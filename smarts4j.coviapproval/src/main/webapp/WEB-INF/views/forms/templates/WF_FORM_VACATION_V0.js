function postRenderingForTemplate() {
	postJobForDynamicCtrl();
	
    document.getElementById("headname").innerHTML = initheadname(getInfo("FormInfo.FormName"), true);
    if (getInfo("Request.mode") == "DRAFT" || getInfo("Request.mode") == "TEMPSAVE") {
        document.getElementById("InitiatedDate")[0].value = getInfo("AppInfo.usnm"); //getInfo("dpdn_apv")+" "+getInfo("AppInfo.usnm") + " "+ getInfo("ustn") 
        ;
        document.getElementById("AppliedDate").value = formatDate(getInfo("AppInfo.svdt"), "D");
        if (document.getElementById("APPLICANT_UNIT_NAME")[0].value == "") {
            document.getElementById("APPLICANT_UNIT_NAME")[0].value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
            document.getElementById("APPLICANT_UNIT_CODE")[0].value = getInfo("AppInfo.dpid");
            document.getElementById("APPLICANT_POSITION_NAME")[0].value = m_oFormMenu.getLngLabel(getInfo("AppInfo.uspn"), false);
            document.getElementById("APPLICANT_POSITION_CODE")[0].value = getInfo("AppInfo.uspc");
            document.getElementById("APPLICANT_PERSON_NAME")[0].value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
            document.getElementById("APPLICANT_PERSON_CODE")[0].value = getInfo("AppInfo.usid");
            document.getElementById("spanAPPLICANT_UNIT_NAME").innerHTML = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
            document.getElementById("spanAPPLICANT_POSITION_NAME").innerHTML = m_oFormMenu.getLngLabel(getInfo("AppInfo.uspn"), false);
            document.getElementById("spanAPPLICANT_PERSON_NAME").innerHTML = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
        } else {
            document.getElementById("spanAPPLICANT_UNIT_NAME").innerHTML = m_oFormMenu.getLngLabel(document.getElementById("APPLICANT_UNIT_NAME")[0].value, false);
            document.getElementById("spanAPPLICANT_POSITION_NAME").innerHTML = m_oFormMenu.getLngLabel(document.getElementById("APPLICANT_POSITION_NAME")[0].value, false);
            document.getElementById("spanAPPLICANT_PERSON_NAME").innerHTML = m_oFormMenu.getLngLabel(document.getElementById("APPLICANT_PERSON_NAME")[0].value, false);
        }
    } else {
    	$("#Subject").attr("disabled","true");
    }
}
function setFormInfoDraft() {
    document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
    document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
}


function checkForm(bTempSave) {
    if (bTempSave) {
        return true;
    } else {
        if (document.getElementById("Subject")[0].value == '') {
            alert('제목을 입력하세요.');
            //SUBJECT.focus();
            return false;
        } else if (document.getElementById("SaveTerm")[0].value == '') {
            alert('보존년한을 선택하세요.');
            return false;
        } else if (document.getElementById("SEL_VACATION_CODE")[0].value == '') {
            alert('휴가종류를 선택하세요.');
            return false;
        } else if (document.getElementById("SDATE")[0].value == '') {
            alert('휴가기간 시작일을 선택하세요.');
            return false;
        } else if (document.getElementById("EDATE")[0].value == '') {
            alert('휴가기간 종료일을 선택하세요.');
            return false;
        } else if (document.getElementById("DAYS")[0].value == '') {
            alert('휴가일수를 입력하세요.');
            return false;
        } else if (document.getElementById("VACATION_TEXT")[0].value == '') {
            alert('휴가사유를 입력하세요.');
            return false;
        } else {
            return true;
        }
    }
}

function Dayout(args, conf) {
    var dt = $('input[name="SDATE"]').val();
    var dt2 = $('input[name="EDATE"]').val();

    if (dt == '') return;
    if (dt2 == '') return;

    var dts = dt.split("-");
    var sdt = new Date(dts[0], dts[1]-1, dts[2], 00, 00, 00);

    dts = dt2.split("-");
    var edt = new Date(dts[0], dts[1]-1, dts[2], 00, 00, 00);

    var rtn = (edt - sdt) / 3600 / 1000 / 24;

    if (rtn < 0) {
        alert("휴가기간 종료일이 시작일 이전일 수 없습니다.");
        $('input[name="EDATE"]').val("");
        $('input[name="DAYS"]').val("");
    }
    else {
        $('input[name="DAYS"]').val(rtn + 1);
    }
    
}

function setBodyContext(sBodyContext) {
/*    //본문 채우기
    try {
        var m_objXML = $.parseXML("<?xml version='1.0' encoding='utf-8'?>" + sBodyContext);
        $(m_objXML).find("BodyContext").children().each(function () {
            innerHtmlData(this.tagName, $(this).text());
        });
    }
    catch (e) { }*/
}

//본문 XML로 구성
function makeBodyContext() {
    var bodyContextObj = {};
	bodyContextObj["BodyContext"] = getFields("mField");
    return bodyContextObj;
}