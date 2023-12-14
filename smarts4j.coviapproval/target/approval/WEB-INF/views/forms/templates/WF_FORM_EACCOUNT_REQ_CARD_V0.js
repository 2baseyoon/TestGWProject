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

        //<!--loadMultiRow_Read-->
        
        if(formJson.BodyContext != undefined) {
        	appTypeChange();
        }
		
        //특정 디자인 수정
        $('#application_reason').removeAttr('style');
        
        //writeOnly해도 selectbox text 남는 현상 제거
        $("#limit_type").next().remove(); 
        $("#change_amount").next().remove();
    }
    else {
        $('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });
        
        setSelectBox("card_application_type");    	
        setSelectBox("card_num");
        setSelectBox("limit_type_combo");
        setSelectBox("reissuance_type");
        setSelectBox("card_company");
        setSelectBox("change_amount_combo");

        // 에디터 처리
        //<!--AddWebEditor-->
        
        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {

            document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
        }
        
        if(formJson.Request.mode == "DRAFT") {
        	appTypeChange($("#card_application_type"));
        } else {
        	if(formJson.BodyContext != undefined)
        		appTypeChange();
        }
     
        //<!--loadMultiRow_Write-->
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
    	var cardAppType = $("#card_application_type").val();
    	switch(cardAppType) {
    	case "CoCardLimitChange":
    		if($("#card_num").val() == "") {
    			Common.Warning(Common.getDic("ACC_msg_noDataCardNum")); //카드번호를 입력하세요.
    			return false;
    		} else if($("#change_amount").val() == "") {
    			Common.Warning(Common.getDic("ACC_msg_noDataChangeLimitAmount")); //변경한도금액을 입력하세요.
    			return false;
    		} else if($("#limit_type_combo").val() == "Up" && $("#change_expiration_date").val() == "") {
    			Common.Warning(Common.getDic("ACC_msg_noDataChangeExpirationDate")); //변경만료일을 입력하세요.
    			return false;
    		}
    		break;
    	case "CoCardReissue":
    		if($("#card_num").val() == "") {
    			Common.Warning(Common.getDic("ACC_msg_noDataCardNum")); //카드번호를 입력하세요.
    			return false;
    		} else if($("#reissuance_type").val() == "") {
    			Common.Warning(Common.getDic("ACC_msg_noDataReissuanceType")); //재발급구분을 입력하세요.
    			return false;
    		}
    		break;
    	case "CoCardClose":
    		if($("#card_num").val() == "") {
    			Common.Warning(Common.getDic("ACC_msg_noDataCardNum")); //카드번호를 입력하세요.
    			return false;
    		}
    		break;
    	case "PublicCardRequest":
    		if($("#start_date").val() == "") {
    			Common.Warning(Common.getDic("msg_EnterStartDate")); //시작일자를 입력하세요.
    			return false;
    		} else if($("#end_date").val() == "") {
    			Common.Warning(Common.getDic("msg_EnterEndDate")); //종료일자를 입력하세요.
    			return false;
    		} else if($("#application_amount").val() == "") {
    			Common.Warning(Common.getDic("ACC_msg_noDataApplicationAmount")); //신청금액을 입력하세요.
    			return false;
    		}
    		break;
    	case "PrCardApp":
    		if($("#card_num").val() == "") {
    			Common.Warning(Common.getDic("ACC_msg_noDataCardNum")); //카드번호를 입력하세요.
    			return false;
    		}
    		break;
    	}
    	
    	return true;
        //return EASY.check().result;
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
	$$(bodyContextObj["BodyContext"]).append("Subject", $("#Subject").val());
    return bodyContextObj;
}

var cardMap = {};

function setSelectBox(pSelectBoxId) {
	if($("#" + pSelectBoxId).find("option").length > 0) { //이미 세팅되었다면 return
		return;
	} else {
		if(pSelectBoxId == "card_num") { //GET 방식 호출 => CFN_CallAjax 사용 불가
			$.ajax({
				data: {},
				url:"/account/baseInfo/getCompanyCardComboList.do",
				success:function (data) {
					if(data.result == "ok"){
						receiveHTTPGetData_CardNum(data, pSelectBoxId); 
					}
				},
				error:function (response, status, error){
					CFN_ErrorAjax("/account/baseInfo/getCompanyCardComboList.do", response, status, error);
				}
			});
		} else {
			var codeGroup = $("#" + pSelectBoxId).attr("codegroup");
			CFN_CallAjax("/account/accountCommon/getBaseCodeCombo.do", {"codeGroups":codeGroup}, function (data){ 
				receiveHTTPGetData_BaseCode(data, pSelectBoxId, codeGroup); 
			}, false, 'json');			
		}
	}
}

function receiveHTTPGetData_CardNum(responseXMLdata, pSelectBoxId) {
    var xmlReturn = responseXMLdata;
    var elmlist = xmlReturn.list;

    $("#" + pSelectBoxId).append("<option value=''>선택</option>");
    $(elmlist).each(function (i, obj) {
    	$("#" + pSelectBoxId).append("<option value='" + obj.CardNo + "'>" + obj.CardNoView + "</option>");
    	cardMap["cardED_" + obj.CardNo] = obj.ExpirationDate;
    	cardMap["cardLA_" + obj.CardNo] = obj.LimitAmount;
    	cardMap["cardLAT_" + obj.CardNo] = obj.LimitAmountType;
    	cardMap["cardCC_" + obj.CardNo] = obj.CardCompany;
    });
    
    if(formJson.BodyContext[pSelectBoxId] != undefined) {
    	$("#" + pSelectBoxId).val(formJson.BodyContext[pSelectBoxId]);
    }
}

function receiveHTTPGetData_BaseCode(responseXMLdata, pSelectBoxId, pCodeGroup) {
    var xmlReturn = responseXMLdata;
    var elmlist = xmlReturn.list[0][pCodeGroup];

    if(pCodeGroup == "CardLimitAmount") {
        $("#" + pSelectBoxId).append("<option value=''>직접입력</option>");    	
    } else {
    	if(pCodeGroup != "CardApplicationType") {
    		$("#" + pSelectBoxId).append("<option value=''>선택</option>");
    	}
    }
    $(elmlist).each(function (i, obj) {
    	$("#" + pSelectBoxId).append("<option value='" + obj.Code + "'>" + obj.CodeName + "</option>");
    });
    
    if(formJson.BodyContext[pSelectBoxId] != undefined) {
    	$("#" + pSelectBoxId).val(formJson.BodyContext[pSelectBoxId]);
    }		
}

function appTypeChange(pObj) {
	var appType = "";
	
	if(typeof(pObj) == "object") appType = $(pObj).val();
	else if(typeof(pObj) == "undefined") appType = formJson.BodyContext.card_application_type;
	
	switch(appType) {
	case "CoCardLimitChange":
		$("#tblCorpPrCard").show();
		$("select[name=card_num]").attr("id", "card_num");
		$("select[name=card_num]").show();
		$("input[name=card_num]").removeAttr("id");
		$("input[name=card_num]").hide();
		$("#cardNumTd").attr("colspan", "");
		$("#card_num").css("width", "75%");
		$("[name=limitArea]").show();
		$("[name=reissueArea]").hide();
		$("[name=privateArea]").hide();
		$("[name=nonPrivateArea]").show();
		$("#tblPublicCard").hide();
		if(formJson.BodyContext != undefined && formJson.BodyContext.limit_type_combo == "Dwn") {
			$("#change_expiration_date").closest("tr").hide();
		}
		$("[name=newArea]").prev().attr("colspan", "2");
		$("[name=newArea]").hide();
		break;
	case "CoCardNewissue":
		$("#tblCorpPrCard").hide();
		$("select[name=card_num]").attr("id", "card_num");
		$("select[name=card_num]").show();
		$("input[name=card_num]").removeAttr("id");
		$("input[name=card_num]").hide();
		$("[name=limitArea]").hide();
		$("[name=reissueArea]").hide();
		$("[name=privateArea]").hide();
		$("[name=nonPrivateArea]").hide();
		$("#tblPublicCard").hide();
		$("[name=newArea]").prev().removeAttr("colspan");
		$("[name=newArea]").show();
		break;
	case "CoCardReissue":
		$("#tblCorpPrCard").show();
		$("select[name=card_num]").attr("id", "card_num");
		$("select[name=card_num]").show();
		$("input[name=card_num]").removeAttr("id");
		$("input[name=card_num]").hide();
		$("#cardNumTd").attr("colspan", "");
		$("#card_num").css("width", "75%");
		$("[name=limitArea]").hide();
		$("[name=reissueArea]").show();
		$("[name=privateArea]").hide();
		$("[name=nonPrivateArea]").show();
		$("#tblPublicCard").hide();
		$("[name=newArea]").prev().attr("colspan", "2");
		$("[name=newArea]").hide();
		break;
	case "CoCardClose":
		$("#tblCorpPrCard").show();
		$("select[name=card_num]").attr("id", "card_num");
		$("select[name=card_num]").show();
		$("input[name=card_num]").removeAttr("id");
		$("input[name=card_num]").hide();
		$("#cardNumTd").attr("colspan", "3");
		$("#card_num").css("width", "30%");
		$("[name=limitArea]").hide();
		$("[name=reissueArea]").hide();
		$("[name=privateArea]").hide();
		$("[name=nonPrivateArea]").show();
		$("#tblPublicCard").hide();
		$("[name=newArea]").prev().attr("colspan", "2");
		$("[name=newArea]").hide();
		break;
	case "PublicCardRequest":
		$("#tblCorpPrCard").hide();
		$("select[name=card_num]").attr("id", "card_num");
		$("select[name=card_num]").show();
		$("input[name=card_num]").removeAttr("id");
		$("input[name=card_num]").hide();
		$("#tblPublicCard").show();
		$("[name=newArea]").prev().attr("colspan", "2");
		$("[name=newArea]").hide();
		break;
	case "PrCardApp":
		$("#tblCorpPrCard").show();
		$("select[name=card_num]").removeAttr("id");
		$("select[name=card_num]").hide();
		$("input[name=card_num]").attr("id", "card_num");
		$("input[name=card_num]").show();
		$("#cardNumTd").attr("colspan", "");
		$("[name=limitArea]").hide();
		$("[name=reissueArea]").hide();
		$("[name=privateArea]").show();
		$("[name=nonPrivateArea]").hide();
		$("#tblPublicCard").hide();
		$("[name=newArea]").prev().attr("colspan", "2");
		$("[name=newArea]").hide();
		break;
	}
}

function cardNumChange(pObj) {
	var cardNum = $(pObj).val();
	
	$("#expiration_date").val(cardMap["cardED_" + cardNum]);
	$("#limit_amount").val(cardMap["cardLA_" + cardNum]);
	$("#limit_amount_type").val(cardMap["cardLAT_" + cardNum]);
}

function amountChange(pObj) {
	var limit_amount = Number($("#limit_amount").val());
	var change_amount = Number($(pObj).val());
	
	if(limit_amount > change_amount) { //감액
		$("#limit_type_combo").val("Dwn");
		$("#change_expiration_date").closest("tr").hide();
	} else { //증액
		$("#limit_type_combo").val("Up");
		$("#change_expiration_date").closest("tr").show();
	}
	$("#limit_type").val($("select[id=limit_type_combo] option:selected").text());
}

function amountComboChange(pObj) {
	var amountType = $(pObj).val();
	
	if(amountType == "") {
		$("#change_amount").attr("readonly", false);
		$("#change_amount").attr("disabled", false);
	} else {
		$("#change_amount").attr("readonly", "readonly");
		$("#change_amount").attr("disabled", "disabled");
		$("#change_amount").val($(pObj).val().replace("Amt", ""));
		amountChange($("#change_amount"));
	}
}

function calSDateEDate() {
	var sdate = null; 
	var edate = null;
	if($("#start_date").val() != "" && $("#end_date").val() != "") {
		sdate = new Date($("#start_date").val());
		edate = new Date($("#end_date").val());
		if(sdate.getTime() > edate.getTime()) {
			$("#start_date").val($("end_date").val());
		}
	}
}

function changeCardNoInput(obj) {
	var val = obj.value;
	var strVal = "";
	
	if(val != null){
		val = val.toString();
		val = val.replaceAll("-", "");
		val = val.replace(/[^0-9]/g, "");
		val = val.substr(0,16)
	
		if(isNaN(val)){
			strVal = "";
			val = "";
		}
		else{
			strVal = makeCardNoFormat(val);
		}
		obj.value = strVal;
		
		$("#card_num").val(val);
		
	}
}
//카드번호 양식
function makeCardNoFormat(val) {
	var retVal = "";
	retVal = val.substr(0,4)
	if(val.substr(4,4) != ""){
		retVal = retVal + "-"+ val.substr(4,4)
	}
	
	if(val.substr(8,4) != ""){
		retVal = retVal + "-"+ val.substr(8,4)
	}
	
	if(val.substr(12,4) != ""){
		retVal = retVal + "-"+ val.substr(12,4)
	}
	return retVal;
}

function inputNumChk(e){
	var keyValue	= e.keyCode;
	if(	(keyValue	>= 48)	&&
		(keyValue	<= 57)){
		return true
	}else{
		return false
	}
}

function pressHan(obj){
	if(	event.keyCode == 8	||
		event.keyCode == 9	||
		event.keyCode == 37	||
		event.keyCode == 39	||
		event.keyCode == 46){
		return;
	}
	obj.value = obj.value.replace(/[^0-9]/gi,'');
}