<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<style>
.AXGrid .AXgridScrollBody .AXGridBody .gridBodyTable tbody tr.hover {
	background: #f5f5f5;
}
input[type="checkbox"] { display:inline-block; }
</style>

<div class="cRConTop titType AtnTop">
	<h2 class="title"><spring:message code='Cache.MN_889'/></h2>		
	<div class="searchBox02">
		<span><input type="text" id="schTxt"><button type="button" class="btnSearchType01" onclick="search(1);"><spring:message code='Cache.btn_search'/></button>	<!-- 검색 -->
		</span><a href="#" class="btnDetails"><spring:message code='Cache.lbl_detail'/></a>	<!-- 상세 -->
	</div>				
</div>
<div class="cRContBottom mScrollVH ">
	<div class="inPerView type02">
		<div style="">
			<div class="selectCalView">
				<select class="selectType02 yearList" id="schYearSel">
				</select>	
			</div>
			<div>
				<a href="javascript:search(1)" class="btnTypeDefault btnSearchBlue nonHover"><spring:message code='Cache.btn_search' /></a>
			</div>
		</div>	
	</div>
	<div class="boardAllCont">
		<%--<div class="mt20 tabMenuCont">
			
		</div>--%>
		<div class="boradTopCont selectCalView">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a href="#" onclick="openHolidayPopup();" class="btnTypeDefault btnTypeChk"><spring:message code="Cache.lbl_Regist" /></a>
				<a href="#" onclick="delHoliday();" class="btnTypeDefault"><spring:message code="Cache.lbl_delete" /></a>
				<select class="selectType02 yearList" id="apiYear"></select>	
				<a href="#" onclick="getHolidayGoogleData();" class="btnTypeDefault"><spring:message code="Cache.lbl_n_att_googleAPILink" /></a>	<!-- google api 연동 -->
				<a href="#" onclick="goBaseAttendDatePop()" class="btnTypeDefault"><spring:message code="Cache.lbl_apv_attendance"/> <spring:message code="Cache.DicSection_Base"/> <spring:message code="Cache.btn_Add"/></a> 	<!-- 근태 기초데이터 추가 -->
			</div>
			<div class="pagingType02 buttonStyleBoxRight">	
				<select class="selectType02 listCount" id="listCount" onchange="search(1); return false;">
					<option value="10">10</option>
					<option value="15">15</option>
					<option value="20">20</option>
					<option value="30">30</option>
					<option value="50">50</option>
					<option value="100">100</option>
				</select>
				<button href="#" class="btnRefresh" type="button" onclick="search(1); return false;"></button> 
			</div>
			<div class="tblList tblCont boradBottomCont" id="gridHolidayDiv"></div>	
		</div>
					
	</div>	
	<!-- 목록보기--> 
</div>								 			

<script type="text/javascript">
var pageSize = CFN_GetQueryString("pageSize")== 'undefined'?10:CFN_GetQueryString("pageSize");

if(CFN_GetCookie("AttListCnt")){
	pageSize = CFN_GetCookie("AttListCnt");
}
if(pageSize===null||pageSize===""||pageSize==="undefined"){
	pageSize=10;
}

$("#listCount").val(pageSize);

$(document).ready(function(){
	
	// 상세 보기
	$('.btnDetails').on('click', function() {
		var mParent = $('.inPerView');
		if(mParent.hasClass('active')){
			mParent.removeClass('active');
			$(this).removeClass('active');
		}else {
			mParent.addClass('active');
			$(this).addClass('active');
		}
	});
	var nowYear = new Date().getFullYear();
	// 년도 option 생성	
	for (var i=2; i>-3;i--) {
		var temp = nowYear + i;
		if (temp == nowYear) {
		    $('.yearList').append($('<option>', {
		        value: temp,
		        text : temp,
		        selected : 'selected'
		    }));				
		} else {
		    $('.yearList').append($('<option>', {
		        value: temp,
		        text : temp
		    }));
		}
	}
	
	init();

});

function init(){
	var grid = new coviGrid();
	setHolidayGrid();
	search(1);
	$("#apiYear").on('change', function() {
		search(1);
	});
	
	$("#schTxt").on('keypress', function(e){ 
		if (e.which == 13) {
			search(1);
	    }
	});
}


