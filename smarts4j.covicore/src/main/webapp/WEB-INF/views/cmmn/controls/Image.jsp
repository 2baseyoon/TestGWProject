<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>

<style type="text/css">
	#con_image img {
	    display: block;
	    margin: auto;
	}
</style>

<script  type="text/javascript">
	var option = '${option}';
	$(document).ready(function(){
		coviCtrl.renderImageViewer('con_image', JSON.parse(option));
	});
</script>

<table width="100%" height="100%" align="center" valign="center">
	<tr>
		<td>
    		<div id="con_image"></div>
		</td>
	</tr>
</table>
