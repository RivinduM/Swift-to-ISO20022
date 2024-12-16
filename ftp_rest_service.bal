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

import ballerina/http;
import ballerina/log;

# This service is used to upload files to the FTP service.
# The service is exposed at `/file` and listens to HTTP requests at port `9091`.
#
@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:3000"],
        allowCredentials: false,
        maxAge: 84900
    }
}
service /file on new http:Listener(9091) {

    resource function get sendToFtp(string fileName) returns error?|http:NotFound|http:Accepted {
        if (!protocol.SFTP.enabled) {
            log:printError("SFTP is not enabled");
            return http:NOT_FOUND;
        }
        check sendFile(fileName);
        return http:ACCEPTED;
    }

}