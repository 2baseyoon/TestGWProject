var schAclArray = {};
var sessionObj = Common.getSession(); //전체호출
var lang = sessionObj["lang"];
var userCode = sessionObj["USERID"];
var userMultiName = sessionObj["UR_MultiName"];

var g_isWorkTime = false;			//업무시간 체크 여부

var g_year;
var g_month;
var g_day;
var g_viewType = "M";
var g_currentTime = new Date(CFN_GetLocalCurrentDate("yyyy/MM/dd HH:mm:ss"));

var arrSunday = new Array();

var g_startDate;
var g_endDate;

var g_isPopup = false;
var popObj;

//그리드 및 목록 보기 세팅
var grid = new coviGrid();
//구글연동 목록
var gridGoogle = new coviGrid();

var prevClickIdx  = -1;

var isCanBooking = false;			// 자원 예약이 가능한지 체크.

var updateScheduleDataObj;				// 수정을 위한 temp 데이터

var g_googleFolderID = null;

var g_fileList = null;

var g_editorKind = Common.getBaseConfig('EditorType');

var isCommunity = "";
var schFolderId = "";

// 21.07.26, 일정관리 미리알림 조건 추가.
var flag4AlarmSave = "Y";

var scheduleUser = {
		initJS : function(){
			g_startDate = schedule_SetDateFormat(g_currentTime, '.');
		
			//$('.sSListCol').css('height', $('.specialScheduleTitle').height());
			//$('.weekListCol').css('height', $('.weeklyListTitle').height());
			
			$('#content').off('click').on('click', function(e) {
				if( e.target.classList.value === "cRContBottom mScrollVH" ) return false;
				
				if ($("article[id=read_popup]").html() != '' && !$(e.target).parents().andSelf().is('#read_popup')) {
					$("article[id=read_popup]").html('');
			    }
				if ($("article[id=popup]").html() != '' && !$(e.target).parents().andSelf().is('#popup')) {
					$("article[id=popup]").html('');
			    }
			});
			//개별호출 - 일괄호출
			Common.getBaseConfigList(["ScheduleGoogleFolderID","SchedulePersonFolderID","WorkStartTime","WorkEndTime"]);
			g_googleFolderID = coviCmn.configMap["ScheduleGoogleFolderID"];
			
			
			if(location.href.indexOf("schedule_View.do") < 0){
				scheduleUser.fn_schedule_onload();
			}
			
			if(schAclArray.status != "SUCCESS") {
				scheduleUser.setAclEventFolderData();
			}
			
			if( CFN_GetCookie("useWorkTime_schedule_"+Common.getSession("UR_Code")) != '') {
				g_isWorkTime = coviCmn.getCookie("useWorkTime_schedule_"+Common.getSession("UR_Code")) == 'true';
	        } else {
				g_isWorkTime = (Common.getBaseConfig('useWorkTime') == 'Y');
				coviCmn.setCookie("useWorkTime_schedule_"+Common.getSession("UR_Code"), String(g_isWorkTime), 3);
			}
			
			
		},
		// 일정관리 로드시
		fn_schedule_onload : function(){
			g_isPopup = false;
			popObj = null;
			
			g_viewType = CFN_GetQueryString("viewType");
			g_startDate = CFN_GetQueryString("startDate");
			g_endDate = CFN_GetQueryString("endDate");
			
			if(g_startDate == "undefined" || g_startDate == "" || g_startDate == null){
				g_startDate = XFN_getCurrDate(".");
			}
			if(g_viewType == "undefined" || g_viewType == "" || g_viewType == null){
				g_viewType = "M";
			}
			
			g_year = g_startDate.split(".")[0];			// 전역변수 세팅
			g_month = g_startDate.split(".")[1];		// 전역변수 세팅
			g_day = g_startDate.split(".")[2];			// 전역변수 세팅
			
			if(CFN_GetQueryString("CSMU") != 'C' && CFN_GetQueryString("CSMU") != 'T'){
				$("#calTopDateVal").val(g_year + "." + AddFrontZero(g_month));
				
				if($("#leftCalendar").hasClass("active"))
					$('.calTopdate').text(g_year + '.' + g_month);
				else
					$('.calTopdate').text(g_currentTime.getFullYear() + '.' + AddFrontZero((g_currentTime.getMonth()+1), 2) + '.' + AddFrontZero(g_currentTime.getDate(), 2));
				if(g_viewType != 'Popup') {
					makeLeftCalendar();		// 달력 그리기
				}else {
					Common.getDicList(["lbl_From0","lbl_Atimes","lbl_EveryNumWeek","lbl_RepeteSettingAtoB","lbl_To0",
						"lbl__EveryDays0","lbl_SchEveryday","lbl_EveryNumWeek","lbl_EveryMonthsDays01","lbl_EveryYearOn",
						"lbl_FirstWeek","lbl_SecondWeek","lbl_ThirdWeek","lbl_FourthWeek","lbl_FifthWeek",
						"lbl_Sunday0","lbl_Monday0","lbl_Tuesday0","lbl_Wednesday0","lbl_Thursday0","lbl_Friday0","lbl_Saturday0",
						"lbl_EveryMonthsDays01","lbl_EveryYearOn"]);
				}
			}else{
				getCalendarDic();
			}
			
			isCommunity = CFN_GetQueryString("communityId") == "undefined" ? false : true;
			if(isCommunity){
				schFolderId = CFN_GetQueryString("schFolderId");
			}


		},
		fn_scheduleView_onload : function(){
			scheduleUser.fn_schedule_onload();
			
			window.onresize = scheduleUser.setResizeFunction;
			
			var liID = "";
			if(g_viewType == "M"){
				$("#DayCalendar,#WeekCalendar,#List").hide();
				$("#MonthCalendar").show();
				liID = "liMonth";
			}else if(g_viewType == "D"){
				$("#WeekCalendar,#MonthCalendar,#List").hide();
				$("#DayCalendar").show();
				liID = "liDay";
			}else if(g_viewType == "W"){
				$("#DayCalendar,#MonthCalendar,#List").hide();
				$("#WeekCalendar").show();
				liID = "liWeek";
			}else if(g_viewType == "List"){
				$("#DayCalendar,#WeekCalendar,#MonthCalendar").hide();
				$("#List").show();
				liID = "liList";
			}
			
			$("#topButton").find("li").removeClass("selected");
			$("#"+liID).addClass("selected");
			
			scheduleUser.setSearchControl();
		},
		// 권한에 따른 폴더 데이터 가져오기
		setAclEventFolderData : function(){
			var isCommunity = CFN_GetQueryString("communityId") == "undefined" ? false : true;
			
			/*if (!isCommunity && localCache.exist("schAclArray_" + userCode)) {
				schAclArray = localCache.get("schAclArray_" + userCode);
			} else {*/
				$.ajax({
				    url: "/groupware/schedule/getACLFolder.do",
				    type: "POST",
				    data: {
				    	"isCommunity" : isCommunity
				    },
				    async: false,
				    success: function (res) {
				    	if(res.status == "SUCCESS"){
					
							for(var i = 0; i<res.create.length; i++){
								if(res.create[i].FolderType == 'Folder'){
									res.create.splice(i,1);
									i--;
								}
							}
					
				    		schAclArray = res;
				    		//localCache.set("schAclArray_" + userCode, res, "");
				    	}else{
				    		Common.Error(Common.getDic("msg_apv_030"));		// 오류가 발생했습니다.
				    	}
			        },
			        error:function(response, status, error){
						CFN_ErrorAjax("/groupware/schedule/getACLFolder.do", response, status, error);
					}
				});
			//}
		},
		// Resize에 대한 이벤트 세팅
		setResizeFunction : function(){
			if(g_viewType == "W")
				scheduleUser.setWeekEventDataTopWidth('resize');
			if(g_viewType == "D")
				scheduleUser.setDayEventDataTopWidth('resize');
			if(g_isPopup)
				scheduleUser.setSimpleViewTopLeft(popObj);
		},
		// 오늘로 이동
		goCurrent : function(){
			g_startDate = schedule_SetDateFormat(g_currentTime, ".");
			g_year = g_startDate.split(".")[0];			// 전역변수 세팅
			g_month = g_startDate.split(".")[1];		// 전역변수 세팅
			g_day = g_startDate.split(".")[2];			// 전역변수 세팅
			
			clickTopButton(g_viewType);
		},
		getMonthEventData : function(sDate, eDate){
			// 좌측 메뉴 체크 항목
			var folderIDs = ";";
			for (var i=0; i<folderCheckList.split(";").length; i++) {
 				var val = folderCheckList.split(";")[i];
 				if(val != "" && val != "undefined" && $$(schAclArray).find("view").concat().find("[FolderID="+val+"]").length > 0)
 					folderIDs += val + ";";
			}
			
			folderCheckList = folderIDs;

			// 커뮤니티일 때 폴더 값 세팅
			if(folderIDs == ";" && ( CFN_GetQueryString("CSMU") == 'C' || CFN_GetQueryString("CSMU") == 'T') ){
				folderIDs = ";"+CFN_GetQueryString("schFolderId")+";";
				//2019.09 추가
				folderCheckList = folderIDs;
			}

			sDate = (sDate.length == 10) ? sDate.replaceAll(".", "-") + ' 00:00' : sDate;
			eDate = (eDate.length == 10) ? schedule_SetDateFormat(schedule_AddDays(eDate.replaceAll(".", "-"), 1),'-') + ' 00:00' : eDate;
			
			$.ajax({
			    url: "/groupware/schedule/getView.do",
			    type: "POST",
			    async: false,
			    data: {
			    	"FolderIDs" : folderIDs,
					"StartDate": CFN_TransServerTime(sDate),
					"EndDate": CFN_TransServerTime(eDate),
			    	"lang" : lang,
			    	"ImportanceState" : (type == "import") ? "Y" : "",
			    	"hasAnniversary": "Y"
				},
			    success: function (res) {
			    	if(res.status == "SUCCESS"){
			    		var resList = res.list;
			    		var anniversaryList = res.anniversaryList;
			    		
						$.each(resList, function(idx, el){
							el.StartDateTime = CFN_TransLocalTime(el.StartDateTime, 'yyyy-MM-dd HH:mm');
							el.StartDate = el.StartDateTime.split(' ')[0];
							el.StartTime = el.StartDateTime.split(' ')[1];
							el.EndDateTime = CFN_TransLocalTime(el.EndDateTime, 'yyyy-MM-dd HH:mm');
							el.EndDate = el.EndDateTime.split(' ')[0];
							el.EndTime = el.EndDateTime.split(' ')[1];
							if ($$(schAclArray).find("read").concat().find("[FolderID="+el.FolderID+"]").length == 0){
								if(typeof schAclArray.attendant == 'undefined') schAclArray.attendant = [];
								schAclArray.attendant.push(el);
							}
						});

			    		//var tempGoogle;
			    		//2019.03 성능개선
			    		if(isConnectGoogle && g_googleFolderID == null){
			    			Common.getBaseConfigList(["ScheduleGoogleFolderID","SchedulePersonFolderID","WorkStartTime","WorkEndTime"]);
			    			g_googleFolderID = coviCmn.configMap["ScheduleGoogleFolderID"];
			    		}
		    			// FolderID에 구글 계정 연동 Folder가 체크되었을 경우
		    			if(folderCheckList.indexOf(";"+g_googleFolderID + ";") > -1 && isConnectGoogle){
		    				//tempGoogle = getGoogleEventList(sDate, eDate);
		    				if(getGoogleEventList(sDate, eDate) != undefined)
		    					resList = resList.concat(getGoogleEventList(sDate, eDate));
		    			}
			    		
		    			scheduleUser.setAnniversaryData(anniversaryList);
		    			
		    			if(g_viewType == "M")
		    				scheduleUser.setMonthEventData(resList);
		    			else if(g_viewType == "D")
		    				scheduleUser.setDayEventData(resList);
		    			else if(g_viewType == "W")
		    				scheduleUser.setWeekEventData(resList, sDate, eDate);
		
						if (scheduleUser.params) delete scheduleUser.params;
						if (scheduleUser.origin) delete scheduleUser.origin;
			    	} else {
						Common.Error(Common.getDic("msg_apv_030"));		// 오류가 발생했습니다.
					}
		        },
		        error:function(response, status, error){
					CFN_ErrorAjax("/groupware/schedule/getView.do", response, status, error);
				}
			});
		},
		setAnniversaryData : function(anniversaryList){
			if(anniversaryList != undefined){
				$(anniversaryList).each(function(idx, obj){
					if(obj.AnniversaryType == "General") {
						$("span[name='dayInfo'][value='"+obj.SolarDate+"']").text("("+CFN_GetDicInfo(obj.Anniversary)+")").css("color","blue");
					} else {
						$("span[name='dayInfo'][value='"+obj.SolarDate+"']").text("("+CFN_GetDicInfo(obj.Anniversary)+")").css("color","red");
					}
				});
			}
		},
		setMonthEventData : function(eventData){
			// 주별로 데이터 분리
			var eventArr = new Array();
			var eventObj = new Array();
			var weekDateArr = {};
			
			$(arrSunday).each(function(i, val){
				eventObj = new Array();
				var sDate = val;
				var eDate = schedule_AddDays(val, 6);
				
				$(eventData).each(function(j){
					var isInclude = false;
					var dataStartDate = new Date(this.StartDate.split("-")[0], Number(this.StartDate.split("-")[1])-1, this.StartDate.split("-")[2]);
					var dataEndData = new Date(this.EndDate.split("-")[0], Number(this.EndDate.split("-")[1])-1, this.EndDate.split("-")[2]);
					
					if( schedule_GetDiffDates(sDate, dataStartDate, 'day') <= 0 && schedule_GetDiffDates(eDate, dataEndData, 'day') >= 0 ){ //기준 시간 안에 비교대상이 포함되어 있을 때 
						isInclude = true;
					}else if( schedule_GetDiffDates(sDate, dataStartDate, 'day') < 0 && schedule_GetDiffDates(sDate, dataEndData, 'day') >= 0 && schedule_GetDiffDates(eDate, dataEndData, 'day') <= 0  ){ // 기준 시간 안에 비교대상의 시작점은 포함되엉 있고, 종료점은 넘어가지 않을 때 
						isInclude = true;
					}else if( schedule_GetDiffDates(sDate, dataStartDate, 'day') >= 0 && schedule_GetDiffDates(eDate, dataStartDate, 'day') <= 0 && schedule_GetDiffDates(eDate, dataEndData, 'day') >= 0 ){ // 기준 시간 안에 비교대상의 종료점은 포함되엉 있고, 시작점은 넘어가지 않을 때
						isInclude = true;
					}else if( schedule_GetDiffDates(sDate, dataStartDate, 'day') >= 0 && schedule_GetDiffDates(eDate, dataEndData, 'day') <= 0 ){ //기준 시간이 비교대상에 포함되어 있을 때 
						isInclude = true;
					}
					
					if(isInclude){
						eventObj.push(this);
						//eventData.splice(j, 1);
						return;
					}
				});
				eventArr.push(eventObj);
			});
			
			// 데이터 달력에 그림
			for(var i=0; i<eventArr.length; i++){
				scheduleUser.drawMonthEventData(eventArr[i], arrSunday[i]);
			}
		},
		drawMonthEventData : function(eventDataArr, sunday){
			sunday = schedule_SetDateFormat(sunday, '.');
		    var targetNo = sunday.replace(".", "").replace(".", "");		//targetNo는 table의 고유번호 sunday 값
		    var eventDataHTML = "";
		    var i, j;
		    
		    // 공백 컨텐츠 tr 생성
		    for (i = 0; i < 4; i++) {
		    	var targetNoNextID = i;
		    	var rowNo = i;
		    	if(i == 3){
		    		targetNoNextID = "more";
		    		rowNo = "";
		    	}
		    		
		    	eventDataHTML  += '<tr id="trAlldayBar_'+targetNo+'_'+targetNoNextID+'" RowNo="'+rowNo+'" >';
		        for (j = 0; j < 7; j++) {
		        	var schday = schedule_AddDays(sunday, j);
		            eventDataHTML  += '<td id="tdAlldayBar_'+targetNo+'_'+targetNoNextID+'_'+j+'" Day="'+j+'" schday="'+schedule_SetDateFormat(schday, '.')+'">&nbsp;</td>';
		        }
		        eventDataHTML += '</tr>';
		    }
	
		    $('#tableWeekScheduleForMonth_' + targetNo + ' tbody').append(eventDataHTML);
		    
		    var d;
		    for (d = 0; d < eventDataArr.length; d++) {
		    	eventDataHTML = "";
		    	
		        var strSun = schedule_SetDateFormat(sunday, '/');
		        var g_sun = new Date(strSun);
		        var g_nsun = schedule_AddDays(strSun, 7);
		        var barColor = eventDataArr[d].Color;
		        
		        if (barColor == '' || barColor == null) { barColor = schedule_RandomColor('hex'); }
		        var EventID = eventDataArr[d].EventID;
		        var barImportance = eventDataArr[d].ImportanceState;
		        var barSubject = eventDataArr[d].Subject;
		        var sTime = eventDataArr[d].StartTime;
		        var eTime = eventDataArr[d].EndTime;
		        var sDate = eventDataArr[d].StartDate;
		        var eDate = eventDataArr[d].EndDate;
		        var isRepeat = eventDataArr[d].IsRepeat;
				
		        // 종일/반복처리시 종료일 
		        if (eTime == "00:00" || (eventDataArr[d].IsAllDay == "Y" && isRepeat == "Y")) {
		            if(eDate != sDate) {
		                eDate = schedule_SetDateFormat(schedule_SubtractDays(eDate.replace(/\./gi, '-'), 1), '-');
		            }
		            if (eTime == "00:00") {
		                eTime = "23:59";
		            }
		        }
	
		        var sDateTime = schedule_MakeDateForCompare(sDate, sTime);
		        var eDateTime = schedule_MakeDateForCompare(eDate, eTime);
	
		        var sDay = null; // 시작요일
		        var eDay = null; // 종료요일
		        var tDay = null; // 일정의 길이
		        var preDay = "N"; // 시작일이 일요일 이전
		        var nextDay = "N"; // 종료일이 토요일 이후
		        
	
		        // 하루가 넘는 경우
		        if (sDate != eDate) {
		            if (schedule_GetDiffDates(sDateTime, g_sun, 'day') > 0) { //시작일이 일요일 이전(일요일 부터): 연결 표시 필요
		                sDay = 0;
		                preDay = "Y";
		            } else { // 시작일이 일요일 이후
		                sDay = parseInt(schedule_GetDiffDates(g_sun, sDateTime, 'day'));
		            }
		            if (schedule_GetDiffDates(g_nsun, eDateTime, 'day') > 0) { //종료일이 토요일 이후(토요일까지) : 연결 표시 필요
		                eDay = 6;
		                nextDay = "Y";
		            } else { // 종료일이 토요일 이하
		                eDay = parseInt(schedule_GetDiffDates(g_sun, eDateTime, 'day'))
		            }
		            // 일일 일정
		        } else {
		            sDay = parseInt(schedule_GetDiffDates(g_sun, sDateTime, 'day'));
		            eDay = sDay;
		        }
	
		        tDay = (eDay + 1) - sDay;// 몇개의 요일을 걸치는지.
		        
		        var innerEventHTML = "";
		        var strAddCSS = "";
		        var className = "";
		        var isShowTime = false;
		        if (sDate != eDate || eventDataArr[d].IsAllDay == "Y") {
		        	className = "shcMultiDayText";
		        	strAddCSS = "background-color:"+barColor;
		            if (eventDataArr[d].IsAllDay != "Y") 
		            	isShowTime = true;
		            
		            if(preDay == "Y")
		            	className += " prevLine";
		        	if(nextDay == "Y")
		        		className += " nextLine";
		        		
		        }else{
		        	strAddCSS = "color:"+barColor;
		        	isShowTime = true;
		        	className = "shcDayText";
		        }
		        
		        innerEventHTML += "<div>";
		        if(preDay == "Y" && $(".calMonBody").eq(0).find("[class=calMonWeekRow]").attr("id").split("_")[1] != targetNo){			// 이어지는 날짜의 뒤이고, 첫번째  주가 아닌 경우
					innerEventHTML += '<span class="txt" style="padding-left: 15px;">'+barSubject+'</span>';
		        }
		        else{
		        	//중요도 및 반복 표시
		            if (barImportance == 'Y' && isRepeat == 'Y') {
		            	className += " rePoint";
		            }else if(barImportance == 'Y'){
		            	className += " point";
		            }else if(isRepeat == 'Y'){
		            	className += " repeat";
		            }
		            
			        // 시간 표시
			        if(isShowTime){
			        	innerEventHTML += '<span class="time">' + sTime + '</span>';
			        }
			        innerEventHTML += '<span class="txt">'+barSubject+'</span>';
			        innerEventHTML += '</div>';
			        
			        if (isRepeat == 'Y') {
			        	innerEventHTML += '<div class="calToolTip">'+coviDic.dicMap["lbl_schedule_repeatSch"]+'</div>';			// 반복일정
			        }
		        }
		        
		        eventDataHTML += '<div class="'+className+'" id="eventData_'+eventDataArr[d].DateID+'" style="'+strAddCSS+'" '
		        							+(eventDataArr[d].isGoogle == "Y" ? 'isGoogle="Y"' : '')
		        							+'eventID="'+EventID+'"'
		        							+' dateID="'+eventDataArr[d].DateID+'"'
		        							+' isRepeat="'+isRepeat+'"'
		        							+' repeatID="'+eventDataArr[d].RepeatID+'"'
		        							+' folderID="'+eventDataArr[d].FolderID+'"'
		        							+' registerCode="'+eventDataArr[d].RegisterCode+'"'
		        							+' ownerCode="'+eventDataArr[d].OwnerCode+'"'
		        							+' data-subject="' + eventDataArr[d].Subject + '"'
		        							+' onclick="scheduleUser.setSimpleViewPopup(this, event)">';
		        eventDataHTML += innerEventHTML + '</div>';
		        
		        var targetTrNum = null; // 일정바를 넣을 Tr 번호
		        for (i = 0; i < 3; i++) { // TR looping : 일정바를 넣을 대상 Tr 찾기
		            var targetTdCnt = 0;
		            for(j = sDay; j < (sDay + tDay); j++) { // 해당 Tr의 Td를 검사하여 넣을 수 있는지 확인
		                if ($("#tdAlldayBar_" + targetNo + "_" + i + "_" + j) != null && $("#tdAlldayBar_" + targetNo + "_" + i + "_" + j).html() == "&nbsp;") {
		                    targetTdCnt++;
		                } else {
		                    targetTdCnt = 0; 
		                }
		            }
		            if (targetTdCnt == tDay) { // 대상을 찾은 경우 For문을 빠져나오기.
		                targetTrNum = i;
		                i = 3;    
		            }
		        }
		        // 기본 3개의 Tr에 넣은 경우
		        if (targetTrNum != null) {
		            // 일정이 1일 이상이라면 Td를 삭제하고 대상 일정에 colspan에 걸치는 일정수를 넣어줌.
		            if (tDay > 1) {
		                $("#trAlldayBar_" + targetNo + "_" + targetTrNum).children().each(function(idx, item) {
		                    for (var i = (sDay + 1); i <= eDay; i++) {
		                        if ($(this).attr("id") == "tdAlldayBar_" + targetNo + "_" + targetTrNum + "_" + i) {
		                            $(this).remove();
		                        }
		                    }
		                });
		                $("#tdAlldayBar_" + targetNo + "_" + targetTrNum + "_" + sDay).attr("colspan", tDay);
		            }
		            // 대상 Td에 일정바 삽입.
		            $("#tdAlldayBar_" + targetNo + "_" + targetTrNum + "_" + sDay).html(eventDataHTML);
		            // 기본 3개의 Tr을 모두 사용한 경우 새로 만들어서 넣음.
		        } else {
		            var l_TempScheduleBar = eventDataHTML; //기간바 임시 저장
		            eventDataHTML = "";
		            
		            var l_TargetOffTr = null; // 일정바를 삽입할 Tr ID
		            var l_TargetRowNo = null;
		            $("#divWeekScheduleForMonth_" + targetNo).find(".daybar_off").each(function(idx, item) { //Tr Loop
		                var targetTdCnt = 0;
		                $(this).children().each(function () {  // Tr Loop
		                    if( sDay <= $(this).attr("Day") && eDay >= $(this).attr("Day") && $(this).html() == "&nbsp;") {
		                        targetTdCnt++;
		                    }
		                });
		                if (targetTdCnt == tDay) { // 대상을 찾은 경우 For문을 빠져나오기.
		                    l_TargetOffTr = $(this).attr("id");
		                    l_TargetRowNo = $(this).attr("RowNo");
		                    return false;
		                }
		            });
		            
		            // 추가할 Tr이 없는 경우 새로 생성해서 대상을 찾는다. 
		            if (l_TargetOffTr == null) {
		                var rowNum = $("#divWeekScheduleForMonth_" + targetNo).find(".daybar_off").length + 3;
		                eventDataHTML += '<tr id="trAlldayBar_'+targetNo+'_'+rowNum+'" RowNo="'+rowNum+'" class="daybar_off" style="display:none;" >';
		                for (i = 0; i < 7; i++) {
		                	eventDataHTML += '<td id="tdAlldayBar_'+targetNo+'_'+rowNum+'_'+i+'" Day="'+i+'" schday="'+schedule_SetDateFormat(schday, '.')+'">&nbsp;</td>';
		                }
		                eventDataHTML += '</tr>';
		                
		                $(eventDataHTML).insertBefore("#trAlldayBar_" + targetNo + "_more");
		                $("#divWeekScheduleForMonth_" + targetNo).find(".daybar_off").each(function () { //Tr Loop
		                    var targetTdCnt = 0;
		                    $(this).children().each(function(idx, item) {  // Tr Loop
		                        if( sDay <= $(this).attr("Day") && eDay >= $(this).attr("Day") && $(this).html() == "&nbsp;") {
		                            targetTdCnt++;
		                        }
		                    });
		                    if (targetTdCnt == tDay) { // 대상을 찾은 경우 For문을 빠져나오기.
		                        l_TargetOffTr =  $(this).attr("id");
		                        l_TargetRowNo = $(this).attr("RowNo");
		                        return false;
		                    }
		                });
		            }
	
		            // 일정이 1일 이상이라면 Td를 삭제하고 대상 일정에 colspan에 걸치는 일정수를 넣어줌.
		            if (tDay > 1) {
		                $("#" + l_TargetOffTr).children().each(function(idx, item) {
		                    for (var i = (sDay + 1); i <= eDay; i++) {
		                        if ($(this).attr("id") == "tdAlldayBar_" + targetNo + "_" + l_TargetRowNo + "_" + i) {
		                            $(this).remove();
		                        }
		                    }
		                });
		                $("#tdAlldayBar_" + targetNo + "_" + l_TargetRowNo + "_" + sDay).attr("colspan", tDay);
		            }
		            // 대상 Td에 일정바 삽입.
		            $("#tdAlldayBar_" + targetNo + "_" + l_TargetRowNo + "_" + sDay).html(l_TempScheduleBar);
		        }
		    }
		    
		    // + 표시
	    	var trObj = $("#divWeekScheduleForMonth_"+schedule_SetDateFormat(sunday, ''));
	    	var indexArray = [0, 0, 0, 0, 0, 0, 0];
	    	
	    	$(trObj).find("[class=daybar_off]").each(function(j){
	    		$(this).find('td:not(:not([colspan]))').each(function(){
	    			var colspanTR = $(this);
	    			
	    			var colspanCnt = Number($(colspanTR).attr("colspan"));
		    		var dayInt = Number($(colspanTR).attr("day"));
		    		$(colspanTR).attr("colspan", "");
		    		
		    		for(var i=0; i<colspanCnt-1; i++){
		    			var copyObj = $(colspanTR).clone();
		    			$(copyObj).attr("id", $(colspanTR).attr("id").substring(0,$(colspanTR).attr("id").length-1) + (dayInt + i+1));
		    			$(copyObj).attr("day", (dayInt + i+1  ));
		    			
		    			$(copyObj).insertBefore(colspanTR);
		    		}
	    		});
	    		
	    		$(this).find("td>div").each(function(x){
	    			var index = $(this).parent().index();
	    			++indexArray[index];
	    		});
	    	});
	    	
	    	$(indexArray).each(function(i){
	    		if(this > 0){
	    			$(trObj).find("td[id*=tdAlldayBar][id*=more_"+i+"]").html('<div class="moreShcDayTextView"><a onclick="scheduleUser.MonthShowMore(this);">+'+this+'</a></div>')
	    		}
	    	});
		    
	    	
		    // Drag&Drop jquery ui event 바인딩
		    scheduleUser.setDragNDropEvent();
		},
		//Drag&Drop jquery ui event 바인딩
		setDragNDropEvent : function(){
			if(g_viewType == "M"){
				$("[id^=tdAlldayBar_]").droppable({
					drop: function( event, ui ) {
						// 레이어팝업에서 발생하지않도록 처리
						if($(ui.draggable).hasClass("layer_divpop"))
							return;
						
						var sDate = $(this).parents("tr").eq(0).find("td").eq(Number($(this).attr("day"))).attr("schday").replaceAll(".", "-");
						var eventID = $(ui.draggable).attr("eventID");
						var sTime = $(ui.draggable).find(".time").text();
						
						if(!$(ui.draggable).hasClass("oftSchCard")){
							
							var isRepeat = $(ui.draggable).attr("isRepeat");
							var dateID = $(ui.draggable).attr("dateID");
							var repeatID = $(ui.draggable).attr("repeatID");
							var subject = $(ui.draggable).attr("data-subject");
							
							var tdSize = $(".monShcList tr:eq(0) td:eq(0)").width();
							var evtPos = ui.offset.left - $(".monShcList").offset().left ;
							var evtIdx = Math.floor(evtPos / tdSize);							
							sDate = $(this).parents("tr").eq(0).find("td").eq(evtIdx).attr("schday").replaceAll(".", "-");							

							if(isRepeat == "Y"){
								//TODO 반복 제외시 Event Data 다시 넣는 함수 호출
								Common.Confirm(coviDic.dicMap["msg_changeRepeatEach"],"",function (result){			//반복일정은 수정 시 반복일정에서 제외됩니다.\n수정하시겠습니까?
									if(result){
										scheduleUser.DragNDrop_Update(eventID, dateID, repeatID, sDate, sTime, subject, "RU");
									}else{
										scheduleUser.refresh();
									}
								});
							}else{
								scheduleUser.DragNDrop_Update(eventID, dateID, repeatID, sDate, sTime, subject);
							}
						}else{
							// 자주 쓰는 일정 드래그 드롭 설정
							scheduleUser.templateDragNDrop_Update(eventID, sDate, "00:00", sDate, "00:30");
						}
					}
				});
				
			}else if(g_viewType == "D"){
				$("#gridDataDiv").find("[class^=hourCell]").droppable({
					drop: function( event, ui ) {
						// 레이어팝업에서 발생하지않도록 처리
						if($(ui.draggable).hasClass("layer_divpop"))
							return;
						
						var sDate = g_startDate.replaceAll(".", "-");
						var sTime = $(this).attr("time");
						var eventID = $(ui.draggable).attr("eventID");
						
						if(!$(ui.draggable).hasClass("oftSchCard")){
							
							var isRepeat = $(ui.draggable).attr("isRepeat");
							var dateID = $(ui.draggable).attr("dateID");
							var repeatID = $(ui.draggable).attr("repeatID");
							var subject = $(ui.draggable).attr("data-subject");
							
							if(isRepeat == "Y"){
								//TODO 반복 제외시 Event Data 다시 넣는 함수 호출
								Common.Confirm(coviDic.dicMap["msg_changeRepeatEach"],"",function (result){			//반복일정은 수정 시 반복일정에서 제외됩니다.\n수정하시겠습니까?
									if(result){
										scheduleUser.DragNDrop_Update(eventID, dateID, repeatID, sDate, sTime, subject, "RU");
									}else{
										scheduleUser.refresh();
									}
								});
							}else{
								scheduleUser.DragNDrop_Update(eventID, dateID, repeatID, sDate, sTime, subject);
							}
						}else{
							// 자주 쓰는 일정 드래그 드롭 설정
							var eTime = new Date(new Date(replaceDate(sDate) + " " + sTime).getTime() + (30*60000));
							scheduleUser.templateDragNDrop_Update(eventID, sDate, sTime, sDate, AddFrontZero(eTime.getHours(), 2)+":"+AddFrontZero(eTime.getMinutes(), 2));
						}
					}
				});
			}else if(g_viewType == "W"){
				$(".weeklyListCont .hourCell").droppable({
					accept: 'div[id^=eventData]',
					drop: function( event, ui ) {
						// 레이어팝업에서 발생하지않도록 처리
						if($(ui.draggable).hasClass("layer_divpop"))
							return;
						
						var sTime = $(this).attr("time");
						var sDate;
						var eventID = $(ui.draggable).attr("eventID");
						
						if(sTime == undefined)
							sDate = $(this).attr("date").replaceAll(".", "-");
						else
							sDate = $(this).parent().attr("date").replaceAll(".", "-");
						
						if(!$(ui.draggable).hasClass("oftSchCard")){
							
							var isRepeat = $(ui.draggable).attr("isRepeat");
							var dateID = $(ui.draggable).attr("dateID");
							var repeatID = $(ui.draggable).attr("repeatID");
							var subject = $(ui.draggable).attr("data-subject");
							
							if(isRepeat == "Y"){
								//TODO 반복 제외시 Event Data 다시 넣는 함수 호출
								Common.Confirm(coviDic.dicMap["msg_changeRepeatEach"],"",function (result){			//반복일정은 수정 시 반복일정에서 제외됩니다.\n수정하시겠습니까?
									if(result){
										scheduleUser.DragNDrop_Update(eventID, dateID, repeatID, sDate, sTime, subject, "RU");
									}else{
										scheduleUser.refresh();
									}
								});
							}else{
								scheduleUser.DragNDrop_Update(eventID, dateID, repeatID, sDate, sTime, subject);
							}
						}else{
							// 자주 쓰는 일정 드래그 드롭 설정
							var eTime = new Date(new Date(replaceDate(sDate) + " " + sTime).getTime() + (30*60000));
							scheduleUser.templateDragNDrop_Update(eventID, sDate, sTime, sDate, AddFrontZero(eTime.getHours(), 2)+":"+AddFrontZero(eTime.getMinutes(), 2));
						}
					}
				});
				$(".specialSchedule .hourCell").droppable({
					accept: 'div[id^=allDayData]',
					drop: function( event, ui ) {
						// 레이어팝업에서 발생하지않도록 처리
						if($(ui.draggable).hasClass("layer_divpop"))
							return;
						
						var sTime = $(this).attr("time");
						var sDate;
						var eventID = $(ui.draggable).attr("eventID");
						
						if(sTime == undefined)
							sDate = $(this).attr("date").replaceAll(".", "-");
						else
							sDate = $(this).parent().attr("date").replaceAll(".", "-");
						
						if(!$(ui.draggable).hasClass("oftSchCard")){
							
							var isRepeat = $(ui.draggable).attr("isRepeat");
							var dateID = $(ui.draggable).attr("dateID");
							var repeatID = $(ui.draggable).attr("repeatID");
							var subject = $(ui.draggable).attr("data-subject");
							
							if(isRepeat == "Y"){
								//TODO 반복 제외시 Event Data 다시 넣는 함수 호출
								Common.Confirm(coviDic.dicMap["msg_changeRepeatEach"],"",function (result){			//반복일정은 수정 시 반복일정에서 제외됩니다.\n수정하시겠습니까?
									if(result){
										scheduleUser.DragNDrop_Update(eventID, dateID, repeatID, sDate, sTime, subject, "RU");
									}else{
										scheduleUser.refresh();
									}
								});
							}else{
								scheduleUser.DragNDrop_Update(eventID, dateID, repeatID, sDate, sTime, subject);
							}
						}else{
							// 자주 쓰는 일정 드래그 드롭 설정
							var eTime = new Date(new Date(replaceDate(sDate) + " " + sTime).getTime() + (30*60000));
							scheduleUser.templateDragNDrop_Update(eventID, sDate, sTime, sDate, AddFrontZero(eTime.getHours(), 2)+":"+AddFrontZero(eTime.getMinutes(), 2));
						}
					}
				});
				$("[id^=allDayData_]").draggable({ 
					start : function(event, ui){
						// 권한 체크
						var folderID = $(event.currentTarget).attr("folderid");
						if($(event.currentTarget).attr("isGoogle") != "Y" && ($(event.currentTarget).attr("RegisterCode") != userCode && $(event.currentTarget).attr("OwnerCode") != userCode  && $$(schAclArray).find("modify").concat().find("[FolderID="+folderID+"]").length == 0)){
							Common.Warning(coviDic.dicMap["msg_noModifyACL"]);		//수정 권한이 없습니다.
							return false;
						}
					},
					revert: "invalid" 
				});
			}
			$("[id^=eventData_]").draggable({
				start : function(event, ui){
					$(event.currentTarget).removeAttr("onclick");
					// 권한 체크
					var folderID = $(event.currentTarget).attr("folderid");
					if($(event.currentTarget).attr("isGoogle") != "Y" && ($(event.currentTarget).attr("RegisterCode") != userCode && $(event.currentTarget).attr("OwnerCode") != userCode  && $$(schAclArray).find("modify").concat().find("[FolderID="+folderID+"]").length == 0)){
						Common.Warning(coviDic.dicMap["msg_noModifyACL"]);		//수정 권한이 없습니다.
						$(event.currentTarget).attr("onclick", "scheduleUser.setSimpleViewPopup(this, event)");
						return false;
					}
					// 참석자가 승인한 개인일정 권한 체크
					if($(event.currentTarget).attr("OwnerCode") == userCode){
						if($(event.currentTarget).attr("RegisterCode") != userCode){
							Common.Warning(coviDic.dicMap["msg_noModifyACL"]);		//수정 권한이 없습니다.
							$(event.currentTarget).attr("onclick", "scheduleUser.setSimpleViewPopup(this, event)");
							return false;
						}
					}	
				},
				stop: function(event, ui){
					$(event.target).attr("onclick", "scheduleUser.setSimpleViewPopup(this, event)");
				},
				revert: "invalid" 
			});
		    $(".moreShcDayTextView>a").draggable({
		    	containment: "parent",
		    	start : function(event, ui){
		    		return false;
		    	}	
		    });
			
		},
		//Selectable jquery ui event 바인딩
		setSelectableEvent : function(){
		    var cellHight = $(".hourCell").height()+1;
		   
			if(g_viewType == "M"){
				$( ".calMonBody" ).selectable({
			        filter:'td',
			        selecting: function( event, ui ) {
			        	/*// 월간 보기에서 시작일과 종료일이 다른 주일 경우 그 주 나머지 색칠하기
			        	
			        	var selectObj = $(this).find(".ui-selecting[id=monthDate]");
			        	var startPoint = $(selectObj).eq(0);
			        	var endPoint = $(selectObj).eq($(selectObj).length-1);
			        	var startParent = $(startPoint).parent().parent().parent().parent();
			        	var endParent = $(endPoint).parent().parent().parent().parent();
			        	
			        	if($(startParent).get(0) != $(endParent).get(0)){
			        		$(startPoint).nextAll().addClass("ui-selecting");
			        		$(endPoint).prevAll().addClass("ui-selecting");
			        	}
			        	
			        	// 선택된 부분 이외에 색칠된 부분 제외하기
			        	
			        	$(".ui-selectable-helper").hide();*/
			        },
			        stop: function( event, ui ) {
			            var selectObj=$(this).find(".ui-selected[id=monthDate]");
			            
			            if(selectObj.length == 0)
			            	selectObj = $(this).find(".ui-selected");
			            
			            var sDate = $(selectObj).eq(0).attr("schday");
			 	        var eDate = $(selectObj).eq($(selectObj).length-1).attr("schday");
			            
						var diffDate = schedule_GetDiffDates(new Date(replaceDate(sDate)), new Date(replaceDate(eDate)), 'day');
						
						for(var i = 1; i < diffDate; i++){
							var midDate = schedule_SetDateFormat(schedule_AddDays(sDate, i),".");
							
							$("[id=monthDate][schDay='"+ midDate + "']").addClass("ui-selected");
						}
			 	        
			            var posX = event.pageX - $(".cRContBottom").offset().left;
				        var posY = event.pageY - ($(".cRContBottom").offset().top - $(".cRContBottom").scrollTop());
			            
			            $("#popup").load("/groupware/schedule/getSimpleWriteView.do", function(){
			            	if ($("article[id=read_popup]").html() != '') $("article[id=read_popup]").html('');
			            	
			            	// coviFile.fileInfos 초기화
							coviFile.files.length = 0;
							coviFile.fileInfos.length = 0;
			            	
			            	// Top과 Left 세팅
			            	if(CFN_GetQueryString("communityId") != "undefined"){
			            		posX += $(".individualLeftCont").innerWidth();
			            		posY += 370;
			            		
				            	if(posX > ($("#content").innerWidth() - $(".individualLeftCont").innerWidth())){
					            	posX = $("#content").innerWidth() - $(".individualLeftCont").innerWidth();
					            }
				            	if(posY > ($(".individualCommunity").height() - $("#simpleWritePop").height() - ($("#portContent").height() - $("#content").height()) + 2)){
					            	posY = $(".individualCommunity").height() - $("#simpleWritePop").height() - ($("#portContent").height() - $("#content").height()) + 2;
					            }
			            	}else{
				            	if(posX > ($(".cRContBottom").width() - ($("#simpleWritePop").width() + 52 + 20))){
					            	posX = $(".cRContBottom").width() - ($("#simpleWritePop").width() + 52 + 20);
					            }
					            if(posY > ($(".scheduleContent").height() - ($("#simpleWritePop").height() + 2))){
					            	posY = $(".scheduleContent").height() - ($("#simpleWritePop").height() + 2);
					            }
			            	}
			            	
			            	$("#popup").css("left", posX+"px");
			            	$("#popup").css("top", posY+"px");
			            	
							if(sDate == undefined){
								sDate = $(selectObj).children(".day_info").attr("value").replaceAll("-",".");
								eDate = sDate;
							}
							
							//일시 세팅 후 disable
			            	scheduleUser.setFolderType('S');
			            	scheduleUser.setStartEndDateTime('S', sDate, eDate);
			            	scheduleUser.setResourceList();
			            });
			        }
			    });
			}else if(g_viewType == "D"){
				$( "#gridDataDiv" ).selectable({
			        filter:'div',
			        stop: function( event, ui ) {
			            var selectObj=$(this).find('.ui-selected');
			            var start = $(selectObj).eq(0);
			            var end = $(selectObj).eq(selectObj.length-1);
			            
			            var topDefault = pxToNumber($(".scheduleTop").css("height")) + pxToNumber($(".weeklyTitle").css("height")) + pxToNumber($("#DayCalendar .specialSchedule").css("height")) + pxToNumber($(".scheduleTop").css("padding-top"));
			            
			            var posX = $(end).offset().left - $(".cRContBottom").offset().left;
			            var posY = $(end).offset().top - $(".cRContBottom").offset().top + pxToNumber($(".gridWrapper div:first-child div").css("height"));
			            
			            $("#hidIsAllDay").val("N");
			            
			            $("#popup").load("/groupware/schedule/getSimpleWriteView.do", function(){
			            	if ($("article[id=read_popup]").html() != '') $("article[id=read_popup]").html('');
			            	
			            	// coviFile.fileInfos 초기화
							coviFile.files.length = 0;
							coviFile.fileInfos.length = 0;
			            	
			            	// Top과 Left 세팅
			            	if(CFN_GetQueryString("communityId") != "undefined"){
			            		posX += $(".individualLeftCont").innerWidth();
			            		posY += 370;
			            		
				            	if(posX > ($("#content").innerWidth() - $(".individualLeftCont").innerWidth())){
					            	posX = $("#content").innerWidth() - $(".individualLeftCont").innerWidth();
					            }
					            if(posY > ($(".individualCommunity").height() - $("#simpleWritePop").height() - ($("#portContent").height() - $("#content").height()) + 2)){
					            	posY = $(".individualCommunity").height() - $("#simpleWritePop").height() - ($("#portContent").height() - $("#content").height()) + 2;
					            }
			            	}else{
				            	if(posX > ($(".cRContBottom").width() - ($("#simpleWritePop").width() + 52 + 20))){
				            		posX = $(".cRContBottom").width() - ($("#simpleWritePop").width() + 52 + 20);
				           		}
			            		if(posY > ($(".scheduleContent").height() - ($("#simpleWritePop").height() + 2))){
			            			posY = ((cellHight * Number($(start).attr("number"))) - ($("#simpleWritePop").height() + 2)) + topDefault;
				            	}
			            	}
			            	
			            	$("#popup").css("left", posX+"px");
			            	$("#popup").css("top", posY+"px");
			            	//일시 세팅 후 disable
			            	scheduleUser.setFolderType('S');
			            	
			            	
			            	var endTime = "";

			            	if($(end).next().attr("time") == undefined || !$(end).next().hasClass("hourCell")){
			            		if(g_isWorkTime){
			            			if(coviCmn.configMap["WorkEndTime"] != ""){
			            				endTime = Number(coviCmn.configMap["WorkEndTime"])+":00";
			        			    }else{
				            			endTime = "23:59";
				            		}
			            		}else{
			            			endTime = "23:59";
			            		}
			            	}else{
			            		endTime = $(end).next().attr("time");
			            	}
			            	scheduleUser.setStartEndDateTime('S', g_startDate, g_startDate, false, $(start).attr("time"), endTime);
			            	scheduleUser.setResourceList();
			            });
			        }
			    });
			}else if(g_viewType == "W"){
				$( "[id^=gridDataDiv_" ).selectable({
			        filter:'div',
			        start: function( event, ui ) {
			        	$("[class*=ui-selected]").removeClass("ui-selected");
			        },
			        stop: function( event, ui ) {
			        	var selectObj=$(this).find('.ui-selected');
			        	var sDate = $(selectObj.context).attr("date");
			            var start = $(selectObj).eq(0);
			            var end = $(selectObj).eq(selectObj.length-1);
			            
			            var topDefault = pxToNumber($(".scheduleTop").css("height")) + pxToNumber($(".weeklyTitle").css("height")) + pxToNumber($("#WeekCalendar .specialSchedule").css("height")) + pxToNumber($(".scheduleTop").css("padding-top"));
			            
			            var posX = $(end).offset().left - $(".cRContBottom").offset().left;
			            var posY = $(end).offset().top - $(".cRContBottom").offset().top + pxToNumber($(".gridWrapper div:first-child div").css("height"));
			            
			            $("#hidIsAllDay").val("N");
			            
			            $("#popup").load("/groupware/schedule/getSimpleWriteView.do", function(){
			            	if ($("article[id=read_popup]").html() != '') $("article[id=read_popup]").html('');
			            	
			            	// coviFile.fileInfos 초기화
							coviFile.files.length = 0;
							coviFile.fileInfos.length = 0;
			            	
			            	// Top과 Left 세팅
			            	if(CFN_GetQueryString("communityId") != "undefined"){
			            		posX += $(".individualLeftCont").innerWidth();
			            		posY += 370;
			            		
				            	if(posX > ($("#content").innerWidth() - $(".individualLeftCont").innerWidth())){
					            	posX = $("#content").innerWidth() - $(".individualLeftCont").innerWidth();
					            }
				            	if(posY > ($(".individualCommunity").height() - $("#simpleWritePop").height() - ($("#portContent").height() - $("#content").height()) + 2)){
					            	posY = $(".individualCommunity").height() - $("#simpleWritePop").height() - ($("#portContent").height() - $("#content").height()) + 2;
					            }
			            	}else{
			            		if(posX > ($(".cRContBottom").width() - ($("#simpleWritePop").width() + 52 + 20))){
					            	posX = $(".cRContBottom").width() - ($("#simpleWritePop").width() + 52 + 20);
					            }
				            	if(posY > ($(".scheduleContent").height() - ($("#simpleWritePop").height() + 2))){
				            		posY = ((cellHight * Number($(start).attr("number"))) - ($("#simpleWritePop").height() + 2)) + topDefault;
					            }
			            	}
			            	
			            	$("#popup").css("left", posX+"px");
			            	$("#popup").css("top", posY+"px");
			            	
			            	//일시 세팅 후 disable
			            	scheduleUser.setFolderType('S');
			            	if(g_isWorkTime){
		            			if(coviCmn.configMap["WorkEndTime"] != ""){
		        			    	var endTime = Number(coviCmn.configMap["WorkEndTime"])+":00";
		        			    	scheduleUser.setStartEndDateTime('S', sDate, sDate, false,$(start).attr("time"), ($(end).next() == undefined || !$(end).next().hasClass("hourCell"))  ? endTime	 : $(end).next().attr("time"));
		        			    }else{
		        			    	scheduleUser.setStartEndDateTime('S', sDate, sDate, false,$(start).attr("time"), ($(end).next() == undefined || !$(end).next().hasClass("hourCell"))  ? "23:59" : $(end).next().attr("time"));
			            		}
		            		}else{
		            			scheduleUser.setStartEndDateTime('S', sDate, sDate, false,$(start).attr("time"), ($(end).next() == undefined || !$(end).next().hasClass("hourCell"))  ? "23:59" : $(end).next().attr("time"));
		            		}
			            	scheduleUser.setResourceList();
			            });
			        }
			    });
			}
		},
		//종일일정에서 일정 작성하기
		// 주간/일간만
		setSimpleWritePopupAllDay : function(obj){
			var cellHight = $(".hourCell").height()+1;
			var sDate = $(obj).attr("date");
			
			var posX = $(obj).offset().left - $(".cRContBottom").offset().left;
			var posY = 0;
			
			$("#hidIsAllDay").val("Y");
			
			if(g_viewType == "D"){
				$("#allDayDataBgDiv").find("[class=gridWrapperLine]>div").css("background", "");
				
				posY = $(".scheduleTop").height() + pxToNumber($(".scheduleTop").css("padding-top")) + $("#weekHeaderDay").height() + 13 + (cellHight * ($(obj).parent().parent().parent().parent().index() + 1));
				sDate = g_startDate;
			}
			else if(g_viewType == "W"){
				$("#allDayWeekDataBgDiv").find("[class=gridWrapperLine]>div").css("background", "");
				
				posY = $(".scheduleTop").height() + pxToNumber($(".scheduleTop").css("padding-top")) + $("#weekHeader").height() + 13 + (cellHight * ($(obj).parent().parent().parent().parent().index() + 1));
			}
			$(obj).css("background", "#e7faff");
			
			$("#popup").load("/groupware/schedule/getSimpleWriteView.do", function(){
				if ($("article[id=read_popup]").html() != '') $("article[id=read_popup]").html('');
				
				// coviFile.fileInfos 초기화
				coviFile.files.length = 0;
				coviFile.fileInfos.length = 0;
				
            	if(CFN_GetQueryString("communityId") != "undefined"){
            		posX += $(".individualLeftCont").innerWidth();
            		posY += 370;
            		
	            	if(posX > ($("#content").innerWidth() - $(".individualLeftCont").innerWidth())){
		            	posX = $("#content").innerWidth() - $(".individualLeftCont").innerWidth();
		            }
	            	if(posY > ($(".individualCommunity").height() - $("#simpleWritePop").height() - ($("#portContent").height() - $("#content").height()) + 2)){
		            	posY = $(".individualCommunity").height() - $("#simpleWritePop").height() - ($("#portContent").height() - $("#content").height()) + 2;
		            }
            	}else{
            		if(posX > ($(".cRContBottom").width() - ($("#simpleWritePop").width() + 52 + 20))){
    	            	posX = $(".cRContBottom").width() - ($("#simpleWritePop").width() + 52 + 20);
    	            }
            	}
				
            	$("#popup").css("left", posX+"px") ;
            	$("#popup").css("top", posY+"px");
            	
            	//일시 세팅 후 disable
            	scheduleUser.setFolderType('S');
            	scheduleUser.setStartEndDateTime('S', sDate, sDate, true, "00:00", "23:59");
            	scheduleUser.setResourceList();
            });
		},
		// DragNDrop 데이터 Update
		DragNDrop_Update : function(eventID, dateID, repeatID, sDate, sTime, subject, setType){
			if(Number(eventID)){
				$.ajax({
				    url: "/groupware/schedule/setDateDataByDragDrop.do",
				    type: "POST",
				    data: {
				    	"setType" : setType,
				    	"Subject" : subject,
				    	"EventID" : eventID,
				    	"DateID" : dateID,
				    	"RepeatID": repeatID,
				    	"StartDate" : sDate,
				    	"StartTime" : sTime
					},
				    success: function (res) {
				    	if(res.status == "SUCCESS"){
				    		if(g_viewType == "M"){
								schedule_MakeMonthCalendar();
							}else if(g_viewType == "D"){
								scheduleUser.schedule_MakeDayCalendar();
							}else if(g_viewType == "W"){
								scheduleUser.schedule_MakeWeekCalendar();
							}
				    	} else if(res.status == "DUPLICATION") {
				    		Common.Warning(res.Message);
				    		if(g_viewType == "M"){
								schedule_MakeMonthCalendar();
							}else if(g_viewType == "D"){
								scheduleUser.schedule_MakeDayCalendar();
							}else if(g_viewType == "W"){
								scheduleUser.schedule_MakeWeekCalendar();
							}
				    	} else {
							Common.Error(Common.getDic("msg_apv_030"));		// 오류가 발생했습니다.
						}
			        },
			        error:function(response, status, error){
						CFN_ErrorAjax("/groupware/schedule/setDateDataByDragDrop.do", response, status, error);
					}
				});
				
			}else{
				// Alert 팝업이 있는 경우 발생하지않도록 처리
				if($("#AlertLayer").length > 0) return false;
				
				Common.Confirm(Common.getDic("msg_changeGoogleSch"), "", function(result){		//"구글 캘린더에 있는 일정이 수정됩니다.\n수정하시겠습니까?"
					if(result){
						coverGoogleEventForDragNDrop(eventID, dateID, sDate, sTime);
					}
				});
			}
		},
		// 일간 그리기
		schedule_MakeDayCalendar : function(){
			// 상단 제목 날짜 표시
			$('#dateTitle').html(g_year + "." + g_month + "." + g_day);
			
			// 헤더에 오늘 날짜
			var headerTodayDateHTML = "";
			
			var dateObj = new Date(g_year, g_month-1, g_day);
			
			var headerDay = g_day;
			var headerWeekOfDay = schedule_GetWeekDay(dateObj);
			var headerLunarMon;
			var headerLunarDay;
			var i;
			
			headerTodayDateHTML += '<span>'+headerDay+'</span> '+headerWeekOfDay;
			headerTodayDateHTML += '<span name="dayInfo" value="' +schedule_SetDateFormat(dateObj, '-')+ '" class="inDate"></span>';
			//headerTodayDateHTML += '<span class="inDate">('+Common.getDic("lbl_sch_lunar")+' '+headerLunarMon+'/'+headerLunarDay+')</span>'; TODO 기념일 없을 경우 음력
			
			$("#headerTodayDate").html(headerTodayDateHTML);
			
			// 월간 달력 그리기(달력의 바닥을 그림)
		    
			// 종일
			var allDayHTML = '<table class="weeklySpecialTbl"><tbody>';
			
			// 기본 2개의 div
			for(i = 0; i<2; i++){
				allDayHTML += '<tr class="grid"><td><div class="gridWrapper"><div class="gridWrapperLine"><div class="hourCell" onclick="scheduleUser.setSimpleWritePopupAllDay(this);"></div></div></div></td></tr>';
		    }
			allDayHTML += '</tbody></table>';
			$("#allDayDataBgDiv").html(allDayHTML);
			
			var backHTML = '';
		    
		    // 업무시간으로 체크되었을 경우
			 var timeStart = 0;
			 var timeEnd = 24;
			
			 if(g_isWorkTime){
			    if(coviCmn.configMap["WorkStartTime"] != ""){
			    	timeStart = Number(coviCmn.configMap["WorkStartTime"]);
			    }
			    if(coviCmn.configMap["WorkEndTime"] != ""){
			    	timeEnd = Number(coviCmn.configMap["WorkEndTime"]);
			    }
		    }
			 
		    var divCount = 0;
		    //개별호출 - 일괄호출
		    Common.getDicList(["lbl_Hour"]);
		    // 왼쪽 시간
		    for(i = timeStart; i<timeEnd; i++){
		    	backHTML += '<p id="time_'+i+'">'+i+ coviDic.dicMap["lbl_Hour"]+'</p>';
		    	++divCount;
		    }
		    $("#dayDataBgDiv").html(backHTML);
		    
		    
		    // 가운데 내용
		    var bodyHTML = '<table class="weeklyTbl "><tbody><tr class="grid"><td><div class="gridWrapper">';
		    bodyHTML += '<div id="gridDataDiv" class="gridWrapperLine">';
		    
		    for(i = timeStart*2; i<(timeEnd)*2; i++){
		    	var tempDate = new Date(new Date(replaceDate(g_startDate)).getTime() + (i*30*60000));
		    	var hour = AddFrontZero(tempDate.getHours(), 2);
		    	var min = AddFrontZero(tempDate.getMinutes(), 2);
		    	var time = hour + ":"+min;
		    	
		    	bodyHTML += '<div class="hourCell" time="'+time+'" number="'+i+'"></div>';
		    }
		    bodyHTML += '</div>';
		    bodyHTML += '<div class="schTimeLine" style="z-index:80"></div>';
		    bodyHTML += '</td></tr></tbody></table>';
	
		    $("#dayDataDiv").html(bodyHTML);
		    
		    
		    // 현재 날짜 표시
		    if(g_startDate == schedule_SetDateFormat(g_currentTime, ".")){
		    	var totalDivHeight = ($(".hourCell").height() + 1) * divCount * 2;
		    	
		    	var currHour = g_currentTime.getHours();
			    var currMin = g_currentTime.getMinutes();
			    
			    if(g_isWorkTime){
			    	currHour = currHour - Number(coviCmn.configMap["WorkStartTime"]);
			    	
			    	if(currHour < 0)
			    		$(".schTimeLine").hide();
			    }
			    
			    var currTop = (totalDivHeight / (divCount * 4)) * ((currHour * 4) + (currMin / 15));
			    $(".schTimeLine").css("top", currTop+"px");
		    }else{
		    	$(".schTimeLine").hide();
		    }
		   
		    //데이터 조회하여 그림
		    var sDate = g_startDate.replaceAll(".", "-");
		    var eDate = g_endDate.replaceAll(".", "-");
		    
		    if(g_isWorkTime){
		    	sDate = sDate + " " + AddFrontZero(timeStart, 2) + ":00";
		    	eDate = eDate + " " + AddFrontZero(timeEnd, 2) + ":00";
		    }
		    	
		    scheduleUser.getMonthEventData(sDate, eDate);
		    
		    //Selectable jquery ui event 바인딩
		    scheduleUser.setSelectableEvent();
			
			if(g_isWorkTime) {
				$("#chkWorkTimeDay").attr("checked", "checked");
			}
		},
		// 일간 데이터로 그리기
		setDayEventData : function(eventData){
			var allDayHTML = "";
			var dayHTML = '';
			$(".cRContBottom").append('<article id="read_popup" style="position: absolute;"></article>');
			
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

					// 종일/반복처리시 종료일 
			        if (eTime == "00:00" || (eventData[i].IsAllDay == "Y" && isRepeat == "Y")) {
			            if(eDate != sDate) {
			                eDate = schedule_SetDateFormat(schedule_SubtractDays(eDate.replace(/\./gi, '-'), 1), '-');
			            }
			            if (eTime == "00:00") {
			                eTime = "23:59";
			            }
			        }

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
												+' repeatID="'+eventData[i].RepeatID+'"'
												+' startDateTime="'+sDateTime+'"'
												+' endDateTime="'+eDateTime+'"'
												+' isRepeat="'+isRepeat+'"'
												+' folderID="'+eventData[i].FolderID+'"'
												+' registerCode="'+eventData[i].RegisterCode+'"'
												+' ownerCode="'+eventData[i].OwnerCode+'"'
												+' data-subject="' + eventData[i].Subject + '"'
												+' onclick="scheduleUser.setSimpleViewPopup(this, event)" class="shcMultiDayText '+className+'" style="width:100%;background:'+eventData[i].Color+'">';
						
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
						var heightVal = $(".hourCell").height() + 1;
						var diffMin = schedule_GetDiffDates(new Date(replaceDate(sDateTime)), new Date(replaceDate(eDateTime)), 'min');
						
						var multiHeightVal = diffMin / 30;
						if(multiHeightVal >= 1){
							heightVal = heightVal * multiHeightVal;
						}
						
						dayHTML += '<div id="eventData_'+eventData[i].FolderID+'_'+eventData[i].DateID+'"'
											+(eventData[i].isGoogle == "Y" ? 'isGoogle="Y"' : '')
											+' eventID="'+eventData[i].EventID+'"'
											+' dateID="'+eventData[i].DateID+'"'
											+' repeatID="'+eventData[i].RepeatID+'"'
											+' startDateTime="'+sDateTime+'"'
											+' endDateTime="'+eDateTime+'"'
											+' isRepeat="'+isRepeat+'"'
											+' folderID="'+eventData[i].FolderID+'"'
											+' registerCode="'+eventData[i].RegisterCode+'"'
											+' ownerCode="'+eventData[i].OwnerCode+'"'
											+' data-subject="' + eventData[i].Subject + '"'
											+' class="shcMultiDayText '+className+'"'
											+' onclick="scheduleUser.setSimpleViewPopup(this, event)" style="background:'+eventData[i].Color+'; height:'+heightVal+'px;overflow:hidden;">';
						dayHTML += '<div>';
						dayHTML += '<span>'+sTime+'~'+eTime+'</span>'+'<span>'+eventData[i].Subject+' '+'</span>';
						if(eventData[i].Place != ""){
							dayHTML += '<span class="locIcon">'+coviDic.dicMap["lbl_schedule_position"]+'</span>';			//위치확인
						}
						if(eventData[i].Place != ""){
							dayHTML += '<p>'+eventData[i].Place+'</p>';
						}
						dayHTML += '</div>';
						dayHTML += '</div>';
					}
				}
			}
			
			$("#allDayDataBgDiv").append(allDayHTML);
			$("#dayDataDiv").append(dayHTML);
			
			// Top, Wigth 세팅
			scheduleUser.setDayEventDataTopWidth('load');
		},
		// 일간 데이터 Top, Wigth 세팅
		setDayEventDataTopWidth : function(mode){
			var $positionTarget = $("#allDayDataBgDiv .weeklySpecialTbl .hourCell:first");
			var dayWidth = $positionTarget.width();
				
			if (mode == 'load'){			// 종일 일정 load
				$("#allDayDataBgDiv .weeklySpecialTbl tbody tr:last").addClass('last');			// 종일 일정 영역의 마지막에 last 클래스 추가. 라인추가여부에 활용
				
				var allDayEvent = $("[id^=allDayData_]");
				$.each(allDayEvent, function(idx, el){
					$(el).css({ padding: 0 });
					
					$.each($("#allDayDataBgDiv .grid .hourCell"), function(index, ele){		// 일정의 시작일에 해당하는 div를 가져와서 표시여부 확인
						var isFinished = false;
						if ($(ele).attr('data-event-id') == undefined){			// div에 data-event-id 값이 없으면 표시 내용없음.
							if ($(ele).closest('tr').hasClass('last')) {		// 표시내용 표시 전 마지막 열인 경우 신규라인 추가 및 초기화
								$(ele).closest('tr').removeClass('last');
								$("#allDayDataBgDiv .weeklySpecialTbl tbody").append($("#allDayDataBgDiv .weeklySpecialTbl tbody tr:first").clone(true));
								$("#allDayDataBgDiv .weeklySpecialTbl tbody tr:last").addClass('last');
								$("#allDayDataBgDiv .weeklySpecialTbl tbody tr:last .hourCell").removeAttr("data-event-id"); 
							}
							
							$(el).css({top: $(ele).closest('td').position().top});		// 일정의 top, left 속성을 div 위치를 참고하여 이동
							$(ele).attr('data-event-id', el.id);		// div에 event-id를 마킹
							
							isFinished = true;							// 루프를 종료
						}
						if (isFinished) return false;
					});
				});	
			}
			
			var dayEvent = $("[id^=eventData_]");
			var seDateTimeArr = new Array();
			
			$.each(dayEvent, function(idx, el){				
				$(el).css({ padding: 0 });
				var eventStartDatetime = $(el).attr('startdatetime').split('-').join('.').split(' ');
				var eventEndDatetime = $(el).attr('enddatetime').split('-').join('.').split(' ');
				
				var divCount = $("[id^=time_]").length;
				var totalDivHeight = ($(".hourCell").height() + 1) * divCount * 2;
				var dateObj = new Date(replaceDate(eventStartDatetime));
			    
				var sHour = dateObj.getHours();
				var sMin = dateObj.getMinutes();
				
				// 업무시간 체크했을 때 해당위치부터 그리기
				if(g_isWorkTime){
				    if(coviCmn.configMap["WorkStartTime"] != ""){
				    	sHour = dateObj.getHours() - Number(coviCmn.configMap["WorkStartTime"]);
				    }
				}

				var seDateTimeObj = {};
			    
			    seDateTimeObj.start = eventStartDatetime;
				if(sMin < 30){	//30분 넘지 않을때 정각으로 맞춤
					var tempEndDate = new Date(new Date(replaceDate(eventStartDatetime)).getTime() - sMin*60000); 
			    	seDateTimeObj.start = schedule_SetDateFormat(tempEndDate, '.') + " " +tempEndDate.getHours() + ":"+tempEndDate.getMinutes();
					var hour = tempEndDate.getHours();
					var min = tempEndDate.getMinutes();
					
					if((hour+"").length < 2){
						hour="0"+hour;
					}
					if((min+"").length < 2){
						min="0"+min;
					}
					
					seDateTimeObj.start = schedule_SetDateFormat(tempEndDate, '.') + " " +hour + ":"+min;
					
					var startTarget = seDateTimeObj.start.split(" ");
					// 시간별 일정을 확인하여, 해당 시간영역에 일정 수 합산
					var $targetDatetime = $("#dayDataDiv div[time='"+startTarget[1]+"']");
					if (typeof $targetDatetime.attr("data-event-cnt") == 'undefined') {
						$targetDatetime.attr("data-event-cnt", 0);
						$targetDatetime.attr("data-event-date", startTarget[0].split('.').join('-'));
						$targetDatetime.addClass("hasEvent");
					}
					
					var eventCnt = Number($targetDatetime.attr("data-event-cnt"))
					if (mode == 'load') $targetDatetime.attr("data-event-cnt", ++eventCnt);
					
					// 일정을 해당 시간 영역의 위치로 이동 한 후 일정에 시간영역을 마킹. 어러개의 시간영역에 걸쳐있는 경우 모두 마킹됨
					var currTop = (totalDivHeight / (divCount * 4)) * ((sHour * 4) + (sMin / 15));
					var targetleft = $("#dayDataBgDiv").width()
					$(el).css({top: currTop, left: targetleft});
					$(el).addClass("target_"+$targetDatetime.attr("number"));
					
					var isContinue = true;
					if ($targetDatetime.next().length > 0 && isContinue && mode == 'load') {			// 로드할때, 시간 영역 및 이벤트에 관련 정보 마킹
						setNext($targetDatetime.next(), eventStartDatetime, eventEndDatetime, $(el));
					}
				}
				
				if(sMin >= 30){
					var tempEndDate = new Date(new Date(replaceDate(eventStartDatetime)).getTime() - sMin*60000 + 30*60000); 
			    	seDateTimeObj.start = schedule_SetDateFormat(tempEndDate, '.') + " " +tempEndDate.getHours() + ":"+tempEndDate.getMinutes();
					var hour = tempEndDate.getHours();
					var min = tempEndDate.getMinutes();
					
					if((hour+"").length < 2){
						hour="0"+hour;
					}
					if((min+"").length < 2){
						min="0"+min;
					}
					
					seDateTimeObj.start = schedule_SetDateFormat(tempEndDate, '.') + " " +hour + ":"+min;
					
					var startTarget = seDateTimeObj.start.split(" ");
					// 시간별 일정을 확인하여, 해당 시간영역에 일정 수 합산
					var $targetDatetime = $("#dayDataDiv div[time='"+startTarget[1]+"']");
					if (typeof $targetDatetime.attr("data-event-cnt") == 'undefined') {
						$targetDatetime.attr("data-event-cnt", 0);
						$targetDatetime.attr("data-event-date", startTarget[0].split('.').join('-'));
						$targetDatetime.addClass("hasEvent");
					}
					
					var eventCnt = Number($targetDatetime.attr("data-event-cnt"))
					if (mode == 'load') $targetDatetime.attr("data-event-cnt", ++eventCnt);
					
					// 일정을 해당 시간 영역의 위치로 이동 한 후 일정에 시간영역을 마킹. 어러개의 시간영역에 걸쳐있는 경우 모두 마킹됨
					var currTop = (totalDivHeight / (divCount * 4)) * ((sHour * 4) + (sMin / 15));
					var targetleft = $("#dayDataBgDiv").width()
					$(el).css({top: currTop, left: targetleft});
					$(el).addClass("target_"+$targetDatetime.attr("number"));
					
					var isContinue = true;
					if ($targetDatetime.next().length > 0 && isContinue && mode == 'load') {			// 로드할때, 시간 영역 및 이벤트에 관련 정보 마킹
						setNext($targetDatetime.next(), eventStartDatetime, eventEndDatetime, $(el));
					}
				}

				// 시간 일정의 기간까지 다음 시간영역을 확인하면서 이벤트 합산 증가 및 일정에 시간 영역 마킹하는 함수.
				function setNext(target, start, end, eventObj) {
					var nextTime = $(target).attr('time')
					if (end[1] > nextTime || (start[0] < end[0] && end[1] == '00:00')) {
						if (typeof $(target).attr("data-event-cnt") == 'undefined') {
							$(target).attr("data-event-cnt", 0);
							$(target).attr("data-event-date", start[0].split('.').join('-'));
							$(target).addClass("hasEvent");
						}
						
						var nextEventCnt = Number($(target).attr("data-event-cnt"))
						$(target).attr("data-event-cnt", ++nextEventCnt);
						
						$(eventObj).addClass("target_"+$(target).attr("number"));
					}
					else {
						isContinue = false;
					}
	
					if ($(target).next().length > 0 && isContinue) {
						setNext($(target).next(), eventStartDatetime, eventEndDatetime, eventObj)
					}
				}
			});
			
			dayWidth = dayWidth - 10;
			scheduleUser.dayblockidx = 0;
			scheduleUser.dayblockInfo = {}
			var maxEventCount = 1;
			
			$.each($("#dayDataDiv div.hasEvent"), function(idx, el){
				var $prev = $(el).prev();
				var $next = $(el).next();
				if ($(el).attr('data-event-cnt') > 1) $(".target_"+$(el).attr("number")).attr('data-devided', 'Y');		// 일정 카운트가 1 이상인 경우, 해당 시간영역이 마킹된 일정에 분할일정 마킹
				
				if ($prev.attr("data-event-cnt") == undefined) {			// 앞노드는 이벤트가 없고, 뒷노드에 이벤트가 있는 경우 이벤트 구역의 시작으로 판정
					// 새 구역으로 block-index 증가하고, 최대 일정수를 초기화
					$(".target_"+$(el).attr("number")).attr('data-block-index', ++scheduleUser.dayblockidx);
					maxEventCount = 1;
				}
				else if ($prev.attr("data-event-cnt") > 0 || $next.attr("data-event-cnt") > 0) {				// 앞 또는 뒷노드에 이벤트가 있으면 중간 또는 끝 구역으로 판정
					// 시간영역을 바라보는 이벤트에 block index를 마킹, 시간영역의 이벤트 합산이 최대 일절 수 보다 큰 경우, 최대일정 갱신
					$(".target_"+$(el).attr("number")).attr('data-block-index', scheduleUser.dayblockidx);
				}
				
				if (maxEventCount < $(el).attr('data-event-cnt')) maxEventCount = $(el).attr('data-event-cnt');
				
				// 이벤트 합산이 1 이상인 경우, 시간영역을 바라보는 이벤트의 넓이를 조정 
				if (maxEventCount > 1){
					var newDayWidth = (maxEventCount > 0) ? (Number(dayWidth)/Number(maxEventCount)) : Number(dayWidth);
					scheduleUser.dayblockInfo[scheduleUser.dayblockidx] = newDayWidth;
				}
			});
			
			$.each(scheduleUser.dayblockInfo, function(idx, el){
				$("div[data-block-index="+idx+"]").attr('data-devided', 'Y');
			});		
				
			$.each(dayEvent, function(idx, el){
				var $prev = $(el).prev();
				var $next = $(el).next();
				
				if($(el).attr("data-devided") == 'Y') {
					if($prev.attr("data-block-index") == $(el).attr("data-block-index") && $next.attr("data-block-index") == $(el).attr("data-block-index")) {
						$(el).attr('data-order', 'mid');
					}
					else if ($prev.attr("data-block-index") != $(el).attr("data-block-index") && $next.attr("data-block-index") == $(el).attr("data-block-index")) {
						$(el).attr('data-order', 'first');
					}
					else if ($prev.attr("data-block-index") == $(el).attr("data-block-index") && $next.attr("data-block-index") != $(el).attr("data-block-index")) {
						$(el).attr('data-order', 'end');
					}
					$(el).removeAttr('data-right-nodes')
				}
				else {
					$(el).width(dayWidth);
				}

				if (mode == 'load'){
					scheduleUser.setResizebleEvent(
						el, 
						$(".hourCell").height() + 1, 
						$(el).width(), 
						$("#gridDataDiv").height() - pxToNumber($(el).css("top")),
						$(".hourCell").height() + 1
					);
				}
			});
			
			$.each(scheduleUser.dayblockInfo, function(idx, el){
				$("div[data-block-index="+idx+"]").width(el);
			});
			
			for(var i = 0; i < scheduleUser.dayblockidx; i++){
				var $first = $("[data-devided=Y][data-block-index="+(i+1)+"][data-order=first]");
				var eventDepth = 1;
				$first.attr('data-event-depth', eventDepth);
				
				$.each($("[data-devided=Y][data-block-index="+(i+1)+"]"), function(idx, el){
					if ($(el).attr('data-order') != 'first'){
						comparePosition($first)
					}
					
					function comparePosition(compareTarget){
						var isFinished = false;
						var isOverlap = false;
						
						if ($(compareTarget).attr('id') == el.id) {
							return false;	
						}
						
						// 0. 비교대상과 같은 뎁스의 일정이 협치는지 확인
						var $sameDepthEvents = $("[data-devided=Y][data-block-index="+(i+1)+"][data-event-depth="+$(compareTarget).attr('data-event-depth')+"]");
						if ($sameDepthEvents.length > 0){
							$.each($sameDepthEvents, function(sameDepthEventIdx, sameDepthEventEle){
								if (
									($(el).attr('startdatetime') >= $(sameDepthEventEle).attr('startdatetime') && $(el).attr('startdatetime') < $(sameDepthEventEle).attr('enddatetime')) ||
									($(el).attr('enddatetime') > $(sameDepthEventEle).attr('startdatetime') && $(el).attr('enddatetime') <= $(sameDepthEventEle).attr('enddatetime')) ||
									($(el).attr('startdatetime') == $(sameDepthEventEle).attr('startdatetime') && $(el).attr('enddatetime') == $(sameDepthEventEle).attr('enddatetime'))
								){
									isOverlap = true;
								}
							});
						}
						
						// 하나도 겹치지 않으면 비교대상의 레벨 복사, 비교대상의 뎁스와 우측 노드를 복사
						if(!isOverlap) {
							if($(compareTarget).attr('data-right-nodes') != undefined){
								$(el).attr('data-right-nodes', $(compareTarget).attr('data-right-nodes'));
							}
							$(el).attr('data-event-depth', $(compareTarget).attr('data-event-depth'));
							
							if (Number($(compareTarget).attr('data-event-depth')) > 1) {
								$.each($("[data-devided=Y][data-block-index="+(i+1)+"][data-event-depth="+$(compareTarget).attr('data-event-depth')+"]"), function(prevDepthIdx, prevDepthEle){
									$(prevDepthEle).attr('data-right-nodes', $(prevDepthEle).attr('data-right-nodes') + ';' +el.id);
								});
							}
						}
						else {	
							// 2. 비교대상의 오른편의 대상이 있는지 확인 
							if ($(compareTarget).attr('data-right-nodes') == undefined) {	// 없으면, 비교대상의 옆으로 이동
									$(el).css("left", $(compareTarget).position().left + $(compareTarget).width() - 0.5).attr('data-event-depth', ++eventDepth);
									
									$.each($("[data-devided=Y][data-block-index="+(i+1)+"][data-event-depth="+$(compareTarget).attr('data-event-depth')+"]"), function(prevDepthIdx, prevDepthEle){
										$(prevDepthEle).attr('data-right-nodes', (($(prevDepthEle).attr('data-right-nodes') != undefined) ? ($(prevDepthEle).attr('data-right-nodes') + ';') : '') + el.id);
									});
									isFinished = true;							
							}
							else {	// 있으면 오른쪽 대상을 확인하여 
								var rightNodes = $(compareTarget).attr('data-right-nodes').split(';')
								var goNext = false;
								var duplcatedEvents = [];
								$.each(rightNodes, function(nodeIdx, node){
									var $node = $("#"+node)
									
									//나와 겹치면는지 확인
									if (
										($(el).attr('startdatetime') >= $node.attr('startdatetime') && $(el).attr('startdatetime') < $node.attr('enddatetime')) ||
										($(el).attr('enddatetime') > $node.attr('startdatetime') && $(el).attr('enddatetime') <= $node.attr('enddatetime')) ||
										($(el).attr('startdatetime') == $node.attr('startdatetime') && $(el).attr('enddatetime') == $node.attr('enddatetime'))
									){		// 겹치면 해당 노드의 오른쪽을 확인
										if ($node.attr('data-right-nodes') == undefined){		// 우측노트가 없는 겹치는 노드를 모두 확인
											duplcatedEvents.push($node);
										}
										else {	// 나와 겹치지만 우측 노드가 있어 이동하지 않고 다음 비교
											goNext = true;
										}
									}
								});
								
								// 모든 노드와 확인 후 겹치지 않으면 비교대상의 옆으로 이동
								if(!isFinished && !goNext){
									if (duplcatedEvents.length == 0){	// 모든 노드와 겹치지 않는 경우 비교대상의 옆으로 이동, 비교대상과 같은 레벨의 일정에 나를 마킹
										$(el).css("left", $(compareTarget).position().left + $(compareTarget).width() - 0.5);
										
										var currentEventDepth = Number($(compareTarget).attr('data-event-depth'))
										$(el).attr('data-event-depth', currentEventDepth + 1);
										
										$.each($("[data-devided=Y][data-block-index="+(i+1)+"][data-event-depth="+$(compareTarget).attr('data-event-depth')+"]"), function(prevDepthIdx, prevDepthEle){
											$(prevDepthEle).attr('data-right-nodes', (($(prevDepthEle).attr('data-right-nodes') != undefined) ? ($(prevDepthEle).attr('data-right-nodes') + ';') : '') + el.id);
										});
										
										isFinished = true;
									}
									else{	// 겹치는 노드의 오른편이 비어있는 경우 겹치는 노드의 옆으로 이동, 블럭 깊이를 1 증가, 겹치는 노드와 같은 레벨의 일정에 나를 마킹
										var $duplicatedEvent = $(duplcatedEvents[0]);
										$(el).css("left", $duplicatedEvent.position().left + $duplicatedEvent.width() - 0.5).attr('data-event-depth', ++eventDepth);
										
										$.each($("[data-devided=Y][data-block-index="+(i+1)+"][data-event-depth="+$duplicatedEvent.attr('data-event-depth')+"]"), function(prevDepthIdx, prevDepthEle){
											$(prevDepthEle).attr('data-right-nodes', (($(prevDepthEle).attr('data-right-nodes') != undefined) ? ($(prevDepthEle).attr('data-right-nodes') + ';') : '') + el.id);
										});
										
										isFinished = true;
									}
								}
							}
							
							if (!isFinished) comparePosition($(compareTarget).next(), $(compareTarget))
						}
					}
				});
			}
			
			scheduleUser.setDragNDropEvent();
		},
		setResizebleEvent : function(obj, resize, maxWidth, maxHeight, minHeight){
			// 권한있는 Div만 Resize 이벤트 적용시키기
			if($(obj).attr("isGoogle") == "Y" || $(obj).attr("RegisterCode") == userCode || $(obj).attr("OwnerCode") == userCode  || $$(schAclArray).find("modify").concat().find("[FolderID="+$(obj).attr("FolderID")+"]").length > 0){
				$(obj).resizable({
					grid: resize,
					maxWidth: maxWidth,
					maxHeight: maxHeight,
					minWidth: maxWidth,
					minHeight: (minHeight) ? minHeight : resize,
					stop: function( event, ui ) {
						var isRepeat = $(this).attr("isRepeat");
						var eventID = $(this).attr("eventID");
						var dateID = $(this).attr("dateID");
						var repeatID = $(this).attr("repeatID");
						var subject = $(this).attr("data-subject");
						var endMin = $(this).height() / resize;
						var sDateTime = $(this).attr("startDateTime");
						
						var eDate = new Date(new Date(replaceDate(sDateTime)).getTime() + (endMin*30*60000));
				    	var hour = (eDate.getHours() < 10 ? '0' : '') + eDate.getHours();
				    	var min = (eDate.getMinutes() < 10 ? '0' : '') + eDate.getMinutes();
						
				    	var endDateTime = schedule_SetDateFormat(eDate, '-') + " "+hour + ":"+min;
				    	if(isRepeat == "Y"){
				    		//TODO 반복 제외시 Event Data 다시 넣는 함수 호출
				    		Common.Confirm(coviDic.dicMap["msg_changeRepeatEach"],"",function (result){
				    			if(result){
				    				scheduleUser.Resize_Update(eventID, dateID, repeatID, endDateTime, sDateTime, subject, "RU");
				    			} else{
									scheduleUser.refresh();
								}
				    		});
				    	}else{
				    		scheduleUser.Resize_Update(eventID, dateID, repeatID, endDateTime, sDateTime, subject);
				    	}
					}
				});
			}
		},
		Resize_Update : function(eventID, dateID, repeatID, endDateTime, startDateTime, subject, setType){
			if(Number(eventID)){
				$.ajax({
				    url: "/groupware/schedule/setDateDataByResize.do",
				    type: "POST",
				    data: {
				    	"EventID" : eventID,
				    	"DateID" : dateID,
				    	"RepeatID" : repeatID,
				    	"EndDateTime" : endDateTime,
				    	"StartDateTime" : startDateTime,
				    	"Subject": subject,
				    	"SetType" : setType				    	
					},
				    success: function (res) {
				    	if (res.status == "DUPLICATION") {
				    		Common.Warning(res.Message);
				    	}else if(res.status != "SUCCESS"){
							Common.Error(Common.getDic("msg_apv_030"));		// 오류가 발생했습니다.
						}
				    	
				    	if(g_viewType == "M"){
							schedule_MakeMonthCalendar();
						}else if(g_viewType == "D"){
							scheduleUser.schedule_MakeDayCalendar();
						}else if(g_viewType == "W"){
							scheduleUser.schedule_MakeWeekCalendar();
						}
			        },
			        error:function(response, status, error){
						CFN_ErrorAjax("/groupware/schedule/setDateDataByResize.do", response, status, error);
						
						if(g_viewType == "M"){
							schedule_MakeMonthCalendar();
						}else if(g_viewType == "D"){
							scheduleUser.schedule_MakeDayCalendar();
						}else if(g_viewType == "W"){
							scheduleUser.schedule_MakeWeekCalendar();
						}
					}
				});
			}
			else{
				// Alert 팝업이 있는 경우 발생하지않도록 처리
				if($("#AlertLayer").length > 0) return false;
				
				// 구글 연동 일정 등록
				Common.Confirm(Common.getDic("msg_changeGoogleSch"), "", function(result){			//구글 캘린더에 있는 일정이 수정됩니다.\n수정하시겠습니까?
					if(result)
						coverGoogleEventForResize(eventID, endDateTime);
				});
			}
		},
		// 주간 그리기
		schedule_MakeWeekCalendar : function(){
			var startDateObj = new Date(replaceDate(g_startDate));
	
		    //select day가 속한 주를 가져오기
		    var sun = schedule_GetSunday(startDateObj);
		    var strSun = schedule_SetDateFormat(sun, '/');
		    var mon = schedule_AddDays(strSun, 1);
		    var tue = schedule_AddDays(strSun, 2);
		    var wed = schedule_AddDays(strSun, 3);
		    var thr = schedule_AddDays(strSun, 4);
		    var fri = schedule_AddDays(strSun, 5);
		    var sat = schedule_AddDays(strSun, 6);
	
		    // 상단 제목 날짜 표시
		    $('#dateTitle').html(schedule_SetDateFormat(sun, '.') + ' - ' + schedule_SetDateFormat(sat, '.'));
			
			// 헤더 날짜
		    var headerDateHTML = "";
			headerDateHTML += '<th class="sun"><span>'+sun.getDate()+'</span>&nbsp;'+coviDic.dicMap["lbl_WPSun"]+'<span name="dayInfo" value="' +schedule_SetDateFormat(sun, '-')+ '" class="inDate"></span></th>';
			headerDateHTML += '<th><span>'+mon.getDate()+'</span>&nbsp;'+coviDic.dicMap["lbl_WPMon"]+'<span  name="dayInfo" value="' +schedule_SetDateFormat(mon, '-')+ '" class="inDate"></span></th>';
			headerDateHTML += '<th><span>'+tue.getDate()+'</span>&nbsp;'+coviDic.dicMap["lbl_WPTue"]+'<span name="dayInfo" value="' +schedule_SetDateFormat(tue, '-')+ '" class="inDate"></span></th>';
			headerDateHTML += '<th><span>'+wed.getDate()+'</span>&nbsp;'+coviDic.dicMap["lbl_WPWed"]+'<span name="dayInfo" value="' +schedule_SetDateFormat(wed, '-')+ '" class="inDate"></span></th>';
			headerDateHTML += '<th><span>'+thr.getDate()+'</span>&nbsp;'+coviDic.dicMap["lbl_WPThu"]+'<span name="dayInfo" value="' +schedule_SetDateFormat(thr, '-')+ '" class="inDate"></span></th>';
			headerDateHTML += '<th><span>'+fri.getDate()+'</span>&nbsp;'+coviDic.dicMap["lbl_WPFri"]+'<span name="dayInfo" value="' +schedule_SetDateFormat(fri, '-')+ '" class="inDate"></span></th>';
			headerDateHTML += '<th><span>'+sat.getDate()+'</span>&nbsp;'+coviDic.dicMap["lbl_WPSat"]+'<span name="dayInfo" value="' +schedule_SetDateFormat(sat, '-')+ '" class="inDate"></span></th>';
			
			$("#weekHeader").find("tr").html(headerDateHTML);
			
			
			// 월간 달력 그리기(달력의 바닥을 그림)
		    
			// 종일
			var allDayHTML = '<table class="weeklySpecialTbl"><tbody>';
			var i, j;
			
			// 기본 2개의 div
			for(i = 0; i<2; i++){
				allDayHTML += '<tr class="grid">';
				
				for(j=0; j<7; j++)
					allDayHTML += '<td><div class="gridWrapper"><div class="gridWrapperLine"><div class="hourCell" onclick="scheduleUser.setSimpleWritePopupAllDay(this);" date="'+schedule_SetDateFormat(schedule_AddDays(strSun, j), '.')+'"></div></div></div></td>';
					
				allDayHTML += '</tr>';
		    }
			allDayHTML += '</tbody></table>';
			$("#allDayWeekDataBgDiv").html(allDayHTML);
			
			
			var backHTML = '';
		    
		    // 업무시간으로 체크되었을 경우
			var timeStart = 0;
			var timeEnd = 24;
			
			if(g_isWorkTime){
			    if(coviCmn.configMap["WorkStartTime"] != ""){
			    	timeStart = Number(coviCmn.configMap["WorkStartTime"]);
			    }
			    if(coviCmn.configMap["WorkEndTime"] != ""){
			    	timeEnd = Number(coviCmn.configMap["WorkEndTime"]);
			    }
		    }
			
		    var divCount = 0;
		    // 왼쪽 시간
		    for(var i = timeStart; i<timeEnd; i++){
		    	backHTML += '<p id="time_'+i+'">'+i+coviDic.dicMap["lbl_Hour"]+'</p>';
		    	++divCount;
		    }
		    $("#weekDataBgDiv").html(backHTML);
		    
		    
		    // 가운데 내용
		    var bodyHTML = '<table class="weeklyTbl "><tbody>';
		    bodyHTML += '<tr class="grid">';
		    
		    for(i=0; i<7; i++){
		    	bodyHTML += '<td><div class="gridWrapper">';
		    	bodyHTML += '<div id="gridDataDiv_'+i+'" class="gridWrapperLine" date="'+schedule_SetDateFormat(schedule_AddDays(strSun, i), '.')+'">';
		    	
			    for(j = timeStart*2; j<(timeEnd)*2; j++){
			    	var tempDate = new Date(new Date(replaceDate(g_startDate)).getTime() + (j*30*60000));
			    	var hour = (tempDate.getHours() < 10 ? '0' : '') + tempDate.getHours();
			    	var min = (tempDate.getMinutes() < 10 ? '0' : '') + tempDate.getMinutes();
			    	var time = hour + ":"+min;
			    	
			    	bodyHTML += '<div class="hourCell" time="'+time+'" number="'+j+'"></div>';
		    	}
			    bodyHTML += '</div>';
			    bodyHTML += '<div class="schTimeLine" style="display:none;z-index:80"></div>';
		        bodyHTML += '</td>';
		    }
		    bodyHTML += '</tr>';
		    
		    bodyHTML += '</tbody></table>';
	
		    $("#weekDataDiv").html(bodyHTML);
		    
		    // 현재 날짜 표시
		    var nowDisplay = $("[id^=gridDataDiv][date='"+schedule_SetDateFormat(g_currentTime, '.')+"']").parent().find("[class=schTimeLine]");
		    
			var totalDivHeight = ($(".hourCell").height() + 1) * divCount * 2;

			var currHour = g_currentTime.getHours();
			if(g_isWorkTime){
				currHour=currHour-coviCmn.configMap["WorkStartTime"];
			}
		    var currMin = g_currentTime.getMinutes();
		    
		    var currTop = (totalDivHeight / (divCount * 4)) * ((currHour * 4) + (currMin / 15));
		    $(nowDisplay).css("top", currTop+"px");
		    $(nowDisplay).show();
		    
		    var sDate = schedule_SetDateFormat(sun, '-');
		    var eDate = schedule_SetDateFormat(sat, '-');
		    
		    if(g_isWorkTime){
		    	sDate = sDate + " " + AddFrontZero(timeStart, 2) + ":00";
		    	eDate = eDate + " " + AddFrontZero(timeEnd, 2) + ":00";
		    }
		    
		    //데이터 조회하여 그림
		    scheduleUser.getMonthEventData(sDate, eDate);
		    
		    //Selectable jquery ui event 바인딩
		    scheduleUser.setSelectableEvent();
			
			if(g_isWorkTime) {
				$("#chkWorkTimeWeek").attr("checked", "checked");
			}
		},
		setWeekEventData : function(eventData, pSDate, pEDate){
			var allDayHTML = "";
			var dayHTML = '';
			$(".cRContBottom").append('<article id="read_popup" style="position: absolute;"></article>');
			
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
					
			        // 종일/반복처리시 종료일 
			        if (eTime == "00:00" || (eventData[i].IsAllDay == "Y" && isRepeat == "Y")) {
			            if(eDate != sDate) {
			                eDate = schedule_SetDateFormat(schedule_SubtractDays(eDate.replace(/\./gi, '-'), 1), '-');
			            }
			            if (eTime == "00:00") {
			                eTime = "23:59";
			            }
			        }

					if (isRepeat == 'Y') {
						allDayHTML += '<div class="calToolTip">'+coviDic.dicMap["lbl_schedule_repeatSch"]+'</div>';		//반복일정
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
						var widthVal = $(".hourCell").width();
						
						allDayHTML += '<div id="allDayData_'+eventData[i].DateID+'" class="shcMultiDayText '+className+'"'
												+(eventData[i].isGoogle == "Y" ? 'isGoogle="Y"' : '')
												+' eventID="'+eventData[i].EventID+'"'
												+' dateID="'+eventData[i].DateID+'"'
												+' repeatID="'+eventData[i].RepeatID+'"'
												+' startDateTime="'+sDateTime+'"'
												+' endDateTime="'+eDateTime+'"'
												+' isRepeat="'+isRepeat+'"'
												+' folderID="'+eventData[i].FolderID+'"'
												+' registerCode="'+eventData[i].RegisterCode+'"'
												+' ownerCode="'+eventData[i].OwnerCode+'"'
												+' data-subject="' + eventData[i].Subject + '"'
												+' onclick="scheduleUser.setSimpleViewPopup(this, event)" style="width:'+widthVal+'px;background:'+eventData[i].Color+'">';
						allDayHTML += '<div>';
						
						if(eventData[i].IsAllDay != "Y")
							allDayHTML += '<span>('+sTime+')</span>';
						
						allDayHTML += '<span>'+eventData[i].Subject+'</span>';
						if(eventData[i].Place != "")
							allDayHTML += '<span class="locIcon">'+coviDic.dicMap["lbl_schedule_position"]+'</span>';			//위치확인
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
						var heightVal = $(".hourCell").height() + 1;
						var diffMin = schedule_GetDiffDates(new Date(replaceDate(sDateTime)), new Date(replaceDate(eDateTime)), 'min');
						
						var multiHeightVal = diffMin / 30;
						if(multiHeightVal >= 1){
							heightVal = heightVal * multiHeightVal;
						}
						
						dayHTML += '<div id="eventData_'+eventData[i].FolderID+'_'+eventData[i].DateID+'"'
											+(eventData[i].isGoogle == "Y" ? 'isGoogle="Y"' : '')
											+' eventID="'+eventData[i].EventID+'"'
											+' dateID="'+eventData[i].DateID+'"'
											+' repeatID="'+eventData[i].RepeatID+'"'
											+' startDateTime="'+sDateTime+'"'
											+' endDateTime="'+eDateTime+'"'
											+' isRepeat="'+isRepeat+'"'
											+' folderID="'+eventData[i].FolderID+'"'
											+' registerCode="'+eventData[i].RegisterCode+'"'
											+' ownerCode="'+eventData[i].OwnerCode+'"'
											+' data-subject="' + eventData[i].Subject + '"'
											+' class="shcMultiDayText '+className+'" onclick="scheduleUser.setSimpleViewPopup(this, event)" style="background:'+eventData[i].Color+'; height:'+heightVal+'px;overflow:hidden">';
						dayHTML += '<div>';
						//dayHTML += '<span>'+sTime+'~'+eTime+'</span>'+'<span>'+eventData[i].Subject+' '+'</span>';
						dayHTML += '<span>'+eventData[i].Subject+' '+'</span>';
						if(eventData[i].Place != "")
							dayHTML += '<span class="locIcon">'+coviDic.dicMap["lbl_schedule_position"]+'</span>';		//위치확인
						if(eventData[i].Place != "")
							dayHTML += '<p>'+eventData[i].Place+'</p>';
						dayHTML += '</div>';
						dayHTML += '</div>';
					}
				}
			}
			
			$("#allDayWeekDataBgDiv").append(allDayHTML);
			$("#weekDataDiv").append(dayHTML);
			
			// Top, Width 세팅
			scheduleUser.setWeekEventDataTopWidth('load');
		},
		setWeekEventDataTopWidth: function(mode){
			var dayWidth = $("#allDayWeekDataBgDiv .weeklySpecialTbl .hourCell:first").width();
				
			if (mode == 'resize'){			// 종일 일정 resize
				$.each($("[id^=allDayData_]"), function(idx, el){
					$(el).css({ padding: 0 });
					var duration = $(el).attr('data-duration');
					$(el).width(dayWidth * duration);
					var allDayEventStartDatetime = $(el).attr('startdatetime').split('-').join('.').split(' ');
					
					$.each($("#allDayWeekDataBgDiv div[date='"+allDayEventStartDatetime[0]+"']"), function(index, ele){
						$(el).css({left: $(ele).closest('td').position().left});
					});
				});
			}
			else if (mode == 'load'){			// 종일 일정 load
				$(".weeklySpecialTbl tbody tr:last").addClass('last');			// 종일 일정 영역의 마지막에 last 클래스 추가. 라인추가여부에 활용
				
				var allDayEvent = $("[id^=allDayData_]");
				$.each(allDayEvent, function(idx, el){
					$(el).css({ padding: 0 });
					var allDayEventStartDatetime = $(el).attr('startdatetime').split('-').join('.').split(' ');
					var allDayEventEndDatetime = $(el).attr('enddatetime').split('-').join('.').split(' ');
					
					if (allDayEventStartDatetime[0] < $("#allDayWeekDataBgDiv .hourCell:first").attr("date")) {		// 일정 시작일이 목록의 시작일보다 작으면 목록의 시작을로 설정
						allDayEventStartDatetime[0] = $("#allDayWeekDataBgDiv .hourCell:first").attr("date");
						$(el).addClass('prevLine'); 
						$(el).find('span').css("margin-left", "12px");
					}
					
					$.each($("#allDayWeekDataBgDiv div[date='"+allDayEventStartDatetime[0]+"']"), function(index, ele){		// 일정의 시작일에 해당하는 div를 가져와서 표시여부 확인
						var isFinished = false;
						if ($(ele).attr('data-event-id') == undefined){			// div에 data-event-id 값이 없으면 표시 내용없음.
							if ($(ele).closest('tr').hasClass('last')) {		// 표시내용 표시 전 마지막 열인 경우 신규라인 추가 및 초기화
								$(ele).closest('tr').removeClass('last');
								$(".weeklySpecialTbl tbody").append($(".weeklySpecialTbl tbody tr:first").clone(true));
								$(".weeklySpecialTbl tbody tr:last").addClass('last');
								$(".weeklySpecialTbl tbody tr:last .hourCell").removeAttr("data-event-id"); 
							}

							$(el).css({top: $(ele).closest('td').position().top, left: $(ele).closest('td').position().left});		// 일정의 top, left 속성을 div 위치를 참고하여 이동
							$(ele).attr('data-event-id', el.id);		// div에 event-id를 마킹
							
							// 하루 이상의 종일일정 여부 확인
							var duration = schedule_GetDiffDates(new Date(replaceDate(allDayEventStartDatetime[0])), new Date(replaceDate(allDayEventEndDatetime[0])), 'day');
							
							if (!isNaN(duration) && duration > 0) {			// 일정의 기간이 하루 이상인 경우 div와 동일한 영역을 가져와서, 일정의 시작일보다 크고, 종료일보다 같거나 작은 경우 해당 div에 event-id를 마킹
								$.each($(ele).closest('tr').find('.hourCell'), function(durationIndex, durationEle){
									if ($(durationEle).attr('date') > allDayEventStartDatetime[0] && $(durationEle).attr('date') <= allDayEventEndDatetime[0]) $(durationEle).attr('data-event-id', el.id);
								});
							}
							
							var overflowDuration = 0;
							if(allDayEventEndDatetime[0] > $("div[data-event-id='"+el.id+"']:last").attr('date')){		// 종료일이 목록의 마지막 일자보다 큰 경우 오버플로두된 만큼 기간 차감
								overflowDuration = schedule_GetDiffDates(new Date(replaceDate(allDayEventEndDatetime[0])), new Date(replaceDate($("div[data-event-id='"+el.id+"']:last").attr('date'))), 'day');
								$(el).addClass('nextLine');
							}
							
							if (!isNaN(duration) && duration > 0) {		// 하루이상의 종일일정 길이 조정
								duration = duration + overflowDuration;
								$(el).width(dayWidth * (duration + 1));
							}
							$(el).attr('data-duration', duration+1);	// 일정에 기간 마킹
							isFinished = true;							// 루프를 종료
						}
						if (isFinished) return false;
					});
				});	
			}
			
			var dayEvent = $("[id^=eventData_]");
			
			$.each(dayEvent, function(idx, el){				
				$(el).css({ padding: 0 });
				var eventStartDatetime = $(el).attr('startdatetime').split('-').join('.').split(' ');
				var eventEndDatetime = $(el).attr('enddatetime').split('-').join('.').split(' ');
				
				var divCount = $("[id^=time_]").length;
				var totalDivHeight = ($(".hourCell").height() + 1) * divCount * 2;
				var dateObj = new Date(replaceDate(eventStartDatetime));
			    
				var sHour = dateObj.getHours();
				var sMin = dateObj.getMinutes();
				
				// 업무시간 체크했을 때 해당위치부터 그리기
				if(g_isWorkTime){
				    if(coviCmn.configMap["WorkStartTime"] != ""){
				    	sHour = dateObj.getHours() - Number(coviCmn.configMap["WorkStartTime"]);
				    }
				}
				
				var seDateTimeObj = {};
				
				if(sMin < 30){
					var tempEndDate = new Date(new Date(replaceDate(eventStartDatetime)).getTime() - sMin*60000); 
					seDateTimeObj.start = schedule_SetDateFormat(tempEndDate, '.') + " " +tempEndDate.getHours() + ":"+tempEndDate.getMinutes();
					var hour = tempEndDate.getHours();
					var min = tempEndDate.getMinutes();
					
					if((hour+"").length < 2){
						hour="0"+hour;
					}
					if((min+"").length < 2){
						min="0"+min;
					}
					
					seDateTimeObj.start = schedule_SetDateFormat(tempEndDate, '.') + " " +hour + ":"+min;
					
					var startTarget = seDateTimeObj.start.split(" ");
					// 시간별 일정을 확인하여, 해당 시간영역에 일정 수 합산
					var $targetDatetime = $("#weekDataDiv div[date='"+startTarget[0]+"'] div[time='"+startTarget[1]+"']");
					if (typeof $targetDatetime.attr("data-event-cnt") == 'undefined') {
						$targetDatetime.attr("data-event-cnt", 0);
						$targetDatetime.attr("data-event-date", startTarget[0].split('.').join('-'));
						$targetDatetime.addClass("hasEvent");
					}
					
					var targetTop = ($targetDatetime.length > 0) ? $targetDatetime.position().top : 0;
					var eventCnt = Number($targetDatetime.attr("data-event-cnt"))
					
					if (mode == 'load') $targetDatetime.attr("data-event-cnt", ++eventCnt);
					
					// 일정을 해당 시간 영역의 위치로 이동 한 후 일정에 시간영역을 마킹. 어러개의 시간영역에 걸쳐있는 경우 모두 마킹됨
					var $targetLeftTd = $("#allDayWeekDataBgDiv div[date='"+startTarget[0]+"']").closest('td');
					var currTop = (totalDivHeight / (divCount * 4)) * ((sHour * 4) + (sMin / 15));
					var currLeft = (typeof cID != 'undefined') ? ($targetLeftTd.position().left + $targetLeftTd.width() - 2) : ($targetLeftTd.offset().left - $("#left").width() - 90);
					$(el).css({top: currTop, left: currLeft});
					$(el).addClass("target_"+eventStartDatetime[0].split('.').join('-')+"_"+$targetDatetime.attr("number"));
					
					var isContinue = true;
					if ($targetDatetime.next().length > 0 && isContinue && mode == 'load') {			// 로드할때, 시간 영역 및 이벤트에 관련 정보 마킹
						setNext($targetDatetime.next(), eventStartDatetime, eventEndDatetime, $(el));
					}
				}
				
				if(sMin >= 30){
					var tempEndDate = new Date(new Date(replaceDate(eventStartDatetime)).getTime() - sMin*60000 + 30*60000); 
					seDateTimeObj.start = schedule_SetDateFormat(tempEndDate, '.') + " " +tempEndDate.getHours() + ":"+tempEndDate.getMinutes();
					var hour = tempEndDate.getHours();
					var min = tempEndDate.getMinutes();
					
					if((hour+"").length < 2){
						hour="0"+hour;
					}
					if((min+"").length < 2){
						min="0"+min;
					}
					
					seDateTimeObj.start = schedule_SetDateFormat(tempEndDate, '.') + " " +hour + ":"+min;
					
					var startTarget = seDateTimeObj.start.split(" ");
					// 시간별 일정을 확인하여, 해당 시간영역에 일정 수 합산
					var $targetDatetime = $("#weekDataDiv div[date='"+startTarget[0]+"'] div[time='"+startTarget[1]+"']");
					if (typeof $targetDatetime.attr("data-event-cnt") == 'undefined') {
						$targetDatetime.attr("data-event-cnt", 0);
						$targetDatetime.attr("data-event-date", startTarget[0].split('.').join('-'));
						$targetDatetime.addClass("hasEvent");
					}
					
					var targetTop = ($targetDatetime.length > 0) ? $targetDatetime.position().top : 0;
					var eventCnt = Number($targetDatetime.attr("data-event-cnt"))
					
					if (mode == 'load') $targetDatetime.attr("data-event-cnt", ++eventCnt);
					
					// 일정을 해당 시간 영역의 위치로 이동 한 후 일정에 시간영역을 마킹. 어러개의 시간영역에 걸쳐있는 경우 모두 마킹됨
					var $targetLeftTd = $("#allDayWeekDataBgDiv div[date='"+startTarget[0]+"']").closest('td');
					var currTop = (totalDivHeight / (divCount * 4)) * ((sHour * 4) + (sMin / 15));
					var currLeft = (typeof cID != 'undefined') ? ($targetLeftTd.position().left + $targetLeftTd.width() - 2) : ($targetLeftTd.offset().left - $("#left").width() - 90);
					$(el).css({top: currTop, left: currLeft});
					$(el).addClass("target_"+eventStartDatetime[0].split('.').join('-')+"_"+$targetDatetime.attr("number"));
					
					var isContinue = true;
					if ($targetDatetime.next().length > 0 && isContinue && mode == 'load') {			// 로드할때, 시간 영역 및 이벤트에 관련 정보 마킹
						setNext($targetDatetime.next(), eventStartDatetime, eventEndDatetime, $(el));
					}
				}
				// 시간 일정의 기간까지 다음 시간영역을 확인하면서 이벤트 합산 증가 및 일정에 시간 영역 마킹하는 함수.
					function setNext(target, start, end, eventObj) {
						var nextTime = $(target).attr('time')
						if (end[1] > nextTime || (start[0] < end[0] && end[1] == '00:00')) {
							if (typeof $(target).attr("data-event-cnt") == 'undefined') {
								$(target).attr("data-event-cnt", 0);
								$(target).attr("data-event-date", start[0].split('.').join('-'));
								$(target).addClass("hasEvent");
							}
							
							var nextEventCnt = Number($(target).attr("data-event-cnt"))
							$(target).attr("data-event-cnt", ++nextEventCnt);
							
							$(eventObj).addClass("target_"+start[0].split('.').join('-')+"_"+$(target).attr("number"));
						}
						else {
							isContinue = false;
						}
		
						if ($(target).next().length > 0 && isContinue) {
							setNext($(target).next(), start, end, eventObj)
						}
					}
			});
			
			dayWidth = dayWidth - 5;
			scheduleUser.blockidx = 0;
			scheduleUser.blockInfo = {}
			$.each($("#weekDataDiv .gridWrapperLine"), function(weekdayIdx, weekdayEl){		// 일자별로 이벤트를 가진 시간영역 루프
				var $events = $(weekdayEl).find("div.hasEvent");
				var maxEventCount = 1;
				
				// 일정 블록 부여. 일정이 형제 레벨의 div로 구성되어 있어 구역을 나눌 필요가 있음. 넓이 계산 등.
				$.each($events, function(index, ele){
					var $prev = $(ele).prev();
					var $next = $(ele).next();
					
					if ($prev.attr("data-event-cnt") == undefined) {			// 앞노드는 이벤트가 없고, 뒷노드에 이벤트가 있는 경우 이벤트 구역의 시작으로 판정
						// 새 구역으로 block-index 증가하고, 최대 일정수를 초기화
						$(".target_"+$(ele).attr("data-event-date")+"_"+$(ele).attr("number")).attr('data-block-index', ++scheduleUser.blockidx);
						maxEventCount = 1;
					}
					else if ($prev.attr("data-event-cnt") > 0 || $next.attr("data-event-cnt") > 0) {				// 앞 또는 뒷노드에 이벤트가 있으면 중간 또는 끝 구역으로 판정
						// 시간영역을 바라보는 이벤트에 block index를 마킹, 시간영역의 이벤트 합산이 최대 일절 수 보다 큰 경우, 최대일정 갱신
						$(".target_"+$(ele).attr("data-event-date")+"_"+$(ele).attr("number")).attr('data-block-index', scheduleUser.blockidx);
					}
					if (maxEventCount < $(ele).attr('data-event-cnt')) maxEventCount = $(ele).attr('data-event-cnt');		// 구역의 최
					// 이벤트 합산이 1 이상인 경우, 시간영역을 바라보는 이벤트의 넓이를 조정 
					if (maxEventCount > 1){
						var newDayWidth = (maxEventCount > 0) ? (Number(dayWidth)/Number(maxEventCount)) : Number(dayWidth);
						scheduleUser.blockInfo[scheduleUser.blockidx] = newDayWidth;
					}
				});
			});
			
			$.each(scheduleUser.blockInfo, function(idx, el){
				$("div[data-block-index="+idx+"]").attr('data-devided', 'Y');
			});
			
			$.each(dayEvent, function(idx, el){
				var $prev = $(el).prev();
				var $next = $(el).next();
				
				if($(el).attr("data-devided") == 'Y') {
					if($prev.attr("data-block-index") == $(el).attr("data-block-index") && $next.attr("data-block-index") == $(el).attr("data-block-index")) {
						$(el).attr('data-order', 'mid');
					}
					else if ($prev.attr("data-block-index") != $(el).attr("data-block-index") && $next.attr("data-block-index") == $(el).attr("data-block-index")) {
						$(el).attr('data-order', 'first');
					}
					else if ($prev.attr("data-block-index") == $(el).attr("data-block-index") && $next.attr("data-block-index") != $(el).attr("data-block-index")) {
						$(el).attr('data-order', 'end');
					}
					$(el).removeAttr('data-right-nodes')
				}
				else {
					$(el).width(dayWidth);
				}

				if (mode == 'load'){
					scheduleUser.setResizebleEvent(
						el, 
						$(".hourCell").height() + 1, 
						$(el).width(),
						$("#gridDataDiv_0").height() - pxToNumber($(el).css("top")),
						$(".hourCell").height() + 1
					);
				}
			});
			
			$.each(scheduleUser.blockInfo, function(idx, el){
				$("div[data-block-index="+idx+"]").width(el);
			});
			
			for(var i = 0; i < scheduleUser.blockidx; i++){
				var $first = $("[data-devided=Y][data-block-index="+(i+1)+"][data-order=first]");
				var eventDepth = 1;
				$first.attr('data-event-depth', eventDepth);
				
				$.each($("[data-devided=Y][data-block-index="+(i+1)+"]"), function(idx, el){
					if ($(el).attr('data-order') != 'first'){
						comparePosition($first)
					}
					function comparePosition(compareTarget){
						var isFinished = false;
						var isOverlap = false;
						
						if ($(compareTarget).attr('id') == el.id) {
							return false;	
						}
						
						// 0. 비교대상과 같은 뎁스의 일정이 협치는지 확인
						var $sameDepthEvents = $("[data-devided=Y][data-block-index="+(i+1)+"][data-event-depth="+$(compareTarget).attr('data-event-depth')+"]");
						if ($sameDepthEvents.length > 0){
							$.each($sameDepthEvents, function(sameDepthEventIdx, sameDepthEventEle){
								if (
									($(el).attr('startdatetime') >= $(sameDepthEventEle).attr('startdatetime') && $(el).attr('startdatetime') < $(sameDepthEventEle).attr('enddatetime')) ||
									($(el).attr('enddatetime') > $(sameDepthEventEle).attr('startdatetime') && $(el).attr('enddatetime') <= $(sameDepthEventEle).attr('enddatetime')) ||
									($(el).attr('startdatetime') == $(sameDepthEventEle).attr('startdatetime') && $(el).attr('enddatetime') == $(sameDepthEventEle).attr('enddatetime'))
								){
									isOverlap = true;
								}
							});
						}
						
						// 하나도 겹치지 않으면 비교대상의 레벨 복사, 비교대상의 뎁스와 우측 노드를 복사
						if(!isOverlap) {
							if($(compareTarget).attr('data-right-nodes') != undefined){
								$(el).attr('data-right-nodes', $(compareTarget).attr('data-right-nodes'));
							}
							$(el).attr('data-event-depth', $(compareTarget).attr('data-event-depth'));
							
							if (Number($(compareTarget).attr('data-event-depth')) > 1) {
								$.each($("[data-devided=Y][data-block-index="+(i+1)+"][data-event-depth="+$(compareTarget).attr('data-event-depth')+"]"), function(prevDepthIdx, prevDepthEle){
									$(prevDepthEle).attr('data-right-nodes', $(prevDepthEle).attr('data-right-nodes') + ';' +el.id);
								});
							}
						}
						else {	
							// 2. 비교대상의 오른편의 대상이 있는지 확인 
							if ($(compareTarget).attr('data-right-nodes') == undefined) {	// 없으면, 비교대상의 옆으로 이동
									$(el).css("left", $(compareTarget).position().left + $(compareTarget).width() - 0.5).attr('data-event-depth', ++eventDepth);
									
									$.each($("[data-devided=Y][data-block-index="+(i+1)+"][data-event-depth="+$(compareTarget).attr('data-event-depth')+"]"), function(prevDepthIdx, prevDepthEle){
										$(prevDepthEle).attr('data-right-nodes', (($(prevDepthEle).attr('data-right-nodes') != undefined) ? ($(prevDepthEle).attr('data-right-nodes') + ';') : '') + el.id);
									});
									isFinished = true;							
							}
							else {	// 있으면 오른쪽 대상을 확인하여 
								var rightNodes = $(compareTarget).attr('data-right-nodes').split(';')
								var goNext = false;
								var duplcatedEvents = [];
								$.each(rightNodes, function(nodeIdx, node){
									var $node = $("#"+node)
									
									//나와 겹치면는지 확인
									if (
										($(el).attr('startdatetime') >= $node.attr('startdatetime') && $(el).attr('startdatetime') < $node.attr('enddatetime')) ||
										($(el).attr('enddatetime') > $node.attr('startdatetime') && $(el).attr('enddatetime') <= $node.attr('enddatetime')) ||
										($(el).attr('startdatetime') == $node.attr('startdatetime') && $(el).attr('enddatetime') == $node.attr('enddatetime'))
									){		// 겹치면 해당 노드의 오른쪽을 확인
										if ($node.attr('data-right-nodes') == undefined){		// 우측노트가 없는 겹치는 노드를 모두 확인
											duplcatedEvents.push($node);
										}
										else {	// 나와 겹치지만 우측 노드가 있어 이동하지 않고 다음 비교
											goNext = true;
										}
									}
								});
								
								// 모든 노드와 확인 후 겹치지 않으면 비교대상의 옆으로 이동
								if(!isFinished && !goNext){
									if (duplcatedEvents.length == 0){	// 모든 노드와 겹치지 않는 경우 비교대상의 옆으로 이동, 비교대상과 같은 레벨의 일정에 나를 마킹
										$(el).css("left", $(compareTarget).position().left + $(compareTarget).width() - 0.5);
										
										var currentEventDepth = Number($(compareTarget).attr('data-event-depth'))
										$(el).attr('data-event-depth', currentEventDepth + 1);
										
										$.each($("[data-devided=Y][data-block-index="+(i+1)+"][data-event-depth="+$(compareTarget).attr('data-event-depth')+"]"), function(prevDepthIdx, prevDepthEle){
											$(prevDepthEle).attr('data-right-nodes', (($(prevDepthEle).attr('data-right-nodes') != undefined) ? ($(prevDepthEle).attr('data-right-nodes') + ';') : '') + el.id);
										});
										
										isFinished = true;
									}
									else{	// 겹치는 노드의 오른편이 비어있는 경우 겹치는 노드의 옆으로 이동, 블럭 깊이를 1 증가, 겹치는 노드와 같은 레벨의 일정에 나를 마킹
										var $duplicatedEvent = $(duplcatedEvents[0]);
										$(el).css("left", $duplicatedEvent.position().left + $duplicatedEvent.width() - 0.5).attr('data-event-depth', ++eventDepth);
										
										$.each($("[data-devided=Y][data-block-index="+(i+1)+"][data-event-depth="+$duplicatedEvent.attr('data-event-depth')+"]"), function(prevDepthIdx, prevDepthEle){
											$(prevDepthEle).attr('data-right-nodes', (($(prevDepthEle).attr('data-right-nodes') != undefined) ? ($(prevDepthEle).attr('data-right-nodes') + ';') : '') + el.id);
										});
										
										isFinished = true;
									}
								}
							}
							
							if (!isFinished) comparePosition($(compareTarget).next(), $(compareTarget))
						}
					}
				});
			}
			
			scheduleUser.setDragNDropEvent();
		},
		// 상세 검색에서 구분에 대한 selectbox
		setSearchFolderType : function(){
			//권한 있는 모든 폴더 리스트
			var selectHtml = "<option value=''>"+Common.getDic("lbl_Whole")+"</option>";		//전체
			$(schAclArray.read).each(function(i){
				selectHtml += "<option value='"+this.FolderID+"'>"+this.MultiDisplayName+"</opion>";
			});
			$("#searchFolderType").html(selectHtml);
		},
		// 상세 검색 했을 경우
		getSearchListData : function(){
			//TODO Validation
			
			var startdate = $("#searchDateCon_StartDate").val();
			var enddate = $("#searchDateCon_EndDate").val();
			
			if(startdate > enddate){
				Common.Warning(Common.getDic("msg_bad_period"));	//시작일이 종료일보다 클 수 없습니다.
				return;
			}
			
			if($(".oftenSchCont").hasClass("active")){
				bntOftenOnClick($("#btnOften"));
			}
			
			$("#DayCalendar,#WeekCalendar,#MonthCalendar").hide();
			$(".scheduleTop ul.schSelect li[data-role=result]").remove();
			$("#List").show();
			$("#googleScheduleTxt, #GoogleList").hide();
			$(".scheduleTop ul.schSelect").append(
				'<li data-role="result" class="selected"><a>'+Common.getDic('lbl_SearchResult')+'</a></li>'
			);
			if($("#liList").width() != 98) $("#liList").width(98);
			if (g_viewType == 'List'){
				if($("#topButton").width() != 414) $("#topButton").width($("#topButton").width() + 100);
				if($("#liList").css("margin-left") != '-207px') $("#topButton").css("margin-left", '-207px');
				$("#liList").attr("style", $("#liList").attr("style")+'border-top-right-radius: 0; border-bottom-right-radius: 0;');
				$(".scheduleTop ul.schSelect li[data-role=result]").attr("style", 'border-top-left-radius: 0; border-bottom-left-radius: 0;');
			} else {
				if($("#topButton").width() != 412) $("#topButton").width($("#topButton").width() + 98);
				if($("#liList").css("margin-left") != '-206px') $("#topButton").css("margin-left", '-206px');
			}
			
			scheduleUser.schedule_MakeList();
		},
		// 간단 검색 했을 경우
		searchSubject : function(){
			if($("#simSearchSubject").val() == undefined || $("#simSearchSubject").val() == ""){
				Common.Warning(Common.getDic("msg_EnterSearchword"));			//검색어를 입력하세요
			}else{
				$("#searchSubject").val($("#simSearchSubject").val());
				
				scheduleUser.getSearchListData();
				$("#searchSubject").val("");
			}
		},
		// 검색에서 엔티키 입력했을 경우
		searchSubjectEnter : function(e){
			if (e.keyCode == 13) {
				scheduleUser.searchSubject();
			}
		},
		// 상세검색에서 엔티키 입력했을 경우
		DetailSearchSubjectEnter : function(e){
			if (e.keyCode == 13) {
				scheduleUser.getSearchListData();
			}
		},
		schedule_MakeList : function(){
			// 상단 제목 날짜 표시
			$('#dateTitle').html(g_year + "." + g_month);
			
			// 자주 쓰는 일정 숨김
			$("#btnOften").hide();
			
			//개별호출-일괄호출
			Common.getDicList(["lbl_Title", "lbl_Important","lbl_Repeate","lbl_schedule_start","lbl_schedule_end","lbl_Register","lbl_schedule_showContent","msg_apv_030"]);
			
			var headerData = [{key: 'showInfo', label: '' , width: '1', align: 'center', display: false},
			                  			{key:'FolderID', label:' ', width:'80', align:'center',
											formatter:function () {
												return '<div><span class="ribbonBox" style="background:'+this.item.Color+';">'+this.item.FolderName+'</span></div>';
											}
										},{key:'Subject', label:coviDic.dicMap["lbl_Title"], width:'200', align:'left',					//제목
											formatter:function () {
												var html = '';
												html +='<div class="tblLink"><a onclick="scheduleUser.goDetailViewPage(\'LIST\', \''+this.item.EventID+'\', \''+this.item.DateID+'\', \''+this.item.RepeatID+'\', \''+this.item.IsRepeat+'\', \''+this.item.FolderID+'\');">';
												// 중요일정일 경우
												if(this.item.ImportanceState == "Y")
													html +='<span class="btnType02 active">'+coviDic.dicMap["lbl_Important"]+'</span>';		//중요
												
												// 반복일 경우
												if(this.item.IsRepeat == "Y")
													html +='<span class="btnType02">'+coviDic.dicMap["lbl_Repeate"]+'</span>';			//반복
												
												html += this.item.Subject;
												html += '</a></div>';
												
												return html;
											}
										},{key:'StartDateTime', label:coviDic.dicMap["lbl_schedule_start"] + Common.getSession("UR_TimeZoneDisplay"), width:'80', align:'center', 			//일정 시작
											formatter:function(){
												var startDate =new Date(replaceDate(CFN_TransLocalTime(this.item.StartDateTime)));
												startDate = schedule_SetDateFormat(startDate, ".") 
														+ (this.item.IsAllDay == "Y" ? "" :  " " + AddFrontZero(startDate.getHours(), 2)+":"+AddFrontZero(startDate.getMinutes(), 2));
												
												return '<div class="fcStyle">' + startDate.substring(startDate.indexOf(".")+1, startDate.length) + '</div>';
											}
										},
										{key:'EndDateTime', label:coviDic.dicMap["lbl_schedule_end"] + Common.getSession("UR_TimeZoneDisplay"), width:'80', align:'center', 				//일정 종료
											formatter:function(){
												var endDate = new Date(replaceDate(CFN_TransLocalTime(this.item.EndDateTime)));
												endDate = schedule_SetDateFormat(endDate, ".")
														+ (this.item.IsAllDay == "Y" ? "" : " " + AddFrontZero(endDate.getHours(), 2)+":"+AddFrontZero(endDate.getMinutes(), 2));
												
												return '<div class="fcStyle">' + endDate.substring(endDate.indexOf(".")+1, endDate.length) + '</div>';
											}
										},
										{key:'MultiRegisterName', label:coviDic.dicMap["lbl_Register"], width:'50', align:'center', formatter: function(){				//등록자
										     return coviCtrl.formatUserContext("List", this.item.MultiRegisterName, this.item.RegisterCode, this.item.MailAddress);
										}}, 
										{key:'RegisterCode',  label:'RegisterCode', align:'center' , display:false, hideFilter : 'Y'},
										{key:'Buttons', label:' ', width:'80', align:'center',
											formatter:function () {
												var html = '';
												var activeHtml = (this.item.showInfo) ? ' active' : '';
												html += '<div class="schListBtnBox">';
												html += '<a onclick="scheduleUser.addTemplateScheduleData('+this.item.EventID+');" class="btnSchLayerAdd"></a>';
												html += '<a onclick="scheduleUser.showDetailInfo('+this.index+');" class="btnCycleArrUD btnUrgent'+activeHtml+'">'+coviDic.dicMap["lbl_schedule_showContent"]+'</a>';			//내용보기
												html += '</div>';
												
												return html;
											}}];
			
			grid.setGridHeader(headerData);
			
			// config
			var configObj = {
				targetID : "DefaultList",
				height:"auto",	
				overflowCell: [5],
				paging : false,
				body: {
					marker : {
						display: function () { return this.item.showInfo; },
						rows: [
							[{
								colSeq  : null, colspan: 12, formatter: function () {
						    		$.Event(event).stopPropagation();
	
									$.ajax({
									    url: "/groupware/schedule/getListDetail.do",
									    type: "POST",
									    async:false,
									    data: {
									    	"EventID" : this.item.EventID,
									    	"lang" : lang
										},
									    success: function (res) {
									    	if(res.status == "SUCCESS"){
												$("#hidShowInfo").val(scheduleUser.getListDetailShowInfo(res.EventJson));
									    	} else {
												Common.Error(coviDic.dicMap["msg_apv_030"]);		// 오류가 발생했습니다.
											}
								        },
								        error:function(response, status, error){
											CFN_ErrorAjax("/groupware/schedule/getListDetail.do", response, status, error);
										}
									});
									return $("#hidShowInfo").val();
								}, align: "center"
							}]
						]
					}
				}
			};
			grid.setGridConfig(configObj);
			
			scheduleUser.searchScheduleData();
		},
		// 그리드 데이터
		searchScheduleData : function(){
			var importanceState = "";
			var subject = $("#searchSubject").val();
			var placeName = $("#searchPlace").val();
			var register = $("#serachRegister").val();
			var sDate = g_startDate;
			var eDate = g_endDate;
			
			if(eDate == undefined || eDate == "undefined"){
				sDate = schedule_SetDateFormat(new Date(g_year, (g_month - 1), 1), '.');
				eDate = schedule_SetDateFormat(new Date(g_year, g_month, 0), '.');
			}
			
			if(type == "import"){
				importanceState = "Y";
			}else if(type == "all"){
				folderIDs = null;
			}
			
			var searchStartDate = parent.$("#searchDateCon_StartDate").val();
			var searchEndDate = parent.$("#searchDateCon_EndDate").val();
			
			// 상세 검색 조건을 하였을 경우 기간 값을 가져와서 조회 한다.
			if($('.btnDetails').hasClass('active') && searchStartDate != "" && searchEndDate != "") {
				sDate = searchStartDate;
				eDate = searchEndDate;
			}
			
			sDate = (sDate.length == 10) ? sDate.replaceAll(".", "-") + ' 00:00' : sDate.replaceAll(".", "-");
			eDate = (eDate.length == 10) ? schedule_SetDateFormat(schedule_AddDays(eDate.replaceAll(".", "-"), 1),'-') + ' 00:00' : eDate.replaceAll(".", "-");
			
			var params = {
					"FolderIDs" : folderCheckList,
					"StartDate": CFN_TransServerTime(sDate),
					"EndDate": CFN_TransServerTime(eDate),
					"UserCode" : userCode,
					"lang" : lang,
					"ImportanceState" : importanceState,
					"Subject" : subject,
					"PlaceName" : placeName,
					"RegisterName" : register
			};
			
			grid.bindGrid({
				ajaxUrl : "/groupware/schedule/getList.do",
				ajaxPars : params,
				onLoad : function() {				
					// 구글 연동 일정
		    		//2019.03 성능개선
		    		if(isConnectGoogle && g_googleFolderID == null){
		    			Common.getBaseConfigList(["ScheduleGoogleFolderID","SchedulePersonFolderID","WorkStartTime","WorkEndTime"]);
		    			g_googleFolderID = coviCmn.configMap["ScheduleGoogleFolderID"];
		    		}					
					if(folderCheckList.indexOf(";"+g_googleFolderID + ";") > -1 && isConnectGoogle){
						scheduleUser.schedule_MakeListGoogle();
					}
				}
			});
		},
		schedule_MakeListGoogle : function(){
			$("#googleScheduleTxt").show();
			
			var headerData = [{key: 'showInfo', label: '' , width: '1', align: 'center', display: false},
			            			{key:'FolderID', label:' ', width:'80', align:'center',
										formatter:function () {
											return '<div><span class="ribbonBox" style="background:'+this.item.Color+';">'+this.item.FolderName+'</span></div>';
										}
									},{key:'Subject', label:coviDic.dicMap["lbl_Title"], width:'200', align:'left',			// 제목
										formatter:function () {
											var html = '';
											html +='<div class="tblLink"><a onclick="scheduleUser.goDetailViewPage(\'LIST\', \''+this.item.EventID+'\', \''+this.item.DateID+'\', \''+this.item.RepeatID+'\' \''+this.item.IsRepeat+'\', \''+this.item.FolderID+'\');">';
											// 중요일정일 경우
											if(this.item.ImportanceState == "Y")
												html +='<span class="btnType02 active">'+coviDic.dicMap["lbl_Important"]+'</span>';		//중요
											
											// 반복일 경우
											if(this.item.IsRepeat == "Y")
												html +='<span class="btnType02">'+coviDic.dicMap["lbl_Repeate"]+'</span>';		//반복
											
											html += this.item.Subject;
											html += '</a></div>';
											
											return html;
										}
									},{key:'StartDateTime', label:coviDic.dicMap["lbl_schedule_start"], width:'80', align:'center', 			//일정 시작
										formatter:function(){
											var startDate =new Date(this.item.StartDateTime);
											startDate = schedule_SetDateFormat(startDate, ".") 
													+ (this.item.IsAllDay == "Y" ? "" :  " " + AddFrontZero(startDate.getHours(), 2)+":"+AddFrontZero(startDate.getMinutes(), 2));
											
											return '<div class="fcStyle">' + startDate.substring(startDate.indexOf(".")+1, startDate.length) + '</div>';
										}
									},
									{key:'EndDateTime', label:coviDic.dicMap["lbl_schedule_end"], width:'80', align:'center', 				//일정 종료
										formatter:function(){
											var endDate =new Date(this.item.EndDateTime);
											endDate = schedule_SetDateFormat(endDate, ".")
													+ (this.item.IsAllDay == "Y" ? "" : " " + AddFrontZero(endDate.getHours(), 2)+":"+AddFrontZero(endDate.getMinutes(), 2));
											
											return '<div class="fcStyle">' + endDate.substring(endDate.indexOf(".")+1, endDate.length) + '</div>';
										}
									},
									{key:'MultiRegisterName', label:coviDic.dicMap["lbl_Register"], width:'50', align:'center'},				// 등록자
									{key:'Buttons', label:' ', width:'80', align:'center',
										formatter:function () {
											var html = '';
											var activeHtml = (this.item.showInfo) ? ' active' : '';
											html += '<div class="schListBtnBox">';
											html += '<a onclick="scheduleUser.showGoogleDetailInfo('+this.index+');" class="btnCycleArrUD btnUrgent'+activeHtml+'">'+coviDic.dicMap["lbl_schedule_showContent"]+'</a>';			//내용보기
											html += '</div>';
											
											return html;
										}}];
			
			gridGoogle.setGridHeader(headerData);
			
			// config
			var configObj = {
				targetID : "GoogleList",
				listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
				height:"auto",			
				paging : false,
				body: {
					marker : {
						display: function () { return this.item.showInfo; },
						rows: [
							[{
								colSeq  : null, colspan: 12, formatter: function () {
						    		$.Event(event).stopPropagation();
	
						    		var getGoogleDetailShowInfo = function(mode, data){
						    			$("#hidShowInfo").val(scheduleUser.getListDetailShowInfo(data));
						    		};
						    		
						    		getGoogleEventOne("", this.item.EventID, coverGoogleEventOne, getGoogleDetailShowInfo, false);
						    		
									return $("#hidShowInfo").val();
									
								}, align: "center"
							}]
						]
					}
				}
			};
			
			gridGoogle.setGridConfig(configObj);
			
			scheduleUser.searchScheduleGoogleData();
		},
		// 구글 그리드 데이터
		searchScheduleGoogleData : function(){
			var subject = $("#searchSubject").val();
			var placeName = $("#searchPlace").val();
			var register = $("#serachRegister").val();
			var sDate = g_startDate;
			var eDate = g_endDate;
			
			if(eDate == undefined || eDate == "undefined"){
				sDate = schedule_SetDateFormat(new Date(g_year, (g_month - 1), 1), '.');
				eDate = schedule_SetDateFormat(new Date(g_year, g_month, 0), '.');
			}
			
			if(type == "all"){
				folderIDs = null;
			}
			
			if($("#searchDateCon_StartDate").val() != "" && $("#searchDateCon_EndDate").val() != ""){
				sDate = $("#searchDateCon_StartDate").val();
				eDate = schedule_SetDateFormat(schedule_AddDays($("#searchDateCon_EndDate").val(), 1), '.');
			}
			
			sDate = new Date(replaceDate(sDate)).toISOString();
			eDate = new Date(replaceDate(eDate)).toISOString();
			
			var paramJSON = {
					"orderBy" : "startTime",
					"showDeleted" : false,
					"singleEvents" : true,
					"timeMax" : eDate,
					"timeMin" : sDate
			};
			
			var params = {
					"StartDate" : sDate,
					"EndDate" : eDate,
					"UserCode" : userCode,
					"Subject" : subject,
					"PlaceName" : placeName,
					"RegisterName" : register,
					"paramJSON" : JSON.stringify(paramJSON)
			};
			
			gridGoogle.bindGrid({
				ajaxUrl : "/groupware/schedule/getGoogleList.do",
				ajaxPars : params
			});
		},
		getListDetailShowInfo : function(eventJson){
			var returnHtml = '<div class="tblBoradDisplay">';
			
			var place = eventJson.Event.Place;
			var attendee = eventJson.Attendee;
			var resource = eventJson.Resource;
			var desc = eventJson.Event.Description;
			
			//개별호출 - 일괄호출
			Common.getDicList(["lbl_Place","lbl_schedule_attendant","lbl_schedule_participation","lbl_schedule_Nonparticipation","lbl_schedule_standBy","lbl_Resources"
			                   , "lbl_Text","msg_nothingToDetail"]);
			
			// 장소
			if(place != undefined && place != ""){
				returnHtml += '<div>';
				returnHtml += '<div class="tit">'+coviDic.dicMap["lbl_Place"]+'</div>';			//장소
				returnHtml += '<div class="txt"><span class="locIcon02">'+place+'</span></div>';
				returnHtml += '</div>';
			}
			// 참석자
			if(attendee != undefined && attendee.length > 0 && attendee[0].UserCode != undefined){
				returnHtml += '<div>';
				returnHtml += '<div class="tit">'+coviDic.dicMap["lbl_schedule_attendant"]+'</div>';			//참석자
				returnHtml += '<div class="txt ">';
				returnHtml += '<p class="many">';
	
				$(attendee).each(function(){
					returnHtml += '<span>';
					
					if(this.IsAllow == "Y")
						returnHtml += '<span class="btnType02 blue">'+coviDic.dicMap["lbl_schedule_participation"]+'</span>';		//참여
					else if(this.IsAllow == "N")
						returnHtml += '<span><span class="btnType02">'+coviDic.dicMap["lbl_schedule_Nonparticipation"]+'</span>';			//비참여
					else
						returnHtml += '<span><span class="btnType02">'+coviDic.dicMap["lbl_schedule_standBy"]+'</span>';			//대기중
					
					returnHtml += this.UserName;
					
					if(this.DeptCode != undefined)
						returnHtml += ' ('+this.DeptName+')';
					returnHtml += '&nbsp;&nbsp;&nbsp;&nbsp;';
					
					returnHtml += '</span>';
				});
				
				returnHtml += '</p>';
				returnHtml += '</div></div>';
			}
			// 자원
			if(resource != undefined && resource.length > 0 && resource[0].FolderID != undefined){
				returnHtml += '<div>';
				returnHtml += '<div class="tit">'+coviDic.dicMap["lbl_Resources"]+'</div>';				//자원
				returnHtml += '<div class="txt">';
				returnHtml += '<p><span>';
				
				var resourceName = "";
				$(resource).each(function(){
					resourceName += this.ResourceName + ", ";
				});
				returnHtml += resourceName.substring(0, resourceName.lastIndexOf(','));
				
				returnHtml += '</span></p>';
				returnHtml += '</div></div>';
			}
			// 본문
			if(desc != undefined && desc != ''){
				returnHtml += '<div>';
				returnHtml += '<div class="tit">'+coviDic.dicMap["lbl_Text"]+'</div>';			//본문
				returnHtml += '<div class="txt">';
				returnHtml += '<p>' +desc+ '</p>';
				returnHtml += '</div></div>';
			}
			
			// 보여줄 내용이 없을 경우
			if(returnHtml == '<div class="tblBoradDisplay">'){
				returnHtml += '<p><span>'+coviDic.dicMap["msg_nothingToDetail"]+'</span></p>';			//상세히 표시할 내용이 없습니다.
			}
			returnHtml += '</div>';
			
			return returnHtml;
		},
		// 목록 그리드에서 상세 정보 펼쳤을 때
		showDetailInfo : function(index) {
		    $.Event(event).stopPropagation();
	
			var item = grid.list[index];
			if(prevClickIdx != index){ //현재 그리드에서 펼쳐진 행은 모두 닫는다.
				$.each(
						grid.list, function(idx) {
					if(grid.list[idx].showInfo)
						grid.updateItem(0,0,idx,false);
				});
			}
			if(!item.showInfo){
				grid.updateItem(0,0,index,true);
				prevClickIdx = index;
			}
			else{
				grid.updateItem(0,0,index,false);
			}
			grid.setFocus(index);
			grid.windowResizeApply(); //스크롤바를 리드로우한다.
		},
		showGoogleDetailInfo : function(index) {
		    $.Event(event).stopPropagation();
	
			var item = gridGoogle.list[index];
			if(prevClickIdx != index){ //현재 그리드에서 펼쳐진 행은 모두 닫는다.
				$.each(
						gridGoogle.list, function(idx) {
					if(gridGoogle.list[idx].showInfo)
						gridGoogle.updateItem(0,0,idx,false);
				});
			}
			if(!item.showInfo){
				gridGoogle.updateItem(0,0,index,true);
				prevClickIdx = index;
			}
			else{
				gridGoogle.updateItem(0,0,index,false);
			}
			gridGoogle.setFocus(index);
			gridGoogle.windowResizeApply(); //스크롤바를 리드로우한다.
		},
		// 작성화면에서 구분 select box
		setFolderType : function(mode){
			//권한 있는 모든 폴더 리스트
			var selectHtml = "";
			var selectFolderObj;
			// 커뮤니티 연동시 해당 폴더만 보이도록
			if(CFN_GetQueryString("CSMU") == "C"){
				selectFolderObj = $$(schAclArray).find("create").concat().find("[FolderID="+folderCheckList.replaceAll(";", "") +"]").json();
			}else if(mode == "SAC"){
				scheduleUser.setAclEventFolderData();
				selectFolderObj = $(schAclArray.create);
			}
			else
				selectFolderObj = $(schAclArray.create);

			$(selectFolderObj).each(function(i){
				// 구글은 연동되었을 때만
	    		//2019.03 성능개선
	    		if(isConnectGoogle && g_googleFolderID == null){
	    			Common.getBaseConfigList(["ScheduleGoogleFolderID","SchedulePersonFolderID","WorkStartTime","WorkEndTime"]);
	    			g_googleFolderID = coviCmn.configMap["ScheduleGoogleFolderID"];
	    		}				
				if(!(this.FolderID == g_googleFolderID) || isConnectGoogle){
					if(i == 0){
						$("#defaultFolderType").html('<span style="background-color:'+this.Color+'"></span> '+this.MultiDisplayName);
						$("#FolderType").val(this.FolderID);
					}

					if ( this.FolderType != "Folder" && this.FolderType != "ScheduleShare"){
						selectHtml += '<li onclick="selectOpListLiOnclick(this, \''+mode+'\');" data-selvalue="'+this.FolderID+'" folderType="'+this.FolderType+'" style="white-space: nowrap;text-overflow: ellipsis; overflow: hidden;"><span style="background-color:'+this.Color+'"></span>&nbsp'+this.MultiDisplayName+'</li>';
					}
				}
			});

			$("#ulFolderTypes").html(selectHtml);
		},
		// 작성화면에서 일시 표시 select box
		setStartEndDateTime : function(setType, sDate, eDate, isAllDay, sTime, eTime){
			if(setType == "S"){
				target = 'simpleSchDateCon';
				
				var timeInfos = {};
				timeInfos = {
						width : "80",
						H : "1,2,3,4,8",
						W : "1,2", //주 선택
						M : "1,2", //달 선택
						Y : "1,2" //년도 선택
					};
			}
			else{
				target = 'detailDateCon';
				timeInfos = {
						width : "80",
						H : "1,2,3,4,8",
						W : "1,2", //주 선택
						M : "1,2", //달 선택
						Y : "1,2" //년도 선택
					};
			}
			
			var initInfos = {
					useCalendarPicker : 'Y',
					useTimePicker : 'Y',
					useBar : 'Y',
					useSeparation : 'Y',
					minuteInterval : 5,  //TODO 만약, 60의 약수가 아닌 경우, 그려지지 않음.
					timePickerwidth : '50',
					height : '200',
					use59 : 'Y'
				};
			
			coviCtrl.renderDateSelect(target, timeInfos, initInfos);
			//$("#"+target).find("[name=endDate]").find("select").append('<option value="23:59" data-code="23:59" data-codename="23:59">23:59</option>');
			
			if(setType == "S"){
				$("#simpleSchDateCon_StartDate").val(sDate);
				$("#simpleSchDateCon_EndDate").val(eDate);
	
				if(g_viewType == "D" || g_viewType == "W"){
					coviCtrl.setSelected('simpleSchDateCon [name=startHour]', sTime.split(":")[0]);
					coviCtrl.setSelected('simpleSchDateCon [name=startMinute]', sTime.split(":")[1]);
					
					coviCtrl.setSelected('simpleSchDateCon [name=endHour]', eTime.split(":")[0]);
					coviCtrl.setSelected('simpleSchDateCon [name=endMinute]', eTime.split(":")[1]);
					
					coviCtrl.setSelected('simpleSchDateCon [name=datePicker]', "select");
					
					//if(isAllDay == undefined || !isAllDay){
						coviCtrl.setSelected('simpleSchDateCon [name=datePicker]', "select");
					//}
				} else if(g_viewType == "M") {// 일정시간 +1 ex) 11시45분 자원 간편예약시 12시로 자동셋팅

					var parseDate = new Date(CFN_GetLocalCurrentDate("yyyy/MM/dd HH:mm:ss")); // 시간을 현재 시간 기준으로 다시 초기화
					parseDate.setHours(parseDate.getHours() + 1);
					var chHour = parseDate.format("HH");
					parseDate.setHours(parseDate.getHours() + 1);
					var chNextHour = parseDate.format("HH");
					
					
					coviCtrl.setSelected('simpleSchDateCon [name=startHour]', chHour);
					coviCtrl.setSelected('simpleSchDateCon [name=startMinute]', "00");
					
					coviCtrl.setSelected('simpleSchDateCon [name=endHour]', chNextHour);
					coviCtrl.setSelected('simpleSchDateCon [name=endMinute]', "00");
					
					/*if(isAllDay == undefined || !isAllDay){
						coviCtrl.setSelected('simpleSchDateCon [name=datePicker]', "select");
					}*/

				}
				
				//자원 추천 체크
				scheduleUser.recommandResource();
			}

			if((CFN_GetQueryString("isTemplate") == "undefined" || (CFN_GetQueryString("isTemplate") == "Y" && CFN_GetQueryString("eventID") != "undefined"))
					&& ($("#detailDateCon_StartDate").val() == "" || $("#detailDateCon_EndDate").val() == "")){
				$("#detailDateCon_StartDate").val(g_startDate);
				$("#detailDateCon_EndDate").val(g_startDate);
			}
		},
		// 간단 작성에서 자원목록 조회
		setResourceList : function(){
			//개별호출 - 일괄호출
			Common.getDicList(["lbl_Select","msg_apv_030"]);
			var resourceListHTML = '<option value="" placeofbusiness="">'+coviDic.dicMap["lbl_Select"]+'</option>';	// 선택
			
			$.ajax({
			    url: "/groupware/resource/getResourceList.do",
			    type: "POST",
			    data: {},
			    success: function (res) {
			    	if(res.status == "SUCCESS"){
			    		if(Common.getBaseConfig("IsUsePlaceOfBusinessSel") == "Y") {
			    			scheduleUser.setPlaceOfBusiness();
			    			$("#placeOfBusinessSel").css({"display":"inline"});
			    			$("#resourceList").css({"width":"271px"});
			    		} else {
			    			$("#placeOfBusinessSel").css({"display":"none"});
			    		}
			    		
			    		$(res.data).each(function(){
			    			resourceListHTML += '<option value="'+this.FolderID+'" typeid="'+this.FolderType+'" typename="'+this.TypeName+'" placeofbusiness="'+this.PlaceOfBusiness+'">'+this.FolderName+'</option>';
			    		});
			    		$("#resourceList").html(resourceListHTML);
			    	}else{
			    		Common.Error(coviDic.dicMap["msg_apv_030"]);		// 오류가 발생했습니다.
			    	}
		        },
		        error:function(response, status, error){
					CFN_ErrorAjax("/groupware/resource/getResourceList.do", response, status, error);
				}
			});
			
			if (Common.getBaseConfig('IsPastSave') == '' || Common.getBaseConfig('IsPastSave') == 'N'){
				var sDate = $("#simpleSchDateCon_StartDate").val();
				var sTime = coviCtrl.getSelected('simpleSchDateCon [name=startHour]').val + ":" + coviCtrl.getSelected('simpleSchDateCon [name=startMinute]').val;			
				if (parseInt(g_currentTime.getTime() / 1000 / 60) > parseInt(new Date(replaceDate(sDate) + " " + sTime).getTime() / 1000 / 60)){
					$(".addSurveyTarget").hide();
					$("#resourceList").parent().hide();
					$("#msgSelectResource").removeClass("active");
					$("#msgPast").addClass("active");
				}
			}
		},
		setPlaceOfBusiness: function (){
			var lang = Common.getSession("lang");
			var initInfos = [
		        {
			        target : 'placeOfBusinessSel',
			        codeGroup : 'PlaceOfBusiness',
			        defaultVal : 'PlaceOfBusiness',
			        width : '120',
			        onchange : ''
		        }
	        ];
	        coviCtrl.renderAjaxSelect(initInfos, '', lang);
			$("#placeOfBusinessSel select").change(scheduleUser.onChangePlaceOfBusiness);
		},
		// 사업장 Select Box 변경시
		onChangePlaceOfBusiness : function (){
			placeOfBusiness = coviCtrl.getSelected('placeOfBusinessSel').val;
			
			if(placeOfBusiness == "PlaceOfBusiness"){
				placeOfBusiness = "";
			}
			
			var resourceDisplay = false;
			
			$("#resourceList option").each(function(item){
				if(placeOfBusiness == "" || $(this).attr("PlaceOfBusiness") == ""){
					$(this).show();
					resourceDisplay = true;
				} else if((";"+$(this).attr("PlaceOfBusiness")).indexOf(";"+placeOfBusiness+";") > -1){
					$(this).show();
					resourceDisplay = true;
				} else {
					$(this).hide();
				}
			})
			
			if(placeOfBusiness == ""){
				$("#resourceList option[value='PlaceOfBusiness']").show();
			} else {
				$("#resourceList option[value='PlaceOfBusiness']").hide();
			}
			
			// 자원이 없습니다. Option 삭제
			$("#resourceList option[value='0']").remove();

			if(resourceDisplay) {		// 변경된 사업장의 회의실중 최상위 회의실로 변경
				$("#resourceList option").each(function(idx) {
					if($(this).css("display") != "none") {
						$("#resourceList option:eq("+idx+")").prop("selected", true);
						return false;
					}
				});
			} else {					// 변경된 사업장에 자원이 없는 경우 표시 (자원이 없습니다.)
				$("#resourceList option:last").after("<option value='0'>" + Common.getDic("msg_resource_emptyResource") + "</option>");
				$("#resourceList option:last").prop("selected", true);
			}
		},
		// 간단 작성에서 자원추가하기
		addResource : function(){
			// 자원 예약 추천
			if(isCanBooking){
				var selectedVal = $("#resourceList option:selected").val();
				var selectedText = $("#resourceList option:selected").text();
				
				if(selectedVal != ""){
					if ($("#addedResourceList span[value="+selectedVal+"]").length > 0){
						parent.Common.Warning(Common.getDic("msg_AlreadyRegisted"), 'Warning', function(){
							$("#resourceList").val('').change();
						});
						return;
					}
					
					var addedHtml = '<li><div>';
					addedHtml += '<span id="resource_'+selectedVal+'" value="'+selectedVal+'">'+selectedText+'</span>';
					addedHtml += '<a onclick="scheduleUser.deleteResource(this); event.stopPropagation();" class="btnRemove">'+Common.getDic("btn_delete")+'</a>';			//삭제
					addedHtml += '</div></li>';
					
					$("#addedResourceList").append(addedHtml);
					$("#resourceList").val('').change();
				} else {
					Common.Warning(Common.getDic("msg_mustSelectRes"));
				}
			}
		},
		deleteResource : function(obj){
			$(obj).parent().parent().remove();
		},
		// 간단 작성에서 자원 예약 추천
		recommandResource : function(){
			var selectedVal = $("#resourceList option:selected").val();
			var resourceType = $("#resourceList option:selected").attr("typeid");
	
			if(selectedVal != "" && selectedVal != undefined){
				var sDate = $("#simpleSchDateCon_StartDate").val();
				var eDate = $("#simpleSchDateCon_EndDate").val();
				var sTime = coviCtrl.getSelected('simpleSchDateCon [name=startHour]').val + ":" + coviCtrl.getSelected('simpleSchDateCon [name=startMinute]').val;
				var eTime = coviCtrl.getSelected('simpleSchDateCon [name=endHour]').val + ":" + coviCtrl.getSelected('simpleSchDateCon [name=endMinute]').val;
				
				if(sDate == "" && eDate == "" && sTime == "" && eTime == ""){
					isCanBooking = false;
					
					$("#msgSelectTime").addClass("active");
					$("#msgSelectResource").removeClass("active");
					$("#msgOK").removeClass("active");
					$("#msgNO").removeClass("active");
					$("#msgRecommand1").removeClass("active");
					$("#msgRecommand2").removeClass("active");
					$("#recLastMsg").hide();
				}
				else{
					$.ajax({
					    url: "/groupware/resource/check.do",
					    type: "POST",
					    data: {
					    	"FolderID" : selectedVal,
							"StartDate" : sDate.replaceAll(".", "-"),
							"StartTime" : sTime,
							"EndDate" : eDate.replaceAll(".", "-"),
							"EndTime" : eTime,
							"ResourceType" : resourceType
					    },
					    success: function (res) {
					    	if(res.status == "SUCCESS"){
					    		if(res.resultObj != undefined){
					    			isCanBooking = false;
					    			
					    			$("#msgRecommand1").addClass("active");
									$("#msgRecommand2").addClass("active");
									$("#recLastMsg").show();
									$("#msgSelectResource").removeClass("active");
					    			$("#msgOK").removeClass("active");
					    			$("#msgNO").removeClass("active");
									$("#msgSelectTime").removeClass("active");
									
					    			var recResourceHTML = "<span>"+Common.getDic("lbl_resource_recommend")+"</span>";			//추천 자원
					    			if(res.resultObj.resource.length > 0){
					    				$(res.resultObj.resource).each(function(){
						    				recResourceHTML += '<span id="'+this.FolderID+'"><a onclick="scheduleUser.setSimpleRecommandResource(\''+this.FolderID+'\')">'+this.FolderName+'</a></span>,';
						    			});
					    				recResourceHTML = recResourceHTML.substring(0, recResourceHTML.lastIndexOf(",")); 
					    			}
					    			$("#recReources").html(recResourceHTML);
					    			
					    			var firstTimeStartDateTime = res.resultObj.firstTime.StartDateTime;
					    			var firstTimeEndDateTime = res.resultObj.firstTime.EndDateTime;
					    			var timeStartDateTime = res.resultObj.time.StartDateTime;
					    			var timeEndDateTime = res.resultObj.time.EndDateTime;
				
									if(firstTimeStartDateTime && firstTimeStartDateTime.indexOf(" ") > -1){
										firstTimeStartDateTime = firstTimeStartDateTime.split(" ")[1];
									}
									if(firstTimeEndDateTime && firstTimeEndDateTime.indexOf(" ") > -1){
										firstTimeEndDateTime = firstTimeEndDateTime.split(" ")[1];
									}
									if(timeStartDateTime && timeStartDateTime.indexOf(" ") > -1){
										timeStartDateTime = timeStartDateTime.split(" ")[1];
									}
									if(timeEndDateTime && timeEndDateTime.indexOf(" ") > -1){
										timeEndDateTime = timeEndDateTime.split(" ")[1];
									}
					    			
					    			$("#recCloseTimes").html("<a onclick=\"scheduleUser.setSimpleRecommandTime('"+firstTimeStartDateTime+"', '"+firstTimeEndDateTime+"')\">" + (firstTimeStartDateTime != undefined ? (firstTimeStartDateTime + " ~ " + firstTimeEndDateTime) : "") + "</a>");	// 가장 가까운 시간
					    			$("#recOtherTimes").html("<a onclick=\"scheduleUser.setSimpleRecommandTime('"+timeStartDateTime+"', '"+timeEndDateTime+"')\">" + (timeStartDateTime != undefined ? (timeStartDateTime + " ~ " + timeEndDateTime) : "") + "</a>");		// 다른 시간
					    		}else if(res.result == "ApprovalProhibit"){
									isCanBooking = false;
									
									$("#msgOK").removeClass("active");
									$("#msgNO").addClass("active");
									$("#msgSelectResource").removeClass("active");
									$("#msgSelectTime").removeClass("active");
									$("#msgRecommand1").removeClass("active");
									$("#msgRecommand2").removeClass("active");
									$("#recLastMsg").show();
								}else{
					    			isCanBooking = true;
					    			
									$("#msgOK").addClass("active");
									$("#msgNO").removeClass("active");
									$("#msgSelectResource").removeClass("active");
					    			$("#msgSelectTime").removeClass("active");
									$("#msgRecommand1").removeClass("active");
									$("#msgRecommand2").removeClass("active");
									$("#recLastMsg").hide();
					    		}
					    	}else{
					    		Common.Error(Common.getDic("msg_apv_030"));		// 오류가 발생했습니다.
					    	}
				        },
				        error:function(response, status, error){
							CFN_ErrorAjax("/groupware/resource/check.do", response, status, error);
						}
					});
					
				}
			}else{
				isCanBooking = true;
				
				$("#msgSelectResource").addClass("active");
				$("#msgSelectTime").removeClass("active");
				$("#msgOK").removeClass("active");
				$("#msgRecommand1").removeClass("active");
				$("#msgRecommand2").removeClass("active");
				$("#recLastMsg").hide();
			}
		},
		// 간단 등록에서 자원추천했을 때, 자원 클릭시 세팅
		setSimpleRecommandResource : function(folderID){
			$("#resourceList").val(folderID);
			scheduleUser.recommandResource();
		},
		// 간단 등록에서 시간추천했을 때, 추천 클릭시 세팅
		setSimpleRecommandTime : function(startDateTime, endDateTime){
			var startHour = startDateTime.split(":")[0];
			var startMin = startDateTime.split(":")[1];
			var endHour = endDateTime.split(":")[0];
			var endMin = endDateTime.split(":")[1];
			
			$("#simpleWritePop #simpleSchDateCon [name=startHour] select").val(startHour);
			$("#simpleWritePop #simpleSchDateCon [name=startMinute] select").val(startMin);
			$("#simpleWritePop #simpleSchDateCon [name=endHour] select").val(endHour);
			$("#simpleWritePop #simpleSchDateCon [name=endMinute] select").val(endMin);
			
			scheduleUser.recommandResource();
		},
		// 간단 등록에서 상세등록으로 이동
		goDetailWritePage : function(){
			$("#simpleSubject").val($("#Subject").val());
			$("#simpleFolderType").val($("#FolderType").val());
			$("#simpleStartDate").val($("#simpleSchDateCon_StartDate").val());
			$("#simpleEndDate").val($("#simpleSchDateCon_EndDate").val());
			$("#simpleIsAllDay").val($("#IsAllDay").is(":checked") ? "Y" : "N");
			$("#simpleDescription").val($("#Description").val());
			
			$("#simpleStartHour").val(coviCtrl.getSelected('simpleSchDateCon [name=startHour]').val);
			$("#simpleStartMinute").val(coviCtrl.getSelected('simpleSchDateCon [name=startMinute]').val);
			$("#simpleEndHour").val(coviCtrl.getSelected('simpleSchDateCon [name=endHour]').val);
			$("#simpleEndMinute").val(coviCtrl.getSelected('simpleSchDateCon [name=endMinute]').val);
			$("#simpleSelectDatePicker").val($("#simpleSchDateCon [name=datePicker] select").val());
			
			//resource
			var resource = new Array();
			$("#addedResourceList").find("[id^=resource_]").each(function(){
				var resourceObj = {};
				resourceObj.FolderID = $(this).attr("value");
				resourceObj.ResourceName = $(this).html();
				resource.push(resourceObj);
			});
			$("#simpleResources").val(JSON.stringify(resource));
			
			// 커뮤니티 연동을 위함
			var CSMU = CFN_GetQueryString("CSMU");
			var communityId = CFN_GetQueryString("communityId");
			var activeKey = CFN_GetQueryString("activeKey");
			
			if(communityId != 'undefined'){
				scheduleUser.community = {};
				scheduleUser.community.descripion = $("#Description").val();
			}
			
			CoviMenu_GetContent("schedule_DetailWrite.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule"+(CSMU == "undefined" ? "" : "&CSMU="+CSMU+"&communityId="+communityId+"&activeKey="+activeKey)+"&simpleDatePicker="+$("#simpleSelectDatePicker").val());
		},
		// 상세 등록에서 자원 자동입력
		setResourceAutoInput : function(){
			$.ajax({
			    url: "/groupware/resource/getResourceList.do",
			    type: "POST",
			    data: {},
			    success: function (res) {
			    	if(res.status == "SUCCESS"){
			    		var resource;
			    		
			    		if(res.data.length > 0){
							$('#Resource').autocomplete({
								source : function(request, response){
									response($.map( res.data, function( item ) {
										var lbl = item['FolderName'];
										var val = item['FolderID'];
										
										if(lbl.indexOf(request.term) > -1){
											return {
							                	label: lbl,
							                    value: val,
												FolderID: item.FolderID,
												ResourceName: item.FolderName,
												LeastRentalTime: item.LeastRentalTime,
												opType: 'none'
							                }	
										}
						            }));
								},
								autoFocus : true,
								useEnter : false,
								multiselect : true,
								useDuplication : false,
								callBackFunction : 'callbackAutoTagResource'
							});
			    		}
			    		else
			    			$("#Resource").attr("disabled", true);
			    		
			    		// 수정화면일 경우 바인딩 후 데이터 세팅하기
			    		if(CFN_GetQueryString("eventID") != "undefined" && CFN_GetQueryString("eventID") != ""){
			    			if($("#hidResourceList_DU").val() != ""){
				    			resource = $.parseJSON($("#hidResourceList_DU").val());
								if(resource.length > 0){
									$(resource).each(function(){
										var resourceObj = $("<div></div>")
						                .addClass("ui-autocomplete-multiselect-item")
						                .attr("data-json", JSON.stringify({"label":this.ResourceName,"value":this.FolderID,"ResourceName":this.ResourceName,"FolderID":this.FolderID,"opType":"none"}))
						                .attr("data-value", this.FolderID)
						                .text(this.ResourceName)
						                .append(
						                    $("<span></span>")
						                        .addClass("ui-icon ui-icon-close")
						                        .click(function(){
						                            var item = $(this).parent();
						                            item.remove();
						                        })
						                );
										$("#resourceAutoComp .ui-autocomplete-multiselect").prepend(resourceObj);
									});
								}
			    			}
			    		}else if($("#simpleResources").val() != ""){
			    			var resourceListHTML = "";
			    			resource = $.parseJSON($("#simpleResources").val());
			    			$(resource).each(function(){
			    				var resourceObj = $("<div></div>")
			                    .addClass("ui-autocomplete-multiselect-item")
			                    .attr("data-json", JSON.stringify({"label":this.ResourceName,"value":this.FolderID,"ResourceName":this.ResourceName,"FolderID":this.FolderID,"opType":"none"}))
			                    .attr("data-value", this.FolderID)
			                    .text(this.ResourceName)
			                    .append(
			                        $("<span></span>")
			                            .addClass("ui-icon ui-icon-close")
			                            .click(function(){
			                                var item = $(this).parent();
			                                item.remove();
			                            })
			                    );
			    				$("#resourceAutoComp .ui-autocomplete-multiselect").prepend(resourceObj);
			    			});
			    			
			    			$("#simpleResources").val("");
			    		}
			    	}else{
			    		Common.Error(Common.getDic("msg_apv_030"));		// 오류가 발생했습니다.
			    	}
		        },
		        error:function(response, status, error){
					CFN_ErrorAjax("/groupware/resource/getResourceList.do", response, status, error);
				}
			});
		},
		//상세 등록에서 참석자 자동입력
		setAttendeeAutoInput : function(){
			// 사용자 값 조회
			coviCtrl.setUserWithDeptAutoTags(
					'Attendee', //타겟
					'/covicore/control/getAllUserAutoTagList.do', //url 
					{
						labelKey : 'UserName',
						addInfoKey : 'DeptName',
						valueKey : 'UserCode',
						minLength : 1,
						useEnter : true,
						multiselect : true,
						callType : "",
						select : function(event, ui){
							//if(! o.useDuplication){
				            	if ($("#attendeeAutoComp").find(".ui-autocomplete-multiselect-item[data-value='"+ ui.item.value+"'], .ui-autocomplete-multiselect-item[data-value^='"+ ui.item.value+"|']").length > 0) {
				    				Common.Warning(Common.getDic("ACC_msg_existItem"));
				    				ui.item.value = '';
				    				return;
				    			}
			            	//}
				            	
			            	if($("#ulFolderTypes").find("li[data-selvalue="+$("#FolderType").val()+"]").attr("folderType") == "Schedule.Person") {
			            		if(ui.item.value == sessionObj["UR_Code"]) {
			            			Common.Inform(Common.getDic("msg_no_self_attendant"));  //내 일정의 참석자로 본인을 등록할 수 없습니다.
			            			ui.item.value = '';
			    					return;
			    				}
			            	}
			            	
			            	// 외부 참석자 여부
			            	ui.item.IsOutsider = "N";
				            
			                $("<div></div>")
			                    .addClass("ui-autocomplete-multiselect-item")
			                    .attr("data-json", JSON.stringify(ui.item))
			                    .attr("data-value", ui.item.value)
			                    .text(ui.item.saveLabel)
			                    .append(
			                        $("<span></span>")
			                            .addClass("ui-icon ui-icon-close")
			                            .click(function(){
			                                var item = $(this).parent();
			                                //delete self.selectedItems[item.text()];
			                                item.remove();
			                            })
			                    )
			                    .insertBefore($("#Attendee"));
			                
			    	    	ui.item.value = ''; // 선택 후 input에 value값이 들어가는 문제가 있어 빈값 처리
						}
					}
				);
		},
		// 주소 자동입력
		setPlaceAutoInput : function(){
			var PlaceAutoUseYn = Common.getBaseConfig("PlaceAutoUse");
			if(PlaceAutoUseYn == "Y") {
				coviCtrl.setAddrAutoTags(
					'Place', //타겟
					{
						count : 10, 
						minLength : 1,
						useEnter : false,
						multiselect : true,
						callBackFunction : "deletePlaceInput"
					}
				);
			} else {
				$("#Place").show();
			}
		},
		// 주소 하나만 입력하도록
		deletePlaceInput : function(){
			
			if(coviCtrl.getAutoTags("Place").length > 0){
				$("#Place").hide();
			}else{
				$("#Place").show();
			}
		},
		// 상세 등록화면에서 종일 체크
		setAllDayCheck : function(setType){
			var target = "";
			if(setType === "S"){
				target = "simpleSchDateCon";
			}else{
				target = "detailDateCon";
			}
			
			if ($("#IsAllDay").is(":checked")) {
				var sStartDate = $("#" + target + "_StartDate").val();
				var sStartHour = coviCtrl.getSelected(target + ' [name=startHour]').val;
				var sStartMinute = coviCtrl.getSelected(target + ' [name=startMinute]').val;
				
				var sEndDate = $("#" + target + "_EndDate").val();
				var sEndHour = coviCtrl.getSelected(target + ' [name=endHour]').val;
				var sEndMinute = coviCtrl.getSelected(target + ' [name=endMinute]').val;
				
				$("#hidStartDate").val(sStartDate);
				$("#hidStartHour").val(sStartHour);
				$("#hidStartMinute").val(sStartMinute);
				
				$("#hidEndDate").val(sEndDate);
				$("#hidEndHour").val(sEndHour);
				$("#hidEndMinute").val(sEndMinute);
				
				coviCtrl.setSelected(target + ' [name=startHour]', "00");
				coviCtrl.setSelected(target + ' [name=startMinute]', "00");
				
				coviCtrl.setSelected(target + ' [name=endHour]', "23");
				coviCtrl.setSelected(target + ' [name=endMinute]', "59");
				
				// Disabled
				$("#" + target + " [name=startHour]").find("select").attr("disabled", true);
				$("#" + target + " [name=startMinute]").find("select").attr("disabled", true);
				$("#" + target + " [name=endHour]").find("select").attr("disabled", true);
				$("#" + target + " [name=endMinute]").find("select").attr("disabled", true);
				$("#" + target + " [name=datePicker]").find("select").attr("disabled", true);
				
				coviCtrl.setSelected(target + ' [name=datePicker]', "select");
		    } else {
				sStartDate = $("#hidStartDate").val();
				sStartHour = $("#hidStartHour").val();
				sStartMinute = $("#hidStartMinute").val();
				
				sEndDate = $("#hidEndDate").val();
				sEndHour = $("#hidEndHour").val();
				sEndMinute = $("#hidEndMinute").val();
				
				$("#" + target + "_StartDate").val(sStartDate).attr("disabled", false);
				coviCtrl.setSelected(target + ' [name=startHour]', sStartHour);
				coviCtrl.setSelected(target + ' [name=startMinute]', sStartMinute);
				
				$("#" + target + "_EndDate").val(sEndDate).attr("disabled", false);
				coviCtrl.setSelected(target + ' [name=endHour]', sEndHour);
				coviCtrl.setSelected(target + ' [name=endMinute]', sEndMinute);
				
				$("#" + target + " [name=startHour]").find("select").attr("disabled", false);
				$("#" + target + " [name=startMinute]").find("select").attr("disabled", false);
				$("#" + target + " [name=endHour]").find("select").attr("disabled", false);
				$("#" + target + " [name=endMinute]").find("select").attr("disabled", false);
				$("#" + target + " [name=datePicker]").find("select").attr("disabled", false);
		    }
		},
		setChanges: function(setType){
			scheduleUser.params.changes = {
				event: {
					changed: String(JSON.stringify(scheduleUser.origin.Event) != JSON.stringify(scheduleUser.params.Event))
				},
				date: {
					changed: String(JSON.stringify(scheduleUser.origin.Date) != JSON.stringify(scheduleUser.params.Date))
				},
				resource: {
					changed: (scheduleUser.params.Resource.find(function(el){ return el.opType == 'new' ||  el.opType == 'del' })) ? 'true' : 'false'
				},
				attendee: {
					changed: (scheduleUser.params.Attendee.find(function(el){ return el.opType == 'new' ||  el.opType == 'del' })) ? 'true' : 'false'
				},
				repeat: {
					changed: String(JSON.stringify(scheduleUser.origin.Repeat) != JSON.stringify(scheduleUser.params.Repeat)),
					type: ($("#IsRepeat").val() == 'N') ? 'del' :
						  ($("#IsRepeat").val() == 'Y' && scheduleUser.origin.Repeat.RepeatType == '') ? 'add' :
						  (JSON.stringify(scheduleUser.origin.Repeat) != JSON.stringify(scheduleUser.params.Repeat)) ? 'modify' : 'none'
				},
				notification: {
					changed: String(JSON.stringify(scheduleUser.origin.Notification) != JSON.stringify(scheduleUser.params.Notification)),
					type: ($("#IsNotification").val() == 'N' && Object.keys(scheduleUser.origin.Notification).length > 0) ? 'del' :
						  ($("#IsNotification").val() == 'Y' && Object.keys(scheduleUser.origin.Notification).length == 0) ? 'add' :
						  (JSON.stringify(scheduleUser.origin.Notification) != JSON.stringify(scheduleUser.params.Notification)) ? 'modify' : 'none'
				}
			}
		},
		// 일정 등록
		setOne : function(setType){
			/*
			 * S : 간단 등록
			 * SC: 간편작성 
			 * SAC: 개인환경설정 - 기념일 관리 - 일정 등록
			 * D : 상세 등록
			 * U : 수정
			 * F : 자주 쓰는 일정 
			 * FU : 자주 쓰는 일정 수정
			 * RU : 반복일정 개별일정
			 */
		
			Common.Progress();
			//개별호출-일괄호출
			Common.getDicList(["msg_apv_030","msg_registerGoogleSch","msg_changeGoogleSch","msg_117"]);
			
			var mode = "I";
			var eventObj = {};
			
			var FolderType = $("#FolderType").val() == "" ? $("#ulFolderTypes").find("li").attr("folderType") : $("#ulFolderTypes").find("li[data-selvalue="+$("#FolderType").val()+"]").attr("folderType");

			// 간단 등록
			if(setType == "S" || setType == "SC" || setType == "SAC"){
				eventObj = scheduleUser.setSimpleData(setType);
			}else if(setType == "D" || setType == "U" || setType == "F" || setType == "FU" || setType == "RU"){				
				if(setType == "U" || setType == "FU"){
					eventObj = scheduleUser.setDetailData(setType, FolderType == "Schedule.Google");
					mode = "U";
				}else if(setType == "RU"){
					eventObj = scheduleUser.setDetailData(setType, FolderType == "Schedule.Google");
					mode = "RU";
				} else if (setType == "D") {
					scheduleUser.origin = {"Event":{},"Date":{},"Resource":[],"Repeat":{"RepeatType":""},"Attendee":[],"Notification":{},"NotiComment":[],"fileList":[]}
					scheduleUser.params = { isNewProcess: 'Y' }
					scheduleUser.setScheduleData(setType, FolderType == "Schedule.Google");					
				} else {
					eventObj = scheduleUser.setDetailData(setType, FolderType == "Schedule.Google");
				}				
			} 
			
			if (typeof scheduleUser.params == 'object' && scheduleUser.params.isNewProcess == 'Y'){
				scheduleUser.setChanges(setType);
			}
			
			if (setType == 'F' || setType == "FU"){
				eventObj.Date = {}
			} else {
				if ((Common.getBaseConfig('IsPastSave') == '' || Common.getBaseConfig('IsPastSave') == 'N')){
					// eventObj 객체에 Date 값을 생성해서 가지고 있을 경우 조건을 확인하여 리소스 제거
					if (eventObj.Date) {
						var startDateTime = eventObj.Date.StartDate + " " + eventObj.Date.StartTime;
						if(parseInt(g_currentTime.getTime() / 1000 / 60) > parseInt(new Date(replaceDate(startDateTime)).getTime() / 1000 / 60)){
							if(eventObj.Resource) eventObj.Resource.length = 0;
						}
					}
					
					// 상세입력의 날짜/시간 필드가 존재하는 경우, 조건을 확인하여 리소스 제거
					var sDate = $("#detailDateCon_StartDate").val();
					var sTime = coviCtrl.getSelected('detailDateCon [name=startHour]').val + ":" + coviCtrl.getSelected('detailDateCon [name=startMinute]').val;			
					if (parseInt(g_currentTime.getTime() / 1000 / 60) > parseInt(new Date(replaceDate(sDate) + " " + sTime).getTime() / 1000 / 60)){
						if(eventObj.Resource) eventObj.Resource.length = 0;
					}
				}
			}
			
			// bugfix : 반복일정에서 데이터값을 '분' 단위로 변경되지 않아 발생한 이슈 수정
			if(eventObj.Repeat !== undefined) {
				if(eventObj.Repeat.AppointmentDuring !== undefined && eventObj.Repeat.AppointmentDuring.length >= 2) {
					var duringHour = eventObj.Repeat.AppointmentDuring.substring(0, eventObj.Repeat.AppointmentDuring.length - 1)
					eventObj.Repeat.AppointmentDuring = Number(duringHour) * 60; 
				}
			}
			
			var formData = new FormData();
			formData.append("mode", mode);
			if(setType == "RU"){
				var isChangeDate = eventObj.isChangeDate;
				var isChangeRes = eventObj.isChangeResource;
				
				delete eventObj.isChangeDate;
				delete eventObj.isChangeResource;
				
				formData.append("isChangeDate", isChangeDate);
				formData.append("isChangeRes", isChangeRes);
			}

			if (scheduleUser.params && (mode == 'U' || mode == 'I')){
				eventObj = scheduleUser.params;
				
				if ((Common.getBaseConfig('IsPastSave') == '' || Common.getBaseConfig('IsPastSave') == 'N')){
					// eventObj 객체에 Date 값을 생성해서 가지고 있을 경우 조건을 확인하여 리소스 제거
					if (eventObj.Date) {
						var startDateTime = eventObj.Date.StartDate + " " + eventObj.Date.StartTime;
						if(parseInt(g_currentTime.getTime() / 1000 / 60) > parseInt(new Date(replaceDate(startDateTime)).getTime() / 1000 / 60)){
							if(eventObj.Resource) eventObj.Resource.length = 0;
						}
					}
					
					// 상세입력의 날짜/시간 필드가 존재하는 경우, 조건을 확인하여 리소스 제거
					var sDate = $("#detailDateCon_StartDate").val();
					var sTime = coviCtrl.getSelected('detailDateCon [name=startHour]').val + ":" + coviCtrl.getSelected('detailDateCon [name=startMinute]').val;			
					if (parseInt(g_currentTime.getTime() / 1000 / 60) > parseInt(new Date(replaceDate(sDate) + " " + sTime).getTime() / 1000 / 60)){
						if(eventObj.Resource) eventObj.Resource.length = 0;
					}
				}
				
				// bugfix : 반복일정에서 데이터값을 '분' 단위로 변경되지 않아 발생한 이슈 수정
				if(eventObj.Repeat !== undefined) {
					if(eventObj.Repeat.AppointmentDuring !== undefined && eventObj.Repeat.AppointmentDuring.length >= 2) {
						var duringHour = eventObj.Repeat.AppointmentDuring.substring(0, eventObj.Repeat.AppointmentDuring.length - 1)
						eventObj.Repeat.AppointmentDuring = Number(duringHour) * 60; 
					}
				}
				
				eventObj.strRepeat = (eventObj.IsRepeat == 'Y') ? $("#detailDateCon span").text()+" "+Common.getSession("UR_TimeZoneDisplay") : "N"; 
			}
			formData.append("eventObj", JSON.stringify(eventObj));
			
			formData.append("fileInfos", JSON.stringify(coviFile.fileInfos));
		    for (var i = 0; i < coviFile.files.length; i++) {
		    	if (typeof coviFile.files[i] == 'object') {
		    		formData.append("files", coviFile.files[i]);
		        }
		    }
		    formData.append("fileCnt", coviFile.fileInfos.length);
			
			// 협업 스페이스 - 일정 연동
			if (Common.getBaseConfig("isUseCollabSchedule") === "Y") {
				if ($("#prjMap").attr("data-key")){
					var prjList = [];
					var arrMap = $("#prjMap").attr("data-key").split("_");
					prjList.push({"prjType":arrMap[0], "prjSeq":arrMap[1], "sectionSeq":arrMap[2]});
					
					formData.append("prjMap", JSON.stringify(prjList));
				}
			}
		    
			if(JSON.stringify(eventObj) != "{}"){
				if(FolderType != "Schedule.Google"){
					// Validation 체크
					if(scheduleUser.checkValidationSchedule(eventObj)){
						var targetBtnSelector = '';
						var targetBtnEvent = '';
						if (setType == 'S' || setType == 'SC'){
							targetBtnSelector = "#scheduleRegistBtn";
						}
						else if (setType == 'D'){
							targetBtnSelector = "#btnAdd, #btnCopy";
						}
						targetBtnEvent = $(targetBtnSelector).attr("onclick");

						$.ajax({
						    url: "/groupware/schedule/setOne.do",
						    type: "POST",
						    data: formData,
						    processData : false,
					        contentType : false,
					        beforeSend: function () {
								// 22.05.13 데이터 중복 입력 방지를 위해 ajax 실행 전 버튼의 이벤트를 제거한다.
								$(targetBtnSelector).attr("onclick", "");								
							},
						    success: function (res) {
						    	if(res.status == "SUCCESS" && res.result == "OK"){
						    		Common.Inform(res.message, "", function(){
						    			if(setType == "S")
						    				scheduleUser.refresh();
						    			else if(setType == "SC"){
						    				//scheduleUser.refresh();						    				
						    				coviCtrl.toggleSimpleMake();
						    				$(targetBtnSelector).attr("onclick", "scheduleUser.setOne('SC');");
						    				setSimpleMakeBlank($('.tabMenuArrow').find(".active").attr("type"));
						    			}else if(setType == "SAC") {
						    				Common.Close();
						    			}else if (setType == "D"){
											try
											{
												if (opener) {
													// 커뮤니티 일정 등록 완료시 이전 페이지로 이동
													if(isCommunity) {
														CoviMenu_GetContent(g_lastURL);	
													} else {
														window.close();	
													}					
												}else{
								    				CoviMenu_GetContent(g_lastURL);
												}
											}
											catch(E)
											{
							    				window.close();
											}	
										}
							    		else {
							    			CoviMenu_GetContent(g_lastURL);
						    			}
						    		});
						    	}
						    	else if(res.status == "SUCCESS" && res.result == "DUPLICATION"){
						    		Common.Warning(res.message);
									$(targetBtnSelector).attr("onclick", targetBtnEvent);
						    	}
								else if(res.status == "SUCCESS" && res.result == "RESOURCE_DUPLICATION"){
						    		Common.Warning(res.message);
						    		$(targetBtnSelector).attr("onclick", targetBtnEvent);
						    	}
						    	else {
						    		Common.Error(coviDic.dicMap["msg_apv_030"]);		// 오류가 발생했습니다.
									$(targetBtnSelector).attr("onclick", targetBtnEvent);
						    	}
						    },
						    error:function(response, status, error){
								// 22.05.13 success, error 처리 후 버튼의 이벤트를 다시 부여한다.
								$(targetBtnSelector).attr("onclick", targetBtnEvent);
								
								CFN_ErrorAjax("/groupware/schedule/setOne.do", response, status, error);
							}
						});
					}
				}
				else{
					// 구글 연동 일정 등록
					if(mode == "I"){
						Common.Confirm(coviDic.dicMap["msg_registerGoogleSch"], "", function(result){			//구글 캘린더에 일정이 등록됩니다.\n등록하시겠습니까?
							if(result)
								coverInsertGoogleEventData(setType, eventObj, "I");
						});
					}
					// 구글 연동 일정 수정
					else if(mode == "U"){
						// Alert 팝업이 있는 경우 발생하지않도록 처리
						if($("#AlertLayer").length > 0) return false;
						
						Common.Confirm(coviDic.dicMap["msg_changeGoogleSch"], "", function(result){			//구글 캘린더에 있는 일정이 수정됩니다.\n수정하시겠습니까?
							if(result)
								coverInsertGoogleEventData(setType, eventObj, "U");
						});
					}
				}
			}
			else{
				Common.Inform(coviDic.dicMap["msg_117"], "", function(){			//성공적으로 저장하였습니다.
					if(setType == "S")
						scheduleUser.refresh();
					else if (setType == "SAC")
	    				Common.Close();
		    		else
		    			CoviMenu_GetContent(g_lastURL);
				});
			}
		},
		//Validation Check
		checkValidationSchedule : function(eventObj){
			var returnVal = true;

			if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
			
			//개별호출 - 일괄호출
			Common.getDicList(["msg_Sch_020", "msg_EnterSubject","msg_EnterStartDate","msg_EnterEndDate","msg_StartDateCannotAfterEndDate","mag_Attendance81"]);
			
			// 자원 선택 여부 체크
			if(eventObj.Event != undefined){
				var folder = eventObj.Event.FolderID;
				if(folder == undefined || folder == ""){
					Common.Warning(coviDic.dicMap["msg_Sch_020"]);			//구분을 선택해주세요.
					return false;
				}
				
				// 제목 입력 여부 체크
				var subject = eventObj.Event.Subject;
				if(subject == undefined || subject == ""){
					Common.Warning(coviDic.dicMap["msg_EnterSubject"]);		//제목을 입력해주세요
					return false;
				}
			}
			
			if($("#detailDateCon_StartDate").val() > $("#detailDateCon_EndDate").val()){
				Common.Warning(coviDic.dicMap["msg_StartDateCannotAfterEndDate"]);			//시작일은 종료일 보다 이후일 수 없습니다.
				return false;
			}
			
			if($("#detailDateCon_StartDate").val() == $("#detailDateCon_EndDate").val()){
				if(coviCtrl.getSelected('detailDateCon [name=startHour]').val + ":" + coviCtrl.getSelected('detailDateCon [name=startMinute]').val > coviCtrl.getSelected('detailDateCon [name=endHour]').val + ":" + coviCtrl.getSelected('detailDateCon [name=endMinute]').val){
					Common.Warning(coviDic.dicMap["mag_Attendance81"]);
					return false;
				}
			}

			if(eventObj.Date != undefined && Object.keys(eventObj.Date).length > 0){
				if(eventObj.Date.IsRepeat !== undefined && eventObj.Date.IsRepeat == "Y") {
					var repeat = $.parseJSON($("#hidRepeatInfo").val()).ResourceRepeat;
					if(repeat.RepeatStartDate === undefined || repeat.RepeatStartDate === '') {
						Common.Warning(coviDic.dicMap["msg_EnterStartDate"]);		//시작 일자를 입력하세요
						return false;
					}
					
					if(repeat.RepeatEndDate === undefined || repeat.RepeatEndDate === '') {
						Common.Warning(coviDic.dicMap["msg_EnterEndDate"]);			//종료 일자를 입력하세요
						return false;
					}
				} else {
					// 시작일자 입력 여부 체크
					var startDate = eventObj.Date.StartDate;
					if(startDate == undefined || startDate == ""){
						Common.Warning(coviDic.dicMap["msg_EnterStartDate"]);		//시작 일자를 입력하세요
						return false;
					}
					
					// 종료일자 입력 여부 체크
					var endDate = eventObj.Date.EndDate;
					if(endDate == undefined || endDate == ""){
						Common.Warning(coviDic.dicMap["msg_EnterEndDate"]);		//종료 일자를 입력하세요
						return false;
					}
				}
			}
			
			// 21.07.26, 일정등록 미리알림 조건 추가.
			if ( (eventObj.Notification != null) && (!$.isEmptyObject(eventObj.Notification))) {
				if ( (eventObj.Notification.IsReminder == "Y") && !$.isEmptyObject(eventObj.Repeat) && (eventObj.Repeat.RepeatType == "W") ) {		// 미리 알림 설정을 했을 때 && 반복 설정을 '매주'로 지정했을 때.
					if ( checkAlarmSave(eventObj.Repeat) == "N") {	// 새로운 조건 추가(다중 요일 선택 시 미리알림 제한)
						Common.Warning(coviDic.dicMap["msg_schedulePreAlert"]);		// 알림문구(미리알림 설정 시 매주 2개 이상의 요일을 지정하시면, 최대 6개월 혹은 10회차 이하로 등록/수정 가능합니다.)
						return false;
					}
				}
			}
			
			var hasResiterCode = false;
			var selectAttendee = coviCtrl.getAutoTags("Attendee");
			$(selectAttendee).each(function(idx, el){
				
				if(eventObj.Event.FolderType == "Schedule.Person") {
					if(this.UserCode == sessionObj["UR_Code"]) {
						// 안내 후 삭제
            			Common.Inform(coviDic.dicMap["msg_no_self_attendant"]);  //내 일정의 참석자로 본인을 등록할 수 없습니다.
            			$("#attendeeAutoComp").find("div[data-value='" + sessionObj["UR_Code"] + "']").remove();
						hasResiterCode = true;
    					return false;
    				}
            	}
				
			});
			if (hasResiterCode) return false;
			
			// 최소 대여기간 체크
			var startDateTime = eventObj.Date.StartDate + " " + eventObj.Date.StartTime;
			var endDateTime = eventObj.Date.EndDate + " " + eventObj.Date.EndTime;
			if (eventObj.IsRepeat == 'Y'){
				startDateTime = CFN_GetLocalCurrentDate(_ServerDateSimpleFormat) + " " + eventObj.Repeat.AppointmentStartTime;
				if (eventObj.Repeat.AppointmentStartTime > eventObj.Repeat.AppointmentEndTime){
					endDateTime = schedule_SetDateFormat(schedule_AddDays(CFN_GetLocalCurrentDate(_ServerDateSimpleFormat), 1),'-') + " " + eventObj.Repeat.AppointmentEndTime;
				} else {
					endDateTime = CFN_GetLocalCurrentDate(_ServerDateSimpleFormat) + " " + eventObj.Repeat.AppointmentEndTime;
				}
			}
			var rentalTime = parseInt(new Date(replaceDate(endDateTime)).getTime() / 1000 / 60) - parseInt(new Date(replaceDate(startDateTime)).getTime() / 1000 / 60);
			var leastRentalTimeResource = (function(){
				var maxLeastRentalTime = 0;
				var resourceName = '';
				$.each(coviCtrl.getAutoTags("Resource"), function(idx, el){
					if (maxLeastRentalTime < el.LeastRentalTime) {
						maxLeastRentalTime = el.LeastRentalTime;	
						resourceName = el.ResourceName;
					}
				});
				return { time: maxLeastRentalTime, resource: resourceName };
			}());
			if(rentalTime < leastRentalTimeResource.time){
				var leastRentalTimeStr = '';
				if(leastRentalTimeResource.time < 60){
					leastRentalTimeStr = leastRentalTimeResource.time + Common.getDic("lbl_Minutes"); // 분
				}else{
					leastRentalTimeStr = Math.floor(leastRentalTimeResource.time/60) + Common.getDic("lbl_Time"); // 시간
					if(leastRentalTimeResource.time % 60 != 0){
						leastRentalTimeStr += " " + (leastRentalTimeResource.time % 60) + Common.getDic("lbl_Minutes"); // 분
					}
				}
				Common.Warning('['+ leastRentalTimeResource.resource +'] ' + Common.getDic("msg_cannotLeastRentalTimeBefore").replace("{0}", leastRentalTimeStr)); // 최소 대여기간보다 적게 예약할 수 없습니다.<br/>{0} 이상 예약해주세요.
				return false;
			}
			
			return returnVal;
		},
		setSimpleData : function(mode){
			var eventObj = {};
			var event = {};
			var date = {};
			var resource = new Array();
			var repeat = {};
			var attendee = new Array();
			var notification = {};
			
			event.EventType = "";
			event.LinkEventID = "";
			event.MasterEventID = "";
			
			// 사용자 입력값
			if(mode == "S"){
				event.FolderID = $("#FolderType").val() == "" ? $("#ulFolderTypes").find("li").eq(0).attr("data-selvalue") : $("#FolderType").val();
				event.FolderType = $("#FolderType").val() == "" ? $("#ulFolderTypes").find("li").eq(0).attr("folderType") : $("#ulFolderTypes").find("li[data-selvalue="+$("#FolderType").val()+"]").attr("folderType");
				
				event.Subject = $("#Subject").val();
				event.Description = $("#Description").val();
				
				date.StartDate = $("#simpleSchDateCon_StartDate").val().replaceAll(".", "-");
				date.EndDate = $("#simpleSchDateCon_EndDate").val().replaceAll(".", "-");
				date.StartTime = coviCtrl.getSelected('simpleSchDateCon [name=startHour]').val + ":" + coviCtrl.getSelected('simpleSchDateCon [name=startMinute]').val;
				date.EndTime = coviCtrl.getSelected('simpleSchDateCon [name=endHour]').val + ":" + coviCtrl.getSelected('simpleSchDateCon [name=endMinute]').val;
				
				date.IsAllDay = $("#IsAllDay").is(":checked") ? "Y" : $("#hidIsAllDay").val();
			}else if(mode == "SC"){
				event.FolderID = $("#scheduleSimpleMake #FolderType").val() == "" ? $("#scheduleSimpleMake #ulFolderTypes").find("li").eq(0).attr("data-selvalue") : $("#scheduleSimpleMake #FolderType").val();
				event.FolderType = $("#scheduleSimpleMake #FolderType").val() == "" ? $("#scheduleSimpleMake #ulFolderTypes").find("li").eq(0).attr("folderType") : $("#scheduleSimpleMake #ulFolderTypes").find("li[data-selvalue="+$("#scheduleSimpleMake #FolderType").val()+"]").attr("folderType");
				
				event.Subject = $("#scheduleSimpleMake #Subject").val();
				event.Description = $("#hidDescription").val();
				
				date.StartDate = $("#scheduleSimpleMake #simpleSchDateCon_StartDate").val().replaceAll(".", "-");
				date.EndDate = $("#scheduleSimpleMake #simpleSchDateCon_EndDate").val().replaceAll(".", "-");
				date.StartTime = coviCtrl.getSelected('scheduleSimpleMake #simpleSchDateCon [name=startHour]').val + ":" + coviCtrl.getSelected('scheduleSimpleMake #simpleSchDateCon [name=startMinute]').val;
				date.EndTime = coviCtrl.getSelected('scheduleSimpleMake #simpleSchDateCon [name=endHour]').val + ":" + coviCtrl.getSelected('scheduleSimpleMake #simpleSchDateCon [name=endMinute]').val;
				
				date.IsAllDay = $("#IsAllDay").is(":checked") ? "Y" : "N";
			}else{
				event.FolderID = $("#scheduleSimpleMake #FolderType").val() == "" ? $("#scheduleSimpleMake #ulFolderTypes").find("li").eq(0).attr("data-selvalue") : $("#scheduleSimpleMake #FolderType").val();
				event.FolderType = $("#scheduleSimpleMake #FolderType").val() == "" ? $("#scheduleSimpleMake #ulFolderTypes").find("li").eq(0).attr("folderType") : $("#scheduleSimpleMake #ulFolderTypes").find("li[data-selvalue="+$("#scheduleSimpleMake #FolderType").val()+"]").attr("folderType");
				
				event.Subject = $("#scheduleSimpleMake #Subject").val();
				event.Description = $("#hidDescription").val();
				
				date.StartDate = CFN_GetQueryString("anni_StartDate").replaceAll(".", "-");
				date.EndDate = CFN_GetQueryString("anni_EndDate").replaceAll(".", "-");
				date.StartTime = "00:00"
				date.EndTime = "23:00"
					
				date.IsAllDay = $("#IsAllDay").is(":checked") ? "Y" : "N";
			}
			
			// 고정값 세팅
			event.InlineImage = "";
			event.Place = "";
			event.IsPublic = "Y";
			event.IsDisplay = "Y";
			event.IsInviteOther = "N";
			event.ImportanceState = "N";
			event.Place = "";
			
			date.IsRepeat = "N";
			
			notification.IsNotification = "N";
			notification.IsReminder = "N";
			notification.ReminderTime = "10";
			notification.IsCommentNotification = "N";
			notification.MediumKind = "";
			
			//resource
			$("#addedResourceList").find("[id^=resource_]").each(function(){
				var resourceObj = {};
				resourceObj.FolderID = $(this).attr("value");
				resourceObj.ResourceName = $(this).html();
				resource.push(resourceObj);
			});
			
			eventObj.Event = event;
			eventObj.Date = date;
			eventObj.Resource = resource;
			eventObj.Repeat = repeat;
			eventObj.Attendee = attendee;
			eventObj.Notification = notification;
			
			return eventObj;
		},
		setParamEvent: function(setType){
			var event = $.extend(true, {}, scheduleUser.origin.Event);
			event.FolderID = $("#FolderType").val() == "" ? $("#ulFolderTypes").find("li").eq(0).attr("data-selvalue") : $("#FolderType").val();
			event.FolderType = $("#FolderType").val() == "" ? $("#ulFolderTypes").find("li").eq(0).attr("folderType") : $("#ulFolderTypes").find("li[data-selvalue="+$("#FolderType").val()+"]").attr("folderType");						//TODO 상황에 따라 다른값에 대해서 처리 필요
			event.Subject = $("#Subject").val();
			event.Place = coviCtrl.getAutoTags("Place").length > 0 ? coviCtrl.getAutoTags("Place")[0].label :  $("#Place").val();		//장소
			event.IsPublic = $("#IsPublic").is(":checked") ? "N" : "Y";
			event.IsDisplay = "Y";
			event.IsInviteOther = $("#IsInviteOther").is(":checked") ? "Y" : "N";
			event.ImportanceState = $("#ImportanceState").val() == "" ? "N" : $("#ImportanceState").val();
			
			// 본문 에디터 혹은 TextArea
			if($("#pSwitchEditor").attr("value") == "textarea"){
				event.Description = $("#Description").val();
				if (typeof event.InlineImage != 'undefined') event.InlineImage = '';
			}else{
				event.Description = coviEditor.getBody(g_editorKind, 'tbContentElement');
				event.InlineImage = coviEditor.getImages(g_editorKind, 'tbContentElement');
			}

			if(setType == "F" || setType == "FU") {
				event.EventType = "F";
				event.IsDisplay = "N";
			} else if(setType == "RU") {
				event.MasterEventID = CFN_GetQueryString("eventID");
				event.EventType = "M";
			} else {
				event.EventType = "";
			}
			return event;
		},
		setParamDate: function(){
			var date = $.extend(true, {}, scheduleUser.origin.Date);
			if ($("#IsRepeat").val() != "Y") {
				date.StartDate = $("#detailDateCon_StartDate").val().replaceAll(".", "-");
				date.EndDate = $("#detailDateCon_EndDate").val().replaceAll(".", "-");
				date.StartTime = coviCtrl.getSelected('detailDateCon [name=startHour]').val + ":" + coviCtrl.getSelected('detailDateCon [name=startMinute]').val;	//coviCtrl.getSelected('detailDateCon [name=startDate]').val;
				date.EndTime = coviCtrl.getSelected('detailDateCon [name=endHour]').val + ":" + coviCtrl.getSelected('detailDateCon [name=endMinute]').val;	//coviCtrl.getSelected('detailDateCon [name=endDate]').val;
				date.IsAllDay = $("#IsAllDay").is(":checked") ? "Y" : "N";
				date.IsRepeat = $("#IsRepeat").val() == "" ? "N" : $("#IsRepeat").val();
			}
			
			return date;
		},
		setParamResource: function(){
			var resource = [];
			var selectResource = coviCtrl.getAutoTags("Resource");
			$.each(selectResource, function(idx, el){
				el.opType = (JSON.stringify(scheduleUser.origin.Resource).indexOf(el.FolderID) == -1) ? "new" : el.opType;
				resource.push(el);
			});
			$.each(scheduleUser.origin.Resource, function(idx, el){
				if (JSON.stringify(resource).indexOf(el.FolderID) == -1){		//기존 데이터가 신규 자원에 없는 경우, 삭제로 추가
					el.opType = "del";
					resource.push(el);
				}
			});
			return resource;
		},
		setParamAttendee: function(){
			var attendee = [];
			var selectAttendee = coviCtrl.getAutoTags("Attendee");
			$.each(selectAttendee, function(idx, el){
				if($("#ulFolderTypes").find("li[data-selvalue="+$("#FolderType").val()+"]").attr("folderType") == "Schedule.Person" && el.UserCode == sessionObj["UR_Code"]) {
        			Common.Inform(coviDic.dicMap["msg_no_self_attendant"]);  //내 일정의 참석자로 본인을 등록할 수 없습니다.
        			$("#attendeeAutoComp").find("div[data-value='" + sessionObj["UR_Code"] + "']").remove();
					return;
            	}
				if(scheduleUser.origin.isGoogle == 'Y') el.UserName = (this.MailAddress == undefined) ? this.label : this.MailAddress;
				
				if (el.UserCode) {		// 내부참석자
					el.opType = (JSON.stringify(scheduleUser.origin.Attendee).indexOf(el.UserCode) == -1) ? "new" : el.opType; //기존 데이터에 없는 경우, 신규로 추가
				}
				else {					// 외부참석자, 참석자는 일괄 삭제 후 재등록하므로, 
					el.UserName = this.label;
					el.UserCode = "";
					el.IsOutsider = "Y";
					el.IsAllow = "Y";
					el.opType = "new";
				}
				attendee.push(el);
			});
			
			$.each(scheduleUser.origin.Attendee, function(idx, el){
				if (el.IsOutsider == 'N') {
					if (JSON.stringify(attendee).indexOf(el.UserCode) == -1){		//기존 데이터가 신규 참석자에 없는 경우, 삭제로 추가
						el.opType = "del";
						attendee.push(el);
					}
				}
			});
			return attendee;
		},
		setParamRepeat: function(){
			return ($("#hidRepeatInfo").val() != '') ? $.parseJSON($("#hidRepeatInfo").val()).ResourceRepeat : {};
		},
		setParamNotification: function(){
			if(typeof scheduleUser.origin.Notification != 'undefined' && typeof scheduleUser.origin.Notification == 'object') {
				var notification = JSON.parse(JSON.stringify(scheduleUser.origin.Notification));
				notification.IsNotification = $("#IsNotification").val() == "" ? "N" : $("#IsNotification").val();
				notification.IsReminder = $("#IsReminder").val();
				notification.ReminderTime = $("#ReminderTime option:selected").val() == "" ? "10" : $("#ReminderTime option:selected").val();
				notification.IsCommentNotification = $("#IsCommentNotification").val();
				//notification.MediumKind = "";
				return notification;
			}
		},
		setScheduleData: function(setType, isGoogle){
			scheduleUser.params.Event = scheduleUser.setParamEvent(setType);
			scheduleUser.params.Date = scheduleUser.setParamDate();
			scheduleUser.params.Resource = scheduleUser.setParamResource();
			scheduleUser.params.Attendee = scheduleUser.setParamAttendee();
			scheduleUser.params.Repeat = scheduleUser.setParamRepeat();
			scheduleUser.params.Notification = scheduleUser.setParamNotification();
			
			if (!(typeof isCopy != 'undefined' && isCopy == 'Y')) {
				if (CFN_GetQueryString("eventID") != 'undefined') scheduleUser.params.EventID = CFN_GetQueryString("eventID");
				if (CFN_GetQueryString("dateID") != 'undefined') scheduleUser.params.DateID = CFN_GetQueryString("dateID");
				if (CFN_GetQueryString("repeatID") != 'undefined') scheduleUser.params.RepeatID = CFN_GetQueryString("repeatID");
			}
			
			if (CFN_GetQueryString("isTemplate") == 'Y' && setType == 'D') scheduleUser.params.EventType = 'F';
			
			scheduleUser.params.IsRepeat = $("#IsRepeat").val();
			scheduleUser.params.FolderID = scheduleUser.params.Event.FolderID;
			scheduleUser.params.RegisterCode = scheduleUser.params.Event.RegisterCode;
		},
		setDetailData : function(setType, isGoogle){
			if (typeof scheduleUser.origin == 'object' && setType != 'FU'){
				scheduleUser.params = {
					isNewProcess: 'Y'
				}
				scheduleUser.setScheduleData(setType, isGoogle);
			}
			
			var eventObj = {};
			var event = {};
			var date = {};
			var resource = new Array();
			var repeat = {};
			var attendee = new Array();
			var notification = {};
			
			//개별호출 - 일괄호출
			// 21.07.26, 일정관리, 미리알림 조건 추가, "msg_schedulePreAlert" 추가.
			Common.getDicList(["msg_no_self_attendant", "msg_schedulePreAlert"]);
			
			// 사용자 입력값
			event.FolderID = $("#FolderType").val() == "" ? $("#ulFolderTypes").find("li").eq(0).attr("data-selvalue") : $("#FolderType").val();
			event.FolderType = $("#FolderType").val() == "" ? $("#ulFolderTypes").find("li").eq(0).attr("folderType") : $("#ulFolderTypes").find("li[data-selvalue="+$("#FolderType").val()+"]").attr("folderType");						//TODO 상황에 따라 다른값에 대해서 처리 필요
			event.LinkEventID = "";						//TODO 상황에 따라 다른값에 대해서 처리 필요
			event.MasterEventID = "";					//TODO 상황에 따라 다른값에 대해서 처리 필요
			event.Subject = $("#Subject").val();
			event.Place = coviCtrl.getAutoTags("Place").length > 0 ? coviCtrl.getAutoTags("Place")[0].label :  $("#Place").val();		//장소
			event.IsPublic = $("#IsPublic").is(":checked") ? "N" : "Y";
			event.IsDisplay = "Y";
			event.IsInviteOther = $("#IsInviteOther").is(":checked") ? "Y" : "N";
			event.ImportanceState = $("#ImportanceState").val() == "" ? "N" : $("#ImportanceState").val();
			
			// 본문 에디터 혹은 TextArea
			if($("#pSwitchEditor").attr("value") == "textarea"){
				event.Description = $("#Description").val();
				event.InlineImage = '';
			}else{
				event.Description = coviEditor.getBody(g_editorKind, 'tbContentElement');
				event.InlineImage = coviEditor.getImages(g_editorKind, 'tbContentElement');
			}
				
			// EventType
			/* TODO
			 * M: 반복일정 중 개별일정 , A: 개인일정(참석자가 승인하여 생긴 개인일정), F: 자주 쓰는 일정
			 */
			if(setType == "F" || setType == "FU"){
				event.EventType = "F";
				event.IsDisplay = "N";
			}else if(setType == "RU"){
				event.MasterEventID = CFN_GetQueryString("eventID");
				event.EventType = "M";
			}else{
				event.EventType = "";
			}
			eventObj.Event = event;
			
			if(setType != "F" && setType != "FU"){
				if($("#IsRepeat").val() == "Y"){
					date.StartDate = "";
					date.EndDate = "";
					date.StartTime = "";
					date.EndTime = "";
					
					repeat = $.parseJSON($("#hidRepeatInfo").val()).ResourceRepeat;
				}else{
					date.StartDate = $("#detailDateCon_StartDate").val().replaceAll(".", "-");
					date.EndDate = $("#detailDateCon_EndDate").val().replaceAll(".", "-");
					date.StartTime = coviCtrl.getSelected('detailDateCon [name=startHour]').val + ":" + coviCtrl.getSelected('detailDateCon [name=startMinute]').val;	//coviCtrl.getSelected('detailDateCon [name=startDate]').val;
					date.EndTime = coviCtrl.getSelected('detailDateCon [name=endHour]').val + ":" + coviCtrl.getSelected('detailDateCon [name=endMinute]').val;	//coviCtrl.getSelected('detailDateCon [name=endDate]').val;
					
					repeat = {};
				}
				
				date.IsAllDay = $("#IsAllDay").is(":checked") ? "Y" : "N";
				date.IsRepeat = $("#IsRepeat").val() == "" ? "N" : $("#IsRepeat").val();
				
			}else{
				//date.StartDate = "";
				//date.EndDate = "";
				//date.StartTime = "";
				//date.EndTime = "";
				
				// 자주쓰는 일정등록시 validation 문제로 아래로 변경함.
				if(setType == "FU" && $("#IsRepeat").val() == "Y"){
					date.StartDate = "";
					date.EndDate = "";
					date.StartTime = "";
					date.EndTime = "";
					
					date.IsAllDay = "N";
					date.IsRepeat = "N";
				}else{
					date.StartDate = $("#detailDateCon_StartDate").val().replaceAll(".", "-");
					date.EndDate = $("#detailDateCon_EndDate").val().replaceAll(".", "-");
					date.StartTime = coviCtrl.getSelected('detailDateCon [name=startHour]').val + ":" + coviCtrl.getSelected('detailDateCon [name=startMinute]').val;	//coviCtrl.getSelected('detailDateCon [name=startDate]').val;
					date.EndTime = coviCtrl.getSelected('detailDateCon [name=endHour]').val + ":" + coviCtrl.getSelected('detailDateCon [name=endMinute]').val;	//coviCtrl.getSelected('detailDateCon [name=endDate]').val;
					
					date.IsAllDay = "N";
					date.IsRepeat = "N";
				}
			}
			
			//알림
			//if($("#divNotification:hidden").length == 0){
				// notification.IsNotification = $("#IsNotification").val() == "" ? "N" : $("#IsNotification").val();
				notification.IsNotification = $("#IsNotification").val() == "" ? "N" : $("#IsNotification").val();
				notification.IsReminder = $("#IsReminder").val();
				notification.ReminderTime = $("#ReminderTime option:selected").val() == "" ? "10" : $("#ReminderTime option:selected").val();
				notification.IsCommentNotification = $("#IsCommentNotification").val();
				notification.MediumKind = "";
			//}
			
			//resource
			var oldResources = [];
			if(setType == "U" && updateScheduleDataObj.Resource) {
				$(updateScheduleDataObj.Resource).each(function(idx, data) {
					oldResources.push(data.FolderID);
				});
			}
				
			//함수이용
			var selectResource = coviCtrl.getAutoTags("Resource");
			$(selectResource).each(function(){
				var resourceObj = {};
				resourceObj.FolderID = this.value;
				resourceObj.ResourceName = this.label;
				
				if(oldResources.indexOf(this.value) == -1)
					resourceObj.IsNew = "Y";
				else
					resourceObj.IsNew = "N";
				
				resource.push(resourceObj);
			});
			
			// folderid 순으로 정렬 ( update obj와 일치시키기 위해 )
			resource.sort(function(a,b) { 
				if(a.FolderID > b.FolderID) return 1; 
				if(a.FolderID == b.FolderID) return 0; 
				if(a.FolderID < b.FolderID) return -1;
			});
			
			//attendee
			//함수이용
			var selectAttendee = coviCtrl.getAutoTags("Attendee");
			$(selectAttendee).each(function(){
				if($("#ulFolderTypes").find("li[data-selvalue="+$("#FolderType").val()+"]").attr("folderType") == "Schedule.Person") {
					if(this.UserCode == sessionObj["UR_Code"]) {
						// 안내 후 삭제
            			Common.Inform(coviDic.dicMap["msg_no_self_attendant"]);  //내 일정의 참석자로 본인을 등록할 수 없습니다.
            			$("#attendeeAutoComp").find("div[data-value='" + sessionObj["UR_Code"] + "']").remove();
    					return;
    				}
            	}
				
				var attendeeObj = {};
				
				attendeeObj.UserName = isGoogle ? (this.MailAddress == undefined ? this.label : this.MailAddress) : this.label;
				if(!this.hasOwnProperty("IsOutsider")){
					attendeeObj.UserCode = "";
					attendeeObj.IsOutsider = "Y";
					attendeeObj.IsAllow = "N";
				}else{
					attendeeObj.UserCode = this.value.split("|")[0];
					attendeeObj.IsAllow = this.value.split("|")[1] == undefined ? "" : this.value.split("|")[1];
					attendeeObj.IsOutsider = "N";
				}
				attendeeObj.dataType = "NEW";
				attendee.push(attendeeObj);
			});
			
			
			eventObj.Date = date;
			eventObj.Resource = resource;
			eventObj.Repeat = repeat;
			eventObj.Attendee = attendee;
			eventObj.Notification = notification;
			
			// 수정할 경우
			if(setType == "U" || setType == "FU"){
				// 구글일 경우 비교하지 않음
				if(!isGoogle){
					if(updateScheduleDataObj.IsGoogle == undefined){
						// 비교에 불필요한 키 삭제
						$$(updateScheduleDataObj).find("Event").remove("FolderName");
						$$(updateScheduleDataObj).find("Event").remove("FolderColor");
						$$(updateScheduleDataObj).find("Event").remove("RegisterData");
						$$(updateScheduleDataObj).find("Event").remove("RegisterDept");
						$$(updateScheduleDataObj).find("Event").remove("RegisterPhoto");
						$$(updateScheduleDataObj).find("Event").remove("RegistDate");
						$$(updateScheduleDataObj).find("Event").remove("MailAddress");
						$$(updateScheduleDataObj).find("Resource").concat().remove("TypeName");
						$$(updateScheduleDataObj).find("Attendee").concat().remove("DeptCode");
						$$(updateScheduleDataObj).find("Attendee").concat().remove("DeptName");
						$$(updateScheduleDataObj).find("NotiComment").remove();
						
						$$(eventObj).find("Event").remove("IsDisplay");
						
						// 비교에 사용 안함
						$$(updateScheduleDataObj).find("Date").remove("RepeatID");
						
						if($$(updateScheduleDataObj).find("Date").attr("IsRepeat") == "N" && $$(eventObj).find("Date").attr("IsRepeat") == "N"){
							$$(updateScheduleDataObj).find("Repeat").remove();
							$$(eventObj).find("Repeat").remove();
						}
						
						// eventObj와 updateScheduleDataObj 비교
						//eventObj = compareEventObject(eventObj, updateScheduleDataObj);
						//eventObj = updateScheduleDataObj;
						// 참석자 데이터 별도 비교 필요
						if(eventObj.Attendee != undefined){
							var oldData = updateScheduleDataObj.Attendee;
							var newData = attendee;
							var delArray = new Array();
							var isModify = false;
							var isAdd = false;
							
							$(oldData).each(function(i, oObj){
								isAdd = false;
								$(newData).each(function(j, nObj){
									if(oObj.dataType == "OLD" && oObj.UserCode == nObj.UserCode && oObj.UserName == nObj.UserName){
										nObj.dataType = "OLD";
										isAdd = true;
										return false;
									}
								});
								if(!isAdd){
									oObj.dataType = "DEL";
									delArray.push(oObj);
								}
							});
							
							newData = newData.concat(delArray);
							$(newData).each(function(){
								if(this.dataType == "NEW" || this.dataType == "DEL"){
									isModify = true;
									return false;
								}
							});
							
							if(isModify)
								eventObj.Attendee = newData;
							else
								$$(eventObj).remove("Attendee");
							
						}
					}
				}
				
				eventObj.EventID = CFN_GetQueryString("eventID");
				eventObj.DateID = CFN_GetQueryString("dateID");
				eventObj.RepeatID = CFN_GetQueryString("repeatID");
				eventObj.RegisterCode = event.RegisterCode;
				
				// 미리알림을 위한 데이터
				eventObj.Subject = eventObj.Event == undefined ? updateScheduleDataObj.Event.Subject : eventObj.Event.Subject;
				eventObj.FolderID = eventObj.FolderID == undefined ? updateScheduleDataObj.Event.FolderID : eventObj.Event.FolderID;
			}
			// TODO 반복예약 개별 등록
			else if(setType == "RU"){
				var tempEventObj;
				
				// 비교에 불필요한 키 삭제
				$$(updateScheduleDataObj).find("Event").remove("FolderName");
				$$(updateScheduleDataObj).find("Event").remove("FolderColor");
				$$(updateScheduleDataObj).find("Event").remove("RegisterData");
				$$(updateScheduleDataObj).find("Event").remove("RegisterDept");
				$$(updateScheduleDataObj).find("Date").remove("IsRepeat");
				$$(updateScheduleDataObj).find("Resource").concat().remove("TypeName");
				$$(updateScheduleDataObj).find("Attendee").concat().remove("DeptCode");
				$$(updateScheduleDataObj).find("Attendee").concat().remove("DeptName");
				$$(updateScheduleDataObj).find("NotiComment").remove();
				
				$$(eventObj).find("Event").remove("IsDisplay");
				$$(eventObj).find("Date").remove("IsRepeat");
				
				//TODO 반복 관련 추가 개발 필요
				$$(updateScheduleDataObj).find("Repeat").remove();
				$$(eventObj).find("Repeat").remove();
				
				// eventObj와 updateScheduleDataObj 비교
				tempEventObj = compareEventObject(eventObj, updateScheduleDataObj);
				
				var isChangeDate = $$(tempEventObj).find("Date").length > 0;
				var isChangeResource = $$(tempEventObj).find("Resource").length > 0;
				
				eventObj.EventID = CFN_GetQueryString("eventID");
				eventObj.DateID = CFN_GetQueryString("dateID");
				eventObj.RegisterCode = event.RegisterCode;
				
				eventObj.isChangeDate = isChangeDate;
				eventObj.isChangeResource = isChangeResource;
			}
			
			return eventObj;
		},
		// 간단 조회창 열기
		setSimpleViewPopup : function(obj, e){
			if($$(schAclArray).find("read").concat().find("[FolderID="+$(obj).attr("folderid")+"]").length > 0 || $$(schAclArray).find("attendant").concat().find("[EventID="+$(obj).attr("eventid")+"]").length > 0){		// 읽기 권한 체크
				var popupObj;
				
				$("#read_popup").load("/groupware/schedule/getSimpleViewView.do", function(){
					if ($("article[id=popup]").html() != '') $("article[id=popup]").html('');
					
					var eventID = $(obj).attr("eventid");
					var dateID = $(obj).attr("dateid");
					var repeatID = $(obj).attr("repeatid");
					var isRepeat = $(obj).attr("isrepeat");
					var folderID = $(obj).attr("folderid");
					var isGoogle = $(obj).attr("isGoogle");
					
					$("#eventID").val(eventID);
					$("#dateID").val(dateID);
					$("#repeatID").val(repeatID);
					$("#isRepeat").val(isRepeat);
					$("#folderID").val(folderID);
					
					scheduleUser.setSimpleViewTopLeft(e, obj);
					g_isPopup = true;
					popObj = obj;
					
			    	// 데이터 세팅
					scheduleUser.setViewData("S", eventID, dateID, folderID, isRepeat, isGoogle);	
			    	
			    	// 자주 쓰는 일정 버튼 onclick
			    	$("#btnAddTemplate").attr("onclick", "scheduleUser.addTemplateScheduleData("+eventID+", 'S')");
				});
			}else{
				Common.Warning(Common.getDic("msg_noViewACL"));	//읽기 권한이 없습니다.
			}
		},
		// 간단 조회창 위치 지정
		setSimpleViewTopLeft : function(e, obj){
			var top = 0;
			var left = 0;
			
			if(g_viewType == "M"){
				var calBody = $(obj).parent().parent().parent().parent().parent();
				var tr = $(obj).parent().parent();
				var td = $(obj).parent();
				var calBodyPrev = $(calBody).prev();
				
				while($(calBodyPrev).length > 0){
					top += $(calBodyPrev).height();
					calBodyPrev = $(calBodyPrev).prev();
				}
				
				top +=($(tr).height() * (Number($(tr).attr("rowno"))+1)) + 32;
				top += pxToNumber($(".calTopCont").css("height")) + $(".calMonHeader").height() + 8;
				left = ($("#monthDate").width()+1) * Number($(td).attr("day"));
				left += pxToNumber($(".scheduleContent").css("padding-left")) + 4;
				
				if(left > (pxToNumber($(".scheduleContent").css("width")) - pxToNumber($(".schViewLayerPopup").css("width")))){
					left = pxToNumber($(".scheduleContent").css("width")) - pxToNumber($(".schViewLayerPopup").css("width"));
		        }
				if(top > ($(".scheduleContent").height() - pxToNumber($(".schViewLayerPopup").css("height")))){
					top = top - pxToNumber($(".schViewLayerPopup").css("height")) - $(tr).height();
		        }
				
			}else if(g_viewType == "W" ||g_viewType == "D" ){
				left = e.pageX - $(".cRContBottom").offset().left;
				top = e.pageY - ($(".cRContBottom").offset().top - $(".cRContBottom").scrollTop());
				if(CFN_GetQueryString("communityId") != "undefined"){
					left += $(".individualLeftCont").innerWidth();
					top += 370;
            		
	            	if(left > ($("#content").innerWidth() - $(".individualLeftCont").innerWidth() + 89)){
	            		left = $("#content").innerWidth() - $(".individualLeftCont").innerWidth() + 89 ;
		            }
	            	if(top > ($(".individualCommunity").height() - $(".schViewLayerPopup").height() - ($("#portContent").height() - $("#content").height()) + 2)){
	            		top = $(".individualCommunity").height() - $(".schViewLayerPopup").height() - ($("#portContent").height() - $("#content").height()) + 2;
		            }
            	}else{
	            	if(left > ($(".scheduleContent").width() - $(".schViewLayerPopup").width())){
	            		left = $(".scheduleContent").width() - $(".schViewLayerPopup").width();
		            }
		            if(top > ($(".scheduleContent").height() - ($(".schViewLayerPopup").height() + 2))){
		            	top = $(".scheduleContent").height() - ($(".schViewLayerPopup").height() + 2);
		            }
            	}
			}
			$("#read_popup").css("left", left+"px") ;
			$("#read_popup").css("top", top+"px");
		},
		//상세 조회창
		goDetailViewPage : function(mode, eventID, dateID, repeatID, isRepeat, folderID){
			if(mode != "LinkSchedule"){
				g_lastURL = location.href.replace(location.origin, "");
			}
			
			eventID = $("#eventID").val() == undefined ? eventID : $("#eventID").val();
			dateID = $("#dateID").val() == undefined ? dateID : $("#dateID").val();
			repeatID = $("#repeatID").val() == undefined ? repeatID : $("#repeatID").val();
			isRepeat = $("#isRepeat").val() == undefined ? isRepeat : $("#isRepeat").val();
			folderID = $("#folderID").val() == undefined ? folderID : $("#folderID").val();
			
			// 커뮤니티 연동을 위함
			var CSMU = CFN_GetQueryString("CSMU");
			var communityId = CFN_GetQueryString("communityId");
			var activeKey = CFN_GetQueryString("activeKey");
			
			if(mode == "AttendRequest"){
				Common.open("","schedule_detail_pop",Common.getDic("lbl_DetailView"),'/groupware/schedule/goScheduleDetailPopup.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule'			//상세보기
						+ '&eventID=' + eventID 
						+ '&dateID=' + dateID 
						+ "&repeatID=" + repeatID
						+ '&isRepeat=' + isRepeat 
						+ '&folderID=' + folderID
						+ '&isAttendee=Y'
						+ ((isRepeat == 'Y') ? '&isRepeatAll=Y' : '')
						+ '&viewType=Popup',"1050px","632px","iframe",true,null,null,true);
			} else if(isRepeat == "Y"){
				Common.getDicList(["msg_ReservationView_01","lbl_ReservationView_01","lbl_ReservationView_02"]);//다국어 파싱
				var showRepeatHTML = getRepeatAllOROnlyHTML("V", eventID, dateID, folderID, repeatID, mode);
				Common.open("","showRepeat",Common.getDic("lbl_ScheduleView_03"), showRepeatHTML, "270px","230px","html",true,null,null,true);			//반복 일정 열기
			} else if(mode == "MyInfo") {
				//Common.Close();
				window.open("/groupware/layout/schedule_DetailView.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule"
						+(CSMU == "undefined" ? "" : "&CSMU="+CSMU+"&communityId="+communityId+"&activeKey="+activeKey)
						+ "&eventID=" + eventID
						+ "&dateID=" + dateID
						+ "&repeatID=" + repeatID
						+ "&isRepeat=" + isRepeat
						+ "&folderID=" + folderID, "_blank");
			} else if(mode == "Webpart") {
				Common.open("","schedule_detail_pop",Common.getDic("lbl_DetailView"),'/groupware/schedule/goScheduleDetailPopup.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule'			//상세보기
						+'&eventID=' + eventID 
						+ '&dateID=' + dateID 
						+ "&repeatID=" + repeatID
						+ '&isRepeat=' + isRepeat 
						+ '&folderID=' + folderID
						+ '&viewType=Popup',"1050px","632px","iframe",true,null,null,true);
			} else if(mode == "LinkSchedule") {
				Common.open("","schedule_detail_pop",Common.getDic("lbl_LinkSchedule"),'/groupware/schedule/goScheduleDetailPopup.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule'			//연결일정
						+'&eventID=' + eventID 
						+ '&dateID=' + dateID 
						+ "&repeatID=" + repeatID
						+ '&isRepeat=' + isRepeat 
						+ '&folderID=' + folderID
						+ '&viewType=Popup',"1050px","632px","iframe",true,null,null,true);
			} else {
				CoviMenu_GetContent("schedule_DetailView.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule"
						+(CSMU == "undefined" ? "" : "&CSMU="+CSMU+"&communityId="+communityId+"&activeKey="+activeKey)
						+ "&eventID=" + eventID
						+ "&dateID=" + dateID
						+ "&repeatID=" + repeatID
						+ "&isRepeat=" + isRepeat
						+ "&folderID=" + folderID);
			}
		},
		// 검색 관련 Control 세팅
		setSearchControl : function(){
			// 검색 상태 Select Box 세팅
			
			target = 'searchDateCon';
			
			var timeInfos = {
					width : "80",
					H : "",
					W : "1,2,3,4", //주 선택
					M : "1,2", //달 선택
					Y : "1" //년도 선택
				};
			
			var initInfos = {
					useCalendarPicker : 'Y',	//캘린더 picker의 사용여부로, 날짜를 선택하는 달력의 사용여부를 묻는 옵션입니다.
					useTimePicker : 'N',	//time picker의 사용여부로, 00:00 부터 23:00 까지의 시간을 선택하는 select box의 사용여부를 묻는 옵션입니다.
					useBar : 'Y'	//time picker 사이의 bar의 사용여부를 묻는 옵션입니다.
				};
			
			coviCtrl.renderDateSelect(target, timeInfos, initInfos);
			
			coviCtrl.setSelected('searchDateCon [name=datePicker]', "select");	//coviCtrl.clickSelectListBox($("[data-codename=선택]"), 'selPickerChange');
			$("#searchDateCon_StartDate").val("");
			$("#searchDateCon_EndDate").val("");
			
			$("#searchDateCon img.ui-datepicker-trigger").on("click", function(){
				var nowDate = CFN_GetLocalCurrentDate("yyyy.MM.dd");
				var sDate = $("#searchDateCon_StartDate").val();
				var eDate = $("#searchDateCon_EndDate").val();
				
				if(!sDate && !eDate){
					$("#searchDateCon_StartDate").val(nowDate);
					$("#searchDateCon_EndDate").val(nowDate);
				}
			});
		},
		//조회창 데이터 세팅
		setViewData : function(mode, eventID, dateID, folderID, isRepeat, isGoogle, isPop){
			$("#attach_icon").hide();
			
			/**
			 * mode : S - 간단 조회, D - 상세 조회, DU - 상세 등록(수정화면)
			 */
			//개별호출 - 일괄호출
			Common.getDicList(["msg_noViewACL","btn_Edit","btn_delete","msg_apv_030","msg_scheduleModifyOrDelete"]);
			// 구글 연동 체크
			if(isGoogle != "Y" && Number(eventID)){
				$.ajax({
				    url: "/groupware/schedule/goOne.do",
				    type: "POST",
				    data: {
				    	"mode" : mode,
				    	"lang" : lang,
				    	"EventID" : eventID,
				    	"DateID" : dateID,
				    	"FolderID" : folderID,
				    	"IsRepeat" : isRepeat,
				    	"UserCode" : userCode
					},
				    success: function (res) {
				    	if(res.status == "SUCCESS"){
				    		if(JSON.stringify(res.data) != "{}"){
								var tempStartDateTime = CFN_TransLocalTime(res.data.Date.StartDate + ' ' + res.data.Date.StartTime, 'yyyy-MM-dd HH:mm');
								res.data.Date.StartDate = tempStartDateTime.split(' ')[0];
								res.data.Date.StartTime = tempStartDateTime.split(' ')[1];
								var tempEndDateTime = CFN_TransLocalTime(res.data.Date.EndDate + ' ' + res.data.Date.EndTime, 'yyyy-MM-dd HH:mm');
								res.data.Date.EndDate = tempEndDateTime.split(' ')[0];
								res.data.Date.EndTime = tempEndDateTime.split(' ')[1];
								
								if (typeof isCopy != 'undefined' && isCopy == 'Y'){ scheduleUser.FolderType = res.data.Event.FolderType; }
								else { scheduleUser.origin = $.extend(true, {}, res.data); }
				    			
								var btnHTML = "";
				    			var isModify = false;
				    			var isDelete = false;
				    			
				    			// 작성자,  Owner 권한 체크, 폴더 권한 체크
				    			// 구글일정은 개인일정이므로 수정 및 삭제 권한 허용
				    			if(res.data.Event.RegisterCode == userCode || res.data.Event.OwnerCode == userCode  || $$(schAclArray).find("modify").concat().find("[FolderID="+folderID+"]").length > 0){		// 수정 권한 체크
				    				isModify = true;
				    			}
				    			if(res.data.Event.RegisterCode == userCode || res.data.Event.OwnerCode == userCode  || $$(schAclArray).find("delete").concat().find("[FolderID="+folderID+"]").length > 0){		// 삭제 권한 체크
				    				isDelete = true;
				    			}
				    			if(res.data.Event.RegisterCode != userCode || res.data.Event.OwnerCode != userCode){		// 알림 버튼 권한 체크
									$("#divNotification").css("display","none");
				    			}
				    			
				    			var isAttendee = false;
			    				for(var i = 0; i < res.data.Attendee.length; i++) {
			    					if(res.data.Attendee[i].UserCode == userCode) {
			    						isAttendee = true;
			    						break;
			    					}
			    				}
								
								if(CFN_GetQueryString("isTemplate") !== "Y" 
									&& typeof res.data.Date === "object" && JSON.stringify(res.data.Date) === "{}"){
									Common.Inform(coviDic.dicMap["msg_scheduleModifyOrDelete"], "Information", function(result){ // 일정이 수정 또는 삭제되었습니다.
										if(result){
											CoviMenu_GetContent("/groupware/layout/schedule_View.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule&viewType=M");
										}
									});
									return false;
								}
			    				
				    			if(coviCmn.configMap["SchedulePersonFolderID"] == folderID && res.data.Event.OwnerCode != userCode && !isAttendee){
				    				Common.Inform(coviDic.dicMap["msg_noViewACL"], "", function(){	//읽기 권한이 없습니다.
				    					CoviMenu_GetContent(g_lastURL);
				    				});
				    			}else{
				    				/**
				    				 * 수정/삭제 버튼
				    				 */
				    				if(isModify){
				    					btnHTML += '<a onclick="scheduleUser.modifyScheduleEvent(\''+isPop+'\');" id="btnModify"  class="btnTypeDefault right">'+coviDic.dicMap["btn_Edit"]+'</a>';			//수정
				    				}
				    				if(isDelete){
				    					btnHTML += '<a onclick="scheduleUser.callDeleteScheduleEvent(\''+mode+'\', \'\', \'\', \''+isRepeat+'\', \''+isPop+'\');" id="btnDelete" class="btnTypeDefault left">'+coviDic.dicMap["btn_delete"]+'</a>';			//삭제
				    				}
				    				
				    				if(!isModify && mode == "DU"){
				    					$("[id=btnUpdate]").remove();
				    				}
				    				
				    				$("#divBtnBottom").prepend(btnHTML);
				    				$("#btnList").after(btnHTML);
				    				
				    				scheduleUser.drawViewData(mode, res.data);
				    				
				    				if(mode == "D"){
				    					$("#hidFolderType").val(res.data.Event.FolderType);	
				    					
				    					// 댓글 알림 보내기 위한 세팅
				    					var commentURL = Common.getGlobalProperties("smart4j.path")+"/groupware/layout/schedule_DetailView.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule"
				    						+ "&eventID=" + CFN_GetQueryString("eventID") + "&dateID=" + CFN_GetQueryString("dateID")+ "&isRepeat=" + CFN_GetQueryString("isRepeat") + "&folderID=" + folderID;
				    					var mobileURL = Common.getGlobalProperties("smart4j.path")+"/groupware/mobile/schedule/view.do"
				    						+ "?eventid=" + CFN_GetQueryString("eventID") + "&dateid=" + CFN_GetQueryString("dateID") + "&isrepeat=" + CFN_GetQueryString("isRepeat") 
											+ "&repeatid=" + CFN_GetQueryString("repeatID") + "&folderid=" + folderID + "&isrepeatall=" + CFN_GetQueryString("isRepeatAll");
				    					
				    					var messageSetting = {
				    							SenderCode : sessionObj["USERID"],
				    							RegistererCode : sessionObj["USERID"],
				    							ReceiversCode : (res.data.Event.RegisterCode != sessionObj["USERID"]) ? res.data.Event.RegisterCode : '',
				    							GotoURL: commentURL, 
				    							PopupURL: commentURL, 
				    							MobileURL: mobileURL,
				    							MessagingSubject : res.data.Event.Subject,
				    							ReceiverText :  res.data.Event.Subject, //요약된 내용
				    							ServiceType : "Schedule",
				    							MsgType : "ScheduleComment"
				    					};
				    					coviComment.load('commentView', 'Schedule', CFN_GetQueryString("eventID"), messageSetting);
				    				}
				    			}
				    		}
				    		scheduleUser.deletePlaceInput();
				    	} else if (res.status == "EMPTY") {
				    		Common.Warning(Common.getDic("msg_notExistSchedule"), "Warning", function() {
				    			CoviMenu_GetContent(g_lastURL);	// 목록으로
				    		});
				    	} else {
							Common.Error(coviDic.dicMap["msg_apv_030"]);		// 오류가 발생했습니다.
						}
				    },
				    error:function(response, status, error){
				    	CFN_ErrorAjax("/groupware/schedule/goOne.do", response, status, error);
				    }
				});
			}else{
				// 구글연동 데이터
				var btnHTML ="";
				btnHTML += '<a onclick="scheduleUser.modifyScheduleEvent();" id="btnModify"  class="btnTypeDefault right">'+coviDic.dicMap["btn_Edit"]+'</a>';		//수정
				btnHTML += '<a onclick="scheduleUser.callDeleteScheduleEvent(\''+mode+'\', \'\', \'\', \''+isRepeat+'\', \''+isPop+'\');" id="btnDelete" class="btnTypeDefault left">'+coviDic.dicMap["btn_delete"]+'</a>';		//삭제
				$("#divBtnBottom").prepend(btnHTML);
    			$("#btnList").after(btnHTML);
    			
				getGoogleEventOne(mode, eventID, coverGoogleEventOne, scheduleUser.drawViewData, true);
			}
		},
		// 조회한 데이터 상황에 맞게 그려주기
		drawViewData : function(mode, data){
			var event = data.Event;
			var date = data.Date;
			var resource = data.Resource;
			var repeat = data.Repeat;
			var attendee = data.Attendee;
			var notification = data.Notification;
			var collabPrj = data.CollabPrj;
			var startDate, endDate;
			
			if(mode == "S"){
				$("#Subject").html(event.Subject);
				
				startDate = new Date(replaceDate(date.StartDate) + " " + date.StartTime);
				//startDate = schedule_SetDateFormat(startDate, ".") + (date.IsAllDay == "Y" ? "" :  " " + AddFrontZero(startDate.getHours(), 2)+":"+AddFrontZero(startDate.getMinutes(), 2));
				startDate = schedule_SetDateFormat(startDate, ".") + ((date.IsAllDay == "Y" && date.StartTime == "00:00") ? "" :  " " + AddFrontZero(startDate.getHours(), 2)+":"+AddFrontZero(startDate.getMinutes(), 2));
				startDate = startDate.substring(startDate.indexOf(".")+1, startDate.length);
				
				endDate = new Date(replaceDate(date.EndDate) + " " + date.EndTime);
				//endDate = schedule_SetDateFormat(endDate, ".") + (date.IsAllDay == "Y" ? "" : " " + AddFrontZero(endDate.getHours(), 2)+":"+AddFrontZero(endDate.getMinutes(), 2));
				endDate = schedule_SetDateFormat(endDate, ".") + ((date.IsAllDay == "Y" && date.EndTime == "23:59") ? "" : " " + AddFrontZero(endDate.getHours(), 2)+":"+AddFrontZero(endDate.getMinutes(), 2));
				endDate = endDate.substring(endDate.indexOf(".")+1, endDate.length);
				
				if(startDate == endDate)
					$("#StartEndDateTime").html(startDate + Common.getSession("UR_TimeZoneDisplay"));
				else
					$("#StartEndDateTime").html(startDate + " - " + endDate + Common.getSession("UR_TimeZoneDisplay"));
				
				var sRepJobTypeConfig = Common.getBaseConfig("RepJobType");
				var sRepJobType = event.MultiJobLevelName;
		        if(sRepJobTypeConfig == "PN"){
		        	sRepJobType = event.MultiJobPositionName;
		        } else if(sRepJobTypeConfig == "TN"){
		        	sRepJobType = event.MultiJobTitleName;
		        } else if(sRepJobTypeConfig == "LN"){
		        	sRepJobType = event.MultiJobLevelName;
		        }

				if (data.IsGoogle == 'Y'){
					$("#Register").html('<strong class="btnFlowerName">' + event.RegisterData +'</strong>');
				} else {
					$("#Register").html('<strong class="btnFlowerName" onclick="coviCtrl.setFlowerName(this)" style="position:relative;cursor:pointer" data-user-code="'+ event.RegisterCode +'" data-user-mail="' +event.MailAddress+ '" >' + event.MultiRegisterName + " " + sRepJobType +'</strong>');
				}
				
				if(event.Place != undefined && event.Place != "" && event.Place != " " && event.Place != null){
					$("#pPlace").show();
					$("#Place").html(event.Place);
				}
				
				if(event.ImportanceState == "Y")
					$("#ImportanceState").addClass("active");
			}
			else if(mode == "D"){
				/**
    			 * 참석자에 대한 승인/거부 버튼
    			 */
				//개별호출 - 일괄호출
				Common.getDicList(["lbl_schedule_attend","lbl_Important","lbl_schedule_noAttend","lbl_noexists","lbl_schedule_participation","lbl_schedule_Nonparticipation","lbl_schedule_standBy"]);
				
				$(attendee).each(function(){
					if($$(this).attr("UserCode") == userCode && $$(this).attr("IsAllow") == ""){
						var btnHTML = '<a onclick="scheduleUser.approve(\'APPROVAL\');" class="btnTypeDefault right">'+coviDic.dicMap["lbl_schedule_attend"]+'</a><a onclick="scheduleUser.approve(\'REJECT\');" class="btnTypeDefault left">'+coviDic.dicMap["lbl_schedule_noAttend"]+'</a>';		//참석 요청 승인
						$("#btnList").after(btnHTML);
						return false;
					} 
				});
    			
				$("#Subject").html('<span id="ImportanceState" class="btnType02">'+coviDic.dicMap["lbl_Important"]+'</span><span name="Subject">'+event.Subject+'</span>');		//중요
				
				if(event.ImportanceState == "Y"){
					$("#ImportanceState").addClass("active");
				}
				
				if(date.IsRepeat == "Y" && CFN_GetQueryString("isRepeatAll") == "Y"){
					// 21.07.26, 일정관리 미리알림 조건 추가.
					checkAlarmSave(repeat);
					getCalendarDic();
					var startEndDateTime = getRepeatViewMessage(repeat);					
					$("#StartEndDateTime").html(startEndDateTime + repeat.RepeatTimeZoneDisplay);
				}else{
					startDate = new Date(replaceDate(date.StartDate) + " " + date.StartTime);
					startDate = schedule_SetDateFormat(startDate, ".") + (date.IsAllDay == "Y" ? "" :  " " + AddFrontZero(startDate.getHours(), 2)+":"+AddFrontZero(startDate.getMinutes(), 2));
					
					endDate = new Date(replaceDate(date.EndDate) + " " + date.EndTime);
					endDate = schedule_SetDateFormat(endDate, ".") + (date.IsAllDay == "Y" ? "" : " " + AddFrontZero(endDate.getHours(), 2)+":"+AddFrontZero(endDate.getMinutes(), 2));
					
					if(startDate == endDate)
						$("#StartEndDateTime").html(startDate + Common.getSession("UR_TimeZoneDisplay"));
					else
						$("#StartEndDateTime").html(startDate + " - " + endDate + Common.getSession("UR_TimeZoneDisplay"));
				}
				
				$("#RegisterPhoto").attr("src", event.RegisterPhoto == undefined ? "" : coviCmn.loadImage(event.RegisterPhoto));
				
				var sRepJobTypeConfig = Common.getBaseConfig("RepJobType");
				var sRepJobType = event.MultiJobLevelName;
		        if(sRepJobTypeConfig == "PN"){
		        	sRepJobType = event.MultiJobPositionName;
		        } else if(sRepJobTypeConfig == "TN"){
		        	sRepJobType = event.MultiJobTitleName;
		        } else if(sRepJobTypeConfig == "LN"){
		        	sRepJobType = event.MultiJobLevelName;
		        }

				if (data.IsGoogle == 'Y'){
					$("#Register").html('<strong class="btnFlowerName">' + event.RegisterData +'</strong>');
				} else {
					$("#Register").html('<strong class="btnFlowerName" onclick="coviCtrl.setFlowerName(this)" style="position:relative;cursor:pointer" data-user-code="'+ event.RegisterCode +'" data-user-mail="' +event.MailAddress+ '" >' + event.MultiRegisterName + " " + sRepJobType +'</strong>');
				}
				
				$("#FolderID").html('<span id="FolderColor" class="rect"></span>&nbsp'+event.FolderName);
				$("#FolderID").attr("folderID", event.FolderID);
				$("#FolderColor").css("background", event.FolderColor);
				
				if(event.Place != undefined && event.Place != "" && event.Place != " " && event.Place != null){
					$("#placeMap").show();
					$("#Place").html(event.Place);
					
					try{
						coviCtrl.addr2Geocode(event.Place, "drawMap");
					}catch(e){
						$("#placeMap").hide();
					}
				}else{
					$("#placeMap").hide();
					$("#Place").html(coviDic.dicMap["lbl_noexists"]);		//없음
				}
				
				//참석자
				if(attendee.length > 0 && attendee[0].UserCode != undefined){
					var notAnswerAttendRequest = false;
					var attendeeHTML = "";
					$(attendee).each(function(){
						attendeeHTML += '<span>';
						
						if (this.IsOutsider != 'Y'){
							if(this.IsAllow == "Y")
								attendeeHTML += '<span class="btnType02 blue">'+coviDic.dicMap["lbl_schedule_participation"]+'</span>';		//참여
							else if(this.IsAllow == "N")
								attendeeHTML += '<span class="btnType02">'+coviDic.dicMap["lbl_schedule_Nonparticipation"]+'</span>';			//비참여
							else
								attendeeHTML += '<span class="btnType02">'+coviDic.dicMap["lbl_schedule_standBy"]+'</span>';			//대기중
						}
							
						attendeeHTML += this.UserName+ ((this.IsOutsider == 'Y') ? ' ('+Common.getDic('ACC_lbl_outsideAttendant')+')' : this.DeptName == undefined ? "" : ' ('+this.DeptName+')' )+'&nbsp;</span>'; 
						
						notAnswerAttendRequest = (this.IsAllow == "" && Common.getSession('UR_Code') == this.UserCode);
					});
					$("#Attendee").html(attendeeHTML);
					
					if (notAnswerAttendRequest && parent && (parent.document.getElementById('attendRequest_pop_p') != null || parent.CFN_GetQueryString('CLBIZ') == 'Resource')){		// 참석요청 팝업에서 열어본 일정상세이거나, 자원에서 연 일정상세인 경우
						$("#commentView").hide();
						$('#commentView').before('<div style="text-align: center; width: 100%;">'+
							'<a onclick="scheduleUser.approve(\'APPROVAL\');" class="btnTypeDefault right">' + Common.getDic('lbl_schedule_attend') + '</a>'+
							'<a onclick="scheduleUser.approve(\'REJECT\');" class="btnTypeDefault left">' + Common.getDic('lbl_schedule_noAttend') + '</a>'+
						'</div>');
					}
				}else{
					$("#Attendee").html("<span>"+coviDic.dicMap["lbl_noexists"]+"</span>");		//없음
				}
				
				//자원
				if(resource.length > 0 && resource[0].ResourceName != undefined){
					var resourceHTML = "";
					$(resource).each(function(){
						resourceHTML += this.ResourceName + " (" + this.TypeName + "),";
					});
					resourceHTML = resourceHTML.substring(0, resourceHTML.lastIndexOf(","));
					$("#Resource").html(resourceHTML);
				}else{
					$("#Resource").html("<span>"+coviDic.dicMap["lbl_noexists"]+"</span>");		//없음
				}
				
				//협업스페이스 프로젝트
				if(collabPrj.PrjName != undefined){
					$("#CollabPrj").html(collabPrj.PrjName + ">" + collabPrj.SectionName);
				}else{
					$("#CollabPrj").html("<span>"+coviDic.dicMap["lbl_noexists"]+"</span>");		//없음
				}
				
				$("#Description").html(event.Description == "" ? coviDic.dicMap["lbl_noexists"] : event.Description.replaceAll("\n", "<br>"));		//없음
				
				// 알림은 등록자와 참석자만 변경할 수 있음
				/*
				if($.isEmptyObject(notification)){
					// $("#divNotification").hide();
				}
				
				else{
				*/
				if(notification != null && !$.isEmptyObject(notification)){
					$("#ReminderTime").val(notification.ReminderTime);
					if(notification.IsNotification == "Y")
						alarmOnClick($("#IsNotificationDiv"));
					if(notification.IsReminder == "Y"){
						alarmOnClick($("#IsReminderA"));
						$("#ReminderTime").attr("disabled", false);
					}
					if(notification.IsCommentNotification == "Y")
						alarmOnClick($("#IsCommentA"));
				}
			}
			else if(mode == "DU"){
				updateScheduleDataObj = data;
				$(updateScheduleDataObj.Attendee).each(function(){
					this.dataType = "OLD";
				});
				if($$(updateScheduleDataObj).find("Date").attr("IsRepeat") == "Y" && CFN_GetQueryString("isRepeatAll") == "Y"){
					$$(updateScheduleDataObj).find("Date").attr("StartDate", "");
					$$(updateScheduleDataObj).find("Date").attr("EndDate", "");
					$$(updateScheduleDataObj).find("Date").attr("StartTime", "");
					$$(updateScheduleDataObj).find("Date").attr("EndTime", "");
				}
				
				if(event.ImportanceState == "Y"){
					$("#ImportanceState").val("Y");
					$("#aImportanceState").addClass("active");
				}
				
				if(event.IsSubject != "N"){
					var setSubject = event.Subject.split('&nbsp;').join(' ').replaceAll("<br />","\r\n");
					$("#Subject").val(setSubject);
				}
					
				
				$("#IsPublic").prop("checked", event.IsPublic == "N");
				
				$("[data-selvalue="+event.FolderID+"]").click();
				
				// 장소
				if(event.Place != undefined && event.Place != ""){
					$("#Place").val(event.Place);						//주소자동완성 API 제거로 인한 수정
					
					/*var placeObj = $("<div></div>")
	                .addClass("ui-autocomplete-multiselect-item")
	                .attr("data-json", JSON.stringify({"label":event.Place,"value":event.Place}))
	                .attr("data-value", event.Place)
	                .text(event.Place)
	                .append(
	                    $("<span></span>")
	                        .addClass("ui-icon ui-icon-close")
	                        .click(function(){
	                            var item = $(this).parent();
	                            item.remove();
	                        })
	                );
					$("#placeAutoComp .ui-autocomplete-multiselect").prepend(placeObj);*/
				}
				
				//자원
				if(resource.length > 0){
					$(resource).each(function(){
						var resourceObj = $("<div></div>")
		                .addClass("ui-autocomplete-multiselect-item")
		                .attr("data-json", JSON.stringify({"label":this.ResourceName,"value":this.FolderID,"ResourceName":this.ResourceName,"FolderID":this.FolderID,"opType":"none"}))
		                .attr("data-value", this.FolderID)
		                .text(this.ResourceName)
		                .append(
		                    $("<span></span>")
		                        .addClass("ui-icon ui-icon-close")
		                        .click(function(){
		                            var item = $(this).parent();
		                            item.remove();
		                        })
		                );
						$("#resourceAutoComp .ui-autocomplete-multiselect").prepend(resourceObj);
					});
				}
				
				if(CFN_GetQueryString("isTemplate") != "Y"){
					$("#detailDateCon_StartDate").val(date.StartDate.replaceAll("-", "."));
					$("#detailDateCon_EndDate").val(date.EndDate.replaceAll("-", "."));
					
					coviCtrl.setSelected('detailDateCon [name=startHour]', date.StartTime.split(":")[0]);
					coviCtrl.setSelected('detailDateCon [name=startMinute]', date.StartTime.split(":")[1]);
					coviCtrl.setSelected('detailDateCon [name=endHour]', date.EndTime.split(":")[0]);
					coviCtrl.setSelected('detailDateCon [name=endMinute]', date.EndTime.split(":")[1]);
					coviCtrl.setSelected('detailDateCon [name=datePicker]', "select");	//JSYun 기존 일정 수정시, select는 선택으로 변경
				}
				
				//종일
				$("#IsAllDay").prop("checked", date.IsAllDay == "Y");
				if(date.IsAllDay == "Y"){
					$("#detailDateCon [name=datePicker]").find("select").attr("disabled", true);
					coviCtrl.setSelected('detailDateCon [name=datePicker]', "select");
				
					// Disabled
					$("#" + target + " [name=startHour]").find("select").attr("disabled", true);
					$("#" + target + " [name=startMinute]").find("select").attr("disabled", true);
					$("#" + target + " [name=endHour]").find("select").attr("disabled", true);
					$("#" + target + " [name=endMinute]").find("select").attr("disabled", true);
					$("#" + target + " [name=datePicker]").find("select").attr("disabled", true);
				}
				
				//반복
				repeat = {"ResourceRepeat" : repeat};
				if(date.IsRepeat == "Y" && CFN_GetQueryString("isRepeatAll") == "N"){
					date.IsRepeat = "N";
					repeat = {};
				}
				$("#IsRepeat").val(date.IsRepeat);
				scheduleUser.callBackRepeatSetting(JSON.stringify(repeat), "DU");
				
				//자원
				$("#hidResourceList_DU").val(JSON.stringify(resource));
				
				//참석자
				var attendeeListHTML = "";
				if(attendee.length > 0){
					$(attendee).each(function(){
						if (typeof isCopy != 'undefined' && isCopy == 'Y' && scheduleUser.FolderType == 'Schedule.Person' && Common.getSession('UR_Code') == this.UserCode) return true;
						var attendeeObj = $("<div></div>")
		                .addClass("ui-autocomplete-multiselect-item")
		                .attr("data-json", JSON.stringify({"UserCode":this.UserCode,"UserName":this.UserName,"label":this.UserName,"value":this.UserCode,"IsOutsider":this.IsOutsider,"IsAllow":this.IsAllow,"opType":"none","DomainID":this.DomainID}))
		                .attr("data-value", this.UserCode+'|'+this.IsAllow)
		                .text(this.UserName)
		                .append(
		                    $("<span></span>")
		                        .addClass("ui-icon ui-icon-close")
		                        .click(function(){
		                            var item = $(this).parent();
		                            item.remove();
		                        })
		                );
						$("#attendeeAutoComp .ui-autocomplete-multiselect").prepend(attendeeObj);
					});
				}
				
				$("#IsInviteOther").prop("checked", event.IsInviteOther == "Y");
				
				// 알림은 등록자와 참석자만 변경할 수 있음
				// 단 복사할 때는 표시해야 함
				if($.isEmptyObject(notification) && $("[id=btnUpdate]").length == 0){
					notification = {"IsNotification":"N","IsReminder":"N","ReminderTime":"10","IsCommentNotification":"N","MediumKind":""};			// 기본으로 모두 해제되어 있는 값 세팅
				}
				
				if($.isEmptyObject(notification)){
					//$("#divNotification").hide();
				}else{
					$("#ReminderTime").val(notification.ReminderTime);
					if(notification.IsNotification == "Y")
						alarmOnClick($("#IsNotificationDiv"));
					if(notification.IsReminder == "Y"){
						alarmOnClick($("#IsReminderA"));
						$("#ReminderTime").attr("disabled", false);
					}
					if(notification.IsCommentNotification == "Y")
						alarmOnClick($("#IsCommentA"));
				}
				
				// 자주 쓰는 일정 외의 수정화면에서 제외
				if(CFN_GetQueryString("isTemplate") != "Y"){
					//$("#divNotification").hide();
				}
				
				// 에디터 세팅
				setDescEditor();
				
				// Description
				if(!/<[a-z][\s\S]*>/i.test(event.Description)){
					var setDescription =  event.Description.split('&nbsp;').join(' ').replaceAll("<br />","\r\n");
					$("#Description").html(setDescription);
				}else{
					$("#Description").hide();
					$("#hidDescription").val(event.Description);
					
					$("#pSwitchEditor").attr("value", "editor");
					$("#pSwitchEditor").find("a").html(Common.getDic("lbl_writeTextArea"));			//텍스트로 작성

					// 에디터 세팅
					//setDescEditor();
					
					//coviEditor.setBody('dext5', 'tbContentElement', event.Description);
					
					/*//$("#dext5").show();
					coviEditor.show('dext5', 'tbContentElement');

	
					// TODO
					setTimeout(function(){
						coviEditor.setBody('dext5', 'tbContentElement', event.Description);
					}, 500);*/
				}
		
			}
			
			// 구글일정에서 숨겨질 항목 처리
			if(event.IsGoogle == "Y"){
				//중요도
				$("#ImportanceState").hide();
				if(mode == "S"){
					$("#Subject").css("margin", "0");
					
					// 자주 쓰는 일정 추가 버튼 숨김
					$("#btnAddTemplate").hide();
				}else{
					if(mode == "D"){
						// 자원 숨김
						$("#viewDivRES").hide();
						
						// 자주 쓰는 일정 추가 버튼 숨김
						$("#btnAddTemplate").hide();
					}
					else if(mode == "DU"){
						// 자원 숨김
						$("#wrtDivRES").hide();
						
						// 수정시 다른 일정으로 수정하지 못함
					}
					
					// 알림 숨김
					$("#divNotification").hide();
				}
			}
			
			g_fileList = data.fileList;

			$(".attFileListBox").html("");
			if(g_fileList !== undefined && g_fileList !== null && g_fileList.length > 0){
				var attFileAnchor = $('<a onclick="$(\'.attFileListCont\').toggleClass(\'active\');"/>').addClass('btnAttFile btnAttFileListBox').text('(' + g_fileList.length + ')');
				var attFileListCont = $('<ul>').addClass('attFileListCont');
				var attFileDownAll = $('<li>').append("<a href='#' onclick='javascript:scheduleUser.downloadAll(g_fileList)'>"+Common.getDic("lbl_download_all")+"</a>").append($('<a onclick="$(\'.attFileListCont\').toggleClass(\'active\');" >').addClass("btnXClose btnAttFileListBoxClose"));
				var attFileList = $('<li>');
				var videoHtml = '';
				
				$.each(g_fileList, function(i, item){
					var iconClass = "";
					if(item.Extention == "ppt" || item.Extention == "pptx"){
						iconClass = "ppt";
					} else if (item.Extention == "excel" || item.Extention == "xlsx" || item.Extention == "xls"){
						iconClass = "fNameexcel";
					} else if (item.Extention == "pdf"){
						iconClass = "pdf";
					} else if (item.Extention == "doc" || item.Extention == "docx"){
						iconClass = "word";
					} else if (item.Extention == "zip" || item.Extention == "rar" || item.Extention == "7z"){
						iconClass = "zip";
					} else if (item.Extention == "jpg" || item.Extention == "gif" || item.Extention == "png"|| item.Extention == "bmp"){
						iconClass = "attImg";
					} else {
						iconClass = "default";
					}
					
					$(attFileList).append($('<p style="cursor:pointer;"/>').attr({"fileID": item.FileID, "fileToken": item.FileToken}).addClass('fName').append($('<span title="'+item.FileName+'">').addClass(iconClass).text(item.FileName)).append($('<span class="fileSize">').text("("+coviFile.convertFileSize(item.Size)+")")));
				});
				$('#BodyText').html($('#BodyText').html() + videoHtml);
				
				$(attFileListCont).append(attFileDownAll, attFileList);
				$('.attFileListBox').append(attFileAnchor ,attFileListCont);
				$('.attFileListBox .fName').click(function(){
					Common.fileDownLoad($(this).attr("fileID"), $(this).text(), $(this).attr("fileToken"));
				});
				$('.attFileListBox').show();
			} else {
				$('.attFileListBox').hide();
			}
			
		},
		// 첨부파일 전체다운로드
		downloadAll: function( pFileList ){
			var fileList = pFileList.slice(0);	//array 객체 복사용
			Common.downloadAll(fileList);
		},
		// 일정 삭제 호출 함수
		callDeleteScheduleEvent : function(setType, paramEventID, paramDateID, isRepeat, isPop){
			Common.Confirm(Common.getDic("msg_AreYouDelete"), 'Confirmation Dialog', function (result) { //삭제하시겠습니까?
				if(result){
					if(isRepeat == "Y" && CFN_GetQueryString("isRepeatAll") == "undefined"){
						var showRepeatHTML = getRepeatAllOROnlyHTML('D');
						Common.open("","showRepeat",Common.getDic("lbl_ScheduleView_03"), showRepeatHTML, "270px","230px","html",true,null,null,true);			//"반복 일정 열기"
					}else{
						if(isRepeat == "Y" && CFN_GetQueryString("isRepeatAll") == "N")
							setType = "RU";
						
						scheduleUser.deleteScheduleEvent(setType, paramEventID, paramDateID, isPop);
					}
				}
			});
		},
		// 일정 삭제
		deleteScheduleEvent : function(setType, paramEventID, paramDateID, isPop){
			var eventID = $("#eventID").val() == undefined ? CFN_GetQueryString("eventID"): $("#eventID").val();
			if(eventID == "undefined")
				eventID = paramEventID;
			var dateID = $("#dateID").val() == undefined ? CFN_GetQueryString("dateID") : $("#dateID").val();
			if(dateID == "undefined")
				dateID = paramDateID;

			if(Number(eventID)){
				$.ajax({
				    url: "/groupware/schedule/remove.do",
				    type: "POST",
				    data: {
				    	"mode" : setType,
				    	"EventID" : eventID,
				    	"DateID" : dateID
					},
				    success: function (res) {
				    	if(res.status == "SUCCESS"){
					    	Common.Inform(Common.getDic("msg_deleteSuccess"), "", function(){			//성공적으로 삭제하였습니다.
					    		if(setType == "S" || setType == "F"){
									if(isPop == "Y")
										Common.Close();
									else
										scheduleUser.refresh();
								} else{
									CoviMenu_GetContent(g_lastURL);
								}
					    	});
				    	} else {
							Common.Error(Common.getDic("msg_apv_030"));		// 오류가 발생했습니다.
						}
				    },
				    error:function(response, status, error){
						CFN_ErrorAjax("/groupware/schedule/remove.do", response, status, error);
					}
				});
			}else{
				Common.Confirm(Common.getDic("msg_deleteGoogleSch"), "", function(result){			//구글 캘린더에 있는 일정을 삭제합니다.\n삭제하시겠습니까?
					if(result){
						deleteGoogleEventOne(setType, eventID);
					}
				});
			}
		},
		// 조회화면에서 수정 버튼 이벤트
		modifyScheduleEvent : function(pIsPop, pIsCopy){
			var eventID = $("#eventID").val() == undefined ? CFN_GetQueryString("eventID"): $("#eventID").val();
			var dateID = $("#dateID").val() == undefined ? CFN_GetQueryString("dateID"): $("#dateID").val();
			var repeatID = $("#repeatID").val() == undefined ? CFN_GetQueryString("repeatID"): $("#repeatID").val();
			var isRepeat = $("#isRepeat").val() == undefined ? CFN_GetQueryString("isRepeat"): $("#isRepeat").val();
			var isRepeatAll = $("#isRepeatAll").val() == undefined ? CFN_GetQueryString("isRepeatAll") : $("#isRepeatAll").val();
			var folderID = $("#folderID").val() == undefined ? CFN_GetQueryString("folderID") : $("#folderID").val();
			
			// 커뮤니티 연동을 위함
			var CSMU = CFN_GetQueryString("CSMU");
			var communityId = CFN_GetQueryString("communityId");
			var activeKey = CFN_GetQueryString("activeKey");
			
			if(isRepeat == "Y" && isRepeatAll == "undefined"){
				var showRepeatHTML = getRepeatAllOROnlyHTML("U", eventID, dateID, folderID, repeatID);
				Common.open("","showRepeat",Common.getDic("lbl_ScheduleView_03"), showRepeatHTML, "270px","230px","html",true,null,null,true);			//반복 일정 열기
			}else{
				var redirectURL = "/groupware/layout/schedule_DetailWrite.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule"
						+(CSMU == "undefined" ? "" : "&CSMU="+CSMU+"&communityId="+communityId+"&activeKey="+activeKey)
						+"&eventID="+eventID
						+"&dateID="+dateID
						+"&repeatID="+repeatID
						+"&isRepeat="+isRepeat
						+"&isRepeatAll="+isRepeatAll
						+"&folderID=" + folderID
						+((pIsCopy == "Y") ? "&isCopy=Y" : "");
				if(pIsPop == "Y"){
					window.open(redirectURL, "_blank");
				}else{
					CoviMenu_GetContent(redirectURL);
				}
			}
		},
		// 자주 쓰는 일정 조회
		getTemplateScheduleList : function(){
			//개별호출 - 일괄호출
			Common.getDicList(["btn_delete","msg_apv_030"]);
			
			$.ajax({
			    url: "/groupware/schedule/getTemplateList.do",
			    type: "POST",
			    data: {
			    	"UserCode" : userCode
				},
			    success: function (res) {
			    	if(res.status == "SUCCESS"){
			    		if(res.list.length > 0){
			    			var templateHtml = "";
			    			$(res.list).each(function(){
			    				var htmlStr = "";
			    				var className = "oftSchCard";
			    				if(this.Place == "")
			    					className += " txt";
			    				
			    				htmlStr += '<div class="'+className+'" id="template_'+this.EventID+'" eventid="'+this.EventID+'">';
			    				htmlStr += '<div onclick="scheduleUser.clickTemplateSchedule('+this.EventID+');">';
			    				
			    				if(this.Place != ""){
			    					htmlStr += '<h3>'+this.Subject+'</h3>';
			    					htmlStr += '<p>'+this.Place+'</p>';
			    				}else{
			    					htmlStr += '<p>'+this.Subject+'</p>';
			    				}
			    				
			    				htmlStr += '</div>';
			    				htmlStr += '<a onclick="scheduleUser.callDeleteScheduleEvent(\'F\', '+this.EventID+', '+this.DateID+', \'N\', \'N\');" class="btnPhotoRemove">'+coviDic.dicMap["btn_delete"]+'</a>';		//삭제
		                        htmlStr += '</div>';
		                        
		                        templateHtml = htmlStr + templateHtml;
			    			});
			    			$("#templateList").html(templateHtml);
			    			
			    			// 자주 쓰는 일정 Drag&Drop 바인딩
			    			scheduleUser.setTemplateDragNDropEvent();
			    		}
			    	} else {
						Common.Error(coviDic.dicMap["msg_apv_030"]);		// 오류가 발생했습니다.
					}
			    },
			    error:function(response, status, error){
					CFN_ErrorAjax("/groupware/schedule/getTemplateList.do", response, status, error);
				}
			});
		},
		clickTemplateSchedule : function(eventID){
			// 커뮤니티 연동을 위함
			var CSMU = CFN_GetQueryString("CSMU");
			var communityId = CFN_GetQueryString("communityId");
			var activeKey = CFN_GetQueryString("activeKey");
			
			CoviMenu_GetContent('schedule_DetailWrite.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule'
					+(CSMU == "undefined" ? "" : "&CSMU="+CSMU+"&communityId="+communityId+"&activeKey="+activeKey)
					+'&isTemplate=Y'
					+(eventID == undefined ? "" : '&eventID='+eventID));
		},
		// 자주 쓰는 일정 추가 버튼 (간단 보기, 상세 보기, 목록 보기)
		addTemplateScheduleData : function(eventID, setType){
			$.ajax({
			    url: "/groupware/schedule/addTemplate.do",
			    type: "POST",
			    data: {
			    	"EventID" : eventID,
			    	"UserCode" : userCode
				},
			    success: function (res) {
			    	if(res.status == "SUCCESS"){
			    		Common.Inform(Common.getDic("msg_117"), "", function(){			//성공적으로 저장하였습니다.
			    			if(setType == "S")
			    				scheduleUser.refresh();
			    		});
			    	} else {
						Common.Error(Common.getDic("msg_apv_030"));		// 오류가 발생했습니다.
					}
			    },
			    error:function(response, status, error){
					CFN_ErrorAjax("/groupware/schedule/addTemplate.do", response, status, error); 
				}
			});
		},
		// 자주 쓰는 일정 드래그 앤 드롭
		setTemplateDragNDropEvent : function(){
			var onclickStr = "";
			$( "[id^=template_]" ).draggable({
				revert: true,
				helper: "clone",
				start:function(event,ui){
					$(".oftScroll").append($(".ui-draggable-dragging"));
				}
			});
		},
		// 자주 쓰는 일정 드래그 앤 드롭 등록
		templateDragNDrop_Update : function(eventID, sDate, sTime, eDate, eTime){
			$.ajax({
			    url: "/groupware/schedule/setEventByTemplateDragDrop.do",
			    type: "POST",
			    data: {
					"IsCommunity" : isCommunity,
					"FolderID" : schFolderId,
			    	"EventID" : eventID,
			    	"StartDate" : sDate,
			    	"StartTime" : sTime,
			    	"EndDate" : eDate,
			    	"EndTime" : eTime,
			    	"UserCode" : userCode
				},
			    success: function (res) {
			    	if(res.status == "SUCCESS"){
			    		if(g_viewType == "M"){
							schedule_MakeMonthCalendar();
						}else if(g_viewType == "D"){
							scheduleUser.schedule_MakeDayCalendar();
						}else if(g_viewType == "W"){
							scheduleUser.schedule_MakeWeekCalendar();
						}
			    	} else if (res.status == "DUPLICATION") {
			    		Common.Warning(res.Message);
			    		
			    		if(g_viewType == "M"){
							schedule_MakeMonthCalendar();
						}else if(g_viewType == "D"){
							scheduleUser.schedule_MakeDayCalendar();
						}else if(g_viewType == "W"){
							scheduleUser.schedule_MakeWeekCalendar();
						}
			    	} else {
						Common.Error(Common.getDic("msg_apv_030"));		// 오류가 발생했습니다.
					}
		        },
		        error:function(response, status, error){
					CFN_ErrorAjax("/groupware/schedule/setEventByTemplateDragDrop.do", response, status, error);
				}
			});
		    
			/*if(g_viewType == "M"){
				schedule_MakeMonthCalendar();
			}else if(g_viewType == "D"){
				scheduleUser.schedule_MakeDayCalendar();
			}else if(g_viewType == "W"){
				scheduleUser.schedule_MakeWeekCalendar();
			}*/
		},
		// 참석 요청 승인/거부
		approve : function(mode){
			var eventID = CFN_GetQueryString("eventID");
			
			$.ajax({
			    url: "/groupware/schedule/approve.do",
			    type: "POST",
			    data: {
			    	"mode" : mode,
			    	"EventID" : eventID,
			    	"UserCode" : userCode,
					"UserMultiName" : userMultiName
				},
			    success: function (res) {
			    	if(res.status == "SUCCESS"){
						Common.Inform(Common.getDic("msg_117"), "", function(){			//성공적으로 저장하였습니다.
							if (parent && parent.document.getElementById('attendRequest_pop_p') != null){
								if(parent.document.getElementById('attendRequest_pop_if') != null) parent.document.getElementById('attendRequest_pop_if').contentWindow.initAttendRequest();
				    			parent.$("#schedule_detail_pop_px").click();
								parent.scheduleUser.refresh();
							} else if (parent && parent.CFN_GetQueryString('CLBIZ') == 'Resource'){
								parent.$("#schedule_detail_pop_px").click();
								parent.resourceUser.refresh();
							} else {
								scheduleUser.refresh();
							}
			    		});
			    	} else {
						Common.Error(Common.getDic("msg_apv_030"));		// 오류가 발생했습니다.
					}
			    },
			    error:function(response, status, error){
					CFN_ErrorAjax("/groupware/schedule/approve.do", response, status, error);
				}
			});
		},
		//새로고침
		refresh : function(){
			CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
		},
		//입력된 반복내용을 화면에 표시
		callBackRepeatSetting : function(repeatInfo, mode) {
			var sHour, sMin, eHour, eMin;
			if(repeatInfo != undefined && repeatInfo != ""){
				if($("#IsRepeat").val() == "N"){
					// 기존값 저장
					$("#hidStartDate").val($("#detailDateCon_StartDate").val());
					$("#hidEndDate").val($("#detailDateCon_EndDate").val());
					
					sHour = coviCtrl.getSelected('detailDateCon [name=startHour]').val;
					sMin = coviCtrl.getSelected('detailDateCon [name=startMinute]').val;
					eHour = coviCtrl.getSelected('detailDateCon [name=endHour]').val;
					eMin = coviCtrl.getSelected('detailDateCon [name=endMinute]').val;
					
					$("#hidStartHour").val(sHour);
					$("#hidStartMinute").val(sMin);
					$("#hidEndHour").val(eHour);
					$("#hidEndMinute").val(eMin);
				}
				
				$("#hidRepeatInfo").val(repeatInfo);
				
				if($("#IsRepeat").val() == "Y" || (mode == undefined || mode != "DU"))
					$("#detailDateCon").html("<span>" + getRepeatConfigMessage(repeatInfo) + "</span>");
				
				if($("#IsRepeat").val() == "N" && mode == undefined || mode != "DU")
					$("#IsRepeat").val("Y");
				
				if(mode != "DU" || $("#IsRepeat").val() == "Y"){
					$("#lbIsAllDay").hide();
				}

			}else{
				$("#IsRepeat").val("N");
				scheduleUser.setStartEndDateTime('D');
				
				$("#hidRepeatInfo").val("");
				
				var sDate = ($("#hidStartDate").val() != '') ? $("#hidStartDate").val() : (typeof scheduleUser.origin != 'undefined') ? scheduleUser.origin.Date.StartDate.replaceAll(/-/g, '.') : '';
				var eDate = ($("#hidEndDate").val() != '') ? $("#hidEndDate").val() : (typeof scheduleUser.origin != 'undefined') ? scheduleUser.origin.Date.EndDate.replaceAll(/-/g, '.') : '';
				
				$("#detailDateCon_StartDate").val(sDate);
				$("#detailDateCon_EndDate").val(eDate);
				
				sHour = ($("#hidStartHour").val() != '') ? $("#hidStartHour").val() : (typeof scheduleUser.origin != 'undefined') ? scheduleUser.origin.Date.StartTime.split(':')[0] : '';
				sMin = ($("#hidStartMinute").val() != '') ? $("#hidStartMinute").val() : (typeof scheduleUser.origin != 'undefined') ? scheduleUser.origin.Date.StartTime.split(':')[1] : '';
				eHour = ($("#hidEndHour").val() != '') ? $("#hidEndHour").val() : (typeof scheduleUser.origin != 'undefined') ? scheduleUser.origin.Date.EndTime.split(':')[0] : '';
				eMin = ($("#hidEndMinute").val() != '') ? $("#hidEndMinute").val() : (typeof scheduleUser.origin != 'undefined') ? scheduleUser.origin.Date.EndTime.split(':')[1] : '';
				
				coviCtrl.setSelected('detailDateCon [name=startHour]', sHour);
				coviCtrl.setSelected('detailDateCon [name=startMinute]', sMin);
				coviCtrl.setSelected('detailDateCon [name=endHour]', eHour);
				coviCtrl.setSelected('detailDateCon [name=endMinute]', eMin);
				
				$("#lbIsAllDay").show();
			}
			//PageResize();
		},
		// 구독 버튼 그리기
		setSubscriptionButton : function(){
			var folderID = "";
			
			if(CFN_GetQueryString("CSMU") == 'C' || CFN_GetQueryString("CSMU") == 'T'  ){
				folderID = folderCheckList.replaceAll(";", "");
			}
			
			var folderIDs = ""
				
			if($$(schAclArray).find("view").concat().length > 0){
				$$(schAclArray).find("view").concat().each(function(i, obj){
					folderIDs += $$(obj).attr("FolderID") + ",";
				});
				
				folderIDs = "(" + folderIDs.substring(0, folderIDs.length-1) + ")";
			
				$.ajax({
				    url: "/groupware/schedule/getSubscriptionFolderList.do",
				    type: "POST",
				    data: {
				    	"FolderID" : folderID,
				    	"FolderIDs" : folderIDs
					},
				    success: function (res) {
				    	if(res.status == "SUCCESS"){
				    		var listHTML = "";
				    		
				    		$(res.list).each(function(){
				    			listHTML += '<li>';
				    			listHTML += '<div class="chkStyle03">';
				    			listHTML += '<input type="checkbox" id="subsc_'+this.FolderID+'" name="allSV" value="'+this.FolderID+'"><label for="subsc_'+this.FolderID+'"><span style="background-color:'+this.Color+'"></span>'+this.MultiDisplayName+'</label>';
				    			listHTML += '</div>';
				    			listHTML += '</li>';
				    		});
				    		
				    		$("#subscClose").after(listHTML);
				    		
				    		// 기존 구독 체크된 항목 가져오기
				    		var subScList = coviCtrl.getSubscriptionFolderList();
				    		$(subScList).each(function(){
				    			if(this.TargetServiceType == "Schedule"){
				    				$("#subsc_"+this.FolderID).prop("checked", true);
				    			}
				    		});
				    	} else {
							Common.Error(Common.getDic("msg_apv_030"));		// 오류가 발생했습니다.
						}
				    },
				    error:function(response, status, error){
						CFN_ErrorAjax("/groupware/schedule/getSubscriptionFolderList.do", response, status, error);
					}
				});
			}
		},
		//사용자 프로필의 일정
		setMyInfoProfileSchedule : function(){
			
			Common.getDicList(["lbl_WPSun","lbl_WPMon","lbl_WPTue","lbl_WPWed","lbl_WPThu","lbl_WPFri","lbl_WPSat"]);
			
			var startDateObj = new Date(replaceDate(g_startDate));
			
		    //select day가 속한 주를 가져오기
		    var sun = schedule_GetSunday(startDateObj);
		    var strSun = schedule_SetDateFormat(sun, '/');
		    var mon = schedule_AddDays(strSun, 1);
		    var tue = schedule_AddDays(strSun, 2);
		    var wed = schedule_AddDays(strSun, 3);
		    var thr = schedule_AddDays(strSun, 4);
		    var fri = schedule_AddDays(strSun, 5);
		    var sat = schedule_AddDays(strSun, 6);
	
		    // 상단 제목 날짜 표시
		    $('#dateTitle').html(schedule_SetDateFormat(sun, '.') + ' - ' + schedule_SetDateFormat(sat, '.'));
		    
		    //헤더 그리기
		    var headerHTML = '<table class="calMonTbl">';
		    headerHTML += '<tbody>';
		    headerHTML += '<tr>';
		    headerHTML += '<th class="sun">'+sun.getDate()+'&nbsp;'+coviDic.dicMap["lbl_WPSun"]+'</th>';
		    headerHTML += '<th>'+mon.getDate()+'&nbsp;'+coviDic.dicMap["lbl_WPMon"]+'</th>';
		    headerHTML += '<th>'+tue.getDate()+'&nbsp;'+coviDic.dicMap["lbl_WPTue"]+'</th>';
		    headerHTML += '<th>'+wed.getDate()+'&nbsp;'+coviDic.dicMap["lbl_WPWed"]+'</th>';
		    headerHTML += '<th>'+thr.getDate()+'&nbsp;'+coviDic.dicMap["lbl_WPThu"]+'</th>';
		    headerHTML += '<th>'+fri.getDate()+'&nbsp;'+coviDic.dicMap["lbl_WPFri"]+'</th>';
		    headerHTML += '<th>'+sat.getDate()+'&nbsp;'+coviDic.dicMap["lbl_WPSat"]+'</th>';
		    headerHTML += '</tr>';
		    headerHTML += '</tbody>';
		    headerHTML += '</table>';
		    
		    $(".calMonHeader").html(headerHTML);
		    
		    var gridHTML = '<tbody><tr>';
		    for(var i=0; i<7; i++)
		    	gridHTML += '<td></td>';
			gridHTML += '</tr></tbody>';
			
			$(".calGrid").html(gridHTML);
			
			scheduleUser.getWeekMyInfoEventData(schedule_SetDateFormat(sun, '.'), schedule_SetDateFormat(sat, '.'));
		},
		//사용자 프로필의 일정 데이터 가져오기
		getWeekMyInfoEventData : function(sDate, eDate){
			var params = {
				"StartDate": CFN_TransServerTime(sDate.replaceAll(".", "-") + ' 00:00'),
				"EndDate": CFN_TransServerTime(schedule_SetDateFormat(schedule_AddDays(eDate.replaceAll(".", "-"), 1),'-') + ' 00:00'),
		    	"userCode": $("#userCode").val()
			}
			var url = "/groupware/schedule/getMyInfoProfileScheduleData.do";
			
			if(userId == sessionObj["USERID"]){
				url = "/groupware/schedule/getMyScheduleData.do";
				params.FolderIDs = parent.folderCheckList;
			}
			
			// 데이터 조회하기
			$.ajax({
			    url: url,
			    type: "POST",
			    data: params,
			    success: function (res) {
			    	if(res.status == "SUCCESS"){
						$.each(res.list, function(idx, el){
							el.StartDateTime = CFN_TransLocalTime(el.StartDateTime, 'yyyy-MM-dd HH:mm');
							el.StartDate = el.StartDateTime.split(' ')[0];
							el.StartTime = el.StartDateTime.split(' ')[1];
							el.EndDateTime = CFN_TransLocalTime(el.EndDateTime, 'yyyy-MM-dd HH:mm');
							el.EndDate = el.EndDateTime.split(' ')[0];
							el.EndTime = el.EndDateTime.split(' ')[1];
						});
			    		scheduleUser.drawWeekMyInfoEventData(res.list, sDate);
			    	} else {
						Common.Error(Common.getDic("msg_apv_030"));		// 오류가 발생했습니다.
					}
			    },
			    error:function(response, status, error){
					CFN_ErrorAjax("/groupware/schedule/getMyInfoProfileScheduleData.do", response, status, error);
				}
			});
		},
		//사용자 프로필의 일정 데이터 그리기
		drawWeekMyInfoEventData : function(eventDataArr, sunday){
		    var targetNo = sunday.replace(".", "").replace(".", "");		//targetNo는 table의 고유번호 sunday 값
		    var eventDataHTML = "";
		    var i, j;

			var trNum = 0; 
		    
			// 공백 컨텐츠 tr 생성
		    for (i = 0; i < 4; i++) {
		    	var targetNoNextID = i;
		    	var rowNo = i;
		    		
		    	eventDataHTML  += '<tr id="trAlldayBar_'+targetNo+'_'+targetNoNextID+'" RowNo="'+rowNo+'" >';
		        for (j = 0; j < 7; j++) {
		        	var schday = schedule_AddDays(sunday, j);
		            eventDataHTML  += '<td id="tdAlldayBar_'+targetNo+'_'+targetNoNextID+'_'+j+'" Day="'+j+'" schday="'+schedule_SetDateFormat(schday, '.')+'">&nbsp;</td>';
		        }
		        eventDataHTML += '</tr>';
		    }
		    $(".monShcList>tbody").html(eventDataHTML);

			$(".monShcList tr:last").addClass("last");
			trNum = $(".monShcList tr:last").attr('rowno');
			$(".calMonWeekRow, .calGrid").css("height", "100%");
	
		    for (var d = 0; d < eventDataArr.length; d++) {
		    	eventDataHTML = "";
		    	
		        var strSun = schedule_SetDateFormat(sunday, '/');
		        var g_sun = new Date(strSun);
		        var g_nsun = schedule_AddDays(strSun, 7);
		        var barColor = eventDataArr[d].Color;
		        
		        if (barColor == '' || barColor == null) { barColor = schedule_RandomColor('hex'); }
		        var EventID = eventDataArr[d].EventID;
		        var barImportance = eventDataArr[d].ImportanceState;
		        var barSubject = eventDataArr[d].Subject;
		        var sTime = eventDataArr[d].StartTime;
		        var eTime = eventDataArr[d].EndTime;
		        var sDate = eventDataArr[d].StartDate;
		        var eDate = eventDataArr[d].EndDate;
		        var isRepeat = eventDataArr[d].IsRepeat;
	
		        // 종일/반복처리시 종료일 
		        if (eTime == "00:00" || (eventDataArr[d].IsAllDay == "Y" && isRepeat == "Y")) {
		            if(eDate != sDate) {
		                eDate = schedule_SetDateFormat(schedule_SubtractDays(eDate.replace(/\./gi, '-'), 1), '.');
		            }
		            if (eTime == "00:00") {
		                eTime = "23:59";
		            }
		        }
	
		        var sDateTime = schedule_MakeDateForCompare(sDate, sTime);
		        var eDateTime = schedule_MakeDateForCompare(eDate, eTime);
	
		        var sDay = null; // 시작요일
		        var eDay = null; // 종료요일
		        var tDay = null; // 일정의 길이
		        var preDay = "N"; // 시작일이 일요일 이전
		        var nextDay = "N"; // 종료일이 토요일 이후
		        
		        // 하루가 넘는 경우
		        if (sDate != eDate) {
		            if (schedule_GetDiffDates(sDateTime, g_sun, 'day') > 0) { //시작일이 일요일 이전(일요일 부터): 연결 표시 필요
		                sDay = 0;
		                preDay = "Y";
		            } else { // 시작일이 일요일 이후
		                sDay = parseInt(schedule_GetDiffDates(g_sun, sDateTime, 'day'));
		            }
		            if (schedule_GetDiffDates(g_nsun, eDateTime, 'day') > 0) { //종료일이 토요일 이후(토요일까지) : 연결 표시 필요
		                eDay = 6;
		                nextDay = "Y";
		            } else { // 종료일이 토요일 이하
		                eDay = parseInt(schedule_GetDiffDates(g_sun, eDateTime, 'day'))
		            }
		            // 일일 일정
		        } else {
		            sDay = parseInt(schedule_GetDiffDates(g_sun, sDateTime, 'day'));
		            eDay = sDay;
		        }
	
		        tDay = (eDay + 1) - sDay;// 몇개의 요일을 걸치는지.
		        
		        var innerEventHTML = "";
		        var strAddCSS = "";
		        var className = "";
		        var isShowTime = false;
		        if (sDate != eDate || eventDataArr[d].IsAllDay == "Y") {
		        	className = "shcMultiDayText";
		        	strAddCSS = "background-color:"+barColor;
		            if (eventDataArr[d].IsAllDay != "Y") 
		            	isShowTime = true;
		            
		            if(preDay == "Y")
		            	className += " prevLine";
		        	if(nextDay == "Y")
		        		className += " nextLine";
		        		
		        }else{
		        	strAddCSS = "color:"+barColor;
		        	isShowTime = true;
		        	className = "shcDayText";
		        }
		        
		        innerEventHTML += "<div>";

	        	//중요도 및 반복 표시
	            if (barImportance == 'Y' && isRepeat == 'Y') {
	            	className += " rePoint";
	            }else if(barImportance == 'Y'){
	            	className += " point";
	            }else if(isRepeat == 'Y'){
	            	className += " repeat";
	            }
	            
		        // 시간 표시
		        if(isShowTime){
		        	innerEventHTML += '<span class="time">' + sTime + '</span>';
		        }
		        innerEventHTML += '<span class="txt"'+((preDay == "Y") ? ' style="margin-left: 15px;"' : '')+'>'+barSubject+'</span>';
		        innerEventHTML += '</div>';
		        
	        	if (isRepeat == 'Y') {
		        	innerEventHTML += '<div class="calToolTip">'+coviDic.dicMap["lbl_schedule_repeatSch"]+'</div>';		//반복일정
		        }
		        
		        eventDataHTML += '<div class="'+className+'" id="eventData_'+eventDataArr[d].DateID+'" style="'+strAddCSS+'" eventID="'+EventID+'" dateID="'+eventDataArr[d].DateID+'" isRepeat="'+isRepeat+'" folderID="'+eventDataArr[d].FolderID+'" registerCode="'+eventDataArr[d].RegisterCode+'" ownerCode="'+eventDataArr[d].OwnerCode+'" onclick="showSimpleScheduleView(this)">';
		        eventDataHTML += innerEventHTML + '</div>';

				var eventDivID = 'eventData_'+eventDataArr[d].DateID;
				var startDateTime = eventDataArr[d].StartDateTime.split(' ');
				var endDateTime = eventDataArr[d].EndDateTime.split(' ');
				
				if (startDateTime[0].split('-').join('.') < $(".monShcList tr:first td:first").attr('schday')) {		// 일정 시작일이 목록의 시작일보다 작으면 목록의 시작을로 설정
					startDateTime[0] = $(".monShcList tr:first td:first").attr('schday').split('.').join('-');
					preDay = 'Y';
				}
				
				// 하루 이상의 종일일정 여부 확인
				var duration = schedule_GetDiffDates(new Date(replaceDate(startDateTime[0])), new Date(replaceDate(endDateTime[0])), 'day');
				
				var overflowDuration = 0;
				if(endDateTime[0].split('-').join('.') > $(".monShcList tr:last td:last").attr('schday')){		// 종료일이 목록의 마지막 일자보다 큰 경우 오버플로두된 만큼 기간 차감
					overflowDuration = schedule_GetDiffDates(new Date(replaceDate(endDateTime[0])), new Date(replaceDate($(".monShcList tr:last td:last").attr('schday'))), 'day');
				}

				$.each($(".monShcList tr td[schday='"+startDateTime[0].split('-').join('.')+"']"), function(idx, el){
					var isStop = false;
					
					if ($(el).closest('tr').hasClass('last')) {
						$(".monShcList tbody").append($(el).closest('tr').clone(true))
						$(el).closest('tr').removeClass('last');
						$(".monShcList .last").attr("id", 'trAlldayBar_'+targetNo+'_'+(++trNum)).attr("rowno", trNum);
						$.each($(".monShcList .last td"), function(tdidx, tdele){
							tdele.id = $(".monShcList .last").attr("id")+"_"+ $(tdele).attr('day');
						})
 					}
					
					if (el.innerHTML == '&nbsp;') {
						el.innerHTML = eventDataHTML;
						isStop = true;
					}
					
					if (isStop) return false;
				});
				
				if (!isNaN(duration) && duration > 0) {			// 일정의 기간이 하루 이상인 경우 div와 동일한 영역을 가져와서, 일정의 시작일보다 크고, 종료일보다 같거나 작은 경우 해당 div에 event-id를 마킹
					duration = duration + overflowDuration;
					var dayIndex = Number($("#"+eventDivID).closest('td').attr('day'));
					var rowIndex = Number($("#"+eventDivID).closest('tr').attr('rowno'));
					for (var durIdx = 0; durIdx < duration; durIdx++){
						$(".monShcList tr[rowno='"+rowIndex+"'] td[day='"+(dayIndex+durIdx+1)+"']").remove();
					}
					$("#"+eventDivID).closest('td').attr("colspan", duration + 1);
				}
				
				if(preDay == 'Y') $("#"+eventDivID).addClass('prevLine');
		    }

			if(eventDataArr.length <= 0 && userId != sessionObj["USERID"]){
		    	$(".bulDashedTitle").html('<span class="colorTheme">*</span>'+coviDic.dicMap["msg_thereNoShareEvent"].replace("{0}", $("#UserName>strong").text()).replace("{1}", sessionObj["USERNAME"]));		//{0} 님이 {1} 님에게 공유한 일정이 없습니다.
		    }
		},
		// 일정 인쇄
		openPrintView : function(){
			$('.btnAddFunc, .addFuncLilst').removeClass('active');	//Context Menu 닫기
			
			CFN_OpenWindow("/groupware/schedule/printView.do", "", 1024, 768,  "scroll");
			
			//인쇄용 팝업 호출
			/*var contentsHtml = window.open('', 'PRINT', 'height=768,width=1024');
			var innerHtml = $("#content").clone();
			//innerHtml.children("script").remove();
			
			contentsHtml.document.write('<html><head><title>' + document.title  + '</title>');
			$("head link").each(function(idx,obj){
				try{
					contentsHtml.document.write(obj.outerHTML);
				}catch(e){}
			});
			
			contentsHtml.document.write('<script type="text/javascript" src="/groupware/resources/script/user/schedule.js"></script>');
			contentsHtml.document.write('<script type="text/javascript" src="/covicore/resources/script/Controls/Common.js"></script>');
			contentsHtml.document.write('</head><body >');
			contentsHtml.document.write('<div id="content"/>');
			contentsHtml.document.write('<div class="scheduleContentDiv">');
			contentsHtml.document.write(innerHtml.html());
			contentsHtml.document.write('</div></div>');
			contentsHtml.document.write('</body></html>');
			
			$(contentsHtml.document).find(".pagingType02").hide();
			$(contentsHtml.document).find(".searchBox02").hide();
			$(contentsHtml.document).find(".scheduleTop").hide();
			$(contentsHtml.document).find(".cRContBottom").css("overflow","hidden");
			$(contentsHtml.document).find(".cRConTop").css("borderBottom","0px");
			$(contentsHtml.document).find(".shcToDay ").removeClass("shcToDay");
			$(contentsHtml.document).find(".ui-selected ").removeClass("ui-selected");*/
			
			
			/*contentsHtml.document.close();	// necessary for IE >= 10
			contentsHtml.focus(); 			// necessary for IE >= 10
			
			setTimeout(function(){
				contentsHtml.print();
				contentsHtml.close();
			}, 1000);
			*/
			return true;
		},
		// 일정 상세보기 인쇄
		openPrintDetailView : function(){
			$('.btnAddFunc, .addFuncLilst').removeClass('active');	//Context Menu 닫기
		  	
			//Theme 타입 체크 후 적용
			var themeType = sessionObj["UR_ThemeType"];
	 		if(themeType == "" || themeType == undefined){
	 			themeType = "blue";
	 		}
			
			//인쇄용 팝업 호출
			var contentsHtml = window.open('', 'PRINT', 'height=768,width=1024');

			contentsHtml.document.write('<html><head><title>' + document.title  + '</title>');
			contentsHtml.document.write('<link rel="stylesheet" href="/HtmlSite/smarts4j_n/covicore/resources/css/common.css" type="text/css" />');
			contentsHtml.document.write('<link rel="stylesheet" href="/HtmlSite/smarts4j_n/board/resources/css/schedule.css" type="text/css" />');
			contentsHtml.document.write('<link rel="stylesheet" href="/HtmlSite/smarts4j_n/covicore/resources/css/theme/'+themeType+'.css" type="text/css" />');
			contentsHtml.document.write('</head><body >');
			contentsHtml.document.write('<div id="content"/>');
			contentsHtml.document.write('<div class="scheduleContentDiv">');
			contentsHtml.document.write($("#scheduleContentDiv").html());
			contentsHtml.document.write('</div></div>');
			contentsHtml.document.write('</body></html>');
			
			contentsHtml.document.getElementById("btnAddTemplate").style.display = "none";
			//contentsHtml.document.getElementById("commentView").style.display = "none";
			
			contentsHtml.document.close();	// necessary for IE >= 10
			contentsHtml.focus(); 			// necessary for IE >= 10
			
			setTimeout(function(){
				contentsHtml.print();
				contentsHtml.close();
			}, 1000);
			
		    return true;
		},
		// 상세등록 화면에서 자원 현황 보기
		openResourceView : function(){
			var openURL = "/groupware/resource/goViewPopup.do?CLSYS=resource&CLMD=user&CLBIZ=Resource&isPopupView=Y";
			
			// 예약일자에 맞는 날짜화면 표시
			var dirDate = $("#detailDateCon_StartDate").val();
			if(dirDate != undefined && dirDate != "") {
				openURL += "&startDate=" + dirDate;
			}
			
			Common.open("","resource_pop",Common.getDic("lbl_resource_resStatus"), openURL,"1060px","550px","iframe",true,null,null,true);		//자원예약 현황
		},
		// 일정 간편등록에서 자원 현황 보기
		openResourceOnlyView : function(){
			var openURL = "/groupware/resource/goViewPopup.do?CLSYS=resource&CLMD=user&CLBIZ=Resource&isPopupView=Y&onlyView=Y";
			
			// 예약일자에 맞는 날짜화면 표시
			var dirDate = $("#detailDateCon_StartDate").val();
			if(dirDate != undefined && dirDate != "") {
				openURL += "&startDate=" + dirDate;
			}
			Common.open("","resource_pop",Common.getDic("lbl_resource_resStatus"), openURL,"1060px","550px","iframe",true,null,null,true);		//자원예약 현황
		},
		setResourceToSchedule: function(checkedData){
			$("#resourceAutoComp").find("[class=ui-autocomplete-multiselect-item]").remove();
			
			$(checkedData).each(function(idx, el){
				var resFolderID = $(this).val();
				var resName = $(this).attr("label");
				
				var resourceObj = $("<div></div>")
	            .addClass("ui-autocomplete-multiselect-item")
	            .attr("data-json", JSON.stringify({"label":resName,"value":resFolderID,"FolderID":resFolderID,"ResourceName":resName,"LeastRentalTime":$(this).attr("data-least-rental-time"),"opType":"none"}))
				.attr("data-value", resFolderID)
	            .text(resName)
	            .append(
	                $("<span></span>")
	                    .addClass("ui-icon ui-icon-close")
	                    .click(function(){
	                        var item = $(this).parent();
	                        item.remove();
	                    })
	            );
				
				//parent.$("#resourceAutoComp .ui-autocomplete-multiselect").prepend(resourceObj);
				$(resourceObj).insertBefore("#Resource");
			});
		},
		//업무시간 체크
		changeWorkTime : function(obj){
			g_isWorkTime = $(obj).is(":checked");
			coviCmn.setCookie("useWorkTime_schedule_"+Common.getSession("UR_Code"), String(g_isWorkTime), 3);
			
			if(g_viewType == "D"){
				scheduleUser.schedule_MakeDayCalendar();
			}else if(g_viewType == "W"){
				scheduleUser.schedule_MakeWeekCalendar();
			}
		},
		// 예약 되어 있는 날짜에 대해서 표시하기
		setLeftCalendarEvent : function(sYear, sDate, eDate){
			$.ajax({
			    url: "/groupware/schedule/getLeftCalendarEvent.do",
			    type: "POST",
			    data: {
					"StartDate": CFN_TransServerTime(sDate.replaceAll(".", "-") + ' 00:00'),
					"EndDate": CFN_TransServerTime(schedule_SetDateFormat(schedule_AddDays(eDate.replaceAll(".", "-"), 1),'-') + ' 00:00'),
			    	"FolderIDs": folderCheckList
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
			    					var year = startDateObj.getFullYear();
			    					var month = startDateObj.getMonth() + 1;
				    				var day = startDateObj.getDate();
				    				
				    				if(year == sYear) {
				    					$("#cal_body").find("div[month="+month+"][id="+day+"]").addClass("mark");
				    				}
			    					
			    					startDateObj.setDate(day + 1);
			    				}
			    			}
			    		});
			    	} else {
			    		parent.Common.Error(Common.getDic("msg_apv_030"));		// 오류가 발생했습니다.
			    	}
			    },
			    error:function(response, status, error){
			    	parent.CFN_ErrorAjax("/groupware/schedule/getLeftCalendarEvent.do", response, status, error);
			    }
			});
		},
		
		// 월간보기 더보기 팝업
		MonthShowMore : function(obj){
			var MonWeekRow = $(obj).closest(".calMonWeekRow");
			var count =  $(obj).closest("tbody").find(".daybar_off:hidden").length;
			
			if(count>0){
				$(obj).closest("tbody").find(".daybar_off:hidden").show();
			}
			else{
				$(obj).closest("tbody").find(".daybar_off:visible").hide();		
			}
		},
		
		// 엑셀 다운로드
		excelDownload : function() {
			var importanceState = "";
			var subject = $("#searchSubject").val();
			var placeName = $("#searchPlace").val();
			var register = $("#serachRegister").val();
			var sDate = g_startDate;
			var eDate = g_endDate;
			
			if(eDate == undefined || eDate == "undefined"){
				sDate = schedule_SetDateFormat(new Date(g_year, (g_month - 1), 1), '.');
				eDate = schedule_SetDateFormat(new Date(g_year, g_month, 0), '.');
			}
			
			if(type == "import"){
				importanceState = "Y";
			}else if(type == "all"){
				folderIDs = null;
			}
			
			var searchStartDate = parent.$("#searchDateCon_StartDate").val();
			var searchEndDate = parent.$("#searchDateCon_EndDate").val();
			
			if(searchStartDate != "" && searchEndDate != ""){
				sDate = searchStartDate;
				eDate = schedule_SetDateFormat(schedule_AddDays(searchEndDate, 1), '.');
			}
			
			var paramJSON = {
				"orderBy" : "startTime",
				"showDeleted" : false,
				"singleEvents" : true,
				"timeMax" : new Date(replaceDate(eDate)).toISOString(),
				"timeMin" : new Date(replaceDate(sDate)).toISOString()
			};
			
			var includeGoogleYn = 'N';
    		//2019.03 성능개선
    		if(isConnectGoogle && g_googleFolderID == null){
    			Common.getBaseConfigList(["ScheduleGoogleFolderID","SchedulePersonFolderID","WorkStartTime","WorkEndTime"]);
    			g_googleFolderID = coviCmn.configMap["ScheduleGoogleFolderID"];
    		}			
			if (folderCheckList.indexOf(";"+g_googleFolderID + ";") > -1 && isConnectGoogle) includeGoogleYn = 'Y';	// 구글 시트 포함
			
			var params = {
					"FolderIDs" : folderCheckList,
					"StartDate" : sDate.replaceAll(".", "-"),
					"EndDate" : eDate.replaceAll(".", "-"),
					"UserCode" : userCode,
					"lang" : lang,
					"ImportanceState" : importanceState,
					"Subject" : subject,
					"PlaceName" : placeName,
					"RegisterName" : register,
					"paramJSON" : JSON.stringify(paramJSON),
					"includeGoogleYn" : includeGoogleYn
			};
			
			if (g_viewType == 'List') {	// 목록보기
				ajax_download('/groupware/schedule/excelDownload.do', params);	// 엑셀 다운로드 post 요청
			} else {
				alert('구현 중 입니다.');
			}
		},
		// 체크 폴더 데이터 세팅
		saveChkFolderListRedis : function(chkList){
			$.ajax({
			    url: "/groupware/schedule/saveChkFolderListRedis.do",
			    type: "POST",
			    data: {
			    	"checkList":chkList
				},
				success: function (res) {
					if(res.status == "FAIL"){
						Common.Error(Common.getDic("msg_apv_030"));		// 오류가 발생했습니다.
					}
				},
			    error:function(response, status, error){
			    	parent.CFN_ErrorAjax("/groupware/schedule/saveChkFolderListRedis.do", response, status, error);
			    }
			});
		},
	resource_SimpleViewPopup: function(target){
		var eventID = $(target).attr("eventid");
		var dateID = $(target).attr("dateid");
		var resourceID = $(target).attr("resourceid");
		var repeatID = $(target).attr("repeatid");
		$("#popup").load("/groupware/resource/getSimpleViewView.do", function(){
			$("#simpleViewPop #divBtnBottom").remove();
			$("#simpleViewPop").css({
				left: "calc(50% - 170px)",
				top: "calc(50% - 100px)"
			});
			resourceUser.setViewData("S", eventID, dateID, resourceID, repeatID);
			setTimeout(function(){ $("#simpleViewPop #Register .btnFlowerName").removeAttr("onclick").css("cursor", "default"); }, 500)
		});
	}
}


