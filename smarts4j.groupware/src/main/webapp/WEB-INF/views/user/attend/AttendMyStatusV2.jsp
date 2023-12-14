<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8" import="egovframework.coviframework.util.RedisDataUtil,egovframework.covision.groupware.attend.user.util.AttendUtils"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<%@ page import="egovframework.coviframework.util.ComUtils"%>
<%@ page import="egovframework.coviframework.util.DicHelper"%>
<%@ page import="egovframework.baseframework.util.SessionHelper"%>
<%@ page import="egovframework.coviframework.util.RedisDataUtil"%>
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
			<ul class="addFuncLilst_normal right" id="ul_tab">

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
			<dl class="ATMTime_dl" id="dl_weeklyAvgTime">
				<dt><%=DicHelper.getDic("lbl_Week")%> <%=DicHelper.getDic("lbl_apv_TimeAverage")%></dt>
				<dd><span class="tx_normal" id="weeklyAvgTime"></span></dd>
			</dl>
			<dl class="ATMTime_dl" id="dl_monthlyMaxWorkTime" style="display: none;">
				<dt><spring:message code='Cache.lbl_MonthlyLegalWork' /></dt> <!-- 월 법정근로시간 -->
				<dd><span class="tx_normal" id="monthlyMaxWorkTime"></span></dd>
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
							<li><a href="#" onclick='AttendUtils.openSchedulePopup()'><spring:message code='Cache.lbl_n_att_worksch' /> <%=AttendUtils.getRequestName(RedisDataUtil.getBaseConfig("WorkReqMethod"))%></a></li>
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
				<%if (!RedisDataUtil.getBaseConfig("ExcelSaveYn").equals("N")){%>
				<a href="#" class="btnTypeDefault btnExcel" id="excelBtn"><spring:message code='Cache.lbl_SaveToExcel' /></a>
				<%} %>
			</div>
			<div class="ATMbuttonStyleBoxRight">
				<ul class="ATMschSelect">
					<li class="pageToggle selected"><a href="#"><spring:message code='Cache.lbl_Weekly' /></a></li>
					<li class="pageToggle"><a href="#"><spring:message code='Cache.lbl_Monthly' /></a></li>
				</ul>
			</div>
			<div class="ATMbuttonStyleBoxRight" style="margin-top: 10px;margin-right: 5px;">
				<input type="checkbox" id="ckb_daynight" checked/> 주야표기
				<input type="checkbox" id="ckb_incld_weeks" checked/> 주단위
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
			<td class="td_time_day"></td>
			<td class="td_time_day"></td>
			<td class="td_time_day"></td>
			<td class="td_time_day"></td>
			<td class="td_time_day"></td>
			<td class="td_time_day"></td>
			<td class="td_etc"></td>
		</tr>
		<tr>
			<td><strong><spring:message code='Cache.lbl_n_att_remainWorkTime' /></strong>
				<span class="time_info">
						<%=String.format(DicHelper.getDic("lbl_n_att_basedOnHourPerWeek"),RedisDataUtil.getBaseConfig("RemainTimeCode"))%>
				</span>
			</td>
			<td><p class="td_time_day"></p></td>
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
<div id="divJobPopup" style="display:none;width:282px;  position:absolute; z-index:105">
	<div class="ATMgt_Work_Popup">
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

	.ATMUserMonthWrap .calMonBody .calMonWeekRow {
		height: 125px;
	}

	@media all and (max-width:1700px){
		.ATMUserMonthWrap .calMonBody .calMonWeekRow {
			height: 145px;
		}
	}
	.ATMUserMonthWrap .calMonBody .calMonWeekRow .calGrid tbody tr td:hover{
		background: #f5f5f5;
	}

	.User_ATMWork_detail_wrap .ATMWork_detail_T td.Work.Admit:after {content:''; position:absolute; left:0; bottom:5px; display:inline-block; width:100%; height:5px; z-index:2;}
	.User_ATMWork_detail_wrap .ATMWork_detail_T td.Work.Admit:after {background-color: #75aaac; height:9px;}
	.User_ATMWork_detail_wrap .ATMWork_detail_T td.Work.AdmitAble:after {content:''; position:absolute; left:0; bottom:5px; display:inline-block; width:100%; height:5px; z-index:2;}
	.User_ATMWork_detail_wrap .ATMWork_detail_T td.Work.AdmitAble:after {background-color: #a7e6e8; height:9px;}
	.User_ATMWork_detail_wrap .ATMWork_detail_T td.Work.Coretime:after {content:''; position:absolute; left:0; bottom:5px; display:inline-block; width:100%; height:5px; z-index:2;}
	.User_ATMWork_detail_wrap .ATMWork_detail_T td.Work.Coretime:after {background-color: #437779; height:9px;}

	.Holywork {background: #ffc141 !important;}
	.WorkBox.Holywork .tx_title { color: #ffeecc; }
	.User_ATMTable_wrap .ATMTable td.Holywork .User_Info dt { color: #ffffff; }
	.User_ATMTable_wrap .ATMTable td.Holywork .User_Info dd { color:#566165; padding: 3px;}

	#loading-spinner {
		width: 100%; height: 100%;
		top: 0; left: 0;
		display: none;
		opacity: .4;
		background: silver;
		position: fixed;
		z-index: 9999;
	}
	#loading-spinner div {
		width: 100%; height: 100%;
		display: table;
	}
	#loading-spinner span {
		display: table-cell;
		text-align: center;
		vertical-align: middle;
		padding-left: 200px;
	}
	#loading-spinner img {
		background: white;
		padding: 1em;
		border-radius: .7em;
	}
	-->
</style>
<script type="text/javascript">
	var _tab0_selval = 0;
	var _tab1_selval = 0;

	var _pageType = 0;
	var _printDN = true;

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

	var _monthlyMaxWorkTime;

	//보기옵션
	var _viewIdx = 0;

	var _commuteTimeYn = Common.getBaseConfig('CommuteTimeYn');

	$(document).ready(function(){
		init();

		//내 근태현황 조회
		getMyAttInfo();
	});

	function init(){
		//휴일대체근무 신청 표기
		if(Common.getBaseConfig("HoliReplReqMethod") == "Y")
			$("#HoliReplReqMethod").show();

		//기타근무 리스트
		AttendUtils.getOtherJobList('Y', 'USER');
		//주야 표기 모드
		if($("#ckb_daynight").is(":checked")){
			_printDN = true;
		}else{
			_printDN = false;
		}
		$("#ckb_daynight").change(function() {
			if(this.checked) {
				_printDN = true;
			}else{
				_printDN = false;
			}
			if(_pageType==0) {
				setWeekHtml();
			}else{
				setMonthHtml();
			}
		});

		$("#ckb_incld_weeks").change(function() {
			getMyAttInfo()
		});



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

		filter_ul();

		//주간/월간
		$(".pageToggle").on('click',function(){
			$(".pageToggle").attr("class","pageToggle");
			$(this).attr("class","selected pageToggle");
			_pageType = $(this).index();
			filter_ul();
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
			var url = "/groupware/attendUserSts/excelDownloadForAttMyStatusV2.do";
			var params = {
				dateTerm	: _pageType==0?"W":_pageType==1?"M":null
				,targetDate	: _targetDate
				,printDN : _printDN
				,incld_weeks: $("#ckb_incld_weeks").is(":checked")
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

	function filter_ul(){
		if(_pageType===0){
			var ulHtml='<li class="contentcheck" value=""><a href="#"><span class="check_txt"><spring:message code='Cache.lbl_ViewAll' /></span><span class="fil"></span></a></li>'
					+'<li class="contentcheck" value=""><a href="#"><span class="check_txt"><spring:message code='Cache.lbl_n_att_attendStatusView' /></span><span class="fil"></span></a></li>'
					+'<li class="contentcheck" value=""><a href="#"><span class="check_txt"><spring:message code='Cache.lbl_n_att_attendScheduleView' /></span><span class="fil"></span></a></li>';
			$("#ul_tab").html(ulHtml);
			$("#ul_tab > li").eq(_tab0_selval).addClass("active");
			$("#ul_tab > li").eq(_tab0_selval).find('.fil').addClass('checkico');
			_viewIdx=_tab0_selval;
		}else if(_pageType===1){
			var ulHtml='<li class="contentcheck" value=""><a href="#"><span class="check_txt">근태현황상세</span><span class="fil"></span></a></li>'
					+'<li class="contentcheck" value=""><a href="#"><span class="check_txt">근태현황/일정</span><span class="fil"></span></a></li>'
					+'<li class="contentcheck" value=""><a href="#"><span class="check_txt"><spring:message code='Cache.lbl_n_att_attendStatusView' /></span><span class="fil"></span></a></li>'
					+'<li class="contentcheck" value=""><a href="#"><span class="check_txt"><spring:message code='Cache.lbl_n_att_attendScheduleView' /></span><span class="fil"></span></a></li>';
			$("#ul_tab").html(ulHtml);
			$("#ul_tab > li").eq(_tab1_selval).addClass("active");
			$("#ul_tab > li").eq(_tab1_selval).find('.fil').addClass('checkico');
			_viewIdx=_tab1_selval;
		}



		$(".contentcheck").off();
		//표기 필터
		$(".contentcheck").on('click',function(){
			_viewIdx = $(this).index();

			$(".contentcheck").removeClass('active');
			$(".contentcheck .fil").removeClass('checkico');

			$(this).addClass('active');
			$(this).find('.fil').addClass('checkico');
			if(_pageType===0){
				_tab0_selval = $(this).index();
				setWeekHtml();
			}else if(_pageType===1){
				_tab1_selval = $(this).index();
				setMonthHtml();
			}
		});
	}


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
			,incld_weeks: $("#ckb_incld_weeks").is(":checked")
		}
		$('#loading-spinner').show();
		$.ajax({
			type : "POST",
			data : params,
			url : "/groupware/attendUserSts/getMyAttStatusV2.do",
			success:function (data) {
				if(data.status=="SUCCESS"){
					if(_pageType==0){
						_att = data.attMap;
						_jobHisList = data.jobHisList;
						_monthlyMaxWorkTime = data.monthlyMaxWorkTime;
						setWeekHtml();
					}else if(_pageType==1){
						_attMonth =  data.attMonthList;
						_attMonthMap =  data.monthMap;
						_attMonthRangeFromToDateMap =  data.rangeFromToDateMap;
						_monthlyMaxWorkTime = data.monthlyMaxWorkTime;
						setMonthHtml();
					}
					$('#loading-spinner').hide();
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
		var FreePartAttCnt = 0;
		/* 근태현황 주간 출퇴근 현황  */
		$("#dl_weeklyAvgTime").hide();
		var userAtt = _att.userAtt[0];
		var userAttList = userAtt.userAttList;
		var userAttWorkTime = userAtt.userAttWorkTime;

		//상단 날짜 표시
		$(".title").html(_att.dayTitle);
		_stDate = _att.p_sDate;
		_edDate = _att.p_eDate;

		/* 상단 시간 표시 */
		var totWorkTime = userAttWorkTime.TotWorkTime;
		var attAcN = Number(userAttWorkTime.AttAcN) + Number(userAttWorkTime.ExtenAcN) + Number(userAttWorkTime.HoliAcN);
		var totWorkTimeD = totWorkTime - attAcN;
		var totWorkTimeHtml = "<p title=\""+attTimeFormat(totWorkTime)+"(<spring:message code='Cache.lbl_Weekly' />:"+attTimeFormat(totWorkTimeD)+"/<spring:message code='Cache.lbl_night' />:"+attTimeFormat(attAcN)+")\">"; //주간:야간
		if(_printDN){
			totWorkTimeHtml += attTimeFormat(totWorkTimeD)+"/"+attTimeFormat(attAcN);
		}else{
			totWorkTimeHtml += attTimeFormat(totWorkTime);
		}
		totWorkTimeHtml += "</p>";
		$("#totWorkTime").html(totWorkTimeHtml);
		var attRealTimeW = userAttWorkTime.AttRealTime;
		var attRealTimeN = Number(userAttWorkTime.AttAcN);
		var attRealTimeD = attRealTimeW - attRealTimeN;
		var workTimeHtml = "<p title=\""+attTimeFormat(userAttWorkTime.AttRealTime)+"(<spring:message code='Cache.lbl_Weekly' />:"+attTimeFormat(attRealTimeD)+"/<spring:message code='Cache.lbl_night' />:"+attTimeFormat(userAttWorkTime.AttAcN)+")\">"; //주간:야간
		if(_printDN){
			workTimeHtml += attTimeFormat(attRealTimeD)+"/"+attTimeFormat(attRealTimeN);
		}else{
			workTimeHtml += attTimeFormat(attRealTimeW);
		}
		workTimeHtml += "</p>";
		$("#workTime").html(workTimeHtml);
		var extendAcHtml = "<p title=\""+attTimeFormat(userAttWorkTime.ExtenAc)+"(<spring:message code='Cache.lbl_Weekly' />:"+attTimeFormat(userAttWorkTime.ExtenAcD)+"/<spring:message code='Cache.lbl_night' />:"+attTimeFormat(userAttWorkTime.ExtenAcN)+")\">"; //주간:야간
		if(_printDN){
			extendAcHtml += attTimeFormat(userAttWorkTime.ExtenAcD)+"/"+attTimeFormat(userAttWorkTime.ExtenAcN);
		}else{
			extendAcHtml += attTimeFormat(userAttWorkTime.ExtenAc);
		}
		extendAcHtml += "</p>";
		$("#exTime").html(extendAcHtml);
		var holiAcHtml = "";
		if(_printDN){
			holiAcHtml = attTimeFormat(userAttWorkTime.HoliAcD)+"/"+attTimeFormat(userAttWorkTime.HoliAcN);
		}else{
			holiAcHtml = attTimeFormat(userAttWorkTime.HoliAc);
		}
		$("#hoTime").html(holiAcHtml);
		var totConfWorkTime = userAttWorkTime.TotConfWorkTime;
		var totConfWorkTimeD = totConfWorkTime - attAcN;
		var totConfWorkTimeHtml = "<p title=\""+attTimeFormat(totConfWorkTime)+"(<spring:message code='Cache.lbl_Weekly' />:"+attTimeFormat(totConfWorkTimeD)+"/<spring:message code='Cache.lbl_night' />:"+attTimeFormat(attAcN)+")\">"; //주간:야간
		if(_printDN){
			totConfWorkTimeHtml += attTimeFormat(totConfWorkTimeD)+"/"+attTimeFormat(attAcN);
		}else{
			totConfWorkTimeHtml += attTimeFormat(totConfWorkTime);
		}
		totConfWorkTimeHtml += "</p>";
		$("#confTime").html(totConfWorkTimeHtml);


		$("#workDay").html(userAttWorkTime.WorkDay+"<spring:message code='Cache.lbl_day'/>");
		$("#workingDay").html(userAttWorkTime.NormalCnt+"<spring:message code='Cache.lbl_day'/>");

		//월 법정근로시간
		$("#monthlyMaxWorkTime").html(attTimeFormat(_monthlyMaxWorkTime));

		/* 근태현황  주간 합계*/
		var workTimeTemp = $("#myAttWeekWorkTimeTemp").clone();
		workTimeTemp = workTimeTemp.removeAttr("style","display:none;");
		var sumUserWorkInfo = userAttList[userAttList.length-1].userWorkInfo;
		var totSumWorkTimeHtml = "";
		totSumWorkTimeHtml += "<p style='color: "+AttendUtils.userWorkTimeOverColor(sumUserWorkInfo, totWorkTime, "W")+"'>"
		totSumWorkTimeHtml += attTimeFormat(totWorkTime);
		totSumWorkTimeHtml += "</p>";
		if(_printDN){
			totSumWorkTimeHtml += "<p style=\"color: #999999;font-size: 13px;\">("
			totSumWorkTimeHtml += attTimeFormat(totWorkTimeD)+" /"+attTimeFormat(attAcN);
			totSumWorkTimeHtml += ")</p>";
		}
		workTimeTemp.find("table tr .time_info").html(Common.getDic("lbl_n_att_basedOnHourPerWeek").replace("%s",userAttWorkTime.WorkTime));	// 기준
		workTimeTemp.find("table tr").eq(0).find(".td_time_day").eq(0).html(totSumWorkTimeHtml);	//총 근무시간 합계
		var attSumRealTimeHtml = "";
		attSumRealTimeHtml += "<p style='color: "+AttendUtils.userWorkTimeOverColor(sumUserWorkInfo, attRealTimeW, "W")+"'>";
		attSumRealTimeHtml += attTimeFormat(attRealTimeW);
		attSumRealTimeHtml += "</p>";
		if(_printDN){
			attSumRealTimeHtml += "<p style=\"color: #999999;font-size: 13px;\">("
			attSumRealTimeHtml += attTimeFormat(attRealTimeD)+" /"+attTimeFormat(attRealTimeN);
			attSumRealTimeHtml += ")</p>";
		}
		workTimeTemp.find("table tr").eq(0).find(".td_time_day").eq(1).html(attSumRealTimeHtml);	//안정근무 합계
		var sumExtendAcHtml = "";
		sumExtendAcHtml += "<p>"+attTimeFormat(userAttWorkTime.ExtenAc)+"</p>";
		if(_printDN){
			sumExtendAcHtml +=  "<p style=\"color: #999999;font-size: 13px;\">"+attTimeFormat(userAttWorkTime.ExtenAcD)+" /"+attTimeFormat(userAttWorkTime.ExtenAcN)+"</p>";
		}
		workTimeTemp.find("table tr").eq(0).find(".td_time_day").eq(2).html(sumExtendAcHtml);	//연장근무 합계
		var sumHoliAcHtml = "";
		sumHoliAcHtml += "<p>"+attTimeFormat(userAttWorkTime.HoliAc)+"</p>";
		if(_printDN){
			sumHoliAcHtml +=  "<p style=\"color: #999999;font-size: 13px;\">"+attTimeFormat(userAttWorkTime.HoliAcD)+" /"+attTimeFormat(userAttWorkTime.HoliAcN)+"</p>";
		}
		workTimeTemp.find("table tr").eq(0).find(".td_time_day").eq(3).html(sumHoliAcHtml);	//휴일근무 합계

		var totConfWorkTimeHtml = "";
		totConfWorkTimeHtml += "<p>";
		totConfWorkTimeHtml += attTimeFormat(totConfWorkTime);
		totConfWorkTimeHtml += "</p>";
		if(_printDN){
			totConfWorkTimeHtml += "<p style=\"color: #999999;font-size: 13px;\">("
			totConfWorkTimeHtml += attTimeFormat(totConfWorkTimeD)+" /"+attTimeFormat(attAcN);
			totConfWorkTimeHtml += ")</p>";
		}
		workTimeTemp.find("table tr").eq(0).find(".td_time_day").eq(5).html(totConfWorkTimeHtml);	//인정실근무 합계
		var remainTime = userAttWorkTime.RemainTime;
		var remainTimeHtml = "";
		if(remainTime < 0) {
			remainTime = Math.abs(remainTime);
			remainTimeHtml = "<p style=\"color: #f08264;\">"+attTimeFormat(remainTime) + " "+Common.getDic("lbl_above")+"</p>"
		}else{
			remainTimeHtml = attTimeFormat(remainTime);
		}
		$("#remainTime").html(remainTimeHtml);
		// 잔여 근무 시간 표시
		var _ExptVacTime = Common.getBaseConfig('ExptVacTime');
		if (_ExptVacTime == 'Y'){
			workTimeTemp.find("table tr").eq(1).find(".td_time_day").eq(1).html(remainTimeHtml);
		}else{
			workTimeTemp.find("table tr").eq(1).find(".td_time_day").eq(0).html(remainTimeHtml);
		}

		/* 근태현황 주간 table header  */
		var header = $("#myAttWeekHeader").clone();
		header = header.removeAttr("style","display:none;");
		$(".tblList").html(header);
		$(".tblList").append("<div class='User_ATMTable_wrap' id='myAttStsContents' ></div>");
		/* 근태현황 주간 table header  */

		for(var i=0;i<userAttList.length;i++) {
			//자율출근 또는 선택 근로제인경우 월 법정 근로시간 표기 여부 체크용 카운트 처리
			if(userAttList[i].WorkingSystemType==2){
				FreePartAttCnt++;
			}
			var tableTemp = $("#myAttWeekTableTemp").clone();
			/*기타근무 시간*/
			var taStatusArray = new Array();

			for (var jh = 0; jh < _jobHisList.length; jh++) {
				if (_jobHisList[jh].JobDate == userAttList[i].dayList) {
					var taJhStartHour = Number(_jobHisList[jh].t_StartHour);
					var taJhStartMin = Number(_jobHisList[jh].v_StartMin);
					var taJhEndHour = Number(_jobHisList[jh].t_EndHour);
					var taJhEndMin = Number(_jobHisList[jh].v_EndMin);

					var taJhArray = setTimeTableArray('N','','', taJhStartHour, taJhStartMin, taJhEndHour, taJhEndMin);
					var jhData = {
						stsName: _jobHisList[jh].JobStsName
						, stsArray: taJhArray
					}

					taStatusArray.push(jhData);
				}
			}

			tableTemp = tableTemp.removeAttr("style", "display:none;");
			tableTemp = tableTemp.removeAttr("id");

			var dateTitle = schedule_SetDateFormat(userAttList[i].dayList, '.');
			var dayHtml = "";
			switch (userAttList[i].weekd) {
				case 0 :
					dayHtml = dateTitle + "(" + _wpMon + ")";
					break;
				case 1 :
					dayHtml = dateTitle + "(" + _wpTue + ")";
					break;
				case 2 :
					dayHtml = dateTitle + "(" + _wpWed + ")";
					break;
				case 3 :
					dayHtml = dateTitle + "(" + _wpThu + ")";
					break;
				case 4 :
					dayHtml = dateTitle + "(" + _wpFri + ")";
					break;
				case 5 :
					dayHtml = dateTitle + "(" + _wpSat + ")";
					tableTemp.find(".date_title").attr("class", "date_title tx_sat");
					break;
				case 6 :
					dayHtml = dateTitle + "(" + _wpSun + ")";
					tableTemp.find(".date_title").attr("class", "date_title tx_sun");
					break;
			}
			tableTemp.find(".date_title").html(dayHtml);	//날짜

			/* 전체 / 누적  / 계획일정 표기 분할  */
			var startTd = tableTemp.find('tr td').eq(1);
			var endTd = tableTemp.find('tr td').eq(2);

			var startDt = "", startDd = "", startClass = "", endDt = "", endDd = "", endClass = "";


			//근무제 일정 명 길이 제한
			var spNum = 10;
			var schName = userAttList[i].SchName;
			if (schName == null)
				schName = "";
			else
				schName = userAttList[i].SchName.length > spNum ? userAttList[i].SchName.substring(0, spNum) + ".." : userAttList[i].SchName;

			//공통이 맞는지.. 이후 변경
			startTd.append('<dl class="User_Info"></dl>');
			endTd.append('<dl class="User_Info"></dl>');
			if (_viewIdx === 0) {	//전체
				if (userAttList[i].StartSts != null) {

					startDt = Common.getDic(userAttList[i].StartSts);
					if (userAttList[i].StartSts == "lbl_n_att_absent") {	//결근
						startClass = 'Absent';
					} else if (userAttList[i].StartSts == "lbl_n_att_callingTarget") { //소명
						startClass = 'Calling';
						startDt += "<a href='#' class='Btn_Explan'></a>";
					} else {
						if (userAttList[i].StartSts == "lbl_att_beingLate") {	//지각
							startClass = 'Normal2';
							startDt += "<a href='#' class='Btn_Warning'></a>";
						} else {
							startClass = 'Normal';
						}

						//출근시간
						if (userAttList[i].WorkingSystemType == 0) {
							startDd = userAttList[i].v_AttStartTime != null ? userAttList[i].v_AttStartTime : "";
						} else if (userAttList[i].WorkingSystemType == 1) {
							startDd = "";
						} else if (userAttList[i].WorkingSystemType == 2) {
							startDd = "";
						}
					}

					if (_commuteTimeYn != 'Y') {
						startDd = "";
					}

				} else {
					startClass = 'Holyday';
					startDt = schName;	//근무제

					//출근일정시간
					if (userAttList[i].WorkingSystemType == 0) {
						startDd = userAttList[i].v_AttDayStartTime != null ? userAttList[i].v_AttDayStartTime : '';
					} else if (userAttList[i].WorkingSystemType == 1) {
						startDd = "";
					} else if (userAttList[i].WorkingSystemType == 2) {
						startDd = "";
					}
				}

				if (userAttList[i].EndSts != null) {

					endDt = Common.getDic(userAttList[i].EndSts);
					if (userAttList[i].EndSts == "lbl_n_att_absent") {	//결근
						endClass = 'Absent';
					} else if (userAttList[i].EndSts == "lbl_n_att_callingTarget") { //소명
						endClass = 'Calling';
						endDt += "<a href='#' class='Btn_Explan'></a>";
					} else {
						if (userAttList[i].EndSts == "lbl_att_leaveErly") {	//조퇴
							endClass = 'Normal3';
							endDt += "<a href='#' class='Btn_Warning2'></a>";
						} else {
							endClass = 'Normal';
						}
						//퇴근시간
						if (userAttList[i].WorkingSystemType == 0) {
							endDd = userAttList[i].v_AttEndTime != null ? userAttList[i].v_AttEndTime : "";
						} else if (userAttList[i].WorkingSystemType == 1) {
							endDd = "";
						} else if (userAttList[i].WorkingSystemType == 2) {
							endDd = "";
						}

					}

					if (_commuteTimeYn != 'Y') {
						endDd = "";
					}

				} else {
					endClass = 'Holyday';
					endDt = schName;	//근무제

					//퇴근일정시간
					if (userAttList[i].WorkingSystemType == 0) {
						endDd = userAttList[i].v_AttDayEndTime != null ? userAttList[i].v_AttDayEndTime : '';
					} else if (userAttList[i].WorkingSystemType == 1) {
						endDd = "";
					} else if (userAttList[i].WorkingSystemType == 2) {
						endDd = "";
					}
				}

				//연장 근무
				if (userAttList[i].ExtenAc != null && userAttList[i].ExtenAc != "") {
					endClass = "Ex";
					endDt = "<spring:message code='Cache.lbl_att_overtime_work' />";
					if (userAttList[i].ExtenNotEnough == 'N') {
						endDt += "<a href='#' class='Btn_Info'></a>";
					}
					endDd = AttendUtils.maskTime(userAttList[i].v_ExtenEndTime);
				}

			} else if (_viewIdx === 1) {	//누적일정 ( 출퇴근 )
				if (userAttList[i].StartSts != null) {
					startDt = Common.getDic(userAttList[i].StartSts);
					if (userAttList[i].StartSts == "lbl_n_att_absent") {	//결근
						startClass = 'Absent';
					} else if (userAttList[i].StartSts == "lbl_n_att_callingTarget") { //소명
						startClass = 'Calling';
						startDt += "<a href='#' class='Btn_Explan'></a>";
					} else {
						if (userAttList[i].StartSts == "lbl_att_beingLate") {	//지각
							startClass = 'Normal2';
							startDt += "<a href='#' class='Btn_Warning'></a>";
						} else {
							startClass = 'Normal';
						}
						startDd = userAttList[i].v_AttStartTime	//출근시간
					}

					if (_commuteTimeYn != 'Y') {
						startDd = "";
					}
				}

				if (userAttList[i].EndSts != null) {

					endDt = Common.getDic(userAttList[i].EndSts);
					if (userAttList[i].EndSts == "lbl_n_att_absent") {	//결근
						endClass = 'Absent';
					} else if (userAttList[i].EndSts == "lbl_n_att_callingTarget") { //소명
						endClass = 'Calling';
						endDt += "<a href='#' class='Btn_Explan'></a>";
					} else {
						if (userAttList[i].EndSts == "lbl_att_leaveErly") {	//조퇴
							endClass = 'Normal3';
							endDt += "<a href='#' class='Btn_Warning2'></a>";
						} else {
							endClass = 'Normal';
						}
						endDd = userAttList[i].v_AttEndTime	//퇴근시간
					}

					if (_commuteTimeYn != 'Y') {
						endDd = "";
					}
				}

				//연장 근무
				if (userAttList[i].ExtenAc != null && userAttList[i].ExtenAc != "") {
					endClass = "Ex";
					endDt = "<spring:message code='Cache.lbl_att_overtime_work' />";
					if (userAttList[i].ExtenNotEnough == 'N') {
						endDt += "<a href='#' class='Btn_Info'></a>";
					}
					endDd = AttendUtils.maskTime(userAttList[i].v_ExtenEndTime);
				}

			} else if (_viewIdx === 2) {	//계획일정 ( 근무제 )
				startClass = 'Holyday';
				startDt = schName;	//근무제
				//출근시간
				if (userAttList[i].WorkingSystemType == 0) {
					startDd = userAttList[i].v_AttDayStartTime != null ? userAttList[i].v_AttDayStartTime : '';
				} else if (userAttList[i].WorkingSystemType == 1) {
					startDd = "";
				} else if (userAttList[i].WorkingSystemType == 2) {
					startDd = "";
				}
				endClass = 'Holyday';
				endDt = schName;	//근무제

				//퇴근일정시간
				if (userAttList[i].WorkingSystemType == 0) {
					endDd = userAttList[i].v_AttDayEndTime != null ? userAttList[i].v_AttDayEndTime : '';
				} else if (userAttList[i].WorkingSystemType == 1) {
					endDd = "";
				} else if (userAttList[i].WorkingSystemType == 2) {
					endDd = "";
				}
			}

			//휴무일
			if (userAttList[i].WorkSts == "OFF" || userAttList[i].WorkSts == "HOL") {
				if(Number(userAttList[i].HoliCnt)>0){
					startClass = 'Holywork';
					startDt =  "<spring:message code='Cache.lbl_att_holiday_work' />";
					if(userAttList[i].v_AttStartTime==null){
						startDd = AttendUtils.hhmmToFormat(userAttList[i].v_HoliStartTime);
					}else{
						startDd = userAttList[i].v_AttStartTime;
					}

					endClass = 'Holywork';
					endDt = "<spring:message code='Cache.lbl_att_holiday_work' />";
					if(userAttList[i].v_AttEndTime==null){
						endDd = AttendUtils.hhmmToFormat(userAttList[i].v_HoliEndTime);
					}else{
						endDd = userAttList[i].v_AttEndTime;
					}
				}else{
					startClass = 'Holyday';
					startDt = userAttList[i].WorkSts == "OFF" ? "<spring:message code='Cache.lbl_att_sch_holiday' />" : "<spring:message code='Cache.lbl_Holiday' />";
					startDd = '';

					endClass = 'Holyday';
					endDt = userAttList[i].WorkSts == "OFF" ? "<spring:message code='Cache.lbl_att_sch_holiday' />" : "<spring:message code='Cache.lbl_Holiday' />";
					endDd = '';
				}
			}
			//휴가
			if (userAttList[i].VacFlag != null && userAttList[i].VacFlag != "") {
				//연차종류
				if (userAttList[i].VacCnt == "1") {//연차
					startClass = "Vacation";
					startDt = userAttList[i].VacCodeName;
					startDd = "";

					endClass = "Vacation";
					endDt = userAttList[i].VacCodeName;
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
						startDt = AttendUtils.vacNameConvertor(userAttList[i].VacOffFlag,userAttList[i].VacCodeName,'AM',0) + (startDt != "" && userAttList[i].StartSts != "lbl_att_normal_goWork" ? "(" + startDt + ")" : "");
					}
					if (userAttList[i].VacOffFlag.indexOf("PM")>-1 && Number(arrVacAmPmVacDay[1])>=0.5) {
						endClass += " Vacation";
						if (userAttList[i].VacOffFlag.indexOf("AM") > -1) {
							endDt = AttendUtils.vacNameConvertor(userAttList[i].VacOffFlag,userAttList[i].VacCodeName,'PM',0) + (endDt != "" && userAttList[i].EndSts != "lbl_att_normal_offWork" ? "(" + endDt + ")" : "");
						} else {
							endDt = AttendUtils.vacNameConvertor(userAttList[i].VacOffFlag,userAttList[i].VacCodeName,'AM',0) + (endDt != "" && userAttList[i].EndSts != "lbl_att_normal_offWork" ? "(" + endDt + ")" : "");
						}
					}
				}

			}

			startTd.addClass(startClass);
			startTd.find('dl').attr('onclick', "AttendUtils.openAttMyStatusPopup('" + userAtt.userCode + "','" + userAttList[i].dayList + "')");
			startTd.find('dl').append('<dt>' + startDt + '</dt>');	//출근상태
			startTd.find('dl').append('<dd>' + startDd + '</dd>');	//출근시간

			endTd.addClass(endClass);
			endTd.find('dl').attr('onclick', "AttendUtils.openAttMyStatusPopup('" + userAtt.userCode + "','" + userAttList[i].dayList + "')");
			endTd.find('dl').append('<dt>' + endDt + "</dt>");//퇴근상태
			if (taStatusArray.length > 0 || endClass == "Ex")
				endTd.find('dl dt').append('<a class="Btn_Overlap Btn_pop" href="#"></a>');

			endTd.find('dl').append('<dd>' + endDd + '</dd>');	//퇴근시간

			var tootipHtml = '<div class="smallPop" style="display: none;"><ul>';
			for (var s = 0; s < taStatusArray.length; s++) {
				var taStatus = taStatusArray[s];
				var statusName = taStatus.stsName;
				//var statusArray = taStatus.stsArray;

				tootipHtml += '	<li><a href="#" class="color1">' + statusName + '</a></li>';
			}
			if (endClass == "Ex") {
				tootipHtml += '	<li><a href="#" class="color2"><spring:message code="Cache.lbl_att_overtime_work" /></a></li>';
			}
			endTd.append(tootipHtml + '</ul></div>');

			/*근무시간*/
			var jobHtml = "";
			if (userAttList[i].jh_JobStsName != null && userAttList[i].jh_JobStsName != '') {
				jobHtml = "<p class='td_status'><a href='#' data-usercode='" + userAtt.userCode + "' data-targetdate='" + userAttList[i].dayList + "' onclick='showJobList(this);'>" + userAttList[i].jh_JobStsName + "</a></p>";

			}

			var totWorkTime = "";
			var valTotWorkTime = Number(userAttList[i].TotWorkTime);
			var valAttAcN = Number(userAttList[i].AttAcN) +  Number(userAttList[i].ExtenAcN) + Number(userAttList[i].HoliAcN);
			var valAttAcD = valTotWorkTime - valAttAcN;
			if (valTotWorkTime > 0) {
				totWorkTime = "<p class='td_time_day' style='color: " + AttendUtils.userWorkTimeOverColor(userAttList[i].userWorkInfo, valTotWorkTime, "D") + ";'>" + AttendUtils.convertSecToStr(valTotWorkTime, "H") + "</p>";
				if (_printDN) {
					totWorkTime += "<p style='color: #999999;'>(" + AttendUtils.convertSecToStr(valAttAcD, "H") + " /" + AttendUtils.convertSecToStr(valAttAcN, "H") + " )</p>";
				}
			} else {
				totWorkTime = "<p class='td_time_day'>" + AttendUtils.convertSecToStr(valTotWorkTime, "H") + "</p>";
			}
			tableTemp.find('tr td').eq(3).html(totWorkTime);

			var attRealTime = "";
			var valAttRealTime = userAttList[i].AttRealTime;
			var valAttRealTimeN = Number(userAttList[i].AttAcN);
			var valAttRealTimeD = valAttRealTime - valAttRealTimeN;
			if (valAttRealTime > 0) {
				attRealTime = "<p class='td_time_day' style='color: " + AttendUtils.userWorkTimeOverColor(userAttList[i].userWorkInfo, valAttRealTime, "D") + ";'>" + AttendUtils.convertSecToStr(valAttRealTime, "H") + "</p>";
				if (_printDN) {
					attRealTime += "<p style='color: #999999;'>(" + AttendUtils.convertSecToStr(valAttRealTimeD, "H") + " /" + AttendUtils.convertSecToStr(valAttRealTimeN, "H") + " )</p>";
				}
			} else {
				attRealTime = "<p class='td_time_day'>" + AttendUtils.convertSecToStr(valAttRealTime, "H") + "</p>";
			}
			//근무제가 선택 근무제 이고
			if (userAttList[i].WorkingSystemType == 2) {
				attRealTime += "<p style='color: #000000;'>월 누적 : " + attTimeFormat(userAttList[i].MonthlyAttAcSum) + "</p>";
				//월 근무시간 합이 월 법정근무시간을 넘기면
				if (userAttList[i].MonthlyAttAcSum >= _monthlyMaxWorkTime) {
					tableTemp.find('tr td').eq(4).attr('style', 'background: lightgray !important');
				}
			}
			tableTemp.find('tr td').eq(4).html(attRealTime);

			var extenAcTime = "";
			var valExtenAc = userAttList[i].ExtenAc;
			var valExtenAcD = userAttList[i].ExtenAcD;
			var valExtenAcN = userAttList[i].ExtenAcN;
			if (valExtenAc > 0) {
				extenAcTime = AttendUtils.convertSecToStr(valExtenAc, "H");
				if (_printDN) {
					extenAcTime += "<p style='color: #999999;'>(" + AttendUtils.convertSecToStr(valExtenAcD, "H") + " /" + AttendUtils.convertSecToStr(valExtenAcN, "H") + " )</p>";
				}
			} else {
				extenAcTime = AttendUtils.convertSecToStr(valExtenAc, "H");
			}
			tableTemp.find('tr td').eq(5).html("<p class='td_time_day'>" + extenAcTime + "</p>");

			var holiAcTime = "";
			var valHoliAc = userAttList[i].HoliAc;
			var valHoliAcD = userAttList[i].HoliAcD;
			var valHoliAcN = userAttList[i].HoliAcN;
			if (valHoliAc > 0) {
				holiAcTime = AttendUtils.convertSecToStr(valHoliAc, "H");
				if (_printDN) {
					holiAcTime += "<p style='color: #999999;'>(" + AttendUtils.convertSecToStr(valHoliAcD, "H") + " /" + AttendUtils.convertSecToStr(valHoliAcN, "H") + " )</p>";
				}
			} else {
				holiAcTime = AttendUtils.convertSecToStr(valHoliAc, "H");
			}
			tableTemp.find('tr td').eq(6).html("<p class='td_time_day'><dl class='User_Info'><dt>" + holiAcTime +
					(userAttList[i].HoliNotEnough == 'N' && userAttList[i].HoliAc > 0 ? "<a href='#' class='Btn_Info'></a>" : "") + "</dt></dl></p>");
			tableTemp.find('tr td').eq(7).html(jobHtml);
			tableTemp.find('tr td').eq(8).html("<p class='td_time_day'>" + AttendUtils.convertSecToStr(userAttList[i].AttRealConfTime, "H") + "</p>");

			var coreTime = $('<p />', {
				class: "td_time_day"
				, text: userAttList[i].CoreTime == null ? '' : userAttList[i].CoreTime
			});	//시
			var coreTimeText = $('<p />', {
				class: "td_status"
				,
				text: (userAttList[i].CoreTimeObey == "Y" ? Common.getDic("lbl_n_att_compliance") : userAttList[i].CoreTimeObey == null ? '' : Common.getDic("lbl_n_att_non_compliance")) + (userAttList[i].AssYn == "Y" ? '(간)' : '')
			});	//시
			tableTemp.find('tr td').eq(9).append(coreTime);
			tableTemp.find('tr td').eq(9).append(coreTimeText);

			$("#myAttStsContents").append(tableTemp);

			/**
			 근무일 timetable
			 */
			/*출퇴근 시간 */
			var WorkingSystemType = 0;
			if (userAttList[i].WorkingSystemType != null) {
				WorkingSystemType = userAttList[i].WorkingSystemType;
			}
			var nextDayYn = userAttList[i].v_NextDayYn;
			var mAttDayStartTime = userAttList[i].mAttDayStartTime;
			var mAttDayEndTime = userAttList[i].mAttDayEndTime;
			var sYMD = "";
			if (mAttDayStartTime!=null && mAttDayStartTime!="" && mAttDayStartTime.length == 19) {
				sYMD = mAttDayStartTime.toString().substr(0,10);
			}
			var eYMD = "";
			if (mAttDayEndTime!=null && mAttDayEndTime!="" && mAttDayEndTime.length == 19) {
				eYMD = mAttDayEndTime.toString().substr(0,10);
			}
			var taAttDayStartHour = 0;
			var taAttDayStartMin = 0;
			var taAttDayEndHour = 0;
			var taAttDayEndMin = 0;
			if(WorkingSystemType===0) {//지정근무지 - 일반
				taAttDayStartHour = Number(userAttList[i].v_AttDayStartHour);
				taAttDayStartMin = Number(userAttList[i].v_AttDayStartMin);
				taAttDayEndHour = Number(userAttList[i].v_AttDayEndHour);
				taAttDayEndMin = Number(userAttList[i].v_AttDayEndMin);
			}else if(WorkingSystemType===1) {//자율근무제
				taAttDayStartHour = Number(userAttList[i].v_AttStartHour);
				taAttDayStartMin = Number(userAttList[i].v_AttStartMin);
				taAttDayEndHour = Number(userAttList[i].v_AttEndHour);
				taAttDayEndMin = Number(userAttList[i].v_AttEndMin);

			}else if(WorkingSystemType===2) {//선택근무제
				taAttDayStartHour = Number(userAttList[i].v_AttDayStartHour);
				taAttDayStartMin = Number(userAttList[i].v_AttDayStartMin);
				taAttDayEndHour = Number(userAttList[i].v_AttDayEndHour);
				taAttDayEndMin = Number(userAttList[i].v_AttDayEndMin);
			}

			if (userAttList[i].StartSts == "lbl_att_beingLate") {//지각이면 실제 출근시간으로
				taAttDayStartHour = Number(userAttList[i].v_AttStartHour);
				taAttDayStartMin = Number(userAttList[i].v_AttStartMin);
			}
			if (userAttList[i].EndSts == "lbl_att_leaveErly") {//조퇴면 실제 퇴근시간으로
				taAttDayEndHour = Number(userAttList[i].v_AttEndHour);
				taAttDayEndMin = Number(userAttList[i].v_AttSEndMin);
			}

			var taAttArray = null;
			if(WorkingSystemType===0) {//0:지정근무제

				var comCoreTime = userAttList[i].CoreTime;
				if(comCoreTime!=null&&comCoreTime!=""&&comCoreTime.indexOf("~")>-1){
					var arrCT = comCoreTime.split("~");
					var arrCTS = arrCT[0].split(":");
					var arrCTE = arrCT[1].split(":");
					cSH = Number(arrCTS[0]);
					cSM = Number(arrCTS[1]);
					cEH = Number(arrCTE[0]);
					cEM = Number(arrCTE[1]);
				}

				taAttArray = setTimeTableArray(nextDayYn,sYMD,eYMD,taAttDayStartHour, taAttDayStartMin, taAttDayEndHour, taAttDayEndMin, cSH, cSM, cEH, cEM);

				if(userAttList[i].ExtenCnt != null && userAttList[i].ExtenCnt > 0){
					taAttArray = setTimeTableArray(nextDayYn,sYMD,eYMD,taAttDayStartHour,taAttDayStartMin,Number(userAttList[i].v_ExtenEndTime.substring(0,2)),Number(userAttList[i].v_ExtenEndTime.substring(2,4)), cSH, cSM, cEH, cEM);
				}

				if(userAttList[i].HoliCnt != null && userAttList[i].HoliCnt >0){
					taAttArray = setTimeTableArray('N',sYMD,eYMD,Number(userAttList[i].v_HoliStartTime.substring(0,2)),Number(userAttList[i].v_HoliStartTime.substring(2,4)),Number(userAttList[i].v_HoliEndTime.substring(0,2)),Number(userAttList[i].v_HoliEndTime.substring(2,4)), cSH, cSM, cEH, cEM);
				}
			}else if(WorkingSystemType===1) {//1:자율

				var comCoreTime = userAttList[i].CoreTime;
				if(comCoreTime!=null&&comCoreTime!=""&&comCoreTime.indexOf("~")>-1){
					var arrCT = comCoreTime.split("~");
					var arrCTS = arrCT[0].split(":");
					var arrCTE = arrCT[1].split(":");
					cSH = Number(arrCTS[0]);
					cSM = Number(arrCTS[1]);
					cEH = Number(arrCTE[0]);
					cEM = Number(arrCTE[1]);
				}
				var aSSH = 0;
				var aSSM = 0;
				var aSEH = 0;
				var aSEM = 0;
				var lHour = "";
				var lMin = "";
				if(taAttDayStartHour==0 && taAttDayStartMin==0 && taAttDayEndHour==0 && taAttDayEndMin==0){
					aSEH = 23;
					aSEM = 59;
					taAttDayStartHour = 0;
					taAttDayStartMin = 0;
					taAttDayEndHour = 23;
					taAttDayEndMin = 59;
				}else if(taAttDayEndHour==0 && taAttDayEndMin==0 && Number(userAttList[i].AttAc)>0){//출근테그후 퇴근전
					var h = Number(userAttList[i].AttAc)/60;
					var m = Number(userAttList[i].AttAc)%60;
					taAttDayEndHour = taAttDayStartHour + h;
					taAttDayEndMin = taAttDayEndMin + m;
				}else if(userAttList[i].v_NextDayYn=="Y" && Number(userAttList[i].AttAc)>0){//출퇴근 기록된 케이스중 다음날퇴근
					var h = Number(userAttList[i].AttAc)/60;
					var m = Number(userAttList[i].AttAc)%60;
					lHour = ""+(taAttDayStartHour + h);
					lMin = ""+(taAttDayEndMin + m);
				}


				taAttArray = setTimeTableArray_Free(nextDayYn,sYMD,eYMD, taAttDayStartHour, taAttDayStartMin, taAttDayEndHour, taAttDayEndMin, cSH, cSM, cEH, cEM,aSSH,aSSM,aSEH,aSEM,lHour,lMin);

				if(userAttList[i].ExtenCnt != null && userAttList[i].ExtenCnt > 0){
					taAttArray = setTimeTableArray_Free(nextDayYn,sYMD,eYMD,taAttDayStartHour,taAttDayStartMin,Number(userAttList[i].v_ExtenEndTime.substring(0,2)),Number(userAttList[i].v_ExtenEndTime.substring(2,4)), cSH, cSM, cEH, cEM,aSSH,aSSM,aSEH,aSEM,lHour,lMin);
				}

				if(userAttList[i].HoliCnt != null && userAttList[i].HoliCnt >0){
					taAttArray = setTimeTableArray_Free('N',sYMD,eYMD,Number(userAttList[i].v_HoliStartTime.substring(0,2)),Number(userAttList[i].v_HoliStartTime.substring(2,4)),Number(userAttList[i].v_HoliEndTime.substring(0,2)),Number(userAttList[i].v_HoliEndTime.substring(2,4)), cSH, cSM, cEH, cEM,aSSH,aSSM,aSEH,aSEM,lHour,lMin);
				}
			}else if(WorkingSystemType===2){// 2:선택 근무제

				if (userAttList[i].GoWorkTimeYn == "Y") {
					taAttDayStartHour = Number(userAttList[i].GoWorkStartTimeHour);
					taAttDayStartMin = Number(userAttList[i].GoWorkStartTimeMin);
				}else{
					if(userAttList[i].v_AttStartHour!=null){
						taAttDayStartHour = Number(userAttList[i].v_AttStartHour);
						taAttDayStartMin = Number(userAttList[i].v_AttStartMin);
					}else{
						taAttDayStartHour = 0;
						taAttDayStartMin = 0;
					}
				}
				if (userAttList[i].OffWorkTimeYn == "Y") {
					taAttDayEndHour = Number(userAttList[i].OffWorkEndTimeHour);
					taAttDayEndMin = Number(userAttList[i].OffWorkEndTimeMin);
				}else{
					if(userAttList[i].v_AttEndHour!=null){
						taAttDayEndHour = Number(userAttList[i].v_AttEndHour);
						taAttDayEndMin = Number(userAttList[i].v_AttEndMin);
					}else{
						taAttDayEndHour = 23;
						taAttDayEndMin = 59;
					}
				}
				if(userAttList[i].v_NextDayYn=="Y" && Number(userAttList[i].AttAc)>0){
					taAttDayEndHour++;
				}
				var aSSH = 0;
				var aSSM = 0;
				var aSEH = 0;
				var aSEM = 0;
				var aESH = 0;
				var aESM = 0;
				var aEEH = 0;
				var aEEM = 0;
				if (userAttList[i].GoWorkTimeYn == "Y") {
					aSSH = Number(userAttList[i].GoWorkStartTimeHour);
					aSSM = Number(userAttList[i].GoWorkStartTimeMin);
					aSEH = Number(userAttList[i].GoWorkEndTimeHour);
					aSEM = Number(userAttList[i].GoWorkEndTimeMin);
				}/*else{
				aSSH = 0;
				aSSM = 0;
				aSEH = 11;
				aSEM = 59;
			}*/
				if (userAttList[i].OffWorkTimeYn == "Y") {
					aESH = Number(userAttList[i].OffWorkStartTimeHour);
					aESM = Number(userAttList[i].OffWorkStartTimeMin);
					aEEH = Number(userAttList[i].OffWorkEndTimeHour);
					aEEM = Number(userAttList[i].OffWorkEndTimeMin);
				}/*else{
				aESH = 12;
				aESM = 0;
				aEEH = 23;
				aEEM = 59;
			}*/

				var schCoreTimeYn = userAttList[i].CoreSchTimeYn;
				var comCoreTime = userAttList[i].CoreTime;
				var cSH = 0;
				var cSM = 0;
				var cEH = 0;
				var cEM = 0;
				if(schCoreTimeYn==='Y'){
					cSH = Number(userAttList[i].CoreStartTimeHour);
					cSM = Number(userAttList[i].CoreStartTimeMin);
					cEH = Number(userAttList[i].CoreEndTimeHour);
					cEM = Number(userAttList[i].CoreEndTimeMin);
				}else if(comCoreTime!=null&&comCoreTime!=""&&comCoreTime.indexOf("~")>-1){
					var arrCT = comCoreTime.split("~");
					var arrCTS = arrCT[0].split(":");
					var arrCTE = arrCT[1].split(":");
					cSH = Number(arrCTS[0]);
					cSM = Number(arrCTS[1]);
					cEH = Number(arrCTE[0]);
					cEM = Number(arrCTE[1]);
				}

				taAttArray = setTimeTableArrayV2(nextDayYn,sYMD,eYMD, taAttDayStartHour, taAttDayStartMin, taAttDayEndHour, taAttDayEndMin, cSH, cSM, cEH, cEM, aSSH, aSSM, aSEH, aSEM, aESH, aESM, aEEH, aEEM);

				if(userAttList[i].ExtenCnt != null && userAttList[i].ExtenCnt > 0){
					taAttArray = setTimeTableArrayV2(nextDayYn,sYMD,eYMD,taAttDayStartHour,taAttDayStartMin,Number(userAttList[i].v_ExtenEndTime.substring(0,2)),Number(userAttList[i].v_ExtenEndTime.substring(2,4)), cSH, cSM, cEH, cEM, aSSH, aSSM, aSEH, aSEM, aESH, aESM, aEEH, aEEM);
				}

				if(userAttList[i].HoliCnt != null && userAttList[i].HoliCnt >0){
					taAttArray = setTimeTableArrayV2('N',sYMD,eYMD,Number(userAttList[i].v_HoliStartTime.substring(0,2)),Number(userAttList[i].v_HoliStartTime.substring(2,4)),Number(userAttList[i].v_HoliEndTime.substring(0,2)),Number(userAttList[i].v_HoliEndTime.substring(2,4)), cSH, cSM, cEH, cEM, aSSH, aSSM, aSEH, aSEM, aESH, aESM, aEEH, aEEM);
				}
			}
			var divTemp = $("#myAttWeekDivTemp").clone();
			divTemp = divTemp.removeAttr("id");
			divTemp = divTemp.addClass("toggleDayStatus");

			var divHeader = divTemp.find("table thead tr");
			var divAtt = divTemp.find("table tbody tr").eq(0);
			var divBody = divTemp.find("table tbody tr").eq(1);
			var divBodyText = divTemp.find("table tbody tr").eq(2);


			var taStart = true;
			var taEnd = false;
			var taEndCnt = 0;

			var startTimeNum = 0;

			var vAttStartHour = 0;
			var vAttStartMin = 0;
			var vAttEndHour = 0;
			var vAttEndMin = 0;
			if(WorkingSystemType===0){//지정근무지 - 일반
				vAttStartHour = Number(userAttList[i].v_AttStartHour);
				vAttStartMin = Number(userAttList[i].v_AttStartMin);
				vAttEndHour = Number(userAttList[i].v_AttEndHour);
				vAttEndMin = Number(userAttList[i].v_AttEndMin);
			}else if(WorkingSystemType===1) {//자율근무제
				vAttStartHour = Number(userAttList[i].v_AttStartHour);
				vAttStartMin = Number(userAttList[i].v_AttStartMin);
				vAttEndHour = Number(userAttList[i].v_AttEndHour);
				vAttEndMin = Number(userAttList[i].v_AttEndMin);
			}else if(WorkingSystemType===2) {//선택근무제
				vAttStartHour = Number(userAttList[i].v_AttStartHour);
				vAttStartMin = Number(userAttList[i].v_AttStartMin);
				vAttEndHour = Number(userAttList[i].v_AttEndHour);
				vAttEndMin = Number(userAttList[i].v_AttEndMin);
			}

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
					var min = k==1?"00":"30";
					divBodyTd.attr("title",dayNum+":"+min);
					if(taAttArray[j][k]=="Y"){startTimeNum++;}
					if(taAttArray[j][k]=="Y" && Number(userAttList[i].VacCnt)<1){
						divBodyTd.addClass("Admit");
						//선택근로제의 출근 가능 시간 범위 표기
						if(k==1 && taAttArray[j][5]=="Y"){
							divBodyTd.removeClass("Admit");
							divBodyTd.addClass("AdmitAble");
						}
						if(k==2 && taAttArray[j][6]=="Y"){
							divBodyTd.removeClass("Admit");
							divBodyTd.addClass("AdmitAble");
						}

						//선택근로제의 퇴근 가능 시간 범위 표기
						if(k==1 && taAttArray[j][7]=="Y"){
							divBodyTd.removeClass("Admit");
							divBodyTd.addClass("AdmitAble");
						}
						if(k==2 && taAttArray[j][8]=="Y"){
							divBodyTd.removeClass("Admit");
							divBodyTd.addClass("AdmitAble");
						}

						//코어 타임 설정있는경우 표기
						if(k==1 && taAttArray[j][3]=="Y"){
							divBodyTd.removeClass("Admit");
							divBodyTd.addClass("Coretime");
						}
						if(k==2 && taAttArray[j][4]=="Y"){
							divBodyTd.removeClass("Admit");
							divBodyTd.addClass("Coretime");
						}

						if (userAttList[i].HoliCnt >0){
							divBodyTd.addClass("HolidayW");
							divAttTd.addClass("HolidayW");
							divClass = 'title_text1';
							divText = "<spring:message code='Cache.lbl_att_holiday_work' />";
						}
						else if (userAttList[i].ExtenAc>0 && taAttDayEndHour < taAttArray[j][0]){
							divBodyTd.addClass("Extend");
							divAttTd.addClass("Extend");
							divClass = 'title_text3';
							divText = '<spring:message code="Cache.lbl_att_overtime_work" />';
						}
						else{
							divClass = 'title_text1';
							divText = "<spring:message code='Cache.lbl_n_att_acknowledgedWork'/>";
						}

					}//end if 1 or 2 == Y

					if (taStart && userAttList[i].v_AttStartHour != null && userAttList[i].v_AttStartMin != null
							&& vAttStartHour==Number(dayNum) && k==1 && vAttStartMin<30){
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
					if (taStart  && userAttList[i].v_AttStartHour != null && userAttList[i].v_AttStartMin != null
							&& vAttStartHour==Number(dayNum) && k==2 && vAttStartMin>=30){
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

					/*if ((k == 1 && taAttArray[j][k+1]=="N")
                            || (k == 2 && (j+1)<taAttArray.length && taAttArray[j+1][1]=="N")
                        ){*/
					if(taStart==false){
						if(nextDayYn && taAttArray[j][9]==eYMD){
							taEnd = true;
						}else if(!nextDayYn){
							taEnd = true;
						}

						if(vAttEndHour==Number(dayNum) && userAttList[i].v_AttEndHour != null && userAttList[i].v_AttEndMin != null
								&& k==1 && vAttEndMin<30
								&& taEnd){
							divBodyTd.addClass("End");
							divAttTd.addClass("End");
							if (userAttList[i].EndSts == "lbl_att_leaveErly"){
								divAttTd.addClass("Late");
								divAttTd.append("<p class='title_text'><spring:message code='Cache.lbl_att_leaveErly' /></p>");
							}
							else
								divAttTd.append("<p class='title_text'><spring:message code='Cache.lbl_att_offWork' /></p>");
						}
						if(vAttEndHour==Number(dayNum) && userAttList[i].v_AttEndHour != null && userAttList[i].v_AttEndMin != null
								&& k==2 && vAttEndMin>=30
								&& taEnd){
							divBodyTd.addClass("End");
							divAttTd.addClass("End");
							if (userAttList[i].EndSts == "lbl_att_leaveErly"){
								divAttTd.addClass("Late");
								divAttTd.append("<p class='title_text'><spring:message code='Cache.lbl_att_leaveErly' /></p>");
							}
							else
								divAttTd.append("<p class='title_text'><spring:message code='Cache.lbl_att_offWork' /></p>");
						}
					} //end if taStart==false


					if (userAttList[i].VacFlag != null && userAttList[i].VacFlag != "")
					{
						var vacAmPmVacDay = userAttList[i].VacAmPmVacDay;
						var arrVacAmPmVacDay = null;
						if(vacAmPmVacDay.indexOf("|")>-1){
							arrVacAmPmVacDay = vacAmPmVacDay.split('|');
						}
						if (Number(arrVacAmPmVacDay[0])>=0.5 || Number(arrVacAmPmVacDay[1])>=0.5){
							if (Number(arrVacAmPmVacDay[0])>=0.5 && userAttList[i].VacOffFlag.indexOf("AM")>-1){

								if (startTimeNum>5 && startTimeNum < 10){
									divBodyTd.addClass("Annual");
									divAttTd.addClass("Annual");
									divClass = 'title_text5';
									divText = AttendUtils.vacNameConvertor(userAttList[i].VacOffFlag,userAttList[i].VacCodeName,'AM',0); //반차

								}

							}
							else if (Number(arrVacAmPmVacDay[1])>=0.5 && userAttList[i].VacOffFlag.indexOf("PM")>-1){
								if (startTimeNum>14 && startTimeNum <= 18){
									divBodyTd.addClass("Annual");
									divAttTd.addClass("Annual");
									divClass = 'title_text5';
									divText = AttendUtils.vacNameConvertor(userAttList[i].VacOffFlag,userAttList[i].VacCodeName,'PM',0); //반차

								}

							}
						}else if (Number(userAttList[i].VacCnt)>=1){
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
					divBodyTextTd.append("<p class='"+divClass+"'>"+divText+"</p>");
					divAtt.append(divAttTd);
					divBody.append(divBodyTd);
					divBodyText.append(divBodyTextTd);

				}//end for

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

		//월 법정시간 표기/가리기 처리
		if(FreePartAttCnt>0){
			$("#dl_monthlyMaxWorkTime").show();
		}else{
			$("#dl_monthlyMaxWorkTime").hide();
		}
	}


	function setMonthHtml(){
		var FreePartAttCnt = 0;
		$("#dl_weeklyAvgTime").show();
		var userMonthAttWorkTime = _attMonthMap.userAttWorkTime;

		/* 상단 날짜 표시 */
		$(".title").html(_attMonthRangeFromToDateMap.TargetDate.substring(0,7));
		_stDate = _attMonthRangeFromToDateMap.p_sDate;
		_edDate = _attMonthRangeFromToDateMap.p_eDate;

		/* 상단 시간 표시 */
		/* 상단 시간 표시 */
		var totWorkTime = Number(userMonthAttWorkTime.TotWorkTime);
		var attAcN = Number(userMonthAttWorkTime.AttAcN) + Number(userMonthAttWorkTime.ExtenAcN) + Number(userMonthAttWorkTime.HoliAcN);
		var totWorkTimeD = totWorkTime - attAcN;
		var totWorkTimeHtml = "<p style='cursor: pointer;' title=\""+attTimeFormat(totWorkTime)+"(<spring:message code='Cache.lbl_Weekly' />:"+attTimeFormat(totWorkTimeD)+"/<spring:message code='Cache.lbl_night' />:"+attTimeFormat(attAcN)+")\">"; //주간:야간
		if (_printDN) {
			totWorkTimeHtml += attTimeFormat(totWorkTimeD)+"/"+attTimeFormat(attAcN);
		}else{
			totWorkTimeHtml += attTimeFormat(totWorkTime);
		}
		totWorkTimeHtml += "</p>";
		$("#totWorkTime").html(totWorkTimeHtml);
		var attRealTime = userMonthAttWorkTime.AttRealTime;
		var attRealTimeD = attRealTime - attAcN;
		var workTimeHtml = "<p style='cursor: pointer;' title=\""+attTimeFormat(userMonthAttWorkTime.AttRealTime)+"(<spring:message code='Cache.lbl_Weekly' />:"+attTimeFormat(attRealTimeD)+"/<spring:message code='Cache.lbl_night' />:"+attTimeFormat(userMonthAttWorkTime.AttAcN)+")\">"; //주간:야간
		if (_printDN) {
			workTimeHtml += attTimeFormat(attRealTimeD) + "/" + attTimeFormat(userMonthAttWorkTime.AttAcN);
		}else{
			workTimeHtml += attTimeFormat(attRealTime);
		}
		workTimeHtml += "</p>";
		$("#workTime").html(workTimeHtml);
		var extendAcHtml = "<p style='cursor: pointer;' title=\""+attTimeFormat(userMonthAttWorkTime.ExtenAc)+"(<spring:message code='Cache.lbl_Weekly' />:"+attTimeFormat(userMonthAttWorkTime.ExtenAcD)+"/<spring:message code='Cache.lbl_night' />:"+attTimeFormat(userMonthAttWorkTime.ExtenAcN)+")\">"; //주간:야간
		if (_printDN) {
			extendAcHtml += attTimeFormat(userMonthAttWorkTime.ExtenAcD) + "/" + attTimeFormat(userMonthAttWorkTime.ExtenAcN);
		}else{
			extendAcHtml += attTimeFormat(userMonthAttWorkTime.ExtenAc);
		}
		extendAcHtml += "</p>";
		$("#exTime").html(extendAcHtml);
		var holiAcHtml = "";
		if (_printDN) {
			holiAcHtml = attTimeFormat(userMonthAttWorkTime.HoliAcD) + "/" + attTimeFormat(userMonthAttWorkTime.HoliAcN);
		}else{
			holiAcHtml = attTimeFormat(userMonthAttWorkTime.HoliAc);
		}
		$("#hoTime").html(holiAcHtml);
		$("#confTime").html(attTimeFormat(userMonthAttWorkTime.TotConfWorkTime));
		$("#remainTime").html(attTimeFormat(userMonthAttWorkTime.RemainTime));

		$("#workDay").html(userMonthAttWorkTime.WorkDay+"<spring:message code='Cache.lbl_day'/>");
		$("#workingDay").html(userMonthAttWorkTime.NormalCnt+"<spring:message code='Cache.lbl_day'/>");

		//월 법정근로시간
		$("#monthlyMaxWorkTime").html(attTimeFormat(_monthlyMaxWorkTime));

		var monthWrap = $("#monthWrap").clone();
		monthWrap.removeAttr("style","display:none;");
		monthWrap.removeAttr("id");

		/* 근태현황 월간 table header  */
		var header = monthWrap.find(".calMonHeader");
		header.find(".calMonTbl tbody tr").html("");
		var dayList = _attMonth[2].userAtt[0].userAttList;
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

		for(var m=0;m<_attMonth.length;m++){

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

				//자율출근 또는 선택 근로제인경우 월 법정 근로시간 표기 여부 체크용 카운트 처리
				if(userAttList[j].WorkingSystemType==2){
					FreePartAttCnt++;
				}

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

				var holPrintFlag = false;
				//출퇴근 상태표기
				if(_viewIdx == 0) {
					var htmlAttDayTime = "";
					var startPointX = userAttList[j].StartPointX;
					var startPointY = userAttList[j].StartPointY;
					var startAddr = userAttList[j].StartAddr;
					var endPointX = userAttList[j].EndPointX;
					var endPointY = userAttList[j].EndPointY;
					var endAddr = userAttList[j].EndAddr;
					htmlAttDayTime += userAttList[j].v_AttDayStartHour + ":" + userAttList[j].v_AttDayStartMin;
					if((startPointX!=null) && startPointY!=null) {
						htmlAttDayTime += "<a class=\"btn_gps_chk\" data-point-x=\""+startPointX+"\" data-point-y=\""+startPointY+"\" data-addr=\""+startAddr+"\"></a>";
					}
					htmlAttDayTime += " ~ " + userAttList[j].v_AttDayEndHour + ":" + userAttList[j].v_AttDayEndMin;
					if(endPointX!=null && endPointY!=null) {
						htmlAttDayTime += "<a class=\"btn_gps_chk\" data-point-x=\""+endPointX+"\" data-point-y=\""+endPointY+"\" data-addr=\""+endAddr+"\"></a>";
					}
					if (htmlAttDayTime.indexOf("null") > -1) {
						htmlAttDayTime = "&nbsp;";
					}
					if ((userAttList[j].WorkSts == "HOL" || userAttList[j].WorkSts == "OFF") && userAttList[j].HoliAc > 0) {
						htmlAttDayTime = "<span style='color: #e8b139;font-weight: bold;'><spring:message code='Cache.lbl_att_holiday_work' /></span>";
					}
					var attAcN = userAttList[j].AttAcN + userAttList[j].ExtenAcN + userAttList[j].HoliAcN;
					var dayTimeTd = $('<td />', {});
					dayTimeTd.html("<p class='tx_etc' style='text-align: left;'>" + htmlAttDayTime + "</p>");
					var totWorkTime = userAttList[j].TotWorkTime;
					if (_printDN) {
						dayTimeTd.append("<p class='tx_etc' style='color: " + AttendUtils.userWorkTimeOverColorV2(userAttList[j].userWorkInfo, totWorkTime, "D", "#777777") + ";'><%=DicHelper.getDic("lbl_total")%><%=DicHelper.getDic("lbl_att_work")%> : " + attTimeFormat(totWorkTime - attAcN) + "/" + attTimeFormat(attAcN) + "</p>");//총근무
					}else{
						dayTimeTd.append("<p class='tx_etc' style='color: " + AttendUtils.userWorkTimeOverColorV2(userAttList[j].userWorkInfo, totWorkTime, "D", "#777777") + ";'><%=DicHelper.getDic("lbl_total")%><%=DicHelper.getDic("lbl_att_work")%> : " + attTimeFormat(totWorkTime) + "</p>");//총근무
					}
					var attRealTime = userAttList[j].AttRealTime;

					if (_printDN) {
						dayTimeTd.append("<p class='tx_etc' style='color: " + AttendUtils.userWorkTimeOverColorV2(userAttList[j].userWorkInfo, attRealTime, "D", "#777777") + ";'><%=DicHelper.getDic("lbl_att_sch_rec")%> : " + attTimeFormat(attRealTime - attAcN) + "/" + attTimeFormat(attAcN) + "</p>");//인정
					}else{
						dayTimeTd.append("<p class='tx_etc' style='color: " + AttendUtils.userWorkTimeOverColorV2(userAttList[j].userWorkInfo, attRealTime, "D", "#777777") + ";'><%=DicHelper.getDic("lbl_att_sch_rec")%> : " + attTimeFormat(attRealTime) + "</p>");//인정
					}
					if (_printDN) {
						dayTimeTd.append("<p class='tx_etc'><spring:message code='Cache.lbl_att_overtime'/> : " + attTimeFormat(userAttList[j].ExtenAcD) + "/" + attTimeFormat(userAttList[j].ExtenAcN) + "</p>");
					}else{
						dayTimeTd.append("<p class='tx_etc'><spring:message code='Cache.lbl_att_overtime'/> : " + attTimeFormat(userAttList[j].ExtenAc) + "</p>");
					}
					if (_printDN) {
						dayTimeTd.append("<p class='tx_etc'><spring:message code='Cache.lbl_Holiday'/> : " + attTimeFormat(userAttList[j].HoliAcD) + "/" + attTimeFormat(userAttList[j].HoliAcN) + "</p>");
					}else{
						dayTimeTd.append("<p class='tx_etc'><spring:message code='Cache.lbl_Holiday'/> : " + attTimeFormat(userAttList[j].HoliAc) + "</p>");
					}
					if(userAttList[j].WorkingSystemType == 2) {
						dayTimeTd.append("<p class='tx_etc'> 월 누적 : " + attTimeFormat(userAttList[j].MonthlyAttAcSum) + "</p>");
					}
					dayTimeTd.attr("onclick","AttendUtils.openAttMyStatusPopup('"+userAtt.userCode+"','"+dayList+"')");

					if($("#ckb_incld_weeks").is(":checked")==false &&
							_targetDate.replaceAll("-","").substring(0,6) != dayList.replaceAll("-","").substring(0,6)){
						dayTimeTd.attr("style","cursor: pointer;background-color: #f5f5f5;");
					}else{
						dayTimeTd.attr("style","cursor: pointer;");
					}
					if(userAttList[j].WorkingSystemType == 2) {
						//월 근무시간 합이 월 법정근무시간을 넘기면
						if (userAttList[j].MonthlyAttAcSum >= _monthlyMaxWorkTime) {
							dayTimeTd.attr("style", "cursor: pointer; background: lightgray !important;");
						} else {
							dayTimeTd.attr("style", "cursor: pointer;");
						}
					} else {
						dayTimeTd.attr("style", "cursor: pointer;");
					}
					calGrid.find("tbody tr").append(dayTimeTd);

				}else if(_viewIdx == 1){	//전체
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
						endTime.html(AttendUtils.hhmmToFormat(userAttList[j].v_ExtenEndTime));
					}

				}else if(_viewIdx == 2){	//누적일정 ( 출퇴근 )
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
						endTime.html(AttendUtils.hhmmToFormat(userAttList[j].v_ExtenEndTime));
					}
				}else if(_viewIdx == 3){	//계획일정 ( 근무제 )
					startClass = 'WorkBox Half one';
					startTitle.html(schName);	//근무제
					startTime.html(userAttList[j].v_AttDayStartTime!=null?userAttList[j].v_AttDayStartTime:'');	//출근일정시간

					endClass = 'WorkBox Half one';
					endTitle.html(schName);	//근무제
					endTime.html(userAttList[j].v_AttDayEndTime!=null?userAttList[j].v_AttDayEndTime:'');	//출근일정시간
				}


				//휴무일
				if(userAttList[j].WorkSts == "OFF"|| userAttList[j].WorkSts == "HOL"){
					if(Number(userAttList[j].HoliCnt)>0){
						startClass = 'WorkBox Holywork';
						startTitle.html("<spring:message code='Cache.lbl_att_holiday_work' />");

						if(userAttList[j].v_AttStartTime==null || userAttList[j].v_AttEndTime==null){
							startTime.html(AttendUtils.hhmmToFormat(userAttList[j].v_HoliStartTime)
									+"<br/>"
									+AttendUtils.hhmmToFormat(userAttList[j].v_HoliEndTime));
						}else{
							startTime.html(userAttList[j].v_AttStartTime+"<br/>"+userAttList[j].v_AttEndTime);
						}

						endClass = '';
						endTitle.html("");
						endTime.html("");
					}else {
						startClass = 'WorkBox Holyday';
						startTitle.html(userAttList[j].WorkSts == "OFF" ? "<spring:message code='Cache.lbl_att_sch_holiday' />" : "<spring:message code='Cache.lbl_Holiday' />");
						startTime.html("");

						endClass = "";
						endTitle.html("");
						endTime.html("");
					}
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

				if(_viewIdx!=0 || holPrintFlag){

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

					if(userAttList[j].WorkingSystemType == 2) {
						//월 근무시간 합이 월 법정근무시간을 넘기면
						if (userAttList[j].MonthlyAttAcSum >= _monthlyMaxWorkTime) {
							calTd.attr("style", "background: lightgray !important;");
						}
					}

					calTd.attr("onclick","AttendUtils.openAttMyStatusPopup('"+userAtt.userCode+"','"+dayList+"')");

					calGrid.find("tbody tr").append(calTd);

				}
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

				if($("#ckb_incld_weeks").is(":checked")==false &&
						_targetDate.replaceAll("-","").substring(0,6) != dayList.replaceAll("-","").substring(0,6)){
					dayTd.addClass("disable");
				}

				monSchList.find("tbody tr").append(dayTd);
			}
			var attWeeklyRealTime = userAttWorkTime.AttRealTime;
			var totWeeklyWorkTime = userAttWorkTime.TotWorkTime;
			var weeklyWorkDay = Number(userAttWorkTime.WorkDay);
			var weeklyWorkTime = Number(userAttWorkTime.WorkTime);
			var totWeeklyWorkTimeColor = "#4abde1";
			if(totWeeklyWorkTime>(9*60*weeklyWorkTime)){
				totWeeklyWorkTimeColor = "#ff0000";
			}else if(totWeeklyWorkTime>(8*60*weeklyWorkDay)){
				totWeeklyWorkTimeColor = "#f08264";
			}
			var weekTimeTd = "<td style=\"background-color: #fffdf0;\">";
			weekTimeTd += "<p class='tx_time_total' style='color: "+AttendUtils.userWorkTimeOverColorV2(userAttList[userAttList.length-1].userWorkInfo, totWeeklyWorkTime, "W", "#4abde1")+";'>"+attTimeFormat(totWeeklyWorkTime)+"</p>";
			weekTimeTd += "<p class='tx_etc'><%=DicHelper.getDic("lbl_att_sch_rec")%> : "+attTimeFormat(attWeeklyRealTime)+"</p>";
			weekTimeTd += "<p class='tx_etc'><spring:message code='Cache.lbl_att_overtime'/> : "+attTimeFormat(extenAc)+"</p>";
			weekTimeTd += "<p class='tx_etc'><spring:message code='Cache.lbl_Holiday'/> : "+attTimeFormat(holiAc)+"</p>";
			weekTimeTd += "<p class='tx_etc'><spring:message code='Cache.lbl_n_att_AttRealTime'/> : "+attTimeFormat(totConfWorkTime)+"</p>";
			var remainTimeHtml = "";
			// 주 단위를 체크했을 경우
			if($("#ckb_incld_weeks").is(":checked")) {
				var remainTimeHtml = "";
				if(remainTime < 0) {
					remainTime = Math.abs(remainTime);
					remainTimeHtml = "<p class='tx_etc' style=\"color: #f08264;\"><spring:message code='Cache.lbl_n_att_remain'/> : "+attTimeFormat(remainTime) + " "+Common.getDic("lbl_above")+"</p>";
				}else{
					remainTimeHtml = "<p class='tx_etc'><spring:message code='Cache.lbl_n_att_remain'/> : "+attTimeFormat(remainTime)+"</p>";
				}
				weekTimeTd += remainTimeHtml;
			}

			weekTimeTd += "</td>";
			calGrid.find("tbody tr").append(weekTimeTd);
			monSchList.find("tbody tr").append("<td></td>");

			body.append(contentsClone);
		}
		var valWeeklyAvgWorkTime  = _attMonthMap.threeMonthsAvgWorkTime;
		var threeMonthsAvgWorkTimeInfo = _attMonthMap.threeMonthsAvgWorkTimeInfo;
		var htmlWeeklyAvgWorkTime = attTimeFormat(valWeeklyAvgWorkTime);
		$("#weeklyAvgTime").html(htmlWeeklyAvgWorkTime);
		$("#weeklyAvgTime").attr("title",threeMonthsAvgWorkTimeInfo);

		$(".tblList").html(monthWrap);

		//월 법정시간 표기/가리기 처리
		if(FreePartAttCnt>0){
			$("#dl_monthlyMaxWorkTime").show();
		}else{
			$("#dl_monthlyMaxWorkTime").hide();
		}

	}//end Monthly


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
	}

	function setTimeTableArray(nextYn,sYMD,eYMD,sHour,sMin,eHour,eMin, sCHour,sCMin,eCHour,eCMin){

		var timeArray = new Array();
		for(var t=0;t<24;t++){
			var minArray = [t,'N','N','N','N','N','N','N','N',sYMD];
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

			for(var t=0;t<=eHour;t++){
				var minArray = [t,'N','N','N','N','N','N','N','N',eYMD];

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
			//코어타임 설정시
			if(sCHour!=null&&eCHour!=null){
				for(var at=sCHour;at<=eCHour;at++ ){

					timeArray[at][3] = 'Y';
					timeArray[at][4] = 'Y';

					if(sCHour==at){
						if(sCMin>=30){
							timeArray[at][3] = 'N';
							timeArray[at][4] = 'Y';
						}else{
							timeArray[at][3] = 'Y';
							timeArray[at][4] = 'Y';
						}
					}

					if(eCHour==at){
						if(eCMin>=30){
							timeArray[at][3] = 'Y';
							timeArray[at][4] = 'N';
						}else{
							timeArray[at][3] = 'N';
							timeArray[at][4] = 'N';
						}
					}
				}
			}
		}
		return timeArray;
	}

	function setTimeTableArray_Free(nextYn,sYMD,eYMD,sHour,sMin,eHour,eMin, sCHour,sCMin,eCHour,eCMin,aSSH,aSSM,aSEH,aSEM,lHour,lMin){
		var timeArray = new Array();
		for(var t=0;t<24;t++){
			var minArray = [t,'N','N','N','N','N','N','N','N',sYMD];
			timeArray.push(minArray);
		}

		if(nextYn=="Y"){
			var ycut = false;
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

				if(lHour!=""&&lMin!=""){
					if(lHour<at){
						ycut = true;
						timeArray[at][1] = 'N';
						timeArray[at][2] = 'N';
					}else if(lHour==at){
						ycut = true;
						timeArray[at][1] = 'N';
						timeArray[at][2] = 'N';
						if(lMin>=30){
							timeArray[at][1] = 'Y';
							timeArray[at][2] = 'N';
						}
					}
				}
			}

			for(var t=0;t<=eHour;t++){
				var minArray = [t,'N','N','N','N','N','N','N','N',eYMD];

				if(eHour>=t && ycut==false){
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

				if(lHour!=null&&lHour!=""&&lMin!=null&&lMin!=""){
					if(lHour<t){
						minArray[1] = 'N';
						minArray[2] = 'N';
					}else if(lHour==t){
						minArray[1] = 'N';
						minArray[2] = 'N';
						if(lMin>=30){
							minArray[1] = 'Y';
							minArray[2] = 'N';
						}
					}
				}
				timeArray.push(minArray);
			}

			//코어타임 설정시
			if(sCHour!=null&&eCHour!=null){
				for(var at=sCHour;at<=eCHour;at++ ){

					timeArray[at][3] = 'Y';
					timeArray[at][4] = 'Y';

					if(sCHour==at){
						if(sCMin>=30){
							timeArray[at][3] = 'N';
							timeArray[at][4] = 'Y';
						}else{
							timeArray[at][3] = 'Y';
							timeArray[at][4] = 'Y';
						}
					}

					if(eCHour==at){
						if(eCMin>=30){
							timeArray[at][3] = 'Y';
							timeArray[at][4] = 'N';
						}else{
							timeArray[at][3] = 'N';
							timeArray[at][4] = 'N';
						}
					}
				}
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
			//코어타임 설정시
			if(sCHour!=null&&eCHour!=null){
				for(var at=sCHour;at<=eCHour;at++ ){

					timeArray[at][3] = 'Y';
					timeArray[at][4] = 'Y';

					if(sCHour==at){
						if(sCMin>=30){
							timeArray[at][3] = 'N';
							timeArray[at][4] = 'Y';
						}else{
							timeArray[at][3] = 'Y';
							timeArray[at][4] = 'Y';
						}
					}

					if(eCHour==at){
						if(eCMin>=30){
							timeArray[at][3] = 'Y';
							timeArray[at][4] = 'N';
						}else{
							timeArray[at][3] = 'N';
							timeArray[at][4] = 'N';
						}
					}
				}
			}
			//출근가능시간
			if(aSSH!=null&&aSEH!=null){
				for(var at=aSSH;at<=aSEH;at++ ){

					timeArray[at][5] = 'Y';
					timeArray[at][6] = 'Y';

					if(aSSH==at){
						if(aSSM>=30){
							timeArray[at][5] = 'N';
							timeArray[at][6] = 'Y';
						}else{
							timeArray[at][5] = 'Y';
							timeArray[at][6] = 'Y';
						}
					}
					if(aSEH==at){
						if(aSEM>=30){
							timeArray[at][5] = 'Y';
							timeArray[at][6] = 'N';
						}else{
							timeArray[at][5] = 'N';
							timeArray[at][6] = 'N';
						}
					}
				}
			}
		}
		return timeArray;
	}

	function setTimeTableArrayV2(nextYn,sYMD,eYMD,sHour,sMin,eHour,eMin, sCHour,sCMin,eCHour,eCMin,aSSH,aSSM,aSEH,aSEM,aESH,aESM,aEEH,aEEM){

		var timeArray = new Array();
		for(var t=0;t<24;t++){
			var minArray = [t,'N','N','N','N','N','N','N','N',sYMD];
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
				var minArray = [t,'N','N','N','N','N','N','N','N',eYMD];

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

			//코어타임 설정시
			if(sCHour!=null&&eCHour!=null){
				for(var at=sCHour;at<=eCHour;at++ ){

					timeArray[at][3] = 'Y';
					timeArray[at][4] = 'Y';

					if(sCHour==at){
						if(sCMin>=30){
							timeArray[at][3] = 'N';
							timeArray[at][4] = 'Y';
						}else{
							timeArray[at][3] = 'Y';
							timeArray[at][4] = 'Y';
						}
					}

					if(eCHour==at){
						if(eCMin>=30){
							timeArray[at][3] = 'Y';
							timeArray[at][4] = 'N';
						}else{
							timeArray[at][3] = 'N';
							timeArray[at][4] = 'N';
						}
					}
				}
			}
			//출근가능시간
			if(aSSH!=null&&aSEH!=null){
				for(var at=aSSH;at<=aSEH;at++ ){

					timeArray[at][5] = 'Y';
					timeArray[at][6] = 'Y';

					if(aSSH==at){
						if(aSSM>=30){
							timeArray[at][5] = 'N';
							timeArray[at][6] = 'Y';
						}else{
							timeArray[at][5] = 'Y';
							timeArray[at][6] = 'Y';
						}
					}
					if(aSEH==at){
						if(aSEM>=30){
							timeArray[at][5] = 'Y';
							timeArray[at][6] = 'N';
						}else{
							timeArray[at][5] = 'N';
							timeArray[at][6] = 'N';
						}
					}
				}
			}
			//퇴근가능시간
			if(aESH!=null&&aEEH!=null){
				for(var at=aESH;at<=aEEH;at++ ){

					timeArray[at][7] = 'Y';
					timeArray[at][8] = 'Y';

					if(aESH==at){
						if(aESM>=30){
							timeArray[at][7] = 'N';
							timeArray[at][8] = 'Y';
						}else{
							timeArray[at][7] = 'Y';
							timeArray[at][8] = 'Y';
						}
					}
					if(aEEH==at){
						if(aEEM<30){
							timeArray[at][7] = 'Y';
							timeArray[at][8] = 'N';
						}else{
							timeArray[at][7] = 'Y';
							timeArray[at][8] = 'Y';
						}
					}
				}
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
			//코어타임 설정시
			if(sCHour!=null&&eCHour!=null){
				for(var at=sCHour;at<=eCHour;at++ ){

					timeArray[at][3] = 'Y';
					timeArray[at][4] = 'Y';

					if(sCHour==at){
						if(sCMin>=30){
							timeArray[at][3] = 'N';
							timeArray[at][4] = 'Y';
						}else{
							timeArray[at][3] = 'Y';
							timeArray[at][4] = 'Y';
						}
					}

					if(eCHour==at){
						if(eCMin>=30){
							timeArray[at][3] = 'Y';
							timeArray[at][4] = 'N';
						}else{
							timeArray[at][3] = 'N';
							timeArray[at][4] = 'N';
						}
					}
				}
			}
			//출근가능시간
			if(aSSH!=null&&aSEH!=null){
				for(var at=aSSH;at<=aSEH;at++ ){

					timeArray[at][5] = 'Y';
					timeArray[at][6] = 'Y';

					if(aSSH==at){
						if(aSSM>=30){
							timeArray[at][5] = 'N';
							timeArray[at][6] = 'Y';
						}else{
							timeArray[at][5] = 'Y';
							timeArray[at][6] = 'Y';
						}
					}
					if(aSEH==at){
						if(aSEM>=30){
							timeArray[at][5] = 'Y';
							timeArray[at][6] = 'N';
						}else{
							timeArray[at][5] = 'N';
							timeArray[at][6] = 'N';
						}
					}
				}
			}
			//퇴근가능시간
			if(aESH!=null&&aEEH!=null){
				for(var at=aESH;at<=aEEH;at++ ){

					timeArray[at][7] = 'Y';
					timeArray[at][8] = 'Y';

					if(aESH==at){
						if(aESM>=30){
							timeArray[at][7] = 'N';
							timeArray[at][8] = 'Y';
						}else{
							timeArray[at][7] = 'Y';
							timeArray[at][8] = 'Y';
						}
					}
					if(aEEH==at){
						if(aEEM<=30){
							timeArray[at][7] = 'Y';
							timeArray[at][8] = 'N';
						}else{
							timeArray[at][7] = 'Y';
							timeArray[at][8] = 'Y';
						}
					}
				}
			}
		}
		return timeArray;
	}
</script>
<!-- <div id='loading-spinner'>
	<div><span>
		<img src='/groupware/resources/images/loader.gif'>
	</span></div>
</div> -->