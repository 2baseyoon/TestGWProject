<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
</head>
<body>
	<table style="width:100%;height:100%;border:1px solid black;">
		<c:forEach var="UserMenu" items="${list}">
			<c:if test="${UserMenu.getMenuType() == 'mailleft' }">
				<tr>
					<td style="width:150px;float:left;margin-top:10px;margin-left:10px">
					<a href="<c:out value="${UserMenu.getUrl()}"/>"><c:out value="${UserMenu.getDisplayName()}"/></a>
					</td>
				</tr>
			</c:if>
		</c:forEach>
	</table>
</body>
</html>