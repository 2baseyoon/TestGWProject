<%@ page import="egovframework.coviframework.util.RedisDataUtil" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
		 pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
	String WorkPlaceWithGrouping = RedisDataUtil.getBaseConfig("WorkPlaceWithGrouping");
	if(WorkPlaceWithGrouping.equalsIgnoreCase("Y")){
		WorkPlaceWithGrouping = "Y";
	}else{
		WorkPlaceWithGrouping = "N";
	}
%>
<c:set var="workPlaceWithGrouping" value="<%=WorkPlaceWithGrouping%>" />
<style>
.AXGrid .AXgridScrollBody .AXGridBody .gridBodyTable tbody tr.hover {
	background: #f5f5f5;
}
input[type="checkbox"] { display:inline-block; }
</style>

<div class='cRConTop titType AtnTop'>
	<h2 class="title"><spring:message code='Cache.MN_896'/></h2>
	<div class="searchBox02"> 
		<span><input type="text" id="schUrName"/><button type="button" class="btnSearchType01" onclick="search()"><spring:message code='Cache.btn_search' /></button></span>
		<a href="#" class="btnDetails"><spring:message code='Cache.lbl_detail' /></a>
	</div>
</div>
<div class='cRContBottom mScrollVH'>
	<div class="inPerView type02">
		<div>
			<div class="selectCalView">			
				<select class="selectType02" id="schTypeSel">
					<option value="workZoneName"><spring:message code="Cache.lbl_workplace" /></option>
					<option value="workZoneAddr"><spring:message code="Cache.lbl_workplaceaddr" /></option>
				</select>
				<div class="dateSel type02">
					<input type="text" id="schTxt">
				</div>											
			</div>
			<div>
				<a href="#" class="btnTypeDefault btnSearchBlue nonHover"><spring:message code='Cache.btn_search' /></a>
			</div>
		</div>
	</div>
	<div class="ATMCont">
		<div class="ATMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft" id="selectBoxDiv"> 
				<!-- 근로정보 추가 -->
				<a href="#" class="btnTypeDefault btnTypeBg btnAttAdd" id="btnWorkPlaceAdd"><spring:message code='Cache.btn_attendaddWorkPlace'/></a>
				<!-- 삭제 -->
				<a href="#" class="btnTypeDefault left" id="btnWorkPlaceDel"><spring:message code='Cache.btn_Delete'/></a>
				<!-- 엑셀저장 -->
				<a href="#" class="btnTypeDefault btnExcel" id="btnExcelList"><spring:message code="Cache.lbl_SaveToExcel"/></a>
				<%--<a href="#" class="btnTypeDefault btnExcel" id="btnRestApiTest">restApiTest</a>--%>
			</div>
			<div class="pagingType02 buttonStyleBoxRight">
				<button href="#" class="btnRefresh" type="button"></button>
				<select class="selectType02 listCount" id="listCntSel">
					<option value="10" selected>10</option>
					<option value="15">15</option>
					<option value="20">20</option>
					<option value="30">30</option>
					<option value="50">50</option>
					<option value="100">100</option>
				</select>
			</div>
		</div>
		<div class="tblList tblCont">
			<div id="gridDiv"></div>
		</div>
	</div>
</div>

<script>
var grid = new coviGrid();
var wiUrArry = new Array();
var WorkPlaceWithGrouping = "<%=WorkPlaceWithGrouping%>";
var pageSize = CFN_GetQueryString("pageSize")== 'undefined'?10:CFN_GetQueryString("pageSize");

if(CFN_GetCookie("AttListCnt")){
	pageSize = CFN_GetCookie("AttListCnt");
}
if(pageSize===null||pageSize===""||pageSize==="undefined"){
	pageSize=10;
}

$("#listCntSel").val(pageSize);

$(document).ready(function(){
	init();
	setGrid();
	search();
});

//merge cell 시 좌우 border 미표기로 수동 표기처리 이나, grid 자체에서 보완 하여 미사용
/*$(window).load(function(){
	//merged cell 사용시
	$("tr td").each(function( index ) {
		if($( this ).attr("rowspan")!="" && !isNaN(Number($( this ).attr("rowspan"))) && Number($( this ).attr("rowspan"))>1) {
			$(this).css({"border-left":"solid 1px #eee", "border-right":"solid 1px #eee"});
		}
	});
});*/

