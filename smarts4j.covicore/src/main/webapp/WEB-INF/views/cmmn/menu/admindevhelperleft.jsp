<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>


<nav class="lnb">
	<h2 class="gnb_left_tit"><span class="gnb_tit" onclick="leftmenu_goToPageMain(); return false"><spring:message code="Cache.CN_10"/></span></h2>
	<ul class="lnb_list">
	</ul>
</nav>

<script type="text/javascript">
	var leftdata = ${admindevhelperleft};
	
	
	function leftmenu_goToPageMain(){
		location.href = "devhelper_grid.do";
	}
	
	$(document).ready(function (){
		drawadminleftmenu(leftdata);
		
	});
</script>
