<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"  import="egovframework.baseframework.util.SessionHelper,egovframework.baseframework.util.RedisDataUtil"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<%@ page import="egovframework.coviframework.util.ComUtils"%>
<%
	String userNowDate = ComUtils.GetLocalCurrentDate("yyyy-MM-dd"); 
%>


<div class="cRConTop titType AtnTop">
	<h2 class="title"><spring:message code='Cache.lbl_att_attendance_sts'/></h2>	
	<div id="divDate" >
		<input class="adDate title_calendar" type="text" id="StartDate" date_separator="." readonly> <span class="adLine">~</span>  
		<input id="EndDate" date_separator="." date_startTargetID="StartDate" class="adDate title_calendar" type="text" readonly>
	</div>											
	<div class="pagingType02">       
		<a href="#" class="calendartoday btnTypeDefault">오늘</a>
	</div> 						
	<div class="searchBox02">
		<span><input type="text" id="searchText"><button type="button" class="btnSearchType01" id="btnSearch"><spring:message code='Cache.btn_search'/></button></span> <!-- 검색 -->
	</div>
<!--  
	<div class="pagingType02">
		<a href="#" class="pre dayChg" data-paging="-"></a>
		<a href="#" class="next dayChg" data-paging="+"></a>
		<a href="#" class="btnTypeDefault calendartoday"><spring:message code='Cache.lbl_Todays'/></a>
		<a href="#" class="calendarcontrol btnTypeDefault cal"></a>
		<input type="text" id="inputCalendarcontrol" style="height: 0px; width:0px; border: 0px;" >
	</div>--> 
	<div class="searchBox02"> 
		<span><input type="text" id="sUserTxt"><button type="button" id="searchBtn" class="btnSearchType01"><spring:message code='Cache.lbl_search'/></button></span>
	</div>
</div>
<div class='cRContBottom mScrollVH'>
	<!-- 컨텐츠 시작 -->
	<div class="ATMCont">
		<div class="ATMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a href="#" id="setAttBtn" class="btnTypeDefault  btnTypeBg btnAttAdd"><spring:message code='Cache.lbl_n_att_history'/> <spring:message code='Cache.btn_Add'/>/<spring:message code='Cache.btn_Edit'/></a>
				<a href="#" id="commuteBtn" class="btnTypeDefault" style="display: none;"><spring:message code='Cache.lbl_allCommute'/></a>
			</div>
			<div class="pagingType02 buttonStyleBoxRight" id="selectBoxDiv"> 
				<%if (!RedisDataUtil.getBaseConfig("ExcelSaveYnAdmin").equals("N")){%>
				<a class="btnTypeDefault btnExcel" id="excelBtn" href="#"><spring:message code='Cache.lbl_SaveToExcel'/></a>
				<%} %>
				<button href="#" class="btnRefresh" type="button" id="btnRefresh"></button>
				<select class="selectType02 listCount" id="listCntSel">
					<option value="10" selected>10</option>
					<option value="20">20</option>
					<option value="30">30</option>
					<option value="50">50</option>
					<option value="100">100</option>
				</select>
			</div>
		</div>
		<div class="ATMFilter_Info_wrap">
			<div class="ATMFilter">
				<p class="ATMFilter_title"><spring:message code='Cache.lbl_att_select_department'/></p>
				<select class="size112" id="groupPath"></select>
				<!-- <p class="ATMFilter_title">근무형태</p>
				<select class="size72"><option>전체</option></select>
				<select class="size72"><option>전체</option></select>
				<select class="size72"><option>전체</option></select> -->
				<select class="size72" id="jobGubun">
					<option value=""><spring:message code='Cache.lbl_Whole'/></option> 
					<option value="1_JobTitle"><spring:message code='Cache.lbl_JobTitle'/></option> 
					<option value="1_JobLevel"><spring:message code='Cache.lbl_JobLevel'/></option> 
				</select>
				<select class="size72" id="jobCode">
					<option value=""><spring:message code='Cache.lbl_Whole'/></option>
				</select>
				<p class="ATMFilter_title"><spring:message code='Cache.lbl_templateName'/></p>
				<select class="selectType02" id="SchSeq">
				</select>
					<input id="AttStatus1" name="AttStatus" value="B10" type="checkbox">
					<label for=AttStatus1><spring:message code="Cache.AlramTime_10"/>~<spring:message code="Cache.lbl_startWorkTime"/></label><!-- 출근10분전 -->
					<input id="AttStatus2" name="AttStatus" value="A1" type="checkbox">
					<label for=AttStatus2><spring:message code="Cache.lbl_startWorkTime"/>~<spring:message code="Cache.RepeatTerm_60"/></label><!-- 출근1시간내-->
					<input id="AttStatus3" name="AttStatus" value="LATE" type="checkbox">
					<label for=AttStatus3><spring:message code="Cache.lbl_att_beginLate"/></label><!-- 지각 -->
					<p class="ATMFilter_title" style="display:none"><spring:message code='Cache.lbl_n_att_attStatusMainAlert'/></p>
			</div>
			<!-- <div class="ATMInfo">
				<p class="Normal">정상</p>
				<p class="Outside">외근</p>
				<p class="Ex">연장/휴일</p>
				<p class="Holyday">휴무</p>
				<p class="Vacation">휴가</p>
			</div> -->
		</div>
		<div class="tblList">
			<div id="gridDiv"></div>
		</div>
	</div>
	<!-- 컨텐츠 끝 -->
