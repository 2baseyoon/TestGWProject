<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil" %>
<%@ page import="java.util.Properties" %>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="/account/resources/script/user/expAppCommon.js<%=resourceVersion%>"></script>
<style>
.pad10 { padding:10px;}
</style>


	<!-- 상단 끝 -->
	<div class="cRConTop titType">
		<h2 id="headerTitle" class="title"></h2>
	</div>
	<input id="syncProperty" type="hidden" />
	<div class='cRContBottom mScrollVH'>
		<!-- 컨텐츠 시작 -->
		<div class="eaccountingCont">
			<!-- 상단 버튼 시작 -->
			<div class="eaccountingTopCont">
				<div class="pagingType02 buttonStyleBoxLeft">
					<!-- 새로고침 -->
					<a class="btnTypeDefault" href="#" onclick="accountCtrl.pageRefresh();"><spring:message code="Cache.ACC_btn_refresh"/></a>
					<!-- 엑셀저장 -->
					<a class="btnTypeDefault btnExcel" href="#" onclick="MonthlyAccountSummarySheet.mthAccSum_excelDownload();"><spring:message code="Cache.ACC_btn_excelDownload"/></a>
				</div>
			</div>
			<!-- 상단 버튼 끝 -->
			<!-- 검색영역 시작 -->
			<div class="bodysearch_Type01">
				<div class="inPerView type08">
					<div style="width:830px;">
						<div class="inPerTitbox">
							<!-- 회사 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_company"/></span>
							<span id="mthAccSum_CompanyCode" class="selectType02" name="searchParam" tag="companyCode" onchange="MonthlyAccountSummarySheet.changeCompanyCode()">
							</span>
						</div>		
						<div class="inPerTitbox">
							<!-- 기안자 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_aprvWriter"/></span>
							<input type="text" name="searchParam" tag="RegisterNm" id="mthAccSum_RegisterNm"
								onkeydown="MonthlyAccountSummarySheet.onenter()">
						</div>
						<%-- <div class="inPerTitbox">
							<!-- 부서 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_dept"/></span>
							<input type="text" name="searchParam" tag="RegisterDept" id="mthAccSum_RegisterDept"
								onkeydown="MonthlyAccountSummarySheet.onenter()">
						</div>	 --%>	
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<!-- 코스트센터 -->
								<spring:message code='Cache.ACC_lbl_costCenter'/>
							</span>
							<div class="name_box_wrap">
								<span class="name_box" name="ccNameBox" ></span>
								<a class="btn_del03" onclick="MonthlyAccountSummarySheet.mthAccSum_ccDelete()"></a>
							</div>
							<a class="btn_search03" onclick="MonthlyAccountSummarySheet.mthAccSum_ccSearch()"></a>
							<input  type="text" hidden name="searchParam" tag="CostCenterCode"
								onkeydown="MonthlyAccountSummarySheet.onenter()" >
						</div>
					</div>		
					<div style="width:980px;">									
						<div class="inPerTitbox">
							<!-- 신청유형 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_requestType"/></span>
							<span id="mthAccSum_RequestType" class="selectType02" name="searchParam" tag="RequestType">
							</span>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<!-- 계정과목 -->
								<spring:message code='Cache.ACC_lbl_account'/>
							</span>
							<div class="name_box_wrap">
								<span class="name_box" name="accNameBox" ></span>
								<a class="btn_del03" onclick="MonthlyAccountSummarySheet.mthAccSum_accDelete()"></a>
							</div>
							<a class="btn_search03" onclick="MonthlyAccountSummarySheet.mthAccSum_accSearch()"></a>
							<input  type="text" hidden name="searchParam" tag="AccountCode"
								onkeydown="MonthlyAccountSummarySheet.onenter()" >
						</div>
						<%-- <div class="inPerTitbox">
							<!-- 지급일자 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_payDay"/></span>
							<div id="mthAccSum_dateAreaPayDate" class="dateSel type02" name="searchParam" tag="PayDate" fieldtype="Date">
							</div>
						</div> --%>
						<div class="inPerTitbox">
							<!-- 증빙일자 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_proofDate"/></span>
							<input type="text" id="mthAccSum_ProofDate" class="W70" kind="date" date_selectType="m" name="searchParam" tag="ProofDate" style="width: 90px;"/>
						</div>
						<a href="#" class="btnTypeDefault btnSearchBlue" onclick="MonthlyAccountSummarySheet.mthAccSum_searchMonthlyAccountSummaryList()"><spring:message code="Cache.ACC_btn_search"/></a>
					</div>
				</div>
			</div>
			<!-- 검색영역 끝 -->			
			<div class="inPerTitbox">
				<!-- 구분 -->
				<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_division"/></span>
				<span class="selectType02"	id="mthAccSum_SearchType" name="searchParam" tag="SearchType" onchange="MonthlyAccountSummarySheet.mthAccSum_searchMonthlyAccountSummaryList()">
				</span>
				<div class="buttonStyleBoxRight ">	
					<button class="btnRefresh" type="button" onclick="MonthlyAccountSummarySheet.mthAccSum_searchMonthlyAccountSummaryList();"></button>
				</div>
			</div>
			<!-- ===================== -->
			<div id="Grid" class="pad10">
				<div id="mthAccSumListGrid"></div>
			</div>
		</div>
		<!-- 컨텐츠 끝 -->
	</div>

