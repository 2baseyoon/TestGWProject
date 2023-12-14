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
					<a class="btnTypeDefault btnExcel" href="#" onclick="MonthlyStandardBriefSummarySheet.mthSBSum_excelDownload();"><spring:message code="Cache.ACC_btn_excelDownload"/></a>
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
							<span id="mthSBSum_CompanyCode" class="selectType02" name="searchParam" tag="companyCode" onchange="MonthlyStandardBriefSummarySheet.changeCompanyCode()">
							</span>
						</div>		
						<div class="inPerTitbox">
							<!-- 기안자 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_aprvWriter"/></span>
							<input type="text" name="searchParam" tag="RegisterNm" id="mthSBSum_RegisterNm"
								onkeydown="MonthlyStandardBriefSummarySheet.onenter()">
						</div>
						<%-- <div class="inPerTitbox">
							<!-- 부서 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_dept"/></span>
							<input type="text" name="searchParam" tag="RegisterDept" id="mthSBSum_RegisterDept"
								onkeydown="MonthlyStandardBriefSummarySheet.onenter()">
						</div>	 --%>	
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<!-- 코스트센터 -->
								<spring:message code='Cache.ACC_lbl_costCenter'/>
							</span>
							<div class="name_box_wrap">
								<span class="name_box" name="ccNameBox" ></span>
								<a class="btn_del03" onclick="MonthlyStandardBriefSummarySheet.mthSBSum_ccDelete()"></a>
							</div>
							<a class="btn_search03" onclick="MonthlyStandardBriefSummarySheet.mthSBSum_ccSearch()"></a>
							<input  type="text" hidden name="searchParam" tag="CostCenterCode"
								onkeydown="MonthlyStandardBriefSummarySheet.onenter()" >
						</div>
					</div>		
					<div style="width:980px;">									
						<div class="inPerTitbox">
							<!-- 신청유형 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_requestType"/></span>
							<span id="mthSBSum_RequestType" class="selectType02" name="searchParam" tag="RequestType">
							</span>
						</div>
						<div class="inPerTitbox">
							<!-- 표준적요 -->
							<span class="bodysearch_tit"><spring:message code='Cache.ACC_standardBrief'/></span>
							<div class="name_box_wrap">
								<span class="name_box" name="sbNameBox" ></span>
								<a class="btn_del03" onclick="MonthlyStandardBriefSummarySheet.mthSBSum_sbDelete()"></a>
							</div>
							<a class="btn_search03" onclick="MonthlyStandardBriefSummarySheet.mthSBSum_sbSearch()"></a>
							<input  type="text" hidden name="searchParam" tag="StandardBriefID"
								onkeydown="MonthlyStandardBriefSummarySheet.onenter()" >
						</div>
						<%-- <div class="inPerTitbox">
							<!-- 지급일자 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_payDay"/></span>
							<div id="mthSBSum_dateAreaPayDate" class="dateSel type02" name="searchParam" tag="PayDate" fieldtype="Date">
							</div>
						</div> --%>
						<div class="inPerTitbox">
							<!-- 증빙일자 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_proofDate"/></span>
							<input type="text" id="mthSBSum_ProofDate" class="W70" kind="date" date_selectType="m" name="searchParam" tag="ProofDate" style="width: 90px;"/>
						</div>
						<a href="#" class="btnTypeDefault btnSearchBlue" onclick="MonthlyStandardBriefSummarySheet.mthSBSum_searchMonthlyStandardBriefSummaryList()"><spring:message code="Cache.ACC_btn_search"/></a>
					</div>
				</div>
			</div>
			<!-- 검색영역 끝 -->			
			<div class="inPerTitbox">
				<!-- 구분 -->
				<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_division"/></span>
				<span class="selectType02"	id="mthSBSum_SearchType" name="searchParam" tag="SearchType" onchange="MonthlyStandardBriefSummarySheet.mthSBSum_searchMonthlyStandardBriefSummaryList()">
				</span>
				<div class="buttonStyleBoxRight ">	
					<button class="btnRefresh" type="button" onclick="MonthlyStandardBriefSummarySheet.mthSBSum_searchMonthlyStandardBriefSummaryList();"></button>
				</div>
			</div>
			<!-- ===================== -->
			<div id="Grid" class="pad10">
				<div id="mthSBSumListGrid"></div>
			</div>
		</div>
		<!-- 컨텐츠 끝 -->
	</div>

