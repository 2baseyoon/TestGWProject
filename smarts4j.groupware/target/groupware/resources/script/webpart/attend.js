/**
 * attendStatus - 근태 웹파트
 */
var attendStatus = {
	config: {
		nowDate: new Date(CFN_GetLocalCurrentDate("yyyy/MM/dd"))
	},
	data: [],
	init: function (data, ext, caller, webPartID){
		attendStatus.caller = caller;
		attendStatus.preId = webPartID!=undefined?"#"+webPartID+" ":"";

		var _ext = (typeof ext == 'object') ? ext : {};
		attendStatus.config = $.extend(attendStatus.config, _ext);
		
		var nowDateStr = schedule_SetDateFormat(attendStatus.config.nowDate, '.');
		nowDateStr = schedule_SetDateFormat(attendStatus.config.nowDate, '.').substr(5, nowDateStr.length);
		var nowDay = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"];
		var nowDayStr = Common.getDic("lbl_sch_" + nowDay[attendStatus.config.nowDate.getDay()]);
		var titleStr = nowDateStr + " (" + nowDayStr + ") <spring:message code='Cache.lbl_AttStatus'/>"; // 출근현황
		
		AttendUtils.getDeptListJobType($(attendStatus.preId + "#selGroupPath"), "", false, true) // (본부장:본인포함 하위부서, 그 외:본인 부서만)
		
		attendStatus.getAttendCount($(attendStatus.preId + "#selGroupPath").val());
		$(attendStatus.preId + "#selGroupPath").on("change", function(){
			attendStatus.getAttendCount($(attendStatus.preId + "#selGroupPath").val());
		});
		if (attendStatus.caller != "Contents"){
			$(".PN_TitleBox .ic_time").text(titleStr);
		} else {
			$(attendStatus.preId + ".widget_head .title").empty().text(titleStr);
			$(attendStatus.preId + ".normal").attr("href",attendStatus.config.moreUrl); // 출근
			$(attendStatus.preId + ".late").attr("href",attendStatus.config.moreUrl); // 지각
			$(attendStatus.preId + ".holidays").attr("href","/groupware/layout/vacation_Home.do?CLSYS=vacation&CLMD=user&CLBIZ=vacation"); // 휴가
			$(attendStatus.preId + ".reason").attr("href",attendStatus.config.moreUrl); // 소명	
		}
	},
	getAttendCount: function(groupPath){
		var nowDateStr = schedule_SetDateFormat(attendStatus.config.nowDate, '.');
		var paramMap = {
			  startDate: nowDateStr
			, endDate: nowDateStr
			, targetDate: nowDateStr
			, pageType: "D"
		};
		
		var params = {
			  companyMap : paramMap
			, userMap : paramMap
			, deptMap : paramMap
			, queryType: "A"
			, deptUpCode: groupPath
			, deptUpCodeWork: groupPath
			, searchText: ""
			, schSeq: ""
			, pageNo: 1
			, pageSize: "10"
		};
		
		$.ajax({
			url: "/groupware/attendPortal/getMangerAttStatus.do",
			type: "POST",
			data: JSON.stringify(params),
			dataType: "json",
			contentType: "application/json; charset=utf-8",
			success: function (data) {
				if(data.status == "SUCCESS"){
					if(data.companyToday){
						if(attendStatus.caller != "Contents"){
							if(data.companyToday.WorkCnt != null) $(".ic_attend .PN_count").text(data.companyToday.WorkCnt); // 출근
							if(data.companyToday.LateCnt != null) $(".ic_late .PN_count").text(data.companyToday.LateCnt); // 지각
							if(data.companyToday.VacCnt != null) $(".ic_vacation .PN_count").text(data.companyToday.VacCnt); // 휴가
							if(data.companyToday.AbsentCnt != null) $(".ic_calling .PN_count").text(data.companyToday.AbsentCnt); // 소명
						} else {
							if(data.companyToday.WorkCnt != null) $(attendStatus.preId + ".normal em").text(data.companyToday.WorkCnt); // 출근
							if(data.companyToday.LateCnt != null) $(attendStatus.preId + ".late em").text(data.companyToday.LateCnt); // 지각
							if(data.companyToday.VacCnt != null) $(attendStatus.preId + ".holidays em").text(data.companyToday.VacCnt); // 휴가
							if(data.companyToday.AbsentCnt != null) $(attendStatus.preId + ".reason em").text(data.companyToday.AbsentCnt); // 소명		
						}
					}
				}else{
					Common.Warning("<spring:message code='Cache.msg_ErrorOccurred'/>");
				}
			},
			error: function(request, status, error){
				Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
			}
		})
	}
}
