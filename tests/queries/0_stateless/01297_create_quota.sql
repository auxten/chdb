-- Tags: no-parallel

DROP QUOTA IF EXISTS q1_01297, q2_01297, q3_01297, q4_01297, q5_01297, q6_01297, q7_01297, q8_01297, q9_01297,
q10_01297, q11_01297, q12_01297, q13_01297, q14_01297, q15_01297, q16_01297, q17_01297,q18_01297;

DROP QUOTA IF EXISTS q2_01297_renamed;
DROP USER IF EXISTS u1_01297;
DROP ROLE IF EXISTS r1_01297;

SELECT '-- default';
CREATE QUOTA q1_01297;
SHOW CREATE QUOTA q1_01297;

SELECT '-- same as default';
CREATE QUOTA q2_01297 TO NONE;
CREATE QUOTA q3_01297 FOR INTERVAL 1 HOUR NO LIMITS NOT KEYED TO NONE;
CREATE QUOTA q4_01297 KEYED BY none FOR 1 hour NO LIMITS;
SHOW CREATE QUOTA q2_01297;
SHOW CREATE QUOTA q3_01297;
SHOW CREATE QUOTA q4_01297;

SELECT '-- rename';
ALTER QUOTA q2_01297 RENAME TO 'q2_01297_renamed';
SHOW CREATE QUOTA q2_01297; -- { serverError 199 } -- Policy not found
SHOW CREATE QUOTA q2_01297_renamed;
DROP QUOTA q1_01297, q2_01297_renamed, q3_01297, q4_01297;

SELECT '-- key';
CREATE QUOTA q1_01297 NOT KEYED;
CREATE QUOTA q2_01297 KEY BY user_name;
CREATE QUOTA q3_01297 KEY BY ip_address;
CREATE QUOTA q4_01297 KEY BY client_key;
CREATE QUOTA q5_01297 KEY BY client_key, user_name;
CREATE QUOTA q6_01297 KEY BY client_key, ip_address;
CREATE QUOTA q7_01297 KEYED BY 'none';
CREATE QUOTA q8_01297 KEYED BY 'user name';
CREATE QUOTA q9_01297 KEYED BY 'IP_ADDRESS';
CREATE QUOTA q10_01297 KEYED BY CLIENT_KEY;
CREATE QUOTA q11_01297 KEYED BY 'client key or user name';
CREATE QUOTA q12_01297 KEYED BY 'client key or ip address';
SHOW CREATE QUOTA q1_01297;
SHOW CREATE QUOTA q2_01297;
SHOW CREATE QUOTA q3_01297;
SHOW CREATE QUOTA q4_01297;
SHOW CREATE QUOTA q5_01297;
SHOW CREATE QUOTA q6_01297;
SHOW CREATE QUOTA q7_01297;
SHOW CREATE QUOTA q8_01297;
SHOW CREATE QUOTA q9_01297;
SHOW CREATE QUOTA q10_01297;
SHOW CREATE QUOTA q11_01297;
SHOW CREATE QUOTA q12_01297;
ALTER QUOTA q1_01297 KEY BY user_name;
ALTER QUOTA q2_01297 KEY BY client_key, user_name;
ALTER QUOTA q3_01297 NOT KEYED;
SHOW CREATE QUOTA q1_01297;
SHOW CREATE QUOTA q2_01297;
SHOW CREATE QUOTA q3_01297;
DROP QUOTA q1_01297, q2_01297, q3_01297, q4_01297, q5_01297, q6_01297, q7_01297, q8_01297, q9_01297, q10_01297, q11_01297, q12_01297;

SELECT '-- intervals';
CREATE QUOTA q1_01297 FOR INTERVAL 5 DAY MAX ERRORS = 3;
CREATE QUOTA q2_01297 FOR INTERVAL 30 minute MAX ERRORS 4;
CREATE QUOTA q3_01297 FOR 1 HOUR errors MAX 5;
CREATE QUOTA q4_01297 FOR 2000 SECOND errors MAX 5;
CREATE QUOTA q5_01297 FOR RANDOMIZED INTERVAL 1 YEAR MAX errors = 11, MAX queries = 100;
CREATE QUOTA q6_01297 FOR 2 MONTH MAX errors = 11, queries = 100, result_rows = 1000, result_bytes = 10000, read_rows = 1001, read_bytes = 10001, execution_time=2.5;
CREATE QUOTA q7_01297 FOR 1 QUARTER MAX errors 11, queries 100;
CREATE QUOTA q8_01297 FOR 0.5 year ERRORS MAX 11, QUERIES MAX 100, FOR 2 MONTH RESULT ROWS MAX 1002;
SHOW CREATE QUOTA q1_01297;
SHOW CREATE QUOTA q2_01297;
SHOW CREATE QUOTA q3_01297;
SHOW CREATE QUOTA q4_01297;
SHOW CREATE QUOTA q5_01297;
SHOW CREATE QUOTA q6_01297;
SHOW CREATE QUOTA q7_01297;
SHOW CREATE QUOTA q8_01297;
ALTER QUOTA q1_01297 FOR INTERVAL 5 DAY NO LIMITS;
ALTER QUOTA q2_01297 FOR INTERVAL 30 MINUTE TRACKING ONLY;
ALTER QUOTA q3_01297 FOR INTERVAL 2 HOUR MAX errors = 10, FOR INTERVAL 1 HOUR MAX queries = 70;
ALTER QUOTA q4_01297 FOR RANDOMIZED INTERVAL 2000 SECOND errors MAX 5;
ALTER QUOTA q5_01297 FOR 1 YEAR MAX errors = 111;
SHOW CREATE QUOTA q1_01297;
SHOW CREATE QUOTA q2_01297;
SHOW CREATE QUOTA q3_01297;
SHOW CREATE QUOTA q4_01297;
SHOW CREATE QUOTA q5_01297;
DROP QUOTA q1_01297, q2_01297, q3_01297, q4_01297, q5_01297, q6_01297, q7_01297, q8_01297;

