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

import Swift_to_ISO20022.mtmx as mtToMx; // todo: replace with central library

import ballerina/log;
import ballerina/regex;
import ballerinax/financial.iso20022 as swiftmx;
import ballerinax/financial.iso20022.cash_management as camtIsoRecord;
import ballerinax/financial.iso20022.payment_initiation as painIsoRecord;
import ballerinax/financial.iso20022.payments_clearing_and_settlement as pacsIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

isolated function transformMtToMx(string swiftMessage) returns xml {

    log:printInfo(string `Transforming MT message to ISO 20022 XML`, message = swiftMessage);
    xml|error transformedMsg = mtToMx:toIso20022Xml(swiftMessage);
    if transformedMsg is error {
        log:printError("Error while transforming MT message", err = transformedMsg.toBalString());
        return xml `<error>Unsupported message transformation</error>`;
    }
    log:printDebug(string `Transformed ISO 20022 XML`, transformedMessage = transformedMsg.toString());
    return transformedMsg;
}

isolated function transformMxToMt(xml isoMessage, string targetType) returns string|error {

    log:printInfo(string `Transforming MX message to MT`, targetType = targetType);
    string isotype = "";
    string response = "Unsupported message type";
    if isoMessage is xml:Element {
        string namespace = isoMessage.getAttributes().get("{http://www.w3.org/2000/xmlns/}xmlns");
        string[] messageType = regex:split(namespace, "xsd:");
        isotype = messageType[1].substring(0, 8);
    }

    string conversionType = isotype + "_" + targetType;
    if (!mxToMtTransformFunctionMap.hasKey(conversionType)) {
        log:printError("Unsupported message transformation", mxMessage = isotype, mtMessage = targetType);
        return "Unsupported message transformation";
    }
    isolated function func = mxToMtTransformFunctionMap.get(conversionType);
    record {} isoRecord = check function:call(func, check swiftmx:fromIso20022(isoMessage, isoRecordMap.get(isotype))).ensureType();
    response = check swiftmt:getFinMessage(isoRecord);
    log:printDebug(string `Transformed MT message`, transformedMessage = response);
    return response;
}

final readonly & map<isolated function> mxToMtTransformFunctionMap = {
    "pain.001_MT101": transformPain001DocumentToMT101,
    "pacs.008_MT103": transformPacs008DocumentToMT103,
    "camt.057_MT210": transformCamt057ToMt210
};

final readonly & map<typedesc<record {}>> isoRecordMap = {
    "pain.001": painIsoRecord:Pain001Document,
    "pacs.008": pacsIsoRecord:Pacs008Document,
    "camt.057": camtIsoRecord:Camt057Document
};



// isolated function transformSwiftMTtoMX(string swiftMessage) returns xml|error {

//     xml defaultMapping = transformMtToMx(swiftMessage);
//     record {} inputMessage = {};
//     inputMessage = check swiftmt:parseSwiftMt(swiftMessage);
//     MtMxCustomMapper customMapper = {
//         mt210ToCamt057v08: a
//     }
//     check xmldata:toXml(check function:call(customFunction, defaultMapping, inputMessage).ensureType());
// }

// isolated function a(camtIsoRecord:Camt057Document mappedRecord, swiftmt:MT210Message inputMsg) returns camtIsoRecord:Camt057Document {
//     mappedRecord.NtfctnToRcv.GrpHdr.MsgId = inputMsg.block1?.applicationId ?: mappedRecord.NtfctnToRcv.GrpHdr.MsgId;
//     return mappedRecord;
// };

// # Mapping function type for PV1 segment to Encounter FHIR resource.
// public type MT210ToCAMT057V08 isolated function (camtIsoRecord:Camt057Document mappedRecord, swiftmt:MT210Message inputMsg) returns camtIsoRecord:Camt057Document;

// public type MtMxCustomMapper record {
//     MT210ToCAMT057V08 mt210ToCamt057v08?;
// };

// isolated function transform(string swiftMessage, MtMxCustomMapper customMapper) {
//     xml defaultMapping = transformMtToMx(swiftMessage);
//     record{} inputMessage = check swiftmt:parseSwiftMt(swiftMessage);

// }