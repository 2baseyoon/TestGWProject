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
	<input id="taxInvoiceID"	type="hidden" />
	<div class="layer_divpop ui-draggable docPopLayer" style="width:910px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
				<div class="wrap">
					<div class="invoice_wrap" style="width:910px">
						<dl class="invoice_no">
							<!-- 승인번호 -->
							<dt><spring:message code='Cache.ACC_lbl_confirmNum'/> : </dt>
							<dd id='nTSConfirmNum'></dd>
						</dl>
						<table class="invoice_table mb9">
							<colgroup>
								<col style="width: 40px">
								<col style="width: 90px">
								<col style="width: 150px">
								<col style="width: 80px">
								<col style="width: 80px">
								<col style="width: 40px">
								<col style="width: 90px">
								<col style="width: 150px">
								<col style="width: 80px">
								<col style="width: 80px">
							</colgroup>
							<tbody>
								<tr>
									<td class="t_tit" colspan="7">
										<p class="invoice_title">
											<!-- 전자세금계산서 -->
											<%-- <spring:message code='Cache.ACC_lbl_taxInvoiceCash'/> --%>
											<!-- 공급받는자 보관용 -->
											<span class="invoice_sub"><spring:message code='Cache.ACC_lbl_invoiceSub'/></span>
										</p>
									</td>
									<td class="noPad" colspan="3">
										<table class="invoice_table_in">
											<tbody>
												<tr> 
													<!-- 책번호 -->
													<td class="t_tit"><spring:message code='Cache.ACC_lbl_bNo'/></td>
													<!-- 권 -->
													<td><spring:message code='Cache.ACC_lbl_volume'/></td>
													<!-- 호 -->
													<td><spring:message code='Cache.ACC_lbl_aNo'/></td>
												</tr>
												<tr> 
													<td class="t_tit"><spring:message code='Cache.ACC_lbl_serialNum'/></td>
													<td colspan="2">
														<span id='serialNum'></span>												
													</td>
												</tr>
											</tbody>
										</table>
									</td>
								</tr>
								<tr>
									<!-- 공급자 -->
									<td class="t_tit" rowspan="9"><spring:message code='Cache.ACC_lbl_provider'/></td>
									<!-- 등록번호 -->
									<td class="t_tit"><spring:message code='Cache.ACC_lbl_vendorRegistNumber'/></td>
									<td colspan="3">
										<span id='invoicerCorpNum'></span>
									</td>
									<!-- 공급받는자 -->
									<td class="t_tit" rowspan="9"><spring:message code='Cache.ACC_lbl_invoiceUser'/></td>
									<!-- 등록번호 -->
									<td class="t_tit"><spring:message code='Cache.ACC_lbl_vendorRegistNumber'/></td>
									<td colspan="3">
										<span id='invoiceeCorpNum'></span>
									</td>
								</tr>
								<tr>
									<!-- 상호 -->
									<td class="t_tit"><spring:message code='Cache.ACC_lbl_corpName'/></td>
									<td>
										<span id='invoicerCorpName'></span>
									</td>
									<!-- 성명 -->
									<td class="t_tit"><spring:message code='Cache.ACC_lbl_displayName'/></td>
									<td>
										<span id='invoicerCEOName'></span>
									</td>
									<td class="t_tit"><spring:message code='Cache.ACC_lbl_corpName'/></td>
									<td>
										<span id='invoiceeCorpName'></span>
									</td>
									<td class="t_tit"><spring:message code='Cache.ACC_lbl_displayName'/></td>
									<td>
										<span id='invoiceeCEOName'></span>
									</td>
								</tr>
								<tr>
									<!-- 사업장주소 -->
									<td class="t_tit"><spring:message code='Cache.ACC_lbl_businessAddress'/></td>
									<td colspan="3">
										<span id='invoicerAddr'></span>
									</td>
									<td class="t_tit"><spring:message code='Cache.ACC_lbl_businessAddress'/></td>
									<td colspan="3">
										<span id='invoiceeAddr'></span>
									</td>
								</tr>
								<tr>
									<!-- 업태 -->
									<td class="t_tit"><spring:message code='Cache.ACC_lbl_business'/></td>
									<td>
										<span id='invoicerBizType'></span>
									</td>
									<!-- 총사업장번호 -->
									<td class="t_tit" colspan="2"><spring:message code='Cache.ACC_lbl_totalBusinessNumber'/></td>
									<td class="t_tit"><spring:message code='Cache.ACC_lbl_business'/></td>
									<td>
										<span id='invoiceeBizType'></span>
									</td>
									<td class="t_tit" colspan="2"><spring:message code='Cache.ACC_lbl_totalBusinessNumber'/></td>
								</tr>
								<tr>
									<!-- 종목 -->
									<td class="t_tit"><spring:message code='Cache.ACC_lbl_event'/></td>
									<td>
										<span id='invoicerBizClass'></span>
									</td>
									<td colspan="2">
										<span id='invoicerTaxRegID'></span>
									</td>
									<td class="t_tit"><spring:message code='Cache.ACC_lbl_event'/></td>
									<td>
										<span id='invoiceeBizClass'></span>
									</td>
									<td colspan="2">
										<span id='invoiceeTaxRegID'></span>
									</td>
								</tr>
								<tr>
									<!-- 부서명 -->
									<td class="t_tit"><spring:message code='Cache.ACC_lbl_deptName'/></td>
									<td>
										<span id='invoicerDeptName'></span>
									</td>
									<!-- 담당자 -->
									<td class="t_tit"><spring:message code='Cache.ACC_lbl_manager'/></td>
									<td>
										<span id='invoicerContactName'></span>
									</td>
									<td class="t_tit"><spring:message code='Cache.ACC_lbl_deptName'/></td>
									<td>
										<span id='invoiceeDeptName1'></span>
									</td>
									<td class="t_tit"><spring:message code='Cache.ACC_lbl_manager'/></td>
									<td>
										<span id='invoiceeContactName1'></span>
									</td>
								</tr>
								<tr>
									<!-- 연락처 -->
									<td class="t_tit"><spring:message code='Cache.ACC_lbl_contact'/></td>
									<td>
										<span id='invoicerTel'></span>
									</td>
									<!-- 휴대폰 -->
									<td class="t_tit"><spring:message code='Cache.ACC_lbl_phone'/></td>
									<td>
										<span id='noMapping'></span>
									</td>
									<td class="t_tit"><spring:message code='Cache.ACC_lbl_contact'/></td>
									<td>
										<span id='invoiceeTel1'></span>
									</td>
									<td class="t_tit"><spring:message code='Cache.ACC_lbl_phone'/></td>
									<td>
										<span id='noMapping'></span>
									</td>
								</tr>
								<tr>
									<td class="t_tit" rowspan="2">E-Mail</td>
									<td colspan="3" rowspan="2">
										<span id='invoicerEmail'></span>
									</td>
									<td class="t_tit" rowspan="2">E-Mail</td>
									<td colspan="3">
										<span id='invoiceeEmail1'></span>
									</td>
								</tr>
								<tr style="display: none;">
									<td colspan="3">
										<span id='invoiceEmail2'></span>
									</td>
								</tr>
							</tbody>
						</table>
						
						<table class="invoice_table mb9">
							<tbody>
								<tr>
									<!-- 작성일 -->
									<td class="t_tit" width="300"><spring:message code='Cache.ACC_lbl_writeDate'/></td>
									<td class="t_tit" width="300"><spring:message code='Cache.ACC_lbl_supplyValue'/></td>
									<td class="t_tit"><spring:message code='Cache.ACC_lbl_taxValue'/></td>
								</tr>
								<tr>
									<td>
										<span id='writeDate1'></span>
										<span id='writeDate2'></span>
										<span id='writeDate3'></span>
									</td>
									<td style="text-align: right;">
										<span id='supplyCostTotal'></span>
									</td>
									<td style="text-align: right;">
										<span id='taxTotal'></span>
									</td>
								</tr>
							</tbody>
						</table>
						<table class="invoice_table mb9">
							<tbody>
								<tr>
									<td class="t_tit" width="130"><spring:message code='Cache.ACC_lbl_description'/></td>
									<td>
										 <span id='remark1'></span>
									</td>
								</tr>
							</tbody>
						</table>
						<table class="invoice_table">
							<tbody id="invoice_table_info">
							</tbody>
						</table>
						
						<table class="invoice_table mb0">
							<tbody id="invoice_table_info_sum">
							</tbody>
						</table>
					</div>
					<div class="bottom">
						<a onclick="TaxInvoicePopup.printLayer()"	id="btnPrint"	class="btnTypeDefault"><spring:message code='Cache.lbl_Print'/></a>
						<a onclick="TaxInvoicePopup.closeLayer();"	id="btnClose"	class="btnTypeDefault"><spring:message code='Cache.ACC_btn_close'/></a>
					</div>
				</div>
			</div>	
		</div>
	</div>
