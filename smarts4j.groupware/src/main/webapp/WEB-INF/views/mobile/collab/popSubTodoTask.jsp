<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div id="collab_add_subTask" data-role="page">
  <div class="card_list_popup collabo_pop" style="width:320px; height:406px;">
  	<div class="card_list_popup_cont">
  		<div class="card_list_title">
        	<strong class="tit"><spring:message code='Cache.lbl_TaskRegist'/></strong><!-- 업무 등록 -->
    	</div>
  	<div class="pop_box pop_task">
		<ul class="pop_table mb0">
			<li>
				<div class="div_th"><spring:message code='Cache.lbl_TaskName'/></div><!-- 업무명 -->
		        <div class="div_td"><div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset"><input type="text" id="taskName" class="w100"></div></div>
			</li>
			<li>
				<div class="div_th"><spring:message code='Cache.lbl_Period'/></div><!-- 기간 -->
				<div class="div_td">
		          <div class="dateSel type02" id="collab_subTask_period">
					  <div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset"><input type="text" id="startDate" class="input_date" autocomplete="off"></div><span>-</span><div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset"><input type="text" id="endDate" class="input_date" kind="twindate" autocomplete="off"></div>
		          </div>
				</div>
			</li>
	      	<li class="colspan">
		        <div class="div_th"><spring:message code='Cache.lbl_task_performer'/></div><!-- 수행자 -->
		        <div class="div_td">
		        	<div id="member"></div>
		        	<a href="#" class="g_btn04 ui-link" id="addMember">선택</a>
		        </div>				
			</li>
		</ul>
	</div>
		<!-- 버튼영역 -->
        <div class="mobile_popup_btn">
    		<a href="#" class="g_btn03 ui-link" id="saveTodo"><spring:message code='Cache.btn_save'/></a><!-- 저장 -->
    		<a href="#" class="g_btn04 ui-link" id="closeTodo"><spring:message code='Cache.btn_Close'/></a><!-- 닫기 -->
    	</div>
  	</div>
  </div>
</div>
