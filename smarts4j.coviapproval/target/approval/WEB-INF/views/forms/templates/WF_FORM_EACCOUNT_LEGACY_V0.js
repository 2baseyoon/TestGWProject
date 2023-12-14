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
     
        //<!--loadMultiRow_Write-->
    }

    setAmountSumByProof();
    setAmountSumByStandardBrief();
    
    //eliips로 인하여 내역 말줄임되는 현상 임시 수정
    $("span[name=colIOArea]").removeClass("eliips");
    
    // 선택된 담당업무함이 있는 경우.
    if(formJson.BodyContext.JSONBody.ChargeJob != undefined && formJson.BodyContext.JSONBody.ChargeJob != "") {
    	var ChargeJob = formJson.BodyContext.JSONBody.ChargeJob;
    	
    	if(formJson.BodyContext.JSONBody.ApplicationType == "EA") { //직원경비신청인 경우 ChargeJob 재설정 필요 - 본사 회계팀 커스텀 사항으로, 추후 제품 개발 시 제외 될 예정
    		var ChargeJobCode = ChargeJob.split("@")[0];
    		var ChargeJobName = "";
    		
    		if(ChargeJobCode.indexOf("NEW") > -1) {
    			ChargeJobCode = "JF_ACCOUNT_NEW";
    			ChargeJobName = "직원경비신청-회계팀";
    		} else if(ChargeJobCode.indexOf("INSA") > -1) {
    			ChargeJobCode = "JF_ACCOUNT_INSA";
    			ChargeJobName = "직원경비신청-인사팀";
    		}
    		
    		ChargeJob = ChargeJobCode + "@" + ChargeJobName;
    	}
    	
    	setInfo("SchemaContext.scChgr.value", ChargeJob);
    	
    	var m_oApvList = $.parseJSON(XFN_ChangeOutputValue(document.getElementById("APVLIST").value));
        var ApvLines = __setInlineApvList(m_oApvList);
        drawFormApvLinesAll(ApvLines);
    }
    
    $(".total_acooungting_wrap").before(
    		"<p style='float:right; padding:10px; font-size: 14px;'><strong>" 
    		+ Common.getDic("ACC_lbl_payDay") 
    		+ " : </strong><label>" + formJson.BodyContext.JSONBody.pageExpenceAppEvidList[0].PayDateStr + "</label>"
    );
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
    	if(formJson.Request.mode == "DRAFT") {
	    	var appStatus = getApplicationStatus();
	    	if(appStatus != "T") {
	    		Common.Warning(Common.getDic("ACC_msg_draftOnlyTempsave")); //비용신청 상태가 '임시저장'인 신청내역만 기안할 수 있습니다.
	    		return false;
	    	}
    	}
    	return true;
        //return EASY.check().result;
    }
}

//증빙 별 금액 합계 보여주기
function setAmountSumByProof() {
	var cntArr = [];
	var sHtml = '';
	sHtml += '<div style="margin-top: 20px;" id="divAmountSumByProof">';
	sHtml += '	<p class="taw_top_sub_title">' + Common.getDic("ACC_lbl_proofAmountSum") + '</p>'; //증빙 별 금액 합계
	sHtml += '	<table class="acstatus_wrap" cellpadding="0" cellspacing="0">';
	sHtml += '		<tr>';
	if($(".total_acooungting_info").length > 0) {
		$(".total_acooungting_info").find("dt").each(function(i, obj) { 
			sHtml += '<th>' + $(obj).text().split(" :")[0] + '</th>'; 
		});
	} else { //자동기안일 경우
		var proofCode = formJson.BodyContext.JSONBody.pageExpenceAppEvidList[0].ProofCode;
		if(proofCode == "Receipt") proofCode = "MobileReceipt";
		sHtml += '		<th>' + Common.getDic("ACC_lbl_" + proofCode.charAt(0).toLowerCase() + proofCode.slice(1)) + '</th>';
	}
	sHtml += '		</tr>';
	sHtml += '		<tr>';
	if($(".total_acooungting_info").length > 0) {
		$(".total_acooungting_info").find("dd").each(function(i, obj) { 
			if (i % 2 == 0) 
				sHtml += '<td style="text-align: right; padding-right: 5px;""><strong>' + $(obj).text() + '</strong></td>';
			else
				cntArr.push($(obj).text());
		});
	} else {
		var evidTotalAmount = 0;
		for(var i = 0; i < formJson.BodyContext.JSONBody.pageExpenceAppEvidList.length; i++) {
			evidTotalAmount += Number(formJson.BodyContext.JSONBody.pageExpenceAppEvidList[i].TotalAmount);
		}
		sHtml += '<td style="text-align: right; padding-right: 5px;""><strong>' + toAmtFormat(evidTotalAmount) + '</strong></td>';
	}
	sHtml += '		</tr>';
	sHtml += '	</table>';
	sHtml += '</div>';
	
	if($("div.total_acooungting_wrap").length > 0) {
		$("div.total_acooungting_wrap").css("margin-top", "20px");
		$("div.total_acooungting_wrap").after(sHtml);
	} else {
		$("#tblFormSubject").after(sHtml);
	}
	
	$("#divAmountSumByProof").find('th').each(function(i, obj) {
		if(cntArr[i] != undefined && cntArr[i] != "undefined") {
			$(obj).append(" " + cntArr[i]);
		}
	});
	
	$(".total_acooungting_info").hide();
}

