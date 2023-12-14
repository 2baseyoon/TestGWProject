<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8" import="egovframework.coviframework.util.RedisDataUtil,egovframework.covision.groupware.attend.user.util.AttendUtils"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
</head>
<body>
	<div class="layer_divpop ui-draggable docPopLayer" style="width:100%;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="ATMgt_popup_wrap">
			<div >
				<table class="ATMgt_popup_table type02" cellspacing="0" cellpadding="0">
					<colgroup>
				        <col width="115">
				        <col width="*">
				        <col width="115">
				        <col width="*">        
				        <col width="115">
				        <col width="*">        
				    </colgroup>
				<tbody>
					<tr>
		               	<td class="ATMgt_T_th"><spring:message code='Cache.lbl_Time'/></td>
						<td colspan=5>
		               		<div class="ATMgt_T">
		               			<div class="ATMgt_T_Time wd">
									<select id="StartHour" name="StartHour">
										<c:forEach begin="${extenStartHour}" end="${extenEndHour}" var="hour">
											<option value="<c:out value="${ hour < 10 ? '0' : '' }${hour}"/>" ><c:out value="${ hour < 10 ? '0' : '' }${hour}" /></option>
										</c:forEach>
									</select>
									<span>:</span>
									<select name="StartMin"   id="StartMin">
										<c:forEach begin="00" end="59" var="min"  step="${extenUnit}">
										<option value="${ min < 10 ? '0' : '' }${min}">${ min < 10 ? '0' : '' }${min}</option>
										</c:forEach>
									</select>
									<span>-</span>
									<select id="EndHour" name="EndHour">
										<c:forEach begin="${extenStartHour}" end="${extenEndHour}" var="hour">
											<option value="<c:out value="${ hour < 10 ? '0' : '' }${hour}"/>" ><c:out value="${ hour < 10 ? '0' : '' }${hour}" /></option>
										</c:forEach>
									</select>
									<span>:</span> 
									<select name="EndMin"   id="EndMin">
										<c:forEach begin="00" end="59" var="min" step="${extenUnit}">
										<option value="${ min < 10 ? '0' : '' }${min}">${ min < 10 ? '0' : '' }${min}</option>
										</c:forEach>
									</select>
									<input type="checkbox" id="NextDayYn" name="NextDayYn" value="Y"  />
									<label for="NextDayYn"><spring:message code='Cache.lbl_NextDay' /></label>
							</div>
						</td>
					</tr>				
					<tr>
		               	<td class="ATMgt_T_th"><spring:message code='Cache.lbl_att_ldleTime'/></td>
						<td><input type="text" name="IdleTime"  id="IdleTime" value="0" style="width:100%" ${holiRestYn=='Y'?'disabled':''}/></td>
		               	<td class="ATMgt_T_th"><spring:message code='Cache.lbl_n_att_applicationTime'/></td>
		               	<td><input type="text" name="AcTime"  id="AcTime"  value="" style="width:100%"  ${holiRestYn=='Y'?'disabled':''}/></td>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_Approver' /></td>
						<td>${UR_ManagerName}</td>
					</tr>	
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_Remark'/></td>
						<td colspan=5><textarea id="Comment" name="Comment" class="ATMgt_Tarea"></textarea></td>
					</tr>
				</tbody>
				</table>	
			</div>				
			<div class="WTemp_cal_wrap">
				<div class="WTemp_cal_Top">
					<strong class="WTemp_cal_date"  id="dateTitle"></strong>
					<div class="pagingType01"><a class="pre" href="#"></a><a class="next" href="#"></a></div>
				</div>
    			<table class="WTemp_cal" id="calendar" cellpadding="0" cellspacing="0">
					<thead>
						<tr>
							<th><span class="tx_sun"><spring:message code='Cache.lbl_sch_sun' /></span></th> <!-- 일 -->
							<th><spring:message code='Cache.lbl_sch_mon' /></th> <!-- 월 -->
							<th><spring:message code='Cache.lbl_sch_tue' /></th> <!-- 화 -->
							<th><spring:message code='Cache.lbl_sch_wed' /></th> <!-- 수 -->
							<th><spring:message code='Cache.lbl_sch_thu' /></th> <!-- 목 -->
							<th><spring:message code='Cache.lbl_sch_fri' /></th> <!-- 금 -->
							<th><span class="tx_sat"><spring:message code='Cache.lbl_sch_sat' /></span></th> <!-- 토-->
						</tr>
					</thead>
					<tbody id="calTbody">
						<c:forEach begin="1" end="5">
						<tr>
							<td class="tx_sun"><p class="tx_day"></p><div><p></p></div></td>
							<td><p class="tx_day"></p><div><p></p></div></td>
							<td><p class="tx_day"></p><div><p></p></div></td>
							<td><p class="tx_day"></p><div><p></p></div></td>
							<td><p class="tx_day"></p><div><p></p></div></td>
							<td><p class="tx_day"></p><div><p></p></div></td>
							<td class="tx_sat"><p class="tx_day"></p><div><p></p></div></td>
						</tr>
						</c:forEach>
					</tbody>
			  </table>
           </div>   	
		</div>
		<div class="bottom">
			<a id="btnReq"	class="btnTypeDefault btnTypeChk"><%=AttendUtils.getRequestName(RedisDataUtil.getBaseConfig("HoliReqMethod"))%></a> 	<!-- 신청하기 -->
			<a id="btnClose"	class="btnTypeDefault"><spring:message code='Cache.btn_Cancel'/></a>				<!-- 취소 -->
		</div>
	</div>	
