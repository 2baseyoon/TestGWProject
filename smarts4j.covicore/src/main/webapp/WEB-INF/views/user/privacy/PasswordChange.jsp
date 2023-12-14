<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil,egovframework.baseframework.util.SessionHelper,egovframework.coviframework.util.DicHelper" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<%
	String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path");

	String cryptoType = (String)request.getAttribute("cryptoType");

	// for AES ecryption
	String as = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.salt"));
	String aI = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.iv"));
	String ak = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.keysize"));
	int ac = Integer.parseInt(PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.iterationCount")));
	int app = Integer.parseInt(PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.passPhrase")));
		
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>

<% if("R".equals(cryptoType)){ %>
	<script type="text/javascript" src="/covicore/resources/script/security/jsbn.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/security/rsa.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/security/prng4.js<%=resourceVersion%>"></script>
	<script type="text/javascript" src="/covicore/resources/script/security/rng.js<%=resourceVersion%>"></script>
<% }else if("A".equals(cryptoType)){ %>
	<script type="text/javascript" src="/covicore/resources/script/security/AesUtil.js"></script>
	<script type="text/javascript" src="/covicore/resources/script/security/aes.js"></script>
	<script type="text/javascript" src="/covicore/resources/script/security/pbkdf2.js"></script>
<% }%>
<style type="text/css">
input[type=password]::-ms-clear {
   display: none;
}
input[type=password]::-ms-reveal {
   display: none;
}
</style>
<input type="hidden" id="rsaPublicKeyModulus" value="${publicKeyModulus}">
<input type="hidden" id="rsaPublicKeyExponent" value="${publicKeyExponent}">

<div class="cRConTop titType">
	<h2 class="title"><spring:message code='Cache.lbl_ChangePassword'/></h2>
</div>
<div class="cRContBottom mScrollVH" id="passwordChangeDiv">
<form method="post" id="frm">	
	<div class="myInfoContainer myInfoPassWordCont">
	<%
		String initialConnection = SessionHelper.getSession("UR_InitialConnection");
		String passMaxDate = SessionHelper.getSession("UR_PassMaxDate");
		String passUseDate = SessionHelper.getSession("UR_PassUseDate");
		

		if (initialConnection.equals("Y")){
			out.println("<p><span class=\"blueStart\" style=\"color:red\">"+DicHelper.getDic("msg_firstLogin")+"</span></p>");
		}
		else if (passUseDate != null && !"".equals(passUseDate)){
			out.println("<p><span class=\"blueStart\" style=\"color:red\">"+DicHelper.getDic("msg_ExpiredNoticePage").replace("{0}",passUseDate).replace("{1}",passMaxDate)+"</span></p>");
		}
	%>
		<div class="mt50 myInfoPassWordModify">
			<input type="password" autocomplete="off" onkeypress="if (event.keyCode==13){ updateUserPassword(); return false;}" placeholder="<spring:message code='Cache.lbl_PasswordChange_01'/>" id="nowPassword">
		</div>
		<div class="mt30 myInfoPassWordModify">
			<input type="password" autocomplete="off" onkeypress="if (event.keyCode==13){ updateUserPassword(); return false;}" placeholder="<spring:message code='Cache.lbl_PasswordChange_02'/>" id="newPassword">
			<i class="fa fa-eye fa-lg" style="position: absolute; left: calc(50% + 148px); top: 175px; text-align: right; display: none;"></i> <!-- 상단 구조 변경 시 눈 아이콘 top 인라인 수정 필요 -->
		</div>
 		<div class="mt10 myInfoPassWordModify">
			<input type="password" autocomplete="off" onkeypress="if (event.keyCode==13){ updateUserPassword(); return false;}" placeholder="<spring:message code='Cache.lbl_PasswordChange_03'/>" id="newRePassword">
		</div>
		<div class="mt20 myInfoPassWordModify">
			<a href="#" class="btnType01" onclick="updateUserPassword()"><spring:message code='Cache.btn_PasswordChange_01'/></a>
		</div>
		<p class="mt65"><span class="blueStart" id="changePwHelpText"></span></p>
		<p><span class="blueStart"><spring:message code='Cache.msg_ChangePasswordDSCR05'/></span></p>
		<p><span class="blueStart"><spring:message code='Cache.lbl_PasswordChange_07'/></span></p>
	</div>
</form>			
</div>

<script type="text/javascript" src="/groupware/resources/script/user/privacy.js<%=resourceVersion%>"></script>
<script type="text/javascript">
	var cryptoType = "<%=cryptoType%>";
	var privacy_level = "${IsUseComplexity}";
	var privacy_len = "${MinimumLength}";
	var privacy_specialCharater = "${SpecialCharacterPolicy}";
	var npa = "${NPA}";
	
	$(function(){					
		if(npa == "Y"){
			Common.Inform("<spring:message code='Cache.msg_init_pwChangePage'/>");
		}

		setHelpText();
		
		$('#newPassword').on('change keydown keyup kepress', function(){
			if (this.value == ''){
				$('#passwordChangeDiv i').hide();
			}
			else {
				$('#passwordChangeDiv i').show();
			}
		})
		
		$('#passwordChangeDiv i').on('mousedown',function(){
			$(this).attr('class',"fa fa-eye-slash fa-lg")
            .prev('input').attr('type',"text");
	    });
		
		$('#passwordChangeDiv i').on('mouseup',function(){
			$(this).attr('class',"fa fa-eye fa-lg")
            .prev('input').attr('type','password');
	    });
	});
	
	
	// 변경
	function updateUserPassword() {
	 	var nowPassword = ""; 
		var newPassword = "";
		
		if(!validation()){
			return;
		}
		
		if(cryptoType == "R"){
			var rsaPublicKeyModulus = $("#rsaPublicKeyModulus").val();
			var rsaPublicKeyExponent = $("#rsaPublicKeyExponent").val();
			
			nowPassword = fnRsaEnc($("#nowPassword").val(), rsaPublicKeyModulus, rsaPublicKeyExponent);
			newPassword = fnRsaEnc($("#newPassword").val(), rsaPublicKeyModulus, rsaPublicKeyExponent);
			
		}else if(cryptoType == "A"){
			
			 var aesUtil = new AesUtil("<%=ak%>", "<%=ac%>");
			 
			 nowPassword = aesUtil.encrypt("<%=as%>", "<%=aI%>", "<%=app%>", $("#nowPassword").val());
			 newPassword = aesUtil.encrypt("<%=as%>", "<%=aI%>", "<%=app%>", $("#newPassword").val());
				
		}else{
			nowPassword = $("#nowPassword").val();
			newPassword = $("#newPassword").val();
		}
		
		var url = "/covicore/updateUserPassword.do";
		
		$.ajax({
			type : "POST",
			data : {newPassword : newPassword, nowPassword: nowPassword},
			async: false,
			url : url,
			success:function (response) {
				if (response.status == 'SUCCESS') {
					Common.Inform("<spring:message code='Cache.msg_Edited'/>", "", function(){
						location.href = "/groupware/layout/privacy_DefaultSetting.do?CLSYS=privacy&CLMD=user&CLBIZ=Privacy";
					});
				} else if(response.status == 'NOT_ALLOW'){
					Common.Warning(response.message);
				} else {
					Common.DetailErrPwMsg("<spring:message code='Cache.msg_OccurError'/>"+"<br/><br/>"+response.message,"Detail Info","Password Change");
				}
			},
			error:function(response, status, error) {
				CFN_ErrorAjax(url, response, status, error);
			}
		});
	}
	
	function fnRsaEnc(value, rsaPublicKeyModulus, rsaPpublicKeyExponent) {
		
	    var rsa = new RSAKey();

	    rsa.setPublic(rsaPublicKeyModulus, rsaPpublicKeyExponent);
	    var encValue = rsa.encrypt(value)
	    
	    return encValue;

	}	
	
	function validation(){
		var flag = false;
		
		var regex  = "";
		
		var len = "";
		
		if(privacy_len == null || privacy_len == ""){
			len = 10;
		}else{
			len = parseInt(privacy_len);
		}
		
		if ($("#nowPassword").val() == ""){
			Common.Warning("<spring:message code='Cache.msg_PasswordChange_03'/>", "", function(){ //현재 비밀번호를 입력하여 주십시오.
				$("#nowPassword").focus();
			});
			return flag;
		}
		
		if ($("#newPassword").val() == "") {
			Common.Warning("<spring:message code='Cache.msg_PasswordChange_04'/>", "", function(){ //새 비밀번호를 입력하여 주십시오.
				$("#newPassword").focus();
			});
			return flag;
		}

		if ($("#nowPassword").val() == $("#newPassword").val()){
			Common.Warning("<spring:message code='Cache.msg_PasswordChange_19'/>", "", function(){ //사용중인 패스워드와 변경하실 패스워드가 같습니다.
				$("#newPassword").focus();
			});
			return flag;
		}
		
		
		if ($("#newRePassword").val() == "") {
			Common.Warning("<spring:message code='Cache.msg_Mail_PleaseEnterPassword'/>", "", function(){ //비밀번호를 입력하여 주십시오.
				$("#newRePassword").focus();
			});
			return flag;
		} 	
		
		if ($("#newPassword").val() != $("#newRePassword").val()) {
			Common.Warning("<spring:message code='Cache.msg_PasswordChange_05'/>", "", function(){ //새 비밀번호와 비밀번호 확인이 일치하지 않습니다.
				$("#newRePassword").focus();
			});
			return flag;
		} 
		
		if ($("#newRePassword").val().indexOf("|") > -1){
			Common.Warning(String.format("<spring:message code='Cache.msg_noEnter_specialCharacterPolicy'/>", "|(pipeline)"), "", function(){ /* {0} 특수문자는 사용할 수 없습니다 */ 
				$("#newRePassword").focus();
			});
			return flag;
		}
		/* 서버에서 체크
		if(!pwPolicy.isPwLevel("newPassword", privacy_level, len)){
			return false;
		}
		
		if(!pwPolicy.isPwLevel("newPassword", "0", len)){
			return false;
		}
		
		if(!pwPolicy.isPwContinuous("newPassword")){
			
			return false;
		}
		*/
		return true;
	} 
	
	function setHelpText(){
		var text = "";		
		var len = "";
		
		if(privacy_len == null || privacy_len == ""){
			len = 10;
		}else{
			len = parseInt(privacy_len);
		}
		
		if(privacy_level == "1"){
			//최소 {0}자 이상/영문 문자, 숫자 각각 1개 이상 조합하여 사용
			text = "<spring:message code='Cache.msg_ChangePasswordDSCR08'/>".replace("{0}", len); 
		}else if(privacy_level == "2"){	
			//최소 {0}자 이상/영문 문자, 숫자, 특수문자 각각 1개 이상 조합하여 사용
			text = "<spring:message code='Cache.msg_ChangePasswordDSCR07'/>".replace("{0}", len);
		}else if(privacy_level == "3"){	
			//최소 {0}자 이상/영문 대소문자, 숫자, 특수문자 각각 1개 이상 조합하여 사용
			text = "<spring:message code='Cache.msg_ChangePasswordDSCR06'/>".replace("{0}", len);
		}else{
			//최소 {0}자 이상 조합하여 사용
			text = "<spring:message code='Cache.msg_ChangePasswordDSCR09'/>".replace("{0}", len);
		}
		
		$("#changePwHelpText").text(text);
		
		if(privacy_level == "2" || privacy_level == "3"){	
			//다음 특수문자 중 하나를 포함 {0}
			$("#changePwHelpText").parent().after("<p><span class=\"blueStart\">" + Common.getDic('msg_allowSpecialChar').replace('{0}', privacy_specialCharater) + "</span></p>");
		}
	}
	
	
</script>
