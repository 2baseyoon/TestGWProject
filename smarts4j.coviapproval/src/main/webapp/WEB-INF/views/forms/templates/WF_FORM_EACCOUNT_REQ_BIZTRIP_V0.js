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
    }
    else {
        $('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });
        
        //getData();
        
        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {
			document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
            document.getElementById("InitiatorCodeDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usid"), false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
            document.getElementById("InitiatedDate").value = getInfo("AppInfo.svdt");
            
            // 임시저장 또는 재사용 시 저장하였던 프로젝트명 가져오기
            if (formJson.Request.mode == "TEMPSAVE" || getInfo("Request.reuse") == "Y" || getInfo("Request.reuse") == "P" || getInfo("Request.reuse") == "YH") {
                if (formJson.BodyContext.PROJECT_NAME != undefined) {
                    $("#PROJECT_NAME").val(formJson.BodyContext.PROJECT_NAME);
                }
            }
        }

        // 편집, 임시저장 또는 재사용 시 저장하였던 프로젝트명 가져오기
        if (formJson.Request.mode != "DRAFT") {
            if (formJson.BodyContext.PROJECT_NAME != undefined) {
                $("#PROJECT_NAME").val(formJson.BodyContext.PROJECT_NAME);     
            }
        }
    }
    
    if (formJson.BodyContext.rdo_type_biztrip != undefined && formJson.BodyContext.rdo_type_biztrip == "P") {
        $("[name=projectArea]").show();
        $("th[name=projectArea]").prev().attr("colspan", "2");
        if(getInfo("Request.templatemode") == "Write")
        	getData();
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
    	if($("#rdo_type_biztrip_project").prop("checked")) {
    		if($("#PROJECT_NAME").val() == "") {
                alert("프로젝트명을 선택하세요.");
    			return false;
    		}
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
	$$(bodyContextObj["BodyContext"]).append("Subject", document.getElementById("Subject").value); 
	$$(bodyContextObj["BodyContext"]).append("InitiatorOUCodeDisplay", m_oFormMenu.getLngLabel(getInfo("AppInfo.dpid"), false));
    return bodyContextObj;
}

function setProjectArea(obj) {
	if(obj.value == "N") {
		$("[name=projectArea]").hide();
		$("#PROJECT_NAME").val("");
		$(obj).parent().parent().attr("colspan", "6");
	} else if(obj.value == "P") {
		$("[name=projectArea]").show();
		$(obj).parent().parent().attr("colspan", "2");
		if($("#PROJECT_NAME").html() == "") {
			getData();
		}
	}
}

/* DB 데이터(프로젝트명)를 불러오기 */
function getData() {
	var selectBoxID = "PROJECT_NAME";
	
	CFN_CallAjax("/approval/legacy/getBaseCodeList.do", {"CodeGroup":"IOCode", "CompanyCode":getInfo("AppInfo.etid")}, function (data){ 
		receiveHTTPGetData(data, selectBoxID);
	}, false, 'json');
}

function receiveHTTPGetData(data, pSelectBoxID) {
    var elmlist = data.list;

    $("#" + pSelectBoxID).append("<option value=''>선택</option>");
    
    $(elmlist).each(function (i, obj) {
    	$("#" + pSelectBoxID).append("<option value='" + obj.Code + "'>" + obj.CodeName + "</option>");
    });
    
    if(formJson.BodyContext[pSelectBoxID] != undefined) {
    	$("#" + pSelectBoxID).val(formJson.BodyContext[pSelectBoxID]);
    }
}

function validateDate() {
    var sdt = $('#SDATE').val().replace(/-/g, '');
    var edt = $('#EDATE').val().replace(/-/g, '');

    if (Number(sdt) > Number(edt)) {
        Common.Warning("시작일은 종료일보다 먼저 일 수 없습니다.");
        $('#EDATE').val('')
    }
}