/**
 * pnReservation - [포탈개선] My Place - 회의실 예약
 */
var pnReservation = {
	webpartType: "",
	isOverlap: false,
	currentSelectResource: coviCmn.getCookie("recentReservation"),
	config: {
		IsUsePlaceOfBusiness: (typeof Common == 'object') ? Common.getBaseConfig("IsUsePlaceOfBusinessSel") : 'Y'
	},
	data: {},
	init: function (data, ext){
		pnReservation.setEvent();
		pnReservation.setDefaultTime();
		pnReservation.getResourceList();

		// 사업장 사용 여부
		if(this.config.IsUsePlaceOfBusiness == "Y"){
			$("#placeOfBusinessSel").show();
			pnReservation.setPlaceOfBusiness();
			$("#placeOfBusinessSel").css({"display":"inline"});
			$("#placeOfBusinessSel select").css({"width":"80px", "height":"40px"});
		}
		else {
			$(".PN_rsPlace #resourceSel").css({ 'margin-left': 0 });
		}
	},
	setEvent: function(){
		$(".PN_reserve").closest(".PN_myContents_box").find(".PN_portlet_btn").off("click").on("click", function(){
			if(!$(this).hasClass("active")){
				$(this).addClass("active");
				$(this).next(".PN_portlet_menu").stop().slideDown(300);
				$(this).children(".PN_portlet_btn > span").addClass("on");
			}else{
				$(this).removeClass("active");
				$(this).next(".PN_portlet_menu").stop().slideUp(300);
				$(this).children(".PN_portlet_btn > span").removeClass("on");
			}
		});

		$(".PN_reserve").closest(".PN_myContents_box").find(".PN_portlet_close").click(function(){
			$(this).parents(".PN_portlet_function").find(".PN_portlet_btn").removeClass("active");
			$(this).parents(".PN_portlet_menu").stop().slideUp(300);
			$(this).parents(".PN_portlet_function").find(".PN_portlet_btn > span").removeClass("on");
		});

		$("#PN_rsDate").addClass("input_date").datepicker({
			dateFormat: "yy.mm.dd",
			showOn: "button",
			buttonText : "calendar",
			buttonImage: Common.getGlobalProperties("css.path") +  "/covicore/resources/images/theme/blue/app_calendar.png", 
			buttonImageOnly: true,
			dayNamesMin: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
		});
		
		$(".PN_rsTime select").on("change", function(){
			var sTime = Number($("#rsSTime").val());
			var eTime = Number($("#rsETime").val());
			
			if(sTime >= eTime){
				Common.Warning("<spring:message code='Cache.msg_Mobile_InvalidStartTime'/>"); // 시작시간이 종료시간보다 클 수 없습니다.
				return false;
			}
			
			pnReservation.setTimeTable();
			pnReservation.getReservationList($(".PN_rsPlace #resourceSel").val(), $("#PN_rsDate").val().replaceAll(".", "-"));
		});
		
		$(".PN_reserve .PN_btnLink").off("click").on("click", function(){
			if(pnReservation.isOverlap){
				Common.Warning("<spring:message code='Cache.msg_ResourceManage_26' />"); // 자원을 예약할 수 없습니다. 동일한 예약기간에 이미 사용되고 있습니다.
				return false;
			}
			
			if($("#resourceSel").val() == ""){
				Common.Warning("<spring:message code='Cache.msg_mustSelectRes' />"); // 자원을 선택해주세요.
				return false;
			}
			
			pnReservation.openSubjectPopup();
		});
		
		$(".PN_rsPlace select, #PN_rsDate").off("change").on("change", function(){
			pnReservation.currentSelectResource = $(".PN_rsPlace #resourceSel").val();
			pnReservation.getReservationList(pnReservation.currentSelectResource, $("#PN_rsDate").val().replaceAll(".", "-"));
		});	
	},
	setTimeTableEvent: function(){
		$(".PN_timeTable .PN_rsChk p input[type=checkbox]").off("click").on("click", function(e){
			var checkedList = $(".PN_timeTable .PN_rsChk p > input:checked");
			pnReservation.isOverlap = false;
				
			if(checkedList.length > 1){
				var sNum = Number($(checkedList[0]).attr("id").replace(/[^\-\.0-9]/g, ""));
				var eNum = Number($(checkedList[(checkedList.length - 1)]).attr("id").replace(/[^\-\.0-9]/g, ""));
				var clickNum = Number($(this).attr("id").replace(/[^\-\.0-9]/g, ""));
				
				$.each($(".PN_timeTable .PN_rsChk p > input"), function(idx, item){
					var thisNum = Number($(item).attr("id").replace(/[^\-\.0-9]/g, ""));
					
					if(clickNum > sNum && clickNum < eNum){
						if(thisNum >= sNum && thisNum < clickNum
							&& !$(item).prop("disabled")){
							$(item).prop("checked", true);
						}
						else $(item).prop("checked", false);
					}else if(clickNum == sNum){
						if(thisNum >= clickNum && thisNum <= eNum){
							if($(item).prop("disabled")) pnReservation.isOverlap = true;
							else $(item).prop("checked", true);
						}
						else $(item).prop("checked", false);
					}else if(clickNum == eNum){
						if(thisNum >= sNum && thisNum <= clickNum){
							if($(item).prop("disabled")) pnReservation.isOverlap = true;
							else $(item).prop("checked", true);
						}
						else $(item).prop("checked", false);
					}
				});
			}
		});
	},
	setDefaultTime: function(){
		Common.getBaseConfigList(["WorkStartTime","WorkEndTime"]);
		var nowDate = new Date(CFN_GetLocalCurrentDate("yyyy/MM/dd"));
		var nowDateStr = schedule_SetDateFormat(nowDate, ".")
		var workSTime = Number(coviCmn.configMap["WorkStartTime"]);
		var workETime = Number(coviCmn.configMap["WorkEndTime"]);
		var timeHtml = "";
		var optionHtml = "";
		
		for(var i = workSTime; i < workETime; i++){
			var hourStr = "";
			var timeStr = "";
			var liWrap = $("<li></li>");
			
			if(i < 10) hourStr = "0" + i;
			else hourStr = i;
			
			timeStr = hourStr + ":00";
			
			liWrap.append($("<div class='PN_rsTime2'></div>").text(hourStr))
			.append($("<div class='PN_rsChk'></div>")
				.append($("<p></p>")
					.append($("<input type='checkbox'>").attr("time", timeStr).attr("id", "rs"+i))
					.append($("<label></label>").attr("for", "rs"+i)
						.append($("<span class='s_check'></span>"))))
				.append($("<p></p>")
						.append($("<input type='checkbox'>").attr("time", hourStr + ":30").attr("id", "rs"+(i+0.5)))
						.append($("<label></label>").attr("for", "rs"+(i+0.5))
							.append($("<span class='s_check'></span>")))));
			
			timeHtml += $(liWrap)[0].outerHTML;
			optionHtml += $("<option></option>").attr("value", i).text(timeStr)[0].outerHTML;
		}
		
		$("#PN_rsDate").val(nowDateStr);
		$(".PN_timeTable ul").empty().append(timeHtml);
		$(".PN_rsTime select").empty().append(optionHtml);
		$(".PN_rsTime select").append($("<option></option>").text(workETime + ":00"));
		$("#rsSTime").find("option:first").prop("selected", true);
		$("#rsETime").find("option:last").prop("selected", true);
		
		pnReservation.setTimeTableEvent();
	},
	setTimeTable: function(){
		var sTime = Number($("#rsSTime").val().split(":")[0]);
		var eTime = Number($("#rsETime").val().split(":")[0]);
		var timeHtml = "";
		
		for(var i = sTime; i < eTime; i++){
			var hourStr = "";
			var liWrap = $("<li></li>");
			
			if(i < 10) hourStr = "0" + i;
			else hourStr = i;
			
			liWrap.append($("<div class='PN_rsTime2'></div>").text(hourStr))
			.append($("<div class='PN_rsChk'></div>")
				.append($("<p></p>")
					.append($("<input type='checkbox'>").attr("time", hourStr + ":00").attr("id", "rs"+i))
					.append($("<label></label>").attr("for", "rs"+i)
						.append($("<span class='s_check'></span>"))))
				.append($("<p></p>")
						.append($("<input type='checkbox'>").attr("time", hourStr + ":30").attr("id", "rs"+(i+0.5)))
						.append($("<label></label>").attr("for", "rs"+(i+0.5))
							.append($("<span class='s_check'></span>")))));
			
			timeHtml += $(liWrap)[0].outerHTML;
		}
		
		$(".PN_timeTable ul").empty().append(timeHtml);
		
		pnReservation.setTimeTableEvent();
	},
	// 사업장 Select Box 세팅
	setPlaceOfBusiness: function (){
		var lang = Common.getSession("lang");
		var initInfos = [
	        {
		        target : 'placeOfBusinessSel',
		        codeGroup : 'PlaceOfBusiness',
		        defaultVal : 'PlaceOfBusiness',
		        width : '220',
		        onchange : ''
	        }
        ];
        coviCtrl.renderAjaxSelect(initInfos, '', lang);
		$("#placeOfBusinessSel select").change(pnReservation.onChangePlaceOfBusiness);
		$("#placeOfBusinessSel select").removeClass('selectType04').addClass('selectType02');
	},
	// 사업장 Select Box 변경시
	onChangePlaceOfBusiness : function (){
		placeOfBusiness = coviCtrl.getSelected('placeOfBusinessSel').val;
		
		if(placeOfBusiness == "PlaceOfBusiness"){
			placeOfBusiness = "";
		}
		pnReservation.setResourceList(placeOfBusiness);
	},
	getResourceList: function(){
		$.ajax({
			url: "/groupware/resource/getResourceList.do",
			type: "POST",
			data: {
				"FolderType": "Resource.MeetingRoom"
			},
			success: function(res){
				if(res.status == "SUCCESS"){
					if(res != null && res.data.length != 0){
						pnReservation.data.resources = res.data;
						pnReservation.setResourceList();
					}
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/resource/getResourceList.do", response, status, error);
			}
		});
	},
	setResourceList: function(pPlaceOfBusiness){
		$(".PN_rsPlace #resourceSel option").remove();
		$(".PN_timeTable input[type=checkbox]").prop("disabled", false);
		$(".PN_timeTable input[type=checkbox]").prop("checked", false);
		
		$.each(this.data.resources, function(idx, item){
			if (pPlaceOfBusiness == undefined || pPlaceOfBusiness == '' || pnReservation.config.IsUsePlaceOfBusiness != 'Y' || (pnReservation.config.IsUsePlaceOfBusiness == 'Y' && (item.PlaceOfBusiness.indexOf(pPlaceOfBusiness) > -1 || item.PlaceOfBusiness == ''))){
				$(".PN_rsPlace #resourceSel").append($("<option>").text((item.UpperFolderName != "" ? item.UpperFolderName + " > " : item.UpperFolderName) + item.FolderName).attr("value", item.FolderID).attr("PlaceOfBusiness", item.PlaceOfBusiness));	
			}
		});
		
		//자원이 없을 경우
		if($(".PN_rsPlace #resourceSel option").length <= 0){
			$(".PN_rsPlace #resourceSel").append($("<option>").text(Common.getDic("lbl_Resources")).attr("value", ''));
		}
		
		//자원 선택
		if($('.PN_rsPlace #resourceSel option[value="' + pnReservation.currentSelectResource + '"]').length > 0){
			$(".PN_rsPlace #resourceSel").val(pnReservation.currentSelectResource); // 이전 선택 자원이 현재 사업장에도 있으면 선택
		}
		$(".PN_rsPlace #resourceSel").trigger("change");	

		
		
	},
	getReservationList: function(pFolderID, pResDate){
		$.ajax({
			url: "/groupware/resource/getBookingList.do",
			type: "POST",
			data: {
				"mode": "D",
				"FolderID": ";" + pFolderID + ";",
				"StartDate": CFN_TransServerTime(pResDate + " 00:00"),
				"EndDate": CFN_TransServerTime(schedule_SetDateFormat(schedule_AddDays(pResDate, 1),'-')+ ' 00:00'),
				"hasAnniversary": "N"
			},
			success: function(res){
				if(res.status == "SUCCESS"){
					$(".PN_timeTable input[type=checkbox]").prop("disabled", false);
					$(".PN_timeTable input[type=checkbox]").prop("checked", false);
					
					if(res && res.data.folderList.length > 0){
						var bookingList = res.data.folderList[0].bookingList;
						
						if(bookingList && bookingList.length > 0){
							$.each(bookingList, function(bIdx, booking){
								var sTime = CFN_TransLocalTime(booking.StartDate + " " + booking.StartTime, "HH:mm");
								var eTime = CFN_TransLocalTime(booking.EndDate + " " + booking.EndTime, "HH:mm");
								var isTime = false;
								var itemTime;
								var tempTime;
								
								// 종료 시간 세팅
								var endTime = Number($("#rsETime").val().split(":")[0]);
								endTime = endTime < 10 ? "0" + endTime : endTime; // 10보다 작을 경우 0 추가
								var setendTime = CFN_TransLocalTime(booking.EndDate + " "+ endTime +":00", "HH:mm"); // 시간 세팅
									
								// 종료일이 선택일보다 큰 경우 설정된 종료 시간으로 시간 변경
								eTime = CFN_TransServerTime(booking.EndDate + " 00:00:00") > CFN_TransServerTime(pResDate + " 00:00:00") ? setendTime : eTime;
									
								// 시작 시간 세팅
								var startTime = Number($("#rsSTime").val().split(":")[0]);
								startTime = startTime < 10 ? "0" + startTime : startTime; // 10보다 작을 경우 0 추가
								var setstartTime = CFN_TransLocalTime(booking.StartDate + " "+ startTime +":00", "HH:mm"); // 시간 세팅
																
								// 시작 시간이 세팅 시간보다 작고, 종료 시간이 시작시간보다 큰 경우 혹은 시작일이 선택일보다 작은 경우 시작 시간을 세팅 시간으로 변경
								sTime = (sTime < setstartTime && eTime > setstartTime) || CFN_TransServerTime(booking.StartDate + " 00:00:00") < CFN_TransServerTime(pResDate + " 00:00:00") ? setstartTime : sTime; 
								
								$.each($(".PN_timeTable input[type=checkbox]"), function(tIdx, time){
									tempTime = itemTime;
									itemTime = $(time).attr("time");
									
									if(itemTime.split(":")[0] == sTime.split(":")[0] 
										&& Number(itemTime.split(":")[1]) - Number(sTime.split(":")[1] < 30)){
										if(itemTime <= sTime) isTime = true;
									}
									if(itemTime >= eTime) isTime = false;
									
									if(isTime) $(time).prop("disabled", true);
								});
							});
						}
					}
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/resource/getBookingList.do", response, status, error);
			}
		});
	},
	openSubjectPopup: function(){
		var url = "/groupware/resource/goSubjectPopup.do?callBackFunc=pnReservation.getReservationList";
		var resID = $(".PN_rsPlace #resourceSel").val();
		var resDate = $("#PN_rsDate").val();
		var sHour = "00";
		var sMin = "00";
		var eHour = "01";
		var eMin = "00";
		
		if($(".PN_timeTable input[type=checkbox]:checked").length != 0){
			var sTime = $(".PN_timeTable input[type=checkbox]:checked:first").attr("time");
			var eTime = $(".PN_timeTable input[type=checkbox]:checked:last").attr("time");
			sHour = sTime.split(":")[0];
			sMin = sTime.split(":")[1];
			eHour = eTime.split(":")[0];
			eMin = eTime.split(":")[1];
			
			if(eMin == "30") {
				eHour = Number(eHour) + 1;
				eMin = "00"
			}else{
				eMin = "30"
			}
		}else{
			Common.Warning("<spring:message code='Cache.msg_selectReserveTime' />"); // 예약할 시간을 선택해 주세요.
			return false;
		}
		
		url += "&resourceID=" + resID
			+  "&resDate=" + resDate
			+  "&sTime=" + sHour + ":" + sMin
			+  "&eTime=" + eHour + ":" + eMin;
		
		Common.open("", "ResourceBooking", "<spring:message code='Cache.lbl_Booking' />", url, "400px", "325px", "iframe", true, null, null, true); // 자원예약
	}
}
