<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<!doctype html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<script type="text/javascript">

$(document).ready(function(){
	
	setDatePickerExcelPop();
	init();
});

var g_curDate = CFN_GetLocalCurrentDate("yyyy-MM-dd");
var strtWeek = parseInt(Common.getBaseConfig("AttBaseWeek"));
var g_oriMonth;
var g_ckb_incld_weeks = decodeURIComponent(CFN_GetQueryString("ckb_incld_weeks"));
var b_ckb_incld_weeks = false;
if(g_ckb_incld_weeks=="true"){
	b_ckb_incld_weeks = true;
}
var g_sUserTxt        = decodeURIComponent(CFN_GetQueryString("sUserTxt"));
var g_sJobTitleCode   = decodeURIComponent(CFN_GetQueryString("sJobTitleCode"));
var g_sJobLevelCode   = decodeURIComponent(CFN_GetQueryString("sJobLevelCode"));
var g_weeklyWorkType  = decodeURIComponent(CFN_GetQueryString("weeklyWorkType"));
var g_weeklyWorkValue = decodeURIComponent(CFN_GetQueryString("weeklyWorkValue"));
var g_groupPath       = decodeURIComponent(CFN_GetQueryString("groupPath"));
var g_printDN         = decodeURIComponent(CFN_GetQueryString("printDN"));

var pageType = "${pageType}";
var sDate = "${StartDate}";
var eDate = "${EndDate}";
var g_rangeWeekNum    = ${rangeWeekNum};
var g_sDate = sDate;
var g_eDate = eDate;

