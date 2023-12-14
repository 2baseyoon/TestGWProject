/**
 * 타임라인 형태 일정 웹파트
 */
var scheduleTimeline = {
	config: {
		before: -1,
		after: 1,
		date: CFN_GetLocalCurrentDate(_ServerDateSimpleFormat),
		seperator: '.',
		weekday: ['lbl_Sunday', 'lbl_Monday', 'lbl_Tuesday', 'lbl_Wednesday', 'lbl_Thursday', 'lbl_Friday', 'lbl_Saturday']
	},
	data: {},
	init: function (data, ext, caller){
		var _ext = (typeof ext == 'object') ? ext : {};
		this.config = $.extend(this.config, _ext);
		this.caller = caller;
		
		if (Common.getBaseConfig("WebpartScheduleBefore") != '') scheduleTimeline.config.before = parseInt(Common.getBaseConfig("WebpartScheduleBefore"));
		if (Common.getBaseConfig("WebpartScheduleAfter") != '') scheduleTimeline.config.after = parseInt(Common.getBaseConfig("WebpartScheduleAfter"));
		scheduleTimeline.setEvent();
		$("#wp_Schedule_Timelime a[data-role=today]").click();
	},
	setEvent: function(){
		$("#wp_Schedule_Timelime a[data-role=today]")
			.attr("onclick", "javascript: scheduleTimeline.getScheduleList(this);")
			.attr("data-date-idx", 0)
			.attr("data-date", scheduleTimeline.config.date);
		$("#wp_Schedule_Timelime a[data-role=before]")
			.attr("onclick", "javascript: scheduleTimeline.getScheduleList(this);")
			.attr("data-date-idx", scheduleTimeline.config.before)
			.attr("data-date", schedule_SetDateFormat(schedule_AddDays(scheduleTimeline.config.date, Number(scheduleTimeline.config.before)), '-'));
		$("#wp_Schedule_Timelime a[data-role=after]")
			.attr("onclick", "javascript: scheduleTimeline.getScheduleList(this);")
			.attr("data-date-idx", scheduleTimeline.config.after)
			.attr("data-date", schedule_SetDateFormat(schedule_AddDays(scheduleTimeline.config.date, Number(scheduleTimeline.config.after)), '-'));;
	},
	// 일정 조회
	getScheduleList : function(target) {
		if ($(target).hasClass("on") || $(target).hasClass("off")){
			$("#wp_Schedule_Timelime a").not(target).removeClass("on").addClass("off");
			$(target).removeClass("off").addClass("on");
		} else {
			$("#wp_Schedule_Timelime li").removeClass("active")
			$(target).closest("li").addClass("active");
		}
		
		var date = $(target).attr("data-date").split('-');
		
		/*$("#schedule_timeline_date").text(
			($("#schedule_timeline_date").attr("data-format") == "yyyy.MM") ? date.join(scheduleTimeline.config.seperator).substring(0,7) : date.join(scheduleTimeline.config.seperator)
		);
		if ($("#schedule_timeline_date").attr("data-format") == "yyyy.MM") $("#schedule_timeline_day").text(date[2]);
		if ($("#schedule_timeline_weekday").length > 0) {
			var weekday = new Date(Number(date[0]), Number(date[1]) - 1, Number(date[2])).getDay();
			$("#schedule_timeline_weekday").text(Common.getDic(scheduleTimeline.config.weekday[weekday]));
		}*/
		
		if ($(".ptype03_schedule_top_date1").length > 0) {
			var weekday = new Date(Number(date[0]), Number(date[1]) - 1, Number(date[2])).getDay();
			$(".ptype03_schedule_top_date1").text(Common.getDic(scheduleTimeline.config.weekday[weekday]));
		}
		
		if ($(".ptype03_schedule_top_date2").length > 0) {
			$(".ptype03_schedule_top_date2").text(date.join("."));
		}
		
		var dateIdx = Number($(target).attr("data-date-idx"));
		
		var sDate = CFN_TransServerTime($(target).attr("data-date") + " 00:00");
		var eDate = CFN_TransServerTime(schedule_SetDateFormat(schedule_AddDays($(target).attr("data-date"), 1), '-') + " 00:00");
		
		$.ajax({
			type: "POST",
			url: "/groupware/schedule/getWebpartScheduleList.do",
			data: {
				'StartDate' : sDate,
				'EndDate' : eDate,
				'Idx' : dateIdx
			},
			success:function(data) {
				scheduleTimeline.data = data.list;
			}
		}).done(function(){
			scheduleTimeline.render();
		});
	},
	render: function(){
		$("#schedule_timeline_list").empty();
		if(scheduleTimeline.data.length > 0 ){
			$("#schedule_timeline_list").show();
			$("#schedule_timeline_none").hide();
			$.each(scheduleTimeline.data, function(idx, el){
				$("#schedule_timeline_list").append($("#template_schedule_timeline_item").html()
					.replace('{title}', el.Subject)
					.replace('{time}', el.StartTime + '~' + (el.EndTime.substring(0,2) >= 12 ? el.EndTime + ' pm' : el.EndTime + ' am'))
				)
			});
		}else{
			$("#schedule_timeline_list").hide();
			$("#schedule_timeline_none").show();
		}
	}
}


