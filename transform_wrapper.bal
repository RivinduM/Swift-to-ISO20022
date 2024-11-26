import ballerina/log;
import ballerina/regex;
import ballerinax/financial.swiftmtToIso20022 as mtToMx;
import ballerinax/financial.swift.mt as swiftmt;
import ballerinax/financial.iso20022.payment_initiation as painIsoRecord;
import ballerinax/financial.iso20022.payments_clearing_and_settlement as pacsIsoRecord;
import ballerinax/financial.iso20022.cash_management as camtIsoRecord;
import ballerinax/financial.iso20022 as swiftmx;

function transformMtToMx(string swiftMessage) returns xml {

    log:printInfo(string `Transforming MT message to ISO 20022 XML`, message = swiftMessage);
    xml|error transformedMsg = mtToMx:toIso20022Xml(swiftMessage);
    if transformedMsg is error {
        log:printError("Error while transforming MT message", err = transformedMsg.toBalString());
        return xml `<error>Error while transforming MT message</error>`;
    }
    log:printDebug(string `Transformed ISO 20022 XML`, transformedMessage = transformedMsg.toString());
    return transformedMsg;
}

function transformMxToMt(xml isoMessage, string targetType) returns string|error {

    log:printInfo(string `Transforming MX message to MT`, targetType = targetType);
    string isotype = "";
    string response = "Unsupported message type";
    if isoMessage is xml:Element {
        string namespace = isoMessage.getAttributes().get("{http://www.w3.org/2000/xmlns/}xmlns");
        string[] messageType = regex:split(namespace, "xsd:");
        isotype = messageType[1].substring(0, 8);
    }

    string conversionType = isotype + "_" + targetType;
    if (!transformFunctionMap.hasKey(conversionType)) {
        log:printError("Unsupported message transformation", mxMessage = isotype, mtMessage = targetType);
        return "Unsupported message transformation";
    }
    isolated function func = transformFunctionMap.get(conversionType);
    record{} isoRecord = check function:call(func, check swiftmx:fromIso20022(isoMessage, isoRecordMap.get(isotype))).ensureType();
    response = check swiftmt:getFinMessage(isoRecord);
    log:printDebug(string `Transformed MT message`, transformedMessage = response);
    return response;
}


final readonly & map<isolated function> transformFunctionMap = {
    "pain.001_MT101": transformPain001DocumentToMT101,
    "pacs.008_MT103": transformPacs008DocumentToMT103,
    "camt.057_MT210": transformCamt057ToMt210
};

final readonly & map<typedesc<record {}>> isoRecordMap = {
    "pain.001": painIsoRecord:Pain001Document,
    "pacs.008": pacsIsoRecord:Pacs008Document,
    "camt.057": camtIsoRecord:Camt057Document
};