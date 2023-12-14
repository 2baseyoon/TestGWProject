<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="egovframework.baseframework.util.SessionHelper" %>

<div id="addTodo" class="mobile_popup_wrap" style="display:block;">
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
		          <div class="dateSel type02">
					  <div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset"><input type="text" id="startDate" class="input_date"></div><span>-</span><div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset"><input type="text" id="endDate" class="input_date" kind="twindate"></div>
		          </div>
				</div>
			</li>
			<li>
				<div class="div_th"><spring:message code='Cache.lbl_State'/></div><!-- 상태 -->
				<div class="div_td">
		          <div class="div_chk" id="taskStatus">
		            <div class="ui-checkbox active"><label for="chk1" class="ui-btn ui-corner-all ui-btn-inherit ui-btn-icon-left ui-checkbox-off"><spring:message code='Cache.lbl_Ready'/></label><input type="checkbox" value="W" id="chk1"></div><!-- 대기 -->
		            
		            <div class="ui-checkbox"><label for="chk2" class="ui-btn ui-corner-all ui-btn-inherit ui-btn-icon-left ui-checkbox-off"><spring:message code='Cache.lbl_Progress'/></label><input type="checkbox" value="P" id="chk2"></div><!-- 진행 -->
		            
		            <div class="ui-checkbox"><label for="chk3" class="ui-btn ui-corner-all ui-btn-inherit ui-btn-icon-left ui-checkbox-off"><spring:message code='Cache.lbl_Hold'/></label><input type="checkbox" value="H" id="chk3"></div><!-- 보류 -->
		            
		            <div class="ui-checkbox"><label for="chk4" class="ui-btn ui-corner-all ui-btn-inherit ui-btn-icon-left ui-checkbox-off"><spring:message code='Cache.lbl_Completed'/></label><input type="checkbox" value="C" id="chk4"></div><!-- 완료 -->                    
		          </div>
				</div>
			</li>
	      	<li class="colspan">
		        <div class="div_th"><spring:message code='Cache.lbl_TFProgressing'/></div><!-- 진행률 -->
		        <div class="div_td"><div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset"><input type="text" id="progRate" class="w100"></div></div>
				<div class="div_th wd"><spring:message code='Cache.lbl_Categories'/></div><!-- 범주 -->
				<div class="div_td">
					<div class="cusSelect02" id="label">
						<input type="txt" readonly="" class="selectValue">
						<span class="sleOpTitle"><span class="urgent"></span> <spring:message code='Cache.lbl_Urgency'/></span><!-- 긴급 -->
						<ul class="selectOpList">
							<li data-selvalue="E"><span class="urgent"></span> <spring:message code='Cache.lbl_Urgency'/></li><!-- 긴급 -->
							<li data-selvalue="I"><span class="important"></span> <spring:message code='Cache.lbl_Important'/></li><!-- 중요 -->
						</ul>
					</div>
				</div>
			</li>			
			<li>
				<div class="div_th"><spring:message code='Cache.lbl_Description'/></div><!-- 설명 -->
				<div class="div_td">
					<textarea id="remark" cols="30" rows="10" class="ui-input-text ui-shadow-inset ui-body-inherit ui-corner-all ui-textinput-autogrow" style="height: 44px;"></textarea>
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
