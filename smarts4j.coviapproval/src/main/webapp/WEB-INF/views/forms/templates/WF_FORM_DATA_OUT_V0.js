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

        if (JSON.stringify(formJson.BodyData) != "{}" && formJson.BodyData.SubTable1 != undefined && formJson.BodyData.SubTable1 !='') {
            XFORM.multirow.load(JSON.stringify(removeSeperatorForMultiRow(formJson.BodyData.SubTable1)), 'json', '#SubTable1', 'R');
        } else {
            XFORM.multirow.load('', 'json', '#SubTable1', 'R');
        }


    }
    else {
        $('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });

        // 에디터 처리


        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {
        	 document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
             document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
        }

        if (JSON.stringify(formJson.BodyData) != "{}" && formJson.BodyData.SubTable1 != undefined && formJson.BodyData.SubTable1 !='') {
            XFORM.multirow.load(JSON.stringify(removeSeperatorForMultiRow(formJson.BodyData.SubTable1)), 'json', '#SubTable1', 'W', { minLength: 1 });
        } else {
            var json_multi_data = '[{"REQUSERNAME":"' + m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false) + '","REQUSERDEPT":"' + m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false) + '"}]';
            XFORM.multirow.load(json_multi_data, 'json', '#SubTable1', 'W', { minLength: 1 });
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
        return EASY.check().result;
    }
}

function setBodyContext(sBodyContext) {
}

//본문 XML로 구성
function makeBodyContext() {
   /* var sBodyContext = "";
    sBodyContext = "<BODY_CONTEXT>" + getFields("mField") + "</BODY_CONTEXT>";

    return sBodyContext;*/
	var bodyContextObj = {};
	bodyContextObj["BodyContext"] = getFields("mField");
    
    return bodyContextObj;
}


var objTxtSelect, tmpObj;
function OpenWinEmployee(szObject, obj) {
    tmpObj = obj;
    
    /*
    var sType = "B1";
    var sGroup = "N";
    var sTarget = "Y";
    var sCompany = "Y";
    var sSearchType = "";
    var sSearchText = "";
    var sSubSystem = "";
    XFN_OrgMapShow_WindowOpen("REQUEST_TEAM_LEADER", "bodytable_content", szObject.id, openID, "Requester_CallBack", sType, sGroup, sCompany, sTarget, sSubSystem, sSearchType, sSearchText);
     */
    CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=Requester_CallBack&type=B1","<spring:message code='Cache.lbl_apv_org'/>",1000,580,"");
}

function Requester_CallBack(pStrItemInfo) {
    /*var oXmlOrgMap = $.parseXML("<?xml version='1.0' encoding='utf-8'?>" + pStrItemInfo);
    var l_User = $(oXmlOrgMap).find('ItemInfo[type=User]').eq(0);

    $(tmpObj).closest("tr").find("input[name=REQUSERNAME]").val(CFN_GetDicInfo($(l_User).find('ExDisplayName').eq(0).text()));
    $(tmpObj).closest("tr").find("input[name=REQUSERDEPT]").val(CFN_GetDicInfo($(l_User).find('GroupName').eq(0).text()));*/
    
	var oJsonOrgMap = $.parseJSON(pStrItemInfo);
    var l_User = oJsonOrgMap.item[0];
    
    $(tmpObj).closest("tr").find("input[name=REQUSERNAME]").val(CFN_GetDicInfo(l_User.DN));
    $(tmpObj).closest("tr").find("input[name=REQUSERDEPT]").val(CFN_GetDicInfo(l_User.RGNM));
}