<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class="cRConTop">
	<div class="cRTopButtons ">							
		<div id="divBtnTop" class="pagingType02 buttonStyleBoxLeft">
			<a onclick="CoviMenu_GetContent(g_lastURL);" id="btnList"  class="btnTypeDefault btnTypeLArrr"><spring:message code='Cache.lbl_Index' /></a><!-- 목록 -->
		</div>
		<div class="surveySetting">
			<!-- TODO 프린트 및 설정 버튼 개발 (미구현 항목으로 숨김처리)  -->
			<a class="btnPrintIcon" style="display:none"><spring:message code='Cache.lbl_Index' /><spring:message code='Cache.lbl_printEng' /></a><!-- 프린트 -->
			<a class="surveryContSetting active" style="display:none"><spring:message code='Cache.lbl_Index' /><spring:message code='Cache.lbl_Setting' /></a><!-- 설정 -->
			<!-- <a class="surveryWinPop">팝업</a> -->
		</div>
	</div>
</div>
<div class='cRContBottom mScrollVH resourceContanier'>
	<div class="resourceContent viewType02">
		<div class=" cRContBtmTitle">
			<div class="boardTitle">
				<h2 id="Subject" name="Subject"></h2>
			</div>
		</div>
		<div class="boradBottomCont">
			<div class="boardViewCont">
				<div class="bvcTitle">
					<div class="personBox">
						<div class="perPhoto">
							<img id="RegisterPhoto" src="" alt="<spring:message code='Cache.lbl_ProfilePhoto' />" onerror="coviCmn.imgError(this, true)"><!-- 프로필사진 -->
						</div>
						<p class="name" id="Register"></p>
						<div class="attFileListBox"></div>					<!-- 첨부파일 -->	
					</div>
				</div>
				<div id="divNotification" class="boradAlarmBox" style="display: none;">
					<div class="inputBoxSytel01">
						<div>
							<div id="IsNotificationDiv" class="alarm type01" onclick="alarmOnClick(this);saveAlarm('All');">
								<span><spring:message code='Cache.lbl_Alram' /></span><!-- 알림 -->
								<a id="IsNotification" class="onOffBtn"><span></span></a>
							</div>
						</div>
						<div id="NotificationType" class="noticeMedia off">		
							<div id="IsReminderA" class="alarm type01 ml25" onclick="alarmOnClick(this);saveAlarm('Reminder');">
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
							<div id="IsCommentA" class="alarm type01"onclick="alarmOnClick(this);saveAlarm('Comment');">
								<span><spring:message code='Cache.lbl_Comments' /></span><!-- 댓글 -->
								<a class="onOffBtn"><span></span></a>
							</div>
							<a class="btnTypeDefault btnAlarmOption" style="display: none"><spring:message code='Cache.lbl_alarmSetting' /></a><!-- 알림설정 -->
							<input type="hidden" id="IsNotification" value="N">
							<input type="hidden" id="IsReminder" value="N">
							<input type="hidden" id="IsCommentNotification" value="N">
						</div>
					</div>
					
					<div id="RepeatControlNotification" class="inputBoxSytel01" style="display:none;">
					<div>
						<div class="alarm type01">
							<spring:message code='Cache.lbl_totalAlarm' />
						</div>
					</div>
					<div>
						<div style="width:250px; height:70px; padding:5px 10px; border:1px solid #d9d9d9; display:inline-block; float: left; margin-right: 10px;">
							<div>
								<input type="checkbox" id="totalReminder" onchange="changeTotalReminder(this)"/> <span style="font-weight:bold;">미리알림</span> 
								<select id="totalReminderTime" class="selectType02" disabled="disabled" style="vertical-align: baseline;">
									<option value="1">1분전</option><!-- 1분전 -->
									<option selected="selected" value="10">10분전</option><!-- 10분전 -->
									<option value="20">20분전</option><!-- 20분전 -->
									<option value="30">30분전</option><!-- 30분전 -->
									<option value="60">1시간전</option><!-- 1시간전 -->
									<option value="180">3시간전</option><!-- 3시간전 -->
									<option value="360">6시간전</option><!-- 6시간전 -->
									<option value="720">12시간전</option><!-- 12시간전 -->
									<option value="4320">3일전</option><!-- 3일전 -->
									<option value="2880">2일전</option><!-- 2일전 -->
									<option value="1440">1일전</option><!-- 1일전 -->
								</select>
							</div>
							<div>
								<input type="checkbox" id="totalCommentAlarm"/> <span style="font-weight:bold;">댓글알림</span>
							</div>
						</div>
						<div style="display:inline-block;">
							<a onclick="modifyAllNoti()" id="btnAllNotiModify" class="btnTypeDefault right" style="display: block; margin-bottom: 10px;"><spring:message code='Cache.btn_totalAlarmModify' /></a>
							<a onclick="deleteAllNoti()" id="btnAllNotiDelete" class="btnTypeDefault right"><spring:message code='Cache.btn_totalAlarmTurnOff' /></a>
						</div>
					</div>
				</div>
				</div>
				<div class="boradDisplay" id="divBookingData">
					<div class="inputBoxSytel01 type02">
						<div><span><spring:message code='Cache.lbl_Res_Name' /><!-- 자원명 --></span><a onclick="btnSurMoveOnClick(this);" class="btnMoreStyle02 btnSurMove"><spring:message code='Cache.lbl_resource_moreRes' /></a></div><!-- 자원명 더보기 -->
						<div>
							<p id="ResourceName"></p>
							<div id="divInfo"></div>
						</div>
					</div>
					<div>
						<div class="tit"><span><spring:message code='Cache.lbl_RepeateDate' /></span></div><!-- 일시 -->
						<div class="txt">
							<p id="StartEndDateTime"></p>
						</div>
					</div>
					
					<!--참석자 -->
					<div id="Attendeediv">
						<div class="tit"><spring:message code='Cache.lbl_schedule_attendant' /></div><!-- 참석자 -->
						<div class="txt">
							<p id="Attendee" class="many"></p>
						</div>
					</div>
					
					<div>
						<div class="tit"><span><spring:message code='Cache.lbl_LinkSchedule' /></span></div><!-- 연결일정 -->
						<div class="txt">
							<p><a id="linkSchedule"></a></p>
						</div>
					</div>
				</div>
				<div id="commentView" class="commentView">
				</div>
			</div>
		</div>
	</div>
	<div class="cRContEnd">
		<div id="divBtnBottom" class="cRTopButtons">
			<a class="btnTop"><spring:message code='Cache.lbl_goToTop' /></a><!-- 탑으로 이동 -->
		</div>
	</div>
	<!-- hidden field value  -->
	<input id="hidFolderType"  type="hidden" value=""/>