// 표준적요 별 금액 합계 보여주기
function setAmountSumByStandardBrief() {
	var SBJson = {};
	
	var evidList = formJson.BodyContext.JSONBody.pageExpenceAppEvidList;
	for(var i = 0; i < evidList.length; i++) {
		var divList = evidList[i].divList;
		for(var j = 0; j < divList.length; j++) {
			var id = divList[j].StandardBriefName;
			if(SBJson[id] == undefined) {
				SBJson[id] = divList[j].Amount;
			} else {
				SBJson[id] = Number(SBJson[id]) + Number(divList[j].Amount);
			}
		}
	}
	
	//SBObj -> key, SBJson[SBObj] -> value
	var sHtml = '';
	sHtml += '<div style="margin-top: 20px;" id="divAmountSumByStandardBrief">';
	sHtml += '	<p class="taw_top_sub_title">' + Common.getDic("ACC_lbl_standardBriefAmountSum") + '</p>'; //표준적요 별 금액 합계
	sHtml += '	<table class="acstatus_wrap" cellpadding="0" cellspacing="0">';
	sHtml += '		<tr>';
	for(var SBObj in SBJson) {
	    if(SBJson.hasOwnProperty(SBObj)) {
	    	sHtml += '<th>' + SBObj + '</th>';
	    }
	}
	sHtml += '		</tr>';
	sHtml += '		<tr>';
	for(var SBObj in SBJson) {
	    if(SBJson.hasOwnProperty(SBObj)) {
	    	sHtml += '<td style="text-align: right; padding-right: 5px;"><strong>' + CFN_AddComma(SBJson[SBObj].toString()) + '</strong></td>';
	    }
	}
	sHtml += '		</tr>';
	sHtml += '	</table>';
	sHtml += '</div>';
	
	if($("#divAmountSumByProof").length > 0) {
		$("#divAmountSumByProof").after(sHtml);		
	} else if($("div.total_acooungting_wrap").length > 0) {
		$("div.total_acooungting_wrap").css("margin-top", "20px");
		$("div.total_acooungting_wrap").after(sHtml);
	} else {
		$("#tblFormSubject").after(sHtml);
	}
}
//formJson.BodyContext.JSONBody.pageExpenceAppEvidList[0].divList[0].StandardBriefID

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

function getApplicationStatus() {
	var expenceApplicationID = formJson.BodyContext.JSONBody.ExpenceApplicationID;
	var applicationStatus = "";
	CFN_CallAjax("/account/accountCommon/getApplicationStatus.do", {"expenceApplicationID":expenceApplicationID}, function (data){ 
		if(data.result == "ok") {
			applicationStatus = data.list.list[0].ApplicationStatus;
		}
	}, false, 'json');
	
	return applicationStatus;
	
}

var evidArr = [];
var pageCount = 1;
function evidPreviewEAccount(isPaging) {
	if($("#evidPreview").css("display") != "none" && isPaging == undefined) {
		$("#evidPreview").hide();
		$("#formBox").css('width', '');
		$("#e_IframePreview").attr('src', '');
		$("#e_previewVal").val('');
		
		var centerplaceWidth = (window.screen.width / 2) - 385;
		if (window.screen.width < 1550) {
			window.resizeTo(790, window.screen.height);
			window.moveTo(centerplaceWidth, 0);
		}
		else {
			window.resizeTo(790, window.screen.height);
		}
	} else {
		if($("#filePreview").css("display") != "none") {
			$("#filePreview").hide();
			/*$("#IframePreview").attr('src', '');
			$("#previewVal").val('');*/
		}
		if(evidArr.length == 0) {
			$(formJson.BodyContext.JSONBody.pageExpenceAppEvidList).each(function(i, evidList) {
				var proofCode = evidList.ProofCode;
				var expenceApplicationListID = evidList.ExpenceApplicationListID;
				
				if(proofCode == "CorpCard") {
					var tempObj = {};
					tempObj.ProofCode = proofCode;
					tempObj.ExpenceApplicationListID = expenceApplicationListID;
					tempObj.ReceiptID = evidList.CardUID;
					evidArr.push(tempObj);
					
				} else if(proofCode == "TaxBill") {
					var tempObj = {};
					tempObj.ProofCode = proofCode;
					tempObj.ExpenceApplicationListID = expenceApplicationListID;
					tempObj.ReceiptID = evidList.TaxUID;
					evidArr.push(tempObj);
					
				} else if(proofCode == "Receipt") {
					var tempObj = {};
					tempObj.ProofCode = proofCode;
					tempObj.ExpenceApplicationListID = expenceApplicationListID;
					tempObj.FileID = evidList.FileID;
					tempObj.FileExt = evidList.FileName.split('.')[evidList.FileName.split('.').length-1];
					evidArr.push(tempObj);					
				}
				
				$(evidList.fileList).each(function(j, fileList) {
					var tempObj = {};
					tempObj.ProofCode = proofCode;
					tempObj.ExpenceApplicationListID = expenceApplicationListID;
					tempObj.FileID = fileList.FileID;
					tempObj.FileExt = fileList.Extention;
					evidArr.push(tempObj);
				});
			});
			
			$("tr[name=evidItemAreaApv]").each(function(i, obj) {
				$(obj).mouseenter(function() {
					hoverEvidItemArea(i);
			    });
			});
		}
		
		if(evidArr.length == 0) {
			Common.Warning("미리보기할 증빙이 없습니다.");
			return;
		}
		
		switch(evidArr[pageCount-1].ProofCode) {
		case "CorpCard":
			$(".e_TitleText").text("법인카드 사용분");
			break;
		case "TaxBill":
			$(".e_TitleText").text("전자세금계산서 사용분");
			break;
		case "CashBill":
			$(".e_TitleText").text("현금영수증 사용분");
			break;
		case "PrivateCard":
			$(".e_TitleText").text("개인카드 사용분");
			break;
		case "EtcEvid":
			$(".e_TitleText").text("기타증빙 사용분");
			break;
		case "Receipt":
			$(".e_TitleText").text("모바일 영수증 사용분");
			break;
		}
		
		if(evidArr[pageCount-1].FileID != undefined) {
			$(".e_TitleText").append(" - 첨부 파일");
			$("#evidContent").hide();
			$("#fileContent").show();
			attachFilePreviewAccount(evidArr[pageCount-1].FileID, evidArr[pageCount-1].FileToken, evidArr[pageCount-1].FileExt);
		} else if(evidArr[pageCount-1].ReceiptID != undefined) {
			$(".e_TitleText").append(" - 상세 내역");
			$("#fileContent").hide();
			$("#evidContent").show();
			showEvidPreview(evidArr[pageCount-1].ProofCode, evidArr[pageCount-1].ReceiptID);
		}
		
		$("#previewTotalPage").text(evidArr.length);
		$("#previewCurrentPage").text(pageCount);
	}
}

