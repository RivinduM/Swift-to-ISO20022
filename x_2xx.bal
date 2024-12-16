import ballerinax/financial.iso20022.payments_clearing_and_settlement as pacsIsoRecord;
import ballerinax/financial.iso20022.cash_management as camtIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

isolated function transformPacs009ToMt200(pacsIsoRecord:Pacs009Document document) returns swiftmt:MT200Message|error => {
    block2: {
        'type: "input",
        messageType: "200"
    }, 
    block3: {
        NdToNdTxRef: {value: getMandatory(document.FICdtTrf.CdtTrfTxInf[0].PmtId.UETR)}
    },
    block4: {
        MT20: {
            name: "20",
            msgId: {
                content: getMandatory(document.FICdtTrf.CdtTrfTxInf[0].PmtId.InstrId),
                number: "1"
            }
        }, 
        MT32A: {
            name: "32A",
            Dt: {
                content: getMandatory(document.FICdtTrf.CdtTrfTxInf[0].IntrBkSttlmDt),
                number: "1"
            }, 
            Ccy: {
                content: getMandatory(document.FICdtTrf.CdtTrfTxInf[0].IntrBkSttlmAmt.ActiveCurrencyAndAmount_SimpleType.Ccy),
                number: "2"
            }, 
            Amnt: {
                content: check convertToString(document.FICdtTrf.CdtTrfTxInf[0].IntrBkSttlmAmt.ActiveCurrencyAndAmount_SimpleType.ActiveCurrencyAndAmount_SimpleType),
                number: "3"
            }
        },
        MT53B: {
            name:"53B",
            PrtyIdn: {
                content: getFieldMt53Or54(document.FICdtTrf.GrpHdr.SttlmInf.InstgRmbrsmntAgt?.FinInstnId?.LEI, document.FICdtTrf.GrpHdr.SttlmInf.InstgRmbrsmntAgtAcct?.Id?.IBAN, document.FICdtTrf.GrpHdr.SttlmInf.InstgRmbrsmntAgtAcct?.Id?.Othr?.Id)[2], 
                number: "2"
            }
        },
        MT56A: getField56(document.FICdtTrf.CdtTrfTxInf[0].IntrmyAgt1?.FinInstnId?.BICFI, document.FICdtTrf.CdtTrfTxInf[0].IntrmyAgt1?.FinInstnId?.Nm, document.FICdtTrf.CdtTrfTxInf[0].IntrmyAgt1?.FinInstnId?.PstlAdr?.AdrLine, document.FICdtTrf.CdtTrfTxInf[0].IntrmyAgt1?.FinInstnId?.LEI)[0],
        MT56D: getField56(document.FICdtTrf.CdtTrfTxInf[0].IntrmyAgt1?.FinInstnId?.BICFI, document.FICdtTrf.CdtTrfTxInf[0].IntrmyAgt1?.FinInstnId?.Nm, document.FICdtTrf.CdtTrfTxInf[0].IntrmyAgt1?.FinInstnId?.PstlAdr?.AdrLine, document.FICdtTrf.CdtTrfTxInf[0].IntrmyAgt1?.FinInstnId?.LEI)[2],
        MT57A: getField57(document.FICdtTrf.CdtTrfTxInf[0].CdtrAgt?.FinInstnId?.BICFI, document.FICdtTrf.CdtTrfTxInf[0].CdtrAgt?.FinInstnId?.Nm, document.FICdtTrf.CdtTrfTxInf[0].CdtrAgt?.FinInstnId?.PstlAdr?.AdrLine, document.FICdtTrf.CdtTrfTxInf[0].CdtrAgt?.FinInstnId?.LEI)[0],
        MT57B: getField57(document.FICdtTrf.CdtTrfTxInf[0].CdtrAgt?.FinInstnId?.BICFI, document.FICdtTrf.CdtTrfTxInf[0].CdtrAgt?.FinInstnId?.Nm, document.FICdtTrf.CdtTrfTxInf[0].CdtrAgt?.FinInstnId?.PstlAdr?.AdrLine, document.FICdtTrf.CdtTrfTxInf[0].CdtrAgt?.FinInstnId?.LEI)[1],
        MT57D: getField57(document.FICdtTrf.CdtTrfTxInf[0].CdtrAgt?.FinInstnId?.BICFI, document.FICdtTrf.CdtTrfTxInf[0].CdtrAgt?.FinInstnId?.Nm, document.FICdtTrf.CdtTrfTxInf[0].CdtrAgt?.FinInstnId?.PstlAdr?.AdrLine, document.FICdtTrf.CdtTrfTxInf[0].CdtrAgt?.FinInstnId?.LEI)[3],
        MT72: getField72(document.FICdtTrf.CdtTrfTxInf[0].InstrForCdtrAgt, document.FICdtTrf.CdtTrfTxInf[0].InstrForNxtAgt)
    }
};

