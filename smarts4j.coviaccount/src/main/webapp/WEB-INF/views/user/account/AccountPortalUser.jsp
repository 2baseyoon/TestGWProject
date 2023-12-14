<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="egovframework.coviframework.util.RedisDataUtil"%>
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
	params.put("Type", "USER");
	CoviList sectionList = service.selectPortalSectionSort(params);
	if(sectionList == null || sectionList.size() != 5){
		// when not found sort data
		sectionList = new CoviList();
		CoviMap info1 = new CoviMap();
		info1.put("SectionKey", "widget_quick_link");
		sectionList.add(info1);
		CoviMap info2 = new CoviMap();
		info2.put("SectionKey", "group_status");
		sectionList.add(info2);
		CoviMap info3 = new CoviMap();
		info3.put("SectionKey", "group_history");
		sectionList.add(info3);
		CoviMap info4 = new CoviMap();
		info4.put("SectionKey", "widget_monthly_report");
		sectionList.add(info4);
		CoviMap info5 = new CoviMap();
		info5.put("SectionKey", "widget_monthly_apply");
		sectionList.add(info5);
	}
%>
	<jsp:include page="/WEB-INF/views/user/account/UserAccountGuide.jsp"></jsp:include> 
	<style type="text/css">/* Chart.js */
		@keyframes chartjs-render-animation{from{opacity:.99}to{opacity:1}}.chartjs-render-monitor{animation:chartjs-render-animation 1ms}.chartjs-size-monitor,.chartjs-size-monitor-expand,.chartjs-size-monitor-shrink{position:absolute;direction:ltr;left:0;top:0;right:0;bottom:0;overflow:hidden;pointer-events:none;visibility:hidden;z-index:-1}.chartjs-size-monitor-expand>div{position:absolute;width:1000000px;height:1000000px;left:0;top:0}.chartjs-size-monitor-shrink>div{position:absolute;width:200%;height:200%;left:0;top:0}
	</style>
	
    <div id="fixedTabAccViewArea" class="ui_main ui_dashboard ui_dashboard_e_accounting_personal user_dashboard">
        <div class="ui_head">
            <h3 class="head_title">e-Accounting</h3>
            <div class="tip" <c:if test="${deadline.IsUse == 'N'}">hidden=""</c:if>>
            	<fmt:parseDate value="${fn:replace( deadline.DeadlineFinishDate,'.','')}" var="dlDate" pattern="yyyyMMdd"/>
				<fmt:formatDate value="${dlDate}" pattern="yyyy" var="yyyy"/>					
				<fmt:formatDate value="${dlDate}" pattern="MM" 	 var="mm"/>
				<fmt:formatDate value="${dlDate}" pattern="dd" 	 var="dd"/>
				<fmt:formatDate value="${dlDate}" pattern="E" 	 var="e"/>
                <p id="deadlineMsg"/>
            </div>
        </div>
        <div class="ui_content">
            <div data-custom-scrollbar>
                <div class="dashboard_message">
                    <div class="ui_alert alert_outlined" data-type="info" role="alert">
                        <div class="alert_message">
                        	<!-- 설명 메시지 -->
                            <p><spring:message code="Cache.msg_eacc_dashboard_desc"/></p>
                        </div>
                    </div>
                </div>
                <!-- 청구 가이드 -->
                <div class="dashboard_list">
	                <%
	                	boolean isGroupDivDrawn = false;
		            	for(int i = 0; i < sectionList.size(); i++){
		            		CoviMap sectionInfo = sectionList.getJSONObject(i);
		            		if("widget_quick_link".equals(sectionInfo.getString("SectionKey"))){
	            			
	            	%>
					<c:if test="${fn:length(guideList)> 0}">
                    <div class="dashboard_card widget_quick_link" type="widget_quick_link">
                        <div class="card_root">
                            <dl>
                            	<!-- 경비 청구 가이드 -->
                                <dt><spring:message code="Cache.CPEAccounting_ExpenseGuide"/></dt>
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
	            			if(!isGroupDivDrawn){
	            	%>
                    <div class="dashboard_group">
                    <%
                    		}
                    		if("group_status".equals(sectionInfo.getString("SectionKey"))){
	               	%>
                        <div class="dashboard_card widget_status" type="group_status">
                        	<!-- 진행단계 -->
                            <div class="card_root">
                                <div class="card_head">
                                    <div class="title"><spring:message code="Cache.CPEAccounting_ProgressiveStage"/></div>
                                    <div class="action">
                                        <span class="card_move_handle"><span>이동</span></span>
                                        <button type="button" class="card_more"><span>더보기</span></button>
                                    </div>
                                </div>
                                <div class="card_tab ui_tabs">
                                    <div class="tab_list" role="tablist">
                                    	<!-- 승인대기 -->
                                        <button role="tab" type="button" class="tab" aria-selected="true"  data-type="AA"><span><spring:message code="Cache.lbl_adstandby"/>(<span id="ApprovalCnt"></span>)</span></button>
                                        <!-- 진행 -->
                                        <button role="tab" type="button" class="tab" aria-selected="false" data-type="AP"><span><spring:message code="Cache.lbl_apv_goProcess"/>(<span id="ProcessCnt"></span>)</span></button>
                                    </div>
                                </div>
                                <div class="card_content" id="userApprovalList">
                                    <ul class="post_list">
                                </div>
                            </div>
                        </div>
                        <% 
                        	} else if("group_history".equals(sectionInfo.getString("SectionKey"))){
                        %>
                        <div class="dashboard_card widget_history" type="group_history">
                        	<!-- 사용내역 -->
                            <div class="card_root">
                                <div class="card_head">
                                    <div class="title"><spring:message code="Cache.CPEAccounting_usageDetails"/></div>
                                    <div class="action">
                                        <span class="card_move_handle"><span>이동</span></span>
                                        <button type="button" class="card_more"><span>더보기</span></button>
                                    </div>
                                </div>
                                <div class="card_tab ui_tabs">
                                    <div class="tab_list" role="tablist">
                                        <button role="tab" type="button" class="tab" aria-selected="true" id="history_company_tab" aria-controls="history_company_tab_panel" data-type="C"><span><spring:message code="Cache.ACC_lbl_corpCard"/>(${corpCardListCnt})</span></button>
                                        <button role="tab" type="button" class="tab" aria-selected="false" id="history_tax_tab" aria-controls="history_tax_tab_panel" data-type="T"><span><spring:message code="Cache.ACC_lbl_TaxInvoice"/>(${taxBillListCnt})</span></button>
                                        <button role="tab" type="button" class="tab" aria-selected="false" id="history_receipt_tab" aria-controls="history_receipt_tab_panel" data-type="R"><span><spring:message code="Cache.ACC_lbl_receipt"/>(${billListCnt})</span></button>
                                    </div>
                                </div>
                                <!-- 법인카드 -->
                                <div role="tabpanel" class="card_content" id="history_company_tab_panel" aria-labelledby="history_company_tab">
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
		                                                    	<c:if test="${not empty list.Code}">
		                                                    		<em class="regist_corpcard" data="${list.ReceiptID}">${list.Name}</em>
		                                                    	</c:if>
		                                                    </div>
		                                                    <div class="secondary">
		                                                        <span>${list.AmountWon}</span>
		                                                        <time>${list.ApproveDate} ${list.ApproveTime}</time>
		                                                    </div>
		                                                </a>
		                                                <c:if test="${empty list.Code}">
		                                                	<button type="button" class="regist_corpcard" data="${list.ReceiptID}"><span>작성</span></button>
		                                                </c:if>
		                                            </div>
		                                        </li>
		                                    </c:forEach>
	                                    </ul>
	                                </c:otherwise>
	                            </c:choose>
                                </div>
                                <!-- 세금계산서 -->
                                <div hidden="" role="tabpanel" class="card_content" id="history_tax_tab_panel" aria-labelledby="history_tax_tab">
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
		                                                <a href="#" class="taxInvoice" data="${list.TaxInvoiceID}">
		                                                    <div class="main">
		                                                        <strong>${list.InvoicerCorpName}</strong>
		                                                        <c:if test="${list.Code ne null }">
		                                                    		<em data="${list.ReceiptID}">${list.Name}</em>
		                                                    	</c:if>
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
                                <div hidden="" role="tabpanel" class="card_content" id="history_receipt_tab_panel" aria-labelledby="history_receipt_tab">
								<c:choose>
									<c:when test="${fn:length(billList)== 0}">
										<div class="ui_empty">
											<p><spring:message code="Cache.msg_apv_101"/></p> <!-- 조회할 목록이 없습니다. -->
										</div>
									</c:when>
									<c:otherwise>
	                                    <ul class="thumb_list">
											<c:forEach items="${billList}" var="list" varStatus="status">
		                                        <li>
		                                            <a href="#" class="thumb_item">
	                                                    <span class="preview">
	                                                        <img src="/covicore/common/photo/photo.do?img=${list.URLPath}"  alt="" onerror="coviCmn.imgError(this, false);" class="mobileReceipt" data="${list.ReceiptFileID}"/>
	                                                        <c:if test="${not empty list.Code}">
	                                                        	<strong class="regist_receipt" data="${list.ReceiptID}">${list.Name}</strong>
	                                                        </c:if>
	                                                        <c:if test="${empty list.Code}">
																<strong class="regist_receipt" data="${list.ReceiptID}"><spring:message code='Cache.lbl_Unregistered'/></strong>										
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
                        		if(isGroupDivDrawn){
                        %>
                    </div>
                    <%
                    			}
                    			isGroupDivDrawn = true;
	            		} else if("widget_monthly_report".equals(sectionInfo.getString("SectionKey"))){
	                %>
                    <div class="dashboard_card widget_monthly_report" type="widget_monthly_report">
                    	<!-- 월리포트 -->
                        <div class="card_root">
                            <div class="card_head">
                                <div class="title">${urName} <font id=portalTitle>${fn:substring(payDate,0,4)}<spring:message code="Cache.lbl_year"/>&nbsp;${fn:substring(payDate,4,6)}</font><spring:message code="Cache.CPEAccounting_monthReport"/></div>
                                <div class="control" id="userCal">
                                    <button type="button" class="prev"><span>이전</span></button>
                                    <button type="button" class="next"><span>다음</span></button>
                                </div>
                            </div>
                            <div class="card_content">
                            	<!-- 증빙종류별 사용금액 -->
                                <div class="content_item" id="circleChart">
                                    <div class="item_head">
                                        <strong class="title"><spring:message code="Cache.CPEAccounting_amountEvidence"/></strong>
                                        <span class="total"><spring:message code="Cache.ACC_lbl_total"/> <em id="account_portal_user_proof_tot"><fmt:formatNumber value="${proofCount.TotalAmount}" pattern="#,###" /></em> <spring:message code="Cache.ACC_lbl_won"/></span>
                                    </div>
                                    <div class="item_content">
                                    	<!-- 원형그래프 -->
                                        <div class="ui_chart">
                                            <canvas id="userProofDoughnut" style="display: block; height: 150px; width: 150px;" width="300" height="300" class="chartjs-render-monitor"></canvas>
                                        </div>
                                        <!-- 증빙종류별 목록 -->
                                        <div class="data_lists" id="userProofList">
                                            <ul class="list" id="account_portal_user_proof_list">
		                                        <c:if test="${proofCount.TotalAmount>0 }">
													<fmt:parseNumber var="per" value="${proofCount.TaxBillAmount*100.00/proofCount.TotalAmount}" pattern=".00"/>
												</c:if>
												<!-- 전자세금계산서 -->
                                                <li>
                                                    <div class="item t_1">
                                                        <i style="background:#009DF6"></i>
                                                        <span><spring:message code="Cache.ACC_lbl_taxInvoiceCash"/>(${proofCount.TaxBillCnt}<spring:message code="Cache.ACC_lbl_items"/>)</span>
                                                        <strong><fmt:formatNumber value="${proofCount.TaxBillAmount}" pattern="#,###" /><spring:message code="Cache.ACC_lbl_won"/></strong>
                                                    </div>
                                                </li>
                                                <c:if test="${proofCount.TotalAmount>0 }">
													<fmt:parseNumber var="per" value="${proofCount.ReceiptAmount*100.00/proofCount.TotalAmount}" pattern=".00"/>
												</c:if>
												<!-- 모바일 영수증 -->	
                                                <li>
                                                    <div class="item t_2">
                                                        <i style="background:#254CAA"></i>
                                                        <span><spring:message code="Cache.ACC_lbl_mobileReceipt"/>(${proofCount.ReceiptCnt}<spring:message code="Cache.ACC_lbl_items"/>)</span>
                                                        <strong><fmt:formatNumber value="${proofCount.ReceiptAmount}" pattern="#,###" /><spring:message code="Cache.ACC_lbl_won"/></strong>
                                                    </div>
                                                </li>
                                                <c:if test="${proofCount.TotalAmount>0 }">
													<fmt:parseNumber var="per" value="${proofCount.CorpCardAmount*100.00/proofCount.TotalAmount}" pattern=".00"/>
												</c:if>	
												<!-- 법인카드 -->
                                                <li>
                                                    <div class="item t_3">
                                                        <i style="background:#99CD05"></i>
                                                        <span><spring:message code="Cache.ACC_lbl_corpCard"/>(${proofCount.CorpCardCnt}<spring:message code="Cache.ACC_lbl_items"/>)</span>
                                                        <strong><fmt:formatNumber value="${proofCount.CorpCardAmount}" pattern="#,###" /><spring:message code="Cache.ACC_lbl_won"/></strong>
                                                    </div>
                                                </li>
                                            </ul>
                                            <div class="pagination" role="tablist" hidden="">
                                                <button type="button" role="tab" aria-selected="true"><span>1</span></button>
                                                <button type="button" role="tab"><span>2</span></button>
                                                <button type="button" role="tab"><span>3</span></button>
                                                <button type="button" role="tab"><span>4</span></button>
                                                <button type="button" role="tab"><span>5</span></button>
                                            </div>
                                        </div>
                                        <div class="ui_empty" id="userProofEmpty" hidden="">
											<p><spring:message code="Cache.msg_apv_101"/></p> <!-- 조회할 목록이 없습니다. -->
										</div>
                                    </div>
                                </div>
                                <div class="content_item application_details">
                                	<!-- 신청 내역 -->
                                    <div class="item_head">
                                        <strong class="title"><spring:message code="Cache.ACC_lbl_applicationList"/></strong>
                                        <span class="total"><spring:message code="Cache.ACC_lbl_total"/> <em id="account_portal_user_account_tot"><fmt:formatNumber value="${fn:length(accountCount) == 0 ? 0 : accountCount[0].Amount}" pattern="#,###.##" /></em> <spring:message code="Cache.ACC_lbl_won"/></span>
                                    </div>
                                    <div class="item_content">
	                                    <div class="data_lists" id="userAccountList">
	                                        <ul class="list">
	                                            <c:forEach items="${accountCount}" var="list" varStatus="status">
													<c:if test="${list.Code ne 'Total'}">
														<c:set var="per" value="${list.Amount*100.00/accountCount[0].Amount}"/>
														<c:if test="${status.count>5 && status.count%5 == 2}">
															</ul><ul class="list" hidden="">
														</c:if>
														<li>
		                                                    <div class="item">
		                                                        <span>${list.Name}(${list.Cnt})</span>
		                                                        <div class="progress" style="background-color:#CEF1FA"><div class="bar" data-width="${per}" style="width: ${per}%; background-color:#0DBAE7"></div></div>
		                                                        <strong><fmt:formatNumber value="${list.Amount}" pattern="#,###.##" /><spring:message code="Cache.ACC_lbl_won"/></strong>
		                                                    </div>
		                                                </li>
													</c:if>
												</c:forEach>
	                                        </ul>
	                                     	<div class="pagination" role="tablist" hidden="" id="account_portal_user_account_slide">
												<c:if test="${fn:length(accountCount) > 6}">
													<c:forEach begin="1" end="${fn:length(accountCount)/5}"  var="x">
														<c:choose>
															<c:when test="${x== 1}">
																<button type="button" role="tab" aria-selected="true"><span>1</span></button>
															</c:when>
															<c:otherwise>
																<button type="button" role="tab"><span>2</span></button>
															</c:otherwise>	
														</c:choose>
													</c:forEach>
												</c:if>
											</div>
										</div>
										<div class="ui_empty" id="userAccountEmpty" hidden="">
											<p><spring:message code="Cache.msg_apv_101"/></p> <!-- 조회할 목록이 없습니다. -->
										</div>
									</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <%
	            		}else if("widget_monthly_apply".equals(sectionInfo.getString("SectionKey"))){
	                %>
                    <div class="dashboard_card widget_monthly_apply" id="monthChartTit" type="widget_monthly_apply">
                    	<!-- 월별 신청내역 -->
                        <div class="card_root">
                            <div class="card_head">
                                <div class="title">${fn:substring(payDate,0,4)}<spring:message code="Cache.lbl_year"/> <spring:message code="Cache.CPEAccounting_monthDetails"/></div>
                                <div class="control" id="yearCal">
                                    <button type="button" class="prev"><span>이전</span></button>
                                    <button type="button" class="next"><span>다음</span></button>
                                </div>
                            </div>
                            <div class="card_content">
                                <div id="chart3_legend" class="ui_chart_legend"></div>
                                <div class="ui_chart">
                                    <canvas id="userMonthChart" width="1440" height="350" style="display: block; width: 1440px; height: 350px;" class="chartjs-render-monitor"/>
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
                    <button type="button" class="ui_button primary" onclick="sortUserPortalSectionTab();"><span><spring:message code="Cache.btn_Apply"/></span></button> <!-- 적용 -->
                </div>
            </div>
        </div>
        <button type="button" class="ui_floating_action_button" data-icon="setting" id="activateDashboardEdit" data-tooltip-title="<spring:message code='Cache.lbl_dashboardSetting'/>" data-tooltip-position="left"><span>설정</span></button>
    </div>
<script>
//get css variable
const $textPrimaryColor = getComputedStyle(document.documentElement).getPropertyValue('--text-primary') || '#222222';
const $paperSecondaryColor = getComputedStyle(document.documentElement).getPropertyValue('--paper-secondary') || '#f8f8f8';
const $borderSecondaryColor = getComputedStyle(document.documentElement).getPropertyValue('--border-primary') || '#dddddd';

// https://www.youtube.com/watch?v=t7Wb2w6nKD0 참고
const canvasBackgroundColor = {
    id: 'canvasBackgroundColor',
    beforeDraw: function (chart) {
        // const {ctx, chartArea: {top, bottom, left, right}} = chart;
        chart.ctx.fillStyle = $paperSecondaryColor;
        chart.ctx.fillRect(chart.chartArea.left, chart.chartArea.top, chart.chartArea.right - chart.chartArea.left,
            chart.chartArea.bottom - chart.chartArea.top);
    }
};

// 공용 옵션
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

var ProfileImagePath = Common.getBaseConfig('ProfileImagePath');
var userPortal = {	
	pageInit : function(){
	    var msg = "<spring:message code='Cache.msg_eacc_dashboard_desc2'/>"; //{0}월 경비 마감! <em> {1}월 {2}일({3})</em> 까지
		msg = msg.replace("{0}", ${deadline.StandardMonth == "01" ? (mm == "01" ? 12 : mm-1) : mm});
		msg = msg.replace("{1}", ${mm});
		msg = msg.replace("{2}", ${dd});
		msg = msg.replace("{3}", "${e}");
		if(${deadline.NoticeTexte != ''}) {
		    msg += " | " + "${deadline.NoticeText}";
		}
		$("p#deadlineMsg").html(msg);
			    
		this.getApprovalList(0);	
		userComm.getData("/account/accountPortal/getTopCategory.do",{})
		var data = [${proofCount.TaxBillAmount},${proofCount.ReceiptAmount},${proofCount.CorpCardAmount}];
		userMonthChartObj.init( "${payDate}" );		
		userAccountChartObj.initChart(data);
		if(${fn:length(accountCount)==0}){
		    $("#userAccountList").attr("hidden", true);
			$("#userAccountEmpty").removeAttr("hidden");
		}
		
		//승인대기/진행중
		$('#fixedTabAccViewArea .widget_status .tab_list [role="tab"]').click(function(){
			//$('#fixedTabAccViewArea .widget_status .post_list').attr("hidden", true);
			//$('#fixedTabAccViewArea .widget_status .ui_empty').attr("hidden", true);
			userPortal.getApprovalList($(this).index());
		});		
		
		//법인카드
		$("#fixedTabAccViewArea .corpCard").find("strong, .secondary").click(function(){
			userPortal.cardReceiptPopup($(this).closest('.corpCard').attr("data"));
		});
		//세금계산서
		$('#fixedTabAccViewArea .taxInvoice').click(function(){
			userPortal.taxInvoicePop($(this).attr("data"));
		});
		//영수증팝업
		$('#fixedTabAccViewArea .mobileReceipt').click(function(){
			userPortal.mobileReceiptPopup($(this).attr("data"));
		});
		//법인카드 - 계정과목(표준적요)/적요
		$('#fixedTabAccViewArea .regist_corpcard').click(function(){
			userPortal.usageTextWritePopup($(this).attr("data"), "CorpCard");
		});
		//영수증 - 계정과목(표준적요)/적요
		$('#fixedTabAccViewArea .regist_receipt').click(function(){
			userPortal.usageTextWritePopup($(this).attr("data"), "Receipt");
		});
		
		//진행단계 카운트
		$("#fixedTabAccViewArea .widget_status .card_tab #ApprovalCnt").text($("li.eaccountingMenu02").find("a[id$=Approval]").find("span.fCol19abd8").text().trim());
		$("#fixedTabAccViewArea .widget_status .card_tab #ProcessCnt").text($("li.eaccountingMenu02").find("a[id$=Process]").find("span.fCol19abd8").text().trim());
		
		//다음월버튼
		$('#fixedTabAccViewArea #userCal .next').click(function(){
			userAccountChartObj.getUserMonth("+");
		});
		//다음월버튼
		$('#fixedTabAccViewArea #userCal .prev').click(function(){
			userAccountChartObj.getUserMonth("-");
		});		
		
		//다음해버튼
		$('#fixedTabAccViewArea #yearCal .next').click(function(){
			userMonthChartObj.nextReport();
		});
		//이전해 버튼
		$('#fixedTabAccViewArea #yearCal .prev').click(function(){
			userMonthChartObj.prevReport();
		});	
	
		/*more */
		$("#fixedTabAccViewArea .card_more").on("click", function(){
			// 현재 선택된 탭 그룹 찾기
		    const tabGroup = $(this).closest('.card_root').find('.tab_list');
		    const selectedTab = tabGroup.find('.tab[aria-selected="true"]'); 
			switch (selectedTab.attr("data-type")){
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
			}
		});
		
		// Tiles 로 로딩시 자동으로 스크롤스타일이 적용되지 않아 수동 실행.
		var $scroll_area = $("#fixedTabAccViewArea [data-custom-scrollbar]").not(".mCustomScrollbar");
		$.each($scroll_area, function(){
		    new SimpleBar(this, {autoHide: false});
		});
				
		//대쉬보드
		const $eAccountingDashboardList = document.querySelector('.user_dashboard .dashboard_list');
	    const $eAccountingDashboardGroup = document.querySelectorAll('.user_dashboard .dashboard_list .dashboard_group');
	
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
	    $('.user_dashboard').on('click', '#activateDashboardEdit', function () {
	        $('.user_dashboard').addClass('dashboard_editing');
	        if ($eAccountingDashboardList) dashboardSortableList.option('disabled', false);
	        if ($eAccountingDashboardGroup.length > 0) dashboardSortableGroup.option('disabled', false);
	    });
	
	    // 대시보드 편집모드 취소
	    $('.user_dashboard').on('click', '#cancelDashboardEdit', function () {
			location.reload();
	    });
	    
	    this.toggleDashBoard = function(disableDnD){
   			if(disableDnD === true){
   				$('.user_dashboard').removeClass('dashboard_editing');	
   			}else{
   				$('.user_dashboard').addClass('dashboard_editing');
   			}
	        if ($eAccountingDashboardList) dashboardSortableList.option('disabled', disableDnD);
	        if ($eAccountingDashboardGroup.length > 0) dashboardSortableGroup.option('disabled', disableDnD);
   		};
	},
	
	getApprovalList : function(idx){
		var objId ="userApprovalList";
		var mode = "Approval";
		if (idx == 0){
			mode = "Approval";
		}else{
			mode = "Process";
		}
		
		$.ajax({
			url	: "/approval/user/getApprovalListData.do",
			type: "POST",
			data: {"mode"  :mode,	"searchGroupType":'',	"bstored":"false",	"userID":Common.getSession().UR_Code,	"businessData1":"ACCOUNT",	"pageSize":3,	"pageNo":1},
			success:function (data) {
				if(data.status == "SUCCESS"){
					var listCount = data.page.listCount;
					if (listCount== undefined || listCount ==0) {
						$("#"+objId).html(
							'<div class="ui_empty">'+
								'<p><spring:message code="Cache.msg_apv_101"/></p>'+ <!-- 조회할 목록이 없습니다. -->
							'</div>'
						);
						return;
					} 
					var $userApprList = '<ul class="post_list">';
					$.each( data.list, function(index, value) {
					    $userApprList += '<li onclick=\'userPortal.onClickPopButton("'+value.ProcessID+"\",\""+value.WorkItemID+"\",\""+value.TaskID+"\",\""+value.PerformerID+"\",\""+value.ProcessDescriptionID+"\",\""+value.FormInstID+"\",\""+value.FormSubKind+"\",\""+value.UserCode+"\",\""+value.FormID+"\",\""+value.BusinessData2+'","'+mode+'")\'>'+
                               '	<a href="#" class="post_item">'+
                               '	    <div class="ui_avatar"><img src="'+coviCmn.loadImage(value.PhotoPath)+'" onerror="coviCmn.imgError(this, true);"></div>'+
                               '   	 <div class="info">'+
                               '       	 <div class="main">'+
                               '           	 <strong>'+value.FormSubject+'</strong>'+
                               '	            <em>'+userComm.makeComma(value.BusinessData3)+'<spring:message code="Cache.ACC_lbl_won"/></em>'+
                               '   	     </div>'+
                               '       	 <div class="secondary">'+
                               '           	 <span>'+value.InitiatorName+'</span>'+
                               '	            <time>'+(mode=="Approval"?value.Created:value.Finished)+'</time>'+
                               '   	     </div>'+
                               '	    </div>'+
                               '	</a>'+
                           	'</li>';
					});
					$userApprList +='</ul>';
					$("#"+objId).html($userApprList);
				}
			},
			error:function (error){
			}
		});
	},
	cardReceiptPopup : function(key){
		var popupName	=	"CardReceiptPopup";
		var popupID		=	"cardReceiptPopup";
		var openerID	=	"userPortal";
		var popupTit	=	"<spring:message code='Cache.ACC_lbl_cardReceiptInvoice' />"; //신용카드 매출전표
		var url			=	"/account/accountCommon/accountCommonPopup.do?"
						+	"popupID="		+ popupID	+ "&"
						+	"openerID="		+ openerID	+ "&"
						+	"popupName="	+ popupName	+ "&"
						+	"approveNo="	+ key		+ "&"
						+	"receiptID="	+ key;
		Common.open("",popupID,popupTit,url,"320px", "510px","iframe",true,null,null,true);
	},
	taxInvoicePop : function(key){
		var popupName	=	"TaxInvoicePopup";
		var popupID		=	"taxInvoicePopup";
		var popupTit	=	"<spring:message code='Cache.ACC_lbl_taxInvoiceCash' />";	//전자세금계산서
		var url			=	"/account/accountCommon/accountCommonPopup.do?"
						+	"popupID="		+	popupID		+	"&"
						+	"popupName="	+	popupName	+	"&"
						+	"taxInvoiceID="	+	key;
		Common.open("",popupID,popupTit,url,"980px", "720px","iframe",true,null,null,true);
	},
	mobileReceiptPopup : function(FileID){
		var popupName	=	"FileViewPopup";
		var popupID		=	"FileViewPopup";
		var openerID	=	"userPortal";
		var callBack	=	"zoomMobileReceiptPopup";
		var popupTit	=	"<spring:message code='Cache.ACC_lbl_receiptPopup' />"; //영수증 보기
		var url			=	"/account/accountCommon/accountCommonPopup.do?"
						+	"popupID="		+ popupID	+ "&"
						+	"popupName="	+ popupName	+ "&"
						+	"fileID="		+ FileID	+ "&"
						+	"openerID="		+ openerID	+ "&"
						+	"callBackFunc="	+	callBack;
		Common.open("",popupID,popupTit,url,"340px","500px","iframe",true,null,null,true);
	},
	zoomMobileReceiptPopup : function(info){
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
	usageTextWritePopup : function(key, proofCode){
		var popupName	=	"UsageTextWritePopup";
		var popupID		=	"UsageTextWritePopup";
		var openerID	= 	"userPortal";
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
	},	
	usageTextWritePopup_CallBack : function() {
		location.reload(); //증빙사용내역은 c:foreach 구문으로 출력되기 때문에 해당 목록만 새로고침 불가능
	},

	onClickPopButton:function(ProcessID,WorkItemID,TaskID,PerformerID,ProcessDescriptionID,FormInstID,SubKind,UserCode,FormID,BusinessData2, g_mode){
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
}	

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
/* 사용자 포탈 월별 신청내역 함수 */
var userMonthChartObj = {
	data : {"payYear":${fn:substring(payDate,0,4)}}
	,init:function(date){
		this.data.payYear = Number( date.replace(/(\d{4})(\d{2})/,"$1") );			
		this.chart = new Chart( $("#userMonthChart"),{
		    type: 'bar',
		    data: { labels: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'] },
		    options: {
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

                        // Sum
                        tooltipModel.dataPoints.forEach(function (item) {
                            sum += item.yLabel;
                        });

                        // Append Html
                        let innerHtml = '';
                        innerHtml += '<div class="head"><strong>'+tooltipModel.title[0]+'</strong><span><em>'+sum.toLocaleString()+'</em>원</span></div><div class="body">';

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
		this.data.searchType = 'user';
		userComm.getData("/account/accountPortal/getAccountMonth.do",this.data)
			.done( $.proxy( function( data ){  this.draw( data.chartObj ) } ,this) )
			.fail(  function( e ){  coviCmn.traceLog(e) })
	}
	,draw : function( obj ){
		var chartColorList = [ "#0DBAE7","#2F5AC2","#8D6DFC","#99CD05","#FF6666","#48626D"];
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
		//타이틀
		$('#fixedTabAccViewArea #monthChartTit .title').text( this.data.payYear+Common.getDic("lbl_year")+" "+Common.getDic("CPEAccounting_monthDetails") ); //년 월별 신청내역
	}
}
var userAccountChartObj={
	g_year :  ${fn:substring(payDate,0,4)},
	g_month: ${fn:substring(payDate,4,6)},
	chart:null,
	chartData :{labels :["전자세금계산서","모바일영수증","법인카드"]					
				,datasets : [{
					data : [${proofCount.TaxBillAmount},${proofCount.ReceiptAmount},${proofCount.CorpCardAmount}]
					,borderWidth : 0
					,backgroundColor : [ "#009DF6", "#254CAA", "#99CD05"]
				}]},
	chartObj : {
	    data : this.chartData,
		options: {
	        devicePixelRatio: 2,
	        maintainAspectRatio: false,
	        legend: {
	            display: false
	        },
	        tooltips: {
	            mode: 'index',
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
	                tooltipEl.style.left = position.left + tooltipModel.caretX + 'px';
	                tooltipEl.style.top = position.top + tooltipModel.caretY + 'px';
	            }
	        }
	    }
	},
	initChart:function(data){
		this.chartObj.data = this.chartData;
		this.chartObj.data.datasets[0].data=data;
		this.chartObj.type = 'doughnut';
		if(${proofCount.TotalAmount} == 0){
			$("#userProofDoughnut, #userProofList").attr("hidden", true);
			$("#userProofEmpty").removeAttr("hidden");
		} else {
			$("#userProofEmpty").attr("hidden", true);
			$("#userProofDoughnut, #userProofList").removeAttr("hidden");
		}
		this.chart = new Chart(  $("#userProofDoughnut"), this.chartObj ); 
	},					
	drawChart:function(data){
		this.chartObj.data.datasets[0].data=data;
		this.chart.data =this.chartObj.data;
		this.chart.update();
	},
	getUserMonth:function(v){
		if (v == "+") {
			this.g_month++;
			if (this.g_month > 12) { this.g_year++; this.g_month = 1; }
		} else if (v == "-"){
			this.g_month--;
			if (this.g_month < 1) { this.g_year--; this.g_month = 12; }
		}
		this.g_month=parseInt(this.g_month)<10?"0"+parseInt(this.g_month):this.g_month;

		$.ajax({
			url:"/account/accountPortal/getAccountUserMonth.do",
			type:"POST",
			data:{"payDate" : this.g_year+""+this.g_month},
			success:function (r) {
				if(r.result == "ok"){
					$("#fixedTabAccViewArea #portalTitle").text(r.payDate.substring(0,4)+Common.getDic("lbl_year")+" "+r.payDate.substring(4,6)); //월리포트
					var proofCount = r.proofCount;
					//증빙별
					if(proofCount != undefined) {
						if(Array.isArray(proofCount)) proofCount = proofCount[0];
						var data = [proofCount["TaxBillAmount"],proofCount["ReceiptAmount"],proofCount["CorpCardAmount"]];
						if (proofCount["TotalAmount"] == 0){
						    data = [0,0,0];
						    $("#userProofDoughnut, #userProofList").attr("hidden", true);
						    $("#userProofEmpty").removeAttr("hidden");
						}else{
						    $("#userProofEmpty").attr("hidden", true);
						    $("#userProofDoughnut, #userProofList").removeAttr("hidden");
						    
							var colArray = [["TaxBill","ACC_lbl_taxInvoiceCash"],["Receipt","ACC_lbl_mobileReceipt"],["CorpCard","ACC_lbl_corpCard"]];
							var sListHtml ='';
							for (var i=0; i< colArray.length;i++){
								sListHtml   += '<li>'+
	                                           '    <div class="item t_'+i+'">'+
	                                           '        <i style="background:'+userAccountChartObj.chartData.datasets[0].backgroundColor[i]+'"></i>'+
	                                           '        <span>'+Common.getDic(colArray[i][1])+'('+proofCount[colArray[i][0]+"Cnt"] + Common.getDic("ACC_lbl_items")+')</span>'+
	                                           '        <strong>'+userComm.makeComma(proofCount[colArray[i][0]+"Amount"]) + Common.getDic("ACC_lbl_won")+'</strong>'+
	                                           '    </div>'+
	                                           '</li>';
							}
						}
						
						$("#account_portal_user_proof_tot").text(userComm.makeComma(proofCount["TotalAmount"]));
						$("#account_portal_user_proof_list").html(sListHtml);
						userAccountChartObj.drawChart(data);
					}
					
					var accountCount = r.accountCount;
					//계정별
					if(accountCount != undefined) {
						if (accountCount.length == 0){
							$("#account_portal_user_account_tot").text("0");
							$("#account_portal_user_account_slide").attr("hidden", true);
							$("#userAccountList").attr("hidden", true);
							$("#userAccountEmpty").removeAttr("hidden");
						}else{
						    $("#userAccountEmpty").attr("hidden", true);
							$("#userAccountList").removeAttr("hidden");
							var sChartHtml = '<ul class="list">';
							var totCnt = accountCount[0].Amount;
							
							var barBgcolors = ["#0DBAE7", "#2F5AC2", "#8D6DFC", "#99CD05", "#FF6565", "#48626D"];
							var accountBgcolors = ["#CEF1FA", "#D5DEF3", "#E8E2FF", "#EBF5CD", "#FFE0E0", "#DADFE2"];
							
							var intBg = 0; 
							for (var i=1; i< accountCount.length;i++){
								var per	= accountCount[i].Amount*100.00/totCnt;

								if (i>4 && i%5 == 1){
									sChartHtml   += '</ul><ul class="list" hidden="">'; 
									intBg = 0;
								}
								sChartHtml	+=	'<li>'+
                                                '    <div class="item">'+
                                                '        <span>'+accountCount[i].Name+'('+accountCount[i].Cnt+')</span>'+
                                                '        <div class="progress" style="background-color:'+accountBgcolors[intBg]+'"><div class="bar" data-width="'+per+'" style="width: '+per+'%; background-color:'+barBgcolors[intBg]+'"></div></div>'+
                                                '        <strong>'+userComm.makeComma(String(accountCount[i].Amount))+'<spring:message code="Cache.ACC_lbl_won"/></strong>'+
                                                '    </div>'+
                                                '</li>';
                               intBg++;
							}
							
							$("#account_portal_user_account_tot").text(userComm.makeComma(String(totCnt)));
							$("#userAccountList").html(sChartHtml+"</ul>");
							$("#userAccountList").append('<div class="pagination" role="tablist" hidden="" id="account_portal_user_account_slide">');
	
							if (accountCount.length > 6){
								for (var i=0; i<Math.ceil(accountCount.length/5); i++){
									var isSelected = i == 0 ? 'aria-selected="true"' : '';
    								$("#account_portal_user_account_slide").append('<button type="button" role="tab" onclick="userComm.AccountSlide('+i+')" ' + isSelected + '><span>'+i+'</span></button>');
    								$("#account_portal_user_account_slide").removeAttr('hidden');
								}
							}	
						}		
					}
					
				}
				else{
					alert(r.message);
				}
			},
			error:function(response, status, error){
				alert(error)
			}
		});
	}	
}

var userComm = {		
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
		,AccountSlide:function(idx){
			$("#userAccountList ul").attr("hidden",true);
		
			$('#userAccountList ul').eq(idx).removeAttr('hidden');	
		}	
}

$(document).ready(function(){
	userPortal.pageInit();
});

// 홈 탭(섹션) 순서 저장
function sortUserPortalSectionTab(){
	var sortListArr = [];
	var sortList = $(".user_dashboard").find(".dashboard_card", ".dashboard_list");
	for(var i = 0; i < sortList.length; i++){
		sortListArr.push(sortList[i].getAttribute("type"));
	}
	
	var pUrl = "/account/user/updatePortalSectionSort.do";
	var pParam = {
		"sortList" : sortListArr.join(";"),
		"Type" : "USER"
	};
	var pAsync = true;
	var pCallBack = function(data){
		if(data.status == "SUCCESS"){
			userPortal.toggleDashBoard(true);
		}
	};
	CFN_CallAjax(pUrl, pParam, pCallBack, pAsync, "json");
}
</script>