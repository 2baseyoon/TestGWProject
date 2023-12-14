/**
 * approvalBox - 전자결재 - 결재함
 */
g_viewType="M";

var ceoSchedule ={
		webpartType: '', 
		init: function (data,ext){
			var g_startDate = CFN_GetLocalCurrentDate("yyyy.MM.dd");
			g_year = g_startDate.split(".")[0];			// 전역변수 세팅
			g_month = g_startDate.split(".")[1];		// 전역변수 세팅
			g_day = g_startDate.split(".")[2];			// 전역변수 세팅
			$("#ceoSchedule .btnTypeDefault").attr("href", ext.scheduleURL);

			
			ceoSchedule.moveLeftMonth('');
			$('.btnFold').on('click', function(){
				if($(this).hasClass('active')){
					$(this).removeClass('active');
					$('.tablCalendar').removeClass('active');
					$('.calendarTop').removeClass('active');
					$('.calTopdate').text(g_year + '.' + g_month + '.' + g_day);
					$('.CEOCalendarDetail_Scroll').height(665);
				}else {
					$(this).addClass('active');
					$('.tablCalendar').addClass('active');
					$('.calendarTop').addClass('active');
					$('.calTopdate').text(g_year + '.' + g_month);
					$('.CEOCalendarDetail_Scroll').height(400);
				}		
			});
			
		},
		getCalendar:function(v){
			var sDate = $(".calTopdate").text()+".01";
			var nlastdate = new Date(g_year, g_month, 0);
			var nlastday = nlastdate.getDate();
			var eDate = $(".calTopdate").text()+"."+nlastday;

			$.ajax({
			    url: "/groupware/schedule/getLeftCalendarEvent.do",
			    type: "POST",
			    data: {
			    	"StartDate":sDate.replaceAll(".", "-"),
			    	"EndDate":eDate.replaceAll(".", "-"),
			    	"FolderIDs":''
				},
			    success: function (res) {
			    	if(res.status == "SUCCESS"){
			    		$(res.list).each(function(){
			    			var startDate = this.StartEndDate.split("~")[0];
			    			var endDate = this.StartEndDate.split("~")[1];
			    			
			    			// 향후 수정 필요하다고 생각됨
			    			if(startDate == endDate){
			    				var monthStr = Number(startDate.split("-")[1]);
			    				var dayStr = Number(startDate.split("-")[2]);
			    				
			    				$("#cal_body").find("div[month="+monthStr+"][id="+dayStr+"]").addClass("mark");
			    			}else{
			    				var startDateObj = new Date(replaceDate(startDate));
			    				var endDateObj = new Date(replaceDate(endDate));
			    				
			    				while(startDateObj.getTime() <= endDateObj.getTime()){
			    					var month = startDateObj.getMonth() + 1;
				    				var day = startDateObj.getDate();

			    					$("#cal_body").find("div[month="+month+"][id="+day+"]").addClass("mark");
			    					
			    					startDateObj.setDate(day + 1);
			    				}
			    			}
			    		});
			    		if (v == "") gotoDiaryView(CFN_GetLocalCurrentDate("yyyy.MM.dd"));
			    	} else {
			    		parent.Common.Error(Common.getDic("msg_apv_030"));		// 오류가 발생했습니다.
			    	}
			    },
			    error:function(response, status, error){
			    	parent.CFN_ErrorAjax("/groupware/schedule/getLeftCalendarEvent.do", response, status, error);
			    }
			});
		},
		moveLeftMonth:function(v) {
			if (v == "+") {
				g_month++;
				if (g_month > 12) { g_year++; g_month = 1; }
			} else if (v == "-"){
				g_month--;
				if (g_month < 1) { g_year--; g_month = 12; }
			}
			
			g_month=parseInt(g_month)<10?"0"+parseInt(g_month):g_month;
			$(".calTopdate").text(g_year+"."+g_month);
			makeLeftCalendar();
//			scheduleUser.setLeftCalendarEvent(sDate, eDate);
			ceoSchedule.getCalendar(v);
		}
}

var sessionObj = Common.getSession(); //전체호출
var lang = sessionObj["lang"];
var userCode = sessionObj["USERID"];

