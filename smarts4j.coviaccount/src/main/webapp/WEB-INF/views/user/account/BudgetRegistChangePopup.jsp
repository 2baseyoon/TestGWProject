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
<body>	
	<input id="companyCode" type="hidden" />
	<input id="registID" type="hidden" />
	<input id="chgType" type="hidden" />
	<input id="costCenterType" type="hidden" />
	<div class="layer_divpop ui-draggable docPopLayer" style="width:100%;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="popContent" style="position:relative;width:100%;" >
			<div class="middle">
				<div class="bodysearch_Type01">
					<div class="inPerView type08">
						<%--
						<input type="radio" id="a1" name="chgType" class="AXInput av-required"  value="Shift" onclick="BudgetRegistChangePopup.changeType(this)"/>
						<label for="a1"><spring:message code='Cache.ACC_lbl_budget' /><spring:message code='Cache.lbl_Use' /><!-- 예산이용 -->
						<input type="radio" id="a2" name="chgType" class="AXInput av-required"  value="Dedicate"  onclick="BudgetRegistChangePopup.changeType(this)"/>
						<label for="a2"><spring:message code='Cache.ACC_lbl_budget' /><spring:message code='Cache.lbl_Only' /></label><!-- 예산전용 -->
						--%>
						<input type="radio" id="a3" name="chgType" class="AXInput av-required" value="Change"  onclick="BudgetRegistChangePopup.changeType(this)"/>
						<label for="a3"><spring:message code='Cache.ACC_lbl_budget' /><spring:message code='Cache.lbl_change' /></label><!-- 예산변경 -->
					</div>
				</div>
				<%
				/* String[][] list = { {"Before","Cache.ACC_lbl_budgetCuts"},{"After","Cache.ACC_lbl_buegetIncrease"}, {"Change", "Cache.ACC_lbl_budgetChange"}}; */
				String[][] list = {{"Change", "Cache.ACC_lbl_budgetChange"}};
				request.setAttribute("list",list);
				%>
				<c:forEach items="${list}" var="list" varStatus="status">
					<div id="Budget${list[0]}" class="before" style="display:none1">
	
						<p style="height: 20px; font-weight: bold; margin-top:15px;">○ <spring:message code='${list[1]}' /></p>
						<table class="soundTable">
							<colgroup>
								<col width="20%" />
								<col width="*" />
							</colgroup>
							<tbody>
								<tr>
									<th><spring:message code='Cache.ACC_lbl_budget' /><spring:message code='Cache.lbl_apv_vacation_year' /></th>	<!-- 예산년도 -->
									<td>
										<select name="fiscalYear"  style="width:150px" disabled></select>
										<input id="baseTerm" name="baseTerm" type="hidden" />
									</td>
								</tr>
								<tr>
									<th><spring:message code="Cache.ACC_lbl_DeptUser"/> <!-- 부서/사용자 --></th>
									<td>
										<input name="companyCode" type="hidden" value="${companyCode}"/>
										<input name="costCenter" type="hidden" />
										<input name="costCenterName" type="text" disabled>
										<%-- <button class="btnSearchType01" type="button" onclick="BudgetRegistChangePopup.costCenterSearchPopup('${list[0]}');"></button> --%>
									</td>
								</tr>
								<tr>
									<th><spring:message code='Cache.ACC_lbl_budget' /><spring:message code='Cache.ACC_lbl_accountName' /></th> <!-- 예산계정과목 -->
									<td>
										<input name="accountCode" type="hidden" />
										<input name="accountName" type="text" disabled>
										<%-- <button class="btnSearchType01" type="button" onclick="BudgetRegistChangePopup.accountSearchPopup('${list[0]}');"></button> --%>
									</td>
								</tr>
								<tr class="StandardBrief">
									<th><spring:message code='Cache.ACC_lbl_budget' /><spring:message code='Cache.ACC_standardBrief' /></th> <!-- 표준적요 -->
									<td>
										<input name="standardBriefID" type="hidden" />
										<input name="standardBriefName" type="text" disabled />
										<%-- <button class="btnSearchType01" type="button" onclick="BudgetRegistChangePopup.standardBriefSearchPopup('${list[0]}');"></button> --%>
										<%-- <a onclick="BudgetRegistChangePopup.getBudgetRegistItem('${list[0]}');"	id="btnSave" class="btnTypeDefault btnTypeChk"><spring:message code='Cache.Acc_lbl_budgetCheck' /></a> --%>
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
												<input id="${iM}MDiff" type="text" class="onlyNumber" onblur="BudgetRegistChangePopup.SetSum('${list[0]}','Month',this);" />
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
												<input id="${iQ}QDiff" type="text" class="onlyNumber" onblur="BudgetRegistChangePopup.SetSum('${list[0]}','Quarter',this);" />
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
										<input id="1HDiff" type="text" class="onlyNumber" onblur="BudgetRegistChangePopup.SetSum('${list[0]}','Half',this);" />
									</td>
									<th>하반기</th>
									<td style="padding:5px 2px">
										<span id="2H" style="width:90px; float:left; margin-top:2px; margin-right:5px; text-align:right;"></span>
										<input id="2HDiff" type="text" class="onlyNumber" onblur="BudgetRegistChangePopup.SetSum('${list[0]}','Half',this);" />
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
						<table id="tbYear" class="soundTable Year" cellpadding="0" cellspacing="0" width="100%" style="margin-top:5px; border-top:1px solid #d7d7d7; display:none;">
							<colgroup>
								<col width="20%" />
								<col width="80%" />
							</colgroup>
							<tbody>
								<tr>
									<th>금액</th>
									<td>
										<span id="1Y" style="width:90px; float:left; margin-top:2px; margin-right:5px; text-align:right;"></span>
										<input id="1YDiff" type="text" class="onlyNumber" onblur="BudgetRegistChangePopup.SetSum('${list[0]}','Year',this);" />
										<span id="YearSumChange" style="width:90px; float:left; margin-top:2px; margin-right:5px; text-align:right; color:red;"></span>
									</td>
								</tr>
							</tbody>
						</table>
						<table id="tbDate" class="soundTable Date" cellpadding="0" cellspacing="0" width="100%" style="margin-top:5px; border-top:1px solid #d7d7d7; display:none;">
							<colgroup>
								<col width="20%" />
								<col width="30%" />
								<col width="20%" />
								<col width="30%" />
							</colgroup>
							<tbody>
								<tr>
									<th>시작일</th>
									<td>
										<span id="StartDate" style="width:90px; float:left; margin-top:2px; margin-right:5px;"></span>
									</td>
									<th>종료일</th>
									<td>
										<span id="EndDate" style="width:90px; float:left; margin-top:2px; margin-right:5px;"></span>
									</td>
								</tr>
								<tr>
									<th>금액</th>
									<td colspan="3">
										<span id="Date" style="width:90px; float:left; margin-top:2px; margin-right:5px; text-align:right;"></span>
										<input id="DateDiff" type="text" class="onlyNumber" onblur="BudgetRegistChangePopup.SetSum('${list[0]}','Date',this);" " />
										<span id="DateSumChange" style="width:90px; float:left; margin-top:2px; margin-right:5px; text-align:right; color:red;"></span>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
				</c:forEach>
				<table class="soundTable">
					<colgroup>
						<col width="30%" />
						<col width="70%" />
					</colgroup>
					<tbody>
						<tr>
							<th>변경사유</td>
							<td><textarea id="memo" style="width:90%" rows="5" cols="1"></textarea></td>
						</tr>
					</tbody>
				</table>
			</div>
			<div class="bottom">
				<a onclick="BudgetRegistChangePopup.Save(this);"	id="btnSave" class="btnTypeDefault btnTypeChk"><spring:message code='Cache.ACC_btn_save' /></a>
				<a onclick="BudgetRegistChangePopup.closeLayer();"	id="btnClose" class="btnTypeDefault"><spring:message code='Cache.btn_Cancel' /></a>
			</div>
		</div>
