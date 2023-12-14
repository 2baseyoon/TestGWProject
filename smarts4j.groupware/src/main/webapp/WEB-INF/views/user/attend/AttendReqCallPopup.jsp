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
				<tbody>
					<tr>
		               	<td class="ATMgt_T_th"><spring:message code='Cache.lbl_Time'/></td>
				    	<td>
				    		<span id="callList" style="z-index:2099px;scroll-y:auto;position: relative;overflow-y: auto;height: 300pox;"></span>
				    	</td>
					</tr>	
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_Approver' /></td>
						<td>${UR_ManagerName}</td>
					</tr>
					<tr>
						<td class="ATMgt_T_th"><spring:message code='Cache.lbl_Remark'/></td>
						<td><textarea id="Comment" name="Comment" class="ATMgt_Tarea"></textarea></td>
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
			<a id="btnReq"	class="btnTypeDefault btnTypeChk"><%=AttendUtils.getRequestName(RedisDataUtil.getBaseConfig("CommuModReqMethod"))%></a> 	<!-- 신청하기 -->
			<a id="btnClose"	class="btnTypeDefault"><spring:message code='Cache.btn_Cancel'/></a>				<!-- 취소 -->
		</div>
	</div>	
</div>
</body>
<script>

var callBackFunc = CFN_GetQueryString("callBackFunc") == "undefined" ? "" : CFN_GetQueryString("callBackFunc");
var SelDate = CFN_GetQueryString("SelDate") == "undefined" ? "" : CFN_GetQueryString("SelDate");
var ReqUserCode = CFN_GetQueryString("ReqUserCode") == "undefined" ? Common.getSession("USERID") : CFN_GetQueryString("ReqUserCode");
var ReqUserName = CFN_GetQueryString("ReqUserName") == "undefined" ? Common.getSession("USERNAME") : CFN_GetQueryString("ReqUserName");

if(SelDate != ""){
	AttendUtils.getScheduleMonth( SelDate , "calendar", "dateTitle", "CMT", "calTbody");
}else{
	AttendUtils.getScheduleMonth( CFN_GetLocalCurrentDate("yyyy-MM-dd"), "calendar", "dateTitle", "CMT", "calTbody");
}
$(document).ready(function(){
	if(SelDate != ""){
		setTimeout(function(){$(".calDate[title='"+ SelDate+"']").click();},500);
	}
	//event 세팅
	$(".WTemp_cal_wrap .pre").click(function(){
		AttendUtils.goScheduleNextPrev(-1, "calendar", "dateTitle", "CMT", "calTbody");
	});
	$(".WTemp_cal_wrap .next").click(function(){
		AttendUtils.goScheduleNextPrev(1, "calendar", "dateTitle", "CMT", "calTbody");
	});
    
	$('#btnReq').click(function(){
		if(!validationChk())     	return ;
		Common.Confirm("<spring:message code='Cache.ACC_isAppCk' />", "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
				reqCall();
			}	
		});				
	});
	
	$('#btnClose').click(function(){
		Common.Close();
	});	
	
});

$(document).on("click",".calDate",function(){
	var dataStr = $(this).find("div p").attr("data-map");
	if (dataStr != undefined && dataStr != "") {
		var dataMap = JSON.parse(dataStr);
		if (dataMap["Call"]==true){
			if (dataMap["ConfmYn"] == "Y"){
				Common.Warning("<spring:message code='Cache.msg_apv_personnel_items_modify_refresh' />");
				return;
			}
			
			if ($(this).hasClass("selDate")){
				$('#callList #jobItem :input[value="'+dataMap["JobDate"]+'"]').closest("#jobItem").remove();
//				$(this).closest("#jobItem").remove();
//				$("#callList #jobItem").find
			} else {
				var html ="";
				var findCol = [["StartSts", "lbl_att_normal_goWork", "AttStartTime",Common.getDic("lbl_attendance")]
						, ["EndSts", "lbl_att_normal_offWork", "AttEndTime",Common.getDic("lbl_att_offWork")]]
				for (var i=0;  i< findCol.length; i++){
	
					if ((dataMap[findCol[i][0]] == null || dataMap[findCol[i][0]]!=findCol[i][1]) )
					{
						html +='<span id="jobItem" class="ATMgt_T_Time wd mt5">'+
						'<input type="text" name="WorkDate" id="WorkDate" style="width:100px;" disabled value="'+dataMap["JobDate"]+'">'+
			    		'<input type="text" disabled value="'+findCol[i][3]+'" />'+
			    		'<input type="hidden" name="Division"  id="Division" value="'+findCol[i][0]+'" />'+
						'<input type="text" disabled name="OrgTime"  id="OrgTime" style="width:120px" class="mr10" value="'+(dataMap[findCol[i][2]]==null?"":dataMap[findCol[i][2]])+'"/>'+
						'<select id="ChgHour" name="ChgHour" style="width:40px;" >';
						for (var j=0; j <24; j++){		html+='		<option value='+(j< 10 ? '0' : '')+j+' >'+(j< 10 ? '0' : '')+j+'</option>';		}
						html +='</select>'+
						'<span>:</span>'+ 
						'<input type="text" name="ChgMin"  id="ChgMin" maxlength="2" value="00" style="width:40px"/>'+
						'<input type="checkbox" id="NextDayYn" name="NextDayYn" value="Y"  />'+
						'<label for="NextDayYn"><spring:message code="Cache.lbl_NextDay"/></label>'+
						'<!--<a class="btn_del" href="#">Del</a>-->'+
						'</span>';
					}
				}
	
				$("#callList").append(html);
			}	
			$(this).toggleClass("selDate");
		}
  	}
	
});

