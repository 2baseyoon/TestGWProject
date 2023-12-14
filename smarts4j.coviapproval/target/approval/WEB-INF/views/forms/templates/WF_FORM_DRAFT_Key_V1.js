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
        $("#standard").show();

        //<!--loadMultiRow_Read-->
		if (JSON.stringify(formJson.BodyContext) != "{}" && formJson.BodyContext != undefined) {
			//Java Migration 이후 멀티로우 ID 변경에 따른 수정
            if(typeof formJson.BodyContext.SubTable1 != 'undefined'){
            	XFORM.multirow.load(JSON.stringify(formJson.BodyContext.SubTable1), 'json', '#SubTable1', 'R', { minLength: 1 });
            }else{
            	XFORM.multirow.load(JSON.stringify(formJson.BodyContext.sub_table1), 'json', '#SubTable1', 'R', { minLength: 1 });
            }
        	$("#standard").show();
        } else {
            XFORM.multirow.load('', 'json', '#SubTable1', 'R');
			$("#standard").show();
        }
    }
    else {
        $('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });
        
        
        var sDate = new Date();
        var sYear = sDate.getFullYear().toString().substring(2, 4);
        var sMonth = (sDate.getMonth() + 1).toString();
        $("#YearMonth").text(sYear + sMonth);
        
        //임시저장 후 제목이 사라지는 현상 수정.
        // if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {
    	if (formJson.Request.mode == "DRAFT") {
        	document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
        	document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
	        document.getElementById("Subject").value = "소프트웨어 라이선스 사용 Key";
			 $('#Contract_Name').focus(function () {
                document.getElementById("Subject").value = "";
                document.getElementById("Subject").value = "소프트웨어 라이선스 사용 Key -" + document.getElementById("Customer_Name").value;
            });

        }     
        
        //<!--loadMultiRow_Write-->
        if (JSON.stringify(formJson.BodyContext) != "{}") {
            //Java Migration 이후 멀티로우 ID 변경에 따른 수정
            if(typeof formJson.BodyContext.SubTable1 != 'undefined'){
            	 XFORM.multirow.load(JSON.stringify(formJson.BodyContext.SubTable1), 'json', '#SubTable1', 'W', { minLength: 1 });
            }else{
            	XFORM.multirow.load(JSON.stringify(formJson.BodyContext.sub_table1), 'json', '#SubTable1', 'W', { minLength: 1 });
            }
            if (formJson.Request.mode == "TEMPSAVE" && (formJson.BodyContext.SerialNumber == "" || formJson.BodyContext.SerialNumber == null)) { //임시저장, serialNumber가 아무것도 없거나, null
            } else if (getInfo("Request.reuse") == "Y") { //재사용 했을때--> 확인(x) 기안(x)
                if (formJson.BodyContext.SerialNumber != "") {
                    $("#SerialNumber").val("");
                }
            }
            else if (formJson.BodyContext.SerialNumber == "" || formJson.BodyContext.SerialNumber == null) { //serialNumber가 없거나 null일때

            }
            else {//임시저장
                $("#standard").show();
            }

        } else {
            XFORM.multirow.load('', 'json', '#SubTable1', 'W', { minLength: 1 });
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
        if (document.getElementById("DocClassName").value == '') {
            Common.Warning('문서분류를 선택해 주세요.');
            return false;
        } else if (!$(':input:radio[name=Contract_Type]:checked').val()) { //$(':radio[name="contract_quarter"]').is(':checked');
            Common.Warning("구분값을 선택해주세요.");
            return false;
        } else {
            return EASY.check().result;
        }

    }
}

function setBodyContext(sBodyContext) {
}

//본문 XML로 구성
function makeBodyContext() {
    /*var sBodyContext = "";
    sBodyContext = "<BODY_CONTEXT>" + getFields("mField") + getMultiRowFields("sub_table1", "rField") + "</BODY_CONTEXT>";*/

    var bodyContextObj = {};
	bodyContextObj["BodyContext"] = getFields("mField");
    $$(bodyContextObj["BodyContext"]).append(getMultiRowFields("SubTable1", "rField"));
    return bodyContextObj;
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
		if($(':input:radio[name=Contract_Type]:checked').val() == "CP"){
			$("span#LicenseModules").closest("tr").show();
		}
	}
}