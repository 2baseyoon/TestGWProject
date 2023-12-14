<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<nav class="lnb">
	<h2 class="gnb_left_tit">
		<span class="gnb_tit" onclick="leftmenu_goToPageMain(); return false">설문</span>
	</h2>
	<ul id="lnb_con" class="lnb_list">
	</ul>
</nav>

<script type="text/javascript">
	var leftData = ${leftMenuData};
	var loadContent = '${loadContent}';
	
	function leftInif(){
		//left menu 그리는 부분
		var opt = {
				lang : "ko",
				isPartial : "true"
		};
		var surveyLeft = new CoviMenu(opt);
		
		if(leftData.length != 0){
			surveyLeft.render('#lnb_con', leftData, 'adminLeft');
			
			var $first = $('#lnb_con li').first().find('a');
			if ($("#content").html() == 0){
				$first.click();
			}
			else {
				$first.addClass("admin-menu-active");
			}
    	}
	}

	function leftmenu_goToPageMain(){
		CoviMenu_GetContent('/groupware/layout/survey_SurveyManage.do?CLSYS=survey&CLMD=admin&CLBIZ=Survey');	
	}

	leftInif();
</script>