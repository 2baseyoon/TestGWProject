<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<script type="text/javascript">
	var leftData = ${leftMenuData};
	var loadContent = '${loadContent}';
	
	$(document).ready(function (){
		//$('#left').hide();
		//$('#content').removeClass('commContRight');
		
		if(loadContent == 'true'){
    		CoviMenu_GetContent('/groupware/portal/home.do?CLSYS=portal&CLMD=user&CLBIZ=Portal');
    	}
	});
	
</script>
