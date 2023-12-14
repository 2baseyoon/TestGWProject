<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>

<div>
	<label> 
		<input name="vendorRequestPopupPeople_inputVendorIsNew" id="vendorRequestPopupPeople_inputVendorIsNewY" type="radio" onclick="VendorRequestPopup.peopleIsNewChange(this);" checked="checked" value="Y">
		<label for="vendorRequestPopupPeople_inputVendorIsNewY"><spring:message code='Cache.ACC_lbl_new'/></label>
		<input name="vendorRequestPopupPeople_inputVendorIsNew" id="vendorRequestPopupPeople_inputVendorIsNewN" type="radio" onclick="VendorRequestPopup.peopleIsNewChange(this);" value="N">
		<label for="vendorRequestPopupPeople_inputVendorIsNewN"><spring:message code='Cache.ACC_lbl_change'/></label>
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
				<!-- 주민등록번호 -->
				<th><spring:message code="Cache.ACC_lbl_registrationNumber"/><span class="star"></span></th>
				<td>
					<div class="box">
						<input id="vendorRequestPopupPeople_inputVendorNoView" type="text"
						 placeholder=""
						onkeyup="VendorRequestPopup.peopleNoChange(this)" class='HtmlCheckXSS ScriptCheckXSS'>
						<input id="vendorRequestPopupPeople_inputVendorNo" 
						name="vendorRequestPopupPeople_inputVendorNo" type="hidden" class='HtmlCheckXSS ScriptCheckXSS'>
						<!-- 등록확인 -->
						<a class="btnTypeDefault" onclick="VendorRequestPopup.regCheck()"><spring:message code="Cache.ACC_btn_registCheck"/></a>
						
					</div>
				</td>
				<!-- 거래처명 -->
				<th><spring:message code="Cache.ACC_lbl_vendorName"/><span class="star"></span></th>
				<td>
					<div class="box">
						<input id="vendorRequestPopupPeople_inputVendorName" type="text" placeholder="" class='HtmlCheckXSS ScriptCheckXSS'>
					</div>
				</td>
			</tr>
			<tr>
				<!-- 상세주소 -->
				<th><spring:message code="Cache.ACC_lbl_detailAddress"/></th>
				<td colspan="3">
					<div class="box">
						<input id="vendorRequestPopupPeople_inputAddress" type="text" placeholder="" class='HtmlCheckXSS ScriptCheckXSS'>
					</div>
				</td>
			</tr>
			</tbody>
			</table>
			
			
					<!--  추가/ 삭제 -->
			<div class="fRight" style="padding-bottom:10px; padding-top:10px;">
					<a onclick="VendorRequestPopup.addRow2()"	id="addRowBtn"	class="btnTypeDefault" style = "margin-right:5px"><spring:message code='Cache.ACC_btn_add'/></a>
					<a onclick="VendorRequestPopup.delRow2()"	id="delRowBtn"	class="btnTypeDefault"><spring:message code='Cache.ACC_btn_delete'/></a>
			</div>
			
			<table class="tableTypeRow" >
					<colgroup>
				        <col style="width: 17%;" />
						<col style="width: 33%;" />
						<col style="width: 25%;" />
						<col style="width: 25%;" />
					</colgroup>	
						
					<tbody id="rowInfoTablePeople">
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
						<span id="vendorRequestPopupPeople_inputPaymentCondition" class="selectType02">
						</span>
					</div>
				</td>
				<!-- 지금방법 -->
				<th><spring:message code="Cache.ACC_lbl_pay"/></th>
				<td>
					<div class="box">
						<span id="vendorRequestPopupPeople_inputPaymentMethod" class="selectType02">
						</span>
					</div>
				</td>
			</tr>
			<tr>
				<!-- 원천세(소득세) -->
				<th><spring:message code="Cache.ACC_lbl_incomTax"/></th>
				<td>
					<div class="box">
						<span id="vendorRequestPopupPeople_inputIncomTax" class="selectType02">
						</span>
					</div>
				</td>
				<!-- 원천세(지방세) -->
				<th><spring:message code="Cache.ACC_lbl_localTax"/></th>
				<td>
					<div class="box">
						<span id="vendorRequestPopupPeople_inputLocalTax" class="selectType02">
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
				peopleComboMake : function() {
					var me = this;
					var AXSelectMultiArr	= [	
							{'codeGroup':'PayType',		'target':'vendorRequestPopupPeople_inputPaymentCondition',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_choice'/>"} //선택
						,	{'codeGroup':'PayMethod',	'target':'vendorRequestPopupPeople_inputPaymentMethod',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_choice'/>"}
						]
					accountCtrl.renderAXSelectMulti(AXSelectMultiArr);
					me.vendorRequestWHTaxComboMake()
				},
	
				peopleComboRefresh : function() {
					var list = "vendorRequestPopupPeople_inputPaymentCondition,vendorRequestPopupPeople_inputPaymentMethod"
					+"vendorRequestPopupPeople_inputIncomTax,vendorRequestPopupPeople_inputLocalTax"
					accountCtrl.refreshAXSelect(list);
				},
				
				setVendorRequestPeopleData : function(data) {
					var me = window.VendorRequestPopup;
					setFieldDataPopup("vendorRequestPopupPeople_inputVendorNo",			data.VendorNo);
					setFieldDataPopup("vendorRequestPopupPeople_inputVendorName",		data.VendorName);
					setFieldDataPopup("vendorRequestPopupPeople_inputAddress",			data.Address);

					var items=new Array();
					items=data.BankCode.split(',');
					
					var BankCodeSplit=items;
					var BankNameSplit=data.BankName.split(',');
					var BankAccountNoSplit=data.BankAccountNo.split(',');
					var BankAccountName=data.BankAccountName.split(',');
					
					for(var j=0;j<(items.length-1);j++){
						me.addRow2();
					} 

					for(var i=0;i<(items.length);i++){
						setFieldDataPopup("vendorRequestPopupPeople_inputBankName"+(i+1),		BankNameSplit[i]);
						setFieldDataPopup("vendorRequestPopupPeople_inputBankCode"+(i+1),		BankCodeSplit[i]);
						setFieldDataPopup("vendorRequestPopupPeople_inputBankAccountNo"+(i+1),		BankAccountNoSplit[i]);	
						setFieldDataPopup("vendorRequestPopupPeople_inputBankAccountName"+(i+1),	BankAccountName[i]);
					}
					
					
					var cdNumStr = me.peopleNoFormat(data.VendorNo); 
					setFieldDataPopup("vendorRequestPopupPeople_inputVendorNoView", cdNumStr );
					
					
					accountCtrl.getComboInfo("vendorRequestPopupPeople_inputPaymentCondition").bindSelectSetValue(data.PaymentCondition)
					accountCtrl.getComboInfo("vendorRequestPopupPeople_inputPaymentMethod").bindSelectSetValue(data.PaymentMethod)
					accountCtrl.getComboInfo("vendorRequestPopupPeople_inputIncomTax").bindSelectSetValue(data.IncomTax)
					accountCtrl.getComboInfo("vendorRequestPopupPeople_inputLocalTax").bindSelectSetValue(data.LocalTax)
					
					$("input[name=vendorRequestPopupPeople_inputVendorIsNew]:radio[value='"+data.IsNew+"']").prop("checked", true);
					
					
				},
	
				getVendorRequestPeopleData : function() {
					var me = window.VendorRequestPopup;
					var IsNew = $("input[name=vendorRequestPopupPeople_inputVendorIsNew]:checked").val();
					var infoList= $("#rowInfoTablePeople").children('tr');
					var len		= infoList.length;
					
					me.params.pageDataObj.IsNew				= IsNew;
					me.params.pageDataObj.VendorNo			= getTxTFieldDataPopup("vendorRequestPopupPeople_inputVendorNo");
					me.params.pageDataObj.VendorName		= getTxTFieldDataPopup("vendorRequestPopupPeople_inputVendorName");
					me.params.pageDataObj.Address			= getTxTFieldDataPopup("vendorRequestPopupPeople_inputAddress");
					me.params.pageDataObj.PaymentCondition	= accountCtrl.getComboInfo("vendorRequestPopupPeople_inputPaymentCondition").val();
					me.params.pageDataObj.PaymentMethod		= accountCtrl.getComboInfo("vendorRequestPopupPeople_inputPaymentMethod").val();
					me.params.pageDataObj.IncomTax			= accountCtrl.getComboInfo("vendorRequestPopupPeople_inputIncomTax").val();
					me.params.pageDataObj.LocalTax			= accountCtrl.getComboInfo("vendorRequestPopupPeople_inputLocalTax").val();
	
					me.params.pageDataObj.BankCode="";
					me.params.pageDataObj.BankName="";
					me.params.pageDataObj.BankAccountNo="";
					me.params.pageDataObj.BankAccountName="";
					
					for(var i=0;i<len-1;i++){	
						me.params.pageDataObj.BankCode += getTxTFieldDataPopup("vendorRequestPopupPeople_inputBankCode"+(i+1))+",";
						me.params.pageDataObj.BankName += getTxTFieldDataPopup("vendorRequestPopupPeople_inputBankName"+(i+1))+",";
						me.params.pageDataObj.BankAccountNo += getTxTFieldDataPopup("vendorRequestPopupPeople_inputBankAccountNo"+(i+1))+",";
						me.params.pageDataObj.BankAccountName += getTxTFieldDataPopup("vendorRequestPopupPeople_inputBankAccountName"+(i+1))+",";
					}
					
					return me.params.pageDataObj;
				},
				
				peopleIsNewChange : function(obj) {
					var me = window.VendorRequestPopup;
					var val = "";
					if(obj==null){
						val = $("input[name=vendorRequestPopupPeople_inputVendorIsNew]:checked").val();
					}else{
						val = obj.value;
					}
					
					if(val=="N"){
						setFieldDataPopup("vendorRequestPopupPeople_inputBankCode",			"");
						setFieldDataPopup("vendorRequestPopupPeople_inputBankName",			"");
						setFieldDataPopup("vendorRequestPopupPeople_inputBankAccountNo",		"");
						setFieldDataPopup("vendorRequestPopupPeople_inputBankAccountName",	"");
						$("tr[name=bankAreaPeople]").css({"display":"none"});
						me.peopleComboRefresh()
					}else{
						$("tr[name=bankAreaPeople]").css({"display":""});
						me.peopleComboRefresh()
					}
	
					me.setRegCk('N')
				},

				peopleNoChange : function(obj){
					var me = this;
					me.setRegCk('N');
					
					var val = obj.value;
					var strVal = "";
					
					if(val != null){
						val=val.toString();
						val = val.replaceAll("-", "");
						val = val.substr(0,13)

						if(isNaN(val)){
							strVal = "";
							val = "";
						}
						else{
							strVal = me.peopleNoFormat(val);
							val = val.substr(0,13);
						}
						obj.value = strVal
						
						$("[name=vendorRequestPopupPeople_inputVendorNo]").val(val);
						
					}
				},
				
				popupInit2 : function(){
					var me = this;
					me.addRow2();
				},
				
				addRow2 : function(){
					var me = this;
					var infoList= $("#rowInfoTablePeople").children('tr');
					var len		= infoList.length;
					
				
					var appendStr	= "<tr>"
									+	"<td style='border-left:none;text-align:center' class='multi-row-selector-wrap'>"
									+		"<input type='checkbox' name='RowCheck2' class='multi-row-select'/>"
									+	"</td>"
									+	"<td>"
									+		"<div class='box'>"
									+			"<input type='hidden' id='vendorRequestPopupPeople_inputBankCode"+len+"'  class='HtmlCheckXSS ScriptCheckXSS' >"
									+			"<input id='vendorRequestPopupPeople_inputBankName"+len+"' type='text' placeholder='' disabled='true' class='HtmlCheckXSS ScriptCheckXSS'>"
									+			"<a onClick='VendorRequestPopup.bankSearchPopup("+len+")' class='btnTypeDefault btnResInfo'><spring:message code='Cache.ACC_btn_search'/></a>"
									+		"</div>"
									+	"</td>"
									+	"<td>"
									+		"<div class='box'>"
									+			"<input id='vendorRequestPopupPeople_inputBankAccountNo"+len+"' type='text' placeholder='' onkeyup='VendorRequestPopup.ckAccountNo(this)' class='HtmlCheckXSS ScriptCheckXSS' >"
									+		"</div>"
									+	"</td>"
									+	"<td>"
									+		"<div class='box'>"
									+			"<input id='vendorRequestPopupPeople_inputBankAccountName"+len+"' type='text' placeholder='' class='HtmlCheckXSS ScriptCheckXSS' >"
									+		"</div>"
									+	"</td>"
									+ "</tr>"		
					$("#rowInfoTablePeople").append(appendStr);
					me.vendorComboRefresh();
			
				},
				
				delRow2 : function(){
					var me = this;
					
					var infoList= $("#rowInfoTablePeople").children('tr');
					var memberChk = document.getElementsByName("RowCheck2");
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
				vendorComboRefresh : function(){
					var list = "vendorRequestPopupPeople_inputPaymentCondition,vendorRequestPopupPeople_inputPaymentMethod,vendorRequestPopupPeople_inputIncomTax,vendorRequestPopupPeople_inputLocalTax"
					accountCtrl.refreshAXSelect(list);
				},
				peopleNoFormat : function(val){
					var retVal = "";
					retVal = val.substr(0,6)
					if(val.substr(6,7) != ""){
						retVal = retVal + "-"+ val.substr(6,7)
					}
					return retVal
				},
				vendorRequestWHTaxComboMake : function(){
					
					

					$.ajax({
						type:"POST",
							url:"/account/accountCommon/getBaseCodeData.do",
						data:{
							codeGroups : "WHTax"
						},
						
						success:function (data) {
							if(data.result == "ok"){
								var codeList = data.list
								
								var WHTaxList = codeList.WHTax

								var incomList = WHTaxList.filter(function(item){
									if(item.Reserved1=="E1"){
										return true
									}
								});
								var localList = WHTaxList.filter(function(item){
									if(item.Reserved1=="E2"){
										return true
									}
								});
								
								
								accountCtrl.createAXSelectData("vendorRequestPopupPeople_inputIncomTax",incomList, "<spring:message code='Cache.ACC_lbl_choice'/>", 'Code', 'CodeName', null, null, null  )
								accountCtrl.createAXSelectData("vendorRequestPopupPeople_inputLocalTax",localList, "<spring:message code='Cache.ACC_lbl_choice'/>", 'Code', 'CodeName', null, null, null  )

								//vendorPopup_inputIncomTax
								//vendorPopup_inputLocalTax

							}
							else{
								Common.Error(data.message);
							}
						},
						error:function (error){
							Common.Error(error.message);
						}
					});
				},
		}
		window.VendorRequestPopup = $.extend(window.VendorRequestPopup, VendorRequestPopup);
	})(window);
	
	VendorRequestPopup.popupInit2();
	
</script>