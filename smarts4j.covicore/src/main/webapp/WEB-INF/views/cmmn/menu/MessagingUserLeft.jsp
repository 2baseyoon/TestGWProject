<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<div class="cLnbTop">
	<h2><spring:message code='Cache.lbl_MessagingSetting' /></h2><!-- 설문 -->
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
    	}
    	if(loadContent == 'true') {
    		
    		CoviMenu_GetContent('/covicore/layout/messaging_MessagingTypeMng.do?CLSYS=messaging&CLMD=user&CLBIZ=Messaging');
    	}
	}
</script>