function attachFilePreviewAccount(fileId, fileToken, extention) {
	extention = extention.toLowerCase();
	
	if (extention ==  "jpg" ||
			extention ==  "jpeg" ||
			extention ==  "png" ||
			extention ==  "tif" ||
			extention ==  "bmp" ||
			extention ==  "xls" ||
			extention ==  "xlsx" ||
			extention ==  "doc" ||
			extention ==  "docx" ||
			extention ==  "ppt" ||
			extention ==  "pptx" ||
			extention ==  "txt" ||
			extention ==  "pdf" ||
			extention ==  "hwp") {
		var url = Common.getBaseConfig("MobileDocConverterURL") + "?fileID=" + fileId + "&fileToken=" + encodeURIComponent(fileToken) ;
		if ($("#evidPreview").css('display') == 'none') {
			$("#evidPreview").show();
			$("#formBox").css('width', '790px');
			window.resizeTo(1550, window.screen.height);
			$("#e_IframePreview").attr('src', url);
			$("#e_previewVal").val(fileId);
		} else {
			$("#e_IframePreview").attr('src', url);
			$("#e_previewVal").val(fileId);
		}
	} else {
		alert("변환이 지원되지않는 형식입니다.");
		return false;
	}
}

function showEvidPreview(proofCode, receiptID) {
	if ($("#evidPreview").css('display') == 'none') {
		$("#evidPreview").show();
		$("#formBox").css('width', '790px');
		window.resizeTo(1550, window.screen.height);
	}
	
	var sHTML = "";
	if(proofCode == "CorpCard") {
		getCardReceiptInfo(receiptID, 'preview');
	} else if(proofCode == "TaxBill") {
		getTaxInvoiceInfo(receiptID, 'preview');
	}

	$("#hidReceiptID").val(receiptID);
}

function clickPaging(obj) {
	if($(obj).attr("class") == "pre") {
		if(pageCount > 1) {
			pageCount--;
		} else {
			Common.Warning("첫번째 증빙입니다.");
		}
	} else {
		if(pageCount < evidArr.length) {
			pageCount++;
		} else {
			Common.Warning("마지막 증빙입니다.");
		}
	}
	
	evidPreviewEAccount(true);
}

