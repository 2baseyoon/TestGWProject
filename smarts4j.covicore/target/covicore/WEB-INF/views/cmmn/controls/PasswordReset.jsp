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
<script type="text/javascript" src="/covicore/resources/script/autosize.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/Dictionary.js<%=resourceVersion%>"></script>

<script type="text/javascript" src="/covicore/resources/script/palette-color-picker.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Jsoner/Jsoner.0.8.2.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/slick.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/jquery.slimscroll.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/html2canvas.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/clipboard.min.js<%=resourceVersion%>"></script>

<div class="layer_divpop">
	<div class="popContent">
		<div class="loginPopContainer loginPassWordCont">
			<div class="top">
				<h2><span id="pwReOption"></span></h2>
				<select class="selectType02" id="validationType" style="display:none;">
					<option value="Email"></option>
				</select>
			</div>			
			<div class="middle mt20">
				<div class="inputBoxSytel01 type03">
					<div><span id="userId"></span></div>
					<div>								
						<input type="text" id="pwChangeId" />
					</div>
				</div>
				<div class="inputBoxSytel01 type03">
					<div><span id="userName"></span></div>
					<div>								
						<input type="text" id="pwChangeNm"/> 
					</div>
				</div>
				<div class="inputBoxSytel01 type03">
					<div><span id="userExMail"></span></div>
					<div>								
						<input type="text" id="pwChangeMail"/> 
						<div class="mt10"><span class="blueStart"><span class="eNoti"></span></span></div>
					</div>
				</div>
				<div class="inputBoxSytel01 type03">
					<div><span id="ReMedium"></span></div>
					<div class="chkBoxH txtBox">																
						<div class="chkStyle01 ">
							<input type="checkbox" id="allSV01" name="allSV"><label for="allSV01" id="labelMobilePush"><span></span></label>
						</div> 
						<div class="chkStyle01 ">
							<input type="checkbox" id="allSV02" name="allSV"><label for="allSV02" id="labelUserExMail"><span></span></label>
							</div>
					</div>
				</div>
				<p class="mt10 "><span class="blueStart" id="sendNoti"></span></p>
			</div>
			<div class="bottom mt20">						
				<a class="btnTypeDefault btnTypeBg" id="btnConfirm"></a>
				<a class="btnTypeDefault" id="btnClose" onclick="Common.Close();"></a>
			</div>
		</div>
	</div>
</div>	

<script  type="text/javascript">
var cryptoType = "${cryptoType}";
var lang = "${lang}";
var dicData = {};
var isOtpSend = false;

$(document).ready(function (){		
	var jsonData = {};
	jsonData["locale"] = lang;
	var pKeys = "lbl_pwReOption;lbl_PasswordReset_UserId;lbl_PasswordReset_UserName;lbl_PasswordReset_ExMail;lbl_PasswordReset_eNoti";
	pKeys += ";lbl_PasswordReset_ReMedium;lbl_PasswordReset_MobilePush;lbl_PasswordReset_SendNoti;btn_Confirm;btn_Confirm;btn_Close";
	pKeys += ";msg_PasswordReset_Confirm;msg_PasswordReset_Retransmitted;msg_PasswordReset_AuthKind;msg_otp_FailCount;msg_PasswordReset_NotFound";
	pKeys += ";msg_ErrorOccurred;msg_otp_resend;msg_enter_ID;msg_EnterName;msg_PasswordReset_EnterExMail;msg_PasswordReset_SelectMedium;msg_FailedToSend";
	pKeys += ";msg_SendQ;msg_otp_retry;msg_otp_incorrect;lbl_otp_expiredTime;lbl_otp;btn_otp_send;msg_otp_sendNoti;msg_otp_send;msg_otp_request;msg_otp_expired_resend;msg_otp_expired";
		
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
	
	$("#pwReOption").text(dicData["lbl_pwReOption"]);			// 비밀번호 재설정
	$("#userId").text(dicData["lbl_PasswordReset_UserId"]); 	// 아이디
	$("#userName").text(dicData["lbl_PasswordReset_UserName"]); // 이름
	$("#userExMail").text(dicData["lbl_PasswordReset_ExMail"]);	// 외부메일
	$(".eNoti").text(dicData["lbl_PasswordReset_eNoti"]);		// 개인정보에 등록한 외부메일
	$("#ReMedium").text(dicData["lbl_PasswordReset_ReMedium"]);	// 수신매체
	$("#labelMobilePush").empty().append("<span></span>" + dicData["lbl_PasswordReset_MobilePush"]); // 모바일 푸시
	$("#labelUserExMail").empty().append("<span></span>" + dicData["lbl_PasswordReset_ExMail"]); // 외부메일
	$("#btnClose").text(dicData["btn_Close"]);	// 닫기
	
	checkOTP();
});

