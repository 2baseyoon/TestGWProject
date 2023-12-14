<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="task_list_page" class="mob_rw">
	<header data-role="header" id="task_list_header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript:mobile_comm_TopMenuClick('task_list_topmenu');" class="topH_menu"><span>전체메뉴</span></a>
				<div class="menu_link gnb">
					<span id="task_list_title" href="javascript:void(0);" class="topH_tit"></span>					            
					<div class="cover_leftmenu" style="display:none;">
						<div class="LsubHeader">
							<span class="LsubTitle task"><spring:message code='Cache.lbl_TaskManage' /></span>
							<span class="LsubTitle_btn">
								<button onclick="mobile_comm_TopMenuClick('task_list_topmenu',true);return false;" type="button" class="btn_close"><i>닫기</i></button>
							</span>
					 	</div>
						<div class="tree_default" id="task_list_topmenu">
							<ul class="h_tree_menu_wrap">
								<li> 
									<ul class="h_tree_menu_list" id="task_list_topmenuShare">
										<li></li>
									</ul>
									<ul class="h_tree_menu_list" id="task_list_topmenuPerson">
										<li></li>
									</ul>
             					</li>
							</ul>
					 	</div> 
				 	</div>
					<div class="left_bg_dim" onclick="mobile_comm_TopMenuClick('task_list_topmenu',true);return false;" style="display: none;"></div>
				</div>
			</div>
			<div class="utill">
				<a href="javascript: mobile_comm_opensearch();" class="topH_search"><span class="Hicon"></span></a>				
				<a href="javascript: mobile_task_clickrefresh();" class="topH_reload"><span class="Hicon">새로고침</span></a>				
				<div class="dropMenu">
					<a id="task_list_btnAdd" href="#" onclick="javascript: mobile_task_showORhide(this);" class="topH_exmenu ui-link"><span class="Hicon">확장메뉴</span></a>
					<div class="exmenu_layer">
						<ul class="exmenu_list">
							<li><a href="javascript: mobile_task_clickwrite('F');" class="btn" style="display: true;"><spring:message code='Cache.lbl_AddFolder' /></a></li> <!-- 폴더 추가 -->
						</ul>
					</div>
				</div>								
			</div>
		</div>
		<div class="ly_search ly_change">
			<a href="javascript: mobile_comm_closesearch(); mobile_task_clickrefresh();" class="topH_back"><span><spring:message code='Cache.btn_Close' /></span></a> <!-- 닫기 -->
			<input type="text" id="mobile_search_input" name="" value=""  voiceInputType="callback" voiceStyle="margin-right:25px;" voiceCallBack="mobile_task_clicksearch"  class="mobileViceInputCtrl" placeholder="<spring:message code='Cache.msg_task_searchBy' />" onkeypress="if (event.keyCode==13){ mobile_task_clicksearch(); return false;}" onkeyup="mobile_comm_searchinputui('mobile_search_input');" /> <!-- 폴더 내 제목, 소유자로 검색 -->
			<a id="mobile_search_input_btn" href="javascript: mobile_task_clicksearch();" class="topH_search" style="display: none;"></a>
			<a href="javascript: mobile_comm_cleansearch(); mobile_comm_searchinputui('mobile_search_input');" class="topH_del"></a>		  
		</div>
	</header>
	<div data-role="content" class="cont_wrap" id="task_list_content">
		<div class="task_cont">
			<div class="task_loc">
				<a id="task_loc_top" href="javascript:void();" onclick="mobile_task_changeFolder();" class="webhard_loc_ico ui-link"></a>
				<ul class="task_loc_list"></ul>
			</div>
			<div class="task_list_wrap">
				<h3 class="tit" onclick="mobile_task_toggleList('folder');return false;"><span id="task_list_folderCnt" ><i class="bull"></i><spring:message code='Cache.lbl_Category_Folder' /></span></h3> <!-- 폴더 -->
				<ul id="task_list_folderlist" class="task_list folder"></ul>
				<h3 class="tit" onclick="mobile_task_toggleList('task');return false;"><span id="task_list_taskCnt"><i class="bull"></i><spring:message code='Cache.lbl_task_task' /></span></h3> <!-- 업무 -->
				<ul id="task_list_tasklist" class="task_list task"></ul>
				<div class="btn_list_more" style="display: none;">
					<a href="#"><span><spring:message code='Cache.lbl_MoreView' /></span></a> <!-- 더보기 -->
				</div>
			</div>
		</div>
	</div>
	<div id="task_list_btnAddTask" class="list_writeBTN">
      <a href="javascript: mobile_task_clickwrite('T');" class="ui-link"><span>작성</span></a>
    </div>
	<div class="bg_dim" style="display: none;"></div>	
</div>