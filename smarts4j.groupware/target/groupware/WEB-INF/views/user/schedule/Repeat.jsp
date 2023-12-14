<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<body>	
	<div class="layer_divpop ui-draggable schResCommPopLayer" id="testpopup_p" style="width:555px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
				<div class="schResCommPopContent">
					<div class="top">
						<div class="inputBoxSytel01">
							<div><span><spring:message code='Cache.lbl_Time' /></span></div><!-- 시간 -->
							<div id="inputDateCon"></div>
						</div>
					</div>
					<div class="middle mt10">						
						<div class="inputBoxSytel01">
							<div><span><spring:message code='Cache.lbl_Setting' /></span></div><!-- 설정 -->
							<div>
								<ul id="repeatTab" class="tabMenu clearFloat">
									<li onclick="tabMenuOnClick(this);" value="D" class="active"><a><spring:message code='Cache.lbl_EveryDay' /></a></li><!-- 매일 -->
									<li onclick="tabMenuOnClick(this);" value="W" class=""><a><spring:message code='Cache.lbl_EveryWeek' /></a></li><!-- 매주 -->
									<li onclick="tabMenuOnClick(this);" value="M" class=""><a><spring:message code='Cache.lbl_EveryMonth' /></a></li><!-- 매월 -->
									<li onclick="tabMenuOnClick(this);" value="Y" class=""><a><spring:message code='Cache.lbl_EveryYear' /></a></li><!-- 매년 -->
								</ul>
								<div class="tabContent active daily">
									<div class="radioStyle04 inpBtnStyle">
										<input type="radio" id="rdoRepeatDay_day" name="rdoRepeatDay" checked="checked"><label for="rdoRepeatDay_day"><span><span></span></span><spring:message code='Cache.lbl_Every' />&nbsp;<input type="text" id="txtRepeatDay" class="HtmlCheckXSS ScriptCheckXSS" value="1" /><spring:message code='Cache.lbl_PerDay' /></label><!-- 매 ? 일마다 -->
									</div>
									<div class="radioStyle04 inpBtnStyle mt15">
										<input type="radio" id="rdoRepeatDay_all" name="rdoRepeatDay"><label for="rdoRepeatDay_all"><span><span></span></span><spring:message code='Cache.lbl_EveryDayWeekDays' /></label><!-- 매일(평일)마다 -->
									</div>
								</div>									
								<div class="tabContent  everyWeek">
									<div class="radioStyle04 inpBtnStyle">
										<spring:message code='Cache.lbl_Every' />&nbsp;<input type="text" id="txtRepeatWeek" class="HtmlCheckXSS ScriptCheckXSS" value="1" />&nbsp;<spring:message code='Cache.lbl_SchRepeatDay' /><!-- 매 ? 주마다 다음 요일에 반복 -->
									</div>
									<div class="mt5 srChkBox">
										<div class="chkStyle04 chkType01 ">
											<input type="checkbox" id="repeatWeek_Mon" name="chkRepeatWeek" value="Monday"><label for="repeatWeek_Mon"><span></span><spring:message code='Cache.lbl_Monday' /></label><!-- 월요일 -->
										</div>
										<div class="chkStyle04 chkType01 ">
											<input type="checkbox" id="repeatWeek_Tue" name="chkRepeatWeek" value="Tuesday"><label for="repeatWeek_Tue"><span></span><spring:message code='Cache.lbl_Tuesday' /></label><!-- 화요일 -->
										</div>
										<div class="chkStyle04 chkType01 ">
											<input type="checkbox" id="repeatWeek_Wed" name="chkRepeatWeek" value="Wednesday"><label for="repeatWeek_Wed"><span></span><spring:message code='Cache.lbl_Wednesday' /></label><!-- 수요일 -->
										</div>
										<div class="chkStyle04 chkType01 ">
											<input type="checkbox" id="repeatWeek_Thu" name="chkRepeatWeek" value="Thursday"><label for="repeatWeek_Thu"><span></span><spring:message code='Cache.lbl_Thursday' /></label><!-- 목요일 -->
										</div>
										<div class="chkStyle04 chkType01 ">
											<input type="checkbox" id="repeatWeek_Fri" name="chkRepeatWeek" value="Friday"><label for="repeatWeek_Fri"><span></span><spring:message code='Cache.lbl_Friday' /></label><!-- 금요일 -->
										</div>
									</div>
									<div class="srChkBox">
										<div class="chkStyle04 chkType01 ">
											<input type="checkbox" id="repeatWeek_Sat" name="chkRepeatWeek" value="Saturday"><label for="repeatWeek_Sat"><span></span><spring:message code='Cache.lbl_Saturday' /></label><!-- 토요일 -->
										</div>
										<div class="chkStyle04 chkType01 ">
											<input type="checkbox" id="repeatWeek_Sun" name="chkRepeatWeek" value="Sunday"><label for="repeatWeek_Sun"><span></span><spring:message code='Cache.lbl_Sunday' /></label><!-- 일요일 -->
										</div>
									</div>
								</div>
								<div class="tabContent  monthly">
									<div class="radioStyle04 inpBtnStyle">
										<input type="radio" id="rdoRepeatMonth_day" name="rdoRepeatMonth" checked="checked">
										<label for="rdoRepeatMonth_day"><span><span></span></span><spring:message code='Cache.lbl_date' />&nbsp;<input type="text" id="txtRepeatMonth_M" class="HtmlCheckXSS ScriptCheckXSS" value="1" /><spring:message code='Cache.lbl_MonthEvery' />&nbsp;<input type="text" id="txtRepeatMonth_D" class="HtmlCheckXSS ScriptCheckXSS" value="1" /><spring:message code='Cache.lbl_DayRepeat' /></label><!-- 날짜 ?개월마다 ?일에 -->
									</div>
									<div class="radioStyle04 inpBtnStyle mt5">
										<input type="radio" id="rdoRepeatMonth_weekofday" name="rdoRepeatMonth">
										<label for="rdoRepeatMonth_weekofday"><span><span></span></span><spring:message code='Cache.lbl_ADay' />&nbsp;<input type="text" id="txtRepeatMonth_weekofday_M" class="HtmlCheckXSS ScriptCheckXSS" value="1" /><spring:message code='Cache.lbl_MonthEvery' /></label><!-- ?요일 ?개월마다 -->
										<select id="selRepeatMonth_order" class="selectType02 " onfocus="setRdoRepeatMonth_weekofday();">
											<option value="1"><spring:message code='Cache.lbl_First' /></option><!-- 첫째 -->
											<option value="2"><spring:message code='Cache.lbl_Second' /></option><!-- 둘째 -->
											<option value="3"><spring:message code='Cache.lbl_Third' /></option><!-- 셋째 -->
											<option value="4"><spring:message code='Cache.lbl_Forth' /></option><!-- 넷째 -->
											<option value="5"><spring:message code='Cache.lbl_last' /></option><!-- 마지막 -->
										</select>
										<select id="selRepeatMonth_weekofday" class="selectType02 " onfocus="setRdoRepeatMonth_weekofday();">
											<option value="DAY"><spring:message code='Cache.lbl_Day_1' /></option><!-- 날 -->
											<option value="WEEKDAY"><spring:message code='Cache.lbl_Weekday' /></option><!-- 평일 -->
											<option value="WEEKEND"><spring:message code='Cache.lbl_Weekend' /></option><!-- 주말 -->
											<option value="SUN"><spring:message code='Cache.lbl_Sunday' /></option><!-- 일요일 -->
											<option value="MON"><spring:message code='Cache.lbl_Monday' /></option><!-- 월요일 -->
											<option value="TUE"><spring:message code='Cache.lbl_Tuesday' /></option><!-- 화요일 -->
											<option value="WED"><spring:message code='Cache.lbl_Wednesday' /></option><!-- 수요일 -->
											<option value="THU"><spring:message code='Cache.lbl_Thursday' /></option><!-- 목요일 -->
											<option value="FRI"><spring:message code='Cache.lbl_Friday' /></option><!-- 금요일 -->
											<option value="SAT"><spring:message code='Cache.lbl_Saturday' /></option><!-- 토요일 -->
										</select>
										<label for="rdoRepeatMonth_weekofday"><spring:message code='Cache.lbl_DayRepeat_1' /></label><!-- 에 -->
									</div>
								</div>
								<div class="tabContent  yearly">
									<div><spring:message code='Cache.lbl_Every' />&nbsp;<input type="text" id="txtRepeatYear" class="HtmlCheckXSS ScriptCheckXSS" value="1" />&nbsp;<spring:message code='Cache.lbl_Peryear' /></div><!-- 매 ? 년마다 -->
									<div class="radioStyle04 inpBtnStyle mt10">
										<input type="radio" id="rdoRepeatYear_day" name="rdoRepeatYear" checked="checked">
										<label for="rdoRepeatYear_day"><span><span></span></span><spring:message code='Cache.lbl_date' /> </label><!-- 날짜 -->
										<select id="selRepeatYear_day_M" class="selectType02" onfocus="setRdoRepeatYear_day();">
											<option value="1"><spring:message code='Cache.lbl_Month_1' /></option><!-- 1월 -->
											<option value="2"><spring:message code='Cache.lbl_Month_2' /></option><!-- 2월 -->
											<option value="3"><spring:message code='Cache.lbl_Month_3' /></option><!-- 3월 -->
											<option value="4"><spring:message code='Cache.lbl_Month_4' /></option><!-- 4월 -->
											<option value="5"><spring:message code='Cache.lbl_Month_5' /></option><!-- 5월 -->
											<option value="6"><spring:message code='Cache.lbl_Month_6' /></option><!-- 6월 -->
											<option value="7"><spring:message code='Cache.lbl_Month_7' /></option><!-- 7월 -->
											<option value="8"><spring:message code='Cache.lbl_Month_8' /></option><!-- 8월 -->
											<option value="9"><spring:message code='Cache.lbl_Month_9' /></option><!-- 9월 -->
											<option value="10"><spring:message code='Cache.lbl_Month_10' /></option><!-- 10월 -->
											<option value="11"><spring:message code='Cache.lbl_Month_11' /></option><!-- 11월 -->
											<option value="12"><spring:message code='Cache.lbl_Month_12' /></option><!-- 12월 -->
										</select>
										<label for="rdoRepeatYear_day"><input type="text" id="txtRepeatYear_D" class="HtmlCheckXSS ScriptCheckXSS" value="1" /><spring:message code='Cache.lbl_DayRepeat' /></label><!-- 일에 -->
									</div>
									<div class="radioStyle04 inpBtnStyle mt5">
										<input type="radio" id="rdoRepeatYear_weekofday" name="rdoRepeatYear">
										<label for="rdoRepeatYear_weekofday"><span><span></span></span><spring:message code='Cache.lbl_ADay' />&nbsp;</label><!-- 요일 -->
										<select id="selRepeatYear_weekofday_M" class="selectType02" onfocus="setRdoRepeatYear_weekofday();">
											<option value="1"><spring:message code='Cache.lbl_Month_1' /></option><!-- 1월 -->
											<option value="2"><spring:message code='Cache.lbl_Month_2' /></option><!-- 2월 -->
											<option value="3"><spring:message code='Cache.lbl_Month_3' /></option><!-- 3월 -->
											<option value="4"><spring:message code='Cache.lbl_Month_4' /></option><!-- 4월 -->
											<option value="5"><spring:message code='Cache.lbl_Month_5' /></option><!-- 5월 -->
											<option value="6"><spring:message code='Cache.lbl_Month_6' /></option><!-- 6월 -->
											<option value="7"><spring:message code='Cache.lbl_Month_7' /></option><!-- 7월 -->
											<option value="8"><spring:message code='Cache.lbl_Month_8' /></option><!-- 8월 -->
											<option value="9"><spring:message code='Cache.lbl_Month_9' /></option><!-- 9월 -->
											<option value="10"><spring:message code='Cache.lbl_Month_10' /></option><!-- 10월 -->
											<option value="11"><spring:message code='Cache.lbl_Month_11' /></option><!-- 11월 -->
											<option value="12"><spring:message code='Cache.lbl_Month_12' /></option><!-- 12월 -->
										</select>
										<select id="selRepeatYear_weekofday_order"  class="selectType02 " onfocus="setRdoRepeatYear_weekofday();">
											<option value="1"><spring:message code='Cache.lbl_First' /></option><!-- 첫째 -->
											<option value="2"><spring:message code='Cache.lbl_Second' /></option><!-- 둘째 -->
											<option value="3"><spring:message code='Cache.lbl_Third' /></option><!-- 셋째 -->
											<option value="4"><spring:message code='Cache.lbl_Forth' /></option><!-- 넷째 -->
											<option value="5"><spring:message code='Cache.lbl_last' /></option><!-- 마지막 -->
										</select>
										<select id="selRepeatYear_weekofday" class="selectType02 " onfocus="setRdoRepeatYear_weekofday();">
											<option value="DAY"><spring:message code='Cache.lbl_Day_1' /></option><!-- 날 -->
											<option value="WEEKDAY"><spring:message code='Cache.lbl_Weekday' /></option><!-- 평일 -->
											<option value="WEEKEND"><spring:message code='Cache.lbl_Weekend' /></option><!-- 주말 -->
											<option value="SUN"><spring:message code='Cache.lbl_Sunday' /></option><!-- 일요일 -->
											<option value="MON"><spring:message code='Cache.lbl_Monday' /></option><!-- 월요일 -->
											<option value="TUE"><spring:message code='Cache.lbl_Tuesday' /></option><!-- 화요일 -->
											<option value="WED"><spring:message code='Cache.lbl_Wednesday' /></option><!-- 수요일 -->
											<option value="THU"><spring:message code='Cache.lbl_Thursday' /></option><!-- 목요일 -->
											<option value="FRI"><spring:message code='Cache.lbl_Friday' /></option><!-- 금요일 -->
											<option value="SAT"><spring:message code='Cache.lbl_Saturday' /></option><!-- 토요일 -->
										</select>
										<label for="rdoRepeatYear_weekofday"><spring:message code='Cache.lbl_DayRepeat_1' /></label><!-- 에 -->
									</div>
								</div>
							</div>
						</div>
						<div class="inputBoxSytel01">
							<div><span><spring:message code='Cache.lbl_RepetitionRange' /></span></div><!-- 반복범위 -->
							<div>
								<div class="repetitionCont">
									<div class="dateSel type02 clearFloat">
										<div><spring:message code='Cache.lbl_startdate' /></div><!-- 시작일 -->
										<div class="ml10">
											<input class="adDate" id="StartDate" date_separator="." vali_early="true" vali_date_id="EndDate" kind="date" type="text" data-axbind="date">
										</div>
									</div>
									<div>
										<div class="dateSel type02 clearFloat">
											<div class="radioStyle04 inpBtnStyle">
												<input type="radio" id="rdoRepeatEndDate" name="rdAlle" onclick="javascript:setEnd(this);" value="date"><label for="rdoRepeatEndDate"><span><span></span></span><spring:message code='Cache.lbl_EndDate' /></label><!-- 종료일 -->
											</div>
											<div class="ml10"><input class="adDate" id="EndDate" date_separator="." vali_late="true" vali_date_id="StartDate" kind="date" type="text" data-axbind="date" disabled></div>
										</div>
										<div class="radioStyle04 inpBtnStyle mt10">
											<input type="radio" id="rdoRepeatEndCount" name="rdAlle" checked="checked" onclick="javascript:setEnd(this);" value="count"><label for="rdoRepeatEndCount"><span><span></span></span><input type="text" id="txtRepeatEndCount" class="HtmlCheckXSS ScriptCheckXSS" value="5" />&nbsp;<spring:message code='Cache.lbl_repeatCount' /></label><!-- 회 반복 후 끝냄 -->
										</div>
									</div>
								</div>
							</div>
						</div>
					</div>
					<div class="bottom mt20">
						<a onclick="setRepeatData();" class="btnTypeDefault btnTypeBg"><spring:message code='Cache.btn_Confirm' /><!-- 확인 --></a><a onclick="Common.Close();" class="btnTypeDefault"><spring:message code='Cache.btn_Cancel' /><!-- 취소 --></a><a id="aRemoveBtn" onclick="removeRepeatInfo();" class="btnTypeDefault"><spring:message code='Cache.lbl_RepeatRemoval' /><!-- 반복제거 --></a>
					</div>
				</div>
			</div>
		</div>	
	</div>
