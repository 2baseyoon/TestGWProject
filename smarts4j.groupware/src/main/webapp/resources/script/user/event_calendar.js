// 좌측 상단 달력
function makeLeftCalendar() {
	var cnt = 0;
	var icnt = 0;
	//var preDay = new Array();
	var tempMonth = parseInt(g_month, 10);
	
	var sDate = "";
	var eDate = "";
	
	var tempDay = g_day;
	
	if (g_viewType == "W") {
		var nDate = new Date(g_year, (tempMonth - 1), tempDay);
		var nDay = nDate.getDay();
		if (nDay != 0) {
			while (nDate.getDay() > 0) {
				nDate.setDate(nDate.getDate() - parseInt(1));
			}
			if (AddFrontZero(tempMonth, 2) == AddFrontZero((nDate.getMonth() + 1), 2)) {
				tempDay = nDate.getDate();
			}
			else {
				if (AddFrontZero(tempMonth, 2) > AddFrontZero((nDate.getMonth() + 1), 2)) {
					while (AddFrontZero(tempMonth, 2) != AddFrontZero((nDate.getMonth() + 1), 2)) {
						//preDay[icnt] = nDate.getDate();
						nDate.setDate(nDate.getDate() + parseInt(1));
						icnt++;
					}
				}
				nDate = new Date(g_year, (tempMonth - 1), 1);
				cnt += nDate.getDay();
				tempDay = 1;
			}
		}
	}

	var nfirstdate = new Date(g_year, (tempMonth - 1), 1);
	var nfirstweek = nfirstdate.getDay();
	var nlastdate = new Date(g_year, tempMonth, 0);
	var nlastday = nlastdate.getDate();

	//개별호출 일괄호출
	//커뮤니티에서는 좌측달력이 없기 때문에 다국어 깨지는 오류가 있어 함수로 변경
	getCalendarDic();
	
	var dtmsg = "<div class='tblCalTr'>" +
			"<div>" + coviDic.dicMap["lbl_WPSun"] + "</div>" +
			"<div>" + coviDic.dicMap["lbl_WPMon"] + "</div>" +
			"<div>" + coviDic.dicMap["lbl_WPTue"] + "</div>" +
			"<div>" + coviDic.dicMap["lbl_WPWed"] + "</div>" +
			"<div>" + coviDic.dicMap["lbl_WPThu"] + "</div>" +
			"<div>" + coviDic.dicMap["lbl_WPFri"] + "</div>" +
			"<div>" + coviDic.dicMap["lbl_WPSat"] + "</div>" +
			"</div>";

	var d = 0;
	var ntdsum = nlastday + nfirstweek;
	var dmsg = "";
	var weekly = 1;

	var preYear = "";
	var preMonth = "";

	if ((parseInt(tempMonth) - 1) < 1) // tempMonth == 0 이전년도 12월로 변경
	{
		preMonth = AddFrontZero(12, 2);
		preYear = parseInt(g_year) - 1; // 이전년도 설정
	} else {
		preMonth = AddFrontZero(parseInt(tempMonth) - 1, 2);
		preYear = g_year;
	}
	var nextYear = "";
	var nextMonth = "";
	if ((parseInt(tempMonth) + 1) > 12) // tempMonth == 13일때 다음년도 1월로 변경
	{
		nextMonth = AddFrontZero(1, 2);
		nextYear = parseInt(g_year) + 1;
	} else {
		nextMonth = AddFrontZero(parseInt(tempMonth) + 1, 2);
		nextYear = g_year;
	}

	dmsg += "<div class='tblCalTr'>";
	var tdfc = "";
	var i;
	for (i = 0; i < ntdsum; i++) {
		if (i < nfirstweek) {
			/*if(preDay == "") {
				tdfc = "CalPervMon";
			}*/
			
			tdfc = "CalPervMon";
			dmsg += "<div class='calendarDate " + tdfc + "' month = '" + parseInt(preMonth) + "' weekly = '" + weekly + "'></div>";
		}
		else {
			d++;
			tdfc = "";

			// 예약 현황 보기 별 날짜 선택 표시
			if (g_viewType == "W") { // 주간
				if (d == tempDay) {
					if (cnt < 6) {
						tempDay++;
					}
					cnt++;
				} // 선택날짜 표시
			}

			if (g_year == g_currentTime.getFullYear() && g_month == (g_currentTime.getMonth() + 1) && d == g_currentTime.getDate()) { tdfc = "calendarToday"; } // 오늘날짜 표시 
			dmsg += "<div class='calendarDate " + tdfc + "' month = '" + tempMonth + "' id= '" + d + "' weekly = '" + weekly + "' >";
			dmsg += "<a onclick = \"gotoDiaryView('" + g_year + "." + AddFrontZero(tempMonth, 2) + "." + AddFrontZero(d, 2) + "');\"><span>" + d + "</span></a></div>";
		}
		if (i < ntdsum - 1 && ((i + 1) % 7) == 0) {
			dmsg += "</div><div class='tblCalTr'>"; weekly++;
		}
		
	}
	
	--tempDay;
	if (7 - (ntdsum % 7) > 0 && (ntdsum % 7) > 0) {
		for (i = 0; i < (7 - (ntdsum % 7)); i++) {
			if(tempDay <= nlastday) {
				tdfc = "CalNextMon";
			}
			if (i == 0 && (ntdsum % 7) == 0) { tdfc = ""; }
			
			var paramDateTempStr = nextYear + "." + AddFrontZero(nextMonth,2) + "." + AddFrontZero((i + 1),2);
			dmsg += "<div class='calendarDate " + tdfc + "'  month = '" + Number(nextMonth) + "' weekly = '" + weekly + "' id='"+(i + 1)+"'><a onclick = \"gotoDiaryView('" + paramDateTempStr + "');\"><span>" + (i + 1) + "</span></a></div>";
			
			eDate = paramDateTempStr;
		}
	}
	
	dmsg += "</div>";

	$("#leftCalendar").html(dtmsg + "<div id='cal_body'>" + dmsg + "</div>");

	var ltm = tempMonth - 1;
	var lty = g_year;

	if (ltm < 1) { lty = g_year - 1; ltm = 12; }
	var tlastdate = new Date(lty, ltm, 0);
	var tlastday = tlastdate.getDate();
	var btcnt = -1;

	for (i = 0; i < 7; i++) {
		if ($("#cal_body").find("div:first").find("div")[i].innerText.trim() == "") btcnt++;
	}

	var tfirstday = tlastday - btcnt;
	for (i = 0; i <= btcnt; i++) {
		if (i == 0) {
			var paramDateStr = preYear + "." + AddFrontZero(preMonth,2) + "." + AddFrontZero((tfirstday + i),2);
			sDate = paramDateStr;
			
			$("#cal_body").find("div:first").find("div")[i].innerHTML = "<a onclick = \"gotoDiaryView('" + paramDateStr + "');\" style='color:#ff9999;'><span>" + (tfirstday + i) + "</span></a>";
		} else {
			$("#cal_body").find("div:first").find("div")[i].innerHTML = "<a onclick = \"gotoDiaryView('" + preYear + "." + AddFrontZero(preMonth,2) + "." + AddFrontZero((tfirstday + i),2) + "');\"><span>" + (tfirstday + i) + "</span></a>";
		}
		$("#cal_body").find("div:first").find("div").eq(i).attr("id", tfirstday + i);

		// class 추가로 변경 필요
		$("#cal_body").find("div:first").find("div")[i].innerText.className = "calendarDate CalPervMon";
	}
	
	if(btcnt == -1){ //선택된 달의 1일이 일요일인 경우 
		sDate = schedule_SetDateFormat(nfirstdate, ".");
	}
	
	if(ntdsum % 7 == 0){
		var eDateObj = new Date(replaceDate(sDate));
		eDateObj.setDate(eDateObj.getDate() + (ntdsum-1));
		eDate = schedule_SetDateFormat(eDateObj, ".");
	}
	
	// 현재 선택한 날짜를 달력에 표시하기
	if(g_viewType == "W"){
		var weeklyVal = $("#cal_body").find("div[month="+Number(g_month)+"][id="+Number(g_day)+"]").attr("weekly");
		$("#cal_body").find("div[weekly="+weeklyVal+"]").addClass("calendarSelected");
	}
	else if(g_viewType == "D"){
		$("#cal_body").find("div[month="+Number(g_month)+"][id="+Number(g_day)+"]").addClass("calendarSelected_d");
	}
	
	// 예약 되어 있는 날짜에 대해서 표시하기
	var CLBIZ = CFN_GetQueryString("CLBIZ");
	
	if(CLBIZ.toUpperCase() == "SCHEDULE"){
		scheduleUser.setLeftCalendarEvent(g_year, sDate, eDate);
	}else if(CLBIZ.toUpperCase() == "RESOURCE"){
		resourceUser.setLeftCalendarEvent(g_year, sDate, eDate);
	}
}

