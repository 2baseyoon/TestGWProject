<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<!doctype html>
<html lang="ko">
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script type="text/javascript" src="/groupware/resources/script/user/collab_util.js"></script>
<script type="text/javascript" src="/groupware/resources/script/user/collab_main.js"></script>
<%
	String key = "";
	Cookie[] cookies = request.getCookies();
	if (cookies != null) {
		for (int i = 0; i < cookies.length; i++) {
			if ("CSJTK".equals(cookies[i].getName())) {
				key = cookies[i].getValue();
			}
		}
	}	
%>
<style>
.cRContBottom {
top:10px
}
.container-fluid { display:none;}
.container-fluid.active { display:inherit; }
.CollabTable { width:100%; table-layout:fixed;}
.CollabTable th {height:33px; border-bottom:1px solid #ACAEB2; font-size:13px; font-family:맑은 고딕, Malgun Gothic,sans-serif, dotum,'돋움',Apple-Gothic;font-color:#5E5E5E}
.CollabTable td{height:40px;border-bottom:1px solid #ededed;}
.bodyTdText {color:#9a9a9a; text-shadow:none; overflow:hidden; white-space:nowrap; text-overflow:ellipsis;}

</style>

<body>	
<div class="cRContBottom mScrollVH" id="${prjType}_${prjSeq}" style="display: block;">
<jsp:include page="/WEB-INF/views/user/collab/CollabMain.jsp"></jsp:include>
</div>
<script>
var key = "<%=key%>";	
$(document).ready(function(){
	var dataMap ={"myTodo":"N","prjType":"${prjType}","prjSeq": "${prjSeq}", "prjName":"${prjName}"};
	collabMain.objectInit("${prjType}_${prjSeq}", dataMap);
});

</script>
