<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
</head>

<body>	
	<div class="layer_divpop ui-draggable docPopLayer" id="vendorPopup" style="width:900px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
				<table class="tableTypeRow">
					<colgroup>
					<col style="width: 17%;" />
					<col style="width: auto;" />
					<col style="width: 17%;" />
					<col style="width: auto;" />
				</colgroup>
				<tbody>
					<tr>
						<!-- 제목 -->
						<th><spring:message code="Cache.ACC_lbl_title"/></th>
						<td >
							<div class="box">
								<label name="labelMainPopup" datafield="ApplicationTitle" ></label>
							</div>
						</td>
						<!-- 등록자 -->
						<th><spring:message code="Cache.ACC_lbl_registerName"/></th>
						<td >
							<div class="box">
								<label name="labelMainPopup" datafield="RegisterName" ></label>
							</div>
						</td>
					</tr>
					<tr>
						<!-- 신청유형 -->
						<th><spring:message code="Cache.ACC_lbl_vendorRequestType"/></th>
						<td name="isTypeArea" >
							<div class="box">
								<label name="labelMainPopup" datafield="ApplicationTypeName"></label>
							</div>
						</td>
						<th name="isNewArea">
							<!-- 신규/변경 -->
							<spring:message code="Cache.ACC_lbl_new"/> / <spring:message code="Cache.ACC_lbl_change"/>
						</th >
						<td name="isNewArea">
							<div class="box">
								<label name="labelMainPopup" datafield="IsNewName"></label>
							</div>
						</td>
					</tr>
					</tbody>
				</table>
				<div style="height:10px">
				</div>
				<div class="middle">
					<div id="bankChangeArea" style="display:none">
						<table class="tableTypeRow">
								<colgroup>
									<col style="width: 17%;" />
									<col style="width: auto;" />
									<col style="width: 17%;" />
									<col style="width: auto;" />
								</colgroup>
								<tbody>
									<tr>
										<th>
											<!-- 거래처명 -->
											<spring:message code="Cache.ACC_lbl_vendorName"/>
										</th>
										<td>
											<div class="box">
												<label name="labelBankChange" datafield="VendorName"></label>
											</div>
										</td>
										<th>
											<!-- 등록번호 -->
											<spring:message code="Cache.ACC_lbl_vendorRegistNumber"/>
										</th>
										<td>
											<div class="box">
												<label name="labelBankChange" datafield="VendorNo"></label>
											</div>
										</td>
									</tr>
									<tr>
										<th>
											<!-- 은행명 -->
											<spring:message code="Cache.ACC_lbl_BankName"/>
										</th>
										<td colspan="3">
											<div class="box">
												<label name="labelBankChange" datafield="BankName"></label>
											</div>
										</td>
									</tr>
									<tr>
										<th>
											<!-- 은행계좌 -->
											<spring:message code="Cache.ACC_lbl_BankAccount"/>
										</th>
										<td>
											<div class="box">
												<label name="labelBankChange" datafield="BankAccountNo"></label>
											</div>
										</td>
										<th>
											<!-- 예금주 -->
											<spring:message code="Cache.ACC_lbl_BankAccountHolder"/>
										</th>
										<td>
											<div class="box">
												<label name="labelBankChange" datafield="BankAccountName"></label>
											</div>
										</td>
									</tr>
								</tbody>
							</table>
					</div>
					<div id="organizationArea" style="display:none">
						<table class="tableTypeRow">
								<colgroup>
									<col style="width: 17%;" />
									<col style="width: auto;" />
									<col style="width: 17%;" />
									<col style="width: auto;" />
								</colgroup>
								<tbody>
									<tr>
										<th>
											<!-- 거래처명 -->
											<spring:message code="Cache.ACC_lbl_vendorName"/>
										</th>
										<td>
											<div class="box">
												<label name="labelOrgan" datafield="VendorName"></label>
											</div>
										</td>
										<th>
											<!-- 등록번호 -->
											<spring:message code="Cache.ACC_lbl_vendorRegistNumber"/>
										</th>
										<td>
											<div class="box">
												<label name="labelOrgan" datafield="VendorNo"></label>
											</div>
										</td>
									</tr>
									<tr>
										<th>
											<!-- 은행명 -->
											<spring:message code="Cache.ACC_lbl_BankName"/>
										</th>
										<td colspan="3">
											<div class="box">
												<label name="labelOrgan" datafield="BankName"></label>
											</div>
										</td>
									</tr>
									<tr>
										<th>
											<!-- 은행계좌 -->
											<spring:message code="Cache.ACC_lbl_BankAccount"/>
										</th>
										<td>
											<div class="box">
												<label name="labelOrgan" datafield="BankAccountNo"></label>
											</div>
										</td>
										<th>
											<!-- 예금주 -->
											<spring:message code="Cache.ACC_lbl_BankAccountHolder"/>
										</th>
										<td>
											<div class="box">
												<label name="labelOrgan" datafield="BankAccountName"></label>
											</div>
										</td>
									</tr>
								</tbody>
							</table>
					</div>
					<div id="peopleArea" style="display:none"><table class="tableTypeRow">
						<table class="tableTypeRow">
							<colgroup>
								<col style="width: 17%;" />
								<col style="width: auto;" />
								<col style="width: 17%;" />
								<col style="width: auto;" />
							</colgroup>	
							<tbody>
								<tr>
									<th>
										<!-- 주민등록번호 -->
										<spring:message code="Cache.ACC_lbl_registrationNumber"/>
									</th>
									<td>
										<div class="box">
											<label name="labelPeople" datafield="VendorNo"></label>
										</div>
									</td>
									<th>
										<!-- 거래처명 -->
										<spring:message code="Cache.ACC_lbl_vendorName"/>
									</th>
									<td>
										<div class="box">
											<label name="labelPeople" datafield="VendorName"></label>
										</div>
									</td>
								</tr>
								<tr>
									<th>
										<!-- 상세 주소 -->
										<spring:message code="Cache.ACC_lbl_detailAddress"/>
									</th>
									<td colspan="3">
										<div class="box">
											<label name="labelPeople" datafield="Address"></label>
										</div>
									</td>
								</tr>
								<tr name="vdBankArea">
									<th>
										<!-- 은행명 -->
										<spring:message code="Cache.ACC_lbl_BankName"/>
									</th>
									<td colspan="3">
										<div class="box">
											<label name="labelPeople" datafield="BankName"></label>
										</div>
									</td>
								</tr>
								<tr name="vdBankArea">
									<th>
										<!-- 은행계좌 -->
										<spring:message code="Cache.ACC_lbl_BankAccount"/>
									</th>
									<td>
										<div class="box">
											<label name="labelPeople" datafield="BankAccountNo"></label>
										</div>
									</td>
										<!-- 예금주 -->
									<th><spring:message code="Cache.ACC_lbl_BankAccountHolder"/></th>
									<td>
										<div class="box">
											<label name="labelPeople" datafield="BankAccountName"></label>
										</div>
									</td>
								</tr>
								<tr>
									<th>
										<!-- 지급조건 -->
										<spring:message code="Cache.ACC_lbl_PayType"/>
									</th>
									<td>
										<div class="box">
											<label name="labelPeople" datafield="PaymentConditionName"></label>
										</div>
									</td>
									<th>
										<!-- 지급방법 -->
										<spring:message code="Cache.ACC_lbl_pay"/>
									</th>
									<td>
										<div class="box">
											<label name="labelPeople" datafield="PaymentMethodName"></label>
										</div>
									</td>
								</tr>
								<tr>
									<th>
										<!-- 원천세(소득세) -->
										<spring:message code="Cache.ACC_lbl_incomTax"/>
									</th>
									<td>
										<div class="box">
											<label name="labelPeople" datafield="IncomTaxName"></label>
										</div>
									</td>
									<th>
										<!-- 원천세(지방세) -->
										<spring:message code="Cache.ACC_lbl_localTax"/>
									</th>
									<td>
										<div class="box">
											<label name="labelPeople" datafield="LocalTaxName"></label>
										</div>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
					<div id="companyArea" style="display:none">
						<table class="tableTypeRow">
							<colgroup>
								<col style="width: 17%;" />
								<col style="width: auto;" />
								<col style="width: 17%;" />
								<col style="width: auto;" />
							</colgroup>
							<tbody>
								<tr>
									<th>
										<!-- 사업자번호 -->
										<spring:message code="Cache.ACC_lbl_BusinessNumber"/>
									</th>
									<td>
										<div class="box">
											<label name="labelCompany" datafield="VendorNo"></label>
										</div>
									</td>
									<th>
										<!-- 법인번호 -->
										<spring:message code="Cache.ACC_lbl_CorporateNumber"/>
									</th>
									<td>
										<div class="box">
											<label name="labelCompany" datafield="CorporateNo"></label>
										</div>
									</td>
								</tr>
								<tr>
									<th>
										<!-- 거래처명 -->
										<spring:message code="Cache.ACC_lbl_vendorName"/>
									</th>
									<td>
										<div class="box">
											<label name="labelCompany" datafield="VendorName"></label>
										</div>
									</td>
									<th>
										<!-- 대표자명 -->
										<spring:message code="Cache.ACC_lbl_storeRepresentative"/>
									</th>
									<td>
										<div class="box">
											<label name="labelCompany" datafield="CEOName"></label>
										</div>
									</td>
								</tr>
								
								<tr>
									<th>
										<!-- 업태 -->
										<spring:message code="Cache.ACC_lbl_business"/>
									</th>
									<td>
										<div class="box">
											<label name="labelCompany" datafield="Industry"></label>
										</div>
									</td>
									<th>
										<!-- 업종 -->
										<spring:message code="Cache.ACC_lbl_vendorSector"/>
									</th>
									<td>
										<div class="box">
											<label name="labelCompany" datafield="Sector"></label>
										</div>
									</td>
								</tr>
								<tr>
									<th>
										<!-- 상세주소 -->
										<spring:message code="Cache.ACC_lbl_detailAddress"/></th>
									<td colspan="3">
										<div class="box">
											<label name="labelCompany" datafield="Address"></label>
										</div>
									</td>
								</tr>
								<tr name="vdBankArea">
									<th>
										<!-- 은행명 -->
										<spring:message code="Cache.ACC_lbl_BankName"/></th>
									<td colspan="3">
										<div class="box">
											<label name="labelCompany" datafield="BankName"></label>
										</div>
									</td>
								</tr>
								<tr name="vdBankArea">
									<th>
										<!-- 은행계좌 -->
										<spring:message code="Cache.ACC_lbl_BankAccount"/>
									</th>
									<td>
										<div class="box">
											<label name="labelCompany" datafield="BankAccountNo"></label>
										</div>
									</td>
									<th>
										<!-- 예금주 -->
										<spring:message code="Cache.ACC_lbl_BankAccountHolder"/>
									</th>
									<td>
										<div class="box">
											<label name="labelCompany" datafield="BankAccountName"></label>
										</div>
									</td>
								</tr>
								<tr>
									<th>
										<!-- 지급조건 -->
										<spring:message code="Cache.ACC_lbl_PayType"/>
									</th>
									<td>
										<div class="box">
											<label name="labelCompany" datafield="PaymentConditionName"></label>
										</div>
									</td>
									<th>
										<!-- 지급방법 -->
										<spring:message code="Cache.ACC_lbl_pay"/>
									</th>
									<td>
										<div class="box">
											<label name="labelCompany" datafield="PaymentMethodName"></label>
										</div>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
				
				
				
				<input type="hidden" id="vendorRequestPopup_inputVendorApplicationID" >
				<input type="hidden" id="vendorRequestPopup_inputIsSearched" >
				<div class="popBtnWrap bottom">
					<%
						String isAM = (String)request.getAttribute("isAM");
						if("Y".equals(isAM)){
					%>
					<!-- 승인 -->
					<a onclick="VendorRequestViewPopup.onAprvChange('E');" name='aprvBtn' style="display:none" class='btnTypeDefault btnTypeChk'>
						<spring:message code='Cache.ACC_btn_accept' />
					</a>
					<!-- 반려 -->
					<a onclick="VendorRequestViewPopup.onAprvChange('R');" name='aprvBtn' style="display:none" class='btnTypeDefault btnTypeChk'>
						<spring:message code='Cache.ACC_btn_reject' />
					</a>
					<% 
						}
					%>
					<a onclick='VendorRequestViewPopup.onAprvCancel();' name='aprvBtn' style="display:none"  class='btnTypeDefault btnTypeChk'>
						<spring:message code='Cache.ACC_btn_applicationCancel' />
					</a>
					<a onclick="VendorRequestViewPopup.closeLayer();"			id="btnClose"	class="btnTypeDefault"><spring:message code='Cache.ACC_btn_cancel' /></a>
				</div>
			</div>
		</div>		
	</div>