SELECT '-- to roles';
CREATE ROLE r1_01297;
CREATE USER u1_01297;
CREATE QUOTA q1_01297 TO NONE;
CREATE QUOTA q2_01297 TO ALL;
CREATE QUOTA q3_01297 TO r1_01297;
CREATE QUOTA q4_01297 TO u1_01297;
CREATE QUOTA q5_01297 TO r1_01297, u1_01297;
CREATE QUOTA q6_01297 TO ALL EXCEPT r1_01297;
CREATE QUOTA q7_01297 TO ALL EXCEPT r1_01297, u1_01297;
SHOW CREATE QUOTA q1_01297;
SHOW CREATE QUOTA q2_01297;
SHOW CREATE QUOTA q3_01297;
SHOW CREATE QUOTA q4_01297;
SHOW CREATE QUOTA q5_01297;
SHOW CREATE QUOTA q6_01297;
SHOW CREATE QUOTA q7_01297;
ALTER QUOTA q1_01297 TO u1_01297;
ALTER QUOTA q2_01297 TO NONE;
SHOW CREATE QUOTA q1_01297;
SHOW CREATE QUOTA q2_01297;
DROP QUOTA q1_01297, q2_01297, q3_01297, q4_01297, q5_01297, q6_01297, q7_01297;

SELECT '-- multiple quotas in one command';
CREATE QUOTA q1_01297, q2_01297 FOR 1 day MAX errors=5;
SHOW CREATE QUOTA q1_01297, q2_01297;
ALTER QUOTA q1_01297, q2_01297 FOR 1 day TRACKING ONLY TO r1_01297;
SHOW CREATE QUOTA q1_01297, q2_01297;
DROP QUOTA q1_01297, q2_01297;

SELECT '-- system.quotas';
CREATE QUOTA q1_01297 KEYED BY user_name TO r1_01297;
CREATE QUOTA q2_01297 FOR 2 MONTH MAX errors = 11, queries = 100, result_rows = 1000, result_bytes = 10000, read_rows = 1001, read_bytes = 10001, execution_time=2.5 TO r1_01297, u1_01297;
CREATE QUOTA q3_01297 KEYED BY client_key, user_name FOR 0.5 YEAR ERRORS MAX 11, QUERIES MAX 100, FOR 2 MONTH RESULT ROWS MAX 1002;
CREATE QUOTA q4_01297 FOR 1 WEEK TRACKING ONLY TO ALL EXCEPT u1_01297;
SELECT name, storage, keys, durations, apply_to_all, apply_to_list, apply_to_except FROM system.quotas WHERE name LIKE 'q%\_01297' ORDER BY name;

SELECT '-- system.quota_limits';
SELECT * FROM system.quota_limits WHERE quota_name LIKE 'q%\_01297' ORDER BY quota_name, duration;
DROP QUOTA q1_01297, q2_01297, q3_01297, q4_01297;

SELECT '-- query_selects query_inserts';
CREATE QUOTA q1_01297 KEYED BY user_name FOR INTERVAL 1 minute MAX query_selects = 1 TO r1_01297;
CREATE QUOTA q2_01297 KEYED BY user_name FOR INTERVAL 1 minute MAX query_inserts = 1 TO r1_01297;
SHOW CREATE QUOTA q1_01297;
SHOW CREATE QUOTA q2_01297;
DROP QUOTA q1_01297, q2_01297;

DROP ROLE r1_01297;
DROP USER u1_01297;

