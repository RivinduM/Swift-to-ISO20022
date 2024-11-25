import ballerina/http;


// Represents the subtype of http:Ok status code record for successful conversion.
type SwiftToIso20022Response record {|
    *http:Ok;
    string mediaType = "application/xml";
    xml body;
|};

// Represents the subtype of http:BadRequest status code record for invalid input.
type SwiftToIso20022BadRequest record {|
    *http:BadRequest;
    string body;
|};

# This service converts SWIFT messages to ISO 20022 XML.
# The service is exposed at `/transform` and listens to HTTP requests at port `9090`.
service / on new http:Listener(9090) {

    # SWIFT to ISO 20022 transformation service.
    # + return - Transformed ISO 20022 XML or an appropriate error response.
    resource function post mt\-mx/transform(@http:Payload string swiftMessage)
        returns xml {

            return transformMtToMx(swiftMessage);

    }

    resource function post mx\-mt/transform(@http:Payload xml isoMessage, string targetType)
        returns string|error {

        return transformMxToMt(isoMessage, targetType);

    }
}