</body>
<script>

if (!window.VendorRequestViewPopup) {
	window.VendorRequestViewPopup = {};
}

(function(window) {
	var VendorRequestViewPopup = {
			params : {
				pageDataObj				: {},
				pageVendorApplicationID	: "${VendorApplicationID}",
				isAM	: "${isAM}",
			},
			
			popupInit : function(){
				var me = window.VendorRequestViewPopup;
				//accountCtrl.renderAXSelect('VendorApplicationType',	'vendorRequestPopup_inpupApplicationType',	'ko','','','');

				//me.peopleComboMake();
				//me.companyComboMake();
				//setFieldDataPopup("vendorRequestPopup_inputIsSearched", "${isSearched}");
				var getVendorApplicationID = "${VendorApplicationID}";
				me.searchDetailData(getVendorApplicationID);

				$("#bankChangeArea").css("display", "none");
				$("#peopleArea").css("display", "none");
				$("#companyArea").css("display", "none");
				$("#organizationArea").css("display", "none");
				
			},
			
			searchDetailData : function(getVendorApplicationID) {
				var me = window.VendorRequestViewPopup;
				setFieldDataPopup("vendorRequestPopup_inputIsSearched", "Y");

				var searchVendorApplicationID = "";
				if(	getVendorApplicationID == null	||
					isEmptyStr(getVendorApplicationID)){
					searchVendorApplicationID	= me.params.pageVendorApplicationID;
				}else{
					searchVendorApplicationID							= getVendorApplicationID;
					me.params.pageVendorApplicationID	= getVendorApplicationID;
				}
				
				setFieldDataPopup("vendorRequestPopup_inputVendorApplicationID", me.params.pageVendorApplicationID);

				$.ajaxSetup({
					cache : false
				});
				
				$.getJSON('/account/baseInfo/searchVendorRequestDetail.do', {VendorApplicationID : getVendorApplicationID}
					, function(r) {
						if(r.result == "ok"){
							var data = r.data
							
							me.params.pageDataObj = data;
							
							me.setLabelField(data, "labelMainPopup");

							if(data.ApplicationType=="BankChange"){
								me.setLabelField(data, "labelBankChange");
								$("[name=isNewArea]").css("display", "none");
								$("[name=isTypeArea]").attr("colspan", 3);
							}else if(data.ApplicationType == "People"){
								me.setLabelField(data, "labelPeople");
								$("[name=isNewArea]").css("display", "");
								$("[name=isTypeArea]").attr("colspan", 1);
							}else if(data.ApplicationType == "Company"){
								me.setLabelField(data, "labelCompany");
								$("[name=isNewArea]").css("display", "");
								$("[name=isTypeArea]").attr("colspan", 1);
							}else if(data.ApplicationType == "Organization"){
								me.setLabelField(data, "labelOrgan");
								$("[name=isNewArea]").css("display", "");
								$("[name=isTypeArea]").attr("colspan", 1);
							}
							
							if(data.IsNew=="Y"){
								$("[name=vdBankArea]").css("display", "");
							}else{
								$("[name=vdBankArea]").css("display", "none");
							}

							if(data.ApplicationStatus =="S"){
								$("[name=aprvBtn]").css("display", "");
							}

							me.appTypeChange(data.ApplicationType, data.IsNew)
							
						}
				}).error(function(response, status, error){
				});
			},
			
			appTypeChange : function(inputType, isNew) {
				var me = window.VendorRequestViewPopup;
				var val = inputType
				var popupH = '0px';
				if(val == "BankChange"){
					$("#bankChangeArea").css("display", "");
					$("#peopleArea").css("display", "none");
					$("#companyArea").css("display", "none");
					$("#organizationArea").css("display", "none");
					popupH = '320px';
				}else if(val == "People"){
					$("#bankChangeArea").css("display", "none");
					$("#peopleArea").css("display", "");
					$("#companyArea").css("display", "none");
					$("#organizationArea").css("display", "none");
					
					if(isNew=="Y"){
						popupH = '480px';
					}else{
						popupH = '380px';
					}
					
				}else if(val == "Company"){
					$("#bankChangeArea").css("display", "none");
					$("#peopleArea").css("display", "none");
					$("#companyArea").css("display", "");
					$("#organizationArea").css("display", "none");
					if(isNew=="Y"){
						popupH = '500px';
					}else{
						popupH = '400px';
					}
				}else if(val== "Organization"){
					$("#bankChangeArea").css("display", "none");
					$("#peopleArea").css("display", "none");
					$("#companyArea").css("display", "none");
					$("#organizationArea").css("display", "");
					popupH = '320px';
				}
				
				accountCtrl.changePopupSize('',popupH);
			},



			closeLayer : function(){
				var isWindowed	= CFN_GetQueryString("CFN_OpenedWindow");
				var popupID		= CFN_GetQueryString("popupID");
				
				if(isWindowed.toLowerCase() == "true") {
					window.close();
				} else {
					parent.Common.close(popupID);
				}
			},
			
			
			

			setLabelField : function(inputData, labelNm){
				var me = window.VendorRequestViewPopup;
				if(inputData==null){
					return;
				}
				
				if(labelNm ==null){
					labelNm = "labelMainPopup"
				}
				var labelList = $("label[name="+labelNm+"]")
			   	for(var i=0;i<labelList.length; i++){
			   		var getLabel = labelList[i];
			   		var field = getLabel.getAttribute("datafield");
			   		getLabel.innerHTML = nullToBlank(inputData[field]);
			   	}
				
			},
			onAprvCancel : function(){
				var me = this;
				var getStat = me.params.pageDataObj.ApplicationStatus;
				if(getStat != 'D'
						&& getStat != 'S'){
					Common.Inform("<spring:message code='Cache.ACC_038'/>") //신청상태가 아닌 항목입니다.
					return;
				}
				var aprvObj = {
						setStatus : 'T'
				};
				aprvObj.aprvList = 	[me.params.pageDataObj]
		        Common.Confirm("<spring:message code='Cache.ACC_039'/>", "Confirmation Dialog", function(result){	//신청취소 하시겠습니까??
		       		if(result){
						
						$.ajax({
							type:"POST",
								url:"/account/baseInfo/vendAprvStatChange.do",
							data:{
								"aprvObj"	: JSON.stringify(aprvObj),
							},
							success:function (data) {
								if(data.result == "ok"){
									parent.Common.Inform("<spring:message code='Cache.ACC_msg_processComplet'/>");	//처리완료되었습니다.
									try{
										accountCtrl.popupCallBackStr([]);
									}catch (e){
										coviCmn.traceLog(e);
										coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
									}
									me.closeLayer();
									
								}
							},
							error:function (error){
								Common.Error(error.message);
							}
						});
		       		}
		        });
			},
			
			addRow : function(){
				var me = this;
				var infoList = $("#rowInfoTable").children('tr');
				var len	= infoList.length;
		
				var appendStr	= "<tr>"
								+	"<td style='border-left:none;text-align:center' class='multi-row-selector-wrap'>"
								+		"<input type='checkbox' name='RowCheck' class='multi-row-select'/>"
								+	"</td>"
								+	"<td>"
								+		"<div class='box'>"
								+			"<input type='hidden' id='vendorPopup_inputBankCode"+len+"'  >"
								+			"<input id='vendorPopup_inputBankName"+len+"' type='text' placeholder='' disabled='true'>"
								+			"<a onClick='VendorPopup.bankSearchPopup(" + len + ")' class='btnTypeDefault btnResInfo'><spring:message code='Cache.ACC_btn_search'/></a>"
								+		"</div>"
								+	"</td>"
								+	"<td>"
								+		"<div class='box'>"
								+			"<input id='vendorPopup_inputBankAccountNo"+len+"' type='text' placeholder='' onkeyup='VendorPopup.bankAccountChange(this)' >"
								+		"</div>"
								+	"</td>"
								+	"<td>"
								+		"<div class='box'>"
								+			"<input id='vendorPopup_inputBankAccountName"+len+"' type='text' placeholder='' >"
								+		"</div>"
								+	"</td>"
								+ "</tr>"		
				$("#rowInfoTable").append(appendStr);
				me.vendorComboRefresh();
			},
			
			onAprvChange : function(stat){
				<%
				if("Y".equals(isAM)){
				%>
				var me = this;
				
				var getStat = me.params.pageDataObj.ApplicationStatus;
				if(getStat != 'S'
						&& getStat != 'D'){
					Common.Inform("<spring:message code='Cache.ACC_038'/>")	//신청상태가 아닌 항목입니다.
					return;
				}
				
				var aprvObj = {
						setStatus : stat
				};
				aprvObj.aprvList = 	[me.params.pageDataObj]
				if(stat=="E"){
					msg = "<spring:message code='Cache.ACC_msg_ckAccept' />";	//승인하시겠습니까?
				}else if(stat=="R"){
					msg = "<spring:message code='Cache.ACC_msg_ckReject' />";	//반려하시겠습니까?
				}
		        Common.Confirm(msg, "Confirmation Dialog", function(result){
		       		if(result){
						
						$.ajax({
							type:"POST",
								url:"/account/baseInfo/vendAprvStatChange.do",
							data:{
								"aprvObj"	: JSON.stringify(aprvObj),
							},
							success:function (data) {
								if(data.result == "ok"){
									parent.Common.Inform("<spring:message code='Cache.ACC_msg_processComplet'/>");	//처리완료하였습니다
									try{
										accountCtrl.popupCallBackStr([]);
									}catch (e){
										coviCmn.traceLog(e);
										coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
									}
									me.closeLayer();
									
								//	Common.Inform("<spring:message code='Cache.ACC_msg_processComplet'/>");
								//	me.closeLayer();
								}
							},
							error:function (error){
								Common.Error(error.message);
							}
						});
		       		}
		        });
				<% 
					}
				%>
			}


			
	}


	
	window.VendorRequestViewPopup = $.extend(window.VendorRequestViewPopup, VendorRequestViewPopup);

})(window);

VendorRequestViewPopup.popupInit();

</script>