// 좌측 달력 이동
function gotoDiaryView(date){
	//업무시간 체크 초기화
	//g_isWorkTime = false; //업무시간 초기화 원치 않을 경우 주석 처리
	
	var CLSYS = CFN_GetQueryString("CLSYS");
	var CLBIZ = CFN_GetQueryString("CLBIZ");
	
	// 커뮤니티 연동을 위함
	var CSMU = CFN_GetQueryString("CSMU");
	var communityId = CFN_GetQueryString("communityId");
	var activeKey = CFN_GetQueryString("activeKey");
	
	var url = CLSYS+"_View.do?CLSYS="+CLSYS+"&CLMD=user&CLBIZ="+CLBIZ+(CSMU == "undefined" ? "" : "&CSMU="+CSMU+"&communityId="+communityId+"&activeKey="+activeKey)+"&viewType=D"+"&startDate="+date+"&endDate="+date;
	CoviMenu_GetContent(url);
	g_lastURL = url;
}

// 좌측 상단 달력 달 이동
function moveLeftMonth(v) {
	if (v == "+") {
		g_month++;
		if (g_month > 12) { g_year++; g_month = 1; }
	} else {
		g_month--;
		if (g_month < 1) { g_year--; g_month = 12; }
	}
	if (g_viewType == "W") {
		var dt = new Date(parseInt(g_year), (parseInt(g_month) - 1), parseInt(g_day));
		dt.setDate(parseInt(dt.getDate()) - parseInt(6));
		g_day = dt.getDate();
	}

	var selDate = new Date(parseInt(g_year), (parseInt(g_month) - 1));
	var sdate = "";
	var edate = "";
	var sURL = "";
	var type = "";
	
	if (CFN_GetQueryString("viewType") == "undefined") {
		if (parseInt(g_day) >= 30) {
			switch (parseInt(g_month)) {
				case 2:
				case 4:
				case 6:
				case 9:
				case 11:
					var last = new Date(parseInt(g_year), (parseInt(g_month)), "");
					g_day = last.getDate();
					selDate.setDate(g_day);
					sdate = selDate.getFullYear() + "." + AddFrontZero(selDate.getMonth() + 1, 2) + "." + AddFrontZero(selDate.getDate(), 2);
					edate = selDate.getFullYear() + "." + AddFrontZero(selDate.getMonth() + 1, 2) + "." + AddFrontZero(selDate.getDate(), 2);
					break;
				case 1:
				case 3:
				case 5:
				case 7:
				case 8:
				case 10:
				case 12:
					selDate.setDate(parseInt(g_day));
					sdate = selDate.getFullYear() + "." + AddFrontZero(selDate.getMonth() + 1, 2) + "." + AddFrontZero(selDate.getDate(), 2);
					edate = selDate.getFullYear() + "." + AddFrontZero(selDate.getMonth() + 1, 2) + "." + AddFrontZero(selDate.getDate(), 2);
					break;
			}
		}
		else {
			selDate.setDate(parseInt(g_day));
			sdate = selDate.getFullYear() + "." + AddFrontZero(selDate.getMonth() + 1, 2) + "." + AddFrontZero(selDate.getDate(), 2);
			edate = selDate.getFullYear() + "." + AddFrontZero(selDate.getMonth() + 1, 2) + "." + AddFrontZero(selDate.getDate(), 2);
		}
		type = "D";
	} else {
		type = CFN_GetQueryString("viewType");
		switch (type.toUpperCase()) {
			case "D":
				if (parseInt(g_day) >= 30) {
					switch (parseInt(g_month)) {
						case 2:
						case 4:
						case 6:
						case 9:
						case 11:
							var lastDay = new Date(parseInt(g_year), (parseInt(g_month)), "");
							g_day = lastDay.getDate();
							selDate.setDate(g_day);
							sdate = selDate.getFullYear() + "." + AddFrontZero(selDate.getMonth() + 1, 2) + "." + AddFrontZero(selDate.getDate(), 2);
							edate = selDate.getFullYear() + "." + AddFrontZero(selDate.getMonth() + 1, 2) + "." + AddFrontZero(selDate.getDate(), 2);
							break;
						case 1:
						case 3:
						case 5:
						case 7:
						case 8:
						case 10:
						case 12:
							selDate.setDate(parseInt(g_day));
							sdate = selDate.getFullYear() + "." + AddFrontZero(selDate.getMonth() + 1, 2) + "." + AddFrontZero(selDate.getDate(), 2);
							edate = selDate.getFullYear() + "." + AddFrontZero(selDate.getMonth() + 1, 2) + "." + AddFrontZero(selDate.getDate(), 2);
							break;
					}
				}
				else {
					selDate.setDate(parseInt(g_day));
					sdate = selDate.getFullYear() + "." + AddFrontZero(selDate.getMonth() + 1, 2) + "." + AddFrontZero(selDate.getDate(), 2);
					edate = selDate.getFullYear() + "." + AddFrontZero(selDate.getMonth() + 1, 2) + "." + AddFrontZero(selDate.getDate(), 2);
				}
				break;
			case "W":
				selDate.setDate(parseInt(g_day));
				selDate.setDate(parseInt(selDate.getDate()) - parseInt(selDate.getDay()));
				sdate = selDate.getFullYear() + "." + AddFrontZero(selDate.getMonth() + 1, 2) + ".01";
				selDate.setDate(parseInt(selDate.getDate()) + parseInt(6));
				edate = selDate.getFullYear() + "." + AddFrontZero(selDate.getMonth() + 1, 2) + "." + AddFrontZero(selDate.getDate(), 2);
				
				break;
			case "M": 
			case "LIST":
            case "Y":
            	var first = new Date(selDate.getFullYear(), selDate.getMonth());
				var lastDate = new Date(selDate.getFullYear(), selDate.getMonth() + 1, "");
				sdate = first.getFullYear() + "." + AddFrontZero((first.getMonth() + 1), 2) + "." + AddFrontZero(first.getDate(), 2);
				edate = lastDate.getFullYear() + "." + AddFrontZero((lastDate.getMonth() + 1), 2) + "." + AddFrontZero(lastDate.getDate(), 2);
                break;
		}
	}
	
	var CLSYS = CFN_GetQueryString("CLSYS");
	var CLBIZ = CFN_GetQueryString("CLBIZ");
	
	// 커뮤니티 연동을 위함
	var CSMU = CFN_GetQueryString("CSMU");
	var communityId = CFN_GetQueryString("communityId");
	var activeKey = CFN_GetQueryString("activeKey");
	
	var url = CLSYS+"_View.do?CLSYS="+CLSYS+"&CLMD=user&CLBIZ="+CLBIZ+(CSMU == "undefined" ? "" : "&CSMU="+CSMU+"&communityId="+communityId+"&activeKey="+activeKey)+"&viewType="+type+"&startDate="+sdate+(edate == undefined ? "" : ("&endDate="+edate));
	CoviMenu_GetContent(url);
	g_lastURL = url;
	
	if(CLBIZ == "Schedule")
		scheduleUser.fn_scheduleView_onload();
	else if(CLBIZ == "Resource")
		resourceUser.fn_resourceView_onload();
}


