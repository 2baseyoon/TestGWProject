<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="tiles"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><%=PropertiesUtil.getGlobalProperties().getProperty("front.admin.title") %></title>
<tiles:insertAttribute name="include" />
</head>
<body class="body_bg">
	<div class="fix_wrap">
		<div class="fix_conts">
			<header>
				<tiles:insertAttribute name="header" />
			</header>
			<article>
				<div id="left">
					<tiles:insertAttribute name="left" />
				</div>
				<section class="content_box">
					<div id="content">
						<tiles:insertAttribute name="content" />
					</div>
				</section>
			</article>
			<footer>
			</footer>
		</div>
	</div>
</body>
</html>