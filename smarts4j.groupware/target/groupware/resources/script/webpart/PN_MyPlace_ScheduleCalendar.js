/**
 * pnScCalendar - [포탈개선] My Place - 일정관리
 */
var pnScCalendar = {
	webpartType: "",
	folderCheckList: ";", 
	calendarHeight: "",
	init: function (data, ext){
		if(schAclArray.status != "SUCCESS") {
			scheduleUser.setAclEventFolderData();
		}
		
		pnScCalendar.setEvent();
		pnScCalendar.calendarHeight = $(".calCont").outerHeight();
		pnScCalendar.schedule_onload();
	},
	setEvent: function(){
		$(".PN_scCalendar").closest(".PN_myContents_box").find(".PN_portlet_btn").off("click").on("click", function(){
			if(!$(this).hasClass("active")){
				$(this).addClass("active");
				$(this).next(".PN_portlet_menu").stop().slideDown(300);
				$(this).children(".PN_portlet_btn > span").addClass("on");
			}else{
				$(this).removeClass("active");
				$(this).next(".PN_portlet_menu").stop().slideUp(300);
				$(this).children(".PN_portlet_btn > span").removeClass("on");
			}
		});

		$(".PN_scCalendar").closest(".PN_myContents_box").find(".PN_portlet_close").click(function(){
			$(this).parents(".PN_portlet_function").find(".PN_portlet_btn").removeClass("active");
			$(this).parents(".PN_portlet_menu").stop().slideUp(300);
			$(this).parents(".PN_portlet_function").find(".PN_portlet_btn > span").removeClass("on");
		});
		
		$(".PN_scCalendar").closest(".PN_myContents_box").find(".PN_portlet_menu li[mode=write]").off("click").on("click", function(){
			coviCtrl.toggleSimpleMake();
			$(".tabMenuArrow li[type=Schedule]").trigger("click");
		});
	},
	schedule_onload: function(){
		g_viewType = "M";
		g_startDate = CFN_GetLocalCurrentDate("yyyy.MM.dd");
		
		g_year = g_startDate.split(".")[0];			// 전역변수 세팅
		g_month = g_startDate.split(".")[1];		// 전역변수 세팅
		g_day = g_startDate.split(".")[2];			// 전역변수 세팅
		
		$(schAclArray.read).each(function(idx,obj){
			pnScCalendar.folderCheckList += (obj.FolderID + ";");
		});
		
		pnScCalendar.makeCalendar($("#leftCalendar"));
	}, 
	// 포탈에서 일정 호출
	//그리드 데이터
	searchScheduleData: function(date){
		var sDate = schedule_SetDateFormat(date, "-");
		var eDate = sDate;
		
		$("#cal_body").find("div").removeClass("calendarSelected_d");
		$("#cal_body").find("div[month="+Number(g_month)+"][id="+Number(g_day)+"]").addClass("calendarSelected_d");
		
		//개별 호출 -> 일괄호출 
		var sessionObj = Common.getSession(); //전체호출

		var params = {
				"FolderIDs" : pnScCalendar.folderCheckList,
				"StartDate" : sDate,
				"EndDate" : eDate,
				"UserCode" : sessionObj["USERID"],
				"lang" : sessionObj["lang"]
		};
		
		$.ajax({
			type:"POST",
			url:"/groupware/schedule/getList.do",
			data: params,
			success:function(data){
				var listData = data.list;
				var schHtml = "";
				
				$.each(listData, function(index, value){
					var liWrap = $("<li></li>");
					
					liWrap.append($("<a href='#'></a>")
							.attr("onclick", "scheduleUser.goDetailViewPage('Webpart', " + value.EventID + ", " + value.DateID + ", " + value.RepeatID + ", '" + value.IsRepeat + "', " + value.FolderID + ")")
							.append($("<span class='scTheme'></span>").css("background-color", value.Color))
							.append($("<strong class='scTitle'></strong>").text(value.Subject))
							.append($("<span class='scTime'></span>").text(getStringDateToString("HH:mm", value.StartDateTime) + "~" + getStringDateToString("HH:mm", value.EndDateTime))));
					
					schHtml += $(liWrap)[0].outerHTML;
				});
				
				$(".PN_scList").empty().append(schHtml);
				
				// 구글 일정 연동
				//pnScCalendar.schedule_MakeListGoogle(date);
				
				// 일정이 없으면
				if(!schHtml){
					$(".PN_scManage .mScrollV").hide();
					$(".PN_scManage .PN_nolist").show();
					$(".PN_scManage .PN_scheduleList .PN_btnRegist").off("click").on("click", pnScCalendar.addSchedule);
				}else{
					$(".PN_scManage .mScrollV").show();
					$(".PN_scManage .PN_nolist").hide();
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/groupware/schedule/getList.do", response, status, error);
			}
		});
	},
	moveMonth: function(v){
		if (v == "+") {
			g_month++;
			if (g_month > 12){ g_year++; g_month = 1; }
		} else {
			g_month--;
			if (g_month < 1){ g_year--; g_month = 12; }
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
		}
		pnScCalendar.makeCalendar($("#leftCalendar"));
	}, 
	makeCalendar: function(target){
		var cnt = 0;
		var icnt = 0;
		var preDay = new Array();
		var nextDay = new Array();
		var tempMonth = parseInt(g_month, 10);
		
		var sDate = "";
		var eDate = "";
		
		var tempDay = g_day;
		
		var nfirstdate = new Date(g_year, (tempMonth - 1), 1);
		var nfirstweek = nfirstdate.getDay();
		var nlastdate = new Date(g_year, tempMonth, 0);
		var nlastday = nlastdate.getDate();
		
		var dtmsg = "<div class='tblCalTr'>" +
				"<div>" + "<spring:message code='Cache.lbl_WPSun'/>" + "</div>" +
				"<div>" + "<spring:message code='Cache.lbl_WPMon'/>" + "</div>" +
				"<div>" + "<spring:message code='Cache.lbl_WPTue'/>" + "</div>" +
				"<div>" + "<spring:message code='Cache.lbl_WPWed'/>" + "</div>" +
				"<div>" + "<spring:message code='Cache.lbl_WPThu'/>" + "</div>" +
				"<div>" + "<spring:message code='Cache.lbl_WPFri'/>" + "</div>" +
				"<div>" + "<spring:message code='Cache.lbl_WPSat'/>" + "</div>" +
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
				if(preDay == "") {
					tdfc = "CalPervMon";
				}
				
				tdfc = "CalPervMon";
				dmsg += "<div class='calendarDate " + tdfc + "' month = '" + preMonth + "' weekly = '" + weekly + "'></div>";
			}
			else {
				d++;
				var tdfc = "";
			
			//	if (g_year == g_currentTime.getFullYear() && g_month == (g_currentTime.getMonth() + 1) && d == g_currentTime.getDate()) { tdfc = "calendarToday"; } // 오늘날짜 표시 
				dmsg += "<div class='calendarDate " + tdfc + "' month = '" + tempMonth + "' id= '" + d + "' weekly = '" + weekly + "' >";
				dmsg += "<a onclick = \"pnScCalendar.clickDay('" + g_year + "." + AddFrontZero(tempMonth, 2) + "." + AddFrontZero(d, 2) + "');\"><span>" + d + "</span></a></div>";
			}
			if (i < ntdsum - 1 && ((i + 1) % 7) == 0) {
				dmsg += "</div><div class='tblCalTr'>"; weekly++;
			}
			
		}
		
		if (7 - (ntdsum % 7) > 0 && (ntdsum % 7) > 0) {
			for (i = 0; i < (7 - (ntdsum % 7)); i++) {
				if(tempDay <= nlastday) {
					tdfc = "CalNextMon";
				}
				if (i == 0 && (ntdsum % 7) == 0) { tdfc = ""; }
				
				var paramDateStr = nextYear + "." + AddFrontZero(nextMonth,2) + "." + AddFrontZero((i + 1),2);
				dmsg += "<div class='calendarDate " + tdfc + "'  month = '" + Number(nextMonth) + "' weekly = '" + weekly + "' id='"+(i + 1)+"'><a onclick = \"pnScCalendar.clickDay('" + paramDateStr + "');\"><span>" + (i + 1) + "</span></a></div>";
				
				eDate = paramDateStr;
			}
		}
		
		dmsg += "</div>";
		
		target.html(dtmsg + "<div id='cal_body'>" + dmsg + "</div>");
		
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
				var paramDateStr = preYear + "." + AddFrontZero(preMonth,2) + "." + AddFrontZero((tfirstday + i), 2);
				sDate = paramDateStr;
				
				$("#cal_body").find("div:first").find("div")[i].innerHTML = "<a onclick = \"pnScCalendar.clickDay('" + paramDateStr + "');\" style='color:#ff9999;'><span>" + (tfirstday + i) + "</span></a>";
			} else {
				$("#cal_body").find("div:first").find("div")[i].innerHTML = "<a onclick = \"pnScCalendar.clickDay('" + preYear + "." + AddFrontZero(preMonth,2) + "." + AddFrontZero((tfirstday + i),2) + "');\"><span>" + (tfirstday + i) + "</span></a>";
			}
			$("#cal_body").find("div:first").find("div").eq(i).attr("id", tfirstday + i);
			
			// class 추가로 변경 필요
			$("#cal_body").find("div:first").find("div")[i].innerText.className = "calendarDate CalPervMon";
		}
		
		if(btcnt == -1){
			sDate = schedule_SetDateFormat(nfirstdate, ".");
		}
		
		if(ntdsum % 7 == 0){
			var eDateObj = new Date(replaceDate(sDate));
			eDateObj.setDate(eDateObj.getDate() + (ntdsum-1));
			eDate = schedule_SetDateFormat(eDateObj, ".");
		}
		
		// 달력 년, 월 세팅
		$("#calTopDateVal").val(g_year + "." + AddFrontZero(g_month, 2));
		$('.calTopdate').text(g_year + '.' + AddFrontZero(g_month, 2));
		
		// 예약 되어 있는 날짜에 대해서 표시하기
		pnScCalendar.setCalendarEvent(sDate, eDate);
		
		// [웹 파트] 일정 세로 조절
		if(Number($("#cal_body").height()) > ($(".tblCalTr").height() * 5 )) {
			$(".PLinkCalendartimeline").css("max-height", pnScCalendar.calendarHeight - $(".tblCalTr").height());
		}
		else {
			$(".PLinkCalendartimeline").css("max-height", "none")
		}
		
		pnScCalendar.searchScheduleData(g_year+"."+g_month+"."+g_day);
		
	},
	clickDay: function(date){
		g_year = date.split(".")[0];		// 전역변수 세팅
		g_month = date.split(".")[1];		// 전역변수 세팅
		g_day = date.split(".")[2];			// 전역변수 세팅
		
		pnScCalendar.searchScheduleData(date);
	},
	setCalendarEvent: function(sDate, eDate){
		$.ajax({
			url: "/groupware/schedule/getLeftCalendarEvent.do",
			type: "POST",
			data: {
				"StartDate":sDate.replaceAll(".", "-"),
				"EndDate":eDate.replaceAll(".", "-"),
				"FolderIDs":pnScCalendar.folderCheckList
			},
			success: function(res){
				if(res.status == "SUCCESS"){
					$(res.list).each(function(){
						var startDate = this.StartEndDate.split("~")[0];
						var endDate = this.StartEndDate.split("~")[1];
						
						// 향후 수정 필요하다고 생각됨
						if(startDate == endDate){
							var monthStr = Number(startDate.split("-")[1]);
							var dayStr = Number(startDate.split("-")[2]);
							
							$("#cal_body").find("div[month="+monthStr+"][id="+dayStr+"]").addClass("mark");
						}else{
							var startDateObj = new Date(replaceDate(startDate));
							var endDateObj = new Date(replaceDate(endDate));
							
							while(startDateObj.getTime() <= endDateObj.getTime()){
								var month = startDateObj.getMonth() + 1;
								var day = startDateObj.getDate();
								
								$("#cal_body").find("div[month="+month+"][id="+day+"]").addClass("mark");
								
								startDateObj.setDate(day + 1);
							}
						}
					});
				} else {
					parent.Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
				}
			},
			error:function(response, status, error){
				parent.CFN_ErrorAjax("/groupware/schedule/getLeftCalendarEvent.do", response, status, error);
			}
		});
	},
	addSchedule: function(){
		var schDate = g_year+"."+g_month+"."+g_day;
		
		coviCtrl.toggleSimpleMake();
		$(".tabMenuArrow li[type=Schedule]").trigger("click");
		
		$("#simpleSchDateCon_StartDate").val(schDate);
		$("#simpleSchDateCon_EndDate").val(schDate);
	}
}