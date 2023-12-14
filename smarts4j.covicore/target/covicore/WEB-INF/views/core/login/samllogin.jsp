<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil" %>
<%@ page import="egovframework.core.sso.oauth.*" %>
<%@ page import="java.util.*" %>
<%@ page import="net.sf.json.JSONObject" %>
<% String appPath = PropertiesUtil.getGlobalProperties().getProperty("app.path"); %>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<% String cryptoType = PropertiesUtil.getSecurityProperties().getProperty("cryptoType"); %>

<% String as = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.salt")); %>
<% String aI = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.iv")); %>
<% String ak = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.keysize")); %>
<% int ac = Integer.parseInt(PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.iterationCount"))); %>
<% int app = Integer.parseInt(PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.passPhrase"))); %>
<% String copyRight = PropertiesUtil.getGlobalProperties().getProperty("copyright"); %>

<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
<title><%=PropertiesUtil.getGlobalProperties().getProperty("front.title") %></title>

<!-- 플러그 css -->
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/axisj/arongi/AXJ.min.css<%=resourceVersion%>">
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision.control.css<%=resourceVersion%>">
<!-- 서버용 -->		
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/jquery.mCustomScrollbar.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/common.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision/Controls.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/theme/blue.css<%=resourceVersion%>" />	
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/login.css<%=resourceVersion%>" />

<!-- 기존 로그인 -->
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision/user_common_controls.css<%=resourceVersion%>" />
<script type="text/javascript" src="<%=appPath%>/resources/script/jquery-1.8.0.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/jquery.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/axisj/AXJ.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/Controls/Common.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/Controls/CommonControls.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/Controls/Utils.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/Controls/covision.common.js<%=resourceVersion%>"></script>

<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/jquery-ui-1.12.1.css<%=resourceVersion%>" />
<script type="text/javascript" src="<%=appPath%>/resources/script/jquery-ui-1.12.1.js<%=resourceVersion%>"></script>

<% if("R".equals(cryptoType)){ %>
	<script type="text/javascript" src="<%=appPath%>/resources/script/security/jsbn.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="<%=appPath%>/resources/script/security/rsa.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="<%=appPath%>/resources/script/security/prng4.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="<%=appPath%>/resources/script/security/rng.js<%=resourceVersion%>"></script>
<% }else if("A".equals(cryptoType)){ %>
	<script type="text/javascript" src="<%=appPath%>/resources/script/security/AesUtil.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="<%=appPath%>/resources/script/security/aes.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="<%=appPath%>/resources/script/security/pbkdf2.js<%=resourceVersion%>"></script>
<% }%>

<!-- grid -->
<script type="text/javascript" language="javascript">
	
	var loginState = "${loginState}";  //로그인 실패 시 fail 로 넘어옴.
	var samlLogin = "${samlLogin}";
	var ssoType = "${ssoType}";
	var samlRequest = "${samlRequest}";
	var cryptoType = "${cryptoType}";
	
	$(document).ready(function () {		
		
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
		
		$("#checkID").click(function(){
			if($("#checkID").prop("checked")){
				coviCmn.setCookie("loginIdCheck", "Y", 1);			
			}else{			
				coviCmn.setCookie("loginIdCheck", "N", 1);
			}
		});
		
		//쿠키
		var cookieIDCheck = coviCmn.getCookie("loginIdCheck");		
		if(cookieIDCheck!="" && cookieIDCheck != "undefined" && cookieIDCheck == 'Y'){
			$("#checkID").click();
		}

		//쿠키
		var cookieID = coviCmn.getCookie("loginId");		
		if(cookieID!="" && cookieID != "undefined"){
			$("#idtemp").val(cookieID);								
			$("#id").val(cookieID);
		}

		var cookieLang = coviCmn.getCookie("langCode");
		if(cookieLang!="" && cookieLang != "undefined"){
			$("#langList").val(cookieLang);
			$(".langSelect").val(cookieLang);
		}
	});
	
	function loginChk(){
		setCookieData();
		
		var url = "";
		var suUrl = "";

		url = "samlLoginbasechk.do";
		suUrl = "samlLoginchk.do";
		
		if(bool_Check()){
			var encPassword = "";
			if(cryptoType == "A"){
				
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
						Common.Warning("<spring:message code='Cache.msg_login_fail'/>","ERROR");
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
	    	Common.Warning("<spring:message code='Cache.msg_enter_ID'/>","ERROR");
	    } else if ($("#password").val() == "") {
	    	bReturn = false;
	    	Common.Warning("<spring:message code='Cache.msg_enter_PW'/>","ERROR");
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
			coviCmn.setCookie("loginId", loginVal, 1);			
		}else{			
			coviCmn.setCookie("loginId", "", 1);
		}
		
		//사용언어 설정 저장
		coviCmn.setCookie("langCode", $('#langList').val(), 1);
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
	
	
	function infoSePolicy(pModal){
		Common.open("", "SecurityPolicy", "<spring:message code='Cache.lbl_infoSePolicy'/>", "/covicore/control/callSecurityPolicy.do", "491px", "523px", "iframe", true, null, null, true);
			
	}
	
	function resetPassword(pModal){
		Common.open("", "PasswordReset", "<spring:message code='Cache.lbl_pwReOption'/>","/covicore/control/callPasswordReset.do", "491px", "480px", "iframe", true, null, null, true);
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
	<div id='wrap'>		
	<form method="post" id="frm">	
	<input type="hidden" id="RelayState" name="RelayState" value="${relayState}"/>
	<input type="hidden" id="SamlRequest" name="SamlRequest" value="${samlRequest}"/>
	<input type="hidden" id="uid" name="uid" value="${uid}"/>
	<input type="hidden" id="acr" name="acr" value="${acr}"/>
	<input type="hidden" id="destination" name="destination" value="${destination}"/>
	<input type="hidden" id="rsaPublicKeyModulus" value="${publicKeyModulus}">
	<input type="hidden" id="rsaPublicKeyExponent" value="${publicKeyExponent}">
	
		<section class="loginContent2">
			<h1><a href="#" class="covision">covision</a></h1>
			<div class="title">
				<p class="title01"></p>
			</div>
			<div class="background">
		        <img src="<%=cssPath%>/covicore/resources/images/login/login_img.jpg" id="bg" alt="">
            </div>
<!-- 			<video class="main_video" id="main-video" preload="metadata" autoplay="" loop=""> -->
<%-- 				<source class="mainVideoSrc" src="<%=cssPath%>/covicore/resources/images/login/loginvideo.mp4" type="video/mp4"> --%>
<!-- 			</video> -->
			<section class="loginCont">
				<p></p>
				<article>
<!-- 					<article  class="infoSePolicy"><a href="javascript:;" onclick="infoSePolicy();return false;">정보보호 정책</a></article> -->
					<article class="loginBox mt20">
						<article>
							<p>
								<strong>GROUPWARE</strong>
								<br />
								<strong>SYSTEM</strong>
							</p>
						</article>
						<article class="loginInputCont">
							<div class="loginSelectCont">
							 <input type="hidden" name="language" class="langSelect" value="ko"/>
								<select class="selectType05" id="langList" onclick="selectBox(this);">
							          	<option value="ko">Kor</option>
							          	<option value="en">Eng</option>
							          	<option value="ja">Jpn</option>
							          	<option value="zh">Chn</option>
								</select>
							</div>
							<div class="mt15">
							
							<input type="text" id="idtemp" name="idtemp" class="roundInput" value="ID">
          					<input type="text" id="id" name="id" class="roundInput" value="" onkeypress="if (event.keyCode==13){ loginChk(); return false;}">  
							
							</div>
							<div class="mt5">
							
							<input type="text" id="passwordtemp" name="passwordtemp" class="roundInput" value="Password">
          					<input type="password" id="password" name="password" class="roundInput" value="" autocomplete="off" onkeypress="if (event.keyCode==13){ loginChk(); return false;}">    
							
							</div>
							
							<div class="mt20">
    							<a href="#" onclick="javascript:loginChk();" class="btnLogin">LOGIN</a>
							</div>
							
							<div class="mt15 loginSetting">
								<div class="chkStyle07">
									<input type="checkbox" id="checkID"><label for="checkID" ><span></span>아이디 저장</label>
								</div>
								<div class = "chkStyle07" id="ssoCheckbox">
									<input type="checkbox" onclick="checkSSO(this);" id="aaaallSV02"><label><span id="checkSSO" onclick="checkSSO(this)" class="checkOff"></span><c:if test="${samlLogin == 'Y'}"><c:if test="${ssoType == '1'}" var="result">SAML</c:if><c:if test="${ssoType == '2'}" var="result">OAuth</c:if><c:if test="${ssoType == '0'}" var="result">None</c:if></c:if></label>
								</div>
								<div class = "chkStyle07">
									<a href="javascript:;" onclick = "resetPassword();return false;" class="btnPwReOption">비밀번호 재설정</a>
								</div>
							</div>
						</article>
					</article>
				</article>
				<article class="loginInfo">
<!-- 					<p class="tit">Help Desk</p> -->
<!-- 					<p class="telNumber"><span><strong>T.</strong> 02-1541-6512</span><span class="cLine">|</span><span ><strong>M.</strong> 010-1541-4575</span></p> -->
					<p class="txt">임직원용 시스템으로 인가된 사용자만 사용 할 수 있습니다.
					<br />불법으로 사용시에는 법적 제재를 받을 수 있습니다.</p>
					
					<p class="copyright">Copyright ⓒ <%=copyRight %> Corp. All Rights Reserved.</p>
				</article>
			</section>
		</section>
	</form>
	</div>
</body>
</html>

