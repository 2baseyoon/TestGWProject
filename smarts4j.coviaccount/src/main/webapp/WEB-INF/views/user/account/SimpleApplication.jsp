<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil" %>
<%@ page import="egovframework.coviframework.util.StringUtil" %>
<%@ page import="egovframework.coviframework.util.RedisDataUtil" %>
<%@ page import="egovframework.coviaccount.common.util.AccountUtil" %>

<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<%
	String requestType = request.getParameter("requesttype");

	AccountUtil accountUtil = new AccountUtil();
	String propertyAprv = accountUtil.getBaseCodeInfo("eAccApproveType", "ExpenceApplication");

	String propertyOtherApv = RedisDataUtil.getBaseConfig("eAccOtherApv");
	String AccountApvLineType = RedisDataUtil.getBaseConfig("AccountApvLineType");
	String isUseBizMnt = RedisDataUtil.getBaseConfig("isUseBizMnt");
	
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
		#alt_div {
			padding-left:10px;
			border:1px solid #c8c8c8;
			background-color:#ffffff;
			color:#330000;
			font-size:13px;
			position:absolute;
			overflow:hidden;
			z-index:auto;
			width:auto;
			height:auto;
			filter:alpha(opacity=1);
		}
	</style>
</head>
<body>
	<!-- 상단 끝 -->
	<div class="cRConTop titType">
		<h2 id="headerTitle" class="title"></h2>	
		<% if(StringUtil.replaceNull(requestType).equals("INVEST")) { %>
			<a href="#" onclick="openInvestStandardPopup()" class="btnTypeDefault"><spring:message code="Cache.ACC_lbl_investStandard"/></a>
		<% } %>		
	</div>
	<div class="cRConTop">
		<!-- 상단 버튼 시작 -->
		<div class="cRTopButtons">
			<a href="#" class="btnTypeDefault btnTypeChk" onClick="SimpleApplication<%=requestType%>.simpApp_onSave('S')"  name="saveBtn">
				<!-- 신청 -->
				<spring:message code="Cache.ACC_btn_application"/>
			</a>					
			<a href="#" class="btnTypeDefault" onClick="openApvLinePopup()" name="apvLineBtn" style="display: none;">
				<!-- 결재선 -->
				<spring:message code="Cache.lbl_ApprovalLine"/>
			</a>
			<a href="#" class="btnTypeDefault" onClick="openRuleApvPopup()" name="ruleApvbtn" style="display: none;">
				<!-- 전결규정 -->
				<spring:message code="Cache.apv_btn_rule"/>
			</a>
			<a href="#" class="btnTypeDefault" onClick="SimpleApplication<%=requestType%>.simpApp_onSave('T')"  name="saveBtn">
				<!-- 임시저장 -->
				<spring:message code="Cache.ACC_btn_tempSave"/>
			</a>
			<a href="#" class="btnTypeDefault" onClick="SimpleApplication<%=requestType%>.simpApp_onSave('E')"  name="afterSaveBtn" style="display:none">
				<!-- 저장 -->
				<spring:message code="Cache.ACC_btn_save"/>
			</a>					
			<a href="#" class="btnTypeDefault" onclick="SimpleApplication<%=requestType%>.simpApp_showPreview()" name="previewBtn" style="display:none">
				<!-- 미리보기 -->
				<spring:message code="Cache.btn_preview"/>
			</a>
		</div>
		<!-- 상단 버튼 끝 -->	
	</div>
	<div class="total_acooungting">		
		<!-- 결재선 영역 -->	
		<% 
		if(propertyOtherApv.equals("N")) {
			if(AccountApvLineType.equals("Graphic")) { %>
				<div id="graphicDiv" style="padding: 10px 0 0 25px;"></div>
		<%	} else { %>
				<jsp:include page="Frozen.jsp" flush="false"></jsp:include>
		<%	}
		} 
		%>		
			
		<!-- 컨텐츠 시작 -->
		<div class="eaccountingCont"> 
			<div class="allMakeView">
				<!-- 제목 및 hidden field 영역 -->
				<div class="inpStyle01 allMakeTitle" style="padding-top:10px;">
					<input type="text" class="inpStyle01 HtmlCheckXSS ScriptCheckXSS" id="simpApp_ApplicationTitle" name="SimpAppInputField"
						onkeyup="SimpleApplication<%=requestType%>.simpApp_setModified(true);" tag="ApplicationTitle" placeholder="<spring:message code='Cache.ACC_msg_noTitle'/>" maxlength="100">	<!-- 제목을 입력하세요 -->
						
					<input type="hidden" id="simpApp_isSearched"	name="SimpAppInputField" tag="isSearched">
					<input type="hidden" id="simpApp_isNew"			name="SimpAppInputField" tag="isNew">
					<input type="hidden" id="simpApp_ExpAppID"		name="SimpAppInputField" tag="ExpenceApplicationID">
					<input type="hidden" id="simpApp_PropertyBudget"		name="SimpAppInputField" tag="Budget">
					<input type="hidden" id="simpApp_UserDefaultCCCode"		name="SimpAppInputField" tag="CostCenterCode">
					<input type="hidden" id="simpApp_UserDefaultCCName"		name="SimpAppInputField" tag="CostCenterName">
				</div>
			</div>
			<%-- <p class="eaccounting_name">
				<!-- 신청자 -->
				<strong><spring:message code="Cache.ACC_lbl_applicator"/> :</strong> 
				<label id="simpApp_lblApplicator"></label>
			</p> --%>
			<div class="eaccountingCont_in">
				<div class="inStyleSetting">
					<!-- 상단 영역(회사, 신청자, 코스트센터, I/O, 금액합계 등) -->
					<div class="card_nea_top_wrap_2" style="height:auto; padding:0px; margin:0px;" >		
						<table>
							<colgroup>
								<col style="width:70%">
								<col style="width:30%">
							</colgroup>
							<tr class="total_acooungting_info" >
								<td>
									<div class="total_acooungting_info_wrap" style="height: auto;">
										<!-- 내역 상세보기 -->
										<a class="btnTypeDefault" id="simpApp_DetailPopupBtn" onclick="SimpleApplication<%=requestType %>.simpApp_openDetailPopup(this)"
											style="display:none; float:right; margin-right:10px; background:white;" href="#"></a>
										<ul class="total_acooungting_info" style="float:none;" >
											<li>
												<dl>
													<!-- 회사 -->
													<dt><spring:message code='Cache.ACC_lbl_companyCode'/> :</dt>
													<dd style="min-width: 0;">
														<label id="simpApp_CompanyName"  name="SimpAppInputField" tag="CompanyName"></label>
													</dd>
													<input type="hidden"  id="simpApp_CompanyCode" name="SimpAppInputField" tag="CompanyCode">
												</dl>
											</li>
											<li>
												<dl>
													<!-- 신청자 -->
													<dt><spring:message code='Cache.ACC_lbl_applicator'/> :</dt>
													<dd style="min-width: 0;">
														<label id="simpApp_Sub_UR_Name"  name="SimpAppInputField" tag="Sub_UR_Name" NO_INIT="Y"></label>
														<a href="#" class="btn_search" onclick="SimpleApplication<%=requestType%>.simpApp_onSubUserSearch()"></a>
													</dd>
													<input type="hidden"  id="simpApp_Sub_UR_Code" name="SimpAppInputField" tag="Sub_UR_Code" NO_INIT="Y">
													<input type="hidden"  id="simpApp_Sub_UR_Info" name="SimpAppInputField" tag="Sub_UR_Info" NO_INIT="Y">
												</dl>
											</li>
											<!-- 프로젝트 -->
											<li style="display: none;">
												<dl>
													<dt><spring:message code='Cache.ACC_lbl_projectName'/> :</dt>
													<dd>
														<label id="simpApp_IOLabel"   name="SimpAppInputField" tag="IOName"></label>
														<a href="#" class="btn_search" onclick="SimpleApplication<%=requestType%>.simpApp_onIOSearch()"></a>
														<a href="#" class="btn_del" onclick="SimpleApplication<%=requestType%>.simpApp_SetIOVal()"></a> 
													</dd>
													<input type="hidden"  id="simpApp_IOCode" name="SimpAppInputField" tag="IOCode">
												</dl>
											</li>
											<li>
												<dl>
													<dt><spring:message code='Cache.ACC_lbl_payDay'/> :</dt>
													<dd> 
														<span class="selectType02 size113" id="simpApp_defaultPayDateList" 
															onChange="SimpleApplication<%=requestType%>.simpApp_payDateComboChange(this)">
														</span>
														<span class="dateSel type02" id='simpApp_defaultPayDateInput' style="display: none;" onchange="SimpleApplication<%=requestType%>.simpApp_makePayDate('E')">
														</span> 
													</dd>
												</dl>
											</li>
										</ul>
									</div>
								</td>
								<td>
									<div class="total_acooungting_wrap" id="simpApp_TotalWrap">
										<table class="total_acooungting_wrap_table">
											<tbody>
												<tr>
													<td class="acc_total_l" style="display:none;">
														<table class="total_table_list">
															<tbody>
																<tr><td id="simpApp_EvidAmtArea"></td></tr>
																<tr><td id="simpApp_SBAmtArea"></td></tr>
																<tr style="display: none;"><td id="simpApp_AuditCntArea"></td></tr>
															</tbody>
														</table>
													</td>
													<td class="acc_total_r">
														<table class="total_table">
															<thead>
																<tr>			<!-- 증빙 총액  | 청구 금액 -->
																	<th><spring:message code='Cache.ACC_lbl_eviTotalAmt'/><span id="simpApp_lblTotalCnt"></span></th>
																	<th><spring:message code='Cache.ACC_billReqAmt'/></th>
																</tr>
															</thead>
															<tbody>
																<tr>			<!-- 원 -->
																	<td><span class="tx_ta" id="simpApp_lblTotalAmt" onmouseover="alt( '' )" onmouseout="altOut()">0</span><spring:message code='Cache.ACC_krw'/></td>
																	<td><span class="tx_ta" id="simpApp_lblBillReqAmt">0</span><spring:message code='Cache.ACC_krw'/></td>
																</tr>
															</tbody>
														</table>
														<input type="hidden" id="simpApp_TotalAmt"  name="SimpAppInputField" tag="TotalAmt">
														<input type="hidden" id="simpApp_ReqAmt"  name="SimpAppInputField" tag="ReqAmt">
													</td>
												</tr>
											</tbody>
										</table>
									</div>
								</td>
							</tr>
						</table>
					</div>
					
					<table class="total_acooungting_table2" name="ProjectArea" style="display:none; margin-top: 20px;">
						<tbody>
								<tr>
									<td class="th"><spring:message code='Cache.ACC_lbl_projectName'/></td> <!-- 프로젝트명 -->
									<td id="simpApp_projectName"></td>
									<td class="th"><spring:message code='Cache.ACC_lbl_executivePlan'/></td> <!-- 집행계획서 -->
									<td>
										<a href="#" onclick="SimpleApplication<%=requestType%>.simpApp_LinkOpen('execplan')" id="simpApp_execDocSubject"></a>
										<input type="hidden" id="simpApp_execProcessID" />
									</td>
								</tr>         
						</tbody>
					</table>
					
					<!-- 증빙 및 카드선택 영역 -->					
					<div class="total_acooungting_info_wrap" style="margin-bottom: 12px; height: 25px;">					
						<span class="selectType02 size233" id="simpApp_inputProofCode" 
							onChange="SimpleApplication<%=requestType%>.simpApp_evidComboChange(this)">
						</span>
						<span class="selectType02 size211" id="simpApp_CardListSelect">
						</span>
					</div>
					
					<div class="card_ea_wrap">
						<div class="card_ea_left">
							<div class="card_ea_left_top">
								<input type="checkbox" style="" id="simpApp_evidCardCheckAll" onclick="SimpleApplication<%=requestType%>.simpApp_cardCheckAll();" />
								<div class="dateSel type02" style="display:inline-block;">		
									<div id="simpApp_dateArea" class="dateSel type02" name="searchParam" fieldtype="Date" style='display: inline-block;'
										stfield="simpApp_dateArea_St" edfield="simpApp_dateArea_Ed" 
										onkeyup="SimpleApplication<%=requestType%>.simpApp_evidInfoCall();"
										onchange="SimpleApplication<%=requestType%>.simpApp_evidInfoCall();"
										stdatafield="UseDateSt" eddatafield="UseDateEd">
									</div>				
								</div>
								<!-- <div class="card_ea_left_select">
									<select class="selectType02" name="simpApp_evidSearchListCount">
										<option>15</option>
										<option>30</option>
										<option>45</option>
										<option>60</option>
									</select>
								</div> -->
								<div class="buttonStyleBoxRight" style="margin-top: 5px;">
									<a href="#" class="btnTypeDefault" style="display:none;padding:0px" name="simpApp_DeleteEvidBtn" id="simpApp_DeleteCorpCardBtn" onclick="SimpleApplication<%=requestType%>.simpApp_deleteEvid('CorpCard')"><spring:message code="Cache.ACC_lbl_personalUse"/></a> <!-- 개인사용 -->
									<a href="#" class="btnTypeDefault" style="display:none;" name="simpApp_DeleteEvidBtn" id="simpApp_DeleteReceiptBtn" onclick="SimpleApplication<%=requestType%>.simpApp_deleteEvid('Receipt')"><spring:message code="Cache.ACC_lbl_delete"/></a> <!-- 삭제 -->
								</div>
							</div>
							<div class="card_nea_left_cont">
								<ul class="card_nea_left_cont_list" id="simpApp_EvidInfoListArea" name="simpApp_EvidInfoListArea">
								</ul>												
							</div>
						</div>
						<div class="card_ea_btn_wrap"  name="simpApp_AddBtnArea">
							<select class="selectType02" name="simpApp_AddBriefSelect" onchange="SimpleApplication<%=requestType%>.simpApp_evidInfoAdd(this)" style="width: 90px; margin-top: 5px; margin-bottom: 15px; padding-right: 25px;"></select>
						</div>
						<%-- <div class="card_ea_btn_wrap"  name="simpApp_AddBtnArea">
							<select class="selectType02" name="simpApp_AddBriefSelect" onchange="SimpleApplication<%=requestType%>.simpApp_evidInfoAdd(this)" style="width: 90px; margin-top: 5px; padding-right: 25px;"></select>
							<a href="#" class="btnTypeDefault" onclick="SimpleApplicationNORMAL.simpApp_evidInfoAdd('*')"style="margin-bottom: 15px;width: 90px; padding-right: 25px;"><span><spring:message code="Cache.ACC_lbl_StoreCategoryApply"/></span></a>
						</div> --%>
						<div class="card_ea_right">
							<div class="card_ea_right_top">
								<!-- 신청 내역 -->
								<p class="card_ea_right_title">
									<input type="checkbox" style="margin: 0 6px;" id="simpApp_evidAddCheckAll" onclick="SimpleApplication<%=requestType%>.simpApp_toggleCheckAll();" />
									<spring:message code='Cache.ACC_lbl_applicationList'/>
								</p>
								<div class="pagingType02 buttonStyleBoxRight">
									<a class="btnTypeDefault btnPlusAdd" name="AddItemBtn" id="simpApp_EtcEvidAddItemBtn" style="display: none;" href="#" onclick="SimpleApplication<%=requestType%>.simpApp_evidInfoAdd('None', 'EtcEvid')"><spring:message code="Cache.ACC_btn_etcEvidAdd"/></a> <!-- 기타증빙 추가 -->
									<a class="btnTypeDefault btnPlusAdd" name="AddItemBtn" id="simpApp_PrivateCardAddItemBtn" style="display: none;" href="#" onclick="SimpleApplication<%=requestType%>.simpApp_evidInfoAdd('None', 'PrivateCard')"><spring:message code="Cache.ACC_btn_privateCardLoad"/></a> <!-- 개인카드 추가 -->
									<a class="btnTypeDefault" name="CopyItemBtn" id="simpApp_PrivateCardCopyItemBtn" style="display: none;" href="#" onclick="SimpleApplication<%=requestType%>.simpApp_evidInfoCopy('None', 'PrivateCard')" title="<spring:message code='Cache.ACC_msg_copyPrivateCardExpence'/>"><spring:message code='Cache.ACC_btn_copyPrivateCard'/></a> <!-- 개인카드 증빙 복사 -->
									<a class="btnTypeDefault" name="CopyItemBtn" id="simpApp_EtcEvidCopyItemBtn" style="display: none;" href="#" onclick="SimpleApplication<%=requestType%>.simpApp_evidInfoCopy('None', 'EtcEvid')" title="<spring:message code='Cache.ACC_msg_copyEtcEvidExpence'/>"><spring:message code='Cache.ACC_btn_copyEtcEvid'/></a> <!-- 기타증빙 복사 -->
									<a class="btnTypeDefault" href="#" onclick="SimpleApplication<%=requestType%>.simpApp_deleteAddedItem()"><spring:message code='Cache.ACC_btn_delete'/></a>
								</div>
							</div>
							<div class="card_ea_right_cont">
								<ul class="card_nea_right_list" name="simpApp_AddListArea"></ul>
							</div>
						</div>
					</div>
					<!--웹 에디터-->
					<div>
						<div id="divWebEditor<%=requestType%>"></div>
					</div>
				</div>
			</div>
			<div name="simpApp_hiddenViewForm" style="display:none"></div>
		</div>
		<!-- 컨텐츠 끝 -->
		
		<!-- 금액 상세정보 alt 영역 -->
		<div id="alt_div"></div>
		
		<!-- 로딩 이미지  -->
		<div style="display: none; background: rgb(0, 0, 0); left: 0px; top: 0px; width: 100%; height: 1296px; position: fixed; z-index: 149; opacity: 0; filter: progid:DXImageTransform.Microsoft.Alpha(opacity=0); -ms-filter:'progid:DXImageTransform.Microsoft.Alpha(opacity=0)'; " id="loading_overlay"></div>
		<div id="divLoading" style="display: none; text-align:center;z-index:10;background-color:red;margin:0 auto;position:absolute; top:16%; left:50%; height:20px; margin-left:-10px; margin-top:-10px; ">
			<img src="/HtmlSite/smarts4j_n/covicore/resources/images/covision/loding12.gif" style="text-align:center;" alt=""/>
		</div>
		<input type="hidden" id="APVLIST_">
		<input type="hidden" id="RuleItemInfo" name="SimpAppInputField" tag="RuleItemInfo" />
	</div>
	<!-- 전자결재 연동용 iframe -->
	<iframe id="goFormLink" src="" style="display: none;" title=""></iframe>
</body>	
<script type="text/javascript" charset="UTF-8">


if (!window.SimpleApplication<%=requestType%>) {
	window.SimpleApplication<%=requestType%> = {};
}

var Sub_UR_Name = null;
var Sub_Chg_Title = null;

