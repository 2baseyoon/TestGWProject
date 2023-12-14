<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="schedule_select_page">

	<header data-role="header" id="schedule_select_header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript: mobile_comm_back();" class="btn_back"><span><!-- 이전페이지로 이동 --></span></a>
				<div class="menu_link gnb">
					<a href="#" class="pg_tit"><spring:message code='Cache.lbl_WP_ScheduleSetting' /></a> <!-- 일정선택 -->
				</div>
			</div>
			<div class="utill">
	          <a href="javascript: mobile_schedule_saveFolderSelected();" class="btn_txt"><spring:message code='Cache.btn_Select' /></a> <!-- 선택 -->
	        </div>
		</div>
	</header>

	<div data-role="content" class="cont_wrap" id="schedule_select_content">
		<div class="sch_select">
			<ul id="schedule_select_checklist" class="select_list">
				<li>
					<ul id="schedule_select_checklisttotal">
						<li class="all_chk chk_item">
							<a href="#"><span class="rd_chk"></span><label><spring:message code='Cache.lbl_selectall' /></label></a> <!-- 전체선택 -->
						</li>
					</ul>
				</li>
				<li>
					<ul id="schedule_select_checklistcommunity"></ul>
				</li>
				<li>
					<ul id="schedule_select_checklisttheme"></ul>
				</li>
			</ul>
		</div>
	</div>
</div>