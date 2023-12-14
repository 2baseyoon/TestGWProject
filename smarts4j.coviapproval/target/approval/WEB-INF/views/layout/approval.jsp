<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="tiles"%>

<tiles:insertAttribute name="commonScripts" />

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