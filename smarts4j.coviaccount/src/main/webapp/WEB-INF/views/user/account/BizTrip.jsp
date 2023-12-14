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
	<input id="searchProperty"	type="hidden" />
	<input id="syncProperty"	type="hidden" />
	<div class='cRContBottom mScrollVH'>
		<!-- 컨텐츠 시작 -->
		<div class="eaccountingCont">
			<div class="eaccountingTopCont">
				<!-- 상단 버튼 시작 -->
				<div class="pagingType02 buttonStyleBoxLeft">
					<!-- 새로고침 -->
					<a class="btnTypeDefault"			onclick="BizTrip.refresh()"><spring:message code="Cache.ACC_btn_refresh"/></a>
					<!-- 엑셀저장 -->
					<a class="btnTypeDefault btnExcel"	onclick="BizTrip.excelDownload()"><spring:message code="Cache.ACC_btn_excelDownload"/></a>
				</div>
				<!-- 상단 버튼 끝 -->				
			</div>
			<div id="searchbar1" class="bodysearch_Type01">
				<div class="inPerView type08">
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">	<!-- 회사코드 -->
								<spring:message code="Cache.ACC_lbl_companyCode"/>
							</span>
							<span id="CompanyCode" class="selectType02" onchange="BizTrip.changeCompanyCode();">
							</span>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">	<!-- 부서 -->
								<spring:message code="Cache.ACC_lbl_dept"/>
							</span>
							<input type="text" onkeydown="if(event.keyCode=='13'){BizTrip.searchList();}" id="RequesterDeptName">
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">	<!-- 사용자 -->
								<spring:message code="Cache.lbl_User"/>
							</span>
							<input type="text" onkeydown="if(event.keyCode=='13'){BizTrip.searchList();}" id="RequesterName">
						</div>
					</div>
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">	<!-- 출장구분 -->
								<spring:message code="Cache.ACC_lbl_bizTripType"/>
							</span>
							<span id="BizTripType" class="selectType02"></span>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">		<!-- 지역구분 -->
								<spring:message code="Cache.ACC_lbl_bizAreaType"/>
							</span>
							<span id="BusinessAreaType" class="selectType02"></span>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">		<!-- 정산상태 -->
								<spring:message code="Cache.ACC_lbl_applicationStatus"/>
							</span>
							<span id="ApplicationStatus" class="selectType02">
							</span>
						</div>
					</div>
					<div style="width:1200px">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">	<!-- 제목 -->
								<spring:message code="Cache.lbl_subject"/>
							</span>
							<input type="text" onkeydown="if(event.keyCode=='13'){BizTrip.searchList();}" id="RequestTitle">
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">	<!-- 프로젝트명 -->
								<spring:message code="Cache.ACC_lbl_projectName"/>
							</span>
							<span id="ProjectCode" class="selectType02"></span>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">		<!-- 출장기간 -->
								<spring:message code="Cache.ACC_lbl_bizTripTerm"/>
							</span>
							<div id="BizTripDate" class="dateSel type02"></div>
						</div>
						<a class="btnTypeDefault  btnSearchBlue" onclick="BizTrip.searchList()"><spring:message code="Cache.ACC_btn_search"/></a>
					</div>
				</div>
			</div>
			<div class="inPerTitbox">
				<div class="buttonStyleBoxRight">	
					<span id="listCount" class="selectType02 listCount" onchange="BizTrip.searchList()"></span>
					<button class="btnRefresh" type="button" onclick="BizTrip.searchList()"></button>
				</div>
			</div>
			<div id="gridArea" class="pad10">
			</div>
		</div>
	</div>
