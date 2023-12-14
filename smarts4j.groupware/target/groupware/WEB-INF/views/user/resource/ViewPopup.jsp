<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<!DOCTYPE html>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<div class="layer_divpop ui-draggable boradPopLayer" id="testpopup_p" style="width:1060px" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">
		<div class="popContent layerType02">
			<div class="cRConTop titType">
			    <h2 id="dateTitle" class="title" style="float:left;"></h2>
			    <p class="pagingType02" style="float: left;margin: auto;padding: 12px;">
			        <a class="pre" style="margin-right: 0px;width: 28px;" onclick="clickTopButtonPopup('PREV');"></a><a class="next" style="margin-right: 0px;width: 29px;" onclick="clickTopButtonPopup('NEXT');"></a><a onclick="goCurrent();" class="btnTypeDefault">오늘</a>
			    </p>
			    <!-- 사업장 추가 -->
				<div id="placeOfBusinessSel" style="padding:12px;"></div>
			</div>
			<div class="resourceContent">
				<div class="resourceContScrollTop">
					<div class="resTopCont scheduleTop checkType">
						<ul id="topButton" class="schSelect clearFloat">
							<li id="liDay" class="selected"><a onclick="clickTopButtonPopup('D');"><spring:message code='Cache.lbl_Daily' /></a></li><!-- 일간 -->
							<li id="liWeek"><a onclick="clickTopButtonPopup('W');" ><spring:message code='Cache.lbl_Weekly' /></a></li><!-- 주간 -->
						</ul>
						<div>
							<div class="resCalViewBox">
								<span class="reserComp"><span></span><spring:message code='Cache.lbl_resource_bookingComlete' /></span><span class="myReser"><span></span><spring:message code='Cache.lbl_resource_MyBooking' /></span><!-- 예약완료 --><!-- 나의예약 -->
							</div>
							<button class="btnRefresh" type="button" onclick="resourceUser.refresh();"></button>
						</div>
					</div>
					<div id="DayCalendar" class="resDayListCont" >
						<div class="reserTblContent reserTblTit">
							<div class="chkStyle04">
								<input type="checkbox" id="chkWorkTimeDay" onchange="resourceUser.changeWorkTime(this);"><label for="chkWorkTimeDay"><span></span><spring:message code='Cache.lbl_BusinessTime' /></label><!-- 업무시간 -->
							</div>
							<div class="reserTblView ">
								<table id="headerTimeList" class=" reserTbl"></table>
							</div>
						</div>
						<div id="bodyResourceDay" class="reserTblContent reserTblCont">
						</div>
					</div>
					<div id="WeekCalendar" class="resDayListCont reserTblWeekly" style="display: none">
						<div class="reserTblContent reserTblTit">
							<div class="chkStyle04">
								<span><spring:message code='Cache.lbl_Res_Name' /></span><!-- 자원명 -->
							</div>
							<div class="reserTblView ">
								<table class=" reserTbl">
									<colgroup>
										<col width="16.6%"/>
										<col width="16.6%"/>
										<col width="16.6%"/>
										<col width="16.6%"/>
										<col width="16.6%"/>
										<col width="16.6%"/>
										<col width="16.6%"/>
										<col width="16.6%"/>
										<col width="16.6%"/>
										<col width="16.6%"/>
										<col width="16.6%"/>
										<col width="16.6%"/>
										<col width="16.6%"/>
										<col width="16.6%"/>
									</colgroup>
									<tbody id="headerDayList">
									</tbody>
								</table>
							</div>
						</div>
						<div id="bodyResourceWeek" class="reserTblContent reserTblCont">
						</div>
					</div>
					<article id="popup" >
		    		</article>
		    		<div style="margin-top: 20px;text-align: center;">
						<a id="SaveResourceToScheduleBtn" onclick="setResourceToSchedule();" class="btnTypeDefault btnTypeBg"><spring:message code='Cache.btn_Confirm' /></a><!-- 확인 -->
						<a onclick="Common.Close();" class="btnTypeDefault"><spring:message code='Cache.btn_Close' /></a><!-- 닫기 -->
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
<script>

	//FolderList 세팅. 권한 있는 모든 자원 폴더 가져오기
	if(resAclArray.status != "SUCCESS") {
		resourceUser.setAclEventFolderData();
	}
	
	g_folderList = ";";
	$($$(resAclArray).find("read").has("[FolderType!=Root][FolderType!=Folder]").concat().attr("FolderID")).each(function(){
		g_folderList += this + ";";
	});
	
	var eventDataList = {};
	
	initContent();
	
	function initContent(){
		
		if(CFN_GetQueryString("onlyView") == "Y"){
			$("#SaveResourceToScheduleBtn").hide();			
		}
		
		resourceUser.initJS();
		
		resourceUser.fn_resourceView_onload();
		
		// 사업장 사용 여부
		if((Common.getBaseConfig("IsUsePlaceOfBusinessSel") == "N")){
			$("#placeOfBusinessSel").hide();
			
			if(g_viewType == "D"){
				resourceUser.resource_MakeDayCalendar();
			}else if(g_viewType == "W"){
				resourceUser.resource_MakeWeekCalendar();
			}
		}else{
			$("#placeOfBusinessSel").show();
			setPlaceOfBusiness();
		}

		
		// 스타일 조정
		// 목록에서 월간, 목록 사라지면서 스타일 조정
		$(".schSelect").css("width", "144px");
		$(".schSelect").css("margin-left", "-73px");
		$(".schSelect > li:last-child").css("width", "72px");
		
		// 스크롤 생기도록 스타일 조정
		$("#bodyResourceDay").css("height", "290px");
		$("#bodyResourceDay").css("overflow-y", "auto");
		$("#bodyResourceWeek").css("height", "232px");
		$("#bodyResourceWeek").css("overflow-y", "auto");
		$(".resourceContent").css("padding", "0");
		
		
		//개별호출 일괄호출 (다국어)
		Common.getDicList(["lbl_WPSun","lbl_WPMon","lbl_WPTue","lbl_WPWed","lbl_WPThu","lbl_WPFri","lbl_WPSat","lbl_AM","lbl_PM"]);
		
		Common.toResizeDynamic('resource_pop', 'testpopup_p');
	}
	
	function clickTopButtonPopup(liType){
		var sDate = "";
		var eDate = "";
		
		var startDateObj = new Date(replaceDate(g_startDate));
		
		if(liType == "D"){		//일간 보기
			if(g_startDate == "" || g_startDate == undefined || (g_viewType == "W" && (new Date(replaceDate(g_startDate)).getTime() <= new Date().getTime() && new Date(replaceDate(g_endDate)).getTime() >= new Date().getTime()))){
				sDate = schedule_SetDateFormat(new Date, '.');
				eDate  = sDate;
			}else{
				sDate = g_startDate
				eDate = sDate;
			}
		}
		else if(liType == "W"){		//주간 보기
			var sun = schedule_GetSunday(new Date(replaceDate(g_startDate)));
			sDate = schedule_SetDateFormat(sun, '.');
			eDate = schedule_SetDateFormat(schedule_AddDays(sDate, 6), '.');
		    
		    // 일 -> 주 -> 월을 변경시 달이 바뀌는 것 처리를 위해
            if (sDate.substring(0, 7) != g_startDate.substring(0, 7))
            {
            	sDate = g_startDate.substring(0, 7) + ".01";
            }
		}else if(liType == "PREV")		// 이전
		{
			if(g_viewType == "D"){
				sDate = schedule_SetDateFormat(schedule_AddDays(startDateObj, -1), '.');
				eDate = sDate;
			}else if(g_viewType == "W"){
				sDate = schedule_SetDateFormat(schedule_AddDays(startDateObj, -7), '.');
				eDate = schedule_SetDateFormat(schedule_AddDays(startDateObj, -1), '.');
			}
			liType = g_viewType;
		}else if(liType == "NEXT"){		// 다음
			if(g_viewType == "D"){
				sDate = schedule_SetDateFormat(schedule_AddDays(startDateObj, 1), '.');
				eDate = sDate;
			}else if(g_viewType == "W"){
				sDate = schedule_SetDateFormat(schedule_AddDays(startDateObj, 7), '.');
				eDate = schedule_SetDateFormat(schedule_AddDays(startDateObj, 13), '.');
			}
			liType = g_viewType;
		}
		
		g_startDate = sDate;
		g_endDate = eDate;
		
		g_viewType = liType;
		g_year = g_startDate.split(".")[0];			// 전역변수 세팅
		g_month = g_startDate.split(".")[1];		// 전역변수 세팅
		g_day = g_startDate.split(".")[2];			// 전역변수 세팅
		
		var liID = "";
		if(g_viewType == "D"){
			$("#WeekCalendar,#MonthCalendar,#List").hide();
			$("#DayCalendar").show();
			liID = "liDay";
			
			resourceUser.resource_MakeDayCalendar();
		}else if(g_viewType == "W"){
			$("#DayCalendar,#MonthCalendar,#List").hide();
			$("#WeekCalendar").show();
			liID = "liWeek";
			
			resourceUser.resource_MakeWeekCalendar();
		}
		
		$("#topButton").find("li").removeClass("selected");
		$("#"+liID).addClass("selected");
	}
	
	function goCurrent(){
		g_startDate = schedule_SetDateFormat(g_currentTime, ".");
		g_year = g_startDate.split(".")[0];			// 전역변수 세팅
		g_month = g_startDate.split(".")[1];		// 전역변수 세팅
		g_day = g_startDate.split(".")[2];			// 전역변수 세팅
		
		clickTopButtonPopup(g_viewType);
	}
	
	// 확인 버튼 클릭시
	function setResourceToSchedule(){
		/* parent.$("#resourceAutoComp").find("[class=ui-autocomplete-multiselect-item]").remove();
		
		$("[name=chkResourceFolder]:checked").each(function(){
			var resFolderID = $(this).val();
			var resName = $(this).attr("label");
			
			var resourceObj = $("<div></div>")
            .addClass("ui-autocomplete-multiselect-item")
            .attr("data-json", JSON.stringify({"label":resName,"value":resFolderID}))
            .attr("data-value", resFolderID)
            .text(resName)
            .append(
                $("<span></span>")
                    .addClass("ui-icon ui-icon-close")
                    .on('click', function(){
                        var item = $(this).parent();
                        item.remove();
                    })
            );
			//parent.$("#resourceAutoComp .ui-autocomplete-multiselect").prepend(resourceObj);
			parent.$(resourceObj).insertBefore("#Resource");
		});
		 */
		 
		parent.scheduleUser.setResourceToSchedule($("[name=chkResourceFolder]:checked"));
		Common.Close();
	}
	
	// 사업장 Select Box 세팅
	
	function setPlaceOfBusiness() {
		var lang = Common.getSession("lang");
		var initInfos = [ {
			target : 'placeOfBusinessSel',
			codeGroup : 'PlaceOfBusiness',
			defaultVal : 'PlaceOfBusiness',
			width : '160',
			onchange : 'onchangePlaceOfBusiness'
		} ];
		coviCtrl.renderAjaxSelect(initInfos, '', lang);
		onchangePlaceOfBusiness();
	}
	// 사업장 Select Box 변경시
	function onchangePlaceOfBusiness() {
		placeOfBusinessSchedule = coviCtrl.getSelected('placeOfBusinessSel').val;
		if (placeOfBusinessSchedule == "PlaceOfBusiness") {
			placeOfBusinessSchedule = "";
		}
		
		if (g_viewType == "D") {
			resourceUser.resource_MakeDayCalendar();
		} else if (g_viewType == "W") {
			resourceUser.resource_MakeWeekCalendar();
		}
	}
</script>