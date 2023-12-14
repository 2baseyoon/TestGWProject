<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="tiles"%>
<%
 /**
  * Class Name : default_hfc.jsp
  * Description : 기본레이아웃 화면
  * Modification Information
  * 
  *   수정일         수정자                   수정내용
  *  -------    --------    ---------------------------
  *  2016.04.01            	최초 생성
  *  2016.04.22 ywcho		doctype html5로 변경
  *
  * 기술연구소
  * since 2016.04.01
  *  
  * Copyright (C) 2016 by Covision  All right reserved.
  */
%>
<!DOCTYPE html>
<!-- <html lang="ko"> -->
<html lang="ko" xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title><tiles:getAsString name="title" /></title>
 
<style>

/*
** TODO : 반응형 웹 스타일 구현
** 
*/
@media screen and (min-width:100px) and (max-width:360px){
	#jb-sidebar {
		display: none;
	}

}

#jb-container {
	width: 1240px;
	margin: 0px auto;
	padding: 20px;
	border: 1px solid #bcbcbc;
}

#jb-header {
	padding: 20px;
	margin-bottom: 20px;
	border: 1px solid #bcbcbc;
}

#jb-content {
	width: 900px;
	padding: 20px;
	margin-bottom: 20px;
	float: right;
	border: 1px solid #bcbcbc;
}

#jb-sidebar {
	width: 240px;
	padding: 20px;
	margin-bottom: 20px;
	float: left;
	border: 1px solid #bcbcbc;
}

#jb-footer {
	clear: both;
	padding: 20px;
	border: 1px solid #bcbcbc;
}
</style>
<!-- css block -->
<link rel="stylesheet" type="text/css" href="<c:url value='/resources/css/axisj/arongi/AXJ.css'/>" />
<link rel="stylesheet" type="text/css" href="<c:url value='/resources/css/axicon/axicon.min.css'/>" />
<!-- js block -->
<tiles:insertAttribute name="commonScripts"/>
<script type="text/javascript" src="<c:url value='/resources/script/jquery.min.js'/>"></script>
</head>
<body>

	<div id="jb-container">
		<div id="jb-header">
			<tiles:insertAttribute name="header" />
		</div>
		<div id="jb-content">
			<tiles:insertAttribute name="content" />
		</div>
		<div id="jb-sidebar">
			<tiles:insertAttribute name="left" />
		</div>
		<div id="jb-footer">
			<tiles:insertAttribute name="footer" />
		</div>
	</div>
</body>
</html>