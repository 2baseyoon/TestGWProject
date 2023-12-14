function postRenderingForTemplate(){
	 postJobForDynamicCtrl();
}

function checkForm(bTempSave) {
    if (bTempSave) {
        return true;
    } else {
//            if (document.getElementById("SUBJECT")[0].value == '') {
//                alert('제목을 입력하세요.');
//                //SUBJECT.focus();
//                return false;
//            } else 
        if (document.getElementById("SaveTerm")[0].value == '') {
            alert('보존년한을 선택하세요.');
            return false;
        } else {
            document.getElementById("Subject")[0].value = document.getElementById("contractName")[0].value;// CFN_GetDicInfo(getInfo("usdn")) + " - " + getInfo("fmnm");
            return true;
        }
    }
}

/*function setBodyContext(sBodyContext) {
    //본문 채우기
    try {
        var m_objXML = $.parseXML("<?xml version='1.0' encoding='utf-8'?>" + sBodyContext);
        tblAllDelRow("tblAdd2", 1, 0);
        $(m_objXML).find("BODY_CONTEXT").children().each(function () {
            if (this.tagName == 'contractGubun_value') {
                if ($(this).text() == '법인') {
                    document.getElementById("contractGubun")[0].checked = true;
                    AddRow('', 'c');
                }
                else {
                    document.getElementById("contractGubun")[1].checked = true;
                    AddRow('', 'p');
                }
            }
            else if (this.tagName == "moneySelect_value") {
                if ($(this).text() == '세금계산서 발행 후 익월 말일') {
                    document.getElementById("moneySelect")[0].checked = true;
                }
                else if ($(this).text() == '용역 제공 후 익월 15일') {
                    document.getElementById("moneySelect")[1].checked = true;
                }
                else {
                    document.getElementById("moneySelect")[2].checked = true;
                }
            }
            else if (this.tagName == "idCard1") {
                idCardText = $(this).text();
            }
            else if (this.tagName == "idCard2") {
                idCardText2 = $(this).text();
            }
            else if (this.tagName == "tblAdd2") {
                // alert("1");
                var m_objXML2 = $(m_objXML).find(this.tagName).children().each(function () {
                    if (this.tagName == "ITEM") {
                        AddRow2(this);
                    }
                });
            }
            innerHtmlData(this.tagName, $(this).text());
        });
    }
    catch (e) { }
}*/

//본문 XML로 구성
function makeBodyContext() {
 /*   var sBodyContext = "";
    //totalCalc();
    sBodyContext = "<BODY_CONTEXT>" + nodeAdd() + getFields("mField") + getTableFields("tblAdd2", 1, "rField") + "</BODY_CONTEXT>";
    return sBodyContext;
    */
	var bodyContextObj = {};
	bodyContextObj["BodyContext"] = getFields("mField");
    $$(bodyContextObj["BodyContext"]).append(getMultiRowFields("tblAdd2", "rField"));
    return bodyContextObj;
}

/*function getTableFields(objName, firstIndex, Fields) {
    var sText = "";
    var oTable = document.getElementById(objName);
    if (Fields == null) Fields = "rField";
    sText += "<" + objName + ">";
    for (var i = firstIndex; i < oTable.rows.length; i++) {
        var oRow = oTable.rows[i];
        sText += "<ITEM>";
        var unFiltered = oRow.getElementsByTagName('*');
        for (var j = 0; j < unFiltered.length; j++) {
            if (unFiltered[j].getAttribute('id') == Fields) {
                sText += makeNode(unFiltered[j].getAttribute("name"), unFiltered[j].value);
            }
        }
        sText += "</ITEM>";
    }
    sText += "</" + objName + ">";
    return sText;
}*/

/*function nodeAdd() {
    var node, contractGubun_value, moneySelect_value;
    if (document.getElementById("contractGubun")[0].checked == true) {
        contractGubun_value = "법인";
    }
    else { contractGubun_value = "개인"; }

    if (document.getElementById("moneySelect")[0].checked == true) {
        moneySelect_value = "세금계산서 발행 후 익월 말일";
    }
    else if (document.getElementById("moneySelect")[1].checked == true) {
        moneySelect_value = "용역 제공 후 익월 15일";
    }
    else { moneySelect_value = ""; }

    node = "<contractGubun_value>" + contractGubun_value + "</contractGubun_value>";
    node += "<moneySelect_value>" + moneySelect_value + "</moneySelect_value>";

    return node;
}*/

/*function tblAllDelRow(objName, findex, lindex) {
    var tblObj = document.getElementById(objName);
    var i = findex;
    while (i < tblObj.rows.length - lindex) {
        tblObj.deleteRow(findex);
    }
}*/