function getCardReceiptInfo(pReceiptID, mode) {
	var sHTML = "";
	$.ajax({
		url	:"/account/accountCommon/getCardReceiptPopupInfo.do?",
		type: "POST",
		async: false,
		data: {		
			"receiptID"			: pReceiptID
			, "approveNo"		: ""
			, "searchProperty"	: ""
		},
		success:function (data) {
			if(data.status == "SUCCESS"){
				var info = data.list[0];
				
				var cardNoStr		= Common.getDic("ACC_lbl_cardNumber") +'('+getCardNoValue(info.CardNo,'*')+')';
				var amountWonStr	= info.AmountWon + '('+info.InfoIndexName+')';
				var storeAddressStr	= info.StoreAddress1 + '\n' +info.StoreAddress2;
				
				sHTML += '<div class="eaccounting_bill">';
				sHTML += '	<p class="card_number"><span>' + cardNoStr + '</span></p>';
				sHTML += '	<div class="card_info01_wrap">';
				sHTML += '		<dl class="card_info">';
				sHTML += '			<dt>승인번호</dt>';
				sHTML += '			<dd>' + info.ApproveNo + '</dd>';
				sHTML += '		</dl>';
				sHTML += '		<dl class="card_info">';
				sHTML += '			<dt>거래일자</dt>';
				sHTML += '			<dd>' + info.UseDate + ' ' + info.UseTime + '</dd>';
				sHTML += '		</dl>';
				sHTML += '		<dl class="card_info">';
				sHTML += '			<dt>결제방법</dt>';
				sHTML += '			<dd>' + '</dd>';
				sHTML += '		</dl>';
				sHTML += '		<dl class="card_info">';
				sHTML += '			<dt>가맹점명</dt>';
				sHTML += '			<dd>' + info.StoreName + '</dd>';
				sHTML += '		</dl>';
				sHTML += '		<dl class="card_info">';
				sHTML += '			<dt>가맹점번호</dt>';
				sHTML += '			<dd>' + info.StoreNo + '</dd>';
				sHTML += '		</dl>';
				sHTML += '		<dl class="card_info">';
				sHTML += '			<dt>대표자명</dt>';
				sHTML += '			<dd>' + info.StoreRepresentative + '</dd>';
				sHTML += '		</dl>';
				sHTML += '		<dl class="card_info">';
				sHTML += '			<dt>사업자등록번호</dt>';
				sHTML += '			<dd>' + info.StoreRegNo + '</dd>';
				sHTML += '		</dl>';
				sHTML += '		<dl class="card_info">';
				sHTML += '			<dt>전화번호</dt>';
				sHTML += '			<dd>' + info.StoreTel + '</dd>';
				sHTML += '		</dl>';
				sHTML += '		<dl class="card_info">';
				sHTML += '			<dt>주소</dt>';
				sHTML += '			<dd>' + storeAddressStr + '</dd>';
				sHTML += '		</dl>';
				sHTML += '	</div>';
				sHTML += '	<div class="card_info02_wrap">';
				sHTML += '		<dl class="card_info">';
				sHTML += '			<dt>금액</dt>';
				sHTML += '			<dd>' + info.RepAmount + '</dd>';
				sHTML += '		</dl>';
				sHTML += '		<dl class="card_info">';
				sHTML += '			<dt>부가세</dt>';
				sHTML += '			<dd>' + info.TaxAmount + '</dd>';
				sHTML += '		</dl>';
				sHTML += '		<dl class="card_info">';
				sHTML += '			<dt>봉사료</dt>';
				sHTML += '			<dd>' + info.ServiceAmount + '</dd>';
				sHTML += '		</dl>';
				sHTML += '	</div>';
				sHTML += '	<div class="card_info02_wrap">';
				sHTML += '		<dl class="card_info">';
				sHTML += '			<dt>합계</dt>';
				sHTML += '			<dd>' + amountWonStr + '</dd>';
				sHTML += '		</dl>';
				sHTML += '	</div>';
				sHTML += '</div>';
				
				if(mode == 'preview') {
					$(".billW").html(sHTML);
					
					$(".invoice_wrap").hide();
					$(".billW").show();
				}
				
			}else{
				Common.Error(Common.getDic("ACC_msg_error")); // data.message	
			}
		},
		error:function (error){
			Common.Error(Common.getDic("ACC_msg_error")); // error.message
		}
	});
	
	if(mode == 'print') {
		return sHTML;
	}
}