isolated function transformCamt057ToMt210 (camtIsoRecord:Camt057Document document) returns swiftmt:MT210Message|error {
    swiftmt:MT210Message message = {
        block2: {
            'type: "input",
            messageType: "210"
        }, 
        block4: {
            MT20: {
                name: "20",
                msgId: {content: document.NtfctnToRcv.Ntfctn.Id, number: "1"}
            }, 
            MT21: {
                name: "21",
                Ref: {content: getField21(document.NtfctnToRcv.Ntfctn.Itm[0].EndToEndId, id = document.NtfctnToRcv.Ntfctn.Itm[0].Id), number: "1"}
            }, 
            MT32B: {
                name: "32B",
                Ccy: {content: document.NtfctnToRcv.Ntfctn.Itm[0].Amt.ActiveOrHistoricCurrencyAndAmount_SimpleType.Ccy, number: "1"}, 
                Amnt: {content: check convertToString(document.NtfctnToRcv.Ntfctn.Itm[0].Amt.ActiveOrHistoricCurrencyAndAmount_SimpleType.ActiveOrHistoricCurrencyAndAmount_SimpleType), number: "2"}
            },
            MT30: {
                name: "30",
                Dt: {content: getMandatory(document.NtfctnToRcv.Ntfctn.Itm[0].XpctdValDt), number: "1"}
            },
            MT25: getField25(document.NtfctnToRcv.Ntfctn.Itm[0].Acct?.Id?.IBAN, document.NtfctnToRcv.Ntfctn.Itm[0].Acct?.Id?.Othr?.Id),
            MT56A: getField56(document.NtfctnToRcv.Ntfctn.Itm[0].IntrmyAgt?.FinInstnId?.BICFI, document.NtfctnToRcv.Ntfctn.Itm[0].IntrmyAgt?.FinInstnId?.Nm, document.NtfctnToRcv.Ntfctn.Itm[0].IntrmyAgt?.FinInstnId?.PstlAdr?.AdrLine, document.NtfctnToRcv.Ntfctn.Itm[0].IntrmyAgt?.FinInstnId?.LEI)[0],
            MT56D: getField56(document.NtfctnToRcv.Ntfctn.Itm[0].IntrmyAgt?.FinInstnId?.BICFI, document.NtfctnToRcv.Ntfctn.Itm[0].IntrmyAgt?.FinInstnId?.Nm, document.NtfctnToRcv.Ntfctn.Itm[0].IntrmyAgt?.FinInstnId?.PstlAdr?.AdrLine, document.NtfctnToRcv.Ntfctn.Itm[0].IntrmyAgt?.FinInstnId?.LEI)[2],
            MT52A: getField52(document.NtfctnToRcv.Ntfctn.Itm[0].DbtrAgt?.FinInstnId?.BICFI, document.NtfctnToRcv.Ntfctn.Itm[0].DbtrAgt?.FinInstnId?.Nm, document.NtfctnToRcv.Ntfctn.Itm[0].DbtrAgt?.FinInstnId?.PstlAdr?.AdrLine, document.NtfctnToRcv.Ntfctn.Itm[0].DbtrAgt?.FinInstnId?.LEI)[0],
            MT52D: getField52(document.NtfctnToRcv.Ntfctn.Itm[0].DbtrAgt?.FinInstnId?.BICFI, document.NtfctnToRcv.Ntfctn.Itm[0].DbtrAgt?.FinInstnId?.Nm, document.NtfctnToRcv.Ntfctn.Itm[0].DbtrAgt?.FinInstnId?.PstlAdr?.AdrLine, document.NtfctnToRcv.Ntfctn.Itm[0].DbtrAgt?.FinInstnId?.LEI)[3],
            MT50: getField50Or50COr50L(document.NtfctnToRcv.Ntfctn.Itm[0].Dbtr?.Pty?.Id?.OrgId?.AnyBIC, document.NtfctnToRcv.Ntfctn.Itm[0].Dbtr?.Pty?.Nm, document.NtfctnToRcv.Ntfctn.Itm[0].Dbtr?.Pty?.PstlAdr?.AdrLine, document.NtfctnToRcv.Ntfctn.Itm[0].Dbtr?.Pty?.Id?.PrvtId?.Othr)[0],
            MT50C: getField50Or50COr50L(document.NtfctnToRcv.Ntfctn.Itm[0].Dbtr?.Pty?.Id?.OrgId?.AnyBIC, document.NtfctnToRcv.Ntfctn.Itm[0].Dbtr?.Pty?.Nm, document.NtfctnToRcv.Ntfctn.Itm[0].Dbtr?.Pty?.PstlAdr?.AdrLine, document.NtfctnToRcv.Ntfctn.Itm[0].Dbtr?.Pty?.Id?.PrvtId?.Othr)[1],
            MT50F: getField50a(document.NtfctnToRcv.Ntfctn.Itm[0].Dbtr?.Pty?.Id?.OrgId?.AnyBIC, document.NtfctnToRcv.Ntfctn.Itm[0].Dbtr?.Pty?.Nm, document.NtfctnToRcv.Ntfctn.Itm[0].Dbtr?.Pty?.PstlAdr?.AdrLine, (), (), document.NtfctnToRcv.Ntfctn.Itm[0].Dbtr?.Pty?.Id?.PrvtId?.Othr)[4]
        }
    };
    return message;
};

