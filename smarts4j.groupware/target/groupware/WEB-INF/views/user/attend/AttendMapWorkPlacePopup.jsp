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
<!--  <script type="text/javascript" src="https://maps.googleapis.com/maps/api/js?key=AIzaSyD1ge_u7His6Vz46-iyxh45IUDwdO8fL64">    </script>-->


<body>
<div class="layer_divpop ui-draggable docPopLayer" style="width:100%;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">
		<div class="ATMgt_popup_wrap" >
			<table class="ATMgt_popup_table type02" cellspacing="0" cellpadding="0">
				<tbody>
					<tr id="tr_groupzone_nm">
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_workplaceGroupNm'/></td>
						<td><input name="input_workGroupZoneNm" placeholder="<spring:message code='Cache.msg_typeinWorkPlaceGroupNm'/>"  class="w100" id="input_workGroupZoneNm" type="text" value="" maxlength="100"></td>
					</tr>
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_workplace'/></td>
						<td><input name="input_workZoneNm" placeholder="<spring:message code='Cache.msg_typeinWorkPlaceNm'/>" class="w100" id="input_workZoneNm" type="text" value="" maxlength="100"></td>
					</tr>
					<tr>
					 	<td class="ATMgt_T_th"><spring:message code='Cache.lbl_workplaceaddr'/></td>
						<td>
							<div class="searchBox02">
								<span id="placeAutoComp"  style="display: inline-block;border:1px solid #DDDDDD" class="autoCompleteCustom place" onclick="deleteAddrInput();" onkeydown="javascript:if(event.keyCode==13) {deleteAddrInput();}" >
									<input id="input_workAddr" style="width:420px !important;"  maxlength="1000"  onfocus="scheduleUser.deletePlaceInput();" onkeydown="javascript:if(event.keyCode==13) {scheduleUser.deletePlaceInput();}" type="text" placeholder="<spring:message code='Cache.msg_mustWriteAddress'/>" ><!-- 주소를 입력하세요. -->
									<button class="btnSearchType01" type="button"><spring:message code='Cache.lbl_search'/></button>
								</span>
							</div>
						</td>
					</tr>
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_CoordinateRadius'/>(m)</td> <!-- 좌표반경 -->
						<td><input name="AllowRadius" placeholder="100m" style="width: 70px !important;" id="AllowRadius" type="text" value="100" data-axbind="number"> <span style="vertical-align: bottom;">m</span></td>
					</tr>
				</tbody>
			</table>
			<div class="ATMgt_map_box">
				<div  id="map_ma" class="ATMgt_Map_img" style="height:270px">			</div>	
			</div>	
			<div class="bottom mtop20">
		          	<input type="hidden" id="PointX" name="PointX">
		          	<input type="hidden" id="PointY" name="PointY">
				<a href="#" class="btnTypeDefault btnTypeChk" id="btnAdd"><spring:message code='Cache.btn_register'/></a> <!-- 등록 -->
				<a href="#" class="btnTypeDefault" id="btnDivClose"><spring:message code='Cache.btn_Close'/></a> <!-- 닫기 -->
			</div>
		</div>	
	</div>
</div>	
</body>
<script>
/**
 * Google Map API 주소의 callback 파라미터와 동일한 이름의 함수이다.
 * Google Map API에서 콜백으로 실행시킨다.
 */
var LocationSeq = CFN_GetQueryString("LocationSeq");
var WorkZoneGroupNm = decodeURI(CFN_GetQueryString("WorkZoneGroupNm"));
var CompanyCode = CFN_GetQueryString("CompanyCode");
var mode = CFN_GetQueryString("mode");
var openerID = CFN_GetQueryString("openerID");
var Zone	= decodeURI(CFN_GetQueryString("Zone")) ;
var oriZone	= decodeURI(CFN_GetQueryString("Zone")) ;
var Addr	= decodeURI(CFN_GetQueryString("Addr")) ;
var X_point	= CFN_GetQueryString("PointX") ;
var Y_point	= CFN_GetQueryString("PointY");
var map;
var marker ;
var zoomLevel		= Number("<%=googleMapLevel%>");				// 지도의 확대 레벨 : 숫자가 클수록 확대정도가 큼.
var AllowRadiusMap;
var AllowRadiusVal  = Number(CFN_GetQueryString("AllowRadius"));
var ValidYn = CFN_GetQueryString("ValidYn");
var WorkPlaceWithGrouping = "${WorkPlaceWithGrouping}";

if(AllowRadiusVal==null || AllowRadiusVal==="undefined" || isNaN(AllowRadiusVal)){
	AllowRadiusVal = 100;
}

