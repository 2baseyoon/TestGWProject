<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="schedule_write_page">

	<header id="schedule_write_header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript: window.sessionStorage.removeItem('schedule_writeinit'); mobile_comm_back();" class="topH_close"><span class="Hicon">닫기</span></a>
				<div class="menu_link"><a id="schedule_write_mode" href="#" class="pg_tit"><spring:message code='Cache.btnWrite' /></a></div><!-- 작성 -->
			</div>
			<div class="utill">
				<a id="schedule_write_save" href="javascript: mobile_schedule_save();" class="topH_save"><span class="Hicon">등록</span></a><!-- 등록 -->
			</div>
		</div>
	</header>

	<div data-role="content" class="cont_wrap" id="schedule_write_content">
		<div class="write_wrap">
			<select id="schedule_write_schedulefolder" name="" class="full sel_type" onchange="mobile_schedule_folderchange();">
			 	<option value=""><spring:message code='Cache.lbl_sch_Classification' /></option> <!-- 일정구분 -->
			</select>
	        <div class="title_wrap">
		          <input id="schedule_write_subject" type="text" class="full mobileViceInputCtrl" voiceInputType="change" voiceStyle="" voiceCallBack="" placeholder="<spring:message code='Cache.lbl_subject' />" maxlength="100"> <!-- 제목 -->
	        </div>
			<div class="dates_wrap">
				<div class="dates start">
					<div>
						<input type="checkbox" name="schedule_write_isallday" id="schedule_write_isallday" onclick="javascript: mobile_schedule_clickallday();"><label for="schedule_write_isallday"><spring:message code='Cache.lbl_AllDay' /></label>
					</div>
					<p>
						<input type="text" id="schedule_write_startday" placeholder="<spring:message code='Cache.lbl_startdate' />" class="dates_date input_date" onchange="mobile_schedule_chkDateValidation('SD');">
					</p>
					<p>
						<select id="schedule_write_starttime" class="dates_time input_time" onchange="mobile_schedule_chkDateValidation('ST');"></select>
					</p>
				</div>
				<div class="dates end">
					<div class="emptyspace"></div>
					<p>
						<input id="schedule_write_endday" type="text" placeholder="<spring:message code='Cache.lbl_EndDate' />" class="dates_date input_date"  onchange="mobile_schedule_chkDateValidation('ED');">
					</p>
					<p>
						<select id="schedule_write_endtime" class="dates_time input_time" onchange="mobile_schedule_chkDateValidation('ET');"></select>
					</p>
				</div>
			</div>
			<div class="editor_wrap">
				<textarea id="schedule_write_description" name="name"  voiceInputType="append" voiceStyle="" voiceCallBack="" class="txareas full mobileViceInputCtrl" rows='8' cols="80" placeholder="<spring:message code='Cache.lbl_Contents' />"></textarea> <!-- 내용 -->
			</div>
			<div class="joins_wrap active">
				<div class="jmail">
					<input type="text" title="참석자입력" name="schedule_write_emailtxt" class="inputbox joins_n" placeholder="<spring:message code='Cache.lbl_schedule_attendant' />(<spring:message code='Cache.msg_schedule_enterEmailTxt' />)">
					<a id="schedule_write_btnAddEmail" onclick="javascript: mobile_schedule_clickAddEmail(this);"  class="btn_add_n">추가</a>
					<a id="schedule_write_btnAddOrg" onclick="javascript: mobile_schedule_openOrg();" class="btn_org_n">추가</a>
				</div>
				<div class="jcheck" style="display: none;">
					<div>
						<input type="checkbox" id="schedule_write_isinviteother"><label for="schedule_write_isinviteother"><spring:message code='Cache.lbl_schedule_inviteAuth' /></label>
					</div>
				</div>
				<div class="joins_a" id="joins_wrapArea" style="display: none;padding-right:10px;"></div>
			</div>
			<div class="resources_wrap">
				<p id="resourceSelectTitle" class="tx"><spring:message code='Cache.lbl_Resources' /></p>
				<div id="resourcesSelect_wrapArea" class="resources_a" style="display:none;"></div>
				<a id="schedule_write_btnAddResource" onclick="javascript: mobile_schedule_openResource();" class="btn_add_n"><spring:message code='Cache.btn_Add' /></a> <!-- 추가 -->
			</div>
			<div class="places_wrap">
				<div class="place_area">
					<input type="text" id="txtPlace" title="링크입력" name="linknames" class="inputbox places_n" placeholder="<spring:message code='Cache.lbl_Place' />">
				</div>
			</div>
			<div class="alims_wrap"><p class="tx"><spring:message code='Cache.lbl_Alram' /></p><div id="BtnAlims_wrap" onclick="mobile_schedule_alimsWrapShow(this)" class="opt_setting new"><span class="ctrl"></span></div></div>
			<div id="schedule_write_alarmdiv" class="more_info alarm" style="display:none;">
				<dl class="pre_alarm"  id="schedule_write_prealarm">
					<dt><spring:message code='Cache.lbl_BeforInform' /></dt>
					<dd>
						<div id="schedule_write_notice_reminderYN" class="opt_setting" onclick="mobile_schedule_clickUiSetting(this, 'on'); $('#schedule_write_notice_divReminderTime').css('visibility', ($('#schedule_write_notice_divReminderTime').css('visibility') == 'hidden' ? 'visible' : 'hidden'));">
							<span class="ctrl"></span>
						</div>
						<select id="schedule_write_notice_remindertime" class="" name="">
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
				<dl  id="schedule_write_commentalarm" style="display:none;">
					<dt><spring:message code='Cache.lbl_commentNotify' /></dt>
					<dd>
						<div  id="schedule_write_notice_commentYN" class="opt_setting" onclick="mobile_schedule_clickUiSetting(this, 'on');">
							<span class="ctrl"></span>
						</div>
					</dd>
				</dl>
			</div>
			<div class="impts_wrap" adata='active'><p class="tx"><spring:message code='Cache.lbl_Important' /></p><div id="schedule_write_isimportantstate" class="opt_setting new" onclick="mobile_schedule_clickUiSetting(this, 'on');"><span class="ctrl"></span></div></div>
			<div class="locks_wrap active" adata='active'><p class="tx"><spring:message code='Cache.lbl_Private' /></p><div id="schedule_write_ispublic" onclick="mobile_schedule_clickUiSetting(this, 'on')" class="opt_setting new"><span class="ctrl"></span></div></div><!-- 비공개 -->
			<div class="repeats_wrap" adata='active'>
				<p id="schedule_write_repeat" class="tx"><spring:message code='Cache.lbl_noRepeat' /></p>
				<div id="schedule_write_repeatChk" onclick="mobile_schedule_clickUiSetting(this, 'on')" adata="schedule_write_repeatHide" class="opt_setting new"><span class="ctrl"></span></div>
				<input type="hidden" id="schedule_write_IsRepeat" value="N">
				<a class="acc_link" id="schedule_write_repeatHide" style="display:none;" onclick="javascript: mobile_schedule_showORhide(this, 'self');"><spring:message code='Cache.lbl_noRepeat' /></a> <!-- 반복없음 -->
				<div class="acc_cont">
					<div class="tab_wrap">
						<ul  id="schedule_write_repeat" class="g_tab">
							<li id="schedule_write_tabNo" value=""><a href="javascript: mobile_schedule_changeTab('No');"><spring:message code='Cache.lbl_noexists' /></a></li> <!-- 없음 -->
							<li id="schedule_write_tabDay" value="D"><a href="javascript: mobile_schedule_changeTab('Day');"><spring:message code='Cache.lbl_EveryDay' /></a></li> <!-- 매일 -->
							<li id="schedule_write_tabWeek" value="W"><a href="javascript: mobile_schedule_changeTab('Week');"><spring:message code='Cache.lbl_EveryWeek' /></a></li> <!-- 매주 -->
							<li id="schedule_write_tabMonth" value="M"><a href="javascript: mobile_schedule_changeTab('Month');"><spring:message code='Cache.lbl_EveryMonth' /></a></li> <!-- 매월 -->
							<li id="schedule_write_tabYear" value="Y"><a href="javascript: mobile_schedule_changeTab('Year');"><spring:message code='Cache.lbl_EveryYear' /></a></li> <!-- 매년 -->
						</ul>
						<div class="tab_cont_wrap">
							<div class="tab_cont">
							</div>
							<div class="tab_cont">
							 	<ul>
							 		<li>
										<div>
											<p>
												<input type="radio" name="schedule_write_repeatday1" value=""  id="schedule_write_repeatday_day">
												<spring:message code='Cache.lbl_Every' /> <input id="schedule_write_repeatday_dayvalue" type="text" name="radio1" value="1" class="num"> <spring:message code='Cache.lbl_dayEvery' /> <!--  매 n 일 마다 -->
												<label for="schedule_write_repeatday_day"></label>
											</p>
											<p>
												<input type="radio" name="schedule_write_repeatday1" value="" id="schedule_write_repeatday_all">
												<label for="schedule_write_repeatday_all"><spring:message code='Cache.lbl_EveryDay' />(<spring:message code='Cache.lbl_Weekday' />)</label> <!-- 매일(평일) -->
											</p>
										</div>
									</li>
									<li>
										<div>
											<p><spring:message code='Cache.lbl_startdate' /></p>
											<p>
												<input id="schedule_write_repeatday_startdate" type="text" name="" value="" class="dates_date input_date" placeholder="<spring:message code='Cache.lbl_startdate' />"> <!-- 끝 날짜 -->
											</p>
										</div>
										<div>
											<p>
												<input type="radio" name="schedule_write_repeatday2" id="schedule_write_repeatday_useenddate" onclick="setEnd(this);" value="date">
												<label for="schedule_write_repeatday_useenddate"></label>
												<input id="schedule_write_repeatday_enddate" type="text" class="dates_date input_date" placeholder="<spring:message code='Cache.lbl_EndDate2' />" disabled> <!-- 끝 날짜 -->
											</p>
											<p>
												<input type="radio" name="schedule_write_repeatday2" id="schedule_write_repeatday_userepeat" onclick="setEnd(this);" value="count">
												<label for="schedule_write_repeatday_userepeat"></label>
												<input id="schedule_write_repeatday_repeatcnt"  type="text" name="" value="1" class="num">	<spring:message code='Cache.lbl_RepeatTimes' /> <!-- 회 반복 -->
											 </p>
										</div>
									</li>
								</ul>
							</div>
							<div class="tab_cont">
								<ul>
									<li>
										<div class="full">
											<p>
												<spring:message code='Cache.lbl_Every' /> <input id="schedule_write_repeatweek_week" type="text" name="" value="1" class="num"> <spring:message code='Cache.lbl_weekEvery2' /> <!-- 매 n 주 마다 -->
											</p>
										</div>
										<div class="btn_area" >
											<a  id="schedule_write_repeatweek_sun" href="#" onclick="mobile_schedule_clickUiSetting(this, 'on');" class="day on"><spring:message code='Cache.lbl_sch_sun' /></a> <!-- 일 -->
											<a  id="schedule_write_repeatweek_mon" href="#" onclick="mobile_schedule_clickUiSetting(this, 'on');" class="day"><spring:message code='Cache.lbl_sch_mon' /></a> <!-- 월 -->
											<a  id="schedule_write_repeatweek_tue" href="#" onclick="mobile_schedule_clickUiSetting(this, 'on');" class="day"><spring:message code='Cache.lbl_sch_tue' /></a> <!-- 화 -->
											<a  id="schedule_write_repeatweek_wed" href="#" onclick="mobile_schedule_clickUiSetting(this, 'on');" class="day"><spring:message code='Cache.lbl_sch_wed' /></a> <!-- 수 -->
											<a  id="schedule_write_repeatweek_thu" href="#" onclick="mobile_schedule_clickUiSetting(this, 'on');" class="day"><spring:message code='Cache.lbl_sch_thr' /></a> <!-- 목 -->
											<a  id="schedule_write_repeatweek_fri" href="#" onclick="mobile_schedule_clickUiSetting(this, 'on');" class="day"><spring:message code='Cache.lbl_sch_fri' /></a> <!-- 금 -->
											<a  id="schedule_write_repeatweek_sat" href="#" onclick="mobile_schedule_clickUiSetting(this, 'on');" class="day"><spring:message code='Cache.lbl_sch_sat' /></a> <!-- 토 -->
										</div>
									</li>
									<li>
										<div>
											<p><spring:message code='Cache.lbl_startdate' /></p>
											<p>
												<input id="schedule_write_repeatweek_startdate" type="text" name="" value="" class="dates_date input_date" placeholder="<spring:message code='Cache.lbl_startdate' />"> <!-- 끝 날짜 -->
											</p>
										</div>
										<div>
											<p>
												<input type="radio" name="schedule_write_repeatweek" value="" id="schedule_write_repeatweek_useenddate">
												<label for="schedule_write_repeatweek_useenddate"></label>
												<input id="schedule_write_repeatweek_enddate" type="text" name="" value="" class="dates_date input_date" placeholder="<spring:message code='Cache.lbl_EndDate2' />"> <!-- 끝 날짜 -->
											</p>
											<p>
												<input type="radio" name="schedule_write_repeatweek" value="" id="schedule_write_repeatweek_userepeat">
												<label for="schedule_write_repeatweek_userepeat"></label>
												<input id="schedule_write_repeatweek_repeatcnt" type="text" name="" value="1" class="num"> <spring:message code='Cache.lbl_RepeatTimes' /> <!-- 회 반복 -->
											</p>
										</div>
									</li>
								</ul>
							</div>
							<div class="tab_cont">
								<ul>
									<li>
										<div class="full">
											<p>
												<spring:message code='Cache.lbl_Every' /> <input id="schedule_write_repeatmonth_month"  type="text" name="" value="1" class="num"> <spring:message code='Cache.lbl_monthEvery2' /> <!-- 매 n 개월 마다 -->
											</p>
										</div>
										<div>
											<p>
												<input type="radio" name="select_write_repeatmonth1" id="schedule_write_repeatmonth_useday">
												<label for="schedule_write_repeatmonth_useday"></label>
												<input type="text" name="" value="1" id="schedule_write_repeatmonth_day" class="num"> <spring:message code='Cache.lbl_day' /> <!-- 일 -->
											</p>
											<p>
												<input type="radio" name="select_write_repeatmonth1" value="" id="schedule_write_repeatmonth_usedayword">
												<label for="schedule_write_repeatmonth_usedayword"></label>
												<select id="schedule_write_repeatmonth_dayword1" class="" name="">
													<option value="1"><spring:message code='Cache.lbl_First' /></option> <!-- 첫째 -->
													<option value="2"><spring:message code='Cache.lbl_Second' /></option> <!-- 둘째 -->
													<option value="3"><spring:message code='Cache.lbl_Third' /></option> <!-- 셋째 -->
													<option value="4"><spring:message code='Cache.lbl_Forth' /></option> <!-- 넷째 -->
													<option value="5"><spring:message code='Cache.lbl_last' /></option> <!-- 마지막 -->
												</select>
												<select id="schedule_write_repeatmonth_dayword2" class="" name="">
													<option value="DAY"><spring:message code='Cache.lbl_Day_1' /></option> <!-- 날 -->
													<option value="WEEKDAY"><spring:message code='Cache.lbl_Weekday' /></option> <!-- 평일 -->
													<option value="WEEKEND"><spring:message code='Cache.lbl_Weekend' /></option> <!-- 주말 -->
													<option value="SUN"><spring:message code='Cache.lbl_Sunday' /></option> <!-- 일요일 -->
													<option value="MON"><spring:message code='Cache.lbl_Monday' /></option> <!-- 월요일 -->
													<option value="TUE"><spring:message code='Cache.lbl_Tuesday' /></option> <!-- 화요일 -->
													<option value="WED"><spring:message code='Cache.lbl_Wednesday' /></option> <!-- 수요일 -->
													<option value="THU"><spring:message code='Cache.lbl_Thursday' /></option> <!-- 목요일 -->
													<option value="FRI"><spring:message code='Cache.lbl_Friday' /></option> <!-- 금요일 -->
													<option value="SAT"><spring:message code='Cache.lbl_Saturday' /></option> <!-- 토요일 -->
												</select>
											</p>
										</div>
									</li>
									<li>
										<div>
											<p><spring:message code='Cache.lbl_startdate' /></p>
											<p>
												<input id="schedule_write_repeatmonth_startdate" type="text" name="" value="" class="dates_date input_date" placeholder="<spring:message code='Cache.lbl_startdate' />"> <!-- 끝 날짜 -->
											</p>
										</div>
										<div>
											<p>
												<input type="radio" name="select_write_repeatmonth2" value="" id="schedule_write_repeatmonth_useenddate">
												<label for="schedule_write_repeatmonth_useenddate"></label>
												<input id="schedule_write_repeatmonth_enddate" type="text" name="" value="" class="dates_date input_date" placeholder="<spring:message code='Cache.lbl_EndDate2' />"> <!-- 끝 날짜 -->
											</p>
											<p>
												<input type="radio" name="select_write_repeatmonth2" value="" id="schedule_write_repeatmonth_userepeat">
												<label for="schedule_write_repeatmonth_userepeat"></label>
												<input id="schedule_write_repeatmonth_repeatcnt" type="text" name="" value="1" class="num"> <spring:message code='Cache.lbl_RepeatTimes' /> <!-- 회 반복 -->
											</p>
										</div>
									</li>
								</ul>
							</div>
							<div class="tab_cont">
								<ul>
									<li>
										<div class="full">
											<p>
												<spring:message code='Cache.lbl_Every' /> <input id="schedule_write_repeatyear_year" type="text" name="" value="1" class="num"> <spring:message code='Cache.lbl_yearEvery' /> <!-- 년 마다 -->
												<select  id="schedule_write_repeatyear_month"  class="" name="">
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
												<input type="radio" name="select_write_repeatyear1" id="schedule_write_repeatyear_useday">
												<label for="schedule_write_repeatyear_useday"></label>
												<input type="text" name="" value="1" id="schedule_write_repeatyear_day" class="num"> <spring:message code='Cache.lbl_day' /> <!-- 일 -->
											</p>
											<p>
												<input type="radio" name="select_write_repeatyear1" value="" id="schedule_write_repeatyear_usedayword">
												<label for="schedule_write_repeatyear_usedayword"></label>
												<select id="schedule_write_repeatyear_dayword1" class="" name="">
													<option value="1"><spring:message code='Cache.lbl_First' /></option> <!-- 첫째 -->
													<option value="2"><spring:message code='Cache.lbl_Second' /></option> <!-- 둘째 -->
													<option value="3"><spring:message code='Cache.lbl_Third' /></option> <!-- 셋째 -->
													<option value="4"><spring:message code='Cache.lbl_Forth' /></option> <!-- 넷째 -->
													<option value="5"><spring:message code='Cache.lbl_last' /></option> <!-- 마지막 -->
												</select>
												<select id="schedule_write_repeatyear_dayword2" class="" name="">
													<option value="DAY"><spring:message code='Cache.lbl_Day_1' /></option> <!-- 날 -->
													<option value="WEEKDAY"><spring:message code='Cache.lbl_Weekday' /></option> <!-- 평일 -->
													<option value="WEEKEND"><spring:message code='Cache.lbl_Weekend' /></option> <!-- 주말 -->
													<option value="SUN"><spring:message code='Cache.lbl_Sunday' /></option> <!-- 일요일 -->
													<option value="MON"><spring:message code='Cache.lbl_Monday' /></option> <!-- 월요일 -->
													<option value="TUE"><spring:message code='Cache.lbl_Tuesday' /></option> <!-- 화요일 -->
													<option value="WED"><spring:message code='Cache.lbl_Wednesday' /></option> <!-- 수요일 -->
													<option value="THU"><spring:message code='Cache.lbl_Thursday' /></option> <!-- 목요일 -->
													<option value="FRI"><spring:message code='Cache.lbl_Friday' /></option> <!-- 금요일 -->
													<option value="SAT"><spring:message code='Cache.lbl_Saturday' /></option> <!-- 토요일 -->
												</select>
											</p>
										</div>
									</li>
									<li>
										<div>
											<p><spring:message code='Cache.lbl_startdate' /></p>
											<p>
												<input id="schedule_write_repeatyear_startdate" type="text" name="" value="" class="dates_date input_date" placeholder="<spring:message code='Cache.lbl_startdate' />"> <!-- 끝 날짜 -->
											</p>
										</div>
										<div>
											<p>
												<input type="radio" name="select_write_repeatyear2" value="" id="schedule_write_repeatyear_useenddate">
												<label for="schedule_write_repeatyear_useenddate"></label>
												<input id="schedule_write_repeatyear_enddate" type="text" name="" value="" class="dates_date input_date" placeholder="<spring:message code='Cache.lbl_EndDate2' />"> <!-- 끝 날짜 -->
											</p>
											<p>
												<input type="radio" name="select_write_repeatyear2" value="" id="schedule_write_repeatyear_userepeat">
												<label for="schedule_write_repeatyear_userepeat"></label>
												<input id="schedule_write_repeatyear_repeatcnt" type="text" name="" value="1" class="num"><spring:message code='Cache.lbl_RepeatTimes' /> <!-- 회 반복 -->
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

