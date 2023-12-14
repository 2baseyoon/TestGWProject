<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.coviframework.util.RedisDataUtil" %>
<%@ page import="egovframework.coviaccount.common.util.AccountUtil" %>
<%
	AccountUtil accountUtil = new AccountUtil();
	String propertyAprv = accountUtil.getBaseCodeInfo("eAccApproveType", "ExpenceApplication");
	String propertyOtherApv = RedisDataUtil.getBaseConfig("eAccOtherApv");
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>

<script type="text/javascript" src="/account/resources/script/user/expAppCommon.js<%=resourceVersion%>"></script>
<style>
.pad10 { padding:10px;}
.AXgridScrollBody, .AXGridBody { overflow : visible !important; }
div:has(> .btnFlowerName) { overflow : visible !important; }
</style>
	<!-- 상단 끝 -->
	<div class="cRConTop titType">
		<h2 id="headerTitle" class="title"></h2>
	</div>
	<div class='cRContBottom mScrollVH'>
		<!-- 컨텐츠 시작 -->
		<div class="eaccountingCont">
			<!-- 상단 버튼 시작 -->
			<div class="eaccountingTopCont">
				<div class="pagingType02 buttonStyleBoxLeft">
					<!-- 삭제 -->
					<a class="btnTypeDefault" href="#" onclick="ExpenceApplicationManageUser.expAppManUser_applicationDelete();"><spring:message code="Cache.ACC_btn_delete"/></a>
					<!-- 새로고침 -->
					<a class="btnTypeDefault" href="#" onclick="accountCtrl.pageRefresh();"><spring:message code="Cache.ACC_btn_refresh"/></a>
					<!-- 엑셀저장 -->
					<a class="btnTypeDefault btnExcel" href="#" onclick="ExpenceApplicationManageUser.expAppManUser_excelDownload();"><spring:message code="Cache.ACC_btn_excelDownload"/></a>
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
							<span id="expAppManUser_CompanyCode" class="selectType02" name="searchParam" tag="CompanyCode" onchange="ExpenceApplicationManageUser.changeCompanyCode()">
							</span>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_aprvWriter"/></span>
							<input type="text" name="searchParam" tag="RegisterNm"
								onkeydown="ExpenceApplicationManageUser.onenter()">
						</div>
						<div class="inPerTitbox">
							<!-- 금액 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_amt"/></span>
							<div class="dateSel type02" >
								<input type="text" name="searchParam" tag="SearchAmtSt" style="width:100px; ime-mode:disabled; text-align: right;" fieldtype="Amt"
									targetfield="SearchAmtEd"
									onkeydown="ExpenceApplicationManageUser.onCkNum(this)"
									onkeyup="ExpenceApplicationManageUser.onSetNum(this);"
									onblur="ExpenceApplicationManageUser.expAppManUser_searchAmtSet(this);"> 
								~ 
								<input type="text" name="searchParam" tag="SearchAmtEd" style="width:100px; ime-mode:disabled; text-align: right;"  fieldtype="Amt"
									targetfield="SearchAmtSt"
									onkeydown="ExpenceApplicationManageUser.onCkNum(this)"
									onkeyup="ExpenceApplicationManageUser.onSetNum(this);"
									onblur="ExpenceApplicationManageUser.expAppManUser_searchAmtSet(this);"> 
							</div>
						</div>
					</div>		
					<div style="width:830px;">
						<div class="inPerTitbox">
							<!-- 제목 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_title"/></span>
							<input type="text" name="searchParam" tag="ApplicationTitle"
								onkeydown="ExpenceApplicationManageUser.onenter()">
						</div>
						<div class="inPerTitbox">
							<!-- 처리상태 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_processStatus"/></span>
							<span id="expAppManUser_ApplicationStatus" class="selectType02" name="searchParam" tag="ApplicationStatus">
							</span>
						</div>
						<div class="inPerTitbox">
							<!-- 증빙일자 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_proofDate"/></span>
							<div id="expAppManUser_dateArea" class="dateSel type02" name="searchParam" fieldtype="Date"
								stfield="expAppManUser_dateArea_St" edfield="expAppManUser_dateArea_Ed" 
								stdatafield="ProofDateSt" eddatafield="ProofDateEd"
							></div>	
							<!-- 
								<div id="expAppManUser_dateArea_Ed" class="dateSel type02" name="searchParam" tag="ProofDateEd"></div>
							-->								
						</div>
					</div>	
					<div style="width:830px;" name="divSearchArea">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<!-- 코스트센터 -->
								<spring:message code='Cache.ACC_lbl_costCenter'/>
							</span>
							<div class="name_box_wrap">
								<span class="name_box" name="ccNameBox" ></span>
								<a class="btn_del03" onclick="ExpenceApplicationManageUser.expAppManUser_ccDelete()"></a>
							</div>
							<a class="btn_search03" onclick="ExpenceApplicationManageUser.expAppManUser_ccSearch()"></a>
							<input  type="text" hidden name="searchParam" tag="CostCenterCode"
								onkeydown="ExpenceApplicationManageUser.onenter()" >
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<!-- 계정과목 -->
								<spring:message code='Cache.ACC_lbl_account'/>
							</span>
							<div class="name_box_wrap">
								<span class="name_box" name="accNameBox" ></span>
								<a class="btn_del03" onclick="ExpenceApplicationManageUser.expAppManUser_accDelete()"></a>
							</div>
							<a class="btn_search03" onclick="ExpenceApplicationManageUser.expAppManUser_accSearch()"></a>
							<input  type="text" hidden name="searchParam" tag="AccountCode"
								onkeydown="ExpenceApplicationManageUser.onenter()" >
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<spring:message code='Cache.ACC_lbl_projectName'/>
							</span>
							<div class="name_box_wrap">
								<span class="name_box" name="ioNameBox" ></span>
								<a class="btn_del03" onclick="ExpenceApplicationManageUser.expAppManUser_ioDelete()"></a>
							</div>
							<a class="btn_search03" onclick="ExpenceApplicationManageUser.expAppManUser_ioSearch()"></a>
							<input  type="text" hidden name="searchParam" tag="IOCode"
								onkeydown="ExpenceApplicationManageUser.onenter()" >						
						</div>
					</div>	
					<div style="width:830px;">
						<%-- <div class="inPerTitbox">
							<!-- 전표번호 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_docNo"/></span>
							<input type="text" name="searchParam" tag="DocNo"
								onkeydown="ExpenceApplicationManageUser.onenter()">
						</div> --%>
						<%-- <div class="inPerTitbox">
							<!-- 담당업무 - 회계팀 커스텀 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_chargeJob"/></span>
							<span id="expAppManUser_ChargeJob" class="selectType02" name="searchParam" tag="ChargeJob">
							</span>
						</div> --%>
						<div class="inPerTitbox">
							<!-- 신청유형 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_requestType"/></span>
							<span id="expAppManUser_RequestType" class="selectType02" name="searchParam" tag="RequestType">
							</span>
						</div>
						<div class="inPerTitbox">
							<!-- 증빙종류 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_proofClass"/></span>
							<span id="expAppManUser_ProofCode" class="selectType02" name="searchParam" tag="ProofCode">
							</span>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<!-- 기안일 -->
								<spring:message code='Cache.ACC_lbl_aprvDate'/>
							</span>
							<div id="expAppManUser_applicationDateArea" class="dateSel type02" name="searchParam" fieldtype="Date"
								stfield="expAppManUser_applicationDateArea_St" edfield="expAppManUser_applicationDateArea_Ed" 
								stdatafield="ApplicationDateSt" eddatafield="ApplicationDateEd"
							></div>	
						</div>
					</div>
					<div style="width:980px;">
						<div class="inPerTitbox">
							<!-- 거래처명 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_vendorName"/></span>
							<input type="text" name="searchParam" tag="VendorName"
								onkeydown="ExpenceApplicationManageUser.onenter()">
						</div>
						<div class="inPerTitbox" name="divListSearchArea">
							<!-- 표준적요 -->
							<span class="bodysearch_tit"><spring:message code='Cache.ACC_standardBrief'/></span>
							<div class="name_box_wrap">
								<span class="name_box" name="sbNameBox" ></span>
								<a class="btn_del03" onclick="ExpenceApplicationManageUser.expAppManUser_sbDelete()"></a>
							</div>
							<a class="btn_search03" onclick="ExpenceApplicationManageUser.expAppManUser_sbSearch()"></a>
							<input  type="text" hidden name="searchParam" tag="StandardBriefID"
								onkeydown="ExpenceApplicationManageUser.onenter()" >
						</div>
						<div class="inPerTitbox" name="divListSearchArea">
							<!-- 지급일자 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_payDay"/></span>
							<div id="expAppManUser_dateAreaPayDate" class="dateSel type02" name="searchParam" tag="PayDate" fieldtype="Date">
							</div>
						</div>
						<a href="#" class="btnTypeDefault btnSearchBlue" onclick="ExpenceApplicationManageUser.expAppManUser_searchExpenceApplicationList()"><spring:message code="Cache.ACC_btn_search"/></a>
					</div>						
				</div>
			</div>
			<!-- 검색영역 끝 -->
			<div class="inPerTitbox">
				<!-- 구분 -->
				<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_division"/></span>
				<span class="selectType02"	id="expAppManSearchType" name="searchParam" tag="SearchType"
				onchange="ExpenceApplicationManageUser.expAppManUser_searchExpenceApplicationList()">
				</span>
				
				<div class="buttonStyleBoxRight ">	
					<span class="selectType02 listCount" id="expAppManListCount" onchange="ExpenceApplicationManageUser.expAppManUser_searchExpenceApplicationList();">
						<!-- 
						<option>10</option>
						<option>20</option>
						<option>30</option>
						-->
					</span>
					<button class="btnRefresh" type="button" onclick="ExpenceApplicationManageUser.expAppManUser_searchExpenceApplicationList();"></button>
				</div>
			</div>
			<!-- ===================== -->
			<div id="Grid" class="pad10">
				<div id="ExpAppManListGrid"></div>
			</div>
			
			<div name="hiddenLinkArea" ></div>
		</div>
		<!-- 컨텐츠 끝 -->
	</div>

