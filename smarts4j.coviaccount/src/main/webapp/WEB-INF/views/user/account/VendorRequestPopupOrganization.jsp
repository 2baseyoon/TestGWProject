<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>


<div>
	<label> 
		<input name="vendorRequestPopupOrganization_inputVendorIsNew" id="vendorRequestPopupOrganization_inputVendorIsNewY" type="radio" onclick="VendorRequestPopup.OrganizationIsNewChange(this);" checked="checked" value="Y">
		<label for="vendorRequestPopupOrganization_inputVendorIsNewY"><spring:message code='Cache.ACC_lbl_new'/></label>
		<input name="vendorRequestPopupOrganization_inputVendorIsNew" id="vendorRequestPopupOrganization_inputVendorIsNewN" type="radio" onclick="VendorRequestPopup.OrganizationIsNewChange(this);" value="N">
		<label for="vendorRequestPopupOrganization_inputVendorIsNewN"><spring:message code='Cache.ACC_lbl_change'/></label>
	</label>
	
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
					<!-- 사번 -->
					<spring:message code="Cache.ACC_lbl_idNumber"/>
					<span class="star"></span>
				</th>
				<td>
					<div class="box">
						<input id="vendorRequestPopupOrganization_inputVendorNoView" type="text" placeholder="" disabled="disabled" readonly="readonly" class='HtmlCheckXSS ScriptCheckXSS'>
						<a class="btnTypeDefault" onclick="VendorRequestPopup.regCheck()" name="noViewArea">
							<!-- 등록확인 -->
							<spring:message code="Cache.ACC_btn_registCheck"/>
						</a>
					</div>
				</td>
				<th>
					<!-- 거래처명 -->
					<spring:message code="Cache.ACC_lbl_vendorName"/>
					<span class="star"></span>
				</th>
				<td >
					<div class="box">
						<input id="vendorRequestPopupOrganization_inputVendorName" type="text" placeholder="" class='HtmlCheckXSS ScriptCheckXSS'>
						<a id="organizationNameSearchBtn" class="btnTypeDefault btnResInfo" onclick="VendorRequestPopup.organizationNameSearch()">검색</a>
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
						<input id="vendorPopup_inputAddress" type="text" placeholder="" class='HtmlCheckXSS ScriptCheckXSS'>
					</div>
				</td>
			</tr>					

		</tbody>
	</table>
			
			
			<!--  추가/ 삭제 -->
			<div class="fRight" style="padding-bottom:10px; padding-top:10px;">
					<a onclick="VendorRequestPopup.addRow4()"	id="addRowBtn"	class="btnTypeDefault" style = "margin-right:5px"><spring:message code='Cache.ACC_btn_add'/></a>
					<a onclick="VendorRequestPopup.delRow4()"	id="delRowBtn"	class="btnTypeDefault"><spring:message code='Cache.ACC_btn_delete'/></a>
			</div>
			
			<table class="tableTypeRow" >
					<colgroup>
				        <col style="width: 17%;" />
						<col style="width: 33%;" />
						<col style="width: 25%;" />
						<col style="width: 25%;" />
					</colgroup>	
						
					<tbody id="rowInfoTableOrganization">
					    <tr>
					        <th class="multi-row-selector-wrap"  >선택</th>
					        <!-- 은행명 -->
					        <th><spring:message code="Cache.ACC_lbl_BankName"/> </th>
					        <!-- 은행계좌 -->
					        <th><spring:message code="Cache.ACC_lbl_BankAccount"/></th>
					        <!-- 예금주 -->
					        <th><spring:message code="Cache.ACC_lbl_BankAccountHolder"/></th>
					    </tr>
					</tbody>
			</table>

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
							<!-- 지급조건 -->
							<spring:message code="Cache.ACC_lbl_PayType"/>
						</th>
						<td> 
							<div class="box">
								<span id="vendorRequestPopupOrganization_inputPaymentCondition" class="selectType02">
								</span>
							</div>
						</td>
						<th>	
							<!-- 지급방법 -->
							<spring:message code="Cache.ACC_lbl_pay"/>
						</th>
						<td>
							<div class="box">
								<span id="vendorRequestPopupOrganization_inputPaymentMethod" class="selectType02">
								</span>
							</div>
						</td>
					</tr>
					<tr>
						<th>
							<!-- 상태 -->
							<spring:message code="Cache.ACC_lbl_status"/>
						</th>
						<td colspan="3">
							<div class="box">
								<span id="vendorRequestPopupOrganization_inputVendorStatus" class="selectType02">
								</span>
							</div>
						</td>
					</tr>
				</tbody>
		</table>
	</div>