function init(){
	
	//검색
	$('#schUrName').on('keypress', function(e){ 
		if (e.which == 13) {
	        e.preventDefault();
	        
	        var schName = $('#schUrName').val();
	        
	        $('#schTypeSel').val('workZoneName');
	        $('#schTxt').val(schName);
			
	        search();
	    }
	});
	//상세 검색에 input enter fun.
	$('#schTxt').on('keypress', function(e){
		if (e.which == 13) {
			e.preventDefault();
			search();
		}
	});
	
	// 검색 버튼
	$('.btnSearchBlue').on('click', function(e) {
		search();
	});
	$('.btnRefresh').on('click', function(e) {
		search();
	});
	// 그리드 카운트
	$('#listCntSel').on('change', function(e) {
		grid.page.pageSize = $(this).val();
		CFN_SetCookieDay("AttListCnt", $(this).find("option:selected").val(), 31536000000);
		grid.reloadList();
	});
	
	// 상세 보기
	$('.btnDetails').on('click', function(){
		var mParent = $('.inPerView');
		if(mParent.hasClass('active')){
			mParent.removeClass('active');
			$(this).removeClass('active');
		}else {
			mParent.addClass('active');
			$(this).addClass('active');
		}
	});
	
	$("#btnExcelList").on("click",function(){
		excelListDownload();
	});


	$("#btnRestApiTest").on("click",function(){
		$.ajax({
			type:"GET",
			dataType : "json",
			url:"/groupware/attendAdmin/getWorkPlaceList.rest",
			success:function (data) {
				if(data.status !=="SUCCESS"){
					Common.Warning("<spring:message code='Cache.msg_sns_03'/>");
					search();
				}
			}
		});
	});
	//근무지 추가 팝업
	$("#btnWorkPlaceAdd").on('click',function(){
		goAddWorkPlacePop('add', 0);
	});
	
	//근무지 삭제
	$("#btnWorkPlaceDel").on('click',function(){
		delWorkPlace();
	});
	
	
}


//그리드 세팅
function setGrid() {
	// header
	var	headerData = [//LocationSeq, CompanyCode, WorkZone, WorkAddr, WorkPointX, WorkPointY, AllowRadius, ValidYn
			{ key:'LocationSeq', label:'chk', width:'30', align:'center', formatter:'checkbox'},
			<c:if test="${workPlaceWithGrouping == 'Y'}">
			{ key:'WorkZoneGroupNm', label:'<spring:message code="Cache.lbl_workplaceGroupNm" />', width:'100', align:'center'},
			</c:if>
			{ key:'ValidYn', label:"<spring:message code='Cache.lbl_IsUse' />",width:'60', align:'center',		//사용여부 <spring:message code='Cache.lbl_IsUse' />
				formatter : function () {
					var _div = $('<div />', {
						class : "alarm type01"
					});
					
					var _a = $('<a />', {
						class : "onOffBtn"
						,id : "dataGridRowId_"+this.item.LocationSeq
						,"data-LocationSeq" : this.item.LocationSeq
						,"data-WorkZoneGroupNm" : this.item.WorkZoneGroupNm
						,"data-CompanyCode" : this.item.CompanyCode
						,"data-WorkZone" : this.item.WorkZone
						,"data-WorkAddr" : this.item.WorkAddr
						,"data-WorkPointX" : this.item.WorkPointX
						,"data-WorkPointY" : this.item.WorkPointY
						,"data-AllowRadius" : this.item.AllowRadius
						,"data-ValidYn" : this.item.ValidYn
					});
					_a.attr("onclick","updateWorkPlaceStatus(this)");
					if(this.item.ValidYn=="Y") { _a.addClass("on"); }
					_a.append("<span></span>");
					_div.append(_a);
					return _div[0].outerHTML;
				}
			},
			{key:'WorkZone', label:'<spring:message code="Cache.lbl_workplace" />', width:'100', align:'center',
				formatter:function () {
					var html = "<p class='tx_Team'><a onclick='goModWorkPlacePopup(\"" + this.item.LocationSeq + "\");'  class='gridLink'>";
					html += this.item.WorkZone;
					html += "</a></p>";

					return html;
				}
			},
			{key:'WorkAddr', label:'<spring:message code="Cache.lbl_workplaceaddr" />', width:'140', align:'left'},
			{key:'AllowRadius', label:'<spring:message code="Cache.lbl_workplaceRadius" />', width:'60', align:'center'}
		];
	
	grid.setGridHeader(headerData);
	
	// config
	var configObj = {
		targetID : "gridDiv",
		listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
		height:"auto",			
		paging : true,
		<c:if test="${workPlaceWithGrouping == 'Y'}">
		mergeCells:[1],
		</c:if>
		page : {
			pageNo:1,
			pageSize: $("#listCntSel").val(),
		}
	};
	grid.setGridConfig(configObj);
}

