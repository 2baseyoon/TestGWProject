 <%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<style>
	.pad10 { padding:10px;}
</style>

	<!-- 상단 끝 -->
	<div class="cRConTop titType">
		<h2 id="headerTitle" class="title"></h2>
	</div>
	<div class='cRContBottom mScrollVH'>
		<!-- 컨텐츠 시작 -->
		<div class="eaccountingCont">
			<div class="eaccountingTopCont">
				<!-- 상단 버튼 시작 -->
				<div class="pagingType02 buttonStyleBoxLeft">
					<!-- 추가 -->
					<a class="btnTypeDefault  btnTypeBg"		onclick="BudgetFiscal.openPopup();"	id="btnAdd">
						<spring:message code='Cache.ACC_lbl_acounting' /><spring:message code='Cache.lbl_Standard' /><spring:message code='Cache.lbl_apv_date2' /><spring:message code='Cache.lbl_change' /></a>
					<!-- 새로고침 -->
					<a class="btnTypeDefault"					onclick="BudgetFiscal.refresh()"><spring:message code="Cache.ACC_btn_refresh"/></a>
				</div>				
			</div>
			
			<div id="searchBar1" class="bodysearch_Type01">
				<div class="inPerView type08">
					<div style="width:100%;">
						<div class="inPerTitbox">
							<span id="companyCode" class="selectType02" onchange="BudgetFiscal.searchList();">
							</span>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<spring:message code='Cache.ACC_lbl_budget' /><spring:message code='Cache.lbl_apv_vacation_year' />	<!-- 예산년도 -->
							</span>
							<select  class="selectType02" id="fiscalYear" onchange="BudgetFiscal.searchList()"></select>
						</div>
					</div>
				</div>
			</div>
			<div class="inPerTitbox">
				<div class="buttonStyleBoxRight">	
					<span id="listCount" class="selectType02 listCount" onchange="BudgetFiscal.searchList()">
					</span>
					<button class="btnRefresh" type="button" onclick="BudgetFiscal.searchList();"></button>
				</div>
			</div>
			<div id="gaBudgetFiscal" class="pad10">
			</div>
		</div>
		<!-- 컨텐츠 끝 -->
	</div>