$(document).on("click",".btn_del",function(){
//	alert($(this).closest("#jobItem").index());
	var workDate = $(this).closest("#jobItem").find("#WorkDate").val();
//	if (alert(workDate))
	$(this).closest("#jobItem").remove();
});


function validationChk(){
	var returnVal= true;
	if ($(".selDate").length == 0){
		 Common.Warning("<spring:message code='Cache.ACC_msg_selectDate'/>", "Warning Dialog", function () {     
        });
        return false;
	}
	/* 시작시간 종료시간
	var attDayStartTime = $("#StartHour").val()+''+$("#StartMin").val();
	var attDayEndTime = $("#EndHour").val()+''+$("#EndMin").val();

	if(attDayStartTime>= attDayEndTime && !$("#NextDayYn").prop("checked")){
		Common.Warning(Common.getDic("msg_Mobile_InvalidStartTime"));			//시작일은 종료일 보다 이후일 수 없습니다.
		return false;
	}*/
	
	$(".selDate").each(function(idx, obj){
		var dataStr = $(obj).find("div p").attr("data-map");
   		if (dataStr == undefined || dataStr == "") {
   			Common.Warning(Common.getDic("<spring:message code='Cache.mag_Attendance31' />"));			 //소명 대상건이 아닙니다.
			returnVal = false;
			return;	
   		}
   		else{
   			var dataMap = JSON.parse(dataStr);
   			if (dataMap["Call"]!=true){
   	   			Common.Warning(Common.getDic("<spring:message code='Cache.mag_Attendance31' />"));			//소명 대상건이 아닙니다.
   				returnVal = false;
   				return;	
   			}
   		}
	});
	
	$("#callList #jobItem").each(function(idx, obj){
//		$(obj).find("#EndHour")
//		var saveData = { "WorkDate":$(obj).attr("title"), "StartTime":StartTime, "EndTime":EndTime, "NextDayYn":NextDayYn};
		
	})
	
	
	if (returnVal == false) return returnVal;
	
	return returnVal;
}

function reqCall(){
//	var StartTime = $("#StartHour").val()+''+$("#StartMin").val();
//	var EndTime = $("#EndHour").val()+''+$("#EndMin").val();
//	var NextDayYn = ($("#NextDayYn").prop("checked")?'Y':'N') ;

	var aJsonArray = new Array();
	$("#callList #jobItem").each(function(idx, obj){
		var WorkDate = $(obj).find("#WorkDate").val();
		var OrgTime = $(obj).find("#OrgTime").val();
		var Division = $(obj).find("#Division").val();
		var ChgTime = $(obj).find("#ChgHour").val()+''+$(obj).find("#ChgMin").val();
		var NextDayYn = ($(obj).find("#NextDayYn").prop("checked")?'Y':'N') ;

		var saveData = { "WorkDate":WorkDate, "OrgTime":OrgTime, "Division":Division, "ChgTime":ChgTime, "NextDayYn":NextDayYn, "ReqUserCode":ReqUserCode, "ReqUserName":ReqUserName };
        aJsonArray.push(saveData);
	});

	var saveJson ={
			"ReqType":"C",
			"ReqGubun":"C",
			"Comment":$("#Comment").val(),
			"ReqData":aJsonArray
	}
	//insert 호출		
	 $.ajax({
			type:"POST",
			contentType:"application/json; charset=utf-8",
			dataType   : "json",
            url : "/groupware/attendReq/requestCall.do",
            data : JSON.stringify(saveJson),
            success : function(data){	
            	if(data.status=='SUCCESS'){
	            	Common.Inform("<spring:message code='Cache.msg_ProcessOk'/>","Information",function(){ //저장되었습니다.
	        			if(callBackFunc){
	        				try{
	    			    			callBackFunc = "parent.window."+callBackFunc+"()";
	    			    			new Function (callBackFunc).apply();
	        						Common.Close();
	        				}catch(e){
	        					console.error(e);
	        				}
	        			}else{
	        				Common.Close();
	        			}
	            	});
            	}else{
            		Common.Warning("<spring:message code='Cache.msg_apv_030'/>");
            	}
            },
            error:function(response, status, error){
                //TODO 추가 오류 처리
                CFN_ErrorAjax("attendReq/requestJobStatus.do", response, status, error);
            }
        });
}


</script>