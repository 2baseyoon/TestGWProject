 <%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="egovframework.coviframework.util.RedisDataUtil, egovframework.coviframework.util.StringUtil,egovframework.baseframework.util.SessionHelper"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<style>
	.pad10 { padding:10px;}
</style>
<%
String IsUseStandardBrief = RedisDataUtil.getBaseConfig("IsUseStandardBrief");
String StandardBriefTag = "";
if (!IsUseStandardBrief.equals("Y")) {
	out.println("<style>.StandardBrief{display:none}</style>");
	StandardBriefTag = ",display:false";
}

String authMode = StringUtil.replaceNull(request.getParameter("Auth"),"M");
if (authMode.equals("M")) {
	out.println("<style>#account_BudgetUsePerformaccountuserAccountMViewArea .costTypeCls{display:none}</style>");
	
}

%>
<input id="authMode" type="hidden"  value="<%=authMode%>">
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
					<!-- 새로고침 -->
					<a class="btnTypeDefault"					onclick="BudgetUsePerform.refresh()"><spring:message code="Cache.ACC_btn_refresh"/></a>
					<!-- 새로고침 -->
					<a class="btnTypeDefault"					onclick="BudgetUsePerform.openChart()"><spring:message code="Cache.lbl_viewChart"/></a>
				</div>
				<div class="buttonStyleBoxRight">	
					<!-- 엑셀저장 -->
					<a class="btnTypeDefault btnExcel"			onclick="BudgetUsePerform.downloadExcel();"><spring:message code="Cache.btn_ExcelDownload"/></a>					
				</div>
			</div>
			
			<div id="searchBar1" class="bodysearch_Type01">
				<div class="inPerView type08">
					<div style="width:100%;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<spring:message code='Cache.lbl_CorpName' />	<!-- 회사명 -->
							</span>
							<span id="companyCode" class="selectType02"></span>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<spring:message code="Cache.ACC_lbl_division"/>	<!-- 구분 -->
							</span>
							<span id="searchType" class="selectType02"></span>
							<input onkeydown="BudgetUsePerform.onEnter()" id="searchStr" type="text" placeholder="">
						</div>
					</div>
					<div style="width:100%;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<spring:message code='Cache.ACC_lbl_budget' /><spring:message code='Cache.lbl_apv_vacation_year' />	<!-- 예산년도 -->
							</span>
							<select  class="selectType02" id="fiscalYear"></select>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<spring:message code='Cache.ACC_lbl_budgetType' />	<!-- 예산타입 -->
							</span>
							<span id="costCenterType" class="selectType02">
							</span>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit costTypeCls" style="width:90px">
								<spring:message code="Cache.ACC_lbl_DeptUser"/>	<!-- 부서/사용자  -->
							</span>
							<input onkeydown="BudgetUsePerform.onEnter()"  id="costCenterName" class="sm costTypeCls" type="text" placeholder="">
						</div>
						<a class="btnTypeDefault  btnSearchBlue" onclick="BudgetUsePerform.searchList();"><spring:message code='Cache.ACC_btn_search'/></a><!-- 검색 -->
					</div>
				</div>
			</div>
			<div class="inPerTitbox">
				<div class="buttonStyleBoxRight">
					<span id="listCount" class="selectType02 listCount" onchange="BudgetUsePerform.searchList()">
					</span>
					<button class="btnRefresh" type="button" onclick="BudgetUsePerform.searchList();"></button>
				</div>
			</div>
			<div id="gaBudgetUsePerform" class="pad10">
			</div>
		</div>
		<!-- 컨텐츠 끝 -->
	</div>
