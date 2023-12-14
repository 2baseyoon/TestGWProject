
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@page import="egovframework.coviframework.util.SessionCommonHelper"%>
<%@page import="egovframework.baseframework.util.ClientInfoHelper"%>
<%@page import="egovframework.baseframework.util.RedisDataUtil"%>
<%@page import="egovframework.baseframework.data.CoviMap"%>

<% 
	org.apache.logging.log4j.Logger LOGGER = org.apache.logging.log4j.LogManager.getLogger(this);

	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
	String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path");
	String appPath = PropertiesUtil.getGlobalProperties().getProperty("app.path"); 
	String cryptoType = PropertiesUtil.getSecurityProperties().getProperty("cryptoType");
	String themeCode = SessionCommonHelper.getSession("UR_ThemeCode");
	String themeType = SessionCommonHelper.getSessionMapKey("PortalOption","mbTheme","purple") ;//SessionCommonHelper.getSession("UR_ThemeType");	
	String useWebhard = PropertiesUtil.getExtensionProperties().getProperty("isUse.webhard");	
	String useAccount =PropertiesUtil.getExtensionProperties().getProperty("isUse.account");
	String useMail = PropertiesUtil.getExtensionProperties().getProperty("isUse.mail");
	String useMobileTheme = RedisDataUtil.getBaseConfig("useMobileTheme");
	String mobileEditorType = RedisDataUtil.getBaseConfig("MobileEditorType");
	String mobileEditorTypeMail = RedisDataUtil.getBaseConfig("MobileEditorTypeMail");
	String mobileEditorTypeApproval = RedisDataUtil.getBaseConfig("MobileEditorTypeApproval");
	String useCrm = PropertiesUtil.getExtensionProperties().getProperty("isUse.crm");
	boolean isMobileApp = ClientInfoHelper.isMobileApp(request); 	
	String useTeamsAddIn = "N";
	
	String AttendanceMobileMapUsedYn = RedisDataUtil.getBaseConfig("AttendanceMobileMapUsedYn");
	String AttendanceMapApiType = RedisDataUtil.getBaseConfig("AttendanceMapApiType");
	String GoogleApiKey = RedisDataUtil.getBaseConfig("GoogleApiKey");
	String VMapApiKey = RedisDataUtil.getBaseConfig("VMapApiKey");

	//out.println("<script>var PARAM_VALID='"+  egovframework.baseframework.util.StringUtil.replaceNull(PropertiesUtil.getSecurityProperties().getProperty("param.valid"),"N")+"';</script>");	
	out.println("<script>");
	out.println("var PARAM_VALID='"+  egovframework.baseframework.util.StringUtil.replaceNull(PropertiesUtil.getSecurityProperties().getProperty("param.valid"),"N")+"';");
	out.println("var isMobile =true;");
	try {
		out.println("");
		
		String userAgent = request.getHeader("User-Agent");
		String pIsTeamsAddIn = request.getParameter("teamsaddin");
	    if ((userAgent != null && userAgent.toLowerCase().indexOf("teams") > -1) || (pIsTeamsAddIn != null && pIsTeamsAddIn.toUpperCase().equals("Y"))) {
	    	useTeamsAddIn = "Y";
	    	
	    	// Teams Add-In 구분용 변수
	    	out.println("var _IsTeamsAddIn=true;");
	    	
	    	// Teams Add-In 속도 개선을 위한 SessionData 처리
	    	out.println("try {");
	    	out.println("function setTeamsSessionData(sessionKey, sessionValue) {");
	    	out.println("var _TeamIsLocalStorage = true;");
	    	out.println("try {");
	    	out.println("sessionStorage.setItem('test', 'test');");
	    	out.println("sessionStorage.removeItem('test');");
	    	out.println("} catch(e) {");
	    	out.println("_TeamIsLocalStorage = false;");
	    	out.println("}");
	    	out.println("if (_TeamIsLocalStorage) {");
	    	out.println("sessionStorage.removeItem(sessionKey); var sessionStoragedItem = { _ : new Date().getTime(), data : sessionValue }; sessionStorage.setItem(sessionKey, JSON.stringify(sessionStoragedItem));");
	    	out.println("} else {");
	    	out.println("localCache.remove(sessionKey); localCache.data[sessionKey] = { _ : new Date().getTime(), data : value };");
	    	out.println("}");
	    	out.println("}");
	    	CoviMap sessionObj = SessionCommonHelper.getSession();
	    	java.util.Iterator arrKeys = sessionObj.keys();
	    	out.println("setTeamsSessionData(\"SESSION_all\", $.parseJSON(\"" + sessionObj.toJSONString().replace("\"", "\\\"") + "\"));");
			while (arrKeys.hasNext()) {
		        String sessionKey = arrKeys.next().toString();
		        //json 데이타 파싱 오류로 일부 데이타 제외 2023.04.26 김혜영
				if (!sessionKey.toLowerCase().equals("portaloption")){
			    	out.println("setTeamsSessionData(\"SESSION_" + sessionKey + "\", \"" + sessionObj.getString(sessionKey) + "\");");
				}	
			}
	    	out.println("} catch(ee) { }");
	    } else {
	    	out.println("var _IsTeamsAddIn=false;");
	    }
	} catch (NullPointerException e) {
		LOGGER.debug("teams error");
	} catch (Exception e) {
		LOGGER.debug("teams error");
	}

	out.println("</script>");
