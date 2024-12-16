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
import ballerinax/rabbitmq;

public rabbitmq:Client mqClient = check new (mqHostname, mqPort);

# This service is used to send messages to the MQ.
# The service is exposed at `/mq` and listens to HTTP requests at port `9092`.
#
@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:3000"],
        allowCredentials: false,
        maxAge: 84900
    }
}
service /mq on new http:Listener(9092) {

    function init() returns error? {

        if (protocol.MQ.enabled) {
            check mqClient->queueDeclare(queueName);
        }
    }

    resource function post sendToMQ(@http:Payload string message) returns http:Accepted|error|http:NotFound {

        if (!protocol.MQ.enabled) {
            log:printError("MQ is not enabled");
            return http:NOT_FOUND;
        }
        // Publishes the message using the mqClient
        check mqClient->publishMessage({content: message.toBytes(), routingKey: queueName});

        return http:ACCEPTED;
    }

}