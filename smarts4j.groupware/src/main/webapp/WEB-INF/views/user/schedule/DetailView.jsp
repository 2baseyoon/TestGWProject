<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<%
	pageContext.setAttribute("isRepeatAll", request.getParameter("isRepeatAll"));
%>

<div id="divSheet" style="z-index: 50;background-color: white;position: relative;width: 100%;height: 100%;"></div>
<div class="cRConTop ">
	<div id="divBtnTop" class="cRTopButtons">
		<a onclick="CoviMenu_GetContent(g_lastURL);" id="btnList" class="btnTypeDefault btnTypeLArrr"><spring:message code='Cache.lbl_Index' /></a><!-- 목록 -->
		<a onclick="scheduleUser.modifyScheduleEvent('N', 'Y');" id="btnCopy" class="btnTypeDefault"><spring:message code='Cache.btn_Copy' /></a><!-- 복사 -->
	</div>
	<div class="surveySetting">
		<a class="btnPrintIcon" onclick="scheduleUser.openPrintDetailView();"><spring:message code='Cache.lbl_Index' /><spring:message code='Cache.lbl_printEng' /></a><!-- 프린트 -->
		<!-- <a class="surveryWinPop">팝업</a> -->
	</div>
</div>
<div class='cRContBottom mScrollVH '>
	<div id="scheduleContentDiv" class="scheduleContentType02">
		<div class=" cRContBtmTitle">
			<div >
				<div id="FolderID" class="boxDivTit"></div>
			</div>
			<div class="boardTitle">
				<h2 id="Subject"></h2>
				<!-- 자주  쓰는  일정 등록 텍스트 클릭시 btnSchLayerAdd -->
				<a id="btnAddTemplate" title="<spring:message code='Cache.lbl_schedule_addFavoriteSch' />" onclick="scheduleUser.addTemplateScheduleData(CFN_GetQueryString('eventID'));" class="btnSchLayerAddTxt"><span class="btnSchLayerAdd"></span><spring:message code='Cache.lbl_schedule_addFavoriteSch' /></a><!-- 자주 쓰는 일정 등록 -->
			</div>
		</div>
		<div class="boardViewCont">
			<div class="bvcTitle">
				<div class="personBox">
					<div class="perPhoto">
						<img id="RegisterPhoto" onerror="coviCmn.imgError(this, true);" src="" alt="<spring:message code='Cache.lbl_ProfilePhoto' />"><!-- 프로필사진 -->
					</div>
					<p class="name" id="Register"></p>
					<div class="attFileListBox"></div>					<!-- 첨부파일 -->
				</div>
			</div>
			<div id="divNotification" class="boradAlarmBox" style="display:none;">
				<div class="inputBoxSytel01">
					<div>
						<div id="IsNotificationDiv" class="alarm type01" onclick="alarmOnClick(this);saveAlarm('All');">
							<c:choose>
								<c:when test="${isRepeatAll == 'Y'}">
									<span><spring:message code='Cache.lbl_totalAlarm' /></span><!-- 전체알림 -->
								</c:when>
								<c:otherwise>
									<span><spring:message code='Cache.lbl_Alram' /></span><!-- 알림 -->
								</c:otherwise>
							</c:choose>
							<a id="IsNotification" class="onOffBtn"><span></span></a>
						</div>
					</div>
					<div id="NotificationType"  class="noticeMedia off">
						<div id="IsReminderA" class="alarm type01" style="margin-left: -8px; margin-right: 0;" onclick="alarmOnClick(this);saveAlarm('Reminder');">
							<span><spring:message code='Cache.lbl_BeforInform' /></span><!-- 미리알림 -->
							<a class="onOffBtn"><span></span></a>
						</div>
						<select id="ReminderTime" class="selectType02" onchange="saveAlarm('Reminder');" disabled="disabled" style="vertical-align: baseline;">
							<option value="1"><spring:message code='Cache.lbl_AlramTime_1' /></option><!-- 1분전 -->
							<option selected="selected" value="10"><spring:message code='Cache.lbl_AlramTime_10' /></option><!-- 10분전 -->
							<option value="20"><spring:message code='Cache.lbl_AlramTime_20' /></option><!-- 20분전 -->
							<option value="30"><spring:message code='Cache.lbl_AlramTime_30' /></option><!-- 30분전 -->
							<option value="60"><spring:message code='Cache.lbl_AlramTime_60' /></option><!-- 1시간전 -->
							<option value="180"><spring:message code='Cache.lbl_AlramTime_180' /></option><!-- 3시간전 -->
							<option value="360"><spring:message code='Cache.lbl_AlramTime_360' /></option><!-- 6시간전 -->
							<option value="720"><spring:message code='Cache.lbl_AlramTime_720' /></option><!-- 12시간전 -->
							<option value="4320"><spring:message code='Cache.lbl_AlramTime_4320' /></option><!-- 3일전 -->
							<option value="2880"><spring:message code='Cache.lbl_AlramTime_2880' /></option><!-- 2일전 -->
							<option value="1440"><spring:message code='Cache.lbl_AlramTime_1440' /></option><!-- 1일전 -->
						</select>
						<div id="IsCommentA" class="alarm type01"onclick="alarmOnClick(this);saveAlarm('Comment');" style="display:none;">
							<span><spring:message code='Cache.lbl_Comments' /></span><!-- 댓글 -->
							<a class="onOffBtn"><span></span></a>
						</div>
						<input type="hidden" id="IsNotification" value="N">
						<input type="hidden" id="IsReminder" value="N">
						<input type="hidden" id="IsCommentNotification" value="N">
					</div>
				</div>
			</div>
			<div class="boradDisplay">
				<div>
					<div class="tit"><spring:message code='Cache.lbl_RepeateDate' /></div><!-- 일시 -->
					<div class="txt" id="StartEndDateTime"></div>
				</div>
				<div>
					<div class="tit"><spring:message code='Cache.lbl_Place' /></div><!-- 장소 -->
					<div class="txt ">
						<p id="Place"></p>
						<div id="placeMap" class="map" >
							<img id="placeMapImg" alt="" src="">
						</div>
					</div>
				</div>
				<div>
					<div class="tit"><spring:message code='Cache.lbl_schedule_attendant' /></div><!-- 참석자 -->
					<div class="txt">
						<p id="Attendee" class="many"></p>
					</div>
				</div>
				<div id="viewDivRES">
					<div class="tit"><spring:message code='Cache.lbl_Resources' /></div><!-- 자원 -->
					<div class="txt">
						<p id="Resource"></p>
					</div>
				</div>
				<div>
					<div class="tit"><spring:message code='Cache.lbl_Text' /></div><!-- 본문 -->
					<div class="txt">
						<p id="Description"></p>
					</div>
				</div>
				<div>
					<div class="tit"><spring:message code='Cache.lbl_Project' /></div><!-- 프로젝트 -->
					<div class="txt">
						<p id="CollabPrj"></p>
					</div>
				</div>
			</div>
			<div id="commentView" class="commentView">

			</div>
		</div>
	</div>
	<div class="cRContEnd">
		<div id="divBtnBottom" class="cRTopButtons">
			<a onclick="$('.cRContBottom').animate({scrollTop:0}, 'fast');" class="btnTop"><spring:message code='Cache.lbl_goToTop' /></a><!-- 탑으로 이동 -->
		</div>
	</div>
	<!-- hidden field value  -->
	<input id="hidFolderType"  type="hidden" value=""/>