function getTaxInvoiceInfo(pReceiptID, mode) {
	var sHTML = "";
	$.ajax({
		url	:"/account/accountCommon/getTaxInvoicePopupInfo.do?",
		type: "POST",
		async: false,
		data: {		
			"taxInvoiceID" : pReceiptID		
		},
		success:function (data) {
			if(data.status == "SUCCESS"){
				var info = data.list[0];
				
				sHTML += '<dl class="invoice_no"><dt>승인번호 :</dt><dd>' + getStr(info.NTSConfirmNum) + '</dd></dl>';
				sHTML += '<table class="invoice_table mb9">';
				sHTML += '	<tbody>';
				sHTML += '		<tr>';
				sHTML += '			<td class="t_tit" colspan="7"><p class="invoice_title">전자(세금)계산서<span class="invoice_sub">(공급받는자 보관용)</span></p></td>';
				sHTML += '			<td colspan="3" class="noPad">';
				sHTML += '				<table class="invoice_table_in">';
				sHTML += '					<tbody>';
				sHTML += '						<tr>';
				sHTML += '							<td width="90" class="t_tit">책번호</td>';
				sHTML += '							<td>권</td>';
				sHTML += '							<td>호</td>';
				sHTML += '						</tr>';
				sHTML += '						<tr>';
				sHTML += '							<td class="t_tit">일련번호</td>';
				sHTML += '							<td colspan="2">' + getStr(info.SerialNum) + '</td>';
				sHTML += '						</tr>';
				sHTML += '					</tbody>';
				sHTML += '				</table>';
				sHTML += '			</td>';
				sHTML += '		</tr>';
				sHTML += '		<tr>';
				sHTML += '			<td class="t_tit" rowspan="8" width="40">공급자</td>';
				sHTML += '			<td class="t_tit" width="90">등록번호</td>';
				sHTML += '			<td colspan="3">' + getStr(info.InvoicerCorpNum) + '</td>';
				sHTML += '			<td class="t_tit" rowspan="8" width="40">공급받는자</td>';
				sHTML += '			<td class="t_tit" width="90">등록번호</td>';
				sHTML += '			<td colspan="3">' + getStr(info.InvoiceeCorpNum) + '</td>';
				sHTML += '		</tr>';
				sHTML += '		<tr>';
				sHTML += '			<td class="t_tit">상호</td>';
				sHTML += '			<td width="140">' + getStr(info.InvoicerCorpName) + '</td>';
				sHTML += '			<td class="t_tit" width="90">성명</td>';
				sHTML += '			<td>' + getStr(info.InvoicerCEOName) + '</td>';
				sHTML += '			<td class="t_tit">상호</td>';
				sHTML += '			<td width="140">' + getStr(info.InvoiceeCorpName) + '</td>';
				sHTML += '			<td class="t_tit" width="90">성명</td>';
				sHTML += '			<td>' + getStr(info.InvoiceeCEOName) + '</td>';
				sHTML += '		</tr>';
				sHTML += '		<tr>';
				sHTML += '			<td class="t_tit">사업장주소</td>';
				sHTML += '			<td colspan="3">' + getStr(info.InvoicerAddr) + '</td>';
				sHTML += '			<td class="t_tit">사업장주소</td>';
				sHTML += '			<td colspan="3">' + getStr(info.InvoiceeAddr) + '</td>';
				sHTML += '		</tr>';
				sHTML += '		<tr>';
				sHTML += '			<td class="t_tit">업태</td>';
				sHTML += '			<td>' + getStr(info.InvoicerBizType) + '</td>';
				sHTML += '			<td class="t_tit" colspan="2">총사업장번호</td>';
				sHTML += '			<td class="t_tit">업태</td>';
				sHTML += '			<td>' + getStr(info.InvoiceeBizType) + '</td>';
				sHTML += '			<td class="t_tit" colspan="2">총사업장번호</td>';
				sHTML += '		</tr>';
				sHTML += '		<tr>';
				sHTML += '			<td class="t_tit">종목</td>';
				sHTML += '			<td width="140">' + getStr(info.InvoicerBizClass) + '</td>';
				sHTML += '			<td colspan="2"' + getStr(info.InvoicerTaxRegID) + '></td>';
				sHTML += '			<td class="t_tit">종목</td>';
				sHTML += '			<td width="140">' + getStr(info.InvoiceeBizClass) + '</td>';
				sHTML += '			<td colspan="2">' + getStr(info.InvoiceeTaxRegID) + '</td>';
				sHTML += '		</tr>';
				sHTML += '		<tr>';
				sHTML += '			<td class="t_tit">부서명</td>';
				sHTML += '			<td>' + getStr(info.InvoicerDeptName) + '</td>';
				sHTML += '			<td class="t_tit">담당자</td>';
				sHTML += '			<td>' + getStr(info.InvoicerContactName) + '</td>';
				sHTML += '			<td class="t_tit">부서명</td>';
				sHTML += '			<td>' + getStr(info.InvoiceeDeptName1) + '</td>';
				sHTML += '			<td class="t_tit">담당자</td>';
				sHTML += '			<td>' + getStr(info.InvoiceeContactName1) + '</td>';
				sHTML += '		</tr>';
				sHTML += '		<tr>';
				sHTML += '			<td class="t_tit">연락처</td>';
				sHTML += '			<td>' + getStr(info.InvoicerTel) + '</td>';
				sHTML += '			<td class="t_tit">휴대폰</td>';
				sHTML += '			<td></td>';
				sHTML += '			<td class="t_tit">연락처</td>';
				sHTML += '			<td>' + getStr(info.InvoiceeTel1) + '</td>';
				sHTML += '			<td class="t_tit">휴대폰</td>';
				sHTML += '			<td></td>';
				sHTML += '		</tr>';
				sHTML += '		<tr>';
				sHTML += '			<td class="t_tit">E-Mail</td>';
				sHTML += '			<td colspan="3">' + getStr(info.InvoicerEmail) + '</td>';
				sHTML += '			<td class="t_tit">E-Mail</td>';
				sHTML += '			<td colspan="3">' + getStr(info.InvoiceeEmail1) + '</td>';
				sHTML += '		</tr>';
				sHTML += '	</tbody>';
				sHTML += '</table>';
				sHTML += '<table class="invoice_table mb9">';
				sHTML += '	<tbody>';
				sHTML += '		<tr>';
				sHTML += '			<td class="t_tit" width="300">작성일자</td>';
				sHTML += '			<td class="t_tit" width="300">공급가액</td>';
				sHTML += '			<td class="t_tit">세액</td>';
				sHTML += '		</tr>';
				sHTML += '		<tr>';
				sHTML += '			<td><span>'+ getStr(info.WriteDate1) + '</span><span>'+ getStr(info.WriteDate2) + '</span><span>'+ getStr(info.WriteDate3) + '</span></td>';
				sHTML += '			<td style="text-align: right;">' + getStr(info.SupplyCostTotal) + '</td>';
				sHTML += '			<td class="t_tit" style="text-align: right;">' + getStr(info.TaxTotal) + '</td>';
				sHTML += '		</tr>';
				sHTML += '	</tbody>';
				sHTML += '</table>';
				sHTML += '<table class="invoice_table mb9">';
				sHTML += '	<tbody>';
				sHTML += '		<tr>';
				sHTML += '			<td class="t_tit" width="130">비고</td>';
				sHTML += '			<td>' + getStr(info.Remark1) + '</td>';
				sHTML += '		</tr>';
				sHTML += '	</tbody>';
				sHTML += '</table>';
				sHTML += '<table class="invoice_table"><tbody id="invoice_table_info"></tbody></table>';
				sHTML += '<table class="invoice_table mb0"><tbody id="invoice_table_info_sum"></tbody></table>';
				
				$(".invoice_wrap").html(sHTML);
				
				var appendStr		= "";
				var appendStrHeader	= "";
				var appendStrBody	= "";
				var appendStrBottom	= "";
			
				appendStrHeader	+=	"<tr>"
								+		"<td class='t_tit' width='65'>"+Common.getDic("ACC_lbl_month")+"</td>"//월
								+		"<td class='t_tit' width='65'>"+Common.getDic("ACC_lbl_day")+"</td>"//일
								+		"<td class='t_tit'>"+Common.getDic("ACC_lbl_item")+"</td>"//품목명
								+		"<td class='t_tit' width='78'>"+Common.getDic("ACC_lbl_standardName")+"</td>"//규격
								+		"<td class='t_tit' width='78'>"+Common.getDic("ACC_lbl_quantity")+"</td>"//수량
								+		"<td class='t_tit' width='78'>"+Common.getDic("ACC_lbl_unitPrice")+"</td>"//단가
								+		"<td class='t_tit' width='100'>"+Common.getDic("ACC_lbl_supplyCost")+"</td>"//공급액
								+		"<td class='t_tit' width='100'>"+Common.getDic("ACC_lbl_taxValue")+"</td>"//세액
								+		"<td class='t_tit' width='100'>"+Common.getDic("ACC_lbl_description")+"</td>"//비고
								+	"</tr>";
				
				if(getNum(info.TaxInvoiceItemCnt) > 0){
					var list = data.list;
					for(var i=0; i<list.length; i++){
						appendStrBody	+=	"<tr>"
										+		"<td>"
										+			"<span id='PurchaseMM_"+i+"'>"	+ getStr(list[i].PurchaseMM)	+ "</span>"
										+		"</td>"
										+		"<td>"
										+			"<span id='PurchaseDD_"+i+"'>"	+ getStr(list[i].PurchaseDD)	+ "</span>"
										+		"</td>"
										+		"<td>"
										+			"<span id='ItemName_"+i+"'>"	+ getStr(list[i].ItemName)		+ "</span>"
										+		"</td>"
										+		"<td>"
										+			"<span id='Spec_"+i+"'>"		+ getStr(list[i].Spec)			+ "</span>"
										+		"</td>"
										+		"<td style='text-align: right;'>"
										+			"<span id='Qty_"+i+"'>"			+ getStr(list[i].Qty)			+ "</span>"
										+		"</td>"
										+		"<td style='text-align: right;'>"
										+			"<span id='UnitCost_"+i+"'>"	+ getStr(list[i].UnitCost)		+ "</span>"
										+		"</td>"
										+		"<td style='text-align: right;'>"
										+			"<span id='SupplyCost_"+i+"'>"	+ getStr(list[i].SupplyCost)	+ "</span>"
										+		"</td>"
										+		"<td style='text-align: right;'>"
										+			"<span id='Tax_"+i+"'>"			+ getStr(list[i].Tax)			+ "</span>"
										+		"</td>"
										+		"<td>"
										+			"<span id='Remark_"+i+"'>"		+ getStr(list[i].Remark)		+ "</span>"
										+		"</td>"
										+	"</tr>";
					}
				}

				var payMsg = Common.getDic("ACC_lbl_payBill"); //이 금액을 청구 함
				if(info.PurposeType=="01"){
					payMsg = Common.getDic("ACC_lbl_payBill2"); //이 금액을 영수 함
				}
				appendStrBottom	+=	"<tr>"
								+		"<td class='t_tit' width='130'>"+Common.getDic("ACC_lbl_totalAmount")+"</td>"//합계금액
								+		"<td class='t_tit' width='122'>"+Common.getDic("ACC_lbl_cash")+"</td>"//현금
								+		"<td class='t_tit'>"+Common.getDic("ACC_lbl_check")+"</td>" //수표
								+		"<td class='t_tit' width='117'>"+Common.getDic("ACC_lbl_etc_1")+"</td>"//어름
								+		"<td class='t_tit' width='117'>"+Common.getDic("ACC_lbl_payAble")+"</td>"//외상미수금
								+		"<td rowspan='2' width='300'>"
								+			"<p class='invoice_text'>"
								+				payMsg
								+			"</p>"
								+		"</td>"
								+	"</tr>"
								+	"<tr>"
								+		"<td style='text-align: right;'>"
								+			"<span id='totalAmount'>"	+ getStr(info.TotalAmount)	+ "</span>"
								+		"</td>"
								+		"<td style='text-align: right;'>"
								+			"<span id='cash'>"			+ getStr(info.Cash) 		+ "</span>"
								+		"</td>"
								+		"<td style='text-align: right;'>"
								+			"<span id='chkBill'>"		+ getStr(info.ChkBill)		+ "</span>"
								+		"</td>"
								+		"<td style='text-align: right;'>"
								+			"<span id='note'>"			+ getStr(info.Note)			+ "</span>"
								+		"</td>"
								+		"<td style='text-align: right;'>"
								+			"<span id='credit'>"		+ getStr(info.Credit)		+ "</span>"
								+		"</td>"
								+	"</tr>";
			
				if(getNum(info.TaxInvoiceItemCnt) > 0){
					appendStr	= appendStrHeader
								+ appendStrBody;
					$("#invoice_table_info").append(appendStr);
					
					appendStr	= appendStrBottom;
					$("#invoice_table_info_sum").append(appendStr);
				}

				if(mode == 'preview') {
					$(".billW").hide();
					$(".invoice_wrap").show();
				}
				
			}else{
				Common.Error(Common.getDic("ACC_msg_error")); // data.message	
			}
		},
		error:function (error){
			Common.Error(Common.getDic("ACC_msg_error")); // error.message
		}
	});
	
	if(mode == 'print') {
		return "<div class='invoice_wrap' style='width:910px;'>" + $(".invoice_wrap").html() + "</div>";
	}
	
}

