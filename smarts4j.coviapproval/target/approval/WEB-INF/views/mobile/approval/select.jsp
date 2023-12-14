<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="approval_select_page">

	<header id="approval_select_header">
		<div class="sub_header">
			<div class="l_header">
				<!-- <a href="javascript: mobile_approval_closeDocClass();" class="btn_back"><span>이전페이지로 이동</span></a> -->
				<a href="javascript: mobile_approval_closeDocClass();" class="topH_close"><span class="Hicon">닫기</span></a>
				<div class="menu_link gnb">
					<a id="approval_select_title" class="pg_tit"><spring:message code='Cache.lbl_apv_docfoldername'/></a> <!-- 문서분류 -->
				</div>
			</div>
			<div class="utill">
				<a href="javascript: mobile_approval_saveSelectedDocClass();" class="topH_save"><span class="Hicon">등록</span></a> <!-- 선택 -->
			</div>
		</div>
	</header>

	<div data-role="content" class="tree_wrap cont_wrap" id="approval_select_content">
		<ul id="approval_select_docClassList" class="h_tree_menu_wrap">
		</ul>
	</div>
	
</div>