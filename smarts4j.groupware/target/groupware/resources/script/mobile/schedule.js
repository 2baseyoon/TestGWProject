/*!
 * 
 * 

 * SmartS4j / MobileOffice / 모바일 일정 js 파일
 * 함수명 : mobile_schedule_...
 * 
 * 
 */

/*!
 * 
 * 페이지별 init 함수
 * 
 */


//일정 목록 - 월간보기 페이지
$(document).on('pageinit', '#schedule_month_page', function () {
	if($("#schedule_month_page").attr("IsLoad") != "Y"){
		$("#schedule_month_page").attr("IsLoad", "Y");
		setTimeout("mobile_schedule_MonthInit()", 10);
		mobile_schedule_bindTouch("schedule_month_content");
		if(mobile_comm_isAndroidApp()) {
			window.covimoapp.SetPullToRefresh(false);
		}		
	} else {
		mobile_schedule_bindTouch("schedule_month_content");
	}
});

//일정 목록 - 주간보기 페이지
$(document).on('pageinit', '#schedule_week_page', function () {
	if($("#schedule_week_page").attr("IsLoad") != "Y"){
		$("#schedule_week_page").attr("IsLoad", "Y");
		setTimeout("mobile_schedule_WeekInit()", 10);
		mobile_schedule_bindTouch("schedule_week_content");	
		if(mobile_comm_isAndroidApp()) {
			window.covimoapp.SetPullToRefresh(false);
		}	
	} else {
		mobile_schedule_bindTouch("schedule_week_content");
	}
});

//일정 목록 - 일간보기 페이지
$(document).on('pageinit', '#schedule_day_page', function () {
	if($("#schedule_day_page").attr("IsLoad") != "Y"){
		$("#schedule_day_page").attr("IsLoad", "Y");
		setTimeout("mobile_schedule_DayInit()", 10);
		mobile_schedule_bindTouch("schedule_day_content");	
		if(mobile_comm_isAndroidApp()) {
			window.covimoapp.SetPullToRefresh(false);
		}	
	} else {
		mobile_schedule_bindTouch("schedule_day_content");
	}
});

//일정 목록 - 목록보기 페이지
$(document).on('pageinit', '#schedule_list_page', function () {
	if($("#schedule_list_page").attr("IsLoad") != "Y"){
		$("#schedule_list_page").attr("IsLoad", "Y");
		setTimeout("mobile_schedule_ListInit()", 10);
		mobile_schedule_bindTouch("schedule_list_content");
		if(mobile_comm_isAndroidApp()) {
			window.covimoapp.SetPullToRefresh(false);
		}
	} else {
		mobile_schedule_bindTouch("schedule_list_content");
	}
});

//일정 작성 페이지
$(document).on('pageinit', '#schedule_write_page', function () {
	if($("#schedule_write_page").attr("IsLoad") != "Y"){
		$("#schedule_write_page").attr("IsLoad", "Y");
		setTimeout("mobile_schedule_WriteInit()", 10);	
	}
});

//일정 조회 페이지
$(document).on('pageinit', '#schedule_view_page', function () {
	_mobile_schedule_updatescheduleobj = {}
	if($("#schedule_view_page").attr("IsLoad") != "Y"){
		$("#schedule_view_page").attr("IsLoad", "Y");
		
		setTimeout("mobile_schedule_ViewInit()", 10);
		setTimeout("mobile_schedule_setModifyAllButton()", 100);
	}	
});

function mobile_schedule_setModifyAllButton(){
	if(mobile_comm_getQueryString('isrepeatall', "schedule_view_page") == "Y"){
		$("#schedule_view_modify").text(mobile_comm_getDic('lbl_schedule_modify_one'));
		$("#schedule_view_modify").closest('li').after(
			'<li><a id="schedule_view_modifyAll" data-schedule-scope="all" href="#" onclick="javascript: mobile_schedule_clickmodify(this);" class="btn">'+mobile_comm_getDic('lbl_schedule_modify_all')+'</li>'
		);
	}
}


/*!
 * 
 * 일정 공통
 * 
 */

var _mobile_schedule_common = {
	
	AclArray : {},				//권한 조회
	
	ViewType : 'M',				//뷰 타입 설정(월간/주간/일간)
	FolderCheckList : '',		//조회 폴더	
	CU_ID : '',					//커뮤니티 아이디
	IsCommunity : 'N',			//커뮤니티 일정 여부
	SearchText: '',				//검색 내용
	
	StartDate : 0,				//그리드 시작일
	EndDate : 1,				//그리드 종료일

	Year : '',					//그리드 년도
	Month : '', 				//그리드 월
	Day : '',					//그리드 일
		
	ArrSunday : new Array(),	//일요일 정보 담는 배열
	CurrentTime : new Date(CFN_GetLocalCurrentDate()),	//현재 시간
	
	IsWorkTime : 'N',			//업무시간 보기 여부	
	
	UseGoogle : 'N',			//구글일정 사용여부(회사)
	IsConnectGoogle : false,	//구글일정 사용여부(개인)
	CheckGoogle : false,		//구글일정 사용여부 체크 여부 (회사/개인)
	GoogleEmail : "",			//구글 이메일
	SelectDate : ""
};

//일간보기/주간보기 시 timeline 표시여부를 위해 추가
//날짜 또는 주 변경 시 ;로 초기화하기
var _mobile_schedule_time = ";";	//;1;3;4;12; 또는 ;202005271;2020.05.27.3;2020.05.27.4;2020.05.27.12;  

var schTouchX = 0;
var schTouchPosX = 0;
var schTouchDirection = "";
var schTouchMoveWidth = 0;
var isSchUpdate = false;
function mobile_schedule_bindTouch(pTargetID){
	$("#"+pTargetID).off("touchstart,touchmove,touchend")
	.on('touchstart', function(e) {    	 		     	 
		schTouchPosX = e.originalEvent.targetTouches[0].pageX;
		schTouchX = 0;
		if(mobile_comm_isAndroidApp()) {
			window.covimoapp.SetPullToRefresh(false);
		}
	})
	.on('touchmove', function(e) {         	 
		schTouchX = e.originalEvent.targetTouches[0].pageX;
		schTouchDirection = "Right";
		mobile_comm_disablescroll();
		schTouchMoveWidth = parseInt(schTouchPosX - schTouchX);
		if(schTouchMoveWidth < 0) {
			schTouchDirection = "Left";
		}
		if(parseInt(schTouchMoveWidth) > parseInt(winW/2)){
			schTouchMoveWidth = parseInt(winW/2);
		}
		$("#sSlide_bar").css("margin-left", -(parseInt(schTouchMoveWidth)));
	})
	.on('touchend', function(e) {    	 
	 var left = parseInt(schTouchPosX - schTouchX);
	 var width = parseInt($("body").width())*0.3;
	 if(schTouchX != 0) {
		 if(left < 0 ){
			if (-left >= width) {
				mobile_schedule_ShowPrevNextCalendar('prev');
			 } 
		 }else{
			if (left >= width) {
				mobile_schedule_ShowPrevNextCalendar('next');
			 }
		 }
	 } 
	 $("#sSlide_bar").css("margin-left","");
	 mobile_comm_enablescroll();
	});
}

//TODO : mobile_schedule_GetCurrDate() =>공통화
//초기화 및 파라미터 세팅
//pIsRefresh => 리스트 화면에서 "오늘" 클릭  시, url에 searchtext가 있으면 계속 검색화면으로 초기화되는 것을 방지하기 위함 
function mobile_schedule_InitJS(pIsRefresh){
	
	_mobile_schedule_common.StartDate = mobile_schedule_SetDateFormat(_mobile_schedule_common.CurrentTime, '.');
	
	_mobile_schedule_common.ViewType = mobile_comm_getQueryString("viewtype");
	_mobile_schedule_common.StartDate = mobile_comm_getQueryString("startdate");
	_mobile_schedule_common.EndDate = mobile_comm_getQueryString("enddate");
	
	if((pIsRefresh != undefined && pIsRefresh == "Y") || (mobile_comm_getQueryString("searchtext") == "undefined" || mobile_comm_getQueryString("searchtext") == null)){
		_mobile_schedule_common.SearchText = null;
	} else {
		_mobile_schedule_common.SearchText = decodeURIComponent(mobile_comm_getQueryString("searchtext"));
	}
	if(_mobile_schedule_common.StartDate == "undefined" || _mobile_schedule_common.StartDate == "" || _mobile_schedule_common.StartDate == null){
		_mobile_schedule_common.StartDate = mobile_schedule_GetCurrDate(".");
	}
	if(_mobile_schedule_common.ViewType == "undefined" || _mobile_schedule_common.ViewType == "" || _mobile_schedule_common.ViewType == null){
		_mobile_schedule_common.ViewType = "M";
	}
	//일정 폴더 선택값
	if(mobile_comm_getQueryString('cuid') != 'undefined' && mobile_comm_getQueryString('schfd') != 'undefined'){
		_mobile_schedule_common.CU_ID = mobile_comm_getQueryString('cuid') ;
		_mobile_schedule_common.FolderCheckList = ";" + mobile_comm_getQueryString('schfd') + ";";
		_mobile_schedule_common.IsCommunity = "Y";
	} else if(localStorage.getItem("ScheduleCheckBox_"+mobile_comm_getSession("UR_Code").toLowerCase()) != null){
		_mobile_schedule_common.CU_ID = "";
		_mobile_schedule_common.FolderCheckList = localStorage.getItem("ScheduleCheckBox_"+mobile_comm_getSession("UR_Code").toLowerCase());
		_mobile_schedule_common.IsCommunity = "N";
	} else {
		_mobile_schedule_common.FolderCheckList = mobile_schedule_getSchUserFolderSetting();
	}
	
	_mobile_schedule_common.Year = _mobile_schedule_common.StartDate.split(".")[0];	
	_mobile_schedule_common.Month = _mobile_schedule_common.StartDate.split(".")[1];		
	_mobile_schedule_common.Day = _mobile_schedule_common.StartDate.split(".")[2];	
	
	//구글 일정 사용 여부 체크 
	mobile_schedule_chkUseGoogle();
}

//오늘날짜 구하기
function mobile_schedule_GetCurrDate(pSplitStr, pFormat) {  //pSplitStr: 년월일사이에 나타낼 구분문자
    var now = _mobile_schedule_common.CurrentTime;
    var year = now.getFullYear();
    var month = now.getMonth() + 1;
    var date = now.getDate();
    if (month < 10)  //월이 한자리수인 경우
        month = "0" + month;
    if (date < 10)   //일이 한자리수인 경우
        date = "0" + date;

    var currDate = "";
    if (pFormat == undefined) {
        currDate = year + pSplitStr + month + pSplitStr + date;   //예: 2009-10-02
    } else {
        if (pFormat == 'dot' || pFormat == 'dash' || pFormat == 'slash' || pFormat == 'enslash') {
            currDate = year + pSplitStr + month + pSplitStr + date;   //예: 2009-10-02
        } else {
            currDate = pFormat.replace("yyyy", year).replace("MM", month).replace("dd", date);
        }
    }
    return currDate;
}

//선택일자의 캘린더로 이동
function mobile_schedule_GoToSelectedDate(pDate){
	
	var sUrl = "";
	
	if(_mobile_schedule_common.ViewType == "D")
		_mobile_schedule_common.EndDate = _mobile_schedule_common.StartDate;
	else if(_mobile_schedule_common.ViewType == "W"){
		 var sun = mobile_schedule_GetSunday(new Date(mobile_schedule_ReplaceDate(_mobile_schedule_common.StartDate)));
		 _mobile_schedule_common.StartDate = mobile_schedule_SetDateFormat(sun, '.');
		 _mobile_schedule_common.EndDate = mobile_schedule_SetDateFormat(mobile_schedule_AddDays(_mobile_schedule_common.StartDate, 6), '.');
	}else if(_mobile_schedule_common.ViewType == "M" || _mobile_schedule_common.ViewType == "List"){
		_mobile_schedule_common.StartDate = mobile_schedule_SetDateFormat(new Date(_mobile_schedule_common.Year, (_mobile_schedule_common.Month - 1), 1), '.');
		_mobile_schedule_common.EndDate = mobile_schedule_SetDateFormat(new Date(_mobile_schedule_common.Year, _mobile_schedule_common.Month, 0), '.');
		sUrl = "/groupware/mobile/schedule/month.do?menucode=ScheduleMain";
		sUrl += "&viewtype=" + _mobile_schedule_common.ViewType;
		sUrl += "&startdate=" + _mobile_schedule_common.StartDate;
		if(_mobile_schedule_common.EndDate != undefined){
			sUrl += "&endDate=" + _mobile_schedule_common.EndDate;
		}
	}
	
	mobile_comm_go(sUrl);

}

// 상단 메뉴 - 달력 클릭 이벤트
function mobile_schedule_clickcalendar(){
	var sUrl = "/groupware/mobile/schedule/select.do";
	mobile_comm_go(sUrl);
}

//상단 메뉴 - 작성 클릭 이벤트
function mobile_schedule_clickwrite(){
	var sUrl = "/groupware/mobile/schedule/write.do";
	if(typeof(_mobile_schedule_common.SelectDate) == 'string' && _mobile_schedule_common.SelectDate != "") {
		sUrl += '?date=' + _mobile_schedule_common.SelectDate;
	}
	if(_mobile_schedule_common.IsCommunity == "Y"){
		sUrl += "?iscommunity=Y";
		sUrl += "&folderid=" + mobile_comm_replaceAll(_mobile_schedule_common.FolderCheckList, ";", "");
	}
	mobile_comm_go(sUrl, "Y");
}

//권한 처리된 일정 폴더 가져오기
function mobile_schedule_SetAclEventFolderData(){
	
	var url = "/groupware/mobile/schedule/getACLFolder.do";
	$.ajax({
	    url: url,
	    type: "POST",
	    data: {
	    	"isCommunity" : (_mobile_schedule_common.IsCommunity == "Y" ? true : false)
	    },
	    async: false,
	    success: function (res) {
	    	if(res.status == "SUCCESS"){
	    		_mobile_schedule_common.AclArray = res;
	    	}else{
	    		alert(mobile_comm_getDic("msg_apv_030"));		// 오류가 발생했습니다.
	    	}
        },
        error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
			alert(mobile_comm_getDic("msg_apv_030"));		// 오류가 발생했습니다.
		}
	});
}

//해당 달의 일요일 배열객체 생성
function mobile_schedule_MakeSunArray(selDate) {
var sun = [];
var firstSun = mobile_schedule_GetFirstSunOfMonth(selDate);
var strFirstSun = mobile_schedule_SetDateFormat(firstSun, '/');
var lastSun = mobile_schedule_GetLastSunOfMonth(selDate);
for (var i = 0; i < 6; i++) {
   var sDay = mobile_schedule_AddDays(strFirstSun, i * 7);
   sun.push(sDay);
   if (mobile_schedule_GetDiffDates(sDay, lastSun, 'day') == 0) {
       break;
   }
}
return sun;
}

//특정일이 속한 일요일
function mobile_schedule_GetSunday(d) {
	var day = d.getDay();
	var diff = d.getDate() - day;
	return new Date(mobile_schedule_ReplaceDate(d.setDate(diff)));
}

//해당 달의 첫번째 일요일 조회
function mobile_schedule_GetFirstSunOfMonth(selDate) {
  var arrSelDate = selDate.split('.');
  //이달의 첫째 날
  var firstDay = new Date(arrSelDate[0], Number(arrSelDate[1]) - 1, 1);
  //이달의 첫째 날의 일요일
  var firstSun = mobile_schedule_GetSunday(firstDay);
  return firstSun;
}

//해당 달의 마지막 일요일 조회
function mobile_schedule_GetLastSunOfMonth(selDate) {
  var arrSelDate = selDate.split('.');
  //이달의 첫째 날
  var strNextFirstDay = arrSelDate[0] + '/' + (Number(arrSelDate[1]) + 1) + '/' + 1;
  var lastDay = mobile_schedule_SubtractDays(strNextFirstDay, 1);
  var lastSun = mobile_schedule_GetSunday(lastDay);
  return lastSun;
}

//날짜 형식 바꿈
function mobile_schedule_ReplaceDate(dateStr) {

    var regexp = /\./g;

    if (typeof dateStr == "string") {
    	if (dateStr.indexOf("-") > -1) {
            regexp = /-/g;
        } else if (dateStr.indexOf(".") > -1) {
            regexp = /\./g;
        } else if (dateStr.indexOf("/") > -1) {
            regexp = /\//g;
        }
        
        return dateStr.replace(regexp, "/");
    } else {
        var tempDate = new Date(dateStr);
        
        dateStr = tempDate.getFullYear() + "/" + (tempDate.getMonth() + 1) + "/" + tempDate.getDate() + " " + mobile_comm_AddFrontZero(tempDate.getHours(), 2) + ":" + mobile_comm_AddFrontZero(tempDate.getMinutes(), 2);
        
        return dateStr;
    }
}

//날짜 포멧 변환
function mobile_schedule_SetDateFormat(pDate, pType) {
  var formattedDate = '';
  var date = new Date(mobile_schedule_ReplaceDate(pDate));
  var year = date.getFullYear();
  var month = date.getMonth() + 1;
  var day = date.getDate();
  if (month < 10) {
      month = '0' + month;
  }
  if (day < 10) {
      day = '0' + day;
  }

  switch (pType) {
      case '.': formattedDate = year + '.' + month + '.' + day;
          break;
      case '/': formattedDate = year + '/' + month + '/' + day;
          break;
      case '-': formattedDate = year + '-' + month + '-' + day;
          break;
      case '': formattedDate = year.toString() + month.toString() + day.toString();
          break;
  }
  return formattedDate;
}

//지정한 만큼 이전 일
function mobile_schedule_SubtractDays(strDate, days) {
  var date = new Date(mobile_schedule_ReplaceDate(strDate));
  var d = date.getDate() - days;
  date.setDate(d);
  return date;
}

//지정한 만큼 이후 일
function mobile_schedule_AddDays(strDate, days) {
  var date = new Date(mobile_schedule_ReplaceDate(strDate));
  var d = date.getDate() + days;
  date.setDate(d);
  return date;
}

//날짜 비교
function mobile_schedule_GetDiffDates(date1, date2, type) {
  //날짜 비교
  var ret = '';
  //소수점 발생
  var num_days = ((((date2 - date1) / 1000) / 60) / 60) / 24;
  var num_hours = ((((date2 - date1) / 1000) / 60) / 60);
  var num_minutes = (((date2 - date1) / 1000) / 60);

  switch (type) {
      case 'day': ret = num_days;
          break;
      case 'hour': ret = num_hours;
          break;
      case 'min': ret = num_minutes;
          break;
  }

  return ret;
}  

//랜덤 Color 제조기
function mobile_schedule_RandomColor(format) {
	var rint = Math.round(0xffffff * mobile_comm_random());
	switch (format) {
		case 'hex':
			return ('#0' + rint.toString(16)).replace(/^#0([0-9a-f]{6})$/i, '#$1');
			break;
		case 'rgb':
			return 'rgb(' + (rint >> 16) + ',' + (rint >> 8 & 255) + ',' + (rint & 255) + ')';
			break;
		default:
			return rint;
			break;
	}
}

// .형식의 날짜 반환
function mobile_schedule_MakeDateForCompare(date, time) {
    try {
        var arrDate;
        var arrTime;
        if (date.indexOf('-') > -1) {
            arrDate = date.split('-');
        } else {
            arrDate = date.split('.');
        }
        arrTime = time.split(':');
        var retDate = new Date(Number(arrDate[0]), Number(arrDate[1]) - 1, Number(arrDate[2]), Number(arrTime[0]), Number(arrTime[1]));
        return retDate;
    }  catch (e) {mobile_comm_log(e); }
}

//월별 이벤트 데이터 가져오기(월간/주간/일간/목록에서 사용)
function mobile_schedule_GetMonthEventData(sDate, eDate){

	$("#mobile_schedule_topmenu li[viewtype=" + _mobile_schedule_common.ViewType + "] a").addClass("selected");

	var folderIDs = _mobile_schedule_common.FolderCheckList;				// 좌측 메뉴 체크 항목
	var importanceState = "";
	var url = "/groupware/mobile/schedule/getView.do";
	
	$.ajax({
	    url: url,
	    type: "POST",
	    async: false,
	    data: {
	    	"FolderIDs": folderIDs,
	    	"StartDate": CFN_TransServerTime(sDate.replaceAll(".", "-") + ' 00:00'),
			"EndDate": CFN_TransServerTime(mobile_schedule_SetDateFormat(mobile_schedule_AddDays(eDate.replaceAll(".", "-"), 1),'-') + ' 00:00'),
	    	"UserCode": mobile_comm_getSession("UR_Code"),
	    	"lang": lang,
	    	"ImportanceState": importanceState
		},
	    success: function (res) {
	    	
	    	if(res.status == "SUCCESS"){
	    		var resList = res.list;

				$.each(resList, function(idx, el){
					el.StartDateTime = CFN_TransLocalTime(el.StartDateTime, 'yyyy-MM-dd HH:mm');
					el.StartDate = el.StartDateTime.split(' ')[0];
					el.StartTime = el.StartDateTime.split(' ')[1];
					el.EndDateTime = CFN_TransLocalTime(el.EndDateTime, 'yyyy-MM-dd HH:mm');
					el.EndDate = el.EndDateTime.split(' ')[0];
					el.EndTime = el.EndDateTime.split(' ')[1];
				});
	    		
	  			// FolderID에 구글 계정 연동 Folder가 체크되었을 경우
	  			if(_mobile_schedule_common.FolderCheckList.indexOf(";"+mobile_comm_getBaseConfig("ScheduleGoogleFolderID", 0) + ";") > -1){
	  				if(mobile_schedule_GetGoogleEventList(sDate, eDate) != undefined)
	  					resList = resList.concat(mobile_schedule_GetGoogleEventList(sDate, eDate));
	  			}
		    		
	    		if(resList.length > 0){
	    			if(_mobile_schedule_common.ViewType == "M"){
	    				mobile_schedule_SetMonthEventData(resList);
	    			}
	    			else if(_mobile_schedule_common.ViewType == "ML" || _mobile_schedule_common.ViewType == "L"){
	    				mobile_schedule_SetMonthEventDataList(resList);
	    			}
	    			else if(_mobile_schedule_common.ViewType == "W"){
	    				mobile_schedule_SetWeekEventData(resList, sDate, eDate);
	    			}
	    			else if(_mobile_schedule_common.ViewType == "D"){
	    				mobile_schedule_SetDayEventData(resList, sDate, eDate);
	    			}
	    		}
	    		else{
	    			mobile_schedule_SetMonthEventDataList();
	    		}
	    	} else {
				alert(mobile_comm_getDic("msg_apv_030"));		// 오류가 발생했습니다.
			}
	    },
	    error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
			alert(mobile_comm_getDic("msg_apv_030"));		// 오류가 발생했습니다.
		}
	});
}

//TODO 보완..
//몇 번째 주인지 가져오기
function mobile_schedule_getWeekNum(pDate){
	 var oDate = new Date(pDate);
	 return Math.ceil(oDate.getDate() / 7);
}

//업무시간 보기 클릭
function mobile_schedule_clickworktime(){
	
	//버튼 CSS 및 IsWorkTime 변수 값 세팅
	if($(".chk_work_time").hasClass("active")){
		$(".chk_work_time").removeClass("active");
		_mobile_schedule_common.IsWorkTime = "N";
	} else {
		$(".chk_work_time").addClass("active");
		_mobile_schedule_common.IsWorkTime = "Y";
	}
	
	//달력 다시 그림
	if(_mobile_schedule_common.ViewType == "W"){
		mobile_schedule_MakeWeekCalendar();
	} else {
		mobile_schedule_MakeDayCalendar();
	}
}

//이전/다음 달력 보기
function mobile_schedule_ShowPrevNextCalendar(pType){
	
	if(_mobile_schedule_common.ViewType == "M" || _mobile_schedule_common.ViewType == "L" ){
		
		//다음/이전달 값 세팅
		if(pType == "next"){
			if(_mobile_schedule_common.Month == 12){
				_mobile_schedule_common.Year = Number(_mobile_schedule_common.Year) + 1;
				_mobile_schedule_common.Month = 1;
		    } else {
		    	_mobile_schedule_common.Month = Number(_mobile_schedule_common.Month) + 1;
		    }
		} else if(pType == "prev"){
			if(_mobile_schedule_common.Month == 1){
				_mobile_schedule_common.Year = Number(_mobile_schedule_common.Year) - 1;
				_mobile_schedule_common.Month = 12;
		    } else {
		    	_mobile_schedule_common.Month = Number(_mobile_schedule_common.Month) - 1;
		    }
		}
	
		var nextMonthDate = "";
		if(_mobile_schedule_common.Month == 12){
			nextMonthDate = (Number(_mobile_schedule_common.Year) + 1) + "/01/01";
	    } else {
	    	nextMonthDate = _mobile_schedule_common.Year + "/" + (Number(_mobile_schedule_common.Month) + 1) + "/01";
	    }
		_mobile_schedule_common.StartDate = _mobile_schedule_common.Year + "." + mobile_comm_AddFrontZero(_mobile_schedule_common.Month, 2) + "." + "01";
		_mobile_schedule_common.EndDate = mobile_schedule_SetDateFormat(mobile_schedule_SubtractDays(nextMonthDate, 1), ".");

		if(_mobile_schedule_common.ViewType == "M"){
			//월간보기 캘린더 영역
			mobile_schedule_MakeMonthCalendar();
			//월간보기 리스트 영역
			mobile_schedule_MakeMonthList();
		} else {
			//목록보기 리스트 영역
			mobile_schedule_MakeList();
		}
		
	}
	else if(_mobile_schedule_common.ViewType == "W"){
		
		//다음/이전주 값 세팅
		if(pType == "next"){
			_mobile_schedule_common.StartDate = mobile_schedule_SetDateFormat(mobile_schedule_AddDays(_mobile_schedule_common.StartDate, 7), '.');
		} else if(pType == "prev"){
			_mobile_schedule_common.StartDate = mobile_schedule_SetDateFormat(mobile_schedule_AddDays(_mobile_schedule_common.StartDate, -7), '.');
		}

		_mobile_schedule_common.Year = _mobile_schedule_common.StartDate.split(".")[0];	
		_mobile_schedule_common.Month = _mobile_schedule_common.StartDate.split(".")[1];		
		_mobile_schedule_common.Day = _mobile_schedule_common.StartDate.split(".")[2];	
	
		//주간보기 캘린더 영역
		mobile_schedule_MakeWeekCalendar();
	}
	else if(_mobile_schedule_common.ViewType == "D"){
		
		//다음/이전일 값 세팅
		if(pType == "next"){
			_mobile_schedule_common.StartDate = mobile_schedule_SetDateFormat(mobile_schedule_AddDays(_mobile_schedule_common.StartDate, 1), '.');
		} else if(pType == "prev"){
			_mobile_schedule_common.StartDate = mobile_schedule_SetDateFormat(mobile_schedule_AddDays(_mobile_schedule_common.StartDate, -1), '.');
		}

		_mobile_schedule_common.Year = _mobile_schedule_common.StartDate.split(".")[0];	
		_mobile_schedule_common.Month = _mobile_schedule_common.StartDate.split(".")[1];		
		_mobile_schedule_common.Day = _mobile_schedule_common.StartDate.split(".")[2];	
	
		//일간보기 캘린더 영역
		mobile_schedule_MakeDayCalendar();
	}
	
}

//새일정 표시 또는 작성 페이지 연결
function mobile_schedule_clickHour(pDate, pTime){
	if($("td[date='" + pDate + "'][time='" + pTime + "']").find("a").hasClass("active")){
		mobile_comm_go('/groupware/mobile/schedule/write.do?'+(_mobile_schedule_common.IsCommunity == "Y" ? 'iscommunity=Y&' : '')+'date=' + pDate + '&time=' + pTime);
	} else {
		
		if($("td[id^='schedule_" + ((_mobile_schedule_common.ViewType == "W") ? "week" : "day") + "_td'] a.active").length > 0) {
			var active = $("td[id^='schedule_" + ((_mobile_schedule_common.ViewType == "W") ? "week" : "day") + "_td'] a.active");
			active.removeClass("active");
			if(active.parent().prop('tagName').toUpperCase() == "LI") {
				active.parent().css('left', '90%').css('width', '10%');	//li 너비 변경;
			}
		}
		
		var add = $("td[date='" + pDate + "'][time='" + pTime + "']").find("a").last();
		if(add.parent().prop('tagName').toUpperCase() == "LI") {
			add.parent().css('left', '0%').css('width', '100%');	//li 너비 변경
		}
		
		if(_mobile_schedule_common.ViewType == "D") {
			if(("td[id^='schedule_day_td'] i")) {
				$("td[id^='schedule_day_td'] i").parent().html("");//a태그 제거
			}
			add.html("<i class=\"ico_cell_add\"></i>" + mobile_comm_getDic("lbl_schedule_newSchedule")); //새 일정
		}
		add.addClass("active");
	}
}

//검색 버튼 클릭
function mobile_schedule_clicksearch(pListYN){
	var selDate, tempYear, tempMonth, nextMonthDate, startdate, enddate;
	
	if(selDate == undefined){
		selDate = _mobile_schedule_common.StartDate;
	}
	
	tempYear = selDate.split('.')[0];
	tempMonth = selDate.split('.')[1];
	
	if(tempMonth == 12){
		nextMonthDate = (Number(tempYear) + 1) + "/01/01";
    } else {
    	nextMonthDate = tempYear + "/" + (Number(tempMonth) + 1) + "/01";
    }
	
	var sUrl = "/groupware/mobile/schedule/list.do?viewtype=L";
	sUrl += "&searchtext=" + $("#mobile_search_input").val();

	//pListYN > 목록보기에서 검색여부
	if(pListYN == 'Y') {
		_mobile_schedule_common.SearchText = $("#mobile_search_input").val();
		_mobile_schedule_common.ViewType = "L";
		
		startdate = $("#schedule_list_datetitle").text() + ".01";
		enddate = mobile_schedule_SetDateFormat(mobile_schedule_SubtractDays(nextMonthDate, 1), '.');
	} else {
		if(mobile_comm_getQueryString("viewtype") == "D"){
			startdate = $("#schedule_day_titleDate").text();
			var nextdate = new Date(new Date(startdate).setDate(new Date(startdate).getDate()+1));
			var endmonth = nextdate.getMonth()+1 <10 ? '0'+(nextdate.getMonth()+1) : nextdate.getMonth()+1;
			var endday = nextdate.getDate() < 10 ? '0'+ nextdate.getDate() : nextdate.getDate();
			enddate = nextdate.getFullYear() +'.' + endmonth + '.' + endday;
		} else if (mobile_comm_getQueryString("viewtype") == "W"){
			startdate = $("#schedule_week_calendarheader .sun").attr('date');
			enddate = $("#schedule_week_calendarheader .sat").attr('date');
		} else if (mobile_comm_getQueryString("viewtype") == "M"){
			startdate = $("#schedule_month_calendar table.calendar tbody tr[id^=tableWeekScheduleForMonth]:first td:first").attr("schday");
			enddate = $("#schedule_month_calendar table.calendar tbody tr[id^=tableWeekScheduleForMonth]:last td:last").attr("schday");
		}
	}
	sUrl += "&startdate=" + startdate + "&enddate=" + enddate;
	sUrl += (mobile_comm_getQueryString('cuid') != 'undefined') ? '&cuid=' + mobile_comm_getQueryString('cuid') : '';
	sUrl += (mobile_comm_getQueryString('schfd') != 'undefined') ? '&schfd=' + mobile_comm_getQueryString('schfd') : '';
	
	mobile_comm_go(sUrl);	
}