function init(){
	g_oriMonth = new Date(replaceDate(sDate));
	
	trSDate = sDate;//.replace(/-/gi,".");
	trEDate = eDate;//.replace(/-/gi,".");
	$("#inputCalendarcontrol").datepicker({
		dateFormat: 'yy-mm-dd',
		beforeShow: function(input) {
		           var i_offset = $(".calendarcontrol").offset();      // 버튼이미지 위치 조회
		           setTimeout(function(){
		              jQuery("#ui-datepicker-div").css({"left":i_offset});
		           })
		        },
		onSelect: function(dateText){
			setDateTerm($("#excelDownType").val(),dateText);
		}
	});
	$(".calendarcontrol").click(function(){
		$("#inputCalendarcontrol").datepicker().datepicker("show");
	});
	$(".calendartoday").click(function(){
		setDateTerm($("#excelDownType").val(), g_curDate);
	});

	AttendUtils.getDeptList($("#groupPath"),g_groupPath, false, false, true);

	$('input[name="AttStatus"]').bind('click',function() {
	    $('input[name="AttStatus"]').not(this).prop("checked", false);
	});
	
	$('input[name="dataMode"]').bind('click',function() {
	    $('input[name="dataMode"]').not(this).prop("checked", false);
  	});
	//퇴사자 check
	var retireUser = "${retireUser}";
	if(retireUser=="INOFFICE"){
		$("#retireUser").prop("checked", true);
	}

	//이전
	$(".pre").click(function(){
		var startDateObj = new Date(replaceDate($("#StartDate").val()));

		switch ($("#excelDownType").val()) {
			case "D":
				sDate = schedule_SetDateFormat(schedule_AddDays(startDateObj, -1), '-');
				eDate = sDate;
				$("#StartDate").val(sDate);
				$("#EndDate").val(eDate);
				break;
			case "W":
				sDate = schedule_SetDateFormat(schedule_AddDays(startDateObj, -7), '-');
				eDate = schedule_SetDateFormat(schedule_AddDays(startDateObj, -1), '-');
				g_oriMonth.setDate(g_oriMonth.getDate() - 7);
				$("#StartDate").val(sDate);
				$("#EndDate").val(eDate);
				break;
			case "M":
				g_oriMonth.setMonth(g_oriMonth.getMonth() - 1);
				if (b_ckb_incld_weeks) {
					sDate = AttendUtils.getWeeklyStart(g_oriMonth, strtWeek - 1);
					eDate = AttendUtils.getWeeklyEnd(new Date(g_oriMonth.getFullYear(), (g_oriMonth.getMonth()+1), 0), strtWeek-1);
				}else{
					sDate = new Date(g_oriMonth.getFullYear(), g_oriMonth.getMonth(), 1);
					eDate = new Date(g_oriMonth.getFullYear(), (g_oriMonth.getMonth()+1), 0);
					$("#p_StartDate").val(schedule_SetDateFormat(AttendUtils.getWeeklyStart(g_oriMonth, strtWeek - 1), '-'));
					$("#p_EndDate").val(schedule_SetDateFormat(AttendUtils.getWeeklyEnd(new Date(g_oriMonth.getFullYear(), (g_oriMonth.getMonth()+1), 0), strtWeek-1), '-'));
				}
				sDate = schedule_SetDateFormat(sDate, '-');
				eDate = schedule_SetDateFormat(eDate, '-');
				$("#StartDate").val(sDate);
				$("#EndDate").val(eDate);
				break;
		}
	});
	
	//이후
	$(".next").click(function(){
		var startDateObj = new Date(replaceDate($("#StartDate").val()));

		switch ($("#excelDownType").val()){
			case "D":
				sDate = schedule_SetDateFormat(schedule_AddDays(startDateObj, 1), '-');
				eDate = sDate;
				$("#StartDate").val(sDate);
				$("#EndDate").val(eDate);
				break;
			case "W":
				sDate = schedule_SetDateFormat(schedule_AddDays(startDateObj, 7), '-');
				eDate = schedule_SetDateFormat(schedule_AddDays(startDateObj, 13), '-');
				g_oriMonth.setDate(g_oriMonth.getDate() + 7);
				$("#StartDate").val(sDate);
				$("#EndDate").val(eDate);
				break;
			case "M":
				g_oriMonth.setMonth(g_oriMonth.getMonth() + 1);
				if (b_ckb_incld_weeks) {
					sDate = AttendUtils.getWeeklyStart(g_oriMonth, strtWeek-1);
					eDate = AttendUtils.getWeeklyEnd(new Date(g_oriMonth.getFullYear(), (g_oriMonth.getMonth()+1), 0), strtWeek-1);
				}else{
					sDate = new Date(g_oriMonth.getFullYear(), g_oriMonth.getMonth(), 1);
					eDate = new Date(g_oriMonth.getFullYear(), (g_oriMonth.getMonth()+1), 0);
					$("#p_StartDate").val(schedule_SetDateFormat(AttendUtils.getWeeklyStart(g_oriMonth, strtWeek - 1), '-'));
					$("#p_EndDate").val(schedule_SetDateFormat(AttendUtils.getWeeklyEnd(new Date(g_oriMonth.getFullYear(), (g_oriMonth.getMonth()+1), 0), strtWeek-1), '-'));
				}
				sDate = schedule_SetDateFormat(sDate, '-');
				eDate = schedule_SetDateFormat(eDate, '-');
				$("#StartDate").val(sDate);
				$("#EndDate").val(eDate);
				break;
		}
	});


	//주간/월간/주간장표 탭 별 기록 범위 설정
	if("0" === pageType){
		$("#excelDownType").val("W").attr("selected", "selected");
		selectBoxChg("W");
	}else if("1" === pageType){
		$("#excelDownType").val("M").attr("selected", "selected");
		selectBoxChg("M");
	}else if("2" === pageType){
		$("#id_tr_option").hide();
		$("#excelDownType").val("L").attr("selected", "selected");
		selectBoxChg("L");
	}else if("3" === pageType){
		$("#excelDownType").val("L").attr("selected", "selected");
		selectBoxChg("L");
	}

	//주야 표기 여부에 따른 RAW출력 가능 여부 처리
	if(g_printDN=="true"){
		if("3" === pageType) {
			if ($("#detailOption").is(":checked")) {
				$("#id_raw_option").show();
			} else {
				$("#outputNumtype").attr("checked", false);
				$("#id_raw_option").hide();
			}

			$("#detailOption").click(function () {
				if ($(this).is(":checked")) {
					$("#id_raw_option").show();
				} else {
					$("#id_raw_option").hide();
					$("#outputNumtype").attr("checked", false);
				}
			});
		}else if("2" === pageType) {
			$("#id_raw_option").show();
		}
	}

}//end init

