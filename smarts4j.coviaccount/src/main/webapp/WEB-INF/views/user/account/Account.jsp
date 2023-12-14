<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>


<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
</head>

<body>
	
	<!-- 상단 탭 시작-->
	<div class="l-contents-tabs">
		<div class="l-contents-tabs__fixed-tab l-contents-tabs__fixed-tab--active">
			<a href="#" class="l-contents-tabs__main-tab"><i class="tab_eaccountingico_03"></i><div class="l-contents-tabs__title">기준정보관리</div></a>
		</div>
		<div class="l-contents-tabs__list">
			<div class="l-contents-tabs__item">
				<div class="l-contents-tabs__title">예산기간</div>
				<a href="#" class="l-contents-tabs__delete"><i class="i-cancle"></i></a>
			</div>
			<!-- 탭 활성 시작-->
			<div class="l-contents-tabs__item l-contents-tabs__item--active">
				<div class="l-contents-tabs__title">예산계정구</div>
				<a href="#" class="l-contents-tabs__delete"><i class="i-cancle"></i></a>
			</div>
			<!-- 탭 활성 끝-->
			<!-- 드래그 앤 드롭 시작-->
			<div class="l-contents-tabs__item l-contents-tabs__item--draggable" style="top: 80px; left: 600px;">
				<div class="l-contents-tabs__title">구회계년도 기준</div>
				<a href="#" class="l-contents-tabs__delete"><i class="i-cancle"></i></a>
			</div>
			<!-- 드래그 앤 드롭 끝-->
			<div class="l-contents-tabs__item">
				<div class="l-contents-tabs__title">회계년도 기준</div>
				<a href="#" class="l-contents-tabs__delete"><i class="i-cancle"></i></a>
			</div>
			<div class="l-contents-tabs__more-item">
				<a href="#" class="l-contents-tabs__btn-more"><i class="i-etc--mail"></i></a>
				<div class="l-contents-tabs__more-pop">
					<a href="#" class="l-contents-tabs__pop-item">회계년도 기준</a>
					<a href="#" class="l-contents-tabs__pop-item">회계년도 기준</a>
					<a href="#" class="l-contents-tabs__pop-item">회계년도 기준</a>
					<a href="#" class="l-contents-tabs__pop-item">회계년도 기준</a>
				</div>
			</div>
		</div>
	</div>
	<!-- 상단 끝 -->
	
	
	
	<!-- =================================== -->
	<!-- 
	<div class='cRContBottom mScrollVH'>
		<div id = "divJspMailList" class = "divJspClass" style = "display:block" >
			<jsp:include page="/WEB-INF/views/user/mail/MailList.jsp" flush = "false"></jsp:include>
		</div>
		<div id = "divJspMailLeftRightList" class = "divJspClass" style = "display:none" >
			<jsp:include page="/WEB-INF/views/user/mail/MailLeftRightList.jsp" flush = "false"></jsp:include>
		</div>
		<div id = "divJspMailUpDownList" class = "divJspClass" style = "display:none" >
			<jsp:include page="/WEB-INF/views/user/mail/MailUpDownList.jsp" flush = "false"></jsp:include>
		</div>
		<div id = "divJspMailWrite" class = "divJspClass" style = "display:none" >
			<jsp:include page="/WEB-INF/views/user/mail/MailWrite.jsp" flush = "false"></jsp:include>
		</div>
		<div id = "divJspMailRead" class = "divJspClass" style = "display:none" >
			<jsp:include page="/WEB-INF/views/user/mail/MailRead.jsp" flush = "false"></jsp:include>
		</div>
	</div>		
	<aside class='secretary_cont new off'>
		<a href='#' class='balloon' id='typed2'></a>
		<div class='secretaryView'>
			<div class='secretaryCont'>
				<a href="#" class='btnSerImg'>							
					<strong>개인비서</strong>
				</a>					
				<a href="#" class='btnSecOnOff'></a>			
			</div>
			<span class='cycleNew new'>N</span>
		</div>
	</aside>
	 -->
	<!-- 이전 뷰 -->
	<!-- 
	<input type = "hidden" id = "inputPrevView" value = "">
	 -->
	<!-- sort 정보 담아두기 -->
	<!-- 
	<input type = "hidden" id = "inputSort" value = ""> 		
	 
	<form>
		<input type = "hidden" name = "inputReadMessageId" id = "inputReadMessageId" value = "">
		<input type = "hidden" name = "inputReadUid" id = "inputReadUid" value = "">
		<input type = "hidden" name = "inputReadType" id = "inputReadType" value = "">
		<input type = "hidden" name = "inputUserMail" id = "inputUserMail" value = "">
		<input type = "hidden" name = "inputMailBox" id = "inputMailBox" value = "">
		<input type = "hidden" name = "inputAttName" id = "inputAttName" value = "">
	</form>
	
	<iframe style = "width:1px;height:1px;border:0;" name = "hiddenifr"></iframe>	
	-->
</body>

