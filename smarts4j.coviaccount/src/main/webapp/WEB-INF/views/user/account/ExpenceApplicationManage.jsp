<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
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
					<!-- 엑셀 다운로드 -->
					<a class="btnTypeDefault btnExcel" href="#" onclick="ExpenceApplicationManage.expAppMan_excelDownload('default');"><spring:message code="Cache.ACC_btn_excelDownload"/></a>
					<!-- 더존 다운로드 -->
					<a class="btnTypeDefault btnExcel" href="#" onclick="ExpenceApplicationManage.expAppMan_excelDownload('douzone');" name="douzoneBtn"><spring:message code="Cache.ACC_btn_douzoneDownload"/></a>
					<!-- 법인카드 상세정보 다운로드 -->
					<a class="btnTypeDefault btnExcel" href="#" onclick="ExpenceApplicationManage.expAppMan_excelDownload('CardReceiptExcel');" name="cardReceiptExcelBtn"><spring:message code="Cache.ACC_btn_corpCardExcelDownload"/></a>
					<!-- 전자세금계산서 상세정보 다운로드 -->
					<a class="btnTypeDefault btnExcel" href="#" onclick="ExpenceApplicationManage.expAppMan_excelDownload('TaxInvoiceExcel');" name="taxInvoiceExcelBtn"><spring:message code="Cache.ACC_btn_taxInvoiceExcelDownload"/></a>
					<!-- 삭제 -->
					<a class="btnTypeDefault" href="#" style="display:none" onclick="ExpenceApplicationManage.expAppMan_applicationDelete();"><spring:message code="Cache.ACC_btn_delete"/></a>
				<%
					if(propertyAprv==null){
						propertyAprv = "";
					}
					if("APRV".equals(propertyAprv)){
				%>
				<% 
					} else if("".equals(propertyAprv)) {
				%>				
					<!-- 승인 -->
					<a class="btnTypeDefault" href="#" onclick="ExpenceApplicationManage.expAppMan_applicationAprvStat('E');" name="aprvBtn"><spring:message code="Cache.ACC_btn_accept"/></a>
					<!-- 반려 -->
					<a class="btnTypeDefault" href="#" onclick="ExpenceApplicationManage.expAppMan_applicationAprvStat('R');" name="aprvBtn"><spring:message code="Cache.ACC_btn_reject"/></a>
				<%		
					}
				%>
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
							<span id="expAppMan_CompanyCode" class="selectType02" name="searchParam" tag="CompanyCode" onchange="ExpenceApplicationManage.changeCompanyCode()">
							</span>
						</div>
						<div class="inPerTitbox">
							<!-- 기안자 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_aprvWriter"/></span>
							<input type="text" name="searchParam" tag="RegisterNm" id="RegisterNm"
								onkeydown="ExpenceApplicationManage.onenter()">
						</div>
						<div class="inPerTitbox">
							<!-- 금액 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_amt"/></span>
							<div class="dateSel type02" >
								<input type="text" name="searchParam" tag="SearchAmtSt" style="width:100px; ime-mode:disabled; text-align: right;"" fieldtype="Amt"
									targetfield="SearchAmtEd"
									onkeydown="ExpenceApplicationManage.onCkNum(this)"
									onkeyup="ExpenceApplicationManage.onSetNum(this);"
									onblur="ExpenceApplicationManage.expAppMan_searchAmtSet(this);"> 
								~ 
								<input type="text" name="searchParam" tag="SearchAmtEd" style="width:100px; ime-mode:disabled; text-align: right;""  fieldtype="Amt"
									targetfield="SearchAmtSt"
									onkeydown="ExpenceApplicationManage.onCkNum(this)"
									onkeyup="ExpenceApplicationManage.onSetNum(this);"
									onblur="ExpenceApplicationManage.expAppMan_searchAmtSet(this);">
							</div>
							
						</div>
					</div>		
					<div style="width:830px;">
						<div class="inPerTitbox">
							<!-- 제목 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_title"/></span>
							<input type="text" name="searchParam" tag="ApplicationTitle" id="ApplicationTitle"
								onkeydown="ExpenceApplicationManage.onenter()">
						</div>
						<div class="inPerTitbox">
							<!-- 처리상태 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_processStatus"/></span>
							<span id="expAppMan_ApplicationStatus" class="selectType02" name="searchParam" tag="ApplicationStatus">
							</span>
						</div>
						<div class="inPerTitbox">
							<!-- 증빙일자 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_proofDate"/></span>
							<div id="expAppMan_dateArea" class="dateSel type02" name="searchParam" fieldtype="Date"
								stfield="expAppMan_dateArea_St" edfield="expAppMan_dateArea_Ed" 
								stdatafield="ProofDateSt" eddatafield="ProofDateEd"
							></div>	
							<!-- 
								<div id="expAppMan_dateArea_Ed" class="dateSel type02" name="searchParam" tag="ProofDateEd"></div>
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
								<a class="btn_del03" onclick="ExpenceApplicationManage.expAppMan_ccDelete()"></a>
							</div>
							<a class="btn_search03" onclick="ExpenceApplicationManage.expAppMan_ccSearch()"></a>
							<input  type="text" hidden name="searchParam" tag="CostCenterCode"
								onkeydown="ExpenceApplicationManage.onenter()" >
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<!-- 계정과목 -->
								<spring:message code='Cache.ACC_lbl_account'/>
							</span>
							<div class="name_box_wrap">
								<span class="name_box" name="accNameBox" ></span>
								<a class="btn_del03" onclick="ExpenceApplicationManage.expAppMan_accDelete()"></a>
							</div>
							<a class="btn_search03" onclick="ExpenceApplicationManage.expAppMan_accSearch()"></a>
							<input  type="text" hidden name="searchParam" tag="AccountCode"
								onkeydown="ExpenceApplicationManage.onenter()" >
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<spring:message code='Cache.ACC_lbl_projectName'/>
							</span>
							<div class="name_box_wrap">
								<span class="name_box" name="ioNameBox" ></span>
								<a class="btn_del03" onclick="ExpenceApplicationManage.expAppMan_ioDelete()"></a>
							</div>
							<a class="btn_search03" onclick="ExpenceApplicationManage.expAppMan_ioSearch()"></a>
							<input  type="text" hidden name="searchParam" tag="IOCode" >						
						</div>
					</div>
					<div style="width:830px;">
						<%-- <div class="inPerTitbox">
							<!-- 전표번호 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_docNo"/></span>
							<input type="text" name="searchParam" tag="DocNo"
								onkeydown="ExpenceApplicationManage.onenter()">
						</div> --%>						
						<%-- <div class="inPerTitbox">
							<!-- 담당업무 - 회계팀 커스텀 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_chargeJob"/></span>
							<span id="expAppMan_ChargeJob" class="selectType02" name="searchParam" tag="ChargeJob">
							</span>
						</div> --%>
						<div class="inPerTitbox">
							<!-- 신청유형 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_requestType"/></span>
							<span id="expAppMan_RequestType" class="selectType02" name="searchParam" tag="RequestType">
							</span>
						</div>
						<div class="inPerTitbox">
							<!-- 증빙종류 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_proofClass"/></span>
							<span id="expAppMan_ProofCode" class="selectType02" name="searchParam" tag="ProofCode">
							</span>
						</div>
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<!-- 기안일 -->
								<spring:message code='Cache.ACC_lbl_aprvDate'/>
							</span>
							<div id="expAppMan_applicationDateArea" class="dateSel type02" name="searchParam" fieldtype="Date"
								stfield="expAppMan_applicationDateArea_St" edfield="expAppMan_applicationDateArea_Ed" 
								stdatafield="ApplicationDateSt" eddatafield="ApplicationDateEd"
							></div>	
						</div>
					</div>
					<div style="width:980px;">
						<div class="inPerTitbox">
							<!-- 거래처명 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_vendorName"/></span>
							<input type="text" name="searchParam" tag="VendorName"
								onkeydown="ExpenceApplicationManage.onenter()">
						</div>
						<div class="inPerTitbox" name="divListSearchArea">
							<!-- 표준적요 -->
							<span class="bodysearch_tit"><spring:message code='Cache.ACC_standardBrief'/></span>
							<div class="name_box_wrap">
								<span class="name_box" name="sbNameBox" ></span>
								<a class="btn_del03" onclick="ExpenceApplicationManage.expAppMan_sbDelete()"></a>
							</div>
							<a class="btn_search03" onclick="ExpenceApplicationManage.expAppMan_sbSearch()"></a>
							<input  type="text" hidden name="searchParam" tag="StandardBriefID"
								onkeydown="ExpenceApplicationManage.onenter()" >
						</div>
						<div class="inPerTitbox" name="divListSearchArea">
							<!-- 지급일자 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_payDay"/></span>
							<div id="expAppMan_dateAreaPayDate" class="dateSel type02" name="searchParam" tag="PayDate" fieldtype="Date">
							</div>
						</div>
						<a href="#" class="btnTypeDefault btnSearchBlue" onclick="ExpenceApplicationManage.expAppMan_searchExpenceApplicationList()"><spring:message code="Cache.ACC_btn_search"/></a>
					</div>
				</div>
			</div>
			<!-- 검색영역 끝 -->
			<div class="inPerTitbox">
				<!-- 구분 -->
				<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_division"/></span>
				<span class="selectType02"	id="expAppManSearchType" name="searchParam" tag="SearchType"
				onchange="ExpenceApplicationManage.expAppMan_searchExpenceApplicationList()">
				</span>
				
				<div class="buttonStyleBoxRight ">	
					<span class="selectType02 listCount" id="expAppManListCount" onchange="ExpenceApplicationManage.expAppMan_searchExpenceApplicationList();">
						<!-- 
						<option>10</option>
						<option>20</option>
						<option>30</option>
						-->
					</span>
					<button class="btnRefresh" type="button" onclick="ExpenceApplicationManage.expAppMan_searchExpenceApplicationList();"></button>
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