function clickTopButton(liType){
	// double click event prevent
	if (event.detail && event.detail > 1) return false;
	
	//g_isWorkTime = false; //업무시간 초기화 원치 않을 경우 주석 처리
	
	var sDate = "";
	var eDate = "";
	
	var startDateObj = new Date(replaceDate(g_startDate));
	
	if(liType == "D"){		//일간 보기
		if(g_startDate == "" || g_startDate == undefined || ((g_viewType == "M" || g_viewType == "List") && (Number(g_month)-1) == g_currentTime.getMonth())
				|| (g_viewType == "W" && (new Date(replaceDate(g_startDate)).getTime() <= g_currentTime.getTime() && new Date(replaceDate(g_endDate)).getTime() >= g_currentTime.getTime()))){
			sDate = schedule_SetDateFormat(g_currentTime, '.');
			eDate  = sDate;
		}else{
			sDate = g_startDate
			eDate = sDate;
		}
	}
	else if(liType == "W"){		//주간 보기
		var sun;
		
		if((g_viewType == "M" || g_viewType == "List") && (Number(g_month)-1) == g_currentTime.getMonth()){
			sun = schedule_GetSunday(g_currentTime);
			sDate = schedule_SetDateFormat(sun, '.');
			eDate = schedule_SetDateFormat(schedule_AddDays(sDate, 6), '.');
		}else{
			sun = schedule_GetSunday(new Date(replaceDate(g_startDate)));
			sDate = schedule_SetDateFormat(sun, '.');
			eDate = schedule_SetDateFormat(schedule_AddDays(sDate, 6), '.');
		    
		    // 일 -> 주 -> 월을 변경시 달이 바뀌는 것 처리를 위해
            if (sDate.substring(0, 7) != g_startDate.substring(0, 7))
            {
            	sDate = g_startDate.substring(0, 7) + ".01";
            }
		}
	}else if(liType == "M" || liType == "List"){ 		//월간 및 목록보기
		sDate = schedule_SetDateFormat(new Date(g_year, (g_month - 1), 1), '.');
		eDate = schedule_SetDateFormat(new Date(g_year, g_month, 0), '.')
	}else if(liType == "PREV")		// 이전
	{
		if(g_viewType == "D"){
			sDate = schedule_SetDateFormat(schedule_AddDays(startDateObj, -1), '.');
			eDate = sDate;
		}else if(g_viewType == "W"){
			sDate = schedule_SetDateFormat(schedule_AddDays(startDateObj, -7), '.');
			eDate = schedule_SetDateFormat(schedule_AddDays(startDateObj, -1), '.');
		}else if(g_viewType == "M" || g_viewType == "List"){
			eDate = schedule_SetDateFormat(schedule_AddDays(startDateObj.setDate(1), -1), '.');
			sDate = schedule_SetDateFormat(new Date(startDateObj.setMonth(startDateObj.getMonth()-1)).setDate(1), '.');
		}
		liType = g_viewType;
	}else if(liType == "NEXT"){		// 다음
		if(g_viewType == "D"){
			sDate = schedule_SetDateFormat(schedule_AddDays(startDateObj, 1), '.');
			eDate = sDate;
		}else if(g_viewType == "W"){
			sDate = schedule_SetDateFormat(schedule_AddDays(startDateObj, 7), '.');
			eDate = schedule_SetDateFormat(schedule_AddDays(startDateObj, 13), '.');
		}else if(g_viewType == "M" || g_viewType == "List"){
			sDate = schedule_SetDateFormat(new Date(startDateObj.setMonth(startDateObj.getMonth()+1, 1)), '.');
			eDate = schedule_SetDateFormat(new Date(startDateObj.setMonth(startDateObj.getMonth()+1, 0)), '.');
		}
		liType = g_viewType;
	}
	
	g_startDate = sDate;
	g_endDate = eDate;
	
	var CLSYS = CFN_GetQueryString("CLSYS");
	var CLBIZ = CFN_GetQueryString("CLBIZ");
	
	// 커뮤니티 연동을 위함
	var CSMU = CFN_GetQueryString("CSMU");
	var communityId = CFN_GetQueryString("communityId");
	var activeKey = CFN_GetQueryString("activeKey");
	
	var url = CLSYS+"_View.do?CLSYS="+CLSYS+"&CLMD=user&CLBIZ="+CLBIZ+(CSMU == "undefined" ? "" : "&CSMU="+CSMU+"&communityId="+communityId+"&activeKey="+activeKey)+"&viewType="+liType+"&startDate="+g_startDate+(g_endDate == undefined ? "" : ("&endDate="+g_endDate));
	
	if(schFolderId != "" && isCommunity == true){
		url += "&schFolderId=" + schFolderId + "&isCommunity=" + isCommunity;
	}
	
	CoviMenu_GetContent(url);
	g_lastURL = url;
}

//월 달력 그리기
function schedule_MakeMonthCalendar(){
	
	// 상단 제목 날짜 표시
	$('#dateTitle').html(g_year + "." + g_month);
	
	arrSunday = schedule_MakeSunArray(g_startDate);
	var firstDay = new Date(g_year, g_month - 1, 1);
	var strNextYear = g_year;
    var strNextMonth = Number(g_month) + 1;
    
    // 12월일 경우 다음해 1월로. chrome에서 오류로 인해 추가
    if(g_month == 12){
    	strNextYear = Number(g_year)+1;
    	strNextMonth = 1;
    }
    
    var lastDay = schedule_SubtractDays(strNextYear + '/' + strNextMonth + '/' + 1, 1);
    
    // 월간 달력 그리기(달력의 바닥을 그림)
    var backHTML = '';
    
    // 달력 상단
    backHTML += '<div class="calMonHeader">';
    backHTML += '<table class="calMonTbl">';
    backHTML += '<tbody>';
    backHTML += '<tr>';
    backHTML += '<th class="sun">'+coviDic.dicMap["lbl_WPSun"]+'</th>';
    backHTML += '<th>'+coviDic.dicMap["lbl_WPMon"]+'</th>';
    backHTML += '<th>'+coviDic.dicMap["lbl_WPTue"]+'</th>';
    backHTML += '<th>'+coviDic.dicMap["lbl_WPWed"]+'</th>';
    backHTML += '<th>'+coviDic.dicMap["lbl_WPThu"]+'</th>';
    backHTML += '<th>'+coviDic.dicMap["lbl_WPFri"]+'</th>';
    backHTML += '<th>'+coviDic.dicMap["lbl_WPSat"]+'</th>';
    backHTML += '</tr>';
    backHTML += '</tbody>';
    backHTML += '</table>';
    backHTML += '</div>';
    
    if(CFN_GetQueryString("CLBIZ") == "Resource")
    	backHTML += '<div class="calMonBody resMonth" style="position:relative;">';
    else
    	backHTML += '<div class="calMonBody" style="position:relative;">';
    
    for (var i = 0; i < arrSunday.length; i++) {
    	backHTML += schedule_MakeWeekCalendarForMonth(arrSunday[i], firstDay, lastDay, i);
    }
    backHTML += '</div>';
    backHTML += '<article id="read_popup" style="position:absolute;"></aside>';
    $("#MonthCalendar").html(backHTML);
    
    
    //오늘 날짜 표시
    var todayDateStr = schedule_SetDateFormat(g_currentTime, '.');
    $("td[schday='"+todayDateStr+"']").addClass('shcToDay');
    $("td[schday='"+todayDateStr+"']").eq(0).html('<div></div>');
    
    var sDate = schedule_SetDateFormat(arrSunday[0], '-');
	var eDate = schedule_SetDateFormat(schedule_AddDays(arrSunday[arrSunday.length-1], 6), '-');
	
	var CLBIZ = CFN_GetQueryString("CLBIZ");
	if(CLBIZ == "Schedule"){
		scheduleUser.getMonthEventData(sDate, eDate);
		scheduleUser.setSelectableEvent();		//Selectable jquery ui event 바인딩
	}
    else if(CLBIZ == "Resource"){
    	resourceUser.getMonthBookingData(sDate, eDate);
    	if(CFN_GetQueryString("isPopupView") != 'Y')			// TODO 팝업으로 자원을 띄었을 때 간단 등록이나 조회 창을 열면 퍼블리싱 등이 많이 깨짐. 추후 보완 필요
    		resourceUser.setSelectableEvent();							//Selectable jquery ui event 바인딩
    }
}

//월간 달력 그리기(달력의 바닥을 그림)
//월간 달력 그리기(달력의 바닥을 그림)
function schedule_MakeWeekCalendarForMonth(sunday, firstDay, lastDay, index) {
	
    var strSun = schedule_SetDateFormat(sunday, '/');
    var g_sun = sunday;
    var g_mon = schedule_AddDays(strSun, 1);
    var g_tue = schedule_AddDays(strSun, 2);
    var g_wed = schedule_AddDays(strSun, 3);
    var g_thr = schedule_AddDays(strSun, 4);
    var g_fri = schedule_AddDays(strSun, 5);
    var g_sat = schedule_AddDays(strSun, 6);
    var l_arrDays = [g_sun, g_mon, g_tue, g_wed, g_thr, g_fri, g_sat];
    
    //make tag
    var $div = $("<div>",{ class : "calMonWeekRow", week : index, id : "divWeekScheduleForMonth_"+schedule_SetDateFormat(g_sun, "") });
    var $calGridTb = $("<table>",{ class : "calGrid" });
    var $monShcListTb = $("<table>",{ class : "monShcList", id : "tableWeekScheduleForMonth_"+schedule_SetDateFormat(g_sun, "") });
    $calGridTb.append( $("<tbody>").append("<tr>") );
    $monShcListTb.append( $("<tbody>").append("<tr>") );
    
    var $calGridObj 	= $("tr",$calGridTb);
    var $monShcListObj 	= $("tr",$monShcListTb);
    
    l_arrDays.forEach(function(cur){
    	var $calGridTd = $("<td>",{ id : "monthDate", schday : schedule_SetDateFormat(cur, '.') });
    	$calGridObj.append( $calGridTd );
    	
    	var $monShcListTd = $("<td>");
    	var $dayLunar = [1,15].indexOf( cur.getDate() ) > -1 ? $("<span>",{ class : "dayLunar", text : "음"+solarToLunar(cur.getFullYear(), cur.getMonth(), cur.getDate() ) }) : "" ;    	
    	var $strong = $("<strong>").append( cur.getDate() );
    	var $dayInfo = $("<span>",{ class : "day_info", name : "dayInfo", value : schedule_SetDateFormat(cur, '-') });
    	var isDisable = (schedule_GetDiffDates(firstDay, cur, 'day') >= 0) && (schedule_GetDiffDates(lastDay, cur, 'day') <= 0) ? "" : "disable";
    	var isSun = cur === g_sun ? "sun" : "";    	
    	$monShcListTd
    		.addClass( isSun )
    		.addClass( isDisable )
    		.append( $strong )
    		.append( $dayLunar )
    		.append( $dayInfo )
    		.appendTo( $monShcListObj );
    });
    
    $div.append( $calGridTb ).append( $monShcListTb );
    return $div.clone().wrapAll("<div/>").parent().html();    
}

