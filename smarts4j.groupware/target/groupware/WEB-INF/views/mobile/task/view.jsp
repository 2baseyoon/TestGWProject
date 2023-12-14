<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<form id="formData" method="post" enctype="multipart/form-data">

	<div data-role="page" id="task_view_page" adata='view'>

		<header id="task_view_header">
			<div class="sub_header">
				<div class="l_header">
					<a href="javascript: mobile_comm_back();" class="topH_close"><span class="Hicon">닫기</span></a>
					<div class="menu_link"><a id="task_view_mode" href="#" class="pg_tit"><spring:message code='Cache.lbl_task_task' /> <spring:message code='Cache.lbl_DetailView' /></a></div><!-- 업무 상세보기 -->
				</div>
				<div class="utill">
					<div class="dropMenu" style="display: none;">
						<a id="task_list_btnAdd" href="#" class="topH_exmenu" onclick="javascript: mobile_task_showORhide(this);"><span class="Hicon">확장메뉴</span></a>
						<div class="exmenu_layer">
							<ul id="task_view_ulBtnArea" class="exmenu_list">
							</ul>
						</div>
					</div>
				</div>
			</div>
		</header>
	
		<div data-role="" class="cont_wrap" id="task_view_content">
			<div class="task_loc">
				<ul class="task_loc_list">
				</ul>
			</div>
			<div class="task_view">
				<div class="task_title">
					<h2 id="task_view_subject" class="tit"></h2>
					<p class="info"><span id="task_view_register" class="name"></span><span id="task_view_registDate" class="date"></span></p>
				</div>
				<div class="task_date">
					<dl class="task_date_dl">
						<dt><spring:message code='Cache.lbl_Schedule' /></dt><!-- 일정 -->
						<dd id="task_view_date"></dd>
					</dl>
					<dl class="task_date_dl">
						<dt><spring:message code='Cache.lbl_State' /></dt> <!-- 상태 -->
						<dd id="task_view_progress"></dd>
					</dl>
					<dl id="task_view_personPerformer" class="task_date_dl">
						<dt><spring:message code='Cache.lbl_task_performer' /></dt> <!-- 수행자 -->
						<dd class="name_list_wrap">
							<!-- <a href="#" class="txt_email">abc@naver.com</a> -->
						</dd>
					</dl>
				</div>
				
				<!-- 첨부 정보 -->
				<div id="task_view_attach"></div>
				
				<div class="task_txt"  id="task_view_description">
				</div>
				
				<!-- 좋아요 -->
				<div id="task_view_like" class="end_like_area"></div>
				
				<!-- 댓글 -->
				<div covi-mo-comment></div>
				
			</div>
		</div>
		
	</div>
	
</form>