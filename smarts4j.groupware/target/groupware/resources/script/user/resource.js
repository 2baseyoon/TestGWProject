var resAclArray = {};
var sessionObj = Common.getSession(); //전체호출
var lang = sessionObj["lang"];
var userCode = sessionObj["USERID"];

var g_isWorkTime = false;			//업무시간 체크 여부

var g_year;
var g_month;
var g_day;
var g_viewType = "D";
var g_currentTime = new Date(CFN_GetLocalCurrentDate("yyyy/MM/dd HH:mm:ss"));

var arrSunday = new Array();

var g_startDate;
var g_endDate;

var g_isPopup = false;
var popObj;

// 주간 일간 resize 시 선택한 object 저장
var g_selectStartObj;

var g_fileList = null;

var grid = new coviGrid();
var myGrid = new coviGrid();
var requestGrid = new coviGrid();

var updateBookingDataObj;				// 수정을 위한 temp 데이터

// 일정 등록 시 자원 사업장 변수 추가
var placeOfBusinessSchedule= "";

var resourceUser = {
	initialized: false,
		initJS : function(){
			g_currentTime = new Date(CFN_GetLocalCurrentDate("yyyy/MM/dd HH:mm:ss"));
			
			g_startDate = schedule_SetDateFormat(g_currentTime, '.');

			//$('.sSListCol').css('height', $('.specialScheduleTitle').height());
			//$('.weekListCol').css('height', $('.weeklyListTitle').height());
			
			$('#content').off('click').on('click', function(e) {
				if ($("article[id=read_popup]").html() != '' && !$(e.target).parents().andSelf().is('#read_popup')) {
					$("article[id=read_popup]").html('');
			    }
				if ($("article[id=popup]").html() != '' && !$(e.target).parents().andSelf().is('#popup')) {
					$("article[id=popup]").html('');
			    }
			});
			
			if(location.href.indexOf("resource_View.do") < 0){
				resourceUser.fn_resource_onload();
			}
			
			if(resAclArray.status != "SUCCESS") {
				resourceUser.setAclEventFolderData();
			}
			
			if( CFN_GetCookie("useWorkTime_resource_"+Common.getSession("UR_Code")) != '') {
				g_isWorkTime = coviCmn.getCookie("useWorkTime_resource_"+Common.getSession("UR_Code")) == 'true';
	        } else {
				g_isWorkTime = (Common.getBaseConfig('useWorkTime') == 'Y');
				coviCmn.setCookie("useWorkTime_resource_"+Common.getSession("UR_Code"), String(g_isWorkTime), 3);
			}
			
			resourceUser.initialized = true;
		},
		// 자원예약 로드시
		fn_resource_onload : function(){
			g_isPopup = false;
			popObj = null;
			
			g_viewType = CFN_GetQueryString("viewType");
			g_startDate = CFN_GetQueryString("startDate");
			g_endDate = CFN_GetQueryString("endDate");
			
			if(g_startDate == "undefined" || g_startDate == "" || g_startDate == null){
				g_startDate = CFN_GetLocalCurrentDate("yyyy.MM.dd");
			}
			if(g_endDate == "undefined" || g_endDate == "" || g_endDate == null){
				g_endDate = g_startDate;
			}
			if(g_viewType == "undefined" || g_viewType == "" || g_viewType == null){
				g_viewType = "D";
			}
			
			g_year = g_startDate.split(".")[0];			// 전역변수 세팅
			g_month = g_startDate.split(".")[1];		// 전역변수 세팅
			g_day = g_startDate.split(".")[2];			// 전역변수 세팅
			
			if(CFN_GetQueryString("isPopupView") != 'Y'){
				$("#calTopDateVal").val(g_year + "." + AddFrontZero(g_month));
				
				if($("#leftCalendar").hasClass("active"))
					$('.calTopdate').text(g_year + '.' + g_month);
				else
					$('.calTopdate').text(g_currentTime.getFullYear() + '.' + AddFrontZero((g_currentTime.getMonth()+1), 2) + '.' + AddFrontZero(g_currentTime.getDate(), 2));
				makeLeftCalendar();		// 달력 그리기
			}
		    //개별호출-일괄호출
		    Common.getBaseConfigList(["SchedulePersonFolderID"]);
		},
		// 일간, 주간, 월간, 리스트 보기
		fn_resourceView_onload : function(){
			resourceUser.fn_resource_onload();
			
			window.onresize = resourceUser.setResizeFunction;
			if(CFN_GetQueryString("isPopupView") != 'Y' && g_viewType != "M"){
				resourceUser.setDivision();
			}
			
			var liID = "";
			if(g_viewType == "M"){
				$("#DayCalendar,#WeekCalendar,#List").hide();
				$("#moveBar,.resourceContScrollMiddle,.resourceContScrollBottom").hide();		// 나의 자원예약, 승인/반납 요청 숨김
				$("#MonthCalendar").show();
				$(".resourceContainerScroll").css("overflow-y", "auto");
				liID = "liMonth";
			}else if(g_viewType == "D"){
				$("#WeekCalendar,#MonthCalendar,#List").hide();
				$("#moveBar,.resourceContScrollMiddle,.resourceContScrollBottom").show();		// 나의 자원예약, 승인/반납 요청 표시
				$("#DayCalendar").show();
				liID = "liDay";
			}else if(g_viewType == "W"){
				$("#DayCalendar,#MonthCalendar,#List").hide();
				$("#moveBar,.resourceContScrollMiddle,.resourceContScrollBottom").show();		// 나의 자원예약, 승인/반납 요청 표시
				$("#WeekCalendar").show();
				liID = "liWeek";
			}else if(g_viewType == "List"){
				$("#DayCalendar,#WeekCalendar,#MonthCalendar").hide();
				$("#moveBar,.resourceContScrollMiddle,.resourceContScrollBottom").show();		// 나의 자원예약, 승인/반납 요청 표시
				$("#List").show();
				liID = "liList";
			}
			
			$("#topButton").find("li").removeClass("selected");
			$("#"+liID).addClass("selected");
			
			if($("#searchDateCon").length != 0){
				resourceUser.setSearchControl();
			}
		},
		//권한에 따른 폴더 데이터 가져오기
		setAclEventFolderData : function(){
			/*if (localCache.exist("resAclArray_" + userCode)) {
				resAclArray = localCache.get("resAclArray_" + userCode);
			} else {*/
				$.ajax({
				    url: "/groupware/resource/getACLFolder.do",
				    type: "POST",
				    data: {},
				    async: false,
				    success: function (res) {
				    	if(res.status == "SUCCESS"){
				    		resAclArray = res;
				    		//localCache.set("resAclArray_" + userCode, res, "");
				    	}else{
				    		Common.Error(Common.getDic("msg_apv_030"));		// 오류가 발생했습니다.
				    	}
			        },
			        error:function(response, status, error){
						CFN_ErrorAjax("/groupware/resource/getACLFolder.do", response, status, error);
					}
				});
			//}
		},
		// 오늘로 이동
		goCurrent : function(){
			g_startDate = schedule_SetDateFormat(g_currentTime, ".");
			g_year = g_startDate.split(".")[0];			// 전역변수 세팅
			g_month = g_startDate.split(".")[1];		// 전역변수 세팅
			g_day = g_startDate.split(".")[2];			// 전역변수 세팅
			
			$("#leftmenu .selected").removeClass("selected");
			
			clickTopButton(g_viewType);
		},
		//Resize에 대한 이벤트 세팅
		setResizeFunction : function(){
			if(g_viewType != "M"){
				//$(".resourceContent").css("height", pxToNumber($("#contents").css("height")));
			}
		},
		// 바 조절 함수
		setDivision : function(){
			var content = $(".resourceContent");
		    var pan1 = $('.resourceContScrollTop');
		    var pan2 = $('.resourceContScrollBottom');
		    var bar =  $('#moveBar');
			
			var contentHight = pxToNumber($(".cRContBottom").css("height")) - 10;
			var setheight = CFN_GetCookie("ListChangeVal");
			
			content.css("height", contentHight);
			if(setheight == "" || setheight == undefined || setheight == 'NaN'){
				pan1.css("height", "50%");
				pan2.css("height", "50%");	
			} else {
				pan1.css("height", setheight + "%");
				pan2.css("height", 100 - setheight + "%");
			}
			
			$("#ifmMyBooking, #ifmRequestBooking").height(pan2.height() - 70);
			
			var min = 100;
//			var max = contentHight - 300;
			var max = contentHight;

		    var unlock = false;
			$(document).mousemove(function (e) {
		        if (unlock) {
			
			        var change = e.pageY - $(".cRContBottom").offset().top;
					if (change > min && change < max) {
		        		pan1.css('height', (change / contentHight) * 100 + "%");
		        		pan2.css('height', 100 - ((change / contentHight) * 100) + "%");
						
						CFN_SetCookieDay("ListChangeVal", (change / contentHight) * 100, null); // 쿠키저장
		        	}
		        }
		    });
		    bar.mousedown(function (e) {
		        unlock = true;
		    });
		    $(document).mousedown(function (e) {
		        if (unlock) {
		            e.preventDefault();
		        }
		    });
		    $(document).mouseup(function (e) {
		        unlock = false;
		    });
		},
		// 검색 관련 Control 세팅
		setSearchControl : function(){
			// 검색 상태 Select Box 세팅
			if(this.Code != "ApprovalState" && this.Code != ""){
				$("#searchApprovalState").html(coviCtrl.makeSelectData(Common.getBaseCode("ApprovalState")["CacheData"], {hasAll:true,id:"",defaultVal:""}, this.lang));
			}
			
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
		// 자원예약 정보 가져오기
		getMonthBookingData : function(sDate, eDate){
			var folderID = g_folderList;				// 좌측 메뉴 체크 항목
			var hasAnniversary = "N";
			
			if(folderID == ";")
				folderID = "";
			
			if(g_viewType == "M" || g_viewType == "W"){
				hasAnniversary = "Y";
			}
			
			sDate = (sDate.length == 10) ? sDate.replaceAll(".", "-") + ' 00:00' : sDate;
			eDate = (eDate.length == 10) ? schedule_SetDateFormat(schedule_AddDays(eDate.replaceAll(".", "-"), 1),'-') + ' 00:00' : eDate;
			
			$.ajax({
			    url: "/groupware/resource/getBookingList.do",
			    type: "POST",
			    data: {
			    	"mode": g_viewType,
			    	"FolderID": folderID,
					"StartDate": CFN_TransServerTime(sDate),
					"EndDate": CFN_TransServerTime(eDate),
			    	"hasAnniversary": hasAnniversary,
					"isGetShared": "Y",
					"placeOfBusiness" : placeOfBusinessSchedule

				},
			    success: function (res) {
			    	resourceUser.setAnniversaryData(res.anniversaryList);
			    	
			    	if(res.status == "SUCCESS"){
						

			    		if(g_viewType == "M"){
							$.each(res.data.bookingList, function(idx, el){
								el.StartDateTime = CFN_TransLocalTime(el.StartDateTime, 'yyyy-MM-dd HH:mm');
								el.StartDate = el.StartDateTime.split(' ')[0];
								el.StartTime = el.StartDateTime.split(' ')[1];
								el.EndDateTime = CFN_TransLocalTime(el.EndDateTime, 'yyyy-MM-dd HH:mm');
								el.EndDate = el.EndDateTime.split(' ')[0];
								el.EndTime = el.EndDateTime.split(' ')[1];
							});
		    				if(res.data.bookingList.length > 0)
		    					resourceUser.setMonthBookingData(res.data.bookingList);
			    		}
			    		else{
							$.each(res.data.folderList, function(folderIdx, folderEl){
								$.each(folderEl.bookingList, function(idx, el){
									el.StartDateTime = CFN_TransLocalTime(el.StartDateTime, 'yyyy-MM-dd HH:mm');
									el.StartDate = el.StartDateTime.split(' ')[0];
									el.StartTime = el.StartDateTime.split(' ')[1];
									el.EndDateTime = CFN_TransLocalTime(el.EndDateTime, 'yyyy-MM-dd HH:mm');
									el.EndDate = el.EndDateTime.split(' ')[0];
									el.EndTime = el.EndDateTime.split(' ')[1];
								});
							});
				
			    			if(res.data.folderList.length > 0){
				    			if(g_viewType == "D")
				    				resourceUser.setDayBookingData(res.data);
				    			else if(g_viewType == "W")
				    				resourceUser.setWeekBookingData(res.data);
			    			}
			    		}
			    	} else {
						Common.Error(Common.getDic("msg_apv_030"));		// 오류가 발생했습니다.
					}
		        },
		        error:function(response, status, error){
					CFN_ErrorAjax("/groupware/resource/getBookingList.do", response, status, error);
				}
			});
		},
		setAnniversaryData : function(anniversaryList){
			if(anniversaryList != undefined){
				$(anniversaryList).each(function(idx, obj){
					$("span[name='dayInfo'][value='"+obj.SolarDate+"']").text("("+CFN_GetDicInfo(obj.Anniversary)+")").css("color","red");
				});
			}
		},
		// 월간 보기 데이터 그림
		setMonthBookingData : function(bookingList){
			// 주별로 데이터 분리
			var eventArr = new Array();
			var eventObj = new Array();
			var weekDateArr = {};
			
			$(arrSunday).each(function(i, val){
				eventObj = new Array();
				var sDate = val;
				var eDate = schedule_AddDays(val, 6);
				
				$(bookingList).each(function(j){
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
				resourceUser.drawMonthBookingData(eventArr[i], arrSunday[i]);
			}
		},
		drawMonthBookingData : function(eventDataArr, sunday){
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
		    
		    for (var d = 0; d < eventDataArr.length; d++) {
		    	eventDataHTML = "";
		    	
		        var strSun = schedule_SetDateFormat(sunday, '/');
		        var g_sun = new Date(strSun);
		        var g_nsun = schedule_AddDays(strSun, 7);
		        
		        var EventID = eventDataArr[d].EventID;
		        var barSubject = eventDataArr[d].FolderName;
		        var sTime = eventDataArr[d].StartTime;
		        var eTime = eventDataArr[d].EndTime;
		        var sDate = eventDataArr[d].StartDate;
		        var eDate = eventDataArr[d].EndDate;
		        var isRepeat = eventDataArr[d].IsRepeat;
		        var sbj = eventDataArr[d].Subject;

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
		        if (sDate != eDate || eventDataArr[d].IsAllDay == "Y") {
		        	className = "shcMultiDayText";
		            if(preDay == "Y")
		            	className += " prevLine";
		        	if(nextDay == "Y")
		        		className += " nextLine";
		        }else{
		        	className = "shcDayText";
		        }
		        
		        // 나의 예약 /  기존 예약 구분
		        if(eventDataArr[d].RegisterCode == userCode)
		        	className += " my";
		        else
		        	className += " comp";
		        
		        innerEventHTML += "<div>";
		        if(preDay == "Y" && $(".calMonBody").eq(0).find("[class=calMonWeekRow]").attr("id").split("_")[1] != targetNo){			// 이어지는 날짜의 뒤이고, 첫번째  주가 아닌 경우
		        	 innerEventHTML += '<span class="txt" style="visibility: hidden;">'+barSubject+'</span>';
		        }
		        else{
		        	
		        	//중요도 및 반복 표시
		            if(isRepeat == 'Y'){
		            	className += " repeatW";
		            }
		            
			       innerEventHTML += '<span class="time">' + sTime + '</span>';
			       innerEventHTML += '<span class="txt">' + barSubject + " - " + sbj +'</span>';
			        innerEventHTML += '</div>';
			        
			        if (isRepeat == 'Y') {
			        	innerEventHTML += '<div class="calToolTip">반복일정</div>';
			        }
		        }
		        
		        eventDataHTML += '<div class="'+className+'" id="eventData_'+eventDataArr[d].DateID+'" style="'+strAddCSS+'" eventID="'+EventID+'" dateID="'+eventDataArr[d].DateID+'" repeatID="'+eventDataArr[d].RepeatID+'" isRepeat="'+isRepeat+'" resourceID="'+eventDataArr[d].ResourceID+'" onclick="resourceUser.setSimpleViewPopup(this)">';
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
		                eventDataHTML += '<tr id="trAlldayBar_'+targetNo+'_'+rowNum+'" RowNo="'+rowNum+'" class="daybar_off" style="display : none;" >';
		                for (i = 0; i < 7; i++) {
		                	eventDataHTML += '<td id="tdAlldayBar_'+targetNo+'_'+rowNum+'_'+i+'" Day="'+i+'">&nbsp;</td>';
		                }
		                eventDataHTML += '</tr>';
		                
		                $(eventDataHTML).insertBefore("#trAlldayBar_" + targetNo + "_more");
		                $("#divWeekScheduleForMonth_" + targetNo).find(".daybar_off").each(function(idx, item) { //Tr Loop
		                    var targetTdCnt = 0;
		                    $(this).children().each(function () {  // Tr Loop
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
	    			$(trObj).find("td[id*=tdAlldayBar][id*=more_"+i+"]").html('<div class="moreShcDayTextView"><a onclick="resourceUser.MonthShowMore(this);">+'+this+'</a></div>')
	    		}
	    	});
		    
		    // 자원예약에서 drag & drop 기능을 지원하진 않지만,
		    // jquery ui에서 selectable 이벤트 관련 중복을 방지하기 위해서 drag & drop 기능 바인딩
		    // 실제 동작하지 않음
		    $("[id^=tdAlldayBar_]").droppable();
		    $("[id^=eventData_]").draggable({containment: "parent"});
		    $(".moreShcDayTextView>a").draggable({
		    	containment: "parent",
		    	start : function(event, ui){
		    		return false;
		    	}	
		    });
		},
		// 일간 그리기
		resource_MakeDayCalendar : function(){
			// 상단 제목 날짜 표시
			$('#dateTitle').html(g_year + "." + g_month + "." + g_day);
			
			// 시간을 보여주는 header 부분
			var headerTimeHTML = "";
			
			// 업무시간으로 체크되었을 경우
			var timeStart = 0;
		    var timeEnd = 24;
		    
		    if(g_isWorkTime){
				$("input:checkbox[id='chkWorkTimeDay']").prop("checked", true); //check박스 checked 표시
		    	//개별호출-일괄호출
		    	Common.getBaseConfigList(["WorkStartTime", "WorkEndTime"]);
		    	
			    if(coviCmn.configMap["WorkStartTime"] != ""){
			    	timeStart = Number(coviCmn.configMap["WorkStartTime"]);
			    }
			    if(coviCmn.configMap["WorkEndTime"] != ""){
			    	timeEnd = Number(coviCmn.configMap["WorkEndTime"]);
			    }
		    }
		    
			headerTimeHTML += '<tbody><tr>';
			
			for(var i = timeStart; i<timeEnd; i++){
				var nowClass = "";
				// 현재 시각 표시
				if(g_startDate == schedule_SetDateFormat(g_currentTime, ".") && g_currentTime.getHours() == i)
					nowClass = 'class="selected"';
				
				headerTimeHTML += '<th colspan="2" '+nowClass+'>'+AddFrontZero(i, 2)+'</th>';
			}
			
			headerTimeHTML += '</tr></tbody>';
			
			$("#headerTimeList").html(headerTimeHTML);
			var sDate = g_startDate.replaceAll(".", "-");
			var eDate = g_endDate.replaceAll(".", "-");
			
			if(g_isWorkTime){
				sDate = sDate + ' ' + AddFrontZero(timeStart, 2) + ':00';
				eDate = eDate + ' ' + AddFrontZero(timeEnd, 2) + ':00';
			}
			
			// 데이터 조회해서 그림
			resourceUser.getMonthBookingData(sDate, eDate);
		},
		// 자원예약 일간 데이터 그리기
		setDayBookingData : function(data){
			// 업무시간으로 체크되었을 경우
			var timeStart = 0;
		    var timeEnd = 24;
			
		    if(g_isWorkTime){
				$("input:checkbox[id='chkWorkTimeDay']").prop("checked", true); //check박스 checked 표시
		    	//개별호출-일괄호출
		    	Common.getBaseConfigList(["WorkStartTime", "WorkEndTime"]);		    	
			    if(coviCmn.configMap["WorkStartTime"] != ""){
			    	timeStart = Number(coviCmn.configMap["WorkStartTime"]);
			    }
			    if(coviCmn.configMap["WorkEndTime"] != ""){
			    	timeEnd = Number(coviCmn.configMap["WorkEndTime"]);
			    }
		    }
		    
			var folderList = data.folderList;

			// 폴더 기준으로 뒷 배경 그리기
			var folderListHTML = '<div>';
			
			var resourceListHTML =  '<div class="reserTblView"><table class=" reserTbl">';
				resourceListHTML += '<tbody>';

			$(folderList).each(function(x, folder){
				var bookingList = this.bookingList;
				
		        var pStrBookingType = folder.BookingType;
				var tempFolderPathName = folder.FolderPathName;
				if (tempFolderPathName[0] == ';') tempFolderPathName = tempFolderPathName.substring(1);
				if (tempFolderPathName[tempFolderPathName.length - 1] == ';') tempFolderPathName = tempFolderPathName.left(tempFolderPathName.length - 1);
				var folderPathArry = tempFolderPathName.split(';');
				folderPathArry.shift();
				var folderPath = folderPathArry.reverse().join(' < ');
				
				folderListHTML += '<p id="header_'+folder.FolderID+'" title="'+folderPathArry.reverse().join(' > ') + ' > ' + folder.DisplayName+'">';
				
				folderListHTML += '<span class="resource_location">'+folderPath+'</span>';
				
				folderListHTML += '<span class="resource_name">';
				if(CFN_GetQueryString("isPopupView") == "Y" && CFN_GetQueryString("onlyView") != "Y"){
					// 일정관리에서 자원예약현황으로 팝업이 열렸을 때 checkbox 세팅
					folderListHTML += '<input type="checkbox" id="chkResource_'+folder.FolderID+'_D" value="'+folder.FolderID+'" label="'+folder.MultiDisplayName+'" name="chkResourceFolder" data-least-rental-time="'+folder.LeastRentalTime+'"' + (pStrBookingType == "ApprovalProhibit" ? "disabled" : "") + '>';
				}
				folderListHTML += folder.DisplayName;
				folderListHTML += '</span>';
				
				//예약불가 표시
				if(pStrBookingType == "ApprovalProhibit") {
					folderListHTML += '<span class="resource_state">'+Common.getDic('BookingType_ApprovalProhibit')+'</span>';
				}
				
				folderListHTML += '</p>';
				
				resourceListHTML += '<tr resourceID="'+folder.FolderID+'" folderName="'+folder.DisplayName+'">';
				
				// 데이터 색칠하기
				for(var i = timeStart*2; i<(timeEnd)*2; i++){
					var tempDate = new Date(new Date(replaceDate(g_startDate)).getTime() + (i*30*60000));
			    	var hour = AddFrontZero(tempDate.getHours(), 2);
			    	var min = AddFrontZero(tempDate.getMinutes(), 2);
			    	var time = hour + ":"+min;
					
			        var sDefaultDate = g_startDate;   				// Cell의 날짜
			        var nTargetStart = 0;       // Cell의 시작 값(분)
			        var nTargetEnd = 0;         // Cell의 종료 값(분)
			        var nTimeStep = 30;         // 1개 Cell별 기본 값(분)

			        var sDateIDs_All = "";   // 전체 Cell의 예약 ID(;으로 구분)
			        var sDateIDs_My = "";    // 나의 Cell의 예약 ID(;으로 구분)
			        var sPossible_All = "";  // 전체 Cell의 상태(F=예약불가/H=부분예약가능/N=예약가능)
			        var sPossible_My = "";   // 나의 Cell의 상태(Y=예약가능/N=예약가능)
			        var isDecide_All = false;  // 전체 Cell의 상태 결정 여부
			        var isNextSame = false;    // 나의 Cell의 상태 결정 여부

			        var nStart = 0;             // 예약별 시작 값(분)
			        var nEnd = 0;               // 예약별 종료 값(분)
			        
			        var sEventIDs_All = "";
					var sRepeatIDs_All = "";
					var sIsRepeats_All = "";
					
		            sPossible_All = "N";
		            sPossible_My = "N";
		            isDecide_All = false;
		            isNextSame = false;

		            nTargetStart = i * nTimeStep;
		            nTargetEnd = (i + 1) * nTimeStep;
		            
		            var bookingListLen = bookingList.length;
		            
		            $(bookingList).each(function(j, item){
		            	if (!isNextSame)
		                {
		                    nStart = 0;
		                    if (sDefaultDate == this.StartDate.replaceAll("-", ".")){
		                        nStart = (new Date(replaceDate(this.StartDateTime)).getHours() * 60) + (new Date(replaceDate(this.StartDateTime)).getMinutes());
		                    }
		                    if (sDefaultDate == this.EndDate.replaceAll("-", ".")){
		                        nEnd = (new Date(replaceDate(this.EndDateTime)).getHours() * 60) + (new Date(replaceDate(this.EndDateTime)).getMinutes());
		                    }else{
		                        nEnd = 1440;			//TODO
		                    }
		                }

		            	// 조회 영역 밖
		                if (!(nEnd <= nTargetStart) && !(nTargetEnd <= nStart)){
		                	sEventIDs_All += this.EventID + ";";
		                	sDateIDs_All += this.DateID + ";";
		                	sRepeatIDs_All += this.RepeatID + ";";
		                	sIsRepeats_All += this.IsRepeat + ";";
		                	
		                    if (this.RegisterCode == userCode)
		                        sPossible_My = "Y";
		                    
		                    if (!isDecide_All){
		                    	var nTemp, $this;
		                    	
		                    	if (nStart <= nTargetStart){
		                            // 진행중
		                            if (nTargetEnd <= nEnd){
		                                // 아직 끝나지 않음
		                                sPossible_All = "F";
		                                isDecide_All = true;
		                                isNextSame = false;
		                            }
		                            else{
		                                // 중간에 끝나서 다음 예약 확인
		                                nTemp = j + 1;
		                                do{
		                                    if (nTemp < bookingListLen){
		                                    	$this = bookingList[nTemp];
		                                        if (((new Date(replaceDate($this.StartDateTime)).getHours() * 60) + (new Date(replaceDate($this.StartDateTime)).getMinutes()) <= nEnd) &&
		                                            (nEnd <= (new Date(replaceDate($this.EndDateTime)).getHours() * 60) + (new Date(replaceDate($this.EndDateTime)).getMinutes())))
		                                        {
		                                            isNextSame = true;
		                                            if (sDefaultDate == $this.EndDate.replaceAll("-", "."))
		                                            {
		                                                nEnd = (new Date(replaceDate($this.EndDateTime)).getHours() * 60) + (new Date(replaceDate($this.EndDateTime)).getMinutes());
		                                            }
		                                            else
		                                            {
		                                                nEnd = 1440;
		                                            }
		                                            nTemp++;
		                                            $this = bookingList[nTemp];
		                                        }
		                                        else{
		                                            sPossible_All = "H";
		                                            isDecide_All = true;
		                                            isNextSame = false;
		                                            break;
		                                        }
		                                    }
		                                    else{
		                                        sPossible_All = "H";
		                                        isDecide_All = true;
		                                        isNextSame = false;
		                                        break;
		                                    }
		                                }while (	nTemp < bookingListLen &&
		                                			((new Date(replaceDate($this.StartDateTime)).getHours() * 60) + (new Date(replaceDate($this.StartDateTime)).getMinutes()) <= nEnd) &&
		                                        	(nEnd < (new Date(replaceDate($this.EndDateTime)).getHours() * 60) + (new Date(replaceDate($this.EndDateTime)).getMinutes()))	);
		                            }
		                        }
		                        else if (nTargetStart < nStart){
		                            // 중간에 시작
		                            if (nTargetEnd <= nEnd){
		                                // 아직 끝나지 않음
		                                sPossible_All = "H";
		                                isDecide_All = true;
		                                isNextSame = false;
		                            }
		                            else{
		                                // 중간에 끝나서 다음 예약 확인
		                                nTemp = j + 1;
		                                do{
		                                    if (nTemp < bookingListLen){
		                                    	$this = bookingList[nTemp];
		                                        if (((new Date(replaceDate($this.StartDateTime)).getHours() * 60) + (new Date(replaceDate($this.StartDateTime)).getMinutes()) <= nEnd) &&
		                                            (nEnd <= (new Date(replaceDate($this.EndDateTime)).getHours() * 60) + (new Date(replaceDate($this.EndDateTime)).getMinutes())))
		                                        {
		                                            isNextSame = true;
		                                            if (sDefaultDate == $this.EndDate.replaceAll("-", ".")){
		                                                nEnd = (new Date(replaceDate($this.EndDateTime)).getHours() * 60) + (new Date(replaceDate($this.EndDateTime)).getMinutes());
		                                            }
		                                            else{
		                                                nEnd = 1440;
		                                            }
		                                            nTemp++;
		                                            $this = bookingList[nTemp];
		                                        }
		                                        else{
		                                            sPossible_All = "H";
		                                            isDecide_All = true;
		                                            isNextSame = false;
		                                            break;
		                                        }
		                                    }
		                                    else{
		                                        sPossible_All = "H";
		                                        isDecide_All = true;
		                                        isNextSame = false;
		                                        break;
		                                    }
		                                }while (	nTemp < bookingListLen &&
		                                			((new Date(replaceDate($this.StartDateTime)).getHours() * 60) + (new Date(replaceDate($this.StartDateTime)).getMinutes()) <= nEnd) &&
		                                        	(nEnd < (new Date(replaceDate($this.EndDateTime)).getHours() * 60) + (new Date(replaceDate($this.EndDateTime)).getMinutes()))	);
		                            }
		                        }
		                    	
		                    	// 최소 부분예약 가능 체크
		                    /*	if(sPossible_All == "H"){
		                    		var diffTargetStart = Math.abs(nTargetStart - nStart);
		                    		var diffTargetEnd = Math.abs(nTargetEnd - nEnd);
		                        	var partRentalTime = folder.LeastPartRentalTime;
		                        	
		                        	if(diffTargetStart <= partRentalTime || diffTargetEnd <= partRentalTime)
		                        		sPossible_All = "F";
		                    	}*/
		                    }
		                }
		            });

		            var className = "selectedComp";
		        	
		        	//나의 예약
		        	if(sPossible_My == "Y")
		        		className = "selectedMy";

		            // 예약불가
		            if (sPossible_All == "F"){
						// 매칭되는 eventID를 찾아서 해당 bookingList.folderid를 추가로 입력.
						if (bookingListLen>0) {
							var bookingIdx = 0;
							var booleanBooking = false;
							var eventArr = sEventIDs_All.split(";");
							for (var bookingIdx; bookingIdx<bookingListLen;bookingIdx++) {
								if ((bookingList[bookingIdx].EventID) === eventArr[0]) {
									booleanBooking = true;
									break;
								}
							}
							if (booleanBooking) {
								resourceListHTML += '<td type="color" time="'+time+ '"folderid="'+ bookingList[bookingIdx].FolderID + '" resourceid="'+ bookingList[bookingIdx].ResourceID + '" integratedid="'+ bookingList[bookingIdx].IntegratedID +'" eventid="'+sEventIDs_All+'" dateid="'+sDateIDs_All+'" repeatid="'+sRepeatIDs_All+'" isrepeat="'+sIsRepeats_All+'" ><div class="'+className+'"></div></td>';
							} else {
								resourceListHTML += '<td type="color" time="'+time+ '" resourceid="' + bookingList[bookingIdx].ResourceID + '" integratedid="' + bookingList[bookingIdx].IntegratedID + '" eventid="'+sEventIDs_All+'" dateid="'+sDateIDs_All+'" repeatid="'+sRepeatIDs_All+'" isrepeat="'+sIsRepeats_All+'" ><div class="'+className+'"></div></td>';
							}
						} else {
		            		resourceListHTML += '<td type="color" time="'+time+ '" resourceid="' + bookingList[bookingIdx].ResourceID + '" integratedid="' + bookingList[bookingIdx].IntegratedID + '" eventid="'+sEventIDs_All+'" dateid="'+sDateIDs_All+'" repeatid="'+sRepeatIDs_All+'" isrepeat="'+sIsRepeats_All+'" ><div class="'+className+'"></div></td>';
						}
		            }
		            // 예약가능
		            else if (sPossible_All == "H"){
		            	//예약 불가 상태의 자원일 경우
		                if (pStrBookingType == "ApprovalProhibit"){
		                	resourceListHTML += '<td type="color" style="background:#f4f4f4;" eventid="'+sEventIDs_All+'" dateid="'+sDateIDs_All+'" repeatid="'+sRepeatIDs_All+'" isrepeat="'+sIsRepeats_All+'"><div class="'+className+' half"></div></td>';
		                }else{
		                	//resourceListHTML += '<td type="color" time="'+time+'" eventid="'+sEventIDs_All+'" dateid="'+sDateIDs_All+'" repeatid="'+sRepeatIDs_All+'" isrepeat="'+sIsRepeats_All+'"><div class="'+className+' half"></div></td>';
		                	if (bookingListLen > 0) {
								var bookingIdx = 0;
								var booleanBooking = false;
								for (bookingIdx; bookingIdx<bookingListLen;bookingIdx++) {
									if ((bookingList[bookingIdx].EventID+";") === sEventIDs_All) {
										booleanBooking = true;
										break;
									}
								}
								if (booleanBooking) {
									resourceListHTML += '<td type="color" time="'+time+ '" resourceid="' + bookingList[bookingIdx].ResourceID + '" integratedid="' + bookingList[bookingIdx].IntegratedID + '" eventid="'+sEventIDs_All+'" dateid="'+sDateIDs_All+'" repeatid="'+sRepeatIDs_All+'" isrepeat="'+sIsRepeats_All+'"><div class="'+className+' half_book"></div></td>';								
								}
							} else {
		                		resourceListHTML += '<td type="color" time="'+time+'" eventid="'+sEventIDs_All+'" dateid="'+sDateIDs_All+'" repeatid="'+sRepeatIDs_All+'" isrepeat="'+sIsRepeats_All+'"><div class="'+className+' half_book"></div></td>';
		                	}
		                }		                	
		            }
		            else{
		            	//예약 불가 상태의 자원일 경우
		                if (pStrBookingType == "ApprovalProhibit"){
		                	resourceListHTML += '<td type="none" book="' + pStrBookingType + '" style="background:#f4f4f4; cursor:default;"><div></div></td>';
		                }else{
		                	resourceListHTML += '<td type="none" time="'+time+'"><div></div></td>';
		                }	
		            }
				}
				
				resourceListHTML += '</tr>';
			});
			folderListHTML += '</div>';
			
			resourceListHTML += '</tbody></table></div>';
			
			$("#bodyResourceDay").html(folderListHTML + resourceListHTML);

			//Selectable jquery ui event 바인딩
			if(CFN_GetQueryString("isPopupView") != 'Y')			// TODO 팝업으로 자원을 띄었을 때 간단 등록이나 조회 창을 열면 퍼블리싱 등이 많이 깨짐. 추후 보완 필요
				resourceUser.setSelectableEvent();
			else{
				// 일정관리 자원현황 팝업에서 열렸을 때 이미 체크했던 항목 체크하기
				var oldResource = parent.coviCtrl.getAutoTags("Resource");
				$(oldResource).each(function(){
					$("#chkResource_"+this.value+"_D").prop("checked", "checked");
				});
				
				// 일간 헤더 스크롤 영역
				if($("#bodyResourceDay").get(0).scrollHeight > $("#bodyResourceDay").height()){
					var thObjD = $("<th></th>");
					$(thObjD).attr("colspan", "2");
					$(thObjD).css("width", "17px");
					$(thObjD).css("min-width", "17px");
					$("#headerTimeList").find("tr").append(thObjD);
				}
				
				$.each($("#DayCalendar .reserTblView .reserTbl td[type!=none]"), function(idx, el) {
					$(el).attr("onclick", "javascript: scheduleUser.resource_SimpleViewPopup(this);");
				});
				
				
			}
		},
		// 주간 그리기
		resource_MakeWeekCalendar : function(){
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
		    
		    var todatyDate = g_currentTime.getDate();
		    
		    
		    var headerDateHTML = "<tr>";
			headerDateHTML += '<th colspan="2" '+(todatyDate == sun.getDate() ? 'class="selected"' : '')+'>'+sun.getDate()+'&nbsp;'+coviDic.dicMap["lbl_WPSun"]+'<span name="dayInfo" value="' +schedule_SetDateFormat(sun, '-')+ '" class="inDate"></span></th>';
			headerDateHTML += '<th colspan="2" '+(todatyDate == mon.getDate() ? 'class="selected"' : '')+'>'+mon.getDate()+'&nbsp;'+coviDic.dicMap["lbl_WPMon"]+'<span name="dayInfo" value="' +schedule_SetDateFormat(mon, '-')+ '" class="inDate"></span></th>';
			headerDateHTML += '<th colspan="2" '+(todatyDate == tue.getDate() ? 'class="selected"' : '')+'>'+tue.getDate()+'&nbsp;'+coviDic.dicMap["lbl_WPTue"]+'<span name="dayInfo" value="' +schedule_SetDateFormat(tue, '-')+ '" class="inDate"></span></th>';
			headerDateHTML += '<th colspan="2" '+(todatyDate == wed.getDate() ? 'class="selected"' : '')+'>'+wed.getDate()+'&nbsp;'+coviDic.dicMap["lbl_WPWed"]+'<span name="dayInfo" value="' +schedule_SetDateFormat(wed, '-')+ '" class="inDate"></span></th>';
			headerDateHTML += '<th colspan="2" '+(todatyDate == thr.getDate() ? 'class="selected"' : '')+'>'+thr.getDate()+'&nbsp;'+coviDic.dicMap["lbl_WPThu"]+'<span name="dayInfo" value="' +schedule_SetDateFormat(thr, '-')+ '" class="inDate"></span></th>';
			headerDateHTML += '<th colspan="2" '+(todatyDate == fri.getDate() ? 'class="selected"' : '')+'>'+fri.getDate()+'&nbsp;'+coviDic.dicMap["lbl_WPFri"]+'<span name="dayInfo" value="' +schedule_SetDateFormat(fri, '-')+ '" class="inDate"></span></th>';
			headerDateHTML += '<th colspan="2" '+(todatyDate == sat.getDate() ? 'class="selected"' : '')+'>'+sat.getDate()+'&nbsp;'+coviDic.dicMap["lbl_WPSat"]+'<span name="dayInfo" value="' +schedule_SetDateFormat(sat, '-')+ '" class="inDate"></span></th>';
			headerDateHTML += "</tr>";
			
			headerDateHTML += "<tr>";
			for(var i=0; i<7; i++){
				headerDateHTML += '<td>'+coviDic.dicMap["lbl_AM"]+'</td>';		//오전
				headerDateHTML += '<td>'+coviDic.dicMap["lbl_PM"]+'</td>';		//오후
			}
			headerDateHTML += "</tr>";
			
			$("#headerDayList").html(headerDateHTML);
			
			// 데이터 조회해서 그림
			resourceUser.getMonthBookingData(schedule_SetDateFormat(sun, '-'), g_endDate.replaceAll(".", "-"));
		},
		setWeekBookingData : function(data){
			var folderList = data.folderList;

			// 폴더 기준으로 뒷 배경 그리기
			var folderListHTML = '<div>';
			var resourceListHTML = '<div class="reserTblView"><table class=" reserTbl">'
											+'<colgroup>'
											+'<col width="16.6%"/>'
											+'<col width="16.6%"/>'
											+'<col width="16.6%"/>'
											+'<col width="16.6%"/>'
											+'<col width="16.6%"/>'
											+'<col width="16.6%"/>'
											+'<col width="16.6%"/>'
											+'<col width="16.6%"/>'
											+'<col width="16.6%"/>'
											+'<col width="16.6%"/>'
											+'<col width="16.6%"/>'
											+'<col width="16.6%"/>'
											+'<col width="16.6%"/>'
											+'<col width="16.6%"/>'
											+'</colgroup>'
											+'<tbody>';
			
		    var sDefaultDate = "";   // Cell의 날짜
		    var nDisplayLength = 12;     // Cell 개수
		    var nTargetStart = 0;       // Cell의 시작 값(분)
		    var nTargetEnd = 0;         // Cell의 종료 값(분)
		    var nTimeStep = 120;        // 1개 Cell별 기본 값(분)

		    var sDateIDs_All = "";   // 전체 Cell의 예약 ID(;으로 구분)
		    var sDateIDs_My = "";    // 나의 Cell의 예약 ID(;으로 구분)
		    var sPossible_All = "";  // 전체 Cell의 상태(F=예약불가/H=부분예약가능/N=예약가능)
		    var sPossible_My = "";   // 나의 Cell의 상태(Y=예약가능/N=예약가능)
		    var isDecide_All = false;  // 전체 Cell의 상태 결정 여부
		    var isNextSame = false;    // 나의 Cell의 상태 결정 여부
		    
		    var sEventIDs_All;
		    var sRepeatIDs_All;
		    var sIsRepeats_All;
			var sFolderIDs_All;			// 주간에서 보여줄 FolderID 대상들.
			
		    var nStart = 0;             // 예약별 시작 값(분)
		    var nEnd = 0;               // 예약별 종료 값(분)
		    
			$(folderList).each(function(x, folder){
				var bookingList = this.bookingList;
			    var nBookingLength = bookingList.Length;
				var pStrBookingType = folder.BookingType;
				
				var tempFolderPathName = folder.FolderPathName;
				if (tempFolderPathName[0] == ';') tempFolderPathName = tempFolderPathName.substring(1);
				if (tempFolderPathName[tempFolderPathName.length - 1] == ';') tempFolderPathName = tempFolderPathName.left(tempFolderPathName.length - 1);
				var folderPathArry = tempFolderPathName.split(';');
				folderPathArry.shift();
				var folderPath = folderPathArry.reverse().join(' < ');
				
				folderListHTML += '<p id="header_'+folder.FolderID+'" title="'+folderPathArry.reverse().join(' > ') + ' > ' + folder.DisplayName+'">';
				
				folderListHTML += '<span class="resource_location">'+folderPath+'</span>';
				
				folderListHTML += '<span class="resource_name">';
				if(CFN_GetQueryString("isPopupView") == "Y" && CFN_GetQueryString("onlyView") != "Y"){
					// 일정관리에서 자원예약현황으로 팝업이 열렸을 때 checkbox 세팅
					folderListHTML += '<input type="checkbox" id="chkResource_'+folder.FolderID+'_D" value="'+folder.FolderID+'" label="'+folder.MultiDisplayName+'" name="chkResourceFolder" data-least-rental-time="'+folder.LeastRentalTime+'"' + (pStrBookingType == "ApprovalProhibit" ? "disabled" : "") + '>';
				}
				folderListHTML += folder.DisplayName;
				folderListHTML += '</span>';
				
				//예약불가 표시
				if(pStrBookingType == "ApprovalProhibit") {
					folderListHTML += '<span class="resource_state">'+Common.getDic('BookingType_ApprovalProhibit')+'</span>';
				}
				
				folderListHTML += '</p>';
				
				resourceListHTML += '<tr resourceID="'+folder.FolderID+'" folderName="'+folder.DisplayName+'">';
				
				var tempStartDate = g_startDate;
				var sun = schedule_GetSunday(new Date(replaceDate(tempStartDate)));
				tempStartDate = schedule_SetDateFormat(sun, '.');
				
				// 데이터 색칠하기
				for(var k = 0; k<7; k++){
					
					sDefaultDate = schedule_SetDateFormat(schedule_AddDays(tempStartDate, k), '/');
					
			        for (var i = 0; i < nDisplayLength; i++)
			        {
			        	sEventIDs_All = "";
			            sRepeatIDs_All = "";
			            sDateIDs_All = "";
			            sIsRepeats_All = "";
			            sFolderIDs_All = "";

			            sPossible_All = "N";
			            sPossible_My = "N";
			            isDecide_All = false;
			            isNextSame = false;

			            nTargetStart = i * nTimeStep;
			            nTargetEnd = (i + 1) * nTimeStep;
			            
			            $(bookingList).each(function(j, item){
			                if (!(new Date(replaceDate(this.EndDateTime)) <= schedule_AddDays(tempStartDate, k)) &&
			                    !(schedule_AddDays(tempStartDate, k+1) <= new Date(replaceDate(this.StartDateTime))))
			                {
			                	if (!isNextSame){
				                    nStart = 0;
				                    if (sDefaultDate == this.StartDate.replaceAll("-", "/")){
				                        nStart = (new Date(replaceDate(this.StartDateTime)).getHours() * 60) + (new Date(replaceDate(this.StartDateTime)).getMinutes());
				                    }
				                    if (sDefaultDate == this.EndDate.replaceAll("-", "/")){
				                        nEnd = (new Date(replaceDate(this.EndDateTime)).getHours() * 60) + (new Date(replaceDate(this.EndDateTime)).getMinutes());
				                    }
				                    else{
				                        nEnd = 1440;
				                    }
				                }
								
				                if (!(nEnd <= nTargetStart) && !(nTargetEnd <= nStart)){
									
	
				                	sDateIDs_All += this.DateID + ";";
				                	sEventIDs_All += this.EventID + ";";
				                	sRepeatIDs_All += this.RepeatID + ";";
				                	sIsRepeats_All += this.IsRepeat + ";";
				                	sFolderIDs_All = this.FolderID;

					                if (this.RegisterCode == userCode)
					                	sPossible_My = "Y";
				                	
					                if (!isDecide_All){
					                	var nTemp, $this;
					                	if (nStart <= nTargetStart){
						                    // 진행중
						                    if (nTargetEnd <= nEnd){
						                        // 아직 끝나지 않음
						                        sPossible_All = "F";
						                        isDecide_All = true;
						                        isNextSame = false;
						                    }
						                    else{
						                        // 중간에 끝나서 다음 예약 확인
						                        nTemp = j + 1;
						                        do{
						                            if (nTemp < nBookingLength){
						                            	$this = bookingList[nTemp];
						                                if ((new Date(replaceDate($this.EndDateTime)) <= schedule_AddDays(tempStartDate, k)) ||
						                                    (schedule_AddDays(tempStartDate, k+1) <= new Date(replaceDate($this.StartDateTime))))
						                                {
						                                    sPossible_All = "H";
						                                    isDecide_All = true;
						                                    isNextSame = false;
						                                    break;
						                                }
						                                else{
						                                    if (((new Date(replaceDate($this.StartDateTime)).getHours() * 60) + (new Date(replaceDate($this.StartDateTime)).getMinutes()) <= nEnd) &&
						                                        (nEnd <= (new Date(replaceDate($this.EndDateTime)).getHours() * 60) + (new Date(replaceDate($this.EndDateTime)).getMinutes())))
						                                    {
						                                        isNextSame = true;
						                                        if (sDefaultDate == $this.EndDate.replaceAll(".", "/")){
						                                            nEnd = (new Date(replaceDate($this.EndDateTime)).getHours() * 60) + (new Date(replaceDate($this.EndDateTime)).getMinutes());
						                                        }
						                                        else{
						                                            nEnd = 1440;
						                                        }
						                                        nTemp++;
						                                        $this = bookingList[nTemp];
						                                    }
						                                    else{
						                                        sPossible_All = "H";
						                                        isDecide_All = true;
						                                        isNextSame = false;
						                                        break;
						                                    }
						                                }
						                            }
						                            else{
						                                sPossible_All = "H";
						                                isDecide_All = true;
						                                isNextSame = false;
						                                break;
						                            }
						                        }while (	nTemp < bookingListLen &&
						                        			((new Date(replaceDate($this.StartDateTime)).getHours() * 60) + (new Date(replaceDate($this.StartDateTime)).getMinutes()) <= nEnd) &&
						                                	(nEnd <= (new Date(replaceDate($this.EndDateTime)).getHours() * 60) + (new Date(replaceDate($this.EndDateTime)).getMinutes()))	);
						                    }
						                }
						                else if (nTargetStart < nStart){
						                    // 중간에 시작
						                    if (nTargetEnd <= nEnd){
						                        // 아직 끝나지 않음
						                        sPossible_All = "H";
						                        isDecide_All = true;
						                        isNextSame = false;
						                    }
						                    else{
						                        // 중간에 끝나서 다음 예약 확인
						                        nTemp = j + 1;
						                        do{
						                            if (nTemp < nBookingLength){
						                            	$this = bookingList[nTemp];
						                                if ((new Date(replaceDate($this.EndDateTime)) <= schedule_AddDays(tempStartDate, k)) ||
						                                    (schedule_AddDays(tempStartDate, k+1) <= new Date(replaceDate($this.StartDateTime))))
						                                {
						                                    sPossible_All = "H";
						                                    isDecide_All = true;
						                                    isNextSame = false;
						                                    break;
						                                }
						                                else{
						                                    if (((new Date(replaceDate($this.StartDateTime)).getHours() * 60) + (new Date(replaceDate($this.StartDateTime)).getMinutes()) <= nEnd) &&
						                                        (nEnd <= (new Date(replaceDate($this.EndDateTime())).getHours() * 60) + (new Date(replaceDate($this.EndTime)).getMinutes())))
						                                    {
						                                        isNextSame = true;
						                                        if (sDefaultDate == $this.EndDate.replaceAll("-", "/")){
						                                            nEnd = (new Date(replaceDate($this.EndDateTime)).getHours() * 60) + (new Date(replaceDate($this.EndDateTime)).getMinutes());
						                                        }
						                                        else{
						                                            nEnd = 1440;
						                                        }
						                                        nTemp++;
						                                        $this = bookingList[nTemp];
						                                    }
						                                    else{
						                                        sPossible_All = "H";
						                                        isDecide_All = true;
						                                        isNextSame = false;
						                                        break;
						                                    }
						                                }
						                            }
						                            else{
						                                sPossible_All = "H";
						                                isDecide_All = true;
						                                isNextSame = false;
						                                break;
						                            }
						                        }while (	nTemp < bookingListLen &&
						                        			((new Date(replaceDate($this.StartDateTime)).getHours() * 60) + (new Date(replaceDate($this.StartDateTime)).getMinutes()) <= nEnd) &&
						                                	(nEnd < (new Date(replaceDate($this.EndDateTime)).getHours() * 60) + (new Date(replaceDate($this.EndDateTime)).getMinutes()))	);
						                    }
						                }
					                }
				                }
			                }
			            });
			            
			            var sDateHour = AddFrontZero(new Date(new Date(sDefaultDate+" 00:00").getTime() + nTargetStart*60*1000).getHours(), 2);
			            
			            if(nTargetStart == 0 || nTargetStart == 720)
			            	resourceListHTML+= '<td schday="'+sDefaultDate+'">';
			            
			            var className = "selectedComp";
			            
			        	//나의 예약
			        	if(sPossible_My == "Y")
			        		className = "selectedMy";
			            
			            // 예약불가
			            if (sPossible_All == "F"){
			            	resourceListHTML += '<div type="color" folderid="'+ sFolderIDs_All + '" eventid="'+sEventIDs_All+'" dateid="'+sDateIDs_All+'" repeatid="'+sRepeatIDs_All+'" isrepeat="'+sIsRepeats_All+'" class="'+className+'"><span></span></div>';
			            }
			            // 예약가능
			            else if (sPossible_All == "H"){
							
			            	//예약 불가 상태의 자원일 경우
			                if (pStrBookingType == "ApprovalProhibit")
								resourceListHTML +=  '<div type="color" folderid="'+ sFolderIDs_All + '" eventid="'+sEventIDs_All+'" dateid="'+sDateIDs_All+'" repeatid="'+sRepeatIDs_All+'" isrepeat="'+sIsRepeats_All+'" style="background:#f4f4f4;"></div>';
			                else
								resourceListHTML +=  '<div type="color" folderid="'+ sFolderIDs_All + '" eventid="'+sEventIDs_All+'" dateid="'+sDateIDs_All+'" repeatid="'+sRepeatIDs_All+'" isrepeat="'+sIsRepeats_All+'" time="'+sDateHour+':00" class="'+className+' half_book"></div>';
			            }
			            else{
			            	//예약 불가 상태의 자원일 경우
			                if (pStrBookingType == "ApprovalProhibit")
			                	resourceListHTML +=  '<div type="none" book="' + pStrBookingType + '" style="background:#f4f4f4; cursor:default;"><span></span></div>';
			                else
			                	resourceListHTML +=  '<div type="none" time="'+sDateHour+':00"><span></span></div>';
			            }
			            
			            if(nTargetEnd == 720 || nTargetEnd == 1440)
			            	resourceListHTML+= '</td>';
			        }
				}
			});
			folderListHTML += '</div>';
			
			resourceListHTML += '</tbody></table></div>';
			
			$("#bodyResourceWeek").html(folderListHTML + resourceListHTML);
			
			//Selectable jquery ui event 바인딩
			if(CFN_GetQueryString("isPopupView") != 'Y')			// TODO 팝업으로 자원을 띄었을 때 간단 등록이나 조회 창을 열면 퍼블리싱 등이 많이 깨짐. 추후 보완 필요
				resourceUser.setSelectableEvent();
			else{
				// 일정관리 자원현황 팝업에서 열렸을 때 이미 체크했던 항목 체크하기
				var oldResource = parent.coviCtrl.getAutoTags("Resource");
				$(oldResource).each(function(){
					$("#chkResource_"+this.value+"_W").prop("checked", "checked");
				});
				
				// 주간 헤더 스크롤 영역
				if($("#bodyResourceWeek").get(0).scrollHeight > $("#bodyResourceDay").height()){
					var thObjW = $("<th></th>");
					$(thObjW).css("width", "17px");
					$(thObjW).css("min-width", "17px");
					$("#headerDayList").find("tr").eq(0).append(thObjW);
					$("#headerDayList").find("tr").eq(1).append("<td></td>");
				}
				
				$.each($("#WeekCalendar .reserTblView .reserTbl div[type!=none]"), function(idx, el) {
					$(el).attr("onclick", "javascript: scheduleUser.resource_SimpleViewPopup(this);");
				});
			}
		},
		//Selectable jquery ui event 바인딩
		setSelectableEvent : function(){
			if(g_viewType == "D"){
				$(".reserTbl").find("tr").selectable({
					filter:'td', 
					start: function(event, ui) {
						$(this).prevAll().find("[class*=ui-selected]").removeClass("ui-selected");
						$(this).nextAll().find("[class*=ui-selected]").removeClass("ui-selected");
					},
					stop:function(event, ui){
						var selectObj = $(event.target).find("[class*=ui-selected]");
						
						var start = $(selectObj).eq(0);
						
						// 코드 없는 곳에서 드래그 시작시 취소 처리
						if( !$(start).closest("tr").attr("resourceid") ){
							return false;
						}
					
						var posX = $(start).offset().left - $(".cRContBottom").offset().left;
			            var posY = $(start).offset().top - $(".cRContBottom").offset().top + pxToNumber($(".reserTblCont tr:first-child td").css("height"));
						
			            var resouceID = $(start).parent().attr("resourceid");
			            
			            if($(start).attr("type") == "none"){
							if($(start).attr("book") == "ApprovalProhibit") {
								$(selectObj).removeClass("ui-selected");
								return;
							}
							var SelectSecurityLevel = $$(resAclArray).find("create").concat().find("[FolderID="+resouceID+"]").attr("SecurityLevel");
							var UserSecurityLevel = Common.getSession("SecurityLevel");
							
			            	if($$(resAclArray).find("create").concat().find("[FolderID="+resouceID+"]").length > 0 && Number(SelectSecurityLevel) >= Number(UserSecurityLevel)){		// 작성 권한 체크
								var end = $(selectObj).eq($(selectObj).length-1);
								
								$("#popup").load("/groupware/resource/getSimpleWriteView.do", function(){
									if ($("article[id=read_popup]").html() != '') $("article[id=read_popup]").html('');
									
									// coviFile.fileInfos 초기화
									coviFile.files.length = 0;
									coviFile.fileInfos.length = 0;
									
					            	 // Top과 Left 세팅
					            	if(posX > ($(".cRContBottom").width() - ($("#simpleWritePop").width() + 20))){
						            	posX = $(".cRContBottom").width() - ($("#simpleWritePop").width() + 20);
						            }
						            if(posY > ($(".cRContBottom").height() - ($("#simpleWritePop").height() + 2))){
						            	posY = posY - pxToNumber($(".reserTblCont tr:first-child td").css("height")) - $("#simpleWritePop").height() - 5;
						            }
									
					            	$("#popup").find("aside").css("left", posX+"px") ;
					            	$("#popup").find("aside").css("top", posY+"px");
					            	
					            	//일시 세팅 후 disable
					            	resourceUser.setFolderType(resouceID, $(start).parent().attr("foldername"));
					            	
					            	var endTime = "";
					            	
					            	if($(selectObj).length==1){
					            		endTime = new Date(new Date(replaceDate(g_startDate) + " "+ $(start).attr("time")).getTime() + (30*60000));
					            		endTime = AddFrontZero(endTime.getHours(),2) + ":" + AddFrontZero(endTime.getMinutes(), 2);
					            	}else if($(end).next().attr("time") == undefined){
					            		if(g_isWorkTime){
					            			if(coviCmn.configMap["WorkEndTime"] != ""){
					        			    	var timeEnd = Number(coviCmn.configMap["WorkEndTime"]);
					        			    	endTime = timeEnd+":00";
					        			    }else{
						            			endTime = "23:59";
						            		}
				            			}else{
				            				endTime = "23:59";
					            		}
					            	}else{
					            		endTime = $(end).next().attr("time");
					            	}
					            	
					            	var _endDateStr = g_startDate;
									if (endTime == '00:00'){
										var _endDate = new Date(_endDateStr);
										_endDate.setDate(_endDate.getDate() + 1);
										_endDateStr = schedule_SetDateFormat(_endDate, '.');
									}
									
									resourceUser.setStartEndDateTime('S', g_startDate, _endDateStr, $(start).attr("time"), endTime);
					            });
			            	}else{
			            		Common.Warning(Common.getDic("msg_WriteAuth"));		//작성 권한이 없습니다.
			            	}
			            }else{
			            	var SelectSecurityLevel = $$(resAclArray).find("create").concat().find("[FolderID="+resouceID+"]").attr("SecurityLevel");
							var UserSecurityLevel = Common.getSession("SecurityLevel");
							
			            	if($$(resAclArray).find("read").concat().find("[FolderID="+resouceID+"]").length > 0 && Number(SelectSecurityLevel) >= Number(UserSecurityLevel)){		// 읽기 권한 체크
			            		var eventID = $(start).attr("eventid");
				    			var dateID = $(start).attr("dateid");
				    			var repeatID = $(start).attr("repeatid");
				    			var isRepeat = $(start).attr("isrepeat");
				    			
			    				if(eventID.split(";").length <= 2){
				    				eventID = eventID.split(";")[0];
				    				dateID = dateID.split(";")[0];
				    				repeatID = repeatID.split(";")[0];
				    				isRepeat = isRepeat.split(";")[0];
				    				
				    				// 공유자원을 자신의 도메인 자원으로 연결시켜 일정을 보여줌.
      								// $(start).attr(folderid)는 일정에 등록된 자원ID이고, resouceID는 header 자원명의 resourceID임.
      								// 두 값이 같으면 자신의 도메인 자원이고, 다르면 타 도메인의 공유자원으로, 조회할 자원ID로 변경. 
      								if (resouceID != $(start).attr("folderid")) {
                  						resouceID = $(start).attr("folderid");
      								}
      								
				    				resourceUser.setSimpleViewPopupDW(eventID, dateID, repeatID, isRepeat, resouceID, start);
				    			}else{
				    				// 여러개 이벤트 한번에 보여주기
				    				resourceUser.setMoreListPopup(start);
				    			}
			            	}else{
			            		Common.Warning(Common.getDic("msg_noViewACL"));		//읽기 권한이 없습니다.
			            	}
			            }
					}
				});
				
			}else if(g_viewType == "W"){
				$(".reserTbl").find("tr").selectable({
					filter:'div',
					start: function(event, ui) {
						$(this).prevAll().find("[class*=ui-selected]").removeClass("ui-selected");
						$(this).nextAll().find("[class*=ui-selected]").removeClass("ui-selected");
					},
					stop:function(event, ui){
						var selectObj = $(event.target).find("[class*=ui-selected]");
						var start = $(selectObj).eq(0);
						
						// 코드 없는 곳에서 드래그 시작시 취소 처리
						if( !$(start).closest("tr").attr("resourceid") ){
							return false;
						}
					
						var posX = $(start).offset().left - $(".cRContBottom").offset().left;
			            var posY = $(start).offset().top - $(".cRContBottom").offset().top + pxToNumber($(".reserTblWeekly .reserTbl div").css("height"));
			            
			            var resouceID = $(start).parent().parent().attr("resourceID");
			            
						// 등록
						if($(start).attr("type") == "none"){
							if($(start).attr("book") == "ApprovalProhibit") {
								$(selectObj).removeClass("ui-selected");
								return;
							}
							var SelectSecurityLevel = $$(resAclArray).find("create").concat().find("[FolderID="+resouceID+"]").attr("SecurityLevel");
							var UserSecurityLevel = Common.getSession("SecurityLevel");
							
							if($$(resAclArray).find("create").concat().find("[FolderID="+resouceID+"]").length > 0 && Number(SelectSecurityLevel) >= Number(UserSecurityLevel)){		// 작성 권한 체크
								var end = $(selectObj).eq($(selectObj).length-1);
								
								$("#popup").load("/groupware/resource/getSimpleWriteView.do", function(){
									if ($("article[id=read_popup]").html() != '') $("article[id=read_popup]").html('');
									
									// coviFile.fileInfos 초기화
									coviFile.files.length = 0;
									coviFile.fileInfos.length = 0;
									
					            	 // Top과 Left 세팅
					            	if(posX > ($(".cRContBottom").width() - ($("#simpleWritePop").width() + 20))){
						            	posX = $(".cRContBottom").width() - ($("#simpleWritePop").width() + 20);
						            }
						            if(posY > ($(".cRContBottom").height() - ($("#simpleWritePop").height() + 2))){
						            	posY = posY - pxToNumber($(".reserTblWeekly .reserTbl div").css("height")) - $("#simpleWritePop").height() - 5;
						            }
									
					            	$("#popup").find("aside").css("left", posX+"px") ;
					            	$("#popup").find("aside").css("top", posY+"px");
					            	
					            	//일시 세팅 후 disable
					            	resourceUser.setFolderType(resouceID, $(start).parent().parent().attr("foldername"));
					            	resourceUser.setStartEndDateTime('S', schedule_SetDateFormat($(start).parent().attr("schday"),"."), schedule_SetDateFormat($(end).parent().attr("schday"),"."), $(start).attr("time"),  ($(end).attr("time") == "10:00") ? "12:00" :(($(end).next().attr("time") == undefined) ? "23:59" : $(end).next().attr("time")));
					            });
							}else{
			            		Common.Warning(Common.getDic("msg_WriteAuth"));		//작성 권한이 없습니다.
			            	}
						}
						// 조회
						else{
							var SelectSecurityLevel = $$(resAclArray).find("create").concat().find("[FolderID="+resouceID+"]").attr("SecurityLevel");
							var UserSecurityLevel = Common.getSession("SecurityLevel");
							
							if($$(resAclArray).find("read").concat().find("[FolderID="+resouceID+"]").length > 0 && Number(SelectSecurityLevel) >= Number(UserSecurityLevel)){		// 읽기 권한 체크
							
							
								var eventID = $(start).attr("eventid");
				    			var dateID = $(start).attr("dateid");
				    			var repeatID = $(start).attr("repeatid");
				    			var isRepeat = $(start).attr("isrepeat");
				    			
				    			if(eventID.split(";").length <= 2){
				    				eventID = eventID.split(";")[0];
				    				dateID = dateID.split(";")[0];
				    				repeatID = repeatID.split(";")[0];
				    				isRepeat = isRepeat.split(";")[0];
				    				
				    				// 공유자원을 자신의 도메인 자원으로 연결시켜 일정을 보여줌.
				    				// $(start).attr(folderid)는 일정에 등록된 자원ID이고, resouceID는 header 자원명의 resourceID임.
				    				// 두 값이 같으면 자신의 도메인 자원이고, 다르면 타 도메인의 공유자원으로, 조회할 자원ID로 변경. 
				    				if (resouceID != $(start).attr("folderid")) {
										resouceID = $(start).attr("folderid");
									}
									
				    				resourceUser.setSimpleViewPopupDW(eventID, dateID, repeatID, isRepeat, resouceID, start);
				    			}else{
				    				// 여러개 이벤트 한번에 보여주기
				    				resourceUser.setMoreListPopup(start);
				    			}
							}else{
			            		Common.Warning(Common.getDic("msg_noViewACL"));		//읽기 권한이 없습니다.
			            	}
						}
					}
				});
				
			}else if(g_viewType == "M"){
				$( ".calMonBody" ).selectable({
					filter:'td',
			        selecting: function( event, ui ) {
			        },
			        stop: function( event, ui ) {
			        	var selectObj=$(this).find(".ui-selected[id=monthDate]");
			            
			            if(selectObj.length == 0)
			            	selectObj = $(this).find(".ui-selected");
			            
			            if(selectObj.length > 0){
			            	var sDate = $(selectObj).eq(0).attr("schday");
				 	        var eDate = $(selectObj).eq($(selectObj).length-1).attr("schday");
				            
							var diffDate = schedule_GetDiffDates(new Date(replaceDate(sDate)), new Date(replaceDate(eDate)), 'day');
							
							for(var i = 1; i < diffDate; i++){
								var midDate = schedule_SetDateFormat(schedule_AddDays(sDate, i),".");
								
								$("[id=monthDate][schDay='"+ midDate + "']").addClass("ui-selected");
							}
							
				 	        
				            var posX = event.pageX - $(".cRContBottom").offset().left;
				            var posY = event.pageY - ($(".cRContBottom").offset().top - $(".cRContBottom").scrollTop());
				            
				            $("#popup").load("/groupware/resource/getSimpleWriteView.do", function(){
				            	if ($("article[id=read_popup]").html() != '') $("article[id=read_popup]").html('');
				            	
				            	// coviFile.fileInfos 초기화
								coviFile.files.length = 0;
								coviFile.fileInfos.length = 0;
				            	
				            	 // Top과 Left 세팅
				            	if(posX > ($(".cRContBottom").width() - ($("#simpleWritePop").width() + 52 + 20))){
					            	posX = $(".cRContBottom").width() - ($("#simpleWritePop").width() + 52 + 20);
					            }
				            	
				            	$("#popup").find("aside").css("left", posX+"px") ;
				            	$("#popup").find("aside").css("top", posY+"px");

								if(sDate == undefined){
									sDate = $(selectObj).children(".day_info").attr("value").replaceAll("-",".");
									eDate = sDate;
								}
				            	
				            	//일시 세팅 후 disable
				            	resourceUser.setFolderType();
				            	resourceUser.setStartEndDateTime('S', sDate, eDate);
				            });
			            }
			        }
			    });
			}
		},
		//상세 검색 및 검색했을 경우
		getSearchListData : function(){
			
			var startdate = $("#searchDateCon_StartDate").val();
			var enddate = $("#searchDateCon_EndDate").val();
			
			if(startdate > enddate){
				Common.Warning(Common.getDic("msg_bad_period"));	//시작일이 종료일보다 클 수 없습니다.
				return;
			}
			
			$("#DayCalendar,#WeekCalendar,#MonthCalendar").hide();
			$(".scheduleTop ul.schSelect li[data-role=result]").remove();
			$("#moveBar,.resourceContScrollMiddle,.resourceContScrollBottom").hide();		// 나의 자원예약, 승인/반납 요청 표시
			$(".resourceContScrollTop").css("height", "100%");
			$("#List").show();
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
			
			resourceUser.resource_MakeList();
		},
		// 간단 검색 했을 경우
		searchSubject : function(){
			if($("#simSearchSubject").val() == undefined || $("#simSearchSubject").val() == ""){
				Common.Warning(Common.getDic("msg_EnterSearchword"));			//검색어를 입력해주세요
			}else{
				$("#searchSubject").val($("#simSearchSubject").val());
				
				resourceUser.getSearchListData();
				$("#searchSubject").val("");
			}
		},
		// 나위 자원예약, 승인/반납요청 간단 검색 했을 경우
		searchMyReqSubject : function(type){
			if($("#simSearchSubject_Btm").val() == undefined || $("#simSearchSubject_Btm").val() == ""){
				Common.Warning(Common.getDic("msg_EnterSearchword"));			//검색어를 입력해주세요
			}else{
				$("#searchSubject_Btm").val($("#simSearchSubject_Btm").val());
				
				if(type == "MY")
					document.getElementById("ifmMyBooking").contentWindow.resourceUser.resource_MakeMyList();
				else if(type == "REQ")
					document.getElementById("ifmRequestBooking").contentWindow.resourceUser.resource_MakeRequestList();
				$("#searchSubject_Btm").val("");
			}
		},
		// 검색에서 엔티키 입력했을 경우
		searchSubjectEnter : function(e){
			if (e.keyCode == 13) {
				resourceUser.searchSubject();
			}
		},
		// 검색에서 엔티키 입력했을 경우
		searchMyReqSubjectEnter : function(e){
			if (e.keyCode == 13) {
				resourceUser.searchMyReqSubject($(".tabMenu>li[class=active]").attr("value"));
			}
		},
		// 상세검색에서 엔티키 입력했을 경우
		DetailSearchSubjectEnter : function(e){
			if (e.keyCode == 13) {
				resourceUser.getSearchListData();
			}
		},
		setSearchBtn : function(obj){
			if($(obj).attr("value") == "MY"){
				$('#ifmMyBooking').attr('src', '/groupware/resource/goGridMyBooking.do');
			}else if($(obj).attr("value") == "REQ"){
				$('#ifmRequestBooking').attr('src', '/groupware/resource/goGridRequestBooking.do');
			}
			CFN_SetCookieDay("Resource_SelectedTab_"+Common.getSession('USERID'), $(obj).attr("value"), null); // 쿠키저장
		},
		//그리드 및 목록 보기 세팅
		resource_MakeList : function(){
			// 상단 제목 날짜 표시
			$('#dateTitle').html(g_year + "." + g_month);
			
			//개별호출-일괄호출
			Common.getDicList(["lbl_schedule_start","lbl_schedule_end","lbl_Resources","lbl_Purpose","lbl_Curr_Ststus","lbl_Reserver"]);
			
			var headerData = [{key:'StartDateTime', label:coviDic.dicMap["lbl_schedule_start"], width:'80', align:'center',		//일정 시작 
										formatter:function(){
											var startDate =new Date(replaceDate(CFN_TransLocalTime(this.item.StartDateTime)));
											startDate = schedule_SetDateFormat(startDate, ".")  + " " + AddFrontZero(startDate.getHours(), 2)+":"+AddFrontZero(startDate.getMinutes(), 2);
											
											return '<div class="fcStyle">' + startDate.substring(startDate.indexOf(".")+1, startDate.length) + '</div>';
										}
									},
									{key:'EndDateTime', label:coviDic.dicMap["lbl_schedule_end"], width:'80', align:'center',			//일정 종료 
										formatter:function(){
											var endDate =new Date(replaceDate(CFN_TransLocalTime(this.item.EndDateTime)));
											endDate = schedule_SetDateFormat(endDate, ".") + " " + AddFrontZero(endDate.getHours(), 2)+":"+AddFrontZero(endDate.getMinutes(), 2);
											
											return '<div class="fcStyle">' + endDate.substring(endDate.indexOf(".")+1, endDate.length) + '</div>';
										}
									},{key:'ResourceName', label:coviDic.dicMap["lbl_Resources"], width:'80', align:'center',				//자원
										formatter:function(){
											return '<div class="fcStyle">' + this.item.ResourceName + '</div>';
										}
									},{key:'Subject', label:coviDic.dicMap["lbl_Purpose"], width:'200', align:'center',						//용도	
										formatter:function(){
											return '<a onclick="resourceUser.goDetailViewPage(\'\', \''+this.item.EventID+'\', \''+this.item.DateID+'\', \''+this.item.RepeatID+'\', \''+this.item.IsRepeat+'\', \''+this.item.ResourceID+'\');">'+this.item.Subject+'</a>';
										}
									},{key:'ApprovalStateCode', label:coviDic.dicMap["lbl_Curr_Ststus"], width:'80', align:'center',			//현재 상태
										formatter:function(){
											var className = resourceUser.getApprovalStateIcon(this.item.ApprovalStateCode);
											
											return '<div style="width:50px" class="resTblApp '+className+'">'+this.item.ApprovalState+'</div>';
										}
									},{key:'RegisterName', label:coviDic.dicMap["lbl_Reserver"], width:'50', align:'center', addClass:'bodyTdFile', 	//예약자
										formatter:function(){
											return '<div id="btnFlower" class="btnFlowerName" onclick="coviCtrl.setFlowerName(this)" style="position:relative;cursor:pointer" data-user-code="'+ this.item.RegisterCode +'" data-user-mail="" >' + this.item.RegisterName +'</div>';
										}
									}];					
			
			grid.setGridHeader(headerData);
			
			var configObj = {
					targetID : "ListGrid",
					height:"auto",			
					page:{
						paging:false,
						pageSize:10
					}
			};
			grid.setGridConfig(configObj);
			
			resourceUser.searchResourceData();
		},
		getApprovalStateIcon : function(approvalStateCode){
			var className = "";
			
			switch (approvalStateCode) {
			case "ReturnRequest":
				className = "resTblAppReturnReq";
				break;
			case "AutoCancel":
				className = "resAutoCancel";
				break;
			case "ApprovalDeny":
				className = "resAppCancel";
				break;
			case "ReturnComplete":
				className = "resTblAppReturnComp";
				break;
			case "ApprovalCancel":
				className = "resAppWithdrawal";
				break;
			case "Approval":
				className = "resTblApproval";
				break;
			case "Reject":
				className = "resTblAppRej";
				break;
			case "ApprovalRequest":
				className = "resTblAppReq";
				break;
			default:
				break;
			}
			
			return className;
		},
		//그리드 데이터
		searchResourceData : function(){
			var subject = $("#searchSubject").val();
			var register = $("#serachRegister").val();
			var approvalState = $("#searchApprovalState option:selected").val();
			var dateType = $("#searchDateType option:selected").val();
			var sDate = g_startDate;
			var eDate = g_endDate;
			
			var searchStartDate = $("#searchDateCon_StartDate").val();
			var searchEndDate = $("#searchDateCon_EndDate").val();
			
			if(searchStartDate != "" && searchEndDate != ""){
				sDate = searchStartDate;
				eDate = searchEndDate;
			}

			sDate = (sDate.length == 10) ? sDate.replaceAll(".", "-") + ' 00:00' : sDate.replaceAll(".", "-");
			eDate = (eDate.length == 10) ? schedule_SetDateFormat(schedule_AddDays(eDate.replaceAll(".", "-"), 1),'-') + ' 00:00' : eDate.replaceAll(".", "-");
			
			var params = {
					"mode" : "List",
					"FolderID" : g_folderList,
					"StartDate": CFN_TransServerTime(sDate),
					"EndDate": CFN_TransServerTime(eDate),
					"searchDateType" : dateType,
					"Subject" : subject,
					"RegisterName" : register,
					"ApprovalState" : approvalState,
					"isGetShared" : "Y"
			};
			
			grid.bindGrid({
				ajaxUrl : "/groupware/resource/getBookingList.do",
				ajaxPars : params
			});
		},
		// 나의 자원예약 그리드
		resource_MakeMyList : function(pOption){
			var opt = (typeof pOption != 'object') ? {} : pOption;
			
			Common.getDicList(["btn_Returnrequest", "btn_ApplicationWithdrawn", "lbl_RegistDate"]);
			var headerData = [
				{key:'ApprovalStateCode', label:coviDic.dicMap["lbl_Curr_Ststus"], width:'60', align:'center',				//현재 상태
					formatter: function(){
						var className = resourceUser.getApprovalStateIcon(this.item.ApprovalStateCode);
						
						return '<div style="width:50px" class="resTblApp '+className+'">'+this.item.ApprovalState+'</div>';
					}
				},
				{key:'ResourceName', label:coviDic.dicMap["lbl_Resources"], width:'60', align:'center',							//자원
					formatter: function(){
						return '<div class="fcStyle">' + this.item.ResourceName + '</div>';
					}
				},
				{key:'StartDateTime', label:coviDic.dicMap["lbl_resource_BookingTime"] + Common.getSession('UR_TimeZoneDisplay'), width:'120', align:'center',			//예약 시간 
					formatter:function(){
						var startDate =new Date(replaceDate(CFN_TransLocalTime(this.item.StartDateTime)));
						startDate = schedule_SetDateFormat(startDate, ".")  + " " + AddFrontZero(startDate.getHours(), 2)+":"+AddFrontZero(startDate.getMinutes(), 2);
						var endDate =new Date(replaceDate(CFN_TransLocalTime(this.item.EndDateTime)));
						endDate = schedule_SetDateFormat(endDate, ".") + " " + AddFrontZero(endDate.getHours(), 2)+":"+AddFrontZero(endDate.getMinutes(), 2);
						
						return '<span class="resTblDate">'+startDate+'~'+endDate+'</span>';
					}
				},
				{key:'Subject', label:coviDic.dicMap["lbl_Purpose"], width:'120', align:'center',		//용도
					formatter:function(){
						return '<a onclick="parent.resourceUser.goDetailViewPage(\'\', \''+this.item.EventID+'\', \''+this.item.DateID+'\', \''+this.item.RepeatID+'\', \''+this.item.IsRepeat+'\', \''+this.item.ResourceID+'\');">'+this.item.Subject+'</a>';
					}
				},
				{key:'RegisterName', label:coviDic.dicMap["lbl_Reserver"], width:'50', align:'center', addClass:'bodyTdFile', 	//예약자
					formatter:function(){
						return '<div id="btnFlower" class="btnFlowerName" onclick="coviCtrl.setFlowerName(this)" style="position:relative;cursor:pointer" data-user-code="'+ this.item.RegisterCode +'" data-user-mail="" >' + this.item.RegisterName +'</div>';
					}
				}			
			];
			
			if (opt.mode == 'listOnly') {
				headerData.push({
					key:'RegistDate', label: coviDic.dicMap["lbl_RegistDate"] + Common.getSession("UR_TimeZoneDisplay"), width:'60', align:'center',			//예약 시간 
					formatter: function(){
						return CFN_TransLocalTime(this.item.RegistDate);
					}
				});
			}
			
			headerData.push({
				key:'Buttons', label:' ', width:'50', align:'center', 
				formatter:function(){
					if(this.item.ReturnTypeCode == "ChargeConfirm" && this.item.ApprovalStateCode.toUpperCase() == "APPROVAL" && (g_currentTime >= new Date(replaceDate(this.item.StartDateTime)))){
						return '<a onclick="resourceUser.modifyBookingState(\'ReturnRequest\', ' + this.item.EventID + ', ' + this.item.DateID + ', ' + this.item.ResourceID + ', \'N\');" class="btnTypeDefault">'+coviDic.dicMap["btn_Returnrequest"]+'</a>';			//반납요청
					}else if((this.item.ApprovalStateCode.toUpperCase() == "APPROVAL" && (g_currentTime <= new Date(replaceDate(this.item.StartDateTime))) ) || this.item.ApprovalStateCode.toUpperCase() == "APPROVALREQUEST"){
						return '<a onclick="parent.resourceUser.callDeleteResourceEvent(' + this.item.EventID + ', ' + this.item.DateID + ', ' + this.item.ResourceID + ', \'' + this.item.IsRepeat + '\', \'N\' ,' + this.item.FolderID + ' ,' + this.item.RepeatID + ');" class="btnTypeDefault">'+coviDic.dicMap["btn_ApplicationWithdrawn"]+'</a>';		//신청철회
					}
				}
			});
			
			myGrid.setGridHeader(headerData);
			
			var configObj = {
				targetID : "MyListGrid",
				displayColHead: (opt.header == 'Y'), //설정하지 않을 시 자동으로 true
				height: "auto",
				page: (opt.header == 'Y') ? { paging: false, pageSize: 10 } : false
			};
			
			myGrid.setGridConfig(configObj);
			resourceUser.searchMyBookingData(opt);
		},
		searchMyBookingData : function(pOption){
			var approvalState = "Approval;ApprovalCancel;ApprovalDeny;ApprovalRequest;AutoCancel;Reject;ReturnComplete;ReturnRequest";
			var sDate = '';
			var eDate = '';
			
			if (pOption.mode != 'listOnly'){
				sDate = parent.g_startDate;
				eDate = parent.g_endDate;
			}
			
			if (pOption.search == 'Y'){
				var searchStartDate = parent.$("#searchDateCon_StartDate").val();
				var searchEndDate = parent.$("#searchDateCon_EndDate").val();
				
				if(searchStartDate != "" && searchEndDate != ""){
					sDate = searchStartDate;
					eDate = searchEndDate;
				}
				
				if($("#searchApprovalState option:selected").val() != '') approvalState = $("#searchApprovalState option:selected").val();
			}
			
			var params = {
					"mode" : "List",
					"userID" : userCode,
					"searchDateType" : (parent.$("#searchDateType option:selected").val() != '') ? parent.$("#searchDateType option:selected").val() : 'BookingDate',
					"Subject" : (parent.$("#searchSubject").val() != '') ? parent.$("#searchSubject").val() : '',
					"RegisterName" : (parent.$("#serachRegister").val() != '') ? parent.$("#serachRegister").val() : '',
					"ApprovalState" : approvalState,
					"sortBy" :"RegistDate DESC",
					"isGetShared" : "N"
			};
			
			if (pOption.mode != 'listOnly' || pOption.search == 'Y'){
				if (sDate != '') params.StartDate = CFN_TransServerTime(sDate.replaceAll(".", "-") + ' 00:00');
				if (eDate != '') params.EndDate = CFN_TransServerTime(schedule_SetDateFormat(schedule_AddDays(eDate.replaceAll(".", "-"), 1),'-') + ' 00:00');
			}

			myGrid.bindGrid({
				ajaxUrl : "/groupware/resource/getBookingList.do",
				ajaxPars : params
			});
		},
		// 승인/반납 요청 그리드
		resource_MakeRequestList : function(pOption){
			var opt = (typeof pOption != 'object') ? {} : pOption;
			//개별호출-일괄호출
			Common.getDicList(["lbl_Curr_Ststus","lbl_Resources","lbl_resource_BookingTime","lbl_Purpose","lbl_Reserver","lbl_Approval","lbl_Deny","btn_CheckReturn","btn_CancelApproval","lbl_RegistDate"]);

			var headerData = [
				{key:'ApprovalStateCode', label:coviDic.dicMap["lbl_Curr_Ststus"], width:'60', align:'center',		//현재 상태
					formatter:function(){
						var className = resourceUser.getApprovalStateIcon(this.item.ApprovalStateCode);
						
						return '<div style="width:50px" class="resTblApp '+className+'">'+this.item.ApprovalState+'</div>';
					}
				},
				{key:'ResourceName', label:coviDic.dicMap["lbl_Resources"], width:'60', align:'center',					//자원
					formatter:function(){
						return '<div class="fcStyle">' + this.item.ResourceName + '</div>';
					}
				},
				{key:'StartDateTime', label:coviDic.dicMap["lbl_resource_BookingTime"], width:'120', align:'center',			//예약 시간 
					formatter:function(){
						var startDate =new Date(replaceDate(CFN_TransLocalTime(this.item.StartDateTime)));
						startDate = schedule_SetDateFormat(startDate, ".")  + " " + AddFrontZero(startDate.getHours(), 2)+":"+AddFrontZero(startDate.getMinutes(), 2);
						var endDate =new Date(replaceDate(CFN_TransLocalTime(this.item.EndDateTime)));
						endDate = schedule_SetDateFormat(endDate, ".") + " " + AddFrontZero(endDate.getHours(), 2)+":"+AddFrontZero(endDate.getMinutes(), 2);
						
						return '<span class="resTblDate">'+startDate+'~'+endDate+'</span>';
					}
				},
				{key:'Subject', label:coviDic.dicMap["lbl_Purpose"], width:'120', align:'center',				//용도
					formatter:function(){
						return '<a onclick="parent.resourceUser.goDetailViewPage(\'\', \''+this.item.EventID+'\', \''+this.item.DateID+'\', \''+this.item.RepeatID+'\', \''+this.item.IsRepeat+'\', \''+this.item.ResourceID+'\');">'+this.item.Subject+'</a>';
					}
				},
				{key:'RegisterName', label:coviDic.dicMap["lbl_Reserver"], width:'50', align:'center', addClass:'bodyTdFile',		//예약자
					formatter:function(){
						return '<div id="btnFlower" class="btnFlowerName" onclick="coviCtrl.setFlowerName(this)" style="position:relative;cursor:pointer" data-user-code="'+ this.item.RegisterCode +'" data-user-mail="" >' + this.item.RegisterName +'</div>';
					}
				}			
			];
			
			if (opt.mode == 'listOnly') {
				headerData.push({
					key:'RegistDate', label: coviDic.dicMap["lbl_RegistDate"] + Common.getSession("UR_TimeZoneDisplay"), width:'60', align:'center',			//예약 시간 
					formatter: function(){
						return CFN_TransLocalTime(this.item.RegistDate);
					}
				});
			}
			
			headerData.push({
				key:'Buttons', label:' ', width:'80', align:'center', 
				formatter:function(){
					if(this.item.ApprovalStateCode.toUpperCase() == "APPROVALREQUEST"){
						return '<div class="btnTblBox"><a onclick="parent.resourceUser.modifyBookingState(\'Approval\', ' + this.item.EventID +', '+this.item.DateID +', '+this.item.ResourceID +', \'N\');" class="btnTypeChk btnTypeDefault">'+coviDic.dicMap["lbl_Approval"]
						+'</a><a onclick="resourceUser.modifyBookingState(\'Reject\', ' + this.item.EventID +', '+this.item.DateID +', '+this.item.ResourceID +', \'N\');" class="btnTypeX btnTypeDefault">'+coviDic.dicMap["lbl_Deny"]+'</a></div>';		//승인, 거부
					}
					else if(this.item.ApprovalStateCode.toUpperCase() == "RETURNREQUEST"){
						return '<a onclick="resourceUser.modifyBookingState(\'ReturnComplete\', ' + this.item.EventID +', '+this.item.DateID +', '+this.item.ResourceID +', \'N\');" class="btnTypeDefault">'+coviDic.dicMap["btn_CheckReturn"]+'</a>';			//반납확인
					}
					else if(this.item.ApprovalStateCode.toUpperCase() == "APPROVAL"){
						return '<a onclick="resourceUser.modifyBookingState(\'ApprovalDeny\', ' + this.item.EventID +', '+this.item.DateID +', '+this.item.ResourceID +', \'N\')" class="btnTypeDefault">'+coviDic.dicMap["btn_CancelApproval"]+'</a>';			//승인취소
					}
				}
			});
			
			requestGrid.setGridHeader(headerData);
			
			var configObj = {
				targetID: "RequestListGrid",
				displayColHead: (opt.header == 'Y'), //설정하지 않을 시 자동으로 true
				height: "auto",
				page: (opt.header == 'Y') ? { paging: false, pageSize: 10 } : false
			};
			
			requestGrid.setGridConfig(configObj);
			resourceUser.searchRequestBookingData(opt);
		},
		searchRequestBookingData: function(pOption){
			var approvalState = "Approval;ApprovalCancel;ApprovalDeny;ApprovalRequest;AutoCancel;Reject;ReturnComplete;ReturnRequest";
			var sDate = '';
			var eDate = '';
			
			if (pOption.mode != 'listOnly') {
				sDate = parent.g_startDate;
				eDate = parent.g_endDate;
			}
			
			if (pOption.search == 'Y'){
				var searchStartDate = parent.$("#searchDateCon_StartDate").val();
				var searchEndDate = parent.$("#searchDateCon_EndDate").val();
				
				if(searchStartDate != "" && searchEndDate != ""){
					sDate = searchStartDate;
					eDate = searchEndDate;
				}
				
				if(parent.$("#searchApprovalState option:selected").val() != '') approvalState = parent.$("#searchApprovalState option:selected").val();
			}
			
			var requestFolderList = ";";
			
			$.ajax({
			    url: "/groupware/resource/getManageInfo.do",
			    type: "POST",
			    async: false,
			    data: {},
			    success: function (res) {
			    	if(res.status == "SUCCESS"){
			    		$(res.list).each(function(){
			    			requestFolderList += this.FolderID + ";";
			    		});
			    	} else {
			    		Common.Error(Common.getDic("msg_apv_030"));		// 오류가 발생했습니다.
			    	}
			    },
			    error:function(response, status, error){
			    	CFN_ErrorAjax("/groupware/resource/getManageInfo.do", response, status, error);
			    }
			});
			
			var params = {
					"mode" : "List",
					"searchDateType" : (parent.$("#searchDateType option:selected").val() != '') ? parent.$("#searchDateType option:selected").val() : 'BookingDate',
					"Subject" : (parent.$("#searchSubject").val() != '') ? parent.$("#searchSubject").val() : '',
					"RegisterName" : (parent.$("#serachRegister").val() != '') ? parent.$("#serachRegister").val() : '',
					"ApprovalState" : approvalState,
					"FolderID" : requestFolderList,
					"sortBy" :"RegistDate DESC",
					"isGetShared" : "N"			// 공유 자원의 내용을 보여줄 지 여부. '승인/반납 요청'의 데이터는 공유자원 것을 보여줄 필요 없음.
			};
			
			if (pOption.mode != 'listOnly' || pOption.search == 'Y'){
				if (sDate != '') params.StartDate = CFN_TransServerTime(sDate.replaceAll(".", "-") + ' 00:00');
				if (eDate != '') params.EndDate = CFN_TransServerTime(schedule_SetDateFormat(schedule_AddDays(eDate.replaceAll(".", "-"), 1),'-') + ' 00:00');
			}
			
			requestGrid.bindGrid({
				ajaxUrl : "/groupware/resource/getBookingList.do",
				ajaxPars : params
			});
		},
		//자원 선택 팝업 열기
		openResourceTree : function(setType){
			var selectFolderID = $("#ResourceID").val();
			
			Common.open("","resourceTree_Popup",Common.getDic("lbl_resource_selectRes"),"/groupware/resource/goResourceTree.do?setType="+setType,"345px","420px","iframe",true,null,null,true);			//자원선택
		},
		// 확장필드 설정 조회
		setUserFormOption : function(folderID){
			$.ajax({
			    url: "/groupware/resource/getUserFormOptionData.do",
			    type: "POST",
			    async:false,
			    data: {
			    	"FolderID" : folderID,
			    	"lang" : lang
				},
			    success: function (res) {
			    	if(res.status == "SUCCESS"){
			    		if(res.list.length>0){
			    			var optionHTML = "";
			    			var isSetDate = false;
			    			
			    			$(res.list).each(function(i, userFormObj){
			    				optionHTML += '<div id="'+this.UserFormID+'" class="inputBoxSytel01" >';
			    				
			    				optionHTML += '<div><span>'+this.MultiFieldName+'</span></div>';
			    				optionHTML += '<div type="'+this.FieldType+'" name="content">';
			    				
			    				if(this.IsOption == "Y"){
			    					if(this.FieldType == "DropDown"){
			    						optionHTML += '<select>';
			    					}else{
			    						optionHTML += '<div>';
			    					}
			    					
			    					$(this.OptionList).each(function(j, optionObj){
			    						switch (userFormObj.FieldType) {
										case "Radio":
											optionHTML += '<input type="radio" id="option_radio_'+j+'" name="option_'+this.UserFormID+'" value="'+optionObj.OptionValue+'">&nbsp;'+optionObj.MultiOptionName + '&nbsp;&nbsp;';
											break;
										case "CheckBox":
											optionHTML += '<input type="checkbox" id="option_check_'+this.UserFormID+'_'+j+'" name="option_'+this.UserFormID+'" value="'+optionObj.OptionValue+'">&nbsp;'+optionObj.MultiOptionName + '&nbsp;&nbsp;';
											break;
										case "DropDown":
											optionHTML += '<option id="option_select_'+this.UserFormID+'_'+j+'" name="option_'+this.UserFormID+'" value="'+optionObj.OptionValue+'">'+optionObj.MultiOptionName+'</option>';
											break;
										default:
											break;
										}
			    					});
			    					
			    					if(this.FieldType == "DropDown"){
			    						optionHTML += '</select>';
			    					}else{
			    						optionHTML += '</div>';
			    					}
			    				}else{
			    					switch (this.FieldType) {
									case "Input":
										optionHTML += '<input type="text" id="option_input_'+this.UserFormID+'" name="option_'+this.UserFormID+'" maxlength="'+(this.FieldInputLimit == 0 ? "" : this.FieldInputLimit)+'">';
										break;
									case "TextArea":
										optionHTML += '<textarea id="option_textarea_'+this.UserFormID+'" name="option_'+this.UserFormID+'" maxlength="'+this.FieldInputLimit == 0 ? "" : this.FieldInputLimit+'"></textarea>';
										break;
									case "Date":
										optionHTML += '<input type="text" kind="date" name="option_'+this.UserFormID+'" date_separator="." id="option_textarea_'+this.UserFormID+'"  />';
										isSetDate = true;
										break;
									default:
										break;
									}
			    				}
			    				
			    				optionHTML += '</div>';
			    				
			    				optionHTML += '</div>';
			    			});

		    	    		$("#userFormOption").html(optionHTML);
			    			$("#userFormOption").show();
			    			if(isSetDate)
			    				coviInput.setDate();
			    		}else{
			    			$("#userFormOption").html("");
			    			$("#userFormOption").hide();
			    		}
			    	} else {
			    		Common.Error(Common.getDic("msg_apv_030"));		// 오류가 발생했습니다.
			    	}
			    },
			    error:function(response, status, error){
			    	CFN_ErrorAjax("/groupware/resource/getUserFormOptionData.do", response, status, error);
			    }
			});
		},
		// 간단 등록 - 회의실 세팅
		setFolderType : function(folderID, folderName){
			if(g_viewType == "D" || g_viewType == "W"){
				$("#divFolderID").html('<p class="icLocaction"><span class="tit">'+Common.getDic("lbl_Place")+'</span><span class="txt" id="FolderName"></span></p>');			//장소
				
				$("#simpleWritePop #FolderName").html(folderName);
				$("#simpleWritePop #ResourceID").val(folderID);
			}else{
				$("#divFolderID").html('<input type="text" id="FolderName" readonly="readonly" placeholder="'+Common.getDic("msg_mustSelectRes")+'" style="width: 370px;margin-right: 5px;"><a onclick="resourceUser.openResourceTree(\'S\');" class="btnTypeDefault btnTypeChkLine">'+Common.getDic("lbl_resource_selectRes")+'</a>');	//자원을 선택하세요, 자원선택 
				
				$("#simpleWritePop #ResourceID").val("");
				$("#folderSelectBtn").show();
			}
		},
		// 간단 등록 창 - 달력 세팅
		setStartEndDateTime : function(setType, sDate, eDate, sTime, eTime){
			target = 'simpleResDateCon';
			var timeInfos = {
					width : "80",
					H : "1,2,3,4",
					W : "1,2", //주 선택
					M : "1,2", //달 선택
					Y : "1,2" //년도 선택
				};
			
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
			
			$("#simpleResDateCon_StartDate").val(sDate);
			$("#simpleResDateCon_EndDate").val(eDate);
			
			//$("#simpleResDateCon_StartDate").attr("disabled", true);
			//$("#simpleResDateCon_EndDate").attr("disabled", true);
			//$("#simpleResDateCon_StartDate").next().hide();		// 달력 컨트롤 숨김
			//$("#simpleResDateCon_EndDate").next().hide();		// 달력 컨트롤 숨김

			//$("#simpleResDateCon_StartDate").attr("disabled", true);
			//$("#simpleResDateCon_EndDate").attr("disabled", true);
			
			if(g_viewType == "D" || g_viewType == "W"){
				coviCtrl.setSelected('simpleResDateCon [name=datePicker]', "select");
				
				coviCtrl.setSelected('simpleResDateCon [name=startHour]', sTime.split(":")[0]);
				coviCtrl.setSelected('simpleResDateCon [name=startMinute]', sTime.split(":")[1]);
				
				coviCtrl.setSelected('simpleResDateCon [name=endHour]', eTime.split(":")[0]);
				coviCtrl.setSelected('simpleResDateCon [name=endMinute]', eTime.split(":")[1]);
				
				// StartTime, EndTime Disabled
				//$("#simpleWritePop #simpleResDateCon [name=datePicker] select").attr("disabled", true);
				//$("#simpleWritePop #simpleResDateCon [name=startHour] select").attr("disabled", true);
				//$("#simpleWritePop #simpleResDateCon [name=startMinute] select").attr("disabled", true);
				//$("#simpleWritePop #simpleResDateCon [name=endHour] select").attr("disabled", true);
				//$("#simpleWritePop #simpleResDateCon [name=endMinute] select").attr("disabled", true);
			}
		},
		// 자원 저장
		setOne : function(setType){
			Common.Progress();
			/*
			 * S : 간단 등록
			 * D : 상세 등록
			 * U : 수정
			 * F : 자주 쓰는 일정 
			 */
			var mode = "I";
			var eventObj = {};
			
			// 간단 등록
			if(setType == "S" || setType == "SC"){
				eventObj = resourceUser.setSimpleData(setType);
			}else if(setType == "D" || setType == "U" || setType == "F" || setType == "RU"){
				eventObj = resourceUser.setDetailData(setType);
				if(setType == "U")
					mode = "U";
				else if(setType == "RU")
					mode = "RU";
			}

			// bugfix : 반복일정에서 데이터값을 '분' 단위로 변경되지 않아 발생한 이슈 수정
			if(eventObj.Repeat !== undefined) {
				if(eventObj.Repeat.AppointmentDuring !== undefined && eventObj.Repeat.AppointmentDuring.length >= 2) {
					var duringHour = eventObj.Repeat.AppointmentDuring.substring(0, eventObj.Repeat.AppointmentDuring.length - 1)
					eventObj.Repeat.AppointmentDuring = Number(duringHour) * 60;
				}
			}
			
			var formData = new FormData();
			
			if(setType == "RU"){
				var isChangeDate = eventObj.isChangeDate;
				var isChangeRes = eventObj.isChangeResource;
				
				delete eventObj.isChangeDate;
				delete eventObj.isChangeResource;
				
				formData.append("mode", mode);
				formData.append("eventStr", JSON.stringify(eventObj));
				formData.append("isChangeDate", isChangeDate);
				formData.append("isChangeRes", isChangeRes);
			}
			else{
				formData.append("mode", mode);
				formData.append("eventStr", JSON.stringify(eventObj));
			}
			
			
			formData.append("fileInfos", JSON.stringify(coviFile.fileInfos));
		    for (var i = 0; i < coviFile.files.length; i++) {
		    	if (typeof coviFile.files[i] == 'object') {
		    		formData.append("files", coviFile.files[i]);
		        }
		    }
		    formData.append("fileCnt", coviFile.fileInfos.length);
			
			if(JSON.stringify(eventObj) != "{}"){
				// Validation 체크
				if(resourceUser.checkValidationResource(eventObj)){
					var targetBtnSelector = '';
					var targetBtnEvent = '';
					
					if(setType == "S" || setType == "SC"){
						targetBtnSelector = "#resourceRegistBtn";
					} else if(setType == "D"){
						targetBtnSelector = "#btnAdd";
					}
					targetBtnEvent = $(targetBtnSelector).attr("onclick");
					
					$.ajax({
					    url: "/groupware/resource/saveBookingData.do",
					    type: "POST",
					    //data: params,
					    data: formData,
					    processData : false,
				        contentType : false,
						beforSend : function() {
							$(targetBtnSelector).attr("onclick","");
						},
					    success: function (res) {
					    	if(res.status == "SUCCESS" && res.result == "OK"){
					    		Common.Inform(res.message, "", function(){
					    			if(setType == "S")
					    				resourceUser.refresh();
					    			else if(setType == "SC"){
//					    				resourceUser.refresh();
					    				coviCtrl.toggleSimpleMake();
										$(targetBtnSelector).attr("onclick", "resourceUser.setOne('SC');");
					    				setSimpleMakeBlank($('.tabMenuArrow').find(".active").attr("type"));
					    			}
						    		else{
						    			CoviMenu_GetContent(g_lastURL);
						    		}	
					    		});
					    	}
					    	else if(res.status == "SUCCESS" && res.result == "DUPLICATION"){
					    		Common.Warning(res.message);
								$(targetBtnSelector).attr("onclick", targetBtnEvent);
					    	}
					    	else {
					    		Common.Error(Common.getDic("msg_apv_030"));		// 오류가 발생했습니다.
								$(targetBtnSelector).attr("onclick", targetBtnEvent);
					    	}
					    },
					    error:function(response, status, error){
							$(targetBtnSelector).attr("onclick", targetBtnEvent);
						
					    	CFN_ErrorAjax("/groupware/resource/saveBookingData.do", response, status, error);
					    }
					});
				}
			}
			else{
				Common.Inform(Common.getDic("msg_117"), "", function(){			//성공적으로 저장하였습니다.
					if(setType == "S")
						resourceUser.refresh();
		    		else
		    			CoviMenu_GetContent(g_lastURL);
				});
			}
		},
		// 간단 등록 데이터
		setSimpleData : function(mode){
			var eventObj = {};
			
			eventObj.IsSchedule = $("#IsSchedule").hasClass("active") ? "Y" : "N";
			
			var event = {};
			var date = {};
			var repeat = {};
			var notification = {};
			var userForm = new Array();
			var attendee = new Array();
			
			if(mode == "S"){
				eventObj.ResourceID = $("#ResourceID").val();
				eventObj.ResourceName= $("#FolderName").text();
				if(!eventObj.ResourceName){
					eventObj.ResourceName= $("#FolderName").val();
				}
				event.FolderID = $("#ResourceID").val();
				
				event.Subject = $("#Subject").val();
				event.Description = "";		//$("#Subject").val();
				
				date.StartDate = $("#simpleResDateCon_StartDate").val().replaceAll(".", "-");
				date.EndDate = $("#simpleResDateCon_EndDate").val().replaceAll(".", "-");
				date.StartTime = coviCtrl.getSelected('simpleResDateCon [name=startHour]').val + ":" + coviCtrl.getSelected('simpleResDateCon [name=startMinute]').val;
				date.EndTime = coviCtrl.getSelected('simpleResDateCon [name=endHour]').val + ":" + coviCtrl.getSelected('simpleResDateCon [name=endMinute]').val;
			}else{
				eventObj.ResourceID = $("#resourceSimpleMake #ResourceID").val();
				eventObj.ResourceName= $("#resourceSimpleMake #FolderName").val();
				event.FolderID = $("#resourceSimpleMake #ResourceID").val();
				event.FolderType = "Resource";
				event.Subject = $("#resourceSimpleMake #Subject").val();
				event.Description = "";		//$("#resourceSimpleMake #Subject").val();
				
				date.StartDate = $("#resourceSimpleMake #simpleResDateCon_StartDate").val().replaceAll(".", "-");
				date.EndDate = $("#resourceSimpleMake #simpleResDateCon_EndDate").val().replaceAll(".", "-");
				date.StartTime = coviCtrl.getSelected('resourceSimpleMake #simpleResDateCon [name=startHour]').val + ":" + coviCtrl.getSelected('resourceSimpleMake #simpleResDateCon [name=startMinute]').val;
				date.EndTime = coviCtrl.getSelected('resourceSimpleMake #simpleResDateCon [name=endHour]').val + ":" + coviCtrl.getSelected('resourceSimpleMake #simpleResDateCon [name=endMinute]').val;
			}
			event.FolderType = "Resource";
			event.RegisterCode = userCode;
			event.MultiRegisterName = sessionObj["UR_MultiName"];
			
			date.IsAllDay = 'N';
			date.IsRepeat = 'N';
			
			repeat = {};
			
			notification.IsNotification = "N";
			notification.IsReminder = "N";
			notification.ReminderTime = "10";
			notification.IsCommentNotification = "N";
			notification.MediumKind = "";
			
			eventObj.Event = event;
			eventObj.Date = date;
			eventObj.Repeat = repeat;
			eventObj.Notification = notification;
			eventObj.UserForm = userForm;
			eventObj.Attendee = attendee;
			
			return eventObj;
		},
		// 상세 등록 데이터
		setDetailData : function(setType){
			var eventObj = {};
			var resourceID = $("#ResourceID").val();
			
			eventObj.IsSchedule = $("#IsSchedule").hasClass("on") ? "Y" : "N";
			eventObj.ResourceID = resourceID;
			eventObj.ResourceName= $("#ResourceName").text(); 

			var event = {};
			var date = {};
			var repeat = {};
			var notification = {};
			var userForm = new Array();
			var tempObj = {};
			var tempEvent = {};
			var tempDate = {};
			var tempNotification = {};
			var tempUserForm = new Array;
			var attendee = new Array();		//참석자
			
			//attendee
			//함수이용
			var selectAttendee = coviCtrl.getAutoTags("Attendee");

			$(selectAttendee).each(function(){

				if(this.UserCode == sessionObj["UR_Code"]) {
				
					// 안내 후 삭제
            		Common.Inform(coviDic.dicMap["msg_no_self_attendant"]);  //내 일정의 참석자로 본인을 등록할 수 없습니다.
            		$("#attendeeAutoComp").find("div[data-value='" + sessionObj["UR_Code"] + "']").remove();
    				return;
    			}
				
				var attendeeObj = {};
				if(this.value == "undefined" || this.value == ""){
					
					attendeeObj.UserName   = "";
					attendeeObj.UserCode   = "";
					attendeeObj.IsOutsider = "Y";
					attendeeObj.IsAllow    = "N";
				}else{

					attendeeObj.UserName   = this.UserName;
					attendeeObj.UserCode   = this.value.split("|")[0];
					attendeeObj.IsAllow    = this.value.split("|")[1] == undefined ? "" : this.value.split("|")[1];
					attendeeObj.IsOutsider = "N";
				}

				attendeeObj.dataType = "NEW";
				attendee.push(attendeeObj);
			});
			
			if (eventObj.IsSchedule == "Y") {
				event.FolderID = $("#hidFolderID").val();
				event.FolderType = $("#hidFolderType").val() == "" ? "Resource" : $("#hidFolderType").val();
			}
			else {
				event.FolderID = $("#ResourceID").val();
				event.FolderType = "Resource";
			}
			event.FolderID =  event.FolderID == "" ? $("#ResourceID").val() : event.FolderID;
			
			event.Subject = $("#Subject").val();
			event.Description = "";
			event.RegisterCode = userCode;
			event.MultiRegisterName = sessionObj["UR_MultiName"];
			
			if($("#IsRepeat").val() == "N"){
				date.StartDate = $("#detailDateCon_StartDate").val().replaceAll(".", "-");
				date.EndDate = $("#detailDateCon_EndDate").val().replaceAll(".", "-");
				date.StartTime = coviCtrl.getSelected('detailDateCon [name=startHour]').val + ":" + coviCtrl.getSelected('detailDateCon [name=startMinute]').val;
				date.EndTime = coviCtrl.getSelected('detailDateCon [name=endHour]').val + ":" + coviCtrl.getSelected('detailDateCon [name=endMinute]').val;
				
				repeat = {};
			}else{
				date.StartDate = "";
				date.EndDate = "";
				date.StartTime = "";
				date.EndTime = "";
				
				repeat = $.parseJSON($("#hidRepeatInfo").val()).ResourceRepeat;
			}
			date.IsAllDay = $("#IsAllDay").is(":checked") ? "Y" : "N";
			date.IsRepeat = $("#IsRepeat").val();
			
			notification.IsNotification = $("#IsNotification").val() == "" ? "N" : $("#IsNotification").val();
			notification.IsReminder = $("#IsReminder").val();
			notification.ReminderTime = $("#ReminderTime option:selected").val() == "" ? "10" : $("#ReminderTime option:selected").val();
			notification.IsCommentNotification = $("#IsCommentNotification").val();
			notification.MediumKind = "";
			
			// UserForm Data
			$("#userFormOption").find(">div").each(function(){
				var userFormObj = {};
				
				userFormObj.UserFormID = $(this).attr("id");
				userFormObj.FolderID = $("#ResourceID").val();
				userFormObj.FieldValue = resourceUser.getUserFormOptionValue($(this).find("[name=content]"));
				
				userForm.push(userFormObj);
			});
			
			eventObj.Event = event;
			eventObj.Date = date;
			eventObj.Repeat = repeat;
			eventObj.Notification = notification;
			eventObj.UserForm = userForm;
			eventObj.Attendee = attendee;
			
			// 수정할 경우
			if(setType == "U"){
				tempEvent = {
						"FolderID": $$(updateBookingDataObj).find("bookingData").attr("ResourceID"),
						"FolderType": $("#hidFolderType").val(),
						"Subject": $$(updateBookingDataObj).find("bookingData").attr("Subject"),
						"Description": "",
						"RegisterCode": event.RegisterCode,
						"MultiRegisterName": event.MultiRegisterName
				};
				
				tempDate = {
						"StartDate": $$(updateBookingDataObj).find("bookingData").attr("StartDateTime").split(" ")[0],
					    "EndDate": $$(updateBookingDataObj).find("bookingData").attr("EndDateTime").split(" ")[0],
					    "StartTime": $$(updateBookingDataObj).find("bookingData").attr("StartDateTime").split(" ")[1],
					    "EndTime": $$(updateBookingDataObj).find("bookingData").attr("EndDateTime").split(" ")[1],
					    "IsAllDay": $$(updateBookingDataObj).find("bookingData").attr("IsAllDay"),
					    "IsRepeat": $$(updateBookingDataObj).find("bookingData").attr("IsRepeat")
				};
				
				tempNotification = $$(updateBookingDataObj).find("notification").json();
				
				$$(updateBookingDataObj).find("userDefValue").concat().each(function(i, obj){
					tempUserForm.push({
						"UserFormID": $$(obj).attr("UserFormID"),
						"FolderID": $$(updateBookingDataObj).find("bookingData").attr("ResourceID"),
						"FieldValue": $$(obj).attr("FieldValue")
					});
				});
				
				tempObj.IsSchedule = $$(updateBookingDataObj).find("bookingData").attr("LinkScheduleID") == "" ? "N" : "Y";
				tempObj.ResourceID = $$(updateBookingDataObj).find("bookingData").attr("ResourceID");
				
				tempObj.Event = tempEvent;
				tempObj.Date = tempDate;
				tempObj.Notification= tempNotification;
				tempObj.UserForm = tempUserForm;
				tempObj.Repeat = $$(updateBookingDataObj).find("repeat").json();
				tempObj.Attendee = updateBookingDataObj.bookAtdData;
				
				//TODO 반복 관련 추가 개발 필요
				// 반복이 바뀌어도 Repeat 데이터로 가능할 경우
				if($$(tempObj).find("Date").attr("IsRepeat") == "Y" && $$(eventObj).find("Date").attr("IsRepeat") == "Y"){
					$$(tempObj).find("Date").remove();
					$$(eventObj).find("Date").remove();
				}
				//$$(tempObj).find("Repeat").remove();
				//$$(eventObj).find("Repeat").remove();
				//var resourceRepeat = {"ResourceRepeat" : {}};
				//$$(resourceRepeat).find("ResourceRepeat").append($$(tempObj).find("Repeat").json());
				//$$(tempObj).find("Repeat").remove();
				//$$(tempObj).append("Repeat", $$(resourceRepeat).json()).json();
				
				// eventObj와 tempObj 비교
				eventObj = compareEventObject(eventObj,tempObj);
				
				//추가 참석자 데이터 별도 비교 필요
				if(eventObj.Attendee != undefined){
					var oldData = tempObj.Attendee;
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
				
				eventObj.EventID = CFN_GetQueryString("eventID");
				eventObj.DateID = CFN_GetQueryString("dateID");
				eventObj.RepeatID = CFN_GetQueryString("repeatID");
				eventObj.IsRepeatAll = CFN_GetQueryString("isRepeatAll") == "undefined" ? "N":  CFN_GetQueryString("isRepeatAll");
				eventObj.IsSchedule = $("#IsSchedule").hasClass("on") ? "Y" : "N";
				eventObj.ResourceID = resourceID;
				eventObj.oldResourceID = CFN_GetQueryString("resourceID");
				eventObj.RegisterCode = event.RegisterCode;
				eventObj.Attendee 	   	  = attendee;
				
				// 미리알림을 위한 데이터
				eventObj.Subject = eventObj.Subject == undefined ? updateBookingDataObj.bookingData.Subject : eventObj.Event.Subject;
				eventObj.FolderID = eventObj.FolderID == undefined ? updateBookingDataObj.bookingData.FolderID : eventObj.Event.FolderID;
				eventObj.FolderID = eventObj.IsRepeat == undefined ? updateBookingDataObj.bookingData.IsRepeat : eventObj.Event.FolderID;
			}
			else if(setType == "RU"){
				var tempEventObj;
				
				tempEvent = {
						"FolderID": $$(updateBookingDataObj).find("bookingData").attr("ResourceID"),
						"FolderType": "Resource",
						"Subject": $$(updateBookingDataObj).find("bookingData").attr("Subject"),
						"Description": "",
						"RegisterCode": event.RegisterCode,
						"MultiRegisterName": event.MultiRegisterName
				};
				
				tempDate = {
						"StartDate": $$(updateBookingDataObj).find("bookingData").attr("StartDateTime").split(" ")[0],
					    "EndDate": $$(updateBookingDataObj).find("bookingData").attr("EndDateTime").split(" ")[0],
					    "StartTime": $$(updateBookingDataObj).find("bookingData").attr("StartDateTime").split(" ")[1],
					    "EndTime": $$(updateBookingDataObj).find("bookingData").attr("EndDateTime").split(" ")[1],
					    "IsAllDay": $$(updateBookingDataObj).find("bookingData").attr("IsRepeat"),
					    "IsRepeat": $$(updateBookingDataObj).find("bookingData").attr("IsAllDay")
				};
				
				tempNotification = $$(updateBookingDataObj).find("notification").json();
				
				$$(updateBookingDataObj).find("userDefValue").concat().each(function(i, obj){
					tempUserForm.push({
						"UserFormID": $$(obj).attr("UserFormID"),
						"FolderID": $$(updateBookingDataObj).find("bookingData").attr("ResourceID"),
						"FieldValue": $$(obj).attr("FieldValue")
					});
				});
				
				tempObj.IsSchedule = $$(updateBookingDataObj).find("bookingData").attr("LinkScheduleID") == "" ? "N" : "Y";
				tempObj.ResourceID = $$(updateBookingDataObj).find("bookingData").attr("ResourceID");
				
				tempObj.Event = tempEvent;
				tempObj.Date = tempDate;
				tempObj.Notification= tempNotification;
				tempObj.UserForm = tempUserForm;
				
				//TODO 반복 관련 추가 개발 필요
				$$(tempObj).find("Repeat").remove();
				$$(eventObj).find("Repeat").remove();
				
				// eventObj와 updateScheduleDataObj 비교
				tempEventObj = compareEventObject(eventObj,tempObj);
				
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
		getUserFormOptionValue : function(obj){
			var returnVal = "";
			var fieldType = $(obj).attr("type");
			
			switch (fieldType) {
			case "Input": case "TextArea": case "Date":
				returnVal = $(obj).find("input,textarea").val();
				break;
			case "Radio": case "CheckBox":
				returnVal = $(obj).find("input:checked").val() == undefined ? "" : $(obj).find("input:checked").val();
				break;
			case "DropDown":
				returnVal = $(obj).find("select option:selected").val();
				break;
			default:
				break;
			}
			
			return returnVal;
		},
		// Validation Check
		checkValidationResource : function(eventObj){
			var returnVal = true;

			if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
			
			var folderID = eventObj.ResourceID;
			var leastRentalTime;
			$.ajax({
			    url: "/groupware/resource/getResourceData.do",
			    type: "POST",
			    async: false,
			    data: {
			    	"FolderID" : folderID
				},
			    success: function (res){
			    	if(res.status == "SUCCESS"){
			    		if(res.data.resourceData){
			    			var resourceData = res.data.resourceData;
			    			leastRentalTime = resourceData.LeastRentalTime;
			    		}
			    	} else {
						Common.Error("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생했습니다.
					}
			    },
			    error: function(response, status, error){
					CFN_ErrorAjax("/groupware/schedule/getThemeList.do", response, status, error);
				}
			});
			
			if(eventObj.Date != undefined){
				var startDateTime = eventObj.Date.StartDate + " " + eventObj.Date.StartTime;
				var endDateTime = eventObj.Date.EndDate + " " + eventObj.Date.EndTime;
				
				if(eventObj.Date.IsRepeat == "N"){
					// 시작날짜 입력여부 체크
					if(eventObj.Date.StartDate == "") {
	                     Common.Warning(Common.getDic("msg_EnterStartDate"));
	                     return false;
		            }
	
					// 종료날짜 입력여부 체크
					if(eventObj.Date.EndDate == "") {
	                     Common.Warning(Common.getDic("msg_EnterEndDate"));
	                     return false;
					}
				}
				
				// 이전날짜 및 시간 체크
				if (Common.getBaseConfig('IsPastSave') == '' || Common.getBaseConfig('IsPastSave') == 'N'){
					if(parseInt(g_currentTime.getTime() / 1000 / 60) > parseInt(new Date(replaceDate(startDateTime)).getTime() / 1000 / 60)){
						Common.Warning(Common.getDic("msg_cannotBookingBefore"));			//현재보다 이전 시간에 대해서 예약할 수 없습니다.
						return false;
					}
					
					if(eventObj.Repeat != undefined && Object.keys(eventObj.Repeat).length > 0){
						var repeatStartDateTime = eventObj.Repeat.RepeatStartDate + " " + eventObj.Repeat.AppointmentStartTime;
						if(parseInt(g_currentTime.getTime() / 1000 / 60) > parseInt(new Date(replaceDate(repeatStartDateTime)).getTime() / 1000 / 60)){
							Common.Warning(Common.getDic("msg_cannotBookingBefore"));			//현재보다 이전 시간에 대해서 예약할 수 없습니다.
							return false;
						}
					}
				}
				
				// 시작일/종료일 체크
				/*if(parseInt(new Date(replaceDate(startDateTime)).getTime() / 1000 / 60) > parseInt(new Date(replaceDate(endDateTime)).getTime() / 1000 / 60)){
					Common.Warning(Common.getDic("msg_StartDateCannotAfterEndDate"));			//시작일은 종료일 보다 이후일 수 없습니다.
					return false;
				}*/
				if($("#detailDateCon_StartDate").val() > $("#detailDateCon_EndDate").val()){
					Common.Warning(Common.getDic("msg_StartDateCannotAfterEndDate"));			//시작일은 종료일 보다 이후일 수 없습니다.
					return false;
				} else if($("#detailDateCon_StartDate").val() == $("#detailDateCon_EndDate").val()){
					if(coviCtrl.getSelected('detailDateCon [name=startHour]').val + ":" + coviCtrl.getSelected('detailDateCon [name=startMinute]').val > coviCtrl.getSelected('detailDateCon [name=endHour]').val + ":" + coviCtrl.getSelected('detailDateCon [name=endMinute]').val){
						Common.Warning(Common.getDic("mag_Attendance81"));						// 종료시간이 시작시간보다 작을 수 없습니다.
						return false;
					}
				}
				
				// 최소 대여기간 체크
				if ($("#IsRepeat").val() == 'Y'){
					startDateTime = CFN_GetLocalCurrentDate(_ServerDateSimpleFormat) + " " + eventObj.Repeat.AppointmentStartTime;
					if (eventObj.Repeat.AppointmentStartTime > eventObj.Repeat.AppointmentEndTime){
						endDateTime = schedule_SetDateFormat(schedule_AddDays(CFN_GetLocalCurrentDate(_ServerDateSimpleFormat), 1),'-') + " " + eventObj.Repeat.AppointmentEndTime;
					} else {
						endDateTime = CFN_GetLocalCurrentDate(_ServerDateSimpleFormat) + " " + eventObj.Repeat.AppointmentEndTime;
					}
				}
				var rentalTime = parseInt(new Date(replaceDate(endDateTime)).getTime() / 1000 / 60) - parseInt(new Date(replaceDate(startDateTime)).getTime() / 1000 / 60);
				if(rentalTime < leastRentalTime){
					var leastRentalTimeStr;
					if(leastRentalTime < 60){
						leastRentalTimeStr = leastRentalTime + Common.getDic("lbl_Minutes"); // 분
					}else{
						leastRentalTimeStr = Math.floor(leastRentalTime/60) + Common.getDic("lbl_Time"); // 시간
						if(leastRentalTime % 60 != 0){
							leastRentalTimeStr += " " + (leastRentalTime % 60) + Common.getDic("lbl_Minutes"); // 분
						}
					}
					Common.Warning(Common.getDic("msg_cannotLeastRentalTimeBefore").replace("{0}", leastRentalTimeStr)); // 최소 대여기간보다 적게 예약할 수 없습니다.<br/>{0} 이상 예약해주세요.
					return false;
				}
			}
			
			
			// 자원 선택 여부 체크
			var folder = eventObj.ResourceID;
			if(folder == undefined || folder == ""){
				Common.Warning(Common.getDic("msg_mustSelectRes"));			//자원을 선택해주세요.
				return false;
			}
			
			// 제목 입력 여부 체크
			if(eventObj.Event != undefined){
				var subject = eventObj.Event.Subject;
				if(subject == undefined || subject == ""){
					Common.Warning(Common.getDic("msg_ReservationWrite_01"));			//용도를 입력해주세요.
					return false;
				}
			}
			
			if(eventObj.Repeat != undefined && Object.keys(eventObj.Repeat).length > 0){
				if(eventObj.Repeat.RepeatType == 'M' || eventObj.Repeat.RepeatType == 'Y'){
					var year = Number(eventObj.Repeat.RepeatStartDate.split("-")[0]); 
					var month = Number(eventObj.Repeat.RepeatMonth);
					var day = Number(eventObj.Repeat.RepeatDay);
					
					var date = new Date(year, month-1, day);
					
					if(date.getFullYear() === year && date.getMonth() === month-1 && date.getDate() === day){
						return true;
					} else {
						Common.Warning(Common.getDic("lbl_RepeatSettingDateValid"));
						return false;
					}	
				}
			}
			
			return returnVal;
		},
		//상세 등록화면에서 종일 체크
		setAllDayCheck : function(){
			if ($("#IsAllDay").is(":checked")) {
		        var sStartDate = $("#detailDateCon_StartDate").val();
		        var sStartHour = coviCtrl.getSelected('detailDateCon [name=startHour]').val;
		        var sStartMinute = coviCtrl.getSelected('detailDateCon [name=startMinute]').val;
		        var sEndDate = $("#detailDateCon_EndDate").val();
		        var sEndHour = coviCtrl.getSelected('detailDateCon [name=endHour]').val;
		        var sEndMinute = coviCtrl.getSelected('detailDateCon [name=endMinute]').val;

		        $("#hidStartDate").val(sStartDate);
		        $("#hidStartHour").val(sStartHour);
		        $("#hidStartMinute").val(sStartMinute);
		        $("#hidEndDate").val(sEndDate);
		        $("#hidEndHour").val(sEndHour);
		        $("#hidEndMinute").val(sEndMinute);
		        
		        coviCtrl.setSelected('detailDateCon [name=startHour]', "00");
				coviCtrl.setSelected('detailDateCon [name=startMinute]', "00");
				
				coviCtrl.setSelected('detailDateCon [name=endHour]', "23");
				coviCtrl.setSelected('detailDateCon [name=endMinute]', "59");
		        
				//disabled true
				$("#detailDateCon [name=startHour]").find("select").attr("disabled", true);
				$("#detailDateCon [name=startMinute]").find("select").attr("disabled", true);
				$("#detailDateCon [name=endHour]").find("select").attr("disabled", true);
				$("#detailDateCon [name=endMinute]").find("select").attr("disabled", true);
				$("#detailDateCon [name=datePicker]").find("select").attr("disabled", true);
				
				coviCtrl.setSelected('detailDateCon [name=datePicker]', "select");
		    } else {
		        sStartDate = $("#hidStartDate").val();
		        sStartHour = $("#hidStartHour").val();
		        sStartMinute = $("#hidStartMinute").val();
		        sEndDate = $("#hidEndDate").val();
		        sEndHour = $("#hidEndHour").val();
		        sEndMinute = $("#hidEndMinute").val();
		        
		        $("#detailDateCon_StartDate").val(sStartDate).attr("disabled", false);
		        coviCtrl.setSelected('detailDateCon [name=startHour]', sStartHour);
				coviCtrl.setSelected('detailDateCon [name=startMinute]', sStartMinute);
				
		        $("#detailDateCon_EndDate").val(sEndDate).attr("disabled", false);
				coviCtrl.setSelected('detailDateCon [name=endHour]', sEndHour);
				coviCtrl.setSelected('detailDateCon [name=endMinute]', sEndMinute);
				
				// disabled false
				$("#detailDateCon [name=startHour]").find("select").attr("disabled", false);
				$("#detailDateCon [name=startMinute]").find("select").attr("disabled", false);
				$("#detailDateCon [name=endHour]").find("select").attr("disabled", false);
				$("#detailDateCon [name=endMinute]").find("select").attr("disabled", false);
				$("#detailDateCon [name=datePicker]").find("select").attr("disabled", false);
		    }
		},
		//월간에서 간단 조회창 열기
		setSimpleViewPopup : function(obj){
			var resourceID = $(obj).attr("resourceID");
            var SelectSecurityLevel = $$(resAclArray).find("read").concat().find("[FolderID="+resourceID+"]").attr("SecurityLevel");
            var UserSecurityLevel = Common.getSession("SecurityLevel");

			if($$(resAclArray).find("read").concat().find("[FolderID="+$(obj).attr("resourceID")+"]").length > 0 && Number(SelectSecurityLevel) >= Number(UserSecurityLevel)){		// 읽기 권한 체크
				var popupObj;
				
				$("#read_popup").load("/groupware/resource/getSimpleViewView.do", function(){
					if ($("article[id=popup]").html() != '') $("article[id=popup]").html('');
					
					var eventID = $(obj).attr("eventid");
					var dateID = $(obj).attr("dateid");
					var isRepeat = $(obj).attr("isrepeat");
					var repeatID = $(obj).attr("repeatid");
					
					$("#eventID").val(eventID);
					$("#dateID").val(dateID);
					$("#isRepeat").val(isRepeat);
					$("#repeatID").val(repeatID);
					$("#resourceID").val(resourceID);
					
					resourceUser.setSimpleViewTopLeft(obj);
					g_isPopup = true;
					popObj = obj;
					
			    	// 데이터 세팅
					resourceUser.setViewData("S", eventID, dateID, resourceID, repeatID);
			    	
			    	// 자주 쓰는 일정 버튼 onclick
			    	$("#btnAddTemplate").attr("onclick", "addTemplateScheduleData("+eventID+", 'S')");
				});
			}else{
				Common.Warning(Common.getDic("msg_noViewACL"));		//읽기 권한이 없습니다.
			}
		},
		//주간, 일간에서 간단 조회창 열기
		setSimpleViewPopupDW : function(eventID, dateID, repeatID, isRepeat, resourceID, start){
			$("#popup").load("/groupware/resource/getSimpleViewView.do", function(){
				resourceUser.setSimpleViewTopLeft(start);
		    	
				$("#eventID").val(eventID);
				$("#dateID").val(dateID);
				$("#repeatID").val(repeatID);
				$("#isRepeat").val(isRepeat);
				$("#resourceID").val(resourceID);
				
				if($$(resAclArray).find("modify").concat().find("[FolderID="+resourceID+"]").length <= 0){		// 수정 권한 체크
					$("#btnModify").hide();
					$("#btnDelete").removeClass("left");
				}
				g_isPopup = true;
				popObj = start;
				
		    	// 데이터 세팅
				resourceUser.setViewData("S", eventID, dateID, resourceID, repeatID);
			});
		},
		// 간단 등록창 위치 조정
		setSimpleViewTopLeft : function(obj){
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
				
				top += ($(tr).height() * (Number($(tr).attr("rowno"))+1)) + 32; 
				top += pxToNumber($(".resTopCont").css("height")) + $(".calMonHeader").height() + 8;
				left = ($("#monthDate").width()+1) * Number($(td).attr("day"));
				left += pxToNumber($(".resourceContScrollTop").css("padding-left")) + pxToNumber($("#MonthCalendar").css("padding-left")) + 1;
				
				if(left > (pxToNumber($(".resourceContScrollTop").css("width")) - pxToNumber($("#simpleViewPop").css("width")))){
					left = pxToNumber($(".resourceContScrollTop").css("width")) - pxToNumber($("#simpleViewPop").css("width"));
		        }
				if(top > ($(".resourceContScrollTop").height() - pxToNumber($("#simpleViewPop").css("height")))){
					top = top - pxToNumber($("#simpleViewPop").css("height")) - $(tr).height();
		        }
				$("#read_popup").css("left", left+"px") ;
				$("#read_popup").css("top", top+"px");
			}else{
				var posX = $(obj).offset().left - $(".cRContBottom").offset().left;
		        var posY = $(obj).offset().top - $(".cRContBottom").offset().top + pxToNumber($((g_viewType == "D" ? ".reserTblCont tr:first-child td" : ".reserTblWeekly .reserTbl div")).css("height"));
		        
		    	if(posX > ($(".cRContBottom").width() - ($("#simpleViewPop").width() + 20))){
		        	posX = $(".cRContBottom").width() - ($("#simpleViewPop").width() + 20);
		        }
		        if(posY > ($(".cRContBottom").height() - ($("#simpleViewPop").height() + 2))){
		        	posY = posY - pxToNumber($((g_viewType == "D" ? ".reserTblCont tr:first-child td" : ".reserTblWeekly .reserTbl div")).css("height")) - $("#simpleViewPop").height() - 5;
		        }
				
		    	$("#popup").find("aside").css("left", posX+"px") ;
		    	$("#popup").find("aside").css("top", posY+"px");
				
			}
		},
		//간단 등록에서 상세등록으로 이동
		goDetailWritePage : function(){
			$("#simpleSubject").val($("#Subject").val());
			$("#simpleStartDate").val($("#simpleResDateCon_StartDate").val());
			$("#simpleEndDate").val($("#simpleResDateCon_EndDate").val());
			
			$("#simpleStartHour").val(coviCtrl.getSelected('simpleResDateCon [name=startHour]').val);
			$("#simpleStartMinute").val(coviCtrl.getSelected('simpleResDateCon [name=startMinute]').val);
			$("#simpleEndHour").val(coviCtrl.getSelected('simpleResDateCon [name=endHour]').val);
			$("#simpleEndMinute").val(coviCtrl.getSelected('simpleResDateCon [name=endMinute]').val);
			
			$("#simpleIsChkSchedule").val($("#IsSchedule").hasClass("active"));
			$("#simpleSelectDatePicker").val($("#simpleResDateCon [name=datePicker] select").val());
			
			CoviMenu_GetContent("resource_DetailWrite.do?CLSYS=resource&CLMD=user&CLBIZ=Resource&resourceID="+$("#ResourceID").val()+"&simpleDatePicker="+$("#simpleSelectDatePicker").val());
		},
		
		setAttendeeAutoInput : function(){
			
			// 사용자 값 조회
			coviCtrl.setUserWithDeptAutoTags(
					   'Attendee' 									//타겟
					,  '/covicore/control/getAllUserAutoTagList.do' //url 
					, {	  labelKey    : 'UserName'
						, addInfoKey  : 'DeptName'
						, valueKey    : 'UserCode'
						, minLength   : 1
						, useEnter 	  : false
						, multiselect : true
						, callType 	  : ""
						, select 	  : function(event, ui){
							
							if(ui.item.value == sessionObj["UR_Code"]) {
			            		Common.Inform(Common.getDic("msg_no_self_attendant"));  //내 일정의 참석자로 본인을 등록할 수 없습니다.
			            		ui.item.value = '';
			    				return;
			    			}

							if ($("#attendeeAutoComp").find(".ui-autocomplete-multiselect-item[data-value='"+ ui.item.value+"'], .ui-autocomplete-multiselect-item[data-value^='"+ ui.item.value+"|']").length > 0) {
				    		
								Common.Warning(Common.getDic("ACC_msg_existItem"));
				    			ui.item.value = '';
				    			return;
				    		}
		            	
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
			                                item.remove();
			                            })
			                    )
			                    .insertBefore($("#Attendee"));
			    	    	ui.item.value = ''; // 선택 후 input에 value값이 들어가는 문제가 있어 빈값 처리
						}
					}
				);
		},
		
		//조회창 데이터 세팅
		setViewData : function(mode, eventID, dateID, resourceID, repeatID){
			/**
			 * mode : S - 간단 조회, D - 상세 조회, DU - 상세 등록(수정화면)
			 */
			var data = {
					"mode" : mode,
			    	"EventID" : eventID,
			    	"DateID" : dateID,
			    	"FolderID" : resourceID,
			    	"RepeatID" : repeatID
			};
			
			// 테이블에서 공유자원을 예약정보와 연결해주기 위해 integeratedID(linkFolderID) 값을 <tr>에 resourceID로 입력하여 연결.
			// 공유자원일 경우 실제 resourceID와 다를 수 있음. 실제 정보를 예약항목에서 가져옴.
			var integratedID = $(".ui-selected").attr("integratedid");
			var realResourceID = $(".ui-selected").attr("resourceid");
			
			if (integratedID != "" && realResourceID != "") {
				if (integratedID != realResourceID) {
					data.IntegratedID = integratedID;
					data.ResourceID = realResourceID; 
				}	
			}
			
			$.ajax({
			    url: "/groupware/resource/getBookingData.do",
			    type: "POST",
			    data: data,
			    success: function (res) {
			    	if(res.status == "SUCCESS"){
			    		if(JSON.stringify(res.data.bookingData) != "{}"){
							res.data.bookingData.StartDateTime = CFN_TransLocalTime(res.data.bookingData.StartDateTime, 'yyyy-MM-dd HH:mm');
							res.data.bookingData.EndDateTime = CFN_TransLocalTime(res.data.bookingData.EndDateTime, 'yyyy-MM-dd HH:mm');

			    			var btnHTML = "";
			    			
			    			// 작성자,  Owner 권한 체크, 폴더 권한 체크
			    			if((res.data.bookingData.RegisterCode == userCode || res.data.bookingData.OwnerCode == userCode  || $$(resAclArray).find("modify").concat().find("[FolderID="+resourceID+"]").length > 0)
			    					&& (res.data.bookingData.ApprovalStateCode == "ApprovalRequest" || (res.data.bookingData.ApprovalStateCode == "Approval" && res.data.bookingData.BookingTypeCode == "DirectApproval"))){		// 수정 권한 체크
			    				btnHTML += '<a onclick="resourceUser.modifyResourceEvent();"  id="btnModify" class="btnTypeDefault">'+coviDic.dicMap["btn_Edit"]+'</a>';			//수정
			    			}
			    			
			    			if(	( res.data.bookingData.RegisterCode == userCode || res.data.bookingData.OwnerCode == userCode   )
			    					&& (	(res.data.bookingData.ApprovalStateCode.toUpperCase() == "APPROVAL" && (g_currentTime <= new Date(replaceDate(res.data.bookingData.StartDateTime))) ) || res.data.bookingData.ApprovalStateCode.toUpperCase() == "APPROVALREQUEST") 
			    			){
			    				var isRepeatAll = coviCmn.isNull(CFN_GetQueryString("isRepeatAll"),"N");
			    				//신청철회
			    				btnHTML += ' <a onclick="resourceUser.callDeleteResourceEvent(' + res.data.bookingData.EventID + ', ' + res.data.bookingData.DateID + ', ' + res.data.bookingData.ResourceID + ', \'' + res.data.bookingData.IsRepeat + '\', \'' + isRepeatAll + '\');" class="btnTypeDefault">'+coviDic.dicMap["btn_ApplicationWithdrawn"]+'</a>';		//신청철회'
			    			}
			    			
			    			//자원 정보가 필요한 버튼의 경우 자원 정보 조회 후 표시 여부 확인 (setResourceInfo 함수)
			    			
			    			$("#divBtnBottom").prepend(btnHTML);
			    			$("#btnList").after(btnHTML);
			    			
			    			resourceUser.drawViewData(mode, res.data);
			    			
			    			
			    			if(mode == "D"){
			    				$("#hidFolderType").val(res.data.bookingData.FolderType);	
			    				
			    				// 댓글 알림 보내기 위한 세팅
				    			
				    			
				    			var commentURL = Common.getGlobalProperties("smart4j.path")+"/groupware/layout/resource_DetailView.do?CLSYS=resource&CLMD=user&CLBIZ=Resource"
				    										+ "&eventID=" + eventID	+ "&dateID=" + dateID + "&repeatID=" + repeatID + "&isRepeat=" + res.data.bookingData.IsRepeat	+ "&resourceID=" + resourceID;
				    			var mobileURL = Common.getGlobalProperties("smart4j.path")+"/groupware/mobile/resource/view.do"
				    										+ "?eventid=" + eventID	+ "&dateid=" + dateID + "&repeatid=" + repeatID + "&isrepeat=" + res.data.bookingData.IsRepeat + "&resourceid=" + resourceID;
				    			
				    			var messageSetting = {
				    					SenderCode : sessionObj["USERID"],
				    					RegistererCode : sessionObj["USERID"],
				    					ReceiversCode : (res.data.bookingData.RegisterCode != sessionObj["USERID"]) ? res.data.bookingData.RegisterCode : '',
				    					GotoURL: commentURL, 
				    					PopupURL: commentURL, 
				    					MobileURL: mobileURL,
				    					MessagingSubject : res.data.bookingData.Subject,
				    					ReceiverText : res.data.bookingData.Subject, //요약된 내용
				    					ServiceType : "Resource",
				    					MsgType : "ResourceComment"
				    			};
				    			coviComment.load('commentView', 'Resource', CFN_GetQueryString("eventID"), messageSetting);
			    			}
			    		}else{
							Common.Warning(Common.getDic("msg_changedResourceBooking"), "Warning", function(){ //수정 및 삭제된 자원예약 입니다.
								CoviMenu_GetContent(g_lastURL); // 목록으로 이동
							});
						}
			    	}else {
						Common.Error(coviDic.dicMap["msg_apv_030"]);		// 오류가 발생했습니다.
					}
			       },
			       error:function(response, status, error){
					CFN_ErrorAjax("/groupware/resource/getBookingData.do", response, status, error);
				}
			});
		},
		//주간보기 - 더보기 창에 데이터 표시를 위한 1개 이상의 예약정보 조회
		getArrayBookingData : function(mode, eventIDArr, dateIDArr, resourceIDArr, repeatIDArr){
			var arrayBookingData =[]; 
			
			$.ajax({
			    url: "/groupware/resource/getBookingData.do",
			    type: "POST",
			    async: false,
			    data: {
			    	"mode" : mode,
			    	"EventIDArr" : eventIDArr,
			    	"DateIDArr" : dateIDArr,
			    	"FolderIDArr" : resourceIDArr,
			    	"RepeatIDArr" : repeatIDArr
				},
			    success: function (res) {
			    	if(res.status == "SUCCESS"){
			    		arrayBookingData =  res.data.arrayBookingData;
			    	} else {
						Common.Error(coviDic.dicMap["msg_apv_030"]);		// 오류가 발생했습니다.
					}
			    },
			    error:function(response, status, error){
					CFN_ErrorAjax("/groupware/resource/getBookingData.do", response, status, error);
				}
			});
			
			return arrayBookingData;
		},
		//조회한 데이터 상황에 맞게 그려주기
		drawViewData : function(mode, data){
			var bookingData = data.bookingData;
			var attendeData  = data.bookAtdData;
			var repeatData = data.repeat;
			var notification = data.notification;
			var userDefValue = data.userDefValue;
			var startDate, endDate;
			
			var sRepJobTypeConfig = Common.getBaseConfig("RepJobType");
				var sRepJobType = bookingData.UserLevelName;
		        if(sRepJobTypeConfig == "PN"){
		        	sRepJobType = bookingData.UserPositionName;
		        } else if(sRepJobTypeConfig == "TN"){
		        	sRepJobType = bookingData.UserTitleName;
		        } else if(sRepJobTypeConfig == "LN"){
		        	sRepJobType = bookingData.UserLevelName;
		        }
			
			//개별호출 - 일괄호출
			Common.getDicList(["lbl_LinkSchedule","lbl_noexists"]);
			
			if(mode=="S"){
				var subject = bookingData.Subject + '<a class="btnAppReq '+resourceUser.getApprovalStateIcon(bookingData.ApprovalStateCode)+'">'+bookingData.ApprovalState+'</a>';
				$("#Subject").html(subject);
				
				startDate = new Date(replaceDate(bookingData.StartDateTime));
				startDate = schedule_SetDateFormat(startDate, ".") + " " + AddFrontZero(startDate.getHours(), 2)+":"+AddFrontZero(startDate.getMinutes(), 2);
				startDate = startDate.substring(startDate.indexOf(".")+1, startDate.length);
				
				endDate =new Date(replaceDate(bookingData.EndDateTime));
				endDate = schedule_SetDateFormat(endDate, ".") + " " + AddFrontZero(endDate.getHours(), 2)+":"+AddFrontZero(endDate.getMinutes(), 2);
				endDate = endDate.substring(endDate.indexOf(".")+1, endDate.length);
				
				$("#StartEndDateTime").html(startDate + " - " + endDate + " " + Common.getSession("UR_TimeZoneDisplay"));
				
				//$("#Register").html(bookingData.RegisterName+" "+bookingData.UserPositionName+ ( bookingData.UserDeptName == undefined ? "" : " ("+bookingData.UserDeptName+")") );
				$("#Register").html('<strong class="btnFlowerName" onclick="coviCtrl.setFlowerName(this)" style="font-weight:500;position:relative;cursor:pointer" data-user-code="'+ bookingData.RegisterCode +'" data-user-mail="" >' + bookingData.RegisterName + " " + sRepJobType + '</strong>');
				$("#ResourceName").html(bookingData.ResourceName);
			}
			else if(mode == "D"){
				$("#Subject").html(bookingData.Subject);
				
				//참석자
				Common.getDicList(["lbl_schedule_attend","lbl_Important","lbl_schedule_noAttend","lbl_noexists","lbl_schedule_participation","lbl_schedule_Nonparticipation","lbl_schedule_standBy"]);

				/*$(attendeData).each(function(){
					if($$(this).attr("UserCode") == userCode && $$(this).attr("IsAllow") == ""){
						var btnHTML = '<a onclick="scheduleUser.approve(\'APPROVAL\');" class="btnTypeDefault right">'+coviDic.dicMap["lbl_schedule_attend"]+'</a><a onclick="scheduleUser.approve(\'REJECT\');" class="btnTypeDefault left">'+coviDic.dicMap["lbl_schedule_noAttend"]+'</a>';		//참석 요청 승인
						$("#btnList").after(btnHTML);
						return false;
					} 
				});*/

				if(attendeData.length > 0 && attendeData[0].UserCode != undefined){
					var attendeeHTML = "";
					$(attendeData).each(function(){

						if(bookingData.LinkScheduleID.length >0 && bookingData.LinkScheduleID != undefined) {
						attendeeHTML += '<span>';
						
						//참석여부를 표기하는 곳.
						if(this.IsAllow == "Y")
							
							attendeeHTML += '<span class="btnType02 blue">'+coviDic.dicMap["lbl_schedule_participation"]+'</span>';		//참여
						else if(this.IsAllow == "N")
							
							attendeeHTML += '<span class="btnType02">'+coviDic.dicMap["lbl_schedule_Nonparticipation"]+'</span>';		//비참여
						else
							attendeeHTML += '<span class="btnType02">'+coviDic.dicMap["lbl_schedule_standBy"]+'</span>';				//대기중
						}
							
						attendeeHTML += this.UserName+(this.DeptName == undefined ? "" : ' ('+this.DeptName+')' )+'&nbsp;</span>'; 
					});
					
					$("#Attendee").html(attendeeHTML);
				}else{
					$("#Attendee").html("<span>"+coviDic.dicMap["lbl_noexists"]+"</span>");		//없음
				}
				
				if(bookingData.IsRepeat == "Y" && CFN_GetQueryString("isRepeatAll") == "Y"){
					var startEndDateTime = getRepeatViewMessage(repeatData);
					
					$("#StartEndDateTime").html(startEndDateTime);
				}else{
					startDate =new Date(replaceDate(bookingData.StartDateTime));
					startDate = schedule_SetDateFormat(startDate, ".") + " " + AddFrontZero(startDate.getHours(), 2)+":"+AddFrontZero(startDate.getMinutes(), 2);
					
					endDate =new Date(replaceDate(bookingData.EndDateTime));
					endDate = schedule_SetDateFormat(endDate, ".") + " " + AddFrontZero(endDate.getHours(), 2)+":"+AddFrontZero(endDate.getMinutes(), 2);
					
					$("#StartEndDateTime").html(startDate + " - " + endDate + " " + Common.getSession("UR_TimeZoneDisplay"));
				}
				
				$("#RegisterPhoto").attr("src", bookingData.RegisterPhoto == undefined ? "" : coviCmn.loadImage(bookingData.RegisterPhoto));
				
				$("#Register").html('<strong class="btnFlowerName" onclick="coviCtrl.setFlowerName(this)" style="position:relative;cursor:pointer" data-user-code="'+ bookingData.RegisterCode +'" data-user-mail="" >' + bookingData.RegisterName + " " + sRepJobType + '</strong>');
				
				
				// 알림은 등록자와 참석자만 변경할 수 있음
				if($.isEmptyObject(notification)){
					$("#divNotification").hide();
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
				
				$("#ResourceName").html(bookingData.ResourceName);
				resourceUser.setResourceInfo("R", bookingData.ResourceID, bookingData);
				
				if(bookingData.LinkScheduleID != "" && bookingData.LinkScheduleID != 0){
					$("#linkSchedule").attr("eventID", bookingData.LinkScheduleID);
					$("#linkSchedule").html(bookingData.Subject);
					$("#linkSchedule").attr("onclick", 'scheduleUser.goDetailViewPage("LinkSchedule", "'+bookingData.LinkScheduleID+'", "'+bookingData.DateID+'", "'+bookingData.RepeatID+'", "'+bookingData.IsRepeat+'", "'+bookingData.FolderID+'")');
				}else{
					$("#linkSchedule").parent().html(coviDic.dicMap["lbl_noexists"]);			//없음
				}
				
				// UserForm
				var userDefValueHtml = "";
				$(userDefValue).each(function(){
					userDefValueHtml += '<div>';
					userDefValueHtml += '<div class="tit"><span>'+this.FieldName+'</span></div>';
					userDefValueHtml += '<div class="txt">';
					userDefValueHtml += '<p>'+(this.FieldText == "" ?coviDic.dicMap["lbl_noexists"] : this.FieldText)+'</p>';			//없음
					userDefValueHtml += '</div>';
					userDefValueHtml += '</div>';
				});
				
				$("#divBookingData").append(userDefValueHtml);
			}else if(mode == "DU"){
				updateBookingDataObj = data;
				$(updateBookingDataObj.bookAtdData).each(function(){
					this.dataType = "OLD";
				});
				
				if($(updateBookingDataObj.bookAtdData).length >0) {
					$("#AttendeeYN").addClass("on");
				    $(".autoCompleteCustom").show();
				    $("#topInfoBoxMessage").show();
				}
				
				$("#hidFolderID").val(bookingData.FolderID);
				$("#hidFolderType").val(bookingData.FolderType);
				
				$("#detailDateCon_StartDate").val(bookingData.StartDateTime.split(" ")[0].replaceAll("-", "."));
				$("#detailDateCon_EndDate").val(bookingData.EndDateTime.split(" ")[0].replaceAll("-", "."));
				
				var startTime = bookingData.StartDateTime.split(" ")[1];
				var endTime = bookingData.EndDateTime.split(" ")[1];
				
				coviCtrl.setSelected('detailDateCon [name=startHour]', startTime.split(":")[0]);
				coviCtrl.setSelected('detailDateCon [name=startMinute]', startTime.split(":")[1]);
				coviCtrl.setSelected('detailDateCon [name=endHour]', endTime.split(":")[0]);
				coviCtrl.setSelected('detailDateCon [name=endMinute]', endTime.split(":")[1]);
				coviCtrl.setSelected('detailDateCon [name=datePicker]', "select");	//JSYun 기존  예약 자원 수정시, select는 선택으로 변경

				// 종일 체크표시
				if(bookingData.IsAllDay == "Y"){
					$("input:checkbox[id='IsAllDay']").prop("checked", true); //check박스 checked 표시
				}
				
				//반복
				repeatData = {"ResourceRepeat" : repeatData};
				if(bookingData.IsRepeat == "Y" && CFN_GetQueryString("isRepeatAll") == "N"){
					bookingData.IsRepeat = "N";
					repeatData = {};
				}
				$("#IsRepeat").val(bookingData.IsRepeat);
				resourceUser.callBackRepeatSetting(JSON.stringify(repeatData), "DU");
				
				if(bookingData.LinkScheduleID != ""){
					$("#IsSchedule").addClass("on");
				}
				
				// 알림은 등록자와 참석자만 변경할 수 있음
				if(!$.isEmptyObject(notification)){
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
				
				//$("#NotificationType").hide();
				
				var setSubject = bookingData.Subject.split('&nbsp;').join(' ').replaceAll("<br />","\r\n");
				$("#Subject").html(setSubject).val();
				
				//자원예약 수정화면상에서 참석자 출력관련 부분.
				var attendeeListHTML = "";
				if(attendeData.length > 0 && attendeData[0].UserCode != undefined){
					
					$(attendeData).each(function(){
						
						var attendeeObj = $("<div></div>").addClass("ui-autocomplete-multiselect-item")
		                								  .attr("data-json", JSON.stringify({"UserCode":this.UserCode,"UserName":this.UserName,"label":this.UserName,"value":this.UserCode}))
		                								  .attr("data-value", this.UserCode+'|'+this.IsAllow)
		                								  .text(this.UserName)
		                								  .append(
		                    										$("<span></span>").addClass("ui-icon ui-icon-close")
		                        													  .click(function(){
		                            														
		                            														var item = $(this).parent();
		                            															item.remove();
		                        														})
		                										 );
						$("#attendeeAutoComp .ui-autocomplete-multiselect").prepend(attendeeObj);
					});
				}
				
				// UserForm
				$(userDefValue).each(function(){
					var obj = "[name=option_"+this.UserFormID+"]";
					
					switch (this.FieldType) {
					case "Input": case "TextArea": case "Date":
						$(obj).val(this.FieldValue);
						break;
					case "Radio": case "CheckBox":
						$(obj+"[value="+this.FieldValue+"]").prop("checked", true);
						break;
					case "DropDown":
						$(obj).find("option[value="+this.FieldValue+"]").attr("selected", "selected");
						break;
					default:
						break;
					}
				});
			}
			
			g_fileList = data.fileList;

			$(".attFileListBox").html("");
			if(g_fileList !== undefined && g_fileList !== null && g_fileList.length > 0){
				var attFileAnchor = $('<a onclick="$(\'.attFileListCont\').toggleClass(\'active\');"/>').addClass('btnAttFile btnAttFileListBox').text('(' + g_fileList.length + ')');
				var attFileListCont = $('<ul>').addClass('attFileListCont');
				var attFileDownAll = $('<li>').append("<a href='#' onclick='javascript:resourceUser.downloadAll(g_fileList)'>"+Common.getDic("lbl_download_all")+"</a>").append($('<a onclick="$(\'.attFileListCont\').toggleClass(\'active\');" >').addClass("btnXClose btnAttFileListBoxClose"));
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
					
					$(attFileList).append($('<p style="cursor:pointer;"/>').attr({"fileID": item.FileID, "fileToken": item.FileToken}).addClass('fName').append($('<span title="'+item.FileName+'">').addClass(iconClass).text(item.FileName)).append($('<span class="fileSize">').text("("+convertFileSize(item.Size)+")")));
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
		//간단 조회에서 상세 조회창으로 이동
		goDetailViewPage : function(mode, eventID, dateID, repeatID, isRepeat, resourceID){
			g_lastURL = location.href.replace(location.origin, "");
			
			eventID = $("#eventID").val() == undefined ? eventID : $("#eventID").val();
			dateID = $("#dateID").val() == undefined ? dateID : $("#dateID").val();
			isRepeat = $("#isRepeat").val() == undefined ? isRepeat : $("#isRepeat").val();
			resourceID = $("#resourceID").val() == undefined ? resourceID : $("#resourceID").val();
			repeatID = $("#repeatID").val() == undefined ? repeatID : $("#repeatID").val();
			
			if(isRepeat == "Y"){
				var showRepeatHTML = getRepeatAllOROnlyHTML("V", eventID, dateID, resourceID, repeatID);
				Common.open("","showRepeat",Common.getDic("lbl_ReservationView_03"), showRepeatHTML, "270px","230px","html",true,null,null,true);			//반복 예약 열기
			}else if(mode == "Webpart"){
				Common.open("","resource_detail_pop",Common.getDic("lbl_DetailView"),'/groupware/resource/goResourceDetailPopup.do?CLSYS=resource&CLMD=user&CLBIZ=Resource'			//상세보기
						+ '&eventID=' + eventID 
						+ '&dateID=' + dateID 
						+ "&repeatID=" + repeatID
						+ '&isRepeat=' + isRepeat 
						+ '&resourceID=' + resourceID
						+ '&isPopupView=Y',"1050px","632px","iframe",true,null,null,true);
			}else{
				CoviMenu_GetContent("resource_DetailView.do?CLSYS=resource&CLMD=user&CLBIZ=Resource"
						+ "&eventID=" + eventID
						+ "&dateID=" + dateID
						+ "&repeatID=" + repeatID
						+ "&isRepeat=" + isRepeat
						+ "&resourceID=" + resourceID);
			}
		},
		//자원 정보 표시
		setResourceInfo : function(mode, folderID, bookingData){
			// 자원 정보
			//개별호출-일괄호출
			Common.getDicList(["lbl_Res_Div","lbl_PlaceOfBusiness","lbl_resource_rentalTime","lbl_Res_Admin","lbl_ReservationProc"
			                   ,"lbl_Equipment","lbl_DescriptionURL","lbl_Description","lbl_noexists","lbl_resource_leastMin"
			                   ,"lbl_ProfilePhoto","btn_Returnrequest","lbl_Approval","lbl_Deny","btn_CheckReturn","btn_CancelApproval","msg_apv_030",
			                   "lbl_ReturnProc"]);
			
			$.ajax({
			    url: "/groupware/resource/getResourceData.do",
			    type: "POST",
			    data: {
			    	"FolderID" : folderID
				},
			    success: function (res) {
			    	if(res.status == "SUCCESS"){
			    		var infoHTML = "";
			    		
			    		if(mode == "W")
				    		infoHTML += '<div class="inPerView type03 inPerInfoView">';
			    		else
				    		infoHTML += '<div class="makeMoreInput boradBlueBox">';
			    		
			    		infoHTML += '<div class="tblBoradDisplay infoDetailView">'+
					    		'<div>'+
					    			'<div class="tit">'+coviDic.dicMap["lbl_Res_Div"]+'</div>'+		//자원분류
					    			'<div class="txt" id="ParentFolderName"></div>'+
					    			'<div class="tit">'+coviDic.dicMap["lbl_PlaceOfBusiness"]+'</div>'+		//사업장
					    			'<div class="txt" id="PlaceOfBusiness"></div>'+
					    		'</div>'+
					    		'<div>'+
					    			'<div class="tit">'+coviDic.dicMap["lbl_resource_rentalTime"]+'</div>'+			//대여시간
					    			'<div class="txt ">'+
					    				'<p id="LeastRentalTime"></p>'+
					    			'</div>'+
					    			'<div class="tit">'+coviDic.dicMap["lbl_Res_Admin"]+'</div>'+				//담당자
					    			'<div class="txt " id="ManagerList">'+
					    			'</div>'+
					    		'</div>'+
					    		'<div>'+
					    			'<div class="tit">'+coviDic.dicMap["lbl_ReservationProc"]+'</div>'+		//예약절차
					    			'<div class="txt">'+
					    				'<p>'+
					    					'<span id="BookingType"></span>'+
					    				'</p>'+
					    			'</div>'+
					    			'<div class="tit">'+coviDic.dicMap["lbl_ReturnProc"]+'</div>'+				//반납절차
					    			'<div class="txt">'+
					    				'<p>'+
					    					'<span id="ReturnType"></span>'+
					    				'</p>'+
					    			'</div>'+
					    		'</div>'+
					    		'<div id="attrAfter">'+
					    			'<div class="tit">'+coviDic.dicMap["lbl_Equipment"]+'</div>'+				//지원장비
					    			'<div class="txt">'+
					    				'<p id="EquipmentList"></p>'+
					    			'</div>'+
					    			'<div class="tit">'+coviDic.dicMap["lbl_DescriptionURL"]+'</div>'+		//부가설명 URL
					    			'<div class="txt">'+
					    				'<p id="DescriptionURL"></p>'+
					    			'</div>'+
					    		'</div>'+
					    		'<div>'+
					    			'<div class="tit">'+coviDic.dicMap["lbl_Description"]+'</div>'+			//설명
					    			'<div class="txt">'+
					    				'<p id="pDescription"></p>'+
					    			'</div>'+
					    		'</div>'+
					    	'</div>'+
					    '</div>';
					    
			    		$("#divInfo").html(infoHTML);
			    		
			    		// Folder Data
			    		if(res.data.folderData){
			    			var folderData = res.data.folderData;
			    			
			    			$("#ResourceName").html(folderData.ResourceName);
			    			
			    			if(folderData.PlaceOfBusiness != "" && folderData.PlaceOfBusiness != undefined){
			    				var placeOfBusinessStr = "";
			    				var placeOfBusinessArr = folderData.PlaceOfBusiness.split(";");
			    				
			    				$("#PlaceOfBusiness").append('<span class="locIcon02"></span>');
			    				
			    				for(var i=0; i<placeOfBusinessArr.length-1; i++){
			    					placeOfBusinessStr = CFN_GetDicInfo($$(Common.getBaseCode("PlaceOfBusiness")).find("CacheData[Code="+placeOfBusinessArr[i]+"]").attr("MultiCodeName"), parent.lang);
			    					
			    					$("#PlaceOfBusiness").append(placeOfBusinessStr);
			    					
			    					if(placeOfBusinessArr.length-2 != i)
			    						$("#PlaceOfBusiness").append(", ");
			    				}
			    			}else{
			    				$("#PlaceOfBusiness").html(coviDic.dicMap["lbl_noexists"]);		//없음
			    			}
			    			
			    			$("#ParentFolderName").html(checkNoData(folderData.ParentFolderName));
			    			
			    			$("#pDescription").html(checkNoData(folderData.Description));
			    		}
			    		
			    		// Resource Data
			    		var resourceData = {}
			    		if(res.data.resourceData){
			    			resourceData = res.data.resourceData;
			    			
			    			$("#BookingType").html(checkNoData(resourceData.BookingType));
			    			$("#ReturnType").html(checkNoData(resourceData.ReturnType));
			    			
			    			$("#DescriptionURL").html(checkNoData(resourceData.DescriptionURL));
			    			
			    			$("#LeastRentalTime").html(coviDic.dicMap["lbl_resource_leastMin"].replace("{0}", resourceData.LeastRentalTime));		//최소 {0}분 이상
			    		}
			    		
			    		var isManager = false;
			    		// Manager List
			    		if(res.data.managerList.length>0){
			    			var managerStr = "";
			    			$(res.data.managerList).each(function(i){
			    				var subjectName = this.SubjectName;
			    				
			    				//담당자 여부 확인
			    				if( (this.UserType == "User" && userCode == this.SubjectCode) ||  (this.UserType == "Group" && this.SubjectCode == sessionObj["GR_Code"]) ){
			    					isManager = true;
			    				}	
			    				
			    				if(i != 0){
			    					managerStr += '<span>,</span>';
			    				}
			    				
			    				managerStr += '<div class="personBox">';
			    				
			    				if(this.UserType == "User"){
			    					managerStr += '<div class="perPhoto">';
			    					managerStr += '<img src="'+coviCmn.loadImage(this.PhotoPath)+'" style="width:100%;height:100%;" alt="'+coviDic.dicMap["lbl_ProfilePhoto"]+'" onerror="coviCmn.imgError(this,true)">';                    //프로필사진
				    				//managerStr += '<img src="../../covicore/resources/images/common/img.jpg" style="width:100%;height:100%;" alt="'+coviDic.dicMap["lbl_ProfilePhoto"]+'">';		//프로필사진
				    				
				    				managerStr += '</div>';
				    				
				    				subjectName = subjectName + " " + this.UserPositionName + " (" + this.UserDeptName + ")";
			    				}
			    				
			    				managerStr += '<p class="name">';
			    				managerStr += '<span>'+subjectName+'</span>';
			    				managerStr += '</p>';
			    				managerStr += '</div>';
			    				
			    			});
			    			$("#ManagerList").html(managerStr);
			    		}else{
			    			$("#ManagerList").html(coviDic.dicMap["lbl_noexists"]);		// 없음
			    		}
			    		
			    		var actionBtn = "";
			    		var isRepeatAll = coviCmn.isNull(CFN_GetQueryString("isRepeatAll"),"N");

		    			if(mode == "R"  && ( bookingData.RegisterCode == userCode || bookingData.OwnerCode == userCode   )
		    				&&	( resourceData.ReturnTypeCode.toUpperCase()  == "CHARGECONFIRM" && bookingData.ApprovalStateCode.toUpperCase() == "APPROVAL" && (g_currentTime >= new Date(replaceDate(bookingData.StartDateTime))) ) 
		    			){
		    				actionBtn += ' <a onclick="resourceUser.modifyBookingState(\'ReturnRequest\', ' + bookingData.EventID + ', ' + bookingData.DateID + ', ' + bookingData.ResourceID + ', \'' + isRepeatAll + '\');" class="btnTypeDefault">'+coviDic.dicMap["btn_Returnrequest"]+'</a>';		//반납요청
		    			}
			    		
			    		if(mode == "R" && isManager){
			    			if(bookingData.ApprovalStateCode.toUpperCase() == "APPROVALREQUEST"){
			    				actionBtn += '<a onclick="parent.resourceUser.modifyBookingState(\'Approval\', ' + bookingData.EventID + ', ' + bookingData.DateID + ', ' + bookingData.ResourceID + ', \'' + isRepeatAll + '\');" class="btnTypeDefault right">'+coviDic.dicMap["lbl_Approval"]
			    				+'</a><a onclick="resourceUser.modifyBookingState(\'Reject\', ' + bookingData.EventID + ', ' + bookingData.DateID + ', ' + bookingData.ResourceID + ', \'' + isRepeatAll + '\');" class="btnTypeDefault left">'+coviDic.dicMap["lbl_Deny"]+'</a>';		//승인, 거부
							}
							else if(bookingData.ApprovalStateCode.toUpperCase() == "RETURNREQUEST"){
								actionBtn += '<a onclick="resourceUser.modifyBookingState(\'ReturnComplete\', ' + bookingData.EventID + ', ' + bookingData.DateID + ', ' + bookingData.ResourceID + ', \'' + isRepeatAll + '\');" class="btnTypeDefault">'+coviDic.dicMap["btn_CheckReturn"]+'</a>';			//반납확인
							}
							else if(bookingData.ApprovalStateCode.toUpperCase() == "APPROVAL"){
								actionBtn += '<a onclick="resourceUser.modifyBookingState(\'ApprovalDeny\', ' + bookingData.EventID + ', ' + bookingData.DateID + ', ' + bookingData.ResourceID + ', \'' + isRepeatAll + '\');" class="btnTypeDefault">'+coviDic.dicMap["btn_CancelApproval"]+'</a>';			//승인취소
							}
			    		}

			    		$("#divBtnBottom").prepend(actionBtn);
			    		$("#btnList").after(actionBtn);
			    		
			    		// Attribute List
			    		if(res.data.attributeList.length>0){
			    			var attributeStr = "";
			    			$(res.data.attributeList).each(function(i){
			    				if((i+1)%2 != 0)
			    					attributeStr += '<div>';
			    				attributeStr += '<div class="tit">'+this.AttributeName+'</div>';
			    				attributeStr += '<div class="txt"><p>'+this.AttributeValue+'</p></div>';
			    				
			    				if((i+1)%2 == 0 || (res.data.attributeList.length%2 != 0 && res.data.attributeList.length==(i+1)))
			    					attributeStr += '</div>';
			    			});
			    			$("#attrAfter").before(attributeStr);
			    		}
			    		
			    		// Equipment List
			    		if(res.data.equipmentList.length>0){
			    			$(res.data.equipmentList).each(function(){
			    				$("#EquipmentList").append('<span class="btnType02 btnNormal">'+this.EquipmentName+'</span>');
			    			});
			    		}else{
			    			$("#EquipmentList").html(coviDic.dicMap["lbl_noexists"]);		// 없음
			    		}
			    		
			    	} else {
						Common.Error(coviDic.dicMap["msg_apv_030"]);		// 오류가 발생했습니다.
					}
			    },
			    error:function(response, status, error){
					CFN_ErrorAjax("/groupware/resource/getResourceData.do", response, status, error);
				}
			});
			
			// 자원 확장필드 설정
			resourceUser.setUserFormOption(folderID);
		},
		//조회화면에서 수정 버튼 이벤트
		modifyResourceEvent : function(){
			var eventID = $("#eventID").val() == undefined ? CFN_GetQueryString("eventID"): $("#eventID").val();
			var dateID = $("#dateID").val() == undefined ? CFN_GetQueryString("dateID"): $("#dateID").val();
			var isRepeat = $("#isRepeat").val() == undefined ? CFN_GetQueryString("isRepeat"): $("#isRepeat").val();
			var resourceID = $("#resourceID").val() == undefined ? CFN_GetQueryString("resourceID") : $("#resourceID").val();
			var repeatID = $("#repeatID").val() == undefined ? CFN_GetQueryString("repeatID") : $("#repeatID").val();
			
			if(isRepeat == "Y"){
				var showRepeatHTML = getRepeatAllOROnlyHTML("U", eventID, dateID, resourceID, repeatID);
				Common.open("","showRepeat",Common.getDic("lbl_ReservationView_03"), showRepeatHTML, "270px","230px","html",true,null,null,true);			//반복 예약 열기
			}else{
				CoviMenu_GetContent('resource_DetailWrite.do?CLSYS=resource&CLMD=user&CLBIZ=Resource'
						+"&eventID="+eventID
						+"&dateID="+dateID
						+"&isRepeat="+isRepeat
						+"&repeatID=" + repeatID
						+"&resourceID=" + resourceID);
			}
		},
		// 자원예약 상태 변경
		modifyBookingState : function(approvalState, eventID, dateID, resourceID, IsRepeatAll){
			$.ajax({
			    url: "/groupware/resource/modifyBookingState.do",
			    type: "POST",
			    data: {
			    	"ApprovalState" : approvalState,
			    	"EventID" : eventID,
			    	"DateID" : dateID,
			    	"ResourceID" : resourceID,
			    	"IsRepeatAll" : IsRepeatAll
				},
			    success: function (res) {
			    	if(res.status == "SUCCESS"){
			    		var lastURL =  typeof(g_lastURL) == "undefined"?  parent.g_lastURL : g_lastURL;
			    		
			    		if(IsRepeatAll == "Y"){
			    			if(res.failCnt > 0){
			    				var warMsg = "";
			    				
			    				$.each(res.result,function(idx,obj){
			    					if(obj.retType != 'SUCCESS'){
			    						warMsg += obj.StartDateTime + " ~ " + obj.EndDateTime + ": " + obj.retMsg + "\n";
			    					}
			    				});
		    					Common.Warning(warMsg + "\n" + Common.getDic("msg_noProcessList"),"Warning", function(){ //위 항목은 제외하고 처리되었습니다.
		    						parent.CoviMenu_GetContent(lastURL);
		    					}); 
			    			}else{
			    				parent.Common.Inform(Common.getDic("msg_apv_alert_006"), "Information", function(){		//성공적으로 처리되었습니다.
			    					parent.CoviMenu_GetContent(lastURL);
			    				});
			    			}
			    		}else{
			    			if(res.result[0].retType == "SUCCESS"){
			    				parent.Common.Inform(Common.getDic("msg_apv_alert_006"), "Information", function(){		//성공적으로 처리되었습니다.
			    					parent.CoviMenu_GetContent(lastURL);
			    				});
			    			}else{
			    				parent.Common.Warning(res.result[0].retMsg, "Warning", function(){		//성공적으로 처리되었습니다.
			    					parent.CoviMenu_GetContent(lastURL);
			    				});
			    			}
			    		}
			    	} else {
			    		parent.Common.Error(Common.getDic("msg_apv_030"));		// 오류가 발생했습니다.
			    	}
			    },
			    error:function(response, status, error){
			    	parent.CFN_ErrorAjax("/groupware/resource/modifyBookingState.do", response, status, error);
			    }
			});
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
				
				if($("#IsRepeat").val() == "Y" || mode != "DU")
					$("#detailDateCon").html("<span>" + getRepeatConfigMessage(repeatInfo) + "</span>");
				
				if($("#IsRepeat").val() == "N" && mode == undefined || mode != "DU")
					$("#IsRepeat").val("Y");
				
				if(mode != "DU" || $("#IsRepeat").val() == "Y"){
					$("#lbIsAllDay").hide();
				}
			}else{
				$("#IsRepeat").val("N");
				setInputDateContrl();
				
				$("#hidRepeatInfo").val("");
				
				var sDate = $("#hidStartDate").val();
				var eDate = $("#hidEndDate").val();
				
				$("#detailDateCon_StartDate").val(sDate);
				$("#detailDateCon_EndDate").val(eDate);
				
				sHour = $("#hidStartHour").val();
				sMin = $("#hidStartMinute").val();
				eHour = $("#hidEndHour").val();
				eMin = $("#hidEndMinute").val();
				
				coviCtrl.setSelected('detailDateCon [name=startHour]', sHour);
				coviCtrl.setSelected('detailDateCon [name=startMinute]', sMin);
				coviCtrl.setSelected('detailDateCon [name=endHour]', eHour);
				coviCtrl.setSelected('detailDateCon [name=endMinute]', eMin);

				$("#lbIsAllDay").show();
			}
			//PageResize();
		},
		//새로고침
		refresh : function(){
			CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
		},
		//일간보기 업무시간 체크
		changeWorkTime : function(obj){
			g_isWorkTime = $(obj).is(":checked");
			coviCmn.setCookie("useWorkTime_resource_"+Common.getSession("UR_Code"), String(g_isWorkTime), 3);

			resourceUser.resource_MakeDayCalendar();
		},
		// 예약 되어 있는 날짜에 대해서 표시하기
		setLeftCalendarEvent : function(sYear, sDate, eDate){
			$.ajax({
			    url: "/groupware/resource/getLeftCalendarEvent.do",
			    type: "POST",
			    data: {
					"StartDate": CFN_TransServerTime(sDate.replaceAll(".", "-") + ' 00:00'),
					"EndDate": CFN_TransServerTime(schedule_SetDateFormat(schedule_AddDays(eDate.replaceAll(".", "-"), 1),'-') + ' 00:00'),
			    	"FolderIDs": g_folderList
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
			    	parent.CFN_ErrorAjax("/groupware/resource/getLeftCalendarEvent.do", response, status, error);
			    }
			});
		},
		// 체크 폴더 데이터 세팅
		saveChkFolderListRedis : function(chkList){
			$.ajax({
			    url: "/groupware/resource/saveChkFolderListRedis.do",
			    type: "POST",
			    data: {
			    	"checkList":chkList,
			    	"userCode":userCode
				},
				success: function (res) {
					if(res.status == "FAIL"){
						Common.Error(Common.getDic("msg_apv_030"));		// 오류가 발생했습니다.
					}
				},
			    error:function(response, status, error){
			    	parent.CFN_ErrorAjax("/groupware/resource/saveChkFolderListRedis.do", response, status, error);
			    }
			});
		},
		
		//월간 더보기 
		MonthShowMore : function(obj){
			if(g_viewType=="M"){	//월간보기
				var MonWeekRow = $(obj).closest(".calMonWeekRow");
				var count =  $(obj).closest("tbody").find(".daybar_off:hidden").length; 
				
				if(count>0){
					$(obj).closest("tbody").find(".daybar_off:hidden").show();
				}else{	
					$(obj).closest("tbody").find(".daybar_off:visible").hide();
				}
			};	
		},
		
		// 일간, 주간 더보기 팝업
		setMoreListPopup : function(obj){
			$("#popup").load("/groupware/schedule/getMoreListPopup.do", function(){
				var moreDate;
				var morePopupHtml = ""; 	// 데이터 세팅
				var top = 0, left = 0;

				if(g_viewType == "D" || g_viewType == "W"){			//일간보기, 주간보기
					var targetDay = (g_viewType == "D" ? g_startDate : $(obj).parent().attr("schday"));
					moreDate = schedule_SetDateFormat(targetDay, ".");
					
					var eventIDArr = $(obj).attr("eventid").split(";");
					var dateIDArr = $(obj).attr("dateid").split(";");
					var repeatIDArr = $(obj).attr("repeatid").split(";");
					var folderIDArr = $(obj).attr("folderid").split(";");
					var resourceIDArr = new Array();
					
					//마지막 요소 제거
					eventIDArr.pop();
					dateIDArr.pop();
					repeatIDArr.pop();
					folderIDArr.pop();
					
					resourceIDArr.push($(obj).parent().parent().attr("resourceid"))
					
					// 공유자원 관련으로 목록의 resourceID 말고, 각 자원의 FolderID 정보를 넘긴다.
					var arrayBookingData = resourceUser.getArrayBookingData("S", eventIDArr, dateIDArr, folderIDArr, repeatIDArr);
					
					$.each(arrayBookingData, function(idx, data){
						var title = data.Subject;
						var startDate =new Date(replaceDate(data.StartDateTime));
						var time =  AddFrontZero(startDate.getHours(), 2)+":"+AddFrontZero(startDate.getMinutes(), 2);
						var className = data.RegisterCode == userCode ? "my" : "comp";
						
						if(schedule_SetDateFormat(data.StartDateTime) != schedule_SetDateFormat(data.EndDateTime)){ //시작날짜와 종료날짜가 다를 경우 시간표시 안함                                                                                                    
							morePopupHtml += '<p class="shcMultiDayText '+className+'" onclick="resourceUser.goDetailViewPage(\'\', \''+ this.EventID +'\', \''+ this.DateID +'\', \''+ this.RepeatID +'\', \''+ this.IsRepeat +'\', \''+ this.ResourceID +'\');"><a><span style="color:white; font-weight: 700">'+title+'</span></a></p>';		//onclick="'+$(this).attr("onclick")+'"
						}else{
							morePopupHtml += '<p class="shcMultiDayText '+className+'" onclick="resourceUser.goDetailViewPage(\'\', \''+ this.EventID +'\', \''+ this.DateID +'\', \''+ this.RepeatID +'\', \''+ this.IsRepeat +'\', \''+ this.ResourceID +'\');"><a><span style="color:white;">'+time+'</span></a><a><span style="color:white;">'+title+'</span></a></p>';		//onclick="'+$(this).attr("onclick")+'"
						}
					});
					
					left = $(obj).offset().left - $(".cRContBottom").offset().left;
			        top = $(obj).offset().top - $(".cRContBottom").offset().top + pxToNumber($((g_viewType == "D" ? ".reserTblCont tr:first-child td" : ".reserTblWeekly .reserTbl div")).css("height"));
					
				}
			
				// 날짜 세팅
				$("#moreDate").html(moreDate);
				$("#moreWeekOfDay").html(getWeekOfDayValue(moreDate));
				$("#moreListDiv").html(morePopupHtml);
				
				// Top, Left 세팅
				if(left > ($(".cRContBottom").width() - ($("#moreListPop").width() + 20))){
		        	left = $(".cRContBottom").width() - ($("#moreListPop").width() + 20);
		        }
				
				$(this).find("aside").css("top", top + "px");
				$(this).find("aside").css("left", left + "px");	
			});
		},
		
		// 엑셀 다운로드
		excelDownload : function() {
			var subject = $("#searchSubject").val();
			var register = $("#serachRegister").val();
			var approvalState = $("#searchApprovalState option:selected").val();
			var dateType = $("#searchDateType option:selected").val();
			var sDate = g_startDate;
			var eDate = g_endDate;
			
			var searchStartDate = $("#searchDateCon_StartDate").val();
			var searchEndDate = $("#searchDateCon_EndDate").val();
			
			if(searchStartDate != "" && searchEndDate != ""){
				sDate = searchStartDate;
				eDate = schedule_SetDateFormat(schedule_AddDays(searchEndDate, 1), '.');
			}
			
			var params = {
					"mode" : g_viewType,
					"FolderID" : g_folderList,
					"StartDate" : sDate.replaceAll(".", "-"),
					"EndDate" : eDate.replaceAll(".", "-"),
					"searchDateType" : dateType,
					"Subject" : subject,
					"RegisterName" : register,
					"ApprovalState" : approvalState
			};
			
			if (g_viewType == 'List') {	// 목록보기
				ajax_download('/groupware/resource/excelDownload.do', params);	// 엑셀 다운로드 post 요청
			} else {
				alert('구현 중 입니다.');
			}
		},
		// 자원 신청 철회 함수
		callDeleteResourceEvent : function(eventID, dateID, resourceID, isRepeat, isRepeatAll, folderID, repeatID){
			if(isRepeat == "Y" && CFN_GetQueryString("isRepeatAll") == "undefined"){
				var showRepeatHTML = getRepeatAllOROnlyHTML('D', eventID, dateID, folderID, repeatID);
				Common.open("", "showRepeat", Common.getDic("lbl_ReservationView_03"), showRepeatHTML, "270px", "230px", "html", true, null, null, true); // 반복 예약 열기
			}else{
				if(isRepeatAll == "N" && CFN_GetQueryString("isRepeatAll") == "Y")
					isRepeatAll = "Y";
				
				resourceUser.modifyBookingState('ApprovalCancel', eventID, dateID, resourceID, isRepeatAll);
			}
		}
}

//resourceUser.setAclEventFolderData();


function btnSurMoveOnClick(obj){
	if($(obj).hasClass('active')){
		$(obj).removeClass('active');
		
		$('.makeMoreInput').eq($( ".btnSurMove" ).index( this )).removeClass('active');
	}else {
		$(obj).addClass('active');
		$('.makeMoreInput').eq($( ".btnSurMove" ).index( this )).addClass('active');
	}
}
function btnOnOffOnClick(obj){
	if($(obj).hasClass('active')){
		$(obj).removeClass('active');
		$(obj).closest('.selOnOffBox').next().removeClass('active');
		
	}else {
		$(obj).addClass('active');
		$(obj).closest('.selOnOffBox').next().addClass('active');
	}
}
function scheduleOnOffBtnOnClick(obj){
	if($(obj).hasClass('active')){
		$(obj).removeClass('active');
	}else {
		$(obj).addClass('active');		
	}
}

function checkNoData(value){
	if(value == "" || value == undefined)
		return Common.getDic("lbl_noexists");		// 없음
	else
		return value;
}

//엑셀 다운로드 post 요청
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

function AttendOnClick(Obj) {
	if($("#AttendeeYN").hasClass("on")) {
		$("#AttendeeYN").removeClass("on")
		$(".autoCompleteCustom").hide();
		$(".ui-autocomplete-multiselect-item").remove();
	}
	else{
		$("#AttendeeYN").addClass("on")
		$(".autoCompleteCustom").show();
	}
}

function convertFileSize(pSize) {
	var sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
    if (pSize == 0) return 'n/a';
    var i = parseInt(Math.floor(Math.log(pSize) / Math.log(1024)));
    return (pSize / Math.pow(1024, i)).toFixed(1) + sizes[i];
}
