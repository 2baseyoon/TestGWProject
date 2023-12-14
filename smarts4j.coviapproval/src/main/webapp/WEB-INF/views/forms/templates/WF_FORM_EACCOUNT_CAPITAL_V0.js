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
        
        if (JSON.stringify(formJson.BodyContext) != "{}" && formJson.BodyContext != undefined) {
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.tblExpenceInfo), 'json', '#tblExpenceInfo', 'R');
        }
        
        setReadData();
        $("input[type=button][name=apv_doc]").val("결재문서 보기");

    }
    else {
        $('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });

        // 에디터 처리
        //<!--AddWebEditor-->
        
        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {

            document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
        }
        
        if (JSON.stringify(formJson.BodyContext) != "{}" && formJson.BodyContext != undefined && JSON.stringify(formJson.BodyContext.tblExpenceInfo) != "{}" && formJson.BodyContext.tblExpenceInfo != undefined ) {
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.tblExpenceInfo), 'json', '#tblExpenceInfo', 'W');
        }
        else {
            XFORM.multirow.load('', 'json', '#tblExpenceInfo', 'W', { minLength: 1 });
        }
        
        if (formJson.Request.mode == "DRAFT" && formJson.Request.gloct == "") {
        	setData();
        } else {
        	if (JSON.stringify(formJson.BodyContext) != "{}" && formJson.BodyContext != undefined) {
                XFORM.multirow.load(JSON.stringify(formJson.BodyContext.tblExpenceInfo), 'json', '#tblExpenceInfo', 'W');
            }
        }
        
        $(".table_3").find("input[type=text]").not("#spend_date").css("border", "0px");
     
        //<!--loadMultiRow_Write-->
    	
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
        return EASY.check().result;
    }
}

function setBodyContext(sBodyContext) {
}

//본문 XML로 구성
function makeBodyContext() {
	var bodyContextObj = {};
	bodyContextObj["BodyContext"] = getFields("mField");
    $$(bodyContextObj["BodyContext"]).append(getMultiRowFields("tblExpenceInfo", "rField"));
    if(formJson.BodyContext.ERPKey != undefined) {
		$$(bodyContextObj["BodyContext"]).append("ERPKey", formJson.BodyContext.ERPKey);
    } 
    if(formJson.BodyContext.JSONBody != undefined) {
    	$$(bodyContextObj["BodyContext"]).append("JSONBody", formJson.BodyContext.JSONBody);
    } 
    if(formJson.BodyContext.PayDate != undefined) {
		$$(bodyContextObj["BodyContext"]).append("PayDate", formJson.BodyContext.PayDate);
    }
    return bodyContextObj;
}

