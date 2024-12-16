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

configurable Protocol protocol = ?;
configurable Monitoring monitoring = ?;

string host = protocol.API.host ?: "localhost";
int port = protocol.API.port ?: 9090;

listener http:Listener httpListener = new (port,
    host = host
);

# This service converts SWIFT messages to ISO 20022 XML and vice versa.
# The service is exposed at `/transform`.
#
http:Service mtmxRestService =  @http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:3000"],
        allowCredentials: false,
        maxAge: 84900
    }
} service object {

    # SWIFT MT to ISO 20022 transformation service.
    # + return - Transformed ISO 20022 XML or an appropriate error response.
    resource function post mt\-mx/transform(@http:Payload string swiftMessage)
        returns xml|http:NotFound {

        logMessage("MT->MX", swiftMessage.toBalString());
        xml result = transformMtToMx(swiftMessage);
        logMessage("MT->MX", result.toBalString(), true);
        return result;
    }

    # ISO 20022 to SWIFT MT transformation service.
    # + return - Transformed MT or an appropriate error response.
    resource function post mx\-mt/transform(@http:Payload xml isoMessage, string targetType)
        returns string|http:BadRequest {

        logMessage("MX->MT", isoMessage.toBalString());
        string|error result = transformMxToMt(isoMessage, targetType);
        if result is error {
            log:printError("Error while transforming MX message", err = result.toBalString());
            logMessage("MX->MT", result.toBalString());
            return {body: { message: "Message transformation failed"}};
        }
        logMessage("MX->MT", result.toBalString(), true);
        return result;
    }
};