%>

<%
	if("Y".equals(AttendanceMobileMapUsedYn)){
		if("G".equals(AttendanceMapApiType)){
%>
	<script type="text/javascript" src="https://maps.googleapis.com/maps/api/js?key=<%=GoogleApiKey%>" async defer></script>
<%
		}else if("V".equals(AttendanceMapApiType)){
%>
	<script type="text/javascript" src="http://map.vworld.kr/js/vworldMapInit.js.do?version=2.0&apiKey=<%=VMapApiKey%>"></script>
	<script src="https://cdnjs.cloudflare.com/ajax/libs/proj4js/2.4.4/proj4.js"></script>
<%
		}
	}
%>



<!-- 모바일 공통 css -->
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/mobile/resources/css/common.css<%=resourceVersion%>" />

<% if(isMobileApp) { %>
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/mobile/resources/css/common_app.css<%=resourceVersion%>" />
<%}%>

<!-- 모바일 UI CSS 지우면 안됨. -->
<link rel="stylesheet" type="text/css" href="/covicore/resources/script/Mobile/temp.css<%=resourceVersion%>" />

<link rel="stylesheet" type="text/css" href="<%=cssPath%>/approval/resources/css/approval.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/common_m.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision/user_common_controls.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision.control.css<%=resourceVersion%>" />
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/webhard/resources/css/webhard.css<%=resourceVersion%>" />
<link rel="stylesheet" href="<%=cssPath%>/mobile/resources/css/collaboration.css<%=resourceVersion%>">

<% if ("Y".equals(useTeamsAddIn)) { %>
	<!-- Teams Add-In -->
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/mobile/resources/css/teams.css<%=resourceVersion%>" />
<% } else {%>

<!-- 모바일 테마 css (기본:blue) -->
<% if(themeType != null && !themeType.equals("") && useMobileTheme.equals("Y")){ %>
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/mobile/resources/css/theme/<%=themeType%>.css<%=resourceVersion%>" />
<% } else {%>
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/mobile/resources/css/theme/blue.css<%=resourceVersion%>" />
<% } %>

<% } %>

<% if(themeCode != null && !themeCode.equals("default")){ %>
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/customizing/mobile/<%=themeCode%>/resources/css/project.css<%=resourceVersion%>" />
	<%
	String themeColor= "color_01";
	if (themeType.equals("green")){
		themeColor= "color_02";
	}else if (themeType.equals("red")){		
		themeColor= "color_03";
	}else if (themeType.equals("black")){	
		themeColor= "color_04";
	}else if (themeType.equals("blue")){	
		themeColor= "color_05";
	}	
	%>		
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/customizing/mobile/<%=themeCode%>/resources/css/<%=themeColor%>.css<%=resourceVersion%>" />
<% } %>

 <!-- 신규 포털 및 레이아웃 소스 -->	<!-- 플러그인 -->
    <link rel="stylesheet" type="text/css" href="<%=cssPath%>/mobile/resources/plugins/swiper/swiper.min.css"/>
    <link rel="stylesheet" type="text/css" href="<%=cssPath%>/mobile/resources/plugins/simplebar/simplebar.css"/>
    
    <script type="text/javascript" src="<%=cssPath%>/mobile/resources/plugins/swiper/swiper.min.js"></script>
    <script type="text/javascript" src="<%=cssPath%>/mobile/resources/plugins/sortable/sortable.min.js"></script>
    <script type="text/javascript" src="<%=cssPath%>/mobile/resources/plugins/simplebar/simplebar.min.js"></script>
        
