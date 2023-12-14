<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class="cLnbTop">
	<h2 onclick="vacationUserLeft.goVactionHome();" style="cursor:pointer;"><spring:message code='Cache.MN_658' /></h2>
	<div>
		<a class="btnType01 btnSurveyAdd" href="#" onclick="AttendUtils.openVacationPopup('USER');"><spring:message code='Cache.MN_659' /></a>
	</div>	
</div>
<div class="cLnbMiddle mScrollV scrollVType01">
	<ul id="leftVacationMenu" class="contLnbMenu extensionMenu">
	</ul>
</div>

<script type="text/javascript">
var vacationUserLeft = function(){
	if (!(this instanceof arguments.callee )) return new arguments.callee();
	
	//# sourceURL=VacationUserLeft.jsp
	var leftData = ${leftMenuData};
	var loadContent = '${loadContent}';

	var contentUrl = '/groupware/layout/vacation_Home.do?CLSYS=vacation&CLMD=user&CLBIZ=vacation';
	$(document).ready(function(){
		initLeft();
	});
	
	function initLeft(){
		var opt = {
    			lang : "ko",
    			isPartial : "true"
    	};
		var left = new CoviMenu(opt);
		left.render('#leftVacationMenu', leftData, 'userLeft');
		
		if(loadContent == 'true'){
			CoviMenu_OpenMenu(contentUrl);
		}

		 $(".selOnOffBox").find('a').click(function () {	
			var cla= $(this).closest('li').find('.selOnOffBoxChk');
		
			var liname = $(this).parent().parent().attr("class");
		
			if(liname=="extensionMenu02"){
				if(cla.hasClass('active')){
					cla.removeClass("active");
					$(this).removeClass("active");
				}else{
					cla.addClass("active");
					$(this).addClass("active");
				}			
			}else if(liname=="extensionMenu03"){
				if(cla.hasClass('active')){
					cla.removeClass("active");
					$(this).removeClass("active");
				}else{
					cla.addClass("active");
					$(this).addClass("active");
				}
			}else if(liname=="extensionMenu04"){
				if(cla.hasClass('active')){
					cla.removeClass("active");
					$(this).removeClass("active");
				}else{
					cla.addClass("active");
					$(this).addClass("active");
				}
			}
			
		}); 
	}
	
	// 휴가 포탈
	this.goVactionHome=function(){
		CoviMenu_OpenMenu(contentUrl);
	}
	
	// 휴가 신청
	function openVacationApplyPopup() {
		CFN_OpenWindow("/approval/approval_Form.do?formPrefix=WF_FORM_VACATION_REQUEST2&mode=DRAFT", "", 790, (window.screen.height - 100), "resize");
	}	
	
	
	this.getMainUrl=function(){
		return contentUrl;
	}
}();
</script>