SELECT '-- size suffix';
SELECT '-- functional test';
CREATE QUOTA q1_01297 FOR INTERVAL 1 MINUTE MAX query_selects = '12K';
CREATE QUOTA q2_01297 FOR INTERVAL 1 MINUTE MAX query_selects = '12Ki';
CREATE QUOTA q3_01297 FOR INTERVAL 1 MINUTE MAX query_selects = '12M';
CREATE QUOTA q4_01297 FOR INTERVAL 1 MINUTE MAX query_selects = '12Mi';
CREATE QUOTA q5_01297 FOR INTERVAL 1 MINUTE MAX query_selects = '12G';
CREATE QUOTA q6_01297 FOR INTERVAL 1 MINUTE MAX query_selects = '12Gi';
CREATE QUOTA q7_01297 FOR INTERVAL 1 MINUTE MAX query_selects = '12T';
CREATE QUOTA q8_01297 FOR INTERVAL 1 MINUTE MAX query_selects = '12Ti';
CREATE QUOTA q9_01297 FOR INTERVAL 1 MINUTE MAX execution_time = '12K';
CREATE QUOTA q10_01297 FOR INTERVAL 1 MINUTE MAX execution_time = '12Ki';
CREATE QUOTA q11_01297 FOR INTERVAL 1 MINUTE MAX execution_time = '12M';
CREATE QUOTA q12_01297 FOR INTERVAL 1 MINUTE MAX execution_time = '12Mi';
CREATE QUOTA q13_01297 FOR INTERVAL 1 MINUTE MAX execution_time = '12G';
CREATE QUOTA q14_01297 FOR INTERVAL 1 MINUTE MAX execution_time = '12Gi';
CREATE QUOTA q15_01297 FOR INTERVAL 1 MINUTE MAX query_selects = 1.5;
CREATE QUOTA q16_01297 FOR INTERVAL 1 MINUTE MAX execution_time = 1.5;
CREATE QUOTA q17_01297 FOR INTERVAL 1 MINUTE MAX query_selects = '1.5'; -- { clientError 27 }
CREATE QUOTA q18_01297 FOR INTERVAL 1 MINUTE MAX execution_time = '1.5'; -- { clientError 27 }
SHOW CREATE QUOTA q1_01297;
SHOW CREATE QUOTA q2_01297;
SHOW CREATE QUOTA q3_01297;
SHOW CREATE QUOTA q4_01297;
SHOW CREATE QUOTA q5_01297;
SHOW CREATE QUOTA q6_01297;
SHOW CREATE QUOTA q7_01297;
SHOW CREATE QUOTA q8_01297;
SHOW CREATE QUOTA q9_01297;
SHOW CREATE QUOTA q10_01297;
SHOW CREATE QUOTA q11_01297;
SHOW CREATE QUOTA q12_01297;
SHOW CREATE QUOTA q13_01297;
SHOW CREATE QUOTA q14_01297;
SHOW CREATE QUOTA q15_01297;
SHOW CREATE QUOTA q16_01297;
DROP QUOTA IF EXISTS q1_01297;
DROP QUOTA IF EXISTS q2_01297;
DROP QUOTA IF EXISTS q3_01297;
DROP QUOTA IF EXISTS q4_01297;
DROP QUOTA IF EXISTS q5_01297;
DROP QUOTA IF EXISTS q6_01297;
DROP QUOTA IF EXISTS q7_01297;
DROP QUOTA IF EXISTS q8_01297;
DROP QUOTA IF EXISTS q9_01297;
DROP QUOTA IF EXISTS q10_01297;
DROP QUOTA IF EXISTS q11_01297;
DROP QUOTA IF EXISTS q12_01297;
DROP QUOTA IF EXISTS q13_01297;
DROP QUOTA IF EXISTS q14_01297;
DROP QUOTA IF EXISTS q15_01297;
DROP QUOTA IF EXISTS q16_01297;
SELECT '-- overflow test';
CREATE QUOTA q1_01297 FOR INTERVAL 1 MINUTE MAX query_selects = '18446744073709551615';
CREATE QUOTA q2_01297 FOR INTERVAL 1 MINUTE MAX execution_time = '18446744073';
SHOW CREATE QUOTA q1_01297;
SHOW CREATE QUOTA q2_01297;
DROP QUOTA IF EXISTS q1_01297;
DROP QUOTA IF EXISTS q2_01297;
SELECT '-- FIXME';
SELECT '-- the overflow happens somewhere else before reaching the up bound of Quota Value , not in the parser';
SELECT '-- the overflow have different behavior in different environment';
-- CREATE QUOTA q1_01297 FOR INTERVAL 1 MINUTE MAX query_selects = '18446744073709551616';
-- CREATE QUOTA q2_01297 FOR INTERVAL 1 MINUTE MAX execution_time = '1T';
-- CREATE QUOTA q3_01297 FOR INTERVAL 1 MINUTE MAX execution_time = '1Ti';
-- CREATE QUOTA q4_01297 FOR INTERVAL 1 MINUTE MAX execution_time = '18446744074';
-- SHOW CREATE QUOTA q1_01297;
-- SHOW CREATE QUOTA q2_01297;
-- SHOW CREATE QUOTA q3_01297;
-- SHOW CREATE QUOTA q4_01297;
-- DROP QUOTA IF EXISTS q1_01297;
-- DROP QUOTA IF EXISTS q2_01297;
-- DROP QUOTA IF EXISTS q3_01297;
-- DROP QUOTA IF EXISTS q4_01297;
SELECT '-- zero test';
CREATE QUOTA q1_01297 FOR INTERVAL 1 MINUTE MAX query_selects = '0';
CREATE QUOTA q2_01297 FOR INTERVAL 1 MINUTE MAX execution_time = '0';
SHOW CREATE QUOTA q1_01297;
SHOW CREATE QUOTA q2_01297;
DROP QUOTA IF EXISTS q1_01297;
DROP QUOTA IF EXISTS q2_01297;
SELECT '-- underflow test';
CREATE QUOTA q1_01297 FOR INTERVAL 1 MINUTE MAX query_selects = '-1'; -- { clientError 72 }
CREATE QUOTA q2_01297 FOR INTERVAL 1 MINUTE MAX execution_time = '-1'; -- { clientError 72 }
SELECT '-- syntax test';
CREATE QUOTA q1_01297 FOR INTERVAL 1 MINUTE MAX query_selects = ' 12 ';
CREATE QUOTA q2_01297 FOR INTERVAL 1 MINUTE MAX execution_time = ' 12 ';
CREATE QUOTA q3_01297 FOR INTERVAL 1 MINUTE MAX query_selects = ' 12k ';
CREATE QUOTA q4_01297 FOR INTERVAL 1 MINUTE MAX execution_time = ' 12k ';
CREATE QUOTA q5_01297 FOR INTERVAL 1 MINUTE MAX execution_time = ' 00 ';
CREATE QUOTA q6_01297 FOR INTERVAL 1 MINUTE MAX execution_time = ' 00 ';
CREATE QUOTA q7_01297 FOR INTERVAL 1 MINUTE MAX execution_time = ' 00k ';
CREATE QUOTA q8_01297 FOR INTERVAL 1 MINUTE MAX execution_time = ' 00k ';
CREATE QUOTA q9_01297 FOR INTERVAL 1 MINUTE MAX execution_time = ' 00123k ';
CREATE QUOTA q10_01297 FOR INTERVAL 1 MINUTE MAX execution_time = ' 00123k ';
SHOW CREATE QUOTA q1_01297;
SHOW CREATE QUOTA q2_01297;
SHOW CREATE QUOTA q3_01297;
SHOW CREATE QUOTA q4_01297;
SHOW CREATE QUOTA q5_01297;
SHOW CREATE QUOTA q6_01297;
SHOW CREATE QUOTA q7_01297;
SHOW CREATE QUOTA q8_01297;
SHOW CREATE QUOTA q9_01297;
SHOW CREATE QUOTA q10_01297;
DROP QUOTA IF EXISTS q1_01297;
DROP QUOTA IF EXISTS q2_01297;
DROP QUOTA IF EXISTS q3_01297;
DROP QUOTA IF EXISTS q4_01297;
DROP QUOTA IF EXISTS q5_01297;
DROP QUOTA IF EXISTS q6_01297;
DROP QUOTA IF EXISTS q7_01297;
DROP QUOTA IF EXISTS q8_01297;
DROP QUOTA IF EXISTS q9_01297;
DROP QUOTA IF EXISTS q10_01297;
SELECT '-- bad syntax test';
CREATE QUOTA q1_01297 FOR INTERVAL 1 MINUTE MAX query_selects = '1 1'; -- { clientError 27 }
CREATE QUOTA q2_01297 FOR INTERVAL 1 MINUTE MAX execution_time = '1 1'; -- { clientError 27 }
CREATE QUOTA q3_01297 FOR INTERVAL 1 MINUTE MAX query_selects = '1K 1'; -- { clientError 27 }
CREATE QUOTA q4_01297 FOR INTERVAL 1 MINUTE MAX execution_time = '1K 1'; -- { clientError 27 }
CREATE QUOTA q5_01297 FOR INTERVAL 1 MINUTE MAX query_selects = '1K1'; -- { clientError 27 }
CREATE QUOTA q6_01297 FOR INTERVAL 1 MINUTE MAX execution_time = '1K1'; -- { clientError 27 }
CREATE QUOTA q7_01297 FOR INTERVAL 1 MINUTE MAX query_selects = 'foo'; -- { clientError 27 }
CREATE QUOTA q8_01297 FOR INTERVAL 1 MINUTE MAX execution_time = 'bar'; -- { clientError 27 }
