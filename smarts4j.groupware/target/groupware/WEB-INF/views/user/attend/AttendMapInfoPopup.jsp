<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8" import="egovframework.coviframework.util.RedisDataUtil"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%
	String googleApiKey = RedisDataUtil.getBaseConfig("GoogleApiKey");
	String googleMapLevel = RedisDataUtil.getBaseConfig("GoogleMapLevel")!=null?RedisDataUtil.getBaseConfig("GoogleMapLevel"):"15";
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
	String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); 
%>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv='cache-control' content='no-cache'> 
<meta http-equiv='expires' content='0'> 
<meta http-equiv='pragma' content='no-cache'>

<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script type="text/javascript" src="https://maps.google.com/maps/api/js?key=<%=googleApiKey %>" ></script>
<!-- <script type="text/javascript" src="https://maps.googleapis.com/maps/api/js?key=AIzaSyD1ge_u7His6Vz46-iyxh45IUDwdO8fL64"></script> -->
</head>
<body>
<div class="layer_divpop ui-draggable docPopLayer" style="width:100%;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="" style="overflow:hidden; padding:0;">
		<div class="ATMgt_Map_Popup pt40" style="width:100%;">
			<div id="map_ma" class="ATMgt_Map_img"></div>	
			<span class="map_addr">${addr}</span>
			<div class="bottom">
            	<input type="hidden" id="PointX" name="PointX">
            	<input type="hidden" id="PointY" name="PointY">
				<a href="#" class="btnTypeDefault" id="btnDivClose" onclick="parent.Common.close('AttendMapInfoPopup');"><spring:message code='Cache.lbl_close' /></a>
			</div>
		</div>	
	</div>
</div>	
</body>
<style>
<!--
.bottom { padding:10 0 0 0; }
-->
</style>
<script>
/**
 * Google Map API 주소의 callback 파라미터와 동일한 이름의 함수이다.
 * Google Map API에서 콜백으로 실행시킨다.
 */
var Addr = decodeURI("${addr}") ;
var X_point	= "${pointX}" ;
var Y_point	= "${pointY}" ;
var map;
var marker ;
var zoomLevel = Number("<%=googleMapLevel%>");				// 지도의 확대 레벨 : 숫자가 클수록 확대정도가 큼
$(document).ready(function() {
	// 기본 javascript bind함수가 변경되서 다시 원복 - /mail/resources/script/cmmn/cmmn.func.js
	if (Function.prototype._original_bind && Function.prototype.bind) {
		Function.prototype.bind = Function.prototype._original_bind;
	}
	
	var markerTitle	= "<spring:message code='Cache.lbl_hrcert_comInfo_name' />";		// 현재 위치 마커에 마우스를 오버을때 나타나는 정보 코비젼
	var markerMaxWidth = 300;				// 마커를 클릭했을때 나타나는 말풍선의 최대 크기
	var myLatlng = new google.maps.LatLng(Y_point, X_point);
	var mapOptions = {
		zoom: zoomLevel,
		center: myLatlng,
		mapTypeId: google.maps.MapTypeId.ROADMAP
	};

	map = new google.maps.Map(document.getElementById('map_ma'), mapOptions);
	marker = new google.maps.Marker({
			position: myLatlng,
			map: map,
			title: markerTitle
	});
});
</script>