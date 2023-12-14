<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<% String approvalAppPath = PropertiesUtil.getGlobalProperties().getProperty("approval.app.path"); %>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<!doctype html>
<html lang="ko">
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<style>

	.layer_divpop table,p {font-size:12px}
	.attSel {}

</style>
<body>	

<!-- 근태기록 추가 및 수정 팝업 시작 -->
<!-- <div class="layer_divpop" style="width:500px; left:0; top:0; z-index:104;"> -->
<div class="layer_divpop ui-draggable docPopLayer" style="width:100%;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="" style="overflow:hidden; padding:0;">
		<div class="ATMgt_popup_wrap">
			<p class="ATMgt_popup_title" id="titleDate">&nbsp;</p>
			<table class="ATMgt_popup_table type02" cellpadding="0" cellspacing="0">
				<tbody>
					<!-- <tr>
						<td class="ATMgt_T_th">지점</td>
						<td><p class="tx_company">본사</p></td>
					</tr> -->
					<tr> 
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_n_att_worktype' />/<spring:message code='Cache.lbl_SmartDept' /></td>
						<td><p class="tx_dept" id="at_dept"></p></td>
					</tr>
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_n_att_Staff' /></td> 	
						<td><p class="tx_company" id="at_name"></p></td>
					</tr>
					<tr> 
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_n_att_selectWorkSchTemp' /></td>
						<td><p class="tx_template" id="at_schName"></p></td>
					</tr>
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_date' /></td>
						<td>
							<div class="dateSel type02">
								<input class="adDate" data-axbind="date" date_separator="."  type="text" id="AXInput-1" kind="date" >
							</div>
						</td>
					</tr>
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_startdate2' /></td> 
						<td>
							<div class="ATMgt_T_Time dateSel type02">
								<input class="adDate" data-axbind="date" date_separator="." type="text" id="AXInput-2" kind="date" style="width: 102px;text-align: left;"  >
								<select id="at_startHour" class='attSel' style="width:40px">
									<option value="" ><spring:message code='Cache.lbl_Hour' /></option>
									<c:forEach begin="01" end="12" var="hour">
										<option value="<c:out value="${ hour < 10 ? '0' : '' }${hour}"/>"><c:out value="${ hour < 10 ? '0' : '' }${hour}" /></option>
									</c:forEach>
								</select> 
								<span>:</span>
								<select id="at_startMin" class='attSel' style="width:40px">
									<option value="" ><spring:message code='Cache.lbl_Minutes' /></option>
									<c:forEach begin="00" end="59" var="min">
										<option value="<c:out value="${ min < 10 ? '0' : '' }${min}"/>"><c:out value="${ min < 10 ? '0' : '' }${min}" /></option>
									</c:forEach>
								</select>
								<select id="at_startAP">
									<option value=""><spring:message code='Cache.btn_Select' /></option>
									<option value="AM">AM</option>
									<option value="PM">PM</option>
								</select>
							</div>
						</td>
					</tr>
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_EndDate3' /></td>
						<td>
							<div class="ATMgt_T_Time dateSel type02">
								<input class="adDate" data-axbind="date" date_separator="." type="text" id="AXInput-3" kind="date" style="width: 102px;text-align: left;" >
								<select id="at_endHour" class='attSel' style="width:40px">
									<option value="" ><spring:message code='Cache.lbl_Hour' /></option>
									<c:forEach begin="01" end="12" var="hour">
										<option value="<c:out value="${ hour < 10 ? '0' : '' }${hour}"/>"><c:out value="${ hour < 10 ? '0' : '' }${hour}" /></option>
									</c:forEach>
								</select>
								<span>:</span>
								<select id="at_endMin" class='attSel' style="width:40px">
									<option value="" ><spring:message code='Cache.lbl_Minutes' /></option>
									<c:forEach begin="00" end="59" var="min">
										<option value="<c:out value="${ min < 10 ? '0' : '' }${min}"/>"><c:out value="${ min < 10 ? '0' : '' }${min}" /></option>
									</c:forEach>
								</select>
								<select id="at_endAP">
									<option value=""><spring:message code='Cache.btn_Select' /></option>
									<option value="AM">AM</option>
									<option value="PM">PM</option>
								</select>
							</div>
						</td>
					</tr>
				</tbody> 
			</table>
			<div class="ATMgt_memo_wrap mb20">
				<table class="ATMgt_popup_table type02" cellpadding="0" cellspacing="0">
					<tbody>
						<tr>
							<td class="ATMgt_T_th"><spring:message code='Cache.lbl_User' /> <spring:message code='Cache.lbl_Remark' /></td>
							<td><p class="" id="at_userEtc"></p></td>
						</tr> 
						<tr>
							<td class="ATMgt_T_th"><spring:message code='Cache.lbl_admin' /> <spring:message code='Cache.lbl_Remark' /></td>
							<td><textarea class="ATMgt_Tarea" id="at_etc"></textarea></td>
						</tr>
					</tbody>
				</table>
			</div>
			<div class="bottom">
				
				<c:choose>
					<c:when test='${attMap eq "" or attMap == null  }'>
					<a href="#" class="btnTypeDefault btnTypeBg" id="saveBtn"><spring:message code='Cache.lbl_Regist'/></a>
					</c:when>
					<c:otherwise>
					<a href="#" class="btnTypeDefault btnTypeBg" id="cancelBtn"><spring:message code='Cache.btn_att_del'/></a>
					<a href="#" class="btnTypeDefault btnTypeBg" id="saveBtn"><spring:message code='Cache.btn_att_upd'/></a>
					</c:otherwise>
				</c:choose>
				<a href="#" class="btnTypeDefault" onclick="parent.Common.close('AttendAttStstusPopup');"><spring:message code='Cache.lbl_close'/></a>
			</div>
		</div>				
	</div>
