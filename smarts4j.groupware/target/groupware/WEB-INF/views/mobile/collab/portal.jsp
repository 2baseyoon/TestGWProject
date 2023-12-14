<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="egovframework.baseframework.util.SessionHelper" %>

<div data-role="page" id="collab_portal_page" class="mob_rw">
	<header data-role="header" >
	      <div class="sub_header">
	        <div class="l_header">
	          
	          	<a href="javascript:mobile_comm_TopMenuClick('collab_leftmenu_tree');" class="topH_menu"><span><spring:message code='Cache.lbl_FullMenu'/></span></a> <!-- 전체메뉴 -->
				<div class="menu_link gnb">
		          	<span class="topH_tit"><spring:message code='Cache.lbl_Collab'/></span>
					<jsp:include page="/WEB-INF/views/mobile/collab/collabLeft.jsp"></jsp:include>
					<div class="left_bg_dim" onclick="mobile_comm_TopMenuClick('collab_list_topmenu',true);return false;" style="display: none;"></div>
				</div>
				
	        </div>
			<div class="utill">
				<div class="dropMenu" style="display: none;">
					<a href="#" class="topH_exmenu" onclick="javascript: mobile_task_showORhide(this);"><span class="Hicon"><spring:message code='Cache.btn_extmenu'/></span></a><!-- 확장메뉴 -->
					<div class="exmenu_layer">
						<ul id="attendance_view_ulBtnArea" class="exmenu_list"></ul>
					</div>
				</div>
			</div>
	      </div>
    </header>
    	
	<div data-role="content" class="cont_wrap" id="collab_portal_content">
		 <div class="Plist Pwork Pwork_state">
				<div class="Plist_title">
					<span class="">My Work</span>
				</div>
				<div class="Plist_cont">
			          <div class="Twork_area">
			            <div class="Twork_slider">
			              <div>
			                <div class="Twork_box Twork_box01">
			                  <div class="Twork_tit"><strong>Today's Work</strong></div>
			                  <div class="Twork_cont">
			                    <ul class="Twork_today">
			                      <li><a href="#"><span class="T_num">0</span><span class="T_text"><spring:message code='Cache.lbl_AssignedTasks'/></span></a></li><!-- 배정된업무 -->
			                      <li><a href="#"><span class="T_num">0</span><span class="T_text"><spring:message code='Cache.lbl_ClosingToday'/></span></a></li><!-- 오늘마감 -->
			                      <li><a href="#"><span class="T_num">0</span><span class="T_text"><spring:message code='Cache.lbl_delaywork'/></span></a></li><!-- 지연업무 -->
			                      <li><a href="#"><span class="T_num">0</span><span class="T_text"><spring:message code='Cache.lbl_EmergencyWork'/></span></a></li><!-- 긴급업무 -->
			                    </ul>
			                  </div>
			                </div>
			              </div>
			              <div>
			                <div class="Twork_box Twork_box02">
			                  <div class="Twork_tit"><strong>To do List</strong> <a href="#" class="btn_add"></a></div>
			                  <div class="Twork_cont">
			                    <ul class="Twork_todo">
			                    </ul>
			                  </div>
			                </div>
			              </div>
			              <div>
			                <div class="Twork_box Twork_box03">
			                  <div class="Twork_tit"><strong>My BookMark</strong></div>
			                  <div class="Twork_cont">
			                    <ul class="Twork_bookmark">
			                    </ul>
			                  </div>
			                </div>
			              </div>
			            </div>
				  </div>
			  </div>
      </div>
      <div class="Plist Pwork Pwork_project">
				<div class="Plist_title">
					<span class="">Team / Project</span>
			          <!-- 
			          <a href="#" class="column_btn"></a>
			          <div class="column_menu">
			           <a href="#"><spring:message code='Cache.lbl_Project'/></span></a>--><!-- 프로젝트 -->
			           <!-- <a href="#"><spring:message code='Cache.lbl_Teamwork'/></span></a>--><!-- 팀업무 -->
			           <!-- <a href="#"><spring:message code='Cache.lbl_all'/></span></a>--><!-- 전체 -->
			           <!-- 
			          </div>
			          <a href="#" class="column_add"></a>
			           -->
				</div>
        <!-- Team일 경우 bg01, project일 경우 bg02 -->
				<div class="Plist_cont">
			          <div class="Pwork_list">
			          </div>
			  </div>
      </div>
    </div>

	<div class="bg_dim" style="display: none;"></div>	
</div>
	
