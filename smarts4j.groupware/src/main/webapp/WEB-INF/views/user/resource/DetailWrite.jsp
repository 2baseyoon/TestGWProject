<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<div class="cRConTop ">
	<div class="cRTopButtons">
		<a onclick="resourceUser.setOne('D');" id="btnAdd" class="btnTypeDefault btnTypeChk"><spring:message code='Cache.btn_register' /></a><!-- 등록 -->
		<a onclick="resourceUser.setOne('U');" id="btnUpdate"  class="btnTypeDefault btnTypeChk" style="display: none"><spring:message code='Cache.btn_Confirm' /></a><!-- 확인 -->
		<a onclick="CoviMenu_GetContent(g_lastURL);" class="btnTypeDefault"><spring:message code='Cache.btn_Cancel' /></a><!-- 취소 -->
	</div>
	<div class="surveySetting">
		<!-- <a class="surveryWinPop">팝업</a> -->
	</div>
</div>
<form id="formData" method="post" enctype="multipart/form-data">
	<div class='cRContBottom mScrollVH resourceContanier'>											
		<div class="resourceContent viewType02">
			<div class=" cRContBtmTitle">
				<div class="boardTitle">
					<h2 id="ResourceName"></h2>
					<input type="hidden" id="ResourceID" value="">
					<input type="hidden" id="hidFolderID" >
					<input type="hidden" id="hidFolderType" >
				</div>			
				<div class="publicChk">
					<a onclick="resourceUser.openResourceTree('D');" class="btnTypeDefault btnTypeChkLine"><spring:message code='Cache.lbl_resource_selectRes' /></a><!-- 자원선택 -->
					<a onclick="showResourceInfo(this);" class="btnTypeDefault btnResInfo"><spring:message code='Cache.lbl_FromInfo' /></a><!-- 정보 -->
				</div>
			</div>
			<div class="scheduleAddBox">
				<div id="divInfo" style="padding: 0;">
				</div>
				<div>
					<div class="inputBoxSytel01">
						<div><span><spring:message code='Cache.lbl_RepeateDate' /></span></div><!-- 일시 -->
						<div id="detailDateCon" class="dateSel type02">
						</div>
						<div class="chkStyle01">
							<input type="hidden" id="IsRepeat" value="N">
							<a id="btnRepeat" onclick="openSettingRepeat();" class="btnTypeDefault btnRepeat"><spring:message code='Cache.lbl_Repeate' /></a><input type="checkbox" id="IsAllDay" onchange="resourceUser.setAllDayCheck();"><label id="lbIsAllDay" for="IsAllDay"><span></span><spring:message code='Cache.lbl_AllDay' /></label><!-- 반복 --><!-- 종일 -->
						</div>
					</div>
				</div>
				<div>
					<div id="divNotification" class="inputBoxSytel01">
						<div>
							<div class="alarm type01" onclick="onOffBtnOnClick(this);" >
								<span><spring:message code='Cache.lbl_schedule_linkage' /></span><!-- 일정연동 -->
								<a id="IsSchedule" class="onOffBtn" style="right: 0;"><span></span></a>
							</div>
						</div>
						<div>		
							<div id="NotificationType" class="noticeMedia off">
								<div class="noticeMidaTbl">
									<div id="IsNotificationDiv" class="alarm type01" onclick="alarmOnClick(this);">
										<span><spring:message code='Cache.lbl_Alram' /></span><!-- 알림 -->
										<a id="IsNotification" class="onOffBtn"><span></span></a>
									</div>
								</div>
								<div class="noticeMidaTbl">
									<div>
										<div id="IsReminderA" class="alarm type01"onclick="alarmOnClick(this);">
											<span><spring:message code='Cache.lbl_BeforInform' /></span><!-- 미리알림 -->
											<a class="onOffBtn"><span></span></a>
										</div>
										<select id="ReminderTime" class="selectType02" disabled="disabled" style="min-width:100px !important; width:auto !important;">
											<option value="1"><spring:message code='Cache.lbl_AlramTime_1' /></option><!-- 1분전 -->
											<option selected="selected" value="10"><spring:message code='Cache.lbl_AlramTime_10' /></option><!-- 10분전 -->
											<option value="20"><spring:message code='Cache.lbl_AlramTime_20' /></option><!-- 20분전 -->
											<option value="30"><spring:message code='Cache.lbl_AlramTime_30' /></option><!-- 30분전 -->
											<option value="60"><spring:message code='Cache.lbl_AlramTime_60' /></option><!-- 1시간전 -->
											<option value="180"><spring:message code='Cache.lbl_AlramTime_180' /></option><!-- 3시간전 -->
											<option value="360"><spring:message code='Cache.lbl_AlramTime_360' /></option><!-- 6시간전 -->
											<option value="720"><spring:message code='Cache.lbl_AlramTime_720' /></option><!-- 12시간전 -->
											<option value="1440"><spring:message code='Cache.lbl_AlramTime_1440' /></option><!-- 1일전 -->
											<option value="2880"><spring:message code='Cache.lbl_AlramTime_2880' /></option><!-- 2일전 -->
											<option value="4320"><spring:message code='Cache.lbl_AlramTime_4320' /></option><!-- 3일전 -->
											
										</select>