</div>


<!-- 기타근무 레이어 팝업 -->
<div id="divJobPopup" style="position:initial;display:none">
	<div class="ATMgt_Work_Popup" style="width:282px;  position:absolute; z-index:105">
		<a class="Btn_Popup_close" onclick='AttendUtils.hideAttJobListPopup();'></a>
		<div class="ATMgt_Cont" id="jobListInfo"></div>
		<div class="bottom">
			<a href="#" class="btnTypeDefault" onclick='AttendUtils.hideAttJobListPopup();'><spring:message code='Cache.lbl_close' /></a>
		</div> 
	</div>
</div>

<style>
.title_calendar { display: inline-block; font-size: 24px; font-weight: 700; font-family: sans-serif, 'Nanum Gothic','맑은 고딕', 'Malgun Gothic'; vertical-align: middle; width:128px !important; padding:0; text-indent:0; border:0px !important; }
.AXanchorDateHandle { right: -118px !important; top: -0px !important; height:32px !important; border:1px solid #d6d6d6; min-width:40px; border-radius: 2px; }
.adLine { display:inline-block; vertical-align:middle; width:15px; font-size:24px; font-weight:600; }
#divDate { margin-top:-3px; }
.pagingType02 { margin-left:2px; }


</style>
<script type="text/javascript">
var page = 1;
var pageSize = CFN_GetQueryString("pageSize")== 'undefined'?10:CFN_GetQueryString("pageSize");

if(CFN_GetCookie("AttListCnt")){
	pageSize = CFN_GetCookie("AttListCnt");
}
if(pageSize===null||pageSize===""||pageSize==="undefined"){
	pageSize=10;
}

$("#listCntSel").val(pageSize);
var grid = new coviGrid();

//var _pageSize = 7 ;
//var _pageType = 0; 


//var _stDate;
//var _edDate;

var _wpMon = "<spring:message code='Cache.lbl_WPMon' />";
var _wpTue = "<spring:message code='Cache.lbl_WPTue' />";
var _wpWed = "<spring:message code='Cache.lbl_WPWed' />";
var _wpThu = "<spring:message code='Cache.lbl_WPThu' />";
var _wpFri = "<spring:message code='Cache.lbl_WPFri' />";
var _wpSat = "<spring:message code='Cache.lbl_WPSat' />";
var _wpSun = "<spring:message code='Cache.lbl_WPSun' />";
var g_curDate = CFN_GetLocalCurrentDate("yyyy.MM.dd");


$(document).ready(function(){
	init();
	
	//getTitleDayScope();
	
	setGrid();
	setGridData();
	/*실근무 시간 표기 확인*/
	if(Common.getBaseConfig('RealTimeYn')!="Y"){
		$("#excelRealBtn").hide();
	}
});

function init(){
	//부서선택
	AttendUtils.getDeptList($("#groupPath"),'', false, false, true);
	AttendUtils.getScheduleList($("#SchSeq"),'', true);
	
	if ($("#StartDate").val()==""){
		$("#StartDate").val(g_curDate);
		$("#EndDate").val(g_curDate);
	}

	
	$("#groupPath,#listCntSel").on('change',function(){
		CFN_SetCookieDay("AttListCnt", $("#listCntSel option:selected").val(), 31536000000);
		reLoadList();
	});
	
	$("#btnRefresh").on('click',function(){
		reLoadList();
	});
	
	
	//오늘날짜검색
	$(".dayToday").on('click',function(){
		$("#StartDate").val(g_curDate);
		$("#EndDate").val(g_curDate);
		reLoadList();
	});
	
	//사용자명 검색
	$("#sUserTxt").on('keypress', function(e){ 
		if (e.which == 13) {
			reLoadList();
	    }
	});
	
	$("#EndDate").bindTwinDate({
		startTargetID : "StartDate",
		separator : ".",
		onChange:function(){
			reLoadList();
		},
		onBeforeShowDay : function(date){
			var fnStr = $("#"+this.config.targetID.split("_")[2]).attr("onBeforeShowDay");
			if(fnStr != null && fnStr != ""){
				return coviCmn.callFnBasedNamespace(fnStr, [date]);
			}
		}
	})
	
	//오늘 클릭시
	$(".calendartoday").click(function(){
		$("#StartDate").val(g_curDate);
		$("#EndDate").val(g_curDate);
		reLoadList();		
		
	});

	
	$("#searchBtn").on('click',function(){
		reLoadList();
	});
	
	$("#setAttBtn").on('click',function(){
		if(Common.getSession("isAttendAdmin") == "ADMIN"){
			goAttStatusSetPopup();
		}
	});
	
	//달력 검색
//	setTodaySearch();
	
	//직급 직책 리스트 조회
	$("#jobGubun").on('change',function(){
		AttendUtils.getJobList($(this).val(),'jobCode');
		if($(this).val()==''){
			reLoadList();			
		}
	});
	
	$("#jobCode,#SchSeq").on('change',function(){
		reLoadList();
	});
	
	$('input[name="AttStatus"]').bind('click',function() {
	    $('input[name="AttStatus"]').not(this).prop("checked", false);
		reLoadList();

	  });
	
	$("#excelBtn").on('click',function(){
		var popupID		= "AttendUserStatusPopup";
		var openerID	= "AttendUserStatus";
		var popupTit	= "<spring:message code='Cache.lbl_SaveToExcel' />";
		var popupYN		= "N";
		var popupUrl	= "/groupware/attendUserSts/goAttUserExcelDownPopup.do?"
						+ "popupID="		+ popupID	+ "&"
						+ "openerID="		+ openerID	+ "&"
						+ "popupYN="		+ popupYN	+ "&"
						+ "groupPath="		+ $("#groupPath").val()	+ "&"
						+ "StartDate="		+ $('#StartDate').val() + "&"
						+ "EndDate="		+ $('#EndDate').val() ;
		
		Common.open("", popupID, popupTit, popupUrl, "500px", "450px", "iframe", true, null, null, true);
	});
	
	// 일괄 출퇴근
	$("#commuteBtn").off("click").on("click", function(){
		goAllCommutePopup();
	});
	
	if(Common.getSession("isAttendAdmin") == "ADMIN"){
		$("#commuteBtn").show();
	} else{
		$("#commuteBtn").hide();
		$("#setAttBtn").removeClass("btnTypeBg").addClass("disabled");
	}
}

function searchList(d){
	setGridData();
}


function reLoadList(){
	grid.page.pageNo = 1 ;
	setGridData();
} 

function refreshList(){
	setGridData();
} 

function setGridData(){
	grid.page.pageSize= $("#listCntSel").val();
				 
	var params = {
		"groupPath" : 	$("#groupPath").val()
		,"dateTerm" : ""
		,"startDate":$("#StartDate").val()
		,"endDate":$("#EndDate").val()
		,"sUserTxt" : $("#sUserTxt").val()
		,"sJobTitleCode" : $("#jobGubun").val()=="1_JobTitle"?$("#jobCode").val():null
		,"sJobLevelCode" : $("#jobGubun").val()=="1_JobLevel"?$("#jobCode").val():null
		,"AttStatus" : $("input[name=AttStatus]:checked").length>0?$("input[name=AttStatus]:checked").val():null
	 	,"searchText": $("#searchText").val()
	 	,"SchSeq": $("#SchSeq").val()
	};
	
	grid.bindGrid({
		ajaxUrl : "/groupware/attendUserSts/getUserAttendanceList.do",
		ajaxPars : params,
		onLoad : function(data) {
			//아래 처리 공통화 할 것
			coviInput.setSwitch();
			//custom 페이징 추가
			$('.AXgridPageBody').append('<div id="custom_navi" style="text-align:center;margin-top:2px;"></div>');
			grid.fnMakeNavi("grid");
		}
	});
}


// 그리드 세팅 
function setGrid() {
	// header
	var	headerData = [
			/* { key:'CodeID', label:'chk', width:'30', align:'center', formatter:'checkbox' ,sort:false}, */
			{ key:'', label:"<spring:message code='Cache.lbl_n_att_Staff' />",width:'60', align:'center',sort:false,
				formatter:function(){
					return "<p class='tx_Name'><a href='#' onclick='goAttStatusSetPopup(\""+this.item.UserCode+"\",\""+this.item.dayList+"\");'>"+this.item.DisplayName+"</a></p>"
				}	
			},
			{ key:'', label:"<spring:message code='Cache.lbl_date' />",width:'80', align:'center',sort:false ,
				formatter:function () {
					var dayList = this.item.v_dayList;
					var weekd = this.item.weekd;
					var dayHtml = "<p class='tx_Date'><a href='#' onclick='goAttStatusSetPopup(\""+this.item.UserCode+"\",\""+this.item.dayList+"\");'>";
					switch (weekd){
						case 1 : dayHtml += dayList+" ("+_wpSun+")" ; break;
						case 2 : dayHtml += dayList+" ("+_wpMon+")" ; break;
						case 3 : dayHtml += dayList+" ("+_wpTue+")" ; break;
						case 4 : dayHtml += dayList+" ("+_wpWed+")" ; break;
						case 5 : dayHtml += dayList+" ("+_wpThu+")" ; break;
						case 6 : dayHtml += dayList+" ("+_wpFri+")" ; break; 
						case 7 : dayHtml += dayList+" ("+_wpSat+")" ; break;
					}
					dayHtml += "</a></p>";
					return dayHtml;
				}
	        },
			{ key:'SchName', label:"<spring:message code='Cache.lbl_templateName' />",width:'70', align:'center',sort:false },
			{ key:'', label:"<spring:message code='Cache.lbl_n_att_worksch' />",width:'150', align:'center',sort:false ,
				formatter:function () {
					var st = this.item.v_AttDayStartTime;
					var ed = this.item.v_AttDayEndTime
					var html = "<p class='tx_Time'><a href='#' onclick='goAttStatusSetPopup(\""+this.item.UserCode+"\",\""+this.item.dayList+"\");'>";
					if(!(st == null || ed == null)){
						html += st+"~"+ed;						
					}
					html += "</a></p>";
					return html;
				}
	        },
	        { key:'', label:"<spring:message code='Cache.lbl_att_goWork' />",width:'70', align:'center',sort:false ,
				formatter:function () {
					var st = this.item.v_AttStartTime;
					var ed = this.item.v_AttEndTime
					var html = "<p class='tx_Time'>";
					html += AttendUtils.convertNull(st,"");						
					html += "</p>";
					return html;
				}
	        },
	        { key:'', label:"<spring:message code='Cache.lbl_leave' />",width:'70', align:'center',sort:false ,
				formatter:function () {
					var st = this.item.v_AttStartTime;
					var ed = this.item.v_AttEndTime
					var html = "<p class='tx_Time'>";
					html +=AttendUtils.convertNull(ed,"");						
					html += "</p>";
					return html;
				}
	        },
	        { key:'', label:"<spring:message code='Cache.lbl_n_att_acknowledgedWork' />",width:'60', align:'center',sort:false ,
				formatter:function(){
					var workSts = this.item.WorkSts; //휴일
					var vacName = this.item.VacName; //휴가
					var html = "<p class='tx_Hour'>"+AttendUtils.convertNull(this.item.v_AttRealTime, "")+"</p>";
					if(workSts=="OFF" || workSts =="HOL"){
						html = "<p class='tx_Hour Holiday'>"+(workSts== "OFF"? "<spring:message code='Cache.lbl_att_sch_holiday' />":"<spring:message code='Cache.lbl_Holiday' />")+"</p>";
					}
					if(vacName!=null&&vacName!=''){
						html = "<p class='tx_Hour Vacation'>"+vacName+"</p>";
					}
					return html;
				}	
			},
			{ key:'', label:"<spring:message code='Cache.lbl_over' />",width:'56', align:'center',sort:false ,
				 formatter:function(){
					 var exHtml;
					if(this.item.ExtenCnt > 1){
						exHtml = $('<a />', {
							html : this.item.v_ExtenAc
							,onclick : "showExhoList(this,'O')"
							,"data-usercode" : this.item.UserCode
							,"data-targetdate" : this.item.dayList
						}); 
					}else{
						exHtml = $('<a />', {
							html : this.item.v_ExtenAc
							,onclick : "goAttStatusExPopup(\""+this.item.UserCode+"\",\""+this.item.dayList+"\",\"O\")"
						});
					}
					var temp = $('<p />', {
						class : "tx_Hour"
					});
					temp.append(exHtml);
					return temp[0].outerHTML;
				} 
				
			},
			{ key:'', label:"<spring:message code='Cache.lbl_Holiday' />",width:'56', align:'center',sort:false ,
				formatter:function(){
					var hoHtml;
					if(this.item.HoliCnt > 1){
						hoHtml = $('<a />', {
							html : this.item.v_HoliAc
							,onclick : "showExhoList(this,'H')"
							,"data-usercode" : this.item.UserCode
							,"data-targetdate" : this.item.dayList
						}); 
					}else{
						hoHtml = $('<a />', {
							html : this.item.v_HoliAc
							,onclick : "goAttStatusExPopup(\""+this.item.UserCode+"\",\""+this.item.dayList+"\",\"H\")"
						});
					}
					
					var temp = $('<p />', {
						class : "tx_Hour"
					});
					temp.append(hoHtml);
					return temp[0].outerHTML;
				}	
			},
			{ key:'', label:"<spring:message code='Cache.lbl_n_att_RecordTime' />",width:'56', align:'center',sort:false ,
				formatter:function(){
					var html = "<p class='tx_Hour'>"+ AttendUtils.convertNull(this.item.v_startToEnd,'')+"</p>";
					return html;
				}	 
			},
			{ key:'', label:"<spring:message code='Cache.lbl_n_att_resttime' />",width:'60', align:'center',sort:false ,
				formatter:function(){
					return "<p class='tx_Hour'>"+AttendUtils.convertNull(this.item.AttIdle, '')+"</p>"
				}	
			},
			{ key:'', label:"<spring:message code='Cache.lbl_att_beingLate' />",width:'60', align:'center',sort:false ,
				formatter:function(){
					return "<p class='tx_Hour'>"+ AttendUtils.convertNull(this.item.LateMin,'')+"</p>"
				}	
			},
			{ key:'', label:"<spring:message code='Cache.lbl_n_att_worktype' />/<spring:message code='Cache.lbl_SmartDept' />",width:'110', align:'center',sort:false ,
				formatter:function(){
					return "<p class='tx_Job'>"+this.item.DeptName+"</p>"
				}	
			},
			{ key:'', label:"<spring:message code='Cache.lbl_n_att_worknote' />",width:'200', align:'center',sort:false , 
				formatter:function(){
					return "<p class='tx_Note'>"+AttendUtils.convertNull(this.item.Etc, "")+"</p>"
				}	
			},
			{ key:'AttConfirmYn', label:"<spring:message code='Cache.lbl_apv_determine' />",width:'50', align:'center',sort:false  ,
				formatter:function () {
					var confirmYn = this.item.AttConfirmYn;
					var html = "";
					
					if(confirmYn=="Y"){
						html += "<a href='#' class='btnYes'><span>Y</span></a>";				
					}else{
						html += "<a href='#' class='btnNo'><span>N</span></a>";				
					}
					return html;
				}
	        }
		];
	grid.setGridHeader(headerData);
	
	// config
	var configObj = {
		targetID : "gridDiv",
 		listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>",  
		height:"auto",			
		paging : true,
		page : {
			pageNo:1,
			pageSize:$("#listCntSel").val()
		}
	};
	grid.setGridConfig(configObj);
}

//조직도 팝업 콜백
function orgMapLayerPopupCallBack(orgData) {
	wiUrArry = new Array();
	var data = $.parseJSON(orgData);
	var item = data.item
	var len = item.length;
	//기존 입력정보 초기화
	attPopValueClear();
	
	var childPop = $('#AttendAttStstusPopup_if').contents();
	//사용자 정보 표시
	childPop.find('#userCode').val(item[0].UserCode);
	childPop.find('#at_dept').html(CFN_GetDicInfo(item[0].RGNM));
	childPop.find('#at_name').html(CFN_GetDicInfo(item[0].DN));
}	

function attPopValueClear(){
	var childPop = $('#AttendAttStstusPopup_if').contents();
	
	//기존 입력정보 초기화
	childPop.find('#at_dept').html("");
	childPop.find('#at_name').html("");
	childPop.find('#at_schName').html("");
	childPop.find('#AXInput-1').val("");
	childPop.find('#AXInput-2').val("");
	childPop.find('#AXInput-3').val("");
  
	childPop.find('#at_startHour').val("");
	childPop.find('#at_startMin').val("");
	childPop.find('#at_startAP').val("");
	childPop.find('#at_endHour').val("");
	childPop.find('#at_endMin').val("");
	childPop.find('#at_endAP').val("");
  
	childPop.find('#at_etc').val("");
}


//기타근무 리스트 팝업 
function showJobList(o){
	AttendUtils.openAttJobListPopup(o,$(o).parent().parent().parent(),'Y');
}

//연장(휴일)근무  리스트 팝업
function showExhoList(o,gubun){
	AttendUtils.openAttExhoListPopup(o,$(o).parent().parent().parent(),gubun,'Y');
}

//연장근무 수정 팝업
function goAttStatusExPopup(u,t,reqType){
	AttendUtils.openAttExHoInfoPopup(u,t,reqType,'','Y');
}

//근태현황수정 팝업
function goAttStatusSetPopup(u,t){
	//AttendUtils.openAttStatusSetPopup(u,t);
	//상세로 변경
	AttendUtils.openAttMyStatusPopup(u,t,'Y');
}

//일괄 출퇴근 팝업
function goAllCommutePopup(){
	AttendUtils.openAllCommutePopup();
}
</script>