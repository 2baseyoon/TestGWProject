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
<% String loginPageCss = PropertiesUtil.getGlobalProperties().getProperty("loginPage.css"); %>
<% pageContext.setAttribute("loginImageClass", PropertiesUtil.getGlobalProperties().getProperty("loginImage.class")); %>
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
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision/common_controls.css<%=resourceVersion%>">

<% if(loginPageCss != null && !loginPageCss.isEmpty()){ %>
	<link rel="stylesheet" type="text/css" href="<%=cssPath%><%=loginPageCss%>" />
<% }%>

<!-- 서버용 -->
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/common.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/style.css<%=resourceVersion%>" />
<!-- 로그인 cloud 추가 -->
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/login_saas.css<%=resourceVersion%>" />

<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/jquery-ui-1.12.1.css<%=resourceVersion%>" />
	
<script type="text/javascript" src="<%=appPath%>/resources/script/jquery-1.8.0.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/jquery.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/axisj/AXJ.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/Controls/Common.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/Controls/CommonControls.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/Controls/Utils.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/Controls/covision.common.js<%=resourceVersion%>"></script>


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

<style>
.layer_divpop .divpop_body { padding: 0; }
</style>

<script type="text/javascript" language="javascript">
	/* 비밀번호 확인 → 계정잠금 확인 → two factor → 동시접속 확인 */
	var loginState = "${loginState}";  //로그인 실패 시 fail 로 넘어옴.
	var samlLogin = "${samlLogin}";
	var ssoType = "${ssoType}";
	var samlRequest = "${samlRequest}";
	var cryptoType = "${cryptoType}";
	var useFIDO = "${useFIDO}"; //파이도 사용여부 

	var domainThemeCode = "${domainThemeCode}"; //로그인 테마
	var useFIDO = "${useFIDO}"; //파이도 사용여부 
	var dicData = {};
	$(document).ready(function () {
		XFN_closeWindowOpenList();

		if(document.location.href.indexOf("login.do") < 0){
			location.href='/covicore/login.do';
		}

		if ("${domainLoginImagePath}" != ""){
			$(".loginContent").css({'background-image': 'url(/covicore/covics/loginImg.do?domainCode=${domainCode})'});
		}	
		if(useFIDO == "Y"){
			changeLoginType($("#tabFIDO"));
			$("#LoginTypeTabDiv").show();
		}
		
		if(ssoType == "0" || samlLogin == "N"){
			$("#ssoCheckbox").hide();
		}
		if(samlRequest != null && samlRequest != "" ){
			$("#ssoCheckbox").hide();
		}		
		
		if(loginState == "fail"){
			Common.Warning(dicData["msg_login_fail"],"ERROR",function(){
				location.href='/covicore/login.do';
			});
		} 
		$("#id").val("");
		$("#password").val("");
		
		$("#id, #password").keypress(function(){
			if (event.keyCode==13){ loginChk(); return false;}
		});
		
		//login click
		$(".btnLogin").click(function(){
			loginChk()
		});
		
		$("#id").keyup(function(){
			this.value=this.value.replace(/[^a-zA-Z-_.0-9@]/g,'');
		});

		$("#checkID").click(function(){
			if($("#checkID").prop("checked")){
				coviCmn.setCookie("loginIdCheck", "Y", 1);			
			}else{			
				coviCmn.setCookie("loginIdCheck", "N", 1);
			}
		});
		
		//비밀번호 재설정
		$(".btnPwReOption").click(function(){
			Common.open("", "PasswordReset", $(".btnPwReOption").text(),"/covicore/control/callPasswordReset.do?lang="+$("#language").val(), "520px", "480px", "iframe", true, null, null, true);
		});
	
		//언어변경
		$("#language").change(function(){
			getDicCallData();

			$("#saveId").text(dicData["lbl_saveID"]);
			$(".btnPwReOption").text(dicData["lbl_pwReOption"]);
			
			$(".loginInfo .caution").html(dicData["lbl_loginOnly"]+"<br>"+dicData["lbl_illegal"]);
			$(".loginInfo .customerBox .tit #subTit").text(dicData["lbl_CustomerSupp"]);
			$(".btnTypeLArrr").text(dicData["lbl_Index"]);
			
		});
		
		//탭 클릭id 
		$(".list li").click(function(){
			//content
			if ($(".layer_customer").attr("load") != "true"){
	        	$(".layer_customer").attr("data",$(this).index());
				$.ajax({
			        type : "GET",
			        cache : false,
			        url : "/covicore/covics/list.do",
			        beforeSend : function(req) {
			            req.setRequestHeader("Accept", "text/html;type=ajax");
			        },
			        success : function(res) {
			        	$(".layer_customer").html(res);
			        	$(".layer_customer").attr("load","true");
						$(".layer_customer").show();
			        },
			        error : function(response, status, error){
			        }
			    });	
			}
			else{
				$(".layer_customer").show();
				$(".tabMenu li:eq("+$(this).index()+")").trigger("click");
			}	
		});

        $(".layer_customer").draggable();

		//쿠키
		var cookieIDCheck = coviCmn.getCookie("loginIdCheck");		
		if(cookieIDCheck!="" && cookieIDCheck != "undefined" && cookieIDCheck == 'Y'){
			$("#checkID").click();
		}
		
		//쿠키
		var cookieID = coviCmn.getCookie("loginId");		
		if(cookieID!="" && cookieID != "undefined"){
			$("#id").val(cookieID);
		}

		var cookieLang = coviCmn.getCookie("langCode");
		if(cookieLang!="" && cookieLang != "undefined"){
			$("#language").val(cookieLang);
			if (cookieLang!="ko") $("#language").change();
		}
		getDicCallData();
	});
	
	function getDicCallData(){
		var jsonData = {};
		jsonData["locale"] = $("#language").val();
		var pKeys = "lbl_Biometrics;lbl_login;lbl_saveID;lbl_pwReOption;lbl_Password;lbl_loginOnly;lbl_illegal;msg_login_fail;lbl_accountLock;msg_enter_ID;msg_enter_PW;lbl_CustomerSupp;lbl_Index;msg_twoFactorAuth;msg_otp_reConfirm;msg_anotherConnection;msg_noAuthLoginIP;msg_otpExpiration;msg_otp_resend;msg_otp_expired_resend;msg_enter_ID;msg_enter_PW;msg_login_fail;msg_fido04;msg_caps_lock;lbl_RequestUserAuth"
		jsonData["keys"] = pKeys;
		$.ajax({
			url:"/covicore/common/getdicall.do",			// [2016-10-26] 박경연. approval/user에서 접근할 때 문제가 있음
			data:jsonData,
			type:"post",
			async:false,
			success: function (res) {
				$(pKeys.split(';')).each(function (idx, obj) {
					var dicItem = res.list[0][obj];
					dicData[obj.toString()] = dicItem;
				});
			},
			error:function(response, status, error){
				CFN_ErrorAjax("common/getdicall.do", response, status, error);
			}
		});
	}
	
	function loginChk(){
		setCookieData();
		
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
			
			$("#password").val("");
			$.ajax({
				method: "POST",
			    data: {id : $("#id").val(), pw : encPassword, language : $("#language").val(), activeTime:localStorage.getItem($("#id").val() + "_sessionLastActiveTime"),"EXCLUDE_VALD":true},
				url: "loginbasechk.do",
				success:function (data) {
					 if(data.result =="ok"){
						$("#frm").attr("method","POST")
						$("#frm").attr("action", "loginchk.do");
						$("#frm").submit();		
					 }else if(data.result == "nosession"){
						 Common.Warning(dicData["msg_otpExpiration"], "Smart4J", function(result){ //인증키 만료!!! 화면을 재설정합니다.
								location.reload();
						});
					 }else if(data.result == "lock"){
						 Common.Warning(dicData["lbl_accountLock"]); //계정이 잠금되었습니다. 비밀번호 재설정 바랍니다.
						 return ;
					 }else if(data.result == "inaccessIP"){ //사용자 IP 접근권한 없음
						 Common.Warning(dicData["msg_noAuthLoginIP"]);
						 return ;
					 }else if(data.result == "factor"){
						 if(useFIDO =="Y"){ //파이도 사용여부
							 Common.open("", "authwarning", "Warning","/covicore/control/authWarningPopup.do", "300px", "210px", "iframe", true, null, null, true);	
						 }else{
							Common.Warning(dicData["msg_fido04"],"Warning",function(){
								 Common.open("", "OTP", dicData["msg_twoFactorAuth"],"/covicore/control/twoFector.do?id="+$("#id").val(), "520px", "310px", "iframe", true, null, null, true);	
							});
						 }
						 return ;
					 }else if(data.result == "duplication"){
						Common.Confirm(dicData["msg_anotherConnection"], "Confirm", function(result){
							if(result){
								duplicationLogin();
							}
						});
					 } else{
						Common.Warning(dicData["msg_login_fail"]);
						return ;
					 }
				
				}
			
			});  
		
		}
	}
	function bool_Check() {
	    var bReturn = true;
		if ($("#id").val() == "") {
 	    	bReturn = false;
	    	Common.Warning(dicData["msg_enter_ID"],"ERROR");
	    } else if ($("#password").val() == "") {
	    	bReturn = false;
	    	Common.Warning(dicData["msg_enter_PW"],"ERROR");
	    }
		return bReturn;
	}
	
	function setCookieData(type){ //undefined or fido
		if($("#checkID").prop("checked")){
			var loginVal = $("#id").val();
			coviCmn.setCookie("loginId", loginVal, 1);			
		}else{			
			coviCmn.setCookie("loginId", "", 1);
		}
		
		//사용언어 설정 저장
		coviCmn.setCookie("langCode", $('#language').val(), 1);
	}
	
	function changeLoginType(obj){
		$("#LoginTypeTabDiv li").attr("class", "FDtabMenuOff");
		$(obj).attr("class", "FDtabMenuOn");
		
		if($(obj).attr("value") =="Password"){
			$("#LoginDiv").show();
			$("#FIDOLoginDiv").hide();
		}else if($(obj).attr("value") =="FIDO"){
			$("#LoginDiv").hide();
			$("#FIDOLoginDiv").show();
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
	
	function twoFactorLogin(otpNumber, otpUseTime){
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
			data: {id : $("#id").val(), pw: encPassword , otp : otpNumber, language : $("#langList").val(), otpUseTime : otpUseTime},
			url: "loginTwoFactorChk.do",
			success:function (data) {
				if(data.result =="ok"){
					$("#frm").attr("method","POST")
					$("#frm").attr("action", "loginchk.do");
					$("#frm").submit();		
				}else{
					if(data.failcount == 0){
						$('#OTP_if')[0].contentWindow.Common.Warning(dicData["msg_otp_expired_resend"]);
					} else if(data.failcount <= data.baseFailCount){
						$('#OTP_if')[0].contentWindow.Common.Warning(dicData["msg_otp_reConfirm"] + "<br>" + dicData["msg_otp_FailCount"] + " : "+ data.failcount + " / " + data.baseFailCount);
					} else {
          				Common.Warning(dicData["msg_otp_resend"]);
          			}
					
					return;
				 }
			}
		}); 
	}

	function duplicationLogin(){
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
		    data: {id : $("#id").val(), pw: encPassword , language : $("#language").val()},
			url: "/covicore/loginDuplicationChk.do",
			success:function (data) {
				 if(data.result =="ok"){
					$("#frm").attr("method","POST")
					$("#frm").attr("action", "loginchk.do");
					$("#frm").submit();		
				 }
			}
		
		}); 
		
	}
	
	function callBackSelectAuth(authType){
		switch(authType){
			case 'OTP': 	 
				Common.open("", "OTP", dicData["msg_twoFactorAuth"],"/covicore/control/twoFector.do?id="+$("#id").val(), "520px", "310px", "iframe", true, null, null, true);
				break;
			case 'FIDO': 
				Common.open("", "checkFido", dicData["lbl_RequestUserAuth"], "/covicore/control/checkFido.do?logonID="+$("#id").val()+"&authType=Login", "400px", "510px", "iframe", true, null, null, true); //사용자 본인인증 요청
				break;
		}
	}

