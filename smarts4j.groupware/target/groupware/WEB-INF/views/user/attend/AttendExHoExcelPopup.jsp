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
var trSDate;
var trEDate;
function init(){
	var sDate = "${StartDate}";
	var eDate = "${EndDate}";
	
	trSDate = sDate.replace(/-/gi,".");
	trEDate = eDate.replace(/-/gi,".");
	
	selectBoxChg("week");
	
	AttendUtils.getDeptList($("#subDeptList"),'', false, false, true);
	
}

function selectBoxChg(v){
	if(v=="week"){
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
	
}

function setDatePickerExcelPop(){
	$("#searchDate_StartDate").datepicker({
		dateFormat: 'yy.mm.dd',
/* 	    showOn: 'button', */
	    buttonText : 'calendar',
	    buttonImage: Common.getGlobalProperties("css.path") +  "/covicore/resources/images/theme/blue/app_calendar.png", 
        buttonImageOnly: true
	});
	$("#searchDate_EndDate").datepicker({
		dateFormat: 'yy.mm.dd',
/* 	    showOn: 'button', */
	    buttonText : 'calendar',
	    buttonImage: Common.getGlobalProperties("css.path") +  "/covicore/resources/images/theme/blue/app_calendar.png", 
        buttonImageOnly: true,
        onSelect : function(selected){
        	var $start = $("#searchDate_StartDate");
        	var startDate = new Date($start.val().replaceAll(".", "/"));
        	var endDate = new Date(selected.replaceAll(".", "/"));

        	if (startDate.getTime() > endDate.getTime()){
        		Common.Warning("<spring:message code='Cache.mag_Attendance19' />"); //시작일 보다 이전 일 수 없습니다.
        		$("#searchDate_EndDate").val(startDate.format('yyyy.MM.dd'));
        	}
        }
	});
	
	$(".txtDate").focusout(function(obj){
		obj = obj.currentTarget; 
		var dataStr = $(obj).val();
		if(dataStr != ""){
			if(dataStr.split('.').length != 3){
				if(dataStr.replaceAll(".", "").length == 8){
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
		}
	});
}

function excelDownload(){
	$('#download_iframe').remove();
	
	var params = {
			"StartDate" : $("#searchDate_StartDate").val()
			,"EndDate" : $("#searchDate_EndDate").val()
			,"DEPTID" : $("#subDeptList").val()
			,"RetireUser" : $("#retireUser").is(":checked")?"Y":"N"
			,"Type" : $("input[name='excelDownType']:checked").val()
			,"ExcelType" : $("input[name='excelType']:checked").val() 
		};
	ajax_download('/groupware/attendExHo/excelDownFile.do', params);	// 엑셀 다운로드 post 요청
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
<div class="layer_divpop ui-draggable docPopLayer" style="width:100%;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">
		<div class="ATMgt_popup_wrap">
			<div class="ATMgt_work_wrap">
				<table class="ATMgt_popup_table type03" cellpadding="0" cellspacing="0">
					<colgroup>
				        <col width="115">
				        <col width="*">
				    </colgroup>
				    <tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_att_select_department'/>	<!-- 부서선택 --></td>
						<td>
							<div class="ATMgt_T">
								<div class="ATMgt_T_l">
									<select class="selectType02" id="subDeptList"></select>
								</div>
								<div class="ATMgt_T_r">
									<label for="retireUser"><spring:message code='Cache.lbl_att_retireuser'/></label>	<!--  퇴사자 포함 -->
									<input type="checkbox" id="retireUser" />
								</div>
							</div>		
						</td>
					</tr>
					<tr>
						<td class="ATMgt_T_th">
							<input type="radio" name="excelDownType" id="excelDownType1" value="week" checked onClick="selectBoxChg('week')"/><label for="excelDownType1">주간</label>
							<input type="radio" name="excelDownType" id="excelDownType2" value="select" onClick="selectBoxChg('select')"/><label for="excelDownType2">기간</label>
						</td>
						<td>	
							<div class="dateSel type02" id="">
								<input type="text" class="txtDate" id="searchDate_StartDate" disabled value=""/>-
								<input type="text" class="txtDate" id="searchDate_EndDate" disabled value=""/>
							</div>											
						</td>	
					</tr>
					<tr>
						<td colspan="2">
							<input type="radio" name="excelType" id="excelType1" value="Comm" checked/><label for="excelType1"><spring:message code='Cache.lbl_AbsenceTardiness' /></label> <!-- 근태내역 -->
							<input type="radio" name="excelType" id="excelType2" value="Late50"/><label for="excelType2">50<spring:message code='Cache.lbl_Minutes' /><spring:message code='Cache.lbl_AfterwardsWork' /></label> <!-- 50분이후출근 -->
							<input type="radio" name="excelType" id="excelType3" value="Late"/><label for="excelType3">9<spring:message code='Cache.lbl_Hour' /><spring:message code='Cache.lbl_AfterwardsWork' /></label> <!-- 9시이후출근 -->
							<input type="radio" name="excelType" id="excelType7" value="ExSumm"/><label for="excelType7"><spring:message code='Cache.lbl_SummaryOverWork' /></label> <!-- 연장근무요약 -->
							<input type="radio" name="excelType" id="excelType8" value="CommSumm"/><label for="excelType8"><spring:message code='Cache.lbl_SummaryActualWork' /></label> <!-- 실근무요약 -->
							<input type="radio" name="excelType" id="excelType4" value="ExHo"/><label for="excelType4"><spring:message code='Cache.lbl_att_overtime' />/<spring:message code='Cache.lbl_att_holiday_work' /></label>  <!-- 연장/휴일근무 -->
						</td>
					</tr>
				</table>	
			</div>
			<div class="bottom" style="text-align: center">
				<a class="btnTypeDefault btnExcel isAdminChk" href="#" onclick="excelDownload();"><spring:message code='Cache.lbl_SaveToExcel'/></a>
			</div>
		</div>
	</div>
</div>
</body>
</html>
