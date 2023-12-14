<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
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

<!-- TODO : 다국어 처리 -->
<div data-role="page" id="board_list_page" class="mob_rw">

	<script>
		var BoardMenu = ${Menu};	//좌측 메뉴
	</script>

    <header class="header" id="board_list_header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript:mobile_comm_TopMenuClick('board_list_topmenu');" class="topH_menu"><span>전체메뉴</span></a>
				<div class="menu_link gnb">
					<span id="board_list_title" onclick="mobile_board_clickrefresh();" class="topH_tit"></span>
					<div class="cover_leftmenu" style="display:none;">
						<div class="LsubHeader">
							<c:choose>
								<c:when test='${communityID != null}'>
									<span class="LsubTitle board"><spring:message code='Cache.BizSection_Community' /></span>
								</c:when>
								<c:otherwise>
									<span class="LsubTitle board"><spring:message code='Cache.CPMail_IntergratedPublishing' /></span>
								</c:otherwise>
							</c:choose>
							<span class="LsubTitle_btn">
								<button type="button" onclick="mobile_comm_TopMenuClick('board_list_topmenu',true);return false;" class="btn_close ui-btn ui-shadow ui-corner-all"><i>닫기</i></button>
							</span>
						</div>
				 		<div class="tree_default" id="board_list_topmenu"></div>
		    		</div>
					<div class="left_bg_dim" onclick="mobile_comm_TopMenuClick('board_list_topmenu',true);return false;" style="display: none;"></div>
          		</div>
        	</div>                	
	        <div class="utill">
	          <a href="javascript: mobile_comm_opensearch();" id="board_list_search" class="topH_search"><span class="Hicon">검색</span></a>
	          <a href="javascript: mobile_board_clickrefresh();" class="topH_reload"><span class="Hicon">새로고침</span></a>			  
	        </div>
      	</div>
	  	<div class="ly_search ly_change" tabindex="0">
			<a href="javascript: mobile_comm_closesearch(); mobile_board_closesearch();" class="topH_back"><span><span><spring:message code='Cache.btn_Close' /></span></a> <!-- 닫기 -->
			<input type="text" id="mobile_search_input" class="mobileViceInputCtrl" voiceInputType="callback" voiceStyle="margin-right:25px;" voiceCallBack="mobile_board_clicksearch" name="" value="" placeholder="<spring:message code='Cache.msg_board_searchBy' />" onkeypress="if (event.keyCode==13){ mobile_board_clicksearch(); return false;}" onkeyup="mobile_comm_searchinputui('mobile_search_input');" /><!-- 제목, 내용으로 검색 -->
			<a id="mobile_search_input_btn" href="javascript: mobile_board_clicksearch();" class="topH_search" style="display: none;"></a>
			<a href="javascript: mobile_comm_cleansearch(); mobile_comm_searchinputui('mobile_search_input');" class="topH_del"></a>
		</div>
    </header>
	<div data-role="content" class="cont_wrap" id="board_list_content">
		<div class="g_list" style="display: none;">
			<select id="community_home_myCommunitySel" name="" class="full sel_type" onchange="javascript: mobile_community_clickCommunitySel();">
				<option value=""><spring:message code='Cache.lbl_MyCommunity' /></option> <!-- 내가 가입한 커뮤니티 -->
			</select>
		</div>
		
		<!-- 게시글 분류 영역 -->
		<select id="board_list_category" class="full sel_type" onchange="javascript: mobile_board_clickcategory();"></select>
		
		<!-- 게시글 목록 영역 -->
		<ul id="board_list_list" class="g_list"></ul>
		
		<div id="board_list_more" class="btn_list_more" style="display: none;">
			<a href="javascript: mobile_board_nextlist();"><span><spring:message code='Cache.lbl_MoreView' /></span></a> <!-- 더보기 -->
		</div>
	</div>
<% if ("Y".equals(useTeamsAddIn) && !isMobile) { %>
    <!-- 작성, 업무시스템 바로가기 사용시 -->
    <div id="divPopBtnArea" class="FloatingBtn">
        <ul class="popBtn">
            <li class="btnMore active" onclick="XFN_FloatingBtnMore_OnClick(this);"><a href="javascript:void(0);">더보기</a><span class="toolTip2">더보기</span></li>
            <li class="btnClose" onclick="XFN_FloatingBtnClose_OnClick(this);"><a href="javascript:void(0);">닫기</a><span class="toolTip2">닫기</span></li>
        </ul>
        <ul class="popBtn2" style="display: none;">
            <li class="btnWrite"><a href="javascript:void(0);" onclick="mobile_board_clickwrite();">작성</a><span class="toolTip2">작성</span></li>
            <li class="btnNewPopup"><a href="javascript:void(0);" onclick="XFN_TeamsOpenGroupware('BOARD');">새창</a><span class="toolTip2">새창</span></li>
        </ul>
    </div>
<% } else { %>
	<div class="list_writeBTN">
      <a href="javascript: mobile_board_clickwrite();" class="ui-link"><span>작성</span></a>
    </div>
<% } %>
	<div class="bg_dim" style="display: none;"></div>	
</div>