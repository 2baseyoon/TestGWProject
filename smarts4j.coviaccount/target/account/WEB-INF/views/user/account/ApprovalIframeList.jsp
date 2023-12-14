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
	String Subkind 				= StringUtil.replaceNull(request.getParameter("Subkind"),"");
	String FormInstID 			= StringUtil.replaceNull(request.getParameter("FormInstID"),"");
	String FormID 				= StringUtil.replaceNull(request.getParameter("FormID"),"");
	String UserCode 			= StringUtil.replaceNull(request.getParameter("UserCode"),"");
	String BusinessData2 		= StringUtil.replaceNull(request.getParameter("BusinessData2"),"");
	String Mode 				= StringUtil.replaceNull(request.getParameter("Mode").toString(),"");
	String Gloct 				= StringUtil.replaceNull(request.getParameter("Gloct"),"");
	String Archived 			= StringUtil.replaceNull(request.getParameter("Archived"),"");
	String bstored 				= StringUtil.replaceNull(request.getParameter("bstored"),"");
	String Admintype 			= StringUtil.replaceNull(request.getParameter("Admintype"),"");
	String Listpreview 			= StringUtil.replaceNull(request.getParameter("Listpreview"),"");
%>

<form name="IframeFormData" method="get">
	<input type="hidden" id="processID" 			name="processID" 			 value="<%=ProcessID%>">
	<input type="hidden" id="workitemID" 			name="workitemID" 			 value="<%=WorkItemID%>">
	<input type="hidden" id="performerID" 			name="performerID" 			 value="<%=PerformerID%>">
	<input type="hidden" id="processdescriptionID" 	name="processdescriptionID"  value="<%=ProcessDescriptionID%>">
	<input type="hidden" id="subkind" 				name="subkind" 				 value="<%=Subkind%>">
	<input type="hidden" id="forminstanceID" 		name="forminstanceID" 		 value="<%=FormInstID%>">
	<input type="hidden" id="formID" 				name="formID" 			 	 value="<%=FormID%>">
	<input type="hidden" id="userCode" 				name="userCode" 			 value="<%=UserCode%>">
	<input type="hidden" id="businessData2" 		name="businessData2" 		 value="<%=BusinessData2%>">
	<input type="hidden" id="ExpAppID" 				name="ExpAppID" 			 value="<%=BusinessData2%>">
	<input type="hidden" id="mode" 					name="mode" 				 value="<%=Mode%>">
	<input type="hidden" id="gloct" 				name="gloct" 				 value="<%=Gloct%>">
	<input type="hidden" id="archived" 				name="archived" 			 value="<%=Archived%>">
	<input type="hidden" id="bstored" 				name="bstored" 			 	 value="<%=bstored%>">
	<input type="hidden" id="admintype" 			name="admintype" 			 value="<%=Admintype%>">
	<input type="hidden" id="listpreview" 			name="listpreview" 			 value="<%=Listpreview%>">
</form>
<div class="rightFixed"></div>
<div id="IframeDiv">
	<iframe id="IframeForm" name="IframeForm" frameborder="0" width="100%" height="100%" scrolling="yes" title="<spring:message code='Cache.lbl_show_form' />"></iframe>
</div>

<script>
	initIframeList();

	function initIframeList(){
		openFormData();
	}
	
	function openFormData(){
		document.IframeFormData.target = "IframeForm";
	  	document.IframeFormData.action = "/account/expenceApplication/ExpenceApplicationViewPopup.do";
	  	
	  	document.IframeFormData.submit();
	}

	function onClickPopButton(){
		CFN_OpenWindow("/approval/approval_Form.do?mode="+document.IframeFormData.mode.value
				+"&processID="+document.IframeFormData.processID.value
				+"&gloct="+document.IframeFormData.gloct.value
				+"&ExpAppID="+document.IframeFormData.ExpAppID.value
				+"&admintype=&archived="+document.IframeFormData.archived.value
				+"&usisdocmanager=true&listpreview=N&subkind="+document.IframeFormData.subkind.value+"", "", 1070, (window.screen.height - 100), "both");
		
	}
	function setIFrameHeight(obj){
        obj.height = obj.contentWindow.document.body.scrollHeight;
	}
</script>