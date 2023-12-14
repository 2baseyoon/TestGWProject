<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="board_viewer_page">

	<header id="board_viewer_header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript: mobile_comm_back();" class="topH_close"><span class="Hicon">닫기</span></a>
				<div class="menu_link"><a href="#" class="pg_tit"><spring:message code='Cache.btn_Viewer' /> <spring:message code='Cache.btn_List' /></a></div> <!-- 조회자 목록 -->
			</div>
		</div>
	</header>
		
	<div data-role="content" class="cont_wrap" id="board_viewerlist_content">
		<div style="text-align:right; height: 50px; border-bottom: 1px solid #b5b5b5;">
			<span id="board_viewer_count" class="ico_hits" style="height: 100%; line-height: 50px; padding-right:10px;"></span>
		</div>
		<div class="g_list">
			<ul id="board_viewer_list"  class="org_list">
			</ul>
		</div>
		<div id="board_viewer_more" class="btn_list_more" style="display: none;">
			<a href="javascript: mobile_board_nextlist('viewerlist');"><span><spring:message code='Cache.lbl_MoreView' /></span></a> <!-- 더보기 -->
		</div>
	</div>
		
</div>
