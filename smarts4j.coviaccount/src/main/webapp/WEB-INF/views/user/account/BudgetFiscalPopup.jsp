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
<style>
.onlyNumber{width: 70px; float: left; text-align:right; ime-mode:disabled;}
</style>
<body>
<input id="costCenterType" type="hidden" value="${costCenterType}">
	<div class="layer_divpop ui-draggable docPopLayer" style="width:100%;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
			
			<div class="middle">
					<table class="soundTable" style="width:100%">
						<colgroup>
							<col style = "width: 200px;">
							<col style = "width: auto;">
						</colgroup>
						<tbody>
	                      <tr>
	                          <th><spring:message code='Cache.lbl_CorpName' />	<!-- 회사명 --></th>
				              <td>
								<span id="companyCode" class="selectType02">
								</span>
	                          </td>
			              </tr>
	                      <tr>
	                          <th><spring:message code='Cache.ACC_lbl_acounting' /><spring:message code='Cache.lbl_apv_vacation_year' />	<!-- 예산년도 --></th>
				              <td>
	                              <select id="fiscalYear" name="fiscalYear"  Width="150" ></select>
	                          </td>
			              </tr>
	                      <tr>
	                          <th><spring:message code='Cache.ACC_lbl_acounting' /><spring:message code='Cache.lbl_apv_vacation_year' /><spring:message code="Cache.lbl_Start" /> <!-- costcenter --></th>
				              <td>
	                              <select id="yearStart" name="yearStart"  Width="150"   onchange="BudgetFiscalPopup.changeFiscalMonth(this,'S')">
	                              	<c:forEach var="i" begin="1" end="12" step="1">
										<option value="${i}">${i}<spring:message code='Cache.lbl_sch_mon' /></option>
									</c:forEach>
	                              </select>
	                          </td>
			              </tr>
	                      <tr>
	                          <th><spring:message code='Cache.ACC_lbl_acounting' /><spring:message code='Cache.lbl_apv_vacation_year' /><spring:message code="Cache.lbl_Exit" /> <!-- costcenter --></th>
				              <td>
	                              <select id="yearEnd" name="yearEnd"  Width="150"   onchange="BudgetFiscalPopup.changeFiscalMonth(this,'E')">
	                              	<c:forEach var="i" begin="1" end="12" step="1">
										<option value="${i}">${i}<spring:message code='Cache.lbl_sch_mon' /></option>
									</c:forEach>
	                              </select>
	                          </td>
			              </tr>

						</tbody>
					</table>
				</div>
				<div class="bottom">
					<a onclick="BudgetFiscalPopup.Save();"	id="btnSave"	class="btnTypeDefault btnTypeChk"><spring:message code='Cache.ACC_btn_save'/></a> 	<!-- 저장 -->
					<a onclick="BudgetFiscalPopup.closeLayer();"			id="btnClose"	class="btnTypeDefault"><spring:message code='Cache.btn_Cancel'/></a>				<!-- 취소 -->
				</div>
			</div>
		</div>	
	</div>
</body>
<script>

if (!window.BudgetFiscalPopup) {
	window.BudgetFiscalPopup = {};
}

(function(window) {
	var BudgetFiscalPopup = {
			baseTerm : "Year",
			
			/**
			화면 초기화
			*/
			popupInit : function(){
				var me = this;
				me.setSelectCombo();
			},
			setSelectCombo : function(){
				var Today = new Date();
				var Year = Today.getFullYear()-1;
				var obj = $("#fiscalYear");

				for (var i = 0; i < 3; i++)
		        {
					var option = $("<option value="+Year+">"+Year+"</option>");
					obj.append(option);
					Year++;
		        }
				obj.val(Today.getFullYear());
				if ("${FirstMonthOfFiscalYear}" != "")
					$("#yearStart").val(parseInt("${FirstMonthOfFiscalYear}"));
				else
					$("#yearStart").val(1);
					
				if ("${LastMonthOfFiscalYear}" != "")
					$("#yearEnd").val(parseInt("${LastMonthOfFiscalYear}"));
				else
					$("#yearEnd").val(12);
				
				var AXSelectMultiArr	= [	
											{'codeGroup':'CompanyCode',		'target':'companyCode',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'ALL'}
									]
				accountCtrl.renderAXSelectMulti(AXSelectMultiArr);

			},
			changeFiscalMonth : function(obj, sType){
				var year= parseInt($(obj).val(),10);
				if (sType == "S")
				{
			        if (year == 1) year = 12;
		        	else			year--;
			        $("#yearEnd").val(year);
				}
				else{
			        if (year == 12) year = 1;
		        	else			year++;
			        $("#yearStart").val(year);
				}
			},
			Save:function(){
				$.ajax({
					type:"POST",
					url:"/account/budgetFiscal/addBudgetFiscal.do",
					data:{"companyCode"		: accountCtrl.getComboInfo("companyCode").val()	//회사코드
						,"fiscalYear"		: $("#fiscalYear").val() 
						,"yearStart":(parseInt($("#yearStart").val())<10?"0"+$("#yearStart").val():$("#yearStart").val())
						,"yearEnd":  (parseInt($("#yearEnd").val())  <10?"0"+$("#yearEnd").val()  :$("#yearEnd").val())},
					success:function (data) {
						if(data.result == "ok"){
							
							parent.Common.Inform("<spring:message code='Cache.msg_Been_saved'/>");	//저장되었습니다.
							BudgetFiscalPopup.closeLayer();								
							try{
								accountCtrl.popupCallBackStr([]);
							}catch (e) {
								coviCmn.traceLog(e);
								coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
							}
							
						}
						else{
							Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); //	오류가 발생했습니다. 관리자에게 문의바랍니다
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); //	오류가 발생했습니다. 관리자에게 문의바랍니다
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
	window.BudgetFiscalPopup = BudgetFiscalPopup;
})(window);

BudgetFiscalPopup.popupInit();
</script>