function setHolidayGrid() {
	
	
	// header
	var	headerData = null;
	headerData = [
				{key:'HolidayStart', label:'chkHoliday', width:'25', align:'center', formatter:'checkbox', sort:false},
				{key:'HolidayName', label:'<spring:message code="Cache.lbl_att_holiday_name" />', width:'50', align:'center' },
				/* {key:'HolidayName', label:'<spring:message code="Cache.lbl_att_holiday_name" />', width:'50', align:'center',
					formatter:function () {
						var html = "<div>";
						html += "<a href='#' onclick='updHolidayPopup(\""+this.item.HolidayStart+"\",\""+this.item.HolidayEnd+"\",\""+this.item.GoogleYn+"\"); return false;'>";					
						html += this.item.HolidayName;
						html += "</a>";
						html += "</div>"; 
							
						return html;
					}
				}, */
	  			{key:'HolidayStart', label:'<spring:message code="Cache.lbl_startdate" />', width:'50', align:'center'},
	  			{key:'HolidayEnd', label:'<spring:message code="Cache.lbl_EndDate" />', width:'50', align:'center'},
	  			//{key:'AlramYn', label:'<spring:message code="Cache.lbl_Alram" />', width:'50', align:'center'},
	  			//{key:'ImportLevel', label:'<spring:message code="Cache.lbl_importance" />', width:'50', align:'center'},
	  			{key:'Etc', label:'<spring:message code="Cache.lbl_Contents" />', width:'100', align:'center'},
	  			{key:'',  label:' ', width:'150', align:'center', sort:false,
					formatter : function () {
						return "<a class='btn_Ok' id='btnApply' onclick=applyHoliday("+this.index+")><spring:message code='Cache.lbl_Rereflect'/></a>";
					}
				}
	  		];
	 
	grid.setGridHeader(headerData);
	
	// config
	var configObj = {
		targetID : "gridHolidayDiv",
		/* listCountMSG:"", */ 
		/* listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", */
		height:"auto",			
		paging : true,
		page : {
			pageNo:1,
			pageSize: $("#listCount").val()
		}
	};
	
	grid.setGridConfig(configObj);
	
}

function goBtnPage(o){
	search($(o).prevAll("#btPageInput").val());
}
 

//검색
function search(n) {
	
	var params = {
			  year : $('#apiYear').val(),
			  schTxt : $('#schTxt').val(),
			  ApprovalSts : $('#ApprovalSts').val(),
		  	  sortBy : "HolidayStart DESC"
		  	  };

	grid.page.pageNo = n;
	grid.page.pageSize = $("#listCount").val();
	// bind
	grid.bindGrid({
		ajaxUrl : "/groupware/attendAdmin/getHolidayList.do",
		ajaxPars : params,
		onLoad : function() {
			//아래 처리 공통화 할 것
			coviInput.setSwitch();
			//custom 페이징 추가
				
			var countStr = "<div class='AXgridStatus' id='gridHolidayDiv_AX_gridStatus'><b>"+grid.page.listCount+"</b> <spring:message code='Cache.lbl_Count'/></div>"; 
			var pageStr = "<div class='goPage'>";	
			pageStr += "<input type='text' id='btPageInput' value='"+grid.page.pageNo+"' /><span> / <spring:message code='Cache.lbl_total'/></span><span>"+grid.page.pageCount+"</span><span><spring:message code='Cache.lbl_page'/></span>";	
			pageStr += "<a href='#' onclick='goBtnPage(this);' class='btnGo'>go</a>";	

			$('.AXgridPageBody').html(countStr);
			$('.AXgridPageBody').append('<div id="custom_navi" style="text-align:center;margin-top:2px;">'+pageStr+'</div>');
			grid.fnMakeNavi("grid");
		}
	});
}

function delHoliday(){
	var StartDayArry = new Array();
	for(var i=0;i<$("input[name=chkHoliday]").length;i++){
		if($("input[name=chkHoliday]").eq(i).is(":checked")){
			StartDayArry.push($("input[name=chkHoliday]").eq(i).val());
		}
	}
	
	var params = {
			"StartDayArry" : JSON.stringify(StartDayArry)
	}	
	
	if(StartDayArry.length == 0){
		Common.Warning("<spring:message code='Cache.msg_selectTargetDelete'/>");
		return;
	}else{

		$.ajax({
			type:"POST",
			dataType : "json",
			data: params,
			url:"/groupware/attendAdmin/deleteHoliday.do",
			success:function (data) {
				if(data.status =="SUCCESS"){
					Common.Inform("<spring:message code='Cache.msg_sns_05'/>","Information",function(){
						search(1);					
					});	
				}else{
					Common.Warning("<spring:message code='Cache.msg_sns_03'/>");
				}
			}
		});
	}
}