function selectBoxChg(v){
	if(v=="L"){
		if("2" === pageType){
			v = "WT";
		}else if("3" === pageType){
			v = "DT";
		}
	}
    setDateTerm(v, $("#StartDate").val());
}

function setDateTerm(mode, gDate){
	switch (mode){
		case "W":
			sDate = AttendUtils.getWeekStart(new Date(replaceDate(gDate)), strtWeek-1);
			sDate = schedule_SetDateFormat(sDate, '-');
			eDate = schedule_SetDateFormat(schedule_AddDays(sDate, 6), '-');
            $("#StartDate").val(sDate);
            $("#EndDate").val(eDate);
            $(".txtDate").attr("disabled",true);
            break;
		case "M":
			g_oriMonth = new Date(g_oriMonth.getFullYear(), g_oriMonth.getMonth(), 1);
			if (b_ckb_incld_weeks) {
				sDate = AttendUtils.getWeeklyStart(g_oriMonth, strtWeek-1);
				eDate = AttendUtils.getWeeklyEnd(new Date(g_oriMonth.getFullYear(), (g_oriMonth.getMonth()+1), 0), strtWeek-1);
			}else{
				sDate = new Date(g_oriMonth.getFullYear(), g_oriMonth.getMonth(), 1);
				eDate = new Date(g_oriMonth.getFullYear(), (g_oriMonth.getMonth()+1), 0);
				$("#p_StartDate").val(schedule_SetDateFormat(AttendUtils.getWeeklyStart(g_oriMonth, strtWeek - 1), '-'));
				$("#p_EndDate").val(schedule_SetDateFormat(AttendUtils.getWeeklyEnd(new Date(g_oriMonth.getFullYear(), (g_oriMonth.getMonth()+1), 0), strtWeek-1), '-'));
			}
			sDate = schedule_SetDateFormat(sDate, '-');
			eDate = schedule_SetDateFormat(eDate, '-');

            $("#StartDate").val(sDate);
            $("#EndDate").val(eDate);
            $(".txtDate").attr("disabled",true);
            break;
		case "WT":
			sDate = schedule_SetDateFormat(g_sDate, '-');
			eDate = schedule_SetDateFormat(g_eDate, '-');
            $("#StartDate").val(sDate);
            $("#EndDate").val(eDate);
    		$(".txtDate").removeAttr("disabled");
            break;
		case "DT":
			g_oriMonth = new Date(g_oriMonth.getFullYear(), g_oriMonth.getMonth(), 1);
			if (b_ckb_incld_weeks) {
				sDate = AttendUtils.getWeeklyStart(g_oriMonth, strtWeek-1);
				eDate = AttendUtils.getWeeklyEnd(new Date(g_oriMonth.getFullYear(), (g_oriMonth.getMonth()+1), 0), strtWeek-1);

			}else{
				sDate = new Date(g_oriMonth.getFullYear(), g_oriMonth.getMonth(), 1);
				eDate = new Date(g_oriMonth.getFullYear(), (g_oriMonth.getMonth()+1), 0);
				$("#p_StartDate").val(schedule_SetDateFormat(AttendUtils.getWeeklyStart(g_oriMonth, strtWeek - 1), '-'));
				$("#p_EndDate").val(schedule_SetDateFormat(AttendUtils.getWeeklyEnd(new Date(g_oriMonth.getFullYear(), (g_oriMonth.getMonth()+1), 0), strtWeek-1), '-'));
			}
			sDate = schedule_SetDateFormat(sDate, '-');
			eDate = schedule_SetDateFormat(eDate, '-');
			$("#StartDate").val(sDate);
			$("#EndDate").val(eDate);
			$(".txtDate").removeAttr("disabled");
			break;
	}
}

