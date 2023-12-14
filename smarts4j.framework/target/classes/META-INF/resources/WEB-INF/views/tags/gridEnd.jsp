<%@ page language="java" contentType="text/html; charset=UTF-8" import="egovframework.coviframework.util.DicHelper"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
String id = request.getParameter("id");
String gridVar = request.getParameter("gridVar");
String gridEvent = request.getParameter("gridEvent");
String pageSize = request.getParameter("pageSize");
%>
<script type="text/javascript" >
	var <%=gridVar%> = {
		targetID : '<%=id%>',
		colGroup : <%=gridVar%>_header,
		listCountMSG:'<b>{listCount}</b><%=DicHelper.getDic("lbl_Count")%>',
		height:'auto',
		<%if (gridEvent.equals("true")){%>
			body: {onclick       : grid<%=gridVar%>_Click },// 데이터 행의 click 이벤트를 정의합니다. 이벤트 변수 및 this 프로퍼티는 아래 onclick 함수를 참고하세요.
		<%}%>
		page : {pageNo: 1,pageSize: <%=pageSize%>}
	}
</script>