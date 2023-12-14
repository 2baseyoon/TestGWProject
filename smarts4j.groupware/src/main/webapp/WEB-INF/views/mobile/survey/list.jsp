<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.baseframework.util.SessionHelper" %>
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
<div data-role="page" id="survey_list_page" class="mob_rw">	
	
	<script>
		var SurveyMenu = ${Menu}; //상단 메뉴
	</script>
	
	<header data-role="header" id="survey_list_header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript: mobile_comm_back();" class="topH_back" style="display:none;" id="aBtnBack"><span>커뮤니티 이전 페이지로 이동</span></a>
				<a href="javascript:mobile_comm_TopMenuClick('survey_list_topmenu');" class="topH_menu"><span>전체메뉴</span></a>
				<div class="menu_link gnb">
					<span id="survey_list_title" href="javascript:void(0);" class="topH_tit"></span>
					<div class="cover_leftmenu" style="display:none;">
						<div class="LsubHeader">
							<c:choose>
								<c:when test='${communityID != null}'>
									<span class="LsubTitle board"><spring:message code='Cache.BizSection_Community' /></span>
								</c:when>
								<c:otherwise>
									<span class="LsubTitle board"><spring:message code='Cache.BizSection_Survey' /></span>
								</c:otherwise>
							</c:choose>
							<span class="LsubTitle_btn">
								<button type="button" onclick="mobile_comm_TopMenuClick('survey_list_topmenu',true);return false;" class="btn_close ui-btn ui-shadow ui-corner-all"><i><spring:message code='Cache.btn_Close' /></i></button>
							</span>
						</div>
						<div class="tree_default" id="survey_list_topmenu"></div>
					</div>
					<div class="left_bg_dim" onclick="mobile_comm_TopMenuClick('survey_list_topmenu',true);return false;" style="display: none;"></div>		            
				</div>
			</div>
			<div class="utill">
				<a href="javascript: mobile_comm_opensearch();" class="topH_search"><span class="Hicon"></span></a>				
				<a href="javascript: mobile_survey_clickrefresh();" class="topH_reload"><span class="Hicon">새로고침</span></a>				
			</div>
		</div>
		<div class="ly_search ly_change">
			<a href="javascript: mobile_comm_closesearch(); mobile_survey_clickrefresh();" class="topH_back"><span><spring:message code='Cache.btn_Close' /></span></a> <!-- 닫기 -->
			<input type="text" id="mobile_search_input"  voiceInputType="change" voiceStyle="margin-right:25px;" voiceCallBack="mobile_survey_clicksearch"  class="mobileViceInputCtrl" name="" value="" placeholder="<spring:message code='Cache.msg_survey_searchBy' />" onkeypress="if (event.keyCode==13){ mobile_survey_clicksearch(); return false;}" onkeyup="mobile_comm_searchinputui('mobile_search_input');" /> <!-- 제목, 등록자, 내용으로 검색 -->
			<a id="mobile_search_input_btn" href="javascript: mobile_survey_clicksearch();" class="topH_search" style="display: none;"></a>
			<a href="javascript: mobile_comm_cleansearch(); mobile_comm_searchinputui('mobile_search_input');" class="topH_del"></a>
		</div>
	</header>
	
	<div data-role="content" class="cont_wrap" id="survey_list_content">
		<div class="g_list" style="display: none;">
			<select id="community_home_myCommunitySel" name="" class="full sel_type" onchange="javascript: mobile_community_clickCommunitySel();">
				<option value=""><spring:message code='Cache.lbl_MyCommunity' /></option> <!-- 내가 가입한 커뮤니티 -->
			</select>
		</div>
		
		<!-- 설문 리스트 영역 -->
		<ul id="survey_list_list" class="survey_list"></ul>
		
		<!-- 설문 리스트 더보기 -->
		<div id="survey_list_more" class="btn_list_more" style="display: none;">
			<a href="javascript: mobile_survey_nextlist();"><span><spring:message code='Cache.lbl_MoreView' /></span></a> <!-- 더보기 -->
		</div>
		
<% if ("Y".equals(useTeamsAddIn) && !isMobile) { %>
	    <!-- 작성, 업무시스템 바로가기 사용시 -->
	    <div id="divPopBtnArea" class="FloatingBtn">
	        <ul class="popBtn">
				<li class="btnNewPopup"><a href="javascript:void(0);" onclick="XFN_TeamsOpenGroupware('SURVEY');">새창</a><span class="toolTip2">새창</span></li>
	        </ul>
	    </div>
<% }%>
	</div>
	
	<div class="bg_dim" style="display: none;"></div>
	
</div>