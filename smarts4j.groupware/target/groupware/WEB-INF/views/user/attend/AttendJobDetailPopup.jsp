<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8" import="egovframework.coviframework.util.RedisDataUtil,egovframework.baseframework.util.PropertiesUtil,egovframework.baseframework.util.SessionHelper"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
</head>
<style>
<%=(RedisDataUtil.getBaseConfig("SchConfmYn").equals("Y")&&SessionHelper.getSession("isAttendAdmin").equals("ADMIN")?"":".divConfm {display:none !important}")%>
<%=(RedisDataUtil.getBaseConfig("AssYn").equals("Y")?"":".divAss {display:none !important}")%>
<%=(RedisDataUtil.getBaseConfig("OutsideYn").equals("Y")?"":".divOutside {display:none !important}")%>
</style>
<body>
<form name="form1" id="form1" style="margin:0px;">
	<input type="hidden" id="JobDate" name="JobDate" value="${data.JobDate}">
	<input type="hidden" id="UserCode" name="UserCode" value="${data.UserCode}">
	<input type="hidden" id="SelfCommYn" name="SelfCommYn" value="${data.SelfCommYn}">
	<input type="hidden" id="SchSeq" name="SchSeq" value="${data.SchSeq}">
<div class="layer_divpop ui-draggable docPopLayer" style="width:100%;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">
		<div class="ATMgt_popup_wrap">
			<table class="ATMgt_popup_table type02" cellpadding="0" cellspacing="0">
				<tbody>
				<tr>
					<td class="ATMgt_T_th"><spring:message code="Cache.lbl_att_work"/> <spring:message code="Cache.lbl_type"/></td> <!-- 근무 유형 -->
					<td>
						<input type="radio" id="WorkingSystemType1" name="WorkingSystemType" value="0" ${data.WorkingSystemType==null || data.WorkingSystemType == '0'?"checked":""} disabled/>
						<label for="WorkingSystemType1"><spring:message code="Cache.lbl_designatedTime"/></label> <!-- 지정시간 -->
						<input type="radio" id="WorkingSystemType2" name="WorkingSystemType" value="1" ${data.WorkingSystemType == '1'?"checked":""} disabled/>
						<label for="WorkingSystemType2"><spring:message code="Cache.lbl_Autonomous"/></label> <!-- 자율 -->
						<input type="radio" id="WorkingSystemType3" name="WorkingSystemType" value="2" ${data.WorkingSystemType == '2'?"checked":""} disabled/>
						<label for="WorkingSystemType3"><spring:message code="Cache.lbl_Select"/>(<spring:message code="Cache.CPMail_Part"/>, <spring:message code="Cache.lbl_Totally"/>)</label> <!-- 선택(부분, 완전) -->
					</td>
				</tr>
                <tr>
                	<td class="ATMgt_T_th"><spring:message code='Cache.lbl_att_sch_name'/></td>
                	<td><input type="text" style="width:90%" placeholder="<spring:message code='Cache.lbl_att_sch_name'/>" id="SchName" name="SchName" class="WorkingStatusAdd_title_input w100" value="${data.SchName }" readonly></td>
				</tr>
				<tr id="CoreTimeTr" style="display: none;">
					<td class="ATMgt_T_th"><spring:message code='Cache.lbl_n_att_coreTime'/></td> <!-- 코어타임 -->
					<td>
						<div class="ATMgt_T_Time">
                               <span class="alarm type01"><input id="CoreTimeYn" value="Y" type="checkbox" ${data.CoreTimeYn!=null && data.CoreTimeYn == 'Y'?"checked":""} style="display:none">
                               <label class="onOffBtn ${data.CoreTimeYn!=null && data.CoreTimeYn == 'Y'?"on":""}" href="#" for="CoreTimeYn"><span></span></label></span>
							<input type="text" value="${data.CoreStartTimeHour}" name="CoreStartTimeHour" disabled></input>
							<input type="text" value="${data.CoreStartTimeMin}" name="CoreStartTimeMin" disabled></input>
							~
							<input type="text" value="${data.CoreEndTimeHour}" name="CoreEndTimeHour" disabled></input>
							<input type="text" value="${data.CoreEndTimeMin}" name="CoreEndTimeMin" disabled></input>
						</div>
						</td>
					</tr>
                <tr>
                	<td  class="ATMgt_T_th"><spring:message code='Cache.lbl_Time'/></td>
	               <td>
	               	<div class="ATMgt_T_Time wd">
						<select id="StartTimeHour" name="StartTimeHour">
						<c:forEach begin="00" end="23" var="hour">
							<option value="<c:out value="${ hour < 10 ? '0' : '' }${hour}"/>" <c:if test="${ hour == (data.StartTime!=null?fn:substring(data.StartTime,0,2):9) }">selected</c:if> ><c:out value="${ hour < 10 ? '0' : '' }${hour}" /></option>
						</c:forEach>
						</select>
						<span>:</span>
						<input type="text" name="StartTimeMin"  id="StartTimeMin" maxlength="2" value="${data.StartTime != null ? fn:substring(data.StartTime,2,4) : '00'}" />
						<span>-</span>
						<select id="EndTimeHour" name="EndTimeHour">
						<c:forEach begin="00" end="23" var="hour">
							<option value="<c:out value="${ hour < 10 ? '0' : '' }${hour}"/>" <c:if test="${ hour == (data.EndTime!=null?fn:substring(data.EndTime,0,2):18) }">selected</c:if> ><c:out value="${ hour < 10 ? '0' : '' }${hour}" /></option>
						</c:forEach>
						</select>
						<span>:</span> 
						<input type="text" name="EndTimeMin"  id="EndTimeMin" maxlength="2" value="${data.EndTime != null ? fn:substring(data.EndTime,2,4) : '00'}"/>
						<input type="checkbox" id="NextDayYn" name="NextDayYn" value="Y"   ${data.NextDayYn == 'Y'?"checked":""}/>
						<label for="NextDayYn"><spring:message code='Cache.lbl_NextDay' /></label>
					</div>	
                   </td>
                  </tr>
                  <tr class="divAss"> 
                	<td  class="ATMgt_T_th"><spring:message code='Cache.lbl_Assum'/>	<!-- 간주여부 --></td>
					<td>
						<div class="alarm type01">
							<input id="AssYn" name="AssYn" value="Y" type="checkbox" style="display:none" ${data.AssYn == 'Y'?"checked":""}>
							<label class="onOffBtn ${data.AssYn == 'Y'?"on":""}" href="#" for="AssYn"><span></span></label>
						</div>
						<select id="AssSeq" name="AssSeq" ${data.AssYn == 'Y'?"":"disabled"}>
							<c:forEach items="${assList}" var="list" varStatus="status">
								<option value="${list.AssSeq}" <c:if test="${ list.AssSeq == data.AssSeq }">selected</c:if> >${list.AssName}</option>
							</c:forEach>
						</select>
