<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="egovframework.coviframework.util.RedisDataUtil,egovframework.baseframework.util.SessionHelper"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="org.springframework.web.context.support.WebApplicationContextUtils"%>
<%@ page import="egovframework.baseframework.data.CoviList"%>
<%@ page import="egovframework.baseframework.data.CoviMap"%>
<%@ page import="egovframework.coviaccount.user.service.AccountPortalHomeSvc"%>
<%@ page import="org.springframework.web.context.WebApplicationContext"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
	
	ServletContext servletContext = getServletContext();
	WebApplicationContext waContext = WebApplicationContextUtils.getRequiredWebApplicationContext(servletContext);
	AccountPortalHomeSvc service = (AccountPortalHomeSvc) waContext.getBean("AccountPortalHomeSvc");
	
	CoviMap params = new CoviMap();
	params.put("Type", "CEO");
	CoviList sectionList = service.selectPortalSectionSort(params);
	if(sectionList == null || sectionList.size() != 7){
		// when not found sort data
		sectionList = new CoviList();
		CoviMap info1 = new CoviMap();
		info1.put("SectionKey", "widget_quick_link");
		sectionList.add(info1);
		CoviMap info2 = new CoviMap();
		info2.put("SectionKey", "group_report");
		sectionList.add(info2);
		CoviMap info3 = new CoviMap();
		info3.put("SectionKey", "group_status");
		sectionList.add(info3);
		CoviMap info4 = new CoviMap();
		info4.put("SectionKey", "group_history");
		sectionList.add(info4);
		CoviMap info5 = new CoviMap();
		info5.put("SectionKey", "widget_monthly_report");
		sectionList.add(info5);
		CoviMap info6 = new CoviMap();
		info6.put("SectionKey", "widget_monthly_apply");
		sectionList.add(info6);
		CoviMap info7 = new CoviMap();
		info7.put("SectionKey", "widget_monthly_expenses");
		sectionList.add(info7);
	}
%>
  