isolated function getMandatory(string? content) returns string {
    if content is string {
        return content;
    }
    return "";
}

isolated function convertToString(decimal? content) returns string|error {
    if content is decimal {
        string amount = content.toString();
        return amount.substring(0,check amount.lastIndexOf(".").ensureType(int)) + "," + amount.substring(check amount.lastIndexOf(".").ensureType(int) + 1);
    }
    return "";
}

isolated function getFieldMt53Or54(string? partyIdentifier, string? account1, string? account2, string? identifierCode = (), string? name = (), pacsIsoRecord:Max70Text[]? address = ()) returns string[] {
    if partyIdentifier is string && identifierCode is string {
        return [partyIdentifier, "", ""];
    }
    if partyIdentifier is string && (name is string || address is pacsIsoRecord:Max70Text[]) {
        return ["", partyIdentifier, ""];
    }
    if partyIdentifier is string {
        return ["", "", partyIdentifier];
    }
    if account1 is string && identifierCode is string {
        return [account1, "", ""];
    }
    if account2 is string && (name is string || address is pacsIsoRecord:Max70Text[]) {
        return ["", account2, ""];
    }
    if account2 is string {
        return ["", "", account2];
    }
    return ["", "", ""];
}

isolated function getAddressLine(pacsIsoRecord:Max70Text[]? address1) returns swiftmt:AdrsLine[] {
    swiftmt:AdrsLine[] address = [];
    int count = 4;
    if address1 is pacsIsoRecord:Max70Text[] {
        foreach string adrsLine in address1{
            address.push({content: adrsLine, number: count.toString()});
            count += 1;
        }
    } 
    return address;
}

isolated function getField72(pacsIsoRecord:InstructionForCreditorAgent3[]? instruction1, pacsIsoRecord:InstructionForNextAgent1[]? instruction2) returns swiftmt:MT72? {
    if instruction1 is pacsIsoRecord:InstructionForCreditorAgent3[] {
        if instruction1.length() == 1 {
            return getField72SingleCode(instruction1);
        } 
    }
    if instruction2 is pacsIsoRecord:InstructionForNextAgent1[] {
        if instruction2.length() == 1 {
            return getField72SingleCode(instruction2);
        } 
    }
    return ();
}