<!--  						<input class="size48 txtInputMin" type="checkbox" name="AssYn" id="AssYn" value="Y" ${data.AssYn == 'Y'?"checked":""}>-->
					</td>
				</tr>
				<tr id="AutoExtenTr" style="display: none;">
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_AutomaticOvertime'/></td> <!-- 자동연장근무 -->
						<td>
							<div class="ATMgt_T_Time">
							<span class="alarm type01"><input id="AutoExtenYn" value="Y" type="checkbox" ${data.AutoExtenYn != null && data.AutoExtenYn == 'Y'?"checked":""} style="display:none">
							<label class="onOffBtn ${data.AutoExtenYn != null && data.AutoExtenYn == 'Y'?"on":""}" href="#" for="AutoExtenYn"><span></span></label></span>
								<span><spring:message code='Cache.lbl_Minimum'/> <spring:message code='Cache.lbl_att_ac_time'/> : </span> <!-- 최소 인정시간 -->
								<input type="text" name="AutoExtenMinTime" value="${data.AutoExtenMinTime}" disabled></select>
								<span><spring:message code='Cache.lbl_Mail_Maximum'/> <spring:message code='Cache.lbl_att_ac_time'/> : </span> <!-- 최대 인정시간 -->
								<input type="text" name="AutoExtenMaxTime" value="${data.AutoExtenMaxTime}" disabled></input>
							</div>
						</td>
					</tr>
			</tbody>
		</table>
		<div class="ATMgt_memo_wrap ">
			<table class="ATMgt_popup_table type02" cellspacing="0" cellpadding="0">
				<tbody>
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_Memo'/></td>
	                    <td><textarea id="Etc" name="Etc" class="ATMgt_Tarea" rows="10" cols="1">${data.Etc}</textarea></td>
					</tr>
				</tbody>
			</table>
		</div>
		<div class="ATMgt_popup_check_wrap divOutside">
			<table class="ATMgt_popup_table type02" cellspacing="0" cellpadding="0">
				<tbody>
				<tr>
					<td class="ATMgt_T_th"><spring:message code='Cache.lbl_OutsideWork' /> <spring:message code='Cache.lbl_att_goWork' /></td> <!-- 근무지외 출근 -->
					<td>
						<div class="alarm type01">
							<input id="StartZoneYn" name="StartZoneYn" value="Y" type="checkbox" style="display:none" ${data.StartZone != null && data.StartZone != ''?"checked":""}>
							<label class="onOffBtn ${data.StartZone != null && data.StartZone != ''?"on":""}" href="#" for="StartZoneYn"><span></span></label>
						</div>
						<select name="GoWorkPlace">
							<option value="-1"><spring:message code='Cache.lbl_Mail_DirectInput' /></option> <!-- 직접입력 -->
						</select>
						<div class="searchBox03">
							<span>
								<input type="text" class="w100"  placeholder=""  id="StartZone" name="StartZone" value="${data.StartZone}" >
								<button class="btnSearchType01" type="button" id="btnMapStart"></button>
							</span>
						</div>
		            	<input type="text" readonly class="w100 mt5" placeholder="<spring:message code='Cache.lbl_Address' />" id="StartAddr" name="StartAddr" value="${data.StartAddr}" > <!-- 주소 -->
		            	<input type="hidden" style="width:100px" placeholder="X" id="StartPointX" name="StartPointX" value="${data.StartPointX}" >
		            	<input type="hidden" style="width:100px" placeholder="Y" id="StartPointY" name="StartPointY" value="${data.StartPointY}" >
					</td>
				<tr>	
				</tr>	
					<td class="ATMgt_T_th"><spring:message code='Cache.lbl_OutsideWork' /> <spring:message code='Cache.lbl_att_offWork' /></td> <!-- 근무지외 퇴근 -->
					<td>
						<div class="alarm type01">
							<input id="EndZoneYn" name="EndZoneYn" value="Y" type="checkbox" style="display:none" ${data.EndZone != null && data.EndZone != ''?"checked":""}>
							<label class="onOffBtn ${data.EndZone != null && data.EndZone != ''?"on":""}" href="#" for="EndZoneYn"><span></span></label>
						</div>
						<select name="OffWorkPlace">
							<option value="-1"><spring:message code='Cache.lbl_Mail_DirectInput' /></option> <!-- 직접입력 -->
						</select>
						<div class="searchBox03">
							<span>
								<input type="text" class="w100"  placeholder=""  id="EndZone" name="EndZone" value="${data.EndZone}" >
								<button class="btnSearchType01" type="button" id="btnMapEnd"></button>
							</span>
						</div>
		            	<input type="text" readonly class="w100 mt5"  placeholder="<spring:message code='Cache.lbl_Address' />" id="EndAddr" name="EndAddr" value="${data.EndAddr}"> <!-- 주소 -->
		            	<input type="hidden" style="width:100px" placeholder="X" id="EndPointX" name="EndPointX" value="${data.EndPointX}">
		            	<input type="hidden" style="width:100px" placeholder="Y" id="EndPointY" name="EndPointY" value="${data.EndPointY}">
					</td>
				</tr>
				<tr>
					<td class="ATMgt_T_th"><spring:message code='Cache.lbl_CoordinateRadius' />(m)</td> <!-- 좌표반경 -->
					<td><input class="w100" type="text" name="AllowRadius"  id="AllowRadius" maxlength="3" value="${data.AllowRadius}" /></td>
				</tr>
				</tbody>
			</table>	
            	
            	
		</div>
		<div class="bottom" >
			<c:if test="${ data.ConfmYn =='N'}">
				<a id="btnModify"	class="btnTypeDefault btnTypeBg"><spring:message code='Cache.lbl_Modify'/></a> 	<!-- 수정 -->
				<a id="btnDelete"	class="btnTypeDefault"><spring:message code='Cache.lbl_delete'/></a> 	<!-- 삭제 -->
				<a id="btnConfirm"	class="btnTypeDefault divConfm"><spring:message code='Cache.lbl_Apr_ConfirmYes'/></a> 	<!-- 확정 -->
			</c:if>	
			<c:if test="${ data.ConfmYn !='N'}">
				<a id="btnCancel"	class="btnTypeDefault divConfm"><spring:message code='Cache.lbl_apv_determine_cancel'/></a> 	<!-- 확정 -->
			</c:if>
			<a id="btnClose"	class="btnTypeDefault"><spring:message code='Cache.btn_Cancel'/></a>				<!-- 취소 -->
		</div>
	</div>