</div>
</body>
<script>
function funOnChangeSelect(){
	var strtTime = $('#StartHour').val()+":"+$("#StartMin").val();
	var endTime = $('#EndHour').val()+":"+$("#EndMin").val();
	if ("${holiRestYn}" == "Y"){
		$("#IdleTime").val((AttendUtils.getIdleTime2(strtTime, endTime, $("#NextDayYn").prop("checked"), "${holiWorkTime}", "${holiRestTime}")*60));
	}
	var acTime = AttendUtils.getAcTime2(strtTime, endTime, $("#NextDayYn").prop("checked"), $("#IdleTime").val())
	if ("${extenMaxTime}" != "" && "${extenMaxTime}" != "0" && acTime!=undefined){
		if (AttendUtils.convertStrToSec(acTime) > parseInt("${extenMaxTime}",10) *3600){
			Common.Warning("<spring:message code='Cache.mag_Attendance32'/>("+"${extenMaxTime}"+"H)"); //하루 최대 근무시간이 초과되어 신청할 수 없습니다.
			return false;
		}
	}

	$("#AcTime").val(acTime);
}
$(document).ready(function(){
	AttendUtils.getScheduleMonth( CFN_GetLocalCurrentDate("yyyy-MM-dd"), "calendar", "dateTitle", "", "calTbody");

	//event 세팅
	$(".WTemp_cal_wrap .pre").click(function(){
		AttendUtils.goScheduleNextPrev(-1, "calendar", "dateTitle", "calTbody");
	});
	$(".WTemp_cal_wrap .next").click(function(){
		AttendUtils.goScheduleNextPrev(1, "calendar", "dateTitle", "calTbody");
	});

	$('#StartHour').change(function() {
		if(parseInt($('#StartHour').val())>parseInt($('#EndHour').val()) &&$("#NextDayYn").prop("checked")===false){
			var sIdx = $('#StartHour').prop('selectedIndex');
			$('#EndHour').prop('selectedIndex', sIdx+1);
			sIdx = $('#EndHour').prop('selectedIndex');
			if(Number(sIdx)<0){
				$('#EndHour').prop('selectedIndex', 0);
				$("#NextDayYn").prop("checked",true);
			}
		}
		funOnChangeSelect();
	});
	$('#StartMin, #EndHour, #EndMin, #IdleTime').change(function() {
		funOnChangeSelect();
	});

	$("#NextDayYn").change(function(){
		funOnChangeSelect();
	});

	$('#btnReq').click(function(){
		if(!validationChk())     	return ;
		Common.Confirm("<spring:message code='Cache.ACC_isAppCk' />", "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
				reqHolidayWork();
			}	
		});				
	});
	
	$('#btnClose').click(function(){
		Common.Close();
	});	
	
});

