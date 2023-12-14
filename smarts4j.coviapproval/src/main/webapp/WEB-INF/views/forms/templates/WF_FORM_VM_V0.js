//양식별 다국어 정의 부분
var localLang_ko = {
    localLangItems: {
    }
};

var localLang_en = {
    localLangItems: {
    }
};

var localLang_ja = {
    localLangItems: {
    }
};

var localLang_zh = {
    localLangItems: {
    }
};


//양식별 후처리를 위한 필수 함수 - 삭제 시 오류 발생
function postRenderingForTemplate() {
    // 체크박스, radio 등 공통 후처리
    postJobForDynamicCtrl();
    getOSSelect('OPERATING_SYSTEM', 'FormOS');
    getOSSelect('OS_NAME', 'FormOS');
    getOSSelect('HOST_COMPUTER', 'FormHOST');

    //기안부서 결재 완료시 테이블 보여주기
    var vApvlist = $.parseJSON($("#APVLIST").val());
    var vStepLen = $$(vApvlist).find("division").concat().eq(0).find("step").valLength();
    $$(vApvlist).find("division").concat().eq(0).find("step").concat().each(function (i, element) {
        if ((vStepLen - 1) == i) {
         if($$(element).find("ou > person > taskinfo").attr("status") == "completed"){
             $("#SubTable2").css("display", "");
           }
        }
    });
   

    //읽기 모드 일 경우
    if (getInfo("Request.templatemode") == "Read") {

        $("#btn").css("display", "noen");

        $('*[data-mode="writeOnly"]').each(function () {
            $(this).hide();
        });


        if (JSON.stringify(formJson.BodyData)!="{}" && formJson.BodyData.SubTable1 != undefined && formJson.BodyData.SubTable1 !='') {
            XFORM.multirow.load(JSON.stringify(removeSeperatorForMultiRow(formJson.BodyData.SubTable1)), 'json', '#SubTable1', 'R');
        } else {
            XFORM.multirow.load('', 'json', '#SubTable1', 'R');
        }
        if (JSON.stringify(formJson.BodyData)!="{}" && formJson.BodyData.SubTable2 != undefined && formJson.BodyData.SubTable2 !='') {
            XFORM.multirow.load(JSON.stringify(removeSeperatorForMultiRow(formJson.BodyData.SubTable2)), 'json', '#SubTable2', 'R');
        } else {
            XFORM.multirow.load('', 'json', '#SubTable2', 'R');
        }


        //결재선의 수신자 가져오기
        var ScPerson = '';
        if (getInfo("SchemaContext.scPRec.isUse") == "Y") {
            if (getInfo("SchemaContext.scPRec.value") != "") {
                var aScPRecV = getInfo("SchemaContext.scPRec.value").split("@@");
                var sChgrPersonXml = "";
                if (aScPRecV.length > 2) {
                    $("#IS_CHARGE_PERSON").val(m_oFormMenu.getLngLabel(aScPRecV[1], false));
                    ScPerson = m_oFormMenu.getLngLabel(aScPRecV[1], false);
                }
            }
        }

        if (ScPerson == m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false) && getInfo("Request.loct") == "APPROVAL") {
            $("#btModify").css("display", "");
        }


        if (formJson.Request.loct == "COMPLETE") { //완료함
            $("#FINISH_DAY").val(getInfo("COMPLETED_DATE"));   //결재완료일자
        }



    }
    else {
        $('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });

        // 에디터 처리
        $("#btn").css("display", "");


        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {
        	document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
            
            $("#REQ_DAY").val(getInfo("AppInfo.svdt").split(" ")[0]); //신청일자

            $("#REQ_PERSON").val(m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false));   //신청자

            $("#REQ_TEAM").val(m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false));       //신청자 팀

            $("#SubTable1").find("input[name=DISK]").val(120); //디스크 C 기본 값 입력

            $("input[name='USE_TERM_S']").val(getInfo("AppInfo.svdt").split(" ")[0]);    //사용기간 시작 값 기본 입력

            //기안자 내용 입력 불가능
            //$("#SubTable2").css("display", "none"); //.css("display", "none"); //.attr("disabled", "true");

            // 팀 Manager 가져오기
            getPersonInfo();
        }

        if (formJson.Request.mode == "DRAFT") {
            if ($("#REQ_REASON").val() == "" || $("#REQ_REASON").val() == "VM의 사용용도를 상세하게 기재하여 주십시오.")
                $("#REQ_REASON").val("VM의 사용용도를 상세하게 기재하여 주십시오.");
        }

        //        if (formJson.oFormData.mode == "REDRAFT") {
        //             //결재자 내용 입력 불가능
        //            $("#SubTable1").attr("disabled", "true");
        //       }


        if (JSON.stringify(formJson.BodyData)!="{}" && formJson.BodyData.SubTable1 != undefined && formJson.BodyData.SubTable1 !='') {
            XFORM.multirow.load(JSON.stringify(removeSeperatorForMultiRow(formJson.BodyData.SubTable1)), 'json', '#SubTable1', 'W');
        } else {
            XFORM.multirow.load('', 'json', '#SubTable1', 'W', { minLength: 1, enableSubMultirow: true });
        }
        if (JSON.stringify(formJson.BodyData)!="{}" && formJson.BodyData.SubTable2 != undefined && formJson.BodyData.SubTable2 !='') {
            XFORM.multirow.load(JSON.stringify(removeSeperatorForMultiRow(formJson.BodyData.SubTable2)), 'json', '#SubTable2', 'W');
        } else {
            XFORM.multirow.load('', 'json', '#SubTable2', 'W', { minLength: 1, enableSubMultirow: true });
        }
    }
}

