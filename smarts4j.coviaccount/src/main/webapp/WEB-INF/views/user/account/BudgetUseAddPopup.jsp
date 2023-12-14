<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8" import="egovframework.coviframework.util.RedisDataUtil"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
</head>

<style>
.onlyNumber{width: 140px; float: left; text-align:right; ime-mode:disabled;}
</style>
<%String IsUseStandardBrief = RedisDataUtil.getBaseConfig("IsUseStandardBrief");
if (!IsUseStandardBrief.equals("Y")) {
	out.println("<style>.StandardBrief{display:none}</style>");
}
%>
<c:set var="costName" value="Cache.ACC_lbl_costCenterName" />
<c:if test="${costCenterType eq 'USER'}">
	<c:set var="costName" value="Cache.ObjectType_UR" />
</c:if>

<body>
	<div class="layer_divpop ui-draggable docPopLayer" style="width:100%;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
			
			<div class="middle">
					<table class="soundTable" style="width:100%">
						<colgroup>
							<col style = "width: 150px;">
							<col style = "width: auto;">
						</colgroup>
						<tbody>
	                      <tr>
	                          <th><spring:message code="Cache.ObjectType_UR"/> <!-- costcenter --></th>
				              <td>
	                              <input id="initiatorID" name="initiatorID" type="hidden" />
	                              <input id="initiatorName" name="initiatorName" type="text" readonly="readonly">							
								<button class="btnSearchType01" type="button" onclick="BudgetUseAddPopup.userSearchPopup();"></button>
	                          </td>
			              </tr>
			               <tr>
	                          <th><spring:message code="Cache.NumberFieldType_DeptName"/> <!-- costcenter --></th>
				              <td>
	                              <input id="initiatorDeptCode" name="initiatorDeptCode" type="hidden" />
	                              <input id="initiatorDeptName" name="initiatorDeptName" type="text" readonly="readonly">							
	                          </td>
			              </tr>
	                      <tr>
	                          <th><spring:message code="${costName}"/> <!-- costcenter --></th>
				              <td>
	                              <input id="costCenter" name="costCenter" type="hidden" />
	                              <input id="costCenterName" name="costCenterName" type="text" readonly="readonly">							
								<button class="btnSearchType01" type="button" onclick="BudgetUseAddPopup.costCenterSearchPopup('${costName}');"></button>
	                          </td>
			              </tr>
	                      <tr>
	                          <th><spring:message code='Cache.ACC_lbl_budget' /><spring:message code='Cache.ACC_lbl_accountName' /> <!-- 예산계정과목 --></th>
				              <td>
	                              <input id="accountCode" name="accountCode" type="hidden" />
	                              <input id="accountName" name="accountName" type="text" readonly="readonly">							
								<button class="btnSearchType01" type="button" onclick="BudgetUseAddPopup.accountSearchPopup();"></button>
	                          </td>
			              </tr>
			              <tr class="StandardBrief">
	                          <th><spring:message code='Cache.ACC_lbl_budget' /><spring:message code='Cache.ACC_standardBrief' /> <!-- 표준적요 --></th>
				              <td>
	                              <input id="standardBriefID" name="standardBriefID" type="hidden" />
	                              <input id="standardBriefName" name="standardBriefName" type="text" readonly="readonly" />
								<button class="btnSearchType01" type="button" onclick="BudgetUseAddPopup.standardBriefSearchPopup();"></button>
	                          </td>
			              </tr>
	                      <tr>
	                          <th><spring:message code='Cache.ACC_lbl_deadlineYear' />	<!-- 회계년도 --></th>
				              <td>
	                              <select id="fiscalYear" name="fiscalYear"  Width="150" ></select>
	                          </td>
			              </tr>
	                      <tr>
	                          <th><spring:message code='Cache.ACC_lbl_realPayDate' /></th><!-- 증빙일자 -->
	                          <td>
	                              <span id="Date" style="width:100%;"></span>
	                          </td>
	                      </tr>
	                      <tr>
	                          <th><spring:message code='Cache.ACC_lbl_budget' /><spring:message code='Cache.lbl_amount' /></th>
	                          <td>
	                              <input id="budgetAmount" name="budgetAmount" class="onlyNumber" type="text" readonly="readonly">		
	                              <spring:message code='Cache.ACC_lbl_budget' />	<spring:message code='Cache.ACC_lbl_control' />					
	                              <input type="checkbox" id="isControl" name="isControl" class="AXInput av-required"  value="" disabled="readonly"/>
								<a onclick="BudgetUseAddPopup.getBudgetAmount();"	id="btnSave" class="btnTypeDefault btnTypeChk"><spring:message code='Cache.lbl_invoice_amount' /><spring:message code='Cache.lbl_Views' /></a>
	                          </td>
	                      </tr>
	                      <tr>
	                          <th><spring:message code='Cache.ACC_lbl_applicationAmt' /></th>
	                          <td>
	                              <input id="usedAmount" name="usedAmount" class="onlyNumber" type="text" >							
	                          </td>
	                      </tr>
						 <tr>
	                          <th><spring:message code='Cache.lbl_Reserved' />1</th>
		                      <td><input id="reservedStr1" name="reservedStr1" type="text" ></td>
	                      </tr>
	                      <tr>
	                          <th><spring:message code='Cache.ACC_lbl_useHistory2' /></th>
		                      <td><textarea id="description" style="width:90%" rows="5" cols="1"></textarea></td>
	                      </tr>
	                      <tr>
	                          <th><spring:message code='Cache.lbl_Status' /></th>
	                      	<td>
	                      		<select id=status name=status>
	                      			<option value="R">반려</option>
	                      			<option value="P">가집행</option>
	                      			<option value="C" selected>집행</option>
	                      		</select>
	                      	</td>
	                      </tr>
						</tbody>
					</table>
				</div>
				<div class="bottom">
					<a onclick="BudgetUseAddPopup.Save();"	id="btnSave"	class="btnTypeDefault btnTypeChk"><spring:message code='Cache.ACC_btn_save'/></a> 	<!-- 저장 -->
					<a onclick="BudgetUseAddPopup.closeLayer();"			id="btnClose"	class="btnTypeDefault"><spring:message code='Cache.btn_Cancel'/></a>				<!-- 취소 -->
				</div>
			</div>
		</div>	
	</div>
