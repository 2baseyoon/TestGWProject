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

    //읽기 모드 일 경우
    if (getInfo("Request.templatemode") == "Read") {

        $('*[data-mode="writeOnly"]').each(function () {
            $(this).hide();
        });

        if (getInfo("Request.mode") == "COMPLETE" && typeof formJson.BodyContext.PM_Code == 'undefined') {
            $("#btReUse").css("display", "none");
            alert("PM코드가 없으므로 재사용이 불가합니다.");
        }

        if (JSON.stringify(formJson.BodyContext) != "{}" && typeof formJson.BodyContext != 'undefined') {
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.TB), 'json', '#TB', 'R');
        } else {
            XFORM.multirow.load('', 'json', '#TB', 'R');
        }

        /////PM
        if (JSON.stringify(formJson.BodyContext) != "{}" && typeof formJson.BodyContext != 'undefined') {

            if (formJson.BodyContext.Total_Master != undefined) {
                $("#Total_Master_Span").text(formJson.BodyContext.Total_Master);
            }
            if (formJson.BodyContext.PM != undefined) {
                $("#Total_Sub_Span").text(formJson.BodyContext.PM);
            }
        }
        ////영업대표
        if (JSON.stringify(formJson.BodyContext) != "{}" && typeof formJson.BodyContext != 'undefined') {
            if (formJson.BodyContext.Total_Master != undefined) {
                $("#Total_Master_Span").text(formJson.BodyContext.Total_Master);
            }
            if (formJson.BodyContext.CEO != undefined) {
                $("#Total_Sub_Span2").text(formJson.BodyContext.CEO);
            }
        }
        ////ADD
        if (JSON.stringify(formJson.BodyContext) != "{}" && typeof formJson.BodyContext != 'undefined') {
            if (formJson.BodyContext.Total_Master != undefined) {
                $("#Total_Master_Span").text(formJson.BodyContext.Total_Master);
            }
            if (formJson.BodyContext.ADD != undefined) {
                $("#Total_Sub_Span3").text(formJson.BodyContext.ADD);
            }
        }
        
        if($("#pStrJobtype").val() != ""){
        	var strDesc = "";
        	
        	switch ($("#pStrJobtype").val()) {
			case "P":
				strDesc = "(프로젝트)"
				break;
			case "G":
				strDesc = "(회사일반)"
				break;
			case "R":
				strDesc = "(R&amp;D)"
				break;
			case "S":
				strDesc = "(Sales)"
				break;
			case "C":
				strDesc = "(유지보수)"
				break;
			/*case "M":
				strDesc = "(SE 제품관리)"
					break;*/
			default:
				break;
			}
        	$("#SubjectTypeDesc").html(strDesc);
        }
        

    }
    else {
        $('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });

        if (JSON.stringify(formJson.BodyContext) != "{}" && typeof formJson.BodyContext != 'undefined') {
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.TB), 'json', '#TB', 'W', { minLength: 1 });
        } else {
            XFORM.multirow.load('', 'json', '#TB', 'W', { minLength: 0 });
        }

        if (formJson.Request.mode == "DRAFT") {
            $("#Subject").val(m_oFormMenu.getLngLabel(getInfo("FormInfo.FormName"), false));
            document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
            document.getElementById("InitiatorCodeDisplay").value = m_oFormMenu.getLngLabel(formJson.AppInfo.usid, false);

            // [16-07-14] kimhs, 위치 이동
            //PROJECTNO();            // PROJECT No 넘버링
            setJobType(); // 프로젝트 코드 타입 세팅

            document.getElementById("InitiatedDate").value = formJson.AppInfo.svdt; // 재사용, 임시함에서 오늘날짜로 들어가게함.
            $("#Total_Master_Span").text(document.getElementById("InitiatorDisplay").value + "(" + getInfo("AppInfo.sabun") + ")");
            $("#Total_Master").val(document.getElementById("InitiatorDisplay").value + "(" + getInfo("AppInfo.sabun") + ")");
        }

        if (formJson.Request.mode == "REDRAFT") {
            $("#PROPOSALNO").attr("disabled", false);
        }

        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {

            // 임시저장 또는 재사용 시 저장하였던 프로젝트명 가져오기
            //if (formJson.oFormData.mode == "TEMPSAVE" || getInfo("reuse") == "Y" || getInfo("reuse") == "P" || getInfo("reuse") == "YH") {
            //    if (formJson.BODY_CONTEXT.PROJECT_NAME != undefined) {
            //        $("#PROJECT_NAME").val(formJson.BODY_CONTEXT.PROJECT_NAME);
            //    }
            //}
        }


        //////PM
        if (JSON.stringify(formJson.BodyContext) != "{}" && typeof formJson.BodyContext != 'undefined') {

            if (formJson.BodyContext.Total_Master != undefined) {
                $("#Total_Master_Span").text(formJson.BodyContext.Total_Master);
            }
            if (formJson.BodyContext.PM != undefined) {
                $("#Total_Sub_Span").text(formJson.BodyContext.PM);
            }
        }
        ////영업대표
        if (JSON.stringify(formJson.BodyContext) != "{}" && typeof formJson.BodyContext != 'undefined') {

            if (formJson.BodyContext.Total_Master != undefined) {
                $("#Total_Master_Span").text(formJson.BodyContext.Total_Master);
            }
            if (formJson.BodyContext.CEO != undefined) {
                $("#Total_Sub_Span2").text(formJson.BodyContext.CEO);
            }
        }

        ////ADD
        if (JSON.stringify(formJson.BodyContext) != "{}" && typeof formJson.BodyContext != 'undefined') {

            if (formJson.BodyContext.Total_Master != undefined) {
                $("#Total_Master_Span").text(formJson.BodyContext.Total_Master);
            }
            if (formJson.BodyContext.ADD != undefined) {
                $("#Total_Sub_Span3").text(formJson.BodyContext.ADD);
            }
        }
    }

    $("[name*='chkbox_']").click(function () {
        $("[name*='chkbox_']").removeAttr("checked", "checked");
        $(this).attr("checked", "checked");
    });
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
        return EASY.check().result;
    }
}

