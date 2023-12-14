<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8" import="egovframework.coviframework.util.RedisDataUtil"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div>
	<div class="cRConTop ">
		<div class="cRTopButtons">
			<a onclick="scheduleUser.setOne('D');" id="btnAdd" class="btnTypeDefault btnTypeChk"><spring:message code='Cache.btn_register' /></a><!-- 등록 -->
			<a onclick="scheduleUser.setOne('U');" id="btnUpdate"  class="btnTypeDefault btnTypeChk" style="display: none"><spring:message code='Cache.btn_Confirm' /></a><!-- 확인 -->
			<a onclick="scheduleUser.setOne('D');" id="btnCopy"  class="btnTypeDefault btnTypeChk" style="display: none"><spring:message code='Cache.btn_Copy' /></a><!-- 복사 -->
			<a onclick="CoviMenu_GetContent(g_lastURL);" class="btnTypeDefault"><spring:message code='Cache.btn_Cancel' /></a><!-- 취소 -->
		</div>
		<div class="surveySetting">
			<!-- <a class="surveryWinPop">팝업</a> -->
		</div>
	</div>
	<form id="formData" method="post" enctype="multipart/form-data">
		<div class='cRContBottom mScrollVH '>
			<div class="scheduleContentType02">
				<div class=" cRContBtmTitle">
					<div>
						<input type="hidden" id="ImportanceState" />
						<a class="btnType02" id="aImportanceState" onclick="importantOnClick(this);"><spring:message code='Cache.lbl_Important' /></a><!-- 중요 --><input id="Subject" type="text" class="inpStyle01 HtmlCheckXSS ScriptCheckXSS" placeholder="<spring:message code='Cache.msg_028' />" maxlength="100"><!-- 제목을 입력하세요. -->
					</div>
					<div class="publicChk">
						<div class="chkStyle01">
							<input type="checkbox" id="IsPublic"><label for="IsPublic"><span></span><spring:message code='Cache.lbl_Private' /></label><!-- 비공개 -->
						</div>
					</div>
				</div>						
				<div class="scheduleAddBox">		
					<div>
						<div class="inputBoxSytel01">
							<div><span ><spring:message code='Cache.lbl_Gubun' /></span></div><!-- 구분 -->
							<div>
								<div class="cusSelect">
									<!-- 셀렉트 선택시 아래 input에 value값으로 ul 태그 li에 data-selvalue 값 입력 -->
									<input id="FolderType" type="txt" readonly="" class="selectValue">
									<span id="defaultFolderType" onclick="sleOpTitleOnClick(this);" class="sleOpTitle"></span>
									<ul id="ulFolderTypes" class="selectOpList">
									</ul>
								</div>
							</div>
						</div>
						<div class="inputBoxSytel01">
							<div><span ><spring:message code='Cache.lbl_Place' /></span></div><!-- 장소 -->
							<div id="placeAutoComp" class="autoCompleteCustom place" onclick="scheduleUser.deletePlaceInput();" onkeydown="javascript:if(event.keyCode==13) {scheduleUser.deletePlaceInput();}" >
								<input id="Place" onfocus="scheduleUser.deletePlaceInput();" onkeydown="javascript:if(event.keyCode==13) {scheduleUser.deletePlaceInput();}" type="text" class="inpStyle02 HtmlCheckXSS ScriptCheckXSS" placeholder="<spring:message code='Cache.msg_mustWriteAddress'/>"><!-- 주소를 입력하세요. -->
							</div>
						</div>
						<div id="divDateInput" class="inputBoxSytel01">
							<div><span><spring:message code='Cache.lbl_RepeateDate' /></span></div><!-- 일시 -->
							<div id="detailDateCon" class="dateSel type02">
							</div>
							<div class="chkStyle01">
								<input type="hidden" id="IsRepeat" value="N">
								<a id="btnRepeat" onclick="openSettingRepeat();" class="btnTypeDefault btnRepeat"><spring:message code='Cache.lbl_Repeate' /></a><input type="checkbox" id="IsAllDay" onchange="scheduleUser.setAllDayCheck('D');"><label id="lbIsAllDay" for="IsAllDay"><span></span><spring:message code='Cache.lbl_AllDay' /></label><!-- 반복 --><!-- 종일 -->
							</div>
						</div>
					</div>
					<div>
						<div id="wrtDivRES" class="inputBoxSytel01">
							<div><span><spring:message code='Cache.lbl_Resources' /></span></div><!-- 자원 -->
							<div id="resourceAutoComp" class="autoCompleteCustom">
								<input id="Resource" type="text" class="HtmlCheckXSS ScriptCheckXSS" style="width:calc(100% - 266px)"/>
								<a class="btnTypeDefault  " onclick="scheduleUser.openResourceView();"><spring:message code='Cache.lbl_resource_check' /></a><!-- 자원확인 -->
								<div id="infoPastSave" style="display: none;">
									<dl>
										<dd>
											<ul class="bulDashedList" style="list-style-type: none;">
												<li><spring:message code='Cache.msg_resource_pastSave' /></li><!-- 과거일자에 등록하는 경우 자원은 저장되지 않습니다. -->
											</ul>
										</dd>
									</dl>
								</div>
							</div>
						</div>
						<div id="attendeeAutoComp" class="inputBoxSytel01">
							<div><span><spring:message code='Cache.lbl_schedule_attendant' /></span></div><!-- 참석자 -->
							<div class="autoCompleteCustom">
								<input id="Attendee" type="text" class="HtmlCheckXSS ScriptCheckXSS" style="width:calc(100% - 266px)"/>
								<a onclick="addAttendeeAtOrgMap()" class="btnTypeDefault"><spring:message code='Cache.btn_OrgMDM' /></a><!-- 조직도 -->
								<a onclick="goAttMemberSch()" class="btnTypeDefault"><spring:message code='Cache.lbl_ScheduleManager' /></a><!-- 일정 확인 -->
								<div class="chkStyle01" style="display: none;">
									<input type="checkbox" id="IsInviteOther"><label for="IsInviteOther"><span></span><spring:message code='Cache.lbl_schedule_inviteAuth' /></label><!-- 초대 권한 -->
								</div>
								<div>
									<dl>
										<dd>
											<ul class="bulDashedList" style="list-style-type: none;">
												<li><spring:message code='Cache.msg_YouCanEnterOtherPeople' /></li><!-- 외부 참석자일 경우, 이메일을 작성한 후 Enter를 입력하시면 등록이 가능합니다. -->
											</ul>
										</dd>
									</dl>
								</div>
							</div>
						</div>
					</div>
					<div>
						<div class="inputBoxSytel01" id="divNotification">
							<div id="IsNotificationDiv" class="alarm type01" onclick="alarmOnClick(this);">
								<span><spring:message code='Cache.lbl_Alram' /></span><!-- 알림 -->
								<a id="IsNotificationA" class="onOffBtn"><span></span></a>
							</div>
							<div id="NotificationType"  class="noticeMedia off">
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
									<div id="IsCommentA" class="alarm type01"onclick="alarmOnClick(this);" style="display:none;">
										<span><spring:message code='Cache.lbl_Comments' /></span><!-- 댓글 -->
										<a class="onOffBtn"><span></span></a>
									</div>
