<%@page import="egovframework.coviframework.util.CommonUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
		 pageEncoding="UTF-8"%>
<%@ page import="egovframework.coviframework.util.RedisDataUtil"%>
<%@ page import="net.sf.json.*"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<style>
	<!--
	#content{height:100%}

	td input {width:80px}
	-->
	.inform {
		margin-top: 2px;
		color: #989898;
		font-size: 12px;
	}
</style>
<div class="cRConTop titType AtnTop ">
	<h2 class="title"><spring:message code='Cache.MN_891'/></h2>
</div>
<div class='cRContBottom ATMCont_wrap'>
	<form id="frm">
		<!-- 컨텐츠 시작 -->
		<div class="ATMCont">
			<!-- 회사설정 탭메뉴 시작 -->
			<div class="ATM_Config_wrap">
				<ul class="tabMenu clearFloat">
					<li class="topToggle active"><a href="#"  ><spring:message code='Cache.lbl_n_att_worksch'/></a></li>		<!-- 근무일정 -->
					<li class="topToggle"><a href="#"  ><spring:message code='Cache.lbl_n_att_history'/></a></li>	<!-- 근태기록 -->
					<li class="topToggle"><a href="#"  ><spring:message code='Cache.lbl_n_att_rewardVac'/></a></li>	<!-- 보상휴가-->
					<li class="topToggle"><a href="#"  ><spring:message code='Cache.lbl_n_att_restManage'/></a></li>	<!-- 휴게<spring:message code='Cache.lbl_Hours'/>관리 -->
					<li class="topToggle"><a href="#"  ><spring:message code='Cache.lbl_n_att_reqManage'/></a></li>	<!-- 요청관리-->
					<%-- <li class="topToggle"><a href="#"  ><spring:message code='Cache.lbl_n_att_viewOption'/></a></li> --%>	<!-- 보기옵션-->
					<li class="topToggle"><a href="#"  ><spring:message code='Cache.lbl_n_att_funcSetting'/></a></li>	<!-- 출퇴근 기능설정-->
					<li class="topToggle"><a href="#"  ><spring:message code='Cache.lbl_apv_attendance'/> <spring:message code='Cache.lbl_alarmSetting'/></a></li>	<!-- 근태 알림설정-->
					<li class="topToggle"><a href="#"  ><spring:message code='Cache.lbl_apv_attendance'/><spring:message code='Cache.BizSection_Portal'/> <spring:message code='Cache.btn_Preference'/></a></li>	<!-- 근태포탈 환경설정-->
				</ul>

				<div class="tabContent active">
					<div class="ATM_Config_Table_wrap">
						<p class="ATM_Config_Title"><spring:message code='Cache.lbl_n_att_worksch'/></p>
						<div class="ATM_Config_TW">
							<table class="ATM_Config_Table" cellpadding="0" cellspacing="0">
								<tbody>
								<tr>
									<td class="Config_TH"><p class="tx_TH"><spring:message code='Cache.lbl_n_att_extentionFunction'/></p></td>
									<td width="80"><div class="alarm type01"><a href="#" class="onOffBtn" id="SchConfmYn"><span></span></a></div></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_n_att_companySetting1'/></p>
										<p class="Config_sp"><spring:message code='Cache.msg_n_att_companySetting2'/></p>
									</td>
								</tr>
								<tr>
									<td class="Config_TH"><p class="tx_TH"><spring:message code='Cache.lbl_n_att_deemedWork'/></p></td>
									<td><div class="alarm type01"><a href="#" class="onOffBtn" id="AssYn"><span></span></a></div></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_n_att_companySetting3'/></p>
										<p class="Config_sp"><spring:message code='Cache.msg_n_att_companySetting4'/></p>
										<div class="Config_Table_wrap">
											<table class="Config_Table" cellpadding="0" cellspacing="0" id="assTb">
												<colgroup>
													<col width="40%">
													<col width="*">
													<col width="80px">
												</colgroup>
												<thead>
												<tr>
													<th><spring:message code='Cache.lbl_n_att_deemedWork'/> <spring:message code='Cache.lbl_type'/></th>
													<th><spring:message code='Cache.lbl_n_att_fixedWork'/> <spring:message code='Cache.lbl_att_sch_time'/></th>
													<th><a href="#" class="btnAdd" onclick="addRow('ass');"></a></th>
												</tr>
												</thead>
												<tbody>
												</tbody>
											</table>
										</div>
										<p class="Config_mp"><spring:message code='Cache.msg_n_att_companySetting5'/></p>
									</td>
								</tr>
								<tr>
									<td class="Config_TH"><p class="tx_TH"><spring:message code='Cache.lbl_n_att_outOfTownOffice'/></p></td>
									<td><div class="alarm type01"><a href="#" class="onOffBtn" id="OutsideYn"><span></span></a></div></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_n_att_companySetting6'/></p>
										<p class="Config_sp"><spring:message code='Cache.msg_n_att_companySetting7'/></p>
									</td>
								</tr>
								<tr>
									<td class="Config_TH"><p class="tx_TH"><spring:message code='Cache.lbl_n_att_customTempletUse'/></p></td>
									<td><div class="alarm type01"><a href="#" class="onOffBtn" id="CustomSchYn"><span></span></a></div></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_n_att_companySetting46'/></p>
										<p class="Config_sp"><spring:message code='Cache.msg_n_att_companySetting47'/></p>
									</td>
								</tr>
								</tbody>
							</table>
						</div>

						<div class="bottom">
							<a href="#" class="btnTypeDefault btnTypeBg createCSBtn"><spring:message code='Cache.lbl_Save'/></a>
						</div>
					</div>
				</div>
				<div class="tabContent">
					<div class="ATM_Config_Table_wrap">
						<p class="ATM_Config_Title"><spring:message code='Cache.lbl_n_att_history'/></p>
						<div class="ATM_Config_TW">
							<table class="ATM_Config_Table" cellpadding="0" cellspacing="0">
								<tbody>
								<tr style="display:none">
									<td class="Config_TH"><p class="tx_TH"><spring:message code='Cache.lbl_n_att_nonRegularWork'/></td>
									<td width="80">
										<div class="alarm type01"><a href="#" class="onOffBtn" id="NoSchYn"><span></span></a></div>
									</td>
									<td></td>
								</tr>
								<tr>
									<td class="Config_TH"><p class="tx_TH"><spring:message code='Cache.lbl_n_att_extentionFunction'/></p></td>
									<td width="80"><div class="alarm type01"><a href="#" class="onOffBtn" id="AttConfirmYn"><span></span></a></div></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_n_att_companySetting54'/></p>
										<p class="Config_sp"><spring:message code='Cache.msg_n_att_companySetting55'/></p>
									</td>
								</tr>
								<tr>
									<td class="Config_TH" rowspan=3><p class="tx_TH"><spring:message code='Cache.lbl_n_att_remainingWorkingHours'/></p></td>
									<td width="80">
										<div class="alarm type01"><a href="#" class="onOffBtn" name="RemainTimeCode" id="RemainTimeCode_40" ><span></span></a></div>
									</td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_n_att_companySetting8'/></p>
									</td>
								</tr>
								<tr>
									<td><div class="alarm type01">
										<a href="#" class="onOffBtn" name="RemainTimeCode"  id="RemainTimeCode_52" ><span></span></a></div>
									</td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_n_att_companySetting9'/></p>
									</td>
								</tr>
								<tr>
									<td><div class="alarm type01">
										<a href="#" class="onOffBtn" name="ExptVacTime"  id="ExptVacTime" ><span></span></a></div>
									</td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.mag_RemainingTimeRealWork'/></p> <!-- 잔여시간을 실근무(실근무=인정근무+연장근무+휴일근무-유급휴가)로 반영 -->
									</td>
								</tr>
								<tr>
									<td class="Config_TH" rowspan=5><p class="tx_TH"><spring:message code='Cache.lbl_n_att_commutingSuspended'/></p></td>
									<td><input type="text" style="width: 40px;" class='onlyNum' name="AttStartTimeTermMin" value=""/></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_n_att_companySetting10'/></p>
									</td>
								</tr>
								<tr>
									<td><input type="text" style="width: 40px;" class='onlyNum' name="AttStatusStartTimeTermMin" value=""/></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_n_att_companySetting50'/></p>
									</td>
								</tr>
								<tr>
									<td><input type="text" style="width: 40px;" class='onlyNum' name="AttEndTimeTermMin" value=""/></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_n_att_companySetting11'/></p>
									</td>
								</tr>
								<tr>
									<td><input type="text" style="width: 40px;" class='onlyNum' name="AttStatusEndTimeTermMin" value=""/></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_n_att_companySetting51'/></p>
									</td>
								</tr>
								<tr>
									<td><input type="text" style="width: 40px;" class='onlyNum' name="CommuteOutTerm" value=""/></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_n_att_companySetting43'/></p>
									</td>
								</tr>
								<tr>
									<td class="Config_TH"><p class="tx_TH"><spring:message code='Cache.lbl_n_att_lookupBaseDay'/></p></td>
									<td><select name="AttBaseWeek" style="min-width: 40px !important;">
										<option value="1"><spring:message code='Cache.lbl_WPSun' /></option>
										<option value="2"><spring:message code='Cache.lbl_WPMon' /></option>
										<option value="3"><spring:message code='Cache.lbl_WPTue' /></option>
										<option value="4"><spring:message code='Cache.lbl_WPWed' /></option>
										<option value="5"><spring:message code='Cache.lbl_WPThu' /></option>
										<option value="6"><spring:message code='Cache.lbl_WPFri' /></option>
										<option value="7"><spring:message code='Cache.lbl_WPSat' /></option>
									</select>
									</td>
									<td><spring:message code='Cache.mag_Attendance1'/></td> <!-- 주간 근태현황 차트 상에서 표기되는 시작 요일을 설정합니다. -->
								</tr>
								<tr>
									<td class="Config_TH"><p class="tx_TH"><spring:message code='Cache.lbl_n_att_realTimeMarkingSetting'/><br/>(<spring:message code='Cache.lbl_admin'/>)</p></td>
									<td><div class="alarm type01"><a href="#" class="onOffBtn" id="RealTimeYn"><span></span></a></div></td>
									<td><spring:message code='Cache.msg_n_att_companySetting42'/></td>
								</tr>
								<tr>
									<td class="Config_TH"><p class="tx_TH"><spring:message code='Cache.lbl_n_att_commuteTimeSet'/><br/>(<spring:message code='Cache.lbl_User'/>)</p></td> <!-- 사용자 -->
									<td><div class="alarm type01"><a href="#" class="onOffBtn" id="CommuteTimeYn"><span></span></a></div></td>
									<td><spring:message code='Cache.msg_n_att_companySetting44'/></td>
								</tr>
								<tr>
									<td class="Config_TH"><p class="tx_TH"><spring:message code='Cache.btn_SaveToExcel'/><br/>(<spring:message code='Cache.lbl_User'/>)</p></td> <!-- 사용자 -->
									<td><div class="alarm type01"><a href="#" class="onOffBtn" id="ExcelSaveYn"><span></span></a></div></td>
									<td><spring:message code='Cache.msg_n_att_companySetting52'/></td>
								</tr>
								<tr>
									<td class="Config_TH"><p class="tx_TH"><spring:message code='Cache.lbl_admin'/> <spring:message code='Cache.MN_754'/><br/><spring:message code='Cache.btn_SaveToExcel'/><br/>(<spring:message code='Cache.lbl_admin'/>)</p></td> <!-- 관리자 근태관리 엑셀저장(관리자)  -->
									<td><div class="alarm type01"><a href="#" class="onOffBtn" id="ExcelSaveYnAdmin"><span></span></a></div></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_n_att_companySetting53'/></p>
										<div class="Config_Chk_list_option chkStyle10">
											<input type="checkbox" class="check_class" name="ExcelDataMode" id="ExcelDataMode_1" value="A"><label for="ExcelDataMode_1"><span class="s_check"></span><spring:message code='Cache.lbl_n_att_acknowledgedWork'/></label> 
										</div>	
										<div class="Config_Chk_list_option chkStyle10">
											<input type="checkbox" class="check_class" name="ExcelDataMode" id="ExcelDataMode_2" value="E"><label for="ExcelDataMode_2"><span class="s_check"></span><spring:message code='Cache.lbl_n_att_AttRealTime'/></label> 
										</div>	
										<div class="Config_Chk_list_option chkStyle10">
											<input type="checkbox" class="check_class" name="ExcelDataMode" id="ExcelDataMode_3" value="R"><label for="ExcelDataMode_3"><span class="s_check"></span><spring:message code='Cache.lbl_entry_exit_records'/></label> 
										</div>	
									</td>
								</tr>
								<tr>
									<td class="Config_TH"><p class="tx_TH"><spring:message code='Cache.lbl_allGoWorkApplyTimeSetting'/></p></td> <!-- 일괄 출근 적용시간 설정 -->
									<td style="padding: 0; text-align: center;">
										<select id="selGoWorkApplyTime" name="AllGoWorkApplyTime"></select>
									</td>
									<td>
										<div><spring:message code='Cache.msg_changeWorkStatusToNormalWork'/></div>
										<div class="inform">(<spring:message code='Cache.msg_goWorkTimeInform'/>)</div>
									</td>
								</tr>
								<tr>
									<td class="Config_TH"><p class="tx_TH"><spring:message code='Cache.lbl_allOffWorkApplyTimeSetting'/></p></td> <!-- 일괄 퇴근 적용시간 설정 -->
									<td style="padding: 0; text-align: center;">
										<select id="selOffWorkApplyTime" name="AllOffWorkApplyTime"></select>
									</td>
									<td>
										<div><spring:message code='Cache.msg_changeWorkStatusToNormalOffWork'/></div>
										<div class="inform">(<spring:message code='Cache.msg_offWorkTimeInform'/>)</div>
									</td>
								</tr>
								</tbody>
							</table>
						</div>
						<div class="bottom">
							<a href="#" class="btnTypeDefault btnTypeBg createCSBtn"><spring:message code='Cache.lbl_Save'/></a>
						</div>
					</div>
				</div>
				<div class="tabContent">
					<div class="ATM_Config_Table_wrap">
						<p class="ATM_Config_Title"><spring:message code='Cache.lbl_n_att_rewardVac'/></p>
						<div class="ATM_Config_TW">
							<table class="ATM_Config_Table" cellpadding="0" cellspacing="0">
								<tbody>
								<tr>
									<td class="Config_TH"><p class="tx_TH"><spring:message code='Cache.lbl_n_att_compensatoryVacFunc'/></p></td>
									<td width="80"><div class="alarm type01"><a href="#" class="onOffBtn" id="RewardYn"><span></span></a></div></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_n_att_companySetting12'/></p>
										<p class="Config_sp">(<spring:message code='Cache.msg_n_att_companySetting13'/>)</p>
										<p class="Config_sp">(<spring:message code='Cache.mag_Attendance2'/>)</p> <!-- 보상 시간은  근로시간의 배수로 설정합니다. 예: 근로시간의 1.5배를  보상으로 주실거면 1.5 -->
										<div class="Config_Chk_list_option">
											<p class="Config_Chk_p"><label><spring:message code='Cache.msg_n_att_companySetting14'/></label></p>
											<table class="Config_Table" cellpadding="0" cellspacing="0" id="rewardTb">
												<colgroup>
													<col width="40%">
													<col width="*">
													<col width="80px">
												</colgroup>
												<thead>
												<tr>
													<th width="40%"><spring:message code='Cache.lbl_n_att_overTimeHour'/></th>
													<th width="*"><spring:message code='Cache.lbl_n_att_compWorkingHours'/></th>
													<th width="10%"><a href="#" class="btnAdd" onclick="addRow('reward');"></a></th>
												</tr>
												</thead>
												<tbody></tbody>
											</table>
										</div>
										<div class="Config_Chk_list_option">
											<p class="Config_Chk_p"><label><spring:message code='Cache.lbl_n_att_calculationHoliday'/></label></p>
											<table class="Config_Table" cellpadding="0" cellspacing="0" id="rewardHoliTb">
												<colgroup>
													<col width="40%">
													<col width="*">
													<col width="80px">
												</colgroup>
												<thead>
												<tr>
													<th><spring:message code='Cache.lbl_n_att_overTimeHour'/></th>
													<th><spring:message code='Cache.lbl_n_att_compWorkingHours'/></th>
													<th><a href="#" class="btnAdd" onclick="addRow('rewardHoli');"></a></th>
												</tr>
												</thead>
												<tbody></tbody>
											</table>
										</div>
										<div class="Config_Chk_list_option">
											<p class="Config_Chk_p"><label><spring:message code='Cache.lbl_n_att_calculationOff'/></label></p>
											<table class="Config_Table" cellpadding="0" cellspacing="0" id="rewardOffTb">
												<colgroup>
													<col width="40%">
													<col width="*">
													<col width="80px">
												</colgroup>
												<thead>
												<tr>
													<th><spring:message code='Cache.lbl_n_att_overTimeHour'/></th>
													<th><spring:message code='Cache.lbl_n_att_compWorkingHours'/></th>
													<th><a href="#" class="btnAdd" onclick="addRow('rewardOff');"></a></th>
												</tr>
												</thead>
												<tbody></tbody>
											</table>
										</div>

									</td>
								</tr>
								<tr style="display:none">
									<td class="Config_TH" rowspan="2"><p class="tx_TH"><spring:message code='Cache.lbl_n_att_compensationHoliBase'/></p></td>
									<td>
										<div class="Config_SelDay_wrap">
											<select name="RewardStandardDay">
													<option value='1'>1</option>
											</select>
										</div>
									</td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_n_att_companySetting15'/></p>
									</td>
								</tr>
								<tr style="display:none">
									<td>
										<div class="Config_SelDay_wrap">
											<select name="RewardPeriod" class="RewardPeriod">
													<option value='1month'>한달</option>
											</select>
										</div>
									</td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_n_att_companySetting16'/></p>
									</td>
								</tr>
								</tbody>
							</table>
						</div>
						<div class="bottom">
							<a href="#" class="btnTypeDefault btnTypeBg createCSBtn"><spring:message code='Cache.lbl_Save'/></a>
						</div>
					</div>
				</div>
				<div class="tabContent">
					<div class="ATM_Config_Table_wrap">
						<p class="ATM_Config_Title"><spring:message code='Cache.lbl_n_att_restManage'/></p>
						<div class="ATM_Config_TW">
							<table class="ATM_Config_Table" cellpadding="0" cellspacing="0">
								<tbody>
								<tr>
									<td class="Config_TH"><p class="tx_TH"><spring:message code='Cache.lbl_n_att_automaticBreakTime'/></p></td>
									<td width="120" style="text-align: center;"><div class="alarm type01"><a href="#" class="onOffBtn" id="RestYn"><span></span></a></div></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_n_att_companySetting17'/></p>
										<div class="Config_Chk_list_option">
											<table class="Config_Table" cellpadding="0" cellspacing="0" id="restTb">
												<colgroup>
													<col width="40%">
													<col width="*">
													<col width="80px">
												</colgroup>
												<thead>
												<tr>
													<th><spring:message code='Cache.lbl_n_att_totWorkTime'/></th>
													<th><spring:message code='Cache.lbl_n_att_resttime'/></th>
													<th><a href="#" class="btnAdd" onclick="addRow('rest');"></a></th>
												</tr>
												</thead>
												<tbody></tbody>
											</table>
										</div>
										<p class="Config_mp"><spring:message code='Cache.msg_n_att_companySetting18'/></p>
										<p class="Config_sp"><spring:message code='Cache.msg_n_att_companySetting19'/></p>
										<p class="Config_mp"><spring:message code='Cache.msg_n_att_companySetting20'/></p>
									</td>
								</tr>
								<tr style="display:none">
									<td class="Config_TH">1111<p class="tx_TH"><spring:message code='Cache.lbl_n_att_manualBreakTime' /></p></td>
									<td><div class="alarm type01"><a href="#" class="onOffBtn" id="RestBtnYn"><span></span></a></div></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_n_att_companySetting21'/></p>
										<p class="Config_sp"><spring:message code='Cache.msg_n_att_companySetting22'/></p>
									</td>
								</tr>
								<tr>
									<td class="Config_TH" rowspan=4><p class="tx_TH"><spring:message code='Cache.lbl_SettingOvertime' /></p></td> <!-- 연장/휴일근무시간설정 -->
									<td style="text-align: center;"><div class="alarm type01"><a href="#" class="onOffBtn" id="ExtenStartEndTimeBtnYn"><span></span></a></div></td>
									<td><p class="Config_mp"><spring:message code='Cache.mag_Attendance3' /></p> <!-- 연장/휴일신청 가능시간을 설정합니다. -->
										<div class="Config_Chk_list_option">
											<select name="ExtenStartTimeHour">
												<c:forEach begin="00" end="23" var="hour">
													<option value="${ hour < 10 ? '0' : '' }${hour}">${ hour < 10 ? '0' : '' }${hour}</option>
												</c:forEach>
											</select>
											<select name="ExtenStartTimeMin">
												<c:forEach begin="00" end="59" var="min">
													<option value="${ min < 10 ? '0' : '' }${min}">${ min < 10 ? '0' : '' }${min}</option>
												</c:forEach>
											</select>
											~
											<select name="ExtenEndTimeHour">
												<c:forEach begin="00" end="23" var="hour">
													<option value="${ hour < 10 ? '0' : '' }${hour}">${ hour < 10 ? '0' : '' }${hour}</option>
												</c:forEach>
											</select>
											<select name="ExtenEndTimeMin">
												<c:forEach begin="00" end="59" var="min">
													<option value="${ min < 10 ? '0' : '' }${min}">${ min < 10 ? '0' : '' }${min}</option>
												</c:forEach>
											</select>
										</div>
									</td>
								</tr>
								<tr>
									<td style="text-align: center;"><select name="ExtenUnit">
										<option value="0"><spring:message code='Cache.lbl_NotApplicable' /></option> <!-- 해당없음 -->
										<option value="10">10<spring:message code='Cache.lbl_Minutes' /></option> <!-- 분 -->
										<option value="15">15<spring:message code='Cache.lbl_Minutes' /></option> <!-- 분 -->
										<option value="30">30<spring:message code='Cache.lbl_Minutes' /></option> <!-- 분 -->
									</select>
									</td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.mag_Attendance4' /></p> <!-- 신청시간 단위 분 단위 선택 -->
									</td>
								</tr>
								<tr>
									<td style="text-align: center;"><div class="alarm type01"><a href="#" class="onOffBtn" id="ExtenRestYn"><span></span></a></div></td>
									<td><p class="Config_mp"><spring:message code='Cache.mag_Attendance5' /></p> <!-- 연장근무시 근무시간에 따라 휴게시간 자동 추가 기능을 사용합니다. -->
										<div class="Config_Chk_list_option">
											<table class="Config_Table" cellpadding="0" cellspacing="0" id="restTb">
												<colgroup>
													<col width="50%">
													<col width="*">
												</colgroup>
												<thead>
												<tr>
													<th><spring:message code='Cache.lbl_n_att_totWorkTime'/></th>
													<th><spring:message code='Cache.lbl_n_att_resttime'/></th>
												</tr>
												</thead>
												<tbody>
												<tr>
													<td><input type="text" class="onlyNum" value="" name="ExtenWorkTime"><label><spring:message code='Cache.lbl_WorkMinute'/></label></td> <!-- 분 근무시 -->
													<td><input type="text" class="onlyNum" name="ExtenRestTime" value=""><label><spring:message code='Cache.lbl_MinuteBreak'/></label></td> <!-- 분 휴게 추가 -->
												</tr>
												</tbody>
											</table>
										</div>
									</td>
								</tr>
								<tr>
									<td style="text-align: center;"><div class="alarm type01"><a href="#" class="onOffBtn" id="HoliRestYn"><span></span></a></div></td>
									<td><p class="Config_mp"><spring:message code='Cache.mag_Attendance87' /></p> <!-- 휴일근무시 근무시간에 따라 휴게시간 자동 추가 기능을 사용합니다. -->
										<div class="Config_Chk_list_option">
											<table class="Config_Table" cellpadding="0" cellspacing="0" id="restTb">
												<colgroup>
													<col width="50%">
													<col width="*">
												</colgroup>
												<thead>
												<tr>
													<th><spring:message code='Cache.lbl_n_att_totWorkTime'/></th>
													<th><spring:message code='Cache.lbl_n_att_resttime'/></th>
												</tr>
												</thead>
												<tbody>
												<tr>
													<td><input type="text" class="onlyNum" value="" name="HoliWorkTime"><label><spring:message code='Cache.lbl_WorkMinute'/></label></td> <!-- 분 근무시 -->
													<td><input type="text" class="onlyNum" name="HoliRestTime" value=""><label><spring:message code='Cache.lbl_MinuteBreak'/></label></td> <!-- 분 휴게 추가 -->
												</tr>
												</tbody>
											</table>
										</div>
									</td>
								</tr>
								<tr>
									<td class="Config_TH" rowspan=3><p class="tx_TH"><spring:message code='Cache.lbl_SettingWorkHoliday'/></p></td> <!-- 휴일근무시간설정 -->
									<td style="text-align: center;"><input type="text" class="onlydecimal" value="" name="ExtenMaxTime" style="width:40px"><label><spring:message code='Cache.lbl_Hours'/></label></td> <!-- 시간 -->
									<td><p class="Config_mp"><spring:message code='Cache.lbl_OneDay'/> <spring:message code='Cache.lbl_MaxWorkTime'/>(<spring:message code='Cache.lbl_Hours'/>)</p></td> <!-- 하루 최대 근무가능시간(시간) -->
								</tr>
								<tr>
									<td style="text-align: center;"><input type="text" class="onlydecimal" value="" name="ExtenMaxWeekTime" style="width:40px"><label><spring:message code='Cache.lbl_Hours'/></label></td> <!-- 시간 -->
									<td><p class="Config_mp"><spring:message code='Cache.CPMail_1Week'/> <spring:message code='Cache.lbl_MaxWorkTime'/>(<spring:message code='Cache.lbl_Hours'/>)</p></td> <!-- 1주 최대 근무가능시간(시간) -->
								</tr>
								<!--
									<td>
										<p class="Config_mp"></p>
										<div class="Config_Chk_list_option">
											<table class="Config_Table" cellpadding="0" cellspacing="0">
												<colgroup>
												        <col width="40%">
												        <col width="*">
												        <col width="10%">
												</colgroup>
												<thead>
												</thead>
												<tr>
													<th>신청시간단위(분)</th>
													<td>
														<select name="ExtenUnit">
															<option value="0">해당없음</option>
															<option value="10">10분</option>
															<option value="15">15분</option>
															<option value="30">30분</option>
														</select></td>
												</tr>
												<tr>
													<th>휴게시간자동설정<div class="alarm type01"><a href="#" class="onOffBtn" id="ExtenRestYn"><span></span></a></div></th>
													<td><input type="text" class="onlyNum" value="" name="ExtenWorkTime"><label>분 근무시</label> <input type="text" class="onlyNum" name="ExtenRestTime" value=""><label>분 휴게 추가</label></td>
												</tr>
												<tr>
													<th>근무가능시간</th>
													<td><select name="ExtenStartTimeHour">
															<c:forEach begin="00" end="23" var="hour">
															<option value="${ hour < 10 ? '0' : '' }${hour}">${hour}</option>
															</c:forEach>
														</select>
														<select name="ExtenStartTimeMin">
															<c:forEach begin="00" end="59" var="min">
															<option value="${ min < 10 ? '0' : '' }${min}">${min}</option>
															</c:forEach>
														</select>
														~
														<select name="ExtenEndTimeHour">
															<c:forEach begin="00" end="23" var="hour">
															<option value="${ hour < 10 ? '0' : '' }${hour}">${hour}</option>
															</c:forEach>
														</select>
														<select name="ExtenEndTimeMin">
															<c:forEach begin="00" end="59" var="min">
															<option value="${ min < 10 ? '0' : '' }${min}">${min}</option>
															</c:forEach>
														</select>
													</td>
												</tr>
											</table>
										</div>
									</td>
								</tr>-->
								</tbody>
							</table>
						</div>
						<div class="bottom">
							<a href="#" class="btnTypeDefault btnTypeBg createCSBtn"><spring:message code='Cache.lbl_Save'/></a>
						</div>
					</div>
				</div>
				<div class="tabContent">
					<div class="ATM_Config_Table_wrap">
						<p class="ATM_Config_Title"><spring:message code='Cache.lbl_n_att_reqManage'/></p>
						<div class="ATM_Config_TW">
							<table class="ATM_Config_Table" cellpadding="0" cellspacing="0">
								<tbody>
								<tr>
									<td class="Config_TH"><p class="tx_TH"><spring:message code='Cache.lbl_n_att_coreTime'/></p></td>
									<td width="120" style="text-align: center;"><div class="alarm type01"><a href="#" class="onOffBtn" id="CoreTimeYn"><span></span></a></div></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_n_att_companySetting23'/></p>
										<p class="Config_sp"><spring:message code='Cache.msg_n_att_companySetting24'/></p>
										<p class="Config_mp mt5">
											<select name="CoreStartTimeHour">
												<c:forEach begin="00" end="23" var="hour">
													<option value="${ hour < 10 ? '0' : '' }${hour}">${hour}</option>
												</c:forEach>
											</select>
											<select name="CoreStartTimeMin">
												<c:forEach begin="00" end="59" var="min">
													<option value="${ min < 10 ? '0' : '' }${min}">${min}</option>
												</c:forEach>
											</select>
											~
											<select name="CoreEndTimeHour">
												<c:forEach begin="00" end="23" var="hour">
													<option value="${ hour < 10 ? '0' : '' }${hour}">${hour}</option>
												</c:forEach>
											</select>
											<select name="CoreEndTimeMin">
												<c:forEach begin="00" end="59" var="min">
													<option value="${ min < 10 ? '0' : '' }${min}">${min}</option>
												</c:forEach>
											</select>
										</p>
										<!-- <p class="Config_Chk_p"><label><input type="checkbox">평일 연장근무 보상휴가 산정</label></p> -->
									</td>
								</tr>

								<tr>
									<td class="Config_TH"><p class="tx_TH"><spring:message code='Cache.lbl_n_att_reqToAttend'/></p></td>
									<td style="text-align: center;"><div class="alarm type01"><select class="reqAttMethod" name="AttReqMethod"></select></div></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_n_att_companySetting25'/></p>
										<p class="Config_sp"><spring:message code='Cache.msg_n_att_companySetting26'/></p>
										<!-- <p class="Config_Chk_p"><label><input type="checkbox">승인이 항상 필요합니다.</label></p> -->
									</td>
								</tr>
								<tr>
									<td class="Config_TH"><p class="tx_TH"><spring:message code='Cache.lbl_n_att_reqToLeave'/></p></td>
									<td style="text-align: center;"><div class="alarm type01"><select class="reqAttMethod" name="LeaveReqMethod"></select></div></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_n_att_companySetting27'/></p>
										<p class="Config_sp"><spring:message code='Cache.msg_n_att_companySetting28'/></p>
										<!-- <p class="Config_Chk_p"><label><input type="checkbox">승인이 항상 필요합니다.</label></p> -->
									</td>
								</tr>

								<tr>
									<td class="Config_TH"><p class="tx_TH"><spring:message code='Cache.lbl_n_att_reqToCreWorkSch'/></p></td>
									<td style="text-align: center;"><div class="alarm type01"><select class="reqMethod" name="WorkReqMethod"></select></div></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_n_att_companySetting29'/></p>
									</td>
								</tr>
								<tr style="display:none">
									<td style="text-align: center;"><div class="alarm type01"><select class="reqMethod" name="WorkUpdMethod"></select></div></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_n_att_companySetting30'/></p>
									</td>
								</tr>
								<tr style="display:none">
									<td style="text-align: center;"><div class="alarm type01"><select class="reqMethod" name="WorkDelMethod"></select></div></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_n_att_companySetting31'/></p>
									</td>
								</tr>
								<tr>
									<td class="Config_TH"><p class="tx_TH"><spring:message code='Cache.lbl_n_att_reqToRevicseCommute'/></br>(<spring:message code='Cache.lbl_app_approval_call'/>)</p></td>
									<td style="text-align: center;"><div class="alarm type01"><select class="reqMethod" name="CommuModReqMethod"></select></div></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_n_att_companySetting32'/></p>
										<p class="Config_sp"><spring:message code='Cache.msg_n_att_companySetting33'/></p>
										<!-- <p class="Config_Chk_p"><label><input type="checkbox">전자결재를 연동합니다.</label></p> -->
									</td>
								</tr>
								<!-- <tr>
									<td class="Config_TH" rowspan="3"><p class="tx_TH">기타근무 요청</p></td>
									<td><div class="alarm type01"><select class="reqMethod" name="OutReqMethod"></select></div></td>
									<td>
										<p class="Config_mp">기타근무 요청 기능을 사용합니다.</p>
									</td>
								</tr>
								<tr>
									<td><div class="alarm type01"><select class="reqMethod" name="OutUpdMethod"></select></div></td>
									<td>
										<p class="Config_mp">기타근무 수정 요청 기능을 사용합니다.</p>
									</td>
								</tr>
								<tr>
									<td><div class="alarm type01"><select class="reqMethod" name="OutDelMethod"></select></div></td>
									<td>
										<p class="Config_mp">기타근무 <spring:message code='Cache.lbl_delete'/> 요청 기능을 사용합니다.</p>
									</td>
								</tr> -->

								<tr>
									<td class="Config_TH"><p class="tx_TH"><spring:message code='Cache.lbl_n_att_reqToOverTime'/></p></td>
									<td style="text-align: center;"><div class="alarm type01"><select class="reqMethod" name="ExtenReqMethod"></select></div></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_n_att_companySetting34'/></p>
									</td>
								</tr>
								<tr style="display:none">
									<td style="text-align: center;"><div class="alarm type01"><select class="reqMethod" name="ExtenUpdMethod"></select></div></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_n_att_companySetting35'/></p>
									</td>
								</tr>
								<tr style="display:none">
									<td style="text-align: center;"><div class="alarm type01"><select class="reqMethod" name="ExtenDelMethod"></select></div></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_n_att_companySetting36'/></p>
									</td>
								</tr>

								<tr>
									<td class="Config_TH"><p class="tx_TH"><spring:message code='Cache.lbl_n_att_reqToHolytime'/></p></td>
									<td style="text-align: center;"><div class="alarm type01"><select class="reqMethod" name="HoliReqMethod"></select></div></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_n_att_companySetting37'/></p>
									</td>
								</tr>
								<tr style="display:none">
									<td style="text-align: center;"><div class="alarm type01"><select class="reqMethod" name="HoliUpdMethod"></select></div></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_n_att_companySetting38'/></p>
									</td>
								</tr>
								<tr style="display:none">
									<td style="text-align: center;"><div class="alarm type01"><select class="reqMethod" name="HoliDelMethod"></select></div></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_n_att_companySetting39'/></p>
									</td>
								</tr>
								<tr>
									<td class="Config_TH"><p class="tx_TH"><spring:message code='Cache.lbl_n_att_reqToVac'/></p></td>
									<td style="text-align: center;"><div class="alarm type01"><select class="reqMethod" name="VacReqMethod"></select></div></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_n_att_companySetting40'/></p>
									</td>
								</tr>
								<tr style="display:none">
									<td style="text-align: center;"><div class="alarm type01"><select class="reqMethod" name="VacDelMethod"></select></div></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_n_att_companySetting41'/></p>
									</td>
								</tr>
								<tr>
									<td class="Config_TH"><p class="tx_TH"><spring:message code='Cache.lbl_n_att_reqToHoliReplWork'/></p></td>
									<td style="text-align: center;"><div class="alarm type01"><select name="HoliReplReqMethod"></select></div></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_n_att_companySetting45'/></p>
									</td>
								</tr>
								<tr>
									<td class="Config_TH"><p class="tx_TH"><spring:message code='Cache.lbl_att_overtime'/>/<spring:message code='Cache.lbl_att_sch_holiday'/> <spring:message code='Cache.lbl_att_work'/><br /><spring:message code='Cache.lbl_RecognitionTime'/></p></td> <!-- 연장/휴일 근무<br />시간인정 -->
									<td style="text-align: center;"><div class="alarm type01"><select name="ExtenHoliTimeMethod"></select></div></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.mag_Attendance6'/></p> <!-- 연장/휴일근무시간 미도달시 실제 퇴근시간까지만 인정합니다. -->
									</td>
								</tr>
								</tbody>
							</table>
						</div>
						<div class="bottom">
							<a href="#" class="btnTypeDefault btnTypeBg createCSBtn"><spring:message code='Cache.lbl_Save'/></a>
						</div>
					</div>
				</div>

				<div class="tabContent">
					<div class="ATM_Config_Table_wrap">
						<p class="ATM_Config_Title"><spring:message code='Cache.lbl_n_att_commutingFuncSet'/></p>
						<div class="ATM_Config_TW">
							<table class="ATM_Config_Table" cellpadding="0" cellspacing="0">
								<tbody>
								<tr>
									<td class="Config_TH" rowspan="3"><p class="tx_TH"><spring:message code='Cache.lbl_n_att_deviceSetting'/></p></td>
									<td width="80"><div class="alarm type01"><a href="#" class="onOffBtn" id="PcUseYn"><span></span></a></div></td>
									<td>
										<p class="Config_mp">PC <spring:message code='Cache.lbl_Use'/></p>
									</td>
								</tr>
								<tr>
									<td><div class="alarm type01"><a href="#" class="onOffBtn" id="MobileUseYn"><span></span></a></div></td>
									<td>
										<p class="Config_mp">Mobile <spring:message code='Cache.lbl_Use'/></p>
									</td>
								</tr>
								<tr>
									<td><div class="alarm type01"><a href="#" class="onOffBtn" id="OthYn"><span></span></a></div></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.lbl_att_806_s_3_h'/></p>
									</td>
								</tr>
								<tr>
									<td class="Config_TH"><p class="tx_TH"><spring:message code='Cache.lbl_att_806_h_2'/></p></td>
									<td><div class="alarm type01"><a href="#" class="onOffBtn" id="IpYn"><span></span></a></div></td>
									<td>
										<div class="Config_Table_Add">
											<div class="Config_Table_btn">
												<a href="#" class="btnCfgPlus" onclick="addRow('ip');"><spring:message code='Cache.btn_att_806_s_3'/></a>
											</div>
											<table class="Config_Table mw100" id="ipTb" cellpadding="0" cellspacing="0">
												<colgroup>
													<col width="16%">
													<col width="16%">
													<col width="16%">
													<col width="*">
													<col width="16%">
													<col width="16%">
												</colgroup>
												<thead>
												<tr>
													<!-- <th>사용여부</th> -->
													<th><spring:message code='Cache.lbl_att_806_s_4_h'/></th>
													<th><spring:message code='Cache.lbl_att_806_s_4_h'/></th>
													<th>PC <spring:message code='Cache.lbl_Use'/></th>
													<th>Mobile <spring:message code='Cache.lbl_Use'/></th>
													<th><spring:message code='Cache.lbl_Remark'/></th>
													<th></th>
												</tr>
												</thead>
												<tbody></tbody>
											</table>
										</div>
									</td>
								</tr>
								</tbody>
							</table>
						</div>
						<div class="bottom">
							<a href="#" class="btnTypeDefault btnTypeBg createCSBtn"><spring:message code='Cache.lbl_Save'/></a>
						</div>
					</div>
				</div>

				<div class="tabContent">
					<div class="ATM_Config_Table_wrap">
						<p class="ATM_Config_Title"><spring:message code='Cache.lbl_apv_attendance'/> <spring:message code='Cache.lbl_alarmSetting'/></p>
						<div class="ATM_Config_TW">
							<table class="ATM_Config_Table" cellpadding="0" cellspacing="0">
								<tr>
									<td class="Config_TH" rowspan=2><p class="tx_TH"><spring:message code='Cache.lbl_n_att_worksch'/> <spring:message code='Cache.lbl_Alram'/></p></td> <!-- 근무일정 알림 -->
									<td style="width: 170px;text-align: center;">
										<p class="Config_mp"><spring:message code='Cache.lbl_n_att_worksch'/> <spring:message code='Cache.lbl_Start'/> <spring:message code='Cache.lbl_Alram'/></p> <!-- 근무일정 시작 알림 -->
										<div class="alarm type01"><a href="#" class="onOffBtn" id="AlarmAttStartNoticeToUserYn"><span></span></a></div>
									</td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.mag_Attendance7'/></p> <!-- 근무일정 시작 알림 사용합니다. -->
										<p class="Config_sp">(<spring:message code='Cache.mag_Attendance8'/>)</p> <!-- 직원이 본인 근무일정 시작이 임박하면 알람을 받습니다 -->
										<select name="AlarmAttStartNoticeMin" style="width: 70px;">
											<option value="5"><spring:message code='Cache.lbl_AlramTime_5'/></option> <!-- 5분전 -->
											<option value="10"><spring:message code='Cache.lbl_AlramTime_10'/></option> <!-- 10분전 -->
											<option value="15"><spring:message code='Cache.lbl_AlramTime_15'/></option> <!-- 15분전 -->
											<option value="20"><spring:message code='Cache.lbl_AlramTime_20'/></option> <!-- 20분전 -->
											<option value="30"><spring:message code='Cache.lbl_AlramTime_30'/></option> <!-- 30분전 -->
										</select>
									</td>
								</tr>
								<tr>
									<td style="text-align: center;">
										<p class="Config_mp"><spring:message code='Cache.lbl_n_att_worksch'/> <spring:message code='Cache.lbl_Exit'/> <spring:message code='Cache.lbl_Alram'/></p> <!-- 근무일정 종료 알림 -->
										<div class="alarm type01"><a href="#" class="onOffBtn" id="AlarmAttEndNoticeToUserYn"><span></span></a></div>
									</td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.mag_Attendance9'/></p> <!-- 근무일정 종료 알림 사용합니다. -->
										<p class="Config_sp">(<spring:message code='Cache.mag_Attendance10'/>)</p> <!-- 직원이 본인 근무일정 종료가 임박하면 알람을 받습니다 -->
										<select name="AlarmAttEndNoticeMin" style="width: 70px;">
											<option value="5"><spring:message code='Cache.lbl_AlramTime_5'/></option> <!-- 5분전 -->
											<option value="10"><spring:message code='Cache.lbl_AlramTime_10'/></option> <!-- 10분전 -->
											<option value="15"><spring:message code='Cache.lbl_AlramTime_15'/></option> <!-- 15분전 -->
											<option value="20"><spring:message code='Cache.lbl_AlramTime_20'/></option> <!-- 20분전 -->
											<option value="30"><spring:message code='Cache.lbl_AlramTime_30'/></option> <!-- 30분전 -->
										</select>
									</td>
								</tr>

								<tr>
									<td class="Config_TH"><p class="tx_TH"><spring:message code='Cache.lbl_att_beginLate'/> <spring:message code='Cache.lbl_Alram'/></p></td> <!-- 지각 알림 -->
									<td style="text-align: center;"><div class="alarm type01"><a href="#" class="onOffBtn" id="AlarmAttLateToAdminUserYn"><span></span></a></div></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.mag_Attendance11'/></p> <!-- 지각 알림 기능을 사용합니다. -->
										<p class="Config_sp">(<spring:message code='Cache.mag_Attendance12'/>)</p> <!-- 직원이 본인 근무일정보다 출근이 늦었을 때 알림을 받습니다. 관리자도 함께 알림을 받습니다. -->
									</td>
								</tr>

								<tr>
									<td class="Config_TH"><p class="tx_TH"><spring:message code='Cache.lbl_OverWork'/> <spring:message code='Cache.lbl_Alram'/></p></td> <!-- 초과근무 알림 -->
									<td style="text-align: center;"><div class="alarm type01"><a href="#" class="onOffBtn" id="AlarmAttOvertimeToAdminUserYn"><span></span></a></div></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.lbl_OverWork'/> <spring:message code='Cache.lbl_Alram'/> <spring:message code='Cache.mag_UseFunction'/></p> <!-- 초과근무 알림 기능을 사용합니다. -->
										<p class="Config_sp">(<spring:message code='Cache.mag_Attendance13'/>)</p> <!-- 원이 본인 근무일정보다 퇴근이 늦었을 때 알림을 받습니다. 관리자도 함께 알림을 받습니다. -->
									</td>
								</tr>
								</tbody>
							</table>
						</div>
						<div class="bottom">
							<a href="#" class="btnTypeDefault btnTypeBg createCSBtn"><spring:message code='Cache.lbl_Save'/></a>
						</div>
					</div>
				</div>

				<div class="tabContent" data-add="editor">
					<div class="ATM_Config_Table_wrap">
						<p class="ATM_Config_Title"><spring:message code='Cache.lbl_apv_attendance'/><spring:message code='Cache.BizSection_Portal'/> <spring:message code='Cache.btn_Preference'/></p>
						<div class="ATM_Config_TW">
							<table class="ATM_Config_Table" cellpadding="0" cellspacing="0">

								<tr>
									<td class="Config_TH"><p class="tx_TH"><spring:message code='Cache.CPMail_Daily' /> <spring:message code='Cache.lbl_att_goWork' /> <spring:message code='Cache.lbl_CurrentSituation' /></p></td> <!-- 지각 알림 -->
									<td style="width: 400px; text-align: center;">
										<div class="alarm type01">
											<div id="divAttPortalDailyJobTitle" style="text-align: left; margin-left: 20px;"></div>
										</div>
									</td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.mag_Attendance83'/></p>
										<p class="Config_sp"><spring:message code='Cache.mag_Attendance85'/></p>
									</td>
								</tr>
								<tr>
									<td class="Config_TH" rowspan=2><p class="tx_TH"><spring:message code='Cache.lbl_commuteMiss'/></p></td> <!-- 지각 알림 -->
									<td style="text-align: center;">
										<div class="alarm type01">
											<div id="divAttendanceGMJobTiltle" style="text-align: left; margin-left: 20px;"></div>
										</div>
									</td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.mag_Attendance84'/></p>
										<p class="Config_sp"><spring:message code='Cache.mag_Attendance85'/></p>
									</td>
								</tr>
								<tr>
									<td colspan=2>
										<table class="Config_Table" cellpadding="0" cellspacing="0" style="max-width: 100% !important;width: 100%;padding-top: 10px;">
												<colgroup>
													<col style="width: 10%;"/>
													<col style="width: 40%;"/>
													<col style="width: 50%;"/>
												</colgroup>
												<tbody>
												<tr>
													<th><spring:message code='Cache.CPMail_NotificationTarget' /></th>	<!-- 발송대상 -->
													<td>
														<div class="chkStyle10">
															<input type="checkbox" class="check_class" id="LateSendYn" value="Y"><label for="LateSendYn"><span class="s_check"></span><spring:message code='Cache.lbl_att_beginLate'/></label> 
														</div>	
														<div class="chkStyle10">
															<input type="checkbox" class="check_class" id="AbsentSendYn" value="Y"><label for="AbsentSendYn"><span class="s_check"></span><spring:message code='Cache.lbl_n_att_absent'/></label> 
														</div>	
														<div class="chkStyle10">
															<input type="checkbox" class="check_class" id="EarlySendYn" value="Y"><label for="EarlySendYn"><span class="s_check"></span><spring:message code='Cache.lbl_att_leaveErly'/></label> 
														</div>	
														<div class="chkStyle10">
															<input type="checkbox" class="check_class" id="CallingSendYn" value="Y"><label for="CallingSendYn"><span class="s_check"></span><spring:message code='Cache.lbl_n_att_callingTarget'/></label> 
														</div>
													</td>
													<td><p class="Config_mp"><spring:message code='Cache.mag_Attendance86'/></p></td>
												</tr>
												<tr>
													<th><spring:message code='Cache.lbl_Title' /></th>	<!-- 제목 -->
													<td colspan="2">
														<input type="text" name="MailTitle" id="MailTitle" maxlength="128" style="width: 100%;" title="#UR_Name"/>
													</td>
												</tr>
												<tr>
													<th><spring:message code='Cache.lbl_Contents' /></th>	<!-- 생성방법 -->
													<td colspan="2">
														<div id="divMailEditForm" class="writeEdit"></div>
													</td>
												</tr>
												</tbody>
											</table>									
										</td>
									</tr>
									<tr>
										<td class="Config_TH"><p class="tx_TH"><spring:message code='Cache.lbl_apv_attend_rule'/></p></td> <!-- 근태 규정 -->
										<td colspan=2>
											<div id="divPolicyEditForm" class="writeEdit"></div>
										</td>
									</tr>
								</tbody>
							</table>
						</div>
						<div class="bottom">
							<a href="#" class="btnTypeDefault btnTypeBg createCSBtn"><spring:message code='Cache.lbl_Save'/></a>
						</div>
					</div>
				</div>

			</div>
		</div>
		<!-- 컨텐츠 끝 -->
	</form>