var PositionXY;

$(document).ready(function() {
	// 기본 javascript bind함수가 변경되서 다시 원복 - /mail/resources/script/cmmn/cmmn.func.js
	if (Function.prototype._original_bind && Function.prototype.bind) {
		Function.prototype.bind = Function.prototype._original_bind;
	}
	
	//근무지 그룹 단위 관리 기능 사용 여부 처리
	if(WorkPlaceWithGrouping==="N") {
		$("#tr_groupzone_nm").hide();
	}

	if(mode=="modify" ){
		if(AllowRadiusVal!==100) {
			$("#AllowRadius").val(AllowRadiusVal);
		}
		
		$("#btnAdd").html("수정");
	}
	
	//AllowRadius onChange fun.
	$( "#AllowRadius" ).keyup(function() {
		if ($.trim($("#AllowRadius").val()) != "") {
			var radiusVal = 0;
			radiusVal = Number($("#AllowRadius").val());
			if (!Number.isInteger(radiusVal)) {
				Common.Warning(Common.getDic("msg_ObjectUR_29"));			//근무제명 넣기
				return false;
			} else {//정상 반경 값 입력시
				AllowRadiusVal = radiusVal;
				AllowRadiusMap.setRadius(parseFloat(AllowRadiusVal));
			}
		}
	});

	if (WorkZoneGroupNm=="") WorkZoneGroupNm="";
	if (Zone=="") Zone="";
	if (X_point=="") X_point="126.8381680267984";
	if (Y_point=="") Y_point="37.56185560026877";

	$("#input_workGroupZoneNm").val(WorkZoneGroupNm);
	$("#input_workZoneNm").val(Zone);
	$("#input_workAddr").val(Addr);
	$("#PointX").val(X_point);
	$("#PointY").val(Y_point);

	var markerTitle		= Zone;		// 현재 위치 마커에 마우스를 오버을때 나타나는 정보
	var markerMaxWidth	= 300;				// 마커를 클릭했을때 나타나는 말풍선의 최대 크기
	var myLatlng = new google.maps.LatLng(Y_point, X_point);
	PositionXY = myLatlng;
	var mapOptions = {
		zoom: zoomLevel,
		center: myLatlng,
		mapTypeId: google.maps.MapTypeId.ROADMAP
	}

	map = new google.maps.Map(document.getElementById('map_ma'), mapOptions);
	marker = new google.maps.Marker({
		position: myLatlng,
		map: map,
		title: markerTitle
	});

	AllowRadiusMap = new google.maps.Circle({
		center: PositionXY,
		radius: AllowRadiusVal,
		strokeColor: "BLUE",
		strokeOpacity: 0.8,
		strokeWeight: 1,
		fillColor: "BLUE",
		fillOpacity: 0.1
	});
	AllowRadiusMap.setMap(map);

	map.addListener('click', function(event) {
		X_point = event.latLng.lng();
		Y_point = event.latLng.lat();
		$("#PointX").val(X_point);
		$("#PointY").val(Y_point);
		PositionXY = new google.maps.LatLng(Y_point, X_point);

		marker.setPosition(new google.maps.LatLng(Y_point, X_point));
		AllowRadiusMap.setCenter(PositionXY);
    });

	coviCtrl.setAddrAutoTags(
		'input_workAddr', //타겟
		{
			count : 10,
			minLength : 1,
			useEnter : false,
			multiselect : true,
			callBackFunction : "deleteAddrInput"
		}
	);

	$("#placeAutoComp").width(425);
	$("#placeAutoComp .ui-autocomplete-multiselect").width(410);
	$("#placeAutoComp .ui-autocomplete-multiselect").css("border","0px");

	$("#btnAdd").click(function(){
		if(WorkPlaceWithGrouping==="Y") {
			if ($.trim($("#input_workGroupZoneNm").val()) == "") {
				Common.Warning(Common.getDic("msg_ObjectUR_30"));			//근무지그룹 넣기
				return false;
			}
		}else{//그룹단위 관리가 아닌경우 그룹명에 근무지명과 동일값 기록 하여 키 조건 수립
			$("#input_workGroupZoneNm").val($("#input_workZoneNm").val());
		}
		
		if ($.trim($("#input_workZoneNm").val()) == "") {
			Common.Warning(Common.getDic("msg_ObjectUR_31"));			//근무지명 넣기
			return false;
		}
		
		if ($.trim($("#AllowRadius").val()) == "") {
			Common.Warning(Common.getDic("msg_ObjectUR_28"));			//근무지 반경 넣기
			return false;
		}
		
		if ($.trim($("#AllowRadius").val()) != "") {
			var radiusVal = 0;
			radiusVal = Number($("#AllowRadius").val());
			if (!Number.isInteger(radiusVal)) {
				Common.Warning(Common.getDic("msg_ObjectUR_29"));			//근무제명 넣기
				return false;
			}
		}

		$.ajax({
			url: "/groupware/attendCommon/getLocationAddressAPI.do",
			type: "post",
			data: {
				x: $("#PointX").val(),
				y: $("#PointY").val(),
			},
			dataType: "json",
			success: function (res) {
				var jsonStr = res.list;

				if (res.status != "SUCCESS") {
					coviCmn.traceLog("error at : coviCtrl.getLocationAddrAPI : ");
				} else {
					if (jsonStr != null) {
						$("#input_workAddr").val(jsonStr.response.result[0].text);
					}
				}
				
				var returnParam = {
					"mode": mode,
					"LocationSeq": LocationSeq,
					"WorkZoneGroupNm": $("#input_workGroupZoneNm").val(),
					"CompanyCode": CompanyCode,
					"oriZone": oriZone,
					"Zone": $("#input_workZoneNm").val(),
					"Addr": $("#input_workAddr").val(),
					"PointX": $("#PointX").val(),
					"PointY": $("#PointY").val(),
					"AllowRadius": $("#AllowRadius").val(),
					"ValidYn": ValidYn
				};
				parent.setMapLocation(returnParam);
				Common.Close();
			},
			error: function (xhr, status, error) {
				var returnParam = {
					"mode": mode,
					"LocationSeq": LocationSeq,
					"oriZone": oriZone,
					"Zone": $("#input_workZoneNm").val(),
					"Addr": $("#input_workAddr").val(),
					"PointX": $("#PointX").val(),
					"PointY": $("#PointY").val(),
					"AllowRadius": $("#AllowRadius").val(),
					"ValidYn": ValidYn
				};
				parent.setMapLocation(returnParam);
				Common.Close();
			}
		});
	});

	$("#btnDivClose").click(function(){
		Common.Close();
	});

	$("#AllowRadius").bindNumber();

	$(".AXanchorIncrease").click(function(){
		var radiusVal = 0;
		radiusVal = Number($("#AllowRadius").val());
		if (!Number.isInteger(radiusVal)) {
			Common.Warning(Common.getDic("msg_ObjectUR_29"));			//근무제명 넣기
			return false;
		} else {//정상 반경 값 입력시
			AllowRadiusVal = radiusVal;
			AllowRadiusMap.setRadius(parseFloat(AllowRadiusVal));
		}
	});

	$(".AXanchorDecrease").click(function(){
		var radiusVal = 0;
		radiusVal = Number($("#AllowRadius").val());
		if (!Number.isInteger(radiusVal)) {
			Common.Warning(Common.getDic("msg_ObjectUR_29"));			//근무제명 넣기
			return false;
		} else {//정상 반경 값 입력시
			AllowRadiusVal = radiusVal;
			AllowRadiusMap.setRadius(parseFloat(AllowRadiusVal));
		}
	});
});

