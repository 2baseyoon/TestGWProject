<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="task_write_page">

	<header id="task_write_header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript: mobile_comm_back();" class="topH_close"><span class="Hicon">닫기</span></a>
				<div class="menu_link"><a id="task_write_mode" href="#" class="pg_tit"><spring:message code='Cache.btnWrite' /></a></div>
			</div>
			<div class="utill">
				<a id="task_write_save" href="javascript: mobile_task_save();" class="topH_save" style="display: none;"><span class="Hicon">등록</span></a>
			</div>
		</div>
	</header>

	<div data-role="content" class="cont_wrap" id="task_write_content">
		<div class="task_loc">
			<ul class="task_loc_list">
			</ul>
		</div>
		<div id="task_write_divFolder" class="write_wrap">
			<select style="display: none;" id="task_write_type" name="" class="full sel_type" onchange="javascript: mobile_task_changeWriteType();">
			 	<option value="F"><spring:message code='Cache.lbl_Folder' /></option> <!-- 폴더 -->
			 	<option value="T"><spring:message code='Cache.lbl_task_task' /></option> <!-- 업무 -->
			</select>
	        <div class="title_wrap">
		          <input id="task_write_subject" type="text"  voiceInputType="change" voiceStyle="" voiceCallBack=""  class="full mobileViceInputCtrl" placeholder="<spring:message code='Cache.msg_apv_ValidationBizDocName' />"> <!-- 업무함 명칭을 입력하세요 -->
	        </div>
			<div class="dates_wrap">
				<div class="dates start">
					<div>
						<input type="checkbox" name="task_write_chkAllDay" id="task_write_chkAllDay" onclick="javascript: mobile_task_chkAllDay();"><label for="task_write_chkAllDay"><spring:message code='Cache.lbl_AllDay' /></label>
					</div>
					<p>
						<input type="text" id="task_write_startdate" class="dates_date input_date" onchange="mobile_task_chkDateValidation('SD');">
					</p>
					<p>
						<select id="task_write_starttime" class="dates_time input_time" onchange="mobile_task_chkDateValidation('ST');"></select>
					</p>
				</div>
				<div class="dates end">
					<div class="emptyspace"></div>
					<p>
						<input id="task_write_enddate" type="text" class="dates_date input_date" onchange="mobile_task_chkDateValidation('ED');">
					</p>
					<p>
						<select id="task_write_endtime" class="dates_time input_time" onchange="mobile_task_chkDateValidation('ET');"></select>
					</p>
				</div>
				<input type="hidden" id="task_write_hidstartdate">
				<input type="hidden" id="task_write_hidstarttime">
				<input type="hidden" id="task_write_hidenddate">
				<input type="hidden" id="task_write_hidendtime">
			</div>
			<div class="editor_wrap" style="height:120px;">
				<textarea id="task_write_descriptionTask" name="task_write_description" voiceInputType="append" voiceStyle="" voiceCallBack="" class="txareas full mobileViceInputCtrl" rows="8" cols="80" placeholder="<spring:message code='Cache.msg_survey_enterDesc' />"></textarea> <!-- 설명을 입력하세요 -->
			</div>
			<div class="status_wrap active">
				<select id="task_write_progress" name="" class="full sel_type">
				 	<option value="Process"><spring:message code='Cache.lbl_Progressing' /></option> <!-- 진행중 -->
				 	<option value="Complete"><spring:message code='Cache.lbl_Completed' /></option> <!-- 완료 -->
				 	<option value="Waiting"><spring:message code='Cache.lbl_inactive' /></option> <!-- 대기 -->
				</select>
			</div>
			<!-- 2020.01.03 진행률 추가 수정필요 -->
			<div class="impts_wrap">
			<input id="task_write_progressPercent" style="width:20%" placeholder="<spring:message code='Cache.lbl_ProgressRate' />"><p class="tx">%</p>
			</div>
			<div class="editor_wrap" style="height:120px;">
				<textarea id="task_write_descriptionFolder" name="task_write_description" voiceInputType="append" voiceStyle="" voiceCallBack="" class="full" cols="80" placeholder="<spring:message code='Cache.msg_survey_enterDesc' />"></textarea> <!-- 설명을 입력하세요 -->
			</div>			
			<div covi-mo-attachupload system="Task"></div>
			<div id="task_write_personFolder" class="joins_wrap" style="height: auto;">
				<p class="tx" id="taskCoowerTitle" style="margin-left:0px;width:100px;"><spring:message code='Cache.lbl_Coowner' /></p>
				<div class="joins_a" id="taskCoowerArea" style="display:none;"></div>
				<a id="task_write_btnCoowner" onclick="javascript: mobile_task_openOrg('Folder');" class="btn_add_n">추가</a>
			</div>
			<div id="task_write_personTask" class="joins_wrap" style='height:auto;display:none;'>
				<p class="tx" id="taskperformerTitle" style="margin-left:0px;width:100px;"><spring:message code='Cache.lbl_task_performer' /></p>
				<div class="joins_a" id="taskperformerArea" style="display:none;"></div>
				<input name="task_write_emailtxt"  type="text" name="" value="" placeholder="<spring:message code='Cache.msg_schedule_enterEmailTxt' />" style="display: none;"> <!-- 메일주소 입력 -->
				<a id="task_write_btnAddEmail" onclick="javascript: mobile_task_clickAddEmail(this);" class="btn_add_n" style="display: none;"><i class="add"></i><spring:message code='Cache.lbl_Email2' /></a> <!-- 이메일 -->
				<a id="task_write_btnAddOrg" onclick="javascript: mobile_task_openPersonFolderList();" class="btn_add_n"><i class="add"></i><spring:message code='Cache.lbl_Coowner' /></a> <!-- 공유자 -->
			</div>
		</div>
	</div>
	
</div>