function search(){
	
	var params = {
				  schTypeSel : $('#schTypeSel').val(),
				  schTxt : $('#schTxt').val(),
			  	  sortBy : "WorkZone ASC"
			  	  };
	 
	grid.page.pageNo = 1;
	
	// bind
	grid.bindGrid({
		ajaxUrl : "/groupware/attendAdmin/getWorkPlaceList.do",
		ajaxPars : params
	});


}


//근로지 추가 팝업
function goAddWorkPlacePop(mode, SchSeq){
	var param = {"WorkZoneGroupNm":"", "Zone":"", "Addr":"", "PointX":"", "PointY":"", "popupTitle":"근무지 추가 지도팝업"};
	AttendUtils.openMapWorkPlacePopup('AttendMapPopup', "add", param);
}
//근로지 수정팝법
function goModWorkPlacePopup(rowId){

	var obj = $("#dataGridRowId_"+rowId);
	//LocationSeq, CompanyCode, WorkZone, WorkAddr, WorkPointX, WorkPointY, AllowRadius, ValidYn
	var params = {
		LocationSeq : obj.attr("data-LocationSeq")
		<c:if test="${workPlaceWithGrouping == 'Y'}">
		,WorkZoneGroupNm : obj.attr("data-WorkZoneGroupNm")
		</c:if>
		,CompanyCode : obj.attr("data-CompanyCode")
		,Zone : obj.attr("data-WorkZone")
		,Addr : obj.attr("data-WorkAddr")
		,PointX : obj.attr("data-WorkPointX")
		,PointY : obj.attr("data-WorkPointY")
		,AllowRadius : obj.attr("data-AllowRadius")
		,ValidYn : obj.attr("data-ValidYn")
		,popupTitle : "근무지 수정 지도팝업"
	}

	AttendUtils.openMapWorkPlacePopup('AttendMapPopup', "modify", params);
}

function setMapLocation(param){
	var res_mode = param["mode"];
	var res_LocationSeq = param["LocationSeq"];
	var res_WorkZoneGroupNm = param["WorkZoneGroupNm"];
	var res_CompanyCode = param["CompanyCode"];
	var res_oriZone = param["oriZone"];
	var res_Zone = param["Zone"];
    //근무지 등록//WorkZoneGroupNm, LocationSeq, CompanyCode, WorkZone, WorkAddr, WorkPointX, WorkPointY, AllowRadius, ValidYn
	var params = {};
	var ajaxUrl = "";
	if(res_mode==="add") {
		ajaxUrl = "/groupware/attendAdmin/insertWorkPlace.do";
		params = {
			WorkZoneGroupNm: param["WorkZoneGroupNm"]
			, CompanyCode: param["CompanyCode"]
			, WorkZone: param["Zone"]
			, WorkAddr: param["Addr"]
			, WorkPointX: param["PointX"]
			, WorkPointY: param["PointY"]
			, AllowRadius: param["AllowRadius"]
			, ValidYn: "Y"//신규 등록은 기본 사용 으로 세팅
		};
	}else if(res_mode==="modify") {
		ajaxUrl = "/groupware/attendAdmin/updateWorkPlace.do";
		params = {
			LocationSeq: param["LocationSeq"]
			, WorkZoneGroupNm: param["WorkZoneGroupNm"]
			, CompanyCode: param["CompanyCode"]
			, WorkZone: param["Zone"]
			, WorkAddr: param["Addr"]
			, WorkPointX: param["PointX"]
			, WorkPointY: param["PointY"]
			, AllowRadius: param["AllowRadius"]
			, ValidYn: "Y"//신규 등록은 기본 사용 으로 세팅
		};
	}else {
		alert("fail ajax call mode!");
		return;
	}
	$.ajax({
		type:"POST",
		dataType : "json",
		data: params,
		url: ajaxUrl,
		success:function (data) {
			if(data.status =="SUCCESS"){
				search();
			}else{
				Common.Warning("<spring:message code='Cache.msg_sns_03'/>");
				search();
			}
		}
	});
}

