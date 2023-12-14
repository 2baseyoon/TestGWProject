/**
 * MyContents : 연차사용내역
 */
var ctnAnnualLeave = {
	init: function (data, ext, caller, webPartID){
		let preId = webPartID!=undefined?"#"+webPartID+" ":"";
		var annualTags = "";
		for(var i = 1; i < 13; i++){
			if(i == 1 || i == 7) annualTags += "<div class='row'>";
			let tmFunc = new Function('data', 'return data[0][0].VacDay_' + i);
			let vacDayVal = tmFunc(data);
			if(vacDayVal==0) vacDayVal='';
			annualTags += "<dl><dt>" + i + Common.getDic('lbl_month') +"</dt><dd>" + vacDayVal + "</dd></dl>";
			if(i == 6 || i == 12) annualTags += "</div>";
		}
		$(preId + " #widget_annual_leave_detail_tab_panel .detail").append(annualTags); // 휴가월별현황
		$(preId + " #annual_leave_planVacDay dd").text(data[0][0].VacDay); // 총연차
		$(preId + " #annual_leave_useDays dd").text(data[0][0].UseDays); // 사용연차
		$(preId + " #annual_leave_remindDays dd").text(data[0][0].RemainVacDay); // 잔여연차
	}
}