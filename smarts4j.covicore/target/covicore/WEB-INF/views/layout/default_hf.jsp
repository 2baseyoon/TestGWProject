<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!-- <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"> -->
<!doctype html>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="tiles"%>
<!-- <html> -->
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title><tiles:getAsString name="title" /></title>
<style>

/*
** TODO : 반응형 웹 스타일 구현
** 
*/
@media screen and (min-width:100px) and (max-width:360px){}

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
	padding: 20px;
	margin-bottom: 20px;
	border: 1px solid #bcbcbc;
}

#jb-footer {
	clear: both;
	padding: 20px;
	border: 1px solid #bcbcbc;
}
</style>
<!-- css block -->
<link rel="stylesheet" type="text/css" href="<c:url value='/css/axisj/arongi/AXJ.css'/>" />
<link rel="stylesheet" type="text/css" href="<c:url value='/css/axicon/axicon.min.css'/>" />
<!-- js block -->
<tiles:insertAttribute name="commonScripts"/>
<script type="text/javascript" src="<c:url value='/script/jquery.min.js'/>"></script>
<script type="text/javascript" src="<c:url value='/script/axisj/AXJ.all.js'/>"></script>
<script type="text/javascript">
	// TODO : 태스크 테스트
</script>
</head>
<body>

	<div id="jb-container">
		<div id="jb-header">
			<tiles:insertAttribute name="header" />
		</div>
		<div id="jb-content">
			<tiles:insertAttribute name="content" />
		</div>
		<div id="jb-footer">
			<tiles:insertAttribute name="footer" />
		</div>
	</div>
</body>
</html>