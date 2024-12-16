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
import ballerinax/rabbitmq;

string queueName = protocol.MQ.queueName;
string mqHostname = protocol.MQ.host ?: rabbitmq:DEFAULT_HOST;
int mqPort = protocol.MQ.port ?: rabbitmq:DEFAULT_PORT;

listener rabbitmq:Listener rabbitmqListener = new (mqHostname, mqPort);

@rabbitmq:ServiceConfig {
    queueName: queueName
}
service on rabbitmqListener {
    function init() {
        log:printInfo("[RabbitMQ] Waiting for messages. To exit press CTRL+C.");
    }
    remote function onMessage(rabbitmq:BytesMessage message) returns 
        error? {
        string messageContent = check string:fromBytes(message.content);
        log:printDebug("[RabbitMQ] Received message: " + messageContent);
        logMessage("MT->MX", messageContent);
        xml output = transformMtToMx(messageContent);
        logMessage("MT->MX", output.toBalString(), true);
        check io:fileWriteXml(protocol.MQ.outputFileStorePath + string `/result_mq.xml`, output);

        // Send the output file to the FTP server.
        stream<io:Block, io:Error?> outputFileStream = 
            check io:fileReadBlocksAsStream(protocol.MQ.outputFileStorePath + string `/result_mq.xml`, 1024);
        check fileClient->put("/outputs/result_mq.xml", outputFileStream);
    }
}