//scheduleUser.setAclEventFolderData();


// 공통 함수에서 장소 함수 접근하기 위해서 객체에서 제외함
//장소 이미지 그리기
function drawMap(place){
	if(place != null){
		var x = place[0].point.x;
		var y = place[0].point.y;
		
		var src = coviCtrl.geocode2Img(x, y, $(".map").width(), $(".map").height());
		$("#placeMapImg").attr("src", src);
	}else{
		$("#placeMap").hide();
	}
}


//class에 대한 이벤트 바인딩
function btnFoldOnClick(obj){
	if($(obj).hasClass('active')){
		$(obj).removeClass('active');
		$('.tablCalendar').removeClass('active');
		$('.calendarTop').removeClass('active');
		
		$("#calTopDateVal").val($('.calTopdate').text());
		
		$('.calTopdate').text(g_currentTime.getFullYear() + '.' + AddFrontZero((g_currentTime.getMonth()+1), 2) + '.' + AddFrontZero(g_currentTime.getDate(), 2));
	}else {
		$(obj).addClass('active');
		$('.tablCalendar').addClass('active');
		$('.calendarTop').addClass('active');
		
		$('.calTopdate').text($("#calTopDateVal").val());
	}
}
function bntOftenOnClick(obj){
	if($(obj).hasClass('active')){
		$(obj).removeClass('active');
		$('.oftenSchCont').removeClass('active');
		$('.oftScroll').mCustomScrollbar("destroy");
	}else {
		$(obj).addClass('active');
		$('.oftenSchCont').addClass('active');
		$('.oftScroll').mCustomScrollbar({
			theme:"dark", axis:"x",
			callbacks:{
				onCreate:function(){
					var width = 0;
					for(var i = 0; i < $('.oftSchCard').length; i++){
						width += $('.oftSchCard').eq(i).width();
					}
					$('.oftCont').css('width', width + 90);
				},
				onBeforeUpdate:function(){
				  var width = 0;
					for(var i = 0; i < $('.oftSchCard').length; i++){
						width += $('.oftSchCard').eq(i).width();
					}
					$('.oftCont').css('width', width + 90);
				}
			}
		});
		
		// 그려진 데이터가 없을 경우에만 그림
		if($("#templateList").html() == ""){
			scheduleUser.getTemplateScheduleList();
		}
	}
}
function clickTap(obj){
	$('.tabMenu>li').removeClass('active');
	$('.tabContent').removeClass('active');
	$(obj).addClass('active');
	$('.tabContent').eq($(obj).index()).addClass('active');
}
function importantOnClick(obj){
	if($(obj).hasClass('active')){
		$("#ImportanceState").val("N");
		$(obj).removeClass('active');
	}else {
		$("#ImportanceState").val("Y");
		$(obj).addClass('active');
	}
}
function btnUrgentOnClick(){
	if($(".tblBoradDisplay").length > 0){
		var parentId = $(".tblBoradDisplay").parent().attr("id");
		var index = Number(parentId.substring(parentId.lastIndexOf('_')+1, parentId.length));
		if($(".btnUrgent").eq(index).hasClass("active"))
			$(".btnUrgent").eq(index).removeClass("active");
		else
			$(".btnUrgent").eq(index).addClass("active");
	}else{
		$(".btnUrgent").addClass("active");
	}
}
function btnTopOptionMenuOnClick(obj){
	var displayCont = $(obj).siblings('.topOptionListCont');
	if(displayCont.hasClass('active')){
		displayCont.removeClass('active');
		$(obj).removeClass('active');
	}else {			
		$('.topOptionListCont').removeClass('active');
		$(obj).addClass('active');
		displayCont.addClass('active');
	}
}
function btnTopOptionContCloseOnClick(){
	var displayCont = $('.topOptionListCont');
	displayCont.removeClass('active');
}
function sleOpTitleOnClick(obj){
	if(CFN_GetQueryString("eventID") == "undefined" || Number(CFN_GetQueryString("eventID"))){
		if($(obj).hasClass('active')){
			$(obj).removeClass('active');
			$(obj).parent().find('.selectOpList').removeClass('active');
		}else {
			$(obj).addClass('active');
			$(obj).parent().find('.selectOpList').addClass('active');
		}
	}else{
		Common.Inform(Common.getDic("msg_cannotChangeGoogleFolder"));			//구글일정 수정 시 구분을 변경할 수 없습니다.
	}
}
//일정관리 폴더 선택 Onclick
function selectOpListLiOnclick(obj, mode){
	$(obj).parent().parent().find(".sleOpTitle").html($(obj).html());
	$(obj).parent().parent().find('.selectValue').val($(obj).data( "selvalue" ));
	$(obj).parent().parent().find(".sleOpTitle").removeClass('active');
	$(obj).closest('.selectOpList').removeClass('active');
	
	//2019.03 성능개선
	if(g_googleFolderID == null){
		Common.getBaseConfigList(["ScheduleGoogleFolderID","SchedulePersonFolderID","WorkStartTime","WorkEndTime"]);
		g_googleFolderID = coviCmn.configMap["ScheduleGoogleFolderID"];
	}
	// 구글연동을 선택했을 경우
	if($(obj).data( "selvalue" ) == g_googleFolderID || $(obj).attr("folderType") == "Schedule.Google"){
		
		if(mode == "S"){
			// 자원 탭 숨김
			$("#tapRES").hide();
		}
		else if(mode == "D"){
			// 중요도 숨김
			$("#aImportanceState").hide();
			
			// 자원 숨김
			$("#wrtDivRES").hide();
			
			// 알림 숨김
			$("#divNotification").hide();
			
			//첨부파일 숨김
			$("#fileDiv").hide();
		}
	}else{
		if(mode == "S"){
			// 자원 탭 표시
			$("#tapRES").show();
		}
		else if(mode == "D"){
			// 중요도 표시
			$("#aImportanceState").show();
			
			// 자원 표시
			$("#wrtDivRES").show();
			
			// 알림 표시 - 등록화면에서만 표시함
			if(CFN_GetQueryString("isTemplate") == "Y" || (CFN_GetQueryString("eventID") == "undefined" || CFN_GetQueryString("eventID") == "")){
				$("#divNotification").show();
			}
			
			//첨부파일 표시
			$("#fileDiv").show();
		}
	}
}

