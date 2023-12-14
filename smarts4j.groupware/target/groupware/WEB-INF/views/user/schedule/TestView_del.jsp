<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/include.jsp"></jsp:include>

<script>
	function getView(){
		var folderIDs = ";1008;1009;1010;1011;1012;1013;1031;1033;";
		var startDate = "2017-08-01";
		var endDate = "2017-08-31";
		var userCode = "gypark";
		var lang = Common.getSession("lang");
		var importanceState = "";
		
		$.ajax({
		    url: "getView.do",
		    type: "POST",
		    data: {
		    	"FolderIDs" : folderIDs,
		    	"StartDate" : startDate,
		    	"EndDate" : endDate,
		    	"UserCode" : userCode,
		    	"lang" : lang,
		    	"ImportanceState" : importanceState
			},
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
		    		var htmlStr = "";
		    		$(res.list).each(function(){
		    			htmlStr += JSON.stringify(this) + "<br><br>";
		    		});
			    	$("#getViewResult").html(htmlStr);
		    	} else {
					Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
				}
	        },
	        error:function(response, status, error){
				CFN_ErrorAjax("getView.do", response, status, error);
			}
		});
	}
	
	
	function setOne(){
		var eventObj = {
				"Event" : {
					  "FolderID": "1033",
					  "FolderType": "Schedule",
					  "EventType": "",
					  "LinkEventID": "",
					  "MasterEventID": "",
					  "Subject": "테스트 08290924_778",
					  "Description": "테스트 08290924_778",
					  "IsPublic": "Y",
					  "IsDisplay":"Y",
					  "IsInviteOther": "N",
					  "ImportanceState": "Y",
					  "OwnerCode": "gypark",
					  "RegisterCode": "gypark",
					  "MultiRegisterName": "박경연;;;;;;",
					  "ModifierCode": "gypark"
				},
				"Date" : {
					  "StartDate": "2017-08-29",
					  "EndDate": "2017-08-29",
					  "StartTime": "16:50",
					  "EndTime": "17:30",
					  "IsAllDay": "N",
					  "IsRepeat": "N"
				},
				  "Resource": [
				    {
				      "FolderID": "778",
				      "ResourceName": "11층 대회의실"
				    }
				  ],
				  "Repeat": {},
				  "Attendee": [
					{
					    "UserCode": "yjlee",
					    "UserName": "이연재",
					    "Email": "yjlee@covision.co.kr",
					    "IsOutsider": "N"
					 },
					 {
					    "UserCode": "ywcho",
					    "UserName": "조용욱",
					    "Email": "ywcho@covision.co.kr",
					    "IsOutsider": "N"
					 }
				  ],
				  "Notification": {
				    "IsNotification": "N",
				    "IsReminder": "N",
				    "ReminderTime": "",
				    "IsCommentNotification": "N",
				    "MediumKind": ""
				  }
				};
			
			/* {
				"Event" : {
					  "FolderID": "1033",
					  "FolderType": "Schedule",
					  "EventType": "",
					  "LinkEventID": "",
					  "MasterEventID": "",
					  "Subject": "반복일정 테스트 0822",
					  "Description": "반복일정 테스트 0822",
					  "IsPublic": "Y",
					  "IsDisplay":"Y",
					  "IsInviteOther": "N",
					  "ImportanceState": "Y",
					  "OwnerCode": "gypark",
					  "RegisterCode": "gypark",
					  "MultiRegisterName": "박경연;;;;;;",
					  "ModifierCode": "gypark"
				},
				"Date" : {
					  "StartDate": "2017-08-28",
					  "EndDate": "2017-09-28",
					  "StartTime": "00:00",
					  "EndTime": "00:30",
					  "IsAllDay": "N",
					  "IsRepeat": "Y"
				},
				  "Resource": [
				    {
				      "FolderID": "755",
				      "ResourceName": "13층 대회의실"
				    }
				  ],
				  "Repeat": {
						  "ResourceRepeat": {
						    "AppointmentStartTime": "00:00",
						    "AppointmentEndTime": "00:30",
						    "AppointmentDuring": "30",
						    "RepeatType": "W",
						    "RepeatYear": "0",
						    "RepeatMonth": "0",
						    "RepeatWeek": "1",
						    "RepeatDay": "1",
						    "RepeatMonday": "Y",
						    "RepeatTuesday": "N",
						    "RepeatWednseday": "N",
						    "RepeatThursday": "N",
						    "RepeatFriday": "N",
						    "RepeatSaturday": "N",
						    "RepeatSunday": "N",
						    "RepeatStartDate": "2017-08-28",
						    "RepeatEndType": "I",
						    "RepeatEndDate": "2017-09-28",
						    "RepeatCount": "0",
						    "RepeatAppointType":"",
						    "RepetitionPerAtt":"1"
						  }
				  },
				  "Attendee": [
					{
					    "UserCode": "yjlee",
					    "UserName": "이연재",
					    "Email": "yjlee@covision.co.kr",
					    "IsOutsider": "N"
					 },
					 {
					    "UserCode": "ywcho",
					    "UserName": "조용욱",
					    "Email": "ywcho@covision.co.kr",
					    "IsOutsider": "N"
					 }
				  ],
				  "Notification": {
				    "IsNotification": "N",
				    "IsReminder": "N",
				    "ReminderTime": "",
				    "IsCommentNotification": "N",
				    "MediumKind": ""
				  }
				}; */

		
		$.ajax({
		    url: "setOne.do",
		    type: "POST",
		    data: {
		    	"mode" : "I",
		    	"eventObj" : JSON.stringify(eventObj)
			},
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
			    	$("#setOneResult").html("등록 성공");
		    	} else {
					Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
				}
		       },
		       error:function(response, status, error){
				CFN_ErrorAjax("setOne.do", response, status, error);
			}
		});
	}
	
	function setOne_Update(){
		var eventObj = {
					"EventID" : "133",
					"DateID" : "7;",
					"RepeatID" : "4",
					"Event" : {
						  "FolderID": "1009",
						  "FolderType": "Schedule.Person",
						  "EventType": "",
						  "LinkEventID": "",
						  "MasterEventID": "",
						  "Subject": "일학습병행제 발표준비",
						  "Description": "일학습병행제 발표준비",
						  "IsPublic": "Y",
						  "IsDisplay":"Y",
						  "IsInviteOther": "N",
						  "ImportanceState": "Y",
						  "OwnerCode": "gypark",
						  "RegisterCode": "gypark",
						  "MultiRegisterName": "박경연;;;;;;",
						  "ModifierCode": "gypark"
					}
				};
		
		$.ajax({
		    url: "setOne.do",
		    type: "POST",
		    data: {
		    	"mode" : "U",
		    	"eventObj" : JSON.stringify(eventObj)
			},
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
			    	$("#setOneResult_Update").html("수정 성공");
		    	} else {
					Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
				}
		       },
		       error:function(response, status, error){
				CFN_ErrorAjax("setOne.do", response, status, error);
			}
		});
	}
	
	function setOne_Simple(){
		var eventObj = {
				  "Event": {
				    "FolderID": "1009",
				    "FolderType": "Schedule.Person",
				    "EventType": "",
				    "LinkEventID": "",
				    "MasterEventID": "",
				    "Subject": "간단 등록 테스트 0821",
				    "Description": "",
				    "IsPublic": "Y",
					"IsDisplay":"Y",
				    "IsInviteOther": "N",
				    "ImportanceState": "N",
				    "OwnerCode": "gypark",
				    "RegisterCode": "gypark",
				    "MultiRegisterName": "박경연;;;;;;",
				    "ModifierCode": "gypark"
				  },
				  "Date": {
				    "StartDate": "2017-08-21",
				    "EndDate": "2017-08-21",
				    "StartTime": "20:00",
				    "EndTime": "22:00",
				    "IsAllDay": "N",
				    "IsRepeat": "N"
				  },
				  "Resource": [
				    {
				      "FolderID": "755",
				      "ResourceName": "13층 대회의실"
				    }
				  ],
				  "Repeat": {},
				  "Attendee": [],
				  "Notification": {
				    "IsNotification": "N",
				    "IsReminder": "N",
				    "ReminderTime": "",
				    "IsCommentNotification": "N",
				    "MediumKind": ""
				  }
				};
		
		$.ajax({
		    url: "setOne.do",
		    type: "POST",
		    data: {
		    	"mode" : "I",
		    	"eventObj" : JSON.stringify(eventObj)
			},
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
			    	$("#setOne_Simple").html("등록 성공");
		    	} else {
					Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
				}
		       },
		       error:function(response, status, error){
				CFN_ErrorAjax("setOne.do", response, status, error);
			}
		});
	}
	
	function setNotification(){
		var eventID = "166";
		var registerCode = "gypark";
		var isNotification = "Y";
		var isReminder = "N";
		var reminderTime = "";
		var isCommentNotification = "Y";
		var mediumKind = "ToDo;";
		
		$.ajax({
		    url: "setNotification.do",
		    type: "POST",
		    data: {
		    	"EventID" : eventID,
		    	"RegisterCode" : registerCode,
				"IsNotification" : isNotification,
				"IsReminder" : isReminder,
				"ReminderTime" : reminderTime,
				"IsCommentNotification" : isCommentNotification,
				"MediumKind" : mediumKind
			},
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
			    	$("#setNotification").html("개별 수정 성공");
		    	} else {
					Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
				}
		       },
		       error:function(response, status, error){
				CFN_ErrorAjax("setNotification.do", response, status, error);
			}
		});
	}
	
	function goOne(){
		var mode = "D";
		var lang = "ko";
		var eventID = "129";
		var dateID = "";
		var isRepeat = "N";
		var userCode = "gypark";
		
		location.href = "goOne.do?"
						+"mode="+mode
						+"&lang="+lang
						+"&EventID="+eventID
						+"&DateID="+dateID
						+"&IsRepeat="+isRepeat
						+"&UserCode="+userCode;
	}
	
	function goOne_Simple(){
		var mode = "S";
		var lang = "ko";
		var eventID = "129";
		var dateID = "";
		var isRepeat = "N";
		var userCode = "gypark";
		
		location.href = "goOne.do?"
						+"mode="+mode
						+"&lang="+lang
						+"&EventID="+eventID
						+"&DateID="+dateID
						+"&IsRepeat="+isRepeat
						+"&UserCode="+userCode;
	}
	
	function remove(){
		var eventID = "139";
		
		$.ajax({
		    url: "remove.do",
		    type: "POST",
		    data: {
		    	"EventID" : eventID
			},
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
			    	$("#remove").html("삭제 성공");
		    	} else {
					Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
				}
		       },
		       error:function(response, status, error){
				CFN_ErrorAjax("remove.do", response, status, error);
			}
		});
	}
	
	function getList(){
		var folderIDs = "1008;1009;1010;1011;1012;1013;1031;1033;";
		var startDate = "2017-08-01";
		var endDate = "2017-08-31";
		var userCode = "gypark";
		var lang = Common.getSession("lang");
		var importanceState = "";
		
		$.ajax({
		    url: "getList.do",
		    type: "POST",
		    data: {
		    	"FolderIDs" : folderIDs,
		    	"StartDate" : startDate,
		    	"EndDate" : endDate,
		    	"UserCode" : userCode,
		    	"lang" : lang,
		    	"ImportanceState" : importanceState
			},
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
		    		var htmlStr = "";
		    		$(res.list).each(function(){
		    			htmlStr += JSON.stringify(this) + "<br><br>";
		    		});
			    	$("#getList").html(htmlStr);
		    	} else {
					Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
				}
	        },
	        error:function(response, status, error){
				CFN_ErrorAjax("getList.do", response, status, error);
			}
		});
	}
	
	function getListDetail(){
		var eventID = "141";
		var lang = Common.getSession("lang");
		
		$.ajax({
		    url: "getListDetail.do",
		    type: "POST",
		    data: {
		    	"EventID" : eventID,
		    	"lang" : lang
			},
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
			    	$("#getListDetail").html(JSON.stringify(res.EventJson));
		    	} else {
					Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
				}
	        },
	        error:function(response, status, error){
				CFN_ErrorAjax("getListDetail.do", response, status, error);
			}
		});
	}
	
	function getToday(){
		var folderIDs = ";1008;1009;1010;1011;1012;1013;1031;1033;";
		var userCode = "gypark";
		var lang = Common.getSession("lang");
		
		$.ajax({
		    url: "getToday.do",
		    type: "POST",
		    data: {
		    	"FolderIDs" : folderIDs,
		    	"UserCode" : userCode,
		    	"lang" : lang
			},
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
		    		var htmlStr = "";
		    		$(res.list).each(function(){
		    			htmlStr += JSON.stringify(this) + "<br><br>";
		    		});
			    	$("#getToday").html(htmlStr);
		    	} else {
					Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
				}
	        },
	        error:function(response, status, error){
				CFN_ErrorAjax("getToday.do", response, status, error);
			}
		});
	}
	
	function getThisMonth(){
		var folderIDs = ";1008;1009;1010;1011;1012;1013;1031;1033;";
		var userCode = "gypark";
		var lang = Common.getSession("lang");
		
		$.ajax({
		    url: "getThisMonth.do",
		    type: "POST",
		    data: {
		    	"FolderIDs" : folderIDs,
		    	"UserCode" : userCode,
		    	"lang" : lang
			},
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
		    		var htmlStr = "";
		    		$(res.list).each(function(){
		    			htmlStr += JSON.stringify(this) + "<br><br>";
		    		});
			    	$("#getThisMonth").html(htmlStr);
		    	} else {
					Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
				}
	        },
	        error:function(response, status, error){
				CFN_ErrorAjax("getThisMonth.do", response, status, error);
			}
		});
	}
	
	function getAttendList(){
		var folderIDs = ";1008;1009;1010;1011;1012;1013;1031;1033;";
		var userCode = "yjlee";
		var lang = Common.getSession("lang");
		
		$.ajax({
		    url: "getAttendList.do",
		    type: "POST",
		    data: {
		    	"FolderIDs" : folderIDs,
		    	"UserCode" : userCode,
		    	"lang" : lang
			},
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
		    		var htmlStr = "";
		    		$(res.list).each(function(){
		    			htmlStr += JSON.stringify(this) + "<br><br>";
		    		});
			    	$("#getAttendList").html(htmlStr);
		    	} else {
					Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
				}
	        },
	        error:function(response, status, error){
				CFN_ErrorAjax("getAttendList.do", response, status, error);
			}
		});
	}
	
	function approve(){
		var mode = "APPROVAL";
		var personalFolderID = "1009";
		var eventID = "141";
		var userCode = "yjlee";
		
		$.ajax({
		    url: "approve.do",
		    type: "POST",
		    data: {
		    	"mode" : mode,
		    	"PersonalFolderID" : personalFolderID,
		    	"EventID" : eventID,
		    	"UserCode" : userCode
			},
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
			    	$("#approve").html("승인 성공");
		    	} else {
					Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
				}
		       },
		       error:function(response, status, error){
				CFN_ErrorAjax("approve.do", response, status, error);
			}
		});
	}
	
	function setOne_Template(){
		var eventObj = {
				"Event" : {
					  "FolderID": "1033",
					  "FolderType": "Schedule",
					  "EventType": "F",				// 변경되지 않는 값
					  "LinkEventID": "",
					  "MasterEventID": "",
					  "Subject": "자주 쓰는 일정 테스트 0828_1",
					  "Description": "자주 쓰는 일정 테스트 0828_1",
					  "IsPublic": "Y",
					  "IsDisplay":"N",				// 변경되지 않는 값
					  "IsInviteOther": "N",
					  "ImportanceState": "Y",
					  "OwnerCode": "gypark",
					  "RegisterCode": "gypark",
					  "MultiRegisterName": "박경연;;;;;;",
					  "ModifierCode": "gypark"
				},
				"Date" : {
					  "StartDate": "",				// 변경되지 않는 값
					  "EndDate": "",				// 변경되지 않는 값
					  "StartTime": "",				// 변경되지 않는 값
					  "EndTime": "",				// 변경되지 않는 값
					  "IsAllDay": "N",				// 변경되지 않는 값
					  "IsRepeat": "N"				// 변경되지 않는 값
				},
				  "Resource": [
				    {
				      "FolderID": "755",
				      "ResourceName": "13층 대회의실"
				    }
				  ],
				  "Repeat": {				// 변경되지 않는 값
				  },
				  "Attendee": [
					{
					    "UserCode": "yjlee",
					    "UserName": "이연재",
					    "Email": "yjlee@covision.co.kr",
					    "IsOutsider": "N"
					 },
					 {
					    "UserCode": "ywcho",
					    "UserName": "조용욱",
					    "Email": "ywcho@covision.co.kr",
					    "IsOutsider": "N"
					 }
				  ],
				  "Notification": {
				    "IsNotification": "N",
				    "IsReminder": "N",
				    "ReminderTime": "",
				    "IsCommentNotification": "N",
				    "MediumKind": ""
				  }
				};

		
		$.ajax({
		    url: "setOne.do",
		    type: "POST",
		    data: {
		    	"mode" : "I",
		    	"eventObj" : JSON.stringify(eventObj)
			},
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
			    	$("#setOne_Template").html("등록 성공");
		    	} else {
					Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
				}
		       },
		       error:function(response, status, error){
				CFN_ErrorAjax("setOne.do", response, status, error);
			}
		});
	}
	
	function getTemplateList(){
		var userCode = "gypark";
		
		$.ajax({
		    url: "getTemplateList.do",
		    type: "POST",
		    data: {
		    	"UserCode" : userCode
			},
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
		    		var htmlStr = "";
		    		$(res.list).each(function(){
		    			htmlStr += JSON.stringify(this) + "<br><br>";
		    		});
			    	$("#getTemplateList").html(htmlStr);
		    	} else {
					Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
				}
	        },
	        error:function(response, status, error){
				CFN_ErrorAjax("getTemplateList.do", response, status, error);
			}
		});
	}
	
	function goOne_Template(){
		var mode = "D";
		var lang = "ko";
		var eventID = "188";
		var dateID = "";
		var isRepeat = "N";
		var userCode = "gypark";
		
		location.href = "goOne.do?"
						+"mode="+mode
						+"&lang="+lang
						+"&EventID="+eventID
						+"&DateID="+dateID
						+"&IsRepeat="+isRepeat
						+"&UserCode="+userCode;
	}
	
	function removeTemplate(){
		var eventID = "187";
		
		$.ajax({
		    url: "removeTemplate.do",
		    type: "POST",
		    data: {
		    	"EventID" : eventID
			},
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
			    	$("#removeTemplate").html("삭제 성공");
		    	} else {
					Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
				}
		       },
		       error:function(response, status, error){
				CFN_ErrorAjax("removeTemplate.do", response, status, error);
			}
		});
	}
	
	function getThemeList(){
		var userCode = "gypark";
		
		$.ajax({
		    url: "getThemeList.do",
		    type: "POST",
		    data: {
		    	"UserCode" : userCode
			},
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
		    		var htmlStr = "";
		    		$(res.list).each(function(){
		    			htmlStr += JSON.stringify(this) + "<br><br>";
		    		});
			    	$("#getThemeList").html(htmlStr);
		    	} else {
					Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
				}
	        },
	        error:function(response, status, error){
				CFN_ErrorAjax("getThemeList.do", response, status, error);
			}
		});
	}
	
	function setTheme(){
		var mode = "I";
		var folderData = {
				"DisplayName" : "테마 일정 테스트1",
				"MultiDisplayName" : "테마 일정 테스트1;;;;;;",
				"DefaultColor" : "#6999d2",
				"ManageCompany" : "",
				"OwnerCode" : "gypark",
				"IsInherited" : "Y",
				"RegisterCode" : "gypark",
				"ModifierCode" : "gypark"
		};
		var aclData = [{"SubjectType":"CM","SubjectCode":"ORGROOT","AclList":"SCDMEVR"}];
		
		$.ajax({
		    url: "setTheme.do",
		    type: "POST",
		    data: {
		    	"mode" : mode,
		    	"folderData" : JSON.stringify(folderData),
		    	"aclData" : JSON.stringify(aclData)
			},
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
			    	$("#setTheme").html("등록 성공");
		    	} else {
					Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
				}
		       },
		       error:function(response, status, error){
				CFN_ErrorAjax("setTheme.do", response, status, error);
			}
		});
	}
	
	function removeTheme(){
		var folderIDs = ";1043;";
		$.ajax({
		    url: "removeTheme.do",
		    type: "POST",
		    data: {
		    	"FolderIDs" : folderIDs
			},
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
			    	$("#removeTheme").html("삭제 성공");
		    	} else {
					Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
				}
		       },
		       error:function(response, status, error){
				CFN_ErrorAjax("removeTheme.do", response, status, error);
			}
		});
	}
	
	function setShareMine(){
		var mode = "I";
		var TargetDataArr = [{
			"TargetType" : "U",
			"TargetCode" : "bsseo2",
			"TargetName" : "서봉수",
			"StartDate" : "2017-08-29",
			"EndDate" : "2017-08-29"
		}];
		
		$.ajax({
		    url: "setShareMine.do",
		    type: "POST",
		    data: {
		    	"mode" : mode,
		    	"TargetDataArr" : JSON.stringify(TargetDataArr)
			},
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
			    	$("#setShareMine").html("등록 성공");
		    	} else {
					Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
				}
		       },
		       error:function(response, status, error){
				CFN_ErrorAjax("setShareMine.do", response, status, error);
			}
		});
	}
	
	function getShareMine(){
		$.ajax({
		    url: "getShareMine.do",
		    type: "POST",
		    data: {
			},
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
		    		var htmlStr = "";
		    		$(res.list).each(function(){
		    			htmlStr += JSON.stringify(this) + "<br><br>";
		    		});
			    	$("#getShareMine").html(htmlStr);
		    	} else {
					Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
				}
	        },
	        error:function(response, status, error){
				CFN_ErrorAjax("getShareMine.do", response, status, error);
			}
		});
	}
