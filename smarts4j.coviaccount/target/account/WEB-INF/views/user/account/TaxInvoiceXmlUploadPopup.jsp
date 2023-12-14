<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="popContent vmExcelUploadPopup" style="padding: 30px 24px;">
	<input type="hidden" value="${searchProperty}" id="searchProperty">
	<div class="">
		<div class="top">
			<ul class="noticeTextGrayBox">
				<li>※ <spring:message code="Cache.ACC_msg_xmlUpload" /></li>
			</ul>
			<div class="ulList type02 mt20">
				<ul>
					<li class="listCol">
						<div><strong><spring:message code="Cache.ACC_lbl_file" /></strong></div>
						<div>
							<input type="text" id="uploadfileText" placeholder="<spring:message code='Cache.ACC_msg_excelUpload_2' />"><a class="btnTypeDefault" onclick="$('#uploadfile').click();"><spring:message code="Cache.ACC_lbl_selectFile" /></a>
							<div style="width:0px; height:0px; overflow:hidden;"><input type="file" id="uploadfile" ></div>
						</div>
					</li>								
				</ul>							
			</div>
		</div>
		<div class="bottom" style="text-align: center;">									
			<a class="btnTypeDefault btnTypeBg" onclick="TaxInvoiceXmlUploadPopup.excelUpload()"><spring:message code="Cache.ACC_btn_upload" /></a>	<!-- 업로드 -->
			<a class="btnTypeDefault"			onclick="TaxInvoiceXmlUploadPopup.closeLayer()"><spring:message code='Cache.ACC_btn_close' /></a>	<!-- 취소 -->
		</div>
	</div>
</div>
			
