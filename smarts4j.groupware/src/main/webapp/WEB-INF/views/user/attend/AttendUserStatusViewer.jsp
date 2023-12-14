<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="egovframework.baseframework.util.RedisDataUtil"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.coviframework.util.ComUtils"%>
<%@ page import="egovframework.coviframework.util.DicHelper"%>
<%
	String userNowDate = ComUtils.GetLocalCurrentDate("yyyy-MM-dd");
	String attConfirmYn = RedisDataUtil.getBaseConfig("AttConfirmYn");
%>
<style>
	.WRule_Sel {position:relative; clear:both; margin:10px auto; width:75px;}
	.WRule_Sel .btnSelDay {width:76px;display:inline-block;padding:0 20px;width:75px;height:30px;line-height:28px;background:#fff url(/HtmlSite/smarts4j_n/AttendanceManagement/resources/images/btnSelDay.png) no-repeat 55px 50%;border:1px solid #d5d5d5;border-radius:3px;text-align:center;}
	.WRule_Sel .SelDay_layer {position:absolute; top:28px; left:0; list-style:none; margin:0; padding:0; width:75px; background-color:#fff; border:1px solid #d5d5d5; z-index:10;}
	.WRule_Sel .SelDay_layer li {margin:0; padding:0;}
	.WRule_Sel .SelDay_layer li a {display:inline-block; padding:0 10px; width:100%; height:30px; line-height:28px; border-top:1px solid #e0e0e0;}
	.WRule_Sel .SelDay_layer li.selected a {background-color:#f2f2f2;}
	.WRule_Sel .SelDay_layer li a:hover {background-color:#f2f2f2;}
	/*#realTimeTr{diplay:none}*/
	.WorkBoxM.Absent {background-color:#E6E1E0 !important;}
	.WorkBoxM.LeaveErly {background-color:#e5acac !important;}
	.WorkBoxM.BeingLate {background-color:#e7ccac !important;}
	.WorkBoxM.Calling {background-color:#fdc755 !important;}
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


	.mCSB_inside > .mCSB_container {margin:0;text-overflow:clip;overflow:visible;}
	.mCSB_scrollTools .mCSB_dragger .mCSB_dragger_bar {margin:2px auto;width:5px;background-color:rgba(255,255,255,0.1);}
	.mCSB_scrollTools .mCSB_draggerRail {display:none;}
	.scrollBarType02 .mCSB_scrollTools .mCSB_dragger .mCSB_dragger_bar {background-color:rgba(0,0,0,0.1);}
	.mCSB_scrollTools a + .mCSB_draggerContainer {margin:5px 0;}
	.mCSB_scrollTools {z-index:2;}
	.scrollVType01 .mCSB_scrollTools .mCSB_dragger .mCSB_dragger_bar {background-color:rgba(0,0,0,0.1);}
	.mCSB_container_wrapper{
		position: absolute;
		height: auto;
		width: auto;
		overflow: hidden;
		top: 0;
		left: 0;
		right: 0;
		bottom: 0;
		margin: 0;
	}
	.ATMInfo > p.Holywork { background:none !important; }
	.ATMInfo > p.Holywork:before {content:''; display:inline-block; width:10px; height:10px; background-color: #e8b139; color:#d99c19; border-radius:10px; vertical-align:top; margin:2px 5px 0 0;}
	.ATMInfo > p.BeingLate { background:none !important; }
	.ATMInfo > p.BeingLate:before {content:''; display:inline-block; width:10px; height:10px; background-color: #e7ccac; color:#75aaac; border-radius:10px; vertical-align:top; margin:2px 5px 0 0;}
	.ATMInfo > p.LeaveErly { background:none !important; }
	.ATMInfo > p.LeaveErly:before {content:''; display:inline-block; width:10px; height:10px; background-color: #e5acac; color:#75aaac; border-radius:10px; vertical-align:top; margin:2px 5px 0 0;}
	.WorkBoxW.BeingLate {background-color:#e7ccac; color:#75aaac;}
	.WorkBoxW.LeaveErly {background-color:#e5acac; color:#75aaac;}
	.WorkBoxW.Holywork {position:absolute; top:0; padding:15px 0; height:48px; background-color: #e8b139; border:1px dashed #d99c19;}
	.WorkBoxM.Holywork {position:absolute; top:0; padding:0; height:62px; background-color:#e8b139; border:1px dashed #d99c19;}
	
	.half_book {
		background-image: linear-gradient(45deg, white, white 25%, transparent 25%, transparent 50%, white 50%, white 75%, transparent 75%, transparent) !important;
	    background-size: 5px 5px !important;
	    background-color: #9da4ff;
	}
	
	.ATMInfo > p.AttConfirm { background:none !important; }
	.ATMInfo > p.AttConfirm:before {content:''; display:inline-block; width:10px; height:10px; background-color: #9da4ff;  background-size: 5px 5px !important; color:#75aaac; vertical-align:top; margin:2px 5px 0 0; background-image: linear-gradient(45deg, white, white 25%, transparent 25%, transparent 50%, white 50%, white 75%, transparent 75%, transparent) !important;}
	
	<% if("Y".equals(attConfirmYn)) { %>
	#attTable .ATMTable.top_line tr:first-child td:nth-child(2) {background: #ffffff;}
	#attTable .ATMTable.top_line tr:first-child td:nth-child(3) {background: #fffdf0;}
	<% } %>
	
	.attendance_pc {
	    display: inline-block;
	    width: 17px;
	    height: 17px;
	    background: url(/covicore/resources/images/common/ic_attendance_pc.png);
	    vertical-align: middle;
	    margin: -2px 0 0 5px;
	}
	
	.attendance_secom {
	    display: inline-block;
	    width: 17px;
	    height: 17px;
	    background: url(/covicore/resources/images/common/ic_attendance_secom.png);
	    vertical-align: middle;
	    margin: -2px 0 0 5px;
	}
	
	.attendance_caution {
	    display: inline-block;
	    width: 17px;
	    height: 17px;
	    background: url(/covicore/resources/images/common/ic_attendance_caution.png);
	    vertical-align: middle;
	    margin: -2px 0 0 5px;
	}
</style>
<div class="cRConTop titType AtnTop">
	<h2 class="title"></h2>
	<div class="pagingType02">
		<a href="#" class="AXPaging_begin dayChg" data-paging="--" style="top: -3px;margin: 5px 3px 0 0 !important;display: none;"></a>
		<a href="#" class="AXPaging_prev dayChg" data-paging="-" style="top: -3px;margin: 5px 3px 0 0 !important;"></a>
		<a href="#" class="AXPaging_next dayChg" data-paging="+" style="top: -3px;margin: 5px 3px 0 0 !important;"></a>
		<a href="#" class="AXPaging_end dayChg" data-paging="++" style="top: -3px;margin: 5px 3px 0 0 !important;display: none;"></a>
		<a href="#" class="btnTypeDefault"  id="btnToday"><spring:message code='Cache.lbl_Todays'/></a>
		<a href="#" class="btnTypeDefault cal" id="btnCalendar"></a>
		<input type="text" id="inputCalendarcontrols" style="height: 0px; width:0px; border: 0px;" />
	</div>
	<div class="searchBox02 WRule_Sel" style="right: 240px;top: 3px;font-size: 14px;display: none;" id="div_unitTerm">
		<a href="#" id="unitTerm" class="btnSelDay unitTerm" data-workvalue=""><spring:message code='Cache.btn_Select' /></a>
		<ul class="SelDay_layer"></ul>
	</div>
	<div class="searchBox02">
		<span><input type="text" id="sUserTxt"/><button type="button" id="searchBtn" class="btnSearchType01"><spring:message code='Cache.lbl_search'/></button></span>
	</div>
</div>
<div class='cRContBottom' style="overflow: hidden;">
	<!-- 컨텐츠 시작 -->
	<div class="ATMCont">
		<div class="ATMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a href="#" id="setAttBtn" class="s_active btnTypeDefault btnTypeBg btnAttAdd"><spring:message code='Cache.lbl_n_att_history'/> <spring:message code='Cache.btn_Add'/>/<spring:message code='Cache.btn_Edit'/></a>
				<a href="#" id="commuteBtn" class="btnTypeDefault" style="display: none;"><spring:message code='Cache.lbl_allCommute'/></a>
				<%if (!RedisDataUtil.getBaseConfig("ExcelSaveYnAdmin").equals("N")){%>
				<a class="btnTypeDefault btnExcel" id="excelBtn" href="#"><spring:message code='Cache.lbl_SaveToExcel'/></a>
				<%} %>
				<a class="btnTypeDefault btnExcel" id="excelBtnWeekly" href="#"><spring:message code='Cache.lbl_SaveToExcel'/></a>
				<div class="ATMTop_info_Time" id="div_monthlyMaxWorkTime" style="display: none;">
					<dl class="ATMTime_dl">
						<dt><spring:message code='Cache.lbl_MonthlyLegalWork' /></dt> <!-- 월 법정근로시간 -->
						<dd><span class="tx_normal" id="span_monthlyMaxWorkTime"></span></dd>
					</dl>
				</div>
				<% if("Y".equals(attConfirmYn)) { %>
					<a href="#" id="attConfirmBtn" class="btnTypeDefault" style="display: none;">근태확정</a>
					<a href="#" id="attCancelBtn" class="btnTypeDefault" style="display: none;">근태확정취소</a>
				<% } %>
			</div>
			<div class="ATMbuttonStyleBoxRight">
				<ul class="ATMschSelect">
					<li class="pageToggle selected" data-tabid="0"><a href="#"><spring:message code='Cache.lbl_Weekly' /></a></li>
					<li class="pageToggle" data-tabid="1"><a href="#"><spring:message code='Cache.lbl_Monthly' /></a></li>
					<li class="pageToggle" data-tabid="2"><a href="#"><%=DicHelper.getDic("lbl_Weekly")%><%=DicHelper.getDic("lbl_Tables")%></a></li> <%--주간장표 --%>
					<li class="pageToggle" data-tabid="3"><a href="#"><%=DicHelper.getDic("lbl_Monthly")%><%=DicHelper.getDic("lbl_Tables")%></a></li><%--월간장표 --%>
				</ul>
			</div>
		</div>
		<div class="ATMFilter_Info_wrap">
			<div class="ATMFilter">
				<p class="ATMFilter_title"><spring:message code='Cache.lbl_att_select_department'/></p>
				<select class="size112" id="groupPath"></select>
				<select class="size72" id="jobGubun">
					<option value=""><spring:message code='Cache.lbl_Whole'/></option>
					<option value="JobTitle"><spring:message code='Cache.lbl_JobTitle'/></option>
					<option value="JobLevel"><spring:message code='Cache.lbl_JobLevel'/></option>
				</select>
				<select class="size72" id="jobCode">
					<option value=""><spring:message code='Cache.lbl_Whole'/></option>
				</select>
				<input type="checkbox" id="retireUser" /> <spring:message code='Cache.lbl_att_retireuser'/>	<!--  퇴사자 포함 -->

				<span id ="monFilter" style="display: none;">
				<span id="monthlyFilter">
							&nbsp;<%=DicHelper.getDic("lbl_Week")%><%--주--%>
							<input id="weeklyWorkValue" maxlength="3" value="" style="width: 35px;height: 33px;" />&nbsp;<%=DicHelper.getDic("lbl_Time")%>&nbsp;<%--시간--%>
							<select class="selectType02" style="width: 68px;height: 33px;" id="weeklyWorkType">
								<option value="over"><%=DicHelper.getDic("lbl_above")%></option><%--초과--%>
								<option value="under"><%=DicHelper.getDic("lbl_below")%></option><%--이하--%>
							</select>
						</span>
				</span>
				<button href="#" class="btnRefresh" type="button" id="btnRefresh" style="margin-left: 5px;"></button>
			</div>
			<div class="ATMInfo">
				<% if("Y".equals(attConfirmYn)) { %>
				<p data-type="01" class="AttConfirm"><spring:message code='Cache.lbl_AttendConfirm'/></p>
				<% } %>
				<p data-type="01" class="BeingLate"><spring:message code='Cache.lbl_att_beingLate'/></p>
				<p data-type="01" class="LeaveErly"><spring:message code='Cache.lbl_att_leaveErly'/></p>
				<p data-type="01" class="Holywork"><spring:message code='Cache.lbl_att_holiday_work'/></p>
				<p data-type="01" class="Calling"><spring:message code='Cache.lbl_n_att_callingTarget'/></p>
				<p data-type="01" class="Normal"><spring:message code='Cache.lbl_attendance_normal'/></p>
				<p data-type="01" class="Outside"><spring:message code='Cache.lbl_OutsideWorking'/></p>
				<p data-type="01" class="Ex"><spring:message code='Cache.lbl_over'/></p>
				<p data-type="01" class="Holyday"><spring:message code='Cache.lbl_att_sch_holiday'/></p>
				<p data-type="01" class="Vacation"><spring:message code='Cache.lbl_Vacation'/></p>
				<p data-type="23"><input type="checkbox" id="ckb_daynight" checked/> <spring:message code='Cache.lbl_DayNightMarking'/></p> <!-- 주야표기 -->
				<span id="span_incld_weeks">
					<input type="checkbox" id="ckb_incld_weeks" checked/> <spring:message code='Cache.lbl_WeekByWeek'/>	<!-- 주단위 -->
				</span>
				<select class="selectType02" style="width: 68px;height: 33px;" id="PageSize" onchange="setPage(1);">
					<option value="10" selected>10</option>
					<option value="15">15</option>
					<option value="20">20</option>
					<option value="30">30</option>
					<option value="50">50</option>
					<option value="100">100</option>
				</select>
			</div>
		</div>

		<div id="WeekTable" class="resDayListCont" style="display: none;">
			<!-- 근태현황 temp 테이블 시작 -->
			<table id="attWeekTemp" class="ATMTable" cellpadding="0" cellspacing="0">
				<thead>
				<tr>
					<% if("Y".equals(attConfirmYn)) { %>
					<th width="30"><input type="checkbox" id="attWeekCheckAll" name="attWeekCheckAll" /></th>
					<% } %>
					
					<th width="150"><spring:message code='Cache.lbl_name' /></th>
					<th width="130"><div class="tfoot_box"><p class="tfoot_title"><spring:message code='Cache.lbl_att_Cumulative_duty_hours' /></p><a id="btnFilter" class="btn_open"></a></div></th>
					<th width="110"><spring:message code='Cache.lbl_Gubun' /></th>
					<th class="dayScope"></th>
					<th class="dayScope"></th>
					<th class="dayScope"></th>
					<th class="dayScope"></th>
					<th class="dayScope"></th>
					<th class="dayScope"></th>
					<th class="dayScope"></th>
				</tr>
				</thead>
			</table>

			<table id="attWeekTempTable" class="ATMTable top_line" cellpadding="0" cellspacing="0" style="display: none;">
				<tbody>
				<tr>
					<% if("Y".equals(attConfirmYn)) { %>
						<td rowspan="6" width="30" class="weekCheckbox"></td>
					<% } %>
										
					<td rowspan="6" width="150" class="attWeekTempTableTd0">
						<div class="ATMT_user_wrap type">
							<div class="ATMT_user_img"></div>
							<p class="ATMT_name"></p>
							<p class="ATMT_team"></p>
							<!-- <p class="ATMT_type">근무제</p> -->
						</div>
					</td>
					<td rowspan="6" width="130"  class="attWeekTempTableTd1">
						<p class="workTime tx_time_total"></p>
						<p class="workTime tx_etc"></p>
						<p class="workTime tx_etc"></p>
						<p class="workTime tx_etc"></p>
						<p class="workTime tx_etc"></p>
						<p class="workTime tx_etc"></p>
						<p class="workTime tx_etc"></p>
					</td>
					<td width="110"><p class="td_type"><spring:message code='Cache.lbl_att_goWork' /></p></td>
					<td>
						<a href="#" class="WorkBoxW startSts"></a>
					</td>
					<td>
						<a href="#" class="WorkBoxW startSts"></a>
					</td>
					<td>
						<a href="#" class="WorkBoxW startSts"></a>
					</td>
					<td>
						<a href="#" class="WorkBoxW startSts"></a>
					</td>
					<td>
						<a href="#" class="WorkBoxW startSts"></a>
					</td>
					<td>
						<a href="#" class="WorkBoxW startSts"></a>
					</td>
					<td>
						<a href="#" class="WorkBoxW startSts"></a>
					</td>
				</tr>
				<tr>
					<td><p class="td_type"><spring:message code='Cache.lbl_att_offWork' /></p></td>
					<td>
						<a href="#" class="WorkBoxW endSts"></a>
					</td>
					<td>
						<a href="#" class="WorkBoxW endSts"></a>
					</td>
					<td>
						<a href="#" class="WorkBoxW endSts"></a>
					</td>
					<td>
						<a href="#" class="WorkBoxW endSts"></a>
					</td>
					<td>
						<a href="#" class="WorkBoxW endSts"></a>
					</td>
					<td>
						<a href="#" class="WorkBoxW endSts"></a>
					</td>
					<td>
						<a href="#" class="WorkBoxW endSts"></a>
					</td>
				</tr>
				<tr>
					<td><p class="td_type"><spring:message code='Cache.lbl_att_work' /></p></td>
					<td class="workSts" ></td>
					<td class="workSts" ></td>
					<td class="workSts" ></td>
					<td class="workSts" ></td>
					<td class="workSts" ></td>
					<td class="workSts" ></td>
					<td class="workSts" ></td>
				</tr>
				<tr>
					<td><p class="td_type"><spring:message code='Cache.lbl_Status' /></p></td>
					<td class="jobSts"></td>
					<td class="jobSts"></td>
					<td class="jobSts"></td>
					<td class="jobSts"></td>
					<td class="jobSts"></td>
					<td class="jobSts"></td>
					<td class="jobSts"></td>
				</tr>
				<tr id="realTimeTr" style="display:none">
					<td><p class="td_type"><spring:message code='Cache.lbl_n_att_RecordTime' /></p></td>
					<td class="attReal" ></td>
					<td class="attReal" ></td>
					<td class="attReal" ></td>
					<td class="attReal" ></td>
					<td class="attReal" ></td>
					<td class="attReal" ></td>
					<td class="attReal" ></td>
				</tr>
				<tr>
					<td><p class="td_type"><spring:message code='Cache.lbl_n_att_attendSch' /></p></td>
					<td class="schName"></td>
					<td class="schName"></td>
					<td class="schName"></td>
					<td class="schName"></td>
					<td class="schName"></td>
					<td class="schName"></td>
					<td class="schName"></td>
				</tr>
				<tr>
					<td><p class="td_type"><spring:message code='Cache.lbl_AccWorkMonth' /></p></td> <!-- 월 누적 근무시간 -->
					<td class="monthlyAttAcSum"></td>
					<td class="monthlyAttAcSum"></td>
					<td class="monthlyAttAcSum"></td>
					<td class="monthlyAttAcSum"></td>
					<td class="monthlyAttAcSum"></td>
					<td class="monthlyAttAcSum"></td>
					<td class="monthlyAttAcSum"></td>
				</tr>
				</tbody>
			</table>
			<div class='ATMTable_02_scroll' id='attTable' style="overflow: auto;"></div>
		</div>

		<!----주간 끝---->


		<!----월간 ---->
		<div id="MonthTable" class="resDayListCont" style="display: none;">
			<!-- 근태현황 월간 테이블 시작 -->
			<table id="attMonthTemp" class="ATMTable" cellpadding="0" cellspacing="0" style="display:block;">
				<thead>
				<tr>
					<% if("Y".equals(attConfirmYn)) { %>
					<th rowspan="2" style="width: 30px;"></th>
					<% } %>
					<th rowspan="2" style="min-width: 190px;"><spring:message code='Cache.lbl_name' /></th>
					<th rowspan="2" style="min-width: 130px;"><spring:message code='Cache.lbl_att_Cumulative_duty_hours' /></th>
					<th style="text-align: center;" class="tx_date_month"></th>
				</tr>
				<tr>
					<th></th>
				</tr>
				</thead>
			</table>
			<table  id="attMonthTempTable" class="ATMTable" cellpadding="0" cellspacing="0"  style="display:none">
				<tbody>
				</tbody>
			</table>
			<!-- 근태현황 월간 테이블 끝 -->
			<!-- 근태현황  temp 테이블 끝 -->
			<div class='ATMTable_03_scroll' id='attMonthTable'>
				<table class="ATMTable" cellpadding="0" cellspacing="0" id="attMonthTbl">
					<colgroup>
						<% if("Y".equals(attConfirmYn)) { %>
						<col width="30">
						<% } %>
						<col width="149">
						<col width="130">
						<col>
						<col>
						<col>
						<col>
						<col>
					</colgroup>
					<tbody id="attMonthTblTbody">
					</tbody>
				</table>
			</div>
		</div>
		<!----월간 끝---->

		<!----주간장표 시작---->
		<div id="WeeklyTable" class="resDayListCont" style="display: none;">
			<table class="ATMTable" cellpadding="0" cellspacing="0" id="WeeklyTableTbl">
				<tbody>
				<tr>
					<th class="th_user_name_weekly" style="width: 190px;"><spring:message code='Cache.lbl_name' /></th>
					<th class="th_user_sum_weekly" style="width: 180px;"><spring:message code='Cache.lbl_att_Cumulative_duty_hours' /></th>
					<th id="headerWeeklyList" style="calc(100% - 330px);">
						<table style="border-top: 0px solid #969696;height: 33px; width:100%" id="headerWeeklyTbl" class="ATMTable" cellpadding="0" cellspacing="0">
							<tbody id="headerWeeklyTblTbody">
							</tbody>
						</table>
					</th>
				</tr>
				</tbody>
			</table>
			<table class="ATMTable" cellpadding="0" cellspacing="0" id="tbl_bodyWeekly">
				<tbody>
				<td style="width: 100%;vertical-align: top;" id="td_left_namesumWeekly">
					<div class="ATMTable_01_scroll scrollVType01" style="width: 100%;" id="bodyWeekly">
						<table class="ATMTable" cellpadding="0" cellspacing="0" id="bodyWeeklyTbl">
							<tbody id="bodyWeeklyTblTbody">

							</tbody>
						</table>
					</div>
				</td>
				<%--<td style="vertical-align: top; width:100%;" id="td_bodydataWeekly">
					<div class="ATMTable_01_scroll scrollVType01" id="bodyWeeklyData">
						<table class="ATMTable" cellpadding="0" cellspacing="0" style="width:100%;" id="bodyWeeklyDataTbl">
							<colgroup>
								<col width="25%">
								<col width="25%">
								<col width="25%">
								<col width="25%">
							</colgroup>
							<tbody id="bodyWeeklyDataTblTbody">

							</tbody>
						</table>
					</div>
				</td>--%>
				</tbody>
			</table>
		</div>
		<!----주간장표 끝---->

		<!----월간장표 시작---->
		<div id="DailyTable" class="resDayListCont" style="display: none;">
			<table class="ATMTable" cellpadding="0" cellspacing="0" id="DailyTableTbl">
				<tbody>
				<tr>
					<th class="th_user_name" style="width: 190px;"><spring:message code='Cache.lbl_name' /></th>
					<th class="th_user_sum" style="width: 200px;"><spring:message code='Cache.lbl_att_Cumulative_duty_hours' /></th>
					<th id="headerDailyList"  style="calc(100% - 390px);">
						<table style="border-top: 0px solid #969696;width: 100%;" id="headerDailyTbl" class="ATMTable" cellpadding="0" cellspacing="0">
							<tbody  id="headerDailyTblTbody">
							</tbody>
						</table>
					</th>
				</tr>
				</tbody>
			</table>
			<table class="ATMTable" cellpadding="0" cellspacing="0" id="tbl_bodyDaily">
				<tbody>
				<td style="width: 100%;vertical-align: top;" id="td_left_namesum">
					<div class="ATMTable_01_scroll scrollVType01" style="width: 100%;" id="bodyDaily">
						<table class="ATMTable" cellpadding="0" cellspacing="0"  style="width: 100%;" id="bodyDailyTbl">
							<tbody id="bodyDailyTblTbody">

							</tbody>
						</table>
					</div>
				</td>
				<%--<td style="vertical-align: top;" id="td_bodydata">
					<div class="ATMTable_01_scroll scrollVType01" id="bodyData">
						<table class="ATMTable" cellpadding="0" cellspacing="0" id="bodyDataTbl">
							<tbody id="bodyDataTblTbody">

							</tbody>
						</table>
					</div>
				</td>--%>
				</tbody>
			</table>
		</div>
		<!----월간장표 끝---->
	</div>
	<!-- 컨텐츠 끝 -->
</div>



<!-- 기타근무 레이어 팝업 -->
<div id="divJobPopup" style="position:initial;display:none">
	<div class="ATMgt_Work_Popup" style="width:282px;  position:absolute; z-index:105">
		<a class="Btn_Popup_close" onclick='AttendUtils.hideAttJobListPopup();'></a>
		<div class="ATMgt_Cont" id="jobListInfo"></div>
		<div class="bottom">
			<a href="#" class="btnTypeDefault" onclick='AttendUtils.hideAttJobListPopup();'><spring:message code='Cache.lbl_close' /></a>
		</div>
	</div>
</div>

<script type="text/javascript">
	var _scroller_data_y = 0;
	var _scroller_data_x = 0;
	var _scroller_data_y_w = 0;
	var _scroller_data_x_w = 0;
	var scroller_handler_w = "";
	var scroller_handler_body_w = "";
	var scroller_handler = "";
	var scroller_handler_body = "";
	var _strtWeek = parseInt(Common.getBaseConfig("AttBaseWeek"));
	var _data = null;
	var g_loadMode = false;
	var _printDN = true;
	var _weeklyTabnum = 0;
	var _weeklyDataPerWeek = 4;
	var _weeklyDataTotalPage = 0;
	var _dailyTabnum = 0;
	var _dailyDataPerWeek = 7;
	var _dailyDataTotalPage = 0;
	var _pageType = 0;
	var _todayDate = "<%=userNowDate%>";
	var _targetDate = "<%=userNowDate%>";
	var _rangeStartDate = "<%=userNowDate%>";
	var _rangeEndDate = "<%=userNowDate%>";
	var _rangeWeekNum = 4;
	var _weeklyHeaderCnt = 0;
	var _curStDate;
	var _curEdDate;
	var _stDate;
	var _edDate;

	var _wpMon = "<spring:message code='Cache.lbl_WPMon' />";
	var _wpTue = "<spring:message code='Cache.lbl_WPTue' />";
	var _wpWed = "<spring:message code='Cache.lbl_WPWed' />";
	var _wpThu = "<spring:message code='Cache.lbl_WPThu' />";
	var _wpFri = "<spring:message code='Cache.lbl_WPFri' />";
	var _wpSat = "<spring:message code='Cache.lbl_WPSat' />";
	var _wpSun = "<spring:message code='Cache.lbl_WPSun' />";

	var _days = "<spring:message code='Cache.lbl_days' />";

	var _absent = "<spring:message code='Cache.lbl_n_att_absent' />";
	var _calling = "<spring:message code='Cache.lbl_n_att_callingTarget' />";

	var _lbl_totWork = "<%=DicHelper.getDic("lbl_total")%><%=DicHelper.getDic("lbl_att_work")%>";
	var _page = 1 ;
	var _endPage = 1 ;
	var _pageSize = CFN_GetQueryString("_pageSize")== 'undefined'?10:CFN_GetQueryString("_pageSize");
	
	if(CFN_GetCookie("AttListCnt")){
		_pageSize = CFN_GetCookie("AttListCnt");
	}
	if(_pageSize===null||_pageSize===""||_pageSize==="undefined"){
		_pageSize=10;
	}

	$("#PageSize").val(_pageSize);
	var _FreePartAttCnt = 0;
	var _fistLoad = true;

	function autoResize(){
		$(".mCSB_dragger_bar").css("background-color","rgba(0,0,0,0.1)");
		
		if(_pageType === 0){
			var w_height = $('.cRContBottom').height() - 150 + 'px';
			$('#attTable').css('height',w_height);
			
			//스크롤바 로 인한 해더 요일 표기 td넓이 보정
			var w_width = $('#attTable').width() - 390;
			var attComfirmYn = Common.getBaseConfig("AttConfirmYn");
			
			if(attComfirmYn == "Y") {
				$("#attTable table tr").eq(0).find("td").each(function (idx){
					var tdW = $(this).width() + 1;
					
					if(idx == 0){
						$("#attWeekTemp thead tr").eq(0).find("th").eq(idx).css("width", "30px");
					} else if(idx == 1){
						$("#attWeekTemp thead tr").eq(0).find("th").eq(idx).css("width", "150px");
					}else if(idx == 2){
						$("#attWeekTemp thead tr").eq(0).find("th").eq(idx).css("width", "130px");
					}else if(idx == 3){
						$("#attWeekTemp thead tr").eq(0).find("th").eq(idx).css("width", "110px");
					} else if(idx > 3 && idx < 10){
						$("#attWeekTemp thead tr").eq(0).find("th").eq(idx).css("width", tdW +"px");
						w_width = w_width - tdW;
					}else if(idx == 10){
						$("#attWeekTemp thead tr").eq(0).find("th").eq(idx).css("width", (tdW+15) +"px");
					}
				});
			} else {
				$("#attTable table tr").eq(0).find("td").each(function (idx){
					var tdW = $(this).width() + 1;
					
					if(idx == 0) {
						$("#attWeekTemp thead tr").eq(0).find("th").eq(idx).css("width", "150px");
					} else if(idx == 1) {
						$("#attWeekTemp thead tr").eq(0).find("th").eq(idx).css("width", "130px");
					} else if(idx == 2) {
						$("#attWeekTemp thead tr").eq(0).find("th").eq(idx).css("width", "110px");
					} else if(idx > 2 && idx < 9) {
						$("#attWeekTemp thead tr").eq(0).find("th").eq(idx).css("width", tdW + "px");
						w_width = w_width - tdW;
					} else if(idx == 9) {
						$("#attWeekTemp thead tr").eq(0).find("th").eq(idx).css("width", (tdW+15) +"px");
					}
				});
			}
		} else if(_pageType === 1) {
			var w_ATMCont = $('.ATMCont').width() - 150 - 130 + 'px';
			$('.tx_date_month').css('width',w_ATMCont);

			var w_height = $('.cRContBottom').height() - 188 + 'px';
			$('#attMonthTable').css('height',w_height);
		} else if(_pageType===2) {
			var l_height = $('.cRContBottom').height() - 160 + 'px';
			$('#bodyWeekly').css('height',l_height);
		} else if(_pageType===3) {
			var l_height = $('.cRContBottom').height() - 210 + 'px';
			$('#bodyDaily').css('height',l_height);
			/*$('#headerDailyList > .mCSB_horizontal').css('height',"66px");
            var h_width = $('.cRContBottom').width() - 430+'px';
            $('#headerDailyList').css('width',h_width);

            var wName = $('.th_user_name').width();
            var wSum = $('.th_user_sum').width();
            $('.td_user_name').css('width',wName+'px');
            $('.td_user_sum').css('width',wSum+'px');
            $('#td_left_namesum').css('width',(wName+wSum+1)+"px");
            var tblbodyDaily_W  = $("#tbl_bodyDaily").width();
            var td_bodydata_W = tblbodyDaily_W - (wName+wSum+1);
            $('#td_bodydata').css('width',td_bodydata_W+"px");
            $('#bodyDaily').css('width',(wName+wSum)+"px");

            var d_width = $('.cRContBottom').width() - 398+'px';
            $('#bodyData').css('width',d_width);
            var dataH = $('.cRContBottom').height() - 180 + 'px';
            $('#bodyData').css('height',dataH);
            var hDTblW = $('#headerDailyTbl').width()+'px';
            $('#bodyDataTbl').css('width',hDTblW);*/
		}
	}

	function myCustomFn(id){
		var scrollTop = Math.abs($("#"+id+" .mCSB_container").position().top);
		var innerHeight = $("#"+id).height();
		var scrollHeight = $("#"+id+" .mCSB_container").prop('scrollHeight');

		if ((scrollTop + innerHeight+20) >= scrollHeight) {
			if (parseInt(_page)+1 <= parseInt(_endPage)){
				setPage(parseInt(_page)+1);
			}
		}
	}

	function loadNextPageFn(){
		if (parseInt(_page)+1 <= parseInt(_endPage)){
			setPage(parseInt(_page)+1);
		}
	}

	//오늘 클릭시
	$("#btnToday").click(function(){
		if(_pageType===2){
			var strTodayDate = replaceDate(_todayDate);
			$('#inputCalendarcontrols').val(strTodayDate.replaceAll("/","-"));
			var todayDate = new Date(strTodayDate);
			weeklyTableDateRangePrint(todayDate);
		}else{
			_targetDate = _todayDate;
		}
		reLoadList();
	});

	//달력버튼 클릭시
	$("#btnCalendar").click(function(){
		$('#inputCalendarcontrols').datepicker("show");
	});


	//일 주 페이징 출력
	function showPageing(page){
		if(page!=null){
			_endPage = page.pageCount;
		}
	}

	$(document).ready(function(){
		init();
		setPageType(_pageType);

	});
	$( window ).resize( function() {
		autoResize();
	});

	function setSelectVal(){

		$(".SelDay_layer").hide();

		var str = "";
		var chacheUt = Common.getBaseCode("UnitTerm").CacheData;
		for(var i=0;i<chacheUt.length;i++){
			if(chacheUt[i].Code.indexOf("day")==-1){
				str += "<li><a href='#' onclick='setListVal(this);' data-workvalue='"+chacheUt[i].Code+"'>"+chacheUt[i].CodeName+"</a></li>";
			}
			if(chacheUt[i].Code=="4week"){
				$("#unitTerm").text(chacheUt[i].CodeName);
				$("#unitTerm").data("workvalue",chacheUt[i].Code);
				$("#unitTerm").attr("workvalue",chacheUt[i].Code);
				_rangeWeekNum = 4;
			}
		}
		$(".unitTerm").next(".SelDay_layer").html(str);
	}

	function setListVal(o){
		$(o).parent().parent().prev('.btnSelDay').text($(o).html());
		$(o).parent().parent().prev('.btnSelDay').data("workvalue",$(o).data("workvalue"));
		$(o).parent().parent().prev('.btnSelDay').attr("workvalue",$(o).data("workvalue"));
		_rangeWeekNum = Number($(o).data("workvalue").replace("week",""));
		$(o).parent().parent().hide();
		weeklyTableDateRangePrint("");
		reLoadList();
	}

	//주간장표 검색 범위 출력(처음 탭 클릭시)
	function weeklyTableDateRangePrint(date){
		var dateInfo = null;
		if(date==null || date == ""){
			var titleDate = $(".title").html();
			if(titleDate.indexOf("~")>-1){
				var arrTitleDate = titleDate.split("~");
				dateInfo = arrTitleDate[1];
			}else{
				dateInfo = _targetDate;
			}
		}else{
			dateInfo = date;
		}
		var thisWSDate = AttendUtils.getWeekStart(new Date(replaceDate(dateInfo)), _strtWeek-1);
		thisWSDate = schedule_SetDateFormat(thisWSDate, '-');
		var thisWEDate = schedule_SetDateFormat(schedule_AddDays(thisWSDate, 6), '-');
		var rangeWeeks = Number($("#unitTerm").attr("workvalue").replace("week",""))*-1;
		_rangeStartDate = schedule_SetDateFormat(schedule_AddWeeks(thisWSDate, rangeWeeks+1), '-');
		_rangeEndDate   = thisWEDate;
		$(".title").html(schedule_SetDateFormat(_rangeStartDate,'.')+"~"+schedule_SetDateFormat(_rangeEndDate,'.'));
	}

	function init(){
		$("#inputCalendarcontrols").datepicker({
			dateFormat: 'yy-mm-dd',
			buttonText : 'calendar',
			buttonImage: Common.getGlobalProperties("css.path") +  "/covicore/resources/images/theme/blue/app_calendar.png",
			buttonImageOnly: true,
			onSelect : function(){
				var $cal = $("#inputCalendarcontrols");
				var selDate = new Date(replaceDate($cal.val()));
				if(_pageType===2){
					_targetDate = schedule_SetDateFormat(selDate,'-');
					weeklyTableDateRangePrint(selDate);
				}else{
					_targetDate = schedule_SetDateFormat(selDate,'-');
				}
				reLoadList();

			}
		});

		$(".btnSelDay").on('click',function(){
			$(this).next(".SelDay_layer").toggle();
		});
		//검색 범위 주단위 설정
		setSelectVal();


		//부서선택
		var GR_GroupPath = Common.getSession("GR_GroupPath");
		AttendUtils.getDeptList($("#groupPath"), GR_GroupPath, false, false, true);
		$("#groupPath").on('change',function(){
			reLoadList();
		});
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
			if(_pageType===2){
				setMonthlyByWeeklyHtml(_data, "reload");
			}else if(_pageType===3){
				setMonthlyByDailyHtml(_data, "reload");
			}
		});
		//날짜paging
		$(".dayChg").on('click',function() {
			if (g_loadMode) {
				Common.Warning("<spring:message code='Cache.mag_Attendance65' />");	//데이터 로딩중 입니다.
			} else {
				dayChg($(this).data("paging"));
				reLoadList();
			}
		});

		$(".pageToggle").on('click',function(){
			$("#div_monthlyMaxWorkTime").hide();
			$(".pageToggle").attr("class","pageToggle");
			$(this).attr("class","selected pageToggle");
			_page = 1;
			_weeklyTabnum = 0;
			_dailyTabnum  = 0;
			setPageType($(this).data("tabid"));
		});

		$("#setAttBtn").on('click',function(){
			if(Common.getSession("isAttendAdmin") == "ADMIN"){
				goAttStatusSetPopup();
			}
		});

		//사용자명 검색
		$("#sUserTxt").on('keypress', function(e){
			if (e.which == 13) {
				reLoadList();
			}
		});

		$("#searchBtn").on('click',function(){
			reLoadList();
		});

		//달력 검색
		setTodaySearch();

		//직급 직책 리스트 조회
		$("#jobGubun").on('change',function(){
			var memberOf = "1_"+$(this).val();
			AttendUtils.getJobList(memberOf,'jobCode');
			if($(this).val()==''){
				reLoadList();
			}
		});

		$("#jobCode").on('change',function(){
			reLoadList();
		});

		$("#retireUser").on('click',function(){
			reLoadList();
		});
		//기존, 주간 월간 근태 현황 엑셀 다운로드 처리용
		$("#excelBtn").on('click',function(){
			var popupID		= "AttendUserStatusPopup";
			var openerID	= "AttendUserStatus";
			var popupTit	= "<spring:message code='Cache.lbl_SaveToExcel' />";
			var popupYN		= "N";
			var retireUser  = "";
			if($("#retireUser").is(":checked")===true){
				retireUser = "INOFFICE";
			}
			var groupPath       = $("#groupPath").val();
			var popupUrl	= "/groupware/attendUserSts/goAttUserExcelDownPopup.do?"
					+ "popupID="		+ popupID	+ "&"
					+ "openerID="		+ openerID	+ "&"
					+ "popupYN="		+ popupYN	+ "&"
					+ "retireUser="		+ retireUser+ "&"
					+ "pageType="		+ _pageType + "&"
					+ "StartDate="		+ _curStDate + "&"
					+ "EndDate="		+ _curEdDate + "&"
					+ "groupPath="		+ encodeURIComponent(groupPath);

			Common.open("", popupID, popupTit, popupUrl, "500px", "490px", "iframe", true, null, null, true);
		});

		//추가된, 주단위 주간장표 엑셀 다운로드.
		$("#excelBtnWeekly").on('click',function(){
			var popupID		= "AttendUserStatusPopupWeekly";
			var openerID	= "AttendUserStatus";
			var popupTit	= "<spring:message code='Cache.lbl_SaveToExcel' />";
			var popupYN		= "N";
			var retireUser  = "";
			if($("#retireUser").is(":checked")===true){
				retireUser = "INOFFICE";
			}
			var ckb_incld_weeks = "";
			if($("#ckb_incld_weeks").is(":checked")===true){
				ckb_incld_weeks = "true";
			}
			var sUserTxt = $("#sUserTxt").val();
			var sJobTitleCode   = $("#jobGubun").val()==="JobTitle"?$("#jobCode").val():"";
			var sJobLevelCode   = $("#jobGubun").val()==="JobLevel"?$("#jobCode").val():"";
			var weeklyWorkType  = $("#weeklyWorkType").val();
			var weeklyWorkValue = $("#weeklyWorkValue").val();
			var groupPath       = $("#groupPath").val();
			var popupUrl	= "/groupware/attendUserSts/goAttUserWeeklyExcelDownPopup.do?"
					+ "popupID="		+ popupID	+ "&"
					+ "openerID="		+ openerID	+ "&"
					+ "popupYN="		+ popupYN	+ "&"
					+ "retireUser="		+ retireUser+ "&"
					+ "ckb_incld_weeks="+ ckb_incld_weeks+ "&"
					+ "sUserTxt="		+ sUserTxt + "&"
					+ "sJobTitleCode="	+ sJobTitleCode + "&"
					+ "sJobLevelCode="	+ sJobLevelCode + "&"
					+ "weeklyWorkType="	+ weeklyWorkType + "&"
					+ "weeklyWorkValue="+ weeklyWorkValue + "&"
					+ "printDN="		+ _printDN + "&"
					+ "pageType="		+ _pageType + "&"
					+ "StartDate="		+ _curStDate + "&"
					+ "EndDate="		+ _curEdDate + "&"
					+ "rangeWeekNum="	+ _rangeWeekNum + "&"
					+ "groupPath="		+ encodeURIComponent(groupPath);
			Common.open("", popupID, popupTit, popupUrl, "500px", "490px", "iframe", true, null, null, true);
		});
		//주단위 포함 체크 이벤트 처리
		$("#ckb_incld_weeks").on('change',function(){
			reLoadList();
		});

		//주당 시간 검색 조건 input 관련 이벤트
		$("#weeklyWorkValue").keyup(function() {
			if ($.trim($("#weeklyWorkValue").val()) != "") {
				var weeklyWorkValue = 0;
				weeklyWorkValue = Number($("#weeklyWorkValue").val());
				if(weeklyWorkValue<0){
					$("#weeklyWorkValue").val(0);
					weeklyWorkValue = Number($("#weeklyWorkValue").val());
				}
				if (!Number.isInteger(weeklyWorkValue)) {
					Common.Warning(Common.getDic("msg_ObjectUR_29"));
					$("#weeklyWorkValue").val(0);
					return false;
				}
			}
		});
		$("#weeklyWorkValue").change(function() {
			var weeklyWorkValue = 0;
			weeklyWorkValue = Number($("#weeklyWorkValue").val());
			if(weeklyWorkValue<0){
				$("#weeklyWorkValue").val(0);
			}
		});

		//검색
		$("#btnRefresh").click(function(){
			reLoadList();
		});

		// 일괄 출퇴근
		$("#commuteBtn").off("click").on("click", function(){
			goAllCommutePopup();
		});

		$("#attMonthTable").mCustomScrollbar({
			mouseWheelPixels: 20
			,scrollInertia: 5,
			callbacks:{
				onTotalScroll:function(){
					loadNextPageFn();
				}
			}
		});

		$("#bodyDaily").mCustomScrollbar({
			mouseWheelPixels: 20
			,scrollInertia: 5
			,axis:"y"
			,callbacks:{
				onTotalScroll:function(){
					loadNextPageFn();
				}
			}
		});

		$("#bodyWeekly").mCustomScrollbar({
			mouseWheelPixels: 20
			,scrollInertia: 5
			,axis:"y"
			,callbacks:{
				onTotalScroll:function(){
					loadNextPageFn();
				}
			}
		});
		
		$("#attWeekCheckAll").on('change', function() {
			if($(this).is(':checked')) {
				$("input:checkbox[name='attWeekCheck']").prop("checked", true);
			} else {
				$("input:checkbox[name='attWeekCheck']").prop("checked", false);
			}
		});		
		
		$(document).off('change', '#attMonthCheckAll').on("change", "#attMonthCheckAll", function(e) {
			if($(this).is(':checked')) {
				$("input:checkbox[name='attMonthCheck']").prop("checked", true);
			} else {
				$("input:checkbox[name='attMonthCheck']").prop("checked", false);
			}
		});
		
		$("#attConfirmBtn, #attCancelBtn").on('click', function(){
			var checkCnt = _pageType === 0 ? $("input:checkbox[name='attWeekCheck']:checked").length : $("input:checkbox[name='attMonthCheck']:checked").length;
			var dateTerm = _pageType === 0 ? "W" : "M";
			var attConfirmYn = $(this).attr("id") == "attConfirmBtn" ? "Y" : "N";
			
			if(checkCnt > 0) {
				Common.Confirm(attConfirmYn == "Y" ? Common.getDic("msg_hr_confirm_want") : Common.getDic("msg_hr_cancle_want"), 'Confirmation Dialog', function (result) {	
			        if (result) {
			        	var attData = new Object();
			        	var userArr = new Array();
			        	
			        	if(_pageType === 0) {			        		
							$("input:checkbox[name='attWeekCheck']:checked").each(function (){
								userArr.push(this.value);
							});
						} else if(_pageType === 1) {
							$("input:checkbox[name='attMonthCheck']:checked").each(function (){
								userArr.push(this.value);
							});
						}
						
						$.ajax({
			        	    url: "/groupware/attendUserSts/updateAttConfirm.do",
			        	    type: "POST",	    
			        	    data: { 
			        	    	"userList" : userArr, 
			        	    	"dateTerm" : dateTerm,
			        	    	"attConfirmYn" : attConfirmYn,
			        	    	"targetDate" : _targetDate
			        	    },
			        	    success: function (res) {
			        	    	if(res.status =="SUCCESS") {
			        	    		if(res.resultCount > 0) {
			        	    			Common.Inform(attConfirmYn == "Y" ? Common.getDic("msg_hr_confirm") : Common.getDic("msg_hr_cancle"), "Information", function(result){
											if(result){
												$("#btnRefresh").trigger("click");
											}
										});
			        	    		} else {
			        	    			Common.Inform(attConfirmYn == "Y" ? Common.getDic("msg_hr_NoDataConfirm") : Common.getDic("msg_hr_NoDataCancel"), "Information")
			        	    		}
			        	    	}
			        		},
			        		error:function(res, status, error){
			        			CFN_ErrorAjax("/groupware/attendUserSts/updateAttConfirm.do", res, status, error);
			        		}
			        	});
			        }
				});
			} else {
				Common.Inform(Common.getDic("lbl_hr_please_select"), "Information");
				return false;
			}
		});
		
		if(Common.getSession("isAttendAdmin") == "ADMIN"){
			$("#commuteBtn").show();
			$("#attConfirmBtn").show();
			$("#attCancelBtn").show();
		} else{
			$("#commuteBtn").hide();
			$("#attConfirmBtn").hide();
			$("#attCancelBtn").hide();
			$("#setAttBtn").removeClass("btnTypeBg").addClass("disabled");
		}
	}//end onload

	function xyScrollerSync(){
		if(scroller_handler==="head") {
			if (_scroller_data_x === 0) {
				$('#bodyData').mCustomScrollbar('scrollTo', "left", {
					timeout:0,
					callbacks:false
				});
			} else {
				$('#bodyData').mCustomScrollbar('scrollTo', {x: _scroller_data_x}, {
					timeout:0,
					callbacks:false
				});
			}
		}
		if(scroller_handler==="left") {
			if (_scroller_data_y === 0) {
				$('#bodyData').mCustomScrollbar('scrollTo', "top", {
					timeout:0,
					callbacks:false
				});
			} else {
				$('#bodyData').mCustomScrollbar('scrollTo', {y: _scroller_data_y}, {
					timeout:0,
					callbacks:false
				});
			}
		}
	}
	function xyScrollerSyncV2(){
		if(scroller_handler_w==="head") {
			if (_scroller_data_x_w === 0) {
				$('#bodyWeeklyData').mCustomScrollbar('scrollTo', "left", {
					timeout:0,
					callbacks:false
				});
			} else {
				$('#bodyWeeklyData').mCustomScrollbar('scrollTo', {x: _scroller_data_x_w}, {
					timeout:0,
					callbacks:false
				});
			}
		}
		if(scroller_handler_w==="left") {
			if (_scroller_data_y_w === 0) {
				$('#bodyWeeklyData').mCustomScrollbar('scrollTo', "top", {
					timeout:0,
					callbacks:false
				});
			} else {
				$('#bodyWeeklyData').mCustomScrollbar('scrollTo', {y: _scroller_data_y_w}, {
					timeout:0,
					callbacks:false
				});
			}
		}
	}


	function xyScrollerSyncBody(obj){
		var x = obj.mcs.left;
		//var y = $("#bodyDaily .mCSB_container").position().top;
		if (x === 0) {
			$('#headerDailyList').mCustomScrollbar('scrollTo', "left", {
				timeout:0,
				callbacks:false
			});
		} else {
			$('#headerDailyList').mCustomScrollbar('scrollTo', {x: x}, {
				timeout:0,
				callbacks:false
			});
		}
	}
	function xyScrollerSyncBodyV2(obj){
		var x = obj.mcs.left;
		//var y = $("#bodyDaily .mCSB_container").position().top;
		if (x === 0) {
			$('#headerWeeklyList').mCustomScrollbar('scrollTo', "left", {
				timeout:0,
				callbacks:false
			});
		} else {
			$('#headerWeeklyList').mCustomScrollbar('scrollTo', {x: x}, {
				timeout:0,
				callbacks:false
			});
		}
	}

	$("#btnFilter").on("click", function(){
		$(this).toggleClass("btn_open").toggleClass("btn_close");
		$("#attTable table").each( function() {
			$( this ).find("#realTimeTr").toggle();
			//2021.12.22 숨김tr 토글시 rowspan 대응처리
			var rowSpanNum = $( this ).find(".attWeekTempTableTd0").attr("rowspan");
			if(rowSpanNum=="6"){
				$( this ).find(".weekCheckbox").attr("rowspan","7");
				$( this ).find(".attWeekTempTableTd0").attr("rowspan","7");
				$( this ).find(".attWeekTempTableTd1").attr("rowspan","7");
			}else if(rowSpanNum=="7"){
				$( this ).find(".weekCheckbox").attr("rowspan","6");
				$( this ).find(".attWeekTempTableTd0").attr("rowspan","6");
				$( this ).find(".attWeekTempTableTd1").attr("rowspan","6");
			}
		});
	});

	function searchList(d){
		_page = 1;
		_weeklyTabnum = 0;
		_dailyTabnum = 0;
		_targetDate = d;
		clearGetAttList();
	}

	function dayChg(t){
		if("++"==t){
			if(_pageType===2){
				_fistLoad = false;
				var rangeWeeks = Number($("#unitTerm").attr("workvalue").replace("week",""));
				var titleDate = $(".title").html();
				var arrTitleDate = titleDate.split("~");
				var sdate = new Date(replaceDate(arrTitleDate[0]));
				var edate = new Date(replaceDate(arrTitleDate[1]));
				_rangeStartDate = schedule_SetDateFormat(schedule_AddWeeks(sdate, rangeWeeks), '-');
				_rangeEndDate   = schedule_SetDateFormat(schedule_AddWeeks(edate, rangeWeeks), '-');
				$(".title").html(schedule_SetDateFormat(_rangeStartDate,'.')+"~"+schedule_SetDateFormat(_rangeEndDate,'.'));
				$('#inputCalendarcontrols').val(schedule_SetDateFormat(_rangeEndDate,'-'));
			}else{
				_targetDate = _edDate;
			}
		}else if("+"==t){
			if(_pageType===2){
				_fistLoad = false;
				var rangeWeeks = 1;
				var titleDate = $(".title").html();
				var arrTitleDate = titleDate.split("~");
				var sdate = new Date(replaceDate(arrTitleDate[0]));
				var edate = new Date(replaceDate(arrTitleDate[1]));
				_rangeStartDate = schedule_SetDateFormat(schedule_AddWeeks(sdate, rangeWeeks), '-');
				_rangeEndDate   = schedule_SetDateFormat(schedule_AddWeeks(edate, rangeWeeks), '-');
				$(".title").html(schedule_SetDateFormat(_rangeStartDate,'.')+"~"+schedule_SetDateFormat(_rangeEndDate,'.'));
				$('#inputCalendarcontrols').val(schedule_SetDateFormat(_rangeEndDate,'-'));
			}else{
				_targetDate = _edDate;
			}
		}else if("--"==t){
			if(_pageType===2){
				_fistLoad = false;
				var rangeWeeks = Number($("#unitTerm").attr("workvalue").replace("week",""))*-1;
				var titleDate = $(".title").html();
				var arrTitleDate = titleDate.split("~");
				var sdate = new Date(replaceDate(arrTitleDate[0]));
				var edate = new Date(replaceDate(arrTitleDate[1]));
				_rangeStartDate = schedule_SetDateFormat(schedule_AddWeeks(sdate, rangeWeeks), '-');
				_rangeEndDate   = schedule_SetDateFormat(schedule_AddWeeks(edate, rangeWeeks), '-');
				$(".title").html(schedule_SetDateFormat(_rangeStartDate,'.')+"~"+schedule_SetDateFormat(_rangeEndDate,'.'));
				$('#inputCalendarcontrols').val(schedule_SetDateFormat(_rangeEndDate,'-'));
			}else{
				_targetDate = _stDate;
			}
		}else if("-"==t){
			if(_pageType===2){
				_fistLoad = false;
				var rangeWeeks = -1;
				var titleDate = $(".title").html();
				var arrTitleDate = titleDate.split("~");
				var sdate = new Date(replaceDate(arrTitleDate[0]));
				var edate = new Date(replaceDate(arrTitleDate[1]));
				_rangeStartDate = schedule_SetDateFormat(schedule_AddWeeks(sdate, rangeWeeks), '-');
				_rangeEndDate   = schedule_SetDateFormat(schedule_AddWeeks(edate, rangeWeeks), '-');
				$(".title").html(schedule_SetDateFormat(_rangeStartDate,'.')+"~"+schedule_SetDateFormat(_rangeEndDate,'.'));
				$('#inputCalendarcontrols').val(schedule_SetDateFormat(_rangeEndDate,'-'));
			}else{
				_targetDate = _stDate;
			}
		}
	}

	function clearGetAttList(){
		$("#attTable").html("");
		$("#attMonthTblTbody").html("");
		setTempHtml();
	}

	function reLoadList(){
		_page = 1;
		_weeklyTabnum = 0;
		_dailyTabnum = 0;
		clearGetAttList();
	}


	function refreshList(){
		_targetDate = "<%=userNowDate%>";
		reLoadList();
	}


	function setPageType(t){
		_pageType = t;
		setTempHtml();
	}


	function setPage (n) {
		_page = n;
		CFN_SetCookieDay("AttListCnt", $("#PageSize option:selected").val(), 31536000000);
		_pageSize = $("#PageSize").val();
		setTempHtml();
	}

	function atmInfoDisplayer(){
		$(".ATMInfo > P").each(function(){
			var tabid = $(this).data("type").toString();
			if(tabid.indexOf(parseFloat(_pageType))>-1){
				$(this).show();
			}else{
				$(this).hide();
			}
		});
	}

	function setTempHtml(){
		if(_pageType===0){
			if(_page===1){
				$("#attTable").html("");
			}
			$("#WeekTable").show();
			$("#MonthTable").hide();
			$("#WeeklyTable").hide();
			$("#DailyTable").hide();
			$("#monthlyFilter").hide();
			$("#monFilter").hide();
			$("#excelBtn").show();
			$("#excelBtnWeekly").hide();
			atmInfoDisplayer();
			$("#span_incld_weeks").hide();
			$("#div_unitTerm").hide();
			$(".AXPaging_begin").hide();
			$(".AXPaging_end").hide();
		}else if(_pageType===1){
			if(_page===1) {
				$("#attMonthTblTbody").html("");
			}
			$("#WeekTable").hide();
			$("#MonthTable").show();
			$("#WeeklyTable").hide();
			$("#DailyTable").hide();
			$("#monthlyFilter").hide();
			$("#monFilter").hide();
			$("#excelBtn").show();
			$("#excelBtnWeekly").hide();
			atmInfoDisplayer();
			$("#span_incld_weeks").hide();
			$("#div_unitTerm").hide();
			$(".AXPaging_begin").hide();
			$(".AXPaging_end").hide();
		}else if(_pageType===2){
			if(_page==1 && _fistLoad){
				//주간 장표 탭 클릭시 날짜 범위 출력
				weeklyTableDateRangePrint("");
			}
			$("#WeekTable").hide();
			$("#MonthTable").hide();
			$("#WeeklyTable").show();
			$("#monthlyFilter").show();
			$("#monFilter").show();
			$("#excelBtn").hide();
			$("#excelBtnWeekly").show();
			atmInfoDisplayer();
			$("#div_unitTerm").show();
			$("#span_incld_weeks").hide();
			$(".AXPaging_begin").show();
			$(".AXPaging_end").show();
		}else if(_pageType===3){
			$("#WeekTable").hide();
			$("#MonthTable").hide();
			$("#WeeklyTable").hide();
			$("#DailyTable").show();
			$("#monthlyFilter").hide();
			$("#monFilter").hide();
			$("#excelBtn").hide();
			$("#excelBtnWeekly").show();
			atmInfoDisplayer();
			$("#span_incld_weeks").show();
			$("#div_unitTerm").hide();
			$(".AXPaging_begin").hide();
			$(".AXPaging_end").hide();
		}
		getAttList();
	}

	function setWeekHtml(att, monthlyMaxWorkTime){

		//상단 날짜 표시
		$(".title").html(att.dayTitle);
		_fistLoad = true;
		_curStDate = att.sDate;
		_curEdDate = att.eDate;
		_stDate = att.p_sDate;
		_edDate = att.p_eDate;

		var dayList = att.dayList;
		for(var i=0;i<dayList.length;i++){
			var dayObj = dayList[i];
			var dayHtml = "";
			var vDayOfWeek = "";
			var vDayClass = "";
			switch (dayObj.weekd){
				case 0 : dayHtml = dayObj.dDate+_days+"("+_wpMon+")" ; break;
				case 1 : dayHtml = dayObj.dDate+_days+"("+_wpTue+")" ; break;
				case 2 : dayHtml = dayObj.dDate+_days+"("+_wpWed+")" ; break;
				case 3 : dayHtml = dayObj.dDate+_days+"("+_wpThu+")" ; break;
				case 4 : dayHtml = dayObj.dDate+_days+"("+_wpFri+")" ; break;
				case 5 : dayHtml = dayObj.dDate+_days+"("+_wpSat+")" ; $(".dayScope").eq(i).attr("class","dayScope tx_sat"); break;
				case 6 : dayHtml = dayObj.dDate+_days+"("+_wpSun+")" ; $(".dayScope").eq(i).attr("class","dayScope tx_sun"); break;
			}
			$(".dayScope").eq(i).html(dayHtml);
		}

		//<th class="dayScope"><span class="tx_holy">20일 (월)</span></th>

		//$("#attTable").html("");
		var userAtt = att.userAtt;
		for(var i=0;i<userAtt.length;i++){

			var tempTable = $("#attWeekTempTable").clone();
			tempTable = tempTable.removeAttr("style","display:none;");
			tempTable = tempTable.removeAttr("id");
			
			tempTable.find(".weekCheckbox").html('<input type="checkbox" id="attWeekCheck" name="attWeekCheck" value="'+ userAtt[i].userCode +'" />');

			//프로필이미지
			if (userAtt[i].photoPath != ""){
				tempTable.find("div.ATMT_user_img").html('<img src="'+coviCmn.loadImage(userAtt[i].photoPath)+'" onerror="coviCmn.imgError(this, true)" alt=""></div>'); // img").attr("src",userAtt[i].photoPath);
			}
			else{
				tempTable.find("div.ATMT_user_img").html('<p class="bgColor'+Math.floor(i%5+1)+'"><strong>'+userAtt[i].displayName.substring(0,1)+'</strong></p>');
			}
			//사용자명
			var UserNameInfo = userAtt[i].displayName;
			if(userAtt[i].jobPositionName!=null) {
				UserNameInfo += " " + userAtt[i].jobPositionName;
			}
			tempTable.find("p.ATMT_name").html('<div class="btnFlowerName" onclick="coviCtrl.setFlowerName(this)" style="cursor:pointer" data-user-code="'+ userAtt[i].userCode +'" data-user-mail="">'+userAtt[i].displayName+' '+AttendUtils.userRepJobType(userAtt[i])+'</div>');
			//부서
			tempTable.find("p.ATMT_team").html(userAtt[i].deptName);

			var userAttList = userAtt[i].userAttList;
			for(var j=0;j<userAttList.length;j++){
				//var startHtml = "";
				var startHtml = $('<span />', {});
				var endHtml = $('<span />', {});
				var startCss = "";
				var endCss = "";

				/*css 문제로 빈값추가*/
				/* var workHtml = "<p class='td_time_w'>&nbsp;</p>"; */
				/*var workHtml = $('<p />', {
                    class : "td_time_w"
                    ,html : '&nbsp;'
                    //td_time_wbox
                });*/
				var workHtml =  $('<div />', { "class" : "td_time_wbox" });
				var jobHtml = "<p class='td_time_w'>&nbsp;</p>";
				var schNameHtml = "<p class='td_time_w'>&nbsp;</p>";
				var attRealHtml = "<p class='td_time_w'>&nbsp;</p>";
				var monthlyAttAcSumHtml = "<p class='td_time_w'>&nbsp;</p>";

				//정상
				if(userAttList[j].StartSts != null){
					var startChannelIcon = "";
				
					if(userAttList[j].StartChannel != null && userAttList[j].StartChannel != "" && userAttList[j].StartChannel == "W") {
						startChannelIcon = "<span class='attendance_pc'></span>";
					} else if(userAttList[j].StartChannel != null && userAttList[j].StartChannel != "" && userAttList[j].StartChannel == "S") {
						startChannelIcon = "<span class='attendance_secom'></span>";
					}  else if(userAttList[j].StartChannel != null && userAttList[j].StartChannel != "" && userAttList[j].StartChannel == "I") {
						startChannelIcon = "<span class='attendance_caution'></span>";
					}
				
					if(userAttList[j].StartSts=="lbl_n_att_callingTarget"){
						startCss = "Calling";	//소명 css
						startHtml.html(Common.getDic(userAttList[j].StartSts) + startChannelIcon);
					} else {
						if(userAttList[j].v_AttStartTime != null){
							startHtml.addClass("tx_time");
							startHtml.html(userAttList[j].v_AttStartTime + startChannelIcon);
							if(userAttList[j].StartSts=="lbl_att_beingLate") {
								startCss = "BeingLate";
							} else {
								startCss = "Normal";
							}
						}else{
							if(userAttList[j].StartSts=="lbl_n_att_absent"){
								startCss = "Absent";	//결근 css
							}						
							
							startHtml.html(Common.getDic(userAttList[j].StartSts) + startChannelIcon);
						}
					}

					if(userAttList[j].StartChannel != null && userAttList[j].StartChannel == "W") {
						startHtml.attr("title", userAttList[j].StartIpAddr);	
					} else if(userAttList[j].StartChannel != null && userAttList[j].StartChannel == "I") {
						startHtml.attr("title", userAttList[j].Etc);	
					}
				}
				
				if(userAttList[j].EndSts != null){
					var endChannelIcon = "";
					
					if(userAttList[j].EndChannel != null && userAttList[j].EndChannel != "" && userAttList[j].EndChannel == "W") {
						endChannelIcon = "<span class='attendance_pc'></span>";
					} else if(userAttList[j].EndChannel != null && userAttList[j].EndChannel != "" && userAttList[j].EndChannel == "S") {
						endChannelIcon = "<span class='attendance_secom'></span>";
					}  else if(userAttList[j].EndChannel != null && userAttList[j].EndChannel != "" && userAttList[j].EndChannel == "I") {
						endChannelIcon = "<span class='attendance_caution'></span>";
					}		
				
					if(userAttList[j].EndSts=="lbl_n_att_callingTarget"){
						endCss = "Calling";	//소명 css
						endHtml.html(Common.getDic(userAttList[j].EndSts) + endChannelIcon);
					} else {
						if(userAttList[j].v_AttEndTime != null){
							endHtml.addClass("tx_time");
							endHtml.html(userAttList[j].v_AttEndTime + endChannelIcon);
							endCss = "Normal";
							
							if(userAttList[j].EndSts=="lbl_att_leaveErly"){
								endCss = "LeaveErly";
							}else{
								endCss = "Normal";
							}
						}else{
							if(userAttList[j].EndSts=="lbl_n_att_absent"){
								endCss = "Absent";	//결근 css
							}
							
							endHtml.html(Common.getDic(userAttList[j].EndSts) + endChannelIcon);
						}
					}

					if(userAttList[j].EndChannel != null && userAttList[j].EndChannel == "W") {
						endHtml.attr("title", userAttList[j].EndIpAddr);	
					} else if(userAttList[j].EndChannel != null && userAttList[j].EndChannel == "I") {
						endHtml.attr("title", userAttList[j].Etc);	
					}
				}

				//근무상태 ( 외근 등.. )
				if(userAttList[j].jh_JobStsName!=null && userAttList[j].jh_JobStsName != ""){
					//endHtml = "<span class='tx_time'>"+userAttList[j].jobStsStartTime+"</span>";
					if(userAttList[j].v_AttStartTime != null) {
						startCss = "Outside";
					}
					if(userAttList[j].v_AttEndTime != null) {
						endCss = "Outside";
					}

					//상태text
					jobHtml = "<p class='td_time_w' ><a href='#' data-usercode='"+userAtt[i].userCode+"' data-targetdate='"+userAttList[j].dayList+"' onclick='showJobList(this);'>"+userAttList[j].jh_JobStsName+"</a></p>";
				}

				//연장 휴일
				if((userAttList[j].ExtenAc!=null && userAttList[j].ExtenAc!="") ||(userAttList[j].HoliAc!=null && userAttList[j].HoliAc!="")) {
					startCss = "Ex";
					endCss = "Ex";
				}

				//휴무
				if(userAttList[j].WorkSts == "OFF" || userAttList[j].WorkSts == "HOL"){
					if(Number(userAttList[j].HoliCnt)>0){
						//userAttList[j].v_AttStartTime+"<br/>"+userAttList[j].v_AttEndTime
						startHtml.addClass("tx_title");
						startHtml.html("<spring:message code='Cache.lbl_att_holiday_work' />");
						startCss = "Holywork";
						endHtml.removeClass();
						endHtml.html("");
						endCss = "";
					}else {
						startHtml.addClass("tx_title");
						startHtml.attr("title", "<spring:message code='Cache.lbl_att_sch_holiday' />");
						startHtml.html(userAttList[j].WorkSts == "OFF" ? "<spring:message code='Cache.lbl_att_sch_holiday' />" : "<spring:message code='Cache.lbl_Holiday' />");
						startCss = "Holyday";
						endHtml.removeClass();
						endHtml.attr("title", "<spring:message code='Cache.lbl_att_sch_holiday' />");
						endHtml.html("");
						endCss = "";
					}
				}

				//휴가
				if(userAttList[j].VacFlag != null && userAttList[j].VacFlag != ""){
					//연차종류
					if(userAttList[j].VacCnt == 1){
						startHtml.addClass("tx_title");
						startHtml.html(userAttList[j].VacName);
						startCss = "Vacation";
						endHtml.removeClass();
						endHtml.html("");
						endCss = "";
					}else{
						//반차
						var vacAmPmVacDay = userAttList[j].VacAmPmVacDay;
						var arrVacAmPmVacDay = null;
						if(vacAmPmVacDay.indexOf("|")>-1){
							arrVacAmPmVacDay = vacAmPmVacDay.split('|');
						}
						if(userAttList[j].VacOffFlag.indexOf("AM")>-1 && Number(arrVacAmPmVacDay[0])>=0.5){
							startHtml.addClass("tx_title");
							startHtml.html(AttendUtils.vacNameConvertor(userAttList[j].VacOffFlag,userAttList[j].VacName,'AM',0));
							if(userAttList[j].StartSts=="lbl_att_beingLate") {
								startCss = "BeingLate";
							}else if(userAttList[j].StartSts=="lbl_n_att_callingTarget") {
								startCss = "Calling";
							}else if(userAttList[j].StartSts=="lbl_n_att_absent"){
								startCss = "Absent";	//결근 css
							}else{
								startCss = "Half Vacation";
							}
						}
						if(userAttList[j].VacOffFlag.indexOf("PM")>-1 && Number(arrVacAmPmVacDay[1])>=0.5){
							endHtml.addClass("tx_title");
							if(userAttList[j].VacOffFlag.indexOf("AM")>-1){
								endHtml.html(AttendUtils.vacNameConvertor(userAttList[j].VacOffFlag,userAttList[j].VacName,'PM',0));
							}else{
								endHtml.html(userAttList[j].VacName);
							}
							if(userAttList[j].EndSts==="lbl_att_leaveErly") {
								endCss = "LeaveErly";
							}else if(userAttList[j].EndSts==="lbl_n_att_callingTarget") {
								endCss = "Calling";
							}else{
								endCss = "Half Vacation";
							}
						}
					}
				}

				/*출퇴근 좌표*/
				if(userAttList[j].StartPointX!=null && userAttList[j].StartPointX!='' && userAttList[j].StartPointY!=null && userAttList[j].StartPointY!='') {
					var startPoi = $('<button />', {
						class			: "btn_gps_chk"
						,"data-point-x" : userAttList[j].StartPointX
						,"data-point-y" : userAttList[j].StartPointY
						,"data-addr" : userAttList[j].StartAddr
					});
					startHtml.append(startPoi);
				}
				
				if(userAttList[j].EndPointX!=null && userAttList[j].EndPointX!='' && userAttList[j].EndPointY!=null && userAttList[j].EndPointY!='') {
					var endPoi = $('<button />', {
						class			: "btn_gps_chk"
						,"data-point-x" : userAttList[j].EndPointX
						,"data-point-y" : userAttList[j].EndPointY
						,"data-addr" : userAttList[j].EndAddr
					});
					endHtml.append(endPoi);
				}

				var workArry = new Array();
				//정상근무시간
				if(userAttList[j].AttRealTime != null && userAttList[j].AttRealTime != "" ){
					var workval = {
						name : "<spring:message code='Cache.lbl_attendance_normal' />"
						,time : AttendUtils.convertSecToStr(userAttList[j].AttRealTime,"H")
					}
					workArry.push(workval);
				}
				//연장근무시간
				if(userAttList[j].ExtenAc != null && userAttList[j].ExtenAc != "" ){

					var workval = {
						name : "<spring:message code='Cache.lbl_att_overtime' />"
						,time : AttendUtils.convertSecToStr(userAttList[j].ExtenAc,"H")
						,type : "Ex"
					}
					workArry.push(workval);
				}
				//휴일근무시간
				if(userAttList[j].HoliAc != null && userAttList[j].HoliAc != "" && Number(userAttList[j].HoliAc)>0){
					var workval = {
						name : "<spring:message code='Cache.lbl_Holiday' />"
						,time : AttendUtils.convertSecToStr(userAttList[j].HoliAc,"H")
						,type : "Ho"
					}
					workArry.push(workval);
				}

				for(var w=0;w<workArry.length;w++){
					var workHtmlTmep = $('<p />', {
						class : "td_time_w"
						,html : '&nbsp;'
					});

					if(w==0){
//					workHtml.html(workHtmlTmep);	//css꺠짐으로 인한 공백 제거
					}

					if(workArry[w].type=='Ex'){
						var exHtml;
						if(userAttList[j].ExtenCnt > 1){
							exHtml = $('<a />', {
								html : workArry[w].name+" : "+workArry[w].time+ (userAttList[j].ExtenNotEnough == 'N'?" (<a class='exHoSts'><spring:message code='Cache.lbl_NotRun'/></a>)":"")
								,onclick : "showExhoList(this,'O')"
								,"data-usercode" : userAtt[i].userCode
								,"data-targetdate" : userAttList[j].dayList
							});
						}else{
							exHtml = $('<a />', {
								html : workArry[w].name+" : "+workArry[w].time+ (userAttList[j].ExtenNotEnough == 'N'?" (<a class='exHoSts'><spring:message code='Cache.lbl_NotRun'/></a>)":"")
								,onclick : "goAttStatusExPopup(\""+userAtt[i].userCode+"\",\""+userAttList[j].dayList+"\",\"O\")"
								,style : "font-size: 13px;color: #555555;"
							});
						}
						workHtmlTmep.html(exHtml);
					}else if(workArry[w].type=='Ho'){
						var hoHtml;
						if(userAttList[j].HoliCnt > 1){
							hoHtml = $('<a />', {
								html : workArry[w].name+" : "+workArry[w].time+ (userAttList[j].HoliNotEnough == 'N'?" (<a class='exHoSts'><spring:message code='Cache.lbl_NotRun'/></a>)":"")
								,onclick : "showExhoList(this,'H')"
								,"data-usercode" : userAtt[i].userCode
								,"data-targetdate" : userAttList[j].dayList
							});
						}else{
							hoHtml = $('<a />', {
								html : workArry[w].name+" : "+workArry[w].time+ (userAttList[j].HoliNotEnough == 'N'?" (<a class='exHoSts'><spring:message code='Cache.lbl_NotRun'/></a>)":"")
								,onclick : "goAttStatusExPopup(\""+userAtt[i].userCode+"\",\""+userAttList[j].dayList+"\",\"H\")"
							});
						}
						workHtmlTmep.html(hoHtml);
					}else{
						workHtmlTmep.html($('<p />', {
							html : workArry[w].name+" : "+workArry[w].time
							,class:"td_time_w"
						}));
					}
					
					workHtml.append(workHtmlTmep);
				}

				//if(userAttList[j].SchName != null && userAttList[j].SchName != ''){ //직접 입력은 SchName이 없으므로 AttDayStartTime로 Job 체크
				if(userAttList[j].AttDayStartTime != null && userAttList[j].AttDayStartTime != ''){
					//근무제 일정 명 길이 제한
					var spNum = 13;
					var schName = userAttList[j].SchName;

					if(schName == null)
						schName = "";
					else
						schName = userAttList[j].SchName.length > spNum ? userAttList[j].SchName.substring(0,spNum)+".." : userAttList[j].SchName;

					schNameHtml = "<p class='td_time_w ATMT_type' title='"+schName+"'>"+schName+(userAttList[j].AssYn=="Y"?"(간)":"")+"</p>";
				}

				if(userAttList[j].v_startToEndSec != null  && userAttList[j].v_startToEndSec != ''){
					attRealHtml = "<p class='td_time_w'>"+AttendUtils.convertSecToStr(userAttList[j].v_startToEndSec,"H")+"</p>";
				}

				if(userAttList[j].MonthlyAttAcSum != null  && userAttList[j].MonthlyAttAcSum != '') {
					monthlyAttAcSumHtml = "<p class='td_time_w'>"+AttendUtils.convertSecToStr(userAttList[j].MonthlyAttAcSum,"H")+"</p>";
				}

				tempTable.find("a.startSts").eq(j).attr("class","WorkBoxW startSts "+startCss);
				tempTable.find("a.endSts").eq(j).attr("class","WorkBoxW endSts "+endCss);
				tempTable.find("a.startSts").eq(j).html(startHtml);
				tempTable.find("a.endSts").eq(j).html(endHtml);

				//근태기록 상세 데이터 추가
				tempTable.find("a.startSts").eq(j).attr("class","WorkBoxW startSts "+startCss);
				tempTable.find("a.endSts").eq(j).attr("class","WorkBoxW endSts "+endCss);
				tempTable.find("a.startSts").eq(j).attr('href',"javascript:goAttStatusSetPopup('"+userAtt[i].userCode+"','"+userAttList[j].dayList+"');");
				tempTable.find("a.endSts").eq(j).attr('href',"javascript:goAttStatusSetPopup('"+userAtt[i].userCode+"','"+userAttList[j].dayList+"');");
				
				if(userAttList[j].AttConfirmYn == "Y" && Common.getBaseConfig("AttConfirmYn") == "Y") {
					tempTable.find("a.startSts").eq(j).closest("td").addClass("half_book");
					tempTable.find("a.endSts").eq(j).closest("td").addClass("half_book");
				}
				
				tempTable.find("td.attReal").eq(j).html(attRealHtml);
				tempTable.find("td.workSts").eq(j).html(workHtml);
				tempTable.find("td.jobSts").eq(j).html(jobHtml);

				tempTable.find("td.schName").eq(j).html(schNameHtml);
				tempTable.find("a.startSts").eq(j).closest("td").addClass("s_active");
				tempTable.find("a.endSts").eq(j).closest("td").addClass("s_active");
				// tempTable.find("td.schName").eq(j).addClass("s_active");

				tempTable.find("td.monthlyAttAcSum").eq(j).html(monthlyAttAcSumHtml);
				if(userAttList[j].WorkingSystemType == 2) {
					if (userAttList[j].MonthlyAttAcSum >= monthlyMaxWorkTime) {
						tempTable.find("td.monthlyAttAcSum").eq(j).attr("style", "background: lightgray !important;");
					}
				}
			}
			//누적 근무시간
			var userWorkTime = userAtt[i].userAttWorkTime;
			var totWorkTime = userWorkTime.TotWorkTime != ''?userWorkTime.TotWorkTime:"00h";
			var attRealTime = userWorkTime.AttRealTime != ''?userWorkTime.AttRealTime:"0h";
			var extenAc = userWorkTime.ExtenAc != ''?userWorkTime.ExtenAc:"0h";
			var holiAc = userWorkTime.HoliAc != ''?userWorkTime.HoliAc:"0h";
			var totConfWorkTime = userWorkTime.TotConfWorkTime != ''?userWorkTime.TotConfWorkTime:"0h";
			var remainTime = userWorkTime.RemainTime != ''?userWorkTime.RemainTime:"0h";
			var jobStsTime = userWorkTime.JobStsSumTime != ''?userWorkTime.JobStsSumTime:"0h";
			tempTable.find("p.workTime").eq(0).html(AttendUtils.convertSecToStr(totWorkTime,'H'));
			tempTable.find("p.workTime").eq(1).html("<spring:message code='Cache.lbl_n_att_acknowledgedWork'/> "+AttendUtils.convertSecToStr(attRealTime,'H'));
			tempTable.find("p.workTime").eq(2).html("<spring:message code='Cache.lbl_att_overtime'/> "+AttendUtils.convertSecToStr(extenAc,'H'));
			tempTable.find("p.workTime").eq(3).html("<spring:message code='Cache.lbl_Holiday'/> "+AttendUtils.convertSecToStr(holiAc,'H'));
			tempTable.find("p.workTime").eq(4).html("<spring:message code='Cache.lbl_n_att_AttRealTime'/> "+AttendUtils.convertSecToStr(totConfWorkTime,'H'));
			tempTable.find("p.workTime").eq(5).html("<spring:message code='Cache.lbl_n_att_remain'/> "+AttendUtils.convertSecToStr(remainTime,'H'));
			//tempTable.find("p.workTime").eq(5).html("<spring:message code='Cache.lbl_n_att_otherjob_sts'/> "+jobStsTime);

			/*실근무 시간 표기 확인*/
			if(Common.getBaseConfig('RealTimeYn')!="Y"){
				$("#btnFilter").hide();
//			$("#excelRealBtn").hide();
			}

			AttendUtils.Colspan(tempTable.find("tr").eq(5));

			$("#attTable").append(tempTable);

			$(".btn_gps_chk").on('click',function(){
				var pointx = $(this).data('point-x');
				var pointy = $(this).data('point-y');
				var addr = $(this).data('addr');
				parent.AttendUtils.openMapInfoPopup(pointx,pointy,addr);
				return false;
			});
		}

		autoResize();

	}

	function setMonthHtml(att, monthlyMaxWorkTime){
		//상단 날짜 표시
		$(".title").html(att.dayTitleMonth);
		_fistLoad = true;
		_stDate = att.p_sDate;
		_edDate = att.p_eDate;
		_curStDate = att.sDate;
		_curEdDate = att.eDate;

		var userAtt = att.userAtt;
		//헤더 날일 출력
		var userAttListTemp = userAtt[0].userAttList;
		var cellDayW = ($('.ATMCont').width() - 150 - 130)/userAttListTemp.length;
		var theadHtml = "<tr>";
		var attComfirmYn = Common.getBaseConfig("AttConfirmYn");
		
		if(attComfirmYn == "Y") {
			theadHtml += '<th rowspan="2" style="width: 31px;"><input type="checkbox" id="attMonthCheckAll" name="attMonthCheckAll" /></th>';
		}
		
		theadHtml += '<th rowspan="2" style="min-width: 149px;"><spring:message code='Cache.lbl_name' /></th>';
		theadHtml += '<th rowspan="2" style="min-width: 130px;"><spring:message code='Cache.lbl_att_Cumulative_duty_hours' /></th>';
		theadHtml += '<th colspan="'+userAttListTemp.length+'" style="text-align: center;" class="tx_date_month"></th>';
		theadHtml += '</tr>';
		theadHtml += '<tr>';
		for(var i=0;i<userAttListTemp.length;i++) {
			if(i==0){
				theadHtml += '<th style="width: '+cellDayW+'px;border-left: 1px solid #ebebec;">';
			}else{
				theadHtml += '<th style="width: '+cellDayW+'px;">';
			}
			switch (userAttListTemp[i].weekd){
				case 0 : case 1 : case 2 : case 3 : case 4 :
					theadHtml += userAttListTemp[i].v_day; break;
				case 5 : theadHtml += "<span class='tx_sat'>"+userAttListTemp[i].v_day+"</span>"; break;
				case 6 : theadHtml += "<span class='tx_sun'>"+userAttListTemp[i].v_day+"</span>"; break;
			}
			theadHtml += '</th>';
		}
		theadHtml += "</tr>";
		$("#attMonthTemp thead").html(theadHtml);

		$(".tx_date_month").html(att.dayTitleMonth);
		
		//바디 출력
		var tempTable = "";
		for(var i=0;i<userAtt.length;i++){
			tempTable += "<tr>";
			
			if(attComfirmYn == "Y") {
				tempTable += '<td style="width: 30px;"><input type="checkbox" id="attMonthCheck" name="attMonthCheck" value="'+ userAtt[i].userCode +'" /></td>';
			}
			
			tempTable += "<td style=\"width: 190px;\">";
			tempTable += "<div class=\"ATMT_user_wrap\">";
			
			//프로필이미지
			if (userAtt[i].photoPath != ""){
				tempTable += '<div class=\"ATMT_user_img\"><img src="'+coviCmn.loadImage(userAtt[i].photoPath)+'" onerror="coviCmn.imgError(this, true)" alt=""/></div>';
			} else {
				tempTable += '<div class=\"ATMT_user_img\"><p class="bgColor'+Math.floor(i%5+1)+'"><strong>'+userAtt[i].displayName.substring(0,1)+'</strong></p></div>';
			}
			
			//사용자명
			var userJobPosition = userAtt[i].jobPositionName==null?'':userAtt[i].jobPositionName;
			tempTable += '<p class="ATMT_name"><div class="btnFlowerName" onclick="coviCtrl.setFlowerName(this)" style="cursor:pointer" data-user-code="'+ userAtt[i].userCode +'" data-user-mail="">'+userAtt[i].displayName+' '+AttendUtils.userRepJobType(userAtt[i])+'</div></p>';
			
			//부서
			var deptName = userAtt[i].deptName==null?'':userAtt[i].deptName;
			tempTable += '<p class="ATMT_team">'+deptName+'</p>';
			tempTable += "</div>";
			tempTable += "</td>";
			
			//누적 근무시간
			tempTable += "<td style=\"width: 130px;\">";
			var userWorkTime = userAtt[i].userAttWorkTime;
			var totWorkTime = userWorkTime.TotWorkTime != ''?userWorkTime.TotWorkTime:"00h";
			var attRealTime = userWorkTime.AttRealTime != ''?userWorkTime.AttRealTime:"0h";
			var extenAc = userWorkTime.ExtenAc != ''?userWorkTime.ExtenAc:"0h";
			var holiAc = userWorkTime.HoliAc != ''?userWorkTime.HoliAc:"0h";
			var totConfWorkTime = userWorkTime.TotConfWorkTime != ''?userWorkTime.TotConfWorkTime:"0h";
			var remainTime = userWorkTime.RemainTime != ''?userWorkTime.RemainTime:"0h";
			//var jobStsTime = userWorkTime.JobStsSumTime != ''?userWorkTime.JobStsSumTime:"0h";
			tempTable += "<table class=\"ATMtimeTable total\" style=\"width: 100%;\">";
			tempTable += "<tbody>";
			tempTable += "<tr><th>"+_lbl_totWork+"</th><td>"+AttendUtils.convertSecToStr(totWorkTime, 'H')+"</td></tr>";
			tempTable += "<tr><th><spring:message code='Cache.lbl_n_att_acknowledgedWork'/></th><td>"+AttendUtils.convertSecToStr(attRealTime, 'H')+"</td></tr>";
			tempTable += "<tr><th><spring:message code='Cache.lbl_att_overtime'/></th><td>"+AttendUtils.convertSecToStr(extenAc, 'H')+"</td></tr>";
			tempTable += "<tr><th><spring:message code='Cache.lbl_Holiday'/></th><td>"+AttendUtils.convertSecToStr(holiAc, 'H')+"</td></tr>";
			tempTable += "<tr><th><spring:message code='Cache.lbl_n_att_AttRealTime'/></th><td>"+AttendUtils.convertSecToStr(totConfWorkTime, 'H')+"</td></tr>";
			tempTable += "<tr><th><spring:message code='Cache.lbl_n_att_remain'/></th><td>"+AttendUtils.convertSecToStr(remainTime, 'H')+"</td></tr>";
			tempTable += "</tbody>";
			tempTable += "</table>";
			tempTable += "</td>";

			var userAttList = userAtt[i].userAttList;
			for(var j=0;j<userAttList.length;j++) {
				if(userAttList[j].AttConfirmYn == "Y" && Common.getBaseConfig("AttConfirmYn") == "Y") {
					tempTable += "<td class='half_book' onclick='goAttStatusSetPopup(\""+userAtt[i].userCode+"\",\""+userAttList[j].dayList+"\");'";	
				} else {
					tempTable += "<td onclick='goAttStatusSetPopup(\""+userAtt[i].userCode+"\",\""+userAttList[j].dayList+"\");'";	
				}

				//선택 근무제 일때 누적근무 시간이 법정근무 시간 보다 크면 배경색에 표시
				if(userAttList[j].WorkingSystemType == 2) {
					if (userAttList[j].MonthlyAttAcSum >= monthlyMaxWorkTime) {
						//alert(userAttList[j].MonthlyAttAcSum);
						tempTable += " style='background:lightgray;'";
					}
				}
				
				tempTable += ">";

				//출퇴근
				var startHtml = "";
				var endHtml = "";

				//근무상태
				//정상
				if(userAttList[j].StartSts!=null){
					if(userAttList[j].StartSts=="lbl_n_att_callingTarget"){
						startHtml = "<a href='#' class='WorkBoxM Calling' style='height: 90px;'></a>";//소명 css
					}
					else{
						if(userAttList[j].v_AttStartTime != null){
							startHtml = "<a href='#' class='WorkBoxM "+(userAttList[j].StartSts=="lbl_att_beingLate"?"BeingLate":"Normal")+"' style='height: 90px;'></a>";
						}else{
							if(userAttList[j].StartSts=="lbl_n_att_absent"){
								startHtml = "<a href='#' class='WorkBoxM Absent' style='height: 90px;'></a>";	//결근 css
							}
						}
					}
				}
				if(userAttList[j].EndSts!=null){
					if(userAttList[j].EndSts=="lbl_n_att_callingTarget"){
						endHtml = "<a href='#' class='WorkBoxM Calling' style='height: 90px;'></a>";//소명 css
					}
					else{
						if(userAttList[j].v_AttEndTime != null){
							endHtml = "<a href='#' class='WorkBoxM "+(userAttList[j].EndSts=="lbl_att_leaveErly"?"LeaveErly":"Normal")+"' style='height: 90px;'></a>";
						}else{
							if(userAttList[j].EndSts=="lbl_n_att_absent"){
								endHtml = "<a href='#' class='WorkBoxM Absent' style='height: 90px;'></a>";	//결근 css
							}
						}
					}
				}

				//근무상태 ( 외근 등.. )
				if(userAttList[j].jh_JobStsName!=null && userAttList[j].jh_JobStsName != ""){
					startHtml = "<a href='#' class='WorkBoxM Outside' style='position: relative;height: 182px;'></a>"
				}

				//연장 휴일
				if(
						(userAttList[j].ExtenAc!=null && userAttList[j].ExtenAc!="")
						||(userAttList[j].HoliAc!=null && userAttList[j].HoliAc!="")
				){
					startHtml = "<a href='#' class='WorkBoxM Ex' style='height: 90px;'></a>";
					endHtml = "<a href='#' class='WorkBoxM Ex' style='height: 90px;'></a>";
				}

				//휴무
				if(userAttList[j].WorkSts == "OFF" || userAttList[j].WorkSts == "HOL"){
					if(Number(userAttList[j].HoliCnt)>0){
						startHtml = "<a href='#' class='WorkBoxM Holywork' style='position: relative;height: 182px;'></a>";
						endHtml = "&nbsp;";
					}else{
						startHtml = "<a href='#' class='WorkBoxM Holyday' style='position: relative;height: 182px;'></a>";
						endHtml = "&nbsp;";
					}
				}

				//휴가
				if(userAttList[j].VacFlag != null && userAttList[j].VacFlag != ""){
					//연차종류
					//반차
					if(userAttList[j].VacOffFlag.indexOf("AM")>-1 || userAttList[j].VacOffFlag.indexOf("PM")>-1){
						if(userAttList[j].VacOffFlag.indexOf("AM")>-1){
							if(userAttList[j].StartSts=="lbl_att_beingLate") {
								startHtml = "<a href='#' class='WorkBoxM Half BeingLate' style='position: relative;height: 90px;'></a>";
							}else if(userAttList[j].StartSts=="lbl_n_att_callingTarget") {
								startHtml = "<a href='#' class='WorkBoxM Half Calling' style='position: relative;height: 90px;'></a>";
							}else if(userAttList[j].StartSts=="lbl_n_att_absent"){
								startHtml = "<a href='#' class='WorkBoxM Half Absent' style='position: relative;height: 90px;'></a>";
							}else{
								startHtml = "<a href='#' class='WorkBoxM Half Vacation' style='position: relative;height: 90px;'></a>";
							}
						}
						if(userAttList[j].VacOffFlag.indexOf("PM")>-1){
							if(userAttList[j].EndSts=="lbl_att_leaveErly") {
								endHtml = "<a href='#' class='WorkBoxM Half LeaveErly' style='position: relative;height: 90px;'></a>";
							}else if(userAttList[j].EndSts=="lbl_n_att_callingTarget") {
								endHtml = "<a href='#' class='WorkBoxM Half Calling' style='position: relative;height: 90px;'></a>";
							}else{
								endHtml = "<a href='#' class='WorkBoxM Half Vacation' style='position: relative;height: 90px;'></a>";
							}
						}
					}else{
						startHtml = "<a href='#' class='WorkBoxM Vacation' style='position: relative;height: 182px;'></a>";
						endHtml = "&nbsp;";
					}
				}
				tempTable += "<p style='height: 90px;'>"+startHtml+"</p>";
				tempTable += "<p style='height: 90px;'>"+endHtml+"</p>";
				//tempTable.find(".ATMTable_month thead tr").append(thHtml);
				///tempTable.find(".ATMTable_month tbody tr").eq(0).append(""+startHtml+"</td>");
				///tempTable.find(".ATMTable_month tbody tr").eq(1).append("<td onclick='goAttStatusSetPopup(\""+userAtt[i].userCode+"\",\""+userAttList[j].dayList+"\");'>"+endHtml+"</td>");
				tempTable += "</td>";

			}//for daily
			tempTable += "</tr>";
		}
		$("#attMonthTblTbody").append(tempTable);
		autoResize();

	}

	function headWeeklyTableDisplay(){
		//header 주차 출력
		$(".weeklyHeaderTd").each(function(){
			var thispagenum = Number($(this).data('pagenum'));
			if(_weeklyTabnum === thispagenum){
				$(this).show();
			}else{
				$(this).hide();
			}
		});
		$(".weeklyHeaderBtnLeft").each(function(){
			var thWeekNum = Number($(this).data('btnweeknum'))+1;
			if(thWeekNum%_weeklyDataPerWeek === 1 && _weeklyTabnum>0){
				$(this).show();
				$(this).off();
				$(this).on('click',function(){
					_weeklyTabnum--;
					headWeeklyTableDisplay();
				});
			}else{
				$(this).hide();
				$(this).off();
			}
		});
		$(".weeklyHeaderBtnRight").each(function(){
			var thWeekNum = Number($(this).data('btnweeknum'))+1;
			if(thWeekNum%_weeklyDataPerWeek === 0 && _weeklyDataTotalPage>(_weeklyTabnum+1)){
				$(this).show();
				$(this).off();
				$(this).on('click',function(){
					_weeklyTabnum++;
					headWeeklyTableDisplay();
				});
			}else{
				$(this).hide();
				$(this).off();
			}
		});

		$(".bodyWeeklyTblTbodyTd").each(function(){
			var thispagenum = Number($(this).data('pagenum'));
			if(_weeklyTabnum === thispagenum){
				$(this).show();
			}else{
				$(this).hide();
			}
		});
	}

	function setMonthlyByWeeklyHtml(att, mode){
		var tdH =  110;
		var weekCnt = att.WeeksNum.length;
		var userAtt = att.userAttStatusInfo;
		_weeklyDataTotalPage = Math.floor(weekCnt/_weeklyDataPerWeek);
		if(weekCnt%_weeklyDataPerWeek>0){
			_weeklyDataTotalPage++;
		}
		_curStDate = att.sDate;
		_curEdDate = att.eDate;
		_stDate = att.p_sDate;
		_edDate = att.p_eDate;
		if(_page == 1){
			_weeklyHeaderCnt = weekCnt;
			//상단 날짜 표시
			$(".title").html(att.dayTitleMonth);
			//상단 주단위 theader html생성
			var theaderHtml  = "<tr>";

			for(var i=0;i<weekCnt;i++){
				var tabNum = Math.floor(i/_weeklyDataPerWeek);
				theaderHtml += "<td class=\"weeklyHeaderTd\" data-pagenum=\""+tabNum+"\">";
				theaderHtml += "<table style=\"width:100%;\">";
				theaderHtml += "<tr>";
				theaderHtml += "<th style=\"width:40px; border: none !important;\">";
				theaderHtml += "<a href=\"#\" class=\"AXPaging_prev weeklyHeaderBtnLeft\" data-btnweeknum=\""+i+"\" data-paging=\"-\" style=\"top: -3px;margin: 5px 3px 0 0 !important;\"></a>";
				theaderHtml += "</th>";
				theaderHtml += "<th style=\"min-width: 100px; border: none !important;\" data-btnweeknum=\""+i+"\">";
				var dateRangeStartDate  = ""+Object.keys(att.listRangeFronToDate[i]);
				var dateRangeStartDateF = dateRangeStartDate.substring(4,6)+"."+dateRangeStartDate.substring(6);
				var dateRangeEndDate    = ""+att.listRangeFronToDate[i][dateRangeStartDate];
				var dateRangeEndDateF   = dateRangeEndDate.substring(4,6)+"."+dateRangeEndDate.substring(6);
				theaderHtml += att.WeeksNum[i]+"주차<br/><p style=\"font-weight: normal;color: #838383;\">"+dateRangeStartDateF+"~"+dateRangeEndDateF+"</p>";
				theaderHtml += "</th>";
				theaderHtml += "<th style=\"width:40px; border: none !important;\">";
				theaderHtml += "<a href=\"#\" class=\"AXPaging_next weeklyHeaderBtnRight\" data-btnweeknum=\""+i+"\" data-paging=\"+\" style=\"top: -3px;margin: 5px 3px 0 0 !important;\"></a>";
				theaderHtml += "</th>";
				theaderHtml += "<tr>";
				theaderHtml += "</table>";
				theaderHtml += "</td>";
			}
			theaderHtml  += "</tr>";
			//$("#headerWeekList").html(theaderHtml);

			//헤더 출력
			$("#headerWeeklyTblTbody").html(theaderHtml);
		}

		//직원별 row boby 생성
		var rowDataIdx = (_page-1)*_pageSize;
		var tempTable = "";
		var dataTable = "";
		for(var i=0;i<userAtt.length;i++) {
			tempTable += '<tr><td style="width: 190px;height: '+tdH+'px;">';
			//프로필이미지
			tempTable += '<div class="ATMT_user_wrap">';
			if (userAtt[i].PhotoPath != "") {
				tempTable += "<div class=\"ATMT_user_img\"><img src=\"" + coviCmn.loadImage(userAtt[i].PhotoPath) + "\" onerror=\"coviCmn.imgError(this, true)\" alt=\"\"/></div>";
			} else {
				tempTable += "<div class=\"ATMT_user_img\"><p class=\"bgColor" + Math.floor(i % 5 + 1) + "\"><strong>" + userAtt[i].UserName.substring(0, 1) + "</strong></p></div>";
			}
			//사용자명
			var userJobPosition = userAtt[i].JobPositionName == null ? '' : userAtt[i].JobPositionName;
			tempTable += "<div class=\"ATMT_team btnFlowerName\" onclick=\"coviCtrl.setFlowerName(this)\" style=\"cursor:pointer\" data-user-code="+userAtt[i].UserCode+" data-user-mail=\"\">"+userAtt[i].UserName+" "+AttendUtils.userRepJobType(userAtt[i])+"</div>";
			//부서
			tempTable += "<div class=\"ATMT_team\">" + userAtt[i].DeptName + "</div";
			tempTable += "</td>";


			//누적 근무시간
			tempTable += "<td style=\"background: #fffdf0;width: 180px;\">";
			tempTable += "<table class=\"ATMtimeTable total\">";
			tempTable += "<tbody>";
			var sumUserWorkInfo = userAtt[i].userWorkInfo_0;
			var workDays = Number(userAtt[i].Sum_WorkDay);
			var totWorkTime = userAtt[i].Sum_TotWorkTime;
			var totWorkTimeD = Number(userAtt[i].Sum_TotWorkTime) - (Number(userAtt[i].Sum_AttAcN)+ Number(userAtt[i].Sum_ExtenAcN) + Number(userAtt[i].Sum_HoliAcN));
			var totWorkTimeN = (Number(userAtt[i].Sum_AttAcN)+ Number(userAtt[i].Sum_ExtenAcN) + Number(userAtt[i].Sum_HoliAcN));
			var attRealTime = userAtt[i].Sum_AttRealTime;
			var attRealTimeD = Number(userAtt[i].Sum_AttRealTime) - (Number(userAtt[i].Sum_AttAcN)+ Number(userAtt[i].Sum_ExtenAcN) + Number(userAtt[i].Sum_HoliAcN));
			var attRealTimeN = (Number(userAtt[i].Sum_AttAcN)+ Number(userAtt[i].Sum_ExtenAcN) + Number(userAtt[i].Sum_HoliAcN));
			var extenAc =  userAtt[i].Sum_ExtenAc;
			var extenAcD =  userAtt[i].Sum_ExtenAcD;
			var extenAcN =  userAtt[i].Sum_ExtenAcN;
			var holiAc = userAtt[i].Sum_HoliAc;
			var holiAcD = userAtt[i].Sum_HoliAcD;
			var holiAcN = userAtt[i].Sum_HoliAcN;
			var totConfWorkTime = userAtt[i].Sum_TotConfWorkTime;
			var totConfWorkDTime = Number(userAtt[i].Sum_TotConfWorkTime) - (Number(userAtt[i].Sum_AttAcN) + Number(userAtt[i].Sum_ExtenAcN) + Number(userAtt[i].Sum_HoliAcN));
			var totConfWorkNTime = Number(userAtt[i].Sum_AttAcN) + Number(userAtt[i].Sum_ExtenAcN) + Number(userAtt[i].Sum_HoliAcN);
			var avgWeeklyWorkTime = Number(totWorkTime)/weekCnt;

			if (_printDN) {
				var vTotWorkTimeD = AttendUtils.convertSecToStr(totWorkTimeD,'H');
				var vTotWorkTimeN = AttendUtils.convertSecToStr(totWorkTimeN,'H');
				var vAttRealTimeD = AttendUtils.convertSecToStr(attRealTimeD,'H');
				var vAttRealTimeN = AttendUtils.convertSecToStr(attRealTimeN,'H');
				var vExtenAcD = AttendUtils.convertSecToStr(extenAcD,'H');
				var vExtenAcN = AttendUtils.convertSecToStr(extenAcN,'H');
				var vHoliAcD = AttendUtils.convertSecToStr(holiAcD,'H');
				var vHoliAcN = AttendUtils.convertSecToStr(holiAcN,'H');
				var vTotConfWorkDTime = AttendUtils.convertSecToStr(totConfWorkDTime,'H');
				var vTotConfWorkNTime = AttendUtils.convertSecToStr(totConfWorkNTime,'H');
				tempTable += "<tr data-attno=\""+rowDataIdx+"\" class=\"row_tot_TotWorkTime\"><th>"+_lbl_totWork+"</th><td style=\"cursor:pointer;color: "+AttendUtils.userWorkTimeOverColorM(sumUserWorkInfo, totWorkTime, "M", "#4ABDE2", workDays)+";font-size: 14px;\" title=\"<spring:message code='Cache.lbl_Weekly'/>:"+vTotWorkTimeD+" /<spring:message code='Cache.lbl_night'/>:"+vTotWorkTimeN+"\">"+vTotWorkTimeD +" /"+vTotWorkTimeN+"</td></tr>";
				tempTable += "<tr data-attno=\""+rowDataIdx+"\" class=\"row_tot_AttRealTime\"><th><spring:message code='Cache.lbl_n_att_acknowledgedWork'/></th><td style=\"cursor:pointer;\" title=\"<spring:message code='Cache.lbl_Weekly'/>:"+vAttRealTimeD+" /<spring:message code='Cache.lbl_night'/>:"+vAttRealTimeN+"\">"+vAttRealTimeD+" /"+vAttRealTimeN+"</td></tr>";
				tempTable += "<tr data-attno=\""+rowDataIdx+"\" class=\"row_tot_ExtenAc\"><th><spring:message code='Cache.lbl_att_overtime'/></th><td style=\"cursor:pointer;\" title=\"<spring:message code='Cache.lbl_Weekly'/>:"+vExtenAcD+" /<spring:message code='Cache.lbl_night'/>:"+vExtenAcN+"\">"+vExtenAcD+" /"+vExtenAcN+"</td></tr>";
				tempTable += "<tr data-attno=\""+rowDataIdx+"\" class=\"row_tot_HoliAc\"><th><spring:message code='Cache.lbl_Holiday'/></th><td style=\"cursor:pointer;\" title=\"<spring:message code='Cache.lbl_Weekly'/>:"+vHoliAcD+" /<spring:message code='Cache.lbl_night'/>:"+vHoliAcN+"\">"+vHoliAcD+" /"+vHoliAcN+"</td></tr>";
				tempTable += "<tr data-attno=\""+rowDataIdx+"\" class=\"row_tot_TotConfWorkTime\"><th><spring:message code='Cache.lbl_n_att_AttRealTime'/></th><td style=\"cursor:pointer;\" title=\"<spring:message code='Cache.lbl_Weekly'/>:"+vTotConfWorkDTime+" /<spring:message code='Cache.lbl_night'/>:"+vTotConfWorkNTime+"\">"+vTotConfWorkDTime+" /"+vTotConfWorkNTime+"</td></tr>";
				tempTable += "<tr data-attno=\""+rowDataIdx+"\"><th><spring:message code='Cache.lbl_Week'/> <spring:message code='Cache.lbl_Average'/></th><td style=\"cursor:pointer;\">"+AttendUtils.convertSecToStr(avgWeeklyWorkTime,'H')+"</td></tr>";		//평균
			} else {
				tempTable += "<tr data-attno=\""+rowDataIdx+"\" class=\"row_tot_TotWorkTime\"><th>"+_lbl_totWork+"</th><td style=\"color: "+AttendUtils.userWorkTimeOverColorM(sumUserWorkInfo, totWorkTime, "M", "#4ABDE2", workDays)+";font-size: 14px;\">"+AttendUtils.convertSecToStr(totWorkTime, 'H')+"</td></tr>";
				tempTable += "<tr data-attno=\""+rowDataIdx+"\" class=\"row_tot_AttRealTime\"><th><spring:message code='Cache.lbl_n_att_acknowledgedWork'/></th><td>"+AttendUtils.convertSecToStr(attRealTime,'H')+"</td></tr>";
				tempTable += "<tr data-attno=\""+rowDataIdx+"\" class=\"row_tot_ExtenAc\"><th><spring:message code='Cache.lbl_att_overtime'/></th><td>"+AttendUtils.convertSecToStr(extenAc,'H')+"</td></tr>";
				tempTable += "<tr data-attno=\""+rowDataIdx+"\" class=\"row_tot_HoliAc\"><th><spring:message code='Cache.lbl_Holiday'/></th><td>"+AttendUtils.convertSecToStr(holiAc,'H')+"</td></tr>";
				tempTable += "<tr data-attno=\""+rowDataIdx+"\" class=\"row_tot_TotConfWorkTime\"><th><spring:message code='Cache.lbl_n_att_AttRealTime'/></th><td>"+AttendUtils.convertSecToStr(totConfWorkTime,'H')+"</td></tr>";
				tempTable += "<tr data-attno=\""+rowDataIdx+"\"><th><spring:message code='Cache.lbl_Week'/> <spring:message code='Cache.lbl_Average'/></th><td>"+AttendUtils.convertSecToStr(avgWeeklyWorkTime,'H')+"</td></tr>";	//평균
			}
			tempTable += "</tbody>";
			tempTable += "</table>";
			tempTable +="</td>";
			//tempTable += "</tr>";

			for(var j=0;j<weekCnt;j++){
				var tabNum = Math.floor(j/_weeklyDataPerWeek);
				var userWorkInfo = userAtt[i]['userWorkInfo_' + j];
				var totWorkTime = userAtt[i]['TotWorkTime_'+j];
				var attAcN = Number(userAtt[i]['AttAcN_'+j]);
				
				var extenAc = Number(userAtt[i]['ExtenAc_'+j]);
				var extenAcD = Number(userAtt[i]['ExtenAcD_'+j]);
				var extenAcN = Number(userAtt[i]['ExtenAcN_'+j]);
				var holiAc = Number(userAtt[i]['HoliAc_'+j]);
				var holiAcD = Number(userAtt[i]['HoliAcD_'+j]);
				var holiAcN = Number(userAtt[i]['HoliAcN_'+j]);
				var totWorkTimeD = Number(userAtt[i]['TotWorkTime_'+j]) - (attAcN+extenAcN+holiAcN);

				var attReal = Number(userAtt[i]['AttReal_'+j]);
				var attRealD = Number(userAtt[i]['AttReal_'+j]) - (attAcN+extenAcN+holiAcN);
				var totConfWorkTime = Number(userAtt[i]['AttRealConfTime_'+j]);
				var totConfWorkDTime = Number(userAtt[i]['AttRealConfTime_'+j]) - (attAcN+extenAcN+holiAcN);
				var monthlyAttAcSum = Number(userAtt[i]['MonthlyAttAcSum_'+j]);
				var workingSystemType = Number(userAtt[i]['WorkingSystemType_'+j]);
				var tdHtml = "<td class=\"bodyWeeklyTblTbodyTd\" data-pagenum=\""+tabNum+"\"";
				var styleTemp = "";
				if(workingSystemType == 2) {
					if(monthlyAttAcSum >= att.monthlyMaxWorkTime) {
						styleTemp += "background: lightgray;";
					}
				}
				tdHtml += " style=\"height: "+tdH+"px;"+styleTemp+"\">";
				var monthlyWorkTimeHtml = "";
				if(workingSystemType == 2) { //선택 근무제 일때
					monthlyWorkTimeHtml += "<tr><td><spring:message code='Cache.lbl_MonthCumulativeWork'/></td><td>" + AttendUtils.convertSecToStr(monthlyAttAcSum, 'h') + "</td></tr>";	//월 누적 근무
				}
				tdHtml += "<table class=\"ATMtimeTable\" style=\"width: 100%;\">";
				tdHtml += "<tbody>";
				if (_printDN) {
					var vTotWorkTimeD = AttendUtils.convertSecToStr(totWorkTimeD,'h');
					var vTotWorkTimeN = AttendUtils.convertSecToStr((attAcN+extenAcN+holiAcN),'h');
					var vAttRealTimeD = AttendUtils.convertSecToStr(attRealD, 'h');
					var vAttRealTimeN = AttendUtils.convertSecToStr((attAcN+extenAcN+holiAcN), 'h');
					var vExtenAcD = AttendUtils.convertSecToStr(extenAcD, 'h');
					var vExtenAcN = AttendUtils.convertSecToStr(extenAcN, 'h');
					var vHoliAcD = AttendUtils.convertSecToStr(holiAcD, 'h');
					var vHoliAcN = AttendUtils.convertSecToStr(holiAcN, 'h');
					var vTotConfWorkDTime = AttendUtils.convertSecToStr(totConfWorkDTime, 'h');
					var vTotConfWorkNTime = AttendUtils.convertSecToStr((attAcN+extenAcN+holiAcN), 'h');
					tdHtml += "<tr data-attno=\""+rowDataIdx+"\" class=\"row_data_TotWorkTime\"><th>"+_lbl_totWork+"</th><td style=\"cursor:pointer;\" style=\"color: "+AttendUtils.userWorkTimeOverColorV2(userWorkInfo, totWorkTime, "W", "#4ABDE2")+";font-size: 14px;\" title=\"<spring:message code='Cache.lbl_Weekly'/>:"+vTotWorkTimeD+" /<spring:message code='Cache.lbl_night'/>:"+vTotWorkTimeN+"\">"+vTotWorkTimeD+" /"+vTotWorkTimeN+"</td></tr>";
					tdHtml += "<tr data-attno=\""+rowDataIdx+"\" class=\"row_data_AttRealTime\"><th><spring:message code='Cache.lbl_n_att_acknowledgedWork'/></th><td style=\"cursor:pointer;\" title=\"<spring:message code='Cache.lbl_Weekly'/>:"+vAttRealTimeD+" /<spring:message code='Cache.lbl_night'/>:"+vAttRealTimeN+"\">"+vAttRealTimeD+" /"+vAttRealTimeN+"</td></tr>";
					tdHtml += "<tr data-attno=\""+rowDataIdx+"\" class=\"row_data_ExtenAc\"><th><spring:message code='Cache.lbl_att_overtime'/></th><td style=\"cursor:pointer;\" title=\"<spring:message code='Cache.lbl_Weekly'/>:"+vExtenAcD+" /<spring:message code='Cache.lbl_night'/>:"+vExtenAcN+"\">"+vExtenAcD+" /"+vExtenAcN+"</td></tr>";
					tdHtml += "<tr data-attno=\""+rowDataIdx+"\" class=\"row_data_HoliAc\"><th><spring:message code='Cache.lbl_Holiday'/></th><td style=\"cursor:pointer;\" title=\"<spring:message code='Cache.lbl_Weekly'/>:"+vHoliAcD+" /<spring:message code='Cache.lbl_night'/>:"+vHoliAcN+"\">"+vHoliAcD+" /"+vHoliAcN+"</td></tr>";
					tdHtml += "<tr data-attno=\""+rowDataIdx+"\" class=\"row_data_TotConfWorkTime\"><th><spring:message code='Cache.lbl_n_att_AttRealTime'/></th><td style=\"cursor:pointer;\" title=\"<spring:message code='Cache.lbl_Weekly'/>:"+vTotConfWorkDTime+" /<spring:message code='Cache.lbl_night'/>:"+vTotConfWorkNTime+"\">"+vTotConfWorkDTime+" /"+vTotConfWorkNTime+"</td></tr>";

					if(monthlyWorkTimeHtml==""){
						tdHtml += "<tr><td colspan=\"2\">&nbsp;</td></tr>";
					}else{
						tdHtml += monthlyWorkTimeHtml;
					}
				}else{
					tdHtml += "<tr data-attno=\""+rowDataIdx+"\" class=\"row_data_TotWorkTime\"><th>"+_lbl_totWork+"</th><td style=\"color: "+AttendUtils.userWorkTimeOverColorV2(userWorkInfo, totWorkTime, "W", "#4ABDE2")+";font-size: 14px;\">"+AttendUtils.convertSecToStr(totWorkTime, 'h')+"</td></tr>";
					tdHtml += "<tr data-attno=\""+rowDataIdx+"\" class=\"row_data_AttRealTime\"><th><spring:message code='Cache.lbl_n_att_acknowledgedWork'/></th><td>"+AttendUtils.convertSecToStr(attReal, 'h') +"</td></tr>";
					tdHtml += "<tr data-attno=\""+rowDataIdx+"\" class=\"row_data_ExtenAc\"><th><spring:message code='Cache.lbl_att_overtime'/></th><td>"+AttendUtils.convertSecToStr(extenAc, 'h') +"</td></tr>";
					tdHtml += "<tr data-attno=\""+rowDataIdx+"\" class=\"row_data_HoliAc\"><th><spring:message code='Cache.lbl_Holiday'/></th><td>"+AttendUtils.convertSecToStr(holiAc, 'h') +"</td></tr>";
					tdHtml += "<tr data-attno=\""+rowDataIdx+"\" class=\"row_data_TotConfWorkTime\"><th><spring:message code='Cache.lbl_n_att_AttRealTime'/></th><td>"+AttendUtils.convertSecToStr(totConfWorkTime, 'h') +"</td></tr>";

					if(monthlyWorkTimeHtml==""){
						tdHtml += "<tr><td colspan=\"2\">&nbsp;</td></tr>";
					}else{
						tdHtml += monthlyWorkTimeHtml;
					}
				}

				tdHtml += "</tbody>";
				tdHtml += "</table>";
				tdHtml += "</td>";
				tempTable += tdHtml;
			}
			tempTable += "</tr>";

			rowDataIdx++;
		}
		if (_page==1 || mode=="reload")	{
			$("#bodyWeeklyTblTbody").html("");
			//$("#bodyWeeklyDataTblTbody").html("");
		}
		$("#bodyWeeklyTblTbody").append(tempTable);
		//$("#bodyWeeklyDataTblTbody").append(dataTable);
		headWeeklyTableDisplay();

		mouseRowOverOutEventWeekly("tr.row_tot_TotWorkTime", "tr.row_data_TotWorkTime");
		mouseRowOverOutEventWeekly("tr.row_tot_AttRealTime", "tr.row_data_AttRealTime");
		mouseRowOverOutEventWeekly("tr.row_tot_ExtenAc", "tr.row_data_ExtenAc");
		mouseRowOverOutEventWeekly("tr.row_tot_HoliAc", "tr.row_data_HoliAc");
		mouseRowOverOutEventWeekly("tr.row_tot_TotConfWorkTime", "tr.row_data_TotConfWorkTime");

		autoResize();
	}


	function headDailyTableDisplay(){
		//header 주차 출력
		$(".dailyHeaderTh").each(function(){
			var thispagenum = Number($(this).data('pagenum'));
			if(_dailyTabnum === thispagenum){
				$(this).show();
			}else{
				$(this).hide();
			}
		});
		$(".dailyHeaderBtnLeft").each(function(){
			var thWeekNum = Number($(this).data('btnweeknum'))+1;
			if(_dailyTabnum>0){
				$(this).show();
				$(this).off();
				$(this).on('click',function(){
					_dailyTabnum--;
					headDailyTableDisplay();
				});
			}else{
				$(this).hide();
				$(this).off();
			}
		});
		$(".dailyHeaderBtnRight").each(function(){
			var thWeekNum = Number($(this).data('btnweeknum'))+1;
			if(_dailyDataTotalPage>(_dailyTabnum+1)){
				$(this).show();
				$(this).off();
				$(this).on('click',function(){
					_dailyTabnum++;
					headDailyTableDisplay();
				});
			}else{
				$(this).hide();
				$(this).off();
			}
		});

		$(".dailyBodyTd").each(function(){
			var thispagenum = Number($(this).data('pagenum'));
			if(_dailyTabnum === thispagenum){
				$(this).show();
			}else{
				$(this).hide();
			}
		});
	}

	function setMonthlyByDailyHtml(att, mode){
		var weekCnt = att.WeeksNum.length;
		var dailyCnt = 0;
		if(att.userAtt.length>0){
			dailyCnt = att.userAtt[0].userAttDaily.length;
		}
		var userAtt = att.userAtt;

		_curStDate = att.sDate;
		_curEdDate = att.eDate;
		_stDate = att.p_sDate;
		_edDate = att.p_eDate;
		if(_page == 1){
			_FreePartAttCnt = 0;
			_dailyDataTotalPage = weekCnt;
			//상단 날짜 표시
			$(".title").html(att.dayTitleMonth);
			_fistLoad = true;
			//상단 주단위 theader html생성

			var theaderHtml  = "<tr>";
			for(var i=0;i<weekCnt;i++){
				var dateRangeStartDate  = ""+Object.keys(att.listRangeFronToDate[i]);
				var dateRangeStartDateF = dateRangeStartDate.substring(4,6)+"."+dateRangeStartDate.substring(6);
				var dateRangeEndDate    = ""+att.listRangeFronToDate[i][dateRangeStartDate];
				var dateRangeEndDateF   = dateRangeEndDate.substring(4,6)+"."+dateRangeEndDate.substring(6);
				var sdate = new Date(replaceDate(dateRangeStartDate));
				var edate = new Date(replaceDate(dateRangeEndDate));
				var Difference_In_Time = edate.getTime() - sdate.getTime();
				var Difference_In_Days = (Difference_In_Time / (1000 * 3600 * 24))+1+1;


				theaderHtml += "<th class=\"dailyHeaderTh\" colspan=\""+Difference_In_Days+"\" data-pagenum=\""+i+"\" style=\"\">";
				theaderHtml += "<table style=\"width:100%;\">";
				theaderHtml += "<tr>";
				theaderHtml += "<th style=\"width:40px; border: none !important; text-align: left;\">";
				theaderHtml += "<a href=\"#\" class=\"AXPaging_prev dailyHeaderBtnLeft\" data-btnweeknum=\""+i+"\" data-paging=\"-\" style=\"top: -1px;margin: 5px 3px 0 2px !important;\"></a>";
				theaderHtml += "</th>";
				theaderHtml += "<th style=\"border: none !important;\">"+att.WeeksNum[i]+"<spring:message code='Cache.lbl_TheWeek' /> ("+dateRangeStartDateF+"~"+dateRangeEndDateF+")</th>";	//주차
				theaderHtml += "<th style=\"width:40px; border: none !important; text-align: right;\">";
				theaderHtml += "<a href=\"#\" class=\"AXPaging_next dailyHeaderBtnRight\" data-btnweeknum=\""+i+"\" data-paging=\"-\" style=\"top: -1px;margin: 5px 3px 0 0 !important;\"></a>";
				theaderHtml += "</th>";
				theaderHtml += "</tr></table></th>";
			}
			theaderHtml  += "</tr>";

			var daysHtml = "<tr>";
			var weeklyNum = 0;
			for(var j=0;j<dailyCnt;j++) {

				//일단위 데이터 출력
				var DailyData = userAtt[0]['userAttDaily'][j];
				//주단위 합계 출력
				var sumPrintFlag = false;
				if(j>0 && _strtWeek===Number(DailyData.DayOfWeek)){
					sumPrintFlag = true;
				}
				if(sumPrintFlag){
					daysHtml  += "<th class=\"dailyHeaderTh\" data-pagenum=\""+weeklyNum+"\" style=\"background: #f5f5f5;\"><spring:message code='Cache.lbl_sum' /></th>";	//합계
					weeklyNum++;
				}

				var dayList = "" + DailyData.dayList;
				var v_day = Number(dayList.substring(8));
				daysHtml += "<th class=\"dailyHeaderTh\" data-pagenum=\""+weeklyNum+"\" style=\"\">";
				switch (DailyData.DayOfWeek) {
					case 2 :
					case 3 :
					case 4 :
					case 5 :
					case 6 :
						daysHtml += v_day;
						break;
					case 7 :
						daysHtml += "<span class='tx_sat'>" + v_day + "</span>";
						break;
					case 1 :
						daysHtml += "<span class='tx_sun'>" + v_day + "</span>";
						break;
				}
				daysHtml += "</th>";
			}
			daysHtml += "<th class=\"dailyHeaderTh\" data-pagenum=\""+weeklyNum+"\" style=\"background: #f5f5f5;\">합계</th>";
			daysHtml += "</tr>";
			//헤더 출력
			$("#headerDailyTblTbody").html(theaderHtml+daysHtml);
		}

		//직원별 row boby 생성
		var rowDataIdx = (_page-1)*_pageSize;
		var tempTable = "";
		for(var i=0;i<userAtt.length;i++){
			var dataHtml = "";
			tempTable+="<tr style='height: 91px;'>";
			tempTable+="<td style=\"width: 190px;\" class=\"td_user_name\">";
			//프로필이미지
			tempTable+='<div class="ATMT_user_wrap type">';
			if (userAtt[i].PhotoPath != ""){
				tempTable+='<div class="ATMT_user_img"><img src="'+coviCmn.loadImage(userAtt[i].PhotoPath)+'" onerror="coviCmn.imgError(this, true)" alt=""></div>';
			}
			else{
				tempTable+='<div class="ATMT_user_img"><p class="bgColor'+Math.floor(i%5+1)+'"><strong>'+userAtt[i].UserName.substring(0,1)+'</strong></p></div>';
			}
			//사용자명
			var userJobPosition = userAtt[i].JobPositionName==null?'':userAtt[i].JobPositionName;
			tempTable+="<p class=\"ATMT_name\"><div <div class=\"btnFlowerName\" onclick=\"coviCtrl.setFlowerName(this)\" style=\"cursor:pointer\" data-user-code="+userAtt[i].UserCode+" data-user-mail=\"\">"+userAtt[i].UserName+" "+AttendUtils.userRepJobType(userAtt[i])+"</div></p>";
			//부서
			if(userAtt[i].JobTitleName === null || userAtt[i].JobTitleName===""){
				tempTable += "<p class=\"ATMT_team\">" + userAtt[i].DeptName + "</p>";
			}else {
				tempTable += "<p class=\"ATMT_team\">" + userAtt[i].DeptName + "(" + userAtt[i].JobTitleName + ")</p>";
			}
			tempTable+="</div></td>";

			///////////////////////////////////////////

			//누적 근무시간
			var userWorkTime = userAtt[i].userAttWorkTotalTime;
			var attAcN = Number(userWorkTime.AttAcN)+Number(userWorkTime.ExtenAcN)+Number(userWorkTime.HoliAcN);
			var totWorkTime = Number(userWorkTime.TotWorkTime);
			var avgWorkTime = totWorkTime/weekCnt;
			var attRealTime = Number(userWorkTime.AttRealTime);
			var extenAc = userWorkTime.ExtenAc;
			var extenAcD = userWorkTime.ExtenAcD;
			var extenAcN = userWorkTime.ExtenAcN;
			var holiAc = userWorkTime.HoliAc;
			var holiAcD = userWorkTime.HoliAcD;
			var holiAcN = userWorkTime.HoliAcN;
			var totConfWorkTime = Number(userWorkTime.TotConfWorkTime);
			var totWorkTimeHtml = "";
			var attRealTimeHtml = "";
			var extenHtml = "";
			var holiHtml = "";
			var totConfWorkTimeHtml = "";
			var tTotWorkTime = "";
			var tAttRealTime = "";
			var tExten = "";
			var tHoli = "";
			var tTotConfWork = "";
			var totWorkTimeD = totWorkTime - attAcN;
			var attRealTimeD = attRealTime - attAcN;
			var totConfWorkDTime = totConfWorkTime - attAcN;
			if(_printDN){
				totWorkTimeHtml = AttendUtils.attTimeHtml(AttendUtils.convertSecToStr(totWorkTimeD,'H'), AttendUtils.convertSecToStr(attAcN,'H'));
				attRealTimeHtml = AttendUtils.attTimeHtml(AttendUtils.convertSecToStr(attRealTimeD,'H'), AttendUtils.convertSecToStr(attAcN,'H'));
				extenHtml = AttendUtils.attTimeHtml(AttendUtils.convertSecToStr(extenAcD,'H'), AttendUtils.convertSecToStr(extenAcN,'H'));
				holiHtml = AttendUtils.attTimeHtml(AttendUtils.convertSecToStr(holiAcD,'H'), AttendUtils.convertSecToStr(holiAcN,'H'));
				totConfWorkTimeHtml = AttendUtils.attTimeHtml(AttendUtils.convertSecToStr(totConfWorkDTime,'H'), AttendUtils.convertSecToStr(attAcN,'H'));
			}else{
				totWorkTimeHtml = AttendUtils.convertSecToStr(totWorkTime,'H');
				attRealTimeHtml = AttendUtils.convertSecToStr(attRealTime,'H');
				extenHtml = AttendUtils.convertSecToStr(extenAc,'H');
				holiHtml = AttendUtils.convertSecToStr(holiAc,'H');
				totConfWorkTimeHtml = AttendUtils.convertSecToStr(totConfWorkTime,'H');
			}
			tTotWorkTime = "<spring:message code='Cache.lbl_Weekly'/>:"+AttendUtils.convertSecToStr(totWorkTimeD,'H')+" /<spring:message code='Cache.lbl_night'/>:"+AttendUtils.convertSecToStr(attAcN,'H');
			tAttRealTime = "<spring:message code='Cache.lbl_Weekly'/>:"+AttendUtils.convertSecToStr(attRealTimeD,'H')+" /<spring:message code='Cache.lbl_night'/>:"+AttendUtils.convertSecToStr(attAcN,'H');
			tExten = "<spring:message code='Cache.lbl_Weekly'/>:"+AttendUtils.convertSecToStr(extenAcD,'H')+" /<spring:message code='Cache.lbl_night'/>:"+AttendUtils.convertSecToStr(extenAcN,'H');
			tHoli = "<spring:message code='Cache.lbl_Weekly'/>:"+AttendUtils.convertSecToStr(holiAcD,'H')+" /<spring:message code='Cache.lbl_night'/>:"+AttendUtils.convertSecToStr(holiAcN,'H');
			tTotConfWork = "<spring:message code='Cache.lbl_Weekly'/>:"+AttendUtils.convertSecToStr(totWorkTimeD,'H')+" /<spring:message code='Cache.lbl_night'/>:"+AttendUtils.convertSecToStr(attAcN,'H');


			tempTable+="<td style=\"background-color: #FFFDF0;width: 200px;\">";
			tempTable+="<table class=\"ATMDailytimeTable total\" style=\"width: 100%;\">";
			tempTable+="<tbody>";
			tempTable+="<tr data-attno=\""+rowDataIdx+"\" class=\"workTime tx_etc row_tot_TotWorkTime\" style=\"cursor: pointer;\"><th style=\"width: 80px;\" width=\"80\">"+_lbl_totWork+"</th><td title=\""+tTotWorkTime+"\">"+totWorkTimeHtml+"</td></tr>";
			tempTable+="<tr data-attno=\""+rowDataIdx+"\" class=\"workTime tx_etc row_tot_AttRealTime\" style=\"cursor: pointer;\"><th><spring:message code='Cache.lbl_n_att_acknowledgedWork'/></th><td title=\""+tAttRealTime+"\">"+attRealTimeHtml+"</td></tr>";
			tempTable+="<tr data-attno=\""+rowDataIdx+"\" class=\"workTime tx_etc row_tot_ExtenAc\" style=\"cursor: pointer;\"><th><spring:message code='Cache.lbl_att_overtime'/></th><td title=\""+tExten+"\">"+extenHtml+"</td></tr>";
			tempTable+="<tr data-attno=\""+rowDataIdx+"\" class=\"workTime tx_etc row_tot_HoliAc\" style=\"cursor: pointer;\"><th><spring:message code='Cache.lbl_Holiday'/></th><td title=\""+tHoli+"\">"+holiHtml+"</td></tr>";
			tempTable+="<tr data-attno=\""+rowDataIdx+"\" class=\"workTime tx_etc row_tot_TotConfWorkTime\" style=\"cursor: pointer;\"><th><spring:message code='Cache.lbl_n_att_AttRealTime'/></th><td title=\""+tTotConfWork+"\">"+totConfWorkTimeHtml+"</td></tr>";
			tempTable+="<tr data-attno=\""+rowDataIdx+"\" class=\"workTime tx_etc row_tot_AvgWorkTime\" style=\"cursor: pointer;\"><th><spring:message code='Cache.lbl_Week'/> <spring:message code='Cache.lbl_apv_TimeAverage' /></th><td>"+AttendUtils.convertSecToStr(avgWorkTime,'H')+"</td></tr>";	//평균시간
			tempTable+="</tbody>";
			tempTable+="</table>";
			tempTable+="</td>";

			var weekRowCnt = 0;
			var dailyNum = 0;
			for(var j=0;j<dailyCnt;j++){
				var tdHtml = "";
				var dailyData = userAtt[i]['userAttDaily'][j];
				
				//자율출근 또는 선택 근로제인경우 월 법정 근로시간 표기 여부 체크용 카운트 처리
				if(dailyData.WorkingSystemType == 2) {
					_FreePartAttCnt++;
				}

				//주단위 합계 출력
				var weeklyTotalPrintFlag = false;
				if(j>0 && _strtWeek===dailyData.DayOfWeek){
					weeklyTotalPrintFlag = true;
				}
				if(weeklyTotalPrintFlag){
					//주단위 heaer width 설정
					tdHtml += "<td class=\"dailyBodyTd\" data-pagenum=\""+dailyNum+"\" style=\"background: #f5f5f5;\">";
					tdHtml += "<table class=\"ATMDailytimeTable\">";
					tdHtml += "<tbody>";
					dailyNum++;
					//주단위 합계 출력
					var weeklyData = userAtt[i]['userAttWeekly'][weekRowCnt];
					var numTotWorkTime = Number(weeklyData.TotWorkTime);
					var attAcN = Number(weeklyData.AttAcN)+Number(weeklyData.ExtenAcN)+Number(weeklyData.HoliAcN);
					var totWorkTimeHtml = "";
					var totWorkTimeD = numTotWorkTime - attAcN;
					if(_printDN){
						totWorkTimeHtml = AttendUtils.attTimeHtml(AttendUtils.convertSecToStr(totWorkTimeD,'hh'), AttendUtils.convertSecToStr(attAcN,'hh'));
					}else{
						totWorkTimeHtml = AttendUtils.convertSecToStr(weeklyData.TotWorkTime,'nbsp');
					}

					var userWorkTimeOverColor = AttendUtils.userWorkTimeOverColorV2(dailyData.userWorkInfo, numTotWorkTime, "W", "#777777");
					var tTotWorkTime = "<spring:message code='Cache.lbl_Weekly'/>:"+AttendUtils.convertSecToStr(totWorkTimeD,'H')+" /<spring:message code='Cache.lbl_night'/>:"+AttendUtils.convertSecToStr(attAcN,'H');
					if(userWorkTimeOverColor!="#777777"){
						tdHtml += "<tr class=\"workTime tx_etc row_data_TotWorkTime\" data-attno=\""+rowDataIdx+"\"><td style=\"cursor: point;\" title=\""+tTotWorkTime+"\">"+totWorkTimeHtml+"</td></tr>";
					}else{
						tdHtml += "<tr class=\"workTime tx_etc row_data_TotWorkTime\" data-attno=\""+rowDataIdx+"\"><td style=\"cursor: point;\" title=\""+tTotWorkTime+"\">"+totWorkTimeHtml+"</td></tr>";
					}
					var attRealTime = Number(weeklyData.AttRealTime);
					var attRealTimeHtml = "";
					var attRealTimeD = attRealTime - attAcN;
					if(_printDN){
						attRealTimeHtml = AttendUtils.attTimeHtml(AttendUtils.convertSecToStr(attRealTimeD,'hh'), AttendUtils.convertSecToStr(attAcN,'hh'));
					}else{
						attRealTimeHtml = AttendUtils.convertSecToStr(attRealTime,'nbsp');
					}
					var extenAcDN = "";
					if(_printDN){
						extenAcDN = AttendUtils.attTimeHtml(AttendUtils.convertSecToStr(weeklyData.ExtenAcD,'hh'), AttendUtils.convertSecToStr(weeklyData.ExtenAcN,'hh'));
					}else{
						extenAcDN = AttendUtils.convertSecToStr(weeklyData.ExtenAc,'nbsp');
					}

					var holiAcDN = "";
					if(_printDN){
						holiAcDN = AttendUtils.attTimeHtml(AttendUtils.convertSecToStr(weeklyData.HoliAcD,'hh'), AttendUtils.convertSecToStr(weeklyData.HoliAcN,'hh'));
					}else{
						holiAcDN = AttendUtils.convertSecToStr(weeklyData.HoliAc,'nbsp');
					}

					var totConfWorkTime = Number(weeklyData.TotConfWorkTime);
					var totConfWorkTimeHtml = "";
					var totConfWorkTimeD = totConfWorkTime - attAcN;
					if(_printDN){
						totConfWorkTimeHtml = AttendUtils.attTimeHtml(AttendUtils.convertSecToStr(totConfWorkTimeD,'hh'), AttendUtils.convertSecToStr(attAcN,'hh'));
					}else{
						totConfWorkTimeHtml = AttendUtils.convertSecToStr(totConfWorkTime,'nbsp');
					}

					var tAttRealTime = "<spring:message code='Cache.lbl_Weekly'/>:"+AttendUtils.convertSecToStr(attRealTimeD,'H')+" /<spring:message code='Cache.lbl_night'/>:"+AttendUtils.convertSecToStr(attAcN,'H');
					var tExten = "<spring:message code='Cache.lbl_Weekly'/>:"+AttendUtils.convertSecToStr(weeklyData.ExtenAcD,'H')+" /<spring:message code='Cache.lbl_night'/>:"+AttendUtils.convertSecToStr(weeklyData.ExtenAcN,'H');
					var tHoli = "<spring:message code='Cache.lbl_Weekly'/>:"+AttendUtils.convertSecToStr(weeklyData.HoliAcD,'H')+" /<spring:message code='Cache.lbl_night'/>:"+AttendUtils.convertSecToStr(weeklyData.HoliAcN,'H');
					var tTotConfWork = "<spring:message code='Cache.lbl_Weekly'/>:"+AttendUtils.convertSecToStr(totConfWorkTimeD,'H')+" /<spring:message code='Cache.lbl_night'/>:"+AttendUtils.convertSecToStr(attAcN,'H');


					tdHtml += "<tr class=\"workTime tx_etc row_data_AttRealTime\" data-attno=\""+rowDataIdx+"\"><td style=\"cursor: point;\" title=\""+tAttRealTime+"\">"+attRealTimeHtml+"</td></tr>";
					tdHtml += "<tr class=\"workTime tx_etc row_data_ExtenAc\" data-attno=\""+rowDataIdx+"\"><td style=\"cursor: point;\" title=\""+tExten+"\">"+extenAcDN+"</td></tr>";
					tdHtml += "<tr class=\"workTime tx_etc row_data_HoliAc\" data-attno=\""+rowDataIdx+"\"><td style=\"cursor: point;\" title=\""+tHoli+"\">"+holiAcDN+"</td></tr>";
					tdHtml += "<tr class=\"workTime tx_etc row_data_TotConfWorkTime\" data-attno=\""+rowDataIdx+"\"><td style=\"cursor: point;\" title=\""+tTotConfWork+"\">"+totConfWorkTimeHtml+"</td></tr>";
					tdHtml += "<tr class=\"workTime tx_etc row_data_AvgWorkTime\" data-attno=\""+rowDataIdx+"\"><td>&nbsp;</td></tr>";
					tdHtml += "</tbody></table>";
					tdHtml += "</td>";

					weekRowCnt++;
				}

				//days
				tdHtml += "<td class=\"dailyBodyTd\" data-pagenum=\""+dailyNum+"\" style=\"";
				if(dailyData.WorkingSystemType == 2) {
					if (dailyData.MonthlyAttAcSum >= att.monthlyMaxWorkTime) {
						tdHtml += " background: lightgray;";
					}
				}
				tdHtml += "\" data-dayList=\""+userAtt[i].userAttDaily[j].dayList+"\">";
				tdHtml += "<table class=\"ATMDailytimeTable\">";
				tdHtml += "<tbody>";

				var numTotWorkTime = Number(dailyData.TotWorkTime);
				var dayilyAttAcN = Number(dailyData.AttAcN)+Number(dailyData.ExtenAcN)+Number(dailyData.HoliAcN);
				var totWorkTimeHtml = "";
				var totWorkTimeD = numTotWorkTime - dayilyAttAcN;
				if(_printDN){
					totWorkTimeHtml = AttendUtils.attTimeHtml(AttendUtils.convertSecToStr(totWorkTimeD,'hh'), AttendUtils.convertSecToStr(dayilyAttAcN,'hh'));
				}else{
					totWorkTimeHtml = AttendUtils.convertSecToStr(numTotWorkTime,'nbsp');
				}

				var attRealTime = Number(dailyData.AttRealTime);
				var attRealTimeHtml = "";
				var attRealDTime = attRealTime - dayilyAttAcN;
				if(_printDN){
					attRealTimeHtml = AttendUtils.attTimeHtml(AttendUtils.convertSecToStr(attRealDTime,'hh'), AttendUtils.convertSecToStr(dayilyAttAcN,'hh'));
				}else{
					attRealTimeHtml = AttendUtils.convertSecToStr(attRealTime,'nbsp');
				}

				var htmlTotWorkTime = "";
				var userWorkTimeOverColor = AttendUtils.userWorkTimeOverColorV2(dailyData.userWorkInfo, numTotWorkTime, "D", "#777777");
				if(userWorkTimeOverColor!="#777777"){
					htmlTotWorkTime += "<a class=\"WorkBoxM Calling\" style=\"background-color: "+userWorkTimeOverColor+" !important;height: 18px;margin-top: -1px;\">";
					htmlTotWorkTime += totWorkTimeHtml+"</a>";
				}else{
					htmlTotWorkTime = totWorkTimeHtml;
				}

				var extenAcDN = "";
				if(_printDN){
					extenAcDN = AttendUtils.attTimeHtml(AttendUtils.convertSecToStr(dailyData.ExtenAcD,'hh'), AttendUtils.convertSecToStr(dailyData.ExtenAcN,'hh'));
				}else{
					extenAcDN = AttendUtils.convertSecToStr(dailyData.ExtenAc,'nbsp');
				}

				var holiAcDN = "";
				if(_printDN){
					holiAcDN = AttendUtils.attTimeHtml(AttendUtils.convertSecToStr(dailyData.HoliAcD,'hh'), AttendUtils.convertSecToStr(dailyData.HoliAcN,'hh'));
				}else{
					holiAcDN = AttendUtils.convertSecToStr(dailyData.HoliAc,'nbsp');
				}

				var attRealConfTime = Number(dailyData.AttRealConfTime);
				var attRealConfTimeHtml = "";
				var attRealConfTimeD = attRealConfTime - dayilyAttAcN;
				if(_printDN){
					attRealConfTimeHtml = AttendUtils.attTimeHtml(AttendUtils.convertSecToStr(attRealConfTimeD,'hh'), AttendUtils.convertSecToStr(dayilyAttAcN,'hh'));
				}else{
					attRealConfTimeHtml = AttendUtils.convertSecToStr(attRealConfTime,'nbsp');
				}
				var tTotWorkTime = "<spring:message code='Cache.lbl_Weekly'/>:"+AttendUtils.convertSecToStr(totWorkTimeD,'H')+" /<spring:message code='Cache.lbl_night'/>:"+AttendUtils.convertSecToStr(dayilyAttAcN,'H');
				var tAttRealTime = "<spring:message code='Cache.lbl_Weekly'/>:"+AttendUtils.convertSecToStr(attRealDTime,'H')+" /<spring:message code='Cache.lbl_night'/>:"+AttendUtils.convertSecToStr(dayilyAttAcN,'H');
				var tExten = "<spring:message code='Cache.lbl_Weekly'/>:"+AttendUtils.convertSecToStr(dailyData.ExtenAcD,'H')+" /<spring:message code='Cache.lbl_night'/>:"+AttendUtils.convertSecToStr(dailyData.ExtenAcN,'H');
				var tHoli = "<spring:message code='Cache.lbl_Weekly'/>:"+AttendUtils.convertSecToStr(dailyData.HoliAcD,'H')+" /<spring:message code='Cache.lbl_night'/>:"+AttendUtils.convertSecToStr(dailyData.HoliAcN,'H');
				var tTotConfWork = "<spring:message code='Cache.lbl_Weekly'/>:"+AttendUtils.convertSecToStr(attRealConfTimeD,'H')+" /<spring:message code='Cache.lbl_night'/>:"+AttendUtils.convertSecToStr(dayilyAttAcN,'H');


				tdHtml += "<tr class=\"workTime tx_etc row_data_TotWorkTime\" data-attno=\""+rowDataIdx+"\"><td style=\"cursor: pointer;\" title=\""+tTotWorkTime+"\">"+htmlTotWorkTime+"</td></tr>";
				tdHtml += "<tr class=\"workTime tx_etc row_data_AttRealTime\" data-attno=\""+rowDataIdx+"\"><td style=\"cursor: pointer;\" title=\""+tAttRealTime+"\">"+attRealTimeHtml+"</td></tr>";
				tdHtml += "<tr class=\"workTime tx_etc row_data_ExtenAc\" data-attno=\""+rowDataIdx+"\"><td style=\"cursor: pointer;\" title=\""+tExten+"\">"+extenAcDN+"</td></tr>";
				tdHtml += "<tr class=\"workTime tx_etc row_data_HoliAc\" data-attno=\""+rowDataIdx+"\"><td style=\"cursor: pointer;\" title=\""+tHoli+"\">"+holiAcDN+"</td></tr>";
				tdHtml += "<tr class=\"workTime tx_etc row_data_TotConfWorkTime\" data-attno=\""+rowDataIdx+"\"><td style=\"cursor: pointer;\" title=\""+tTotConfWork+"\">"+attRealConfTimeHtml+"</td></tr>";
				tdHtml += "<tr class=\"workTime tx_etc row_data_AvgWorkTime\" data-attno=\""+rowDataIdx+"\"><td>&nbsp;</td></tr>";
				tdHtml += "</tbody></table>";
				tdHtml += "</td>";
				dataHtml+=tdHtml;
			}//end for
			//주단위 heaer width 설정
			var tdHtml2 = "<td class=\"dailyBodyTd\" data-pagenum=\""+dailyNum+"\" style=\"background: #f5f5f5;\">";
			tdHtml2 += "<table class=\"ATMDailytimeTable\">";
			tdHtml2 += "<tbody>";
			//주단위 합계 출력
			weekRowCnt = weekCnt-1;
			var weeklyData = userAtt[i]['userAttWeekly'][weekRowCnt];
			var numTotWorkTime = Number(weeklyData.TotWorkTime);
			var attAcN = Number(weeklyData.AttAcN)+Number(weeklyData.ExtenAcN)+Number(weeklyData.HoliAcN);
			var totWorkTimeHtml = "";
			var totWorkTimeD = numTotWorkTime - attAcN;
			if(_printDN){
				totWorkTimeHtml = AttendUtils.attTimeHtml(AttendUtils.convertSecToStr(totWorkTimeD,'hh'), AttendUtils.convertSecToStr(attAcN,'hh'));
			}else{
				totWorkTimeHtml = AttendUtils.convertSecToStr(weeklyData.TotWorkTime,'nbsp');
			}

			var lastUserWorkInfo = userAtt[0].userAttDaily[dailyCnt-1].userWorkInfo;
			var userWorkTimeOverColor = AttendUtils.userWorkTimeOverColorV2(lastUserWorkInfo, numTotWorkTime, "W", "#777777");
			var tTotWorkTime = "<spring:message code='Cache.lbl_Weekly'/>:"+AttendUtils.convertSecToStr(totWorkTimeD,'H')+" /<spring:message code='Cache.lbl_night'/>:"+AttendUtils.convertSecToStr(attAcN,'H');

			if(userWorkTimeOverColor!="#777777"){
				tdHtml2 += "<tr class=\"workTime tx_etc row_data_TotWorkTime\" data-attno=\""+rowDataIdx+"\"><td style=\"cursor: pointer;\" title=\""+tTotWorkTime+"\">"+totWorkTimeHtml+"</td></tr>";
			}else{
				tdHtml2 += "<tr class=\"workTime tx_etc row_data_TotWorkTime\" data-attno=\""+rowDataIdx+"\"><td style=\"cursor: pointer;\" title=\""+tTotWorkTime+"\">"+totWorkTimeHtml+"</td></tr>";
			}
			var attRealTime = Number(weeklyData.AttRealTime);
			var attRealTimeHtml = "";
			var attRealTimeD = attRealTime - attAcN;
			if(_printDN){
				attRealTimeHtml = AttendUtils.attTimeHtml(AttendUtils.convertSecToStr(attRealTimeD,'hh'), AttendUtils.convertSecToStr(attAcN,'hh'));
			}else{
				attRealTimeHtml = AttendUtils.convertSecToStr(attRealTime,'nbsp');
			}
			var extenAcDN = "";
			if(_printDN){
				extenAcDN = AttendUtils.attTimeHtml(AttendUtils.convertSecToStr(weeklyData.ExtenAcD,'hh'), AttendUtils.convertSecToStr(weeklyData.ExtenAcN,'hh'));
			}else{
				extenAcDN = AttendUtils.convertSecToStr(weeklyData.ExtenAc,'nbsp');
			}

			var holiAcDN = "";
			if(_printDN){
				holiAcDN = AttendUtils.attTimeHtml(AttendUtils.convertSecToStr(weeklyData.HoliAcD,'hh'), AttendUtils.convertSecToStr(weeklyData.HoliAcN,'hh'));
			}else{
				holiAcDN = AttendUtils.convertSecToStr(weeklyData.HoliAc,'nbsp');
			}

			var totConfWorkTime = Number(weeklyData.TotConfWorkTime);
			var totConfWorkTimeHtml = "";
			var totConfWorkTimeD = totConfWorkTime - attAcN;
			if(_printDN){
				totConfWorkTimeHtml = AttendUtils.attTimeHtml(AttendUtils.convertSecToStr(totConfWorkTimeD,'hh'), AttendUtils.convertSecToStr(attAcN,'hh'));
			}else{
				totConfWorkTimeHtml = AttendUtils.convertSecToStr(totConfWorkTime,'nbsp');
			}
			var tAttRealTime = "<spring:message code='Cache.lbl_Weekly'/>:"+AttendUtils.convertSecToStr(attRealTimeD,'H')+" /<spring:message code='Cache.lbl_night'/>:"+AttendUtils.convertSecToStr(attAcN,'H');
			var tExten = "<spring:message code='Cache.lbl_Weekly'/>:"+AttendUtils.convertSecToStr(weeklyData.ExtenAcD,'H')+" /<spring:message code='Cache.lbl_night'/>:"+AttendUtils.convertSecToStr(weeklyData.ExtenAcN,'H');
			var tHoli = "<spring:message code='Cache.lbl_Weekly'/>:"+AttendUtils.convertSecToStr(weeklyData.HoliAcD,'H')+" /<spring:message code='Cache.lbl_night'/>:"+AttendUtils.convertSecToStr(weeklyData.HoliAcN,'H');
			var tTotConfWork = "<spring:message code='Cache.lbl_Weekly'/>:"+AttendUtils.convertSecToStr(totConfWorkTimeD,'H')+" /<spring:message code='Cache.lbl_night'/>:"+AttendUtils.convertSecToStr(attAcN,'H');

			tdHtml2 += "<tr class=\"workTime tx_etc row_data_AttRealTime\" data-attno=\""+rowDataIdx+"\"><td style=\"cursor: pointer;\" title=\""+tAttRealTime+"\">"+attRealTimeHtml+"</td></tr>";
			tdHtml2 += "<tr class=\"workTime tx_etc row_data_ExtenAc\" data-attno=\""+rowDataIdx+"\"><td style=\"cursor: pointer;\" title=\""+tExten+"\">"+extenAcDN+"</td></tr>";
			tdHtml2 += "<tr class=\"workTime tx_etc row_data_HoliAc\" data-attno=\""+rowDataIdx+"\"><td style=\"cursor: pointer;\" title=\""+tHoli+"\">"+holiAcDN+"</td></tr>";
			tdHtml2 += "<tr class=\"workTime tx_etc row_data_TotConfWorkTime\" data-attno=\""+rowDataIdx+"\"><td style=\"cursor: pointer;\" title=\""+tTotConfWork+"\">"+totConfWorkTimeHtml+"</td></tr>";
			tdHtml2 += "<tr class=\"workTime tx_etc row_tot_AvgWorkTime\" data-attno=\""+rowDataIdx+"\"><td>&nbsp;</td></tr>";
			tdHtml2 += "</tbody></table>";
			tdHtml2 += "</td>";

			weekRowCnt++;
			dataHtml+=tdHtml2;
			rowDataIdx++;

			tempTable+=dataHtml+"</tr>";
		}

		if (_page==1 || mode=="reload")	{
			$("#bodyDailyTblTbody").html("");
			//$("#bodyDataTblTbody").html("");
		}
		$("#bodyDailyTblTbody").append(tempTable);
		//$("#bodyDataTblTbody").append(dataHtml);

		autoResize();

		headDailyTableDisplay();
		//월별장표의 누적 근무시간 마우스 롤오버시 라인 백그라운드 처리
		mouseRowOverOutEvent("tr.row_tot_TotWorkTime", "tr.row_data_TotWorkTime");
		mouseRowOverOutEvent("tr.row_tot_AttRealTime", "tr.row_data_AttRealTime");
		mouseRowOverOutEvent("tr.row_tot_ExtenAc", "tr.row_data_ExtenAc");
		mouseRowOverOutEvent("tr.row_tot_HoliAc", "tr.row_data_HoliAc");
		mouseRowOverOutEvent("tr.row_tot_TotConfWorkTime", "tr.row_data_TotConfWorkTime");
		//mouseRowOverOutEvent("p.row_tot_RemainTime", "p.row_data_RemainTime");

		if(_FreePartAttCnt>0){
			var monthlyMaxWorkTime = AttendUtils.convertSecToStr(att.monthlyMaxWorkTime,'h');
			$("#div_monthlyMaxWorkTime").show();
			if(monthlyMaxWorkTime!="") {
				$("#span_monthlyMaxWorkTime").html(monthlyMaxWorkTime);
			}
		}else{
			$("#div_monthlyMaxWorkTime").hide();
		}

	}

	function mouseRowOverOutEventWeekly(obj, dtObj){
		var overColor = "rgb(173, 252, 191)";
		var outColor  = "rgba(0, 0, 0, 0)";
		var clickColor= "rgba(173, 252, 191, 100)";
		var clickColorJs= "rgb(173, 252, 191)";
		$( obj ).off();
		$( obj ).mouseover(function() {
			var thBgColor = $(obj).find("th").css("background");
			var overRGB = thBgColor.substr(4, thBgColor.indexOf(")")-4).split(', ');
			var r = Number(overRGB[0])-10;
			var g = Number(overRGB[1])-10;
			var b = Number(overRGB[2])-10;
			if(r>255){r=255;}
			if(g>255){g=255;}
			if(b>255){b=255;}
			overColor = "rgb("+r+", "+g+", "+b+")";
			var attno = $(this).data("attno")+"";
			if($(this).css("background-color")!=clickColorJs){
				if($(obj).hasClass("row_tot_TotWorkTime")){
					$(this).css("background-color", overColor);
					$(this).find("td").css("style", "background-color:"+overColor+" !important");
				}else{
					$(this).css("background-color", overColor);
				}
			}
			$(dtObj+'[data-attno="'+attno+'"]').each(function(){
				if($(this).css("background-color")!=clickColorJs){
					$(this).css("background-color", overColor);
				}
			});
		});
		$( obj ).mouseout(function() {
			var attno = $(this).data("attno")+"";
			if($(this).css("background-color")!=clickColorJs) {
				$(this).css("background-color", outColor);
			}
			$(dtObj+'[data-attno="'+attno+'"]').each(function(){
				if($(this).css("background-color")!=clickColorJs) {
					$(this).css("background-color", outColor);
				}
			});
		});
		$( obj ).click(function() {
			var thBgColor = $(obj).find("th").css("background");
			var overRGB = thBgColor.substr(4, thBgColor.indexOf(")")-4).split(', ');
			var r = Number(overRGB[0])-5;
			var g = Number(overRGB[1])-5;
			var b = Number(overRGB[2])-5;
			clickColorJs = "rgb("+r+", "+g+", "+b+")";
			clickColor = "rgba("+r+", "+g+", "+b+", 100)";

			var attno = $(this).data("attno")+"";
			if($(this).css("background-color")==clickColorJs){
				$(this).css("background-color",outColor);
			}else{
				$(this).css("background-color",clickColor);
			}
			$(dtObj+'[data-attno="'+attno+'"]').each(function(){
				if($(this).css("background-color")==clickColorJs){
					$(this).css("background-color", outColor);
				}else {
					$(this).css("background-color", clickColor);
				}
			});
		});
	}


	function mouseRowOverOutEvent(obj, dtObj){
		var overColor = "rgb(173, 252, 191)";
		var outColor  = "rgba(0, 0, 0, 0)";
		var clickColor= "rgba(173, 252, 191, 100)";
		var clickColorJs= "rgb(173, 252, 191)";
		$( obj ).off();
		$( obj ).mouseover(function() {
			var thBgColor = $(obj).find("th").css("background");
			var overRGB = thBgColor.substr(4, thBgColor.indexOf(")")-4).split(', ');
			var r = Number(overRGB[0])+10;
			var g = Number(overRGB[1])+10;
			var b = Number(overRGB[2])+10;
			if(r>255){r=255;}
			if(g>255){g=255;}
			if(b>255){b=255;}
			overColor = "rgb("+r+", "+g+", "+b+")";
			var attno = $(this).data("attno")+"";
			if($(this).css("background-color")!=clickColorJs){
				if($(obj).hasClass("row_tot_TotWorkTime")){
					$(this).css("background-color", overColor);
					$(this).find("td").css("style", "background-color:"+overColor+" !important");
				}else{
					$(this).css("background-color", overColor);
				}
			}
			$(dtObj+'[data-attno="'+attno+'"]').each(function(){
				if($(this).css("background-color")!=clickColorJs){
					$(this).css("background-color", overColor);
				}
			});
		});
		$( obj ).mouseout(function() {
			var attno = $(this).data("attno")+"";
			if($(this).css("background-color")!=clickColorJs) {
				$(this).css("background-color", outColor);
			}
			$(dtObj+'[data-attno="'+attno+'"]').each(function(){
				if($(this).css("background-color")!=clickColorJs) {
					$(this).css("background-color", outColor);
				}
			});
		});
		$( obj ).click(function() {
			var thBgColor = $(obj).find("th").css("background");
			var overRGB = thBgColor.substr(4, thBgColor.indexOf(")")-4).split(', ');
			var r = Number(overRGB[0]);
			var g = Number(overRGB[1]);
			var b = Number(overRGB[2]);
			clickColorJs = "rgb("+r+", "+g+", "+b+")";
			clickColor = "rgba("+r+", "+g+", "+b+", 100)";

			var attno = $(this).data("attno")+"";
			if($(this).css("background-color")==clickColorJs){
				$(this).css("background-color",outColor);
			}else{
				$(this).css("background-color",clickColor);
			}
			$(dtObj+'[data-attno="'+attno+'"]').each(function(){
				if($(this).css("background-color")==clickColorJs){
					$(this).css("background-color", outColor);
				}else {
					$(this).css("background-color", clickColor);
				}
			});
		});
	}

	function getAttList(){
		var mode = "append";
		if(_page == 1){
			mode = "reload";
		}
		var url = "";
		var dataterm = "";
		var pageSize = _pageSize;
		if(_pageType===0){
			url = "/groupware/attendUserSts/getUserAttendance.do"
			dataterm = "W";
			$("#PageSize").show();
		}else if(_pageType===1) {
			url = "/groupware/attendUserSts/getUserAttendance.do"
			dataterm = "M";
			pageSize = 5;
			$("#PageSize").hide();
		}else if(_pageType===2){
			url = "/groupware/attendUserSts/getUserAttendanceWeeklyViewer.do"
			dataterm = "M";
			pageSize = 5;
			$("#PageSize").hide();
		}else{
			url = "/groupware/attendUserSts/getUserAttendanceDailyViewer.do"
			dataterm = "M";
			pageSize = 5;
			$("#PageSize").hide();
		}
		var params = {
			groupPath : 	$("#groupPath").val()
			,dateTerm : dataterm
			,targetDate : _targetDate
			,rangeStartDate : _rangeStartDate
			,rangeEndDate : _rangeEndDate
			,rangeWeekNum : _rangeWeekNum
			,pageSize : pageSize
			,pageNo : _page
			,printDN : _printDN
			,sUserTxt : $("#sUserTxt").val()
			,sJobTitleCode : $("#jobGubun").val()=="JobTitle"?$("#jobCode").val():null
			,sJobLevelCode : $("#jobGubun").val()=="JobLevel"?$("#jobCode").val():null
			,weeklyWorkType : $("#weeklyWorkType").val()
			,weeklyWorkValue : $("#weeklyWorkValue").val()
			,retireUser:$("#retireUser").is(":checked")?"":"INOFFICE"
			,incld_weeks: $("#ckb_incld_weeks").is(":checked")
		}

		g_loadMode = true;
		$.ajax({
			type:"POST",
			dataType : "json",
			data: params,
			url:url,
			success:function (data) {
				if(_page==1){
					_data = data.data;
				}else{
					if(_pageType===2) {
						var newData = data.data.userAttStatusInfo;
						Array.prototype.push.apply(_data.userAttStatusInfo, newData);
					}else if(_pageType===3){
						var newData = data.data.userAtt;
						Array.prototype.push.apply(_data.userAtt, newData);
					}
				}
				if(data.status =="SUCCESS"){
					if(data.loadCnt > 0){
						if(_pageType===0){
							setWeekHtml(data.data, data.monthlyMaxWorkTime);
							$("#attTable").scroll(function(){
								var scrollTop = $(this).scrollTop();
								var innerHeight = $(this).innerHeight();
								var scrollHeight = $(this).prop('scrollHeight');

								if (scrollTop + innerHeight+10 >= scrollHeight) {
									_page++;
									$("#attTable").off();
									getAttList();
								}
							});
						}else if(_pageType===1){
							setMonthHtml(data.data, data.monthlyMaxWorkTime);
						}else if(_pageType===2){
							setMonthlyByWeeklyHtml(data.data, mode);
						}else if(_pageType===3){
							setMonthlyByDailyHtml(data.data, mode);
						}

						if(_page == 1){
							showPageing(data.page);
						}
					}
				}else{
					Common.Warning("<spring:message code='Cache.msg_sns_03'/>");
				}
				$('#loading-spinner').hide();
				g_loadMode = false;
			}
		});
	}

	//근태현황수정 팝업
	function goAttStatusSetPopup(u,t){

		AttendUtils.openAttMyStatusPopup(u,t,'Y');

		//AttendUtils.openAttStatusSetPopup(u,t);
	}

	// 일괄 출퇴근 팝업
	function goAllCommutePopup(){
		AttendUtils.openAllCommutePopup();
	}

	//조직도 팝업 콜백
	function orgMapLayerPopupCallBack(orgData) {
		wiUrArry = new Array();
		var data = $.parseJSON(orgData);
		var item = data.item
		var len = item.length;
		//기존 입력정보 초기화
		attPopValueClear();

		var childPop = $('#AttendAttStstusPopup_if').contents();
		//사용자 정보 표시
		childPop.find('#userCode').val(item[0].UserCode);
		childPop.find('#at_dept').html(CFN_GetDicInfo(item[0].RGNM));
		childPop.find('#at_name').html(CFN_GetDicInfo(item[0].DN));
	}

	function attPopValueClear(){
		var childPop = $('#AttendAttStstusPopup_if').contents();

		//기존 입력정보 초기화
		childPop.find('#at_dept').html("");
		childPop.find('#at_name').html("");
		childPop.find('#at_schName').html("");
		childPop.find('#AXInput-1').val("");
		childPop.find('#AXInput-2').val("");
		childPop.find('#AXInput-3').val("");

		childPop.find('#at_startHour').val("");
		childPop.find('#at_startMin').val("");
		childPop.find('#at_startAP').val("");
		childPop.find('#at_endHour').val("");
		childPop.find('#at_endMin').val("");
		childPop.find('#at_endAP').val("");

		childPop.find('#at_etc').val("");
	}

	//기타근무 리스트 팝업
	function showJobList(o){
		AttendUtils.openAttJobListPopup(o,$(o).parent(),'Y');
	}

	//연장(휴일)근무  리스트 팝업
	function showExhoList(o,gubun){
		AttendUtils.openAttExhoListPopup(o,$(o).parent(),gubun,'Y');
	}


	//연장근무 수정 팝업
	function goAttStatusExPopup(u,t,reqType){
		AttendUtils.openAttExHoInfoPopup(u,t,reqType,'','Y');
	}


</script>

<!-- <div id='loading-spinner'>
	<div><span>
		<img src='/groupware/resources/images/loader.gif'>
	</span></div>
</div> -->