(function(window) {
	var isUseIO = Common.getBaseConfig("IsUseIO");
	var isUseSB = Common.getBaseConfig("IsUseStandardBrief");
	var isUseBD = "N";
	
	var requestType = "";
	var propertyOtherApv = "<%=propertyOtherApv%>";
	
	var SimpleApplication<%=requestType%> = {			
			pageOpenerIDStr : "openerID=SimpleApplication<%=requestType%>&",
			pageName :  "SimpleApplication<%=requestType%>",
			ApplicationType : "SC",
			
			//좌측 증빙 목록
			pageEvidInfoList : [],
			//증빙 정보
			pageEvidInfoMap : {},
			//추가한 증빙 맵
			pageEvidAddMap : {},
			
			//추가된 증빙 목록
			pageExpenceAppEvidList : [],
			pageExpenceAppCorpCardList : [],
			pageExpenceAppPrivateCardList : [],
			pageExpenceAppEtcEvidList : [],
			pageExpenceAppReceiptList : [],
			//삭제할 증빙 목록
			pageExpenceAppEvidDeletedList : [],
			//페이지 데이터 오브젝트
			pageExpenceAppData : {},
			
			pageSimpAppFormList : {	
									EvidInfoForm : "",
									
									CorpCardAddForm : "",
									InputAddForm : "",
									DivInputAreaStr : "",
									DivAddInputAreaStr : "",
									
									CorpCardViewForm : "",
									EtcEvidViewForm : "",
									PrivateCardViewForm : "",
									ReceiptViewForm : "",
									DivForm : "",
								},
			pageSimpAppComboData : {
				DefaultCC : {}
			},
			
			tempVal : {},
			pageInfo : {},
			dataModified : false,
			openParam : {},
			CompanyCode : '',
			
			pageInit : function(inputParam) {
				var me = this;
				
				me.tempVal.isLoad = false;
				
				requestType = "<%=requestType%>";
				
				setHeaderTitle('headerTitle');
				
				if(inputParam != null){
					me.openParam = inputParam;
				}

				var isSearch = "";
				var ExpAppId = "";
				if(inputParam != null){
					isSearch = inputParam.isSearch;
					ExpAppId = inputParam.ExpAppId;
				}
				
				//사용자에 매핑된 코스트센터의 회사코드 가져오기
				me.CompanyCode = accComm.getCompanyCodeOfUser(sessionObj["UR_Code"]);
				
				//비용신청서 정보 가져오기
				accComm.getFormManageInfo(requestType, me.CompanyCode);
				me.noteIsUse = accComm.getNoteIsUse(me.CompanyCode, requestType, 'divWebEditor' + requestType);
				me.exchangeIsUse = accComm.getExchangeIsUse(me.CompanyCode, requestType);
				
				//날짜 컨트롤러 생성
				makeDatepicker('simpApp_dateArea', 'simpApp_dateArea_St', 'simpApp_dateArea_Ed', null, null, 100);
				makeDatepicker("simpApp_defaultPayDateInput", "simpApp_defaultPayDateInput_Date", null, null, null, 100);

				//증빙 선택 Select Box Load 
				var AXSelectMultiArr = [	
					{'codeGroup':'ProofCodeSimple', 'target':'simpApp_inputProofCode', 'lang':'ko', 'onchange':'', 'oncomplete':'', 'defaultVal':''}
				]
				accountCtrl.renderAXSelectMulti(AXSelectMultiArr, me.CompanyCode);
				
				//비용신청서 별 사용하는 증빙 option 추가
				accComm.setComboByProofInfo(requestType, 'simpApp_inputProofCode', me.CompanyCode);
				
				//Form Init
				me.simpApp_formInit();
				
				//Form 영역 Select Box Load
				me.simpApp_onComboDataLoad();

				//Property Init
				setPropertySearchType('Budget','simpApp_PropertyBudget');
				isUseBD = accountCtrl.getInfo("simpApp_PropertyBudget").val();
				
				//마감일자 셋팅
				accComm.setDeadlineInfo();
				
				//KAKAO 택시 이력 조회
				//var today = new Date();
				//var preMonthDay= new Date(today.getFullYear(), today.getMonth()-1 , 1);
				//accComm.getkakaoTaxiList(preMonthDay.format("yyyyMMdd"),today.format("yyyyMMdd"),requestType);
				
				if(isSearch !="Y") {
					accountCtrl.getInfo('simpApp_Sub_UR_Name').text(sessionObj.USERNAME);
					accountCtrl.getInfo('simpApp_Sub_UR_Code').val(sessionObj.USERID);
					accountCtrl.getInfo('simpApp_Sub_UR_Info').val(sessionObj.UR_JobPositionCode);
					me.simpApp_setNew();
					me.setEditor("");
				} else {
					if(ExpAppId != null){
						// 임시저장 데이터 로딩시 증빙내역 draw 후 me.tempVal 값이 셋팅되어 IO, CC 등 변경팝업 오동작. --> simpApp_searchData 에서 tempVal 초기화되도록. hgsong.
						me.tempVal.saveType = "T";
						me.simpApp_searchData(ExpAppId);
					}
				}
				 
				if(Common.getBaseConfig("IsUseIO") == "N") {
					accountCtrl.getInfo("simpApp_IOCode").parent().parent().hide();
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
				
				//지급희망일 Select Box Load 
				me.setPayDateSelectCombo();

				//최종결재선 지정
				if(propertyOtherApv != "Y") {					
					var strMode = "";
					var processID = null;
					
					if(inputParam != null && inputParam.isReview == "Y") {
						strMode = "COMPLETE";
						processID = me.pageExpenceAppData.ProcessID;
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
					
					setWorkedAutoDomainData(accComm[requestType].pageExpenceFormInfo.FormPrefix, strMode, ExpAppId, processID);
				}				
				
				// default 제목 세팅
				if(accountCtrl.getInfo("simpApp_ApplicationTitle").val() == "") {
					accountCtrl.getInfo("simpApp_ApplicationTitle").val(setApplicationTitle());
				}

				me.tempVal.isLoad = true;
				
				$(accountCtrl.getInfo("simpApp_CardListSelect")).on('change', function() {
					window.SimpleApplication<%=requestType%>.simpApp_evidInfoCall();
			    });
			},
			pageView : function(inputParam) {
				var me = this;
				
				requestType = "<%=requestType%>";
				
				if(inputParam != null){
					$.extend(me.openParam, inputParam);
				}

				accountCtrl.refreshAXSelect("simpApp_defaultPayDateList");
				accountCtrl.refreshAXSelect("simpApp_inputProofCode");				

				var openType = "";
				var isSearch = "";
				var ExpAppId = "";
				if(inputParam != null){
					openType = inputParam.name;
					isSearch = inputParam.isSearch;
					ExpAppId = inputParam.ExpAppId;
				}

				formJson = $.extend({}, formJson, accComm[requestType].pageExpenceFormInfo);
				//$.extend(formJson, {"RuleInfo" : formJson.RuleInfo.replace(/item/gi, 'ruleitem')});
				if(getInfo("RuleInfo") && getInfo("RuleInfo").indexOf("ruleitem") == -1) setInfo("RuleInfo", getInfo("RuleInfo").replace(/item/gi, 'ruleitem'));
				
				//탭 이동일 시 아무작업 안함
				if(openType === "tabDivTitle"){
					return;
				}
				
				//새로 작성이면 작업중인 내용 삭제 여부 물어보기
				else if(openType=="LeftSub"){
					if(me.dataModified){
						//작업중인 내용이 있습니다. 작업중인 내용을 지우고 새로 작성하시겠습니까?
						Common.Confirm("<spring:message code='Cache.ACC_msg_initDataCk' />", "Confirmation Dialog", function(result){	//작업중인 내용이 있습니다. 작업중인 내용을 지우고 새로 작성하시겠습니까?
							if(result){
								me.simpApp_setNew();
							}
						});
					}
					else{
						me.simpApp_setNew();
					}
				}
				
				//조회일 경우
				else if(openType=="search"){
					if(ExpAppId != null){
						me.simpApp_dataInit();
						me.simpApp_evidInfoCall();
						me.simpApp_searchData(ExpAppId);
					}
				}

			},
			
			//폼 데이터 세팅
			simpApp_formInit : function() {
				var me = this;
				var formPath = Common.getBaseConfig("AccountApplicationFormPath");

				$.ajaxSetup({async:false});
				
				$.get(formPath + "SimpleApplication_EvidInfoForm.html" + resourceVersion, function(val){
					me.pageSimpAppFormList.EvidInfoForm = val;
				});
				
				$.get(formPath + "SimpleApplication_CorpCardAddForm.html" + resourceVersion, function(val){
					me.pageSimpAppFormList.CorpCardAddForm = val;
				});
				$.get(formPath + "SimpleApplication_InputAddForm.html" + resourceVersion, function(val){
					me.pageSimpAppFormList.InputAddForm = val;
				});
				$.get(formPath + "SimpleApplication_Div.html" + resourceVersion, function(val){
					me.pageSimpAppFormList.DivInputAreaStr = val;
				});
				$.get(formPath + "SimpleApplication_DivAdd.html" + resourceVersion, function(val){
					me.pageSimpAppFormList.DivAddInputAreaStr = val;
				});
				
				$.get(formPath + "CombiCostApp_ViewForm_CorpCard_Apv.html" + resourceVersion, function(val){
					me.pageSimpAppFormList.CorpCardViewForm = val;
				});
				$.get(formPath + "CombiCostApp_ViewForm_EtcEvid_Apv.html" + resourceVersion, function(val){
					me.pageSimpAppFormList.EtcEvidViewForm = val;
				});
				$.get(formPath + "CombiCostApp_ViewForm_PrivateCard_Apv.html" + resourceVersion, function(val){
					me.pageSimpAppFormList.PrivateCardViewForm = val;
				});
				$.get(formPath + "CombiCostApp_ViewForm_Receipt_Apv.html" + resourceVersion, function(val){
					me.pageSimpAppFormList.ReceiptViewForm = val;
				});
				$.get(formPath + "CombiCostApp_ViewForm_Div_Apv.html" + resourceVersion, function(val){
					me.pageSimpAppFormList.DivForm = val;
				});
			},
 	
			//폼에 세팅할 콤보 데이터 조회
			simpApp_onComboDataLoad : function() {
				var me = this;
				//관리항목 조회
				$.ajax({
					type:"POST",
						url:"/account/accountCommon/getBaseCodeData.do",
					data:{
						codeGroups : "AccountCtrl,BizTripItem,InvestTarget,InvestItem,ExchangeNation",
						CompanyCode : me.CompanyCode
					},
					async: false,
					success:function (data) {
						if(data.result == "ok"){
							var codeList = data.list;
							
							me.pageSimpAppComboData.InvestTargetList = codeList.InvestTarget;
							me.pageSimpAppComboData.InvestItemList = codeList.InvestItem;
							
							if(codeList.hasOwnProperty('AccountCtrl'))
							{
								me.pageSimpAppComboData.AccountCtrlList = codeList.AccountCtrl;
								me.simpApp_makeCodeMap(me.pageSimpAppComboData.AccountCtrlList, "AccountCtrl", "Code", "CodeName");
							}
							if(codeList.hasOwnProperty('BizTripItem'))
							{
								me.pageSimpAppComboData.BizTripItemList = codeList.BizTripItem;
								me.simpApp_makeCodeMap(me.pageSimpAppComboData.BizTripItemList, "BizTripItem", "Code", "CodeName");
							}
							if(codeList.hasOwnProperty('ExchangeNation') && me.exchangeIsUse == "Y")
							{
								me.pageSimpAppComboData.ExchangeNationList = codeList.ExchangeNation;
								me.simpApp_makeCodeMap(me.pageSimpAppComboData.ExchangeNationList, "ExchangeNation", "Code", "CodeName");
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

				//업종관리데이터 조회
				$.ajax({
					type:"POST",
						url:"/account/expenceApplication/getStoreCategoryCombo.do",
					data:{
						CompanyCode : me.CompanyCode
					},
					async: false,
					success:function (data) {
						if(data.result == "ok"){
							var codeList = data.list;
							me.pageSimpAppComboData.StoreCategoryList = data.list;
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
							me.pageSimpAppComboData.TaxCodeList = data.list;
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
						"isSimp": "Y",
						"StandardBriefSearchStr": accComm[requestType].pageExpenceFormInfo.StandardBriefSearchStr,
						"CompanyCode": me.CompanyCode
					},
					success:function (data) {
						if(data.result == "ok"){
							me.pageSimpAppComboData.BriefList = data.list;
							me.simpApp_makeCodeMap(data.list, "Brief", "StandardBriefID");
							
							if(requestType == "INVEST") {
								me.pageSimpAppComboData.UserBriefList = data.list;
								me.simpApp_makeCodeMap(data.list, "UserBrief", "StandardBriefID");
							} else {
								me.pageSimpAppComboData.UserBriefList = data.userList;
								me.simpApp_makeCodeMap(data.userList, "UserBrief", "StandardBriefID");
							}
							
							// 신청서 별 표준적요					
							me.simpApp_FormComboInit();
							
							// 신청서 별 사용자 즐겨찾기 표준적요
							me.simpApp_makeBtnArea();
						}
						else{
							Common.Error("<spring:message code='Cache.ACC_msg_error' />");	//오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />");	//오류가 발생했습니다. 관리자에게 문의 바랍니다.
					}
				});
			},
			
			simpApp_getUserCardList : function() {
				var me = this;
				accountCtrl.getInfo("simpApp_CardListSelect").html('');
				//카드목록 조회
				
				
				
				$.ajax({
					type:"POST",
					url:"/account/expenceApplication/getCardList.do",
					async:false,
					data:{
						"UR_Code": accountCtrl.getInfo('simpApp_Sub_UR_Code').val() == "" ? sessionObj.USERID : accountCtrl.getInfo('simpApp_Sub_UR_Code').val(), // Sub_UR_Code가 빈 값인 경우 sessionObj.USERID 재할당
						"CompanyCode": accountCtrl.getInfo('simpApp_CompanyCode').val(),
						"RequestType":requestType
					},
					success:function (data) {
						if(data.result == "ok"){
							if(data.list.length > 0) {
								accountCtrl.getInfo("simpApp_CardListSelect").show();
								accountCtrl.createAXSelectData("simpApp_CardListSelect",data.list, null, 'CorpCardID', 'CorpCardName', null, null, null);
								accountCtrl.getInfo("simpApp_CardListSelect").change();
							} else {
								accountCtrl.getInfo("simpApp_CardListSelect").hide();
								accountCtrl.getInfoName("simpApp_EvidInfoListArea").html("");
							}
						}
						else{
							Common.Error("<spring:message code='Cache.ACC_msg_error' />");	//오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />");	//오류가 발생했습니다. 관리자에게 문의 바랍니다.
					}
				});
			},
			
			//화면 데이터 초기화
			simpApp_dataInit : function() {
				var me = this;

				me.simpApp_setModified(false);

				me.pageExpenceAppData = {};
				me.pageEvidInfoList = [];
				me.pageEvidInfoMap = {};
				me.pageExpenceAppEvidList = [];
				me.pageExpenceAppEvidDeletedList = [];
				me.pageEvidAddMap = {};
				
				me.pageExpenceAppCorpCardList = [];
				me.pageExpenceAppPrivateCardList = [];
				me.pageExpenceAppEtcEvidList = [];
				me.pageExpenceAppReceiptList = [];
				
				var fieldList =  accountCtrl.getInfoStr("[name=SimpAppInputField]:not([NO_INIT=Y])");
			   	for(var i=0;i<fieldList.length; i++){
			   		var field = fieldList[i];
			   		var tag = field.getAttribute("tag")
			   		
					var fieldType = field.tagName;
					if(fieldType=="INPUT"){
						field.value = "";
					} else if(fieldType=="LABEL"){
						field.innerHTML = "";
					}
			   	}
				
				me.simpApp_pageAmtSet();
				
				accountCtrl.getInfoName("simpApp_AddListArea").html("");
				
				if(requestType == "PROJECT") { 
					//프로젝트 비용신청일 경우만 프로젝트 선택 영역 show
					accountCtrl.getInfo("simpApp_IOLabel").parents("li").show();
					accountCtrl.getInfoName("ProjectArea").show();
				} else if(requestType == "BIZTRIP" || requestType == "OVERSEA") {
					accountCtrl.getInfo("simpApp_DetailPopupBtn").html("출장 내역 상세보기"); //TODO: 20210129 다국어
					accountCtrl.getInfo("simpApp_DetailPopupBtn").show();	

					if(me.openParam.BizTripRequestID != undefined) {
						me.simpApp_setBizTripRequestInfo(me.openParam.BizTripRequestID);
					}
					
					me.BizTripNoteMap = {};
				} else if(requestType == "SELFDEVELOP") {
					accountCtrl.getInfo("simpApp_DetailPopupBtn").html("예산 내역 상세보기"); //TODO: 20210129 다국어
					accountCtrl.getInfo("simpApp_DetailPopupBtn").show();
				}
			},

			//신규생성 화면으로 세팅
			simpApp_setNew : function() {
				var me = this;
				
				me.simpApp_dataInit();
				
				me.simpApp_evidInfoCall();
				
				accountCtrl.getInfoStr("[name=SimpAppInputField][tag=isSearched]").val("N");
				accountCtrl.getInfoStr("[name=SimpAppInputField][tag=isNew]").val("Y");
				accountCtrl.getInfoName("saveBtn").css("display","");
				accountCtrl.getInfoName("afterSaveBtn").css("display","none");
				
				//사용자의 법인카드 목록 가져오기
				if(accountCtrl.getComboInfo("simpApp_inputProofCode").val() == 'CorpCard') {
					me.simpApp_getUserCardList();
				}
				
				//사용자 코스트센터, 회사 정보 셋팅 - 회사 정보 없을 시 그룹사(공용)
				$.ajax({
					url:"/account/expenceApplication/getUserCC.do",
					cache: false,
					data:{
						UserCode : accountCtrl.getInfo('simpApp_Sub_UR_Code').val()
					},
					success:function (data) {
						if(data.result == "ok"){
							var getData = data.CCInfo;
							if(getData != null){
								//회사
								if(getData.CompanyCode != null && getData.CompanyCode != undefined && getData.CostCenterName != null && getData.CostCenterName != undefined) {
									accountCtrl.getInfo("simpApp_CompanyCode").val(getData.CompanyCode);						
									accountCtrl.getInfo("simpApp_CompanyName").text(getData.CompanyName);
								} else {
									accountCtrl.getInfo("simpApp_CompanyCode").val("ALL");
									accountCtrl.getInfo("simpApp_CompanyName").text(accComm.getBaseCodeName("CompanyCode", "All", "All"));
								}
								
								//코스트센터
								accountCtrl.getInfo("simpApp_UserDefaultCCCode").val(getData.CostCenterCode);
								accountCtrl.getInfo("simpApp_UserDefaultCCName").val(getData.CostCenterName);
								
								me.pageSimpAppComboData.DefaultCC.CostCenterCode = getData.CostCenterCode;
								me.pageSimpAppComboData.DefaultCC.CostCenterName = getData.CostCenterName;
							}
						}
					},
					error:function (error){ 
					}
				});
				
				if(requestType == "INVEST") {
					if(accountCtrl.getInfoName("simpApp_AddListArea").find("li").length == 0) {
						accountCtrl.getInfo("simpApp_EtcEvidAddItemBtn").click();
					}
				}
			},
			
			simpApp_setProjectArea : function() {
				var me = this;
				
				var IOCodeVal = accountCtrl.getInfo("simpApp_IOCode").val();
				var IONameVal = accountCtrl.getInfo("simpApp_IOLabel").html();
				
				if(IOCodeVal == undefined || IOCodeVal == "")
					return;

				accountCtrl.getInfo("simpApp_projectName").html(IONameVal);
				
				if("<%=isUseBizMnt%>" == "Y") {
					$.ajax({
						type:"POST",
						url:"/bizmnt/approval/searchProcessIdOfExecplan.do",
						async: false,
						cache: false,
						data:{
							projectCd : IOCodeVal
						},
						success:function (data) {
							if(data.status == "SUCCESS"){
								accountCtrl.getInfo("simpApp_execProcessID").val(data.processId);
								accountCtrl.getInfo("simpApp_execDocSubject").html(data.DocSubject);
							}
							else{
								accountCtrl.getInfo("simpApp_execProcessID").val("");
								accountCtrl.getInfo("simpApp_execDocSubject").html("");
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />");
						}
					});	
				}
			},
			
			simpApp_openDetailPopup : function(obj) {
				var me = this;
				
				var height = "";
				
				switch (requestType) {
				case "BIZTRIP" : height = "500px"; break;
				case "OVERSEA" : height = "600px"; break;
				default : height = "300px"; break;
				}
								
				var popupID		=	"applicationDetailPopup";
				var popupTit	=	$(obj).html();
				var popupName	=	"ApplicationDetailPopup";
				var appType		=	"SimpleApplication";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	me.pageOpenerIDStr
								+	"includeAccount=N&"
								+	"appType="		+	appType		+	"&"
								+	"requestType="	+	requestType	+	"&"
								+	"companyCode="	+	me.CompanyCode;
				Common.open(	"",popupID,popupTit,url,"1200px",height,"iframe",true,null,null,true);
			},
			
			simpApp_evidComboChange : function(obj) {
				var me = this;
				var getType = obj.value;
				if(getType==null || obj.tagName!="SELECT"){
					return;
				}
				
				accountCtrl.getInfoName("AddItemBtn").hide();
				accountCtrl.getInfoName("CopyItemBtn").hide();
				
				if(getType != "CorpCard") {
					accountCtrl.getInfo("simpApp_CardListSelect").hide();
				} else if(accountCtrl.getInfo("simpApp_CardListSelect").find("option").length > 0) {
					accountCtrl.getInfo("simpApp_CardListSelect").show();
					accountCtrl.refreshAXSelect("simpApp_CardListSelect");
				}
				
				if(getType == "PrivateCard" || getType == "EtcEvid"){					
					accountCtrl.getInfoStr("div.card_ea_left, div.card_ea_btn_wrap").hide();
					accountCtrl.getInfoStr("div.card_ea_right").css("width", "100%");
					accountCtrl.getInfo("simpApp_" + getType + "AddItemBtn").show();
				}else {
					accountCtrl.getInfoStr("div.card_ea_left, div.card_ea_btn_wrap").show();
					accountCtrl.getInfoStr("div.card_ea_right").css("width", "calc(100% - 406px)");
					me.simpApp_evidInfoCall(getType);
				}

				// 증빙 복사 버튼 show
				if(requestType == "NORMAL" && (getType == "PrivateCard" || getType == "EtcEvid")) {
					accountCtrl.getInfo("simpApp_" + getType + "CopyItemBtn").show();
				}
			},

			//상세조회
			simpApp_searchData : function(ExpenceApplicationID) {
				var me = this;
				me.simpApp_dataInit();
				$.ajax({
					url:"/account/expenceApplication/searchExpenceApplication.do",
					cache: false,
					data:{
						ExpenceApplicationID : ExpenceApplicationID
					},
					success:function (data) {
						
						if(data.result == "ok"){
							var getData = data.data;

							me.pageExpenceAppEvidList = getData.pageExpenceAppEvidList;
							me.pageExpenceAppData = getData;
							
							var fieldList =  accountCtrl.getInfoName("SimpAppInputField");
						   	for(var i=0;i<fieldList.length; i++){
						   		var field = fieldList[i];
						   		var tag = field.getAttribute("tag")
								var fieldType = field.tagName;
								if(fieldType=="INPUT"){
							   		field.value = nullToBlank(typeof(me.pageExpenceAppData[tag]) == "object" ? JSON.stringify(me.pageExpenceAppData[tag]) : me.pageExpenceAppData[tag]);
								} else if(fieldType=="LABEL"){
									if(tag == "Sub_UR_Name"){
								   		field.innerHTML = nullToBlank(CFN_GetDicInfo(me.pageExpenceAppData[tag]));
									} else {
							   			field.innerHTML = nullToBlank(me.pageExpenceAppData[tag]);
									}
								}
						   	}
				   										
						   	accountCtrl.getInfoStr("[name=SimpAppInputField][tag=isSearched]").val("Y");
							accountCtrl.getInfoStr("[name=SimpAppInputField][tag=isNew]").val("N");
							
							for(var i = 0; i<me.pageExpenceAppEvidList.length; i++){
								var item = me.pageExpenceAppEvidList[i];
								var ProofCode = item.ProofCode;
								var KeyField = me.simpApp_getProofKey(ProofCode);
								
								if(item.divList != null){
									item = $.extend(item, item.divList[0]); //divList에 있는 세부증빙(div) 정보를 증빙(list) 정보에 추가
								}
								
								me.pageEvidAddMap[item[KeyField]] = item;
								me["pageExpenceApp"+ProofCode+"List"] = me["pageExpenceApp"+ProofCode+"List"].concat(item);
							}
							
						   	accountCtrl.getInfo("simpApp_CCCode").val(nullToBlank(me.pageExpenceAppEvidList[0].CostCenterCode));
						   	accountCtrl.getInfo("simpApp_CCLabel").html(nullToBlank(me.pageExpenceAppEvidList[0].CostCenterName));
						   	
							
							if(me.pageExpenceAppEvidList.length > 0) {
								accountCtrl.getComboInfo("simpApp_defaultPayDateList").val(me.pageExpenceAppData.PayDateType);
								accountCtrl.refreshAXSelect("simpApp_defaultPayDateList");
								
								if(me.pageExpenceAppData.PayDateType == "E" && me.pageExpenceAppEvidList[0].PayDateStr != undefined) {
									accountCtrl.getInfo("simpApp_defaultPayDateInput_Date").val(me.pageExpenceAppEvidList[0].PayDateStr);
								}
							}

						   	if(requestType == "PROJECT") {
							   	accountCtrl.getInfo("simpApp_IOCode").val(nullToBlank(me.pageExpenceAppEvidList[0].IOCode));
							   	accountCtrl.getInfo("simpApp_IOLabel").html(nullToBlank(me.pageExpenceAppEvidList[0].IOName));
								
								me.simpApp_setProjectArea();
						   	} else if(requestType == "BIZTRIP" || requestType == "OVERSEA") {
								if(me.openParam.BizTripRequestID == undefined || me.openParam.BizTripRequestID == "") {
									me.openParam.BizTripRequestID = me.pageExpenceAppData.BizTripRequestID;
								}
								
								//출장신청서 정보 가져오기
								me.simpApp_setBizTripRequestInfo(me.pageExpenceAppData.BizTripRequestID);
							}
							
							me.simpApp_makeEvidAddHTMLAll();
							me.simpApp_evidInfoCall();
							me.simpApp_pageAmtSet();
							me.simpApp_makeViewForm();

							if(accountCtrl.getComboInfo("simpApp_inputProofCode").val() == 'CorpCard') {
								me.simpApp_getUserCardList();
							}
							
							if(me.openParam.isReview == "Y"){
								accountCtrl.getInfoName("saveBtn").css("display","none");
								accountCtrl.getInfoName("afterSaveBtn").css("display","");
							}
							else if(getData.ApplicationStatus != "T"){
								accountCtrl.getInfoName("saveBtn").css("display","none");
								accountCtrl.getInfoName("afterSaveBtn").css("display","none");
							}
							
							//감사규칙 위반 건 문서 표시
							displayAuditViolation(me.pageExpenceAppData.auditCntMap, "simpApp_AuditCntArea");
							
							if(me.tempVal.saveType=="S"){
								var saveData = me.tempVal.saveData;
								me.tempVal = {};
								//감사규칙 체크 후 결재 진행
								var expAppObj = me.pageExpenceAppData;
								expAppObj.Sub_UR_Name = Sub_UR_Name;
								//마감기간 기안통제여부 체크
								if(checkDeadlineControl(me.pageExpenceAppEvidList, me.CompanyCode)) return;
								checkAuditRule(propertyOtherApv, expAppObj, me.simpApp_getHTMLBody(), ExpenceApplicationID, requestType, me.CompanyCode);
							} else if(me.tempVal.saveType=="E") {
								me.tempVal = {};
								callChangeBodyContext(me.pageExpenceAppData, me.simpApp_getHTMLBody(), requestType);
							} else if(me.tempVal.saveType=="T") {
								me.tempVal = {};
							}

							me.simpApp_setModified(false);
							
							var note = nullToBlank(me.pageExpenceAppData["Note"]);
							me.setEditor(note);
							
							// 전결규정에서 담당업무를 셋팅한 경우 임시저장문서 로드시 적용 
							setChargeJob(me.pageExpenceAppData.ChargeJob);
						}
						else{
							Common.Error("<spring:message code='Cache.ACC_msg_error' />");
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />");
					}
				});
			},
			
			//html 폼 생성
			simpApp_makeEvidAddHTMLAll : function(){
				var me = this;
				
				for(var i = 0; i<me.pageExpenceAppEvidList.length; i++){
					var getItem = me.pageExpenceAppEvidList[i];
					var ProofCode = getItem.ProofCode;
					me.simpApp_makeEvidAddHTML(getItem, ProofCode);
				}
			},
			simpApp_makeCodeMap : function(List, name, dataField, labelField) {
				var me = this;
				if(List != null){
					//var evalStr = "me.pageSimpAppComboData['"+name+"Map'] = {}";
					//eval(evalStr);
					me.pageSimpAppComboData[name+"Map"] = {};
					for(var i = 0; i<List.length; i++){
						var item = List[i];
						//evalStr = "me.pageSimpAppComboData['"+name+"Map'][item[dataField]] = item";
						//eval(evalStr);
						me.pageSimpAppComboData[name+"Map"][item[dataField]] = item;
					}
				}
			},
			//폼의 콤보데이터 초기화
			simpApp_FormComboInit : function(){
				var me = this;
				var BriefStr = "";
				var BizTripItemStr = "";
				
				for(var formNm in me.pageSimpAppFormList){
					var formStr = me.pageSimpAppFormList[formNm]

					if(me.pageSimpAppComboData.BriefList != null){
						BriefStr = me.simpApp_ComboDataMake(me.pageSimpAppComboData.BriefList, "StandardBriefID", "StandardBriefName");
						formStr = formStr.replace("@@{BriefOptions}", BriefStr);
					}
					
					if(me.exchangeIsUse == "Y"){
						ExcNatStr = me.simpApp_ComboDataMake(me.pageSimpAppComboData.ExchangeNationList, "Code", "CodeName");
						formStr = formStr.replace("@@{ExchangeNationOptions}", ExcNatStr);
					}
					
					if((requestType == "BIZTRIP" || requestType == "OVERSEA") && me.pageSimpAppComboData.BizTripItemList != null){
						BizTripItemStr = me.simpApp_ComboDataMake(me.pageSimpAppComboData.BizTripItemList, "Code", "CodeName");
						formStr = formStr.replace("@@{BizTripItemOptions}", BizTripItemStr);
					}
					
					me.pageSimpAppFormList[formNm] = formStr
				}
				
				accountCtrl.getInfoName("simpApp_AddBriefSelect").html(BriefStr);
			},
			
			simpApp_ComboDataMake : function(cdList, codeField, nameField, attrField) {
				if(cdList==null){
					return;
				}
				if(codeField==null){
					codeField="Code"
				}
				if(nameField==null){
					nameField="CodeName"
				}
				var htmlStr = "<option value=''>"+ "<spring:message code='Cache.ACC_lbl_choice' />" +"</option>";	//선택
				for(var i = 0; i<cdList.length; i++){
					var getCd = cdList[i];
					if(getCd.IsUse == "Y"
						||getCd.IsUse == null
						||getCd.IsUse == ""){
						htmlStr = htmlStr + "<option value='"+ getCd[codeField] + "'";
						htmlStr = htmlStr + (attrField != undefined ? (" type=" + getCd[attrField] + " ") : ""); //기타 속성 값을 option에 추가할 경우
						htmlStr = htmlStr + ">" + getCd[nameField] + "</option>";
					}
				}
				return htmlStr;
			},
			
			//추가할 수 있는 카드목록 조회
			simpApp_evidInfoCall : function(ProofCode) {
				var me = this;
				
				if(ProofCode == undefined) {
					ProofCode = accountCtrl.getComboInfo("simpApp_inputProofCode").val();
					if(ProofCode == undefined) {
						ProofCode = "CorpCard";
					}
				}
				
				if(ProofCode != "CorpCard" && ProofCode != "Receipt") {
					return;
				}
				
				accountCtrl.getInfoName("simpApp_DeleteEvidBtn").hide();
				accountCtrl.getInfo("simpApp_Delete"+ProofCode+"Btn").show();
				
				var StartDate = accountCtrl.getInfo("simpApp_dateArea_St").val();
				var EndDate = accountCtrl.getInfo("simpApp_dateArea_Ed").val();
				StartDate = StartDate.replaceAll(".", "");
				EndDate = EndDate.replaceAll(".", "");

				var pageList = me["pageExpenceApp"+ProofCode+"List"];
				
				var addPageList = "";
				for(var i = 0; i < pageList.length; i++){
					var item = pageList[i];
					if(addPageList == ""){
						addPageList = item.ReceiptID;
					}else{
						addPageList = addPageList+","+item.ReceiptID;
					}
				}
				
				var ExpenceApplicationID = accountCtrl.getInfoStr("[name=SimpAppInputField][tag=ExpenceApplicationID]").val();
				
				var url = "/account/expenceApplication/getSimpCardInfoList.do";
				var CardID = accountCtrl.getComboInfo("simpApp_CardListSelect").val();
				
				if(ProofCode == "Receipt") { // 모바일영수증
					url = "/account/expenceApplication/getSimpReceiptInfoList.do";
				} else { // 그 외는 법인카드
					// 2022-09-21 법인카드인 경우 CardID가 없으면 AJAX 호출 X
					if (nullToBlank(CardID) == "") {
						return;	
					}
				}
				
				$.ajax({
					type:"POST",
						url : url,
					data:{
						pageNo : 1,
						pageSize : 200,
						ExpenceApplicationID : ExpenceApplicationID,
						addPageList : addPageList,
						StartDate : StartDate,
						EndDate : EndDate,
						CardID : CardID,
						UserCode: accountCtrl.getInfo('simpApp_Sub_UR_Code').val(),
					},
					success:function (data) {						
						if(data.result == "ok"){
							var list = data.list;
							var infoMap = data.infoMap;
							var page = data.page;
							
							me.pageEvidInfoList = list;
							me.pageEvidInfoMap = infoMap;

							accountCtrl.getInfoName("simpApp_evidListCount").html(page.listCount); //증빙 개수 표시
							
							me.simpApp_makeEvidInfoHTML(list, ProofCode);
						}
						else{
							Common.Error("<spring:message code='Cache.ACC_msg_error' />");	//오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />");
					}
				});
			},
			
			//증빙 정보 html 생성
			simpApp_makeEvidInfoHTML : function(inputList, ProofCode){
				var me = this;

				var arrCk = Array.isArray(inputList);
				if(!arrCk){
					return;
				}
				accountCtrl.getInfoName("simpApp_EvidInfoListArea").html("");
				var formStr = me.pageSimpAppFormList.EvidInfoForm;
				
				for(var i = 0; i<inputList.length; i++){
					var item = inputList[i];

					var valMap = {
							RequestType : requestType,
							KeyNo : nullToBlank(item.ReceiptID),
							ProofCode : ProofCode,
							
							ReceiptID : nullToBlank(item.ReceiptID),
							FileID : nullToBlank(item.FileID),
							
							StoreName : nullToBlank(item.StoreName).trim(),
							TotalAmount : toAmtFormat(nullToBlank(item.TotalAmount)),

							ProofDate : nullToBlank(item.ProofDate),
							ProofDateStr : nullToBlank(item.ProofDateStr),
							ProofTime : nullToBlank(item.ProofTime),
							ProofTimeStr : nullToBlank(item.ProofTimeStr),
							ClassName : (ProofCode == "Receipt" ? "mobile" : ""),
							
							//사용자가 모바일에서 입력한 정보 		
							UseDate : nullToBlank(item.UseDate), //모바일영수증은 직접입력, 법인카드는 I/F 데이터
							AccountCode : nullToBlank(item.AccountCode),
							AccountName : nullToBlank(item.AccountName),
							StandardBriefID : nullToBlank(item.StandardBriefID),
							StandardBriefName : nullToBlank(item.StandardBriefName),
							CostCenterCode : nullToBlank(item.CostCenterCode),
							CostCenterName : nullToBlank(item.CostCenterName),
							UsageText : nullToBlank(item.UsageText),
							Amount : nullToBlank(item.Amount)
					};
					
					var getForm = me.simpApp_htmlFormSetVal(formStr, valMap);
					getForm = me.simpApp_htmlFormDicTrans(getForm);
					
					accountCtrl.getInfoName("simpApp_EvidInfoListArea").append(getForm);
				}
			},
			
			//조회된 카드사용내역 클릭 이벤트
			simpApp_evidInfoClick  : function(obj, ProofCode, KeyNo){
				var me = this;

				var checkField = accountCtrl.getInfoStr("[tag=evidInfoCheck][proofcd="+ProofCode+"][keyno="+KeyNo+"]");
				var checked = checkField.is(":checked");
				if(checked){
					checkField[0].checked = false;
				}else{
					checkField[0].checked = true;
				}
			},
			
			//조회된 카드사용내역 더블클릭 이벤트
			simpApp_evidInfoDblClick : function(obj, ProofCode, KeyNo) {
				var me = this;
				var standardBriefID = me.pageEvidInfoMap[KeyNo].StandardBriefID;
				
				/* if(standardBriefID == undefined || standardBriefID == "") {
					Common.Warning("선택된 표준적요가 없습니다.");
					return;
				} */
				
				if(standardBriefID == undefined) {
					standardBriefID=''
				}
				
				me.simpApp_evidInfoClick(obj, ProofCode, KeyNo);
				me.simpApp_evidInfoAdd(standardBriefID);
			},
			
			//사용자 즐겨찾는 표준적요 버튼목록 생성
			simpApp_makeBtnArea : function(){
				var me = this;
				var list = me.pageSimpAppComboData.UserBriefList;
				var btnStr = '<a href="#" class="card_ea_btn" onclick="SimpleApplication<%=requestType%>.simpApp_evidInfoAdd(\'@@{id}\')">'
						+ '<span>@@{label}</span></a>\n';
				var setStr = "";
				for(var i = 0; i<list.length; i++){
					var item = list[i];
					var str = btnStr.replaceAll("@@{id}", item.StandardBriefID)
					str = str.replaceAll("@@{label}", item.StandardBriefName)
					accountCtrl.getInfoName("simpApp_AddBtnArea").append(str);
				}
			},
			
			simpApp_ckMaxExpNum : function(ProofCode){
				var me = this;
				var maxNum = 0;
				var KeyField = me.simpApp_getProofKey(ProofCode);
				
				for(var i = 0; i<me["pageExpenceApp"+ProofCode+"List"].length; i++){
					var item = me["pageExpenceApp"+ProofCode+"List"][i]
					if(maxNum < ckNaN(item[KeyField])){
						maxNum = ckNaN(item[KeyField]);
					}
				}
				return maxNum;
			}, 
			
			//증빙내역 추가
			simpApp_evidInfoAdd : function(StandardBriefID, ProofCode){
				var me = this;
				me.simpApp_setModified(true);
				
				var KeyField = me.simpApp_getProofKey(ProofCode);
				
				if(ProofCode != undefined) { //기타증빙, 개인카드
					var maxNum = 0;
					if(me.pageExpenceAppData.maxNum != null){
						maxNum = ckNaN(me.pageExpenceAppData.maxNum);
					}
					else{
						if(me["pageExpenceApp"+ProofCode+"List"].length==0){
							me.pageExpenceAppData.maxNum = 0;
						}
						else{
							me.pageExpenceAppData.maxNum = me.simpApp_ckMaxExpNum(ProofCode);
						}
						maxNum = ckNaN(me.pageExpenceAppData.maxNum);
					}
					var getItem = {
							IsNew : true
							, IsNewStr : "Y"
							, ProofCode : ProofCode
					};
					getItem[KeyField] = ++maxNum;
					me.pageExpenceAppData.maxNum = maxNum;
					
					var divCk = false;
					if(getItem.divList == null){
						divCk = true;
					}
					else if(getItem.divList.length == 0){
						divCk = true;
					}
					if(divCk){
						getItem.divList = [];
						var divItem = {
								ExpenceApplicationListID : ""
								, KeyNo : getItem[KeyField]
								, ProofCode : getItem.ProofCode
								
								, ExpenceApplicationDivID : ""
								, AccountCode :  ""
								, AccountName : ""
								, StandardBriefID : nullToBlank(getItem.StandardBriefID)
								, StandardBriefName : ""
								, CostCenterCode :  nullToBlank(accountCtrl.getInfo("simpApp_UserDefaultCCCode").val())
								, CostCenterName :  nullToBlank(accountCtrl.getInfo("simpApp_UserDefaultCCName").val())
								, IOCode : ""
								, IOName : ""
								, Amount : nullToBlank(getItem.TotalAmount)
								, UsageComment : ""
								, IsNew : true
								, Rownum : 0
						}
						getItem.divList.push(divItem);
						getItem.divSum = divItem.Amount;
					}		
					
					if(getItem.UsageComment == undefined || getItem.UsageComment == "") {
						getItem.UsageComment = nullToBlank(getItem.UsageText);
					}
					
					if(getItem.VendorNo == undefined || getItem.VendorNo == "") {
						getItem.VendorNo = sessionObj["UR_Code"];
						getItem.VendorName = sessionObj["UR_Name"];
					}
					
					if(getItem.CostCenterCode == undefined || getItem.CostCenterCode == "" || getItem.CostCenterName == undefined || getItem.CostCenterName == "") {
						getItem.CostCenterCode = accountCtrl.getInfo("simpApp_UserDefaultCCCode").val();
						getItem.CostCenterName = accountCtrl.getInfo("simpApp_UserDefaultCCName").val();
					}

					me.pageEvidAddMap[KeyField] = getItem;
					me.pageExpenceAppEvidList.push(getItem);
					me["pageExpenceApp"+ProofCode+"List"].push(getItem);
					
					me.simpApp_makeEvidAddHTML(getItem, ProofCode, null);
				} else { //법인카드, 모바일영수증
					var checkedList = accountCtrl.getInfoStr("[tag=evidInfoCheck]:checked");
					//select box로 선택 시 
					if(typeof(StandardBriefID) == "object") {
						var obj = StandardBriefID;
						StandardBriefID = $(obj).val();
						$(obj).val(""); 
					}
					for(var i = 0; i<checkedList.length; i++){
						var _StandardBriefID = StandardBriefID;
						var checkedItem = checkedList[i];
						var getId = checkedItem.getAttribute("keyno");
						
						if(me.pageEvidAddMap[getId] == null || me.pageEvidAddMap[getId] == ""){
							var getItem = me.pageEvidInfoMap[getId];
							
							if(_StandardBriefID=='*')
								_StandardBriefID = getItem.StandardBriefID;
							if(getItem.isIF=="Y"){
								var copyObj = objCopy(getItem);
								getItem.oriIFData = copyObj;
							}							
							
							getItem.StandardBriefID = _StandardBriefID;
							
							if(nullToBlank(getItem.Amount) == ""){
								getItem.Amount = getItem.TotalAmount;
							}

							if(nullToBlank(getItem.RepAmount) == "") {
								getItem.RepAmount = getItem.TotalAmount;
							}
							
							if(nullToBlank(getItem.TaxAmount) == "") {
								getItem.TaxAmount = 0;
							}
							
							var divCk = false;
							if(getItem.divList == null){
								divCk = true;
							}
							else if(getItem.divList.length == 0){
								divCk = true;
							}
							if(divCk){
								getItem.divList = [];
								var divItem = {
										ExpenceApplicationListID : ""
										, KeyNo : getId
										, ProofCode : getItem.ProofCode
										
										, ExpenceApplicationDivID : ""
										, AccountCode : nullToBlank(getItem.AccountCode)
										, AccountName : ""
										, StandardBriefID : nullToBlank(getItem.StandardBriefID)
										, StandardBriefName : ""
										, CostCenterCode :  nullToBlank(accountCtrl.getInfo("simpApp_UserDefaultCCCode").val())
										, CostCenterName :  nullToBlank(accountCtrl.getInfo("simpApp_UserDefaultCCName").val())
										, IOCode : ""
										, IOName : ""
										, Amount : nullToBlank(getItem.Amount)
										, UsageComment : nullToBlank(getItem.UsageText)
										, IsNew : true
										, Rownum : 0
								}
								getItem.divList.push(divItem);
								getItem.divSum = divItem.Amount;
							}
							
							if(getItem.UsageComment == undefined || getItem.UsageComment == "") {
								getItem.UsageComment = nullToBlank(getItem.UsageText);
							}
							
							if(getItem.VendorNo == undefined || getItem.VendorNo == "") {
								getItem.VendorNo = sessionObj["UR_Code"];
								getItem.VendorName = sessionObj["UR_Name"];
							}
							
							if(getItem.CostCenterCode == undefined || getItem.CostCenterCode == "" || getItem.CostCenterName == undefined || getItem.CostCenterName == "") {
								getItem.CostCenterCode = accountCtrl.getInfo("simpApp_UserDefaultCCCode").val();
								getItem.CostCenterName = accountCtrl.getInfo("simpApp_UserDefaultCCName").val();
							}
							
							me.pageEvidAddMap[KeyField] = getItem;
							me.pageExpenceAppEvidList.push(getItem);
							me["pageExpenceApp"+getItem.ProofCode+"List"].push(getItem);
							
							me.simpApp_makeEvidAddHTML(getItem, getItem.ProofCode, _StandardBriefID);
	
							if(getItem.ExpenceApplicationListID != null){
								var idx = accFindIdx(me.pageExpenceAppEvidDeletedList, "ExpenceApplicationListID", getItem.ExpenceApplicationListID);
								if(idx>=0){
									me.pageExpenceAppEvidDeletedList.splice(idx,1);
								}
							}
							
						}
					}
					me.simpApp_evidInfoCall();
					me.simpApp_pageAmtSet();
				}
				
				me.tempVal = {};
			},

			//일반비용신청 기타증빙 복사
			simpApp_evidInfoCopy : function(StandardBriefID, ProofCode) {
				var me = this;
				
				var checkedList = accountCtrl.getInfoStr("[tag=evidAddCheck]:checked");
				if(checkedList.length > 1){
					Common.Inform(Common.getDic("msg_SelectOnlyOne")); //1개 항목만 선택하세요.
					return;
				} else if(checkedList.length == 0) {
					Common.Inform(Common.getDic("ACC_msg_emptyCopy"+ProofCode)); //복사할 기타증빙을 선택하세요.
					return;
				} else {
					if(checkedList[0].getAttribute('proofcd') != ProofCode) {
						Common.Inform(Common.getDic("ACC_msg_noCopy"+ProofCode)); //기타증빙만 복사할 수 있습니다.
						return;
					}
				}
				
                // 체크된 증빙의 Idx 값으로 해당 증빙 obj 가져오기
				var copyKeyNo = checkedList[0].getAttribute("keyno");
				var copyIdx = accFindIdx(me["pageExpenceApp"+ProofCode+"List"], "KeyNo", copyKeyNo);
				var copyItem = me["pageExpenceApp"+ProofCode+"List"][copyIdx];
				
                // 복사할 증빙 obj 생성
				var addItem = JSON.parse(JSON.stringify(copyItem));
				
				var KeyField = me.simpApp_getProofKey(ProofCode);
				var maxNum;
				
                // 새로운 KeyNo 구하기
				if(me.pageExpenceAppData.maxNum != null){
					maxNum = ckNaN(me.pageExpenceAppData.maxNum);
				} else {
                    me.pageExpenceAppData.maxNum = (me["pageExpenceApp"+ProofCode+"List"].length == 0) ? 0 : me.simpApp_ckMaxExpNum(ProofCode);
					maxNum = ckNaN(me.pageExpenceAppData.maxNum);
				}
				
                // KeyNo 변경
				addItem[KeyField] = ++maxNum;
				addItem.KeyNo = maxNum;
				me.pageExpenceAppData.maxNum = maxNum;
				
				addItem.IsNew = true;
				addItem.IsNewStr = 'Y';
				addItem.ExpenceApplicationListID = "";
				
				const addItemFunc = function()
				{
	                // 증빙분할 KeyNo 변경
					for(var i = 0; i < addItem.divList.length; i++) {
						var addItemDivItem = addItem.divList[i];
						addItemDivItem.KeyNo = maxNum;
						
	                    // 관리항목 팝업 KeyNo 변경, CtrlCode 추가
	                    if(addItemDivItem.ReservedStr3_Div == undefined || Object.keys(addItemDivItem.ReservedStr3_Div).length == 0) continue;
	                    
						var ctrlType = Object.keys(addItemDivItem.ReservedStr3_Div);
	                    var ctrlList = "";
	                    
	                    for(var j = 0 ; j < ctrlType.length; j++) {
	                    	if(ctrlList.indexOf(ctrlType[j]) == -1) {
	    			        	if(j > 0) ctrlList += ",";
	    			    		ctrlList += ctrlType[j];
	    			    	}
	                    }
	                    
	    			    addItemDivItem.CtrlCode = ctrlList;
	                    
						if(!ctrlType.includes('D01', 'D02', 'D03', 'Z09', 'C07')) {
							continue;
						}
						
						for(var j = 0; j < ctrlType.length; j++) {
							var ctrlObj = addItemDivItem.ReservedStr3_Div[ctrlType[j]];
							if(me.isJsonString(ctrlObj) == true) {
								var jsonObj = JSON.parse(ctrlObj);
								var jsonObjItem = jsonObj[Object.keys(jsonObj)[0]];
	                            
	                            for(var z = 0; z < jsonObjItem.length; z++) {
	                                if(jsonObjItem[z].KeyNo != undefined) {
	                                    jsonObjItem[z].KeyNo = maxNum;
	                                }
	                            }
	                            
	                            addItemDivItem.ReservedStr3_Div[ctrlType[j]] = JSON.stringify(jsonObj);
							}
						}
					}
	                
	                //첨부파일 제외
					if(addItem.fileList) 		addItem.fileList = [];
					if(addItem.fileInfoList) 	addItem.fileInfoList = [];
					if(addItem.uploadFileList) 	delete addItem.uploadFileList;
					addItem.fileMaxNo = 0;
					
					//문서연결 제외
					if(addItem.docList)			addItem.docList = [];
					addItem.docMaxNo = 0;
					
					//문서연결 복사
					/* if(addItem.docList) {
						addItem.docList.forEach(function(e) {
							if('KeyNo' in e) e.KeyNo =  addItem.KeyNo;
						})
					} */
					
	                // 복사된 증빙 추가
					me.pageEvidAddMap[KeyField] = addItem;
					me.pageExpenceAppEvidList.push(addItem);
					me["pageExpenceApp"+ProofCode+"List"].push(addItem);
					
					var tempAddItem = JSON.parse(JSON.stringify(addItem));
					me.simpApp_makeEvidAddHTML(addItem, ProofCode, null);
    			    
					// 관리항목 후처리
					for(var z = 0; z < tempAddItem.divList.length; z++) {
						var tempAddItemDiv = tempAddItem.divList[z];
	                    if(tempAddItemDiv.ReservedStr3_Div == undefined || Object.keys(tempAddItemDiv.ReservedStr3_Div).length == 0) continue;
	    			    me.simApp_setCtrlDivHtml(tempAddItemDiv);
					}
				}
                
				if(addItem.divList.length > 1) {
	                // 증빙분할 복사 여부 확인
					Common.Confirm("<spring:message code='Cache.ACC_msg_copyAllDiv'/>", "Confirmation Dialog", function(result){
						addItemFunc();
						
						// 증빙분할 삭제
						if(!result) {
							accountCtrl.getInfoStr('[name=DivCheck][proofcd='+ProofCode+'][keyno='+maxNum+']').prop('checked', true);
							me.simpApp_delSelectAddDiv(ProofCode, maxNum);
						}
					});
				} else {
					addItemFunc();
				}
			},
			
			//json string check
			isJsonString : function(str) {
				try {
					JSON.parse(str);
				} catch (e) {
					return false;
				}
				return true;
			},
			
			//증빙내역 html 생성
			simpApp_makeEvidAddHTML : function(inputItem, ProofCode, inputBriefID){
				var me = this;
				var addFormTarget = (ProofCode == 'CorpCard' ? ProofCode : "Input");
				var formStr = me.pageSimpAppFormList[addFormTarget+"AddForm"];
				var KeyField = me.simpApp_getProofKey(ProofCode);

				inputItem.KeyNo = inputItem[KeyField];

				var valMap = {
						RequestType : requestType,
						
						KeyNo : nullToBlank(inputItem.KeyNo),
						ProofCode : nullToBlank(inputItem.ProofCode),
						
						TotalAmount : toAmtFormat(nullToBlank(inputItem.TotalAmount)),
						
						ProofDateStr : nullToBlank(inputItem.ProofDateStr),
						ProofTimeStr : nullToBlank(inputItem.ProofTimeStr),
						
						ReceiptID : nullToBlank(inputItem.ReceiptID),
						StoreName : nullToBlank(inputItem.StoreName).trim(),
						CardUID : nullToBlank(inputItem.CardUID),
						CardApproveNo : nullToBlank(inputItem.CardApproveNo),
						
						PersonalCardNo : inputItem.PersonalCardNo,
						PersonalCardNoView : inputItem.PersonalCardNoView,
						
						PhotoDateStr : nullToBlank(inputItem.PhotoDateStr),
						FullPath : nullToBlank(inputItem.FullPath),
						FileID : nullToBlank(inputItem.FileID),
						SavedName : nullToBlank(inputItem.SavedName),
						FileName : nullToBlank(inputItem.FileName),
						
						VendorNo : nullToBlank(inputItem.VendorNo),
						VendorName : nullToBlank(inputItem.VendorName),
						
						Currency : nullToBlank(inputItem.Currency),
						ExchangeRate : nullToBlank(inputItem.ExchangeRate) == "" ? 0 : parseInt(inputItem.ExchangeRate),
						LocalAmount : nullToBlank(inputItem.LocalAmount) == "" ? 0 : parseInt(inputItem.LocalAmount),

						//세부증빙 영역
						Rownum : nullToBlank(inputItem.divList[0].Rownum),
						AmountVal : toAmtFormat(nullToBlank(inputItem.divList[0].Amount)),
						UsageCommentVal : nullToBlank(inputItem.divList[0].UsageComment).replace(/<br>/gi, '\r\n'),
						AccountCode : nullToBlank(inputItem.divList[0].AccountCode),
						StandardBriefID : nullToBlank(inputItem.divList[0].StandardBriefID),
						CostCenterCode : nullToBlank(inputItem.divList[0].CostCenterCode),
						CostCenterName : nullToBlank(inputItem.divList[0].CostCenterName)
				}
				
				var DivInputAreaStr = me.simpApp_htmlFormSetVal(me.pageSimpAppFormList.DivInputAreaStr, valMap);
				valMap.DivInputArea = DivInputAreaStr;
				
				var getForm = me.simpApp_htmlFormSetVal(formStr, valMap);
				getForm = me.simpApp_htmlFormDicTrans(getForm);

				accountCtrl.getInfoName("simpApp_AddListArea").append(getForm);
				
				// 법인카드/모바일영수증만 ReceiptField show
				if(ProofCode == "CorpCard" || ProofCode == "Receipt") {
					accountCtrl.getInfoStr("p[name=ReceiptField][proofcd="+ProofCode+"][keyno="+inputItem.KeyNo+"]").show();
				} else {
					accountCtrl.getInfoStr("p[name=ReceiptField][proofcd="+ProofCode+"][keyno="+inputItem.KeyNo+"]").hide();
				}
				
				// 날짜 필드 생성
				me.simpApp_makeDateField(ProofCode, inputItem);
				
				// 환종 환율 추가
				if(me.exchangeIsUse == "Y" && ProofCode == "EtcEvid") {
					//입력 필드 show
					accountCtrl.getInfoStr("span[name=EtcEvidField][proofcd="+ProofCode+"][keyno="+inputItem.KeyNo+"]").show();
					
					//환종 KRW 기본값 세팅
					var CUField = accountCtrl.getInfoStr("[name=CurrencySelectField][proofcd="+ProofCode+"][keyno="+inputItem.KeyNo+"]");
					if (valMap.Currency == "") valMap.Currency = "KRW";
					CUField.val(valMap.Currency);
					me.simpApp_setFieldData(ProofCode, "Currency", inputItem.KeyNo, valMap.Currency);
					
					// 값 세팅 시 (임시저장, 상신) change 이벤트로 인하여 덮어씌워지지 않도록 처리
					if (CUField.val() != "KRW") {
						if (CUField.val() == valMap.Currency) {
							accountCtrl.getInfoStr("span[name=ExRateArea][proofcd="+ProofCode+"][keyno="+inputItem.KeyNo+"]").show();
						}
					}
				} else {
					accountCtrl.getInfoStr("span[name=EtcEvidField][proofcd="+ProofCode+"][keyno="+inputItem.KeyNo+"]").hide();
				}
				
				// 표준적요 값 세팅
				me.simpApp_BriefValSet(ProofCode, valMap.KeyNo, valMap.Rownum, valMap.StandardBriefID);
								
				// 세부 증빙이 2개 이상일 경우
				if(inputItem.divList != undefined && inputItem.divList.length > 1) {
					me.simpApp_makeInputDivHtmlAdd(inputItem);
				}
			
				var item = inputItem;
				me.tempVal.ProofCode = item.ProofCode;
				me.tempVal.KeyNo = item.KeyNo;
				
				if(item.docList != null){
					me.simpApp_LinkComp(item.docList, true);
				}
				
				item.fileMaxNo = 0;
				var setFileList = null;
				
				if(item.uploadFileList != null){
					setFileList = [].concat(item.uploadFileList);
				} else if(item.fileList != null) {
					setFileList = [].concat(item.fileList);
				}
				
				if(setFileList != null) {
					for(var y = 0; y<setFileList.length; y++){
						var fileItem = setFileList[y];
						item.fileMaxNo++;
						fileItem.fileNum = item.fileMaxNo;
					}
					me.simpApp_UploadHTML(setFileList, item.KeyNo, item.ProofCode, false);
				}
				
				var SBField = accountCtrl.getInfoStr("[name=BriefSelectField][proofcd="+valMap.ProofCode+"][keyno="+valMap.KeyNo+"]");
				if(SBField.val() == null) {
					SBField.val("");
				}
				
				if(requestType == "SELFDEVELOP") {
					accountCtrl.getInfoStr(".cnrl_bot").hide(); //증빙 분할 제거
				}
				if(requestType == "INVEST") {
					if(SBField.val() == "")
						SBField.val(accComm[requestType].pageExpenceFormInfo.StandardBriefInfo[0].item[0]);				
					SBField.attr("disabled", "disabled");
					SBField.siblings("button").remove();
					SBField.parents("div.searchBox02").removeClass("searchBox02");
					
					//accountCtrl.getInfoName("TotalAmountField").attr("disabled", "disabled");
					//accountCtrl.getInfoName("AmountField").attr("disabled", "disabled");
				}
				
				if(SBField[0]!=null){
					SBField[0].onchange();
				}
			},
			
			//증빙내역 삭제
			simpApp_deleteAddedItem : function(){
				var me = this;

				var checkedList = accountCtrl.getInfoStr("[tag=evidAddCheck]:checked");
				if(checkedList.length==0){
					Common.Inform("<spring:message code='Cache.ACC_msg_noselectdata' />");	//선택된 항목이 없습니다.
					return;
				}

		        Common.Confirm("<spring:message code='Cache.ACC_msg_ckDelete' />", "Confirmation Dialog", function(result){	//삭제하시겠습니까?
		       		if(result){

						me.simpApp_setModified(true);

						//var delList = [];
						for(var i = 0; i<checkedList.length; i++){
							var checkedItem = checkedList[i];
							var targetNm = checkedItem.getAttribute("targetnm");
							var KeyNo = checkedItem.getAttribute("keyno");
							var ProofCode = checkedItem.getAttribute("proofcd");
							var KeyField = me.simpApp_getProofKey(ProofCode);
							
							accountCtrl.getInfoName(targetNm).remove();
							var getItem = me.pageEvidAddMap[KeyNo];

							if(getItem.ExpenceApplicationListID != null){
								me.pageExpenceAppEvidDeletedList.push(me.pageEvidAddMap[KeyNo]);
							}
							delete me.pageEvidAddMap[KeyNo];
							
							var idx = accFindIdx(me.pageExpenceAppEvidList, KeyField, KeyNo );
							if(idx>=0){
								me.pageExpenceAppEvidList.splice(idx,1);
							}
							
							idx = accFindIdx(me["pageExpenceApp"+ProofCode+"List"], KeyField, KeyNo );
							if(idx>=0){
								me["pageExpenceApp"+ProofCode+"List"].splice(idx,1);
							}
						}
						me.simpApp_pageAmtSet();
						me.simpApp_evidInfoCall();
						
						if(accountCtrl.getInfo("simpApp_evidAddCheckAll").prop("checked")) { //전체선택해서 삭제했을 경우 전체선택 checkbox checked 해제
							accountCtrl.getInfo("simpApp_evidAddCheckAll").prop("checked", false);
						}
		       		}
		        });
			},
			
			//세부증빙(증빙분할) 추가
			simpApp_divAddOne : function(ProofCode, KeyNo) {				
				var me = this;
				var pageList = me["pageExpenceApp"+ProofCode+"List"];
				var KeyField = me.simpApp_getProofKey(ProofCode);
				
				var usageComment = accountCtrl.getInfoStr("[name=UsageCommentField][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum=0]").val()
				
				for(var i = 0; i<pageList.length; i++){
					var item = pageList[i];
					if(item.KeyNo == undefined) {
						item.KeyNo = item[KeyField];
					}
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
								, CostCenterCode :  nullToBlank(accountCtrl.getInfo("simpApp_UserDefaultCCCode").val())
								, CostCenterName :  nullToBlank(accountCtrl.getInfo("simpApp_UserDefaultCCName").val())
								, IOCode : ""
								, IOName : ""
								, Amount : 0
								, UsageComment : usageComment
								, IsNew : true
								, ExpenceApplicationListID : nullToBlank(item.ExpenceApplicationListID)
								, KeyNo : item.KeyNo
								, ProofCode : item.ProofCode
						}
						var maxRN = ckNaN(item.maxRowNum);
						maxRN++;
						item.maxRowNum = maxRN;
						divItem.Rownum = maxRN;
						
						item.divList.push(divItem);
						me.simpApp_makeInputDivHtmlAddOne(divItem, ProofCode, KeyNo)
					}
				}
			},
			
			//세부증빙부분의 html 추가
			simpApp_makeInputDivHtmlAdd : function(inputItem, isAll) {
				var me = this;
				var ProofCode = inputItem.ProofCode;
				var KeyNo = inputItem.KeyNo;
				var divArea = accountCtrl.getInfoStr("[name=DivAddArea][proofcd="+ProofCode+"][keyno="+KeyNo+"]");

				if(isAll){
					divArea.html("");
				}

				var formStr = me.pageSimpAppFormList["DivAddInputAreaStr"];
				var divList = inputItem.divList;
				
				for(var y = 0; y<divList.length; y++){
					var divItem = divList[y];
					
					if(y > 0) {
						if(nullToBlank(divItem.Amount) == ""){
							divItem.Amount = divItem.TotalAmount;
						}
						
						var valMap = {
								RequestType : requestType,
								ExpenceApplicationListID : nullToBlank(inputItem.ExpenceApplicationListID),
								KeyNo : nullToBlank(inputItem.KeyNo),
								ProofCode : nullToBlank(inputItem.ProofCode),
								Rownum : nullToBlank(divItem.Rownum),

								AmountVal : toAmtFormat(divItem.Amount),
								accCDVal : nullToBlank(divItem.AccountCode),
								accNMVal : nullToBlank(divItem.AccountName),
								CCCDVal : nullToBlank(divItem.CostCenterCode),
								CCNMVal : nullToBlank(divItem.CostCenterName),
								IOCDVal : nullToBlank(divItem.IOCode),
								IONMVal : nullToBlank(divItem.IOName),
								UsageCommentVal : nullToBlank(divItem.UsageComment).replace(/<br>/gi, '\r\n'),
								
								RequestType : requestType,
								
								SelfDevelopDetail : nullToBlank(divItem.SelfDevelopDetail)
						}
						
						var getForm = me.simpApp_htmlFormSetVal(formStr, valMap);
						getForm = me.simpApp_htmlFormDicTrans(getForm);
						divArea.append(getForm);

						me.simpApp_BriefValSet(ProofCode, inputItem.KeyNo, divItem.Rownum, divItem.StandardBriefID);
					}	
				}
				
				if(isUseIO == "N") {
			   		accountCtrl.getInfoName("noIOArea").hide();
			   	}
			   	if(isUseSB == "N") {
			   		accountCtrl.getInfoName("noSBArea").hide();
			   	} else {
			   		accountCtrl.getInfoName("AccBtn").remove();
			   		accountCtrl.getInfoName("DivAccNm").css("width", "116px");
			   	}
			   	if(isUseBD == "" || isUseBD == "N") {
			   		accountCtrl.getInfoName("noBDArea").hide();
			   	}
			},	
			
			//추가된 세부증빙 html 생성
			simpApp_makeInputDivHtmlAddOne : function(divItem, ProofCode, KeyNo) {
				var me = this;
				//DivAddArea
				//DivAddInputAreaStr

				var ProofCode = divItem.ProofCode;
				var KeyNo = divItem.KeyNo;
				var divArea = accountCtrl.getInfoStr("[name=DivAddArea][proofcd="+ProofCode+"][keyno="+KeyNo+"]")
				
				var formStr = me.pageSimpAppFormList["DivAddInputAreaStr"];

				if(nullToBlank(divItem.Amount) == ""){
					divItem.Amount = divItem.TotalAmount;
				}
				
				var valMap = {
						ExpenceApplicationListID : nullToBlank(divItem.ExpenceApplicationListID),
						KeyNo : nullToBlank(divItem.KeyNo),
						ProofCode : nullToBlank(divItem.ProofCode),
						Rownum : nullToBlank(divItem.Rownum),

						AmountVal : toAmtFormat(divItem.Amount),
						accCDVal : nullToBlank(divItem.AccountCode),
						accNMVal : nullToBlank(divItem.AccountName),
						CCCDVal : nullToBlank(divItem.CostCenterCode),
						CCNMVal : nullToBlank(divItem.CostCenterName),
						IOCDVal : nullToBlank(divItem.IOCode),
						IONMVal : nullToBlank(divItem.IOVal),
						UsageCommentVal : nullToBlank(divItem.UsageComment).replace(/<br>/gi, '\r\n'),
						
						RequestType : requestType,
						
						SelfDevelopDetail : nullToBlank(divItem.SelfDevelopDetail)
				}

				var getForm = me.simpApp_htmlFormSetVal(formStr, valMap);
				getForm = me.simpApp_htmlFormDicTrans(getForm);
				divArea.append(getForm);
								
				me.simpApp_BriefValSet(ProofCode, KeyNo, divItem.Rownum, divItem.StandardBriefID);
								
				if(isUseIO == "N") {
			   		accountCtrl.getInfoName("noIOArea").hide();
			   	}
			   	if(isUseSB == "N") {
			   		accountCtrl.getInfoName("noSBArea").hide();
			   	} else {
			   		accountCtrl.getInfoName("AccBtn").remove();
			   		accountCtrl.getInfoName("DivAccNm").css("width", "116px");
			   	}
			   	if(isUseBD == "" || isUseBD == "N") {
			   		accountCtrl.getInfoName("noBDArea").hide();
			   	}
			},
			
			//증빙분할 삭제
			simpApp_delAddDiv : function(ProofCode, KeyNo, Rownum) {
				var me = this;

				var pageList = me["pageExpenceApp"+ProofCode+"List"];
				var getItem = me.simpApp_findListItem(pageList, "KeyNo", KeyNo);
				var divList = getItem.divList;
				var idx = accFindIdx(divList, "Rownum", Rownum);
				if(idx >= 0){
					divList.splice(idx,1);
				}
				accountCtrl.getInfoStr("[name=DivRowDL][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").remove();
			},
			
			//증빙분할 선택 삭제
			simpApp_delSelectAddDiv : function(ProofCode, KeyNo) {
				var me = this;
				
				var targetRow = accountCtrl.getInfoStr('[name=DivCheck]:checked');
				if(targetRow.length==0){
					Common.Inform("<spring:message code='Cache.ACC_msg_noselectdata' />"); //선택된 항목이 없습니다.
					return;
				}
				
				var pageList = me["pageExpenceApp"+ProofCode+"List"];
				var getItem = me.simpApp_findListItem(pageList, "KeyNo", KeyNo);
				var divList = getItem.divList;
				
				var Rownum = '';
				for(var i = 0; i < targetRow.length; i++) {
					Rownum = String(targetRow.eq(i).attr('rownum'));
					var idx = accFindIdx(divList, "Rownum", Rownum);
					if(idx >= 0){
						//출장항목(일비, 유류비) 증빙분할 삭제 시 합계된 청구금액 빼기
					    if(divList[idx].ReservedStr2_Div != undefined) {
						    if('D02' in divList[idx].ReservedStr2_Div || 'D03' in divList[idx].ReservedStr2_Div || 'Z09' in divList[idx].ReservedStr2_Div) {
								var totalAmount = AmttoNumFormat(getItem.divSum);
								var delAmount = AmttoNumFormat(divList[idx].Amount);
								
								var tempTotalAmount = parseInt(totalAmount) - parseInt(delAmount);
								accountCtrl.getInfoStr("[name=TotalAmountField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").val(tempTotalAmount);
								me.simpApp_setFieldData(ProofCode, "TotalAmount", KeyNo, tempTotalAmount);
							}
					    }
						
						me.simpApp_setDivVal(ProofCode, KeyNo, Rownum, "Amount", 0);
						me.simpApp_pageAmtSet();
						
						divList.splice(idx,1);
						//getItem.maxRowNum = Number(getItem.maxRowNum) - 1;
						
						accountCtrl.getInfoStr("[name=DivRowDL][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").remove();
					}
				}
			},

			//날짜필드 생성
			simpApp_makeDateField : function(ProofCode, getItem) {
				var me = this;

				var pageList = me["pageExpenceApp"+ProofCode+"List"];
				var KeyField = me.simpApp_getProofKey(ProofCode);
				var KeyNo = getItem[KeyField];
				
				var dateInputList = accountCtrl.getInfoStr("[name=SimpAppDateField][proofcd="+ProofCode+"][keyno="+KeyNo+"]");

				for(var y = 0; y<dateInputList.length; y++){
					var input = dateInputList[y];
					var dataField = input.getAttribute("datafield");
					var areaID = input.id;
					var pd = getItem[dataField];
					
					makeDatepicker(areaID, areaID+"_Date", null, pd, null, 100);
					if(!isEmptyStr(pd)){
						me.simpApp_setFieldData(ProofCode, 'ProofDate', KeyNo, pd);
						me.simpApp_setFieldData(ProofCode, 'ProofDateStr', KeyNo, pd.substring(0, 4)+"."+pd.substring(4, 6)+"."+pd.substring(6, 8));
					}
				}
			},
			
			//날짜 변경 이벤트
			//현재 미사용
			simpApp_onDateChange : function(obj, KeyNo, ProofCode, field){
				var me = this;
				var pageList = me["pageExpenceApp"+ProofCode+"List"];
				var KeyField = me.simpApp_getProofKey(ProofCode);
				var objId = obj.id;
				var Strval = coviCtrl.getSimpleCalendar(objId);
				
				if(Strval != null) { // 예외처리 추가
					var val = Strval.replaceAll(".","");
					
					for(var i = 0; i<pageList.length; i++){
						var item = pageList[i]
						if(item[KeyField] == KeyNo){
							item[field] = val;
							item[field+"Str"] = Strval;
						}
					}
				}
				
				if(me.exchangeIsUse == "Y") {
					accountCtrl.getInfoStr("[name=CurrencySelectField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").trigger("onchange");
				}
			},
			
			simpApp_ComboChange : function(obj, type, ProofCode, KeyNo, Rownum) {
				var me = this;
				var val = obj.value;

				me.simpApp_setFieldData(ProofCode, type, KeyNo, val);
				
				var pageList = me["pageExpenceApp"+ProofCode+"List"];
				var KeyField = me.simpApp_getProofKey(ProofCode);
				
				var Item = me.simpApp_findListItem(pageList, KeyField, KeyNo);
				
				var BriefMap = me.pageSimpAppComboData.BriefMap
				var getMap = BriefMap[Item.StandardBriefID];
				if(getMap==null) {
					getMap = {};
				}

				//청구금액 disabled 제거
				accountCtrl.getInfoStr("[name=AmountField][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").removeAttr('disabled');
				
				if(type == "StandardBriefID"){
					me.simpApp_setDivVal(ProofCode, KeyNo, Rownum, type, val);
					me.simpApp_BriefValSet(ProofCode, KeyNo, Rownum, val);
					
					me.simpApp_pageAmtSet();

					if(requestType=="INVEST") {
						me.simpApp_InvestTargetSet(ProofCode, KeyNo, '');
					} else {
						var BizTripItemItem = me.pageSimpAppComboData.BizTripItemList.filter(function(o) {
							var Items = o.Reserved1;
							if(isEmptyStr(Items))return false;
							if(requestType == "OVERSEA"&&(o.Code=='Toll'||o.Code=='Fuel'||o.Code=='Park'))return;
							return $.inArray(val.toString(),Items.split(",")) > -1
						});
						
						//출장항목 선택가능항목 변경
						if(!jQuery.isEmptyObject(BizTripItemItem)&&BizTripItemItem.length>0){
							htmlStr = me.simpApp_ComboDataMake(BizTripItemItem, "Code", "CodeName",null,"Y");
							//D01 : 출장항목
							var D01Val = accountCtrl.getInfoStr("[code=D01][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").val();
							var D01Item = me.simpApp_findListItem(BizTripItemItem, 'Code', D01Val);
							accountCtrl.getInfoStr("[code=D01][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").html(htmlStr);
							if(jQuery.isEmptyObject(D01Item))
								D01Val = accountCtrl.getInfoStr("[code=D01][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"] option:first").val()
							
							accountCtrl.getInfoStr("[code=D01][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").val(D01Val).prop("selected", true);
							accountCtrl.getInfoStr("[code=D01][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").trigger("onchange");
						}	
					}
					
					if(Item.IsNew) { //신규추가일 때만 기본값 설정
						if(accountCtrl.getInfoStr("[code=E07][proofcd="+ProofCode+"][keyno="+KeyNo+"]").length>0)//인원수
							accountCtrl.getInfoStr("[code=E07][proofcd="+ProofCode+"][keyno="+KeyNo+"]").val(1);
						if(accountCtrl.getInfoStr("[code=E08][proofcd="+ProofCode+"][keyno="+KeyNo+"]").length>0)//참석자(내부)
							accountCtrl.getInfoStr("[code=E08][proofcd="+ProofCode+"][keyno="+KeyNo+"]").val(Common.getSession().USERNAME);
						accountCtrl._onSaveJson(me, null, "CtrlArea", ProofCode, KeyNo, Rownum);
					}
					
					//카카오 택시 데이터 연동 출발,도착,목적조회 , 신규추가일 경우만 
					/*if(ProofCode == "CorpCard" && Item.IsNewStr != "N"){
						var storeName = me.pageEvidAddMap[KeyNo].StoreName;
						var approveNo = me.pageEvidAddMap[KeyNo].CardApproveNo;
						if(accComm[requestType].kakaoTaxiInfo != undefined){
							var kakaoTInfo = accComm[requestType].kakaoTaxiInfo[approveNo];
							
							if(kakaoTInfo != undefined){
								var obj_1 = accountCtrl.getInfoStr("input[code='E01'][keyno='" + KeyNo + "'][rownum='" + Rownum + "']")[0];	//출발
					            var obj_2 = accountCtrl.getInfoStr("input[code='E02'][keyno='" + KeyNo + "'][rownum='" + Rownum + "']")[0];	//도착
					            
					            accountCtrl.getInfoStr("[code='E01'][keyno='" + KeyNo + "'][rownum='" + Rownum + "']").val(kakaoTInfo.departure_point);
					            accountCtrl.getInfoStr("[code='E02'][keyno='" + KeyNo + "'][rownum='" + Rownum + "']").val(kakaoTInfo.arrival_point);
					            
					            accountCtrl._onSaveJson(me, obj_1, "CtrlArea", ProofCode, KeyNo, Rownum);
					            accountCtrl._onSaveJson(me, obj_2, "CtrlArea", ProofCode, KeyNo, Rownum);
					            
					            accountCtrl.getInfoStr("[name=UsageCommentField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").val(kakaoTInfo.use_code);
								accountCtrl.getInfoStr("[name=UsageCommentField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").keyup();	
							}
						}
					}*/
				} 
				
				if(type=="InvestItem") {
					var getItem = me.simpApp_findListItem(me.pageSimpAppComboData.InvestItemList, 'Code', val);
					var desc = getItem.Reserved1;//경조항목 별 설명 
					desc = isEmptyStr(desc)?'':desc;
					
					if(desc != '') {
						accountCtrl.getInfoStr("[name=BriefDecField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").show();
						accountCtrl.getInfoStr("[name=BriefDecField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").html(desc);
					} else {
						accountCtrl.getInfoStr("[name=BriefDecField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").hide();
					}

					me.simpApp_InvestTargetSet(ProofCode, KeyNo, val); //경조항목 별 경조 대상 select box 바인딩
				}
				
				if(type=="InvestTarget") {
					if(nullToBlank(me.tempVal.saveType) == "" && me.tempVal.isLoad) {
						var getItem = me.simpApp_findListItem(me.pageSimpAppComboData.InvestTargetList, 'Code', val);
						var amount = getItem.ReservedInt;
						amount = isEmptyStr(amount)?0:amount;
						
						accountCtrl.getInfoStr("[name=TotalAmountField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").val(amount);
						accountCtrl.getInfoStr("[name=TotalAmountField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").keyup();
						me.simpApp_setFieldData(ProofCode, "TotalAmount", KeyNo, amount);
						
						accountCtrl.getInfoStr("[name=AmountField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").val(amount);
						accountCtrl.getInfoStr("[name=AmountField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").keyup();
						me.simpApp_setFieldData(ProofCode, "Amount", KeyNo, amount);

						me.simpApp_pageAmtSet();
					}
				}
				
				if(type=="BizTripItem") {
					var idx = accFindIdx(Item.divList, "Rownum", Rownum);
					var objTem = accountCtrl.getInfoStr("[tag=Amount][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]");

					var tempObj = $.extend(true, {}, Item); 

					accountCtrl._modifyItemJson(me, 'D02', KeyNo, Rownum, ProofCode,Item.divList[idx],"DEL");//유류비
					accountCtrl._modifyItemJson(me, 'D03', KeyNo, Rownum, ProofCode,Item.divList[idx],"DEL");//일비
					
					if(val == "Daily") {
						$(objTem).attr("disabled", "disabled"); //일비는 청구금액 수동입력 불가능
						Item = tempObj;
						accountCtrl._modifyItemJson(me, 'D03', KeyNo, Rownum, ProofCode,Item.divList[idx],"ADD");
					} else {
						$(objTem).removeAttr("disabled");
						
						if(val == "Fuel") {
							Item = tempObj;
							accountCtrl._modifyItemJson(me, 'D02', KeyNo, Rownum, ProofCode,Item.divList[idx],"ADD");
						}
					}

            		//증빙분할 관리항목 스타일 제거
	            	$("[name='DivAddArea'] dl[name='CtrlArea'][keyno='" + KeyNo + "'][rownum='" + Rownum + "']").css({'display':'inline-table', 'width':'auto', 'margin':'0px 20px 7px 0px !important'});
	            	$("[name='DivAddArea'] [name='CtrlArea'][keyno='" + KeyNo + "'][rownum='" + Rownum + "'] dt").css({'display':'table-cell', 'font-weight':'bold', 'vertical-align':'middle'});
	            	$("[name='DivAddArea'] [name='CtrlArea'][keyno='" + KeyNo + "'][rownum='" + Rownum + "'] dd").css({'display':'table-cell', 'vertical-align':'top'});
				}
				
				if(type=="Currency") {
					var exchangeRateField = accountCtrl.getInfoStr("[name=ExchangeRateField][proofcd="+ProofCode+"][keyno="+KeyNo+"]");
					var localAmountField = accountCtrl.getInfoStr("[name=LocalAmountField][proofcd="+ProofCode+"][keyno="+KeyNo+"]");
					
					if(val == "KRW") {
						accountCtrl.getInfoStr("span[name=ExRateArea][proofcd="+ProofCode+"][keyno="+KeyNo+"]").hide();
						
						// 환율 초기화
						exchangeRateField.val(0);
						exchangeRateField.trigger("onblur");
						// 현지금액 초기화
						localAmountField.val(0);
						localAmountField.trigger("onblur");
					} else {
						var proofDateField = accountCtrl.getInfoStr("[name=SimpAppDateField][proofcd="+ProofCode+"][keyno="+KeyNo+"]");
						var proofDate = proofDateField.find("input[type=text]").val();
						
						// 환율, 현지금액 영역 show
						accountCtrl.getInfoStr("span[name=ExRateArea][proofcd="+ProofCode+"][keyno="+KeyNo+"]").show();
						
						// 증빙날짜 비어있을 때 오늘날짜
						if(proofDate == "") {
							var today = new Date().format('yyyy.MM.dd');
							var todayHidden = new Date(today).format("MM/dd/yyyy");
							
							proofDateField.find("input[type=text]").val(today);
							proofDateField.find("input[type=hidden]").val(todayHidden);
							proofDateField.trigger("onchange");
							
							proofDate = today;
						}
						
						// 환율 적용
						var exchangeRate = accComm.getExchangeRate(proofDate, val);
						exchangeRateField.val(exchangeRate == "" || exchangeRate == undefined ? 0 : exchangeRate);
						exchangeRateField.trigger("onblur");
						
						// 현지금액 비어있을 때 0원
						if(localAmountField.val() == "") {
							localAmountField.val(0);
							localAmountField.trigger("onkeyup");
						}
					}
				}
			},

			//코스트센터 조회팝업
			simpApp_onCCSearch : function(ProofCode, KeyNo, Rownum){
				var me = this;
				me.tempVal.KeyNo = KeyNo;
				me.tempVal.ProofCode = ProofCode;
				me.tempVal.Rownum = Rownum;
				
				var popupID		=	"ccSearchPopup";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_costCenter'/>";	//코스트센터
				var popupName	=	"CostCenterSearchPopup";
				var callBack	=	"simpApp_SetCCVal";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	me.pageOpenerIDStr
								+	"includeAccount=N&"
								+	"companyCode="	+	me.CompanyCode	+ "&"
								+	"popupType="	+ (Common.getBaseConfig("IsUseIO") == "Y" ? "CC" : "") + 	"&"
								+	"callBackFunc="	+	callBack;
				Common.open(	"",popupID,popupTit,url,"600px","730px","iframe",true,null,null,true);
			},
			
			//코스트센터 값 세팅
			simpApp_SetCCVal : function(value){
				var me = this;
				if(value != null){
					me.simpApp_setModified(true);

					var ProofCode = me.tempVal.ProofCode;
					var KeyNo = me.tempVal.KeyNo;
					var Rownum = me.tempVal.Rownum;

					var keyIdx = accFindIdx(me.pageExpenceAppEvidList, "KeyNo", KeyNo);
					var rowIdx = accFindIdx(me.pageExpenceAppEvidList[keyIdx].divList, "Rownum", Rownum);
					var elementName = {
						CodeField : rowIdx > 0 ? "DivCCCd" : "CostCenterCode",
						NameField : rowIdx > 0 ? "DivCCNm" : "CostCenterName"
					};
					
					var cdField = accountCtrl.getInfoStr("[name="+elementName.CodeField+"][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]");
					var nmField = accountCtrl.getInfoStr("[name="+elementName.NameField+"][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]");
					me.simpApp_setDivVal(ProofCode, KeyNo, Rownum, "CostCenterCode", value.CostCenterCode);
					me.simpApp_setDivVal(ProofCode, KeyNo, Rownum, "CostCenterName", value.CostCenterName);

					cdField.val(value.CostCenterCode);
					nmField.val(value.CostCenterName);
					
					accountCtrl.getInfo("simpApp_CompanyCode").val(value.CompanyCode);								
					accountCtrl.getInfo("simpApp_CompanyName").text(value.CompanyName);
					
					me.tempVal = {};

					accountCtrl.refreshAXSelect("simpApp_defaultPayDateList");
				}
			},
			
			//IO 조회팝업
			simpApp_onIOSearch : function(ProofCode, KeyNo, Rownum){
				var me = this;
				var popupID		=	"ioSearchPopup";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_projectName' />";
				var popupName	=	"BaseCodeSearchPopup";
				var openerID	=	"SimpleApplication<%=requestType%>";
				var callBack	=	"simpApp_SetIOVal";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	me.pageOpenerIDStr
								+	"includeAccount=N&"
								+	"companyCode="	+	me.CompanyCode	+ "&"
								+	"codeGroup=IOCode&"
								+	"callBackFunc="	+	callBack;
				
				Common.open(	"",popupID,popupTit,url,"600px","650px","iframe",true,null,null,true);
			},
			
			//IO값 세팅
			simpApp_SetIOVal : function(value){
				var me = this;
				me.simpApp_setModified(true);
				
				var ProofCode = me.tempVal.ProofCode;
				var KeyNo = me.tempVal.KeyNo;
				var Rownum = me.tempVal.Rownum;
				
				if(value == null) {
					value = {};
					value.Code = "";
					value.CodeName = "";
				}
				
				var cdField = null;
				var nmField = null;
				if(ProofCode == undefined) {
					cdField = accountCtrl.getInfoStr("[name=SimpAppInputField][tag=IOCode]");
					nmField = accountCtrl.getInfoStr("[name=SimpAppInputField][tag=IOName]");
					for(var i = 0; i < me.pageExpenceAppEvidList.length; i++) {
						ProofCode = me.pageExpenceAppEvidList[i].ProofCode;
						KeyNo = me.pageExpenceAppEvidList[i].KeyNo;
						Rownum = coviCmn.isNull(me.pageExpenceAppEvidList[i].Rownum, 0);

						me.simpApp_setDivVal(ProofCode, KeyNo, Rownum, "IOCode", value.Code);
						me.simpApp_setDivVal(ProofCode, KeyNo, Rownum, "IOName", value.CodeName);
					}
					
					cdField.val(value.Code);
					nmField.html(value.CodeName);			

					if(requestType == "PROJECT") {
						me.simpApp_setProjectArea();
						accountCtrl.refreshAXSelect("simpApp_defaultPayDateList");
						accountCtrl.getInfo("simpApp_ApplicationTitle").val("[" + value.CodeName + "] " + setApplicationTitle());
					}					
				} else {
					cdField = accountCtrl.getInfoStr("[name=DivIOCd][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]");
					nmField = accountCtrl.getInfoStr("[name=DivIONM][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]");
					
					me.simpApp_setDivVal(ProofCode, KeyNo, Rownum, "IOCode", value.Code);
					me.simpApp_setDivVal(ProofCode, KeyNo, Rownum, "IOName", value.CodeName);
					
					cdField.val(value.Code);
					nmField.val(value.CodeName);
				}	
							
			},

			//계정과목 조회팝업
			simpApp_CallAccountPopup : function(ProofCode, KeyNo, Rownum){
				var me = this;
				me.tempVal.KeyNo = KeyNo;
				me.tempVal.ProofCode = ProofCode;
				me.tempVal.Rownum = Rownum;
				
				var popupID		=	"accountSearchPopup";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_account'/>";	//계정과목
				var popupName	=	"AccountSearchPopup";
				var callBack	=	"simpApp_SetAccVal";
				var openerID	=	"ExpenceApplication<%=requestType%>";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	me.pageOpenerIDStr
								+	"includeAccount=N&"
								+	"companyCode="	+	me.CompanyCode	+ "&"
								+	"callBackFunc="	+	callBack;
				Common.open(	"",popupID,popupTit,url,"740px","690px","iframe",true,null,null,true);
			},
			//계정과목 값 세팅
			simpApp_SetAccVal : function(info){
				var me = this;
				var KeyNo = me.tempVal.KeyNo;
				var ProofCode = me.tempVal.ProofCode;
				var Rownum = me.tempVal.Rownum;
				
				var cdField = accountCtrl.getInfoStr("[name=DivAccCd][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]");
				var nmField = accountCtrl.getInfoStr("[name=DivAccNm][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]");
				cdField.val(info.AccountCode);
				nmField.val(info.AccountName);
								
				me.simpApp_setDivVal(ProofCode, KeyNo, Rownum, "AccountCode", info.AccountCode);
				me.simpApp_setDivVal(ProofCode, KeyNo, Rownum, "AccountName", info.AccountName);
				
				me.tempVal = {};
			},

			//표준적요 조회팝업
			simpApp_CallBriefPopup : function(ProofCode, KeyNo, Rownum){
				var me = this;
				me.tempVal.KeyNo = KeyNo;
				me.tempVal.ProofCode = ProofCode;
				me.tempVal.Rownum = Rownum;
				
				var popupID		=	"standardBriefSearchPopup";
				var popupTit	=	"<spring:message code='Cache.ACC_standardBrief'/>";	//표준적요
				var popupName	=	"StandardBriefSearchPopup";
				var callBack	=	"simpApp_SetBriefVal";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
// 								+	"StandardBriefSearchStr="	+	Base64.utf8_to_b64(accComm[requestType].pageExpenceFormInfo.StandardBriefSearchStr)	+	"&"
								+	me.pageOpenerIDStr
								+	"includeAccount=N&"
								+	"companyCode="	+	me.CompanyCode	+ "&"
								+	"callBackFunc="	+	callBack;
				Common.open(	"",popupID,popupTit,url,"1000px","700px","iframe",true,null,null,true);
			},
			//표준적요 값 세팅
			simpApp_SetBriefVal : function(info){
				var me = this;
				var KeyNo = me.tempVal.KeyNo;
				var ProofCode = me.tempVal.ProofCode;
				var Rownum = me.tempVal.Rownum;
				var val = info.StandardBriefID;
				
				me.simpApp_BriefValSet(ProofCode, KeyNo, Rownum, val);
				
				me.simpApp_pageAmtSet();

				if(requestType!="INVEST") {
					var BizTripItemItem = me.pageSimpAppComboData.BizTripItemList.filter(function(o) {
						var Items = o.Reserved1;
						if(isEmptyStr(Items))return false;
						if(requestType == "OVERSEA"&&(o.Code=='Toll'||o.Code=='Fuel'||o.Code=='Park'))return;
						return $.inArray(val.toString(),Items.split(",")) > -1
					});
					
					//출장항목 선택가능항목 변경
					if(!jQuery.isEmptyObject(BizTripItemItem)&&BizTripItemItem.length>0){
						htmlStr = me.simpApp_ComboDataMake(BizTripItemItem, "Code", "CodeName",null,"Y");
						//D01 : 출장항목
						var D01Val = accountCtrl.getInfoStr("[code=D01][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").val();
						var D01Item = me.simpApp_findListItem(BizTripItemItem, 'Code', D01Val);
						accountCtrl.getInfoStr("[code=D01][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").html(htmlStr);
						if(jQuery.isEmptyObject(D01Item))
							D01Val = accountCtrl.getInfoStr("[code=D01][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"] option:first").val()
						
						accountCtrl.getInfoStr("[code=D01][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").val(D01Val).prop("selected", true);
						accountCtrl.getInfoStr("[code=D01][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").trigger("onchange");
					}
				}	
					
				me.tempVal = {};
			},
			
			simpApp_BriefValSet : function(ProofCode, KeyNo, Rownum, StandardBriefID) {
				var me = this;
				me.simpApp_setModified(true);
				
				var pageList = me["pageExpenceApp"+ProofCode+"List"];
				var KeyField = me.simpApp_getProofKey(ProofCode);

				var BriefMap = me.pageSimpAppComboData.BriefMap
				var getMap = BriefMap[StandardBriefID];
				if(getMap==null){
					getMap = {};
				}
				
				for(var i = 0; i<pageList.length; i++){
					var item = pageList[i];
					if(item[KeyField] == KeyNo){
						var divList = pageList[i].divList;
						for(var j = 0; j < divList.length; j++) {
							var divItem = divList[j];
							if(divItem.Rownum == Rownum){
								item["StandardBriefID"] = StandardBriefID;
								item["StandardBriefName"] = nullToBlank(getMap.StandardBriefName);
			
								item['TaxType'] = nullToBlank(getMap.TaxType);
								item['TaxCode'] = nullToBlank(getMap.TaxCode);
								item['AccountCode'] = nullToBlank(getMap.AccountCode);
								item['AccountName'] = nullToBlank(getMap.AccountName);
								item['StandardBriefDesc'] = nullToBlank(getMap.StandardBriefDesc);
								
								accountCtrl.getInfoStr("[name=BriefDecField][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").html(nullToBlank(getMap.StandardBriefDesc));
								if(nullToBlank(getMap.StandardBriefDesc) != '') {
									accountCtrl.getInfoStr("[name=BriefDecField][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").show();
								} else {
									accountCtrl.getInfoStr("[name=BriefDecField][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").hide();
								}
								accountCtrl._setCtrlField(me, nullToBlank(getMap.CtrlCode), KeyNo, Rownum, ProofCode,divItem);
								accountCtrl._onSaveJson(me, null, "CtrlArea", ProofCode, KeyNo, Rownum);
	
								divItem["StandardBriefID"] = StandardBriefID;
								divItem["StandardBriefName"] = nullToBlank(getMap.StandardBriefName);
		
								divItem['TaxType'] = nullToBlank(getMap.TaxType);
								divItem['TaxCode'] = nullToBlank(getMap.TaxCode);
								divItem['AccountCode'] = nullToBlank(getMap.AccountCode);
								divItem['AccountName'] = nullToBlank(getMap.AccountName);
								divItem['StandardBriefDesc'] = nullToBlank(getMap.StandardBriefDesc);
								
								accountCtrl.getInfoStr("[name=BriefSelectField][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").val(StandardBriefID);
								accountCtrl.getInfoStr("[name=DivAccCd][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").val(getMap.AccountCode);
								accountCtrl.getInfoStr("[name=DivAccNm][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").val(getMap.AccountName);
								
								me.simpApp_setDivVal(ProofCode, KeyNo, Rownum, "AccountCode", getMap.AccountCode);
								me.simpApp_setDivVal(ProofCode, KeyNo, Rownum, "AccountName", getMap.AccountName);
								me.simpApp_setDivVal(ProofCode, KeyNo, Rownum, "StandardBriefID", StandardBriefID);
								me.simpApp_setDivVal(ProofCode, KeyNo, Rownum, "StandardBriefName", getMap.StandardBriefName);
								
								me.pageEvidAddMap[KeyNo] = $.extend({}, item);
							}
						}
					}
				}				
			},
			
			simpApp_InvestTargetSet : function(ProofCode, KeyNo, InvestItem) {
				var me = this;

				var code = 'B01';//B01 : 경조항목
				var B01Val = accountCtrl.getInfoStr("[code="+code+"][proofcd="+ProofCode+"][keyno="+KeyNo+"]").val();
				var InvestItem = me.pageSimpAppComboData.InvestTargetList.filter(function(o) {
									return $.inArray(B01Val.toString(), o.Reserved1.split(",")) > -1
								});
				code = 'B02';//B02 : 경조대상 
				var B02Val = accountCtrl.getInfoStr("[code="+code+"][proofcd="+ProofCode+"][keyno="+KeyNo+"]").val();
				if(!jQuery.isEmptyObject(InvestItem)){
					htmlStr = me.simpApp_ComboDataMake(InvestItem, "Code", "CodeName",null,"Y");
					accountCtrl.getInfoStr("[code="+code+"][proofcd="+ProofCode+"][keyno="+KeyNo+"]").html(htmlStr);
					
					var Item = me.simpApp_findListItem(InvestItem, 'Code', B02Val);
					if(jQuery.isEmptyObject(Item))
						B02Val = accountCtrl.getInfoStr("[code="+code+"][proofcd="+ProofCode+"][keyno="+KeyNo+"] option:first").val()
					
					accountCtrl.getInfoStr("[code="+code+"][proofcd="+ProofCode+"][keyno="+KeyNo+"]").val(B02Val).prop("selected", true);
					accountCtrl.getInfoStr("[code="+code+"][proofcd="+ProofCode+"][keyno="+KeyNo+"]").trigger("onchange");
				}
			},
			
			//필드 데이터값 획득
			simpApp_getSimpAppField : function(){
				var me = this;
				
				var fieldList = accountCtrl.getInfoName("SimpAppInputField");
				var pageInfo = {};
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
				
				var pageEvidList = me.pageExpenceAppCorpCardList.concat(me.pageExpenceAppPrivateCardList);
				pageEvidList = pageEvidList.concat(me.pageExpenceAppEtcEvidList);
				pageEvidList = pageEvidList.concat(me.pageExpenceAppReceiptList);
				me.simpApp_getSimpAppEvidDate(pageEvidList);
				me.pageExpenceAppEvidList = pageEvidList;
				pageInfo.pageExpenceAppEvidList = pageEvidList;
				pageInfo.pageExpenceAppEvidDeletedList = me.pageExpenceAppEvidDeletedList;	
				
				for(var i = 0; i < pageInfo.pageExpenceAppEvidList.length; i++) {
					if(pageInfo.pageExpenceAppEvidList[i].PayDate != undefined) {
						pageInfo.pageExpenceAppEvidList[i].RealPayDate = pageInfo.pageExpenceAppEvidList[i].PayDate.replace(/\./gi, '');
					}
					pageInfo.pageExpenceAppEvidList[i].RealPayAmount = pageInfo.pageExpenceAppEvidList[i].divSum;
					
					if(pageInfo.IOCode != undefined && pageInfo.IOCode != "") {
						pageInfo.pageExpenceAppEvidList[i].divList[0].IOCode = pageInfo.IOCode;
						pageInfo.pageExpenceAppEvidList[i].divList[0].IOName = pageInfo.IOName;
					}
				}

				pageInfo.ApplicationType 		= "SC";
				pageInfo.ApplicationStatus 		= "T";
				pageInfo.RequestType			= requestType;
				
				pageInfo.ChargeJob = accComm.getJobFunctionData(requestType);
				
				pageInfo.ApprovalLine = JSON.stringify(getApvList(accountCtrl.getInfo("APVLIST_").val(), "TEMPSAVE"));
				pageInfo.FormName = accComm[requestType].pageExpenceFormInfo.FormName;
				
				// 지급일 타입 저장
				pageInfo.PayDateType = me.pageExpenceAppData.PayDateType;

				// 법인 저장				
				pageInfo.CompanyCode = me.CompanyCode;
				
				if(requestType == "BIZTRIP" || requestType == "OVERSEA") {
					pageInfo.BizTripRequestID = me.openParam.BizTripRequestID;
					pageInfo.BizTripNoteMap = encodeURI(JSON.stringify(me.BizTripNoteMap));
				}
				
				me.pageExpenceAppData = pageInfo;
				return pageInfo;
			},
			
			//증빙의 날자값 획득하여 list에 세팅
			simpApp_getSimpAppEvidDate : function(pageEvidList){
				var me = this;
				for(var i = 0; i<pageEvidList.length; i++){
					var evidItem = pageEvidList[i];
					var KeyField = me.simpApp_getProofKey(evidItem.ProofCode);
					
					var dateInputList = accountCtrl.getInfoStr("[name=SimpAppDateField][proofcd="+evidItem.ProofCode+"][keyno="+evidItem[KeyField]+"]");

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
			
			//데이터 저장
			simpApp_onSave : function(type){
				var me = this;
				
				if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
				
				me.simpApp_getSimpAppField();
				accComm.setDeadlineInfo();
				me.pageExpenceAppData.saveType = type;
				
				if(me.pageExpenceAppData.pageExpenceAppEvidList.length == 0){
					Common.Inform("<spring:message code='Cache.ACC_msg_noSaveData' />");	//저장할 데이터가 없습니다.
					return;
				}

				me.tempVal = {};
				
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

				me.pageExpenceAppData.body = body;
				me.pageExpenceAppData.images = images;
				me.pageExpenceAppData.backgroundImage = backgroundImage;

				if(isEmptyStr(me.pageExpenceAppData.ApplicationTitle)){
					Common.Inform("<spring:message code='Cache.ACC_msg_noTitle' />");	//제목을 입력해주세요.
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
					
					var totalAmt = ckNaN(accountCtrl.getInfoStr("[name=SimpAppInputField][tag=TotalAmt]").val());
					var reqAmt = ckNaN(accountCtrl.getInfoStr("[name=SimpAppInputField][tag=ReqAmt]").val());
					
					if(totalAmt < reqAmt){
						var msg = "<spring:message code='Cache.ACC_015' />";	//항목의 세부비용의 합계금액이 증빙금액보다 클 수 없습니다.
						Common.Inform(msg);
						return;
					}
					
					if(isEmptyStr(me.pageExpenceAppData.PayDateType)){
						Common.Inform("지급일을 선택하세요");	
						return;
					} else {
						me.simpApp_makePayDate(me.pageExpenceAppData.PayDateType); //무조건 지급일 다시 세팅하도록 수정
						
						if(me.pageExpenceAppData.PayDateType == "E" && isEmptyStr(accountCtrl.getInfo("simpApp_defaultPayDateInput_Date").val())) {
							Common.Inform("지급일 유형이 기타일 경우 지급일 입력이 필요합니다.");
							return;
						}
					}
					
					if(requestType == "PROJECT") { //프로젝트 비용신청일 경우 프로젝트 반드시 선택 필요
						if(isEmptyStr(me.pageExpenceAppData.IOCode)) {
							Common.Inform("신청 유형이 [프로젝트 비용 신청]일 경우 반드시 프로젝트를 선택하셔야 합니다.");
							return;
						}	
					} else if (requestType == "BIZTRIP"){ // 출장신청의 경우 해당 로직 제외
					} else { //프로젝트 경비가 아닐 경우 프로젝트 선택 해제 필요
						if(!isEmptyStr(me.pageExpenceAppData.IOCode)) {
							Common.Inform("프로젝트 비용 신청일 경우만 프로젝트 선택이 가능합니다.");
							return;
						}	
					}
					
					let evidMsgArr = new Array();
					var BriefMap = me.pageSimpAppComboData.BriefMap;
				   	for(var i=0; i<me.pageExpenceAppEvidList.length; i++){
				   		var evidItem = me.pageExpenceAppEvidList[i];
				   		var divList = evidItem.divList;
				   		
						var fileList = evidItem.fileList;
						var uploadFileList = evidItem.uploadFileList;
						var docList = evidItem.docList;
				   		
				   		// 마감일자 체크 주석처리
				   		/* if(accComm.accDeadlineCk(evidItem.ProofDate) == false){
				   			deadCk = true;
							var msg = "<spring:message code='Cache.ACC_044' />";	//경비 마감일이 넘긴 항목이 있습니다. 마감일은 @@{date}입니다.
							var deadline = accComm.getDeadlindDate();
							msg = msg.replace("@@{date}", deadline);
							Common.Inform(msg);
							return;
				   			break;
				   		} */
				   		
				   		if(isEmptyStr(evidItem.ProofDate)){
				   			const msg = "<spring:message code='Cache.ACC_lbl_proofDate' />"; //증빙일자
				   			evidMsgArr = me.simpApp_evidValidCheck(evidMsgArr, i, msg);
						} else if(evidItem.ProofDate > evidItem.PayDate) {
				   			const msg = "해당 증빙의 증빙일자가 지급희망일보다 큽니다.";
				   			evidMsgArr = me.simpApp_evidValidCheck(evidMsgArr, i, msg);
				   		}
				   		
				   		evidItem.PostingDate = evidItem.ProofDate;
				   		evidItem.PostingDateStr = evidItem.ProofDateStr;
				   		
						for (var j = 0; j < divList.length; j++) {
							var divItem = divList[j];
		   	  				divItem.ReservedStr2_Div = divList[j].ReservedStr2_Div == undefined || Object.keys(divList[j].ReservedStr2_Div).length == 0 ?
		   	  					divList[0].ReservedStr2_Div : divList[j].ReservedStr2_Div;
		   	  				divItem.ReservedStr3_Div = divList[j].ReservedStr3_Div == undefined || Object.keys(divList[j].ReservedStr3_Div).length == 0 ?
								divList[0].ReservedStr3_Div : divList[j].ReservedStr3_Div;

							if(isEmptyStr(divItem.CostCenterCode)){
					   			const msg = "<spring:message code='Cache.lbl_costCenter' />";	//코스트센터
					   			evidMsgArr = me.simpApp_evidValidCheck(evidMsgArr, i, msg);
							}
					   		
					   		if(isUseSB == "Y" && isEmptyStr(divItem.StandardBriefID)){
					   			const msg = "<spring:message code='Cache.ACC_standardBrief' />";	//표준적요
					   			evidMsgArr = me.simpApp_evidValidCheck(evidMsgArr, i, msg);
					   		}
							if(isEmptyStr(divItem.AccountCode)){
					   			const msg = "<spring:message code='Cache.ACC_lbl_account' />";	//계정과목
					   			evidMsgArr = me.simpApp_evidValidCheck(evidMsgArr, i, msg);
							}
					   		if(isEmptyStr(divItem.UsageComment)){
					   			const msg = "<spring:message code='Cache.ACC_useHistory' />";	//내역
					   			evidMsgArr = me.simpApp_evidValidCheck(evidMsgArr, i, msg);
					   		}					   		
					   		
					   		var getDivAmt = nullToBlank(divItem.Amount);
							getDivAmt = Number(AmttoNumFormat(getDivAmt));
							if(isNaN(getDivAmt) || getDivAmt == 0){
					   			const msg = "<spring:message code='Cache.ACC_lbl_amtValidateErr' />";	//청구금액이 0이거나 올바른 금액이 아닙니다.
					   			evidMsgArr = me.simpApp_evidValidCheck(evidMsgArr, i, msg);
							}
				   			
							var BriefInfo = BriefMap[divItem.StandardBriefID];
							if(BriefInfo) {
								if (BriefInfo.IsFile=='Y') {
									if ((!fileList || fileList.length == 0) && (!uploadFileList || uploadFileList.length == 0)) {
										const msg = "<spring:message code='Cache.ACC_msg_Require_AttchFile' />";	//파일첨부 필수입니다.
							   			evidMsgArr = me.simpApp_evidValidCheck(evidMsgArr, i, msg);
									}
								}
								
								if(BriefInfo.IsDocLink=='Y') {
									if (!docList || docList.length == 0) {
										const msg = "<spring:message code='Cache.ACC_msg_Require_DocLink' />";	//문서연결 필수입니다.
							   			evidMsgArr = me.simpApp_evidValidCheck(evidMsgArr, i, msg);
									}
								}
							}

							//관리항목 (ACC_CTRL) 필수체크 추가
		                    accountCtrl.getInfoStr("input[keyno=" + evidItem.KeyNo + "][rownum=" + divItem.Rownum + "][requiredVal=required][code],div[keyno=" + evidItem.KeyNo + "][rownum=" + divItem.Rownum + "][requiredVal=required][code],select[keyno=" + evidItem.KeyNo + "][rownum=" + divItem.Rownum + "][requiredVal=required][code]").each(function(idx, item){
		                        if($(item).val() == "" && $(item).attr("viewtype") != "Date"){
		                        	const msg = $(item).closest("dd").prev().text();
						   			evidMsgArr = me.simpApp_evidValidCheck(evidMsgArr, i, msg);
		                        }else{
		                            if($(item).find("input[code]").val() == ""){
										const msg = $(item).closest("dd").prev().text();
							   			evidMsgArr = me.simpApp_evidValidCheck(evidMsgArr, i, msg);
		                            }
		                        }
		                    });
						}
						
				   		if(ckNaN(AmttoNumFormat(evidItem.TotalAmount)) < evidItem.divSum){
							const msg = "<spring:message code='Cache.ACC_051' />";	//청구금액은 증빙금액보다 작아야합니다.
				   			evidMsgArr = me.simpApp_evidValidCheck(evidMsgArr, i, msg);
				   		}
				   		
						// 환율 관련 체크
						if (me.exchangeIsUse == "Y" && evidItem.ProofCode == "EtcEvid") {
							if (evidItem.Currency == "") {
								const msg = "<spring:message code='Cache.ACC_lbl_exchangeType' />";	//환종
					   			evidMsgArr = me.simpApp_evidValidCheck(evidMsgArr, i, msg);
							}
							
							if (evidItem.Currency != "KRW") {
						   		var getExchangeRate = nullToBlank(evidItem.ExchangeRate);
						   		getExchangeRate = Number(AmttoNumFormat(getExchangeRate));
						   		
								if (getExchangeRate == "" || isNaN(getExchangeRate) || getExchangeRate == 0) {
									const msg = "<spring:message code='Cache.ACC_lbl_exchangeRate' />";	//환율
						   			evidMsgArr = me.simpApp_evidValidCheck(evidMsgArr, i, msg);
								}
								
						   		var getLocalAmount = nullToBlank(evidItem.LocalAmount);
						   		getLocalAmount = Number(AmttoNumFormat(getLocalAmount));
						   		
								if (getLocalAmount == "" || isNaN(getLocalAmount) || getLocalAmount == 0) {
									const msg = "<spring:message code='Cache.ACC_lbl_localAmount' />";	//현지금액
						   			evidMsgArr = me.simpApp_evidValidCheck(evidMsgArr, i, msg);
								}
							}
						}
				   	}
				   	
				   	if(evidMsgArr.length > 0) {
				   		const msg = evidMsgArr.map((msgArr, idx) => {
			   				let returnMsg = "";
			   				const infoStr = "[" + Number(idx+1) + "번째 증빙] ";
			   				
			   				//중복 제거
			   				msgArr = Array.from(new Set(msgArr));
			   				
			   				const otherStr = msgArr.filter(m =>  m.includes(".")).join("\n");	//개별 메세지
			   				const emptyStr = msgArr.filter(m => !m.includes(".")).join(", ");	//비어있는 항목 메세지
			   				
			   				if(otherStr) returnMsg += otherStr + "\n";
			   				if(emptyStr) returnMsg += emptyStr + "<spring:message code='Cache.ACC_msg_required' />" + "\n";	//이(가) 입력되지 않은 항목이 있습니다.
			   				
			   				return infoStr + returnMsg;
			   			}).filter(msgArr => msgArr.length > 0).join("\n");
				   		
				   		Common.Warning(msg);
				   		return;
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
				}else{ // 임시저장 type == 'T'
					if(!isEmptyStr(me.pageExpenceAppData.PayDateType)) me.simpApp_makePayDate(me.pageExpenceAppData.PayDateType); //무조건 지급일 다시 세팅하도록 수정
				}
			   	if(type=="S" && !me.simpApp_callDuplicateCheck(me.pageExpenceAppData)){
					Common.Warning("<spring:message code='Cache.CPEAccounting_DuplicateDoc' />");
			   		return false;
			   	}

			   	var confirmMsg = "<spring:message code='Cache.ACC_isSaveCk' />";	//저장하시겠습니까?
			   	if(type=="S"){
			   		confirmMsg = "<spring:message code='Cache.ACC_isAppCk' />";		//신청하시겠습니까?
			   	}
			   	
			   	if(type != 'T' && me.pageExpenceAppEvidList[0].PayDate < new Date().format("yyyyMMdd")) {
			   		Common.Confirm("<spring:message code='Cache.ACC_PayDateChk' />", "Confirmation Dialog", function(result){
						if(result){
							Common.Confirm(confirmMsg, "Confirmation Dialog", function(result){
								if(result){
								    me.simpApp_IsSaveStatus(type);
									me.simpApp_callExpAppSaveAjax(me.pageExpenceAppData);
								}
							});
						}
					});
			   	} else {
			   		Common.Confirm(confirmMsg, "Confirmation Dialog", function(result){
						if(result){
						    me.simpApp_IsSaveStatus(type);
							me.simpApp_callExpAppSaveAjax(me.pageExpenceAppData);
						}
					});
			   	}
			},
			
			simpApp_IsSaveStatus : function (type){ //validation Check후 상태값 변경하도록함. 
			    var me = this;
				if(type=="T"){
					me.pageExpenceAppData.IsTempSave = "Y"
					me.pageExpenceAppData.ApplicationStatus = 'T'
					me.tempVal.saveType="T";
				} else if(type=="E"){
					me.pageExpenceAppData.IsTempSave = "N"
					me.pageExpenceAppData.ApplicationStatus = 'E'
					me.tempVal.saveType="E";
				} else{
					me.pageExpenceAppData.IsTempSave = "Y"
					me.pageExpenceAppData.ApplicationStatus = 'T'
					me.tempVal.saveType="S";
				}
			},
			
			simpApp_evidValidCheck : function(evidMsgArr, idx, msg) {
				const evid = document.querySelectorAll("ul[name=simpApp_AddListArea] > li");
				
				if(evidMsgArr.length == 0) {
					// 전체 background 초기화
					evid.forEach(ele => ele.querySelector("div[class=cnrl_top]").style.removeProperty('background'));
					// 첫 번째 증빙 위치로 스크롤 이동
					evid[idx].scrollIntoView(false);
				}
				
				// validation Check 에 걸린 증빙의 배경색 변경
				evid[idx].querySelector("div[class=cnrl_top]").style.background = "#fff3f7";
				
				// 메세지 배열에 추가
				if(!evidMsgArr[idx]) evidMsgArr[idx] = new Array();
				evidMsgArr[idx].push(msg);
				
	   			return evidMsgArr;
			},
			
			//중복기안 체크
			simpApp_callDuplicateCheck : function(data) {
				var returnVal;
				$.ajax({
					type:"POST",
					url:"/account/expenceApplication/ExpenceApplicationDuplicateCheck.do",
					async:false,
					data:{
						duplObj : JSON.stringify(data),
					},
					success:function (data) {
						if(data.status == "SUCCESS" && data.duplChk == 'N'){
							returnVal = true;
						}else{
							returnVal = false;
						}
					},
					error:function (error){
						returnVal = false;
						Common.Warning(error);
					}
				});
				
				return returnVal;
			},

			//저장로직 호출
			simpApp_callExpAppSaveAjax : function(data, isBK){
				var me = this;
				var ExpObj = data;
				ExpObj.Sub_UR_Name = Sub_UR_Name;
				
				$.ajax({
					type:"POST",
						url:"/account/expenceApplication/saveExpenceApplication.do",
					data:{
						saveObj : JSON.stringify(ExpObj),
					},
					success:function (data) {
						if(data.result == "ok"){

							me.simpApp_dataInit()
							me.simpApp_evidInfoCall();
							
							var fieldList =  accountCtrl.getInfoName("SimpAppInputField");
						   	for(var i=0;i<fieldList.length; i++){
						   		var field = fieldList[i];
						   		var tag = field.getAttribute("tag")
								var fieldType = field.tagName;
								if(fieldType=="INPUT"){
									field.value = nullToBlank(me.pageExpenceAppData[tag]);
								} else if(fieldType=="LABEL"){
									field.innerHTML = nullToBlank(me.pageExpenceAppData[tag]);
								}
						   		
						   	}
						   	accountCtrl.getInfo("simpApp_CCLabel").html(nullToBlank(me.pageExpenceAppData["CostCenterName"]));
						   	accountCtrl.getInfo("simpApp_IOLabel").html(nullToBlank(me.pageExpenceAppData["IOName"]));
						   	
							var ExpAppID = data.getSavedKey;
							
							if(me.tempVal.saveType!="T"){
								me.tempVal.saveData = data;
							} else {
								Common.Inform("<spring:message code='Cache.ACC_msg_saveComp' />"); //저장되었습니다
							}
							
							me.simpApp_searchData(ExpAppID);
							
						}
						else if(data.result == "D"){
							
							var duplObj = data.duplObj;
							var msg = "<spring:message code='Cache.ACC_msg_isExpAppDupl' />";	//이미 저장되어 있는 증빙이 추가되어있습니다.
							if(duplObj.CCCnt>0){
								msg += "<br>" + "<spring:message code='Cache.ACC_lbl_corpCard' />";
								msg += ": " + duplObj.CCCnt + "<spring:message code='Cache.lbl_DocCount' />";
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
						Common.Error("<spring:message code='Cache.ACC_msg_error' />");
					}
				});
			},
			
			
			//법인카드/모바일 영수증 조회
			simpApp_billClick  : function(ProofCode, ReceiptID, FileID){
				var me = this;
				if(ProofCode == "CorpCard") {
					accComm.accCardAppClick(ReceiptID, me.pageOpenerIDStr);
				} else if(ProofCode == "Receipt") {
					me.simpApp_MobileAppClick(FileID);
				}
			},
			
			simpApp_MobileAppClick : function(FileID){
				var me = this;
				
				var popupID		=	"fileViewPopup";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_receiptPopup'/>";	//영수증 보기
				var popupName	=	"FileViewPopup";
				var callBack	=	"simpApp_ZoomMobileAppClick";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	"fileID="	+	FileID	+	"&"
								+	me.pageOpenerIDStr
								+	"callBackFunc="	+	callBack;
				Common.open(	"",popupID,popupTit,url,"340px","500px","iframe",true,null,null,true);
			},
			
			simpApp_ZoomMobileAppClick : function(info){
				var me = this;
				
				var popupID		=	"fileViewPopupZoom";
				var popupTit	=	"<spring:message code='Cache.ACC_lbl_receiptPopup'/>";	//영수증 보기
				var popupName	=	"FileViewPopup";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	"fileID="	+	info.FileID		+	"&"		
								+	me.pageOpenerIDStr				+	"&"	
								+	"zoom="			+	"Y"		
				Common.open(	"",popupID,popupTit,url,"490px","700px","iframe",true,null,null,true);
			},

			//입력창 변경시 이벤트
			simpApp_onInputFieldChange : function(obj, ProofCode, fieldNm) {
				var me = this; 
				me.simpApp_setModified(true);
				
				var getName = obj.name;
				var val = obj.value;
				var KeyNo = obj.getAttribute("keyno");
				
				var Rownum = 0;
				var pageList = me["pageExpenceApp"+ProofCode+"List"];
				$(pageList).each(function(i, obj) {
				    if(obj.KeyNo == KeyNo)
				    	Rownum = obj.divList[0].Rownum;
				});

				if(getName == "AmountField"
						|| getName == "TotalAmountField"
						|| getName == "TaxAmountField"
						|| getName == "ExchangeRateField"
						|| getName == "LocalAmountField"){
					val = val.replace(/[^0-9\-,.]/g, "");
					var numVal = ckNaN(AmttoNumFormat(val))
					if(numVal>99999999999){
						numVal = 99999999999;
					}
					val = Number(AmttoNumFormat(val));
					
					accountCtrl.getInfoStr("[name="+getName+"][proofcd="+ProofCode+"][keyno="+KeyNo+"]").val(toAmtFormat(numVal));
					if(getName=="TotalAmountField"){
						accountCtrl.getInfoStr("[name=AmountField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").val(toAmtFormat(numVal));
						me.simpApp_setDivVal(ProofCode, KeyNo, Rownum, "Amount", val);
					}
					
					if(me.exchangeIsUse == "Y" && (getName=="ExchangeRateField" || getName=="LocalAmountField")){
						var calName = (getName == "ExchangeRateField" ? "LocalAmountField" : "ExchangeRateField");
						var calVal =  Number(AmttoNumFormat(accountCtrl.getInfoStr("[name="+calName+"][proofcd="+ProofCode+"][keyno="+KeyNo+"]").val()));
						var curType = accountCtrl.getInfoStr("[name=CurrencySelectField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").val();
						var totalAmt = 0;
						
						//입력값 소수점 두자리  처리
						if (val % 1 > 0) { val = val.toFixed(2); }
						
						accountCtrl.getInfoStr("[name="+getName+"][proofcd="+ProofCode+"][keyno="+KeyNo+"]").val(toAmtFormat(val));
						me.simpApp_setDivVal(ProofCode, KeyNo, Rownum, getName, val);
						
						//증빙합계 소수점 두자리  처리
						totalAmt = val*calVal;
						//엔화 예외처리
						if (curType == "JPY") { totalAmt = totalAmt / 100 };
						if (totalAmt % 1 > 0) { totalAmt = totalAmt.toFixed(2); }
						
						accountCtrl.getInfoStr("[name=TotalAmountField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").val(toAmtFormat(totalAmt));
						accountCtrl.getInfoStr("[name=TotalAmountField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").trigger("onblur");
					}
				}

				me.simpApp_setFieldData(ProofCode, fieldNm, KeyNo, val);
				me.simpApp_pageAmtSet();
			},
			
			simpApp_divInputChange : function(obj, ProofCode, KeyNo, Rownum, jsonVal, type) {
				var me = this;
				var field;
				var val;
				if(jsonVal != undefined) {
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
				
				me.simpApp_setDivVal(ProofCode, KeyNo, Rownum, field, val);
				me.simpApp_pageAmtSet();
			},
			
			//필드에 값 세팅
			simpApp_setFieldData : function(ProofCode, fieldNm, KeyNo, Val){
				var me = this;
				
				var pageList = me["pageExpenceApp"+ProofCode+"List"];
				var getItem = me.simpApp_findListItem(pageList, "KeyNo", KeyNo);
				getItem[fieldNm] = Val;
				me.pageEvidAddMap[KeyNo] = $.extend({}, getItem);
			},
			
			//세부증빙 list에 값 세팅
			simpApp_setDivVal : function(ProofCode, KeyNo, Rownum, fieldNm, val) {
				var me = this;
				
				var pageList = me["pageExpenceApp"+ProofCode+"List"];
				var getItem = me.simpApp_findListItem(pageList, "KeyNo", KeyNo);
				if(!isEmptyStr(getItem.KeyNo)){
					var divItem = me.simpApp_findListItem(getItem.divList, "Rownum", Rownum);
					divItem[fieldNm] = val;
					if(fieldNm == "Amount") {
						getItem.Amount = val;
						getItem.divSum = 0;
						for(var i = 0; i < getItem.divList.length; i++) {
							getItem.divSum += Number(AmttoNumFormat(getItem.divList[i].Amount));
						}
					}
				}
				me.pageEvidAddMap[KeyNo] = $.extend({}, getItem);
			},
			
			//합계금액 세팅
			simpApp_pageAmtSet : function() {
				var me= this;
				
				accComm.accPageAmtSet(me.pageExpenceAppEvidList, "simpApp_");
				
				accountCtrl.refreshAXSelect("simpApp_defaultPayDateList");
				accountCtrl.refreshAXSelect("simpApp_inputProofCode");
			},
			
			simpApp_htmlFormSetVal : function(inputStr, replaceMap){
				return accComm.accHtmlFormSetVal(inputStr, replaceMap);
			},
			simpApp_htmlFormDicTrans : function(inputStr){
				return accComm.accHtmlFormDicTrans(inputStr);
			},

			//증빙별 고유 키
			simpApp_getProofKey : function(ProofCode){
				var KeyField = "";
				if(ProofCode=='CorpCard'){
					KeyField = "CardUID";
				}else if(ProofCode=='PrivateCard'){
					KeyField = "ExpAppPrivID";
				}else if(ProofCode=='EtcEvid'){
					KeyField = "ExpAppEtcID";
				}else if(ProofCode=='Receipt'){
					KeyField = "ReceiptID";
				}
				return KeyField
			},

			//결재용 뷰 폼 생성
			simpApp_makeViewForm : function (){
				var me = this;
				var proofCode = "";
				var tableStr = ""; 				

				accountCtrl.getInfoName("simpApp_hiddenViewForm").html("");
				accountCtrl.getInfoName("simpApp_hiddenViewForm").html(accountCtrl.getInfo("simpApp_TotalWrap")[0].outerHTML);
				
				for(var i = 0; i<me.pageExpenceAppEvidList.length; i++){
					var getItem = me.pageExpenceAppEvidList[i];
					var ProofCode = getItem.ProofCode;

					var formStr = me.pageSimpAppFormList[ProofCode+"ViewForm"];

					var addUsageComment = "";
					
					var divValMap = {
							AccountName : nullToBlank(getItem.AccountName),
							StandardBriefName : nullToBlank(getItem.StandardBriefName),
							CostCenterName : nullToBlank(getItem.CostCenterName),
							IOName : nullToBlank(getItem.IOName),
							UsageComment : nullToBlank(getItem.UsageComment),
							AddUsageComment : addUsageComment, //TODO: 부가적요 표시하기
							DivAmount : toAmtFormat(getItem.Amount)
					}
					var htmlDivFormStr = me.pageSimpAppFormList.DivForm;
					htmlDivFormStr = me.simpApp_htmlFormSetVal(htmlDivFormStr, divValMap);

					var valMap = {
							ViewKeyNo : nullToBlank(getItem.ViewKeyNo),
							ProofCode : nullToBlank(getItem.ProofCode),
							
							TotalAmount : toAmtFormat(nullToBlank(getItem.TotalAmount)),
							RepAmount : toAmtFormat(nullToBlank(getItem.RepAmount)),
							TaxAmount : toAmtFormat(nullToBlank(getItem.TaxAmount)),
							SupplyCost : nullToBlank(getItem.SupplyCost),
							Tax : nullToBlank(getItem.Tax),
							
							ProofDate : nullToBlank(getItem.ProofDateStr),
							PostingDate : nullToBlank(getItem.PostingDateStr),
							PayDate : nullToBlank(getItem.PayDateStr),
							ProofTime : nullToBlank(getItem.ProofTimeStr),
							
							StoreName : nullToBlank(getItem.StoreName).trim(),
							CardUID : nullToBlank(getItem.CardUID),
							CardApproveNo : nullToBlank(getItem.CardApproveNo),
							
							ReceiptID : nullToBlank(getItem.ReceiptID),
							
							TaxCodeNm : nullToBlank(getItem.TaxCodeName),
							TaxTypeNm : nullToBlank(getItem.TaxTypeName),
							
							VendorNo : nullToBlank(getItem.VendorNo),
							VendorName : nullToBlank(getItem.VendorName),
							
							pageNm : "SimpleApplication<%=requestType%>",
					}
					valMap.rowNum = i+1;
					valMap.rowspan = 1;
					valMap.divApvArea = htmlDivFormStr;
					valMap.divApvArea2 = '';

					var getForm = me.simpApp_htmlFormSetVal(formStr, valMap);
					getForm = me.simpApp_htmlFormDicTrans(getForm);
					
					if(proofCode != getItem.ProofCode) {
						if(proofCode != "") {
							tableStr += '</tbody></table>';
						}
						proofCode = getItem.ProofCode;
						
						var title = Common.getDic('ACC_lbl_' + proofCode + 'UseInfo');
						tableStr += '<p class="taw_top_sub_title">'+title+'</p>'
									+ '<table class="acstatus_wrap">'
									+ '<tbody>'
									+ getForm
					} else {
						tableStr += getForm;
					}
				}

				accountCtrl.getInfoName("simpApp_hiddenViewForm").append(tableStr);
				
				proofCode = "";
				for(var i = 0; i<me.pageExpenceAppEvidList.length; i++){
					var getItem = me.pageExpenceAppEvidList[i];
					
					if(proofCode != getItem.ProofCode) {
						proofCode = getItem.ProofCode;
					} else {
						accountCtrl.getInfoStr("tr[name=headerArea][viewkeyno="+getItem.ViewKeyNo+"]").remove();
					}
						
					me.simpApp_makeHtmlChkColspan(accountCtrl.getInfoStr("[name=evidItemAreaApv][viewkeyno="+getItem.ViewKeyNo+"]"));
					
					if((getItem.docList == null && getItem.fileList == null) 
							|| ((getItem.docList != null && getItem.docList.length == 0) && (getItem.fileList != null && getItem.fileList.length == 0))) {
						accountCtrl.getInfoStr("[name=fileDocAreaApv][viewkeyno=" + getItem.ViewKeyNo + "]").remove();
					} else {
						accountCtrl.getInfoStr("[name=evidItemAreaApv][viewkeyno=" + getItem.ViewKeyNo + "]").find("td").each(function(i, obj) { 
							if($(obj).attr("rowspan") != undefined) { 
								$(obj).attr("rowspan", Number($(obj).attr("rowspan"))+1) 
							} 
						});

						if(getItem.docList != null){
							for(var y = 0; y < getItem.docList.length; y++){
								var getDoc = getItem.docList[y];
								var str = 						
									"<a href='javascript:void(0);' class='btn_File ico_doc' style='margin-right: 10px;' onClick=\"SimpleApplication<%=requestType%>.simpApp_LinkOpen('"
											+ getDoc.ProcessID+"', '" + getDoc.forminstanceID + "', '" + getDoc.bstored + "', '" + getDoc.BusinessData2 + "')\">"
											+ nullToStr(getDoc.Subject, "("+"<spring:message code='Cache.ACC_lbl_noTitle' />"+")")+"</a>";			
									var getStr = accountCtrl.getInfoStr("[name=DocViewArea][proofcode="+getItem.ProofCode+"][viewkeyno="+getItem.ViewKeyNo+"]").append(str);
							}
						}
						
						if(getItem.fileList != null){
							for(var y = 0; y < getItem.fileList.length; y++){
								var fileInfo = getItem.fileList[y];
								var str = 						
									"<a href='javascript:void(0);' class='btn_File ico_file' style='width: auto;' onClick=\"SimpleApplication<%=requestType%>.simpApp_FileDownload('"+escape(fileInfo.SavedName)+"','"+escape(fileInfo.FileName)+"','"+fileInfo.FileID+"')\">"+ fileInfo.FileName 
									+"<span class='tx_size'>("+ ckFileSize(fileInfo.Size) +")</span></a>"
									+"<a class='previewBtn' style='margin: 0px 10px;' href='javascript:void(0);' onclick=\"accountFileCtrl.attachFilePreview('" + fileInfo.FileID + "','" + fileInfo.FileToken + "','" + fileInfo.FileToken + "','" + fileInfo.FileName.split(".")[fileInfo.FileName.split(".").length-1].toLowerCase() + "');\"></a>";
				
									var getStr = accountCtrl.getInfoStr("[name=FileViewArea][proofcode="+getItem.ProofCode+"][viewkeyno="+getItem.ViewKeyNo+"]").append(str);
							}
						}
	
						if(getItem.uploadFileList != null){
							for(var y = 0; y < getItem.uploadFileList.length; y++){
								var fileInfo = getItem.uploadFileList[y];
								var str = "<a href='javascript:void(0);' class='btn_File ico_file' style='width: auto;' >" + fileInfo.FileName+"<span class='tx_size'>("+ ckFileSize(fileInfo.Size) +")</span></a>";
								var getStr = accountCtrl.getInfoStr("[name=FileViewArea][proofcode="+getItem.ProofCode+"][viewkeyno="+getItem.ViewKeyNo+"]").append(str);
							}
						}
					}
				}
			},
			
			simpApp_makeHtmlChkColspan : function(divObj) {
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
			
			// 파일/문서 연결부 
			simpApp_linkCk : function(ProofCode, KeyNo) {
				var me = this;
				var pageList = me["pageExpenceApp"+ProofCode+"List"];
				var KeyField = me.simpApp_getProofKey(ProofCode);

				var ckVal = false;
				var item = me.simpApp_findListItem(pageList, KeyField, KeyNo);
				
				var fList = [];
				if(item.fileList != null){
					fList = fList.concat(item.fileList)
				}
				if(item.uploadFileList != null){
					fList = fList.concat(item.uploadFileList)
				}
				if(fList != null){
					if(fList.length != 0){
						ckVal = true;
					}
				}

				var dList = item.docList;
				if(dList != null){
					if(dList.length != 0){
						ckVal = true;
					}
				}

				if(ckVal){
					accountCtrl.getInfoStr("[name=LinkArea][proofcd="+ProofCode+"][keyno="+KeyNo+"]").show();
				}else{
					accountCtrl.getInfoStr("[name=FileArea][proofcd="+ProofCode+"][keyno="+KeyNo+"]").addClass("border_none")
				}
				
			},
			
			simpApp_FileAttach : function(ProofCode, KeyNo) {
				var me = this;
				me.tempVal.ProofCode = ProofCode;
				me.tempVal.KeyNo = KeyNo;
				
				accountFileCtrl.callFileUpload(this, 'SimpleApplication<%=requestType%>.simpApp_FileCallback');
			},
			
			simpApp_FileCallback : function(data) {
				var me = window.SimpleApplication<%=requestType%>;
				me.simpApp_setModified(true);

				var ProofCode = me.tempVal.ProofCode;
				var KeyNo = me.tempVal.KeyNo;

				var pageList = me["pageExpenceApp"+ProofCode+"List"];
				var KeyField = me.simpApp_getProofKey(ProofCode);
				
				var getItem = me.simpApp_findListItem(pageList, KeyField, KeyNo);

				if(getItem.uploadFileList == null){
					getItem.uploadFileList = data;
				}else{
					var tempList = getItem.uploadFileList;
					var index = getItem.uploadFileList.length;
					for(var i = 0; i < data.length; i++) {
						tempList[index+i] = data[i];						
					}
					getItem.uploadFileList = tempList;
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
				me.simpApp_UploadHTML(data, KeyNo, ProofCode, false);
				
				me.tempVal = {};
			},

			simpApp_UploadComp : function(data, isSearched) {
				var me = window.SimpleApplication<%=requestType%>;
				var ProofCode = me.tempVal.ProofCode;
				var KeyNo = me.tempVal.KeyNo;
				var KeyField = me.simpApp_getProofKey(ProofCode);
				
				me.simpApp_UploadHTML(data.list, KeyNo,ProofCode, isSearched);
			},

			simpApp_UploadHTML : function(data, KeyNo, ProofCode, isSearched) {
				var me = window.SimpleApplication<%=requestType%>;

				var list = data
				var fileList = [];
				var fileStr = "";
				var pageList = me["pageExpenceApp"+ProofCode+"List"];
				var KeyField = me.simpApp_getProofKey(ProofCode);
				
				if(list==null){
					return;
				}
				
				for(var i = 0; i<list.length; i++){
					var fileInfo = list[i];
					var info = $.extend({}, fileInfo);
					info.KeyNo = KeyNo
					
					var fileHtmlStr = "<div class='File_list' name='simpApp"+ProofCode+"_FileItem_"+KeyNo+"_"+fileInfo.fileNum+"'>"
					if(fileInfo.FileID != null){
						fileHtmlStr = fileHtmlStr+"<a href='javascript:void(0);' class='btn_FileDel' onClick=\"SimpleApplication<%=requestType%>.simpApp_FileDelete('"+ProofCode+"', '"+KeyNo+"','"+fileInfo.fileNum+"')\"></a>"
						+"<a href='javascript:void(0);' class='btn_File ico_file' onClick=\"SimpleApplication<%=requestType%>.simpApp_FileDownload('"+escape(fileInfo.SavedName)+"','"+escape(fileInfo.FileName)+"','"+fileInfo.FileID+"')\">"+ fileInfo.FileName 
						+"<span class='tx_size'>("+ ckFileSize(fileInfo.Size) +")</span></a>"
						+"<a class='previewBtn' style='margin: 0px 10px;' href='javascript:void(0);' onclick=\"accountFileCtrl.attachFilePreview('" + fileInfo.FileID + "','" + fileInfo.FileToken + "','" + fileInfo.FileName.split(".")[fileInfo.FileName.split(".").length-1].toLowerCase() + "');\"></a>";
						+"</div>";
					}else{
						fileHtmlStr = fileHtmlStr+"<a href='javascript:void(0);' class='btn_FileDel' onClick=\"SimpleApplication<%=requestType%>.simpApp_NewFileDelete('"+ProofCode+"', '"+KeyNo+"','"+fileInfo.fileNum+"')\"></a>"
						+"<a href='javascript:void(0);' class='btn_File ico_file'>"+ fileInfo.FileName 
						+"<span class='tx_size'>("+ ckFileSize(fileInfo.Size) +")</span></a></div>";
					}
					if(!isSearched){
					}
					
					accountCtrl.getInfoStr("[name=LinkArea][proofcd="+ProofCode+"][keyno="+KeyNo+"]").append(fileHtmlStr);
				}
				
				me.simpApp_linkCk(ProofCode, KeyNo);
			},
			
			simpApp_FileDelete : function(ProofCode, KeyNo, fileNum){
				var me = this;
				me.simpApp_setModified(true);
				
				Common.Confirm("<spring:message code='Cache.ACC_lbl_DeleteAttachFile' />", "Confirmation Dialog", function(result){	//파일을 삭제하시겠습니까?
					if(result){
						var pageList = me["pageExpenceApp"+ProofCode+"List"];
						var KeyField = me.simpApp_getProofKey(ProofCode);
						var item = me.simpApp_findListItem(pageList, KeyField, KeyNo);
						var fileList = item.fileList;

						var idx = accFindIdx(fileList, "fileNum", fileNum);
						accountCtrl.getInfoName("simpApp"+ProofCode+"_FileItem_"+KeyNo+"_"+fileNum).remove();
						
						if(idx != -1){
							var fileItem = fileList[idx];
							fileList.splice(idx,1);
							if(item.deletedFile == null){
								item.deletedFile = [fileItem];
							}else{
								item.deletedFile.push(fileItem);
							}
						}
						me.simpApp_linkCk(ProofCode, KeyNo);
					}
				});
			},
			
			simpApp_NewFileDelete : function(ProofCode, KeyNo, fileNum){
				var me = this;
				me.simpApp_setModified(true);
				
				Common.Confirm("<spring:message code='Cache.ACC_lbl_DeleteAttachFile' />", "Confirmation Dialog", function(result){	//파일을 삭제하시겠습니까?
					if(result){
						var pageList = me["pageExpenceApp"+ProofCode+"List"];
						var KeyField = me.simpApp_getProofKey(ProofCode);
						var item = me.simpApp_findListItem(pageList, KeyField, KeyNo);
						
						var uploadFileList = item.uploadFileList;
						if(uploadFileList == null) {
							uploadFileList = item.fileList;
						}

						var idx = accFindIdx(uploadFileList, "fileNum", fileNum );
						accountCtrl.getInfoName("simpApp"+ProofCode+"_FileItem_"+KeyNo+"_"+fileNum).remove();
						
						if(idx != -1){
							var tempList = [];
							for(var i = 0; i < uploadFileList.length; i++) {
								if(i != idx) {
									tempList.push(uploadFileList[i]);
								}
							}
							if(tempList.length == 0) tempList = null;
							
							if(item.uploadFileList != null) {
								if(tempList)
									item.uploadFileList = tempList;
								else
									delete item.uploadFileList;
							} else {
								item.fileList = tempList;
							}
						}
						
						me.simpApp_linkCk(ProofCode, KeyNo);
					}
				});
			},

			simpApp_FileDownload : function(SavedName, FileName, FileID){
				accountFileCtrl.downloadFile(SavedName, FileName, FileID)
			},

			simpApp_LinkOpen : function(ProcessId, forminstanceID, bstored, expAppID){			
				if(ProcessId == 'execplan') {
					ProcessId = accountCtrl.getInfo("simpApp_execProcessID").val();
				}
				
				accComm.accLinkOpen(ProcessId, forminstanceID, bstored, expAppID);
			},

			simpApp_DocLink : function(ProofCode, KeyNo) {
				var me = this;
				me.tempVal.ProofCode = ProofCode
				me.tempVal.KeyNo = KeyNo
				
				var url	= "/approval/goDocListSelectPage.do";
				var iWidth = 1000, iHeight = 660, sSize = "fix";
				CFN_OpenWindow(url, "", iWidth, iHeight, sSize);
			},
			
			simpApp_LinkComp : function(data, isSearched) {
				var me = window.SimpleApplication<%=requestType%>;
				me.simpApp_setModified(true);
				
				var list = typeof(data) == "string" ? data.split("^^^") : data;				
				if(list == null){
					return;
				}
				
				var docList = [];
				
				var ProofCode = me.tempVal.ProofCode;
				var KeyNo = me.tempVal.KeyNo;
				
				var pageList = me["pageExpenceApp"+ProofCode+"List"];
				var KeyField = me.simpApp_getProofKey(ProofCode);
								
				var getItem = me.simpApp_findListItem(pageList, KeyField, KeyNo);
				var pageDocList = getItem.docList;

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
					var ckDocItem = {};
					if(!isSearched) {	
						ckDocItem = me.simpApp_findListItem(pageDocList, "ProcessID", docInfo.ProcessID);
						if(ckDocItem == null) {
							ckDocItem = {};
						}
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
							var docStr = "<div class='File_list' name='simpApp"+ProofCode+"_DocItem_"+KeyNo+"_"+docInfo.ProcessID+"'>"
								+"<a href='javascript:void(0);' class='btn_FileDel' onClick=\"SimpleApplication<%=requestType%>.simpApp_DocDelete('"+ProofCode+"','"+KeyNo+"','"+docInfo.ProcessID+"')\"></a>"
								+"<a href='javascript:void(0);' class='btn_File ico_doc' onClick=\"SimpleApplication<%=requestType%>.simpApp_LinkOpen ('" + docInfo.ProcessID + "', '" + docInfo.forminstanceID + "', '" + docInfo.bstored + "', '" + docInfo.BusinessData2 + "')\">"
								+ nullToStr(docInfo.Subject, "("+"<spring:message code='Cache.ACC_lbl_noTitle' />"+")") 	+"</div>";
					
							docList.push(info);
					
							accountCtrl.getInfoStr("[name=LinkArea][proofcd="+ProofCode+"][keyno="+KeyNo+"]").append(docStr);
						}
					}
				}

				if(!isSearched) { // 신규 추가
					if(getItem.docList == null || getItem.docList.length == 0){
						getItem.docList = docList;
					} else {
						var tempList = getItem.docList;
						var index = getItem.docList.length;
						for(var i = 0; i < docList.length; i++) {
							tempList[index + i] = docList[i];
						}
						getItem.docList = tempList;
					}
					
					if(getItem.docMaxNo==null){
						getItem.docMaxNo = 0;
					}
						
					for(var i = 0; i<docList.length; i++){
						var docItem = docList[i];
						getItem.docMaxNo++;
						docItem.docNum = getItem.docMaxNo;
					}
				
					me.tempVal = {};
				}
				
				me.simpApp_linkCk(ProofCode, KeyNo);
			},

			simpApp_DocDelete : function(ProofCode, KeyNo, docID){
				var me = this;
				Common.Confirm("<spring:message code='Cache.ACC_lbl_DeleteDocLink' />", "Confirmation Dialog", function(result){	//연결문서를 삭제하시겠습니까?
					if(result){
						var pageList = me["pageExpenceApp"+ProofCode+"List"];
						var KeyField = me.simpApp_getProofKey(ProofCode);
						
						for(var i = 0; i<pageList.length; i++){
							var item = pageList[i];
							if(item[KeyField] == KeyNo){
								var docList = item.docList;
								var tempList = [];
								for(var y = 0; y<docList.length; y++){
									var docItem = docList[y];
									if(docItem.ProcessID != docID){
										tempList.push(docItem);										
									} else {
										accountCtrl.getInfoName("simpApp"+ProofCode+"_DocItem_"+KeyNo+"_"+docID).remove();
										
										if(item.deletedDoc == null){
											item.deletedDoc = [docItem];
										}else{
											item.deletedDoc.push(docItem);
										}
									}
								}
								
								item.docList = tempList;
							}
						}
						me.simpApp_linkCk(ProofCode, KeyNo);
					}
				});
			},

			//list에서 지정된 값을 가진 항목 찾기
			simpApp_findListItem : function(inputList, field, val) {
				var retVal = null;
				var arrCk = Array.isArray(inputList);
				if(arrCk){
					retVal = accFind(inputList, field, val);
				}
				return retVal;
			},
			
			simpApp_GetRuleItem : function(ChargeJob) {
				var ruleItemId = 0;
				
				$.ajax({
					type:"POST",
					url:"/account/baseCode/getCodeListByCodeGroup.do",
					async:false,
					data:{
						codeGroup : 'ApvRule',
						companyCode : me.CompanyCode
					},
					success:function (data) {
						if(data.status == "SUCCESS"){
							if(data.list.length > 0) {
								$(data.list).each(function(i, obj){
									if(obj.IsUse == "Y" && obj.IsGroup == "N") {
										if(obj.Code.split('_')[0] == ChargeJob) {
											ruleItemId = obj.Code.split('_')[1];
											return false;
										}
									}
								});
							}
						}
					},
					error:function (error){
						alert(error.message);
					}
				});
				
				return ruleItemId;
			},
			
			simpApp_GetApvLine : function(pLegacyFormID, pRuleItemID) {
				var apvLine = "";
				
				$.ajax({
					type:"POST",
					url:"/approval/legacy/getRuleApvLine.do",
					async:false,
					data:{
						legacyFormID : pLegacyFormID,
						ruleItemID : pRuleItemID
					},
					success:function (data) {
						if(data.status == "SUCCESS"){
							apvLine = data.result;
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의바랍니다.
					}
				});
				
				return apvLine;
			},
			
			simpApp_getHTMLBody : function() {
			    // 버튼 삭제, 체크박스 삭제
			    accountCtrl.getInfoStr("div[name=simpApp_hiddenViewForm] .acstatus_wrap").each(function(){ 
			    	$(this).find("input[type=checkbox]").parent().parent().remove();
			    });
			    
				return accountCtrl.getInfoStr("div[name=simpApp_hiddenViewForm]").html();
			},

			simpApp_setModified : function(val) {
				var me = this;
				me.dataModified = val;
			},
			
			//콤보 설정
			setPayDateSelectCombo : function(){
				var me = this;
				var payDateDefaultVal = "";
				
				if(typeof me.pageExpenceAppData != "undefined") {
					if(typeof me.pageExpenceAppData.PayDateType != "undefined") {
						payDateDefaultVal = me.pageExpenceAppData.PayDateType;
					} else if(requestType == "SELFDEVELOP" || requestType == "INVEST") {
						payDateDefaultVal = "M"; //15일 default
					}
				}
				
				var AXSelectMultiArr = [	
					{'codeGroup':'DefaultPayDate', 'target':'simpApp_defaultPayDateList', 'lang':'ko', 'onchange':'', 'oncomplete':'', 'defaultVal':payDateDefaultVal, 'useDefault':"<spring:message code='Cache.lbl_Select' />"}
				]
				accountCtrl.renderAXSelectMulti(AXSelectMultiArr, me.CompanyCode);
				
				accountCtrl.getComboInfo("simpApp_defaultPayDateList").val(payDateDefaultVal);
				
				accountCtrl.refreshAXSelect("simpApp_defaultPayDateList");
				
				me.simpApp_payDateComboChange(payDateDefaultVal);
				
				// 전표발행 현황 내 편집 시 콤보박스 편집 가능하도록 처리
				if((requestType == "SELFDEVELOP" || requestType == "INVEST") && me.openParam.isReview != "Y") {
					accountCtrl.getComboInfo("simpApp_defaultPayDateList").bindSelectDisabled(true);
				}
			}, 

			simpApp_payDateComboChange : function(obj) {
				var me = this;
				
				var getType = "";
				if(typeof(obj) == "object") getType = obj.value;
				else if(typeof(obj) == "string") getType = obj;
				
				if(getType==null || getType==""){
					return;
				}
				
				me.pageExpenceAppData.PayDateType = getType;
				
				var payDateInput = accountCtrl.getInfo("simpApp_defaultPayDateInput");
				
				if(getType == "E") { //기타					
					$(payDateInput).show();
				} else {
					$(payDateInput).hide();
				}
					
				me.simpApp_makePayDate(getType);
				
				accountCtrl.refreshAXSelect("simpApp_defaultPayDateList");
			},
			
			simpApp_makePayDate : function(getType) {
				var me = this;
				
				if(getType == "E") { //기타
					if(accountCtrl.getInfo("simpApp_defaultPayDateInput_Date").val() != "") {
						me.pageExpenceAppData.PayDate = accountCtrl.getInfo("simpApp_defaultPayDateInput_Date").val().replace(/\./gi, '');
						me.pageExpenceAppData.PayDateStr = accountCtrl.getInfo("simpApp_defaultPayDateInput_Date").val();
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

					me.pageExpenceAppData.PayDate = date.format("yyyyMMdd");
					me.pageExpenceAppData.PayDateStr = date.format("yyyy.MM.dd");
				}
				me.pageExpenceAppData.RealPayDate = me.pageExpenceAppData.PayDate;

				for(var i = 0; i < me.pageExpenceAppCorpCardList.length; i++) {
					me.pageExpenceAppCorpCardList[i].RealPayDate = me.pageExpenceAppData.PayDate;
					me.pageExpenceAppCorpCardList[i].PayDate = me.pageExpenceAppData.PayDate;
					me.pageExpenceAppCorpCardList[i].PayDateStr = me.pageExpenceAppData.PayDateStr;
				}	
				for(var i = 0; i < me.pageExpenceAppPrivateCardList.length; i++) {
					me.pageExpenceAppPrivateCardList[i].RealPayDate = me.pageExpenceAppData.PayDate;
					me.pageExpenceAppPrivateCardList[i].PayDate = me.pageExpenceAppData.PayDate;
					me.pageExpenceAppPrivateCardList[i].PayDateStr = me.pageExpenceAppData.PayDateStr;
				}	
				for(var i = 0; i < me.pageExpenceAppEtcEvidList.length; i++) {
					me.pageExpenceAppEtcEvidList[i].RealPayDate = me.pageExpenceAppData.PayDate;
					me.pageExpenceAppEtcEvidList[i].PayDate = me.pageExpenceAppData.PayDate;
					me.pageExpenceAppEtcEvidList[i].PayDateStr = me.pageExpenceAppData.PayDateStr;
				}	
				for(var i = 0; i < me.pageExpenceAppReceiptList.length; i++) {
					me.pageExpenceAppReceiptList[i].RealPayDate = me.pageExpenceAppData.PayDate;
					me.pageExpenceAppReceiptList[i].PayDate = me.pageExpenceAppData.PayDate;
					me.pageExpenceAppReceiptList[i].PayDateStr = me.pageExpenceAppData.PayDateStr;
				}	
				for(var i = 0; i < me.pageExpenceAppEvidList.length; i++) {
					me.pageExpenceAppEvidList[i].RealPayDate = me.pageExpenceAppData.PayDate;
					me.pageExpenceAppEvidList[i].PayDate = me.pageExpenceAppData.PayDate;
					me.pageExpenceAppEvidList[i].PayDateStr = me.pageExpenceAppData.PayDateStr;
				}		
				if(me.pageExpenceAppData.pageExpenceAppEvidList != undefined) {
					for(var i = 0; i < me.pageExpenceAppData.pageExpenceAppEvidList.length; i++) {
						me.pageExpenceAppData.pageExpenceAppEvidList[i].RealPayDate = me.pageExpenceAppData.PayDate;
						me.pageExpenceAppData.pageExpenceAppEvidList[i].PayDate = me.pageExpenceAppData.PayDate;
						me.pageExpenceAppData.pageExpenceAppEvidList[i].PayDateStr = me.pageExpenceAppData.PayDateStr;
					}
				}
			},
			
			//출장신청서 정보 가져오기
			simpApp_setBizTripRequestInfo : function(BizTripRequestID) {
				var me = this;
				
				$.ajax({
					type:"POST",
					url:"/account/bizTrip/getBizTripRequestInfo.do",
					async: false,
					cache: false,
					data:{
						bizTripRequestID : BizTripRequestID
					},
					success:function (data) {
						if(data.result == "ok"){
							var getData = data.data;
							if(getData != null){
								if(getData.BizTripType != "P") { //프로젝트 출장이 아닐 경우
									accountCtrl.getInfo("simpApp_IOLabel").parents("li").hide();
								} else {
									var params = {};
									params.Code = getData.ProjectCode;
									params.CodeName = getData.ProjectName;
									
									me.simpApp_SetIOVal(params);
									
									accountCtrl.getInfo("simpApp_IOLabel").parents("li").show();
									accountCtrl.getInfo("simpApp_IOLabel").siblings("a").hide(); //프로젝트 고정(선택/삭제 불가하도록)
								}
							}
						}
						else{
							Common.Error("<spring:message code='Cache.ACC_msg_error' />");
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />");
					}
				});
			},
			
			simpApp_showPreview : function() {
				var me = this;
				me.simpApp_getSimpAppField();
				
				//신청 건 미리보기
				Common.open("","ExpenceApplicationPreviewPopup","<spring:message code='Cache.btn_preview'/>",
					"/account/expenceApplication/ExpenceApplicationPreviewPopup.do?parentID=SimpleApplication<%=requestType%>","1000px","800px","iframe",true,"450px","100px",true);
			},
			
			simpApp_deleteEvid : function(ProofCode) {
				var me = this;
				var checkedList = accountCtrl.getInfoStr("[tag=evidInfoCheck]:checked");
				var chkList = new Array;
				var deleteSeq = "";
				
				if(checkedList.length == 0) {
					Common.Warning("<spring:message code='Cache.ACC_msg_noselectdata'/>");
					return;
				}
				
				for(var i = 0; i<checkedList.length; i++){
					var checkedItem = checkedList[i];
					if (ProofCode == "CorpCard") {
						chkList.push({"ReceiptID" : checkedItem.getAttribute("keyno")}); continue;
					}
					if (ProofCode == "Receipt") {
						if (i==0) {
							deleteSeq = checkedItem.getAttribute("keyno"); continue;
						}
						deleteSeq += "," + checkedItem.getAttribute("keyno");
					}
				}
				
				if(ProofCode == "CorpCard") {
					Common.Confirm("<spring:message code='Cache.ACC_msg_personalUseYN'/>", "Confirmation Dialog", function(result){ if(result){
						$.ajax({
							url			: "/account/cardReceipt/saveCardReceiptPersonal.do",
							type		: "POST",
							data		: JSON.stringify({ "isPersonalUse" : "Y", "chkList" : chkList }),
							dataType	: "json",
							contentType	: "application/json",
							success		:function (data) {
								if (data.status == "SUCCESS") me.simpApp_evidInfoCall(ProofCode);
								else Common.Error("<spring:message code='Cache.ACC_msg_error' />");
								// 오류가 발생했습니다. 관리자에게 문의바랍니다.
							},
							error		:function(response, status, error){
								Common.Error("<spring:message code='Cache.ACC_msg_error' />");
								// 오류가 발생했습니다. 관리자에게 문의바랍니다.
							}
						});
					}});
				} else if(ProofCode == "Receipt") {
					Common.Confirm("<spring:message code='Cache.msg_AreYouDelete'/>", "Confirmation Dialog", function(result){ if(result){
						$.ajax({
							url		: "/account/mobileReceipt/deleteMobileReceipt.do",
							type	: "POST",
							data	: { "deleteSeq" : deleteSeq },
							success	:function (data) {
								if (data.status == "SUCCESS") me.simpApp_evidInfoCall(ProofCode);
								else Common.Error("<spring:message code='Cache.ACC_msg_error' />");
								// 오류가 발생했습니다. 관리자에게 문의바랍니다.
							},
							error	:function(response, status, error){
								Common.Error("<spring:message code='Cache.ACC_msg_error' />");
								// 오류가 발생했습니다. 관리자에게 문의바랍니다.
							}
						});
					}});
				}
			},
			//증빙과 세금유형에 따라 세금 유형
			simpApp_makeTTData : function(ProofCode, taxcode) {
				var me = this;
				var result = me.simpApp_findListItem(me.pageSimpAppComboData.TaxCodeList, "Code", taxcode);
				var value = '';
				if(result.DeductionType!=undefined)
					value = result.DeductionType=="N"?'induct':'deduct';
				return value;	
			},
			simpApp_toggleCheckAll : function() {
				var chkAll = accountCtrl.getInfo("simpApp_evidAddCheckAll").prop("checked");
				accountCtrl.getInfoStr("[tag=evidAddCheck]").prop("checked", chkAll);
			},
			simpApp_cardCheckAll : function() {
				var chkAll = accountCtrl.getInfo("simpApp_evidCardCheckAll").prop("checked");
				var checked = accountCtrl.getInfoStr("[tag=evidInfoCheck][proofcd=CorpCard]:first").is(":checked")
				accountCtrl.getInfoStr("[tag=evidInfoCheck][proofcd=CorpCard]").prop("checked", chkAll);
				
			},
			
			//대리기안자
			simpApp_onSubUserSearch : function() {
				var me = this;
				var popupID		= "orgmap_pop";
				var openerID	=	"SimpleApplication<%=requestType%>";
				var popupTit	= "<spring:message code='Cache.ACC_lbl_orgChart' />";	//조직도
				var callBackFn	= "simpApp_onSubUserCallBack";
				var type		= "B1";
				var popupUrl	= "/covicore/control/goOrgChart.do?"
								+ "popupID="		+ popupID		+ "&"
								+ "callBackFunc="	+ callBackFn	+ "&"
								+ "type="			+ type;
				Sub_Chg_Title =  accountCtrl.getInfo("simpApp_ApplicationTitle").val();
				window[callBackFn] = window[openerID][callBackFn];

				Common.open("", popupID, popupTit, popupUrl, "1000px","580px","iframe",true,null,null,true);
			},
			simpApp_onSubUserCallBack : function(orgData){
				var me = SimpleApplication<%=requestType%>;
				var items		= JSON.parse(orgData).item;
				var arr			= items[0];
				Sub_UR_Name		= arr.DN;
				var UserCode	= arr.UserCode;
				var PO			= arr.PO.split('&');
				
				accountCtrl.getInfo('simpApp_Sub_UR_Name').text(CFN_GetDicInfo(Sub_UR_Name));
				accountCtrl.getInfo('simpApp_Sub_UR_Code').val(UserCode);
				accountCtrl.getInfo('simpApp_Sub_UR_Info').val(PO[0]);
				me.simpApp_setNew();
				accountCtrl.getInfo("simpApp_ApplicationTitle").val(Sub_Chg_Title);
			},
			
			ctrlComboChange: function(obj){
				var me = this;
				var type = $(obj).attr("type");
				var ProofCode = $(obj).attr("proofcd");
	            var KeyNo = $(obj).attr("keyno");
	            var Rownum = $(obj).attr("rownum");
	          
				me.simpApp_ComboChange(obj, type, ProofCode, KeyNo,Rownum);
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
	            var popupID;
	            var popupName;
	            var callBack;
	            var width;
	            var height;
	            
	            me.tempVal.KeyNo = KeyNo;
	            me.tempVal.ProofCode = ProofCode;
	            me.tempVal.Rownum = Rownum;
	            me.tempVal.code = code;
	            
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
	            
	            var url =	"/account/accountCommon/accountCommonPopup.do?"
						+	"popupID="		+	popupID		+	"&"
						+	"popupName="	+	popupName	+	"&"
						+	"parentNM="		+	me.pageName	+	"&"
						+	"jsonCode="		+	code		+	"&"
						+	"KeyNo="		+	KeyNo		+	"&"
						+	"ProofCode="	+	ProofCode	+	"&"
						+	"RequestType="	+	requestType	+	"&" 
						+	me.pageOpenerIDStr
						+	"includeAccount=N&"
						+	"companyCode="	+	me.CompanyCode	+ "&"
						+	"callBackFunc="	+	callBack;
	            
	            Common.open("", popupID, popupTit, url, width, height, "iframe", true, null, null, true);
			},
			
			SetDistanceCallBack: function (info) {
	            var me = this;
	            
				var ProofCode = me.tempVal.ProofCode;
				var KeyNo = me.tempVal.KeyNo;
				var Rownum = me.tempVal.Rownum;
				
				var pageList = me["pageExpenceApp"+ProofCode+"List"];
				var KeyField = me.simpApp_getProofKey(ProofCode);
				var getItem = me.simpApp_findListItem(pageList, KeyField, KeyNo);
				
				var fuelList = $.extend(true,[],info['FuelExpenceAppEvidList']);
				
				var FuelRealPrice = 0;
				var totDistance = 0;
				var lastDate = '';

				$(fuelList).each(function(idx,item){
					item.BizTripDateStr = item.BizTripDate;
					item.BizTripDate = item.BizTripDate.replace(/\./gi, '');	
					FuelRealPrice += Number(item.FuelRealPrice);
					totDistance += Number(item.Distance.replace(/\,/gi, ''));
					
				    if(Number(item.BizTripDate) > lastDate.replace(/\./gi, '')) {
				    	lastDate = item.BizTripDateStr;
				    }
				});

				accountCtrl.getInfoStr("[tag=Amount][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").val(toAmtFormat(FuelRealPrice));
				accountCtrl.getInfoStr("[tag=Amount][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").keyup();

				//divList 수정
				me.simpApp_setDivVal(ProofCode, KeyNo, Rownum, "Amount", FuelRealPrice);
				
				//총합 계산
				me.setBizTripTotalAmount(ProofCode, KeyNo, Rownum, getItem, FuelRealPrice);
				
				var lastDateHidden = new Date(lastDate); lastDateHidden.format("MM/dd/yyyy");
				accountCtrl.getInfoStr("[name=SimpAppDateField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").find("input[type=text]").val(lastDate);
				accountCtrl.getInfoStr("[name=SimpAppDateField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").find("input[type=hidden]").val(lastDateHidden);
				accountCtrl.getInfoStr("[name=SimpAppDateField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").trigger("onchange");

				//////////////////////////////////////////////////////////////////////////
	            //관리항목
	            //////////////////////////////////////////////////////////////////////////
	            var code = me.tempVal.code;

	            var obj = accountCtrl.getInfoStr("input[code='" + code + "'][keyno='" + KeyNo + "'][rownum='" + Rownum + "']");
	            
	            var PopCode = {};
	            
	            PopCode['Distance'] = info['Distance'];
	            PopCode['FuelExpenceAppEvidList'] = info['FuelExpenceAppEvidList'];
	            PopCode = JSON.stringify(PopCode);

				var Distance = toAmtFormat(totDistance.toFixed(1));
				if(code!='D02') Distance = toAmtFormat(totDistance);
	           	
	            accountCtrl.getInfoStr("[code='" + code + "'][keyno='" + KeyNo + "'][rownum='" + Rownum + "'][popup='value']").val(Distance);
	            accountCtrl.getInfoStr("[code='" + code + "'][keyno='" + KeyNo + "'][rownum='" + Rownum + "'][popup='code']").val(PopCode);
	            
	            accountCtrl._onSaveJson(me, obj, "CtrlArea", ProofCode, KeyNo, Rownum);
	            
				me.tempVal = {};
	        },
	        
	        SetDailyCallBack : function(returnList){				
				var me = this;
				
				var ProofCode = me.tempVal.ProofCode;
				var KeyNo = me.tempVal.KeyNo;
				var Rownum = me.tempVal.Rownum;
				
				var pageList = me["pageExpenceApp"+ProofCode+"List"];
				var KeyField = me.simpApp_getProofKey(ProofCode);
				var getItem = me.simpApp_findListItem(pageList, KeyField, KeyNo);
				
				var dailyList = $.extend(true,[],returnList['DailyExpenceAppEvidList']);
				
				var DailyAmount = 0;
				var commentHtml = "";
				var WorkingDays = 0;
				var lastDate = '';
				
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
				
				accountCtrl.getInfoStr("[name=UsageCommentField][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").html(commentHtml);
				accountCtrl.getInfoStr("[name=UsageCommentField][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").keyup();

				accountCtrl.getInfoStr("textarea[tag=Comment][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").html(commentHtml);
				accountCtrl.getInfoStr("textarea[tag=Comment][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").keyup();
				
				accountCtrl.getInfoStr("[tag=Amount][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").val(toAmtFormat(DailyAmount));
				accountCtrl.getInfoStr("[tag=Amount][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").keyup();
				
				//divList 수정
				me.simpApp_setDivVal(ProofCode, KeyNo, Rownum, "Amount", DailyAmount);

				//총합 계산
				me.setBizTripTotalAmount(ProofCode, KeyNo, Rownum, getItem, DailyAmount);
				
				var lastDateHidden = new Date(lastDate); lastDateHidden.format("MM/dd/yyyy");
				accountCtrl.getInfoStr("[name=SimpAppDateField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").find("input[type=text]").val(lastDate);
				accountCtrl.getInfoStr("[name=SimpAppDateField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").find("input[type=hidden]").val(lastDateHidden);
				accountCtrl.getInfoStr("[name=SimpAppDateField][proofcd="+ProofCode+"][keyno="+KeyNo+"]").trigger("onchange");

				//////////////////////////////////////////////////////////////////////////
	            //관리항목
	            //////////////////////////////////////////////////////////////////////////			
				var code = me.tempVal.code;
	            
	            var obj = accountCtrl.getInfoStr("input[code='" + code + "'][keyno='" + KeyNo + "'][rownum='" + Rownum + "']");
	            var PopCode = {};
	            PopCode['DailyExpenceAppEvidList'] = returnList['DailyExpenceAppEvidList'];
	            PopCode = JSON.stringify(PopCode);
	           
	            accountCtrl.getInfoStr("[code='" + code + "'][keyno='" + KeyNo + "'][rownum='" + Rownum + "'][popup='value']").val(WorkingDays);
	            accountCtrl.getInfoStr("[code='" + code + "'][keyno='" + KeyNo + "'][rownum='" + Rownum + "'][popup='code']").val(PopCode);

	            accountCtrl._onSaveJson(me, obj, "CtrlArea", ProofCode, KeyNo, Rownum);
				me.tempVal = {};
				
			},
			
			//출장항목(일비,유류비) 총액 계산
			setBizTripTotalAmount : function(ProofCode, KeyNo, Rownum, item, amount) {
				var me = this;
				
				var TotalAmount = 0;
				for(var i = 0; i < item.divList.length; i++) {
				    var divItem = item.divList[i];
				    if(divItem.ReservedStr2_Div != undefined) {
					    if('D02' in divItem.ReservedStr2_Div || 'D03' in divItem.ReservedStr2_Div || 'Z09' in divItem.ReservedStr2_Div)
					    	TotalAmount += divItem.Amount;
				    }
				}
				
				var totalField = accountCtrl.getInfoStr("[name=TotalAmountField][proofcd="+ProofCode+"][keyno="+KeyNo+"]");
				if(totalField.length > 0) {
					totalField.val(toAmtFormat(TotalAmount));
					me.simpApp_setFieldData(ProofCode, "TotalAmount", KeyNo, TotalAmount);
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
	            
	            me.tempVal.KeyNo = KeyNo;
	            me.tempVal.ProofCode = ProofCode;
	            me.tempVal.Rownum = Rownum;
	            me.tempVal.code = code;

	            var popupTit = name;
	            var popupID;
	            var popupName;
	            var callBack;
	            var width;
	            var height;
	            
	            if(code=="C07") {//C07:tmap없는 유류비
		            popupID = "AttendantPopup";
		            popupName = "AttendantPopup";
		            callBack = "SetAttendantCallBack";
		            width = "1000px";
		            height = "550px";
	            }
	            
	            var url =	"/account/accountCommon/accountCommonPopup.do?"
						+	"popupID="		+	popupID		+	"&"
						+	"popupName="	+	popupName	+	"&"
						+	"parentNM="		+	me.pageName	+	"&"
						+	"jsonCode="		+	code		+	"&"
						+	"KeyNo="		+	KeyNo		+	"&"
						+	"ProofCode="	+	ProofCode	+	"&"
						+	"RequestType="	+	requestType	+	"&" 
						+	me.pageOpenerIDStr
						+	"includeAccount=N&"
						+	"companyCode="	+	me.CompanyCode	+ "&"
						+	"callBackFunc="	+	callBack;
	            Common.open("", popupID, popupTit, url, width, height, "iframe", true, null, null, true);
			},
			
			SetAttendantCallBack : function(returnList) {
				var me = this;
				var ProofCode = me.tempVal.ProofCode;
				var KeyNo = me.tempVal.KeyNo;
				var Rownum = me.tempVal.Rownum;
				var code = me.tempVal.code;
				
	            var obj = accountCtrl.getInfoStr("input[code='" + code + "'][keyno='" + KeyNo + "'][rownum='"+Rownum+"']");
	            
	            var attendList = $.extend(true,[],returnList['AttendantList']);
	            var PopCode = {};
	            PopCode['AttendantList'] = returnList['AttendantList'];
	            PopCode = JSON.stringify(PopCode);
	            
				var displayText = $(attendList).length < 2 
									? $(attendList)[0].UserName 
									: "<spring:message code='Cache.msg_BesidesCount' />".replace("{0}", $(attendList)[0].UserName).replace("{1}", $(attendList).length-1);

			    accountCtrl.getInfoStr("[code='" + code + "'][keyno='" + KeyNo + "'][rownum='"+Rownum+"'][popup='value']").val(displayText);
				accountCtrl.getInfoStr("[code='" + code + "'][keyno='" + KeyNo + "'][rownum='"+Rownum+"'][popup='code']").val(PopCode);
				
				accountCtrl._onSaveJson(me, obj, "CtrlArea", ProofCode, KeyNo, Rownum);
				me.tempVal = {};
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
						onLoad: function(){
				        	coviEditor.setBody(g_editorKind, g_containerID, g_editorBody);
				        }
					}
				);
			},
			
			//세부증빙 복사
			simpApp_copyDiv : function(ProofCode, KeyNo) {
				var me = this;
				
				var targetRow = accountCtrl.getInfoStr("[name=DivCheck][keyno="+KeyNo+"]:checked");
				if(targetRow.length>1){
					Common.Inform("<spring:message code='Cache.msg_SelectOnlyOne' />"); //1개 항목만 선택하세요.
					return;
				}
				
				var pageList = me["pageExpenceApp"+ProofCode+"List"];
				var item = me.simpApp_findListItem(pageList, "KeyNo", KeyNo);
			    var copyRownum = targetRow.length == 0 ? item.divList[0].Rownum : parseInt(targetRow.attr('rownum'));
				var oriTempVal = Object.assign({}, me.tempVal);
				
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
						, ExpenceApplicationListID : nullToBlank(item.ExpenceApplicationListID)
						
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

				if(divList.ReservedStr2_Div != undefined && Object.keys(divList.ReservedStr2_Div).length != 0)
					divItem.ReservedStr2_Div = Object.assign({}, divList.ReservedStr2_Div);
				if(divList.ReservedStr3_Div != undefined && Object.keys(divList.ReservedStr3_Div).length != 0)
					divItem.ReservedStr3_Div = Object.assign({}, divList.ReservedStr3_Div);
				
				item.divList.push(divItem);
				me.simpApp_updateCopyDivHtml(divItem, divItem.ProofCode, divItem.KeyNo, copyRownum);
				
				me.tempVal = oriTempVal;
			},

			//복사된 세부증빙 html로 수정
			simpApp_updateCopyDivHtml : function(divItem, ProofCode, KeyNo, copyRownum) {
				var me = this;
				var Rownum = divItem.Rownum;
				var divArea = accountCtrl.getInfoStr("[name=DivAddArea][proofcd="+ProofCode+"][keyno="+KeyNo+"]");
				
				var formStr = me.pageSimpAppFormList["DivAddInputAreaStr"];

				if(nullToBlank(divItem.Amount) == ""){
					divItem.Amount = divItem.TotalAmount;
				}
				
				const valMap = {
						ExpenceApplicationListID : nullToBlank(divItem.ExpenceApplicationListID),
						KeyNo : nullToBlank(divItem.KeyNo),
						ProofCode : nullToBlank(divItem.ProofCode),
						Rownum : nullToBlank(divItem.Rownum),
						
						Amount : nullToBlank(divItem.Amount),
						AmountVal : nullToBlank(divItem.Amount),
						
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
						CostCenterCode : nullToBlank(divItem.CostCenterCode),
						CostCenterName : nullToBlank(divItem.CostCenterName),
						
						IOCDVal : nullToBlank(divItem.IOCode),
						IONMVal : nullToBlank(divItem.IOVal),
						
						UsageCommentVal : nullToBlank(divItem.UsageComment).replace(/<br>/gi, '\r\n'),
						
						RequestType : requestType,
						
						SelfDevelopDetail : nullToBlank(divItem.SelfDevelopDetail),
						
						//관리항목
						TaxType : nullToBlank(divItem.TaxType),
						TaxCode : nullToBlank(divItem.TaxCode),
						CtrlCode : nullToBlank(divItem.CtrlCode)
				}
				
				if(divItem.ReservedStr2_Div != undefined && Object.keys(divItem.ReservedStr2_Div).length > 0)
					valMap.ReservedStr2_Div = Object.assign({}, divItem.ReservedStr2_Div);
				if(divItem.ReservedStr3_Div != undefined && Object.keys(divItem.ReservedStr3_Div).length > 0)
					valMap.ReservedStr3_Div = Object.assign({}, divItem.ReservedStr3_Div);
				
				var getForm = me.simpApp_htmlFormSetVal(formStr, valMap);
				getForm = me.simpApp_htmlFormDicTrans(getForm);
				divArea.append(getForm);
				
				//표준적요, 관리항목 셋팅
				var targetObj = {
			    	ProofCode : ProofCode
			    	, KeyNo : KeyNo
			    	, Rownum : Rownum
			    };
				
				me.tempVal = Object.assign({}, targetObj);
				me.simpApp_SetBriefVal(valMap);
				
			    if(accountCtrl.getInfoStr("[name=CtrlArea][keyno="+KeyNo+"][rownum="+Rownum+"]").length > 0) {
			    	//관리항목 input 값 셋팅
			    	me.simApp_setCtrlDivHtml(valMap);
			    	
			    	//관리항목 popup 처리
			    	if(valMap.ReservedStr2_Div != undefined && Object.keys(valMap.ReservedStr2_Div).length > 0) {
			    		var ctrlType = Object.keys(valMap.ReservedStr2_Div);
			    		
			    		//출장항목 관련 관리항목 처리
				    	if('D01' in valMap.ReservedStr2_Div) {
							accountCtrl.getInfoStr("select[code="+ctrlType[0]+"][keyno="+KeyNo+"][rownum="+Rownum+"][type=BizTripItem]").val(accountCtrl.getInfoStr("select[code="+ctrlType[0]+"][keyno="+KeyNo+"][rownum="+copyRownum+"][type=BizTripItem]").val());
							accountCtrl.getInfoStr("select[code="+ctrlType[0]+"][keyno="+KeyNo+"][rownum="+Rownum+"][type=BizTripItem]").trigger("onchange");
							
				            if(valMap.ReservedStr3_Div != undefined && Object.keys(valMap.ReservedStr3_Div).length > 1) {
				            	if(valMap.ReservedStr3_Div[ctrlType[1]] != undefined && valMap.ReservedStr3_Div[ctrlType[1]] != "") {
									var jsonDiv = JSON.parse(valMap.ReservedStr3_Div[ctrlType[1]]);
									targetObj.code = ctrlType[1];
									me.tempVal = Object.assign({}, targetObj);
					            	
									if(ctrlType[1] == "D02") {
										me.SetDistanceCallBack(jsonDiv);
									} else if(ctrlType[1] == "D03") {
										me.SetDailyCallBack(jsonDiv);
									} else if(ctrlType[1] == "Z09") {
										me.SetDistanceCallBack(jsonDiv);
									}
									
									accountCtrl.getInfoStr("textarea[tag=Comment][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").html(valMap.UsageCommentVal);
									me.simpApp_setDivVal(ProofCode, KeyNo, Rownum, "UsageComment", valMap.UsageCommentVal);
				            	}
							}
				        //편익제공 관련 관리항목 처리
			    		} else if('C07' in valMap.ReservedStr2_Div) {
			    			if(valMap.ReservedStr3_Div['C07'] != undefined || valMap.ReservedStr3_Div['C07'] != "") {
								var jsonDiv = JSON.parse(valMap.ReservedStr3_Div['C07']);
								targetObj.code = 'C07';
								me.tempVal = Object.assign({}, targetObj);
				            	
								me.SetAttendantCallBack(jsonDiv);
			    			}
			    		}
			    	}
			    }
			    
			    //Amount 셋팅
			    me.simpApp_setDivVal(ProofCode, KeyNo, Rownum, "Amount", valMap.Amount);
			    accountCtrl.getInfoStr("[name=DivAmountField][proofcd="+ProofCode+"][keyno="+KeyNo+"][Rownum="+Rownum+"]").trigger('onblur');
				
				if(isUseIO == "N") {
			   		accountCtrl.getInfoName("noIOArea").hide();
			   	}
			   	if(isUseSB == "N") {
			   		accountCtrl.getInfoName("noSBArea").hide();
			   	} else {
			   		accountCtrl.getInfoName("AccBtn").remove();
			   		accountCtrl.getInfoName("DivAccNm").css("width", "116px");
			   	}
			   	if(isUseBD == "" || isUseBD == "N") {
			   		accountCtrl.getInfoName("noBDArea").hide();
			   	}
			},
			
			//세부증빙 관리항목 값 셋팅
			simApp_setCtrlDivHtml : function(divItem) {
				var ctrlCodeArr = divItem.CtrlCode.split(',');
				
				for(var i = 0; i < ctrlCodeArr.length; i++) {
					var ctrlVal = divItem.ReservedStr2_Div[ctrlCodeArr[i]];
					if(ctrlCodeArr.includes('D01', 'D02', 'D03', 'Z09', 'C07')) {
						continue;
					}
					accountCtrl.getInfoStr("[name=CtrlArea] [code="+ctrlCodeArr[i]+"][proofcd="+divItem.ProofCode+"][keyno="+divItem.KeyNo+"][rownum="+divItem.Rownum+"]").val(ctrlVal);
				}
			},
			
			getRequestType : function(){
				return requestType;
			},
	}
	window.SimpleApplication<%=requestType%> = SimpleApplication<%=requestType%>;
})(window);


function InputDocLinks(szValue) {
    try {
    	window.SimpleApplication<%=requestType%>.simpApp_LinkComp(szValue); 
    	// szValue : [ProcessID(ProcessArchiveID)]@@@[FormPrefix]@@@[Subject]^^^[ProcessID(ProcessArchiveID)]@@@[FormPrefix]@@@[Subject]
    	// ex) 2402569@@@WF_FORM_EACCOUNT_LEGACY@@@결재연동 1713^^^2400107@@@WF_FORM_EACCOUNT_LEGACY@@@통합 비용 신청 - 0706 #1
    }
    catch (e) {
    }
}
</script>