function setBodyContext(sBodyContext) {
}

//본문 XML로 구성
function makeBodyContext() {
    /*var sBodyContext = "";
    sBodyContext = "<BODY_CONTEXT>" + getFields("mField") + getMultiRowFields("TB", "rField") + "</BODY_CONTEXT>";

    return sBodyContext;
    */
    var bodyContextObj = {};
    
	bodyContextObj["BodyContext"] = getFields("mField");
    $$(bodyContextObj["BodyContext"]).append(getMultiRowFields("TB", "rField"));
    
    return bodyContextObj;
}

function calSDATEEDATE(obj) {
    var tmpObj = $(obj).closest('TR');

    if ($(tmpObj).find("input[id=DAY_START]").val() != "" && $(tmpObj).find("input[id=DAY_FINISH]").val() != "") {
        var SDATE = $(tmpObj).find("input[id=DAY_START]").val().split('-');
        var EDATE = $(tmpObj).find("input[id=DAY_FINISH]").val().split('-');

        var SOBJDATE = new Date(parseInt(SDATE[0], 10), parseInt(SDATE[1], 10) - 1, parseInt(SDATE[2], 10));
        var EOBJDATE = new Date(parseInt(EDATE[0], 10), parseInt(EDATE[1], 10) - 1, parseInt(EDATE[2], 10));
        var tmpday = EOBJDATE - SOBJDATE;
        tmpday = parseInt(tmpday, 10) / (1000 * 3600 * 24);
        if (tmpday < 0) {
            alert("이전 일보다 전 입니다. 확인하여 주십시오.");
            $(obj).val("");
        }
    }
}

var objTxtSelect;
function OpenWinEmployee(szObject) {
    objTxtSelect = document.getElementById(szObject);
    objTxtSelect.value = "";
    /*
    var sType = "B9";
    var sGroup = "N";
    var sTarget = "Y";
    var sCompany = "Y";
    var sSearchType = "";
    var sSearchText = "";
    var sSubSystem = "";
    XFN_OrgMapShow_WindowOpen("REQUEST_TEAM_LEADER", "bodytable_content", objTxtSelect.id, openID, "Requester_CallBack", sType, sGroup, sCompany, sTarget, sSubSystem, sSearchType, sSearchText);
	*/
    
    CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=Requester_CallBack&type=B1","<spring:message code='Cache.lbl_apv_org'/>",1000,580,"");
}

