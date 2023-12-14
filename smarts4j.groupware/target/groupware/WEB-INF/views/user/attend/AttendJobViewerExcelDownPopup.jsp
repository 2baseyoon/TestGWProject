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
var g_DeptCode       = decodeURIComponent(CFN_GetQueryString("DeptCode"));
var mode = "<c:out value="${mode}"/>";
function init(){
	var sDate = "${StartDate}";
	var eDate = "${EndDate}";
	/*
	trSDate = sDate.replace(/-/gi,".");
	trEDate = eDate.replace(/-/gi,".");*/
	
	
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
	sDate = AttendUtils.getWeekStart(new Date(replaceDate(sDate)), strtWeek-1);
	sDate = schedule_SetDateFormat(sDate, '-');
	eDate = schedule_SetDateFormat(schedule_AddDays(sDate, 6), '-');
	
    $("#StartDate").val(sDate);
    $("#EndDate").val(eDate);
    if(mode=="W") {
		selectBoxChg("W");
	}else{
		selectBoxChg("M");
	}
//    setDateTerm( ,sDate)
	AttendUtils.getDeptList($("#groupPath"),g_DeptCode, false, false, true);
//	AttendUtils.getDeptList($("#subDeptList"));

	/*$('input[name="AttStatus"]').bind('click',function() {
	    $('input[name="AttStatus"]').not(this).prop("checked", false);

	  });*/
	
	/*$('input[name="dataMode"]').bind('click',function() {
	    $('input[name="dataMode"]').not(this).prop("checked", false);
  	});*/
	
	//이전
	$(".pre").click(function(){
		var startDateObj = new Date(replaceDate($("#StartDate").val()));

		switch ($("#excelDownType").val()){
			case "D":
				sDate = schedule_SetDateFormat(schedule_AddDays(startDateObj, -1), '-');
				eDate = sDate;
				break;
			case "W":
				sDate = schedule_SetDateFormat(schedule_AddDays(startDateObj, -7), '-');
				eDate = schedule_SetDateFormat(schedule_AddDays(startDateObj, -1), '-');
				break;
			case "M":
				eDate = schedule_SetDateFormat(schedule_AddDays(startDateObj.setDate(1), -1), '-');
				sDate = schedule_SetDateFormat(new Date(startDateObj.setMonth(startDateObj.getMonth()-1)).setDate(1), '-');
				break;
            case "L":
                eDate = schedule_SetDateFormat(schedule_AddDays(startDateObj.setDate(1), -1), '-');
                sDate = schedule_SetDateFormat(new Date(startDateObj.setMonth(startDateObj.getMonth()-1)).setDate(1), '-');
                break;
		}
		
        $("#StartDate").val(sDate);
        $("#EndDate").val(eDate);
		//setPage(1);
	});
	
	//이후
	$(".next").click(function(){
		var startDateObj = new Date(replaceDate($("#StartDate").val()));

		switch ($("#excelDownType").val()){
			case "D":
				sDate = schedule_SetDateFormat(schedule_AddDays(startDateObj, 1), '-');
				eDate = sDate;
				break;
			case "W":
				sDate = schedule_SetDateFormat(schedule_AddDays(startDateObj, 7), '-');
				eDate = schedule_SetDateFormat(schedule_AddDays(startDateObj, 13), '-');
				break;
			case "M":
				sDate = schedule_SetDateFormat(new Date(startDateObj.setMonth(startDateObj.getMonth()+1, 1)), '-');
				eDate = schedule_SetDateFormat(new Date(startDateObj.setMonth(startDateObj.getMonth()+1, 0)), '-');
				break;
            case "L":
                sDate = schedule_SetDateFormat(new Date(startDateObj.setMonth(startDateObj.getMonth()+1, 1)), '-');
                eDate = schedule_SetDateFormat(new Date(startDateObj.setMonth(startDateObj.getMonth()+1, 0)), '-');
                break;
		}			
        $("#StartDate").val(sDate);
        $("#EndDate").val(eDate);
		//setPage(1);
	});
	}

function selectBoxChg(v){
    setDateTerm(v, $("#StartDate").val());
    
/*	if(v=="W"){
		$("#searchDate_StartDate").val(trSDate);
		$("#searchDate_EndDate").val(trEDate);
		$(".txtDate").attr("disabled",true);
	}else{
		if($("#searchDate_StartDate").val()==""){
			$("#searchDate_StartDate").val(trSDate);
			$("#searchDate_EndDate").val(trEDate);
		}
		$(".txtDate").removeAttr("disabled");
		
	}
	*/
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
			sDate = schedule_SetDateFormat(new Date(gDate.substring(0,4), (gDate.substring(5,7) - 1), 1), '-');
			eDate = schedule_SetDateFormat(new Date(gDate.substring(0,4), gDate.substring(5,7), 0), '-')
            $("#StartDate").val(sDate);
            $("#EndDate").val(eDate);
            $(".txtDate").attr("disabled",true);
            break;
        case "L":
            sDate = schedule_SetDateFormat(new Date(gDate.substring(0,4), (gDate.substring(5,7) - 1), 1), '-');
            eDate = schedule_SetDateFormat(new Date(gDate.substring(0,4), gDate.substring(5,7), 0), '-')
            $("#StartDate").val(sDate);
            $("#EndDate").val(eDate);
            $(".txtDate").removeAttr("disabled");
            break;
		default:
            $("#StartDate").val(gDate);
            $("#EndDate").val(gDate);
    		$(".txtDate").removeAttr("disabled");
            break;
    
	}
}