// 달력 이동
function gotoDiaryView(date){
	//var folderIDs = _mobile_schedule_common.FolderCheckList;				// 좌측 메뉴 체크 항목
	
	$("#cal_body").find("div[month="+parseInt(g_month)+"][id="+parseInt(g_day)+"]").removeClass("calendarSelected");
	g_year = date.split(".")[0];			// 전역변수 세팅
	g_month = date.split(".")[1];		// 전역변수 세팅
	g_day = date.split(".")[2];			// 전역변수 세팅

	$("#cal_body").find("div[month="+parseInt(g_month)+"][id="+parseInt(g_day)+"]").addClass("calendarSelected");
	
	var importanceState = "";
//	var next_date = schedule_SetDateFormat(schedule_AddDays(date,1),"-");
//	alert(next_date)
	var url = "/groupware/schedule/getView.do";
	$.ajax({
	    url: url,
	    async: false,
	    type: "POST",
	    data: {
	    	"FolderIDs" : '',
	    	"StartDate" : date.replaceAll(".", "-"),
	    	"EndDate" : date.replaceAll(".", "-"),
	    	"UserCode" : userCode,
	    	"lang" : lang,
	    	"ImportanceState" : importanceState,
	    	"hasAnniversary": "Y"
		},
	    success: function (res) {
	    	if(res.status == "SUCCESS"){
	    		var eventData = res.list;
	    		var anniversaryList = res.anniversaryList;
	    		/*
	    		var tempGoogle;
	    		//2019.03 성능개선
	    		if(isConnectGoogle && g_googleFolderID == null){
	    			Common.getBaseConfigList(["ScheduleGoogleFolderID","SchedulePersonFolderID","WorkStartTime","WorkEndTime"]);
	    			g_googleFolderID = coviCmn.configMap["ScheduleGoogleFolderID"];
	    		}
    			// FolderID에 구글 계정 연동 Folder가 체크되었을 경우
    			if(folderCheckList.indexOf(";"+g_googleFolderID + ";") > -1 && isConnectGoogle){
    				tempGoogle = getGoogleEventList(sDate, eDate);
    				if(getGoogleEventList(sDate, eDate) != undefined)
    					resList = resList.concat(getGoogleEventList(sDate, eDate));
    			}
	    		
    			scheduleUser.setAnniversaryData(anniversaryList);
    			*/
	    		if(eventData.length > 0){
	    			var allDayHTML = "";
	    			var dayHTML = '';
	    			
	    			for(var i=0; i<eventData.length; i++){
	    				if(eventData[i] != undefined){
	    					var sDate = eventData[i].StartDate;
	    					var eDate = eventData[i].EndDate;
	    					var sTime = eventData[i].StartTime;
	    					var eTime = eventData[i].EndTime;
	    					var sDateTime = eventData[i].StartDateTime;
	    					var eDateTime = eventData[i].EndDateTime;
	    					var isRepeat = eventData[i].IsRepeat;
	    					var className = "";
	    					
	    					if (isRepeat == 'Y') {
	    						allDayHTML += '<div class="calToolTip">'+coviDic.dicMap["lbl_schedule_repeatSch"]+'</div>';			//반복일정
	    			        }
	    			    	
	    			    	//중요도 및 반복 표시
	    			        if (eventData[i].ImportanceState == 'Y' && isRepeat == 'Y') {
	    			        	className += " rePoint";
	    			        }else if(eventData[i].ImportanceState == 'Y'){
	    			        	className += " point";
	    			        }else if(isRepeat == 'Y'){
	    			        	className += " repeat";
	    			        }
	    					
	    					
	    					// 종일일정
	    					if(sDate != eDate || eventData[i].IsAllDay == "Y"){
	    						allDayHTML += '<div id="allDayData_'+eventData[i].DateID+'" '
	    												+(eventData[i].isGoogle == "Y" ? 'isGoogle="Y"' : '')
	    												+'eventID="'+eventData[i].EventID+'"'
	    												+' dateID="'+eventData[i].DateID+'"'
	    												+' startDateTime="'+sDateTime+'"'
	    												+' endDateTime="'+eDateTime+'"'
	    												+' isRepeat="'+isRepeat+'"'
	    												+' folderID="'+eventData[i].FolderID+'"'
	    												+' registerCode="'+eventData[i].RegisterCode+'"'
	    												+' ownerCode="'+eventData[i].OwnerCode+'"'
	    												+' data-subject="' + eventData[i].Subject + '"'
	    												+' onclick="ceoSchedule.setSimpleViewPopup(this)" class="shcMultiDayText '+className+'" style="width:100%;background:'+eventData[i].Color+'">';
	    						
	    						allDayHTML += '<div>';
	    						
	    						if(eventData[i].IsAllDay != "Y")
	    							allDayHTML += '<span>('+sTime+')</span>';
	    						
	    						allDayHTML += '<span>'+eventData[i].Subject+'</span>';
	    						
	    						if(eventData[i].Place != ""){
	    							allDayHTML += '<span class="locIcon">'+coviDic.dicMap["lbl_schedule_position"]+'</span>';			//위치확인
	    						}
	    						
	    						allDayHTML += '</div>';
	    						
	    						if(isRepeat == "Y")
	    							allDayHTML += '<div class="calToolTip">'+coviDic.dicMap["lbl_schedule_repeatSch"]+'</div>';		//반복일정
	    						
	    						allDayHTML += '</div>';
	    					}
	    					// 시간으로 지정된 일정
	    					else{
	    						// 업무시간으로 체크했을 경우 업무시간 이외의 일정은 제외하기
	    						if(g_isWorkTime){
	    							var sDateTimeObj = new Date(replaceDate(sDateTime)).getTime();
	    							var eDateTimeObj = new Date(replaceDate(eDateTime)).getTime();
	    							
	    							var workSDateTime = new Date(replaceDate(sDate) + " " + AddFrontZero(Number(coviCmn.configMap["WorkStartTime"]), 2) + ":00").getTime();
	    							var workEDateTime = new Date(replaceDate(eDate) + " " + AddFrontZero(Number(coviCmn.configMap["WorkEndTime"]), 2) + ":00").getTime();
	    							
	    							if( (sDateTimeObj >= workSDateTime && sDateTimeObj < workEDateTime)
	    									|| (sDateTimeObj <= workSDateTime && eDateTimeObj >= workEDateTime)
	    									|| (workSDateTime <= eDateTimeObj && eDateTimeObj < workEDateTime) ){
	    								if(eDateTimeObj > workEDateTime){
	    									eDateTime = eDate + " " + AddFrontZero(Number(coviCmn.configMap["WorkEndTime"]), 2) + ":00";
	    								}
	    								if(sDateTimeObj < workSDateTime){
	    									sDateTime = sDate + " " + AddFrontZero(Number(coviCmn.configMap["WorkStartTime"]), 2) + ":00";
	    								}
	    							}else{
	    								continue;
	    							}
	    					    }
	    						
	    						// height 값 구하기
	    						var height = ($(".hourCell").height()+1)*2;// + 1;
	    						var diffMin = schedule_GetDiffDates(new Date(replaceDate(sDateTime)), new Date(replaceDate(eDateTime)), 'min');
	    						var multiHeightVal = diffMin / 30;
	    						var	heightVal = (height/2) * multiHeightVal;

	    						var hh = parseInt(sTime.substring(0,2),10);
	    						var mm = parseInt(sTime.substring(3,4),10);
	    						var topVal =  (height)*(hh) + height*(mm/6);
	    						
	    						dayHTML += '<div class="hourCell shcMultiDayText '+className+'"'
				    						+' style="background:'+eventData[i].Color+'; height:'+heightVal+'px;top:'+topVal+'px;width:100%;overflow:hidden;position: absolute">';
				    						
	    						dayHTML += '<div  id="eventData_'+eventData[i].DateID+'"'
	    											+(eventData[i].isGoogle == "Y" ? 'isGoogle="Y"' : '')
	    											+' eventID="'+eventData[i].EventID+'"'
	    											+' dateID="'+eventData[i].DateID+'"'
	    											+' startDateTime="'+sDateTime+'"'
	    											+' endDateTime="'+eDateTime+'"'
	    											+' isRepeat="'+isRepeat+'"'
	    											+' folderID="'+eventData[i].FolderID+'"'
	    											+' registerCode="'+eventData[i].RegisterCode+'"'
	    											+' ownerCode="'+eventData[i].OwnerCode+'"'
	    											+' data-subject="' + eventData[i].Subject + '"'
	    											+' onclick="scheduleUser.setSimpleViewPopup(this)" >';
	    						
	    						dayHTML += '<span>'+eventData[i].Subject+'</span>';
	    						dayHTML += '<p>'+sTime+'~'+eTime+'</p>';
	    						if(eventData[i].Place != ""){
	    							dayHTML += '<p class="locIcon">'+coviDic.dicMap["lbl_schedule_position"]+'</p>';			//위치확인
	    						}
	    						dayHTML += '</div>';
	    						dayHTML += '</div>';
	    					}
	    				}
	    			}
	    			$("#allDayDataBgDiv").html(allDayHTML);
	    			$("#dayDataDiv").html(dayHTML);
	    		}
	    		else
	    		{
	    			$("#allDayDataBgDiv").html("");
	    			$("#dayDataDiv").html("");
	    		}
	    	} else {
				Common.Error(Common.getDic("msg_apv_030"));		// 오류가 발생했습니다.
			}
        },
        error:function(response, status, error){
			CFN_ErrorAjax("/groupware/schedule/getView.do", response, status, error);
		}
	});
}



