<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8" import="egovframework.coviframework.util.RedisDataUtil,egovframework.covision.groupware.attend.user.util.AttendUtils"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<%@ page import="egovframework.coviframework.util.ComUtils"%>
<%@ page import="egovframework.coviframework.util.DicHelper"%>
<%
	String userNowDate = ComUtils.GetLocalCurrentDate("yyyy-MM-dd");
%>

<div class="cRConTop ATMTop titType">
	<h2 class="title"></h2>
	<div class="pagingType02">
		<a href="#" class="pre dayChg" data-paging="-"></a>
		<a href="#" class="next dayChg" data-paging="+"></a>
		<a href="#" class="btnTypeDefault calendartoday"><spring:message code='Cache.lbl_Todays'/></a>
		<a href="#" class="calendarcontrol btnTypeDefault cal"></a>
		<input type="text" id="inputCalendarcontrol" style="height: 0px; width:0px; border: 0px;" >
	</div>
	<div class="ATM_filter_wrap">
		<div class="addFuncBox">
			<a class="btn_slide_close" href="#"><spring:message code='Cache.lbl_close' /></a>
		</div>
		<div class="addFuncBox" name="imNoSeenHidden">
			<a href="#" class="btnTypeDefault_r middle1 ATMico_filter viewOptions" name="aFilterNameTag"><spring:message code='Cache.lbl_Filter' /></a>
			<ul class="addFuncLilst_normal right">
				<li class="contentcheck active" value=""><a href="#"><span class="check_txt"><spring:message code='Cache.lbl_ViewAll' /></span><span class="fil checkico"></span></a></li>
				<li class="contentcheck" value=""><a href="#"><span class="check_txt"><spring:message code='Cache.lbl_n_att_attendStatusView' /></span><span class="fil"></span></a></li>
				<li class="contentcheck" value=""><a href="#"><span class="check_txt"><spring:message code='Cache.lbl_n_att_attendScheduleView' /></span><span class="fil"></span></a></li>
			</ul>
		</div>
	</div>
	<div class="ATMTop_info_wrap">
		<div class="ATMTop_info_Time">
			<p class="ATMTime_title"><span><spring:message code='Cache.lbl_att_workTime' /></span></p>
			<dl class="ATMTime_dl">
				<dt><spring:message code='Cache.lbl_n_att_totWorkTime' /></dt>
				<dd><span class="tx_normal" id="totWorkTime"></span></dd>
			</dl>
			<dl class="ATMTime_dl">
				<dt><spring:message code='Cache.lbl_n_att_acknowledgedWork' /></dt>
				<dd><span class="tx_normal" id="workTime"></span></dd>
			</dl>
			<dl class="ATMTime_dl">
				<dt><spring:message code='Cache.lbl_att_overtime_work' /></dt>
				<dd><span class="tx_ex" id="exTime"></span></dd>
			</dl>
			<dl class="ATMTime_dl">
				<dt><spring:message code='Cache.lbl_att_holiday_work' /></dt>
				<dd><span class="tx_holy" id="hoTime"></span></dd>
			</dl>
			<dl class="ATMTime_dl">
				<dt><spring:message code='Cache.lbl_n_att_AttRealTime' /></dt>
				<dd><span class="tx_holy" id="confTime"></span></dd>
			</dl>
			<dl class="ATMTime_dl">
				<dt><spring:message code='Cache.lbl_n_att_remainWork' /></dt>
				<dd><span class="tx_normal" id="remainTime"></span></dd>
			</dl>
		</div>
		<div class="ATMTop_info_Date">
			<p class="ATMDate_title"><span><spring:message code='Cache.lbl_n_att_workingDay' /></span></p>
			<dl class="ATMDate_dl">
				<dt><spring:message code='Cache.lbl_n_att_fixedWorkingDay' /></dt>
				<dd><span class="tx_cont" id="workDay"></span></dd>
			</dl>
			<dl class="ATMDate_dl">
				<dt><spring:message code='Cache.lbl_n_att_normalWork' /></dt>
				<dd><span class="tx_cont" id="workingDay"></span></dd>
			</dl>
		</div>
	</div>
</div>
<div class='cRContBottom ATMTop mScrollVH ATMday'>
	<!-- 컨텐츠 시작 -->
	<div class="ATMCont">
		<div class="ATMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<span class="btnLayerWrap">
					<a href="#" class="btnTypeDefault  btnTypeBg btnDropdown btnIcon1"><spring:message code='Cache.lbl_att_work' /><%=AttendUtils.getRequestName(RedisDataUtil.getBaseConfig("WorkCreateMethod"))%></a>
					<div class="btnDropdown_layer" style="display:none;z-index:999999;">
						<ul class="btnDropdown_layer_list">
							<li><a href="#" onclick='AttendUtils.openSchedulePopup()'><spring:message code='Cache.lbl_n_att_selectWorkSchTemp' /></a></li>
							<li><a href="#" onclick='AttendUtils.openOverTimePopup()'><spring:message code='Cache.lbl_att_overtime_work' /> <%=AttendUtils.getRequestName(RedisDataUtil.getBaseConfig("ExtenReqMethod"))%></a></li>
							<li><a href="#" onclick='AttendUtils.openHolidayPopup()'><spring:message code='Cache.lbl_att_holiday_work' /> <%=AttendUtils.getRequestName(RedisDataUtil.getBaseConfig("HoliReqMethod"))%></a></li>
							<li id="HoliReplReqMethod" style="display: none;"><a href="#" onclick='AttendUtils.openHolidayReplacementPopup()'><spring:message code='Cache.lbl_att_holiday_replacement_work' /></a></li>
							<li><a href="#" onclick='AttendUtils.openCallPopup()'><spring:message code='Cache.lbl_app_calling' /> <%=AttendUtils.getRequestName(RedisDataUtil.getBaseConfig("CommuModReqMethod"))%></a></li>
						</ul>
					</div>
				</span>
				<a href="#" onclick='AttendUtils.openVacationPopup("USER");' class="btnTypeDefault btnIcon2"><spring:message code='Cache.lbl_Vacation' /><%=AttendUtils.getRequestName(RedisDataUtil.getBaseConfig("VacReqMethod"))%></a>
				<span class="btnLayerWrap">
					<a href="#" class="btnTypeDefault btnDropdown "><spring:message code='Cache.lbl_n_att_otherJobReq' /></a>
					<div class="btnDropdown_layer" style="display:none;z-index:999999;">
						<ul class="btnDropdown_layer_list" id="jobList"></ul>
					</div>
				</span>
				<a href="#" class="btnTypeDefault btnExcel" id="excelBtn"><spring:message code='Cache.lbl_SaveToExcel' /></a>
			</div>
			<div class="ATMbuttonStyleBoxRight">
				<ul class="ATMschSelect">
					<li class="pageToggle selected"><a href="#"><spring:message code='Cache.lbl_Weekly' /></a></li>
					<li class="pageToggle"><a href="#"><spring:message code='Cache.lbl_Monthly' /></a></li>
				</ul>
			</div>
		</div>
		<div class="tblList"></div>
	</div>
	<!-- 컨텐츠 끝 -->
</div>

<!-- 내 근태현황 주간 -->
<table class="ATMTable" id="myAttWeekHeader" style="display:none;" cellpadding="0" cellspacing="0">
	<thead>
	<tr>
		<th width="150"><spring:message code='Cache.lbl_date' /></th>
		<th width="120"><spring:message code='Cache.lbl_att_goWork' /></th>
		<th width="120"><spring:message code='Cache.lbl_att_offWork' /></th>
		<th><spring:message code='Cache.lbl_n_att_totWorkTime' /></th>
		<th><spring:message code='Cache.lbl_n_att_acknowledgedWork' /></th>
		<th><spring:message code='Cache.lbl_att_overtime_work' /></th>
		<th><spring:message code='Cache.lbl_att_holiday_work' /></th>
		<th><spring:message code='Cache.lbl_n_att_otherjob_sts' /></th>
		<th><spring:message code='Cache.lbl_n_att_AttRealTime' /></th>
		<th class="td_etc"><spring:message code='Cache.lbl_Remark' /></th>
	</tr>
	</thead>
