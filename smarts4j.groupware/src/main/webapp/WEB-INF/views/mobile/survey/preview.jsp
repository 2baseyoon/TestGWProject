<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="survey_preview_page" data-close-btn="none">
	<header data-role="header" id="survey_list_header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript:mobile_comm_back();" class="topH_close"><span><!-- 닫기 --></span></a>
				<div class="menu_link">
					<a href="#" class="pg_tit"><spring:message code='Cache.lbl_preview' /></a><!-- 미리보기 -->
				</div>
			</div>
			<div class="utill" style="display: none;">
				<div class="dropMenu">
            		<a href="#" class="btn_exmenu" onclick="javascript: mobile_survey_showORhide(this);"><span><spring:message code='Cache.btn_extmenu' /></span></a> <!-- 확장메뉴 -->
					<div class="exmenu_layer">
						<!-- <strong class="blind">본문 폰트 크기 조정</strong>
						<div class="font_box font_box_s">
							<a href="#" class="small dis"><span class="sim">본문 폰트 크기 작게 보기</span></a>
							<a href="#" class="big"><span class="sim">본문 폰트 크기 크게 보기</span></a>
							<span class="font_box_size font_zoom1">가</span>
						</div> -->
						<ul class="exmenu_list">
							<li><a id="survey_preview_target_respondent" href="#" class="btn" style="display: none;"><spring:message code='Cache.lbl_polltarget' /> <spring:message code='Cache.lbl_view' /></a></li> <!-- 설문대상 보기 -->
							<li><a id="survey_preview_target_resultpreview" href="#" class="btn" style="display: none;"><spring:message code='Cache.lbl_title_surveyResult_01' /></a></li> <!-- 결과공개대상 보기 -->
						</ul>
					</div>
        		</div>
			</div>
		</div>
	</header>
	<div class="cont_wrap">
      	<div class="survey_title">
      		<a class="survey_title_btn" onclick="javascript: mobile_survey_showContSetting();"></a>
      		<h2 id="survey_preview_title" class="tit"></h2> <!-- 설문 제목  -->
      		<a id="survey_preview_period" class="btn_date"></a> <!-- 설문 기간  -->
      		<p id="survey_preview_description" class="s_txt"></p> <!-- 설문 설명 -->
      	</div>
      	
      	<!-- 첨부 정보 -->
		<div id="survey_preview_attach"></div>
		
      	<div id="survey_view_preview_btn" class="survey_prev_btn_wrap">
 			<div class="survey_prev_btn">
				<a href="javascript: mobile_survey_view_getQuestionData('prev');" class="prev"><span></span></a>
				<p id="survey_view_preview_pageCnt" class="tx"><span class="pg">1</span>/1</p>
  				<a href="javascript: mobile_survey_view_getQuestionData('next');" class="next"><span></span></a>
			</div>
		</div>
		
		<!-- 설문 본문  -->
		<div class="survey_cont" id="survey_preview_body"></div>
		
		<div class="fixed_btm_wrap">
            <div class="survey_btn align">
				<a id="survey_view_preview_approvebtn" href="#" class="approval"><span class="tx"><spring:message code='Cache.lbl_Approval' /></span></a> <!-- 승인 -->
				<a id="survey_view_preview_cancelbtn" href="#" class="cancel"><span class="tx"><spring:message code='Cache.lbl_Deny' /></span></a> <!-- 거부 -->
			</div>
         </div>
	</div>
</div>
