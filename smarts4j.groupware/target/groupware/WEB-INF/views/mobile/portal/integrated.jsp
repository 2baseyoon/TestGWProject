<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="portal_integrated_page" data-close-btn="none">
	
	<header data-role="header" id="portal_integrated_header">
		<div class="sub_header">
	        <div class="l_header">
				<a href="javascript:mobile_comm_back();" class="topH_close" style="display: none;"><span class="Hicon">닫기</span></a>
				<div class="menu_link gnb">
					<a id="portal_integrated_title" href="#" class="pg_tit"><spring:message code="Cache.lbl_portal_IntegratedNotify"/></a> <!-- 통합알림 -->
				</div>
			</div>
			<div class="utill">
				<a href="javascript: mobile_portal_deleteInteratedAlarm();" class="topH_delete"><span class="Hicon">삭제</span></a>
				<a href="javascript: mobile_portal_clickrefresh();" class="topH_reload"><span class="Hicon">새로고침</span></a>
			</div>
		</div>
	</header>

	<div data-role="content" class="cont_wrap" id="portal_integrated_content">
		<div class="total_notice total_n">
			<ul id="portal_integrated_list">
			</ul>
		</div>
	</div>
	
	<div class="bg_dim" style="display: none;"></div>
	
</div>