</table>
<table class="ATMTable" id="myAttWeekTableTemp" cellpadding="0" cellspacing="0" style="display:none;">
	<tbody>
	<tr>
		<td width="150"><div class="date_box"><p class="date_title"></p><a href="#" class="btn_open"></a></div></td>
		<td width="120"></td>
		<td width="120"></td>
		<td></td>
		<td></td>
		<td></td>
		<td></td>
		<td></td>
		<td></td>
		<td class="td_etc"></td>
	</tr>
	</tbody>
</table>
<div class="User_ATMWork_detail_wrap Normal" id="myAttWeekDivTemp" style="display:none;">
	<table class="ATMWork_detail_T" cellpadding="0" cellspacing="0">
		<thead>
		<tr></tr>
		</thead>
		<tbody>
		<tr></tr>
		<tr></tr>
		<tr></tr>
		</tbody>
	</table>
</div>

<div class="User_ATMTable_tfoot_wrap" id="myAttWeekWorkTimeTemp" style="display:none;">
	<table class="ATMTable tfoot" cellpadding="0" cellspacing="0">
		<tfoot>
		<tr>
			<td width="390"><strong><spring:message code='Cache.lbl_n_att_cumulativeTotal' /></strong></td>
			<td><p class="td_time_day"></p></td>
			<td><p class="td_time_day"></p></td>
			<td><p class="td_time_day"></p></td>
			<td><p class="td_time_day"></p></td>
			<td><p class="td_time_day"></p></td>
			<td><p class="td_time_day"></p></td>
			<td class="td_etc"></td>
		</tr>
		<tr>
			<td><strong><spring:message code='Cache.lbl_n_att_remainWorkTime' /></strong>
				<span class="time_info">
						<%=String.format(DicHelper.getDic("lbl_n_att_basedOnHourPerWeek"),RedisDataUtil.getBaseConfig("RemainTimeCode"))%>
					</span>
			</td>
			<td></td>
			<td></td>
			<td></td>
			<td></td>
			<td></td>
			<td><p class="td_time_day"></p></td>
			<td class="td_etc"></td>
		</tr>
		</tfoot>
	</table>
</div>
<!-- 내 근태현황 주간 -->

<!-- 내 근태현황 월간 -->
<div class="ATMUserMonthWrap" id="monthWrap" style="display:none;">
	<div class="calMonHeader">
		<table class="calMonTbl" cellpadding="0" cellspacing="0">
			<tbody>
			<tr></tr>
			</tbody>
		</table>
	</div>
	<div class="calMonBody">
		<div class="calMonWeekRow" style="display:none;">
			<table class="calGrid" cellpadding="0" cellspacing="0">
				<tbody>
				<tr></tr>
				</tbody>
			</table>
			<table class="monShcList" cellpadding="0" cellspacing="0">
				<tbody>
				<tr></tr>
				</tbody>
			</table>
		</div>
	</div>
</div>


<!-- 내 근태현황 럴간 -->

<!-- 기타근무 레이어 팝업 -->
<div id="divJobPopup" style="position:initial;display:none;">
	<div class="ATMgt_Work_Popup" style="width:282px;  position:absolute; z-index:105;right:0">
		<a class="Btn_Popup_close" onclick='AttendUtils.hideAttJobListPopup()'></a>
		<div class="ATMgt_Cont" id="jobListInfo"></div>
		<div class="bottom">
			<a href="#" class="btnTypeDefault" onclick='AttendUtils.hideAttJobListPopup();'><spring:message code='Cache.lbl_close' /></a>
		</div>
	</div>
</div>

