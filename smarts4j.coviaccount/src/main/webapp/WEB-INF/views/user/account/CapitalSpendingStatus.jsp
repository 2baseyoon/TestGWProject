<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.coviaccount.common.util.AccountUtil" %>
<%
	AccountUtil accountUtil = new AccountUtil();
	String propertyAprv = accountUtil.getBaseCodeInfo("eAccApproveType", "ExpenceApplication");
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
					<a class="btnTypeDefault btnExcel" href="#" onclick="CapitalSpendingStatus.cptSped_excelDownload();"><spring:message code="Cache.ACC_btn_excelDownload"/></a>
				<%
					if(propertyAprv==null){
						propertyAprv = "";
					}
					if("APRV".equals(propertyAprv)){
				%>	<!-- 지출보고(전체) -->
					<a class="btnTypeDefault" onclick="CapitalSpendingStatus.cptSped_OpenCapitalSpendingForm('REP', 'A');" name="capitalBtn"><spring:message code="Cache.ACC_btn_capitalReport"/>(<spring:message code="Cache.lbl_all"/>)</a>
					<!-- 지출보고(개별) -->
					<a class="btnTypeDefault" onclick="CapitalSpendingStatus.cptSped_OpenCapitalSpendingForm('REP', 'I');" name="capitalBtn"><spring:message code="Cache.ACC_btn_capitalReport"/>(<spring:message code="Cache.lbl_each"/>)</a>
					<!-- 지출결의(전체) -->
					<a class="btnTypeDefault" onclick="CapitalSpendingStatus.cptSped_OpenCapitalSpendingForm('RES', 'A');" name="capitalBtn"><spring:message code="Cache.ACC_btn_capitalResolution"/>(<spring:message code="Cache.lbl_all"/>)</a>
					<!-- 지출결의(개별) -->
					<a class="btnTypeDefault" onclick="CapitalSpendingStatus.cptSped_OpenCapitalSpendingForm('RES', 'I');" name="capitalBtn"><spring:message code="Cache.ACC_btn_capitalResolution"/>(<spring:message code="Cache.lbl_each"/>)</a>
				<% 
					}
				%>		
					<!-- 보류 -->
					<a class="btnTypeDefault" href="#" onclick="CapitalSpendingStatus.cptSped_updateCapitalStatus('H');"><spring:message code="Cache.lbl_apv_hold"/></a>
					<!-- 보류취소 -->
					<a class="btnTypeDefault" href="#" onclick="CapitalSpendingStatus.cptSped_updateCapitalStatus('W');"><spring:message code="Cache.lbl_apv_hold"/><spring:message code="Cache.ACC_btn_cancel"/></a>
					<!-- 편집 -->
					<a class="btnTypeDefault" href="#" onclick="CapitalSpendingStatus.cptSped_openEditPopup();"><spring:message code="Cache.btn_apv_modify"/></a>
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
							<span id="cptSped_CompanyCode" class="selectType02" name="searchParam" tag="companyCode" onchange="CapitalSpendingStatus.changeCompanyCode()">
							</span>
						</div>				
						<div class="inPerTitbox">
							<!-- 제목 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_title"/></span>
							<input type="text" name="searchParam" tag="ApplicationTitle" id="cptSped_ApplicationTitle"
								onkeydown="CapitalSpendingStatus.onenter()">
						</div>
						<div class="inPerTitbox">
							<!-- 기안자 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_aprvWriter"/></span>
							<input type="text" name="searchParam" tag="RegisterNm" id="cptSped_RegisterNm"
								onkeydown="CapitalSpendingStatus.onenter()">
						</div>
					</div>
					<div style="width:1200px;">
						<div class="inPerTitbox">
							<!-- 처리상태 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_processStatus"/></span>
							<span id="cptSped_CapitalStatus" class="selectType02" name="searchParam" tag="CapitalStatus">
							</span>
						</div>
						<div class="inPerTitbox">
							<!-- 증빙종류 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_proofClass"/></span>
							<span id="cptSped_ProofCode" class="selectType02" name="searchParam" tag="ProofCode">
							</span>
						</div>
						<div class="inPerTitbox">
							<!-- 자금집행일 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_realPayDate"/></span>
							<div id="cptSped_dateAreaRealPayDate" class="dateSel type02" name="searchParam" tag="RealPayDate" fieldtype="Date">
							</div>
						</div>
						<div class="inPerTitbox">
							<!-- 거래처명 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_vendorName"/></span>
							<input type="text" name="searchParam" tag="VendorName"
								onkeydown="CapitalSpendingStatus.onenter()">
						</div>
					</div>
					<div style="width:1200px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<!-- 코스트센터 -->
								<spring:message code='Cache.ACC_lbl_costCenter'/>
							</span>
							<div class="name_box_wrap">
								<span class="name_box" name="ccNameBox" ></span>
								<a class="btn_del03" onclick="CapitalSpendingStatus.cptSped_ccDelete()"></a>
							</div>
							<a class="btn_search03" onclick="CapitalSpendingStatus.cptSped_ccSearch()"></a>
							<input  type="text" hidden name="searchParam" tag="CostCenterCode"
								onkeydown="CapitalSpendingStatus.onenter()" >
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<!-- 계정과목 -->
								<spring:message code='Cache.ACC_lbl_account'/>
							</span>
							<div class="name_box_wrap">
								<span class="name_box" name="accNameBox" ></span>
								<a class="btn_del03" onclick="CapitalSpendingStatus.cptSped_accDelete()"></a>
							</div>
							<a class="btn_search03" onclick="CapitalSpendingStatus.cptSped_accSearch()"></a>
							<input  type="text" hidden name="searchParam" tag="AccountCode"
								onkeydown="CapitalSpendingStatus.onenter()" >
						</div>
						<div class="inPerTitbox">
							<!-- 표준적요 -->
							<span class="bodysearch_tit"><spring:message code='Cache.ACC_standardBrief'/></span>
							<div class="name_box_wrap">
								<span class="name_box" name="sbNameBox" ></span>
								<a class="btn_del03" onclick="CapitalSpendingStatus.cptSped_sbDelete()"></a>
							</div>
							<a class="btn_search03" onclick="CapitalSpendingStatus.cptSped_sbSearch()"></a>
							<input  type="text" hidden name="searchParam" tag="StandardBriefID"
								onkeydown="CapitalSpendingStatus.onenter()" >
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<!-- 프로젝트명 -->
								<spring:message code='Cache.ACC_lbl_projectName'/>
							</span>
							<div class="name_box_wrap">
								<span class="name_box" name="ioNameBox" ></span>
								<a class="btn_del03" onclick="CapitalSpendingStatus.cptSped_ioDelete()"></a>
							</div>
							<a class="btn_search03" onclick="CapitalSpendingStatus.cptSped_ioSearch()"></a>
							<input  type="text" hidden name="searchParam" tag="IOCode" >						
						</div>
						<a href="#" class="btnTypeDefault btnSearchBlue" onclick="CapitalSpendingStatus.cptSped_searchCapitalSpendingList()"><spring:message code="Cache.ACC_btn_search"/></a>
					</div>
				</div>
			</div>
			<!-- 검색영역 끝 -->
			<div class="inPerTitbox">
				<div class="buttonStyleBoxRight ">	
					<span class="selectType02 listCount" id="cptSpedListCount" onchange="CapitalSpendingStatus.cptSped_searchCapitalSpendingList();">
					</span>
					<button class="btnRefresh" type="button" onclick="CapitalSpendingStatus.cptSped_searchCapitalSpendingList();"></button>
				</div>
			</div>
			<!-- ===================== -->
			<div id="Grid" class="pad10">
				<div id="cptSpedListGrid"></div>
			</div>
			
			<div name="hiddenLinkArea" ></div>
		</div>
		<!-- 컨텐츠 끝 -->
	</div>

