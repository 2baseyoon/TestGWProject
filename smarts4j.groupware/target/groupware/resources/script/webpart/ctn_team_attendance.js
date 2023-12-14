/**
 * MyContents : 팀원 근태현황
 */
var ctnTeamAttendance = {
	init: function (data, ext, caller, webPartID){
		ctnTeamAttendance.caller = caller;
		ctnTeamAttendance.webPartID = webPartID;
		ctnTeamAttendance.preId = webPartID!=undefined?"#"+webPartID+" ":"";
		
		// 부서 셀렉트박스
		AttendUtils.getDeptListJobType($(ctnTeamAttendance.preId + "#selDeptCode"), "", false, false); 
		
		// 본부장만 부서 셀렉트박스 표시
		if(AttendUtils.chkJobType() == "DEVISION") {
			$(ctnTeamAttendance.preId + "#selDeptCode").show();
		}else{
			$(ctnTeamAttendance.preId + "#selDeptCode").hide();
		}
		// 리스트 표시
		ctnTeamAttendance.getDeptAttStatusWebpart($(ctnTeamAttendance.preId + "#selDeptCode").val()); 
		
		//부서 셀렉트박스 변경시 리스트 표시
		$(ctnTeamAttendance.preId + "#selDeptCode").on("change", function(){
			ctnTeamAttendance.getDeptAttStatusWebpart($(ctnTeamAttendance.preId + "#selDeptCode").val());
		});
	},
	getDeptAttStatusWebpart: function(deptCode){ //리스트표시
		// 컨텐츠영역
		$.ajax({
			type: "POST",
			url: "/groupware/attendPortal/getDeptAttStatusWebpart.do",
			data: {"DeptCode": deptCode},
			success: function (data) {
				if(data.status == "SUCCESS"){
					var list = data.data;
					if (list.length > 0) {
						$(ctnTeamAttendance.preId + ".widget_content").remove();
						$(ctnTeamAttendance.preId + ".widget_empty").remove();
						
						var teamList = $(ctnTeamAttendance.preId + ".widget_card");
						teamList.append($("<div>",{"class":"widget_content"})
							.append($("<div>",{"data-custom-scrollbar":""})
								.append($("<div>",{"class":"content_list"}))
							)
						);
						$.each(list, function(i, item) {
							// list
							teamList.find(".content_list")
								.append($("<div>", {"class" : "user_item"})
									.append($("<div>", {"class" : "info"})
										.append($("<strong>", {"text": ctnTeamAttendance.displayMemberName(item.DisplayName, item.JobLevelName, item.JobPositionName, item.JobTitleName)}))
										.append($("<time>", {"text": ctnTeamAttendance.getDay(item.dayList)}))
									)
									.append(ctnTeamAttendance.getMemberStatus(item))
								);
						});
					} else {
						// 조회할 목록이 없습니다.
						coviUtil.webpartDrawEmpty(list, ctnTeamAttendance.caller, ctnTeamAttendance.webPartID, Common.getDic('msg_NoDataList'));
					}
				}
			}
		});
		
	},
	displayMemberName: function(displayName, jobLevelName, jobPositionName, jobTitleName){ // 이름과 설정에 맞는 직위,직책,직급 표시
		var sRepJobTypeConfig = Common.getBaseConfig("RepJobType");
		var sRepJobType = jobLevelName;
		if(sRepJobTypeConfig == "PN"){
		  	sRepJobType = jobPositionName;
		} else if(sRepJobTypeConfig == "TN"){
		    sRepJobType = jobTitleName;
		} else if(sRepJobTypeConfig == "LN"){
		    sRepJobType = jobLevelName;
		}
		if(sRepJobType == null) { sRepJobType = "" }
		var memberName = displayName+" "+sRepJobType;
		return memberName;
	},
	getDay : function(dayList){ // 2022.07.25 형식
		var extModDate = new Date(dayList);
		var extDateStr = schedule_SetDateFormat(extModDate, "."); //날짜포맷변환
		return extDateStr;
	},
	getMemberStatus:function(data){ // 근태상태 표시
		var emClass = "";
		var emText = "";

		// 출근 시간 : 소명대상(orange), 지각(pink), 근무(green), 결근(red)
		if( data.StartSts != null ) {
			if ( data.StartSts == "lbl_n_att_callingTarget" ) {
				emClass = "orange";
				emText = "<spring:message code='Cache.lbl_n_att_callingTarget' />"; // 소명대상
			} else {
				if( data.v_AttStartTime != null ) {
					if ( data.StartSts == "lbl_att_beingLate" ) {
						emClass ="pink";
						emText =  "<spring:message code='Cache.lbl_att_beingLate' />"; // 지각
					} else {
						emClass ="green";
						emText = "<spring:message code='Cache.lbl_att_work' />"; // 근무
					}
				} else {
					if ( data.StartSts == "lbl_n_att_absent" ) {
						emClass = "red";
						emText = "<spring:message code='Cache.lbl_n_att_absent' />"; // 결근
					} 
				}
			}
		}
		
		// 퇴근 시간 : 소명대상(orange), 조퇴(pink), 퇴근(blue), 결근(red)
		if ( data.EndSts != null ){
			if ( data.EndSts == "lbl_n_att_callingTarget" ){
				emClass = "orange";
				emText = "<spring:message code='Cache.lbl_n_att_callingTarget' />"; // 소명대상
			} else {
				if ( data.v_AttEndTime != null ){
					if ( data.EndSts == "lbl_att_leaveErly" ){
						emClass = "pink";
						emText = "<spring:message code='Cache.lbl_att_leaveErly' />"; // 조퇴
					} else {
						emClass = "blue";
						emText = "<spring:message code='Cache.lbl_att_offWork' />"; // 퇴근
					}
				} else {
					if ( data.EndSts == "lbl_n_att_absent" ){
						emClass = "red";
						emText = "<spring:message code='Cache.lbl_n_att_absent' />"; // 결근
					}
				}
			}
		}
		
		if( data.StartSts == null  && data.EndSts == null ) {
			emClass = "red";
			emText = "<spring:message code='Cache.lbl_n_att_absent' />"; // 결근
		}	
		// 근무상태 (기타근무 : 외근, 출장, 교육 등...)
		if ( data.jh_JobStsName != null && data.jh_JobStsName != "" ){
			emClass = "purple";
			emText = data.jh_JobStsName;
		}
		//연장근무
		if( data.ExtenAc!=null && data.ExtenAc!="" ){
			emClass = "cyan";
			emText = "<spring:message code='Cache.lbl_over' />"; // 연장
		}
		
		//휴무(휴일근무, 휴일)
		if( data.WorkSts == "OFF" || data.WorkSts == "HOL" ){
			if(Number(data.HoliCnt) > 0){
				emClass = "white";
				emText = "<spring:message code='Cache.lbl_att_holiday_work' />"; // 휴일근무
			} else {
				emClass = "light";
				emText = "<spring:message code='Cache.lbl_att_sch_holiday' />"; // 휴일
			}
		}
		// 휴가 (휴가(gray),지각(pink),소명대상(orange),결근(red),조퇴(pink))
		if ( data.VacFlag != null && data.VacFlag != "" ){
			if ( data.VacCnt == 1 ){
				emClass = "gray";
				emText = data.VacName;
			} else {
				var vacAmPmVacDay = data.VacAmPmVacDay;
				var arrVacAmPmVacDay = null;
				if ( vacAmPmVacDay.indexOf("|")>-1 ){
					arrVacAmPmVacDay = vacAmPmVacDay.split('|');
				}
				if ( data.VacOffFlag.indexOf("AM") > -1 && Number(arrVacAmPmVacDay[0]) >= 0.5 ){
					if ( data.StartSts=="lbl_att_beingLate" ){
						emClass = "pink";
						emText = "<spring:message code='Cache.lbl_att_beingLate' />"; // 지각
					} else if ( data.StartSts=="lbl_n_att_callingTarget" ) {
						emClass = "orange";
						emText = "<spring:message code='Cache.lbl_n_att_callingTarget' />"; // 소명대상
					} else if ( data.StartSts=="lbl_n_att_absent" ){
						emClass = "red";
						emText = "<spring:message code='Cache.lbl_n_att_absent' />"; // 결근
					} else {
						emClass = "gray";
						emText = data.VacName+"(AM)";
					}
				}
				if ( data.VacOffFlag.indexOf("PM") > -1 && Number(arrVacAmPmVacDay[1]) >= 0.5){
					if ( data.EndSts==="lbl_att_leaveErly" ) {
						emClass = "pink";
						emText = "<spring:message code='Cache.lbl_att_leaveErly' />"; // 조퇴
					}else if(data.EndSts==="lbl_n_att_callingTarget") {
						emClass = "orange";
						emText = "<spring:message code='Cache.lbl_n_att_callingTarget' />"; // 소명대상
					}else{
						if(data.VacOffFlag.indexOf("AM")>-1){
							emClass = "gray";
							emText = data.VacName;
						}else{
							emClass = "gray";
							emText = data.VacName+"(PM)";
						}
					}
				}
			}
		}
		var rtnTags = "";
		if( emClass != "" && emText != "" ){
			rtnTags = $("<em>", {"class" : "status" , "data-status-color" : emClass , "text": emText});
		}

		return rtnTags;		
	}
}