<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="community_portal_page" class="mob_rw">	
	
	<header data-role="header" id="community_portal_header" class="header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript:mobile_comm_TopMenuClick('community_portal_topmenu');" class="topH_menu"><span>전체메뉴</span></a>
				<div class="menu_link gnb">
					<span id="community_portal_title" href="javascript:void(0);" class="topH_tit"><spring:message code='Cache.BizSection_Community' /></span>
					<div class="cover_leftmenu" style="display:none;">
						<div class="LsubHeader">
							<span class="LsubTitle community"><spring:message code='Cache.BizSection_Community' /></span>
							<span class="LsubTitle_btn">
								<button onclick="mobile_comm_TopMenuClick('community_portal_topmenu',true);return false;" type="button" class="btn_close"><i>닫기</i></button>
							</span>
						</div>
						<div class="tree_default" id="community_portal_topmenu">
							<ul class="h_tree_menu_wrap">
								<li>
									<ul class="h_tree_menu_list"></ul>
									<ul id="community_portal_treeCategory" class="h_tree_menu_list"></ul>		
								</li>
							</ul>													
					 	</div> 
					</div>
					<div class="left_bg_dim" onclick="mobile_comm_TopMenuClick('community_portal_topmenu',true);return false;" style="display: none;"></div>
				</div>
			</div>
			<div class="utill">
				<a href="javascript: mobile_comm_opensearch();" class="topH_search"><span class="Hicon">검색</span></a>
				<a href="javascript: mobile_community_clickrefresh();" class="topH_reload"><span class="Hicon">새로고침</span></a>
				<a href="#" class="topH_add" style="display:none;"><span class="Hicon">생성</span></a>
				
				<div class="dropMenu" style="display: none;">
					<a id="community_portal_btnAdd" href="javascript:void(0);"
						class="topH_exmenu ui-link"
						onclick="mobile_community_showORhide(this);"><span
						class="Hicon">확장메뉴</span></a>
					<div class="exmenu_layer">
						<ul class="exmenu_list">
							<li><a href="javascript: mobile_community_clickwrite('F');"
								class="btn" style="display: true;"><spring:message
										code='Cache.lbl_AddFolder' /></a></li>
							<!-- 폴더 추가 -->
							<li><a href="javascript: mobile_community_clickwrite('T');"
								class="btn" style="display: true;"><spring:message
										code='Cache.lbl_AddTask' /></a></li>
							<!-- 업무 추가 -->
						</ul>
					</div>
				</div>
			</div>
		</div>
		<div class="ly_search ly_change">						
			<a href="javascript: mobile_comm_closesearch(); mobile_community_clickrefresh();" class="topH_back"><span><spring:message code='Cache.BizSection_Community' /><spring:message code='Cache.btn_Close' /></span></a> <!-- 닫기 -->
			<input type="text" id="mobile_search_input" name="" value=""  voiceInputType="callback" voiceStyle="margin-right:25px;" voiceCallBack="mobile_community_clicksearch"  class="mobileViceInputCtrl" placeholder="<spring:message code='Cache.msg_community_searchBy' />" onkeypress="if (event.keyCode==13){ mobile_community_clicksearch(); return false;}" onkeyup="mobile_comm_searchinputui('mobile_search_input');" /> <!-- 커뮤니티 이름, 운영자, 소개로 검색 -->
			<a id="mobile_search_input_btn" href="javascript: mobile_community_clicksearch();" class="topH_search" style="display: none;"></a>
			<a href="javascript: mobile_comm_cleansearch(); mobile_comm_searchinputui('mobile_search_input');" class="topH_del ui-link"></a>		  
		</div>
	</header>
	<div data-role="content" class="cont_wrap" id="community_portal_content">

		<div class="my_comm_list">
			<p class="list_tit"><spring:message code='Cache.lbl_MyCommunity' /></p> <!-- 내가 가입한 커뮤니티 -->
			<div id="community_portal_listMyCommunity" class="scr_h">
			</div>
		</div>
		<div class="g_list">
			<p class="list_tit"><spring:message code='Cache.lbl_MyCommunity_Notice' /></p> <!-- 내가 가입한 커뮤니티 공지사항 -->
			<ul id="community_portal_listNotice">
			</ul>
		</div>
		<div id="community_portal_btnNoticeMore" class="btn_list_more" style="display: none;">
			<a href="javascript: mobile_community_noticeNextlist('portal');"><span><spring:message code='Cache.lbl_MoreView' /></span></a> <!-- 더보기 -->
		</div>

	</div>	
	
	<div class="bg_dim" style="display: none;"></div>
	
</div>