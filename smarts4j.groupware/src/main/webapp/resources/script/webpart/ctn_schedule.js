/**
 * ctn_schedule - 웹파트, 일정.
 * viewMode : PC_CAL(캘린더를 띄운 형태, 일정 1일 검색, PC Ver.)
 * 			, PC_DAY(날짜변경 가능한 일정 1일 검색:현재 퍼블없음), MO_DAY(날짜변경 가능한 일정 1일 검색:모바일 위젯)
 * 			, PC_LIST(달력없이 오늘과 내일의 일정 조회. x1y2), MO_LIST(x1y1)
 */
var ctnSchedule = {
	strNow : "",
	strNextDay : "",
	schYear : "",
	schMonth : "",
	schDate : "",
	dateNow : new Date(),
	folderCheckList : ";",
	webpartId : "",
	webpartType: "",
	myCalendar : "",
	callId  : "",
	viewMode : "PC_LIST",
	weekday: { 0 : 'lbl_Sunday', 1 : 'lbl_Monday', 2 : 'lbl_Tuesday', 3 : 'lbl_Wednesday', 4 : 'lbl_Thursday', 5 : 'lbl_Friday', 6 : 'lbl_Saturday'}
	, init: function (data, ext, pType, pWebpartID) {
		
		if (coviUtil.isMobile()){
			mobile_schedule_SetAclEventFolderData();
			$("#"+ pWebpartID).find(".widget_empty").addClass("ui_empty");
			ctnSchedule.viewMode = "MO_"
		}else{
			scheduleUser.setAclEventFolderData();
			ctnSchedule.viewMode = "PC_"
		}	
		
		ctnSchedule.schOnLoad(); 	// FolderID list Setting.
		
		let $this = this;
		$this.strNow = ctnSchedule.exchangeDate(new Date());
		$this.webpartId = pWebpartID;
		$this.webpartType =pType;
		$this.callId = pWebpartID+"_coviCalendar";
		
		if (ext?.isCalender === "Y" ) {	
			ctnSchedule.viewMode += "CAL";
		} else {
			if (ext?.isDay === "Y") {
				ctnSchedule.viewMode += "DAY";
			} else {
				ctnSchedule.viewMode += "LIST";
			}
		}
		
		if ($this.viewMode === "PC_CAL") {
			$("#"+pWebpartID+" .widget_head").addClass("fixed");
			
			$("#"+pWebpartID+" .schedule_calendar").attr("id", pWebpartID+"_coviCalendar"); 	// create Calendar.
		   	$(function () {
		   		$this.myCalendar = CoviCalendar($this.callId, {weekLine: 6});
		    });
			
			$this.searchScheduleInfo($this.strNow);
			
			$("#"+$this.callId).click(function() { 		// Calendar Click event.
				
				let $webpart = $("#"+$this.webpartId);
				let $calendar = $("#"+$this.callId);
				let strCalendarCurrent = $calendar.find('.covi-calender-current').text();
				let strSelDate = $calendar.find(".selected").attr("data-day");
				let dateSelected = new Date(strSelDate);
				
				$webpart.find("[data-custom-scrollbar] .schedule_list").empty(); 	// 기존 데이터 삭제.
				
				if ( new Date(strCalendarCurrent).getMonth() === dateSelected.getMonth() ) {
					$webpart.find("[data-custom-scrollbar]").attr("hidden", false);
					$webpart.find(".empty").attr("hidden", true);
					$this.searchScheduleInfo($this.exchangeDate(dateSelected));
				} else {
					// 달력의 현재 달과 클릭한 날짜의 월이 다를 때 0건으로 처리.
					$webpart.find("[data-custom-scrollbar]").attr("hidden", true);
					$webpart.find(".empty").attr("hidden", false);
				}
			});
			
		} else {
			if ($this.viewMode.indexOf("PC") > -1 || $this.webpartType == "Contents") {
				$("#"+$this.webpartId).find(".widget_head").prepend($("<h3>", {"class": "title", "text": Common.getDic('lbl_task_task')+""+Common.getDic('lbl_Schedule')})); 	// 업무 일정
			}
			
			if ($this.viewMode === "PC_LIST") {
				$("#"+ctnSchedule.webpartId).find(".schedule_list").addClass("history_list").removeClass("schedule_list")
				.append($("<h4>").append($("<span>", {"text": $this.strNow})))
				.append($("<ul>"));
				$this.searchScheduleList($this.strNow);
			
			} else if ($this.viewMode === "MO_LIST") {
				let $webpartScroll = $("#"+ctnSchedule.webpartId).find("[data-custom-scrollbar]");
				$webpartScroll.addClass("history-list").empty();
				$webpartScroll.append($("<h4>").append($("<span>", {"text": $this.strNow}))).append($("<ul>"));
				$webpartScroll.each(function (index, element) {
        	    	new SimpleBar(element);
	        	});
				$this.searchScheduleList($this.strNow);
			
			} else if (($this.viewMode === "MO_DAY") && ($this.webpartType === "Widget")) {
				let strDate = $this.strNow + " " + mobile_comm_getDic($this.weekday[new Date($this.strNow).getDay()]);
				$("#"+ $this.webpartId).find(".schedule_list").remove(); 
				$("#"+ $this.webpartId).find(".schedule_calendar").attr("hidden", true);
				$("#"+ $this.webpartId).find(".widget_content").prepend($("<div>", {"class":"toolbar"}));
				
				$("#"+ $this.webpartId).find(".toolbar")
				.append($("<button>", {"type":"button", "class" : "prev ui-btn ui-shadow ui-corner-all", "data-icon": "prev"})
					.append($("<span>", {"text": mobile_comm_getDic("lbl_previous")}))
				)
				.append($("<button>", {"type": "button", "class" : "calendar ui-btn ui-shadow ui-corner-all"})
					.append($("<span>", {"text" : mobile_comm_getDic("lbl_schedule_calendar")}))
				)
				.append($("<div>", {"class" : "label", "text" : strDate}))
				.append($("<button>", {"type": "button", "class": "next ui-btn ui-shadow ui-corner-all", "data-icon": "next"})
					.append($("<span>", {"text": mobile_comm_getDic("lbl_next")}))
				);
				
				let $webpartContent = $("#"+pWebpartID).find("[data-custom-scrollbar]").addClass("list");
				$webpartContent.each(function (index, element) {
        	    	new SimpleBar(element);
	        	});
				
				$webpartContent.find(".simplebar-content").append($("<ul>"));
				
				$this.searchScheduleInfo($this.strNow);
				
				$("#"+ $this.webpartId+" .toolbar button").click(function() {
					if ($(this).attr("data-icon") === "prev") {
						$this.strNextDay = $this.exchangeDate(mobile_schedule_AddDays($this.strNow, -1));
						$this.strNow = $this.strNextDay;
						
					} else if ($(this).attr("data-icon") === "next") {
						$this.strNextDay = $this.exchangeDate(mobile_schedule_AddDays($this.strNow, 1));
						$this.strNow = $this.strNextDay;
					}
					
					$this.searchScheduleInfo($this.strNow);
				});
			}
		}
		
		// init function end.
	}

	, schOnLoad : function() { 	// Authorized FolderID List Setting.
		let schArr = coviUtil.isMobile()?_mobile_schedule_common.AclArray:schAclArray;
		let $this = this;
		$(schArr.read).each(function(idx,obj){
			$this.folderCheckList += (obj.FolderID + ";");
		});
	}
	
	// viewMode : PC_CAL
	, searchCalendarData : function(pDate) {
		
		let $this = this;
		let yearMonth = pDate.split("-")[0] + "-" + pDate.split("-")[1];
		let endDate = new Date(pDate.split("-")[0], pDate.split("-")[1], 0).getDate()
		$.ajax({
			url: "/groupware/schedule/getLeftCalendarEvent.do"
			, type: "POST"
			, data: {
				"StartDate": yearMonth+"-01"
				, "EndDate": yearMonth+"-"+endDate
				, "FolderIDs": $this.folderCheckList
			}
			, success: function(res){
				if (res.status == "SUCCESS") {
					let arrResultDate = [];
					
					$(res.list).each(function() {
						var startDate = this.StartEndDate.split("~")[0];
						var endDate = this.StartEndDate.split("~")[1];
						
						arrResultDate.push(startDate);
						arrResultDate.push(endDate);
					});
					filteringDate = Array.from(new Set(arrResultDate));
					$this.myCalendar.setMark(filteringDate);
	                		
				} else {
					parent.Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
				}
			}
			, error:function(response, status, error){
				parent.CFN_ErrorAjax("/groupware/schedule/getLeftCalendarEvent.do", response, status, error);
			}
		});
	}
	
	// search schedule data(daily).
	, searchScheduleInfo : function(pDate) {
		
		var sDate = pDate;
		var eDate = sDate;
		var sessionObj = Common.getSession();
		var params = {
				"FolderIDs" : ctnSchedule.folderCheckList,
				"StartDate" : sDate+ ' 00:00',
				"EndDate" : eDate+ ' 23:59',
				"UserCode" : sessionObj["USERID"],
				"lang" : sessionObj["lang"]
		};

		$.ajax({
			type:"POST",
			url:"/groupware/schedule/getList.do",
			data: params,
			success:function(result) {
				var listData = result.list;
				
				if (ctnSchedule.viewMode.indexOf("LIST") > -1) {
					if (ctnSchedule.strNow === pDate) {
						ctnSchedule.drawSchedule(listData, pDate);
					} else {
						ctnSchedule.drawNextSchedule(listData, pDate);
					}
				} else {
					ctnSchedule.drawSchedule(listData, pDate);
				}
			}
			, error:function(response, status, error){
				CFN_ErrorAjax("/groupware/schedule/getList.do", response, status, error);
			}
		});
	}
	
	, searchScheduleList : function(pNow) { 	// viewMode is PC_LIST or MO_LIST.
		this.searchScheduleInfo(pNow);
		if (ctnSchedule.viewMode.indexOf("PC") > -1) {
			ctnSchedule.strNextDay = ctnSchedule.exchangeDate(schedule_AddDays(pNow, 1));	
		} else {
			ctnSchedule.strNextDay = ctnSchedule.exchangeDate(mobile_schedule_AddDays(ctnSchedule.strNow, 1));
		}

		this.searchScheduleInfo(ctnSchedule.strNextDay);	
	}

	// 상세보기 레이어팝업
	, goDetailViewPage : function(eventID, dateID, repeatID, isRepeat, folderID) {
		if (ctnSchedule.viewMode.indexOf("PC") > -1) {
			Common.open("","schedule_detail_pop",Common.getDic("lbl_DetailView"),'/groupware/schedule/goScheduleDetailPopup.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule'			//상세보기
						+'&eventID=' + eventID 
						+ '&dateID=' + dateID 
						+ "&repeatID=" + repeatID
						+ '&isRepeat=' + isRepeat 
						+ '&folderID=' + folderID
						+ '&viewType=Popup',"1050px","632px","iframe",true,null,null,true);
		}
	}
	
	, drawSchedule : function(pList, pDate) {
		
		let $webpart = $("#"+ctnSchedule.webpartId);
		
		if (pList.length > 0) {
			let $ulTag = "";
			let nowTime = ctnSchedule.dateNow.getHours() + ":" + ctnSchedule.dateNow.getMinutes();
			
			if (ctnSchedule.viewMode === "PC_CAL") { 		// PC 업무일정 달력형.
				$webpart.find(".empty").attr("hidden", true);
				let $scrollbar = $("#"+ctnSchedule.webpartId).find("[data-custom-scrollbar]");
				$scrollbar.attr("hidden", false);
				let $scheduleList = $scrollbar.find(".schedule_list");
				$scheduleList.empty();
				$scheduleList.append($("<ul>"));
				$ulTag = $scheduleList.find("ul");
				
				$.each(pList, function(index, value) {
					$ulTag.append($("<li>", { "data-eventid" : value.EventID, "data-dateid" : value.DateID, "data-repeatid": value.RepeatID, "data-isrepeat": value.IsRepeat, "data-folderid" : value.FolderID}));
					
					$ulTag.find("li").eq(index).append($("<a>", {"href": "#"})
						.append($("<i>", {"class" : "status", "style" : "background-color:"+value.Color})) 		// 23.09.11 : 디자인 변경. 일정 색상으로 변경.
						.append($("<strong>", {"text": value.Subject}))
						.append($("<time>", {"text": value.StartTime+"~"+value.EndTime}))
					);
				});
				ctnSchedule.searchCalendarData(pDate);
			}
			else if (ctnSchedule.viewMode.indexOf("LIST") > -1) { 	// 업무일정 목록형(PC / Mobile).
				if (ctnSchedule.viewMode.indexOf("PC") > -1) { 		// PC와 모바일 class 디자인이 underline과 hypen 이 다르게 적용되어 있음.
					$ulTag = $("#"+ctnSchedule.webpartId+" .history_list").find("ul");
				} else {
					$ulTag = $("#"+ctnSchedule.webpartId+" .history-list").find("ul");
				}
				
				// 업무일정 PC/Mobile 모두.		
				$.each(pList, function(index, value) {
					$ulTag.append($("<li>", { "data-eventid" : value.EventID, "data-dateid" : value.DateID, "data-repeatid": value.RepeatID, "data-isrepeat": value.IsRepeat, "data-folderid" : value.FolderID}));
					
					$ulTag.find("li").eq(index).append($("<a>", {"class" : "history", "href": "#"})
						.append($("<i>", {"class" : "status", "style" : "background-color:"+value.Color})) 		// 23.09.11 : 디자인 변경. 일정 색상으로 변경.
						.append($("<strong>", {"text": value.Subject}))
			 			.append($("<time>", {"text": value.StartTime+"~"+value.EndTime}))
					);
				});
			}
			else if ((ctnSchedule.viewMode === "MO_DAY") && (ctnSchedule.webpartType === "Widget")) {
				
				$webpart.find(".empty").attr("hidden", true);
				$webpart.find("[data-custom-scrollbar]").attr("hidden", false);
			
				let strDate = ctnSchedule.strNow + " " + mobile_comm_getDic(ctnSchedule.weekday[new Date(ctnSchedule.strNow).getDay()]);
				$("#"+ctnSchedule.webpartId+ " .toolbar").find(".label").text(strDate);
				
				$ulTag = $("#"+ctnSchedule.webpartId+ " .simplebar-content").find("ul");
				$ulTag.empty();
				
				$.each(pList, function(index, value) {
					$ulTag.append($("<li>", { "data-eventid" : value.EventID, "data-dateid" : value.DateID, "data-repeatid": value.RepeatID, "data-isrepeat": value.IsRepeat, "data-folderid" : value.FolderID}));
					
					$ulTag.find("li").eq(index).append($("<a>", {"class" : "ui-link", "href" : "#"})
						.append($("<i>", {"class" : "status", "style" : "background-color:"+value.Color})) 	// 23.09.11 : 디자인 변경. 일정 색상으로 변경.
						.append($("<span>", {"text": value.Subject}))
						.append($("<time>", {"text": value.StartTime+"~"+value.EndTime}))
					);
				});
			}
			
			$ulTag.find("li").click(function() { 	// schedule click event.
				let $li = $(this);
			
				if (coviUtil.isMobile()) {
					let strUrl = "/groupware/mobile/schedule/view.do?eventid="+$li.attr("data-eventid")+"&dateid="+$li.attr("data-dateid")+"&isrepeat=+"+$li.attr("data-isrepeat")+"&repeatid="+$li.attr("data-repeatid")+"&folderid="+$li.attr("data-folderid")+"&IsPopup=Y";
					mobile_comm_go(strUrl, "Y")
				} else { 	// PC Ver.
					ctnSchedule.goDetailViewPage($li.attr("data-eventid"), $li.attr("data-dateid"), $li.attr("data-repeatid"), $li.attr("data-isrepeat"), $li.attr("data-folderid"));
				}
			});
			// CASE : data exist end.

		} else { 	// case : data is 0.
			if (ctnSchedule.viewMode === "PC_CAL") {
				ctnSchedule.searchCalendarData(pDate);
				$webpart.find("[data-custom-scrollbar]").attr("hidden", true);
				$webpart.find(".empty").attr("hidden", false);
			} else if (ctnSchedule.viewMode.indexOf("DAY") > -1) {
				let $ulList = $("#"+ctnSchedule.webpartId+ " .simplebar-content").find("ul");
				$ulList.empty();
				let strDate = ctnSchedule.strNow + " " + mobile_comm_getDic(ctnSchedule.weekday[new Date(ctnSchedule.strNow).getDay()]);
				$("#"+ctnSchedule.webpartId+ " .toolbar").find(".label").text(strDate);
				$webpart.find($("#coviCalendar")).attr("hidden", true);
				$webpart.find("[data-custom-scrollbar]").attr("hidden", true);
				$webpart.find(".ui_empty").attr("hidden", false);	
			} else if (ctnSchedule.viewMode.indexOf("LIST") > -1) { 	// 0건이라도 다음날에 일정이 있다면 날짜를 보여주기.
				$webpart.find($("#coviCalendar")).attr("hidden", true);
				$("#"+ctnSchedule.webpartId).find(".schedule_list").addClass("history_list").removeClass("schedule_list")
					.append($("<h4>").append($("<span>", {"text": pDate})))
					.append($("<ul>"));
			}
		}
		// drawSchedule end.
	}
	
	, drawNextSchedule : function(pListData, pDate) { 	// viewMode is LIST 
		
		let $webpart = $("#"+ctnSchedule.webpartId);
		let $historyList = "";
		
		if (coviUtil.isMobile()) {
			$historyList = $webpart.find(".simplebar-content");
		} else {
			$historyList = $webpart.find(".history_list");
		}
		
		$historyList.append($("<h4>").append($("<span>", {"text":pDate})));
		$historyList.append($("<ul>"));
		
		let $ulTag = $historyList.find("ul").eq(1);
		
		if ($ulTag) {
			$.each(pListData, function(index, value) {
				$ulTag.append($("<li>", { "data-eventid" : value.EventID, "data-dateid" : value.DateID, "data-repeatid": value.RepeatID, "data-isrepeat": value.IsRepeat, "data-folderid" : value.FolderID}));
				
				$ulTag.find("li").eq(index).append($("<a>", {"class" : coviUtil.isMobile()?"history ui-link":"history", "href": "#"})
					.append($("<i>", {"class" : "status", "style" : "background-color:"+value.Color})) 		// 23.09.11 : 디자인 변경. 일정 색상으로 변경.
					.append($("<strong>", {"text": value.Subject}))
					.append($("<time>", {"text": value.StartTime+"~"+value.EndTime}))
				);
			});
		}
		
		// click event.
		$ulTag.find("li").click(function() { 	// schedule click event.
			let $li = $(this);
			
			if (coviUtil.isMobile()) {
				let strUrl = "/groupware/mobile/schedule/view.do?eventid="+$li.attr("data-eventid")+"&dateid="+$li.attr("data-dateid")+"&isrepeat=+"+$li.attr("data-isrepeat")+"&repeatid="+$li.attr("data-repeatid")+"&folderid="+$li.attr("data-folderid")+"&IsPopup=Y";
				mobile_comm_go(strUrl, "Y")
			} else { 	// PC Ver.
				ctnSchedule.goDetailViewPage($li.attr("data-eventid"), $li.attr("data-dateid"), $li.attr("data-repeatid"), $li.attr("data-isrepeat"), $li.attr("data-folderid"));
			}
		});
			
		// case : today and tomorrow schedule are empty.
		if ($historyList.find("li").length === 0) {
			$webpart.find("#coviCalendar").attr("hidden", true);
			$webpart.find("[data-custom-scrollbar]").attr("hidden", true);
			$webpart.find(".widget_empty").attr("hidden", false);
		}
	}
	
	// DateType to string type(yyyy-mm-dd).
	, exchangeDate : function(pDateType) {
		ctnSchedule.schYear = pDateType.getFullYear();
		ctnSchedule.schMonth = coviUtil.isMobile()?mobile_resource_AddFrontZero(pDateType.getMonth()+1, 2):AddFrontZero(pDateType.getMonth()+1, 2);
		ctnSchedule.schDate  = coviUtil.isMobile()?mobile_resource_AddFrontZero(pDateType.getDate(), 2):AddFrontZero(pDateType.getDate(), 2);
		return ctnSchedule.schYear + "-" + ctnSchedule.schMonth + "-" + ctnSchedule.schDate;
	}
	
}