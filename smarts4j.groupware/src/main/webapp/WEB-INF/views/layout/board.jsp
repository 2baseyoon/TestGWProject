<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="tiles" %>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<!DOCTYPE html>
<html>
<head>
<title>Bootstrap Example</title>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<tiles:insertAttribute name="commonScripts"/>

<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/resources/css/groupware/leftMenu_bootstrap.css<%=resourceVersion%>" />
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
<script	src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js<%=resourceVersion%>"></script>
<style>


</style>
</head>
<body>
	<tiles:insertAttribute name="header" />


	<div id="wrapper">

        <!-- Sidebar -->
        <div id="sidebar-wrapper">
        	<tiles:insertAttribute name="left" />
        </div>
        <!-- /#sidebar-wrapper -->

        <!-- Page Content -->
        <div id="page-content-wrapper">
            <div class="container-fluid">
                <div class="row">
                    <div id="content" class="col-lg-12">
                        <tiles:insertAttribute name="content" />
                    </div>
                </div>
            </div>
        </div>
        <!-- /#page-content-wrapper -->

    </div>
    <!-- /#wrapper -->
<!-- 	<div class="container-fluid text-center"> -->
<!-- 		<div class="row content"> -->
<!-- 			<div class="col-sm-2 sidenav"> -->
<%-- 				<tiles:insertAttribute name="left" /> --%>
<!-- 			</div> -->
<!-- 			<div id="content" class="col-sm-8 text-left"> -->
<%-- 				<tiles:insertAttribute name="content" /> --%>
<!-- 			</div> -->
<!-- 		</div> -->
<!-- 	</div> -->

</body>
</html>