function setLabel() {
}

function setFormInfoDraft() {
}

function checkForm(bTempSave) {
    if (bTempSave) {
        return true;
    } else {
        // 필수 입력 필드 체크
    //getInfo("apvst");

        var tbl = $('#SubTable2').find('tr.multi-row').find("td");
         var aScPRecV = getInfo("SchemaContext.scPRec.value").split("@@");

         if (getInfo("AppInfo.usnm").split(";")[0] == m_oFormMenu.getLngLabel(aScPRecV[1], false)) {
             if ((getInfo("Request.editmode") == 'Y') && ($(tbl).find("input[name=VM_NAME]").val() == ""
            || $(tbl).find("select[name=HOST_COMPUTER]").val() == ""
            || $(tbl).find("input[name=CORE]").val() == ""
            || $(tbl).find("input[name=Memory]").val() == ""
            || $(tbl).find("input[name=IP_ADDRESS]").val() == ""
            || $(tbl).find("select[name=OPERATING_SYSTEM]").val() == ""
            || $(tbl).find("input[name=COMPUTER_NAME]").val() == "")) {
                 alert("값 입력 후 승인 하시기 바랍니다.");
                 return false;
             }
             else if (
            (getInfo("Request.editmode") != 'Y') &&
             ($(tbl).find("span[name=VM_NAME]").text() == "" ||
              $(tbl).find("span[name=HOST_COMPUTER]").text() == "" ||
               $(tbl).find("span[name=CORE]").text() == "" ||
                $(tbl).find("span[name=Memory]").text() == "" ||
                 $(tbl).find("span[name=IP_ADDRESS]").text() == "" ||
                 $(tbl).find("span[name=OPERATING_SYSTEM]").text() == "" ||
                  $(tbl).find("span[name=COMPUTER_NAME]").text() == "")) {
                 alert("값 입력 후 승인 하시기 바랍니다.");
                 return false;
             }
             else {
                 return true;
             }
         }

         else {
             return EASY.check().result;
         }
    }
}

function setBodyContext(sBodyContext) {
}

//본문 XML로 구성
function makeBodyContext() {
	/*var sBodyContext = "";
    sBodyContext = "<BODY_CONTEXT>" + getFields("mField") + "</BODY_CONTEXT>";*/
	
    var bodyContextObj = {};
	
	bodyContextObj["BodyContext"] = getFields("mField");
    return bodyContextObj;
}

function test(obj) {
    var tblobj = document.getElementById("SubTable2");
    var Arr = new Array();
    var i;
    var check = false;
    var vFindInput = obj.name;
    var vName;
    for (i = 3; i <= tblobj.rows.length - 1; i++) {
        if ($(tblobj.rows[i]).find("input[name=" + vFindInput + "]").val() != "") {
            Arr.push($(tblobj.rows[i]).find("input[name=" + vFindInput + "]").val() + "," + vFindInput);
        }
    }

    for (var j = 0; j <= Arr.length - 1; j++) {
        if (check) { break; }
        for (var y = 0; y <= Arr.length - 1; y++) {
            if (y != j) {
                if (Arr[j] == Arr[y]) {
                    switch (Arr[j].toString().split(",")[1]) {
                        case "VM_NAME":
                            vName = "VM NAME";
                            break;
                        case "COMPUTER_NAME":
                            vName = "COMPUTER NAME";
                            break;
                        case "IP_ADDRESS":
                            vName = "IP Address";
                            break;
                    }
                    // alert((j + 1) + "번째 행 과 " + (y + 1) + "번째 행에 중복된 값이 있습니다.");
                    alert(vName + "항목의 값이 중복 되었습니다.");
                    check = true;
                    break;
                }
            }
        }

    }
}

