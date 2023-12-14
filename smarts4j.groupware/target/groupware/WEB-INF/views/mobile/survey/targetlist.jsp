<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="survey_target_page" data-close-btn="none">
	<header data-role="header" id="survey_target_header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript:mobile_comm_back();" class="topH_close"><span><!-- 닫기 --></span></a>
				<div class="menu_link"><a href="#" class="pg_tit" id="survey_target_title"></a></div><!-- TODO: 다국어처리 -->
			</div>
		</div>
	</header>
	
	<div class="cont_wrap">
		<ul id="survey_target_list" class="survey_user_list">
		</ul>
		<div id="survey_target_more" class="btn_list_more" style="display: none;">
			<a href="javascript: mobile_survey_target_nextlist();"><span><spring:message code='Cache.lbl_MoreView' /></span></a> <!-- 더보기 -->
		</div>
	</div>
</div>