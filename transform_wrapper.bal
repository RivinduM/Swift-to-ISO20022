import ballerina/log;
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
        isotype = isoMessage.getAttributes().get("{http://www.w3.org/2000/xmlns/}xmlns");
    }
    if (isotype.includes("pain.001") && targetType == "MT101") {
        log:printDebug("Transforming Pain001 to MT101");
        painIsoRecord:Pain001Document pain001Message = 
            <painIsoRecord:Pain001Document>(check swiftmx:fromIso20022(isoMessage, painIsoRecord:Pain001Document));
        swiftmt:MT101Message mt101Message = check transformPain001DocumentToMT101(pain001Message);
        response = check swiftmt:getFinMessage(mt101Message);
    } else if (isotype.includes("pacs.008") && targetType == "MT103") {
        log:printDebug("Transforming Pacs008 to MT103");
        pacsIsoRecord:Pacs008Document pacs008Message = 
            <pacsIsoRecord:Pacs008Document>(check swiftmx:fromIso20022(isoMessage, pacsIsoRecord:Pacs008Document));
        swiftmt:MT103Message mt103Message = check transformPacs008DocumentToMT103(pacs008Message);
        response = check swiftmt:getFinMessage(mt103Message);
    } else if (isotype.includes("camt.057") && targetType == "MT210") {
        log:printDebug("Transforming Camt057 to MT210");
        camtIsoRecord:Camt057Document camt057Message = 
            <camtIsoRecord:Camt057Document>(check swiftmx:fromIso20022(isoMessage, camtIsoRecord:Camt057Document));
        swiftmt:MT210Message mt210Message = check transformCamt057ToMt210(camt057Message);
        response = check swiftmt:getFinMessage(mt210Message);
    }
    log:printDebug(string `Transformed MT message`, transformedMessage = response);
    return response;
}