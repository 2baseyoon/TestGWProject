<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="egovframework.baseframework.util.PropertiesUtil" %>
<jsp:include page="/WEB-INF/views/cmmn/PopupInclude.jsp"></jsp:include>

<%
String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.file.js<%=resourceVersion%>"></script>

<link rel="stylesheet" id="cCss" type="text/css" /> 
<link rel="stylesheet" id="cthemeCss" type="text/css" />

<script  type="text/javascript">
	var option = '${option}';
	$(window).load(function(){
		coviFile.renderFileControl('con_file', JSON.parse(option));
		
		if (parent.communityID != '' && parent.communityCssPath != '' && parent.communityTheme != ''){
			//$("#cCss").attr("href",parent.communityCssPath + "/community/resources/css/community.css");
			$("#cthemeCss").attr("href",parent.communityCssPath + "/covicore/resources/css/theme/community/"+parent.communityTheme+".css");
		}
		else {
			$("#cCss, #cthemeCss").remove();
		}
	});
</script>

<div id="con_file">				
</div>