/** 반복 설정 관련 **/
// 반복 설정 팝업
function openSettingRepeat(){
	Common.open("","setRepeat",coviDic.dicMap["lbl_Repeatsettings"], "/groupware/schedule/goRepeat.do?CLBIZ="+CFN_GetQueryString("CLBIZ"), "600px","590px","iframe",true,null,null,true);		//반복설정
}
function getRepeatConfigMessage(jsonObj) {
    var repeatInfoObj = $.parseJSON(jsonObj);
    
    repeatInfoObj = $$(repeatInfoObj).find("ResourceRepeat");
    
    var sAppointmentStartTime = $$(repeatInfoObj).attr("AppointmentStartTime");
    var sAppointmentEndTime = $$(repeatInfoObj).attr("AppointmentEndTime");
    var sRepeatStartDate = $$(repeatInfoObj).attr("RepeatStartDate");
    var sRepeatEndType = $$(repeatInfoObj).attr("RepeatEndType");
    var sRepeatEndDate = $$(repeatInfoObj).attr("RepeatEndDate");
    var sRepeatCount = $$(repeatInfoObj).attr("RepeatCount");

    var sMessage = "";
    if (sRepeatEndType == "R") {
        // 반복횟수 지정
        sMessage = sRepeatStartDate + coviDic.dicMap["lbl_From"] + " ";//XFN_TransDateLocalFormat(sRepeatStartDate) + Common.getDic('lbl_From') + " ";
        sMessage += getRepeatTypeMessage(repeatInfoObj);
        if (sAppointmentStartTime != sAppointmentEndTime) {
            sMessage += sAppointmentStartTime + "-" + sAppointmentEndTime + " ";
        }
        sMessage += sRepeatCount + coviDic.dicMap["lbl_RepeatTimes"];
    }
    else if (sRepeatEndType == "I") {
        // 끝날짜 지정
        sMessage = sRepeatStartDate + coviDic.dicMap["lbl_From"] + " " + sRepeatEndDate + coviDic.dicMap["lbl_Till"] + " ";
        	//XFN_TransDateLocalFormat(sRepeatStartDate) + Common.getDic('lbl_From') + " " + XFN_TransDateLocalFormat(sRepeatEndDate) + Common.getDic('lbl_Till') + " ";
        sMessage += getRepeatTypeMessage(repeatInfoObj);
        if (sAppointmentStartTime != sAppointmentEndTime) {
            sMessage += sAppointmentStartTime + "-" + sAppointmentEndTime + " ";
        }
        sMessage += coviDic.dicMap["lbl_Repeate"];
    }
    else {
        // 무한반복
    }

    return sMessage;
}

// 일정 반복 유형
function getRepeatTypeMessage(repeatInfoObj) {
    var sRepeatType = $$(repeatInfoObj).attr("RepeatType");
    var sRepeatYear = $$(repeatInfoObj).attr("RepeatYear");
    var sRepeatMonth = $$(repeatInfoObj).attr("RepeatMonth");
    var sRepeatWeek = $$(repeatInfoObj).attr("RepeatWeek");
    var sRepeatDay = $$(repeatInfoObj).attr("RepeatDay");

    var sReturnMessage = "";
    
    switch (sRepeatType.toUpperCase()) {
        case "D":
            if (sRepeatDay == "0") {
                sReturnMessage += coviDic.dicMap["lbl_SchEveryday2"]+ " ";
            }
            else if (sRepeatDay == "1") {
                sReturnMessage += coviDic.dicMap["lbl_EveryDay"]+ " ";
            }
            else {
                sReturnMessage += sRepeatDay + coviDic.dicMap["lbl_dayEvery"]+ " ";
            }
            break;
        case "W":
            if (sRepeatWeek == "1") {
                sReturnMessage += coviDic.dicMap["lbl_EveryWeek"]+ " ";
            }
            else {
                sReturnMessage += sRepeatWeek + coviDic.dicMap["lbl_weekEvery2"]+ " ";
            }
            sReturnMessage += getRepeatWeekendMessage(repeatInfoObj)
            break;
        case "M":
            sReturnMessage += sRepeatMonth + coviDic.dicMap["lbl_monthEvery2"]+ " ";
            if (sRepeatDay != "0") {
                sReturnMessage += sRepeatDay + coviDic.dicMap["lbl_SchAtDay"]+ " ";
            }
            else {
                if (sRepeatWeek == 1) {
                    sReturnMessage += coviDic.dicMap["lbl_First"]+ " ";
                }
                else if (sRepeatWeek == 2) {
                    sReturnMessage += coviDic.dicMap["lbl_Second"]+ " ";
                }
                else if (sRepeatWeek == 3) {
                    sReturnMessage += coviDic.dicMap["lbl_Third"]+ " ";
                }
                else if (sRepeatWeek == 4) {
                    sReturnMessage += coviDic.dicMap["lbl_Forth"]+ " ";
                }
                else {
                    sReturnMessage += coviDic.dicMap["lbl_last"] + " ";
                }
                sReturnMessage += getRepeatWeekendMessage(repeatInfoObj);
            }
            break;
        case "Y":
            // n 년 마다
            // n 개월 마다
            if (sRepeatYear == "1") {
                sReturnMessage += coviDic.dicMap["lbl_EveryYear"] + " ";
            }
            else {
                sReturnMessage += coviDic.dicMap["lbl_Every"] + " " + sRepeatYear + coviDic.dicMap["lbl_year"] + " ";
            }
            sReturnMessage += sRepeatMonth + coviDic.dicMap["lbl_monthEvery3"] + " ";
            if (sRepeatDay != "0") {
                sReturnMessage += sRepeatDay + coviDic.dicMap["lbl_SchAtDay"] + " ";
            }
            else {
                if (sRepeatWeek == 1) {
                    sReturnMessage += coviDic.dicMap["lbl_First"] + " ";
                }
                else if (sRepeatWeek == 2) {
                    sReturnMessage += coviDic.dicMap["lbl_Second"] + " ";
                }
                else if (sRepeatWeek == 3) {
                    sReturnMessage += coviDic.dicMap["lbl_Third"] + " ";
                }
                else if (sRepeatWeek == 4) {
                    sReturnMessage += coviDic.dicMap["lbl_Forth"] + " ";
                }
                else {
                    sReturnMessage += coviDic.dicMap["lbl_last"] + " ";
                }
                sReturnMessage += getRepeatWeekendMessage(repeatInfoObj);
            }
            break;
    }
    return sReturnMessage;
}