function setAccessPw(){
	if(!validation()){
		return;
	}
	
	var params = setParam()
	params.otpNo = $("#otpNo").val();
	params.otpUseTime = (parseInt($("#otpMinute").text())+ parseInt($("#otpSecond").text()));
	
	
	Common.Confirm(dicData["msg_PasswordReset_Confirm"], "Confirmation Dialog", function (confirmResult) { // 비밀번호 재설정을 하시겠습니까?
		if (confirmResult) {
			$.ajax({
				type: "POST",
				data: params,
				url: "/covicore/control/changePassword.do",
				success:function (data) {
					if(data.status == 'SUCCESS') {
						Common.Inform(dicData["msg_PasswordReset_Retransmitted"], "Inform", function() { // 패스워드가 재전송 되었습니다.
						 	Common.Close("target_pop");
							parent.location.href='/covicore/login.do';
						});
		          	} else {
		          		if(data.code == "ere"){
		          			Common.Warning(dicData["msg_PasswordReset_AuthKind"],"ERROR"); // 인증방식을 선택하세요.
		          		}else if(data.code == "eru" ){
		          			Common.Warning(dicData["msg_PasswordReset_NotFound"],"ERROR"); // 일치하는 사용자 정보가 없습니다.
		          		}else if(data.code == "erp" ){
		          			Common.Warning(dicData["msg_ErrorOccurred"],"ERROR"); // 오류가 발생하였습니다.
		          		}else if(data.code == "erf" ){
		          			Common.Warning(dicData["msg_ErrorOccurred"],"ERROR"); // 오류가 발생하였습니다.
		          		}else if(data.code == "ero" ){
		          			if(data.failcount == 0){
		          				Common.Warning(dicData["msg_otp_expired_resend"]);
		          			}else if(data.failcount <= data.baseFailCount)
		          				Common.Warning(dicData["msg_otp_incorrect"] + "<br>" + dicData["msg_otp_FailCount"]+ " : "+ data.failcount + " / " + data.baseFailCount ,"ERROR"); // 인증번호가 올바르지 않습니다.
		          			else {
		          				Common.Warning(dicData["msg_otp_resend"], "ERROR", function(){
		          					Common.Close("target_pop");
		          					parent.location.href='/covicore/login.do';
		          				});
		          			}
		          		}else{
		          			Common.Warning(dicData["msg_ErrorOccurred"],"ERROR"); // 오류가 발생하였습니다.
		          		}
		          	}
				},
				error:function(response, status, error) {
					CFN_ErrorAjax(url, response, status, error);
				}
			});
			
		}
	 });
	// 보낼땐 암호화 처리 
	// ID,PW,인증방법,수신매체,인증방법 값 Clinet >> 
}

function checkOTP(data){
	$(".loginPassWordCont input").prop("disabled", isOtpSend);
	if (isOtpSend){
		$("#sendNoti").text(dicData["lbl_PasswordReset_SendNoti"]);	// 지정한 매체로 초기화된 비밀번호가 발송됩니다.
		$("#btnConfirm").text(dicData["btn_Confirm"]);
		$("#btnConfirm").attr("onclick", "javascript:setAccessPw();");
		$(".loginPopContainer .middle .inputBoxSytel01:last").after(
			'<div class="inputBoxSytel01 type03 otpNumberDiv">'+
			'	<div><span>'+dicData["lbl_otp"]+'</span></div>'+
			'	<div>			'+					
			'		<input type="text" id="otpNo"> '+
			'	</div>'+
			'</div>'+
			'<div id="otpTimeDiv" class="inputBoxSytel01 type03 otpNumberDiv" style="display: none;">'+
			'	<div><span>'+dicData["lbl_otp_expiredTime"]+'</span></div>'+
			'	<div id="otpTime">'+
			'		<span id="otpMinute"></span>:<span id="otpSecond"></span>'+
			'	</div>'+
			'	<div id="otpMessage" style="display: none; color: red; font-weight: 700;">'+dicData["msg_otp_expired"]+'</div>'+
			'</div>'
		);
		parent.Common.toResize("PasswordReset", "520px", "550px");
		setOtpTimer(data);
	}
	else {
		$("#sendNoti").text(dicData['msg_otp_sendNoti']);	// 지정한 수신매체로 인증번호가 발송됩니다.
		$("#btnConfirm").text(dicData["btn_otp_send"]);			// OTP 발송
		$("#btnConfirm").attr("onclick", "javascript:sendOTP();");
		$(".otpNumberDiv").remove();
	}
}