$(document).on("click",".calDate",function(){
	var dataStr = $(this).find("div p").attr("data-map");
	if (dataStr == undefined || dataStr == "") {
		Common.Warning(Common.getDic("<spring:message code='Cache.mag_Attendance26' />"));			//근무가 설정되어 있지 않습니다.
		return false;
  	}
	else{
		var dataMap = JSON.parse(dataStr);
		if (dataMap["ConfmYn"] == "Y"){
			Common.Warning("<spring:message code='Cache.msg_apv_personnel_items_modify_refresh' />");
			return;
		}
		if (dataMap["WorkSts"]!="OFF" && dataMap["WorkSts"]!="HOL"){
			Common.Warning("<spring:message code='Cache.mag_Attendance33' />");			 //휴무(휴일)일 때만 가능합니다.
			return false;
		}
	}	
	$(this).toggleClass("selDate");
});

function validationChk(){
	var returnVal= true;
	if ($(".selDate").length == 0){
		 Common.Warning("<spring:message code='Cache.ACC_msg_selectDate'/>", "Warning Dialog", function () {     
        });
        return false;
	}
	// 시작시간 종료시간
	var attDayStartTime = $("#StartHour").val()+''+$("#StartMin").val();
	var attDayEndTime = $("#EndHour").val()+''+$("#EndMin").val();

	if(attDayStartTime>= attDayEndTime && !$("#NextDayYn").prop("checked")){
		Common.Warning(Common.getDic("msg_Mobile_InvalidStartTime"));			//시작일은 종료일 보다 이후일 수 없습니다.
		return false;
	}
	
	$(".selDate").each(function(idx, obj){
		var dataStr = $(obj).find("div p").attr("data-map");
   		if (dataStr == undefined || dataStr == "") {
   			Common.Warning(Common.getDic("<spring:message code='Cache.mag_Attendance26'/>"));			//근무가 설정되어 있지 않습니다.
			returnVal = false;
			return;	
   		}
		var dataMap = JSON.parse(dataStr);
		var dataMap = JSON.parse(dataStr);
		if (dataMap["WorkSts"]!="OFF" && dataMap["WorkSts"]!="HOL"){
			Common.Warning("<spring:message code='Cache.mag_Attendance33' />");			//휴무(휴일)일 때만 가능합니다.
			returnVal = false;
			return;	
		}
	});

	return returnVal;
}
function reqHolidayWork(){
	var StartTime = $("#StartHour").val()+''+$("#StartMin").val();
	var EndTime = $("#EndHour").val()+''+$("#EndMin").val();
	var NextDayYn = ($("#NextDayYn").prop("checked")?'Y':'N') ;

	var aJsonArray = new Array();
	$(".selDate").each(function(idx, obj){
		var saveData = { "WorkDate":$(obj).attr("title"), "StartTime":StartTime, "EndTime":EndTime, "NextDayYn":NextDayYn, "IdleTime":$("#IdleTime").val(), "AcTime":XFN_ReplaceAllSpecialChars($("#AcTime").val())};
        aJsonArray.push(saveData);
	});


	var saveJson ={
			"ReqType":"H",
			"ReqGubun":"C",
			"Comment":$("#Comment").val(),
			"ReqData":aJsonArray
	}
	
	//insert 호출		
	 $.ajax({
			type:"POST",
			contentType:'application/json; charset=utf-8',
			dataType   : 'json',
            url : "/groupware/attendReq/requestHolidayWork.do",
            data : JSON.stringify(saveJson),
            success : function(data){	
            	if(data.status=='SUCCESS'){
	            	Common.Inform("<spring:message code='Cache.msg_ProcessOk'/>","Information",function(){ //저장되었습니다.
					Common.Close();
	            	});
            	}else{
            		if (data.dupFlag == true){
	            		Common.Warning("<spring:message code='Cache.msg_att_overlapping_overtime'/>");
	            	}else if (data.errorCode != undefined ){
	            		var subMsg="";
	            		if (data.errorCode == "lbl_n_att_overTimeHour"){
		            		if (data.errorData != "-1"){
		            			subMsg = "["+AttendUtils.convertSecToStr(data.errorData)+"]";
		            		}
	            		}	
	            		Common.Warning(Common.getDic(data.errorCode)+subMsg);
	            	}	
	            	else{
	            		Common.Warning("<spring:message code='Cache.msg_apv_030'/>");
	            	}
	            }		
            },
            error:function(response, status, error){
                //TODO 추가 오류 처리
                CFN_ErrorAjax("attendReq/requestOverTime.do", response, status, error);
            }
        });
}

</script>