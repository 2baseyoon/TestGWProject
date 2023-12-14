<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="community_home_page">	
	
	<header data-role="header" id="community_home_header" class="header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript:mobile_comm_go('/groupware/mobile/community/portal.do?menucode=CommunityMain');" class="topH_back ui-link"><span>이전페이지로 이동</span></a>
				<a href="javascript:mobile_comm_TopMenuClick('community_home_topmenu');" class="topH_menu"><span>전체메뉴</span></a>
				<div class="menu_link gnb">
					<span id="community_home_title" href="javascript:void(0);" class="topH_tit"></span>
					<div class="cover_leftmenu" style="display:none;">
						<div class="LsubHeader">
							<span class="LsubTitle community"><spring:message code='Cache.BizSection_Community' /></span>
							<span class="LsubTitle_btn">
								<button onclick="mobile_comm_TopMenuClick('community_home_topmenu',true);return false;" type="button" class="btn_close"><i>닫기</i></button>
							</span>
						</div>
						<div class="tree_default" id="community_home_topmenu">
							<ul class="h_tree_menu_wrap">
								<li>									
									<ul id="community_list_treeCategory" class="h_tree_menu_list"></ul>		
								</li>
							</ul>													
					 	</div> 
					</div>
					<div class="left_bg_dim" onclick="mobile_comm_TopMenuClick('community_home_topmenu',true);return false;" style="display: none;"></div>
				</div>
			</div>								
			<div class="utill">								
				<div class="dropMenu">
					<a id="community_home_btnAdd" href="javascript:void(0);" class="topH_exmenu ui-link" onclick="mobile_community_showORhide(this);"><span class="Hicon">확장메뉴</span></a>
					<div class="exmenu_layer">
						<ul class="exmenu_list"></ul>
					</div>
				</div>
	        </div>		        	        		
		</div>  
	</header>
	<div data-role="content" class="cont_wrap" id="community_home_content">
		<div class="g_list">
			<select id="community_home_myCommunitySel" name="" class="full sel_type" onchange="javascript: mobile_community_clickCommunitySel();">
				<option value=""><spring:message code='Cache.lbl_MyCommunity' /></option> <!-- 내가 가입한 커뮤니티 -->
			</select>
			<div class="community_img" style="background-image:url('../../resources/images/bg_com_img.png')">
				<div class="txt_area">
					<p class="name"><!-- 멘토멘티의 공간 --></p>
					<p class="opening"><!-- 개설일 : 2008.12.20  --><span><!-- 회원 : 32명 --></span></p>
				</div>
			</div>

			<p class="list_tit"><spring:message code='Cache.CommunityHomeBoardType_NOTICE' /></p> <!-- 공지사항 -->
			<ul id="community_home_listNotice">
			</ul>
		</div>
		<div id="community_home_btnNoticeMore" class="btn_list_more" style="display: none;">
			<a href="javascript: mobile_community_noticeNextlist('home');"><span><spring:message code='Cache.lbl_MoreView' /></span></a> <!-- 더보기 -->
		</div>
	</div>
	<div class="btn_private_secretary" style="display:none;">
		<a href="javascript:void(0);" class=""><span>상담</span></a> <span class="ico_new">N</span>
	</div>
	<div class="bg_dim" style="display: none;"></div>
	
</div>