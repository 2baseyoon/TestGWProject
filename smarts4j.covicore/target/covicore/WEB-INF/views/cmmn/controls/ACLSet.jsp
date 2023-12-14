<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>

<script  type="text/javascript">

var option = '${option}';
$(window).load(function(){
	//var coviACL = new CoviACL({'lang' : 'ko', 'hasItem' : 'false', 'orgMapCallback' : 'callback'});
	var coviACL = new CoviACL(JSON.parse(option));
	coviACL.render('con_acl_popup');
});

</script>

<div id="con_acl_popup">				
</div>