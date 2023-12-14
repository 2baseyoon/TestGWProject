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
					<a class="btnTypeDefault btnExcel" href="#" onclick="MonthlyDeptSummarySheet.mthDeptSum_excelDownload();"><spring:message code="Cache.ACC_btn_excelDownload"/></a>
				</div>
				<div class="buttonStyleBoxRight ">	
					<button class="btnRefresh" type="button" onclick="MonthlyDeptSummarySheet.mthDeptSum_searchMonthlyDeptSummaryList();"></button>
				</div>
			</div>
			<!-- 상단 버튼 끝 -->
			<!-- 검색영역 시작 -->
			<div class="bodysearch_Type01">
				<div class="inPerView type08">
					<div style="width:830px;">
						<div class="inPerTitbox">
							<!-- 부서 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_dept"/></span>
							<input type="text" name="searchParam" tag="RegisterDept" id="RegisterDept"
								onkeydown="MonthlyDeptSummarySheet.onenter()">
						</div>	
					</div>		
					<div style="width:980px;">									
						<div class="inPerTitbox">
							<!-- 신청유형 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_requestType"/></span>
							<!-- <span id="mthDeptSum_ChargeJob" class="selectType02" name="searchParam" tag="ChargeJob">
							</span> -->
							<span id="mthDeptSum_RequestType" class="selectType02" name="searchParam" tag="RequestType">
							</span>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<!-- 계정과목 -->
								<spring:message code='Cache.ACC_lbl_account'/>
							</span>
							<div class="name_box_wrap">
								<span class="name_box" name="accNameBox" ></span>
								<a class="btn_del03" onclick="MonthlyDeptSummarySheet.mthDeptSum_accDelete()"></a>
							</div>
							<a class="btn_search03" onclick="MonthlyDeptSummarySheet.mthDeptSum_accSearch()"></a>
							<input  type="text" hidden name="searchParam" tag="AccountCode"
								onkeydown="MonthlyDeptSummarySheet.onenter()" >
						</div>
						<%-- <div class="inPerTitbox">
							<!-- 지급일자 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_payDay"/></span>
							<div id="mthDeptSum_dateAreaPayDate" class="dateSel type02" name="searchParam" tag="PayDate" fieldtype="Date">
							</div>
						</div> --%>
						<div class="inPerTitbox">
							<!-- 증빙일자 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_proofDate"/></span>
							<input type="text" id="mthDeptSum_ProofDate" class="W70" kind="date" date_selectType="m" name="searchParam" tag="ProofDate" style="width: 90px;"/>
						</div>
						<a href="#" class="btnTypeDefault btnSearchBlue" onclick="MonthlyDeptSummarySheet.mthDeptSum_searchMonthlyDeptSummaryList()"><spring:message code="Cache.ACC_btn_search"/></a>
					</div>
				</div>
			</div>
			<!-- ===================== -->
			<div id="Grid" class="pad10">
				<div id="mthDeptSumListGrid"></div>
			</div>
		</div>
		<!-- 컨텐츠 끝 -->
	</div>

<script>

if (!window.MonthlyDeptSummarySheet) {
	window.MonthlyDeptSummarySheet = {};
}

