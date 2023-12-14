<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path");%>
<!-- 메인 페이지 -->
<div data-role="page" id="portal_banner_main">
	<header class="Htype02">
		<div class="sub_header">
			<div class="l_header" >
				<a href="#" class="logo" id="imgPortalLogo"><span>covismart2</span></a>
				<a href="#" class="portal_setting" style="display: none;"></a>
			</div>
		</div>
	</header>
	<div class="cont_wrap">
		 <div class="portal_wrap Ptype02">
    </div>
    <div class="m_protal_banner">
      <div class="mImg" style="background-image:url('<%=cssPath%>/mobile/resources/images/portal_banner_sample.png');"></div>
      <div class="dim" style="opacity: 0.3;"></div>
      <div class="mBox">
        <h3 class="mTitle">고객사 맞춤형 협업 기능을<br>제공하는<br>독립형 클라우드 그룹웨어 <strong>'하랑'</strong></h3>
        <p class="mTxt">개별 서버를 독립적으로 구성하여 기업의 자산이<br>되는 데이터를 관리하는 그룹웨어입니다.</p>
      </div>
    </div>
  </div>
</div>
