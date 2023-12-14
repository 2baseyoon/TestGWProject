<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="resource_write_page" data-close-btn="none">
	<header id="resource_write_header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript: window.sessionStorage.removeItem('resource_writeinit'); mobile_comm_back();" class="topH_close"><span><!-- 닫기 --></span></a>
				<div class="menu_link gnb">
					<a id="resource_write_title" class="pg_tit"><spring:message code='Cache.lbl_Write' /></a> <!-- 작성 -->
				</div>
			</div>
			<div class="utill">
				<a id="resource_write_btn_regist" href="javascript: mobile_resource_regist('I');" class="topH_save"><span class="Hicon">등록</span></a> <!-- 등록 -->
				<a id="resource_write_btn_modify" href="javascript: mobile_resource_regist('U');" class="topH_save" style="display: none;"><span class="Hicon">수정</span></a> <!-- 수정 -->
			</div>
		</div>
	</header>

	<div data-role="content" class="cont_wrap" id="resource_write_content">
		<div class="write_wrap">
			<div class="sel_resource">
				<p id="resource_write_resourceName"></p>
				<input type="hidden" id="resource_write_resourceID">
				<div class="btn_area">
					<a href="javascript: mobile_resource_clickbizplace('write');" class="g_btn01"><spring:message code='Cache.lbl_Select' /></a> <!-- 선택 -->
					<a href="javascript: mobile_resource_clickResourceInfo();" class="g_btn01"><spring:message code='Cache.lbl_FromInfo' /></a> <!-- 정보 -->
				</div>
			</div>
			<div class="dates_wrap">
				<div class="dates start">
					<div>
						<input type="checkbox" name="resource_write_chkAllDay" id="resource_write_chkAllDay" onclick="javascript: mobile_resource_chkAllDay();"><label for="resource_write_chkAllDay"><spring:message code='Cache.lbl_AllDay' /></label>
					</div>
					<p>
						<input type="text" id="resource_write_startdate" placeholder="2019.07.16(화)" class="dates_date input_date" onchange="mobile_resource_chkDateValidation('SD');">
					</p>
					<p>
						<select id="resource_write_starttime" class="dates_time input_time" onchange="mobile_resource_chkDateValidation('ST');"></select>
					</p>
				</div>
				<div class="dates end">
					<div class="emptyspace"></div>
					<p>
						<input id="resource_write_enddate" type="text" placeholder="2019.07.16(화)" class="dates_date input_date" onchange="mobile_resource_chkDateValidation('ED');">
					</p>
					<p>
						<select id="resource_write_endtime" class="dates_time input_time" onchange="mobile_resource_chkDateValidation('ET');"></select>
					</p>
				</div>
				<input type="hidden" id="resource_write_hidstartdate">
				<input type="hidden" id="resource_write_hidstarttime">
				<input type="hidden" id="resource_write_hidenddate">
				<input type="hidden" id="resource_write_hidendtime">
			</div>
			<div class="editor_wrap">
				<textarea id="resource_write_subject" rows="8" cols="80"  voiceInputType="append" voiceStyle="" voiceCallBack="" placeholder="<spring:message code='Cache.msg_ReservationWrite_01' />" class="txareas full mobileViceInputCtrl"></textarea> <!-- 용도를 입력해주세요. -->
			</div>
			<div class="joins_wrap active">
				<div class="jmail">
					<input type="text" title="참석자입력" name="resource_write_emailtxt" class="inputbox joins_n" placeholder="<spring:message code='Cache.lbl_schedule_attendant' />" readonly>
					<a id="resource_write_btnAddOrg" onclick="javascript: mobile_resource_openOrg();" class="btn_org_n">추가</a>
				</div>
				<div class="joins_a" id="joins_wrapArea" style="display: none;padding-right:10px;"></div>
			</div>
			<div class="alims_wrap" adata='active'>
				<p class="tx"><spring:message code='Cache.lbl_Alram' /></p>
				<div id="resource_write_notice" class="opt_setting new" onclick="mobile_resource_clickUiSetting(this, 'on');" sdata='alims_wrapArea'>
					<span class="ctrl"></span>
				</div>
			</div>
			<div class="more_info alarm" id="alims_wrapArea" style='display:none;'>
				<dl class="pre_alarm" id="resource_write_prealarm">
					<dt><spring:message code='Cache.lbl_BeforInform' /></dt> <!-- 미리알림 -->
					<dd>
						<div id="resource_write_notice_reminderYN" class="opt_setting"  onclick="mobile_resource_clickUiSetting(this, 'on');">
							<span class="ctrl"></span>
						</div>
						<spring:message code='Cache.lbl_BeforInform' /> 
						<select id="resource_write_notice_remindertime">
							<option value="1">1<spring:message code='Cache.lbl_before_m' /></option> <!-- 1분 전 -->
							<option selected="selected" value="10">10<spring:message code='Cache.lbl_before_m' /></option> <!-- 10분 전 -->
							<option value="20">20<spring:message code='Cache.lbl_before_m' /></option> <!-- 20분 전 -->
							<option value="30">30<spring:message code='Cache.lbl_before_m' /></option> <!-- 30분 전 -->
							<option value="60">1<spring:message code='Cache.lbl_before_h' /></option> <!-- 1시간 전 -->
							<option value="180">3<spring:message code='Cache.lbl_before_h' /></option> <!-- 3시간 전 -->
							<option value="360">6<spring:message code='Cache.lbl_before_h' /></option> <!-- 6시간 전 -->
							<option value="720">12<spring:message code='Cache.lbl_before_h' /></option> <!-- 12시간 전 -->
							<option value="1440">1<spring:message code='Cache.lbl_before_d' /></option> <!-- 1일 전 -->
							<option value="2880">2<spring:message code='Cache.lbl_before_d' /></option> <!-- 2일 전 -->
							<option value="4320">3<spring:message code='Cache.lbl_before_d' /></option> <!-- 3일 전 -->
						</select>
					</dd>
				</dl>
				<dl id="resource_write_commentalarm" style="display: none;">
					<dt><spring:message code='Cache.lbl_commentNotify' /></dt> <!-- 댓글알림 -->
					<dd>
						<div id="resource_write_notice_commentYN" class="opt_setting"   onclick="mobile_resource_clickUiSetting(this, 'on');">
						<span class="ctrl"></span>
						</div>
					</dd>
				</dl>
			</div>
			<div class="calendarlinkage_wrap" adata='active'><p class="tx"><spring:message code='Cache.lbl_schedule_linkage' /></p><div id="resource_write_interlockYN" onclick="mobile_resource_clickUiSetting(this, 'on');" class="opt_setting new"><span class="ctrl"></span></div></div>
			<div class="repeats_wrap" adata='active'>
				<p id="resource_write_repeat" class="tx"><spring:message code='Cache.lbl_noRepeat' /></p>
				<div id="resource_write_repeatChk" onclick="mobile_schedule_clickUiSetting(this, 'on')" sdata="resource_write_repeatHide" class="opt_setting new"><span class="ctrl"></span></div>
				<input type="hidden" id="resource_write_IsRepeat" value="N">
				<a class="acc_link" id="resource_write_repeatHide" style="display:none;" onclick="javascript: mobile_resource_showORhide(this, 'self');"><spring:message code='Cache.lbl_noRepeat' /></a> <!-- 반복없음 -->
				<div class="acc_cont">
					<div class="tab_wrap">
						<ul class="g_tab" id="resource_write_repeatTab">
							<li id="resource_write_tabNo" class="on"><a href="javascript: mobile_resource_changeTab('No');"><spring:message code='Cache.lbl_noexists' /></a></li> <!-- 없음 -->
							<li id="resource_write_tabDay"><a href="javascript: mobile_resource_changeTab('Day');"><spring:message code='Cache.lbl_EveryDay' /></a></li> <!-- 매일 -->
							<li id="resource_write_tabWeek"><a href="javascript: mobile_resource_changeTab('Week');"><spring:message code='Cache.lbl_EveryWeek' /></a></li> <!-- 매주 -->
							<li id="resource_write_tabMonth"><a href="javascript: mobile_resource_changeTab('Month');"><spring:message code='Cache.lbl_EveryMonth' /></a></li> <!-- 매월 -->
							<li id="resource_write_tabYear"><a href="javascript: mobile_resource_changeTab('Year');"><spring:message code='Cache.lbl_EveryYear' /></a></li> <!-- 매년 -->
						</ul>
						<div class="tab_cont_wrap" id="resource_write_repeatDiv">
							<div class="tab_cont" id="resource_write_divNo" style="display:none;">
							</div>
							<div class="tab_cont" id="resource_write_divDay" style="display:none;">            
								<ul>
									<li>
										<div>
											<p>
												<input type="radio" value="set" name="resource_write_day_date" id="resource_write_day_setday" checked="checked">
												<spring:message code='Cache.lbl_Every' /> <input type="text" class="num" id="resource_write_day_inputday" value="1"> <spring:message code='Cache.lbl_dayEvery' /> <label for="resource_write_day_setday"></label> <!--  매 n 일 마다 -->
											</p>
											<p>
												<input type="radio" value="every" name="resource_write_day_date" id="resource_write_day_everyday">
												<label for="resource_write_day_everyday"><spring:message code='Cache.lbl_EveryDay' />(<spring:message code='Cache.lbl_Weekday' />)</label> <!-- 매일(평일) -->
											</p>
										</div>
									</li>
									<li>
										<div>
											<p>
												<input type="radio" value="end" name="resource_write_day_repeat" id="resource_write_day_setend">
												<input type="text" id="resource_write_day_inputend" class="dates_date input_date" placeholder="<spring:message code='Cache.lbl_EndDate2' />"><label for="resource_write_day_setend"></label> <!-- 끝 날짜 -->
											</p>
											<p>
												<input type="radio" value="repeat" name="resource_write_day_repeat" id="resource_write_day_setrepeat" checked="checked">
												<input type="text" id="resource_write_day_inputrepeat" class="num" value="5"> <spring:message code='Cache.lbl_RepeatTimes' /><label for="resource_write_day_setrepeat"></label> <!-- 회 반복 -->
											</p>
										</div>
									</li>
								</ul>
							</div>
							<div class="tab_cont" id="resource_write_divWeek" style="display:none;">
								<ul>
									<li>
										<div class="full"><p><spring:message code='Cache.lbl_Every' /> <input type="text" id="resource_write_week_inputweek" class="num" value="1"> <spring:message code='Cache.lbl_weekEvery2' /></p></div> <!-- 매 n 주 마다 -->
										<div class="btn_area" id="resource_write_divDayOfWeekBtn">
											<a id="resource_write_week_sun" onclick="javascript: mobile_resource_changeDayBtn(this);" class="day"><spring:message code='Cache.lbl_sch_sun' /></a> <!-- 일 -->
											<a id="resource_write_week_mon" onclick="javascript: mobile_resource_changeDayBtn(this);" class="day"><spring:message code='Cache.lbl_sch_mon' /></a> <!-- 월 -->
                      						<a id="resource_write_week_tue" onclick="javascript: mobile_resource_changeDayBtn(this);" class="day"><spring:message code='Cache.lbl_sch_tue' /></a> <!-- 화 -->
                      						<a id="resource_write_week_wed" onclick="javascript: mobile_resource_changeDayBtn(this);" class="day"><spring:message code='Cache.lbl_sch_wed' /></a> <!-- 수 -->
                      						<a id="resource_write_week_thu" onclick="javascript: mobile_resource_changeDayBtn(this);" class="day"><spring:message code='Cache.lbl_sch_thr' /></a> <!-- 목 -->
                      						<a id="resource_write_week_fri" onclick="javascript: mobile_resource_changeDayBtn(this);" class="day"><spring:message code='Cache.lbl_sch_fri' /></a> <!-- 금 -->
                      						<a id="resource_write_week_sat" onclick="javascript: mobile_resource_changeDayBtn(this);" class="day"><spring:message code='Cache.lbl_sch_sat' /></a> <!-- 토 -->
                      					</div>
									</li>
									<li>
										<div>
											<p>
												<input type="radio" value="end" name="resource_write_week_repeat" id="resource_write_week_setend">
												<input type="text" id="resource_write_week_inputend" class="dates_date input_date" placeholder="<spring:message code='Cache.lbl_EndDate2' />"><label for="resource_write_week_setend"></label> <!-- 끝 날짜 -->
											</p>
											<p>
												<input type="radio" value="repeat" name="resource_write_week_repeat" id="resource_write_week_setrepeat" checked="checked">
												<input type="text" id="resource_write_week_inputrepeat" class="num" value="5"> <spring:message code='Cache.lbl_RepeatTimes' /><label for="resource_write_week_setrepeat"></label> <!-- 회 반복 -->
											</p>
										</div>
									</li>
								</ul>
							</div>
							<div class="tab_cont" id="resource_write_divMonth" style="display:none;">
								<ul>
									<li>
										<div class="full">
											<p><spring:message code='Cache.lbl_Every' /> <input type="text" id="resource_write_month_inputmonth" class="num" value="1"> <spring:message code='Cache.lbl_monthEvery2' /></p> <!-- 매 n 개월 마다 -->
										</div>
										<div>
											<p>
												<input type="radio" value="day" name="resource_write_month_date" id="resource_write_month_setday" checked="checked">
												<input type="text" id="resource_write_month_inputday" class="num"> <spring:message code='Cache.lbl_day' /><label for="resource_write_month_setday"></label> <!-- 일 -->
											</p>
											<p>
												<input type="radio" value="dayofweek" name="resource_write_month_date" id="resource_write_month_setdayofweek">
												<select id="resource_write_month_selectseq">
													<option value="1"><spring:message code='Cache.lbl_First' /></option> <!-- 첫째 -->
													<option value="2"><spring:message code='Cache.lbl_Second' /></option> <!-- 둘째 -->
													<option value="3"><spring:message code='Cache.lbl_Third' /></option> <!-- 셋째 -->
													<option value="4"><spring:message code='Cache.lbl_Forth' /></option> <!-- 넷째 -->
													<option value="5"><spring:message code='Cache.lbl_Fifth' /></option> <!-- 다섯째 -->
												</select>
												<select id="resource_write_month_selectdayofweek">
													<option value="<spring:message code='Cache.lbl_sch_sun' />"><spring:message code='Cache.lbl_Sunday' /></option> <!-- 일요일 -->
													<option value="<spring:message code='Cache.lbl_sch_mon' />"><spring:message code='Cache.lbl_Monday' /></option> <!-- 월요일 -->
													<option value="<spring:message code='Cache.lbl_sch_tue' />"><spring:message code='Cache.lbl_Tuesday' /></option> <!-- 화요일 -->
													<option value="<spring:message code='Cache.lbl_sch_wed' />"><spring:message code='Cache.lbl_Wednesday' /></option> <!-- 수요일 -->
													<option value="<spring:message code='Cache.lbl_sch_thr' />"><spring:message code='Cache.lbl_Thursday' /></option> <!-- 목요일 -->
													<option value="<spring:message code='Cache.lbl_sch_fri' />"><spring:message code='Cache.lbl_Friday' /></option> <!-- 금요일 -->
													<option value="<spring:message code='Cache.lbl_sch_sat' />"><spring:message code='Cache.lbl_Saturday' /></option> <!-- 토요일 -->
												</select>
												<label for="resource_write_month_setdayofweek"></label>
											</p>
										</div>
									</li>
									<li>
										<div>
											<p>
												<input type="radio" value="end" name="resource_write_month_repeat" id="resource_write_month_setend">
												<input type="text" id="resource_write_month_inputend" class="dates_date input_date" placeholder="<spring:message code='Cache.lbl_EndDate2' />"><label for="resource_write_month_setend"></label> <!-- 끝 날짜 -->
											</p>
											<p>
												<input type="radio" value="repeat" name="resource_write_month_repeat" id="resource_write_month_setrepeat" checked="checked">
												<input type="text" id="resource_write_month_inputrepeat" class="num" value="5"> <spring:message code='Cache.lbl_RepeatTimes' /><label for="resource_write_month_setrepeat"></label> <!-- 회 반복 -->
											</p>
										</div>
									</li>
								</ul>
							</div>
							<div class="tab_cont" id="resource_write_divYear" style="display:none;">
								<ul>
									<li>
										<div class="full">
											<p>
												<spring:message code='Cache.lbl_Every' /> <input type="text" id="resource_write_year_inputyear" class="num" value="1"> <spring:message code='Cache.lbl_yearEvery' />  <!-- 매 n 년마다 -->
												<select id="resource_write_year_selectmonth">
													<option value="1"><spring:message code='Cache.lbl_Month_1' /></option> <!-- 1월 -->
													<option value="2"><spring:message code='Cache.lbl_Month_2' /></option> <!-- 2월 -->
													<option value="3"><spring:message code='Cache.lbl_Month_3' /></option> <!-- 3월 -->
													<option value="4"><spring:message code='Cache.lbl_Month_4' /></option> <!-- 4월 -->
													<option value="5"><spring:message code='Cache.lbl_Month_5' /></option> <!-- 5월 -->
													<option value="6"><spring:message code='Cache.lbl_Month_6' /></option> <!-- 6월 -->
													<option value="7"><spring:message code='Cache.lbl_Month_7' /></option> <!-- 7월 -->
													<option value="8"><spring:message code='Cache.lbl_Month_8' /></option> <!-- 8월 -->
													<option value="9"><spring:message code='Cache.lbl_Month_9' /></option> <!-- 9월 -->
													<option value="10"><spring:message code='Cache.lbl_Month_10' /></option> <!-- 10월 -->
													<option value="11"><spring:message code='Cache.lbl_Month_11' /></option> <!-- 11월 -->
													<option value="12"><spring:message code='Cache.lbl_Month_12' /></option> <!-- 12월 -->
												</select>
											</p>
										</div>
										<div>
											<p>
												<input type="radio" value="day" name="resource_write_year_date" id="resource_write_year_setday" checked="checked">
												<input type="text" id="resource_write_year_inputday" class="num"> <spring:message code='Cache.lbl_day' /><label for="resource_write_year_setday"></label> <!-- 일 -->
											</p>
											<p>
												<input type="radio" value="dayofweek" name="resource_write_year_date" id="resource_write_year_setdayofweek">
												<select id="resource_write_year_selectseq">
													<option value="1"><spring:message code='Cache.lbl_First' /></option> <!-- 첫째 -->
													<option value="2"><spring:message code='Cache.lbl_Second' /></option> <!-- 둘째 -->
													<option value="3"><spring:message code='Cache.lbl_Third' /></option> <!-- 셋째 -->
													<option value="4"><spring:message code='Cache.lbl_Forth' /></option> <!-- 넷째 -->
													<option value="5"><spring:message code='Cache.lbl_Fifth' /></option> <!-- 다섯째 -->
												</select>
												<select id="resource_write_year_selectdayofweek">
													<option value="<spring:message code='Cache.lbl_sch_sun' />"><spring:message code='Cache.lbl_Sunday' /></option> <!-- 일요일 -->
													<option value="<spring:message code='Cache.lbl_sch_mon' />"><spring:message code='Cache.lbl_Monday' /></option> <!-- 월요일 -->
													<option value="<spring:message code='Cache.lbl_sch_tue' />"><spring:message code='Cache.lbl_Tuesday' /></option> <!-- 화요일 -->
													<option value="<spring:message code='Cache.lbl_sch_wed' />"><spring:message code='Cache.lbl_Wednesday' /></option> <!-- 수요일 -->
													<option value="<spring:message code='Cache.lbl_sch_thr' />"><spring:message code='Cache.lbl_Thursday' /></option> <!-- 목요일 -->
													<option value="<spring:message code='Cache.lbl_sch_fri' />"><spring:message code='Cache.lbl_Friday' /></option> <!-- 금요일 -->
													<option value="<spring:message code='Cache.lbl_sch_sat' />"><spring:message code='Cache.lbl_Saturday' /></option> <!-- 토요일 -->
												</select>
												<label for="resource_write_year_setdayofweek"></label>
											</p>
										</div>
									</li>
									<li>
										<div>
											<p>
												<input type="radio" value="end" name="resource_write_year_repeat" id="resource_write_year_setend">
												<input type="text" id="resource_write_year_inputend" class="dates_date input_date" placeholder="<spring:message code='Cache.lbl_EndDate2' />"><label for="resource_write_year_setend"></label> <!-- 끝 날짜 -->
											</p>
											<p>
												<input type="radio" value="repeat" name="resource_write_year_repeat" id="resource_write_year_setrepeat"  checked="checked">
												<input type="text" id="resource_write_year_inputrepeat" class="num" value="5"> <spring:message code='Cache.lbl_RepeatTimes' /><label for="resource_write_year_setrepeat"></label> <!-- 회 반복 -->
											</p>
										</div>
									</li>
								</ul>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>