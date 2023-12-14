<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="bizcard_list_page" class="mob_rw">

	<script>
		var BizcardMenu = ${Menu};	//좌측 메뉴
	</script>
	
	<header data-role="header" id="bizcard_list_header">
		<div class="sub_header">
	        <div class="l_header">
	        	<a href="javascript:mobile_comm_TopMenuClick('bizcard_list_topmenu');" class="topH_menu"><span>전체메뉴</span></a>
				<div class="menu_link gnb">
					<span id="bizcard_list_title" href="javascript:void(0);" class="topH_tit"></span> <!-- 전체 연락처 -->
					<div class="cover_leftmenu" style="display:none;">
						<div class="LsubHeader">
							<span class="LsubTitle board"><spring:message code='Cache.BizSection_BizCard' /></span>
							<span class="LsubTitle_btn">
								<button type="button" onclick="mobile_comm_TopMenuClick('bizcard_list_topmenu',true);return false;" class="btn_close ui-btn ui-shadow ui-corner-all"><i><spring:message code='Cache.btn_Close' /></i></button>
							</span>							
						</div>
						<div class="tree_default" id="bizcard_list_topmenu"></div>
					</div>
					<div class="left_bg_dim" onclick="mobile_comm_TopMenuClick('bizcard_list_topmenu',true);return false;" style="display: none;"></div>					
				</div>
			</div>
			<div class="utill">
				<%-- <a href="javascript: mobile_comm_go('/groupware/mobile/bizcard/select.do');" class="btn_contact"><span><spring:message code='Cache.lbl_bizcard_Contact' /></span></a> <!-- 연락처 --> --%>				
				<a href="javascript: mobile_comm_opensearch();"" class="topH_search"><span class="Hicon"><spring:message code='Cache.btn_search' /></span></a> <!-- 검색 -->				
				<a href="javascript: mobile_bizcard_clickrefresh();" class="topH_reload"><span class="Hicon">새로고침</span></a>
				<%-- <a href="javascript: mobile_bizcard_clickwrite();" class="btn_write"><span><spring:message code='Cache.btnWrite' /></span></a> <!-- 작성 --> --%>
			</div>
		</div>
		<div class="ly_search ly_change" >
			<a href="javascript: mobile_bizcard_clickrefresh(); mobile_comm_closesearch();" class="topH_back"><span><spring:message code='Cache.btn_Close' /></span></a> <!-- 닫기 -->
			<input type="text" id="mobile_search_input" name="" value="" voiceInputType="callback" voiceStyle="margin-right:25px;" voiceCallBack="mobile_bizcard_clicksearch"  class="mobileViceInputCtrl" placeholder="<spring:message code='Cache.msg_bizcard_searchBy' />" onkeypress="if (event.keyCode==13){ mobile_bizcard_clicksearch(); return false;}" onkeyup="mobile_comm_searchinputui('mobile_search_input');" /> <!-- 이름, 이메일, 핸드폰으로 검색 -->
			<a id="mobile_search_input_btn" href="javascript: mobile_bizcard_clicksearch();" class="topH_search" style="display: none;"></a>
			<a href="javascript: mobile_comm_cleansearch(); mobile_comm_searchinputui('mobile_search_input');" class="topH_del ui-link"></a>
		</div>
	</header>

	<div data-role="content" class="cont_wrap" id="bizcard_list_content">
		<ul id="bizcard_list_data" class="bizcard_person_list"></ul>
		<div id="bizcard_list_more" class="btn_list_more" style="display: none;">
			<a href="javascript: mobile_bizcard_nextlist();"><span><spring:message code='Cache.lbl_MoreView' /></span></a> <!-- 더보기 -->
		</div>
	</div>
	
	<!-- 작성버튼 시작 -->
	<div class="list_writeBTN">
   		<a href="javascript: mobile_bizcard_clickwrite();" class="btn_write"><span><spring:message code='Cache.btnWrite' /></span></a> <!-- 작성 -->
  	</div>
  	
	<div class="bg_dim" style="display: none;"></div>
	
</div>