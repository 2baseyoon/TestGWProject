<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="egovframework.baseframework.util.SessionHelper"%>
<%@ page import="egovframework.coviframework.util.ClientInfoHelper"%>
<% 
	boolean isMobile = ClientInfoHelper.isMobile(request);
	String useTeamsAddIn = "N";
	String userAgent = request.getHeader("User-Agent");
	String pIsTeamsAddIn = request.getParameter("teamsaddin");
    if ((userAgent != null && userAgent.toLowerCase().indexOf("teams") > -1) || (pIsTeamsAddIn != null && pIsTeamsAddIn.toUpperCase().equals("Y"))) {
    	useTeamsAddIn = "Y";
    }
%>
<c:set var="idPrefix" value="account_portal_manager_"/>
<div data-role="page" id="account_portal_manager_page">
	<script>
		var AccountMenu = ${Menu};	//좌측 메뉴
		//var AccountMenu = "portal_manager";	//좌측 메뉴
	</script>
	<style>
		.Gragh_color.blue6 {
	    	background-color: #e5e5e5;
		}
	</style>
	
	<header class="header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript:mobile_comm_TopMenuClick('account_portal_manager_topmenu');" class="topH_menu"><span></span></a>
				<div class="menu_link gnb">
					<span id="account_portal_title" class="topH_tit"><spring:message code='Cache.ACC_lbl_eAccounting'/></span>
					<div class="cover_leftmenu" style="display:none;">
						<div class="LsubHeader">
							
							<span class="LsubTitle approval" onclick="mobile_account_PortalLinkClick('Portal');"></span>
							
							<span class="LsubTitle_btn">
								<button type="button" onclick="mobile_comm_TopMenuClick('account_portal_manager_topmenu',true);return false;" class="btn_close ui-btn ui-shadow ui-corner-all"><i>닫기</i></button>
							</span>
						</div>
						<div class="tree_default" id="account_portal_manager_topmenu"></div>
					</div>
					<div class="left_bg_dim" onclick="mobile_comm_TopMenuClick('account_portal_manager_topmenu',true);return false;" style="display: none;"></div>
				</div>
			</div>
		</div>
	</header>
    
    <div class="cont_wrap">
		<div class="calendar_wrap month">
			<div class="calendar_ctrl">
				<div class="selBox top_selbox_cal" style="width:70px;">
					<select class="selectType02 lg widSm"  id="account_portal_manager_report">
						<option value="">코비젼</option>						
					</select>						
				</div>
				<div class="month_ctrl" id="${idPrefix}reportCal">
					<a href="#" class="prev_month ui-link"></a>
					<p class="t_month"><a class="ui-link" id="${idPrefix}reportCalTxt"></a></p>
					<a href="#" class="next_month ui-link"></a>
				</div>
			</div>
		</div>
		<div class="Newgragh_eAPBoard" id="${idPrefix}reportDiv">
			<div class="squaregraph01_wrap">
				<span class="squaregragh_Title">총금액 :</span><span class="squaregragh_Textb" id="${idPrefix}reportExpTot"></span><span class="squaregragh_Title"> 원</span>
				<span class="squaregragh_Text_sub" id="${idPrefix}reportExpCnt"></span>
			</div>
			<div class="Newgragh_eAPBoardL">
				<h3 class="Newgragh_eAPBoardTitle">용도별 지출현황</h3>
				<div class="Newgragh_eAPBoardContents">
					<div class="Newgragh_eAPBoardCardBox">
							<canvas id="account_portal_manager_proofDoughnut"></canvas>		
					</div>
					<div class="graph_contentbox">
						<div class="Newgragh_Detailrank_menu">
							<div class="selBox">
								<select class="selectType02 lg widSm" id="${idPrefix}proofCategory"></select>						
							</div>
							<a class="per_tit">전월대비</a>
						</div>
						<div class="Newgragh_Detailrank" id="${idPrefix}proofList">
							<ul></ul>
						</div>	
					</div>
				</div>				
			</div>
			<div class="Newgragh_eAPBoardR">
				<h3 class="Newgragh_eAPBoardTitle">부서별 지출현황</h3>
				<div class="Newgragh_eAPBoardContents">					
					<div class="Newgragh_eAPBoardCardBox">
						<canvas id="account_portal_manager_accountDoughnut"></canvas>
					</div>
					<div class="graph_contentbox">
						<div class="Newgragh_Detailrank_menu">
							<div class="selBox" style="width:105px;">
								<select class="selectType02 lg widSm" id="${idPrefix}accountCategory"></select>						
							</div>
							<a class="per_tit">전월대비</a>
						</div>
						<div class="Newgragh_Detailrank" id="${idPrefix}accountList">
							<ul></ul>
						</div>	
					</div>
				</div>
				<!--슬라이드 버튼 -->
				<div class="Slideroll_btn">
					<a class="Slideroll_btn_on" href="#"><span></span></a>
					<a class="Slideroll_btn_off" href="#"><span></span></a>
					<a class="Slideroll_btn_off" href="#"><span></span></a>
				</div>	
				<!--슬라이드 버튼 끝 -->
			</div>
		</div>
		<div class="squaregraph01_wrap">
			<div class="selBox top_selbox" style="width:70px;">
				<select class="selectType02 lg widSm" id="account_portal_manager_monthReport">
					<option value="">코비젼</option>					
				</select>						
			</div>
			<span class="squaregragh_Title" style="margin-left:5px;">2020년 월별 신청내역</span>
		</div>
		<div class="NewColorChart_graphtext_fbox">				
			<div class="NewColorChart_graphContent">
				<canvas id="${idPrefix}monthChart" width="390" height="90"></canvas>
			</div>
		</div>
		<div class="squaregraph01_wrap">
			<span class="squaregragh_Title" style="margin-left:5px;">감사규칙</span>
		</div>
		<div class="circle_box_fbox">
			<div class="circle_box" id="${idPrefix}auditList">
				<ul>
					<li class="circleBtncolor01" style="cursor: pointer;">
						<span class="txt01">동일가맹점 중복 사용</span>
						<span class="txt02"><strong id="${idPrefix}auditDupStore">0건</strong></span>
					</li>
					<li class="circleBtncolor01" style="cursor: pointer;">
						<span class="txt01">접대비 사용보고서</span>
						<span class="txt02"><strong id="${idPrefix}auditEnterTain">0건</strong></span>
					</li>
					<li class="circleBtncolor01" style="cursor: pointer;">
						<span class="txt01">휴일/심야 사용보고서</span>
						<span class="txt02"><strong id="${idPrefix}auditHolidayUse">0건</strong></span>
					</li>										
					<li class="circleBtncolor01" style="cursor: pointer;">
						<span class="txt01">규정금액 이상 사용보고서</span>
						<span class="txt02"><strong id="${idPrefix}auditLimitAmount">0건</strong></span>
					</li>										
					<li class="circleBtncolor01" style="cursor: pointer;">
						<span class="txt01">사용자 휴가 사용 보고서</span>
						<span class="txt02"><strong id="${idPrefix}auditUserVacation">0건</strong></span>
					</li>
				</ul>
			</div>
		</div>
		<div class="squaregraph01_wrap">
				<div class="selBox top_selbox" style="width:70px;">
					<select class="selectType02 lg widSm" id="account_portal_manager_budgetReport">
						<option value="">코비젼</option>						
					</select>						
				</div>
				<span class="squaregragh_Title" style="margin-left:5px;">자기개발비</span>
		</div>
		<div class="Monthlygraph_box">
			<div class="Monthly_graph_1">	
				<div class="squaregragh_Text_sub">월별 예산대비 지출 현황</div>
				<span class="squaregragh_Title">예산 </span>
				<span class="squaregragh_Textb2" id="${idPrefix}budgetAmount">80,000,000</span>
				<span class="squaregragh_Title"> 원</span>
			</div>
			<div class="Monthly_fbox">
				<div class="Monthly_content_l">
					<div class="Monthly_graph_lineBar blue_a" style="margin-left:0px; height:91px; width:5px;"></div>
					<div class="Monthly_content_tbox">
						<p class="Monthly_content_tit">지출</p>
						<span class="Monthly_content_t1" id="${idPrefix}UsedAmount">24,747,980</span><span>원</span>
					</div>
				</div>
				<div class="Monthly_content_c">
					<div class="Monthly_graph_lineBar blue_b" style="margin-left:0px; height:91px; width:5px;"></div>
					<div class="Monthly_content_tbox">
						<p class="Monthly_content_tit">진행</p>
						<span class="Monthly_content_t1" id="${idPrefix}processAmount">10,320,923</span><span>원</span>
					</div>
				</div>
				<div class="Monthly_content_r">
					<div class="Monthly_graph_lineBar blue_c" style="margin-left:0px; height:91px; width:5px;"></div>
					<div class="Monthly_content_tbox">
						<p class="Monthly_content_tit">잔액</p>
						<span class="Monthly_content_t1" id="${idPrefix}leftAmount">44,930,980</span><span>원</span>
					</div>
				</div>
			</div>
		</div>
		<div class="MonColorChart_graphtext_fbox">
			<div class="MonColorChart_graphContent_b">									
				<canvas id="${idPrefix}budgetChart" width="390" height="90"></canvas>						
			</div>
		</div>
		<% if ("Y".equals(useTeamsAddIn) && !isMobile) { %>
				<div id="divPopBtnArea" class="FloatingBtn">
					<ul class="popBtn">
						<li class="btnNewPopup"><a href="javascript:void(0);" onclick="XFN_TeamsOpenGroupware('EACCOUNTING');">새창</a><span class="toolTip2">새창</span></li>
					</ul>
				</div>
		<% } %>
    </div>
</div>
<div class="mobile_popup_wrap" id="${idPrefix}popup" style="display: none;"></div>