from . import err
from functools import partial
import re

# Regular expression for :meth:`Cursor.executemany`.
# executemany only supports simple bulk insert.
# You can use it to load large dataset.
RE_INSERT_VALUES = re.compile(
    r"\s*((?:INSERT|REPLACE)\b.+\bVALUES?\s*)" +
    r"(\(\s*(?:%s|%\(.+\)s)\s*(?:,\s*(?:%s|%\(.+\)s)\s*)*\))" +
    r"(\s*(?:ON DUPLICATE.*)?);?\s*\Z",
    re.IGNORECASE | re.DOTALL)


class Cursor(object):
    """
    This is the object you use to interact with the database.

    Do not create an instance of a Cursor yourself. Call
    connections.Connection.cursor().

    See `Cursor <https://www.python.org/dev/peps/pep-0249/#cursor-objects>`_ in
    the specification.
    """

    #: Max statement size which :meth:`executemany` generates.
    #:
    #: Default value is 1024000.
    max_stmt_length = 1024000

    def __init__(self, connection):
        self.connection = connection
        self.description = None
        self.rowcount = -1
        self.rownumber = 0
        self.arraysize = 1
        self.lastrowid = None
        self._result = None
        self._rows = None
        self._executed = None

    def __enter__(self):
        return self

    def __exit__(self, *exc_info):
        del exc_info
        self.close()

    def __iter__(self):
        return iter(self.fetchone, None)

    def callproc(self, procname, args=()):
        """Execute stored procedure procname with args

        procname -- string, name of procedure to execute on server

        args -- Sequence of parameters to use with procedure

        Returns the original args.

        Compatibility warning: PEP-249 specifies that any modified
        parameters must be returned. This is currently impossible
        as they are only available by storing them in a server
        variable and then retrieved by a query. Since stored
        procedures return zero or more result sets, there is no
        reliable way to get at OUT or INOUT parameters via callproc.
        The server variables are named @_procname_n, where procname
        is the parameter above and n is the position of the parameter
        (from zero). Once all result sets generated by the procedure
        have been fetched, you can issue a SELECT @_procname_0, ...
        query using .execute() to get any OUT or INOUT values.

        Compatibility warning: The act of calling a stored procedure
        itself creates an empty result set. This appears after any
        result sets generated by the procedure. This is non-standard
        behavior with respect to the DB-API. Be sure to use nextset()
        to advance through all result sets; otherwise you may get
        disconnected.
        """

        return args

    def close(self):
        """
        Closing a cursor just exhausts all remaining data.
        """
        conn = self.connection
        if conn is None:
            return
        try:
            while self.nextset():
                pass
        finally:
            self.connection = None

    def _get_db(self):
        if not self.connection:
            raise err.ProgrammingError("Cursor closed")
        return self.connection

    def _escape_args(self, args, conn):
        if isinstance(args, (tuple, list)):
            return tuple(conn.escape(arg) for arg in args)
        elif isinstance(args, dict):
            return {key: conn.escape(val) for (key, val) in args.items()}
        else:
            # If it's not a dictionary let's try escaping it anyway.
            # Worst case it will throw a Value error
            return conn.escape(args)

    def mogrify(self, query, args=None):
        """
        Returns the exact string that is sent to the database by calling the
        execute() method.

        This method follows the extension to the DB API 2.0 followed by Psycopg.
        """
        conn = self._get_db()

        if args is not None:
            query = query % self._escape_args(args, conn)

        return query

    def _clear_result(self):
        self.rownumber = 0
        self._result = None

        self.rowcount = 0
        self.description = None
        self.lastrowid = None
        self._rows = None

    def _do_get_result(self):
        conn = self._get_db()

        self._result = result = conn._result

        self.rowcount = result.affected_rows
        self.description = result.description
        self.lastrowid = result.insert_id
        self._rows = result.rows

    def _query(self, q):
        conn = self._get_db()
        self._last_executed = q
        self._clear_result()
        conn.query(q)
        self._do_get_result()
        return self.rowcount

    def execute(self, query, args=None):
        """Execute a query

        :param str query: Query to execute.

        :param args: parameters used with query. (optional)
        :type args: tuple, list or dict

        :return: Number of affected rows
        :rtype: int

        If args is a list or tuple, %s can be used as a placeholder in the query.
        If args is a dict, %(name)s can be used as a placeholder in the query.
        """
        while self.nextset():
            pass

        query = self.mogrify(query, args)

        result = self._query(query)
        self._executed = query
        return result

    def executemany(self, query, args):
        # type: (str, list) -> int
        """Run several data against one query

        :param query: query to execute on server
        :param args:  Sequence of sequences or mappings.  It is used as parameter.
        :return: Number of rows affected, if any.

        This method improves performance on multiple-row INSERT and
        REPLACE. Otherwise, it is equivalent to looping over args with
        execute().
        """
        if not args:
            return 0

        m = RE_INSERT_VALUES.match(query)
        if m:
            q_prefix = m.group(1) % ()
            q_values = m.group(2).rstrip()
            q_postfix = m.group(3) or ''
            assert q_values[0] == '(' and q_values[-1] == ')'
            return self._do_execute_many(q_prefix, q_values, q_postfix, args,
                                         self.max_stmt_length,
                                         self._get_db().encoding)

        self.rowcount = sum(self.execute(query, arg) for arg in args)
        return self.rowcount

    def _do_execute_many(self, prefix, values, postfix, args, max_stmt_length, encoding):
        conn = self._get_db()
        escape = self._escape_args
        if isinstance(prefix, str):
            prefix = prefix.encode(encoding)
        if isinstance(postfix, str):
            postfix = postfix.encode(encoding)
        sql = str(prefix)
        args = iter(args)
        v = values % escape(next(args), conn)
        if isinstance(v, str):
            v = v.encode(encoding, 'surrogateescape')
        sql += v
        rows = 0
        for arg in args:
            v = values % escape(arg, conn)
            if isinstance(v, str):
                v = v.encode(encoding, 'surrogateescape')
            if len(sql) + len(v) + len(postfix) + 1 > max_stmt_length:
                rows += self.execute(sql + postfix)
                sql = str(prefix)
            else:
                sql += ','
            sql += v
        rows += self.execute(sql + postfix)
        self.rowcount = rows
        return rows

    def _check_executed(self):
        if not self._executed:
            raise err.ProgrammingError("execute() first")

    def fetchone(self):
        """Fetch the next row"""
        self._check_executed()
        if self._rows is None or self.rownumber >= len(self._rows):
            return None
        result = self._rows[self.rownumber]
        self.rownumber += 1
        return result

    def fetchmany(self, size=None):
        """Fetch several rows"""
        self._check_executed()
        if self._rows is None:
            return ()
        end = self.rownumber + (size or self.arraysize)
        result = self._rows[self.rownumber:end]
        self.rownumber = min(end, len(self._rows))
        return result

    def fetchall(self):
        """Fetch all the rows"""
        self._check_executed()
        if self._rows is None:
            return ()
        if self.rownumber:
            result = self._rows[self.rownumber:]
        else:
            result = self._rows
        self.rownumber = len(self._rows)
        return result

    def nextset(self):
        """Get the next query set"""
        # Not support for now
        return None

    def setinputsizes(self, *args):
        """Does nothing, required by DB API."""

    def setoutputsizes(self, *args):
        """Does nothing, required by DB API."""


class DictCursor(Cursor):
    """A cursor which returns results as a dictionary"""
    # You can override this to use OrderedDict or other dict-like types.
    dict_type = dict

    def _do_get_result(self):
        super(self)._do_get_result()
        fields = []
        if self.description:
            for f in self._result.fields:
                name = f.name
                if name in fields:
                    name = f.table_name + '.' + name
                fields.append(name)
            self._fields = fields

        if fields and self._rows:
            self._rows = [self._conv_row(r) for r in self._rows]

    def _conv_row(self, row):
        if row is None:
            return None
        return self.dict_type(zip(self._fields, row))

