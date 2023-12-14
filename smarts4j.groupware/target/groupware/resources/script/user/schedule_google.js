
var isConnectGoogle = false;
var googleEmail = "";
var googleUserCode = Common.getSession('USERID');

var callGoogleAPI = setInterval(function() {
	var params = {};
		$.ajax({
		    url: "/covicore/oauth2/client/callGoogleRestAPI.do",
		    type: "POST",
		    async : false,
		    data: {
		    	"url" : "https://www.googleapis.com/calendar/v3/calendars/primary/events/",
		    	"type" : "REFLASH",
		    	"userCode" : googleUserCode,
		    	"params" : JSON.stringify(params)
		    },
		    success: function (res) {
	        },
	        error:function(response, status, error){
			}
		});
}, 600000);

function initGoogleJS(){
	$.ajax({
	    url: "/groupware/schedule/checkIsConnectGoogle.do",
	    type: "POST",
	    async: false,
	    data: {
	    	"UserCode" : googleUserCode
	    },
	    success: function (res) {
	    	if(res.status == "SUCCESS"){
	    		isConnectGoogle = res.data.isConnect;
	    		googleEmail = res.data.Mail;
	    	}else{
	    		//Common.Error(Common.getDic("msg_apv_030"));		// 오류가 발생했습니다.
	    	}
        },
        error:function(response, status, error){
			CFN_ErrorAjax("/groupware/schedule/checkIsConnectGoogle.do", response, status, error);
		}
	});
}

// 구글 캘린더 리스트 - 데이터 가져오기
function getGoogleEventList(sDate, eDate){
	var returnVal;
	
	var timeZoneNum = AddFrontZero(new Date().getTimezoneOffset() / -60, 2) + ":00";
	var checkPlus = new Date().getTimezoneOffset() >= 0 ? "-" : "+";
	
	//sDate = encodeURIComponent(new Date(replaceDate(sDate)).toISOString().replace(".000", "").replace("Z", checkPlus+timeZoneNum));
	//eDate = encodeURIComponent(new Date(schedule_AddDays(eDate, 1)).toISOString().replace(".000", "").replace("Z", checkPlus+timeZoneNum));
	sDate = encodeURIComponent(XFN_getDateTimeString('yyyy-MM-ddT00:00:00', new Date(replaceDate(sDate))) + (checkPlus+timeZoneNum));
	eDate = encodeURIComponent(XFN_getDateTimeString('yyyy-MM-ddT00:00:00', new Date(schedule_AddDays(eDate, 1))) + (checkPlus+timeZoneNum));
	
	var params = {
			"orderBy" : "startTime",
			"showDeleted" : false,
			"singleEvents" : true,
			"timeMax" : eDate,
			"timeMin" : sDate
	};
	
	$.ajax({
	    url: "/covicore/oauth2/client/callGoogleRestAPI.do",
	    type: "POST",
	    async : false,
	    data: {
	    	"url" : "https://www.googleapis.com/calendar/v3/calendars/primary/events",
	    	"type" : "GET",
	    	"userCode" : googleUserCode,
	    	"params" : JSON.stringify(params)
	    },
	    success: function (res) {
	    	if(res.status == "200"){
	    		returnVal = coverGoogleEventListData(res.data);
	    	}
        },
        error:function(response, status, error){
			CFN_ErrorAjax("/covicore/oauth2/client/callGoogleRestAPI.do", response, status, error);
		}
	});
	
	return returnVal;
}