function getRepeatWeekendMessage(repeatInfoObj) {
    var sRepeatMonday = $$(repeatInfoObj).attr("RepeatMonday");
    var sRepeatTuesday = $$(repeatInfoObj).attr("RepeatTuesday");
    var sRepeatWednseday = $$(repeatInfoObj).attr("RepeatWednseday");
    var sRepeatThursday = $$(repeatInfoObj).attr("RepeatThursday");
    var sRepeatFriday = $$(repeatInfoObj).attr("RepeatFriday");
    var sRepeatSaturday = $$(repeatInfoObj).attr("RepeatSaturday");
    var sRepeatSunday = $$(repeatInfoObj).attr("RepeatSunday");
    var sReturnMessage = "";
    

    if ((sRepeatMonday != "Y") &&
        (sRepeatTuesday != "Y") &&
        (sRepeatWednseday != "Y") &&
        (sRepeatThursday != "Y") &&
        (sRepeatFriday != "Y") &&
        (sRepeatSunday != "Y") &&
        (sRepeatSaturday != "Y")) {
        sReturnMessage = coviDic.dicMap["lbl_OfTheDay"] + " ";
    }
    else if ((sRepeatMonday == "Y") &&
        (sRepeatTuesday == "Y") &&
        (sRepeatWednseday == "Y") &&
        (sRepeatThursday == "Y") &&
        (sRepeatFriday == "Y") &&
        (sRepeatSunday != "Y") &&
        (sRepeatSaturday != "Y")) {
        sReturnMessage = coviDic.dicMap["lbl_Weekdays"] + " ";
    }
    else if ((sRepeatMonday != "Y") &&
        (sRepeatTuesday != "Y") &&
        (sRepeatWednseday != "Y") &&
        (sRepeatThursday != "Y") &&
        (sRepeatFriday != "Y") &&
        (sRepeatSunday == "Y") &&
        (sRepeatSaturday == "Y")) {
        sReturnMessage = coviDic.dicMap["lbl_Sch_Weekend"] + " ";
    }
    else {
        if (sRepeatSunday == "Y") {
            sReturnMessage += coviDic.dicMap["lbl_Sunday"] + " ";
        }
        if (sRepeatMonday == "Y") {
            sReturnMessage += coviDic.dicMap["lbl_Monday"] + " ";
        }
        if (sRepeatTuesday == "Y") {
            sReturnMessage += coviDic.dicMap["lbl_Tuesday"] + " ";
        }
        if (sRepeatWednseday == "Y") {
            sReturnMessage += coviDic.dicMap["lbl_Wednesday"] + " ";
        }
        if (sRepeatThursday == "Y") {
            sReturnMessage += coviDic.dicMap["lbl_Thursday"] + " ";
        }
        if (sRepeatFriday == "Y") {
            sReturnMessage += coviDic.dicMap["lbl_Friday"] + " ";
        }
        if (sRepeatSaturday == "Y") {
            sReturnMessage += coviDic.dicMap["lbl_Saturday"] + " ";
        }
        sReturnMessage = sReturnMessage.substring(0, sReturnMessage.length - 1) + coviDic.dicMap["lbl_DayRepeat_1"] + " ";
    }
    return sReturnMessage;
}
// 반복 일정 조회할 경우 뜨는 팝업 HTML
function getRepeatAllOROnlyHTML(mode, eventID, dateID, folderID, repeatID, openmode){
	var returnHTML = "";
	var qusStr = "";
	var rdoStr1 = "";
	var rdoStr2 = "";
	var isLinkSchedule = "N";
	var _eventID = (eventID == undefined) ? "" : eventID;
	var _dateID = (dateID == undefined) ? "" : dateID;
	var _folderID = (folderID == undefined) ? "" : folderID;
	var _repeatID = (repeatID == undefined) ? "" : repeatID;
	
	if(mode == "V"){		
		qusStr = Common.getDic("msg_ReservationView_01");		//"선택하신 예약은 반복 예약입니다.<br>반복 예약 중 이 항목만 여시겠습니까?";
		rdoStr1 = Common.getDic("lbl_ReservationView_01");		//"이 항목만 열기";
		rdoStr2 = Common.getDic("lbl_ReservationView_02");		//"모두 열기";
	}else if(mode == "U"){
		qusStr = Common.getDic("msg_ReservationView_01_modify");		//"선택하신 예약은 반복 예약입니다.<br>반복 예약 중 이 항목만 수정하시겠습니까?";
		rdoStr1 = Common.getDic("lbl_ReservationView_01_modify");		//"이 항목만 수정하기";
		rdoStr2 = Common.getDic("lbl_ReservationView_02_modify");		//"모두 수정하기";
	}else if(mode == "D"){
		qusStr = Common.getDic("msg_ReservationView_01_delete");		//"선택하신 예약은 반복 예약입니다.<br>반복 예약 중 이 항목만 삭제하시겠습니까?";
		rdoStr1 = Common.getDic("lbl_ReservationView_01_delete");		//"이 항목만 삭제하기";
		rdoStr2 = Common.getDic("lbl_ReservationView_02_delete");		//"모두 삭제하기";
	}
	
	if(openmode != undefined && openmode == "LinkSchedule") {
		isLinkSchedule = "Y";
	}
	
	returnHTML += '<div class="layer_divpop ui-draggable boradPopLayer" id="testpopup_p" style="width: 274px;">';
	returnHTML += '<div class="divpop_contents">';
	returnHTML += '<div class="popContent layerType02 treeDefaultPop">';
	returnHTML += '<div><div>';
	returnHTML += '<span>'+qusStr+'</span>';
	returnHTML += '<div style="margin: 20px 0px;">';
	returnHTML += '<div class="radioStyle04 inpBtnStyle" style="margin-bottom: 10px;">';
	returnHTML += '<input type="radio" name="rdoRepeat" checked="checked" value="only" id="rdoOnlyEvent"><label for="rdoOnlyEvent"><span><span></span></span>'+rdoStr1+'</label>';
	returnHTML += '</div>';
	returnHTML += '<div class="radioStyle04 inpBtnStyle">';
	returnHTML += '<input type="radio" name="rdoRepeat" checked="checked" value="all" id="rdoAllEvent"><label for="rdoAllEvent"><span><span></span></span>'+rdoStr2+'</label>';
	returnHTML += '</div></div></div>';
	returnHTML += '<div class="bottom mt10">';
	returnHTML += '<div><a onclick="goDetailViewFromRepeat(\''+mode+'\', \''+_eventID+'\', \''+_dateID+'\', \''+_folderID+'\', \''+_repeatID+'\', \''+isLinkSchedule+'\');" class="btnTypeDefault btnTypeBg">'+Common.getDic("btn_ok")+'</a><a onclick="Common.Close(\'showRepeat\');" class="btnTypeDefault">'+Common.getDic("btn_Cancel")+'</a></div>';
	returnHTML += '</div></div></div></div></div>';
	
	return returnHTML;
}
//반복에서 확인 버튼 클릭 시 상세 조회로 이동
function goDetailViewFromRepeat(mode, eventID, dateID, folderID, repeatID, isLinkSchedule){
	var isRepeatAll = $("[name=rdoRepeat]:checked").val() == "only" ? "N" : "Y";
	var isRepeat = "Y";
	
	eventID = $("#eventID").val() == undefined ? eventID : $("#eventID").val();
	dateID = $("#dateID").val() == undefined ? dateID : $("#dateID").val();
	
	if(CFN_GetQueryString("CLBIZ") == "Resource"){
		var resourceID = $("#resourceID").val() == undefined ? folderID : $("#resourceID").val();
		repeatID = $("#repeatID").val() == undefined ? repeatID : $("#repeatID").val();
		
		if(CFN_GetQueryString("CLBIZ") == "Portal"){
			Common.open("","resource_detail_pop",Common.getDic("lbl_DetailView"),'/groupware/resource/goResourceDetailPopup.do?CLSYS=resource&CLMD=user&CLBIZ=Resource'			//상세보기
					+ '&eventID=' + eventID 
					+ '&dateID=' + dateID 
					+ "&repeatID=" + repeatID
					+ '&isRepeat=' + isRepeat 
					+ "&isRepeatAll=" + isRepeatAll
					+ '&resourceID=' + resourceID
					+ '&isPopupView=Y',"1050px","632px","iframe",true,null,null,true);
		}else if(isLinkSchedule == "Y") {
			Common.open("","schedule_detail_pop",Common.getDic("lbl_LinkSchedule"),'/groupware/schedule/goScheduleDetailPopup.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule'			//연결일정
					+'&eventID=' + eventID 
					+ '&dateID=' + dateID 
					+ "&repeatID=" + repeatID
					+ '&isRepeat=' + isRepeat 
					+ '&folderID=' + folderID
					+ "&isRepeatAll="+isRepeatAll
					+ "&viewType=Popup","1050px","632px","iframe",true,null,null,true);
		}else if(mode == "V"){
			CoviMenu_GetContent("resource_DetailView.do?CLSYS=resource&CLMD=user&CLBIZ=Resource"
					+ "&eventID=" + eventID
					+ "&dateID=" + dateID
					+ "&repeatID=" + repeatID
					+ "&isRepeat=" + isRepeat
					+ "&isRepeatAll=" + isRepeatAll
					+ "&resourceID=" + resourceID);
		}else if(mode == "U"){
			CoviMenu_GetContent('resource_DetailWrite.do?CLSYS=resource&CLMD=user&CLBIZ=Resource'
					+"&eventID="+eventID
					+"&dateID="+dateID
					+"&isRepeat="+isRepeat
					+"&repeatID=" + repeatID
					+ "&isRepeatAll=" + isRepeatAll
					+"&resourceID=" + resourceID);
		}else if(mode == "D"){
			resourceUser.modifyBookingState('ApprovalCancel', eventID, dateID, resourceID, isRepeatAll);
		}
		
		Common.Close("showRepeat");
	}
	//else if(CFN_GetQueryString("CLBIZ") == "Schedule"){
	// TODO 포탈에서 일정을 접근하기 때문에 임시로 우선 처리. 향후 CLBIZ 이외의 값이 필요함
	else{
		folderID = $("#folderID").val() == undefined ? folderID : $("#folderID").val();
		
		// 커뮤니티 연동을 위함
		var CSMU = CFN_GetQueryString("CSMU");
		var communityId = CFN_GetQueryString("communityId");
		var activeKey = CFN_GetQueryString("activeKey");
		
		if(CFN_GetQueryString("CFN_OpenLayerName") == "MyInfo"){
			//Common.Close();
			window.open("/groupware/layout/schedule_DetailView.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule"
					+(CSMU == "undefined" ? "" : "&CSMU="+CSMU+"&communityId="+communityId+"&activeKey="+activeKey)
					+ "&eventID=" + eventID
					+ "&dateID=" + dateID
					+ "&repeatID=" + repeatID
					+ "&isRepeat=" + isRepeat
					+ "&folderID=" + folderID
					+"&isRepeatAll="+isRepeatAll, "_blank");
		}
		else if(CFN_GetQueryString("CLBIZ") == "Portal"){
			Common.open("","schedule_detail_pop",Common.getDic("lbl_DetailView"),'/groupware/schedule/goScheduleDetailPopup.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule'			//상세보기
					+'&eventID=' + eventID 
					+ '&dateID=' + dateID 
					+ "&repeatID=" + repeatID
					+ '&isRepeat=' + isRepeat 
					+ '&folderID=' + folderID
					+"&isRepeatAll="+isRepeatAll
					+"&viewType=Popup","1050px","632px","iframe",true,null,null,true);
		}else if(mode == "V"){
			CoviMenu_GetContent("/groupware/layout/schedule_DetailView.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule"
					+(CSMU == "undefined" ? "" : "&CSMU="+CSMU+"&communityId="+communityId+"&activeKey="+activeKey)
					+ "&eventID=" + eventID
					+ "&dateID=" + dateID
					+ "&repeatID=" + repeatID
					+ "&isRepeat=" + isRepeat
					+ "&isRepeatAll=" + isRepeatAll
					+ "&folderID=" + folderID);
		}else if(mode == "U"){
			CoviMenu_GetContent('/groupware/layout/schedule_DetailWrite.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule'
					+(CSMU == "undefined" ? "" : "&CSMU="+CSMU+"&communityId="+communityId+"&activeKey="+activeKey)
					+"&eventID="+eventID
					+"&dateID="+dateID
					+ "&repeatID=" + repeatID
					+"&isRepeat="+isRepeat
					+"&isRepeatAll="+isRepeatAll);
		}else if(mode == "D"){
			var setType = (isRepeatAll == "N" ? "RU" : "S");
			scheduleUser.deleteScheduleEvent(setType, eventID, dateID);
		}
		
		Common.Close("showRepeat");
	}
}