<!-- 공통 스타일 -->
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/mobile/resources/css/style.css"/>
<!-- Jquery -->
<script type="text/javascript" src="/covicore/resources/script/Mobile/jquery-1.11.3.js<%=resourceVersion%>"></script>
<!-- JqueryUI -->
<script type="text/javascript" src="/covicore/resources/script/Mobile/jquery-ui-1.12.1.min.js<%=resourceVersion%>"></script>
<!-- JqueryMobile -->
<script type="text/javascript" src="/covicore/resources/script/Mobile/jquery.mobile-1.4.5.min.js<%=resourceVersion%>"></script>
<!-- JqueryMobileTouch -->
<script type="text/javascript" src="/covicore/resources/script/Mobile/jquery.ui.touch-punch.min.js<%=resourceVersion%>"></script>

<!-- 모바일 공통 js -->
<script type="text/javascript" src="/covicore/resources/script/Mobile/mobile.common.js<%=resourceVersion%>"></script>
<!-- 퍼블리서 작업 js -->
<script type="text/javascript" src="/covicore/resources/script/Mobile/mobile.ui.js<%=resourceVersion%>"></script>

<% if("2".equals(mobileEditorType) || "2".equals(mobileEditorTypeMail) || "2".equals(mobileEditorTypeApproval)){ %>
<!-- 모바일 에디터 -->
	<script type="text/javascript" src="/covicore/resources/script/mobileeditor/mobile_editor.js<%=resourceVersion%>"></script>
<% }%>

<!-- 게시 js -->
<script type="text/javascript" src="/groupware/resources/script/mobile/board.js<%=resourceVersion%>"></script>

<!-- 조직도 js -->
<script type="text/javascript" src="/covicore/resources/script/Mobile/org/org.js<%=resourceVersion%>"></script>

<!-- 댓글 js -->
<script type="text/javascript" src="/covicore/resources/script/Mobile/comment/comment.js<%=resourceVersion%>"></script>

<!-- 설문 js -->
<script type="text/javascript" src="/groupware/resources/script/mobile/survey.js<%=resourceVersion%>"></script>

<!-- 일정 js -->
<script type="text/javascript" src="/groupware/resources/script/mobile/schedule.js<%=resourceVersion%>"></script>

<!-- 자원예약 js -->
<script type="text/javascript" src="/groupware/resources/script/mobile/resource.js<%=resourceVersion%>"></script>

<!-- 인명관리 js -->
<script type="text/javascript" src="/groupware/resources/script/mobile/bizcard.js<%=resourceVersion%>"></script>

<!-- 업무관리 js -->
<script type="text/javascript" src="/groupware/resources/script/mobile/task.js<%=resourceVersion%>"></script>

<!-- 포탈 js -->
<script type="text/javascript" src="/groupware/resources/script/mobile/portal.js<%=resourceVersion%>"></script>

<!-- 결재 js -->
<script type="text/javascript" src="/approval/resources/script/mobile/approval.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/approval/resources/script/mobile/approval_common.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/approval/resources/script/mobile/approval_form.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/approval/resources/script/mobile/approval_formapvline.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/approval/resources/script/mobile/approval_fido.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/approval/resources/script/mobile/approval_signature.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/approval/resources/script/mobile/mobile_approval.common.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/approval/resources/script/user/ApprovalListCommon.js<%=resourceVersion%>"></script>
<% if("R".equals(cryptoType)){ %>
	<script type="text/javascript" src="<%=appPath%>/resources/script/security/jsbn.js"></script>
	<script type="text/javascript" src="<%=appPath%>/resources/script/security/rsa.js"></script>
	<script type="text/javascript" src="<%=appPath%>/resources/script/security/prng4.js"></script>
	<script type="text/javascript" src="<%=appPath%>/resources/script/security/rng.js"></script>
<% }%>
<!-- 전자결재 구간암호화시 AES사용 -->
<script type="text/javascript" src="<%=appPath%>/resources/script/security/AesUtil.js"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/security/aes.js"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/security/pbkdf2.js"></script>

<!-- 휴가관리 js -->
<script type="text/javascript" src="/groupware/resources/script/mobile/vacation.js<%=resourceVersion%>"></script>

