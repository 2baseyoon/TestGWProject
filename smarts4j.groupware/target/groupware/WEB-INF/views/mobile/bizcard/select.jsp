<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="bizcard_select_page" data-close-btn="none">

	<header data-role="header" id="bizcard_select_header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript: mobile_comm_back();" class="btn_back"><span><!-- 이전페이지로 이동 --></span></a>
				<div class="menu_link gnb">
					<a href="#" class="pg_tit"><spring:message code='Cache.lbl_SelectGroup2' /></a> <!-- 그룹 선택 -->
				</div>
			</div>
			<div class="utill">
	          <a href="javascript: mobile_bizcard_saveGroupSelected();" class="btn_txt"><spring:message code='Cache.btn_Select' /></a> <!-- 선택 -->
	        </div>
		</div>
	</header>

	<div data-role="content" class="cont_wrap" id="bizcard_select_content">
		<div class="sch_select">
			<ul id="bizcard_select_checklist" class="select_list">
				<li>
					<ul id="bizcard_select_checklisttotal">
						<li class="all_chk chk_item">
							<a href="javascript: mobile_bizcard_selectGroupAction();"><span class="rd_chk"></span><spring:message code='Cache.lbl_selectall' /></label></a> <!-- 전체선택 -->
						</li>
					</ul>
				</li>
				<li id="bizcard_select_checklistperson" style="display: none;">
				</li>
				<li id="bizcard_select_checklistdept" style="display: none;">
				</li>
				<li id="bizcard_select_checklistunit" style="display: none;">
				</li>
				<li id="bizcard_select_checklistcompany" style="display: none;">
				</li>
			</ul>
		</div>
	</div>
	
</div>