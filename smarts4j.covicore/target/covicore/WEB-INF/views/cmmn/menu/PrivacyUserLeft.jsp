<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class="cLnbTop">
	<h2><spring:message code="Cache.lbl_PersonalPreference"/></h2> <!-- 개인환경설정 -->
</div>
<div class="cLnbMiddle noneBtnTop mScrollV scrollVType01">
	<div>
		<ul class="contLnbMenu myInfoMenu">								
			<li class="myInfoMenu01">
				<a data-menu-path="/groupware/layout/privacy_DefaultSetting.do" onclick="javascript:clickPrivacyLeftMenu(this);"><spring:message code="Cache.lbl_BasicInfo"/></a>
			</li> <!-- 기본 정보 -->
			<li class="myInfoMenu02">
				<a data-menu-path="/covicore/passwordChange.do" onclick="javascript:clickPrivacyLeftMenu(this);"><spring:message code="Cache.lbl_ChangePassword"/></a>
			</li> <!-- 비밀번호 변경 -->
			<li class="myInfoMenu03">
				<a data-menu-path="/groupware/layout/privacy_Anniversary.do" onclick="javascript:clickPrivacyLeftMenu(this);"><spring:message code="Cache.lbl_AnniversaryManagement"/></a>
			</li> <!-- 기념일 관리 -->
			<li class="myInfoMenu04">
				<a data-menu-path="/groupware/layout/privacy_ConnectionLog.do" onclick="javascript:clickPrivacyLeftMenu(this);"><spring:message code="Cache.lbl_AccessHistory"/></a>
			</li> <!-- 접속이력 -->
			<li class="myInfoMenu05">
				<a data-menu-path="/groupware/layout/privacy_AlarmSetting.do" onclick="javascript:clickPrivacyLeftMenu(this);"><spring:message code="Cache.lbl_MessagingSetting"/></a>
			</li> <!-- 통합 메세징 설정 -->
		</ul>
	</div>
</div>

<script type="text/javascript">
	//# sourceURL=PrivacyUserLeft.jsp
	
	var loadContent = '${loadContent}';
	
	initLeft();
	
	function initLeft(){
    	if(loadContent == 'true'){
    		if (Common.getSession('UR_InitialConnection') == 'Y' || Common.getSession('UR_PassExpireDate') != '') {
    			$(".myInfoMenu02 a").click();
        	}
    		else {
    			$(".myInfoMenu01 a").click();
    		}
    	}
    	else {
    		var pathname = location.pathname;
    		$.each($(".myInfoMenu a"), function(idx, el){
    			if (el.dataset.menuPath == pathname) { $(el).addClass("selected"); }
    		})
    	}
    	
		coviCtrl.bindmScrollV($('.mScrollV'));
	}
	
	function clickPrivacyLeftMenu(target){
		$(".myInfoMenu a").removeClass("selected");
		$(target).addClass("selected");
		CoviMenu_GetContent(target.dataset.menuPath+'?CLSYS=privacy&CLMD=user&CLBIZ=Privacy');
	}
</script>