if (!window.ExpenceApplicationManage) {
	window.ExpenceApplicationManage = {};
}

(function(window) {
	
	var propertyOtherApv = "<%=propertyOtherApv%>";
	
	var ExpenceApplicationManage = {
			
			gridPanel : new coviGrid(),
			gridHeaderDataList : [],
			searchedType : "",
			setGridHead : [],
			auditInfo : {},

			pageInit : function() {
				var me = this;
				setPropertySyncType('AccountManage','syncProperty');
				
				setHeaderTitle('headerTitle');

				me.gridHeaderDataList = expAppCommon.getGridHeader("app");
				
				var today = new Date();
				var gy = today.getFullYear();
				var gm = today.getMonth();
				var gd = today.getDate();
				//coviCtrl.makeSimpleCalendar('expAppMan_dateArea_St', gy+"."+gm+"."+gd);
				//coviCtrl.makeSimpleCalendar('expAppMan_dateArea_Ed', gy+"."+(gm+1)+"."+gd);
				makeDatepicker('expAppMan_dateArea', 'expAppMan_dateArea_St', 'expAppMan_dateArea_Ed', null, null, 100);
				makeDatepicker('expAppMan_applicationDateArea', 'expAppMan_applicationDateArea_St', 'expAppMan_applicationDateArea_Ed', null, null, 100);
				makeDatepicker('expAppMan_dateAreaPayDate', 'expAppMan_dateAreaPayDate', null, null, null, 220);

				me.expAppMan_comboInit();
				me.expAppMan_gridInit();		
			},
			
			pageView : function() {
				var me = this;
				me.expAppMan_comboRefresh();
				me.expAppMan_searchExpenceApplicationList();
			},

			expAppMan_comboInit : function(pCompanyCode) {
				accountCtrl.getInfo("expAppManListCount").children().remove();
				accountCtrl.getInfo("expAppManSearchType").children().remove();
				accountCtrl.getInfo("expAppMan_ProofCode").children().remove();
				accountCtrl.getInfo("expAppMan_ApplicationStatus").children().remove();
				accountCtrl.getInfo("expAppMan_RequestType").children().remove();

				accountCtrl.getInfo("expAppManListCount").addClass("selectType02").addClass("listCount").attr("onchange", "ExpenceApplicationManage.expAppMan_searchExpenceApplicationList();");
				accountCtrl.getInfo("expAppManSearchType").addClass("selectType02").attr("name", "searchParam").attr("tag", "SearchType").attr("onchange", "ExpenceApplicationManage.expAppMan_searchExpenceApplicationList()");
				accountCtrl.getInfo("expAppMan_ProofCode").addClass("selectType02").attr("name", "searchParam").attr("tag", "ProofCode");
				accountCtrl.getInfo("expAppMan_ApplicationStatus").addClass("selectType02").attr("name", "searchParam").attr("tag", "ApplicationStatus");
				accountCtrl.getInfo("expAppMan_RequestType").addClass("selectType02").attr("name", "searchParam").attr("tag", "RequestType");
				
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
						,"target":"expAppMan_ProofCode"
						,"lang":"ko"
						,"onchange":""
						,"oncomplete":""
						,"defaultVal":""
						,"useDefault":"<spring:message code='Cache.ACC_lbl_comboAll' />"
					},
					{
						"codeGroup":"ExpenceApplicationStatus"
						,"target":"expAppMan_ApplicationStatus"
						,"lang":"ko"
						,"onchange":""
						,"oncomplete":""
						,"defaultVal":""
						,"useDefault":"<spring:message code='Cache.ACC_lbl_comboAll' />"
					},
					{
						"codeGroup":"FormManage_RequestType"
						,"target":"expAppMan_RequestType"
						,"lang":"ko"
						,"onchange":""
						,"oncomplete":""
						,"defaultVal":""
						,"useDefault":"<spring:message code='Cache.ACC_lbl_comboAll' />"
					}
				];
				accountCtrl.renderAXSelectMulti(__AXSelectMultiArr, pCompanyCode);
				
				if(pCompanyCode == undefined) {
					accountCtrl.renderAXSelect('CompanyCode',			'expAppMan_CompanyCode',		'ko','','','',null,pCompanyCode);
				}
			},

			expAppMan_comboRefresh : function() {
				accountCtrl.refreshAXSelect('expAppMan_ProofCode');
				accountCtrl.refreshAXSelect('expAppMan_ApplicationStatus');
				accountCtrl.refreshAXSelect('expAppMan_RequestType');
				accountCtrl.refreshAXSelect('expAppMan_CompanyCode');
			},
			
			changeCompanyCode : function() {
				var me = this;
				me.expAppMan_comboInit(accountCtrl.getComboInfo("expAppMan_CompanyCode").val());
			},

			//audit 정보 획득. 현재 미사용.
			//audit은 데이터 조회시 db에서 같이 가지고 나오게 수정됨
			expAppMan_getAuditInfo : function(defaultVal) {
				var me = this;

				return;
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
			
			expAppMan_gridInit : function() {
				var me = this;
				me.expAppMan_searchExpenceApplicationList();
			},

			expAppMan_gridHeaderInit : function() {
				var me = this;
				var getHead = [];

				var searchType = accountCtrl.getInfoStr("[name=searchParam][tag=SearchType]").val();

				getHead = expAppCommon.getGridHeader(searchType);
				
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
					me.expAppMan_ccDelete();
					me.expAppMan_accDelete();
					me.expAppMan_ioDelete();
				}
				
				//증빙별 보기에서만 버튼 display
				if(searchType=="list"){
					accountCtrl.getInfoName("douzoneBtn").css("display", "");
					accountCtrl.getInfoName("cardReceiptExcelBtn").css("display", "");
					accountCtrl.getInfoName("taxInvoiceExcelBtn").css("display", "");
				} else {
					accountCtrl.getInfoName("douzoneBtn").css("display", "none");
					accountCtrl.getInfoName("cardReceiptExcelBtn").css("display", "none");
					accountCtrl.getInfoName("taxInvoiceExcelBtn").css("display", "none");
				}
			},

			//조회조건 획득
			expAppMan_getSearchParams : function() {
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
									var dateVal = accountCtrl.getInfoStr("input[id=expAppMan_dateAreaPayDate]").val();
									dateVal = dateVal.replaceAll(".", "");
									retVal[item.getAttribute("tag")] = dateVal;										
								} else {
									var stField = item.getAttribute("stfield");
									var edField = item.getAttribute("edfield");
									
									var stDataField = item.getAttribute("stdatafield");
									var edDataField = item.getAttribute("eddatafield");
									
									var stVal = accountCtrl.getInfo(stField).val();
									var edVal = accountCtrl.getInfo(edField).val();

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
			
			//조회
			expAppMan_searchExpenceApplicationList : function(YN) {
				var me = this;
				
				var searchParam = me.expAppMan_getSearchParams();
				me.expAppMan_getAuditInfo();
				me.expAppMan_gridHeaderInit();
				var pageSize	= accountCtrl.getComboInfo("expAppManListCount").val();
				
				var gridAreaID		= "ExpAppManListGrid";
				var gridPanel		= me.gridPanel;
				//var gridHeader		= me.gridHeaderData;
				var gridHeader		= me.setGridHead;
				
				var ajaxUrl			= "/account/expenceApplication/searchExpenceApplicationList.do";
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
								, 	"callback"		: me.expappMan_searchCallback
								,	"fitToWidth"	: false
				}
				
				accountCtrl.setViewPageBindGrid(gridParams);
			},
			

			//조회 후처리
			expappMan_searchCallback : function() {
				var me = window.ExpenceApplicationManage;
				var searchedType = accountCtrl.getInfoStr("[name=searchParam][tag=SearchType]").val();
				me.searchedType = searchedType;
			},
			
			//증빙보기
			expAppMan_viewEvidPopup : function(getId, ProcessID) {
				var me = this;
				//전표조회
				Common.open("","expenceApplicationViewPopup"+getId,"<spring:message code='Cache.ACC_lbl_expenceApplicationView'/>",
					"/account/expenceApplication/ExpenceApplicationViewPopup.do?ExpAppID="+getId+"&processID="+ProcessID,"1000px","800px","iframe",true,"450px","100px",true);
			},			

			expAppMan_viewEvidTempPopup : function(getId, type, requestType, regUserId) {
				Common.open("","expenceApplicationViewPopup"+getId,"<spring:message code='Cache.ACC_lbl_expenceApplicationView'/>",
					"/account/expenceApplication/ExpenceApplicationViewPopup.do?ExpAppID="+getId+"&processID=&mode=TEMPSAVE&gloct=ADMTEMPSAVE","1000px","800px","iframe",true,"450px","100px",true);
			},
			
			//파일보기
			expAppMan_expAppManViewFile : function(getId) {
				var me = this;
				//첨부파일
				Common.open("","expAppManViewFile","<spring:message code='Cache.ACC_lbl_addFile'/>",	
					"/account/expenceApplication/ExpenceApplicationViewFilePopup.do?ExpAppListID="+getId,"350px","400px","iframe",true,null,null,true);
			},

			expAppMan_LinkOpen : function(stat, ProcessId){
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
			
			
			//증빙보기
			expAppMan_viewEvidListItem : function(ProofCode, LinkKey) {
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
					accComm.accMobileReceiptAppClick(LinkKey, me.pageOpenerIDStr);
				}
			},

			//증빙 삭제
			expAppMan_applicationDelete : function(){
				var me = this;
				
				
				if(me.searchedType != "div"){
					var deleteobj	= me.gridPanel.getCheckedList(0);
					
					if(deleteobj.length == 0){
						Common.Inform("<spring:message code='Cache.ACC_msg_noselectdata'/>");	//선택된 항목이 없습니다.
						return;
					}

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
					
					//삭제하시겠습니까?
			        Common.Confirm("<spring:message code='Cache.ACC_msg_ckDelete' />", "Confirmation Dialog", function(result){	
			       		if(result){
			       			me.expAppMan_callDeleteAjax(deleteobj)
			       		}
			        });
					
				}else{

					Common.Inform("<spring:message code='Cache.ACC_020'/>");	// 증빙별 조회를 하였을 시에만 삭제가 가능합니다.
					return;
				}
			},

			//증빙 삭제
			expAppMan_callDeleteAjax : function(deletedList){

				var deleteObj = {};
				deleteObj.deleteList = 	deletedList
				
				var me = this;
				$.ajax({
					type:"POST",
						url:"/account/expenceApplication/deleteExpenceApplicationManList.do",
					data:{
						"deleteObj"	: JSON.stringify(deleteObj),
						"deleteType"	: me.searchedType
					},
					success:function (data) {
						if(data.result == "ok"){
							Common.Inform("<spring:message code='Cache.ACC_msg_delComp'/>");	//삭제를 완료하였습니다.
							me.expAppMan_searchExpenceApplicationList();
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
					}
				});
			},

			//상태값 변경
			expAppMan_applicationAprvStat : function(stat){
				var me = this;
				var useAprv = false;
				
				<%
					if("APRV".equals(propertyAprv)){
				%>
						useAprv = true;
				<%
					}
				%>
				
				if(me.searchedType == "list" || me.searchedType == "app"){
					var aprvobj	= me.gridPanel.getCheckedList(0);
					
					if(aprvobj.length == 0){
						Common.Inform("<spring:message code='Cache.ACC_msg_noselectdata'/>");	//선택된 항목이 없습니다.
						return;
					}	
					
					var appCk = false;
					var statCk = false;
					var aprvStatCk = false;
					for(var i = 0; i < aprvobj.length; i++){
						var item = aprvobj[i];
						if(ckNaN(item.AppCnt) > 1){
							appCk = true;
						}
						
						if(!useAprv) {
							if(item.ApplicationStatus != "D" &&
									item.ApplicationStatus != "S" ){
								statCk = true;
							}
						} else {
							if(item.ApplicationStatus != "S") {
								aprvStatCk = true;
							}
						}
					}
					
					var msg = "";
					
					if(!useAprv && statCk){
						msg = "<spring:message code='Cache.ACC_025' />";	//결재 진행중이 아닌 항목이 선택되었습니다.
						Common.Inform(msg);
						return;
					} else if(useAprv && aprvStatCk) {
						msg = "<spring:message code='Cache.ACC_msg_cannotRejectTo' />";	//관리자 페이지에서의 반려 처리는 처리 상태가 '신청'인 문서만 가능합니다.
						Common.Inform(msg);
						return;
					}
					
					if(stat=="E"){
						msg = "<spring:message code='Cache.ACC_msg_ckAccept' />";	//승인하시겠습니까?
					}else if(stat=="R"){
						msg = "<spring:message code='Cache.ACC_msg_ckReject' />";	//반려하시겠습니까?
					}
					if(appCk){
						msg = "<spring:message code='Cache.ACC_024' />" + "<br>" + msg;	//하나의 전표에 여러 증빙이 있는 항목이 있습니다. 승인/반려시 전표의 모든 증빙이 같이 처리됩니다.
					}
			        Common.Confirm(msg, "Confirmation Dialog", function(result){
			       		if(result){	
							var aprvObj = {
									setStatus : stat
							};							
							aprvObj.aprvList = 	aprvobj
			       			me.expAppMan_callStatChangeAjax(aprvObj)
			       		}
			        });
				} else {
					Common.Inform("<spring:message code='Cache.ACC_020'/>");	//증빙별 조회를 하였을 시에만 삭제가 가능합니다.
					return;
				}
				
			},
			
			//상태값 변경
			expAppMan_callStatChangeAjax : function(aprvObj){
				var me = this;
				
				if(aprvObj == null ){
					return;
				}
				if(aprvObj.aprvList == null ){
					return;
				}
				
				$.ajax({
					type:"POST",
						url:"/account/expenceApplication/statChangeExpenceApplicationManList.do",
					data:{
						"aprvObj"	: JSON.stringify(aprvObj),
						"searchedType" : me.searchedType
					},
					success:function (data) {
						if(data.result == "ok"){
							Common.Inform("<spring:message code='Cache.ACC_msg_processComplet'/>");	//처리를 완료하였습니다.
							me.expAppMan_searchExpenceApplicationList();
						}
						else if(data.result == "st"){
							Common.Inform("<spring:message code='Cache.ACC_025'/>");	//결재 진행중이 아닌 항목이 선택되었습니다.
							me.expAppMan_searchExpenceApplicationList();
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
					}
				});
			},
			
			//엑셀 다운로드
			expAppMan_excelDownload : function(type){
				var me = this;

				var title = accountCtrl.getInfo("headerTitle").text();
				var msg = "<spring:message code='Cache.ACC_msg_excelDownMessage'/>";
				var getHead = expAppCommon.getGridHeader(type);
				var searchType = (type == 'default' ? accountCtrl.getInfoStr("[name=searchParam][tag=SearchType]").val() : type);
				
				if(type == 'douzone') {
					title = "<spring:message code='Cache.ACC_lbl_douzone'/>";
					msg = "<spring:message code='Cache.ACC_msg_douzoneDownMessage'/>";
				} else {
					if(type == 'default') {
						getHead = me.setGridHead;					
					} else {
						if(type == 'CardReceiptExcel') {
							title = "<spring:message code='Cache.ACC_lbl_corpCardExcelTitle'/>";
						} else if(type == 'TaxInvoiceExcel') {
							title = "<spring:message code='Cache.ACC_lbl_taxInvoiceExcelTitle'/>";
						}
					}
				}
				
				if(Common.getBaseConfig("IsUseStoreStatus") == "Y" && (searchType == "list" || searchType == "CardReceiptExcel")) {
					var idx = getHead.findIndex( function(header) {
						return header.key == "StoreName";
					});
					var objStoreStatus = { key:'CardStoreStatus', label:Common.getDic("ACC_lbl_storeStatus"), width:'150', align:'center' }; //가맹점상태
					
					getHead.splice(idx+1, 0, objStoreStatus);
				}
				
	  			var headerName = accountCommon.getHeaderNameForExcel(getHead);
				var headerKey = accountCommon.getHeaderKeyForExcel(getHead);

				Common.Confirm(msg, "<spring:message code='Cache.ACC_btn_save' />", function(result){
			  		if(result){
 						var searchParams	= me.expAppMan_getSearchParams();
						
						var applicationStatus = searchParams.ApplicationStatus;
						var registerNm = searchParams.RegisterNm;
						var companyCode = accountCtrl.getComboInfo("expAppMan_CompanyCode").val();
						var companyName	= searchParams.CompanyName;
						var applicationType = searchParams.ApplicationType;
						var applicationTitle = searchParams.ApplicationTitle;
						var requestType = searchParams.RequestType;
						var docNo = searchParams.DocNo;
						var proofCode = searchParams.ProofCode;
						var vendorName = searchParams.VendorName;
						var costCenterCode = searchParams.CostCenterCode;
						var accountCode = searchParams.AccountCode;
						var IOCode = searchParams.IOCode;
						var standardBriefID = searchParams.StandardBriefID;
						var payDate = searchParams.PayDate;
						var expAppMan_dateArea_St = searchParams.ProofDateSt;
						var expAppMan_dateArea_Ed = searchParams.ProofDateEd;
						var expAppMan_applicationDateArea_St = searchParams.ApplicationDateSt;
						var expAppMan_applicationDateArea_Ed = searchParams.ApplicationDateEd;
						var pUrl = "/account/expenceApplication/excelDownloadExpenceApplicationList.do";
						var pParamJson = {
								"headerName"		:encodeURIComponent(headerName)
								,"headerKey"			:nullToBlank(headerKey)
								,"searchType"			:nullToBlank(searchType)
								,"applicationStatus"	:nullToBlank(applicationStatus)
								,"registerNm"			:nullToBlank(registerNm)
								,"companyCode" 			:nullToBlank(companyCode)
								,"companyName"			:nullToBlank(companyName)
								,"applicationTitle"		:nullToBlank(applicationTitle)
								,"requestType"			:nullToBlank(requestType)
								,"docNo"				:nullToBlank(docNo)
								,"proofCode"			:nullToBlank(proofCode)
								,"vendorName"			:nullToBlank(vendorName)
								,"costCenterCode"		:nullToBlank(costCenterCode)
								,"accountCode"			:nullToBlank(accountCode)
								,"IOCode"				:nullToBlank(IOCode)
								,"standardBriefID"		:nullToBlank(standardBriefID)
								,"payDate"				:nullToBlank(payDate)
								,"expAppMan_dateArea_St"		:nullToBlank(expAppMan_dateArea_St)
								,"expAppMan_dateArea_Ed"		:nullToBlank(expAppMan_dateArea_Ed)
								,"expAppMan_applicationDateArea_St"		:nullToBlank(expAppMan_applicationDateArea_St)
								,"expAppMan_applicationDateArea_Ed"		:nullToBlank(expAppMan_applicationDateArea_Ed)
								,"title"				:encodeURIComponent(title)
						};
						Common.downloadFilePost (pUrl, pParamJson);
			       	}
				});
			},

			//더존 다운로드
			expAppMan_douzoneDownload : function(){
				var me = this;
				Common.Confirm("<spring:message code='Cache.ACC_msg_douzoneDownMessage'/>", "<spring:message code='Cache.ACC_btn_save' />", function(result){ //엑셀(더존용)을 저장하시겠습니까?
			  		if(result){
						var getHead = expAppCommon.getGridHeader("douzone");
						
			  			var headerName		= getHeaderNameForExcel(getHead);
						var headerKey		= getHeaderKeyForExcel(getHead);
						var searchParams	= me.expAppMan_getSearchParams();
						
						var applicationStatus = searchParams.ApplicationStatus;
						var registerNm = searchParams.RegisterNm;
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
						var expAppMan_dateArea_St = searchParams.ProofDateSt;
						var expAppMan_dateArea_Ed = searchParams.ProofDateEd;
						var expAppMan_applicationDateArea_St = searchParams.ApplicationDateSt;
						var expAppMan_applicationDateArea_Ed = searchParams.ApplicationDateEd;
						var pUrl = "/account/expenceApplication/excelDownloadExpenceApplicationList.do";
						var pParamJson = {
								 "headerName"								 : encodeURIComponent(nullToBlank(headerName))
								 ,"headerKey"								 : nullToBlank(headerKey)
								 ,"searchType"							 : 'douzone'
								 ,"applicationStatus"						 : nullToBlank(applicationStatus)
								 ,"registerNm"							 : nullToBlank(registerNm)
								 ,"companyName"							 : nullToBlank(companyName)
								 ,"applicationTitle"						 : nullToBlank(applicationTitle)
								 ,"requestType"							 : nullToBlank(requestType)
								 ,"docNo"									: nullToBlank(docNo)
								 ,"proofCode"								: nullToBlank(proofCode)
								 ,"vendorName"							 : nullToBlank(vendorName)
								 ,"costCenterCode"						 : nullToBlank(costCenterCode)
								 ,"accountCode"							 : nullToBlank(accountCode)
								 ,"IOCode"								 : nullToBlank(IOCode)
								 ,"standardBriefID"						 : nullToBlank(standardBriefID)
								 ,"payDate"								 : nullToBlank(payDate)
								 ,"expAppMan_dateArea_St"					 : nullToBlank(expAppMan_dateArea_St)
								 ,"expAppMan_dateArea_Ed"					 : nullToBlank(expAppMan_dateArea_Ed)
								 ,"expAppMan_applicationDateArea_St"		 : nullToBlank(expAppMan_applicationDateArea_St)
								 ,"expAppMan_applicationDateArea_Ed"		 : nullToBlank(expAppMan_applicationDateArea_Ed)
								 ,"title"									 : accountCtrl.getInfo("headerTitle").text()
						};
						Common.downloadFilePost (pUrl, pParamJson);
			       	}
				});
			},

			pageOpenerIDStr : "openerID=ExpenceApplicationManage&",
			expAppMan_ccDelete : function() {
				var me = this
				var labelField = accountCtrl.getInfoName("ccNameBox").text("");
				var cdField = accountCtrl.getInfoStr("[name=searchParam][tag=CostCenterCode]").val("");
			},
			expAppMan_ccSearch : function() {
				var me = this;

				var popupID		=	"ccSearchPopup";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_costCenter'/>";	//코스트센터
				var popupName	=	"CostCenterSearchPopup";
				var callBack	=	"expAppMan_ccSearchComp";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	"includeAccount=N&"
								+	me.pageOpenerIDStr
								+	"popupType="	+ (Common.getBaseConfig("IsUseIO") == "Y" ? "CC" : "") + 	"&"
								+	"callBackFunc="	+	callBack	+	"&"
								+	"companyCode="	+	accountCtrl.getComboInfo("expAppMan_CompanyCode").val();
				Common.open(	"",popupID,popupTit,url,"600px","730px","iframe",true,null,null,true);
				
			},
			expAppMan_ccSearchComp : function(value) {
				var me = this
				var labelField = accountCtrl.getInfoName("ccNameBox").text(value.CostCenterName);
				var cdField = accountCtrl.getInfoStr("[name=searchParam][tag=CostCenterCode]").val(value.CostCenterCode);
			},
			
			expAppMan_accDelete : function() {
				var me = this
				var labelField = accountCtrl.getInfoName("accNameBox").text("");
				var cdField = accountCtrl.getInfoStr("[name=searchParam][tag=AccountCode]").val("");
			},
			expAppMan_accSearch : function() {
				var me = this;
				var popupID		=	"accountSearchPopup";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_account'/>";	//계정과목
				var popupName	=	"AccountSearchPopup";
				var callBack	=	"expAppMan_accSearchComp";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	me.pageOpenerIDStr
								+	"callBackFunc="	+	callBack	+	"&"
								+	"companyCode="	+	accountCtrl.getComboInfo("expAppMan_CompanyCode").val();
				Common.open(	"",popupID,popupTit,url,"740px","690px","iframe",true,null,null,true);
				
			},
			expAppMan_accSearchComp : function(value) {
				var me = this
				var labelField = accountCtrl.getInfoName("accNameBox").text(value.AccountName);
				var cdField = accountCtrl.getInfoStr("[name=searchParam][tag=AccountCode]").val(value.AccountCode);
			},
			
			expAppMan_ioDelete : function() {
				var me = this
				var labelField = accountCtrl.getInfoName("ioNameBox").text("");
				var cdField = accountCtrl.getInfoStr("[name=searchParam][tag=IOCode]").val("");
			},
			expAppMan_ioSearch : function() {
				var me = this;
				var popupID		=	"ioSearchPopup";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_projectName' />";
				var popupName	=	"BaseCodeSearchPopup";
				var callBack	=	"expAppMan_ioSearchComp";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	me.pageOpenerIDStr
								+	"codeGroup=IOCode&"
								+	"callBackFunc="	+	callBack	+	"&"
								+	"companyCode="	+	accountCtrl.getComboInfo("expAppMan_CompanyCode").val();
				
				Common.open(	"",popupID,popupTit,url,"600px","650px","iframe",true,null,null,true);				
			},
			expAppMan_ioSearchComp : function(value) {
				var me = this
				var labelField = accountCtrl.getInfoName("ioNameBox").text(value.CodeName);
				var cdField = accountCtrl.getInfoStr("[name=searchParam][tag=IOCode]").val(value.Code);
			},
			
			expAppMan_sbDelete : function() {
				var me = this
				var labelField = accountCtrl.getInfoName("sbNameBox").text("");
				var cdField = accountCtrl.getInfoStr("[name=searchParam][tag=StandardBriefID]").val("");
			},
			expAppMan_sbSearch : function() {
				var me = this;
				var popupID		=	"standardBriefSearchPopup";
				var popupTit	=	"<spring:message code='Cache.ACC_standardBrief'/>";	//표준적요
				var popupName	=	"StandardBriefSearchPopup";
				var callBack	=	"expAppMan_sbSearchComp";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	me.pageOpenerIDStr
								+	"callBackFunc="	+	callBack	+	"&"
								+	"companyCode="	+	accountCtrl.getComboInfo("expAppMan_CompanyCode").val();
				Common.open(	"",popupID,popupTit,url,"1000px","700px","iframe",true,null,null,true);
				
			},
			expAppMan_sbSearchComp : function(value) {
				var me = this
				var labelField = accountCtrl.getInfoName("sbNameBox").text(value.StandardBriefName);
				var cdField = accountCtrl.getInfoStr("[name=searchParam][tag=StandardBriefID]").val(value.StandardBriefID);
			},
			
			expAppMan_searchAmtSet : function(obj) {
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
			
			/* 미사용 */
			/*
			GetExpenceApplicationSync : function(){
				$.ajax({
					url	: "/account/expenceApplication/getExpenceApplicationSync.do",
					type: "POST",
					success:function (data) {
						if(data.status == "SUCCESS"){
							Common.Inform("<spring:message code='Cache.ACC_msg_syncComp' />");	//동기화 되었습니다.
							ExpenceApplicationManage.expAppMan_searchExpenceApplicationList();
						}else{
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
					}
				});
			},
			
			SetExpenceApplicationSync : function(interFaceSetType){
				var me = this;
				var params	= new Object();
				var syncList	= me.gridPanel.getCheckedList(0);
			
				if(syncList.length == 0){
					Common.Inform("<spring:message code='Cache.ACC_msg_noselectdata'/>");	//선택된 항목이 없습니다.
					return;
				}
			
				params.interFaceSetType	= interFaceSetType;
				params.syncList			= syncList;
			
				$.ajax({
					url			: "/account/expenceApplication/setExpenceApplicationSync.do",
					type		: "POST",
					data		: JSON.stringify(params),
					dataType	: "json",
					contentType	: "application/json",
					success:function (data) {
						if(data.status == "SUCCESS"){
							Common.Inform("<spring:message code='Cache.ACC_msg_syncComp' />");	//동기화 되었습니다.
							ExpenceApplicationManage.expAppMan_searchExpenceApplicationList();
						}else{
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
					}
				});
			},
			*/
			
			onenter : function(){
				var me = this;
				if(event.keyCode=="13"){
					me.expAppMan_searchExpenceApplicationList();
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
					me.expAppMan_searchExpenceApplicationList();
				}
				else if(keyList.indexOf(keyCd) != -1){
					return;
				}
				else if(
					!((keyCd>=48 && keyCd<=57)
						|| (keyCd>=96 && keyCd<=105)
						|| keyCd==188)){
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
	window.ExpenceApplicationManage = ExpenceApplicationManage;
})(window);

	
</script>
