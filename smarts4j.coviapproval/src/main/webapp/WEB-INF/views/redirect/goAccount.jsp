<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@page import="egovframework.coviframework.util.StringUtil"%>

<head>
	<% 
		String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
	%>
	<%
		String processID = StringUtil.replaceNull(request.getParameter("processID"), "");
		String taskID = StringUtil.replaceNull(request.getParameter("taskID"), "");
		String mode = StringUtil.replaceNull(request.getParameter("mode"), "");
		String workitemID = StringUtil.replaceNull(request.getParameter("workitemID"), "");
		String userCode = StringUtil.replaceNull(request.getParameter("userCode"), "");
		String gloct = StringUtil.replaceNull(request.getParameter("gloct"), "");
		String formID = StringUtil.replaceNull(request.getParameter("formID"), "");
		String forminstanceID = StringUtil.replaceNull(request.getParameter("forminstanceID"), "");
		String subkind = StringUtil.replaceNull(request.getParameter("subkind"), "");
		
		String scount = StringUtil.replaceNull(request.getParameter("scount"), ""); // 일괄확인
		String bserial = StringUtil.replaceNull(request.getParameter("bserial"), "false"); // 연속결재
		String listpreview = StringUtil.replaceNull(request.getParameter("listpreview"), "");
	%>
</head>

<script type="text/javascript" src="/covicore/resources/script/jquery.min.js<%=resourceVersion%>"></script>
<div>
	<form id="form" action="/account/expenceApplication/ExpenceApplicationViewPopup.do" method="post">
		<input type="hidden" id="ExpAppID" name="ExpAppID" value="${ExpAppID}">
		<input type="hidden" id="isUser" name="isUser" value="${isUser}">
		<input type="hidden" id="processID" name="processID" value="<%=processID%>">
		<input type="hidden" id="taskID" name="taskID" value="<%=taskID%>">
		<input type="hidden" id="mode" name="mode" value="<%=mode%>">
		<input type="hidden" id="workitemID" name="workitemID" value="<%=workitemID%>">
		<input type="hidden" id="userCode" name="userCode" value="<%=userCode%>">
		<input type="hidden" id="gloct" name="gloct" value="<%=gloct%>">
		<input type="hidden" id="formID" name="formID" value="<%=formID%>">
		<input type="hidden" id="forminstanceID" name="forminstanceID" value="<%=forminstanceID%>">
		<input type="hidden" id="subkind" name="subkind" value="<%=subkind%>">
		
		<input type="hidden" id="scount" name="scount" value="<%=scount%>">
		<input type="hidden" id="bserial" name="bserial" value="<%=bserial%>">
		<input type="hidden" id="listpreview" name="listpreview" value="<%=listpreview%>">
	</form>
</div>
<script>

// 필요 시 받아와서 사용
// var formJson = "${formJson}";

initContent();

function initContent(){
	// 양식을 열지 않음 처리 (서명 여부, workitem 값 등 확인 처리)
	var strSuccessYN = ${strSuccessYN};
	var strErrorMsg = "${strErrorMsg}";
	
	if(strSuccessYN == false){
		alert(strErrorMsg);
		window.close();
	}
	else { // 성공
		var url = "/account/expenceApplication/ExpenceApplicationViewPopup.do"; // pc 경로
		
		window.resizeTo(1070, window.outerHeight);
		$("#form").submit();
	}
}

</script>