</body>
<script>

initPopup();

function initPopup(){
	
	target = 'inputDateCon';
	var timeInfos = {
			width : "80",
			H : "1,2,3,4,5,6,7,8,9,10,11",
			W : "", //주 선택
			M : "", //달 선택
			Y : "" //년도 선택
		};
	
	var initInfos = {
			useCalendarPicker : 'N',
			useTimePicker : 'Y',
			useBar : 'Y',
			useSeparation : 'Y',
			minuteInterval : 5,  //TODO 만약, 60의 약수가 아닌 경우, 그려지지 않음.
			timePickerwidth : '50',
			height : '200',
			use59 : 'Y',
			changeTarget : 'endtime'	// bugfix : 반복일정에서 데이터값을 '분' 단위로 변경되지 않아 발생한 이슈 수정
		};
	
	coviCtrl.renderDateSelect(target, timeInfos, initInfos);
	//$("#"+target).find("[name=endDate]").find("select").append('<option value="23:59" data-code="23:59" data-codename="23:59">23:59</option>');
	
	setRepeatDefaultData();
}

// 기존 값 세팅
function setRepeatDefaultData(){
	//$("#inputDateCon select").css("width", "38px");
	
	var repeatInfoObj = null;
	var repeatInfoStr = parent.$("#hidRepeatInfo").val();
	
	if(repeatInfoStr != ""){
		repeatInfoObj =  $$($.parseJSON(repeatInfoStr)).find("ResourceRepeat");
	}
	
	if(repeatInfoObj == null || repeatInfoObj.isEmpty()){
		$("#aRemoveBtn").hide();
		
		//사용자 값 세팅
		var sHour = parent.coviCtrl.getSelected('detailDateCon [name=startHour]').val;
		var sMin = parent.coviCtrl.getSelected('detailDateCon [name=startMinute]').val;
		var eHour = parent.coviCtrl.getSelected('detailDateCon [name=endHour]').val;
		var eMin = parent.coviCtrl.getSelected('detailDateCon [name=endMinute]').val;
		
		sHour = isNaN(parseInt(sHour)) ? "00" : sHour;
		sMin = isNaN(parseInt(sMin)) ? "00" : sMin;
		eHour = isNaN(parseInt(eHour)) ? "00" : eHour;
		eMin = isNaN(parseInt(eMin)) ? "00" : eMin;
		
		
		coviCtrl.setSelected('inputDateCon [name=startHour]', sHour);
		coviCtrl.setSelected('inputDateCon [name=startMinute]', sMin);
		coviCtrl.setSelected('inputDateCon [name=endHour]', eHour);
		coviCtrl.setSelected('inputDateCon [name=endMinute]', eMin);
			
		coviCtrl.setSelected('inputDateCon [name=datePicker]', "select");
		
		var tempStartDate = parent.$("#detailDateCon_StartDate").val();
		var tempEndMonth = (Number(parent.$("#detailDateCon_EndDate").val().split(".")[1])+1) % 12;
		var tempEndYear = tempEndMonth > 0 ? Number(parent.$("#detailDateCon_EndDate").val().split(".")[0])+1 : parent.$("#detailDateCon_EndDate").val().split(".")[0];
		
		var tempEndDate = new Date(); 
		
		if(!isNaN(tempEndMonth))
			tempEndDate = new Date(tempEndYear + "/" + (tempEndMonth == 0 ? 12 : tempEndMonth) + "/" + parent.$("#detailDateCon_EndDate").val().split(".")[2]);
		else 
			tempEndDate.setDate(tempEndDate.getDate() + 7);
		
		if(tempStartDate == "")
			tempStartDate = parent.schedule_SetDateFormat(new Date(), ".");
		
		$("#StartDate").val(tempStartDate);
		$("#EndDate").val(parent.schedule_SetDateFormat(tempEndDate, "."));
		$("#EndDate").prop("disabled", true);
		
		tabMenuOnClick($("#repeatTab li[value=W]"));
	}else{
		$("#aRemoveBtn").show();

        var sAppointmentStartTime = $$(repeatInfoObj).attr("AppointmentStartTime");
        var sAppointmentEndTime = $$(repeatInfoObj).attr("AppointmentEndTime");
        var sAppointmentDuring = $$(repeatInfoObj).attr("AppointmentDuring");
        var sRepeatAppointType = $$(repeatInfoObj).attr("RepeatAppointType");
        var sRepeatType = $$(repeatInfoObj).attr("RepeatType");
        var sRepeatYear = $$(repeatInfoObj).attr("RepeatYear");
        var sRepeatMonth = $$(repeatInfoObj).attr("RepeatMonth");
        var sRepeatWeek = $$(repeatInfoObj).attr("RepeatWeek");
        var sRepeatDay = $$(repeatInfoObj).attr("RepeatDay");
        var sRepeatMonday = $$(repeatInfoObj).attr("RepeatMonday");
        var sRepeatTuesday = $$(repeatInfoObj).attr("RepeatTuesday");
        var sRepeatWednseday = $$(repeatInfoObj).attr("RepeatWednseday");
        var sRepeatThursday = $$(repeatInfoObj).attr("RepeatThursday");
        var sRepeatFriday = $$(repeatInfoObj).attr("RepeatFriday");
        var sRepeatSaturday = $$(repeatInfoObj).attr("RepeatSaturday");
        var sRepeatSunday = $$(repeatInfoObj).attr("RepeatSunday");
        var sRepeatStartDate = $$(repeatInfoObj).attr("RepeatStartDate");		//XFN_TransDateLocalFormat($$(repeatInfoObj).attr("RepeatStartDate"));
        var sRepeatEndType = $$(repeatInfoObj).attr("RepeatEndType");
        var sRepeatEndDate = $$(repeatInfoObj).attr("RepeatEndDate");			//XFN_TransDateLocalFormat($$(repeatInfoObj).attr("RepeatEndDate"));
        var sRepeatCount = $$(repeatInfoObj).attr("RepeatCount");

		coviCtrl.setSelected('inputDateCon [name=startHour]', sAppointmentStartTime.split(":")[0]);
		coviCtrl.setSelected('inputDateCon [name=startMinute]', sAppointmentStartTime.split(":")[1]);
		coviCtrl.setSelected('inputDateCon [name=endHour]', sAppointmentEndTime.split(":")[0]);
		coviCtrl.setSelected('inputDateCon [name=endMinute]', sAppointmentEndTime.split(":")[1]);
        
        
        // bugfix : 반복일정에서 데이터값을 '분' 단위로 변경되지 않아 발생한 이슈 수정
        //coviCtrl.setSelected('inputDateCon [name=datePicker]', (sAppointmentDuring == "" || sAppointmentDuring == "0" || sAppointmentDuring == null ? "select" : sAppointmentDuring));
		var selectedDuringData = "select";
		if(sAppointmentDuring !== "" && sAppointmentDuring !== "0" && sAppointmentDuring !== null) {
			selectedDuringData = sAppointmentDuring;
			if(sAppointmentDuring.indexOf('H') == -1) {
				selectedDuringData = parseInt(Number(sAppointmentDuring) / 60) + 'H';
			}
		}

		$('#inputDateCon [name=datePicker] select').val(selectedDuringData);
        	
        switch (sRepeatType.toUpperCase()) {
            case "D":
                if (sRepeatDay == "0") {
                    $("#rdoRepeatDay_day").prop("checked", false);
                    $("#rdoRepeatDay_all").prop("checked", true);
                }
                else {
                    $("#txtRepeatDay").val(sRepeatDay);
                    $("#rdoRepeatDay_all").prop("checked", false);
                    $("#rdoRepeatDay_day").prop("checked", true);
                }
                break;
            case "W":
                $("#txtRepeatWeek").val(sRepeatWeek);
                if (sRepeatMonday == "Y") { $("#repeatWeek_Mon").prop("checked", true); } else { $("#repeatWeek_Mon").prop("checked", false); }
                if (sRepeatTuesday == "Y") { $("#repeatWeek_Tue").prop("checked", true); } else { $("#repeatWeek_Tue").prop("checked", false); }
                if (sRepeatWednseday == "Y") { $("#repeatWeek_Wed").prop("checked", true); } else { $("#repeatWeek_Wed").prop("checked", false); }
                if (sRepeatThursday == "Y") { $("#repeatWeek_Thu").prop("checked", true); } else { $("#repeatWeek_Thu").prop("checked", false); }
                if (sRepeatFriday == "Y") { $("#repeatWeek_Fri").prop("checked", true); } else { $("#repeatWeek_Fri").prop("checked", false); }
                if (sRepeatSaturday == "Y") { $("#repeatWeek_Sat").prop("checked", true); } else { $("#repeatWeek_Sat").prop("checked", false); }
                if (sRepeatSunday == "Y") { $("#repeatWeek_Sun").prop("checked", true); } else { $("#repeatWeek_Sun").prop("checked", false); }
                break;
            case "M":
                if (sRepeatDay != "0") {
                	if (sRepeatAppointType == 'B') {
                		 $("#rdoRepeatMonth_day").prop("checked", false);
                         $("#rdoRepeatMonth_weekofday").prop("checked", true);
                         $("#selRepeatMonth_order").val((sRepeatWeek == '5') ? sRepeatWeek : sRepeatDay);
                         $("#selRepeatMonth_weekofday").val('DAY');
                	}
                	else {
                		 $("#rdoRepeatMonth_weekofday").prop("checked", false);
                         $("#rdoRepeatMonth_day").prop("checked", true);
                         $("#txtRepeatMonth_M").val(sRepeatMonth);
                         $("#txtRepeatMonth_D").val(sRepeatDay);
                	}
                }
                else {
                    $("#rdoRepeatMonth_day").prop("checked", false);
                    $("#rdoRepeatMonth_weekofday").prop("checked", true);
                    $("#txtRepeatMonth_weekofday_M").val(sRepeatMonth);
                    $("#selRepeatMonth_order").val(sRepeatWeek);
                    
                    if ((sRepeatMonday == "Y") && (sRepeatTuesday == "Y") && (sRepeatWednseday == "Y") && (sRepeatThursday == "Y") && (sRepeatFriday == "Y") && (sRepeatSaturday != "Y") && (sRepeatSunday != "Y")) { sTemp = "WEEKDAY"; }
                    else if ((sRepeatMonday != "Y") && (sRepeatTuesday != "Y") && (sRepeatWednseday != "Y") && (sRepeatThursday != "Y") && (sRepeatFriday != "Y") && (sRepeatSaturday == "Y") && (sRepeatSunday == "Y")) { sTemp = "WEEKEND"; }
                    else if (sRepeatMonday == "Y") { sTemp = "MON"; }
                    else if (sRepeatTuesday == "Y") { sTemp = "TUE"; }
                    else if (sRepeatWednseday == "Y") { sTemp = "WED"; }
                    else if (sRepeatThursday == "Y") { sTemp = "THU"; }
                    else if (sRepeatFriday == "Y") { sTemp = "FRI"; }
                    else if (sRepeatSaturday == "Y") { sTemp = "SAT"; }
                    else if (sRepeatSunday == "Y") { sTemp = "SUN"; }
                    else { sTemp = "DAY"; }
                    $("#selRepeatMonth_weekofday").val(sTemp);
                }
                break;
            case "Y":
                $("#txtRepeatYear").val(sRepeatYear);
                if (sRepeatDay != "0") {
                    $("#rdoRepeatYear_weekofday").prop("checked", false);
                    $("#rdoRepeatYear_day").prop("checked", true);
                    $("#selRepeatYear_day_M").val(sRepeatMonth);
                    $("#txtRepeatYear_D").val(sRepeatDay);
                }
                else {
                    $("#rdoRepeatYear_day").prop("checked", false);
                    $("#rdoRepeatYear_weekofday").prop("checked", true);
                    $("#selRepeatYear_weekofday_M").val(sRepeatMonth);
                    $("#selRepeatYear_weekofday_order").val(sRepeatWeek);
                    if ((sRepeatMonday == "Y") && (sRepeatTuesday == "Y") && (sRepeatWednseday == "Y") && (sRepeatThursday == "Y") && (sRepeatFriday == "Y") && (sRepeatSaturday != "Y") && (sRepeatSunday != "Y")) { sTemp = "WEEKDAY"; }
                    else if ((sRepeatMonday != "Y") && (sRepeatTuesday != "Y") && (sRepeatWednseday != "Y") && (sRepeatThursday != "Y") && (sRepeatFriday != "Y") && (sRepeatSaturday == "Y") && (sRepeatSunday == "Y")) { sTemp = "WEEKEND"; }
                    else if (sRepeatMonday == "Y") { sTemp = "MON"; }
                    else if (sRepeatTuesday == "Y") { sTemp = "TUE"; }
                    else if (sRepeatWednseday == "Y") { sTemp = "WED"; }
                    else if (sRepeatThursday == "Y") { sTemp = "THU"; }
                    else if (sRepeatFriday == "Y") { sTemp = "FRI"; }
                    else if (sRepeatSaturday == "Y") { sTemp = "SAT"; }
                    else if (sRepeatSunday == "Y") { sTemp = "SUN"; }
                    else { sTemp = "DAY"; }
                    $("#selRepeatYear_weekofday").val(sTemp);
                }
                break;
        }
        $("#StartDate").val(sRepeatStartDate);

        if (sRepeatEndType == "I") {
            $("#rdoRepeatEndCount").prop("checked", false);
            $("#rdoRepeatEndDate").prop("checked", true);
			$("#EndDate").val(sRepeatEndDate);
        }
        else if (sRepeatEndType == "R") {
            $("#rdoRepeatEndDate").prop("checked", false);
            $("#rdoRepeatEndCount").prop("checked", true);
            $("#EndDate").val(sRepeatEndDate);
            $("#txtRepeatEndCount").val(sRepeatCount);
        } else {
        	$("#EndDate").val(sRepeatEndDate);
        }
        
        if(sRepeatType) tabMenuOnClick($("#repeatTab li[value="+sRepeatType+"]"));
	}
}

