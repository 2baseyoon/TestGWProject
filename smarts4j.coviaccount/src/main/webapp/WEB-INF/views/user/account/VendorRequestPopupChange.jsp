<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>

<div>
	<input id="vendorRequestPopupChange_inputVendorID" type="hidden" >
	<table class="tableTypeRow">
		<colgroup>
			<col style="width: 17%;" />
			<col style="width: auto;" />
			<col style="width: 17%;" />
			<col style="width: auto;" />
		</colgroup>
		<tbody>
			<tr>
				<!-- 거래처명 -->
				<th><spring:message code="Cache.ACC_lbl_vendorName"/><span class="star"></span></th>
				<td>
					<div class="box">
						<div class="searchBox02">
							<span>
								<input id="vendorRequestPopupChange_inputVendorName" class="sm" type="text" disabled="true" style="width:100%" class="HtmlCheckXSS ScriptCheckXSS">
								<button class="btnSearchType01" type="button" onclick="VendorRequestPopup.vendorSelectPopup();"><spring:message code="Cache.ACC_btn_search"/></button>
							</span>
						</div>	
					</div>
				</td>	
				<!-- 등록번호 -->
				<th><spring:message code="Cache.ACC_lbl_vendorRegistNumber"/></th>
				<td>
					<div class="box">
						<input id="vendorRequestPopupChange_inputVendorNo" type="text" disabled="true" class="HtmlCheckXSS ScriptCheckXSS">
					</div>
				</td>
			</tr>
		</tbody>
	</table>
	
	<!--  추가/ 삭제 -->
	<div class="fRight" style="padding-bottom:10px; padding-top:10px;">
			<a onclick="VendorRequestPopup.addRow()"	id="addRowBtn"	class="btnTypeDefault" style = "margin-right:5px"><spring:message code='Cache.ACC_btn_add'/></a>
			<a onclick="VendorRequestPopup.delRow()"	id="delRowBtn"	class="btnTypeDefault"><spring:message code='Cache.ACC_btn_delete'/></a>
	</div>
	
	<table class="tableTypeRow" >
					<colgroup>
				        <col style="width: 17%;" />
						<col style="width: 33%;" />
						<col style="width: 25%;" />
						<col style="width: 25%;" />
					</colgroup>	
						
					<tbody id="rowInfoTableBankChange">
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

	
	
</div>
<script>
	
	if (!window.VendorRequestPopup) {
		window.VendorRequestPopup = {};
	}
	
	(function(window) {
		var VendorRequestPopup = {
				setVendorRequestChangeData : function(data){
					var me=this;
					setFieldDataPopup("vendorRequestPopupChange_inputVendorID",			data.VendorID);
					setFieldDataPopup("vendorRequestPopupChange_inputVendorName",		data.VendorName);
					setFieldDataPopup("vendorRequestPopupChange_inputVendorNo",			data.VendorNo);
					
					var items=new Array();
					items=data.BankCode.split(',');
					
					var BankNameSplit=data.BankName.split(',');
					var BankCodeSplit=items;
					var BankAccountNoSplit=data.BankAccountNo.split(',');
					var BankAccountName=data.BankAccountName.split(',');
					
					for(var j=0;j<items.length-1;j++){
						me.addRow();
					} 

					for(var i=0;i<items.length;i++){
						setFieldDataPopup("vendorRequestPopupChange_inputBankName"+(i+1),		BankNameSplit[i]);
						setFieldDataPopup("vendorRequestPopupChange_inputBankCode"+(i+1),		BankCodeSplit[i]);
						setFieldDataPopup("vendorRequestPopupChange_inputBankAccountNo"+(i+1),		BankAccountNoSplit[i]);	
						setFieldDataPopup("vendorRequestPopupChange_inputBankAccountName"+(i+1),	BankAccountName[i]);
					}
				},

				getVendorRequestChangeData : function(){
					var me = window.VendorRequestPopup;
					var infoList= $("#rowInfoTableBankChange").children('tr');
					var len		= infoList.length;
				
					me.params.pageDataObj.VendorID			= getTxTFieldDataPopup("vendorRequestPopupChange_inputVendorID");
					me.params.pageDataObj.VendorName		= getTxTFieldDataPopup("vendorRequestPopupChange_inputVendorName");
					me.params.pageDataObj.VendorNo			= getTxTFieldDataPopup("vendorRequestPopupChange_inputVendorNo");
					me.params.pageDataObj.IsNew				= "N"
					
					me.params.pageDataObj.BankCode="";
					me.params.pageDataObj.BankName="";
					me.params.pageDataObj.BankAccountNo="";
					me.params.pageDataObj.BankAccountName="";
					
					for(var i=0;i<len-1;i++){	
						me.params.pageDataObj.BankCode += getTxTFieldDataPopup("vendorRequestPopupChange_inputBankCode"+(i+1))+",";
						me.params.pageDataObj.BankName += getTxTFieldDataPopup("vendorRequestPopupChange_inputBankName"+(i+1))+",";
						me.params.pageDataObj.BankAccountNo += getTxTFieldDataPopup("vendorRequestPopupChange_inputBankAccountNo"+(i+1))+",";
						me.params.pageDataObj.BankAccountName += getTxTFieldDataPopup("vendorRequestPopupChange_inputBankAccountName"+(i+1))+",";
					}
	
					return;
				},
				
				popupInit : function(){
					var me = this;
					me.addRow();
				},
				
				addRow : function(){
					var me = this;
					var infoList= $("#rowInfoTableBankChange").children('tr');
					var len		= infoList.length;
			
					var appendStr	= "<tr>"
									+	"<td style='border-left:none;text-align:center' class='multi-row-selector-wrap'>"
									+		"<input type='checkbox' name='RowCheck' class='multi-row-select'/>"
									+	"</td>"
									+	"<td>"
									+		"<div class='box'>"
									+			"<input type='hidden' id='vendorRequestPopupChange_inputBankCode"+len+"'  >"
									+			"<input id='vendorRequestPopupChange_inputBankName"+len+"' type='text' placeholder='' disabled='true'>"
									+			"<a onClick='VendorRequestPopup.bankSearchPopup("+len+")' class='btnTypeDefault btnResInfo'><spring:message code='Cache.ACC_btn_search'/></a>"
									+		"</div>"
									+	"</td>"
									+	"<td>"
									+		"<div class='box'>"
									+			"<input id='vendorRequestPopupChange_inputBankAccountNo"+len+"' type='text' placeholder='' onkeyup='VendorRequestPopup.ckAccountNo(this)' >"
									+		"</div>"
									+	"</td>"
									+	"<td>"
									+		"<div class='box'>"
									+			"<input id='vendorRequestPopupChange_inputBankAccountName"+len+"' type='text' placeholder='' >"
									+		"</div>"
									+	"</td>"
									+ "</tr>"		
					$("#rowInfoTableBankChange").append(appendStr);
				},
				
				delRow : function(){
					var infoList= $("#rowInfoTableBankChange").children('tr');
					var memberChk = document.getElementsByName("RowCheck");
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
					
				}
		}

		window.VendorRequestPopup = $.extend(window.VendorRequestPopup, VendorRequestPopup);

	})(window);
	
	VendorRequestPopup.popupInit();

</script>
