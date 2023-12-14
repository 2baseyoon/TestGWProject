//근태관리 목록
$(document).on('pageinit', '#attend_main_page', function () {
	// 기본 javascript bind함수가 변경되서 다시 원복 - /mail/resources/script/cmmn/cmmn.func.js
	if (Function.prototype._original_bind && Function.prototype.bind) {
		Function.prototype.bind = Function.prototype._original_bind;
	}
	
	setTimeout(function () {
		//기본정보 로딩
		AttendMobile.init();
		
    }, 10);
	mobile_attendance_bindTouch("attend_main_content","AT"); //메인 화면 근태 현황 Attendance
	mobile_attendance_getDropmenuList();
});

//부서현황 목록
$(document).on('pageinit', '#attend_list_page', function () {
	// 기본 javascript bind함수가 변경되서 다시 원복 - /mail/resources/script/cmmn/cmmn.func.js
	if (Function.prototype._original_bind && Function.prototype.bind) {
		Function.prototype.bind = Function.prototype._original_bind;
	}
	
	setTimeout(function(){
		//기본정보 로딩
		AttendMobileDeptList.init();
	}, 10);
	mobile_attendance_bindTouch("attend_list_content","DP"); //부서 근태 현황 Department
	mobile_attendance_getDropmenuList();
});

// 근태관리 이전/다음 터치 스와이프
var resTouchX = 0;
var resTouchPosX = 0;
var resTouchDirection = "";
var resTouchMoveWidth = 0;

function mobile_attendance_bindTouch(pTargetID, NextType){ 
	$("#"+pTargetID).off("touchstart,touchmove,touchend")
	.on('touchstart', function(e) {    	 		     	 
		resTouchPosX = e.originalEvent.targetTouches[0].pageX;
		resTouchX = 0;
		if(mobile_comm_isAndroidApp()) {
			window.covimoapp.SetPullToRefresh(false);
		}
	})
	.on('touchmove', function(e) {         	 
		resTouchX = e.originalEvent.targetTouches[0].pageX;
		resTouchDirection = "Right";
		mobile_comm_disablescroll();
		resTouchMoveWidth = parseInt(resTouchPosX - resTouchX);
		if(resTouchMoveWidth < 0) {
			resTouchDirection = "Left";
		}
		if(parseInt(resTouchMoveWidth) > parseInt(winW/2)){
			resTouchMoveWidth = parseInt(winW/2);
		}
		$("#sSlide_bar").css("margin-left", -(parseInt(resTouchMoveWidth)));
	})
	.on('touchend', function(e) {    	 
	 var left = parseInt(resTouchPosX - resTouchX);
	 var width = parseInt($("body").width())*0.3;
	 if(resTouchX != 0) {
		 if(left < 0 ){
			if (-left >= width && NextType == "DP") {
				AttendMobileDeptList.dateChange("PREV");
			 }else if(-left >= width && NextType == "AT"){
				AttendMobile.dayChg("-");
			} 
		 }else{
			if (left >= width && NextType == "DP") {
				AttendMobileDeptList.dateChange("NEXT");
			 }else if(left >= width && NextType == "AT"){
				AttendMobile.dayChg("+");
			}
		 }
	 }	
	 $("#sSlide_bar").css("margin-left","");
	 mobile_comm_enablescroll();
	});
}

//드롭메뉴(PC 버튼 영역) 조회
function mobile_attendance_getDropmenuList() {
	var sHtml = "";
	
	if(mobile_comm_getBaseConfig("useMobileApprovalWrite") == "Y") {
		var arrForms = mobile_comm_getBaseConfig("MobileAttendanceForm").split(";");
		
		for(var i = 0 ; i < arrForms.length ; i++) {
			var arrBtn = arrForms[i].split("@"); // FormPrerix@버튼명...
			
			sHtml += "<li><a onclick=\"mobile_attendance_writeApprovalForm('" + arrBtn[0] + "');\">" + mobile_comm_getDic(arrBtn[1]) + "</a></li>"; //일괄결재
		}	
	}
	if(sHtml != "") {
		$("ul.exmenu_list").html(sHtml);
		$("div .dropMenu").show();
	}
}

//모바일 근태관리 관련 결재양식 작성
function mobile_attendance_writeApprovalForm(pFormPrefix) {
	mobile_approval_clickwrite(pFormPrefix);
}

//시간변환 함수
function fun_convertSecToStr(iVal, sFormat)	{
	var sRet;
	var iHour	 ;
	var iMinute  ;
	var iSec     ;

	if (isNaN(iVal)  ||iVal == 0) {
		iHour = 0;
		iMinute = 0;
	}
	else{
		iHour	 = Math.floor(iVal / 60);
		iMinute  = Math.floor((iVal- 60*iHour));
		iSec     = iVal - (60*iHour) - (iMinute);
	}
	if (sFormat == "H"){
		sRet = iHour+"h ";
		if (iMinute>0 ) sRet+=iMinute+"m";
	}else if (sFormat == "h"){
		sRet = iHour+"h";
		if (iMinute>0 ) sRet+=" "+iMinute+"m";
	}else if (sFormat == "hh"){
		if(iHour>0) {
			sRet = iHour + "h";
		}else{
			sRet = "";
		}
		if (iMinute>0 ) sRet+=""+iMinute+"m";
	}else if (sFormat == "nbsp"){
		if(iHour>0) {
			sRet = iHour + "h";
		}else{
			sRet = "";
		}
		if (iMinute>0 ) sRet+=" "+iMinute+"m";
		if(sRet==""){
			sRet="&nbsp;";
		}
	}else if(sFormat == "hour"){
			sRet = iHour+"h ";
	}
	else{
		sRet =  (iHour<10?"0":"")  +   iHour + ":";
		sRet += (iMinute<10?"0":"") +  iMinute ;

	}

//		sRet += (iSec<10?"0":"")    +  iSec;
	return sRet;
}

function userWorkTimeCheck(userWorkInfo, workTime, type) {
	var sOver = false;
	var mOver = false;
	var wOver = false;
	if(userWorkInfo!=null && userWorkInfo.length>0 && userWorkInfo.indexOf("|")>0) {
		var arrUWI = userWorkInfo.split('|');
		var limitOnWeekly = Number(arrUWI[13]);
		var limitOnWeeklyTime = 0;
		var psWorkingDays = arrUWI[1];
		var psWorkingDayNum = 0;
		for (var i = 0; i < psWorkingDays.length; i++) {
			psWorkingDayNum += Number(psWorkingDays.substring(i, i + 1));
		}
		if(limitOnWeekly>0){
			limitOnWeeklyTime = (limitOnWeekly * 60) / psWorkingDayNum;
		}
		var pDailyWT = 0;
		var psTime = Number(arrUWI[4]);
		if (arrUWI[5] == "day") {
			pDailyWT = psTime * 60;
		} else {
			pDailyWT = (psTime * 60) / psWorkingDayNum;
		}
		var pmDailyWT = 0;
		var pmTime = Number(arrUWI[9]);
		if (arrUWI[10] == "day") {
			pmDailyWT = pmTime * 60;
		} else {
			pmDailyWT = (pmTime * 60) / psWorkingDayNum;
		}
		if (type == "D") {
			if (workTime > pDailyWT) {
				sOver = true;
			}
			if (workTime > pmDailyWT) {
				mOver = true;
			}
			if(limitOnWeekly>0 && workTime>limitOnWeeklyTime){
				wOver = true;
			}
		} else if (type == "W") {
			if (workTime > (pDailyWT * psWorkingDayNum)) {
				sOver = true;
			}
			if (workTime > (pmDailyWT * psWorkingDayNum)) {
				mOver = true;
			}
			if(limitOnWeekly>0 && workTime > (limitOnWeeklyTime * psWorkingDayNum)){
				wOver = true;
			}
		}
	}

	var color = "#3fb062";
	if(sOver){
		color = "#f08264";
	}
	if(mOver){
		color = "#ff5d5d";
	}
	if(wOver){
		color = "#be310b";
	}
	return color;
}


