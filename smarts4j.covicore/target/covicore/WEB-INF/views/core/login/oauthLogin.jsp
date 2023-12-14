<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil" %>
<%@ page import="egovframework.core.sso.oauth.*" %>
<%@ page import="java.util.*" %>
<%@ page import="net.sf.json.JSONObject" %>
<% String appPath = PropertiesUtil.getGlobalProperties().getProperty("app.path"); %>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
<title>Login</title>

<!-- 기존 로그인 -->
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision/user_common_controls.css<%=resourceVersion%>" />
<script type="text/javascript" src="<%=appPath%>/resources/script/jquery-1.8.0.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/jquery.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/axisj/AXJ.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/activiti/manageActiviti.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/Controls/Common.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/Controls/CommonControls.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/Controls/Utils.js<%=resourceVersion%>"></script>

<!-- 팝업디자인 -->
<link rel="stylesheet" type="text/css" href="/covicore/resources/css/theme/theme.css<%=resourceVersion%>">

<!-- 새로운 로그인 디자인 적용시 추가된 css/js -->
<script type="text/javascript" src="/covicore/resources/script/jquery.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=cssPath%>/covicore/resources/js/lib/jquery.mCustomScrollbar.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=cssPath%>/covicore/resources/js/lib/typed.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=cssPath%>/board/resources/js/board.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=cssPath%>/doc/resources/js/doc.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=cssPath%>/bizcard/resources/js/bizcard.js<%=resourceVersion%>"></script>


<!-- 플러그 css -->
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/axisj/arongi/AXJ.min.css<%=resourceVersion%>">
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/axisj/arongi/AXGrid.css<%=resourceVersion%>">
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/axisj/arongi/AXTree.css<%=resourceVersion%>">
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision.control.css<%=resourceVersion%>">
<!-- 서버용 -->		
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/jquery.mCustomScrollbar.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/approval/resources/css/approval.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/common.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision/Controls.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/theme/blue.css<%=resourceVersion%>" />	

<link rel="stylesheet" type="text/css" href="<%=cssPath%>/bizcard/resources/css/bizcard.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/board/resources/css/board.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/community/resources/css/community.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/doc/resources/css/doc.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/extension/resources/css/extension.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/myInfo/resources/css/myInfo.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/resource/resources/css/resource.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/schedule/resources/css/schedule.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/survey/resources/css/survey.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/task/resources/css/task.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/VacationManager/resources/css/VacationManager.css<%=resourceVersion%>" />	
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/login.css<%=resourceVersion%>" />

<!-- 팝업 -->
<script type="text/javascript" src="/covicore/resources/script/jquery.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/activiti/manageActiviti.js<%=resourceVersion%>"></script>

<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/jquery-ui-1.12.1.css<%=resourceVersion%>" />
<script type="text/javascript" src="/covicore/resources/script/jquery-ui-1.12.1.js<%=resourceVersion%>"></script>

<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/axisj/arongi/AXToolBar.css<%=resourceVersion%>" />

<!-- grid -->
<script type="text/javascript" language="javascript">
<%
	boolean isloggined = (Boolean)request.getAttribute("isloginned");
	
	String scope = request.getParameter("scope");
%>


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
		
		
		//쿠키
		var cookieID = CFN_GetCookie("loginId");		
		if(cookieID!=""){
			$("#idtemp").val(cookieID);								
			$("#id").val(cookieID);
		} 
	});
	function loginChk(){
		
		var url = "";
		
		url = "/covicore/loginbasechk.do";
		
		if(bool_Check()){
			$.ajax({
				method: "POST",
			    data: {id : $("#id").val(), pw : $("#password").val(), language : $(".langSelect").val()},
				url: url,
				success:function (data) {
					 if(data.result =="ok"){
						 //authorize();
						 login();
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
	function setCookieID(){
		if($("#checkID").attr("checked")){ //체크가 되어 있을 경우
			var loginVal = $("#id").val();
			CFN_SetCookieDate("loginId",loginVal);			
			return;
		}else{			
			CFN_DelCookie("loginId");
			return;
		}
	}
	
	function authorize(){
		$("#frm").attr("method","POST")
		$("#frm").attr("action", "${currenturl}");
		$("#frm").submit();		
	}
	
	function nonAuthorize(){
		$("#isallow").val("false");
		$("#frm").attr("method","POST")
		$("#frm").attr("action", "${currenturl}");
		$("#frm").submit();		
	}
	
	function login(){
		$("#frm").attr("method","POST")
		$("#frm").attr("action", "/covicore/loginchk.do");
		$("#frm").submit();
	}

	function infoSePolicy(pModal){
		Common.open("", "dictionaryPopup", "<spring:message code='Cache.lbl_infoSePolicy'/>", "/covicore/infoSePolicy.do", "491px", "523px", "iframe", true, null, null, true);
			
	}
	function pwReOption(pModal){
		Common.open("","pwReOption","<spring:message code='Cache.lbl_pwReOption'/>","/covicore/pwReOption.do","491px","535px","iframe",pModal,null,null,true);
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
		<section class="loginContent">
			<h1><a href="#">coviSmart</a></h1>
			<section class="loginCont">
				<p></p>
				<article>
					<article  class="infoSePolicy"><a href="#" onclick="infoSePolicy()">정보보호 정책</a></article>
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
									<input type="checkbox" id="checkID" checked><label for="checkID" ><span></span>아이디 저장</label>
								</div>
								<div class = "chkStyle07" id="ssoCheckbox">
									<input type="checkbox" onclick="checkSSO(this);" id="aaaallSV02"><label><span id="checkSSO" onclick="checkSSO(this)" class="checkOff"></span><c:if test="${ssoType == '1'}" var="result">SAML</c:if><c:if test="${ssoType == '2'}" var="result">OAuth</c:if><c:if test="${ssoType == '0'}" var="result">None</c:if></label>
								</div>
								<div class = "chkStyle07">
									<a href="#" onclick = "pwReOption()" class="btnPwReOption">비밀번호 재설정</a>
								</div>
							</div>
						</article>
					</article>
				</article>
				<article class="loginInfo">
					<p class="tit">Help Desk</p>
					<p class="telNumber"><span><strong>T.</strong> 02-1541-6512</span><span class="cLine">|</span><span ><strong>M.</strong> 010-1541-4575</span></p>
					<p class="txt">코비젼 임직원용 시스템으로 인가된 사용자만 사용 할 수 있습니다.<br />
					불법으로 사용시에는 법적 제재를 받을 수 있습니다.</p>
					<p class="copyright">Copyright ⓒ Covision Corp. All Rights Reserved.</p>
				</article>
			</section>
		</section>
	</form>
	</div>
</body>
</html>

