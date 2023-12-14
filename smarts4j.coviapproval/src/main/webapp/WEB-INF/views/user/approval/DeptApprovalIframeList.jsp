<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@page import="egovframework.coviframework.util.StringUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%
	String ProcessID 			= StringUtil.replaceNull(request.getParameter("ProcessID"),"");
	String WorkItemID 			= StringUtil.replaceNull(request.getParameter("WorkItemID"),"");
	String PerformerID 			= StringUtil.replaceNull(request.getParameter("PerformerID"),"");
	String ProcessDescriptionID = StringUtil.replaceNull(request.getParameter("ProcessDescriptionID"),"");
	String Mode 				= StringUtil.replaceNull(StringUtil.replaceNull(request.getParameter("Mode")).toString(),"");
	String Gloct 				= StringUtil.replaceNull(request.getParameter("Gloct"),"");
	String Subkind 				= StringUtil.replaceNull(request.getParameter("Subkind"),"");
	String Archived 			= StringUtil.replaceNull(request.getParameter("Archived"),"");
	String bstored 				= StringUtil.replaceNull(request.getParameter("bstored"),"");
	String UserCode 			= StringUtil.replaceNull(request.getParameter("UserCode"),"");
	String Usisdocmanager 		= StringUtil.replaceNull(request.getParameter("Usisdocmanager"),"");
	String Admintype 			= StringUtil.replaceNull(request.getParameter("Admintype"),"");
	String Listpreview 			= StringUtil.replaceNull(request.getParameter("Listpreview"),"");
	
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<body>
	<form name="IframeFormData" method="post">
		<input type="hidden" id="processID" 			name="processID" 			 value="<%=ProcessID%>">
		<input type="hidden" id="workitemID" 			name="workitemID" 			 value="<%=WorkItemID%>">
		<input type="hidden" id="performerID" 			name="performerID" 			 value="<%=PerformerID%>">
		<input type="hidden" id="processdescriptionID" 	name="processdescriptionID"  value="<%=ProcessDescriptionID%>">
		<input type="hidden" id="mode" 					name="mode" 				 value="<%=Mode%>">
		<input type="hidden" id="gloct" 				name="gloct" 				 value="<%=Gloct%>">
		<input type="hidden" id="subkind" 				name="subkind" 				 value="<%=Subkind%>">
		<input type="hidden" id="archived" 				name="archived" 			 value="<%=Archived%>">
		<input type="hidden" id="bstored" 				name="bstored" 			 	 value="<%=bstored%>">
		<input type="hidden" id="userCode" 				name="userCode" 			 value="<%=UserCode%>">
		<input type="hidden" id="admintype" 			name="admintype" 			 value="<%=Usisdocmanager%>">
		<input type="hidden" id="usisdocmanager" 		name="usisdocmanager" 		 value="<%=Admintype%>">
		<input type="hidden" id="listpreview" 			name="listpreview" 			 value="<%=Listpreview%>">
	</form>
	
	<div class="rightFixed"></div>
	<div id="IframeDiv">
		<iframe id="IframeForm" name="IframeForm" frameborder="0" width="100%" height="100%" scrolling="yes"></iframe>
	</div>
</body>
<script type="text/javascript" src="/covicore/resources/script/jquery.min.js<%=resourceVersion%>"></script>
<script>
	initDeptIframeList();

	function initDeptIframeList(){
		openFormData();
	}

	function openFormData(){
		/*
		document.IframeFormData.target = "IframeForm";
	  	document.IframeFormData.action = "/approval/approval_Form.do";
	  	document.IframeFormData.submit();
	  	*/
	  	var url = "/approval/approval_Form.do?" + $(document.IframeFormData).serialize();
	  	$("iframe#IframeForm").attr("src", url);
	}

	function onClickPopButton(){
		CFN_OpenWindow("/approval/approval_Form.do?mode="+document.IframeFormData.mode.value+"&processID="+document.IframeFormData.processID.value+"&workitemID="+document.IframeFormData.workitemID.value+"&performerID="+document.IframeFormData.performerID.value+"&processdescriptionID="+document.IframeFormData.processdescriptionID.value+"&userCode="+document.IframeFormData.userCode.value+"&gloct="+document.IframeFormData.gloct.value+"&admintype=&archived="+document.IframeFormData.archived.value+"&bstored="+document.IframeFormData.bstored.value+"&usisdocmanager=true&listpreview=N&subkind="+document.IframeFormData.subkind.value+"", "", 790, (window.screen.height - 100), "resize");
	}
</script>