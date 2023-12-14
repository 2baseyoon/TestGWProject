<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="resource_select_page" data-close-btn="none">

	<header data-role="header" id="resource_select_header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript:mobile_comm_back();" class="topH_close"><span><!-- 닫기 --></span></a>
				<div class="menu_link gnb">
					<a id="resource_select_title" class="pg_tit"><spring:message code='Cache.lbl_resource_selectRes' /></a> <!-- 자원선택 -->
				</div>
			</div>
			<div class="utill">
				<a href="javascript: mobile_select_saveSelectedResource();" class="topH_save"><span class="Hicon">선택</span></a> <!-- 선택 -->
			</div>
		</div>
	</header>

	<div data-role="content" class="cont_wrap" id="resource_select_content">
		<div class="sch_select">
			<select id="resource_select_placeOfBusiness" class="full sel_type" onchange="javascript: mobile_resource_changePlaceOfBusiness();"></select>
			<ul id="resource_select_resourceList" class="select_list">
			</ul>
		</div>
	</div>
	
</div>