//이전 페이지 재로드
function mobile_schedule_reloadPrevPage(){
	if(_mobile_schedule_common.ViewType == "M"){
		mobile_schedule_MonthInit();
	} else if(_mobile_schedule_common.ViewType == "W"){
		mobile_schedule_WeekInit();
	} else if(_mobile_schedule_common.ViewType == "D"){
		mobile_schedule_DayInit();
	} else {
		mobile_schedule_ListInit();
	}
}

//커뮤니티의 경우, 별도의 display 세팅 필요
function mobile_schedule_setCommunityTopMenu(params){
	if(params.IsCommunity == "Y"){
		$("#mobile_schedule_topmenu").html(mobile_community_makeHomeTreeList(params));
		$("#mobile_schedule_topmenu").removeClass();
		$("#mobile_schedule_topmenu").addClass("h_tree_menu_wrap");
		$("#mobile_schedule_topmenu").addClass("comm_menu");
		
		$("div.utill a.btn_calendar").hide();
	}
}

//UI 이벤트 처리
function mobile_schedule_clickUiSetting(pObj, pClass){
	if($(pObj).hasClass(pClass)) {
		$(pObj).removeClass(pClass);
		if($(pObj).parent().attr("adata") == "active") {
			$(pObj).parent().removeClass("active");
		}
		
		if($(pObj).attr("adata") != undefined && $(pObj).attr("adata") != ""){
			$("#"+$(pObj).attr("adata")).click(); 
		}
		
	} else {
		$(pObj).addClass(pClass);
		if($(pObj).parent().attr("adata") == "active") {
			$(pObj).parent().addClass("active");
		}
		
		if($(pObj).attr("adata") != undefined && $(pObj).attr("adata") != ""){
			$("#"+$(pObj).attr("adata")).click(); 
		}
	}
}

//확장메뉴 show or hide
function mobile_schedule_showORhide(obj, mode) {
	if(mode != undefined && mode == "self") {
		if($(obj).hasClass("show")) {
			$(obj).removeClass("show");
		} else {
			$(obj).addClass("show");
		}
	} else {
		if($(obj).parent().hasClass("show")) {
			$(obj).parent().removeClass("show");
		} else {
			$(obj).parent().addClass("show");
		}
	}
}

//view 페이지 이동
function mobile_schedule_changeCalendar(pType){
	var cuid = _mobile_schedule_common.CU_ID;
	var schfd = mobile_comm_replaceAll(_mobile_schedule_common.FolderCheckList,";", "");
	
	if(_mobile_schedule_common.ViewType == pType){
		mobile_schedule_realoadPage();
		mobile_comm_TopMenuClick('mobile_schedule_topmenu',true);
		return false;
	}
		
    var sUrl = "";
     
    switch(pType){
    case "M" : sUrl += "/groupware/mobile/schedule/month.do";
    break;
    case "W" : sUrl += "/groupware/mobile/schedule/week.do";
    break; 
    case "D" : sUrl += "/groupware/mobile/schedule/day.do";
    break; 
    case "L" : sUrl += "/groupware/mobile/schedule/list.do";
    break; 
    }
	
	if(_mobile_schedule_common.CU_ID != ""){
		sUrl += "?viewtype=" + pType + "&cuid=" + cuid + "&schfd=" + schfd;
	}else{
		sUrl += "?viewtype=" + pType;
	}
    
    mobile_comm_go(sUrl);
    $('.bg_dim').hide();
    $(".menu_link").removeClass("show");
}

//사용자 일정 폴더 선택 값 조회 및 로컬스토리지에 저장
function mobile_schedule_getSchUserFolderSetting(){
	
	var strUserFD = '';
	var url = "/groupware/mobile/schedule/getSchUserFolderSetting.do";
	$.ajax({
	    url: url,
	    type: "POST",
	    async: false,
	    data: {
	    	"UserCode" : mobile_comm_getSession("UR_Code")
	    },
	    success: function (res) {
	    	if(res.status == "SUCCESS"){
	    		if(res.data.isSchUserFDExist) {
	    			strUserFD = res.data.schUserFD;	    
		    		localStorage.setItem("ScheduleCheckBox_"+mobile_comm_getSession("UR_Code").toLowerCase(), strUserFD);
	    		} else {
	    			strUserFD = mobile_comm_getBaseConfig('ScheduleDefaultFolder') != undefined && mobile_comm_getBaseConfig('ScheduleDefaultFolder') != "" ? 
	    					mobile_comm_getBaseConfig('ScheduleDefaultFolder') : mobile_comm_getBaseConfig('ScheduleDefaultFolder', 0);
	    		}
	    	}else{
	    		alert(mobile_comm_getDic("msg_apv_030"));		// 오류가 발생했습니다.
	    	}
        },
        error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
			//alert("ERROR");
		}
	});
	
	return strUserFD;
}

//구글일정 사용여부 체크(회사 -> 개인) 
function mobile_schedule_chkUseGoogle() {
	
	//saas는 회사설정, 제품기본은 기초설정 체크
	
	//구글일정 사용여부 체크 안했으면 체크하고 jsinit 호출
	if(!_mobile_schedule_common.CheckGoogle) {
		
		//saas 면
		if(mobile_comm_getGlobalProperties("isSaaS") == "Y") {
			var domainID = mobile_comm_getSession("DN_ID");
			$.ajax({
				type:"POST",
				url:"/covicore/domain/get.do",
				data:{ "DomainID" : domainID },
				async: false,
				success:function (data) {
					var isUseGoogleSchedule = data.list[0].IsUseGoogleSchedule;
					if(isUseGoogleSchedule == "Y") {
						mobile_schedule_initGoogleJS();
					} else {
						_mobile_schedule_common.CheckGoogle = true;
					}
				},
				error: function(response, status, error) {
				     mobile_comm_ajaxerror("/covicore/domain/get.do", response, status, error);
				}
			});
		} else {	//saas가 아니면
			if(mobile_comm_getBaseConfig("UseGoogleSchedule") == "Y") {
				mobile_schedule_initGoogleJS();
			} else {
				_mobile_schedule_common.CheckGoogle = true;
			}
		}
	}
}

