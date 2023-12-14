<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil" %>
<%@ page import="egovframework.coviframework.util.RedisDataUtil" %>
<%@ page import="egovframework.coviaccount.common.util.AccountUtil" %>

<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<%
	String requestType = request.getParameter("requesttype");

	AccountUtil accountUtil = new AccountUtil();
	String propertyAprv = accountUtil.getBaseCodeInfo("eAccApproveType", "ExpenceApplication");

	String propertyOtherApv = RedisDataUtil.getBaseConfig("eAccOtherApv");
	String AccountApvLineType =  RedisDataUtil.getBaseConfig("AccountApvLineType");
	
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<head>
	<% if(AccountApvLineType.equals("Graphic")) { %>
		<script type="text/javascript" src="/approval/resources/script/user/approvestat.js<%=resourceVersion%>"></script>
		<link rel="stylesheet" type="text/css" href="<%=cssPath%>/approval/resources/css/approval/monitoring.css<%=resourceVersion%>" />
	<% } else { %>
		<script type="text/javascript" src="/approval/resources/script/forms/FormApvLine.js<%=resourceVersion%>"></script>
	<% } %>
	
	<style>
	.pad10 { padding:10px;}
	</style>
</head>
<body>
	<!-- 상단 끝 -->
	<div class="cRConTop titType">
		<h2 id="headerTitle" class="title"></h2>			
	</div>
	<!-- 상단 버튼 시작 -->
	<div class="cRConTop">
		<div class="cRTopButtons">	<!-- 신청 -->
			<a href="#" class="btnTypeDefault btnTypeChk" onClick="CombineCostApplication<%=requestType%>.combiCostApp_onSave('S')" name="saveBtn">
				<spring:message code="Cache.ACC_btn_application"/>
			</a>					<!-- 결재선 -->
			<a href="#" class="btnTypeDefault" onClick="openApvLinePopup()" name="apvLineBtn" style="display: none;">
				<spring:message code="Cache.lbl_ApprovalLine"/>
			</a>
			<a href="#" class="btnTypeDefault" onClick="openRuleApvPopup()" name="ruleApvbtn" style="display: none;">
				<!-- 전결규정 -->
				<spring:message code="Cache.apv_btn_rule"/>
			</a>					<!-- 임시저장 -->
			<a href="#" class="btnTypeDefault" onClick="CombineCostApplication<%=requestType%>.combiCostApp_onSave('T')" name="saveBtn">
				<spring:message code="Cache.ACC_btn_tempSave"/>
			</a>					<!-- 저장 -->
			<a href="#" class="btnTypeDefault" onClick="CombineCostApplication<%=requestType%>.combiCostApp_onSave('E')"  name="afterSaveBtn" style="display:none">
				<spring:message code="Cache.ACC_btn_save"/>
			</a>					<!-- 미리보기 -->
			<a href="#" class="btnTypeDefault" onclick="CombineCostApplication<%=requestType%>.combiCostApp_showPreview()" name="previewBtn" style="display:none">
				<spring:message code="Cache.btn_preview"/>
			</a>
			<a href="#" class="btn_taw_open" onclick="CombineCostApplication<%=requestType%>.combiCostApp_toggleShowArea()"></a>
		</div>
	</div>
	<!-- 상단 버튼 끝 -->
	<div class="total_acooungting" id="combineCostAppDiv">			
	<% 
		if(propertyOtherApv.equals("N")) {
			if(AccountApvLineType.equals("Graphic")) { %>
				<div id="graphicDiv" style="padding: 25px 0 0 25px;"></div>
		<%	} else { %>
				<jsp:include page="Frozen.jsp" flush="false"></jsp:include>
		<% 	}
		}
	%>
							
		<!-- 컨텐츠 시작 -->
		<div class="eaccountingCont">
			<div class="allMakeView">
				<div class="inpStyle01 allMakeTitle">
					<input type="text" class="inpStyle01 HtmlCheckXSS ScriptCheckXSS" id="comCostApp_ApplicationTitle" name="ComCostAppInputField"
						onkeyup="CombineCostApplication<%=requestType%>.combiCostApp_setModified(true)" 
						tag="ApplicationTitle" placeholder="<spring:message code='Cache.ACC_msg_noTitle'/>" maxlength="100">	<!-- 제목을 입력하세요 -->
					<input type="hidden" id="comCostApp_isSearched" name="ComCostAppInputField" tag="isSearched">
					<input type="hidden" id="comCostApp_isNew"  name="ComCostAppInputField" tag="isNew">
					<input type="hidden" id="comCostApp_ExpAppId"  name="ComCostAppInputField" tag="ExpenceApplicationID">
					
					<input type="hidden" id="comCostApp_PropertyCardReceipt" name="ExpAppPropertyField" tag="CardReceipt">
					<input type="hidden" id="comCostApp_PropertyTaxInvoice" name="ExpAppPropertyField" tag="TaxInvoice">
					<input type="hidden" id="comCostApp_PropertyCostCenter" name="ExpAppPropertyField" tag="CostCenter">
					<input type="hidden" id="comCostApp_PropertyAccount" name="ExpAppPropertyField" tag="AccountManage">
					<input type="hidden" id="comCostApp_PropertyBudget" tag="Budget">
					
				</div>
			</div>
			<p class="eaccounting_name">	<!-- 신청자 -->
				<strong><spring:message code="Cache.ACC_lbl_applicator"/> :</strong> 
				<label id="comCostApp_lblApplicator"></label>
			</p>
			<div class="eaccountingCont_in">
				<div class="inStyleSetting">	
					<div class="total_acooungting_wrap" id="comCostApp_TotalWrap">
						<table class="total_acooungting_wrap_table">
							<tbody>
								<tr>
									<td class="acc_total_l">
										<table class="total_table_list">
											<tbody>
												<tr><td id="comCostApp_EvidAmtArea"></td></tr>
												<tr><td id="comCostApp_SBAmtArea"></td></tr>
												<tr style="display: none;"><td id="comCostApp_AuditCntArea"></td></tr>
											</tbody>
										</table>
									</td>
									<td class="acc_total_r">
										<table class="total_table">
											<thead>
												<tr>			<!-- 증빙 총액  | 청구 금액 -->
													<th><spring:message code='Cache.ACC_lbl_eviTotalAmt'/><span id="comCostApp_lblTotalCnt"></span></th>
													<th><spring:message code='Cache.ACC_billReqAmt'/></th>
												</tr>
											</thead>
											<tbody>
												<tr>			<!-- 원 -->
													<td><span class="tx_ta" id="comCostApp_lblTotalAmt">0</span><spring:message code='Cache.ACC_krw'/></td>
													<td><span class="tx_ta" id="comCostApp_lblBillReqAmt">0</span><spring:message code='Cache.ACC_krw'/></td>
												</tr>
											</tbody>
										</table>
										<input type="hidden" id="comCostApp_TotalAmt"  name="ComCostAppInputField" tag="TotalAmt">
										<input type="hidden" id="comCostApp_RepAmt"  name="ComCostAppInputField" tag="ReqAmt">
									</td>
								</tr>
							</tbody>
						</table>
					</div>
					<div class="total_acooungting_info_wrap">
						<div class="card_nea_top_wrap">
							<div class="card_ea_left_select">
								<span class="selectType02 size233" id="combiCostApp_inputCompanyCode"
									onchange="CombineCostApplication<%=requestType%>.combiCostApp_companyComboChange(this)">
								</span>
								<span class="selectType02 size233" id="combiCostApp_inputProofCode" 
									onchange="CombineCostApplication<%=requestType%>.combiCostApp_evidComboChange(this)">
								</span>
							</div>
							<div class="card_nea_left_btn">
								<a class="btnTypeDefault btnTypeBg" href="#" id="combiCostApp_btnForLoadPopup" 
									onClick="CombineCostApplication<%=requestType%>.combiCostAppCC_CardInfoLoadPopup()">
									<spring:message code="Cache.ACC_btn_corpCardLoad"/>
								</a>
								<a class="btnTypeDefault btnTypeBg" href="#" id="combiCostApp_btnForXmlUpload" style="display: none;"
									onClick="CombineCostApplication<%=requestType%>.combiCostAppTB_TaxLoadXmlUpLoadPopup()">
									<spring:message code="Cache.ACC_btn_xml_upload"/>
								</a>
								<a class="btnTypeDefault" href="#" id="combiCostApp_btnForDelete" 
									onClick="CombineCostApplication<%=requestType%>.combiCostApp_pageListDelete()">
									<spring:message code="Cache.ACC_btn_delete"/>
								</a>
								<label>
									<input type="checkbox" id="chk_info" name="chk_info" class="card_nea_chk">
									<span class="card_nea_chk_tx"><spring:message code="Cache.ACC_btn_copy"/></span>
								</label>
							</div>
							<div class="card_nea_left_day">
								<dl class="write_info_list_dl">
									<dt><spring:message code='Cache.ACC_lbl_payDay' /></dt> <!-- 지급일 -->
									<dd>
										<span class="selectType02" id="combiCostApp_defaultPayDateList" 
											onchange="CombineCostApplication<%=requestType%>.combiCostApp_payDateComboChange(this)">
										</span>
										<span class="dateSel type02" id='combiCostApp_defaultPayDateInput' style="display: none;" 
											onchange="CombineCostApplication<%=requestType%>.combiCostApp_makePayDate('E')">
										</span>
									</dd>
								</dl>
							</div>
							<div class="card_ea_left_select">
								<input type="hidden"  id="comCostApp_Sub_UR_Code" name="ComCostAppInputField" tag="Sub_UR_Code" NO_INIT="Y">
								<input type="hidden"  id="comCostApp_Sub_UR_Info" name="ComCostAppInputField" tag="Sub_UR_Info" NO_INIT="Y">
							</div>
							<%-- <a href="#" class="btn_taw_close" onClick="CombineCostApplication<%=requestType%>.combiCostApp_inputAreaFolding(this)" ></a> --%>
						</div>
						<div id="comCostApp_inputAreaDiv">
							<div class="card_nea_wrap" id="corpCardArea" name="inputAreaDiv" proofcode="CorpCard">
								<%-- <jsp:include page="CombineCostApplicationCorpCard.jsp" flush="false"></jsp:include> --%>
								<ul class="card_nea_right_list" id="combiCostAppCC_TableArea" name="combiCostAppCC_TableArea">
								</ul>
							</div>
							<div class="card_nea_wrap" id="taxBillArea" name="inputAreaDiv" proofcode="TaxBill" style="display:none">
								<%-- <jsp:include page="CombineCostApplicationTaxBill.jsp" flush="false"></jsp:include> --%>
								<ul class="card_nea_right_list" id="combiCostAppTB_TableArea" name="combiCostAppTB_TableArea">
								</ul>
							</div>
							<div class="card_nea_wrap" id="paperBillArea" name="inputAreaDiv" proofcode="PaperBill" style="display:none">
								<%-- <jsp:include page="CombineCostApplicationMobileReceipt.jsp" flush="false"></jsp:include> --%>
								<ul class="card_nea_right_list" id="combiCostAppPB_TableArea" name="combiCostAppPB_TableArea">
								</ul>
							</div>
							<div class="card_nea_wrap" id="cashBillArea" name="inputAreaDiv" proofcode="CashBill" style="display:none">
								<%-- <jsp:include page="CombineCostApplicationCashBill.jsp" flush="false"></jsp:include> --%>
								<ul class="card_nea_right_list" id="combiCostAppCB_TableArea" name="combiCostAppCB_TableArea">
								</ul>
							</div>
							<div class="card_nea_wrap" id="privateCardArea" name="inputAreaDiv" proofcode="PrivateCard" style="display:none">
								<%-- <jsp:include page="CombineCostApplicationPrivateCard.jsp" flush="false"></jsp:include> --%>
								<ul class="card_nea_right_list" id="combiCostAppPC_TableArea" name="combiCostAppPC_TableArea">
								</ul>
							</div>
							<div class="card_nea_wrap" id="etcArea" name="inputAreaDiv" proofcode="EtcEvid" style="display:none">
								<%-- <jsp:include page="CombineCostApplicationEtcEvid.jsp" flush="false"></jsp:include> --%>
								<ul class="card_nea_right_list" id="combiCostAppEE_TableArea" name="combiCostAppEE_TableArea">
								</ul>
							</div>
							<div class="card_nea_wrap" id="mobileArea" name="inputAreaDiv" proofcode="Receipt" style="display:none">
								<%-- <jsp:include page="CombineCostApplicationMobileReceipt.jsp" flush="false"></jsp:include> --%>
								<ul class="card_nea_right_list" id="combiCostAppMR_TableArea" name="combiCostAppMR_TableArea">
								</ul>
							</div>
							<div class="card_nea_bottom_btn">
								<a class="btnTypeDefault btnTypeBg" href="#" 
									onclick="CombineCostApplication<%=requestType%>.combiCostApp_pageListSave()">
									<spring:message code='Cache.ACC_btn_save'/>
								</a>
							</div>
							<div class="card_nea_wrap">
								<a href="#" class="btn_taw_top_del" style="margin: 0" 
									onclick="CombineCostApplication<%=requestType%>.combiCostApp_evidItemDelete()">
									<spring:message code="Cache.ACC_btn_delete"/>
								</a>
							</div>
							<div class="total_acooungting_write_status" id="combiCostApp_evidListArea"></div>
							<div class="total_acooungting_write_status" id="combiCostApp_evidListAreaApv" style="display:none;"></div>
						</div>
						
						<!--웹 에디터-->
						<div>
							<div id="divWebEditor<%=requestType%>"></div>
						</div>
					</div>
				</div>
			</div>
		</div>		
		<!-- 컨텐츠 끝 -->
	
		<!-- 로딩 이미지  -->
		<div style="display: none; background: rgb(0, 0, 0); left: 0px; top: 0px; width: 100%; height: 1296px; position: fixed; z-index: 149; opacity: 0; filter: progid:DXImageTransform.Microsoft.Alpha(opacity=0); -ms-filter:'progid:DXImageTransform.Microsoft.Alpha(opacity=0)'; " id="loading_overlay"></div>
		<div id="divLoading" style="display: none; text-align:center;z-index:10;background-color:red;margin:0 auto;position:absolute; top:16%; left:50%; height:20px; margin-left:-10px; margin-top:-10px; ">
			<img src="/HtmlSite/smarts4j_n/covicore/resources/images/covision/loding12.gif" style="text-align:center;" alt=""/>
		</div>
		<input type="hidden" id="APVLIST_">
		<input type="hidden" id="RuleItemInfo" name="ComCostAppInputField" tag="RuleItemInfo" />
	</div>
	
	<!-- 전자결재 연동용 iframe -->
	<iframe id="goFormLink" src="" style="display: none;" title=""></iframe>
</body>
<script>

if (!window.CombineCostApplication<%=requestType%>) {
	window.CombineCostApplication<%=requestType%> = {};
}

//통합비용 신청 메인
//주요 기능들은 다 이 jsp파일에 존재
(function(window) {
	var isUseIO = Common.getBaseConfig("IsUseIO");
	var isUseSB = Common.getBaseConfig("IsUseStandardBrief");
	var isUseBD = "N";
	
	var requestType = "";
	var propertyOtherApv = "<%=propertyOtherApv%>";
	
	var CombineCostApplication<%=requestType%> = {
			pageOpenerIDStr : "openerID=CombineCostApplication<%=requestType%>&",
			pageName :  "CombineCostApplication<%=requestType%>",
			ApplicationType : "CO",
			pageCombiAppFormList : {
					CorpCardViewFormStr		: "",
					DivViewFormStr			: "",
					TaxBillViewFormStr		: "",
					PaperBillViewFormStr	: "",
					CashBillViewFormStr		: "",
					PrivateCardViewFormStr	: "",
					EtcEvidViewFormStr		: "",
					ReceiptViewFormStr		: "",

					CorpCardViewApvFormStr	: "",
					DivViewApvFormStr		: "",
					TaxBillViewApvFormStr	: "",
					TaxBillDivViewApvFormStr : "",
					PaperBillViewApvFormStr	: "",
					CashBillViewApvFormStr	: "",
					PrivateCardViewApvFormStr : "",
					EtcEvidViewApvFormStr	: "",
					ReceiptViewApvFormStr	: "",
					
					docLinkInputAreaStr		: "",
					CorpCardInputFormStr	: "",
					TaxBillInputFormStr		: "",
					PaperBillInputFormStr	: "",
					CashBillInputFormStr	: "",
					EtcEvidInputFormStr		: "",
					DivInputFormStr			: "",
					DocLinkInputFormStr		: "",
					VendorInputFormStr		: "",
					TaxBillItemInputFormStr	: ""
			},
			pageExpenceAppEvidList : [],
			pageExpenceAppEvidDeletedList : [],
			pageExpenceAppObj : {maxCdRownum:0},

			pageCombiAppComboData : {
				AccountCtrlList		: [],
				TaxTypeList			: [],
				TaxCodeList			: [],
				WHTaxList			: [],
				PayMethodList		: [],
				PayTypeList			: [],
				PayTargetList		: [],
				BankAccountList		: [],
				ProvideeList		: [],
				BillTypeList		: [],
				BriefList			: [],
				ExchangeNationList	: [],
				
				AccountCtrlMap		: {},
				TaxTypeMap			: {},
				TaxCodeMap			: {},
				WHTaxMap			: {},
				PayMethodMap		: {},
				PayTypeMap			: {},
				PayTargetMap		: {},
				AccountInfoMap		: {},
				ProvideeMap			: {},
				BillTypeMap			: {},
				BriefMap			: {},
				ExchangeNationMap	: {},
				
				DefaultCC			: {},
			},
			tempObj : {},
			maxViewKeyNo : 0,
			dataModified : false,
			openParam : {},
			CompanyCode : '',
			pageInit : function(inputParam) {
				var me = this;
				
				requestType = "<%=requestType%>";
				
				setHeaderTitle('headerTitle');
				
				if(inputParam != null){
					me.openParam = inputParam;
				}
				
				me.CompanyCode = accComm.getCompanyCodeOfUser(sessionObj["UR_Code"]);
				me.pageExpenceAppObj.CompanyCode = me.CompanyCode;
				
				accComm.getFormManageInfo(requestType, me.CompanyCode);
				me.noteIsUse = accComm.getNoteIsUse(me.CompanyCode, requestType, 'divWebEditor' + requestType);
				me.exchangeIsUse = accComm.getExchangeIsUse(me.CompanyCode, requestType);
				
				accountCtrl.getInfo('combiCostApp_evidListArea').html("");
				accountCtrl.getInfo('combiCostApp_evidListAreaApv').html("");
				
				makeDatepicker("combiCostApp_defaultPayDateInput", "combiCostApp_defaultPayDateInput_Date", null, null, null, 100);
				
				//필요 데이터들 초기 조회
				me.combiCostApp_comboInit();
				me.combiCostApp_FormInit();
				me.combiCostApp_FormComboDataInit();
				accComm.setDeadlineInfo();
				me.combiCostApp_getDefaultCC();
				me.combiCostApp_PropertyInit();
				
				//각 세부 페이지 초기화
				me.combiCostAppCC_CorpCardPageInit();
				me.combiCostAppTB_TaxBillPageInit();
				me.combiCostAppPB_PaperBillPageInit();
				me.combiCostAppCB_CashBillPageInit();
				me.combiCostAppPC_PrivateCardPageInit();
				me.combiCostAppEE_EtcEvidPageInit();
				me.combiCostAppMR_ReceiptPageInit();
				
				me.combiCostApp_setModified(false);
				accountCtrl.getInfo("comCostApp_lblApplicator").html(Common.getSession().USERNAME);
				
				accountCtrl.getInfoStr("[name=inputAreaDiv]").css("border-bottom", "none");

				var isSearch = "";
				var ExpAppId = "";
				if(inputParam != null){
					isSearch = inputParam.isSearch;
					ExpAppId = inputParam.ExpAppId;
				}
				if(isSearch=="Y"){
					me.combiCostApp_searchPageData(ExpAppId);
				}
				else{
					accountCtrl.getInfo('comCostApp_Sub_UR_Code').val(sessionObj.USERID);
					accountCtrl.getInfo('comCostApp_Sub_UR_Info').val(sessionObj.UR_JobPositionCode);
					me.setEditor("");
				}
			   	<%
				if(propertyAprv==null){
					propertyAprv = "";
				}
				if("".equals(propertyAprv)){
				%>
					accountCtrl.getInfoStr(".BC_File_btn .btn_Dlink").hide();
				<%
				}
				%>
								
				me.combiCostApp_comboDataInit(); //담당업무, 지급희망일 등 select box 바인딩

				if(propertyOtherApv != "Y") {
					var strMode = "";
					var processID = null;
					
					if(inputParam != null && inputParam.isReview == "Y") {
						strMode = "COMPLETE";
						processID = me.pageExpenceAppObj.ProcessID;
					} else {
						strMode = "DRAFT";
						accountCtrl.getInfoName("apvLineBtn").show();
						
						//전결규정 버튼
						if (Common.getBaseConfig("RuleBtnApvMgr") != "Y") { 
							var ruleitemlist = getInfo("RuleInfo");
							if (ruleitemlist != "" && ruleitemlist != "[]" && ruleitemlist != undefined) {
								// 본인 회사 기준 체크
								var oTemp = JSON.parse(ruleitemlist).filter(function(rule) {
									return rule.DNCode == Common.getSession("DN_Code");
								});
								// 그룹사 기준 체크 > 전결규정 팝업에서 본인회사것만 나오므로 통일
								/*
								if (oTemp.length == 0) {
									oTemp = JSON.parse(ruleitemlist).filter(function(rule) {
										return rule.DNCode == "ORGROOT";
									});
								}
								*/
								if(oTemp.length > 0) accountCtrl.getInfoName("ruleApvbtn").show();
							}
						}
					}
					
					g_dicFormInfo = new Dictionary();
					g_dicFormInfo.Add("Request.mode", strMode);
					g_dicFormInfo.Add("etid","A1");
					
					//최종결재선 지정
					setWorkedAutoDomainData(accComm[requestType].pageExpenceFormInfo.FormPrefix, strMode, ExpAppId, processID);
				}
				
				/* if(accountCtrl.getInfo("comCostApp_ApplicationTitle").val() == "") {
					accountCtrl.getInfo("comCostApp_ApplicationTitle").val(setApplicationTitle());
				} */
				
				// 증빙유형 별 버튼 표시되도록 호출
				// 다른 데이터 init 함수타기 전에 호출 시 결재선이 그려지지 않아 소스 위치 이동함.
				me.combiCostApp_evidComboChange(accountCtrl.getComboInfo("combiCostApp_inputProofCode")[0]);
			},
			pageView : function(inputParam) {
				var me = this;
				
				requestType = "<%=requestType%>";

				if(inputParam != null){
					$.extend(me.openParam, inputParam);
				}
				
				me.combiCostApp_comboRefresh();
				
				var openType = "";
				var isSearch = "";
				var ExpAppId = "";
				if(inputParam != null){
					openType = inputParam.name
					isSearch = inputParam.isSearch;
					ExpAppId = inputParam.ExpAppId
				}

				formJson = $.extend({}, formJson, accComm[requestType].pageExpenceFormInfo);
				//$.extend(formJson, {"RuleInfo" : formJson.RuleInfo.replace(/item/gi, 'ruleitem')});
				if(getInfo("RuleInfo") && getInfo("RuleInfo").indexOf("ruleitem") == -1) setInfo("RuleInfo", getInfo("RuleInfo").replace(/item/gi, 'ruleitem'));
								
				//탭이동일시 아무작업 안함
				if(openType == "tabDivTitle"){
					return;
				}
				//새로작성이면 작업 물어보고 
				else if(openType=="LeftSub"){
					if(me.dataModified){
						Common.Confirm("<spring:message code='Cache.ACC_msg_initDataCk' />", "Confirmation Dialog", function(result){
							if(result){
								me.combiCostApp_setNew();
							}
						});
					}
					else{
						me.combiCostApp_setNew();
					}
					
				}
				else if(openType=="search"){
					me.combiCostAppCC_CorpCardDataInit();
					me.combiCostAppTB_TaxBillDataInit();
					me.combiCostAppPB_PaperBillPageInit();
					me.combiCostAppCB_CashBillDataInit();
					me.combiCostAppEE_EtcEvidDataInit();
					me.combiCostAppPC_PrivateCardDataInit();
					me.combiCostAppMR_ReceiptDataInit();
					me.combiCostApp_pageDataInit();
					if(isSearch=="Y"){
						me.combiCostApp_searchPageData(ExpAppId);
					}
				}
			},
			
			//신규작성 세팅
			combiCostApp_setNew : function() {
				var me = this;
				me.combiCostAppCC_CorpCardDataInit();
				me.combiCostAppTB_TaxBillDataInit();
				me.combiCostAppPB_PaperBillPageInit();
				me.combiCostAppCB_CashBillDataInit();
				me.combiCostAppEE_EtcEvidDataInit();
				me.combiCostAppPC_PrivateCardDataInit();
				me.combiCostAppMR_ReceiptDataInit();
				
				me.combiCostApp_pageDataInit();
				me.combiCostApp_pageAmtSet();
				me.combiCostApp_setModified(false);
				
			},
			
			//화면 데이터들 초기화
			combiCostApp_pageDataInit : function() {
				var me = this;
				me.combiCostApp_setModified(false);
				me.pageExpenceAppEvidList = [];
				me.pageExpenceAppEvidDeletedList = [];
				me.pageExpenceAppObj = {};

				me.combiCostAppCC_CorpCardDataInit();
				me.combiCostAppTB_TaxBillDataInit();
				me.combiCostAppPB_PaperBillPageInit();
				me.combiCostAppCB_CashBillDataInit();
				me.combiCostAppEE_EtcEvidDataInit();
				me.combiCostAppPC_PrivateCardDataInit();
				me.combiCostAppMR_ReceiptDataInit();

				var fieldList =  accountCtrl.getInfoName("ComCostAppInputField");
			   	for(var i=0;i<fieldList.length; i++){
			   		var field = fieldList[i];
			   		var tag = field.getAttribute("tag")
			   		field.value="";
			   	}
				accountCtrl.getInfo("combiCostApp_evidListArea").html("");
				accountCtrl.getInfo("combiCostApp_evidListAreaApv").html("");
				accountCtrl.getInfoName("saveBtn").css("display","");
				accountCtrl.getInfoName("afterSaveBtn").css("display","none");
				
			},
			combiCostApp_comboInit : function() {
				var me = this;
				
				var AXSelectMultiArr = [	
					{'codeGroup':'ProofCode', 'target':'combiCostApp_inputProofCode', 'lang':'ko', 'onchange':'', 'oncomplete':'', 'defaultVal':''}
				]
				accountCtrl.renderAXSelectMulti(AXSelectMultiArr, me.CompanyCode);
				
				accComm.setComboByProofInfo(requestType, 'combiCostApp_inputProofCode', me.CompanyCode);
			},
			combiCostApp_comboRefresh : function() {
				accountCtrl.refreshAXSelect("combiCostApp_inputProofCode");
				accountCtrl.refreshAXSelect("combiCostApp_inputCompanyCode");
				accountCtrl.refreshAXSelect("combiCostApp_defaultPayDateList");
			},
			combiCostApp_comboDataInit : function() {
				var me = this;

				var payDateDefaultVal = "";
				var companyCodeDefaultVal = "";
				
				if(typeof me.pageExpenceAppObj != "undefined") {
					if(typeof me.pageExpenceAppObj.PayDateType != "undefined") {
						payDateDefaultVal = me.pageExpenceAppObj.PayDateType;
					}
					if(typeof me.pageExpenceAppObj.CompanyCode != "undefined") {
						companyCodeDefaultVal = me.pageExpenceAppObj.CompanyCode;
					}
				}
				
				var AXSelectMultiArr = [	
					{'codeGroup':'DefaultPayDate', 'target':'combiCostApp_defaultPayDateList', 'lang':'ko', 'onchange':'', 'oncomplete':'', 'defaultVal':payDateDefaultVal, 'useDefault':"<spring:message code='Cache.lbl_Select' />"},
					{'codeGroup':'CompanyCode', 'target':'combiCostApp_inputCompanyCode', 'lang':'ko', 'onchange':'', 'oncomplete':'', 'defaultVal':companyCodeDefaultVal}
				]
				accountCtrl.renderAXSelectMulti(AXSelectMultiArr, me.CompanyCode);
				
				//법인 선택 시 그룹사(공용)은  선택 불가
				accountCtrl.getComboInfo("combiCostApp_inputCompanyCode").find("option[value='ALL']").remove();
				accountCtrl.refreshAXSelect("combiCostApp_inputCompanyCode");
				
				accountCtrl.getComboInfo("combiCostApp_defaultPayDateList").val(payDateDefaultVal);
				accountCtrl.getComboInfo("combiCostApp_inputCompanyCode").val(companyCodeDefaultVal);
				
				me.combiCostApp_payDateComboChange(payDateDefaultVal);
			},

			combiCostApp_SubCodeSet : function (pType) {
				var me = this;
				var rslt;
				$.ajax({
					type:"POST",
						url:"/account/accountCommon/getBaseCodeSubSet.do",
					data:{
						codeGroups: pType,
						CompanyCode : me.CompanyCode
					},
					async:false,
					success:function (data) {
						if(data.result == "ok"){
							var codeList = data.list
							
							rslt = codeList;
						}
						else{
							Common.Error(data);
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의바랍니다.
					}
				});
				
				return rslt;
			}, 

			//form에 사용할 콤보데이터 조회
			combiCostApp_FormComboDataInit : function() {
				var me = this;
				//관리항목 조회
				$.ajax({
					type:"POST",
						url:"/account/accountCommon/getBaseCodeData.do",
					data:{
						codeGroups : "AccountCtrl,ExchangeNation",
						CompanyCode : me.CompanyCode
					},
					async: false,
					success:function (data) {
						if(data.result == "ok"){
							var codeList = data.list;
							if(codeList.hasOwnProperty('AccountCtrl'))
							{
								me.pageCombiAppComboData.AccountCtrlList = codeList.AccountCtrl;
								me.combiCostApp_makeCodeMap(me.pageCombiAppComboData.AccountCtrlList, "AccountCtrl", "Code", "CodeName");
							}
							if(codeList.hasOwnProperty('ExchangeNation') && me.exchangeIsUse == "Y")
							{
								me.pageCombiAppComboData.ExchangeNationList = codeList.ExchangeNation;
								me.combiCostApp_makeCodeMap(me.pageCombiAppComboData.ExchangeNationList, "ExchangeNation", "Code", "CodeName");
							}
						}
						else{
							Common.Error(data);
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
					}
				});
				$.ajax({
					type:"POST",
					url:"/account/expenceApplication/getTaxCodeCombo.do",
					data:{
						CompanyCode : me.CompanyCode
					},
					async:false,
					success:function (data) {
						if(data.result == "ok"){
							me.pageCombiAppComboData.TaxCodeList = data.list
							me.combiCostApp_makeCodeMap(me.pageCombiAppComboData.TaxCodeList, "TaxCode", "Code", "CodeName");
						}
						else{
							Common.Error(data);
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의바랍니다.
					}
				});
				$.ajax({
					type:"POST",
						url:"/account/accountCommon/getBaseCodeDataAll.do",
					data:{
						codeGroups : "TaxType,WHTax,PayMethod,PayType,PayTarget,BillType,CompanyCode",
						CompanyCode : me.CompanyCode
					},
					async:false,
					success:function (data) {
						if(data.result == "ok"){
							var codeList = data.list
							me.pageCombiAppComboData.TaxTypeList = codeList.TaxType;
							
							for(var i = 0; i < codeList.PayMethod.length; i++) {
								if(codeList.PayMethod[i].Code == "T") {
									codeList.PayMethod.splice(i);
								}
							}
							
							me.pageCombiAppComboData.PayMethodList = codeList.PayMethod;
							me.pageCombiAppComboData.PayTypeList = codeList.PayType;
							me.pageCombiAppComboData.PayTargetList = codeList.PayTarget;

							me.pageCombiAppComboData.WHTaxList = codeList.WHTax;
							
							me.pageCombiAppComboData.ProvideeList = codeList.CompanyCode;
							me.pageCombiAppComboData.BillTypeList = codeList.BillType;
							
							me.combiCostApp_makeCodeMap(me.pageCombiAppComboData.TaxTypeList, "TaxType", "Code", "CodeName");
							me.combiCostApp_makeCodeMap(me.pageCombiAppComboData.PayMethodList, "PayMethod", "Code", "CodeName");
							me.combiCostApp_makeCodeMap(me.pageCombiAppComboData.PayTypeList, "PayType", "Code", "CodeName");
							me.combiCostApp_makeCodeMap(me.pageCombiAppComboData.PayTargetList, "PayTarget", "Code", "CodeName");
							me.combiCostApp_makeCodeMap(me.pageCombiAppComboData.WHTaxList, "WHTax", "Code", "CodeName", true, true, false, false, true);
							me.combiCostApp_makeCodeMap(me.pageCombiAppComboData.ProvideeList, "Providee", "Code", "CodeName");
							me.combiCostApp_makeCodeMap(me.pageCombiAppComboData.BillTypeList, "BillType", "Code", "CodeName");
							
							me.combiCostApp_FormComboInit();
						}
						else{
							Common.Error(data);
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의바랍니다.
					}
				});

				$.ajax({
					type:"POST",
					url:"/account/expenceApplication/getUserBankAccount.do",
					data:{
					},
					async:false,
					success:function (data) {
						if(data.result == "ok"){
							me.pageCombiAppComboData.BankAccountList = data.list;
							me.combiCostApp_makeCodeMap(me.pageCombiAppComboData.BankAccountList, "AccountInfo", "BankAccountNo", "BankAccountView");
							
							me.combiCostApp_FormComboInit();
						}
						else{
							Common.Error(data);
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의바랍니다.
					}
				});

				$.ajax({
					type:"POST",
					url:"/account/expenceApplication/getBriefCombo.do",
					data:{
						CompanyCode : me.CompanyCode
					},
					success:function (data) {
						if(data.result == "ok"){
							var codeList = data.list;
							me.pageCombiAppComboData.BriefList = data.list;
							me.combiCostApp_makeCodeMap(data.list, "Brief", "StandardBriefID");
						}
						else{
							Common.Error("<spring:message code='Cache.ACC_msg_error' />");	//오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />");	//오류가 발생했습니다. 관리자에게 문의 바랍니다.
					}
				});
				//업종관리데이터 조회
				$.ajax({
					type:"POST",
					url:"/account/expenceApplication/getStoreCategoryCombo.do",
					data:{
						CompanyCode : me.CompanyCode
					},
					async:false,
					success:function (data) {
						if(data.result == "ok"){
							var codeList = data.list;
							me.pageCombiAppComboData.StoreCategoryList = data.list;
						}
						else{
							Common.Error(data);
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의바랍니다.
					}
				});
			},

			combiCostApp_getDefaultCC : function() {
				var me = this;
				$.ajax({
					url:"/account/expenceApplication/getUserCC.do",
					cache: false,
					data:{
					},
					success:function (data) {
						
						if(data.result == "ok"){
							var getData = data.CCInfo
							if(getData != null){
								me.pageCombiAppComboData.DefaultCC.CostCenterCode = getData.CostCenterCode;
								me.pageCombiAppComboData.DefaultCC.CostCenterName = getData.CostCenterName;
							}
						}
						else{
							//Common.Error("<spring:message code='Cache.ACC_msg_error' />");
						}
					},
					error:function (error){
						//Common.Error("<spring:message code='Cache.ACC_msg_error' />");
					}
				});
			},
			
			//인터페이스 프로퍼티 조회
			combiCostApp_PropertyInit : function(){
				var me = this
				setPropertySearchType('CardReceipt','comCostApp_PropertyCardReceipt');
				setPropertySearchType('TaxInvoice','comCostApp_PropertyTaxInvoice');
				setPropertySearchType('CostCenter','comCostApp_PropertyCostCenter');
				setPropertySearchType('AccountManage','comCostApp_PropertyAccount');
				setPropertySearchType('Budget','comCostApp_PropertyBudget'); //예산관리 사용여부
				
				isUseBD = accountCtrl.getInfo("comCostApp_PropertyBudget").val();
			},
			
			//폼의 콤보데이터 세팅
			combiCostApp_FormComboInit : function(){
				var me = this
				
				var PayMethodOptionsStr = me.combiCostApp_ComboDataMake(me.pageCombiAppComboData.PayMethodList);
				var PayTypeOptionsStr = me.combiCostApp_ComboDataMake(me.pageCombiAppComboData.PayTypeList);
				var PayTargetOptionsStr = me.combiCostApp_ComboDataMake(me.pageCombiAppComboData.PayTargetList);
				var TaxTypeOptionsStr = me.combiCostApp_ComboDataMake(me.pageCombiAppComboData.TaxTypeList);
				
				var IncomeTaxOptionStrEE = me.combiCostApp_TaxComboDataMake(me.pageCombiAppComboData.WHTaxList, "E1");
				var LocalTaxOptionStrEE = me.combiCostApp_TaxComboDataMake(me.pageCombiAppComboData.WHTaxList, "E2");
				
				var BankAccountOptionsStr = me.combiCostApp_BankComboDataMake(me.pageCombiAppComboData.BankAccountList, "BankAccountNo", "BankAccountView");

				var ProvideeOptionsStr = me.combiCostApp_ComboDataMake(me.pageCombiAppComboData.ProvideeList);
				var BillTypeOptionsStr = me.combiCostApp_ComboDataMake(me.pageCombiAppComboData.BillTypeList);
				
				var ExchangeNationOptionsStr =  me.exchangeIsUse == "Y" ? me.combiCostApp_ComboDataMake(me.pageCombiAppComboData.ExchangeNationList, "Code", "CodeName") : "";
				
				for(var formNm in me.pageCombiAppFormList){
					var formStr = me.pageCombiAppFormList[formNm];

					formStr = formStr.replace("@@{PayMethodOptions}", PayMethodOptionsStr);
					formStr = formStr.replace("@@{PayTypeOptions}", PayTypeOptionsStr);
					formStr = formStr.replace("@@{PayTargetOptions}", PayTargetOptionsStr);

					formStr = formStr.replace("@@{TaxTypeOptions}", TaxTypeOptionsStr);
					
					formStr = formStr.replace("@@{IncomeTaxOptions}", IncomeTaxOptionStrEE);
					formStr = formStr.replace("@@{LocalTaxOptions}", LocalTaxOptionStrEE);
					
					formStr = formStr.replace("@@{BankAccountOptions}", BankAccountOptionsStr);

					formStr = formStr.replace("@@{ProvideeOptions}", ProvideeOptionsStr);
					formStr = formStr.replace("@@{BillTypeOptions}", BillTypeOptionsStr);
					
					formStr = me.exchangeIsUse == "Y" ? formStr.replace("@@{ExchangeNationOptions}", ExchangeNationOptionsStr) : formStr;
					
					me.pageCombiAppFormList[formNm] = formStr;
				}
			},

			//콤보데이터 html 생성
			combiCostApp_ComboDataMake : function(cdList, codeField, nameField) {
				if(cdList==null){
					return;
				}
				if(codeField==null){
					codeField="Code"
				}
				if(nameField==null){
					nameField="CodeName"
				}
				var htmlStr = "<option value=''>"+ "<spring:message code='Cache.ACC_lbl_choice' />" +"</option>";
				for(var i = 0; i<cdList.length; i++){
					var getCd = cdList[i];
					if(getCd.IsUse == "Y"
							||getCd.IsUse == null
							||getCd.IsUse == ""){
						htmlStr = htmlStr + "<option value='"+ getCd[codeField] +"'>"+ getCd[nameField] +"</option>"
					}
				}
				return htmlStr;
			},
			
			//텍스코드 콤보 생성
			combiCostApp_TaxComboDataMake : function(cdList, Type) {
				var me = this;
				var htmlStr = "<option value=''>"+ "<spring:message code='Cache.ACC_lbl_choice' />" +"</option>";
				for(var i = 0; i<cdList.length; i++){
					var getCd = cdList[i];
					if(getCd.Reserved1 == Type){
						if(getCd.IsUse == "Y"
								||getCd.IsUse == null
								||getCd.IsUse == ""){
							htmlStr = htmlStr + "<option value='"+ getCd.Code +"' tag='" + JSON.stringify(getCd) + "'>"+ getCd.CodeName +"</option>"
						}
					}
				}
				return htmlStr;
			},
			
			//은행계좌 combo box 생성
			combiCostApp_BankComboDataMake : function(cdList, codeField, nameField) {
				if(cdList==null){
					return;
				}
				var htmlStr = "<option value=''>"+ "<spring:message code='Cache.ACC_lbl_choice' />" +"</option>";
				for(var i = 0; i<cdList.length; i++){
					var getCd = cdList[i];
					htmlStr = htmlStr + "<option value='"+ getCd[codeField] +"' data='" + JSON.stringify(getCd) + "'>"+ getCd[nameField] +"</option>";
				}
				return htmlStr;
			},
			
			//코드 map를 사전에 만들어둬서 코드로 코드명 찾는 로직 단순화
			CODEMAPSTR : "me.pageCombiAppComboData.",
			combiCostApp_makeCodeMap : function(List, name, dataField, labelField) {
				var me = this;
				for(var i = 0; i<List.length; i++){
					var item = List[i];
					
					//var evalStr = me.CODEMAPSTR+name+"Map[item[dataField]] = item";
					//eval(evalStr);
					me.pageCombiAppComboData[name+"Map"][item[dataField]] = item;
				}
			},
			
			//html 폼 조회
			combiCostApp_FormInit : function() {
				var me = this;
				var formPath = Common.getBaseConfig("AccountApplicationFormPath");
				
				$.ajaxSetup({async:false});
				
				var formList = {
						CorpCardViewFormStr 		: "CombiCostApp_ViewForm_CorpCard.html",
						DivViewFormStr 				: "CombiCostApp_ViewForm_Div.html",
						TaxBillViewFormStr 			: "CombiCostApp_ViewForm_TaxBill.html",
						PaperBillViewFormStr 		: "CombiCostApp_ViewForm_PaperBill.html",
						CashBillViewFormStr 		: "CombiCostApp_ViewForm_CashBill.html",
						PrivateCardViewFormStr 		: "CombiCostApp_ViewForm_PrivateCard.html",
						EtcEvidViewFormStr 			: "CombiCostApp_ViewForm_EtcEvid.html",
						ReceiptViewFormStr 			: "CombiCostApp_ViewForm_Receipt.html",
						
						CorpCardViewApvFormStr 		: "CombiCostApp_ViewForm_CorpCard_Apv.html",
						DivViewApvFormStr 			: "CombiCostApp_ViewForm_Div_Apv.html",
						TaxBillViewApvFormStr 		: "CombiCostApp_ViewForm_TaxBill_Apv.html",
						TaxBillDivViewApvFormStr 	: "CombiCostApp_ViewForm_TaxBillDiv_Apv.html",
						PaperBillViewApvFormStr 	: "CombiCostApp_ViewForm_PaperBill_Apv.html",
						CashBillViewApvFormStr 		: "CombiCostApp_ViewForm_CashBill_Apv.html",
						PrivateCardViewApvFormStr 	: "CombiCostApp_ViewForm_PrivateCard_Apv.html",
						EtcEvidViewApvFormStr 		: "CombiCostApp_ViewForm_EtcEvid_Apv.html",
						ReceiptViewApvFormStr 		: "CombiCostApp_ViewForm_Receipt_Apv.html",
						
						CorpCardInputFormStr 		: "CombiCostApp_InputForm_CorpCard.html",
						TaxBillInputFormStr 		: "CombiCostApp_InputForm_TaxBill.html",
						PaperBillInputFormStr 		: "CombiCostApp_InputForm_PaperBill.html",
						CashBillInputFormStr 		: "CombiCostApp_InputForm_CashBill.html",
						PrivateCardInputFormStr 	: "CombiCostApp_InputForm_PrivateCard.html",
						EtcEvidInputFormStr 		: "CombiCostApp_InputForm_EtcEvid.html",
						ReceiptInputFormStr 		: "CombiCostApp_InputForm_Receipt.html",
						DivInputFormStr 			: "CombiCostApp_InputForm_DivTableForm.html",
						DocLinkInputFormStr 		: "CombiCostApp_InputForm_DocLink.html",
						VendorInputFormStr 			: "CombiCostApp_InputForm_Vendor.html",
						TaxBillItemInputFormStr 	: "CombiCostApp_InputForm_TaxBillItem.html"
				}
				
       	    	Object.keys(formList).forEach(function(e) {
					$.get(formPath + formList[e] + resourceVersion, function(val){
						me.pageCombiAppFormList[e] = val;
					});
    	        });
			},
			
			combiCostApp_payDateComboChange : function(obj) {
				var me = this;
				
				var getType = "";
				if(typeof(obj) == "object") getType = obj.value;
				else if(typeof(obj) == "string") getType = obj;
				
				if(getType==null || getType==""){
					return;
				}
				
				me.pageExpenceAppObj.PayDateType = getType;
				
				var payDateInput = accountCtrl.getInfo("combiCostApp_defaultPayDateInput");
				
				if(getType == "E") { //기타					
					$(payDateInput).show();
				} else {
					$(payDateInput).hide();
				}
					
				me.combiCostApp_makePayDate(getType);
				
				accountCtrl.refreshAXSelect("combiCostApp_defaultPayDateList");
			},
			
			combiCostApp_makePayDate : function(getType) {
				var me = this;
				
				if(getType == "E") { //기타
					if(accountCtrl.getInfo("combiCostApp_defaultPayDateInput_Date").val() != "") {
						me.pageExpenceAppObj.PayDate = accountCtrl.getInfo("combiCostApp_defaultPayDateInput_Date").val().replace(/\./gi, '')
						me.pageExpenceAppObj.PayDateStr = accountCtrl.getInfo("combiCostApp_defaultPayDateInput_Date").val();
					}
				} else {
					var date = new Date();
					if(getType == "M") { //15일
						var day = date.getDate();
						date.setDate("15");
						
						if(day > 15) { //15일 이후에 저장된 내역은 다음달로
							date.setMonth(date.getMonth()+1);
						}						
					} else if(getType == "L") { //말일
						var lastDate = new Date(date.getYear(), date.getMonth()+1, 0);					
						date.setDate(lastDate.getDate());		
					} else {
						var etcPayDate = parseInt(getType); 
						if(!isNaN(etcPayDate)){
							var day = date.getDate();
							date.setDate(getType);
							
							if(day > etcPayDate) { //지정일 이후에 저장된 내역은 다음달로
								date.setMonth(date.getMonth()+1);
							}
						}
					}
					
					me.pageExpenceAppObj.PayDate = date.format("yyyyMMdd");
					me.pageExpenceAppObj.PayDateStr = date.format("yyyy.MM.dd");
				}
				me.pageExpenceAppObj.RealPayDate = me.pageExpenceAppObj.PayDate;
				
				for(var i = 0; i < me.pageExpenceAppEvidList.length; i++) {
					me.pageExpenceAppEvidList[i].RealPayDate = me.pageExpenceAppObj.PayDate;
					me.pageExpenceAppEvidList[i].PayDate = me.pageExpenceAppObj.PayDate;
					me.pageExpenceAppEvidList[i].PayDateStr = me.pageExpenceAppObj.PayDateStr;
				}
					
				accountCtrl.getInfoName("payDateArea").html(me.pageExpenceAppObj.PayDateStr);
			},
			
			//증빙 콤보 변경시 로직
			combiCostApp_evidComboChange : function(obj) {
				var me = this;
				var getType = obj.value;
				if(getType==null || obj.tagName !="SELECT"){
					return;
				}
				
				var btn = accountCtrl.getInfo("combiCostApp_btnForLoadPopup");
				var btnClickFun = "";
				var btnText = "";
				
				switch(getType) {
				case "CorpCard":
					btnClickFun = "combiCostAppCC_CardInfoLoadPopup";
					btnText = "<spring:message code='Cache.ACC_btn_corpCardLoad'/>";
					accountCtrl.getInfo("combiCostApp_btnForXmlUpload").hide();
					accountCtrl.getInfo("combiCostApp_btnForDelete").show();
					accountCtrl.getInfo("chk_info").parent().show();
					break;
				case "TaxBill":
					btnClickFun = "combiCostAppTB_TaxLoadPopup";
					btnText = "<spring:message code='Cache.ACC_btn_taxBillLoad'/>";
					accountCtrl.getInfo("combiCostApp_btnForXmlUpload").show();
					accountCtrl.getInfo("combiCostApp_btnForDelete").hide();
					accountCtrl.getInfo("chk_info").prop("checked", false);
					accountCtrl.getInfo("chk_info").parent().hide();
					break;
				case "PaperBill":
					btnClickFun = "combiCostAppPB_itemAdd";
					btnText = "<spring:message code='Cache.ACC_btn_paperBillAdd'/>";
					accountCtrl.getInfo("combiCostApp_btnForXmlUpload").hide();
					accountCtrl.getInfo("combiCostApp_btnForDelete").hide();
					accountCtrl.getInfo("chk_info").prop("checked", false);
					accountCtrl.getInfo("chk_info").parent().hide();
					break;
				case "CashBill":
					btnClickFun = "combiCostAppCB_cashPopupLoad";
					btnText = "<spring:message code='Cache.ACC_btn_cashBillLoad'/>";
					accountCtrl.getInfo("combiCostApp_btnForXmlUpload").hide();
					accountCtrl.getInfo("combiCostApp_btnForDelete").show();
					accountCtrl.getInfo("chk_info").prop("checked", false);
					accountCtrl.getInfo("chk_info").parent().hide();
					break;
				case "PrivateCard":
					btnClickFun = "combiCostAppPC_itemAdd";
					btnText = "<spring:message code='Cache.ACC_btn_privateCardLoad'/>";
					accountCtrl.getInfo("combiCostApp_btnForXmlUpload").hide();
					accountCtrl.getInfo("combiCostApp_btnForDelete").hide();
					accountCtrl.getInfo("chk_info").prop("checked", false);
					accountCtrl.getInfo("chk_info").parent().hide();
					break;
				case "EtcEvid":
					btnClickFun = "combiCostAppEE_itemAdd";
					btnText = "<spring:message code='Cache.ACC_btn_etcEvidAdd'/>";
					accountCtrl.getInfo("combiCostApp_btnForXmlUpload").hide();
					accountCtrl.getInfo("combiCostApp_btnForDelete").hide();
					accountCtrl.getInfo("chk_info").prop("checked", false);
					accountCtrl.getInfo("chk_info").parent().hide();
					break;
				case "Receipt":
					btnClickFun = "combiCostAppMR_ReceiptInfoLoadPopup";
					btnText = "<spring:message code='Cache.ACC_btn_mobileReceiptLoad'/>";
					accountCtrl.getInfo("combiCostApp_btnForXmlUpload").hide();
					accountCtrl.getInfo("combiCostApp_btnForDelete").show();
					accountCtrl.getInfo("chk_info").prop("checked", false);
					accountCtrl.getInfo("chk_info").parent().hide();
					break;
				}
				$(btn).attr('onclick', '').unbind('click');
				$(btn).on({"click": function() {
						me[btnClickFun]();
				    }
				});
				$(btn).html(btnText);
				
				if(me.pageCombiAppFormList[getType+"InputFormStr"].search(/\{*Options\}/) > 0) {
					me.combiCostApp_FormComboInit();					
				}
				me.combiCostAppCC_CorpCardDataInit();
				me.combiCostAppTB_TaxBillDataInit();
				me.combiCostAppCB_CashBillDataInit();
				me.combiCostAppEE_EtcEvidDataInit();
				me.combiCostAppPC_PrivateCardDataInit();
				me.combiCostAppMR_ReceiptDataInit();
				
				accountCtrl.getInfoName("inputAreaDiv").css("display", "none");
				accountCtrl.getInfoStr("[name=inputAreaDiv][proofcode="+getType+"]").css("display", "");
								
				if(getType=="PrivateCard"){
					me.combiCostAppPC_itemAdd()
				}else if(getType=="EtcEvid"){
					me.combiCostAppEE_itemAdd()
				}else if(getType=="PaperBill"){
					me.combiCostAppPB_itemAdd()
				}
				
			},
			
			combiCostApp_companyComboChange : function(obj) {
				var me = this;
				
				Common.Confirm("법인(사업장) 변경 시 입력하신 내용이 초기화 됩니다. 계속하시겠습니까?", "Confirmation Dialog", function(result){
		       		if(result){
		       			me.combiCostApp_setNew();
		       			
						me.CompanyCode = obj.value;
		       			me.pageExpenceAppObj.maxCdRownum = 0;
		       			me.pageExpenceAppObj.CompanyCode = obj.value;
		       			
		       			me.combiCostApp_comboInit();
		       			me.combiCostApp_comboDataInit();
		       			me.combiCostApp_FormComboDataInit();

		       		}
				});
			},

			//////////////////////////////////
			//상세조회 일 시 조회된 모든 증빙의 조회폼html 생성
			combiCostApp_makeHtmlViewFormAll : function(){
				var me = this;

				accountCtrl.getInfo("combiCostApp_evidListArea").html("");
				
				for(var i = 0; i<me.pageExpenceAppEvidList.length; i++){
					var getItem = me.pageExpenceAppEvidList[i];
					
					var htmlStr = me.combiCostApp_makeViewHtmlForm(getItem);

					htmlStr = "<tbody id='combiCostApp_evidItemArea_"+getItem.ViewKeyNo+"'"
							+ " name='evidItemArea' viewkeyno='"+getItem.ViewKeyNo+"'>"
							+ htmlStr
							+ "</tbody>";
					
					if(accountCtrl.getInfoStr("[name=evidItemTable][proofcode="+getItem.ProofCode+"]").length == 0) {
						htmlStr = "<p class='taw_top_sub_title'>"+Common.getDic("ACC_lbl_"+getItem.ProofCode+"UseInfo")+"</p>"
								+ "<table class='acstatus_wrap' id='combiCostApp_evidItemTable_"+getItem.ProofCode+"'"
								+ " name='evidItemTable' proofcode='"+getItem.ProofCode+"'>"
								+ htmlStr
								+ "</table>";
								
						accountCtrl.getInfo("combiCostApp_evidListArea").append(htmlStr);
					} else {
						accountCtrl.getInfoStr("[name=evidItemTable][proofcode="+getItem.ProofCode+"]").append(htmlStr);
						
						if(accountCtrl.getInfoStr("[name=evidItemArea][viewkeyno="+getItem.ViewKeyNo+"]").index() > 0) {
							accountCtrl.getInfoStr("[name=evidItemArea][viewkeyno="+getItem.ViewKeyNo+"]").find("th").remove();
						}
					}
							
					me.combiCostApp_makeHtmlChkColspan(accountCtrl.getInfoStr("[name=evidItemArea][viewkeyno="+getItem.ViewKeyNo+"]"));

					if(isEmptyStr(getItem.TaxInvoiceID) && getItem.ProofCode=="TaxBill"){
						accountCtrl.getInfoStr("[name=noTaxIFView][proofcode="+getItem.ProofCode+"][viewkeyno="+getItem.ViewKeyNo+"]").remove();
					}

					if(getItem.docList != null){
						for(var y = 0; y<getItem.docList.length; y++){
							var getDoc = getItem.docList[y];
							var str = 						
								"<a href='javascript:void(0);' class='btn_File ico_doc' style='margin-right: 10px;' onClick=\"CombineCostApplication<%=requestType%>.combiCostApp_LinkOpen('"
										+ getDoc.ProcessID+"', '" + getDoc.forminstanceID + "', '" + getDoc.bstored + "', '" + getDoc.BusinessData2 + "')\">"
										+ nullToStr(getDoc.Subject, "("+"<spring:message code='Cache.ACC_lbl_noTitle' />"+")") +"</a>";
										
							var getStr = accountCtrl.getInfoStr("[name=DocViewArea][proofcode="+getItem.ProofCode+"][viewkeyno="+getItem.ViewKeyNo+"]").append(str);
							//getStr = getStr + str;
							//var getStr = accountCtrl.getInfo("combCostApp"+type+"_docViewArea_"+keyId).html(getStr);
						}
					}
					
					if(getItem.fileList != null){
						for(var y = 0; y<getItem.fileList.length; y++){
							var fileInfo = getItem.fileList[y];
							var str = 						
								"<a href='javascript:void(0);' class='btn_File ico_file' style='width: auto;' onClick=\"CombineCostApplication<%=requestType%>.combiCostApp_FileDownload('"+escape(fileInfo.SavedName)+"','"+escape(fileInfo.FileName)+"','"+fileInfo.FileID+"')\">"+ fileInfo.FileName 
								+"<span class='tx_size'>("+ ckFileSize(fileInfo.Size) +")</span></a>"
								+"<a class='previewBtn' style='margin: 0px 10px;' href='javascript:void(0);' onclick=\"accountFileCtrl.attachFilePreview('" + fileInfo.FileID + "','" + fileInfo.FileToken + "','" + fileInfo.FileName.split(".")[fileInfo.FileName.split(".").length-1].toLowerCase() + "');\"></a>";
			
							var getStr = accountCtrl.getInfoStr("[name=FileViewArea][proofcode="+getItem.ProofCode+"][viewkeyno="+getItem.ViewKeyNo+"]").append(str);
						}
					}
					if(getItem.uploadFileList != null){
						for(var y = 0; y<getItem.uploadFileList.length; y++){
							var fileInfo = getItem.uploadFileList[y];
							var str = 						
								"<a href='javascript:void(0);' class='btn_File ico_file' style='width: auto;'>" + fileInfo.FileName + "<span class='tx_size'>("+ ckFileSize(fileInfo.Size) +")</span></a>";
							var getStr = accountCtrl.getInfoStr("[name=FileViewArea][proofcode="+getItem.ProofCode+"][viewkeyno="+getItem.ViewKeyNo+"]").append(str);
						}
					}
				}
			},

			//기존에 추가되어 있는 조회폼 1건 수정
			combiCostApp_changeHtmlViewFormOne : function(inputItem){
				var me = this;
				
				var htmlStr = me.combiCostApp_makeViewHtmlForm(inputItem);
				
				accountCtrl.getInfoStr("[name=evidItemArea][viewkeyno="+inputItem.ViewKeyNo+"]").html(htmlStr);
						
				me.combiCostApp_makeHtmlChkColspan(accountCtrl.getInfoStr("[name=evidItemArea][viewkeyno="+inputItem.ViewKeyNo+"]"));

				if(isEmptyStr(inputItem.TaxInvoiceID) && inputItem.ProofCode=="TaxBill"){
					accountCtrl.getInfoStr("[name=noTaxIFView][proofcode="+inputItem.ProofCode+"][viewkeyno="+inputItem.ViewKeyNo+"]").remove();
				}
				if(inputItem.docList != null){
					for(var y = 0; y<inputItem.docList.length; y++){
						var getDoc = inputItem.docList[y];
						var str = 						
							"<a href='javascript:void(0);' class='btn_File ico_doc' style='margin-right: 10px;' onClick=\"CombineCostApplication<%=requestType%>.combiCostApp_LinkOpen('"
									+ getDoc.ProcessID+"', '" + getDoc.forminstanceID + "', '" + getDoc.bstored + "', '" + getDoc.BusinessData2 + "')\">"
									+ nullToStr(getDoc.Subject, "("+"<spring:message code='Cache.ACC_lbl_noTitle' />"+")") +"</a>";
		
							var getStr = accountCtrl.getInfoStr("[name=DocViewArea][proofcode="+inputItem.ProofCode+"][viewkeyno="+inputItem.ViewKeyNo+"]").append(str);
							//getStr = getStr + str;
							//var getStr = accountCtrl.getInfo("combCostApp"+type+"_docViewArea_"+keyId).html(getStr);
					}
				}
				
				if(inputItem.fileList != null){
					for(var y = 0; y<inputItem.fileList.length; y++){
						var fileInfo = inputItem.fileList[y];
						var str = 						
							"<a href='javascript:void(0);' class='btn_File ico_file' style='width: auto;' onclick=\"CombineCostApplication<%=requestType%>.combiCostApp_FileDownload('"+escape(fileInfo.SavedName)+"','"+escape(fileInfo.FileName)+"','"+fileInfo.FileID+"')\">"+ fileInfo.FileName 
							+"<span class='tx_size'>("+ ckFileSize(fileInfo.Size) +")</span></a>"
							+"<a class='previewBtn' style='margin: 0px 10px;' href='javascript:void(0);' onclick=\"accountFileCtrl.attachFilePreview('" + fileInfo.FileID + "','" + fileInfo.FileToken + "','" + fileInfo.FileName.split(".")[fileInfo.FileName.split(".").length-1].toLowerCase() + "');\"></a>";
		
							var getStr = accountCtrl.getInfoStr("[name=FileViewArea][proofcode="+inputItem.ProofCode+"][viewkeyno="+inputItem.ViewKeyNo+"]").append(str);
					}
				}
				if(inputItem.uploadFileList != null){
					for(var y = 0; y<inputItem.uploadFileList.length; y++){
						var fileInfo = inputItem.uploadFileList[y];
						var str = 						
							"<a href='javascript:void(0);' class='btn_File ico_file' style='width: auto;'>" + fileInfo.FileName; //onclick=\"CombineCostApplication<%=requestType%>.combiCostApp_FileDownload('"+escape(fileInfo.SavedName)+"','"+escape(fileInfo.FileName)+"','"+fileInfo.FileID+"')\">"+ fileInfo.FileName 
							+"<span class='tx_size'>("+ ckFileSize(fileInfo.Size) +")</span></a>";
							//+"<a class='previewBtn' style='margin: 0px 10px;' href='#ax' onclick=\"accountFileCtrl.attachFilePreview('" + fileInfo.FileID + "','" + fileInfo.FileToken + "','" + fileInfo.FileName.split(".")[fileInfo.FileName.split(".").length-1].toLowerCase() + "');\"></a>";
							var getStr = accountCtrl.getInfoStr("[name=FileViewArea][proofcode="+inputItem.ProofCode+"][viewkeyno="+inputItem.ViewKeyNo+"]").append(str);
					}
				}
			},
			
			//조회폼 1건 추가
			combiCostApp_addHtmlViewFormOne : function(inputItem){
				var me = this;
				
				var htmlStr = me.combiCostApp_makeViewHtmlForm(inputItem);
				
				htmlStr = "<tbody id='combiCostApp_evidItemArea_"+inputItem.ViewKeyNo+"'"
						+ " name='evidItemArea' viewkeyno='"+inputItem.ViewKeyNo+"'>"
						+ htmlStr
						+ "</tbody>";
				
				if(accountCtrl.getInfoStr("[name=evidItemTable][proofcode="+inputItem.ProofCode+"]").length == 0) {
					htmlStr = "<p class='taw_top_sub_title'>"+Common.getDic("ACC_lbl_"+inputItem.ProofCode+"UseInfo")+"</p>"
							+ "<table class='acstatus_wrap' id='combiCostApp_evidItemTable_"+inputItem.ProofCode+"'"
							+ " name='evidItemTable' proofcode='"+inputItem.ProofCode+"'>"
							+ htmlStr
							+ "</table>";
							
					accountCtrl.getInfo("combiCostApp_evidListArea").append(htmlStr);
				} else {
					accountCtrl.getInfoStr("[name=evidItemTable][proofcode="+inputItem.ProofCode+"]").append(htmlStr);
					
					if(accountCtrl.getInfoStr("[name=evidItemArea][viewkeyno="+inputItem.ViewKeyNo+"]").index() > 0) {
						accountCtrl.getInfoStr("[name=evidItemArea][viewkeyno="+inputItem.ViewKeyNo+"]").find("th").remove();
					}
				}				
						
				me.combiCostApp_makeHtmlChkColspan(accountCtrl.getInfoStr("[name=evidItemArea][viewkeyno="+inputItem.ViewKeyNo+"]"));

				if(isEmptyStr(inputItem.TaxInvoiceID) && inputItem.ProofCode=="TaxBill"){
					accountCtrl.getInfoStr("[name=noTaxIFView][proofcode="+inputItem.ProofCode+"][viewkeyno="+inputItem.ViewKeyNo+"]").remove();
				}
				if(inputItem.docList != null){
					for(var y = 0; y<inputItem.docList.length; y++){
						var getDoc = inputItem.docList[y];
						var str = 						
							"<a href='javascript:void(0);' class='btn_File ico_doc' style='margin-right: 10px;' onClick=\"CombineCostApplication<%=requestType%>.combiCostApp_LinkOpen('"
									+ getDoc.ProcessID+"', '" + getDoc.forminstanceID + "', '" + getDoc.bstored + "', '" + getDoc.BusinessData2 + "')\">"
									+ nullToStr(getDoc.Subject, "("+"<spring:message code='Cache.ACC_lbl_noTitle' />"+")")+"</a>";
		
							var getStr = accountCtrl.getInfoStr("[name=DocViewArea][proofcode="+inputItem.ProofCode+"][viewkeyno="+inputItem.ViewKeyNo+"]").append(str);
							//getStr = getStr + str;
							//var getStr = accountCtrl.getInfo("combCostApp"+type+"_docViewArea_"+keyId).html(getStr);
					}
				}
				
				if(inputItem.fileList != null){
					for(var y = 0; y<inputItem.fileList.length; y++){
						var fileInfo = inputItem.fileList[y];
						var str = 						
							"<a href='javascript:void(0);' class='btn_File ico_file' style='width: auto;' onClick=\"CombineCostApplication<%=requestType%>.combiCostApp_FileDownload('"+escape(fileInfo.SavedName)+"','"+escape(fileInfo.FileName)+"','"+fileInfo.FileID+"')\">"+ fileInfo.FileName 
							+"<span class='tx_size'>("+ ckFileSize(fileInfo.Size) +")</span></a>"
							+"<a class='previewBtn' style='margin: 0px 10px;' href='javascript:void(0);' onclick=\"accountFileCtrl.attachFilePreview('" + fileInfo.FileID + "','" + fileInfo.FileToken + "','" + fileInfo.FileName.split(".")[fileInfo.FileName.split(".").length-1].toLowerCase() + "');\"></a>";
		
							var getStr = accountCtrl.getInfoStr("[name=FileViewArea][proofcode="+inputItem.ProofCode+"][viewkeyno="+inputItem.ViewKeyNo+"]").append(str);
					}
				}
				

				if(inputItem.uploadFileList != null){
					for(var y = 0; y<inputItem.uploadFileList.length; y++){
						var fileInfo = inputItem.uploadFileList[y];
						var str = 						
							"<a href='javascript:void(0);' class='btn_File ico_file' style='width: auto;'>"+ fileInfo.FileName // onClick=\"CombineCostApplication<%=requestType%>.combiCostApp_FileDownload('"+escape(fileInfo.SavedName)+"','"+escape(fileInfo.FileName)+"','"+fileInfo.FileID+"')\">"+ fileInfo.FileName 
							+"<span class='tx_size'>("+ ckFileSize(fileInfo.Size) +")</span></a>";
							//+"<a class='previewBtn' style='margin: 0px 10px;' href='#ax' onclick=\"accountFileCtrl.attachFilePreview('" + fileInfo.FileID + "','" + fileInfo.FileToken + "','" + fileInfo.FileName.split(".")[fileInfo.FileName.split(".").length-1].toLowerCase() + "');\"></a>";
							
							var getStr = accountCtrl.getInfoStr("[name=FileViewArea][proofcode="+inputItem.ProofCode+"][viewkeyno="+inputItem.ViewKeyNo+"]").append(str);
					}
				}
			},
			
			//조회 폼 생성하여 html을 str로 반환
			combiCostApp_makeViewHtmlForm : function(inputItem) {
				var me = this;
				if(inputItem != null){

					var ProofCode = inputItem.ProofCode;
					var ViewKeyNo = inputItem.ViewKeyNo;
					var formStr = me.pageCombiAppFormList[ProofCode+"ViewFormStr"];

					var TC = nullToBlank(inputItem.TaxCode)
					var TT = nullToBlank(inputItem.TaxType)
					var PM = nullToBlank(inputItem.PayMethod)
					var PT = nullToBlank(inputItem.PayType)
					var PG = nullToBlank(inputItem.PayTarget)
					var PV = nullToBlank(inputItem.Providee)
					var BT = nullToBlank(inputItem.BillType)
					
					var TaxCodeNm = me.combiCostApp_getCodeMapInfo(me.pageCombiAppComboData.TaxCodeMap, TC, 'CodeName')
					var TaxTypeNm = me.combiCostApp_getCodeMapInfo(me.pageCombiAppComboData.TaxTypeMap, TT, 'CodeName')
					var PayMethodNm = me.combiCostApp_getCodeMapInfo(me.pageCombiAppComboData.PayMethodMap, PM, 'CodeName')
					var PayTypeNm = me.combiCostApp_getCodeMapInfo(me.pageCombiAppComboData.PayTypeMap, PT, 'CodeName')
					var PayTargetNm = me.combiCostApp_getCodeMapInfo(me.pageCombiAppComboData.PayTargetMap, PG, 'CodeName')
					var ProvideeNm = me.combiCostApp_getCodeMapInfo(me.pageCombiAppComboData.ProvideeMap, PV, 'CodeName')
					var BillTypeNm = me.combiCostApp_getCodeMapInfo(me.pageCombiAppComboData.BillTypeMap, BT, 'CodeName')
					
					var divList = inputItem.divList;
					var divStr = "";
					for(var y = 0; y<divList.length; y++){
						var divItem = divList[y];
							
						var oneLine="";
						if(divList.length==1){
							oneLine="class='one_line'";
						}
						
						var divValMap = {
								DivAmount : toAmtFormat(divItem.Amount),
								AccountName : nullToBlank(divItem.AccountName),
								StandardBriefName : nullToBlank(divItem.StandardBriefName),
								CostCenterName : nullToBlank(divItem.CostCenterName),
								IOName : nullToBlank(divItem.IOName),
								DocNo : nullToBlank(divItem.DocNo),
								UsageComment : nullToBlank(divItem.UsageComment),
								OneLine : oneLine,
								BankInfo : nullToBlank(me.combiCostApp_makeBankInfoStr(inputItem))
						}
						
						var htmlDivFormStr = me.pageCombiAppFormList.DivViewFormStr;
						if(ProofCode == "CorpCard"){
							htmlDivFormStr = htmlDivFormStr.replace("name=\"noBankArea\"", "name=\"noBankArea\" style=\"display:none;\"");
						}
						htmlDivFormStr = me.combiCostApp_htmlFormSetVal(htmlDivFormStr, divValMap);
						divStr = divStr + htmlDivFormStr;
					}
					
					inputItem.AccountBankName = accComm.getBaseCodeName("Bank", nullToBlank(inputItem.AccountBank), me.CompanyCode);
					
					if(inputItem.AccountBankName == "") {
						inputItem.AccountBankName = inputItem.AccountBank;
					}

					var valMap = {
							RequestType : requestType, 
							ViewKeyNo : nullToBlank(inputItem.ViewKeyNo),
							ProofCode : nullToBlank(inputItem.ProofCode),
							
							TotalAmount : toAmtFormat(nullToBlank(inputItem.TotalAmount)),
							RepAmount : toAmtFormat(nullToBlank(inputItem.RepAmount)),
							TaxAmount : toAmtFormat(nullToBlank(inputItem.TaxAmount)),
							SupplyCost : toAmtFormat(nullToBlank(inputItem.SupplyCost)),
							Tax : toAmtFormat(nullToBlank(inputItem.Tax)),
							
							ProofDate : nullToBlank(inputItem.ProofDateStr),
							ProofTime : nullToBlank(inputItem.ProofTimeStr),
							PostingDate : nullToBlank(inputItem.PostingDateStr),
							PayDate : nullToBlank(inputItem.PayDateStr),
							
							StoreName : nullToBlank(inputItem.StoreName).trim(),
							CardUID : nullToBlank(inputItem.CardUID),
							CardApproveNo : nullToBlank(inputItem.CardApproveNo),
							
							ReceiptID : nullToBlank(inputItem.ReceiptID),
							
							TaxInvoiceID : nullToBlank(inputItem.TaxInvoiceID),
							TaxUID : nullToBlank(inputItem.TaxUID),
							TaxNTSConfirmNum : nullToBlank(inputItem.TaxNTSConfirmNum),
							
							CashUID : nullToBlank(inputItem.CashUID),
							CashNTSConfirmNum : nullToBlank(inputItem.CashNTSConfirmNum),
							
							AccountInfo : nullToBlank(inputItem.AccountInfo),
							AccountHolder : nullToBlank(inputItem.AccountHolder),
							AccountBank : nullToBlank(inputItem.AccountBank),
							AccountBankName : nullToBlank(inputItem.AccountBankName),
							BankName : nullToBlank(inputItem.BankName),
							BankAccountNo : nullToBlank(inputItem.BankAccountNo),
							
							VendorNo : nullToBlank(inputItem.VendorNo),
							VendorName : nullToBlank(inputItem.VendorName),
							TaxCodeNm : TaxCodeNm,
							TaxTypeNm : TaxTypeNm,
							PayMethod : PayMethodNm,
							PayType : PayTypeNm,
							PayTarget : PayTargetNm,
							PaymentConditionName : nullToBlank(inputItem.PaymentConditionName),

							FranchiseCorpName : nullToBlank(inputItem.FranchiseCorpName),
							PersonalCardNoView : nullToBlank(inputItem.PersonalCardNoView),
							
							ProviderName : nullToBlank(inputItem.ProviderName),
							ProviderNo : nullToBlank(inputItem.ProviderNo),
							Providee : ProvideeNm,
							BillType : BillTypeNm,
							
							pageNm : "CombineCostApplication<%=requestType%>",

							MobileAppClick : "combiCostApp_MobileAppClick",
							FileID : nullToBlank(inputItem.FileID),
					}
					valMap.divArea = divStr;
					
					var getForm = me.combiCostApp_htmlFormSetVal(formStr, valMap);
					getForm = me.combiCostApp_htmlFormDicTrans(getForm);
					
					return getForm;
				}
			},
			
			combiCostApp_makeHtmlChkColspan : function(divObj) {
				if(divObj == undefined)
					return;
				
				if(isUseIO == "N"){
					$(divObj).find("[name=noIOArea]").remove();
					$(divObj).find("[name=colIOSBArea]").attr("colspan", Number($(divObj).find("[name=colIOSBArea]").attr("colspan")) - 1);
					$(divObj).find("[name=FileViewArea]").attr("colspan", Number($(divObj).find("[name=FileViewArea]").attr("colspan")) - 1);
				}
				if(isUseSB == "N") {
					$(divObj).find("[name=noSBArea]").remove();
					$(divObj).find("[name=colIOSBArea]").attr("colspan", Number($(divObj).find("[name=colIOSBArea]").attr("colspan")) - 1);
					$(divObj).find("[name=FileViewArea]").attr("colspan", Number($(divObj).find("[name=FileViewArea]").attr("colspan")) - 1);
				}
			   	if(isUseBD == "" || isUseBD == "N") {
			   		$(divObj).find("[name=noBDArea]").remove();
			   		$(divObj).find("[name=colIOSBArea]").attr("colspan", Number($(divObj).find("[name=colIOSBArea]").attr("colspan")) - 1);
			   		$(divObj).find("[name=FileViewArea]").attr("colspan", Number($(divObj).find("[name=FileViewArea]").attr("colspan")) - 1);
				}
			},
			
			//상세 데이터 조회
			combiCostApp_searchPageData : function(ExpenceApplicationID) {
				var me = this;

				$.ajax({
					url:"/account/expenceApplication/searchExpenceApplication.do",
					cache: false,
					data:{
						ExpenceApplicationID : ExpenceApplicationID
					},
					success:function (data) {
						
						if(data.result == "ok"){
							me.pageExpenceAppEvidList =data.data.pageExpenceAppEvidList;

						   	for(var i=0;i<me.pageExpenceAppEvidList.length; i++){
						   		var item = me.pageExpenceAppEvidList[i];
								me.maxViewKeyNo++;
								item.ViewKeyNo = me.maxViewKeyNo;
						   	}
						   	
							me.pageExpenceAppObj = data.data;
							me.pageExpenceAppObj.isNew = "N";
							me.pageExpenceAppObj.isSearched = "Y";
							
							var fieldList =  accountCtrl.getInfoName("ComCostAppInputField");
						   	for(var i=0;i<fieldList.length; i++){
						   		var field = fieldList[i];
						   		var tag = field.getAttribute("tag");
						   		field.value = nullToBlank(typeof(me.pageExpenceAppObj[tag]) == "object" ? JSON.stringify(me.pageExpenceAppObj[tag]) : me.pageExpenceAppObj[tag]);
						   	}
							
							if(me.pageExpenceAppEvidList.length > 0) {
								accountCtrl.getComboInfo("combiCostApp_defaultPayDateList").val(me.pageExpenceAppObj.PayDateType);
								accountCtrl.refreshAXSelect("combiCostApp_defaultPayDateList");
								
								if(me.pageExpenceAppObj.PayDateType == "E" && me.pageExpenceAppEvidList[0].PayDateStr != undefined) {
									accountCtrl.getInfo("combiCostApp_defaultPayDateInput_Date").val(me.pageExpenceAppEvidList[0].PayDateStr);
								}
							}
							
							me.combiCostApp_makeHtmlViewFormAll();
							me.combiCostApp_pageAmtSet();
							me.combiCostApp_comboDataInit();
							
							//리뷰에서 진입했다는건 완료된 건이라는것
							if(me.openParam.isReview == "Y"){
								accountCtrl.getInfoName("saveBtn").css("display","none");
								accountCtrl.getInfoName("afterSaveBtn").css("display","");
							}
							else if(me.pageExpenceAppObj.ApplicationStatus != "T"){
								accountCtrl.getInfoName("saveBtn").css("display","none");
								accountCtrl.getInfoName("afterSaveBtn").css("display","none");
								accountCtrl.getInfoName("noViewArea").remove();
							}

							if(me.tempObj.saveType=="S"){
								var saveData = me.tempObj.saveData;
								me.tempObj = {};

								//accountCtrl.getInfoName("saveBtn").css("display","none");
								//accountCtrl.getInfoName("afterSaveBtn").css("display","none");
								
								//마감기간 기안통제여부 체크
								if(checkDeadlineControl(me.pageExpenceAppEvidList, me.CompanyCode)) return;
								//감사규칙 체크 후 결재 진행
								checkAuditRule(propertyOtherApv, me.pageExpenceAppObj, me.combiCostApp_getHTMLBody(), ExpenceApplicationID, requestType, me.CompanyCode);
							} else if(me.tempObj.saveType=="E"){
								me.tempObj = {};
								callChangeBodyContext(me.pageExpenceAppObj, me.combiCostApp_getHTMLBody(), requestType);
							}
							
							var note = nullToBlank(me.pageExpenceAppObj["Note"]);
							me.setEditor(note);
							
							// 전결규정에서 담당업무를 셋팅한 경우 임시저장문서 로드시 적용 
							setChargeJob(me.pageExpenceAppObj.ChargeJob);
						}
						else{
							Common.Error(data);
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의바랍니다.
					}
				});
				
			},
			
			//추가되어 있는 증빙을 삭제
			combiCostApp_evidItemDelete : function() {
				var me = this;

				var checkedList =  accountCtrl.getInfoStr("[name=EvidItemCheck]:checked");
				
				if(checkedList.length==0){
					Common.Inform("<spring:message code='Cache.ACC_msg_noselectdata' />");	//선택된 항목이 없습니다.
					return;
				}
				
		        Common.Confirm("<spring:message code='Cache.ACC_msg_ckDelete' />", "Confirmation Dialog", function(result){	//삭제하시겠습니까?
		       		if(result){
						var newList  =[]
		
					   	for(var i=0;i<checkedList.length; i++){
					   		var checkedItem = checkedList[i];
							var ViewKeyNo = checkedItem.getAttribute("viewkeyno");
							var ProofCode = checkedItem.getAttribute("proofcode");
							
							var deletedItem = me.combiCostApp_findListItem(me.pageExpenceAppEvidList, "ViewKeyNo", ViewKeyNo);
							me.pageExpenceAppEvidDeletedList.push(deletedItem);
									
							var idx = accFindIdx(me.pageExpenceAppEvidList, "ViewKeyNo", ViewKeyNo );
		
							if(idx>=0){
								me.pageExpenceAppEvidList.splice(idx,1);
							}
							
							if(accountCtrl.getInfoStr("[name=evidItemArea][viewkeyno="+ViewKeyNo+"]").index() == 0) { //삭제할 tbody가 첫번째일경우 다음 tbody에 th 추가
								if(accountCtrl.getInfoStr("[name=evidItemTable][proofcode="+ProofCode+"]").find("[name=evidItemArea]").length > 1) {
									var thArea = accountCtrl.getInfoStr("[name=evidItemArea][viewkeyno="+ViewKeyNo+"]").find("th").parent();
									accountCtrl.getInfoStr("[name=evidItemArea]").eq(1).prepend(thArea);
								}
							}
							accountCtrl.getInfoStr("[name=evidItemArea][viewkeyno="+ViewKeyNo+"]").remove();
							
							if(accountCtrl.getInfoStr("[name=evidItemTable][proofcode="+ProofCode+"]").find("[name=evidItemArea]").length == 0) { //table에 더이상 tbody가 없을 경우 table 삭제
								accountCtrl.getInfoStr("[name=evidItemTable][proofcode="+ProofCode+"]").siblings("p").remove();
								accountCtrl.getInfoStr("[name=evidItemTable][proofcode="+ProofCode+"]").remove();
							}
					   	}
						me.combiCostApp_pageAmtSet();
		       		}
		        });
			},

			//추가되어 있는 증빙을 수정을 위해 상단으로 이동
			combiCostApp_onEvidItemEdit : function(ProofCode, ViewKeyNo) {
				var me = this;

				var iHeight = 500;
				var iWidth = 1000;
				if(ProofCode != "CorpCard") {
					iHeight = 650;
					iWidth = 1600;
				}
		        var sUrl = "/account/expenceApplication/ExpenceApplicationListEditPopup.do?" 
		        			+ me.pageOpenerIDStr
		        			+ "ExpAppListID="
		        			+ "&AppType=CO"
		        			+ "&RequestType=" + requestType
		        			+ "&ProofCode=" + ProofCode
		        			+ "&ViewKeyNo=" + ViewKeyNo
		        			+ "&CompanyCode=" + me.CompanyCode
		        			+ "&callBackFunc=combiCostApp_setListEditInfo";
		        
		        var sSize = "both";
				
				CFN_OpenWindow(sUrl, "", iWidth, iHeight, sSize);
			},			
			
			combiCostApp_setListEditInfo : function(targetObj) {
				var me = this;

				$(me.pageExpenceAppEvidList).each(function(i, obj){
					if(obj.ExpenceApplicationListID != undefined) {
						if(obj.ExpenceApplicationListID == targetObj.ExpenceApplicationListID){
							me.pageExpenceAppEvidList[i] = JSON.parse(JSON.stringify(targetObj));
							return false;
						}
					} else {
						if(obj.ViewKeyNo == targetObj.ViewKeyNo){
							me.pageExpenceAppEvidList[i] = JSON.parse(JSON.stringify(targetObj));
							return false;
						}
					}
				});
				
				me.combiCostApp_makeHtmlViewFormAll();
				me.combiCostApp_pageAmtSet();
			},
			
			//카드 영수증 조회
			combiCostApp_onCardAppClick  : function(ReceiptID){
				var me = this;
				accComm.accCardAppClick(ReceiptID, me.pageOpenerIDStr);
			},

			//세금계산서 영수증 조회
			combiCostApp_onTaxBillAppClick  : function(TaxInvoiceID){
				var me = this;
				accComm.accTaxBillAppClick(TaxInvoiceID, me.pageOpenerIDStr);
			},
			
			//지급정보 세부조회
			combiCostApp_onDivDetailClick  : function(ExpListID){
				var me = this;
				accComm.accCombineCostDetClick(ExpListID, me.pageOpenerIDStr, "CO", requestType);
			},
			
			combiCostApp_MobileAppClick : function(FileID){
				var me = this;
				accComm.accMobileReceiptAppClick(FileID, me.pageOpenerIDStr);
			},
			
			//============================================공통사용부=======================
			
			//팝업 생성시 팝업에서 호출. 값을 넘겨주기 위한 함수
			combiCostApp_CallAddLoadPopupParam : function(ProofCode) {
				var me = this;
				var obj = {}
				var ExpAppId = accountCtrl.getInfoStr("[name=ComCostAppInputField][tag=ExpenceApplicationID]").val();

				var list = me.pageExpenceAppEvidList;
				var pageList = me.combiCostApp_getPageList(ProofCode);
				var idStr = "";

				if(list != null && pageList != null){
					list = list.concat(pageList);
				}
				else if(list==null && pageList != null){
					list = pageList;
				}
				
				if(ProofCode=="CorpCard"){
					searchKey = "CardUID"
				} else if(ProofCode=="CashBill"){
					searchKey = "CashUID";
				} else if(ProofCode=="TaxBill"){
					searchKey = "TaxUID";
				} else if(ProofCode=="Receipt"){
					searchKey = "ReceiptID";
				} 
				
				for(var i = 0; i<list.length; i++){
					var item = list[i];
					if(item.ProofCode==ProofCode){
						if(idStr==""){
							idStr = item[searchKey]
						}else{
							idStr = idStr + ","+item[searchKey]
						}	
					}
				}

				obj.ExpAppId = ExpAppId;
				obj.idStr = idStr;
				
				return obj
			},
			
			//코드 맵에서 코드를 통해 코드 명 획득
			combiCostApp_getCodeMapInfo : function(codeMap, key, getField) {
				var me = this;
				var retVal = "";
				
				if(codeMap != null 
					&& key != null
					&& getField != null
				){
					if(codeMap[key] != null){
						retVal = codeMap[key][getField]	
					}
				}
				return retVal
			},
			
			//자동저장기능. 현재는 미사용
			combiCostApp_onSaveBackground : function(ProofCode, htmlMake) {
				var me = this;
				Common.Inform("<spring:message code='Cache.ACC_lbl_notUse' />");
				return;
				var getInfo = me.combiCostApp_getDataObj();
				if(ProofCode != null){
					var pageList = me.combiCostApp_getPageList(ProofCode);
					getInfo.pageExpenceAppEvidList = pageList
				}
				
				getInfo.IsTempSave = "Y";
				getInfo.ApplicationStatus = "T";
				
				var pageInfo = {
						ProofCode : ProofCode,
						htmlMake : htmlMake
				}
				
				me.combiCostApp_callSaveAjax(getInfo, true, pageInfo);
			},
			
			//저장전 유효성 검사
			combiCostApp_onSave : function(type) {
			    if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
			    
				var me = this;

				me.combiCostApp_getDataObj();
				
				var g_containerID = 'tbContentElement<%=requestType%>';
				var g_editorKind = Common.getBaseConfig('EditorType');
				
				// Dext5의 경우 display 값이 변경되면 제대로 로드되지 않기 때문에 사용여부가 N인 경우 데이터를 찾기 않게 조건문 추가
				var eAccNoteIsUse = Common.getBaseConfig("eAccNoteIsUse");
				var body = "";
				var images = "";
				var backgroundImage = "";
				
				if(eAccNoteIsUse == "Y" && me.noteIsUse == "Y") {
					body = coviEditor.getBody(g_editorKind, g_containerID);
					images = coviEditor.getImages(g_editorKind, g_containerID);
					backgroundImage = coviEditor.getBackgroundImage(g_editorKind, g_containerID);
				}

				me.pageExpenceAppObj.body = body;
				me.pageExpenceAppObj.images = images;
				me.pageExpenceAppObj.backgroundImage = backgroundImage;
				
				if(me.pageExpenceAppEvidList.length == 0){
					Common.Inform("<spring:message code='Cache.ACC_msg_noSaveData' />");
					return;
				}
				
				if(isEmptyStr(me.pageExpenceAppObj.ApplicationTitle)){
					Common.Inform("<spring:message code='Cache.ACC_msg_noTitle' />");
					return;
				}
				
				if(!bool_ApvValidationCheck()) return;
				
				if(type != 'T') {
					if(getInfo("SchemaContext.scChrDraft.isUse") != "Y" && $$(JSON.parse(accountCtrl.getInfo("APVLIST_").val())).find("steps>division>step>ou").length < 2) {
						Common.Inform("<spring:message code='Cache.msg_apv_049' />"); //결재자를 지정하세요
						return;
					}
					
					// 자동결재선 체크 추가.
					if(chkAutoApprovalLine()) return; // accountCommon.js
					
					if(isEmptyStr(me.pageExpenceAppObj.PayDateType)){
						Common.Inform("지급일을 선택하세요");	
						return;
					} else {
						me.combiCostApp_makePayDate(me.pageExpenceAppObj.PayDateType);
										
						if(me.pageExpenceAppObj.PayDateType == "E" && isEmptyStr(accountCtrl.getInfo("combiCostApp_defaultPayDateInput_Date").val())) {
							Common.Inform("지급일 유형이 기타일 경우 지급일 입력이 필요합니다.");
							return;
						}
					}
					
					for(var i = 0; i < me.pageExpenceAppEvidList.length; i++) {
						var evidItem = me.pageExpenceAppEvidList[i];
				   		var divList = evidItem.divList;
				   		var msg = "[" + Number(i+1) + "번째 증빙] ";
				   		
						if(evidItem.ProofDate > evidItem.PayDate) {
					   		Common.Inform("해당 증빙의 증빙일자가 지급희망일보다 큽니다.");
					   		return;
					   		break;
					   	}
						
						// 환율 관련 체크
						if (me.exchangeIsUse == "Y" && evidItem.ProofCode == "EtcEvid") {
							if (evidItem.Currency == "") {
								msg += "<spring:message code='Cache.ACC_msg_Require_Currency' />"; //환종은 필수로 입력하여야 합니다.
								Common.Inform(msg);
								return;
							}
							
							if (evidItem.Currency != "KRW") {
						   		var getExchangeRate = nullToBlank(evidItem.ExchangeRate);
						   		getExchangeRate = Number(AmttoNumFormat(getExchangeRate));
						   		
								if (getExchangeRate == "" || isNaN(getExchangeRate) || getExchangeRate == 0) {
									msg += "<spring:message code='Cache.ACC_msg_Require_ExchangeRate' />"; //환율은 필수로 입력하여야 합니다.
									Common.Inform(msg);
									return;
								}
								
						   		var getLocalAmount = nullToBlank(evidItem.LocalAmount);
						   		getLocalAmount = Number(AmttoNumFormat(getLocalAmount));
						   		
								if (getLocalAmount == "" || isNaN(getLocalAmount) || getLocalAmount == 0) {
									msg += "<spring:message code='Cache.ACC_msg_Require_LocalAmount' />"; //현지금액은 필수로 입력하여야 합니다.
									Common.Inform(msg);
									return;
								}
							}
						}
						
						for (var j = 0; j < divList.length; j++) {
							var divItem = divList[j];	
					   		var getDivAmt = nullToBlank(divItem.Amount);
					   		
							getDivAmt = Number(AmttoNumFormat(getDivAmt));
							
							if(isNaN(getDivAmt) || getDivAmt == 0){
								msg += "<spring:message code='Cache.ACC_lbl_amtValidateErr' />";	//청구금액이 [0]이거나 올바른 금액이 아닙니다.
								Common.Inform(msg);
								return;
							}
						}
					}

			   		//예산 통제
				   	if(type != "E" && Common.getBaseConfig('eAccIsUseBudget') == 'Y') {
				   		//예산초과체크
					   	var budgetMsg = budgetControl(requestType, me.pageExpenceAppEvidList);
					   	if (budgetMsg) {
                	        Common.Inform(budgetMsg);
                    	    return;
				   		}
			   		}
				}
				

			   	var msg = "<spring:message code='Cache.ACC_isSaveCk' />";
			   	if(type=="S"){
					msg = "<spring:message code='Cache.ACC_isAppCk' />";
			   	}

				if(type != 'T' && me.pageExpenceAppEvidList[0].PayDate < new Date().format("yyyyMMdd")) {
			   		Common.Confirm("<spring:message code='Cache.ACC_PayDateChk' />", "Confirmation Dialog", function(result){
						if(result){
							Common.Confirm(msg, "Confirmation Dialog", function(result){
								if(result){
								    me.combiCostApp_IsSaveStatus(type);
									me.combiCostApp_callSaveAjax(me.pageExpenceAppObj);
								}
							});
						}
					});
			   	} else {
			   		Common.Confirm(msg, "Confirmation Dialog", function(result){
						if(result){
						    me.combiCostApp_IsSaveStatus(type);
							me.combiCostApp_callSaveAjax(me.pageExpenceAppObj);
						}
					});
			   	}
			},

			combiCostApp_IsSaveStatus : function (type){ //validation Check후 상태값 변경하도록함. 
			    var me = this;
			    if(type=="T"){
					me.pageExpenceAppObj.IsTempSave = "Y"
					me.pageExpenceAppObj.ApplicationStatus 		= "T";
					me.tempObj.saveType="T";
				}
				else if(type=="E"){
					me.pageExpenceAppObj.IsTempSave = "N"
					me.pageExpenceAppObj.ApplicationStatus 		= "E";
					me.tempObj.saveType="E";
				}
				else{
					me.pageExpenceAppObj.IsTempSave = "Y"
					me.pageExpenceAppObj.ApplicationStatus 		= "T";
					me.tempObj.saveType="S";
			   		msg = "<spring:message code='Cache.ACC_isAppCk' />";
				}
			},
			    
			//저장 호출
			combiCostApp_callSaveAjax : function(inputData, isBK, pageInfo) {
				var me = this;
				
				if(!inputData){
					inputData = me.pageExpenceAppObj
				}
				
				$.ajax({
					type:"POST",
						url:"/account/expenceApplication/saveCombineCostApplication.do",
					data:{
						saveObj : JSON.stringify(inputData),
					},
					success:function (data) {
						
						if(data.result == "ok"){
							if(!isBK){								
								//전자결재 연동 호출
								//저장 후 재조회 이후로 이동
								//me.combiCostApp_callOpenForm(inputData, data.data.ExpenceApplicationID);							
							}

							me.combiCostApp_pageDataInit();
							//me.combiCostApp_searchPageData(data.data.ExpenceApplicationID);
							if(isBK){
								//백그라운드 세이브는 현재 사용 안함
							}
							else{
								var ExpAppID = data.getSavedKey;
								
								if(me.tempObj.saveType!="T"){
									me.tempObj.saveData = inputData;
								} else {
									Common.Inform("<spring:message code='Cache.ACC_msg_saveComp' />"); //저장되었습니다
								}	
								
								me.combiCostApp_searchPageData(ExpAppID);
							}
						}
						else if(data.result == "D"){
							
							var duplObj = data.duplObj;
							var msg = "<spring:message code='Cache.ACC_msg_isExpAppDupl' />";
							if(duplObj.CCCnt>0){
								msg += "<br>" + "<spring:message code='Cache.ACC_lbl_corpCard' />";
								msg += ": " + duplObj.CCCnt + "<spring:message code='Cache.lbl_DocCount' />";
							}
							if(duplObj.TBCnt>0){
								msg += "<br>" + "<spring:message code='Cache.ACC_lbl_taxInvoiceCash' />";
								msg += ": " + duplObj.TBCnt + "<spring:message code='Cache.lbl_DocCount' />";
							}
							if(duplObj.CBCnt>0){
								msg += "<br>" + "<spring:message code='Cache.ACC_lbl_cashBill' />";
								msg += ": " + duplObj.CBCnt + "<spring:message code='Cache.lbl_DocCount' />";
							}
							if(duplObj.MRCnt>0){
								msg += "<br>" + "<spring:message code='Cache.ACC_lbl_mobileReceipt' />";
								msg += ": " + duplObj.MRCnt + "<spring:message code='Cache.lbl_DocCount' />";
							}
							
							Common.Inform(msg);
						}
						else{
							Common.Error("<spring:message code='Cache.ACC_msg_error' />");	//오류가 발생하였습니다. 관리자에게 문의 바랍니다.
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의바랍니다.
					}
				});
			},

			//날짜필드 생성
			combiCostApp_makeDateField : function(ProofCode, itemList) {
				var me = this;
				var arrCk = Array.isArray(itemList);
				if(arrCk){
					for(var i = 0; i<itemList.length; i++){
						var getItem = itemList[i];
						var dateInputList = accountCtrl.getInfoStr("[name=DateArea][proofcode="+ProofCode+"][keyno="+getItem["KeyNo"]+"]");

						for(var y = 0; y<dateInputList.length; y++){
							var input = dateInputList[y]
							var dataField = input.getAttribute("datafield")
							var areaID = input.id;
							var pd = getItem[dataField];
							/* if(isEmptyStr(pd)){
								var today = new Date();
								pd = today.format("yyyyMMdd")
							} */
							makeDatepicker(areaID, areaID+"_Date", null, pd, null, 100);
						}
					}
				}
			},
			
			//필드값에서 값 획득
			combiCostApp_getDataObj : function() {
				var me = this;

				var pageInfo = {};
				var fieldList = accountCtrl.getInfoName("ComCostAppInputField");
				for(var i = 0; i<fieldList.length; i++){
					var field = fieldList[i];
					var tag = field.getAttribute("tag");
					var fieldType = field.tagName;
					if(fieldType=="INPUT"){
						pageInfo[tag] = field.value;
					} else if(fieldType=="LABEL"){
						pageInfo[tag] = field.innerHTML;
					}
				}

				var propertyFieldList = accountCtrl.getInfoName("ExpAppPropertyField");
				for(var i = 0; i<propertyFieldList.length; i++){
					var field = propertyFieldList[i];
					var tag = field.getAttribute("tag");
					var fieldType = field.tagName;
					if(fieldType=="INPUT"){
						pageInfo["Property"+tag] = field.value;
					}
				}
				
				var pageEvidList = me.pageExpenceAppEvidList;
				pageInfo.pageExpenceAppEvidList = pageEvidList;
				pageInfo.pageExpenceAppEvidDeletedList = me.pageExpenceAppEvidDeletedList;	
				
				for(var i = 0; i < pageInfo.pageExpenceAppEvidList.length; i++) {
					if(pageInfo.pageExpenceAppEvidList[i].PayDate != undefined) {
						pageInfo.pageExpenceAppEvidList[i].RealPayDate = pageInfo.pageExpenceAppEvidList[i].PayDate.replace(/\./gi, '');
					}
					pageInfo.pageExpenceAppEvidList[i].RealPayAmount = pageInfo.pageExpenceAppEvidList[i].divSum;
				}

				pageInfo.ApplicationType 		= "CO";
				pageInfo.ApplicationStatus 		= "T";
				pageInfo.RequestType			= requestType;
				
				pageInfo.ChargeJob = accComm.getJobFunctionData(requestType);
				
				pageInfo.ApprovalLine = JSON.stringify(getApvList(accountCtrl.getInfo("APVLIST_").val(), "TEMPSAVE"));
				pageInfo.FormName = accComm[requestType].pageExpenceFormInfo.FormName;
				
				// 지급일 타입 저장
				pageInfo.PayDateType = me.pageExpenceAppObj.PayDateType;

				// 법인 저장
				pageInfo.CompanyCode = accountCtrl.getComboInfo("combiCostApp_inputCompanyCode").val();
								
				me.pageExpenceAppObj = pageInfo;
				return pageInfo;
			},

			//화면의 Date 필드값 획득하여 세팅
			combiCostApp_getExpAppEvidDate : function(pageEvidList){
				var me = this;
				for(var i = 0; i<pageEvidList.length; i++){
					var evidItem = pageEvidList[i];

					var dateInputList = accountCtrl.getInfoStr("[name=DateArea][proofcode="+evidItem.ProofCode+"][keyno="+evidItem.KeyNo+"]");

					for(var y = 0; y<dateInputList.length; y++){
						var input = dateInputList[y]
						var dataField = input.getAttribute("datafield")
						var areaID = input.id;
						var Strval = accountCtrl.getInfo(areaID+"_Date").val();
						var val = Strval.replaceAll(".","");

						evidItem[dataField] = val;
						evidItem[dataField+"Str"] = Strval;
					}
				}
			},
			
			//입력영역 접기
			combiCostApp_inputAreaFolding : function(obj) {
				var me = this;
				
				if(accountCtrl.getInfo("comCostApp_inputAreaDiv").css("display") == "none"){
					accountCtrl.getInfo("comCostApp_inputAreaDiv").css("display", "") ;
					obj.setAttribute("class", "btn_taw_close")
				} else {
					accountCtrl.getInfo("comCostApp_inputAreaDiv").css("display", "none") ;
					obj.setAttribute("class", "btn_taw_open")
				}
				
			},
			
			//금액 계산하여 상단에 표시
			combiCostApp_pageAmtSet : function() {
				var me = this;
				
				accComm.accPageAmtSet(me.pageExpenceAppEvidList, "comCostApp_");
			},
			
			//문자열 형태의 htmlform에 @@{} 형식으로 지정된 부분에 값 치환
			combiCostApp_htmlFormSetVal : function(inputStr, replaceMap){
				return accComm.accHtmlFormSetVal(inputStr, replaceMap);
			},
			
			
			// 거래처비용정산 : 은행계좌 정보 추가표시.
			combiCostApp_makeBankInfoStr : function(item) {
				var BankInfo = ""; // 신한 123-22222-65214 홍길동
				if(item.AccountBankName && item.AccountBankName != ""){
					BankInfo += item.AccountBankName;
				}else if(item.BankName && item.BankName != ""){
					BankInfo += item.BankName;
				}
				if(item.AccountInfo){
					BankInfo += "<br>" + item.AccountInfo;
				}
				if(item.AccountHolder){
					BankInfo += "<br>" + item.AccountHolder; //예금주
				}
				return BankInfo;
			},
			
			//문자열 형태의 htmlform에 다국어 처리
			combiCostApp_htmlFormDicTrans : function(inputStr) {
				return accComm.accHtmlFormDicTrans(inputStr);
			},
			
			//입력용 form 생성 입력된 item의 증빙 유형별로 생성
			combiCostApp_makeInputHtmlForm : function(inputItem, valMap) {
				var me = this;
				
				if(inputItem != null){

					var ProofCode = inputItem.ProofCode;
					var KeyNo = inputItem.KeyNo;
					var formStr = me.pageCombiAppFormList[ProofCode+"InputFormStr"];

					if(nullToBlank(inputItem.Amount) == ""){
						inputItem.Amount = inputItem.TotalAmount;
					}
					
					if(valMap==null){
						var valMap = {
							RequestType : requestType,
							ExpenceApplicationListID : nullToBlank(inputItem.ExpenceApplicationListID),
							ViewKeyNo : nullToBlank(inputItem.ViewKeyNo),
							KeyNo : nullToBlank(inputItem.KeyNo),
							ProofCode : nullToBlank(inputItem.ProofCode),
							TotalAmount : toAmtFormat(nullToBlank(inputItem.TotalAmount)),
							ProofDate : nullToBlank(inputItem.ProofDate),
							ProofDateStr : nullToBlank(inputItem.ProofDateStr),
							StoreName : nullToBlank(inputItem.StoreName).trim(),
							CardUID : nullToBlank(inputItem.CardUID),
							CardApproveNo : nullToBlank(inputItem.CardApproveNo),
							ReceiptID : nullToBlank(inputItem.ReceiptID),
							TaxInvoiceID : nullToBlank(inputItem.TaxInvoiceID),
							TaxUID : nullToBlank(inputItem.TaxUID),
							CashUID : nullToBlank(inputItem.CashUID),
							TaxNTSConfirmNum : nullToBlank(inputItem.TaxNTSConfirmNum),
							CashNTSConfirmNum : nullToBlank(inputItem.CashNTSConfirmNum),
						}
					}
					
					var DocLinkInputAreaStr = me.combiCostApp_htmlFormSetVal(me.pageCombiAppFormList.DocLinkInputFormStr, valMap);
					valMap.DocLinkInputArea = DocLinkInputAreaStr;
					
					var VendorInputAreaStr = me.combiCostApp_htmlFormSetVal(me.pageCombiAppFormList.VendorInputFormStr, valMap);
					valMap.VendorInputArea = VendorInputAreaStr;
					
					var getForm = me.combiCostApp_htmlFormSetVal(formStr, valMap);
					getForm = me.combiCostApp_htmlFormDicTrans(getForm);
					
					var divList = inputItem.divList;
					return getForm;
				}
			},


			//체크된 증빙 삭제
			combiCostApp_pageListDelete : function() {
				var me = this;
				var ProofCode = accountCtrl.getComboInfo("combiCostApp_inputProofCode").val();

				var fieldList =  accountCtrl.getInfoStr("[name=listCheck][proofcode="+ProofCode+"]:checked");
				if(fieldList.length==0){
					Common.Inform("<spring:message code='Cache.ACC_msg_noselectdata' />");
					return;
				}
		        Common.Confirm("<spring:message code='Cache.ACC_msg_ckDelete' />", "Confirmation Dialog", function(result){
		       		if(result){
						var pageList = me.combiCostApp_getPageList(ProofCode);
		
						for(var i=0;i<fieldList.length; i++){
					   		var checkedItem = fieldList[i];
							var KeyNo = checkedItem.getAttribute("keyno");
							
							var getItem = me.combiCostApp_findListItem(pageList, "KeyNo", KeyNo);
							var idx = accFindIdx(pageList, "KeyNo", KeyNo );
							me.pageExpenceAppEvidDeletedList.push(getItem)
		
							if(idx>=0){
								pageList.splice(idx,1);
							}
							accountCtrl.getInfoStr("[name=listArea][proofcode="+ProofCode+"][keyno="+KeyNo+"]").remove();
					   	}
		       		}
		        });
			},
			
			//세부증빙부분의 html 추가
			combiCostApp_makeInputDivHtmlAdd : function(inputItem, isAll) {
				var me = this;
				//DivBodyArea
				var ProofCode = inputItem.ProofCode;
				var KeyNo = inputItem.KeyNo;
				var divArea = accountCtrl.getInfoStr("[name=DivBodyArea][proofcode="+ProofCode+"][keyno="+KeyNo+"]")

				if(isAll){
					divArea.html("");
				}

				var formStr = me.pageCombiAppFormList["DivInputFormStr"];
				var divList = inputItem.divList;
				
				for (var y = 0; y<divList.length; y++) {
					var divItem = divList[y];
					
					if(nullToBlank(divItem.Amount) == ""){
						if(inputItem.ProofCode == "TaxBill") {
							divItem.Amount = divItem.RepAmount;
						} else {
							divItem.Amount = divItem.TotalAmount;
						}
					}
					
					var valMap = {
							
							RequestType : requestType,
							ExpenceApplicationListID : nullToBlank(inputItem.ExpenceApplicationListID),
							ViewKeyNo : nullToBlank(inputItem.ViewKeyNo),
							KeyNo : nullToBlank(inputItem.KeyNo),
							ProofCode : nullToBlank(inputItem.ProofCode),
							Rownum : nullToBlank(divItem.Rownum),
							
							AmountVal : toAmtFormat(divItem.Amount),
							accCDVal : nullToBlank(divItem.AccountCode),
							accNMVal : nullToBlank(divItem.AccountName),
							SBCDVal : nullToBlank(divItem.StandardBriefID),
							SBNMVal : nullToBlank(divItem.StandardBriefName),
							CCCDVal : nullToBlank(divItem.CostCenterCode),
							CCNMVal : nullToBlank(divItem.CostCenterName),
							IOCDVal : nullToBlank(divItem.IOCode),
							IONMVal : nullToBlank(divItem.IOName),
							UsageCommentVal : nullToBlank(divItem.UsageComment).replace(/<br>/gi, '\r\n'),
					}
					
					var getForm = me.combiCostApp_htmlFormSetVal(formStr, valMap);
					getForm = me.combiCostApp_htmlFormDicTrans(getForm);
					divArea.append(getForm);
					
					me.combiCostApp_makeDivHtmlChkColspan(inputItem.ProofCode, inputItem.KeyNo, divItem.Rownum);
				}
			},
			
			//세부증빙부분의 html 복사
			combiCostApp_makeInputDivHtmlAddCopy : function(inputItem, isAll) {
				var me = this;
				var ProofCode = inputItem.ProofCode;
				var KeyNo = inputItem.KeyNo;
				var divArea = accountCtrl.getInfoStr("[name=DivBodyArea][proofcode="+ProofCode+"][keyno="+KeyNo+"]");
				var formStr = me.pageCombiAppFormList["DivInputFormStr"];
				var divList = inputItem.divList;
				
				if(isAll){
					divArea.html("");
				}

				for(var y = 0; y<divList.length; y++){
					var divItem = divList[y];
					if(nullToBlank(divItem.Amount) == ""){
                        divItem.Amount = inputItem.ProofCode == "TaxBill" ? divItem.RepAmount : divItem.TotalAmount;
					}
					
					var valMap = {
							RequestType : requestType,
							ExpenceApplicationListID : nullToBlank(inputItem.ExpenceApplicationListID),
							ViewKeyNo : nullToBlank(inputItem.ViewKeyNo),
							KeyNo : nullToBlank(inputItem.KeyNo),
							ProofCode : nullToBlank(inputItem.ProofCode),
							Rownum : nullToBlank(divItem.Rownum),

							AmountVal : toAmtFormat(divItem.Amount),
							accCDVal : nullToBlank(divItem.AccountCode),
							accNMVal : nullToBlank(divItem.AccountName),
							SBCDVal : nullToBlank(divItem.StandardBriefID),
							SBNMVal : nullToBlank(divItem.StandardBriefName),
							CCCDVal : nullToBlank(divItem.CostCenterCode),
							CCNMVal : nullToBlank(divItem.CostCenterName),
							IOCDVal : nullToBlank(divItem.IOCode),
							IONMVal : nullToBlank(divItem.IOName),
							UsageCommentVal : nullToBlank(divItem.UsageComment).replace(/<br>/gi, '\r\n'),
					}
					
					var getForm = me.combiCostApp_htmlFormSetVal(formStr, valMap);
					getForm = me.combiCostApp_htmlFormDicTrans(getForm);
					divArea.append(getForm);
					
                    me.combiCostApp_setDivVal(ProofCode, 1, y, "CostCenterCode", divItem.CostCenterCode);
                    me.combiCostApp_setDivVal(ProofCode, 1, y, "CostCenterName", divItem.CostCenterName);
					
                    me.combiCostApp_setDivVal(ProofCode, 1, y, "AccountCode", divItem.AccountCode);
                    me.combiCostApp_setDivVal(ProofCode, 1, y, "AccountName", divItem.AccountName);
					
					me.combiCostApp_setDivVal(ProofCode, 1, y, "StandardBriefID", divItem.StandardBriefID);
					me.combiCostApp_setDivVal(ProofCode, 1, y, "StandardBriefName", divItem.StandardBriefName);
					
					me.combiCostApp_setDivVal(ProofCode, 1, y, "IOCode", divItem.IOCode);
					me.combiCostApp_setDivVal(ProofCode, 1, y, "IOName", divItem.IOName);
					
					me.combiCostApp_makeDivHtmlChkColspan(inputItem.ProofCode, inputItem.KeyNo, divItem.Rownum);
					
					accountCtrl.getInfoStr("[datafield=Amount][proofcode=" + ProofCode + "][rownum=" + y + "]").trigger("keyup");
					accountCtrl.getInfoStr("[name=DivCommentField][datafield=UsageComment]").trigger("keyup");
				}
				
                var divListItem = inputItem.divList[0];

				// 은행
			 	if(nullToBlank(divListItem.BankCode) != "") {
			 		$("[name=ComboSelect][field=AccountInfo]").val("DirectInput").prop("selected", true);
					$("[name=CombiCostInputField][field=AccountInfo]").val(nullToBlank(divListItem.BankAccountNo))	 	
			 	}
			 	$("[field=AccountHolder]").val(nullToBlank(divListItem.BankAccountName));
			 	$("[field=AccountBank]").val(nullToBlank(divListItem.BankCode));
			 	$("[field=AccountBankName]").val(nullToBlank(accComm.getBaseCodeName("Bank", nullToBlank(divListItem.BankCode), me.CompanyCode)))
				
				$("[field=PayType]").val(divListItem.PayType).change();     // 지급조건
				$("[field=PayMethod]").val(divListItem.PayMethod).change();
				$("[field=TaxType]").val(divListItem.TaxType).change();     // 세금유형
		 		$("[field=TaxCode]").val(divListItem.TaxCode).change();
		 		$("[field=PayTarget]").val(divListItem.PayTarget).change(); // 지금대상 
			 	$("[field=AlterPayeeName]").val(divListItem.AlterPayeeName).change();	// 대체숭취인
			 	$("[field=AlterPayeeNo]").val(divListItem.AlterPayeeNo).change();	    // 대체숭취인
			 	
			 	$("[name=ComboSelect][field=AccountInfo]").trigger("change");			 	
			 	$("[name=CombiCostInputField][field=AccountInfo]").trigger("keyup");
			 	$("[field=AccountHolder]").trigger("keyup");
			 	me.combiCostApp_setListVal(ProofCode, KeyNo, "AccountBank", nullToBlank(divListItem.BankCode));
				me.combiCostApp_setListVal(ProofCode, KeyNo, "AccountBankName", nullToBlank(accComm.getBaseCodeName("Bank", nullToBlank(divListItem.BankCode), me.CompanyCode)));
			},
			
			//세부증빙 추가
			combiCostApp_divAddOne : function(ProofCode, KeyNo) {
				var me = this;
				var pageList = me.combiCostApp_getPageList(ProofCode);
				
				for(var i = 0; i<pageList.length; i++){
					var item = pageList[i];
					if(item.KeyNo == KeyNo){
						if(item.divList == null){
							item.divList = [];
						}

						var divItem = {
								ExpenceApplicationDivID : ""
								, AccountCode :  ""
								, AccountName : ""
								, StandardBriefID :  ""
								, StandardBriefName : ""
								, CostCenterCode :  nullToBlank(me.pageCombiAppComboData.DefaultCC.CostCenterCode)
								, CostCenterName :  nullToBlank(me.pageCombiAppComboData.DefaultCC.CostCenterName)
								, IOCode : ""
								, IOName : ""
								, Amount : 0
								, UsageComment : ""
								, IsNew : true
								
								, ExpenceApplicationListID : item.ExpenceApplicationListID
								, ViewKeyNo : item.ViewKeyNo
								, KeyNo : item.KeyNo
								, ProofCode : item.ProofCode
						}
						var maxRN = ckNaN(item.maxRowNum);
						maxRN++;
						item.maxRowNum = maxRN;
						divItem.Rownum = maxRN;
						
						item.divList.push(divItem);
						me.combiCostApp_makeInputDivHtmlAddOne(divItem, ProofCode, KeyNo);
					}
				}
			},
			
			combiCostApp_divAddSubMulti: function (ProofCode, KeyNo, Type) { 
                var me = this;
                var ArrType = Type.split(";");

				for (var i = 0; i < ArrType.length; i++) {
					if(!me.combiCostApp_divAddSubCheck(ProofCode, KeyNo, ArrType[i])) {
						return;
						break;
					}
				}
                for (var i = 0; i < ArrType.length; i++) {
                    me.combiCostApp_divAddSub(ProofCode, KeyNo, ArrType[i]);
                }
            },
			
			combiCostApp_divAddSubCheck: function (ProofCode, KeyNo, Type) {
				var ret = true;
				var me = this;
				var pageList = me.combiCostApp_getPageList(ProofCode);
				var subAmount;
				
				for(var i = 0; i<pageList.length; i++){
					var item = pageList[i];
					if(item.KeyNo == KeyNo){
						
						if(Type == "TaxCodeSet") {
							subAmount = item.TaxAmount;					
						}else if (Type == "IncomeTaxCodeSet") {
							subAmount = item.IncomTaxAmt;
						} else if (Type == "LocalTaxCodeSet") {
							subAmount = item.LocalTaxAmt;
						} else { 
							subAmount = 0;
						}
						
						if (subAmount == 0 || subAmount == undefined) {
							Common.Inform(Common.getDic("ACC_msg_" + Type));
							return false;
						}
					}
				}
				return ret;
			},

			//세부증빙 추가 
			combiCostApp_divAddSub : function (ProofCode, KeyNo, Type) {
				var me = this;
				if(!me.combiCostApp_divAddSubCheck(ProofCode, KeyNo, Type)) {
					return;
				}
				var pageList = me.combiCostApp_getPageList(ProofCode);
				
				// 금액 세팅
				var subAmount;
								
				// 계정과목 표준적요 코드 가져오기				
				var codeSet = me.combiCostApp_SubCodeSet(Type);
				
				accountID = codeSet.SubCodeSet[0].AccountID;
                accountCode = codeSet.SubCodeSet[0].AccountCode;
                accountName = codeSet.SubCodeSet[0].AccountName;
                standardBriefID = codeSet.SubCodeSet[0].StandardBriefID;
				// standardBriefCode = codeSet.split(";")[4];
                standardBriefName =  codeSet.SubCodeSet[0].StandardBriefName;
				
				for(var i = 0; i<pageList.length; i++){
					var item = pageList[i];
					if(item.KeyNo == KeyNo){
						if(item.divList == null){
							item.divList = [];
						}
						
						if(Type == "TaxCodeSet") {	// 부가세추가버튼
							subAmount = item.TaxAmount;					
						}else if (Type == "IncomeTaxCodeSet") {	// 어떤애는 income 이고 어떤애는 ioncom 이고 맨뒤에 e가 있다 없다함... 장난치나......
                            subAmount = item.IncomTaxAmt;
                        } else if (Type == "LocalTaxCodeSet") {
                            subAmount = item.LocalTaxAmt;
                        } else { 
							subAmount = 0;
						}
						
						var divList = item.divList;

						// 부가세가 이미 만들어져있으면 안되게
                        // 부가세 있는거 체크하기
                        for (var y = 0; y < divList.length; y++) {
                            var divItem = divList[y];

                            if (divItem.StandardBriefID == standardBriefID) {
                            	// Common.Inform("<spring:message code='Cache.ACC_msg_" + Type + "dup' />");  // 부가세가 0원이라 추가하면 안된다.
                                Common.Inform(Common.getDic("ACC_msg_" + Type + "Dup")); // 부가세가 이미 추가되어있습니다.
                                return;
                            }
                        }

						var divItem = {
								ExpenceApplicationDivID : ""
								, AccountCode :  accountCode
								, AccountName : accountName
								, StandardBriefID :  standardBriefID
								, StandardBriefName : standardBriefName
								, CostCenterCode :  nullToBlank(me.pageCombiAppComboData.DefaultCC.CostCenterCode)
								, CostCenterName :  nullToBlank(me.pageCombiAppComboData.DefaultCC.CostCenterName)
								, IOCode : ""
								, IOName : ""
								, Amount : subAmount
								, UsageComment : ""
								, IsNew : true
								
								, ExpenceApplicationListID : item.ExpenceApplicationListID
								, ViewKeyNo : item.ViewKeyNo
								, KeyNo : item.KeyNo
								, ProofCode : item.ProofCode
						}
						var maxRN = ckNaN(item.maxRowNum);
						maxRN++;
						item.maxRowNum = maxRN;
						divItem.Rownum = maxRN;
						
						item.divList.push(divItem);
						me.combiCostApp_makeInputDivHtmlAddOne(divItem, ProofCode, KeyNo);
						
						accountCtrl.getInfoStr("[name=DivSBCd][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+maxRN+"]").siblings("button").remove();
					}
				}
			},
			
			//추가된 세부증빙 html 생성
			combiCostApp_makeInputDivHtmlAddOne : function(divItem, ProofCode, KeyNo) {
				var me = this;
				var ProofCode = divItem.ProofCode;
				var KeyNo = divItem.KeyNo;
				var divArea = accountCtrl.getInfoStr("[name=DivBodyArea][proofcode="+ProofCode+"][keyno="+KeyNo+"]");
				var formStr = me.pageCombiAppFormList["DivInputFormStr"];

				if(nullToBlank(divItem.Amount) == ""){
                	divItem.Amount = ProofCode == "TaxBill" ? divItem.RepAmount : divItem.TotalAmount;
				}
				
				var valMap = {
						RequestType: requestType,
						ExpenceApplicationListID : nullToBlank(divItem.ExpenceApplicationListID),
						ViewKeyNo : nullToBlank(divItem.ViewKeyNo),
						KeyNo : nullToBlank(divItem.KeyNo),
						ProofCode : nullToBlank(divItem.ProofCode),
						Rownum : nullToBlank(divItem.Rownum),
						
						AmountVal : toAmtFormat(divItem.Amount),
						accCDVal : nullToBlank(divItem.AccountCode),
						accNMVal : nullToBlank(divItem.AccountName),
						SBCDVal : nullToBlank(divItem.StandardBriefID),
						SBNMVal : nullToBlank(divItem.StandardBriefName),
						CCCDVal : nullToBlank(divItem.CostCenterCode),
						CCNMVal : nullToBlank(divItem.CostCenterName),
						IOCDVal : nullToBlank(divItem.IOCode),
						IONMVal : nullToBlank(divItem.IOName),
						UsageCommentVal : nullToBlank(divItem.UsageComment).replace(/<br>/gi, '\r\n'),
				}

				var getForm = me.combiCostApp_htmlFormSetVal(formStr, valMap);
				getForm = me.combiCostApp_htmlFormDicTrans(getForm);
				divArea.append(getForm);

				me.combiCostApp_makeDivHtmlChkColspan(ProofCode, KeyNo, divItem.Rownum);
			},
			
			combiCostApp_makeDivHtmlChkColspan : function(ProofCode, KeyNo, Rownum) {
			   	if(isUseIO == "N") {
			   		accountCtrl.getInfoName("noIOArea").hide();
			   	}
			   	if(isUseSB == "N") {
			   		accountCtrl.getInfoName("noSBArea").hide();
			   	} else {
			   		accountCtrl.getInfoStr(".total_acooungting_table th[name=noSBArea]").prev().find("span").remove();
			   		var accNM =  accountCtrl.getInfoStr("[name=DivAccNm][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]");
			   		$(accNM).parent().find("button").remove();
			   	}
			   	if(isUseBD == "" || isUseBD == "N") {
			   		accountCtrl.getInfoName("noBDArea").hide();
			   	}
			},
			
			//세부증빙 삭제
			combiCostApp_divDelete : function(ProofCode, KeyNo) {
				var me = this;

				var fieldList =  accountCtrl.getInfoStr("[name=DivCheck][proofcode="+ProofCode+"][keyno="+KeyNo+"]:checked");
				var fieldMaxList =  accountCtrl.getInfoStr("[name=DivCheck][proofcode="+ProofCode+"][keyno="+KeyNo+"]");
				if(fieldList.length==0){
					Common.Inform("<spring:message code='Cache.ACC_msg_noselectdata' />");
					return;
				}
				if(fieldList.length == fieldMaxList.length){
					Common.Inform("<spring:message code='Cache.ACC_045' />");
					return;
				}
		        Common.Confirm("<spring:message code='Cache.ACC_msg_ckDelete' />", "Confirmation Dialog", function(result){
		       		if(result){
						var pageList = me.combiCostApp_getPageList(ProofCode);
						
						
					   	for(var i=0;i<fieldList.length; i++){
					   		var checkedItem = fieldList[i];
							var Rownum = checkedItem.getAttribute("rownum");							
		
							var getItem = me.combiCostApp_findListItem(pageList, "KeyNo", KeyNo);
							var divList = getItem.divList;
							var idx = accFindIdx(divList, "Rownum", Rownum );
							if(idx>=0){
								//출장항목(일비, 유류비) 증빙분할 삭제 시 합계된 청구금액 빼기
					    		if(divList[idx].ReservedStr2_Div != undefined) {
						    		if('D02' in divList[idx].ReservedStr2_Div || 'D03' in divList[idx].ReservedStr2_Div || 'Z09' in divList[idx].ReservedStr2_Div) {
										var totalAmount = AmttoNumFormat(accountCtrl.getInfoStr("[name=CombiCostInputField][tag=Amount][proofcode="+ProofCode+"][keyno="+KeyNo+"]").val());
										var delAmount = AmttoNumFormat(divList[idx].Amount);
										
										accountCtrl.getInfoStr("[name=CombiCostInputField][tag=Amount][proofcode="+ProofCode+"][keyno="+KeyNo+"]").val(toAmtFormat(parseInt(totalAmount) - parseInt(delAmount)));
									}
					    		}
								
								divList.splice(idx,1);
								//getItem.maxRowNum = Number(getItem.maxRowNum) - 1;
							}
							accountCtrl.getInfoStr("[name=DivRowTR][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").remove();
					   	}
		       		}
		        });
			},
			
			//상단부에서 입력된 증빙을 하단부에 추가
			combiCostApp_pageListSave : function(){
				var me = this;
				var ProofCode = accountCtrl.getComboInfo("combiCostApp_inputProofCode").val();
				var pageList = me.combiCostApp_getPageList(ProofCode);

				//accComm.setDeadlineInfo();
				if(pageList.length==0){
					Common.Inform("<spring:message code='Cache.ACC_msg_noSaveData' />");
				}

				//msg_EnterTheRequiredValue
				me.combiCostApp_getExpAppEvidDate(pageList);

				var BriefMap = me.pageCombiAppComboData.BriefMap;
				for(var i = 0; i<pageList.length; i++){
					var item = pageList[i];
					var divList = item.divList;
					var divSum = 0;
					
					var fileList = item.fileList;
					var uploadFileList = item.uploadFileList;
					var docList = item.docList;
					
					item.PostingDate = item.ProofDate;
					item.PostingDateStr = item.ProofDateStr;
					
					if(divList==null){
						var msg = "<spring:message code='Cache.ACC_019' />";
						Common.Inform(msg);
						return;
					}
					if(divList.length==0){
						var msg = "<spring:message code='Cache.ACC_019' />";
						Common.Inform(msg);
						return;
					}

					if(isEmptyStr(item.TotalAmount)){
						var msg = "<spring:message code='Cache.ACC_052' />";
						Common.Inform(msg);
						return;
					}
					
					if(isEmptyStr(item.ProofDate)){
						var msg = "<spring:message code='Cache.ACC_053' />";
						Common.Inform(msg);
						return;
					}
					if(isEmptyStr(item.PostingDate)){
						var msg = "<spring:message code='Cache.ACC_056' />";
						Common.Inform(msg);
						return;
					}
					
					if(item.ProofCode == "CorpCard" && isEmptyStr(item.VendorNo)) {
						item.VendorNo = Common.getSession("UR_Code");
					}
					
					//useWriteVendor == Y
					if(item.ProofCode == "EtcEvid" && Common.getBaseConfig("useWriteVendor", sessionObj["DN_ID"]) == "Y") {
						if(isEmptyStr(item.VendorNo)){
							var msg = "<spring:message code='Cache.ACC_msg_emptyVendorNo' />"; //사업자번호가 입력되지 않았으므로 저장 시 자동으로 사업자번호가 발번됩니다.
							Common.Inform(msg);
						}
						if(isEmptyStr(item.VendorName)){
							var msg = "<spring:message code='Cache.ACC_msg_emptyVendorName' />"; //거래처명이 입력되지 않은 항목이 있습니다.
							Common.Inform(msg);
							return;
						}
					} else {
						if(isEmptyStr(item.VendorNo)){
							var msg = "<spring:message code='Cache.ACC_054' />";
							Common.Inform(msg);
							return;
						}
					}
					/* if(item.TaxType != "notApplicable"){
						if(isEmptyStr(item.TaxCode) || isEmptyStr(item.TaxType)) {
							var msg = "<spring:message code='Cache.ACC_057' />";
							Common.Inform(msg);
							return;
						}
					} */
					
					if(item.ProofCode == "PrivateCard"
						&&isEmptyStr(item.PersonalCardNo)
							){
						var msg = "<spring:message code='Cache.ACC_055' />";
						Common.Inform(msg);
						return;
					}
					
					//마감일자 체크 주석처리
			   		/* if(accComm.accDeadlineCk(item.PayDate) == false){
						var msg = "<spring:message code='Cache.ACC_044' />";
						var deadline = accComm.getDeadlindDate();
						msg = msg.replace("@@{date}", deadline);
						Common.Inform(msg);
						return;
			   		} */
			   		
			   		/* if(item.ProofCode == "EtcEvid"
			   				&& Number(AmttoNumFormat(item.TotalAmount)) != (Number(AmttoNumFormat(item.RepAmount)) + Number(AmttoNumFormat(item.TaxAmount)))) {
						var msg = "공급가액과 부가세의 합이 합계금액과 일치하지 않습니다.";
						Common.Inform(msg);
						return;
			   		} */
			   		
			   		if((item.ProofCode == "TaxBill" || item.ProofCode == "CashBill" || item.ProofCode == "EtcEvid") && isEmptyStr(item.PayMethod)) {
			   			var msg = "지급방법이 선택되지 않았습니다.";
						Common.Inform(msg);
						return;
			   		}
					
					for(var y = 0; y<divList.length; y++){
						var divItem = divList[y];
						var divAmt = divItem.Amount;
						
						divSum= divSum+ckNaN(AmttoNumFormat(divAmt))

						if(Common.getBaseConfig("IsUseStandardBrief") == "Y" && isEmptyStr(divItem.StandardBriefID)){
							var msg = "<spring:message code='Cache.ACC_050' />";
							Common.Inform(msg);
							return;							
						}
						if(isEmptyStr(divItem.AccountCode)){
							var msg = "<spring:message code='Cache.ACC_060' />";
							Common.Inform(msg);
							return;
						}
						if(isEmptyStr(divItem.CostCenterCode)){
							var msg = "<spring:message code='Cache.ACC_059' />";
							Common.Inform(msg);
							return;
							
						}
						
						/*
						if(isEmptyStr(divItem.IOCode)){
							var msg = "<spring:message code='Cache.ACC_058' />";
							Common.Inform(msg);
							return;
						}
						*/
				   		/* var ckNaNVal = AmttoNumFormat(divItem.Amount);
				   		caNaNVal = ckNaN(ckNaNVal);
				   		if(caNaNVal == 0){
							var msg = "<spring:message code='Cache.ACC_lbl_amtValidateErr' />";
							Common.Inform(msg);
							return;
				   			break;
				   		} */

				   		if(isEmptyStr(divItem.UsageComment)){
							var msg = "<spring:message code='Cache.ACC_046' />";
							Common.Inform(msg);
							return;
				   			break;
				   		}
				   		
						var getDivAmt = nullToBlank(divItem.Amount);
						getDivAmt = Number(AmttoNumFormat(getDivAmt));
						if(isNaN(getDivAmt)){
							var msg = "<spring:message code='Cache.ACC_lbl_amtValidateErr' />";
							Common.Inform(msg);
							return;
						}
						
						//표준적요별 파일첨부, 문서연결 필수 여부 체크
						var BriefInfo = BriefMap[divItem.StandardBriefID];
						if(BriefInfo.IsFile=='Y'){
							if ((!fileList || fileList.length == 0) && (!uploadFileList || uploadFileList.length == 0)) {
								var msg = "<spring:message code='Cache.ACC_msg_Require_AttchFile' />";//파일첨부 필수입니다
								Common.Inform(msg);
								return;
								break;
							}
						} 
						
						if(BriefInfo.IsDocLink=='Y'){
							if (!docList || docList.length == 0) {
								var msg = "<spring:message code='Cache.ACC_msg_Require_DocLink' />";//문서연결 필수입니다
								Common.Inform(msg);
								return;
								break;
							}
						}
						
						//관리항목 (ACC_CTRL) 필수체크 추가
	                    var reqchk = true;
	                    accountCtrl.getInfoStr("input[keyno=" + item.KeyNo + "][rownum=" + divItem.Rownum + "][requiredVal=required][code],div[keyno=" + item.KeyNo + "][rownum=" + divItem.Rownum + "][requiredVal=required][code],select[keyno=" + item.KeyNo + "][rownum=" + divItem.Rownum + "][requiredVal=required][code]").each(function(i, item){
	                        if($(item).val() == "" && $(item).attr("viewtype") != "Date"){
	                        	var msg = $(item).closest("dd").prev().text() + "<spring:message code='Cache.ACC_msg_required' />"
	                            Common.Inform(msg);

	                            reqchk = false;
	                            return false;
	                        }else{
	                            if($(item).find("input[code]").val() == ""){
	                            	var msg = $(item).closest("dd").prev().text() + "<spring:message code='Cache.ACC_msg_required' />"
	                                Common.Inform(msg);

	                                reqchk = false;
	                                return false;
	                            }
	                        }
	                    });
	                    if(!reqchk) return;
					}
					
					if(ckNaN(AmttoNumFormat(Math.abs(item.TotalAmount))) < Math.abs(divSum)){
						var msg = "<spring:message code='Cache.ACC_015' />"; // 항목의 세부비용의 합계금액이 증빙금액보다 클 수 없습니다.
						Common.Inform(msg);
						return;
					}
					
					if(item.ProofCode == "TaxBill") {
						// [2023.09.23] 부가세추가 버튼 제거(세금계산서일 경우만) "청구금액" => "청구금액(공급가액)" 으로 표시변경. 상단청구금액을 세액합산하므로 세액을 합한하여 Validation 할 필요가 없음. (hgsong, 회계팀)
						// 증빙의 청구금액(공급가액) + 부가세액 이 계산서의 총금액을 초과할 경우만 Validation 처리.
						//if(ckNaN(AmttoNumFormat(item.TotalAmount)) != divSum) { //부가세추가 버튼 통해 부가세 세부증빙 추가 시 청구금액 합과 합계금액이 동일하여 아래 체크 로직 실행 필요 X
							if(ckNaN(AmttoNumFormat(item.TotalAmount)) != divSum + Number(item.TaxAmount)){
							    var msg = "전체 청구금액과 세액의 합이 합계금액과 다릅니다.";
								Common.Inform(msg);
								return;
							} else {
								divSum = divSum + item.TaxAmount; //상단 청구금액 표시에는 전체 청구금액 + 세액으로 표시되도록
							}
						//}
					}
					item.divSum = divSum;
				}
				
				for(var i = 0; i<pageList.length; i++){
					var item = pageList[i];
					item.PayDate = me.pageExpenceAppObj.PayDate;
					item.PayDateStr = me.pageExpenceAppObj.PayDateStr;
					if(item.ViewKeyNo != null){
						var getItem = me.combiCostApp_findListItem(me.pageExpenceAppEvidList, "ViewKeyNo", item.ViewKeyNo);
						if(!isEmptyStr(getItem.ViewKeyNo)){
							var idx = accFindIdx(me.pageExpenceAppEvidList, "ViewKeyNo", item.ViewKeyNo );
							me.pageExpenceAppEvidList[idx] = item;
							me.combiCostApp_changeHtmlViewFormOne(item)
						}
						else{
							me.maxViewKeyNo++;
							item.ViewKeyNo = me.maxViewKeyNo;
							me.pageExpenceAppEvidList.push(item);
							me.combiCostApp_addHtmlViewFormOne(item);
						}
					}
					else{
						me.maxViewKeyNo++;
						item.ViewKeyNo = me.maxViewKeyNo;
						me.pageExpenceAppEvidList.push(item);
						me.combiCostApp_addHtmlViewFormOne(item);
					}
				}

				me.combiCostAppCC_CorpCardDataInit();
				me.combiCostAppTB_TaxBillDataInit();
				me.combiCostAppPB_PaperBillDataInit();
				me.combiCostAppCB_CashBillDataInit();
				me.combiCostAppPC_PrivateCardDataInit();
				me.combiCostAppEE_EtcEvidDataInit();
				me.combiCostAppMR_ReceiptDataInit();

				me.combiCostApp_pageAmtSet();
			},

			//증빙 코드를 통해 각 증빙페이지의 list 반환
			combiCostApp_getPageList : function(ProofCode){
				var me = this;
				if(ProofCode=="CorpCard"){
					return me.cardPageExpenceAppList;
				}
				else if(ProofCode=="TaxBill"){
					return me.taxBillPageExpenceAppList;
				}
				else if(ProofCode=="PaperBill"){
					return me.paperBillPageExpenceAppList;
				}
				else if(ProofCode=="CashBill"){
					return me.cashBillPageExpenceAppList;
				}
				else if(ProofCode=="PrivateCard"){
					return me.privateCardPageExpenceAppList;
				}
				else if(ProofCode=="EtcEvid"){
					return me.etcEvidPageExpenceAppList;
				}
				else if(ProofCode=="Receipt"){
					return me.receiptPageExpenceAppList;
				}
			},

			//계정 입력 팝업 호출
			combiCostApp_callAccountPopup : function(ProofCode, KeyNo, Rownum) {
				var me = this;
				me.tempObj.ProofCode = ProofCode;
				me.tempObj.KeyNo = KeyNo;
				me.tempObj.Rownum = Rownum;
				var info = {
						popupUrl		: "/account/accountCommon/accountCommonPopup.do",
						popupID 		: "accountSearchPopup",
						popupTit 		: "<spring:message code='Cache.ACC_lbl_account'/>",
						popupName 		: "AccountSearchPopup",
						callBackFunc 	: "combiCostApp_setDivAccVal",
						includeAccount 	: "N",
						companyCode 	: me.CompanyCode
				}
				var url = me.makeObjPopupUrl(info);
				Common.open(	"",info.popupID,info.popupTit,url,"740px","690px","iframe",true,null,null,true);
			},
			
			//선택된 계정 세팅
			combiCostApp_setDivAccVal : function(info) {
				var me = this;
				
				var ProofCode = me.tempObj.ProofCode;
				var Rownum = me.tempObj.Rownum;
				
				var checkResult = accountCtrl.getInfo("chk_info").is(":checked");

				if(checkResult){
					var fieldList =  accountCtrl.getInfoStr("[name=listCheck][proofcode="+ProofCode+"]");
					var a = fieldList.length;
					
					for(var i=1; i<=fieldList.length; i++){
						var cdField = accountCtrl.getInfoStr("[name=DivAccCd][proofcode="+ProofCode+"][keyno="+i+"][rownum="+Rownum+"]");
						var nmField = accountCtrl.getInfoStr("[name=DivAccNm][proofcode="+ProofCode+"][keyno="+i+"][rownum="+Rownum+"]");
						me.combiCostApp_setDivVal(ProofCode, i, Rownum, "AccountCode", info.AccountCode);
						me.combiCostApp_setDivVal(ProofCode, i, Rownum, "AccountName", info.AccountName);
						cdField.val(info.AccountCode);
						nmField.val(info.AccountName);
						
					}
				}else{
					var KeyNo = me.tempObj.KeyNo;
					
					var cdField = accountCtrl.getInfoStr("[name=DivAccCd][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]");
					var nmField = accountCtrl.getInfoStr("[name=DivAccNm][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]");
					me.combiCostApp_setDivVal(ProofCode, KeyNo, Rownum, "AccountCode", info.AccountCode);
					me.combiCostApp_setDivVal(ProofCode, KeyNo, Rownum, "AccountName", info.AccountName);
					cdField.val(info.AccountCode);
					nmField.val(info.AccountName);

					me.tempObj = {};
				}
			},

			//표준적요 입력 팝업 호출
			combiCostApp_callStandardBriefPopup : function(ProofCode, KeyNo, Rownum) {
				var me = this;
				me.tempObj.ProofCode = ProofCode;
				me.tempObj.KeyNo = KeyNo;
				me.tempObj.Rownum = Rownum;
				var info = {
						popupUrl		: "/account/accountCommon/accountCommonPopup.do",
						popupID 		: "standardBriefSearchPopup",
						popupTit 		: "<spring:message code='Cache.ACC_standardBrief'/>",
						popupName 		: "StandardBriefSearchPopup",
						callBackFunc 	: "combiCostApp_setDivSBVal",
						includeAccount 	: "N",
						companyCode 	: me.CompanyCode,
						StandardBriefSearchStr : Base64.utf8_to_b64(accComm[requestType].pageExpenceFormInfo.StandardBriefSearchStr)
				}
				var url = me.makeObjPopupUrl(info);
				Common.open(	"",info.popupID,info.popupTit,url,"1000px","710px","iframe",true,null,null,true);
			},
			
			//선택된 표준적요 세팅
			combiCostApp_setDivSBVal : function(info) {
				var me = this;
				
				var ProofCode = me.tempObj.ProofCode;
				var Rownum = me.tempObj.Rownum;

				var checkResult = accountCtrl.getInfo("chk_info").is(":checked");
				var BriefMap = me.pageCombiAppComboData.BriefMap;
				var Item = BriefMap[info.StandardBriefID];
				if(checkResult){
					var fieldList =  accountCtrl.getInfoStr("[name=listCheck][proofcode="+ProofCode+"]");
					
					for(var i=1; i<=fieldList.length; i++){
						if(accountCtrl.getInfoStr("[name=DivSBCd][proofcode="+ProofCode+"][keyno="+i+"]").attr('rownum')==Rownum)
						{
							accountCtrl.getInfoStr("[name=ComboSelect][proofcode="+ProofCode+"][keyno="+i+"][field=TaxType]").val(Item.TaxType).change();
							accountCtrl.getInfoStr("[name=ComboSelect][proofcode="+ProofCode+"][keyno="+i+"][field=TaxCode]").val(Item.TaxCode).change();
						}
						
						accountCtrl.getInfoStr("[name=DivAmountField][proofcode="+ProofCode+"][keyno="+i+"][rownum="+Rownum+"]").removeAttr('disabled');
						
						var sbCdField = accountCtrl.getInfoStr("[name=DivSBCd][proofcode="+ProofCode+"][keyno="+i+"][rownum="+Rownum+"]");
						var sbNmField = accountCtrl.getInfoStr("[name=DivSBNm][proofcode="+ProofCode+"][keyno="+i+"][rownum="+Rownum+"]");
						me.combiCostApp_setDivVal(ProofCode, i, Rownum, "StandardBriefID", info.StandardBriefID);
						me.combiCostApp_setDivVal(ProofCode, i, Rownum, "StandardBriefName", info.StandardBriefName);
						sbCdField.val(info.StandardBriefID);
						sbNmField.val(info.StandardBriefName);
						
						var accCdField = accountCtrl.getInfoStr("[name=DivAccCd][proofcode="+ProofCode+"][keyno="+i+"][rownum="+Rownum+"]");
						var accNmField = accountCtrl.getInfoStr("[name=DivAccNm][proofcode="+ProofCode+"][keyno="+i+"][rownum="+Rownum+"]");
						me.combiCostApp_setDivVal(ProofCode, i, Rownum, "AccountCode", info.AccountCode);
						me.combiCostApp_setDivVal(ProofCode, i, Rownum, "AccountName", info.AccountName);
						accCdField.val(info.AccountCode);
						accNmField.val(info.AccountName);
						
						accountCtrl._setCtrlField(me, nullToBlank(info.CtrlCode), KeyNo, Rownum, ProofCode,null);
						accountCtrl._onSaveJson(me, null, "CtrlArea", ProofCode, KeyNo, Rownum);
						
						/* var taxType = [];
						var taxCode = [];
						
						taxType[i] = accountCtrl.getInfoStr("[name=ComboSelect][proofcode="+ProofCode+"][keyno="+i+"][field=TaxType]");
						taxCode[i] = accountCtrl.getInfoStr("[name=ComboSelect][proofcode="+ProofCode+"][keyno="+i+"][field=TaxCode]");
						me.combiCostApp_setListVal(ProofCode, i, Rownum, "TaxType", info.TaxType);
						me.combiCostApp_setListVal(ProofCode, i, Rownum, "TaxCode", info.TaxCode);
						taxType[i].val(info.TaxType);
						taxCode[i].val(info.TaxCode);
						
						setTimeout(function() {
							taxType[i].trigger("change");				
						}, 10);
						setTimeout(function() {
							taxCode[i].trigger("change");	
						}, 20); */
					}
				} else {
					var KeyNo = me.tempObj.KeyNo;
					if(accountCtrl.getInfoStr("[name=DivSBCd][proofcode="+ProofCode+"][keyno="+KeyNo+"]").attr('rownum')==Rownum)
					{
						accountCtrl.getInfoStr("[name=ComboSelect][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=TaxType]").val(Item.TaxType).change();
						accountCtrl.getInfoStr("[name=ComboSelect][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=TaxCode]").val(Item.TaxCode).change();
					}

					accountCtrl.getInfoStr("[name=DivAmountField][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").removeAttr('disabled');
					
					var sbCdField = accountCtrl.getInfoStr("[name=DivSBCd][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]");
					var sbNmField = accountCtrl.getInfoStr("[name=DivSBNm][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]");
					me.combiCostApp_setDivVal(ProofCode, KeyNo, Rownum, "StandardBriefID", info.StandardBriefID);
					me.combiCostApp_setDivVal(ProofCode, KeyNo, Rownum, "StandardBriefName", info.StandardBriefName);
					sbCdField.val(info.StandardBriefID);
					sbNmField.val(info.StandardBriefName);
					
					
					var accCdField = accountCtrl.getInfoStr("[name=DivAccCd][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]");
					var accNmField = accountCtrl.getInfoStr("[name=DivAccNm][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]");
					me.combiCostApp_setDivVal(ProofCode, KeyNo, Rownum, "AccountCode", info.AccountCode);
					me.combiCostApp_setDivVal(ProofCode, KeyNo, Rownum, "AccountName", info.AccountName);
					accCdField.val(info.AccountCode);
					accNmField.val(info.AccountName);
					
					accountCtrl._setCtrlField(me, nullToBlank(info.CtrlCode), KeyNo, Rownum, ProofCode,null);
					accountCtrl._onSaveJson(me, null, "CtrlArea", ProofCode, KeyNo, Rownum);
					
					/* var taxType = accountCtrl.getInfoStr("[name=ComboSelect][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=TaxType]");
					var taxCode = accountCtrl.getInfoStr("[name=ComboSelect][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=TaxCode]");
					me.combiCostApp_setListVal(ProofCode, KeyNo, Rownum, "TaxType", info.TaxType);
					me.combiCostApp_setListVal(ProofCode, KeyNo, Rownum, "TaxCode", info.TaxCode);
					taxType.val(info.TaxType);
					taxCode.val(info.TaxCode);
					
					setTimeout(function() {
						taxType.trigger("change");				
					}, 10);
					setTimeout(function() {
						taxCode.trigger("change");	
					}, 20); */
					
					me.tempObj = {};
				}
				
				me.combiCostApp_pageAmtSet();
			},
			
			//CC팝업 호출
			combiCostApp_callCostCenterPopup : function(ProofCode, KeyNo, Rownum) {
				var me = this
				me.tempObj.ProofCode = ProofCode;
				me.tempObj.KeyNo = KeyNo;
				me.tempObj.Rownum = Rownum;
				var info = {
						popupUrl		: "/account/accountCommon/accountCommonPopup.do",
						popupID 		: "ccSearchPopup",
						popupTit 		: "<spring:message code='Cache.ACC_lbl_costCenter'/>",
						popupName 		: "CostCenterSearchPopup",
						callBackFunc 	: "combiCostApp_setDivCCVal",
						includeAccount 	: "N",
						companyCode 	: me.CompanyCode,
						popupType		: Common.getBaseConfig("IsUseIO") == "Y" ? "CC" : ""
				}
				var url = me.makeObjPopupUrl(info);
				Common.open(	"",info.popupID,info.popupTit,url,"600px","730px","iframe",true,null,null,true);
			},
			combiCostApp_setDivCCVal : function(info) {
				var me = this;

				var ProofCode = me.tempObj.ProofCode;
				var Rownum = me.tempObj.Rownum;
				
				var checkResult = accountCtrl.getInfo("chk_info").is(":checked");

				if(checkResult){
					var fieldList =  accountCtrl.getInfoStr("[name=listCheck][proofcode="+ProofCode+"]");
					var a = fieldList.length;
					
					for(var i=1; i<=fieldList.length; i++){
						var cdField = accountCtrl.getInfoStr("[name=DivCCCd][proofcode="+ProofCode+"][keyno="+i+"][rownum="+Rownum+"]");
						var nmField = accountCtrl.getInfoStr("[name=DivCCNm][proofcode="+ProofCode+"][keyno="+i+"][rownum="+Rownum+"]");
						me.combiCostApp_setDivVal(ProofCode, i, Rownum, "CostCenterCode", info.CostCenterCode);
						me.combiCostApp_setDivVal(ProofCode, i, Rownum, "CostCenterName", info.CostCenterName);
						cdField.val(info.CostCenterCode);
						nmField.val(info.CostCenterName);
						
					}
				}else{
					var KeyNo = me.tempObj.KeyNo;
					
					var cdField = accountCtrl.getInfoStr("[name=DivCCCd][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]");
					var nmField = accountCtrl.getInfoStr("[name=DivCCNm][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]");
					me.combiCostApp_setDivVal(ProofCode, KeyNo, Rownum, "CostCenterCode", info.CostCenterCode);
					me.combiCostApp_setDivVal(ProofCode, KeyNo, Rownum, "CostCenterName", info.CostCenterName);
					cdField.val(info.CostCenterCode);
					nmField.val(info.CostCenterName);

					me.tempObj = {};
				}
			},

			//IO팝업 호출
			combiCostApp_callIOPopup : function(ProofCode, KeyNo, Rownum) {
				var me = this;
				me.tempObj.ProofCode = ProofCode;
				me.tempObj.KeyNo = KeyNo;
				me.tempObj.Rownum = Rownum;
				var info = {
						popupUrl		: "/account/accountCommon/accountCommonPopup.do",
						popupID 		: "ioSearchPopup",
						popupTit 		: "<spring:message code='Cache.ACC_lbl_projectName'/>",
						popupName 		: "BaseCodeSearchPopup",
						callBackFunc 	: "combiCostApp_setDivIOVal",
						includeAccount 	: "N",
						companyCode 	: me.CompanyCode,
						codeGroup		: "IOCode"
				}
				var url = me.makeObjPopupUrl(info);
				Common.open(	"",info.popupID,info.popupTit,url,"600px","650px","iframe",true,null,null,true);
			},
			combiCostApp_setDivIOVal : function(info) {
				var me = this;

				var ProofCode = me.tempObj.ProofCode;
				var Rownum = me.tempObj.Rownum;
				
				var checkResult = accountCtrl.getInfo("chk_info").is(":checked");

				if(checkResult){
					var fieldList =  accountCtrl.getInfoStr("[name=listCheck][proofcode="+ProofCode+"]");
					var a = fieldList.length;
					
					for(var i=1; i<=fieldList.length; i++){
						var cdField = accountCtrl.getInfoStr("[name=DivIOCd][proofcode="+ProofCode+"][keyno="+i+"][rownum="+Rownum+"]");
						var nmField = accountCtrl.getInfoStr("[name=DivIONm][proofcode="+ProofCode+"][keyno="+i+"][rownum="+Rownum+"]");
						me.combiCostApp_setDivVal(ProofCode, i, Rownum, "IOCode", info.Code);
						me.combiCostApp_setDivVal(ProofCode, i, Rownum, "IOName", info.CodeName);
						cdField.val(info.Code);
						nmField.val(info.CodeName);
						
					}
				}else{
					var KeyNo = me.tempObj.KeyNo;
					
					var cdField = accountCtrl.getInfoStr("[name=DivIOCd][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]");
					var nmField = accountCtrl.getInfoStr("[name=DivIONm][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]");
					me.combiCostApp_setDivVal(ProofCode, KeyNo, Rownum, "IOCode", info.Code);
					me.combiCostApp_setDivVal(ProofCode, KeyNo, Rownum, "IOName", info.CodeName);
					cdField.val(info.Code);
					nmField.val(info.CodeName);

					me.tempObj = {};
				}
			},
			
			//세부증빙의 값이 변경되었을 시 내부 list에값 세팅
			combiCostApp_divInputChange : function(obj, ProofCode, KeyNo, Rownum, jsonVal, type) {
				var me = this;
				var field;
				var val;
				if(jsonVal != undefined ) {
					if(type == "1"){
	                   	field = "ReservedStr2_Div";
						val = jsonVal;
		            }else if(type == "2"){
		               	field = "ReservedStr3_Div";
		                val = jsonVal;
		            }
				} else {
					var getName = obj.name;
					var getId = obj.id
					var getTag = obj.getAttribute("tag");
					field = obj.getAttribute("datafield");
				
					val = obj.value;

					if(getTag == "Amount"){
						val = val.charAt(0) == "-" ? val.charAt(0) + val.substr(1).replace(/[^0-9,.]/g, "") : val.replace(/[^0-9,.]/g, "");
						var numVal = ckNaN(AmttoNumFormat(val));
						if(numVal>99999999999){
							numVal = 99999999999;
						}
						val = numVal;
						obj.value = toAmtFormat(numVal);
					} else if(getTag == "Comment") {
						val = val.replace(/(?:\r\n|\r|\n)/gi, '<br>');
					}
				}
				me.combiCostApp_setDivVal(ProofCode, KeyNo, Rownum, field, val);
			},
			 
			//콤보 변경시 값 세팅과 추가 처리
			combiCostApp_ComboChange : function(obj, ProofCode, KeyNo, Field, Rownum) {
				var me = this;
				
				var val = obj.value;
				var pageList = me.combiCostApp_getPageList(ProofCode);
				var getItem = me.combiCostApp_findListItem(pageList, "KeyNo", KeyNo);

				me.combiCostApp_setListVal(ProofCode, KeyNo, Field, val);

				if(Field=="TaxType"){
					var TCList = me.pageCombiAppComboData.TaxCodeList;
					var TaxCodeOption = me.combiCostApp_makeTCData(ProofCode, TCList, val);
					
					var TCField = accountCtrl.getInfoStr("[name=ComboSelect][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=TaxCode]");
					TCField.html(TaxCodeOption);
					if($(TCField).find("option").length == 2) {
						$(TCField).find("option").eq(1).attr("selected", "selected");
						$(TCField).trigger("change");
					}
				}
				
				if(Field=="IncomTax" || Field=="LocalTax"){
					var taxField = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field="+Field+"Amt]");
					var totalAmount = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=TotalAmount]").val().replace(/,/gi, '');
					var taxAmount = 0;
					var amount = 0;
					
					if($(obj).val() == "") {
						taxField.val(0);
						me.combiCostApp_setListVal(ProofCode, KeyNo, Field+"Amt", 0);
					} else {
						var tax = JSON.parse($(obj).find("option:selected").attr("tag")).ReservedFloat;
						taxAmount = totalAmount * tax / 100;
						taxAmount = taxAmount - taxAmount % 10;
						taxField.val(toAmtFormat(taxAmount));
						me.combiCostApp_setListVal(ProofCode, KeyNo, Field+"Amt", taxAmount);
					}
					
					// 청구금액 & 공급가액 에 합계금액 - (소득세 + 지방세) 값 바인딩
					var incomTaxAmount = Number(accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=IncomTaxAmt]").val().replace(/,/gi, ''));
					var localTaxAmount = Number(accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=LocalTaxAmt]").val().replace(/,/gi, ''));
					amount = totalAmount - (incomTaxAmount + localTaxAmount);

					// 외주용역 비용정산의 원천세의 경우만 고용보험/산재보험 추가
					if(requestType == "OUTSOURCING" && accountCtrl.getInfoStr("[name=etcEvidRadio][keyno="+KeyNo+"]:checked").val() == "Y"){
						var empInsurance = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=EmpInsurance]");
						var empInsuranceVal = (empInsurance.length) ? Number(empInsurance.val().replace(/,/gi, '')) : 0;
						var accidInsurance = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=AccidInsurance]");
						var accidInsuranceVal = (accidInsurance.length) ? Number(accidInsurance.val().replace(/,/gi, '')) : 0;
						amount = amount - (empInsuranceVal + accidInsuranceVal);
					}
					if(!me.isModified) {
						//첫번째 세부증빙 청구금액 값 바인딩 (input & div json object)
						var divList = getItem.divList;
						if(divList != null){
							var divItem = divList[0];
							me.combiCostApp_setDivVal(ProofCode, KeyNo, divItem.Rownum, "Amount", amount);
							var amtField = accountCtrl.getInfoStr("[name=DivAmountField][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+divItem.Rownum+"][datafield=Amount]");
							amtField.val(toAmtFormat(amount));
						}
	
						//공급가액 값 바인딩 (input & list json object)
						me.combiCostApp_setListVal(ProofCode, KeyNo, "RepAmount", totalAmount);
						var repField = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=RepAmount]");
						repField.val(toAmtFormat(totalAmount));
					}
					
					if(Field == "IncomTax") {
						me.combiCostApp_setListVal(ProofCode, KeyNo, "IncomeTax", val);
					}
					
					// 소득세 변경 시 지방세 자동 변경
					/* if(Field=="IncomTax") {
						accountCtrl.getInfo("combiCostApp" + ProofCode + "_localTax_" + KeyNo).val($(obj).val()).trigger('change');
					} */
				}
				
				if(Field=="AccountInfo") {
					if(val == "DirectInput") {
						accountCtrl.getInfoStr("[name=BankInputArea][proofcode="+ProofCode+"][keyno="+KeyNo+"]").show();
						accountCtrl.getInfoStr("[name=ComboSelect][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=AccountInfo]").parents("td").removeAttr("colspan");
						accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=AccountHolder]").removeAttr("disabled");
					
						me.combiCostApp_setListVal(ProofCode, KeyNo, Field, "");
					} else {
						accountCtrl.getInfoStr("[name=BankInputArea][proofcode="+ProofCode+"][keyno="+KeyNo+"]").hide();
						accountCtrl.getInfoStr("[name=ComboSelect][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=AccountInfo]").parents("td").attr("colspan", "3");
						accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=AccountHolder]").attr("disabled", "disabled");

						var accHolder = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=AccountHolder]");
						var accBank = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=AccountBank]");
						var accBankName = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=AccountBankName]");
						
						var accHolderStr = "";
						var accBankStr = "";
						var accBankNameStr = "";
						
						if($(obj).find("option:selected").attr("data") != undefined) {
							var bankInfo = JSON.parse($(obj).find("option:selected").attr("data"));
							
							if(ProofCode == "CorpCard") {
								accHolderStr = bankInfo.BankAccountName;
								accBankStr = bankInfo.BankCode;
								accBankNameStr = bankInfo.BankName;
							} else {
								var index = $(obj).find("option:selected").attr("index");
								
								accHolderStr = bankInfo.BankAccountName.split(",")[index];
								accBankStr = bankInfo.BankCode.split(",")[index];
								accBankNameStr = bankInfo.BankName.split(",")[index];
							}
						}
						
						accHolder.val(accHolderStr);
						accBank.val(accBankStr);
						accBankName.val(accBankNameStr);
						
						me.combiCostApp_setListVal(ProofCode, KeyNo, "AccountHolder", accHolderStr);
						me.combiCostApp_setListVal(ProofCode, KeyNo, "AccountBank", accBankStr);
						me.combiCostApp_setListVal(ProofCode, KeyNo, "AccountBankName", accBankNameStr);
					}
				}
				
				if(Field=="BizTripItem") {
					var objTem = accountCtrl.getInfoStr("[name=DivAmountField][keyno="+KeyNo+"][proofcode="+ProofCode+"][rownum='"+Rownum+"']");
					var tempObj = $.extend(true, {}, getItem); 
					
					accountCtrl._modifyItemJson(me, 'D02', KeyNo, Rownum, ProofCode, me.combiCostApp_findListItem(getItem.divList, "Rownum", Rownum), "DEL");//유류비
					accountCtrl._modifyItemJson(me, 'D03', KeyNo, Rownum, ProofCode, me.combiCostApp_findListItem(getItem.divList, "Rownum", Rownum), "DEL");//일비
					
					if(val == "Daily") {
						$(objTem).attr("disabled", "disabled"); //일비는 청구금액 수동입력 불가능
						getItem = tempObj;
						accountCtrl._modifyItemJson(me, 'D03', KeyNo, Rownum, ProofCode, me.combiCostApp_findListItem(tempObj.divList, "Rownum", Rownum), "ADD");
					} else {
						$(objTem).removeAttr("disabled");
						
						if(val == "Fuel") {
							getItem = tempObj;
							accountCtrl._modifyItemJson(me, 'D02', KeyNo, Rownum, ProofCode, me.combiCostApp_findListItem(tempObj.divList, "Rownum", Rownum), "ADD");
						}
					}
				}
				
				if(Field=="Currency") {
					var localAmountField = accountCtrl.getInfoStr("[name=LocalAmountField][proofcode="+ProofCode+"][keyno="+KeyNo+"]");
					var exchangeRateField = accountCtrl.getInfoStr("[name=ExchangeRateField][proofcode="+ProofCode+"][keyno="+KeyNo+"]");
					
					if(val == "KRW") {
						accountCtrl.getInfoStr("span[name=ExRateArea][proofcode="+ProofCode+"][keyno="+KeyNo+"]").hide();
						
						// 환율 초기화
						exchangeRateField.val(0).trigger("onblur");
						// 현지금액 초기화
						localAmountField.val(0).trigger("onblur");
					} else {
						var proofDateField = accountCtrl.getInfoStr("[name=DateArea][proofcode="+ProofCode+"][keyno="+KeyNo+"]");
						var proofDate = proofDateField.find("input[type=text]").val();
						
						// 증빙날짜 비어있을 때 오늘날짜
						if(proofDate == "") {
							var today = new Date().format('yyyy.MM.dd');
							var todayHidden = new Date(today).format("MM/dd/yyyy");
							
							proofDateField.find("input[type=text]").val(today);
							proofDateField.find("input[type=hidden]").val(todayHidden);
							proofDateField.trigger("onchange");
							
							proofDate = today;
						}
						
						// 환율, 현지금액 영역 show
						accountCtrl.getInfoStr("span[name=ExRateArea][proofcode="+ProofCode+"][keyno="+KeyNo+"]").show();
						
						// 환율 적용
						var exchangeRate = accComm.getExchangeRate(proofDate, val);
						exchangeRateField.val(exchangeRate ? exchangeRate : 0).trigger("onkeyup");
						
						// 현지금액 비어있을 때 0원
						if(localAmountField.val() == "") {
							localAmountField.val(0).trigger("onkeyup");
						}
					}
				}
				
				if(me.isModified) {
					// 수정 버튼 클릭 후 입력 값 바인딩 중 trigger를 통해 select box를 시스템에서 onchange할 때 
					// 기존 사용자가 입력했던 금액값들이 날라가는 현상 때문에 isModified일 경우 금액 자동 수정을 막아놓음
					// 하지만 그 후 사용자가 직접 select box 값을 바꿀 경우 정상 작동이 필요하므로 isModified를 false로 변경 
					me.isModified = false;
				}
			},
			
			//날자변경시의 처리
			//날자 컴포넌트의 변경이로 현재는 미사용
			//외주용역 당월 전체일수 입력에 이용
			combiCostApp_changeDate : function(obj, ProofCode, KeyNo, Field){
				var me = this;
				
				var pageList = me.combiCostApp_getPageList(ProofCode);
				var getId = obj.id
				var Strval = coviCtrl.getSimpleCalendar(getId);
				var val = Strval.replaceAll(".","");
				me.combiCostApp_setListVal(ProofCode, KeyNo, Field, val);
				me.combiCostApp_setListVal(ProofCode, KeyNo, Field+"Str", Strval);
				
				if(me.exchangeIsUse == "Y") {
					accountCtrl.getInfoStr("[name=CurrencySelectField][proofcode="+ProofCode+"][keyno="+KeyNo+"]").trigger("onchange");
				}
				
				// 외주용역 당월 전체일수 입력
				if(ProofCode == "EtcEvid" && requestType == "OUTSOURCING" && accountCtrl.getInfoStr("[name=etcEvidRadio][keyno="+KeyNo+"]:checked").val() == "Y"){
					var workingDay = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=WorkingDay]");
					var arrVal = Strval.split(".");
					if(Field == "ProofDate" && workingDay.length && arrVal.length > 2){
						var wDay = new Date(arrVal[0],arrVal[1],0).getDate();
						workingDay.val(toAmtFormat(wDay));
						//me.combiCostApp_setListVal(ProofCode, KeyNo, "WorkingDay", wDay);
						me.combiCostApp_InputValChange(workingDay[0], ProofCode, KeyNo, "WorkingDay");
					}
				}
			},
			
			//입력폼에 값이 변경되었을 시 세팅과 처리
			combiCostApp_InputValChange : function(obj, ProofCode, KeyNo, Field) {
				var me = this;
				
				var val = obj.value;
				var pageList = me.combiCostApp_getPageList(ProofCode);
				var getItem = me.combiCostApp_findListItem(pageList, "KeyNo", KeyNo);

				var getId = obj.id
				var getTag = obj.getAttribute("tag");
				var field = obj.getAttribute("datafield");
				if(getTag == "Amount"){
					val = val.replace(/[^0-9\-,.]/g, "");					
					var numVal = ckNaN(AmttoNumFormat(val));
					if(numVal>99999999999){
						numVal = 99999999999;
					}
					val = numVal;
					obj.value = toAmtFormat(numVal);
					
					if(ProofCode == "CorpCard") {
						var repAmountField = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=RepAmount]");
						var totalAmountVal = $(obj).parents("li").find(".tx_ta").text().replace(/,/gi, "");
						var repAmountVal = totalAmountVal - numVal;
						repAmountField.val(toAmtFormat(repAmountVal));
						me.combiCostApp_setListVal(ProofCode, KeyNo, "RepAmount", repAmountVal);
					}
					
					if(ProofCode == "EtcEvid") {
						//var totalAmount = val;
						var totalAmount = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=TotalAmount]").val().replace(/,/gi, "")*1;
						numVal = totalAmount;
						// 외주용역 비용정산의 원천세의 경우만 고용보험/산재보험 추가
						if(requestType == "OUTSOURCING" && accountCtrl.getInfoStr("[name=etcEvidRadio][keyno="+KeyNo+"]:checked").val() == "Y"){
							if(Field == "EmpInsurance" || Field == "AccidInsurance"){
								var empInsurance = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=EmpInsurance]");
								var empInsuranceVal = (empInsurance.length) ? Number(empInsurance.val().replace(/,/gi, '')) : 0;
								var accidInsurance = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=AccidInsurance]");
								var accidInsuranceVal = (accidInsurance.length) ? Number(accidInsurance.val().replace(/,/gi, '')) : 0;
								numVal = numVal - (empInsuranceVal + accidInsuranceVal);
							}else{
								// 221017 고용보험 : ((합계금액-(합계금액*15.7%))*1.6%)/2 , 합계금액이 1330000 보다 작으면 1330000 으로 계산
								// 221104 고용보험 : ((합계금액*1.6%)/2), 합계금액이 1330000 보다 작으면 1330000 으로 계산
								var empInsurance = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=EmpInsurance]");
								if(empInsurance.length){
									var empInsuranceVal = 0;
									var empBaseAmt = Common.getBaseConfig("EmpInsurBaseAmt")*1; // 외주용역 고용보험 계산 기준금액(1330000)
									var empRate = Common.getBaseConfig("EmpInsurRate")*1; // 외주용역 고용보험 계산 비율(1.6%/2 = 0.008)
									if(!empRate) empRate = 1;
									// 합계금액이 +/-일때 별도처리 , 합계금액이 0이면 0으로처리
									if(totalAmount > 0){
										if(empBaseAmt && totalAmount < empBaseAmt) empInsuranceVal = empBaseAmt*empRate;
										else empInsuranceVal = totalAmount*empRate; 
									} else if(totalAmount < 0){
										empBaseAmt = -empBaseAmt;
										if(empBaseAmt && totalAmount > empBaseAmt) empInsuranceVal = empBaseAmt*empRate;
										else empInsuranceVal = totalAmount*empRate; 
									}
									empInsuranceVal = empInsuranceVal - empInsuranceVal % 10;
									empInsurance.val(toAmtFormat(empInsuranceVal));
									me.combiCostApp_setListVal(ProofCode, KeyNo, "EmpInsurance", empInsuranceVal);
									numVal = numVal - empInsuranceVal;
								}
								// 220715 산재보험 : 합계금액이 3,937,500원 보다 작으면 합계금액*5.8/1000/2, 크면 3,937,500*5.8/1000/2
								// 221104 산재보험 : (3,937,500/당 월 전체 일 수*(실제 근무일 수)*0.58%)/2
								// 230802 산재보험 : (합계금액/당 월 전체 일수*(실제 근무일 수)*0.58%)/2
								//                >> 230802 처리 : 추후 변경을 위해 기준금액 설정(AccidInsurBaseAmt)을 0으로 바꾸고 기준금액 0이면 합계금액을 이용하도록 변경
								var accidInsurance = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=AccidInsurance]");
								var workingDay = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=WorkingDay]");
								var actualDay = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=ActualDay]");
								if(accidInsurance.length && workingDay.length && actualDay.length){
									if(Field == "WorkingDay" || Field == "ActualDay"){ // 일수 값 제어(마이너스,31일 초과)
										var tmpObj = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field="+Field+"]");
										var tmpVal = (tmpObj.length) ? Number(tmpObj.val().replace(/,/gi, '')) : 0;
										if(tmpVal < 0) tmpVal = tmpVal*-1;
										if(tmpVal > 31) tmpVal = 31;
										tmpObj.val(toAmtFormat(tmpVal));
										me.combiCostApp_setListVal(ProofCode, KeyNo, Field, tmpVal);
									}
									var workingDayVal = Number(workingDay.val().replace(/,/gi, ''));
									var actualDayVal = Number(actualDay.val().replace(/,/gi, ''));
									var accidInsuranceVal = 0;
									if(workingDayVal && actualDayVal){ // 일수가 없으면 0으로 처리
										var accidBaseAmt = Common.getBaseConfig("AccidInsurBaseAmt")*1; // 외주용역 산재보험 계산 기준금액(3937500)
										var accidRate = Common.getBaseConfig("AccidInsurRate")*1; // 외주용역 산재보험 계산 비율(0.58%/2 = 0.0029)
										if(!accidRate) accidRate = 1;
										if(!accidBaseAmt) accidBaseAmt = totalAmount; // 기준금액이 0이면 합계금액 이용
										accidInsuranceVal = accidBaseAmt/workingDayVal*actualDayVal*accidRate;
									}
									accidInsuranceVal = accidInsuranceVal - accidInsuranceVal % 10;
									accidInsurance.val(toAmtFormat(accidInsuranceVal));
									me.combiCostApp_setListVal(ProofCode, KeyNo, "AccidInsurance", accidInsuranceVal);
									numVal = numVal - accidInsuranceVal;
								}
							}
						}
						if(accountCtrl.getInfoStr("select[id*=incomTax]").find("option:selected").val() != "") {
							var incomTaxAmountField = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=IncomTaxAmt]");
							var incomTax = JSON.parse(accountCtrl.getInfoStr("select[id*=incomTax]").find("option:selected").attr("tag")).ReservedFloat;
							var incomTaxAmount = totalAmount * incomTax / 100;
							incomTaxAmount = incomTaxAmount - incomTaxAmount % 10;
							incomTaxAmountField.val(toAmtFormat(incomTaxAmount));
							me.combiCostApp_setListVal(ProofCode, KeyNo, "IncomTaxAmt", incomTaxAmount);
							numVal = numVal - incomTaxAmount;
						}
						if(accountCtrl.getInfoStr("select[id*=localTax]").find("option:selected").val() != "") {
							var localTaxAmountField = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=LocalTaxAmt]");
							var localTax = JSON.parse(accountCtrl.getInfoStr("select[id*=localTax]").find("option:selected").attr("tag")).ReservedFloat;
							var localTaxAmount = totalAmount * localTax / 100;
							localTaxAmount = localTaxAmount - localTaxAmount % 10;
							localTaxAmountField.val(toAmtFormat(localTaxAmount));
							me.combiCostApp_setListVal(ProofCode, KeyNo, "LocalTaxAmt", localTaxAmount);
							numVal = numVal - localTaxAmount;
						}
						if(Field == "TotalAmount") {
							var repAmountField = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=RepAmount]")
							repAmountField.val(toAmtFormat(totalAmount));
							me.combiCostApp_setListVal(ProofCode, KeyNo, "RepAmount", totalAmount);
						}
						/*
						if(Field == "TaxAmount") {
							var repAmountField = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=RepAmount]");
							var totalAmount = AmttoNumFormat(accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=TotalAmount]").val());
							repAmountField.val(toAmtFormat(totalAmount - numVal));
							me.combiCostApp_setListVal(ProofCode, KeyNo, "RepAmount", totalAmount - numVal);
							
							var divList = getItem.divList;
							for(var i = 0; i < divList.length; i++){
								if( i == 0){
									me.combiCostApp_setDivVal(ProofCode, KeyNo, divList[i].Rownum, "Amount", totalAmount - numVal);
								} else {
									me.combiCostApp_setDivVal(ProofCode, KeyNo, divList[i].Rownum, "Amount", 0);
								}
							}
							
							accountCtrl.getInfoStr("[name=DivAmountField][proofcode="+ProofCode+"]").val(0);
							accountCtrl.getInfoStr("[name=DivAmountField][proofcode="+ProofCode+"][keyno="+KeyNo+"]").val(toAmtFormat(totalAmount - numVal));
						}
						var taxCode = accountCtrl.getInfoStr("[name=ComboSelect][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=TaxCode]").val();
						if(Field == "TotalAmount") {
							var totalAmount = numVal;
							var repAmountField = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=RepAmount]");
							var taxAmountField = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=TaxAmount]");
							var taxRate = 1.1;
							if(!taxCode.indexOf("V", 0) === "0" || taxCode == "V0" || taxCode == "V1" || taxCode == "V2") { //V0~2: 표준세율 0 / X1,Y1: 불공제 항목
								taxRate = 1;
							}
							if(taxCode == ""){
								taxRate = 1;
							}
							var repAmount = totalAmount / taxRate;
							repAmountField.val(toAmtFormat(Math.round(repAmount)));
							taxAmountField.val(toAmtFormat(Math.round(totalAmount - repAmount)));	
							
							me.combiCostApp_setListVal(ProofCode, KeyNo, "RepAmount", Math.round(repAmount));
							me.combiCostApp_setListVal(ProofCode, KeyNo, "TaxAmount", Math.round(totalAmount - repAmount));		
						} 
						val = numVal;
						*/ 
						if((Field == "ExchangeRate" || Field == "LocalAmount") && me.exchangeIsUse == "Y"){
							var calName = (Field == "ExchangeRate" ? "LocalAmountField" : "ExchangeRateField");
							var calVal =  Number(AmttoNumFormat(accountCtrl.getInfoStr("[name="+calName+"][proofcode="+ProofCode+"][keyno="+KeyNo+"]").val()));
							var curType = accountCtrl.getInfoStr("[name=CurrencySelectField][proofcode="+ProofCode+"][keyno="+KeyNo+"]").val();
							var totalAmount = 0;
							
							//입력값 소수점 두자리  처리
							if (val % 1 > 0) { val = val.toFixed(2); }
							
							accountCtrl.getInfoStr("[name="+Field+"][proofcode="+ProofCode+"][keyno="+KeyNo+"]").val(toAmtFormat(val));
							me.combiCostApp_setListVal(ProofCode, KeyNo, Field, val);
							
							totalAmount = Number(val*calVal);
							//엔화 예외처리
							if (curType == "JPY") { totalAmount = totalAmount / 100; }
							//증빙합계 소수점 두자리  처리
							if (totalAmount % 1 > 0) { totalAmount = totalAmount.toFixed(2); }
							
							accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=TotalAmount]").val(toAmtFormat(totalAmount));
							accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=TotalAmount]").trigger("onblur");
						}
					}
					
					if(ProofCode == "PaperBill") {
						if(Field == "TaxAmount" || Field == "TotalAmount") {
							var totalAmount = AmttoNumFormat(accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=TotalAmount]").val());
							var taxAmount = AmttoNumFormat(accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=TaxAmount]").val());
							var setVal = (Field == "TaxAmount" ? (totalAmount - numVal) : (numVal - taxAmount));
							
							var repAmountField = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=RepAmount]");
							repAmountField.val(toAmtFormat(setVal));
							me.combiCostApp_setListVal(ProofCode, KeyNo, "RepAmount", setVal);
							
							var divList = getItem.divList;
							if(divList != null){
								if(divList.length==1){
									var divItem = divList[0];
									me.combiCostApp_setDivVal(ProofCode, KeyNo, divItem.Rownum, "Amount", setVal);
									
									var amtField = accountCtrl.getInfoStr("[name=DivAmountField][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+divItem.Rownum+"][datafield=Amount]")
									amtField.val(toAmtFormat(setVal));
								}
							}
						}
					}
					
					if((ProofCode=="EtcEvid" || ProofCode=="PrivateCard"  || ProofCode=="Receipt") && (Field == "TotalAmount" || Field == "EmpInsurance" || Field == "AccidInsurance" || Field == "WorkingDay" || Field == "ActualDay")){						
						var divList = getItem.divList;
						if(divList != null){
							if(divList.length==1){
								var divItem = divList[0];
								var amtField = accountCtrl.getInfoStr("[name=DivAmountField][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+divItem.Rownum+"][datafield=Amount]")
								if(amtField.attr('disabled') != 'disabled') {
									amtField.val(toAmtFormat(numVal));
									me.combiCostApp_setDivVal(ProofCode, KeyNo, divItem.Rownum, "Amount", numVal);
								}
							}
						}
					}
					
				}
				me.combiCostApp_setListVal(ProofCode, KeyNo, Field, val);
				
			},

			//증빙 list에 값을 세팅
			combiCostApp_setListVal : function(ProofCode, KeyNo, Field, val) {
				var me = this;
				var pageList = me.combiCostApp_getPageList(ProofCode);
				var getItem = me.combiCostApp_findListItem(pageList, "KeyNo", KeyNo);
				getItem[Field] = val;
			},
			
			//세부증빙 list에 값 세팅
			combiCostApp_setDivVal : function(ProofCode, KeyNo, Rownum, Field, val) {
				var me = this;
				var pageList = me.combiCostApp_getPageList(ProofCode);
				var getItem = me.combiCostApp_findListItem(pageList, "KeyNo", KeyNo);
				if(!isEmptyStr(getItem.KeyNo)){
					var divItem = me.combiCostApp_findListItem(getItem.divList, "Rownum", Rownum);
					divItem[Field] = val;
				}
			},
			combiCostApp_findListItem : function(inputList, field, val) {
				var retVal = null;
				var arrCk = Array.isArray(inputList);
				if(arrCk){
					retVal = accFind(inputList, field, val);
				}
				return retVal
			},
			
			//증빙의 최대 키값을 세팅
			//아직 저장되지 않은 증빙들은 고유값이 없을때도 있기에 키값을 자체적으로 발번
			combiCostApp_getPageListMaxKey : function(ProofCode, KeyField) {
				var me = this;
				if(KeyField==null){
					KeyField="KeyNo"
				}
				
				var retVal = 0;
				var pageList = me.combiCostApp_getPageList(ProofCode);
				if(pageList==null){
					return;
				}
				for(var i = 0; i<pageList.length; i++){
					var getItem = pageList[i];
					var getno = ckNaN(getItem[KeyField]);
					if(retVal<getno){
						retVal = getno;
					}
				}
				return retVal
			},
			
			//증빙과 세금유형에 따라 세금 코드를 동적으로 생성
			combiCostApp_makeTCData : function(ProofCode, cdList, deduct) {
				var me = this;
				var htmlStr = "<option value=''>"+ "<spring:message code='Cache.ACC_lbl_choice' />" +"</option>";
				if(deduct != "deduct" && deduct != "induct"){
					htmlStr = "<option value=''>"+ "<spring:message code='Cache.ACC_040' />" +"</option>";
					return htmlStr;
				}
				var deductYN = (deduct=="deduct")?"Y":"N"
				for(var i = 0; i<cdList.length; i++){
					var getCd = cdList[i];
					if(getCd.ProofCode == ProofCode
							&& getCd.DeductionType == deductYN){
						htmlStr = htmlStr + "<option value='"+ getCd.Code +"'>"+ getCd.CodeName +"</option>"
					}
				}
				return htmlStr;
			},
			//증빙과 세금유형에 따라 세금 유형
			combiCostApp_makeTTData : function(ProofCode, taxcode) {
				var me = this;
				var result = me.combiCostApp_findListItem(me.pageCombiAppComboData.TaxCodeList, "Code", taxcode);
				var value = '';
				if(result.DeductionType!=undefined)
					value = result.DeductionType=="N"?'induct':'deduct';
				return value;	
			},
			
			combiCostApp_SlipCopyPopup : function(ProofCode) {
				var me = this;
				var info = {
						popupUrl		: "/account/accountCommon/accountCommonPopup.do",
						popupID 		: "copySearchPopup",
						popupTit 		: "<spring:message code='Cache.ACC_btn_copy'/>",
						popupName 		: "copySearchPopup",
						callBackFunc 	: "combiCostApp_callBackSlipCopyPopup",
						companyCode 	: me.CompanyCode,
						vendorNo		: $("[field=VendorNo]").val(),
						proofCode		: ProofCode,
						usid			: Common.getSession("UR_Code")
				}
				var url = me.makeObjPopupUrl(info);
				Common.open(	"",info.popupID,info.popupTit,url,"1000px","630px","iframe",true,null,null,true);
			},
			
			combiCostApp_callBackSlipCopyPopup : function(listID) {
				var me = this;

				$.ajax({
					type:"POST",
					url:"/account/expenceApplication/getApplicationListCopy.do",
					data:{
						ListID : listID.ExpenceApplicationListID
					},
					success:function (data) {
						if(data.result == "ok"){
							if(data.list && data.list.length > 0) {
								var getCopyList = data.list;
								
								getCopyList["divList"] = getCopyList;
								getCopyList["ProofCode"] = getCopyList[0].ProofCode;
								getCopyList["KeyNo"] = "1";
								
					
								me.combiCostApp_makeInputDivHtmlAddCopy(getCopyList, true);
							}
						}
						else{
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
					}
				});
				
				
			},
			// 프로젝트에서는 사업자번호 대신 VendorCode 로 맵핑바랍니다.
			combiCostApp_selRecentVendorInfo : function(BusinessNumber, proofCode) {
				var me = this;
				
				var rslt;

				$.ajax({
					type:"POST",
					url:"/account/expenceApplication/selRecentVendorInfo.do",
					data:{
						"BusinessNumber" : BusinessNumber,
						"proofCode" : proofCode,
						"UR_Code" : Common.getSession("UR_Code")
					},
					success:function (data) {
						if(data.result == "ok"){
							if(data.list && data.list.length > 0) {
								var getCopyList = data.list;
								
								getCopyList["divList"] = getCopyList;
								getCopyList["ProofCode"] = getCopyList[0].ProofCode;
								getCopyList["KeyNo"] = "1";
								
								rslt = getCopyList;
							}
						}
						else{
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
					}
				}, false);
				return rslt;
				
			},
			
			//업체 선택 팝업 호출
			combiCostApp_callVendorPopup : function(ProofCode, KeyNo, BusinessNumber, isAlterPayee, isProvider) {
				var me = this;
				me.tempObj.ProofCode = ProofCode;
				me.tempObj.KeyNo = KeyNo;
				me.tempObj.isAlterPayee = isAlterPayee;
				me.tempObj.isProvider = isProvider;
				
				var isPE = "N";
				if(ProofCode=="EtcEvid"){
					isPE = accountCtrl.getInfoStr("[name=etcEvidRadio][keyno="+KeyNo+"]:checked").val();
				}
				
				var info = {
						popupUrl		: "/account/accountCommon/accountCommonPopup.do",
						popupID 		: "vendorSearchPopup",
						popupTit 		: "<spring:message code='Cache.ACC_lbl_vendor'/>",
						popupName 		: "VendorSearchPopup",
						callBackFunc 	: "combiCostApp_getVendorInfo",
						companyCode 	: me.CompanyCode,
						isPE			: isPE
				}
				if(BusinessNumber != undefined) info.businessNumber = BusinessNumber;
				var url = me.makeObjPopupUrl(info);
				Common.open(	"",info.popupID,info.popupTit,url,"700px","630px","iframe",true,null,null,true);
			},

			//업체의 추가정보 조회
			combiCostApp_getVendorInfo : function(obj) {
				var me = this;
				var ProofCode = me.tempObj.ProofCode;
				var KeyNo = me.tempObj.KeyNo;
				var isAlterPayee = me.tempObj.isAlterPayee;
				var isProvider = me.tempObj.isProvider;
				
				// 업체 자동 바인딩 시 호출하면 tempObj가 없으므로, 호출 시 KeyNo와 ProofCode 같이 넘겨줌.
				if(ProofCode == undefined) {
					ProofCode = obj.ProofCode;
				}
				if(KeyNo == undefined) {
					KeyNo = obj.KeyNo;
				}
				
				// 업체의 은행계좌 정보 초기화
				me.combiCostApp_initAccountInfo(ProofCode, KeyNo);
				
				// 업체 정보 조회
				$.ajax({
					url:"/account/baseInfo/searchVendorDetail.do",
					cache: false,
					data:{
						VendorID : obj.VendorID
					},
					success:function (data) {
						if(data.result == "ok"){
							var vdInfo = data.data;
							
							if(isAlterPayee) {
								me.combiCostApp_setListVal(ProofCode, KeyNo, "AlterPayeeNo", vdInfo.BusinessNumber);
								me.combiCostApp_setListVal(ProofCode, KeyNo, "AlterPayeeName", vdInfo.VendorName);
	
								var nmField = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=AlterPayeeName]");
								var cdField = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=AlterPayeeNo]");
								
								nmField.val(vdInfo.VendorName);
								cdField.val(vdInfo.BusinessNumber);
							} else {
								if(isProvider) {
									me.combiCostApp_setListVal(ProofCode, KeyNo, "ProviderNo", vdInfo.BusinessNumber);
									me.combiCostApp_setListVal(ProofCode, KeyNo, "ProviderName", vdInfo.VendorName);
		
									var nmField = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=ProviderName]");
									var cdField = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=ProviderNo]");
									
									nmField.val(vdInfo.VendorName);
									cdField.val(vdInfo.BusinessNumber);		
								}
								me.combiCostApp_setListVal(ProofCode, KeyNo, "VendorID", vdInfo.VendorID);
								me.combiCostApp_setListVal(ProofCode, KeyNo, "VendorNo", vdInfo.VendorNo);
								me.combiCostApp_setListVal(ProofCode, KeyNo, "VendorName", vdInfo.VendorName);
								me.combiCostApp_setListVal(ProofCode, KeyNo, "BusinessNumber", vdInfo.BusinessNumber);
	
								var nmField = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=VendorName]");
								var vnField = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=VendorNo]");
								
								nmField.val(vdInfo.VendorName);
								vnField.val(vdInfo.BusinessNumber);
								
								// 은행계좌 정보 세팅
								me.combiCostApp_setAccountInfo(vdInfo, ProofCode, KeyNo, obj.AccountInfo, obj.AccountHolder, obj.AccountBank, obj.AccountBankName);
								
								if(ProofCode == "EtcEvid" || ProofCode == "CashBill" || ProofCode == "TaxBill" || ProofCode == "PaperBill"){								
									// 지급조건, 지급방법
									var payMethod = accountCtrl.getInfoStr("[name=ComboSelect][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=PayMethod]");
									var payType = accountCtrl.getInfoStr("[name=ComboSelect][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=PayType]");

									var payMethodStr = (obj.PayMethod ? obj.PayMethod : nullToBlank(vdInfo.PaymentMethod));
									var payTypeStr = (obj.PayTyped ? obj.PayType : nullToBlank(vdInfo.PaymentCondition));
									
									payMethod.val(payMethodStr);
									payType.val(payTypeStr);
									
									me.combiCostApp_setListVal(ProofCode, KeyNo, "PayMethod", payMethodStr);
									me.combiCostApp_setListVal(ProofCode, KeyNo, "PayType", payTypeStr);
								}
							}
							
							me.tempObj = {};
							
		                    if (Common.getBaseConfig("RecentVendorUseYN") == "Y") {
								var tempItem = me.combiCostApp_selRecentVendorInfo(vdInfo.BusinessNumber, ProofCode);
		                    	if(tempItem != undefined){
			                        me.combiCostApp_makeInputDivHtmlAddCopy(tempItem, true);
		                    	}
		                    } 
						} else{
							Common.Error(data);
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의바랍니다.
					}
				});
			},
			
			//업체의 은행계좌 정보  초기화
			combiCostApp_initAccountInfo : function(pProofCode, pKeyNo) {
				var me = this;
				var accInfo = accountCtrl.getInfoStr("[name=ComboSelect][proofcode="+pProofCode+"][keyno="+pKeyNo+"][field=AccountInfo]");
				var accHolder = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+pProofCode+"][keyno="+pKeyNo+"][field=AccountHolder]");
				var accBank = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+pProofCode+"][keyno="+pKeyNo+"][field=AccountBank]");
				var accBankName = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+pProofCode+"][keyno="+pKeyNo+"][field=AccountBankName]");
				
				// 기존에 조회한 은행계좌 삭제
				if(pProofCode == "EtcEvid" || pProofCode == "CashBill" || pProofCode == "TaxBill" || pProofCode == "PaperBill"){
					accInfo.find("option[value!=''][value!='DirectInput']").remove();

				accInfo.find("option:first").prop("selected", true);
				accHolder.val("");
				accBank.val("");
				accBankName.val("");
				
				me.combiCostApp_setListVal(pProofCode, pKeyNo, "AccountInfo", "");
				me.combiCostApp_setListVal(pProofCode, pKeyNo, "AccountHolder", "");
				me.combiCostApp_setListVal(pProofCode, pKeyNo, "AccountBank", "");
				me.combiCostApp_setListVal(pProofCode, pKeyNo, "AccountBankName", "");
				
				accInfo.trigger("change");
				}
			},

			//업체의 은행계좌 정보 세팅
			combiCostApp_setAccountInfo : function(pVendorInfo, pProofCode, pKeyNo, pAccountInfo, pAccountHolder, pAccountBank, pAccountBankName) {
				var me = this;
				
				if(pVendorInfo.BankAccountNo != undefined && pVendorInfo.BankAccountNo != "") {
					var accInfo = accountCtrl.getInfoStr("[name=ComboSelect][proofcode="+pProofCode+"][keyno="+pKeyNo+"][field=AccountInfo]");
					var accHolder = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+pProofCode+"][keyno="+pKeyNo+"][field=AccountHolder]");
					var accBank = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+pProofCode+"][keyno="+pKeyNo+"][field=AccountBank]");
					var accBankName = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+pProofCode+"][keyno="+pKeyNo+"][field=AccountBankName]");
					
					var accInfoStr = "";
					var accHolderStr = "";
					var accBankStr = "";
					var accBankNameStr = "";
					
					var sHtml = "";
					
					for(var i = 0; i < pVendorInfo.BankAccountNo.split(",").length; i++) {
						sHtml += "<option value='" + pVendorInfo.BankAccountNo.split(",")[i] + "' index='" + i + "' data='" + JSON.stringify(pVendorInfo) + "'>" 
							+ pVendorInfo.BankName.split(",")[i] + " " +pVendorInfo.BankAccountNo.split(",")[i] + "</option>";
					}
					
					accInfo.append(sHtml);
					
					accInfoStr = (pAccountInfo ? pAccountInfo : pVendorInfo.BankAccountNo.split(",")[0]);
					accHolderStr = (pAccountHolder ? pAccountHolder : pVendorInfo.BankAccountName.split(",")[0]);
					accBankStr = (pAccountBank ? pAccountBank : pVendorInfo.BankCode.split(",")[0]);
					accBankNameStr = (pAccountBankName ? pAccountBankName : pVendorInfo.BankName.split(",")[0]);
					
					accInfo.val(accInfoStr);
					accHolder.val(accHolderStr);
					accBank.val(accBankStr);
					accBankName.val(accBankNameStr);
					
					me.combiCostApp_setListVal(pProofCode, pKeyNo, "AccountInfo", accInfoStr);
					me.combiCostApp_setListVal(pProofCode, pKeyNo, "AccountHolder", accHolderStr);
					me.combiCostApp_setListVal(pProofCode, pKeyNo, "AccountBank", accBankStr);
					me.combiCostApp_setListVal(pProofCode, pKeyNo, "AccountBankName", accBankNameStr);
				}
			},
			
			combiCostApp_InputVendorChange : function(obj, ProofCode, KeyNo, Field) {
				var me = this;
				if(obj.value != "") {
				//등록되어 있는 거래처인지 확인(act_vendor)
					$.ajax({
						type:"POST",
						url:"/account/expenceApplication/checkActVendorIsRegistered.do",
						data:{
							FieldName : Field,
							FieldValue : obj.value
						},
						success:function (data) {
							if(data.result == "ok"){
								if(data.list.length > 0) {
									var msg = "";
									 
									$(obj).closest("tr").find("input[field=VendorNo]").val(data.list[0].VendorNo);
									$(obj).closest("tr").find("input[field=VendorName]").val(data.list[0].VendorName);
									 
									if(Field == "VendorNo") { //사업자코드 중복
										msg = "<spring:message code='Cache.ACC_msg_dupVendorNo' />"; //동일한 사업자번호로 등록된 거래처가 있으므로 해당 거래처 정보로 대치됩니다.
									} else { //거래처명 중복
										msg = "<spring:message code='Cache.ACC_msg_dupVendorName' />"; //동일한 거래처명으로 등록된 거래처가 있으므로 해당 거래처 정보로 대치됩니다.
									}
									 
									me.combiCostApp_setListVal(ProofCode, KeyNo, "VendorNo", data.list[0].VendorNo);
									me.combiCostApp_setListVal(ProofCode, KeyNo, "VendorName", data.list[0].VendorName);
									 
									Common.Warning(msg);
								} else {
									me.combiCostApp_setListVal(ProofCode, KeyNo, Field, obj.value);
								}
							}
							else{
								Common.Error(data);
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의바랍니다.
						}
					});
				} else {
					me.combiCostApp_setListVal(ProofCode, KeyNo, Field, obj.value);
				}
			},
			
			combiCostApp_callBankPopup : function(ProofCode, KeyNo) {
				var me = this;
				me.tempObj.ProofCode = ProofCode;
				me.tempObj.KeyNo = KeyNo;
				var info = {
						popupUrl		: "/account/accountCommon/accountCommonPopup.do",
						popupID 		: "bankSearchPopup",
						popupTit 		: "<spring:message code='Cache.ACC_lbl_bankSelect'/>",
						popupName 		: "BankSearchPopup",
						callBackFunc 	: "combiCostApp_setBankInfo",
						companyCode 	: me.CompanyCode
				}
				var url = me.makeObjPopupUrl(info);
				Common.open("",info.popupID,info.popupTit,url,"350px","400px","iframe",true,null,null,true);
			},
			
			combiCostApp_setBankInfo : function(obj) {
				var me = this;
				var ProofCode = me.tempObj.ProofCode;
				var KeyNo = me.tempObj.KeyNo;

				accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=AccountBank]").val(obj.Code);
				accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=AccountBankName]").val(obj.CodeName);

				me.combiCostApp_setListVal(ProofCode, KeyNo, "AccountBank", obj.Code);
				me.combiCostApp_setListVal(ProofCode, KeyNo, "AccountBankName", obj.CodeName);
			},

			//개인카드 선택 팝업 호출
			combiCostApp_callPrivateCardPopup : function(ProofCode, KeyNo) {
				var me = this;
				me.tempObj.ProofCode = ProofCode;
				me.tempObj.KeyNo = KeyNo;
				var info = {
						popupUrl		: "/account/accountCommon/accountCommonPopup.do",
						popupID 		: "privateCardSearchPopup",
						popupTit 		: "<spring:message code='Cache.ACC_lbl_privateCardSelect'/>",
						popupName 		: "PrivateCardSearchPopup",
						callBackFunc 	: "combiCostApp_setPrivateCardInfo",
						includeAccount	: "N",
						companyCode 	: me.CompanyCode
				}
				var url = me.makeObjPopupUrl(info);
				Common.open(	"",info.popupID,info.popupTit,url,"700px","550px","iframe",true,null,null,true);
			},

			//개인카드 값 세팅
			combiCostApp_setPrivateCardInfo : function(obj) {
				var me = this;
				var ProofCode = me.tempObj.ProofCode
				var KeyNo = me.tempObj.KeyNo

				me.combiCostApp_setListVal(ProofCode, KeyNo, "PersonalCardNoView", obj.CardNoView);
				me.combiCostApp_setListVal(ProofCode, KeyNo, "PersonalCardNo", obj.CardNo);

				var nmField = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=PersonalCardNoView]")
				var cdField = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode="+ProofCode+"][keyno="+KeyNo+"][field=PersonalCardNo]")
				nmField.val(obj.CardNoView);
				cdField.val(obj.CardNo);
				
				me.tempObj = {};
			},
			
			//세부증빙 복사
			combiCostApp_divCopy : function(ProofCode, KeyNo) {
				var me = this;

				var targetRow = accountCtrl.getInfoStr("[name=DivCheck][keyno="+KeyNo+"]:checked");
				if(targetRow.length>1){
					Common.Inform("<spring:message code='Cache.msg_SelectOnlyOne' />"); //1개 항목만 선택하세요.
					return;
				}
				
				var pageList = me.combiCostApp_getPageList(ProofCode);
				var item = me.combiCostApp_findListItem(pageList, "KeyNo", KeyNo);
			    var copyRownum = targetRow.length == 0 ? item.divList[0].Rownum : parseInt(targetRow.attr('rownum'));
				var oriTempObj = Object.assign({}, me.tempVal);
				
				if(item.divList == null){
					item.divList = [];
				}
				
				var ctrlList = "";
				var ctrlItem = accountCtrl.getInfoStr("[name=CtrlArea][keyno="+KeyNo+"][rownum="+copyRownum+"] [id][code]");
			    $.each(ctrlItem, function(i, item) {
			    	var itemVal = $(item).attr('code');
			    	if(ctrlList.indexOf(itemVal) == -1) {
			        	if(i > 0) ctrlList += ",";
			    		ctrlList += itemVal;
			    	}
			    });
			    
				var idx = accFindIdx(item.divList, "Rownum", copyRownum);

				var divList = item.divList[idx];
				var divItem = {
						ExpenceApplicationDivID : ""
						, ExpenceApplicationListID : nullToBlank(divList.ExpenceApplicationListID)
						
						, AccountCode : nullToBlank(divList.AccountCode)
						, AccountName : nullToBlank(divList.AccountName)
						, StandardBriefID : nullToBlank(divList.StandardBriefID)
						, StandardBriefName : nullToBlank(divList.StandardBriefName)
						, StandardBriefDesc : nullToBlank(divList.StandardBriefDesc)
						, CostCenterCode : nullToBlank(divList.CostCenterCode)
						, CostCenterName : nullToBlank(divList.CostCenterName)
						, IOCode : nullToBlank(divList.IOCode)
						, IOName : nullToBlank(divList.IOName)
						, Amount : nullToBlank(divList.Amount)
						, UsageComment : nullToBlank(divList.UsageComment)
						, IsNew : nullToBlank(divList.IsNew)
						
						, ExpenceApplicationListID : item.ExpenceApplicationListID
						, ViewKeyNo : String(item.ViewKeyNo)
						, KeyNo : String(item.KeyNo)
						, ProofCode : item.ProofCode
						
			            //관리항목 셋팅
						, TaxType	: nullToBlank(item.TaxType)
						, TaxCode	: nullToBlank(item.TaxCode)
						, CtrlCode	: nullToBlank(ctrlList)
				}
				
				var maxRN = ckNaN(item.maxRowNum);
				maxRN++;
				item.maxRowNum = maxRN;
				divItem.Rownum = maxRN;
				
				if(divList.ReservedStr2_Div != undefined && Object.keys(divList.ReservedStr2_Div).length > 0)
					divItem.ReservedStr2_Div = divList.ReservedStr2_Div;
				if(divList.ReservedStr3_Div != undefined && Object.keys(divList.ReservedStr3_Div).length > 0)
					divItem.ReservedStr3_Div = divList.ReservedStr3_Div;
				
				item.divList.push(divItem);
				me.combiCostApp_updateInputDivHtml(divItem, divItem.ProofCode, divItem.KeyNo, copyRownum);    
				
				me.tempObj = oriTempObj;
			},

			//복사된 세부증빙 html로 수정
			combiCostApp_updateInputDivHtml : function(divItem, ProofCode, KeyNo, copyRownum) {
				var me = this;
				
				var Rownum = divItem.Rownum;
				var divArea = accountCtrl.getInfoStr("[name=DivBodyArea][proofcode="+ProofCode+"][keyno="+KeyNo+"]");
				var formStr = me.pageCombiAppFormList["DivInputFormStr"];
				
				if(nullToBlank(divItem.Amount) == ""){
                    divItem.Amount = ProofCode == "TaxBill" ? divItem.RepAmount : divItem.TotalAmount;
				}
				
				const valMap = {
						RequestType: requestType,
						
						ExpenceApplicationDivID : "",
						ExpenceApplicationListID : nullToBlank(divItem.ExpenceApplicationListID),
						ViewKeyNo : nullToBlank(divItem.ViewKeyNo),
						KeyNo : nullToBlank(divItem.KeyNo),
						ProofCode : nullToBlank(divItem.ProofCode),
						Rownum : nullToBlank(divItem.Rownum),
						
						AmountVal : toAmtFormat(divItem.Amount),
						
						accCDVal : nullToBlank(divItem.AccountCode),
						accNMVal : nullToBlank(divItem.AccountName),
						AccountCode : nullToBlank(divItem.AccountCode),
						AccountName : nullToBlank(divItem.AccountName),
						
						SBCDVal : nullToBlank(divItem.StandardBriefID),
						SBNMVal : nullToBlank(divItem.StandardBriefName),
						StandardBriefID : nullToBlank(divItem.StandardBriefID),
						StandardBriefName : nullToBlank(divItem.StandardBriefName),
						StandardBriefDesc : nullToBlank(divItem.StandardBriefDesc),
						
						CCCDVal : nullToBlank(divItem.CostCenterCode),
						CCNMVal : nullToBlank(divItem.CostCenterName),
						
						IOCDVal : nullToBlank(divItem.IOCode),
						IONMVal : nullToBlank(divItem.IOName),
						
						UsageCommentVal : nullToBlank(divItem.UsageComment).replace(/<br>/gi, '\r\n'),
						
			            //관리항목 셋팅
						TaxType : nullToBlank(divItem.TaxType),
						TaxCode : nullToBlank(divItem.TaxCode),
						CtrlCode : nullToBlank(divItem.CtrlCode)
				}
				
				if(divItem.ReservedStr2_Div != undefined && Object.keys(divItem.ReservedStr2_Div).length > 0)
					valMap.ReservedStr2_Div = divItem.ReservedStr2_Div;
				if(divItem.ReservedStr3_Div != undefined && Object.keys(divItem.ReservedStr3_Div).length > 0)
					valMap.ReservedStr3_Div = divItem.ReservedStr3_Div;
				
				var getForm = me.combiCostApp_htmlFormSetVal(formStr, valMap);
				getForm = me.combiCostApp_htmlFormDicTrans(getForm);
				divArea.append(getForm);
				
				//표준적요, 관리항목 셋팅
			    var targetObj = {
			    	ProofCode : ProofCode
			    	, KeyNo : KeyNo
			    	, Rownum : Rownum
			    };
				
				me.tempObj = Object.assign({}, targetObj);
				me.combiCostApp_setDivSBVal(valMap);
				
			    if(accountCtrl.getInfoStr("[name=CtrlArea][keyno="+KeyNo+"][rownum="+Rownum+"]").length > 0) {
			    	//관리항목 input 값 셋팅
			    	me.combiCostApp_setCtrlDivHtml(valMap);
			    	
			    	//관리항목 popup 처리
			    	if(valMap.ReservedStr2_Div != undefined && Object.keys(valMap.ReservedStr2_Div).length > 0) {
			    		var ctrlType = Object.keys(valMap.ReservedStr2_Div);
			    		
			    		//출장항목 관련 관리항목 처리
				    	if('D01' in valMap.ReservedStr2_Div) {
							accountCtrl.getInfoStr("[code="+ctrlType[0]+"][keyno="+KeyNo+"][rownum="+Rownum+"][tag=select]").val(accountCtrl.getInfoStr("[code="+ctrlType[0]+"][keyno="+KeyNo+"][rownum="+copyRownum+"][tag=select]").val());
							accountCtrl.getInfoStr("[code="+ctrlType[0]+"][keyno="+KeyNo+"][rownum="+Rownum+"][tag=select]").trigger("onchange");
							
				            if(valMap.ReservedStr3_Div != undefined && Object.keys(valMap.ReservedStr3_Div).length > 1) {
				            	var ctrlStr3 = valMap.ReservedStr3_Div[ctrlType[1]];
				            	
				            	if(valMap.ReservedStr3_Div[ctrlType[1]] != undefined && valMap.ReservedStr3_Div[ctrlType[1]] != "") {
									var jsonDiv = JSON.parse(valMap.ReservedStr3_Div[ctrlType[1]]);
									targetObj.code = ctrlType[1];
									me.tempObj = Object.assign({}, targetObj);
					            	
									if(ctrlType[1] == "D02") {
										me.SetDistanceCallBack(jsonDiv);
									} else if(ctrlType[1] == "D03") {
										me.SetDailyCallBack(jsonDiv);
									} else if(ctrlType[1] == "Z09") {
										me.SetDistanceCallBack(jsonDiv);
									}
									
									accountCtrl.getInfoStr("textarea[tag=Comment][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").html(valMap.UsageCommentVal);
									me.combiCostApp_setDivVal(ProofCode, KeyNo, Rownum, "UsageComment", valMap.UsageCommentVal);
				            	}
							}
				        //편익제공 관련 관리항목 처리
			    		} else if('C07' in valMap.ReservedStr2_Div) {
			    			if(valMap.ReservedStr3_Div['C07'] != undefined || valMap.ReservedStr3_Div['C07'] != "") {
								var jsonDiv = JSON.parse(valMap.ReservedStr3_Div['C07']);
								targetObj.code = 'C07';
								me.tempObj = Object.assign({}, targetObj);
				            	
								me.SetAttendantCallBack(jsonDiv);
			    			}
			    		}
			    	}
			    }
			    
				
				me.combiCostApp_makeDivHtmlChkColspan(ProofCode, KeyNo, Rownum);
			},
			
			//세부증빙 관리항목 값 셋팅
			combiCostApp_setCtrlDivHtml : function(divItem) {
				var ctrlCodeArr = divItem.CtrlCode.split(',');
				
				for(var i = 0; i < ctrlCodeArr.length; i++) {
					var ctrlVal = divItem.ReservedStr2_Div[ctrlCodeArr[i]];
					accountCtrl.getInfoStr("[name=CtrlArea] input[code="+ctrlCodeArr[i]+"][proofcd="+divItem.ProofCode+"][keyno="+divItem.KeyNo+"][rownum="+divItem.Rownum+"]").val(ctrlVal);
				}
			},
			
			
			/////////////////파일/문서연결 부===========
			
				

			//파일 추가 팝업 호출
			combiCostApp_FileAttach : function(ProofCode, KeyNo) {
				var me = this;
				me.tempObj.ProofCode = ProofCode;
				me.tempObj.KeyNo = KeyNo;
				
				accountFileCtrl.callFileUpload(this, 'CombineCostApplication<%=requestType%>.combiCostApp_FilCallback')
				
			},
			
			//파일팝업에서 추가된 팝업들을 세팅
			combiCostApp_FilCallback : function(data) {
				var me = window.CombineCostApplication<%=requestType%>;

				var ProofCode = me.tempObj.ProofCode
				var KeyNo = me.tempObj.KeyNo

				var pageList = me.combiCostApp_getPageList(ProofCode);
				var getItem = me.combiCostApp_findListItem(pageList, "KeyNo", KeyNo);
				if(getItem.uploadFileList == null){
					getItem.uploadFileList = data;
				}else{
					var tempList = getItem.uploadFileList;
					var index = getItem.uploadFileList.length;
					for(var i = 0; i < data.length; i++) {
						tempList[index+i] = data[i];						
					}
					getItem.uploadFileList = tempList;
					//getItem.uploadFileList = getItem.uploadFileList.concat(data);
				}
				
				if(getItem.fileMaxNo==null){
					getItem.fileMaxNo = 0;
				}
				
				for(var i = 0; i<data.length; i++){
					var fileItem = data[i];
					getItem.fileMaxNo++;
					fileItem.fileNum = getItem.fileMaxNo;
				}
				
				accountFileCtrl.closeFilePopup();
				me.combiCostApp_UploadHTML(data, KeyNo, ProofCode, false);
				me.combiCostApp_linkCk(ProofCode, KeyNo);
			},


			//팝업 html을 생성
			combiCostApp_UploadHTML : function(data, KeyNo, ProofCode, isSearched) {
				var me = window.CombineCostApplication<%=requestType%>;
				
				var list = data
				var fileList = [];
				var fileStr = "";
				var pageList = me.combiCostApp_getPageList(ProofCode);
				//var KeyField = me.combiCostApp_getProofKey(ProofCode);
				if(list==null){
					return;
				}
				for(var i = 0; i<list.length; i++){
					var fileInfo = list[i];
					var info = $.extend({}, fileInfo);
					info.KeyNo = KeyNo
					
					
					var fileHtmlStr = "<div class='File_list' name='combiCostApp"+ProofCode+"_FileItem_"+KeyNo+"_"+fileInfo.fileNum+"'>"
					if(fileInfo.FileID != null){
						fileHtmlStr = fileHtmlStr+"<a href='javascript:void(0);' class='btn_FileDel' onClick=\"CombineCostApplication<%=requestType%>.combiCostApp_FileDelete('"+ProofCode+"', '"+KeyNo+"','"+fileInfo.fileNum+"')\"></a>"
						+"<a href='javascript:void(0);' class='btn_File ico_file' onClick=\"CombineCostApplication<%=requestType%>.combiCostApp_FileDownload('"+escape(fileInfo.SavedName)+"','"+escape(fileInfo.FileName)+"','"+fileInfo.FileID+"')\">"+ fileInfo.FileName 
						+"<span class='tx_size'>("+ ckFileSize(fileInfo.Size) +")</span></a>"
						+"<a class='previewBtn' style='margin: 0px 10px;' href='javascript:void(0);' onclick=\"accountFileCtrl.attachFilePreview('" + fileInfo.FileID + "','" + fileInfo.FileToken + "','" + fileInfo.FileName.split(".")[fileInfo.FileName.split(".").length-1].toLowerCase() + "');\"></a>";
						+"</div>";
					}else{
						fileHtmlStr = fileHtmlStr+"<a href='javascript:void(0);' class='btn_FileDel' onClick=\"CombineCostApplication<%=requestType%>.combiCostApp_NewFileDelete('"+ProofCode+"', '"+KeyNo+"','"+fileInfo.fileNum+"')\"></a>"
						+"<a href='javascript:void(0);' class='btn_File ico_file' >"+ fileInfo.FileName 
						+"<span class='tx_size'>("+ ckFileSize(fileInfo.Size) +")</span></a></div>";
					}
					if(!isSearched){
						//fileList.push(info)
					}
					accountCtrl.getInfoStr("[name=LinkArea][proofcode="+ProofCode+"][keyno="+KeyNo+"]").append(fileHtmlStr);
				}
				me.combiCostApp_linkCk(ProofCode, KeyNo);
			},
			
			//파일 삭제
			combiCostApp_FileDelete : function(ProofCode, KeyNo, fileNum){
				var me = this;
				
				Common.Confirm("<spring:message code='Cache.ACC_lbl_DeleteAttachFile' />", "Confirmation Dialog", function(result){
					if(result){
						var pageList = me.combiCostApp_getPageList(ProofCode);
						//var KeyField = me.combiCostApp_getProofKey(ProofCode);
						var item = me.combiCostApp_findListItem(pageList, "KeyNo", KeyNo);
						var fileList = item.fileList;
						var idx = accFindIdx(fileList, "fileNum", fileNum );
						accountCtrl.getInfoName("combiCostApp"+ProofCode+"_FileItem_"+KeyNo+"_"+fileNum).remove();
						
						if(idx != -1){
							var fileItem = fileList[idx];
							fileList.splice(idx,1);
							if(item.deletedFile == null){
								item.deletedFile = [fileItem];
							}else{
								item.deletedFile.push(fileItem);
							}
						}
						me.combiCostApp_linkCk(ProofCode, KeyNo);
					}
				});
			},
			
			//아직 저장되지 않은 파일을 삭제
			combiCostApp_NewFileDelete : function(ProofCode, KeyNo, fileNum){
				var me = this;
				
				Common.Confirm("<spring:message code='Cache.ACC_lbl_DeleteAttachFile' />", "Confirmation Dialog", function(result){
					if(result){
						var pageList = me.combiCostApp_getPageList(ProofCode);
						//var KeyField = me.combiCostApp_getProofKey(ProofCode);
						var item = me.combiCostApp_findListItem(pageList, "KeyNo", KeyNo);
						var uploadFileList = item.uploadFileList;
						var idx = accFindIdx(uploadFileList, "fileNum", fileNum );
						accountCtrl.getInfoName("combiCostApp"+ProofCode+"_FileItem_"+KeyNo+"_"+fileNum).remove();
						
						if(idx != -1){
							var tempList = [];
							for(var i = 0; i < uploadFileList.length; i++) {
								if(i != idx) {
									tempList.push(uploadFileList[i]);
								}
							}
							if(tempList.length == 0) tempList = null;
							item.uploadFileList = tempList;
							
							//uploadFileList.splice(idx,1);
						}
						me.combiCostApp_linkCk(ProofCode, KeyNo);
					}
				});
			},
			
			//파일 ㅏㄷ운로드
			combiCostApp_FileDownload : function(SavedName, FileName, FileID){
				accountFileCtrl.downloadFile(SavedName, FileName, FileID)
			},
			

			//문서 연결 팝업
			//결재 문서 연결로 변경됨
			combiCostApp_DocLink : function(page, key) {
				var me = this;
				me.tempObj.ProofCode = page;
				me.tempObj.KeyNo = key;
				
				var url	= "/approval/goDocListSelectPage.do";
				var iWidth = 1000, iHeight = 660, sSize = "fix";
				CFN_OpenWindow(url, "", iWidth, iHeight, sSize);
			},
			
			//결재문서 연결 후처리
			combiCostApp_LinkComp : function(data) {
				var me = window.CombineCostApplication<%=requestType%>;
				var list = typeof(data) == "string" ? data.split("^^^") : data;
				if(list == null){
					return;
				}
				
				var ProofCode = me.tempObj.ProofCode;
				var KeyNo = me.tempObj.KeyNo;
				var pageList = me.combiCostApp_getPageList(ProofCode);

				var docList = [];
				
				var item = me.combiCostApp_findListItem(pageList, "KeyNo", KeyNo);
				var pageDocList = item.docList;

				if(pageDocList == null){
					pageDocList = [];
				}

				for(var i = 0; i<list.length; i++){
					var docInfo = {};
					if(typeof(list[i]) == "string") {
						var tempList = list[i].split('@@@');
						docInfo.ProcessID = tempList[0];
						docInfo.FormPrefix = tempList[1];
						docInfo.Subject = tempList[2];
						docInfo.forminstanceID = tempList[3];
						docInfo.bstored = tempList[4];
						docInfo.BusinessData1 = tempList[5];
						docInfo.BusinessData2 = tempList[6];
					} else {
						docInfo = list[i];						
					}
					
					// 기존에 추가된 연결문서와 중복 체크
					var ckDocItem = me.combiCostApp_findListItem(pageDocList, "ProcessID", docInfo.ProcessID);
					if(ckDocItem == null) {
						ckDocItem = {};
					}
					
					if(isEmptyStr(ckDocItem.ProcessID)){
						var info = $.extend({}, docInfo);
						info.KeyNo = KeyNo;				
						
						// 문서연결 팝업에서 선택할 때 동일한 문서(ProcessID 기준) 선택 시 1건만 들어가도록 처리
						var isDup = false;
						for(var j = 0; j < docList.length; j++) {
							if(info.ProcessID == docList[j].ProcessID) {
								isDup = true;
							} 
						}
	
						if(!isDup) {	
							var docHtmlStr = "<div class='File_list'  name='expApp"+ProofCode+"_DocItem_"+KeyNo+"_"+docInfo.ProcessID+"'>"
								+"<a href='javascript:void(0);' class='btn_FileDel' onClick=\"CombineCostApplication<%=requestType%>.combiCostApp_DocDelete('"+ProofCode+"','"+KeyNo+"','"+docInfo.ProcessID+"')\"></a>"
								+"<a href='javascript:void(0);' class='btn_File ico_doc' onClick=\"CombineCostApplication<%=requestType%>.combiCostApp_LinkOpen('"+ docInfo.ProcessID + "', '" + docInfo.forminstanceID + "', '" + docInfo.bstored + "', '" + docInfo.BusinessData2 + "')\">" + nullToStr(docInfo.Subject, "("+"<spring:message code='Cache.ACC_lbl_noTitle' />"+")")+"</a>" 	
								+"</div>";
							
							docList.push(info);
							
							accountCtrl.getInfoStr("[name=LinkArea][proofcode="+ProofCode+"][keyno="+KeyNo+"]").append(docHtmlStr);
						}
					}
				}
				
				if(item.docList == null || item.docList.length == 0){
					item.docList = docList;
				}else{
					var tempList = item.docList;
					var index = item.docList.length;
					for(var i = 0; i < docList.length; i++) {
						tempList[index + i] = docList[i];
					}
					item.docList = tempList;
				}
				
				if(item.docMaxNo==null){
					item.docMaxNo = 0;
				}
				
				for(var i = 0; i<docList.length; i++){
					var docItem = docList[i];
					item.docMaxNo++;
					docItem.docNum = item.docMaxNo;
				}
				
				me.combiCostApp_linkCk(ProofCode, KeyNo);
			},


			//문서 연결부 html 생성
			combiCostApp_DocHTML : function(data, KeyNo, ProofCode, isSearched) {
				var me = window.CombineCostApplication<%=requestType%>;
				
				var list = data
				//var docList = [];
				var pageList = me.combiCostApp_getPageList(ProofCode);
				//var KeyField = me.combiCostApp_getProofKey(ProofCode);
				if(list==null){
					return;
				}

				for(var i = 0; i<list.length; i++){
					var docInfo = list[i];
					var info = $.extend({}, docInfo);
					info.KeyNo = KeyNo

					var docHtmlStr = 
					"<div class='File_list'  name='expApp"+ProofCode+"_DocItem_"+KeyNo+"_"+docInfo.ProcessID+"'>"
					+"<a href='javascript:void(0);' class='btn_FileDel' onClick=\"CombineCostApplication<%=requestType%>.combiCostApp_DocDelete('"+ProofCode+"','"+KeyNo+"','"+docInfo.ProcessID+"')\"></a>"
					+"<a href='javascript:void(0);' class='btn_File ico_doc' onClick=\"CombineCostApplication<%=requestType%>.combiCostApp_LinkOpen('"+ docInfo.ProcessID + "', '" + docInfo.forminstanceID + "', '" + docInfo.bstored + "', '" + docInfo.BusinessData2 + "')\">"+ nullToStr(docInfo.Subject, "("+"<spring:message code='Cache.ACC_lbl_noTitle' />"+")")+"</a>" 	

					//docList.push(info)
					accountCtrl.getInfoStr("[name=LinkArea][proofcode="+ProofCode+"][keyno="+KeyNo+"]").append(docHtmlStr);
				}
				me.combiCostApp_linkCk(ProofCode, KeyNo);
			},
			
			
			//결재문서 연결 삭제
			combiCostApp_DocDelete : function(ProofCode, KeyNo, docID){
				var me = this;
				Common.Confirm("<spring:message code='Cache.ACC_lbl_DeleteDocLink' />", "Confirmation Dialog", function(result){
					if(result){
						var pageList = me.combiCostApp_getPageList(ProofCode);
						//var KeyField = me.combiCostApp_getProofKey(ProofCode);
						var item = me.combiCostApp_findListItem(pageList, "KeyNo", KeyNo);
						var docList = item.docList;
						var tempList = [];
						
						for(var i = 0; i < docList.length; i++){
							var docItem = docList[i];
							if(docItem.ProcessID != docID){
								tempList.push(docItem);										
							} else {
								accountCtrl.getInfoName("expApp"+ProofCode+"_DocItem_"+KeyNo+"_"+docID).remove();
								
								if(item.deletedDoc == null){
									item.deletedDoc = [docItem];
								}else{
									item.deletedDoc.push(docItem);
								}
							}
						}
						
						item.docList = tempList;
						
						/* if(docList != null){
							var idx = accFindIdx(docList, "ProcessID", docID );
							if(idx>=0){
								var docItem = me.combiCostApp_findListItem(docList, "ProcessID", docID);
								docList.splice(idx, 1);
	
								accountCtrl.getInfoName("expApp"+ProofCode+"_DocItem_"+KeyNo+"_"+docID).remove();
								
								if(item.deletedDoc == null){
									item.deletedDoc = [docItem];
								}else{
									item.deletedDoc.push(docItem);
								}
							}
						} */
						me.combiCostApp_linkCk(ProofCode, KeyNo);
					}
				});
			},
			
			//추가된 파일과 문서연결 유무로 class 변경
			combiCostApp_linkCk : function(ProofCode, KeyNo) {
				var me = this;
				
				var pageList = me.combiCostApp_getPageList(ProofCode);

				var ckVal = false;

				var item = me.combiCostApp_findListItem(pageList, "KeyNo", KeyNo);
				var fList = []
				if(item.fileList != null){
					fList = fList.concat(item.fileList)
				}
				if(item.uploadFileList != null){
					fList = fList.concat(item.uploadFileList)
				}
				
				if(fList != null){
					if(fList.length != 0){
						ckVal = true
					}
				}

				var dList = item.docList;
				if(dList != null){
					if(dList.length != 0){
						ckVal = true
					}
				}
				
				if(ckVal){
					accountCtrl.getInfoStr("[name=LinkArea][proofcode="+ProofCode+"][keyno="+KeyNo+"]").removeClass("border_none");
				}else{
					accountCtrl.getInfoStr("[name=LinkArea][proofcode="+ProofCode+"][keyno="+KeyNo+"]").addClass("border_none");
				}
			},

			combiCostApp_LinkOpen : function(ProcessId, forminstanceID, bstored, expAppID){
				accComm.accLinkOpen(ProcessId, forminstanceID, bstored, expAppID);
			},
			
			///////////////////////////결재연동부/////////////////////////
			combiCostApp_getHTMLBody : function() {
				var me = this;				
				me.combiCostApp_makeHtmlViewFormAllApv();
				
				var evidListArea = accountCtrl.getInfo("comCostApp_TotalWrap")[0].outerHTML;
				
				var temp = accountCtrl.getInfo("combiCostApp_evidListAreaApv");
			    
				evidListArea += $(temp).html();
			    
				return evidListArea;
			},
			
			combiCostApp_makeHtmlViewFormAllApv : function(){
				var me = this;
				var proofCode = "";
				var tableStr = ""; 
				
				for(var i = 0; i<me.pageExpenceAppEvidList.length; i++){
					var getItem = me.pageExpenceAppEvidList[i];

					var htmlStr = me.combiCostApp_makeViewHtmlFormApv(getItem, i+1);
							
					if(proofCode != getItem.ProofCode) {
						if(proofCode != "") {
							tableStr += '</tbody></table>';
						}
						proofCode = getItem.ProofCode;
						
						var title = Common.getDic('ACC_lbl_' + proofCode + 'UseInfo');
						tableStr += '<p class="taw_top_sub_title">'+title+'</p>'
									+ '<table class="acstatus_wrap">'
									+ '<tbody>'
									+ htmlStr
					} else {
						tableStr += htmlStr;
					}
				}
				
				accountCtrl.getInfo("combiCostApp_evidListAreaApv").html(tableStr);

				proofCode = "";
				for(var i = 0; i<me.pageExpenceAppEvidList.length; i++){
					var getItem = me.pageExpenceAppEvidList[i];
					
					if(proofCode != getItem.ProofCode) {
						proofCode = getItem.ProofCode;
					} else {
						accountCtrl.getInfoStr("tr[name=headerArea][viewkeyno="+getItem.ViewKeyNo+"]").remove();
					}
					
					me.combiCostApp_makeHtmlChkColspanApv(accountCtrl.getInfoStr("[name=evidItemAreaApv][viewkeyno="+getItem.ViewKeyNo+"]"));

					if(isEmptyStr(getItem.TaxInvoiceID) && getItem.ProofCode=="TaxBill"){
						accountCtrl.getInfoStr("[name=noTaxIFView][proofcode="+getItem.ProofCode+"][viewkeyno="+getItem.ViewKeyNo+"]").remove();
					}
					
					if((getItem.docList == null && getItem.fileList == null) 
							|| ((getItem.docList != null && getItem.docList.length == 0) && (getItem.fileList != null && getItem.fileList.length == 0))) {
						accountCtrl.getInfoStr("[name=fileDocAreaApv][viewkeyno=" + getItem.ViewKeyNo + "]").remove();
					} else {
						accountCtrl.getInfoStr("[name=evidItemAreaApv][viewkeyno=" + getItem.ViewKeyNo + "]").find("td").each(function(i, obj) { 
							if($(obj).attr("rowspan") != undefined) { 
								$(obj).attr("rowspan", Number($(obj).attr("rowspan"))+1) 
							} 
						});
						
						<%-- if(getItem.docList != null){
							for(var y = 0; y<getItem.docList.length; y++){
								var getDoc = getItem.docList[y];
								var str = 						
									"<a href='javascript:void(0);' class='btn_File ico_doc' style='margin-right: 10px;' onClick=\"CombineCostApplication<%=requestType%>.combiCostApp_LinkOpen('"
											+ getDoc.ProcessID+"', '" + getDoc.forminstanceID + "', '" + getDoc.bstored + "', '" + getDoc.BusinessData2 + "')\">"
											+ nullToStr(getDoc.Subject, "("+"<spring:message code='Cache.ACC_lbl_noTitle' />"+")") +"</a>";
											
								var getStr = accountCtrl.getInfoStr("[name=DocViewArea][proofcode="+getItem.ProofCode+"][viewkeyno="+getItem.ViewKeyNo+"]").append(str);
							}
						}
						
						if(getItem.fileList != null){
							for(var y = 0; y<getItem.fileList.length; y++){
								var fileInfo = getItem.fileList[y];
								var str = 						
									"<a href='javascript:void(0);' class='btn_File ico_file' style='width: auto;' onClick=\"CombineCostApplication<%=requestType%>.combiCostApp_FileDownload('"+fileInfo.SavedName+"','"+fileInfo.FileName+"','"+fileInfo.FileID+"')\">"+ fileInfo.FileName 
									+"<span class='tx_size'>("+ ckFileSize(fileInfo.Size) +")</span></a>"
									+"<a class='previewBtn' style='margin: 0px 10px;' href='javascript:void(0);' onclick=\"accountFileCtrl.attachFilePreview('" + fileInfo.FileID + "','" + fileInfo.FileToken + "','" + fileInfo.FileName.split(".")[fileInfo.FileName.split(".").length-1].toLowerCase() + "');\"></a>";
				
								var getStr = accountCtrl.getInfoStr("[name=FileViewArea][proofcode="+getItem.ProofCode+"][viewkeyno="+getItem.ViewKeyNo+"]").append(str);
							}
						} --%>
					}
				}
			},
			
			//조회 폼 생성하여 html을 str로 반환 - 결재연동
			combiCostApp_makeViewHtmlFormApv : function(inputItem, rowNum) {
				var me = this;
				if(inputItem != null){

					var ProofCode = inputItem.ProofCode;
					var ViewKeyNo = inputItem.ViewKeyNo;
					var apvFormStr = me.pageCombiAppFormList[ProofCode+"ViewApvFormStr"];

					var TC = nullToBlank(inputItem.TaxCode)
					var TT = nullToBlank(inputItem.TaxType)
					var PM = nullToBlank(inputItem.PayMethod)
					var PT = nullToBlank(inputItem.PayType)
					var PG = nullToBlank(inputItem.PayTarget)
					var PV = nullToBlank(inputItem.Providee)
					var BT = nullToBlank(inputItem.BillType)
					
					var TaxCodeNm = me.combiCostApp_getCodeMapInfo(me.pageCombiAppComboData.TaxCodeMap, TC, 'CodeName')
					var TaxTypeNm = me.combiCostApp_getCodeMapInfo(me.pageCombiAppComboData.TaxTypeMap, TT, 'CodeName')
					var PayMethodNm = me.combiCostApp_getCodeMapInfo(me.pageCombiAppComboData.PayMethodMap, PM, 'CodeName')
					var PayTypeNm = me.combiCostApp_getCodeMapInfo(me.pageCombiAppComboData.PayTypeMap, PT, 'CodeName')
					var PayTargetNm = me.combiCostApp_getCodeMapInfo(me.pageCombiAppComboData.PayTargetMap, PG, 'CodeName')
					var ProvideeNm = me.combiCostApp_getCodeMapInfo(me.pageCombiAppComboData.ProvideeMap, PV, 'CodeName')
					var BillTypeNm = me.combiCostApp_getCodeMapInfo(me.pageCombiAppComboData.BillTypeMap, BT, 'CodeName')
					
					var divList = inputItem.divList;
					var divApvStr = "";
					var divApvStr2 = "";
					for(var y = 0; y < divList.length; y++){
						var divItem = divList[y];
						
						var addUsageComment = "";
						
						var divValMap = {
								AccountName : nullToBlank(divItem.AccountName),
								StandardBriefName : nullToBlank(divItem.StandardBriefName),
								CostCenterName : nullToBlank(divItem.CostCenterName),
								IOName : nullToBlank(divItem.IOName),
								DocNo : nullToBlank(divItem.DocNo),
								UsageComment : nullToBlank(divItem.UsageComment),
								AddUsageComment : addUsageComment, //TODO: 부가적요 표시하기
								DivAmount : toAmtFormat(divItem.Amount)
						}
						
						//결재양식 용 view form setting
						var htmlDivApvFormStr = me.pageCombiAppFormList.DivViewApvFormStr;
						htmlDivApvFormStr = me.combiCostApp_htmlFormSetVal(htmlDivApvFormStr, divValMap);
						
						if(y == 0) {
							divApvStr = htmlDivApvFormStr;
						} else {
							divApvStr2 += "<tr>" + htmlDivApvFormStr + "</tr>"; //세부증빙 여러개일 경우 처리
						}
					}
					
					inputItem.AccountBankName = accComm.getBaseCodeName("Bank", nullToBlank(inputItem.AccountBank), me.CompanyCode);
					
					if(inputItem.AccountBankName == "") {
						inputItem.AccountBankName = inputItem.AccountBank;
					}

					var valMap = {
							ViewKeyNo : nullToBlank(inputItem.ViewKeyNo),
							ProofCode : nullToBlank(inputItem.ProofCode),
							
							TotalAmount : toAmtFormat(nullToBlank(inputItem.TotalAmount)),							
							RepAmount : toAmtFormat(nullToBlank(inputItem.RepAmount)),
							TaxAmount : toAmtFormat(nullToBlank(inputItem.TaxAmount)),
							SupplyCost : toAmtFormat(nullToBlank(inputItem.SupplyCost)),
							Tax : toAmtFormat(nullToBlank(inputItem.Tax)),
							
							ProofDate : nullToBlank(inputItem.ProofDateStr),
							PostingDate : nullToBlank(inputItem.PostingDateStr),
							PayDate : nullToBlank(inputItem.PayDateStr),
							ProofTime : nullToBlank(inputItem.ProofTimeStr),
							
							StoreName : nullToBlank(inputItem.StoreName).trim(),
							CardUID : nullToBlank(inputItem.CardUID),
							CardApproveNo : nullToBlank(inputItem.CardApproveNo),
							
							ReceiptID : nullToBlank(inputItem.ReceiptID),
							
							TaxInvoiceID : nullToBlank(inputItem.TaxInvoiceID),
							TaxUID : nullToBlank(inputItem.TaxUID),
							TaxNTSConfirmNum : nullToBlank(inputItem.TaxNTSConfirmNum),
							InvoicerCorpNum : nullToBlank(inputItem.InvoicerCorpNum),
							
							CashUID : nullToBlank(inputItem.CashUID),
							CashNTSConfirmNum : nullToBlank(inputItem.CashNTSConfirmNum),
							
							AccountInfo : nullToBlank(inputItem.AccountInfo),
							AccountHolder : nullToBlank(inputItem.AccountHolder),
							AccountBank : nullToBlank(inputItem.AccountBank),
							AccountBankName : nullToBlank(inputItem.AccountBankName),
							BankName : nullToBlank(inputItem.BankName),
							BankAccountNo : nullToBlank(inputItem.BankAccountNo),
							
							VendorNo : nullToBlank(inputItem.VendorNo),
							VendorName : nullToBlank(inputItem.VendorName),
							PayMethod : PayMethodNm,
							PayType : PayTypeNm,
							PayTarget : PayTargetNm,
							TaxCodeNm : TaxCodeNm,
							TaxTypeNm : TaxTypeNm,
							PaymentConditionName : nullToBlank(inputItem.PaymentConditionName),
							
							ProviderName : nullToBlank(inputItem.ProviderName),
							ProviderNo : nullToBlank(inputItem.ProviderNo),
							Providee : ProvideeNm,
							BillType : BillTypeNm,

							FranchiseCorpName : nullToBlank(inputItem.FranchiseCorpName),
							PersonalCardNoView : nullToBlank(inputItem.PersonalCardNoView),
							
							pageNm : "CombineCostApplication<%=requestType%>",
							MobileAppClick : "combiCostApp_MobileAppClick",
							FileID : nullToBlank(inputItem.FileID)
					}
					valMap.rowNum = rowNum;
					valMap.rowspan = divList.length;
					valMap.divApvArea = divApvStr;
					valMap.divApvArea2 = divApvStr2; //세부증빙 여러개일 경우 처리
					
					//결재양식 용 view form setting
					var getApvForm = me.combiCostApp_htmlFormSetVal(apvFormStr, valMap);
					getApvForm = me.combiCostApp_htmlFormDicTrans(getApvForm);
					
					return getApvForm;
				}
			},
			
			combiCostApp_makeHtmlChkColspanApv : function(divObj) {
				if(divObj == undefined)
					return;
				
				if(isUseIO == "N"){
					$(divObj).find("[name=noIOArea]").remove();
					$(divObj).find("[name=accArea]").attr("rowspan", "2");
				}
				if(isUseSB == "N") {
					$(divObj).find("[name=noSBArea]").remove();
					$(divObj).find("[name=ccArea]").attr("rowspan", "2");
				}
			   	if(isUseBD == "" || isUseBD == "N") {
			   		$(divObj).find("[name=noBDArea]").remove();
					$(divObj).find("[name=slipArea]").attr("rowspan", "2");
				}
			},

			combiCostApp_setModified : function(val) {
				var me = this;
				me.dataModified = val;
			},
			
			combiCostApp_showPreview : function() {
				var me = this;
				me.combiCostApp_getDataObj();
				
				//신청 건 미리보기
				Common.open("","ExpenceApplicationPreviewPopup","<spring:message code='Cache.btn_preview'/>",
					"/account/expenceApplication/ExpenceApplicationPreviewPopup.do?parentID=CombineCostApplication<%=requestType%>","1000px","800px","iframe",true,"450px","100px",true);
				
			},
			
			combiCostApp_toggleShowArea : function() {
				var me = this;
				
				if(accountCtrl.getInfo("combineCostAppDiv").hasClass("Close")) {
					accountCtrl.getInfo("combineCostAppDiv").removeClass("Close");
					accountCtrl.getInfo("graphicDiv").show();
					accountCtrl.getInfoStr("a[class=btn_taw_close]").addClass("btn_taw_open");
					accountCtrl.getInfoStr("a[class=btn_taw_close]").removeClass("btn_taw_close");
				} else {
					accountCtrl.getInfo("combineCostAppDiv").addClass("Close");
					accountCtrl.getInfo("graphicDiv").hide();
					accountCtrl.getInfoStr("a[class=btn_taw_open]").addClass("btn_taw_close");
					accountCtrl.getInfoStr("a[class=btn_taw_open]").removeClass("btn_taw_open");
				}
				
				me.combiCostApp_comboRefresh();
			},
			
			getRequestType : function(){
				return requestType;
			}
	}
	window.CombineCostApplication<%=requestType%> = $.extend(window.CombineCostApplication<%=requestType%>, CombineCostApplication<%=requestType%>);
	
	
	
	
	
	
	
	/////////////////////////// 현금영수증 ///////////////////////////
	
	var CombineCostApplicationCash<%=requestType%> = {		
				
		cashBillPageExpenceAppList : [],

		combiCostAppCB_CashBillPageInit : function() {
			var me = this;
			accountCtrl.getInfoName("combiCostAppCB_TableArea").html("");
			me.cashBillPageExpenceAppList = [];
		},
		combiCostAppCB_CashBillDataInit : function() {
			var me = this;
			accountCtrl.getInfoName("combiCostAppCB_TableArea").html("");
			me.cashBillPageExpenceAppList = [];
		},


		combiCostAppCB_cashPopupLoad : function() {
			var me = this;
			me.combiCostAppCB_callCashPopup();
		},

		combiCostAppCB_callCashPopup : function() {
			var me = this;
			//me.combiCostAppCB_CashBillDataInit();
			var info = {
					popupUrl		: "/account/accountCommon/accountCommonPopup.do",
					popupID 		: "cashBillSearchPopup",
					popupTit 		: "<spring:message code='Cache.ACC_btn_cashBillLoad'/>",
					popupName 		: "CashBillSearchPopup",
					callBackFunc 	: "combiCostAppCB_getCashInfo",
					includeAccount 	: "N",
					paramsetFunc	: "combiCostApp_CallAddLoadPopupParam"
			}
			var url = me.makeObjPopupUrl(info);
			Common.open(	"",info.popupID,info.popupTit,url,"1300px","700px","iframe",true,null,null,true);
		},
		
		//세금코드 필요 추가정보 조회
		combiCostAppCB_getCashInfo : function(inputList, val) {
			var me = this;
			$.ajax({
				type:"POST",
					url:"/account/expenceApplication/getCashBillInfo.do",
				data:{
					cashBillIDs : inputList
				},
				success:function (data) {
					if(data.result == "ok"){
						var getCashBillList = data.list;
						
	
						var duplCk = false;
						var duplList = "";
						for(var i = 0; i<getCashBillList.length; i++){
							var item = getCashBillList[i];
							if(item.IsDuplicate=="Y"){
								duplCk = true;
								if(duplList==""){
									duplList = item.NTSConfirmNum;
								}else{
									duplList = duplList+", "+item.NTSConfirmNum;
								}
							}
						}
						if(duplCk){
							
							Common.Error("<spring:message code='Cache.ACC_016' />");		//@@{appNoList}는 이미 추가된 항목입니다.
							msg = msg.replace("@@{appNoList}", appNoList);
							Common.Error(msg);
							return;
						}

						me.combiCostAppCB_inputListDataAdd(getCashBillList, true);
					}
					else{
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
					}
				},
				error:function (error){
					Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
				}
			});
		},

		combiCostAppCB_inputListDataAdd : function(itemList, isNew) {
			var me = this;
			me.combiCostApp_setModified(true);
			var arrCk = Array.isArray(itemList);
			if(arrCk){
				var addedCk1 = false;
				var addedCk2 = false;
				var confirmNoList = "";
				if(isNew){
					for(var i = 0; i<itemList.length; i++){
	
						var newItem = itemList[i]
						var oldItem = null;
						for(var y = 0; y<me.cashBillPageExpenceAppList.length; y++){
							oldItem = me.cashBillPageExpenceAppList[y];
							if(oldItem.CashUID == newItem.CashUID){
								addedCk1 = true;
								if(confirmNoList==""){
									confirmNoList = newItem.CashNTSConfirmNum
								}else{
									confirmNoList = confirmNoList+","+newItem.CashNTSConfirmNum
								}
								break;
							}
						}
						
						if(addedCk1){
							break;
						}
					}
	
					if(addedCk1){
						var msg = "<spring:message code='Cache.ACC_016' />";		//@@{appNoList}는 이미 추가된 항목입니다.
						msg = msg.replace("@@{appNoList}", confirmNoList);
						Common.Error(msg);
						return;
					}
				}


				for(var i = 0; i<itemList.length; i++){
					var item = itemList[i];
					if(isNew){
	
						item.IsNew = true;
						item.IsNewStr = "Y";
					}
					var maxKey = me.combiCostApp_getPageListMaxKey('CashBill');
					item.KeyNo = maxKey+1;
					item.ProofCode = "CashBill";
					/* var today = new Date();
					if(item.ProofDate == null){
						item.ProofDate = today.format("yyyyMMdd");
						item.ProofDateStr = today.format("yyyy.MM.dd");
					}
					if(item.PostingDate == null){
						item.PostingDate = today.format("yyyyMMdd");
						item.PostingDateStr = today.format("yyyy.MM.dd");
					} */
					if(item.ProofDate == null) { item.ProofDate = ""; item.ProofDateStr = ""; }
					if(item.PostingDate == null) { item.PostingDate = ""; item.PostingDateStr = ""; }
					
					var divCk = false;
					if(item.divList == null){
						divCk = true;
					}
					else if(item.divList.length==0){
						divCk = true;
					}
					if(divCk){
						item.divList = [];
						var divItem = {
								ExpenceApplicationListID : item.ExpenceApplicationListID
								, KeyNo : item.KeyNo
								, ProofCode : item.ProofCode
								
								, ExpenceApplicationDivID : ""
								, AccountCode :  ""
								, AccountName : ""
								, StandardBriefID :  ""
								, StandardBriefName : ""
								, CostCenterCode :  nullToBlank(me.pageCombiAppComboData.DefaultCC.CostCenterCode)
								, CostCenterName :  nullToBlank(me.pageCombiAppComboData.DefaultCC.CostCenterName)
								, IOCode : ""
								, IOName : ""
								, Amount : item.TotalAmount
								, UsageComment : ""
								, IsNew : true
								, Rownum : 0
						}
						item.divList.push(divItem);
					}
					me.cashBillPageExpenceAppList.push(item);
				}

				me.combiCostAppCB_setListHTML(false, itemList);
			}
		},

		//현금영수증 사용내역 HTML 만들기
		combiCostAppCB_setListHTML : function(isAll, inputList) {
			var me = this;
			
			if(isAll){
				accountCtrl.getInfoName("combiCostAppCB_TableArea").html("");
			}
			var list = [];
			
			if(inputList == null){
				list = me.cardPageExpenceAppList;
			}else{
				list = inputList;
			}
			
			for(var i = 0; i<list.length; i++){
				var item = list[i];
				var valMap = {
						RequestType : requestType,
						ExpenceApplicationListID : nullToBlank(item.ExpenceApplicationListID),
						KeyNo : nullToBlank(item.KeyNo),
						CashUID : nullToBlank(item.CashUID),
						CashNTSConfirmNum : nullToBlank(item.CashNTSConfirmNum),
						ProofCode : nullToBlank(item.ProofCode),
						ProofDate : nullToBlank(item.ProofDateStr),

						TotalAmount : toAmtFormat(nullToBlank(item.TotalAmount)),
						FranchiseCorpName : nullToBlank(item.FranchiseCorpName),
						Tax : toAmtFormat(nullToBlank(item.Tax)),
						SupplyCost : toAmtFormat(nullToBlank(item.SupplyCost)),
						
						TaxType : nullToBlank(item.TaxType),
						TaxCode : nullToBlank(item.TaxCode),
						PayMethod : nullToBlank(item.PayMethod),
						PayType : nullToBlank(item.PayType),
						PayTarget : nullToBlank(item.PayTarget),
						AlterPayeeNo : nullToBlank(item.AlterPayeeNo),
						AlterPayeeName : nullToBlank(item.AlterPayeeName),
						VendorName : nullToBlank(item.VendorName),
						VendorNo : nullToBlank(item.VendorNo),
						VendorID : nullToBlank(item.VendorID),
						BusinessNumber : nullToBlank(item.BusinessNumber),
						AccountInfo : nullToBlank(item.AccountInfo),
						AccountHolder : nullToBlank(item.AccountHolder),
						AccountBank : nullToBlank(item.AccountBank)
				}
				var htmlStr = me.combiCostApp_makeInputHtmlForm(item, valMap);
				accountCtrl.getInfoName("combiCostAppCB_TableArea").append(htmlStr);
				
				
				me.combiCostApp_makeInputDivHtmlAdd(item);


				var selectFieldList = accountCtrl.getInfoStr("[name=ComboSelect][proofcode="+item.ProofCode+"][keyno="+item.KeyNo+"]");
				for(var y = 0; y<selectFieldList.length; y++){
					var field = selectFieldList[y];

					var dataField = field.getAttribute("field");
					field.value=nullToBlank(item[dataField]);
					
					if(field.onchange!=null){
						field.onchange();
					}
				}
				

				var docList = item.docList;
				if(docList != null){
					var setDocList = [].concat(docList);
					me.combiCostApp_DocHTML(setDocList, item.KeyNo, 'CashBill', false);
				}
				
				
				var fileList = item.fileList;
				var uploadFileList = item.uploadFileList;
				var setFileList = []
				if(fileList != null){
					setFileList = setFileList.concat(fileList);
				}
				if(uploadFileList != null){
					setFileList = setFileList.concat(uploadFileList);
				}
				item.fileMaxNo = 0;
				if(setFileList != null){
					
					for(var y = 0; y<setFileList.length; y++){
						var fileItem = setFileList[y];
						item.fileMaxNo++;
						fileItem.fileNum = item.fileMaxNo;
					}
					me.combiCostApp_UploadHTML(setFileList, item.KeyNo, 'CashBill', false);
				}
			}
			me.combiCostApp_makeDateField("CashBill", list);
		},

	}
	window.CombineCostApplication<%=requestType%> = $.extend(window.CombineCostApplication<%=requestType%>, CombineCostApplicationCash<%=requestType%>);	
	
	/////////////////////////// 법인카드 ///////////////////////////
	
	var CombineCostApplicationCard<%=requestType%> = {

			cardPageExpenceAppList : [],
			
			
			combiCostAppCC_CorpCardPageInit : function() {
				var me = this;
				accountCtrl.getInfo("combiCostAppCC_TableArea").html("");
				me.cardPageExpenceAppList = [];
			},
			
			combiCostAppCC_CorpCardDataInit : function() {
				var me = this;
				accountCtrl.getInfo("combiCostAppCC_TableArea").html("");
				me.cardPageExpenceAppList = [];
			},

			combiCostAppCC_CardInfoLoadPopup : function() {
				var me = this;
				me.combiCostAppCC_callCardInfoPopup();
			},

			combiCostAppCC_callCardInfoPopup : function() {
				var me = this;
				var info = {
						popupUrl		: "/account/accountCommon/accountCommonPopup.do",
						popupID 		: "cardReceiptSearchPopup",
						popupTit 		: "<spring:message code='Cache.ACC_btn_corpCardLoad'/>", //법인카드불러오기
						popupName 		: "CardReceiptSearchPopup",
						callBackFunc 	: "combiCostAppCC_getCardRecInfo",
						includeAccount 	: "N",
						paramsetFunc	: "combiCostApp_CallAddLoadPopupParam",
						Sub_UR_Code		: accountCtrl.getInfo('comCostApp_Sub_UR_Code').val(),
						CompanyCode		: me.CompanyCode,
						RequestType		: requestType
				}
				var url = me.makeObjPopupUrl(info);
				Common.open(	"",info.popupID,info.popupTit,url,"1300px","700px","iframe",true,null,null,true);
				
			},
			combiCostAppCC_getCardRecInfo : function(inputList) {
				var me = this;
				var property = accountCtrl.getInfoStr("[name=ExpAppPropertyField][tag=CardReceipt]").val();
				//Property값이 뭔가 있을경우 인터페이스, 공백일경우 자체 DB
				//자체DB일경우 추가적인 값 조회가 필요
				if(isEmptyStr(property)){

					var idList = ""
					for(var i = 0; i<inputList.length; i++){
						var item = inputList[i]
						if(idList==""){
							idList = item.ReceiptID
						}else{
							idList = idList+","+item.ReceiptID
						}
					}
					$.ajax({
						type:"POST",
							url:"/account/expenceApplication/getCardReceipt.do",
						data:{
							receiptID : idList
						},
						success:function (data) {
							
							if(data.result == "ok"){
								var getCardRecList = data.list;
								
								var duplCk = false;
								var duplList = "";
								for(var i = 0; i<getCardRecList.length; i++){
									var item = getCardRecList[i];
									/* var idx = me.cardPageExpenceAppList.findIndex(
												function(item){
													return item.ReceiptID==item.ReceiptID;
												}
											) */
									var idx = accFindIdx(me.cardPageExpenceAppList, "ReceiptID", item.ReceiptID );
									if(idx>=0){
										duplCk = true;
										duplList = duplList+", "+item.CardApproveNo;
									}
								}
								
								if(duplCk){
								var msg = "<spring:message code='Cache.ACC_017' />";		//@@{appNoList}는 이미 비용신청 된 항목입니다.
									msg = msg.replace("@@{appNoList}", duplList);
									//Common.Error(msg);
									//return;
								}
								
								me.combiCostAppCC_inputListDataAdd(getCardRecList, true);
							}
							else{
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
							}
						},
						error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
						}
					});
				}else{
					//alert("INTERFACE TEST MSG");
					me.combiCostAppCC_inputListDataAdd(inputList, true, property);
				}
			},

			combiCostAppCC_inputListDataAdd : function(itemList, isNew, property) {
				var me = this;
				me.combiCostApp_setModified(true);
				var arrCk = Array.isArray(itemList);
				if(arrCk){
					var addedCk1 = false;
					var appNoList = "";
					if(isNew){
						
						for(var i = 0; i<itemList.length; i++){
		
							var newItem = itemList[i]
							var oldItem = null;
							for(var y = 0; y<me.cardPageExpenceAppList.length; y++){
								oldItem = me.cardPageExpenceAppList[y];
								if(oldItem.CardUID == newItem.CardUID){
									addedCk1 = true;
									if(appNoList==""){
										appNoList = newItem.CardApproveNo
									}else{
										appNoList = appNoList+","+newItem.CardApproveNo
									}
									break;
								}
							}
							
							if(addedCk1){
								break;
							}
						}
						
						if(addedCk1){
							var msg = "<spring:message code='Cache.ACC_016' />";		//@@{appNoList}는 이미 추가된 항목입니다.
							msg = msg.replace("@@{appNoList}", appNoList);
							Common.Error(msg);
							return;
						}
					}
					
					for(var i = 0; i<itemList.length; i++){
						var item = itemList[i];
						if(isNew){
							var today = new Date();
							if(!isEmptyStr(property)){
								var copyObj = objCopy(item);
								item.oriIFData = copyObj;
								item.ProofCode = "CorpCard";
								item.CardUID = item.ReceiptID;
								item.CardApproveNo = item.ApproveNo;
								item.TotalAmount = item.AmountWon;
								item.ProofDate = today.format("yyyyMMdd");
								item.ProofDateStr = today.format("yyyy.MM.dd");
								item.ProofTime = todat.format("HHmmss");
								item.ProofTimeStr = todat.format("HH:mm:ss");
								item.CardApproveNo = item.ApproveNo;
								item.StoreAddress = item.StoreAddress1 + item.StoreAddress2;
								item.AccountInfo = item.AccountInfo;
								item.AccountHolder = item.AccountHolder;
								item.AccountBank = item.AccountBank;
							}
							if(item.PostingDate == null || item.PostingDate == ""){
								//item.PostingDate = today.format("yyyyMMdd");
								//item.PostingDateStr = today.format("yyyy.MM.dd");
								
								//phm
								item.PostingDate = item.ProofDate;
								item.PostingDateStr = item.ProofDateStr;
							}
							item.IsNew = true;
							item.IsNewStr = "Y";
						}
						var maxKey = me.combiCostApp_getPageListMaxKey('CorpCard');
						item.KeyNo = maxKey+1;
						item.ProofCode="CorpCard";

						var divCk = false;
						if(item.divList == null){
							divCk = true;
						}
						else if(item.divList.length==0){
							divCk = true;
						}
						if(divCk){
							item.divList = [];
							var divItem = {
									ExpenceApplicationListID : item.ExpenceApplicationListID
									, KeyNo : item.KeyNo
									, ProofCode : item.ProofCode
									
									, ExpenceApplicationDivID : ""
									, AccountCode : item.AccountCode
									, AccountName : item.AccountName
									, StandardBriefID : item.StandardBriefID
									, StandardBriefName : item.StandardBriefName
									, CostCenterCode :  nullToBlank(me.pageCombiAppComboData.DefaultCC.CostCenterCode)
									, CostCenterName :  nullToBlank(me.pageCombiAppComboData.DefaultCC.CostCenterName)
									, IOCode : ""
									, IOName : ""
									, Amount : item.TotalAmount // 카드내역 선택시 청구금액 Default 셋팅오류
									, UsageComment : item.UsageText
									, IsNew : true
									, Rownum : 0
							}
							item.divList.push(divItem);
						}
						me.cardPageExpenceAppList.push(item);
					}

					me.combiCostAppCC_setListHTML(false, itemList);
					
					/* if(accountCtrl.getInfo("corpCardArea").css("display") == "none"){
						accountCtrl.getInfo("corpCardArea").show();
					} */
				}
			},

			//법인카드 사용내역 HTML 만들기
			combiCostAppCC_setListHTML : function(isAll, inputList) {
				var me = this;
				
				if(isAll){
					accountCtrl.getInfoName("combiCostAppCC_TableArea").html("");
				}
				var list = [];
				
				if(inputList == null){
					list = me.cardPageExpenceAppList;
				}else{
					list = inputList;
				}
				
				for(var i = 0; i<list.length; i++){
					var item = list[i];
					var valMap = {
							RequestType : requestType,
							ExpenceApplicationListID : nullToBlank(item.ExpenceApplicationListID),
							KeyNo : nullToBlank(item.KeyNo),
							ProofCode : nullToBlank(item.ProofCode),
							TotalAmount : toAmtFormat(nullToBlank(item.TotalAmount)),
							ProofDate : nullToBlank(item.ProofDateStr),
							ProofTime : nullToBlank(item.ProofTimeStr),
							StoreName : nullToBlank(item.StoreName).trim(),
							CardUID : nullToBlank(item.CardUID),
							CardApproveNo : nullToBlank(item.CardApproveNo),
							ReceiptID : nullToBlank(item.ReceiptID),
							AccountInfo : nullToBlank(item.AccountInfo),
							AccountHolder : nullToBlank(item.AccountHolder),
							AccountBank : nullToBlank(item.AccountBank),
							RepAmount : toAmtFormat(nullToBlank(item.RepAmount) == "" ? item.TotalAmount : item.RepAmount),
							TaxAmount : toAmtFormat(nullToBlank(item.TaxAmount) == "" ? 0 : item.TaxAmount),
							ServiceAmount : toAmtFormat(nullToBlank(item.ServiceAmount)),
					}
					var htmlStr = me.combiCostApp_makeInputHtmlForm(item, valMap);
					accountCtrl.getInfoName("combiCostAppCC_TableArea").append(htmlStr);
					
					me.combiCostApp_makeInputDivHtmlAdd(item);
					
					var selectFieldList = accountCtrl.getInfoStr("[name=ComboSelect][proofcode="+item.ProofCode+"][keyno="+item.KeyNo+"]");
					for(var y = 0; y<selectFieldList.length; y++){
						var field = selectFieldList[y];

						var dataField = field.getAttribute("field");
						field.value=nullToBlank(item[dataField]);
						
						if(field.onchange!=null){
							field.onchange();
						}
					}

					var docList = item.docList;
					if(docList != null){
						var setDocList = [].concat(docList);
						me.combiCostApp_DocHTML(setDocList, item.KeyNo, 'CorpCard', false);
					}

					var fileList = item.fileList;
					var uploadFileList = item.uploadFileList;
					var setFileList = []
					if(fileList != null){
						setFileList = setFileList.concat(fileList);
					}
					if(uploadFileList != null){
						setFileList = setFileList.concat(uploadFileList);
					}
					item.fileMaxNo = 0;
					if(setFileList != null){
						
						for(var y = 0; y<setFileList.length; y++){
							var fileItem = setFileList[y];
							item.fileMaxNo++;
							fileItem.fileNum = item.fileMaxNo;
						}
						me.combiCostApp_UploadHTML(setFileList, item.KeyNo, 'CorpCard', false);
					}
				}
				me.combiCostApp_makeDateField("CorpCard", list);
			},
	}
	
	window.CombineCostApplication<%=requestType%> = $.extend(window.CombineCostApplication<%=requestType%>, CombineCostApplicationCard<%=requestType%>);
	
/////////////////////////// 기타증빙 ///////////////////////////
	
	var CombineCostApplicationEtc<%=requestType%> = {		
			
			etcEvidPageExpenceAppList : [],

			combiCostAppEE_EtcEvidPageInit : function() {
				var me = this;
				accountCtrl.getInfoName("combiCostAppEE_TableArea").html("");
				me.etcEvidPageExpenceAppList = [];
			},
			combiCostAppEE_EtcEvidDataInit : function() {
				var me = this;
				accountCtrl.getInfoName("combiCostAppEE_TableArea").html("");
				me.etcEvidPageExpenceAppList = [];
			},


			combiCostAppEE_itemAdd : function() {
				var me = this;
				
				if(me.etcEvidPageExpenceAppList.length != 0){
					Common.Confirm("<spring:message code='Cache.ACC_018' />", "Confirmation Dialog", function(result){
						if(result){
							me.combiCostAppEE_EtcEvidDataInit()
							me.combiCostAppEE_inputListDataAdd(null, true);
						}
					});
				}else{
					me.combiCostAppEE_EtcEvidDataInit()
					me.combiCostAppEE_inputListDataAdd(null, true);
				}
			
			},

			combiCostAppEE_inputListDataAdd : function(inputItem, isNew) {
				var me = this;
				me.combiCostApp_setModified(true);
				var item = {};
				
				if(isNew){
					var pd = item.ProofDate;

					item.IsNew = true;
					item.IsNewStr = "Y";
					me.isModified = false;
				}else{
					item = inputItem;
					me.isModified = true;
				}

				var maxKey = me.combiCostApp_getPageListMaxKey('EtcEvid');
				item.KeyNo = maxKey+1;
				item.ProofCode = "EtcEvid";
				/* var today = new Date();
				if(item.ProofDate == null){
					item.ProofDate = today.format("yyyyMMdd");
					item.ProofDateStr = today.format("yyyy.MM.dd");
				}
				if(item.PostingDate == null){
					item.PostingDate = today.format("yyyyMMdd");
					item.PostingDateStr = today.format("yyyy.MM.dd");
				} */
				if(item.ProofDate == null) { item.ProofDate = ""; item.ProofDateStr = ""; }
				if(item.PostingDate == null) { item.PostingDate = ""; item.PostingDateStr = ""; }
				
				if(requestType == "VENDOR") {
					// 거래처비용정산 & 기타증빙 > 세금유형 default 값 세팅
					item.TaxType = "induct";
				}
				
				var divCk = false;
				if(item.divList == null){
					divCk = true;
				}
				else if(item.divList.length==0){
					divCk = true;
				}
				if(divCk){
					item.divList = [];
					var divItem = {
							ExpenceApplicationDivID : ""
							, ExpenceApplicationListID : "" 
							, AccountCode :  ""
							, AccountName : ""
							, StandardBriefID :  ""
							, StandardBriefName : ""
							, CostCenterCode :  nullToBlank(me.pageCombiAppComboData.DefaultCC.CostCenterCode)
							, CostCenterName :  nullToBlank(me.pageCombiAppComboData.DefaultCC.CostCenterName)
							, IOCode : ""
							, IOName : ""
							, Amount : item.TotalAmount
							, UsageComment : ""
							, IsNew : true
							, Rownum : 0
					}
					item.divList.push(divItem);
				}
				me.etcEvidPageExpenceAppList.push(item);

				me.combiCostAppEE_setListHTML();
			},

			combiCostAppEE_setListHTML : function(isAll) {
				var me = this;
				
				if(isAll){
					accountCtrl.getInfoName("combiCostAppEE_TableArea").html("");
				}
				
				for(var i = 0; i<me.etcEvidPageExpenceAppList.length; i++){
					var item = me.etcEvidPageExpenceAppList[i];
					
					if(nullToBlank(item.IncomeTax) != "") {
						item.IncomTax = item.IncomeTax;
					}
					
					item.AccountBankName = accComm.getBaseCodeName("Bank", nullToBlank(item.AccountBank), me.CompanyCode);
					
					if(item.AccountBankName == "") {
						item.AccountBankName = item.AccountBank;
					} 
					
					var valMap = {
							RequestType : requestType,
							ExpenceApplicationListID : nullToBlank(item.ExpenceApplicationListID),
							KeyNo : nullToBlank(item.KeyNo),
							ProofCode : nullToBlank(item.ProofCode),
							ProofDate : nullToBlank(item.ProofDate),
							ProofDateStr : nullToBlank(item.ProofDateStr),
							
							TotalAmount : toAmtFormat(nullToBlank(item.TotalAmount)),
							RepAmount : toAmtFormat(nullToBlank(item.RepAmount) == "" ? item.TotalAmount : item.RepAmount),
							TaxAmount : toAmtFormat(nullToBlank(item.TaxAmount) == "" ? 0 : item.TaxAmount),
							
							TaxType : nullToBlank(item.TaxType),
							TaxCode : nullToBlank(item.TaxCode),
							PayMethod : nullToBlank(item.PayMethod),
							PayType : nullToBlank(item.PayType),
							PayTarget : nullToBlank(item.PayTarget),
							AlterPayeeNo : nullToBlank(item.AlterPayeeNo),
							AlterPayeeName : nullToBlank(item.AlterPayeeName),
							VendorName : nullToBlank(item.VendorName),
							VendorNo : nullToBlank(item.VendorNo),
							VendorID : nullToBlank(item.VendorID),
							BusinessNumber : nullToBlank(item.BusinessNumber),
							AccountInfo : nullToBlank(item.AccountInfo),
							AccountHolder : nullToBlank(item.AccountHolder),
							AccountBank : nullToBlank(item.AccountBank),
							AccountBankName : nullToBlank(item.AccountBankName),
							
							IsWithholdingTax : nullToBlank(item.IsWithholdingTax),
							IncomTax: nullToBlank(item.IncomTax),
							LocalTax: nullToBlank(item.LocalTax),
							EmpInsurance: toAmtFormat(nullToBlank(item.EmpInsurance) == "" ? 0 : item.EmpInsurance),
							AccidInsurance: toAmtFormat(nullToBlank(item.AccidInsurance) == "" ? 0 : item.AccidInsurance),
							WorkingDay: toAmtFormat(nullToBlank(item.WorkingDay) == "" ? 0 : item.WorkingDay),
							ActualDay: toAmtFormat(nullToBlank(item.ActualDay) == "" ? 0 : item.ActualDay),
							
							Currency : nullToBlank(item.Currency),
							ExchangeRate : nullToBlank(item.ExchangeRate) == "" ? 0 : parseInt(item.ExchangeRate),
							LocalAmount : nullToBlank(item.LocalAmount) == "" ? 0 : parseInt(item.LocalAmount)
					}
					
					var htmlStr = me.combiCostApp_makeInputHtmlForm(item, valMap);
					accountCtrl.getInfoName("combiCostAppEE_TableArea").append(htmlStr);					
					
					if(valMap.VendorID != "") {
						var tempObj = {};
						tempObj.KeyNo = valMap.KeyNo;
						tempObj.ProofCode = "EtcEvid";
						tempObj.VendorID = valMap.VendorID;
						tempObj.PayMethod = valMap.PayMethod;
						tempObj.PayType = valMap.PayType;
						tempObj.AccountInfo = valMap.AccountInfo;
						tempObj.AccountHolder = valMap.AccountHolder;
						tempObj.AccountBank = valMap.AccountBank;
						tempObj.AccountBankName = valMap.AccountBankName;
						me.combiCostApp_getVendorInfo(tempObj); 
					}
					
					if(valMap.IsWithholdingTax != "" && valMap.IsWithholdingTax == "Y") {
						accountCtrl.getInfo("combiCostApp"+valMap.ProofCode+"_inputEvidTypeY_"+valMap.KeyNo).trigger("click");
					}

					var selectFieldList = accountCtrl.getInfoStr("[name=ComboSelect][proofcode="+item.ProofCode+"][keyno="+item.KeyNo+"]");
					for(var y = 0; y<selectFieldList.length; y++){
						var field = selectFieldList[y];

						var dataField = field.getAttribute("field");
						field.value=nullToBlank(item[dataField]);
						
						if(field.onchange!=null){
							field.onchange();
						}
					}
					
					me.combiCostApp_makeInputDivHtmlAdd(item);

					var docList = item.docList;
					if(docList != null){
						var setDocList = [].concat(docList);
						me.combiCostApp_DocHTML(setDocList, item.KeyNo, 'EtcEvid', false);
					}
					
					var fileList = item.fileList;
					var uploadFileList = item.uploadFileList;
					var setFileList = []
					if(fileList != null){
						setFileList = setFileList.concat(fileList);
					}
					if(uploadFileList != null){
						setFileList = setFileList.concat(uploadFileList);
					}
					item.fileMaxNo = 0;
					if(setFileList != null){
						
						for(var y = 0; y<setFileList.length; y++){
							var fileItem = setFileList[y];
							item.fileMaxNo++;
							fileItem.fileNum = item.fileMaxNo;
						}
						me.combiCostApp_UploadHTML(setFileList, item.KeyNo, 'EtcEvid', false);
					}
					me.combiCostAppEE_etcEvidTypeChange(null, item.KeyNo, null);
				}
				me.combiCostApp_makeDateField("EtcEvid", me.etcEvidPageExpenceAppList);
				
				//useWriteVendor == Y
				if(Common.getBaseConfig("useWriteVendor", sessionObj["DN_ID"]) == "Y") {
					accountCtrl.getInfoStr("input[field=VendorNo]").removeAttr("disabled").attr("placeholder", "사업자등록번호").attr("onblur", "CombineCostApplication<%=requestType%>.combiCostApp_InputVendorChange(this, 'EtcEvid', '" + item.KeyNo + "', 'VendorNo')");
					accountCtrl.getInfoStr("input[field=VendorName]").removeAttr("disabled").attr("placeholder", "거래처명").attr("onblur", "CombineCostApplication<%=requestType%>.combiCostApp_InputVendorChange(this, 'EtcEvid', '" + item.KeyNo + "', 'VendorName')");
				}
				
				// 환종 환율 추가
				if(me.exchangeIsUse == "Y") {
					//입력 필드 show
					accountCtrl.getInfoStr("span[name=EtcEvidField][proofcode="+valMap.ProofCode+"][keyno="+valMap.KeyNo+"]").show();
					
					//환종 KRW 기본값 세팅
					var CUField = accountCtrl.getInfoStr("[name=CurrencySelectField][proofcode="+valMap.ProofCode+"][keyno="+valMap.KeyNo+"]");
					if (valMap.Currency == "") valMap.Currency = "KRW";
					CUField.val(valMap.Currency);
					me.combiCostApp_setListVal(valMap.ProofCode, valMap.KeyNo, "Currency", valMap.Currency);
					
					if(CUField[0]!=null){
						CUField[0].onchange();
					}
				} else {
					accountCtrl.getInfoStr("span[name=EtcEvidField][proofcode="+valMap.ProofCode+"][keyno="+valMap.KeyNo+"]").hide();
				}
				
			},
			combiCostAppEE_etcEvidTypeChange : function(obj, KeyNo, inputVal) {
				var me = this;
				var val = "";
				if(obj == null){
					if(inputVal != null) {
						val = inputVal;			
					} else {
						val = accountCtrl.getInfoStr("[name=etcEvidRadio][keyno="+KeyNo+"]:checked").val();
					}
				} else {
					val = $(obj).val();
				}

				var item = me.combiCostApp_findListItem(me.etcEvidPageExpenceAppList, "KeyNo", KeyNo);
				item.IsWithholdingTax = val;
				
				if(val=="N") {
					accountCtrl.getInfoStr("[tag=TaxArea][keyno="+KeyNo+"]").css("display", "none")
					accountCtrl.getInfoStr("[tag=TaxVal]").val("");
					accountCtrl.getInfoStr("[tag=InsureArea][keyno="+KeyNo+"]").css("display", "none");
					accountCtrl.getInfoStr("[tag=InsureArea][keyno="+KeyNo+"]").find("[tag=Amount]").val("");
					item.IncomTax = "";
					item.IncomTaxAmt = 0;
					item.IncomeTax = "";
					item.LocalTax = "";
					item.LocalTaxAmt = 0;
					item.EmpInsurance = 0;
					item.AccidInsurance = 0;
					item.WorkingDay = 0;
					item.ActualDay = 0;
					
					// 버튼 추가 컨트롤 추가
					$("[name=IncomeTax]").hide();
                    $("[name=NormalTax]").show();
                    
				} else if(val=="Y") {
					accountCtrl.getInfoStr("[tag=TaxArea][keyno="+KeyNo+"]").css("display", "");
			 
					// 버튼 추가 컨트롤 추가
					$("[name=IncomeTax]").show();
                    $("[name=NormalTax]").hide();

					if(requestType == "OUTSOURCING") {
						// 외주용역비용정산 & 기타증빙_원천세 > 지급방법/지급대상 default 값 세팅
						accountCtrl.getInfoStr("[name=ComboSelect][field=PayMethod][proofcode=EtcEvid][keyno="+KeyNo+"]").val("C").trigger("change");
						accountCtrl.getInfoStr("[name=ComboSelect][field=PayTarget][proofcode=EtcEvid][keyno="+KeyNo+"]").val("Vendor").trigger("change");
						accountCtrl.getInfoStr("[name=ComboSelect][field=TaxType][proofcode=EtcEvid][keyno="+KeyNo+"]").attr("disabled", "disabled");
						accountCtrl.getInfoStr("[name=ComboSelect][field=TaxCode][proofcode=EtcEvid][keyno="+KeyNo+"]").attr("disabled", "disabled");
						// 외주용역비만 고용보험,산재보험 추가
						accountCtrl.getInfoStr("[tag=InsureArea][keyno="+KeyNo+"]").css("display", "");
						var objTotalAmount = accountCtrl.getInfoStr("[name=CombiCostInputField][proofcode=EtcEvid][keyno="+KeyNo+"][field=TotalAmount]");
						var totalAmount = objTotalAmount.val().replace(/,/gi, "");
						if(obj != null && totalAmount) objTotalAmount.trigger("keyup");
					}else{
						accountCtrl.getInfoStr("[tag=InsureArea][keyno="+KeyNo+"]").css("display", "none");
						accountCtrl.getInfoStr("[tag=InsureArea][keyno="+KeyNo+"]").find("[tag=Amount]").val("");
						item.EmpInsurance = 0;
						item.AccidInsurance = 0;
						item.WorkingDay = 0;
						item.ActualDay = 0;
					}
				}
			}

	}
	window.CombineCostApplication<%=requestType%> = $.extend(window.CombineCostApplication<%=requestType%>, CombineCostApplicationEtc<%=requestType%>);
	
	/////////////////////////// 모바일 영수증 ///////////////////////////
	
	var CombineCostApplicationReceipt<%=requestType%> = {

			receiptPageExpenceAppList : [],
			
			
			combiCostAppMR_ReceiptPageInit : function() {
				var me = this;
				accountCtrl.getInfo("combiCostAppMR_TableArea").html("");
				me.receiptPageExpenceAppList = [];
			},
			
			combiCostAppMR_ReceiptDataInit : function() {
				var me = this;
				accountCtrl.getInfo("combiCostAppMR_TableArea").html("");
				me.receiptPageExpenceAppList = [];
			},
			
			combiCostAppMR_ReceiptInfoLoadPopup : function() {
				var me = this;
				me.combiCostAppMR_callReceiptInfoPopup();
			},

			combiCostAppMR_callReceiptInfoPopup : function() {
				var me = this;
				var info = {
						popupUrl		: "/account/accountCommon/accountCommonPopup.do",
						popupID 		: "receiptSearchPopup",
						popupTit 		: "<spring:message code='Cache.ACC_btn_mobileReceiptLoad'/>",
						popupName 		: "ReceiptSearchPopup",
						callBackFunc 	: "combiCostAppMR_getReceiptRecInfo",
						includeAccount 	: "N",
						paramsetFunc	: "combiCostApp_CallAddLoadPopupParam"
						//, ExpAppID 	: ExpAppId
						//, idStr 		: idStr
				}
				var url = me.makeObjPopupUrl(info);
				Common.open(	"",info.popupID,info.popupTit,url,"600px","620px","iframe",true,null,null,true);
			},
			combiCostAppMR_getReceiptRecInfo : function(inputList) {
				var me = this;

				for(var i = 0; i<inputList.length; i++){
					var item = inputList[i];

					item.ExpenceApplicationListID = nullToBlank(item.ExpenceApplicationListID);
					item.RequestType = requestType;
					item.KeyNo = nullToBlank(item.ReceiptID);
					item.ProofCode = nullToBlank(item.ProofCode);
					
					item.ReceiptID = nullToBlank(item.ReceiptID);
					item.FileID = nullToBlank(item.FileID);
					
					item.StoreName = nullToBlank(item.StoreName).trim();
					item.TotalAmount = toAmtFormat(nullToBlank(item.TotalAmount));

					item.ProofDate = nullToBlank(item.PhotoDate);
					item.ProofDateStr = nullToBlank(item.PhotoDateStr);
					item.PostingDate = nullToBlank(item.PhotoDate);
					item.PostingDateStr = nullToBlank(item.PhotoDateStr);
					
					//사용자가 모바일에서 입력한 정보 		
					item.UseDate = nullToBlank(item.UseDate); //모바일영수증은 직접입력, 법인카드는 I/F 데이터
					item.AccountCode = nullToBlank(item.AccountCode);
					item.AccountName = nullToBlank(item.AccountName);
					item.StandardBriefID = nullToBlank(item.StandardBriefID);
					item.StandardBriefName = nullToBlank(item.StandardBriefName);
					item.CostCenterCode = nullToBlank(item.CostCenterCode);
					item.CostCenterName = nullToBlank(item.CostCenterName);
					item.UsageText = nullToBlank(item.UsageText);
					item.Amount = nullToBlank(item.Amount);
				}
				me.combiCostAppMR_inputListDataAdd(inputList, true);
			},

			combiCostAppMR_inputListDataAdd : function(itemList, isNew) {
				var me = this;
				me.combiCostApp_setModified(true);
				var arrCk = Array.isArray(itemList);
				if(arrCk){
					var addedCk1 = false;
					var addedCk2 = false;
					var confirmNoList = "";

					for(var i = 0; i<itemList.length; i++){
						var item = itemList[i];

						if(isNew){
							var pd = item.ProofDate;

							item.IsNew = true;
							item.IsNewStr = "Y";
						}
						var maxKey = me.combiCostApp_getPageListMaxKey('Receipt');
						item.KeyNo = maxKey+1;
						item.ProofCode = "Receipt";
						
						if(item.ProofDate == null) { item.ProofDate = ""; item.ProofDateStr = ""; }
						if(item.PostingDate == null) { item.PostingDate = ""; item.PostingDateStr = ""; }
						
						var divCk = false;
						if(item.divList == null){
							divCk = true;
						}
						else if(item.divList.length==0){
							divCk = true;
						}
						if(divCk){
							item.divList = [];
							var divItem = {
									ExpenceApplicationListID : item.ExpenceApplicationListID
									, KeyNo : item.KeyNo
									, ProofCode : item.ProofCode
									
									, ExpenceApplicationDivID : ""
									, AccountCode : item.AccountCode
									, AccountName : item.AccountName
									, StandardBriefID : item.StandardBriefID
									, StandardBriefName : item.StandardBriefName
									, CostCenterCode :  nullToBlank(me.pageCombiAppComboData.DefaultCC.CostCenterCode)
									, CostCenterName :  nullToBlank(me.pageCombiAppComboData.DefaultCC.CostCenterName)
									, IOCode : ""
									, IOName : ""
									, Amount : item.Amount
									, TotalAmount : item.TotalAmount
									, UsageComment : item.UsageText
									, IsNew : true
									, Rownum : 0
							}
							item.divList.push(divItem);
						}
						me.receiptPageExpenceAppList.push(item);
					}

					me.combiCostAppMR_setListHTML(false, itemList);
				}
			},

			//모바일영수증 사용내역 HTML 만들기
			combiCostAppMR_setListHTML : function(isAll, inputList) {
				var me = this;
				
				if(isAll){
					accountCtrl.getInfoName("combiCostAppMR_TableArea").html("");
				}
				var list = [];
				
				if(inputList == null){
					list = me.receiptPageExpenceAppList;
				}else{
					list = inputList;
				}
				
				for(var i = 0; i<list.length; i++){
					var item = list[i];
					var valMap = {
							RequestType : requestType,
							ExpenceApplicationListID : nullToBlank(item.ExpenceApplicationListID),
							KeyNo : nullToBlank(item.KeyNo),
							ProofCode : nullToBlank(item.ProofCode),
							TotalAmount : toAmtFormat(nullToBlank(item.TotalAmount)),
							ProofDate : nullToBlank(item.ProofDate),
							ProofDateStr : nullToBlank(item.ProofDateStr),
							StoreName : nullToBlank(item.StoreName).trim(),
							TaxType : nullToBlank(item.TaxType),
							TaxCode : nullToBlank(item.TaxCode),
							PayMethod : nullToBlank(item.PayMethod),
							VendorName : nullToBlank(item.VendorName),
							VendorNo : nullToBlank(item.VendorNo),
							PersonalCardNo : nullToBlank(item.PersonalCardNo),
							PersonalCardNoView : nullToBlank(item.PersonalCardNoView),
							FileID : nullToBlank(item.FileID),
							FileName : nullToBlank(item.FileName),
					}
					var htmlStr = me.combiCostApp_makeInputHtmlForm(item, valMap);
					accountCtrl.getInfoName("combiCostAppMR_TableArea").append(htmlStr);
					
					me.combiCostApp_makeInputDivHtmlAdd(item);

					var selectFieldList = accountCtrl.getInfoStr("[name=ComboSelect][proofcode="+item.ProofCode+"][keyno="+item.KeyNo+"]");
					for(var y = 0; y<selectFieldList.length; y++){
						var field = selectFieldList[y];

						var dataField = field.getAttribute("field");
						field.value=nullToBlank(item[dataField]);
						
						if(field.onchange!=null){
							field.onchange();
						}
					}

					var docList = item.docList;
					if(docList != null){
						var setDocList = [].concat(docList);
						me.combiCostApp_DocHTML(setDocList, item.KeyNo, 'Receipt', false);
					}
					
					var fileList = item.fileList;
					var uploadFileList = item.uploadFileList;
					var setFileList = []
					if(fileList != null){
						setFileList = setFileList.concat(fileList);
					}
					if(uploadFileList != null){
						setFileList = setFileList.concat(uploadFileList);
					}
					item.fileMaxNo = 0;
					if(setFileList != null){
						
						for(var y = 0; y<setFileList.length; y++){
							var fileItem = setFileList[y];
							item.fileMaxNo++;
							fileItem.fileNum = item.fileMaxNo;
						}
						me.combiCostApp_UploadHTML(setFileList, item.KeyNo, 'Receipt', false);
					}
				}
				me.combiCostApp_makeDateField("Receipt", list);
			},

		}
	window.CombineCostApplication<%=requestType%> = $.extend(window.CombineCostApplication<%=requestType%>, CombineCostApplicationReceipt<%=requestType%>);
	
	/////////////////////////// 개인카드 ///////////////////////////
	
	var CombineCostApplicationPriv<%=requestType%> = {		
			
			privateCardPageExpenceAppList : [],

			combiCostAppPC_PrivateCardPageInit : function() {
				var me = this;
				accountCtrl.getInfoName("combiCostAppPC_TableArea").html("");
				me.privateCardPageExpenceAppList = [];
			},
			combiCostAppPC_PrivateCardDataInit : function() {
				var me = this;
				accountCtrl.getInfoName("combiCostAppPC_TableArea").html("");
				me.privateCardPageExpenceAppList = [];
			},


			combiCostAppPC_itemAdd : function() {
				var me = this;
				
				if(me.privateCardPageExpenceAppList.length != 0){
					Common.Confirm("<spring:message code='Cache.ACC_018' />", "Confirmation Dialog", function(result){	//이 유형의 증빙은 한번에 하나의 증빙만 추가할 수 있습니다. 입력창을 초기화 하시겠습니까?
						if(result){
							me.combiCostAppPC_PrivateCardDataInit();
							me.combiCostAppPC_inputListDataAdd(null, true);
						}
					});
				}else{
					me.combiCostAppPC_PrivateCardDataInit();
					me.combiCostAppPC_inputListDataAdd(null, true);
				}
			},

			combiCostAppPC_inputListDataAdd : function(inputItem, isNew) {
				var me = this;
				me.combiCostApp_setModified(true);
				var item = {};
				
				if(isNew){
					var pd = item.ProofDate;

					item.IsNew = true;
					item.IsNewStr = "Y";
				}else{
					item = inputItem;
				}

				var maxKey = me.combiCostApp_getPageListMaxKey('PrivateCard');
				item.KeyNo = maxKey+1;
				item.ProofCode = "PrivateCard";
				/* var today = new Date();
				if(item.ProofDate == null){
					item.ProofDate = today.format("yyyyMMdd");
					item.ProofDateStr = today.format("yyyy.MM.dd");
				}
				if(item.PostingDate == null){
					item.PostingDate = today.format("yyyyMMdd");
					item.PostingDateStr = today.format("yyyy.MM.dd");
				} */
				if(item.ProofDate == null) { item.ProofDate = ""; item.ProofDateStr = ""; }
				if(item.PostingDate == null) { item.PostingDate = ""; item.PostingDateStr = ""; }
				
				var divCk = false;
				if(item.divList == null){
					divCk = true;
				}
				else if(item.divList.length==0){
					divCk = true;
				}
				if(divCk){
					item.divList = [];
					var divItem = {
							ExpenceApplicationDivID : ""
							, ExpenceApplicationListID : "" 
							, AccountCode :  ""
							, AccountName : ""
							, StandardBriefID :  ""
							, StandardBriefName : ""
							, CostCenterCode :  nullToBlank(me.pageCombiAppComboData.DefaultCC.CostCenterCode)
							, CostCenterName :  nullToBlank(me.pageCombiAppComboData.DefaultCC.CostCenterName)
							, IOCode : ""
							, IOName : ""
							, Amount : item.TotalAmount
							, UsageComment : ""
							, IsNew : true
							, Rownum : 0
					}
					item.divList.push(divItem);
				}
				me.privateCardPageExpenceAppList.push(item);

				me.combiCostAppPC_setListHTML();
			},

			combiCostAppPC_setListHTML : function(isAll) {
				var me = this;
				
				if(isAll){
					accountCtrl.getInfoName("combiCostAppPC_TableArea").html("");
				}

				for(var i = 0; i<me.privateCardPageExpenceAppList.length; i++){
					var item = me.privateCardPageExpenceAppList[i];
					
					var valMap = {
							RequestType : requestType,
							ExpenceApplicationListID : nullToBlank(item.ExpenceApplicationListID),
							KeyNo : nullToBlank(item.KeyNo),
							ProofCode : nullToBlank(item.ProofCode),
							TotalAmount : toAmtFormat(nullToBlank(item.TotalAmount)),
							ProofDate : nullToBlank(item.ProofDate),
							ProofDateStr : nullToBlank(item.ProofDateStr),
							StoreName : nullToBlank(item.StoreName).trim(),
							TaxType : nullToBlank(item.TaxType),
							TaxCode : nullToBlank(item.TaxCode),
							PayMethod : nullToBlank(item.PayMethod),
							VendorName : nullToBlank(item.VendorName),
							VendorNo : nullToBlank(item.VendorNo),
							PersonalCardNo : nullToBlank(item.PersonalCardNo),
							PersonalCardNoView : nullToBlank(item.PersonalCardNoView),
							FranchiseCorpName : nullToBlank(item.FranchiseCorpName),
							Tax : nullToBlank(item.Tax),
							SupplyCost : nullToBlank(item.SupplyCost),
					}
					var htmlStr = me.combiCostApp_makeInputHtmlForm(item, valMap);
					accountCtrl.getInfoName("combiCostAppPC_TableArea").append(htmlStr);
					
					me.combiCostApp_makeInputDivHtmlAdd(item);

					var selectFieldList = accountCtrl.getInfoStr("[name=ComboSelect][proofcode="+item.ProofCode+"][keyno="+item.KeyNo+"]");
					for(var y = 0; y<selectFieldList.length; y++){
						var field = selectFieldList[y];

						var dataField = field.getAttribute("field");
						field.value=nullToBlank(item[dataField]);
						
						if(field.onchange!=null){
							field.onchange();
						}
					}

					var docList = item.docList;
					if(docList != null){
						var setDocList = [].concat(docList);
						me.combiCostApp_DocHTML(setDocList, item.KeyNo, 'PrivateCard', false);
					}
					
					var fileList = item.fileList;
					var uploadFileList = item.uploadFileList;
					var setFileList = []
					if(fileList != null){
						setFileList = setFileList.concat(fileList);
					}
					if(uploadFileList != null){
						setFileList = setFileList.concat(uploadFileList);
					}
					item.fileMaxNo = 0;
					if(setFileList != null){
						
						for(var y = 0; y<setFileList.length; y++){
							var fileItem = setFileList[y];
							item.fileMaxNo++;
							fileItem.fileNum = item.fileMaxNo;
						}
						me.combiCostApp_UploadHTML(setFileList, item.KeyNo, 'PrivateCard', false);
					}
				}
				me.combiCostApp_makeDateField("PrivateCard", me.privateCardPageExpenceAppList);
			},

	}
	window.CombineCostApplication<%=requestType%> = $.extend(window.CombineCostApplication<%=requestType%>, CombineCostApplicationPriv<%=requestType%>);
	
	/////////////////////////// 전자세금계산서 ///////////////////////////
	
	var CombineCostApplicationTax<%=requestType%> = {		
			
			taxBillPageExpenceAppList : [],
			taxBillManager : "N",
			businessNumber : "",
			businessNumberCnt : 0,
			combiCostAppTB_TaxBillPageInit : function() {
				var me = this;
				accountCtrl.getInfo("combiCostAppTB_TableArea").html("");
				me.taxBillPageExpenceAppList = [];
				me.combiCostAppTB_callManager();
			},
			
			combiCostAppTB_TaxBillDataInit : function() {
				var me = this;
				accountCtrl.getInfo("combiCostAppTB_TableArea").html("");
				me.taxBillPageExpenceAppList = [];
			},

			combiCostAppTB_callManager : function() {
				var me = this;
				$.ajax({
					type:"POST",
					url:"/account/expenceApplication/getManagerList.do",
					data:{},
					success:function (data) {
						if(data.result == "ok"){
							me.taxBillManager = data.check;
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

			combiCostAppTB_TaxLoadXmlUpLoadPopup : function() {
				var me= this;

				if(me.taxBillManager != "Y"){
					Common.Inform("<spring:message code='Cache.ACC_026' />");	//담당자만 사용할 수 있습니다.
					return;
				}
				
				var info = {
						popupUrl		: "/account/expenceApplication/getTaxInvoiceXmlUploadPopup.do",
						popupID 		: "taxInvoiceXmlUploadPopup",
						popupTit 		: "TaxInvoice Xml UpLoad",
						popupYN			: "N",
						callBackFunc 	: "combiCostAppTBTaxLoadXmlUpLoadPopup_CallBack"
				}
				var popupUrl = me.makeObjPopupUrl(info);
				
				if(me.taxBillPageExpenceAppList.length != 0){
					Common.Confirm("<spring:message code='Cache.ACC_msg_modDataConfirm' />", "Confirmation Dialog", function(result){	//작성중인 항목이 있습니다. 불러오기를 하시면 수정중인 내용이 사라집니다. 계속하시겠습니까? 
						if(result){
							me.combiCostAppTB_TaxBillDataInit();
							Common.open("", info.popupID, info.popupTit, popupUrl, "500px", "250px", "iframe", true, null, null, true);
						}
					});
				} else {
					Common.open("", info.popupID, info.popupTit, popupUrl, "500px", "250px", "iframe", true, null, null, true);
				}
			},
			
			combiCostAppTBTaxLoadXmlUpLoadPopup_CallBack : function(data) {
				var me = this;
				var inputVal = data.info;
				
				inputVal.isXML = "Y";
				inputVal.NTSConfirmNum = inputVal.IssueID;
				inputVal.WriteDate = inputVal.IssueDTTaxInvoice;
				inputVal.FormatWriteDate = accComm.accFormatDate(inputVal.IssueDTTaxInvoice);
				inputVal.IssueDT = inputVal.IssueDTExchanged;
				inputVal.ItemList = data.list;
				
				$.ajax({
					type:"POST",
					url:"/account/expenceApplication/getVdCheck.do",
					data:{
						VendorNo : inputVal.InvoicerCorpNum
					},
					success:function (data) {
						if(data.result == "ok"){
							var vdInfo = data.vdInfo;
							if(vdInfo != null){
								inputVal.VendorNo = vdInfo.VendorNo;
								inputVal.VendorName = vdInfo.VendorName;
								inputVal.CEOName = vdInfo.CEOName;
								inputVal.Address = vdInfo.Address;
								inputVal.Industry = vdInfo.Industry;
								inputVal.Sector = vdInfo.Sector;
								inputVal.BankAccountInfo = vdInfo.BankAccountInfo;
								inputVal.BankAccountName = vdInfo.BankAccountName;
								inputVal.BankAccountNo = vdInfo.BankAccountNo;								
								inputVal.BankCode = vdInfo.BankCode;
								inputVal.BankName = vdInfo.BankName;
								inputVal.PayType = vdInfo.PayType;
								inputVal.PayMethod = vdInfo.PayMethod;
							}
							me.combiCostAppTB_inputListDataAdd([inputVal], true);
						}
						else{
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
					}
				});
			},
			
			combiCostAppTB_TaxLoadPopup : function() {
				var me= this;
				if(me.taxBillPageExpenceAppList.length != 0){
					Common.Confirm("<spring:message code='Cache.ACC_msg_modDataConfirm' />", "Confirmation Dialog", function(result){	//작성중인 항목이 있습니다. 불러오기를 하시면 수정중인 내용이 사라집니다. 계속하시겠습니까? 
						if(result){
							me.combiCostAppTB_callTaxBillInfoPopup();
						}
					});
				}
				else{
					me.combiCostAppTB_callTaxBillInfoPopup();
				}
			},

			combiCostAppTB_callTaxBillInfoPopup : function() {
				var me = this;

				if(me.taxBillManager != "Y"){
					Common.Inform("<spring:message code='Cache.ACC_026' />");	//담당자만 사용할 수 있습니다.
					return;
				}

				me.combiCostAppTB_TaxBillDataInit();
//				taxBillInit();
				var info = {
						popupUrl		: "/account/accountCommon/accountCommonPopup.do",
						popupID 		: "taxinvoiceSearchPopup",
						openerID		: "CostApplication",
						popupTit 		: "<spring:message code='Cache.ACC_btn_taxBillLoad'/>",
						popupName 		: "TaxinvoiceSearchPopup",
						callBackFunc 	: "combiCostAppTB_getTaxInfo",
						includeAccount 	: "N",
						companyCode 	: me.CompanyCode,
						paramsetFunc	: "combiCostApp_CallAddLoadPopupParam"
				}
				var url = me.makeObjPopupUrl(info);
				Common.open(	"",info.popupID,info.popupTit,url,"1200px","630px","iframe",true,null,null,true);
				
			},
			combiCostAppTB_getTaxInfo : function(inputVal) {
				var me = this;
				var property = accountCtrl.getInfoStr("[name=ExpAppPropertyField][tag=TaxInvoice]").val();

				//Property값이 뭔가 있을경우 인터페이스, 공백일경우 자체 DB
				//자체DB일경우 추가적인 값 조회가 필요
				if(isEmptyStr(property)){
					$.ajax({
						type:"POST",
						url:"/account/expenceApplication/getTaxBillInfo.do",
						data:{
							taxBillID : inputVal.TaxInvoiceID
						},
						success:function (data) {
							if(data.result == "ok"){
								var getTaxBillList = data.list[0];
								
								// 품목 추가
								if(inputVal.ItemList && inputVal.ItemList.length > 0) {
									getTaxBillList.ItemList = inputVal.ItemList;
								}
								
								me.combiCostAppTB_inputListDataAdd([getTaxBillList], true);
							}
							else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					});
				}
				else{
					$.ajax({
						type:"POST",
						url:"/account/expenceApplication/getVdCheck.do",
						data:{
							VendorNo : inputVal.InvoicerCorpNum
						},
						success:function (data) {
							if(data.result == "ok"){
								var vdInfo = data.vdInfo;
								if(vdInfo != null){
									inputVal.VendorNo = vdInfo.VendorNo;
									inputVal.VendorName = vdInfo.VendorName;
									inputVal.CEOName = vdInfo.CEOName;
									inputVal.Address = vdInfo.Address;
									inputVal.Industry = vdInfo.Industry;
									inputVal.Sector = vdInfo.Sector;
									inputVal.BankAccountInfo = vdInfo.BankAccountInfo;
									inputVal.BankAccountName = vdInfo.BankAccountName;
									inputVal.BankCode = vdInfo.BankCode;
									inputVal.BankName = vdInfo.BankName;
									inputVal.divComment = (typeof(vdInfo.ItemName) == "undefined" ? "" : vdInfo.ItemName);
								}
								me.combiCostAppTB_inputListDataAdd([inputVal], true, property);
							}
							else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					});
				}
			},

			combiCostAppTB_inputListDataAdd : function(infoList, isNew, property) {
				//세금계산서 데이터 정리해서 비용신청 obj 에 넣고 품목별 증빙분할 생성
				
				var me = this;
				me.combiCostApp_setModified(true);
				
				var arrCk = Array.isArray(infoList);
				if(arrCk){
					var addedCk1 = false;
					var addedCk2 = false;
					var confirmNoList = "";
					
					//이미 추가된 내용인지 체크
					if (isNew) {
						for (var i = 0; i<infoList.length; i++) {
							var newItem = infoList[i];
							var oldItem = null;
							for (var y = 0; y<me.taxBillPageExpenceAppList.length; y++) {
								oldItem = me.taxBillPageExpenceAppList[y];
								if (oldItem.TaxUID == newItem.TaxUID) {
									addedCk1 = true;
									confirmNoList = (confirmNoList=="") ? newItem.TaxNTSConfirmNum : confirmNoList+","+newItem.TaxNTSConfirmNum;
									break;
								}
							}
							
							if (addedCk1) break;
						}
						
						if (addedCk1) {
							var msg = "<spring:message code='Cache.ACC_016' />";
							msg = msg.replace("@@{appNoList}", confirmNoList);
							Common.Error(msg);
							return;
						}
					}
					
					//계산서 obj 만들기
					for(var i = 0; i<infoList.length; i++){
						var info = infoList[i];
						var divCk = false;
						if(isNew){
							if(!isEmptyStr(property) || info.isXML=="Y"){
								var copyObj = objCopy(info);
								info.oriIFData = copyObj;

								info.ProofCode = "TaxBill";
								info.TaxNTSConfirmNum = info.NTSConfirmNum;
								info.SupplyCost = info.SupplyCostTotal;
								info.WriteDate = info.WriteDate;
								info.FormatWriteDate = info.FormatWriteDate;
								info.Tax = info.TaxTotal;
								info.FormatTotalAmount = toAmtFormat(info.TotalAmount);
								info.FormatTaxTotal = toAmtFormat(info.TaxTotal);
								info.FormatSupplyCostTotal = toAmtFormat(info.SupplyCostTotal);
								info.VendorName = info.VendorName;
								info.VendorNo = info.VendorNo;
								info.CEOName = info.CEOName;
								info.Addr = info.Address;
								info.Industry = info.Industry;
								info.Sector = info.Sector;
								info.AccountInfo = info.BankAccountInfo;
								info.AccountHolder = info.BankAccountName;
								info.AccountBank = info.BankCode;
								info.AccountBankName = info.BankName;
								if(typeof info.ItemList === 'object' && info.ItemList.length > 0){
									info.ItemList = info.ItemList;
									
									info.ItemName = info.ItemList[0].ItemName;
									info.Remark = info.ItemList[0].Remark;
								}
							}
							info.IsNew = true;
							info.IsNewStr = "Y";
							
							//전자세금계산서 지급방법/세금유형 default 값 세팅
							info.PayMethod = "C";
							info.TaxType = "deduct";
							//거래처비용정산 & 전자세금계산서 > 지급대상 default 값 세팅
							if(requestType == "VENDOR") {
								info.PayTarget = "Vendor";
							}
						}

						var maxKey = me.combiCostApp_getPageListMaxKey('TaxBill');
						info.KeyNo = maxKey+1;
						info.ProofCode = "TaxBill";
						
						if(info.ProofDate == null || info.ProofDate == ""){
							info.ProofDate = info.WriteDate;
							info.ProofDateStr = info.FormatWriteDate;
						}
						if(info.PostingDate == null || info.PostingDate == ""){
							info.PostingDate = info.ProofDate;
							info.PostingDateStr = info.ProofDateStr;
							
						}
						info.RepAmount = info.SupplyCost;
						info.TaxAmount = info.Tax;
						
						if(info.divList == null){
							divCk = true;
						} else if(info.divList.length==0){
							divCk = true;
						}
						
						//품목별 증빙분할 추가
						if(divCk){
							info.divList = [];
							var divItem = {
									ExpenceApplicationListID : info.ExpenceApplicationListID
									, KeyNo : info.KeyNo
									, ProofCode : info.ProofCode
									
									, ExpenceApplicationDivID : "" 
									, AccountCode :  ""
									, AccountName : ""
									, StandardBriefID :  ""
									, StandardBriefName : ""
									, CostCenterCode :  nullToBlank(me.pageCombiAppComboData.DefaultCC.CostCenterCode)
									, CostCenterName :  nullToBlank(me.pageCombiAppComboData.DefaultCC.CostCenterName)
									, IOCode : ""
									, IOName : ""
									, Amount : info.RepAmount
									, UsageComment : info.ItemName
									, IsNew : true
									, Rownum : 0
							}
							
							if(info.ItemList) {
								//품목별 증빙분할 생성
								(info.ItemList).map(function(item, idx) {
									var addItem = JSON.parse(JSON.stringify(divItem));
									addItem.Amount = Number(AmttoNumFormat(item.SupplyCost)); //청구금액 (품목 공급가액) 
									addItem.UsageComment = item.ItemName; //내역 (품목명)
									addItem.Rownum = idx;
									
									info.divList.push(addItem);
								});
								
								var maxRN = info.ItemList.length - 1;
								info.maxRowNum = maxRN;
								info.maxDivRownum = maxRN;
							} else {
								divItem.UsageComment = info.ItemName;
								info.divList.push(divItem);
							}
						}
						if(info.maxDivRownum==null) {
							info.maxDivRownum=0
						}
						
						me.businessNumberCnt = info.BusinessNumberCnt; //임시저장된 증빙 수정 시
						/* if(isNew){
							if(me.businessNumberCnt == 0){
								info.VendorNo = "";
								info.VendorName = "";
								info.CEOName = "";
								info.Address = "";
								info.Industry = "";
								info.Sector = "";
								info.BankAccountInfo = "";
								info.BankAccountName = "";
								info.BankCode = "";
							} else if ( me.businessNumberCnt > 1){
								me.businessNumber = info.VendorNo;
							}		
						} */
						me.taxBillPageExpenceAppList.push(info);
					}
					me.combiCostAppTB_setListHTML();
				}
			},
			
			//전자세금계산서 사용내역 HTML 만들기
			combiCostAppTB_setListHTML : function(isAll) {
				var me = this;
				if(isAll){
					accountCtrl.getInfoName("combiCostAppTB_TableArea").html();
				}

				for(var i = 0; i<me.taxBillPageExpenceAppList.length; i++){
					var item = me.taxBillPageExpenceAppList[i];
					
					item.AccountBankName = accComm.getBaseCodeName("Bank", nullToBlank(item.AccountBank), me.CompanyCode);
					
					if(item.AccountBankName == "") {
						item.AccountBankName = item.AccountBank;
					}
					
					var valMap = {
							RequestType : requestType,
							ExpenceApplicationListID : nullToBlank(item.ExpenceApplicationListID),
							KeyNo : nullToBlank(item.KeyNo),
							ProofCode : nullToBlank(item.ProofCode),
							ProofDate : nullToBlank(item.ProofDateStr),
							PostingDate : nullToBlank(item.PostingDateStr),
							PayDate : nullToBlank(item.PayDate),
							
							TaxUID : nullToBlank(item.TaxUID),
							TaxNTSConfirmNum : nullToBlank(item.TaxNTSConfirmNum),
							TotalAmount : toAmtFormat(nullToBlank(item.TotalAmount)),
							Tax : toAmtFormat(nullToBlank(item.Tax)),
							TaxAmount : toAmtFormat(nullToBlank(item.TaxAmount)),
							SupplyCost : toAmtFormat(nullToBlank(item.SupplyCost)),
							WriteDate : nullToBlank(item.FormatWriteDate),
							Remark : nullToBlank(item.Remark),
							ItemName : nullToBlank(item.ItemName),
							ItemList : nullToBlank(item.ItemList),
							
							InvoicerCorpNum : nullToBlank(item.InvoicerCorpNum),
							InvoicerCorpName : nullToBlank(item.InvoicerCorpName),
							InvoicerCEOName : nullToBlank(item.InvoicerCEOName),
							InvoicerAddr : nullToBlank(item.InvoicerAddr),
							InvoicerBizType : nullToBlank(item.InvoicerBizType),
							InvoicerBizClass : nullToBlank(item.InvoicerBizClass),
							
							InvoiceeCorpNum : nullToBlank(item.InvoiceeCorpNum),
							InvoiceeCorpName : nullToBlank(item.InvoiceeCorpName),
							InvoiceeCEOName : nullToBlank(item.InvoiceeCEOName),
							InvoiceeAddr : nullToBlank(item.InvoiceeAddr),
							InvoiceeBizType : nullToBlank(item.InvoiceeBizType),
							InvoiceeBizClass : nullToBlank(item.InvoiceeBizClass),
							
							TaxType : nullToBlank(item.TaxType),
							TaxCode : nullToBlank(item.TaxCode),
							PayMethod : nullToBlank(item.PayMethod),
							PayType : nullToBlank(item.PayType),
							PayTarget : nullToBlank(item.PayTarget),
							AlterPayeeNo : nullToBlank(item.AlterPayeeNo),
							AlterPayeeName : nullToBlank(item.AlterPayeeName),
							VendorName : nullToBlank(item.VendorName),
							VendorNo : nullToBlank(item.VendorNo),
							VendorID : nullToBlank(item.VendorID),
							BusinessNumber : nullToBlank(item.BusinessNumber),
							AccountInfo : nullToBlank(item.AccountInfo),
							AccountHolder : nullToBlank(item.AccountHolder),
							AccountBank : nullToBlank(item.AccountBank),
							AccountBankName : nullToBlank(item.AccountBankName)
					}
					
					valMap.payMsg = "<spring:message code='Cache.ACC_lbl_payBill' />";
					if(item.PurposeType == "01") {
						valMap.payMsg = "<spring:message code='Cache.ACC_lbl_payBill2' />";
					}
					
					var htmlStr = me.combiCostApp_makeInputHtmlForm(item, valMap);
					accountCtrl.getInfoName("combiCostAppTB_TableArea").append(htmlStr);
					if(isEmptyStr(item.TaxInvoiceID)){
						accountCtrl.getInfoStr("[name=noTaxIFView][proofcode="+item.ProofCode+"][keyno="+item.KeyNo+"]").remove();
					}
					
					if(valMap.VendorID != "") {
						var tempObj = {
                            KeyNo           : valMap.KeyNo,
                            ProofCode       : "TaxBill",
                            VendorID        : valMap.VendorID,
                            VendorNo        : valMap.VendorNo,
                            PayMethod       : valMap.PayMethod,
                            PayType         : valMap.PayType,
                            AccountInfo     : valMap.AccountInfo,
                            AccountHolder   : valMap.AccountHolder,
                            AccountBank     : valMap.AccountBank,
                            AccountBankName : valMap.AccountBankName
                        };
						me.combiCostApp_getVendorInfo(tempObj); 
					}
					
					if(Common.getBaseConfig("RecentVendorUseYN") == "Y" ) {
						var tempItem = me.combiCostApp_selRecentVendorInfo(item.BusinessNumber,item.ProofCode );
						me.combiCostApp_makeInputDivHtmlAddCopy(tempItem, true);
					} else {
						me.combiCostApp_makeInputDivHtmlAdd(item);
					}
					
					//품목 영수증, 세부증빙 생성
					if(valMap.ItemList.length > 0) {
						var itemArr = valMap.ItemList;
						var itemTable = $("#combiCostAppTaxBill_listArea_"+item.KeyNo).find("[name=invoiceItemTable]");
						
						$(itemTable).css("display","");
						
						itemArr.map(function(val) {
							var TaxBillItemInputFormStr = me.combiCostApp_htmlFormSetVal(me.pageCombiAppFormList.TaxBillItemInputFormStr, val);
							$(itemTable).append(TaxBillItemInputFormStr);
						});
						
						$(itemTable).find("tr:first-child td:last-child").attr("rowspan", itemArr.length+1);
					}
					
					var selectFieldList = accountCtrl.getInfoStr("[name=ComboSelect][proofcode="+item.ProofCode+"][keyno="+item.KeyNo+"]");
					for(var y = 0; y<selectFieldList.length; y++){
						var field = selectFieldList[y];

						var dataField = field.getAttribute("field");
						field.value=nullToBlank(item[dataField]);
						
						if(field.onchange!=null){
							field.onchange();
						}
					}


					var docList = item.docList;
					if(docList != null){
						var setDocList = [].concat(docList);
						me.combiCostApp_DocHTML(setDocList, item.KeyNo, 'TaxBill', false);
					}
					
					var fileList = item.fileList;
					var uploadFileList = item.uploadFileList;
					var setFileList = []
					if(fileList != null){
						setFileList = setFileList.concat(fileList);
					}
					if(uploadFileList != null){
						setFileList = setFileList.concat(uploadFileList);
					}
					item.fileMaxNo = 0;
					if(setFileList != null){
						for(var y = 0; y<setFileList.length; y++){
							var fileItem = setFileList[y];
							item.fileMaxNo++;
							fileItem.fileNum = item.fileMaxNo;
						}
						me.combiCostApp_UploadHTML(setFileList, item.KeyNo, 'TaxBill', false);
					}
				}
				if( me.businessNumberCnt > 1) {
					me.combiCostApp_callVendorPopup("TaxBill", 1, me.businessNumber);
				}
				
				me.combiCostApp_makeDateField("TaxBill", me.taxBillPageExpenceAppList);
			},
			//팝업 호출 url 생성
	        makeObjPopupUrl: function(popupObj) {
				/* //기존 팝업 url 형식
				var url		= "/account/accountCommon/accountCommonPopup.do?"
							+ "popupID="	 +	popupID		+	"&"
							+ "popupName="	 +	popupName	+	"&"
							+ me.pageOpenerIDStr
							+ "companyCode=" +	me.CompanyCode	+ "&"
							+ "callBackFunc="+	callBack; */
				
				var me = this;
				var url = "";
				var popupKey = Object.keys(popupObj);
				var skipKeyArr = ["popupTit", "width", "height"];
				
				if(!popupObj.popupUrl) popupObj.popupUrl = "/account/accountCommon/accountCommonPopup.do";
				
				popupKey.forEach(function(key, index) {
					if(skipKeyArr.includes(key)) return;
					if(key == "popupUrl") {
						var param = popupObj[key] + "?";
						url = param + url;
						return;
					}
					var param = key + "=" + popupObj[key] + "&";
					url += param;
				});
				
				url += me.pageOpenerIDStr; //'openerID=CombineCostApplicationVENDOR&'
				return url.substring(0, url.length - 1);
	        }
	        
	}
	window.CombineCostApplication<%=requestType%> = $.extend(window.CombineCostApplication<%=requestType%>, CombineCostApplicationTax<%=requestType%>);	
	
	/////////////////////////// 종이세금계산서 ///////////////////////////
	
	var CombineCostApplicationPaper<%=requestType%> = {		
			
			paperBillPageExpenceAppList : [],

			combiCostAppPB_PaperBillPageInit : function() {
				var me = this;
				accountCtrl.getInfoName("combiCostAppPB_TableArea").html("");
				me.paperBillPageExpenceAppList = [];
			},
			
			combiCostAppPB_PaperBillDataInit : function() {
				var me = this;
				accountCtrl.getInfoName("combiCostAppPB_TableArea").html("");
				me.paperBillPageExpenceAppList = [];
			},

			combiCostAppPB_itemAdd : function() {
				var me = this;
				
				if(me.paperBillPageExpenceAppList.length != 0){
					Common.Confirm("<spring:message code='Cache.ACC_018' />", "Confirmation Dialog", function(result){
						if(result){
							me.combiCostAppPB_PaperBillDataInit()
							me.combiCostAppPB_inputListDataAdd(null, true);
						}
					});
				}else{
					me.combiCostAppPB_PaperBillDataInit()
					me.combiCostAppPB_inputListDataAdd(null, true);
				}
			
			},

			combiCostAppPB_inputListDataAdd : function(inputItem, isNew) {
				var me = this;
				me.combiCostApp_setModified(true);
				var item = {};
				
				if(isNew){
					var pd = item.ProofDate;

					item.IsNew = true;
					item.IsNewStr = "Y";
					me.isModified = false;
				}else{
					item = inputItem;
					me.isModified = true;
				}

				var maxKey = me.combiCostApp_getPageListMaxKey('PaperBill');
				item.KeyNo = maxKey+1;
				item.ProofCode = "PaperBill";
				if(item.ProofDate == null) { item.ProofDate = ""; item.ProofDateStr = ""; }
				if(item.PostingDate == null) { item.PostingDate = ""; item.PostingDateStr = ""; }
				
				var divCk = false;
				if(item.divList == null){
					divCk = true;
				}
				else if(item.divList.length==0){
					divCk = true;
				}
				if(divCk){
					item.divList = [];
					var divItem = {
							ExpenceApplicationDivID : ""
							, ExpenceApplicationListID : "" 
							, AccountCode :  ""
							, AccountName : ""
							, StandardBriefID :  ""
							, StandardBriefName : ""
							, CostCenterCode :  nullToBlank(me.pageCombiAppComboData.DefaultCC.CostCenterCode)
							, CostCenterName :  nullToBlank(me.pageCombiAppComboData.DefaultCC.CostCenterName)
							, IOCode : ""
							, IOName : ""
							, Amount : item.TotalAmount
							, UsageComment : ""
							, IsNew : true
							, Rownum : 0
					}
					item.divList.push(divItem);
				}
				me.paperBillPageExpenceAppList.push(item);

				me.combiCostAppPB_setListHTML();
			},

			combiCostAppPB_setListHTML : function(isAll) {
				var me = this;
				
				if(isAll){
					accountCtrl.getInfoName("combiCostAppPB_TableArea").html("");
				}
				
				for(var i = 0; i<me.paperBillPageExpenceAppList.length; i++){
					var item = me.paperBillPageExpenceAppList[i];
					
					if(nullToBlank(item.IncomeTax) != "") {
						item.IncomTax = item.IncomeTax;
					}
					
					var valMap = {
							RequestType : requestType,
							ExpenceApplicationListID : nullToBlank(item.ExpenceApplicationListID),
							KeyNo : nullToBlank(item.KeyNo),
							ProofCode : nullToBlank(item.ProofCode),
							ProofDate : nullToBlank(item.ProofDate),
							ProofDateStr : nullToBlank(item.ProofDateStr),
							
							TotalAmount : toAmtFormat(nullToBlank(item.TotalAmount)),
							RepAmount : toAmtFormat(nullToBlank(item.RepAmount) == "" ? item.TotalAmount : item.RepAmount),
							TaxAmount : toAmtFormat(nullToBlank(item.TaxAmount) == "" ? 0 : item.TaxAmount),
							
							TaxType : nullToBlank(item.TaxType),
							TaxCode : nullToBlank(item.TaxCode),
							PayMethod : nullToBlank(item.PayMethod),
							PayType : nullToBlank(item.PayType),
							PayTarget : nullToBlank(item.PayTarget),
							AlterPayeeNo : nullToBlank(item.AlterPayeeNo),
							AlterPayeeName : nullToBlank(item.AlterPayeeName),
							VendorName : nullToBlank(item.VendorName),
							VendorNo : nullToBlank(item.VendorNo),
							VendorID : nullToBlank(item.VendorID),
							BusinessNumber : nullToBlank(item.BusinessNumber),
							AccountInfo : nullToBlank(item.AccountInfo),
							AccountHolder : nullToBlank(item.AccountHolder),
							AccountBank : nullToBlank(item.AccountBank),
							AccountBankName : nullToBlank(item.AccountBankName),
							
							ProviderName : nullToBlank(item.ProviderName),
							ProviderNo : nullToBlank(item.ProviderNo),
							Providee : nullToBlank(item.Providee),
							BillType : nullToBlank(item.BillType),
					}
					
					var htmlStr = me.combiCostApp_makeInputHtmlForm(item, valMap);
					accountCtrl.getInfoName("combiCostAppPB_TableArea").append(htmlStr);					
					
					if(valMap.VendorID != "") {
						var tempObj = {};
						tempObj.KeyNo = valMap.KeyNo;
						tempObj.ProofCode = "PaperBill";
						tempObj.VendorID = valMap.VendorID;
						tempObj.PayMethod = valMap.PayMethod;
						tempObj.PayType = valMap.PayType;
						tempObj.AccountInfo = valMap.AccountInfo;
						tempObj.AccountHolder = valMap.AccountHolder;
						tempObj.AccountBank = valMap.AccountBank;
						tempObj.AccountBankName = valMap.AccountBankName;
						me.combiCostApp_getVendorInfo(tempObj); 
					}
					
					var selectFieldList = accountCtrl.getInfoStr("[name=ComboSelect][proofcode="+item.ProofCode+"][keyno="+item.KeyNo+"]");
					for(var y = 0; y<selectFieldList.length; y++){
						var field = selectFieldList[y];

						var dataField = field.getAttribute("field");
						field.value=nullToBlank(item[dataField]);
						
						if(field.onchange!=null){
							field.onchange();
						}
					}
					
					me.combiCostApp_makeInputDivHtmlAdd(item);

					var docList = item.docList;
					if(docList != null){
						var setDocList = [].concat(docList);
						me.combiCostApp_DocHTML(setDocList, item.KeyNo, 'PaperBill', false);
					}
					
					var fileList = item.fileList;
					var uploadFileList = item.uploadFileList;
					var setFileList = []
					if(fileList != null){
						setFileList = setFileList.concat(fileList);
					}
					if(uploadFileList != null){
						setFileList = setFileList.concat(uploadFileList);
					}
					item.fileMaxNo = 0;
					if(setFileList != null){
						
						for(var y = 0; y<setFileList.length; y++){
							var fileItem = setFileList[y];
							item.fileMaxNo++;
							fileItem.fileNum = item.fileMaxNo;
						}
						me.combiCostApp_UploadHTML(setFileList, item.KeyNo, 'PaperBill', false);
					}
				}
				me.combiCostApp_makeDateField("PaperBill", me.paperBillPageExpenceAppList);

			},

			ctrlComboChange: function(obj){
				var me = this;
				var type = $(obj).attr("type");
				var ProofCode = $(obj).attr("proofcd");
	            var KeyNo = $(obj).attr("keyno");
	            var Rownum = $(obj).attr("rownum");
	          
				me.combiCostApp_ComboChange(obj, ProofCode, KeyNo, type, Rownum);
			},

			setChkYN: function (obj) {
	            var me = this;
	            var val = $(obj).val();

	            if(val == "Y"){
	                val = "";
	            }else{
	                val = "Y";
	            }
	            
	            obj.value = val;
	        },
	        
	        callBizTripPopup : function(obj, name) {
				var me = this;
	            var obj = $(obj).prev();

				var ProofCode = $(obj).attr("proofcd");
	            var KeyNo = $(obj).attr("keyno");
	            var Rownum = $(obj).attr("rownum");
	            var code = $(obj).attr("code");

	            var popupTit = name;
	            var popupID, popupName, callBack, width, height;
	            
				me.tempObj.KeyNo = KeyNo;
				me.tempObj.ProofCode = ProofCode;
				me.tempObj.Rownum = Rownum;
	            me.tempObj.code = code;
	            
	            if(code == "D02") {
	            	//D02: 유류비
		            popupID = "DistancePopup";
		            popupName = "DistancePopup";
		            callBack = "SetDistanceCallBack";
		            width = "1000px";
		            height = "800px";
	            } else if(code == "D03") {
	            	//D03: 일비 
            	  	popupID = "DailyPopup";
		            popupName = "DailyPopup";
		            callBack = "SetDailyCallBack";
		            width = "550px";
		            height = "400px";
	            } else if(code == "Z09") {
	            	//Z09: tmap 없는 유류비
		            popupID = "DistancePopup";
		            popupName = "DistancePopup";
		            callBack = "SetDistanceCallBack";
		            width = "1000px";
		            height = "550px";
	            }
	            
				var info = {
						popupUrl		: "/account/accountCommon/accountCommonPopup.do",
						popupID 		: popupID,
						popupTit 		: popupTit,
						popupName 		: popupName,
						callBackFunc 	: callBack,
						includeAccount 	: "N",
						companyCode 	: me.CompanyCode,
						parentNM		: me.pageName,
						jsonCode		: code,
						ProofCode		: ProofCode,
						KeyNo			: KeyNo,
						Rownum			: Rownum
				}
				var url = me.makeObjPopupUrl(info);
	            Common.open("", popupID, popupTit, url, width, height, "iframe", true, null, null, true);
			},
			
			SetDistanceCallBack: function (info) {
	            var me = this;
	            
				var ProofCode = me.tempObj.ProofCode;
				var KeyNo = me.tempObj.KeyNo;
				var Rownum = me.tempObj.Rownum;
				
				//var pageList = me["pageExpenceApp"+ProofCode+"List"];
				var pageList = me.combiCostApp_getPageList(ProofCode);
				var getItem = me.combiCostApp_findListItem(pageList, "KeyNo", KeyNo);
				
				var fuelList = $.extend(true,[],info['FuelExpenceAppEvidList']);
				
				var FuelRealPrice = 0;
				var totDistance = 0;
				var lastDate = '';
 
	            var code = me.tempObj.code;
	            var obj = accountCtrl.getInfoStr("input[code='" + code + "'][keyno='" + KeyNo + "'][rownum='" + Rownum + "']")[0];
	            var PopCode = {};
				var lastDateHidden = new Date(lastDate);
	            var Distance;
				
				$(fuelList).each(function(idx,item){
					item.BizTripDateStr = item.BizTripDate;
					item.BizTripDate = item.BizTripDate.replace(/\./gi, '');	
					FuelRealPrice += Number(item.FuelRealPrice);
					totDistance += Number(item.Distance.replace(/\,/gi, ''));
					
				    if(Number(item.BizTripDate) > lastDate.replace(/\./gi, '')) {
				    	lastDate = item.BizTripDateStr;
				    }
				});
				
				lastDateHidden.format("MM/dd/yyyy");

	            PopCode['Distance'] = info['Distance'];
	            PopCode['FuelExpenceAppEvidList']= info['FuelExpenceAppEvidList'];
	            PopCode = JSON.stringify(PopCode);

	            Distance = toAmtFormat(totDistance.toFixed(1));
	            
	            if(code!='D02') {
	            	Distance = toAmtFormat(totDistance);
	            }
	            
				accountCtrl.getInfoStr("[name=DivAmountField][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").val(toAmtFormat(FuelRealPrice));
				accountCtrl.getInfoStr("[name=DivAmountField][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").keyup();
				
				//divList Amount 수정
				me.combiCostApp_setDivVal(ProofCode, KeyNo, Rownum, "Amount", FuelRealPrice);
				
				//총합 계산
				me.setBizTripTotalAmount(ProofCode, KeyNo, getItem);

				accountCtrl.getInfoStr("[name=DateArea][proofcd="+ProofCode+"][keyno="+KeyNo+"]").find("input[type=text]").val(lastDate);
				accountCtrl.getInfoStr("[name=DateArea][proofcd="+ProofCode+"][keyno="+KeyNo+"]").find("input[type=hidden]").val(lastDateHidden);
				accountCtrl.getInfoStr("[name=DateArea][proofcd="+ProofCode+"][keyno="+KeyNo+"]").trigger("onchange");
	            
	            accountCtrl.getInfoStr("[code='" + code + "'][keyno='" + KeyNo + "'][rownum='" + Rownum + "'][popup='value']").val(Distance);
	            accountCtrl.getInfoStr("[code='" + code + "'][keyno='" + KeyNo + "'][rownum='" + Rownum + "'][popup='code']").val(PopCode);
	            
	            accountCtrl._onSaveJson(me, obj, "CtrlArea", ProofCode, KeyNo, Rownum);
	            
				me.tempObj = {};
	        },
	        
	        SetDailyCallBack : function(returnList){				
				var me = this;
				var ProofCode = me.tempObj.ProofCode;
				var KeyNo = me.tempObj.KeyNo;
				var Rownum = me.tempObj.Rownum;

				//var pageList = me["pageExpenceApp"+ProofCode+"List"];
				var pageList = me.combiCostApp_getPageList(ProofCode);
				var getItem = me.combiCostApp_findListItem(pageList, "KeyNo", KeyNo);
				
				var dailyList = $.extend(true,[],returnList['DailyExpenceAppEvidList']);
				
				var DailyAmount = 0;
				var commentHtml = "";
				var WorkingDays = 0;
				var lastDate = '';
				
				var code = me.tempObj.code;
	            var obj = accountCtrl.getInfoStr("input[code='" + code + "'][keyno='" + KeyNo + "'][rownum='" + Rownum + "']")[0];
	            var PopCode = {};
				var lastDateHidden = new Date(lastDate);
				
				$(dailyList).each(function(idx,item){
					item.BizTripDateStStr = item.BizTripDateSt;
					item.BizTripDateSt = item.BizTripDateSt.replace(/\./gi, '');
					item.BizTripDateEdStr = item.BizTripDateEd;
					item.BizTripDateEd = item.BizTripDateEd.replace(/\./gi, '');

					DailyAmount += Number(item.DailyAmount);
					WorkingDays += Number(item.WorkingDays);
					
					commentHtml += item.BizTripDateSt + " ~ " + item.BizTripDateEd + "(" + item.DailyTypeNM + ") " + toAmtFormat(item.DailyAmount) + "<spring:message code='Cache.ACC_krw'/>" + " \n";
				    
				    if(Number(item.BizTripDateEd.replace(/\./gi, '')) > lastDate.replace(/\./gi, '')) {
				    	lastDate = item.BizTripDateEdStr;
				    }				    
				});
				
				lastDateHidden.format("MM/dd/yyyy");
				
	            PopCode['DailyExpenceAppEvidList'] = returnList['DailyExpenceAppEvidList'];
	            PopCode = JSON.stringify(PopCode);
				
				accountCtrl.getInfoStr("[name=DivCommentField][datafield=UsageComment][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").html(commentHtml);
				accountCtrl.getInfoStr("[name=DivCommentField][datafield=UsageComment][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").keyup();

				accountCtrl.getInfoStr("[name=DivAmountField][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").val(DailyAmount);
				accountCtrl.getInfoStr("[name=DivAmountField][proofcode="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").keyup();
				
				//divList 수정
				me.combiCostApp_setDivVal(ProofCode, KeyNo, Rownum, "Amount", DailyAmount);
				
				//일비 총합 계산
				me.setBizTripTotalAmount(ProofCode, KeyNo, getItem);
				
				accountCtrl.getInfoStr("[name=DateArea][proofcode="+ProofCode+"][keyno="+KeyNo+"]").find("input[type=text]").val(lastDate);
				accountCtrl.getInfoStr("[name=DateArea][proofcode="+ProofCode+"][keyno="+KeyNo+"]").find("input[type=hidden]").val(lastDateHidden);
				accountCtrl.getInfoStr("[name=DateArea][proofcode="+ProofCode+"][keyno="+KeyNo+"]").trigger("onchange");
				
	            accountCtrl.getInfoStr("[code='" + code + "'][keyno='" + KeyNo + "'][rownum='" + Rownum + "'][popup='value']").val(WorkingDays);
	            accountCtrl.getInfoStr("[code='" + code + "'][keyno='" + KeyNo + "'][rownum='" + Rownum + "'][popup='code']").val(PopCode);

	            accountCtrl._onSaveJson(me, obj, "CtrlArea", ProofCode, KeyNo, Rownum);
	            
				me.tempObj = {};
			},
			
			//출장항목(일비,유류비) 총액 계산
			setBizTripTotalAmount : function(ProofCode, KeyNo, item) {
				var me = this;
				
				var TotalAmount = 0;
				for(var i = 0; i < item.divList.length; i++) {
				    var divItem = item.divList[i];
				    if(divItem.ReservedStr2_Div != undefined) {
					    if('D02' in divItem.ReservedStr2_Div || 'D03' in divItem.ReservedStr2_Div || 'Z09' in divItem.ReservedStr2_Div) {
					    	TotalAmount += parseInt(divItem.Amount);
					    }
				    }
				}
				
				var totalField = accountCtrl.getInfoStr("[name=CombiCostInputField][field=TotalAmount][proofcode="+ProofCode+"][keyno="+KeyNo+"]");
				if(totalField.length > 0) {
					totalField.val(TotalAmount);
					me.combiCostApp_setListVal(ProofCode, KeyNo, "TotalAmount", TotalAmount);
				}
			},
			
			//편익제공 팝업 오픈
			callAttendantPopup : function(obj, name) {
				var me = this;
	            var obj = $(obj).prev();

				var ProofCode = $(obj).attr("proofcd");
	            var KeyNo = $(obj).attr("keyno");
	            var Rownum = $(obj).attr("rownum");
	            var code = $(obj).attr("code");

	            var popupTit = name;
	            var popupID, popupName, callBack, width, height;
	            
				me.tempObj.KeyNo = KeyNo;
				me.tempObj.ProofCode = ProofCode;
				me.tempObj.Rownum = Rownum;
	            me.tempObj.code = code;
	            
	            if(code=="C07") {
	            	//C07: tmap 없는 유류비
		            popupID = "AttendantPopup";
		            popupName = "AttendantPopup";
		            callBack = "SetAttendantCallBack";
		            width = "1000px";
		            height = "550px";
	            }
	            
				var info = {
						popupUrl		: "/account/accountCommon/accountCommonPopup.do",
						popupID 		: popupID,
						popupTit 		: popupTit,
						popupName 		: popupName,
						callBackFunc 	: callBack,
						includeAccount 	: "N",
						companyCode 	: me.CompanyCode,
						parentNM		: me.pageName,
						jsonCode		: code,
						KeyNo			: KeyNo,
						ProofCode		: ProofCode,
						RequestType		: requestType
				}
				var url = me.makeObjPopupUrl(info);
	            Common.open("", popupID, popupTit, url, width, height, "iframe", true, null, null, true);
			},
			
			SetAttendantCallBack : function(returnList) {
				var me = this;
				var ProofCode = me.tempObj.ProofCode;
				var KeyNo = me.tempObj.KeyNo;
				var Rownum = me.tempObj.Rownum;
				var code = me.tempObj.code;
					            
	            var obj = accountCtrl.getInfoStr("input[code='" + code + "'][keyno='" + KeyNo + "'][rownum='" + Rownum + "']");
	            var attendList = $.extend(true,[],returnList['AttendantList']);
	            var PopCode = {};
	            
	            PopCode['AttendantList'] = returnList['AttendantList'];
	            PopCode = JSON.stringify(PopCode);
	            
				var displayText = $(attendList).length < 2 
									? $(attendList)[0].UserName 
									: "<spring:message code='Cache.msg_BesidesCount' />".replace("{0}", $(attendList)[0].UserName).replace("{1}", $(attendList).length-1);
	           
	            accountCtrl.getInfoStr("[code='" + code + "'][keyno='" + KeyNo + "'][rownum='" + Rownum + "'][popup='value']").val(displayText);
	            accountCtrl.getInfoStr("[code='" + code + "'][keyno='" + KeyNo + "'][rownum='" + Rownum + "'][popup='code']").val(PopCode);

	            accountCtrl._onSaveJson(me, obj, "CtrlArea", ProofCode, KeyNo, Rownum);
	            
				me.tempObj = {};
	        },
			setEditor: function(g_editorBody){
				var me = this;
				
				var domainID = accComm.getDomainID(me.CompanyCode);
				var g_containerID = 'tbContentElement<%=requestType%>';
				var g_editorKind = Common.getBaseConfig('EditorType', domainID);
				
				coviEditor.loadEditor(
					'divWebEditor<%=requestType%>',
					{
						editorType : g_editorKind,
						containerID : g_containerID,
						frameHeight : '510',
						focusObjID : '',
						onLoad:  function(){
				        	coviEditor.setBody(g_editorKind, g_containerID, g_editorBody);
				        }
					}
				);
			}
	}
	window.CombineCostApplication<%=requestType%> = $.extend(window.CombineCostApplication<%=requestType%>, CombineCostApplicationPaper<%=requestType%>);
})(window);

function InputDocLinks(szValue) {
    try {
    	window.CombineCostApplication<%=requestType%>.combiCostApp_LinkComp(szValue); 
    	// szValue : [ProcessID(ProcessArchiveID)]@@@[FormPrefix]@@@[Subject]^^^[ProcessID(ProcessArchiveID)]@@@[FormPrefix]@@@[Subject]
    	// ex) 2402569@@@WF_FORM_EACCOUNT_LEGACY@@@결재연동 1713^^^2400107@@@WF_FORM_EACCOUNT_LEGACY@@@통합 비용 신청 - 0706 #1
    }
    catch (e) {
    }
}
</script>
