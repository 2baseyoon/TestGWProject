<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!-- <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"> -->
<!doctype html>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="tiles"%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title><tiles:getAsString name="title" /></title>
<style>
</style>
<jsp:include page="/WEB-INF/views/cmmn/include.jsp"></jsp:include>
</head>
<!-- <body class="body_bg"> -->
<!-- 	<div class="fix_wrap"> -->
<!--     	<div class="fix_conts"> -->
<!--     		<header> -->
<!--             header(상단 메뉴) 시작 -->
<%--             <tiles:insertAttribute name="header" /> --%>
<!--              header(상단 메뉴) 끝 -->
<!--              </header> -->
<!--              <article> -->
<!--                 좌측 메뉴 시작 -->
<%--                 <tiles:insertAttribute name="left" /> --%>
<!--                 좌측 메뉴 끝 -->
<!--                 <section class="content_box"> -->
<!--                 컨텐츠 시작 -->
<%--                 <tiles:insertAttribute name="content" /> --%>
<!--                 컨텐츠 끝 -->
<!--                 </section> -->
<!--             </article> -->
<!--         </div> -->
<!--     </div> -->
<body>
	<div class="wrap">
		<div class="approval_wrap">
<!-- 		    <header> -->
<!--             header(상단 메뉴) 시작 -->
<%--             <tiles:insertAttribute name="header" /> --%>
<!--              header(상단 메뉴) 끝 -->
<!--              </header> -->
		    <!-- 해더영역 Start -->
<!-- 		    <div class="header"> -->
<!-- 		      추후 작성 -->
<%-- 		    	<tiles:insertAttribute name="header" /> --%>
<!-- 		    </div> -->
            <div class="layout">
      			<div class="container">
        			<div class="con_layout">
          				<div class="content">
          				    <!-- 좌측 영역 시작 -->
				            <div class="lmb_box">
				            <!-- 좌측 타이틀 시작 -->
				            	<h3 class="ltit_approval"><span class="ltit_txt"></span></h3>
					            <!-- 좌측 타이틀 끝 -->
					            <!-- 좌측 메뉴 시작 (approval_wrap .클래스명 으로 작업) -->
					            <tiles:insertAttribute name="left" />
					            <!-- 좌측 메뉴 끝 -->
					        </div>
					        <!--컨텐츠 시작 -->
                			<tiles:insertAttribute name="content" />
							<!--컨텐츠 끝 -->
          				</div>
          			</div>
          		</div>
          	</div>
         </div>
    </div>
</body>
</html>