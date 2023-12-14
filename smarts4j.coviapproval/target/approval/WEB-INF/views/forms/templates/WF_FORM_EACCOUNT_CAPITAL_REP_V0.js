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
    	$("[data-pattern=currency]").parent().css("text-align","right");
    }
    else {
        $('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });
        
        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {

            document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
            document.getElementById("InitiatorCodeDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usid"), false);
            document.getElementById("InitiatedDate").value = getInfo("AppInfo.svdt");
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
     
        //<!--loadMultiRow_Write-->

        $(".table_3").find("input[type=text]").css("border", "0px");
        
    	EASY.init();
    }

    $("input[type=button][name=apv_doc]").val("결재문서 보기");
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
	$$(bodyContextObj["BodyContext"]).append("Subject", document.getElementById("Subject").value); 
    return bodyContextObj;
}

function setData() {
	var dataObj = null;
	
	var totalSum = 0; 			//합계금액
	var corpCardSum = 0;		//법인카드
	var autoSum = 0;			//자동이체
	var normalSum = 0;			//일반이체
	var cashSum = 0;			//현금인출

	var realPayDate = CFN_GetQueryString("realPayDate");
	var standardBriefID = CFN_GetQueryString("standardBriefID");
	var expAppListIDs = CFN_GetQueryString("expAppListIDs");
	var companyCode = CFN_GetQueryString("companyCode");
	
	//BodyContext에 넣기 위해 hidden 값으로 저장
	document.getElementById("RealPayDate").value = realPayDate;
	document.getElementById("StandardBriefID").value = standardBriefID;
	document.getElementById("expAppListIDs").value = expAppListIDs;
	document.getElementById("CompanyCode").value = companyCode; 
	
	$.ajax({
		type:"POST",
		url:"/account/expenceApplication/getCapitalSpendingList.do",
		data:{
			"realPayDate"		: realPayDate,
			"standardBriefID"	: standardBriefID,
			"expAppListIDs"		: expAppListIDs,
			"companyCode"		: companyCode
		},
		success:function (data) {
			if(data.result == "ok"){
				if(data.list.length > 0) {									
					var dataList = data.list;
					
					if(realPayDate == "") {
						realPayDate = dataList[0].RealPayDate.replace(/\./gi, '');
						document.getElementById("RealPayDate").value = realPayDate;
					}
					if(standardBriefID == "") {
						standardBriefID = dataList[0].StandardBriefID;
						document.getElementById("StandardBriefID").value = standardBriefID;
					}
					if(expAppListIDs == "") {
						for(var i = 0 ; i < dataList.length; i++) {
							expAppListIDs += dataList[i].ExpenceApplicationListID + ",";
						}
						expAppListIDs = expAppListIDs.slice(0,-1);
						 
						document.getElementById("expAppListIDs").value = expAppListIDs;
					}
					
					for(var i = 0; i < dataList.length; i++) {
						var dataObj = dataList[i];

						if(i > 0) {
							$(".multi-row-add").trigger("click");
						} else {
							$("#real_pay_date").val(dataObj.RealPayDate);
						}
						
						/*
						var amount = dataObj.RealPayAmount;
						if(dataObj.ProofCode == "TaxBill" && dataObj.TotalAmount != dataObj.RealPayAmount) 
							amount = dataObj.RealPayAmount * 1.1;
						*/
						
						var amount = dataObj.Amount;
						if(dataObj.ProofCode == "TaxBill" && dataObj.TotalAmount != dataObj.Amount) {
							if(amount > 0) {
								amount = Math.floor(dataObj.Amount * 1.1);						
							} else {
								amount = Math.ceil(dataObj.Amount * 1.1);
							}
						}
						
						var payMethod = dataObj.PayMethod;
						if(dataObj.PayMethod == null || dataObj.PayMethod == '') {
							payMethod = "C";
						} 
						
						var payMethodName = dataObj.PayMethodName;
						if(payMethod == "C" && (dataObj.PayMethodName == null || dataObj.PayMethodName == '')) {
							payMethodName = '일반이체';
						}
						
						$("tr.multi-row").eq(i).find("[name=pay_method_name]").val(payMethodName);
						$("tr.multi-row").eq(i).find("[name=pay_method_code]").val(payMethod);
						$("tr.multi-row").eq(i).find("[name=standard_brief_name]").val(dataObj.StandardBriefName);
						$("tr.multi-row").eq(i).find("[name=standard_brief_code]").val(dataObj.StandardBriefID);
						$("tr.multi-row").eq(i).find("[name=usage_comment]").val(dataObj.UsageComment);
						$("tr.multi-row").eq(i).find("[name=vendor_name]").val(dataObj.VendorName);
						$("tr.multi-row").eq(i).find("[name=vendor_no]").val(dataObj.VendorNo);
						$("tr.multi-row").eq(i).find("[name=total_amount]").val(amount);
						
						if(dataObj.ProcessID != undefined && dataObj.ProcessID != "") {
							$("tr.multi-row").eq(i).find("[name=process_id]").val(dataObj.ProcessID);
						} else {
							$("tr.multi-row").eq(i).find("[name=apv_doc]").remove();
							$("tr.multi-row").eq(i).find("[name=process_id]").val("");
						}
						
						$("tr.multi-row").eq(i).find("[name=exp_app_id]").val(dataObj.ExpenceApplicationID);
						
						totalSum += Number(amount);
						
						switch(payMethod) {
						case "D": //법인카드
							corpCardSum += Number(amount);
							break;
						case "A": //자동이체
							autoSum += Number(amount);
							break;
						case "C": //일반이체
							normalSum += Number(amount);
							break;
						case "G": //현금인출
							cashSum += Number(amount);
							break;
						default: //값이 없을 경우 일반이체에 sum
							normalSum += Number(amount);
							break;
						}
					}
					
					$("#total_amount_sum").val(totalSum); //지출총계
					
					$("#corpcard_sum").val(corpCardSum);
					$("#auto_sum").val(autoSum);
					$("#normal_sum").val(normalSum);
					$("#cash_sum").val(cashSum);
					$("#total_sum").val(totalSum);
					
					$("#trLen").val(data.list.length);
					
					$("#TotalPayAmount").val(totalSum);
					$("#total_pay_amount").val(totalSum); //합계금액
					
				} else {
					Common.Warning("<spring:message code='Cache.ACC_msg_noDataCapitalSpending' />", "Warning", function() { window.close(); }); //입력하신 자금집행일에 해당하는 자금지출 대상 내역이 없습니다.
				}
			} 
		},
		error:function (error){
			Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
		}
	});
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
	// 이체용 엑셀파일 다운로드
	if(document.getElementById("expAppListIDs")){
		var _expAppListIDs = document.getElementById("expAppListIDs").value;
		var $lastBtn = $("input[type=button]", "div.topWrap").last();
		var $btn = $("<input id='btEATransferDown' type='button' class='AXButton' name='cbBTN'/>");
		$lastBtn.after($btn);
		$btn.val(" 대량이체 엑셀다운 ").on("click", function(ev){
			fnAccountTransferDataDown(_expAppListIDs);
		});
	}
}
// expListIDs 기준으로 이체데이터 엑셀다운로드
function fnAccountTransferDataDown(_expAppListIDs){
	
	var headerName = ["입금은행", "입금계좌번호", "이체금액", "수취인(예금주명)", "사업자번호", "CMS코드", "받는분 통장표시내용", "내부메모"];
	var headerKey = ["BankName", "BankAccountNo", "TotalAmount", "BankAccountName"];
	var headerType = ["", "", "Numeric", "", "", "", "", ""];
	
	location.href = "/account/accountPortal/reportTransferExcelDownload.do?"
		+ "headerName="	 + encodeURIComponent(headerName.join("†"))
		+ "&headerKey="	 + encodeURIComponent(headerKey.join(","))
		+ "&headerType=" + encodeURIComponent(headerType.join("|"))
		+ "&expListIDs=" + encodeURIComponent(_expAppListIDs)
		+ "&title=" + encodeURIComponent("대량이체목록");
}
function apvLinkOpen(pObj) {
	var strProcessID = $(pObj).siblings("[name=process_id]").val();
	var strExpAppID = $(pObj).siblings("[name=exp_app_id]").val();

	CFN_OpenWindow("/account/expenceApplication/ExpenceApplicationViewPopup.do"
			+"?processID="+strProcessID
			+"&ExpAppID="+strExpAppID, "", 1070, (window.screen.height - 100), "resize");
}