<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="community_list_page" class="mob_rw">	
	
	<header data-role="header" id="community_list_header" class="header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript: mobile_comm_back();" class="topH_back" style="display:block;" id="aBtnBack"><span>이전페이지로 이동</span></a>
				<a href="javascript:mobile_comm_TopMenuClick('community_list_topmenu');" id="aTopMenu" class="topH_menu"><span>전체메뉴</span></a>
				<div class="menu_link gnb">
					<span id="community_list_title" href="javascript:void(0);" class="topH_tit"><spring:message code='Cache.BizSection_Community' /></span>
					<div class="cover_leftmenu" style="display:none;">
						<div class="LsubHeader">
							<span class="LsubTitle community"><spring:message code='Cache.BizSection_Community' /></span>
							<span class="LsubTitle_btn">
								<button onclick="mobile_comm_TopMenuClick('community_list_topmenu',true);return false;" type="button" class="btn_close"><i>닫기</i></button>
							</span>
						</div>
						<div class="tree_default" id="community_list_topmenu">
							<ul class="h_tree_menu_wrap">
								<li>									
									<ul id="community_list_treeCategory" class="h_tree_menu_list"></ul>		
								</li>
							</ul>													
					 	</div> 
					</div>
					<div class="left_bg_dim" onclick="mobile_comm_TopMenuClick('community_list_topmenu',true);return false;" style="display: none;"></div>
				</div>
			</div>								
			<div class="utill">								
				<a href="javascript: mobile_comm_opensearch();" class="topH_search"><span class="Hicon">검색</span></a>
				<a href="javascript: mobile_community_clickrefresh('list');" class="topH_reload"><span class="Hicon">새로고침</span></a>				
	        </div>		        	        		
		</div>					
		<div class="ly_search ly_change">						
			<a href="javascript: mobile_comm_closesearch(); mobile_community_clickrefresh('list');" class="topH_back"><span><spring:message code='Cache.BizSection_Community' /><spring:message code='Cache.btn_Close' /></span></a> <!-- 닫기 -->
			<input type="text" id="mobile_search_input"  voiceInputType="callback" voiceStyle="margin-right:25px;" voiceCallBack="mobile_community_clicksearch"  class="mobileViceInputCtrl"  name="" value="" placeholder="<spring:message code='Cache.msg_community_searchBy' />" onkeypress="if (event.keyCode==13){ mobile_community_clicksearch(); return false;}" onkeyup="mobile_comm_searchinputui('mobile_search_input');" /> <!-- 커뮤니티 이름, 운영자, 소개로 검색 -->
			<a id="mobile_search_input_btn" href="javascript: mobile_community_clicksearch();" class="topH_search" style="display: none;"></a>
			<a href="javascript: mobile_comm_cleansearch(); mobile_comm_searchinputui('mobile_search_input');" class="topH_del ui-link"></a>		  
		</div> 
	</header>
	<%--
	<header data-role="header" id="community_list_header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript: mobile_comm_back();" class="btn_back"><span><!-- 이전페이지로 이동 --></span></a>
				<div class="menu_link gnb">
					<a id="community_list_title" href="#" onclick="javascript: mobile_comm_TopMenuClick('community_list_title'); return false;" class="pg_tit"><!-- 폴더<i class="arr_menu"></i> --></a>
		            <ul id="community_list_topmenu" class="h_tree_menu_wrap">
						<li>
							<div class="h_tree_menu">
								<!-- 
								<ul class="h_tree_menu_list">
									<li>
										<a href="#" class="t_link"><span class="t_ico_open"></span>전사커뮤니티</a>
										<ul class="sub_list">
											<li>
												<a href="#" class="t_link"><span class="t_ico_board"></span>일반커뮤니티</a>
											</li>
											<li>
												<a href="#" class="t_link selected"><span class="t_ico_board"></span>그룹커뮤니티</a>
											</li>
										</ul>
									</li>
								</ul>
								 -->
								<ul id="community_list_treeCategory" class="h_tree_menu_list">
								</ul>
							</div>
						</li>
		            </ul>
				</div>
			</div>
			<div class="utill">
				<a href="javascript: mobile_comm_opensearch();" class="btn_search"><span><!-- 검색 --></span></a>
				<!-- <a href="javascript: mobile_community_clickrefresh('list');" class="btn_reload"><span>새로고침</span></a> -->
			</div>
		</div>
		<div class="ly_search">
			<a href="javascript: mobile_comm_closesearch(); mobile_community_clickrefresh('list');" class="btn_back"><span><spring:message code='Cache.btn_Close' /></span></a> <!-- 닫기 -->
			<input type="text" id="mobile_search_input" name="" value="" placeholder="<spring:message code='Cache.msg_community_searchBy' />" onkeypress="if (event.keyCode==13){ mobile_community_clicksearch(); return false;}"> <!-- 커뮤니티 이름, 운영자, 소개로 검색 -->
			<a href="javascript: mobile_comm_cleansearch();" class="del ui-link"></a>
		</div>
	</header>
	 --%>
	<div data-role="content" class="cont_wrap" id="community_list_content">
		<ul id="community_list_ulList" class="community_list">
		</ul>
		<div id="community_list_btnListMore" class="btn_list_more" style="display: none;">
			<a href="javascript: mobile_community_listNextlist();"><span><spring:message code='Cache.lbl_MoreView' /></span></a> <!-- 더보기 -->
		</div>
	</div>
	
	<div class="bg_dim" style="display: none;"></div>
	
</div>