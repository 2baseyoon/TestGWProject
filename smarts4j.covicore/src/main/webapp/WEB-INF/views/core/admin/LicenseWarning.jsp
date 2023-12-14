<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<% String appPath = PropertiesUtil.getGlobalProperties().getProperty("app.path"); %>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>

<script type="text/javascript" src="/covicore/resources/script/jquery.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="<%=appPath%>/resources/script/axisj/AXJ.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/CommonControls.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/Common.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/Utils.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.common.js<%=resourceVersion%>"></script>

<script>
function logout() {
	//if(timeSquereLogout()){
	coviCmn.clearLocalCache();
	coviStorage.clear();
	//}
	window.sessionStorage.setItem("timeSquereLogout", "Y");		
	location.href = "/covicore/logout.do";
}
</script>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=utf-8' />
<title>License Violation!!</title>
</head>
<body style='background-color: #f7f7f7;'>
	<table width='100%' border='0' cellpadding='0' cellspacing='0'>
		<tr>
			<td align='center'>
			<br><br><br><br><br><br>
			<table width='500' border='0' cellpadding='0' cellspacing='1' bgcolor='#CCCCCC'>
				<tr>
					<td align='left' valign='top' bgcolor='#FFFFFF'>
					<table	width='500' border='0' cellpadding='0' cellspacing='0'>
						<tr>
							<td height='50' align='center' bgcolor='#cd0100' style='font-size: 20px; font-weight: bold; color: #fff; font-family: Georgia, Times New Roman, Times, serif;'>${title}</td>
						</tr>
						<tr>
							<td height='1' bgcolor='#CCCCCC'></td>
						</tr>
						<tr>
							<td height='20'></td>
						</tr>
						<tr>
							<td align='center' style='font-size: 14px; line-height: 24px; color: #333333; font-weight: bold; font-family: 돋움;'>${message}</td>
						</tr>
						<tr>
							<td height='20'></td>
						</tr>
						<tr>
							<td align='center'><span style='font-size: 12px; color: #333333;'>${subMessage}</span></td>
						</tr>
						<tr>
							<td height='20'></td>
						</tr>
						<tr>
							<td align='center' style='color: #666666; font-size: 11px; font-family: 돋움; line-height: 16px;'>${engMessage}
							<font style="color:white">${etcMessage}</font>
							</td>
						</tr>
						<tr>
							<td height='20'></td>
						</tr>
						<tr>
							<td height='20' align='center'>
								<button onclick="logout(); return false;" style="font-family: 돋움;background-color: #cd0100;color: #ffffff;border: 0px;padding: 5px 12px;cursor: pointer;">Logout</button>
							</td>
						</tr>
						<tr>
							<td height='20'></td>
						</tr>
					</table>
					</td>
				</tr>
			</table>
			</td>
		</tr>
	</table>
</body>
</html>