<!-- 										<div id="IsCommentA" class="alarm type01"onclick="alarmOnClick(this);"> -->
<%-- 											<span><spring:message code='Cache.lbl_Comments' /></span><!-- 댓글 --> --%>
<!-- 											<a class="onOffBtn"><span></span></a> -->
<!-- 										</div> -->
										<a class="btnTypeDefault btnAlarmOption" style="display: none"><spring:message code='Cache.lbl_alarmSetting' /></a><!-- 알림설정 -->
									</div>
								</div>
							</div>
							<input type="hidden" id="IsNotification" value="N">
							<input type="hidden" id="IsReminder" value="N">
							<input type="hidden" id="IsCommentNotification" value="N">
						</div>
					</div>
					<div class="inputBoxSytel01 mt5">
						<div><span><spring:message code='Cache.lbl_Purpose' /></span></div><!-- 용도 -->
						<div class="txtEdit">
							<textarea id="Subject" class="HtmlCheckXSS ScriptCheckXSS"></textarea>
						</div>
					</div>
					<div id="attendeeAutoComp" class="inputBoxSytel01">
						<div><span><spring:message code='Cache.lbl_schedule_attendant' /></span>
							<div id="AttendeeYNdiv" class="alarm type01" onclick="AttendOnClick(this);" style="display: inline-block; padding-left: 24px;" >
								<a id="AttendeeYN" class="onOffBtn" style="right: 0;"><span></span></a>
							</div>
						</div><!-- 참석자 -->
							<div class="autoCompleteCustom">
								<input id="Attendee" type="text" class="HtmlCheckXSS ScriptCheckXSS" style="width:calc(100% - 266px)"/>
								<a onclick="addAttendeeAtOrgMapRes()" class="btnTypeDefault  "><spring:message code='Cache.btn_OrgMDM' /></a><!-- 조직도 -->
								<a onclick="goAttMemberSch()" class="btnTypeDefault  "><spring:message code='Cache.lbl_Schedule' /> <spring:message code='Cache.btn_Confirm' /></a><!-- 일정 확인 -->
								<div class="topInfoBox" id="topInfoBoxMessage">
									<dl>
										<dd>
											<ul class="bulDashedList">
												<li><spring:message code='Cache.msg_AddEnterOtherPeople' /></li><!-- 참석자 추가 시, 추가된 참석자에게만 알림 발송됩니다. -->
											</ul>
										</dd>
									</dl>
								</div>
						</div>
					</div>					
					<div id="fileDiv" class="inputBoxSytel01 type01" style="padding-top: 10px;">
						<div><span><spring:message code='Cache.lbl_apv_attachfile'/></span></div>	<!-- 파일 첨부 -->
						<div id="con_file" style="padding:0px;"></div>
					</div>
				</div>
				<div id="userFormOption" style="display: none"></div>
			</div>
		</div>
	</div>
