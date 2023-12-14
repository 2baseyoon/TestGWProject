<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%-- <jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include> --%>

<% String appPath = PropertiesUtil.getGlobalProperties().getProperty("app.path"); %>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<link rel="stylesheet" type="text/css" href="/covicore/resources/css/font-awesome-4.7.0/css/font-awesome.min.css<%=resourceVersion%>">
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/axisj/arongi/AXJ.min.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/jquery.mCustomScrollbar.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision.control.css<%=resourceVersion%>" />	
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/common.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision/user_common_controls.css<%=resourceVersion%>" />  
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision/Controls.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/theme/blue.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/jquery-ui-1.12.1.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision/palette-color-picker.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/slick.css<%=resourceVersion%>">

<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/login.css<%=resourceVersion%>" />

<script type="text/javascript" src="/covicore/resources/script/jquery.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/jquery.mousewheel.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/jquery.mCustomScrollbar.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/typed.js<%=resourceVersion%>"></script>
<script	type="text/javascript" src="/covicore/resources/script/bootstrap.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/jquery-ui-1.12.1.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/axisj/AXJ.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/CommonControls.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/Common.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/Utils.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.common.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.dic.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.control.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.comment.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/autosize.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/Dictionary.js<%=resourceVersion%>"></script>

<script type="text/javascript" src="/covicore/resources/script/palette-color-picker.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Jsoner/Jsoner.0.8.2.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/slick.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/jquery.slimscroll.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/html2canvas.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/clipboard.min.js<%=resourceVersion%>"></script>

<style type="text/css">
	.inputBoxSytel01 > div:first-child {
	    position: relative;
	    padding-top: 5px;
	    width: 187px;
	    height: 30px;
	    vertical-align: top;
	    font-weight: 700;
	}
</style>

<div class="layer_divpop">
	<div class="popContent">
		<div class="loginPopContainer loginPassWordCont">
			<div class="top">
				<h2><span>OTP 인증</span></h2>
			</div>			
			<div class="middle mt20">
				<div class="inputBoxSytel01 type03">
					<div><span>인증번호</span></div>
					<div>								
						<input type="text" id="otpNumber"  onkeydown='return onlyNumber(event)' onkeyup='removeChar(event)' style='ime-mode:disabled;'/>
						<a class="btnTypeDefault btnTypeBg" onclick="javascript:sendOTP();">OTP 발송</a>
					</div>
				</div>
			</div>
			<div class="bottom mt20">						
				<a class="btnTypeDefault btnTypeBg" onclick="javascript:otpCheck();">확인</a><a class="btnTypeDefault" onclick="Common.Close();">닫기</a>
			</div>
		</div>
	</div>
</div>	

<script  type="text/javascript">
function sendOTP(){
	
	$.ajax({
		method: "POST",
	    data: {},
		url: "/covicore/control/admin/sendTwoFactor.do",
		success:function (data) {
			 if(data.result =="SUCCESS"){
				Common.Inform("인증 번호가 발송되었습니다.", "Inform");
			 }else{
				Common.Warning("발송에 실패하였습니다.","ERROR");
				return ;
			 }
		}
	
	}); 
	
}

function otpCheck(){
	if($("#otpNumber").val() == ""){
		Common.Warning("인증번호를 입력하세요.","ERROR");
		return ;
	}else{
		$.ajax({
			method: "POST",
		    data: {otp : $("#otpNumber").val()},
			url: "/covicore/control/admin/TwoFactorAdminLogin.do",
			success:function (data) {
				 if(data.result =="SUCCESS"){
					 if(opener){
							opener.window.open(data.url, 'coviSmart','height=' + screen.height + ',width=' + screen.width + 'fullscreen=yes')
							Common.Close();
					 }else{
					 		parent.window.open(data.url, 'coviSmart','height=' + screen.height + ',width=' + screen.width + 'fullscreen=yes')
					 		Common.Close();
					 }	
				 }else{
					Common.Warning("인증번호를 다시 확인하십시오.","ERROR");
					return ;
				 }
			}
		
		}); 
	}
	
}

function onlyNumber(event){
	event = event || window.event;
	var keyID = (event.which) ? event.which : event.keyCode;
	if ( (keyID >= 48 && keyID <= 57) || (keyID >= 96 && keyID <= 105) || keyID == 8 || keyID == 46 || keyID == 37 || keyID == 39 ) 
		return;
	else
		return false;
}

function removeChar(event) {
	event = event || window.event;
	var keyID = (event.which) ? event.which : event.keyCode;
	if ( keyID == 8 || keyID == 46 || keyID == 37 || keyID == 39 ) 
		return;
	else
		event.target.value = event.target.value.replace(/[^0-9]/g, "");
}

</script>