function tabMenuOnClick(obj){
	$('.tabMenu>li').removeClass('active');
	$('.tabContent').removeClass('active');
	$(obj).addClass('active');
	$('.tabContent').eq($(obj).index()).addClass('active');
}

// 반복 데이터 세팅
function setRepeatData(){
	var sCheckMessage = checkRepeatDataValidation();

	if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

	if (sCheckMessage != "") {
        var sMessage = sCheckMessage.split("|")[0];
        var sControlID = "";
        if (sCheckMessage.split("|").length > 1) {
            sControlID = sCheckMessage.split("|")[1];
        }
        parent.Common.Warning(sMessage, "Warning", function () {
            if (sControlID != "") {
                $("#" + sControlID).focus();
            }
        });
        return;
    }
    var sResult = getRepeatData();
    
    if(CFN_GetQueryString("CLBIZ") == "Schedule"){
    	parent.scheduleUser.callBackRepeatSetting(JSON.stringify(sResult));
    }
    else if(CFN_GetQueryString("CLBIZ") == "Resource"){
    	parent.resourceUser.callBackRepeatSetting(JSON.stringify(sResult));
    }
    Common.Close();
}

// 반복 제거
function removeRepeatInfo(){
	if(CFN_GetQueryString("CLBIZ") == "Schedule"){
    	parent.scheduleUser.callBackRepeatSetting();
    }
    else if(CFN_GetQueryString("CLBIZ") == "Resource"){
    	parent.resourceUser.callBackRepeatSetting();
    }
	Common.Close();
}

