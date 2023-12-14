<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script type="text/javascript" src="/groupware/resources/script/user/resource.js"></script>

<style>
	.bottom { text-align: center; margin-top: 10px; }
	.AXFormTable textarea { width: 101%; resize: none; }
	.AXFormTable tbody th { text-align: center; }
</style>

<div class="divpop_contents" style="height:100%;">
	<div class="divpop_body" style="overflow:hidden; padding:0;">
		<div class="popContent">
			<div class="middle">
				<table class="AXFormTable">
					<colgroup>
						<col style="width:100px;">
						<col style="width:*">
					</colgroup>
					<tbody>
						<tr>
							<th><span><spring:message code="Cache.lbl_Purpose"/></span></th> <!-- 용도 -->
							<td>
								<textarea id="txtSubject" class="HtmlCheckXSS ScriptCheckXSS" rows="12" placeholder="<spring:message code='Cache.msg_ReservationWrite_01'/>"></textarea> <!-- 용도를 입력해주세요. -->
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			<div class="bottom">
				<a href="#" id="btnRegist" class="btnTypeDefault btnTypeChk"><spring:message code="Cache.btn_register"/></a> <!-- 등록 -->
				<a href="#" id="btnCancel" class="btnTypeDefault"><spring:message code="Cache.btn_Cancel"/></a> <!-- 취소 -->
			</div>
		</div>
	</div>
</div>

<script>
	var resourceID = CFN_GetQueryString("resourceID") == "undefind" ? "" : CFN_GetQueryString("resourceID");
	var resDate = CFN_GetQueryString("resDate") == "undefind" ? "" : CFN_GetQueryString("resDate").replaceAll(".", "-");
	
	function init(){
		setEvent();
	}
	
	function setEvent(){
		$("#btnCancel").off("click").on("click", function(){
			Common.Close();
		});
		
		$("#btnRegist").off("click").on("click", function(){
			saveBookingData();
		});
	}
	
	function setResourceData(){
		var sTime = CFN_GetQueryString("sTime") == "undefind" ? "" : CFN_GetQueryString("sTime");
		var eTime = CFN_GetQueryString("eTime") == "undefind" ? "" : CFN_GetQueryString("eTime");
		
		var eventObj = {};
		var event = {};
		var date = {};
		var repeat = {};
		var notification = {};
		var userForm = new Array();
		
		eventObj.ResourceID = resourceID;
		event.FolderID = resourceID;
		
		event.Subject = $("#txtSubject").val();
		event.Description = "";
		eventObj.IsSchedule = "N";
		
		date.StartDate = resDate;
		date.EndDate = resDate;
		date.StartTime = sTime;
		date.EndTime = eTime;
		
		event.FolderType = "Resource";
		event.RegisterCode = sessionObj["USERID"];
		event.MultiRegisterName = sessionObj["USERNAME"];
		
		date.IsAllDay = "N";
		date.IsRepeat = "N";
		
		repeat = {};
		
		notification.IsNotification = "N";
		notification.IsReminder = "N";
		notification.ReminderTime = "10";
		notification.IsCommentNotification = "N";
		notification.MediumKind = "";
		
		eventObj.Event = event;
		eventObj.Date = date;
		eventObj.Repeat = repeat;
		eventObj.Notification = notification;
		eventObj.UserForm = userForm;
		
		return eventObj;
	}
	
	function saveBookingData(){
		if (!XFN_ValidationCheckOnlyXSS(false)) return false;
		
		if(!$("#txtSubject").val()){
			Common.Warning("<spring:message code='Cache.msg_ReservationWrite_01'/>"); // 용도를 입력해주세요.
			$("#txtSubject").focus();
			return false;
		}
		
		var eventObj = setResourceData();
		var formData = new FormData();
		
		formData.append("mode", "I");
		formData.append("eventStr", JSON.stringify(eventObj));
		formData.append("fileInfos", "[]");
	    formData.append("fileCnt", 0);
		
		if(resourceUser.checkValidationResource(eventObj)){
			$.ajax({
				url: "/groupware/resource/saveBookingData.do",
				type: "POST",
				data: formData,
				processData: false,
				contentType: false,
				success: function(res){
					if(res.status == "SUCCESS" && res.result == "OK"){
						var callBackFunc = CFN_GetQueryString("callBackFunc") == "undefined" ? "" : CFN_GetQueryString("callBackFunc");
						var openerID = CFN_GetQueryString("openerID") == "undefined" ? "" : CFN_GetQueryString("openerID");
						
						//예약한 자원 쿠키 저장
						coviCmn.setCookie("recentReservation", resourceID, 1);
						
						Common.Inform(res.message, "Information", function(){
							if(callBackFunc){
		        				try{
		        					if(openerID){
		    			    			XFN_CallBackMethod_Call(openerID, callBackFunc, "");
		    			    		}else{
		    			    			if(callBackFunc == "meetingRoom.meetingReservation") {
		    			    				parent.$("#meetingRoomName").trigger("change");
		    			    			} else {
			    			    			callBackFunc = "parent.window."+callBackFunc+"('" + resourceID + "', '" + resDate + "')";
			    			    			new Function (callBackFunc).apply();
		    			    			}
		    						}
		        					Common.Close();
		        				}catch(e){
		        					console.error(e);
		        				}
		        			}else{
		        				Common.Close();
		        			}
						});
					}
					else if(res.status == "SUCCESS" && res.result == "DUPLICATION"){
						Common.Warning(res.message);
					}
					else {
						Common.Error(Common.getDic("msg_apv_030"));		// 오류가 발생했습니다.
					}
				},
				error: function(response, status, error){
					CFN_ErrorAjax("/groupware/resource/saveBookingData.do", response, status, error);
				}
			});
		}
	}
	
	init();
</script>