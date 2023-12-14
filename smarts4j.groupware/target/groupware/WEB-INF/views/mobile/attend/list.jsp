<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
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
<div data-role="page" id="attend_list_page" class="mob_rw">
	<script>
		var AttendMenu = ${Menu};	//좌측 메뉴
	</script>
	
	<header data-role="header" id="attend_list_header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript:mobile_comm_TopMenuClick('attend_list_topmenu');" class="topH_menu"><span><spring:message code='Cache.lbl_FullMenu'/></span></a> <!-- 전체메뉴 -->
				<div class="menu_link gnb">
					<span id="attend_list_title" href="javascript:void(0);" class="topH_tit"><spring:message code='Cache.lbl_DeptStatus'/></span> <!-- 부서현황 -->
					<div class="cover_leftmenu" style="display:none;">
						<div class="LsubHeader">
							<span class="LsubTitle board"><spring:message code='Cache.BizSection_Attendance' /></span> <!-- 근태관리 -->
							<span class="LsubTitle_btn">
								<button type="button" onclick="mobile_comm_TopMenuClick('attend_list_topmenu',true);return false;" class="btn_close ui-btn ui-shadow ui-corner-all"><i><spring:message code='Cache.btn_Close' /></i></button>
							</span>
						</div>
						<div class="tree_default" id="attend_list_topmenu"></div>
					</div>
					<div class="left_bg_dim" onclick="mobile_comm_TopMenuClick('attend_list_topmenu',true);return false;" style="display: none;"></div>
				</div>
			</div>
		</div>
	</header>
	
	<div data-role="content" class="cont_wrap" id="attend_list_content">
		<div class="calendar_wrap month">
			<div class="calendar_ctrl">
				<div class="SelDept">
					<select id="attend_list_select" class="" style="height: 26px;"></select>
				</div>
				<div class="month_ctrl">
					<a href="#" id="attend_list_prev_month" class="prev_month"></a>
					<p class="t_month"><a href="#" id="attend_list_today" class=""></a></p>
					<a href="#" id="attend_list_next_month" class="next_month"></a>
				</div>
				<input type="hidden" id="attend_list_input_calendar" class="" />
				<a href="#" id="attend_list_btn_calendar" class="btn_calendar"><spring:message code='Cache.lbl_schedule_calendar' /></a> <!-- 달력 -->
		    </div>
		    <div class="slide_bar">
 				<span class="slide_color" id="sSlide_bar">바</span>
 			</div>
			<div class="ws_todo_line"></div>
			<div class="staff_wrap">
				<ul id="attend_list_dept" class="staff_list"></ul>
				<div id="attend_list_more" class="btn_list_more" style="display: none;">
					<a href="#" class="ui-link"><span><spring:message code='Cache.lbl_MoreView' /></span></a> <!-- 더보기 -->
				</div>
			</div>
		</div>
	</div>
	<% if ("Y".equals(useTeamsAddIn) && !isMobile) { %>
	    <!-- 작성, 업무시스템 바로가기 사용시 -->
	    <div id="divPopBtnArea" class="FloatingBtn">
	        <ul class="popBtn">
				<li class="btnNewPopup"><a href="javascript:void(0);" onclick="XFN_TeamsOpenGroupware('ATTENDANCE');">새창</a><span class="toolTip2">새창</span></li>
	        </ul>
	    </div>
	<% } %>	
</div>