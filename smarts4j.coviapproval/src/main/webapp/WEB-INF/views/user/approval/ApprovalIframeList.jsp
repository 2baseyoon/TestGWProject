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
	String FormTempInstBoxID 	= StringUtil.replaceNull(request.getParameter("FormTempInstBoxID"),"");
	String FormInstID 			= StringUtil.replaceNull(request.getParameter("FormInstID"),"");
	String FormID 				= StringUtil.replaceNull(request.getParameter("FormID"),"");
	String FormInstTableName 	= StringUtil.replaceNull(request.getParameter("FormInstTableName"),"");
	String Mode 				= StringUtil.replaceNull(StringUtil.replaceNull(request.getParameter("Mode")).toString(),"");
	String Gloct 				= StringUtil.replaceNull(request.getParameter("Gloct"),"");
	String Subkind 				= StringUtil.replaceNull(request.getParameter("Subkind"),"");
	String Archived 			= StringUtil.replaceNull(request.getParameter("Archived"),"");
	String bstored 				= StringUtil.replaceNull(request.getParameter("bstored"),"");
	String UserCode 			= StringUtil.replaceNull(request.getParameter("UserCode"),"");
	String Usisdocmanager 		= StringUtil.replaceNull(request.getParameter("Usisdocmanager"),"true");
	String Admintype 			= StringUtil.replaceNull(request.getParameter("Admintype"),"");
	String Listpreview 			= StringUtil.replaceNull(request.getParameter("Listpreview"),"");
	String BusinessData1 		= StringUtil.replaceNull(request.getParameter("BusinessData1"),"");
	String BusinessData2 		= StringUtil.replaceNull(request.getParameter("BusinessData2"),"");
	String TaskID 				= StringUtil.replaceNull(request.getParameter("TaskID"),"");
	String RowSeq 				= StringUtil.replaceNull(request.getParameter("RowSeq"),"");
%>
<form name="IframeFormData" method="post">
	<input type="hidden" id="processID" 			name="processID" 			 value="<%=ProcessID%>">
	<input type="hidden" id="workitemID" 			name="workitemID" 			 value="<%=WorkItemID%>">
	<input type="hidden" id="performerID" 			name="performerID" 			 value="<%=PerformerID%>">
	<input type="hidden" id="processdescriptionID" 	name="processdescriptionID"  value="<%=ProcessDescriptionID%>">
	<input type="hidden" id="formtempID" 			name="formtempID" 			 value="<%=FormTempInstBoxID%>">
	<input type="hidden" id="forminstanceID" 		name="forminstanceID" 		 value="<%=FormInstID%>">
	<input type="hidden" id="formID" 				name="formID" 				 value="<%=FormID%>">
	<input type="hidden" id="forminstancetablename" name="forminstancetablename" value="<%=FormInstTableName%>">
	<input type="hidden" id="mode" 					name="mode" 				 value="<%=Mode%>">
	<input type="hidden" id="gloct" 				name="gloct" 				 value="<%=Gloct%>">
	<input type="hidden" id="subkind" 				name="subkind" 				 value="<%=Subkind%>">
	<input type="hidden" id="archived" 				name="archived" 			 value="<%=Archived%>">
	<input type="hidden" id="bstored" 				name="bstored" 			 	 value="<%=bstored%>">
	<input type="hidden" id="userCode" 				name="userCode" 			 value="<%=UserCode%>">
	<input type="hidden" id="admintype" 			name="admintype" 			 value="<%=Admintype%>">
	<input type="hidden" id="usisdocmanager" 		name="usisdocmanager" 		 value="<%=Usisdocmanager%>">
	<input type="hidden" id="listpreview" 			name="listpreview" 			 value="<%=Listpreview%>">
	<input type="hidden" id="ExpAppID" 				name="ExpAppID"				 value="<%="undefined".equals(BusinessData2)?"":BusinessData2%>">
	<input type="hidden" id="taskID" 				name="taskID" 			 	 value="<%=TaskID%>">
	<input type="hidden" id="rowSeq" 				name="rowSeq" 			 	 value="<%=RowSeq%>">
</form>
<div class="rightFixed"></div>
<div id="IframeDiv">
	<iframe id="IframeForm" name="IframeForm" frameborder="0" width="100%" height="100%" scrolling="yes" title="<spring:message code='Cache.lbl_show_form' />"></iframe>
</div>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="/covicore/resources/script/jquery.min.js<%=resourceVersion%>"></script>
<script>
	initIframeList();

	function initIframeList(){
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
		CFN_OpenWindow("/approval/approval_Form.do?mode="+document.IframeFormData.mode.value
							+"&processID="+document.IframeFormData.processID.value
							+"&workitemID="+document.IframeFormData.workitemID.value
							+"&performerID="+document.IframeFormData.performerID.value
							+"&processdescriptionID="+document.IframeFormData.processdescriptionID.value
							+"&userCode="+document.IframeFormData.userCode.value
							+"&gloct="+document.IframeFormData.gloct.value
							+"&formID="+document.IframeFormData.formID.value
							+"&forminstanceID="+document.IframeFormData.forminstanceID.value
							+"&formtempID="+document.IframeFormData.formtempID.value
							+"&forminstancetablename="+document.IframeFormData.forminstancetablename.value
							+"&admintype=&archived="+document.IframeFormData.archived.value
							+"&bstored="+document.IframeFormData.bstored.value
							+"&usisdocmanager="+document.IframeFormData.usisdocmanager.value
							+"&listpreview=N&subkind="+document.IframeFormData.subkind.value
							+"&ExpAppID="+(document.IframeFormData.BusinessData2.value!="undefined"?document.IframeFormData.BusinessData2.value:"")
							+"&taskID="+(document.IframeFormData.taskID.value!="undefined"?document.IframeFormData.TaskID.value:"")
							+(document.IframeFormData.rowSeq.value == "" || document.IframeFormData.rowSeq.value == "undefined" ? "" : ("&rowSeq=" + document.IframeFormData.rowSeq.value))
				, "", 790, (window.screen.height - 100), "resize");
	}
	
	function setIFrameHeight(obj){
        obj.height = obj.contentWindow.document.body.scrollHeight;
	}
</script>