/**
 * todayCalendar.js - 달력 
 */
var todayCal ={
		webpartType: '', 
		init: function(data,ext){
			var today = new Date();
			var html = String.format(Common.getDic("lbl_TodayDate"), today.getMonth( )+1, today.getDate());	//오늘은 {0}월 {1}일
			//var test = $.parseJSON("<>");
			$("#todayCal_today").html(html);
		}
}
