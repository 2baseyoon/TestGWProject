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
.onlyNumber{width: 70px; float: left; text-align:right; ime-mode:disabled;}
.soundTable td > input {
    margin: 0px 6px 0px 0px;
}
</style>
<% 
String IsUseStandardBrief = RedisDataUtil.getBaseConfig("IsUseStandardBrief");
if (!IsUseStandardBrief.equals("Y")) out.println("<style>.StandardBrief{display:none}</style>");
%>
<%-- <c:set var="costName" value="Cache.ACC_lbl_costCenterName" />
<c:if test="${costCenterType eq 'USER'}">
	<c:set var="costName" value="Cache.ObjectType_UR" />
</c:if> --%>
<body>
<%-- <input id="costCenterType" type="hidden" value="${costCenterType}"> --%>
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
								<th><spring:message code='Cache.ACC_lbl_budget' /><spring:message code='Cache.lbl_apv_vacation_year' />	<!-- 예산년도 --></th>
								<td>
									<select id="fiscalYear" name="fiscalYear"  style="width:150px" ></select>
								</td>
							</tr>
							<tr>
								<th><spring:message code='Cache.ACC_lbl_budgetType' /></th>	<!-- 예산타입 -->
								<td>
									<input name="budgetType" id="DEPTBudget" type="radio" onclick="BudgetRegistAddPopup.initCostCenter()" value="DEPT" checked="checked">
									<label for=DEPTBudget><spring:message code='Cache.ACC_lbl_deptBudget'/></label> <!-- 부서 예산 -->
									<input name="budgetType" id="USERBudget" type="radio" onclick="BudgetRegistAddPopup.initCostCenter()" value="USER" style="margin-left: 15px;">
									<label for="USERBudget"><spring:message code='Cache.ACC_lbl_userBudget'/></label> <!-- 사용자 예산 -->
								</td>
							</tr>
							<tr>
								<th><spring:message code="Cache.ACC_lbl_DeptUser"/></th>	<!-- 부서/사용자  -->
								<td>
									<input name="companyCode" type="hidden" value="${companyCode}"/>
									<input id="costCenter" name="costCenter" type="hidden" />
									<input id="costCenterName" name="costCenterName" type="text" readonly="readonly">
									<button class="btn_search03" type="button" onclick="BudgetRegistAddPopup.costCenterSearchPopup();"></button>
								</td>
							</tr>
							<tr>
								<th><spring:message code='Cache.ACC_lbl_budget' /><spring:message code='Cache.ACC_lbl_accountName' /> <!-- 예산계정과목 --></th>
								<td>
									<input id="accountCode" name="accountCode" type="hidden" />
									<input id="accountName" name="accountName" type="text" readonly="readonly">
									<button class="btn_search03" type="button" onclick="BudgetRegistAddPopup.accountSearchPopup();"></button>
								</td>
							</tr>
							<tr class="StandardBrief">
								<th><spring:message code='Cache.ACC_lbl_budget' /><spring:message code='Cache.ACC_standardBrief' /> <!-- 표준적요 --></th>
								<td>
									<input id="standardBriefID" name="standardBriefID" type="hidden" />
									<input id="standardBriefName" name="standardBriefName" type="text" readonly="readonly" />
									<button class="btn_search03" type="button" onclick="BudgetRegistAddPopup.standardBriefSearchPopup();"></button>
								</td>
							</tr>
							<tr>
								<th><spring:message code='Cache.ACC_lbl_budget' /><spring:message code='Cache.lbl_SchDivision'/>	<!-- 예산구분 --></th>
								<td>
									<div class="box">
										<span id="baseTerm" class="selectType01" ></span>
									</div>
								</td>
							</tr>
							<tr>
								<th><spring:message code='Cache.ACC_lbl_isUse'/>	<!-- 사용여부 --></th>
								<td>
									<div class="box">
									<span id="isUse" class="selectType01"></span>
									</div>
								</td>
							</tr>
							<tr>
								<th><spring:message code='Cache.ACC_lbl_control'/>	<!-- 통제여부 --></th>
								<td>
									<div class="box">
										<span id="isControl" class="selectType01"></span>
									</div>
								</td>
							</tr>
						</tbody>
					</table>
	
					<table id="tbMonth" class="soundTable Month" cellpadding="0" cellspacing="0" width="100%" style="margin-top:5px; border-top:1px solid #d7d7d7; display:none;">
						<colgroup>
							<col width="8%" />
							<col width="25%" />
							<col width="8%" />
							<col width="25%" />
							<col width="8%" />
							<col width="25%" />
						</colgroup>
						<tbody>
							<c:set var="iM" value="0"/>
							<c:forEach var="i" begin="0" end="3">
								<tr>
									<c:forEach var="j" begin="0" end="2">
										<c:set var="iM" value="${iM+ 1}"/>
										<th>${iM}월</th>
										<td style="padding:5px 2px">
											<span id="${iM}M" style="width:60px; float:left; margin-top:2px; margin-right:5px; text-align:right;"></span>
											<input id="${iM}MDiff" type="text" class="onlyNumber" onblur="BudgetRegistAddPopup.SetSum('Month',this);" />
										</td>
									</c:forEach>
								</tr>
							</c:forEach>
							<tr>
								<th>합계</th>
								<td colspan=5>
									<span id="MonthSum" style="width:70px; float:left; margin-top:2px; margin-right:5px; text-align:right;"></span>
									<span id="MonthSumChange" style="width:70px; float:left; margin-top:2px; margin-right:5px; text-align:right; color:red;"></span>
								</td>
							</tr>
						</tbody>
					</table>
					<table id="tbQuarter" class="soundTable Quarter" cellpadding="0" cellspacing="0" width="100%" style="margin-top:5px; border-top:1px solid #d7d7d7; display:none;">
						<colgroup>
							<col width="20%" />
							<col width="30%" />
							<col width="20%" />
							<col width="30%" />
						</colgroup>
						<tbody>
							<c:set var="iQ" value="0"/>
							<c:forEach var="i" begin="0" end="1">
								<tr>
									<c:forEach var="j" begin="0" end="1">
									<c:set var="iQ" value="${iQ+ 1}"/>
									<th>${iQ}/4분기</th>
									<td style="padding:5px 2px">
										<span id="${iQ}Q" style="width:90px; float:left; margin-top:2px; margin-right:5px; text-align:right;"></span>
										<input id="${iQ}QDiff" type="text" class="onlyNumber" onblur="BudgetRegistAddPopup.SetSum('Quarter',this);" />
									</td>
									</c:forEach>
								</tr>
							</c:forEach>
							<tr>
								<th>합계</th>
								<td colspan=3>
									<span id="QuarterSum" style="width:90px; float:left; margin-top:2px; margin-right:5px; text-align:right;"></span>
									<span id="QuarterSumChange" style="width:90px; float:left; margin-top:2px; margin-right:5px; text-align:right; color:red;"></span>
								</td>
							</tr>
						</tbody>
					</table>
					<table id="tbHalf" class="soundTable Half" cellpadding="0" cellspacing="0" width="100%" style="margin-top:5px; border-top:1px solid #d7d7d7; display:none;">
						<colgroup>
							<col width="20%" />
							<col width="30%" />
							<col width="20%" />
							<col width="30%" />
						</colgroup>
						<tbody>
							<tr>
								<th>상반기</th>
								<td style="padding:5px 2px">
									<span id="1H" style="width:90px; float:left; margin-top:2px; margin-right:5px; text-align:right;"></span>
									<input id="1HDiff" type="text" class="onlyNumber" onblur="BudgetRegistAddPopup.SetSum('Half',this);" />
								</td>
								<th>하반기</th>
								<td style="padding:5px 2px">
									<span id="2H" style="width:90px; float:left; margin-top:2px; margin-right:5px; text-align:right;"></span>
									<input id="2HDiff" type="text" class="onlyNumber" onblur="BudgetRegistAddPopup.SetSum('Half',this);" />
								</td>
							</tr>
							<tr>
								<th>합계</th>
								<td colspan="3">
									<span id="HalfSum" style="width:100px; float:left; margin-top:2px; margin-right:5px; text-align:right;"></span>
									<span id="HalfSumChange" style="width:90px; float:left; margin-top:2px; margin-right:5px; text-align:right; color:red;"></span>
								</td>
							</tr>
						</tbody>
					</table>
					<table id="tbYear" class="soundTable Year" cellpadding="0" cellspacing="0" width="100%" style="margin-top:5px; border-top:1px solid #d7d7d7;">
						<colgroup>
							<col style = "width: 200px;">
							<col style = "width: auto;">
						</colgroup>
						<tbody>
							<tr>
								<th>금액</th>
								<td>
									<span id="1Y" style="width:90px; float:left; margin-top:2px; margin-right:5px; text-align:right;"></span>
									<input id="1YDiff" type="text" class="onlyNumber" onblur=" BudgetRegistAddPopup.SetSum('Year',this);" />
									<span id="YearSumChange" style="width:90px; float:left; margin-top:2px; margin-right:5px; text-align:right; color:red;"></span>
								</td>
							</tr>
						</tbody>
					</table>
					<table id="tbDate" class="soundTable Date" cellpadding="0" cellspacing="0" width="100%" style="margin-top:5px; border-top:1px solid #d7d7d7; display:none;">
						<colgroup>
							<col style = "width: 200px;">
							<col width="*" />
						</colgroup>
						<tbody>
							<tr>
								<th>기간</th>
								<td>
									<div id="validDate" class="dateSel type02"></div>
								</td>
							</tr>
							<tr>
								<th>금액</th>
								<td>
									<span id="Date" style="width:90px; float:left; margin-top:2px; margin-right:5px; text-align:right;"></span>
									<input id="DateDiff" type="text" class="onlyNumber" onblur="BudgetRegistAddPopup.SetSum('Date',this);" />
									<span id="DateSumChange" style="width:90px; float:left; margin-top:2px; margin-right:5px; text-align:right; color:red;"></span>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				<div class="bottom">
					<a onclick="BudgetRegistAddPopup.Save();"		id="btnSave"	class="btnTypeDefault btnTypeChk"><spring:message code='Cache.ACC_btn_save'/></a> 	<!-- 저장 -->
					<a onclick="BudgetRegistAddPopup.closeLayer();"	id="btnClose"	class="btnTypeDefault"><spring:message code='Cache.btn_Cancel'/></a>				<!-- 취소 -->
				</div>
			</div>
		</div>
	</div>