// 조회 화면에서 반복에 대한 메시지
function getRepeatViewMessage(repeatInfo){
	return getRepeatConfigMessage(JSON.stringify({"ResourceRepeat":repeatInfo}));
}


// 상세검색 onclick
function btnDetailsOnClick(obj){
	coviInput.setDate();
	
	var mParent = $('.inPerView');
	mParent.removeClass('active');
	var idx = $('.btnDetails').index(obj);
	if($(obj).hasClass('active')){			
		$(obj).removeClass('active');
	}else {
		$('.btnDetails').removeClass('active');
		mParent.eq(idx).addClass('active');
		$(obj).addClass('active');
	}
}

//조회화면에서 알림 개별 설정
function saveAlarm(updateType){
	var eventID = CFN_GetQueryString("eventID");
	var folderID = CFN_GetQueryString("folderID");
	
	if( !folderID || folderID == "undefined"){
		folderID = CFN_GetQueryString("resourceID");
	}
	var dateID = CFN_GetQueryString("dateID");
	var isNotification = $("#IsNotification").val();
	var isReminder = $("#IsReminder").val();
	var reminderTime = $("#ReminderTime option:selected").val();
	var isComment = $("#IsCommentNotification").val();
	
	var subject = $("[name=Subject]").text();
	
	$.ajax({
	    url: "/groupware/schedule/setNotification.do",
	    type: "POST",
	    data: {
	    	"UpdateType" : updateType,  //All or Comment or Reminder
	    	"EventID" : eventID,
	    	"DateID" : dateID,
	    	"RegisterCode" : userCode,
	    	"IsNotification" : isNotification,
	    	"IsReminder" : isReminder,
	    	"ReminderTime" : reminderTime,
	    	"IsCommentNotification" : isComment,
	    	"FolderID" : folderID,
	    	"FolderType": $("#hidFolderType").val(),
	    	"Subject" : subject
	    },
	    success: function (res) {
	    	if(res.status == "SUCCESS"){
	    		Common.Inform(Common.getDic("msg_changeAlarmSetting"));		//알림 설정을 수정하였습니다.
	    	}else{
	    		Common.Error(Common.getDic("msg_apv_030"));		// 오류가 발생했습니다.
	    	}
     },
     error:function(response, status, error){
			CFN_ErrorAjax("/groupware/schedule/setNotification.do", response, status, error);
		}
	});
}

// 수정시 데이터 비교
function compareEventObject(eventObj, updateObj){
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
		
		if(updateObj[key1] != undefined){
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
		}
	});
	
	return updateReturnObj;
}

function alarmOnClick(obj){
	/*if(($(obj).attr("id") == "IsNotificationDiv" && $(obj).find('.onOffBtn').hasClass('on') == false) || $(obj).attr("id") != "IsNotificationDiv"){
		$("#NotificationType").removeClass("off");
	}else{
		$("#NotificationType").addClass("off");
	}*/
	
	if($(obj).attr("id") == "IsNotificationDiv"){
		if($(obj).find('.onOffBtn').hasClass('on') == false){
			$("#IsNotification").val("Y");
			$("#NotificationType").removeClass("off");
		}
		else{
			$("#IsNotification").val("N");
			$("#NotificationType").addClass("off");
		}
	}
	if($(obj).attr("id") == "IsReminderA"){
		if($(obj).find('.onOffBtn').hasClass('on') == false){
			$("#IsReminder").val("Y");
			$("#ReminderTime").attr("disabled", false);
		}
		else{
			$("#IsReminder").val("N");
			$("#ReminderTime").attr("disabled", true);
		}
	}
	if($(obj).attr("id") == "IsCommentA"){
		if($(obj).find('.onOffBtn').hasClass('on') == false)
			$("#IsCommentNotification").val("Y");
		else
			$("#IsCommentNotification").val("N");
	}
	
	onOffBtnOnClick(obj);
}
function tabMenuOnClick(obj){
	$('.tabMenu>li').removeClass('active');
	$('.tabContent').removeClass('active');
	$(obj).addClass('active');
	$('.tabContent').eq($(obj).index()).addClass('active');
}
function onOffBtnOnClick(obj){
	$(obj).find('.onOffBtn').hasClass('on') == true?$(obj).find('.onOffBtn').removeClass('on'):$(obj).find('.onOffBtn').addClass('on');
}

function btnLayerCloseOnClick(obj){
	//$(obj).closest('.schLayerPopContent').removeClass('active');
	$("article[id=read_popup]").html("");
	$("article[id=popup]").html("");
}

function pxToNumber(pxStr){
	if(typeof pxStr == "string")
		return Number(pxStr.replace("px", ""));
	else
		return 0;
}

function getCalendarDic(){
	//개별호출 일괄호출
	Common.getDicList(["lbl_WPSun","lbl_WPMon","lbl_WPTue","lbl_WPWed","lbl_WPThu","lbl_WPFri","lbl_WPSat",
        "lbl_Sunday0","lbl_Monday0","lbl_Tuesday0","lbl_Wednesday0","lbl_Thursday0","lbl_Friday0","lbl_Saturday0",
        "lbl_Sunday","lbl_Monday","lbl_Tuesday","lbl_Wednesday","lbl_Wednesday","lbl_Thursday","lbl_Friday","lbl_Saturday",
        "lbl_From","lbl_RepeatTimes","lbl_Till","lbl_Repeate",
        "lbl_SchEveryday2", "lbl_EveryDay","lbl_dayEvery","lbl_EveryWeek","lbl_weekEvery2",
        "lbl_monthEvery2","lbl_SchAtDay","lbl_First","lbl_Second","lbl_Third","lbl_Forth","lbl_last",
        "lbl_EveryYear","lbl_Every","lbl_year","lbl_monthEvery3",
        "lbl_OfTheDay", "lbl_Weekdays","lbl_Sch_Weekend","lbl_DayRepeat_1",
        "msg_ReservationView_01","lbl_ReservationView_01","lbl_ReservationView_02","msg_ReservationView_01_modify","lbl_ReservationView_01_modify","lbl_ReservationView_02_modify",
        "msg_ReservationView_01_delete","lbl_ReservationView_01_delete","lbl_ReservationView_02_delete",
        "lbl_From0","lbl_Atimes","lbl_To0","lbl__EveryDays0","lbl_SchEveryday","lbl_EveryNumWeek","lbl_EveryMonthsDays01","lbl_EveryYearOn"
        ,"lbl_FirstWeek","lbl_SecondWeek","lbl_ThirdWeek","lbl_FourthWeek","lbl_FifthWeek"
        ,"lbl_RepeteSettingAtoB","lbl_schedule_repeatSch","lbl_schedule_position","msg_thereNoShareEvent"
        ,"msg_changeRepeatEach","msg_noModifyACL"
        ,"lbl_Curr_Ststus","lbl_Resources","lbl_resource_BookingTime","lbl_Purpose","lbl_Reserver","btn_Returnrequest","btn_ApplicationWithdrawn"
        ,"btn_Edit","btn_ApplicationWithdrawn","msg_apv_030"
        ,"lbl_AM","lbl_PM","lbl_Hour","lbl_Repeatsettings"]);
}

