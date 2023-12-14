<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="community_memberjoininfo_page">	
	
	<header data-role="header" id="community_memberjoininfo_header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript: mobile_comm_back();" class="topH_back"><span class="Hicon">이전페이지</span></a>
				<div class="menu_link gnb">
					<a id="community_memberjoininfo_title"  href="#" onclick="javascript: mobile_comm_TopMenuClick('community_memberjoininfo_title'); return false;" class="pg_tit"><spring:message code='Cache.lbl_User_Info' /><i class=\"arr_menu\"></i></a>
					<ul id="community_memberjoininfo_topmenu" class="h_tree_menu_wrap comm_menu">
		            </ul>
				</div>
			</div>
			<div class="utill">
				<a id="community_home_btnAdd" href="#" class="topH_exmenu" onclick="javascript: mobile_community_showORhide(this);"><span class="Hicon">확장메뉴</span></a>
				<div class="exmenu_layer">
					<ul class="exmenu_list">
					</ul>
				</div>
			</div>
		</div>
	</header>
	
	<div data-role="content" class="cont_wrap" id="community_memberjoininfo_content">
		<div class="tab_wrap member_info">
			<ul class="g_tab">
				<li><a href="#" onclick="mobile_community_clickTabWrap(this);"><span><spring:message code='Cache.lbl_User_Info' /></span></a></li> <!-- 회원정보 -->
				<li><a href="#" onclick="mobile_community_clickTabWrap(this);"><span><spring:message code='Cache.lbl_userRanking' /></span></a></li> <!-- 회원랭킹 -->
			</ul>
			<div class="tab_cont_wrap">
				<div class="tab_cont">
					<ul  id="community_memberjoininfo_memberJoinList" class="org_list">
					</ul>
					<div id="community_memberjoininfo_btnMemberJoinListMore" class="btn_list_more" style="display: none;">
						<a href="javascript: mobile_community_memberJoinNextlist();"><span><spring:message code='Cache.lbl_MoreView' /></span></a> <!-- 더보기 -->
					</div>
				</div>
				<div class="tab_cont">
					<div class="tab_wrap">
						<ul class="g_tab sm_tab">
							<li><a href="#" onclick="mobile_community_clickTabWrap(this);"><span><spring:message code='Cache.lbl_community_uploadBoard' /></span></a></li> <!-- 게시물 등록 -->
							<li><a href="#" onclick="mobile_community_clickTabWrap(this);"><span><spring:message code='Cache.CuPoint_Visit' /></span></a></li> <!-- 방문 -->
						</ul>
						<div class="tab_cont_wrap">
							<div class="tab_cont">
								<ul id="community_memberjoininfo_boardRankList" class="rank_list">
								</ul>
							</div>
							<div class="tab_cont">
								<ul id="community_memberjoininfo_visitRankList" class="rank_list">
								</ul>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
	
	<div class="bg_dim" style="display: none;"></div>
	
</div>