function sendOTP(){
	// otp 발송 처리
	if(!validation()){
		return;
	}

	var params = setParam();
	params.logType = 'passwordReset';
	
	Common.Confirm(dicData["msg_SendQ"], "Confirmation Dialog", function (confirmResult) { // 발송하시겠습니까?
		if (confirmResult) {
			$.ajax({
				method: "POST",
			    data: params,
				url: "/covicore/control/sendTwoFactor.do",
				success:function (data) {
					 if(data.result =="SUCCESS"){
						Common.Inform(dicData["msg_otp_send"], "Inform");		// 인증 번호가 발송되었습니다.
						isOtpSend = true;
						checkOTP(data.otp);
					 }
					 else{
						 if (data.code == 'eru'){
							 Common.Warning(dicData["msg_PasswordReset_NotFound"],"ERROR"); // 일치하는 사용자 정보가 없습니다.
						 } else if (data.code == 'wait'){
							 var min;
							 var sec;
							 if(data.diff < 60){
								min = 0;
								sec = data.diff;
							 } else {
								 min = parseInt(data.diff / 60);
								 sec = data.diff - (min*60);
							 }
							 Common.Warning(dicData["msg_otp_retry"].replace("{0}", min).replace("{1}", sec)); // {0}분 {1}초 후에 다시 시도하세요.
						 }
						 else {
							 Common.Warning(dicData["msg_FailedToSend"],"ERROR");			// 발송에 실패하였습니다.
						 }
					 }
				}
			}); 
		}
	});
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

function setParam(){
	return {
		validationType : $("#validationType").val(),
		smobile : ($("input:checkbox[id='allSV01']").is(":checked")) ? 'Y' : 'N',
		smail : ($("input:checkbox[id='allSV02']").is(":checked")) ? 'Y' : 'N', 
		id : $("#pwChangeId").val(),
		nm : $("#pwChangeNm").val(),
		emailAddress : $("#pwChangeMail").val()
	}
}

function validation(){
	var bReturn = true;
	var mobile = "";
	var mail = "";
	
	if ($("#validationType").val() == "") {
	    Common.Warning(dicData["msg_PasswordReset_AuthKind"]); // 인증방법을 선택하세요.
	   	bReturn = false;
	    return bReturn;
	}
	
	if ($("#pwChangeId").val() == "") {
	 	Common.Warning(dicData["msg_enter_ID"], "Warning", function(){ // 아이디를 입력하세요.
	 		$("#pwChangeId").focus();
	 	});
	 	bReturn = false;
	 	return bReturn;
	}
	
	if ($("#pwChangeNm").val() == "") {
		Common.Warning(dicData["msg_EnterName"], "Warning", function(){ // 이름을 입력하세요.
			$("#pwChangeNm").focus();
		});
	 	bReturn = false;
	 	return bReturn;
	}
	
	if ($("#pwChangeMail").val() == "") {
	 	Common.Warning(dicData["msg_PasswordReset_EnterExMail"], "Warning", function(){ // 외부메일을 입력하세요.
	 		$("#pwChangeMail").focus();
	 	});
	 	bReturn = false;
	 	return bReturn;
	}
	
	if($("input:checkbox[id='allSV01']").is(":checked")){
		mobile = 'Y';
	}else{
		mobile = 'N';
	}
	
	if($("input:checkbox[id='allSV02']").is(":checked")){
		mail = 'Y';
	}else{
		mail = 'N';
	}
	
	if (mobile == "N" && mail == "N") {
	 	bReturn = false;
	 	Common.Warning(dicData["msg_PasswordReset_SelectMedium"]); // 수신매체를 선택하세요.
	 	return bReturn;
	}
	
	if (isOtpSend && $("#otpNo").val() == "") {
		Common.Warning(dicData["msg_otp_request"], "Warning", function(){ // 인증번호를 입력하세요 
			$("#otpNo").focus();
		});
	 	bReturn = false;
	 	return bReturn;
	}
	
	return bReturn;
}

</script>