//구글 일정 사용 여부 체크(개인)
function mobile_schedule_initGoogleJS() {
	
	var url = "/groupware/schedule/checkIsConnectGoogle.do";
	$.ajax({
	    url: url,
	    type: "POST",
	    async: false,
	    data: {
	    	"UserCode" : mobile_comm_getSession("UR_Code")
	    },
	    success: function (res) {
	    	if(res.status == "SUCCESS") {
	    		_mobile_schedule_common.IsConnectGoogle = res.data.isConnect;
	    		_mobile_schedule_common.GoogleEmail = res.data.Mail;
	    	} else {
	    		alert(mobile_comm_getDic("msg_apv_030"));		// 오류가 발생했습니다.
	    	}

			_mobile_schedule_common.CheckGoogle = true;
        },
        error:function(response, status, error) {
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
}





//일정 공통 끝










/*!
 * 
 * 일정 월간보기
 * 
 */

//월간보기 페이지 초기화
function mobile_schedule_MonthInit(){
	
	if(window.sessionStorage["schedule_writeinit"] == "Y")
		window.sessionStorage.removeItem('schedule_writeinit');
	
	_mobile_schedule_common.SelectDate = "";
	
	//초기화 및 파라미터 세팅
	mobile_schedule_InitJS();
	
	//상단바 세팅
	mobile_schedule_setCommunityTopMenu(_mobile_schedule_common);
		
	//월간보기 캘린더 영역
	mobile_schedule_MakeMonthCalendar();
	
	//월간보기 리스트 영역
	mobile_schedule_MakeMonthList();
	
	mobile_schedule_SetScheduleFolderList();
}

//월 달력 그리기
function mobile_schedule_MakeMonthCalendar(){
	
	// 상단 제목 날짜 표시
	$('#schedule_month_datetitle').html(_mobile_schedule_common.Year + "." + mobile_comm_AddFrontZero(_mobile_schedule_common.Month, 2));
	
	_mobile_schedule_common.ArrSunday = mobile_schedule_MakeSunArray(_mobile_schedule_common.StartDate);
	var firstDay = new Date(_mobile_schedule_common.Year, _mobile_schedule_common.Month - 1, 1);
	var strNextYear = _mobile_schedule_common.Year;
    var strNextMonth = Number(_mobile_schedule_common.Month) + 1;
    
    // 12월일 경우 다음해 1월로. chrome에서 오류로 인해 추가
    if(_mobile_schedule_common.Month == 12){
    	strNextYear = Number(_mobile_schedule_common.Year)+1;
    	strNextMonth = 1;
    }
    
    var lastDay = mobile_schedule_SubtractDays(strNextYear + '/' + strNextMonth + '/' + 1, 1);
    
    // 월간 달력 그리기(달력의 바닥을 그림)
    var backHTML = '';
    
    // 달력 상단
    backHTML += '<div class="tb_calendar">';
    backHTML += '<table class="calendar">';
    backHTML += '<thead>';
    backHTML += '<tr>';
    backHTML += '<th class="sun">SUN</th>';
    backHTML += '<th>MON</th>';
    backHTML += '<th>TUE</th>';
    backHTML += '<th>WED</th>';
    backHTML += '<th>THU</th>';
    backHTML += '<th>FRI</th>';
    backHTML += '<th>SAT</th>';
    backHTML += '</tr>';
    backHTML += '</thead>';
    
    // 컨텐츠
	backHTML += '<tbody>';
    
    for (var i = 0; i < _mobile_schedule_common.ArrSunday.length; i++) {
    	backHTML += mobile_schedule_MakeWeekCalendarForMonth(_mobile_schedule_common.ArrSunday[i], firstDay, lastDay, i);
    }
    backHTML += '</tbody>';
    backHTML += '</table>';
    backHTML += '</div>';
    
    $("#schedule_month_calendar").html(backHTML);
    
    // 오늘 날짜 표시
    var todayDateStr = mobile_schedule_SetDateFormat(_mobile_schedule_common.CurrentTime, '.');
    $("td[schday='"+todayDateStr+"']").addClass("today");
    
    var sDate = mobile_schedule_SetDateFormat(_mobile_schedule_common.ArrSunday[0], '-');
	var eDate = mobile_schedule_SetDateFormat(mobile_schedule_AddDays(_mobile_schedule_common.ArrSunday[_mobile_schedule_common.ArrSunday.length-1], 6), '-');
	
	//해당 달의 이벤트를 가져옴
	mobile_schedule_GetMonthEventData(sDate, eDate);
}

//월간 달력 중 주간 영역 그리기
function mobile_schedule_MakeWeekCalendarForMonth(sunday, firstDay, lastDay, index) {
    var returnHTML = "";
    
    var strSun = mobile_schedule_SetDateFormat(sunday, '/');
    var g_sun = sunday;
    var g_mon = mobile_schedule_AddDays(strSun, 1);
    var g_tue = mobile_schedule_AddDays(strSun, 2);
    var g_wed = mobile_schedule_AddDays(strSun, 3);
    var g_thr = mobile_schedule_AddDays(strSun, 4);
    var g_fri = mobile_schedule_AddDays(strSun, 5);
    var g_sat = mobile_schedule_AddDays(strSun, 6);
    var l_arrDays = [g_sun, g_mon, g_tue, g_wed, g_thr, g_fri, g_sat];
    
    //내용
    returnHTML += '<tr id="tableWeekScheduleForMonth_'+mobile_schedule_SetDateFormat(g_sun, "")+'">';

    //날짜정보
    for (var i = 0; i < l_arrDays.length; i++) {
        if(l_arrDays[i].getDate() == g_sun){
        	returnHTML += '<td class="sun">';
        	returnHTML += '		<a href="javascript: mobile_schedule_ShowScheduleMonthList(\'' + mobile_schedule_SetDateFormat(l_arrDays[i].toDateString(), "-") + '\')" class="ui-link">';
        	returnHTML += '			<span>' + l_arrDays[i].getDate() + '</span>';
        	returnHTML += '		</a>';
        	returnHTML += '</td>';
        }else{
        	if ((mobile_schedule_GetDiffDates(firstDay, l_arrDays[i], 'day') >= 0) && (mobile_schedule_GetDiffDates(lastDay, l_arrDays[i], 'day') <= 0)) {
            	returnHTML += '<td schday="'+mobile_schedule_SetDateFormat(l_arrDays[i], '.')+'">';
            	returnHTML += '		<a href="javascript: mobile_schedule_ShowScheduleMonthList(\'' + mobile_schedule_SetDateFormat(l_arrDays[i].toDateString(), "-") + '\')" class="ui-link">';
            	returnHTML += '			<span>' + l_arrDays[i].getDate() + '</span>';
            	returnHTML += '		</a>';
            	returnHTML += '</td>';
            } else {
            	returnHTML += '<td class="dim" schday="'+mobile_schedule_SetDateFormat(l_arrDays[i], '.')+'">';
            	returnHTML += '		<a href="javascript: mobile_schedule_ShowScheduleMonthList(\'' +mobile_schedule_SetDateFormat(l_arrDays[i].toDateString(), "-") + '\')" class="ui-link">';
            	returnHTML += '			<span>' + l_arrDays[i].getDate() + '</span>';
            	returnHTML += '		</a>';
            	returnHTML += '</td>';
            }
        }
        
    }
    
    returnHTML += ('<tr>');
    returnHTML += ('</tr>');
    
    return returnHTML;
}

//월별 캘린더 하단의 리스트를 그림
function mobile_schedule_MakeMonthList(selDate){
	if(selDate == undefined){
		selDate = mobile_comm_replaceAll(_mobile_schedule_common.StartDate, '.', '-');
	}
	
	_mobile_schedule_common.ViewType = "ML";
	mobile_schedule_GetMonthEventData(selDate, selDate);
	_mobile_schedule_common.ViewType = "M";
}
    
//구글 캘린더 리스트 - 데이터 가져오기
function mobile_schedule_GetGoogleEventList(sDate, eDate){

	var returnVal;
	var timeZoneNum = mobile_comm_AddFrontZero(new Date().getTimezoneOffset() / -60, 2) + ":00";
	var checkPlus = new Date().getTimezoneOffset() >= 0 ? "-" : "+";
	
	sDate = encodeURIComponent(mobile_comm_getDateTimeString('yyyy-MM-ddT00:00:00', new Date(mobile_schedule_ReplaceDate(sDate))) + (checkPlus+timeZoneNum));
	eDate = encodeURIComponent(mobile_comm_getDateTimeString('yyyy-MM-ddT00:00:00', new Date(mobile_schedule_AddDays(eDate, 1))) + (checkPlus+timeZoneNum));
	
	var url ="/covicore/oauth2/client/callGoogleRestAPI.do";
	var params = {
			"orderBy" : "startTime",
			"showDeleted" : false,
			"singleEvents" : true,
			"timeMax" : eDate,
			"timeMin" : sDate
	};
	
	$.ajax({
	    url: url,
	    type: "POST",
	    async : false,
	    data: {
	    	"url" : "https://www.googleapis.com/calendar/v3/calendars/primary/events",
	    	"type" : "GET",
	    	"userCode" : mobile_comm_getSession("USERID"),
	    	"params" : JSON.stringify(params)
	    },
	    success: function (res) {
	    	if(res.status == "200"){
	    		returnVal = mobile_schedule_CoverGoogleEventListData(res.data);
	    	}else{
	    		alert(mobile_comm_getDic("msg_apv_030"));		// 오류가 발생했습니다.
	    	}
        },
        error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
	
	return returnVal;
}

//구글 캘린더 리스트 - 데이터 조작 후 그리기
function mobile_schedule_CoverGoogleEventListData(data){
	if(data.items.length > 0){
		var eventArr = data.items;
		var resultArr = new Array();
		
		$(eventArr).each(function(){
			var eventObj = {};
			
			eventObj.EventID = this.id;
			eventObj.DateID = this.id;
			eventObj.ImportanceState = "N";		//구글에는 중요여부 없음
			eventObj.Subject = this.summary == undefined ? "("+mobile_comm_getDic("lbl_NoSubject")+")" : this.summary;
			
			eventObj.IsAllDay = this.start.date == undefined ? "N" : "Y";
			
			var start_date = "";
			var end_date = "";
			if(eventObj.IsAllDay == "N"){
				start_date = this.start.dateTime;
				end_date = this.end.dateTime;
			}else{
				start_date = this.start.date;
				end_date = mobile_schedule_SetDateFormat(mobile_schedule_AddDays(this.end.date, -1), "-");
			}
			eventObj.StartDate = mobile_schedule_SetDateFormat(new Date(start_date), "-");
			eventObj.EndDate = mobile_schedule_SetDateFormat(new Date(end_date), "-");
			
			if(eventObj.IsAllDay == "N"){
				eventObj.StartTime = mobile_comm_AddFrontZero(new Date(start_date).getHours(), 2)+":"+mobile_comm_AddFrontZero(new Date(start_date).getMinutes(), 2);
				eventObj.EndTime = mobile_comm_AddFrontZero(new Date(end_date).getHours(), 2)+":"+mobile_comm_AddFrontZero(new Date(end_date).getMinutes(), 2);
			}else{
				eventObj.StartTime = "00:00";
				eventObj.EndTime = "23:59";
			}
			eventObj.StartDateTime = eventObj.StartDate + " " + eventObj.StartTime;
			eventObj.EndDateTime = eventObj.EndDate + " " + eventObj.EndTime;
			
			eventObj.IsRepeat = this.recurringEventId == undefined ? "N" : "Y";
			
			eventObj.Place = this.location == undefined ? "" : this.location;
			
			eventObj.Color = "#ac725e";			//TODO
			eventObj.FolderID = mobile_comm_getBaseConfig("ScheduleGoogleFolderID", 0);
			
			resultArr.push(eventObj);
		});
	}
	return resultArr;
}

//월간보기 - 데이터 조작 후 그리기
function mobile_schedule_SetMonthEventData(eventData){
	// 주별로 데이터 분리
	var eventArr = new Array();
	var eventObj = new Array();
	var weekDateArr = {};
	
	$(_mobile_schedule_common.ArrSunday).each(function(i, val){
		eventObj = new Array();
		var sDate = val;
		var eDate = mobile_schedule_AddDays(val, 6);
		
		$(eventData).each(function(j){
			var isInclude = false;
			var dataStartDate = new Date(this.StartDate.split("-")[0], Number(this.StartDate.split("-")[1])-1, this.StartDate.split("-")[2]);
			var dataEndData = new Date(this.EndDate.split("-")[0], Number(this.EndDate.split("-")[1])-1, this.EndDate.split("-")[2]);
			
			if( mobile_schedule_GetDiffDates(sDate, dataStartDate, 'day') <= 0 && mobile_schedule_GetDiffDates(eDate, dataEndData, 'day') >= 0 ){ //기준 시간 안에 비교대상이 포함되어 있을 때 
				isInclude = true;
			}else if( mobile_schedule_GetDiffDates(sDate, dataStartDate, 'day') < 0 && mobile_schedule_GetDiffDates(sDate, dataEndData, 'day') >= 0 && mobile_schedule_GetDiffDates(eDate, dataEndData, 'day') <= 0  ){ // 기준 시간 안에 비교대상의 시작점은 포함되엉 있고, 종료점은 넘어가지 않을 때 
				isInclude = true;
			}else if( mobile_schedule_GetDiffDates(sDate, dataStartDate, 'day') >= 0 && mobile_schedule_GetDiffDates(eDate, dataStartDate, 'day') <= 0 && mobile_schedule_GetDiffDates(eDate, dataEndData, 'day') >= 0 ){ // 기준 시간 안에 비교대상의 종료점은 포함되엉 있고, 시작점은 넘어가지 않을 때
				isInclude = true;
			}else if( mobile_schedule_GetDiffDates(sDate, dataStartDate, 'day') >= 0 && mobile_schedule_GetDiffDates(eDate, dataEndData, 'day') <= 0 ){ //기준 시간이 비교대상에 포함되어 있을 때 
				isInclude = true;
			}
			
			if(isInclude){
				eventObj.push(this);
				return;
			}
		});
		eventArr.push(eventObj);
	});
	
	// 데이터 달력에 그림
	for(var i=0; i<eventArr.length; i++){
		mobile_schedule_DrawMonthEventData(eventArr[i], _mobile_schedule_common.ArrSunday[i]);
	}
}

//월간보기 리스트 - 데이터 조작 후 그리기
function mobile_schedule_SetMonthEventDataList(eventData){

	var sHtml = "";
	
	if($(eventData).length > 0){
		$(eventData).each(function(j){
			
			//제목(title) 설정
			var sTitle = "";
			if(this.ImportanceState == "Y"){
				sTitle += "<span class=\"ico_point\"></span>"
			}
			if(this.IsRepeat == "Y"){
				sTitle += "<span class=\"ico_repeat\"></span>"
			}
			sTitle += this.Subject;
			
			//시간(time) 설정
			var sTime = "";
			if(this.IsAllDay == "Y"){
				sTime += mobile_schedule_SetDateFormat(this.StartDateTime.substring(0, this.StartDateTime.indexOf(' ')), '.') + " " + mobile_comm_getDic("lbl_AllDay"); //종일
			}
			else{
				sTime += mobile_schedule_SetDateFormat(this.StartDateTime.split(" ")[0], '.') + " " + this.StartDateTime.split(" ")[1] 
					+ " ~ " + mobile_schedule_SetDateFormat(this.EndDateTime.split(" ")[0], '.') + " " + this.EndDateTime.split(" ")[1];
			}
		
			//속성 설정
			var sUrl = "/groupware/mobile/schedule/view.do";
			sUrl += "?eventid=" + this.EventID;
			sUrl += "&dateid=" + this.DateID;
			sUrl += "&isrepeat=" + this.IsRepeat;
			sUrl += "&repeatid=" + this.RepeatID;
			sUrl += "&folderid=" + this.FolderID;
			if(this.IsRepeat == "Y"){
				sUrl += "&isrepeatall=" + "Y"; //$("[name=rdoRepeat]:checked").val() == "only" ? "N" : "Y";
			}
			if(_mobile_schedule_common.IsCommunity == "Y"){
				sUrl += "&iscommunity=Y";
			}
			
			//데이터 생성
			sHtml += "<li>";
			sHtml += "		<a href=\"javascript: mobile_comm_go('" + sUrl + "', 'Y');\">";
			sHtml += "			<span class=\"bull_level\" style=\"background:" + this.Color + "\"></span>";
			sHtml += "			<div class=\"schedule\">";
			sHtml += "				<p class=\"title\">" + sTitle + "</p>";
			sHtml += "				<p class=\"time\">" + sTime + "</p>";
			sHtml += "			</div>";
			sHtml += "		</a>";
			sHtml += "</li>";
		});
	} else {
		if(_mobile_schedule_common.ViewType == "L"){
			sHtml += "<div class=\"no_list\">";
			sHtml += "    <p>" + mobile_comm_getDic("msg_NoDataList") + "</p>";//조회할 목록이 없습니다.
			sHtml += "</div>";
		}
	}

	if(_mobile_schedule_common.ViewType == "ML"){
		//리스트
		$("#schedule_month_list").html(sHtml);
	} else {
		//리스트
		$("#schedule_list_list").html(sHtml);
		// 상단 제목 날짜 표시
		$('#schedule_list_datetitle').html(_mobile_schedule_common.Year + "." +mobile_comm_AddFrontZero( _mobile_schedule_common.Month, 2));
	}
	
}

//데이터 달력에 그림
function mobile_schedule_DrawMonthEventData(eventDataArr, pSunday){
	var sunday = mobile_schedule_SetDateFormat(pSunday, '.');
    
    for (var d = 0; d < eventDataArr.length; d++) {
    	
        var strSun = mobile_schedule_SetDateFormat(sunday, '/');
        var g_sun = new Date(strSun);
        var g_nsun = mobile_schedule_AddDays(strSun, 7);
        
        var sTime = eventDataArr[d].StartTime;
        var eTime = eventDataArr[d].EndTime;
        var sDate = eventDataArr[d].StartDate;
        var eDate = eventDataArr[d].EndDate;
        var isRepeat = eventDataArr[d].IsRepeat;
        
        // 종일/반복처리시 종료일 
        if (eTime == "00:00" || (eventDataArr[d].IsAllDay == "Y" && isRepeat == "Y")) {
            if(eDate != sDate) {
                eDate = mobile_schedule_SetDateFormat(mobile_schedule_SubtractDays(eDate.replace(/\./gi, '-'), 1), '.');
            }
            if (eTime == "00:00") {
                eTime = "23:59";
            }
        }

        var sDateTime = mobile_schedule_MakeDateForCompare(sDate, sTime);
        var eDateTime = mobile_schedule_MakeDateForCompare(eDate, eTime);

        var sDay = null; // 시작요일
        var eDay = null; // 종료요일
        var tDay = null; // 일정의 길이
      
        // 하루가 넘는 경우
        if (sDate != eDate) {
            if (mobile_schedule_GetDiffDates(sDateTime, g_sun, 'day') > 0) { //시작일이 일요일 이전(일요일 부터): 연결 표시 필요
                sDay = 0;
            } else { // 시작일이 일요일 이후
                sDay = parseInt(mobile_schedule_GetDiffDates(g_sun, sDateTime, 'day'));
            }
            if (mobile_schedule_GetDiffDates(g_nsun, eDateTime, 'day') > 0) { //종료일이 토요일 이후(토요일까지) : 연결 표시 필요
                eDay = 6;
            } else { // 종료일이 토요일 이하
                eDay = parseInt(mobile_schedule_GetDiffDates(g_sun, eDateTime, 'day'))
            }
            // 일일 일정
        } else {
            sDay = parseInt(mobile_schedule_GetDiffDates(g_sun, sDateTime, 'day'));
            eDay = sDay;
        }

        tDay = (eDay + 1) - sDay;// 몇개의 요일을 걸치는지.
        
        //달력에 일정이 존재한다는 표시를 해줌
        for(var temp = 0; temp < tDay; temp++){
        	$("td[schday='" + mobile_schedule_SetDateFormat(mobile_schedule_AddDays(sunday, sDay+temp), '.') + "']").addClass("has_sch");
        }

    }
}

//월간보기 하단의 리스트 가져오기
function mobile_schedule_ShowScheduleMonthList(date) {

	var tempdate = mobile_schedule_SetDateFormat(date, '.');
	
	_mobile_schedule_common.SelectDate = tempdate;
	
	if($("td[schday='" + tempdate + "']").hasClass('active')) {
		mobile_comm_go('/groupware/mobile/schedule/write.do?' + (_mobile_schedule_common.IsCommunity == "Y" ? 'iscommunity=Y&' : '') + 'date=' + tempdate + '&time=0');
	} else {
		$("td.active").removeClass("active");
	
		// 선택일 표시하기
		var activeDateStr = mobile_schedule_SetDateFormat(date, ".");
		$("td[schday='" + activeDateStr + "']").addClass("active");
	
		// 월간보기 하단 리스트 재조회
		mobile_schedule_MakeMonthList(date);
	}
}


//일정 월간보기 끝







/*!
 * 
 * 일정 주간보기 
 * 
 */


//주간보기 페이지 초기화
function mobile_schedule_WeekInit(){
	
	if(window.sessionStorage["schedule_writeinit"] == "Y")
		window.sessionStorage.removeItem('schedule_writeinit');
	
	//초기화 및 파라미터 세팅
	mobile_schedule_InitJS();

	//상단바 세팅
	mobile_schedule_setCommunityTopMenu(_mobile_schedule_common);
		
	//주간보기 캘린더 영역
	mobile_schedule_MakeWeekCalendar();	
	
	mobile_schedule_SetScheduleFolderList();
}

//주간 그리기
function mobile_schedule_MakeWeekCalendar(){
	
	var i, j;
	
	_mobile_schedule_time = ";";
	
	var startDateObj = new Date(mobile_schedule_ReplaceDate(_mobile_schedule_common.StartDate));

    //select day가 속한 주를 가져오기
    var sun = mobile_schedule_GetSunday(startDateObj);
    var strSun = mobile_schedule_SetDateFormat(sun, '/');
    var mon = mobile_schedule_AddDays(strSun, 1);
    var tue = mobile_schedule_AddDays(strSun, 2);
    var wed = mobile_schedule_AddDays(strSun, 3);
    var thr = mobile_schedule_AddDays(strSun, 4);
    var fri = mobile_schedule_AddDays(strSun, 5);
    var sat = mobile_schedule_AddDays(strSun, 6);

    // 상단 제목 날짜 표시
    var sWeekTitle = mobile_schedule_SetDateFormat(sun, '.').slice(0,7) + " <span>";
    var iWeekNum = mobile_schedule_getWeekNum(startDateObj);
    switch(iWeekNum){
	    case 1 : sWeekTitle += mobile_comm_getDic("lbl_FirstWeek"); break;		//첫번째 주
	    case 2 : sWeekTitle += mobile_comm_getDic("lbl_SecondWeek"); break;	//두번째주
	    case 3 : sWeekTitle += mobile_comm_getDic("lbl_ThirdWeek"); break;		//세번째주
	    case 4 : sWeekTitle += mobile_comm_getDic("lbl_FourthWeek"); break;	//네번째주
	    case 5 : sWeekTitle += mobile_comm_getDic("lbl_FifthWeek"); break;		//다섯번째주
    }
    sWeekTitle += "</span>";
    $('#schedule_week_titleDate').html(sWeekTitle);
	
	// 헤더 날짜
	var headerDateHTML = "";
	headerDateHTML += '<th></th>';
	headerDateHTML += '<th><a href="javascript: mobile_schedule_clickworktime();" class="chk_work_time ui-link ' +(_mobile_schedule_common.IsWorkTime == "Y" ? 'active' : '')+ '">' + mobile_comm_getDic("lbl_BusinessTime2") + '</a></th>'; //업무<br>시간
	headerDateHTML += '<th date="' + mobile_schedule_SetDateFormat(sun, '.') 	+ '" class="sun"><span>SUN<br>'+sun.getDate()+'</span></th>';
	headerDateHTML += '<th date="' + mobile_schedule_SetDateFormat(mon, '.')	+ '"><span>MON<br>'+mon.getDate()+'</span></th>';
	headerDateHTML += '<th date="' + mobile_schedule_SetDateFormat(tue, '.') 	+ '"><span>TUE<br>'+tue.getDate()+'</span></th>';
	headerDateHTML += '<th date="' + mobile_schedule_SetDateFormat(wed, '.')	+ '"><span>WED<br>'+wed.getDate()+'</span></th>';
	headerDateHTML += '<th date="' + mobile_schedule_SetDateFormat(thr, '.') 	+ '" ><span>THU<br>'+thr.getDate()+'</span></th>';
	headerDateHTML += '<th date="' + mobile_schedule_SetDateFormat(fri, '.') 	+ '"><span>FRI<br>'+fri.getDate()+'</span></th>';
	headerDateHTML += '<th date="' + mobile_schedule_SetDateFormat(sat, '.') 	+ '" class="sat"><span>SAT<br>'+sat.getDate()+'</span></th>';
	headerDateHTML += '<th></th>';
	
	$("#schedule_week_calendarheader").html(headerDateHTML);

	
	// 종일
	var bodyHTML = '<tr id="schedule_week_calendarallday" class="sec">';
	
	bodyHTML 	+= '		<td></td>';
	bodyHTML 	+= '		<td class="all_day">';
	bodyHTML 	+= '			<a href="#" class="time">' + mobile_comm_getDic("lbl_AllDay") + '</a>'; //종일
	bodyHTML 	+= '		</td>';
	
	for(i = 0; i < 7; i++){
		bodyHTML 	+= '	<td class="hourCell" date="'+mobile_schedule_SetDateFormat(mobile_schedule_AddDays(strSun, i), '.')+'">';
		bodyHTML 	+= '		<a href="#" class="add"></a>';
		bodyHTML 	+= '	</td>';
	}
	
	bodyHTML 	+= '		<td></td>';
	bodyHTML		+= '</tr>';

	// 업무시간으로 체크되었을 경우
	var timeStart = 0;
	var timeEnd = 24;
	
	if(_mobile_schedule_common.IsWorkTime == "Y"){
	    if(mobile_comm_getBaseConfig("WorkStartTime", 0) != ""){
	    	timeStart = Number(mobile_comm_getBaseConfig("WorkStartTime", 0), 0);
	    }
	    if(mobile_comm_getBaseConfig("WorkEndTime", 0) != ""){
	    	timeEnd = Number(mobile_comm_getBaseConfig("WorkEndTime", 0), 0);
	    }
    }
      
    // 달력 내용
    for(i = timeStart; i < timeEnd; i++){
    	if(i != timeEnd-1){
    		bodyHTML += '<tr time="'+i+'">';
    	} else {
    		bodyHTML += '<tr class="sec">';
    	}
    	bodyHTML += '	<td></td>';
    	bodyHTML += '	<td>';
    	bodyHTML += '		<a href="#" class="time">'+i+mobile_comm_getDic("lbl_Hour")+'</a>';
    	bodyHTML += '	</td>';
    	
    	for(j=0; j<7; j++){
    		bodyHTML += '<td id="schedule_week_td'+j+'" date="'+mobile_schedule_SetDateFormat(mobile_schedule_AddDays(strSun, j), '.')+'" time="'+i+'">';
			var now = new Date();
			if(mobile_schedule_SetDateFormat(now, '.') == mobile_schedule_SetDateFormat(mobile_schedule_AddDays(strSun, j), '.') 
				&& now.getHours() == i){
				bodyHTML += '<div class="schTimeLine" style="z-index:100;"></div>';
			}
    		bodyHTML += '	<a href="javascript: mobile_schedule_clickHour(\'' + mobile_schedule_SetDateFormat(mobile_schedule_AddDays(strSun, j), '.') + '\', \'' + i + '\');" class="add"></a>';
    		bodyHTML += '</td>';
    	}
    	
    	bodyHTML += '	<td></td>';
    	bodyHTML += '</tr>';
    	
    }
    
    $("#schedule_week_calendarbody").html(bodyHTML);

	//현재 타임라인 높이 구하기
	$('.schTimeLine').css('top', (new Date().getMinutes() * 30)/60 + 'px');
    
    // 요일 활성화
    $("#schedule_week_calendarheader th[date='"+mobile_schedule_SetDateFormat(_mobile_schedule_common.CurrentTime, '.')+"']").addClass("on");
    
    var sDate = mobile_schedule_SetDateFormat(sun, '-');
    var eDate = mobile_schedule_SetDateFormat(sat, '-');
    
    if(_mobile_schedule_common.IsWorkTime == "Y"){
    	sDate = sDate + " " + mobile_comm_AddFrontZero(timeStart, 2) + ":00";
    	eDate = eDate + " " + mobile_comm_AddFrontZero(timeEnd, 2) + ":00";
    }
    
    //데이터 조회하여 그림
    mobile_schedule_GetMonthEventData(sDate, eDate);
    
}

// 주간보기 이벤트를 달력에 바인딩
function mobile_schedule_SetWeekEventData(eventData, pSDate, pEDate){
	
	for(var i=0; i<eventData.length; i++){
		if(eventData[i] != undefined){
			
			var allDayHTML = "";
			var dayHTML = '';
			
			var sDate = eventData[i].StartDate;
			var eDate = eventData[i].EndDate;
			var sDateTime = eventData[i].StartDateTime;
			var eDateTime = eventData[i].EndDateTime;
			var isRepeat = eventData[i].IsRepeat;
			var className = "";
	    	
	    	//중요도 및 반복 표시
	        if (eventData[i].ImportanceState == 'Y' && isRepeat == 'Y') {
	        	className += " rePoint";
	        }else if(eventData[i].ImportanceState == 'Y'){
	        	className += " point";
	        }else if(isRepeat == 'Y'){
	        	className += " repeat";
	        }
	        
	       //url 설정
			var sUrl = "/groupware/mobile/schedule/view.do";
			sUrl += "?eventid=" + eventData[i].EventID;
			sUrl += "&dateid=" + eventData[i].DateID;
			sUrl += "&isrepeat=" + eventData[i].IsRepeat;
			sUrl += "&repeatid=" + eventData[i].RepeatID;
			sUrl += "&folderid=" + eventData[i].FolderID;
			if(isRepeat == "Y"){
				sUrl += "&isrepeatall=" + "Y"; //$("[name=rdoRepeat]:checked").val() == "only" ? "N" : "Y";
			}
			if(_mobile_schedule_common.IsCommunity == "Y"){
				sUrl += "&iscommunity=Y";
			}
			
			// 종일일정
			if(sDate != eDate || eventData[i].IsAllDay == "Y"){
				
				//td가 존재하지 않는다면
				if($("#schedule_week_calendarallday td[date='" + mobile_schedule_SetDateFormat(sDate, ".") + "']").length < 1){
					sDate = pSDate;
				}
				
				//ul이 존재하지 않는다면
				if($("#schedule_week_calendarallday td[date='" + mobile_schedule_SetDateFormat(sDate, ".") + "'] ul").length < 1){
					$("#schedule_week_calendarallday td[date='" + mobile_schedule_SetDateFormat(sDate, ".") + "']").html("<ul></ul>");
				}
				
				allDayHTML += '<li id="allDayData_'+eventData[i].DateID+'" eventID="'+eventData[i].EventID+'" dateID="'+eventData[i].DateID+'" startDateTime="'+sDateTime+'" endDateTime="'+eDateTime+'" style="width:100%;height:50%;background:' + eventData[i].Color + ';">';
				allDayHTML += '		<a href="javascript: mobile_comm_go(\'' + sUrl + '\', \'Y\')" style=\'text-align: left;\'>';
				allDayHTML +=			eventData[i].Subject;
				allDayHTML += '		</a>';
				allDayHTML += '</li>';

				$("#schedule_week_calendarallday td[date='" + mobile_schedule_SetDateFormat(sDate, ".") + "'] ul").append(allDayHTML);
				
			}
			// 시간으로 지정된 일정
			else{
				// 업무시간으로 체크했을 경우 업무시간 이외의 일정은 제외하기
				if(_mobile_schedule_common.IsWorkTime == "Y"){
					var sDateTimeObj = new Date(mobile_schedule_ReplaceDate(sDateTime)).getTime();
					var eDateTimeObj = new Date(mobile_schedule_ReplaceDate(eDateTime)).getTime();
					
					var workSDateTime = new Date(sDate + " " + mobile_comm_AddFrontZero(Number(mobile_comm_getBaseConfig("WorkStartTime", 0)), 2) + ":00").getTime();
					var workEDateTime = new Date(eDate + " " + mobile_comm_AddFrontZero(Number(mobile_comm_getBaseConfig("WorkEndTime", 0)), 2) + ":00").getTime();
					
					if( (sDateTimeObj >= workSDateTime && sDateTimeObj < workEDateTime)
							|| (sDateTimeObj <= workSDateTime && eDateTimeObj >= workEDateTime)
							|| (workSDateTime <= eDateTimeObj && eDateTimeObj < workEDateTime) ){
						if(eDateTimeObj > workEDateTime){
							eDateTime = eDate + " " + mobile_comm_AddFrontZero(Number(mobile_comm_getBaseConfig("WorkEndTime", 0)), 2) + ":00";
						}
						if(sDateTimeObj < workSDateTime){
							sDateTime = sDate + " " + mobile_comm_AddFrontZero(Number(mobile_comm_getBaseConfig("WorkStartTime", 0)), 2) + ":00";
						}
					}else{
						continue;
					}
			    }
				
				var startTime = (new Date(sDateTime)).getHours();
				var endTime = (new Date(eDateTime)).getHours();

				_mobile_schedule_time += mobile_comm_getDateTimeString('yyyy.MM.dd.', new Date(sDateTime)) + startTime + ";";
				
				// height 값 구하기
				var heightVal = 31;
				var diffMin = mobile_schedule_GetDiffDates(new Date(mobile_schedule_ReplaceDate(sDateTime)), new Date(mobile_schedule_ReplaceDate(eDateTime)), 'min');
				
				var multiHeightVal = diffMin / 60;
				if(multiHeightVal >= 1) {
					heightVal = heightVal * multiHeightVal;
					
					for(startTime++; startTime < endTime + 1; startTime++) {
						if(startTime == endTime) {
							if(Math.floor(multiHeightVal) != multiHeightVal) {
								_mobile_schedule_time += mobile_comm_getDateTimeString('yyyy.MM.dd.', new Date(sDateTime)) + startTime + ";";
							}
						} else {
							_mobile_schedule_time += mobile_comm_getDateTimeString('yyyy.MM.dd.', new Date(sDateTime)) + startTime + ";";
						}
					}
				} else if(multiHeightVal < 1) {
					heightVal = 15;
				}
				
				
				dayHTML += '<li id="eventData_'+eventData[i].DateID+'" eventID="'+eventData[i].EventID+'" dateID="'+eventData[i].DateID
					+'" startDateTime="'+sDateTime+'" endDateTime="'+eDateTime+'" isRepeat="'+isRepeat+'" folderID="'+eventData[i].FolderID
					+'" registerCode="'+eventData[i].RegisterCode+'" ownerCode="'+eventData[i].OwnerCode+'" class="shcMultiDayText '+className
					+'" style="background:'+eventData[i].Color+'; height:'+heightVal+'px;'+(((new Date(sDateTime)).getMinutes() == 30) ? 'top: 15px;' : '')+'" >';
				dayHTML += '		<a href="javascript: mobile_comm_go(\'' + sUrl + '\', \'Y\')">';
				dayHTML += 			eventData[i].Subject;
				dayHTML += '		</a>';
				dayHTML += '</li>';

				var tempStarTime = Number(sDateTime.substring(sDateTime.indexOf(' '), sDateTime.indexOf(':')));
				
				//ul이 존재하지 않는다면
				if($("#schedule_week_calendarbody td[date='" + mobile_schedule_SetDateFormat(sDate, ".") +"'][time='"+tempStarTime+"'] ul").length < 1){
					if(sDate != mobile_schedule_SetDateFormat(new Date(), "-") || tempStarTime != new Date().getHours()){
						$("#schedule_week_calendarbody td[date='" + mobile_schedule_SetDateFormat(sDate, ".") +"'][time='"+tempStarTime+"']").html("<ul></ul>");
					} else {
						$("#schedule_week_calendarbody td[date='" + mobile_schedule_SetDateFormat(sDate, ".") +"'][time='"+tempStarTime+"']").html("<ul><div class='" + 'schTimeLine' + "' style='" + 'z-index:101;' + "'></div></ul>");
						
						//현재 타임라인 높이 구하기
						$('.schTimeLine').css('top', (new Date().getMinutes() * 30)/60 + 'px');
					}
				}
				
				$("#schedule_week_calendarbody td[date='" + mobile_schedule_SetDateFormat(sDate, ".") +"'][time='"+tempStarTime+"'] ul").append(dayHTML);
			}
		}
	}

	//event li 사이즈 조절
	mobile_schedule_setWeekEventDataSize(pSDate, pEDate);
	
}

//event li 사이즈 조절
function mobile_schedule_setWeekEventDataSize(pSDate, pEDate){
	
	var widthVal = $(".hourCell").width();
	var heightVal = 15;
	var weekstart = $('.hourCell').eq(0).attr('date');
	
	//업무시간 선택 시 08:00 제거
	pSDate = pSDate.replace(" 08:00", "");
	
	//종일 일정1
	var seDateArr = new Array();
	$("#schedule_week_calendarbody tr[id='schedule_week_calendarallday'] ul > li").each(function(i) {
		
		var sDateTime = $(this).attr("startDateTime");
		var eDateTime = $(this).attr("endDateTime");
		var sDate = $(this).attr("startDateTime").split(" ")[0];
		var eDate = $(this).attr("endDateTime").split(" ")[0];
		
		var diff_width = mobile_schedule_GetDiffDates(new Date(mobile_schedule_ReplaceDate(sDateTime)), new Date(mobile_schedule_ReplaceDate(eDateTime)), 'min');
		var diff_start = mobile_schedule_GetDiffDates(new Date(mobile_schedule_ReplaceDate(pSDate)), new Date(mobile_schedule_ReplaceDate(sDateTime)), 'min');
			
		var width = ((diff_width / 60) / 24) * widthVal;
		var left = ((diff_start / 60) / 24) * widthVal;
		
		if(left < 0) { //지난 주에 시작된 데이터
			width += left;
			left = 0;
		} else if(width + left > 7 * widthVal) { //다음 주까지 이어지는 데이터
			width = (7 * widthVal) - left;
		}
		
		if(diff_width > 0) {
			width += Math.floor((diff_width / 60) / 24);
		}
		
		if(left > 0) {
			var diffleft = mobile_schedule_GetDiffDates(new Date(mobile_schedule_ReplaceDate(weekstart)), new Date(mobile_schedule_ReplaceDate($(this).parent().parent().attr('date'))), 'day');
			left = left - (diffleft * widthVal);
		}
			
		$(this).css("width", width);
		$(this).css("margin-left", left);
		
		// Top를 구하기 위한 데이터 세팅
	    var seDateObj = {};
	    seDateObj.start = sDate;
	    seDateObj.end = eDate;
	    seDateObj.day = $(this).parent().parent().attr('date');
	    
	    seDateArr.push(seDateObj);
	});
	
	//종일 일정2
	
	$("#schedule_week_calendarbody tr[id='schedule_week_calendarallday'] ul > li").each(function(i) {

		var thisStart = new Date(mobile_schedule_ReplaceDate(seDateArr[i].start));
		var thisDay = seDateArr[i].day;
		
		var top = 0;
		
		var isInclude = false;
		var ulcnt = 0;
		$(seDateArr).each(function(j) {
			
			//다른 일정 중 1) 날짜가 다르고 2) 먼저or같이 시작하는데 겹치는거
			if(i != j && thisDay != this.day) {
				var compareStartDate = new Date(mobile_schedule_ReplaceDate(this.start));
				
				if(mobile_schedule_GetDiffDates(thisStart, compareStartDate, 'day') <= 0) {
					ulcnt++;
					isInclude = true;
				}
			}
		});
		
		if(!(i == 0 || (i > 0 && !isInclude))) {
			top = heightVal * ulcnt;
		}
		$(this).parent().css("padding-top", top);
	});
	
	//일반 일정
	$("#schedule_week_calendarbody tr[id!='schedule_week_calendarallday'] ul").each(function(i) {
		
		var width = 90 / ($(this).children("li").length);
		
		//기본 너비 설정
		$(this).children("li").css("width", "calc(" + width + "% - " + ($(this).children("li").length - 1) + "px)");
		
		//겹치는 경우를 조절
		$(this).children("li").not(':first').each(function(j){
			$(this).css("left", "calc(" + (width * (j + 1)) + "% + " + (j + 1) + "px)");
		});
		
		//일정 추가란 생성
		$(this).append('<li style="left: 90%; width: 10%"><a href="javascript: mobile_schedule_clickHour(\'' + $(this).parent().attr("date") + '\', \'' + $(this).parent().attr("time") + '\');" class="add"></a></li>');
	});
	
}


//일정 주간보기 끝











/*!
 * 
 * 일정 일간보기 
 * 
 */


//일간보기 페이지 초기화
function mobile_schedule_DayInit(){
	
	if(window.sessionStorage["schedule_writeinit"] == "Y")
		window.sessionStorage.removeItem('schedule_writeinit');
	
	//초기화 및 파라미터 세팅
	mobile_schedule_InitJS();

	//상단바 세팅
	mobile_schedule_setCommunityTopMenu(_mobile_schedule_common);
		
	//일간보기 캘린더 영역
	mobile_schedule_MakeDayCalendar();
	
	mobile_schedule_SetScheduleFolderList();
}

//일간 그리기
function mobile_schedule_MakeDayCalendar(){
	
	_mobile_schedule_time = ";";
	
	var startDateObj = new Date(mobile_schedule_ReplaceDate(_mobile_schedule_common.StartDate));

    //select day가 속한 주를 가져오기
    var sun = mobile_schedule_GetSunday(startDateObj);
    var strSun = mobile_schedule_SetDateFormat(sun, '/');
    var mon = mobile_schedule_AddDays(strSun, 1);
    var tue = mobile_schedule_AddDays(strSun, 2);
    var wed = mobile_schedule_AddDays(strSun, 3);
    var thr = mobile_schedule_AddDays(strSun, 4);
    var fri = mobile_schedule_AddDays(strSun, 5);
    var sat = mobile_schedule_AddDays(strSun, 6);

    // 상단 제목 날짜 표시
    var sDayTitle = mobile_schedule_SetDateFormat(_mobile_schedule_common.StartDate, '.');
    $('#schedule_day_titleDate').html(sDayTitle);
	
	// 헤더 날짜
	var headerDateHTML = "";
	headerDateHTML += '<th></th>';
	headerDateHTML += '<th><a href="javascript: mobile_schedule_clickworktime();" class="chk_work_time ui-link ' +(_mobile_schedule_common.IsWorkTime == "Y" ? 'active' : '')+ '">' + mobile_comm_getDic("lbl_BusinessTime2") + '</a></th>'; //업무<br>시간
	headerDateHTML += '<th date="' + mobile_schedule_SetDateFormat(sun, '.') 	+ '" class="sun"><a href="javascript: mobile_schedule_clickDayHeader(\'' + mobile_schedule_SetDateFormat(sun, '.') + '\');"><span>SUN<br>'+sun.getDate()+'</span></a></th>';
	headerDateHTML += '<th date="' + mobile_schedule_SetDateFormat(mon, '.')	+ '"><a href="javascript: mobile_schedule_clickDayHeader(\'' + mobile_schedule_SetDateFormat(mon, '.') + '\');"><span>MON<br>'+mon.getDate()+'</span></a></th>';
	headerDateHTML += '<th date="' + mobile_schedule_SetDateFormat(tue, '.') 	+ '"><a href="javascript: mobile_schedule_clickDayHeader(\'' + mobile_schedule_SetDateFormat(tue, '.') + '\');"><span>TUE<br>'+tue.getDate()+'</span></a></th>';
	headerDateHTML += '<th date="' + mobile_schedule_SetDateFormat(wed, '.')	+ '"><a href="javascript: mobile_schedule_clickDayHeader(\'' + mobile_schedule_SetDateFormat(wed, '.') + '\');"><span>WED<br>'+wed.getDate()+'</span></a></th>';
	headerDateHTML += '<th date="' + mobile_schedule_SetDateFormat(thr, '.') 	+ '" ><a href="javascript: mobile_schedule_clickDayHeader(\'' + mobile_schedule_SetDateFormat(thr, '.') + '\');"><span>THU<br>'+thr.getDate()+'</span></a></th>';
	headerDateHTML += '<th date="' + mobile_schedule_SetDateFormat(fri, '.') 	+ '"><a href="javascript: mobile_schedule_clickDayHeader(\'' + mobile_schedule_SetDateFormat(fri, '.') + '\');"><span>FRI<br>'+fri.getDate()+'</span></a></th>';
	headerDateHTML += '<th date="' + mobile_schedule_SetDateFormat(sat, '.') 	+ '" class="sat"><a href="javascript: mobile_schedule_clickDayHeader(\'' + mobile_schedule_SetDateFormat(sat, '.') + '\');"><span>SAT<br>'+sat.getDate()+'</span></a></th>';
	headerDateHTML += '<th></th>';
	$("#schedule_day_calendarheader").html(headerDateHTML);
	
	// 종일
	var bodyHTML = '<tr id="schedule_day_calendarallday" class="sec">';
	bodyHTML 	+= '		<td></td>';
	bodyHTML 	+= '		<td class="all_day">';
	bodyHTML 	+= '			<a href="#" class="time">' + mobile_comm_getDic("lbl_AllDay") + '</a>'; //종일
	bodyHTML 	+= '		</td>';
	bodyHTML 	+= '		<td class="hourCell" date="'+mobile_schedule_SetDateFormat(_mobile_schedule_common.StartDate, '.')+'">';
	bodyHTML 	+= '			<a href="#" class="add"></a>';
	bodyHTML 	+= '		</td>';
	bodyHTML 	+= '		<td></td>';
	bodyHTML	+= '	</tr>';

	// 업무시간으로 체크되었을 경우
	var timeStart = 0;
	var timeEnd = 24;
	
	if(_mobile_schedule_common.IsWorkTime == "Y"){
	    if(mobile_comm_getBaseConfig("WorkStartTime", 0) != ""){
	    	timeStart = Number(mobile_comm_getBaseConfig("WorkStartTime", 0));
	    }
	    if(mobile_comm_getBaseConfig("WorkEndTime", 0) != ""){
	    	timeEnd = Number(mobile_comm_getBaseConfig("WorkEndTime", 0));
	    }
    }
      
    // 달력 내용
    for(var i=timeStart; i<timeEnd; i++){
    	
    	if(i != timeEnd-1){
    		bodyHTML += '<tr time="'+i+'">';
    	} else {
    		bodyHTML += '<tr class="sec">';
    	}
    	bodyHTML += '	<td></td>';
    	bodyHTML += '	<td>';
    	bodyHTML += '		<a href="#" class="time">'+i+mobile_comm_getDic("lbl_Hour")+'</a>';
    	bodyHTML += '	</td>';
		bodyHTML += '	<td id="schedule_day_td'+i+'" date="'+mobile_schedule_SetDateFormat(_mobile_schedule_common.StartDate, ".")+'" time="'+i+'">';
		var now = new Date();
		if(mobile_schedule_SetDateFormat(now, '.') == mobile_schedule_SetDateFormat(_mobile_schedule_common.StartDate, ".") 
			&& now.getHours() == i){
			bodyHTML += '<div class="schTimeLine" style="z-index:100;"></div>';
		}
		bodyHTML += '		<a href="javascript: mobile_schedule_clickHour(\'' + mobile_schedule_SetDateFormat(_mobile_schedule_common.StartDate, ".") + '\', \'' + i + '\');" class="add"></a>';
		bodyHTML += '	</td>';
    	bodyHTML += '	<td></td>';
    	bodyHTML += '</tr>';
    	
    }
    
    $("#schedule_day_calendarbody").html(bodyHTML);
    
	//현재 타임라인
	$('.schTimeLine').css('top', (new Date().getMinutes() * 30)/60 + 'px');
	
    // 요일 활성화
    $("#schedule_day_calendarheader th[date='"+mobile_schedule_SetDateFormat(_mobile_schedule_common.StartDate, '.')+"']").addClass("on");
    
    var sDate = mobile_schedule_SetDateFormat(_mobile_schedule_common.StartDate, '-');
    var eDate = sDate;
    
    if(_mobile_schedule_common.IsWorkTime == "Y"){
    	sDate = sDate + " " + mobile_comm_AddFrontZero(timeStart, 2) + ":00";
    	eDate = eDate + " " + mobile_comm_AddFrontZero(timeEnd, 2) + ":00";
    }
    
    //데이터 조회하여 그림
    mobile_schedule_GetMonthEventData(sDate, eDate);    
}

// 일간보기 이벤트를 달력에 바인딩
function mobile_schedule_SetDayEventData(eventData, pSDate, pEDate) {
	
	for(var i=0; i<eventData.length; i++){
		if(eventData[i] != undefined){
			
			var allDayHTML = "";
			var dayHTML = '';
			
			var sDate = eventData[i].StartDate;
			var eDate = eventData[i].EndDate;
			var sDateTime = eventData[i].StartDateTime;
			var eDateTime = eventData[i].EndDateTime;
			var isRepeat = eventData[i].IsRepeat;
			var className = "";
	    	
	    	//중요도 및 반복 표시
	        if (eventData[i].ImportanceState == 'Y' && isRepeat == 'Y') {
	        	className += " rePoint";
	        }else if(eventData[i].ImportanceState == 'Y'){
	        	className += " point";
	        }else if(isRepeat == 'Y'){
	        	className += " repeat";
	        }
	        
	        //url 설정
			var sUrl = "/groupware/mobile/schedule/view.do";
			sUrl += "?eventid=" + eventData[i].EventID;
			sUrl += "&dateid=" + eventData[i].DateID;
			sUrl += "&isrepeat=" + eventData[i].IsRepeat;
			sUrl += "&repeatid=" + eventData[i].RepeatID;
			sUrl += "&folderid=" + eventData[i].FolderID;
			if(isRepeat == "Y"){
				sUrl += "&isrepeatall=" + "Y"; //$("[name=rdoRepeat]:checked").val() == "only" ? "N" : "Y";
			}
			if(_mobile_schedule_common.IsCommunity == "Y"){
				sUrl += "&iscommunity=Y";
			}
			
			// 종일일정
			if(sDate != eDate || eventData[i].IsAllDay == "Y"){
				
				//td가 존재하지 않는다면
				if($("#schedule_day_calendarallday td[date='" + mobile_schedule_SetDateFormat(sDate, ".") + "']").length < 1){
					sDate = pSDate;
				}
				
				//ul이 존재하지 않는다면
				if($("#schedule_day_calendarallday td[date='" + mobile_schedule_SetDateFormat(sDate, ".") + "'] ul").length < 1){
					$("#schedule_day_calendarallday td[date='" + mobile_schedule_SetDateFormat(sDate, ".") + "']").html("<ul></ul>");
				}
				
				allDayHTML += '<li id="allDayData_'+eventData[i].DateID+'" eventID="'+eventData[i].EventID+'" dateID="'+eventData[i].DateID+'" startDateTime="'+sDateTime+'" endDateTime="'+eDateTime+'" style="width:100%;height:50%;background:' + eventData[i].Color + ';">';
				allDayHTML += '		<a href="javascript: mobile_comm_go(\'' + sUrl + '\', \'Y\')">';
				allDayHTML +=			eventData[i].Subject;
				allDayHTML += '		</a>';
				allDayHTML += '</li>';

				$("#schedule_day_calendarallday td[date='" + mobile_schedule_SetDateFormat(sDate, ".") + "'] ul").append(allDayHTML);
				
			}
			// 시간으로 지정된 일정
			else{
				// 업무시간으로 체크했을 경우 업무시간 이외의 일정은 제외하기
				if(_mobile_schedule_common.IsWorkTime == "Y"){
					var sDateTimeObj = new Date(mobile_schedule_ReplaceDate(sDateTime)).getTime();
					var eDateTimeObj = new Date(mobile_schedule_ReplaceDate(eDateTime)).getTime();
					
					var workSDateTime = new Date(mobile_schedule_ReplaceDate(sDate) + " " + mobile_comm_AddFrontZero(Number(mobile_comm_getBaseConfig("WorkStartTime", 0)), 2) + ":00").getTime();
					var workEDateTime = new Date(mobile_schedule_ReplaceDate(eDate) + " " + mobile_comm_AddFrontZero(Number(mobile_comm_getBaseConfig("WorkEndTime", 0)), 2) + ":00").getTime();
					
					if( (sDateTimeObj >= workSDateTime && sDateTimeObj < workEDateTime)
							|| (sDateTimeObj <= workSDateTime && eDateTimeObj >= workEDateTime)
							|| (workSDateTime <= eDateTimeObj && eDateTimeObj < workEDateTime) ){
						if(eDateTimeObj > workEDateTime){
							eDateTime = eDate + " " + mobile_comm_AddFrontZero(Number(mobile_comm_getBaseConfig("WorkEndTime", 0)), 2) + ":00";
						}
						if(sDateTimeObj < workSDateTime){
							sDateTime = sDate + " " + mobile_comm_AddFrontZero(Number(mobile_comm_getBaseConfig("WorkStartTime", 0)), 2) + ":00";
						}
					}else{
						continue;
					}
			    }
				
				var startTime = (new Date(sDateTime)).getHours();
				var endTime = (new Date(eDateTime)).getHours();

				_mobile_schedule_time += startTime + ";";
				
				// height 값 구하기
				var heightVal = 31;
				var diffMin = mobile_schedule_GetDiffDates(new Date(mobile_schedule_ReplaceDate(sDateTime)), new Date(mobile_schedule_ReplaceDate(eDateTime)), 'min');
				var multiHeightVal = diffMin / 60;
				if(multiHeightVal >= 1) {
					heightVal = heightVal * multiHeightVal;
					
					for(startTime++; startTime < endTime + 1; startTime++) {
						if(startTime == endTime) {
							if(Math.floor(multiHeightVal) != multiHeightVal) {
								_mobile_schedule_time += startTime + ";";
							}
						} else {
							_mobile_schedule_time += startTime + ";";
						}
					}
				} else if(multiHeightVal < 1) {
					heightVal = 15;
				}
				
				
				dayHTML += '<li id="eventData_'+eventData[i].DateID+'" eventID="'+eventData[i].EventID+'" dateID="'+eventData[i].DateID
					+'" startDateTime="'+sDateTime+'" endDateTime="'+eDateTime+'" isRepeat="'+isRepeat+'" folderID="'+eventData[i].FolderID
					+'" registerCode="'+eventData[i].RegisterCode+'" ownerCode="'+eventData[i].OwnerCode+'" class="shcMultiDayText '+className
					+'" onclick="scheduleUser.setSimpleViewPopup(this)" style="background:'+eventData[i].Color+'; height:'+heightVal+'px;" >';
				dayHTML += '		<a href="javascript: mobile_comm_go(\'' + sUrl + '\', \'Y\')">';
				dayHTML += 			eventData[i].Subject;
				dayHTML += '		</a>';
				dayHTML += '</li>';

				var tempStarTime = Number(sDateTime.substring(sDateTime.indexOf(' '), sDateTime.indexOf(':')));
				
				//ul이 존재하지 않는다면
				if($("#schedule_day_calendarbody td[date='" + mobile_schedule_SetDateFormat(sDate, ".") +"'][time='"+tempStarTime+"'] ul").length < 1){
					if(sDate != mobile_schedule_SetDateFormat(new Date(), "-") || tempStarTime != new Date().getHours()){
						$("#schedule_day_calendarbody td[date='" + mobile_schedule_SetDateFormat(sDate, ".") +"'][time='"+tempStarTime+"']").html("<ul></ul>");
					} else {
						$("#schedule_day_calendarbody td[date='" + mobile_schedule_SetDateFormat(sDate, ".") +"'][time='"+tempStarTime+"']").html("<ul><div class='" + 'schTimeLine' + "' style='" + 'z-index:101;' + "'></div></ul>");
						
						//현재 타임라인 높이 구하기
						$('.schTimeLine').css('top', (new Date().getMinutes() * 30)/60 + 'px');
					}
				}
				
				$("#schedule_day_calendarbody td[date='" + mobile_schedule_SetDateFormat(sDate, ".") +"'][time='"+tempStarTime+"'] ul").append(dayHTML);
			}
		}
	}

	//event li 사이즈 조절
	mobile_schedule_setDayEventDataSize();
}

//event li 사이즈 조절
function mobile_schedule_setDayEventDataSize(){
	
	var widthVal = $('.hourCell').width();
	var weekstart = $('.hourCell').eq(0).attr('date');
	
	var width, left;
	
	//종일 일정1
	$("#schedule_day_calendarbody tr[id='schedule_day_calendarallday'] ul > li").each(function(i) {
		
		var sDateTime = $(this).attr("startDateTime");
		var eDateTime = $(this).attr("endDateTime");
		
		var diff_width = mobile_schedule_GetDiffDates(new Date(mobile_schedule_ReplaceDate(sDateTime)), new Date(mobile_schedule_ReplaceDate(eDateTime)), 'min');
		var diff_start = mobile_schedule_GetDiffDates(new Date(mobile_schedule_ReplaceDate(weekstart)), new Date(mobile_schedule_ReplaceDate(sDateTime)), 'min');
			
		width = ((diff_width / 60) / 24) * widthVal;
		left = ((diff_start / 60) / 24) * widthVal;
		
		if(left < 0) { //지난 주에 시작된 데이터
			width += left;
			left = 0;
		} else if(width + left > 7 * widthVal) { //다음 주까지 이어지는 데이터
			width = (7 * widthVal) - left;
		}
		
		if(diff_width > 0) {
			width += Math.floor((diff_width / 60) / 24);
		}
		
		if(left > 0) {
			var diffleft = mobile_schedule_GetDiffDates(new Date(mobile_schedule_ReplaceDate(weekstart)), new Date(mobile_schedule_ReplaceDate($(this).parent().parent().attr('date'))), 'day');
			left = left - (diffleft * widthVal);
		}
			
		$(this).css("width", width);
		$(this).css("margin-left", left);

		
		
	});
	
	//일반 일정
	$("#schedule_day_calendarbody tr[id!='schedule_day_calendarallday'] ul").each(function(i) {
		
		width = 90 / ($(this).children("li").length);
		
		//기본 너비 설정
		$(this).children("li").css("width", "calc(" + width + "% - " + ($(this).children("li").length - 1) + "px)");
		
		//겹치는 경우를 조절
		$(this).children("li").not(':first').each(function(j) {
			$(this).css("left", "calc(" + (width * (j + 1)) + "% + " + (j + 1) + "px)");
		});
		
		//일정 추가란 생성
		$(this).append('<li style="left: 90%; width: 10%"><a href="javascript: mobile_schedule_clickHour(\'' + $(this).parent().attr("date") + '\', \'' + $(this).parent().attr("time") + '\');" class="add"></a></li>');
	});
}

//선택 요일의 일간달력 보기
function mobile_schedule_clickDayHeader(pDate){
	
	_mobile_schedule_common.StartDate = pDate;

	_mobile_schedule_common.Year = _mobile_schedule_common.StartDate.split(".")[0];	
	_mobile_schedule_common.Month = _mobile_schedule_common.StartDate.split(".")[1];		
	_mobile_schedule_common.Day = _mobile_schedule_common.StartDate.split(".")[2];	

	//일간보기 캘린더 영역
	mobile_schedule_MakeDayCalendar();
	
}

//일정 일간보기 끝










/*!
 * 
 * 일정 목록보기
 * 
 */

//목록보기 페이지 초기화
function mobile_schedule_ListInit(pIsRefresh){
	
	if(window.sessionStorage["schedule_writeinit"] == "Y")
		window.sessionStorage.removeItem('schedule_writeinit');
	
	//초기화 및 파라미터 세팅
	mobile_schedule_InitJS(pIsRefresh);

	//상단바 세팅
	mobile_schedule_setCommunityTopMenu(_mobile_schedule_common);
	$("#schedule_list_top").hide();
	$("div.ly_search").hide();
	
	//목록보기 리스트 영역
	mobile_schedule_MakeList();	
	
	mobile_schedule_SetScheduleFolderList();
	
	delete mobile_commment_messageSetting;
}

//목록보기 리스트 영역
function mobile_schedule_MakeList(selDate) {

	var tempYear = "";
	var tempMonth = "";
	var tempDay = "";
	
	var prevMonthDate = "";		//검색 날짜 값 세팅
	var nextMonthDate = "";
	
	var sDate = "";
	var eDate = "";
	
	//검색일 경우
	if(_mobile_schedule_common.SearchText != null && _mobile_schedule_common.SearchText != undefined && _mobile_schedule_common.SearchText != '') {
		
		$("#schedule_list_page").find("#mobile_search_input").val(_mobile_schedule_common.SearchText);
		mobile_comm_opensearch();
		
		var importanceState = "";
		var subject = _mobile_schedule_common.SearchText;
		var placeName = _mobile_schedule_common.SearchText;
		var register = _mobile_schedule_common.SearchText;
		
		/*tempYear = _mobile_schedule_common.StartDate.split('.')[0];
		tempMonth = _mobile_schedule_common.StartDate.split('.')[1];
		tempDay = '01';
		
		if(tempMonth == 1){
			prevMonthDate = (Number(tempYear) - 1) + "/12/" + tempDay;
	    } else {
	    	prevMonthDate = tempYear + "/" + (Number(tempMonth) - 1) + "/" + tempDay;
	    }
		
		if(tempMonth == 12){
			nextMonthDate = (Number(tempYear) + 1) + "/01/" + tempDay;
	    } else {
	    	nextMonthDate = tempYear + "/" + (Number(tempMonth) + 1) + "/" + tempDay;
	    }
		
		sDate = mobile_schedule_SetDateFormat(prevMonthDate, '-');
		eDate = mobile_schedule_SetDateFormat(nextMonthDate, '-');*/
		
		sDate = mobile_schedule_SetDateFormat(mobile_comm_getQueryString("startdate"), '-');
		eDate = mobile_schedule_SetDateFormat(mobile_comm_getQueryString("enddate"), '-');
		
		

		/*
		if(type == "import"){
			importanceState = "Y";
		}else if(type == "all"){
			folderIDs = null;
		}
		*/
		
		var url = "/groupware/mobile/schedule/getList.do";
		var params = {
				"FolderIDs" : _mobile_schedule_common.FolderCheckList,
				"StartDate" : CFN_TransServerTime(sDate.replaceAll(".", "-") + ' 00:00'),
				"EndDate" : CFN_TransServerTime(mobile_schedule_SetDateFormat(mobile_schedule_AddDays(eDate.replaceAll(".", "-"), 1),'-') + ' 00:00'),
				"UserCode" : mobile_comm_getSession("UR_Code"),
				"lang" : mobile_comm_getSession("LanguageCode"),
				"ImportanceState" : importanceState,
				"Subject" : subject,
				"PlaceName" : placeName,
				"RegisterName" : register,
				"IsMobile" : "Y"
		};
		
		$.ajax({
		    url: url,
		    type: "POST",
		    data: params,
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
		    		mobile_schedule_SetMonthEventDataList(res.list);
		    	}
		    	else {
		    		alert(mobile_comm_getDic("msg_apv_030"));		// 오류가 발생했습니다.
		    	}
		    },
		    error:function(response, status, error){
				mobile_comm_ajaxerror(url, response, status, error);
			}
		});
	}
	//목록보기일 경우
	else {
		
		$("#schedule_list_top").show();
		
		if(selDate == undefined){
			selDate = _mobile_schedule_common.StartDate;
		}
		
		tempYear = selDate.split('.')[0];
		tempMonth = selDate.split('.')[1];
		
		if(tempMonth == 12){
			nextMonthDate = (Number(tempYear) + 1) + "/01/01";
	    } else {
	    	nextMonthDate = tempYear + "/" + (Number(tempMonth) + 1) + "/01";
	    }
		
		sDate = tempYear + "-" + mobile_comm_AddFrontZero(tempMonth, 2) + "-01";
		eDate = mobile_schedule_SetDateFormat(mobile_schedule_SubtractDays(nextMonthDate, 1), '-');

		mobile_schedule_GetMonthEventData(sDate, eDate);
	}
	
}

//일정 목록보기 끝











/*!
 * 
 * 일정 선택 
 * 
 */




//폴터 트리 랜더링
function mobile_schedule_SetScheduleFolderList(){
	if($("#mobile_schedule_treeList").attr("isload") == "Y"){
		return ;
	}
	
	var url = "/groupware/mobile/schedule/getACLLeftFolder.do";
	var sFolderHtml = "";
	var sFolderCommunityHtml = ""; //커뮤니티
	var sFolderThemeHtml = ""; //테마일정
	
	$.ajax({
	    url: url,
	    type: "POST",
	    data: {},
	    async: false,
	    success: function (res) {
	    	
	    	//전체선택
	    	sFolderHtml += "<li class=\"all_chk chk_item\">";
 			sFolderHtml += "		<a href=\"javascript: mobile_schedule_SelectFolderAction();\"><span class=\"rd_chk\"></span>" + mobile_comm_getDic("lbl_selectall") + "</label></a>"; //전체선택
 			sFolderHtml += "</li>";
	    	
	    	if(res.status == "SUCCESS"){
	     		
	     		// 통합일정 목록 세팅
	     		if(res.totalFolder.length > 0){
	     			var folderID = this.FolderID;
	     			
	     			$(res.totalFolder).each(function(){
	     				if(Number(this.SubCount) == 0){
		     				sFolderHtml += "<li class=\"chk_item\" value=\"" + this.FolderID + "\">";
	     					sFolderHtml += "		<a href=\"javascript: mobile_schedule_SelectFolderAction('" + this.FolderID + "')\"><span class=\"rd_chk\" style=\"background-color:" + this.Color + "\"></span>" + this.MultiDisplayName + "</a>";
	     					sFolderHtml += "</li>";
	     				} else {
	     					sFolderHtml += "<li class=\"cate_tit\" value=\"" + this.FolderID + "\" style=\"padding: 5px 15px;\">";
	     					sFolderHtml += "		<span style=\"background-color:" + this.Color + "\"></span>" + this.MultiDisplayName;
	     					sFolderHtml += "</li>";
	     				}    
     					
     					var child = this.child;
	     				if(child.length > 0){
	     					sFolderHtml += "<div class='selOnOffBoxChk type02' id='subFolder_"+this.FolderID+"'>"
	     					var idx = 1;
	     					$(child).each(function(){
	     						if(this.FolderType == "Folder"){
									sFolderHtml += "<li class=\"cate_tit\" value=\"" + this.FolderID + "\" style=\"padding: 5px 15px;\">";
	     							sFolderHtml += "		<span style=\"background-color:" + this.Color + ";margin-left: 25px;\"></span>" + this.MultiDisplayName;
	     							sFolderHtml += "</li>";
								} else {
									if(child.length != idx) {
	     							sFolderHtml += "<li class=\"chk_item\" value=\"" + this.FolderID + "\" style=\"border-bottom: 0px;\">";
		     						} else {
		     							sFolderHtml += "<li class=\"chk_item\" value=\"" + this.FolderID + "\">";
		     						}
			     					sFolderHtml += "		<a href=\"javascript: mobile_schedule_SelectFolderAction('" + this.FolderID + "')\"><span class=\"rd_chk\" style=\"background-color:" + this.Color + ";margin-left: 25px;\"></span>" + this.MultiDisplayName + "</a>";
			     					sFolderHtml += "</li>";
			     					idx ++;
								}
	     					});
	     					
	     					sFolderHtml += "</div>";
	     				}
	     			});
	     		}
	     			
     			// 일정 목록 세팅
	     		if(res.listFolder.length > 0){
	     			$(res.listFolder).each(function(){
	     				var folderID = this.FolderID; 
	     				var folderType = this.FolderType;
	     				var scheduleGoogleFolderID = mobile_comm_getBaseConfig("ScheduleGoogleFolderID", 0);
	     				
	     				if(_mobile_schedule_common.IsConnectGoogle == false && folderID == scheduleGoogleFolderID){
	     				} else if(folderType == "Schedule.Cafe" && this.child.length > 0){
	     					$(this.child).each(function(){
	     						if(this.IsUse == 'Y' && this.IsDisplay == 'Y') {
	     							sFolderCommunityHtml	+= "<li class=\"chk_item\" value=\"" + this.FolderID + "\">";
		     						sFolderCommunityHtml	+= "	<a href=\"javascript: mobile_schedule_SelectFolderAction('" + this.FolderID + "')\">";
		     						sFolderCommunityHtml	+= "		<span class=\"rd_chk\" style=\"background-color:" + this.Color + "\"></span>" + this.MultiDisplayName;
		     						sFolderCommunityHtml	+= "	</a>";
		     						sFolderCommunityHtml	+= "</li>";
	     						}
	     					});
	     				} else if(folderType == "Schedule.Theme" && this.child.length > 0){
	     					$(this.child).each(function(){
	     						if(this.IsUse == 'Y' && this.IsDisplay == 'Y') {
	     							sFolderThemeHtml		+= "<li class=\"chk_item\" value=\"" + this.FolderID + "\">";
			      					sFolderThemeHtml 		+= "	<a href=\"javascript: mobile_schedule_SelectFolderAction('" + this.FolderID + "')\">";
			      					sFolderThemeHtml 		+= "		<span class=\"rd_chk\" style=\"background-color:" + this.Color + "\"></span>" + this.MultiDisplayName;
			      					sFolderThemeHtml 		+= "	</a>";
			      					sFolderThemeHtml 		+= "</li>";
	     						}
	     					});
	      				} else if(folderType != "Schedule.Cafe" && folderType != "Schedule.Theme"){
	      					if(this.IsUse == 'Y' && this.IsDisplay == 'Y') {
	      						sFolderHtml				+= "<li class=\"chk_item\" value=\"" + folderID + "\">";
	      						sFolderHtml				+= "	<a href=\"javascript: mobile_schedule_SelectFolderAction('" + folderID + "')\">";
		      					sFolderHtml				+= "		<span class=\"rd_chk\" style=\"background-color:" + this.Color + "\"></span>" + this.MultiDisplayName;
		      					sFolderHtml				+= "	</a>";
		      					sFolderHtml				+= "</li>";
     						}
	      				}
	     			});
	     		}
		     			
     			$("#mobile_schedule_checklisttotal").html(sFolderHtml);
     			if(sFolderCommunityHtml.length > 0) {
     				sFolderCommunityHtml = "<li class=\"cate_tit\">" + mobile_comm_getDic("BizSection_Community") + "</li>" + sFolderCommunityHtml; //커뮤니티
     				$("#mobile_schedule_checklistcommunity").html(sFolderCommunityHtml).parent().css('display', '');
     			} else {
     				$("#mobile_schedule_checklistcommunity").parent().css('display', 'none');
     			}
     			if(sFolderThemeHtml.length > 0) {
     				sFolderThemeHtml = "<li class=\"cate_tit\">" + mobile_comm_getDic("lbl_schedule_theme") + "</li>" + sFolderThemeHtml; //테마일정
     				$("#mobile_schedule_checklisttheme").html(sFolderThemeHtml).parent().css('display', '');
     			} else {
     				$("#mobile_schedule_checklisttheme").parent().css('display', 'none');
     			}
     			
	     		// 세션에서 선택했던 폴더 값 세팅
     			for (var i=0; i<_mobile_schedule_common.FolderCheckList.split(";").length; i++) {
                    $("#mobile_schedule_treeList").find("li[value='" +_mobile_schedule_common.FolderCheckList.split(";")[i] + "']").addClass("checked");
                }
     			$("#mobile_schedule_treeList").attr("isload","Y");
	    	}else{
	    		alert(mobile_comm_getDic("msg_apv_030"));		// 오류가 발생했습니다.
	    	}
        },
        error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
}

//폴더 선택 시, ui 처리
function mobile_schedule_SelectFolderAction(pFolderID){
	
	if(pFolderID == undefined){ //전체 선택
		if($("li.all_chk").hasClass("checked")){
			$("li:not(:has(>ul))").removeClass("checked");
		} else {
			$("li:not(:has(>ul))").addClass("checked");
		}
	} else { //개별 선택
		var oFolder = $("li[value='" + pFolderID + "']");
		if(oFolder.hasClass("checked")) {
			oFolder.removeClass("checked");
			$("li.all_chk").removeClass("checked");
		} else {
			oFolder.addClass("checked");
		}
	}
	
}

//선택한 폴더 목록 저장 후 이전 페이지로 돌아감
function mobile_schedule_saveFolderSelected(){
	
	//값 초기화
	_mobile_schedule_common.FolderCheckList = ";";
	
	//선택 목록 추출 및 값 바인딩
	$("#schedule_select_content li.checked:not(.all_chk)").each(function() {
		if($(this).attr("value") != undefined){
			_mobile_schedule_common.FolderCheckList += $(this).attr("value") + ";";
		}
	});
	
	//세션에 저장
	localStorage.setItem("ScheduleCheckBox_"+mobile_comm_getSession("UR_Code").toLowerCase(), _mobile_schedule_common.FolderCheckList);
	
	//DB에 저장
	mobile_schedule_saveSchUserFolderSetting(_mobile_schedule_common.FolderCheckList);
	
	//이전 페이지로 되돌아감
	mobile_comm_back();
	mobile_schedule_reloadPrevPage();
}

//
function mobile_schedule_realoadPage(){	
	//값 초기화
	_mobile_schedule_common.FolderCheckList = ";";
	
	//선택 목록 추출 및 값 바인딩	
	$("#mobile_schedule_treeList li.checked:not(.all_chk)").each(function() {
		if($(this).attr("value") != undefined){
			_mobile_schedule_common.FolderCheckList += $(this).attr("value") + ";";
		}
	});
	
	//세션에 저장
	localStorage.setItem("ScheduleCheckBox_"+mobile_comm_getSession("UR_Code").toLowerCase(), _mobile_schedule_common.FolderCheckList);
	
	//DB에 저장
	mobile_schedule_saveSchUserFolderSetting(_mobile_schedule_common.FolderCheckList);
	
	mobile_schedule_reloadPrevPage();
}

//사용자 설정 값 저장
function mobile_schedule_saveSchUserFolderSetting(strFolder){
	
	var url = "/groupware/mobile/schedule/saveSchUserFolderSetting.do";
	$.ajax({
	    url: url,
	    type: "POST",
	    data: {
	    	"schUserFolder" : strFolder,
	    	"UserCode" : mobile_comm_getSession("UR_Code")
		},
	    success: function (res) {
	    	if(res.status != "SUCCESS"){
	    		alert(mobile_comm_getDic("msg_apv_030"));		// 오류가 발생했습니다.
	    	}
	    },
	    error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
	
}

//일정 선택 끝








/*!
 * 
 * 일정 작성
 * 
 */

var _mobile_schedule_write = {
		
		// 리스트 조회 초기 데이터
		Mode: 'D',				// 모드 (D-작성, DU-수정)
		EventID: '',				//이벤트ID
		DateID: '',				//일자ID
		IsRepeat: '',				//반복일정 여부
		FolderID: '',				//폴더ID
		IsCommunity: 'N',		//커뮤니티 여부
		
		//캘린더에서 가져오는 값
		Date: '',					 //기본 시작일 값
		Time: ''					 //기본 시작시간 값	
};

//수정 시 사용(구 updateScheduleDataObj)
var _mobile_schedule_updatescheduleobj;

function mobile_schedule_WriteInit(){
	if(window.sessionStorage["schedule_writeinit"] == undefined)
		window.sessionStorage["schedule_writeinit"] = "Y";
		
	// 1. 파라미터 셋팅
	if (mobile_comm_getQueryString('eventid', 'schedule_write_page') != 'undefined') {
		_mobile_schedule_write.EventID = mobile_comm_getQueryString('eventid', 'schedule_write_page');
		_mobile_schedule_write.Mode = "DU";
	} else {
		_mobile_schedule_write.EventID = '';
		_mobile_schedule_write.Mode = "D";
	}
	if (mobile_comm_getQueryString('dateid', 'schedule_write_page') != 'undefined') {
		_mobile_schedule_write.DateID = mobile_comm_getQueryString('dateid', 'schedule_write_page');
	} else {
		_mobile_schedule_write.DateID = '';
	}
	if (mobile_comm_getQueryString('isrepeat', 'schedule_write_page') != 'undefined') {
		_mobile_schedule_write.IsRepeat = mobile_comm_getQueryString('isrepeat', 'schedule_write_page');
	} else {
		_mobile_schedule_write.IsRepeat = '';
	}
	if (mobile_comm_getQueryString('folderid', 'schedule_write_page') != 'undefined') {
		_mobile_schedule_write.FolderID = mobile_comm_getQueryString('folderid', 'schedule_write_page');
	} else {
		_mobile_schedule_write.FolderID = '';
	}
	if (mobile_comm_getQueryString('iscommunity', 'schedule_write_page') != 'undefined') {
		_mobile_schedule_write.IsCommunity = mobile_comm_getQueryString('iscommunity', 'schedule_write_page');
	} else {
		_mobile_schedule_write.IsCommunity = 'N';
	}
	if (mobile_comm_getQueryString('date', 'schedule_write_page') != 'undefined') {
		_mobile_schedule_write.Date = mobile_schedule_SetDateFormat(new Date(mobile_schedule_ReplaceDate(mobile_comm_getQueryString('date', 'schedule_write_page'))), '.');
	} else {
		_mobile_schedule_write.Date = mobile_schedule_SetDateFormat(_mobile_schedule_common.CurrentTime, '.');
	}
	if (mobile_comm_getQueryString('time', 'schedule_write_page') != 'undefined') {
		_mobile_schedule_write.Time = (mobile_comm_getQueryString('time', 'schedule_write_page').length < 2 ? "0" : "") + mobile_comm_getQueryString('time', 'schedule_write_page') + ":00";
	} else {
		_mobile_schedule_write.Time = '00:00';
	}
	
	// 2. 구글 일정 사용 여부 체크 
	mobile_schedule_chkUseGoogle();
	
	// 3. 목록 바인딩
	mobile_schedule_SetWriteScheduleFolder();
	
	// 4. 일시 바인딩
	mobile_schedule_SetWriteDateTimeSelectBox();
	
	// 5. 수정 모드이면 값 바인딩
	if(_mobile_schedule_write.Mode == "DU"){
		alert(mobile_comm_getDic("msg_board_donotSaveInlineImage"));
		mobile_schedule_getView(_mobile_schedule_write.Mode, _mobile_schedule_write.EventID, _mobile_schedule_write.DateID, _mobile_schedule_write.IsRepeat);
		$("#schedule_write_mode").html(mobile_comm_getDic("lbl_Modify"));
	} else {
		$("#schedule_write_mode").html(mobile_comm_getDic("lbl_Write"));
	}
	
	// 6. 커뮤니티일 경우, selectbox 선택 불가
	if(_mobile_schedule_write.IsCommunity == "Y" && _mobile_schedule_write.FolderID != ""){
		$("#schedule_write_schedulefolder").val(_mobile_schedule_write.FolderID);
		$("#schedule_write_schedulefolder").attr("disabled", "disabled");
	}
	
	// 7. Tab Display 설정
	$("div.tab_wrap").each(function(){
		$(this).children('.g_tab').find('li').first().addClass('on');
		$(this).children('.tab_cont_wrap').find('.tab_cont').first().addClass('on');
	});
	
	// 8. datepicker
	$( ".dates_date" ).datepicker({
		dateFormat : 'yy.mm.dd',
		dayNamesMin : ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
	});
}

//선택 폴더 목록 조회
function mobile_schedule_SetWriteScheduleFolder(){
	
	//권한 있는 모든 폴더 리스트
	var sFolderHtml = "";
	var selectFolderObj;
	
	$.ajax({
	    url: "/groupware/schedule/getACLFolder.do",
	    type: "POST",
	    data: {
	    	"isCommunity" : (_mobile_schedule_write.IsCommunity == "Y" ? true : false)
	    },
	    async: false,
	    success: function (res) {
	    	if(res.status == "SUCCESS"){
				
				for(var i = 0; i<res.create.length; i++){
					if(res.create[i].FolderType == 'Folder'){
						res.create.splice(i,1);
						i--;
					}
				}
				
				// 커뮤니티 연동시 해당 폴더만 보이도록
				if(_mobile_schedule_write.IsCommunity == "Y"){
					selectFolderObj = $$(res).find("create").concat().find("[FolderID=" + mobile_comm_replaceAll(_mobile_schedule_common.FolderCheckList,";", "") +"]").json();
				} else {
					selectFolderObj = $(res.create);
				}
				
				$(selectFolderObj).each(function(i){
					// 구글은 연동되었을 때만
					if(!(_mobile_schedule_common.IsConnectGoogle == false && this.FolderID == mobile_comm_getBaseConfig("ScheduleGoogleFolderID", 0))){
						if(i == 0){
							$("#defaultFolderType").html('<span style="background-color:'+this.Color+'"></span> '+this.MultiDisplayName);
							$("#FolderType").val(this.FolderID);
						}
						sFolderHtml += "<option value=\"" + this.FolderID + "\" type=\"" + this.FolderType + "\">" + this.MultiDisplayName + "</option>";
					}
				});
		     			
     			$("#schedule_write_schedulefolder").html(sFolderHtml);
     			
	    	}else{
	    		alert(mobile_comm_getDic("msg_apv_030"));		// 오류가 발생했습니다.
	    	}
        },
        error:function(response, status, error){
			mobile_comm_ajaxerror("/groupware/schedule/getACLFolder.do", response, status, error);
		}
	});
}

//일시 바인딩
function mobile_schedule_SetWriteDateTimeSelectBox(){
	
	var oToday = _mobile_schedule_write.Date;
	
	//일시 > date
	$("#schedule_write_startday").val(oToday);
	$("#schedule_write_endday").val(oToday);
	
	//일시 > time
	var sTimeHtml = "";
	for(var i=0; i<24; i++){
		for(var j=0; j<60; j+=30){
			sTimeHtml += "<option value='" + (i<10 ? "0"+i : i) + ":" + (j<10 ? "0"+j : j) + "'>" + (i<10 ? "0"+i : i) + ":" + (j<10 ? "0"+j : j) + "</option>";
		}
	}
	$("#schedule_write_starttime").html(sTimeHtml);
	$("#schedule_write_endtime").html(sTimeHtml);
	$("#schedule_write_endtime").append("<option value='23:59'> 23:59 </option>");
	
	$("#schedule_write_starttime").val(_mobile_schedule_write.Time);
	$("#schedule_write_endtime").val(mobile_comm_AddFrontZero(parseInt(_mobile_schedule_write.Time) + 1, 2) + ":00");

	//반복  - 기본 설정
	$("#schedule_write_repeatday_day, #schedule_write_repeatmonth_useday, #schedule_write_repeatyear_useday").prop("checked", true).checkboxradio('refresh');
	$("#schedule_write_repeatday_userepeat, #schedule_write_repeatweek_userepeat, #schedule_write_repeatmonth_userepeat, #schedule_write_repeatyear_userepeat").prop("checked", true).checkboxradio('refresh');   
	var tempEndMonth = (Number(parent.$("#schedule_write_endday").val().split(".")[1])+1) % 12 ;
	var tempEndDate = mobile_schedule_SetDateFormat(new Date(mobile_schedule_ReplaceDate(parent.$("#schedule_write_endday").val().split(".")[0] + "." + (tempEndMonth == 0 ? 12 : tempEndMonth) + "." + parent.$("#schedule_write_endday").val().split(".")[2])));
	$("#schedule_write_repeatday_enddate, #schedule_write_repeatweek_enddate, #schedule_write_repeatmonth_enddate , #schedule_write_repeatyear_enddate").val(tempEndDate);
	
}

//'종일' 선택시 처리
function mobile_schedule_clickallday(){
	if($("#schedule_write_isallday").is(":checked") == true){
		_mobile_schedule_write.TempStartDay = $("#schedule_write_startday").val();
		_mobile_schedule_write.TempEndDay = $("#schedule_write_endday").val();
		_mobile_schedule_write.TempStartTime = $("#schedule_write_starttime").val();
		_mobile_schedule_write.TempEndTime = $("#schedule_write_endtime").val();
		$("#schedule_write_endday").val($("#schedule_write_startday").val());
		$("#schedule_write_starttime").val("00:00");
		$("#schedule_write_endtime").val("23:59");
		$("#schedule_write_startday").attr("disabled", true);
		$("#schedule_write_endday").attr("disabled", true);
		$("#schedule_write_starttime").attr("disabled", true);
		$("#schedule_write_endtime").attr("disabled", true);
	} else {
		$("#schedule_write_startday").val(_mobile_schedule_write.TempStartDay != undefined ? _mobile_schedule_write.TempStartDay : _mobile_schedule_write.Date);
		$("#schedule_write_endday").val(_mobile_schedule_write.TempEndDay != undefined ? _mobile_schedule_write.TempEndDay : _mobile_schedule_write.Date);
		$("#schedule_write_starttime").val(_mobile_schedule_write.TempStartTime != undefined ? _mobile_schedule_write.TempStartTime : '00:00');
		$("#schedule_write_endtime").val(_mobile_schedule_write.TempEndTime != undefined ? _mobile_schedule_write.TempEndTime : '01:00');
		$("#schedule_write_startday").attr("disabled", false);
		$("#schedule_write_endday").attr("disabled", false);
		$("#schedule_write_starttime").attr("disabled", false);
		$("#schedule_write_endtime").attr("disabled", false);
	}
}

//일정 등록
function mobile_schedule_save(){
	/*
	 * D : 상세 등록
	 * U : 수정
	 */
	var mode = _mobile_schedule_write.Mode != "DU" ? "I" : "U";
	var eventObj = {};
	var setType = _mobile_schedule_write.Mode != "DU" ? "D" : "U";
	
	var FolderType = $("#schedule_write_schedulefolder option:selected").attr("type");
	
	eventObj = mobile_schedule_SetSaveInfo(setType);
	
	if(JSON.stringify(eventObj) != "{}"){
		if(FolderType != "Schedule.Google"){
			// Validation 체크
			if(mobile_schedule_CheckValidation(eventObj)){
				var formData = new FormData();
				var url = "/groupware/mobile/schedule/setOne.do";
				
				if ((mobile_comm_getBaseConfig('IsPastSave') == '' || mobile_comm_getBaseConfig('IsPastSave') == 'N')){
					// eventObj 객체에 Date 값을 생성해서 가지고 있을 경우 조건을 확인하여 리소스 제거
					if (eventObj.Date) {
						var startDateTime = eventObj.Date.StartDate + " " + eventObj.Date.StartTime;
						if(parseInt(_mobile_schedule_common.CurrentTime.getTime() / 1000 / 60) > parseInt(new Date(mobile_comm_ReplaceDate(startDateTime)).getTime() / 1000 / 60)){
							if(eventObj.Resource) eventObj.Resource.length = 0;
						}
					}
					
					// 상세입력의 날짜/시간 필드가 존재하는 경우, 조건을 확인하여 리소스 제거
					var sDate = $("#schedule_write_startday").val();
					var sTime = $("#schedule_write_starttime").val();			
					if (parseInt(_mobile_schedule_common.CurrentTime.getTime() / 1000 / 60) > parseInt(new Date(mobile_comm_ReplaceDate(sDate) + " " + sTime).getTime() / 1000 / 60)){
						if(eventObj.Resource) eventObj.Resource.length = 0;
					}
				}

				// bugfix : 반복일정에서 데이터값을 '분' 단위로 변경되지 않아 발생한 이슈 수정
				if(eventObj.Repeat !== undefined) {
					if(eventObj.Repeat.AppointmentDuring !== undefined && eventObj.Repeat.AppointmentDuring.length >= 2) {
						var duringHour = eventObj.Repeat.AppointmentDuring.substring(0, eventObj.Repeat.AppointmentDuring.length - 1)
						eventObj.Repeat.AppointmentDuring = Number(duringHour) * 60; 
					}
				}
				
				// 반복의 개별일정 수정인 경우, 반복정보 제거
				if (mobile_comm_getQueryString('isrepeat', 'schedule_write_page') == 'Y' && mobile_comm_getQueryString('isrepeatall', 'schedule_write_page') != 'Y') {
					if (eventObj.Repeat) delete eventObj.Repeat;
					if (eventObj.RepeatID) delete eventObj.RepeatID;
					setType = "RU";
					mode = "RU";				
				}
				
				if(setType == "RU"){
					var isChangeDate = eventObj.isChangeDate;
					var isChangeRes = eventObj.isChangeResource;
					
					delete eventObj.isChangeDate;
					delete eventObj.isChangeResource;

					/*
					params = {
					    	"mode" : mode,
					    	"eventObj" : JSON.stringify(eventObj),
					    	"isChangeDate" : isChangeDate,
					    	"isChangeRes" : isChangeRes
						};
					*/
					
					// [Added][FileUpload]
					formData.append("mode", mode);
					formData.append("eventObj", JSON.stringify(eventObj));
					formData.append("isChangeDate", isChangeDate);
					formData.append("isChangeRes", isChangeRes);
					
				}else{
					/*
					params = {
				    	"mode" : mode,
				    	"eventObj" : JSON.stringify(eventObj)
					};
					*/
					
					// [Added][FileUpload]
					formData.append("mode", mode);
					formData.append("eventObj", JSON.stringify(eventObj));
				}
				
				// [Added][FileUpload]
				/*
				formData.append("fileInfos", JSON.stringify(coviFile.fileInfos));
			    for (var i = 0; i < coviFile.files.length; i++) {
			    	if (typeof coviFile.files[i] == 'object') {
			    		formData.append("files", coviFile.files[i]);
			        }
			    }
			    formData.append("fileCnt", coviFile.fileInfos.length);
			    */
				formData.append("fileInfos", "");
				formData.append("files", null);
			    formData.append("fileCnt", 0);
			    
			    var targetBtnEvent = $("#schedule_write_save").attr("href");		// 요소의 이벤트 정보 (에러 처리시 재설정 하기 위함)
			    
				$.ajax({
				    url: url,
				    type: "POST",
					data: formData,
				    processData : false,
			        contentType : false,
			        beforeSend: function () { 
						$("#schedule_write_save").attr("href", "#");
						mobile_comm_showload();
					},
			        complete: function () { mobile_comm_hideload() },
				    success: function (res) {
				    	if(res.status == "SUCCESS" && res.result == "OK"){
				    		window.sessionStorage.removeItem('schedule_writeinit');
				    		
				    		mobile_comm_back();
				    		if($("#schedule_view_page").attr("IsLoad") == "Y"){
				    			mobile_schedule_ViewInit();
				    		}				    		
				    		
				    		$("#schedule_view_page").remove();
				    		
				    		mobile_schedule_reloadPrevPage();
				    	}
				    	else if(res.status == "SUCCESS" && res.result == "DUPLICATION"){
				    		$("#schedule_write_save").attr("href", targetBtnEvent);
				    		alert(mobile_comm_getDic("msg_ResourceManage_26")); // 자원을 예약할 수 없습니다. 동일한 예약기간에 이미 사용되고 있습니다.
				    	}
				    	else {
				    		$("#schedule_write_save").attr("href", targetBtnEvent);
				    		alert(mobile_comm_getDic("msg_apv_030"));		// 오류가 발생했습니다.
				    	}
				    },
				    error:function(response, status, error){
						$("#schedule_write_save").attr("href", targetBtnEvent);
						mobile_comm_ajaxerror(url, response, status, error);
					}
				});
			}
		}
		else{
			// 구글 연동 일정 등록
			if(mode == "I"){
				alert(mobile_comm_getDic("msg_registerGoogleSch").split(".")[0]); //구글 캘린더에 일정이 등록됩니다.
				mobile_schedule_CoverInsertGoogleEventData(setType, eventObj, "I");
			}
			// 구글 연동 일정 수정
			else if(mode == "U"){
				alert(mobile_comm_getDic("msg_changeGoogleSch").split(".")[0]); //구글 캘린더에 있는 일정이 수정됩니다.
				mobile_schedule_CoverInsertGoogleEventData(setType, eventObj, "U");
			}
		}
	}
	else{
		alert(mobile_comm_getDic("msg_117")); //성공적으로 저장하였습니다.
		
		mobile_comm_back();
		mobile_schedule_reloadPrevPage();
	}
}

function mobile_schedule_SetSaveInfo(setType){
	
	var eventObj = {};
	var event = {};
	var date = {};
	var resource = new Array();
	var repeat = {};
	var attendee = new Array();
	var notification = {};
	
	// 사용자 입력값
	event.FolderID = $("#schedule_write_schedulefolder").val();
	event.FolderType = $("#schedule_write_schedulefolder").find("option:selected").attr("type");
	event.LinkEventID = "";						//TODO 상황에 따라 다른값에 대해서 처리 필요
	event.MasterEventID = "";					//TODO 상황에 따라 다른값에 대해서 처리 필요
	event.Subject = $("#schedule_write_subject").val().split(' ').join('&nbsp;').replace(/(\r\n|\n|\n\n)/gi, '<br />');
	event.OwnerCode = mobile_comm_getSession("UR_Code");			//TODO 상황에 따라 다른값에 대해서 처리 필요
	event.RegisterCode = mobile_comm_getSession("UR_Code");
	event.MultiRegisterName = mobile_comm_getSession("USERNAME");			//TODO
	event.ModifierCode = mobile_comm_getSession("UR_Code");
	event.Place = $("#txtPlace").val();		//TODO : 장소
	event.IsPublic = $("#schedule_write_ispublic").hasClass("on") ? "N" : "Y";
	event.IsDisplay = "Y";
	event.IsInviteOther = $("#schedule_write_isinviteother").is(":checked") ? "Y" : "N";
	event.ImportanceState = $("#schedule_write_isimportantstate").hasClass("on") == true ? "Y" : "N";
	event.Description = $("#schedule_write_description").val().split(' ').join('&nbsp;');
	event.InlineImage = '';
	
	if(event.FolderType == "Schedule.Person"){
		event.OwnerCode =  mobile_comm_getSession("UR_Code");
	}

	// EventType
	/* TODO
	 * M: 반복일정 중 개별일정 , A: 개인일정(참석자가 승인하여 생긴 개인일정), F: 자주 쓰는 일정
	 */
	event.EventType = "";

	if($("#schedule_write_repeat li.on").attr("value") == "" || $("#schedule_write_repeat li.on").attr("value") == "N" || $("#schedule_write_repeat li.on").attr("value") == undefined || $("#schedule_write_repeatChk").hasClass("on") == false){
		date.RepeatID = mobile_comm_getQueryString("repeatid", "schedule_write_page");
		date.StartDate = mobile_comm_replaceAll(mobile_comm_replaceAll($("#schedule_write_startday").val(), "/", "-"), ".", "-"); // 모든 '/'과 '.'을 '-'으로 변경
		date.EndDate = mobile_comm_replaceAll(mobile_comm_replaceAll($("#schedule_write_endday").val(), "/", "-"), ".", "-"); // 모든 '/'과 '.'을 '-'으로 변경
		date.StartTime = $("#schedule_write_starttime").val();
		date.EndTime = $("#schedule_write_endtime").val();
		date.IsAllDay = $("#schedule_write_isallday").is(":checked")  ? "Y" : "N";
		date.IsRepeat = "N";
		
		repeat = {};
	}else{
		date.RepeatID = mobile_comm_getQueryString("repeatid", "schedule_write_page");
		date.StartDate = mobile_comm_replaceAll(mobile_comm_replaceAll($("#schedule_write_startday").val(), "/", "-"), ".", "-"); // 모든 '/'과 '.'을 '-'으로 변경
		date.EndDate = mobile_comm_replaceAll(mobile_comm_replaceAll($("#schedule_write_endday").val(), "/", "-"), ".", "-"); // 모든 '/'과 '.'을 '-'으로 변경
		date.StartTime = $("#schedule_write_starttime").val();
		date.EndTime = $("#schedule_write_endtime").val();
		date.IsAllDay = $("#schedule_write_isallday").is(":checked")  ? "Y" : "N";
		date.IsRepeat = "Y";
		
		repeat = mobile_schedule_GetRepeatData();
	}
	
	//알림
	if ($("#BtnAlims_wrap").hasClass("on") == true){
		notification.IsNotification = "Y";
		notification.IsReminder = $("#schedule_write_notice_reminderYN").hasClass("on") ? "Y" : "N";
		notification.ReminderTime = $("#schedule_write_notice_remindertime option:selected").val();
		notification.IsCommentNotification = $("#schedule_write_notice_commentYN").hasClass("on") ? "Y" : "N";
		notification.MediumKind = "";
	} else {
		notification.IsNotification = "N";
		notification.IsReminder = "N";
		notification.ReminderTime = $("#schedule_write_notice_remindertime option:selected").val();
		notification.IsCommentNotification = "N";
		notification.MediumKind = "";
	}

	//resource
	var selectResource = $("#resourcesSelect_wrapArea a");
	$(selectResource).each(function(){
		var resourceObj = {};
		var resourceInfo = $.parseJSON($(this).attr("data-json"));
		
		resourceObj.FolderID = resourceInfo.value;
		resourceObj.ResourceName = resourceInfo.label;
		resourceObj.LeastRentalTime = resourceInfo.leastRentalTime;
		
		resource.push(resourceObj);
	});
	
	//attendee
	var selectAttendee = $("#joins_wrapArea a");
	$(selectAttendee).each(function(){
		var attendeeObj = {};
		var attendeeInfo = $.parseJSON($(this).attr("data-json"));
		
		attendeeObj.UserName = attendeeInfo.label;
		if(this.value == "undefined" || attendeeInfo.value == ""){
			attendeeObj.UserCode = "";
			attendeeObj.IsOutsider = "Y";
			attendeeObj.IsAllow = "N";
		}else{
			attendeeObj.UserCode = attendeeInfo.value.split("|")[0];
			attendeeObj.IsAllow = attendeeInfo.value.split("|")[1] == undefined ? "" : attendeeInfo.value.split("|")[1];
			attendeeObj.IsOutsider = "N";
		}
		attendeeObj.dataType = "NEW";
		attendee.push(attendeeObj);
	});
	
	eventObj.Event = event;
	eventObj.Date = date;
	eventObj.Resource = resource;
	eventObj.Repeat = repeat;
	eventObj.Attendee = attendee;
	eventObj.Notification = notification;
	
	// 수정할 경우
	if(setType == "U"){
		if(_mobile_schedule_updatescheduleobj.IsGoogle == undefined){
			// 구글일 경우 비교하지 않음
			
			// 비교에 불필요한 키 삭제
			$(_mobile_schedule_updatescheduleobj).find("Event").detach("FolderName");
			$(_mobile_schedule_updatescheduleobj).find("Event").detach("FolderColor");
			$(_mobile_schedule_updatescheduleobj).find("Event").detach("RegisterData");
			$(_mobile_schedule_updatescheduleobj).find("Event").detach("RegisterDept");
			$(_mobile_schedule_updatescheduleobj).find("Event").detach("RegisterPhoto");
			$(_mobile_schedule_updatescheduleobj).find("Event").detach("RegistDate");
			$(_mobile_schedule_updatescheduleobj).find("Event").detach("MailAddress");
			if($(_mobile_schedule_updatescheduleobj).find("Resource").length > 0) {
				$(_mobile_schedule_updatescheduleobj).find("Resource").concat().detach("TypeName");	
			}
			if($(_mobile_schedule_updatescheduleobj).find("Attendee").length > 0){
				$(_mobile_schedule_updatescheduleobj).find("Attendee").concat().detach("DeptCode");
				$(_mobile_schedule_updatescheduleobj).find("Attendee").concat().detach("DeptName");	
			}
			
			$(_mobile_schedule_updatescheduleobj).find("NotiComment").detach();

			$(eventObj).find("Event").detach("IsDisplay");
			
			//TODO 반복 관련 추가 개발 필요
			if($(_mobile_schedule_updatescheduleobj).find("Date").attr("IsRepeat") == "Y" && $(eventObj).find("Date").attr("IsRepeat") == "Y"){
				//$$(_mobile_schedule_updatescheduleobj).find("Date").detach();
				//$$(eventObj).find("Date").detach();
				
				//var resourceRepeat = {"ResourceRepeat" : {}};
				//$$(resourceRepeat).find("ResourceRepeat").append($$(_mobile_schedule_updatescheduleobj).find("Repeat").json());
				//$$(_mobile_schedule_updatescheduleobj).find("Repeat").detach();
				//$$(_mobile_schedule_updatescheduleobj).append("Repeat", $$(resourceRepeat).json()).json();
			}else{
				$(_mobile_schedule_updatescheduleobj).find("Repeat").detach();
				$(eventObj).find("Repeat").detach();
			}
			
			// eventObj와 _mobile_schedule_updatescheduleobj 비교
			eventObj = mobile_schedule_CompareEventObject(eventObj, _mobile_schedule_updatescheduleobj);
			
			// 참석자 데이터 별도 비교 필요
			if(eventObj.Attendee != undefined){
				var oldData = _mobile_schedule_updatescheduleobj.Attendee;
				var newData = attendee;
				var delArray = new Array();
				var isModify = false;
				var isAdd = false;
				
				$(oldData).each(function(i, oObj){
					isAdd = false;
					$(newData).each(function(j, nObj){
						if(oObj.dataType == "OLD" && oObj.UserCode == nObj.UserCode && oObj.UserName == nObj.UserName){
							nObj.dataType = "OLD";
							if(oObj.IsAllow != nObj.IsAllow){
								nObj.IsAllow = oObj.IsAllow;
								nObj.dataType = "NEW";
							}
							isAdd = true;
							return false;
						}
					});
					if(!isAdd){
						oObj.dataType = "DEL";
						delArray.push(oObj);
					}
				});
				
				newData = newData.concat(delArray);
				$(newData).each(function(){
					if(this.dataType == "NEW" || this.dataType == "DEL"){
						isModify = true;
						return false;
					}
				});
				
				if(isModify)
					eventObj.Attendee = newData;
				else
					$(eventObj).detach("Attendee");
			}
		}
		eventObj.EventID = mobile_comm_getQueryString("eventid", "schedule_write_page");
		eventObj.DateID = mobile_comm_getQueryString("dateid", "schedule_write_page");
		eventObj.RepeatID = mobile_comm_getQueryString("repeatid", "schedule_write_page");
		eventObj.RegisterCode = event.RegisterCode;

		// 미리알림을 위한 데이터
		eventObj.Subject = eventObj.Event == undefined ? _mobile_schedule_updatescheduleobj.Event.Subject : eventObj.Event.Subject;
		eventObj.FolderID = eventObj.FolderID == undefined ? _mobile_schedule_updatescheduleobj.Event.FolderID : eventObj.Event.FolderID;
	}
	
	return eventObj;
}

//Validation Check
function mobile_schedule_CheckValidation(eventObj){
	
	// 자원 선택 여부 체크
	if(eventObj.Event != undefined){
		var folder = eventObj.Event.FolderID;
		if(folder == undefined || folder == ""){
			alert(mobile_comm_getDic("msg_Sch_020")); //구분을 선택해주세요.
			return false;
		}
		
		// 제목 입력 여부 체크
		var subject = eventObj.Event.Subject;
		if(subject == undefined || subject == ""){
			alert(mobile_comm_getDic("msg_board_enterTitle")); //제목을 입력해주세요
			return false;
		}
	}
	
	if(eventObj.Date != undefined) {
		
		var startDate;
		var endDate;
		
		if($("#schedule_write_startday").val() > $("#schedule_write_endday").val()){
			alert(mobile_comm_getDic("msg_StartDateCannotAfterEndDate"));	//시작일은 종료일보다 이후일 수 없습니다.
			return false;
		} else if($("#schedule_write_startday").val() == $("#schedule_write_endday").val()){
			if($("#schedule_write_starttime").val() > $("#schedule_write_endtime").val()){
				alert(mobile_comm_getDic("msg_Mobile_InvalidStartTime"));	//시작시간이 종료시간보다 클 수 없습니다.
				return false;
			}
		}
		
		if(eventObj.Date.IsRepeat != undefined && eventObj.Date.IsRepeat == "Y") {
			
			// 반복 시작일자/종료일자 입력 여부 체크
			startDate = eventObj.Repeat.RepeatStartDate;
			endDate = eventObj.Repeat.RepeatEndDate;
			
			if(startDate == undefined || startDate == "" || endDate == undefined || endDate == "") {
				alert(mobile_comm_getDic("msg_RepeatSetting_08"));		//반복범위 설정이 잘 못 되었습니다. 시작/끝 날짜를 확인하여 주십시오.
				return false;
			}
			// 날짜 입력값 검증
			try {
				var dtStart = new Date(startDate);
				var dtEnd = new Date(endDate);
				if((dtStart.getDate() + "") == "NaN" || (dtEnd.getDate() + "") == "NaN") {
					alert(mobile_comm_getDic("msg_InValidDateInput"));		//날짜 입력값이 잘못 되었습니다.
					return false;
				}
			} catch (e) {
				alert(mobile_comm_getDic("msg_InValidDateInput"));		//날짜 입력값이 잘못 되었습니다.
				return false;
			}
			
			var limitRepeatCount = Number(mobile_comm_getBaseConfig("RepeatCount"));	// 반복 제한 횟수
			limitRepeatCount = limitRepeatCount ? limitRepeatCount : 100;
			var eventRepeatCount = eventObj.Repeat.RepeatCount;
			
			if(eventRepeatCount > limitRepeatCount){
				alert(mobile_comm_getDic("msg_ValidRepeatCount").replace("{0}", limitRepeatCount).replaceAll('</br>', '\n'));	// 설정된 최대 반복 횟수를 초과했습니다. </br> 반복 횟수를 확인하여 주십시오. </br> 최대 반복 횟수: {0}
				return false;
			}
		} else {
			// 시작일자 입력 여부 체크
			startDate = eventObj.Date.StartDate;
			if(startDate == undefined || startDate == "") {
				alert(mobile_comm_getDic("msg_EnterStartDate"));		//시작 일자를 입력하세요
				return false;
			}
			// 종료일자 입력 여부 체크
			endDate = eventObj.Date.EndDate;
			if(endDate == undefined || endDate == "") {
				alert(mobile_comm_getDic("msg_EnterEndDate"));		//종료 일자를 입력하세요
				return false;
			}
		}
		
		// 최소 대여기간 체크
		var startDateTime = eventObj.Date.StartDate + " " + eventObj.Date.StartTime;
		var endDateTime = eventObj.Date.EndDate + " " + eventObj.Date.EndTime;
		if (eventObj.IsRepeat == 'Y'){
			startDateTime = CFN_GetLocalCurrentDate(_ServerDateSimpleFormat) + " " + eventObj.Repeat.AppointmentStartTime;
			if (eventObj.Repeat.AppointmentStartTime > eventObj.Repeat.AppointmentEndTime){
				endDateTime = schedule_SetDateFormat(mobile_schedule_AddDays(CFN_GetLocalCurrentDate(_ServerDateSimpleFormat), 1),'-') + " " + eventObj.Repeat.AppointmentEndTime;
			} else {
				endDateTime = CFN_GetLocalCurrentDate(_ServerDateSimpleFormat) + " " + eventObj.Repeat.AppointmentEndTime;
			}
		}
		var rentalTime = parseInt(new Date(mobile_schedule_ReplaceDate(endDateTime)).getTime() / 1000 / 60) - parseInt(new Date(mobile_schedule_ReplaceDate(startDateTime)).getTime() / 1000 / 60);
		var leastRentalTimeResource = (function(){
			var maxLeastRentalTime = 0;
			var resourceName = '';
			if (typeof eventObj.Resource == 'object') {
				$.each(eventObj.Resource, function(_idx, el){
					if (maxLeastRentalTime < el.LeastRentalTime) {
						maxLeastRentalTime = el.LeastRentalTime;	
						resourceName = el.ResourceName;
					}
				});
			}
			return { time: maxLeastRentalTime, resource: resourceName };
		}());
		if(rentalTime < leastRentalTimeResource.time){
			var leastRentalTimeStr = '';
			if(leastRentalTimeResource.time < 60){
				leastRentalTimeStr = leastRentalTimeResource.time + mobile_comm_getDic("lbl_Minutes"); // 분
			}else{
				leastRentalTimeStr = Math.floor(leastRentalTimeResource.time/60) + mobile_comm_getDic("lbl_Time"); // 시간
				if(leastRentalTimeResource.time % 60 != 0){
					leastRentalTimeStr += " " + (leastRentalTimeResource.time % 60) + mobile_comm_getDic("lbl_Minutes"); // 분
				}
			}
			alert('['+ leastRentalTimeResource.resource +'] ' + mobile_comm_getDic("msg_cannotLeastRentalTimeBefore").replace("{0}", leastRentalTimeStr).replace('<br/>', '\n')); // 최소 대여기간보다 적게 예약할 수 없습니다.<br/>{0} 이상 예약해주세요.
			return false;
		}
	}
	
	/*
	//TODO
	//반복일정 선택
	var sRepeatType = $("#schedule_write_repeat").val();
		
	var nRepeatValue = 0;
	switch (sRepeatType.toUpperCase()) {
	case "D":
		if ( !($("#schedule_write_repeatday_day").is(":checked") && $("#schedule_write_repeatday_dayvalue") == "0") || !($("#schedule_write_repeatday_all").is(":checked")) ) {
			return "반복설정의 반복 일을 입력하여 주십시오.|txtRepeatDay";	
		}
		if ( !($("#schedule_write_repeatday_useenddate").is(":checked") && $("#schedule_write_repeatday_enddate") == "") ||  !($("#schedule_write_repeatday_userepeat").is(":checked") && $("#schedule_write_repeatday_repeatcnt") == "") ) {
			return "반복설정의 반복 일을 입력하여 주십시오.|txtRepeatDay";	
		}
		break;
	case "W":
		if ((isNaN(new Number($("#schedule_write_repeatweek_week").val()))) || ($("#schedule_write_repeatweek_week").val() == "") || ($("#schedule_write_repeatweek_week").val() == "0")) {
			return "반복설정의 반복 주를 입력하여 주십시오.|txtRepeatWeek";			<%-- mobile_comm_getDic("msg_RepeatSetting_04") + "|<%=txtRepeatWeek_W_1.ClientID%>";  // 반복설정의 반복 주를 입력하여 주십시오. --%>
		}
		if ($("#schedule_write_repeatweek_day a.on").length <= 0) {
			return "반복설정의 반복 요일을 선택하여 주십시오."; 		//mobile_comm_getDic("msg_RepeatSetting_05"); // 반복설정의 반복 요일을 선택하여 주십시오.
		}
		break;
    case "M":
    	if( $("#schedule_write_repeatweek_week") == "1" )
    	if ($("#rdoRepeatMonth_day").is(":checked")) {
    		// 날짜
    		if ((isNaN(new Number($("#txtRepeatMonth_M").val()))) || ($("#txtRepeatMonth_M").val() == "") || ($("#txtRepeatMonth_M").val() == "0")) {
    			return "반복설정의 반복 월을 입력하여 주십시오.|txtRepeatMonth_M";		<%-- mobile_comm_getDic("msg_RepeatSetting_06") + "|<%=txtRepeatMonth_M_1.ClientID%>"; // 반복설정의 반복 월을 입력하여 주십시오. --%>
            }
    		if ((isNaN(new Number($("#txtRepeatMonth_D").val()))) || ($("#txtRepeatMonth_D").val() == "") || ($("#txtRepeatMonth_D").val() == "0")) {
    			return "반복설정의 반복 일을 입력하여 주십시오.|txtRepeatMonth_D";		<%-- mobile_comm_getDic("msg_RepeatSetting_01") + "|<%=txtRepeatMonth_D_1.ClientID%>"; // 반복설정의 반복 일을 입력하여 주십시오. --%>
    		}
    	}
    	else {
    		// 요일
    		if ((isNaN(new Number($("#txtRepeatMonth_weekofday_M").val()))) || ($("#txtRepeatMonth_weekofday_M").val() == "") || ($("#txtRepeatMonth_weekofday_M").val() == "0")) {
    			return "반복설정의 반복 월을 입력하여 주십시오.|txtRepeatMonth_weekofday_M";		<%-- mobile_comm_getDic("msg_RepeatSetting_06") + "|<%=txtRepeatMonth_M_2.ClientID%>"; // 반복설정의 반복 월을 입력하여 주십시오. --%>
    		}
    	}
    	break;
    case "Y":
    	if ((isNaN(new Number($("#txtRepeatYear").val()))) || ($("#txtRepeatYear").val() == "") || ($("#txtRepeatYear").val() == "0")) {
    		return "반복설정의 반복 년을 입력하여 주십시오.|txtRepeatYear";			<%-- mobile_comm_getDic("msg_RepeatSetting_07") + "|<%=txtRepeatYear_Y_1.ClientID%>"; // 반복설정의 반복 년을 입력하여 주십시오. --%>
    	}
    	if ($("#rdoRepeatYear_day").is(":checked")) {
    		// 날짜
    		if ((isNaN(new Number($("#txtRepeatYear_D").val()))) || ($("#txtRepeatYear_D").val() == "") || ($("#txtRepeatYear_D").val() == "0")) {
    			return "반복설정의 반복 일을 입력하여 주십시오.|txtRepeatYear_D";		<%-- mobile_comm_getDic("msg_RepeatSetting_01") + "|<%=txtRepeatYear_D_1.ClientID%>"; // 반복설정의 반복 일을 입력하여 주십시오. --%>
    		}
    	}
    	break;
    }
	
	if ($("#schedule_write_repeatday_userepeat").is(":checked")) {
		if ((isNaN(new Number($("#schedule_write_repeatday_repeatcnt").val()))) || ($("#schedule_write_repeatday_repeatcnt").val() == "") || ($("#schedule_write_repeatday_repeatcnt").val() == "0")) {
			return "반복범위 설정이 잘못 되었습니다. 반복 횟수를 확인하여 주십시오.|txtRepeatEndCount";					<%-- mobile_comm_getDic("msg_RepeatSetting_09") + "|<%=txtRepeatCount.ClientID%>"; // 반복범위 설정이 잘 못 되었습니다. 반복 횟수를 확인하여 주십시오. --%>
		}
	}
	return returnVal;
	*/
	
	return true;
}

//수정시 데이터 비교
function mobile_schedule_CompareEventObject(eventObj, updateObj){
	var updateReturnObj = {};
	var tempEventObj = {};
	var tempUpdateObj = {};
	var tempArr;
	
	Object.keys(eventObj).forEach(function(key1) {
		tempEventObj[key1] = {};
		tempUpdateObj[key1] = {};
		
		if(eventObj[key1][0] != undefined){
			tempArr = new Array();
			
			if(typeof eventObj[key1] == "object"){
				$$(eventObj[key1]).concat().each(function(i){
					var tempArrObj = {};
					Object.keys(eventObj[key1][i]).sort().forEach(function(key2) {
						$$(tempArrObj).attr(key2, $$(eventObj[key1][i]).attr(key2));
					});
					tempArr.push(tempArrObj);
				});
				tempEventObj[key1] = tempArr;
			}else{
				tempEventObj[key1] = eventObj[key1];
			}
			
		}else{
			Object.keys(eventObj[key1]).sort().forEach(function(key2) {
				$$(tempEventObj[key1]).attr(key2, $$(eventObj[key1]).attr(key2));
			});
		}
		
		if(updateObj[key1][0] != undefined){
			tempArr = new Array();
			
			if(typeof updateObj[key1] == "object"){
				$$(updateObj[key1]).concat().each(function(i){
					var tempArrObj = {};
					Object.keys(updateObj[key1][i]).sort().forEach(function(key2) {
						$$(tempArrObj).attr(key2, $$(updateObj[key1][i]).attr(key2));
					});
					tempArr.push(tempArrObj);
				});
				tempUpdateObj[key1] = tempArr;
			}else{
				tempUpdateObj[key1] = updateObj[key1];
			}
		}else{
			Object.keys(updateObj[key1]).sort().forEach(function(key2) {
				$$(tempUpdateObj[key1]).attr(key2, $$(updateObj[key1]).attr(key2));
			});
		}
		
		if(JSON.stringify(tempUpdateObj[key1]) != JSON.stringify(tempEventObj[key1])){
			updateReturnObj[key1] = tempEventObj[key1];
		}
	});
	
	return updateReturnObj;
}

//구글 일정 등록 데이터 가공
function mobile_schedule_CoverInsertGoogleEventData(setType, eventObj, mode){
	var resultObj = {};
	
	// 제목
	resultObj.summary = eventObj.Event.Subject.split('&nbsp;').join(' ').replace('<br />', /(\r\n|\n|\n\n)/gi);
	
	// 시작일 종료일
	resultObj.start = {};
	resultObj.end = {};
	if(eventObj.Date.IsAllDay == undefined || eventObj.Date.IsAllDay == "N"){
		resultObj.start.dateTime = new Date(mobile_schedule_ReplaceDate(eventObj.Date.StartDate) + " " + eventObj.Date.StartTime).toISOString();
		resultObj.end.dateTime = new Date(mobile_schedule_ReplaceDate(eventObj.Date.EndDate) + " " + eventObj.Date.EndTime).toISOString();
	}else{
		resultObj.start.date = eventObj.Date.StartDate;
		resultObj.end.date = eventObj.Date.EndDate;
	}
	
	// 참석자
	if(eventObj.Attendee.length > 0){
		var attendee = new Array();
		$(eventObj.Attendee).each(function(){
			if(this.IsOutsider == "Y"){
				attendee.push({
					"email" : this.UserName,
					"responseStatus": "needsAction"
				});
			}
		});
		
		// 자신의 데이터
		attendee.push({
			"email": googleEmail,
	         "displayName": mobile_comm_getSession("USERNAME"),
	         "organizer": true,
	         "self": true,
	         "responseStatus": "accepted"
		});
		
		resultObj.attendees = attendee;
	}
	
	// 설명
	resultObj.description = eventObj.Event.Description.split('&nbsp;').join(' ').replace('<br />', /(\r\n|\n|\n\n)/gi);
	
	// 장소
	resultObj.location = eventObj.Event.Place;
	
	//반복 TODO
	
	if(mode == "I"){
		mobile_schedule_InsertGoogleEventData(setType, resultObj);
	}
	else if(mode == "U"){
		mobile_schedule_UpdateGoogleEventData(setType, resultObj, eventObj.EventID);
	}
}

//구글 일정 등록
function mobile_schedule_InsertGoogleEventData(setType, eventObj){
	var url = "/covicore/oauth2/client/callGoogleRestAPI.do";
	var params = eventObj;
	
	$.ajax({
	    url: url,
	    type: "POST",
	    data: {
	    	"url" : "https://www.googleapis.com/calendar/v3/calendars/primary/events",
	    	"type" : "POST",
	    	"userCode" : mobile_comm_getSession("USERID"),
	    	"params" : JSON.stringify(params)
	    },
	    success: function (res) {
	    	if(res.status == "200"){
	    		alert(mobile_comm_getDic("msg_117")); //성공적으로 저장하였습니다.
	    		//이전 페이지로 되돌아감
	    		mobile_comm_back();
	    		mobile_schedule_reloadPrevPage();
	    	}else{
	    		alert(mobile_comm_getDic("msg_apv_030"));		// 오류가 발생했습니다.
	    	}
        },
        error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
}

//구글 일정 수정
function mobile_schedule_UpdateGoogleEventData(setType, eventObj, eventID){
	var url = "/covicore/oauth2/client/callGoogleRestAPI.do";
	var params = eventObj;

	$.ajax({
	    url: url,
	    type: "POST",
	    data: {
	    	"url" : "https://www.googleapis.com/calendar/v3/calendars/primary/events/"+eventID,
	    	"type" : "PUT",
	    	"userCode" : mobile_comm_getSession("USERID"),
	    	"params" : JSON.stringify(params)
	    },
	    success: function (res) {
	    	if(res.status == "200"){
	    		if(setType == "DD"){
    				if(_mobile_schedule_common.ViewType == "M"){
    					mobile_schedule_MakeMonthCalendar();
    				}else if(_mobile_schedule_common.ViewType == "D"){
    					mobile_schedule_MakeDayCalendar();
    				}else if(_mobile_schedule_common.ViewType == "W"){
    					mobile_schedule_MakeWeekCalendar();
    				}
    			}else{
    				alert(mobile_comm_getDic("msg_117")); //성공적으로 저장하였습니다.
    				//이전 페이지로 되돌아감
    				mobile_comm_back();
    				mobile_schedule_reloadPrevPage();
    			}
	    	}else{
	    		alert(mobile_comm_getDic("msg_apv_030"));		// 오류가 발생했습니다.
	    	}
        },
        error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
}

//반복일정 정보가져오기
function mobile_schedule_GetRepeatData(){
	var sTemp = "";
	var sAppointmentStartTime = $("#schedule_write_starttime").val();
	var sAppointmentEndTime = $("#schedule_write_endtime").val();
	var sAppointmentDuring = "0";
	var sRepeatType = $("#schedule_write_repeat li.on").attr("value") == undefined ? "" : $("#schedule_write_repeat li.on").attr("value");
	var sRepeatYear = "0";
	var sRepeatMonth = "0";
	var sRepeatWeek = "0";
	var sRepeatDay = "1";
	var sRepeatMonday = "N";
	var sRepeatTuesday = "N";
	var sRepeatWednseday = "N";
	var sRepeatThursday = "N";
	var sRepeatFriday = "N";
	var sRepeatSaturday = "N";
	var sRepeatSunday = "N";
	var sRepeatStartDate = mobile_comm_replaceAll(mobile_comm_replaceAll($("#schedule_write_startday").val(), "/", "-"), ".", "-"); // 모든 '/'과 '.'을 '-'으로 변경
	var sRepeatEndDate = mobile_comm_replaceAll(mobile_comm_replaceAll($("#schedule_write_endday").val(), "/", "-"), ".", "-"); // 모든 '/'과 '.'을 '-'으로 변경
	var sRepeatEndType = "R";
	var sRepeatCount = "0";
	
	switch (sRepeatType.toUpperCase()) {
		case "D":
			if ($("#schedule_write_repeatday_day").is(":checked")) {
				sRepeatDay = $("#schedule_write_repeatday_dayvalue").val();
			} else {
				sRepeatDay = "0";
				sRepeatMonday = "Y";
				sRepeatTuesday = "Y";
				sRepeatWednseday = "Y";
				sRepeatThursday = "Y";
				sRepeatFriday = "Y";
			}
			sRepeatStartDate = mobile_comm_replaceAll(mobile_comm_replaceAll($("#schedule_write_repeatday_startdate").val(), "/", "-"), ".", "-"); // 모든 '/'과 '.'을 '-'으로 변경
			sRepeatEndDate = mobile_comm_replaceAll(mobile_comm_replaceAll($("#schedule_write_repeatday_enddate").val(), "/", "-"), ".", "-"); // 모든 '/'과 '.'을 '-'으로 변경
			break;
		case "W":
			sRepeatWeek = $("#schedule_write_repeatweek_week").val();
			if ($("#schedule_write_repeatweek_sun").hasClass("on")) { sRepeatSunday = "Y"; }
			if ($("#schedule_write_repeatweek_mon").hasClass("on")) { sRepeatMonday = "Y"; }
			if ($("#schedule_write_repeatweek_tue").hasClass("on")) { sRepeatTuesday = "Y"; }
			if ($("#schedule_write_repeatweek_wed").hasClass("on")) { sRepeatWednseday = "Y"; }
			if ($("#schedule_write_repeatweek_thu").hasClass("on")) { sRepeatThursday = "Y"; }
			if ($("#schedule_write_repeatweek_fri").hasClass("on")) { sRepeatFriday = "Y"; }
			if ($("#schedule_write_repeatweek_sat").hasClass("on")) { sRepeatSaturday = "Y"; }
			sRepeatStartDate = mobile_comm_replaceAll(mobile_comm_replaceAll($("#schedule_write_repeatweek_startdate").val(), "/", "-"), ".", "-"); // 모든 '/'과 '.'을 '-'으로 변경
			sRepeatEndDate = mobile_comm_replaceAll(mobile_comm_replaceAll($("#schedule_write_repeatweek_enddate").val(), "/", "-"), ".", "-"); // 모든 '/'과 '.'을 '-'으로 변경
			break;
		case "M":
			sRepeatMonth = $("#schedule_write_repeatmonth_month").val();
			if ($("#schedule_write_repeatmonth_useday").is(":checked")) {
				sRepeatDay = $("#schedule_write_repeatmonth_day").val();
			} else {
				sRepeatWeek = $("#schedule_write_repeatmonth_dayword1 option:selected").val();
				sRepeatDay = "0";
				
				sTemp = $("#schedule_write_repeatmonth_dayword2 option:selected").val();
				switch (sTemp.toUpperCase()) {
					case "DAY":
						if ($("#schedule_write_repeatmonth_month").val() != "5") {
							sRepeatWeek = "0";
							sRepeatDay = $("#schedule_write_repeatmonth_month").val();
						}
						break;
					case "WEEKDAY":
						sRepeatMonday = "Y";
						sRepeatTuesday = "Y";
						sRepeatWednseday = "Y";
						sRepeatThursday = "Y";
						sRepeatFriday = "Y";
						break;
					case "WEEKEND":
						sRepeatSunday = "Y";
						sRepeatSaturday = "Y";
						break;
					case "SUN":
						sRepeatSunday = "Y";
						break;
					case "MON":
						sRepeatMonday = "Y";
						break;
					case "TUE":
						sRepeatTuesday = "Y";
						break;
					case "WED":
						sRepeatWednseday = "Y";
						break;
					case "THU":
						sRepeatThursday = "Y";
						break;
					case "FRI":
						sRepeatFriday = "Y";
						break;
					case "SAT":
						sRepeatSaturday = "Y";
						break;
				}
			}
			sRepeatStartDate = mobile_comm_replaceAll(mobile_comm_replaceAll($("#schedule_write_repeatmonth_startdate").val(), "/", "-"), ".", "-"); // 모든 '/'과 '.'을 '-'으로 변경
			sRepeatEndDate = mobile_comm_replaceAll(mobile_comm_replaceAll($("#schedule_write_repeatmonth_enddate").val(), "/", "-"), ".", "-"); // 모든 '/'과 '.'을 '-'으로 변경
			break;
		case "Y":
			sRepeatYear = $("#schedule_write_repeatmonth_month").val();
			sRepeatMonth = $("#schedule_write_repeatyear_month").val();
			if ($("#schedule_write_repeatyear_useday").is(":checked")) {
				sRepeatWeek = "0";
				sRepeatDay = $("#schedule_write_repeatyear_day").val();
			} else {
				sRepeatWeek = $("#schedule_write_repeatyear_dayword1").val();
				sRepeatDay = "0";
				
				sTemp = $("#schedule_write_repeatyear_dayword2").val();
				switch (sTemp.toUpperCase()) {
					case "DAY":
						if ($("#schedule_write_repeatyear_month").val() != "5") {
							sRepeatWeek = "0";
							sRepeatDay = $("#schedule_write_repeatyear_month").val();
						}
						break;
					case "WEEKDAY":
						sRepeatMonday = "Y";
						sRepeatTuesday = "Y";
						sRepeatWednseday = "Y";
						sRepeatThursday = "Y";
						sRepeatFriday = "Y";
						break;
					case "WEEKEND":
						sRepeatSunday = "Y";
						sRepeatSaturday = "Y";
						break;
					case "SUN":
						sRepeatSunday = "Y";
						break;
					case "MON":
						sRepeatMonday = "Y";
						break;
					case "TUE":
						sRepeatTuesday = "Y";
						break;
					case "WED":
						sRepeatWednseday = "Y";
						break;
					case "THU":
						sRepeatThursday = "Y";
						break;
					case "FRI":
						sRepeatFriday = "Y";
						break;
					case "SAT":
						sRepeatSaturday = "Y";
						break;
				}
			}
			sRepeatStartDate = mobile_comm_replaceAll(mobile_comm_replaceAll($("#schedule_write_repeatyear_startdate").val(), "/", "-"), ".", "-"); // 모든 '/'과 '.'을 '-'으로 변경
			sRepeatEndDate = mobile_comm_replaceAll(mobile_comm_replaceAll($("#schedule_write_repeatyear_enddate").val(), "/", "-"), ".", "-"); // 모든 '/'과 '.'을 '-'으로 변경
			break;
	}
	
	var sRepeatAppointType = (typeof _mobile_schedule_updatescheduleobj != 'undefined' && Object.keys(_mobile_schedule_updatescheduleobj).length > 0) ? _mobile_schedule_updatescheduleobj.Repeat.RepeatAppointType : "";
	var sRepetitionPerAtt = 0;
	
	if(sRepeatType == "D"){
		if ($("#schedule_write_repeatday_useenddate").is(":checked")) {
			sRepeatEndType = "I";
			sRepeatEndDate = mobile_comm_replaceAll(mobile_comm_replaceAll($("#schedule_write_repeatday_enddate").val(), "/", "-"), ".", "-"); // 모든 '/'과 '.'을 '-'으로 변경
		}
		else if ($("#schedule_write_repeatday_userepeat").is(":checked")) {
			sRepeatEndType = "R";
			sRepeatCount = $("#schedule_write_repeatday_repeatcnt").val();
		}
		else {
			sRepeatEndType = "";
		}
		sRepeatAppointType = $("#schedule_write_repeatday_day").is(":checked") ? "A" : "B";
		//sRepetitionPerAtt = $("#schedule_write_repeatday_dayvalue").val();
	}else if(sRepeatType == "W"){
		if ($("#schedule_write_repeatweek_useenddate").is(":checked")) {
			sRepeatEndType = "I";
			sRepeatEndDate = mobile_comm_replaceAll(mobile_comm_replaceAll($("#schedule_write_repeatweek_enddate").val(), "/", "-"), ".", "-"); // 모든 '/'과 '.'을 '-'으로 변경
		}
		else if ($("#schedule_write_repeatweek_userepeat").is(":checked")) {
			sRepeatEndType = "R";
			sRepeatCount = $("#schedule_write_repeatweek_repeatcnt").val();
		}
		else {
			sRepeatEndType = "";
		}
		//sRepetitionPerAtt = $("#schedule_write_repeatweek_week").val();
	}else if(sRepeatType == "M"){
		if ($("#schedule_write_repeatmonth_useenddate").is(":checked")) {
			sRepeatEndType = "I";
			sRepeatEndDate = mobile_comm_replaceAll(mobile_comm_replaceAll($("#schedule_write_repeatmonth_enddate").val(), "/", "-"), ".", "-"); // 모든 '/'과 '.'을 '-'으로 변경
		}
		else if ($("#schedule_write_repeatmonth_userepeat").is(":checked")) {
			sRepeatEndType = "R";
			sRepeatCount = $("#schedule_write_repeatmonth_repeatcnt").val();
		}
		else {
			sRepeatEndType = "";
		}
		sRepeatAppointType = $("#schedule_write_repeatmonth_useday").is(":checked") ? "A" : "B";
	}else if(sRepeatType == "Y"){
		if ($("#schedule_write_repeatyear_useenddate").is(":checked")) {
			sRepeatEndType = "I";
			sRepeatEndDate = mobile_comm_replaceAll(mobile_comm_replaceAll($("#schedule_write_repeatyear_enddate").val(), "/", "-"), ".", "-"); // 모든 '/'과 '.'을 '-'으로 변경
		}
		else if ($("#schedule_write_repeatyear_userepeat").is(":checked")) {
			sRepeatEndType = "R";
			sRepeatCount = $("#schedule_write_repeatyear_repeatcnt").val();
		}
		else {
			sRepeatEndType = "";
		}
		//sRepetitionPerAtt = $("#schedule_write_repeatyear_year").val();
		sRepeatAppointType = $("#schedule_write_repeatyear_useday").is(":checked") ? "A" : "B";
	}
	
	var returnObj = {};
	var resourceRepeatObj = {};
	
	resourceRepeatObj.AppointmentStartTime = sAppointmentStartTime;
	resourceRepeatObj.AppointmentEndTime = sAppointmentEndTime;
	resourceRepeatObj.AppointmentDuring = sAppointmentDuring;
	
	resourceRepeatObj.RepeatType = sRepeatType;
	resourceRepeatObj.RepeatYear = sRepeatYear;
	resourceRepeatObj.RepeatMonth = sRepeatMonth;
	resourceRepeatObj.RepeatWeek = sRepeatWeek;
	resourceRepeatObj.RepeatDay = sRepeatDay;
	
	resourceRepeatObj.RepeatMonday = sRepeatMonday;
	resourceRepeatObj.RepeatTuesday = sRepeatTuesday;
	resourceRepeatObj.RepeatWednseday = sRepeatWednseday;
	resourceRepeatObj.RepeatThursday = sRepeatThursday;
	resourceRepeatObj.RepeatFriday = sRepeatFriday;
	resourceRepeatObj.RepeatSaturday = sRepeatSaturday;
	resourceRepeatObj.RepeatSunday = sRepeatSunday;
	
	resourceRepeatObj.RepeatStartDate = sRepeatStartDate;
	resourceRepeatObj.RepeatEndType = sRepeatEndType;
	resourceRepeatObj.RepeatEndDate = sRepeatEndDate;
	resourceRepeatObj.RepeatCount = sRepeatCount;
	
	resourceRepeatObj.RepeatAppointType = sRepeatAppointType;
	//resourceRepeatObj.RepetitionPerAtt = sRepetitionPerAtt;
	
	returnObj.ResourceRepeat = resourceRepeatObj;
	
	return returnObj.ResourceRepeat;
}

//탭 이동
function mobile_schedule_clickTabWrap(pObj){
	var target = $(pObj).parent().index();
	
	$(pObj).parent().siblings().removeClass('on');
	$(pObj).parent().addClass('on');
	$(pObj).parent().parent().siblings('.tab_cont_wrap').children('.tab_cont').removeClass('on');
	$(pObj).parent().parent().siblings('.tab_cont_wrap').children('.tab_cont').eq(target).addClass('on');
	
}


//조직도 호출
function mobile_schedule_openOrg() {
	var sUrl = "/covicore/mobile/org/list.do";

	window.sessionStorage["mode"] = "Select";
	window.sessionStorage["multi"] = "Y";
	window.sessionStorage["callback"] = "mobile_schedule_setAttendeeAtOrgMap();";
	
	mobile_comm_go(sUrl, 'Y');
}

//조직도 콜백 함수 - 참석자
function mobile_schedule_setAttendeeAtOrgMap() {
	var dataObj = JSON.parse("[" + window.sessionStorage["userinfo"] + "]");
	var sUserMail = mobile_comm_getSession("UR_Mail");
	if($("#schedule_write_schedulefolder").val() == mobile_comm_getBaseConfig("SchedulePersonFolderID")){
		for(var i = 0; i < dataObj.length; i++){
			if(sUserMail.toUpperCase() == dataObj[i].EM.toUpperCase()){
				alert(mobile_comm_getDic("msg_no_self_attendant"));
				dataObj.splice(i,1);
			}
		}
	}
	var sHtml = "";
	var sExt = "";
	$(".btn_add_person").each(function(i,obj){
		sExt = $(this).attr("data-value").split("|")[0]+"|"+sExt;
	});
	
	$(dataObj).each(function(i){
		var userCode = $$(this).attr("AN");
		var userName = mobile_comm_getDicInfo($$(this).attr("DN"));
		var DomainID = $$(this).attr("DomainID");
		
		var dataJson = "data-json=\'" + JSON.stringify({"UserCode":userCode,"UserName":userName, "MailAddress":$(this).attr("EM"),"label":userName,"value":userCode,"DomainID":DomainID}) + "\'";
		var dataValue = "data-value=\"" + userCode + "|NEW\"";
		if(sExt.indexOf(userCode+"|") > -1)
			return;
		
		sHtml += "<a onclick=\"mobile_schedule_delUser(this);\" class=\"btn_add_person\" " + dataJson + " " + dataValue + ">";
		sHtml += 		userName;
		sHtml += "</a>";
	});
	
	$("#joins_wrapArea").append(sHtml);
	$("#joins_wrapArea").show();
}

// 알림 열고 닫기
function mobile_schedule_alimsWrapShow(obj){
	if($(obj).hasClass("on")){
		$(obj).removeClass("on");
		$(obj).parent().removeClass("active");
		$("#schedule_write_alarmdiv").hide();
	} else {
		$(obj).addClass("on");
		$(obj).parent().addClass("active");
		$("#schedule_write_alarmdiv").show();
	}
}

//참석자 삭제
function mobile_schedule_delUser(obj, target) {
	var ddObj = $(obj).parents("dd");
	$(obj).detach();
	if($(ddObj).find("a").length == 0) {
		$(ddObj).hide();
	}
	if($("#joins_wrapArea").find('a').length == 0){
		$("#joins_wrapArea").hide();
	}
}

//이메일 추가
function mobile_schedule_clickAddEmail(obj){
	
	obj = $(obj).siblings('div');
	
	var sHtml = "";
	var sEmailTxt = $(obj).find("input[name=schedule_write_emailtxt]").val();
	var sUserMail = mobile_comm_getSession("UR_Mail");
	
	if($("#schedule_write_schedulefolder").val() == mobile_comm_getBaseConfig("SchedulePersonFolderID")){
		if(sEmailTxt.toUpperCase() == sUserMail.toUpperCase()){
			alert(mobile_comm_getDic("msg_no_self_attendant"));
			$(obj).find("input[name=schedule_write_emailtxt]").val('');
			return;
		}
	}
	
	if(sEmailTxt.indexOf('@') < 0) {
		alert(mobile_comm_getDic("msg_ValidationMobileMail")); // 올바른 메일주소를 입력하여 주십시오.
		return;
	}
	
	var dataJson = "data-json=\'" + JSON.stringify({"label":sEmailTxt,"value":sEmailTxt}) + "\'";
	var dataValue = "data-value=\"" + sEmailTxt + "\"";
	
	if(sEmailTxt != ""){
		sHtml += "<a onclick=\"mobile_schedule_delUser(this);\" class=\"btn_add_person\" " + dataJson + " " + dataValue + ">";
		sHtml += 		sEmailTxt; 
		sHtml += "</a>";
		
		if($("#joins_wrapArea").text().indexOf(sEmailTxt) > -1) {
			alert(mobile_comm_getDic("lbl_EmailAddresSame")); // 메일주소가 같습니다. 다시 작성하여 주십시오.
			return;
		}
		
		$("#joins_wrapArea").append(sHtml);
		$("#joins_wrapArea").show();
		$(obj).find("input[name=schedule_write_emailtxt]").val('');
	}
	
}

//자원예약 선택 화면으로 이동
function mobile_schedule_openResource(){
	var startDate = new Date($("#schedule_write_startday").val() + " " + $("#schedule_write_starttime").val());
	var endDate = new Date($("#schedule_write_endday").val() + " " + $("#schedule_write_endtime").val());
	var currentDate = new Date(CFN_GetLocalCurrentDate());
	
	if(startDate < currentDate || endDate < currentDate) {
		alert(mobile_comm_getDic("msg_cannotBookingBefore"));
		return false;
	}
	
	var sUrl = "";
	sUrl += "/groupware/mobile/resource/list.do";
	sUrl += "?viewtype=D";
	
	var selectedResource = "";
	$("dl.resource dd.name_list_wrap a").each(function(){
		selectedResource += $(this).attr("value") + ";";
	});

	window.sessionStorage["isschedulemode_" + mobile_comm_getSession("UR_Code").toLowerCase()] = 'Y';
	window.sessionStorage["selectedres_" + mobile_comm_getSession("UR_Code").toLowerCase()] = selectedResource;
	_mobile_resource_common.IsScheduleStartDate = $("#schedule_write_startday").val();
	_mobile_resource_common.IsScheduleEndDate = $("#schedule_write_endday").val();
	_mobile_resource_common.StartDate = $("#schedule_write_startday").val();
	_mobile_resource_common.EndDate = $("#schedule_write_endday").val();
	
	mobile_comm_go(sUrl, "Y");
}

//일정관리 폴더 선택
function mobile_schedule_folderchange(){
	
	// 내 일정 선택했을 경우
	if($("#schedule_write_schedulefolder").val() == mobile_comm_getBaseConfig("SchedulePersonFolderID")){
		for(var i =0; i < $("#joins_wrapArea").find('a').length; i++){
			if(mobile_comm_getSession("UR_Mail").toUpperCase() == (JSON.parse($("#joins_wrapArea").find('a')[i].dataset.json).value).toUpperCase() || 
			mobile_comm_getSession("UR_Code").toUpperCase() == (JSON.parse($("#joins_wrapArea").find('a')[i].dataset.json).value).toUpperCase()){
				alert(mobile_comm_getDic("msg_no_self_attendant"));
				mobile_schedule_delUser($("#joins_wrapArea").find('a')[i]);
				i--;
			}
		}
	}
	// 구글연동을 선택했을 경우
	if($("#schedule_write_schedulefolder").val() == mobile_comm_getBaseConfig("ScheduleGoogleFolderID", 0) || $("#schedule_write_schedulefolder").find("option:selected").attr("type") == "Schedule.Google"){
			$("#schedule_write_ispublic").hide(); // 중요도 숨김
			$("#schedule_write_divNotification").hide(); // 알림 숨김
	}else{
			$("#schedule_write_ispublic").show(); // 중요도 표시
			$("#schedule_write_divNotification").show(); // 알림 표시
	}
}

//반복 type 탭 변경
function mobile_schedule_changeTab(tabType) {
	$("#schedule_write_repeat > li").removeClass("on"); //전체 탭 > 비선택 처리
	
	var tabObj = $("#schedule_write_tab"+tabType);
	if(tabObj == undefined || tabObj.length < 1) {
		tabObj =$("#schedule_write_repeat > li[value='" + tabType + "']");
	}
	
	$("#schedule_write_repeatDiv").find("div.tab_cont").hide();
	$(tabObj).addClass("on").show();
	$("#schedule_write_repeat").html(tabObj.html());
	
	// '매일'인 경우 (+1)
	if(tabType == "Day"){
		// 반복 시작 날짜 지정
		$("#schedule_write_repeatday_startdate").val($("#schedule_write_startday").val());
		// 반복 끝 날짜 지정
		$("#schedule_write_repeatday_enddate").val(mobile_schedule_SetDateFormat(mobile_schedule_AddDays($("#schedule_write_repeatday_startdate").val(),1), "."));
	
	// '매주'인 경우 (+7)
	} else if(tabType == "Week"){
		// 반복 시작 날짜 지정
		$("#schedule_write_repeatweek_startdate").val($("#schedule_write_startday").val());
		// 반복 끝 날짜 지정
		$("#schedule_write_repeatweek_enddate").val(mobile_schedule_SetDateFormat(mobile_schedule_AddDays($("#schedule_write_repeatweek_startdate").val(),7), "."));
		
	// '매월'인 경우
	} else if(tabType == "Month"){
		// 반복 시작 날짜 지정
		$("#schedule_write_repeatmonth_startdate").val($("#schedule_write_startday").val());
		var tempEndMonth = (Number($("#schedule_write_repeatmonth_startdate").val().split(".")[1])+1)%12;
		var tempYearChk = (Number($("#schedule_write_repeatmonth_startdate").val().split(".")[1])+1)/12;
		var tempEndYear = tempYearChk > 1 ? Number($("#schedule_write_repeatmonth_startdate").val().split(".")[0])+1 : $("#schedule_write_repeatmonth_startdate").val().split(".")[0];
		var tempEndDate = new Date(tempEndYear + "." + (tempEndMonth == 0 ? 12 : tempEndMonth) + "." + $("#schedule_write_repeatmonth_startdate").val().split(".")[2]);
		
		$("#schedule_write_repeatmonth_enddate").val(mobile_schedule_SetDateFormat(tempEndDate, "."));
		
	// '매년'인 경우
	} else if(tabType == "Year"){
		$("#schedule_write_repeatyear_startdate").val($("#schedule_write_startday").val());
		var tempYearEnd = (Number($("#schedule_write_repeatyear_startdate").val().split(".")[0])+1);
		var tempDateEnd = new Date(tempYearEnd + "." + $("#schedule_write_repeatyear_startdate").val().split(".")[1] + "." + $("#schedule_write_repeatyear_startdate").val().split(".")[2]);
		
		$("#schedule_write_repeatyear_enddate").val(mobile_schedule_SetDateFormat(tempDateEnd, "."));
		
	} 
	
	if(tabType == "No") {
		$("#schedule_write_IsRepeat").val("N");
		$("#schedule_write_startday").closest('p').show();
		$("#schedule_write_endday").closest('p').show();
	} else {
		$("#schedule_write_IsRepeat").val("Y");
		$("#schedule_write_startday").closest('p').hide();
		$("#schedule_write_endday").closest('p').hide();
	}
	
	mobile_schedule_clickTabWrap($(tabObj).find("a")); //반복 콘텐츠 영역 변경
}

//일정 작성 끝









/*!
 * 
 * 일정 조회
 * 
 */

var _mobile_schedule_view = {
		
	// 리스트 조회 초기 데이터
	EventID: '',				//이벤트ID
	DateID: '',					//일자ID
	IsRepeat: '',				//반복일정 여부
	RepeatID: '',				//반복 ID
	FolderID: '',				//폴더ID
	FolderType: '',				//폴더유형
	IsCommunity: 'N'			//커뮤니티 여부

};

function mobile_schedule_ViewInit(){
	
	if(window.sessionStorage["schedule_writeinit"] == "Y")
		window.sessionStorage.removeItem('schedule_writeinit');
	
	mobile_schedule_SetAclEventFolderData();
	mobile_schedule_InitJS();

	// 1. 파라미터 셋팅
	if (mobile_comm_getQueryString('eventid', 'schedule_view_page') != 'undefined') {
		_mobile_schedule_view.EventID = mobile_comm_getQueryString('eventid', 'schedule_view_page');
	} else {
		_mobile_schedule_view.EventID = '';
	}
	if (mobile_comm_getQueryString('dateid', 'schedule_view_page') != 'undefined') {
		_mobile_schedule_view.DateID = mobile_comm_getQueryString('dateid', 'schedule_view_page');
	} else {
		_mobile_schedule_view.DateID = '';
	}
	if (mobile_comm_getQueryString('isrepeat', 'schedule_view_page') != 'undefined') {
		_mobile_schedule_view.IsRepeat = mobile_comm_getQueryString('isrepeat', 'schedule_view_page');
	} else {
		_mobile_schedule_view.IsRepeat = '';
	}
	if (mobile_comm_getQueryString('repeatid', 'schedule_view_page') != 'undefined') {
		_mobile_schedule_view.RepeatID = mobile_comm_getQueryString('repeatid', 'schedule_view_page');
	} else {
		_mobile_schedule_view.RepeatID = '';
	}
	if (mobile_comm_getQueryString('folderid', 'schedule_view_page') != 'undefined') {
		_mobile_schedule_view.FolderID = mobile_comm_getQueryString('folderid', 'schedule_view_page');
	} else {
		_mobile_schedule_view.FolderID = '';
	}
	if (mobile_comm_getQueryString('iscommunity', 'schedule_view_page') != 'undefined') {
		_mobile_schedule_view.IsCommunity = mobile_comm_getQueryString('iscommunity', 'schedule_view_page');
	} else {
		_mobile_schedule_view.IsCommunity = 'N';
	}
	
	/*
	// 2. 권한 확인
	if($$(_mobile_schedule_common.AclArray).find("read").concat().find("[FolderID="+folderID+"]").length <= 0){		// 삭제 권한 체크
		alert("읽기 권한이 없습니다.", "", function(){
		CoviMenu_GetContent(g_lastURL);
		return;
	});
	// TODO : 뒷 화면 숨기기 
	}else{
		$("#divSheet").hide();
		
		scheduleUser.setViewData("D", CFN_GetQueryString("eventID"), CFN_GetQueryString("dateID"), CFN_GetQueryString("isRepeat"));
	}
	*/
	
	// 3. 일정 조회
	mobile_schedule_getView("D", _mobile_schedule_view.EventID, _mobile_schedule_view.DateID, _mobile_schedule_view.IsRepeat);
	
	//4. 알림 컨트롤러 표시
//	 if(_mobile_schedule_view.IsRepeat == "Y"){
//		 $("#schedule_view_isnotificationtotaldiv").show();
//	 }else{
//		 $("#schedule_view_isnotificationtotaldiv").hide();
//	 }
}

//일정 조회
function mobile_schedule_getView(mode, eventID, dateID, isRepeat){
	var url = "/groupware/mobile/schedule/goOne.do";
	var userCode = mobile_comm_getSession("UR_Code");
	/**
	 * mode : S - 간단 조회, D - 상세 조회, DU - 상세 등록(수정화면), M - 모바일
	 */
	// 구글 연동 체크
	if(Number(eventID)){
		$.ajax({
		    url: url,
		    type: "POST",
		    data: {
		    	"mode" : (mode == "M" ? "D" : mode),
		    	"lang" : mobile_comm_getSession("LanguageCode"),
		    	"EventID" : eventID,
		    	"DateID" : dateID,
		    	"IsRepeat" : isRepeat,
		    	"UserCode" : userCode
			},
		    success: function (res) {
		    	
		    	if(res.status == "SUCCESS"){
		    		if(res.data && JSON.stringify(res.data) != "{}" && res.data.Date && JSON.stringify(res.data.Date) != "{}"){
		    			var tempStartDateTime = CFN_TransLocalTime(res.data.Date.StartDate + ' ' + res.data.Date.StartTime, 'yyyy-MM-dd HH:mm');
						res.data.Date.StartDate = tempStartDateTime.split(' ')[0];
						res.data.Date.StartTime = tempStartDateTime.split(' ')[1];
						var tempEndDateTime = CFN_TransLocalTime(res.data.Date.EndDate + ' ' + res.data.Date.EndTime, 'yyyy-MM-dd HH:mm');
						res.data.Date.EndDate = tempEndDateTime.split(' ')[0];
						res.data.Date.EndTime = tempEndDateTime.split(' ')[1];
						
		    			if(mode == "M"){
		    				return res.data;
		    			} else {
		    				var folderID = _mobile_schedule_view.FolderID;
			    			var btnHTML = "";
			    			var isModify = false;
			    			var isDelete = false;
			    			
			    			// 작성자,  Owner 권한 체크, 폴더 권한 체크 + 수정/삭제 버튼 활성화
			    			if(res.data.Event.RegisterCode == userCode || res.data.Event.OwnerCode == userCode  || $.inArray(folderID, _mobile_schedule_common.AclArray.modify) > 0){		// 수정 권한 체크
			    				$("#schedule_view_modify").show();
			    			}
			    			if(res.data.Event.RegisterCode == userCode || res.data.Event.OwnerCode == userCode  || $.inArray(folderID, _mobile_schedule_common.AclArray.del) > 0){		// 삭제 권한 체크
			    				$("#schedule_view_delete").show();
			    			}
			    			
			    			if($("#schedule_view_modify").length >= 1 && $("#schedule_view_modify").css('display').indexOf("none") > -1 
			    					&& $("#schedule_view_delete").length >= 1 && $("#schedule_view_delete").css('display').indexOf("none") > -1) 
			    			{
			    				$('div.utill').hide();
			    			} else {
			    				$('div.utill').show();
			    			}
			    			
			    			mobile_schedule_drawViewData(mode, res.data);
			    			//mobile_comment_getCommentLike('Schedule', eventID + '_'  + dateID, 'N'); // + '_' + isRepeat
			    			mobile_comment_getCommentLike('Schedule', eventID, 'N'); // + '_' + isRepeat
							
							var strIsRepeat = (mobile_comm_getQueryString('isrepeat', 'schedule_view_page') != 'undefined') ? mobile_comm_getQueryString('isrepeat', 'schedule_view_page') : '';
							var strRepeatID = (mobile_comm_getQueryString('repeatid', 'schedule_view_page') != 'undefined') ? mobile_comm_getQueryString('repeatid', 'schedule_view_page') : '';
							var strIsRepeatAll = (mobile_comm_getQueryString('isrepeatall', 'schedule_view_page') != 'undefined') ? mobile_comm_getQueryString('isrepeatall', 'schedule_view_page') : '';
							var strFolderID = (mobile_comm_getQueryString('folderid', 'schedule_view_page') != 'undefined') ? mobile_comm_getQueryString('folderid', 'schedule_view_page') : '';
							var commentURL = mobile_comm_getGlobalProperties("smart4j.path")+"/groupware/layout/schedule_DetailView.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule"
	    						+ "&eventID=" + eventID + "&dateID=" + dateID + "&isRepeat=" + strIsRepeat + "&repeatid=" + strRepeatID + "&isrepeatall=" + strIsRepeatAll + "&folderID=" + strFolderID;
	    					var mobileURL = mobile_comm_getGlobalProperties("smart4j.path")+"/groupware/mobile/schedule/view.do"
	    						+ "?eventid=" + eventID + "&dateid=" + dateID + "&isrepeat=" + strIsRepeat + "&repeatid=" + strRepeatID + "&isrepeatall=" + strIsRepeatAll + "&folderid=" + strFolderID;
											
							mobile_commment_messageSetting = {
    							SenderCode : userCode,
    							RegistererCode : userCode,
    							ReceiversCode : (res.data.Event.RegisterCode != userCode) ? res.data.Event.RegisterCode : '',
    							GotoURL: commentURL, 
    							PopupURL: commentURL, 
    							MobileURL: mobileURL,
    							MessagingSubject : res.data.Event.Subject,
    							ReceiverText :  res.data.Event.Subject,
    							ServiceType : "Schedule",
    							MsgType : "ScheduleComment"
	    					};
		    			}
		    		} else if(isSchUpdate){
						isSchUpdate = false;
						mobile_comm_back();
					} else {
						alert(mobile_comm_getDic("msg_notExistSchedule")); // 이미 삭제되었거나 존재하지 않는 일정입니다.
						mobile_comm_back();
					}
		    		//TODO : 지도...
		    		//mobile_schedule_DeletePlaceInput();
		    	} else {
		    		alert(mobile_comm_getDic("msg_apv_030"));		// 오류가 발생했습니다.
		    	}
		    },
	        error:function(response, status, error){
				mobile_comm_ajaxerror(url, response, status, error);
			}
		}).done(function(){
			if(_mobile_schedule_write.Mode == "DU"){
				if (_mobile_schedule_view.IsRepeat == 'Y' && mobile_comm_getQueryString('isrepeatall', "schedule_write_page") != "Y"){
					$("#schedule_write_page .repeats_wrap").hide();
				}
			}
		});
	}else{
		//구글연동 데이터
		$("#schedule_view_modify, #schedule_view_delete").show();
		$("#schedule_view_isnotificationdiv").hide();
		mobile_schedule_GetGoogleEventOne(mode, eventID, mobile_schedule_coverGoogleEventOne, mobile_schedule_drawViewData, true);
	}
	
}

//구글 캘린더 이벤트 - 데이터 조작 후 그리기
function mobile_schedule_coverGoogleEventOne(mode, data, callBack){
	var resultObj = {};
	
	resultObj.IsGoogle = "Y";
	resultObj.Event = {};
	resultObj.Date = {};
	resultObj.Repeat = {};
	resultObj.Resource = {};
	resultObj.Attendee = {};
	resultObj.Notification = {};
	
	resultObj.Event.Subject = data.summary == undefined ? "("+mobile_comm_getDic("lbl_NoSubject")+")" : data.summary;
	resultObj.Event.IsSubject = data.summary == undefined ? "N" : "Y";
	resultObj.Event.RegisterData = data.creator.email;
	resultObj.Event.Place = data.location == undefined ? "" : data.location;
	resultObj.Event.ImportanceState = "N";
	resultObj.Event.FolderName = mobile_comm_getDic("lbl_schedule_googleSchedule");		//구글일정
	resultObj.Event.FolderID = mobile_comm_getBaseConfig("ScheduleGoogleFolderID", 0);
	resultObj.Event.FolderColor = "#ac725e";			//TODO
	resultObj.Event.Description = data.description == undefined ? "" : data.description;
	resultObj.Event.IsPublic = (data.visibility == "private" || data.visibility == "confidential") ? "N" : "Y";
	resultObj.Event.IsInviteOther = "N";
	
	resultObj.Event.IsGoogle = "Y";
	
	resultObj.Date.IsAllDay = data.start.date == undefined ? "N" : "Y";
	var start_date = "";
	var end_date = "";
	if(resultObj.Date.IsAllDay == "N"){
		start_date = data.start.dateTime;
		end_date = data.end.dateTime;
	}else{
		start_date = data.start.date;
		//end_date = data.end.date;
		end_date = mobile_schedule_SetDateFormat(mobile_schedule_AddDays(data.end.date, -1), "-");
	}
	resultObj.Date.StartDate = mobile_schedule_SetDateFormat(new Date(mobile_schedule_ReplaceDate(start_date)), "-");
	resultObj.Date.EndDate = mobile_schedule_SetDateFormat(mobile_schedule_ReplaceDate(new Date(end_date)), "-");
	
	if(resultObj.Date.IsAllDay == "N"){
		resultObj.Date.StartTime =mobile_comm_AddFrontZero(new Date(mobile_schedule_ReplaceDate(start_date)).getHours(), 2)+":"+mobile_comm_AddFrontZero(new Date(mobile_schedule_ReplaceDate(start_date)).getMinutes(), 2);
		resultObj.Date.EndTime = mobile_comm_AddFrontZero(new Date(mobile_schedule_ReplaceDate(end_date)).getHours(), 2)+":"+mobile_comm_AddFrontZero(new Date(mobile_schedule_ReplaceDate(end_date)).getMinutes(), 2);
	}else{
		resultObj.Date.StartTime = "00:00";
		resultObj.Date.EndTime = "23:59";
	}
	resultObj.Date.IsRepeat = this.recurringEventId == undefined ? "N" : "Y";
	
	var attendeeArr = new Array();
	if(data.attendees != undefined){
		$(data.attendees).each(function(){
			if(!this.self){			// 자신 이외의 참석자만 가져옴
				var attendeeObj = {};
				attendeeObj.UserName = this.email;
				attendeeObj.UserCode = "";
				attendeeObj.IsAllow = "";
				attendeeObj.IsOutsider = "Y";
				
				if(this.responseStatus == "accepted")
					attendeeObj.IsAllow = "Y";
				else if(this.responseStatus == "declined")
					attendeeObj.IsAllow = "N";
				
				attendeeArr.push(attendeeObj);
			}
		});
		resultObj.Attendee = attendeeArr;
		
	}
	
	resultObj.Notification.ReminderTime = "10";
	resultObj.Notification.IsNotification = "N";
	resultObj.Notification.IsReminder = "N";
	resultObj.Notification.IsCommentNotification = "N";
	
	callBack(mode, resultObj);
}

//조회한 데이터 상황에 맞게 그려주기
function mobile_schedule_drawViewData(mode, data){
	var event = data.Event;
	var date = data.Date;
	var resource = data.Resource;
	var repeat = data.Repeat;
	var attendee = data.Attendee;
	var notification = data.Notification;	
	var userCode = mobile_comm_getSession("UR_Code");
	var sTemp = "";
	
	if(mode == "D"){
		/**
		 * 참석자에 대한 승인/거부 버튼
		 */
		$(attendee).each(function(){
			if($(this).attr("UserCode") == userCode && $(this).attr("IsAllow") == ""){
				var btnHTML = '<li><a onclick="javascript:mobile_schedule_approve(\'APPROVAL\');" class="btn ui-link">' + mobile_comm_getDic("lbl_schedule_attend") + '</a></li><li><a onclick="javascript:mobile_schedule_approve(\'REJECT\');" class="btn ui-link">' + mobile_comm_getDic("lbl_schedule_noAttend") + '</a></li>'; //참석 요청 승인,  참석 요청 거부
				$("#schedule_view_exmenu_list").append(btnHTML);
				$('div.utill').show();
				$("#schedule_view_page div[covi-mo-comment]").hide();
				return false;
			} 
		});
		
		var sSubject = "";
		if(event.ImportanceState == "Y"){
			sSubject += "<span class=\"ico_point\"></span>";
		}		
		_mobile_schedule_view.FolderType = event.FolderType;
		if(date.IsRepeat == "Y" && mobile_comm_getQueryString("isrepeatall") == "Y"){
			var startEndDateTime = mobile_schedule_GetRepeatViewMessage(repeat);
			
			$("#schedule_view_startenddatetime").html(startEndDateTime);
			sSubject += "<span class=\"ico_repeat\"></span>";
		}else{
			var startDate =new Date(mobile_schedule_ReplaceDate(date.StartDate) + " " + date.StartTime);
			startDate = mobile_schedule_SetDateFormat(startDate, ".") + (date.IsAllDay == "Y" ? "" :  " " + mobile_comm_AddFrontZero(startDate.getHours(), 2)+":"+mobile_comm_AddFrontZero(startDate.getMinutes(), 2));
			
			var endDate =new Date(mobile_schedule_ReplaceDate(date.EndDate) + " " + date.EndTime);
			endDate = mobile_schedule_SetDateFormat(endDate, ".") + (date.IsAllDay == "Y" ? "" : " " + mobile_comm_AddFrontZero(endDate.getHours(), 2)+":"+mobile_comm_AddFrontZero(endDate.getMinutes(), 2));
			
			if(startDate == endDate){
				$("#schedule_view_startenddatetime").html(startDate);
			}else{
				$("#schedule_view_startenddatetime").html(startDate + " - " + endDate);
			}
			
			if(date.IsRepeat == "Y" && mobile_comm_getQueryString('isrepeatall', "schedule_view_page") == "Y"){
				var startEndDateTime = mobile_schedule_GetRepeatViewMessage(repeat);
				
				$("#schedule_view_startenddatetime").after('<dd>' + startEndDateTime + ' ' + repeat.RepeatTimeZoneDisplay + '</dd>');
				sSubject += "<span class=\"ico_repeat\"></span>";
			}
		}
		
		$("#schedule_view_subject").html(sSubject+event.Subject);

		$("#schedule_view_photo").attr("style", "background-image: url('" + mobile_comm_noimg(event.RegisterPhoto) + "'), url('" + mobile_comm_noperson() + "');");
		$("#schedule_view_name").html("<strong>"+event.RegisterData+"</strong> "+( event.RegisterDept == undefined ? "" : "<span>("+event.RegisterDept+")</span>"));
		if(event.RegistDate != undefined && event.RegistDate != null) {
			var registDate = CFN_TransLocalTime(event.RegistDate).substring(0, event.RegistDate.lastIndexOf(":"));			
			registDate = mobile_schedule_SetDateFormat(registDate.split(" ")[0], '.') + " " + registDate.split(" ")[1];
			
			$("#schedule_view_registDate").text(registDate);
		} else { 
			$("#schedule_view_registDate").hide();
		}
		
		$("#schedule_view_folder").html('<span id="schedule_view_foldercolor" class="rd_dot"></span>&nbsp'+event.FolderName);
		$("#schedule_view_folder").attr("folderID", event.FolderID);
		$("#schedule_view_foldercolor").css("background", event.FolderColor);
		
		if(event.Place != undefined && event.Place != "" && event.Place != null){
			//$("#schedule_view_placemap").show();
			$("#schedule_view_placemap").hide();
			$("#schedule_view_place").html(event.Place);
			//TODO 지도
			//coviCtrl.addr2Geocode(event.Place, "drawMap");
		}else{
			$("#schedule_view_placemap").hide();
			//$("#schedule_view_place").html(mobile_comm_getDic("lbl_noexists")); //없음
			$("#schedule_view_place").html("&nbsp;");
		}
		
		//참석자
		if(attendee.length > 0 && attendee[0].UserCode != undefined){
			var attendeeHTML = "<dt>" + mobile_comm_getDic("lbl_schedule_attendant") + "</dt>"; //참석자
			$(attendee).each(function(){
				if(this.UserCode == userCode && this.IsAllow == ""){
					attendeeHTML += '<dd onclick="javascript: mobile_schedule_approve(\'' +this.IsAllow + '\');">';
				}
				else{
					attendeeHTML += '<dd>';
				}
				
				if (this.IsOutsider != 'Y'){
					if(this.IsAllow == "Y")
						attendeeHTML += '<span class="flag_cr02">' + mobile_comm_getDic("lbl_schedule_participation") + '</span>'; //참여
					else if(this.IsAllow == "N")
						attendeeHTML += '<span class="flag_cr01">' + mobile_comm_getDic("lbl_schedule_Nonparticipation") + '</span>'; //비참여
					else
						attendeeHTML += '<span class="flag_cr03">' + mobile_comm_getDic("lbl_schedule_standBy") + '</span>'; //대기중
				}
				
				attendeeHTML += this.UserName+ ((this.IsOutsider == 'Y') ? ' ('+mobile_comm_getDic("ACC_lbl_outsideAttendant")+')' : this.DeptName == undefined ? "" : ' ('+this.DeptName+')' )+'&nbsp;</dd>'; 
			});
			$("#schedule_view_attendee").html(attendeeHTML);
		}else{
			//$("#schedule_view_attendee").html("<dt>" + mobile_comm_getDic("lbl_schedule_attendant") + "</dt><span>" + mobile_comm_getDic("lbl_noexists") + "</span>"); //참석자 없음
			$("#schedule_view_attendee").html("<dt>" + mobile_comm_getDic("lbl_schedule_attendant") + "</dt><span>&nbsp;</span>"); //참석자 없음			
		}
		
		//자원
		if(resource.length > 0 && resource[0].ResourceName != undefined){
			var resourceHTML = "";
			$(resource).each(function(){
				resourceHTML += this.ResourceName + " (" + this.TypeName + "),";
			});
			resourceHTML = resourceHTML.substring(0, resourceHTML.lastIndexOf(","));
			$("#schedule_view_resource").html(resourceHTML);
		}else{
			//$("#schedule_view_resource").html("<span>" + mobile_comm_getDic("lbl_noexists") + "</span>");			
			$("#schedule_view_resource").html("<span>&nbsp;</span>");
		}
		
		$("#schedule_view_description").html(event.Description == "" ? "&nbsp;" : mobile_comm_replaceAll(event.Description, "\n", "<br>"));
		setTimeout(function () {
			mobile_comm_replacebodyinlineimg($('#schedule_view_description'));
			mobile_comm_replacebodylink($('#schedule_view_description'));
		}, 100);
		
		
		// 알림은 등록자와 참석자만 변경할 수 있음
		if($.isEmptyObject(notification)){
			$("#schedule_view_isnotificationdiv").hide();
		}else{
			$("#schedule_view_remindertime").val(notification.ReminderTime);
			if(notification.IsNotification == "Y"){
//				if($("#schedule_view_isnotificationdiv").hasClass('on') == false){
//					$("#schedule_view_isnotificationdiv").show();
//				}
//				else{
					$("#schedule_view_isnotificationdiv").hide();
//				}
				if(notification.IsReminder == "Y"){
					$("#schedule_view_isremindera").parent().addClass('on');
					$('#schedule_view_notice_divReminderTime').css('visibility', 'visible');
				} else {
					$("#schedule_view_isremindera").parent().removeClass('on');
					$('#schedule_view_notice_divReminderTime').css('visibility', 'hidden');
				}
				if(notification.IsCommentNotification == "Y"){
					$("#schedule_view_isrcommenta").parent().addClass('on');
				} else {
					$("#schedule_view_isrcommenta").parent().removeClass('on');
				}
			}		
		}
	}
	else if(mode == "DU"){
		_mobile_schedule_updatescheduleobj = data;
		_mobile_schedule_updatescheduleobj.Repeat.RepeatAppointType = _mobile_schedule_updatescheduleobj.Repeat.RepeatAppointType == '0' ? 'A' : 'B';
		$(_mobile_schedule_updatescheduleobj.Attendee).each(function(){
			this.dataType = "OLD";
		});
		
		var setSubject = event.Subject.split('&nbsp;').join(' ').replace(/(\r\n|\n|\n\n)/gi, '<br />');
		$("#schedule_write_subject").val(setSubject);
		
		
		if(event.ImportanceState == "Y"){
			$("#schedule_write_isimportantstate").addClass("on");
			$("#schedule_write_isimportantstate").parent().addClass("active");
		}
		if(event.IsPublic != "Y"){
			$("#schedule_write_ispublic").addClass("on");
			$("#schedule_write_ispublic").parent().addClass("active");
		}
		
		$("#schedule_write_schedulefolder").val(event.FolderID);
		$("#txtPlace").val(event.Place);
		
		// TODO 장소
		/*if(event.Place != undefined && event.Place != ""){
			var placeObj = $("<div></div>")
            .addClass("ui-autocomplete-multiselect-item")
            .attr("data-json", JSON.stringify({"label":event.Place,"value":event.Place}))
            .attr("data-value", event.Place)
            .text(event.Place)
            .append(
                $("<span></span>")
                    .addClass("ui-icon ui-icon-close")
                    .click(function(){
                        var item = $(this).parent();
                        item.detach();
                    })
            );
			$("#placeAutoComp .ui-autocomplete-multiselect").prepend(placeObj);
		}*/
		
		
		$("#schedule_write_startday").val(mobile_comm_replaceAll(mobile_comm_replaceAll(date.StartDate, "-", "."), "/", "."));
		$("#schedule_write_endday").val(mobile_comm_replaceAll(mobile_comm_replaceAll(date.EndDate, "-", "."), "/", "."));
		
		$("#schedule_write_starttime").val(date.StartTime);
		$("#schedule_write_endtime").val(date.EndTime);
		
		if(date.IsAllDay == "Y"){
			$("#schedule_write_isallday").click();
			$("#schedule_write_starttime").val("00:00");
			$("#schedule_write_endtime").val("23:59");
		}
		
		//반복
		if(date.IsRepeat == "Y" && mobile_comm_getQueryString('isrepeatall','schedule_write_page') == "N"){
			date.IsRepeat = "N";
		} else if(date.IsRepeat == "Y" && mobile_comm_getQueryString('isrepeatall','schedule_write_page') == "Y"){
			//반복 설정
			if(repeat != undefined && repeat != ""){
				
				var sAppointmentStartTime = repeat.AppointmentStartTime;
		        var sAppointmentEndTime = repeat.AppointmentEndTime;
		        var sRepeatType = repeat.RepeatType;
		        var sRepeatYear = repeat.RepeatYear;
		        var sRepeatMonth = repeat.RepeatMonth;
		        var sRepeatWeek = repeat.RepeatWeek;
		        var sRepeatDay = repeat.RepeatDay;
		        var sRepeatMonday = repeat.RepeatMonday;
		        var sRepeatTuesday = repeat.RepeatTuesday;
		        var sRepeatWednseday = repeat.RepeatWednseday;
		        var sRepeatThursday = repeat.RepeatThursday;
		        var sRepeatFriday = repeat.RepeatFriday;
		        var sRepeatSaturday = repeat.RepeatSaturday;
		        var sRepeatSunday = repeat.RepeatSunday;
		        var sRepeatStartDate = repeat.RepeatStartDate;
		        var sRepeatEndType = repeat.RepeatEndType;
		        var sRepeatEndDate = repeat.RepeatEndDate;
		        var sRepeatCount = repeat.RepeatCount;
		        
		        sRepeatStartDate= mobile_comm_replaceAll(mobile_comm_replaceAll(sRepeatStartDate, "-", "."), "/", ".");
		        sRepeatEndDate= mobile_comm_replaceAll(mobile_comm_replaceAll(sRepeatEndDate, "-", "."), "/", ".");
		        
		        $("#schedule_write_starttime").val(sAppointmentStartTime);
		        $("#schedule_write_endtime").val(sAppointmentEndTime);
		        
		        switch (sRepeatType.toUpperCase()) {
		            case "D":
		                if (sRepeatDay == "0") {
		                    $("#schedule_write_repeatday_day").prop("checked", false).checkboxradio('refresh');
		                    $("#schedule_write_repeatday_all").prop("checked", true).checkboxradio('refresh');
		                }
		                else {
		                    $("#schedule_write_repeatday_dayvalue").val(sRepeatDay);
		                    $("#schedule_write_repeatday_all").prop("checked", false).checkboxradio('refresh');
		                    $("#schedule_write_repeatday_day").prop("checked", true).checkboxradio('refresh');
		                }
		                
		                if (sRepeatEndType == "I") {
				            $("#schedule_write_repeatday_userepeat").prop("checked", false).checkboxradio('refresh');
				            $("#schedule_write_repeatday_useenddate").prop("checked", true).checkboxradio('refresh');
				            $("#schedule_write_repeatday_enddate").val(sRepeatEndDate);
				        }
				        else if (sRepeatEndType == "R") {
				            $("#schedule_write_repeatday_useenddate").prop("checked", false).checkboxradio('refresh');
				            $("#schedule_write_repeatday_userepeat").prop("checked", true).checkboxradio('refresh');
				            $("#schedule_write_repeatday_enddate").val(sRepeatEndDate);
				            $("#schedule_write_repeatday_repeatcnt").val(sRepeatCount);
				        }
		                 $("#schedule_write_repeatday_startdate").val(sRepeatStartDate);
		                break;
		            case "W":
		                $("#schedule_write_repeatweek_week").val(sRepeatWeek);
		                if (sRepeatMonday == "Y") { $("#schedule_write_repeatweek_mon").addClass("on"); } else { $("#schedule_write_repeatweek_mon").removeClass("on"); }
		                if (sRepeatTuesday == "Y") { $("#schedule_write_repeatweek_tue").addClass("on"); } else { $("#schedule_write_repeatweek_tue").removeClass("on"); }
		                if (sRepeatWednseday == "Y") { $("#schedule_write_repeatweek_wed").addClass("on"); } else { $("#schedule_write_repeatweek_wed").removeClass("on"); }
		                if (sRepeatThursday == "Y") { $("#schedule_write_repeatweek_thu").addClass("on"); } else { $("#schedule_write_repeatweek_thu").removeClass("on"); }
		                if (sRepeatFriday == "Y") { $("#schedule_write_repeatweek_fri").addClass("on"); } else { $("#schedule_write_repeatweek_fri").removeClass("on"); }
		                if (sRepeatSaturday == "Y") { $("#schedule_write_repeatweek_sat").addClass("on"); } else { $("#schedule_write_repeatweek_sat").removeClass("on"); }
		                if (sRepeatSunday == "Y") { $("#schedule_write_repeatweek_sun").addClass("on"); } else { $("#schedule_write_repeatweek_sun").removeClass("on"); }
		                
		                if (sRepeatEndType == "I") {
				            $("#schedule_write_repeatweek_userepeat").prop("checked", false).checkboxradio('refresh');
				            $("#schedule_write_repeatweek_useenddate").prop("checked", true).checkboxradio('refresh');
				            $("#schedule_write_repeatweek_enddate").val(sRepeatEndDate);
				        }
				        else if (sRepeatEndType == "R") {
				            $("#schedule_write_repeatweek_useenddate").prop("checked", false).checkboxradio('refresh');
				            $("#schedule_write_repeatweek_userepeat").prop("checked", true).checkboxradio('refresh');
				            $("#schedule_write_repeatweek_enddate").val(sRepeatEndDate);
				            $("#schedule_write_repeatweek_repeatcnt").val(sRepeatCount);
				        }
		                 $("#schedule_write_repeatweek_startdate").val(sRepeatStartDate);
		                break;
		            case "M":
		            	$("#schedule_write_repeatmonth_month").val(sRepeatMonth);
		                if (sRepeatDay != "0") {
		                    $("#schedule_write_repeatmonth_usedayword").prop("checked", false).checkboxradio('refresh');
		                    $("#schedule_write_repeatmonth_useday").prop("checked", true).checkboxradio('refresh');
		                    $("#schedule_write_repeatmonth_day").val(sRepeatDay);
		                }
		                else {
		                    $("#schedule_write_repeatmonth_useday").prop("checked", false).checkboxradio('refresh');
		                    $("#schedule_write_repeatmonth_usedayword").prop("checked", true).checkboxradio('refresh');
		                    $("#schedule_write_repeatmonth_dayword1").val(sRepeatWeek);
		                    
		                    if ((sRepeatMonday == "Y") && (sRepeatTuesday == "Y") && (sRepeatWednseday == "Y") && (sRepeatThursday == "Y") && (sRepeatFriday == "Y") && (sRepeatSaturday != "Y") && (sRepeatSunday != "Y")) { sTemp = "WEEKDAY"; }
		                    else if ((sRepeatMonday != "Y") && (sRepeatTuesday != "Y") && (sRepeatWednseday != "Y") && (sRepeatThursday != "Y") && (sRepeatFriday != "Y") && (sRepeatSaturday == "Y") && (sRepeatSunday == "Y")) { sTemp = "WEEKEND"; }
		                    else if (sRepeatMonday == "Y") { sTemp = "MON"; }
		                    else if (sRepeatTuesday == "Y") { sTemp = "TUE"; }
		                    else if (sRepeatWednseday == "Y") { sTemp = "WED"; }
		                    else if (sRepeatThursday == "Y") { sTemp = "THU"; }
		                    else if (sRepeatFriday == "Y") { sTemp = "FRI"; }
		                    else if (sRepeatSaturday == "Y") { sTemp = "SAT"; }
		                    else if (sRepeatSunday == "Y") { sTemp = "SUN"; }
		                    else { sTemp = "DAY"; }
		                    $("#schedule_write_repeatmonth_dayword2").val(sTemp);
		                }
		                
		                if (sRepeatEndType == "I") {
				            $("#schedule_write_repeatmonth_userepeat").prop("checked", false).checkboxradio('refresh');
				            $("#schedule_write_repeatmonth_useenddate").prop("checked", true).checkboxradio('refresh');
				            $("#schedule_write_repeatmonth_enddate").val(sRepeatEndDate);
				        }
				        else if (sRepeatEndType == "R") {
				            $("#schedule_write_repeatmonth_useenddate").prop("checked", false).checkboxradio('refresh');
				            $("#schedule_write_repeatmonth_userepeat").prop("checked", true).checkboxradio('refresh');
				            $("#schedule_write_repeatmonth_enddate").val(sRepeatEndDate);
				            $("#schedule_write_repeatmonth_repeatcnt").val(sRepeatCount);
				        }
		                 $("#schedule_write_repeatmonth_startdate").val(sRepeatStartDate);
		                break;
		            case "Y":
		                $("#schedule_write_repeatyear_year").val(sRepeatYear);
		                $("#schedule_write_repeatyear_month").val(sRepeatMonth);
		                if (sRepeatDay != "0") {
		                    $("#schedule_write_repeatyear_userepeat").prop("checked", false).checkboxradio('refresh');
		                    $("#schedule_write_repeatyear_useday").prop("checked", true).checkboxradio('refresh');
		                    $("#schedule_write_repeatyear_day").val(sRepeatDay);
		                }
		                else {
		                    $("#schedule_write_repeatyear_useday").prop("checked", false).checkboxradio('refresh');
		                    $("#schedule_write_repeatyear_userepeat").prop("checked", true).checkboxradio('refresh');
		                    $("#schedule_write_repeatyear_dayword1").val(sRepeatWeek);
		                    if ((sRepeatMonday == "Y") && (sRepeatTuesday == "Y") && (sRepeatWednseday == "Y") && (sRepeatThursday == "Y") && (sRepeatFriday == "Y") && (sRepeatSaturday != "Y") && (sRepeatSunday != "Y")) { sTemp = "WEEKDAY"; }
		                    else if ((sRepeatMonday != "Y") && (sRepeatTuesday != "Y") && (sRepeatWednseday != "Y") && (sRepeatThursday != "Y") && (sRepeatFriday != "Y") && (sRepeatSaturday == "Y") && (sRepeatSunday == "Y")) { sTemp = "WEEKEND"; }
		                    else if (sRepeatMonday == "Y") { sTemp = "MON"; }
		                    else if (sRepeatTuesday == "Y") { sTemp = "TUE"; }
		                    else if (sRepeatWednseday == "Y") { sTemp = "WED"; }
		                    else if (sRepeatThursday == "Y") { sTemp = "THU"; }
		                    else if (sRepeatFriday == "Y") { sTemp = "FRI"; }
		                    else if (sRepeatSaturday == "Y") { sTemp = "SAT"; }
		                    else if (sRepeatSunday == "Y") { sTemp = "SUN"; }
		                    else { sTemp = "DAY"; }
		                    $("#schedule_write_repeatyear_dayword2").val(sTemp);
		                }
		                
		                if (sRepeatEndType == "I") {
				            $("#schedule_write_repeatyear_userepeat").prop("checked", false).checkboxradio('refresh');
				            $("#schedule_write_repeatyear_useenddate").prop("checked", true).checkboxradio('refresh');
				            $("#schedule_write_repeatyear_enddate").val(sRepeatEndDate);
				        }
				        else if (sRepeatEndType == "R") {
				            $("#schedule_write_repeatyear_useenddate").prop("checked", false).checkboxradio('refresh');
				            $("#schedule_write_repeatyear_userepeat").prop("checked", true).checkboxradio('refresh');
				            $("#schedule_write_repeatyear_enddate").val(sRepeatEndDate);
				            $("#schedule_write_repeatyear_repeatcnt").val(sRepeatCount);
				        }
		                 $("#schedule_write_repeatyear_startdate").val(sRepeatStartDate);
		                break;
		        }
		        //$("#schedule_write_startday").val(sRepeatStartDate);
		       
		        
		        mobile_schedule_changeTab(sRepeatType);
		        $("#schedule_write_repeatChk").trigger("click");
		        
			}
		}
		
		// 알림은 등록자와 참석자만 변경할 수 있음 수정중
		if($.isEmptyObject(notification)){
			$("#schedule_write_prealarm").hide();
			$("#schedule_write_commentalarm").hide();
		}else{
			$("#schedule_write_notice_remindertime").val(notification.ReminderTime);
			if(notification.IsNotification == "Y"){
				$("#BtnAlims_wrap").trigger("click");
				if(notification.IsReminder == "Y"){
					$("#schedule_write_notice_reminderYN").addClass("on");
					$('#schedule_write_notice_divReminderTime').css('visibility', 'visible');
				}
				if(notification.IsCommentNotification == "Y"){
					$("#schedule_write_notice_commentYN").addClass("on");
				}
			}
		}
		
		//자원
		var resourceListHTML = "";
		if(resource.length > 0){
			$(resource).each(function(){
				var resourceID = $$(this).attr("FolderID");
				var resourceName = $$(this).attr("ResourceName");
				
				var dataJson = "data-json=\'" + JSON.stringify({"label":resourceName,"value":resourceID}) + "\'";
				var dataValue = "data-value=\"" + resourceID + "\"";
				
				resourceListHTML += "<a onclick=\"mobile_schedule_delUser(this);\" class=\"btn_add_person\" " + dataJson + " " + dataValue + " value=\"" + resourceID + "\" label=\"" + resourceName + "\">";
				resourceListHTML += 		resourceName;
				resourceListHTML += "</a>";
			});
			if(resourceListHTML != "") {
				$("#resourcesSelect_wrapArea").append(resourceListHTML).show();
				$("#resourceSelectTitle").hide();
				$("#resourcesSelect_wrapArea").parent().addClass("active");
			}			
		}
		
		//참석자
		var attendeeListHTML = "";
		if(attendee.length > 0){
			$(attendee).each(function(){
				var userCode = $$(this).attr("UserCode");
				var userName = $$(this).attr("UserName");
				
				var dataJson = "data-json=\'" + JSON.stringify({"UserCode":userCode,"UserName":userName, "label":userName,"value":userCode}) + "\'";
				var dataValue = "data-value=\"" + userCode + "|" + this.IsAllow + "\"";
				
				attendeeListHTML += "<a onclick=\"mobile_schedule_delUser(this);\" class=\"btn_add_person\" " + dataJson + " " + dataValue + ">";
				attendeeListHTML += userName;
				attendeeListHTML += "</a>";
			});
			$("#joins_wrapArea").append(attendeeListHTML).show();
		}
		
		if(event.IsInviteOther == "Y"){
			$("#schedule_write_isinviteother").trigger("click");
		}
		
		// Description
		var setDescription = event.Description.split('&nbsp;').join(' ').replace(/(\r\n|\n|\n\n)/gi, '<br />');
		$("#schedule_write_description").val(setDescription);
		
		//$("#schedule_write_alarmdiv").hide();
	}
}

/*
//TODO : 주소...
//주소 하나만 입력하도록
function mobile_schedule_DeletePlaceInput(){
	
	if(coviCtrl.getAutoTags("Place").length > 0){
		$("#schedule_view_place").hide();
	}else{
		$("#schedule_view_place").show();
	}
}
*/

//조회 화면에서 반복에 대한 메시지
function mobile_schedule_GetRepeatViewMessage(repeatInfo){
	var returnMessage = "";
	
	var sAppointmentStartTime = $(repeatInfo).attr("AppointmentStartTime");
    var sAppointmentEndTime = $(repeatInfo).attr("AppointmentEndTime");
    
	var sRepeatType = $(repeatInfo).attr("RepeatType");
	var sRepeatStartDate = $(repeatInfo).attr("RepeatStartDate");
	var sRepeatEndDate = $(repeatInfo).attr("RepeatEndDate");
	var sRepeatEndType = $(repeatInfo).attr("RepeatEndType");
	var sRepeatCount = $(repeatInfo).attr("RepeatCount");
	var sRepeatAppointType = $(repeatInfo).attr("RepeatAppointType");
	
    var sRepeatYear = $(repeatInfo).attr("RepeatYear");
    var sRepeatMonth = $(repeatInfo).attr("RepeatMonth");
    var sRepeatWeek = $(repeatInfo).attr("RepeatWeek");
    var sRepeatDay = $(repeatInfo).attr("RepeatDay");
	
    var sRepeatMonday = $(repeatInfo).attr("RepeatMonday");
    var sRepeatTuesday = $(repeatInfo).attr("RepeatTuesday");
    var sRepeatWednseday = $(repeatInfo).attr("RepeatWednseday");
    var sRepeatThursday = $(repeatInfo).attr("RepeatThursday");
    var sRepeatFriday = $(repeatInfo).attr("RepeatFriday");
    var sRepeatSaturday = $(repeatInfo).attr("RepeatSaturday");
    var sRepeatSunday = $(repeatInfo).attr("RepeatSunday");
    
    var l_DateString = "";
    
	returnMessage += mobile_comm_replaceAll(mobile_comm_getDic("lbl_From0"), "{0}", sRepeatStartDate) + " ";			// {0}부터
	
	if(sRepeatEndType == "R"){
		returnMessage += mobile_comm_replaceAll(mobile_comm_getDic("lbl_Atimes"), "{0}", sRepeatCount) + " ";			//	{0} 회
	}else{
		returnMessage += mobile_comm_replaceAll(mobile_comm_getDic("lbl_To0"), "{0}", sRepeatEndDate) + " ";			// 	{0}까지
	}
    
	switch (sRepeatType){
	case "D":
		if(sRepeatAppointType == "A"){
			returnMessage += mobile_comm_replaceAll(mobile_comm_getDic("lbl__EveryDays0"), "{0}", sRepeatDay) + " ";		//	매 {0}일마다
		}else{
			returnMessage += mobile_comm_getDic("lbl_SchEveryday") + " ";		//	매일(평일)에
		}
		break;
	case "W":
		returnMessage += mobile_comm_replaceAll(mobile_comm_getDic("lbl_EveryNumWeek"), "{0}", sRepeatWeek) + " ";	//  매{0}주
		break;
	case "M": case "Y":
		if(sRepeatAppointType == "A"){
			if(sRepeatType == "M"){
				returnMessage += mobile_comm_replaceAll(mobile_comm_replaceAll(mobile_comm_getDic("lbl_EveryMonthsDays01"), "{0}", sRepeatMonth), "{1}", sRepeatDay) + " ";			// {0}개월마다 {1}일에
			}
			else if(sRepeatType == "Y"){
				returnMessage += mobile_comm_replaceAll(mobile_comm_replaceAll(mobile_comm_getDic("lbl_EveryYearOn"), "{0}", sRepeatYear), "{1}", sRepeatMonth);		//	{0}년마다 {1}월 {2}에
			}
		}else{
			switch (sRepeatWeek) {
			case "1":
				l_DateString = mobile_comm_getDic("lbl_FirstWeek") + " ";		//첫번째 주
				break;
			case "2":
				l_DateString = mobile_comm_getDic("lbl_SecondWeek") + " ";	//두번째주
				break;
			case "3":
				l_DateString = mobile_comm_getDic("lbl_ThirdWeek") + " ";		//세번째주
				break;
			case "4":
				l_DateString = mobile_comm_getDic("lbl_FourthWeek") + " ";	//네번째주
				break;
			case "5":
				l_DateString = mobile_comm_getDic("lbl_FifthWeek") + " ";		//다섯번째주
				break;
			default:
				break;
			}
			if(sRepeatDay != "0"){
				switch (sRepeatDay) {
				case "1":
					l_DateString = mobile_comm_getDic("lbl_Sunday0") + " ";			//일요
					break;
				case "2":
					l_DateString = mobile_comm_getDic("lbl_Monday0") + " ";		//월요
					break;
				case "3":
					l_DateString = mobile_comm_getDic("lbl_Tuesday0") + " ";		//화요
					break;
				case "4":
					l_DateString = mobile_comm_getDic("lbl_Wednesday0") + " ";	//수요
					break;
				case "5":
					l_DateString = mobile_comm_getDic("lbl_Thursday0") + " ";		//목요
					break;
				case "6":
					l_DateString = mobile_comm_getDic("lbl_Friday0") + " ";			//금요
					break;
				case "7":
					l_DateString = mobile_comm_getDic("lbl_Saturday0") + " ";		//토요
					break;
				default:
					break;
				}
			}else{
				if (sRepeatSunday == "Y") l_DateString += mobile_comm_getDic("lbl_Sunday0");
				if (sRepeatMonday == "Y") l_DateString += mobile_comm_getDic("lbl_Monday0");
				if (sRepeatTuesday == "Y") l_DateString += mobile_comm_getDic("lbl_Tuesday0");
				if (sRepeatWednseday == "Y") l_DateString += mobile_comm_getDic("lbl_Wednesday0");
				if (sRepeatThursday == "Y") l_DateString += mobile_comm_getDic("lbl_Thursday0");
				if (sRepeatFriday == "Y") l_DateString += mobile_comm_getDic("lbl_Friday0");
				if (sRepeatSaturday == "Y") l_DateString += mobile_comm_getDic("lbl_Saturday0");
			}
			if(sRepeatType == "M"){
				returnMessage += mobile_comm_replaceAll(mobile_comm_replaceAll(mobile_comm_getDic("lbl_EveryMonthsDays01"), "{0}", sRepeatMonth), "{1}", l_DateString) + " ";			// {0}개월마다 {1}일에
			}
			else if(sRepeatType == "Y"){
				returnMessage += mobile_comm_replaceAll(mobile_comm_replaceAll(mobile_comm_replaceAll(mobile_comm_getDic("lbl_EveryYearOn"), "{0}", sRepeatYear), "{1}", sRepeatMonth), "{2}", l_DateString);	//	{0}년마다 {1}월 {2}에
			}
		}
		break;
	}
	returnMessage += mobile_comm_replaceAll(mobile_comm_replaceAll(mobile_comm_getDic("lbl_RepeteSettingAtoB"), "{0}", sAppointmentStartTime), "{1}", sAppointmentEndTime) + " ";			// {0}부터 {1}까지 반복 설정
	
	return returnMessage;
}

//구글 캘린더 이벤트 - 데이터 가져오기
function mobile_schedule_GetGoogleEventOne(mode, eventID, callBack1, callBack2, isAsync){
	var params = {};
	var url = "/covicore/oauth2/client/callGoogleRestAPI.do";
	
	$.ajax({
	    url: url,
	    type: "POST",
	    async : isAsync,
	    data: {
	    	"url" : "https://www.googleapis.com/calendar/v3/calendars/primary/events/"+eventID,
	    	"type" : "GET",
	    	"userCode" : mobile_comm_getSession("USERID"),
	    	"params" : JSON.stringify(params)
	    },
	    success: function (res) {
	    	if(res.status == "200"){
	    		callBack1(mode, res.data, callBack2);
	    	}else{
	    		//alert(mobile_comm_getDic("msg_apv_030"));		// 오류가 발생했습니다.
	    	}
        },
        error:function(response, status, error){
        	mobile_comm_ajaxerror(url, response, status, error);
        	//alert("ERROR");
		}
	});
}

//수정 버튼 클릭
function mobile_schedule_clickmodify(pTarget){
	var target = (typeof pTarget != 'undefined') ? pTarget : "";

	var sUrl = "/groupware/mobile/schedule/write.do";
	sUrl += "?eventid=" + _mobile_schedule_view.EventID ;
	sUrl += "&dateid=" + _mobile_schedule_view.DateID ;
	sUrl += "&iscommunity=" + _mobile_schedule_view.IsCommunity;
	sUrl += "&folderid=" + _mobile_schedule_view.FolderID;
	sUrl += "&isrepeat=" + _mobile_schedule_view.IsRepeat;
	sUrl += "&repeatid=" + _mobile_schedule_view.RepeatID;
	
	if(_mobile_schedule_view.IsRepeat == "Y" && (target != '' && $(target).attr("data-schedule-scope") == 'all')) { //반복일정 사용시
		sUrl += "&isrepeatall=" + "Y" ;
	}
	
	isSchUpdate = true;
	mobile_comm_go(sUrl, 'Y');
	
}

//삭제 버튼 클릭
function mobile_schedule_clickdelete(){
	
	var url = "/groupware/mobile/schedule/remove.do";
		
	if(Number(_mobile_schedule_view.EventID)){
		$.ajax({
		    url: url,
		    type: "POST",
		    data: {
		    	"EventID" : _mobile_schedule_view.EventID
			},
			success: function (res) {
		    	if(res.status == "SUCCESS"){
		    		alert(mobile_comm_getDic("msg_deleteSuccess")); //성공적으로 삭제하였습니다.
		    		//이전 페이지로 되돌아감
		    		mobile_comm_back();
		    		mobile_schedule_reloadPrevPage();
		    	} else {
		    		alert(mobile_comm_getDic("msg_apv_030"));		// 오류가 발생했습니다.
				}
		    },
		    error:function(response, status, error){
				mobile_comm_ajaxerror(url, response, status, error);
			}
		});
	}else{
		alert(mobile_comm_getDic("msg_deleteGoogleSch").split(".")[0]); //구글 캘린더에 있는 일정을 삭제합니다.
		mobile_schedule_deleteGoogleEventOne(_mobile_schedule_view.EventID);
	}
}

//구글 일정 삭제
function mobile_schedule_deleteGoogleEventOne(eventID){
	var params = {};
	var url = "/covicore/oauth2/client/callGoogleRestAPI.do";
	
	$.ajax({
	    url: url,
	    type: "POST",
	    data: {
	    	"url" : "https://www.googleapis.com/calendar/v3/calendars/primary/events/"+eventID,
	    	"type" : "DELETE",
	    	"userCode" : mobile_comm_getSession("USERID"),
	    	"params" : JSON.stringify(params)
	    },
	    success: function (res) {
	    	if(res.status == "204"){
	    		alert(mobile_comm_getDic("msg_deleteSuccess")); //성공적으로 삭제하였습니다.
	    		//이전 페이지로 되돌아감
	    		mobile_comm_back();
	    		mobile_schedule_reloadPrevPage();
	    	}else{
	    		alert(mobile_comm_getDic("msg_apv_030"));		// 오류가 발생했습니다.
	    	}
        },
        error:function(response, status, error){
        	mobile_comm_ajaxerror(url, response, status, error);
		}
	});
}

//조회화면에서 알림 개별 설정
function mobile_schedule_saveAlarm(pObj){

	var eventID = _mobile_schedule_view.EventID;
	var isNotification = "Y";
	var isReminder = $("#schedule_view_isremindera").parent().hasClass('on') ? "Y" : "N";
	var reminderTime = $("#schedule_view_remindertime option:selected").val();
	var isComment = $("#schedule_view_isrcommenta").parent().hasClass('on') ? "Y" : "N";
	var dateID = _mobile_schedule_view.DateID;
	var updateType = "";
	var folderID = _mobile_schedule_view.FolderID;
	var folderType = _mobile_schedule_view.FolderType;	
	var subject = $("#schedule_view_subject").text();
	
	//ui 변화가 먼저 발생하지 않기 때문에, 변경하고자 하는 값에 대한 추가 처리 필요
	if(pObj != undefined && $(pObj).find('span') != null && $(pObj).find('span') != undefined) {
		if($(pObj).find('span').attr('id') == "schedule_view_isremindera") {
			isReminder = (isReminder == "Y" ? "N" : "Y");
			$('#schedule_view_notice_divReminderTime').css('visibility', (isReminder == "Y" ? 'visible' : 'hidden'));
			updateType = "Reminder";
		} else if($(pObj).find('span').attr('id') == "schedule_view_isrcommenta") {
			isComment = (isComment == "Y" ? "N" : "Y");
			updateType = "Comment";
		}
	}
	
	if($(pObj).hasClass('on')){
		$(pObj).removeClass('on');
	} else {
		$(pObj).addClass('on');
	}
	
	var url = "/groupware/mobile/schedule/setNotification.do";
	$.ajax({
	    url: url,
	    type: "POST",
	    data: {
	    	"UpdateType" : updateType,  //All or Comment or Reminder
	    	"EventID" : eventID,
			"DateID" : dateID,
	    	"RegisterCode" : mobile_comm_getSession("UR_Code"),
	    	"IsNotification" : isNotification,
	    	"IsReminder" : isReminder,
	    	"ReminderTime" : reminderTime,
	    	"IsCommentNotification" : isComment,
			"FoderID" : folderID,
	    	"FolderType": folderType,
	    	"Subject" : subject
	    },
	    success: function (res) {
	    	if(res.status == "SUCCESS"){
	    		alert(mobile_comm_getDic("msg_changeAlarmSetting")); //알림 설정을 수정하였습니다.
	    	}else{
	    		alert(mobile_comm_getDic("msg_apv_030"));		// 오류가 발생했습니다.
	    	}
	    },
	    error:function(response, status, error){
	    	mobile_comm_ajaxerror(url, response, status, error);
		}
	});
}

//참석 요청 승인/거부 : 대기 -> 승인/거부
function mobile_schedule_approve(pIsAllow){
	var mode = "APPROVAL";
	var eventID = _mobile_schedule_view.EventID;
	
	//승인 상태이면 -> 거부로 변경
	if(pIsAllow == "Y"){
		mode = "REJECT";
		$("dd[onclick] span").removeClass();
		$("dd[onclick] span").addClass("flag_cr01");
		$("dd[onclick] span").text(mobile_comm_getDic("lbl_schedule_Nonparticipation")); //비참여
	} else {
		$("dd[onclick] span").removeClass();
		$("dd[onclick] span").addClass("flag_cr02");
		$("dd[onclick] span").text(mobile_comm_getDic("lbl_schedule_participation")); //참여
	}
	
	var url = "/groupware/mobile/schedule/approve.do";
	$.ajax({
	    url: url,
	    type: "POST",
	    data: {
	    	"mode" : mode,
	    	"EventID" : eventID,
	    	"UserCode" : mobile_comm_getSession("UR_Code")
		},
	    success: function (res) {
	    	if(res.status == "SUCCESS"){
	    		alert(mobile_comm_getDic("msg_117")); //성공적으로 저장하였습니다.
	    	} else {
	    		alert(mobile_comm_getDic("msg_apv_030"));		// 오류가 발생했습니다.
			}
	    },
	    error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
}

//시작일시/종료일시 Validation Check
function mobile_schedule_chkDateValidation(from) {
	
	//날짜 입력값 유효성 검사 추가
	if(from == "SD" || from == "ED") {
		try {
			var	dtCheck = new Date($("#schedule_write_startday").val().substring(5,7)+'/'+$("#schedule_write_startday").val().substring(8,10)+'/'+$("#schedule_write_startday").val().substring(0,4)+' 00:00:00');
			if(from == "ED") {
				dtCheck = new Date($("#schedule_write_endday").val().substring(5,7)+'/'+$("#schedule_write_endday").val().substring(8,10)+'/'+$("#schedule_write_endday").val().substring(0,4)+' 00:00:00');
			}
			if((dtCheck.getDate() + "") == "NaN") {
				alert(mobile_comm_getDic("msg_InValidDateInput"));		//날짜 입력값이 잘못 되었습니다.
				
				if(from == "SD") {
					var date = _mobile_schedule_common.CurrentTime;
					if (mobile_comm_getQueryString('date', 'schedule_write_page') != 'undefined') {
						date = new Date(mobile_schedule_ReplaceDate(mobile_comm_getQueryString('date', 'schedule_write_page')));
					}
					$("#schedule_write_startday").val(mobile_schedule_SetDateFormat(date, '.'));
				} else if(from == "ED") {
					$("#schedule_write_endday").val($("#schedule_write_startday").val());
				}
				
				return false;
			}
		} catch (e) {
			alert(mobile_comm_getDic("msg_InValidDateInput"));		//날짜 입력값이 잘못 되었습니다.
			return false;
		}
	}
	
	//날짜 변경 시 validation
	if(from == "SD"){
		if($("#schedule_write_startday").val() > $("#schedule_write_endday").val()){
			$("#schedule_write_endday").val($("#schedule_write_startday").val());
		}
		
		if($("#schedule_write_startday").val() == $("#schedule_write_endday").val() && $("#schedule_write_starttime").val() > $("#schedule_write_endtime").val()) {
			$("#schedule_write_endtime").val($("#schedule_write_starttime").val());
		}
	} else if(from == "ED"){
		if($("#schedule_write_startday").val() > $("#schedule_write_endday").val()){
			$("#schedule_write_startday").val($("#schedule_write_endday").val());
		}
		
		if($("#schedule_write_startday").val() == $("#schedule_write_endday").val() && $("#schedule_write_starttime").val() > $("#schedule_write_endtime").val()) {
			$("#schedule_write_starttime").val($("#schedule_write_endtime").val());
		}
	} else if(from == "ST"){
		if($("#schedule_write_startday").val() >= $("#schedule_write_endday").val()){
			if($("#schedule_write_starttime").val() > $("#schedule_write_endtime").val()){
				$("#schedule_write_endtime").val($("#schedule_write_starttime").val());
			}
		}
	} else if(from == "ET"){
		if($("#schedule_write_startday").val() >= $("#schedule_write_endday").val()){
			if($("#schedule_write_starttime").val() > $("#schedule_write_endtime").val()){
				$("#schedule_write_starttime").val($("#schedule_write_endtime").val());
			}
		}
	}
	
	/*if(Math.round(Math.abs((start_date.getTime() - now_date.getTime())/(oneDay))) >= 30){ //시작일이 오늘+30일 이후인 경우
		//alert(mobile_comm_getDic("msg_resource_CannotReserve30DayAfter"));
		$("#schedule_write_startday").val(mobile_comm_getDateTimeString("yyyy.MM.dd", new Date(now_date.setDate(now_date.getDate() + 29))));
		$("#schedule_write_endday").val($("#schedule_write_startday").val());
	}
	
	if(Math.round(Math.abs((end_date.getTime() - now_date.getTime())/(oneDay))) >= 30){ //종료일이 오늘+30일 이후인 경우
		//alert(mobile_comm_getDic("msg_resource_CannotReserve30DayAfter"));
		now_date = new Date();
		$("#schedule_write_endday").val(mobile_comm_getDateTimeString("yyyy.MM.dd", new Date(now_date.setDate(now_date.getDate() + 29))));
	}*/
		
}

//전체 미리알림 체크박스 변경 이벤트
function mobile_schedule_changeTotalReminder(obj) {
	$("#schedule_view_totalremindertime").prop("disabled", !$(obj).prop("checked"));
}

//전체 알림 수정
function mobile_schedule_modifyAllNoti() {
	var eventID = _mobile_schedule_view.EventID;
	var notiInfo = {};
	
	notiInfo.reminder = $("#schedule_view_totalisremindera").prop("checked") ? "Y" : "N";
	notiInfo.reminderTime = $("#schedule_view_totalremindertime").val();
	notiInfo.comment = $("#schedule_view_totalisrcomment").prop("checked") ? "Y" : "N";
	
	// eventID 기준으로 현재 사용자의 모든 알림 수정 (데이터가 기본적으로 입력되있는 상태는 아니므로 Delete -> Insert)
	$.ajax({
	    url: "/groupware/mobile/schedule/modifyAllNoti.do",
	    type: "POST",
	    data: {EventID : eventID, NotiInfo : JSON.stringify(notiInfo)},
	    async: false,
	    success: function (res) {
	    	if(res.status == "SUCCESS"){
	    		alert(mobile_comm_getDic("msg_SuccessModify"));
	    		if($("#schedule_view_page").attr("IsLoad") == "Y"){
	    			mobile_schedule_ViewInit();
	    		} 		
	    	}else{
	    		alert(mobile_comm_getDic("msg_apv_030"));
	    	}
        },
        error:function(response, status, error){
        	mobile_comm_ajaxerror(url, response, status, error);			
		}
	});
}

//전체 알림 삭제
function mobile_schedule_deleteAllNoti() {
	var eventID = _mobile_schedule_view.EventID;
		
	// eventID 기준으로 현재 사용자의 모든 알림 제거
	$.ajax({
	    url: "/groupware/mobile/schedule/deleteAllNoti.do",
	    type: "POST",
	    data: {EventID : eventID},
	    async: false,
	    success: function (res) {
	    	if(res.status == "SUCCESS"){
	    		alert(mobile_comm_getDic("msg_SuccessModify"));
	    		if($("#schedule_view_page").attr("IsLoad") == "Y"){
	    			mobile_schedule_ViewInit();
	    		}	
	    	}else{
	    		alert(mobile_comm_getDic("msg_apv_030"));
	    	}
        },
        error:function(response, status, error){
        	mobile_comm_ajaxerror(url, response, status, error);			
		}
	});
}

function mobile_schedule_closesearch(){
	if (_mobile_schedule_common.SearchText){
		_mobile_schedule_common.SearchText = '';
		mobile_schedule_ListInit('Y');
	}
	$("#mobile_search_input").val('');
}

function setEnd(target){
	$("#schedule_write_repeatday_enddate").prop("disabled", (target.value == 'count'))
}

function mobile_schedule_approve(pMode){
	var url = "/groupware/schedule/approve.do";
	var eventID = mobile_comm_getQueryString('eventid', 'schedule_view_page');
			
	$.ajax({
	    url: url,
	    type: "POST",
	    data: {
	    	"mode" : pMode,
	    	"EventID" : eventID,
	    	"UserCode" : mobile_comm_getSession('UR_Code'),
			"UserMultiName" : mobile_comm_getSession('UR_MultiName')
		},
	    success: function (res) {
	    	if(res.status == "SUCCESS"){
				alert(mobile_comm_getDic("msg_117")); //성공적으로 저장하였습니다.
		
				mobile_schedule_reloadPrevPage();
	    	} else {
				alert(mobile_comm_getDic("msg_apv_030"));		// 오류가 발생했습니다.
			}
	    },
	    error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);			
		}
	});
}

//일정 조회 끝