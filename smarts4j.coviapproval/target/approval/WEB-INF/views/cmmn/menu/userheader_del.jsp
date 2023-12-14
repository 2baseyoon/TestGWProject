<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>



<script type="text/javascript">

	var headerdata = ${userheader};

	function headermenu_goToPageMain(){
		location.href = "devhelper_grid.do";
	}

	$(document).ready(function (){
		drawheadermenu(headerdata);
	});
</script>

<h1 class="nav_logo"><a href="#"></a></h1>
<nav class="gnb">
</nav>