function setDatePickerExcelPop(){
	$("#StartDate").datepicker({
		dateFormat: 'yy-mm-dd',
		format: "yy-MM-dd",
/* 	    showOn: 'button', */
	    buttonText : 'calendar',
	    buttonImage: Common.getGlobalProperties("css.path") +  "/covicore/resources/images/theme/blue/app_calendar.png", 
        buttonImageOnly: true,
		onClose : function(date){
			var startDate = new Date(date.replaceAll(".", "/"));
			$("#StartDate").val(startDate.format('yyyy-MM-dd'));
		}
	});
	$("#EndDate").datepicker({
		dateFormat: 'yy-mm-dd',
		format: "yy-MM-dd",
/* 	    showOn: 'button', */
	    buttonText : 'calendar',
	    buttonImage: Common.getGlobalProperties("css.path") +  "/covicore/resources/images/theme/blue/app_calendar.png", 
        buttonImageOnly: true,
        onSelect : function(date){
        	var $start = $("#StartDate");
        	var startDate = new Date($start.val().replaceAll(".", "/"));
        	var endDate = new Date(date.replaceAll(".", "/"));

        	if (startDate.getTime() > endDate.getTime()){
        		Common.Warning("<spring:message code='Cache.mag_Attendance19' />");	//시작일 보다 이전 일 수 없습니다.
        		$("#EndDate").val(startDate.format('yyyy-MM-dd'));
        	}
        },
		onClose : function(date){
			var endDate = new Date(date.replaceAll(".", "/"));
			$("#EndDate").val(endDate.format('yyyy-MM-dd'));
		}
	});
	
	$(".txtDate").focusout(function(obj){
		obj = obj.currentTarget; 
		var dataStr = $(obj).val();
		if(dataStr != ""){
			if(XFN_ReplaceAllSpecialChars(dataStr).length == 8){
				dataStr = XFN_ReplaceAllSpecialChars(dataStr);
				var returnStr = dataStr.substring(0, 4) + "." + dataStr.substring(4, 6) + "." + dataStr.substring(6, 8);
				
				if(!isNaN(Date.parse(returnStr))){
					$(obj).val(returnStr);
					//coviCtrl.getHWMY(target, "end");
				}
				else{
					$(obj).val("");
					$(".txtDate").val("");
					Common.Warning("<spring:message code='Cache.mag_Attendance20' />");		//날짜 포맷에 맞는 데이터를 입력해주시기 바랍니다.
				}
			}else{
				$(obj).val("");
				$(".txtDate").val("");
				Common.Warning("<spring:message code='Cache.mag_Attendance20' />");		//날짜 포맷에 맞는 데이터를 입력해주시기 바랍니다.
			}
		}
	});
}

function popExcelDownload(){
	$('#download_iframe').remove();
	var url = "";
	if("2" === pageType){
		url = "/groupware/attendUserSts/excelDownloadForAttMngStatusWeekly.do";
	}else if("3" === pageType){
		if($("#detailOption").is(":checked")){
			url = "/groupware/attendUserSts/excelDownloadForAttMngStatusDailyDetail.do";
		}else{
			url = "/groupware/attendUserSts/excelDownloadForAttMngStatusDaily.do";
		}
	}else{
		Common.Warning(Common.getDic("msg_ObjectUR_21"));
		return;
	}


	var tDate = new Date(g_oriMonth.getFullYear(), g_oriMonth.getMonth(), 1);

	var params = {
		"groupPath" : 	$("#groupPath").val()
		,"StartDate" : schedule_SetDateFormat($("#StartDate").val(), "-")
		,"EndDate" : schedule_SetDateFormat($("#EndDate").val(), "-")
		,"rangeWeekNum" : g_rangeWeekNum
		,"TargetDate" : schedule_SetDateFormat(tDate, '-')
		,"dateTerm" : $("#excelDownType").val()
		,"RetireUser" : $("#retireUser").is(":checked")?"":"INOFFICE"
		,"outputNumtype" : $("#outputNumtype").is(":checked")?"Y":"N"
		,"sUserTxt" : g_sUserTxt
		,"sJobTitleCode" : g_sJobTitleCode
		,"sJobLevelCode" : g_sJobLevelCode
		,"weeklyWorkType" : g_weeklyWorkType
		,"weeklyWorkValue" : g_weeklyWorkValue
		,"p_StartDate" : $("#p_StartDate").val()
		,"p_EndDate" : $("#p_EndDate").val()
		,"incld_weeks" : g_ckb_incld_weeks
		,"printDN" : g_printDN
		,"detailOption" : $("#detailOption").is(":checked")?"true":"false"
	};

	ajax_download(url, params);	// 엑셀 다운로드 post 요청

}