</div>


<table style="display:none;" >
	<tr id="assTr" name="assTr">
		<td><input type="text" value="" style="display:none">
			<input type="text" value="" style="width:100px" class="tx_Cont"></td>
		<td><input type="text" value=""  style="width:50px" class="onlyNum tx_Cont"><spring:message code='Cache.lbl_Minutes'/> <!-- 분 -->
			<input type="text"  style="display:none" value="A"></td>
		<td  onclick="hideRow(this);"><a href="#" class="btnTypeDefault"><spring:message code='Cache.lbl_delete'/></a></td>
	</tr>

	<tr id="rewardTr" name="rewardTr">
		<td><input type="text" class="onlyNum" value=""><label><spring:message code='Cache.lbl_Hours'/></label><input type="text" class="onlyNum" value=""><label><spring:message code='Cache.lbl_n_att_excessOfMin'/></label></td>
		<td><span class="ConfigPer"><label><spring:message code='Cache.lbl_Weekly'/> : </label><input type="text" class="onlyNum1" value=""><label> </label></span>
			<span class="ConfigPer"><label><spring:message code='Cache.lbl_night'/> : </label><input type="text" class="onlyNum1" value=""><label> </label></span>
		</td>
		<td onclick="removeRow(this);"><a href="#" class="btnTypeDefault"><spring:message code='Cache.lbl_delete'/></a></td>
	</tr>
	<tr id="rewardHoliTr" name="rewardHoliTr" >
		<td><input type="text" class="onlyNum" value=""><label><spring:message code='Cache.lbl_Hours'/></label><input type="text" class="onlyNum" value=""><label><spring:message code='Cache.lbl_n_att_excessOfMin'/></label></td>
		<td><span class="ConfigPer"><label><spring:message code='Cache.lbl_Weekly'/> : </label><input type="text" class="onlyNum1" value=""><label> </label></span>
			<span class="ConfigPer"><label><spring:message code='Cache.lbl_night'/> : </label><input type="text" class="onlyNum1" value=""><label> </label></span>
		</td>
		<td onclick="removeRow(this);"><a href="#" class="btnTypeDefault"><spring:message code='Cache.lbl_delete'/></a></td>
	</tr>
	<tr id="rewardOffTr" name="rewardOffTr" >
		<td><input type="text" class="onlyNum" value=""><label><spring:message code='Cache.lbl_Hours'/></label><input type="text" class="onlyNum" value=""><label><spring:message code='Cache.lbl_n_att_excessOfMin'/></label></td>
		<td><span class="ConfigPer"><label><spring:message code='Cache.lbl_Weekly'/> : </label><input type="text" class="onlyNum1" value=""><label> </label></span>
			<span class="ConfigPer"><label><spring:message code='Cache.lbl_night'/> : </label><input type="text" class="onlyNum1" value=""><label> </label></span>
		</td>
		<td onclick="removeRow(this);"><a href="#" class="btnTypeDefault"><spring:message code='Cache.lbl_delete'/></a></td>
	</tr>
	<tr id="restTr" name="restTr">
		<td><input type="text" class="onlyNum" value=""><label><spring:message code='Cache.lbl_Hours'/></label><input type="text" class="onlyNum" value=""><label><spring:message code='Cache.lbl_Minutes'/></label></td>
		<td><input type="text" class="onlyNum" value=""><label><spring:message code='Cache.lbl_Hours'/></label><input type="text" class="onlyNum" value=""><label><spring:message code='Cache.lbl_Minutes'/> <spring:message code='Cache.lbl_n_att_additionOfRest'/></label></td>
		<td onclick="removeRow(this);"><a href="#" class="btnTypeDefault"><spring:message code='Cache.lbl_delete'/></a></td>
	</tr>
	<tr id="extendTr" name="extendTr">
		<td><input type="text" class="onlyNum" value=""><label><spring:message code='Cache.lbl_Hours'/></label><input type="text" class="onlyNum" value=""><label><spring:message code='Cache.lbl_Minutes'/></label></td>
		<td><input type="text" class="onlyNum" value=""><label><spring:message code='Cache.lbl_Hours'/></label><input type="text" class="onlyNum" value=""><label><spring:message code='Cache.lbl_Minutes'/> <spring:message code='Cache.lbl_n_att_additionOfRest'/></label></td>
		<td onclick="removeRow(this);"><a href="#" class="btnTypeDefault"><spring:message code='Cache.lbl_delete'/></a></td>
	</tr>

	<tr id="ipTr" name="ipTr">
		<!-- <td><div class="alarm type01"><a href="#" class="onOffBtn" onclick='toggleBtn(this);'><span></span></a></div></td> -->
		<td><p class=""><input type="text" value=""></p></td>
		<td><p class=""><input type="text" value=""></p></td>
		<td><div class="alarm type01"><a href="#" class="onOffBtn" onclick='toggleBtn(this);'><span></span></a></div></td>
		<td><div class="alarm type01"><a href="#" class="onOffBtn" onclick='toggleBtn(this);'><span></span></a></div></td>
		<td><p class=""><input type="text" value=""></p></td>
		<td onclick="removeRow(this);"><a href="#" class="btnTypeDefault"><spring:message code='Cache.lbl_delete'/></a></td>
	</tr>