<script>

if (!window.CapitalSpendingStatus) {
	window.CapitalSpendingStatus = {};
}

(function(window) {
	
	var CapitalSpendingStatus = {
			
			gridPanel : new coviGrid(),
			searchedType : "",
			setGridHead : [],
			auditInfo : {},

			pageInit : function() {
				var me = this;
				
				setHeaderTitle('headerTitle');
				
				var today = new Date();
				var gy = today.getFullYear();
				var gm = today.getMonth();
				var gd = today.getDate();
				
				makeDatepicker('cptSped_dateAreaRealPayDate', 'cptSped_dateAreaRealPayDate', null, null, null, 150);

				me.cptSped_comboInit();
				me.cptSped_gridInit();		
			},

			pageView : function() {
				var me = this;
				me.cptSped_comboRefresh();
				
				me.cptSped_searchCapitalSpendingList();
			},

			cptSped_comboInit : function(pCompanyCode) {
				accountCtrl.getInfo("cptSpedListCount").children().remove();
				accountCtrl.getInfo("cptSped_CapitalStatus").children().remove();
				accountCtrl.getInfo("cptSped_ProofCode").children().remove();

				accountCtrl.getInfo("cptSpedListCount").addClass("selectType02").attr("onchange", "CapitalSpendingStatus.cptSped_searchCapitalSpendingList()");
				accountCtrl.getInfo("cptSped_CapitalStatus").addClass("selectType02").attr("name", "searchParam").attr("tag", "CapitalStatus");
				accountCtrl.getInfo("cptSped_ProofCode").addClass("selectType02").attr("name", "searchParam").attr("tag", "ProofCode");
				
				accountCtrl.renderAXSelect('listCountNum',	'cptSpedListCount',		 'ko','','','',null,pCompanyCode);
				accountCtrl.renderAXSelect('CapitalStatus',	'cptSped_CapitalStatus', 'ko','','','', "<spring:message code='Cache.ACC_lbl_comboAll' />",pCompanyCode);
				accountCtrl.renderAXSelect('ProofCode',		'cptSped_ProofCode', 	 'ko','','','', "<spring:message code='Cache.ACC_lbl_comboAll' />",pCompanyCode);	//전체

				if(pCompanyCode == undefined) {
					accountCtrl.renderAXSelect('CompanyCode',	'cptSped_CompanyCode',	 'ko','','','');
				}
				
				// 자금지출결의서 조회 건수 최대 100개
				accountCtrl.getComboInfo("cptSpedListCount").append("<option value='100'>100</option>");
				accountCtrl.refreshAXSelect("cptSpedListCount");
			},
			cptSped_comboRefresh : function() {
				var me = this;
				accountCtrl.refreshAXSelect('cptSped_CapitalStatus');
				accountCtrl.refreshAXSelect('cptSped_ProofCode');
				accountCtrl.refreshAXSelect('cptSped_CompanyCode');
			},
			
			changeCompanyCode : function() {
				var me = this;
				me.cptSped_comboInit(accountCtrl.getComboInfo("cptSped_CompanyCode").val());
			},
			
			cptSped_gridInit : function() {
				var me = this;
				me.cptSped_searchCapitalSpendingList();
			},

			cptSped_gridHeaderInit : function() {
				var me = this;
				var getHead = [];

				getHead = expAppCommon.getGridHeader("capital");
				
				me.setGridHead = getHead;
				accountCtrl.setViewPageGridHeader(getHead, me.gridPanel);
			},

			//조회조건 획득
			cptSped_getSearchParams : function() {
				var me = this;
				var searchInputList =	accountCtrl.getInfoName("searchParam");
				var retVal = {};
					for(var i=0;i<searchInputList.length; i++){
						var item = searchInputList[i];
						if(item!= null){
							if(item.tagName == 'DIV'){

								var fieldType= item.getAttribute("fieldtype")
								if(fieldType == "Date"){
									if(item.getAttribute("tag") == "RealPayDate") {
										var dateVal = accountCtrl.getInfo("cptSped_dateAreaRealPayDate").val();
										dateVal = dateVal.replaceAll(".", "");
										retVal[item.getAttribute("tag")] = dateVal;										
									} else {
										var stField = item.getAttribute("stfield")
										var edField = item.getAttribute("edfield")
										
										var stDataField = item.getAttribute("stdatafield")
										var edDataField = item.getAttribute("eddatafield")
										
										var stVal = accountCtrl.getInfo(stField).val()
										var edVal = accountCtrl.getInfo(edField).val()
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
				return retVal;
			},
			
			//조회
			cptSped_searchCapitalSpendingList : function(YN) {
				var me = this;
				
				var searchParam = me.cptSped_getSearchParams();
				
				me.cptSped_gridHeaderInit();
				
				var pageSize	= accountCtrl.getComboInfo("cptSpedListCount").val();
				
				var gridAreaID		= "cptSpedListGrid";
				var gridPanel		= me.gridPanel;
				var gridHeader		= me.setGridHead;
				
				var ajaxUrl			= "/account/expenceApplication/searchCapitalSpendingStatus.do";
				var ajaxPars		= {
											"searchParam" : JSON.stringify(searchParam)
											, "pageSize":pageSize,
										}
				
				var pageSizeInfo	= accountCtrl.getComboInfo("cptSpedListCount").val();
				var pageNoInfo		= accountCtrl.getGridViewPageNum(YN,gridPanel,pageSizeInfo);
				
				var gridParams = {	"gridAreaID"	: gridAreaID
								,	"gridPanel"		: gridPanel
								,	"gridHeader"	: gridHeader
								,	"ajaxUrl"		: ajaxUrl
								,	"ajaxPars"		: ajaxPars
								,	"pageNoInfo"	: pageNoInfo
								,	"pageSizeInfo"	: pageSizeInfo
								,	"popupYN"		: "N"
								, 	"callback"		: me.cptSped_searchCallback
								,	"fitToWidth"	: false
				}
				
				accountCtrl.setViewPageBindGrid(gridParams);
			},
			

			//조회 후처리
			cptSped_searchCallback : function() {
				var me = window.CapitalSpendingStatus;
				var searchedType = accountCtrl.getInfoStr("[name=searchParam][tag=SearchType]").val();
				me.searchedType = searchedType;
			},
			
			//신청 건 보기
			cptSped_viewExpAppPopup : function(getId, ProcessID, FormInstID) {
				var me = this;
				//전표조회
				Common.open("","expenceApplicationViewPopup"+getId,"<spring:message code='Cache.ACC_lbl_expenceApplicationView'/>",
					"/account/expenceApplication/ExpenceApplicationViewPopup.do?ExpAppID="+getId+"&processID="+ProcessID+"&forminstanceID="+FormInstID,"1000px","800px","iframe",true,"450px","100px",true);
			},
			
			//파일보기
			cptSped_ViewFile : function(getId) {
				var me = this;
				//첨부파일
				Common.open("","cptSpedViewFile","<spring:message code='Cache.ACC_lbl_addFile'/>",	
					"/account/expenceApplication/ExpenceApplicationViewFilePopup.do?ExpAppListID="+getId,"350px","400px","iframe",true,null,null,true);
			},

			cptSped_LinkOpen : function(stat, ProcessId){
				var me = this;
				if(ProcessId != null){					
					var url = document.location.protocol + "//" + document.location.host + "/approval/legacy/goFormLink.do";
					var form = document.createElement("form");
					form.method = "POST";
					form.target = "form";
					form.action = url;
					form.style.display = "none";
					
					var processID = document.createElement("input");
					processID.type = "hidden";
					processID.name = "processID";
					processID.value = ProcessId;
					
					var logonId = document.createElement("input");
					logonId.type = "hidden";
					logonId.name = "logonId";
					logonId.value = Common.getSession("USERID");
					
					form.appendChild(processID);
					form.appendChild(logonId);
					
					document.body.appendChild(form);
					
				    window.open("", "form", "toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=0,resizable=1,width="+(window.screen.width - 100)+",height="+(window.screen.height - 100));
				    form.submit();
				}
			},
			
			
			//증빙보기
			cptSped_viewEvidListItem : function(ProofCode, LinkKey) {
				var me = this;
				
				if(isEmptyStr(LinkKey)){
					Common.Inform("<spring:message code='Cache.ACC_047'/>");	//정보를 조회할 수 없습니다. 관리자에게 문의해 주세요.
					return;
				}
				
				if(ProofCode=="CorpCard"){
					accComm.accCardAppClick(LinkKey, me.pageOpenerIDStr);
				}
				else if(ProofCode=="TaxBill"){
					accComm.accTaxBillAppClick(LinkKey, me.pageOpenerIDStr);
				}
				else if(ProofCode=="Receipt"){
					var popupID		=	"fileViewPopup";
					var popupTit	=	"<spring:message code='Cache.ACC_lbl_receiptPopup'/>";	//영수증 보기
					var popupName	=	"FileViewPopup";
					var callBack	=	"cptSped_ZoomMobileAppClick";
					var url			=	"/account/accountCommon/accountCommonPopup.do?"
									+	"popupID="		+	popupID		+	"&"
									+	"popupName="	+	popupName	+	"&"
									+	"fileID="	+	LinkKey	+	"&"
									+	me.pageOpenerIDStr
									+	"callBackFunc="	+	callBack;
					Common.open(	"",popupID,popupTit,url,"340px","500px","iframe",true,null,null,true);
				}
			},
			
			cptSped_ZoomMobileAppClick : function(info){
				var me = this;
				
				var popupID		=	"fileViewPopupZoom";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_receiptPopup'/>";	//영수증 보기
				var popupName	=	"FileViewPopup";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	"fileID="		+	info.FileID	+	"&"					
								+	me.pageOpenerIDStr				+	"&"
								+	"zoom="			+	"Y"		
				Common.open(	"",popupID,popupTit,url,"490px","700px","iframe",true,null,null,true);
			},
			
			//엑셀 다운로드
			cptSped_excelDownload : function(){
				var me = this;
				Common.Confirm("<spring:message code='Cache.ACC_msg_excelDownMessage'/>", "<spring:message code='Cache.ACC_btn_save' />", function(result){
			  		if(result){
			  			var headerName		= accountCommon.getHeaderNameForExcel(me.setGridHead);
						var headerKey		= accountCommon.getHeaderKeyForExcel(me.setGridHead);
 						var searchParams	= me.cptSped_getSearchParams();
						
						var applicationTitle = searchParams.ApplicationTitle;
						var registerNm = searchParams.RegisterNm;
						var vendorName = searchParams.VendorName;
						var capitalStatus = searchParams.CapitalStatus;
						var proofCode = searchParams.ProofCode;
						var requestType = searchParams.RequestType;
						var realPayDate = searchParams.RealPayDate;
						var costCenterCode = searchParams.CostCenterCode;
						var accountCode = searchParams.AccountCode;
						var standardBriefID = searchParams.StandardBriefID;
						var IOCode = searchParams.IOCode;
						var title = accountCtrl.getInfo("headerTitle").text();
						var CompanyCode	= searchParams.companyCode;
						var	locationStr		= "/account/expenceApplication/excelDownloadCapitalSpendingStatus.do?"
											//+ "headerName="			+ encodeURIComponent(nullToBlank(headerName))
											+ "headerName="		+ encodeURIComponent(encodeURIComponent(headerName))
											+ "&headerKey="			+ encodeURIComponent(nullToBlank(headerKey))
											+ "&applicationTitle="	+ encodeURIComponent(nullToBlank(applicationTitle))
											+ "&registerNm="		+ encodeURIComponent(nullToBlank(registerNm))
											+ "&vendorName="		+ encodeURIComponent(nullToBlank(vendorName))
											+ "&capitalStatus="		+ encodeURIComponent(nullToBlank(capitalStatus))
											+ "&proofCode="			+ encodeURIComponent(nullToBlank(proofCode))
											+ "&requestType="		+ encodeURIComponent(nullToBlank(requestType))
											+ "&realPayDate="		+ encodeURIComponent(nullToBlank(realPayDate))
											+ "&costCenterCode="	+ encodeURIComponent(nullToBlank(costCenterCode))
											+ "&accountCode="		+ encodeURIComponent(nullToBlank(accountCode))
											+ "&standardBriefID="	+ encodeURIComponent(nullToBlank(standardBriefID))
											+ "&IOCode="			+ encodeURIComponent(nullToBlank(IOCode))
											+ "&title="				+ encodeURIComponent(encodeURIComponent(title))
											+ "&CompanyCode="		+ encodeURI(CompanyCode);
						
						
						location.href = locationStr;
			       	}
				});
			},

			pageOpenerIDStr : "openerID=CapitalSpendingStatus&",
			cptSped_ccDelete : function() {
				var me = this
				var labelField = accountCtrl.getInfoName("ccNameBox").text("");
				var cdField = accountCtrl.getInfoStr("[name=searchParam][tag=CostCenterCode]").val("");
			},
			cptSped_ccSearch : function() {
				var me = this;

				var popupID		=	"ccSearchPopup";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_costCenter'/>";	//코스트센터
				var popupName	=	"CostCenterSearchPopup";
				var callBack	=	"cptSped_ccSearchComp";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	"includeAccount=N&"
								+	me.pageOpenerIDStr
								+	"popupType="	+ (Common.getBaseConfig("IsUseIO") == "Y" ? "CC" : "") + 	"&"
								+	"callBackFunc="	+	callBack;
				Common.open(	"",popupID,popupTit,url,"600px","730px","iframe",true,null,null,true);
				
			},
			cptSped_ccSearchComp : function(value) {
				var me = this
				var labelField = accountCtrl.getInfoName("ccNameBox").text(value.CostCenterName);
				var cdField = accountCtrl.getInfoStr("[name=searchParam][tag=CostCenterCode]").val(value.CostCenterCode);
			},
			
			cptSped_accDelete : function() {
				var me = this
				var labelField = accountCtrl.getInfoName("accNameBox").text("");
				var cdField = accountCtrl.getInfoStr("[name=searchParam][tag=AccountCode]").val("");
			},
			cptSped_accSearch : function() {
				var me = this;
				var popupID		=	"accountSearchPopup";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_account'/>";	//계정과목
				var popupName	=	"AccountSearchPopup";
				var callBack	=	"cptSped_accSearchComp";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	me.pageOpenerIDStr
								+	"callBackFunc="	+	callBack;
				Common.open(	"",popupID,popupTit,url,"740px","690px","iframe",true,null,null,true);
				
			},
			cptSped_accSearchComp : function(value) {
				var me = this
				var labelField = accountCtrl.getInfoName("accNameBox").text(value.AccountName);
				var cdField = accountCtrl.getInfoStr("[name=searchParam][tag=AccountCode]").val(value.AccountCode);
			},
			
			cptSped_ioDelete : function() {
				var me = this
				var labelField = accountCtrl.getInfoName("ioNameBox").text("");
				var cdField = accountCtrl.getInfoStr("[name=searchParam][tag=IOCode]").val("");
			},
			cptSped_ioSearch : function() {
				var me = this;
				var popupID		=	"ioSearchPopup";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_projectName' />";
				var popupName	=	"BaseCodeSearchPopup";
				var callBack	=	"cptSped_ioSearchComp";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	me.pageOpenerIDStr
								+	"codeGroup=IOCode&"
								+	"callBackFunc="	+	callBack;
				
				Common.open(	"",popupID,popupTit,url,"600px","650px","iframe",true,null,null,true);
				
			},
			cptSped_ioSearchComp : function(value) {
				var me = this
				var labelField = accountCtrl.getInfoName("ioNameBox").text(value.CodeName);
				var cdField = accountCtrl.getInfoStr("[name=searchParam][tag=IOCode]").val(value.Code);
			},
			
			cptSped_sbDelete : function() {
				var me = this
				var labelField = accountCtrl.getInfoName("sbNameBox").text("");
				var cdField = accountCtrl.getInfoStr("[name=searchParam][tag=StandardBriefID]").val("");
			},
			cptSped_sbSearch : function() {
				var me = this;
				var popupID		=	"standardBriefSearchPopup";
				var popupTit	=	"<spring:message code='Cache.ACC_standardBrief'/>";	//표준적요
				var popupName	=	"StandardBriefSearchPopup";
				var callBack	=	"cptSped_sbSearchComp";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	me.pageOpenerIDStr
								+	"callBackFunc="	+	callBack;
				Common.open(	"",popupID,popupTit,url,"1000px","700px","iframe",true,null,null,true);
				
			},
			cptSped_sbSearchComp : function(value) {
				var me = this
				var labelField = accountCtrl.getInfoName("sbNameBox").text(value.StandardBriefName);
				var cdField = accountCtrl.getInfoStr("[name=searchParam][tag=StandardBriefID]").val(value.StandardBriefID);
			},
			
			cptSped_searchAmtSet : function(obj) {
				var me = this;
				var val = obj.value;
				var numVal = isNaN(AmttoNumFormat(val))
				if(numVal == true
						|| isEmptyStr(val)){
					obj.value=("");
					return;
				}
				numVal = ckNaN(AmttoNumFormat(val))
				
				var targetField = obj.getAttribute("targetfield");
				var targetVal = accountCtrl.getInfoStr("[name=searchParam][tag="+targetField+"]").val();
				var numTargetVal = isNaN(AmttoNumFormat(targetVal));
				if(numTargetVal == true
						|| isEmptyStr(targetVal)){
					obj.value = toAmtFormat(numVal);
					return;
				}
				numTargetVal = ckNaN(AmttoNumFormat(targetVal));
				
				if(targetField == "SearchAmtEd"
						&& (numVal>numTargetVal)){
					obj.value = toAmtFormat(numTargetVal);
				}
				else if(targetField == "SearchAmtSt"
						&& (numVal<numTargetVal)){
					obj.value = toAmtFormat(numTargetVal);
				}else{
					obj.value = toAmtFormat(numVal);
				}
			},
			
			cptSped_OpenCapitalSpendingForm : function(formType, openMode) { //formType(RES: 결의서, REP: 보고서) / openMode(A: 전체, I: 개별)
				var me = this;
				var checkedObj = me.gridPanel.getCheckedList(0);
				
				var strFormPrefix = "WF_FORM_EACCOUNT_CAPITAL_" + formType;
				var expAppListIDs = "";
				var realPayDate = accountCtrl.getInfo("cptSped_dateAreaRealPayDate").val().replace(/\./gi, '');
				var standardBriefID = accountCtrl.getInfoStr("[name=searchParam][tag=StandardBriefID]").val();
				var companyCode = accountCtrl.getInfoStr("[name=searchParam][tag=companyCode]").val();
				
				if(openMode == "A") {
					if(realPayDate == "") {
						Common.Warning("<spring:message code='Cache.ACC_msg_selectRealPayDate' />"); //검색조건의 자금집행일을 선택해주세요.
						return;
					}
				} else if(openMode == "I") {
					if(checkedObj.length == 0){
						Common.Inform("<spring:message code='Cache.ACC_msg_noselectdata'/>");	//선택된 항목이 없습니다.
						return;
					} else {
						for(var i = 0; i < checkedObj.length; i++) {
							expAppListIDs += checkedObj[i].ExpenceApplicationListID + ",";
						}
						expAppListIDs = expAppListIDs.slice(0,-1);
					}
				}				
				CFN_OpenWindow("/approval/approval_Form.do?mode=DRAFT&formPrefix="+strFormPrefix
								+"&openMode="+openMode+"&realPayDate="+realPayDate+"&standardBriefID="+standardBriefID+"&companyCode="+companyCode+"&expAppListIDs="+expAppListIDs, "", 1080, (window.screen.height - 100), "both");
			},
			
			cptSped_updateCapitalStatus : function(status) {
				var me = this;
				var checkedObj = me.gridPanel.getCheckedList(0);
				var expAppListIDs = "";
				
				if(checkedObj.length == 0) {
					Common.Inform("<spring:message code='Cache.ACC_msg_noselectdata'/>");	//선택된 항목이 없습니다.
					return;
				} else {
					for(var i = 0; i < checkedObj.length; i++) {
						if(status == "H" && checkedObj[i].CapitalStatus != "W") {
							Common.Inform("<spring:message code='Cache.ACC_msg_capitalStatusError'/>");		//상태가 [대기]인 항목만 보류 처리가 가능합니다.							
							return false;
						} else if(status == "W" && checkedObj[i].CapitalStatus != "H") {
							Common.Inform("<spring:message code='Cache.ACC_msg_capitalStatusError2'/>");	//상태가 [보류]인 항목만 보류취소 처리가 가능합니다.							
							return false;
						}
						expAppListIDs += checkedObj[i].ExpenceApplicationListID + ",";
					}
					expAppListIDs = expAppListIDs.slice(0,-1);
				}
				
				$.ajax({
					type:"POST",
					url:"/account/expenceApplication/updateCapitalStatus.do",
					data:{
						"expAppListIDs"	: expAppListIDs,
						"CapitalStatus"	: status
					},
					success:function (data) {
						if(data.status == "SUCCESS"){
							Common.Inform("<spring:message code='Cache.ACC_msg_processComplet'/>");	//처리를 완료하였습니다.
							me.cptSped_searchCapitalSpendingList();
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
					}
				});
			},
			
			cptSped_openEditPopup : function() {
				var me = this;
				var checkedObj = me.gridPanel.getCheckedList(0);
				
				if(checkedObj.length == 0) {
					Common.Inform("<spring:message code='Cache.ACC_msg_noselectdata'/>");	//선택된 항목이 없습니다.
					return;
				} else {
					if(checkedObj[0].CapitalStatus != "W" && checkedObj[0].CapitalStatus != "H") {
						Common.Inform("<spring:message code='Cache.ACC_msg_capitalStatusErrorEdit'/>");	//상태가 [보류/대기]인 항목만 편집이 가능합니다.	
						return;
					}
				}
				
				var expAppListID = checkedObj[0].ExpenceApplicationListID;
				if(checkedObj.length > 1) {
					var chkIds = [];
					for(var i = 0; i < checkedObj.length; i++){
						chkIds.push(checkedObj[i].ExpenceApplicationListID);
					}
					expAppListID = chkIds.join(",");
				}
				
				var isNew		= "Y";
				var popupID		= "capitalEditPopup";
				var openerID	= "CapitalSpendingStatus";
				var popupTit	= "<spring:message code='Cache.ACC_lbl_editEvid'/>";	//증빙수정
				var popupYN		= "N";
				var callBack	= "cptSped_CallBack";
				var popupUrl	= "/account/expenceApplication/callCapitalEditPopup.do?"
								+ "popupID="		+ popupID	+ "&"
								+ "openerID="		+ openerID	+ "&"
								+ "popupYN="		+ popupYN	+ "&"
								+ "callBackFunc="	+ callBack	+ "&"
								+ "expAppListID="	+ encodeURIComponent(nullToBlank(expAppListID))
				
				Common.open("", popupID, popupTit, popupUrl, "420px", "200px", "iframe", true, null, null, true);
			},

			cptSped_CallBack : function(){
				var me = this;
				me.cptSped_searchCapitalSpendingList();
			},
			
			cptSped_openCapitalSpendingDoc : function(strProcessID, strStatus, strFormInstID) {
				if(strProcessID != "") {
					var strMode = "PROCESS";
					if(strStatus == "E") {
						strMode = "COMPLETE";
					}
					CFN_OpenWindow('/approval/approval_Form.do?mode='+strMode+'&processID='+strProcessID+'&forminstanceID='+strFormInstID,'',1070, (window.screen.height - 100), 'scroll');
				}
			},
			
			onenter : function(){
				var me = this;
				if(event.keyCode=="13"){
					me.cptSped_searchCapitalSpendingList();
				}
			}
	}
	window.CapitalSpendingStatus = CapitalSpendingStatus;
})(window);

	
</script>