//양식별 다국어 정의 부분
var localLang_ko = {
    localLangItems : {
        selMessage: "●휴일이 포함된 연차를 사용할 경우 [추가]버튼을 이용하여 개별 입력하시기 바랍니다.",
        allVacDays: "총연차"

    }
};

var localLang_en = {
    localLangItems : {
        selMessage: "●vacation이 포함된 연차를 사용할 경우 [추가]버튼을 이용하여 개별 입력하시기 바랍니다.",
        allVacDays: "총연차"

    }
};

var localLang_ja = {
    localLangItems : {
        selMessage: "●休日이 포함된 연차를 사용할 경우 [추가]버튼을 이용하여 개별 입력하시기 바랍니다.",
        allVacDays: "총연차"

    }
};

var localLang_zh = {
    localLangItems: {
        selMessage: "●休日이 포함된 연차를 사용할 경우 [추가]버튼을 이용하여 개별 입력하시기 바랍니다.",
        allVacDays: "총연차"

    }
};

//양식별 후처리를 위한 필수 함수 - 삭제 시 오류 발생
function postRenderingForTemplate() {
    // 체크박스, radio 등 공통 후처리
    postJobForDynamicCtrl();

    //제목
    document.getElementById("headname").innerHTML = initheadname(formJson.FormInfo.FormName, true);

    //Subject 숨김처리
    $('#tblFormSubject').hide();

    //읽기 모드 일 경우
    if (getInfo("Request.templatemode") == "Read") {

        $('*[data-mode="writeOnly"]').each(function () {
            $(this).hide();
        });

        //년도 선택 select 뒤
        if (typeof formJson.BodyContext != 'undefined' && JSON.stringify(formJson.BodyContext) != "{}") {
            $('#spanSelYear').html('&nbsp;년');
        }
        else {
            $('#spanSelYear').html('&nbsp;&nbsp;&nbsp;');
        }

        // table 개선 작업으로 임시 주석 처리
        //table
        if (typeof formJson.BodyContext != 'undefined' && JSON.stringify(formJson.BodyContext) != "{}") {
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.tblVacInfo), 'json', '#tblVacInfo', 'R');
        }
        
        //특정 디자인 수정
        $('#VAC_REASON').removeAttr('style');

    }
    else {
        //debugger;

        $('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });

        //쓰기일 경우 후처리로 아래와 같이 값 변경
        //비상연락은 DB사용자 정보에서 가져오기
        //JAVA 버전에서는 세션에 사용자 번호가 들어오면 세션값으로 대체 
        //var phonNum = Common.GetObjectInfo('UR', formJson.oFormData.usid, 'AD_Mobile').Table[0].AD_Mobile;
        //document.getElementById("NUMBER").value = phonNum;
        
        //년도 선택 select 뒤
        $('#spanSelYear').html('&nbsp;&nbsp;&nbsp;');

        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {
            document.getElementById("InitiatedDate").value = formJson.AppInfo.svdts; // 재사용, 임시함에서 오늘날짜로 들어가게함.
            document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(formJson.AppInfo.dpnm, false);
            document.getElementById("InitiatorCodeDisplay").value = m_oFormMenu.getLngLabel(formJson.AppInfo.usid, false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(formJson.AppInfo.usnm, false);

            if (formJson.Request.mode == "DRAFT" && formJson.Request.gloct == "") {
                //JSON DATA
                var json_multi_data = '[{"_MULTI_VACATION_SDT":"","_MULTI_VACATION_EDT":"","_MULTI_DAYS":""}]';
                XFORM.multirow.load(json_multi_data, 'json', '#tblVacInfo', 'W');
                //기간에 대한 validation 처리 추가
                validateVacDate();
                getData();
            }
            else {
                
                if (typeof formJson.BodyContext != 'undefined' && JSON.stringify(formJson.BodyContext) != "{}") {
                    XFORM.multirow.load(JSON.stringify(formJson.BodyContext.tblVacInfo), 'json', '#tblVacInfo', 'W');
                    getData();
                }
            }
            
        }
        else {

            if (typeof formJson.BodyContext != 'undefined' && JSON.stringify(formJson.BodyContext) != "{}") {
                XFORM.multirow.load(JSON.stringify(formJson.BodyContext.tblVacInfo), 'json', '#tblVacInfo', 'W');
                getData();
            }
        }

    }

}

function setLabel() {

}

function setFormInfoDraft() {

}

function checkForm(bTempSave) {
    if (document.getElementById("Subject").value == "") {
    	document.getElementById("Subject").value = CFN_GetDicInfo(getInfo("AppInfo.usnm")) + " - " + getInfo("FormInfo.FormName");
    }

    if (bTempSave) {
        return true;
    } else {
        //잔여 휴가일 체크 임시 주석 처리
        //테스트 후 살릴 것
        if ((document.getElementById("USE_DAYS").value == "" || document.getElementById("USE_DAYS").value <= 0)
            && (document.getElementById("VACATION_TYPE").value == "반차" || document.getElementById("VACATION_TYPE").value == "연차")) {
            Common.Warning(Common.getDic("msg_apv_chk_vacation")); //잔여휴가일이 없습니다. 기안할 수 없습니다.
            return false;
        } else if ((parseFloat(document.getElementById("USE_DAYS").value) < parseFloat(document.getElementById("_MULTI_TOTAL_DAYS").value))
            && (document.getElementById("VACATION_TYPE").value != "경조" && document.getElementById("VACATION_TYPE").value != "기타")) {
            Common.Warning(Common.getDic("msg_apv_chk_remain_vacation")); //잔여 연차일을 초과하였습니다.
            return false;
        } else if (document.getElementById("DocClassName").value == '') {
            Common.Warning("문서분류를 입력하세요."); //제목을 입력하세요.
            //SUBJECT.focus();
            return false;
        } else if (document.getElementById("SaveTerm").value == '') {
            Common.Warning(Common.getDic("lbl_apv_InputRetention")); //보존년한을 선택하세요.
            return false;
        } else if (document.getElementById("VAC_REASON").value == '') {
            //Common.Warning(Common.GetDic("msg_apv_chk_reason")); //사유를 입력해주세요.
            //return false;
        } else if (document.getElementById("NUMBER").value == '') {
            Common.Warning(Common.getDic("msg_apv_chk_emergency_contact")); //비상연락처를 입력해주세요.
            return false;
        } else if (document.getElementById("DEPUTY_NAME").value == '') {
            //Common.Warning(Common.GetDic("msg_apv_chk_job_agent")); //직무대행자를 입력해주세요.
            //return false;
        }
        else {
            return EASY.check().result;
        }
        /*else if (sameYear()) {  //선택한 년도와 달력의 년도가 다른 경우
            //Common.Warning(Common.GetDic("msg_apv_chk_job_agent")); //직무대행자를 입력해주세요.
            Common.Warning("연차년도와 동일 년도의 날짜로 선택하시기 바랍니다. ");
            //totalDays();
            return false;

        } else {
            for (var i = 1; i < document.getElementsByName("_MULTI_VACATION_SDT").length; i++) {
                if (document.getElementById("VACATION_TYPE").value != "반차" && document.getElementById("VACATION_TYPE").value != "선반차") {
                    if (document.getElementsByName("_MULTI_VACATION_SDT")[i].value == "" || document.getElementsByName("_MULTI_VACATION_EDT")[i].value == "") {
                        Common.Warning(Common.GetDic("msg_apv_chk_vacation_time")); //휴가기간을 선택해주세요.
                        return false;
                    }
                }
                else {
                    if (document.getElementsByName("_MULTI_VACATION_SDT")[i].value == "") {
                        Common.Warning(Common.GetDic("msg_apv_chk_vacation_time")); //휴가기간을 선택해주세요.
                        return false;
                    }
                    else if (document.getElementById("VACATION_TYPE").value == "반차" || document.getElementById("VACATION_TYPE")[0].value == "선반차") {
                        document.getElementsByName("_MULTI_VACATION_EDT")[0].value = document.getElementsByName("_MULTI_VACATION_SDT")[0].value;
                    }
                }
            }

            return true;
        }
        */

    }
}

//기간에 대한 validation 처리 추가
function validateVacDate() {

    $('#tblVacInfo .multi-row').on('change', '[name=_MULTI_VACATION_EDT]', function () {
        var sdt = $(this).prev().prev().val().replace(/-/g, '');
        var edt = $(this).val().replace(/-/g, '');

        if (Number(sdt) > Number(edt)) {
            Common.Warning("시작일은 종료일보다 먼저 일 수 없습니다.");
            $(this).val('');
        }

        var selectedYear = document.getElementById("Sel_Year").value;
        var clickedYear = $(this).val().split('-')[0];

        if (selectedYear != clickedYear && clickedYear != '') {
            Common.Warning("연차년도와 동일 년도의 날짜로 선택하시기 바랍니다. ");
            $(this).val('');
        }

    });

    $('#tblVacInfo .multi-row').on('change', '[name=_MULTI_VACATION_SDT]', function () {
        var selectedYear = document.getElementById("Sel_Year").value;
        var clickedYear = $(this).val().split('-')[0];

        if (selectedYear != clickedYear && clickedYear != '') {
            Common.Warning("연차년도와 동일 년도의 날짜로 선택하시기 바랍니다. ");
            $(this).val('');
        }

    });

}

//휴가 정보 초기화
function initVacInfoTable() {
    var oHtml = '';
    //multirow 삭제
    $('#tblVacInfo .multi-row').remove();

    if (document.getElementById("VACATION_TYPE").value == "반차" || document.getElementById("VACATION_TYPE").value == "선반차")  {
        oHtml += '<tr class="multi-row halfvac">';
        oHtml += '<td>';
        oHtml += '<input type="text" name="_MULTI_VACATION_SDT" data-type="rField" readonly="" data-pattern="date" required/>';
        oHtml += '<span>&nbsp;~&nbsp;</span>';
        oHtml += '<input type="text" name="_MULTI_VACATION_EDT" data-type="rField" readonly="readonly" required/>&nbsp;';
        oHtml += '<input type="text" name="_MULTI_DAYS" data-type="rField" value="0.5" style="border:0px solid;width:20px;"/>';
        oHtml += '</td>';
        oHtml += '</tr>';

        $('#tblVacInfo').append(oHtml);
        //반차일 경우 초기일 종료일에 복사
        $('#tblVacInfo .halfvac').on('change', '[name=_MULTI_VACATION_SDT]', function () {
            $(this).next().next().val( $(this).val() );
        });
        
        $('#tblVacInfo .multi-row-add').hide();
        $('#tblVacInfo .multi-row-del').hide();
        getData();
    }
    else {
        $('#tblVacInfo .multi-row-add').show();
        $('#tblVacInfo .multi-row-del').show();
        var json_multi_data = '[{"_MULTI_VACATION_SDT":"","_MULTI_VACATION_EDT":"","_MULTI_DAYS":""}]';
        XFORM.multirow.load(json_multi_data, 'json', '#tblVacInfo', 'W');
        validateVacDate();
        getData();
    }
}

var selectboxYear;
function getData() {

   /*
    *  미사용 양식이므로 기안 및 재사용시 필요한 데이터 조회는 생략
    *  if (document.getElementById("VACATION_TYPE").value == "연차" || document.getElementById("VACATION_TYPE").value == "반차") {
        var pXML = "usp_mcd_vacation_plan_apvForm_select";
        var aXML = "<param><name>UR_CODE</name><type>nvarchar</type><length>50</length><value><![CDATA[" + getInfo("usid") + "]]></value></param>";
        if (document.getElementById("VACATION_TYPE").value == "선연차" || document.getElementById("VACATION_TYPE").value == "선반차") {
            aXML += "<param><name>year</name><type>varchar</type><length>4</length><value><![CDATA[" + parseInt(document.getElementById("Sel_Year").value) + 1 + "]]></value></param>";
        }
        else {
            aXML += "<param><name>year</name><type>varchar</type><length>4</length><value><![CDATA[" + document.getElementById("Sel_Year").value + "]]></value></param>";
        }
        var connectionname = "COVI_FLOW_SI_ConnectionString";
        var sXML = "<Items><connectionname>" + connectionname + "</connectionname><xslpath></xslpath><sql><![CDATA[" + pXML + "]]></sql><type>sp</type>" + aXML + "</Items>";
        var szURL = "../getXMLQuery.aspx";

        CFN_CallAjax(szURL, sXML, function (data) {
            receiveHTTPGetData(data);
        }, false, "xml");
    }
    else {
        document.getElementById("VAC_DAYS").value = "";
        document.getElementById("USE_DAYS").value = "";
    }*/
}

function receiveHTTPGetData(responseXMLdata) {
   /* var xmlReturn = responseXMLdata;
    var elmlist = $(xmlReturn).find("response > NewDataSet > Table");
    var vacday = "", atot = "", appday = "";

    $(elmlist).each(function () {
        vacday = $(this).find("VACDAY").text();
        atot = $(this).find("ATot").text();
        if (atot == "") atot = "0.0";
    });
    if (vacday == "") {
        Common.Warning("해당 년도의 연차 사용 가능 일수가 등록되지 않았습니다. 관리자에게 문의하세요."); //잔여휴가일이 없습니다. 기안할 수 없습니다.
        $("[id=VAC_DAYS]").val("0");
        $("[id=USE_DAYS]").val("0");

    } else if (parseFloat(vacday - atot) <= 0) {
        Common.Warning(Common.GetDic("msg_apv_chk_vacation"));
        $("[id=VAC_DAYS]").val(parseFloat(vacday) + "일 (사용 연차 : " + parseFloat(atot) + ")");
        $("[id=USE_DAYS]").val(parseFloat(vacday) - parseFloat(atot));
    }
    else {
        $("[id=VAC_DAYS]").val(parseFloat(vacday) + "일 (사용 연차 : " + parseFloat(atot) + ")");
        $("[id=USE_DAYS]").val(parseFloat(vacday) - parseFloat(atot));
    }*/
}

var objTxtSelect;
function OpenWinEmployee(szObject) {	
	objTxtSelect = document.getElementById(szObject);
    
    /* 
    var sType = "B1";
    var sGroup = "N";
    var sTarget = "Y";
    var sCompany = "Y";
    var sSearchType = "";
    var sSearchText = "";
    var sSubSystem = "";
    XFN_OrgMapShow_WindowOpen("REQUEST_TEAM_LEADER", "bodytable_content", objTxtSelect.id, openID, "Requester_CallBack", sType, sGroup, sCompany, sTarget, sSubSystem, sSearchType, sSearchText);
	*/
   
	CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=Requester_CallBack&type=B1","조직도",1000,580,"");

}

function Requester_CallBack(pStrItemInfo) {
	   var oJsonOrgMap = $.parseJSON(pStrItemInfo);
	   var I_User = oJsonOrgMap.item[0];
		
	   if(I_User != undefined){
	    if (getInfo("AppInfo.usid") != I_User.AN) {
	        objTxtSelect.value = CFN_GetDicInfo(I_User.DN);
	        document.getElementById("DEPUTY_CODE").value = I_User.EmpNo;
	    }
	    else {
	        alert('직무대행자로 본인이 선택되었습니다.\r\n다시 선택하세요');
	        //OpenWinEmployee();
	    }
	   }
	   /*
	   	var oXmlOrgMap = $.parseXML("<?xml version='1.0' encoding='utf-8'?>" + pStrItemInfo);
	    var l_User = $(oXmlOrgMap).find('ItemInfo[type=User]').eq(0);

	    if (getInfo("usid") != $(l_User).find("UR_Code").eq(0).text()) {
	        objTxtSelect.value = CFN_GetDicInfo($(l_User).find('ExDisplayName').eq(0).text());
	        document.getElementById("DEPUTY_CODE").value = $(l_User).find("EmpNo").eq(0).text();
	    }
	    else {
	        alert('직무대행자로 본인이 선택되었습니다.\r\n다시 선택하세요');
	        OpenWinEmployee('DEPUTY_NAME');
	    }
	    */
	}

function setBodyContext(sBodyContext) {
    
}

//본문 XML로 구성
function makeBodyContext() {
   /* var sBodyContext = "";
    sBodyContext = "<BODY_CONTEXT>" + getFields("mField") + getMultiRowFields("tblVacInfo", "rField") + "</BODY_CONTEXT>";
    return sBodyContext;*/
    
	var bodyContextObj = {};
	bodyContextObj["BodyContext"] = getFields("mField");
    $$(bodyContextObj["BodyContext"]).append(getMultiRowFields("tblVacInfo", "rField"));
    return bodyContextObj;
}