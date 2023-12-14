<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil" %>
<%@ page import="egovframework.coviframework.util.RedisDataUtil" %>

<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<%
	String propertyOtherApv = RedisDataUtil.getBaseConfig("eAccOtherApv");
	String isUseBizMnt = RedisDataUtil.getBaseConfig("isUseBizMnt");
	String AccountViewApvLineType = RedisDataUtil.getBaseConfig("AccountViewApvLineType");
	
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
	<% if(AccountViewApvLineType.equals("Graphic")) { %>
		<script type="text/javascript" src="/approval/resources/script/user/approvestat.js<%=resourceVersion%>"></script>
		<link rel="stylesheet" type="text/css" href="<%=cssPath%>/approval/resources/css/approval/monitoring.css<%=resourceVersion%>" />
	<% } else { %>
		<script type="text/javascript" src="/approval/resources/script/forms/FormApvLine.js<%=resourceVersion%>"></script>
	<% } %>
</head>
<style>
.pad10 { padding:10px;}
.total_acooungting_dl { font-size:14px; }
</style>
<body>
	<!-- 상단 버튼 시작 -->
	<div class="cRConTop" name="aprvBtnArea" id="aprvBtnArea">
		<div style="float: right; margin-right: 23px;">
			<!-- 취소전표 -->
			<label name="comCostAppView_reverseLabel" style="font-size: 20px; line-height: 33px; color: #ff0000; font-weight: bold; display: none;">
				<spring:message code="Cache.ACC_lbl_reverse"/>
			</label>
		</div>
		<div class="cRTopButtons" id="div_formmenu">
			<!-- 이전 -->
			<a href="#" class="btnTypeDefault" onClick="CombineCostApplicationView.combiCostAppView_fnGoPreNextList('btPreList')" style="display: none;" id="btPreList">▲</a>
			<!-- 다음 -->
			<a href="#" class="btnTypeDefault" onClick="CombineCostApplicationView.combiCostAppView_fnGoPreNextList('btNextList')" style="display: none;" id="btNextList">▼</a>
		
		<%
			String isUser = (String)request.getParameter("isUser");
			if("Y".equals(isUser)){
		%>
				<a href="#" class="btnTypeDefault btnTypeChk" onClick="CombineCostApplicationView.combiCostAppView_callAprv('S')" style="display: none;" name="comCostAppView_aprvBtn">
					<spring:message code="Cache.ACC_btn_aprvCall"/>
				</a>
				<a href="#" class="btnTypeDefault" onClick="CombineCostApplicationView.combiCostAppView_callReUse()" style="display: none;" name="comCostAppView_reuseBtn">
					<spring:message code="Cache.btn_reuse"/>
				</a>
		<% 
			} else {
		%>
				<!-- 전표발행 -->
				<a class="btnTypeDefault btnTypeBg " href="#" onclick="CombineCostApplicationView.combiCostAppView_makeSlip()" style="display: none; color: #fff;" name="comCostAppView_slipBtn">
					<spring:message code="Cache.ACC_btn_makeSlip"/>
				</a>
				
				<!-- 전표취소 -->
				<a class="btnTypeDefault btnTypeBg " href="#" onclick="CombineCostApplicationView.combiCostAppView_unMakeSlip()" style="display: none; color: #fff;" name="comCostAppView_unSlipBtn">
					<spring:message code="Cache.ACC_lbl_unmakeSlip"/>
				</a>	
				
				<!-- 전표취소(역분개) -->
				<a class="btnTypeDefault" href="#" onclick="CombineCostApplicationView.combiCostAppView_reverseExpApp()" style="display: none;" name="comCostAppView_reverseBtn">
					<spring:message code="Cache.ACC_btn_reverse"/>
				</a>
		<%
			} 
		%>
			<!-- 승인 -->
			<a href="#" class="btnTypeDefault btnTypeBg " onClick="CombineCostApplicationView.combiCostAppView_clickBtn(this)" id="btApproved" style="display: none; color: #fff;">
				<spring:message code="Cache.btn_apv_Approved"/>
			</a>
			<!-- 반려 -->
			<a href="#" class="btnTypeDefault" onClick="CombineCostApplicationView.combiCostAppView_clickBtn(this)" id="btReject" style="display: none;">
				<spring:message code="Cache.lbl_apv_reject"/>
			</a>
			<!-- 보류 -->
			<a href="#" class="btnTypeDefault" onClick="CombineCostApplicationView.combiCostAppView_clickBtn(this)" id="btHold" style="display: none;">
				<spring:message code="Cache.lbl_apv_hold"/>
			</a>
			<!-- 회수 -->
			<a href="#" class="btnTypeDefault" onClick="CombineCostApplicationView.combiCostAppView_clickBtn(this)" id="btWithdraw" style="display: none;">
				<spring:message code="Cache.btn_apv_Withdraw"/>
			</a>
			<!-- 취소 -->
			<a href="#" class="btnTypeDefault" onClick="CombineCostApplicationView.combiCostAppView_clickBtn(this)" id="btAbort" style="display: none;">
				<spring:message code="Cache.btn_apv_cancel"/>
			</a>
			<!-- 재기안 회수 -->
			<a href="#" class="btnTypeDefault" onClick="CombineCostApplicationView.combiCostAppView_clickBtn(this)" id="btRejectedtoDept" style="display: none;">
				<spring:message code="Cache.btn_apv_RedraftWithdraw"/>
			</a>
			<!-- 접수 -->
			<a href="#" class="btnTypeDefault" onClick="CombineCostApplicationView.combiCostAppView_clickBtn(this)" id="btRec" style="display: none;">
				<spring:message code="Cache.btn_apv_receipt"/>
			</a>
			<!-- 재기안 -->
			<a href="#" class="btnTypeDefault" onClick="CombineCostApplicationView.combiCostAppView_clickBtn(this)" id="btDeptDraft" style="display: none;">
				<spring:message code="Cache.btn_apv_redraft"/>
			</a>
			<!-- 선택취소 -->
			<a href="#" class="btnTypeDefault" onClick="CombineCostApplicationView.combiCostAppView_clickBtn(this)" id="btSerialCancel" style="display: none;">
				<spring:message code="Cache.btn_apv_serialCancel"/>
			</a>
			<!-- 담당자 -->
			<a href="#" class="btnTypeDefault" onClick="CombineCostApplicationView.combiCostAppView_clickBtn(this)" id="btCharge" style="display: none;">
				<spring:message code="Cache.btn_apv_charge"/>
			</a>
			<!-- 결재선 -->
			<a href="#" class="btnTypeDefault" onClick="CombineCostApplicationView.combiCostAppView_clickBtn(this)" id="btLine">
				<spring:message code="Cache.lbl_apv_approver"/>
			</a>
			<!-- 출력 -->
			<a href="#" class="btnTypeDefault" onClick="CombineCostApplicationView.combiCostAppView_clickBtn(this)" id="btPrint">
				<spring:message code="Cache.btn_apv_print"/>
			</a>
			<!-- 증빙 미리보기 -->
			<a href="#" class="btnTypeDefault" onClick="CombineCostApplicationView.combiCostAppView_callEvidPreview()" name="comCostAppView_previewBtn">
				<spring:message code="Cache.ACC_btn_EvidPreview"/>
			</a>
			<!-- 증빙 일괄출력 -->
			<a href="#" class="btnTypeDefault" onClick="CombineCostApplicationView.combiCostAppView_clickBtn(this)" id="btPrintEvid">
				<spring:message code="Cache.ACC_btn_printAllEvid"/>
			</a>
            <!-- 증빙별 첨부 일괄저장 -->
			<a href="#" class="btnTypeDefault" onClick="CombineCostApplicationView.combiCostAppView_clickBtn(this)" id="btDownloadEvidFile">
				<spring:message code="Cache.ACC_btn_downloadAllEvidFile"/>
			</a>    
		</div>
	</div>
	<div id="bodytable" style="position:absolute;">
		<div class="divpop_contents" style="display: none;">
			<div class="popContent form_box">
				<div class="rowTypeWrap formWrap tsize">
					<!-- 컨텐츠 시작 -->
					<div id="comCostAppView_contView">
				    	<div>		
							<% 
								if(propertyOtherApv.equals("N")) {
									if(AccountViewApvLineType.equals("Graphic")) { %>
										<div id="graphicDiv"></div>
								<%	} else { %>
										<jsp:include page="Frozen.jsp" flush="false"></jsp:include>
								<%	}
								} 
							%>	
				    	</div>
						<div class="allMakeView">
							 
							<div class="inpStyle01 allMakeTitle" style="display:none">
								<input type="hidden" class="inpStyle01" id="comCostAppView_ApplicationTitle" name="ComCostAppViewInputField" tag="ApplicationTitle">
								<input type="hidden" class="inpStyle01" id="comCostAppView_isSearched" name="ComCostAppViewInputField" tag="isSearched">
								<input type="hidden" class="inpStyle01" id="comCostAppView_isNew"  name="ComCostAppViewInputField" tag="isNew">
								<input type="hidden" class="inpStyle01" id="comCostAppView_isModified"  name="ComCostAppViewInputField" tag="isModified">
								<input type="hidden" class="inpStyle01" id="comCostAppView_PropertyBudget" tag="Budget">
							</div>
							<div class="taw_top">
								<p class="taw_top_title" name="ComCostAppViewViewField" tag="ApplicationTitle">
								</p>
								<div class="eaccounting_name">	<!-- p 안에 다른 객체가 있으면 추후 html을 복사해서 append할때 구조가 꼬임(ex. 출력) -->	
									<strong><spring:message code="Cache.ACC_lbl_company"/> :</strong> <!-- 회사 --> 
									<label id="comCostAppView_lblCompanyName" name="ComCostAppViewViewField" tag="CompanyName"></label>
									<strong>&nbsp;/&nbsp;<spring:message code="Cache.ACC_lbl_applicator"/> :</strong> <!-- 신청자 -->
									<label id="comCostAppView_lblApplicator" name="ComCostAppViewViewField" tag="Sub_UR_Name"></label>
									<strong>&nbsp;/&nbsp;<spring:message code="Cache.ACC_lbl_payDay"/> :</strong> <!-- 지급희망일 --> 
									<label id="comCostAppView_lblPayDate" name="ComCostAppViewViewField" tag="PayDate"></label>
								</div>
								<p class="eaccounting_type"><!-- 신청유형 -->
									<spring:message code="Cache.ACC_lbl_requestType"/> : <span id="requestTypeName"></span>
								</p>
							</div>
						</div>
						<div class="inStyleSetting">	
							<div class="total_acooungting_wrap" id="comCostAppView_TotalWrap">
								<table class="total_acooungting_wrap_table">
									<tbody>
										<tr>
											<td class="acc_total_l">
												<table class="total_table_list">
													<tbody>
														<tr><td id="comCostAppView_EvidAmtArea"></td></tr>
														<tr><td id="comCostAppView_SBAmtArea"></td></tr>
														<tr style="display: none;"><td id="comCostAppView_AuditCntArea"></td></tr>
													</tbody>
												</table>
											</td>
											<td class="acc_total_r">
												<table class="total_table">
													<thead>
														<tr>
															<!-- 증빙총액 -->
															<th><spring:message code='Cache.ACC_lbl_eviTotalAmt'/><span id="comCostAppView_lblTotalCnt"></th>
															<!-- 청구금액 -->
															<th><spring:message code='Cache.ACC_billReqAmt'/></th>
														</tr>
													</thead>
													<tbody>
														<tr>
															<td><span class="tx_ta" id="comCostAppView_lblTotalAmt">0</span><spring:message code='Cache.ACC_krw'/></td>
															<td><span class="tx_ta" id="comCostAppView_lblBillReqAmt">0</span><spring:message code='Cache.ACC_krw'/></td>
														</tr>
													</tbody>
												</table>
												<input type="hidden" id="comCostAppView_TotalAmt"  name="ComCostAppViewInputField" tag="TotalAmt">
												<input type="hidden" id="comCostAppView_ReqAmt"  name="ComCostAppViewInputField" tag="ReqAmt">
											</td>
										</tr>
									</tbody>
								</table>
							</div>
							
							<div class="TaccWrap" style="height: 600px;">
								<div class="total_acooungting_write">									
									<!-- 신청유형 별 표시되는 추가정보 -->
									<!-- 프로젝트 비용신청 -->
									<p class="taw_top_sub_title" name="ProjectArea" style="display:none; margin-top: 20px;">
										<spring:message code='Cache.ACC_lbl_projectInfo'/> <!-- 프로젝트 정보 -->
									</p>
									<table class="total_acooungting_table2" name="ProjectArea" style="display:none;">
									    <tbody>
								            <tr>
								                <td class="th"><spring:message code='Cache.ACC_lbl_projectName'/></td> <!-- 프로젝트명 -->
								                <td id="comCostAppView_projectName"></td>
								                <td class="th"><spring:message code='Cache.ACC_lbl_executivePlan'/></td> <!-- 집행계획서 -->
								                <td>
								                	<a href="#" onclick="CombineCostApplicationView.combiCostAppView_LinkOpen('execplan')" id="comCostAppView_execDocSubject"></a>
								                	<input type="hidden" id="comCostAppView_execProcessID" />
								                </td>
								            </tr>         
									    </tbody>
									</table>
									
									<!-- 자기개발비 신청 -->
									<p class="taw_top_sub_title" name="SelfDevelopArea" style="display:none; margin-top: 20px;">
										<spring:message code='Cache.ACC_lbl_selfDevelop'/> <spring:message code='Cache.ACC_lbl_budgetInfo'/> <!-- 자기개발 예산정보 -->
									</p> 
									<table class="total_acooungting_table2" name="SelfDevelopArea" style="display:none;">
							            <tr>
							                <td class="th"><spring:message code='Cache.ACC_lbl_division'/></td> <!-- 구분 -->
							                <td class="th"><spring:message code='Cache.ACC_lbl_budgetAmount'/></td> <!-- 부여금액 -->
							                <td class="th"><spring:message code='Cache.ACC_lbl_UsedAmt'/></td> <!-- 사용금액 -->
							                <td class="th"><spring:message code='Cache.ACC_lbl_remainAmt'/></td> <!-- 잔여금액 -->
							            </tr>
							            <tbody id="comCostAppView_selfDevelopTBODY">
							            </tbody>
							            <tr>
							                <td class="th"><span id="comCostAppView_fiscalYear"></span><spring:message code='Cache.lbl_year'/> <spring:message code='Cache.lbl_sum'/></td> <!-- n년 합계 -->
							                <td id="comCostAppView_totalBudgetAmt" style="text-align:right;"></td>
							                <td id="comCostAppView_totalUsedAmt" style="text-align:right;"></td>
							                <td id="comCostAppView_totalRemainAmt" style="text-align:right;"></td>
							            </tr>
									</table>
									
									<!-- 국내/해외 출장 비용정산 -->
									<p class="taw_top_sub_title" name="BizTripArea" style="display:none; margin-top: 20px;">
										<spring:message code='Cache.ACC_lbl_bizTripRequest'/> <spring:message code='Cache.lbl_FromInfo'/> <!-- 출장신청 정보 -->
									</p>
									<table class="total_acooungting_table2" name="BizTripArea" style="display:none; margin-bottom: 20px;">
									    <tbody>
								            <tr>
								                <td class="th"><spring:message code='Cache.ACC_lbl_projectName'/></td> <!-- 프로젝트명 -->
								                <td tag="ProjectName" name="BizTripField"></td>
								                <td class="th"><spring:message code='Cache.ACC_lbl_executivePlan'/></td> <!-- 집행계획서 -->
								                <td>								                
								                	<a href="#" onclick="CombineCostApplicationView.combiCostAppView_LinkOpen('execplan_biztip')" tag="ExecDocSubject" name="BizTripField"></a>
								                	<input type="hidden" tag="ExecProcessID" name="BizTripField" />
								                </td>
								            </tr>         
									    </tbody>
									</table>
									<table class="total_acooungting_table2" name="BizTripArea" style="display:none;">
									    <tbody>
									    	<colgroup>
									    		<col width="20%">
									    		<col width="23%">
									    		<col width="13%">
									    		<col width="20%">
									    	</colgroup>
								            <tr>
								                <td class="th"><spring:message code='Cache.ACC_lbl_dept'/></td> <!-- 부서 -->
								                <td colspan="2" style="width: 550px;" tag="RequesterDeptName" name="BizTripField"></td>
								                <td class="th"><spring:message code='Cache.lbl_name'/></td> <!-- 이름 -->
								                <td tag="RequesterName" name="BizTripField"></td>
								            </tr>
								            <tr>
								                <td class="th"><spring:message code='Cache.ACC_lbl_bizTripTerm'/></td> <!-- 출장기간 -->
								                <td>
								                	<label tag="StartDate" name="BizTripField"></label> ~ <label tag="EndDate" name="BizTripField"></label>
								                	<label>(</label><label tag="BusinessDay" name="BizTripField"></label><label><spring:message code='Cache.ACC_lbl_day'/>)</label>
								                </td>
								                <td>
								                	<label><spring:message code='Cache.ACC_lbl_workingDay'/> : </label><label tag="WorkingDay" name="BizTripField"></label><label><spring:message code='Cache.ACC_lbl_day'/></label>
								                </td>
								                <td class="th"><spring:message code='Cache.ACC_lbl_bizTripPlace'/></td> <!-- 출장지 -->
								                <td tag="BusinessArea" name="BizTripField"></td>
								            </tr>
								            <tr>
								                <td class="th"><spring:message code='Cache.ACC_lbl_bizTripPurpose'/></td> <!-- 출장목적 -->
								                <td colspan="4" tag="BusinessPurpose" name="BizTripField"></td>
								            </tr>         
									    </tbody>
									</table>
									<table class="total_acooungting_table2" name="OverseaArea" style="display:none; margin-top: 20px;">
									    <tbody>
								            <tr>
								                <td class="th"><spring:message code='Cache.ACC_lbl_exchangeRate'/></td> <!-- 환율 -->
								                <td></td>
								            </tr>
								            <tr>
								                <td class="th"><spring:message code='Cache.ACC_lbl_standard'/><spring:message code='Cache.ACC_lbl_foreignCurrency'/></td> <!-- 기준통화 -->
								                <td></td>
								            </tr>         
									    </tbody>
									</table>
									
									<p class="taw_top_sub_title" name="BizTripArea" style="display:none; margin-top: 20px;"> <!-- 출장비 내역 -->
										<spring:message code='Cache.ACC_lbl_bizTripExpenceList'/>
									</p>
									<table class="total_acooungting_table2"  id="comCostAppView_bizTripList" name="BizTripArea" style="display:none;">
									    <thead>
									    	<tr>
									    		<td class="th" style="width: auto;"><spring:message code='Cache.ACC_lbl_bizTripDate'/></td> <!-- 출장일자 -->
												<td class="th" style="width: auto;"field="Daily" 	><spring:message code='Cache.ACC_lbl_dailyExpence'/></td> <!-- 일비 -->
												<td class="th" style="width: auto;"field="Food" 	><spring:message code='Cache.ACC_lbl_foodExpence'/></td> <!-- 식비 -->
												<td class="th" style="width: auto;"field="Room" 	><spring:message code='Cache.ACC_lbl_roomExpence'/></td> <!-- 숙박비 -->
												<td class="th" style="width: auto;"field="Taxi" 	><spring:message code='Cache.ACC_lbl_taxiExpence'/></td> <!-- 택시비 -->
												<td class="th" style="width: auto;"field="Public" 	><spring:message code='Cache.ACC_lbl_publicExpence'/></td> <!-- 버스지하철 -->
												<td class="th" style="width: auto;"field="Airplain" ><spring:message code='Cache.ACC_lbl_airplainExpence'/></td> <!-- 항공철도 -->
												<td class="th" style="width: auto;"field="Fuel" 	><spring:message code='Cache.ACC_lbl_fuelExpence'/></td> <!-- 유류비 -->
												<td class="th" style="width: auto;"field="Toll" 	><spring:message code='Cache.ACC_lbl_tollExpence'/></td> <!-- 통행료 -->
												<td class="th" style="width: auto;"field="Etc" 		><spring:message code='Cache.lbl_Etc'/></td> <!-- 기타 -->
												<td class="th" style="width: auto;"><spring:message code='Cache.ACC_lbl_daySum'/></td> <!-- 일계 -->
												<td class="th" style="width: auto;"><spring:message code='Cache.ACC_lbl_description'/></td> <!-- 비고 -->
									        </tr>
									    </thead>
									    <tbody>
									    </tbody>
									    <tfoot>
								            <tr>
								            	<td class="th"><spring:message code='Cache.ACC_lbl_itemSum'/></td> <!-- 항목합계 -->
								                <td style="padding-right:5px;" align="right" field="Daily" type="CostSum"></td>
								                <td style="padding-right:5px;" align="right" field="Food" type="CostSum"></td>
								                <td style="padding-right:5px;" align="right" field="Room" type="CostSum"></td>
								                <td style="padding-right:5px;" align="right" field="Taxi" type="CostSum"></td>
								                <td style="padding-right:5px;" align="right" field="Public" type="CostSum"></td>
								                <td style="padding-right:5px;" align="right" field="Airplain" type="CostSum"></td>
								                <td style="padding-right:5px;" align="right" field="Fuel" type="CostSum"></td>
								                <td style="padding-right:5px;" align="right" field="Toll" type="CostSum"></td>
								                <td style="padding-right:5px;" align="right" field="Etc" type="CostSum"></td>
								                <td style="padding-right:5px;" align="right" type="TotalSum"></td>
								                <td></td>
								            </tr>     
									    </tfoot>
									</table>
									
									<p class="taw_top_sub_title" name="BizTripArea" style="display:none; margin-top: 20px;"> <!-- 유류비 내역 -->
										<spring:message code='Cache.ACC_lbl_fuelExpenceList'/>
									</p>
									<table class="total_acooungting_table2"  id="comCostAppView_fuelList" name="BizTripArea" style="display:none;">
									    <thead>
									    	<tr>
									    		<td class="th" style="width: auto;"><spring:message code='Cache.ACC_lbl_bizTripDate'/></td> <!-- 출장일자 -->
									            <td class="th" style="width: auto;"><spring:message code='Cache.ACC_lbl_startPoint'/></td> <!-- 출발지 -->
									            <td class="th" style="width: auto;"><spring:message code='Cache.ACC_lbl_endPoint'/></td> <!-- 도착지 -->
									            <td class="th" style="width: auto;"><spring:message code='Cache.ACC_lbl_fuelType'/></td> <!-- 유류타입 -->
									            <td class="th" style="width: auto;"><spring:message code='Cache.ACC_lbl_distance'/>(km)</td> <!-- 이동거리 -->
									            <td class="th" style="width: auto;"><spring:message code='Cache.ACC_lbl_fuelUnitPrice'/></td> <!-- 유류단가 -->
									            <td class="th" style="width: auto;"><spring:message code='Cache.ACC_lbl_fuelRealPrice'/></td> <!-- 유류실비 -->
									        </tr>
									    </thead>
									    <tbody>
									    </tbody>
									    <tfoot>
								            <tr>
								            	<td class="th" colspan="6"><spring:message code='Cache.ACC_lbl_itemSum'/></td> <!-- 항목합계 -->
								                <td type="TotalSum"></td>
								            </tr>     
									    </tfoot>
									</table>
									
									<div class="total_acooungting_write_status" name="comCostAppView_evidListArea"></div>
								</div>
								<div id="comCostAppView_note">
									
								</div>
							</div>
							
							<span id="CommentList" data-mode="readOnly"></span>
							<div id="CommentListTable" class="tpl-apv-comment" style="display:none;" >
								<h3 id="tableTitle" class="apptit_h3 mt10" style="display: none"><span>@@{title} <spring:message code='Cache.lbl_Opinion'/></span></h3><!-- 의견 -->
								<table class="tableStyle linePlus mt10">
									<colgroup>
										<col style="width:12%;">
										<col id="name" style="width:20%">
										<col id="opinion" style="width:*">
									</colgroup>
									<tbody class="tpl-dynamic-container">
								        <tr class="tpl-dynamic" style="height: 43px;">
											<th id="commentTH"><spring:message code='Cache.lbl_apv_appCom'/></th>		<!-- 결재문서의견 -->
											<td>@@{person}</td>
											<td style="@@{td_style}">@@{comment}</td>
										</tr>
									</tbody>
								</table>
							</div>
						</div>
					</div>
					<!-- 컨텐츠 끝 -->
					<div class="e_formR" style="display: none; padding-left: 45px;" id="comCostAppView_evidPreview">
						<div class="e_formIarea">
							<div class="e_formRTitle">
								<span class="e_TitleText"></span>
								<span class="e_TitleBtn">
									<span class="pagecount"><span class="countB" id="comCostAppView_previewCurrentPage"></span>/<span id="comCostAppView_previewTotalPage"></span></span>
									<span class="pagingType01"><a onclick="accComm.accClickPaging(this);" class="pre"></a><a onclick="accComm.accClickPaging(this);" class="next"></a></span>
								</span>
							</div>
							<div class="e_formRCont" id="comCostAppView_evidContent" style="height: 670px;">
								<div class="billW" style="display: none; padding-top: 100px;"></div>
								<div class="invoice_wrap" style="width:910px; display: none;"></div>
								<input type="hidden" id="comCostAppView_hidReceiptID" value="">			
							</div>
							<div class="wordView" id="comCostAppView_fileContent" style="height: 670px;">
								<iframe id="comCostAppView_iframePreview" name="IframePreview" frameborder="0" width="100%" height="800px" scrolling="no" title=""></iframe>
								<input type="hidden" id="comCostAppView_previewVal" value="">						
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 로딩 이미지  -->
	<div style="background: rgb(0, 0, 0); left: 0px; top: 0px; width: 100%; height: 1296px; position: fixed; z-index: 149; opacity: 0; filter: progid:DXImageTransform.Microsoft.Alpha(opacity=0); -ms-filter:'progid:DXImageTransform.Microsoft.Alpha(opacity=0)'; " id="loading_overlay"></div>
	<div id="divLoading" style="text-align:center;z-index:10;background-color:red;margin:0 auto;position:absolute; top:16%; left:50%; height:20px; margin-left:-10px; margin-top:-10px; ">
		<img src="/HtmlSite/smarts4j_n/covicore/resources/images/covision/loding12.gif" style="text-align:center;" alt=""/>
	</div>
	
	<!-- 전자결재 연동용 iframe -->
	<iframe id="goFormLink" src="" style="display: none;" title=""></iframe>
	<input type="hidden" id="APVLIST" />
	<input type="hidden" id="ACTIONCOMMENT" />
	<input type="hidden" id="ACTIONCOMMENT_ATTACH" value="[]"/>
	<input type="hidden" data-type="field" id="bLASTAPPROVER" value="false" />