<script>

if (!window.ExpenceApplicationManageUser) {
	window.ExpenceApplicationManageUser = {};
}

(function(window) {

	var propertyOtherApv = "<%=propertyOtherApv%>";
	
	var ExpenceApplicationManageUser = {
			
			gridPanel : new coviGrid(),
			gridHeaderData : [],
			searchedType : "",
			setGridHead : [],
			auditInfo : {},

			pageInit : function(inputParam) {
				var me = this;
				
				setHeaderTitle('headerTitle');

				me.gridHeaderDataList = expAppCommon.getGridHeader("appUser");
			
				var today = new Date();
				var gy = today.getFullYear();
				var gm = today.getMonth();
				var gd = today.getDate();
				makeDatepicker('expAppManUser_dateArea', 'expAppManUser_dateArea_St', 'expAppManUser_dateArea_Ed', null, null, 100);
				makeDatepicker('expAppManUser_dateAreaPayDate', 'expAppManUser_dateAreaPayDate', null, null, null, 220);
				
				var appstdt = null;
				var appeddt = null;
				if(inputParam != null){
					if(inputParam.callType=="Portal"){
						/* var nowDate = new Date();
						var firstDate = new Date(nowDate.getFullYear(), nowDate.getMonth(), 1);
						var lastDate = new Date(nowDate.getFullYear(), nowDate.getMonth()+1, 0);
						appstdt = firstDate.format("yyyyMMdd");
						appeddt = lastDate.format("yyyyMMdd"); */
					}
				}
				
				makeDatepicker('expAppManUser_applicationDateArea', 'expAppManUser_applicationDateArea_St', 'expAppManUser_applicationDateArea_Ed', appstdt, appeddt, 100);

				me.expAppManUser_comboInit();
				me.expAppManUser_getAuditInfo();
				me.expAppManUser_gridInit()
			},
			pageView : function(inputParam) {
				var me = this;
				me.expAppManUser_comboRefresh();

				if(inputParam != null){
					if(inputParam.callType=="Portal"){
						/* var nowDate = new Date();
						var firstDate = new Date(nowDate.getFullYear(), nowDate.getMonth(), 1);
						var lastDate = new Date(nowDate.getFullYear(), nowDate.getMonth()+1, 0);
						accountCtrl.getInfo("expAppManUser_applicationDateArea_St").val(firstDate.format("yyyy.MM.dd"));
						accountCtrl.getInfo("expAppManUser_applicationDateArea_Ed").val(lastDate.format("yyyy.MM.dd")); */
					}
				}
				
				me.expAppManUser_searchExpenceApplicationList();
			},


			expAppManUser_comboInit : function(pCompanyCode) {
				accountCtrl.getInfo("expAppManListCount").children().remove();
				accountCtrl.getInfo("expAppManSearchType").children().remove();
				accountCtrl.getInfo("expAppManUser_ProofCode").children().remove();
				accountCtrl.getInfo("expAppManUser_ApplicationStatus").children().remove();
				accountCtrl.getInfo("expAppManUser_RequestType").children().remove();

				accountCtrl.getInfo("expAppManListCount").addClass("selectType02").addClass("listCount").attr("onchange", "ExpenceApplicationManageUser.expAppManUser_searchExpenceApplicationList();");
				accountCtrl.getInfo("expAppManSearchType").addClass("selectType02").attr("name", "searchParam").attr("tag", "SearchType").attr("onchange", "ExpenceApplicationManageUser.expAppManUser_searchExpenceApplicationList()");
				accountCtrl.getInfo("expAppManUser_ProofCode").addClass("selectType02").attr("name", "searchParam").attr("tag", "ProofCode");
				accountCtrl.getInfo("expAppManUser_ApplicationStatus").addClass("selectType02").attr("name", "searchParam").attr("tag", "ApplicationStatus");
				accountCtrl.getInfo("expAppManUser_RequestType").addClass("selectType02").attr("name", "searchParam").attr("tag", "RequestType");
				
				// 로딩속도 개선
				var __AXSelectMultiArr = [
					{
						"codeGroup":"listCountNum"
						,"target":"expAppManListCount"
						,"lang":"ko"
						,"onchange":""
						,"oncomplete":""
						,"defaultVal":""
						,"useDefault":null
					},
					{
						"codeGroup":"ExpAppSearchType"
						,"target":"expAppManSearchType"
						,"lang":"ko"
						,"onchange":""
						,"oncomplete":""
						,"defaultVal":""
						,"useDefault":null
					},
					{
						"codeGroup":"ProofCode"
						,"target":"expAppManUser_ProofCode"
						,"lang":"ko"
						,"onchange":""
						,"oncomplete":""
						,"defaultVal":""
						,"useDefault":"<spring:message code='Cache.ACC_lbl_comboAll' />"
					},
					{
						"codeGroup":"ExpenceApplicationStatus"
						,"target":"expAppManUser_ApplicationStatus"
						,"lang":"ko"
						,"onchange":""
						,"oncomplete":""
						,"defaultVal":""
						,"useDefault":"<spring:message code='Cache.ACC_lbl_comboAll' />"
					},
					{
						"codeGroup":"FormManage_RequestType"
						,"target":"expAppManUser_RequestType"
						,"lang":"ko"
						,"onchange":""
						,"oncomplete":""
						,"defaultVal":""
						,"useDefault":"<spring:message code='Cache.ACC_lbl_comboAll' />"
					}
				];
				accountCtrl.renderAXSelectMulti(__AXSelectMultiArr, pCompanyCode);
				
				if(pCompanyCode == undefined) {
					accountCtrl.renderAXSelect('CompanyCode',			'expAppManUser_CompanyCode',		'ko','','','',null,pCompanyCode);	
				}
			},

			expAppManUser_comboRefresh : function(defaultVal) {
				var me = this;
				accountCtrl.refreshAXSelect('expAppManUser_ProofCode');
				accountCtrl.refreshAXSelect('expAppManUser_ApplicationStatus');
				accountCtrl.refreshAXSelect('expAppManUser_RequestType');
				accountCtrl.refreshAXSelect('expAppManUser_CompanyCode');
			},
			
			changeCompanyCode : function() {
				var me = this;
				me.expAppManUser_comboInit(accountCtrl.getComboInfo("expAppManUser_CompanyCode").val());
			},

			expAppManUser_getAuditInfo : function(defaultVal) {
				var me = this;

				$.ajax({
					type:"POST",
					url:"/account/audit/getAuditList.do",
					data:{
					},
					success:function (data) {
						if(data.status == "SUCCESS"){
							var list = data.list;
							for(var i = 0; i<list.length; i++){
								var item = list[i]
								me.auditInfo[item.RuleCode] = item;
							}
						}
						else{
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
					}
				});
			},
			expAppManUser_gridInit : function() {
				var me = this;
				
				me.expAppManUser_searchExpenceApplicationList();
			},


			expAppManUser_gridHeaderInit : function() {
				var me = this;
				var getHead = [];
				var searchType = accountCtrl.getInfoStr("[name=searchParam][tag=SearchType]").val();

				getHead = expAppCommon.getGridHeader(searchType+"User");
				
				if(searchType=="app" && propertyOtherApv!="Y") {
					getHead[getHead.length-1].display = false;
				}
				
				me.setGridHead = getHead;
				accountCtrl.setViewPageGridHeader(getHead, me.gridPanel);
				
				if(searchType=="div"){
					accountCtrl.getInfoName("divSearchArea").css("display", "");
					accountCtrl.getInfoName("divListSearchArea").css("display", "");					
					accountCtrl.getInfoStr("[tag=VendorName]").parent().css("margin-right", "24px");
					
					if(Common.getBaseConfig("IsUseIO") == "N") {
						accountCtrl.getInfoStr("[name=searchParam][tag=IOCode]").parent().css("display", "none");
					}
				}else{
					accountCtrl.getInfoName("divSearchArea").css("display", "none");
					accountCtrl.getInfoName("divSearchArea").find("[name=searchParam]").val("");
					accountCtrl.getInfoName("divSearchArea").find(".name_box").text("");
					
					if(searchType=="list") {
						accountCtrl.getInfoName("divListSearchArea").css("display", "");
						accountCtrl.getInfoStr("[tag=VendorName]").parent().css("margin-right", "24px");
					} else {
						accountCtrl.getInfoName("divListSearchArea").css("display", "none");
						accountCtrl.getInfoStr("[tag=VendorName]").parent().css("margin-right", "44px");
					}
					me.expAppManUser_ccDelete();
					me.expAppManUser_accDelete();
					me.expAppManUser_ioDelete();
				}
				
			},

			expAppManUser_getSearchParams : function() {
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
									var dateVal = accountCtrl.getInfo("expAppManUser_dateAreaPayDate").val();
									dateVal = dateVal.replaceAll(".", "");
									retVal[item.getAttribute("tag")] = dateVal;										
								} else {
									var stField = item.getAttribute("stfield")
									var edField = item.getAttribute("edfield")
									
									var stDataField = item.getAttribute("stdatafield")
									var edDataField = item.getAttribute("eddatafield")
									
									var stVal = accountCtrl.getInfo(stField).val()
									var edVal = accountCtrl.getInfo(edField).val()
									
									if(stDataField == "ApplicationDateSt" && edDataField == "ApplicationDateEd" ){
										//TimeZone작업으로 변경
									}else{
										stVal = stVal.replaceAll(".", "");
										edVal = edVal.replaceAll(".", "");
									}										
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
								if(item.getAttribute("tag") == "CompanyCode") {
									retVal["CompanyName"] = $(item).find("option:selected").text();
								}
							}
						}
					}
				}
				return retVal;
			},
			expAppManUser_searchExpenceApplicationList : function(YN) {
				var me = this;
				var searchParam = me.expAppManUser_getSearchParams();

				me.expAppManUser_getAuditInfo();
				me.expAppManUser_gridHeaderInit();
				
				var pageSize	= accountCtrl.getComboInfo("expAppManListCount").val();
				
				var gridAreaID		= "ExpAppManListGrid";
				var gridPanel		= me.gridPanel;
				//var gridHeader		= me.gridHeaderData;
				var gridHeader		= me.setGridHead;
				var ajaxUrl			= "/account/expenceApplication/searchExpenceApplicationUserList.do";
				var ajaxPars		= {
											"searchParam" : JSON.stringify(searchParam)
											, "pageSize":pageSize,
										}
				
				var pageSizeInfo	= accountCtrl.getComboInfo("expAppManListCount").val();
				var pageNoInfo		= accountCtrl.getGridViewPageNum(YN,gridPanel,pageSizeInfo);
				
				var gridParams = {	"gridAreaID"	: gridAreaID
								,	"gridPanel"		: gridPanel
								,	"gridHeader"	: gridHeader
								,	"ajaxUrl"		: ajaxUrl
								,	"ajaxPars"		: ajaxPars
								,	"pageNoInfo"	: pageNoInfo
								,	"pageSizeInfo"	: pageSizeInfo
								,	"popupYN"		: "N"
								, 	"callback"		: me.expAppManUser_searchCallback
								,	"fitToWidth"	: false
				}
				
				accountCtrl.setViewPageBindGrid(gridParams);
			},

			expAppManUser_searchCallback : function() {
				var me = window.ExpenceApplicationManageUser;
				var searchedType = accountCtrl.getInfoStr("[name=searchParam][tag=SearchType]").val();
				me.searchedType = searchedType;
			},
			expAppManUser_viewEvidPopup : function(getId, ProcessID) {
				var me = this;
				//전표조회
				
				//Common.open("","expenceApplicationViewPopup"+getId,"<spring:message code='Cache.ACC_lbl_expenceApplicationView'/>", "/account/expenceApplication/ExpenceApplicationViewPopup.do?isUser=Y&ExpAppID="+getId+"&processID="+ProcessID,"1000px","800px","iframe",true,"450px","100px",true);
				CFN_OpenWindow("/account/expenceApplication/ExpenceApplicationViewPopup.do?isUser=Y&processID="+ProcessID+"&ExpAppID="+getId, "", 1070, (window.screen.height - 100), "both");
			},
			expAppManUser_evidWritePage : function(getId, type, requestType) {
				var me = this;
				
				var setParam = {
						isSearch : 'Y'
						, ExpAppId : getId
						, name : 'search'
				}
								
				//통합비용신청
				if(type=="CO"){
					eAccountContentHtmlChangeAjax('account_CombineCostApplicationaccountuserAccount'+requestType
							, $("#account_CombineCostApplicationaccountuserAccount"+requestType).text()
							, '/account/layout/account_CombineCostApplication.do?CLSYS=account&CLMD=user&CLBIZ=Account&requesttype='+requestType
							, setParam);
				}else if(type=="SC"){
				//간편신청
					eAccountContentHtmlChangeAjax('account_SimpleApplicationaccountuserAccount'+requestType
							, $("#account_SimpleApplicationaccountuserAccount"+requestType).text()
							, '/account/layout/account_SimpleApplication.do?CLSYS=account&CLMD=user&CLBIZ=Account&requesttype='+requestType
							, setParam);
				}
			},
			

			expAppManUser_expAppManViewFile : function(getId) {
				var me = this;
				//첨부파일
				Common.open("","expAppManViewFile","<spring:message code='Cache.ACC_lbl_addFile'/>",
					"/account/expenceApplication/ExpenceApplicationViewFilePopup.do?ExpAppListID="+getId,"350px","400px","iframe",true,null,null,true);
			},
			expAppManUser_LinkOpen : function(stat, ProcessId){
				var me = this;
				if(ProcessId != null){
					/* var mode = "PROCESS"
					if(stat=="E"){
						mode = "COMPLETE"
					}
					var FormUrl = document.location.protocol + "//" + document.location.host + "/approval/approval_Form.do";
					CFN_OpenWindow(FormUrl + '?mode='+mode+'&processID='+ProcessId,'',1070, 998, 'scroll'); */
					
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
			expAppManUser_viewEvidListItem : function(ProofCode, LinkKey) {
				var me = this;
				//정보를 조회할 수 없습니다. 관리자에게 문의해 주세요.
				if(isEmptyStr(LinkKey)){
					Common.Inform("<spring:message code='Cache.ACC_047'/>");
					return;
				}
				
				if(ProofCode=="CorpCard"){
					accComm.accCardAppClick(LinkKey, me.pageOpenerIDStr);
				}
				else if(ProofCode=="TaxBill"){
					accComm.accTaxBillAppClick(LinkKey, me.pageOpenerIDStr);
				}
				else if(ProofCode=="Receipt"){
					accComm.accMobileReceiptAppClick(LinkKey, me.pageOpenerIDStr);
				}
			},
			
			expAppManUser_applicationDelete : function(){
				var me = this;
				
				if(me.searchedType == "app" || me.searchedType == "list") {
					var deleteobj	= me.gridPanel.getCheckedList(0);
					
					if(deleteobj.length == 0){
						Common.Inform("<spring:message code='Cache.ACC_msg_noselectdata'/>");	//선택된 항목이 없습니다.
						return;
					}
					
					if(me.searchedType == "list") { //임시저장만
						var statCk = false;
						for(var i = 0; i < deleteobj.length; i++){
							var item = deleteobj[i];
							if(item.ApplicationStatus != "T"){
								statCk = true;
							}
						}
						
						if(statCk){
							Common.Inform("<spring:message code='Cache.ACC_021'/>");	//임시저장 상태인 항목만 삭제할 수 있습니다.
							return;
						}
					} else if(me.searchedType == "app") { //임시저장, 반려만
						var statCk = false;
						for(var i = 0; i < deleteobj.length; i++){
							var item = deleteobj[i];
							if(item.ApplicationStatus != "T" && item.ApplicationStatus != 'R'){
								statCk = true;
							}
						}
						
						if(statCk){
							Common.Inform("<spring:message code='Cache.ACC_msg_deleteOnlyTempSaveReject'/>");	//임시저장, 반려 상태인 항목만 삭제할 수 있습니다.
							return;
						}
					}
					
			        Common.Confirm("<spring:message code='Cache.ACC_msg_ckDelete' />", "Confirmation Dialog", function(result){	//삭제하시겠습니까?
			       		if(result){
			       			me.expAppManUser_callDeleteAjax(deleteobj)
			       		}
			        });
				} else {
					Common.Inform("<spring:message code='Cache.ACC_020'/>");	//세부증빙별 조회 시 삭제가 불가능합니다.
					return;
				}
			},
			
			expAppManUser_callDeleteAjax : function(deletedList){
				var deleteObj = {};
				deleteObj.deleteList = deletedList;
				
				var me = this;
				$.ajax({
					type:"POST",
					url:"/account/expenceApplication/deleteExpenceApplicationManList.do",
					data:{
						"deleteObj"	: JSON.stringify(deleteObj),
						"deleteType" : me.searchedType
					},
					success:function (data) {
						if(data.result == "ok"){
							if(data.WorkItemArchiveIDs != undefined && data.WorkItemArchiveIDs != "") {
								setDeleteMarkingRejectList(data.WorkItemArchiveIDs);
							}
							Common.Inform("<spring:message code='Cache.ACC_msg_delComp'/>");	//삭제를 완료하였습니다.
							me.expAppManUser_searchExpenceApplicationList();
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
					}
				});
			},

			expAppManUser_excelDownload : function(){
				var me = this;
				Common.Confirm("<spring:message code='Cache.ACC_msg_excelDownMessage'/>", "<spring:message code='Cache.ACC_btn_save' />", function(result){
			  		if(result){
			  			var headerName		= accountCommon.getHeaderNameForExcel(me.setGridHead);
						var headerKey		= accountCommon.getHeaderKeyForExcel(me.setGridHead);

						var searchParams	= me.expAppManUser_getSearchParams();
						
						var applicationStatus = searchParams.ApplicationStatus;
						var registerNm = searchParams.RegisterNm;
						var companyCode = accountCtrl.getComboInfo("expAppManUser_CompanyCode").val();
						var companyName	= searchParams.CompanyName;
						var applicationTitle = searchParams.ApplicationTitle;
						//var chargeJob = searchParams.ChargeJob;
						var requestType = searchParams.RequestType;
						var docNo = searchParams.DocNo;
						var proofCode = searchParams.ProofCode;
						var vendorName = searchParams.VendorName;
						var costCenterCode = searchParams.CostCenterCode;
						var accountCode = searchParams.AccountCode;
						var IOCode = searchParams.IOCode;
						var standardBriefID = searchParams.StandardBriefID;
						var payDate = searchParams.PayDate;
						var expAppManUser_dateArea_St = searchParams.ProofDateSt;
						var expAppManUser_dateArea_Ed = searchParams.ProofDateEd;
						var expAppManUser_applicationDateArea_St = searchParams.ApplicationDateSt;
						var expAppManUser_applicationDateArea_Ed = searchParams.ApplicationDateEd;

						var headerType		= accountCommon.getHeaderTypeForExcel(me.setGridHead);
						var title 			= accountCtrl.getInfo("headerTitle").text();

						var	locationStr		= "/account/expenceApplication/excelDownloadExpenceApplicationUserList.do?"
											//+ "headerName="		+ encodeURI(nullToBlank(headerName))
											+ "headerName="		+ encodeURIComponent(encodeURIComponent(headerName))
											+ "&headerKey="		+ encodeURI(nullToBlank(headerKey))
											+ "&searchType="	+ encodeURI(nullToBlank(accountCtrl.getInfoStr("[name=searchParam][tag=SearchType]").val()))
											+ "&applicationStatus="	+ encodeURI(nullToBlank(applicationStatus))
											+ "&registerNm="		+ encodeURI(nullToBlank(registerNm))
											+ "&companyCode=" + encodeURI(nullToBlank(companyCode))
											+ "&companyName="	+ encodeURI(nullToBlank(companyName))
											+ "&applicationTitle="	+ encodeURI(nullToBlank(applicationTitle))
											//+ "&chargeJob="	+ encodeURI(nullToBlank(chargeJob))
											+ "&requestType="	+ nullToBlank(requestType)
											+ "&docNo="	+ encodeURI(nullToBlank(docNo))
											+ "&proofCode="		+ encodeURI(nullToBlank(proofCode))
											+ "&vendorName="		+ encodeURI(nullToBlank(vendorName))
											+ "&costCenterCode="		+ encodeURI(nullToBlank(costCenterCode))
											+ "&accountCode="		+ encodeURI(nullToBlank(accountCode))
											+ "&IOCode="		+ encodeURI(nullToBlank(IOCode))
											+ "&standardBriefID="		+ encodeURI(nullToBlank(standardBriefID))
											+ "&payDate="		+ encodeURI(nullToBlank(payDate))
											+ "&expAppManUser_dateArea_St="		+ encodeURI(nullToBlank(expAppManUser_dateArea_St))
											+ "&expAppManUser_dateArea_Ed="		+ encodeURI(nullToBlank(expAppManUser_dateArea_Ed))
											+ "&expAppManUser_applicationDateArea_St="		+ encodeURI(nullToBlank(expAppManUser_applicationDateArea_St))
											+ "&expAppManUser_applicationDateArea_Ed="		+ encodeURI(nullToBlank(expAppManUser_applicationDateArea_Ed))
											//+ "&title="		+ encodeURI(accountCtrl.getInfo("headerTitle").text())
											+ "&title="			+ encodeURIComponent(encodeURIComponent(title))
											+ "&headerType="		+ encodeURI(nullToBlank(headerType));
					
						location.href = locationStr;
			       	}
				});
			},
			
			

			pageOpenerIDStr : "openerID=ExpenceApplicationManageUser&",
			expAppManUser_ccDelete : function() {
				var me = this
				var labelField = accountCtrl.getInfoName("ccNameBox").text("");
				var cdField = accountCtrl.getInfoStr("[name=searchParam][tag=CostCenterCode]").val("");
			},
			expAppManUser_ccSearch : function() {
				var me = this;

				var popupID		=	"ccSearchPopup";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_costCenter'/>";	//코스트센터
				var popupName	=	"CostCenterSearchPopup";
				var callBack	=	"expAppManUser_ccSearchComp";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	"includeAccount=N&"
								+	me.pageOpenerIDStr
								+	"popupType="	+ (Common.getBaseConfig("IsUseIO") == "Y" ? "CC" : "") + 	"&"
								+	"callBackFunc="	+	callBack	+	"&"
								+	"companyCode="	+	accountCtrl.getComboInfo("expAppManUser_CompanyCode").val();
				Common.open(	"",popupID,popupTit,url,"600px","730px","iframe",true,null,null,true);
				
			},
			expAppManUser_ccSearchComp : function(value) {
				var me = this
				var labelField = accountCtrl.getInfoName("ccNameBox").text(value.CostCenterName);
				var cdField = accountCtrl.getInfoStr("[name=searchParam][tag=CostCenterCode]").val(value.CostCenterCode);
			},
			
			expAppManUser_accDelete : function() {
				var me = this
				var labelField = accountCtrl.getInfoName("accNameBox").text("");
				var cdField = accountCtrl.getInfoStr("[name=searchParam][tag=AccountCode]").val("");
			},
			expAppManUser_accSearch : function() {
				var me = this;
				var popupID		=	"accountSearchPopup";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_account'/>";	//계정과목
				var popupName	=	"AccountSearchPopup";
				var callBack	=	"expAppManUser_accSearchComp";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	me.pageOpenerIDStr
								+	"callBackFunc="	+	callBack	+	"&"
								+	"companyCode="	+	accountCtrl.getComboInfo("expAppManUser_CompanyCode").val();
				Common.open(	"",popupID,popupTit,url,"740px","690px","iframe",true,null,null,true);
				
			},
			expAppManUser_accSearchComp : function(value) {
				var me = this
				var labelField = accountCtrl.getInfoName("accNameBox").text(value.AccountName);
				var cdField = accountCtrl.getInfoStr("[name=searchParam][tag=AccountCode]").val(value.AccountCode);
			},
			
			expAppManUser_ioDelete : function() {
				var me = this
				var labelField = accountCtrl.getInfoName("ioNameBox").text("");
				var cdField = accountCtrl.getInfoStr("[name=searchParam][tag=IOCode]").val("");
			},
			expAppManUser_ioSearch : function() {
				var me = this;
				var popupID		=	"ioSearchPopup";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_projectName' />";
				var popupName	=	"BaseCodeSearchPopup";
				var callBack	=	"expAppManUser_ioSearchComp";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	me.pageOpenerIDStr
								+	"codeGroup=IOCode&"
								+	"callBackFunc="	+	callBack	+	"&"
								+	"companyCode="	+	accountCtrl.getComboInfo("expAppManUser_CompanyCode").val();
				
				Common.open(	"",popupID,popupTit,url,"600px","650px","iframe",true,null,null,true);				
			},
			expAppManUser_ioSearchComp : function(value) {
				var me = this
				var labelField = accountCtrl.getInfoName("ioNameBox").text(value.CodeName);
				var cdField = accountCtrl.getInfoStr("[name=searchParam][tag=IOCode]").val(value.Code);
			},

			expAppManUser_sbDelete : function() {
				var me = this
				var labelField = accountCtrl.getInfoName("sbNameBox").text("");
				var cdField = accountCtrl.getInfoStr("[name=searchParam][tag=StandardBriefID]").val("");
			},
			expAppManUser_sbSearch : function() {
				var me = this;
				var popupID		=	"standardBriefSearchPopup";
				var popupTit	=	"<spring:message code='Cache.ACC_standardBrief'/>";	//표준적요
				var popupName	=	"StandardBriefSearchPopup";
				var callBack	=	"expAppManUser_sbSearchComp";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	me.pageOpenerIDStr
								+	"callBackFunc="	+	callBack	+	"&"
								+	"companyCode="	+	accountCtrl.getComboInfo("expAppManUser_CompanyCode").val();
				Common.open(	"",popupID,popupTit,url,"1000px","700px","iframe",true,null,null,true);
				
			},
			expAppManUser_sbSearchComp : function(value) {
				var me = this
				var labelField = accountCtrl.getInfoName("sbNameBox").text(value.StandardBriefName);
				var cdField = accountCtrl.getInfoStr("[name=searchParam][tag=StandardBriefID]").val(value.StandardBriefID);
			},
			
			expAppManUser_searchAmtSet : function(obj) {
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
			onenter : function(){
				var me = this;
				if(event.keyCode=="13"){
					me.expAppManUser_searchExpenceApplicationList();
				}
			},
			onCkNum : function(obj){
				var me = this;
				var preVal = obj.value;
				var keyCd = event.keyCode;
				
				var keyList = [
				               8,46//삭제
				               ,9//tab
				               ,16,17,18 //alt,ctrl,shift
				               ,27//esc
				               ,37,38,36,40//방향키
				               ,112,113,114,115,116,117,118,119,120,121,122,123//펑션키
				               ]
				if(keyCd=="13"){
					me.expAppManUser_searchExpenceApplicationList();
				}
				else if(keyList.indexOf(keyCd) != -1){
					return;
				}
				else if(
					!((keyCd>=48 && keyCd<=57)
						|| (keyCd>=96 && keyCd<=105)
						||keyCd==188)){
					event.preventDefault();
					event.returnValue = false;
				}
			},
			onSetNum : function(obj){
				var me = this;
				var objVal = obj.value;
				var objVal = objVal.replace(/[^0-9,-.]/g, "");
				obj.value = objVal;
			}
	}
	window.ExpenceApplicationManageUser = ExpenceApplicationManageUser;
})(window);

	
</script>