</div>

</form>	
</body>
<script>
$(document).ready(function(){
	
 	var isUseCoreTime = "${data.CoreTimeYn}";
 	var isUseAutoExten = "${data.AutoExtenYn}";

 	var GoWorkPlaceList;
	var OffWorkPlaceList;
	
	if(isUseCoreTime == "Y") {
		$("#CoreTimeTr").show();
	}
	
	if(isUseAutoExten == "Y") {
		$("#AutoExtenTr").show();
	}
	
	//event 세팅
	$('#btnModify').click(function(){
		saveJob();
	});
	
	$('#btnDelete').click(function(){
		deleteJob();
	});
	
	$('#btnConfirm').click(function(){
		confirmJob();
	});
	
	$('#btnCancel').click(function(){
		cancelJob();
	});
	
	$('#btnClose').click(function(){
		Common.Close();
	});	
	
	$('#btnMapStart').click(function(){
		var param = {"Zone":encodeURI($("#StartZone").val()), "Addr":encodeURI($("#StartAddr").val()), "PointX":$("#StartPointX").val(), "PointY":$("#StartPointY").val()};
		AttendUtils.openMapPopup('AttendSchedulePopup', "Start", param);
	});	
	
	$('#btnMapEnd').click(function(){
		var param = {"Zone":encodeURI($("#EndZone").val()), "Addr":encodeURI($("#EndAddr").val()), "PointX":$("#EndPointX").val(), "PointY":$("#EndPointY").val()};
		AttendUtils.openMapPopup('AttendSchedulePopup', "End", param);
	});	
	
	//토글
	$(".onOffBtn").click(function(e){
		if ($(this).attr("for")  == "AssYn"){	//간주인경우
			if ($("#SelfCommYn").val() == "Y") {
				Common.Inform("<spring:message code='Cache.mag_Attendance24' />");	//자율근무제인경우 간주을 설정할 수 없습니다.
				return;
			}
			$(this).toggleClass( "on" );
			$("#AssSeq").attr('disabled', !$(this).hasClass( "on" ));
		}
		else if($(this).attr("for") != "CoreTimeYn" && $(this).attr("for") != "AutoExtenYn"){
			$(this).toggleClass( "on" );
		}	
	});

	//출근지 설정
	var placeParams = {
		"SchSeq": $("#SchSeq").val()
		, "WorkPlaceType" : 0
	};
	$.ajax({
		type: "POST",
		url: "/groupware/attendJob/getWorkPlaceList.do",
		data: placeParams,
		success: function (data) {
			if(data.status != "SUCCESS"){
				Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); //	오류가 발생했습니다. 관리자에게 문의바랍니다
			} else {
				var workPlaceList = data.workPlaceList;
				GoWorkPlaceList = workPlaceList;
				for(var i=0; i<workPlaceList.length; i++) {
					var option = "<option value='" + i + "'>" + workPlaceList[i].WorkZone + "</option>";
					$("select[name=GoWorkPlace]").append(option);
				}
			}
		},
		error: function (error) {
			Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); //	오류가 발생했습니다. 관리자에게 문의바랍니다
		}
	});

	//퇴근지 설정
	placeParams = {
		"SchSeq": $("#SchSeq").val()
		, "WorkPlaceType" : 1
	};
	$.ajax({
		type: "POST",
		url: "/groupware/attendJob/getWorkPlaceList.do",
		data: placeParams,
		success: function (data) {
			if(data.status != "SUCCESS"){
				Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); //	오류가 발생했습니다. 관리자에게 문의바랍니다
			} else {
				var workPlaceList = data.workPlaceList;
				OffWorkPlaceList = workPlaceList;
				for(var i=0; i<workPlaceList.length; i++) {
					var option = "<option value='" + i + "'>" + workPlaceList[i].WorkZone + "</option>";
					$("select[name=OffWorkPlace]").append(option);
				}
			}
		},
		error: function (error) {
			Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); //	오류가 발생했습니다. 관리자에게 문의바랍니다
		}
	});

	$("select[name=GoWorkPlace]").change(function() {
		$("label[for = 'StartZoneYn']").addClass("on");
		$("#StartZoneYn").prop("checked", true);

		if(this.value == -1) {
			$("#StartZone").val("");
			$("#StartAddr").val("");
			$("#StartPointX").val("");
			$("#StartPointY").val("");
		} else {
			$("#StartZone").val(GoWorkPlaceList[this.value].WorkZone);
			$("#StartAddr").val(GoWorkPlaceList[this.value].WorkAddr);
			$("#StartPointX").val(GoWorkPlaceList[this.value].WorkPointX);
			$("#StartPointY").val(GoWorkPlaceList[this.value].WorkPointY);
		}
	});

	$("select[name=OffWorkPlace]").change(function() {
		$("label[for = 'EndZoneYn']").addClass("on");
		$("#EndZoneYn").prop("checked", true);

		if(this.value == -1) {
			$("#EndZone").val("");
			$("#EndAddr").val("");
			$("#EndPointX").val("");
			$("#EndPointY").val("");
		} else {
			$("#EndZone").val(OffWorkPlaceList[this.value].WorkZone);
			$("#EndAddr").val(OffWorkPlaceList[this.value].WorkAddr);
			$("#EndPointX").val(OffWorkPlaceList[this.value].WorkPointX);
			$("#EndPointY").val(OffWorkPlaceList[this.value].WorkPointY);
		}
	});
});
function setMapLocation(param){
	var mode =param["mode"] ;

	$("label[for = '"+mode+"ZoneYn']").addClass("on");

	$("#"+mode+"ZoneYn").prop("checked", true);
	$("#"+mode+"Zone").val(param["Zone"]);
	$("#"+mode+"Addr").val(param["Addr"]);
	$("#"+mode+"PointX").val(param["PointX"]);
	$("#"+mode+"PointY").val(param["PointY"]);
}