</form>
<input type="hidden" id="hidRepeatInfo">
<!-- 종일 및 반복 버튼 클릭시 저장 -->
<input type="hidden" id="hidStartDate" >
<input type="hidden" id="hidStartHour" >
<input type="hidden" id="hidStartMinute" >
<input type="hidden" id="hidEndDate" >
<input type="hidden" id="hidEndHour" >
<input type="hidden" id="hidEndMinute" >

<script>
var selectFolderID = "";

initWrite();

$(".autoCompleteCustom").hide();
$("#topInfoBoxMessage").hide();

function initWrite(){
	resourceUser.initJS();
	
	$("#attendeeAutoComp").css("display", (Common.getBaseConfig("IsAttendee") === "Y") ? "table" : "none");
	
	coviFile.files.length = 0;
	coviFile.fileInfos.length = 0;			// coviFile.fileInfos 초기화
	
	var queryFolderID = CFN_GetQueryString("resourceID");
	
	if(queryFolderID != "undefined" && queryFolderID != ""){
		$("#ResourceID").val(queryFolderID);
		
		// 자원 정보 세팅
		resourceUser.setResourceInfo('W', queryFolderID, null);
	}else{
		$("#ResourceName").html('<span style="color:gray"><spring:message code="Cache.msg_mustSelectRes" /></span>');	//자원을 선택해주세요.
	}
	
	resourceUser.setAttendeeAutoInput();
	selectFolderID = $("#ResourceID").val();
	
	// Date 세팅
	setInputDateContrl();
	
	// 수정화면
	if(CFN_GetQueryString("eventID") != "undefined" && CFN_GetQueryString("eventID") != ""){
	
		var fileList = JSON.parse(JSON.stringify(g_fileList));
		coviFile.renderFileControl('con_file', {listStyle:'table', actionButton :'add', multiple : 'true'}, fileList);
		
		// 작성화면에서 데이터 세팅
		resourceUser.setViewData("DU", CFN_GetQueryString("eventID"), CFN_GetQueryString("dateID"), CFN_GetQueryString("resourceID"), CFN_GetQueryString("repeatID"));
		
		$("[id=btnUpdate]").show();
		$("[id=btnCopy]").show();
		$("[id=btnAdd]").hide();
		
		// 반복일정에서 개별수정일 경우
		if(CFN_GetQueryString("isRepeat") == "Y"  && CFN_GetQueryString("isRepeatAll") == "N"){
			$("[id=btnUpdate]").attr("onclick", "resourceUser.setOne('RU');");
			
			// 반복 설정하지 못하도록 반복 버튼 숨김
			$("#btnRepeat").remove();
		}
	}else{
		coviFile.renderFileControl('con_file', {listStyle:'table', actionButton :'add', multiple : 'true'});
		
		// 간단등록에서 넘어왔을 경우
		setSimpleWriteData();
	}
}

