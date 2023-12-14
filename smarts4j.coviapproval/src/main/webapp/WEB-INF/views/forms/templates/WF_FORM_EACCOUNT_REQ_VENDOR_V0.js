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
//개별호출 -> 일괄호출
Common.getDicList(["ACC_msg_SelectVendor","ACC_msg_SelectBank","ACC_msg_noDataBankAccount","ACC_msg_noDataBankOwner","ACC_msg_noDataVendorName","ACC_msg_checkRegisted","ACC_msg_noDataPersonalVendorNo","ACC_005"]);

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

    }
    else {
        $('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });
        
        setSelectBox("vendor_application_type");
        setSelectBox("organization_pay_type");
        setSelectBox("organization_pay_method");
        setSelectBox("personal_pay_type");
        setSelectBox("personal_pay_method");
        setSelectBox("personal_incom_tax");
        setSelectBox("personal_local_tax");
        setSelectBox("business_pay_type");
        setSelectBox("business_pay_method");

        // 에디터 처리
        //<!--AddWebEditor-->
        
        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {

            document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
        }
     
        //<!--loadMultiRow_Write-->
        if(formJson.Request.mode == "DRAFT") {
        	appTypeChange($("#card_application_type"));
        } else if(formJson.Request.mode != "DRAFT" && formJson.BodyContext != undefined) {
        	appTypeChange();
        }
    	
    	EASY.init();
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
    	var vendorAppType = $("#vendor_application_type").val();
    	switch(vendorAppType) {
    	case "BankChange":
    		if($("#vendor_name").val() == "") {
    			Common.Warning(Common.getDic("ACC_msg_SelectVendor")); //거래처를 선택하세요.
    			return false;
    		}
    		else if ($("#bank_name").val() == "") {
                Common.Warning(Common.getDic("ACC_msg_SelectBank")); //은행을 선택하세요.
                return false;
            } else if ($("#bank_account").val() == "") {
                Common.Warning(Common.getDic("ACC_msg_noDataBankAccount")); //은행계좌를 입력하세요.
                return false;
            } else if ($("#bank_owner").val() == "") {
                Common.Warning(Common.getDic("ACC_msg_noDataBankOwner")); //예금주를 입력하세요.
                return false;
            }
    		break;
    	case "Organization":
    		if($("#organization_vendor_no").val() == "") {
    			Common.Warning("사번을 입력하세요.");
    			return false;
    		} else if($("#organization_vendor_name").val() == "") {
    			Common.Warning(Common.getDic("ACC_msg_noDataVendorName")); //거래처명을 입력하세요.
    			return false;
    		} else if($("#organization_reg_check").val() == "N") {
    			Common.Warning(Common.getDic("ACC_msg_checkRegisted")); //등록 여부를 확인하세요.
    			return false;
    		}    		
    		break;
    	case "People":
    		if($("#personal_vendor_no").val() == "") {
    			Common.Warning(Common.getDic("ACC_msg_noDataPersonalVendorNo")); //주민등록번호를 입력하세요.
    			return false;
    		} else if($("#personal_vendor_name").val() == "") {
    			Common.Warning(Common.getDic("ACC_msg_noDataVendorName")); //거래처명을 입력하세요.
    			return false;
    		} else if($("#personal_reg_check").val() == "N") {
    			Common.Warning(Common.getDic("ACC_msg_checkRegisted")); //등록 여부를 확인하세요.
    			return false;
    		}
    		break;
    	case "Company":
    		if($("#business_vendor_no").val() == "") {
    			Common.Warning(Common.getDic("ACC_005")); //사업자번호를 입력해주세요.
    			return false;
    		} else if($("#business_vendor_name").val() == "") {
    			Common.Warning(Common.getDic("ACC_msg_noDataVendorName")); //거래처명을 입력하세요.
    			return false;
    		} else if($("#business_reg_check").val() == "N") {
    			Common.Warning(Common.getDic("ACC_msg_checkRegisted")); //등록 여부를 확인하세요.
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
	var bodyContextObj = {};
	bodyContextObj["BodyContext"] = getFields("mField");
	$$(bodyContextObj["BodyContext"]).append("Subject", $("#Subject").val());
    return bodyContextObj;
}

function setSelectBox(pSelectBoxId) {
	if($("#" + pSelectBoxId).find("option").length > 0) { //이미 세팅되었다면 return
		return;
	} else {
		var codeGroup = $("#" + pSelectBoxId).attr("codegroup");
		CFN_CallAjax("/account/accountCommon/getBaseCodeCombo.do", {"codeGroups":codeGroup}, function (data){ 
			receiveHTTPGetData_BaseCode(data, pSelectBoxId, codeGroup); 
		}, false, 'json');
	}
}

function receiveHTTPGetData_BaseCode(responseXMLdata, pSelectBoxId, pCodeGroup) {
    var xmlReturn = responseXMLdata;
    var elmlist = xmlReturn.list[0][pCodeGroup];


	if(pCodeGroup != "VendorApplicationType") {
		$("#" + pSelectBoxId).append("<option value=''>선택</option>");
	}
    $(elmlist).each(function (i, obj) {
    	if(pCodeGroup == "WHTax" && pSelectBoxId == "personal_incom_tax") {
    		if(parseInt(Number(obj.Code.replace("E", "")) / 100) == 1) {
    	    	$("#" + pSelectBoxId).append("<option value='" + obj.Code + "'>" + obj.CodeName + "</option>");
    		}
    	} else if(pCodeGroup == "WHTax" && pSelectBoxId == "personal_local_tax") {
    		if(parseInt(Number(obj.Code.replace("E", "")) / 100) == 2) {
    	    	$("#" + pSelectBoxId).append("<option value='" + obj.Code + "'>" + obj.CodeName + "</option>");
    		}    		
    	} else {
    		$("#" + pSelectBoxId).append("<option value='" + obj.Code + "'>" + obj.CodeName + "</option>");
    	}
    });		
    
    if(formJson.BodyContext[pSelectBoxId] != undefined) {
    	$("#" + pSelectBoxId).val(formJson.BodyContext[pSelectBoxId]);
    }
}

function appTypeChange(pObj) {
	var appType = "";
	
	if(typeof(pObj) == "object") appType = $(pObj).val();
	else if(typeof(pObj) == "undefined") appType = formJson.BodyContext.vendor_application_type;
	
	switch(appType) {
	case "BankChange":
		$("#tblBankAccount").show();
		$("#tblOrganization").hide();
		$("#tblPersonal").hide();
		$("#tblBusiness").hide();
		break;
	case "Organization":
		$("#tblBankAccount").hide();
		$("#tblOrganization").show();
		$("#tblPersonal").hide();
		$("#tblBusiness").hide();
		break;
	case "People":
		$("#tblBankAccount").hide();
		$("#tblOrganization").hide();
		$("#tblPersonal").show();
		$("#tblBusiness").hide();
		break;
	case "Company":
		$("#tblBankAccount").hide();
		$("#tblOrganization").hide();
		$("#tblPersonal").hide();
		$("#tblBusiness").show();
		break;
	}
}

function rdoTypeChange(pType) {
	var selected = $('input:radio[name=rdo_type_' + pType + ']:checked').val();
	
	/*if(selected == "new") {
		$("[name=" + pType + "NewArea]").show();
	} else {
		$("[name=" + pType + "NewArea]").hide();
	}*/
	
	$("#" + pType + "_reg_check").val("N");
}

function OpenWinEmployee() {   
	CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=Requester_CallBack&type=B1","조직도",1000,580,"");
}

function Requester_CallBack(pStrItemInfo) {
    var oJsonOrgMap = $.parseJSON(pStrItemInfo);
    var I_User = oJsonOrgMap.item[0];
 	
    if(I_User != undefined){
		$("#organization_vendor_name").val(CFN_GetDicInfo(I_User.DN));
		$("#organization_vendor_no").val(I_User.AN);
    }
}

function openPopup(pTarget) {
	if(pTarget == "VENDOR") {
		var popupID		=	"vendorSelectPopup";
		var popupTit	=	"거래처";	//거래처 선택
		var popupYN		=	"N";
		var popupName	=	"VendorSearchPopup";
		var openerID	=	"VendorRequest";
		var callBack	=	"callBackForVendor";
		var url			=	"/account/accountCommon/accountCommonPopup.do?"
						+	"popupID="		+	popupID		+	"&"
						+	"popupName="	+	popupName	+	"&"
						+	"openerID="		+	openerID	+	"&"
						+	"popupYN="		+	popupYN		+	"&"
						+	"includeAccount=N&"
						+	"callBackFunc="	+	callBack;
		Common.open(	"",popupID,popupTit,url,"700px","500px","iframe",true,null,null,true);
	} else if(pTarget == "BANK") {		
		var popupID		=	"bankSelectPopup";
		var popupTit	=	"은행";	//은행선택
		var popupName	=	"BankSearchPopup";
		var openerID	=	"VendorRequest";
		var callBack	=	"callBackForBank";
		var popupYN		=	"N";
		var url			=	"/account/accountCommon/accountCommonPopup.do?"
						+	"popupID="		+	popupID		+	"&"
						+	"popupName="	+	popupName	+	"&"
						+	"openerID="		+	openerID	+	"&"
						+	"popupYN="		+	popupYN		+	"&"
						+	"callBackFunc="	+	callBack;
		Common.open(	"",popupID,popupTit,url,"350px","400px","iframe",true,null,null,true);
	}
}

function chkRegistedVendorNo(pType) {
	var VendorNo		= "";
	var VendorType		= "";
	var IsNew			= "";

	VendorNo = $("#" + pType + "_vendor_no").val();
	VendorType = pType == "organization" ? "OR" : pType == "personal" ? "PE" : "CO";
	IsNew = $('input:radio[name=rdo_type_' + pType + ']:checked').val() == "new" ? "Y" : "N";

	if(isEmptyStr(VendorNo)){
		if(pType == "organization") {
			Common.Warning("사번을 입력해주세요");
		} else if(pType == "personal") {
			Common.Warning("주민등록번호를 입력해주세요");			
		} else {
			Common.Warning("사업자번호를 입력해주세요");			
		}
		return;
	}
	
	if(pType == "personal" && VendorNo.length != 14){
		Common.Warning("형식이 올바르지 않습니다.");
		return;
	}
	if(pType == "business" && VendorNo.length != 12){
		Common.Warning("형식이 올바르지 않습니다.");
		return;
	}
	
	CFN_CallAjax("/account/baseInfo/checkVendorDuplicate.do", {"VendorNo" : VendorNo, "VendorType" : VendorType}, function (data){
		if(data.result == "ok") {
			var duplItem = data.duplItem;
			if(duplItem != null){
				var duplCnt	= duplItem.CNT;
				var duplID	= duplItem.VendorID;
				if(duplCnt != 0){
					var msg = "등록되어 있는 거래처 입니다"	//등록되어 있는 거래처 입니다.
					if(IsNew=="Y"){
						msg=msg+"<br>"+"변경신청을 하시곘습니까?"	//변경 신청을 하시겠습니까?

						Common.Confirm(msg, "Confirmation Dialog", function(result){
							if(result){
								$("#" + pType + "_change").click();
								$("#" + pType + "_reg_check").val("Y");
							}
						});
					}else{
						Common.Inform(msg);
						$("#" + pType + "_reg_check").val("Y");
					}
				} else {
					var msg = "등록되어 있지 않은 거래처입니다."	//등록되어 있지 않은 거래처입니다.
					if(IsNew!="Y"){
						msg=msg+"<br>"+"신규신청을 하시겠습니까?"	//신규신청을 하시겠습니까??
						Common.Confirm(msg, "Confirmation Dialog", function(result){
							if(result){
								$("#" + pType + "_new").click();
								$("#" + pType + "_reg_check").val("Y");
							}
						});
					}else{
						Common.Inform(msg);
						$("#" + pType + "_reg_check").val("Y");
					}
				}
			}		
		}
	}, false, 'json');
}

function changeVendorNo(pType){
	$("#" + pType + "_reg_check").val("N");
	
	var val = $("#" + pType + "_vendor_no").val();
	var strVal = "";
	
	if(val != null){
		val = val.toString();
		val = val.replaceAll("-", "");
		
		if(isNaN(val)) {
			strVal = "";
			val = "";
		}
		else{
			strVal = vendorNoFormat(val, pType);
		}
		$("#" + pType + "_vendor_no").val(strVal);
	}
}

function vendorNoFormat(val, pType){
	var retVal = "";
	if(pType == "business") {
		val = val.substr(0,10);
		retVal = val.substr(0,3);
		if(val.substr(3,2) != ""){
			retVal = retVal + "-"+ val.substr(3,2);
		}
	
		if(val.substr(5,5) != ""){
			retVal = retVal + "-"+ val.substr(5,5);
		}
	} else if(pType == "personal") {
		val = val.substr(0,13);
		retVal = val.substr(0,6);
		if(val.substr(6,7) != ""){
			retVal = retVal + "-"+ val.substr(6,7);
		}		
	}
	return retVal;
}

var VendorRequest = {
		callBackForVendor : function(vdInfo) {
			$("#vendor_id").val(vdInfo.VendorID);
			$("#vendor_name").val(vdInfo.VendorName);
			$("#vendor_no").val(vdInfo.VendorNo);
		},
		callBackForBank : function(bankInfo) {
			var me = this;			
			var appType = $("#vendor_application_type").val();
			
			if(appType == "BankChange"){
				$("#bank_code").val(bankInfo.Code);
				$("#bank_name").val(bankInfo.CodeName);
			}
			else if(appType == "Organization"){
				$("#organization_bank_code").val(bankInfo.Code);
				$("#organization_bank_name").val(bankInfo.CodeName);
			}
			else if(appType == "People"){
				$("#personal_bank_code").val(bankInfo.Code);
				$("#personal_bank_name").val(bankInfo.CodeName);
			}
			else if(appType == "Company"){
				$("#business_bank_code").val(bankInfo.Code);
				$("#business_bank_name").val(bankInfo.CodeName);
			}
		}
}