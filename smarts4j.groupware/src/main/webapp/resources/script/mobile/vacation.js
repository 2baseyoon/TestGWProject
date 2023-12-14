


//휴가관리 메인
$(document).on('pageinit', '#vacation_main_page', function () {
	if($("#vacation_main_page").attr("IsLoad") != "Y"){
		$("#vacation_main_page").attr("IsLoad", "Y");
		setTimeout(function () {
			mobile_vacation_MainInit();
	    }, 10);
	}
});

//휴가관리 메인 초기화
function mobile_vacation_MainInit() {
	var nowYear = new Date().getFullYear();
	var nowDate = $.datepicker.formatDate('yyyy-mm-dd', new Date());
	var profilePath = mobile_comm_replaceAll(mobile_comm_getBaseConfig("ProfileImagePath"), "{0}", mobile_comm_getSession("DN_Code"));
	
	mobile_comm_showload();
	
	$.ajax({
		type : "POST",
		data : {year : nowYear,
				now : nowDate},
		async: false,
		url : "/groupware/vacation/getVacationInfoForHome.do",
		success: function (list) {
			mobile_comm_hideload();
			var data = list.list[0];
			var per = data.PER;
			
			$('#vacation_main_title').html(nowYear + ' ' + mobile_comm_getDic('lbl_apv_vacation_total_annual'));
			
			// per이 100을 넘어가게 되면(총 연차보다 사용 연차가 많을 경우) 다시 100으로 조정
			if(per > 100) per = 100; 
			$('#vacation_main_pie').css('transform', 'rotate(' + (3.6 * per) + 'deg)');	
			//	1%에 3.6deg, 180deg(50%)가 넘어 갈 경우 chart_wrap에 gt180 클래스, 추가 로테이션 값은 pie에만 입력한다.
			if (per > 49) $('.chart_wrap').addClass('gt180');
			else $('.chart_wrap').removeClass('gt180');
			
			$('#vacation_main_totalDays').html(Math.floor(data.VacDay));
			$('#vacation_main_useDays').html(Number(data.VacDayUse));
			$('#vacation_main_remainDays').html(Number(data.RemainVacDay));
			//$('#vacation_main_deptName').html('(' + data.DeptName + ')');
			
			data = list.todayList;
			if(data.length > 0) {	
				var html = '';			
				$.each(data, function(i, v) {
					html += '<li>';
					html += '	<span class="photo" style="background-image:url(\'/covicore/common/photo/photo.do?img='+profilePath+v.UR_Code+'.jpg\')"></span>';
					html += '	<div class="info">';
					var vctitle = "";
					if(v.GUBUN === "VACATION_CANCEL"){
						vctitle += '<span class="btnType03 normal" style="line-height: 19px;">' + v.VacFlagName +' '+mobile_comm_getDic("lbl_Cancel") + '</span>'; // 취소
					}else{
						vctitle += '<span class="btnType02 borderBlue">' + v.VacFlagName + '</span>';
					}
					html += '		<p class="date">' +vctitle + v.period + '</p>';
					html += '		<p class="name">' + v.UR_Name + ' ' + v.JobPositionName + ' <span class="team">' + v.DeptName + '</span></p>';
					if(v.DEPUTY_NAME != null && v.DEPUTY_NAME != "" && v.DEPUTY_NAME != "undefined" && v.DEPUTY_NAME != undefined)
						html += '	<p class="replacement"><span class="label">' + mobile_comm_getDic('lbl_vacation_alterWorker') + ' :</span>' + v.DEPUTY_NAME + '</p>'; //대체직무자
					html += '	</div>';
					html += '</li>';
				});
				
				$('#vacation_main_list').html(html);
			} else {
				var sHtml = "";
				sHtml += "<div class=\"no_list\" style=\"padding-top: 100px;\">";
				sHtml += "    <p>" + mobile_comm_getDic("msg_NoDataList") + "</p>";//조회할 목록이 없습니다.
				sHtml += "</div>";
				$("#vacation_main_list").html(sHtml);
				
			}
			
		},
		error:function(response, status, error) {
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});	
}

//새로고침
function mobile_vacation_clickrefresh() {
	 mobile_comm_showload(); 
	 setTimeout(function() {
		 mobile_vacation_MainInit();
	 }, 10);
	 setTimeout(function() {
		 mobile_comm_hideload();
	 }, 20);
}

//휴가 작성
function mobile_vacation_clickwrite() {
	/*var sUrl = "/groupware/mobile/vacation/write.do";
	mobile_common_go(sUrl);*/
}

