<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="egovframework.baseframework.util.PropertiesUtil
																							,egovframework.coviframework.util.SessionCommonHelper
																							,egovframework.baseframework.util.RedisDataUtil
																							,egovframework.baseframework.data.CoviList
																							,egovframework.baseframework.data.CoviMap
																							,egovframework.baseframework.util.DicHelper
																							,egovframework.coviframework.util.ComUtils"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld"  %>
	<!--  통합알림만 리스트로 -->
	<c:set var="myArray" value="${fn:split('Integrated,Mention',',')}" />	
	<c:forEach var="list"  items="${myArray}" varStatus="status">
		<div id="integratedAlarmCont" data-menu-id="${list}"   class="combineNoticeCont ">
			<div class="combineTop">
				<h3>
					<c:if test="${list eq 'Mention'}">Mention</c:if>
					<c:if test="${list ne 'Mention'}"><spring:message code='Cache.lbl_portal_IntegratedNotify'/></c:if>
				</h3>
				<div class="todoBtnBox">		
					<a href="#" class="btnRemoveType02" onclick="CoviMenu_deleteAllAlarm('${list}'); ">삭제</a>									
					<a href="#" class="btnRepeatType02" onclick="CoviMenu_getIntegratedList('${list}');">리피트</a>									
					<a href="#" class="btnXCloseType02 " onclick="CoviMenu_clickQuickIntegrated('${list}');"></a>
				</div>
			</div>
			<div class="combineBottom mScrollV scrollVType01">
				<ul class="todoListCont combineListCont" id="integratedUL" ></ul>
				<p id="noIntegratedAlarm" style="display:none;" class="noSearchListCont"><spring:message code='Cache.msg_NoDataList' /></p>
			</div>			
		</div>
	</c:forEach>
	<!--  간편작성 창-->
	<aside class="simpleMakeLayerPopUp">
		<jsp:include page="/WEB-INF/views/cmmn/simple_make.jsp"></jsp:include>
	</aside>
	<!-- 가젯 영역 -->
	<article class="orderBusi">
		<div class="orderContent">
	        <div class="oderContCloseBox"><button class="btnOrderContClose">업무지시창 닫기</button></div>
	        <div class="orderBusiMenuCont">
	            <ul class="orderTabMenu clearFloat">
	                <li class="iconTodo active" type="Todo"><a><span>To-Do</span><span class="countStyle new">0</span></a></li>
	                <li class="iconSubscription" type="Subscription"><a><span><spring:message code='Cache.lbl_Subscription'/></span></a></li>
	                <li class="iconContact" type="ContactNumber"><a><span><spring:message code='Cache.lbl_bizcard_Contact'/></span></a></li>
	            </ul>
	            <!-- ToDo 시작 -->
	            <div class="oderTabContent toDoTab active" id="todoDiv">
	            	<div class="todoContTop clearFloat">
	            		<div class="chkStyle04 todoTopChk chkType01"><input type="checkbox" id="allChkInput" class="allChkInput"><label for="allChkInput"><span></span>전체완료</label></div>
	            		<div class="todoTopSelect"></div>
	            		<div class="todoBtnBox">
	            			<a class="btnRemoveType02" onclick="coviCtrl.callDeleteTodo(0)">완료목록삭제</a>
	            			<a class="btnTodoWrite" onclick="coviCtrl.callWriteTodoPopup(0)">쓰기</a>
	            			<a class="btnRepeatType02" onclick="coviCtrl.getTodoList()">리피트</a>
	            		</div>
	            	</div>
	            	<div class="todoContBottom oderScrollcont">
	            		<ul class="todoListCont"></ul>
	            		<p class="noSearchListCont"><spring:message code='Cache.msg_NoDataList' /></p>
	            	</div>
	            </div>
	            <!-- ToDo 끝 -->
	            <div class="oderTabContent subscriptionTab">
	                <div class="subScriptionTop">
	                    <div class="todoBtnBox">
	                        <a href="javascript:;" class="btnRepeatType02" onclick="coviCtrl.getSubscriptionList();">리피트</a>
	                        <a href="javascript:;" class="btnTodoOption" onclick="coviCtrl.callSubscriptionPopup();return false;">옵션</a>
	                    </div>
	                </div>
	                <div id="divSubscriptionList" class="oderScrollcont subscriptionBottom">
	                    <ul class="subscriptionListCont"></ul>
	                </div>
	            </div>
	            <!-- 연락처 시작 -->
	            <div class="oderTabContent contactTab">
	            	<div class="subScriptionTop">
	            		<div style="float: left; padding-top: 14px;"><h3 class="cycleTitle"><spring:message code='Cache.lbl_FavoriteList' /></h3></div>
	                    <div class="todoBtnBox">
	                        <a href="javascript:;" class="btnRepeatType02" onclick="coviCtrl.getContactNumberList();">새로고침</a>
	                    </div>
	                </div>
	                <div class="oderScrollcont" id="contactNumberDiv">
	                </div>
	            </div>
	            <!-- 연락처 끝 -->
	        </div>
	    </div>
   	</article>
	
	    