isolated function getField72SingleCode(pacsIsoRecord:InstructionForCreditorAgent3[]|pacsIsoRecord:InstructionForNextAgent1[] instruction) returns swiftmt:MT72? {
    if instruction[0].Cd !is pacsIsoRecord:Instruction4Code {
        return ();
    } 
    if instruction[0].InstrInf !is pacsIsoRecord:Max140Text{
        return {name: "72", Cd: {content: "/" + instruction[0].Cd.toString(), number: "1"}};
    }
    string instrInf = instruction[0].InstrInf.toString();
    string narrative = "/" + instruction[0].Cd.toString() + "/";
    int lineLen = 35 - instruction[0].Cd.toString().length();
    int lastIndex = 0;
    int linesCount = 1;
    foreach int i in 0...instrInf.length() {
        if (i-lastIndex) % lineLen == 0 && i != 0{
            linesCount += 1;
            if linesCount > 6 {
                break;
            }
            narrative += "\n//";
            lineLen = 35;
            lastIndex = i;
        } 
        narrative += instrInf.substring(i,i+1);
    }
    return {name: "72", Cd: {content: narrative, number: "1"}};
}

isolated function getField72MultipleCode(pacsIsoRecord:InstructionForCreditorAgent3[]|pacsIsoRecord:InstructionForNextAgent1[] instructions) returns swiftmt:MT72?{
    if instructions[0].Cd !is string {
        return ();
    }
    string narrative = "";
    int linesCount = 1;
    foreach int i in 0 ... instructions.length()-1 {
        if linesCount > 6 || instructions[i].Cd !is pacsIsoRecord:Instruction4Code {
            return {name: "72", Cd: {content: narrative, number: "1"}};
        }
        if instructions[i].InstrInf !is pacsIsoRecord:Max140Text {
            continue;
        }
        string instrInf = instructions[i].InstrInf.toString();
        narrative += "/" + instructions[i].Cd.toString() + "/";
        int lineLen = 35 - instructions[0].Cd.toString().length();
        int lastIndex = 0;
        foreach int index in 0...instrInf.length() {
            if (index-lastIndex) % lineLen == 0 && index != 0{
                linesCount += 1;
                narrative += "\n//";
                lineLen = 35;
                lastIndex = index;
            } 
            narrative += instrInf.substring(index,index+1);
        }
        narrative += "\n";
        linesCount += 1;
    }
    return {name: "72", Cd: {content: narrative, number: "1"}};
}

isolated function getField21(string? endToEndId, string? txId = (), string? id = ()) returns string {
    if endToEndId is string && endToEndId.length() > 4 && !(endToEndId.substring(1,4).equalsIgnoreCaseAscii("ROC")) {
        return endToEndId;
    }
    if txId is string {
        return txId;
    }
    if id is string {
        return id;
    }
    return "";
}

isolated function getField56(string? identifierCode, string? name, pacsIsoRecord:Max70Text[]? address, string? partyIdentifier) returns [swiftmt:MT56A?, swiftmt:MT56C?, swiftmt:MT56D?] {
    if identifierCode is string && partyIdentifier is string{
        swiftmt:MT56A fieldMt56A = {
            name: "56A",
            PrtyIdn: {content: partyIdentifier, number: "2"},
            IdnCd: {content: identifierCode, number: "3"}
        };
        return [fieldMt56A, (), ()];
    }
    if identifierCode is string {
        swiftmt:MT56A fieldMt56A = {
            name: "56A",
            IdnCd: {content: identifierCode, number: "3"}
        };
        return [fieldMt56A, (), ()];
    }
    if (name is string || address is pacsIsoRecord:Max70Text[]) && partyIdentifier is string {
        swiftmt:MT56D fieldMt56D = {
            name: "56D",
            PrtyIdn: {content: partyIdentifier, number: "2"},
            AdrsLine: getAddressLine(address), 
            Nm: [{content: getMandatory(name), number: "3"}]
        };
        return [(), (), fieldMt56D];
    }
    if name is string || address is pacsIsoRecord:Max70Text[] {
        swiftmt:MT56D fieldMt56D = {
            name: "56D",
            AdrsLine: getAddressLine(address), 
            Nm: [{content: getMandatory(name), number: "3"}]
        };
        return [(), (), fieldMt56D];
    }
    if partyIdentifier is string {
        swiftmt:MT56C fieldMt56C = {
            name: "56C",
            PrtyIdn: {content: partyIdentifier, number: "1"}
        };
        return [(), fieldMt56C, ()];
    }
    return [(), (), ()];
}

