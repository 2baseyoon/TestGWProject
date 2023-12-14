<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>

<script  type="text/javascript">
	var option = '${option}';
	$(window).load(function(){
		coviCtrl.renderAddr('con_addr', JSON.parse(option));
	});
</script>

<div id="con_addr">				
</div>