function setData() {
	var jsonBody = null;
	var totalAmountKor = ""; 	//합계금액 한글 표시
	var totalSumNum = 0; 	//합계금액 숫자 표시
	var corpCardSum = 0;		//법인카드결제
	var autoSum = 0;			//자동이체
	var normalSum = 0;			//일반이체
	var cashSum = 0;			//현금인출
	var purchaseSum = 0;		//구매자금
	
	var spendingTypeName = {"CorpCard": "법인카드결제", "Auto": "자동이체", "Normal": "일반이체", "Cash": "현금인출", "Purchase": "구매자금"};
	
	var payDate = formJson.BodyContext.PayDate;
	$("#spend_date").val(payDate.substring(0, 4) + '-' + payDate.substring(4, 6) + '-' + payDate.substring(6));
	
	var len = Object.keys(formJson.BodyContext.JSONBody).length;
	for(var i = 0; i < len; i++) {
		jsonBody = formJson.BodyContext.JSONBody[Object.keys(formJson.BodyContext.JSONBody)[i]];

		if(i > 0) {
			$(".multi-row-add").trigger("click");
		}
		
		var spendingType = getPayMethod(jsonBody.ProofCode, jsonBody.PayMethod);
		var amount = jsonBody.AmountSumNum;
		if(jsonBody.ProofCode == "TaxBill" && jsonBody.TotalAmountNum != jsonBody.AmountSumNum) 
			amount = jsonBody.Amount * 1.1;
		
		$("tr.multi-row").eq(i).find("[name=spending_type]").val(spendingTypeName[spendingType]);
		$("tr.multi-row").eq(i).find("[name=standard_brief_name]").val(jsonBody.StandardBriefName);
		$("tr.multi-row").eq(i).find("[name=standard_brief_code]").val(jsonBody.StandardBriefID);
		/*$("tr.multi-row").eq(i).find("[name=register_name]").val(jsonBody.RegisterName);
		$("tr.multi-row").eq(i).find("[name=register_id]").val(jsonBody.RegisterID);
		$("tr.multi-row").eq(i).find("[name=application_title]").val(jsonBody.ApplicationTitle);*/
		$("tr.multi-row").eq(i).find("[name=usage_comment]").val(jsonBody.UsageComment);
		$("tr.multi-row").eq(i).find("[name=vendor_name]").val(jsonBody.VendorName);
		$("tr.multi-row").eq(i).find("[name=vendor_no]").val(jsonBody.VendorNo);
		$("tr.multi-row").eq(i).find("[name=total_amount]").val(amount);
		if(jsonBody.ProcessID != null && jsonBody.ProcessID != undefined && jsonBody.ProcessID != "") {
			$("tr.multi-row").eq(i).find("[name=process_id]").val(jsonBody.ProcessID);
		} else {
			$("tr.multi-row").eq(i).find("[name=apv_doc]").remove();
			$("tr.multi-row").eq(i).find("[name=process_id]").val("");
		}
		
		totalSumNum += Number(amount);
		switch(spendingType) {
		case "CorpCard":
			corpCardSum += Number(amount);
			break;
		case "Auto":
			autoSum += Number(amount);
			break;
		case "Normal":
			normalSum += Number(amount);
			break;
		case "Cash":
			cashSum += Number(amount);
			break;
		case "Purchase":
			purchaseSum += Number(amount);
			break;
		}
	}
	
	$("#total_amount_num").val(totalSumNum);
	$("#total_amount_sum").val(totalSumNum);
	$("#corpcard_sum").val(corpCardSum);
	$("#auto_sum").val(autoSum);
	$("#normal_sum").val(normalSum);
	$("#cash_sum").val(cashSum);
	$("#purchase_sum").val(purchaseSum);
	$("#total_sum").val(totalSumNum);
	$("#trLen").val(len);
}

function setReadData() {
	if(formJson.BodyContext.tblExpenceInfo != undefined && formJson.BodyContext.tblExpenceInfo.length > 0) {
		for(var i = 0; i < formJson.BodyContext.tblExpenceInfo.length; i++) {
			var processID = formJson.BodyContext.tblExpenceInfo[i].process_id;
			if(processID == '') {
				$("tr.multi-row").eq(i).find("[name=apv_doc]").remove();
			}
		}
	}
}

function getPayMethod(strProofCode, strPayMethod) {
	var returnValue = "";
	if(strProofCode == "CorpCard") {
		returnValue = "CorpCard";
	} else {
		switch(strPayMethod) {
		case "A":
			returnValue = "Auto";
			break;
		case "C":
			returnValue = "Normal";
			break;
		case "G":
			returnValue = "Cash";
			break;
		case "B":
			returnValue = "Purchase";
			break;
		case "D":
			returnValue = "CorpCard";
			break;
		default:
			returnValue = "Normal";
			break;
		}
	}
	
	return returnValue;
}

function apvLinkOpen(pObj) {
	var strProcessID = $(pObj).next().val();
	var url = document.location.protocol + "//" + document.location.host + "/approval/legacy/goFormLink.do";
	var form2 = document.createElement("form");
	form2.method = "POST";
	form2.target = "form2";
	form2.action = url;
	form2.style.display = "none";
	
	var processID = document.createElement("input");
	processID.type = "hidden";
	processID.name = "processID";
	processID.value = strProcessID;
	
	var logonId = document.createElement("input");
	logonId.type = "hidden";
	logonId.name = "logonId";
	logonId.value = Common.getSession("USERID");
	
	form2.appendChild(processID);
	form2.appendChild(logonId);
	
	document.body.appendChild(form2);
	
	window.open("", "form2", "toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=0,resizable=1,width=,height"+(window.screen.height - 100));
	form2.submit();
}

// 숫자 -> 한글 (사용안함)
function viewKorean(num) {
	var hanA = new Array("","일","이","삼","사","오","육","칠","팔","구","십"); 
	var danA = new Array("","십","백","천","","십","백","천","","십","백","천","","십","백","천"); 
	var result = "";
	for(var i=0; i<num.length; i++) {
		var str = ""; 
		var han = hanA[num.charAt(num.length-(i+1))]; 
		if(han != "") 
			str += han+danA[i]; 
		if(i == 4) 
			str += "만"; 
		if(i == 8) 
			str += "억"; 
		if(i == 12) 
			str += "조"; 
		result = str + result;
	} 
	return result ; 
}