function saveJob(){
	if ($("#StartZoneYn").prop("checked")){
		if ($("#StartPointX").val() == "" || $("#StartPointY").val() == "")
		{
			Common.Inform("<spring:message code='Cache.msg_att_mapReLoadConfirm'/>");	//좌표설정
			return;
		}
	}else{
		if ($("#StartPointX").val() != "" || $("#StartPointY").val() != "")
		{
			Common.Inform("<spring:message code='Cache.msg_att_mapReLoadConfirm'/>");	//좌표해제
			return;
		}
	}
	
	if ($("#EndZoneYn").prop("checked")){
		if ($("#EndPointX").val() == "" || $("#EndPointY").val() == "")
		{
			Common.Inform("<spring:message code='Cache.msg_att_mapReLoadConfirm'/>");	//좌표설정
			return;
		}
	}else{
		if ($("#EndPointX").val() != "" || $("#EndPointY").val() != "")
		{
			Common.Inform("<spring:message code='Cache.msg_att_mapReLoadConfirm'/>");	//좌표해제
			return;
		}
	}
			
	
   	Common.Confirm("<spring:message code='Cache.msg_RUEdit' />", "Confirmation Dialog", function (confirmResult) {
		if (confirmResult) { 
			var params = jQuery("#form1").serialize();
			params+="&StartTime="+$("#StartTimeHour").val()+""+$("#StartTimeMin").val()+
					"&EndTime="+$("#EndTimeHour").val()+""+$("#EndTimeMin").val();

			$.ajax({
				type:"POST",
				data:params,
				url:"/groupware/attendJob/saveAttendJob.do",
				success:function (data) {
					if(data.result == "ok"){
						Common.Inform("<spring:message code='Cache.msg_Edited'/>");	//저장되었습니다.
						parent.searchData();
						Common.Close();
					}
					else{
						Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+data); //	오류가 발생했습니다. 관리자에게 문의바랍니다
					}
				},
				error:function (request,status,error){
					Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
				}
			});

		}		
	});	
			
}