function userMaxWorkTime(userWorkInfo) {
	var rtn = -1;
	if(userWorkInfo!=null && userWorkInfo.length>0 && userWorkInfo.indexOf("|")>0) {
		var arrUWI = userWorkInfo.split('|');
		var limitOnWeekly = Number(arrUWI[13]);
		var limitOnWeeklyTime = 0;
		var psWorkingDays = arrUWI[1];
		var psWorkingDayNum = 7;

		var pmDailyWT = 0;
		var pmTime = Number(arrUWI[9]);
		if (arrUWI[10] == "day") {
			pmDailyWT = pmTime * psWorkingDayNum;
		} else {
			pmDailyWT = pmTime;
		}

		if (limitOnWeekly>0) {
			rtn = limitOnWeekly;
		} else {
			rtn = pmDailyWT;
		}
	}

	return rtn;
}


function userLimitWorkTime(userWorkInfo) {
	var rtn = -1;
	if(userWorkInfo!=null && userWorkInfo.length>0 && userWorkInfo.indexOf("|")>0) {
		var arrUWI = userWorkInfo.split('|');
		var psWorkingDays = arrUWI[1];
		var psWorkingDayNum = 0;
		for (var i = 0; i < psWorkingDays.length; i++) {
			psWorkingDayNum += Number(psWorkingDays.substring(i, i + 1));
		}
		var pmTime = Number(arrUWI[4]);
		if (arrUWI[5] == "day") {
			rtn = pmTime * psWorkingDayNum;
		} else {
			rtn = pmTime;
		}
	}
	return rtn;
}

function hmsTimeToAM(time){
	var arrTime = time.split(':');
	var ampm = "";
	var hh = "";
	if(arrTime[0]<13){
		ampm = "AM";
		hh = arrTime[0];
	}else{
		ampm = "PM";
		hh = arrTime[0]-12;
		if(hh<10){
			hh = "0"+hh;
		}

	}
	var ss = ":"+arrTime[2];
	var w = $(".am_time_wrap_type2").width();
	if(w<=314){
		ss = "";
	}
	return hh+":"+arrTime[1]+ss+" "+ampm;
}

//지도
var map;
var _targetDate;
var _stDate, _edDate;
var _commuteChannel = "M";

var _pointX ,_pointY;

var _params;


