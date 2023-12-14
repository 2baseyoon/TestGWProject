<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="tiles"%>
<%
 /**
  * Class Name : admin_hfc.jsp
  * Description : 기본레이아웃 화면
  * Modification Information
  * 
  *   수정일         수정자                   수정내용
  *  -------    --------    ---------------------------
  *  2016.04.01            	최초 생성
  *  2016.04.22 ywcho		doctype html5로 변경
  *
  * 기술연구소
  * since 2016.04.01
  *  
  * Copyright (C) 2016 by Covision  All right reserved.
  */
%>

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