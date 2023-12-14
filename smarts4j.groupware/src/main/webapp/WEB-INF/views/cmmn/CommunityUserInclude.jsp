<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="false"%>
<%@page import="egovframework.baseframework.util.SessionHelper"%>
<%@page import="egovframework.coviframework.util.RedisDataUtil"%>
<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@page import="egovframework.coviframework.util.FileUtil"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); 
String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();%>
<jsp:include page="/WEB-INF/views/cmmn/PopupInclude.jsp"></jsp:include>

<script type="text/javascript" src="/covicore/resources/script/Controls/covision.file.js<%=(resourceVersion+(resourceVersion.equals("")?"?":"&")+"maxsize="+FileUtil.getMaxUploadSize())%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.editor.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.util.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.comment.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/groupware/resources/script/user/board.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/groupware/resources/script/user/event_date.js<%=resourceVersion%>"></script>