// 구글 캘린더 리스트 - 데이터 조작 후 그리기
function coverGoogleEventListData(data){
	if(data.items.length > 0){
		var eventArr = data.items;
		var resultArr = new Array();
		var lblnoSubject = Common.getDic("lbl_NoSubject");
		var gBaseConfigScheduleGoogleFolderID = Common.getBaseConfig("ScheduleGoogleFolderID");
		$(eventArr).each(function(){
			var eventObj = {};
			
			eventObj.isGoogle = "Y";
			
			eventObj.EventID = this.id;
			eventObj.DateID = this.id;
			eventObj.ImportanceState = "N";		//구글에는 중요여부 없음
			eventObj.Subject = this.summary == undefined ? "("+lblnoSubject+")" : this.summary;
			
			eventObj.RegisterCode = this.creator.email;
			eventObj.OwnerCode = this.creator.email;
			eventObj.MultiRegisterName = this.creator.email;
			
			eventObj.IsAllDay = this.start.date == undefined ? "N" : "Y";
			
			var start_date = "";
			var end_date = "";
			if(eventObj.IsAllDay == "N"){
				start_date = this.start.dateTime;
				end_date = this.end.dateTime;
			}else{
				start_date = this.start.date;
				end_date = schedule_SetDateFormat(schedule_AddDays(this.end.date, -1), "-");
			}
			eventObj.StartDate = schedule_SetDateFormat(new Date(start_date), "-");
			eventObj.EndDate = schedule_SetDateFormat(new Date(end_date), "-");
			
			if(eventObj.IsAllDay == "N"){
				eventObj.StartTime =AddFrontZero(new Date(start_date).getHours(), 2)+":"+AddFrontZero(new Date(start_date).getMinutes(), 2);
				eventObj.EndTime = AddFrontZero(new Date(end_date).getHours(), 2)+":"+AddFrontZero(new Date(end_date).getMinutes(), 2);
			}else{
				eventObj.StartTime = "00:00";
				eventObj.EndTime = "23:59";
			}
			eventObj.StartDateTime = eventObj.StartDate + " " + eventObj.StartTime;
			eventObj.EndDateTime = eventObj.EndDate + " " + eventObj.EndTime;
			
			eventObj.RepeatID = this.recurringEventId == undefined ? "" : this.recurringEventId;
			eventObj.IsRepeat = this.recurringEventId == undefined ? "N" : "Y";
			
			eventObj.Place = this.location == undefined ? "" : this.location;
			
			eventObj.Color = "#ac725e";			//TODO
			eventObj.FolderID = gBaseConfigScheduleGoogleFolderID;
			
			resultArr.push(eventObj);
		});
	}
	return resultArr;
}

//구글 캘린더 이벤트 - 데이터 가져오기
function getGoogleEventOne(mode, eventID, callBack1, callBack2, isAsync){
	var params = {};
	
	$.ajax({
	    url: "/covicore/oauth2/client/callGoogleRestAPI.do",
	    type: "POST",
	    async : isAsync,
	    data: {
	    	"url" : "https://www.googleapis.com/calendar/v3/calendars/primary/events/"+eventID,
	    	"type" : "GET",
	    	"userCode" : googleUserCode,
	    	"params" : JSON.stringify(params)
	    },
	    success: function (res) {
	    	if(res.status == "200"){
	    		callBack1(mode, res.data, callBack2);
	    	}else{
	    		//Common.Error(Common.getDic("msg_apv_030"));		// 오류가 발생했습니다.
	    	}
        },
        error:function(response, status, error){
			CFN_ErrorAjax("/covicore/oauth2/client/callGoogleRestAPI.do", response, status, error);
		}
	});
}

