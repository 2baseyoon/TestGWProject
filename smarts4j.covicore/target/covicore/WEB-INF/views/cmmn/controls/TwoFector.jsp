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
				<div id="otpTimeDiv" class="inputBoxSytel01 type03" style="display: none;">
					<div><span>인증 유효시간</span></div>
					<div id="otpTime">
						<span id="otpMinute"></span>:<span id="otpSecond"></span>
					</div>
					<div id="otpMessage" style="display: none; color: red; font-weight: 700;">인증번호가 만료되었습니다.</div>
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
	    data: {id : "${id}"},
		url: "/covicore/control/sendTwoFactor.do",
		success:function (data) {
			 if(data.result =="SUCCESS"){
				Common.Inform("인증 번호가 발송되었습니다.", "Inform");
				setOtpTimer(data.otp);
			 }else if (data.code == 'wait'){
				 var min;
				 var sec;
				 if(data.diff < 60){
					min = 0;
					sec = data.diff;
				 } else {
					 min = parseInt(data.diff / 60);
					 sec = data.diff - (min*60);
				 }
				 Common.Warning(min + "분 " + sec + "초 후에 다시 시도하세요.");
			 } else{
				Common.Warning("발송에 실패하였습니다.","ERROR");
				return ;
			 }
		}
	}); 
}

function otpCheck(){
	var otpUseTime = (parseInt($("#otpMinute").text())+ parseInt($("#otpSecond").text())); 
	if($("#otpNumber").val() == ""){
		Common.Warning("인증번호를 입력하세요.","ERROR");
		return ;
	}else{
		if(opener){
			opener.twoFactorLogin($("#otpNumber").val(), otpUseTime);
		}else{
			parent.twoFactorLogin($("#otpNumber").val(), otpUseTime);
		}
	}
}

function onlyNumber(event){
	event = event || window.event;
	var keyID = (event.which) ? event.which : event.keyCode;
	if ( (keyID >= 48 && keyID <= 57) || (keyID >= 96 && keyID <= 105) || keyID == 8 || keyID == 46 || keyID == 37 || keyID == 39 || keyID == 13 ) 
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

function setOtpTimer(data){
	$("#otpMinute").text(data);
	$("#otpSecond").text("00");
	
	$("#otpTimeDiv").show();
	$("#otpTime").show();
	$("#otpMessage").hide();
	
	setOtpTime();
}

function setOtpTime(){
	var min = Number($("#otpMinute").text());
	var sec = Number($("#otpSecond").text());
	var timeoutID = setTimeout("setOtpTime()", 1000);
	
	if (sec === 0) {
		if (min === 0) {
			clearTimeout(timeoutID);
			$("#otpTime").hide();
			$("#otpMessage").show();
		} else {
			min--;
			sec = 59;
		}
	} else {
		sec--;
	}
	
	// format
	min = min === 0 ? "00" : min / 10 < 1 ? "0" + min : min;
	sec = sec === 0 ? "00" : sec / 10 < 1 ? "0" + sec : sec;
	
	$("#otpMinute").text(min);
	$("#otpSecond").text(sec);
}

$(function(){
	$("#otpNumber").keypress(function(e){
		if (e.keyCode==13){ otpCheck(); return false;}
	});
})

</script>