function getPersonInfo() {

    /*var connectionname = "ORG_ConnectionString";
    var pXML = "dbo.usp_getIsManager_Info";
    var aXML = "<param><name>dept_code</name><type>varchar</type><length>10</length><value><![CDATA[" + getInfo("AppInfo.dpid_apv") + "]]></value></param>";
    var sXML = "<Items><connectionname>" + connectionname + "</connectionname><xslpath></xslpath><sql><![CDATA[" + pXML + "]]></sql><type>sp</type>" + aXML + "</Items>";
    var szURL = "../GetXMLQuery.aspx";
    var sealPath = "";
    CFN_CallAjax(szURL, sXML, function (data) {
        var xmlReturn = data;
        var errorNode = $(xmlReturn).find("error");
        if (errorNode.length > 0) {
            Common.Error("Desc: " + $(errorNode).text());
        } else {
            var strMANAGERNAME = $(xmlReturn).find("Table").find("PERSON_CODE").text();
            if (strMANAGERNAME != "") {
                $("#REQ_LEADER").val(m_oFormMenu.getLngLabel($(xmlReturn).find("Table").find("DISPLAY_NAME").text(), false));
            }

        }
    }, false, "xml");*/
	
	/*CFN_CallAjax("/approval/legacy/getIsManagerData.do", {"dept_code":getInfo("AppInfo.dpid_apv")}, function (data){ 
		  var xmlReturn = data;
	      var errorNode = data.error;
	        if (errorNode != null && errorNode != undefined) {
	            Common.Error("Desc: " + errorNode);
	        } else {
	            var strMANAGERNAME = xmlReturn.Table[0].UR_Code;
	            if (strMANAGERNAME != "") {
	                $("#REQ_LEADER").val(m_oFormMenu.getLngLabel(xmlReturn.Table[0].UR_Name, false));
	            }

	        }
	},false,'json');*/
	
	$("#REQ_LEADER").val(getInfo("AppInfo.managername")); //getIsManagerData.do 대체
	
    //양식 결재선에 수신처.
    if (getInfo("SchemaContext.scPRec.isUse") == "Y") {
        if (getInfo("SchemaContext.scPRec.value") != "") {
            var aScPRecV = getInfo("SchemaContext.scPRec.value").split("@@");
            var sChgrPersonXml = "";
            if (aScPRecV.length > 2) {
                $("#IS_CHARGE_PERSON").val(m_oFormMenu.getLngLabel(aScPRecV[1], false));
            }
        }
    }
}


/* 날짜 계산 - VM 신청서에 날짜 계산 추가 [2017.04.04] yjlee*/
function calSDATEEDATE(obj) {
    // 현재 객채(input) 에서 제일 가까이 있는 tr을 찾음
    var tmpObj = $(obj).closest("tr");

    if ($(tmpObj).find("input[name=USE_TERM_S]").val() != "" && $(tmpObj).find("input[name=USE_TERM_E]").val() != "") {
        var SDATE = $(tmpObj).find("input[name=USE_TERM_S]").val().split('-');
        var EDATE = $(tmpObj).find("input[name=USE_TERM_E]").val().split('-');

        var SOBJDATE = new Date(parseInt(SDATE[0], 10), parseInt(SDATE[1], 10) - 1, parseInt(SDATE[2], 10));
        var EOBJDATE = new Date(parseInt(EDATE[0], 10), parseInt(EDATE[1], 10) - 1, parseInt(EDATE[2], 10));
        var tmpday = EOBJDATE - SOBJDATE;
        tmpday = parseInt(tmpday, 10) / (1000 * 3600 * 24);
        tmpday += 1;
        if (tmpday < 0) {
            alert("이전 일보다 전 입니다. 확인하여 주십시오.");
            $(tmpObj).find("input[name=USE_TERM_E]").val("");
        } 
    }
}