<script type="text/javascript">
	if (!window.TaxInvoiceXmlUploadPopup) {
		window.TaxInvoiceXmlUploadPopup = {};
	}
	
	(function(window) {
		var TaxInvoiceXmlUploadPopup = {
				initContent : function() {
					$('#uploadfile').on('change', function(e) {
						var file = $(this)[0].files[0];
						
						if(file.name.split(".")[file.name.split(".").length - 1].toLowerCase() != "xml") { 
							alert("<spring:message code='Cache.msg_cannotLoadExtensionFile' />"); //불러올 수 없는 확장자 파일입니다.
							return; 
						}
						
						if (typeof(file) == 'undefined') $('#uploadfileText').val(''); else $('#uploadfileText').val(file.name);
					});
				},
				
				excelUpload : function() {
					
					var formData = new FormData();
					formData.append("uploadfile",$('#uploadfile')[0].files[0]);
					$.ajax({
						url: '/account/accountCommon/getTaxInvoiceXmlInfo.do',
						processData: false,
						contentType: false,
						data: formData,
						type: 'POST',
						success: function(result) {
							if(result.status == "SUCCESS"){ 
								var rtObj	= {};
								
								var info	= {};
								info.InvoiceeBusinessTypeCode	= result.info.InvoiceeBusinessTypeCode;
								info.InvoiceeBizClass			= result.info.InvoiceeClassificationCode;
								info.InvoiceeCorpNum			= result.info.InvoiceeID;
								info.InvoiceeAddr				= result.info.InvoiceeLineOneText;
								info.InvoiceeCorpName			= result.info.InvoiceeNameText;
								info.InvoiceeCEOName			= result.info.InvoiceeSpecifiedPersonNameText;
								info.InvoiceeTaxRegistrationID	= result.info.InvoiceeTaxRegistrationID;
								info.InvoiceeBizType			= result.info.InvoiceeTypeCode;
								info.InvoiceeTel1				= result.info.InvoiceeTelephoneCommunication1;
								info.InvoiceeEmail1				= result.info.InvoiceeURICommunication1;
								info.InvoiceeContactName1		= result.info.InvoiceePersonNameText1;
								info.InvoiceTel2				= result.info.InvoiceeTelephoneCommunication2;
								info.InvoiceEmail2				= result.info.InvoiceeURICommunication2;
								info.InvoiceeContactName2		= result.info.InvoiceePersonNameText2;
								info.InvoicerBizClass			= result.info.InvoicerClassificationCode;
								info.InvoicerCorpNum			= result.info.InvoicerID;
								info.InvoicerAddr				= result.info.InvoicerLineOneText;
								info.InvoicerCorpName			= result.info.InvoicerNameText;
								info.InvoicerContactName		= result.info.InvoicerPersonNameText;
								info.InvoicerCEOName			= result.info.InvoicerSpecifiedPersonNameText;
								info.InvoicerTaxRegistrationID	= result.info.InvoicerTaxRegistrationID;
								info.InvoicerTel				= result.info.InvoicerTelephoneCommunication;
								info.InvoicerBizType			= result.info.InvoicerTypeCode;
								info.InvoicerEmail				= result.info.InvoicerURICommunication;
								info.IssueID					= result.info.IssueID;
								info.PurposeType				= result.info.PurposeCode;
								info.TaxTotal					= Number(result.info.TaxTotalAmount) || 0;
								info.SupplyCostTotal			= Number(result.info.ChargeTotalAmount) || 0;
								info.TotalAmount				= Number(result.info.GrandTotalAmount) || 0;
								info.IssueDTExchanged			= result.info.IssueDateTimeExchangedDocument;
								info.IssueDTExchangedYMD		= info.IssueDTExchanged.substr(0,8)
								info.IssueDTTaxInvoice			= result.info.IssueDateTimeTaxInvoiceDocument;

								info.Cash = Number(result.info.Cash) || 0;
								info.ChkBill = Number(result.info.ChkBill) || 0;
								info.Credit = Number(result.info.Credit) || 0;
								info.Note = Number(result.info.Note) || 0;

								//데이터 구조가 다름에 따른 임의 정의 데이터
								info.CompanyCode				= accComm.getCompanyCodeOfUser();
								
								var strInvoiceType = accComm.getBaseCodeName("TypeCode", result.info.TypeCode, info.CompanyCode);
								if(!strInvoiceType) strInvoiceType = result.info.TypeCode;
								info.InvoiceType = strInvoiceType;
								
								info.NTSConfirmNum				= result.info.IssueID;
								info.DataIndex					= "BUY";
								info.IsOffset = "";
																
								var list = [];
								for(var i=0; i<result.items.length; i++){
									var listObj	= result.items[i];
									var addObj		= {};
									
									addObj.SequenceNumeric	= listObj.SequenceNumeric;
									addObj.PurchaseDT	= listObj.PurchaseExpiryDateTime;
									addObj.ItemName		= listObj.NameText;
									addObj.SupplyCost	= Number(listObj.InvoiceAmount) || 0;
									addObj.Tax	= Number(listObj.CalculatedAmount) || 0;
									addObj.Spec = listObj.InformationText;
									addObj.Qty = Number(listObj.ChargeableUnitQuantity) || 0;
									addObj.UnitCost = Number(listObj.UnitAmount) || 0;
									addObj.Remark = listObj.DescriptionText;
									
									list.push(addObj);
								}

								rtObj.info = info;
								rtObj.list = list;
								
								try{
									accountCtrl.popupCallBackStr([rtObj]);
								}catch (e) {
									coviCmn.traceLog(e);
									coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
								}
								
								TaxInvoiceXmlUploadPopup.closeLayer();
							}else{
								Common.Inform(result.message);
							}
						},error:function(error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
						}
					});
				},
				
				closeLayer : function(){
					var isWindowed	= CFN_GetQueryString("CFN_OpenedWindow");
					var popupID		= CFN_GetQueryString("popupID");
					
					if(isWindowed.toLowerCase() == "true") {
						window.close();
					} else {
						parent.Common.close(popupID);
					}
				}
		}
		window.TaxInvoiceXmlUploadPopup = TaxInvoiceXmlUploadPopup;
	})(window);

	TaxInvoiceXmlUploadPopup.initContent();

</script>
