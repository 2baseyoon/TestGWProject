<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<html>
	<body>	
		<form id="frm">
		</form>
	</body>
</html>
<script type="text/javascript">

var url = "${url}"+"?";

$(document).ready(function () {	
	var CLSYS = "${CLSYS}";
	var CLMD = "${CLMD}";
	var CLBIZ = "${CLBIZ}";
	
	var flag = false;
	
	if(CLSYS != null && CLSYS != ""){
		url += "CLSYS="+CLSYS;
		flag = true;
	}
	
	if(CLMD != null && CLMD != ""){
		if(flag){
			url += "&CLMD="+CLMD;
		}else{
			url += "CLMD="+CLMD;
		}
		flag = true;
	}
	
	if(CLBIZ != null && CLBIZ != ""){
		if(flag){
			url += "&CLBIZ="+CLBIZ;
		}else{
			url += "CLBIZ="+CLBIZ;
		}
	}
	location.href=url;
	
});
</script>