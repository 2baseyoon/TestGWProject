<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<!-- <div id="collab_projectPop" class="mobile_popup_wrap" style="display: block;"> -->
<div data-role="dialog" id="collab_projectPop" adata='view'>
	<header>
		<div class="sub_header">
			<div class="l_header">
				<a id="collab_projectPop_btnClose" class="topH_close"><span class="Hicon"><spring:message code='Cache.btn_Close'/></span></a><!-- 닫기 -->
				<div class="menu_link gnb">
				<span class="topH_tit" id="collab_projectPop_title"><spring:message code='Cache.lbl_ProjectRegist'/></span><!-- 프로젝트 등록 -->
				<!-- id="collab_projectPop_btnSave" -->
				</div>
			</div>
			<div class="utill">
				<a class="topH_save" id="collab_projectPop_btnSave"><span class="Hicon">등록</span></a>
			</div>
		</div>
	</header>
	<div class="cont_wrap">
		<ul class="write_table">
			<li>
				<div class="div_th"><spring:message code='Cache.lbl_TFName'/></div><!-- 프로젝트명 -->
				<div class="div_td">
					<input type="text" id="collab_projectPop_prjName" value="" class="w100">
				</div>
			</li>
			<li>
				<div class="div_th"><spring:message code='Cache.lbl_charge'/></div><!-- 담당자 -->
				<div class="div_td">
					<div class="org_T" id="collab_projectPop_member_container">
						<div class="org_T_l">
							<div class="org_list_box">
								<input id="collab_projectPop_memberInput" type="hidden">
							</div>
						</div>
						<div class="org_T_r orgBtn"><a class="g_btn05"><spring:message code='Cache.lbl_DeptOrgMap'/></a></div><!-- 조직도 -->
					</div>
				</div>
			</li>
			<li>
				<div class="div_th"><spring:message code='Cache.lbl_Period'/></div><!-- 기간 -->
				<div class="div_td">
					<div class="dateSel type02" id="collab_projectPop_period">
						<input type="text" name="startDate" class="input_date" readonly="true"><span>-</span><input type="text" name="endDate" class="input_date" readonly="true">
					</div>
				</div>
			</li>
			<li>
				<div class="div_th"><spring:message code='Cache.lbl_State'/></div><!-- 상태 -->
				<div class="div_td">
					<div class="div_chk" id="collab_projectPop_taskStatus">
						<label for="chk1"><span class="s_check"></span><spring:message code='Cache.lbl_Ready'/></label><input type="checkbox" value="W" id="chk1"><!-- 대기 -->
						<label for="chk2"><span class="s_check"></span><spring:message code='Cache.lbl_Progress'/></label><input type="checkbox" value="P" id="chk2"><!-- 진행 -->
						<label for="chk3"><span class="s_check"></span><spring:message code='Cache.lbl_Hold'/></label><input type="checkbox" value="H" id="chk3"><!-- 보류 -->
						<label for="chk4"><span class="s_check"></span><spring:message code='Cache.lbl_Completed'/></label><input type="checkbox" value="C" id="chk4"><!-- 완료 -->
					</div>
				</div>
			</li>
			<li>
				<div class="div_th"><spring:message code='Cache.lbl_admin'/></div>
				<div class="div_td">
					<div class="org_T" id="collab_projectPop_manager_container">
						<div class="org_T_l">
							<div class="org_list_box">
								<input id="collab_projectPop_mangerInput" type="hidden">
							</div>
						</div>
						<div class="org_T_r orgBtn"><a class="g_btn05"><spring:message code='Cache.lbl_DeptOrgMap'/></a></div><!-- 조직도 -->
					</div>
				</div>
			</li>
			<li class="colspan">
				<div class="div_th"><spring:message code='Cache.lbl_TFProgressing'/></div><!-- 진행률 -->
				<div class="div_td"><div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset"><input type="text" id="collab_projectPop_progRate" class="w100"></div></div>
			</li>
			<li>
				<div class="div_th"><spring:message code='Cache.lbl_Description'/></div><!-- 설명 -->
				<div class="div_td">
					<textarea id="collab_projectPop_remark" cols="30" rows="10"></textarea>
				</div>
			</li>
			<li>
				<div class="div_th"><spring:message code='Cache.lbl_Color'/></div><!-- 색상 -->
				<div class="div_td">
					<!-- 기존 팔레트 사용 : PC일정관리-테마일정관리-추가 팝업 참고 -->
					<div id="collab_projectPop_colorPicker">
						<div class="palette-color-picker-button" data-target="colorPicker"></div>	<!-- style="background: rgb(74, 134, 232);" -->
					</div>
				</div>
			</li>
		</ul>
		<div class="write_box02" style="display:none">
			<div class="pop_titBox">
				<strong class="pop_title_s"><spring:message code='Cache.btn_ExtendedField'/></strong><!-- 확장필드 -->
				<div class="control_btn">
					<a id="collab_projectPop_btnExDel" class="btn_minus"><spring:message code='Cache.btn_delete'/></a><!-- 삭제 -->
					<a id="collab_projectPop_btnExAdd" class="btn_plus"><spring:message code='Cache.btn_Add'/></a><!-- 추가 -->
				</div>
			</div>
			<!-- 테이블 영역 -->
			<table class="collabo_table" id="collab_projectPop_exField">
				<caption><spring:message code='Cache.btn_ExtendedField'/></caption><!-- 확장필드 -->
				<colgroup>
					<col style="width:10%;" />
					<col style="width:45%;" />
					<col style="width:45%;" />
				</colgroup>
				<thead>
					<tr>
						<th scope="col"><label for="allChk"><span class="s_check"></span></label><input type="checkbox" id="allChk"></th>
						<th scope="col"><spring:message code='Cache.lbl_ItemName'/></th><!-- 항목명 -->
						<th scope="col"><spring:message code='Cache.lbl_Contents'/></th><!-- 내용 -->
					</tr>
				</thead>
				<tbody>
				</tbody>
			</table>
		</div>
	</div>
</div>