</div>
<!-- 근태기록 추가 및 수정 팝업 끝 -->
<input type="hidden" id="userCode" value="" >
</body>
<script>

var jsonStr = '${attMap}';
var attMap = jsonStr != "" ? JSON.parse(jsonStr) : null;


$(document).ready(function(){
	init();
	coviInput.setDate();
});

function init(){	

	if(attMap != null && attMap != ''){
		setUserInfo();		
	}else{
		//근태기록 추가 시 조직도 내에서 사용자 단건 조회 가능하도록 
		$("#at_name").on('click',function(){
			//조직도 팝업
			parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_DeptOrgMap' />","/covicore/control/goOrgChart.do?callBackFunc=orgMapLayerPopupCallBack&type=A1","520","580","iframe",true,null,null,true);	//조직도
		});
		
		$("#AXInput-1").on('change',function(){
			if($("#userCode").val() != "" && $("#userCode").val() != null ){
				getUserAttData();
			}else{
				Common.Warning("<spring:message code='Cache.msg_n_att_stsSetPop1' />");	//직원정보를 선택 해 주세요	
				$("#AXInput-1").val("");
			}
		});
	}
	
	$("#saveBtn").on('click',function(){
		setUserAttData('U');
	});
	$("#cancelBtn").on('click',function(){
		setUserAttData('D');
	});
	
}


function setUserInfo(){
	
	$("#userCode").val(attMap.UserCode);
	$("#at_dept").html(attMap.DeptName);
	$("#at_name").html(attMap.DisplayName);
	$("#at_schName").html(attMap.SchName);
	$("#AXInput-1").val(attMap.TargetDate);
	$("#AXInput-1").attr("readonly","");
	$("#titleDate").html(attMap.TargetDate_KOR);
	
	if(attMap.AttStartTime != null && attMap.AttStartTime != ''){
		$("#AXInput-2").val(attMap.AttStart_Date);
		$("#at_startHour").val(attMap.AttStart_Hour);
		$("#at_startMin").val(attMap.AttStart_Min);
		$("#at_startAP").val(attMap.AttStart_AP);
	}

	if(attMap.AttEndTime != null && attMap.AttEndTime != ''){
		$("#AXInput-3").val(attMap.AttEnd_Date);
		$("#at_endHour").val(attMap.AttEnd_Hour);
		$("#at_endMin").val(attMap.AttEnd_Min);
		$("#at_endAP").val(attMap.AttEnd_AP);
	}
	$("#at_userEtc").html(attMap.UserEtc);
	
	$("#at_etc").val(attMap.Etc.replaceAll("<br>", "\n"));
}

function getUserAttData(){
	var params = {
			targetDate : $("#AXInput-1").val()
			,userCode : $("#userCode").val()
	};
	
	$.ajax({
		type:"POST",
		dataType : "json",
		data: params,
		url:"/groupware/attendUserSts/getUserAttData.do",
		success:function (data) {
			if(data.status =="SUCCESS"){
				attMap = data.attMap;
				if(attMap != null && attMap != ''){
					parent.attPopValueClear();
					setUserInfo();	
					$("#AXInput-1").removeAttr("readonly");
				}
			}else{
				Common.Warning("<spring:message code='Cache.msg_sns_03'/>");
			}
		}
	});  
}

function attValidCheck(){
	if($("#userCode").val() == "" || $("#userCode").val() == null ) {
		Common.Warning(Common.getDic("msg_n_att_stsSetPop1"));	//직원정보를 선택 해 주세요	
		return false;
	}else if($("#AXInput-1").val() == "" || $("#AXInput-1").val() == null ){
		Common.Warning(Common.getDic("msg_att_workDate_isNull"));	//근무일을 선택 해 주세요
		return false;
	}else{
		return true;
	}
}

function setUserAttData(type){
	if(attValidCheck()){
		var startDate;
		if($("#AXInput-2").val()!=null && $("#AXInput-2").val() != ""){
			var startTime = AttendUtils.timeToDBFormat($("#at_startHour").val(),$("#at_startMin").val(),'00',$("#at_startAP").val(),':');
			startDate = AttendUtils.dateToDBFormat(new Date(replaceDate($("#AXInput-2").val())))+" "+startTime;
		}
		var endDate;
		if($("#AXInput-3").val()!=null && $("#AXInput-3").val() != ""){
			var endTime = AttendUtils.timeToDBFormat($("#at_endHour").val(),$("#at_endMin").val(),'00',$("#at_endAP").val(),':');
			endDate = AttendUtils.dateToDBFormat(new Date(replaceDate($("#AXInput-3").val())))+" "+endTime;
		}
			
		var params = {
			"targetDate" : $("#AXInput-1").val(),
			"userCode" : $("#userCode").val(),
			"startDate" : startDate,
			"endDate" : endDate,
			"etc" : $("#at_etc").val(),			
			"type" : type,
			"commuteChannel" : "I"
		};
		
		$.ajax({
			type:"POST",
			dataType : "json",
			data: params,
			url:"/groupware/attendCommute/setCommuteMng.do",
			success:function (data) {
				if(data.status =="SUCCESS"){
					parent.Common.Inform("<spring:message code='Cache.msg_Been_saved'/>");	//저장되었습니다.
					//parent.getCommuteData();
					parent.reLoadList();
					Common.Close();		
				}else{
					Common.Warning("<spring:message code='Cache.msg_sns_03'/>");
				}
			}
		});  
	}
}





</script>
