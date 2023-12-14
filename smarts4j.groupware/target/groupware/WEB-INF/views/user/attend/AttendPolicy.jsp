<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"  import="egovframework.baseframework.util.SessionHelper
	,egovframework.coviframework.util.ComUtils
	,egovframework.baseframework.util.DicHelper
	,egovframework.baseframework.util.PropertiesUtil"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<div class="cRConTop titType AtnTop">
	<h2 class="title">근태규정</h2> 
</div>
<div class='cRContBottom mScrollVH'>
	<div class="StateCont">
	</div>
</div>	
<script>
$(document).ready(function(){
		$.ajax({
			type : "POST",
			url : "/groupware/attendPortal/getAttendPolicy.do",
			success:function (json) {
				if(json.status=="SUCCESS"){
					$(".StateCont").html(json.data.AttendPolicy);
				}else{
					Common.Warning("<spring:message code='Cache.msg_sns_03'/>");
				}
			}
		});
})
</script>
