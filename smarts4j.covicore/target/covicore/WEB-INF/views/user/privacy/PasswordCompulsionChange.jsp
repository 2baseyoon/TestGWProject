<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil,egovframework.baseframework.util.SessionHelper,egovframework.coviframework.util.DicHelper" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% String cryptoType = PropertiesUtil.getSecurityProperties().getProperty("cryptoType"); %>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<% String appPath = PropertiesUtil.getGlobalProperties().getProperty("app.path"); %>

<% String home = PropertiesUtil.getGlobalProperties().getProperty("MainPage.path"); %>


<% String as = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.salt")); %>
<% String aI = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.iv")); %>
<% String ak = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.keysize")); %>
<% int ac = Integer.parseInt(PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.iterationCount"))); %>
<% int app = Integer.parseInt(PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.passPhrase"))); %>

<% String pl = PropertiesUtil.getSecurityProperties().getProperty("privacy.auth.level"); %>
<% String plen = PropertiesUtil.getSecurityProperties().getProperty("privacy.length"); %>

<% 
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

<link rel="stylesheet" type="text/css" href="/covicore/resources/css/font-awesome-4.7.0/css/font-awesome.min.css<%=resourceVersion%>">

<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision.control.css<%=resourceVersion%>" />	
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/common.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision/user_common_controls.css<%=resourceVersion%>" />  
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision/Controls.css<%=resourceVersion%>" />
<link rel="stylesheet" id="themeCSS" type="text/css" href="<%=cssPath%>/covicore/resources/css/theme/blue.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/myInfo/resources/css/myInfo.css<%=resourceVersion%>" />

<script type="text/javascript" src="/covicore/resources/script/jquery.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/typed.js<%=resourceVersion%>"></script>
<script	type="text/javascript" src="/covicore/resources/script/bootstrap.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/jquery-ui-1.12.1.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/axisj/AXJ.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/CommonControls.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/Common.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/idle-timer.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/Utils.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.common.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.dic.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.control.js<%=resourceVersion%>"></script>

<style type="text/css">
.myInfoViewList {
    position: initial;
    top: 58px;
    left: 0;
    display: none;
    width: 183px;
    background: #fff;
    border: 1px solid #e2e2e2;
    box-shadow: 0 3px 10px 0 rgba(0, 0, 0, 0.2);
    z-index: 2;
}
input[type=password]::-ms-clear {
   display: none;
}
input[type=password]::-ms-reveal {
   display: none;
}
</style>

<input type="hidden" id="rsaPublicKeyModulus" value="${publicKeyModulus}">
<input type="hidden" id="rsaPublicKeyExponent" value="${publicKeyExponent}">

<div class="cRConTop titType" style="z-index: 10;">
	<div id="myInfoContainer" class="myInfo" style="float: right;line-height: 55px; margin-right: 0;">
		<div id="infoViewDiv">	
		</div>
		<ul id="myInfoViewList" class="myInfoViewList">	
			<li>
				<p id="logoutATag">
				</p>	
			</li>
		</ul>
	</div>
</div>
<div class="cRContBottom mScrollVH" id="passwordChangeDiv">
	<div class="myInfoContainer myInfoPassWordCont">
		<p><span class="blueStart" style="color:red">
		<%
			String initialConnection = SessionHelper.getSession("UR_InitialConnection");
			String passMaxDate = SessionHelper.getSession("UR_PassMaxDate");
			String passUseDate = SessionHelper.getSession("UR_PassUseDate");
			
			if (initialConnection.equals("Y")){
				out.println(DicHelper.getDic("msg_firstLogin"));
			}
			else if (passUseDate != null && !passUseDate.equals(""))
				out.println(DicHelper.getDic("msg_ExpiredNoticePage").replace("{0}",passUseDate).replace("{1}",passMaxDate));
			else if (SessionHelper.getExtensionSession(SessionHelper.getSession("UR_ID")+"_PSM","UPCMD").equals("Y"))
				out.println(DicHelper.getDic("msg_initPwdPage"));
		%>
		</span></p>
		<h2 class="title" style="font-size: 24px;font-weight: 700;font-family: sans-serif, 'Nanum Gothic','맑은 고딕', 'Malgun Gothic';line-height: 57px;"><spring:message code='Cache.lbl_ChangePassword'/></h2>
		<div class="mt30 myInfoPassWordModify">
			<input type="password" placeholder="<spring:message code='Cache.lbl_PasswordChange_01'/>" id="nowPassword">
		</div>
		<div class="mt30 myInfoPassWordModify">
			<input type="password" placeholder="<spring:message code='Cache.lbl_PasswordChange_02'/>" id="newPassword">
			<i class="fa fa-eye fa-lg" style="position: absolute; left: calc(50% + 148px); top: 204px; text-align: right; display: none;"></i> <!-- 상단 구조 변경 시 눈 아이콘 top 인라인 수정 필요 -->
		</div>
 		<div class="mt10 myInfoPassWordModify">
			<input type="password" placeholder="<spring:message code='Cache.lbl_PasswordChange_03'/>" id="newRePassword">
		</div>
		<div class="mt20 myInfoPassWordModify">
			<a href="#" class="btnType01" onclick="updateUserPassword()"><spring:message code='Cache.btn_PasswordChange_01'/></a>
		</div>
		<p class="mt65"><span class="blueStart" id="changePwHelpText"></span></p>
		<p><span class="blueStart"><spring:message code='Cache.msg_ChangePasswordDSCR05'/></span></p>
		<p><span class="blueStart"><spring:message code='Cache.lbl_PasswordChange_07'/></span></p>
	</div>
</div>
<script type="text/javascript" src="/groupware/resources/script/user/privacy.js<%=resourceVersion%>"></script>
<script type="text/javascript">
	var cryptoType = "<%=cryptoType%>";
	var privacy_level = "${IsUseComplexity}";
	var privacy_len = "${MinimumLength}";
	var privacy_specialCharater = "${SpecialCharacterPolicy}";
	var home = "<%=home%>";
	var myInfoData = ${myInfoData};
	
	Common.Inform("<spring:message code='Cache.msg_init_pwChangePage'/>");

	$(function(){
		var sessionLang = "${lang}";
		var localDictionary = {
				logout : '로그아웃;Sign out;ログアウト;注销;;;;;;'
		};
		
		var detpNm = "";
		for(var i=0;i<myInfoData["baseGroupInfo"].length;i++){
			if(Object.keys(myInfoData["baseGroupInfo"][i])[0] == "detpNm"){
				detpNm = Object.values(myInfoData["baseGroupInfo"][i])[0];
			}
		} 
		
 		var html = '';
		html += '<a class="myInfoViewBtn" onclick="javascript:toggleMenu();">';
		html += '	<div class="photo">';
		html += '		<img id="userImg" src="'+myInfoData.photoPath+'" onerror="coviCmn.imgError(this);" alt="ProfilePhoto">';
		html += '	</div>';
		html += '	<p class="dep">';
		html += '		<strong>'+myInfoData.name+'</strong> <span>'+detpNm+'</span>';
		html += '	</p>';
		html += '	<article class="myInfoView">';
		html += '		<span class="myInfoViewCont">내정보보기</span>';
		html += '	</article>';
		html += '</a>';
		
		$("#infoViewDiv").html(html);
		
		html = '<a href="javascript:;" onclick="XFN_LogOut();">' + CFN_GetDicInfo(localDictionary.logout, sessionLang) + '</a>';
		
		$("#logoutATag").html(html);
		
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
		
		
		$.ajax({
			type : "POST",
			data : {newPassword : newPassword, nowPassword: nowPassword},
			async: false,
			url : "/covicore/updateUserPassword.do",
			success:function (list) {
				
				if (list.status == 'SUCCESS') {
					Common.Inform("<spring:message code='Cache.msg_Edited'/>", "", function(){
						location.href = "/groupware/layout/privacy_DefaultSetting.do?CLSYS=privacy&CLMD=user&CLBIZ=Privacy";
					});
				} else if(list.status == 'NOT_ALLOW'){
					Common.Warning(list.message);
				}else{	
					Common.DetailErrPwMsg("<spring:message code='Cache.msg_OccurError'/>"+"<br/><br/>"+list.message,"Detail Info","Password Change");
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
			Common.Inform("<spring:message code='Cache.msg_PasswordChange_03'/>", "Information Dialog", function(result) {
				return flag;	
			});
		}
		
		if ($("#nowPassword").val() == $("#newPassword").val()){
			Common.Inform("<spring:message code='Cache.msg_PasswordChange_19'/>", "Information Dialog", function(result) {
				return flag;	
			});
		}
		
		if ($("#newPassword").val() == "") {
			Common.Inform("<spring:message code='Cache.msg_PasswordChange_04'/>", "Information Dialog", function(result) {
				return flag;	
			});
		}
		
		if ($("#newRePassword").val() == "") {
			Common.Inform("<spring:message code='Cache.msg_Mail_PleaseEnterPassword'/>", "Information Dialog", function(result) {
				return flag;	
			});
		} 	
		
		if ($("#newPassword").val() != $("#newRePassword").val()) {
			Common.Inform("<spring:message code='Cache.msg_PasswordChange_05'/>", "Information Dialog", function(result) {
				return flag;	
			});
		} 
		
		if ($("#newRePassword").val().indexOf("|") > -1){
			Common.Warning(String.format("<spring:message code='Cache.msg_noEnter_specialCharacterPolicy'/>", "|(pipeline)"), "", function(){ /* {0} 특수문자는 사용할 수 없습니다 */ 
				$("#newRePassword").focus();
			});
			return flag;
		}
	
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
			text = "<spring:message code='Cache.msg_ChangePasswordDSCR08'/>".replace("{0}", len);
		}else if(privacy_level == "2"){	
			text = "<spring:message code='Cache.msg_ChangePasswordDSCR07'/>".replace("{0}", len);
		}else if(privacy_level == "3"){	
			text = "<spring:message code='Cache.msg_ChangePasswordDSCR06'/>".replace("{0}", len);
		}else{
			text = "<spring:message code='Cache.msg_ChangePasswordDSCR09'/>".replace("{0}", len);
		}
		
		$("#changePwHelpText").text(text);
		
		if(privacy_level == "2" || privacy_level == "3"){	
			//다음 특수문자 중 하나를 포함 {0}
			$("#changePwHelpText").parent().after("<p><span class=\"blueStart\">" + Common.getDic('msg_allowSpecialChar').replace('{0}', privacy_specialCharater) + "</span></p>");
		}
	}
	
	function toggleMenu(){
		if($("#myInfoContainer").hasClass('active')){
			$("#myInfoContainer").removeClass('active');
		} else {
			$("#myInfoContainer").addClass('active');
		} 
	}
</script>
