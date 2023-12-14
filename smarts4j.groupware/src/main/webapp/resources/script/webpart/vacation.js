/**
 * wpVacation - 휴가관리
 */
var wpVacation = {
	config: {
		nowYear: schedule_SetDateFormat(new Date(CFN_GetLocalCurrentDate("yyyy/MM/dd")), '.').substr(0, 4)
	},
	data: {},
	init: function(data, ext, caller){
		var _ext = (typeof ext == 'object') ? ext : {};
		this.config = $.extend(this.config, _ext);
		this.caller = caller;
		
		wpVacation.setEvent();
		wpVacation.getVacationList();
	},
	setEvent: function(){
		$("#wpVacation_more").off("click").on("click", function(){
			location.href = '/groupware/layout/vacation_Home.do?CLSYS=vacation&CLMD=user&CLBIZ=vacation';
		});

		$("#wpVacation_request").off("click").on("click", function(){
			AttendUtils.openVacationPopup('USER');
		});
	},
	getVacationList: function() {
		$.when(
			$.ajax({
				url: "/groupware/vacation/getVacationInfoForHome.do",
				type: "POST",
				data: {
					"year": wpVacation.config.nowYear
				},
				success: function(data){
					if(data.status == "SUCCESS"){
						wpVacation.data.vacation = data.list[0];
					}
				},
				error: function(response, status, error){
					CFN_ErrorAjax("/groupware/vacation/getVacationInfoForHome.do", response, status, error);
				}
			}),
			$.ajax({
				url: "/groupware/pnPortal/selectUserRewardVacDay.do",
				type: "POST",
				data: {
					userCode: Common.getSession('USERID'),
					year: wpVacation.config.nowYear
				},
				success: function(data){
					wpVacation.data.rewardVacDay = data.rewardVacDay;
				},
				error: function(response, status, error){
					CFN_ErrorAjax("/groupware/pnPortal/selectUserRewardVacDay.do", response, status, error);
				}
			})
		).done(function(){
			wpVacation.render();
		});
	},
	render: function(){
		if (Object.keys(wpVacation.data).length == 0) {
			return false;
		}
		
		if (typeof wpVacation.data.vacation == 'object' && Object.keys(wpVacation.data.vacation).length > 0) {
			$.each(wpVacation.data.vacation, function(idx, el){
				$("[data-role="+idx+"] [data-role=vacCnt]").text(el);
			});
		}
		
		if (wpVacation.data.rewardVacDay) {
			$("[data-role=rewardVacDay] [data-role=vacCnt]").text(wpVacation.data.rewardVacDay);
		}
	}
}