isolated function getField57(string? identifierCode, string? name, pacsIsoRecord:Max70Text[]? address, string? partyIdentifier, boolean isField57CPresent = false) returns [swiftmt:MT57A?, swiftmt:MT57B?,swiftmt:MT57C?, swiftmt:MT57D?] {
    if identifierCode is string && partyIdentifier is string{
        swiftmt:MT57A fieldMt57A = {
            name: "57A",
            PrtyIdn: {content: partyIdentifier, number: "2"},
            IdnCd: {content: identifierCode, number: "3"}
        };
        return [fieldMt57A,(), (), ()];
    }
    if identifierCode is string {
        swiftmt:MT57A fieldMt57A = {
            name: "57A",
            IdnCd: {content: identifierCode, number: "3"}
        };
        return [fieldMt57A, (), (), ()];
    }
    if (name is string || address is pacsIsoRecord:Max70Text[]) && partyIdentifier is string {
        swiftmt:MT57D fieldMt57D = {
            name: "57D",
            PrtyIdn: {content: partyIdentifier, number: "2"},
            AdrsLine: getAddressLine(address), 
            Nm: [{content: getMandatory(name), number: "3"}]
        };
        return [(), (), (), fieldMt57D];
    }
    if name is string || address is pacsIsoRecord:Max70Text[] {
        swiftmt:MT57D fieldMt57D = {
            name: "57D",
            AdrsLine: getAddressLine(address), 
            Nm: [{content: getMandatory(name), number: "3"}]
        };
        return [(), (), (), fieldMt57D];
    }
    if partyIdentifier is string && isField57CPresent{
        swiftmt:MT57C fieldMt57C = {
            name: "57C",
            PrtyIdn: {content: partyIdentifier, number: "1"}
        };
        return [(), (), fieldMt57C, ()];
    }
    if partyIdentifier is string {
        swiftmt:MT57B fieldMt57B = {
            name: "57B",
            PrtyIdn: {content: partyIdentifier, number: "2"}
        };
        return [(), fieldMt57B, (), ()];
    }
    return [(), (), (), ()];
}

isolated function getAccountId(string? iban, string? bban) returns string {
    if iban is string {
        return iban;
    }
    if bban is string {
        return bban;
    }
    return "";
}

isolated function getField25(string? iban, string? bban) returns swiftmt:MT25A? {
    if iban is string || bban is string {
        return {name: "25", Acc: {content: getAccountId(iban, bban)}};
    }
    return ();
}

isolated function getField52(string? identifierCode, string? name, pacsIsoRecord:Max70Text[]? address, string? partyIdentifier, boolean isField52CPresent = false) returns [swiftmt:MT52A?, swiftmt:MT52B?,swiftmt:MT52C?, swiftmt:MT52D?] {
    if identifierCode is string && partyIdentifier is string{
        swiftmt:MT52A fieldMt52A = {
            name: "52A",
            PrtyIdn: {content: partyIdentifier, number: "2"},
            IdnCd: {content: identifierCode, number: "3"}
        };
        return [fieldMt52A,(), (), ()];
    }
    if identifierCode is string {
        swiftmt:MT52A fieldMt52A = {
            name: "52A",
            IdnCd: {content: identifierCode, number: "3"}
        };
        return [fieldMt52A, (), (), ()];
    }
    if (name is string || address is pacsIsoRecord:Max70Text[]) && partyIdentifier is string {
        swiftmt:MT52D fieldMt52D = {
            name: "52D",
            PrtyIdn: {content: partyIdentifier, number: "2"},
            AdrsLine: getAddressLine(address), 
            Nm: [{content: getMandatory(name), number: "3"}]
        };
        return [(), (), (), fieldMt52D];
    }
    if name is string || address is pacsIsoRecord:Max70Text[] {
        swiftmt:MT52D fieldMt52D = {
            name: "52D",
            AdrsLine: getAddressLine(address), 
            Nm: [{content: getMandatory(name), number: "3"}]
        };
        return [(), (), (), fieldMt52D];
    }
    if partyIdentifier is string && isField52CPresent{
        swiftmt:MT52C fieldMt52C = {
            name: "52C",
            PrtyIdn: {content: partyIdentifier, number: "1"}
        };
        return [(), (), fieldMt52C, ()];
    }
    if partyIdentifier is string {
        swiftmt:MT52B fieldMt52B = {
            name: "52B",
            PrtyIdn: {content: partyIdentifier, number: "2"}
        };
        return [(), fieldMt52B, (), ()];
    }
    return [(), (), (), ()];
}

