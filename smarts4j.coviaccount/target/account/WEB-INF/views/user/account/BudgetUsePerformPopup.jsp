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
	.pad10 { padding:10px;}
	.bodysearch_tit{width:120px}
</style>

<body>
	<div class="layer_divpop ui-draggable docPopLayer" style="width:98%;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div id="searchBar1" class="bodysearch_Type01">
			<div class="inPerView type08">
				<div style="width:100%">
					<div class="inPerTitbox">
						<span class="bodysearch_tit">
							<spring:message code='Cache.ACC_lbl_budget' /><spring:message code='Cache.lbl_apv_vacation_year' />	<!-- 예산년도 -->
						</span>
	                    <span name="fiscalYear"></span>
					</div>
					<div class="inPerTitbox">
						<span class="bodysearch_tit">
							<spring:message code='Cache.ACC_lbl_costCenterName' />	<!-- 코스트센터 -->
						</span>
	                    <span name="costCenterName"></span>
					</div>
				</div>
				<div style="width:100%">
					<div class="inPerTitbox">
						<span class="bodysearch_tit">
							<spring:message code='Cache.ACC_lbl_accountCode' />	<!-- 예산계정 -->
						</span>
	                    <span name="accountCode"></span>
					</div>
					<div class="inPerTitbox">
						<span class="bodysearch_tit">
							<spring:message code='Cache.ACC_lbl_account' />	<!-- 계정명 표준적요 -->
						</span>
	                    <span name="accountName"></span>
	                    <span name="standardBriefName"></span>
					</div>
				</div>
			</div>
		</div>		
		<div class="divpop_contents" style="width:100%;" >
			<div class="popContent ">
				<div id="gridArea" class="pad10">
				</div>
			</div>
		</div>
	</div>
</body>

<script>

	if (!window.BudgetUsePerformPopup) {
		window.BudgetUsePerformPopup = {};
	}
	
	(function(window) {
		var BudgetUsePerformPopup = {
				params	:{
					gridPanel	: new coviGrid(),
					headerData	: []
				},
				
				pageInit : function(){
					var me = this;
					me.setHeaderData();
					me.setData();
					me.searchList();
				},
				
				setHeaderData : function() {
					var me = this;
					me.params.headerData = [	{	key:'InitiatorName',	label:"<spring:message code='Cache.lbl_apv_writer' />", width:'50', align:'center'},	//기안자
												{	key:'RegistDate',		label:"<spring:message code='Cache.lbl_DraftDate' />",		width:'70', align:'center'}	,	//기안일
												{	key:'InitiatorDeptName',	label:"<spring:message code='Cache.lbl_DraftDept' />",		width:'70', align:'center'},	//기안부서
												{	key:'ExecuteDate',	label:"<spring:message code='Cache.ACC_lbl_realPayDate' />",		width:'70', align:'center'},	//이용일
												{	key:'UsedAmount',	label:"<spring:message code='Cache.ACC_lbl_UsedAmt' />",	width:'70', align:'center', formatter:function () {return getAmountValue(this.item.UsedAmount);}},	//금액
												{	key:'Description',		label:"<spring:message code='Cache.ACC_lbl_useHistory2' />",		width:'70', align:'center'}	,	//적요
												{	key:'StatusName',			label:"<spring:message code='Cache.lbl_Status' />",			width:'70', align:'center'}		//상태
											]
					var configObj = {
							targetID : "gridArea",
							height:"auto",
							listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
							page : {
								pageNo:1,
								pageSize:	20

							},
							paging : true,
							colHead:{},
							body:{}
					}
					var gridHeader = me.params.headerData;
					var gridPanel  = me.params.gridPanel;
					
					gridPanel.setGridHeader(gridHeader);
					gridPanel.setGridConfig(configObj);
				},
				
				searchList : function(){
					var me = this;
					me.setHeaderData();
					var gridPanel  = me.params.gridPanel;
					
					var companyCode= "${companyCode}";
					var fiscalYear= "${fiscalYear}";
					var costCenter = "${costCenter}";
					var costCenterName = decodeURIComponent(decodeURIComponent("${costCenterName}"));
					var accountCode = "${accountCode}";
					var accountName = decodeURIComponent(decodeURIComponent("${accountName}"));
					var standardBriefID = "${standardBriefID}";
					var standardBriefName = decodeURIComponent(decodeURIComponent("${standardBriefName}"));
					var validFrom = "${validFrom}";
					var validTo = "${validTo}";
					var periodLabel = "${periodLabel}";
					
					gridPanel.bindGrid( {	
							"ajaxUrl"		: "/account/budgetUsePerform/getBudgetUsePerformDetailList.do"
							,"ajaxPars"		: {	"companyCode":companyCode
									,	"fiscalYear"  :fiscalYear
									,	"costCenter"  : costCenter
									,	"accountCode" : accountCode
									,   "standardBriefID": standardBriefID
									,   "validFrom": validFrom // yyyy-MM-dd
									,   "validTo": validTo
									,   "periodLabel":periodLabel }
							});
				},
				
				setData : function() {
					$("span[name='fiscalYear']").text("${fiscalYear}");
					$("span[name='costCenterName']").text(decodeURIComponent(decodeURIComponent("${costCenterName}")));
					$("span[name='accountCode']").text("${accountCode}");
					$("span[name='accountName']").text(decodeURIComponent(decodeURIComponent("${accountName}")));
					$("span[name='standardBriefName']").text(decodeURIComponent(decodeURIComponent("${standardBriefName}")));
				},
				
				closeLayer : function() {
					var isWindowed	= CFN_GetQueryString("CFN_OpenedWindow");
					var popupID		= CFN_GetQueryString("popupID");
					
					if(isWindowed.toLowerCase() == "true") {
						window.close();
					} else {
						parent.Common.close(popupID);
					}
				}
		}
		window.BudgetUsePerformPopup = BudgetUsePerformPopup;
	})(window);
	
	BudgetUsePerformPopup.pageInit();
	
</script>