<script>

	if (!window.BudgetUsePerform) {
		window.BudgetUsePerform = {};
	}
	
	(function(window) {
		var BudgetUsePerform = {
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
				
				var gridAreaID		= "gaBudgetUsePerform";
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

				for (var i = 0; i < 10; i++)
		        {
					var option = $("<option value="+Year+">"+Year+"</option>");
					obj.append(option);
					Year--;
		        }
				obj.val(Today.getFullYear());
				
				var AXSelectMultiArr	= [	
											{'codeGroup':'CompanyCode',		'target':'companyCode',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':"<%=SessionHelper.getSession("DN_Code")%>"}
										,	{'codeGroup':'listCountNum',	'target':'listCount',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
										,	{'codeGroup':'amSearchType',	'target':'searchType',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}
										,	{'codeGroup':'BudgetType',		'target':'costCenterType',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}
									]
				accountCtrl.renderAXSelectMulti(AXSelectMultiArr);
				var targetComboID		= accountCtrl.getComboInfo("companyCode")[0].id;
				//$("#" + targetComboID).bindSelectRemoveOptions([{optionValue:'ALL', optionText:''}]);
			},
			refreshCombo : function(){
				accountCtrl.refreshAXSelect("listCount");
				accountCtrl.refreshAXSelect("searchType");
			},
			setHeaderData : function() {
				var me = this;
				me.params.headerData = [	{	key:'CompanyCodeName',	label:"<spring:message code='Cache.lbl_CorpName' />", width:'50', align:'center'},	//회사명
				                        	{	key:'FiscalYear',	label:"<spring:message code='Cache.ACC_lbl_budget' /><spring:message code='Cache.lbl_apv_vacation_year' />", width:'50', align:'center'},	//예산년도
				                        	{	key:'CostCenterTypeName',		label:"<spring:message code='Cache.ACC_lbl_budgetType' />",		width:'50', align:'center'}, //예산타입
											{	key:'CostCenterName',		label:"<spring:message code='Cache.ACC_lbl_DeptUser' />",		width:'120', align:'left'}	,	//부서/사용자
											{	key:'AccountCode',	label:"<spring:message code='Cache.ACC_lbl_budget' /><spring:message code='Cache.ACC_lbl_accountCode' />",		width:'70', align:'center'},	//계정과목
											{	key:'AccountName',		label:"<spring:message code='Cache.ACC_lbl_budget' /><spring:message code='Cache.ACC_lbl_account' />",		width:'100', align:'left'},	//계정이름
											{	key:'StandardBriefName',	label:"<spring:message code='Cache.ACC_lbl_standardBriefName' />",		width:'150', align:'left', sort:false <%=StandardBriefTag%>},	//계정이름
											{	key:'PeriodLabelName',			label:"<spring:message code='Cache.lbl_Period' /><spring:message code='Cache.lbl_Division2'/>",		width:'80', align:'center', sort:false},		//기간구분
											{	key:'ValidTerm',			label:"<spring:message code='Cache.ACC_lbl_budget' /><spring:message code='Cache.lbl_Period' />",		width:'180', align:'center', sort:false},		//예산기간
											{	key:'ValidFrom',		display:false, hideFilter:true},
											{	key:'ValidTo',			display:false, hideFilter:true},
											{	key:'BudgetAmount',	label:"<spring:message code='Cache.ACC_lbl_budgetAmount' />",	width:'70', align:'right', formatter:function () {return getAmountValue(this.item.BudgetAmount);}},	//예산금액
											{	key:'CompletAmount',	label:"<spring:message code='Cache.ACC_lbl_execution' /><spring:message code='Cache.lbl_invoice_amount' />",	width:'70', align:'right',	//집행
										    	formatter:function () {
								            		 return "<a onclick='BudgetUsePerform.openBudgetUsePerformPopup(" + JSON.stringify(this.item) + ")';><font color=blue><u>"+getAmountValue(this.item.CompletAmount)+"</u></font></a>";
								            	}
											},
											{	key:'PendingAmount',	label:"<spring:message code='Cache.ACC_lbl_proExecution' /><spring:message code='Cache.lbl_invoice_amount' />",	width:'70', align:'right', formatter:function () {return getAmountValue(this.item.PendingAmount);}},	//금액
											{	key:'RemainAmount',	label:"<spring:message code='Cache.lbl_remainBudget' />",	width:'70', align:'right', formatter:function () {return getAmountValue(this.item.RemainAmount);}}	//금액
										]
				
				var gridPanel	= me.params.gridPanel;
				var gridHeader	= me.params.headerData;
				accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
			},
			
			searchList : function(){
				var me = this;
				me.setHeaderData();

				var authMode		= accountCtrl.getInfo("authMode").val();	//
				var companyCode		= accountCtrl.getComboInfo("companyCode").val();	//회사코드
				var fiscalYear		= accountCtrl.getInfo("fiscalYear").val();	//예산년도
				var costCenterName	= accountCtrl.getInfo("costCenterName").val();	//costcenter명
				var costCenterType	= accountCtrl.getComboInfo("costCenterType").val();			//코스트스센터 구분

				var searchType		= accountCtrl.getComboInfo("searchType").val();		//구분
				var searchStr		= accountCtrl.getInfo("searchStr").val();			//조회문장
				
				var gridAreaID		= "gaBudgetUsePerform";
				var gridPanel		= me.params.gridPanel;
				var gridHeader		= me.params.headerData;
				var ajaxUrl			= "/account/budgetUsePerform/getBudgetUsePerformList.do";
				var ajaxPars		= {	"companyCode":companyCode
									,   "fiscalYear"	: fiscalYear
					 				,	"costCenterName": costCenterName
									,   "costCenterType": costCenterType
					 				,	"searchType"	: searchType
					 				,	"searchStr"		: searchStr
					 				,   "authMode"      : authMode
					};
				
				var pageNoInfo	= 1;
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
			},
			openBudgetUsePerformPopup : function(keyData){
				var popupID		= "BudgetUsePerformPopup";
				var openerID	= "BudgetUsePerform";
				var popupTit	= "<spring:message code='Cache.ACC_lbl_execution' /><spring:message code='Cache.lbl_DetailView' />";	//계정관리
				var popupYN		= "Y";
				var popupUrl	= "/account/budgetUsePerform/BudgetUsePerformPopup.do?"
								+ "popupID="		+ popupID	+ "&"
								+ "openerID="		+ openerID	+ "&"
								+ "popupYN="		+ popupYN	+ "&"
								+ "companyCode="    + keyData.CompanyCode + "&"
								+ "fiscalYear="     + keyData.FiscalYear	+ "&"
								+ "costCenter="     + keyData.CostCenter	+ "&"
								+ "costCenterName=" + encodeURIComponent(encodeURIComponent(keyData.CostCenterName))+ "&"
								+ "accountCode="    + keyData.AccountCode	+ "&"
								+ "accountName="    + encodeURIComponent(encodeURIComponent(keyData.AccountName))+ "&"
								+ "standardBriefID=" + keyData.StandardBriefID	+ "&"
								+ "standardBriefName=" + encodeURIComponent(encodeURIComponent(keyData.StandardBriefName))+ "&"
								+ "validFrom=" + keyData.ValidFrom + "&"
								+ "validTo=" + keyData.ValidTo + "&"
								+ "periodLabel=" + keyData.PeriodLabel;

				Common.open("", popupID, popupTit, popupUrl, "700px", "680px", "iframe", true, null, null, true);
			},
			refresh : function(){
				accountCtrl.pageRefresh();
			},
			openChart :function() {
				var authMode		= accountCtrl.getInfo("authMode").val();	//
				var fiscalYear		= accountCtrl.getInfo("fiscalYear").val();	//예산년도
				var costCenterName	= accountCtrl.getInfo("costCenterName").val();	//costcenter명
				var costCenterType	= accountCtrl.getComboInfo("costCenterType").val();			//코스트스센터 구분

				var searchType		= accountCtrl.getComboInfo("searchType").val();		//구분
				var searchStr		= accountCtrl.getInfo("searchStr").val();			//조회문장

				
				var popupID		= "BudgetUsePerformChartPopup";
				var openerID	= "BudgetUsePerform";
				var popupTit	= "<spring:message code='Cache.lbl_viewChart' />";	//
				var popupYN		= "Y";
				var popupUrl	= "/account/budgetUsePerform/BudgetUsePerformChart.do?"
								+ "popupID="		+ popupID	+ "&"
								+ "openerID="		+ openerID	+ "&"
								+ "popupYN="		+ popupYN	+ "&"
								+ "fiscalYear="     + fiscalYear	+ "&"
								+ "companyCode="    + accountCtrl.getComboInfo("companyCode").val() + "&"
								+ "costCenterName=" + encodeURI(costCenterName)+ "&"
								+ "searchType="    + searchType	+ "&"
								+ "searchStr="    + encodeURI(searchStr)+ "&"
								+ "groupbyCol=Cost&"
								+ "authMode="+authMode+"&"
								+ "costCenterType=" + costCenterType	;

				Common.open("", popupID, popupTit, popupUrl, "1000px", "680px", "iframe", true, null, null, true);
		 	} 	,
		 	downloadExcel: function(){
				var me = this;
				Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage'/>", "<spring:message code='Cache.ACC_btn_save' />", function(result){
		       		if(result){
						var headerName		= BudgetUsePerform.getHeaderNameForExcel(me.params.headerData);
						var headerKey		= BudgetUsePerform.getHeaderKeyForExcel(me.params.headerData);
						
						var authMode		= accountCtrl.getInfo("authMode").val();	//
						var fiscalYear		= accountCtrl.getInfo("fiscalYear").val();	//예산년도
						var costCenterName	= accountCtrl.getInfo("costCenterName").val();	//costcenter명
						var costCenterType	= accountCtrl.getComboInfo("costCenterType").val();			//코스트스센터 구분

						var searchType		= accountCtrl.getComboInfo("searchType").val();		//구분
						var searchStr		= accountCtrl.getInfo("searchStr").val();			//조회문장
						var title 			= accountCtrl.getInfo("headerTitle").text();

						var	locationStr		= "/account/budgetUsePerform/downloadExcel.do?"
											//+ "headerName="		+ encodeURI(headerName)
											+ "headerName="		+ encodeURIComponent(encodeURIComponent(headerName))
											+ "&headerKey="		+ encodeURI(headerKey)
											//+ "&title="			+ encodeURI(accountCtrl.getInfo("headerTitle").text())
											+ "&title="			+ encodeURIComponent(encodeURIComponent(title))
											+ "&companyCode="   + accountCtrl.getComboInfo("companyCode").val()
											+ "&fiscalYear="	+ fiscalYear
							 				+ "&costCenterName="+ encodeURIComponent(encodeURIComponent(costCenterName))
											+ "&costCenterType="+ costCenterType
							 				+ "&searchType="	+ searchType
							 				+ "&searchStr="		+ encodeURIComponent(encodeURIComponent(searchStr))
							 				+ "&authMode="+authMode;
						location.href = locationStr;
		       		}
		       	});
			},
			onEnter : function(){
				var me = this;
				if(event.keyCode=="13"){
					me.searchList();
				}
			}
			,getHeaderNameForExcel:function (headerData){
				var returnStr	= "";
			   	for(var i=0;i<headerData.length; i++){
			   	   	if(headerData[i].display != false && headerData[i].label != 'chk'){
			   	   		returnStr += headerData[i].label + "†";
			   	   	}
				}
				return returnStr;
			},
			getHeaderKeyForExcel:function(headerData){
				var returnStr	= "";
			   	for(var i=0;i<headerData.length; i++){
			   	   	if(headerData[i].display != false && headerData[i].label != 'chk'){
						returnStr += headerData[i].key + ",";
			   	   	}
				}
				return returnStr;
			}

		}
		window.BudgetUsePerform= BudgetUsePerform;
	})(window);
</script>