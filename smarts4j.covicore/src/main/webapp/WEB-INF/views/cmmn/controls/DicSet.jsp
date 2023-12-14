<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<c:choose>
<c:when test="${param.styleType eq 'U'}">
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
</c:when>
<c:otherwise>
	<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>
</c:otherwise>
</c:choose>

<script type="text/javascript">

var option = '${option}';
$(window).load(function(){
	coviDic.render('con_acl_popup', JSON.parse(option));
	$("#ko_full").focus();
});

</script>

<div id="con_acl_popup">				
</div>