<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!-- <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"> -->
<!doctype html>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="tiles"%>
<!-- <html> -->
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title><tiles:getAsString name="title" /></title>
<jsp:include page="/WEB-INF/views/cmmn/include.jsp"></jsp:include>

<script type="text/javascript">
	// TODO : 태스크 테스트
</script>
</head>
<body class="body_bg">
	<div class="fix_wrap">
    	<div class="fix_conts">
    		<header>
            <!-- header(상단 메뉴) 시작 -->
            <tiles:insertAttribute name="header" />
             <!-- header(상단 메뉴) 끝 -->
             </header>
             <article>
                <!-- 좌측 메뉴 시작 -->
                <tiles:insertAttribute name="left" />
                <!-- 좌측 메뉴 끝 -->
                <section class="content_box">
                <!-- 컨텐츠 시작 -->
                <tiles:insertAttribute name="content" />
                <!-- 컨텐츠 끝 -->
                </section>
            </article>
        </div>
    </div>
</body>
</html>