//양력을 음력날짜로 변환
function solarToLunar(solYear, solMonth, solDay) {
	
	// 210716, 파라미터로 들어오는 solMonth은 0(1월)부터 시작, 이 함수에서는 1월을 1로 계산되어 +1 처리함. 
	solMonth = solMonth+1;

	// 양력을 음력으로 계산
	var lunarCalc = function(year, month, day, type, leapmonth) {
		
		var LUNAR_LAST_YEAR = 1939;
	    var lunarMonthTable = [
	        [2, 2, 1, 1, 2, 1, 1, 2, 1, 2, 1, 2],   /* 양력 1940년 1월은 음력 1939년에 있음 그래서 시작년도는 1939년*/
	        [2, 2, 1, 2, 1, 2, 1, 1, 2, 1, 2, 1],
	        [2, 2, 1, 2, 2, 4, 1, 1, 2, 1, 2, 1],   /* 1941 */
	        [2, 1, 2, 2, 1, 2, 2, 1, 2, 1, 1, 2],
	        [1, 2, 1, 2, 1, 2, 2, 1, 2, 2, 1, 2],
	        [1, 1, 2, 4, 1, 2, 1, 2, 2, 1, 2, 2],
	        [1, 1, 2, 1, 1, 2, 1, 2, 2, 2, 1, 2],
	        [2, 1, 1, 2, 1, 1, 2, 1, 2, 2, 1, 2],
	        [2, 5, 1, 2, 1, 1, 2, 1, 2, 1, 2, 2],
	        [2, 1, 2, 1, 2, 1, 1, 2, 1, 2, 1, 2],
	        [2, 2, 1, 2, 1, 2, 3, 2, 1, 2, 1, 2],
	        [2, 1, 2, 2, 1, 2, 1, 1, 2, 1, 2, 1],
	        [2, 1, 2, 2, 1, 2, 1, 2, 1, 2, 1, 2],   /* 1951 */
	        [1, 2, 1, 2, 4, 2, 1, 2, 1, 2, 1, 2],
	        [1, 2, 1, 1, 2, 2, 1, 2, 2, 1, 2, 2],
	        [1, 1, 2, 1, 1, 2, 1, 2, 2, 1, 2, 2],
	        [2, 1, 4, 1, 1, 2, 1, 2, 1, 2, 2, 2],
	        [1, 2, 1, 2, 1, 1, 2, 1, 2, 1, 2, 2],
	        [2, 1, 2, 1, 2, 1, 1, 5, 2, 1, 2, 2],
	        [1, 2, 2, 1, 2, 1, 1, 2, 1, 2, 1, 2],
	        [1, 2, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1],
	        [2, 1, 2, 1, 2, 5, 2, 1, 2, 1, 2, 1],
	        [2, 1, 2, 1, 2, 1, 2, 2, 1, 2, 1, 2],   /* 1961 */
	        [1, 2, 1, 1, 2, 1, 2, 2, 1, 2, 2, 1],
	        [2, 1, 2, 3, 2, 1, 2, 1, 2, 2, 2, 1],
	        [2, 1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 2],
	        [1, 2, 1, 2, 1, 1, 2, 1, 1, 2, 2, 2],
	        [1, 2, 5, 2, 1, 1, 2, 1, 1, 2, 2, 1],
	        [2, 2, 1, 2, 2, 1, 1, 2, 1, 2, 1, 2],
	        [1, 2, 2, 1, 2, 1, 5, 2, 1, 2, 1, 2],
	        [1, 2, 1, 2, 1, 2, 2, 1, 2, 1, 2, 1],
	        [2, 1, 1, 2, 2, 1, 2, 1, 2, 2, 1, 2],
	        [1, 2, 1, 1, 5, 2, 1, 2, 2, 2, 1, 2],   /* 1971 */
	        [1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 2, 1],
	        [2, 1, 2, 1, 1, 2, 1, 1, 2, 2, 2, 1],
	        [2, 2, 1, 5, 1, 2, 1, 1, 2, 2, 1, 2],
	        [2, 2, 1, 2, 1, 1, 2, 1, 1, 2, 1, 2],
	        [2, 2, 1, 2, 1, 2, 1, 5, 2, 1, 1, 2],
	        [2, 1, 2, 2, 1, 2, 1, 2, 1, 2, 1, 1],
	        [2, 2, 1, 2, 1, 2, 2, 1, 2, 1, 2, 1],
	        [2, 1, 1, 2, 1, 6, 1, 2, 2, 1, 2, 1],
	        [2, 1, 1, 2, 1, 2, 1, 2, 2, 1, 2, 2],
	        [1, 2, 1, 1, 2, 1, 1, 2, 2, 1, 2, 2],   /* 1981 */
	        [2, 1, 2, 3, 2, 1, 1, 2, 2, 1, 2, 2],
	        [2, 1, 2, 1, 1, 2, 1, 1, 2, 1, 2, 2],
	        [2, 1, 2, 2, 1, 1, 2, 1, 1, 5, 2, 2],
	        [1, 2, 2, 1, 2, 1, 2, 1, 1, 2, 1, 2],
	        [1, 2, 2, 1, 2, 2, 1, 2, 1, 2, 1, 1],
	        [2, 1, 2, 2, 1, 5, 2, 2, 1, 2, 1, 2],
	        [1, 1, 2, 1, 2, 1, 2, 2, 1, 2, 2, 1],
	        [2, 1, 1, 2, 1, 2, 1, 2, 2, 1, 2, 2],
	        [1, 2, 1, 1, 5, 1, 2, 1, 2, 2, 2, 2],
	        [1, 2, 1, 1, 2, 1, 1, 2, 1, 2, 2, 2],   /* 1991 */
	        [1, 2, 2, 1, 1, 2, 1, 1, 2, 1, 2, 2],
	        [1, 2, 5, 2, 1, 2, 1, 1, 2, 1, 2, 1],
	        [2, 2, 2, 1, 2, 1, 2, 1, 1, 2, 1, 2],
	        [1, 2, 2, 1, 2, 2, 1, 5, 2, 1, 1, 2],
	        [1, 2, 1, 2, 2, 1, 2, 1, 2, 2, 1, 2],
	        [1, 1, 2, 1, 2, 1, 2, 2, 1, 2, 2, 1],
	        [2, 1, 1, 2, 3, 2, 2, 1, 2, 2, 2, 1],
	        [2, 1, 1, 2, 1, 1, 2, 1, 2, 2, 2, 1],
	        [2, 2, 1, 1, 2, 1, 1, 2, 1, 2, 2, 1],
	        [2, 2, 2, 3, 2, 1, 1, 2, 1, 2, 1, 2],   /* 2001 */
	        [2, 2, 1, 2, 1, 2, 1, 1, 2, 1, 2, 1],
	        [2, 2, 1, 2, 2, 1, 2, 1, 1, 2, 1, 2],
	        [1, 5, 2, 2, 1, 2, 1, 2, 1, 2, 1, 2],
	        [1, 2, 1, 2, 1, 2, 2, 1, 2, 2, 1, 1],
	        [2, 1, 2, 1, 2, 1, 5, 2, 2, 1, 2, 2],
	        [1, 1, 2, 1, 1, 2, 1, 2, 2, 2, 1, 2],
	        [2, 1, 1, 2, 1, 1, 2, 1, 2, 2, 1, 2],
	        [2, 2, 1, 1, 5, 1, 2, 1, 2, 1, 2, 2],
	        [2, 1, 2, 1, 2, 1, 1, 2, 1, 2, 1, 2],
	        [2, 1, 2, 2, 1, 2, 1, 1, 2, 1, 2, 1],   /* 2011 */
	        [2, 1, 6, 2, 1, 2, 1, 1, 2, 1, 2, 1],
	        [2, 1, 2, 2, 1, 2, 1, 2, 1, 2, 1, 2],
	        [1, 2, 1, 2, 1, 2, 1, 2, 5, 2, 1, 2],
	        [1, 2, 1, 1, 2, 1, 2, 2, 2, 1, 2, 1],
	        [2, 1, 2, 1, 1, 2, 1, 2, 2, 1, 2, 2],
	        [2, 1, 1, 2, 3, 2, 1, 2, 1, 2, 2, 2],
	        [1, 2, 1, 2, 1, 1, 2, 1, 2, 1, 2, 2],
	        [2, 1, 2, 1, 2, 1, 1, 2, 1, 2, 1, 2],
	        [2, 1, 2, 5, 2, 1, 1, 2, 1, 2, 1, 2],
	        [1, 2, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1],   /* 2021 */
	        [2, 1, 2, 1, 2, 2, 1, 2, 1, 2, 1, 2],
	        [1, 5, 2, 1, 2, 1, 2, 2, 1, 2, 1, 2],
	        [1, 2, 1, 1, 2, 1, 2, 2, 1, 2, 2, 1],
	        [2, 1, 2, 1, 1, 5, 2, 1, 2, 2, 2, 1],
	        [2, 1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 2],
	        [1, 2, 1, 2, 1, 1, 2, 1, 1, 2, 2, 2],
	        [1, 2, 2, 1, 5, 1, 2, 1, 1, 2, 2, 1],
	        [2, 2, 1, 2, 2, 1, 1, 2, 1, 1, 2, 2],
	        [1, 2, 1, 2, 2, 1, 2, 1, 2, 1, 2, 1],
	        [2, 1, 5, 2, 1, 2, 2, 1, 2, 1, 2, 1],   /* 2031 */
	        [2, 1, 1, 2, 1, 2, 2, 1, 2, 2, 1, 2],
	        [1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 5, 2],
	        [1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 2, 1],
	        [2, 1, 2, 1, 1, 2, 1, 1, 2, 2, 1, 2],
	        [2, 2, 1, 2, 1, 4, 1, 1, 2, 2, 1, 2],
	        [2, 2, 1, 2, 1, 1, 2, 1, 1, 2, 1, 2],
	        [2, 2, 1, 2, 1, 2, 1, 2, 1, 1, 2, 1],
	        [2, 2, 1, 2, 5, 2, 1, 2, 1, 2, 1, 1],
	        [2, 1, 2, 2, 1, 2, 2, 1, 2, 1, 2, 1],
	        [2, 1, 1, 2, 1, 2, 2, 1, 2, 2, 1, 2],   /* 2041 */
	        [1, 5, 1, 2, 1, 2, 1, 2, 2, 2, 1, 2],
	        [1, 2, 1, 1, 2, 1, 1, 2, 2, 1, 2, 2]];
		
		
	    var solYear, solMonth, solDay;
	    var lunYear, lunMonth, lunDay;

	    // lunLeapMonth는 음력의 윤달인지 아닌지를 확인하기위한 변수
	    // 1일 경우 윤달이고 0일 경우 음달
	    var lunLeapMonth, lunMonthDay;
	    var i, lunIndex;

	    var solMonthDay = [31, 0, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
	    
	    var myDate = function (year, month, day, leapMonth) {
	        this.year = year;
	        this.month = month;
	        this.day = day;
	        this.leapMonth = leapMonth;
	    }

	    /* range check */
	    if (year < 1940 || year > 2040) {
	        alert(Common.getDic('msg_DateRange'));
	        return;
	    }

	    /* 속도 개선을 위해 기준 일자를 여러개로 한다 */
	    if (year >= 2000) {
	        /* 기준일자 양력 2000년 1월 1일 (음력 1999년 11월 25일) */
	        solYear = 2000;
	        solMonth = 1;
	        solDay = 1;
	        lunYear = 1999;
	        lunMonth = 11;
	        lunDay = 25;
	        lunLeapMonth = 0;

	        solMonthDay[1] = 29;    /* 2000 년 2월 28일 */
	        lunMonthDay = 30;   /* 1999년 11월 */
	    }
	    else if (year >= 1970) {
	        /* 기준일자 양력 1970년 1월 1일 (음력 1969년 11월 24일) */
	        solYear = 1970;
	        solMonth = 1;
	        solDay = 1;
	        lunYear = 1969;
	        lunMonth = 11;
	        lunDay = 24;
	        lunLeapMonth = 0;

	        solMonthDay[1] = 28;    /* 1970 년 2월 28일 */
	        lunMonthDay = 30;   /* 1969년 11월 */
	    }
	    else {
	        /* 기준일자 양력 1940년 1월 1일 (음력 1939년 11월 22일) */
	        solYear = 1940;
	        solMonth = 1;
	        solDay = 1;
	        lunYear = 1939;
	        lunMonth = 11;
	        lunDay = 22;
	        lunLeapMonth = 0;

	        solMonthDay[1] = 29;    /* 1940 년 2월 28일 */
	        lunMonthDay = 29;   /* 1939년 11월 */
	    }

	    lunIndex = lunYear - LUNAR_LAST_YEAR;

	    // type이 1일때는 입력받은 양력 값에 대한 음력값을 반환
	    // 2일 때는 입력받은 음력 값에 대한 양력값을 반환
	    // 반복문이 돌면서 양력 값들과 음력 값들을 1일 씩 증가시키고
	    // 입력받은 날짜값과 양력 값이 일치할 때 음력값을 반환함
	    while (true) {
	        if (type == 1 &&
	            year == solYear &&
	            month == solMonth &&
	            day == solDay) {
	            return new myDate(lunYear, lunMonth, lunDay, lunLeapMonth);
	        }
	        else if (type == 2 &&
	            year == lunYear &&
	            month == lunMonth &&
	            day == lunDay &&
	            leapmonth == lunLeapMonth) {
	            return new myDate(solYear, solMonth, solDay, 0);
	        }

	        // 양력의 마지막 날일 경우 년도를 증가시키고 나머지 초기화
	        if (solMonth == 12 && solDay == 31) {
	            solYear++;
	            solMonth = 1;
	            solDay = 1;

	            // 윤년일 시 2월달의 총 일수를 1일 증가
	            if (solYear % 400 == 0)
	                solMonthDay[1] = 29;
	            else if (solYear % 100 == 0)
	                solMonthDay[1] = 28;
	            else if (solYear % 4 == 0)
	                solMonthDay[1] = 29;
	            else
	                solMonthDay[1] = 28;

	        }
	        // 현재 날짜가 달의 마지막 날짜를 가리키고 있을 시 달을 증가시키고 날짜 1로 초기화
	        else if (solMonthDay[solMonth - 1] == solDay) {
	            solMonth++;
	            solDay = 1;
	        }
	        else
	            solDay++;

	        // 음력의 마지막 날인 경우 년도를 증가시키고 달과 일수를 초기화
	        if (lunMonth == 12 &&
	            ((lunarMonthTable[lunIndex][lunMonth - 1] == 1 && lunDay == 29) ||
	                (lunarMonthTable[lunIndex][lunMonth - 1] == 2 && lunDay == 30))) {
	            lunYear++;
	            lunMonth = 1;
	            lunDay = 1;

	            if (lunYear > 2043) {
	                alert("입력하신 달은 없습니다.");
	                break;
	            }

	            // 년도가 바꼈으니 index값 수정
	            lunIndex = lunYear - LUNAR_LAST_YEAR;

	            // 음력의 1월에는 1 or 2만 있으므로 1과 2만 비교하면됨
	            if (lunarMonthTable[lunIndex][lunMonth - 1] == 1)
	                lunMonthDay = 29;
	            else if (lunarMonthTable[lunIndex][lunMonth - 1] == 2)
	                lunMonthDay = 30;
	        }
	        // 현재날짜가 이번달의 마지막날짜와 일치할 경우
	        else if (lunDay == lunMonthDay) {

	            // 윤달인데 윤달계산을 안했을 경우 달의 숫자는 증가시키면 안됨
	            if (lunarMonthTable[lunIndex][lunMonth - 1] >= 3
	                && lunLeapMonth == 0) {
	                lunDay = 1;
	                lunLeapMonth = 1;
	            }
	            // 음달이거나 윤달을 계산 했을 겨우 달을 증가시키고 lunLeapMonth값 초기화
	            else {
	                lunMonth++;
	                lunDay = 1;
	                lunLeapMonth = 0;
	            }

	            // 음력의 달에 맞는 마지막날짜 초기화
	            if (lunarMonthTable[lunIndex][lunMonth - 1] == 1)
	                lunMonthDay = 29;
	            else if (lunarMonthTable[lunIndex][lunMonth - 1] == 2)
	                lunMonthDay = 30;
	            else if (lunarMonthTable[lunIndex][lunMonth - 1] == 3)
	                lunMonthDay = 29;
	            else if (lunarMonthTable[lunIndex][lunMonth - 1] == 4 &&
	                lunLeapMonth == 0)
	                lunMonthDay = 29;
	            else if (lunarMonthTable[lunIndex][lunMonth - 1] == 4 &&
	                lunLeapMonth == 1)
	                lunMonthDay = 30;
	            else if (lunarMonthTable[lunIndex][lunMonth - 1] == 5 &&
	                lunLeapMonth == 0)
	                lunMonthDay = 30;
	            else if (lunarMonthTable[lunIndex][lunMonth - 1] == 5 &&
	                lunLeapMonth == 1)
	                lunMonthDay = 29;
	            else if (lunarMonthTable[lunIndex][lunMonth - 1] == 6)
	                lunMonthDay = 30;
	        }
	        else
	            lunDay++;
	    }
	}
	
    // 날짜 형식이 안맞을 경우 공백 반환
    if (!solYear || solYear == 0 ||
        !solMonth || solMonth == 0 ||
        !solDay || solDay == 0) {
        return "";
    }

    // 양력의 달마다의 일수
    var solMonthDays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

    // 윤년일 시 2월에 1일 추가
    if (solYear % 400 == 0 || (solYear % 4 == 0 && solYear % 100 != 0)) solMonthDays[1] += 1;


    if (solMonth < 1 || solMonth > 12 ||
        solDay < 1 || solDay > solMonthDays[solMonth - 1]) {

        return "";
    }

    /* 양력/음력 변환 */
    var date = lunarCalc(solYear, solMonth, solDay, 1);

    //return "음력 " + date.year + "년 " + (date.leapMonth ? "(윤)" : "") + date.month + "월 " + date.day;
    return (date.leapMonth ? "(윤)" : "")+date.month+"."+date.day;
}
