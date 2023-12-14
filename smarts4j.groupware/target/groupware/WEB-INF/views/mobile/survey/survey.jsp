<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="survey_view_page" data-close-btn="none">
	<header data-role="header" id="survey_list_header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript:mobile_comm_back();" class="topH_close"><span><!-- 닫기 --></span></a>
				<div class="menu_link">
					<a href="#" class="pg_tit"><spring:message code='Cache.btn_participate' /></a><!-- 참여하기 -->
				</div>
			</div>
			<div class="utill">
				<div class="dropMenu" style="display: none;">
            		<a href="#" class="btn_exmenu" onclick="javascript: mobile_survey_showORhide(this);"><span><spring:message code='Cache.btn_extmenu' /></span></a> <!-- 확장메뉴 -->
					<div class="exmenu_layer">
						<!-- <strong class="blind">본문 폰트 크기 조정</strong>
						<div class="font_box font_box_s">
							<a href="#" class="small dis"><span class="sim">본문 폰트 크기 작게 보기</span></a>
							<a href="#" class="big"><span class="sim">본문 폰트 크기 크게 보기</span></a>
							<span class="font_box_size font_zoom1">가</span>
						</div> -->
						<ul class="exmenu_list">
							<li><a id="survey_view_target_respondent" href="#" onclick="javascript: mobile_survey_view_target('Respondent');" class="btn"><spring:message code='Cache.lbl_polltarget' /> <spring:message code='Cache.lbl_view' /></a></li> <!-- 설문대상 보기 -->
							<li><a id="survey_view_target_resultview" href="#" onclick="javascript: mobile_survey_view_target('ResultView');" class="btn"><spring:message code='Cache.lbl_title_surveyResult_01' /></a></li> <!-- 결과공개대상 보기 -->
						</ul>
					</div>
        		</div>
			</div>
		</div>
	</header>
	<div class="cont_wrap">
      	<div class="survey_title">
      		<a class="survey_title_btn" onclick="javascript: mobile_survey_showContSetting();"></a>
      		<h2 id="survey_view_title" class="tit"></h2> <!-- 설문 제목  -->
      		<a id="survey_view_period" class="btn_date"></a> <!-- 설문 기간  -->
      		<p id="survey_view_description" class="s_txt"></p> <!-- 설문 설명 -->
      	</div>
      	
      	<!-- 첨부 정보 -->
		<div id="survey_view_attach"></div>
      	
      	<!-- 설문 본문  -->
		<div class="survey_cont" id="survey_view_body"></div>
	</div>
</div>