function hoverEvidItemArea(index) {
	if($("#evidPreview").css('display') != 'none') {
		var expenceApplicationListID = formJson.BodyContext.JSONBody.pageExpenceAppEvidList[index].ExpenceApplicationListID;
		for(var i = 0; i < evidArr.length; i++) {
			if(evidArr[i].ExpenceApplicationListID == expenceApplicationListID) { 
				pageCount = i+1;
				break;
			}
		}
		
		evidPreviewEAccount(true);	
	}
}

function getStr(key){
	var rtValue = "";
	if(key == null || key == 'undefined'){
		rtValue = "";
	}else{
		rtValue = key;
	}
	return rtValue
}

function getNum(key) {
	var reg	= /^[0-9]+$/;	
	return reg.test(key) ? key : 0;
}

//금액, 찍기
function toAmtFormat(val) {
	var retVal = "";
	if(val != null){
		if(val.toString != null){
			retVal = val.toString();
			if(!isNaN(retVal.replace(/,/gi, ""))){
				var splitVal = retVal.split(".");
				if(splitVal.length==2){
					retVal = splitVal[0].replace(/(\d)(?=(?:\d{3})+(?!\d))/g,'$1,');
					retVal = retVal +"."+ splitVal[1];
				}
				else if(splitVal.length==1){
					retVal = splitVal[0].replace(/(\d)(?=(?:\d{3})+(?!\d))/g,'$1,');
				}else{
					retVal = "";
				}
			}
		}
	}
	//	str.replace(/[^\d]+/g,'')
	return retVal
}