function deleteAddrInput(){	
	if(coviCtrl.getAutoTags("input_workAddr").length > 0){
		$("#input_workAddr").hide();
		var dataMap = JSON.parse($(".ui-autocomplete-multiselect-item").attr("data-json"));
		$("#input_workAddr").val(dataMap["label"]);
	}else{
		$("#input_workAddr").show();
	}
	
	if($("#input_workAddr").val() != "") {
		$.ajax({
			url : "/groupware/attendCommon/getLocationCoordAPI.do",
			type : "post",
			data : {
				addr : $("#input_workAddr").val(),
				admCd : "",
				rnMgtSn : "",
				udrtYn : "",
				buldMnnm : "",
				buldSlno : ""
			},
			dataType : "json",
			success : function(res){
				var jsonStr = res.list;
				
				if(res.status!="SUCCESS"){
					coviCmn.traceLog("error at : coviCtrl.getLocationAPI : ");
				} else {
					if(jsonStr!= null){
						var p = jsonStr.response.result.point;
						var myLatlng = new google.maps.LatLng(p.y, p.x);
						map.panTo(myLatlng);
						marker.setPosition(myLatlng);


						PositionXY = myLatlng;
						AllowRadiusMap.setCenter(PositionXY);

						$("#PointX").val(p.x);
						$("#PointY").val(p.y);
					}
				}
			 },
			 error: function(xhr,status, error){
				 coviCmn.traceLog(error);
			 }
		});
	}
}
</script>