//구글 캘린더 이벤트 - 데이터 조작 후 그리기
function coverGoogleEventOne(mode, data, callBack){
	var resultObj = {};
	
	resultObj.IsGoogle = "Y";
	resultObj.Event = {};
	resultObj.Date = {};
	resultObj.Repeat = {};
	resultObj.Resource = {};
	resultObj.Attendee = {};
	resultObj.Notification = {};
	resultObj.Notification = {};
	resultObj.fileList = {};
	
	resultObj.Event.Subject = data.summary == undefined ? "("+Common.getDic("lbl_NoSubject")+")" : data.summary;
	resultObj.Event.IsSubject = data.summary == undefined ? "N" : "Y";
	resultObj.Event.RegisterData = data.creator.email;
	resultObj.Event.Place = data.location == undefined ? "" : data.location;
	resultObj.Event.ImportanceState = "N";
	resultObj.Event.FolderName = "구글일정";		//TODO
	resultObj.Event.FolderID = Common.getBaseConfig("ScheduleGoogleFolderID");
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
		end_date = schedule_SetDateFormat(schedule_AddDays(data.end.date, -1), "-");
	}
	resultObj.Date.StartDate = schedule_SetDateFormat(new Date(start_date), "-");
	resultObj.Date.EndDate = schedule_SetDateFormat(new Date(end_date), "-");
	
	if(resultObj.Date.IsAllDay == "N"){
		resultObj.Date.StartTime =AddFrontZero(new Date(start_date).getHours(), 2)+":"+AddFrontZero(new Date(start_date).getMinutes(), 2);
		resultObj.Date.EndTime = AddFrontZero(new Date(end_date).getHours(), 2)+":"+AddFrontZero(new Date(end_date).getMinutes(), 2);
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

//구글 일정 삭제
function deleteGoogleEventOne(setType, eventID){
	var params = {};
	var url = "https://www.googleapis.com/calendar/v3/calendars/primary/events/"+eventID;
	
	// 모든 알림 허용 여부. 참석 요청 알림 포함 (TODO 옵션화 필요)
	url += "?sendNotifications=true";
	
	$.ajax({
	    url: "/covicore/oauth2/client/callGoogleRestAPI.do",
	    type: "POST",
	    data: {
	    	"url" : url,
	    	"type" : "DELETE",
	    	"userCode" : googleUserCode,
	    	"params" : JSON.stringify(params)
	    },
	    success: function (res) {
	    	if(res.status == "204"){
	    		Common.Inform(Common.getDic("msg_deleteSuccess"), "", function(){			//성공적으로 삭제하였습니다.
		    		if(setType == "S")
		    			scheduleUser.refresh();
		    		else
		    			CoviMenu_GetContent(g_lastURL);
		    	});
	    	}else{
	    		//Common.Error(Common.getDic("msg_apv_030"));		// 오류가 발생했습니다.
	    	}
        },
        error:function(response, status, error){
			CFN_ErrorAjax("/covicore/oauth2/client/callGoogleRestAPI.do", response, status, error);
		}
	});
}

//구글 일정 등록 데이터 가공
function coverInsertGoogleEventData(setType, eventObj, mode){
	var resultObj = {};
	
	// 제목
	resultObj.summary = eventObj.Event.Subject;
	
	// 시작일 종료일
	resultObj.start = {};
	resultObj.end = {};
	if(eventObj.Date.IsAllDay == undefined || eventObj.Date.IsAllDay == "N"){
		resultObj.start.dateTime = new Date(replaceDate(eventObj.Date.StartDate) + " " + eventObj.Date.StartTime).toISOString();
		resultObj.end.dateTime = new Date(replaceDate(eventObj.Date.EndDate) + " " + eventObj.Date.EndTime).toISOString();
	}else{
		resultObj.start.date = eventObj.Date.StartDate;
		resultObj.end.date =  schedule_SetDateFormat(schedule_AddDays(eventObj.Date.EndDate, 1), "-");
	}
	
	// 참석자
	if(eventObj.Attendee.length > 0){
		var attendee = new Array();
		$(eventObj.Attendee).each(function(){
			attendee.push({
				"email" : this.UserName,
				"responseStatus": "needsAction"
			});
		});
		
		// 자신의 데이터
		attendee.push({
			"email": googleEmail,
	         "displayName": Common.getSession("USERNAME"),
	         "organizer": true,
	         "self": true,
	         "responseStatus": "accepted"
		});
		
		resultObj.attendees = attendee;
	}
	
	// 설명
	resultObj.description = eventObj.Event.Description;
	
	// 장소
	resultObj.location = eventObj.Event.Place;
	
	//반복 TODO
	
	// 공개 여부
	if(eventObj.Event.IsPublic == "N"){
		resultObj.visibility = "private";
	}else if(eventObj.Event.IsPublic == "Y"){
		resultObj.visibility = "default";
	}
	
	if(mode == "I"){
		insertGoogleEventData(setType, resultObj);
	}
	else if(mode == "U"){
		updateGoogleEventData(setType, resultObj, eventObj.EventID);
	}
}

//구글 일정 등록
function insertGoogleEventData(setType, eventObj){
	var params = eventObj;
	var url = "https://www.googleapis.com/calendar/v3/calendars/primary/events";
	
	// 모든 알림 허용 여부. 참석 요청 알림 포함 (TODO 옵션화 필요)
	url += "?sendNotifications=true";
	
	$.ajax({
	    url: "/covicore/oauth2/client/callGoogleRestAPI.do",
	    type: "POST",
	    data: {
	    	"url" : url,
	    	"type" : "POST",
	    	"userCode" : googleUserCode,
	    	"params" : JSON.stringify(params)
	    },
	    success: function (res) {
	    	if(res.status == "200"){
	    		Common.Inform(Common.getDic("msg_117"), "", function(){			//성공적으로 저장하였습니다.
	    			if(setType == "S")
	    				scheduleUser.refresh();
		    		else
		    			CoviMenu_GetContent(g_lastURL);
	    		});
	    	}else{
	    		//Common.Error(Common.getDic("msg_apv_030"));		// 오류가 발생했습니다.
	    	}
        },
        error:function(response, status, error){
			CFN_ErrorAjax("/covicore/oauth2/client/callGoogleRestAPI.do", response, status, error);
		}
	});
}

//구글 일정 수정
function updateGoogleEventData(setType, eventObj, eventID){
	var params = eventObj;
	var url = "https://www.googleapis.com/calendar/v3/calendars/primary/events/"+eventID;
	
	// 모든 알림 허용 여부. 참석 요청 알림 포함 (TODO 옵션화 필요)
	url += "?sendNotifications=true";
	
	$.ajax({
	    url: "/covicore/oauth2/client/callGoogleRestAPI.do",
	    type: "POST",
	    data: {
	    	"url" : url,
	    	"type" : "PUT",
	    	"userCode" : googleUserCode,
	    	"params" : JSON.stringify(params)
	    },
	    success: function (res) {
	    	if(res.status == "200"){
	    		if(setType == "DD"){
    				if(g_viewType == "M"){
    					schedule_MakeMonthCalendar();
    				}else if(g_viewType == "D"){
    					scheduleUser.schedule_MakeDayCalendar();
    				}else if(g_viewType == "W"){
    					scheduleUser.schedule_MakeWeekCalendar();
    				}
    			}else{
    				Common.Inform(Common.getDic("msg_117"), "", function(){			//성공적으로 저장하였습니다.
    	    			if(setType == "S")
    	    				scheduleUser.refresh();
    	    			else
    		    			CoviMenu_GetContent(g_lastURL);
    	    		});
    			}
	    	}else{
	    		//Common.Error(Common.getDic("msg_apv_030"));		// 오류가 발생했습니다.
	    	}
        },
        error:function(response, status, error){
			CFN_ErrorAjax("/covicore/oauth2/client/callGoogleRestAPI.do", response, status, error);
		}
	});
}

// Drag & Drop 의 수정을 위한 데이터 가공
function coverGoogleEventForDragNDrop(eventID, dateID, sDate, sTime){
	var fnReturnDragNDrop = function(mode, data){
		var resultObj = {};
		
		var start_date = "";
		var end_date = "";
		var start_time = "";
		var end_time = "";
		
		var isAllDay = data.start.dateTime != undefined ? "N" : "Y";
		
		if(isAllDay != "Y"){
			start_date = schedule_SetDateFormat(new Date(data.start.dateTime), "-");
			end_date = schedule_SetDateFormat(new Date(data.end.dateTime), "-");
			start_time = AddFrontZero(new Date(data.start.dateTime).getHours(), 2)+":"+AddFrontZero(new Date(data.start.dateTime).getMinutes(), 2);
			end_time =  AddFrontZero(new Date(data.end.dateTime).getHours(), 2)+":"+AddFrontZero(new Date(data.end.dateTime).getMinutes(), 2);
		}else{
			start_date = data.start.date;
			end_date = data.end.date;
		}
		
		resultObj = data;
		
		var diifDate = schedule_GetDiffDates(new Date(replaceDate(start_date)), new Date(replaceDate(end_date)), 'day');
		var diifTime = schedule_GetDiffDates(new Date(replaceDate(start_date) + " " +start_time), new Date(replaceDate(end_date) + " " +end_time), 'min');
		
		var eDate = schedule_SetDateFormat(schedule_AddDays(sDate, diifDate), '-');
		var eTime = new Date(new Date(replaceDate(sDate) + " " + sTime).getTime() + (diifTime*60000));
		
		if(sTime == undefined){
			sTime = start_time;
			eTime = end_time;
		}else{
	    	var hour = AddFrontZero(eTime.getHours(), 2);
	    	var min = AddFrontZero(eTime.getMinutes(), 2);
			eTime = hour + ":" + min;
		}
		
		resultObj.start = {};
		resultObj.end = {};
		if(isAllDay != "Y"){
			resultObj.start.dateTime = new Date(replaceDate(sDate) + " " + sTime).toISOString();
			resultObj.end.dateTime = new Date(replaceDate(eDate) + " " + eTime).toISOString();
		}else{
			resultObj.start.date = sDate;
			resultObj.end.date = eDate;
		}
		
		updateGoogleEventData("DD", resultObj, eventID);
	};
	
	getGoogleEventOne("DD", eventID, fnReturnDragNDrop, true);
}

//Resize 의 수정을 위한 데이터 가공
function coverGoogleEventForResize(eventID, endDateTime){
	var fnReturnDragNDrop = function(mode, data){
		var resultObj = {};
		
		resultObj = data;
		
		resultObj.end.dateTime = new Date(replaceDate(endDateTime)).toISOString();
		
		updateGoogleEventData("DD", resultObj, eventID);
	};
	
	getGoogleEventOne("DD", eventID, fnReturnDragNDrop, true);
}