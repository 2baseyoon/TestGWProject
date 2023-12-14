<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<%
	String requestType = request.getParameter("requesttype");
	String isView = request.getParameter("isView");
%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
	<script type="text/javascript" src="/covicore/resources/ExControls/Tmap/tmap.js"></script>
</head>
<style> 
	li:hover {background-color: #e3e3de;}
   	th {
       border-bottom: 1px solid #d7d7d7 !important;
       height: 40px;
       padding:5px;
       vertical-align: middle !important;
   	}
</style>
<body>
	<div viewshow="Y" class="l-contents-tabs">
		<div name="fuelTabDiv" tabtype="T" class="l-contents-tabs__item">
			<a name="fuelTabT" tabtype="T" class="l-contents-tabs__title"
				onclick="ExpenceApplicationFuelPopup.fuelTabClick(this, 'T')">
				<div class="l-contents-tabs__title" style="height: 50px; line-height: 50px;">
					<!-- Tmap -->
					TMAP
				</div>
			</a>
		</div>
		<div name="fuelTabDiv" tabtype="K"  class="l-contents-tabs__item l-contents-tabs__item--active">
			<a name="fuelTabT" tabtype="K" class="l-contents-tabs__title"
				onclick="ExpenceApplicationFuelPopup.fuelTabClick(this, 'K')">
				<div  class="l-contents-tabs__title" style="height: 50px; line-height: 50px;">
					<!-- 카카오내비 이용내역 -->
					카카오 이용내역
				</div>
			</a>
		</div>
	</div>
	
	<div ViewShow="Y" name="TmapArea">
		<select id="selectLevel" style="display:none">
			<option value="0" selected="selected">교통최적+추천</option>
			<option value="1">교통최적+무료우선</option>
			<option value="2">교통최적+최소시간</option>
			<option value="3">교통최적+초보</option>
			<option value="4">교통최적+고속도로우선</option>
			<option value="10">최단거리+유/무료</option>
			<option value="12">이륜차도로우선</option>
			<option value="19">교통최적+어린이보호구역 회피</option>
		</select> 
		<select id="year" style="display:none">
			<option value="N" selected="selected">교통정보 표출 옵션</option>
			<option value="Y">Y</option>
			<option value="N">N</option>
		</select>
		<div style="width: 100%;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
			<div class="divpop_contents">
				<div class="popContent" style="position:relative;">
					<div class="middle">
						<div class="con_in" TmapArea="Y">
							<div class="map_input">
								<!-- 출발지 -->
								<p class="map_tit"><spring:message code="Cache.ACC_lbl_startPoint"/></p>
								<div class="searchBox02">
									<input type="text" id="mapFrom" name="searchKeyword" value="" viewinput="Y" style="width:100%">	
									<button type="button" class="btnSearchType01" style="background-position-x: 3px;" onclick="searchList('mapFrom')"><spring:message code='Cache.ACC_btn_search'/></button>
								</div>	
								<!-- 도착지 -->	
								<p class="map_tit"><spring:message code="Cache.ACC_lbl_endPoint"/></p>						
								<div class="searchBox02">
									<input type="text" id="mapTo" name="searchKeyword" value="" viewinput="Y" style="width:100%">
									<button type="button" class="btnSearchType01" style="background-position-x: 3px;" onclick="searchList('mapTo')"><spring:message code='Cache.ACC_btn_search'/></button>
								</div>
								<div>
									<div class="tx_distance">
										* <spring:message code='Cache.ACC_lbl_distance'/> : <span type="text" class="text_custom" id="labresultDistance"> 0km</span>
										<input type="hidden" style='float: left;height:100%;'class="text_custom" id="resultDistance">	
									</div>
								</div>		
								<div ViewShow="Y" class="btn_mapwrap"><a id="btnDelete" class="btnTypeDefault" href="javascript:fn_DelMap();"><spring:message code="Cache.ACC_btn_reset"/></a></div>
								<div ViewShow="Y">
									<div style="width: 100%; float:left; margin-top:10px;">
										<div class="rst_wrap">
											<div class="rst mCustomScrollbar" style="overflow:auto;height:170px">
												<ul id="searchResult" name="searchResult"">
												</ul>
											</div>
										</div>
									</div>
								</div>
							</div>
							<div id="map_div" class="map_wrap" style="height:420px !important;">
							</div>	
						</div>
						<!-- ------------------------------------------------------------------------------------------------------------------------------------ -->
					</div>
				</div>
			</div>	
		</div>
	</div>
	<div ViewShow="Y" name="KakaoArea" style="margin: 0px 15px;">
		<div style="padding: 0px 8px 0px 8px;">
			<div id="topitembar02" class="bodysearch_Type01">
				<div class="inPerView type07">
					<div style="width:900px;">
						<div class="inPerTitbox">
							<!-- 사용일자 -->
							<span class="bodysearch_tit"><spring:message code="Cache.ACC_lbl_approveDate"/></span>
							<div id="expAppFuel_dateArea" class="dateSel type02" name="searchParam" fieldtype="Date"
								stfield="expAppFuel_dateArea_St" edfield="expAppFuel_dateArea_Ed" 
								stdatafield="UseDateSt" eddatafield="UseDateEd">
							</div>	
						</div>
						<a class="btnTypeDefault  btnSearchBlue"	onclick="ExpenceApplicationFuelPopup.kakaoSearchList();"><spring:message code='Cache.ACC_btn_search'/></a>
					</div>
				</div>
			</div>
			<div id="gridArea" class="pad10">
			</div>
		</div>
	</div>
	<div class="layer_divpop ui-draggable docPopLayer">
		<div class="divpop_contents">
			<div class="popContent" style="position:relative;">
				<div class="middle">
					<div class="cnrl_bot">
						<div class="total_acooungting_table_btn">
							<p class="total_acooungting_table_tit" style="margin-top:10px;margin-bottom: 10px;"><spring:message code='Cache.ACC_lbl_fuelExpenceList'/></p>
							<a ViewShow="Y" class="btnTypeDefault" style="min-width: 30px; height:23px; margin-top: 5px; vertical-align: middle; line-height: 22px;" onClick="ExpenceApplicationFuelPopup.setRoundTrip()">왕복</a>
							<a ViewShow="Y" class="btn_add" style="vertical-align:middle;margin-top:5px;" onClick="ExpenceApplicationFuelPopup.addFuelExpence()"></a><a ViewShow="Y" class="btn_del" style="vertical-align:middle;margin-top:5px;" onClick="ExpenceApplicationFuelPopup.deleteFuelExpence()"></a>
						</div>
					</div>
					<table class="total_acooungting_table" style="font-size: 14px;">
						<colgroup>
							<col style="width: 30px;">
							<col style="width: auto;">
						</colgroup>
						<thead>
							<tr>
								<th width="30"><div class="chkStyle01"><input type="checkbox" id="expApp_fuelChkAll" onclick="ExpenceApplicationFuelPopup.distanceCheckAll()"><label for="expApp_fuelChkAll"><span></span></label></div></th>
								<th><spring:message code='Cache.ACC_lbl_date'/></th> <!-- 일자 -->
								<th><spring:message code='Cache.ACC_lbl_startPoint'/></th> <!-- 출발지 -->
								<th><spring:message code='Cache.ACC_lbl_endPoint'/></th> <!-- 목적지 -->
								<th><spring:message code='Cache.ACC_lbl_fuelType'/></th> <!-- 유류타입 -->
								<th><spring:message code='Cache.ACC_lbl_fuelUnitPrice'/></th> <!-- 유류단가 -->
								<th><spring:message code='Cache.ACC_lbl_distance'/>(km)</th> <!-- 이동거리 -->
								<th><spring:message code='Cache.ACC_lbl_fuelRealPrice'/></th> <!-- 유류실비 -->
							</tr>
						</thead>
						<tbody>
							<tr id="fuelExpenceList_trSum" >
								<th colspan="6" align="center" class="tfootbg"><spring:message code='Cache.ACC_lbl_itemSum'/></th> <!-- 합계 -->
								<td align="right" id="distanceTotalSum">0</td>
								<td align="right" id="fuelAmountTotalSum">0</td>
							</tr>
						</tbody>
					</table>
					<div viewshow="Y" class="bottom">
						<div style="font-size: 13px; margin-bottom: 10px;">
							<span class="txt_send_r">*</span>&nbsp;<spring:message code='Cache.ACC_msg_inputProofDateForFuel'/>
						</div>
						<a ViewShow="Y" onclick="ExpenceApplicationFuelPopup.CheckValidation();" id="btnSave" class="btnTypeDefault btnTypeBg"><spring:message code='Cache.ACC_btn_save'/></a> 	<!-- 저장 -->
						<a ViewShow="Y" onclick="ExpenceApplicationFuelPopup.closeLayer();" id="btnClose" class="btnTypeDefault"><spring:message code='Cache.ACC_btn_cancel'/></a>				<!-- 취소 -->
					</div>
				</div>
			</div>
		</div>	
	</div>
</body>
<script type="text/javascript">
	var _imgMarker_FR = '/HtmlSite/smarts4j_n/eaccounting/resources/images/pin_r_m_s.png';
	var _imgMarker_TO = '/HtmlSite/smarts4j_n/eaccounting/resources/images/pin_r_m_e.png';
	var _imgMarker_PO = '/HtmlSite/smarts4j_n/eaccounting/resources/images/point.png';
	var _imgMarkerList = '/HtmlSite/smarts4j_n/eaccounting/resources/images/pin_b_m_';
	var _IsView = 'N';
	var map, marker;
	var markerArr = [], labelArr = [];
	var drawInfoArr = [];
	var resultdrawArr = [];
	var resultMarkerArr = [];
	var _activeDist = "mapFrom";
	var _mapFR_LatLng;
	var _mapTO_LatLng;
	var _marker_FR = new Tmapv2.Marker(null);
	var _marker_TO = new Tmapv2.Marker(null);//, marker_p
	var _resultDistance = 0;
	
	
	$(document).ready(function () {	
		initOnload();
		
		$("#mapFrom").focus();
		$("#mapFrom, #mapTo").keydown(function (event) {
			if (event.keyCode == '13')
				searchList(this.id);
		});
		
		if (_IsView == 'Y') {
			$("input").prop("disabled", true);
			$("select").prop("disabled", true);
			$(".icnDate").remove();
			$("[ViewShow=Y]").hide();
			$("#btnDelete").hide();
		}
	});
	function initOnload() {
		var me = window.ExpenceApplicationFuelPopup; 
		if(me.jsonCode!='D02')return;
		initTmap();
		var List = me.codeJson_Distance
		 
		if(me.codeJson_Distance == undefined) 
			return;
		
	  	if(_IsView == 'Y'){
  			$("#resultDistance").val(me.codeJson_Distance.Distance);
	        $("#labresultDistance").html(me.codeJson_Distance.Distance + "km");
	  	}
	  	
	
		var mapFrom = me.codeJson_Distance.mapFrom;
        var mapTo = me.codeJson_Distance.mapTo;
        $("#mapFrom").val(mapFrom);
        $("#mapTo").val(mapTo);



        var _lng = me.codeJson_Distance.FR_lng;
        var _lat = me.codeJson_Distance.FR_lat;
        var selLatLng = new Tmapv2.LatLng(_lat, _lng);
        _mapFR_LatLng = selLatLng;


        _lng = me.codeJson_Distance.TO_lng;
        _lat = me.codeJson_Distance.TO_lat;
        selLatLng = new Tmapv2.LatLng(_lat, _lng);
        _mapTO_LatLng = selLatLng;

        setMarkerFRTO();
	}
	//1.Tmap 초기화
	function initTmap() {
		// 1. 지도 띄우기
		map = new Tmapv2.Map("map_div", {
			center: new Tmapv2.LatLng(37.570028, 126.986072),
			width: "67%",
			height: "400px",
			zoom: 15,
			zoomControl: true,
			scrollwheel: true
		});
	
	}
	
	//2.목록조회(출발지or도착지)
	function searchList(id) {
		_activeDist = id;
		if (_activeDist == "mapFrom")
			_mapFR_LatLng = '';
		else
			_mapTO_LatLng = '';
	
		var obj = $("#" + id);
		var searchKeyword = obj.val(); // 검색 키워드
		if (searchKeyword == undefined || searchKeyword == null || searchKeyword == '')
			return;
		 
		$.ajax({
			url:"/account/accountCommon/searchMapLocations.do",
			type: "POST",
			async: false,
			data:{
				"SearchKeyword" : searchKeyword,
				"Count" : 10
			},
			success: function (data) {
				//var options = "<option value=''>" + Common.GetDic("lbl_Select") + "</option>";
				searchListSub(data.result);
			},
			error: function (error) {
				Common.Error(Common.GetDic("ACC_msg_error")); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.	
			}
		});
	}
	//2-1.목록 그리기
	function searchListSub(data) {
		var resultpoisData = data.searchPoiInfo.pois.poi;
	
		// 2. 기존 마커, 팝업 제거
		if (markerArr.length > 0) {
			for (var i = 0; i < markerArr.length; i++) {
				markerArr[i].setMap(null);
			}
			markerArr = [];
		}
	
		if (labelArr.length > 0) {
			for (var i = 0; i < labelArr.length; i++) {
				labelArr[i].setMap(null);
			}
			labelArr = [];
		}
	
		var innerHtml = ""; // Search Reulsts 결과값 노출 위한 변수
		//맵에 결과물 확인 하기 위한 LatLngBounds객체 생성
		var positionBounds = new Tmapv2.LatLngBounds();
	
		// 3. POI 마커 표시
		for (var k =0;k<resultpoisData.length;k++){
			// POI 마커 정보 저장
			var noorLat = Number(resultpoisData[k].noorLat);
			var noorLon = Number(resultpoisData[k].noorLon);
			var name = resultpoisData[k].name;
	
			// POI 정보의 ID
			var id = resultpoisData[k].id;
	
			// 좌표 객체 생성
			var pointCng = new Tmapv2.Point(
					noorLon, noorLat);
	
			// EPSG3857좌표계를 WGS84GEO좌표계로 변환
			var projectionCng = new Tmapv2.Projection.convertEPSG3857ToWGS84GEO(
					pointCng);
	
			var lat = projectionCng._lat;
			var lon = projectionCng._lng;
	
			// 좌표 설정
			var markerPosition = new Tmapv2.LatLng(
					lat, lon);
	
			// Marker 설정
			marker = new Tmapv2.Marker(
				{
					position: markerPosition, // 마커가 표시될 좌표
					icon: _imgMarkerList
							+ k
							+ ".png", // 아이콘 등록
					iconSize: new Tmapv2.Size(
							24, 38), // 아이콘 크기 설정
					title: name, // 마커 타이틀
					map: map // 마커가 등록될 지도 객체
				});
	
			// 결과창에 나타날 검색 결과 html
			innerHtml += "<li>"
					+ "<div style='white-space:nowrap;' _lat='" + markerPosition._lat + "' _lng='" + markerPosition._lng +"'>"
					+ "<img src='" + _imgMarkerList + k + ".png' style='vertical-align:middle;'/>"
					+ "<a href='javascript:void(0);' onclick='zoomSelLatLng(this);'>"
					+ "<span name='locationName'>"
					+ name 
					+ "</span>"
					+ "</a>"
					+ "<a onclick='mapSelect(this);' class='btnTypeDefault' style='float: left'><spring:message code='Cache.ACC_lbl_choice'/></a>"
					+ "</div></li>";
			// 마커들을 담을 배열에 마커 저장
			markerArr.push(marker);
			positionBounds.extend(markerPosition); // LatLngBounds의 객체 확장
		}
		
		 
	
		$("#searchResult").html(innerHtml); //searchResult 결과값 노출
		map.panToBounds(positionBounds); // 확장된 bounds의 중심으로 이동시키기
		map.zoomOut();
		$("#mCSB_1").css("min-width","max-content");
	}
	//3.영역 클릭시 zoom
	function zoomSelLatLng(obj) {
		map.setCenter(getLatLng(obj))
		map.setZoom(19);
	}
	//4.선택(출발지or도착지)
	function mapSelect(obj) {
		var locationName = $(obj.parentElement).find('[name=locationName]').html();
		if (_activeDist == "mapFrom") {
			_mapFR_LatLng = getLatLng(obj);
			$("#mapFrom").val(locationName);
		}
		else {
			_mapTO_LatLng = getLatLng(obj);
			$("#mapTo").val(locationName);
		}
		setMarkerFRTO();
	}
	//5.출발지+도착지 마커세팅 + getRouote호출
	function setMarkerFRTO() {
		var me = window.ExpenceApplicationFuelPopup; 
		if (_mapFR_LatLng != undefined && _mapFR_LatLng != '') {
			_marker_FR.setMap(null);
			_marker_FR = new Tmapv2.Marker(
				{
					position: _mapFR_LatLng,
					icon: _imgMarker_FR,
					iconSize: new Tmapv2.Size(24, 38),
					map: map
				});
		}
		if (_mapTO_LatLng != undefined && _mapTO_LatLng != '') {
			_marker_TO.setMap(null);
			_marker_TO = new Tmapv2.Marker(
						{
							position: _mapTO_LatLng,
							icon: _imgMarker_TO,
							iconSize: new Tmapv2.Size(24, 38),
							map: map
						});
		}
		if (!(_mapFR_LatLng != undefined && _mapFR_LatLng != ''
		&& _mapTO_LatLng != undefined && _mapTO_LatLng != ''))
			return;
		resettingMap();
		getRoute();
		if(me.codeJson_Distance== undefined)
			setOilPoint();
	}
	//6.경로 데이터 획득
	function getRoute() {
		var searchOption = $("#selectLevel > option[selected]").val();
	
		var trafficInfochk = $("#year").val();
		if (_IsView != "Y") {
			_resultDistance = 0;
			$("#resultDistance").val(_resultDistance);
			$("#labresultDistance").html(_resultDistance + "km");
		}
	
		$.ajax({
			url:"/account/accountCommon/getMapRoute.do",
			type: "POST",
			dataType: "json",
			async: false,
			data: { 
				"StartX": _mapFR_LatLng._lng,
				"StartY": _mapFR_LatLng._lat,
				"EndX": _mapTO_LatLng._lng,
				"EndY": _mapTO_LatLng._lat,
				"SearchOption": searchOption,
				"TrafficInfo": trafficInfochk
			},
			success: function (data) {
				getRouoteSub(data.result);
			},
			error: function (error) {
				Common.Error(Common.GetDic("ACC_msg_error")); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.	
			}
		});
	}
	function getRouoteSub(data) {
		var resultData = data.features;
		if (_IsView != "Y") {
			_resultDistance = (resultData[0].properties.totalDistance / 1000).toFixed(1);
			$("#resultDistance").val(_resultDistance);
			$("#labresultDistance").html(_resultDistance + "km");
		}

		for (var i in resultData) {
			var geometry = resultData[i].geometry;
			var properties = resultData[i].properties;
	
			if(geometry && properties) {
				if (geometry.type == "LineString") {
					for (var j = 0; j < geometry.coordinates.length; j++) {
						// 경로들의 결과값들을 포인트 객체로 변환 
						var latlng = new Tmapv2.Point(
								geometry.coordinates[j][0],
								geometry.coordinates[j][1]);
						// 포인트 객체를 받아 좌표값으로 변환
						var convertPoint = new Tmapv2.Projection.convertEPSG3857ToWGS84GEO(
								latlng);
						// 포인트객체의 정보로 좌표값 변환 객체로 저장
						var convertChange = new Tmapv2.LatLng(
								convertPoint._lat,
								convertPoint._lng);
						// 배열에 담기
						drawInfoArr.push(convertChange);
					}
					drawLine(drawInfoArr, "0");
				} else {
					var markerImg = "";
					var pType = "";
		
					if (properties.pointType == "S") { //출발지 마커
						markerImg = _imgMarker_FR;
						pType = "S";
					} else if (properties.pointType == "E") { //도착지 마커
						markerImg = _imgMarker_TO;
						pType = "E";
					} else { //각 포인트 마커
						markerImg = _imgMarker_PO;
						pType = "P"
					}
		
					// 경로들의 결과값들을 포인트 객체로 변환 
					var latlon = new Tmapv2.Point(
							geometry.coordinates[0],
							geometry.coordinates[1]);
					// 포인트 객체를 받아 좌표값으로 다시 변환
					var convertPoint = new Tmapv2.Projection.convertEPSG3857ToWGS84GEO(
							latlon);
		
					var routeInfoObj = {
						markerImage: markerImg,
						lng: convertPoint._lng,
						lat: convertPoint._lat,
						pointType: pType
					};
					addMarkers(routeInfoObj);
				}
			}
	
	
			var expandBound = new Tmapv2.LatLngBounds();
			expandBound.extend(_mapFR_LatLng);
			expandBound.extend(_mapTO_LatLng);
	
			map.fitBounds(expandBound);
		} 
	}
	
	//7.경로 라인 그리기
	function drawLine(arrPoint, traffic) {
		var polyline_;
		polyline_ = new Tmapv2.Polyline({
			path: arrPoint,
			strokeColor: "#DD0000",
			strokeWeight: 6,
			map: map
		});
		resultdrawArr.push(polyline_);
	}
	//초기화 기능
	function resettingMap() {
		///////////////////////////////////////////////////////////////////////////////////////////
		if (markerArr.length > 0) {
			for (var i = 0; i < markerArr.length; i++) {
				markerArr[i].setMap(null);
			}
			
			markerArr = [];
		}
	
		if (labelArr.length > 0) {
			for (var i = 0; i < labelArr.length; i++) {
				labelArr[i].setMap(null);
			}
			labelArr = [];
		}
		///////////////////////////////////////////////////////////////////////////////////////////
		_marker_FR.setMap(null);
		_marker_TO.setMap(null);
		if (resultMarkerArr.length > 0) {
			for (var i = 0; i < resultMarkerArr.length; i++) {
				resultMarkerArr[i].setMap(null);
			}
		}
	
		if (resultdrawArr.length > 0) {
			for (var i = 0; i < resultdrawArr.length; i++) {
				resultdrawArr[i].setMap(null);
			}
		}
	
		drawInfoArr = [];
		resultMarkerArr = [];
		resultdrawArr = [];
	}
	
	
	function getLatLng(obj) {
		var _lat = obj.parentElement.getAttribute('_lat')
		var _lng = obj.parentElement.getAttribute('_lng')
		var selLatLng = new Tmapv2.LatLng(_lat, _lng);
		return selLatLng;
	}
	
	
	function addMarkers(infoObj) {
		var size = new Tmapv2.Size(24, 38);//아이콘 크기 설정합니다.
	
		if (infoObj.pointType == "P") { //포인트점일때는 아이콘 크기를 줄입니다.
			size = new Tmapv2.Size(8, 8);
		}
	
		marker_p = new Tmapv2.Marker({
			position: new Tmapv2.LatLng(infoObj.lat, infoObj.lng),
			icon: infoObj.markerImage,
			iconSize: size,
			map: map
		});
	
		resultMarkerArr.push(marker_p);
	}
	function setOilPoint() {
		var mapFrom = $("#mapFrom").val();
		var mapTo = $("#mapTo").val();
	
		var field = $("[name=StartPointField]").first();
		field.val(mapFrom)
		field.keyup();
		var field = $("[name=EndPointField]").last();
		field.val(mapTo)
		field.keyup();
	}
	function fn_ReturnValue() {
		var resultDistance = $("#resultDistance").val();
		var mapFrom = $("#mapFrom").val();
		var mapTo = $("#mapTo").val();
		var resList = new Array();
		var itemList = new Array(); //배열선언
		if (resultDistance == 0) {
			itemList = {
				"Distance": 0
					, "mapFrom": ''
					, "mapTo": ''
					, "FR_lng": ''
					, "FR_lat": ''
					, "TO_lng": ''
					, "TO_lat": ''
			}
		}
		else {
			itemList = {
				"Distance": resultDistance
				, "mapFrom": mapFrom
				, "mapTo": mapTo
				, "FR_lng": _mapFR_LatLng._lng
				, "FR_lat": _mapFR_LatLng._lat
				, "TO_lng": _mapTO_LatLng._lng
				, "TO_lat": _mapTO_LatLng._lat
			}
		}
		return itemList;
	}
	function fn_DelMap() {
		$("#resultDistance").val(0);
		$("#mapFrom").val('');
		$("#mapTo").val('');
		$("#labresultDistance").html("0km");
		resettingMap();
		$("#searchResult").html('')
	}
	
	function fn_findListItem(inputList, field, val) {
		var retVal = null;
		var arrCk = Array.isArray(inputList);
		if(arrCk){
			retVal = accFind(inputList, field, val);
		}
		return retVal;
	}
	function fn_getProofKey(ProofCode) {
		var KeyField = "";
		if(ProofCode=='CorpCard'){
			KeyField = "CardUID";
		}else if(ProofCode=='PrivateCard'){
			KeyField = "ExpAppPrivID";
		}else if(ProofCode=='EtcEvid'){
			KeyField = "ExpAppEtcID";
		}else if(ProofCode=='Receipt'){
			KeyField = "ReceiptID";
		}
		return KeyField
	}
	
	//증빙 코드를 통해 각 증빙페이지의 list 반환
	function fn_getPageList(ProofCode){
		var returnVal;
		if(ProofCode=="CorpCard"){
			return 'cardPageExpenceAppList';
		}
		else if(ProofCode=="TaxBill"){
			return 'taxBillPageExpenceAppList';
		}
		else if(ProofCode=="PaperBill"){
			return 'paperBillPageExpenceAppList';
		}
		else if(ProofCode=="CashBill"){
			return 'cashBillPageExpenceAppList';
		}
		else if(ProofCode=="PrivateCard"){
			return 'privateCardPageExpenceAppList';
		}
		else if(ProofCode=="EtcEvid"){
			return 'etcEvidPageExpenceAppList';
		}
		else if(ProofCode=="Receipt"){
			return 'receiptPageExpenceAppList';
		}
	}
</script>	
<script>

if (!window.ExpenceApplicationFuelPopup) {
	window.ExpenceApplicationFuelPopup = {};
}

(function(window) {
	var CompanyCode = CFN_GetQueryString("companyCode") == "undefined" ? "" : CFN_GetQueryString("companyCode");
	
	var ExpenceApplicationFuelPopup = {
			FuelInputForm : '',
			FuelExpenceTypeHtml : '',
			FuelExpenceAppEvidList : [],
			
			parentNM : '',
			parentMe : {},
			targetList : '',
			ProofCode : '',
			KeyNo : '',			
			params	:{
				gridPanel	: new coviGrid(),
				headerData	: [],
			},
			newPageFlag	: false,
			
			popupInit : function() {
				var me = this;
				var param = location.search.substring(1).split('&');
				for(var i = 0; i < param.length; i++){
					var paramKey	= param[i].split('=')[0];
					var paramValue	= param[i].split('=')[1];
					me[paramKey] = paramValue;
					
				}
				_IsView = me.IsView;
				var KeyField = fn_getProofKey(me.ProofCode);
				me.parentMe = window.parent[me.parentNM];
				
				makeDatepicker('expAppFuel_dateArea', 'expAppFuel_dateArea_St', 'expAppFuel_dateArea_Ed', null, null, 100);
				me.setDefaultDate();	//사용일자 디폴트셋팅
				
				if(me.jsonCode=='D02') $("[TmapArea=Y]").css('display', '');
				
				if(me.parentMe.ApplicationType=="CO") {
					KeyField = 'KeyNo'; 
					me.targetList = fn_getPageList(me.ProofCode);//거래처정산서 작성시 아래로 안내린애들때문에
				} else {
					me.targetList = "pageExpenceApp"+me.ProofCode+"List";
				}
					
				if(me.IsView =='Y') {//수정시와 결재문서에서 오픈했을때 다른 targetList가 필요
					me.targetList = 'pageExpenceAppEvidList';	
					KeyField = 'ViewKeyNo';
				}
				
				var List;
				if(me.IsEditPopup =='Y') {
					me.targetList = 'pageExpenceAppTarget';	
					KeyField = 'KeyNo'; 
					List = me.parentMe[me.targetList];
				} else{
					var List = me.parentMe[me.targetList];
					List = fn_findListItem(List, KeyField, me.KeyNo); 
				}
				
				var divItem;
				if(me.parentMe.ApplicationType=="CO") {
					divItem = fn_findListItem(List.divList, "Rownum", me.Rownum);
				} else {
					divItem = List.divList[0];
				}
				
				var codeJson = divItem.ReservedStr3_Div;
		        codeJson = codeJson[me.jsonCode];
		       
		        if ($.isEmptyObject(codeJson) || codeJson=='') {
		        	codeJson['Distance']= [];
		        	codeJson['FuelExpenceAppEvidList']= [];
		        } else {
		        	if(typeof codeJson =='string') codeJson = JSON.parse(codeJson);
		        }
			  	
			  	codeJson_Distance = codeJson['Distance']
			  	codeJson_Fuel = codeJson['FuelExpenceAppEvidList']
				
				me.List = List;
				me.divItem = divItem;
				me.codeJson_Distance = codeJson_Distance;
				me.codeJson_FuelList = codeJson_Fuel;
				me.KeyField = KeyField;
				
				me.FuelExpenceAppEvidList = $.extend([], me.codeJson_FuelList);
				
				me.popupFormInit();
				me.getFuelExpenceInfo();
				
				me.fuelTabClick('', 'T');	//초기탭
				me.setHeaderData();
				
			},
			
			popupFormInit : function(){
				var me = this;
				var formPath = Common.getBaseConfig("AccountApplicationFormPath");
				
				$.ajaxSetup({async:false});
				
				$.get(formPath + "ExpAppPopupInputForm_Fuel.html" + resourceVersion, function(val){
					me.FuelInputForm = val;
				});
			},
			
			//팝업 정보
			getFuelExpenceInfo : function(){
				var me = this;
				if(me.FuelExpenceAppEvidList.length == 0) {
					me.addFuelExpence();
				} else {
					for(var i = 0; i < me.FuelExpenceAppEvidList.length; i++){
						me.addFuelExpence(i, me.FuelExpenceAppEvidList[i]);
					}		
				}
			},
			
			//일비 추가
			addFuelExpence : function(Rownum, InputItem) {
				var me = this;
				var FuelForm = me.FuelInputForm;
				var isAdd = (Rownum == undefined ? true : false);
				
				if(isAdd) {
					if(me.FuelExpenceAppEvidList.length > 0)
						Rownum = me.FuelExpenceAppEvidList[me.FuelExpenceAppEvidList.length-1].Rownum + 1;
					else
						Rownum = 0;
				}
				
				var valMap = {
					ProofCode : me.ProofCode,
					KeyNo : me.KeyNo,
					Rownum : Rownum
				};
				if(InputItem != undefined) {
					valMap.BizTripDateStr = nullToBlank(InputItem.BizTripDateStr);
					valMap.BizTripDate = nullToBlank(InputItem.BizTripDate);
					valMap.StartPoint = nullToBlank(InputItem.StartPoint);
					valMap.EndPoint = nullToBlank(InputItem.EndPoint);
					valMap.FuelType = nullToBlank(InputItem.FuelType);
					valMap.FuelTypeNM = nullToBlank(InputItem.FuelTypeNM);
					valMap.Distance = toAmtFormat(nullToBlank(InputItem.Distance));
					valMap.FuelUnitPrice = toAmtFormat(nullToBlank(InputItem.FuelUnitPrice));
					valMap.FuelRealPrice = toAmtFormat(nullToBlank(InputItem.FuelRealPrice));
				}
				valMap.FuelType ='COVISION';
				if(isAdd) {
					me.FuelExpenceAppEvidList.push(valMap);
				}
				
				FuelForm = accComm.accHtmlFormSetVal(FuelForm, valMap);
				FuelForm = accComm.accHtmlFormDicTrans(FuelForm);
				
				$("#fuelExpenceList_trSum").before(FuelForm);
				
				me.makeDateField(valMap.ProofCode, valMap.KeyNo, Rownum);
				var areaId = $("[name=BizTripDateArea][proofcd="+valMap.ProofCode+"][keyno="+valMap.KeyNo+"][rownum="+Rownum+"]").attr("id");
				$("#"+areaId+"_Date").val(valMap.BizTripDate);
				
				me.setSelectCombo(valMap.ProofCode, valMap.KeyNo, Rownum);
				$("[name=FuelTypeSelectField][proofcd="+valMap.ProofCode+"][keyno="+valMap.KeyNo+"][rownum="+Rownum+"]").val((valMap.FuelType == undefined ? "" : valMap.FuelType));
				$("[name=FuelTypeSelectField][proofcd="+valMap.ProofCode+"][keyno="+valMap.KeyNo+"][rownum="+Rownum+"]").trigger("onchange");
				
				me.setFuelAmount(false, Rownum);
			},
			
			//콤보 설정
			setSelectCombo : function(ProofCode, KeyNo, Rownum){
				var me = this;
				if(me.FuelExpenceTypeHtml != '') {
					$("[name=FuelTypeSelectField][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").html(me.FuelExpenceTypeHtml);
				} else {
					$.ajax({
						type:"POST",
						url:"/account/accountCommon/getBaseCodeDataAll.do",
						data:{
							codeGroups : "FuelExpenceType",
							CompanyCode : CompanyCode
						},
						async: false,
						success:function (data) {
							if(data.result == "ok"){
								var FuelTypeList = data.list.FuelExpenceType;
								
								var optionHtml = "<option value=''>"+ "<spring:message code='Cache.ACC_lbl_choice' />" +"</option>";
								for(var i = 0; i < FuelTypeList.length; i++) {
									optionHtml += "<option value='"+FuelTypeList[i].Code+"' unit='"+FuelTypeList[i].ReservedFloat+"'>"+FuelTypeList[i].CodeName+"</option>";
								}
								
								me.FuelExpenceTypeHtml = optionHtml;
								
								$("[name=FuelTypeSelectField][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]").html(optionHtml);
							}
							else{
								Common.Error(data);
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); //오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					});
				}
			},
			
			makeDateField : function(ProofCode, KeyNo, Rownum) {
				var dateArea = $("[name=BizTripDateArea][proofcd="+ProofCode+"][keyno="+KeyNo+"][rownum="+Rownum+"]");
				var areaID = $(dateArea).attr("id");
					
				makeDatepicker(areaID, areaID+"_Date", null, null, null);
			},
			
			deleteFuelExpence : function() {
				var me = this;
				var fieldList = $("input[type=checkbox][name=RowCk]:checked");
				 
				if(fieldList.length==0){
					Common.Inform("<spring:message code='Cache.ACC_msg_noselectdata' />");
					return;
				}
				for(var i=0;i<fieldList.length; i++){
			   		var checkedItem = fieldList[i];
					var Rownum = checkedItem.getAttribute("rownum");
					$("tr[name=FuelRowTR][rownum="+Rownum+"]").remove();
					var index = -1;
					$(me.FuelExpenceAppEvidList).each(function(i, obj) {
					    if(obj.Rownum == Rownum) {
					        index = i;
					    }
					});
					me.FuelExpenceAppEvidList.splice(index, 1);
			   	}
				me.setFuelAmountTotal();
			},
			
			//일비 증빙 list에 값을 세팅
			setListVal : function(obj, Field, Rownum) {
				var me = this;
				var val = obj.value;
				
				var getItem = fn_findListItem(me.FuelExpenceAppEvidList, "Rownum", Rownum);
				
				if(Field != "BizTripDate") {
					getItem[Field] = val;
				} else {
					getItem[Field] = $("#"+obj.id+"_Date").val();
					getItem[Field+"Str"] = val;
				}
				 
				if(Field == "FuelType" || Field == "Distance") {
					if(Field == "FuelType") {
						var unitPrice = $(obj).find("option:selected").attr("unit");
						$("[name=FuelUnitPriceField][rownum="+Rownum+"]").val(unitPrice);
						getItem["FuelUnitPrice"] = unitPrice;
						
						var fuelTypeNm = $(obj).find("option:selected").text();
						getItem["FuelTypeNM"] = fuelTypeNm;
					}
					else{
						val = val.replace(/[^0-9,.]/g, "");
						var numVal = ckNaN(AmttoNumFormat(val));
						if(numVal>99999999999){
							numVal = 99999999999;
						}
						val = numVal;
						obj.value = toAmtFormat(numVal);
					}
					me.setFuelAmount(true, Rownum, getItem);
				}
			},
			
			setFuelAmount : function(isNew, Rownum, getItem) {
				var me = this;
				var distance = Number($("[name=DistanceField][rownum="+Rownum+"]").val().replace(/,/gi, ''));
				var unitPrice = parseFloat($("[name=FuelUnitPriceField][rownum="+Rownum+"]").val().replace(/,/gi, ''));
				if(isNaN(unitPrice)) {
					unitPrice = 0;
				}
				var fuelType = $("[name=FuelTypeSelectField][rownum="+Rownum+"]").val();
				var standard = 10; //연비 계산
				if(fuelType == "LPG") {
					standard = 5;
				} else if (fuelType == "COVISION") {
					standard = 1;
				}
				
				$("[name=FuelRealPriceField][rownum="+Rownum+"]").val(toAmtFormat(Math.round(distance / standard * unitPrice)));
				
				if(isNew) {
					getItem.FuelRealPrice = Math.round(distance / standard * unitPrice);
				}
				
				me.setFuelAmountTotal();				
			},
			setFuelAmountTotal : function() {				
				var sum = 0;		
				var Dsum = 0;
				for(var i = 0; i < $("[name=FuelRealPriceField]").length; i++) {
					Dsum += Number($("[name=DistanceField]").eq(i).val().replace(/,/gi, ''));
					sum += Number($("[name=FuelRealPriceField]").eq(i).val().replace(/,/gi, ''));
				}
				$("#distanceTotalSum").html(toAmtFormat(Math.round(Dsum)));
				$("#fuelAmountTotalSum").html(toAmtFormat(Math.round(sum)));
			},
			
			CheckValidation : function(){						
				var me = this;
				for(var i=0; i<me.FuelExpenceAppEvidList.length; i++)
				{
					var item = me.FuelExpenceAppEvidList[i];
					if(isEmptyStr(item.BizTripDate)){
						var msg = "<spring:message code='Cache.ACC_lbl_noData_BizTripDate' />"; //출장일자를 입력하세요.
						Common.Inform(msg);
						return;
					}
					if(isEmptyStr(item.StartPoint)){
						var msg = "<spring:message code='Cache.ACC_lbl_noData_StartPoint' />"; //출발지를 입력하세요.
						Common.Inform(msg);
						return;
					}
					if(isEmptyStr(item.EndPoint)){
						var msg = "<spring:message code='Cache.ACC_lbl_noData_EndPoint' />"; //목적지를 입력하세요.
						Common.Inform(msg);
						return;
					}
					if(isEmptyStr(item.FuelType)){
						var msg = "<spring:message code='Cache.ACC_lbl_noData_FuelType' />"; //유류타입을 선택하세요.
						Common.Inform(msg);
						return;
					}
					if(isEmptyStr(item.Distance)){
						var msg = "<spring:message code='Cache.ACC_lbl_noData_Distance' />"; //이동거리를 입력하세요.
						Common.Inform(msg);
						return;
					}
				}
				me.applyFuelInfo();
			},
			
			applyFuelInfo : function(){
				var me = this;
				var returnObj = [];
				var FuelExpenceAppEvidList = me.FuelExpenceAppEvidList;
	            var DistanceMap = fn_ReturnValue();
	            returnObj['FuelExpenceAppEvidList'] = FuelExpenceAppEvidList;
	            returnObj['Distance'] = DistanceMap;
				if(FuelExpenceAppEvidList.length == 0){
					Common.Inform("<spring:message code='Cache.ACC_msg_noApplyData' />");		//반영할 데이터가 없습니다.
					return;
				}
				if (me.jsonCode=='D02' &&DistanceMap.Distance == 0) {
	                Common.Inform("<spring:message code='Cache.ACC_lbl_NoMapData' />");		//지도정보가 없습니다.
                    return;
                }
				Common.Confirm(Common.getDic("ACC_msg_ckApply"), "Confirmation Dialog", function(result){	//반영하시겠습니까?
		       		if(result){
		       			me.closeLayer();
						try{
                            accountCtrl.popupCallBackStrObj([returnObj]);
						}catch (e) {
							coviCmn.traceLog(e);
							coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
						}
		       		}
	       		});
			},
			
			closeLayer : function(){
				var isWindowed = CFN_GetQueryString("CFN_OpenedWindow");
				var popupID	= CFN_GetQueryString("popupID");
				
				if(isWindowed.toLowerCase() == "true") {
					window.close();
				} else {
					parent.Common.close(popupID);
				}
			},
			
			distanceCheckAll : function(value) {
				var chkAll = $("#expApp_fuelChkAll").prop("checked");
				$("input[type=checkbox][name=RowCk]").prop("checked", chkAll);
			},
			
			setRoundTrip : function() {
				var me = this;
				var fieldList = $("input[type=checkbox][name=RowCk]:checked");
				 
				if(fieldList.length==0){
					Common.Inform("<spring:message code='Cache.ACC_msg_noselectdata' />");
					return;
				}else if(fieldList.length > 1){
					Common.Inform("1건만 선택해 주세요.");
					return;
				}
				
				var Rownum = fieldList[0].getAttribute("rownum");
				var getItem = fn_findListItem(me.FuelExpenceAppEvidList, "Rownum", Rownum);
	
				var valMap = {};
				valMap.BizTripDateStr = nullToBlank(getItem.BizTripDateStr);
				valMap.BizTripDate = nullToBlank(getItem.BizTripDate);
				valMap.StartPoint = nullToBlank(getItem.EndPoint);
				valMap.EndPoint = nullToBlank(getItem.StartPoint);
				valMap.FuelType = nullToBlank(getItem.FuelType);
				valMap.FuelTypeNM = nullToBlank(getItem.FuelTypeNM);
				valMap.Distance = toAmtFormat(nullToBlank(getItem.Distance));
				valMap.FuelUnitPrice = toAmtFormat(nullToBlank(getItem.FuelUnitPrice));
				valMap.FuelRealPrice = toAmtFormat(nullToBlank(getItem.FuelRealPrice));
				
				//출발지, 도착지 변경
				me.addFuelExpence(undefined, valMap);
				me.setFuelAmountTotal();
				
				$("#expApp_fuelChkAll").prop("checked",false);
				$("input[type=checkbox][name=RowCk]").prop("checked", false);
			},
			
			fuelTabClick : function(obj, type){
				var me = this;
				
				if(type=="T"){
					$("[name=fuelTabDiv][tabtype=T]").addClass("l-contents-tabs__item--active");
					$("[name=fuelTabDiv][tabtype=K]").removeClass("l-contents-tabs__item--active");
					$("[name=TmapArea]").css("display", "flex");
					$("[name=KakaoArea]").css("display", "none");
				}else if(type=="K"){
					$("[name=fuelTabDiv][tabtype=T]").removeClass("l-contents-tabs__item--active");
					$("[name=fuelTabDiv][tabtype=K]").addClass("l-contents-tabs__item--active");
					$("[name=TmapArea]").css("display", "none");
					$("[name=KakaoArea]").css("display", "");
					me.kakaoSearchList();
				}
			},
			
			setHeaderData : function() {
				var me = this;
				me.params.headerData = [	{	key:'departure_time',	label:"사용일자",		width:'60', align:'center',
				                        		  formatter:function () {
				    	                			  return getStringDateToString("yyyy.MM.dd",this.item.departure_time);
				    	                	  	   }
											},	//사용일자
				    		          	 	{	key:'departure_point',	label:"출발지",		width:'100', align:'center',
												formatter:function () {
				    								var rtStr =	""
				    											+	"<a onclick='ExpenceApplicationFuelPopup.setUseList(\""
		    													+			getStringDateToString("yyyy.MM.dd",this.item.departure_time) + "\",\""
		    													+			this.item.departure_point		+"\",\""
		    													+			this.item.arrival_point		+"\",\""
		    													+			this.item.total_distance		+"\""
				    											+		"); return false;'>"
				    											+		"<font color='blue'>"
				    											+			this.item.departure_point
				    											+		"</font>"
				    											+	"</a>";
				    								return rtStr;
				    							}
				    		          	 	},	//출발지
				    		          	   	{	key:'arrival_point',	label:"도착지",		width:'100', align:'center'},	//도착지
				    		          	 	{	key:'total_distance',	label:"주행거리",		width:'60', align:'center'}		//주행거리
										]
				var gridPanel	= me.params.gridPanel;
				var gridHeader	= me.params.headerData;
				accountCtrl.setViewPageGridHeader(gridHeader,gridPanel);
			},
			
			kakaoSearchList : function(){
				var me = this;
				var start_date = $('#expAppFuel_dateArea_St').val().replaceAll(".","");
				var end_date = $('#expAppFuel_dateArea_Ed').val().replaceAll(".","");
				
				if(start_date == null || start_date == "" || start_date == undefined || end_date == null || end_date == "" || end_date == undefined){
					Common.Inform("<spring:message code='Cache.ACC_msg_inputUseDate' />");	//사용일자를 입력하세요.
					return;
				}
				
				me.setHeaderData();
	 			
				var gridAreaID	= "gridArea";
				var gridPanel	= me.params.gridPanel;
				var gridHeader	= me.params.headerData;
				var ajaxUrl		= "/account/accountCommon/getKakaoBizUseList.do";
				var ajaxPars	= {	
									StartDate : start_date,
									EndDate	: end_date,
									Vertical : "NAVI"
								};
				
				var pageNoInfo		= 1;
				var pageSizeInfo	= 200;
				
				var gridParams = {	"gridAreaID"	: gridAreaID
								,	"gridPanel"		: gridPanel
								,	"gridHeader"	: gridHeader
								,	"ajaxUrl"		: ajaxUrl
								,	"ajaxPars"		: ajaxPars
								,	"pageNoInfo"	: pageNoInfo
								,	"pageSizeInfo"	: pageSizeInfo
								,	"popupYN"		: 'Y'
								, 	"pagingTF"		: false
								,	"height"		: "300px"
				}
				
				accountCtrl.setViewPageBindGrid(gridParams);
				accountCtrl.setGridBodyOption(gridPanel, ajaxUrl, ajaxPars);
			},
			
			setDefaultDate : function(){
				var nowDate = new Date();
				var preDate = new Date(nowDate.getFullYear(), nowDate.getMonth()-1 , 1);
				
				$('#expAppFuel_dateArea_St').val(preDate.format("yyyy.MM.dd"));
				$('#expAppFuel_dateArea_Ed').val(nowDate.format("yyyy.MM.dd"));
			},
			
			setUseList : function(time,departure,arrival,distance){
				var me = this;
				var rownum = "";
				
				if(me.FuelExpenceAppEvidList.length == 1 && me.FuelExpenceAppEvidList[0].StartPoint == undefined && me.FuelExpenceAppEvidList[0].EndPoint == undefined){
					var field = $("[name=BizTripDateArea]").children(".adDate").last();
					field.val(time)
					field.keyup();
					
					var field = $("[name=StartPointField]").last();
					field.val(departure)
					field.keyup();
					
					var field = $("[name=EndPointField]").last();
					field.val(arrival)
					field.keyup();
					
					var field = $("[name=DistanceField]").last();
					field.val(distance)
					field.keyup();
				}else{
					var valMap = {};
					valMap.BizTripDateStr = nullToBlank(time);
					valMap.BizTripDate = nullToBlank(time);
					valMap.StartPoint = nullToBlank(departure);
					valMap.EndPoint = nullToBlank(arrival);
					valMap.Distance = toAmtFormat(nullToBlank(distance));
					
					me.addFuelExpence(undefined, valMap);
				}
			}
	}
	window.ExpenceApplicationFuelPopup = ExpenceApplicationFuelPopup;
})(window);

ExpenceApplicationFuelPopup.popupInit();
	
</script>