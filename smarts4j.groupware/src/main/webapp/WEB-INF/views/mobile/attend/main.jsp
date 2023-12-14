<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="egovframework.baseframework.util.SessionHelper" %>
<%@ page import="egovframework.coviframework.util.ComUtils"%>
<%@ page import="egovframework.coviframework.util.ClientInfoHelper"%>
<%
	String serverTime = ComUtils.GetLocalCurrentDate("yyyy/MM/dd/HH/mm/ss");
	boolean isMobile = ClientInfoHelper.isMobile(request);
	String useTeamsAddIn = "N";
	String userAgent = request.getHeader("User-Agent");
	String pIsTeamsAddIn = request.getParameter("teamsaddin");
    if ((userAgent != null && userAgent.toLowerCase().indexOf("teams") > -1) || (pIsTeamsAddIn != null && pIsTeamsAddIn.toUpperCase().equals("Y"))) {
    	useTeamsAddIn = "Y";
    }
%>
<style>

</style>

<div data-role="page" id="attend_main_page" class="mob_rw">
<script>
	var urTheme = 0;
	var AttendMenu = ${Menu};//좌측 메뉴
	var g_WorkingSystemType = 0;//2자율출근
	var g_TodayAttStartTime = null;
	var g_TodayAttEndTime = null;
	var g_TodayAttDayStartTime = null;
	var g_TodayAttDayEndTime = null;
	var g_TodayAttStartTagTime = null;
	var g_TodayAttEndTagTime = null;
	var g_SchName = "";

	/*
    사용자 timezone 에 따른 현재시간 정보
    */
	var serverTimeStr = "<%=serverTime%>";
	var spServerTime = serverTimeStr.split("/");
	var serverTime = new Date(spServerTime[0],spServerTime[1]-1,spServerTime[2],spServerTime[3],spServerTime[4],spServerTime[5]);
	var clientTime = new Date();
	var time_diff = serverTime.getTime() - clientTime.getTime();
	function setMenuTime(){
		var now_client_time = new Date();
		var now_server_time = new Date(now_client_time.getTime() + time_diff);
		$(".tx_hour").html(formatAMPM(now_server_time));//현재 시간정보 표기
		$(".tx_date").html(formatDateInfo(now_server_time));//현재 날일 정보 표기
		//출근 태그 기준 근무 시간 표기
		if(g_WorkingSystemType===0){//자율출근체 출근시간 기준 근무시간 계산처리
			// 0:지정시간 1:자율, 2:선택
			if(g_TodayAttEndTagTime==null) {//퇴근 미태그 시 - 출근전 또는 출근 태그후 퇴근 전까지
				if (g_TodayAttStartTime != null && g_TodayAttDayStartTime != null) {
					var TodayAttStartTime = new Date(g_TodayAttStartTime);
					var TodayAttDayStartTime = new Date(g_TodayAttDayStartTime.replaceAll("-","/"));
					if(now_server_time.getTime()>=TodayAttDayStartTime.getTime() && g_TodayAttStartTagTime!=null) {//출근시간 시작시간이 지났으면 카운터 동작
						if (TodayAttStartTime.getTime() > TodayAttDayStartTime.getTime()) {//출근을 출근 시작 일정 시간보다 늦으면(지각)
							var TodayAttWorkingTime = now_server_time.getTime() - TodayAttStartTime.getTime();
							$("#tx_todayWorkTime").html(msToTime(TodayAttWorkingTime));
						} else {
							var TodayAttWorkingTime = now_server_time.getTime() - TodayAttDayStartTime.getTime();
							$("#tx_todayWorkTime").html(msToTime(TodayAttWorkingTime));
						}
					}
				}
			}else {//퇴근 한 상태
				if (g_TodayAttStartTime != null && g_TodayAttEndTime != null && g_TodayAttDayStartTime != null) {
					var TodayAttStartTime = new Date(g_TodayAttStartTime);
					var TodayAttEndTime = new Date(g_TodayAttEndTime);
					var TodayAttDayStartTime = new Date(g_TodayAttDayStartTime.replaceAll("-","/"));
					var TodayAttDayEndTime = new Date(g_TodayAttDayEndTime.replaceAll("-","/"));
					var SchSETime = TodayAttDayEndTime.getTime() - TodayAttDayStartTime.getTime();
					if(SchSETime!=0){//스케쥴 일정 시간 이 등록된 케이스
						if (TodayAttStartTime.getTime() > TodayAttDayStartTime.getTime()) {//출근을 출근 시작 일정 시간보다 늦으면(지각)
							if (TodayAttEndTime.getTime() < TodayAttDayEndTime.getTime()) {//조퇴시
								var TodayAttWorkingTime = TodayAttEndTime.getTime() - TodayAttStartTime.getTime();
								$("#tx_todayWorkTime").html(msToTime(TodayAttWorkingTime));
							}else{
								var TodayAttWorkingTime = TodayAttDayEndTime.getTime() - TodayAttStartTime.getTime();
								$("#tx_todayWorkTime").html(msToTime(TodayAttWorkingTime));
							}
						}else{//정상 출근
							if (TodayAttEndTime.getTime() < TodayAttDayEndTime.getTime()) {//조퇴시
								var TodayAttWorkingTime = TodayAttEndTime.getTime() - TodayAttDayStartTime.getTime();
								$("#tx_todayWorkTime").html(msToTime(TodayAttWorkingTime));
							}else{
								var TodayAttWorkingTime = TodayAttDayEndTime.getTime() - TodayAttDayStartTime.getTime();
								$("#tx_todayWorkTime").html(msToTime(TodayAttWorkingTime));
							}
						}
					}else{//스케쥴 시작/종료 시간 미등록시 00:00 ~ 00:00
						var TodayAttWorkingTime = TodayAttEndTime.getTime() - TodayAttStartTime.getTime();
						$("#tx_todayWorkTime").html(msToTime(TodayAttWorkingTime));
					}
				}
			}
		}else{//근무스케줄 기준 근무 시간 계산 처리
			if(g_TodayAttEndTagTime==null) {//퇴근 미태그 시 - 출근전 또는 출근 태그후 퇴근 전까지
				if (g_TodayAttStartTime != null && g_TodayAttDayStartTime != null) {
					//var TodayAttDayStartTime = new Date(g_TodayAttDayStartTime);
					var TodayAttStartTime = new Date(g_TodayAttStartTime);
					var TodayAttWorkingTime = now_server_time.getTime() - TodayAttStartTime.getTime();
					$("#tx_todayWorkTime").html(msToTime(TodayAttWorkingTime));
				}
			}else {
				if (g_TodayAttStartTime != null && g_TodayAttEndTime != null && g_TodayAttDayStartTime != null) {
					var TodayAttStartTime = new Date(g_TodayAttStartTime);
					var TodayAttEndTime = new Date(g_TodayAttEndTime);
					var TodayAttWorkingTime = TodayAttEndTime.getTime() - TodayAttStartTime.getTime();
					$("#tx_todayWorkTime").html(msToTime(TodayAttWorkingTime));
				}
			}
		}
	}

	function formatAMPM(date) {
		var hours = date.getHours();
		var minutes = date.getMinutes();
		var sec = date.getSeconds();
		var ampm = hours >= 12 ? '<span class="tx_hour_ampm">PM</span>' : '<span class="tx_hour_ampm">AM</span>';
		hours = hours % 12;
		hours = hours ? hours : 12; // the hour '0' should be '12'
		hours = hours < 10 ? '0'+hours : hours;
		minutes = minutes < 10 ? '0'+minutes : minutes;
		sec = sec < 10 ? '0'+sec : sec;
		var strTime = ampm+hours + ':' + minutes + ':' + sec;
		return strTime;
	}


	function formatDateInfo(date) {
		var year = date.getFullYear();
		var month = date.getMonth()+1;
		var dates = date.getDate();
		var days = Number(date.getDay());
		var dayStr = "";
		month = month < 10 ? '0'+month : month;
		dates = dates < 10 ? '0'+dates : dates;
		switch(days){
			case 0 :dayStr = "일";break;
			case 1 :dayStr = "월";break;
			case 2 :dayStr = "화";break;
			case 3 :dayStr = "수";break;
			case 4 :dayStr = "목";break;
			case 5 :dayStr = "금";break;
			case 6 :dayStr = "토";break;
		}
		var rtnDate = year + '.' + month + '.' + dates+' '+dayStr;
		return rtnDate;
	}

	function formatWorkingTime(date) {
		var hours = date.getHours();
		var minutes = date.getMinutes();
		hours = hours < 10 ? '0'+hours : hours;
		minutes = minutes < 10 ? '0'+minutes : minutes;
		var wTime = hours + '시간 ' + minutes + '분'
		return wTime;
	}

	function msToTime(s) {
		var ms = s % 1000;
		s = (s - ms) / 1000;
		var secs = s % 60;
		s = (s - secs) / 60;
		var mins = s % 60;
		var hrs = (s - mins) / 60;

		return hrs + '시간 ' + mins + '분';
	}
	$(document).ready(function(){
		urTheme = mobile_comm_getSession("UR_ThemeType");
		var intervalID = setInterval(setMenuTime, 1000); //현재시간
		AttendMobile.init();
	});

	$(window).resize(function() {
		//기본정보 로딩
		AttendMobile.init();
	});