</body>
<script>

if (!window.BudgetRegistAddPopup) {
	window.BudgetRegistAddPopup = {};
}

(function(window) {
	var BudgetRegistAddPopup = {
			baseTerm : "Year",
			
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
				
				$('#baseTerm select.selectType01').change(function () {
					 me.changeBaseTerm(this);
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
				
				var AXSelectMultiArr	= [	
											{'codeGroup':'BaseTerm',	'target':'baseTerm',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
										,	{'codeGroup':'IsUse',		'target':'isUse',			'lang':'ko',	'onchange':'',	'oncomplete':''}
										,	{'codeGroup':'IsControl',	'target':'isControl',		'lang':'ko',	'onchange':'',	'oncomplete':''}
									]
				accountCtrl.renderAXSelectMulti(AXSelectMultiArr);
				makeDatepicker('validDate','validFrom','validTo','','','');						
			},
			changeBaseTerm:function(obj){
				BudgetRegistAddPopup.baseTerm = $(obj).val();
				$("#tbYear").hide();
				$("#tbHalf").hide();
				$("#tbQuarter").hide();
				$("#tbMonth").hide();
				$("#tbDate").hide();
				
                $("#tb" + BudgetRegistAddPopup.baseTerm).show();
			},
			SetSum:function(baseTerm, obj) {
				var obj = $("#tb" + baseTerm)
		        var sumValue = 0;
				
				/*if (baseTerm == "Year")
					sumValue = sumValue + Number(obj.find("#1Y").text().replace(/,/g, ''));
				else
					sumValue = sumValue + Number(obj.find("#"+baseTerm+"Sum").text().replace(/,/g, ''));
*/
				obj.find("input").each(function (i){
	            	if($(this).val().length>0){
	            		sumValue = sumValue + Number($(this).val().replace(/,/g, ''));
	            	}	
	            })	
                obj.find("#"+baseTerm+"Sum").text(getAmountValue(sumValue));
			}, 
			Save:function(){
				var aJsonArray = new Array();
				var baseTerm = BudgetRegistAddPopup.baseTerm;
				var obj = $("#tb" + baseTerm);
				obj.find("input").each(function (i){
	            	if($(this).val().length>0){
	            		var diffExp = Number($(this).val().replace(/,/g, ''));
	            		if (diffExp != "" && diffExp != 0 && !isNaN(diffExp)) {
		            		var periodLabel = $(this).attr("id").substring(0, $(this).attr("id").length-4)
		            		var saveData = { "periodLabel": periodLabel, "budgetAmount": diffExp};
                            aJsonArray.push(saveData);
	            		}
	            	}	
	            })	
	
				var aJson = {"companyCode":$("input[name='companyCode").val()
						, "fiscalYear":$("#fiscalYear").val() 
						, "costCenter": $("#costCenter").val()  
						, "accountCode": $("#accountCode").val() 
						, "standardBriefID": $("#standardBriefID").val() 
						, "baseTerm" : baseTerm
						, "isControl" : $("#isControl select").val() 
						, "isUse" : $("#isUse select").val() 
						, "validFrom" : $("#validFrom").val() 
						, "validTo" : $("#validTo").val() 
						, "costCenterType" : $("input[name=budgetType]:checked").val()
						, "saveList": aJsonArray};

				$.ajax({
					type:"POST",
					url:"/account/budgetRegist/addBudgetRegist.do",
					data:{"saveObj"		: JSON.stringify(aJson)},
					success:function (data) {
						if(data.status == "SUCCESS"){
							
							parent.Common.Inform("<spring:message code='Cache.msg_Been_saved'/>");	//저장되었습니다.
							BudgetRegistAddPopup.closeLayer();								
							try{
								accountCtrl.popupCallBackStr([]);
							}catch (e) {
								coviCmn.traceLog(e);
								coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
							}
							
						} else {
							var errorStr = "";
							
							if (data.result == "dup") {
								errorStr = "<spring:message code='Cache.msg_CheckDoubleAlert' />"; // 중복확인이 필요합니다
							} else if (data.result == "type") {
								var type = $("input[name=budgetType]:not(:checked)").val(); // DEPT / USER
								var typeStr = $("label[for="+type+"Budget]").text(); 		// 부서 예산 / 사용자 예산
								errorStr = String.format("<spring:message code='Cache.ACC_msg_CheckCostCenterTypeAlert' />", typeStr);
							} else if (data.result == "cc") {
								errorStr = "<spring:message code='Cache.ACC_msg_CheckCostCenterAlert' />"; // 코스트센터가 존재하지 않습니다.
							} else {
								errorStr = "<spring:message code='Cache.msg_ErrorOccurred' />"; // 오류가 발생했습니다. 관리자에게 문의바랍니다
							}
							
							Common.Error(errorStr);
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); // 오류가 발생했습니다. 관리자에게 문의바랍니다
					}
				});
				
			},
			initCostCenter : function() {
				$("#costCenter").val('');
				$("#costCenterName").val('');
			},
			costCenterSearchPopup : function(){
				var costType = $("input[name=budgetType]:checked").val();
				
				if (costType == "USER"){
					var popupName	=	"userSearchPopup";
					var popupID		=	"userSearchPopup";
					var openerID	=	"BudgetRegistAddPopup";
					var popupYN		=   "Y";
					var popupTit	=	"<spring:message code='Cache.ACC_lbl_orgChart' />";	//CostCenter
					var callBack	=	"userSearchPopup_CallBack";
					var url			=	"/covicore/control/goOrgChart.do?"
									+	"popupID="		+	popupID		+	"&"
									+	"popupName="	+	popupName	+	"&"
									+	"openerID="		+	openerID	+	"&"
									+   "popupYN="		+   popupYN	    +   "&"
									+	"companyCode="  + $("input[name='companyCode").val() + "&"
									+   "type=B0&"
									+	"callBackFunc="	+	callBack;
					window[callBack] = window[openerID][callBack];
					parent.Common.open(	"",popupID,popupTit,url,"1000px","580px","iframe",true,null,null,true);
				}
				else
				{
					var popupName	=	"CostCenterSearchPopup";
					var popupID		=	"CostCenterSearchPopup";
					var openerID	=	"BudgetRegistAddPopup";
					var popupYN		=   "Y";
					var popupTit	=	"<spring:message code='Cache.ACC_lbl_costCenter' />";	//CostCenter
					var callBack	=	"costCenterSearchPopup_CallBack";
					var url			=	"/account/accountCommon/accountCommonPopup.do?"
									+	"popupID="		+	popupID		+	"&"
									+	"popupName="	+	popupName	+	"&"
									+	"openerID="		+	openerID	+	"&"
									+   "popupYN="		+   popupYN	    +   "&"
									+	"companyCode="  + $("input[name='companyCode").val() + "&"
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
			userSearchPopup_CallBack : function(orgData){
				var items		= JSON.parse(orgData).item;
				var arr			= items[0];
				var userName	= arr.DN.split(';');

				$("#costCenter").val(arr.UserCode);
				$("#costCenterName").val(userName[0]);
			},
			accountSearchPopup : function(id){
				var me = this;
				me.objId = id;
				var popupName	=	"AccountSearchPopup";
				var popupID		=	"AccountSearchPopup";
				var openerID	=	"BudgetRegistAddPopup";
				var popupYN		=   "Y";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_account' />";	//CostCenter
				var callBack	=	"accountSearchPopup_CallBack";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	"openerID="		+	openerID	+	"&"
								+   "popupYN="		+   popupYN	    +   "&"
								+	"companyCode="  + $("input[name='companyCode").val() + "&"
								+	"callBackFunc="	+	callBack;
				parent.Common.open(	"",popupID,popupTit,url,"800px","730px","iframe",true,null,null,true);
			},
			accountSearchPopup_CallBack:function(value){
				var me = this;
				if(value != null){
					var obj = $("#Budget"+me.objId);
					$("#accountName").val(value.AccountName);
					$("#accountCode").val(value.AccountCode);
				}
			},
			standardBriefSearchPopup : function(id){
				var me = this;
				me.objId = id;
				var popupName	=	"StandardBriefSearchPopup";
				var popupID		=	"StandardBriefSearchPopup";
				var openerID	=	"BudgetRegistAddPopup";
				var popupYN		=   "Y";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_account' />";	//CostCenter
				var callBack	=	"standardBriefSearchPopup_CallBack";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	"openerID="		+	openerID	+	"&"
								+   "popupYN="		+   popupYN	    +   "&"
								+	"companyCode="  + $("input[name='companyCode").val() + "&"
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
	window.BudgetRegistAddPopup = BudgetRegistAddPopup;
})(window);

BudgetRegistAddPopup.popupInit();
</script>