<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>



<nav class="lnb">
	<h2 class="gnb_left_tit"><span class="gnb_tit" onclick="leftmenu_goToPageMain(); return false">메일관리</span></h2>
	<ul class="lnb_list">
	
	</ul>
</nav>

<script type="text/javascript">
	var leftdata = ${adminmailleft};
	
	function leftmenu_goToPageMain(){
		location.href = "mailadmin_mailadmin.do";
	}
	
	$(document).ready(function (){
		drawadminleftmenu(leftdata);
		
	});
</script>
