<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<!-- 템플릿 선택 -->
<div data-role="dialog" id="collab_templateToProject" adata='view'>
	<header>
		<div class="sub_header">
			<div class="l_header">
				<a id="collab_templateToProject_btnClose" class="topH_close"><span class="Hicon"><spring:message code='Cache.btn_Close'/></span></a><!-- 닫기 -->
				<div class="menu_link gnb">
				<span class="topH_tit"><spring:message code='Cache.lbl_AddProject'/></span><!-- 프로젝트추가 -->
				</div>
			</div>
			<div class="utill">
				<a class="topH_save" id="collab_templateToProject_btnSave"><span class="Hicon">등록</span></a>
			</div>
		</div>
	</header>	
	
	<div class="cont_wrap">
		<ul class="write_table">
			<li>
				<div class="div_th"><spring:message code='Cache.lbl_templateName'/></div><!-- 템플릿명 -->
				<div class="div_td">
					<span id="collab_templateToProject_tmplName"></span>
				</div>
			</li>
			<li>
				<div class="div_th"><spring:message code='Cache.ACC_lbl_projectName'/></div><!-- 프로젝트명 -->
				<div class="div_td">
					<input type="text" id="collab_templateToProject_prjName" value="" class="w100">
				</div>
			</li>
			<li>
				<div class="div_th"><spring:message code='Cache.lbl_Period'/></div><!-- 기간 -->
				<div class="div_td" id="collab_templateToProject_period">
					<input type="text" name="startDate" class="input_date" readonly="true"><span>-</span><input type="text" name="endDate" class="input_date" readonly="true">
				</div>
			</li>
			<li>
				<div class="div_th"><spring:message code='Cache.lbl_State'/></div><!-- 상태 -->
				<div class="div_td">
					<div class="div_chk" id="collab_templateToProject_taskStatus">
						<label for="chk1"><span class="s_check"></span><spring:message code='Cache.lbl_Ready'/></label><input type="checkbox" value="W" id="chk1"><!-- 대기 -->
						<label for="chk2"><span class="s_check"></span><spring:message code='Cache.lbl_Progress'/></label><input type="checkbox" value="P" id="chk2"><!-- 진행 -->
						<label for="chk3"><span class="s_check"></span><spring:message code='Cache.lbl_Hold'/></label><input type="checkbox" value="H" id="chk3"><!-- 보류 -->
						<label for="chk4"><span class="s_check"></span><spring:message code='Cache.lbl_Completed'/></label><input type="checkbox" value="C" id="chk4"><!-- 완료 -->
					</div>
				</div>
			</li>
		</ul>
	</div>
</div>