<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%-- <jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include> --%>

<% String appPath = PropertiesUtil.getGlobalProperties().getProperty("app.path"); %>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>

<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/common.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision/user_common_controls.css<%=resourceVersion%>" />  
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision/Controls.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/theme/blue.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/jquery-ui-1.12.1.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/survey/resources/css/survey.css<%=resourceVersion%>">

<script type="text/javascript" src="/covicore/resources/script/jquery.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/axisj/AXJ.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/Common.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/CommonControls.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/Utils.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.common.js<%=resourceVersion%>"></script>

<div class="layer_divpop surveryAllPop surveryAllPop03" style="width:100%">
	<div class="popContent">
		<div class="popTop">
			<p class="nonBg" style="padding-left: 0px;"><spring:message code='Cache.msg_fido04'/></p> <!-- 외부망으로 접속하였습니다.<br>추가인증(OTP, FIDO)이 필요합니다.  -->
		</div>
		<div class="popMiddle " style="height:90px;">
			<div class="grayBox">
				<p><span><spring:message code='Cache.lbl_externalAccess'/></span></p> <!-- 외부망 접속  -->
			</div>					
		</div>
		<div class="popBottom">
			<a id="btnOTPAuth" onclick="selectBtn('OTP'); return false;" class="btnTypeDefault btnTypeBg"><spring:message code='Cache.lbl_otpAuth'/><!-- OTP 인증 --></a>
			<a id="btnFIDOAuth" onclick="selectBtn('FIDO'); return false;" class="btnTypeDefault btnTypeBg" ><spring:message code='Cache.lbl_fidoAuth'/><!-- FIDO 인증 --></a>
		</div>
	</div>
</div>	

<script  type="text/javascript">
//# sourceURL=AuthWarningPopup.jsp

function selectBtn(val){
	if(opener){
		opener.callBackSelectAuth(val);
		opener.Common.close('authwarning');
	}else{
		parent.callBackSelectAuth(val);
		parent.Common.close('authwarning');
	}
}


</script>