<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="tiles"%>
<tiles:insertAttribute name="commonScripts" />
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