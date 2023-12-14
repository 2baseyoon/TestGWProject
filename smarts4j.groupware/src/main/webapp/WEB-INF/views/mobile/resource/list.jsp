<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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

<div data-role="page" id="resource_list_page" class="mob_rw">
<input type="hidden" id="useTeamsAddIn" value="<%=useTeamsAddIn%>"/>
<input type="hidden" id="isMobile" value="<%=isMobile%>"/>
	<header id="resource_list_header">
		<div class="sub_header">
        <div class="l_header">
          <a id="btnResourceSelectBack" href="javascript: mobile_comm_back();" class="topH_back" style="display:none;"><span>닫기</span></a>
          <a href="javascript:mobile_comm_TopMenuClick('resource_list_topmenu');" class="topH_menu"><span>전체메뉴</span></a>
          <div class="menu_link gnb">
          	<span id="resource_list_title" href="javascript:void(0);" class="topH_tit"></span>
			<div class="cover_leftmenu" style="display:none;">
				<div class="LsubHeader">
					<span class="LsubTitle resource"><spring:message code='Cache.lbl_resource_title' /></span>
					<span class="LsubTitle_btn">
						<button type="button" onclick="mobile_ResourceMenuClose();" class="btn_close ui-btn ui-shadow ui-corner-all"><i>닫기</i></button>
					</span>
				</div>
				<div class="sorting">				             
					<ul>
						<li type="D" class="selected" name="resourcemenu">
							<a href="javascript: mobile_resource_changeViewType('D');" class="daily"><spring:message code='Cache.lbl_Daily' /></a>
						</li>
						<li type="W" name="resourcemenu">
							<a href="javascript: mobile_resource_changeViewType('W');" class="weekly"><spring:message code='Cache.lbl_Weekly' /></a>
						</li>						
						<li type="M" name="resourcemenu" style="display:none;">
							<a href="javascript: mobile_resource_changeViewType('M');" class="monthly"><spring:message code='Cache.lbl_Monthly' /></a>
						</li>						 
						<li type="L" name="resourcemenu">
							<a href="javascript: mobile_resource_changeViewType('L');" class="list"><spring:message code='Cache.btn_List' /></a>
						</li>
					</ul>
				</div>
				<div class="tree_default" id="resource_list_topmenu">
					<ul class="h_tree_menu_wrap">
						<li class="h_tree_sch_select">
							<div class="sch_select resource">
								<select id="resource_list_placeOfBusiness" name="" class="full sel_type" onchange="javascript: mobile_resource_changePlaceOfBusiness('list');"></select>
								<ul id="resource_list_resourceList" class="select_list"></ul>					
							</div>
						</li>
						<li type="P" name="resourcemenu"><div class="h_tree_menu"><a href="javascript: mobile_resource_changeViewType('P');" class="t_link ui-link"><span class="t_ico_my"></span><spring:message code='Cache.lbl_resource_myEvent' /></a></div></li>
						<li type="R" name="resourcemenu"><div class="h_tree_menu"><a href="javascript: mobile_resource_changeViewType('R');" class="t_link ui-link"><span class="t_ico_app"></span><spring:message code='Cache.lbl_resource_requestApprovalReturn' /></a></div></li>
					</ul>					
				</div>                                                    
			</div>
			<div class="left_bg_dim" onclick="mobile_ResourceMenuClose();" style="display: none;"></div>
          </div>
        </div>
        <div class="utill">                  
          <a href="javascript: mobile_resource_searchInput();" class="topH_search"><span class="Hicon"><spring:message code='Cache.btn_search' /></span></a> <!-- 검색 -->
          <a href="javascript: mobile_ResourceMenuClose();" class="topH_reload"><span class="Hicon"><spring:message code='Cache.lbl_Refresh' /></span></a> <!-- 새로고침 -->         
          <a href="javascript: mobile_resource_saveSelectedResource();" class="topH_save" id="resource_list_btnSaveResource" style="display: none;"><span class="Hicon">확인</span></a> <!-- 확인 -->
        </div>
      </div>
      
      <div class="ly_search ly_change" id="resource_div_search">		
		<a href="javascript: mobile_resource_changeDisplay(); mobile_comm_closesearch();" class="topH_back"><span><!-- 닫기 --></span></a>
		<input type="text" id="resource_search_input" class="mobileViceInputCtrl"  voiceInputType="callback" voiceStyle="margin-right:25px;" voiceCallBack="mobile_resource_search"  name="" value="" placeholder="<spring:message code='Cache.msg_resource_searchby' />" onkeypress="mobile_resource_searchEnter(event);" onkeyup="mobile_comm_searchinputui('resource_search_input');" /> <!-- 용도, 등록자로 검색 -->
		<a id="resource_search_input_btn" href="javascript: mobile_resource_search();" class="topH_search" style="display: none;"></a>
		<a href="javascript: mobile_resource_resetSearchInput(); mobile_comm_searchinputui('resource_search_input');" class="topH_del"></a>
	  </div>
	</header>
	<div data-role="content" class="cont_wrap" id="resource_list_content">
		<div class="calendar_wrap r_calendar">
			<div class="r_calendar_top month">
				<div class="calendar_ctrl">
					<div class="month_ctrl">
						<a href="javascript: mobile_resource_changeViewType('PREV');"  class="prev_month"></a>
						<p class="t_month"><a id="resource_list_datetitle"></a></p>
						<a href="javascript: mobile_resource_changeViewType('NEXT');" class="next_month"></a>
					</div>
					<a href="javascript: mobile_resource_movetoToday();" class="btn_today"><spring:message code='Cache.btn_Today' /></a> <!-- 오늘 -->
				</div>
				<div class="slide_bar">
					<span class="slide_color" id="sSlide_bar">바</span>
				</div>
				<div class="resource_pro_topselect">
					<div class="resource_pro_timeselect"></div>
				</div>
			</div>
		</div>
		
		<!-- 자원 영역 -->
		<div class="resource_pro_wrap" id="resource_pro_wrap_list">
			<ul id="resource_list_list" class="resource_pro_container"></ul>
		</div>
		
		
		<!-- 검색된 자원 영역 -->
		<ul id="resource_list_searchlist" class="resource_list my_list" style="display: none;"></ul>
		
		<div id="resource_list_more" class="btn_list_more" style="display: none;">
			<a href="javascript: mobile_resource_nextlist();"><span><spring:message code='Cache.lbl_MoreView' /></span></a> <!-- 더보기 -->
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
            <li class="btnWrite"><a href="javascript:void(0);" onclick="mobile_resource_clickwrite();">작성</a><span class="toolTip2">작성</span></li>
            <li class="btnNewPopup"><a href="javascript:void(0);" onclick="XFN_TeamsOpenGroupware('RESOURCE');">새창</a><span class="toolTip2">새창</span></li>
        </ul>
    </div>
<% } else {%>
	<div class="list_writeBTN">
      <a href="javascript: mobile_resource_clickwrite();" class="ui-link"><span>작성</span></a>
    </div>
<% }%>
	<div class="bg_dim" style="display: none;"></div>
</div>