var weekendStr = Common.getBaseCode("AttendWeekend").CacheData;
var workcodeStr = Common.getBaseCode("WorkCode").CacheData;
var unittermStr = Common.getBaseCode("UnitTerm").CacheData;
//요일변화
function weekendFormat(s,c){
	var weekArry = new Array();

	var index = 0;
	while (index < s.length) {
		if(s.charAt(index)== c ){
			weekArry.push(weekendStr[index].CodeName);
		}
		index ++;
	}
	
	var returnStr = "";
	for(var i=0;i<weekArry.length;i++){
		if(i!=0){
			returnStr += ",";
		}
		returnStr += weekArry[i];
	}
	return returnStr;
}

function ruleFormat(wt,wc,ut,ad,pr){
	var returnStr = "";
	var sWc = "";
	for(var i=0;i<workcodeStr.length;i++){
		if(workcodeStr[i].Code == wc){
			sWc = workcodeStr[i].CodeName;
			break;
		}
	}
	
	var sUt = "";
	for(var i=0;i<unittermStr.length;i++){
		if(unittermStr[i].Code == ut){
			sUt = unittermStr[i].CodeName;
			break;
		}
	}
	
	returnStr += wt+pr;
	returnStr += sWc+pr;
	returnStr += sUt+pr;
	returnStr += ad
	return returnStr;
}

//리스트 엑셀 다운로드
function excelListDownload(){
	location.href = "/groupware/attendAdmin/workPlaceExcelListDownload.do";
}
function updateWorkPlaceStatus(o){
	var obj = $(o);
	//LocationSeq, CompanyCode, WorkZone, WorkAddr, WorkPointX, WorkPointY, AllowRadius, ValidYn
	var params = {
		LocationSeq : obj.attr("data-LocationSeq")
		,CompanyCode : obj.attr("data-CompanyCode")
		,WorkZoneGroupNm : obj.attr("data-WorkZoneGroupNm")
		,WorkZone : obj.attr("data-WorkZone")
		,WorkAddr : obj.attr("data-WorkAddr")
		,WorkPointX : obj.attr("data-WorkPointX")
		,WorkPointY : obj.attr("data-WorkPointY")
		,AllowRadius : obj.attr("data-AllowRadius")
	}
	
	if(obj.attr("class").lastIndexOf('on')>0){
		params.ValidYn = "N";
		obj.removeClass("on");
	}else{
		params.ValidYn = "Y";
		obj.addClass("on");
	}
	$.ajax({
		type:"POST",
		dataType : "json",
		data: params,
		url:"/groupware/attendAdmin/updateWorkPlace.do",
		success:function (data) {
			if(data.status =="SUCCESS"){
				//search();
			}else{
				Common.Warning("<spring:message code='Cache.msg_sns_03'/>");
				search();
			}
		}
	});
}


//근무지 삭제
function delWorkPlace(){
	if($("input[name=chk]:checked").length==0){
		Common.Warning("<spring:message code='Cache.msg_selectTargetDelete'/>");
	}else{
		Common.Confirm("<spring:message code='Cache.msg_Common_08' />", "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
				
				var delArry = new Array();
				for(var i=0;i<$("input[name=chk]:checked").length;i++){
					delArry.push($("input[name=chk]:checked").eq(i).val());
				}
				var params = {
					LocationSeqArr : JSON.stringify(delArry)
				};
				$.ajax({
					type:"POST",
					dataType : "json",
					data: params,
					url:"/groupware/attendAdmin/delWorkPlace.do",
					success:function (data) {
						if(data.status =="SUCCESS"){
							if(data.msg!=""){
								Common.Warning(data.msg);
							}
							search();
						}else{
							Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
						}
					}
				});
			}
		});
	}
}


</script>
