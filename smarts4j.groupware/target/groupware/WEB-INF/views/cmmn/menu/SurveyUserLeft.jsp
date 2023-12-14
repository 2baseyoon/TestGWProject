<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<div class="cLnbTop">
	<h2><spring:message code='Cache.MN_108' /></h2><!-- 설문 -->
	<div><a class="btnType01 btnSurveyAdd" onclick="CoviMenu_GetContent('/groupware/layout/survey_SurveyWrite.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&reqType=create&surveyId=&communityId=0');return false;"><spring:message code='Cache.MN_110' /></a></div><!-- 설문등록 -->
</div>
<div class='cLnbMiddle mScrollV scrollVType01'>
	<ul id="leftmenu" class="contLnbMenu surveyMenu"></ul>
</div>


<script type="text/javascript">
	//# sourceURL=SurveyUserLeft.jsp
	
	var leftData = ${leftMenuData};
	var loadContent = '${loadContent}';
	
	initLeft();
	
	function initLeft(){
		
		// 스크롤
		coviCtrl.bindmScrollV($('.mScrollV'));
		
		var opt = {
    			lang : "ko",
    			isPartial : "true"
    	};
    	var coviMenu = new CoviMenu(opt);
    	
    	if(leftData.length != 0){
    		coviMenu.render('#leftmenu', leftData, 'userLeft');
    		setLeftMenuActive();
    	}
    	
    	$("#leftmenu li a").click(function(e){
    		$("#leftmenu li a").removeClass("selected");
    		$(e.target).addClass("selected");
    	});
    	
    	if(loadContent == 'true') {
    		$("#leftmenu li a:first").click();
    	} else {
    		$("#leftmenu li a").removeClass("selected");
    		var reqType = (CFN_GetQueryString('reqType') == 'undefined') ? '' : CFN_GetQueryString('reqType');
    		var listType = (CFN_GetQueryString('listType') == 'undefined') ? '' : CFN_GetQueryString('listType');
    		$.each($("#leftmenu li"), function(idx, el){
    			var menuUrl = (el.dataset.menuUrl) ? el.dataset.menuUrl : '';
				if (menuUrl.indexOf(reqType) > 0) {
					$(el).find('a').addClass("selected");
					return;
				}
				
				if(menuUrl.indexOf(listType) > 0){
					$(el).find('a').addClass("selected");
					return;
				}
    		});
    	}
	}
	
	function setLeftMenuActive(){
		var reqType = (CFN_GetQueryString('reqType') == 'undefined') ? '' : CFN_GetQueryString('reqType');
		var listType = (CFN_GetQueryString('listType') == 'undefined') ? '' : CFN_GetQueryString('listType');
		
		$("#leftmenu li a").removeClass("selected");
		if (reqType == ''){
			$("#leftmenu li a:first").addClass("selected");
		}
		else {
			$.each($("#leftmenu li"), function(idx, el){
				var menuUrl = (el.dataset.menuUrl) ? el.dataset.menuUrl : '';
				if (menuUrl.indexOf(reqType) > 0) {
					$(el).find('a').addClass("selected");
					return;
				}
				
				if (menuUrl.indexOf(listType) > 0) {
					$(el).find('a').addClass("selected");
					return;
				}
			});
		}
	}
</script>