<script>

	if (!window.BudgetFiscal) {
		window.BudgetFiscal = {};
	}
	
	(function(window) {
		var BudgetFiscal = {
			params	:{
				gridPanel	: new coviGrid(),
				headerData	: []
			},
			
			pageInit : function() {
				var me = this;
				setHeaderTitle('headerTitle');
				me.setSelectCombo();
				me.setHeaderData();
				me.searchList();
			},
			
			pageView : function() {
				var me = this;

				me.setHeaderData();
				me.refreshCombo();
				
				var gridAreaID		= "gaBudgetFiscal";
				var gridPanel		= me.params.gridPanel;
				var pageNoInfo		= me.params.gridPanel.page.pageNo;
				var pageSizeInfo	= accountCtrl.getComboInfo("listCount").val();
				
				var gridParams		= {	"gridAreaID"	: gridAreaID
									,	"gridPanel"		: gridPanel
									,	"pageNoInfo"	: pageNoInfo
									,	"pageSizeInfo"	: pageSizeInfo
				}
				
				accountCtrl.refreshGrid(gridParams);
			},
			setSelectCombo : function(){
				var Today = new Date();
				var Year = Today.getFullYear()+1;
				var obj = accountCtrl.getInfo("fiscalYear");//$("#fiscalYear");

				for (var i = 0; i < 3; i++)
		        {
					var option = $("<option value="+Year+">"+Year+"</option>");
					obj.append(option);
					Year--;
		        }
				obj.val(Today.getFullYear());

				var AXSelectMultiArr	= [	
											{'codeGroup':'listCountNum',	'target':'listCount',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''},
											{'codeGroup':'CompanyCode',		'target':'companyCode',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'ALL'}
									]
				accountCtrl.renderAXSelectMulti(AXSelectMultiArr);
			},
			refreshCombo : function(){
				accountCtrl.refreshAXSelect("listCount");
			},
			
			setHeaderData : function() {
				var me = this;
				me.params.headerData = [	{	key:'CompanyCodeName',		label:"<spring:message code='Cache.lbl_CorpName' />", width:'50', align:'center'},	//회사명
				                        	{	key:'FiscalYear',			label:"<spring:message code='Cache.ACC_lbl_budget' /><spring:message code='Cache.lbl_apv_vacation_year' />", width:'50', align:'center'},	//예산년도
											{	key:'BaseTermName',			label:"<spring:message code='Cache.ACC_lbl_budget' /><spring:message code='Cache.lbl_SchDivision' />",		width:'70', align:'center'},	//계정과목
											{	key:'PeriodLabelName',		label:"<spring:message code='Cache.lbl_Period' />",		width:'70', align:'left'},	//계정이름
											{	key:'ValidTerm',			label:"<spring:message code='Cache.ACC_lbl_budget' /><spring:message code='Cache.lbl_Period' />",		width:'150', align:'left', sort:false}	//계정이름
										]
				
				var gridPanel	= me.params.gridPanel;
				var gridHeader	= me.params.headerData;
				accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
				//gridPanel.setGridConfig({remoteSort  :false});
			},
			
			searchList : function(YN){
				var me = this;
				me.setHeaderData();
				var companyCode		= accountCtrl.getComboInfo("companyCode").val();	//회사코드
				var fiscalYear		= accountCtrl.getInfo("fiscalYear").val();	//예산년도
				var gridAreaID		= "gaBudgetFiscal";
				var gridPanel		= me.params.gridPanel;
				var gridHeader		= me.params.headerData;
				var ajaxUrl			= "/account/budgetFiscal/getBudgetFiscalList.do";
				var ajaxPars		= {	"companyCode"	: companyCode
										,"fiscalYear"	: fiscalYear};
				
				var pageNoInfo	= 1;
				if(YN== 'Y'){
					pageNoInfo	= me.params.gridPanel.page.pageNo;
				}
				
				var pageSizeInfo	= accountCtrl.getComboInfo("listCount").val();
				var gridParams = {	"gridAreaID"	: gridAreaID
								,	"gridPanel"		: gridPanel
								,	"gridHeader"	: gridHeader
								,	"ajaxUrl"		: ajaxUrl
								,	"ajaxPars"		: ajaxPars
								,	"pageNoInfo"	: pageNoInfo
								,	"pageSizeInfo"	: pageSizeInfo
								,	"popupYN"		: "N"
				}
				
				accountCtrl.setViewPageBindGrid(gridParams);
			}	,
			openPopup : function(){
				var mode		= "add";
				var popupID		= "BudgetFiscalPopup";
				var openerID	= "BudgetFiscal";
				var popupTit	= "<spring:message code='Cache.ACC_lbl_acounting' /><spring:message code='Cache.lbl_Standard' /><spring:message code='Cache.lbl_apv_date2' /><spring:message code='Cache.lbl_change' />";
				var popupYN		= "N";
				var callBack	= "BudgetFiscal_CallBack";
				var popupUrl	= "/account/budgetFiscal/BudgetFiscalPopup.do?"
								+ "popupID="		+ popupID	+ "&"
								+ "openerID="		+ openerID	+ "&"
								+ "popupYN="		+ popupYN	+ "&"
								+ "callBackFunc="	+ callBack	+ "&"
								+ "mode="			+ mode;
				
				Common.open("", popupID, popupTit, popupUrl, "400px", "300px", "iframe", true, null, null, true);
			},
			BudgetFiscal_CallBack :function(){
				var me = this;
				me.searchList('Y');
			},
			refresh : function(){
				accountCtrl.pageRefresh();
			}
		}
		window.BudgetFiscal= BudgetFiscal;
	})(window);
</script>