/*
 * Copyright (2022) Bytedance Ltd. and/or its affiliates
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#pragma once
#include <Processors/QueryPlan/IQueryPlanStep.h>

namespace DB
{
class SetOperationStep : public IQueryPlanStep
{
public:
    SetOperationStep(
        DataStreams input_streams_, DataStream output_stream_, std::unordered_map<String, std::vector<String>> output_to_inputs_);
    const std::unordered_map<String, std::vector<String>> & getOutToInputs() const;
    void setInputStreams(const DataStreams & input_streams_) override;

protected:
    std::unordered_map<String, std::vector<String>> output_to_inputs;
};

}
