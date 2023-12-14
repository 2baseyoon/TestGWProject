/**
 * 내 근태현황
 */
var ctnMyAttendance = {
	init: function(data, ext, caller, webPartID) {
		let preId = webPartID!=undefined?"#"+webPartID+" ":"";
		var myAttData = data[0][0].result;
		var myAttStatusData = myAttData.myAttStatusMap;
		ctnMyAttendance.my_attend_content_chart = $(preId + "#my_attend_content .chart");
		ctnMyAttendance.drawChart(myAttStatusData.AttRealTime/60, myAttStatusData.ExtenAc/60, myAttStatusData.HoliAc/60, myAttStatusData.RemainTime/60); // 그래프
	
		if (!coviUtil.isMobile()){
			// PC (정상,연장,휴일,잔여 :분 표시 안함)
			$(preId + "#my_attend_content .today").text(ctnMyAttendance.getToday()); //오늘날짜 (2021.10.05 (월) 형식)
			$(preId + "#my_attend_content .info .total").text(AttendUtils.convertSecToStr(myAttStatusData.TotWorkTime,"H")); 	// TotalNum
			$(preId + "#my_attend_content .info .normal dd").text(AttendUtils.convertSecToStr(myAttStatusData.AttRealTime,"hour")); 	// 정상근무
			$(preId + "#my_attend_content .info .extension dd").text(AttendUtils.convertSecToStr(myAttStatusData.ExtenAc,"hour")); 	// 연장근무
			$(preId + "#my_attend_content .info .holiday dd").text(AttendUtils.convertSecToStr(myAttStatusData.HoliAc,"hour")); 	// 휴일근무
			$(preId + "#my_attend_content .info .surplus dd").text(AttendUtils.convertSecToStr(myAttStatusData.RemainTime,"hour")); 	// 잔여근무

			if($(preId + "#my_attend_content").closest(".portal_widget").attr("class").includes("long") && 
				$(preId + "#my_attend_content").closest(".grid_item").attr("class").includes("x2")){
				// portal_widget 에 long 포함 이면서, grid_item x2 일때 
				// 출근, 퇴근, 소정근로
				$(preId + "#my_attend_content .statistics")
					.append($("<div>",{"class":"other"})
						.append($("<dl>")
							.append($("<dt>",{"text":Common.getDic('lbl_att_goWork')}))
							.append($("<dd>",{"text":myAttData.v_AttStartTime ? myAttData.v_AttStartTime : "<spring:message code='Cache.lbl_Unregistered' />"}))
						)
						.append($("<dl>")
							.append($("<dt>",{"text":Common.getDic('lbl_att_offWork')}))
							.append($("<dd>",{"text":myAttData.v_AttEndTime ? myAttData.v_AttEndTime : "<spring:message code='Cache.lbl_Unregistered' />"}))
						)
						.append($("<dl>")
							.append($("<dt>",{"text":Common.getDic('lbl_att_workingDay')}))
							.append($("<dd>",{"text":myAttStatusData.FixWorkTime? myAttStatusData.FixWorkTime + "h":"0h"}))
						)
					);
				
				// 하단 버튼
				$(preId + "#my_attend_content .statistics")
					.after($("<ul>",{"class":"action"})
						.append($("<li>")
							.append($("<a>", {"href":"#"}).on("click", function(){AttendUtils.openOverTimePopup()})
								.append($("<span>",{"text":Common.getDic('lbl_app_approval_extention')}))//연장근무신청
							)
						)
						.append($("<li>")
							.append($("<a>", {"href":"#"}).on("click", function(){AttendUtils.openHolidayPopup()})
								.append($("<span>",{"text":Common.getDic('lbl_app_approval_holiday')}))//휴일근무신청
							)
						)
						.append($("<li>")
							.append($("<a>", {"href":"#"}).on("click", function(){AttendUtils.openCallPopup()})
								.append($("<span>",{"text":Common.getDic('lbl_app_approval_call')})) //소명신청
								.append($("<em>",{"text":"("+ myAttData.callCnt +")"}))
							)
						)
						.append($("<li>")
							.append($("<a>", {"href":"#"}).on("click", function(){AttendUtils.openSchedulePopup()})
								.append($("<span>",{"text":Common.getDic('lbl_att_changeAttSch')})) //근무제 변경
							)
						)
					);
			}else{
				// portal_widget 에 long 미포함, grid_item x2 아닐 때
				// 하단 버튼
				$(preId + "#my_attend_content .statistics")
					.after($("<ul>",{"class":"action"})
						.append($("<li>")
							.append($("<a>", {"href":"#"}).on("click", function(){AttendUtils.openOverTimePopup()})
								.append($("<span>",{"text":Common.getDic('lbl_app_approval_extention')}))//연장근무신청
							)
						)
						.append($("<li>")
							.append($("<a>", {"href":"#"}).on("click", function(){AttendUtils.openCallPopup()})
								.append($("<span>",{"text":Common.getDic('lbl_app_approval_call')})) //소명신청
								.append($("<em>",{"text":"("+ myAttData.callCnt +")"}))
							)
						)
					);
			}
		} else {
			// Mobile (정상,연장,휴일,잔여 :분 표시 안함)
			$(preId + "#my_attend_content .today").text(ctnMyAttendance.getTodayMobile()); //오늘날짜 (2021.10.05 (월) 형식)
			$(preId + "#my_attend_content .info .total").text(fun_convertSecToStr(myAttStatusData.TotWorkTime,"H")); 	// TotalNum
			$(preId + "#my_attend_content .info .normal dd").text(fun_convertSecToStr(myAttStatusData.AttRealTime,"hour")); 	// 정상근무
			$(preId + "#my_attend_content .info .extension dd").text(fun_convertSecToStr(myAttStatusData.ExtenAc,"hour")); 	// 연장근무
			$(preId + "#my_attend_content .info .holiday dd").text(fun_convertSecToStr(myAttStatusData.HoliAc,"hour")); 	// 휴일근무
			$(preId + "#my_attend_content .info .surplus dd").text(fun_convertSecToStr(myAttStatusData.RemainTime,"hour")); 	// 잔여근무
		}		
	},
	drawChart: function(AttRealTime, ExtenAc, HoliAc, RemainTime){
		// 그래프 그리기
		var totTime = AttRealTime + ExtenAc + HoliAc + RemainTime;
		var AttRealTimePer = AttRealTime/totTime*100;
		var ExtenAcPer = ExtenAc/totTime*100;
		var HoliAcPer = HoliAc/totTime*100;
		var RemainTimePer = RemainTime/totTime*100;
		ctnMyAttendance.my_attend_content_chart.empty();
		if(AttRealTimePer > 50) {
			ctnMyAttendance.my_attend_content_chart
				.append($("<div>",{"class":"normal", "style":"transform:rotate(0deg);"})
					.append($("<span>",{"style":"transform:rotate(0deg);"}))
				)
				.append($("<div>",{"class":"normal", "style":"transform:rotate(180deg);"})
					.append($("<span>",{"style":"transform:rotate("+ (-180 + ( 3.6 * ( AttRealTimePer - 50) ) ) +"deg);"}))
				);
		} else { 
			ctnMyAttendance.my_attend_content_chart
				.append($("<div>",{"class":"normal", "style":"transform:rotate(0deg);"})
					.append($("<span>",{"style":"transform:rotate("+( -180 + ( 3.6 * AttRealTimePer ) )+"deg);"}))
				);
		}

		if(ExtenAcPer > 50) {
			ctnMyAttendance.my_attend_content_chart
				.append($("<div>",{"class":"extension", "style":"transform:rotate("+( 18 * AttRealTimePer / 5 )+"deg);"})
					.append($("<span>",{"style":"transform:rotate(0deg);"}))
				)
				.append($("<div>",{"class":"extension", "style":"transform:rotate("+( 18 * (AttRealTimePer + 50) / 5 )+"deg);"})
					.append($("<span>",{"style":"transform:rotate("+( -180 + ( 3.6 * ( ExtenAcPer - 50) ) )+"deg);"}))
				);
		} else { 
			ctnMyAttendance.my_attend_content_chart
				.append($("<div>",{"class":"extension", "style":"transform:rotate("+( 18 * AttRealTimePer / 5 )+"deg);"})
					.append($("<span>",{"style":"transform:rotate("+( -180 + ( 3.6 * ExtenAcPer ) )+"deg);"}))
				);
		}

		if(HoliAcPer > 50) {
			ctnMyAttendance.my_attend_content_chart
				.append($("<div>",{"class":"holiday", "style":"transform:rotate("+( 18 * (AttRealTimePer + ExtenAcPer) / 5 )+"deg);"})
					.append($("<span>",{"style":"transform:rotate(0deg);"}))
				)
				.append($("<div>",{"class":"holiday", "style":"transform:rotate("+( 18 * (AttRealTimePer + ExtenAcPer + 50) / 5 )+"deg);"})
					.append($("<span>",{"style":"transform:rotate("+( -180 + ( 3.6 * ( HoliAcPer - 50) ) )+"deg);"}))
				);
		} else { 
			ctnMyAttendance.my_attend_content_chart
				.append($("<div>",{"class":"holiday", "style":"transform:rotate("+( 18 * (AttRealTimePer + ExtenAcPer) / 5 )+"deg);"})
					.append($("<span>",{"style":"transform:rotate("+( -180 + ( 3.6 * HoliAcPer ) )+"deg);"}))
				);
		}

		if(RemainTimePer > 50) {
			ctnMyAttendance.my_attend_content_chart
				.append($("<div>",{"class":"surplus", "style":"transform:rotate("+( 18 * (AttRealTimePer + ExtenAcPer + HoliAcPer) / 5 )+"deg);"})
					.append($("<span>",{"style":"transform:rotate(0deg);"}))
				)
				.append($("<div>",{"class":"surplus", "style":"transform:rotate("+( 18 * (AttRealTimePer + ExtenAcPer + HoliAcPer + 50) / 5 )+"deg);"})
					.append($("<span>",{"style":"transform:rotate("+( -180 + ( 3.6 * ( RemainTimePer - 50) ) )+"deg);"}))
				);
		} else { 
			ctnMyAttendance.my_attend_content_chart
				.append($("<div>",{"class":"surplus", "style":"transform:rotate("+( 18 * (AttRealTimePer + ExtenAcPer + HoliAcPer) / 5 )+"deg);"})
					.append($("<span>",{"style":"transform:rotate("+( -180 + ( 3.6 * RemainTimePer ) )+"deg);"}))
				);
		}
	},
	getToday : function(){
		// 2021.10.05 (월) 형식 - PC용 함수 사용
		var extDate = new Date(CFN_GetLocalCurrentDate());
		var extDateStr = schedule_SetDateFormat(extDate, "."); //날짜포맷변환
		var extDayArr = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"];
		var extDayStr = Common.getDic("lbl_sch_" + extDayArr[extDate.getDay()]);
		var dateTxt = extDateStr + "(" + extDayStr + ")";
		return dateTxt;
	},
	getTodayMobile : function(){
		// 2021.10.05 (월) 형식 - 모바일용 함수 사용
		var extDate = new Date(CFN_GetLocalCurrentDate());
		var extDateStr = mobile_schedule_SetDateFormat(extDate, "."); //날짜포맷변환
		var extDayArr = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"];
		var extDayStr = Common.getDic("lbl_sch_" + extDayArr[extDate.getDay()]);
		var dateTxt = extDateStr + "(" + extDayStr + ")";
		return dateTxt;
	}
}