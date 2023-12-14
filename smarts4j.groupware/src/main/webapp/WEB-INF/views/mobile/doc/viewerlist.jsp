<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
</head>
<div data-role="page" id="board_viewer_page">
	<header data-role="header" id="board_viewer_header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript: mobile_comm_back();" class="btn_back"><span><!-- 이전페이지로 이동 --></span></a>
				<div class="menu_link"><a href="#" class="pg_tit"><spring:message code='Cache.btn_Viewer'/> <spring:message code='Cache.btn_List'/></a></div><!-- 조회자 목록 -->
			</div>
		</div>
		
		<div id="board_viewer_list" class="g_list">
		</div>
	</header>
</div>
</html>