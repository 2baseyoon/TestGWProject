/**
 * pnAttendance - [포탈개선] My Place - 내 근태현황
 */
var pnAttendance = {
	webpartType: "",
	nowDate: new Date(CFN_GetLocalCurrentDate("yyyy/MM/dd")),
	targetDate: "",
	init: function (data, ext){
		var nowDateStr = schedule_SetDateFormat(pnAttendance.nowDate, ".");
		var nowDay = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"];
		var nowDayStr = Common.getDic("lbl_sch_" + nowDay[pnAttendance.nowDate.getDay()]);
		pnAttendance.targetDate = schedule_SetDateFormat(pnAttendance.nowDate, "-");
		
		$(".PN_attendDg .aDate").text(nowDateStr + " (" + nowDayStr + ")");
		pnAttendance.setEvent();
		pnAttendance.getMyAttStatus(nowDateStr);
		pnAttendance.getUserAttList(pnAttendance.targetDate);
		pnAttendance.getCallCnt();
		pnAttendance.getScheduleList();
		pnAttendance.getUserRewardVacDay(nowDateStr.substr(0, 4));
	},
	setEvent: function(){
		$(".PN_attendance").closest(".PN_myContents_box").find(".PN_portlet_btn").off("click").on("click", function(){
			if(!$(this).hasClass("active")){
				$(this).addClass("active");
				$(this).next(".PN_portlet_menu").stop().slideDown(300);
				$(this).children(".PN_portlet_btn > span").addClass("on");
			}else{
				$(this).removeClass("active");
				$(this).next(".PN_portlet_menu").stop().slideUp(300);
				$(this).children(".PN_portlet_btn > span").addClass("on");
			}
		});

		$(".PN_attendance").closest(".PN_myContents_box").find(".PN_portlet_close").click(function(){
			$(this).parents(".PN_portlet_function").find(".PN_portlet_btn").removeClass("active");
			$(this).parents(".PN_portlet_menu").stop().slideUp(300);
			$(this).parents(".PN_portlet_function").find(".PN_portlet_btn > span").removeClass("on")
		});
		
		$(".PN_attendBtn li[mode=exten]").off("click").on("click", AttendUtils.openOverTimePopup);
		$(".PN_attendBtn li[mode=holi]").off("click").on("click", AttendUtils.openHolidayPopup);
		$(".PN_attendBtn li[mode=call]").off("click").on("click", pnAttendance.openCallPopup);
		
		$(".PN_myContents_sizeW .PN_attendance").closest("div[name=mycontents_webpart]").css("width", "100%");
	},
	getMyAttStatus: function(pTargetDate){
		$.ajax({
			url: "/groupware/attendPortal/getMyAttStatus.do",
			type: "POST",
			data: {
				dateTerm: "W",
				targetDate: pTargetDate
			},
			success: function(data){
				if(data.status == "SUCCESS"){
					var myChart;
					var dataMap = data.userAttWorkTime;
					var chartColor = ["rgb(0,149,235)", "rgb(0,203,235)", "rgb(255,204,62)", "rgb(188,219,255)"];
					
					$(".TotalNum").text(AttendUtils.convertSecToStr(dataMap["TotWorkTime"], "H"));
					$("#PN_workTime .num").text(AttendUtils.convertSecToStr(dataMap["AttRealTime"], "H"));
					$("#PN_exTime .num").text(AttendUtils.convertSecToStr(dataMap["ExtenAc"], "H"));
					$("#PN_holiTime .num").text(AttendUtils.convertSecToStr(dataMap["HoliAc"], "H"));
					$("#PN_remainTime .num").text(AttendUtils.convertSecToStr(dataMap["RemainTime"], "H"));
					
					var chartData = {datasets : [{data: [], borderWidth: 0, backgroundColor: chartColor}]};
					var attendObj = {data: chartData, type: "doughnut", options: {legend: {display: false}}};
					
					if(dataMap["AttRealTime"] || dataMap["ExtenAc"] || dataMap["HoliAc"] || dataMap["RemainTime"]){
						attendObj.data.labels = ["<spring:message code='Cache.lbl_n_att_normalWork'/>", "<spring:message code='Cache.lbl_att_overtime_work'/>", "<spring:message code='Cache.lbl_att_holiday_work'/>", "<spring:message code='Cache.lbl_n_att_remainWork'/>"]; // 정상근무, 연장근무, 휴일근무, 잔여근무
						attendObj.data.datasets[0].data = [dataMap["AttRealTime"]/60, dataMap["ExtenAc"]/60, dataMap["HoliAc"]/60, dataMap["RemainTime"]/60];
					}else{
						chartData.datasets[0].backgroundColor = ["rgb(221, 221, 221)"];
						attendObj.data = chartData;
						attendObj.data.labels = ["<spring:message code='Cache.lbl_att_workTime'/>"]; // 근무시간
						attendObj.data.datasets[0].data = [100];
					}
					
					myChart = new Chart($("#attendGraph"), attendObj); 
				}else{
					Common.Warning("<spring:message code='Cache.msg_sns_03'/>");
				}
			},
			error: function(request,status,error){
				Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
			}
		});
	},
	openCallPopup: function(){
		if (Common.getBaseConfig("CommuModReqMethod") == "Approval"){
			openForm('WF_FORM_CALL','','');
		}else{
			Common.open("", "AttendReqCallPopup", "<spring:message code='Cache.lbl_app_approval_call' />", "/groupware/attendReq/AttendReqCallPopup.do", "720px", "815px", "iframe", true, null, null, true); // 소명신청
		}
	},
	getCallCnt: function(){
		$.ajax({
			url: "/groupware/attendPortal/getCallingTarget.do",
			type: "POST",
			data: {
				  "StartDate": ""
				, "EndDate": ""
				, "DeptUpCode": ""
				, "CommStatus": ""
				, "UserCode": Common.getSession("USERID")
				, "authMode": "A"
			},
			success: function(data){
				var callCnt = data.list.length;
				
				$(".PN_attendBtn li[mode=call] .atNum").text("(" + callCnt + ")");
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/attendPortal/getCallingTarget.do", response, status, error);
	   		}
	 	});
	},
	getUserAttList: function(pTargetDate){
		$.ajax({
			url: "/groupware/attendUserSts/getMyAttStatus.do",
			type: "POST",
			data: {
				dateTerm: "W",
				targetDate: pTargetDate
			},
			success: function(data){
				var userAttList = data.attMap.userAtt[0].userAttList.filter(function(value){
					return value.dayList == pTargetDate;
				});
				var attSTime = userAttList[0].v_AttStartTime ? userAttList[0].v_AttStartTime : "<spring:message code='Cache.lbl_Unregistered' />"; // 미등록
				var attETime = userAttList[0].v_AttEndTime ? userAttList[0].v_AttEndTime : "<spring:message code='Cache.lbl_Unregistered' />"; // 미등록
				
				$(".PN_attend_r li[mode=attSTime] .aTxt").text(attSTime);
				$(".PN_attend_r li[mode=attETime] .aTxt").text(attETime);
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/attendUserSts/getMyAttStatus.do", response, status, error);
			}
		});
	},
	getUserRewardVacDay: function(pYear){
		$.ajax({
			url: "/groupware/pnPortal/selectUserRewardVacDay.do",
			type: "POST",
			data: {
				userCode: sessionObj["USERID"],
				year: pYear
			},
			success: function(data){
				var rVacDay = data.rewardVacDay;
				$(".PN_attend_r li[mode=reward] .aTxt").text(rVacDay + "<spring:message code='Cache.lbl_day' />"); // 일
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/pnPortal/selectUserRewardVacDay.do", response, status, error);
			}
		});
	},
	getScheduleList: function(){
		$.ajax({
			type: "POST",
			url: "/groupware/attendReq/getScheduleList.do",
			data: {
				"SchName": ""
			},
			success: function(data){
				if(data.status == "SUCCESS"){
					var optionHtml = "<option value='A'><spring:message code='Cache.lbl_att_changeAttSch' /></option>"; // 근무제 변경
					
					$.each(data.list, function(idx, item){
						var optionWrap = $("<option></option>").text(item.SchName).attr("value", item.SchSeq);
						optionHtml += $(optionWrap)[0].outerHTML;
					});
					
					$(".PN_attendBtn li[mode=workType] .selectType02").html(optionHtml);
					
					pnAttendance.getUserAttSch(pnAttendance.targetDate);
					
					$(".PN_attendBtn li[mode=workType] .selectType02").off("change").on("change", function(){
						if($(this).val() != "A") AttendUtils.openSchedulePopup();
					});
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/groupware/attendReq/getScheduleList.d", response, status, error);
			}
		});
	},
	getUserAttSch: function(pTargetDate){
		$.ajax({
			type: "POST",
			url: "/groupware/attendCommon/getAttendJobCalendar.do",
			data: {
				"StartDate": pTargetDate,
				"mode": ""
			},
			success: function(data){
				if(data.status == "SUCCESS"){
					var jobList = data.jobList.filter(function(d){
						return d.JobDate == pTargetDate;
					}, []);
					var selVal = jobList[0] ? jobList[0].SchSeq : "A";
					
					$(".PN_attendBtn li[mode=workType] .selectType02").val(selVal);
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/groupware/attendReq/getScheduleList.d", response, status, error);
			}
		});
	}
}