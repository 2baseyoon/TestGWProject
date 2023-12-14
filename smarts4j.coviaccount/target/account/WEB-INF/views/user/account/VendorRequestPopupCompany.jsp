<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>


<div>
	<label> 
		<input name="vendorRequestPopupCompany_inputVendorIsNew" id="vendorRequestPopupCompany_inputVendorIsNewY" type="radio" onclick="VendorRequestPopup.companyIsNewChange(this);" checked="checked" value="Y">
		<label for="vendorRequestPopupCompany_inputVendorIsNewY"><spring:message code='Cache.ACC_lbl_new'/></label>
		<input name="vendorRequestPopupCompany_inputVendorIsNew" id="vendorRequestPopupCompany_inputVendorIsNewN" type="radio" onclick="VendorRequestPopup.companyIsNewChange(this);" value="N">
		<label for="vendorRequestPopupCompany_inputVendorIsNewN"><spring:message code='Cache.ACC_lbl_change'/></label>
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
				<!-- 사업자번호 -->
				<th><spring:message code="Cache.ACC_lbl_BusinessNumber"/><span class="star"></span></th>
				<td>
					<div class="box">
						<input id="vendorRequestPopupCompany_inputVendorNoView" type="text" placeholder="" 
							onkeyup="VendorRequestPopup.vdNoChange(this)" class="HtmlCheckXSS ScriptCheckXSS">
						<input id="vendorRequestPopupCompany_inputVendorNo" 
							name="vendorRequestPopupCompany_inputVendorNo" type="hidden" class="HtmlCheckXSS ScriptCheckXSS">
						
						<!-- 등록확인 -->
						<a class="btnTypeDefault" onclick="VendorRequestPopup.regCheck()"><spring:message code="Cache.ACC_btn_registCheck"/></a>
						
					</div>
				</td>
				<!-- 법인번호 -->
				<th><spring:message code="Cache.ACC_lbl_CorporateNumber"/></th>
				<td>
					<div class="box">
						<input id="vendorRequestPopupCompany_inputCorporateNo" type="text" placeholder="" onkeyup="VendorRequestPopup.ckAccountNo(this)" class="HtmlCheckXSS ScriptCheckXSS">
					</div>
				</td>
			</tr>
			<tr>
				<!-- 거래처명 -->
				<th><spring:message code="Cache.ACC_lbl_vendorName"/><span class="star"></span></th>
				<td>
					<div class="box">
						<input id="vendorRequestPopupCompany_inputVendorName" type="text" placeholder="" class="HtmlCheckXSS ScriptCheckXSS">
					</div>
				</td>
				<!-- 대표자명 -->
				<th><spring:message code="Cache.ACC_lbl_storeRepresentative"/></th>
				<td>
					<div class="box">
						<input id="vendorRequestPopupCompany_inputCEOName" type="text" placeholder="" class="HtmlCheckXSS ScriptCheckXSS">
					</div>
				</td>
			</tr>
			
			<tr>
				<!-- 업태 -->
				<th><spring:message code="Cache.ACC_lbl_business"/></th>
				<td>
					<div class="box">
						<input id="vendorRequestPopupCompany_inputIndustry" type="text" placeholder="" class="HtmlCheckXSS ScriptCheckXSS">
					</div>
				</td>
				<!-- 업종 -->
				<th><spring:message code="Cache.ACC_lbl_vendorSector"/></th>
				<td>
					<div class="box">
						<input id="vendorRequestPopupCompany_inputSector" type="text" placeholder="" class="HtmlCheckXSS ScriptCheckXSS">
					</div>
				</td>
			</tr>
			<tr>
				<!-- 상세주소 -->
				<th><spring:message code="Cache.ACC_lbl_detailAddress"/></th>
				<td colspan="3">
					<div class="box">
						<input id="vendorRequestPopupCompany_inputAddress" type="text" placeholder="" class="HtmlCheckXSS ScriptCheckXSS">
					</div>
				</td>
			</tr>
			</tbody>
			</table>
			
			
			<!--  추가/ 삭제 -->
			<div class="fRight" style="padding-bottom:10px; padding-top:10px;">
					<a onclick="VendorRequestPopup.addRow3()"	id="addRowBtn"	class="btnTypeDefault" style = "margin-right:5px"><spring:message code='Cache.ACC_btn_add'/></a>
					<a onclick="VendorRequestPopup.delRow3()"	id="delRowBtn"	class="btnTypeDefault"><spring:message code='Cache.ACC_btn_delete'/></a>
			</div>
			
			<table class="tableTypeRow" >
					<colgroup>
				        <col style="width: 17%;" />
						<col style="width: 33%;" />
						<col style="width: 25%;" />
						<col style="width: 25%;" />
					</colgroup>	
						
					<tbody id="rowInfoTableCompany">
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
				<!-- 지급조건 -->
				<th><spring:message code="Cache.ACC_lbl_PayType"/></th>
				<td>
					<div class="box">
						<span id="vendorRequestPopupCompany_inputPaymentCondition" class="selectType02">
						</span>
					</div>
				</td>
				<!-- 지급방법 -->
				<th><spring:message code="Cache.ACC_lbl_pay"/></th>
				<td>
					<div class="box">
						<span id="vendorRequestPopupCompany_inputPaymentMethod" class="selectType02">
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
				
				companyComboMake : function(){
					var AXSelectMultiArr	= [	
							{'codeGroup':'PayType',		'target':'vendorRequestPopupCompany_inputPaymentCondition',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_choice'/>"}//선택
						,	{'codeGroup':'PayMethod',	'target':'vendorRequestPopupCompany_inputPaymentMethod',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_choice'/>"}
						]
					accountCtrl.renderAXSelectMulti(AXSelectMultiArr);
				},
				
				companyComboRefresh : function() {
					var list = "vendorRequestPopupCompany_inputPaymentCondition,vendorRequestPopupCompany_inputPaymentMethod"
					accountCtrl.refreshAXSelect(list);
				},
	
				setVendorRequestCompanyData : function(data) {
					var me = window.VendorRequestPopup;
					setFieldDataPopup("vendorRequestPopupCompany_inputVendorNo",			data.VendorNo);
					setFieldDataPopup("vendorRequestPopupCompany_inputVendorNoView",			data.VendorNo);
					setFieldDataPopup("vendorRequestPopupCompany_inputCorporateNo",		data.CorporateNo);
					setFieldDataPopup("vendorRequestPopupCompany_inputVendorName",		data.VendorName);
					setFieldDataPopup("vendorRequestPopupCompany_inputCEOName",			data.CEOName);
					setFieldDataPopup("vendorRequestPopupCompany_inputIndustry",			data.Industry);
					setFieldDataPopup("vendorRequestPopupCompany_inputSector",			data.Sector);
					setFieldDataPopup("vendorRequestPopupCompany_inputAddress",			data.Address);

					
					var items=new Array();
					items=data.BankCode.split(',');
					
					var BankCodeSplit=items;
					var BankNameSplit=data.BankName.split(',');
					var BankAccountNoSplit=data.BankAccountNo.split(',');
					var BankAccountName=data.BankAccountName.split(',');
					
					for(var j=0;j<(items.length-1);j++){
						me.addRow3();
					} 

					for(var i=0;i<(items.length);i++){
						setFieldDataPopup("vendorRequestPopupCompany_inputBankName"+(i+1),		BankNameSplit[i]);
						setFieldDataPopup("vendorRequestPopupCompany_inputBankCode"+(i+1),		BankCodeSplit[i]);
						setFieldDataPopup("vendorRequestPopupCompany_inputBankAccountNo"+(i+1),		BankAccountNoSplit[i]);	
						setFieldDataPopup("vendorRequestPopupCompany_inputBankAccountName"+(i+1),	BankAccountName[i]);
					}


					var cdNumStr = me.vdNoFormat(data.VendorNo); 
					setFieldDataPopup("vendorRequestPopupCompany_inputVendorNo", cdNumStr );
					
					
					$("input[name=vendorRequestPopupCompany_inputVendorIsNew]:radio[value='"+data.IsNew+"']").prop("checked", true);
					me.companyIsNewChange();
					accountCtrl.getComboInfo("vendorRequestPopupCompany_inputPaymentCondition").bindSelectSetValue(data.PaymentCondition);
					accountCtrl.getComboInfo("vendorRequestPopupCompany_inputPaymentMethod").bindSelectSetValue(data.PaymentMethod);
				},
				
				getVendorRequestCompanyData : function() {
					var me = window.VendorRequestPopup;
					var IsNew = $("input[name=vendorRequestPopupCompany_inputVendorIsNew]:checked").val();	
					var infoList= $("#rowInfoTableCompany").children('tr');
					var len		= infoList.length;
					me.params.pageDataObj.IsNew				= IsNew;
					me.params.pageDataObj.VendorNo			= getTxTFieldDataPopup("vendorRequestPopupCompany_inputVendorNo");
					me.params.pageDataObj.CorporateNo		= getTxTFieldDataPopup("vendorRequestPopupCompany_inputCorporateNo");
					me.params.pageDataObj.VendorName		= getTxTFieldDataPopup("vendorRequestPopupCompany_inputVendorName");
					me.params.pageDataObj.CEOName			= getTxTFieldDataPopup("vendorRequestPopupCompany_inputCEOName");
					me.params.pageDataObj.Industry			= getTxTFieldDataPopup("vendorRequestPopupCompany_inputIndustry");
					me.params.pageDataObj.Sector			= getTxTFieldDataPopup("vendorRequestPopupCompany_inputSector");
					me.params.pageDataObj.Address			= getTxTFieldDataPopup("vendorRequestPopupCompany_inputAddress");
					me.params.pageDataObj.PaymentCondition	= accountCtrl.getComboInfo("vendorRequestPopupCompany_inputPaymentCondition").val();
					me.params.pageDataObj.PaymentMethod		= accountCtrl.getComboInfo("vendorRequestPopupCompany_inputPaymentMethod").val();
					
					me.params.pageDataObj.BankCode="";
					me.params.pageDataObj.BankName="";
					me.params.pageDataObj.BankAccountNo="";
					me.params.pageDataObj.BankAccountName="";
					
					for(var i=0;i<len-1;i++){	
						me.params.pageDataObj.BankCode += getTxTFieldDataPopup("vendorRequestPopupCompany_inputBankCode"+(i+1))+",";
						me.params.pageDataObj.BankName += getTxTFieldDataPopup("vendorRequestPopupCompany_inputBankName"+(i+1))+",";
						me.params.pageDataObj.BankAccountNo += getTxTFieldDataPopup("vendorRequestPopupCompany_inputBankAccountNo"+(i+1))+",";
						me.params.pageDataObj.BankAccountName += getTxTFieldDataPopup("vendorRequestPopupCompany_inputBankAccountName"+(i+1))+",";
					}
					
					return;
				},

				popupInit3 : function(){
					var me = this;
					me.addRow3();
				},
				
				addRow3 : function(){
					var me = this;
					var infoList= $("#rowInfoTableCompany").children('tr');
					var len		= infoList.length;
					
				
					var appendStr	= "<tr>"
									+	"<td style='border-left:none;text-align:center' class='multi-row-selector-wrap'>"
									+		"<input type='checkbox' name='RowCheck3' class='multi-row-select'/>"
									+	"</td>"
									+	"<td>"
									+		"<div class='box'>"
									+			"<input type='hidden' id='vendorRequestPopupCompany_inputBankCode"+len+"' class='HtmlCheckXSS ScriptCheckXSS' >"
									+			"<input id='vendorRequestPopupCompany_inputBankName"+len+"' type='text' placeholder='' disabled='true' class='HtmlCheckXSS ScriptCheckXSS'>"
									+			"<a onClick='VendorRequestPopup.bankSearchPopup("+len+")' class='btnTypeDefault btnResInfo'><spring:message code='Cache.ACC_btn_search'/></a>"
									+		"</div>"
									+	"</td>"
									+	"<td>"
									+		"<div class='box'>"
									+			"<input id='vendorRequestPopupCompany_inputBankAccountNo"+len+"' type='text' placeholder='' onkeyup='VendorRequestPopup.ckAccountNo(this)' class='HtmlCheckXSS ScriptCheckXSS'>"
									+		"</div>"
									+	"</td>"
									+	"<td>"
									+		"<div class='box'>"
									+			"<input id='vendorRequestPopupCompany_inputBankAccountName"+len+"' type='text' placeholder='' class='HtmlCheckXSS ScriptCheckXSS'>"
									+		"</div>"
									+	"</td>"
									+ "</tr>"		
					$("#rowInfoTableCompany").append(appendStr);
					me.vendorComboRefresh();
			
				},
				
				delRow3 : function(){
					var me = this;
					var infoList= $("#rowInfoTableCompany").children('tr');
					var memberChk = document.getElementsByName("RowCheck3");
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
				
				vdNoChange : function(obj){
					var me = this;
					me.setRegCk('N');
					
					var val = obj.value;
					var strVal = "";
					
					if(val != null){
						val=val.toString();
						val = val.replaceAll("-", "");
						val = val.substr(0,10)
						
						if(isNaN(val)){
							strVal = "";
							val = "";
						}
						else{
							strVal = me.vdNoFormat(val);
							//strVal = val;
						}
						obj.value = strVal
						$("[name=vendorRequestPopupCompany_inputVendorNo]").val(val);
					}
				},
				vdNoFormat : function(val){
					val = val.replaceAll("-", "");
					val = val.substr(0,10)
					var retVal = "";
					retVal = val.substr(0,3)
					if(val.substr(3,2) != ""){
						retVal = retVal + "-"+ val.substr(3,2)
					}

					if(val.substr(5,5) != ""){
						retVal = retVal + "-"+ val.substr(5,5)
					}
					setFieldDataPopup("vendorRequestPopupCompany_inputVendorNoView",			retVal);
					return retVal
				},
				companyIsNewChange : function(obj) {
					var me = window.VendorRequestPopup;
					var val = "";
					if(obj==null){
						val = $("input[name=vendorRequestPopupCompany_inputVendorIsNew]:checked").val();
					}else{
						val = obj.value;
					}
					if(val=="N"){
						setFieldDataPopup("vendorRequestPopupCompany_inputBankCode","");
						setFieldDataPopup("vendorRequestPopupCompany_inputBankName","");
						setFieldDataPopup("vendorRequestPopupCompany_inputBankAccountNo","");
						setFieldDataPopup("vendorRequestPopupCompany_inputBankAccountName","");
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
	
	VendorRequestPopup.popupInit3();
	
</script>