</table>


<script type="text/javascript">

	$(document).ready(function(){
		init();
		getBaseInfo();
		extendSETimeCheck();
	});

	function init(){
		$(".createCSBtn").on('click',function(){			
			saveCompanySetting(); // 저장
		});
		// 탭 변경
		$(".topToggle").on('click',function(){
			toggleTab($(this));
		});
		// 스위치 버튼 변경
		$(".onOffBtn").on('click',function(){
			toggleBtn(this);
		});
		//근무신청
		$(".btnDropdown").on('click',function(){
			$(this).next().toggle();
		});


		//요청 승인 구분
		var opHtml = "";
		var AttendReqMethod = Common.getBaseCode("AttendReqMethod").CacheData;
		for(var i=0;i<AttendReqMethod.length;i++){
			opHtml += "<option value='"+AttendReqMethod[i].Code+"'>"+CFN_GetDicInfo(AttendReqMethod[i].MultiCodeName)+"</option>";
		}
		$(".reqMethod").html(opHtml);

		//휴일대체근무 요청 임시
		opHtml = "";
		opHtml += "<option value='N'><spring:message code='Cache.lbl_USE_N'/></option>";
		opHtml += "<option value='Y'><spring:message code='Cache.lbl_USE_Y'/></option>";
		$("select[name=HoliReplReqMethod]").html(opHtml);
		//연장/휴일 근무 시간인정
		$("select[name=ExtenHoliTimeMethod]").html(opHtml);

		//출퇴근 요청 승인 구분
		opHtml = "";
		var reqAttMethod = Common.getBaseCode("reqAttMethod").CacheData;
		for(var i=0;i<reqAttMethod.length;i++){
			if (reqAttMethod[i].Code == "Approval") continue;
			opHtml += "<option value='"+reqAttMethod[i].Code+"'>"+CFN_GetDicInfo(reqAttMethod[i].MultiCodeName)+"</option>";
		}
		$(".reqAttMethod").html(opHtml);

		/*보상휴가 적용기간
		opHtml = "";
		var rewardPeriod = Common.getBaseCode("RewardPeriod").CacheData;
		for(var i=0;i<rewardPeriod.length;i++){
			opHtml += "<option value='"+rewardPeriod[i].Code+"'>"+CFN_GetDicInfo(rewardPeriod[i].MultiCodeName)+"</option>";
		}
		$(".RewardPeriod").html(opHtml);
*/
		//일괄 출퇴근
		opHtml = "";
		var goWorkApplyTime = Common.getBaseCode("GoWorkApplyTime").CacheData;
		for(var i = 0; i < goWorkApplyTime.length; i++){
			opHtml += "<option value='"+goWorkApplyTime[i].Code+"'>"+CFN_GetDicInfo(goWorkApplyTime[i].MultiCodeName)+"</option>";
		}
		$("#selGoWorkApplyTime").html(opHtml);

		opHtml = "";
		var offWorkApplyTime = Common.getBaseCode("OffWorkApplyTime").CacheData;
		for(var i = 0; i < offWorkApplyTime.length; i++){
			opHtml += "<option value='"+offWorkApplyTime[i].Code+"'>"+CFN_GetDicInfo(offWorkApplyTime[i].MultiCodeName)+"</option>";
		}
		$("#selOffWorkApplyTime").html(opHtml);

		$('#RemainTimeCode_40').click(function(){
			if ($(this).hasClass("on")){
				$('#RemainTimeCode_52').removeClass("on");
			}
			else
				$('#RemainTimeCode_52').addClass("on");
		});
		$('#RemainTimeCode_52').click(function(){
			if ($(this).hasClass("on")){
				$('#RemainTimeCode_40').removeClass("on");
			}
			else
				$('#RemainTimeCode_40').addClass("on");
		});
		//
		onlyNumber($(".onlyNum"));
		onlyDecimal($(".onlydecimal"));

		$("#ExtenStartEndTimeBtnYn").click(function(){
			if (!$(this).hasClass("on")){
				$('select[name="ExtenStartTimeHour"] option[value="00"]').attr("selected","selected");
				$('select[name="ExtenStartTimeMin"] option[value="00"]').attr("selected","selected");
				$('select[name="ExtenEndTimeHour"] option[value="00"]').attr("selected","selected");
				$('select[name="ExtenEndTimeMin"] option[value="00"]').attr("selected","selected");
			}
		});
		$('select[name="ExtenStartTimeHour"]').change(function(){
			var ExtenStartTimeHour = $('select[name="ExtenStartTimeHour"]').val();
			var ExtenStartTimeMin = $('select[name="ExtenStartTimeMin"]').val();
			var ExtenEndTimeHour = $('select[name="ExtenEndTimeHour"]').val();
			var ExtenEndTimeMin = $('select[name="ExtenEndTimeMin"]').val();
			if(ExtenStartTimeHour=="00" && ExtenStartTimeMin=="00" && ExtenEndTimeHour=="00" && ExtenEndTimeMin=="00"){
				$("#ExtenStartEndTimeBtnYn").removeClass("on");
			}else{
				extendSETimeCheck();
			}
		});

		$('select[name="ExtenStartTimeMin"]').change(function(){
			var ExtenStartTimeHour = $('select[name="ExtenStartTimeHour"]').val();
			var ExtenStartTimeMin = $('select[name="ExtenStartTimeMin"]').val();
			var ExtenEndTimeHour = $('select[name="ExtenEndTimeHour"]').val();
			var ExtenEndTimeMin = $('select[name="ExtenEndTimeMin"]').val();
			if(ExtenStartTimeHour=="00" && ExtenStartTimeMin=="00" && ExtenEndTimeHour=="00" && ExtenEndTimeMin=="00"){
				$("#ExtenStartEndTimeBtnYn").removeClass("on");
			}else{
				extendSETimeCheck();
			}
		});

		$('select[name="ExtenEndTimeHour"]').change(function(){
			var ExtenStartTimeHour = $('select[name="ExtenStartTimeHour"]').val();
			var ExtenStartTimeMin = $('select[name="ExtenStartTimeMin"]').val();
			var ExtenEndTimeHour = $('select[name="ExtenEndTimeHour"]').val();
			var ExtenEndTimeMin = $('select[name="ExtenEndTimeMin"]').val();
			if(ExtenStartTimeHour=="00" && ExtenStartTimeMin=="00" && ExtenEndTimeHour=="00" && ExtenEndTimeMin=="00"){
				$("#ExtenStartEndTimeBtnYn").removeClass("on");
			}else{
				extendSETimeCheck();
			}
		});

		$('select[name="ExtenEndTimeMin"]').change(function(){
			var ExtenStartTimeHour = $('select[name="ExtenStartTimeHour"]').val();
			var ExtenStartTimeMin = $('select[name="ExtenStartTimeMin"]').val();
			var ExtenEndTimeHour = $('select[name="ExtenEndTimeHour"]').val();
			var ExtenEndTimeMin = $('select[name="ExtenEndTimeMin"]').val();
			if(ExtenStartTimeHour=="00" && ExtenStartTimeMin=="00" && ExtenEndTimeHour=="00" && ExtenEndTimeMin=="00"){
				$("#ExtenStartEndTimeBtnYn").removeClass("on");
			}else{
				extendSETimeCheck();
			}
		});

		//근태포탈 일별 출근 현황 표기 대상 직책 설정
		setCheckBoxJobTitle('divAttPortalDailyJobTitle','AttPortalDailyJobTitle','JobTitle');
		setCheckBoxJobTitle('divAttendanceGMJobTiltle','AttendanceGMJobTiltle','JobTitle');

	}

	function setCheckBoxJobTitle(objId, objName, groupType) {
		//직책
		$.ajax({
			async: false,
			type: "POST",
			data: {
				"domainCode": Common.getSession("DN_Code"),
				"groupType": groupType
			},
			url: "/covicore/admin/orgmanage/getjobinfolist.do",
			success: function (data) {
				if (data.status == "FAIL") {
					alert(data.message);
					return;
				}

				var opHtml = "";
				var list = data.list;
				for(var i = 0; i < list.length; i++){
//					<label for="LateSendYn"><span class="s_check"></span>지각</label>
					opHtml += "<div  class='chkStyle10'><input type='checkbox'  class='check_class'  name='"+objName+"'  id='"+objName+'_'+i+"'  value='"+list[i].GroupCode+"'/><label for='"+objName+'_'+i+"'><span class='s_check'></span>"+CFN_GetDicInfo(list[i].MultiDisplayName)+"</label></div>";
				}
				$("#"+objId).html(opHtml);
			},
			error: function (response, status, error) {
				//TODO 추가 오류 처리
				CFN_ErrorAjax("/covicore/admin/orgmanage/getjobinfolist.do",
						response, status, error);
			}
		});
	}

	function getSelectJobTitle(objId, groupType) {
		//직책
		$.ajax({
			async: false,
			type: "POST",
			data: {
				"domainCode": Common.getSession("DN_Code"),
				"groupType": groupType
			},
			url: "/covicore/admin/orgmanage/getjobinfolist.do",
			success: function (data) {
				if (data.status == "FAIL") {
					alert(data.message);
					return;
				}

				var opHtml = "";
				var list = data.list;
				for(var i = 0; i < list.length; i++){
					opHtml += "<option value='"+list[i].GroupCode+"'>"+CFN_GetDicInfo(list[i].MultiDisplayName)+"</option>";
				}
				$("#"+objId).html(opHtml);
			},
			error: function (response, status, error) {
				//TODO 추가 오류 처리
				CFN_ErrorAjax("/covicore/admin/orgmanage/getjobinfolist.do",
						response, status, error);
			}
		});
	}

	function extendSETimeCheck(){
		var ExtenStartTimeHour = $('select[name="ExtenStartTimeHour"]').val();
		var ExtenStartTimeMin = $('select[name="ExtenStartTimeMin"]').val();
		var ExtenEndTimeHour = $('select[name="ExtenEndTimeHour"]').val();
		var ExtenEndTimeMin = $('select[name="ExtenEndTimeMin"]').val();
		if(ExtenStartTimeHour!="00" || ExtenStartTimeMin!="00" || ExtenEndTimeHour!="00" || ExtenEndTimeMin!="00"){
			if(!$("#ExtenStartEndTimeBtnYn").hasClass("on")){
				$("#ExtenStartEndTimeBtnYn").addClass("on");
			}
		}
	}

	function toggleBtn(o){
		if($(o).attr("class").lastIndexOf("on") > 0 ) {
			$(o).removeClass("on");
		}else{
			$(o).addClass("on");
		}
	}

	function setColList(o){
		$(o).parent().parent().prev().html($(o).html());
		$(o).parent().parent().prev().data("dayvalue",$(o).data("dayvalue"));
		$(o).parent().parent().hide();

	};

	function toggleTab(o){
		$(".topToggle").attr("class","topToggle");
		$(".topToggle").eq(o.index()).attr("class","topToggle active");
		$(".tabContent").removeClass("active");
		$(".tabContent").eq(o.index()).addClass("active");
		if ($(".tabContent").eq(o.index()).attr("data-add") == "editor"
					&& $("#divMailEditForm").attr("data-load")!= "Y"){		
			coviEditor.loadEditor('divMailEditForm', {
				editorType : g_editorKind //'dext5'
				,containerID : 'tbContentMail'
				,frameHeight : '300'
				,focusObjID : ''
				,onLoad: function(){
					coviEditor.setBody(g_editorKind, 'tbContentMail' , $("#divMailEditForm").attr("data-cont"));
					$("#divMailEditForm").attr("data-load","Y");
				}
			});
			
			coviEditor.loadEditor('divPolicyEditForm', {
				editorType : g_editorKind //'dext5'
				,containerID : 'tbContentPolicy'
				,frameHeight : '300'
				,focusObjID : ''
				,onLoad: function(){
					coviEditor.setBody(g_editorKind, 'tbContentPolicy' , $("#divPolicyEditForm").attr("data-cont"));
				}
			});
			
		}	
	}

	function setValue(nm){
		return $("a[name="+nm+"]").attr("class").lastIndexOf("on") > 0 ? "Y" : "N" ;
	}

	function getBaseInfo(){
		$.ajax({
			type:"POST",
			url:"/groupware/attendAdmin/getCompanySettings.do",
			success:function (data) {
				var result = data.data;
				var assList = result.assList;
				var rewardList = result.rewardList;
				var rewardListHoli = result.rewardListHoli;
				var rewardListOff = result.rewardListOff;
				var restList = result.restList;
				var ipList = result.ipList;
				var mngMst = result.mngMstMap;

				for(var i=0;i<assList.length;i++){
					addRow("ass");
					$("tr[name=assTr]").eq(i).children("td").eq(0).find("input").eq(0).val(assList[i].AssSeq);
					$("tr[name=assTr]").eq(i).children("td").eq(0).find("input").eq(1).val(assList[i].AssName);
					$("tr[name=assTr]").eq(i).children("td").eq(1).find("input").eq(0).val(assList[i].AssWorkTime);
					$("tr[name=assTr]").eq(i).children("td").eq(1).find("input").eq(1).val("U");
					if (assList[i].SchSeq != "")
						$("tr[name=assTr]").eq(i).children("td").eq(2).html("");
				}

				for(var i=0;i<rewardList.length;i++){
					addRow("reward");
					$("tr[name=rewardTr]").eq(i).children("td").eq(0).find("input").eq(0).val(rewardList[i].OverTimeHour);
					$("tr[name=rewardTr]").eq(i).children("td").eq(0).find("input").eq(1).val(rewardList[i].OverTimeMin);
					$("tr[name=rewardTr]").eq(i).children("td").eq(1).find("input").eq(0).val(rewardList[i].RewardTime);
					$("tr[name=rewardTr]").eq(i).children("td").eq(1).find("input").eq(1).val(rewardList[i].RewardNTime);
				}
				for(var i=0;i<rewardListHoli.length;i++){
					addRow("rewardHoli");

					$("tr[name=rewardHoliTr]").eq(i).children("td").eq(0).find("input").eq(0).val(rewardListHoli[i].OverTimeHour);
					$("tr[name=rewardHoliTr]").eq(i).children("td").eq(0).find("input").eq(1).val(rewardListHoli[i].OverTimeMin);
					$("tr[name=rewardHoliTr]").eq(i).children("td").eq(1).find("input").eq(0).val(rewardListHoli[i].RewardTime);
					$("tr[name=rewardHoliTr]").eq(i).children("td").eq(1).find("input").eq(1).val(rewardListHoli[i].RewardNTime);
				}
				for(var i=0;i<rewardListOff.length;i++){
					addRow("rewardOff");

					$("tr[name=rewardOffTr]").eq(i).children("td").eq(0).find("input").eq(0).val(rewardListOff[i].OverTimeHour);
					$("tr[name=rewardOffTr]").eq(i).children("td").eq(0).find("input").eq(1).val(rewardListOff[i].OverTimeMin);
					$("tr[name=rewardOffTr]").eq(i).children("td").eq(1).find("input").eq(0).val(rewardListOff[i].RewardTime);
					$("tr[name=rewardOffTr]").eq(i).children("td").eq(1).find("input").eq(1).val(rewardListOff[i].RewardNTime);
				}
				for(var i=0;i<restList.length;i++){
					addRow("rest");
					$("tr[name=restTr]").eq(i).children("td").eq(0).find("input").eq(0).val(restList[i].OverTimeHour);
					$("tr[name=restTr]").eq(i).children("td").eq(0).find("input").eq(1).val(restList[i].OverTimeMin);
					$("tr[name=restTr]").eq(i).children("td").eq(1).find("input").eq(0).val(restList[i].RewardTimeHour);
					$("tr[name=restTr]").eq(i).children("td").eq(1).find("input").eq(1).val(restList[i].RewardTimeMin);
				}
				for(var i=0;i<ipList.length;i++){
					addRow("ip");
					/* if(ipList[i].ValidYn=="Y") $("tr[name=ipTr]").eq(i).children("td").eq(0).find("a").addClass("on"); */
					$("tr[name=ipTr]").eq(i).find("td").eq(0).find("input").eq(0).val(ipList[i].SIp);
					$("tr[name=ipTr]").eq(i).find("td").eq(1).find("input").eq(0).val(ipList[i].EIp);
					if(ipList[i].PcUsedYn=="Y") $("tr[name=ipTr]").eq(i).find("td").eq(2).find("a").addClass("on");
					if(ipList[i].MobileUsedYn=="Y") $("tr[name=ipTr]").eq(i).find("td").eq(3).find("a").addClass("on");
					$("tr[name=ipTr]").eq(i).find("td").eq(4).find("input").eq(0).val(ipList[i].Etc);
				}
				if(mngMst.PcUseYn=="Y") $("#PcUseYn").addClass("on");
				if(mngMst.MobileUseYn=="Y") $("#MobileUseYn").addClass("on");
				if(mngMst.OthYn=="Y") $("#OthYn").addClass("on");
				if(mngMst.IpYn=="Y") $("#IpYn").addClass("on");

				if(mngMst.LateSendYn=="Y") $("#LateSendYn").prop('checked', true);
				if(mngMst.AbsentSendYn=="Y") $("#AbsentSendYn").prop('checked', true);
				if(mngMst.EarlySendYn=="Y") $("#EarlySendYn").prop('checked', true);
				if(mngMst.CallingSendYn=="Y") $("#CallingSendYn").prop('checked', true);

				$("#MailTitle").val(mngMst.MailTitle);
				$("#divMailEditForm").attr("data-cont",mngMst.MailBody);
				$("#divPolicyEditForm").attr("data-cont",mngMst.AttendPolicy);
				
			}
		});

		setCol();
	}


	function addRow(id){
		var clone = $("#"+id+"Tr").clone();
		clone = clone.removeAttr("id");
		$("#"+id+"Tb").append(clone);

		onlyNumber($(".onlyNum"));
	}
	//function
	//setMode
	function hideRow(o){

		if ($(o).parent().find("td").eq(0).find("input").eq(0).val() == ""){
			removeRow(o);
		}
		else{
			$(o).parent().find("td").eq(1).find("input").eq(1).val("D");
			$(o).parent().hide();
		}

	}


	function removeRow(o){
		$(o).parent().remove();
	}



	function setCol(){
		var col = [
			"AssYn"
			,"AttAlarmYn"
			/* ,"AttConfmYn" */
			,"AttReqMethod"
			,"CommuModReqMethod"
			,"CoreEndTime"
			,"CoreStartTime"
			,"CoreTimeYn"
			,"EndAlarmTime"
			,"EndAlarmYn"
			,"ExtenAlarmTime"
			,"ExtenAlarmYn"
			,"ExtenDelMethod"
			,"ExtenUpdMethod"
			,"ExtenReqMethod"
			,"HoliDelMethod"
			,"HoliUpdMethod"
			,"HoliReqMethod"
			,"HoliReplReqMethod"
			,"ExtenHoliTimeMethod"
			,"LeaveAlarmYn"
			,"LeaveReqMethod"
			/* ,"LeaveYn" */
			,"NoSchYn"
			,"ExptVacTime"
			/* ,"OutDelMethod"
            ,"OutUpdMethod"
            ,"OutReqMethod"
            ,"RemainTimeCode"*/
			,"OutsideYn"
			,"CustomSchYn"
			,"RestYn"
			,"RewardYn"
			,"SchConfmYn"
			,"StartAlarmTime"
			,"StartAlarmYn"
			,"StaticSetMethod"
			,"TardyAlarmTime"
			,"TardyAlarmYn"
			,"VacDelMethod"
			,"VacReqMethod"
			,"WorkReqMethod"
			,"WorkDelMethod"
			,"WorkUpdMethod"
			,"AttStartTimeTermMin"
			,"AttStatusStartTimeTermMin"
			,"AttEndTimeTermMin"
			,"AttStatusEndTimeTermMin"
			,"AttBaseWeek"
			,"UserTempleteYn"
			,"UserReqAttTime"
			,"RealTimeYn"
			,"CommuteOutTerm"
			,"CommuteTimeYn"
			,"ExcelSaveYn"
			,"ExcelSaveYnAdmin"
			,"ExtenUnit"
			,"ExtenRestYn"
			,"ExtenWorkTime"
			,"ExtenRestTime"
			,"HoliRestYn"
			,"HoliWorkTime"
			,"HoliRestTime"
			,"ExtenMaxTime"
			,"ExtenMaxWeekTime"
			,"ExtenStartTime"
			,"ExtenEndTime"
			/*알람기능 추가 2021.10.08 nkpark*/
			,"AlarmAttStartNoticeToUserYn"
			,"AlarmAttStartNoticeMin"
			,"AlarmAttEndNoticeToUserYn"
			,"AlarmAttEndNoticeMin"
			,"AlarmAttOvertimeToAdminUserYn"
			,"AlarmAttLateToAdminUserYn"
			// 일괄 출퇴근 추가
			,"AllGoWorkApplyTime"
			,"AllOffWorkApplyTime"
			// 근태확정 추가
			,"AttConfirmYn"
		];

		for(var i=0;i<col.length;i++){
			var cacheVal = Common.getBaseConfig(col[i]);

			$("input:text[name="+col[i]+"]").each(function() {
				$("input:text[name="+col[i]+"]").val(cacheVal);
			});

			$("#"+col[i]).each(function(){
				if(cacheVal=="Y"){
					$(this).addClass("on");
				}
			});
			$("select[name="+col[i]+"]").val(cacheVal);

			if(col[i]=="CoreStartTime"||col[i]=="CoreEndTime"|| col[i]=="ExtenStartTime"||col[i]=="ExtenEndTime"){
				$("select[name="+col[i]+"Hour]").val(cacheVal.substr(0,2));
				$("select[name="+col[i]+"Min]").val(cacheVal.substr(2,2));
			}
			$("input:radio[name="+col[i]+"]").each(function() {
				$("input:radio[name="+col[i]+"]:radio[value='"+cacheVal+"']").prop('checked', true);
			});

		}
		var cacheVal = Common.getBaseConfig("RemainTimeCode");
		$("#RemainTimeCode_"+cacheVal).addClass("on");
		var AttendanceGMJobTiltleVal = Common.getBaseConfig("AttendanceGMJobTiltle").split("|");
		$.each(AttendanceGMJobTiltleVal, function (i, item) {
			$('input:checkbox[name="AttendanceGMJobTiltle"]').each(function(j, obj) {
				if ($(this).val() === item) {
					$(this).attr("checked",true);
				}
			});
		});

		var AttPortalDailyJobTitleVal = Common.getBaseConfig("AttPortalDailyJobTitle").split("|");
		$.each(AttPortalDailyJobTitleVal, function (i, item) {
			$('input:checkbox[name="AttPortalDailyJobTitle"]').each(function(j, obj) {
				if ($(this).val() === item) {
					$(this).attr("checked",true);
				}
			});
		});

		var ExcelDataModeVal = Common.getBaseConfig("ExcelDataMode").split("|");
		$.each(ExcelDataModeVal, function (i, item) {
			$('input:checkbox[name="ExcelDataMode"]').each(function(j, obj) {
				if ($(this).val() === item) {
					$(this).attr("checked",true);
				}
			});
		});
	}


	//등록
	function saveCompanySetting(){

		var data = $("#frm").serializeObject();

		data.CoreStartTime = $("select[name=CoreStartTimeHour]").val()+$("select[name=CoreStartTimeMin]").val();
		data.CoreEndTime = $("select[name=CoreEndTimeHour]").val()+$("select[name=CoreEndTimeMin]").val();

		data.ExtenStartTime = $("select[name=ExtenStartTimeHour]").val()+$("select[name=ExtenStartTimeMin]").val();
		data.ExtenEndTime = $("select[name=ExtenEndTimeHour]").val()+$("select[name=ExtenEndTimeMin]").val();

		data.SchConfmYn = $("#SchConfmYn").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
		data.AssYn = $("#AssYn").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
		data.NoSchYn = "Y";//Y 로 세팅
		data.OutsideYn = $("#OutsideYn").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
		data.CustomSchYn = $("#CustomSchYn").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
		/* data.LeaveYn = $("#LeaveYn").attr("class").lastIndexOf("on") > 0 ? "Y":"N"; */
		/* data.AttConfmYn = $("#AttConfmYn").attr("class").lastIndexOf("on") > 0 ? "Y":"N"; */
		data.RewardYn = $("#RewardYn").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
		data.RestYn = $("#RestYn").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
		data.RestBtnYn = $("#RestBtnYn").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
		data.CoreTimeYn = $("#CoreTimeYn").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
		
		data.PcUseYn = $("#PcUseYn").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
		data.MobileUseYn = $("#MobileUseYn").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
		data.OthYn = $("#OthYn").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
		data.IpYn = $("#IpYn").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
		
		data.LateSendYn = $("#LateSendYn").prop("checked") ? "Y":"N";
		data.AbsentSendYn = $("#AbsentSendYn").prop("checked") ? "Y":"N";
		data.EarlySendYn = $("#EarlySendYn").prop("checked") ? "Y":"N";
		data.CallingSendYn = $("#CallingSendYn").prop("checked") ? "Y":"N";
		
		data.MailTitle = $("#MailTitle").val();
		if ($("#divMailEditForm").attr("data-load")!= "Y"){//editor 로드가 안된 경우  이전값 주기
			data.MailBody = $("#divMailEditForm").attr("data-cont");
			data.AttendPolicy = $("#divPolicyEditForm").attr("data-cont");
		}else{
			data.MailBody = $.trim(coviEditor.getBodyText(g_editorKind, 'tbContentMail')) == ""?"":coviEditor.getBody(g_editorKind, 'tbContentMail');
			data.AttendPolicy = $.trim(coviEditor.getBodyText(g_editorKind, 'tbContentPolicy')) == ""?"":coviEditor.getBody(g_editorKind, 'tbContentPolicy');
		}
		data.RealTimeYn = $("#RealTimeYn").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
		data.CommuteTimeYn = $("#CommuteTimeYn").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
		data.ExcelSaveYn = $("#ExcelSaveYn").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
		data.ExcelSaveYnAdmin = $("#ExcelSaveYnAdmin").attr("class").lastIndexOf("on") > 0 ? "Y":"N";

		var ExcelDataMode = "";
		var ckCntMode = 0;
		$('input:checkbox[name="ExcelDataMode"]:checked').each(function() {
			if(ckCntMode>0){ExcelDataMode+='|'}
			ExcelDataMode += $(this).val();
			ckCntMode++;
		});
		data.ExcelDataMode =  ExcelDataMode;
		
		data.CoreTimeYn = $("#CoreTimeYn").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
		data.ExtenRestYn = $("#ExtenRestYn").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
		data.HoliRestYn = $("#HoliRestYn").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
		data.RemainTimeCode = $("#RemainTimeCode_40").attr("class").lastIndexOf("on") > 0 ? "40":"52";
		data.ExptVacTime = $("#ExptVacTime").attr("class").lastIndexOf("on") > 0 ? "Y":"N";


		/*알람기능 추가 2021.10.08 nkpark*/
		data.AlarmAttStartNoticeToUserYn = $("#AlarmAttStartNoticeToUserYn").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
		data.AlarmAttEndNoticeToUserYn = $("#AlarmAttEndNoticeToUserYn").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
		data.AlarmAttOvertimeToAdminUserYn = $("#AlarmAttOvertimeToAdminUserYn").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
		data.AlarmAttLateToAdminUserYn = $("#AlarmAttLateToAdminUserYn").attr("class").lastIndexOf("on") > 0 ? "Y":"N";

		//수정삭제는 요청이랑 같이 세팅
		data.ExtenUpdMethod =  $("select[name=ExtenReqMethod]").val();
		data.ExtenDelMethod =  $("select[name=ExtenReqMethod]").val();

		data.HoliUpdMethod =  $("select[name=HoliReqMethod]").val();
		data.HoliDelMethod =  $("select[name=HoliReqMethod]").val();

		data.VacDelMethod =  $("select[name=VacReqMethod]").val();

		data.HoliReplReqMethod = $("select[name=HoliReplReqMethod]").val();

		data.ExtenHoliTimeMethod = $("select[name=ExtenHoliTimeMethod]").val();
		
		/* 근태확정 기능 추가 2023-10-06 */
		data.AttConfirmYn = $("#AttConfirmYn").attr("class").lastIndexOf("on") > 0 ? "Y":"N";

		//근태 포탈 환경설정

		var AttPortalDailyJobTitle = "";
		var ckCnt2 = 0;
		$('input:checkbox[name="AttPortalDailyJobTitle"]:checked').each(function() {
			if(ckCnt2>0){AttPortalDailyJobTitle+='|'}
			AttPortalDailyJobTitle += $(this).val();
			ckCnt2++;
		});
		data.AttPortalDailyJobTitle =  AttPortalDailyJobTitle;

		var AttendanceGMJobTiltle = "";
		var ckCnt = 0;
		$('input:checkbox[name="AttendanceGMJobTiltle"]:checked').each(function() {
			if(ckCnt>0){AttendanceGMJobTiltle+='|'}
			AttendanceGMJobTiltle += $(this).val();
			ckCnt++;
		});
		data.AttendanceGMJobTiltle =  AttendanceGMJobTiltle;

		var assArry = new Array();
		for(var i=0;i<$("tr[name=assTr]").length-1;i++){
			if ($("tr[name=assTr]").eq(i).find("input").eq(1).val()!=""	){
				var assParam = {
					"AssSeq" 		:  $("tr[name=assTr]").eq(i).find("input").eq(0).val()
					,"AssName" 		:  $("tr[name=assTr]").eq(i).find("input").eq(1).val()
					,"AssWorkTime" 		:  $("tr[name=assTr]").eq(i).find("input").eq(2).val()
					,"AssMode" 		:  $("tr[name=assTr]").eq(i).find("input").eq(3).val()
				};
				assArry.push(assParam);
			} else if(data.AssYn == "Y"){
				Common.Warning("<spring:message code='Cache.lbl_Assum'/>" + " " + "<spring:message code='Cache.msg_apv_chk_contents'/>"); // 간주근로 내용이 입력되지 않았습니다.
				return;
			}
		}
		data.assArry = JSON.stringify(assArry);


		var rewardArry = new Array();
		for(var i=0;i<$("tr[name=rewardTr]").length-1;i++){
			if(
					$("tr[name=rewardTr]").eq(i).find("input").eq(0).val()!=""
					&&$("tr[name=rewardTr]").eq(i).find("input").eq(1).val()!=""
					&&$("tr[name=rewardTr]").eq(i).find("input").eq(2).val()!=""
					&&$("tr[name=rewardTr]").eq(i).find("input").eq(3).val()!=""
			){
				var rewardParam = {
					"OverTimeHour" 		:  $("tr[name=rewardTr]").eq(i).find("input").eq(0).val()
					,"OverTimeMin" 		:  $("tr[name=rewardTr]").eq(i).find("input").eq(1).val()
					,"RewardTime" 	:  $("tr[name=rewardTr]").eq(i).find("input").eq(2).val()
					,"RewardNTime" 	:  $("tr[name=rewardTr]").eq(i).find("input").eq(3).val()
					,"MethodType": "RATE"
					,"HolidayFlag" : "1"
					,"RewardCode" : "reward"
				};
				rewardArry.push(rewardParam);
			} else if(data.RewardYn == "Y"){
				Common.Warning("<spring:message code='Cache.msg_n_att_companySetting14'/>" + " " + "<spring:message code='Cache.msg_apv_chk_contents'/>"); // 평일 연장근무 보상휴가 산정 내용이 입력되지 않았습니다.
				return;
			}
		}
		data.rewardArry = JSON.stringify(rewardArry);

		var rewardHoliArry = new Array();
		for(var i=0;i<$("tr[name=rewardHoliTr]").length-1;i++){
			if(
					$("tr[name=rewardHoliTr]").eq(i).find("input").eq(0).val()!=""
					&&$("tr[name=rewardHoliTr]").eq(i).find("input").eq(1).val()!=""
					&&$("tr[name=rewardHoliTr]").eq(i).find("input").eq(2).val()!=""
					&&$("tr[name=rewardHoliTr]").eq(i).find("input").eq(3).val()!=""
			){
				var rewardParam = {
					"OverTimeHour" 		:  $("tr[name=rewardHoliTr]").eq(i).find("input").eq(0).val()
					,"OverTimeMin" 		:  $("tr[name=rewardHoliTr]").eq(i).find("input").eq(1).val()
					,"RewardTime" 	:  $("tr[name=rewardHoliTr]").eq(i).find("input").eq(2).val()
					,"RewardNTime" 	:  $("tr[name=rewardHoliTr]").eq(i).find("input").eq(3).val()
					,"MethodType": "RATE"
					,"HolidayFlag" : "0"
					,"RewardCode" : "reward"
				};
				rewardHoliArry.push(rewardParam);
			} else if(data.RewardYn == "Y"){
				Common.Warning("<spring:message code='Cache.lbl_n_att_calculationHoliday'/>" + " " + "<spring:message code='Cache.msg_apv_chk_contents'/>"); // 휴일 근무 보상휴가 산정 내용이 입력되지 않았습니다.
				return;
			}
		}
		data.rewardHoliArry = JSON.stringify(rewardHoliArry);

		var rewardOffArry = new Array();
		for(var i=0;i<$("tr[name=rewardOffTr]").length-1;i++){
			if(
					$("tr[name=rewardOffTr]").eq(i).find("input").eq(0).val()!=""
					&&$("tr[name=rewardOffTr]").eq(i).find("input").eq(1).val()!=""
					&&$("tr[name=rewardOffTr]").eq(i).find("input").eq(2).val()!=""
					&&$("tr[name=rewardOffTr]").eq(i).find("input").eq(3).val()!=""
			){
				var rewardParam = {
					"OverTimeHour" 		:  $("tr[name=rewardOffTr]").eq(i).find("input").eq(0).val()
					,"OverTimeMin" 		:  $("tr[name=rewardOffTr]").eq(i).find("input").eq(1).val()
					,"RewardTime" 	:  $("tr[name=rewardOffTr]").eq(i).find("input").eq(2).val()
					,"RewardNTime" 	:  $("tr[name=rewardOffTr]").eq(i).find("input").eq(3).val()
					,"MethodType": "RATE"
					,"HolidayFlag" : "2"
					,"RewardCode" : "reward"
				};
				rewardOffArry.push(rewardParam);
			} else if(data.RewardYn == "Y"){
				Common.Warning("<spring:message code='Cache.lbl_n_att_calculationOff'/>" + " " + "<spring:message code='Cache.msg_apv_chk_contents'/>"); // 휴무 근무 보상휴가 산정 내용이 입력되지 않았습니다.
				return;
			}
		}
		data.rewardOffArry = JSON.stringify(rewardOffArry);

		var restArry = new Array();
		for(var i=0;i<$("tr[name=restTr]").length-1;i++){
			if(
					$("tr[name=restTr]").eq(i).find("input").eq(0).val()!=""
					&&$("tr[name=restTr]").eq(i).find("input").eq(1).val()!=""
					&&$("tr[name=restTr]").eq(i).find("input").eq(2).val()!=""
					&&$("tr[name=restTr]").eq(i).find("input").eq(3).val()!=""
			){
				var rewardParam = {
					"OverTimeHour" 		:  $("tr[name=restTr]").eq(i).find("input").eq(0).val()
					,"OverTimeMin" 		:  $("tr[name=restTr]").eq(i).find("input").eq(1).val()
					,"RewardTimeHour" 	:  $("tr[name=restTr]").eq(i).find("input").eq(2).val()
					,"RewardTimeMin" 	:  $("tr[name=restTr]").eq(i).find("input").eq(3).val()
					,"HolidayFlag" : "1"
					,"RewardCode" : "rest"
				};
				restArry.push(rewardParam);
			} else if(data.RestYn == "Y"){
				Common.Warning("<spring:message code='Cache.lbl_n_att_automaticBreakTime'/>" + " " + "<spring:message code='Cache.msg_apv_chk_contents'/>"); // 자동 휴게시간 내용이 입력되지 않았습니다.
				return;
			}
		}
		data.restArry = JSON.stringify(restArry);

		var ipArry = new Array();
		for(var i=0;i<$("tr[name=ipTr]").length-1;i++){
			if(
					$("tr[name=ipTr]").eq(i).find("td").eq(0).find("input").val()!=""
					&&$("tr[name=ipTr]").eq(i).find("td").eq(1).find("input").val()!=""
			){
				var rewardParam = {
					/* "ValidYn" 	      : $("tr[name=ipTr]").eq(i).find("td").eq(0).find("a").attr("class").lastIndexOf("on")>0?"Y":"N" */
					"SIp" 		      : $("tr[name=ipTr]").eq(i).find("td").eq(0).find("input").val()
					,"EIp" 	          : $("tr[name=ipTr]").eq(i).find("td").eq(1).find("input").val()
					,"PcUsedYn" 	  : $("tr[name=ipTr]").eq(i).find("td").eq(2).find("a").attr("class").lastIndexOf("on")>0?"Y":"N"
					,"MobileUsedYn"   : $("tr[name=ipTr]").eq(i).find("td").eq(3).find("a").attr("class").lastIndexOf("on")>0?"Y":"N"
					,"Etc"            : $("tr[name=ipTr]").eq(i).find("td").eq(4).find("input").val()
				};
				ipArry.push(rewardParam);
			} else if(data.IpYn == "Y"){
				Common.Warning("<spring:message code='Cache.lbl_att_806_h_2'/>" + " " + "<spring:message code='Cache.msg_apv_chk_contents'/>"); // IP설정 내용이 입력되지 않았습니다.
				return;
			}
		}
		data.ipArry = JSON.stringify(ipArry);

		//기초설정 변경 후 CACHE초기화
		$.ajax({
			url:"/groupware/attendAdmin/setCompanySetting.do",
			type:"post",
			data:data,
			dataType:"json",
			success : function(res) {
				if (res.status == "SUCCESS") {
					Common.Confirm("<spring:message code='Cache.msg_SuccessRegist' /> <spring:message code='Cache.msg_n_att_initializeCache' />", "Confirmation Dialog", function (confirmResult) {
						if(confirmResult){
							reloadCache();
						}
					});
				}else {
					Common.Warning("<spring:message code='Cache.msg_apv_030' />"); // 오류가 발생하였습니다.
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/groupware/adminSetting/setCompanySetting.do", response, status, error);
			}
		});
	}

	function reloadCache(){
		localCache.removeAll();
		coviStorage.clear("CONFIG");

		$.ajax({
			url:"/covicore/cache/reloadCache.do",
			type:"post",
			data:{
				"replicationFlag": coviCmn.configMap["RedisReplicationMode"],
				"cacheType" : "BASECONFIG"
			},
			success: function (res) {
				Common.Inform("<spring:message code='Cache.msg_Processed' />","Information",function(){
					location.reload();
				});
			},
			error : function (error){
				alert("error : "+error);
			}
		});
	}

	function refreshList(){

	}
</script>