// 확인 버튼시 Validation Check
function checkRepeatDataValidation() {
	var sRepeatType = "";
	$("#repeatTab>li").each(function () {
		if ($(this).hasClass("active")) {
			sRepeatType = $(this).attr("value");
		}
	});
	
	var nRepeatValue = 0;
	switch (sRepeatType.toUpperCase()) {
	case "D":
		if ($("#rdoRepeatDay_day").is(":checked")) {
			// 매 n일
			if ((isNaN(new Number($("#txtRepeatDay").val()))) || ($("#txtRepeatDay").val() == "") || ($("#txtRepeatDay").val() == "0")) {
				return "<spring:message code='Cache.msg_RepeatSetting_01'/>"+"|txtRepeatDay";		// 반복설정의 반복 일을 입력하여 주십시오.
			}
		}
		break;
	case "W":
		if ((isNaN(new Number($("#txtRepeatWeek").val()))) || ($("#txtRepeatWeek").val() == "") || ($("#txtRepeatWeek").val() == "0")) {
			return "<spring:message code='Cache.msg_RepeatSetting_04'/>"+"|txtRepeatWeek";			// 반복설정의 반복 주를 입력하여 주십시오.
		}
		if ($("input[name=chkRepeatWeek]:checked").length <= 0) {
			return "<spring:message code='Cache.msg_RepeatSetting_05'/>";										// 반복설정의 반복 요일을 선택하여 주십시오.
		}
		break;
    case "M":
    	if ($("#rdoRepeatMonth_day").is(":checked")) {
    		// 날짜
    		if ((isNaN(new Number($("#txtRepeatMonth_M").val()))) || ($("#txtRepeatMonth_M").val() == "") || ($("#txtRepeatMonth_M").val() == "0")) {
    			return "<spring:message code='Cache.msg_RepeatSetting_06'/>"+"|txtRepeatMonth_M";		// 반복설정의 반복 월을 입력하여 주십시오.
            }
    		if ((isNaN(new Number($("#txtRepeatMonth_D").val()))) || ($("#txtRepeatMonth_D").val() == "") || ($("#txtRepeatMonth_D").val() == "0")) {
    			return "<spring:message code='Cache.msg_RepeatSetting_01'/>"+"|txtRepeatMonth_D";		// 반복설정의 반복 일을 입력하여 주십시오.
    		}
    	}
    	else {
    		// 요일
    		if ((isNaN(new Number($("#txtRepeatMonth_weekofday_M").val()))) || ($("#txtRepeatMonth_weekofday_M").val() == "") || ($("#txtRepeatMonth_weekofday_M").val() == "0")) {
    			return "<spring:message code='Cache.msg_RepeatSetting_06'/>"+"|txtRepeatMonth_weekofday_M";		// 반복설정의 반복 월을 입력하여 주십시오.
    		}
    	}
    	break;
    case "Y":
    	if ((isNaN(new Number($("#txtRepeatYear").val()))) || ($("#txtRepeatYear").val() == "") || ($("#txtRepeatYear").val() == "0")) {
    		return "<spring:message code='Cache.msg_RepeatSetting_07'/>"+"|txtRepeatYear";			// 반복설정의 반복 년을 입력하여 주십시오.
    	}
    	if ($("#rdoRepeatYear_day").is(":checked")) {
    		// 날짜
    		if ((isNaN(new Number($("#txtRepeatYear_D").val()))) || ($("#txtRepeatYear_D").val() == "") || ($("#txtRepeatYear_D").val() == "0")) {
    			return "<spring:message code='Cache.msg_RepeatSetting_01'/>"+"|txtRepeatYear_D";		// 반복설정의 반복 일을 입력하여 주십시오.
    		}
    	}
    	break;
    }
	
	if ($("#rdoRepeatEndCount").is(":checked")) {
		if ((isNaN(new Number($("#txtRepeatEndCount").val()))) || ($("#txtRepeatEndCount").val() == "") || ($("#txtRepeatEndCount").val() == "0")) {
			return "<spring:message code='Cache.msg_RepeatSetting_09'/>"+"|txtRepeatEndCount";					// 반복범위 설정이 잘 못 되었습니다. 반복 횟수를 확인하여 주십시오.
		}
		
		var RepeatCount = Number(Common.getBaseConfig("RpeatCount"));
		RepeatCount = RepeatCount ? RepeatCount : 100;
		if ($("#txtRepeatEndCount").val() > RepeatCount){
			return String.format("<spring:message code='Cache.msg_ValidRepeatCount'/>", RepeatCount)+"|txtRepeatEndCount";					// 설정된 최대 반복 횟수를 초과했습니다. </br> 반복 횟수를 확인하여 주십시오. </br> 최대 반복 횟수: {0}
		}
	}
	
	// 2022.04.11 event_calendar.js range check의 규칙을 적용
	var sYear = Number($("#StartDate").val().substring(0,4));
	if (sYear < 1940 || sYear > 2040) {
		return Common.getDic('msg_DateRange')+"|StartDate";
	}
	
	var eYear = Number($("#EndDate").val().substring(0,4));
	if ((eYear < 1940 || eYear > 2040) && $("input[type=radio][name=rdAlle]:checked").attr("id") == "rdoRepeatEndDate") {
		return Common.getDic('msg_DateRange')+"|EndDate";
	}
	
	return "";
}

