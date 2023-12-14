/**
 * 달력 형태 일정 웹파트
 */
var scheduleCalendar = {
	config: {
		folderList: ';'
	},
	data: [],
	init: function (data, ext, caller){
		var _ext = (typeof ext == 'object') ? ext : {};
		this.config = $.extend(this.config, _ext);
		this.caller = caller;
		
		this.calendar = CoviCalendar('wp_calendar', { weekLine: 6 });
		this.setData();
		
		$("#wp_calendar .covi-calendar-date").on("click", function(e){
		    scheduleCalendar.list();
		});
		
		$("#wp_calendar").on("load", function(){
			scheduleCalendar.setData();

			$("#wp_calendar .covi-calendar-date").on("click", function(e){
			    scheduleCalendar.list();
			});
		});
		
		if (caller == 'myPlace') $("#schedule_calendar .PN_scList").mCustomScrollbar();
	},
	setData: function(){
		if(schAclArray.status != "SUCCESS") {
			scheduleUser.setAclEventFolderData();
		}
		
		$(schAclArray.read).each(function(idx, el){
			scheduleCalendar.config.folderList += (el.FolderID + ";");
		});
		
		$.ajax({
		    url: "/groupware/schedule/getList.do",
		    type: "POST",
		    data: {
		    	StartDate: $("[data-day-order=1]").attr("data-day"),
		    	EndDate: $("[data-day-order=42]").attr("data-day"),
		    	FolderIDs: scheduleCalendar.config.folderList,
				UserCode: Common.getSession("USERID"),
				lang: Common.getSession("lang")
			},
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
					scheduleCalendar.data = res.list
					
					scheduleCalendar.mark();
					scheduleCalendar.list();
		    	} else {
		    		parent.Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
		    	}
		    },
		    error:function(response, status, error){
		    	parent.CFN_ErrorAjax("/groupware/schedule/getList.do", response, status, error);
		    }
		});
	},
	mark: function(){
		$.each(scheduleCalendar.data, function(idx, el){
			if (el.StartDate == el.EndDate) {
				scheduleCalendar.calendar.setMark(el.StartDate);
			} else if(el.StartDate < el.EndDate) {
				var StartDate = new Date(el.StartDate);
				var EndDate = new Date(el.EndDate);
				var currentDate = new Date(StartDate);
				while (currentDate < EndDate) {
					scheduleCalendar.calendar.setMark(schedule_SetDateFormat(currentDate, '-'));
					
					currentDate.setDate(currentDate.getDate() + 1);
				}
			}
		});
	},
	list: function(){
		$("#schedule_calendar_list").empty();
		$("#schedule_calendar [data-role=result]").show();
		$("#schedule_calendar [data-role=no-result]").hide();
		if($("#schedule_calendar_date").length > 0) {
			$("#schedule_calendar_date").html($("#template_schedule_calender_date").html()
				.replace('{date}', schedule_SetDateFormat(scheduleCalendar.calendar.current.date, '.'))
			);
		}
		
		var selday = $("#schedule_calendar .covi-calendar-date.selected").attr("data-day");
		var scheduleCnt = 0;
		$.each(scheduleCalendar.data, function(idx, el){
			var isList = false;
			var _time = '';
			var meridiem = ' am';

			if (isList = el.StartDate == el.EndDate && el.StartDate == selday) {
				_time = el.StartTime+'~'+el.EndTime;
				if (Number(el.EndTime.split(':')[0]) - 12 >= 0) meridiem = ' pm';
			}
			else if (isList = el.StartDate != el.EndDate && el.StartDate == selday) {
				_time = el.StartTime+'~23:59';
				meridiem = ' pm';
			}
			else if (isList = el.StartDate != el.EndDate && el.EndDate == selday && el.EndTime != '00:00'){
				_time = '00:00~'+el.EndTime;
				if (Number(el.EndTime.split(':')[0]) - 12 >= 0) meridiem = ' pm';
			}
			else if (isList = el.StartDate != el.EndDate && el.StartDate < selday && el.EndDate > selday){
				_time = '00:00~23:59';
			}
			
			if(isList){
				$("#schedule_calendar_list").append($("#template_schedule_calender_li").html()
					.replace('{startTime}', el.StartTime)
					.replace('{subject}', el.Subject)
					.replace("{color}", el.Color)
					.replace('{folderName}', el.FolderName)
					.replace('{startTimeEndTime}', _time + meridiem)
					.replace('{link}', "scheduleUser.goDetailViewPage('Webpart', " + el.EventID + ", " + el.DateID + ", " + el.RepeatID + ", '" + el.IsRepeat + "', " + el.FolderID + ")")
				);
				scheduleCnt++;
			}
		});
		
		if($("#schedule_calender_count").length > 0) {
			$("#schedule_calender_count").text(Common.getDic('lbl_TotalNumber') + ' : ' + scheduleCnt)
		} 
		if (scheduleCnt < 1){
			$("#schedule_calendar [data-role=result]").hide();
			$("#schedule_calendar [data-role=no-result]").show();
		}
	},
	add: function(){
		coviCtrl.toggleSimpleMake();
		$(".tabMenuArrow li[type=Schedule]").trigger("click");
		
		$("#simpleSchDateCon_StartDate").val(schedule_SetDateFormat($("#schedule_calendar .covi-calendar-date.selected").attr("data-day"), '.'));
		$("#simpleSchDateCon_EndDate").val(schedule_SetDateFormat($("#schedule_calendar .covi-calendar-date.selected").attr("data-day"), '.'));
	}
}


