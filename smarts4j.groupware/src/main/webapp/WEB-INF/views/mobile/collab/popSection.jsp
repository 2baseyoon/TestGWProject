<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<!-- 섹션추가 팝업 -->
<div id="collab_addSectionPop" class="mobile_popup_wrap" style="display:block;">
	<div class="card_list_popup collabo_pop" style="height:150px; top:calc(50%-75px);">
		<div class="card_list_popup_cont">
			<div class="card_list_title">
				<strong class="tit"><spring:message code='Cache.lbl_SectionTitleEnterMsg'/></strong><!-- 섹션 제목을 입력해 주세요 -->
			</div>
			<div class="card_list_cont">
				<input type="text" id="collab_sectionName" />
				<input type="hidden" id="collab_sectionSeq" />
			</div>
			<div class="mobile_popup_btn">
				<a class="g_btn03 ui-link btn_confirm"><spring:message code='Cache.btn_Confirm'/></a><!-- 확인 -->
				<a class="g_btn04 ui-link btn_close"><spring:message code='Cache.btn_Cancel'/></a><!-- 취소 -->
			</div>
		</div>
	</div>
</div>