<style>
	<!--
	.User_Info{cursor: pointer;}

	.jobNm {float:left;width:100px; }

	.Normal2 {background: #cecece; }
	.Absent {background: #e2e2e2; }
	.Calling {background: #cecece; }

	.WorkBox.Normal2 {background: #cecece; }
	.WorkBox.Absent {background: #e2e2e2;; }
	.WorkBox.Calling {background: #127700eb; }
	.WorkBox.Holyday { background: repeating-linear-gradient(-45deg, #e4e4e4 , #e4e4e4  5px, #fff 0, #fff 10px); }
	.WorkBox.Holyday .tx_title{color: #999;}

	.WorkBox .tx_title{ float : left }
	.WorkBox .tx_time{ float: right; padding: 3px 20px 0px 0px; }

	.ATMTable tbody tr:hover {
		background: #f5f5f5;
	}
	.ATMUserMonthWrap .calMonBody .calMonWeekRow .calGrid tbody tr td:hover{
		background: #f5f5f5;
	}

	-->
</style>
<script type="text/javascript">

	var _pageType = 0;

	var _targetDate = "<%=userNowDate%>";
	var _stDate;
	var _edDate;

	var _wpMon = "<spring:message code='Cache.lbl_WPMon' />";
	var _wpTue = "<spring:message code='Cache.lbl_WPTue' />";
	var _wpWed = "<spring:message code='Cache.lbl_WPWed' />";
	var _wpThu = "<spring:message code='Cache.lbl_WPThu' />";
	var _wpFri = "<spring:message code='Cache.lbl_WPFri' />";
	var _wpSat = "<spring:message code='Cache.lbl_WPSat' />";
	var _wpSun = "<spring:message code='Cache.lbl_WPSun' />";

	//근태 데이터
	var _att;
	var _attMonth;
	var _jobHisList;

	//보기옵션
	var _viewIdx = 0;

	var _commuteTimeYn = Common.getBaseConfig('CommuteTimeYn');

	$(document).ready(function(){
		init();

		//내 근태현황 조회
		getMyAttInfo();
	});

	function init(){
		//기타근무 리스트
		AttendUtils.getOtherJobList('Y', 'USER');

		if(Common.getBaseConfig("HoliReplReqMethod") == "Y")
			$("#HoliReplReqMethod").show();

		//날짜paging
		$(".dayChg").on('click',function(){
			dayChg($(this).data("paging"));
			getMyAttInfo();
		});

		//표기/정렬 필터 리스트
		$(".viewOptions").on('click',function(){
			if($(this).parent().attr('class').indexOf('active') > -1){
				$(this).parent().removeClass('active');
			}else{
				$(this).parent().addClass('active');
			}
		});

		//표기 필터
		$(".contentcheck").on('click',function(){
			_viewIdx = $(this).index();

			$(".contentcheck").removeClass('active');
			$(".contentcheck .fil").removeClass('checkico');

			$(this).addClass('active');
			$(this).find('.fil').addClass('checkico');
			if(_pageType==0){
				setWeekHtml();
			}else if(_pageType==1){
				setMonthHtml();
			}
		});

		//주간/월간
		$(".pageToggle").on('click',function(){
			$(".pageToggle").attr("class","pageToggle");
			$(this).attr("class","selected pageToggle");
			_pageType = $(this).index();
			getMyAttInfo();
		});

		//근무신청
		$(".btnDropdown").on('click',function(){
			var j = $(".btnDropdown_layer").index($(this).next());  // 존재하는 모든 버튼을 기준으로 index
			$(".btnDropdown_layer:not(:eq("+j+"))").hide();
			$(this).next().toggle();
		});

		//달력 검색
		setTodaySearch();

		$("#excelBtn").on('click',function(){
			$('#download_iframe').remove();
			var url = "/groupware/attendUserSts/excelDownloadForAttMyStatus.do";
			var params = {
				dateTerm	: _pageType==0?"W":_pageType==1?"M":null
				,targetDate	: _targetDate
			};
			ajax_download(url, params);	// 엑셀 다운로드 post 요청
		});

		Aslide();
	}

	$(document).on("mouseenter",".Btn_pop",function() {
		if($(this).closest("td").find('.smallPop').is(':hidden')){
			$(this).closest("td").find('.smallPop').slideDown();
		}
	});

	$(document).on("mouseleave",".Btn_pop",function() {
		$(this).closest("td").find('.smallPop').slideUp();
	});

	$(document).on("click",".btnDropdown_layer ul li a",function() {
		$(".btnDropdown_layer").hide()
	});



	function refreshList(){
		_targetDate = "<%=userNowDate%>";
		getMyAttInfo();
	}

	function searchList(d){
		_targetDate = d;
		getMyAttInfo();
	}

	function dayChg(t){
		if("+"==t){
			_targetDate = _edDate;
		}else if("-"==t){
			_targetDate = _stDate;
		}
	}

	function getMyAttInfo(){

		var params = {
			dateTerm : _pageType==0?"W":_pageType==1?"M":null
			,targetDate : _targetDate
		}

		$.ajax({
			type : "POST",
			data : params,
			url : "/groupware/attendUserSts/getMyAttStatus.do",
			success:function (data) {
				if(data.status=="SUCCESS"){
					if(_pageType==0){
						_att = data.attMap;
						_jobHisList = data.jobHisList;
						setWeekHtml();
					}else if(_pageType==1){
						_attMonth =  data.attMonthList;
						setMonthHtml();
					}

				}else{
					Common.Warning("<spring:message code='Cache.msg_sns_03'/>");
				}
			},
			error:function (request,status,error){
				Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
			}
		});
	}

	function setWeekHtml(){
		/* 근태현황 주간 출퇴근 현황  */
		var userAtt = _att.userAtt[0];
		var userAttList = userAtt.userAttList;
		var userAttWorkTime = userAtt.userAttWorkTime;

		//상단 날짜 표시
		$(".title").html(_att.dayTitle);
		_stDate = _att.p_sDate;
		_edDate = _att.p_eDate;

		/* 상단 시간 표시 */
		$("#totWorkTime").html(attTimeFormat(userAttWorkTime.TotWorkTime));
		$("#workTime").html(attTimeFormat(userAttWorkTime.AttRealTime));
		$("#exTime").html(attTimeFormat(userAttWorkTime.ExtenAc));
		$("#hoTime").html(attTimeFormat(userAttWorkTime.HoliAc));
		$("#confTime").html(attTimeFormat(userAttWorkTime.TotConfWorkTime));
		$("#remainTime").html(attTimeFormat(userAttWorkTime.RemainTime));

		$("#workDay").html(userAttWorkTime.WorkDay+"<spring:message code='Cache.lbl_day'/>");
		$("#workingDay").html(userAttWorkTime.NormalCnt+"<spring:message code='Cache.lbl_day'/>");

		/* 근태현황  주간 합계*/
		var workTimeTemp = $("#myAttWeekWorkTimeTemp").clone();
		workTimeTemp = workTimeTemp.removeAttr("style","display:none;");
		workTimeTemp.find("table tr").eq(0).find(".td_time_day").eq(0).html(attTimeFormat(userAttWorkTime.TotWorkTime));	//총 근무시간 합계
		workTimeTemp.find("table tr").eq(0).find(".td_time_day").eq(1).html(attTimeFormat(userAttWorkTime.AttRealTime));	//안정근무 합계
		workTimeTemp.find("table tr").eq(0).find(".td_time_day").eq(2).html(attTimeFormat(userAttWorkTime.ExtenAc));	//연장근무 합계
		workTimeTemp.find("table tr").eq(0).find(".td_time_day").eq(3).html(attTimeFormat(userAttWorkTime.HoliAc));	//휴일근무 합계
		workTimeTemp.find("table tr").eq(0).find(".td_time_day").eq(5).html(attTimeFormat(userAttWorkTime.TotConfWorkTime));	//인정실근무 합계
//	workTimeTemp.find("table tr").eq(0).find(".td_time_day").eq(4).html(userAttWorkTime.JobStsSumTime);	//기타근무 합계
		workTimeTemp.find("table tr").eq(1).find(".td_time_day").eq(0).html(attTimeFormat(userAttWorkTime.RemainTime));	//잔여근무시간

		/* 근태현황 주간 table header  */
		var header = $("#myAttWeekHeader").clone();
		header = header.removeAttr("style","display:none;");
		$(".tblList").html(header);
		$(".tblList").append("<div class='User_ATMTable_wrap' id='myAttStsContents' ></div>");
		/* 근태현황 주간 table header  */

		for(var i=0;i<userAttList.length;i++){
			var tableTemp = $("#myAttWeekTableTemp").clone();
			/*기타근무 시간*/
			var taStatusArray = new Array();

			for(var jh=0;jh<_jobHisList.length;jh++){
				if(_jobHisList[jh].JobDate == userAttList[i].dayList){
					var taJhStartHour = Number(_jobHisList[jh].t_StartHour);
					var taJhStartMin = Number(_jobHisList[jh].v_StartMin);
					var taJhEndHour = Number(_jobHisList[jh].t_EndHour);
					var taJhEndMin = Number(_jobHisList[jh].v_EndMin);

					var taJhArray = setTimeTableArray('N',taJhStartHour,taJhStartMin,taJhEndHour,taJhEndMin);
					var jhData = {
						stsName : _jobHisList[jh].JobStsName
						,stsArray : taJhArray
					}

					taStatusArray.push(jhData);
				}
			}

			tableTemp = tableTemp.removeAttr("style","display:none;");
			tableTemp = tableTemp.removeAttr("id");

			var dateTitle = schedule_SetDateFormat(userAttList[i].dayList,'.');
			var dayHtml = "";
			switch (userAttList[i].weekd){
				case 0 : dayHtml = dateTitle+"("+_wpMon+")" ; break;
				case 1 : dayHtml = dateTitle+"("+_wpTue+")" ; break;
				case 2 : dayHtml = dateTitle+"("+_wpWed+")" ; break;
				case 3 : dayHtml = dateTitle+"("+_wpThu+")" ; break;
				case 4 : dayHtml = dateTitle+"("+_wpFri+")" ; break;
				case 5 : dayHtml = dateTitle+"("+_wpSat+")" ; tableTemp.find(".date_title").attr("class","date_title tx_sat"); break;
				case 6 : dayHtml = dateTitle+"("+_wpSun+")" ; tableTemp.find(".date_title").attr("class","date_title tx_sun"); break;
			}
			tableTemp.find(".date_title").html(dayHtml);	//날짜

			/* 전체 / 누적  / 계획일정 표기 분할  */
			var startTd = tableTemp.find('tr td').eq(1);
			var endTd = tableTemp.find('tr td').eq(2);

			var startDt= "",startDd= "",startClass= "",endDt= "",endDd= "",endClass = "";
			var startTime = "";
			var startTitle = "";
			var endTitle = $('<span />', {
				class : "tx_title"
			});
			var endTime = $('<span />', {
				class : "tx_time"
			});
			//근무제 일정 명 길이 제한
			var spNum = 10;
			var schName = userAttList[i].SchName;
			if(schName == null)
				schName = "";
			else
				schName = userAttList[i].SchName.length > spNum ? userAttList[i].SchName.substring(0,spNum)+".." : userAttList[i].SchName;

			//공통이 맞는지.. 이후 변경
			startTd.append('<dl class="User_Info"></dl>');
			endTd.append('<dl class="User_Info"></dl>');
			if(_viewIdx == 0){	//전체
				if(userAttList[i].StartSts!=null){

					startDt = Common.getDic(userAttList[i].StartSts);
					if(userAttList[i].StartSts == "lbl_n_att_absent"){	//결근
						startClass = 'Absent';
					}else if(userAttList[i].StartSts == "lbl_n_att_callingTarget"){ //소명
						startClass = 'Calling';
						startDt += "<a href='#' class='Btn_Explan'></a>";
					}else{
						if(userAttList[i].StartSts == "lbl_att_beingLate"){	//지각
							startClass = 'Normal2';
							startDt += "<a href='#' class='Btn_Warning'></a>";
						}else{
							startClass = 'Normal';
						}
						startDd = userAttList[i].v_AttStartTime	//출근시간
					}

					if(_commuteTimeYn!='Y'){
						startDd = "";
					}

				}else{
					startClass = 'Holyday';
					startDt = schName;	//근무제
					startDd = userAttList[i].v_AttDayStartTime!=null?userAttList[i].v_AttDayStartTime:'';	//출근일정시간
				}

				if(userAttList[i].EndSts!=null){

					endDt = Common.getDic(userAttList[i].EndSts);
					if(userAttList[i].EndSts == "lbl_n_att_absent"){	//결근
						endClass = 'Absent';
					}else if(userAttList[i].EndSts == "lbl_n_att_callingTarget"){ //소명
						endClass = 'Calling';
						endDt += "<a href='#' class='Btn_Explan'></a>";
					}else{
						if(userAttList[i].EndSts == "lbl_att_leaveErly"){	//조퇴
							endClass = 'Normal3';
							endDt += "<a href='#' class='Btn_Warning2'></a>";
						}else{
							endClass = 'Normal';
						}
						endDd = userAttList[i].v_AttEndTime	//퇴근시간
					}

					if(_commuteTimeYn!='Y'){
						endDd = "";
					}

				}else{
					endClass = 'Holyday';
					endDt = schName;	//근무제
					endDd = userAttList[i].v_AttDayEndTime!=null?userAttList[i].v_AttDayEndTime:'';	//퇴근일정시간
				}

				//연장 근무
				if(userAttList[i].ExtenAc != null && userAttList[i].ExtenAc != ""){
					endClass = "Ex";
					endDt = "<spring:message code='Cache.lbl_att_overtime_work' />";
					if(userAttList[i].ExtenNotEnough == 'N'){
						endDt += "<a href='#' class='Btn_Info'></a>";
					}
					endDd = AttendUtils.maskTime(userAttList[i].v_ExtenEndTime);
				}

			}else if(_viewIdx == 1){	//누적일정 ( 출퇴근 )
				if(userAttList[i].StartSts!=null){
					startDt = Common.getDic(userAttList[i].StartSts);
					if(userAttList[i].StartSts == "lbl_n_att_absent"){	//결근
						startClass = 'Absent';
					}else if(userAttList[i].StartSts == "lbl_n_att_callingTarget"){ //소명
						startClass = 'Calling';
						startDt += "<a href='#' class='Btn_Explan'></a>";
					}else{
						if(userAttList[i].StartSts == "lbl_att_beingLate"){	//지각
							startClass = 'Normal2';
							startDt += "<a href='#' class='Btn_Warning'></a>";
						}else{
							startClass = 'Normal';
						}
						startDd = userAttList[i].v_AttStartTime	//출근시간
					}

					if(_commuteTimeYn!='Y'){
						startDd = "";
					}
				}

				if(userAttList[i].EndSts!=null){

					endDt = Common.getDic(userAttList[i].EndSts);
					if(userAttList[i].EndSts == "lbl_n_att_absent"){	//결근
						endClass = 'Absent';
					}else if(userAttList[i].EndSts == "lbl_n_att_callingTarget"){ //소명
						endClass = 'Calling';
						endDt += "<a href='#' class='Btn_Explan'></a>";
					}else{
						if(userAttList[i].EndSts == "lbl_att_leaveErly"){	//조퇴
							endClass = 'Normal3';
							endDt += "<a href='#' class='Btn_Warning2'></a>";
						}else{
							endClass = 'Normal';
						}
						endDd = userAttList[i].v_AttEndTime	//퇴근시간
					}

					if(_commuteTimeYn!='Y'){
						endDd = "";
					}
				}

				//연장 근무
				if(userAttList[i].ExtenAc != null && userAttList[i].ExtenAc != ""){
					endClass = "Ex";
					endDt = "<spring:message code='Cache.lbl_att_overtime_work' />";
					if(userAttList[i].ExtenNotEnough == 'N'){
						endDt += "<a href='#' class='Btn_Info'></a>";
					}
					endDd = AttendUtils.maskTime(userAttList[i].v_ExtenEndTime);
				}

			}else if(_viewIdx == 2){	//계획일정 ( 근무제 )
				startClass = 'Holyday';
				startDt = schName;	//근무제
				startDd = userAttList[i].v_AttDayStartTime!=null?userAttList[i].v_AttDayStartTime:'';	//출근일정시간

				endClass = 'Holyday';
				endDt = schName;	//근무제
				endDd = userAttList[i].v_AttDayEndTime!=null?userAttList[i].v_AttDayEndTime:'';	//퇴근일정시간
			}

			//휴무일
			if(userAttList[i].WorkSts == "OFF" || userAttList[i].WorkSts == "HOL"){
				startClass = 'Holyday';
				startDt = userAttList[i].WorkSts== "OFF"? "<spring:message code='Cache.lbl_att_sch_holiday' />":"<spring:message code='Cache.lbl_Holiday' />";
				startDd = '';

				endClass = 'Holyday';
				endDt = userAttList[i].WorkSts== "OFF"? "<spring:message code='Cache.lbl_att_sch_holiday' />":"<spring:message code='Cache.lbl_Holiday' />";
				endDd = '';
			}
			//휴가
			if (userAttList[i].VacFlag != null && userAttList[i].VacFlag != "") {
				//연차종류
				if (userAttList[i].VacCnt == "1") {//연차
					startClass = "Vacation";
					startDt = userAttList[i].VacName;
					startDd = "";

					endClass = "Vacation";
					endDt = userAttList[i].VacName;
					endDd = "";
				} else {
					//반차
					var vacAmPmVacDay = userAttList[i].VacAmPmVacDay;
					var arrVacAmPmVacDay = null;
					if(vacAmPmVacDay.indexOf("|")>-1){
						arrVacAmPmVacDay = vacAmPmVacDay.split('|');
					}

					if (userAttList[i].VacOffFlag.indexOf("AM")>-1 && Number(arrVacAmPmVacDay[0])>=0.5) {
						startClass += " Vacation";
						startDt = AttendUtils.vacNameConvertor(userAttList[i].VacOffFlag,userAttList[i].VacName,'AM',0) + (startDt != "" && userAttList[i].StartSts != "lbl_att_normal_goWork" ? "(" + startDt + ")" : "");
					}
					if (userAttList[i].VacOffFlag.indexOf("PM")>-1 && Number(arrVacAmPmVacDay[1])>=0.5) {
						endClass += " Vacation";
						if (userAttList[i].VacOffFlag.indexOf("AM") > -1) {
							endDt = AttendUtils.vacNameConvertor(userAttList[i].VacOffFlag,userAttList[i].VacName,'PM',0) + (endDt != "" && userAttList[i].EndSts != "lbl_att_normal_offWork" ? "(" + endDt + ")" : "");
						} else {
							endDt = AttendUtils.vacNameConvertor(userAttList[i].VacOffFlag,userAttList[i].VacName,'AM',0) + (endDt != "" && userAttList[i].EndSts != "lbl_att_normal_offWork" ? "(" + endDt + ")" : "");
						}
					}
				}

			}

			startTd.addClass(startClass);
			startTd.find('dl').attr('onclick',"AttendUtils.openAttMyStatusPopup('"+userAtt.userCode+"','"+userAttList[i].dayList+"')");
			startTd.find('dl').append('<dt>'+startDt+'</dt>');	//출근상태
			startTd.find('dl').append('<dd>'+startDd+'</dd>');	//출근시간

			endTd.addClass(endClass);
			endTd.find('dl').attr('onclick',"AttendUtils.openAttMyStatusPopup('"+userAtt.userCode+"','"+userAttList[i].dayList+"')");
			endTd.find('dl').append('<dt>'+endDt+"</dt>");//퇴근상태
			if (taStatusArray.length>0 || endClass == "Ex")
				endTd.find('dl dt').append('<a class="Btn_Overlap Btn_pop" href="#"></a>');

			endTd.find('dl').append('<dd>'+endDd+'</dd>');	//퇴근시간

			var tootipHtml ='<div class="smallPop" style="display: none;"><ul>';
			for(var s=0;s<taStatusArray.length;s++){
				var taStatus = taStatusArray[s];
				var statusName = taStatus.stsName;
				var statusArray = taStatus.stsArray;

				tootipHtml+='	<li><a href="#" class="color1">'+statusName+'</a></li>';
			}
			if (endClass == "Ex"){
				tootipHtml+='	<li><a href="#" class="color2"><spring:message code="Cache.lbl_att_overtime_work" /></a></li>';
			}
			endTd.append(tootipHtml+'</ul></div>');

			/*근무시간*/
			var jobHtml = "";
			if(userAttList[i].jh_JobStsName != null && userAttList[i].jh_JobStsName != ''){
				jobHtml = "<p class='td_status'><a href='#' data-usercode='"+userAtt.userCode+"' data-targetdate='"+userAttList[i].dayList+"' onclick='showJobList(this);'>"+userAttList[i].jh_JobStsName+"</a></p>";

			}

			tableTemp.find('tr td').eq(3).html("<p class='td_time_day'>"+AttendUtils.convertSecToStr(userAttList[i].TotWorkTime,"H")+"</p>");
			tableTemp.find('tr td').eq(4).html("<p class='td_time_day'>"+AttendUtils.convertSecToStr(userAttList[i].AttRealTime,"H")+"</p>");
			tableTemp.find('tr td').eq(5).html("<p class='td_time_day'>"+AttendUtils.convertSecToStr(userAttList[i].ExtenAc,"H")+"</p>");
			tableTemp.find('tr td').eq(6).html("<p class='td_time_day'><dl class='User_Info'><dt>"+AttendUtils.convertSecToStr(userAttList[i].HoliAc,"H")+
					(userAttList[i].HoliNotEnough == 'N' && userAttList[i].HoliAc > 0?"<a href='#' class='Btn_Info'></a>":"")+	"</dt></dl></p>");
			tableTemp.find('tr td').eq(7).html(jobHtml);
			tableTemp.find('tr td').eq(8).html("<p class='td_time_day'>"+AttendUtils.convertSecToStr(userAttList[i].AttRealConfTime,"H")+"</p>");

			var coreTime = $('<p />', {
				class : "td_time_day"
				,text : userAttList[i].CoreTime==null?'':userAttList[i].CoreTime
			});	//시
			var coreTimeText = $('<p />', {
				class : "td_status"
				,text : (userAttList[i].CoreTimeObey=="Y"?Common.getDic("lbl_n_att_compliance"): userAttList[i].CoreTimeObey==null?'':Common.getDic("lbl_n_att_non_compliance"))+(userAttList[i].AssYn=="Y"?'(간)':'' )
			});	//시
			tableTemp.find('tr td').eq(9).append(coreTime);
			tableTemp.find('tr td').eq(9).append(coreTimeText);

			$("#myAttStsContents").append(tableTemp);

			/**
			 근무일 timetable
			 */
			/*출퇴근 시간 */
			var taAttDayStartHour = Number(userAttList[i].v_AttDayStartHour);
			var taAttDayStartMin = Number(userAttList[i].v_AttDayStartMin);
			var taAttDayEndHour = Number(userAttList[i].v_AttDayEndHour);
			var taAttDayEndMin = Number(userAttList[i].v_AttDayEndMin);


			if (userAttList[i].StartSts == "lbl_att_beingLate") {//지각이면 실제 출근시간으로
				taAttDayStartHour = Number(userAttList[i].v_AttStartHour);
				taAttDayStartMin = Number(userAttList[i].v_AttStartMin);
			}
			if (userAttList[i].EndSts == "lbl_att_leaveErly") {//조퇴면 실제 퇴근시간으로
				taAttDayEndHour = Number(userAttList[i].v_AttEndHour);
				taAttDayEndMin = Number(userAttList[i].v_AttSEndMin);
			}

			var taAttArray = setTimeTableArray(userAttList[i].v_NextDayYn,taAttDayStartHour,taAttDayStartMin,taAttDayEndHour,taAttDayEndMin);

			if(userAttList[i].ExtenCnt != null && userAttList[i].ExtenCnt > 0){
				taAttArray = setTimeTableArray(userAttList[i].v_NextDayYn,taAttDayStartHour,taAttDayStartMin,Number(userAttList[i].v_ExtenEndTime.substring(0,2)),Number(userAttList[i].v_ExtenEndTime.substring(2,4)));
			}

			if(userAttList[i].HoliCnt != null && userAttList[i].HoliCnt >0){
				taAttArray = setTimeTableArray('N',Number(userAttList[i].v_HoliStartTime.substring(0,2)),Number(userAttList[i].v_HoliStartTime.substring(2,4)),Number(userAttList[i].v_HoliEndTime.substring(0,2)),Number(userAttList[i].v_HoliEndTime.substring(2,4)));
			}

			var divTemp = $("#myAttWeekDivTemp").clone();
			divTemp = divTemp.removeAttr("id");
			divTemp = divTemp.addClass("toggleDayStatus");

			var divHeader = divTemp.find("table thead tr");
			var divAtt = divTemp.find("table tbody tr").eq(0);
			var divBody = divTemp.find("table tbody tr").eq(1);
			var divBodyText = divTemp.find("table tbody tr").eq(2);


			var taStart = true;
			var taEnd = true;
			var textFlag = true;

			var startTimeNum = 0;
			for(var j=0;j<taAttArray.length;j++){
				var dayNum = taAttArray[j][0]<10?'0'+taAttArray[j][0]:taAttArray[j][0];
				divHeader.append("<th colspan='2'><p class='tx_detail_h'>"+dayNum+"</p></th>");
				var startFlag = true;
				for (var k=1; k<3; k++){
					var divAttTd = $('<td />', {});  /* 1줄 출퇴근 정보 */
					var divBodyTd = $('<td class="Work" />', {});	//시/* 2줄 progress bar*/
					var divBodyTextTd = $('<td/>', {});	//시/* 3줄 기타*/
					var divText = "";
					var divClass = "";
					if(taAttArray[j][k]=="Y"){startTimeNum++;}
					if(taAttArray[j][k]=="Y" && Number(userAttList[i].VacCnt)<1){
						divBodyTd.addClass("Admit");
						if (taStart){
							divBodyTd.addClass("Start");
							divAttTd.addClass("Start");
							if (userAttList[i].StartSts == "lbl_att_beingLate"){
								divAttTd.addClass("Late");
								divAttTd.append("<p class='title_text'><spring:message code='Cache.lbl_att_beginLate' /></p>");
							}
							else
								divAttTd.append("<p class='title_text'><spring:message code='Cache.lbl_att_goWork' /></p>");

							taStart=false;
						}

						if ((k == 1 && taAttArray[j][k+1]=="N")
								|| (k == 2 && (j+1)<taAttArray.length && taAttArray[j+1][1]=="N")
						){
							divBodyTd.addClass("End");
							divAttTd.addClass("End");
							if (userAttList[i].EndSts == "lbl_att_leaveErly"){
								divAttTd.addClass("Late");
								divAttTd.append("<p class='title_text'><spring:message code='Cache.lbl_att_leaveErly' /></p>");
							}
							else
								divAttTd.append("<p class='title_text'><spring:message code='Cache.lbl_att_offWork' /></p>");
						}

						if (userAttList[i].HoliCnt >0){
							divBodyTd.addClass("HolidayW");
							divAttTd.addClass("HolidayW");
							divClass = 'title_text1';
							divText = "<spring:message code='Cache.lbl_att_holiday_work' />"; //휴일근무
						}
						else if (taAttDayEndHour < taAttArray[j][0]){
							divBodyTd.addClass("Extend");
							divAttTd.addClass("Extend");
							divClass = 'title_text3';
							divText = '<spring:message code="Cache.lbl_att_overtime_work" />';
						}
						else{
							divClass = 'title_text1';
							divText = "<spring:message code='Cache.lbl_n_att_acknowledgedWork' />"; //인정근무
						}

						if (userAttList[i].VacFlag != null && userAttList[i].VacFlag != "")
						{
							var vacAmPmVacDay = userAttList[i].VacAmPmVacDay;
							var arrVacAmPmVacDay = null;
							if(vacAmPmVacDay.indexOf("|")>-1){
								arrVacAmPmVacDay = vacAmPmVacDay.split('|');
							}

							if (Number(arrVacAmPmVacDay[0])>=0.5 || Number(arrVacAmPmVacDay[1])>=0.5){
								if (Number(arrVacAmPmVacDay[0])>=0.5 && userAttList[i].VacOffFlag.indexOf("AM")>-1){
									if (startTimeNum<10){
										divBodyTd.addClass("Annual");
										divAttTd.addClass("Annual");
										divClass = 'title_text5';
										divText = "<spring:message code='Cache.lbl_apv_halfvac' />"; //반차

									}
								}else if (Number(arrVacAmPmVacDay[1])>=0.5 && userAttList[i].VacOffFlag.indexOf("PM")>-1){
									if (startTimeNum>10){
										divBodyTd.addClass("Annual");
										divAttTd.addClass("Annual");
										divClass = 'title_text5';
										divText = "<spring:message code='Cache.lbl_apv_halfvac' />"; //반차

									}

								}
							}
							else if (Number(userAttList[i].VacCnt)>=1){
								divBodyTd.addClass("Annual");
								divAttTd.addClass("Annual");
								divClass = 'title_text5';
								divText = "<spring:message code='Cache.lbl_Vacation' />"; //휴가
							}
						}

						//기타 근무
						for(var s=0;s<taStatusArray.length;s++){
							var taStatus = taStatusArray[s];
							var statusName = taStatus.stsName;
							var statusArray = taStatus.stsArray;
							if(j<statusArray.length && statusArray[j][k]=="Y"){
								divBodyTd.addClass("Afternoon");
								divClass = 'title_text2';
								divText = statusName;
							}
						}

					}
					divBodyTextTd.append("<p class='"+divClass+"'>"+divText+"</p>");
					divAtt.append(divAttTd);
					divBody.append(divBodyTd);
					divBodyText.append(divBodyTextTd);

				}

			}

			AttendUtils.Colspan(divBodyText);
			$("#myAttStsContents").append(divTemp);
		}


		/* 근태현황 주간 출퇴근 현황  */
		$(".tblList").append(workTimeTemp);

		/* action */
		/* 날짜 버튼 클릭 시 timetable 노출*/
		var $item = $('.btn_open').on('click', function() {
			var idx = $item.index(this); // <- 변경된 코드
			$(".toggleDayStatus").eq(idx).toggle('blind',null,500,null);
		});

		if(Common.getBaseConfig('CoreTimeYn')!="Y"){
			$(".td_etc").remove();
		}
	}
	function setMonthHtml(){
		var monthAtt = _attMonth[0];
		var userMonthAtt = monthAtt.userAtt[0];
		var userMonthAttWorkTime = userMonthAtt.userAttWorkTime;

		/* 상단 날짜 표시 */
		$(".title").html(monthAtt.dayTitleMonth);
		_stDate = monthAtt.p_sDate;
		_edDate = monthAtt.p_eDate;

		/* 상단 시간 표시 */
		$("#totWorkTime").html(attTimeFormat(userMonthAttWorkTime.TotWorkTime));
		$("#workTime").html(attTimeFormat(userMonthAttWorkTime.AttRealTime));
		$("#exTime").html(attTimeFormat(userMonthAttWorkTime.ExtenAc));
		$("#hoTime").html(attTimeFormat(userMonthAttWorkTime.HoliAc));
		$("#confTime").html(attTimeFormat(userMonthAttWorkTime.TotConfWorkTime));
		$("#remainTime").html(attTimeFormat(userMonthAttWorkTime.RemainTime));

		$("#workDay").html(userMonthAttWorkTime.WorkDay+"<spring:message code='Cache.lbl_day'/>");
		$("#workingDay").html(userMonthAttWorkTime.NormalCnt+"<spring:message code='Cache.lbl_day'/>");


		var monthWrap = $("#monthWrap").clone();
		monthWrap.removeAttr("style","display:none;");
		monthWrap.removeAttr("id");

		/* 근태현황 월간 table header  */
		var header = monthWrap.find(".calMonHeader");
		header.find(".calMonTbl tbody tr").html("");
		var dayList = _attMonth[1].dayList;
		for(var i=0;i<dayList.length;i++){
			switch (dayList[i].weekd){
				case 0 : header.find(".calMonTbl tbody tr").append("<th>"+_wpMon+"</th>"); break;
				case 1 : header.find(".calMonTbl tbody tr").append("<th>"+_wpTue+"</th>"); break;
				case 2 : header.find(".calMonTbl tbody tr").append("<th>"+_wpWed+"</th>"); break;
				case 3 : header.find(".calMonTbl tbody tr").append("<th>"+_wpThu+"</th>"); break;
				case 4 : header.find(".calMonTbl tbody tr").append("<th>"+_wpFri+"</th>"); break;
				case 5 : header.find(".calMonTbl tbody tr").append("<th class='sat'>"+_wpSat+"</th>"); break;
				case 6 : header.find(".calMonTbl tbody tr").append("<th class='sun'>"+_wpSun+"</th>"); break;
			}
		}
		header.find(".calMonTbl tbody tr").append("<th>합계</th>");
		//header 끝

		/* 근태현황 월간 table body  */
		var body = monthWrap.find(".calMonBody");
		var contents = monthWrap.find(".calMonWeekRow");

		for(var m=1;m<_attMonth.length;m++){

			var userAtt = _attMonth[m].userAtt[0];
			var userAttList = userAtt.userAttList;
			var userAttWorkTime = userAtt.userAttWorkTime;

			var totWorkTime = userAttWorkTime.TotWorkTime != ''?userAttWorkTime.TotWorkTime:"00h";
			var attRealTime = userAttWorkTime.v_AttRealTime != ''?userAttWorkTime.AttRealTime:"0h";
			var extenAc = userAttWorkTime.ExtenAc != ''?userAttWorkTime.ExtenAc:"0h";
			var holiAc = userAttWorkTime.v_HoliAc != ''?userAttWorkTime.HoliAc:"0h";
			var remainTime = userAttWorkTime.RemainTime != ''?userAttWorkTime.RemainTime:"0h";
			var totConfWorkTime = userAttWorkTime.TotConfWorkTime != ''?userAttWorkTime.TotConfWorkTime:"0h";
			var jobStsTime = userAttWorkTime.JobStsSumTime != ''?userAttWorkTime.JobStsSumTime:"0h";

			var contentsClone = contents.clone();
			contentsClone.removeAttr("style","display:none;");

			var monSchList = contentsClone.find(".monShcList");
			var calGrid = contentsClone.find(".calGrid");
			for(var j=0;j<userAttList.length;j++){
				var dayList = userAttList[j].dayList;
				var day = Number(dayList.split("-")[2]);

				/*월간 근태 상태*/
				var calTd = $('<td />', {
					class : "calTd"
					,'data-usercode' : userAtt.userCode
					,'data-targetdate' : dayList
				});

				//출근상태
				var startHtml = $('<a />', {});
				var startTitle = $('<span />', {
					class : "tx_title"
				});
				var startTime = $('<span />', {
					class : "tx_time"
				});
				var startClass= "";

				//퇴근상태
				var endHtml = $('<a />', {});
				var endTitle = $('<span />', {
					class : "tx_title"
				});
				var endTime = $('<span />', {
					class : "tx_time"
				});
				var endClass= "";


				//근무제 일정 명 길이 제한
				var spNum = 7;
				var schName = userAttList[j].SchName;
				if(schName == null)
					schName = "";
				else
					schName = userAttList[j].SchName.length > spNum ? userAttList[j].SchName.substring(0,spNum)+".." : userAttList[j].SchName;

				//출퇴근 상태표기
				if(_viewIdx == 0){	//전체
					if(userAttList[j].StartSts!=null){

						startTitle.html(Common.getDic(userAttList[j].StartSts));
						if(userAttList[j].StartSts == "lbl_n_att_absent"){	//결근
							startClass = 'WorkBox Half Absent';
						}else if(userAttList[j].StartSts == "lbl_n_att_callingTarget"){ //소명
							startClass = 'WorkBox Half Calling';
						}else {
							if(userAttList[j].StartSts == "lbl_att_beingLate"){	//지각
								startClass = 'WorkBox Half Normal2';
								startTitle.append("<span class='ico_workbox_ex_info'></span>");
							}else{
								startClass = 'WorkBox Half Normal';
							}
							startTime.html(userAttList[j].v_AttStartTime);	//출근시간
						}
						if(_commuteTimeYn!="Y"){
							startTime.html("");
						}
					}else{
						startClass = 'WorkBox Half one';
						startTitle.html(schName);	//근무제
						startTime.html(userAttList[j].v_AttDayStartTime!=null?userAttList[j].v_AttDayStartTime:'');	//출근일정시간
					}

					if(userAttList[j].EndSts!=null){
						endTitle.html(Common.getDic(userAttList[j].EndSts));
						if(userAttList[j].EndSts == "lbl_n_att_absent"){	//결근
							endClass = 'WorkBox Half Absent';
						}else if(userAttList[j].EndSts == "lbl_n_att_callingTarget"){ //소명
							endClass = 'WorkBox Half Calling';
						}else{
							if(userAttList[j].EndSts == "lbl_att_leaveErly"){	//조퇴
								endClass = 'WorkBox Half Normal3';
								endTitle.append("<span class='ico_workbox_ex_info'></span>");
							}else{
								endClass = 'WorkBox Half Normal';
							}
							endTime.html(userAttList[j].v_AttEndTime);	//퇴근시간
						}
						if(_commuteTimeYn!="Y"){
							endTime.html("");
						}
					}else{
						endClass = 'WorkBox Half one';
						endTitle.html(schName);	//근무제
						endTime.html(userAttList[j].v_AttDayEndTime!=null?userAttList[j].v_AttDayEndTime:'');	//출근일정시간
					}

					//근무상태 ( 외근 등.. )
					if(userAttList[j].jh_JobStsName!=null && userAttList[j].jh_JobStsName != ""){
						if( !startClass.indexOf("WorkBox Half") > -1 ){
							startClass += " WorkBox Half ";
						}
						endClass = "WorkBox Half Outside";
						endTitle.html(userAttList[j].jh_JobStsName);
						endTime.html(userAttList[j].jh_StartTime);
					}

					//연장 근무
					if(userAttList[j].ExtenAc != null && userAttList[j].ExtenAc != ""){
						if( !startClass.indexOf("WorkBox Half") > -1 ){
							startClass += " WorkBox Half ";
						}
						endClass = "WorkBox Half Ex";
						endTitle.html("<spring:message code='Cache.lbl_att_overtime_work' />");
						if(userAttList[j].ExtenNotEnough == 'N'){
							endTitle.append("<span class='ico_workbox_ex_info'></span>");
						}
						endTime.html(userAttList[j].v_ExtenEndTime);
					}

				}else if(_viewIdx == 1){	//누적일정 ( 출퇴근 )
					if(userAttList[j].StartSts!=null){

						startTitle.html(Common.getDic(userAttList[j].StartSts));
						if(userAttList[j].StartSts == "lbl_n_att_absent"){	//결근
							startClass = 'WorkBox Half Absent';
						}else if(userAttList[j].StartSts == "lbl_n_att_callingTarget"){ //소명
							startClass = 'WorkBox Half Calling';
						}else {
							if(userAttList[j].StartSts == "lbl_att_beingLate"){	//지각
								startClass = 'WorkBox Half Normal2';
								startTitle.append("<span class='ico_workbox_ex_info'></span>");
							}else{
								startClass = 'WorkBox Half Normal';
							}
							startTime.html(userAttList[j].v_AttStartTime);	//출근시간
						}

						if(_commuteTimeYn!="Y"){
							startTime.html("");
						}
					}

					if(userAttList[j].EndSts!=null){
						endTitle.html(Common.getDic(userAttList[j].EndSts));
						if(userAttList[j].EndSts == "lbl_n_att_absent"){	//결근
							endClass = 'WorkBox Half Absent';
						}else if(userAttList[j].EndSts == "lbl_n_att_callingTarget"){ //소명
							endClass = 'WorkBox Half Calling';
						}else{
							if(userAttList[j].EndSts == "lbl_att_leaveErly"){	//조퇴
								endClass = 'WorkBox Half Normal3';
								endTitle.append("<span class='ico_workbox_ex_info'></span>");
							}else{
								endClass = 'WorkBox Half Normal';
							}
							endTime.html(userAttList[j].v_AttEndTime);	//출근시간
						}

						if(_commuteTimeYn!="Y"){
							endTime.html("");
						}
					}

					//근무상태 ( 외근 등.. )
					if(userAttList[j].jh_JobStsName!=null && userAttList[j].jh_JobStsName != ""){
						if( !startClass.indexOf("WorkBox Half") > -1 ){
							startClass += " WorkBox Half ";
						}
						endClass = "WorkBox Half Outside";
						endTitle.html(userAttList[j].jh_JobStsName);
						endTime.html(userAttList[j].jh_StartTime);
					}

					//연장 근무
					if(userAttList[j].ExtenAc != null && userAttList[j].ExtenAc != ""){
						if( !startClass.indexOf("WorkBox Half") > -1 ){
							startClass += " WorkBox Half ";
						}
						endClass = "WorkBox Half Ex";
						endTitle.html("<spring:message code='Cache.lbl_att_overtime_work' />");
						if(userAttList[j].ExtenNotEnough == 'N'){
							endTitle.append("<span class='ico_workbox_ex_info'></span>");
						}
						endTime.html(userAttList[j].v_ExtenEndTime);
					}
				}else if(_viewIdx == 2){	//계획일정 ( 근무제 )
					startClass = 'WorkBox Half one';
					startTitle.html(schName);	//근무제
					startTime.html(userAttList[j].v_AttDayStartTime!=null?userAttList[j].v_AttDayStartTime:'');	//출근일정시간

					endClass = 'WorkBox Half one';
					endTitle.html(schName);	//근무제
					endTime.html(userAttList[j].v_AttDayEndTime!=null?userAttList[j].v_AttDayEndTime:'');	//출근일정시간
				}


				//휴무일
				if(userAttList[j].WorkSts == "OFF"|| userAttList[j].WorkSts == "HOL"){
					startClass = 'WorkBox Holyday';
					startTitle.html(userAttList[j].WorkSts== "OFF"? "<spring:message code='Cache.lbl_att_sch_holiday' />":"<spring:message code='Cache.lbl_Holiday' />");
					startTime.html("");

					endClass = "";
					endTitle.html("");
					endTime.html("");
				}
				//휴가
				if(userAttList[j].VacFlag != null && userAttList[j].VacFlag != ""){
					//연차종류
					//반차
					var vacAmPmVacDay = userAttList[j].VacAmPmVacDay;
					var arrVacAmPmVacDay = null;
					if(vacAmPmVacDay.indexOf("|")>-1){
						arrVacAmPmVacDay = vacAmPmVacDay.split('|');
					}
					//if(userAttList[j].VacOffFlag.indexOf("AM")>-1 && Number(arrVacAmPmVacDay[0])>=0.5){
					if(userAttList[j].VacOffFlag != "" && (Number(arrVacAmPmVacDay[0])>=0.5 || Number(arrVacAmPmVacDay[1])>=0.5)) {
						if(userAttList[j].VacOffFlag.indexOf("AM")>-1 && Number(arrVacAmPmVacDay[0])>=0.5){
							startClass = "WorkBox Half Vacation";
							startTitle.html(userAttList[j].VacName);
							startTime.html("");
						}
						if(userAttList[j].VacOffFlag.indexOf("PM")>-1 && Number(arrVacAmPmVacDay[1])>=0.5){
							endClass = "WorkBox Half Vacation";
							endTitle.html(userAttList[j].VacName);
							endTime.html("");
						}
					}else if(userAttList[j].VacOffFlag != "" && Number(arrVacAmPmVacDay[0])>=1){
						startClass = "WorkBox Vacation";
						startTitle.html(userAttList[j].VacName);
						startTime.html("");

						endClass = "";
						endTitle.html("");
						endTime.html("");
					}
				}

				startHtml.addClass(startClass);
				startHtml.html(startTitle);
				startHtml.append(startTime);

				if(startClass.indexOf("WorkBox Half")>-1){
					if(!endClass.indexOf("WorkBox Half")>-1){
						endClass += (" WorkBox Half");
					}
				}
				endHtml.addClass(endClass);
				endHtml.html(endTitle);
				endHtml.append(endTime);

				if(userAttList[j].AttConfirmYn=='Y'){
					startHtml.addClass('Bg');
					endHtml.addClass('Bg');
				}

				calTd.append(startHtml);
				calTd.append(endHtml);
				calTd.attr("onclick","AttendUtils.openAttMyStatusPopup('"+userAtt.userCode+"','"+dayList+"')");

				calGrid.find("tbody tr").append(calTd);


				/*월간 달력 표기*/
				var dayTd = $('<td />', {});	//시
				switch (userAttList[j].weekd){
					case 0 : dayTd.html("<strong>"+day+"</strong>"); break;
					case 1 : dayTd.html("<strong>"+day+"</strong>"); break;
					case 2 : dayTd.html("<strong>"+day+"</strong>"); break;
					case 3 : dayTd.html("<strong>"+day+"</strong>"); break;
					case 4 : dayTd.html("<strong>"+day+"</strong>"); break;
					case 5 : dayTd.html("<strong>"+day+"</strong>"); dayTd.addClass("sat"); break;
					case 6 : dayTd.html("<strong>"+day+"</strong>"); dayTd.addClass("sun"); break;
				}
				var holiSch = _attMonth[m].holiSch;
				for(var h=0;h<holiSch.length;h++){
					if(
							dayList.replaceAll("-",'') >= Number(holiSch[h].HolidayStart.replaceAll("-",''))
							&&dayList.replaceAll("-",'') <= Number(holiSch[h].HolidayEnd.replaceAll("-",''))
					){
						dayTd.addClass("holiday");
						dayTd.html("<strong>"+day+" "+holiSch[h].HolidayName+"</strong>");
					}
				}

				if("<%=userNowDate%>" == dayList){
					dayTd.addClass("shcToDay");
				}

				if(_targetDate.substring(0,7) != dayList.substring(0,7)){
					dayTd.addClass("disable");
				}

				monSchList.find("tbody tr").append(dayTd);
			}
			var weekTimeTd = $('<td />', {});	//시
			weekTimeTd.html("<p class='tx_time_total'>"+attTimeFormat(totWorkTime)+"</p>");
			weekTimeTd.append("<p class='tx_etc'><spring:message code='Cache.lbl_att_overtime'/> : "+attTimeFormat(extenAc)+"</p>");
			weekTimeTd.append("<p class='tx_etc'><spring:message code='Cache.lbl_Holiday'/> : "+attTimeFormat(holiAc)+"</p>");
			weekTimeTd.append("<p class='tx_etc'><spring:message code='Cache.lbl_n_att_AttRealTime'/> : "+attTimeFormat(totConfWorkTime)+"</p>");
			weekTimeTd.append("<p class='tx_etc'><spring:message code='Cache.lbl_n_att_remain'/> : "+attTimeFormat(remainTime)+"</p>");

			calGrid.find("tbody tr").append(weekTimeTd);
			monSchList.find("tbody tr").append("<td></td>");

			body.append(contentsClone);
		}

		$(".tblList").html(monthWrap);

	}


	//기타근무 리스트 팝업
	function showJobList(o){
		$(".btnDropdown_layer").hide();
		AttendUtils.openAttJobListPopup(o,$(o).parent());
	}


	//time table 근무시간 범위
	function attTimeTableSet(d){
		if(d!=null && d!=undefined){

		}
		return "00:00";
	}

	function attTimeFormat(s){
		return AttendUtils.convertSecToStr(s,"H");
//	return s;
//	s = s==null||s==''?'00h':s;

//	return s.replace("h","<spring:message code='Cache.lbl_att_sch_time'/>").replace("m","<spring:message code='Cache.lbl_Minutes'/>");
	}

	function setTimeTableArray(nextYn,sHour,sMin,eHour,eMin){

		var timeArray = new Array();
		for(var t=0;t<24;t++){
			var minArray = [t,'N','N'];
			timeArray.push(minArray);
		}

		if(nextYn=="Y"){
			for(var at=sHour;at<timeArray.length;at++ ){
				if(sHour==at){
					if(sMin>=30){
						timeArray[at][1] = 'N';
						timeArray[at][2] = 'Y';
					}else{
						timeArray[at][1] = 'Y';
						timeArray[at][2] = 'Y';
					}
				}else{
					timeArray[at][1] = 'Y';
					timeArray[at][2] = 'Y';
				}
			}

			for(var t=0;t<eHour;t++){
				var minArray = [t,'N','N'];

				if(eHour>=t){
					minArray[1] = 'Y';
					minArray[2] = 'Y';
					if(eHour==t){
						minArray[1] = 'N';
						minArray[2] = 'N';
						if(eMin>=30){
							minArray[1] = 'Y';
							minArray[2] = 'N';
						}
					}
				}
				timeArray.push(minArray);
			}

		}else{
			for(var at=sHour;at<=eHour;at++ ){

				timeArray[at][1] = 'Y';
				timeArray[at][2] = 'Y';

				if(sHour==at){
					if(sMin>=30){
						timeArray[at][1] = 'N';
						timeArray[at][2] = 'Y';
					}else{
						timeArray[at][1] = 'Y';
						timeArray[at][2] = 'Y';
					}
				}

				if(eHour==at){
					if(eMin>=30){
						timeArray[at][1] = 'Y';
						timeArray[at][2] = 'N';
					}else{
						timeArray[at][1] = 'N';
						timeArray[at][2] = 'N';
					}
				}
			}
		}

		return timeArray;
	}

</script>