var AttendMobile ={
		_commuteTimeYn : mobile_comm_getBaseConfig('CommuteTimeYn'),
		init:function(){
			AttendMobile.closeLayer();

			var useTeamsAddIn = $("#useTeamsAddIn").val();
			var isMobile = $("#isMobile").val();
			var mapUsed =  mobile_comm_getBaseConfig("AttendanceMobileMapUsedYn");
			
			if(mapUsed == "Y"){
				if(useTeamsAddIn == "Y" && isMobile == "false"){
					$("#map").hide();
				}else{
					mobile_attendance_callapplocation();
				}
			}
			//출퇴근 버튼 정보조회
			AttendMobile.getCommuteData();
			//출퇴근 정보조회
			AttendMobile.getMyAttInfo();
			
			$("#todayBtn").on('click',function(){
				AttendMobile.setToday();
			});
			
			//날짜paging
			$(".dayChg").on('click',function(){
				AttendMobile.dayChg($(this).data("paging"));
			});
			
			$("#jobBtn").on('click',function(){
				AttendMobile.openLayer();
			});
			
			// 메뉴 가져오기
			AttendMobileDeptList.setMenuList(AttendMenu); // AttendMenu - 서버에서 넘겨주는 좌측메뉴 목록
		}
		,mapLoad:function(pointX,pointY){
			
			if(pointX==undefined || pointX==null ) pointX = $("#PointX").val();
			if(pointY==undefined || pointY==null ) pointY = $("#PointY").val();
			var uluru = {
				lng:  Number(pointX)  , lat:  Number(pointY)
			};
			
			_pointX = pointX;
			_pointY = pointY;
			
			var zoom = mobile_comm_getBaseConfig("GoogleMapLevel");	//zoom level
			if(urTheme==="black") {//다크모드시
				map = new google.maps.Map(document.getElementById('map'), {
					center: uluru
					, zoom: Number(zoom)
					, zoomControl: false
					, mapTypeControl: false
					, scaleControl: false
					, streetViewControl: false
					, rotateControl: false
					, fullscreenControl: false
					, styles: [
						{ elementType: "geometry", stylers: [{ color: "#242f3e" }] },
						{ elementType: "labels.text.stroke", stylers: [{ color: "#242f3e" }] },
						{ elementType: "labels.text.fill", stylers: [{ color: "#746855" }] },
						{
							featureType: "administrative.locality",
							elementType: "labels.text.fill",
							stylers: [{ color: "#d59563" }],
						},
						{
							featureType: "poi",
							elementType: "labels.text.fill",
							stylers: [{ color: "#d59563" }],
						},
						{
							featureType: "poi.park",
							elementType: "geometry",
							stylers: [{ color: "#263c3f" }],
						},
						{
							featureType: "poi.park",
							elementType: "labels.text.fill",
							stylers: [{ color: "#6b9a76" }],
						},
						{
							featureType: "road",
							elementType: "geometry",
							stylers: [{ color: "#38414e" }],
						},
						{
							featureType: "road",
							elementType: "geometry.stroke",
							stylers: [{ color: "#212a37" }],
						},
						{
							featureType: "road",
							elementType: "labels.text.fill",
							stylers: [{ color: "#9ca5b3" }],
						},
						{
							featureType: "road.highway",
							elementType: "geometry",
							stylers: [{ color: "#746855" }],
						},
						{
							featureType: "road.highway",
							elementType: "geometry.stroke",
							stylers: [{ color: "#1f2835" }],
						},
						{
							featureType: "road.highway",
							elementType: "labels.text.fill",
							stylers: [{ color: "#f3d19c" }],
						},
						{
							featureType: "transit",
							elementType: "geometry",
							stylers: [{ color: "#2f3948" }],
						},
						{
							featureType: "transit.station",
							elementType: "labels.text.fill",
							stylers: [{ color: "#d59563" }],
						},
						{
							featureType: "water",
							elementType: "geometry",
							stylers: [{ color: "#17263c" }],
						},
						{
							featureType: "water",
							elementType: "labels.text.fill",
							stylers: [{ color: "#515c6d" }],
						},
						{
							featureType: "water",
							elementType: "labels.text.stroke",
							stylers: [{ color: "#17263c" }],
						},
					]
				});
			}else{
				map = new google.maps.Map(document.getElementById('map'), {
					center: uluru
					, zoom: Number(zoom)
					, zoomControl: false
					, mapTypeControl: false
					, scaleControl: false
					, streetViewControl: false
					, rotateControl: false
					, fullscreenControl: false
				});
			}
			var marker = new google.maps.Marker({position: uluru, map: map});
		},getCommuteData:function(){
			//출퇴근 버튼 설정
			var data = {
				commuteChannel : _commuteChannel
			}
			$.ajax({
				type:"POST",
				data:data,
				dataType:"json",
				url:"/groupware/attendCommute/getCommuteBtnStatus.do",
				success:function (data) {
					if(data.result=="ok"){
						if(mobile_comm_getBaseConfig('CommuteTimeYn')=='Y') {//출근-퇴근 시간 표기 설정 켜져있으면
							var unRegStr = mobile_comm_getDic("lbl_Unregistered");
							$("#startSts").html(unRegStr);
							$("#endSts").html(unRegStr);
							if (data.startTime != null && data.startTime != '') {
								$(".am_time_wrap_type2 .am_time").eq(0).addClass("active");
								$("#startSts").html(hmsTimeToAM(data.startTime));
							}
							if (data.endTime != null && data.endTime != '') {
								$(".am_time_wrap_type2 .am_time").eq(1).addClass("active");
								$("#endSts").html(hmsTimeToAM(data.endTime));
							}
						}else{//출근-퇴근 시간 표기 off
							$(".day_working_top").css("height","155px");
							$(".am_time_wrap_type2").hide();
						}

						//스크롤x 막기
						$("#attend_main_content").css("overflow-x","hidden");
						
						$("#attStsBtn").find("a").removeAttr("onclick");
						
						if(data.commuteStatus == 'SE') { // 전날 퇴근 미처리 건이 있으면, 출근 퇴근하기 버튼 모두에 미처리 퇴근 건에 대한 타각 이벤트 설정
							$("#attStsBtn > a[name='start']").attr("onclick", "AttendMobile.setCommute(\"SE\",\""+data.targetDate+"\")");
							$("#attStsBtn > a[name='end']").attr("onclick", "AttendMobile.setCommute(\"SE\",\""+data.targetDate+"\")");
						} else if(data.commuteStatus == "E") {
							$("#attStsBtn > a[name='start']").attr("onclick", "AttendMobile.setCommute(\"SS\",\""+data.targetDate+"\")");
							$("#attStsBtn > a[name='end']").attr("onclick", "AttendMobile.setCommute(\"E\",\""+data.targetDate+"\")");
						} else if(data.commuteStatus == "O" || data.commuteStatus == "EE") { // 당일 퇴근 데이터가 있는 경우, 퇴근 버튼에 재퇴근 이벤트 설정
							$("#attStsBtn > a[name='start']").attr("onclick", "AttendMobile.setCommute(\"SS\",\""+data.targetDate+"\")");
							$("#attStsBtn > a[name='end']").attr("onclick", "AttendMobile.setCommute(\"EE\",\""+data.targetDate+"\")");
						} else if(data.commuteStatus == "S") {
							$("#attStsBtn > a[name='start']").attr("onclick", "AttendMobile.setCommute(\"S\",\""+data.targetDate+"\")");
							
							if(data.endSts != '') {
								$("#attStsBtn > a[name='end']").attr("onclick", "AttendMobile.setCommute(\"EE\",\""+data.targetDate+"\")");
							} else {
								$("#attStsBtn > a[name='end']").attr("onclick", "AttendMobile.setCommute(\"E\",\""+data.targetDate+"\")");
							}
						}
						
						// 승인대기 중인 경우에는 이벤트 발생 X
						if(data.startSts == 'lbl_adstandby') $("#attStsBtn > a[name='start']").attr("onclick", "AttendMobile.setCommute(\"W\",\""+data.targetDate+"\")");
						if(data.endSts == 'lbl_adstandby') $("#attStsBtn > a[name='end']").attr("onclick", "AttendMobile.setCommute(\"W\",\""+data.targetDate+"\")");

						var jobList= data.jobList;

						var jobSelStr = "";
						for(var i=0;i<jobList.length;i++){
							if(jobList[i].ReqMethod!='Approval'){
								jobSelStr += "<option value="+jobList[i].JobStsSeq+">"+jobList[i].JobStsName+"</option>";
							}
						}
						$("#jobSelectBox").html("");
						$("#jobSelectBox").append(jobSelStr);
					}
				}
			});
		},getMyAttInfo:function(){
			var params = {
				dateTerm : "W"	//주간
				,targetDate : _targetDate
			}
			$.ajax({
				type : "POST",
				data : params,
				url : "/groupware/attendUserSts/getMyAttStatusV2.do",
				success:function (data) {
					if(data.status=="SUCCESS"){
						
						var att = data.attMap;
						var userAtt = att.userAtt[0];
						var userAttList = userAtt.userAttList;
						var userAttWorkTime = userAtt.userAttWorkTime;
						var userWorkInfo = userAttList[0].userWorkInfo;
						if(userWorkInfo==null){//사용자에 대한 기본 할당된 근로정보 기준이 없으면
							userWorkInfo="UR|1111100|2000-01-01|UR|40|week|1week|2000-01-01|UR|52|week|1week|2000-01-01|52";
						}
						
						_stDate = att.p_sDate;
						_edDate = att.p_eDate;
						var today = CFN_GetLocalCurrentDate("yyyy-MM-dd");
						//검색 날짜표기
						var dayTitle = att.dayMobileTitle;
						$("#dayRoun").html(dayTitle);

						//상단 사용자 정보 표기
						$(".tx_user").html(userAtt.displayName+" "+userAtt.jobPositionName+" / "+userAtt.deptName);//이름/부서
						//시간정보갱신
						
						//주간 상태 리스트
						var tempList = $("#tempList").clone();
						$("#bodyList").html("");
						var boldS = "";
						var boldE = "";
						var todayLiLineNum = -1;
						for(var i=0;i<userAttList.length;i++){
							var tempLi = tempList.find("li").clone();
							var dayList = userAttList[i].dayList;
							if(today===dayList){//오늘 날짜 관련 출력
								//변수기록
								g_TodayAttStartTime = dayList.replaceAll("-","/")+" "+userAttList[i].v_AttStartHour+":"+userAttList[i].v_AttStartMin+":00";
								g_TodayAttEndTime = dayList.replaceAll("-","/")+" "+userAttList[i].v_AttEndHour+":"+userAttList[i].v_AttEndMin+":00";
								g_TodayAttStartTagTime =  userAttList[i].v_AttStartTime;
								g_TodayAttEndTagTime =  userAttList[i].v_AttEndTime;
								g_TodayAttDayStartTime = userAttList[i].AttDayStartTime;
								g_TodayAttDayEndTime = userAttList[i].AttDayEndTime;
								g_WorkingSystemType = userAttList[i].WorkingSystemType;
								g_SchName = userAttList[i].SchName;

								tempLi.find(".tx_day").html("<b>"+userAttList[i].v_day+"</b>");
								boldS = "<b>";
								boldE = "</b>";
								todayLiLineNum = i;
								//오늘의 근무 계획 시간 출력
								var workSch = userAttList[i].v_AttDayStartHour+":"+userAttList[i].v_AttDayStartMin+"~"+userAttList[i].v_AttDayEndHour+":"+userAttList[i].v_AttDayEndMin;
								if(g_WorkingSystemType===0){//정규시간 근로제
									if(workSch.indexOf("null")>-1){
										$(".tx_standardhour").html("");
									}else{
										$(".tx_standardhour").html(workSch);
									}
								}else{//선택 또는 자율 출퇴근제시 근로제 명칭 출력
									$(".tx_standardhour").html(g_SchName);
								}
								//근무 여부 출력
								var attState = "";
								var attStateFontColor = "";
								var attStateBGColor = "";

								if(userAttList[i].v_AttStartTime===null||userAttList[i].v_AttStartTime===""){
									attState = Common.getDic("lbl_before_goWork"); // 출근전
									attStateBGColor = "#2c6fca";
									attStateFontColor = "#ffffff";
								}else if(userAttList[i].v_AttEndTime===null||userAttList[i].v_AttEndTime===""){
									attState = Common.getDic("lbl_onWorking"); // 근무중
									attStateBGColor = "#5ace7e";
									attStateFontColor = "#ffffff";
								}else if(userAttList[i].v_AttStartTime!=null && userAttList[i].v_AttEndTime!=null){
									attState = Common.getDic("lbl_leave"); // 퇴근
									attStateBGColor = "#2c6fca";
									attStateFontColor = "#ffffff";
								}
								$("#tx_state").html(attState).trigger("create");
								$("#tx_state").css("background-color",attStateBGColor);
								$("#tx_state").css("color",attStateFontColor);
								$("#tx_state").css("font-weight","bold");

							}else{
								tempLi.find(".tx_day").html(userAttList[i].v_day);
								boldS = "";
								boldE = "";
							}

							switch(userAttList[i].weekd){
								case 0 :
									tempLi.find(".tx_day_s").html(boldS+"("+mobile_comm_getDic('lbl_WPMon')+")"+boldE);
									break;
								case 1 :
									tempLi.find(".tx_day_s").html(boldS+"("+mobile_comm_getDic('lbl_WPTue')+")"+boldE);
									break;
								case 2 :
									tempLi.find(".tx_day_s").html(boldS+"("+mobile_comm_getDic('lbl_WPWed')+")"+boldE);
									break;
								case 3 :
									tempLi.find(".tx_day_s").html(boldS+"("+mobile_comm_getDic('lbl_WPThu')+")"+boldE);
									break;
								case 4 :
									tempLi.find(".tx_day_s").html(boldS+"("+mobile_comm_getDic('lbl_WPFri')+")"+boldE);
									break;
								case 5 :
									tempLi.find(".tx_day_s").html(boldS+"("+mobile_comm_getDic('lbl_WPSat')+")"+boldE);
									tempLi.addClass("list_sat");
									break;
								case 6 :
									tempLi.find(".tx_day_s").html(boldS+"("+mobile_comm_getDic('lbl_WPSun')+")");
									tempLi.addClass("list_sun");
									break;
							}
							tempLi.find(".am_time_list_cont").addClass(AttendMobile._commuteTimeYn == "Y"?"case02":"case01");
							//기타근무 상태
							if(userAttList[i].jh_JobStsName!=null && userAttList[i].jh_JobStsName != ''){
								var jobSts = $('<span />',{
									class : "tx_status"
									,text : userAttList[i].jh_JobStsName
								});
							 	tempLi.find(".am_time_list_status").html(jobSts);
							}
							
							//출근 상태
							if(userAttList[i].StartSts!=null){
								var startSts = tempLi.find(".am_time_list_cont > span").eq(0); 
								
								startSts.addClass("tx_normal");
								startSts.text(mobile_comm_getDic(userAttList[i].StartSts)+(AttendMobile._commuteTimeYn == "Y" && userAttList[i].v_AttStartTime != null?"("+userAttList[i].v_AttStartTime+")":""));
								
								if(userAttList[i].StartSts == "lbl_n_att_absent"){	//결근
									startSts.removeClass("tx_normal");
									startSts.addClass('tx_late');
									startSts.addClass('Absent');
								}else if(userAttList[i].StartSts == "lbl_n_att_callingTarget"){ //소명
									startSts.removeClass("tx_normal");
									startSts.addClass('tx_extime');
									startSts.addClass('Calling');
								}else {	
									if(userAttList[i].StartSts == "lbl_att_beingLate"){	//지각
										startSts.removeClass("tx_normal");
										startSts.addClass('tx_late');
										startSts.addClass('Normal2');
									}else{
										startSts.addClass('Normal');
									}
								}
							}
							//퇴근 상태
							if(userAttList[i].EndSts!=null){
								var endSts = tempLi.find(".am_time_list_cont > span").eq(1); 
								
								endSts.addClass("tx_normal");
								endSts.text(mobile_comm_getDic(userAttList[i].EndSts)+(AttendMobile._commuteTimeYn == "Y" && userAttList[i].v_AttEndTime != null?"("+userAttList[i].v_AttEndTime+")":""));
								
								if(userAttList[i].EndSts == "lbl_n_att_absent"){	//결근
									endSts.removeClass("tx_normal");
									endSts.addClass('tx_late');
									endSts.addClass('Absent');
								}else if(userAttList[i].EndSts == "lbl_n_att_callingTarget"){ //소명
									endSts.removeClass("tx_normal");
									endSts.addClass('tx_extime');
									endSts.addClass('Calling');
								}else {	
									if(userAttList[i].EndSts == "lbl_att_leaveErly"){	//조퇴
										endSts.removeClass("tx_normal");
										endSts.addClass('tx_late');
										endSts.addClass('Normal2');
									}else{
										endSts.addClass('Normal');
									}
								}
							}
							
							//연장 근무
							if(userAttList[i].ExtenAc != null && userAttList[i].ExtenAc != ""){
								var exSts = $('<span />',{
									class : 'tx_extime Ex'
									,style : "float: left;"
									,text : mobile_comm_getDic("lbl_att_overtime_work")
								});
								tempLi.find(".am_time_list_cont").append(exSts);
							}
							
							//휴일 근무
							if(userAttList[i].HoliAc != null && userAttList[i].HoliAc != ""){
								var hoSts = $('<span />',{
									class : 'tx_extime Ho'
									,style : "float: left;"
									,text : mobile_comm_getDic("lbl_att_holiday_work")
								});
								tempLi.find(".am_time_list_cont").append(hoSts);
							}
							
							//휴무일
							if(userAttList[i].WorkSts == "OFF" || (userAttList[i].WorkSts == "HOL" && userAttList[i].weekd<5)){
								var holidaySts = $('<span/>',{
									class : 'tx_closed Holiday'
									,style : "float: left;"
									,text : mobile_comm_getDic("lbl_att_sch_holiday")
								});
								tempLi.find(".am_time_list_cont").empty().append(holidaySts);
							}
							
							//휴가
							if(userAttList[i].VacFlag != null && userAttList[i].VacFlag != ""){
								//연차종류
								var vacSts = $('<span />',{
									class : 'tx_vacation Vacation'
									,style : "float: left;"
									,text : userAttList[i].VacName
								});
								//반차
								if(userAttList[i].VacFlag == "VACATION_OFF"){
									vacSts.addClass("Half");
								}
								tempLi.find(".am_time_list_cont").empty().append(vacSts);
							}

							$("#bodyList").append(tempLi);


						}//end for
						if(todayLiLineNum>-1){
							if(urTheme==="black") {//다크모드시 오늘 li 백그라운드 어둡게
								$("#bodyList li").eq(todayLiLineNum).css("background-color", "#5c6d88").addClass("active");
								$(".day_working_top").css("background-color", "#222222");
								$(".am_time_tit").css("background", "0");
								$(".am_time_wrap_type2").css("background-color", "#222222");
								$(".am_time").css("background-color", "#222222");
								$(".btn_workout").css("background-color", "#555555");
								$(".btn_workout span").css("color", "#ffffff");
								$(".tx_today").css("color", "#555555");
								$("#bodyList li").eq(todayLiLineNum).css("background-color","#555555");
							}else if(urTheme==="red"){
								$("#bodyList li").eq(todayLiLineNum).css("background-color","#5c6d88");
								$(".day_working_top").css("background-color","#f16e40");
								$(".am_time_tit").css("background","0");
								$(".am_time_wrap_type2").css("background-color","#f16e40");
								$(".am_time").css("background-color","#f04040");
								$(".btn_workout").css("background-color","#ffffff");
								$(".btn_workout span").css("color","#2c6fca");
								$(".tx_today").css("color", "#f04040");
								$("#bodyList li").eq(todayLiLineNum).css("background-color","#ffc5bb");
							}else if(urTheme==="green"){
								$("#bodyList li").eq(todayLiLineNum).css("background-color","#5c6d88");
								$(".day_working_top").css("background-color","#2ba472");
								$(".am_time_tit").css("background","0");
								$(".am_time_wrap_type2").css("background-color","#2ba472");
								$(".am_time").css("background-color","#6fb128");
								$(".btn_workout").css("background-color","#ffffff");
								$(".btn_workout span").css("color","#2c6fca");
								$(".tx_today").css("color", "#6fb128");
								$("#bodyList li").eq(todayLiLineNum).css("background-color","#c2ffbb");
							}else{
								$("#bodyList li").eq(todayLiLineNum).css("background-color","#b8eeff");
							}
						}


						//하단 평균 근로시간 값 셋
						var totWorkTimeMin = Number(userAttWorkTime.TotWorkTime);
						var userTotWorkTimeF = fun_convertSecToStr(totWorkTimeMin,"H");
						userTotWorkTimeF = userTotWorkTimeF.replace("h","시간").replace("m","분");
						$("#week_wh_hour").html(userTotWorkTimeF).trigger("create");
						var ckOverTimeColor = userWorkTimeCheck(userWorkInfo, totWorkTimeMin, "W");

						$("#week_wh_hour").css("color",ckOverTimeColor);
						$("#graph_bar").css("background-color",ckOverTimeColor);
						var maxWorkTime = userMaxWorkTime(userWorkInfo);
						$("#graph_tx_end").html(maxWorkTime+"h").trigger("create");
						var limitWorkTime = userLimitWorkTime(userWorkInfo);
						$("#graph_mark").html(limitWorkTime).trigger("create");
						var maxWorkTimeMin = maxWorkTime * 60;
						var workTimePercent = (totWorkTimeMin/maxWorkTimeMin)*100;
						if(workTimePercent>100){workTimePercent=100;}
						$("#graph_bar").css("width",workTimePercent+"%");
						var limitWorkTimeMin = limitWorkTime * 60;
						var limitLeftPosition = (limitWorkTimeMin/maxWorkTimeMin)*100;
						if(limitLeftPosition>100){limitLeftPosition=100;}
						$("#graph_mark").css("left",limitLeftPosition+"%");
						$("#graph_limit_bar").css("left",limitLeftPosition+"%");

						//인정시간
						var attWeeklyRealTime = Number(userAttWorkTime.AttRealTime);
						var workRealTimePercent = (attWeeklyRealTime/maxWorkTimeMin)*100;
						if(workRealTimePercent>100){workRealTimePercent=100;}
						$("#graph_bar_real").css("width",workRealTimePercent+"%");
						var realConfWorkTime = fun_convertSecToStr(attWeeklyRealTime,"H");
						$("#graph_mark_real").html(realConfWorkTime).trigger("create");
						var realConfMarkPosition = (attWeeklyRealTime/maxWorkTimeMin)*100;
						if(realConfMarkPosition>100){realConfMarkPosition=100;}
						var realConfMarkPosPer = realConfMarkPosition;
						if(realConfMarkPosPer<8||realConfMarkPosPer>58){
							$("#graph_mark_real").hide();
						}else{
							$("#graph_mark_real").show();
						}
						$("#graph_mark_real").css("left",realConfMarkPosition+"%");
						realConfMarkPosition = Number($(".graph_mark_real").position().left);
						var halfw = Number($(".graph_mark_real").width())/2;
						realConfMarkPosition = realConfMarkPosition-halfw;
						$("#graph_mark_real").css("left",realConfMarkPosition+"px");
						//인정근무와 총근무 시간 값에 따른 Z-index 설정
						if(maxWorkTimeMin<=totWorkTimeMin){//주 최대 근로 시간 초과시
							$("#graph_bar").show();
							$("#graph_bar").css("zIndex","5");
							$("#graph_bar_real").css("zIndex","2");
							$("#graph_bar_exten").hide();
							$("#graph_bar_holi").hide();
						}else if(limitWorkTimeMin<=totWorkTimeMin){//주 소정 근로 시간 초과시
							$("#graph_bar").show();
							$("#graph_bar").css("zIndex","5");
							$("#graph_bar_real").css("zIndex","2");
							$("#graph_bar_exten").hide();
							$("#graph_bar_holi").hide();
						}else if(attWeeklyRealTime<totWorkTimeMin){
							$("#graph_bar").hide();
							$("#graph_bar").css("zIndex","2");
							$("#graph_bar_real").css("zIndex","5");
							$("#graph_bar_exten").show();
							$("#graph_bar_holi").show();
						}else{
							$("#graph_bar").show();
							$("#graph_bar").css("zIndex","5");
							$("#graph_bar_real").css("zIndex","2");
							$("#graph_bar_exten").show()
							$("#graph_bar_holi").show();
						}



						//인정근무
						realConfWorkTime = realConfWorkTime.replace("h","시간").replace("m","분");
						$(".week_ex_hour01 dd").html(realConfWorkTime).trigger("create");
						//연장근무
						var totExtenAc = Number(userAttWorkTime.ExtenAc);
						var totExtenAcF = fun_convertSecToStr(totExtenAc,"H");
						totExtenAcF = totExtenAcF.replace("h","시간").replace("m","분");
						$(".week_ex_hour02 dd").html(totExtenAcF).trigger("create");
						var totExtenWidth = (totExtenAc/maxWorkTimeMin)*100;
						$("#graph_bar_exten").css("width",totExtenWidth+"%");
						var realBarLeft = Number($("#graph_bar_real").position().left);
						var realBarWidth = Number($("#graph_bar_real").width());
						$("#graph_bar_exten").css("left",(realBarLeft+realBarWidth)+"px");

						//휴일근무
						var totHoliAc = Number(userAttWorkTime.HoliAc);
						var totHoliAcF = fun_convertSecToStr(totHoliAc,"H");
						totHoliAcF = totHoliAcF.replace("h","시간").replace("m","분");
						$(".week_ex_hour03 dd").html(totHoliAcF).trigger("create");
						var totHoliWidth = (totHoliAc/maxWorkTimeMin)*100;
						$("#graph_bar_holi").css("width",totHoliWidth+"%");
						var extenBarLeft = Number($("#graph_bar_exten").position().left);
						var extenBarWidth = Number($("#graph_bar_exten").width());
						$("#graph_bar_holi").css("left",(extenBarLeft+extenBarWidth)+"px");

						//라운드 여부 체크 처리
						if(totExtenAc>0 && totHoliAc>0){
							$("#graph_bar_exten").css("border-top-right-radius","0");
							$("#graph_bar_exten").css("border-bottom-right-radius","0");
						}else{
							$("#graph_bar_exten").css("border-top-right-radius","4px");
							$("#graph_bar_exten").css("border-bottom-right-radius","4px");
						}

					}else{
						alert(mobile_comm_getDic("msg_sns_03"));
					}
				},
				error:function (request,status,error){
					alert(mobile_comm_getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
				}
			});
		},setToday:function(){
			_targetDate = null;
			AttendMobile.getMyAttInfo();
		},dayChg:function(t){
			if("+"==t){
				_targetDate = _edDate;
			}else if("-"==t){
				_targetDate = _stDate;
			}
			AttendMobile.getMyAttInfo();
		},setCommute:function(type,targetDate){
			var dayList = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'];
			
			var date = new Date(targetDate);
			var day = dayList[date.getDay()];
			
			var commuteType = "";
			if(type == "S"){	//출근
				popMsg = targetDate+"("+ Common.getDic("lbl_sch_" + day) + ") " + mobile_comm_getDic("msg_att_commuAlramY");
				commuteType = "S";
			}else if(type=="W"){ //승인대기
				alert(mobile_comm_getDic("lbl_hr_err02"));
				return;
			}else if(type =="SS"){ //이미 출근한 경우
				alert(targetDate+"("+ Common.getDic("lbl_sch_" + day) + ") " + mobile_comm_getDic("msg_att_exist_commteY"));
				return;
			}else if(type == "E"){	//퇴근
				popMsg = targetDate+"("+ Common.getDic("lbl_sch_" + day) + ") " + mobile_comm_getDic("msg_att_commuAlramN");
				commuteType = "E";
			}else if(type == "SE"){ //퇴근  (전날 미처리건)
				popMsg = mobile_comm_getDic("msg_n_att_commuAlramNotEnd").replace("{0}",targetDate+"("+ Common.getDic("lbl_sch_" + day) +")");
				popMsg += "\n"+mobile_comm_getDic("msg_att_commuAlramN");
				commuteType = "E";
			}else if(type == "EE"){ //퇴근 중복
				popMsg = targetDate+"("+ Common.getDic("lbl_sch_" + day) + ") " + mobile_comm_getDic("mst_n_att_commuAlramReEnd");
				commuteType = "E";
			}
			if(confirm(popMsg)){
				
				var params = {
						commuteChannel : 'M'
						,commuteType : commuteType
						,targetDate : targetDate
						,commutePointX : _pointX
						,commutePointY : _pointY
					}
				 
				var status ; 
				$.ajax({
					type:"POST",
					data:params,
					async:false, 
					dataType:"json",
					url:"/groupware/attendCommute/setCommute.do",
					success:function (data) {
						if(data.status=="SUCCESS"){
							alert(mobile_comm_getDic("msg_SuccessRegist"));
							AttendMobile.getCommuteData();
							AttendMobile.getMyAttInfo();
						}else{
							if(data.type=="None" || data.type=="Request" || data.type=="Approval"){	
								var msg = mobile_comm_getDic("msg_att_n_requestCommute");
								if(confirm(data.message+"\n"+msg)){
									//AttendMobile.requestCommute(data,params);	
									_params = params ; 
									AttendMobile.openReqPopup();
								}
							}else{
								alert(data.message);								
							}
						}
					}
				});
				
			}
			
		},requestCommute:function(){
			var today = new Date();
			today.setHours(today.getHours() + 9);
			today = today.toISOString().replace('T', ' ').substring(0, 19);
			
			var aJsonArray = new Array();
			var saveData = {
				 "UserCode" 		: $("#userCode").val()
				,"WorkDate" 		: _params.targetDate 
				,"TargetDate" 		: _params.targetDate 
				,"CommuteType" 		: _params.commuteType 
				,"CommuteChannel"	: _params.commuteChannel
				,"CommutePointX" 	: _params.commutePointX
				,"CommutePointY" 	: _params.commutePointY 
				,"CommuteTime" 		: today
			};
			
			aJsonArray.push(saveData);
			
			var reqType = _params.commuteType == "S" ? "A" : _params.commuteType == "E" ? "L" : "";
			var comment =  $("#userEtc").val();
			var saveJson ={
				"ReqType":reqType,
				"ReqGubun":"C",
				"Comment":comment,
				"ReqData":aJsonArray
			}
			
			//insert 호출		
			 $.ajax({
				type:"POST",
				contentType:'application/json; charset=utf-8',
				dataType   : 'json',
				url : "/groupware/attendReq/requestCommute.do",
				data : JSON.stringify(saveJson),
				success : function(data){	
					if(data.status=='SUCCESS'){
						alert(mobile_comm_getDic("msg_SuccessRegist"));
						AttendMobile.getCommuteData();
						AttendMobile.getMyAttInfo();
						
						AttendMobile.closeReqPopup();
					}else{
						alert(data.message);
					}	
					
					
				}
		    });
		},closeReqPopup:function(){
			$(".attReqPopup").hide();
		},openReqPopup:function(){
			$("#userEtc").val("");
			$(".attReqPopup").show();
		},openLayer:function(){
			$("#StartTime  option:eq(0)").prop("selected", true);
			$("#EndTime  option:eq(0)").prop("selected", true);
			$("#JobSeq  option:eq(0)").prop("selected", true);

			$("#JobDate").val("");
			$("#JobDate").datepicker("destroy");
			$("#JobDate").datepicker({
				dateFormat: 'yy.mm.dd',
				ignoreReadonly: true
			});
			
			$("#Etc").val("");
			$("#jobPopup").show();

		},closeLayer:function(){
			$("#jobPopup").hide();
		},saveJob:function(){
			var data = $("#jobFrm").serializeArray();
			
			if($("#StartTime").val() > $("#EndTime").val()){
				alert(mobile_comm_getDic("msg_Mobile_InvalidStartTime"));	//시작시간이 종료시간보다 클 수 없습니다.
				return;
			}
			
			if($("#JobDate").val()==""){
				alert(mobile_comm_getDic("msg_att_workDate_isNull"));
				return ;
			}else{
				$.ajax({
					type:"POST",
					dataType:"json",
					data : data,
					url:"/groupware/attendCommute/setMemJobSts.do",
					success:function (data) {
						if(data.status=="SUCCESS"){
							alert(mobile_comm_getDic("msg_37"));
							AttendMobile.refreshList();
							AttendMobile.closeLayer();
						}else if(data.status=="OVERLAPPING"){
							alert(mobile_comm_getDic("msg_att_overlapping"));/* 저장 중 오류가 발생하였습니다. */	
						}else{
							alert(mobile_comm_getDic("msg_sns_03"));/* 저장 중 오류가 발생하였습니다. */	
						}
					}
				});
			}
		},refreshList:function(){
//			_sNum = 0;
//			_stDate = "";
			AttendMobile.getCommuteData();
		}

};

var AttendMobileDeptList = {
	Page: 1,				//페이지 번호
	PageSize: 100,			//페이지당 건수
	Loading: false,			//데이터 조회 중
	TotalCount: -1,			//전체 건수
	RecentCount: 0,			//현재 보여지는 건수
	EndOfList: false,		//전체 리스트를 다 보여줬는지 여부
	OnBack: false,			//뒤로가기로 왔을 경우
	Scroll: 0,
	TargetDate: "",
	init: function(){
		AttendMobileDeptList.Page = 1;
		AttendMobileDeptList.EndOfList = false;
		
		mobile_comm_getDicList(["lbl_Remark", "lbl_att_goWork", "lbl_att_offWork", "lbl_att_beingLate", "lbl_attendance_normal", "lbl_n_att_absent", "msg_NoDataList", "lbl_noexists"]);
		
		if(!$('#attend_list_topmenu .h_tree_menu_wrap').html())
			AttendMobileDeptList.setMenuList(AttendMenu);
		
		AttendMobileDeptList.setEvent();
		
		AttendMobileDeptList.setToday();
		
		AttendMobileDeptList.getDeptList();
	},
	setEvent: function(){
		$("#attend_list_input_calendar").datepicker({
			dateFormat: 'yy.mm.dd',
			dayNamesMin: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
			onSelect: function(dateText, inst){
				AttendMobileDeptList.TargetDate = dateText;
				AttendMobileDeptList.Page = 1;
				AttendMobileDeptList.EndOfList = false;
				
				$("#attend_list_today").text(AttendMobileDeptList.TargetDate);
				AttendMobileDeptList.setListPage();
			},
			beforeShow: function(input){
				var topPos = $("#attend_list_btn_calendar").offset().top
					+ Number($("#attend_list_btn_calendar").css("height").replace(/[^\-\.0-9]/g, ""));
				
				setTimeout(function(){
				   $("#ui-datepicker-div").css({"top": topPos + "px", "left": "10px", "right": "10px"});
				});
			}
		});
		
		$("#attend_list_btn_calendar").on("click", function(){
			$("#attend_list_input_calendar").datepicker("show");
		});
		
		$("#attend_list_select").off("change").on("change", function(){
			AttendMobileDeptList.Page = 1;
			AttendMobileDeptList.EndOfList = false;
			AttendMobileDeptList.setListPage();
		});
		
		$("#attend_list_prev_month").on("click", function(){
			AttendMobileDeptList.dateChange("PREV");
		});
		
		$("#attend_list_next_month").on("click", function(){
			AttendMobileDeptList.dateChange("NEXT");
		});
		
		$("#attend_list_more").on("click", function(){
			AttendMobileDeptList.showNextList();
		});
	},
	setMenuList: function(attendancemenu){
		var sHtml = "";
		var nSubLength = 0;
		var sALink = "";
		var sLeftMenuID = "";
		
		sHtml += "<ul class=\"h_tree_menu_wrap\">";
		sHtml += "<li displayname=\"" + mobile_comm_getDic("BizSection_Attendance") + "\">";
		sHtml += "	<div class=\"h_tree_menu\">";
		sHtml += "	<a href=\"javascript: mobile_comm_go('/groupware/mobile/attend/main.do');\" class=\"t_link\">";
		sHtml += "		<span class=\"t_ico_doc\"></span>";
		sHtml += "		" + mobile_comm_getDic("BizSection_Attendance");
		sHtml += "	</a>";
		sHtml += "	</div>";
		sHtml += "</li>";
		
		$(attendancemenu).each(function (i, data){
			if(data.MobileURL){
				if(data.MobileURL.toUpperCase().indexOf("LIST.DO") > -1){
					sALink = "javascript: mobile_comm_go('/groupware/mobile/attend/list.do');";
				}else{
					sALink = "javascript: mobile_comm_go('/groupware/mobile/attend/main.do');";
				}
				
				nSubLength = (data.Sub == null || data.Sub == undefined) ? 0 : data.Sub.length;
				
				sHtml += "<li displayname=\"" + data.DisplayName + "\">";
				sHtml += "	<div class=\"h_tree_menu\">";
				
				if(nSubLength > 0) {
					sHtml += "	<a href=\"\" class=\"t_link not_tree\">";
					sHtml += "	  	  <span onclick=\"javascript: mobile_bizcard_openclose('li_sub_" + data.MenuID + "', 'span_menu_" + data.MenuID + "');\">";
					sHtml += "			  <span id=\"span_menu_" + data.MenuID + "\" class=\"t_ico_open\"></span><span class=\"t_ico_call\"></span>";
					sHtml += "	  	  </span>"
					sHtml += "		  <span onclick=\"" + sALink + "\">";
					sHtml += "			  " + data.DisplayName;
					sHtml += "		  </span>";
					sHtml += "	</a>";
					
					sHtml += "	<ul class=\"sub_list\" id=\"li_sub_" + data.MenuID + "\">";
					$(data.Sub).each(function (j, subdata){
						if(data.MobileURL.toUpperCase().indexOf("LIST.DO") > -1){
							sALink = "javascript: mobile_comm_go('/groupware/mobile/attend/list.do');";
						}else{
							sALink = "javascript: mobile_comm_go('/groupware/mobile/attend/main.do');";
						}
						
						sHtml += "	<li displayname=\"" + subdata.DisplayName + "\">";
						sHtml += "		<a href=\"" + sALink + "\" class=\"t_link\">";
						sHtml += "			<span class=\"t_ico_board\"></span>";
						sHtml += "			" + subdata.DisplayName;
						sHtml += "		</a>";
						sHtml += "	</li>";
					});
					sHtml += "	</ul>";
					
				} else {
					sHtml += "	<a href=\"" + sALink + "\" class=\"t_link not_tree\">";
					sHtml += "		<span class=\"t_ico_app\"></span>";
					sHtml += "		" + data.DisplayName;
					sHtml += "	</a>";
				}
				
				sHtml += "	</div>";
				sHtml += "</li>";
			}
			
		});
		sHtml += "</ul>";
		
		$('#attend_list_topmenu').html(sHtml);
	},
	getDeptList: function(){
		$.ajax({
			url: "/groupware/attendCommon/getDeptList.do",
			type: "POST",
			async: true,
			dataType: "json",
			success: function(data){
				var subDeptList = data.deptList;
				var subDeptOption = "";
				
				for(var i = 0;i < subDeptList.length; i++){
					subDeptOption += "<option value='"+subDeptList[i].GroupPath+"'>";
					var SortDepth = subDeptList[i].SortDepth;
					for(var j = 1; j < SortDepth; j++){
						subDeptOption += "&nbsp;";
					}
					subDeptOption += subDeptList[i].TransMultiDisplayName+"</option>";
				}
				
				$("#attend_list_select").html(subDeptOption);
				$("#attend_list_select option:first").prop("selected", true);
				
				AttendMobileDeptList.Page = 1;
				AttendMobileDeptList.EndOfList = false;
				AttendMobileDeptList.setListPage();
			}
		});
	},
	setListPage: function(){
		var sPage = AttendMobileDeptList.Page;
		var sPageSize = AttendMobileDeptList.PageSize;
		var selGroupPath = $("#attend_list_select").val();
		
		if(AttendMobileDeptList.OnBack) {
			sPageSize = sPage * (sPageSize);
			sPage = 1;
		}
		
		mobile_comm_TopMenuClick('attend_list_topmenu', true);
		
		$.ajax({
			url: "/groupware/attendUserSts/getUserAttendanceList.do",
			data: {
				pageNo: sPage,
				pageSize: sPageSize,
				groupPath: selGroupPath,
				dateTerm: "",
				startDate: AttendMobileDeptList.TargetDate,
				endDate: AttendMobileDeptList.TargetDate,
				sUserTxt: "",
				sJobTitleCode: "",
				sJobLevelCode: "",
				AttStatus: "",
				searchText: "",
				SchSeq: ""
			},
			type: "POST",
			success: function(data){
				if(data.status == "SUCCESS"){
					AttendMobileDeptList.TotalCount = data.page.listCount;
					
					//목록별 데이터 처리
					var sHtml = "";
					
					if(data.list.length > 0){
						$.each(data.list, function(idx, item){
							var liWrap = $("<li>");
							var jobPos = !item.JobPositionName ? "" : item.JobPositionName;
							
							liWrap.append($("<div class='staff_box'>")
								.append($("<div class='staff_box_top'>")
									.append($("<p class='name'>").text(item.DisplayName + " " + jobPos))
									.append($("<p class='state'>")))
								.append($("<div class='staff_box_middle'>")
									.append($("<div class='attendance'>")
										.append($("<p class='tx'>").text(mobile_globalCache["lbl_att_goWork"])) // 출근
										.append($("<p class='date'>")
											.append($("<span class='tx'>").text(item.v_AttStartTime == null ? mobile_globalCache["lbl_noexists"] : item.v_AttStartTime)))) // 없음
									.append($("<div class='leave'>")
										.append($("<p class='tx'>")).text(mobile_globalCache["lbl_att_offWork"]) // 퇴근
										.append($("<p class='date'>")
											.append($("<span class='tx'>").text(item.v_AttEndTime == null ? mobile_globalCache["lbl_noexists"] : item.v_AttEndTime))))) // 없음
								.append($("<div class='staff_box_bottom'>")
									.append($("<dl class='staff_box_dl'>")
										.append($("<dt>").text(mobile_globalCache["lbl_Remark"])) // 비고
										.append($("<dd>").text(item.Etc)))));
							
							if(item.LateMin && item.LateMin != ""){
								liWrap.find(".state").addClass("late").text(mobile_globalCache["lbl_att_beingLate"]); // 지각
							}else if(item.v_AttStartTime != null && item.v_AttEndTime != null){
								liWrap.find(".state").addClass("normal").text(mobile_globalCache["lbl_attendance_normal"]); // 정상
							}
							
							sHtml += $(liWrap)[0].outerHTML;
						});
					}else{
						var liWrap = $("<li>").text(mobile_globalCache["msg_NoDataList"]) // 조회할 목록이 없습니다.
							.css({"text-align": "center"});
						
						sHtml += $(liWrap)[0].outerHTML;
					}
					
					if(AttendMobileDeptList.Page == 1 || data.list.length <= 0){
						$("#attend_list_dept").html(sHtml);
					}else{
						$("#attend_list_dept").append(sHtml);
					}
					
					if(Math.min((AttendMobileDeptList.Page) * AttendMobileDeptList.PageSize, AttendMobileDeptList.TotalCount) == AttendMobileDeptList.TotalCount){
						AttendMobileDeptList.EndOfList = true;
						$("#attend_list_more").hide();
					}else{
						$("#attend_list_more").show();
					}
					
					if(AttendMobileDeptList.OnBack){
						AttendMobileDeptList.OnBack = false;
					}
				}
			},
			error: function (response, status, error){
				mobile_comm_ajaxerror(url, response, status, error);
			}
		});
	},
	setToday: function(){
		AttendMobileDeptList.TargetDate = mobile_comm_getDateTimeString2("yyyy.MM.dd", new Date());
		
		$("#attend_list_today").text(AttendMobileDeptList.TargetDate);
	},
	dateChange: function(pType){
		if("NEXT" == pType){
			AttendMobileDeptList.TargetDate = mobile_schedule_SetDateFormat(mobile_schedule_AddDays(new Date(AttendMobileDeptList.TargetDate), 1), ".");
		}else if("PREV" == pType){
			AttendMobileDeptList.TargetDate = mobile_schedule_SetDateFormat(mobile_schedule_AddDays(new Date(AttendMobileDeptList.TargetDate), -1), ".");
		}
		
		AttendMobileDeptList.Page = 1;
		AttendMobileDeptList.EndOfList = false;
		
		$("#attend_list_today").text(AttendMobileDeptList.TargetDate);
		AttendMobileDeptList.setListPage();
	},
	showNextList: function(){
		if(!AttendMobileDeptList.EndOfList){
			AttendMobileDeptList.Page++;
			AttendMobileDeptList.setListPage();
		}else{
			$("#attend_list_more").hide();
		}
	}
};

//application 좌표 호출 
function mobile_attendance_callapplocation(){
	/*
	 * 근태관리 모바일 app 좌표정보 조회
	 * */
	var lon , lat ;
	if(mobile_comm_isAndroidApp()) {
	    window.covimoapp.GetLocationInfo();
	} else if(mobile_comm_isiOSApp()) {
	    window.webkit.messageHandlers.callbackHandler.postMessage({ type:'getlocationinfo' });
	} else{
		navigator.geolocation.getCurrentPosition(function(position) {
		    lat = position.coords.latitude;    // 위도
		    lon = position.coords.longitude; // 경도
		   
		    AttendMobile.mapLoad(lon,lat);		
		},function(e){
			alert("error : "+e);
		});	
	}
	
}

//application 호출 callback 함수
function mobile_attendance_callapplocation_callback(pLocationCode) {
	
	/*app i/f 시 좌표정보 정상 여부에 상관없이 app 에서 호출 정상인 경우 버튼 활성화*/
	try {
		var jsonlocationinfo = JSON.parse(pLocationCode);
		
		//주기기 체크여부 추가 (기초설정 추가 : UseDeviceCheck/기본 N)
		if(mobile_comm_getBaseConfig('UseDeviceCheck') == "Y") {
			var isPrimaryDevice = false;
			if(jsonlocationinfo.isprimary == "Y") {
				isPrimaryDevice = true;
			}
			
			if(!isPrimaryDevice) {
				alert(mobile_comm_getDic("msg_NotAllowedDevice"));
				//mobile_attendance_reloadConfirm(true);
				return false;
			}
		}
		
		if(jsonlocationinfo == undefined || jsonlocationinfo.lat == undefined || jsonlocationinfo.lon == undefined
				|| (jsonlocationinfo.lat == "0.0" && jsonlocationinfo.lon == "0.0")) {
			alert("좌표정보없음");
		}else{
			//지도호출
			AttendMobile.mapLoad(jsonlocationinfo.lon,jsonlocationinfo.lat);	
		}
	}catch(e) {
		mobile_comm_log(e);
	}
}
	

	