function getRepeatData(){
	var sTemp = "";
	var sAppointmentStartTime = "00:00";
	var sAppointmentEndTime = "00:30";
	var sAppointmentDuring = "30";
	var sRepeatType = "D";
	var sRepeatYear = "0";
	var sRepeatMonth = "0";
	var sRepeatWeek = "0";
	var sRepeatDay = "1";
	var sRepeatMonday = "N";
	var sRepeatTuesday = "N";
	var sRepeatWednseday = "N";
	var sRepeatThursday = "N";
	var sRepeatFriday = "N";
	var sRepeatSaturday = "N";
	var sRepeatSunday = "N";
	var sRepeatStartDate = "1900.01.01";
	var sRepeatEndType = "R";
	var sRepeatEndDate = "2100.12.31";
	var sRepeatCount = "0";
	
	sAppointmentStartTime = coviCtrl.getSelected('inputDateCon [name=startHour]').val + ":" + coviCtrl.getSelected('inputDateCon [name=startMinute]').val;
	sAppointmentEndTime = coviCtrl.getSelected('inputDateCon [name=endHour]').val + ":" + coviCtrl.getSelected('inputDateCon [name=endMinute]').val;
	sAppointmentDuring = coviCtrl.getSelected('inputDateCon [name=datePicker]').val == "select" ? "0" : coviCtrl.getSelected('inputDateCon [name=datePicker]').val;
	
	$("#repeatTab>li").each(function () {
		if ($(this).hasClass("active")) {
			sRepeatType = $(this).attr("value");
		}
	});
	
	switch (sRepeatType.toUpperCase()) {
	case "D":
		if ($("#rdoRepeatDay_day").is(":checked")) {
			sRepeatDay = $("#txtRepeatDay").val();
		}
		else {
			sRepeatDay = "0";
			sRepeatMonday = "Y";
			sRepeatTuesday = "Y";
			sRepeatWednseday = "Y";
			sRepeatThursday = "Y";
			sRepeatFriday = "Y";
		}
		break;
	case "W":
		sRepeatWeek = $("#txtRepeatWeek").val();
		if ($("#repeatWeek_Sun").is(":checked")) { sRepeatSunday = "Y"; }
		if ($("#repeatWeek_Mon").is(":checked")) { sRepeatMonday = "Y"; }
		if ($("#repeatWeek_Tue").is(":checked")) { sRepeatTuesday = "Y"; }
		if ($("#repeatWeek_Wed").is(":checked")) { sRepeatWednseday = "Y"; }
		if ($("#repeatWeek_Thu").is(":checked")) { sRepeatThursday = "Y"; }
		if ($("#repeatWeek_Fri").is(":checked")) { sRepeatFriday = "Y"; }
		if ($("#repeatWeek_Sat").is(":checked")) { sRepeatSaturday = "Y"; }
		break;
	case "M":
		if ($("#rdoRepeatMonth_day").is(":checked")) {
			sRepeatMonth = $("#txtRepeatMonth_M").val();
			sRepeatDay = $("#txtRepeatMonth_D").val();
		}
		else {
			sRepeatMonth = $("#txtRepeatMonth_weekofday_M").val();
			sRepeatWeek = $("#selRepeatMonth_order option:selected").val();
			sRepeatDay = "0";
			
			sTemp = $("#selRepeatMonth_weekofday option:selected").val();
			switch (sTemp.toUpperCase()) {
			case "DAY":
				if ($("#selRepeatMonth_order").val() != "5") {
					sRepeatWeek = "0";
					//sRepeatDay = $("#txtRepeatMonth_weekofday_M").val();
					sRepeatDay = $("#selRepeatMonth_order").val();
				}
				break;
			case "WEEKDAY":
				sRepeatMonday = "Y";
				sRepeatTuesday = "Y";
				sRepeatWednseday = "Y";
				sRepeatThursday = "Y";
				sRepeatFriday = "Y";
				break;
			case "WEEKEND":
				sRepeatSunday = "Y";
				sRepeatSaturday = "Y";
				break;
			case "SUN":
				sRepeatSunday = "Y";
				break;
			case "MON":
				sRepeatMonday = "Y";
				break;
			case "TUE":
				sRepeatTuesday = "Y";
				break;
			case "WED":
				sRepeatWednseday = "Y";
				break;
			case "THU":
				sRepeatThursday = "Y";
				break;
			case "FRI":
				sRepeatFriday = "Y";
				break;
			case "SAT":
				sRepeatSaturday = "Y";
				break;
			}
		}
		break;
	case "Y":
		sRepeatYear = $("#txtRepeatYear").val();
		if ($("#rdoRepeatYear_day").is(":checked")) {
			sRepeatMonth = $("#selRepeatYear_day_M").val();
			sRepeatWeek = "0";
			sRepeatDay = $("#txtRepeatYear_D").val();
		}
		else {
			sRepeatMonth = $("#selRepeatYear_weekofday_M").val();
			sRepeatWeek = $("#selRepeatYear_weekofday_order").val();
			sRepeatDay = "0";
			
			sTemp = $("#selRepeatYear_weekofday").val();
			switch (sTemp.toUpperCase()) {
			case "DAY":
				if ($("#selRepeatYear_weekofday_order").val() != "5") {
					sRepeatWeek = "0";
					sRepeatDay = $("#selRepeatYear_weekofday_order").val();
				}
				break;
			case "WEEKDAY":
				sRepeatMonday = "Y";
				sRepeatTuesday = "Y";
				sRepeatWednseday = "Y";
				sRepeatThursday = "Y";
				sRepeatFriday = "Y";
				break;
			case "WEEKEND":
				sRepeatSunday = "Y";
				sRepeatSaturday = "Y";
				break;
			case "SUN":
				sRepeatSunday = "Y";
				break;
			case "MON":
				sRepeatMonday = "Y";
				break;
			case "TUE":
				sRepeatTuesday = "Y";
				break;
			case "WED":
				sRepeatWednseday = "Y";
				break;
			case "THU":
				sRepeatThursday = "Y";
				break;
			case "FRI":
				sRepeatFriday = "Y";
				break;
			case "SAT":
				sRepeatSaturday = "Y";
				break;
			}
		}
		break;
	}
	
	sRepeatStartDate = $("#StartDate").val().replaceAll(".", "-");		//XFN_TransDateServerFormat($("#StartDate").val());
	sRepeatEndDate = $("#EndDate").val().replaceAll(".", "-");		//XFN_TransDateServerFormat($("#EndDate").val());
	
	if ($("#rdoRepeatEndDate").is(":checked")) {
		sRepeatEndType = "I";
	}
	else if ($("#rdoRepeatEndCount").is(":checked")) {
		sRepeatEndType = "R";
		sRepeatCount = $("#txtRepeatEndCount").val();
	}
	else {
		sRepeatEndType = "";
	}
	
	var sRepeatAppointType = "";
	var sRepetitionPerAtt = 0;
	
	if(sRepeatType == "D"){
		sRepeatAppointType = $("#rdoRepeatDay_day").is(":checked") ? "A" : "B";
		sRepetitionPerAtt = $("#txtRepeatDay").val();
	}else if(sRepeatType == "W"){
		sRepetitionPerAtt = $("#txtRepeatWeek").val();
	}else if(sRepeatType == "M"){
		sRepeatAppointType = $("#rdoRepeatMonth_day").is(":checked") ? "A" : "B";
	}else if(sRepeatType == "Y"){
		sRepetitionPerAtt = $("#txtRepeatYear").val();
		sRepeatAppointType = $("#rdoRepeatYear_day").is(":checked") ? "A" : "B";
	}
	
	var returnObj = {};
	var resourceRepeatObj = {};
	
	resourceRepeatObj.AppointmentStartTime = sAppointmentStartTime;
	resourceRepeatObj.AppointmentEndTime = sAppointmentEndTime;
	resourceRepeatObj.AppointmentDuring = sAppointmentDuring;
	
	resourceRepeatObj.RepeatType = sRepeatType;
	resourceRepeatObj.RepeatYear = sRepeatYear;
	resourceRepeatObj.RepeatMonth = sRepeatMonth;
	resourceRepeatObj.RepeatWeek = sRepeatWeek;
	resourceRepeatObj.RepeatDay = sRepeatDay;
	
	resourceRepeatObj.RepeatMonday = sRepeatMonday;
	resourceRepeatObj.RepeatTuesday = sRepeatTuesday;
	resourceRepeatObj.RepeatWednseday = sRepeatWednseday;
	resourceRepeatObj.RepeatThursday = sRepeatThursday;
	resourceRepeatObj.RepeatFriday = sRepeatFriday;
	resourceRepeatObj.RepeatSaturday = sRepeatSaturday;
	resourceRepeatObj.RepeatSunday = sRepeatSunday;
	
	resourceRepeatObj.RepeatStartDate = sRepeatStartDate;
	resourceRepeatObj.RepeatEndType = sRepeatEndType;
	resourceRepeatObj.RepeatEndDate = sRepeatEndDate;
	resourceRepeatObj.RepeatCount = sRepeatCount;
	
	resourceRepeatObj.RepeatAppointType = sRepeatAppointType;
	resourceRepeatObj.RepetitionPerAtt = sRepetitionPerAtt;
	
	returnObj.ResourceRepeat = resourceRepeatObj;
	
	return returnObj;
}

//IE 에서 label 태그안에 select box를 넣을 경우, 값을 지정할 수 없으므로 onclick으로 변경
function setRdoRepeatMonth_weekofday(){
	$("#rdoRepeatMonth_day").prop("checked", false);
    $("#rdoRepeatMonth_weekofday").prop("checked", true);
}
function setRdoRepeatYear_day(){
	$("#rdoRepeatYear_weekofday").prop("checked", false);
    $("#rdoRepeatYear_day").prop("checked", true);
}
function setRdoRepeatYear_weekofday(){
	$("#rdoRepeatYear_day").prop("checked", false);
    $("#rdoRepeatYear_weekofday").prop("checked", true);
}

function setEnd(target){
	$("#EndDate").prop("disabled", (target.value == 'count'))
}
</script>