</script>
<style type="text/css">

.txtDate {
    width: 100px !important;
    height: 30px;
    border: 1px solid #d6d6d6;
}

.bottom {
	padding-top: 30px;
}
</style>
</head>
<body>
	<div class="divpop_contents">
		<div class="ATMgt_popup_wrap">
			<div class="ATMgt_work_wrap">
				<table class="ATMgt_popup_table type03" cellpadding="0" cellspacing="0">
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_att_select_department'/></td>	<!-- 부서선택 -->
						<td>
							<div class="ATMgt_T_l"><select class="selectType02" id="groupPath"></select></div>
							<div class="ATMgt_T_r">
								<span class1="tx_cont"><label for="retireUser"><spring:message code='Cache.lbl_att_retireuser'/></label>	<!--  퇴사자 포함 -->
									<input type="checkbox" id="retireUser" /></span>
							</div>
						</td>
					</tr>
					<tr>
						<td class="ATMgt_T_th">
							<select class="selectType02" id="excelDownType" onchange="selectBoxChg(this.value);">
								<option value="L"><spring:message code='Cache.lbl_SpecifyingPeriod'/></option> <!-- 기간지정 -->
								<option value="M"><spring:message code='Cache.lbl_Monthly'/></option> <!-- 월간 -->
								<option value="W"><spring:message code='Cache.lbl_Weekly'/></option> <!-- 주간 -->
							</select>
						</td>
						<td>
							<div class="dateSel">
								<input type="text" class="txtDate" id="StartDate" disabled value=""/>-
								<input type="text" class="txtDate" id="EndDate" disabled value=""/>
								<input type="hidden" id="p_StartDate" value=""/>
								<input type="hidden" id="p_EndDate" value=""/>
							</div>											
							<div class="pagingType02">
								<a href="#" class="pre dayChg" data-paging="-" ></a>
								<a href="#" class="next dayChg" data-paging="+" ></a>
								<a href="#" class="btnTypeDefault calendartoday"><spring:message code='Cache.lbl_Todays'/></a>
								<a href="#" class="calendarcontrol btnTypeDefault cal"></a>
								<input type="text" id="inputCalendarcontrol" style="height: 0px; width:0px; border: 0px;" >
							</div> 
						</td>
					</tr>
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.ACC_btn_option'/></span></td>
						<td style="text-align:center">
							<div class1="tx_cont" style="float: left;" id="id_tr_option">
								<input type="checkbox" id="detailOption" />
								<label for="retireUser"><spring:message code='Cache.lbl_DetailView'/></label>	<!-- 상세보기 -->
							</div>
							&nbsp;&nbsp;&nbsp;
							<div class1="tx_cont" style="float: left;" id="id_raw_option">
								<input id="outputNumtype" name="outputNumtype" value="" type="checkbox">
								<label for=outputNumtype>RAW <spring:message code="Cache.btn_apv_print"/></label>
							</div>
						</td>
					</tr>
				</table>	
			</div>		
			<div class="bottom" style="text-align: center">
				<a class="btnTypeDefault btnExcel isAdminChk" href="#" onclick="popExcelDownload();"><spring:message code='Cache.lbl_SaveToExcel'/></a>
			</div>
		</div>				
	</div>
</body>
</html>
