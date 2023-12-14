var meetingRoom = {
	hasBetweenResevation: false, // 체크된 시간 사이에 예약된 데이터 존재 여부
	// 초기 실행 함수
	init: function(data, ext, caller, webpartID) {
		$("#meetingDate").addClass("input_date").datepicker({
			dateFormat: "yy-mm-dd",
			buttonImageOnly: false,
			dayNamesMin: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
		});
		
		$.each(data[0], function(i, item) {
			$("#meetingRoomName")
			.append($("<option>", {"value" : item.FOLDERID, "text" : item.DISPLAYNAME}))
		});
		
		var today = new Date();

		var year = today.getFullYear();
		var month = ('0' + (today.getMonth() + 1)).slice(-2);
		var day = ('0' + today.getDate()).slice(-2);
		
		var dateString = year + '-' + month  + '-' + day;
		
		$("#meetingDate").val(dateString);
		
		meetingRoom.setSeletedTime();
		meetingRoom.addEvent();
	},
	// 선택한 회의실에 예약 현황 조회
	meetingReservation: function(folderId, viewDate) {
		var folderId = $("#meetingRoomName option:selected").val();
		var viewDate = $("#meetingDate").val();
		
		$.ajax({
			url: "/groupware/resource/webpartSelectMeeting.do",
			type: "POST",
			data: {"folderId" : folderId,
				   "viewDate" : viewDate},
			success: function(result) {
				$.each(result.list, function(i, item) {
					var startTime = parseInt(item.StartTime.replace(':', ''));
					var endTime = parseInt(item.EndTime.replace(':', ''));
					var flag = true;
					
					if(startTime % 100 > 0 && startTime % 100 < 30) {
						startTime = parseInt(startTime / 100) * 100;
					} else if(startTime % 100 != 0 && startTime % 100 != 30) {
						startTime = parseInt(startTime / 100) * 100 + 30;
					} else {
						flag = false;
					}
					
					if(endTime % 100 > 0 && endTime % 100 < 30) {
						endTime = parseInt(endTime / 100) * 100;
					} else if(endTime % 100 != 0 && endTime % 100 != 30) {
						endTime = parseInt(endTime / 100) * 100 + 30;
					} else {
						flag = false;
					}
					
					$.each($("#selectedRoom_timeView dl dd label input"), function(idx, item) {
						if($(this).val() >= startTime && $(this).val() <= endTime) {
							if($(this).val() == endTime && flag == false) {
								return;	
							}
							
							$(this).prop("disabled", true);
							$(this).prop("checked", false);
							$(this).closest("label").css("background-color", "#999");
						}
					});
				});
			}
		});
	},
	// 시간 셀렉트 박스에 옵션 값 설정 및 초기 예약 현황 그려주는 함수
	setSeletedTime: function() {
		for(var i = 9; i < 18; i++) {
			meetingRoom.drawSelectTime(i, i + 1);
		}
		
		$("#meetingStartTime option:first").prop("selected", true);
		$("#meetingEndTime option:last").prop("selected", true);
		
		
		var startTime = parseInt($("#meetingStartTime option:selected").val());
		var endTime = parseInt($("#meetingEndTime option:selected").val());
		
		meetingRoom.drawMeetingTimeView(startTime, endTime);
	},
	// 시간 셀렉트 박스에 옵션 값 세팅 함수
	drawSelectTime: function(time1, time2) {
		var startTime = time1.toString().padStart(2, '0') + ":00";
		var endTime = time2.toString().padStart(2, '0') + ":00";
		
		var start = parseInt($("#meetingStartTime option:selected").val());
		var end = parseInt($("#meetingEndTime option:selected").val());
		
		$("#meetingStartTime").append($("<option>", {"value" : time1, "text" : startTime}));
		$("#meetingEndTime").append($("<option>", {"value" : time2, "text" : endTime}));
	},
	// 예약 현황 테이블 그려주는 함수
	drawMeetingTimeView: function(start, end) {
		for(var i=start; i<end; i++) {
			var hour = i.toString().padStart(2, '0');
			
			$("#selectedRoom_timeView")
			.append($("<dl>")
				.append($("<dt>", {"text" : hour}))
				.append($("<dd>")
					.append($("<label>")
						.append($("<input>", {"type" : "checkbox", "name" : "meeting", "value" : hour + "00"}))
						.append($("<i>"))
					)
					.append($("<label>")
						.append($("<input>", {"type" : "checkbox", "name" : "meeting", "value" : hour + "30"}))
						.append($("<i>"))
					)
				)
			);
		}

		meetingRoom.meetingReservation();
		meetingRoom.checkedTime();
	},
	// 이벤트
	addEvent: function() {
		// 회의실 또는 날짜 변경 시, 재 조회 이벤트
		$("#meetingRoomName, #meetingDate").change('on', function() {
			$("#selectedRoom_timeView dl dd label input[type=checkbox]").prop("checked", false);
			$("#selectedRoom_timeView dl dd label input[type=checkbox]").prop("disabled", false);
			$("#selectedRoom_timeView dl dd label").css("background-color", "");
			
			meetingRoom.meetingReservation();
		});
		
		// 셀렉트 박스(시작, 종료) 변경 시, 선택한 회의실에 예약현황을 다시 그려주는 이벤트
		$("#meetingStartTime, #meetingEndTime").change("on", function() {
			$("#selectedRoom_timeView").empty();
			var start = parseInt($("#meetingStartTime option:selected").val());
			var end = parseInt($("#meetingEndTime option:selected").val());
			
			if(start >= end) return;
			
			meetingRoom.drawMeetingTimeView(start, end);
		});
		
		// 회의실 예약
		$("#meetingDate").closest(".widget_card").find(".widget_link a").on("click", function() {
			meetingRoom.reserve();
		});
	},
	// 예약할 시간에 체크 시, 체크 표시 이벤트
	checkedTime: function() {
		$("#selectedRoom_timeView dl dd label input[type=checkbox]").click("on", function() {
			meetingRoom.hasBetweenReservation = false;
			
			var checkedList = $("#selectedRoom_timeView dl dd label input:checked");
			var sTime = $(checkedList[0]).val();
			var eTime = $(checkedList[checkedList.length - 1]).val();
			var clickTime = $(this).val();
			
			if(checkedList.length > 1) {
				$.each($("#selectedRoom_timeView dl dd label input"), function(i, item){
					var checkTime = $(item).val();
					
					if(checkTime > sTime && checkTime < eTime) {
						if(!$(item).prop("disabled")) $(item).prop("checked", true);
						else meetingRoom.hasBetweenReservation = true;
					}
					
					if (clickTime > sTime && clickTime < eTime) {
						if(clickTime < checkTime) {
							 $(item).prop("checked", false);
						}
					}
				});
			}
		});
	},
	// 예약 확인 버튼 이벤트
	reserve: function() {
		var checkedList = $("#selectedRoom_timeView dl dd label input:checked");
		
		if(checkedList.length < 1) {
			Common.Warning(Common.getDic("msg_selectReserveTime")); // 예약할 시간을 선택해 주세요.
		} else {
			if(meetingRoom.hasBetweenReservation) {
				Common.Warning(Common.getDic("msg_ReservationWrite_06")); // 자원을 예약할 수 없습니다. 동일한 예약기간에 이미 사용되고 있습니다.
			} else {
				meetingRoom.openSubjectPopup(checkedList);
			}
		}
	},
	// 용도 입력하는 팝업창
	openSubjectPopup: function(checkedList){
		var url = "/groupware/resource/goSubjectPopup.do?callBackFunc=meetingRoom.meetingReservation";
		var roomID = $("#meetingRoomName option:selected").val();
		var meetingDate = $("#meetingDate").val();
		var sTime = $(checkedList[0]).val();
		var eTime = $(checkedList[checkedList.length-1]).val();
		
		var ehour = eTime.slice(0, 2);
		var eMin = eTime.slice(2, 4);
		
		if(eMin == '30') {
			eTime = (parseInt(ehour) + 1).toString().padStart(2, '0') + ":00";
		} else {
			eTime = eTime.slice(0, 2) + ":30";
		}
		
		sTime = sTime.slice(0, 2) + ":" + sTime.slice(2, 4);
		
		url += "&resourceID=" + roomID
			+  "&resDate=" + meetingDate
			+  "&sTime=" + sTime
			+  "&eTime=" + eTime
		
		Common.open("", "ResourceBooking", "<spring:message code='Cache.lbl_Booking' />", url, "400px", "300px", "iframe", true, null, null, true); // 자원예약
	}
}