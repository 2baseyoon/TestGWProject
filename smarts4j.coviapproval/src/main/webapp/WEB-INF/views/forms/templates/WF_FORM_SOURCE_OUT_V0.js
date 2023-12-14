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
	_setLicenseComponent();
	
    // 체크박스, radio 등 공통 후처리
    postJobForDynamicCtrl();
	
    //읽기 모드 일 경우
    if (getInfo("Request.templatemode") == "Read") {

        $('*[data-mode="writeOnly"]').each(function () {
            $(this).hide();
        });

        if (JSON.stringify(formJson.BodyContext) != "{}" && formJson.BodyContext.multiTable != undefined && formJson.BodyContext.multiTable !='') {
            XFORM.multirow.load(JSON.stringify(removeSeperatorForMultiRow(formJson.BodyContext.multiTable)), 'json', '#multiTable', 'R');
        } else {
            XFORM.multirow.load('', 'json', '#multiTable', 'R');
        }


    }
    else {
        $('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });

        $("#tblFormSubject").css("display", "none");
        
        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {
        	 document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
             document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
        }

        if(formJson.Request.mode == "REDRAFT") {
        	$("#VERSIONINFO").prop("disabled", false);
        }
        
        if (JSON.stringify(formJson.BodyContext) != "{}" && formJson.BodyContext.multiTable != undefined && formJson.BodyContext.multiTable !='') {
            XFORM.multirow.load(JSON.stringify(removeSeperatorForMultiRow(formJson.BodyContext.multiTable)), 'json', '#multiTable', 'W', { minLength: 1 });
        } else {
            var json_multi_data = '[{"REQUSERNAME":"' + m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false) + '","REQUSERDEPT":"' + m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false) + '"}]';
            XFORM.multirow.load(json_multi_data, 'json', '#multiTable', 'W', { minLength: 1 });
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
    	if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {
    		$("#Subject").val("소스반출 신청서 - " + $("#Contract_Name").val());
    	}
    	
        return EASY.check().result;
    }
}

function setBodyContext(sBodyContext) {
}

//본문 XML로 구성
function makeBodyContext() {
	var bodyContextObj = {};
	bodyContextObj["BodyContext"] = getFields("mField");
	$$(bodyContextObj["BodyContext"]).append(getMultiRowFields("multiTable", "rField"));
	
    return bodyContextObj;
}


var objTxtSelect, tmpObj;
function OpenWinEmployee(szObject, obj) {
    tmpObj = obj;
    
    CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=Requester_CallBack&type=B1","<spring:message code='Cache.lbl_apv_org'/>",1000,580,"");
}

function Requester_CallBack(pStrItemInfo) {
	var oJsonOrgMap = $.parseJSON(pStrItemInfo);
    var l_User = oJsonOrgMap.item[0];
    
    $(tmpObj).closest("tr").find("input[name=REQUSERNAME]").val(CFN_GetDicInfo(l_User.DN));
    $(tmpObj).closest("tr").find("input[name=REQUSERDEPT]").val(CFN_GetDicInfo(l_User.RGNM));
}

function _setLicenseComponent(){
	// 포함모듈 세팅
	var $fragment = $(document.createDocumentFragment());
	var modulesStr = Common.getSecurityProperties("license.bizsection.module");
	var modules = [];
	if(modulesStr == undefined || modulesStr == "") {
		modulesStr = "Account|Approval|Attend|Collab|Mail|Webhard";
		modules = modulesStr.split("|");
	}
	for(var i = 0; i < modules.length; i++) {
		var Code = modules[i];
		var CodeName = Common.getBaseCodeDic("BizSection",Code);
		var $div = $("<label/>", {"style" : "line-height: 150%;"});
		$div.append($("<input/>", {"type": "checkbox", "name":"LicenseModules", "id": "chk" + Code, "value": Code}));
		$div.append(CodeName);
		$div.append("<br/>");
		
		$fragment.append($div);
	}
	$("span#LicenseModules").append($fragment);

	//show when CP
	if (getInfo("Request.templatemode") == "Read") {
		// 조회모드
		if(formJson.BodyContext["Contract_Type"] == "CP"){
			$("span#LicenseModules").closest("tr").show();
		}
	}else{
		// 입력모드
		$(':input:radio[name=Contract_Type]').on("click", function(){
			if($(':input:radio[name=Contract_Type]:checked').val() == "CP"){
				$("span#LicenseModules").closest("tr").show();
			}else{
				$("span#LicenseModules").closest("tr").hide();
			}
		});
		$(':input:checkbox[name=Systems]').on("click", function(){
			var pair = {
				"account" : "Account"
				,"approval" : "Approval"
				,"mail": "Mail"
				,"webhard": "Webhard"
			};
			if(pair[this.value]) {
				$("span#LicenseModules").find("[value="+pair[this.value]+"]").prop("checked", this.checked);
			}
		});
		if($(':input:radio[name=Contract_Type]:checked').val() == "CP"){
			$("span#LicenseModules").closest("tr").show();
		}
	}
	
}