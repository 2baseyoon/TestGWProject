<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
	<style>
		@media print {
			.bottom .btnTypeDefault { display:none; }
		}
	</style>
</head>

<body>
	<input id="searchProperty"	type="hidden" />
	<input id="receiptID"		type="hidden" />
	<input id="keyApproveNo"		type="hidden" />
	<div class="layer_divpop ui-draggable docPopLayer" id="testpopup_p" style="width:320px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
				<div class="middle">
					<div class="eaccounting_bill">
						<p class="card_number">
							<span id="cardNo"></span>
						</p>
						<div class="card_info01_wrap">
							<!-- 승인번호 -->
							<dl class="card_info">	<dt><spring:message code='Cache.ACC_lbl_confirmNum'/></dt>			<dd id="approveNo"></dd>			</dl>
							<!-- 거래일시 -->
							<dl class="card_info">	<dt><spring:message code='Cache.ACC_lbl_tradeDT'/></dt>				<dd id="useDate"></dd> <dd id="useTime"></dd>				</dl>
							<!-- 결제방법 -->
							<dl class="card_info">	<dt><spring:message code='Cache.ACC_lbl_payMethod'/></dt>			<dd id="noCol"></dd>				</dl>
							<!-- 가맹점명 -->
							<dl class="card_info">	<dt><spring:message code='Cache.ACC_lbl_franchiseCorpName'/></dt>	<dd id="storeName"></dd>			</dl>
							<!-- 가맹점번호 -->
							<dl class="card_info">	<dt><spring:message code='Cache.ACC_lbl_franchiseCorpNo'/></dt>		<dd id="storeNo"></dd>				</dl>
							<!-- 대표자명 -->
							<dl class="card_info">	<dt><spring:message code='Cache.ACC_lbl_storeRepresentative'/></dt>	<dd id="storeRepresentative"></dd>	</dl>
							<!-- 사업자등록번호 -->
							<dl class="card_info">	<dt><spring:message code='Cache.ACC_lbl_bizRegNo'/></dt>			<dd id="storeRegNo"></dd>			</dl>
							<!-- 전화번호 -->
							<dl class="card_info">	<dt><spring:message code='Cache.ACC_lbl_tel'/></dt>					<dd id="storeTel"></dd>				</dl>
							<!-- 주소 -->
							<dl class="card_info">	<dt><spring:message code='Cache.ACC_lbl_address'/></dt>				<dd id="storeAddress"></dd>			</dl>
						</div>
						<div class="card_info02_wrap">
							<!-- 금액 -->
							<dl class="card_info">	<dt><spring:message code='Cache.ACC_lbl_amt'/></dt>					<dd id="repAmount"></dd>			</dl>
							<!-- 부가세 -->
							<dl class="card_info">	<dt><spring:message code='Cache.ACC_lbl_taxType'/></dt>				<dd id="taxAmount"></dd>			</dl>
							<!-- 봉사료 -->
							<dl class="card_info">	<dt><spring:message code='Cache.ACC_lbl_serviceAmt'/></dt>			<dd id="serviceAmount"></dd>		</dl>
						</div>
						<div class="card_info03_wrap">
							<!-- 합계금액 -->
							<dl class="card_info">	<dt><spring:message code='Cache.ACC_lbl_totalAmount'/></dt>			<dd id="amountWon"></dd>			</dl>
						</div>
					</div>
				</div>
				<div class="bottom">
					<a onclick="CardReceiptPopup.printLayer()"	id="btnPrint"	class="btnTypeDefault"><spring:message code='Cache.lbl_Print'/></a>
					<a onclick="CardReceiptPopup.closeLayer()"	id="btnClose"	class="btnTypeDefault"><spring:message code='Cache.ACC_btn_close'/></a>
				</div>
			</div>
		</div>	
	</div>
</body>
<script>
	
	if (!window.CardReceiptPopup) {
		window.CardReceiptPopup = {};
	}

	(function(window) {
		var CardReceiptPopup = {
				popupInit : function() {
					var me = this;
					var param = location.search.substring(1).split('&');
					for(var i = 0; i < param.length; i++){
						var paramKey	= param[i].split('=')[0];
						var paramValue	= param[i].split('=')[1];
						$("#"+paramKey).val(paramValue);
					}
					
					setPropertySearchType('CardReceipt','searchProperty');
					
					me.getPopupInfo();
				},
				
				getPopupInfo : function(){
					var receiptID		= $("#receiptID").val();
					var approveNo		= $("#keyApproveNo").val();
					var searchProperty	= $("#searchProperty").val();
					
					$.ajax({
						url	:"/account/accountCommon/getCardReceiptPopupInfo.do?",
						type: "POST",
						data: {		"receiptID"			: receiptID
								,	"approveNo"			: approveNo
								,	"searchProperty"	: searchProperty
						},
						success:function (data) {
							if(data.status == "SUCCESS"){
								var info = data.list[0];
								var cardNoStr		= "<spring:message code='Cache.ACC_lbl_cardNumber' />" +'('+getCardNoValue(info.CardNo,'*')+')';
								var amountWonStr	= info.AmountWon + '('+info.InfoIndexName+')';
								var storeAddressStr	= info.StoreAddress1 + '\n' +info.StoreAddress2;
								
								$("#cardNo").text(cardNoStr);
								$("#approveNo").text(info.ApproveNo);
								$("#useDate").text(info.UseDate);
								$("#useTime").text(info.UseTime);
								$("#storeName").text(info.StoreName);
								$("#storeNo").text(info.StoreNo);
								$("#storeRepresentative").text(info.StoreRepresentative);
								$("#storeRegNo").text(info.StoreRegNo);
								$("#storeTel").text(info.StoreTel);
								$("#storeAddress").text(storeAddressStr);
								$("#repAmount").text(info.RepAmount);
								$("#taxAmount").text(info.TaxAmount);
								$("#serviceAmount").text(info.ServiceAmount);
								$("#amountWon").text(amountWonStr);
							}else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // data.message	
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // error.message
						}
					});
				},
				
				printLayer : function() {
					var isWindowed	= CFN_GetQueryString("CFN_OpenedWindow");
					
					if(isWindowed.toLowerCase() == "true") {
						window.print();
					}else{
						var popupID	= CFN_GetQueryString("popupID");
						var iframe = parent.window.frames[popupID+"_if"];
						if(iframe == undefined || iframe.length == 0 || iframe.contentWindow == undefined) {
							iframe = parent.$("#"+popupID+"_if")[0];
						}
						iframe.contentWindow.focus();
						iframe.contentWindow.print();
					}
					
				},
				
				closeLayer : function() {
					var isWindowed	= CFN_GetQueryString("CFN_OpenedWindow");
					var popupID		= CFN_GetQueryString("popupID");
					
					if(isWindowed.toLowerCase() == "true") {
						window.close();
					} else {
						parent.Common.close(popupID);
					}
				}
		}
		window.CardReceiptPopup = CardReceiptPopup;
	})(window);
	
	CardReceiptPopup.popupInit();
</script>