//,찍힌값 되돌리기
function AmttoNumFormat(val) {
	var retVal = "";
	if(val != null){
		if(val.toString != null){
			retVal = val.toString();
			//retVal = retVal.replace(/[^\d]+/g,'');
			retVal = retVal.replace(/,/gi, '');
		}
	}
	return retVal
}

//증빙 인쇄
function getEvidHTMLEAccount() {
	var corpCardHtml = "";
	var taxBillHtml = "";
	
	var corpCardList = [];
	var taxBillList = [];
	$(formJson.BodyContext.JSONBody.pageExpenceAppEvidList).each(function(i, obj) {
	    if(obj.ProofCode == "CorpCard") {
	        corpCardList.push(obj);
	    } else if(obj.ProofCode == "TaxBill") { 
	    	taxBillList.push(obj);
	    }
	});
	
	$(corpCardList).each(function(i, obj) {
		if(i % 4 == 0) {
			corpCardHtml += "<div style='height: 100%;'>";
		}
		corpCardHtml += accComm.getCardReceiptInfo(obj.CardUID, 'print');
		if(i % 4 == 3) {
			corpCardHtml += "</div>";
		}
	});
	if(corpCardList.length % 4 != 0) {
		corpCardHtml += "</div>";
	}
	
	$(taxBillList).each(function(i, obj) {
		if(i % 2 == 0) {
			taxBillHtml += "<div style='height: 100%;'>";
		}
		taxBillHtml += accComm.getTaxInvoiceInfo(obj.TaxUID, 'print');
		if(i % 2 == 1) {
			taxBillHtml += "</div>";
		}
	});
	if(taxBillList.length % 2 != 0) {
		taxBillHtml += "</div>";
	}	
	
	return corpCardHtml + taxBillHtml;
}

if (!window.CombineCostApplicationView) {
	window.CombineCostApplicationView = {};
}
if (!window.CombineCostApplication) {
	window.CombineCostApplication = {};
}
if (!window.ExpenceApplication) {
	window.ExpenceApplication = {};
}
if (!window.ExpenceApplicationManage) {
	window.ExpenceApplicationManage = {};
}
if (!window.ExpenceApplicationManageUser) {
	window.ExpenceApplicationManageUser = {};
}
if (!window.SimpleCorpCardApplication) {
	window.SimpleCorpCardApplication = {};
}