</body>
<script>

	if (!window.BudgetRegistChangePopup) {
		window.BudgetRegistChangePopup = {};
	}
	
	(function(window) {
		var BudgetRegistChangePopup = {
				//baseTerm : "",
				chgType : "",
				objId   : "",
				
				/**
				화면 초기화
				*/
				popupInit : function(){
					var me = this;
					var param = location.search.substring(1).split('&');
					for(var i = 0; i < param.length; i++){
						var paramKey	= param[i].split('=')[0];
						var paramValue	= param[i].split('=')[1];
						$("#"+paramKey).val(paramValue);
					}
					
					me.setSelectCombo();
					me.getPopupInfo();
					
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
				},
				changeType : function(obj){
					BudgetRegistChangePopup.chgType = obj.value;
					if (obj.value	== "Change")	//예산변경시
					{
	                	$("#memo").height(250);
		                $("#BudgetChange").show();
		                $("#BudgetAfter").hide();
		                $("#BudgetBefore").hide();
					}
					else
					{
	                	$("#memo").height(85);
		                $("#BudgetChange").hide();
		                $("#BudgetAfter").show();
		                $("#BudgetBefore").show();
					}
				},
				//팝업 정보
				getPopupInfo : function(){
					var companyCode = $("#companyCode").val();
					var chgType = $('#chgType').val();
					var registID = $("#registID").val();
					
					$( "input[name='chgType']").each( function() {
						if ($( this ).val() == chgType) {
							$(this).prop("checked", true);
							BudgetRegistChangePopup.changeType(this);
							return;
						}
					});
					
					$.ajax({
						url	:"/account/budgetRegist/getBudgetRegistInfo.do",
						type: "POST",
						data: {
							"registID"		: registID,
							"companyCode"	: companyCode
						},
						async: false,
						success:function (data) {
							if (data.status == "SUCCESS") {
								var getInfo = data.list;
								$("#Budget"+chgType+" input[name='costCenter']").val(getInfo.CostCenter);
								$("#Budget"+chgType+" input[name='costCenterName']").val(getInfo.CostCenterName);
								$("#Budget"+chgType+" input[name='accountCode']").val(getInfo.AccountCode);
								$("#Budget"+chgType+" input[name='accountName']").val(getInfo.AccountName);
								$("#Budget"+chgType+" input[name='standardBriefID']").val(getInfo.StandardBriefID);
								$("#Budget"+chgType+" input[name='standardBriefName']").val(getInfo.StandardBriefName);
								$("#Budget"+chgType+" select[name='fiscalYear']").val(getInfo.FiscalYear);
								$("#costCenterType").val(getInfo.CostCenterType);
								
								BudgetRegistChangePopup.getBudgetRegistItem("Change");
							}
						},
						error:function (error){
							debugger;
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생하였습니다. 관리자에게 문의 바랍니다.
						}
					});
					
				},
				getBudgetRegistItem : function(id){
					var companyCode = $("#companyCode").val();
					var fiscalYear = $("#Budget"+id+" select[name='fiscalYear']").val();
					var costCenter = $("#Budget"+id).find("input[name='costCenter']").val();
					var accountCode = $("#Budget"+id).find("input[name='accountCode']").val();
					var standardBriefID = $("#Budget"+id).find("input[name='standardBriefID']").val();
					
					$( "#Budget"+id).find("#tbYear").hide();
					$( "#Budget"+id).find("#tbHalf").hide();
					$( "#Budget"+id).find("#tbQuarter").hide();
					$( "#Budget"+id).find("#tbMonth").hide();
					$( "#Budget"+id).find("#tbDate").hide();
					
					$.ajax({
						url	: "/account/budgetRegist/getBudgetRegistItem.do",
						type: "POST",
						data: {
								"companyCode" : 	companyCode
							,	"fiscalYear"  : 	fiscalYear
							,	"costCenter"  : 	costCenter
							,	"accountCode" : 	accountCode
							,   "standardBriefID": 	standardBriefID
						},
						success:function (data) {
							if(data.status == "SUCCESS"){

								var rows = data.list;
			                    var total = 0;
			                    if (rows.length>0){
				                    var obj ;
			                    	obj = $( "#Budget"+id).find("#tb" + rows[0].BaseTerm);
			                    	$( "#Budget"+id).find("[name=baseTerm]").val(rows[0].BaseTerm);
				                    if (rows[0].BaseTerm == "Date")
				                    {
				                    	obj.find("#StartDate" ).text(rows[0].ValidFrom);
				                    	obj.find("#EndDate").text(rows[0].ValidTo);
										//obj.find("#"+periodLabel).text(getAmountValue(amount));
				                    }
					                obj.show();
					                
				                    for (var i=0; i < rows.length; i++){
					                    var amount =rows[i].BudgetAmount;
					                    var periodLabel =rows[i].PeriodLabel;
	
										obj.find("#"+periodLabel).text(getAmountValue(amount));
					                    total += parseFloat(amount);
									}
									
					                obj.find("#"+rows[0].BaseTerm+"Sum").text(getAmountValue(total));
					                
					                //화면 사이즈 조정
					                if ("${chgType}" == "Change" && (rows[0].BaseTerm == "Date" || rows[0].BaseTerm == "Year")){
					                	$("#memo").height(250);
					                } else {
					                	$("#memo").height(85);
					                }	
			                    }	
							}else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생하였습니다. 관리자에게 문의 바랍니다.
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); 
						}
					});

				},
				SetSum:function(id, baseTerm, obj) {
					var obj = $( "#Budget"+id).find("#tb" + baseTerm)
			        var sumValue = 0;
					
					if (baseTerm == "Year")
						sumValue = sumValue + Number(obj.find("#1Y").text().replace(/,/g, ''));
					else
						sumValue = sumValue + Number(obj.find("#"+baseTerm+"Sum").text().replace(/,/g, ''));

					obj.find("input").each(function (i){
		            	if($(this).val().length>0){
		            		sumValue = sumValue + Number($(this).val().replace(/,/g, ''));
		            	}	
		            })	
	                obj.find("#"+baseTerm+"SumChange").text(getAmountValue(sumValue));
				},
				Save : function(){
					var me = this;
					var obj = $( "#Budget"+id).find("#tb" + baseTerm);
					var saveObj = {};
					var aList;
					
					if (BudgetRegistChangePopup.chgType == "Change") aList = ["Change"];
					else aList = ["Before", "After"];
					
					for (var i = 0; i < aList.length; i++) {
						var id = aList[i];
	            		var baseTerm = $("#Budget"+id).find("#baseTerm").val();
						var obj = $("#Budget"+id).find("#tb" + baseTerm);
						var periodInfo = new Array();
						
						obj.find("input").each(function(i) {
							var diffExp = Number($(this).val().replace(/,/g, ''));
							
							//예산 기본정보는 수정 불가능하고 분기별 변경된 값에 따라 예산편성 히스토리가 저장되므로 변경되지 않은 값은 저장하지 않음
							if(diffExp != 0 && !isNaN(diffExp)) {
			            		var periodLabel = $(this).attr("id").substring(0, $(this).attr("id").length-4);
			            		var orgExp =  Number(obj.find("#"+periodLabel).text().replace(/,/g, ''));
			            		var period = {
			            				"periodLabel": 	periodLabel
										, "diffAmount": diffExp
										, "totalAmount":orgExp + diffExp
								};
			            		periodInfo.push(period);
							}
			            });
	            		
						if(periodInfo.length > 0) {
							var registInfo = {
									"companyCode": 		$("#companyCode").val()
		            				, "fiscalYear":		$("#Budget"+id+" select[name='fiscalYear']").val()
									, "costCenter": 	$("#Budget"+id).find("input[name='costCenter']").val()
									, "accountCode":	$("#Budget"+id).find("input[name='accountCode']").val()
									, "standardBriefID":$("#Budget"+id).find("input[name='standardBriefID']").val()
									, "changType":	 	BudgetRegistChangePopup.chgType 
									, "memo":			$("#memo").val()
									, "baseTerm":		baseTerm
							};
							
							saveObj.registInfo = registInfo; //예산 기본정보
							saveObj.periodInfo = periodInfo; //분기별 예산편성 정보
						}
					}
					
					//저장할 데이터가 없으면 저장 없이 팝업창 닫음
					if(Object.keys(periodInfo).length == 0) {
						me.closeLayer();
						return;
					}
					
					$.ajax({
						type:"POST",
						url:"/account/budgetRegist/saveBudgetRegist.do",
						data:{
							"saveObj" : JSON.stringify(saveObj)
						},
						success:function (data) {
							if(data.result == "ok"){
								parent.Common.Inform("<spring:message code='Cache.msg_Changed'/>");	//저장되었습니다.
								BudgetRegistChangePopup.closeLayer();
								
								try {
									accountCtrl.popupCallBackStr([]);
								} catch (e) {
									coviCmn.traceLog(e);
									coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
								}
							} else{
								Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); //	오류가 발생했습니다. 관리자에게 문의바랍니다
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); //	오류가 발생했습니다. 관리자에게 문의바랍니다
						}
					});
				}, 
				costCenterSearchPopup : function(id){
					var me = this;
					var costType = $('#costCenterType').val();
					var companyCode = $("#companyCode").val();
					me.objId = id;
					
					if (costType == "USER"){
						var popupName	=	"userSearchPopup";
						var popupID		=	"userSearchPopup";
						var openerID	=	"BudgetRegistChangePopup";
						var popupYN		=   "Y";
						var popupTit	=	"<spring:message code='Cache.ACC_lbl_orgChart' />";	//CostCenter
						var callBack	=	"userSearchPopup_CallBack";
						var url			=	"/covicore/control/goOrgChart.do?"
										+	"popupID="		+	popupID		+	"&"
										+	"popupName="	+	popupName	+	"&"
										+	"openerID="		+	openerID	+	"&"
										+   "popupYN="		+   popupYN	    +   "&"
										+   "type=B0&"
										+	"companyCode="  + companyCode	+ 	"&"
										+	"callBackFunc="	+	callBack;
						window[callBack] = window[openerID][callBack];
						parent.Common.open(	"",popupID,popupTit,url,"1000px","580px","iframe",true,null,null,true);
					} else {
						var popupName	=	"CostCenterSearchPopup";
						var popupID		=	"CostCenterSearchPopup";
						var openerID	=	"BudgetRegistChangePopup";
						var popupYN		=   "Y";
						var popupTit	=	"<spring:message code='Cache.ACC_lbl_costCenter' />";	//CostCenter
						var callBack	=	"costCenterSearchPopup_CallBack";
						var url			=	"/account/accountCommon/accountCommonPopup.do?"
										+	"popupID="		+	popupID		+	"&"
										+	"popupName="	+	popupName	+	"&"
										+	"openerID="		+	openerID	+	"&"
										+   "popupYN="		+   popupYN	    +   "&"
										+	"companyCode="  + 	companyCode	+	"&"
										+	"callBackFunc="	+	callBack;
						parent.Common.open(	"",popupID,popupTit,url,"600px","730px","iframe",true,null,null,true);
					}	
				},
				costCenterSearchPopup_CallBack : function(value){
					var me = this;
					if(value != null){
						var obj = $("#Budget"+me.objId);
						obj.find("[name=costCenterName]").val(value.CostCenterName);
						obj.find("[name=costCenter]").val(value.CostCenterCode);
					}
				},
				userSearchPopup_CallBack : function(orgData){
					var me = BudgetRegistChangePopup;
					if(orgData != null){
						var items		= JSON.parse(orgData).item;
						var arr			= items[0];
						var userName	= arr.DN.split(';');
						var obj = $("#Budget"+me.objId);
						obj.find("[name=costCenterName]").val(userName[0]);
						obj.find("[name=costCenter]").val(arr.UserCode);
					}	
				},
				accountSearchPopup : function(id){
					var me = this;
					me.objId = id;
					var popupName	=	"AccountSearchPopup";
					var popupID		=	"AccountSearchPopup";
					var openerID	=	"BudgetRegistChangePopup";
					var popupYN		=   "Y";
					var popupTit	=	"<spring:message code='Cache.ACC_lbl_account' />";	//CostCenter
					var companyCode =	$("#companyCode").val();
					var callBack	=	"accountSearchPopup_CallBack";
					var url			=	"/account/accountCommon/accountCommonPopup.do?"
									+	"popupID="		+	popupID		+	"&"
									+	"popupName="	+	popupName	+	"&"
									+	"openerID="		+	openerID	+	"&"
									+   "popupYN="		+   popupYN	    +   "&"
									+	"companyCode="  + 	companyCode + 	"&"
									+	"callBackFunc="	+	callBack;
					parent.Common.open(	"",popupID,popupTit,url,"800px","730px","iframe",true,null,null,true);
				},
				accountSearchPopup_CallBack:function(value){
					var me = this;
					if(value != null){
						var obj = $("#Budget"+me.objId);
						obj.find("[name=accountName]").val(value.AccountName);
						obj.find("[name=accountCode]").val(value.AccountCode);
					}
				},
				standardBriefSearchPopup : function(id){
					var me = this;
					me.objId = id;
					var popupName	=	"StandardBriefSearchPopup";
					var popupID		=	"StandardBriefSearchPopup";
					var openerID	=	"BudgetRegistChangePopup";
					var popupYN		=   "Y";
					var popupTit	=	"<spring:message code='Cache.ACC_lbl_account' />";	//CostCenter
					var companyCode =	$("#companyCode").val();
					var callBack	=	"standardBriefSearchPopup_CallBack";
					var url			=	"/account/accountCommon/accountCommonPopup.do?"
									+	"popupID="		+	popupID		+	"&"
									+	"popupName="	+	popupName	+	"&"
									+	"openerID="		+	openerID	+	"&"
									+   "popupYN="		+   popupYN	    +   "&"
									+	"companyCode="  + 	companyCode + 	"&"
									+	"callBackFunc="	+	callBack;
					parent.Common.open(	"",popupID,popupTit,url,"800px","730px","iframe",true,null,null,true);
				},
				standardBriefSearchPopup_CallBack:function(value){
					var me = this;
					if(value != null){
						var obj = $("#Budget"+me.objId);
						obj.find("[name=accountName]").val(value.AccountName);
						obj.find("[name=accountCode]").val(value.AccountCode);
						obj.find("[name=standardBriefName]").val(value.StandardBriefName);
						obj.find("[name=standardBriefID]").val(value.StandardBriefID);
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
		window.BudgetRegistChangePopup = BudgetRegistChangePopup;
	})(window);
	
	BudgetRegistChangePopup.popupInit();
</script>