<%-- 									<a class="btnTypeDefault btnAlarmOption" style="display: none"><spring:message code='Cache.lbl_alarmSetting' /></a><!-- 알림설정 --> --%>
								</div>
							</div>
							<input type="hidden" id="IsNotification" value="N">
							<input type="hidden" id="IsReminder" value="N">
							<input type="hidden" id="IsCommentNotification" value="N">
						</div>
						<div class="inputBoxSytel01 mt5" >
							<div><span><spring:message code='Cache.lbl_Text' /></span></div><!-- 본문 -->
							<div class="txtEdit">
								<textarea id="Description" class="HtmlCheckXSS ScriptCheckXSS"></textarea>
								<div id="dext5">
								</div>
								<input type="hidden" id="hidDescription" value="">
								<p id="pSwitchEditor" onclick="switchTextAreaEditor(this);" class="editChange" value="textarea"><a><spring:message code='Cache.lbl_editChange' /></a></p><!-- 편집기로 작성 -->
							</div>
						</div>
						
						<div id="fileDiv" class="inputBoxSytel01 type01" style="padding-top: 10px;">
							<div><span><spring:message code='Cache.lbl_apv_attachfile'/></span></div>	<!-- 파일 첨부 -->
							<div id="con_file" style="padding:0px;"></div>
						</div>
						<%if (RedisDataUtil.getBaseConfig("isUseCollabSchedule").equals("Y")){ %>
						<div id="taskDiv" class="inputBoxSytel01 type01" style="padding-top: 10px;">
							<div><span><spring:message code='Cache.lbl_Project'/></span></div>	<!-- 업무연결 -->
							<div class="div_td">
<!-- 								<select class="selectType02 wd" id="prjMap" style="width: auto; padding-right: 35px;"> -->
<!-- 								</select> -->
								<div id="prjMap" style="float:left; line-height: 30px; margin-right: 10px;"></div>
								<div class="control_btn" style="padding: 0px 0px 0px 0px;display: inline-block;position: relative;">
<!-- 									<a href="#" class="btn_close" id="btnDelProject">&minus;</a> -->
<!-- 									<a href="#" class="btn_add" id="btnAddPrjoject">&plus;</a> -->
									<a href="#" class="btnTypeDefault" id="btnAddPrjoject"><i class="fa fa-plus" aria-hidden="true"></i></a>
								</div>
							</div>
						</div>
						<%} %>
					</div>
				</div>
			</div>
		</div>
	</form>
