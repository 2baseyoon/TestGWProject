<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="survey_result_page" data-close-btn="none">
	<header data-role="header" id="survey_list_header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript:mobile_comm_back();" class="topH_close"><span><!-- 닫기 --></span></a>
				<div class="menu_link">
					<a href="#" class="pg_tit"><spring:message code='Cache.btn_Viewresults' /></a><!-- 결과보기 -->
				</div>
			</div>
			<div class="utill">
				<div class="dropMenu">
            		<a href="#" class="topH_exmenu ui-link" onclick="javascript: mobile_survey_showORhide(this);"><span class="Hicon">확장메뉴</span></a>
					<div class="exmenu_layer">
						<ul class="exmenu_list">
							<li><a id="survey_result_target_respondent" href="#" onclick="javascript: mobile_survey_view_target('Respondent');" class="btn"><spring:message code='Cache.lbl_polltarget' /> <spring:message code='Cache.lbl_view' /></a></li> <!-- 설문대상 보기 -->
							<li><a id="survey_result_target_resultview" href="#" onclick="javascript: mobile_survey_view_target('ResultView');" class="btn"><spring:message code='Cache.lbl_title_surveyResult_01' /></a></li> <!-- 결과공개대상 보기 -->
						</ul>
					</div>
        		</div>
			</div>
		</div>
	</header>
	<div class="cont_wrap">
      	<div class="survey_title">
      		<a class="survey_title_btn" onclick="javascript: mobile_survey_showContSetting();"></a>
      		<h2 id="survey_result_title" class="tit"></h2> <!-- 설문 제목  -->
      		<a id="survey_result_period" class="btn_date"></a> <!-- 설문 기간  -->
      		<p id="survey_result_description" class="s_txt"></p> <!-- 설문 설명 -->
      	</div>
      	
      	<!-- 첨부 정보 -->
		<div id="survey_result_attach"></div>
		
		<!-- 설문 본문  -->
		<div class="survey_cont" id="survey_result_body"></div>
	</div>
</div>