<style>
	.Gragh_color.blue6 { background-color:#e5e5e5; }
	.DetailRank10 { width:45%; }
	.Detailaccount10 { text-align:right; }
	.Detailaccount10, .Detailaccount30 { width:auto; }
	#monthTooltip{ z-index:9999; position:absolute !important; }
</style>
	<!-- 이어카운팅 포탈 시작-->
	<div id="fixedTabAccCeoViewArea" class="ui_main ui_dashboard ui_dashboard_e_accounting_manager ceo_dashboard">
		<div class="ui_head">
			<h3 class="head_title">e-Accounting</h3>
			<div class="tip" <c:if test="${deadline.IsUse == 'N'}">hidden=""</c:if>>
				<fmt:parseDate value="${fn:replace( deadline.DeadlineFinishDate,'.','')}" var="dlDate" pattern="yyyyMMdd"/>
				<fmt:formatDate value="${dlDate}" pattern="yyyy" var="yyyy"/>					
				<fmt:formatDate value="${dlDate}" pattern="MM" 	 var="mm"/>
				<fmt:formatDate value="${dlDate}" pattern="dd" 	 var="dd"/>
				<fmt:formatDate value="${dlDate}" pattern="E" 	 var="e"/>	
				<p id="deadlineMsg">
			</div>
		</div>
		<div class="ui_content">
			<div data-custom-scrollbar>
				<div class="dashboard_message">
					<div class="ui_alert alert_outlined" data-type="info" role="alert">
						<div class="alert_message">
							<p><spring:message code="Cache.msg_eacc_dashboard_desc"/></p> <!-- 설명 메시지 -->
						</div>
					</div>
				</div>
				<div class="dashboard_list">
				<%
                	boolean isGroupDivDrawn = false;
					int isGroupCnt = 0;
	            	for(int i = 0; i < sectionList.size(); i++){
	            		CoviMap sectionInfo = sectionList.getJSONObject(i);
	            		if("widget_quick_link".equals(sectionInfo.getString("SectionKey"))){
            			
            	%>
					<c:if test="${fn:length(guideList)> 0}">
					<!-- 청구 가이드 -->
					<div class="dashboard_card widget_quick_link" type="widget_quick_link">
						<div class="card_root">
							<dl>
								<dt><spring:message code="Cache.CPEAccounting_ExpenseGuide"/></dt><!-- 경비 청구 가이드 -->
								<dd>
									<ul>
									<c:forEach items="${guideList}" var="list" varStatus="status">
										<li>
											<a href="#"  onclick="board.goViewPopup('Board', '${list.Reserved3}', 1, '${list.Reserved1}', '${list.Reserved2}','W');"
												class="<c:choose>
														    <c:when test="${list.Code == 'URL_INFO1'}">dining</c:when>
														    <c:when test="${list.Code == 'URL_INFO2'}">self</c:when>
														    <c:when test="${list.Code == 'URL_INFO3'}">project</c:when>
														    <c:otherwise>business</c:otherwise>
														</c:choose>">
												<span>${list.CodeName} <spring:message code="Cache.CPEAccounting_claim"/></span><!-- 청구 -->
											</a>
										</li>
									</c:forEach>
									</ul>
								</dd>
							</dl>
						</div>
					</div>
					</c:if>
					<%
	            		}else if(sectionInfo.getString("SectionKey").startsWith("group_")){
	            			if(isGroupCnt == 0){
	            	%>
					<div class="dashboard_group">
					<%
	                   		}
	                   		if("group_report".equals(sectionInfo.getString("SectionKey"))){
	                   			isGroupCnt++;
	               	%>
						<!-- 감사레포팅 -->
						<div class="dashboard_card widget_report" type="group_report">
							<div class="card_root">
								<div class="card_head">
									<div class="title"><spring:message code='Cache.CPEAccounting_AuditReporting'/></div><!-- 감사레포팅 -->
									<div class="action">
										<span class="card_move_handle">
											<span>이동</span>
										</span>
										<button type="button" class="card_more" data-type="AD">
											<span>더보기</span>
										</button>
									</div>
								</div>
								<div class="card_content" id="auditList">
									<ul class="post_list">
										<li>
											<a href="#" class="post_item normal">
												<!-- 동일가맹점 중복 사용 -->
												<strong><spring:message code='Cache.CPEAccounting_AuditList1'/></strong>
												<em>${auditDupStore}<spring:message code='Cache.ACC_lbl_items'/></em>
											</a>
										</li>
										<li>
											<a href="#" class="post_item normal">
												<!-- 접대비 사용보고서 -->
												<strong><spring:message code='Cache.CPEAccounting_AuditList2'/></strong>
												<em>${auditEnterTain}<spring:message code='Cache.ACC_lbl_items'/></em>
											</a>
										</li>
										<li>
											<a href="#" class="post_item normal">
												<!-- 휴일/심야 사용보고서 -->
												<strong><spring:message code='Cache.CPEAccounting_AuditList3'/></strong>
												<em>${auditHolidayUse}<spring:message code='Cache.ACC_lbl_items'/></em>
											</a>
										</li>
										<li>
											<a href="#" class="post_item normal">
												<!-- 규정금액 이상 사용보고서 -->
												<strong><spring:message code='Cache.CPEAccounting_AuditList4'/></strong>
												<em>${auditLimitAmount}<spring:message code='Cache.ACC_lbl_items'/></em>
											</a>
										</li>
										<li>
											<a href="#" class="post_item normal">
												<!-- 사용자 휴가 사용보고서 -->
												<strong><spring:message code='Cache.CPEAccounting_AuditList5'/></strong>
												<em>${auditUserVacation}<spring:message code='Cache.ACC_lbl_items'/></em>
											</a>
										</li>
									</ul>
								</div>
							</div>
						</div>
						<%
                    		}else if("group_status".equals(sectionInfo.getString("SectionKey"))){
                    			isGroupCnt++;
	               		%>
						<!-- 진행단계 -->
						<div class="dashboard_card widget_status" type="group_status">
							<div class="card_root">
								<div class="card_head">
									<div class="title"><spring:message code="Cache.CPEAccounting_ProgressiveStage"/></div>
									<div class="action">
										<span class="card_move_handle">
											<span>이동</span>
										</span>
										<button type="button" class="card_more">
											<span>더보기</span>
										</button>
									</div>
								</div>
								<div class="card_tab ui_tabs">
									<div class="tab_list" role="tablist" id="apprTabs">
										<!-- 승인대기 -->
										<button role="tab" type="button" class="tab" aria-selected="true" data-mode="APPROVAL" data-type="AA">
											<span><spring:message code="Cache.lbl_adstandby"/>(<span id="ApprovalCnt">0</span>)</span>
										</button>
										<!-- 진행 -->
										<button role="tab" type="button" class="tab" aria-selected="false" data-mode="Process" data-type="AP">
											<span><spring:message code="Cache.lbl_apv_goProcess"/>(<span id="ProcessCnt">0</span>)</span>
										</button>
									</div>
								</div>
								<div class="card_content" id="apprTabsList">
									<ul class="post_list" />
								</div>
							</div>
						</div>
						<% 
                        	} else if("group_history".equals(sectionInfo.getString("SectionKey"))){
                        		isGroupCnt++;
                        %>
                        <!-- 사용내역  -->
						<div class="dashboard_card widget_history" id="expsTabs" type="group_history">
							<div class="card_root">
								<div class="card_head">
									<div class="title"><spring:message code="Cache.CPEAccounting_usageDetails"/></div>
									<div class="action">
										<span class="card_move_handle">
											<span>이동</span>
										</span>
										<button type="button" class="card_more">
											<span>더보기</span>
										</button>
									</div>
								</div>
								<div class="card_tab ui_tabs">
									<div class="tab_list" role="tablist">
										<button role="tab" type="button" class="tab" aria-selected="true" id="history_ceocompany_tab" aria-controls="history_ceocompany_tab_panel" data-type="C">
											<span><spring:message code="Cache.ACC_lbl_corpCard"/>(${corpCardListCnt})</span>
										</button>
										<button role="tab" type="button" class="tab" aria-selected="false" id="history_ceotax_tab" aria-controls="history_ceotax_tab_panel" data-type="T">
											<span><spring:message code="Cache.ACC_lbl_TaxInvoice"/>(${taxBillListCnt})</span>
										</button>
										<button role="tab" type="button" class="tab" aria-selected="false" id="history_ceoreceipt_tab" aria-controls="history_ceoreceipt_tab_panel" data-type="R">
											<span><spring:message code="Cache.ACC_lbl_receipt"/>(${billListCnt})</span>
										</button>
									</div>
								</div>
								<!-- 법인카드 -->
								<div role="tabpanel" class="card_content" id="history_ceocompany_tab_panel" aria-labelledby="history_ceocompany_tab">
								<c:choose>
									<c:when test="${fn:length(corpCardList)== 0}">
										<div class="ui_empty">
											<p><spring:message code="Cache.msg_apv_101"/></p><!-- 조회할 목록이 없습니다. -->
										</div>
									</c:when>
									<c:otherwise>
										<ul class="post_list">
											<c:forEach items="${corpCardList}" var="list" varStatus="status">
												<li>
													<div class="post_item">
														<a href="#" class="corpCard" data="${list.ReceiptID}">
															<div class="main">
																<strong>${list.StoreName}</strong>
																<em class="regist_corpcard" data="${list.ReceiptID}">${list.Name}</em>
															</div>
															<div class="secondary">
																<span>${list.AmountWon}</span>
																<time>${list.ApproveDate} ${list.ApproveTime}</time>
															</div>
														</a>
														<c:if test="${empty list.Code}">
															<button type="button" class="regist_corpcard" data="${list.ReceiptID}">
																<span><spring:message code='Cache.lbl_Unregistered'/></span>
															</button>
														</c:if>
													</div>
												</li>
											</c:forEach>
										</ul>                                         
									</c:otherwise>
								</c:choose>
								</div>
								<!-- 세금계산서 -->
								<div hidden role="tabpanel" class="card_content" id="history_ceotax_tab_panel" aria-labelledby="history_ceotax_tab">
									<c:choose>
										<c:when test="${fn:length(taxBillList)== 0}">
											<div class="ui_empty">
												<p><spring:message code="Cache.msg_apv_101"/></p><!-- 조회할 목록이 없습니다. -->
											</div>
										</c:when>
										<c:otherwise>
											<ul class="post_list">
												<c:forEach items="${taxBillList}" var="list" varStatus="status">
													<li>
														<div class="post_item">
															<a href="#" class="taxInvoice"data="${list.TaxInvoiceID}">
																<div class="main">
																	<strong>${list.InvoicerCorpName}</strong>
																</div>
																<div class="secondary">
																	<span>${list.TotalAmount}</span>
																	<time>${list.WriteDate}</time>
																</div>
															</a>
														</div>
													</li>
												</c:forEach>
											</ul>
										</c:otherwise>
									</c:choose>
								</div>
								<!-- 영수증 -->
								<div hidden role="tabpanel" class="card_content" id="history_ceoreceipt_tab_panel" aria-labelledby="history_ceoreceipt_tab">
									<c:choose>
										<c:when test="${fn:length(billList)== 0}">
											<div class="ui_empty">
												<p><spring:message code="Cache.msg_apv_101"/></p><!-- 조회할 목록이 없습니다. -->
											</div>
										</c:when>
										<c:otherwise>
											<ul class="thumb_list">
												<c:forEach items="${billList}" var="list" varStatus="status">
													<li>
														<a href="#" class="thumb_item">
															<span class="preview">
																<img src="/covicore/common/photo/photo.do?img=${list.URLPath}" alt="..." onerror="coviCmn.imgError(this, false);" class="mobileReceipt" data="${list.ReceiptFileID}">
																<c:if test="${empty list.Code}">
																	<strong class="regist_receipt" data="${list.ReceiptID}"><spring:message code='Cache.lbl_Unregistered'/></strong>
																</c:if>
																<c:if test="${not empty list.Code}">
																	<strong class="regist_receipt" data="${list.ReceiptID}">${list.Name}</strong>
																</c:if>
															</span>
															<time>${list.UseDate}</time>
														</a>
													</li>
												</c:forEach>
											</ul>
										</c:otherwise>	
									</c:choose>
								</div>
							</div>
						</div>
						<% 
                       		}
                       		if(isGroupCnt == 3){
                       	%>
					</div>
					<%
                   			}
            			} else if("widget_monthly_report".equals(sectionInfo.getString("SectionKey"))){
             		%>
					<div class="dashboard_card widget_monthly_report" type="widget_monthly_report">
						<div class="card_root">
							<div class="card_head">
								<select class="ui_select_field" id="topReportCate">
									<option value=""><%=SessionHelper.getSession("DN_Name")%></option><!-- 회사명 -->
								</select>
								<!--yyyy년 mm월 리포트 -->
								<div class="title" id="reportCalTxt">${fn:substring(payDate,0,4)}<spring:message code="Cache.lbl_year"/>&nbsp;${fn:substring(payDate,4,6)}<spring:message code="Cache.CPEAccounting_monthReport"/></div>
								<div class="control" id="reportCal">
									<button type="button" class="prev">
										<span>이전</span>
									</button>
									<button type="button" class="next">
										<span>다음</span>
									</button>
								</div>
								<div class="other">
									<strong id="reportExpTot"><fmt:formatNumber value="${totalSummery.amount}" pattern="#,###" /></strong><spring:message code="Cache.ACC_lbl_won"/> 
									<span id="reportExpCnt">(<spring:message code="Cache.ACC_lbl_total"/> ${totalSummery.cnt}<spring:message code="Cache.ACC_lbl_items"/>)</span>
								</div>
							</div>
							<div class="card_content" id="reportDiv">
								<div class="content_item" id="proofDiv">
									<div class="item_head">
										<!-- 용도별 지출현황 -->
										<strong class="title"><spring:message code="Cache.CPEAccounting_chart1Title"/></strong>
										<select class="ui_select_field" id="proofCategory">
											<c:forEach var="list" items="${deptCateList}" varStatus="st">
												<option value="${list.DeptCode}">${list.DeptName}</option>
											</c:forEach>
										</select>
									</div>
									<div class="item_content" id="ceoProofList">
										<div class="ui_chart">
											<canvas id="proofDoughnut" style="display: block; height: 150px; width: 150px;" width="300" height="300" class="chartjs-render-monitor"></canvas>
										</div>
										<div class="data_lists">
											<ul class="list" data-type="usage" id="proofList">
												<c:forEach var="list" items="${proofCount}" varStatus="st">
													<c:if test="${list.AccountCode ne 'Total' }">
														<li code="${list.AccountCode}">
															<a href="#" class="item" data-color="${st.index}">
																<i/>
																<span>${list.AccountName}</span>
																<strong><fmt:formatNumber value="${list.Amount}"/><spring:message code="Cache.ACC_lbl_won"/></strong>
																<em class="up" aria-label="<spring:message code="Cache.CPEAccounting_previousMonth"/>">+100% <b>증가</b></em><!-- 전월대비 -->
															</a>
														</li>
													</c:if>
												</c:forEach>
											</ul>
											<!--슬라이드 버튼 -->						
											<c:set var="totRow" value="${ fn:length(proofCount)/5 }"/>						
											<div class="pagination" role="tablist" ${totRow >= 1 ? "": "hidden"}>
												<c:forEach var="list" begin="1" end="${totRow+( 1-(totRow%1))%1}" step="1" varStatus="st">
													<button type="button" role="tab" aria-selected="true">
														<span>${st.count}</span>
													</button>
												</c:forEach>
											</div>
										</div>
									</div>
									<div class="ui_empty" id="ceoProofEmpty" hidden="">
										<p><spring:message code="Cache.msg_apv_101"/></p><!-- 조회할 목록이 없습니다. -->
									</div>
								</div>
								<div class="content_item" id="accountDiv">
									<div class="item_head">
										<!-- 부서별 지출현황 -->
										<strong class="title"><spring:message code="Cache.CPEAccounting_chart2Title"/></strong>
										<select class="ui_select_field" id="accountCategory">
											<c:forEach var="list" items="${accountCateList}" varStatus="st">
												<option value="${list.AccountCode}">${list.AccountName}</option>
											</c:forEach>
										</select>
									</div>
									<div class="item_content" id="ceoAccountList">
										<div class="ui_chart">
											<canvas id="accountDoughnut" width="300" height="300" style="display: block; height: 150px; width: 150px;" class="chartjs-render-monitor"></canvas>
										</div>
										<div class="data_lists">
											<ul class="list" data-type="department" id="accountList">
												<c:forEach var="acctCont" items="${accountCount}" varStatus="st">
													<c:if test="${acctCont.Code ne 'Total' and st.index <= 5 }">
														<li>
															<a href="#" class="item" data-color="${st.index <= 5 ? st.index : other}">
																<i/>
																<span>${acctCont.Name}</span>
																<strong><fmt:formatNumber value="${acctCont.Amount}"/><spring:message code="Cache.ACC_lbl_won"/></strong>
																<em class="up" aria-label="<spring:message code="Cache.CPEAccounting_previousMonth"/>">+98%</em>
															</a>
														</li>
													</c:if>
												</c:forEach>
											</ul>
											<!--슬라이드 버튼 -->
											<c:set var="totRow" value="${ fn:length(accountCount)/5 }"/>
											<div class="pagination" role="tablist" ${totRow >= 1 ? "": "hidden"}>
												<c:forEach var="list" begin="1" end="${totRow+( 1-(totRow%1))%1}" step="1" varStatus="st">
													<button type="button" role="tab" aria-selected="true">
														<span>${st.count}</span>
													</button>
												</c:forEach>
											</div>
										</div>
									</div>
									<div class="ui_empty" id="ceoAccountEmpty" hidden="">
										<p><spring:message code="Cache.msg_apv_101"/></p><!-- 조회할 목록이 없습니다. -->
									</div>
								</div>
							</div>
						</div>
					</div>
					<%
	            		}else if("widget_monthly_apply".equals(sectionInfo.getString("SectionKey"))){
	                %>
					<div class="dashboard_card widget_monthly_apply" id="monthChartTit" type="widget_monthly_apply">
						<div class="card_root">
							<div class="card_head">
								<select class="ui_select_field" id="topMonthCate">
									<option value=""><%=SessionHelper.getSession("DN_Name")%></option>
								</select>
								<!-- 월별 신청내역 -->
								<div class="title">${yyyy}<spring:message code="Cache.lbl_year"/> <spring:message code="Cache.CPEAccounting_monthDetails"/></div>
								<div class="control" id="monthCal">
									<button type="button" class="prev">
										<span>이전</span>
									</button>
									<button type="button" class="next">
										<span>다음</span>
									</button>
								</div>
							</div>
							<div class="card_content">
								<div id="chart3_legend" class="ui_chart_legend"></div>
								<div class="ui_chart" style="height:350px;">
									<canvas id="monthChart" width="1440" height="350" style="display: block; width: 1440px; height: 350px;" class="chartjs-render-monitor"></canvas>
								</div>
							</div>
						</div>
					</div>
					<%
	            		}else if("widget_monthly_expenses".equals(sectionInfo.getString("SectionKey"))){
	                %>
					<div class="dashboard_card widget_monthly_expenses" type="widget_monthly_expenses">
						<div class="card_root">
							<div class="card_head">
								<select class="ui_select_field" id="topBudgetCate">
									<option value=""><%=SessionHelper.getSession("DN_Name")%></option>							
								</select>
								<!-- 월별 예산대비 지출 현황 -->
								<div class="title"><font id="budgetTitle">${yyyy}<spring:message code="Cache.lbl_year"/></font>
									<select class="selectType02" id="budgetCategory" style="${fn:length(budgetStd)==1?'display:none':''}">
									<c:forEach items="${budgetStd}" var="list" varStatus="status">
										<option value="${list.Code}†${list.Reserved1}†${list.Reserved2}">${list.CodeName}</option>
									</c:forEach>
									</select> 
									<c:if test="${fn:length(budgetStd)==1}"><em>${budgetStd[0].CodeName}</em> </c:if>
									<spring:message code="Cache.CPEAccounting_ceoBudgetTitle"/>
								</div>
								<div class="control" id="budgetCal">
									<button type="button" class="prev">
										<span>이전</span>
									</button>
									<button type="button" class="next">
										<span>다음</span>
									</button>
								</div>
							</div>
							<div class="card_content">
								<div>
									<div class="budget"><spring:message code="Cache.ACC_lbl_budget"/> <em id="budgetAmount"><fmt:formatNumber value="${budgetTotal.BudgetAmount}" pattern="#,###" /></em><span id="baseTermTitle"><spring:message code="Cache.ACC_lbl_won"/></span></div>
									<div class="history">
										<dl>
											<!-- 지출 -->
											<dt><spring:message code="Cache.CPEAccounting_budgetUsed"/></dt>
											<dd id="UsedAmount"><fmt:formatNumber value="${budgetMonthList[12].UsedAmount}" pattern="#,###" /><spring:message code="Cache.ACC_lbl_won"/></dd>
										</dl>
										<dl>
											<!-- 진행 -->
											<dt><spring:message code="Cache.CPEAccounting_budgetProcess"/></dt>
											<dd id="processAmount"><fmt:formatNumber value="${budgetMonthList[12].pending}" pattern="#,###" /><spring:message code="Cache.ACC_lbl_won"/></dd>
										</dl>
										<dl>
											<!-- 잔액 -->
											<dt><spring:message code="Cache.CPEAccounting_budgetLeft"/></dt>
											<dd id="leftAmount"><fmt:formatNumber value="${budgetTotal.BudgetAmount-budgetMonthList[12].UsedAmount}" pattern="#,###" /><spring:message code="Cache.ACC_lbl_won"/></dd>
										</dl>
									</div>
									<div class="ui_chart" style="height:260px;">
										<canvas id="budgetChart" width="1440" height="260" style="display: block; width: 1440px; height: 260px;" class="chartjs-render-monitor"></canvas>
									</div>
								</div>
							</div>
						</div>
					</div>
					<% 
		                	}//end if
		                }//end for
	                %>
				</div>
				<div class="dashboard_action">
					<button type="button" class="ui_button" id="cancelDashboardEdit"><span><spring:message code="Cache.btn_Cancel"/></span></button><!-- 취소 -->
					<button type="button" class="ui_button primary" onclick="sortCeoPortalSectionTab();"><span><spring:message code="Cache.btn_Apply"/></span></button><!-- 적용 -->
				</div>
			</div>
		</div>
		<button type="button" class="ui_floating_action_button" data-icon="setting" id="activateDashboardEdit" data-tooltip-title="<spring:message code='Cache.lbl_dashboardSetting'/>" data-tooltip-position="left">
			<span>설정</span>
		</button>
	</div>
	        
<script>

	var ProfileImagePath = Common.getBaseConfig('ProfileImagePath').replace("{0}", Common.getSession("DN_Code"));
    // 차트공통 옵션 start 
	const $textPrimaryColor = getComputedStyle(document.documentElement).getPropertyValue('--text-primary') || '#222222';
	const $paperSecondaryColor = getComputedStyle(document.documentElement).getPropertyValue('--paper-secondary') || '#f8f8f8';
	const $borderSecondaryColor = getComputedStyle(document.documentElement).getPropertyValue('--border-primary') || '#dddddd';

	const canvasBackgroundColor = {
        id: 'canvasBackgroundColor',
        beforeDraw: function (chart) {
            chart.ctx.fillStyle = $paperSecondaryColor;
            chart.ctx.fillRect(chart.chartArea.left, chart.chartArea.top, chart.chartArea.right - chart.chartArea.left,
                chart.chartArea.bottom - chart.chartArea.top);
        }
    };
    const chartScales = {
        xAxes: [
            {
                stacked: true,
                gridLines: {
                    color: $borderSecondaryColor,
                    zeroLineColor: $borderSecondaryColor,
                    drawTicks: false
                },
                ticks: {
                    padding: 10
                }
            }
        ],
        yAxes: [
            {
                stacked: true,
                gridLines: {
                    color: $borderSecondaryColor,
                    zeroLineColor: $borderSecondaryColor,
                    drawTicks: false
                },
                ticks: {
                    padding: 10
                }
            }
        ]
    };
    Chart.defaults.global.defaultFontFamily = 'NotoSans';
    Chart.defaults.global.defaultFontSize = 12;
    Chart.defaults.global.defaultFontColor = $textPrimaryColor;
    const defaultLegendClickHandler = Chart.defaults.global.legend.onClick;
 	// 차트공통 옵션 end
    
    
	/* 공통함수 */
	var mngComm = {		
		getData : function(purl,param){				
			var deferred = $.Deferred();
			$.ajax({
				url: purl,
				type:"POST",
				data: param,			
				success:function (data) { deferred.resolve(data);},
				error:function(response, status, error){ deferred.reject(status); }
			});				
		 	return deferred.promise();
		}
		,makeComma : function( value ){ return String(value).replace(/(\d)(?=(?:\d{3})+(?!\d))/g, '$1,') }
		,lpad : function( str ){ return /^[0-9]$/.exec(str) ? String(str).replace( /^([0-9])$/, '0$1' ) : String(str) }
		,getPrevDate : function( str ){ 
			var dateArr 		= /(\d{4})(\d{2})/.exec( str );
			var strYear  		= this.lpad( (dateArr[2]-1) * 1 === 0 ? dateArr[1]-1 : dateArr[1] );
            var strMonth 		= this.lpad( (dateArr[2]-1) * 1 === 0 ? 12 : (dateArr[2]-1) );
            return strYear+strMonth;			
		}
		,getNextDate : function( str ){ 
			var dateArr 		= 	/(\d{4})(\d{2})/.exec( str );
			var date  			=   new Date( dateArr[1] , dateArr[2] , 1 );
			var strYear  		=   date.getFullYear();
            var strMonth   		=   this.lpad( date.getMonth()+1 );
			return strYear+strMonth;	
		}
		,addEvent : function(){				
			
			/* 리포트 이벤트 */
			reportTopObj.addEvent();
			
			/* 월별 신청내역 이벤트 */			
			monthChartObj.addEvent();
						
			/* 예산대비 지출현황 이벤트 */			
			budgetChartObj.addEvent();			

			$("#topReportCate,#topMonthCate,#topBudgetCate,#budgetCategory").on( 'change', function(){
				var attr =  this.getAttribute('id');
				attr === 'topReportCate' 	&& reportTopObj.changeReport();
				attr === 'topMonthCate'		&& monthChartObj.changeChart();
				attr === 'topBudgetCate' 	&& budgetChartObj.changeChart();
				attr === 'budgetCategory' 	&& budgetChartObj.changeChart();
			});	
						
			/* 승인대기, 진행 */
			$("#apprTabs #ApprovalCnt").text( $("li.eaccountingMenu02 a[id$=Approval] span.fCol19abd8").text().trim());
			$("#apprTabs #ProcessCnt").text( $("li.eaccountingMenu02 a[id$=Process] span.fCol19abd8").text().trim());
			
			$("#apprTabsList").on('click',function(){
				var value = $(event.target).closest('.post_list li').data('item');
				var mode = $("#apprTabs [aria-selected=true]").data('mode');
				value && onClickPopButton(value.ProcessID,value.WorkItemID,value.TaskID,value.PerformerID,value.ProcessDescriptionID,value.FormInstID,value.FormSubKind,value.UserCode,value.FormID,value.BusinessData2,mode);
			});
			
			$("#apprTabs .tab").on('click',function(){							
				var idx = $("#apprTabs .tab").index(this);
				var obj = $("#apprTabs").parent().next().find("ul");
				var dataObj = this.dataset;				
				mngComm.getData("/approval/user/getApprovalListData.do",{ 
						mode : dataObj.mode
						,searchGroupType:"" 
						,bstored: "false"
						,userID: Common.getSession().UR_Code
						,businessData1: "ACCOUNT"
						,pageSize: "3"
						,pageNo: "1" })
				.done(function( data ){					
					obj.empty().append(
						data.list.length > 0 		
							? data.list.map( function( item,idx ){
								var $li = $("<li>").data( 'item',item );
								$li.append(
									$("<a>",{ "class" : "post_item"})
									.append(
										$("<div>",{ "class" : "ui_avatar" }).append($("<img>",{ "src" : coviCmn.loadImage(item.PhotoPath), "onerror" : "coviCmn.imgError(this, true)"})))
									.append(
										$("<div>",{ "class" : "info" })
										.append($("<div>",{ "class" : "main" })
											.append($("<strong>", {"text" : item.FormSubject}))
											.append($("<em>", {"text" : mngComm.makeComma(item.BusinessData3)+'<spring:message code="Cache.ACC_lbl_won"/>'})))
										.append($("<div>",{ "class" : "secondary" })
											.append($("<span>",{ "text" : item.InitiatorName }))
											.append($("<time>",{ "text" : dataObj.mode === "APPROVAL" ? item.Created : item.Finished })))
									)
								).appendTo( $li );
								return $li;
							})
						: $("<div>",{ "class" : "ui_empty", "text" : "<spring:message code='Cache.msg_apv_101'/>" }) //조회할 목록이 없습니다.
					);
				})
				.fail(  function( e ){  console.log(e) });
			}).eq(0).trigger('click');
			
			/* 감사규칙 링크 */
			$("#auditList a").on('click',function(){ $("#account_AuditReportaccountuserAccount").trigger('click') });
			
			//법인카드
			$('#fixedTabAccCeoViewArea .corpCard').find("strong, .secondary").click(function(){
				mngComm.cardReceiptPopup($(this).closest('.corpCard').attr("data"));
			});
			//세금계산서
			$('#fixedTabAccCeoViewArea .taxInvoice').click(function(){
				mngComm.taxInvoicePop($(this).attr("data"));
			});
			//영수증팝업
			$('#fixedTabAccCeoViewArea .mobileReceipt').click(function(){
				mngComm.mobileReceiptPopup($(this).attr("data"));
			});
			//법인카드 - 계정과목(표준적요)/적요
			$('#fixedTabAccCeoViewArea .regist_corpcard').click(function(){
				mngComm.usageTextWritePopup($(this).attr("data"), "CorpCard");
			});
			//영수증 - 계정과목(표준적요)/적요
			$('#fixedTabAccCeoViewArea .regist_receipt').click(function(){
				mngComm.usageTextWritePopup($(this).attr("data"), "Receipt");
			});
			
			/*more */
			$("#fixedTabAccCeoViewArea .card_more").on("click", function(){
			 	// 현재 선택된 탭 그룹 찾기
			    const tabGroup = $(this).closest('.card_root').find('.tab_list');
			    const selectedTab = tabGroup.find('.tab[aria-selected="true"]');
				var me = $(this);
				switch (me.attr("data-type") || selectedTab.attr("data-type")){
					case "C":	//법인카드
						eAccountContentHtmlChangeAjax('account_CardReceiptUseraccountuserAccount'
								, "<spring:message code='Cache.ACC_lbl_corpCardUseList' />"
								, '/account/layout/account_CardReceiptUser.do?CLSYS=account&CLMD=user&CLBIZ=Account'
								, {callType:"Portal"});
						break;
					case "A":	//전표조회
						eAccountContentHtmlChangeAjax('account_ExpenceApplicationManageUseraccountuserAccount'
								, "<spring:message code='Cache.ACC_lbl_expenceApplicationView' />"
								, '/account/layout/account_ExpenceApplicationManageUser.do?CLSYS=account&CLMD=user&CLBIZ=Account'
								, {callType:"Portal"});
						break;
					case "T":	//세금계산서
						eAccountContentHtmlChangeAjax('account_TaxInvoiceUseraccountuserAccount'
								, "<spring:message code='Cache.ACC_lbl_taxInvoiceView' />"
								, '/account/layout/account_TaxInvoiceUser.do?CLSYS=account&CLMD=user&CLBIZ=Account'
								, {callType:"Portal"});
						break;
					case "R":	//모바일영수증
						eAccountContentHtmlChangeAjax('account_MobileReceiptUseraccountuserAccount'
								, "<spring:message code='Cache.ACC_lbl_mobileReceipt' />"
								, '/account/layout/account_MobileReceiptUser.do?CLSYS=account&CLMD=user&CLBIZ=Account'
								, {callType:"Portal"});
						break;
					case "AA":	//승인대기	
						eAccountContentHtmlChangeAjax('account_ApprovalListaccountuserAccountApproval'
								, "<spring:message code='Cache.ACC_lbl_doc_approve' />"
								, '/account/layout/account_ApprovalList.do?CLSYS=account&CLMD=user&CLBIZ=Account&mode=Approval'
								, {callType:"Portal"});
						break;
					case "AP":	//진행
						eAccountContentHtmlChangeAjax('account_ApprovalListaccountuserAccountProcess'
								, "<spring:message code='Cache.ACC_lbl_doc_process' />"
								, '/account/layout/account_ApprovalList.do?CLSYS=account&CLMD=user&CLBIZ=Account&mode=Process'
								, {callType:"Portal"});
						break;
					case "AD":	//감사레포팅
						eAccountContentHtmlChangeAjax('account_AuditReportaccountuserAccount'
								, "<spring:message code='Cache.ACC_lbl_auditReport' />"
								, '/account/layout/account_AuditReport.do?CLSYS=account&CLMD=user&CLBIZ=Account'
								, {callType:"Portal"});
						break;
				}
			});
			
		}
		,objectInit : function(){
		    var msg = "<spring:message code='Cache.msg_eacc_dashboard_desc2'/>"; //{0}월 경비 마감! <em> {1}월 {2}일({3})</em> 까지
			msg = msg.replace("{0}", ${deadline.StandardMonth == "01" ? (mm == "01" ? 12 : mm-1) : mm});
			msg = msg.replace("{1}", ${mm});
			msg = msg.replace("{2}", ${dd});
			msg = msg.replace("{3}", "${e}");
			if(${deadline.NoticeTexte != ''}) {
			    msg += " | " + "${deadline.NoticeText}";
			}
			$("p#deadlineMsg").html(msg);
			
			//기준날짜 구하기
			this.setCategory();
			this.addEvent();
			
			// Tiles 로 로딩시 자동으로 스크롤스타일이 적용되지 않아 수동 실행.
			var $scroll_area = $("#fixedTabAccCeoViewArea [data-custom-scrollbar]").not(".mCustomScrollbar");
			$.each($scroll_area, function(){
			    new SimpleBar(this, {autoHide: false});
			});
					
			//대쉬보드
			const $eAccountingDashboardList = document.querySelector('.ceo_dashboard .dashboard_list');
		    const $eAccountingDashboardGroup = document.querySelectorAll('.ceo_dashboard .dashboard_list .dashboard_group');
		
		    // 대시보드 위치 이동
		    if ($eAccountingDashboardList) {
		        var dashboardSortableList = Sortable.create($eAccountingDashboardList, {
		            forceFallback: true,
		            animation: 150
		        });
		    }
		
		    // 대시보드 그룹 내부 위치 이동
		    if ($eAccountingDashboardGroup.length > 0) {
		        for (let i = 0; i < $eAccountingDashboardGroup.length; i++) {
		            var dashboardSortableGroup = Sortable.create($eAccountingDashboardGroup[i], {
		                forceFallback: true,
		                handle: '.card_move_handle',
		                animation: 150,
		                onChoose: function (evt) {
		                    if (evt.from.classList.contains('dashboard_group')) {
		                        evt.from.setAttribute('data-sortable-focus', 'true');
		                        evt.from.parentElement.setAttribute('data-sortable-choose', 'true');
		                    }
		                },
		                onUnchoose: function (evt) {
		                    evt.from.removeAttribute('data-sortable-focus');
		                    evt.from.parentElement.removeAttribute('data-sortable-choose');
		                }
		            });
		        }
		    }
		
		    if ($eAccountingDashboardList) dashboardSortableList.option('disabled', true);
		    if ($eAccountingDashboardGroup.length > 0) dashboardSortableGroup.option('disabled', true);
		
		    // 대시보드 편집모드 활성화
		    $('.ceo_dashboard').on('click', '#activateDashboardEdit', function () {
		        $('.ceo_dashboard').addClass('dashboard_editing');
		        if ($eAccountingDashboardList) dashboardSortableList.option('disabled', false);
		        if ($eAccountingDashboardGroup.length > 0) dashboardSortableGroup.option('disabled', false);
		    });
		
		    // 대시보드 편집모드 취소
		    $('.ceo_dashboard').on('click', '#cancelDashboardEdit', function () {
				location.reload();
		    });
		    
		    this.toggleDashBoard = function(disableDnD){
	   			if(disableDnD === true){
	   				$('.ceo_dashboard').removeClass('dashboard_editing');	
	   			}else{
	   				$('.ceo_dashboard').addClass('dashboard_editing');
	   			}
		        if ($eAccountingDashboardList) dashboardSortableList.option('disabled', disableDnD);
		        if ($eAccountingDashboardGroup.length > 0) dashboardSortableGroup.option('disabled', disableDnD);
	   		};
		}
		,setCategory : function(){			
			mngComm.getData("/account/accountPortal/getTopCategory.do",{})
				.done( $.proxy( function( data ){
					$("#topReportCate,#topMonthCate,#topBudgetCate").append( data.topCateList.map( function( item,idx ){ return $("<option>",{ "value" : item.UserCode, "text" : item.DisplayName }).data('type', item.type )}) )
					var date = new Date();			
					var strDate = "${payDate}".length > 0 ? "${payDate}" : date.getFullYear()+this.lpad( date.getMonth()+1 );
					reportTopObj.init(strDate);
					monthChartObj.init( strDate );
					<c:if test="${fn:length(budgetStd)> 0}">
						budgetChartObj.init( strDate );
					</c:if>	
					
				} ,this))
				.fail(  function( e ){  console.log(e) })
		}		
		,imgError : function(image) {
		    image.onerror = "";
		    image.src = ProfileImagePath+"no_image.jpg";
		    return true;
		}
		,cardReceiptPopup : function(key){
			var popupName	=	"CardReceiptPopup";
			var popupID		=	"cardReceiptPopup";
			var openerID	=	"mngComm";
			var popupTit	=	"<spring:message code='Cache.ACC_lbl_cardReceiptInvoice' />"; //신용카드 매출전표
			var url			=	"/account/accountCommon/accountCommonPopup.do?"
							+	"popupID="		+ popupID	+ "&"
							+	"openerID="		+ openerID	+ "&"
							+	"popupName="	+ popupName	+ "&"
							+	"approveNo="	+ key		+ "&"
							+	"receiptID="	+ key;
			Common.open("",popupID,popupTit,url,"320px", "510px","iframe",true,null,null,true);
		}
		,taxInvoicePop : function(key){
			var popupName	=	"TaxInvoicePopup";
			var popupID		=	"taxInvoicePopup";
			var popupTit	=	"<spring:message code='Cache.ACC_lbl_taxInvoiceCash' />";	//전자세금계산서
			var url			=	"/account/accountCommon/accountCommonPopup.do?"
							+	"popupID="		+	popupID		+	"&"
							+	"popupName="	+	popupName	+	"&"
							+	"taxInvoiceID="	+	key;
			Common.open("",popupID,popupTit,url,"980px", "720px","iframe",true,null,null,true);
		}
		,mobileReceiptPopup : function(FileID){
			var popupName	=	"FileViewPopup";
			var popupID		=	"FileViewPopup";
			var openerID	=	"mngComm";
			var callBack	=	"zoomMobileReceiptPopup";
			var popupTit	=	"<spring:message code='Cache.ACC_lbl_receiptPopup' />"; //영수증 보기
			var url			=	"/account/accountCommon/accountCommonPopup.do?"
							+	"popupID="		+ popupID	+ "&"
							+	"popupName="	+ popupName	+ "&"
							+	"fileID="		+ FileID	+ "&"
							+	"openerID="		+ openerID	+ "&"
							+	"callBackFunc="	+	callBack;
			Common.open("",popupID,popupTit,url,"340px","500px","iframe",true,null,null,true);
		}
		,zoomMobileReceiptPopup : function(info){
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
		}
		,usageTextWritePopup : function(key, proofCode){
			var popupName	=	"UsageTextWritePopup";
			var popupID		=	"UsageTextWritePopup";
			var openerID	= 	"mngComm";
			var callBack	=	"usageTextWritePopup_CallBack"
			var popupTit	=	"<spring:message code='Cache.ACC_lbl_useHistory2' />" + " " + "<spring:message code='Cache.ACC_lbl_input'/>"; //적요 입력
			var companyCode = 	Common.getSession("DN_Code") == "ORGROOT" ? "ALL" : Common.getSession("DN_Code");
			var url			=	"/account/accountCommon/accountCommonPopup.do?"
							+	"popupID="		+ popupID	+ "&"
							+	"openerID="		+ openerID	+ "&"
							+	"popupName="	+ popupName	+ "&"
							+	"receiptID="	+ key		+ "&"
							+	"proofCode="	+ proofCode + "&"
							+	"companyCode="	+ companyCode + "&"
							+	"callBackFunc="	+	callBack;
			Common.open("",popupID,popupTit,url,"500px","250px","iframe",true,null,null,true);
		}
		,usageTextWritePopup_CallBack : function() {
			location.reload(); //증빙사용내역은 c:foreach 구문으로 출력되기 때문에 해당 목록만 새로고침 불가능
		}
	}
	
	/* 리포트 함수  */	
	var reportTopObj = {
		data : {}
		,init : function( date ){ 
			this.data.payDate = date;
			this.changeReport();
		}
		,prevReport : function(){			
			this.data.payDate 	= mngComm.getPrevDate( this.data.payDate );			
            this.changeReport();
		}
		,nextReport : function(){
			this.data.payDate 	= mngComm.getNextDate( this.data.payDate );			
			this.changeReport();
		}
		,changeReport : function(){
			var type = $('#topReportCate option:selected').data('type');
			this.data.stdCode = $('#topReportCate').val();			
			this.data.searchType = type ? type : '';
			mngComm.getData("/account/accountPortal/getReportCategoryList.do",this.data)
				.done( $.proxy( function( data ){  this.drawReport( data ) } ,this) )
				.fail(  function( e ){  console.log(e) })				
		}
		,drawReport : function( data ){
			var dateArr 		= /(\d{4})(\d{2})/.exec( this.data.payDate );
			$("#reportCalTxt").text( dateArr[1]+'<spring:message code="Cache.lbl_year"/> '+dateArr[2]+'<spring:message code="Cache.CPEAccounting_monthReport"/>');						
			$("#reportExpTot").text( mngComm.makeComma( data.totalSummery.amount ) ); 
			$("#reportExpCnt").text( '(<spring:message code="Cache.ACC_lbl_total"/> '+data.totalSummery.cnt+'<spring:message code="Cache.ACC_lbl_items"/>)' );
			
			$("#proofCategory")
				.empty()
				.append( data.deptCateList.map( function( item,idx ){ return $("<option>",{ "value" : item.DeptCode, "text" : item.DeptName }) }) )
				.trigger('change');				
			$("#accountCategory")
				.empty()
				.append( data.accountCateList.map( function( item,idx ){ return $("<option>",{ "value" : item.AccountCode, "text" : item.AccountName }) }) )
				.trigger('change');
		}
		,addEvent : function(){
			$('#proofCategory').on('change',function(){ proofObj.changeCategory( $(this).val() ) });
			$('#accountCategory').on('change',function(){ accountObj.changeCategory( $(this).val() ) });			
			
			$("#reportCal").on('click',function(){
				event.target.classList.value === 'prev'  && reportTopObj.prevReport();
				event.target.classList.value === 'next' && reportTopObj.nextReport();
			});
			
			$("#proofDiv .pagination").on('click',function(){
			    var click = $(event.target);
				if( $(click).prop("tagName") === 'BUTTON' ){
					var idx = $('button',this).index( click );					
					$("#proofList li").hide().slice( idx*5 , (idx*5)+5 ).show();
				}				
			});
			$("#accountDiv .pagination").on('click',function(){
				var click = $(event.target);
				if( $(click).prop("tagName") === 'BUTTON' ){
					var idx = $('button',this).index( click );					
					$("#accountList li").hide().slice( idx*5 , (idx*5)+5 ).show();
				}
			});
		}
		,reportChartDraw : function(calcList){
		    if( calcList.length > 5){ //차트데이터가 5개 초과건부터 누계로 표시.
				var sumAmount = 0;
				calcList = calcList.filter(function(item, idx) { if (idx < 5) { return true; } else { sumAmount += item.Amount; return false; } });
				var sumData = {"Name" : "기타 합계", "Amount" : sumAmount};
				calcList.push(sumData); // 마지막에 누적값을 배열에 추가
		    }
			var proofColorList = [ "rgba(0,157,246,100)","rgba(37,76,170,100)","rgba(141,109,252,100)","rgba(153,205,5,100)","rgba(255,102,102,100)","rgba(72,98,109,100)" ];
			var accountColorList = [ "rgba(0,157,246,100)","rgba(37,76,170,100)","rgba(153,205,5,100)","rgba(251,161,5,100)","rgba(65,98,219,100)","rgba(72,98,109,100)" ];
			var chartObj = {
				data : {
					labels : calcList.length > 0 ? calcList.map(function(item){ return item.AccountName || item.Name  }) : []					
					,datasets : [{
			    		data : calcList.length > 0 ? calcList.map(function(item){ return item.Amount }) : [1]
			    		,borderWidth : 0
			    		,backgroundColor : (calcList.length > 0 && calcList[0].hasOwnProperty("AccountCode")) ? accountColorList.slice(0,calcList.length) : proofColorList.slice(0,calcList.length)
			    	}]					
				},
				options: {
	                devicePixelRatio: 2,
	                maintainAspectRatio: false,
	                legend: {
	                    display: false
	                },
	                tooltips: {
	                    enabled: false,
	                    custom: function (tooltipModel) {
	                        const position = this._chart.canvas.getBoundingClientRect();
	                        let tooltipEl = document.querySelector('.ui_chart_tooltip');

	                        // Create
	                        if (!tooltipEl) {
	                            tooltipEl = document.createElement('div');
	                            tooltipEl.className = 'ui_chart_tooltip';
	                            document.body.appendChild(tooltipEl);
	                        }
	                        tooltipEl.classList.remove('many');

	                        // Hide
	                        if (tooltipModel.opacity === 0) {
	                            tooltipEl.style.opacity = 0;
	                            return;
	                        }

	                        // Data
	                        const data = tooltipModel.body[0].lines[0].split(': ');
	                        const label = data[0];
	                        const color = tooltipModel.labelColors[0].backgroundColor;
	                        const value = parseInt(data[1], 10).toLocaleString();

	                        // Append Html
	                        let innerHtml = '';
	                        innerHtml += '<div class="head"><span class="label">'+label+'</span></div>';
	                        innerHtml += '<div class="body"><div class="item"><i class="badge" style="background:'+color+'"></i><em class="value">'+value+'</em></div></div>';
	                        tooltipEl.innerHTML = innerHtml;

	                        // Show
	                        tooltipEl.style.opacity = '1';
	                        tooltipEl.style.left = position.left + window.pageXOffset + tooltipModel.caretX + 'px';
	                        tooltipEl.style.top = position.top + window.pageYOffset + tooltipModel.caretY + 'px';
	                    }
	                }
	            }
			}			
			if( !this.chart ){				
				chartObj.type = 'doughnut';
				this.chart = new Chart(  this === proofObj ? $("#proofDoughnut") : $("#accountDoughnut") , chartObj ); 
			} else {				
				this.chart.data = chartObj.data;
				this.chart.options.tooltips.enabled = chartObj.options.tooltips.enabled;				
				this.chart.update();
			}
			if(calcList.length == 0){
			    if(this === proofObj){
					$("#proofDoughnut, #ceoProofList").attr("hidden", true);
				    $("#ceoProofEmpty").removeAttr("hidden");
			    }else{
					$("#accountDoughnut, #ceoAccountList").attr("hidden", true);
					$("#ceoAccountEmpty").removeAttr("hidden");
			    }
			}else{
			    if(this === proofObj){
					$("#ceoProofEmpty").attr("hidden", true);
				    $("#proofDoughnut, #ceoProofList").removeAttr("hidden");
			    }else{
			    	$("#ceoAccountEmpty").attr("hidden", true);
			    	$("#accountDoughnut, #ceoAccountList").removeAttr("hidden");
			    }
			}
		}
	}
 	
	var proofObj = {			
		data : {}
		,changeCategory : function( dept ){						
			this.data.payDate 		= reportTopObj.data.payDate; 
			this.data.deptCode 		= (dept == "전체" ? "" : dept);			
			this.data.searchType 	= reportTopObj.data.searchType;
			this.data.stdCode 		= reportTopObj.data.stdCode;
			this.data.prevPayDate 	= mngComm.getPrevDate( this.data.payDate );
			mngComm.getData("/account/accountPortal/portalProof.do",this.data)
				.done( $.proxy( function( data ){ this.draw( data ) },this))
				.fail(  function( e ){  console.log(e) })
		}
		,draw : function( list ){				
			var $proofList = $("#proofList");
			var calcList = 
					list.proofList.filter( function(item){ 						
						//증감 표기
						var prvObj =  list.prevProofList.filter(function(prev){ return prev.AccountCode === item.AccountCode });						
						prvObj.length > 0 && (item.prevAmount = prvObj[0].Amount);
						prvObj.length === 0 && (item.prevAmount = 0);
						item.inDecreate = item.prevAmount === 0 ? "0" : ( Math.floor( (((item.Amount-item.prevAmount)/item.prevAmount)*100)  ) );
						return 	item.AccountCode !== 'Total'					
					});
			
			if(calcList.length > 0){
			    $proofList.removeAttr("hidden");
				$('<ul class="list" data-type="usage">').append(				
					calcList.map(function(item,idx){
							var $li 	= $("<li>", { "code"  : item.AccountCode });
							var $a 		= $("<a>",{ "href" : "#", "class" : "item", "data-color" : idx+1 <= 5 ? idx+1 : "other" });
							var sign	= "";
							var sclass	= "normal";
							var stext	= "-";
							if(item.inDecreate > 0) {
							    sign = "+";
							    sclass = "up";
							    stext = "증가";
							}else if(item.inDecreate < 0) {
							    sclass = "down";
							    stext = "감소";
							}
							
							$a.append( "<i/>")
								.append( $("<span>",{ "text" : item.AccountName }) )
								.append( $("<strong>",{ "text" : mngComm.makeComma( item.Amount )+'<spring:message code="Cache.ACC_lbl_won"/>'}) )
								.append( $("<em>",{ "class": sclass, "aria-label" : '<spring:message code="Cache.CPEAccounting_previousMonth"/>', "text" : sign+item.inDecreate+"%"}).append( $("<b>",{"text" : stext}) ))
							.appendTo( $li );
	
							return $li;
						})
				).appendTo( $proofList.empty() );
			}
			
			$proofList.find("li").css("cursor","pointer").on("click",function() { proofObj.clickDetail(this) });
			
			//차트
			reportTopObj.reportChartDraw.call(this,calcList);
			
			$("li",$proofList).slice( 5 ).hide();
			var btnLen = Math.ceil( $("li",$proofList).length / 5 );
			var $fragment = $( document.createDocumentFragment());			
			for( var i =0; i< btnLen; i++) $fragment.append( $("<button>",{ "type" : "button", "role" : "tab", "aria-selected" : (i==0 ? "true" : "false") }).append("<span>") );
			if(btnLen > 1){
			    $("#proofDiv .pagination").removeAttr("hidden");
				$("#proofDiv .pagination").empty().append( $fragment );
			}else{
			    $("#proofDiv .pagination").attr("hidden",true);
			}

		}
		,clickDetail : function( obj ){
			var proofMonth		= this.data.payDate;
			var proofMonthTxt	= proofMonth.substring(0,4) + "<spring:message code='Cache.lbl_year'/>" + " " + proofMonth.substring(4,6) + "<spring:message code='Cache.ACC_lbl_month'/>";
			var deptCode		= this.data.stdCode;
			var costCenterCode	= this.data.deptCode;
			var costCenterTxt	= (costCenterCode == "" ? $("#topReportCate").find("option:selected").text() : $("#proofCategory").find("option:selected").text());
			var accountCode		= $(obj).attr("code");
			var totalAmountTxt	= $(obj).find("strong").html();
			
			var popupName	=	"ReportDetailPopup";
			var popupID		=	"reportDetailPopup";
			var openerID	=	"proofObj";
			var popupTit	=	"<spring:message code='Cache.ACC_lbl_reportDetail' />"
									.replace("{0}", proofMonthTxt)
									.replace("{1}", costCenterTxt)
									.replace("{2}", totalAmountTxt); //2020년 12월 리포트 상세내역 - 코비젼 (1,234,567원)
			var url			=	"/account/accountCommon/accountCommonPopup.do?"
							+	"popupID="			+ popupID			+ "&"
							+	"openerID="			+ openerID			+ "&"
							+	"popupName="		+ popupName			+ "&"
							+	"ProofMonth="		+ proofMonth		+ "&"
							+	"CostCenterCode="	+ costCenterCode	+ "&"
							+	"DeptCode="			+ deptCode			+ "&"
							+	"AccountCode="		+ accountCode;
			
			Common.open("",popupID,popupTit,url,"1200px","770px","iframe",true,null,null,true);
		}
	}
	
	var accountObj = {
		data : {}
		,changeCategory : function( code ){			
			this.data.payDate = reportTopObj.data.payDate;
			this.data.accountCode = code;
			this.data.searchType = reportTopObj.data.searchType;
			this.data.stdCode = reportTopObj.data.stdCode;
			this.data.prevPayDate 	= mngComm.getPrevDate( this.data.payDate );			
			this.data.searchType = reportTopObj.data.searchType;			
			mngComm.getData("/account/accountPortal/portalAccount.do",this.data)
				.done( $.proxy( function( data ){  this.draw( data ) } ,this) )
				.fail(  function( e ){  console.log(e) })
		}
		,draw : function( list ){
			var $accountList = $("#accountList");
			var calcList = 
				list.accountList.filter( function(item){ 					
					var prvObj =  list.prevAccountList.filter(function(prev){ return prev.Code === item.Code });
					prvObj.length > 0 && (item.prevAmount = prvObj[0].Amount);
					prvObj.length === 0 && (item.prevAmount = 0);
					item.inDecreate = item.prevAmount === 0 ? "0" : ( Math.floor( (((item.Amount-item.prevAmount)/item.prevAmount)*100)  ) ) ;
					return 	item.Code !== 'Total'					
				});
			
			if(calcList.length > 0){
			    $accountList.removeAttr("hidden");
				$('<ul class="list" data-type="department">').append(
					calcList.map(function(item,idx){
						var $li 	= $("<li>", { "code"  : item.Code });
						var $a 		= $("<a>",{ "href" : "#", "class" : "item", "data-color" : idx+1 <= 5 ? idx+1 : "other" });
						var sign	= "";
						var sclass	= "normal";
						var stext	= "-";
						if(item.inDecreate > 0) {
						    sign = "+";
						    sclass = "up";
						    stext = "증가";
						}else if(item.inDecreate < 0) {
						    sclass = "down";
						    stext = "감소";
						}
						
						$a.append( "<i/>")
							.append( $("<span>",{ "text" : item.Name }) )
							.append( $("<strong>",{ "text" : mngComm.makeComma( item.Amount )+'<spring:message code="Cache.ACC_lbl_won"/>'}) )
							.append( $("<em>",{ "class": sclass, "aria-label" : '<spring:message code="Cache.CPEAccounting_previousMonth"/>', "text" : sign+item.inDecreate+"%"}).append( $("<b>",{"text" : stext}) ))
						.appendTo( $li );
							
						return $li;
					})
				)
				.appendTo( $accountList.empty() );
			}

			$accountList.find("li").css("cursor","pointer").on("click",function() { accountObj.clickDetail(this) });
			
			//차트
			reportTopObj.reportChartDraw.call(this,calcList);
			
			$("li",$accountList).slice( 5 ).hide();
			var btnLen = Math.ceil( $("li",$accountList).length / 5 );
			var $fragment = $( document.createDocumentFragment());			
			for( var i =0; i< btnLen; i++) $fragment.append( $("<button>",{ "type" : "button", "role" : "tab", "aria-selected" : (i==0 ? "true" : "false") }).append("<span>") );
			if(btnLen > 1){
			    $("#accountDiv .pagination").removeAttr("hidden");
				$("#accountDiv .pagination").empty().append( $fragment );
			}else{
			    $("#accountDiv .pagination").attr("hidden",true);
			}
		}	
		,clickDetail : function( obj ){
			var proofMonth		= this.data.payDate;
			var proofMonthTxt	= proofMonth.substring(0,4) + "<spring:message code='Cache.lbl_year'/>" + " " + proofMonth.substring(4,6) + "<spring:message code='Cache.ACC_lbl_month'/>";
			var deptCode		= this.data.stdCode;
			var costCenterCode	= $(obj).attr("code");
			var costCenterTxt	= $(obj).find("span").html();
			var accountCode		= this.data.accountCode;
			var totalAmountTxt	= $(obj).find("strong").html();
			
			var popupName	=	"ReportDetailPopup";
			var popupID		=	"reportDetailPopup";
			var openerID	=	"accountObj";
			var popupTit	=	"<spring:message code='Cache.ACC_lbl_reportDetail' />"
									.replace("{0}", proofMonthTxt)
									.replace("{1}", costCenterTxt)
									.replace("{2}", totalAmountTxt); //2020년 12월 리포트 상세내역 - 코비젼 (1,234,567원)
			var url			=	"/account/accountCommon/accountCommonPopup.do?"
							+	"popupID="			+ popupID			+ "&"
							+	"openerID="			+ openerID			+ "&"
							+	"popupName="		+ popupName			+ "&"
							+	"ProofMonth="		+ proofMonth		+ "&"
							+	"CostCenterCode="	+ costCenterCode	+ "&"
							+	"DeptCode="			+ deptCode			+ "&"
							+	"AccountCode="		+ accountCode;
			
			Common.open("",popupID,popupTit,url,"1200px","770px","iframe",true,null,null,true);
		}
	}
	/* 리포트 함수 END */
	
	let otherVisible = true;
    let tooltipVisible = false;
    var newLegendClickHandler = function (e, legendItem) {
        var index = legendItem.datasetIndex;
        var ci = this.chart;
        var meta = ci.getDatasetMeta(index);
        meta.hidden = meta.hidden === null ? !ci.data.datasets[index].hidden : null;

        const other = legendItem.datasetIndex === 5;
        if (other) {
            otherVisible = meta.hidden ? false : true;
        }

        ci.update();
    };
	/* 월별 신청내역 함수 */
	let historyData = {};
	var monthChartObj = {
		data : {}
		,init : function( date ){ 
			this.data.payYear = Number( date.replace(/(\d{4})(\d{2})/,"$1") );			
			this.chart = new Chart( $("#monthChart"),{
			    type: 'bar',
			    data: { labels: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'] }
			    ,options: {
					maintainAspectRatio: false,
	                scales: chartScales,
	                legend: {
	                    align: 'end',
	                    labels: {
	                        padding: 20,
	                        boxWidth: 11,
	                        fontSize: 14,
	                        usePointStyle: true
	                    },
	                    onClick: newLegendClickHandler,
	                },
			   		tooltips: {
	                    mode: 'index',
	                    enabled: false,
	                    custom: function (tooltipModel) {
	                        let sum = 0;
	                        const position = this._chart.canvas.getBoundingClientRect();
	                        let tooltipEl = document.querySelector('.ui_chart_tooltip');

	                        let otherBadgeColor = '#48626D';

	                        // Create
	                        if (!tooltipEl) {
	                            tooltipEl = document.createElement('div');
	                            tooltipEl.className = 'ui_chart_tooltip';
	                            document.body.appendChild(tooltipEl);
	                        }
	                        tooltipEl.classList.add('many');

	                        // Hide
	                        if (tooltipModel.opacity === 0) {
	                            tooltipEl.style.opacity = 0;
	                            return;
	                        }

	                        // 합계
	                        tooltipModel.dataPoints.forEach(function (item) {
	                            sum += item.yLabel;
	                        });

	                        // 헤더
							let innerHtml = '';
							innerHtml += '<div class="head"><strong>'+tooltipModel.title[0]+'</strong><span><em>'+sum.toLocaleString()+'</em>'+Common.getDic("ACC_lbl_won")+'</span></div><div class="body">';

							function itemHtml (badge, label, value) {
	                            innerHtml += '<div class="item">'+badge+'<span class="label">'+label+'</span><span class="line"></span><em class="value">'+value+'</em></div>';
	                        }

	                        //리스트
	                        let tooltipData=[];
	                        tooltipModel.dataPoints.forEach(function (item, index) {
	                            let tooltipObj = {};
	                            tooltipObj["label"] = tooltipModel.body[index].lines[0].split(':')[0];
	                            tooltipObj["value"] = parseInt(item.yLabel, 10);
	                            tooltipObj["color"] = tooltipModel.labelColors[index].backgroundColor;
	                            if(tooltipObj["label"] !== "기타")
	                            	tooltipData.push(tooltipObj);
	                        });

	                        // 기타리스트
	                        this._data.otherData.forEach(function (item, index) {
	                            let otherObj = {};
	                            const month = parseInt(tooltipModel.title[0], 10); //선택월
	                            otherObj["label"] = item.label;
	                            otherObj["value"] = parseInt(item.data[month-1], 10);
	                            otherObj["color"] = "#48626D";
	                            otherObj["type"] = "other";
	                            tooltipData.push(otherObj);
	                        });
	                        
	                        if (tooltipData !== undefined) {
	                            tooltipData.sort( function(a,b){  return b.value - a.value });
	                            tooltipData.forEach(function (item) {
	                                const badge = '<i class="badge" style="background:'+item.color+'"></i>';
	                                const label = item.label;
	                                const value = item.value.toLocaleString();
	                                if(value != '0'){
	                                    if(item.hasOwnProperty("type") && !(item.type == "other" && otherVisible)){
	                                		return;
	                                    }
	                                	itemHtml(badge, label, value);
	                                }
	                            });
	                        }

	                        innerHtml += '</div>';
	                        tooltipEl.innerHTML = innerHtml;

	                     	// Show
	                        tooltipEl.style.opacity = '1';

	                        if (position.left + tooltipModel.caretX + tooltipEl.clientWidth > window.innerWidth) {
	                            tooltipEl.style.left = position.left + tooltipModel.caretX - tooltipEl.clientWidth + 'px';
	                        } else {
	                            tooltipEl.style.left = position.left + tooltipModel.caretX + 'px';
	                        }

	                        if (position.top + tooltipModel.caretY + tooltipEl.clientHeight > window.innerHeight) {
	                            tooltipEl.style.top = position.top + tooltipModel.caretY +
	                                (window.innerHeight - ((position.top + tooltipModel.caretY) + tooltipEl.clientHeight)) + 'px';
	                        } else {
	                            tooltipEl.style.top = position.top + tooltipModel.caretY + 'px';
	                        }
	                    }
	                }
			    },
				plugins: [canvasBackgroundColor]
			});
			this.changeChart();
		}
		,prevReport : function(){
			this.data.payYear 	-=  1;
            this.changeChart();
		}
		,nextReport : function(){
			this.data.payYear 	+=  1;
			this.changeChart();
		}		
		,changeChart : function(){			
			var type = $('#topMonthCate option:selected').data('type');	
			this.data.stdCode = $('#topMonthCate').val();
			this.data.searchType = type ? type : '';			
			mngComm.getData("/account/accountPortal/getAccountMonth.do",this.data)
				.done( $.proxy( function( data ){  this.draw( data.chartObj ) } ,this) )
				.fail(  function( e ){  console.log(e) })
		}
		,draw : function( obj ){
			historyData.header = obj.monthHeader;
			historyData.list = obj.monthList;
			var chartColorList = [ "rgba(0,157,246,100)","rgba(37,76,170,100)","rgba(153,205,5,100)","rgba(251,161,5,100)","rgba(65,98,219,100)","rgba(72,98,109,100)" ];
			this.chart.data.datasets = 
				obj.monthHeader.slice(0,5).reduce(function( acc,cur,idx,arr ){
					var rowHeader = {};				
					rowHeader.label					= 	cur.Name;
					rowHeader.data 					=	obj.monthList.map(function(item,idx){ return item["SUM_"+cur.Code] || 0 })
					rowHeader.backgroundColor 		=	chartColorList[idx]
					rowHeader.hoverBackgroundColor	=	chartColorList[idx]
					rowHeader.borderColor			=	'rgb(255, 255, 255)'
					acc = acc.concat( rowHeader );
					if(arr.length-1 === idx && obj.monthHeader.length > 5){//legend용 기타추가
					    rowHeader = {};
					    rowHeader.label					= 	"기타" ;
						rowHeader.data 					=	obj.monthList.map(function( item,idx ){ return obj.monthHeader.slice(5).reduce(function( acc,cur,idx,arr ){ return acc = acc + item["SUM_"+cur.Code] || 0; },0) });
						rowHeader.backgroundColor 		=	chartColorList[idx+1]
						rowHeader.hoverBackgroundColor	=	chartColorList[idx+1]
						rowHeader.borderColor			=	'rgb(255, 255, 255)'
						acc = acc.concat( rowHeader );
					}
					return acc;
				},[]);
			this.chart.data.otherData = 
				obj.monthHeader.slice(5).reduce(function( acc,cur,idx,arr ){
					var rowHeader = {};				
					rowHeader.label					= 	cur.Name;
					rowHeader.data 					=	obj.monthList.map(function(item,idx){ return item["SUM_"+cur.Code] || 0 })
					return acc = acc.concat( rowHeader );
				},[]);
			obj.monthHeader.length > 0 && this.chart.update();			
			obj.monthHeader.length === 0 && this.chart.render();
			this.chart._orgData = obj;
			//타이틀
			$('#monthChartTit .title').text( this.data.payYear+Common.getDic("lbl_year")+" "+Common.getDic("CPEAccounting_monthDetails") );//년 월별 신청내역
		}
		,addEvent : function(){
			$("#monthCal").on('click',function(){				
				event.target.classList.value === 'prev'  && monthChartObj.prevReport();
				event.target.classList.value === 'next' && monthChartObj.nextReport();
			});
		}
	}
	/* 월별 신청내역 함수 END */
	
	/* 월별 예산대비 지출 함수 */	
	var budgetChartObj = {
		data : {}
		,init : function( date ){ 
			this.data.payYear = Number( date.replace(/(\d{4})(\d{2})/,"$1") );
			this.chart = new Chart( $("#budgetChart"),{
			    type: 'bar',
			    data: { labels: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'] },
			 	options: {
	                maintainAspectRatio: false,
	                scales: chartScales,
	                legend: {
	                    display: false
	                },
	                tooltips: {
	                    callbacks: {
	                        title: function (tooltipItem, data) {
	                            return data.labels[tooltipItem[0].index];
	                        },
	                        label: function (tooltipItem, data) {
	                            const value = data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index];
	                            return ' ' + parseInt(value, 10).toLocaleString();
	                        }
	                    }
	                },
	            },
	            plugins: [canvasBackgroundColor],
			});
			
			this.changeChart();
		}
		,prevReport : function(){			
	        this.data.payYear 	-=  1;
            this.changeChart();
		}
		,nextReport : function(){
			this.data.payYear 	+=  1;
			this.changeChart();
		}
		,changeChart : function(){
			var type = $('#topBudgetCate option:selected').data('type');	
			this.data.stdCode = $('#topBudgetCate').val();
			this.data.accountCode= $('#budgetCategory').val();
			this.data.searchType = type ? type : '';			
			mngComm.getData("/account/accountPortal/getBudgetMonthSum.do",this.data)
				.done( $.proxy( function( data ){  this.draw( data ) } ,this) )
				.fail(  function( e ){  console.log(e) })
		}
		,draw : function( obj ){
			var budgetAmount = (typeof obj.budgetTotal.BudgetAmount != "undefined") ?  obj.budgetTotal.BudgetAmount : 0;
			var baseTermName = (typeof obj.budgetTotal.BaseTermName != "undefined") ?  obj.budgetTotal.BaseTermName : "";
			var totalObj = obj.chartObj[12];						
			this.chart.data.datasets = [{
			    label : '지출'
				,data : obj.chartObj.slice(0,12).map(function( item,idx ){ return item.UsedAmount })
				,backgroundColor	: 	'#0dbae7'
			}]			
			this.chart.update();
			
			//title			
			$("#budgetTitle").empty().append( this.data.payYear+Common.getDic("lbl_year")+" ");
			$("#baseTermTitle")	.text( Common.getDic("ACC_lbl_won") + (baseTermName == "" ? "" : "("+baseTermName +")") );
			$("#budgetAmount")	.text( mngComm.makeComma(budgetAmount) );
			$("#UsedAmount")	.text( mngComm.makeComma(totalObj.UsedAmount) );
			$("#processAmount")	.text( mngComm.makeComma(totalObj.pending) );
			var leftAmount = budgetAmount - totalObj.UsedAmount;
			$("#leftAmount")	.text( mngComm.makeComma(leftAmount) )
			if(leftAmount < 0){
			    $("#leftAmount").addClass("negative")
			}else{
			    $("#leftAmount").removeClass("negative")
			}
		}
		,addEvent : function(){			
			$("#budgetCal").on('click',function(){				
				event.target.classList.value === 'prev'  && budgetChartObj.prevReport();
				event.target.classList.value === 'next' && budgetChartObj.nextReport();
			});			
		}
	}
	/* 월별 예산대비 지출 함수 END */
	
	//최근기안팝업
	function onClickPopButton(ProcessID,WorkItemID,TaskID,PerformerID,ProcessDescriptionID,FormInstID,SubKind,UserCode,FormID,BusinessData2, g_mode){
		var mode;
		var userID;
		var gloct;
		var subkind;
		var archived = "false";
		switch (g_mode){
			case "Approval" : mode="APPROVAL"; gloct = "APPROVAL"; subkind=SubKind; userID=UserCode; break;    // 미결함
			case "Process" : mode="PROCESS"; gloct = "PROCESS"; subkind=SubKind; userID=UserCode; break;		// 진행함
			case "Complete" : mode="COMPLETE"; gloct = "COMPLETE"; subkind=SubKind; archived="true"; userID=UserCode; break;	// 완료함
			case "Reject" : mode="REJECT"; gloct = "REJECT";  subkind=SubKind; archived="true"; userID=UserCode; break;		// 반려함
			case "TCInfo" : mode="COMPLETE"; gloct = "TCINFO"; subkind=SubKind; userID=""; break;		// 참조/회람함
		}
				
		CFN_OpenWindow("/account/expenceApplication/ExpenceApplicationViewPopup.do?mode="+mode
				+"&processID="+ProcessID
				+"&workitemID="+WorkItemID
				+"&taskID="+TaskID
				+"&performerID="+PerformerID
				+"&processdescriptionID="+ProcessDescriptionID
				+"&userCode="+userID
				+"&gloct="+gloct
				+"&formID="+FormID
				+"&forminstanceID="+FormInstID
				+"&ExpAppID="+BusinessData2
				+"&admintype=&archived="+archived
				+"&usisdocmanager=true&listpreview=N&subkind="+subkind+"", "", 1070, (window.screen.height - 100), "both");
	}
	
	
	
	$(document).ready(function(){
		mngComm.objectInit();
	});
	
	// 홈 탭(섹션) 순서 저장
	function sortCeoPortalSectionTab(){
		var sortListArr = [];
		var sortList = $("#fixedTabAccCeoViewArea").find(".dashboard_card", ".dashboard_list");
		for(var i = 0; i < sortList.length; i++){
			sortListArr.push(sortList[i].getAttribute("type"));
		}
		
		var pUrl = "/account/user/updatePortalSectionSort.do";
		var pParam = {
			"sortList" : sortListArr.join(";"),
			"Type" : "CEO"
		};
		var pAsync = true;
		var pCallBack = function(data){
			if(data.status == "SUCCESS"){
			    mngComm.toggleDashBoard(true);
			}
		};
		CFN_CallAjax(pUrl, pParam, pCallBack, pAsync, "json");
	}
</script>