<script>

	if (!window.BizTrip) {
		window.BizTrip = {};
	}
	
	(function(window) {
		var BizTrip = {
				params	:{
					gridPanel	: new coviGrid(),
					headerData	: []
				},

				pageInit : function() {
					var me = this;
					setPropertySearchType('BizTrip','searchProperty');
					setPropertySyncType('BizTrip','syncProperty');
					setHeaderTitle('headerTitle');
					me.pageDatepicker();
					me.setSelectCombo();
					me.setHeaderData();
					me.searchList('Y');
				},

				pageView : function() {
					var me = this;
					
					me.setHeaderData();
					me.refreshCombo();
					
					me.searchList();
				},
				
				pageDatepicker : function(){
					makeDatepicker('BizTripDate','StartDate','EndDate','','','');
				},
				
				setSelectCombo : function(pCompanyCode){
					accountCtrl.getInfo("listCount").children().remove();
					accountCtrl.getInfo("BizTripType").children().remove();
					accountCtrl.getInfo("ProjectCode").children().remove();
					accountCtrl.getInfo("BusinessAreaType").children().remove();
					accountCtrl.getInfo("ApplicationStatus").children().remove();

					accountCtrl.getInfo("listCount").addClass("selectType02").addClass("listCount").attr("onchange", "BizTrip.searchList()");
					accountCtrl.getInfo("BizTripType").addClass("selectType02");
					accountCtrl.getInfo("ProjectCode").addClass("selectType02");
					accountCtrl.getInfo("BusinessAreaType").addClass("selectType02");
					accountCtrl.getInfo("ApplicationStatus").addClass("selectType02");
					
					var AXSelectMultiArr	= [	
							{'codeGroup':'listCountNum',			 'target':'listCount',			'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
						,	{'codeGroup':'BizTripType',				 'target':'BizTripType',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}
						,	{'codeGroup':'IOCode',					 'target':'ProjectCode',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}
						,	{'codeGroup':'BusinessAreaType',		 'target':'BusinessAreaType',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}
						,	{'codeGroup':'ExpenceApplicationStatus', 'target':'ApplicationStatus',	'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':'',	'useDefault':"<spring:message code='Cache.ACC_lbl_comboAll' />"}
						,	{'codeGroup':'CompanyCode',				 'target':'CompanyCode',		'lang':'ko',	'onchange':'',	'oncomplete':'',	'defaultVal':''}
					]
					
					if(pCompanyCode != undefined) {
						AXSelectMultiArr.pop(); //CompanyCode 제외
					}
					
					accountCtrl.renderAXSelectMulti(AXSelectMultiArr, pCompanyCode);
				},

				refreshCombo : function(){
					accountCtrl.refreshAXSelect("listCount");
					accountCtrl.refreshAXSelect("CompanyCode");
					accountCtrl.refreshAXSelect("BizTripType");
					accountCtrl.refreshAXSelect("BusinessAreaType");
					accountCtrl.refreshAXSelect("ApplicationStatus");
				},
				
				changeCompanyCode : function() {
					var me = this;
					me.setSelectCombo(accountCtrl.getComboInfo("CompanyCode").val());
				},

				setHeaderData : function() {
					var me = this;
					
					me.params.headerData = [{	key:'chk', label:'chk',	width:'20',	align:'center', formatter:'checkbox'	},
						{ 	key:'CompanyName',		label : "<spring:message code='Cache.ACC_lbl_company' />",					width:'100',		align:'center'},		//회사
						{	key:'RequestTitle',				label:"<spring:message code='Cache.lbl_subject' />",				width:'250',		align:'left', //제목
							formatter:function () {
								var rtStr =	""
											+	"<a onclick='BizTrip.callBizTripRequest(\""+ this.item.ProcessID +"\",\""+ this.item.RequestStatus +"\",\""+ this.item.FormInstID +"\"); return false;'>"
											+		"<font color='blue'>"
											+			this.item.RequestTitle
											+		"</font>"
											+	"</a>";
								return rtStr;
							}
						},
						{	key:'RequesterDeptName',		label:"<spring:message code='Cache.ACC_lbl_dept' />",				width:'100',		align:'center'}, //부서
						{	key:'RequesterName',			label:"<spring:message code='Cache.lbl_User' />",					width:'100',		align:'center'}, //사용자
						{	key:'BizTripTypeName',			label:"<spring:message code='Cache.ACC_lbl_bizTripType' />",		width:'100',		align:'center'}, //출장구분
						{	key:'ProjectName',				label:"<spring:message code='Cache.ACC_lbl_projectName' />",		width:'250',		align:'center'}, //프로젝트명
						//{	key:'RequestStatusName',		label:"<spring:message code='Cache.ACC_lbl_requestStatus' />",		width:'100',		align:'center'}, //신청상태
						{	key:'ApplicationStatusName',	label:"<spring:message code='Cache.ACC_lbl_applicationStatus' />",	width:'100',		align:'center',  //정산상태
							formatter:function () {
								var rtStr =	"";
								if(this.item.AppProcessID != undefined && this.item.AppProcessID != "" && this.item.ApplicationStatus != undefined && this.item.ApplicationStatus != "") {
									rtStr 	+=	"<a onclick='BizTrip.callBizTripApplication(\""+ this.item.BusinessAreaType +"\",\""+ this.item.BizTripRequestID +"\",\""+ this.item.AppProcessID +"\",\""+ this.item.ExpenceApplicationID +"\",\""+ this.item.ApplicationStatus +"\",\""+ this.item.FormInstID +"\"); return false;'>"
											+		"<font color='blue'>"
											+			this.item.ApplicationStatusName
											+		"</font>"
											+	"</a>";
									return rtStr;
								} else {
									return rtStr;
								}
							}
						},
						{	key:'StartDate',				label:"<spring:message code='Cache.ACC_lbl_startDate' />",			width:'100',		align:'center'}, //시작일
						{	key:'EndDate',					label:"<spring:message code='Cache.ACC_lbl_endDate' />",			width:'100',		align:'center'}, //종료일
						{	key:'BusinessAreaTypeName',		label:"<spring:message code='Cache.ACC_lbl_bizAreaType' />",		width:'100',		align:'center'}, //지역구분
						{	key:'BusinessArea',				label:"<spring:message code='Cache.ACC_lbl_bizTripPlace' />",		width:'200',		align:'center'}, //출장지
						{	key:'RequestDate',				label:"<spring:message code='Cache.ACC_lbl_applicationDay' />",		width:'100',		align:'center'}, //신청일
						{	key:'RequestAmount',			label:"<spring:message code='Cache.ACC_lbl_requestAmount' />",		width:'100',		align:'right',	 //예상경비
							formatter:function () {
								return toAmtFormat(this.item.RequestAmount);
							}
						},  
						{	key:'ApplicationDate',			label:"<spring:message code='Cache.ACC_lbl_applicationDate' />",	width:'100',		align:'center'}, //정산일
						{	key:'Amount',					label:"<spring:message code='Cache.ACC_lbl_bizTripAmount' />",		width:'100',		align:'right',	 //출장경비
							formatter:function () {
								return toAmtFormat(this.item.Amount);
							}
						}
					]
					
					var gridPanel	= me.params.gridPanel;
					var gridHeader	= me.params.headerData;
					accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
				},

				searchList : function(YN){
					var me = this;
					
					me.setHeaderData();
					
					var CompanyCode			= accountCtrl.getComboInfo("CompanyCode").val();
					var RequestTitle 		= accountCtrl.getInfo("RequestTitle").val();
					var RequesterDeptName 	= accountCtrl.getInfo("RequesterDeptName").val();
					var RequesterName 		= accountCtrl.getInfo("RequesterName").val();
					var BizTripType			= accountCtrl.getComboInfo("BizTripType").val();
					var ProjectCode			= accountCtrl.getComboInfo("ProjectCode").val();
					var BusinessAreaType	= accountCtrl.getComboInfo("BusinessAreaType").val();
					//var RequestStatus		= accountCtrl.getComboInfo("RequestStatus").val();
					var ApplicationStatus	= accountCtrl.getComboInfo("ApplicationStatus").val();
					var StartDate			= accountCtrl.getInfo("StartDate").val().replace(/\./gi, '-');		
					var EndDate				= accountCtrl.getInfo("EndDate").val().replace(/\./gi, '-');								
					
					var gridAreaID		= "gridArea";
					var gridPanel		= me.params.gridPanel;
					var gridHeader		= me.params.headerData;
					var ajaxUrl			= "/account/bizTrip/searchBizTripList.do";
					var ajaxPars		= {	"RequestTitle"		: RequestTitle,
											"RequesterDeptName"	: RequesterDeptName,
							 				"RequesterName"		: RequesterName,
							 				"BizTripType"		: BizTripType,
							 				"ProjectCode"		: ProjectCode,
							 				"BusinessAreaType"	: BusinessAreaType,
							 				//"RequestStatus"		: RequestStatus,
							 				"ApplicationStatus"	: ApplicationStatus,
							 				"StartDate"			: StartDate,
							 				"EndDate" 			: EndDate,
							 				"companyCode"		: CompanyCode
					};
					
					var pageSizeInfo	= accountCtrl.getComboInfo("listCount").val();
					var pageNoInfo		= accountCtrl.getGridViewPageNum(YN,gridPanel,pageSizeInfo);
					
					var gridParams = {	"gridAreaID"	: gridAreaID
									,	"gridPanel"		: gridPanel
									,	"gridHeader"	: gridHeader
									,	"ajaxUrl"		: ajaxUrl
									,	"ajaxPars"		: ajaxPars
									,	"pageNoInfo"	: pageNoInfo
									,	"pageSizeInfo"	: pageSizeInfo
									,	"popupYN"		: "N"
									,	"fitToWidth"	: false
					}
					
					accountCtrl.setViewPageBindGrid(gridParams);
				},
				
				excelDownload : function(){
					var me = this;
					Common.Confirm("<spring:message code='Cache.ACC_msg_excelDownMessage'/>", "<spring:message code='Cache.ACC_btn_save' />", function(result){
				  		if(result){
							var headerName		= accountCommon.getHeaderNameForExcel(me.params.headerData);
							var headerKey		= accountCommon.getHeaderKeyForExcel(me.params.headerData);

							var CompanyCode			= accountCtrl.getComboInfo("CompanyCode").val();
							var RequestTitle 		= accountCtrl.getInfo("RequestTitle").val();
							var RequesterDeptName 	= accountCtrl.getInfo("RequesterDeptName").val();
							var RequesterName 		= accountCtrl.getInfo("RequesterName").val();
							var BizTripType			= accountCtrl.getComboInfo("BizTripType").val();
							var ProjectCode			= accountCtrl.getComboInfo("ProjectCode").val();
							var BusinessAreaType	= accountCtrl.getComboInfo("BusinessAreaType").val();
							var ApplicationStatus	= accountCtrl.getComboInfo("ApplicationStatus").val();
							var StartDate			= accountCtrl.getInfo("StartDate").val().replace(/\./gi, '-');		
							var EndDate				= accountCtrl.getInfo("EndDate").val().replace(/\./gi, '-');
							var title 				= accountCtrl.getInfo("headerTitle").text();
							
							var	locationStr		= "/account/bizTrip/bizTripExcelDownload.do?"
												//+ "headerName="			+ headerName
												+ "headerName="			+ encodeURIComponent(encodeURIComponent(headerName))
												+ "&headerKey="			+ headerKey
												+ "&RequestTitle="		+ RequestTitle
												+ "&RequesterDeptName="	+ RequesterDeptName
												+ "&RequesterName="		+ RequesterName
												+ "&BizTripType="		+ BizTripType
												+ "&ProjectCode="		+ ProjectCode
												+ "&BusinessAreaType="	+ BusinessAreaType
												+ "&ApplicationStatus="	+ ApplicationStatus
												+ "&StartDate="			+ StartDate
												+ "&EndDate="			+ EndDate
												+ "&companyCode="		+ CompanyCode
												//+ "&title="				+ accountCtrl.getInfo("headerTitle").text();
												+ "&title="				+ encodeURIComponent(encodeURIComponent(title));
						
							location.href = locationStr;
				       	}
					});
				},
				
				//출장신청서 조회
				callBizTripRequest : function(ProcessID, RequestStatus, FormInstID) {
					var me = this;
					
					if(ProcessID == undefined)
						return;
					
					var mode = "PROCESS";
					if(RequestStatus == "E")
						mode = "COMPLETE";
					else if(RequestStatus == "R")
						mode = "REJECT";

					CFN_OpenWindow("/approval/approval_Form.do?mode=" + mode + "&processID="+ ProcessID + "&forminstanceID=" + FormInstID, '', 790, (window.screen.height-100), 'scroll');					
				},
				
				//출장정산서 조회
				callBizTripApplication : function(BusinessAreaType, BizTripRequestID, AppProcessID, ExpenceApplicationID, ApplicationStatus, AppFormInstID) {
					var me = this;
					var requestType = "";
					
					switch(BusinessAreaType){
						case "D": requestType = "BIZTRIP"; break;
						case "O": requestType = "OVERSEA"; break;
						default: requestType = "BIZTRIP"; break;
					}
					
					if(AppProcessID == undefined || ExpenceApplicationID == undefined)
						return;

					var mode = "PROCESS";
					if(ApplicationStatus == "E")
						mode = "COMPLETE";
					else if(ApplicationStatus == "R")
						mode = "REJECT";
					
					CFN_OpenWindow("/account/expenceApplication/ExpenceApplicationViewPopup.do?mode="+mode+"&processID="+AppProcessID+"&forminstanceID="+AppFormInstID+"&ExpAppID="+ExpenceApplicationID+"&requestType="+requestType, "", 1070, (window.screen.height-100), "both");				
				},
				
				refresh : function(){
					accountCtrl.pageRefresh();
				}
		}
		window.BizTrip = BizTrip;
	})(window);
</script>