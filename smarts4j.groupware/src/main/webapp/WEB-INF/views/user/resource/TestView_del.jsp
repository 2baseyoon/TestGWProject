<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<script>
	function getResourceList(){
		$.ajax({
			url: '/groupware/resource/getResourceList.do',
			type: 'post',
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
		    		$("#resourceResult").html(JSON.stringify(res));
		    	} else {
					Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
				}
		       },
		       error:function(response, status, error){
				CFN_ErrorAjax("getResourceList.do", response, status, error);
			}
		});
	}


	function getFolderTreeData(){
		$.ajax({
			url: '/groupware/resource/getFolderTreeData.do',
			type: 'post',
			data:{
				"placeOfBusiness" : "",
			},
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
		    		$("#treeResult").html(JSON.stringify(res));
		    	} else {
					Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
				}
		       },
		       error:function(response, status, error){
				CFN_ErrorAjax("getBookingList.do", response, status, error);
			}
		});
	}
	
	function getManageInfo(){
		$.ajax({
			url: '/groupware/resource/getManageInfo.do',
			type: 'post',
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
		    		$("#manageInfoResult").html(JSON.stringify(res));
		    	} else {
					Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
				}
		       },
		       error:function(response, status, error){
				CFN_ErrorAjax("getManageInfo.do", response, status, error);
			}
		});
		
		
	}
	function getDailyList(){
		$.ajax({
			url: '/groupware/resource/getBookingList.do',
			type: 'post',
			data:{
				"mode" : "Period",
				"FolderID" : ";755;777;778;" ,
				"StartDate" :"2017-08-25",
				"EndDate" :"2017-08-25",
			},
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
		    		$("#dailyResult").html(JSON.stringify(res));
		    	} else {
					Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
				}
		       },
		       error:function(response, status, error){
				CFN_ErrorAjax("getBookingList.do", response, status, error);
			}
		});
	}
	
	
	function getMyBook(){
		$.ajax({
			url: '/groupware/resource/getBookingList.do',
			type: 'post',
			data:{
				"mode" : "List",
				"userID" : "gypark",
				"ApprovalState": "Approval;ApprovalCancel;ApprovalDeny;ApprovalRequest;AutoCancel;Reject;ReturnComplete;ReturnRequest",
				"sortBy" :"RegistDate DESC",
			},
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
		    		$("#myBookResult").html(JSON.stringify(res));
		    	} else {
					Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
				}
		       },
		       error:function(response, status, error){
				CFN_ErrorAjax("getBookingList.do", response, status, error);
			}
		});
	}
	
	function getApprovalRequest(){
		$.ajax({
			url: '/groupware/resource/getBookingList.do',
			type: 'post',
			data:{
				"mode" : "List",
				"ApprovalState": "Approval;ApprovalCancel;ApprovalDeny;ApprovalRequest;AutoCancel;Reject;ReturnComplete;ReturnRequest",
				"FolderID" :";755;",
				"sortBy" :"RegistDate DESC",
			},
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
		    		$("#approvalRequestResult").html(JSON.stringify(res));
		    	} else {
					Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
				}
		       },
		       error:function(response, status, error){
				CFN_ErrorAjax("getBookingList.do", response, status, error);
			}
		});
	}
	
	function saveBookingData(){
		//일반 자원예약
	/* 	var eventObj = {
				"IsSchedule": "N",
				"ResourceID": "755",
				"Event" : {
					  "FolderID": "755",
					  "FolderType": "Resource",
					  "Subject": "자원 예약 업무 협의 (0823)",
					  "Description": "자원 예약 업무 협의 (0823)",
					  "RegisterCode": "yjlee",
					  "MultiRegisterName": "이연재;;;;;;"
				},
				"Date" : {
					  "StartDate": "2017-08-23",
					  "EndDate": "2017-08-23",
					  "StartTime": "10:00",
					  "EndTime": "12:00",
					  "IsAllDay": "N",
					  "IsRepeat": "N"
				},
				"Repeat": {"ResourceRepeat":{}},
				"Notification": {
				    "IsNotification": "N",
				    "IsReminder": "N",
				    "ReminderTime": "",
				    "IsCommentNotification": "N",
				    "MediumKind": ""
				  },
				"UserForm":[
				 {"UserFormID": "1" ,
				  "FolderID":"755",
				  "FieldValue": "testtest"},
				 {"UserFormID": "2" ,
				  "FolderID":"755",
				  "FieldValue": "testtest2"}
				 ]
				}; */
				
		// 반복 자원 예약
		/* var eventObj = {
				"IsSchedule": "N",
				"ResourceID": "755",
				"Event" : {
					  "FolderID": "755",
					  "FolderType": "Resource",
					  "Subject": "자원 예약 업무 협의 (0823)",
					  "Description": "자원 예약 업무 협의 (0823)",
					  "RegisterCode": "yjlee",
					  "MultiRegisterName": "이연재;;;;;;"
				},
				"Date" : {
					  "StartDate": "2017-08-23",
					  "EndDate": "2017-09-27",
					  "StartTime": "10:00",
					  "EndTime": "12:00",
					  "IsAllDay": "N",
					  "IsRepeat": "Y"
				},
				 "Repeat": {
					  "ResourceRepeat": {
					    "AppointmentStartTime": "10:00",
					    "AppointmentEndTime": "12:00",
					    "AppointmentDuring": "30",
					    "RepeatType": "W",
					    "RepeatYear": "0",
					    "RepeatMonth": "0",
					    "RepeatWeek": "1",
					    "RepeatDay": "1",
					    "RepeatMonday": "N",
					    "RepeatTuesday": "N",
					    "RepeatWednseday": "Y",
					    "RepeatThursday": "N",
					    "RepeatFriday": "N",
					    "RepeatSaturday": "N",
					    "RepeatSunday": "N",
					    "RepeatStartDate": "2017-08-23",
					    "RepeatEndType": "I",
					    "RepeatEndDate": "2017-09-27",
					    "RepeatCount": "0",
					    "RepeatAppointType":"",
					    "RepetitionPerAtt":"1"
					  }
			  },
				"Notification": {
				    "IsNotification": "N",
				    "IsReminder": "N",
				    "ReminderTime": "",
				    "IsCommentNotification": "N",
				    "MediumKind": ""
				  },
				"UserForm":[
				 {"UserFormID": "1" ,
				  "FolderID":"755",
				  "FieldValue": "two"},
				 {"UserFormID": "2" ,
				  "FolderID":"755",
				  "FieldValue": "two"}
				 ]
				}; */
				
		//일정으로 등록	
		/* var eventObj = {
				"IsSchedule": "Y",
				"ResourceID": "755",
				"Event" : {
					  "FolderID": "755",
					  "FolderType": "Resource",
					  "Subject": "자원을 통한 일정 등록",
					  "Description": "자원을 통한 일정 등록",
					  "RegisterCode": "yjlee",
					  "MultiRegisterName": "이연재;;;;;;"
				},
				"Date" : {
					  "StartDate": "2017-08-25",
					  "EndDate": "2017-08-25",
					  "StartTime": "13:00",
					  "EndTime": "14:00",
					  "IsAllDay": "N",
					  "IsRepeat": "N"
				},
				 "Repeat": {
					  "ResourceRepeat": {  }
			  	},
				"Notification": {
				    "IsNotification": "N",
				    "IsReminder": "N",
				    "ReminderTime": "",
				    "IsCommentNotification": "N",
				    "MediumKind": ""
				  },
				"UserForm":[ ]
				}; */

		
		$.ajax({
		    url: "/groupware/resource/saveBookingData.do",
		    type: "POST",
		    data: {
		    	"mode" : "I",
		    	"eventStr" : JSON.stringify(eventObj)
			},
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
			    	$("#saveBookingDataResult").html(res.result + res.message);
		    	} else {
					Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
				}
		       },
		       error:function(response, status, error){
				CFN_ErrorAjax("getBookingList.do", response, status, error);
			}
		});
	}
	
	function saveBookingData_Update(){
		var eventObj = {
					"EventID" : "176",
					"DateID" : "32;",
					"RepeatID" : "43",
					"ResourceID": "775",
					"IsSchedule": "N",
					"Event" : {
						  "FolderID": "755",
						  "FolderType": "Resource",
						  "Subject": "자원 예약 수정",
						  "Description": "자원 예약 수정",
						  "RegisterCode": "yjlee",
						  "MultiRegisterName": "이연재;;;;;;",
					},
					"Date" : {
						  "StartDate": "2017-08-23",
						  "EndDate": "2017-09-27",
						  "StartTime": "10:00",
						  "EndTime": "12:00",
						  "IsAllDay": "N",
						  "IsRepeat": "Y"
					},
					 "Repeat": {
						  "ResourceRepeat": {
						    "AppointmentStartTime": "10:00",
						    "AppointmentEndTime": "12:00",
						    "AppointmentDuring": "30",
						    "RepeatType": "W",
						    "RepeatYear": "0",
						    "RepeatMonth": "0",
						    "RepeatWeek": "1",
						    "RepeatDay": "1",
						    "RepeatMonday": "N",
						    "RepeatTuesday": "N",
						    "RepeatWednseday": "Y",
						    "RepeatThursday": "N",
						    "RepeatFriday": "N",
						    "RepeatSaturday": "N",
						    "RepeatSunday": "N",
						    "RepeatStartDate": "2017-08-23",
						    "RepeatEndType": "I",
						    "RepeatEndDate": "2017-09-27",
						    "RepeatCount": "0",
						    "RepeatAppointType":"",
						    "RepetitionPerAtt":"1"
						  }
				  }
				};
		
		$.ajax({
		    url: "/groupware/resource/saveBookingData.do",
		    type: "POST",
		    data: {
		    	"mode" : "U",
		    	"eventStr" : JSON.stringify(eventObj)
			},
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
			    	$("#saveBookingDataResult_Update").html("수정 성공");
		    	} else {
					Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
				}
		       },
		       error:function(response, status, error){
				CFN_ErrorAjax("/groupware/resource/saveBookingData.do", response, status, error);
			}
		});
	}
	
	function saveBookingData_Simple(){
		var eventObj = {
				   "IsSchedule": "N",
				   "ResourceID": "755",
				  "Event": {
					  "FolderID": "755",
					  "FolderType": "Resource",
					  "Subject": "자원 간편 예약",
					  "Description": "자원 간편 예약",
					  "RegisterCode": "yjlee",
					  "MultiRegisterName": "이연재;;;;;;",
				  },
				  "Date": {
				    "StartDate": "2017-08-21",
				    "EndDate": "2017-08-21",
				    "StartTime": "20:00",
				    "EndTime": "22:00",
				    "IsAllDay": "N",
				    "IsRepeat": "N"
				  },
				  "Repeat": {"ResourceRepeat":{}},
				  "Notification": {
				    "IsNotification": "N",
				    "IsReminder": "N",
				    "ReminderTime": "",
				    "IsCommentNotification": "N",
				    "MediumKind": ""
				  },
				  "UserForm":[]
				};
		
		$.ajax({
		    url: "/groupware/resource/saveBookingData.do",
		    type: "POST",
		    data: {
		    	"mode" : "I",
		    	"eventStr" : JSON.stringify(eventObj)
			},
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
			    	$("#saveBookingData_Simple").html(res.result + res.message);
		    	} else {
					Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
				}
		       },
		       error:function(response, status, error){
				CFN_ErrorAjax("saveBookingData.do", response, status, error);
			}
		});
	}
	


	