</div>
<input type="hidden" id="hidRepeatInfo">
<input type="hidden" id="hidResourceList" >
<!-- 종일 버튼 클릭시 저장 -->
<input type="hidden" id="hidStartDate" >
<input type="hidden" id="hidStartTime" >
<input type="hidden" id="hidStartHour" >
<input type="hidden" id="hidStartMinute" >
<input type="hidden" id="hidEndDate" >
<input type="hidden" id="hidEndTime" >
<input type="hidden" id="hidEndHour" >
<input type="hidden" id="hidEndMinute" >

<input type="hidden" id="hidResourceList_DU">

<script>
	//# sourceURL=DetailWrite.jsp

	var isModify = false; 
	var isCopy = (CFN_GetQueryString("isCopy") == 'undefined') ? 'N' : CFN_GetQueryString("isCopy");
	
	// 커뮤니티 일정 등록 여부 확인 (2022-05-25)
	var isCommunity = '<c:out value="${CSMU}"/>' == "C" ? true : false;

	var g_editorKind = Common.getBaseConfig('EditorType');
	
	initWrite();
	
	function initWrite(){		
		scheduleUser.initJS();
		
		// 협업 스페이스 - 일정 연동
		if (Common.getBaseConfig("isUseCollabSchedule") === "Y") {
			//프로젝트 추가
			$("#btnAddPrjoject").on('click', function(){
				//if ($('#prjMap option').length > 0){
// 				if ($('#prjMap').attr("data-key") != undefined){
// 					Common.Warning("이미 프로젝트가 매핑되었습니다.");
// 					return;
// 				}
				if ($('#prjMap').attr("data-key")){
					$('#prjMap').removeAttr("data-key").text('');
					$("#btnAddPrjoject i").removeClass("fa-minus").addClass("fa-plus");
				}
				else {
					collabUtil.openProjectAllocPopup(0, "N", "saveProjectAllocPopup");
				}
				
				
			});
			
// 			$("#btnDelProject").on('click', function(){
// 				//$('#prjMap option').remove();
// 				$('#prjMap').removeAttr("data-key").text('');
// 			});
		}
		
		$("#infoPastSave").css("display", (Common.getBaseConfig("IsPastSave") === "Y") ? "none" : "block");

		// 컨트롤 및 값 세팅
		scheduleUser.setFolderType('D');
		scheduleUser.setStartEndDateTime('D');
		
    	scheduleUser.setResourceAutoInput();
    	scheduleUser.setAttendeeAutoInput();
    	scheduleUser.setPlaceAutoInput();
    	
    	coviFile.files.length = 0;
    	coviFile.fileInfos.length = 0;			// coviFile.fileInfos 초기화

    	// 자주 쓰는 일정 등록
		if(CFN_GetQueryString("isTemplate") == "Y"){
			
			//coviFile.renderFileControl('con_file', {listStyle:'table', actionButton :'add', multiple : 'true'});
			$("#fileDiv").hide();
			
			// 반복, 일시 disabled
			if(CFN_GetQueryString("eventID") == "undefined" || CFN_GetQueryString("eventID") == ""){
				$("#divDateInput").hide();
				
				$("[id=btnAdd]").attr("onclick", "scheduleUser.setOne('F')");
				$("[id=btnAdd]").html("<spring:message code='Cache.lbl_schedule_addFavoriteSch'/>");		//자주 쓰는 일정 등록
			}else{
				isModify = true;
				
				scheduleUser.setViewData("DU", CFN_GetQueryString("eventID"), (CFN_GetQueryString("dateID")=="undefined" ? "" : CFN_GetQueryString("dateID")), (CFN_GetQueryString("folderID")=="undefined" ? "" : CFN_GetQueryString("folderID")), (CFN_GetQueryString("isRepeat")=="undefined" ? "" : CFN_GetQueryString("isRepeat")));
				
				$("#divDateInput").after('<div style="color: #666;font-size: 13px;"><label style="color: red">*</label> 자주 쓰는 일정 템플릿 수정 시에는 일시 저장이 불가능합니다.</div>');				
				
				$("[id=btnUpdate]").show();
				$("[id=btnUpdate]").html("<spring:message code='Cache.lbl_schedule_modifyFavoriteSch'/>");		//자주 쓰는 일정 수정
				$("[id=btnUpdate]").attr("onclick", "scheduleUser.setOne('FU')");
			}
			
 			$("[id=btnAdd]").show();
 			$("[id=btnCopy]").hide();
		}
		// 수정화면
		else if(CFN_GetQueryString("eventID") != "undefined" && CFN_GetQueryString("eventID") != ""){
			isModify = true;
			
			var fileList = JSON.parse(JSON.stringify(g_fileList));
			coviFile.renderFileControl('con_file', {listStyle:'table', actionButton :'add', multiple : 'true'}, fileList);
			
			// 작성화면에서 데이터 세팅
			scheduleUser.setViewData("DU", CFN_GetQueryString("eventID"), CFN_GetQueryString("dateID"), CFN_GetQueryString("folderID"), CFN_GetQueryString("isRepeat"));
			
			if (isCopy == 'Y'){
				$("[id=btnCopy]").show();
			} else {
				$("[id=btnUpdate]").show();
			}
		
 			$("[id=btnAdd]").hide();
			
			// 반복일정에서 개별수정일 경우
			if(CFN_GetQueryString("isRepeat") == "Y"  && CFN_GetQueryString("isRepeatAll") == "N"){
				$("[id=btnUpdate]").attr("onclick", "scheduleUser.setOne('RU');");
				
				// 반복 설정하지 못하도록 반복 버튼 숨김
				$("#btnRepeat").remove();
			}
			
			// 협업 스페이스
			if (Common.getBaseConfig("isUseCollabSchedule") === "Y") {
				setPrjInfo(CFN_GetQueryString("eventID"), CFN_GetQueryString("dateID"));
			}
		}else{
			coviFile.renderFileControl('con_file', {listStyle:'table', actionButton :'add', multiple : 'true'});
			
			// 간단등록에서 넘어왔을 경우
			setSimpleWriteData();
		}
    	
    	if(!isModify){ //수정 모드가 아닐 경우 (DU가 아닐 경우)
			// 에디터 세팅
			setDescEditor();
    	}
    	
    	// 커뮤니티 일정 등록일 경우 프로젝트 입력창을 숨긴다 (2022-05-25)
    	if(isCommunity) {
    		$("#taskDiv").hide();
    	}
	}

	// 간단등록에서 넘어왔을 경우
	// 간편 작성의 일정에서 넘어왔을 경우도 포함
	function setSimpleWriteData(){
		if($("#simpleSubject").val() != "" || (CFN_GetQueryString("subject") != "undefined" && CFN_GetQueryString("subject") != "")){
			$("#Subject").val(($("#simpleSubject").val() == "" ? decodeURIComponent(CFN_GetQueryString("subject")) : $("#simpleSubject").val()));
		}
		if($("#simpleFolderType").val() != "" || (CFN_GetQueryString("folderID") != "undefined" && CFN_GetQueryString("folderID") != "")){
			$("[data-selvalue="+($("#simpleFolderType").val() == "" ? decodeURIComponent(CFN_GetQueryString("folderID")) : $("#simpleFolderType").val())+"]").click();
		}
		if($("#simpleStartDate").val() != "" || (CFN_GetQueryString("startDate") != "undefined" && CFN_GetQueryString("startDate") != "")){
			$("#detailDateCon_StartDate").val(($("#simpleStartDate").val() == "" ? decodeURIComponent(CFN_GetQueryString("startDate")) : $("#simpleStartDate").val()));
		}
		if($("#simpleEndDate").val() != "" || (CFN_GetQueryString("endDate") != "undefined" && CFN_GetQueryString("endDate") != "")){
			$("#detailDateCon_EndDate").val(($("#simpleEndDate").val() == "" ? decodeURIComponent(CFN_GetQueryString("endDate")) : $("#simpleEndDate").val()));
		}
		if($("#simpleStartHour").val() != "" || (CFN_GetQueryString("startHour") != "undefined" && CFN_GetQueryString("startHour") != "")){
			coviCtrl.setSelected('detailDateCon [name=startHour]', ($("#simpleStartHour").val()== "" ? decodeURIComponent(CFN_GetQueryString("startHour")) : $("#simpleStartHour").val()));
		}
		if($("#simpleStartMinute").val() != "" || (CFN_GetQueryString("startMinute") != "undefined" && CFN_GetQueryString("startMinute") != "")){
			coviCtrl.setSelected('detailDateCon [name=startMinute]', ($("#simpleStartMinute").val()== "" ? decodeURIComponent(CFN_GetQueryString("startMinute")) : $("#simpleStartMinute").val()));
		}
		if($("#simpleEndHour").val() != "" || (CFN_GetQueryString("endHour") != "undefined" && CFN_GetQueryString("endHour") != "")){
			coviCtrl.setSelected('detailDateCon [name=endHour]', ($("#simpleEndHour").val()== "" ? decodeURIComponent(CFN_GetQueryString("endHour")) : $("#simpleEndHour").val()));
		}
		if($("#simpleEndMinute").val() != "" || (CFN_GetQueryString("endMinute") != "undefined" && CFN_GetQueryString("endMinute") != "")){
			coviCtrl.setSelected('detailDateCon [name=endMinute]', ($("#simpleEndMinute").val()== "" ? decodeURIComponent(CFN_GetQueryString("endMinute")) : $("#simpleEndMinute").val()));
		}
		if($("#simpleSubject").val() != "" || (CFN_GetQueryString("subject") != "undefined" && CFN_GetQueryString("subject") != "")){
			$("#Subject").val(($("#simpleSubject").val() == "" ? decodeURIComponent(CFN_GetQueryString("subject")) : $("#simpleSubject").val()));
		}
		if($("#simpleIsAllDay").val() && $("#simpleIsAllDay").val() === "Y"){
			$("#IsAllDay").prop("checked", true);
			
			var sStartDate = $("#detailDateCon_StartDate").val();
			var sStartHour = coviCtrl.getSelected('detailDateCon [name=startHour]').val;
			var sStartMinute = coviCtrl.getSelected('detailDateCon [name=startMinute]').val;
			
			var sEndDate = $("#detailDateCon_EndDate").val();
			var sEndHour = coviCtrl.getSelected('detailDateCon [name=endHour]').val;
			var sEndMinute = coviCtrl.getSelected('detailDateCon [name=endMinute]').val;
			
			$("#hidStartDate").val(sStartDate);
			$("#hidStartHour").val(sStartHour);
			$("#hidStartMinute").val(sStartMinute);
			
			$("#hidEndDate").val(sEndDate);
			$("#hidEndHour").val(sEndHour);
			$("#hidEndMinute").val(sEndMinute);
			
			coviCtrl.setSelected('detailDateCon [name=startHour]', "00");
			coviCtrl.setSelected('detailDateCon [name=startMinute]', "00");
			
			coviCtrl.setSelected('detailDateCon [name=endHour]', "23");
			coviCtrl.setSelected('detailDateCon [name=endMinute]', "59");
			
			// Disabled
			$("#detailDateCon [name=startHour]").find("select").attr("disabled", true);
			$("#detailDateCon [name=startMinute]").find("select").attr("disabled", true);
			$("#detailDateCon [name=endHour]").find("select").attr("disabled", true);
			$("#detailDateCon [name=endMinute]").find("select").attr("disabled", true);
			$("#detailDateCon [name=datePicker]").find("select").attr("disabled", true);
			
			coviCtrl.setSelected('detailDateCon [name=datePicker]', "select");
		}
		if($("#simpleDescription").val()){
			$("#Description").val($("#simpleDescription").val());
		}
		if(isCommunity && scheduleUser.community){
			$("#Description").val(scheduleUser.community.descripion);
		}
		
		// 초기화
		$("#simpleFolderType").val("");
		$("#simpleSubject").val("");
		$("#simpleStartDate").val("");
		$("#simpleEndDate").val("");
		$("#simpleStartHour").val("");
		$("#simpleStartMinute").val("");
		$("#simpleEndHour").val("");
		$("#simpleEndMinute").val("");
		$("#simpleIsAllDay").val("");
		$("#simpleDescription").val("");
		
		// 간단 등록에서 상세 등록으로 이동 시 선택 항목 바인딩
		if(CFN_GetQueryString("simpleDatePicker") != 'undefined'){
			$("[name=datePicker] select").val(CFN_GetQueryString("simpleDatePicker"));
		}
	}
	
	// 에디터 세팅
	function setDescEditor(){
		coviEditor.loadEditor(
				'dext5',
				{
					editorType : g_editorKind,
					containerID : 'tbContentElement',
					frameHeight : '400px',
					useResize : 'N',
					onLoad: 'onLoadDescEditor' 
				}
			);
		
		//$("#dext5").hide();
	}
	
	function onLoadDescEditor(){
		if($("#pSwitchEditor").attr("value")=='editor' && isModify == true){
			coviEditor.setBody(g_editorKind, 'tbContentElement', $("#hidDescription").val());
		}else{
			coviEditor.hide(g_editorKind, 'tbContentElement');
		}
	}
	
	function switchTextAreaEditor(obj){
		if($(obj).attr("value") == "textarea"){
			$("#Description").hide();
			//$("#dext5").show();
			coviEditor.show(g_editorKind, 'tbContentElement');
			
			$(obj).attr("value", "editor");
			$(obj).find("a").html("<spring:message code='Cache.lbl_writeTextArea'/>");			//텍스트로 작성
			
			if(coviEditor.getBodyText(g_editorKind, 'tbContentElement') == $("#Description").val())
				coviEditor.setBody(g_editorKind, 'tbContentElement', $("#hidDescription").val());
			else
				coviEditor.setBody(g_editorKind, 'tbContentElement', $("#Description").val().replaceAll("\n", "<br>"));
		}else{
			//$("#dext5").hide();
			coviEditor.hide(g_editorKind, 'tbContentElement');
			$("#Description").show();
			
			$(obj).attr("value", "textarea");
			$(obj).find("a").html("<spring:message code='Cache.lbl_editChange'/>");		//편집기로 작성
			
			$("#hidDescription").val(coviEditor.getBody(g_editorKind, 'tbContentElement'));
			$("#Description").val(coviEditor.getBodyText(g_editorKind, 'tbContentElement'));
		}
	}
	
	function goAttMemberSch(){
		var len = $("#attendeeAutoComp .autoCompleteCustom .ui-autocomplete-multiselect div").length;
		
		if(len != 0){
			var openURL = "/groupware/schedule/goAttendanceSchedulePopup.do?CLSYS=schedule&CLBIZ=Schedule";
			
			// 예약일자에 맞는 날짜화면 표시
			var dirDate = $("#detailDateCon_StartDate").val();
			if(dirDate != undefined && dirDate != "") {
				openURL += "&startDate=" + dirDate;
			}
			
			var isOutsider = false;
			var attInfos = new Array();
			
			for(var i = 0; i < len; i++){
				var obj = $("#attendeeAutoComp .autoCompleteCustom .ui-autocomplete-multiselect div").get(i);
				var json = JSON.parse($(obj).attr("data-json"));
				
				if (!json.hasOwnProperty("IsOutsider") || json.IsOutsider === 'Y') {
					isOutsider = true;
					break;
				}
				
				attInfos.push(json.UserCode+" "+json.UserName);
			}
			
			if(attInfos.length > 0) {
				openURL += "&attendanceInfos="+attInfos.join(",");	
			}
			
			if(isOutsider){
				Common.Warning("<spring:message code='Cache.msg_cannoutCheckOtherPeople' />"); // 외부 참석자의 일정은 확인할 수 없습니다.
			}else{
				Common.open("", "AttMemSch", "<spring:message code='Cache.lbl_ScheduleManager' />", openURL, "1200px", "565px", "iframe", true, null, null, true); // 연관 문서
			}
		}else{
			Common.Warning("<spring:message code='Cache.msg_enterAttendance' />"); // 참석자를 입력해주세요.
			return false;
		}
	}
	
	//조직도에서 참석자 추가하기
	function addAttendeeAtOrgMap(){
		_CallBackMethod2 = setAttendeeAtOrgMap;
		Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>","/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod2&type=B9","1060px","580px","iframe",true,null,null,true);
	}
	
	function setAttendeeAtOrgMap(data){
		var boolRegisterCheck = false;
		var dataObj = $.parseJSON(data);
		dataObj = $$(dataObj).find("item").concat().json();
		
		$(dataObj).each(function(i){
			var userCode = $$(this).attr("AN");
			var userName = CFN_GetDicInfo($$(this).attr("DN"));
			var DomainID = $$(this).attr("DomainID");
			
			if($("#ulFolderTypes").find("li[data-selvalue="+$("#FolderType").val()+"]").attr("folderType") == "Schedule.Person") {
				if(userCode == Common.getSession("UR_Code")) {
					boolRegisterCheck = true;
					return;
				}
			}
			
			if ($("#attendeeAutoComp").find(".ui-autocomplete-multiselect-item[data-value='"+ userCode+"'], .ui-autocomplete-multiselect-item[data-value^='"+ userCode+"|']").length > 0) {
				Common.Warning("<spring:message code='Cache.ACC_msg_existItem'/>");
				return;
			}
			
			var dataJson = {};
			var dataValue = "";
			
			var attendeeObj = $("<div></div>")
            .addClass("ui-autocomplete-multiselect-item")
            .attr("data-json", JSON.stringify({"UserCode":userCode, "UserName":userName, "MailAddress":$(this).attr("EM"), "label":userName,"value":userCode, "IsOutsider":"N","DomainID":DomainID}))
            .attr("data-value", userCode)
            .text(userName)
            .append(
                $("<span></span>")
                    .addClass("ui-icon ui-icon-close")
                    .click(function(){
                        var item = $(this).parent();
                        item.remove();
                    })
            );
			$(attendeeObj).insertBefore("#Attendee");
		});
		
		if(boolRegisterCheck) {
			Common.Inform("<spring:message code='Cache.msg_no_self_attendant'/>"); //내 일정의 참석자로 본인을 등록할 수 없습니다.
		}
		
	}
	
	
	function deletePlaceInput(){
		
		if(coviCtrl.getAutoTags("Place").length > 0){
			$("#Place").hide();
		}else{
			$("#Place").show();
		}
	}
	
	window.addEventListener( 'message', function(e){
	    // 부모창의 함수 실행
	    if( e.data.functionName === 'saveProjectAllocPopup' ) {
			var key = e.data.params.PrjType+"_"+e.data.params.PrjSeq+"_"+e.data.params.SectionSeq;
			$('#prjMap').attr("data-key", key).text(e.data.params.PrjName+" > "+e.data.params.SectionName);
			$("#btnAddPrjoject i").removeClass("fa-plus").addClass("fa-minus");
	    	//var option = $("<option value='"+key+"'>"+e.data.params.PrjName+" > "+e.data.params.SectionName+"</option>");
            //$('#prjMap').append(option);
	    }
	});
	
	function setPrjInfo(eventID, dateID){
		$.ajax({
			url: "/groupware/collabTask/getCollabTaskMapBySchedule.do",
			type: "POST",
			data: {
				  "objectID"	: eventID
			},
			async: false,
			success: function(data){
				if(data.status === "SUCCESS"){
					var taskMap = data.taskMap;
					
					if(data.taskMap){
						var key = taskMap.PrjType+"_"+taskMap.PrjSeq+"_"+taskMap.SectionSeq;
						var option = $("<option value='"+key+"'>"+taskMap.PrjName+" > "+taskMap.SectionName+"</option>");
						$('#prjMap').append(option);
						$("#prjMap").data("taskSeq", taskMap.TaskSeq);
					}
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/collabTask/getCollabTaskMap.do", response, status, error);
			}
		});
	}

</script>