//간단등록에서 넘어왔을 경우
function setSimpleWriteData(){
	if($("#simpleSubject").val() != "" || (CFN_GetQueryString("subject") != "undefined" && CFN_GetQueryString("subject") != ""))
		$("#Subject").val(($("#simpleSubject").val() == "" ? decodeURIComponent(CFN_GetQueryString("subject")) : $("#simpleSubject").val()));
	
	if($("#simpleStartDate").val() != "" || (CFN_GetQueryString("startDate") != "undefined" && CFN_GetQueryString("startDate") != ""))
		$("#detailDateCon_StartDate").val(($("#simpleStartDate").val() == "" ? decodeURIComponent(CFN_GetQueryString("startDate")) : $("#simpleStartDate").val()));
	
	if($("#simpleEndDate").val() != "" || (CFN_GetQueryString("endDate") != "undefined" && CFN_GetQueryString("endDate") != ""))
		$("#detailDateCon_EndDate").val(($("#simpleEndDate").val()== "" ? decodeURIComponent(CFN_GetQueryString("endDate")) : $("#simpleEndDate").val()));
	
	if($("#simpleStartHour").val() != "" || (CFN_GetQueryString("startHour") != "undefined" && CFN_GetQueryString("startHour") != ""))
		coviCtrl.setSelected('detailDateCon [name=startHour]', ($("#simpleStartHour").val()== "" ? decodeURIComponent(CFN_GetQueryString("startHour")) : $("#simpleStartHour").val()));
	
	if($("#simpleStartMinute").val() != "" || (CFN_GetQueryString("startMinute") != "undefined" && CFN_GetQueryString("startMinute") != ""))
		coviCtrl.setSelected('detailDateCon [name=startMinute]', ($("#simpleStartMinute").val()== "" ? decodeURIComponent(CFN_GetQueryString("startMinute")) : $("#simpleStartMinute").val()));
	
	if($("#simpleEndHour").val() != "" || (CFN_GetQueryString("endHour") != "undefined" && CFN_GetQueryString("endHour") != ""))
		coviCtrl.setSelected('detailDateCon [name=endHour]', ($("#simpleEndHour").val()== "" ? decodeURIComponent(CFN_GetQueryString("endHour")) : $("#simpleEndHour").val()));
	
	if($("#simpleEndMinute").val() != "" || (CFN_GetQueryString("endMinute") != "undefined" && CFN_GetQueryString("endMinute") != ""))
		coviCtrl.setSelected('detailDateCon [name=endMinute]', ($("#simpleEndMinute").val()== "" ? decodeURIComponent(CFN_GetQueryString("endMinute")) : $("#simpleEndMinute").val()));
	
	if($("#simpleIsChkSchedule").val() != "" && $("#simpleIsChkSchedule").val() == "true"){
		$("#IsSchedule").parent().click();
	}
	
	// 초기화
	$("#simpleResourceID").val("");
	$("#simpleResourceName").val("");
	$("#simpleSubject").val("");
	$("#simpleStartDate").val("");
	$("#simpleEndDate").val("");
	$("#simpleStartHour").val("");
	$("#simpleStartMinute").val("");
	$("#simpleEndHour").val("");
	$("#simpleEndMinute").val("");
	
	// 간단 등록에서 상세 등록으로 이동 시 선택 항목 바인딩
	if(CFN_GetQueryString("simpleDatePicker") != 'undefined'){
		$("[name=datePicker] select").val(CFN_GetQueryString("simpleDatePicker"));
	}
}

// 정보 클릭시
function showResourceInfo(obj){
	if(selectFolderID == ""){
		Common.Warning("<spring:message code='Cache.msg_mustSelectRes'/>");		//자원을 선택해주세요
	}else{
		var mParent = $('.inPerInfoView');
		if($(obj).hasClass('active')){
			mParent.removeClass('active');
			$(obj).removeClass('active');
		}else {
			mParent.addClass('active');
			$(obj).addClass('active');
		}
		coviInput.setDate();
	}
}

// Date 세팅
function setInputDateContrl(){
	target = 'detailDateCon';
	var timeInfos = {
			width : "100",
			H : "1,2,3,4",
			W : "1,2", //주 선택
			M : "1,2", //달 선택
			Y : "1" //년도 선택
		};
	
	var initInfos = {
			useCalendarPicker : 'Y',
			useTimePicker : 'Y',
			useBar : 'Y',
			useSeparation : 'Y',
			minuteInterval : 5,  //TODO 만약, 60의 약수가 아닌 경우, 그려지지 않음.
			width : '80',
			height : '200',
			use59 : 'Y'
		};
	
	var nowHour = new Date(CFN_GetLocalCurrentDate(_StandardServerDateFormat));
	var nowMinite = AddFrontZero(Math.ceil((new Date(CFN_GetLocalCurrentDate(_StandardServerDateFormat)).getMinutes())/5)*5, 2);
	
	if(nowMinite >= 60) {
		nowHour.setHours(new Date(CFN_GetLocalCurrentDate(_StandardServerDateFormat)).getHours() + 1);	
		nowMinite = AddFrontZero(0, 2);
	}
	
	coviCtrl.renderDateSelect(target, timeInfos, initInfos);
	
	coviCtrl.setSelected('detailDateCon [name=startHour]', AddFrontZero(nowHour.getHours(), 2));
	coviCtrl.setSelected('detailDateCon [name=startMinute]', nowMinite);
	
	nowHour.setTime(nowHour.getTime() + (60*60*1000));
	
	$("#detailDateCon_EndDate").val(schedule_SetDateFormat(nowHour, "."));
	coviCtrl.setSelected('detailDateCon [name=endHour]', AddFrontZero(nowHour.getHours(), 2));
	coviCtrl.setSelected('detailDateCon [name=endMinute]', nowMinite);
}