function Requester_CallBack(pStrItemInfo) {
	
	var oJsonOrgMap = $.parseJSON(pStrItemInfo);

    if (oJsonOrgMap.item.length == 1) {
        objTxtSelect.value = CFN_GetDicInfo(oJsonOrgMap.item[0].PO.split("&")[1]) + " " + CFN_GetDicInfo(oJsonOrgMap.item[0].DN);
       
        // [16-07-14] kimhs, 조건 추가
        if (objTxtSelect.id == "PM")
            $("#PM_Code").val(oJsonOrgMap.item[0].AN);
    }
    else {
        alert("인원은 1명까지 지정 가능합니다. 다시 지정해주세요.");
    }
	/*
    var oXmlOrgMap = $.parseXML("<?xml version='1.0' encoding='utf-8'?>" + pStrItemInfo);
    if ($(oXmlOrgMap).find('ItemInfo[type=User]').length <= 1) {
        $(oXmlOrgMap).find('ItemInfo[type=User]').each(function (i, item) {
            objTxtSelect.value = CFN_GetDicInfo($(item).find('ExJobPositionName').eq(0).text().split('&')[1]) + " " + CFN_GetDicInfo($(item).find('ExDisplayName').eq(0).text());

            // [16-07-14] kimhs, 조건 추가
            if (objTxtSelect.id == "PM")
                $("#PM_Code").val($(item).find('UR_Code').text());
        });
    }
    else {
        alert("인원은 1명까지 지정 가능합니다. 다시 지정해주세요.");
        //OpenWinEmployee(objTxtSelect.name);
    }*/
}

var objTxtSelect3;
function ORG() {
    objTxtSelect3 = document.getElementById("TB");
    /*
    var sType = "B9";
    var sGroup = "N";
    var sTarget = "Y";
    var sCompany = "Y";
    var sSearchType = "";
    var sSearchText = "";
    var sSubSystem = "";
    XFN_OrgMapShow_WindowOpen("REQUEST_TEAM_LEADER", "bodytable_content", objTxtSelect3.name, openID, "Requester_CallBack3", sType, sGroup, sCompany, sTarget, sSubSystem, sSearchType, sSearchText);
	*/
    CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=Requester_CallBack3&type=B9","<spring:message code='Cache.lbl_apv_org'/>",1000,580,"");
}


function Requester_CallBack3(pStrItemInfo) {
	var oJsonOrgMap =  $.parseJSON(pStrItemInfo);
    if (oJsonOrgMap.item.length <= 15) {
        $(oJsonOrgMap.item).each(function (i, item) {
            XFORM.multirow.addRow('#TB', 1, function ($rows) {
                fnSetRow($rows, item);
            })
        });
    }
    else {
        alert("인원은 15명까지 지정 가능합니다. 다시 지정해주세요.");
        //ORG();
    }
}

function fnSetRow(rows, OrgMap) {
  /*  rows.find("span[name=PRO_DEPT]").text(CFN_GetDicInfo($(OrgMap).find('ExGroupName').eq(0).text().split('&')[1]));
    rows.find("span[name=PRO_POSITION]").text(CFN_GetDicInfo($(OrgMap).find('ExJobPositionName').eq(0).text().split('&')[1]));
    rows.find("span[name=PRO_NAME]").text(CFN_GetDicInfo($(OrgMap).find('ExDisplayName').eq(0).text()));
    rows.find("input[name=PRO_ID]").val($(OrgMap).find('UR_Code').eq(0).text());*/
	
	rows.find("span[name=PRO_DEPT]").text(CFN_GetDicInfo(OrgMap.RGNM));
    rows.find("span[name=PRO_POSITION]").text(CFN_GetDicInfo(OrgMap.PO.split("&")[1]));
    rows.find("span[name=PRO_NAME]").text(CFN_GetDicInfo(OrgMap.DN));
    rows.find("input[name=PRO_ID]").val(OrgMap.AN );
}

function PROJECTNAME() {
    var project_name = $('#PROJECT_CODE').val();
    
    if (formJson.Request.mode == "DRAFT" ){
    	$("#Subject").val(m_oFormMenu.getLngLabel(getInfo("FormInfo.FormName") + " - " + project_name, false));
    }
    //var project_name = $('#PROJECT_NAME option:selected').text();
    //$("#SUBJECT").val(m_oFormMenu.getLngLabel(getInfo("fmnm") + " - " + project_name, false));
    //$('#PROJECT_CODE').val($('#PROJECT_NAME option:selected').text());
}

// 프로젝트 코드 타입 세팅 + [추가] 프로젝트 코드에 따라 영업대표란 required 속성 부여/제거
function setJobType() {
    var obj = $("#SUBJECT_TYPE option:selected").val();
    if (obj == "P" || obj == "C") {
        $("#CEO").prop("required", true);
        $("#CEO").addClass("input-required");
    }
    else {
        $("#CEO").prop("required", false);
        $("#CEO").removeClass("input-required");
    }

    $("#pStrJobtype").val($("#SUBJECT_TYPE option:selected").val());
}