// 엑셀 다운로드 post 요청
function ajax_download(url, data) {
    var $iframe, iframe_doc, iframe_html;

    if (($iframe = $('#download_iframe')).length === 0) {
        $iframe = $("<iframe id='download_iframe' style='display: none' src='about:blank'></iframe>").appendTo("body");
    }

    iframe_doc = $iframe[0].contentWindow || $iframe[0].contentDocument;
    if (iframe_doc.document) {
        iframe_doc = iframe_doc.document;
    }

    iframe_html = "<html><head></head><body><form method='POST' action='" + url +"'>" 
    Object.keys(data).forEach(function(key) {
        iframe_html += "<input type='hidden' name='"+key+"' value='"+data[key]+"'>";
    });
    iframe_html +="</form></body></html>";

    iframe_doc.open();
    iframe_doc.write(iframe_html);
    $(iframe_doc).find('form').submit();
}

// 21.07.26, 일정관리 미리알림 부분 제한.
function checkAlarmSave(repeat) {
	// 매주 월~금, 1년의 미리알람 저장일 경우 구동되는 Query가 많아서 실행되다 중간에 끊어지는 경우가 생김. 이로 인해 제한 체크 로직 지정.
	// 제한 조건 : 요일을 다중으로 선택했다면, 기간은 최대 6개월 or 반복범위 최대 10회차 일 때 저장가능하게 제한.
	var cntDay = 0;			// 반복 요일 갯수
	
	// 반복 요일 체크 확인.
	(repeat.RepeatMonday == 'Y') ? cntDay++ : cntDay;
	(repeat.RepeatTuesday == 'Y') ? cntDay++ : cntDay;
	(repeat.RepeatWednseday == 'Y') ? cntDay++ : cntDay;
	(repeat.RepeatThursday == 'Y') ? cntDay++ : cntDay;
	(repeat.RepeatFriday == 'Y') ? cntDay++ : cntDay;
	(repeat.RepeatSaturday == 'Y') ? cntDay++ : cntDay;
	(repeat.RepeatSunday == 'Y') ? cntDay++ : cntDay;

	// 반복범위 일자 체크.	
	var strStartDate = repeat.RepeatStartDate.split("-");
	var strEndDate = repeat.RepeatEndDate.split("-");

	var dtStartDate = new Date(strStartDate[0], strStartDate[1], strStartDate[2]);
	var dtEndDate = new Date(strEndDate[0], strEndDate[1], strEndDate[2]);
	
	var diff = dtEndDate - dtStartDate;
	var currMonth = 24 * 60 * 60 * 1000 * 30;
	
	if ( (cntDay > 1) && (repeat.RepeatEndType == "I") && ( parseInt(diff/currMonth) > 6 ) ) {
		// 요일 다중선택이면서, 지정된 일까지 반복이고, 기간이 6개월 이상일 때 알림저장 불가.
		flag4AlarmSave = "N";
	} else if ( (cntDay > 1) && (repeat.RepeatEndType == "R") && (repeat.RepeatCount > 10) ) {
		// 요일 다중선택이면서, N회 반복이고, 반복기간이 11회 이상이면 알림 저장 불가.
		flag4AlarmSave = "N";
	} else {
		flag4AlarmSave = "Y";
	}
	
	return flag4AlarmSave;
}

function callbackAutoTagResource(item) {
	$("#resourceAutoComp .ui-autocomplete-multiselect-item[data-value="+item.value+"]").attr("data-json", JSON.stringify(item));
}