var sttt;

function getHolidayGoogleData(){
	var url = "/groupware/calendar/eventlist.do";
	var msg = String.format(Common.getDic("msg_n_att_googleCalAlert"),$("#apiYear").val());
	Common.Confirm(msg,"Confirm", function(result) {
		if(result){
			$.ajax({
				type:"GET",
				url:url,
				success:function (data) {
					var items = data.items;
					
					var holidayList = new Array();
					
					for(var i=0;i<items.length;i++){
						var holiObj = items[i];
						
						var summary = holiObj.summary
						var startDay = holiObj.start.date;
						var year = startDay.substring(0,4)
						
						if($("#apiYear").val()==year){
							var returnObj = {
									'summary' : summary 
									,'startDay' : startDay
									,'year' : year
							}
							holidayList.push(returnObj);
						}
					}
					var params = {"holi":JSON.stringify(holidayList)};
					
					$.ajax({
						type:"POST",
						dataType : "json",
						data: params,
						url:"/groupware/attendAdmin/setGoogleHoliday.do",
						success:function (data) {
							if(data.status =="SUCCESS"){
								search(1);
							}else{
								Common.Warning("<spring:message code='Cache.msg_sns_03'/>");
							}
						},
						error:function(){
							alert("error")
						}
					});
					
					if(holidayList.length==0){
						Common.Warning("<spring:message code='Cache.msg_n_att_googleCalAlert2'/>");
					}
					
				},
				error:function(data){
					var json =		data.responseJSON;
					Common.Warning(json.error.status);
				}
			});
		}
	});
	
}


//휴일 추가 팝업
function openHolidayPopup() {
	var url = "/groupware/attendAdmin/goAttHolidayPopup.do";
	var titlemessage = Common.getDic("MN_889");  //회사 휴무일 등록
	parent.Common.open("","SchMemPop",titlemessage,url,"480px","250px","iframe",true,null,null,true);

}

//휴일 수정 팝업
function updHolidayPopup(holidayStart,holidayEnd,googleYn){
	
	var param = "?Sts=UPD";
	param += "&HolidayStart="+holidayStart;
	param += "&HolidayEnd="+holidayEnd;
	param += "&GoogleYn="+googleYn;
	var url = "/groupware/attendAdmin/goAttHolidayPopup.do"+param;
	var titlemessage = Common.getDic("MN_889");  //회사 휴무일 등록
	parent.Common.open("","SchMemPop",titlemessage,url,"480px","250px","iframe",true,null,null,true);
}

function refreshList(){
	search(1);
}

//근무일정 재반영
function applyHoliday(index){
	Common.Confirm("<spring:message code='Cache.ACC_msg_ckApply' />", "<spring:message code='Cache.lbl_n_att_worksch' />", function(result){
   		if(result){
			var item = grid.list[index];
			$.ajax({
				type:"POST",
				data:{ "HolidayStart":item.HolidayStart
					, "HolidayEnd": item.HolidayEnd
					, "GoogleYn": item.GoogleYn},
				url:"/groupware/attendJob/reapplyAttendHolidayJob.do",
				success:function (data) {
					if(data.result == "ok"){
						Common.Inform("<spring:message code='Cache.msg_Been_saved' />");	//저장되었습니다.
					}
					else{
						Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+data); //	오류가 발생했습니다. 관리자에게 문의바랍니다
					}
				},
				error:function (request,status,error){
					Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
				}
			});
   		}
	});	
}

// 근태 날짜-요일 기초 데이터 생성 팝업
function goBaseAttendDatePop() {
	var url = "/groupware/attendAdmin/goBaseAttendDatePop.do";
	var title = '<spring:message code="Cache.lbl_apv_attendance"/> <spring:message code="Cache.DicSection_Base"/> <spring:message code="Cache.btn_Add"/>';
	parent.Common.open("", "baseAttendDatePop",title, url, "300px", "180px", "iframe", true, null, null, true);
}


</script>
<script async defer src="https://apis.google.com/js/api.js"
		onload="this.onload=function(){};handleClientLoad()"
		onreadystatechange="if (this.readyState === 'complete') this.onload()">
</script>