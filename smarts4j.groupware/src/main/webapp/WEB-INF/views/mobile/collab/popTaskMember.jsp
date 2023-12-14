<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="${pageID}">
	<header id="task_sharedperson_header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript: mobile_comm_back();" class="topH_close"><span class="Hicon">닫기</span></a>
				<div class="menu_link">
					<a href="#" class="pg_tit" id="task_sharedperson_title"><spring:message code='Cache.lbl_task_performer' /> <spring:message code='Cache.lbl_Select' /></a> <!-- 수행자 선택 -->
				</div><!-- TODO: 다국어처리 -->
			</div>
			<div class="utill">
				<a class="topH_save" id="addTaskUser" ><span class="Hicon"><spring:message code='Cache.lbl_Select' /></span></a> <!-- 선택 -->
			</div>
		</div>
		<div class="ly_search ly_change" id="task_div_search">
			<a href="javascript: mobile_comm_closesearch(); mobile_comm_cleansearch(); mobile_task_clickSharedPersonSearch();" class="topH_back"><span class="Hicon">닫기</span></a>
			<input type="text" id="task_search_shared" name="" value="" placeholder="<spring:message code='Cache.btn_search' />" onkeypress="if (event.keyCode==13){ mobile_task_clickSharedPersonSearch(); return false;}" onkeyup="mobile_comm_searchinputui('task_search_shared');" /> <!-- 검색 -->
			<a id="task_search_shared_btn" href="javascript: mobile_task_clickSharedPersonSearch();" class="topH_search" style="display: none;"></a>
			<a href="javascript: mobile_comm_cleansearch(); mobile_comm_searchinputui('task_search_shared');" class="topH_del"></a>
		</div>
	</header>
	
	<div data-role="content" class="cont_wrap">
		<ul id="collab_member_list" class="org_list select"></ul>		
	</div>
</div>
