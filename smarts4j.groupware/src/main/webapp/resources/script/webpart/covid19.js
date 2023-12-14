var covid19 = {
	config: {},
	init: function(data, ext, caller){
		covid19.caller = caller;

		var _ext = (typeof ext == 'object') ? ext : {};
		covid19.config = $.extend(covid19.config, _ext);
		
		covid19.get();
	},
	get: function(){
		var nowDate = new Date(CFN_GetLocalCurrentDate("yyyy/MM/dd HH:mm:ss"));
		var sDate = schedule_SetDateFormat(schedule_AddDays(nowDate, -2), "");
		var yDate = schedule_SetDateFormat(schedule_AddDays(nowDate, -1), "");
		var eDate = schedule_SetDateFormat(nowDate, "");
		
		$.ajax({
			type: "POST",
			url: "/covicore/control/getCovid19Api.do",
			data: {
				  "sDate": sDate
				, "eDate": eDate
			},
			success: function(data){
				if(data.status == "SUCCESS"){
					var covidInfo = data.result.sort(function(a, b){
					    if(a.stateDt > b.stateDt){
					        return -1;
					    }else if(a.stateDt < b.stateDt){
					        return 1;
					    }else{
					        return a.updateDt == "" ? 1 : -1;
					    }
					}).filter(function(val, idx, arr){
						return !arr[idx-1] || (arr[idx-1] && ((val.stateDt == arr[idx-1].stateDt && val.updateDt != "") || val.stateDt != arr[idx-1].stateDt));
					}, []);
					var sDateCnt = 0;
					var eDateCnt = 0;
					
					$.each(covidInfo, function(idx, item){
						if(covidInfo.length == 2){
							if(Number(sDate) == item.stateDt){
								sDateCnt = item.decideCnt;
							}else if(Number(yDate) == item.stateDt){
								eDateCnt = item.decideCnt;
							}
						}else{
							if(Number(yDate) == item.stateDt){
								sDateCnt = item.decideCnt;
							}else if(Number(eDate) == item.stateDt){
								eDateCnt = item.decideCnt;
							}
						}
					});
					
					var subCnt = eDateCnt - sDateCnt;
					
					if(subCnt > 0){
						$(".PN_People .PN_Variation").addClass("up");
					}else if(subCnt < 0){
						$(".PN_People .PN_Variation").addClass("down");
					}
					
					$(".PN_People .PN_Variation").text(subCnt.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","));
					$(".PN_People .PN_Num").text(eDateCnt.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","));
					
					$(".PN_People .PN_Num").counterUp();
					$(".PN_People .PN_Variation").counterUp();
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/covicore/control/getCovid19Api.do", response, status, error);				
			}
		});
	}
}