function setDatePickerExcelPop(){
	$("#StartDate").datepicker({
		dateFormat: 'yy-mm-dd',
/* 	    showOn: 'button', */
	    buttonText : 'calendar',
	    buttonImage: Common.getGlobalProperties("css.path") +  "/covicore/resources/images/theme/blue/app_calendar.png", 
        buttonImageOnly: true
	});
	$("#EndDate").datepicker({
		dateFormat: 'yy-mm-dd',
/* 	    showOn: 'button', */
	    buttonText : 'calendar',
	    buttonImage: Common.getGlobalProperties("css.path") +  "/covicore/resources/images/theme/blue/app_calendar.png", 
        buttonImageOnly: true,
        onSelect : function(selected){
        	var $start = $("#StartDate");
        	var startDate = new Date($start.val().replaceAll(".", "-"));
        	var endDate = new Date(selected.replaceAll(".", "-"));

        	if (startDate.getTime() > endDate.getTime()){
        		Common.Warning("<spring:message code='Cache.mag_Attendance19' />"); //시작일 보다 이전 일 수 없습니다.
        		$("#EndDate").val(startDate.format('yyyy-MM-dd'));
        	}
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
	var url = "/groupware/attendJob/getAttendJobViewExcelDownload.do";
	
	var params = {
		"mode" : $("#excelDownType").val()
		,"DeptCode" : 	$("#groupPath").val()
		,"StartDate" : $("#StartDate").val()
		,"EndDate" : $("#EndDate").val()
		,"searchText" : '<c:out value="${searchText}"/>'
		,"weeklyWorkType" : '<c:out value="${weeklyWorkType}"/>'
		,"weeklyWorkValue" : '<c:out value="${weeklyWorkValue}"/>'
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
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_att_select_department'/></span></td>	<!-- 부서선택 -->
						<td>
							<div class="ATMgt_T_l"><select class="selectType02" id="groupPath"></select></div>
							<%--<div class="ATMgt_T_r">
								<span class1="tx_cont"><label for="retireUser"><spring:message code='Cache.lbl_att_retireuser'/></label>	<!--  퇴사자 포함 -->
									<input type="checkbox" id="retireUser" /></span>
							</div>--%>
						</td>
					</tr>
					<tr>
						<td class="ATMgt_T_th">
							<select class="selectType02" id="excelDownType" onchange="selectBoxChg(this.value);">
								<option value="W" <c:if test="${mode eq 'W'}">selected</c:if>><spring:message code='Cache.lbl_Weekly'/></option> <!-- 주간 -->
								<option value="M" <c:if test="${mode eq 'M'}">selected</c:if>><spring:message code='Cache.lbl_Monthly'/></option> <!-- 월간 -->
								<option value="L"><spring:message code='Cache.lbl_scope'/><spring:message code='Cache.btn_apv_Appoint'/></option> <!-- 기간지정 -->
							</select>
						</td>
						<td>
							<div class="dateSel">
								<input type="text" class="txtDate" id="StartDate" disabled value=""/>-
								<input type="text" class="txtDate" id="EndDate" disabled value=""/>
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
					<%--<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_att_806_h_4'/></td>
						<td>
							<input id="AttStatus1" name="AttStatus" value="B10" type="checkbox">
							<label for=AttStatus1><spring:message code="Cache.AlramTime_10"/>~<spring:message code="Cache.lbl_startWorkTime"/></label><!-- 출근10분전 -->
							<input id="AttStatus2" name="AttStatus" value="A1" type="checkbox">
							<label for=AttStatus2><spring:message code="Cache.lbl_startWorkTime"/>~<spring:message code="Cache.RepeatTerm_60"/></label><!-- 출근1시간내-->
							<input id="AttStatus3" name="AttStatus" value="LATE" type="checkbox">
							<label for=AttStatus3><spring:message code="Cache.lbl_att_beginLate"/></label><!-- 지각 -->
						</td>
					</tr>--%>
					<%--<tr>
						<td colspan=2 style="text-align:center"><input id="dataMode1" name="dataMode" value="" type="checkbox" checked>
							<label for=dataMode1><spring:message code="Cache.lbl_n_att_acknowledgedWork"/></label><!-- 인정 -->
							<input id="dataMode2" name="dataMode" value="R" type="checkbox">
							<label for=dataMode2><spring:message code="Cache.lbl_n_att_AttRealTime"/></label><!-- 실근무-->
						</td>
					</tr>--%>
				</table>	
			</div>		
			<div class="bottom" style="text-align: center">
				<a class="btnTypeDefault btnExcel isAdminChk" href="#" onclick="popExcelDownload();"><spring:message code='Cache.lbl_SaveToExcel'/></a>
			</div>
		</div>				
	</div>
</body>
</html>
