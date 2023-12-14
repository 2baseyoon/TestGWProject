<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!doctype html>
<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="tiles" %>
<!-- <html> -->
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <tiles:insertAttribute name="commonScripts" />
    
    <!-- 임시스타일 -->
    <style>
    	* { 
    		padding : 0px;
    		margin : 0px;
    		box-sizing : border-box;
    	}
    	
    	
    	header {
    		height : 80px !important;
    		background-color : #fff !important;
    		border-bottom : 1px solid #c9c9c9;
    	}
    	
    	article {
    		margin : 20px 0px 0px 0px!important;
    		padding : 0px!important;
    		position : relative;
    		z-index : 0;
    	}
    	
    	nav {
    		width: 250px;
    		min-height : 500px;
    		border-right : 1px solid #d9d9d9;
    		padding : 3px;
    		text-align:center;
    		margin : 10px;
    	}
    	
    	section {
    		width : 100%!important;
    		padding : 20px !important;
    		padding-left : 270px !important;
    		position : absolute;
    		top : 0px;
    		left : 0px;
    		z-index : -1;
    	}
    	
    	.ulWorkReportMenuList > li {
    		min-height: 40px;
    		line-height:40px;
    		list-style : none;
    		border-bottom : 1px solid #d9d9d9;
    		padding-left : 10px;
    		cursor : pointer;
    	}
    	
    	.ulWorkReportMenuListDept2 > li {
    		height: 35px;
    		line-height:35px;
    		list-style : none;
    		padding-left : 10px;
    		cursor : pointer;
    	}
    	
    	.closemenu {
    		background : url('/covicore/resources/images/theme/icn_png.png') no-repeat -305px -225px;
    	}
    	
    	.openmenu {
    		background : url('/covicore/resources/images/theme/icn_png.png') no-repeat -305px -195px;
    	}
    	
    	.filtercolumn {
    		width: 30px; 
    		height:30px;
    		display:inline-block;
    		position : absolute; 
    		right : 0px;
    		cursor : pointer;
    		background : url('/covicore/resources/images/theme/icn_png.png') no-repeat -450px -280px;
    	}
    	
    	#ulFilterList > li { 
    		border-bottom : 1px solid #c9c9c9;
    		box-sizing : border-box;
    		height : 30px;
    		line-height : 30px;
    		width : 100%;
    		padding-left : 10px;
    		list-style : none;
    		padding : 0px;
    		margin : 0px;
    		padding-left : 5px;
    		overflow : hidden;
    	}
    	
    	#ulFilterList > li:first-child { 
    		background-color : #e9e9e9;
    		font-weight : bold;
    	}
    </style>
    
  </head>
  <body style="min-width : 1240px;">
  		<!-- Header -->
        <header>
        	<tiles:insertAttribute name="header" />
        </header>
        
        <article>
        	<!-- Left Menu -->
        	<nav>
        		<tiles:insertAttribute name="left" />
        	</nav>
        	
        	<!-- Content -->
        	<section>
        		<tiles:insertAttribute name="content" />
        	</section>
        </article>
  </body>
</html>