var index = 1;
/*function AddRow(obj, gubun) {
    if (index > 1) {
        tblAllDelRow("tblAdd", 3, 1);
    }
    var tblObj = document.getElementById("tblAdd");
    var oRow = tblObj.insertRow(tblObj.rows.length - 1);
    var strHTML1, strHTML2;
    var oCell1 = oRow.insertCell(0);
    var oCell2 = oRow.insertCell(1);

    oCell1.style.backgroundColor = '#f6f6f6';
    oCell1.style.textAlign = 'center';
    oCell1.style.fontWeight = 'bold';

    if (gubun == 'c') {
        document.getElementById("btnline").style.display = "";
        if (document.getElementById("name")[0] != undefined) {
            document.getElementById("name")[0].value = "";
        }
        strHTML1 = '회사명';
        strHTML2 = '<input type="text" id="mField" name="contractCompany" style="width:99%;" />';
    }
    else if (gubun == 'p') {
        document.getElementById("btnline").style.display = "none";
        tblAllDelRow("tblAdd2", 2, 0);
        strHTML1 = '성명';
        strHTML2 = '<input type="text" id="mField" name="contractPerson" style="width:99%;" onblur="nameCopy(this.value)"/>';
    }

    oCell1.innerHTML = strHTML1;
    oCell2.innerHTML = strHTML2;

    var oRow = tblObj.insertRow(tblObj.rows.length - 1);
    var strHTML3, strHTML4;
    var oCell1 = oRow.insertCell(0);
    var oCell2 = oRow.insertCell(1);

    oCell1.style.backgroundColor = '#f6f6f6';
    oCell1.style.textAlign = 'center';
    oCell1.style.fontWeight = 'bold';

    if (gubun == 'c') {
        strHTML3 = '대표이사';
        strHTML4 = '<input type="text" id="mField" name="ceo" style="width:99%;" />';
    }
    else if (gubun == 'p') {
        strHTML3 = '주민등록번호';
        strHTML4 = '<input type="text" id="mField" name="idCard1" style="width:10%;" maxlength="6" onblur="checkInt2(this);" /> - <input type="text" id="mField" name="idCard2" style="width:10%;" maxlength="7" onblur="checkInt2(this);" />';
    }

    oCell1.innerHTML = strHTML3;
    oCell2.innerHTML = strHTML4;

    index++;
}*/

/*function nameCopy(str) {
    document.getElementById("name")[0].value = str;
}*/
/*function CR(strSrc) {
    return (strSrc.replace(/,/g, ""));
}
function checkInt(i) {
    var tmp = CR(i.value);
    if (isNaN(parseInt(tmp))) {
        if (i.value == "") {
        }
        else {
            //alert("숫자만 입력해 주세요!");
            i.focus();
            i.value = "";
        }
    }
    else {
        if (tmp != parseInt(tmp) && tmp.indexOf(".") == -1) {
            //alert("숫자만 입력해 주세요!");
            i.focus();
            i.value = "";
        }
        else {
            i.value = CnvtComma(tmp);
        }

    }
}

function checkInt2(i) {
    var tmp = CR(i.value);
    if (isNaN(parseInt(tmp))) {
        if (i.value == "") {
        }
        else {
            //alert("숫자만 입력해 주세요!");
            i.focus();
            i.value = "";
        }
    }
    else {
        if (tmp != parseInt(tmp) && tmp.indexOf(".") == -1) {
            //alert("숫자만 입력해 주세요!");
            i.focus();
            i.value = "";
        }
        else {
            i.value = tmp;
        }

    }
}*/

function checksubject(obj) {
    document.getElementsById("Subject")[0].value = obj.value;
}
/************************************************************************
함수명		: CnvtComma
작성목적	: 빠져나갈때 포맷주기(123456 => 123,456)
*************************************************************************/
function CnvtComma(num) {
    try {
        var ns = num.toString();
        var dp;

        if (isNaN(ns))
            return "";

        dp = ns.search(/\./);

        if (dp < 0) dp = ns.length;

        dp -= 3;

        while (dp > 0) {
            ns = ns.substr(0, dp) + "," + ns.substr(dp);
            dp -= 3;
        }
        return ns;
    }
    catch (ex) {
    	coviCmn.traceLog(ex);
    }
}

function mulTotal(num) {
    document.getElementById("total")[num].value = CnvtComma(CR(document.getElementById("mm")[num].value) * CR(document.getElementById("unitPrice")[num].value));
    var nCount = document.getElementById("total").length;
    var nAlltotal = 0;
    for (var i = 0; i < nCount; i++) {
        nAlltotal += Number(document.getElementById("total")[i].value);
    }
    //document.getElementById("totalAmount")[0].value = nAlltotal;
    
    totalCalc();
}
function totalCalc() {
    var totalMoney = 0;
    for (var k = 0; k < tblAdd2Index; k++) {
        totalMoney += parseFloat(CR(document.getElementById("total")[k].value));
    }
    document.getElementById("totalAmount")[0].value = CnvtComma(totalMoney);
}

var tblAdd2Index = 0;
/*function AddRow2(tbID) {
    var tableIndex = document.getElementById("tblAdd2");
    var oNewRow = tableIndex.insertRow(tableIndex.rows.length);
    var oNewCell1 = oNewRow.insertCell(0);
    var oNewCell2 = oNewRow.insertCell(1);
    var oNewCell3 = oNewRow.insertCell(2);
    var oNewCell4 = oNewRow.insertCell(3);
    var oNewCell5 = oNewRow.insertCell(4);

    //첫번째줄
    oNewCell1.innerHTML = "인력용역";

    oNewCell2.innerHTML = '<input type="text" id="rField" name="name" style="width:99%;"  value="' + $(tbID).find('name').text() + '" />';

    oNewCell3.innerHTML = '<input type="text" id="rField" name="unitPrice" style="width:99%;text-align:right;" onblur="checkInt(this);mulTotal(' + tblAdd2Index + ')" value="' + $(tbID).find('unitPrice').text() + '"/>';

    oNewCell4.innerHTML = '<input type="text" id="rField" name="mm" style="width:70%;text-align:right;" onblur="checkInt(this);mulTotal(' + tblAdd2Index + ')" value="' + $(tbID).find('mm').text() + '"/>&nbsp;M/M';

    oNewCell5.innerHTML = '<input type="text" id="rField" name="total" style="width:99%;text-align:right;" onblur="checkInt(this)" readonly="readonly" value="' + $(tbID).find('total').text() + '"/>';
    tblAdd2Index++;
}
function DelRow() {
    if (document.getElementById("tblAdd2").rows.length > 2) {
        document.getElementById("tblAdd2").deleteRow(document.getElementById("tblAdd2").rows.length - 1);
    }
    tblAdd2Index--;
}*/
