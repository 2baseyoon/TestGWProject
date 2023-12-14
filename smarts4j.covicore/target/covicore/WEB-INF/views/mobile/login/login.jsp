<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page import="egovframework.core.sso.oauth.*" %>
<%@ page import="java.util.*" %>
<%@ page import="net.sf.json.JSONObject" %>

<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<% String appPath = PropertiesUtil.getGlobalProperties().getProperty("app.path"); %>
<% String cryptoType = PropertiesUtil.getSecurityProperties().getProperty("cryptoType"); %>
<% String loginMobilePageCss = PropertiesUtil.getGlobalProperties().getProperty("loginMobilePage.css"); %>

<% String as = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.salt")); %>
<% String aI = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.iv")); %>
<% String ak = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.keysize")); %>
<% int ac = Integer.parseInt(PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.iterationCount"))); %>
<% int app = Integer.parseInt(PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.passPhrase"))); %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Login</title>

<!-- Jquery -->
<script type="text/javascript" src="/covicore/resources/script/Mobile/jquery-1.11.3.js"></script>
<!-- JqueryUI -->
<script type="text/javascript" src="/covicore/resources/script/Mobile/jquery-ui-1.12.1.min.js"></script>
<!-- JqueryMobile -->
<script type="text/javascript" src="/covicore/resources/script/Mobile/jquery.mobile-1.4.5.min.js"></script>
<!-- 퍼블리서 작업 js -->
<script type="text/javascript" src="/covicore/resources/script/Mobile/mobile.ui.js"></script>

<!-- 모바일 공통 css -->
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/mobile/resources/css/common.css" />
<!-- 모바일 테마 css (기본:blue) -->
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/mobile/resources/css/theme/purple.css" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/mobile/resources/css/style.css"/>

<!-- 하랑고객사 납품용 모바일 테마 css -->
<% if(loginMobilePageCss != null && !loginMobilePageCss.isEmpty()){ %>
	<link rel="stylesheet" type="text/css" href="<%=cssPath%><%=loginMobilePageCss%>" />
<% }%>

<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=yes, target-densitydpi=medium-dpi">
<script type="text/javascript" src="<%=appPath%>/resources/script/jquery-1.8.0.min.js"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/jquery.min.js"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/axisj/AXJ.min.js"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/activiti/manageActiviti.js"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/Controls/Common.js"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/Controls/CommonControls.js"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/Controls/Utils.js"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/Controls/covision.common.js"></script>

<% if("R".equals(cryptoType)){ %>
	<script type="text/javascript" src="<%=appPath%>/resources/script/security/jsbn.js"></script>
	<script type="text/javascript" src="<%=appPath%>/resources/script/security/rsa.js"></script>
	<script type="text/javascript" src="<%=appPath%>/resources/script/security/prng4.js"></script>
	<script type="text/javascript" src="<%=appPath%>/resources/script/security/rng.js"></script>
<% }else if("A".equals(cryptoType)){ %>
	<script type="text/javascript" src="<%=appPath%>/resources/script/security/AesUtil.js"></script>
	<script type="text/javascript" src="<%=appPath%>/resources/script/security/aes.js"></script>
	<script type="text/javascript" src="<%=appPath%>/resources/script/security/pbkdf2.js"></script>
<% }%>

<script type="text/javascript" language="javascript">
	var PARAM_VALID = 'N';
	var loginState = "${loginState}";  //로그인 실패 시 fail 로 넘어옴.
	var samlLogin = "${samlLogin}";
	var ssoType = "${ssoType}";
	var samlRequest = "${samlRequest}";
	var cryptoType = "${cryptoType}";
	
	function mobile_comm_setCookie(pCname, pCvalue, exdays) {
		var cname = (typeof pCname != 'undefined') ? pCname.replace(/\n/g,'').replace(/\r/g,'') : '';
		var cvalue = (typeof pCvalue != 'undefined') ? pCvalue.replace(/\n/g,'').replace(/\r/g,'') : '';
	    var d = new Date();
	    d.setTime(d.getTime() + (exdays*24*60*60*1000));
	    var expires = "expires="+ d.toUTCString();
	    document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
	}
	
	function mobile_comm_getCookie(cname) {
	    var name = cname + "=";
	    var decodedCookie = decodeURIComponent(document.cookie);
	    var ca = decodedCookie.split(';');
	    for(var i = 0; i <ca.length; i++) {
	        var c = ca[i];
	        while (c.charAt(0) == ' ') {
	            c = c.substring(1);
	        }
	        if (c.indexOf(name) == 0) {
	            return c.substring(name.length, c.length);
	        }
	    }
	    return "";
	}
	
	$(document).ready(function () {
		
		if(ssoType == "0"){
			$("#ssoCheckbox").hide();
		}
		if(samlRequest != null && samlRequest != ""){
			$("#ssoCheckbox").hide();
		}
		
		if(loginState == "fail"){
			//alert("로그인 실패");
			alert("<spring:message code='Cache.msg_login_fail'/>");
			location.href='/covicore/login.do';
		}
	
		$("#id").val("");
		$("#password").val("");
	
		$("#id").hide();
		$("#password").hide();
	
		$("#idtemp").focus(function () {
			$("#idtemp").hide();
			$("#id").show();
	
			$("#id").focus();
		});
	
		$("#passwordtemp").focus(function () {
			$("#passwordtemp").hide();
			$("#password").show();
	
			$("#password").focus();
		});
	
		$("#id").blur(function () {
			if($("#id").val() == ""){
				$("#id").hide();
				$("#idtemp").show();
			}
		});
	
		$("#password").blur(function () {
			if($("#password").val() == ""){
				$("#password").hide();
				$("#passwordtemp").show();
			}
		});
	
		//쿠키
		var cookieID = mobile_comm_getCookie("loginId");		
		if(cookieID!="" && cookieID != "undefined"){
			$("#idtemp").val(cookieID);								
			$("#id").val(cookieID);
		}
	
		var cookieLang = mobile_comm_getCookie("langCode");
		if(cookieLang!="" && cookieLang != "undefined"){
			$("#langList").val(cookieLang);
			$(".langSelect").val(cookieLang);
		}
	});
	
	function loginChk(){
		setCookieData();
		
		var url = "";
		var suUrl = "";
	
		/* if(samlLogin == "Y"){
			url = "loginbasechk.do";
			suUrl = "samlloginchk.do";
			
		}else{ */
			url = "loginbasechk.do";
			suUrl = "loginchk.do";
		/* } */
		
		if(bool_Check()){
			var encPassword = "";
			if(cryptoType == "R"){
				var rsaPublicKeyModulus = $("#rsaPublicKeyModulus").val();
				var rsaPublicKeyExponent = $("#rsaPublicKeyExponent").val();
				encPassword = fnRsaEnc($("#password").val(), rsaPublicKeyModulus, rsaPublicKeyExponent);
			}else if(cryptoType == "A"){
				
				 var aesUtil = new AesUtil("<%=ak%>", "<%=ac%>");
				 
				 encPassword = aesUtil.encrypt("<%=as%>", "<%=aI%>", "<%=app%>", $("#password").val());
				
			}else{
				encPassword = $("#password").val();
			}
			
			$.ajax({
				method: "POST",
			    data: {id : $("#id").val(), pw : encPassword, language : $(".langSelect").val()},
				url: url,
				success:function (data) {
					 if(data.result =="ok"){
						
						$("#frm").attr("method","POST")
						$("#frm").attr("action", suUrl);
						$("#frm").submit();		
					 }else{
						alert("<spring:message code='Cache.msg_login_fail'/>");
						return ;
					 }
				
				}
			
			}); 
			
		
		}
	}
	function bool_Check() {
	    var bReturn = true;
		if (($("#id").val() == "아이디") ||($("#id").val() == "")) {
	    	bReturn = false;
	    	alert("<spring:message code='Cache.msg_enter_ID'/>");
	    } else if ($("#password").val() == "") {
	    	bReturn = false;
	    	alert("<spring:message code='Cache.msg_enter_PW'/>");
	    }
		return bReturn;
	}
	
	function selectBox(pObj){		
		if($('.langList').css('display') == 'none'){
			$('.langList').show();
		}else{
			$('.langList').hide();
		}		
		$(".langSelect").html($("#langList>option:selected").text());
		$(".langSelect").val($("#langList").val());
	}
	
	function setCookieData(){
		if($("#checkID").prop("checked")){
			var loginVal = $("#id").val();
			mobile_comm_setCookie("loginId", loginVal, 1);			
		}else{			
			mobile_comm_setCookie("loginId", "", 1);
		}
		
		//사용언어 설정 저장
		mobile_comm_setCookie("langCode", $('#langList').val(), 1);
	}
	
	//saveid체크
	function checkUseId(pObj){		
		var objClass = $(pObj).attr("class");		
		if(objClass=="checkOn"){
			$(pObj).attr("class","checkOff");					
		}else if(objClass=="checkOff"){
			$(pObj).attr("class","checkOn");				
		}		
	}
	
	function checkSSO(pObj){		
		var objClass = $(pObj).attr("class");		
		if(objClass=="checkOn"){
			$(pObj).attr("class","checkOff");
		}else if(objClass=="checkOff"){
			$(pObj).attr("class","checkOn");		
			$("#frm").attr("method","POST")
			$("#frm").attr("action", "samlLogin.do");
			$("#frm").submit();	
		}
	}
	
	function fnRsaEnc(value, rsaPublicKeyModulus, rsaPpublicKeyExponent) {
		
	    var rsa = new RSAKey();

	    rsa.setPublic(rsaPublicKeyModulus, rsaPpublicKeyExponent);
	    var encValue = rsa.encrypt(value)
	    
	    return encValue;

	}
</script>
</head>
	<body>
		<div>
			<form method="post" id="frm">
				<input type="hidden" id="RelayState" name="RelayState" value="${relayState}"/>
				<input type="hidden" id="SamlRequest" name="SamlRequest" value="${samlRequest}"/>
				<input type="hidden" id="uid" name="uid" value="${uid}"/>
				<input type="hidden" id="acr" name="acr" value="${acr}"/>
				<input type="hidden" id="destination" name="destination" value="${destination}"/>
				<input type="hidden" id="rsaPublicKeyModulus" value="${publicKeyModulus}">
				<input type="hidden" id="rsaPublicKeyExponent" value="${publicKeyExponent}">
				<input type="hidden" id="sessionTimeOutCheck">
				
				<div class="login_wrap">
					<div class="login_top">
						<p class="tit">covi smart - groupware system</p>
					</div>
					<div class="login_data">
						<div class="input_text">
							<input type="text" id="idtemp" name="idtemp" value="ID" style="ime-mode:disabled;">
							<input type="text" id="id" name="id" value="" style="ime-mode:disabled;" onkeypress="if (event.keyCode==13){ loginChk(); return false;}">
							<input type="text" id="passwordtemp" name="passwordtemp" value="Password">
	      					<input type="password" id="password" name="password" value="" autocomplete="off" onkeypress="if (event.keyCode==13){ loginChk(); return false;}">
						</div>
						<div class="ctrl">
							<input type="checkbox" id="checkID" name="checkID"><label for="checkID">아이디 저장</label>
							<input type="hidden" name="language" class="langSelect" id="langSelect" value="ko"/>
							<select class="" name="langList" id="langList" onchange="selectBox(this);">
								<!-- <option value="ko">한국어</option>
								<option value="en">English</option>
								<option value="ja">日本語</option>
								<option value="zh">中國語</option> -->
								<option value="ko">KOR</option>
								<option value="en">ENG</option>
								<option value="ja">JPN</option>
								<option value="zh">CHN</option>
							</select>
						</div>
						<a href="#" class="btn_login" onclick="javascript:loginChk(); return false;">LOGIN</a>
					</div>
			    </div>
			</form>
		</div>
    </body>
</html>