</body>
<script>


if (!window.TaxInvoicePopup) {
	window.TaxInvoicePopup = {};
}

(function(window) {
	var TaxInvoicePopup = {
			popupInit : function() {
				var me = this;
				var param = location.search.substring(1).split('&');
				for(var i = 0; i < param.length; i++){
					var paramKey	= param[i].split('=')[0];
					var paramValue	= param[i].split('=')[1];
					$("#"+paramKey).val(paramValue);
				}
				
				me.getPopupInfo();
			},
			
			getPopupInfo : function(){
				var taxInvoiceID	= $("#taxInvoiceID").val();
				var	paramTxt		= "taxInvoiceID:"+taxInvoiceID;
				
				$.ajax({
					url	:"/account/accountCommon/getTaxInvoicePopupInfo.do?",
					type: "POST",
					data: {	"taxInvoiceID"	: taxInvoiceID
					},
					success:function (data) {
						if(data.status == "SUCCESS"){
							TaxInvoicePopup.setInfo(data);
						}else{
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // data.message	
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // error.message
					}
				});
			},
			
			setInfo : function(data) {
				var list = data.list;
				var info = list[0];
				$('#nTSConfirmNum').text(getStr(info.NTSConfirmNum));
				$(".invoice_title").prepend((getStr(info.InvoiceType) == "" ? "<spring:message code='Cache.ACC_lbl_taxInvoiceCash' />" : getStr(info.InvoiceType)));
				$('#serialNum').text(getStr(info.SerialNum));
				$('#invoicerCorpNum').text(getStr(info.InvoicerCorpNum));
				$('#invoiceeCorpNum').text(getStr(info.InvoiceeCorpNum));
				$('#invoicerCorpName').text(getStr(info.InvoicerCorpName));
				$('#invoiceeCorpName').text(getStr(info.InvoiceeCorpName));
				$('#invoicerCEOName').text(getStr(info.InvoicerCEOName));
				$('#invoiceeCEOName').text(getStr(info.InvoiceeCEOName));
				$('#invoicerAddr').text(getStr(info.InvoicerAddr));
				$('#invoiceeAddr').text(getStr(info.InvoiceeAddr));
				$('#invoicerBizType').text(getStr(info.InvoicerBizType));
				$('#invoiceeBizType').text(getStr(info.InvoiceeBizType));
				$('#invoicerTaxRegID').text(getStr(info.InvoicerTaxRegID));
				$('#invoiceeTaxRegID').text(getStr(info.InvoiceeTaxRegID));
				$('#invoicerBizClass').text(getStr(info.InvoicerBizClass));
				$('#invoiceeBizClass').text(getStr(info.InvoiceeBizClass));
				$('#invoicerDeptName').text(getStr(info.InvoicerDeptName));
				$('#invoiceeDeptName1').text(getStr(info.InvoiceeDeptName1));
				$('#invoicerContactName').text(getStr(info.InvoicerContactName));
				$('#invoiceeContactName1').text(getStr(info.InvoiceeContactName1));
				$('#invoicerTel').text(getStr(info.InvoicerTel));
				$('#invoiceeTel1').text(getStr(info.InvoiceeTel1));
				$('#invoicerEmail').text(getStr(info.InvoicerEmail));
				$('#invoiceeEmail1').text(getStr(info.InvoiceeEmail1));
				$('#invoiceEmail2').text(getStr(info.InvoiceEmail2));
				$('#writeDate1').text(getStr(info.WriteDate1));
				$('#writeDate2').text(getStr(info.WriteDate2));
				$('#writeDate3').text(getStr(info.WriteDate3));
				$('#supplyCostTotal').text(getStr(info.SupplyCostTotal));
				$('#taxTotal').text(getStr(info.TaxTotal));
				$('#remark1').text(getStr(info.Remark1));
				$('#totalAmount').text(getStr(info.TotalAmount));
				$('#cash').text(getStr(info.Cash));
				$('#chkBill').text(getStr(info.ChkBill));
				$('#credit').text(getStr(info.Credit));
				$('#note').text(getStr(info.Note));
				
				var appendStr		= "";
				var appendStrHeader	= "";
				var appendStrBody	= "";
				var appendStrBottom	= "";
			
				appendStrHeader	+=	"<tr>"
								+		"<td class='t_tit' width='65'>"+"<spring:message code='Cache.ACC_lbl_month' />"+"</td>"//월
								+		"<td class='t_tit' width='65'>"+"<spring:message code='Cache.ACC_lbl_day' />"+"</td>"//일
								+		"<td class='t_tit'>"+"<spring:message code='Cache.ACC_lbl_item' />"+"</td>"//품목명
								+		"<td class='t_tit' width='78'>"+"<spring:message code='Cache.ACC_lbl_standardName' />"+"</td>"//규격
								+		"<td class='t_tit' width='78'>"+"<spring:message code='Cache.ACC_lbl_quantity' />"+"</td>"//수량
								+		"<td class='t_tit' width='78'>"+"<spring:message code='Cache.ACC_lbl_unitPrice' />"+"</td>"//단가
								+		"<td class='t_tit' width='100'>"+"<spring:message code='Cache.ACC_lbl_supplyCost' />"+"</td>"//공급액
								+		"<td class='t_tit' width='100'>"+"<spring:message code='Cache.ACC_lbl_taxValue' />"+"</td>"//세액
								+		"<td class='t_tit' width='100'>"+"<spring:message code='Cache.ACC_lbl_description' />"+"</td>"//비고
								+	"</tr>";
				
				if(getNum(info.TaxInvoiceItemCnt) > 0){
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

				var payMsg = "<spring:message code='Cache.ACC_lbl_payBill' />"; //이 금액을 청구 함
				if(info.PurposeType=="01"){
					payMsg = "<spring:message code='Cache.ACC_lbl_payBill2' />"; //이 금액을 영수 함
				}
				appendStrBottom	+=	"<tr>"
								+		"<td class='t_tit' width='130'>"+"<spring:message code='Cache.ACC_lbl_totalAmount' />"+"</td>"//합계금액
								+		"<td class='t_tit' width='122'>"+"<spring:message code='Cache.ACC_lbl_cash' />"+"</td>"//현금
								+		"<td class='t_tit'>"+"<spring:message code='Cache.ACC_lbl_check' />"+"</td>" //수표
								+		"<td class='t_tit' width='117'>"+"<spring:message code='Cache.ACC_lbl_etc_1' />"+"</td>"//어름
								+		"<td class='t_tit' width='117'>"+"<spring:message code='Cache.ACC_lbl_payAble' />"+"</td>"//외상미수금
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
				
				if(getStr(info.InvoiceEmail2) != ""){
					$('#invoiceEmail2').parents('tr').css('display', '');
				}
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
	window.TaxInvoicePopup = TaxInvoicePopup;
})(window);

TaxInvoicePopup.popupInit();
	
</script>