</script>

<input type="hidden" id="useTeamsAddIn" value="<%=useTeamsAddIn%>"/>
<input type="hidden" id="isMobile" value="<%=isMobile%>"/>
<input type="hidden" id="PointX" value=""/>
<input type="hidden" id="PointY" value=""/>
<input type="hidden" id="userCode" value="<%=SessionHelper.getSession("USERID")%>" />
	<header data-role="header" id="attend_main_header">
	      <div class="sub_header">
	        <div class="l_header">
				<%--<a href="javascript: mobile_comm_openleftmenu();" class="btn_back ui-link"><span>이전페이지로 이동</span></a>--%>
                <a href="javascript:mobile_comm_TopMenuClick('attend_list_topmenu');" class="topH_menu"><span><spring:message code='Cache.lbl_FullMenu'/></span></a> <!-- 전체메뉴 -->
                <div class="menu_link gnb">
					<a href="#" class="pg_tit"><spring:message code='Cache.BizSection_Attendance'/></a> <!-- 근태관리 -->
					<div class="cover_leftmenu" style="display:none;">
						<div class="LsubHeader">
							<span class="LsubTitle board"><spring:message code='Cache.BizSection_Attendance' /></span> <!-- 근태관리 -->
							<span class="LsubTitle_btn">
								<button type="button" onclick="mobile_comm_TopMenuClick('attend_list_topmenu',true);return false;" class="btn_close ui-btn ui-shadow ui-corner-all"><i><spring:message code='Cache.btn_Close' /></i></button>
							</span>
						</div>
						<div class="tree_default" id="attend_list_topmenu"></div>
					</div>
					<div class="left_bg_dim" onclick="mobile_comm_TopMenuClick('attend_list_topmenu',true);return false;" style="display: none;"></div>
				</div>
	        </div>
			<div class="utill">
                <%--<a href="javascript:mobile_comm_TopMenuClick('attend_list_topmenu');"><span class="Hicon"><spring:message code='Cache.lbl_FullMenu'/></span></a>--%> <!-- 전체메뉴 -->
                <div class="dropMenu" style="display: none;">
					<a href="#" class="topH_exmenu" onclick="javascript: mobile_task_showORhide(this);"><span class="Hicon">확장메뉴</span></a>
					<div class="exmenu_layer">
						<ul id="attendance_view_ulBtnArea" class="exmenu_list"></ul>
					</div>
				</div>
			</div>
	      </div>
    </header>
	<div data-role="content"  class="cont_wrap" id="attend_main_content">
		<div class="day_working_top" style="height: 195px;">
			<p class="tx_user"><span class="meta" style="width: 40%;background-color: white;display: inline-block;opacity: 0.3;">&nbsp;</span> / <span class="meta" style="width: 40%;background-color: white;display: inline-block;opacity: 0.3;">&nbsp;</span></p>
			<p class="tx_todayhour"><span class="tx_today">Today</span><span id="tx_todayWorkTime">0시간 00분</span></p>
			<p class="tx_date">0000.00.00 목</p>
			<p class="tx_hour"><span class="tx_hour_ampm">PM</span>00:00:00</p>
			<p class="tx_state" id="tx_state">대기중</p>
			<p class="tx_standardhour">00:00~00:00</p>
			<div class="btn_workout_wrap" id="attStsBtn">
				<a href="#" class="btn_workout ui-link" name="start" style="width:49%;"><spring:message code='Cache.btn_att_checkin'/></a> <!-- 출근하기 -->
				<a href="#" class="btn_workout ui-link" name="end" style="width:49%;margin-left:1%;"><spring:message code='Cache.btn_att_checkout'/></a> <!-- 퇴근하기 -->
			</div>

			<div class="am_time_wrap_type2" style="margin-top: 5px;padding: 0 0 0 0;">
				<dl class="am_time"><dt><span class="am_time_tit"><spring:message code='Cache.lbl_att_goWork'/></span></dt><dd><span class="am_time_tx03 normal" id="startSts" style="margin-inline-start: -30px;"></span></dd></dl>
				<dl class="am_time"><dt><span class="am_time_tit"><spring:message code='Cache.lbl_att_offWork'/></span></dt><dd><span class="am_time_tx03 normal" id="endSts" style="margin-inline-start: -30px;"></span></dd></dl>
			</div>
		</div>
		
	 	<div class="slide_bar">
			<span class="slide_color" id="sSlide_bar">바</span>
		</div>
		
		<div class="am_map_wrap" id="map"></div>
		<div class="day_working_cont">
			<div class="day_working_cont_top" style="height:83px;">
				<p class="day_working_cont_title">근태 현황</p>
				<!--달력주간컨트롤 시작-->
				<div class="calendar_ctrl" style="top:-35px;left:15px;">
					<div class="month_ctrl">
						<a href="#" class="prev_month ui-link dayChg" data-paging="-"></a>
						<p class="t_month"><a href="#" class="ui-link" id="dayRoun"></a></p>
						<a href="#" class="next_month ui-link dayChg" data-paging="+"></a>
					</div>
					<a href="#" class="btn_today ui-link" id="todayBtn" style="right:20px;"><spring:message code='Cache.lbl_Todays'/></a><!-- 오늘  -->
				</div>
				<!--달력주간컨트롤 끝-->
			</div>
			<div class="day_working_list am_time_list_wrap_type2" style="border-radius: 0;border-top: solid 1px #999;">
				<ul class="am_time_list" id="bodyList"></ul>
			</div>
			<div class="day_working_cont_top">
				<p class="day_working_cont_title">주간 근무 현황</p>
			</div>
			<div class="week_workinghours" style="height: 170px;">
				<p class="week_wh_title">주간 총 근무시간</p>
				<p class="week_wh_hour" id="week_wh_hour">36시간 27분</p><!-- 40시간 넘을 경우 class="week_wh_hour over40" 적용 -->
				<dl class="week_ex_hour01"><dt>인정근무</dt><dd>4시간 0분</dd></dl>
				<dl class="week_ex_hour02"><dt>연장근무</dt><dd>3시간 30분</dd></dl>
				<dl class="week_ex_hour03"><dt>휴일근무</dt><dd>3시간 30분</dd></dl>
				<div class="week_wh_graph">
					<div class="graph_limit_bar" id="graph_limit_bar"></div>
					<div class="graph_background_bg" id="graph_background_bg"></div>
					<div class="graph_bar_holi" id="graph_bar_holi" style="width:80%;"></div>
					<div class="graph_bar_exten" id="graph_bar_exten" style="width:60%;"></div>
					<div class="graph_bar_real" id="graph_bar_real" style="width:50%;"></div>
					<div class="graph_bar" id="graph_bar" style="width:0%;"></div><!-- 40시간 넘을 경우 class="graph_bar over40" 적용 -->
					<p class="graph_mark" id="graph_mark">40</p>
					<p class="graph_mark_real" id="graph_mark_real">21시간 24분</p>
					<p class="graph_tx_start" id="graph_tx_start">0h</p>
					<p class="graph_tx_end" id="graph_tx_end">52h</p>
				</div>
			</div>
			<%--<div class="day_working_cont_top">
				<p class="day_working_cont_title">근무 신청</p>
			</div>
			<div class="day_working_list">
				<dl class="day_working_dl">
					<dt>연장근무</dt>
					<dd><span class="tx_application">신청</span>3시간</dd>
				</dl>
				<dl class="day_working_dl">
					<dt>휴일근무</dt>
					<dd>-</dd>
				</dl>
				<dl class="day_working_dl">
					<dt>휴가정보</dt>
					<dd>-</dd>
				</dl>
			</div>--%>
		</div>