(function(window) {
	var MonthlyDeptSummarySheet = {
			
			gridPanel : new coviGrid(),
			gridHeaderDataList : [],
			setGridHead : [],

			pageInit : function() {
				var me = this;
				setHeaderTitle('headerTitle');

				me.gridHeaderDataList = expAppCommon.getGridHeader("monthDept"); //TODO: 월별 경비 계정별 집계표 header 가져오기 구현 필요
				
				//makeDatepicker('mthDeptSum_dateArea', 'mthDeptSum_dateArea_St', 'mthDeptSum_dateArea_Ed', null, null, 100);
				//makeDatepicker('mthDeptSum_dateAreaPayDate', 'mthDeptSum_dateAreaPayDate', null, null, null, 220);
				
				//증빙일자 달력 컨트롤 바인딩 및 기본값 세팅				
				coviInput.setDate();
				
				var date = new Date();
				var lastDayOfMonth = new Date(date.getFullYear(), date.getMonth() , 1);
				var prevMonth = new Date (lastDayOfMonth.setDate(lastDayOfMonth.getDate() - 1));

				accountCtrl.getInfo("mthDeptSum_ProofDate").val(prevMonth.getFullYear() + "-" + XFN_AddFrontZero(prevMonth.getMonth()+1, 2));

				me.mthDeptSum_comboInit();
				me.mthDeptSum_gridInit();		
			},
			pageView : function() {
				var me = this;
				coviInput.setDate();
				me.mthDeptSum_comboRefresh();
				me.mthDeptSum_searchMonthlyDeptSummaryList();
			},


			mthDeptSum_comboInit : function(defaultVal) {
				var me = this;
				//accountCtrl.renderAXSelect('ChargeJobList_Expence',	'mthDeptSum_ChargeJob',	'ko','','','', "<spring:message code='Cache.ACC_lbl_comboAll' />"); //전체
				accountCtrl.renderAXSelect('FormManage_RequestType',	'mthDeptSum_RequestType',	'ko','','','', "<spring:message code='Cache.ACC_lbl_comboAll' />"); //전체
				accountCtrl.refreshAXSelect('mthDeptSum_ChargeJob');
			},


			mthDeptSum_comboRefresh : function(defaultVal) {
				var me = this;
				//accountCtrl.refreshAXSelect('mthDeptSum_ChargeJob');
				accountCtrl.refreshAXSelect('mthDeptSum_RequestType');
			},

			mthDeptSum_gridInit : function() {
				var me = this;
				
				me.mthDeptSum_searchMonthlyDeptSummaryList()
			},


			mthDeptSum_gridHeaderInit : function() {
				var me = this;
				var getHead = [];

				getHead = expAppCommon.getGridHeader("monthDept");
				
				me.setGridHead = getHead;
				accountCtrl.setViewPageGridHeader(getHead, me.gridPanel);
			},

			//조회조건 획득
			mthDeptSum_getSearchParams : function() {
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
									var dateVal = accountCtrl.getInfo("mthDeptSum_dateAreaPayDate").val();
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
			mthDeptSum_searchMonthlyDeptSummaryList : function() {
				var me = this;
				
				var searchParam = me.mthDeptSum_getSearchParams();
				
				me.mthDeptSum_gridHeaderInit();
				
				var gridAreaID		= "mthDeptSumListGrid";
				var gridPanel		= me.gridPanel;
				var gridHeader		= me.setGridHead;
				
				var ajaxUrl			= "/account/expenceApplication/searchMonthlyDeptSummaryList.do";
				var ajaxPars		= {
											"searchParam" : JSON.stringify(searchParam)
									}
				
				var pageNoInfo		= 1;
				var pageSizeInfo	= 10;
				
				var gridParams = {	"gridAreaID"	: gridAreaID
								,	"gridPanel"		: gridPanel
								,	"gridHeader"	: gridHeader
								,	"ajaxUrl"		: ajaxUrl
								,	"ajaxPars"		: ajaxPars
								,	"pageNoInfo"	: pageNoInfo
								,	"pageSizeInfo"	: pageSizeInfo
								,	"popupYN"		: "N"
								,	"callback"		: me.mthDeptSum_searchCallBack
								,	"pagingTF"		: false
								,	"height"		: "550px"
								,	"fitToWidth"	: false
				}
				
				accountCtrl.setViewPageBindGrid(gridParams);
				
				accountCtrl.setGridBodyOption(gridPanel, ajaxUrl, ajaxPars);
			},
			
			mthDeptSum_searchCallBack : function() {
				accountCtrl.getInfo("mthDeptSumListGrid").find("table.gridBodyTable").find("tr.gridBodyTr:last").find("td").css("font-weight", "bold");
				accountCtrl.getInfo("mthDeptSumListGrid").find("table.gridBodyTable").find("tr.gridBodyTr:last").find("td").css("background-color", "rgb(220, 248, 255)");
			},
			
			//엑셀 다운로드
			mthDeptSum_excelDownload : function(){
				var me = this;
				Common.Confirm("<spring:message code='Cache.ACC_msg_excelDownMessage'/>", "<spring:message code='Cache.ACC_btn_save' />", function(result){
			  		if(result){
			  			var headerName		= accountCommon.getHeaderNameForExcel(me.setGridHead);
						var headerKey		= accountCommon.getHeaderKeyForExcel(me.setGridHead);
						var searchParams	= me.mthDeptSum_getSearchParams();
						
						var registerDept = searchParams.RegisterDept;
						var accountCode = searchParams.AccountCode;
						//var payDate = searchParams.PayDate;
						//var mthDeptSum_dateArea_St = searchParams.SearchAmtSt;
						//var mthDeptSum_dateArea_Ed = searchParams.SearchAmtEd;
						var proofDate = searchParams.ProofDate;
						
						var	locationStr		= "/account/expenceApplication/excelDownloadMonthlyDeptSummaryList.do?"
											+ "headerName="		+ nullToBlank(headerName)
											+ "&headerKey="		+ nullToBlank(headerKey)
											+ "&registerDept="	+ nullToBlank(registerDept)
											+ "&accountCode="	+ nullToBlank(accountCode)
											//+ "&payDate="		+ nullToBlank(payDate)
											//+ "&mthDeptSum_dateArea_St="		+ nullToBlank(mthDeptSum_dateArea_St)
											//+ "&mthDeptSum_dateArea_Ed="		+ nullToBlank(mthDeptSum_dateArea_Ed)
											+ "&proofDate="		+ nullToBlank(proofDate)
											+ "&title="			+ accountCtrl.getInfo("headerTitle").text();
					
						location.href = locationStr;
			       	}
				});
			},

			pageOpenerIDStr : "openerID=MonthlyDeptSummarySheet&",
			
			mthDeptSum_accDelete : function() {
				var me = this
				var labelField = accountCtrl.getInfoName("accNameBox").text("");
				var cdField = accountCtrl.getInfoStr("[name=searchParam][tag=AccountCode]").val("");
			},
			mthDeptSum_accSearch : function() {
				var me = this;
				var popupID		=	"accountSearchPopup";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_account'/>";	//계정과목
				var popupName	=	"AccountSearchPopup";
				var callBack	=	"mthDeptSum_accSearchComp";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	me.pageOpenerIDStr
								+	"callBackFunc="	+	callBack;
				Common.open(	"",popupID,popupTit,url,"740px","690px","iframe",true,null,null,true);
				
			},
			mthDeptSum_accSearchComp : function(value) {
				var me = this
				var labelField = accountCtrl.getInfoName("accNameBox").text(value.AccountName);
				var cdField = accountCtrl.getInfoStr("[name=searchParam][tag=AccountCode]").val(value.AccountCode);
			},
			
			onenter : function(){
				var me = this;
				if(event.keyCode=="13"){
					me.mthDeptSum_searchMonthlyDeptSummaryList();
				}
			}
	}
	window.MonthlyDeptSummarySheet = MonthlyDeptSummarySheet;
})(window);

	
</script>