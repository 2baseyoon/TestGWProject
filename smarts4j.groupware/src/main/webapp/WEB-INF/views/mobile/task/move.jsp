<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<form id="formData" method="post" enctype="multipart/form-data">

	<div data-role="page" id="task_move_page">

		<header data-role="header" id="task_move_header">
			<div class="sub_header">
				<div class="l_header">
					<a href="javascript: mobile_comm_back();" class="btn_close"><span><!-- 이전페이지로 이동 --></span></a>
					<div class="menu_link"><a id="task_move_mode" href="#" class="pg_tit"><spring:message code='Cache.lbl_Move' /></a></div><!-- 이동 -->
				</div>
				<div class="utill">
					<a id="task_move_save" href="javascript: mobile_task_moveTarget();" class="btn_txt"><spring:message code='Cache.lbl_Confirm' /></a><!-- 확인 -->
				</div>
			</div>
		</header>
	
		<div data-role="" class="cont_wrap" id="task_move_content">
			<div class="task_loc">
				<ul class="task_loc_list">
					<li><p class="tx"><spring:message code='Cache.lbl_Person_Task' /></p></li> <!-- 내가 하는 일 -->
					<li><p class="tx">자바 그룹웨어</p></li>
					<li><span class="ico_folder"></span></li>
				</ul>
			</div>
			<div id="task_move_divFolder" class="move_wrap">
				<div class="menu_link gnb">
					<ul id="task_move_topmenu" class="h_tree_menu_wrap" >
						<li>
							<div class="h_tree_menu type2">
								<ul id="task_move_topmenuShare"  class="h_tree_menu_list">
									<li>
		 							</li>
	 							</ul>
 							</div>
						</li>
						<li>
							<div class="h_tree_menu type2">
								<ul id="task_move_topmenuPerson"  class="h_tree_menu_list">
									<li>
		 							</li>
	 							</ul>
 							</div>
						</li>
		            </ul>
				</div>
			</div>
		</div>
		
	</div>
	
</form>