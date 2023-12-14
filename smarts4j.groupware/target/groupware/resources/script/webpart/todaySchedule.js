
var todaySchedule = {
		init : function(data, ext){
			var yesterday = data[0];
			var today = data[1];
			var tomorrow = data[2];
			
			// 어제
			var yesterdayHTML = "";
			$(yesterday).each(function(){
				yesterdayHTML += "<li>"+this.Subject+"&nbsp;"+this.StartTime+"~"+this.EndTime+"</li>";
			});
			$("#yesterday").html(yesterdayHTML);
			
			// 오늘
			var todayHTML = "";
			$(today).each(function(){
				todayHTML += "<li>"+this.Subject+"&nbsp;"+this.StartTime+"~"+this.EndTime+"</li>";
			});
			$("#today").html(todayHTML);
			
			// 내일
			var tomorrowHTML = "";
			$(tomorrow).each(function(){
				tomorrowHTML += "<li>"+this.Subject+"&nbsp;"+this.StartTime+"~"+this.EndTime+"</li>";
			});
			$("#tomorrow").html(todayHTML);
		}
}