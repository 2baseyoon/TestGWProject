<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class="cLnbTop">
	<h2>Social</h2>
	<div><a class="btnType01 btnSurveyAdd" href="javascript:;" onclick="CoviMenu_GetContent('/groupware/layout/survey_SurveyWrite.do?CLSYS=survey&CLMD=user');return false;">Social 등록</a></div>
</div>

<script type="text/javascript">
	var leftData = ${leftMenuData};
	var loadContent = '${loadContent}';
	var domainId = '${domainId}';
	var isAdmin = '${isAdmin}';
	
	initLeft();
	
	function initLeft(){
		if(loadContent == 'true'){
			CoviMenu_GetContent('/groupware/layout/social_Home.do?CLSYS=social&CLMD=user&CLBIZ=Social');	
		}
	}
	
</script>

