<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!doctype html>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="tiles"%>
<html xmlns="http://www.w3.org/1999/xhtml">
</head>
<body>
	<table style="width: 100%; height: 100%">
		<tr style="height: 400px">
			<td><tiles:insertAttribute name="content" /></td>
		</tr>
	</table>
</body>
</html>