</div>

<script type="text/javascript">
	
	initView();

	function initView(){
		scheduleUser.initJS();

		var eventID = CFN_GetQueryString("eventID");
		var folderID = CFN_GetQueryString("folderID");
		var isAttendee = CFN_GetQueryString("isAttendee"); //참석 요청 알림을 통해 온 경우 Y
		// 새로고침과 같은 액션으로 권한 초기화된경우
		/* if(schAclArray.status != "SUCCESS") {
			scheduleUser.setAclEventFolderData();
		}*/
		//var readAuthCnt = $$(schAclArray).find("read").concat().find("[FolderID="+folderID+"]").length;

		var readAuthCnt = '${param.folderID}'.length;
		if(readAuthCnt <= 0 && isAttendee == "Y"){
			$.ajax({
				url: "/groupware/schedule/checkAttendeeAuth.do",
				type: "POST",
				data: {EventID : eventID},
				async: false,
				success: function (res) {
					if(res.status == "SUCCESS"){
						isAttendee = res.attendeeAuth;
					}else{
						isAttendee = "N"
					}
				},
				error:function(response, status, error){
					isAttendee = "N";
					CFN_ErrorAjax("/groupware/schedule/checkAttendeeAuth.do", response, status, error);
				}
			});
		}

		// TODO : 권한체크
		if(readAuthCnt <= 0 && isAttendee != "Y"){		// 읽기 권한 체크
			Common.Inform("<spring:message code='Cache.msg_noViewACL'/>", "", function(){	//읽기 권한이 없습니다.
				if(g_viewType == "Popup"){
					Common.Close();
				}else{
					CoviMenu_GetContent(g_lastURL);
				}
			});
			// TODO : 뒷 화면 숨기기
		}else{
			$("#divSheet").hide();

			scheduleUser.setViewData("D", CFN_GetQueryString("eventID"), CFN_GetQueryString("dateID"), CFN_GetQueryString("folderID"), CFN_GetQueryString("isRepeat"), "N", CFN_GetQueryString("isAlarm"));

// 			if(CFN_GetQueryString("isRepeatAll") == "Y") {
// 				$("#RepeatControlNotification").show();
// 				$("#RepeatControlNotification").prev().hide();
// 			} else{
// 				$("#RepeatControlNotification").hide();
// 				$("#RepeatControlNotification").prev().show();
// 			}
		}
	}


	function changeTotalReminder(obj) {
		$("#totalReminderTime").prop("disabled", !$(obj).prop("checked"));
	}

	function modifyAllNoti() {
		
		// 21.07.26, 알림 저장 조건 추가.
		if (flag4AlarmSave == "N") {
			Common.Inform(Common.getDic("msg_schedulePreAlert"), "Inform", function() {
				// 알림창 이후 미리 알림 체크표시 해제.
				if ( $("input:checked[id='totalReminder']").is(":checked") ) {
					$('#totalReminder').prop("checked", false);	
				} 
			});
			return;	
		}
		
		var eventID = CFN_GetQueryString("eventID");
		var notiInfo = {};

		notiInfo.reminder = $("#totalReminder").prop("checked") ? "Y" : "N";
		notiInfo.reminderTime = $("#totalReminderTime").val();
		notiInfo.comment = $("#totalCommentAlarm").prop("checked") ? "Y" : "N";

		// eventID 기준으로 현재 사용자의 모든 알림 수정 (데이터가 기본적으로 입력되있는 상태는 아니므로 Delete -> Insert)
		$.ajax({
			url: "/groupware/schedule/modifyAllNoti.do",
			type: "POST",
			data: {EventID : eventID, NotiInfo : JSON.stringify(notiInfo)},
			async: false,
			success: function (res) {
				if(res.status == "SUCCESS"){
					Common.Inform(Common.getDic("msg_SuccessModify"), "Inform", function() {
						location.reload();
					});
				}else{
					Common.Error(Common.getDic("msg_apv_030"));		// 오류가 발생했습니다.
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/groupware/schedule/deleteAllNoti.do", response, status, error);
			}
		});
	}

	function deleteAllNoti() {
		var eventID = CFN_GetQueryString("eventID");


		// eventID 기준으로 현재 사용자의 모든 알림 제거
		$.ajax({
			url: "/groupware/schedule/deleteAllNoti.do",
			type: "POST",
			data: {EventID : eventID},
			async: false,
			success: function (res) {
				if(res.status == "SUCCESS"){
					Common.Inform(Common.getDic("msg_SuccessModify"), "Inform", function() {
						location.reload();
					});
				}else{
					Common.Error(Common.getDic("msg_apv_030"));		// 오류가 발생했습니다.
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/groupware/schedule/deleteAllNoti.do", response, status, error);
			}
		});
	}
</script>