</script>

<body>
	<input type="button" value="자원(폴더 제외) 목록 조회(getResourceList.do)" onclick="getResourceList()" value="">
	<div id="resourceResult"></div>
	<br>
	<br>
	
	<input type="button" value="좌측트리 조회(getFolderTreeData.do)" onclick="getFolderTreeData()" value="">
	<div id="treeResult"></div>
	<br>
	<br>
	
	<input type="button" value="담당자 정보(getFolderTreeData.do)" onclick="getManageInfo()" value="">
	<div id="manageInfoResult"></div>
	<br>
	<br>

	<input type="button" value="일간 조회(getBookingList.do)" onclick="getDailyList()" value="">
	<div id="dailyResult"></div>
	<br>
	<br>

	<input type="button" value="나의 자원예약(getBookingList.do)" onclick="getMyBook()" value="">
	<div id="myBookResult"></div>
	<br>
	<br>
	
	<input type="button" value="승인/반납요청(getBookingList.do)" onclick="getApprovalRequest()" value="">
	<div id="approvalRequestResult"></div>
	<br>
	<br>
	
	<input type="button" value="상세등록(saveBookingData.do)" onclick="saveBookingData()" value="">
	<div id="saveBookingDataResult"></div>
	<br>
	<br>
	
	<input type="button" value="상세수정(saveBookingData.do) " onclick="saveBookingData_Update()">
	<div id="saveBookingDataResult_Update"></div>
	<br>
	<br>
	
	<input type="button" value="간단등록(saveBookingData.do)" onclick="saveBookingData_Simple()">
	<div id="saveBookingData_Simple"></div>
	<br>
</body>