</script>

<body>
	일정보기(getView.do)<br>
	<input type="button" value="호출" onclick="getView()">
	<div id="getViewResult"></div><br>
	<br>
	상세등록(setOne.do)<br>
	<input type="button" value="호출" onclick="setOne()">
	<div id="setOneResult"></div><br>
	<br>
	상세등록(setOne.do) - 수정<br>
	<input type="button" value="호출" onclick="setOne_Update()">
	<div id="setOneResult_Update"></div><br>
	<br>
	간단등록(setOne.do)<br>
	<input type="button" value="호출" onclick="setOne_Simple()">
	<div id="setOne_Simple"></div><br>
	<br>
	알림 개별 수정(setNotification.do)<br>
	<input type="button" value="호출" onclick="setNotification()">
	<div id="setNotification"></div><br>
	<br>
	상세조회(goOne.do)<br>
	<input type="button" value="호출" onclick="goOne()"><br>
	<br>
	간단조회(goOne.do)<br>
	<input type="button" value="호출" onclick="goOne_Simple()"><br>
	<br>
	일정삭제(remove.do)<br>
	<input type="button" value="호출" onclick="remove()">
	<div id="remove"></div><br>
	<br>
	일정 목록 조회(getList.do)<br>
	<input type="button" value="호출" onclick="getList()">
	<div id="getList"></div><br>
	<br>
	일정 목록 상세 조회 - 펼치기(getListDetail.do)<br>
	<input type="button" value="호출" onclick="getListDetail()">
	<div id="getListDetail"></div><br>
	<br>
	오늘의 일정 조회(getToday.do)<br>
	<input type="button" value="호출" onclick="getToday()">
	<div id="getToday"></div><br>
	<br>
	이달의 일정 조회(getThisMonth.do)<br>
	<input type="button" value="호출" onclick="getThisMonth()">
	<div id="getThisMonth"></div><br>
	<br>
	참석 요청 중인 일정(getAttendList.do)<br>
	<input type="button" value="호출" onclick="getAttendList()">
	<div id="getAttendList"></div><br>
	<br>
	참석자 승인 /  거부(approve.do)<br>
	<input type="button" value="호출" onclick="approve()">
	<div id="approve"></div><br>
	<br>
	자주 쓰는 일정 세팅(setOne.do)<br>
	<input type="button" value="호출" onclick="setOne_Template()">
	<div id="setOne_Template"></div><br>
	<br>
	자주 쓰는 일정 목록 조회(getTemplateList.do)<br>
	<input type="button" value="호출" onclick="getTemplateList()">
	<div id="getTemplateList"></div><br>
	<br>
	자주 쓰는 일정 조회(goOne.do)<br>
	<input type="button" value="호출" onclick="goOne_Template()">
	<div id="goOne_Template"></div><br>
	<br>
	자주 쓰는 일정 삭제(removeTemplate.do)<br>
	<input type="button" value="호출" onclick="removeTemplate()">
	<div id="removeTemplate"></div><br>
	<br>
	테마일정 목록 조회(getThemeList.do)<br>
	<input type="button" value="호출" onclick="getThemeList()">
	<div id="getThemeList"></div><br>
	<br>
	테마일정 등록(setTheme.do)<br>
	<input type="button" value="호출" onclick="setTheme()">
	<div id="setTheme"></div><br>
	<br>
	테마일정 삭제(removeTheme.do)<br>
	<input type="button" value="호출" onclick="removeTheme()">
	<div id="removeTheme"></div><br>
	<br>
	개인일정 공유 등록(setShareMine.do)<br>
	<input type="button" value="호출" onclick="setShareMine()">
	<div id="setShareMine"></div><br>
	<br>
	개인일정 공유 조회(getShareMine.do)<br>
	<input type="button" value="호출" onclick="getShareMine()">
	<div id="getShareMine"></div><br>
	<br>
</body>