function deleteJob(){
   	Common.Confirm("<spring:message code='Cache.msg_RUDelete' />", "Confirmation Dialog", function (confirmResult) {
		if (confirmResult) { 
			var aJsonArray = new Array();
            aJsonArray.push({ "UserCode":$("#UserCode").val(), "JobDate":$("#JobDate").val()});
				
			$.ajax({
				type:"POST",
				contentType:'application/json; charset=utf-8',
				dataType   : 'json',
				data:JSON.stringify({"dataList" : aJsonArray}),
				url:"/groupware/attendJob/delAttendJob.do",
				success:function (data) {
					if(data.result == "ok"){
						Common.Inform("["+data.resultCnt+"<spring:message code='Cache.lbl_DocCount'/>] <spring:message code='Cache.msg_136'/>");	//저장되었습니다.
						parent.searchData();
						Common.Close();
					}
					else{
						Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+data); //	오류가 발생했습니다. 관리자에게 문의바랍니다
					}
				},
				error:function (request,status,error){
					Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
				}
			});

		}		
	});	
			
}

function confirmJob(){
   	Common.Confirm("<spring:message code='Cache.lbl_apv_userItem_OK' />", "Confirmation Dialog", function (confirmResult) {
		if (confirmResult) { 
			var aJsonArray = new Array();
            aJsonArray.push({ "UserCode":$("#UserCode").val(), "JobDate":$("#JobDate").val()});
				
			$.ajax({
				type:"POST",
				contentType:'application/json; charset=utf-8',
				dataType   : 'json',
				data:JSON.stringify({"dataList" : aJsonArray  }),
				url:"/groupware/attendJob/confirmAttendJob.do",
				success:function (data) {
					if(data.result == "ok"){
						Common.Inform("["+data.resultCnt+"<spring:message code='Cache.lbl_DocCount'/>] <spring:message code='Cache.msg_136'/>");	//저장되었습니다.
						parent.searchData();
						Common.Close();
					}
					else{
						Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+data); //	오류가 발생했습니다. 관리자에게 문의바랍니다
					}
				},
				error:function (request,status,error){
					Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
				}
			});

		}		
	});	
			
}


function cancelJob(){
   	Common.Confirm("<spring:message code='Cache.lbl_apv_userItem_cancel' />", "Confirmation Dialog", function (confirmResult) {
		if (confirmResult) { 
			var aJsonArray = new Array();
            aJsonArray.push({ "UserCode":$("#UserCode").val(), "JobDate":$("#JobDate").val()});
				
			$.ajax({
				type:"POST",
				contentType:'application/json; charset=utf-8',
				dataType   : 'json',
				data:JSON.stringify({"dataList" : aJsonArray  }),
				url:"/groupware/attendJob/confirmCancelAttendJob.do",
				success:function (data) {
					if(data.result == "ok"){
						Common.Inform("["+data.resultCnt+"<spring:message code='Cache.lbl_DocCount'/>] <spring:message code='Cache.msg_136'/>");	//저장되었습니다.
						parent.searchData();
						Common.Close();
					}
					else{
						Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+data); //	오류가 발생했습니다. 관리자에게 문의바랍니다
					}
				},
				error:function (request,status,error){
					Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
				}
			});

		}		
	});	
			
}

</script>