</body>
<script>

if (!window.BudgetUseAddPopup) {
	window.BudgetUseAddPopup = {};
}

(function(window) {
	var BudgetUseAddPopup = {
			/**
			화면 초기화
			*/
			popupInit : function(){
				var me = this;
				me.setSelectCombo();
				$('.onlyNumber').keypress(function(){
					if(event.keyCode < 45 || event.keyCode > 57) event.preventDefault();
				});
				
				$('.onlyNumber').blur(function () {
					 if (this.value == '') return;

			         var RemoveComma = this.value.replace(/,/g, '');

			         if (RemoveComma.match(/^[+\-\d]*$/)) {
			        	 this.value = getAmountValue(RemoveComma);
			         } else {
			             alert("<spring:message code='Cache.ACC_msg_isNaN' />");
			             this.focus();
			             this.value = "";
			         }
			   });
			},
			setSelectCombo : function(){
				var Today = new Date();
				$( "select[name='fiscalYear']").each( function() {
					var Year = Today.getFullYear()+1;
					var obj = $(this);
					for (var i = 0; i < 10; i++)
			        {
						var option = $("<option value="+Year+">"+Year+"</option>");
						obj.append(option);
						Year--;
			        }
					obj.val(Today.getFullYear());
				});	
				
				makeDatepicker('Date','executeDate','','','');						
			},
			getBudgetAmount:function(){
				var fiscalYear = $( "select[name='fiscalYear']").val();
				var initiatorID = $( "input[name='initiatorID']").val();
				var costCenter = $( "input[name='costCenter']").val();
				var accountCode = $( "input[name='accountCode']").val();
				var standardBriefID = $( "input[name='standardBriefID']").val();
				var executeDate = XFN_ReplaceAllSpecialChars($( "#executeDate").val());
				
				if (costCenter == "") costCenter = initiatorID;
				
				if (costCenter == "") {
	            	Common.Error("<spring:message code='Cache.msg_EnterTheRequiredValue' />".replace("{0}","<spring:message code='Cache.ACC_lbl_costCenterName'/>")); //코스트스센터
	                return;
		        }
	            if (accountCode == "") {
	            	Common.Error("<spring:message code='Cache.msg_EnterTheRequiredValue' />".replace("{0}","<spring:message code='Cache.ACC_lbl_account'/>")); //계정코드
	                return;
	            }
	            if (executeDate == "") {
	            	Common.Error("<spring:message code='Cache.msg_EnterTheRequiredValue' />".replace("{0}","<spring:message code='Cache.lbl_evidDate'/>")); //증빙일자
	                return;
	            }
		            
				
				$.ajax({
					url	: "/account/budgetUse/getBudgetAmount.do",
					type: "POST",
					data: {
							"companyCode" :"${companyCode}"
						,	"fiscalYear"  :fiscalYear
						,	"costCenter"  : costCenter
						,	"accountCode" : accountCode
						,   "standardBriefID": standardBriefID
						,   "executeDate" : executeDate
						
					},
					success:function (result) {
						if(result.status == "SUCCESS"){
							var data = result.data;
							$("#budgetAmount").val(getAmountValue(data.RemainAmount));
							if (data.IsControl == "Y") {
								$("#isControl").attr("checked", true);
							}
							
						}else{
							Common.Error("<spring:message code='Cache.msg_NoDataList' />"); //예산데이타 없음
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); 
					}
				});
			},
			Save:function(){
				var fiscalYear = $( "select[name='fiscalYear']").val();
				var initiatorID = $( "input[name='initiatorID']").val();
				var costCenter = $( "input[name='costCenter']").val();
				var accountCode = $( "input[name='accountCode']").val();
				var standardBriefID = $( "input[name='standardBriefID']").val();
				var executeDate = XFN_ReplaceAllSpecialChars($( "#executeDate").val());
				var budgetAmount = parseInt($("#budgetAmount").val().replace(/,/g, ''));
				var usedAmount = parseInt($("#usedAmount").val().replace(/,/g, ''));
				var reservedStr1 = $( "input[name='reservedStr1']").val();
				

				if (costCenter == "") costCenter = initiatorID;
				
				if (costCenter == "") {
	            	Common.Error("<spring:message code='Cache.msg_EnterTheRequiredValue' />".replace("{0}","<spring:message code='Cache.ACC_lbl_costCenterName'/>")); //코스트스센터
	                return;
		        }
	            if (accountCode == "") {
	            	Common.Error("<spring:message code='Cache.msg_EnterTheRequiredValue' />".replace("{0}","<spring:message code='Cache.ACC_lbl_account'/>")); //계정코드
	                return;
	            }
	            if (executeDate == "") {
	            	Common.Error("<spring:message code='Cache.msg_EnterTheRequiredValue' />".replace("{0}","<spring:message code='Cache.lbl_evidDate'/>")); //증빙일자
	                return;
	            }
		            
	            if ($("#budgetAmount").val() == "" || $("#budgetAmount").val() == "0"){
	            	Common.Error("예산조회하기"); //금액 over
	                return;
	            	
	            }
	            
	            if($("#isControl").is(":checked") && ( budgetAmount<usedAmount))
	            {
	            	Common.Error("<spring:message code='Cache.msg_overPlanAmount' />"); //금액 over
	                return;
	            }

	            $.ajax({
					url	: "/account/budgetUse/addExecuteRegist.do",
					type: "POST",
					data: {
							"companyCode" : "${companyCode}"
						,	"fiscalYear"  :fiscalYear
						,	"costCenter"  : costCenter
						,	"accountCode" : accountCode
						,   "standardBriefID": standardBriefID
						,   "executeDate" : executeDate
						,   "usedAmount"  : $("#usedAmount").val().replace(/,/g, '') 
						,   "description" : $("#description").val()
						,   "initiatorID" : $("#initiatorID").val()
						,   "initiatorName" : $("#initiatorName").val()
						,   "initiatorDeptCode" : $("#initiatorDeptCode").val()
						,   "initiatorDeptName" : $("#initiatorDeptName").val()
						,   "reservedStr1" : $("#reservedStr1").val()
						,   "status"      : $("#status").val()
					},
					success:function (result) {
						if(result.status == "SUCCESS"){
							parent.Common.Inform("<spring:message code='Cache.msg_Been_saved'/>");	//저장되었습니다.
							BudgetUseAddPopup.closeLayer();								
							try{
								accountCtrl.popupCallBackStr([]);
							}catch (e) {
								coviCmn.traceLog(e);
								coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
							}
						}else{
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); 
					}
				});
			},
			userSearchPopup:function(){
				var popupName	=	"userSearchPopup";
				var popupID		=	"userSearchPopup";
				var openerID	=	"BudgetUseAddPopup";
				var popupYN		=   "Y";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_orgChart' />";	//CostCenter
				var callBack	=	"userSearchPopup_CallBack";
				var url			=	"/covicore/control/goOrgChart.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	"openerID="		+	openerID	+	"&"
								+   "popupYN="		+   popupYN	    +   "&"
								+   "type=B0&"
								+	"callBackFunc="	+	callBack;
				window[callBack] = window[openerID][callBack];
				parent.Common.open(	"",popupID,popupTit,url,"1000px","580px","iframe",true,null,null,true);
			},
			userSearchPopup_CallBack : function(orgData){
				var items		= JSON.parse(orgData).item;
				var arr			= items[0];
				var userName	= arr.DN.split(';');

				$("#initiatorID").val(arr.UserCode);
				$("#initiatorName").val(userName[0]);
				$("#initiatorDeptCode").val(arr.RG);
				$("#initiatorDeptName").val(arr.RGNM.split(';')[0]);

				if ("${costCenterType}" =="USER"){
					$("#costCenterName").val(userName[0]); 
					$("#costCenter").val(arr.UserCode) ;
				}	
			},
			
			costCenterSearchPopup : function(costType){
				if (costType == "USER"){
					var popupName	=	"userSearchPopup";
					var popupID		=	"userSearchPopup";
					var openerID	=	"BudgetUseAddPopup";
					var popupYN		=   "Y";
					var popupTit	=	"<spring:message code='Cache.ACC_lbl_orgChart' />";	//CostCenter
					var callBack	=	"costUserSearchPopup_CallBack";
					var url			=	"/covicore/control/goOrgChart.do?"
									+	"popupID="		+	popupID		+	"&"
									+	"popupName="	+	popupName	+	"&"
									+	"openerID="		+	openerID	+	"&"
									+   "popupYN="		+   popupYN	    +   "&"
									+   "type=B0&"
									+	"callBackFunc="	+	callBack;
					window[callBack] = window[openerID][callBack];
					parent.Common.open(	"",popupID,popupTit,url,"1000px","580px","iframe",true,null,null,true);
				}
				else{
					var popupName	=	"CostCenterSearchPopup";
					var popupID		=	"CostCenterSearchPopup";
					var openerID	=	"BudgetUseAddPopup";
					var popupYN		=   "Y";
					var popupTit	=	"<spring:message code='Cache.ACC_lbl_costCenter' />";	//CostCenter
					var callBack	=	"costCenterSearchPopup_CallBack";
					var url			=	"/account/accountCommon/accountCommonPopup.do?"
									+	"popupID="		+	popupID		+	"&"
									+	"popupName="	+	popupName	+	"&"
									+	"openerID="		+	openerID	+	"&"
									+   "popupYN="		+   popupYN	    +   "&"
									+	"callBackFunc="	+	callBack;
					parent.Common.open(	"",popupID,popupTit,url,"600px","730px","iframe",true,null,null,true);
				}	
			},
			costCenterSearchPopup_CallBack : function(value){
				if(value != null){
					$("#costCenterName").val(value.CostCenterName); 
					$("#costCenter").val(value.CostCenterCode) ;
				}
			},
			costUserSearchPopup_CallBack : function(orgData){
				var items		= JSON.parse(orgData).item;
				var arr			= items[0];
				var userName	= arr.DN.split(';');

				$("#costCenterName").val(userName[0]); 
				$("#costCenter").val(arr.UserCode) ;
			},
			accountSearchPopup : function(id){
				var me = this;
				me.objId = id;
				var popupName	=	"AccountSearchPopup";
				var popupID		=	"AccountSearchPopup";
				var openerID	=	"BudgetUseAddPopup";
				var popupYN		=   "Y";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_account' />";	//CostCenter
				var callBack	=	"accountSearchPopup_CallBack";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	"openerID="		+	openerID	+	"&"
								+   "popupYN="		+   popupYN	    +   "&"
								+	"callBackFunc="	+	callBack;
				parent.Common.open(	"",popupID,popupTit,url,"800px","730px","iframe",true,null,null,true);
			},
			accountSearchPopup_CallBack:function(value){
				if(value != null){
					$("#accountName").val(value.AccountName);
					$("#accountCode").val(value.AccountCode);
				}
			},
			standardBriefSearchPopup : function(id){
				var me = this;
				me.objId = id;
				var popupName	=	"StandardBriefSearchPopup";
				var popupID		=	"StandardBriefSearchPopup";
				var openerID	=	"BudgetUseAddPopup";
				var popupYN		=   "Y";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_account' />";	//CostCenter
				var callBack	=	"standardBriefSearchPopup_CallBack";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	"openerID="		+	openerID	+	"&"
								+   "popupYN="		+   popupYN	    +   "&"
								+	"callBackFunc="	+	callBack;
				parent.Common.open(	"",popupID,popupTit,url,"800px","730px","iframe",true,null,null,true);
			},
			standardBriefSearchPopup_CallBack:function(value){
				if(value != null){
					$("#accountName").val(value.AccountName);
					$("#accountCode").val(value.AccountCode);
					$("#standardBriefName").val(value.StandardBriefName);
					$("#standardBriefID").val(value.StandardBriefID);
				}
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
	window.BudgetUseAddPopup = BudgetUseAddPopup;
})(window);

BudgetUseAddPopup.popupInit();	
</script>