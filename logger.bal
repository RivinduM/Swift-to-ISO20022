// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/io;
import ballerina/log;
import ballerina/time;

# Function to log a message with a key
#
# + logKey - log key
# + message - message to log
# + output - boolean to indicate if the message is an output or inout message
public function logMessage(string logKey, string message, boolean output = false) {

    if monitoring.logging.enabled {
        // modify this to log into a file or a central log management system
        error? logResult =logToFile(logKey, message, output);
        if logResult is error {
            handleLogFailure(logResult);
        }
    }

}

function logToFile(string logKey, string message, boolean output = false) returns error?{

    string direction = output ? "OUTPUT" : "INPUT";
    io:FileWriteOption option = "APPEND";
    time:Utc currentTime = time:utcNow();
    time:Civil civilTime = time:utcToCivil(currentTime);
    string time = check time:civilToString(civilTime);
    check io:fileWriteString(monitoring.logging.filePath, 
        string `[${time}][${logKey}][${direction}] message = ${message}` + "\n", option);
}

function handleLogFailure(error e) {
    log:printError("[MT <-> MX Translator] Error while logging", err = e.toBalString());
}