</body>
<script>

//ready -> load
$(document).ready(function () {
	 // 양식을 열지 않음 처리 (서명 여부, workitem 값 등 확인 처리)
	var strSuccessYN = ${strSuccessYN};
	var strErrorMsg = "${strErrorMsg}";
	if(strSuccessYN == false){
		alert(strErrorMsg);
		parent.$("[id^=expenceApplicationViewPopup] .divpop_close").click();
		window.close();
	}
});

//증빙 조회 전용
if (!window.CombineCostApplicationView) {
	window.CombineCostApplicationView = {};
}

var printDiv;
var commentPopupTitle = '';
var commentPopupButtonID = '';
var commentPopupReturnValue = false;
var commonWritePopupOnload;

var g_commentAttachList = [];

var g_dicFormInfo = new Dictionary();
var formJson = JSON.parse(Base64.b64_to_utf8('${formJson}'));

(function(window) {
	var openMode = "B";
	var requestType = "";
	var propertyOtherApv = "<%=propertyOtherApv%>";
	var admintype = getInfo("Request.admintype");
	
	var CombineCostApplicationView = {			
			pageOpenerIDStr : "openerID=CombineCostApplicationView&",
			pageName : "CombineCostApplicationView",
			ApplicationType : "",
			isCtrlCode : true,
			pageCombiAppFormList : {
					CorpCardViewFormStr		: "",
					DivViewFormStr			: "",
					TaxBillViewFormStr		: "",
					TaxBillDivViewFormStr	: "",
					PaperBillViewFormStr	: "",
					CashBillViewFormStr		: "",
					PrivateCardViewFormStr	: "",
					EtcEvidViewFormStr		: "",
					ReceiptViewFormStr		: "",
			},

			pageCombiAppComboData : {
				AccountCtrlList	: [],
				TaxTypeList		: [],
				TaxCodeList		: [],
				WHTaxList		: [],
				PayMethodList	: [],
				PayTypeList		: [],
				PayTargetList	: [],
				ProvideeList	: [],
				BillTypeList	: [],
				AccountCtrlMap	: {},
				TaxTypeMap		: {},
				TaxCodeMap		: {},
				WHTaxMap		: {},
				PayMethodMap	: {},
				PayTypeMap		: {},
				PayTargetMap	: {},
				ProvideeMap		: {},
				BillTypeMap		: {},
			},

			pageExpenceAppEvidList : [],
			pageExpenceAppObj : {},
			
			domainData : {},
			tempObj : {},

			pageInit : function(inputParam) {
				var me = this;
				$(".total_acooungting_table2").css("font-size", "13px");
				
				setPropertySearchType('Budget','comCostAppView_PropertyBudget'); //예산관리 사용여부
				$("[name=comCostAppView_evidListArea]").html("");
				me.comCostAppView_FormInit();
				
				g_dicFormInfo.Add("Request.mode", getInfo("Request.mode"));
				g_dicFormInfo.Add("etid","A1");
				
				me.combiCostAppView_displayApvLine();
				me.combiCostAppView_displayBtn();
				
				if(getInfo("Request.expAppID") != ""){
					me.comCostAppView_searchPageData(getInfo("Request.expAppID"));
				}
				me.ApplicationType = me.pageExpenceAppObj.ApplicationType ;
				if(Common.getBaseConfig("IsUseIO") == "N"){
					$("[name=noIOArea]").remove();
					$("[name=colIOSBArea]").attr("colspan", Number($("[name=colIOSBArea]").attr("colspan")) - 1);
					$("[name=FileViewArea]").attr("colspan", Number($("[name=FileViewArea]").attr("colspan")) - 1);
				}
				if(Common.getBaseConfig("IsUseStandardBrief") == "N") {
					$("[name=noSBArea]").remove();
					$("[name=colIOSBArea]").attr("colspan", Number($("[name=colIOSBArea]").attr("colspan")) - 1);
					$("[name=FileViewArea]").attr("colspan", Number($("[name=FileViewArea]").attr("colspan")) - 1);
				}
				if($("#comCostAppView_PropertyBudget").val() == "" || $("#comCostAppView_PropertyBudget").val() == "N") {
					$("[name=noBDArea]").remove();
					$("[name=colIOSBArea]").attr("colspan", Number($("[name=colIOSBArea]").attr("colspan")) - 1);
					$("[name=FileViewArea]").attr("colspan", Number($("[name=FileViewArea]").attr("colspan")) - 1);
				}
				//comCostAppView_inputProofCode //증빙타입
				
				try {
					if (typeof opener.strPiid_List != "undefined" && opener.strPiid_List != "") {
	                    document.getElementById("btPreList").style.display = "";
	                    document.getElementById("btNextList").style.display = "";
	                }
				} catch(e) {}
			},
			pageView : function() {
				var me = this;
			},
			
			//콤보 데이터 조회
			comCostAppView_comboDataInit : function() {
				var me = this;
				
				if(me.isCtrlCode) {
					//관리항목 조회
					$.ajax({
						type:"POST",
							url:"/account/accountCommon/getBaseCodeData.do",
						data:{
							codeGroups : "AccountCtrl",
							CompanyCode : me.pageExpenceAppObj.CompanyCode
						},
						async: false,
						success:function (data) {
							if(data.result == "ok"){
								var codeList = data.list;
								if(codeList.hasOwnProperty('AccountCtrl'))
								{
									me.pageCombiAppComboData.AccountCtrlList = codeList.AccountCtrl;
									me.comCostAppView_makeCodeMap(me.pageCombiAppComboData.AccountCtrlList, "AccountCtrl", "Code", "CodeName");
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
				}
				
				$.ajax({
					type:"POST",
					url:"/account/accountCommon/getBaseCodeDataAll.do",
					data:{
						codeGroups : "TaxType,WHTax,PayMethod,PayType,PayTarget,BillType,CompanyCode",
						CompanyCode : me.pageExpenceAppObj.CompanyCode
					},
					
					success:function (data) {
						if(data.result == "ok"){
							var codeList = data.list
							me.pageCombiAppComboData.TaxTypeList = codeList.TaxType;
							me.pageCombiAppComboData.PayMethodList = codeList.PayMethod;
							me.pageCombiAppComboData.PayTypeList = codeList.PayType;
							me.pageCombiAppComboData.PayTargetList = codeList.PayTarget;

							me.pageCombiAppComboData.WHTaxList = codeList.WHTax;
							
							me.pageCombiAppComboData.ProvideeList = codeList.CompanyCode;
							me.pageCombiAppComboData.BillTypeList = codeList.BillType;
							
							me.comCostAppView_makeCodeMap(me.pageCombiAppComboData.TaxTypeList, "TaxType", "Code", "CodeName");
							me.comCostAppView_makeCodeMap(me.pageCombiAppComboData.PayMethodList, "PayMethod", "Code", "CodeName");
							me.comCostAppView_makeCodeMap(me.pageCombiAppComboData.PayTypeList, "PayType", "Code", "CodeName");
							me.comCostAppView_makeCodeMap(me.pageCombiAppComboData.PayTargetList, "PayTarget", "Code", "CodeName");
							me.comCostAppView_makeCodeMap(me.pageCombiAppComboData.WHTaxList, "WHTax", "Code", "CodeName", true, true, false, false, true);
							me.comCostAppView_makeCodeMap(me.pageCombiAppComboData.ProvideeList, "Providee", "Code", "CodeName");
							me.comCostAppView_makeCodeMap(me.pageCombiAppComboData.BillTypeList, "BillType", "Code", "CodeName");
						}
						else{
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
					}
				});

				$.ajax({
					type:"POST",
					url:"/account/expenceApplication/getTaxCodeCombo.do",
					data:{
						CompanyCode : me.pageExpenceAppObj.CompanyCode
					},
					success:function (data) {
						if(data.result == "ok"){
							me.pageCombiAppComboData.TaxCodeList = data.list
							me.comCostAppView_makeCodeMap(me.pageCombiAppComboData.TaxCodeList, "TaxCode", "Code", "CodeName");
						}
						else{
							Common.Error(data);
						}
					},
					error:function (error){
						Common.Error(error.message);
					}
				});
			},

			CODEMAPSTR : "me.pageCombiAppComboData.",
			comCostAppView_makeCodeMap : function(List, name, dataField, labelField) {
				var me = this;
				for(var i = 0; i<List.length; i++){
					var item = List[i];
					
					//var evalStr = me.CODEMAPSTR+name+"Map[item[dataField]] = item";
					//eval(evalStr);
					me.pageCombiAppComboData[name+"Map"][item[dataField]] = item;
				}
			},
			
			//html폼 로드
			comCostAppView_FormInit : function() {
				var me = this;
				var formPath = Common.getBaseConfig("AccountApplicationFormPath");
				
				$.ajaxSetup({async:false});
				
				$.get(formPath + "CombiCostApp_ViewForm_CorpCard_Apv.html" + resourceVersion, function(val){
					me.pageCombiAppFormList.CorpCardViewFormStr = val;
				});
				$.get(formPath + "CombiCostApp_ViewForm_Div_Apv.html" + resourceVersion, function(val){
					me.pageCombiAppFormList.DivViewFormStr = val;
				});
				$.get(formPath + "CombiCostApp_ViewForm_TaxBill_Apv.html" + resourceVersion, function(val){
					me.pageCombiAppFormList.TaxBillViewFormStr = val;
				});
				$.get(formPath + "CombiCostApp_ViewForm_TaxBillDiv_Apv.html" + resourceVersion, function(val){
					me.pageCombiAppFormList.TaxBillDivViewFormStr = val;
				});
				$.get(formPath + "CombiCostApp_ViewForm_PaperBill_Apv.html" + resourceVersion, function(val){
					me.pageCombiAppFormList.PaperBillViewFormStr = val;
				});
				$.get(formPath + "CombiCostApp_ViewForm_CashBill_Apv.html" + resourceVersion, function(val){
					me.pageCombiAppFormList.CashBillViewFormStr = val;
				});
				$.get(formPath + "CombiCostApp_ViewForm_PrivateCard_Apv.html" + resourceVersion, function(val){
					me.pageCombiAppFormList.PrivateCardViewFormStr = val;
				});				
				$.get(formPath + "CombiCostApp_ViewForm_EtcEvid_Apv.html" + resourceVersion, function(val){
					me.pageCombiAppFormList.EtcEvidViewFormStr = val;
				});
				$.get(formPath + "CombiCostApp_ViewForm_Receipt_Apv.html" + resourceVersion, function(val){
					me.pageCombiAppFormList.ReceiptViewFormStr = val;
				});
			},

			maxViewKeyNo : 0,
			//상세정보 조회
			comCostAppView_searchPageData : function(ExpenceApplicationID) {
				var me = this;
				$.ajax({
					url:"/account/expenceApplication/searchExpenceApplication.do",
					cache: false,
					data:{
						ExpenceApplicationID : ExpenceApplicationID
					},
					success:function (data) {
						
						if(data.result == "ok"){
							me.pageExpenceAppEvidList = data.data.pageExpenceAppEvidList;

						   	for(var i=0;i<me.pageExpenceAppEvidList.length; i++){
						   		var item = me.pageExpenceAppEvidList[i];
								me.maxViewKeyNo++;
								item.ViewKeyNo = me.maxViewKeyNo;
						   	}
						   	
							me.pageExpenceAppObj = data.data;
							me.pageExpenceAppObj.isNew = "N";
							me.pageExpenceAppObj.isSearched = "Y";
							me.pageExpenceAppObj.isModified = "N";
							
							requestType = me.pageExpenceAppObj.RequestType;

							var fieldList =  $("[name=ComCostAppViewInputField]");
						   	for(var i=0;i<fieldList.length; i++){
						   		var field = fieldList[i];
						   		var tag = field.getAttribute("tag")
						   		field.value=nullToBlank(me.pageExpenceAppObj[tag]);
						   	}

							fieldList =  $("[name=ComCostAppViewViewField]");
						   	for(var i=0;i<fieldList.length; i++){
						   		var field = fieldList[i];
						   		var tag = field.getAttribute("tag")
						   		if(tag == "PayDate") {
						   			field.innerHTML = nullToBlank(me.pageExpenceAppEvidList[0].PayDateStr);
						   		} else if (tag == "Sub_UR_Name"){
						   			var subUrCode = me.pageExpenceAppObj["Sub_UR_Code"];
						   			var subUrName = me.pageExpenceAppObj[tag];
						   			var nameFieldHtml = "<div class=\"btnFlowerName\" onclick=\"coviCtrl.setFlowerName(this)\" style=\"position:relative; cursor:pointer;\" data-user-code=\""+subUrCode+"\" data-user-mail>" + CFN_GetDicInfo(subUrName) + "</div>";
						   			field.innerHTML = nameFieldHtml;
						   		} else {
						   			field.innerHTML = nullToBlank(me.pageExpenceAppObj[tag]);
						   		}
						   	}
						   	
						   	//관리항목 사용 여부
						   	//div 테이블의 ReservedStr2 필드에 값이 있으면 true 없으면 false
						   	me.isCtrlCode = (me.pageExpenceAppEvidList[0].divList[0].ReservedStr2_Div ? true : false);
						   	
							for(var i = 0; i<me.pageExpenceAppEvidList.length; i++){
								var item = me.pageExpenceAppEvidList[i];
								if(item.divList != null){
									item = $.extend(item, item.divList[0]); //divList에 있는 세부증빙(div) 정보를 증빙(list) 정보에 추가
								}
								
								if(!me.isCtrlCode) {
									if(requestType == "INVEST") {
										item.InvestItem = item.ReservedStr1;
										item.InvestTarget = item.ReservedStr2;
									}
									if(requestType == "BIZTRIP" || requestType == "OVERSEA") {
										item.BizTripItem = item.ReservedStr1;
										item.BizTripItemNM = item.ReservedStr2;
									}
									if(requestType == "SELFDEVELOP") {
										for(var j = 0; j < item.divList.length; j++) {
											item.divList[j].SelfDevelopDetail = item.divList[j].ReservedStr1_Div;
										}
										item.SelfDevelopDetail = item.ReservedStr1_Div;
									} else if(requestType == "ENTERTAIN") {
										item.EntertainVendor = item.ReservedStr1;
										item.EntertainPurpose = item.ReservedStr2;
										item.InsideAttendantName = item.ReservedStr3;
										item.OutsideAttendantName = item.ReservedStr4;
										item.InsideAttendantNum = item.ReservedInt1;
										item.OutsideAttendantNum = item.ReservedInt2;
									}
								}
							}

						   	if(me.pageExpenceAppObj.ApplicationStatus == "S" && me.pageExpenceAppObj.ApplicationType == "CO") {
								$("[name=comCostAppView_aprvBtn]").css("display", "");
						   	} else if (me.pageExpenceAppObj.ApplicationStatus == "R" || me.pageExpenceAppObj.ApplicationStatus == "C") {	//전표취소 문서 재사용 추가
						   		$("[name=comCostAppView_reuseBtn]").css("display", "");
						   	}
						   	
						   	if(me.pageExpenceAppObj.ApplicationStatus == "E") {			
						   		/* 
								var docCk = false;
								for(var i=0;i<me.pageExpenceAppObj.pageExpenceAppEvidList.length; i++){
									var item = me.pageExpenceAppObj.pageExpenceAppEvidList[i];
									if(!isEmptyStr(item.DocNo)){ //전표번호가 이미 발행된 증빙
										docCk = true;
									}
								}
								
								if(!docCk) { //전표번호 발행된 증빙이 없으면
							   		$("[name=comCostAppView_slipBtn]").css("display", "");
								} else { //전표번호가 발행되었을때만 
									$("[name=comCostAppView_unSlipBtn]").css("display", "");
								} 
								*/
								
								// 전표조회 팝업에서 열었을 때만
								if(getInfo("Request.workitemID") == "") {
									$("[name=comCostAppView_reverseBtn]").css("display", "");
								}
						   	} else if(me.pageExpenceAppObj.ApplicationStatus == "C") {
						   		$("[name=comCostAppView_reverseLabel]").css("display", "");
						   	}

							me.comCostAppView_comboDataInit();
							me.comCostAppView_makeHtmlViewFormAll();
							me.comCostAppView_pageAmtSet();
							
							if(requestType == "BIZTRIP" || requestType == "OVERSEA") {

								var formPath = Common.getBaseConfig("AccountApplicationFormPath");
								
								$.ajaxSetup({async:false});
								
								$.get(formPath + "ExpAppViewForm_BizTripList.html" + resourceVersion, function(val){
									me.pageCombiAppFormList.BizTripExpenceListViewFormStr = val;
								});
								$.get(formPath + "ExpAppViewForm_FuelList.html" + resourceVersion, function(val){
									me.pageCombiAppFormList.FuelExpenceListViewFormStr = val;
								});

								$("[name=BizTripArea]").show();
								if(requestType == "OVERSEA") {
									$("[name=OverseaArea]").show();
								}
								
								//출장신청서 정보 가져오기
								me.comCostAppView_setBizTripRequestInfo(me.pageExpenceAppObj.BizTripRequestID);
								//유류비 내역 가져오기
								me.comCostAppView_loadFuelExpenceList();	 
								//출장비 내역 가져오기
								me.comCostAppView_loadBizTripExpenceList();
							} else if(requestType == "PROJECT") {
								$("[name=ProjectArea]").show();
								
								//프로젝트 정보 가져오기
								me.comCostAppView_setProjectArea();
							} else if(requestType == "SELFDEVELOP") {
								$("[name=SelfDevelopArea]").show();
								
								//비용신청서 별 정보 가져오기
								if(getInfo("Request.expAppID") != "" && getInfo("Request.gloct") != "ADMTEMPSAVE"){
									accComm.getFormLegacyManageInfo(requestType, me.pageExpenceAppObj.CompanyCode, getInfo("Request.expAppID"));
								}else{
									accComm.getFormManageInfo(requestType, me.pageExpenceAppObj.CompanyCode);
								}
								//예산 사용 내역 가져오기
								me.comCostAppView_setSelfDevelopArea();
							}
							
							//감사규칙 위반 건 문서 표시
							displayAuditViolation(me.pageExpenceAppObj.auditCntMap, "comCostAppView_AuditCntArea", true, me.pageExpenceAppObj.AuditReason);
							
							$(".divpop_contents").show();
							ToggleLoadingImage(true);
							
							if(getInfo("Request.mode") != "") {
								me.combiCostAppView_setConfirmRead(); //읽음 확인 - 결재에서 열었을 때만	
							}
							
							accComm.getNoteIsUse(me.pageExpenceAppObj.CompanyCode, me.pageExpenceAppObj.RequestType, 'comCostAppView_note');
							
							var note = nullToBlank(me.pageExpenceAppObj["Note"]);
							// note = note.replace(/(\r\n|\n|\n\n)/gi, '<br/>');	//줄바꿈
							
							$("#comCostAppView_note").html(note);
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

			//조회 폼 생성
			comCostAppView_makeHtmlViewFormAll : function(){
				var me = this;
				var proofCode = "";
				var tableStr = ""; 
				
				for(var i = 0; i<me.pageExpenceAppEvidList.length; i++){
					var getItem = me.pageExpenceAppEvidList[i];
					
					var htmlStr = me.comCostAppView_makeViewHtmlForm(getItem, i+1);
					
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
					
				$("[name=comCostAppView_evidListArea]").html(tableStr);
				if(requestType != 'VENDOR'){
					$("[name=DivViewArea]").hide(); // 상세 지급정보표시용
				}

				proofCode = "";
				for(var i = 0; i<me.pageExpenceAppEvidList.length; i++){
					var getItem = me.pageExpenceAppEvidList[i];
					
					if(proofCode != getItem.ProofCode) {
						proofCode = getItem.ProofCode;
					} else {
						$("tr[name=headerArea][viewkeyno="+getItem.ViewKeyNo+"]").remove();
					}
					
					me.combiCostAppView_makeHtmlChkColspanApv($("[name=evidItemAreaApv][viewkeyno="+getItem.ViewKeyNo+"]"));

					if(isEmptyStr(getItem.TaxInvoiceID) && getItem.ProofCode=="TaxBill"){
						$("[name=noTaxIFView][proofcode="+getItem.ProofCode+"][viewkeyno="+getItem.ViewKeyNo+"]").remove();
					}
					
					if(!isEmptyStr(getItem.PayMethod)) {
						 $("[name=PayArea][proofcode="+getItem.ProofCode+"][viewkeyno="+getItem.ViewKeyNo+"]").show();
					}
										
					if((getItem.docList == null || (getItem.docList != null && getItem.docList.length == 0)) 
							&& (getItem.fileList == null || (getItem.fileList != null && getItem.fileList.length == 0))
							&& getItem.uploadFileList == null)  {
						$("[name=fileDocAreaApv][viewkeyno=" + getItem.ViewKeyNo + "]").remove();
					} else {
						$("[name=evidItemAreaApv][viewkeyno=" + getItem.ViewKeyNo + "]").find("td").each(function(i, obj) { 
							if($(obj).attr("rowspan") != undefined) { 
								$(obj).attr("rowspan", Number($(obj).attr("rowspan"))+1) 
							} 
						});
						
						if(getItem.docList != null){
							for(var y = 0; y<getItem.docList.length; y++){
								var getDoc = getItem.docList[y];
								var str = 						
									"<a href='javascript:void(0);' class='btn_File ico_doc' style='margin-right: 10px;' onClick=\"CombineCostApplicationView.combiCostAppView_LinkOpen('" + getDoc.ProcessID + "', '" + getDoc.forminstanceID + "', '" + getDoc.bstored + "', '" + getDoc.BusinessData2 + "')\">"+ getDoc.Subject+"</a>";
									var getStr = $("[name=DocViewArea][proofcode="+getItem.ProofCode+"][viewkeyno="+getItem.ViewKeyNo+"]").append(str);
							}
						}
						
						if(getItem.fileList != null){
							for(var y = 0; y<getItem.fileList.length; y++){
								var fileInfo = getItem.fileList[y];
								var str = 						
									"<a href='javascript:void(0);' class='btn_File ico_file' style='width: auto;' onClick=\"CombineCostApplicationView.combiCostAppView_FileDownload('"+escape(fileInfo.SavedName)+"','"+escape(fileInfo.FileName)+"','"+fileInfo.FileID+"')\">"+ fileInfo.FileName 
									+"<span class='tx_size'>("+ ckFileSize(fileInfo.Size) +")</span></a>"
									+"<a class='previewBtn' fileid='" + fileInfo.FileID + "' style='margin: 0px 10px;' href='javascript:void(0);' onclick=\"accComm.accAttachFilePreview('" + fileInfo.FileID + "','" + fileInfo.FileToken + "','" + fileInfo.FileName.split(".")[fileInfo.FileName.split(".").length-1].toLowerCase() + "','comCostAppView_','View',true);\"></a>";
									
									var getStr = $("[name=FileViewArea][proofcode="+getItem.ProofCode+"][viewkeyno="+getItem.ViewKeyNo+"]").append(str);
							}
						}
	
						if(getItem.uploadFileList != null){
							for(var y = 0; y < getItem.uploadFileList.length; y++){
								var fileInfo = getItem.uploadFileList[y];
								var str = "<a href='javascript:void(0);' class='btn_File ico_file' style='width: auto;' >" + fileInfo.FileName+"<span class='tx_size'>("+ ckFileSize(fileInfo.Size) +")</span></a>";
								var getStr = $("[name=FileViewArea][proofcode="+getItem.ProofCode+"][viewkeyno="+getItem.ViewKeyNo+"]").append(str);
							}
						}
					}
				}
				
				if(getInfo("Request.loct") == "APPROVAL" && (getInfo("Request.mode") == "APPROVAL" || getInfo("Request.mode") == "RECAPPROVAL" || getInfo("Request.mode") == "REDRAFT")) {
					$("[name=EditArea]").show(); //수정
					$("[name=DivViewArea]").hide();// 상세조회, 수정기능 있으므로 제외
				}
				
				//신청유형 표시
				$("#requestTypeName").html(me.pageExpenceAppObj.RequestTypeName);

				if(me.isCtrlCode) {					
					//관리항목 이전 영역 숨기기
					$("span[name=noV0Area]").hide();
					
					//세부유형 영역 숨기기
					$("span[name=noDTArea]").hide();
				} else {
					//관리항목 영역 숨기기
					$("span[name=noV1Area]").hide();
				}
				
				if (me.pageExpenceAppObj.ApplicationType != "SC") {
					 $("[name=BankArea]").show();
				}
			},
			
			//===========
			//코드 맵 획득
			comCostAppView_getCodeMapInfo : function(codeMap, key, getField) {
				var me = this;
				var retVal = "";
				
				if(codeMap != null && key != null && getField != null) {
					if(codeMap[key] != null){
						retVal = codeMap[key][getField]	
					}
				}
				return retVal
			},
			
			//html 폼의 html 생성 생성
			comCostAppView_makeViewHtmlForm : function(inputItem, rowNum) {
				var me = this;
				if(inputItem != null){
					var CompanyCode = me.pageExpenceAppObj.CompanyCode;
					
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
					
					var TaxCodeNm = me.comCostAppView_getCodeMapInfo(me.pageCombiAppComboData.TaxCodeMap, TC, 'CodeName')
					var TaxTypeNm = me.comCostAppView_getCodeMapInfo(me.pageCombiAppComboData.TaxTypeMap, TT, 'CodeName')
					var PayMethodNm = me.comCostAppView_getCodeMapInfo(me.pageCombiAppComboData.PayMethodMap, PM, 'CodeName')
					var PayTypeNm = me.comCostAppView_getCodeMapInfo(me.pageCombiAppComboData.PayTypeMap, PT, 'CodeName')
					var PayTargetNm = me.comCostAppView_getCodeMapInfo(me.pageCombiAppComboData.PayTargetMap, PG, 'CodeName')
					var ProvideeNm = me.comCostAppView_getCodeMapInfo(me.pageCombiAppComboData.ProvideeMap, PV, 'CodeName')
					var BillTypeNm = me.comCostAppView_getCodeMapInfo(me.pageCombiAppComboData.BillTypeMap, BT, 'CodeName')
					
					var DocNo = inputItem.DocNo;

					var divList = inputItem.divList;
					var divStr = "";
					var divStr2 = "";
					var appType = inputItem.ApplicationType;
					
					for(var y = 0; y<divList.length; y++){
						var divItem = divList[y];
						
						var addUsageComment = "";
						var detailType = ""; //자기개발비, 경조사비
                        var ctrlName = ""; //관리항목
                        var Rownum = divItem.Rownum;

						if(!me.isCtrlCode) {
							if(requestType == "ENTERTAIN") {
								addUsageComment += inputItem.EntertainVendor + "<br>" 
												+ inputItem.InsideAttendantNum + "명(" + inputItem.InsideAttendantName + ") / "
												+ inputItem.OutsideAttendantNum + "명(" + inputItem.OutsideAttendantName + ")";
							} else if(requestType == "SELFDEVELOP") {
								if(divItem.StandardBriefName.indexOf("직무") > -1)  {
									detailType += accComm.getBaseCodeName("JobDevelopmentDetail", inputItem.SelfDevelopDetail, CompanyCode);
								} else {
									detailType += accComm.getBaseCodeName("SelfDevelopmentDetail", inputItem.SelfDevelopDetail, CompanyCode);
								}
							} else if(requestType == "INVEST") {
								detailType += accComm.getBaseCodeName(requestType, inputItem.InvestItem, CompanyCode)
												+ " (" + accComm.getBaseCodeName(requestType, inputItem.InvestTarget, CompanyCode) + ")";
							} else if(requestType == "BIZTRIP" || requestType == "OVERSEA") {
								detailType += inputItem.BizTripItemNM;
							}
						} else {
							////////////////////////////////////////////////////////////////////////////////////
							//관리항목
							////////////////////////////////////////////////////////////////////////////////////
	                        var ctrlJsonVal = divItem.ReservedStr2_Div;
	                       
	                        if (!(ctrlJsonVal == "" || ctrlJsonVal == undefined)) {
	                            var ctrlJsonParse = ctrlJsonVal;
	                            var i = 0;
	                            var data = me.pageCombiAppComboData.AccountCtrlMap;
	                            $.each(ctrlJsonParse, function (key, value) {
	                                var objTempCtrl = new Object();
	                                objTempCtrl.Code = $(data).find("Table > Code").text();
	                                objTempCtrl.CodeName = $(data).find("Table > CodeName").text();
	                                if (data[key] == undefined) {
	                                    if (value != "") {
	                                        ctrlName += "&nbsp;" + value + "<br/>";
	                                    }
	                                }
	                                else {
	                                	if (data[key].Reserved1=='popup') {
	                                        ctrlName += data[key].CodeName + " : " + value + "<span style='width:8px; display:inline-block; vertical-align:top;'>"
	                                        + "<button type='button' key = '" + key + "' rownum='" + Rownum + "' class='btnSearchType01' onClick=\"CombineCostApplicationView."+data[key].Reserved3+"(this, '"+data[key].CodeName + "')\">"
	                                            +  "</button></span><br/>"; 
	                                	}
	                                    else {
	                                        ctrlName += data[key].CodeName + " : " + value + "<br/>";
	                                    }
	                                }
	                                i++;
	                            });
	                        }
						}
                        
						var divValMap = {
								AccountName : nullToBlank(divItem.AccountName),
								StandardBriefName : nullToBlank(divItem.StandardBriefName),
								CostCenterName : nullToBlank(divItem.CostCenterName),
								IOName : nullToBlank(divItem.IOName),
								VendorName : nullToBlank(inputItem.VendorName),
								DocNo : nullToBlank(DocNo),
								UsageComment : nullToBlank(divItem.UsageComment),
								AddUsageComment : addUsageComment, //TODO: 부가적요 표시하기
								DetailType : detailType,
                                CtrlName: ctrlName,
								DivAmount : toAmtFormat(divItem.Amount)
						}
						var htmlDivFormStr = me.pageCombiAppFormList.DivViewFormStr;
						htmlDivFormStr = me.comCostAppView_htmlFormSetVal(htmlDivFormStr, divValMap);
						
						if(y == 0) {
							divStr = htmlDivFormStr;
						} else {
							divStr2 += "<tr>" + htmlDivFormStr + "</tr>"; //세부증빙 여러개일 경우 처리
						}
					}
					
					inputItem.AccountBankName = accComm.getBaseCodeName("Bank", nullToBlank(inputItem.AccountBank), CompanyCode);
					
					if(inputItem.AccountBankName == "") {
						inputItem.AccountBankName = inputItem.AccountBank;
					}

					var valMap = {
							RequestType : requestType,
							ExpenceApplicationListID : nullToBlank(inputItem.ExpenceApplicationListID),
							
							ViewKeyNo : nullToBlank(inputItem.ViewKeyNo),
							ProofCode : nullToBlank(inputItem.ProofCode),
							
							ProofDate : nullToBlank(inputItem.ProofDateStr),
							ProofTime : nullToBlank(inputItem.ProofTimeStr),
							PostingDate : nullToBlank(inputItem.PostingDateStr),
							PayDate : nullToBlank(inputItem.PayDateStr),
							
							TotalAmount : toAmtFormat(nullToBlank(inputItem.TotalAmount)),
							RepAmount : toAmtFormat(nullToBlank(inputItem.RepAmount)),
							TaxAmount : toAmtFormat(nullToBlank(inputItem.TaxAmount)),
							SupplyCost : toAmtFormat(nullToBlank(inputItem.SupplyCost)),
							Tax : toAmtFormat(nullToBlank(inputItem.Tax)),
							
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
							BankInfo : nullToBlank(me.comCostAppView_makeBankInfoStr(inputItem)),
							
							FranchiseCorpName : nullToBlank(inputItem.FranchiseCorpName),
							PersonalCardNo : nullToBlank(inputItem.PersonalCardNo),
							PersonalCardNoView : nullToBlank(inputItem.PersonalCardNoView),

							VendorNo : nullToBlank(inputItem.VendorNo),
							VendorName : nullToBlank(inputItem.VendorName),
							TaxCodeNm : TaxCodeNm,
							TaxTypeNm : TaxTypeNm,
							PayMethod : PayMethodNm,
							PayType : PayTypeNm,
							PayTarget : PayTargetNm,
							PaymentConditionName : nullToBlank(inputItem.PaymentConditionName),							
							
							ProviderName : nullToBlank(inputItem.ProviderName),
							ProviderNo : nullToBlank(inputItem.ProviderNo),
							Providee : ProvideeNm,
							BillType : BillTypeNm,
							
							IsWithholdingTax : nullToBlank(inputItem.IsWithholdingTax),
							IncomTax: nullToBlank(inputItem.IncomTax),
							LocalTax: nullToBlank(inputItem.LocalTax),
							
							pageNm : "CombineCostApplicationView",
							MobileAppClick : "comCostAppView_MobileAppClick",
							FileID : nullToBlank(inputItem.FileID),
					}
					valMap.rowNum = rowNum;
					valMap.rowspan = divList.length;
					valMap.divApvArea = divStr;
					valMap.divApvArea2 = divStr2;
					
					var getForm = me.comCostAppView_htmlFormSetVal(formStr, valMap);
					
					if(!me.isCtrlCode) {
						if(requestType == "SELFDEVELOP") {
							getForm = getForm.replace("ACC_lbl_useHistory2", "ACC_lbl_selfDevelopPlan"); //자기개발비 신청일 경우 적요 -> 자기개발계획 명칭 변경
						}
					}
					
					getForm = me.comCostAppView_htmlFormDicTrans(getForm);
						
					return getForm;
				}
			},
			
			combiCostAppView_makeHtmlChkColspanApv : function(divObj) {
				if(divObj == undefined)
					return;
				
				if(Common.getBaseConfig("IsUseIO") == "N"){
					$(divObj).find("[name=noIOArea]").remove();
					$(divObj).find("[name=accArea]").attr("rowspan", "2");
				}
				if(Common.getBaseConfig("IsUseStandardBrief") == "N") {
					$(divObj).find("[name=noSBArea]").remove();
					$(divObj).find("[name=ccArea]").attr("rowspan", "2");
				}
			   	if($("#comCostAppView_PropertyBudget").val() == "" || $("#comCostAppView_PropertyBudget").val() == "N") {
			   		$(divObj).find("[name=noBDArea]").remove();
					$(divObj).find("[name=slipArea]").attr("rowspan", "2");
				}
			},
			

			comCostAppView_htmlFormSetVal : function(inputStr, replaceMap){
				return accComm.accHtmlFormSetVal(inputStr, replaceMap);
			},

			comCostAppView_htmlFormDicTrans : function(inputStr) {
				return accComm.accHtmlFormDicTrans(inputStr);
			},
			

			//금액 정보 세팅
			comCostAppView_pageAmtSet : function() {
				var me = this;
				
				accComm.accPageAmtSet(me.pageExpenceAppEvidList, "comCostAppView_");
			},
			
			// 거래처비용정산 : 은행계좌 정보 추가표시.
			comCostAppView_makeBankInfoStr : function(item) {
				var BankInfo = ""; // 신한 123-22222-65214 홍길동
				if(item.AccountBankName){
					BankInfo += item.AccountBankName;
				}else if(item.BankName){
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
			
			combiCostAppView_FileDownload : function(SavedName, FileName, FileID){
				accountFileCtrl.downloadFile(SavedName, FileName, FileID)
			},
			combiCostAppView_LinkOpen : function(ProcessId, forminstanceID, bstored, expAppID){
				if(ProcessId == 'execplan') {
					ProcessId = $("#comCostAppView_execProcessID").val();
				} else if(ProcessId == 'execplan_biztip') {
					ProcessId = $("[name=BizTripField][tag=ExecProcessID]").val();
				}
				
				accComm.accLinkOpen(ProcessId, forminstanceID, bstored, expAppID);
			},
			
			//법인카드영수증 조회
			combiCostApp_onCardAppClick  : function(ReceiptID){
				var me = this;
				accComm.accCardAppClick(ReceiptID, me.pageOpenerIDStr);
			},
			//세금계산서 조회
			combiCostApp_onTaxBillAppClick  : function(TaxInvoiceID){
				var me = this;
				accComm.accTaxBillAppClick(TaxInvoiceID, me.pageOpenerIDStr);				
			},
			//지급정보 세부조회
			combiCostApp_onDivDetailClick  : function(ExpListID){
				var me = this;
				accComm.accCombineCostDetClick(ExpListID, me.pageOpenerIDStr, "CO", requestType);
			},
			//모바일영수증 조회
			comCostAppView_MobileAppClick : function(FileID){
				var me = this;
				accComm.accMobileReceiptAppClick(FileID, me.pageOpenerIDStr);
			},

			//결재 호출
			combiCostAppView_callAprv : function() {
				var me = this;
				
				<% if("Y".equals(isUser)){ %>
				
				var data = me.pageExpenceAppObj;
				var type = data.ApplicationType;
				var key = data.ExpenceApplicationID;
				
				if(type=="CO" && key != null){
				   	var msg = "<spring:message code='Cache.ACC_isAppCk' />";
					Common.Confirm(msg, "Confirmation Dialog", function(result){
						if(result){
							
							//감사규칙 체크 후 결재 진행
							checkAuditRule(propertyOtherApv, data, me.combiCostAppView_getHTMLBody(), key, requestType, me.pageExpenceAppObj.CompanyCode);
						}
					});
				}
				<% } %>
			},

			combiCostAppView_fnGoPreNextList : function(objid) {
					var me = this;
					<%
						if("Y".equals(isUser)){
					%>
					
					var sPiid = "";
				    var sWiid = "";
				    var sFiid = "";
				    var sPtid = "";
				    var sMeggage = "";
				    var sCount = "";
				    
				    var sBizData2 = "";
				    var sTaskID = "";
				    var sKind = "";
				    
				    if(opener.strPiid_List == ""){
				    	Common.Warning(Common.getDic("msg_apv_refreshList"), "Warning", function(){ Common.Close(); });
				    }else{
					    /* if (openMode == "L") {
					        var aPiid_List = m_oInfoSrc.strPiid_List.split(";");
					        var aWiid_List = m_oInfoSrc.strWiid_List.split(";");
					        var aFiid_List = m_oInfoSrc.strFiid_List.split(";");
					        var aPtid_List = m_oInfoSrc.strPtid_List.split(";");
					        
					        var aBizData2_List = m_oInfoSrc.strBizData2_List.split(";");
					        var aTaskID_List = m_oInfoSrc.strTaskID_List.split(";");
					    } else { */
					        var aPiid_List = opener.strPiid_List.split(";");
					        var aWiid_List = opener.strWiid_List.split(";");
					        var aFiid_List = opener.strFiid_List.split(";");
					        var aPtid_List = opener.strPtid_List.split(";");
					        
					        var aBizData2_List = opener.strBizData2_List.split(";");
					        var aTaskID_List = opener.strTaskID_List.split(";");
					        var aKind_List = opener.strKind_List.split(";");
					    //}
					    
					    var nPoint = 0;
					    var nTotal = aWiid_List.length - 1;
					
					    for (i = 0; i < nTotal; i++) {
					        if (aWiid_List[i] == "" || aWiid_List[i] == "0") {
					            if (aPiid_List[i] == getInfo("ProcessInfo.ProcessID")) {
					                nPoint = i;
					                i = nTotal;
					            }
					        } else {
					            if ('TCINFO' == getInfo("Request.gloct") && 'COMPLETE' == getInfo("Request.loct")) {   //[2016-01-25 modi kh] 개인결재함 > 참조/회람함 에는 piid 값만 존재 하므로 일괄확인 시 piid로 체크 한다
					                if (aPiid_List[i] == getInfo("ProcessInfo.ProcessID")) {
					                    nPoint = i;
					                    i = nTotal;
					                }
					            }
					            else {
					                if (aWiid_List[i] == getInfo("Request.workitemID")) {
					                    nPoint = i;
					                    i = nTotal;
					                }
					            }
					        }
					    }
					    if (objid == "btPreList") {
					        if (nPoint == 0) sMeggage = Common.getDic("msg_apv_firstPage");
					        else {
					            sPiid = aPiid_List[nPoint - 1].toLowerCase();
					            sWiid = aWiid_List[nPoint - 1].toLowerCase();
					            sFiid = aFiid_List[nPoint - 1].toLowerCase();
					            sPtid = aPtid_List[nPoint - 1].toLowerCase();
					            
					            sBizData2 = aBizData2_List[nPoint - 1].toLowerCase();
					            sTaskID = aTaskID_List[nPoint - 1].toLowerCase();
					            sKind = aKind_List[nPoint - 1];
					            
					            sCount = String(nPoint + 1 - 1) + "/" + String(nTotal);
					        }
					
					    } else if (objid == "btNextList") {
					        if (nPoint == nTotal - 1) sMeggage = Common.getDic("msg_apv_lastPage");
					        else {
					            sPiid = aPiid_List[nPoint + 1].toLowerCase();
					            sWiid = aWiid_List[nPoint + 1].toLowerCase();
					            sFiid = aFiid_List[nPoint + 1].toLowerCase();
					            sPtid = aPtid_List[nPoint + 1].toLowerCase();
					            
					            sBizData2 = aBizData2_List[nPoint + 1].toLowerCase();
					            sTaskID = aTaskID_List[nPoint + 1].toLowerCase();
					            sKind = aKind_List[nPoint + 1];
					            
					            sCount = String(nPoint + 1 + 1) + "/" + String(nTotal);
					        }
					    }
					    
					    if (sMeggage != ""){ Common.Warning(sMeggage); return false;}
					    else if (sPiid != "") {
							var g_mode = getInfo("Request.mode");
					    	var mode = "";
					    	var gloct = "";
							var archived = "false";
							var bstored = "false";
							
							switch (g_mode){
								case "PREAPPROVAL" : 		// 예고함
									mode="PREAPPROVAL";
									gloct = "PREAPPROVAL";
									break;
								case "APPROVAL" :    // 미결함
									mode="APPROVAL";
									gloct = "APPROVAL";
									break;
								case "PROCESS" :		// 진행함
									mode="PROCESS";
									gloct = "PROCESS";
									break;
								case "COMPLETE" : 	// 완료함
									mode="COMPLETE"; 
									gloct = "COMPLETE"; 
									archived="true";
									if (document.getElementById("bstored") != null && document.getElementById("bstored").value == "true") {
										bstored = "true";
									}
									break;
								case "REJECT" : 		// 반려함
									mode="REJECT"; 
									gloct = "REJECT";
									archived="true";
									break;
								case "TCINFO" :		// 참조/회람함 
									mode="COMPLETE";
									gloct = "TCINFO";
									archived = "";
									if (document.getElementById("bstored") != null && document.getElementById("bstored").value == "true") {
										bstored = "true";
									}
									break;
								case "DEPTTCINFO" :		// 참조/회람함 
									mode="COMPLETE";
									gloct = "DEPART";
									archived = "";
									if (document.getElementById("bstored") != null && document.getElementById("bstored").value == "true") {
										bstored = "true";
									}
									break;
								case "DEPTCOMPLETE":	// 부서 참조/회람함(이관함)
									mode="COMPLETE"; 
									gloct = "COMPLETE"; 
									archived="true";
									if (document.getElementById("bstored") != null && document.getElementById("bstored").value == "true") {
										bstored = "true";
									}
									break;
							}
							
					    	var url = "/approval/approval_Form.do?"
					    			+ "&mode="+mode
					    			+ "&processID="+sPiid
					    			+ "&workitemID="+sWiid
					    			+ "&userCode="+sPtid
					    			+ "&gloct="+gloct
					    			+ "&forminstanceID="+sFiid
					    			+ "&admintype="
					    			+ "&archived="+archived
					    			+ "&usisdocmanager=true"
					    			+ "&listpreview=N"
					    			+ "&subkind="+sKind
					    			+ "&ExpAppID="+sBizData2
					    			+ "&taskID="+sTaskID
					    			+ "&bstored="+bstored;
					    	
					    	opener.sNowPiis = sPiid;
					    	document.location.href = url;
					    }
					    return true;
				    }
				    
					<% 
						}
					%>
			},
			
			combiCostAppView_getHTMLBody : function(){
				var evidListArea = $(".inStyleSetting")[0].outerHTML;
				
			    // 버튼 삭제, 체크박스 삭제
			    $(evidListArea).find(".acstatus_wrap").each(function(){ 
			    	$(this).find("a").remove();
			    	$(this).find("input[type=checkbox]").parent().parent().remove();
			    });
				return evidListArea;
			},
			
			combiCostAppView_callReUse : function() {
				var me = this;
				
				/* Common.Confirm("<spring:message code='Cache.ACC_msg_ckReuse' />", "Confirmation Dialog", function(result){	//해당 경비신청 상태를 임시저장으로 변경하시겠습니까?
		       		if(result){
						var ExpenceApplicationID = me.pageExpenceAppObj.ExpenceApplicationID;
						var RequestType = me.pageExpenceAppObj.RequestType;
						$.ajax({
							type:"POST",
							url:"/account/expenceApplication/updateApplicationStatus.do",
							data:{
								ExpenceApplicationID : ExpenceApplicationID,
								RequestType : RequestType
							},
							success:function (data) {
								parent.accountCtrl.pageRefresh();
								parent.$("[id^=expenceApplicationViewPopup] .divpop_close").click();
							},
							error:function (error){
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
							}
						});
		       		}
		        }); */
		        
		        /*
		        	1) 신청 건 복제
		        		- 상태값을 임시저장으로 변경 후 저장해야함
		        		- ExpenceApplicationID/ListID 달라지는거 유의
		        	2) 팝업 닫고 새로고침 하면 임시저장 건 확인 가능
		        */
		        Common.Confirm("<spring:message code='Cache.ACC_msg_ckReuse2' />", "Confirmation Dialog", function(result){	//해당 경비신청을 복제하여 새로운 임시저장 1건을 추가합니다. 
		       		if(result){
						$.ajax({
							type:"POST",
							url:"/account/expenceApplication/insertExpenceApplicationForReuse.do",
							data:{
								ExpenceApplicationID : me.pageExpenceAppObj.ExpenceApplicationID,
								ApplicationTitle : me.pageExpenceAppObj.ApplicationTitle,
								ApprovalLine : JSON.stringify(getApvList($("#APVLIST").val(), "TEMPSAVE")),
								FormName : getInfo("FormInfo.FormName")
							},
							success:function (data) {
								var targetChk = (parent != null && opener == null) ? parent.location.pathname.split('/')[1] : opener.location.pathname.split('/')[1];
								
								if (targetChk == "account") {
									//신청내역조회에서 재사용
									parent.accountCtrl.pageRefresh();
									parent.$("[id^=expenceApplicationViewPopup] .divpop_close").click();
								} else if (targetChk == "approval") {
									//전자결재 반려함에서 재사용
									opener.Refresh();
									window.close();
								} else {
									Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
								}
							},
							error:function (error){
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
							}
						});
		       		}
		        });
			},
			
			combiCostAppView_callEvidPreview : function() {
				var me = this;
				
				accComm.accCallEvidPreview(false, "comCostAppView_", me.pageExpenceAppEvidList);
			},

			combiCostAppView_makeSlip : function(){
				var me = this;
				
				var obj = {};
				
				obj.PostingDateBool = true;
				obj.PostringDateCk = "Y";
				obj.PayDayBool = true;
				obj.PayDayCk = "Y";
				
				obj.ExpenceApplicationID = me.pageExpenceAppObj.ExpenceApplicationID;
		        Common.Confirm("<spring:message code='Cache.ACC_033' />", "Confirmation Dialog", function(result){	//전표를 발행 하시겠습니까?
		       		if(result){
		       			me.combiCostAppView_callMakeSlipAjax(obj);
		       		}
		        });
			},
			combiCostAppView_unMakeSlip : function(){
				var me = this;
				
				var obj = {};
				
				obj.PostingDateBool = true;
				obj.PostringDateCk = "Y";
				obj.PayDayBool = true;
				obj.PayDayCk = "Y";
				
				obj.ExpenceApplicationID = me.pageExpenceAppObj.ExpenceApplicationID;
		        Common.Confirm("<spring:message code='Cache.ACC_msg_unmakeSlip' />", "Confirmation Dialog", function(result){	//전표발행을 취소 하시겠습니까?
		       		if(result){
		       			me.combiCostAppView_callUnMakeSlipAjax(obj);
		       		}
		        });
			},
			
			combiCostAppView_callMakeSlipAjax : function(obj){
				var me = this;
				$.ajax({
					type:"POST",
					url:"/account/expenceApplication/makeSlip.do",
					data:{
						"obj"	: JSON.stringify(obj),
					},
					success:function (data) {
						if(data.result == "ok"){
							Common.Inform("<spring:message code='Cache.ACC_061'/>");	//전표 발행을 완료하였습니다.
							setTimeout(function() {
								parent.accountCtrl.pageRefresh();
								parent.$("[id^=expenceApplicationViewPopup] .divpop_close").click();
								}, 2000);
							
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
					}
				});
			},
			combiCostAppView_callUnMakeSlipAjax : function(obj){

				var me = this;
				$.ajax({
					type:"POST",
					url:"/account/expenceApplication/unMakeSlip.do",
					data:{
						"obj"	: JSON.stringify(obj),
					},
					success:function (data) {
						if(data.result == "ok"){
							Common.Inform("<spring:message code='Cache.ACC_msg_unMaskConfirm'/>");	//전표 발행을 취소하였습니다.
							setTimeout(function() {
								parent.accountCtrl.pageRefresh();
								parent.$("[id^=expenceApplicationViewPopup] .divpop_close").click();
								}, 2000);
						}
					},
					error:function (error){
						Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
					}
				});
			},
			
			combiCostAppView_reverseExpApp : function() {
				var me = this;

	            var expAppID = getInfo("Request.expAppID");

				Common.Confirm("<spring:message code='Cache.ACC_msg_doReverse'/>", "Confirmation Dialog", function(result){ //전표취소 처리하시겠습니까?
					if(result){
						$.ajax({
							type:"POST",
							url:"/account/expenceApplication/reverseExpApp.do",
							data:{
								"ExpAppID" : expAppID,
							},
							success:function (data) {
								if(data.result == "ok"){
									Common.Inform("<spring:message code='Cache.ACC_msg_processComplet'/>");	//처리를 완료하였습니다.
									setTimeout(function() {
										parent.accountCtrl.pageRefresh();
										parent.$("[id^=expenceApplicationViewPopup] .divpop_close").click();
									}, 1000);
								}
							},
							error:function (error){
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
							}
						});
					}
				});
			},
			
			combiCostAppView_displayApvLine : function() {
				var me = this;
				
				if (admintype != "ADMIN" && getInfo("SchemaContext.scCMB.isUse") != "Y" && getInfo("Request.workitemID") != "" && getInfo("Request.workitemID") != "" && getInfo("Request.loct") == "APPROVAL"
		            && (getInfo("Request.mode") == "APPROVAL" || getInfo("Request.mode") == "PCONSULT" || getInfo("Request.mode") == "RECAPPROVAL" || getInfo("Request.mode") == "SUBAPPROVAL" || getInfo("Request.mode") == "AUDIT" )) {
		            setApvList();
		        }
		        else {
		            document.getElementById("APVLIST").value = getInfo("ApprovalLine");
		        }
				
				if (getInfo("Request.mode") == "DRAFT"
					|| getInfo("Request.mode") == "TEMPSAVE"
					|| ((getInfo("Request.loct") == "APPROVAL" || getInfo("Request.loct") == "REDRAFT") && getInfo("Request.mode") == "REDRAFT")
					|| (getInfo("Request.loct") == "REDRAFT" && getInfo("Request.mode") == "SUBREDRAFT" && getInfo("SchemaContext.scRecAssist.isUse") == "Y") //부서협조일경우 수신부서에서 열었을때 접수사용으로 되어 있으면 결재선을 그려 줘야함
				) {
					if (getInfo("Request.reuse") != "P"
						&& openMode != "W"
						&& (getInfo("Request.editmode") != 'Y' || (getInfo("Request.editmode") == 'Y' && getInfo("Request.reuse") == "Y"))) {
						//설정된 결재선 가져오기
						setDomainData();
					}
					else {
						//결재선 그리기
						initApvList();
					}
				} else {
					//결재선 그리기
					initApvList();
				}
				
				if(Common.getBaseConfig("AccountViewApvLineType") == "Graphic") {
					var objGraphicList = ApvGraphicView.getGraphicData(document.getElementById("APVLIST").value);
					ApvGraphicView.initRender($("#graphicDiv"), objGraphicList, "account");
					$("#graphicDiv").parent("div").css("height", "170px");
				} else {
					initApvList();
					$("#divFormApvLines").css("padding", "");
					$("#divFormApvLines").css("padding-bottom", "10px");
				}
			},
			
			combiCostAppView_displayBtn : function() {
				var me = this;
				
				if($("#APVLIST").val() != undefined && $("#APVLIST").val() != "") {
					var m_oApvList = $$($("#APVLIST").val());
					var registerID = $$(m_oApvList).find("division[divisiontype='send'] step ou person").has("taskinfo[kind='charge']").json().code;
					
					if(getInfo("Request.workitemID") != undefined) {
						initBtn(registerID);
						// 연속결재시 버튼 추가제어 - FormMenu.js - initOnloadformmenu 동일하게
						if(getInfo("Request.bserial") == "true"){
							$("#btHold,#btLine,#btDeptLine,#btRejectedto,#btRejectedtoDept,#btBypass").hide();
						}
					}
					
					// 관리자페이지 임시저장문서보기 : 상단 버튼영역 비활성화 (경비결재는 관리자 전표관리)
					if(getInfo("Request.mode") == "TEMPSAVE" && getInfo("Request.gloct") == "ADMTEMPSAVE"){
						//$("#div_formmenu").find("input[type='button'],input[type='checkbox'],a").prop("onclick",null).off("click");
						$("#aprvBtnArea").hide();
					}
				}
			},
			
			combiCostAppView_clickBtn : function(obj) {
				var me = this;
				var btn = $(obj).attr("id");
				
				var mode = getInfo("Request.mode");
				var loct = getInfo("Request.loct");
                var formInstID = getInfo("FormInstanceInfo.FormInstID");
				var processID = getInfo("ProcessInfo.ProcessID");
                var parentProcessID = getInfo("ProcessInfo.ParentProcessID");
				var taskID = getInfo("ProcessInfo.TaskID");
				var subkind = getInfo("ProcessInfo.SubKind");
				var reqUserCode = getInfo("ProcessInfo.UserCode");
                var formName = getInfo("FormInfo.FormName");
                var expAppID = getInfo("Request.expAppID");
                var usid = Common.getSession("USERID");
				
				var sUrl;
				var sSize;
				var iHeight;
				var iWidth;
				
				if(btn == "btLine") {
					var oApproveStep;
					
				    if (mode == "APPROVAL") {
				        var jsonApv = $.parseJSON(document.getElementById("APVLIST").value);
				        oApproveStep = $$(jsonApv).find("steps>division").has("taskinfo[status='pending']").find(">step").has("ou>person[code='" + usid + "']").has("ou>person>taskinfo[status='pending'])");
				    }
				    if (loct == "MONITOR" || loct == "PREAPPROVAL" || loct == "PROCESS" || loct == "REVIEW" || loct == "COMPLETE" || mode == "REJECT" || mode == "JOBDUTY" || mode == "PCONSULT" || mode == undefined || mode == "undefined" || subkind == "T019" || subkind == "T005") { //20110318확인결재추가-확인결재자 결재선변경권한없음
				    	iHeight = 310;
						iWidth = 690;
				        sUrl = "/account/user/ApprovalDetailList.do?ProcessID=" + processID + "&FormInstID=" + formInstID
				        sSize = "scroll";
				    } else if (oApproveStep && oApproveStep.attr("routetype") == "approve" && oApproveStep.attr("allottype") == "parallel") {		// 동시결재자 결재선변경 방지 [2015-11-24]
				        iHeight = 310;
				    	iWidth = 690;
				        sUrl = "/account/user/ApprovalDetailList.do?ProcessID=" + processID + "&FormInstID=" + formInstID
				        sSize = "scroll";
				    } else {
				    	iHeight = 580; 
				    	iWidth = 1110;
				    	sUrl = "/approval/approvalline.do";
				    	sSize = "scrollbars=no,toolbar=no,resizable=no";
				    }
				    
	                CFN_OpenWindow(sUrl, "", iWidth, iHeight, sSize);
					
				} else if(btn == "btPrint" || btn == "btPrintEvid") {
					var printHtml;
					
					if($("#CommentList").children().length != 0) {
						if (confirm(Common.getDic("msg_apv_288").replace(/\\n/g, '\n'))) {//"의견을 포함하여 인쇄하시겠습니까?\n [확인]->[의견포함],\n [닫기]->[의견미포함]"
				            try { document.getElementById("CommentList").style.display = ""; } catch (e) { }
				        } else {
				            try { document.getElementById("CommentList").style.display = "none"; } catch (e) { }
				        }
					}
					if(btn == "btPrint") {
						printHtml = $("#bodytable").clone();
						$(printHtml).find("a.btn_Bill").hide();
						$(printHtml).find("a.previewBtn").hide();
						$(printHtml).find("div.TaccWrap").css("height", "auto");
						
						printDiv = "<html><body>" + $(printHtml).wrapAll("<div/>").parent().html() + "</body></html>";
					} else {
						printHtml = getEvidHTMLEAccount(me.pageExpenceAppEvidList);
						if(printHtml != "") {
							printDiv = "<html><body>" + printHtml + "</body></html>";
						} else {
							Common.Warning("<spring:message code='Cache.ACC_msg_noPrintEvid'/>"); //출력할 증빙이 없습니다.
							return;
						}
					}
					
					sUrl = "/approval/form/Print.do";
					// Popup 방식일 경우 크롬에서 "시스템 대화상자를 사용하여 인쇄" 기능사용시 창이 닫히는 증상이 있어 Iframe 으로 변경
		        	if($("iframe#printIfr").length == 0) {
		        		$(document.body).append("<iframe style='width:0px;height:0px;position:absolute;' id='printIfr'>");
		        	}
		        	$("iframe#printIfr").prop("src", sUrl).prop("isAccount", "Y");
					//CFN_OpenWindow(sUrl, "", iWidth, iHeight, sSize);
				} else if(btn == "btDownloadEvidFile") {
					var fileList = [];
					$(me.pageExpenceAppEvidList).each(function(i, obj) {
					    fileList = $.merge(fileList, obj.fileList);
					});
					
					if(fileList.length == 0) {
						Common.Warning("<spring:message code='Cache.ACC_lbl_noEvidFile'/>"); //저장할 증빙 별 첨부파일이 없습니다.
						return;
					} else {
						var fileName = me.pageExpenceAppObj.ApplicationTitle+'_'+XFN_getCurrDate('.');
					    Common.downloadAll(fileList, fileName);
					}
				} else if(getInfo("Request.bserial") == "true" && $("#" + btn).length > 0) {
					//연속결재의 경우 바로 실행하지 않고 클릭한 버튼 값을 저장한다.
					commentPopupTitle = $(obj).text();
					commentPopupButtonID = btn;
					parent.setStateSerialApprovalList($(obj).attr('id'), $(obj).text(), getInfo("Request.mode"));
				} else {
					var approvalAction = "";
					var bRejectCommentAttach = (Common.getBaseConfig("useRejectCommentAttach") == "Y") ? true : false;
					var popupHeight = 549;
					if(btn == "btApproved") {
						if(mode == "PCONSULT") {
							approvalAction = "AGREE";
						} else {
							approvalAction = "APPROVAL";
						}
					} else if(btn == "btReject") {
						if(mode == "PCONSULT") {
							approvalAction = "DISAGREE";
						} else {
							approvalAction = "REJECT";
						}
						popupHeight = (bRejectCommentAttach) ? 549 : 349; 
					}else if(btn == "btRec") {
						if(mode == "SUBREDRAFT") {
							approvalAction = "REDRAFT";
						} else {
							approvalAction = "APPROVAL";
						}
					} else {
						switch(btn){
						case "btWithdraw": approvalAction = "WITHDRAW"; popupHeight = 349; break;
						case "btAbort": approvalAction = "ABORT"; popupHeight = 349; break;
						case "btHold": approvalAction = "RESERVE"; popupHeight = 349; break;
						case "btDeptDraft": approvalAction = "REDRAFT"; break;
						case "btRejectedtoDept": approvalAction = "REJECTTODEPT"; popupHeight = (bRejectCommentAttach) ? 549 : 349; break;
						}
					}
					
					//기안 취소 / 회수 일 경우 현재 pending 인 결재자의 taskid 넘기기
				    // 진행함에서 부서내반송 클릭하는 경우 => 재기안 회수 처리.
				    if(approvalAction == "ABORT" || approvalAction == "WITHDRAW" || approvalAction == "APPROVECANCEL" || approvalAction == "REJECTTODEPT") {
				    	var apvLineObj = $.parseJSON($("#APVLIST").val());
				    	
				    	var ou = $$(apvLineObj).find("division>step>ou").has("taskinfo[status='pending'],[status='reserved']").concat().eq(0);
				    	var unittype = $$(ou).parent().attr("unittype");
				    	
				    	if(unittype == "ou" && $$(ou).find("person").has("taskinfo[status='pending'],[status='reserved']").concat().eq(0).length > 0)
				    		taskID = $$(ou).find("person").has("taskinfo[status='pending'],[status='reserved']").concat().eq(0).attr("taskid");
				    	else
				    		taskID = $$(ou).attr("taskid");
				    }
	                commentPopupTitle = $(obj).text();
	                commentPopupButtonID = btn;
	                commentPopupReturnValue = false;
	                var commentWritePopup = CFN_OpenWindow("/approval/CommentWrite.do", "", 540, popupHeight, "resize");
                	
	                commonWritePopupOnload = function(){	  
			    		//ToggleLoadingImage(true); 			    		
   			    		if(btn == "btHold") {
   							var sJsonData = {};
   							sJsonData.actionMode = "RESERVE";
   							sJsonData.actionComment = document.getElementById("ACTIONCOMMENT").value;
   							sJsonData.actionUser = gReqUserCode; // 담당업무함인 경우 코드가 다름
   							
   							sJsonData.processID = processID;
   							sJsonData.parentprocessID = parentProcessID;
   							sJsonData.taskID = taskID;
   							
   							// 알림메일 발송용 파라미터
   							var sProcessDescData = {};
   							sProcessDescData.FormSubject = me.pageExpenceAppObj.ApplicationTitle;
   							sJsonData.ProcessDescription = sProcessDescData;
   							sJsonData.FormInstID = formInstID;
   							sJsonData.FormName = formName;
							sJsonData.g_authKey = typeof _g_authKey === "undefined" ? "" : _g_authKey;
							sJsonData.g_authToken = typeof _g_authToken === "undefined" ? "" : _g_authToken;
							sJsonData.g_password = typeof _g_password === "undefined" ? "" : _g_password;
							sJsonData.formID = getInfo("FormInfo.FormID");
			                _g_authKey = "",_g_authToken = "",_g_password = "";		    	
	   						    	    						    
   						    var formData = new FormData();
   						    // 양식 기안 및 승인 정보
							formData.append("formObj", Base64.utf8_to_b64(JSON.stringify(sJsonData)));

   						    try {
   						    	$.ajax({
   						    		url:"/approval/reserve.do",
   						    		data: formData,
   						    		type:"post",
   						    		dataType : 'json',
   						    		processData : false,
   							        contentType : false,
   						    		success:function (res) {    									
   	   						    		if(res.status == "SUCCESS"){
   	   						    			Common.Inform(Common.getDic("msg_170"), "Information", function(){
		   						    			opener.setAccountDocreadCount();
		   		            	    			opener.setDocreadCount();
		   						    			try {
		   						    				// 전자결재 홈화면에서 결재 시 오류 발생하여 예외처리
		   						    				opener.ListGrid.reloadList();
		   						    			} catch(e) {
		   						    				opener.location.reload();
		   						    			}
		   		            	    			window.close(); 
		   		            	    			Common.Close();
   	   						    			});
    									} else{
    										Common.Error(res.message);
    									}
   		            	    			
   						    		},
   						    		error:function(response, status, error){
   										CFN_ErrorAjax("reserve.do", response, status, error);
   									}
   						    	});
   						    } catch (e) {
   						        Common.Error(e.message);
   						    }
   			    		} else {
   			    			if(me.pageExpenceAppObj.isModified == "Y") { //증빙 편집 시 수정된 내역 저장
   			    				var strUrl = "/account/expenceApplication/saveExpenceApplication.do";
   			    				if(me.pageExpenceAppObj.ApplicationType == "CO") {
   			    					strUrl = "/account/expenceApplication/saveCombineCostApplication.do";
   			    				}
   			    				
   			    				me.pageExpenceAppObj.TotalAmt = $("[name=ComCostAppViewInputField][tag=TotalAmt]").val();
   			    				me.pageExpenceAppObj.ReqAmt = $("[name=ComCostAppViewInputField][tag=ReqAmt]").val();
   			    				
   			    				for(var i = 0; i < me.pageExpenceAppEvidList.length;  i++) {
   			    					if(me.pageExpenceAppEvidList[i].RealPayDate != undefined) {
   			    						me.pageExpenceAppEvidList[i].RealPayDate = me.pageExpenceAppEvidList[i].RealPayDate.replace(/\./gi, '');
   			    					}
   			    					if(me.pageExpenceAppEvidList[i].divSum != undefined) {
   			    						me.pageExpenceAppEvidList[i].RealPayAmount = me.pageExpenceAppEvidList[i].divSum;
   			    					}
   			    				}
   			    				
    			    			$.ajax({
    								type:"POST",
    								url:strUrl,
    								data:{
    									saveObj : JSON.stringify(me.pageExpenceAppObj),
    								},
    								async:false,
    								success:function (data) {
    									if(data.result == "ok"){
    										
    									} else if(data.result == "D"){
    										Common.Inform("<spring:message code='Cache.ACC_msg_isExpAppDupl' />");	//이미 저장되어 있는 증빙이 추가되어있습니다.
    									}
    									else{
    										Common.Error(data);
    									}
    								},
    								error:function (error){
    									Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
    								}
    							});
   			    			}
   			    			
    						var apiData = {};
    		                $$(apiData).append("g_action_"+taskID, approvalAction);
    		                $$(apiData).append("g_actioncomment_"+taskID, $("#ACTIONCOMMENT").val());
    		                $$(apiData).append("g_actioncomment_attach_"+taskID, $("#ACTIONCOMMENT_ATTACH").val());
    		                $$(apiData).append("g_signimage_"+taskID, getUserSignInfo(Common.getSession("USERID")));
    		                $$(apiData).append("g_isMobile_"+taskID, "N");
    		                $$(apiData).append("g_isBatch_"+taskID, "N");
    		                if(getInfo("ApprovalLine") != $("#APVLIST").val()) {
    		                	$$(apiData).append("g_appvLine", getApvList($("#APVLIST").val(), approvalAction));
    		                }
    		                $$(apiData).append("isAccount", "Y");    		                $$(apiData).append("g_authKey",typeof _g_authKey === "undefined" ? "" : _g_authKey);
    		                $$(apiData).append("g_authToken",typeof _g_authToken === "undefined" ? "" : _g_authToken);
    		                $$(apiData).append("g_password",typeof _g_password === "undefined" ? "" : _g_password);
    		                _g_authKey = "",_g_authToken = "",_g_password = "";
    		                $$(apiData).append("formID",getInfo("FormInfo.FormID"));
    		                $$(apiData).append("logonId", Common.getSession("USERID"));
    		                $$(apiData).append("g_isModified", "false");
    		                
    			    		$.ajax({
    			    			url: "/approval/legacy/doActionForAccount.do",
    		            	    type: "POST",
    		            	    data: {
    		            			"id" : taskID,
    		            			"data" : JSON.stringify(apiData),
    		            			"formInstID" : formInstID // 문서번호 update 위해 추가
    		            		},
    		            		dataType: "json",
    		            	    success: function (res) {
    		            	    	if(res.status == 'SUCCESS'){
    		            	    		Common.Inform(Common.getDic("msg_apv_alert_006"), "Information", function(){ //성공적으로 처리 되었습니다.
    		            	    			if (getInfo("Request.listpreview") == "Y") { // 결재함 새로고침
    		            						var parentObj = parent.parent;
    		            						parentObj.CoviMenu_GetContent(parentObj.location.href.replace(parentObj.location.origin, ""),false);
    		            						return;
    		            	    			}
    		            	    			else{
    		            						if(opener.setAccountDocreadCount != undefined)opener.setAccountDocreadCount();
    		            						if(opener.setDocreadCount != undefined)opener.setDocreadCount();
    		            					}
    		            	    			try {
    						    				// 전자결재 홈화면에서 결재 시 오류 발생하여 예외처리
    						    				opener.ListGrid.reloadList();
    						    				
    						    				var isEnd = false;
    											if (opener.strPiid_List != '' && opener.strPiid_List != undefined) { // 일괄 확인 처리
    												isEnd = true;
    												if (!me.combiCostAppView_fnGoPreNextList('btNextList')) {
    													isEnd = me.combiCostAppView_fnGoPreNextList('btPreList');
    												}
    												opener.strPiid_List = opener.strPiid_List.replace(getInfo("ProcessInfo.ProcessID") + ";", "");
    												opener.strWiid_List = opener.strWiid_List.replace(getInfo("Request.workitemID") + ";", "");
    												opener.strFiid_List = opener.strFiid_List.replace(getInfo("FormInstanceInfo.FormInstID") + ";", "");
    												opener.strPtid_List = opener.strPtid_List.replace(getInfo("ProcessInfo.UserCode") + ";", "");
    												
    												opener.strBizData2_List = opener.strBizData2_List.replace(getInfo("Request.expAppID") + ";", "");
    												opener.strTaskID_List = opener.strTaskID_List.replace(getInfo("ProcessInfo.TaskID") + ";", "");
    											}
    						    			} catch(e) {
    						    				opener.location.reload();
    						    			}
    						    			
    						    			if (!isEnd) {
    						    				window.close(); 
	    		            	    			Common.Close();
   											}
    		            	    		}); 
    		            	    	} else if(res.status == 'FAIL'){
    		            	    		Common.Error(res.message);
    		            	    	}
    		            	    },
    		            	    error:function(response, status, error){
    		            			CFN_ErrorAjax("/approval/legacy/doActionForAccount.do", response, status, error);
    		            		}
    		            	});
   			    		}
   			    		//ToggleLoadingImage(false);
	    	    	};
				}
				
			},
			
			combiCostAppView_setConfirmRead : function() {
				var me = this;
				
				$.ajax({
					url:"/approval/setConfirmRead.do", //NonApvProcessCon.java
					type:"post",
					data:{
						UserCode : getInfo("ProcessInfo.UserCode"),
						mode : getInfo("Request.mode"),
						loct : getInfo("Request.loct"),
						gloct : getInfo("Request.gloct"),
						subkind : getInfo("ProcessInfo.SubKind"),
						FormInstID : getInfo("FormInstanceInfo.FormInstID"),
						ProcessID : getInfo("ProcessInfo.ProcessID")
					},
					async:false,
					success:function (data) {
						setSubjectHighlight(me);
					},
					error:function(response, status, error){
						CFN_ErrorAjax("/approval/setConfirmRead.do", response, status, error);
					}
				});
			},
			
			// 증빙 편집
			combiCostAppView_clickEdit : function(obj, ExpAppListID) {
				var me = this;
				me.tempObj.ExpAppListID = ExpAppListID;
				
				var iHeight = 500;
				var iWidth = 1000;
				if(me.pageExpenceAppObj.ApplicationType == "CO") {
					iHeight = 650;
					iWidth = 1600;
				}
				
				if(me.pageExpenceAppObj.ApplicationType == "SC") {
					var sUrl = "/account/expenceApplication/SimpleApplicationModify.do?" 
		        			+ me.pageOpenerIDStr
		        			+ "ExpAppListID=" + ExpAppListID
		        			+ "&callBackFunc=comCostAppView_setListEditInfo"
	        				+ "&requesttype=" + requestType;
	       			var sSize = "both";
				} else {
			        var sUrl = "/account/expenceApplication/ExpenceApplicationListEditPopup.do?" 
			        		+ me.pageOpenerIDStr
			        		+ "ExpAppListID=" + ExpAppListID
			        		+ "&callBackFunc=comCostAppView_setListEditInfo"
		        			+ "&requesttype=" + requestType;
			        var sSize = "both";
				}
				
				CFN_OpenWindow(sUrl, "", iWidth, iHeight, sSize);
			},
			
			comCostAppView_setListEditInfo : function(targetObj) {
				var me = this;
				
				$(me.pageExpenceAppEvidList).each(function(i, obj){
					if(obj.ExpenceApplicationListID == me.tempObj.ExpAppListID){
						me.pageExpenceAppEvidList[i] = JSON.parse(JSON.stringify(targetObj));
						return false;
					}
				});
				
				me.comCostAppView_makeHtmlViewFormAll();
				me.comCostAppView_pageAmtSet();
				
				if(requestType == "BIZTRIP" || requestType == "OVERSEA") {
					//출장신청서 정보 가져오기
					me.comCostAppView_setBizTripRequestInfo(me.pageExpenceAppObj.BizTripRequestID);
					//유류비 내역 가져오기
					me.comCostAppView_loadFuelExpenceList();	 
					//출장비 내역 가져오기
					me.comCostAppView_loadBizTripExpenceList();
				} else if(requestType == "SELFDEVELOP") {
					//예산 사용 내역 가져오기
					me.comCostAppView_setSelfDevelopArea();
				}

				me.pageExpenceAppObj.isModified = "Y";
				
				me.tempObj = {};
			},
			
			//////////////////////////////////// 출장비 ////////////////////////////////////
			
			comCostAppView_setBizTripRequestInfo : function(BizTripRequestID) {
				
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
									$("[name=BizTripField][tag=ProjectName]").parents("table").hide();
								} else {
									me.comCostAppView_getExecPlan(getData.ProjectCode); //집행계획서 연결
								}
								
								me.comCostAppView_setFieldList($("[name=BizTripField]"), true, false, getData);
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
			
			comCostAppView_getExecPlan : function(prjCode) {
				var me = this;
				
				if("<%=isUseBizMnt%>" == "Y") {
					$.ajax({
						type:"POST",
						url:"/bizmnt/approval/searchProcessIdOfExecplan.do",
						async: false,
						cache: false,
						data:{
							projectCd : prjCode
						},
						success:function (data) {
							var jsonObj = {};
							if(data.status == "SUCCESS"){
								jsonObj.ExecProcessID = data.processId;
								jsonObj.ExecDocSubject = data.DocSubject;
							}
							else{
								jsonObj.ExecProcessID = "";
								jsonObj.ExecDocSubject = "";
							}
							me.comCostAppView_setFieldList($("[name=BizTripField]"), true, false, jsonObj);
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />");
						}
					});
				}
			},
			
			comCostAppView_setFieldList : function(fieldList, isSet, isInit, pageInfo) {
				for(var i = 0; i<fieldList.length; i++){
					var field = fieldList[i];
					var tag = field.getAttribute("tag");
					var fieldType = field.tagName;
					
					if(isSet) { //필드에 값 세팅
						if(fieldType=="INPUT"){
							field.value = (isInit ? "" : nullToBlank(typeof(pageInfo[tag])=="object" ? JSON.stringify(pageInfo[tag]) : pageInfo[tag]));
						} else if(fieldType=="LABEL" || fieldType=="TD" || fieldType=="A"){
							field.innerHTML = (isInit ? "" : nullToBlank(pageInfo[tag]));
						} else if(fieldType=="SELECT"){
							$(field).val((isInit ? "" : nullToBlank(pageInfo[tag])));
						}
					} else { //json에 값 저장
						if(fieldType=="INPUT"){
							pageInfo[tag] = (isInit ? "" : field.value);
						} else if(fieldType=="LABEL" || fieldType=="TD" || fieldType=="A"){
							pageInfo[tag] = (isInit ? "" : field.innerHTML);
						} else if(fieldType=="SELECT"){
							pageInfo[tag] = (isInit ? "" : $(field).val());
						}
					}
				}
			},
			
			//유류비 내역 가져오기
			comCostAppView_loadFuelExpenceList : function(){
				var me = this;
				
				//초기화
				me.comCostAppView_initFuelExpenceList();
				
				var pageEvidList = me.pageExpenceAppEvidList;
				
				for(var i = 0; i<pageEvidList.length; i++){
					var row = pageEvidList[i];
					
					for(var j = 0; j<row.divList.length; j++) {
						me.comCostAppView_makeFuelExpenceList(row.divList[j]);
					}
				}
				 
			},
			//유류비 내역 초기화
			comCostAppView_initFuelExpenceList : function(){
				var me = this;
				$('#comCostAppView_fuelList').find("tbody > tr").remove();
				$('#comCostAppView_fuelList').find("td[type=TotalSum]").text("0");
				$("#comCostAppView_fuelList").hide();
				$("#comCostAppView_fuelList").prev().hide();
			},
			
			//유류비 내역 만들기
			comCostAppView_makeFuelExpenceList : function(pList){
				var me = this;
		
				var keyno = pList.ViewKeyNo;

				var list = null;
				if(!me.isCtrlCode) {
					list = pList.pageFuelExpenceAppEvidList;
					
					if(list==undefined || list.length==0)
						return;
					
					$("#comCostAppView_fuelList").show();
					$("#comCostAppView_fuelList").prev().show();
				} else {
					if(!pList.ReservedStr3_Div==undefined||$.isEmptyObject(pList.ReservedStr3_Div)||!pList.ReservedStr3_Div.hasOwnProperty('D02'))
						return;

					$("#comCostAppView_fuelList").show();
					$("#comCostAppView_fuelList").prev().show();
					
					list = pList.ReservedStr3_Div['D02'];
					if(list==undefined || list.length==0)
						return;
					
					if(typeof list =='string') {
						list = JSON.parse(list);
						list = list['FuelExpenceAppEvidList']
						if(list==undefined || list.length==0)
							return;
				  	} else {
						list = list['FuelExpenceAppEvidList']
					}
				}
				
				for(var i=0; i<list.length; i++) {
					var item = list[i];
					
					//유류비 내역 양식
					var valMap = {
						ProofCode : item.ProofCode,
						KeyNo : item.KeyNo,
						BizTripDate : item.BizTripDate,
						StartPoint : item.StartPoint,
						EndPoint : item.EndPoint,
						Distance : item.Distance,
						FuelType : item.FuelType,
						FuelTypeNM : item.FuelTypeNM,
						FuelUnitPrice : toAmtFormat(item.FuelUnitPrice),
						FuelRealPrice : toAmtFormat(item.FuelRealPrice)
					};
					
					var html = me.pageCombiAppFormList.FuelExpenceListViewFormStr;
					html = me.comCostAppView_htmlFormSetVal(html, valMap);
					html = me.comCostAppView_htmlFormDicTrans(html);

					$('#comCostAppView_fuelList').find("tbody").append(html);
				}
				

				//재정렬
				var list = $('#comCostAppView_fuelList').find("tbody > tr");
				for(var i=0; i<list.length; i++) {
					for(var j=0; j<(list.length-1)-i; j++) {
						if($(list).eq(j).find("td[field=BizTripDate]").text().replace(/./, '') > $(list).eq(j+1).find("td[field=BizTripDate]").text().replace(/./, ''))
						{
							var html1 = $(list).eq(j)[0].outerHTML;
							var html2 = $(list).eq(j+1)[0].outerHTML;

							$(list).eq(j).replaceWith(html2);
							$(list).eq(j+1).replaceWith(html1);
				        }
				    }
				}
				
				//합계
				me.comCostAppView_sumFuelExpenceList();
			},
			
			//유류비 내역 합계
			comCostAppView_sumFuelExpenceList : function(){
				//유류비
				$('#comCostAppView_fuelList').find("td[type=TotalSum]").text("0");
				var RealPriceTotal = 0;
				$('#comCostAppView_fuelList').find("td[field=FuelRealPrice]").each(function() {
					if($.isNumeric(AmttoNumFormat($(this).text()))) {
						RealPriceTotal += Number(AmttoNumFormat($(this).text()));
					}
				});
				$('#comCostAppView_fuelList').find("td[type=TotalSum]").text(toAmtFormat(RealPriceTotal));
			},
			
			//출장비 내역 가져오기
			comCostAppView_loadBizTripExpenceList : function() {
				var me = this;
				
				//초기화
				me.comCostAppView_initBizTripExpenceList();
				
				var pageEvidList = me.pageExpenceAppEvidList;
				
				for(var i=0; i<pageEvidList.length; i++){
					var row = pageEvidList[i];
					
					var BizTripItem = "";
					if(!me.isCtrlCode) { 
						BizTripItem = row.BizTripItem; 
					} else {						
						if(!row.ReservedStr3_Div==undefined||$.isEmptyObject(row.ReservedStr3_Div)||!row.ReservedStr3_Div.hasOwnProperty('D01'))
							continue;
						BizTripItem = row.ReservedStr3_Div['D01'];	
					}
					
					if(BizTripItem != "Fuel") {
						var ProofDateStr = row.ProofDateStr;
						var Amount = toAmtFormat(row.Amount);
						
						// 첫 번째 증빙의 표준적요와 동일하면 합계 추가
						if(me.isCtrlCode) {
							var SumAmount = parseInt(AmttoNumFormat(Amount));
							for(var j = 1; j < row.divList.length; j++) {
								if(row.divList[j].ReservedStr3_Div['D01'] == row.ReservedStr3_Div['D01']) {
									SumAmount += parseInt(row.divList[j].Amount);
								}
							}
							Amount = toAmtFormat(SumAmount);
						}
						
						if(isEmptyStr(ProofDateStr))
							return;
						
						me.comCostAppView_makeBizTripExpenceList(BizTripItem, ProofDateStr, Amount);
					} else {
						if(!me.isCtrlCode) {
							var popupEvidList = row["page"+BizTripItem+"ExpenceAppEvidList"];
							if(popupEvidList != undefined && popupEvidList.length > 0) {
								for(var j=0; j<popupEvidList.length; j++) {
									var popupRow = popupEvidList[j];
									
									var ProofDateStr = popupRow.BizTripDate;
									var Amount = toAmtFormat(popupRow.FuelRealPrice); 
									
									me.comCostAppView_makeBizTripExpenceList(BizTripItem, ProofDateStr, Amount);
								}			
							} else { // 유류비 팝업에서 입력하지 않았을 경우
								var ProofDateStr = row.ProofDateStr;
								var Amount = toAmtFormat(row.Amount);
								
								if(isEmptyStr(ProofDateStr))
									return;
								
								me.comCostAppView_makeBizTripExpenceList(BizTripItem, ProofDateStr, Amount);
							} 
						} else {
							var ProofDateStr = row.ProofDateStr;
							var Amount = toAmtFormat(row.Amount);
							
							// 첫 번째 증빙의 표준적요와 동일하면 합계 추가
							var SumAmount = parseInt(AmttoNumFormat(Amount));
							for(var j = 1; j < row.divList.length; j++) {
								if(row.divList[j].ReservedStr3_Div['D01'] == row.ReservedStr3_Div['D01']) {
									SumAmount += parseInt(row.divList[j].Amount);
								}
							}
							Amount = toAmtFormat(SumAmount);
							
							if(isEmptyStr(ProofDateStr))
								return;
							
							me.comCostAppView_makeBizTripExpenceList(BizTripItem, ProofDateStr, Amount);
						}
					}
				}
				
				$('#comCostAppView_bizTripList').find("tbody > tr").each(function(index) {					
					$(this).find("td[field=Note]").find("textarea").attr("readonly", "readonly");
					$(this).find("td[field=Note]").find("textarea").css("border", "0px");
					$(this).find("td[field=Note]").find("textarea").css("resize", "none");
					$(this).find("td[field=Note]").find("textarea").removeAttr("onkeyup");
				});
				 
				//합계 
				me.comCostAppView_sumBizTripExpenceList();
				
				if(me.isCtrlCode) {
					$("[field=Food]").hide();
				}
			},

			//출장비 내역 초기화
			comCostAppView_initBizTripExpenceList : function(){
				var me = this;
				//비고 백업
				me.BizTripNoteMap = {};
				if(me.pageExpenceAppObj.BizTripNoteMap != undefined) {
					if(typeof(me.pageExpenceAppObj.BizTripNoteMap) != "string") {
						me.BizTripNoteMap = decodeURI(me.pageExpenceAppObj.BizTripNoteMap);
					} else {
						me.BizTripNoteMap = JSON.parse(decodeURI(me.pageExpenceAppObj.BizTripNoteMap));
					}
				}
				$('#comCostAppView_bizTripList').find("tbody > tr").remove();
				$('#comCostAppView_bizTripList').find("td[type=CostSum]").text("0");
				$('#comCostAppView_bizTripList').find("td[type=TotalSum]").text("0");
			},
			
			//출장비 내역 만들기
			comCostAppView_makeBizTripExpenceList : function(BizTripItem, ProofDateStr, Amount){
				var me = this;
				var targetTr = $('#comCostAppView_bizTripList').find("tr[proofdate=" + ProofDateStr.replace(/\./gi, '') + "]");

				//기존에 없을 경우
				if(targetTr.length == 0) {
					
					//출장비 내역 양식
					var valMap = {
						BizTripDateStr : nullToBlank(ProofDateStr),
						BizTripDate : nullToBlank(ProofDateStr).replace(/\./gi, ''),
						RequestType : requestType
					};
					
					var html = me.pageCombiAppFormList.BizTripExpenceListViewFormStr;
					html = me.comCostAppView_htmlFormSetVal(html, valMap);
					html = me.comCostAppView_htmlFormDicTrans(html);
					
					$('#comCostAppView_bizTripList').find("tbody").append(html);
					
					//tr 추가 후 다시 targeting
					targetTr = $('#comCostAppView_bizTripList').find("tr[proofdate=" + ProofDateStr.replace(/\./gi, '') + "]");
				}
				
				var obj = targetTr.find("td[field="+BizTripItem+"]");
				var note = me.BizTripNoteMap[ProofDateStr];
				if(!isEmptyStr(note)) {
					targetTr.find("td[field=Note]").find("textarea").val(note);
				}
				
				var amountSum = Amount;
				if(obj == null || obj == undefined) {
					amountSum = 0;
				} else {
					if(!isEmptyStr(obj.text())) {
						if($.isNumeric(AmttoNumFormat(obj.text()))) {
							amountSum = Number(AmttoNumFormat(obj.text())) +  Number(AmttoNumFormat(Amount));
						}
					}
					obj.text(toAmtFormat(amountSum));
				}
				
				//td의 type요소가 cost인것 합해서 일계처리
				var daySum = 0;
				targetTr.find("td[type=Cost]").each(function() {
					if(!isEmptyStr($(this).text())) {
					 
						if($.isNumeric(AmttoNumFormat($(this).text()))) {
							daySum += Number(AmttoNumFormat($(this).text()));
						}
					}
				});
				targetTr.find("td[field=DaySum]").text(toAmtFormat(daySum));
				
				//재정렬
				var list = $('#comCostAppView_bizTripList').find("tbody > tr");
				for(var i=0; i<list.length; i++) {
					for(var j=0; j<(list.length-1)-i; j++) {
						if($(list).eq(j).find("td[field=BizTripDate]").text().replace(/\./gi, '') > $(list).eq(j+1).find("td[field=BizTripDate]").text().replace(/\./gi, ''))
						{
							var html1 = $(list).eq(j)[0].outerHTML;
							var html2 = $(list).eq(j+1)[0].outerHTML;
							
							$(list).eq(j).replaceWith(html2);
							$(list).eq(j+1).replaceWith(html1);
						}
				    }
				}
			},
			
			//출장비 내역 합계
			comCostAppView_sumBizTripExpenceList : function(){
				//초기화
				$('#comCostAppView_bizTripList').find("td[type=CostSum]").text("0");
				$('#comCostAppView_bizTripList').find("td[type=TotalSum]").text("0");
				
				//td의 type요소가 cost인것 합해서 항목계처리
				$('#comCostAppView_bizTripList').find("td[type=Cost]").each(function() {
					var field = $(this).attr("field");
					var sumTd = $('#comCostAppView_bizTripList').find("td[type=CostSum][field="+field+"]");
					
					var sumValue = 0;
					sumValue = Number(AmttoNumFormat($(this).text()));
					
					if($.isNumeric(AmttoNumFormat(sumTd.text()))) {
						var sumTotal = Number(AmttoNumFormat(sumTd.text())) + sumValue;
						sumTd.text(toAmtFormat(sumTotal));
					}
				});
				
				//일계 합해서 항목계처리
				var sumTotal = 0;
				$('#comCostAppView_bizTripList').find("td[field=DaySum]").each(function() {
					if($.isNumeric(AmttoNumFormat($(this).text()))) {
						sumTotal += Number(AmttoNumFormat($(this).text()));
					}
				});
				$('#comCostAppView_bizTripList').find("td[type=TotalSum]").text(toAmtFormat(sumTotal));
			},
			
			////////////////////////////////////출장비 ////////////////////////////////////
			
			//자기개발비
			comCostAppView_setSelfDevelopArea : function() {
				var me = this;
				
				var itemArr = accComm["SELFDEVELOP"].pageExpenceFormInfo.StandardBriefInfo[0].item;
				var itemStr = "";
				for(var i = 0; i < itemArr.length; i++) {
				    itemStr += itemArr[i];
				    if(i != itemArr.length-1)
				         itemStr += ",";
				}
				
				var date = new Date();
				if (me.pageExpenceAppEvidList.length>0 && me.pageExpenceAppEvidList[0].PayDateStr != null){
					date = new Date(me.pageExpenceAppEvidList[0].PayDateStr);
					date.setDate(date.getDate()  - 30);	//1달 전데이타로 예산조회 
				}
				var useDate = date.format("yyyy.MM.dd");
				
				$.ajax({
					type:"POST",
					url:"/account/budget/getBudgetInfo.do",
					cache:false,
					async:false,
					data:{
						CostCenter : me.pageExpenceAppObj.RegisterID,
						UseDate : useDate,
						StandardBriefIDs : itemStr // AccountCodes
					},
					success:function (data) {
						if(data.result == "ok"){
							var data = data.list;
							if(data != null && data.length > 0){
								$("#comCostAppView_fiscalYear").html(data[0].FiscalYear);
								var htmlStr = "";
								var totalBudgetAmt = totalUsedAmt = totalRemainAmt = 0;
								$(data).each(function(i, obj) {
									var budgetAmt = (isNaN(obj.BudgetAmount) || obj.BudgetAmount == "") ? 0 : obj.BudgetAmount;
									var usedAmt = (isNaN(obj.UsedAmount) || obj.UsedAmount == "") ? 0 : obj.UsedAmount;
									var remainAmt = budgetAmt - usedAmt;
									
									htmlStr += "<tr>";
									htmlStr += "<td class='th'>" + obj.StandardBriefName + "</td>";
									htmlStr += "<td style=\"text-align:right;\">" + toAmtFormat(budgetAmt) + "</td>";
									htmlStr += "<td style=\"text-align:right;\">" + toAmtFormat(usedAmt) + "</td>";
									htmlStr += "<td style=\"text-align:right;\">" + toAmtFormat(remainAmt) + "</td>";
									htmlStr += "</tr>";
									
									totalBudgetAmt += budgetAmt;
									totalUsedAmt += usedAmt;
									totalRemainAmt += remainAmt;
								});
								$("#comCostAppView_selfDevelopTBODY").html(htmlStr);
								$("#comCostAppView_totalBudgetAmt").html(toAmtFormat(totalBudgetAmt));
								$("#comCostAppView_totalUsedAmt").html(toAmtFormat(totalUsedAmt));
								$("#comCostAppView_totalRemainAmt").html(toAmtFormat(totalRemainAmt));
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
			
			//프로젝트
			comCostAppView_setProjectArea : function() {
				var me = this;
				var IOCodeVal = me.pageExpenceAppEvidList[0].divList[0].IOCode; 
				var IONameVal = me.pageExpenceAppEvidList[0].divList[0].IOName;

				$("#comCostAppView_projectName").html(IONameVal);
				
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
								$("#comCostAppView_execProcessID").val(data.processId);
								$("#comCostAppView_execDocSubject").html(data.DocSubject);
							}
							else{
								$("#comCostAppView_execProcessID").val("");
								$("#comCostAppView_execDocSubject").html("");
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />");
						}
					});	
				}
			},
			
			////////////////////////////////////////////////////////////////////////////////////////////////////////////
			callBizTripPopup : function(obj, name) {
				var me = this;
	            
				var code = $(obj).attr("key");
				var Rownum = $(obj).attr("rownum");
				
                obj = $(obj).closest("tr");
                
                if(!$(obj).attr("viewkeyno")) {
                	obj = $(obj).prevAll("tr[name='evidItemAreaApv']").first();
                }
	            
	            var KeyNo = $(obj).attr("viewkeyno");
				var ProofCode = $(obj).attr("proofcd"); 

	            var popupTit = name;
	            var popupID;
	            var popupName;
	            var width;
	            var height;
	            
	            if(code == "D02") {
	            	//D02: 유류비
		            popupID = "DistancePopup";
		            popupName = "DistancePopup";
		            width = "1000px";
		            height = "800px";
	            } else if(code == "D03") {
	            	//D03: 일비 
            	  	popupID = "DailyPopup";
		            popupName = "DailyPopup";
		            width = "550px";
		            height = "400px";
	            } else if(code == "Z09") {
	            	//Z09: tmap 없는 유류비
		            popupID = "DistancePopup";
		            popupName = "DistancePopup";
		            width = "1000px";
		            height = "550px";
	            }
	            
	            var url =	"/account/accountCommon/accountCommonPopup.do?"
						+	"popupID="		+	popupID			+	"&"
						+	"popupName="	+	popupName		+	"&"
						+	"parentNM="		+	me.pageName		+	"&"
						+	"jsonCode="		+	code			+	"&"
						+	"KeyNo="		+	KeyNo			+	"&"
						+	"ProofCode="	+	ProofCode		+	"&"
						+	"RequestType="	+	requestType		+	"&" 
						+	"Rownum="		+	Rownum			+	"&" 
						+	me.pageOpenerIDStr
						+	"includeAccount=N&"
						+	"IsView=Y&"
						+	"companyCode="	+	me.CompanyCode;
	            
	            Common.open("", popupID, popupTit, url, width, height, "iframe", true, null, null, true);
			},
			
			callAttendantPopup : function(obj, name) {
				var me = this;
	            
				var code = $(obj).attr("key");	
				var Rownum = $(obj).attr("rownum");
				
                obj = $(obj).closest("tr");
                
                if(!$(obj).attr("viewkeyno")) {
                	obj = $(obj).prevAll("tr[name='evidItemAreaApv']").first();
                }
	            
	            var KeyNo = $(obj).attr("viewkeyno");
				var ProofCode = $(obj).attr("proofcd"); 

	            var popupTit = name;
	            var popupID;
	            var popupName;
	            var width;
	            var height;
	            
	            if(code=="C07") {//C07:편익제공
		            popupID = "AttendantPopup";
		            popupName = "AttendantPopup";
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
						+	"Rownum="		+	Rownum		+	"&" 
						+	me.pageOpenerIDStr
						+	"includeAccount=N&"
						+	"IsView=Y&"
						+	"companyCode="	+	me.CompanyCode;
	            
	            Common.open("", popupID, popupTit, url, width, height, "iframe", true, null, null, true);
			}
	}
	window.CombineCostApplicationView = CombineCostApplicationView;
	
	CombineCostApplicationView.pageInit();
})(window);	
</script>