</script>
</head>
<body>	
	<div id='wrap' class='login_${domainThemeCode eq '' or domainThemeCode eq 'blue'?'purple':domainThemeCode}'>
	<form method="post" id="frm">	
	<input type="hidden" id="RelayState" name="RelayState" value="${relayState}"/>
	<input type="hidden" id="uid" name="uid" value="${uid}"/>
	<input type="hidden" id="acr" name="acr" value="${acr}"/>
	<input type="hidden" id="destination" name="destination" value="${destination}"/>
	<input type="hidden" id="rsaPublicKeyModulus" value="${publicKeyModulus}">
	<input type="hidden" id="rsaPublicKeyExponent" value="${publicKeyExponent}">
		<section class="loginContent">
			<section class="loginCont">
				<h1>COVISION Cloud Groupware</h1>
				<article class="loginBox">
					<div class="loginInputCont">
						<div class="loginSelect">
							<select class="lang" id="language" name="language">
					          	<option value="ko">Kor</option>
					          	<option value="en">Eng</option>
					          	<option value="ja">Jpn</option>
					          	<option value="zh">Chn</option>
							</select>
						</div>
						<div class="mt5"><input type="text" id="id" name="id" placeholder="ID" ></div>
						<div class="mt5"><input type="password" id="password" name="password" placeholder="PW" autocomplete="off" onkeyup="checkCapsLock(event)"></div>
						<div class="mt25">
							<a href="#" class="btnLogin">LOGIN</a>
						</div>
						<div class="loginSetting">
							<div class="chkSave">
								<input type="checkbox" id="checkID" name="checkID"><label for="checkID"><span class="s_check"></span><span id="saveId">아이디 저장</span></label>
							</div>
							<div style="margin-left : 8px">
								<a href="#" class="btnPwReOption">비밀번호 재설정</a>
							</div>
						</div>
					</div>
				</article>
				<article class="loginInfo">
					<div class="customerBox">
						<p class="tit"><span id="subTit">고객지원서비스</span><span class="Tel"> -  <%=PropertiesUtil.getGlobalProperties().getProperty("login.telno")==null?"02&middot;6965&middot;3224":PropertiesUtil.getGlobalProperties().getProperty("login.telno")%></span></p>
						<ul class="list">
							<li data-tab="tab-1"><a href="#"><span class="cImg cImg1"></span> <span class="cTxt">NOTICE</span></a></li>
							<li data-tab="tab-2"><a href="#"><span class="cImg cImg2"></span> <span class="cTxt">NEWS</span></a></li>
							<li data-tab="tab-3"><a href="#"><span class="cImg cImg3"></span> <span class="cTxt">FAQ</span></a></li>
						</ul>
					</div>
					<p class="caution">임직원용 시스템으로 인가된 사용자만 사용 할 수 있습니다.<br /> 불법으로 사용시에는 법적 제재를 받을 수 있습니다.</p>
					<p class="copyright">Copyright 2020. Covision corp. All Rights Reserved.<font id="timeoutDesc"></font></p>
				</article>
			</section>
		</section>
	</form>
	</div>
	
	<!-- 로그인 고객지원 팝업 시작 : width, height 그대로 적용해주세요 -->
	<div class="layer_divpop layer_customer  ui-draggable" style="width:840px; height:630px; left:0; right:0; top:0; bottom:0; margin:auto; z-index:104; display:none;" data="0">
	</div>
	<!-- 로그인 고객지원 팝업 끝 -->

</body>
</html>