isolated function getField50a(string? identifierCode, string? name, pacsIsoRecord:Max70Text[]? address, string? iban, string? bban, pacsIsoRecord:GenericPersonIdentification2[]? otherId, boolean isSecondType = false) returns [swiftmt:MT50A?, swiftmt:MT50G?, swiftmt:MT50K?, swiftmt:MT50H?, swiftmt:MT50F?] {
    if identifierCode is string {
        if isSecondType {
            swiftmt:MT50G fieldMt50G = {
                name: "50G",
                Acc: {content: getAccountId(iban, bban), number: "1"},
                IdnCd: {content: identifierCode, number: "2"}
            };
            return [(), fieldMt50G, (), (), ()];
        }
        swiftmt:MT50A fieldMt50A = {
            name: "50A",
            Acc: {content: getAccountId(iban, bban), number: "1"},
            IdnCd: {content: identifierCode, number: "2"}
        };
        return [fieldMt50A,(), (), (), ()];
    }
    if otherId is pacsIsoRecord:GenericPersonIdentification2[] && otherId[0].Id is string {
        swiftmt:MT50F fieldMt50F = {
            name: "50F",
            CdTyp: [], 
            PrtyIdn: {content: getMandatory(otherId[0].Id), number: "1"},
            Nm:[{content: getMandatory(name), number: "2"}],
            AdrsLine: getAddressLine(address)
        };
        return [(), (), (), (), fieldMt50F];
    }
    if (name is string || address is pacsIsoRecord:Max70Text[]) {
        if isSecondType {
            swiftmt:MT50H fieldMt50H = {
                name: "50H",
                Acc: {content: getAccountId(iban, bban), number: "1"},
                Nm: [{content: getMandatory(name), number: "2"}],
                AdrsLine: getAddressLine(address)
            };
            return [(), (), (), fieldMt50H, ()];
        }
        swiftmt:MT50K fieldMt50K = {
            name: "50K",
            Acc: {content: getAccountId(iban, bban), number: "1"},
            Nm: [{content: getMandatory(name), number: "2"}],
            AdrsLine: getAddressLine(address)
        };
        return [(),(), fieldMt50K, (), ()];
    }
    return [(), (), (), (), ()];
}

isolated function getField50Or50COr50L(string? identifierCode, string? name, pacsIsoRecord:Max70Text[]? address, pacsIsoRecord:GenericPersonIdentification2[]? otherId) returns [swiftmt:MT50?, swiftmt:MT50C?, swiftmt:MT50L?] {
    if identifierCode is string {
        swiftmt:MT50C fieldMt50C = {name: "50C", IdnCd: {content: identifierCode, number: "1"}};
        return [(), fieldMt50C, ()];
    }
    if otherId is pacsIsoRecord:GenericPersonIdentification2[] && otherId[0].Id is string {
        swiftmt:MT50L fieldMt50L = {name: "50L", PrtyIdn: {content: getMandatory(otherId[0].Id), number: "1"}};
        return [(), (), fieldMt50L];
    }
    if name is string || address is pacsIsoRecord:Max70Text[] {
        swiftmt:MT50 fieldMt50 = {
            name: "50",
            Nm: [{content: getMandatory(name), number: "1"}],
            AdrsLine: getAddressLine(address)
        };
        return [fieldMt50, (), ()];
    }
    return [(), (), ()];
}