function goAttMemberSch(){
	var len = $("#attendeeAutoComp .autoCompleteCustom .ui-autocomplete-multiselect div").length;
	
	if(len != 0){
		var attInfos = new Array();
		
		for(var i = 0; i < len; i++){
			var obj = $("#attendeeAutoComp .autoCompleteCustom .ui-autocomplete-multiselect div").get(i);
			var json = JSON.parse($(obj).attr("data-json"));
			if(json.MailAddress != json.UserName){
				attInfos.push(json.UserCode+" "+json.UserName);
			}
		}
		
		if(attInfos == null || attInfos == ""){
			Common.Warning("<spring:message code='Cache.msg_cannoutCheckOtherPeople' />"); // 외부 참석자의 일정은 확인할 수 없습니다.
		}else{
			Common.open("", "AttMemSch", "<spring:message code='Cache.lbl_ScheduleManager' />", "/groupware/schedule/goAttendanceSchedulePopup.do?CLSYS=schedule&CLBIZ=Schedule&attendanceInfos="+attInfos.join(","), "1200px", "565px", "iframe", true, null, null, true); // 연관 문서
		}
	}else{
		Common.Warning("<spring:message code='Cache.msg_enterAttendance' />"); // 참석자를 입력해주세요.
		return false;
	}
}

//조직도에서 참석자 추가하기(2022.03.14.월요일)
function addAttendeeAtOrgMapRes(){
	
	_CallBackMethod2 = setAttendeeAtOrgMapRes;
	Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>","/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod2&type=B9","1060px","580px","iframe",true,null,null,true);
}

function setAttendeeAtOrgMapRes(data){
	
	var boolRegisterCheck = false;
	var dataObj = $.parseJSON(data);
		dataObj = $$(dataObj).find("item").concat().json();

	$(dataObj).each(function(i){
		
		var userCode = $$(this).attr("AN");
		var userName = CFN_GetDicInfo($$(this).attr("DN"));

		if(userCode == Common.getSession("UR_Code")) {
			boolRegisterCheck = true;
			return;
		}
		
		if ($("#attendeeAutoComp").find(".ui-autocomplete-multiselect-item[data-value='"+ userCode+"'], .ui-autocomplete-multiselect-item[data-value^='"+ userCode+"|']").length > 0) {
			
			Common.Warning("<spring:message code='Cache.ACC_msg_existItem'/>");
			return;
		}
		
		var dataJson  = {};
		var dataValue = "";
		
		var attendeeObj = $("<div></div>").addClass("ui-autocomplete-multiselect-item")
        								  .attr("data-json", JSON.stringify({"UserCode":userCode,"UserName":userName, "MailAddress":$(this).attr("EM"),"label":userName,"value":userCode}))
       				 					  .attr("data-value", userCode)
       			 						  .text(userName)
        								  .append( $("<span></span>").addClass("ui-icon ui-icon-close")
        										  .click(function(){
                   				 										var item = $(this).parent();
                    														item.remove();
                					 							   }
        										  		)
        										 );
		$(attendeeObj).insertBefore("#Attendee");
	});

	if(boolRegisterCheck) {

		Common.Inform("<spring:message code='Cache.msg_no_self_attendant'/>"); //내 일정의 참석자로 본인을 등록할 수 없습니다.
	}
}
</script>