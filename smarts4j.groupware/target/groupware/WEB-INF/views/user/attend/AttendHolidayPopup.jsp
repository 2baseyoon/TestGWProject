<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<!doctype html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
</head>
<body> 
<form id="holyFrm" method="post">
<input type="hidden" name="HolidayStart" id="HolidayStart" value=""/>
<input type="hidden" name="HolidayEnd" id="HolidayEnd" value=""/>
<input type="hidden" name="AlramYn" id="AlramYn" value=""/>
<input type="hidden" name="GoogleYn" id="GoogleYn" value="${holi.GoogleYn}"/>
<div class="layer_divpop popContent ui-draggable" id="testpopup_p"style="width:100%" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class=" miAnniversaryPopup">
	<div class="">
		<div class="top">						
			<div class="ulList"> 
				<ul>
					<li class="listCol">
						<div><strong><spring:message code="Cache.lbl_att_holiday_name" /></strong></div> <!-- 휴무일 명 -->
						<div>
							<input type="text" name="HolidayName" class="inpFullSize HtmlCheckXSS ScriptCheckXSS" placeholder="" id="subject"> <!-- 휴무일을 입력하세요. -->
						</div>
					</li>	
					<li class="listCol">
						<div><strong><spring:message code="Cache.lbl_att_holiday_date" /></strong></div> <!-- 휴무일자 -->
						<div class="dateSel type02" id="calendar_picker"></div>
					</li>											
					<li class="listCol">		
						<div><strong><spring:message code="Cache.lbl_Contents" /></strong></div> <!-- 내용 -->
						<div>
							<textarea id="description" name="Etc" class="HtmlCheckXSS ScriptCheckXSS"></textarea>
						</div>
					</li>	
				</ul>							
			</div>
		</div>
		<div class="bottom" style="text-align: center;">
			<a href="#" class="btnTypeDefault btnTypeChk" id="createBtn" onclick="saveAnniversary()" style="display:none;"><spring:message code="Cache.btn_register" /></a> <!-- 등록 -->	
			<a href="#" class="btnTypeDefault btnTypeChk" id="updateBtn" onclick="saveAnniversary()" style="display:none;"><spring:message code="Cache.btn_Modify" /></a> <!-- 수정 -->	
			<!-- <a href="#" class="btnTypeDefault btnBlueBoder" onclick="parent.openCalendarPopup();Common.Close()">일정등록</a> --> <!-- 일정등록 -->
			<%-- <a href="#" class="btnTypeDefault" onclick="resetVal()"><spring:message code="Cache.btn_Initialization" /></a> --%> <!-- 초기화 -->
			<a href="#" class="btnTypeDefault" onclick="Common.Close()"><spring:message code="Cache.btn_att_close" /></a> <!-- 닫기 -->
		</div>
	</div>
</div>
		</div>	
	</div>
</form>
</body>

<script type="text/javascript">
$(document).ready(function(){
	setDateConResource();
	$(".onOffBtn").click(function(){
		if($(this).attr("class").lastIndexOf("on")>-0) { 
	    	$(this).attr("class","onOffBtn");
		}else{
			$(this).attr("class","onOffBtn on");
	    }
	});
	
	
	var priorityStr = "";
	priorityStr+="<option value='1'>"+Common.getDic('Anni_Priority_1')+"</option>";
	priorityStr+="<option value='2'>"+Common.getDic('Anni_Priority_2')+"</option> ";
	priorityStr+="<option value='3' selected=''>"+Common.getDic('Anni_Priority_3')+"</option>";
	priorityStr+="<option value='4'>"+Common.getDic('Anni_Priority_4')+"</option>";
	priorityStr+="<option value='5'>"+Common.getDic('Anni_Priority_5')+" <spring:message code='Cache.CPMail_Low' /></option> "; //낮음
	
	$("#priority").html(priorityStr);
	
	var alramPeriodStr = "";
	for(var i=1;i<=31;i++){
		var target = Common.getDic('lbl_AnniversaryAlarm3').replace('{0}', i);
		alramPeriodStr+="<option value='"+i+"'>"+target+"</option>";
	}
	
	$("#alramPeriod").html(alramPeriodStr);
	
	var sts = "${sts}";
	if(sts == "UPD"){
		$("#subject").val("${holi.HolidayName}");
		$("#calendar_picker_StartDate").val("${holi.HolidayStart}".replaceAll("-","."));
		$("#calendar_picker_EndDate").val("${holi.HolidayEnd}".replaceAll("-","."));
		$("#description").val("${holi.Etc}");
		
		$("#updateBtn").removeAttr("style");
	}else{
		$("#createBtn").removeAttr("style");
	}
	
});



function setDateConResource(){
	target = 'calendar_picker';
	
	// 달력 옵션
	var timeInfos = {
		H : "1,,,", // 날짜 단위기 때문에 H는 없음.
		W : "1,,,", //주 선택
		M : "1,,,", //달 선택
		Y : "1,,," //년도 선택
	};
	var initInfos = {
		useCalendarPicker : 'Y',
		useTimePicker : 'N',
		useBar : 'Y',
		useSeparation : 'N',
	}; 
	
	coviCtrl.renderDateSelect2('calendar_picker', initInfos);	 //검색 기간
	$("#calendar_picker_StartDate").val("");
	$("#calendar_picker_EndDate").val("");
}

function saveAnniversary(){
	
	if(validCheck()){
		$("#HolidayStart").val($("#calendar_picker_StartDate").val());
		$("#HolidayEnd").val($("#calendar_picker_EndDate").val());
		var params = $("#holyFrm").serialize();
		
		var url = "/groupware/attendAdmin/createHoliday.do";
		if("${sts}" == "UPD"){ url = "/groupware/attendAdmin/updateHoliday.do"; }
		$.ajax({
			type:"POST",
			dataType : "json",
			data: params,
			url:url,
			success:function (data) {
				if(data.status =="SUCCESS"){
					Common.Inform("<spring:message code='Cache.msg_37'/>.","Information",function(){
						parent.search(1);
						Common.Close();
					});	
				}else if(data.status =="PRIMARY"){
					Common.Warning("<spring:message code='Cache.msg_att_overlapping_date'/>");	// 해당 날자에 휴일정보가 이미 등록 되어있습니다.
				}else{
					Common.Warning("<spring:message code='Cache.msg_sns_03'/>"); // 저장 중 오류가 발생하였습니다. 
				}
			}
		});
	}
}

function validCheck(){
	
	if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
	if($("input[name=HolidayName]").val()==""){
		Common.Warning("<spring:message code='Cache.msg_n_att_holidayAlert1'/>");
		return false;
	}else if($("#calendar_picker_StartDate").val()==""){
		Common.Warning("<spring:message code='Cache.msg_n_att_holidayAlert2'/>");
		return false;
	}else if($("#calendar_picker_EndDate").val()==""){
		Common.Warning("<spring:message code='Cache.msg_n_att_holidayAlert3'/>");
		return false;
	}else {
		return true;
	}
}

function resetVal(){
	$("input[name=HolidayName]").val("");
	$("#calendar_picker_StartDate").val("");
	$("#calendar_picker_EndDate").val("");
	$("#calendar_picker span .selectType04").val("1H");
	$(".onOffBtn").attr("class","onOffBtn");
	$("#alramPeriod").val(1);
	$("#priority").val(3);
	$("#description").val("");
	$("#HolidayStart").val("");
	$("#HolidayEnd").val("");
	$("#AlramYn").val("");
}

</script>
</html>