<% if ("Y".equals(useTeamsAddIn) && !isMobile) { %>
	    <!-- 작성, 업무시스템 바로가기 사용시 -->
	    <div id="divPopBtnArea" class="FloatingBtn">
	        <ul class="popBtn">
				<li class="btnNewPopup"><a href="javascript:void(0);" onclick="XFN_TeamsOpenGroupware('ATTENDANCE');">새창</a><span class="toolTip2">새창</span></li>
	        </ul>
	    </div>
<% } else { %>
		<div class="amWorkStatusAddBTN">
			<a href="#" class="ui-link" id="jobBtn"><span>작성</span></a>
		</div>
<% } %>
	</div>

<ul id="tempList" style="display:none;">
	<li>	
		<p class="am_time_list_day">
			<span class="tx_day"></span>
			<span class="tx_day_s"></span>
		</p>	
		<p class="am_time_list_cont">
			<span style="float: left;"></span>
			<span style="float: left;"></span>
		</p>	
		<p class="am_time_list_status"></p>
	</li>
</ul>

<form id="jobFrm" method="post">
<div class="mobile_popup_wrap jobPopup" id="jobPopup" style="z-index: 99999 ; display:none;" >
    	<div class="card_list_popup">
			<div class="post_ex_area"> 
				<div class="post_ex">
					<span class="th"><spring:message code='Cache.lbl_att_workDate'/></span><!-- 근무일 -->
					<span class="tx">
						<div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset">
							<!-- JobDate에  required 넣으면 소명신청 등 결제 폼 required 체크에 걸림 따라서 뺌, 2022.01.10 nkpark 일정 신청은 자체 폼 체킹 하므로 ..-->
							<input type="text" value="" class="input_date" name="JobDate" id="JobDate" readonly="readonly" onfocus="this.blur()" inputmode="none">
						</div>
					</span>
				</div>   
				<div class="post_ex">
					<span class="th"><spring:message code='Cache.lbl_att_workTime'/></span><!-- 근무시간 -->
					<span class="tx"><span class="sub_span">시작</span>
						<div class="ui-select">
							<div id="select-40-button" class="ui-btn ui-icon-carat-d ui-btn-icon-right ui-corner-all ui-shadow">
								<select class="input_time" name="StartTime" id="StartTime">
									<c:forEach var="i" begin="00" end="23" step="1">
										<option value="<c:if test="${i < 10 }">0</c:if>${i }00"><c:if test="${i < 10 }">0</c:if>${i }:00</option>
										<option value="<c:if test="${i < 10 }">0</c:if>${i }30"><c:if test="${i < 10 }">0</c:if>${i }:30</option>
									</c:forEach>
								</select>
							</div>
						</div>
						<span class="sub_span" style="margin-top: 5px">종료</span>
						<div class="ui-select">
							<div id="select-41-button" class="ui-btn ui-icon-carat-d ui-btn-icon-right ui-corner-all ui-shadow">
							<select class="input_time" name="EndTime" id="EndTime" style="margin-top: 5px">
		               			<c:forEach var="i" begin="00" end="23" step="1">
									<option value="<c:if test="${i < 10 }">0</c:if>${i }00"><c:if test="${i < 10 }">0</c:if>${i }:00</option>
									<option value="<c:if test="${i < 10 }">0</c:if>${i }30"><c:if test="${i < 10 }">0</c:if>${i }:30</option>
								</c:forEach>
		             		 </select>
		             		 </div>
		             	</div>
					</span>
				</div>   
				<div class="post_ex">
					<span class="th"><spring:message code='Cache.lbl_att_806_s_1_h'/></span><!-- 근무유형 -->
					<span class="tx">
						<select class="" name="JobStsSeq" id="jobSelectBox"></select>
					</span> 
				</div>      	  
				<div class="post_ex">
					<span class="th"><spring:message code='Cache.lbl_Remark'/></span><!-- 비고 -->
					<span class="tx"><textarea id="Etc" name="Etc"  class="post_ex_textarea" placeholder="비고"></textarea></span>
				</div>
			</div> 
			<div class="mobile_popup_btn">
				<a href="#" class="g_btn03" onclick="AttendMobile.saveJob();"><spring:message code='Cache.lbl_Confirm'/></a><!-- 확인  -->
				<a href="#" class="g_btn04" onclick="AttendMobile.closeLayer()"><spring:message code='Cache.lbl_Cancel'/></a><!-- 취소  -->
			</div>
		</div>
    </div>
</form>
<div class="mobile_popup_wrap attReqPopup" style="z-index: 99999; display:none;">
   	<div class="card_list_popup">
		<div class="post_ex_area"> 
			<div class="post_ex">
				<span class="th"><spring:message code='Cache.lbl_Reason'/></span><!-- 사유 -->
			</div>   
			<div class="post_ex">
				<span class="tx">
					<textarea id="userEtc"></textarea>
				</span>
			</div>   

		</div> 
		<div class="mobile_popup_btn">
			<a href="#" class="g_btn03" onclick="AttendMobile.requestCommute();"><spring:message code='Cache.lbl_Confirm'/></a><!-- 확인  -->
			<a href="#" class="g_btn04" onclick="AttendMobile.closeReqPopup();"><spring:message code='Cache.lbl_Cancel'/></a><!-- 취소  -->
		</div>
	</div>
</div>
</div>