<script>

if (!window.MonthlyAccountSummarySheet) {
	window.MonthlyAccountSummarySheet = {};
}

(function(window) {
	var MonthlyAccountSummarySheet = {
			
			gridPanel : new coviGrid(),
			searchedType : "",
			gridHeaderDataList : [],
			setGridHead : [],

			pageInit : function() {
				var me = this;
				setHeaderTitle('headerTitle');

				me.gridHeaderDataList = expAppCommon.getGridHeader("monthAcc"); //TODO: 월별 경비 계정별 집계표 header 가져오기 구현 필요
				
				//makeDatepicker('mthAccSum_dateArea', 'mthAccSum_dateArea_St', 'mthAccSum_dateArea_Ed', null, null, 100);
				//makeDatepicker('mthAccSum_dateAreaPayDate', 'mthAccSum_dateAreaPayDate', null, null, null, 220);
				
				//증빙일자 달력 컨트롤 바인딩 및 기본값 세팅				
				coviInput.setDate();
				
				var date = new Date();
				var lastDayOfMonth = new Date(date.getFullYear(), date.getMonth() , 1);
				var prevMonth = new Date (lastDayOfMonth.setDate(lastDayOfMonth.getDate() - 1));

				accountCtrl.getInfo("mthAccSum_ProofDate").val(prevMonth.getFullYear() + "-" + XFN_AddFrontZero(prevMonth.getMonth()+1, 2));

				me.mthAccSum_comboInit();
				me.mthAccSum_gridInit();		
			},
			pageView : function() {
				var me = this;
				coviInput.setDate();
				me.mthAccSum_comboRefresh();
				me.mthAccSum_searchMonthlyAccountSummaryList();
			},

			mthAccSum_comboInit : function(pCompanyCode) {
				accountCtrl.getInfo("mthAccSum_RequestType").children().remove();
				accountCtrl.getInfo("mthAccSum_SearchType").children().remove();
				
				accountCtrl.getInfo("mthAccSum_RequestType").addClass("selectType02").attr("name", "searchParam").attr("tag", "RequestType")
				accountCtrl.getInfo("mthAccSum_SearchType").addClass("selectType02").attr("name", "searchParam").attr("tag", "SearchType").attr("onchange", "MonthlyAccountSummarySheet.mthAccSum_searchMonthlyAccountSummaryList()");
				
				accountCtrl.renderAXSelect('FormManage_RequestType',	'mthAccSum_RequestType',	'ko','','','',"<spring:message code='Cache.ACC_lbl_comboAll' />",pCompanyCode); //전체
				accountCtrl.renderAXSelect('SummarySheetSearchType', 	'mthAccSum_SearchType',		'ko','','','',null,pCompanyCode);
				
				if(pCompanyCode == undefined) {
					accountCtrl.renderAXSelect('CompanyCode',			'mthAccSum_CompanyCode',	'ko','','','',null,pCompanyCode);
				}
			},

			mthAccSum_comboRefresh : function() {
				accountCtrl.refreshAXSelect('mthAccSum_RequestType');
			},
			
			changeCompanyCode : function() {
				var me = this;
				me.mthAccSum_comboInit(accountCtrl.getComboInfo("mthAccSum_CompanyCode").val());
			},

			mthAccSum_gridInit : function() {
				var me = this;
				
				me.mthAccSum_searchMonthlyAccountSummaryList()
			},

			mthAccSum_gridHeaderInit : function() {
				var me = this;
				var getHead = [];
				
				var searchType = accountCtrl.getInfoStr("[name=searchParam][tag=SearchType]").val();
				
				getHead = expAppCommon.getGridHeader(searchType + "MonthAcc");
				
				if(searchType == "dept") {
					accountCtrl.getInfo("RegisterNm").parent("div").hide();
				} else {
					accountCtrl.getInfo("RegisterNm").parent("div").show();
				}
				
				me.setGridHead = getHead;
				accountCtrl.setViewPageGridHeader(getHead, me.gridPanel);
			},

			//조회조건 획득
			mthAccSum_getSearchParams : function() {
				var me = this;
				var searchInputList =	accountCtrl.getInfoName("searchParam");
				var retVal = {};
				for(var i=0;i<searchInputList.length; i++){
					var item = searchInputList[i];
					if(item!= null){
						if(item.tagName == 'DIV'){
							var fieldType= item.getAttribute("fieldtype")
							if(fieldType == "Date"){
								if(item.getAttribute("tag") == "PayDate") {
									var dateVal = accountCtrl.getInfo("mthAccSum_dateAreaPayDate").val();
									dateVal = dateVal.replaceAll(".", "");
									retVal[item.getAttribute("tag")] = dateVal;										
								} else {
									var stField = item.getAttribute("stfield")
									var edField = item.getAttribute("edfield")
									
									var stDataField = item.getAttribute("stdatafield")
									var edDataField = item.getAttribute("eddatafield")
									
									var stVal = accountCtrl.getInfo(stField).val()
									var edVal = accountCtrl.getInfo(edField).val()
									//var str = coviCtrl.getSimpleCalendar(item.id);
									stVal = stVal.replaceAll(".", "");
									edVal = edVal.replaceAll(".", "");
									retVal[stDataField] = stVal;
									retVal[edDataField] = edVal;										
								}
							}
						}else{
							var fieldType = item.getAttribute("fieldtype")
							if(fieldType == "Amt"){
								retVal[item.getAttribute("tag")] = AmttoNumFormat(item.value);
							}else{
								retVal[item.getAttribute("tag")] = item.value;
							}
						}
					}
				}

				retVal.ProofDate = retVal.ProofDate.replace("-", ""); 
				return retVal;
			},
			
			//조회
			mthAccSum_searchMonthlyAccountSummaryList : function(YN) {
				var me = this;
				
				var searchParam = me.mthAccSum_getSearchParams();
				
				me.mthAccSum_gridHeaderInit();
				
				var gridAreaID		= "mthAccSumListGrid";
				var gridPanel		= me.gridPanel;
				var gridHeader		= me.setGridHead;
				
				var ajaxUrl			= "/account/expenceApplication/searchMonthlyAccountSummaryList.do";
				var ajaxPars		= {
											"searchParam" : JSON.stringify(searchParam)
									}
				
				var pageNoInfo		= 1;
				var pageSizeInfo	= 200;
				
				var gridParams = {	"gridAreaID"	: gridAreaID
								,	"gridPanel"		: gridPanel
								,	"gridHeader"	: gridHeader
								,	"ajaxUrl"		: ajaxUrl
								,	"ajaxPars"		: ajaxPars
								,	"pageNoInfo"	: pageNoInfo
								,	"pageSizeInfo"	: pageSizeInfo
								,	"popupYN"		: "N"
								, 	"callback"		: me.mthAccSum_searchCallback
								,	"pagingTF"		: false
								,	"height"		: "550px"
								,	"fitToWidth"	: false
				}
				
				accountCtrl.setViewPageBindGrid(gridParams);
				
				accountCtrl.setGridBodyOption(gridPanel, ajaxUrl, ajaxPars);
			},
			
			mthAccSum_searchCallback : function() {
				var me = window.MonthlyAccountSummarySheet;
				var searchedType = accountCtrl.getInfoStr("[name=searchParam][tag=SearchType]").val();
				me.searchedType = searchedType;
				
				if(searchedType == "dept") {
					accountCtrl.getInfo("mthAccSumListGrid").find("table.gridBodyTable").find("tr.gridBodyTr:last").find("td").css("font-weight", "bold");
					accountCtrl.getInfo("mthAccSumListGrid").find("table.gridBodyTable").find("tr.gridBodyTr:last").find("td").css("background-color", "rgb(220, 248, 255)");
				}
			},
			
			//엑셀 다운로드
			mthAccSum_excelDownload : function(){
				var me = this;
				Common.Confirm("<spring:message code='Cache.ACC_msg_excelDownMessage'/>", "<spring:message code='Cache.ACC_btn_save' />", function(result){
			  		if(result){
			  			var headerName		= accountCommon.getHeaderNameForExcel(me.setGridHead);
						var headerKey		= accountCommon.getHeaderKeyForExcel(me.setGridHead);
						var searchParams	= me.mthAccSum_getSearchParams();
						
						var companyCode = searchParams.companyCode;
						var registerNm = searchParams.RegisterNm;
						var registerDept = searchParams.RegisterDept;
						//var chargeJob = searchParams.ChargeJob;
						var requestType = searchParams.RequestType;
						var accountCode = searchParams.AccountCode;
						//var payDate = searchParams.PayDate;
						//var mthAccSum_dateArea_St = searchParams.SearchAmtSt;
						//var mthAccSum_dateArea_Ed = searchParams.SearchAmtEd;
						var proofDate = searchParams.ProofDate;
						var title 			= accountCtrl.getInfo("headerTitle").text();
						var	locationStr		= "/account/expenceApplication/excelDownloadMonthlyAccountSummaryList.do?"
											//+ "headerName="		+ nullToBlank(headerName)
											+ "headerName="		+ encodeURIComponent(encodeURIComponent(headerName))
											+ "&headerKey="		+ nullToBlank(headerKey)
											+ "&companyCode="	+ nullToBlank(companyCode)
											+ "&searchType="	+ nullToBlank(accountCtrl.getInfoStr("[name=searchParam][tag=SearchType]").val())
											+ "&registerNm="	+ nullToBlank(registerNm)
											+ "&registerDept="	+ nullToBlank(registerDept)
											//+ "&chargeJob="	+ nullToBlank(chargeJob)
											+ "&requestType="	+ nullToBlank(requestType)
											+ "&accountCode="	+ nullToBlank(accountCode)
											//+ "&payDate="		+ nullToBlank(payDate)
											//+ "&mthAccSum_dateArea_St="		+ nullToBlank(mthAccSum_dateArea_St)
											//+ "&mthAccSum_dateArea_Ed="		+ nullToBlank(mthAccSum_dateArea_Ed)
											+ "&proofDate="		+ nullToBlank(proofDate)
											//+ "&title="			+ accountCtrl.getInfo("headerTitle").text();
											+ "&title="			+ encodeURIComponent(encodeURIComponent(title));
					
						location.href = locationStr;
			       	}
				});
			},

			pageOpenerIDStr : "openerID=MonthlyAccountSummarySheet&",
			
			mthAccSum_accDelete : function() {
				var me = this
				var labelField = accountCtrl.getInfoName("accNameBox").text("");
				var cdField = accountCtrl.getInfoStr("[name=searchParam][tag=AccountCode]").val("");
			},
			mthAccSum_accSearch : function() {
				var me = this;
				var popupID		=	"accountSearchPopup";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_account'/>";	//계정과목
				var popupName	=	"AccountSearchPopup";
				var callBack	=	"mthAccSum_accSearchComp";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	me.pageOpenerIDStr
								+	"callBackFunc="	+	callBack;
				Common.open(	"",popupID,popupTit,url,"740px","690px","iframe",true,null,null,true);
			},
			mthAccSum_accSearchComp : function(value) {
				var me = this
				var labelField = accountCtrl.getInfoName("accNameBox").text(value.AccountName);
				var cdField = accountCtrl.getInfoStr("[name=searchParam][tag=AccountCode]").val(value.AccountCode);
			},
			
			mthAccSum_ccDelete : function() {
				var me = this
				var labelField = accountCtrl.getInfoName("ccNameBox").text("");
				var cdField = accountCtrl.getInfoStr("[name=searchParam][tag=CostCenterCode]").val("");
			},
			mthAccSum_ccSearch : function() {
				var me = this;

				var popupID		=	"ccSearchPopup";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_costCenter'/>";	//코스트센터
				var popupName	=	"CostCenterSearchPopup";
				var callBack	=	"mthAccSum_ccSearchComp";
				var companyCode =	accountCtrl.getComboInfo("mthAccSum_CompanyCode").val();
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	"companyCode="	+	companyCode	+	"&"
								+	"includeAccount=N&"
								+	me.pageOpenerIDStr
								+	"popupType="	+ (Common.getBaseConfig("IsUseIO") == "Y" ? "CC" : "") + 	"&"
								+	"callBackFunc="	+	callBack;
				Common.open(	"",popupID,popupTit,url,"600px","730px","iframe",true,null,null,true);				
			},
			mthAccSum_ccSearchComp : function(value) {
				var me = this
				var labelField = accountCtrl.getInfoName("ccNameBox").text(value.CostCenterName);
				var cdField = accountCtrl.getInfoStr("[name=searchParam][tag=CostCenterCode]").val(value.CostCenterCode);
			},
			
			onenter : function(){
				var me = this;
				if(event.keyCode=="13"){
					me.mthAccSum_searchMonthlyAccountSummaryList();
				}
			}
	}
	window.MonthlyAccountSummarySheet = MonthlyAccountSummarySheet;
})(window);

	
</script>