</div>

<script type="text/javascript">
		
	initView();
	
	function initView(){
		resourceUser.initJS();
		
		$("#Attendeediv").css("display", (Common.getBaseConfig("IsAttendee") === "Y") ? "table" : "none");
		
		var resourceID = CFN_GetQueryString("resourceID");
		
		// TODO : 권한체크
		if($$(resAclArray).find("read").concat().find("[FolderID="+resourceID+"]").length <= 0){		// 삭제 권한 체크
			Common.Inform("<spring:message code='Cache.msg_noViewACL' />", "", function(){		//읽기 권한이 없습니다.
				if(CFN_GetQueryString("isPopupView") == 'Y'){
					Common.Close();					
				}else{
					CoviMenu_GetContent(g_lastURL);
				}
				
			});
			// TODO : 뒷 화면 숨기기 
		}else{
			if($$(resAclArray).find("modify").concat().find("[FolderID="+resourceID+"]").length <= 0){		// 수정 권한 체크
				$("#btnModify").hide();
				$("#btnDelete").removeClass("left");
			}
			
			resourceUser.setViewData("D", CFN_GetQueryString("eventID"), CFN_GetQueryString("dateID"), CFN_GetQueryString("resourceID"), CFN_GetQueryString("repeatID"));
			
			if(CFN_GetQueryString("isRepeatAll") == "Y") {
				$("#RepeatControlNotification").show();
			} else{
				$("#RepeatControlNotification").hide();
			}
		}
	}
	
	function changeTotalReminder(obj) {
		$("#totalReminderTime").prop("disabled", !$(obj).prop("checked"));
	}
	
	function modifyAllNoti() {
		var eventID = CFN_GetQueryString("eventID");
		var notiInfo = {};
		
		notiInfo.reminder = $("#totalReminder").prop("checked") ? "Y" : "N";
		notiInfo.reminderTime = $("#totalReminderTime").val();
		notiInfo.comment = $("#totalCommentAlarm").prop("checked") ? "Y" : "N";
		
		// eventID 기준으로 현재 사용자의 모든 알림 수정 (데이터가 기본적으로 입력되있는 상태는 아니므로 Delete -> Insert)
		$.ajax({
		    url: "/groupware/resource/modifyAllNoti.do",
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
				CFN_ErrorAjax("/groupware/resource/deleteAllNoti.do", response, status, error);
			}
		});
	}
	
	function deleteAllNoti() {
		var eventID = CFN_GetQueryString("eventID");
		
		
		// eventID 기준으로 현재 사용자의 모든 알림 제거
		$.ajax({
		    url: "/groupware/resource/deleteAllNoti.do",
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
				CFN_ErrorAjax("/groupware/resource/deleteAllNoti.do", response, status, error);
			}
		});
	}
</script>