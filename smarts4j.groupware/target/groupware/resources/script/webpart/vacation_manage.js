/**
 * 휴가관리
 */
var vacationManage = {
	init: function(data, ext, caller, webPartID) {
		let preId = webPartID!=undefined?"#"+webPartID+" ":"";
		
		var vacDay = data[0].length != 0 ? Number(data[0][0].VacDay) : 0;
		var vacDayUse = data[0].length != 0 ? Number(data[0][0].VacDayUse) : 0;
		var remainVacDay = data[0].length != 0 ? Number(data[0][0].RemainVacDay) : 0;
		
		if (caller == "Widget"){
			$(preId + "#wdg_vacation_info .title em").text(vacDay); 	// 총 휴가일
			$(preId + "#wdg_vacation_info .use dd").text(vacDayUse); 			// 사용
			$(preId + "#wdg_vacation_info .remaining dd").text(remainVacDay);	// 잔여
		}else{
			if (coviUtil.isMobile()){
				$(preId + "#ctn_vacation_info .holidays").addClass("vertical");
				$(preId + "#ctn_vacation_info .title").empty();
				$(preId + "#ctn_vacation_info .title")
							.append($("<span>", {"text" : mobile_comm_getDic('lbl_TotalHolidayDay') + ":"}))
							.append($("<em>", {"text" : vacDay})); 			// 총 휴가일
				// 휴가신청버튼
				if(mobile_comm_getBaseConfig("useMobileApprovalWrite") == "Y"){
					$(preId + "#ctn_vacation_info").append($("<div>",{"class":"widget_link"})
						.append($("<a>",{"href":"#"})
							.append($("<span>",{"text":"<spring:message code='Cache.btn_apv_vacation_req'/>"}))
						)
					);
					// 휴가신청버튼 클릭시
					$(preId + ".widget_link").on("click",function(){
						mobile_approval_clickwrite("WF_FORM_VACATION_REQUEST2");
					});
				}
				
			}else{
				$(preId + "#ctn_vacation_info .title").text(Common.getDic('lbl_TotalHolidayDay') + ": " + vacDay); 	// 총 휴가일
				// 휴가신청버튼
				$(preId + "#ctn_vacation_info").append($("<div>",{"class":"widget_link"})
						.append($("<a>",{"href":"#"})
							.append($("<span>",{"text":"<spring:message code='Cache.btn_apv_vacation_req'/>"}))
						)
				);
				$(preId + " .use").wrap("<a href='/groupware/layout/vacation_VacationApply.do?CLSYS=vacation&CLMD=user&CLBIZ=vacation&reqType=myVacation'>");
				$(preId + " .remaining").wrap("<a href='/groupware/layout/vacation_VacationApply.do?CLSYS=vacation&CLMD=user&CLBIZ=vacation&reqType=myVacation'>");
				// 휴가신청버튼 클릭시
				$(preId + ".widget_link").on("click",function(){
					AttendUtils.openVacationPopup('USER');
				});
			}
			$(preId + "#ctn_vacation_info .use dd").text(vacDayUse); 			// 사용
			$(preId + "#ctn_vacation_info .remaining dd").text(remainVacDay);	// 잔여
		}
	}
}