<script>

if (!window.MonthlyStandardBriefSummarySheet) {
	window.MonthlyStandardBriefSummarySheet = {};
}

(function(window) {
	var MonthlyStandardBriefSummarySheet = {
			
			gridPanel : new coviGrid(),
			gridHeaderDataList : [],
			searchedType : "",
			setGridHead : [],

			pageInit : function() {
				var me = this;
				setHeaderTitle('headerTitle');

				me.gridHeaderDataList = expAppCommon.getGridHeader("monthSB"); //TODO: 월별 경비 계정별 집계표 header 가져오기 구현 필요
				
				//makeDatepicker('mthSBSum_dateArea', 'mthSBSum_dateArea_St', 'mthSBSum_dateArea_Ed', null, null, 100);
				//makeDatepicker('mthSBSum_dateAreaPayDate', 'mthSBSum_dateAreaPayDate', null, null, null, 220);
				
				//증빙일자 달력 컨트롤 바인딩 및 기본값 세팅				
				coviInput.setDate();
				
				var date = new Date();
				var lastDayOfMonth = new Date(date.getFullYear(), date.getMonth() , 1);
				var prevMonth = new Date (lastDayOfMonth.setDate(lastDayOfMonth.getDate() - 1));

				accountCtrl.getInfo("mthSBSum_ProofDate").val(prevMonth.getFullYear() + "-" + XFN_AddFrontZero(prevMonth.getMonth()+1, 2));

				me.mthSBSum_comboInit();
				me.mthSBSum_gridInit();		
			},
			pageView : function() {
				var me = this;
				coviInput.setDate();
				me.mthSBSum_comboRefresh();
				me.mthSBSum_searchMonthlyStandardBriefSummaryList();
			},

			mthSBSum_comboInit : function(pCompanyCode) {
				accountCtrl.getInfo("mthSBSum_RequestType").children().remove();
				accountCtrl.getInfo("mthSBSum_SearchType").children().remove();
				
				accountCtrl.getInfo("mthSBSum_RequestType").addClass("selectType02").attr("name", "searchParam").attr("tag", "RequestType")
				accountCtrl.getInfo("mthSBSum_SearchType").addClass("selectType02").attr("name", "searchParam").attr("tag", "SearchType").attr("onchange", "MonthlyStandardBriefSummarySheet.mthSBSum_searchMonthlyStandardBriefSummaryList()");
				
				accountCtrl.renderAXSelect('FormManage_RequestType',	'mthSBSum_RequestType',	'ko','','','',"<spring:message code='Cache.ACC_lbl_comboAll' />",pCompanyCode); //전체
				accountCtrl.renderAXSelect('SummarySheetSearchType', 	'mthSBSum_SearchType',	'ko','','','',null,pCompanyCode);

				if(pCompanyCode == undefined) {
					accountCtrl.renderAXSelect('CompanyCode', 			'mthSBSum_CompanyCode',	'ko','','','',null,pCompanyCode);
				}
				
			},

			mthSBSum_comboRefresh : function() {
				var me = this;
				accountCtrl.refreshAXSelect('mthSBSum_RequestType');
			},
			
			changeCompanyCode : function() {
				var me = this;
				me.mthAccSum_comboInit(accountCtrl.getComboInfo("mthSBSum_CompanyCode").val());
			},

			mthSBSum_gridInit : function() {
				var me = this;
				
				me.mthSBSum_searchMonthlyStandardBriefSummaryList()
			},

			mthSBSum_gridHeaderInit : function() {
				var me = this;
				var getHead = [];
				
				var searchType = accountCtrl.getInfoStr("[name=searchParam][tag=SearchType]").val();

				getHead = expAppCommon.getGridHeader(searchType + "MonthSB");

				if(searchType == "dept") {
					accountCtrl.getInfo("RegisterNm").parent("div").hide();
				} else {
					accountCtrl.getInfo("RegisterNm").parent("div").show();
				}
				
				me.setGridHead = getHead;
				accountCtrl.setViewPageGridHeader(getHead, me.gridPanel);
			},

			//조회조건 획득
			mthSBSum_getSearchParams : function() {
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
									var dateVal = accountCtrl.getInfo("mthSBSum_dateAreaPayDate").val();
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
			mthSBSum_searchMonthlyStandardBriefSummaryList : function(YN) {
				var me = this;
				
				var searchParam = me.mthSBSum_getSearchParams();
				
				me.mthSBSum_gridHeaderInit();
				
				var gridAreaID		= "mthSBSumListGrid";
				var gridPanel		= me.gridPanel;
				var gridHeader		= me.setGridHead;
				
				var ajaxUrl			= "/account/expenceApplication/searchMonthlyStandardBriefSummaryList.do";
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
								, 	"callback"		: me.mthSBSum_searchCallback
								,	"pagingTF"		: false
								,	"height"		: "550px"
								,	"fitToWidth"	: false
				}
				
				accountCtrl.setViewPageBindGrid(gridParams);
				
				accountCtrl.setGridBodyOption(gridPanel, ajaxUrl, ajaxPars);
			},
			
			mthSBSum_searchCallback : function() {
				var me = window.MonthlyStandardBriefSummarySheet;
				var searchedType = accountCtrl.getInfoStr("[name=searchParam][tag=SearchType]").val();
				me.searchedType = searchedType;				

				if(searchedType == "dept") {
					accountCtrl.getInfo("mthSBSumListGrid").find("table.gridBodyTable").find("tr.gridBodyTr:last").find("td").css("font-weight", "bold");
					accountCtrl.getInfo("mthSBSumListGrid").find("table.gridBodyTable").find("tr.gridBodyTr:last").find("td").css("background-color", "rgb(220, 248, 255)");
				}
			},
			
			//엑셀 다운로드
			mthSBSum_excelDownload : function(){
				var me = this;
				Common.Confirm("<spring:message code='Cache.ACC_msg_excelDownMessage'/>", "<spring:message code='Cache.ACC_btn_save' />", function(result){
			  		if(result){
			  			var headerName		= accountCommon.getHeaderNameForExcel(me.setGridHead);
						var headerKey		= accountCommon.getHeaderKeyForExcel(me.setGridHead);
						var searchParams	= me.mthSBSum_getSearchParams();

						var companyCode = searchParams.companyCode;
						var registerNm = searchParams.RegisterNm;
						var registerDept = searchParams.RegisterDept;
						//var chargeJob = searchParams.ChargeJob;
						var requestType = searchParams.RequestType;
						var standardBriefID = searchParams.StandardBriefID;
						//var payDate = searchParams.PayDate;
						//var mthSBSum_dateArea_St = searchParams.SearchAmtSt;
						//var mthSBSum_dateArea_Ed = searchParams.SearchAmtEd;
						var proofDate = searchParams.ProofDate;
						var title 			= accountCtrl.getInfo("headerTitle").text();
						var	locationStr		= "/account/expenceApplication/excelDownloadMonthlyStandardBriefSummaryList.do?"
											//+ "headerName="			+ nullToBlank(headerName)
											+ "headerName="		+ encodeURIComponent(encodeURIComponent(headerName))
											+ "&headerKey="			+ nullToBlank(headerKey)
											+ "&companyCode="		+ nullToBlank(companyCode)
											+ "&searchType="		+ nullToBlank(accountCtrl.getInfoStr("[name=searchParam][tag=SearchType]").val())
											+ "&registerNm="		+ nullToBlank(registerNm)
											+ "&registerDept="		+ nullToBlank(registerDept)
											//+ "&chargeJob="		+ nullToBlank(chargeJob)
											+ "&requestType="		+ nullToBlank(requestType)
											+ "&standardBriefID="	+ nullToBlank(standardBriefID)
											//+ "&payDate="			+ nullToBlank(payDate)
											//+ "&mthSBSum_dateArea_St="		+ nullToBlank(mthSBSum_dateArea_St)
											//+ "&mthSBSum_dateArea_Ed="		+ nullToBlank(mthSBSum_dateArea_Ed)
											+ "&proofDate="			+ nullToBlank(proofDate)
											//+ "&title="				+ accountCtrl.getInfo("headerTitle").text();
											+ "&title="			+ encodeURIComponent(encodeURIComponent(title));
					
						//location.href = locationStr;
						//GET 방식 다운로드시 URL 길이제한이 될 소지가 있음.
						var url = '/account/expenceApplication/excelDownloadMonthlyStandardBriefSummaryList.do';
						var params = {
								"headerName"		: encodeURIComponent(headerName)
								,"headerKey"		: nullToBlank(headerKey)
								,"companyCode"		: nullToBlank(companyCode)
								,"searchType"		: nullToBlank(accountCtrl.getInfoStr("[name=searchParam][tag=SearchType]").val())
								,"registerNm"		: nullToBlank(registerNm)
								,"registerDept"		: nullToBlank(registerDept)
								,"requestType"		: nullToBlank(requestType)
								,"standardBriefID"	: nullToBlank(standardBriefID)
								,"proofDate"		: nullToBlank(proofDate)
								,"title"			: encodeURIComponent(encodeURIComponent(title))
						};
						Common.downloadFilePost(url, params);
			       	}
				});
			},

			pageOpenerIDStr : "openerID=MonthlyStandardBriefSummarySheet&",
			
			mthSBSum_sbDelete : function() {
				var me = this
				var labelField = accountCtrl.getInfoName("sbNameBox").text("");
				var cdField = accountCtrl.getInfoStr("[name=searchParam][tag=StandardBriefID]").val("");
			},
			mthSBSum_sbSearch : function() {
				var me = this;
				var popupID		=	"standardBriefSearchPopup";
				var popupTit	=	"<spring:message code='Cache.ACC_standardBrief'/>";	//표준적요
				var popupName	=	"StandardBriefSearchPopup";
				var callBack	=	"mthSBSum_sbSearchComp";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	me.pageOpenerIDStr
								+	"callBackFunc="	+	callBack;
				Common.open(	"",popupID,popupTit,url,"1000px","700px","iframe",true,null,null,true);
				
			},
			mthSBSum_sbSearchComp : function(value) {
				var me = this
				var labelField = accountCtrl.getInfoName("sbNameBox").text(value.StandardBriefName);
				var cdField = accountCtrl.getInfoStr("[name=searchParam][tag=StandardBriefID]").val(value.StandardBriefID);
			},
			
			mthSBSum_ccDelete : function() {
				var me = this
				var labelField = accountCtrl.getInfoName("ccNameBox").text("");
				var cdField = accountCtrl.getInfoStr("[name=searchParam][tag=CostCenterCode]").val("");
			},
			mthSBSum_ccSearch : function() {
				var me = this;

				var popupID		=	"ccSearchPopup";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_costCenter'/>";	//코스트센터
				var popupName	=	"CostCenterSearchPopup";
				var callBack	=	"mthSBSum_ccSearchComp";
				var companyCode	=	accountCtrl.getComboInfo("mthSBSum_CompanyCode").val();
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
			mthSBSum_ccSearchComp : function(value) {
				var me = this
				var labelField = accountCtrl.getInfoName("ccNameBox").text(value.CostCenterName);
				var cdField = accountCtrl.getInfoStr("[name=searchParam][tag=CostCenterCode]").val(value.CostCenterCode);
			},
			
			onenter : function(){
				var me = this;
				if(event.keyCode=="13"){
					me.mthSBSum_searchMonthlyStandardBriefSummaryList();
				}
			}
	}
	window.MonthlyStandardBriefSummarySheet = MonthlyStandardBriefSummarySheet;
})(window);

	
</script>