<script>

	if (!window.VendorRequestPopup) {
		window.VendorRequestPopup = {};
	}
	
	(function(window) {
		var VendorRequestPopup = {
				
				organizationComboMake : function(){
					var AXSelectMultiArr	= [	
							{'codeGroup':'PayType',		'target':'vendorRequestPopupOrganization_inputPaymentCondition',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_choice'/>"}//선택
						,	{'codeGroup':'PayMethod',	'target':'vendorRequestPopupOrganization_inputPaymentMethod',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_choice'/>"}
						,	{'codeGroup':'vendorStatus',	'target':'vendorRequestPopupOrganization_inputVendorStatus',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
						]
					accountCtrl.renderAXSelectMulti(AXSelectMultiArr);
				},
				
				organizationComboRefresh : function() {
					var list = "vendorRequestPopupOrganization_inputPaymentCondition,vendorRequestPopupOrganization_inputPaymentMethod,vendorRequestPopupOrganization_inputVendorStatus"
					accountCtrl.refreshAXSelect(list);
				},
	
				setVendorRequestOrganizationData : function(data) {
					var me = window.VendorRequestPopup;
					setFieldDataPopup("vendorRequestPopupOrganization_inputVendorNoView",			data.VendorNo);
					setFieldDataPopup("vendorRequestPopupOrganization_inputCorporateNo",		data.CorporateNo);
					setFieldDataPopup("vendorRequestPopupOrganization_inputVendorName",		data.VendorName);
					setFieldDataPopup("vendorRequestPopupOrganization_inputCEOName",			data.CEOName);
					setFieldDataPopup("vendorRequestPopupOrganization_inputIndustry",			data.Industry);
					setFieldDataPopup("vendorRequestPopupOrganization_inputSector",			data.Sector);
					setFieldDataPopup("vendorRequestPopupOrganization_inputAddress",			data.Address);

					
					var items=new Array();
					items=data.BankCode.split(',');
					
					var BankCodeSplit=items;
					var BankNameSplit=data.BankName.split(',');
					var BankAccountNoSplit=data.BankAccountNo.split(',');
					var BankAccountName=data.BankAccountName.split(',');
					
					for(var j=0;j<(items.length-1);j++){
						me.addRow4();
					} 

					for(var i=0;i<(items.length);i++){
						setFieldDataPopup("vendorRequestPopupOrganization_inputBankName"+(i+1),		BankNameSplit[i]);
						setFieldDataPopup("vendorRequestPopupOrganization_inputBankCode"+(i+1),		BankCodeSplit[i]);
						setFieldDataPopup("vendorRequestPopupOrganization_inputBankAccountNo"+(i+1),		BankAccountNoSplit[i]);	
						setFieldDataPopup("vendorRequestPopupOrganization_inputBankAccountName"+(i+1),	BankAccountName[i]);
					}


					$("input[name=vendorRequestPopupOrganization_inputVendorIsNew]:radio[value='"+data.IsNew+"']").prop("checked", true);
					me.OrganizationIsNewChange();
					accountCtrl.getComboInfo("vendorRequestPopupOrganization_inputPaymentCondition").bindSelectSetValue(data.PaymentCondition);
					accountCtrl.getComboInfo("vendorRequestPopupOrganization_inputPaymentMethod").bindSelectSetValue(data.PaymentMethod);
					accountCtrl.getComboInfo("vendorRequestPopupOrganization_inputVendorStatus").bindSelectSetValue(data.VendorStatus)
				},
				
				getVendorRequestOrganizationData : function() {
					var me = window.VendorRequestPopup;
					var IsNew = $("input[name=vendorRequestPopupOrganization_inputVendorIsNew]:checked").val();	
					var infoList= $("#rowInfoTableOrganization").children('tr');
					var len		= infoList.length;
					me.params.pageDataObj.IsNew				= IsNew;
					me.params.pageDataObj.VendorNo			= getTxTFieldDataPopup("vendorRequestPopupOrganization_inputVendorNoView");
					me.params.pageDataObj.CorporateNo		= getTxTFieldDataPopup("vendorRequestPopupOrganization_inputCorporateNoView");
					me.params.pageDataObj.VendorName		= getTxTFieldDataPopup("vendorRequestPopupOrganization_inputVendorName");
					me.params.pageDataObj.CEOName			= getTxTFieldDataPopup("vendorRequestPopupOrganization_inputCEOName");
					me.params.pageDataObj.Industry			= getTxTFieldDataPopup("vendorRequestPopupOrganization_inputIndustry");
					me.params.pageDataObj.Sector			= getTxTFieldDataPopup("vendorRequestPopupOrganization_inputSector");
					me.params.pageDataObj.Address			= getTxTFieldDataPopup("vendorRequestPopupOrganization_inputAddress");
					me.params.pageDataObj.PaymentCondition	= accountCtrl.getComboInfo("vendorRequestPopupOrganization_inputPaymentCondition").val();
					me.params.pageDataObj.PaymentMethod		= accountCtrl.getComboInfo("vendorRequestPopupOrganization_inputPaymentMethod").val();
					me.params.pageDataObj.VendorStatus		= accountCtrl.getComboInfo("vendorRequestPopupOrganization_inputVendorStatus").val();
					
					me.params.pageDataObj.BankCode="";
					me.params.pageDataObj.BankName="";
					me.params.pageDataObj.BankAccountNo="";
					me.params.pageDataObj.BankAccountName="";
					
					for(var i=0;i<len-1;i++){	
						me.params.pageDataObj.BankCode += getTxTFieldDataPopup("vendorRequestPopupOrganization_inputBankCode"+(i+1))+",";
						me.params.pageDataObj.BankName += getTxTFieldDataPopup("vendorRequestPopupOrganization_inputBankName"+(i+1))+",";
						me.params.pageDataObj.BankAccountNo += getTxTFieldDataPopup("vendorRequestPopupOrganization_inputBankAccountNo"+(i+1))+",";
						me.params.pageDataObj.BankAccountName += getTxTFieldDataPopup("vendorRequestPopupOrganization_inputBankAccountName"+(i+1))+",";
					}
					
					
					return;
				},

				popupInit4 : function(){
					var me = this;
					me.addRow4();
				},
				
				addRow4 : function(){
					var me = this;
					var infoList= $("#rowInfoTableOrganization").children('tr');
					var len		= infoList.length;
					
				
					var appendStr	= "<tr>"
									+	"<td style='border-left:none;text-align:center' class='multi-row-selector-wrap'>"
									+		"<input type='checkbox' name='RowCheck4' class='multi-row-select'/>"
									+	"</td>"
									+	"<td>"
									+		"<div class='box'>"
									+			"<input type='hidden' id='vendorRequestPopupOrganization_inputBankCode"+len+"'  class='HtmlCheckXSS ScriptCheckXSS' >"
									+			"<input id='vendorRequestPopupOrganization_inputBankName"+len+"' type='text' placeholder='' disabled='true' class='HtmlCheckXSS ScriptCheckXSS'>"
									+			"<a onClick='VendorRequestPopup.bankSearchPopup("+len+")' class='btnTypeDefault btnResInfo'><spring:message code='Cache.ACC_btn_search'/></a>"
									+		"</div>"
									+	"</td>"
									+	"<td>"
									+		"<div class='box'>"
									+			"<input id='vendorRequestPopupOrganization_inputBankAccountNo"+len+"' type='text' placeholder='' onkeyup='VendorRequestPopup.ckAccountNo(this)' class='HtmlCheckXSS ScriptCheckXSS' >"
									+		"</div>"
									+	"</td>"
									+	"<td>"
									+		"<div class='box'>"
									+			"<input id='vendorRequestPopupOrganization_inputBankAccountName"+len+"' type='text' placeholder='' class='HtmlCheckXSS ScriptCheckXSS' >"
									+		"</div>"
									+	"</td>"
									+ "</tr>"		
					$("#rowInfoTableOrganization").append(appendStr);
					me.vendorComboRefresh();
			
				},
				
				delRow4 : function(){
					var me = this;
					var infoList= $("#rowInfoTableOrganization").children('tr');
					var memberChk = document.getElementsByName("RowCheck4");
					var count=0;
					var indexAry=new Array();
					for(i=0; i < memberChk.length; i++){
						   if(memberChk[i].checked){ //true면 
							   indexAry[count]=i;
							   count++;							  
						   }
					}
					for(var j=0;j<count;j++){
						infoList.eq((indexAry[j])+1).remove();
					}
					
					me.vendorComboRefresh();
				},
			
				OrganizationIsNewChange : function(obj) {
					var me = window.VendorRequestPopup;
					var val = "";
					if(obj==null){
						val = $("input[name=vendorRequestPopupOrganization_inputVendorIsNew]:checked").val();
					}else{
						val = obj.value;
					}
					if(val=="N"){
						setFieldDataPopup("vendorRequestPopupOrganization_inputBankCode","");
						setFieldDataPopup("vendorRequestPopupOrganization_inputBankName","");
						setFieldDataPopup("vendorRequestPopupOrganization_inputBankAccountNo","");
						setFieldDataPopup("vendorRequestPopupOrganization_inputBankAccountName","");
						$("tr[name=bankAreaCompany]").css({"display":"none"});
						me.companyComboRefresh();
					}else{
						$("tr[name=bankAreaCompany]").css({"display":""});
						me.companyComboRefresh();
					}
					me.setRegCk('N')
				}
		}
		window.VendorRequestPopup = $.extend(window.VendorRequestPopup, VendorRequestPopup);
	})(window);
	
	VendorRequestPopup.popupInit4();
	
</script>