<!-- 커뮤니티 js -->
<script type="text/javascript" src="/groupware/resources/script/mobile/community.js<%=resourceVersion%>"></script>

<!-- 근태관리 js -->
<%--<script type="text/javascript" src="/groupware/resources/script/mobile/attendance.js"></script>--%>
<script type="text/javascript" src="/groupware/resources/script/mobile/new_attendance.js<%=resourceVersion%>"></script>

<% if(useMail != null && useMail.equals("Y")){ %>
	<!-- 메일 js -->
	<script type="text/javascript" src="/mail/resources/script/mobile/mail.js<%=resourceVersion%>"></script>
<% } %>
<% if(useAccount != null && useAccount.equals("Y")){ %>
	<!-- e-Accounting js -->
	<script type="text/javascript" src="/account/resources/script/mobile/account.js<%=resourceVersion%>"></script>
<% } %>
<% if(useWebhard != null && useWebhard.equals("Y")){ %>
	<!-- webhard js -->
	<script type="text/javascript" src="/webhard/resources/script/mobile/webhard.js<%=resourceVersion%>"></script>
<% } %>
<% if(useCrm != null && useCrm.equals("Y")){ %>
	<!-- CRM js -->
	<script type="text/javascript" src="/crm/resources/script/mobile/chance.js<%=resourceVersion%>"></script>
<% } %>
<% if(themeCode != null && !themeCode.equals("default")){ %>
	<link rel="text/javascript" src="<%=cssPath%>/customizing/mobile/<%=themeCode%>/js/project.js" />
<% } %>

<!-- slick -->
<script type="text/javascript" src="<%=cssPath%>/mobile/resources/js/slick.min.js<%=resourceVersion%>"></script>

<!-- Jsoner -->
<script type="text/javascript" src="/covicore/resources/script/Jsoner/Jsoner.0.8.2.js<%=resourceVersion%>"></script>

<!-- 결재 추가 js / css -->
<script type="text/javascript" src="/approval/resources/script/user/common/ApprovalUserCommon.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/activiti/manageActiviti.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/approval/resources/script/forms/underscore.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/approval/resources/script/xeasy/xeasy-number.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/approval/resources/script/xeasy/xeasy-numeral.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/approval/resources/script/xeasy/xeasy-timepicker.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/approval/resources/script/xeasy/xeasy.multirow.0.9.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/approval/resources/script/xeasy/xeasy4j.0.9.2.js<%=resourceVersion%>"></script>
<link type="text/css" rel="stylesheet" href="/approval/resources/css/xeasy/xeasy.0.9.css<%=resourceVersion%>" />

<!-- 결재사인 등록 -->
<script type="text/javascript" src="/approval/resources/script/sign/jquery.signaturepad.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/approval/resources/script/sign/json2.min.js<%=resourceVersion%>"></script>

<!-- 차트 -->
<script type="text/javascript" src="/covicore/resources/ExControls/Chart.js-master/Chart.js<%=resourceVersion%>"></script>  

<script type="text/javascript" src="/covicore/resources/script/highcharts/highcharts-gantt.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/highcharts/modules/draggable-points.js<%=resourceVersion%>"></script>

<!-- 협업스페이스 -->
<script type="text/javascript" src="/groupware/resources/script/mobile/collab.js<%=resourceVersion%>"></script>
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision/palette-color-picker.css<%=resourceVersion%>" />
<script type="text/javascript" src="/covicore/resources/script/palette-color-picker.js<%=resourceVersion%>"></script>    

<!--  파라메터 유호성 체크 -->
<script type="text/javascript" src="/covicore/resources/script/security/aes.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/security/x64-core.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/security/sha256.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/security/pbkdf2.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Mobile/mobile.sec.js<%=resourceVersion%>"></script>

<script type="text/javascript" src="/covicore/resources/script/Mobile/mobile.sec.js<%=resourceVersion%>"></script>
<!-- covision util 함수  -->
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.util.js<%=resourceVersion%>"></script>

<% if ("Y".equals(useTeamsAddIn)) { %>
	<!-- Teams Add-In -->
	<script src="/covicore/resources/script/MicrosoftTeams.min.js<%=resourceVersion%>"></script>
	<script src="/covicore/resources/script/Controls/TeamsApp.js<%=resourceVersion%>"></script>
<% } %>
	 <!-- 신규 소스 시작 -->
<!-- covicore/groupware에 있는 MobileInclude.jsp는 동일한 내용이어야 함 -->