(function(window) {
	var CostApplicationView = {
			pageOpenerIDStr : "openerID=CombineCostApplicationView&",

			// 첨부파일 다운로드 (accountFileCommon.js의 downloadFile 함수와 내용 동일)
			expApp_FileDownload : function(SavedName, FileName, FileID){
				this.combiCostAppView_FileDownload(SavedName, FileName, FileID);
			},
			combiCostApp_FileDownload : function(SavedName, FileName, FileID){
				this.combiCostAppView_FileDownload(SavedName, FileName, FileID);
			},
			combiCostAppView_FileDownload : function(SavedName, FileName, FileID){
				var me = this;
				var alframe = null;
				
				if($("[name=fileFrame]").length>0) {
					alframe = $("[name=fileFrame]")[0];
				} else {
					alframe = document.createElement("iframe");
				}
				
				alframe.setAttribute("name", "fileFrame");
				alframe.style.width="1px";
				alframe.style.height="1px";
				var seturl=String.format('/account/EAccountFileCon/doDownloadFiles.do?' +
						'savedFileName={0}&fileName={1}&fileId={2}',
						encodeURIComponent(encodeURIComponent(SavedName)), 
						encodeURIComponent(encodeURIComponent(FileName)),
						FileID)
				alframe.src= seturl;
				document.getElementsByTagName("body")[0].appendChild(alframe);
			},
			
			//연결문서 open
			expApp_LinkOpen : function(ProcessId, forminstanceID){
				this.combiCostAppView_LinkOpen(ProcessId, forminstanceID);
			},
			expAppMan_LinkOpen : function(ProcessId){
				this.combiCostAppView_LinkOpen(ProcessId, "");
			},
			expAppManUser_LinkOpen : function(ProcessId){
				this.combiCostAppView_LinkOpen(ProcessId, "");
			},
			combiCostApp_LinkOpen : function(ProcessId, forminstanceID){
				this.combiCostAppView_LinkOpen(ProcessId, forminstanceID);
			},
			combiCostAppView_LinkOpen : function(ProcessId, forminstanceID){
				var FormUrl = document.location.protocol + "//" + document.location.host + "/approval/approval_Form.do";
				
				var sParam;
				if(typeof forminstanceID == "undefined" || forminstanceID == "undefined") {
					sParam = "&archived=true";
				} else {
					sParam = forminstanceID;
				}
				
				CFN_OpenWindow(FormUrl + '?mode=COMPLETE&processID='+ProcessId+"&forminstanceID="+sParam,'',790, 998, 'scroll');
			},
			
			//카드 영수증 open
			combiCostApp_onCardAppClick  : function(ReceiptID){

				var me = this;
				var popupID		=	"cardReceiptPopup";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_cardReceiptInvoice'/>";
				var popupName	=	"CardReceiptPopup";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	"receiptID="	+	ReceiptID	+	"&"
								+	me.pageOpenerIDStr
								+	"includeAccount=N&";
								
				Common.open(	"",popupID,popupTit,url,"320px","500px","iframe",true,null,null,true);
				
				setTimeout(function() { $("#cardReceiptPopup_p").attr("tabindex", "1").focus(); }, 300);
			},
			
			//전자세금계산서 open
			combiCostApp_onTaxBillAppClick  : function(TaxInvoiceID){

				var me = this;

				var popupID		=	"taxInvoicePopup";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_taxInvoiceCash'/>";
				var popupName	=	"TaxInvoicePopup";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	"taxInvoiceID="	+	TaxInvoiceID	+	"&"
								+	me.pageOpenerIDStr
								+	"includeAccount=N&";
				Common.open(	"",popupID,popupTit,url,"1000px","600px","iframe",true,null,null,true);
				
				setTimeout(function() { $("#taxInvoicePopup_p").attr("tabindex", "1").focus(); }, 300);
			},
			
			//모바일 영수증 이미지 팝업 open
			expApp_MobileAppClick : function(FileID, btnObj){
				this.comCostAppView_MobileAppClick(FileID, btnObj);
			},
			combiCostApp_MobileAppClick : function(FileID, btnObj){
				this.comCostAppView_MobileAppClick(FileID, btnObj);
			},
			comCostAppView_MobileAppClick : function(FileID){
				var me = this;
				
				var popupID		=	"fileViewPopup";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_receiptPopup'/>";	//영수증 보기
				var popupName	=	"FileViewPopup";
				var callBack	=	"comCostAppView_ZoomMobileAppClick";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	"fileID="	+	FileID	+	"&"
								+	me.pageOpenerIDStr
								+	"includeAccount=N&"
								+	"callBackFunc="	+	callBack;
				Common.open(	"",popupID,popupTit,url,"490px","700px","iframe",true,null,null,true);
				
				setTimeout(function() { $("#fileViewPopup_p").attr("tabindex", "1").focus(); }, 300);
			},
			
			comCostAppView_ZoomMobileAppClick : function(info){
				var me = this;
				
				var popupID		=	"fileViewPopupZoom";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_receiptPopup'/>";	//영수증 보기
				var popupName	=	"FileViewPopup";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	"fileID="		+	info.FileID	+	"&"						
								+	me.pageOpenerIDStr				+	"&"		
								+	"zoom="			+	"Y";
				Common.open(	"",popupID,popupTit,url,"490px","700px","iframe",true,null,null,true);
				
				setTimeout(function() { $("#fileViewPopupZoom_p").attr("tabindex", "1").focus(); }, 300);
			}
	}
	
	window.CombineCostApplicationView = CostApplicationView;
	window.CombineCostApplication = CostApplicationView;
	window.ExpenceApplication = CostApplicationView;
	window.ExpenceApplicationManage = CostApplicationView;
	window.ExpenceApplicationManageUser = CostApplicationView;
	window.SimpleCorpCardApplication = CostApplicationView;
})(window);