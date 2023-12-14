<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<% 
	Cookie[] cookies = request.getCookies();
	String cookieVal = "";
	
	if (cookies != null) {
		for (int i = 0 ; i < cookies.length ; i++) {
			if("CSJTK".equals(cookies[i].getName())){
				cookieVal = cookies[i].getValue();
			}
		} 
	}
%>

<form id="formData" method="post" enctype="multipart/form-data">
<input type="hidden" id="uDnID" value= ""/>

<div class="cRConTop " style="display:none;">
	<div class="cRTopButtons">
		<a href="#" class="btnTypeDefault btnTypeChk" onclick="goAdd('C');"><spring:message code='Cache.btn_register'/></a>
		<a href="#" class="btnTypeDefault btnTypeChk" onclick="goAdd('T');"><spring:message code='Cache.btn_tempsave'/></a>
		<a href="#" class="btnTypeDefault" onclick="javascript:goTFMainPage();"><spring:message code='Cache.btn_Cancel'/></a>
	</div>
</div>
<div class="cRContBottom mScrollVH " style="top: 0;">
	<div class="communityContent commMiddle">
		<div class="commInputBoxDefault">
			<input type="hidden" id="oldTFCode" value= ""/>
			<input type="hidden" id="oldTFCodeCount" value= "0"/>
			
			<div class="inputBoxSytel01 type02">
				<div><span><spring:message code='Cache.lbl_Applicator'/></span></div>
				<div>
					<span id="applicatorInfo"></span>
				</div>
			</div>
			
			<div class="inputBoxSytel01 type02">
				<div><span class="star"><spring:message code='Cache.lbl_TFID'/></span></div>
				<div>
					<input type="text" id="txtTFCode" class="HtmlCheckXSS ScriptCheckXSS">
					<input type="hidden" id="oldTFCode" value= ""/>
					<input type="hidden" id="oldTFCodeCount" value= "0"/>
					
					<a href="#" onclick="CheckTFCode();" class="btnTypeDefault btnThemeLine ml5"><spring:message code='Cache.lbl_apv_DuplicateCheck'/></a> 
					<span class="blueStart ml15"><spring:message code='Cache.msg_explanTFID'/></span>
				</div>
			</div>
			
			<div class="inputBoxSytel01 type02 commName">
				<div><span class="star"><spring:message code='Cache.lbl_TFName'/></span></div>
				<div>
					<input type="text" id="txtTFName" class="HtmlCheckXSS ScriptCheckXSS">
					<input type="hidden" id="oldTFName" value= ""/>
					<input type="hidden" id="oldTFNameCount" value= "0"/>
					<a href="#" onclick="CheckTFName();" class="btnTypeDefault btnThemeLine ml5"><spring:message code='Cache.lbl_apv_DuplicateCheck'/></a>
				</div>
				<div>
				</div>
			</div>
			
			<div class="inputBoxSytel01 type02">
				<div><span class="star"><spring:message code='Cache.lbl_Category_Folder'/></span></div>
				<div>
					<select class="selectType02 size102" id="ddlCategory">
					</select>
				</div>
			</div>
			
			<div class="inputBoxSytel01 type02">
				<div><span class="star"><spring:message code='Cache.lbl_HeadDept'/></span></div>
				<div>
					<input type="text" class="txtInp" id="txtMajorDept" readonly="">
					<input type="hidden" id="hidMajorDeptCode">
				</div>
				<div>
					<a onclick="addDeptAtOrgMap()" class="btnTypeDefault" style="margin-left: 10px;"><spring:message code='Cache.btn_OrgMDM' /></a><!-- 조직도 -->
				</div>
			</div>
			
			<div class="inputBoxSytel01 type02">
				<div><span class="star"><spring:message code='Cache.lbl_TFPeriod'/></span></div>
				<div>
					<div id="divCalendar" class="dateSel type02" style="margin-left: 0;">
						<input class="adDate" type="text" id="startDate" date_separator="." readonly="">
						~ 
						<input class="adDate" type="text" id="endDate" date_separator="." readonly="" kind="twindate" date_startTargetID="startDate" >
					</div>
				</div>
			</div>
			
			<div class="inputBoxSytel01 type02">
				<div><span class="star"><spring:message code='Cache.lbl_TFPM'/></span></div>
				<div>
					<div id="txtPM" class="autoCompleteCustom">
						<div class="ui-autocomplete-multiselect ui-state-default ui-widget" style="width: 100%;"></div>
					</div>
					<input type="hidden" id="hidPMCode">
					<input type="hidden" id="hidPMName">
				</div>
				<div>
					<a onclick="addUserAtOrgMap('PM')" class="btnTypeDefault" style="margin-left: 10px;"><spring:message code='Cache.btn_OrgMDM' /></a><!-- 조직도 -->
				</div>
			</div>
			
			<div class="inputBoxSytel01 type02">
				<div><span class="star"><spring:message code='Cache.lbl_TFAdmin'/></span></div>
				<div>
					<div id="txtAdmin" class="autoCompleteCustom">
						<div class="ui-autocomplete-multiselect ui-state-default ui-widget" style="width: 100%;"></div>
					</div>
					<input type="hidden" id="hidAdminCode">
					<input type="hidden" id="hidAdminName">
				</div>
				<div>
					<a onclick="addUserAtOrgMap('Admin')" class="btnTypeDefault" style="margin-left: 10px;"><spring:message code='Cache.btn_OrgMDM' /></a>
				</div>
			</div>
			
			<div class="inputBoxSytel01 type02">
				<div><span class="star"><spring:message code='Cache.lbl_TFMember'/></span></div>
				<div>
					<div id="txtMember" class="autoCompleteCustom">
						<div class="ui-autocomplete-multiselect ui-state-default ui-widget" style="width: 100%;"></div>
					</div>
					<input type="hidden" id="hidMemberCode">
					<input type="hidden" id="hidMemberName">
				</div>
				<div>
					<a onclick="addUserAtOrgMap('Member')" class="btnTypeDefault" style="margin-left: 10px;"><spring:message code='Cache.btn_OrgMDM' /></a><!-- 조직도 -->
				</div>
			</div>
			
			<div class="inputBoxSytel01 type02">
				<div><span><spring:message code='Cache.lbl_CreateMessengerChannel' /></span></div> <!-- 메신저 채널 생성 -->
				<div class="alarm type01" style="margin-top: 5px;">
					<a id="IsUseMessenger" class="onOffBtn"><span></span></a>
				</div>
			</div>
			
			<div id="securityArea" style="display: none;">
				<div class="inputBoxSytel01 type02">
					<div><span class="star"><spring:message code='Cache.lbl_MessengerChannelOpenYN' /></span></div> <!-- 메신저 채널 공개 여부 -->
					<div>
						<span class="radioStyle04 size">
							<input type="radio" id="channelOpenY" name="channelOpenYN" value="O">
							<label for="channelOpenY"><span><span></span></span><spring:message code='Cache.lbl_apv_open' /></label> <!-- 공개 -->
						</span>
						&nbsp;
						<span class="radioStyle04 size">
							<input type="radio" id="channelOpenN" name="channelOpenYN" value="P">
							<label for="channelOpenN"><span><span></span></span><spring:message code='Cache.lbl_Private' /></label> <!-- 비공개 -->
						</span>
					</div>
				</div>
				<div id="pwArea" class="inputBoxSytel01 type02" style="display: none;">
					<div><span class="star"><spring:message code='Cache.lbl_MessengerPassword' /></span></div> <!-- 메신저 채널 비밀번호 -->
					<div>
						<input type="password" id="txtSecurity">
					</div>
				</div>
			</div>
			
			<div class="inputBoxSytel01 type02">
				<div><span><spring:message code='Cache.lbl_apv_linkdoc'/></span><input type="hidden" id="hidDocLinks"></div>
				<div id="docLinksList">
					<a onclick="openDocLinkTF('doc')" class="btnTypeDefault"><spring:message code='Cache.lbl_apv_linkdoc' /></a><!-- 연결문서 -->
					<%-- <a onclick="deleteDocLinkTF('doc')" class="btnTypeDefault" style="display:none;"><spring:message code='Cache.lbl_apv_link_delete' /></a> --%><!-- 연결삭제 -->
				</div>
			</div>
			
			<div class="inputBoxSytel01 type02"> <!-- 연결현업 -->
				<div><span><spring:message code='Cache.lbl_biztask_linkCollaboration'/></span><input type="hidden" id="hidCollaboLinks"></div>
				<div id="CollaboLinksList">
					<a onclick="openDocLinkTF('project')" class="btnTypeDefault"><spring:message code='Cache.lbl_biztask_linkCollaboration' /></a><!-- 연결 협업 -->
				</div>
			</div>
			
			<!-- 첨부 부분이 들어 올 곳 -->
			<div id="fileDiv" class="inputBoxSytel01 type02">
				<div><span><spring:message code='Cache.lbl_apv_attachfile'/></span></div>
				<div id="fileControl"></div>
			</div>
			
			<div class="inputBoxEdit">
				<div class="inputBoxSytel01 type02">
					<div><span class="star"><spring:message code='Cache.lbl_TFContent'/></span></div>
					<input type="hidden" id="oldtxtContent"/>
					<input type="hidden" id="editChangeNum" value = "N"/>
					<div class="txtEdit" id="editChange">
						<textarea id="txtContent" class="HtmlCheckXSS ScriptCheckXSS" maxlength="300"></textarea>
						<p class="editChange"><a href="#" onclick="editChange()"><spring:message code='Cache.lbl_editChange'/></a></p>
					</div>
				</div>
			</div>
		</div>
	</div>
	<div class="cRContEnd">
		<div class="cRTopButtons">
			<a href="#" class="btnTypeDefault btnTypeChk" onclick="goAdd('C');"><spring:message code='Cache.btn_register'/></a>
			<a href="#" class="btnTypeDefault btnTypeChk" onclick="goAdd('T');"><spring:message code='Cache.btn_tempsave'/></a>
			<a href="#" class="btnTypeDefault" onclick="javascript:goTFMainPage()"><spring:message code='Cache.btn_Cancel'/></a>
			<a href="#" class="btnTop"><spring:message code='Cache.lbl_topMove'/></a>
		</div>
	</div>
</div>
</form>
<script type="text/javascript">
var timeout = "";
var CU_ID = CFN_GetQueryString("CU_ID");

var cookieVal = "<%=cookieVal%>";
var _collaboList = new Array();

var g_editorKind = Common.getBaseConfig('EditorType');

$(function(){
	setEvent();
});

function setEvent(){
	$('.btnTop').on('click', function(){
		$('.mScrollVH').animate({scrollTop:0}, '500');
	});
	
	$("#IsUseMessenger").on("click", function(){
		$("#IsUseMessenger").toggleClass("on");
		if($("#securityArea").css("display") == "none"){
			$("#securityArea").css("display", "table");
		}else{
			$("#securityArea").hide();
		}
	});
	
	$("#securityArea input[name=channelOpenYN]").on("change", function(){
		if($("#securityArea input[name=channelOpenYN]:checked").val() == "P"){
			$("#pwArea").show();
		}else{
			$("#pwArea").hide();
		}
	});
	
	// 세션 DN_ID
	$("#uDnID").val(Common.getSession("DN_ID"));
	
	// 신청자 정보 입력
	$("#applicatorInfo").html(Common.getSession("USERNAME") + " / " + Common.getSession("UR_JobPositionName") + " / " + Common.getSession("DEPTNAME"));
	
	// TF 팀룸 이름 글자 제한
	$("#txtTFName").validation("limitChar",50);
	
	// 구분 select box render
	//coviCtrl.renderDomainAXSelect('ddlCategory', 'ko', '', '', 'ProjectRoomType','');
	var optionArray = new Array();
	var codeArray = Common.getBaseCode('ProjectRoomType').CacheData;
	
	optionArray.push({"optionValue":"","optionText":"<spring:message code='Cache.btn_Select'/>"})
	for(var j = 0; j < codeArray.length; j++) {
		var optionObj = new Object();
		var codeObj = codeArray[j];
		optionObj.optionValue = codeObj.Code;
		if(lang == ''){
			optionObj.optionText = codeObj.CodeName;
		} else {
			optionObj.optionText = CFN_GetDicInfo(codeObj.MultiCodeName, lang);
		}
		optionArray.push(optionObj);
	}
	
	$("#ddlCategory").bindSelect({
		reserveKeys : {
			optionValue : "optionValue",
			optionText : "optionText"
		},
		options : optionArray
	});
	
	// coviFile.fileInfos 초기화
	coviFile.fileInfos.length = 0;
	
	// date field render
	coviInput.setDate();
	
	if(CU_ID != null && CU_ID != "" && CU_ID != "null" && CU_ID != "undefined") { //임시저장 수정
		setData(); //데이터 세팅
	} else { //추가
		coviFile.renderFileControl('fileControl', {listStyle:'table', actionButton :'add', multiple : 'true'});
	}
}

function goTFMainPage(){
	CoviMenu_GetContent("/groupware/layout/biztask_Portal.do?CLSYS=biztask&CLMD=user&CLBIZ=BizTask");
}

function setData() {
	$.ajax({
		type:"POST",
		data:{
			"CU_ID" : CU_ID
		},
		async : false,
		url:"/groupware/layout/selectTFTempSaveData.do",
		success:function (data) {
			if(data.status == "SUCCESS"){
				if(data.TFInfo != undefined && data.TFInfo.length > 0) {
					var info = data.TFInfo[0];
					
					$("#txtTFCode").val(info.CU_Code);
					$("#oldTFCode").val(info.CU_Code);
					$("#oldTFCodeCount").val("1");
					
					$("#txtTFName").val(info.CommunityName);
					$("#oldTFName").val(info.CommunityName);
					$("#oldTFNameCount").val("0");
					
					$("#ddlCategory").bindSelectSetValue(info.TF_DN_ID);
					$("#txtMajorDept").val(info.TF_MajorDept);
					$("#hidMajorDeptCode").val(info.TF_MajorDeptCode);
					
					$("#startDate").val(info.TF_StartDate);
					$("#endDate").val(info.TF_EndDate);
					
					setTFUserInfo(info.TF_PM, info.TF_PMCode, "PM");
					$("#hidPMCode").val(info.TF_PMCode);
					$("#hidPMName").val(info.TF_PM);
					
					setTFUserInfo(info.TF_Admin, info.TF_AdminCode, "Admin");
					$("#hidAdminCode").val(info.TF_AdminCode);
					$("#hidAdminName").val(info.TF_Admin);
					
					setTFUserInfo(info.TF_Member, info.TF_MemberCode, "Member");
					$("#hidMemberCode").val(info.TF_MemberCode);
					$("#hidMemberName").val(info.TF_Member);
					
					if(info.Reserved1 != null && info.Reserved1 != ""){
						$("#IsUseMessenger").addClass("on");
						
						if(info.Reserved1 == "O"){
							$("#channelOpenY").prop("checked", true);
							$("#pwArea").hide();
						}else{
							$("#channelOpenN").prop("checked", true);
							$("#txtSecurity").val(info.Reserved2);
							$("#pwArea").show();
						}
						
						$("#securityArea").show();
					}
					
					$("#hidDocLinks").val(info.TF_DocLinks);
					
					$("#txtContent").val(unescape(info.SearchTitle));
					
					//연결협업 리스트 표기
					inputCollaborationLinkList(info.TF_CollaboLinks);
					
					if(data.fileList != undefined && data.fileList.length > 0) {
						var fileList = JSON.parse(JSON.stringify(data.fileList));
						coviFile.renderFileControl('fileControl', {listStyle:'table', actionButton :'add', multiple : 'true'}, fileList);
					}else{
						coviFile.renderFileControl('fileControl', {listStyle:'table', actionButton :'add', multiple : 'true'});
					}
					
					//연결문서 표시
					G_displaySpnDocLinkInfo();
				}
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/selectTFTempSaveData.do", response, status, error);
		}
	});
}

function setTFUserInfo(urName, urCode, userType){
	if(urName != null && urName != "" && urCode != null && urCode != ""){
		var urNameArr = urName.split(",");
		var urCodeArr = urCode.split(";");
		
		for(var i = 0; i < urNameArr.length; i++){
			var memberObj = $("<div></div>")
			.addClass("ui-autocomplete-multiselect-item")
			.attr("data-json", JSON.stringify({"UserCode": urCodeArr[i],"UserName": urNameArr[i],"label": urNameArr[i],"value": urCodeArr[i]}))
			.attr("data-value", urCodeArr[i])
			.text(urNameArr[i])
			.append(
				$("<span></span>")
					.addClass("ui-icon ui-icon-close")
					.click(function(){
						var userCodes = $("#hid"+userType+"Code").val().split(";");
						var userNames = $("#hid"+userType+"Name").val().split(",");
						var json = JSON.parse($(this).parent().attr("data-json"));
						userCodes = $.grep(userCodes, function(userCodes) {
							return userCodes != json.UserCode;
						});
						userNames = $.grep(userNames, function(userNames) {
							return userNames != json.UserName;
						});
						$("#hid"+userType+"Code").val(userCodes.join(";"));
						$("#hid"+userType+"Name").val(userNames.join(","));
						var item = $(this).parent();
						item.remove();
					})
			);
			$("#txt"+userType+" div").eq(0).append($(memberObj));
		}
	}
}

function CheckTFCode(){
	var tfCode = $("#txtTFCode").val();
	
	if(tfCode == null || tfCode == ""){
		Common.Warning("<spring:message code='Cache.msg_blankValue'/>", "warning", function(answer){ // 빈값을 입력할 수 없습니다.
			if(answer){
				$("#txtTFCode").focus();
			}
		});
		
		return false;
	}
	
	$.ajax({
		type:"POST",
		data:{
			DN_ID : $("#uDnID").val(),
			CU_Code : tfCode
		},
		async : false,
		url:"/groupware/layout/checkTFCode.do",
		success:function (data) {
			if(data.status == "SUCCESS"){
				Common.Warning("<spring:message code='Cache.msg_canusedTfId'/>"); //사용 가능한 T/F팀룸 아이디입니다.
				$("#oldTFCode").val(tfCode);
				$("#oldTFCodeCount").val("1");
			}else{ 
				Common.Warning("<spring:message code='Cache.msg_duplyTfId'/>"); //T/F팀룸 아이디가 중복되어 사용할 수 없습니다.
				$("#oldTFCode").val("");
				$("#oldTFCodeCount").val("0");
			}
		},
		error:function(response, status, error){
			 CFN_ErrorAjax("/groupware/layout/CheckTFCode.do", response, status, error);
		}
	});
}

function CheckTFName(){
	var tfName = $("#txtTFName").val();
	
	if(tfName == null || tfName == ""){
		Common.Warning("<spring:message code='Cache.msg_blankValue'/>", "warning", function(answer){ // 빈값을 입력할 수 없습니다.
			if(answer){
				$("#txtTFName").focus();
			}
		});
		
		return false;
	}
	
	$.ajax({
		type:"POST",
		data:{
			DN_ID : $("#uDnID").val(),
			DisplayName : tfName
		},
		async : false,
		url:"/groupware/layout/checkTFName.do",
		success:function (data) {
			if(data.status == "SUCCESS"){
				Common.Warning("<spring:message code='Cache.msg_canusedTfName'/>"); //사용 가능한 TF 이름입니다.
				$("#oldTFName").val(tfName);
				$("#oldTFNameCount").val("1");
				
				$("#oldTFCodeCount").val("1");
			}else{ 
				Common.Warning("<spring:message code='Cache.msg_duplyTfName'/>"); //TF 이름이 중복되어 사용할 수 없습니다.
				$("#oldTFName").val("");
				$("#oldTFNameCount").val("0");
				$("#oldTFCodeCount").val("0");
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/CheckTFName.do", response, status, error);
		}
	});
}

function addDeptAtOrgMap() {
	Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>","/covicore/control/goOrgChart.do?callBackFunc=deptAdd_CallBack&type=C1","1060px","580px","iframe",true,null,null,true);
}

function deptAdd_CallBack(orgData) {
	var deptJSON =  $.parseJSON(orgData).item[0];
	var deptCode = deptJSON.GroupCode;
	var deptName = CFN_GetDicInfo(deptJSON.GroupName);
	
	$("#txtMajorDept").val(deptName);
	$("#hidMajorDeptCode").val(deptCode);
}

var userType = "";
function addUserAtOrgMap(level) {
	userType = level;
	var type= "B9";
	if(userType=="PM"){
		type= "B1";
	}
	Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>","/covicore/control/goOrgChart.do?callBackFunc=userAdd_CallBack&type="+type,"1060px","580px","iframe",true,null,null,true);
}

function userAdd_CallBack(orgData){
	var userJSON =  $.parseJSON(orgData);
	var lang = Common.getSession("lang");
	
	if(userType=="PM"){
		$("#hidPMCode").val("");
		$("#hidPMName").val("");
		$("#txtPM div").html("");
	}
	
	var userCode = $("#hid"+userType+"Code").val();
	if(userCode != "") userCode += ";";
	
	var userName = $("#hid"+userType+"Name").val();
	if(userName != "") userName += ",";
	
	$(userJSON.item).each(function (i, item) {
		sObjectType = item.itemType;
		if(sObjectType.toUpperCase() == "USER"){ //사용자
			if($("#hid"+userType+"Code").val().indexOf(item.UserCode) < 0) { //기존에 추가된 사용자 중복 추가 방지
				var urName = CFN_GetDicInfo(item.DN, lang);
				userCode += item.UserCode+";";
				userName += urName+",";
				var memberObj = $("<div></div>")
				.addClass("ui-autocomplete-multiselect-item")
				.attr("data-json", JSON.stringify({"UserCode":item.UserCode,"UserName":urName,"label":urName,"value":item.UserCode,"EM":item.EM}))
				.attr("data-value", userCode)
				.text(urName)
				.append(
					$("<span></span>")
						.addClass("ui-icon ui-icon-close")
						.click(function(){
							var userCodes = $("#hid"+userType+"Code").val().split(";");
							var userNames = $("#hid"+userType+"Name").val().split(",");
							var json = JSON.parse($(this).parent().attr("data-json"));
							userCodes = $.grep(userCodes, function(userCodes) {
								return userCodes != json.UserCode;
							});
							userNames = $.grep(userNames, function(userNames) {
								return userNames != json.UserName;
							});
							
							$("#hid"+userType+"Code").val(userCodes.join(";"));
							$("#hid"+userType+"Name").val(userNames.join(","));
							var item = $(this).parent();
							item.remove();
						})
				);
				$("#txt"+userType+" div").eq(0).append($(memberObj));
			}else{
				Common.Warning("<spring:message code='Cache.ACC_msg_existItem'/>"); // 이미 추가된 항목입니다.
			}
		}
	});
	
	if(userCode.length > 0){
		userCode = userCode.substring(0, userCode.length-1);
	}
	
	if(userName.length > 0){
		userName = userName.substring(0, userName.length-1);
	}
	
	$("#hid"+userType+"Code").val(userCode);
	$("#hid"+userType+"Name").val(userName);
}

function editChange(type){
	$("#editChangeNum").val("Y");
	$("#oldtxtContent").val($("#txtContent").val());
	coviEditor.loadEditor(
		'editChange',
		{
			editorType : g_editorKind,
			containerID : 'edit',
			frameHeight : '311',
			focusObjID : '', 
			onLoad: function() {
				coviEditor.setBody(g_editorKind, 'edit', $("#oldtxtContent").val());
			}
		}
	);
}

function goAdd(mode){
	if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
	
	var txtContent = "";
	var txtContentEditer = "";
	var txtContentInlineImage = "";
	
	if($("#editChangeNum").val() == "N"){
		txtContent = $("#txtContent").val();
		txtContentEditer = $("#txtContent").val();
		txtContentInlineImage = "";
	}else{
		txtContent = coviEditor.getBodyText(g_editorKind, 'edit');
		txtContentEditer = coviEditor.getBody(g_editorKind, 'edit');
		txtContentInlineImage = coviEditor.getImages(g_editorKind, 'edit');
	}
	
	if(mode == "C") {
		if($("#txtTFCode").val().replace(/(\s*)/g, "") == ""){
			Common.Warning("<spring:message code='Cache.msg_inputTFCode'/>"); //TF팀룸 아이디를 작성해주세요.
			return ;
		}
		
		if($("#oldTFCodeCount").val() == "0" || $("#oldTFCode").val() != $("#txtTFCode").val()){
			Common.Warning("<spring:message code='Cache.msg_DuplicateCheckTfCode'/>"); //TF팀룸 아이디 중복체크를 하십시오.
			return ;
		}
		
		if($("#txtTFName").val().replace(/(\s*)/g, "") == ""){
			Common.Warning("<spring:message code='Cache.msg_inputTFName'/>"); //TF팀룸 이름을 작성해주세요.
			return ;
		}
		
		if($("#oldTFNameCount").val() == "0" || $("#oldTFName").val() != $("#txtTFName").val()){
			Common.Warning("<spring:message code='Cache.msg_DuplicateCheckTfName'/>"); //TF팀룸 이름 중복체크를 하십시오.
			return ;
		}
		
		/* 분류 선택 */
		if($("#ddlCategory").val() == ""){
			Common.Warning("<spring:message code='Cache.msg_please_select_classification'/>"); //분류를 선택 해 주세요
			return ;
		}
		
		if($("#txtMajorDept").val() == ""){
			Common.Warning("<spring:message code='Cache.msg_fillHeadDept'/>"); //주관부서를 선택해주세요.
			return ;
		}
		
		if($("#startDate").val() == "" || $("#endDate").val() == ""){
			Common.Warning("<spring:message code='Cache.msg_fillPeriod'/>"); //수행기간을 입력해주세요.
			return ;
		}
		
		if($("#txtPM div div").length == 0){
			Common.Warning("<spring:message code='Cache.msg_fillPM'/>"); //PM을 선택해주세요.
			return ;
		}
		
		if($("#txtAdmin div div").length == 0){
			Common.Warning("<spring:message code='Cache.msg_fillViewer'/>"); //간사를 선택해주세요.
			return ;
		}
		
		if($("#txtMember div div").length == 0){
			Common.Warning("<spring:message code='Cache.msg_fillMember'/>"); //팀원을 선택해주세요.
			return ;
		}
		
		if($("#IsUseMessenger").hasClass("on")){
			var cOpen = $("#securityArea input[name=channelOpenYN]:checked").val();
			
			if(cOpen == null || cOpen == ""){
				Common.Warning("<spring:message code='Cache.msg_selectMessengerChannelOpenYN'/>"); //메신저 채널 공개 여부를 선택해 주세요.
				return;
			}
			
			if(cOpen == "P" && $("#txtSecurity").val() == ""){
				Common.Warning("<spring:message code='Cache.msg_ObjectUR_03'/>"); //비밀번호를 입력하여 주십시오.
				return;
			}
		}
		
		if(txtContent == ""){
			Common.Warning("<spring:message code='Cache.msg_fillTfContent'/>"); //추진내용을 입력해주세요.
			return ;
		}
		
		//PM, 간사, 팀원 중복 체크
		var Code = "";
		var CompareCode1 = "";
		var CompareCode2 = "";
		var Result = true;
		
		Code = $("#hidPMCode").val().split(";");
		CompareCode1 = $("#hidAdminCode").val().split(";");
		CompareCode2 = $("#hidMemberCode").val().split(";");
		for (i = 0; i < Code.length; i++) {
			for (j = 0; j < CompareCode1.length; j++) {
				if (Code[i] == CompareCode1[j]) {
					Result = false;
				}
			}
			for (k = 0; k < CompareCode2.length; k++) {
				if (Code[i] == CompareCode2[k]) {
					Result = false;
				}
			}
		}
		
		for (i = 0; i < CompareCode1.length; i++) {
			for (j = 0; j < CompareCode2.length; j++) {
				if (CompareCode1[i] == CompareCode2[j]) {
					Result = false;
				}
			}
		}
		
		if (!Result) {
			Common.Warning("<spring:message code='Cache.msg_MemberOverlap'/>"); //팀원이 중복되었습니다.
			return false;
		}
	}
	
	var formData = new FormData();
	
	if(CU_ID != null && CU_ID != "" && CU_ID != "null" && CU_ID != "undefined") {
		formData.append("CU_ID", CU_ID);
	}
	
	formData.append("txtTFCode", $("#txtTFCode").val());
	formData.append("txtTFName", $("#txtTFName").val());
	
	formData.append("Category", $("#ddlCategory").val());
	
	formData.append("txtMajorDeptCode", $("#hidMajorDeptCode").val());
	formData.append("txtMajorDept", $("#txtMajorDept").val());
	
	formData.append("txtStart",  $("#startDate").val());
	formData.append("txtEnd",  $("#endDate").val());
	
	formData.append("txtPMCount", $("#hidPMCode").val().split(";").length);
	formData.append("txtPMCode", $("#hidPMCode").val());
	formData.append("txtPM", $("#hidPMName").val());
	
	formData.append("txtAdminCount", $("#hidAdminCode").val().split(";").length);
	formData.append("txtAdminCode", $("#hidAdminCode").val());
	formData.append("txtAdmin", $("#hidAdminName").val());
	
	formData.append("txtMemberCount", $("#hidMemberCode").val().split(";").length);
	formData.append("txtMemberCode", $("#hidMemberCode").val());
	formData.append("txtMember", $("#hidMemberName").val());
	
	formData.append("IsUseMessenger", $("#IsUseMessenger").hasClass("on") ? "Y" : "N");
	
	if($("#IsUseMessenger").hasClass("on")){
		var memberArr = new Array();
		var authMemberArr = new Array();
		var cOpen = $("#securityArea input[name=channelOpenYN]:checked").val();
		var security = "";
		
		if(cOpen == "P") security = $("#txtSecurity").val();
		
		$.each($("#hidPMCode").val().split(";"), function(idx, pmCode){
			memberArr.push(pmCode);
			authMemberArr.push(pmCode);
		});
		
		$.each($("#hidAdminCode").val().split(";"), function(idx, adminCode){
			memberArr.push(adminCode);
		});
		
		$.each($("#hidMemberCode").val().split(";"), function(idx, memberCode){
			memberArr.push(memberCode);
		});
		
		formData.append("members", JSON.stringify(memberArr));
		formData.append("authMembers", JSON.stringify(authMemberArr));
		formData.append("openType", cOpen);
		formData.append("security", security);
		formData.append("CSJTK", cookieVal);
	}
	
	formData.append("txtDocLinks", $("#hidDocLinks").val());
	
	//연결협업리스트
	formData.append("txtCollaboLinks", JSON.stringify(_collaboList));
	
	formData.append("frontStorageURL", escape(Common.getGlobalProperties("smart4j.path")+ Common.getBaseConfig("FrontStorage").replace("{0}", Common.getSession("DN_Code"))));
	formData.append("fileInfos", JSON.stringify(coviFile.fileInfos));
	for (var i = 0; i < coviFile.files.length; i++) {
		if (typeof coviFile.files[i] == 'object') {
			formData.append("files", coviFile.files[i]);
		}
	}
	formData.append("fileCnt", coviFile.fileInfos.length);
	
	formData.append("txtContentSize", txtContent.length);
	formData.append("txtContent", txtContent); //Description
	formData.append("txtContentEditer", txtContentEditer); //DescriptionEditor
	formData.append("txtContentInlineImage", txtContentInlineImage); //DescriptionInlineImage
	formData.append("ContentOption", $("#editChangeNum").val()); //DescriptionOption
	
	var confirmMessage = "<spring:message code='Cache.msg_TFConfirm'/>"; //위와 같이 T/F 팀룸을 신청하시겠습니까?
	var url = "/groupware/layout/createTFTeamRoom.do";
	var successMessage = "<spring:message code='Cache.msg_SuccessRegist'/>"; //성공적으로 등록되었습니다.
	var gotoUrl = '/groupware/layout/TF_TFMainList.do?CLSYS=biztask&CLMD=user&CLBIZ=BizTask';
	if(mode == "T") {
		confirmMessage = "<spring:message code='Cache.msg_TFTempSaveConfirm'/>"; // T/F 팀룸을 임시저장하시겠습니까?
		url = "/groupware/layout/tempSaveTFTeamRoom.do";
		successMessage = "<spring:message code='Cache.msg_Been_saved'/>"; //저장되었습니다.
		gotoUrl = '/groupware/layout/TF_TFTempList.do?CLSYS=biztask&CLMD=user&CLBIZ=BizTask';
	}
	
	Common.Confirm(confirmMessage, "Confirmation Dialog", function (confirmResult) {
		if (confirmResult) {
			$.ajax({
				url:url,
				type:"post",
				data:formData,
				dataType:'json',
				processData:false,
				contentType:false,
				success:function (data) {
					if(data.status == "SUCCESS"){
						Common.Inform(successMessage);
						CoviMenu_GetContent(gotoUrl);
						
						if(mode == "C") {
							approvalJoinTf(data.cuId,$("#txtTFName").val(),data.toArray);
						}
					}else{
						Common.Warning("<spring:message code='Cache.msg_38'/>");
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax(url, response, status, error);
				}
			});
		}
	});
}

function movePage() {
	CoviMenu_GetContent(g_lastURL);
}

/*연결문서 시작 */
function openDocLinkTF(type){
	var iWidth = 840; iHeight = 660; sSize = "fix";
	var sUrl = "/approval/goDocListSelectPage.do";		//"/WebSite/Approval/DocList/DocListSelect.aspx";
	if(type == "project"){
		sUrl = "/groupware/tf/goTFListLinkPopup.do";
	}
	CFN_OpenWindow(sUrl, "", iWidth, iHeight, sSize);
}

function InputDocLinks(szValue) {
	try {
		if (document.getElementById("hidDocLinks").value == "") {
			document.getElementById("hidDocLinks").value = szValue; G_displaySpnDocLinkInfo();
		}
		else {
			adddocitem(szValue);
		}
	}
	catch (e) {coviCmn.traceLog(e);
	}
}

function adddocitem(szAddDocLinks) {
	var adoclinks = document.getElementById("hidDocLinks").value.split("^^^");
	var aadddoclinks = szAddDocLinks.split("^^^");
	var szdoclinksinfo = "";
	var tmp = "";
	
	for (var i = 0; i < aadddoclinks.length; i++) {
		if (aadddoclinks[i] != null) {
			var bexitdoclinks = false;
			for (var j = 0; j < adoclinks.length; j++) { if (aadddoclinks[i] == adoclinks[j]) { bexitdoclinks = true; } }
			if (!bexitdoclinks) adoclinks[adoclinks.length] = aadddoclinks[i];
		}
	}
	
	for (var k = 0; k < adoclinks.length; k++) {
		if (adoclinks[k] != null) {
			if (szdoclinksinfo != "") {
				szdoclinksinfo += "^^^" + adoclinks[k];
			} else {
				szdoclinksinfo += adoclinks[k];
			}
		}
	}
	document.getElementById("hidDocLinks").value = szdoclinksinfo;
	G_displaySpnDocLinkInfo();
}

function deleteDocLinkTF(obj) {
	var adoclinks = document.getElementById("hidDocLinks").value.split("^^^");
	var szdoclinksinfo = "";
	
	if(obj != undefined){
		var cuId = $(obj).data("cuid");
		
		for (var j = adoclinks.length - 1; j >= 0; j--) {
			if (adoclinks[j] != null && adoclinks[j].indexOf(cuId) > -1) {
				adoclinks[j] = null;
			}
		}
		
		for (var i = 0; i < adoclinks.length; i++) {
			if (adoclinks[i] != null) {
				if (szdoclinksinfo != "") {
					szdoclinksinfo += "^^^" + adoclinks[i];
				} else {
					szdoclinksinfo += adoclinks[i];
				}
			}
		}
	}else{
		var chkDoc = $("#docLinksList .td_check");
		var tmp = "";
		if (chkDoc.length > 0) {
			chkDoc.each(function (i, elm) {
				if ($(elm).is(":checked")) {
					tmp = $(elm)[0].value;
					for (var j = adoclinks.length - 1; j >= 0; j--) {
						if (adoclinks[j] != null && adoclinks[j].indexOf(tmp) > -1) {
							adoclinks[j] = null;
						}
					}
				}
			});
		}
		for (var i = 0; i < adoclinks.length; i++) {
			if (adoclinks[i] != null) {
				if (szdoclinksinfo != "") {
					szdoclinksinfo += "^^^" + adoclinks[i];
				} else {
					szdoclinksinfo += adoclinks[i];
				}
			}
		}
		
	}
	
	document.getElementById("hidDocLinks").value = szdoclinksinfo;
	G_displaySpnDocLinkInfo();
}

function G_displaySpnDocLinkInfo() {//수정본
	var szdoclinksinfo = "";
	var szdoclinks =  $("#hidDocLinks").val();
	szdoclinks = szdoclinks.replace("undefined^", "");
	szdoclinks = szdoclinks.replace("undefined", "");
	var bEdit = false; 
	var bDisplayOnly = true;
	if (document.location.href.indexOf("Info.") > -1 || document.location.href.indexOf("InfoViewPopup.") > -1) {
		bEdit = false;
	} else {
		bEdit = true;bDisplayOnly=false;
	}
	if (bEdit) {
		szdoclinksinfo += "<a onclick='openDocLinkTF()' class='btnTypeDefault'>"+"<spring:message code='Cache.lbl_apv_linkdoc' />"+"</a>";
	}
	
	if (szdoclinks != "") {
		var adoclinks = szdoclinks.split("^^^");
		for (var i = 0; i < adoclinks.length; i++) {
			var adoc = adoclinks[i].split("@@@");
			var FormUrl = document.location.protocol + "//" + document.location.host + "/approval/approval_Form.do";
			var iWidth = 790;
			var iHeight = window.screen.height - 82;
			if (bEdit) {
					szdoclinksinfo += "<ul style='display:flex'><li>";
					szdoclinksinfo += "<span class='td_txt' onmouseover='this.style.color=\"#2f71ba\";' onmouseout='this.style.color=\"#111111\";'  style='cursor:pointer;float:left;'  onclick=\"CFN_OpenWindow('";
					szdoclinksinfo += FormUrl + "?mode=COMPLETE" + "&processID=" + adoc[0] + "&forminstanceID=" + (typeof adoc[3] != "undefined" ? adoc[3] : "&archived=true") + "&bstored=" + (typeof adoc[4] != "undefined" ? adoc[4] : "false");
					szdoclinksinfo += "',''," + iWidth + ", " + iHeight + ", 'scroll') \">" + adoc[2] + "</span>";
					szdoclinksinfo += "<span class='btnListRemove' onclick='deleteDocLinkTF(this);' style='float: left;margin: 3px 0px 0px 7px;position: relative;cursor: pointer;' data-linktype='doc' data-cuid='"+adoc[0]+"'></span>"
					szdoclinksinfo += "</li></ul>";
					
					//szdoclinksinfo += "<input type='checkbox' name='_" + adoc[0] + "' value='" + adoc[0] + "' class='td_check' style='float:none;'>";
					//szdoclinksinfo += "<span class='td_txt' onmouseover='this.style.color=\"#2f71ba\";' onmouseout='this.style.color=\"#111111\";'  style='cursor:pointer;float:none;'  onclick=\"CFN_OpenWindow('";
					//szdoclinksinfo += FormUrl + "?mode=COMPLETE" + "&processID=" + adoc[0] + "&forminstanceID=" + (typeof adoc[3] != "undefined" ? adoc[3] : "&archived=true") + "&bstored=" + (typeof adoc[4] != "undefined" ? adoc[4] : "false");
					//szdoclinksinfo += "',''," + iWidth + ", " + iHeight + ", 'scroll') \">" + adoc[2] + "</span><br />";
			} else {
				if (bDisplayOnly) {
					szdoclinksinfo += adoc[2];
				} else {
					szdoclinksinfo += "<span class='txt_gn11_blur' onmouseover='this.style.color=\"#2f71ba\";' onmouseout='this.style.color=\"#111111\";'  style='cursor:pointer;'  onclick=\"CFN_OpenWindow('";
					szdoclinksinfo += FormUrl + "?mode=COMPLETE" + "&processID=" + adoc[0] + "&forminstanceID=" + (typeof adoc[3] != "undefined" ? adoc[3] : "&archived=true") + "&bstored=" + (typeof adoc[4] != "undefined" ? adoc[4] : "false");
					szdoclinksinfo += "',''," + iWidth + ", " + iHeight + ", 'scroll') \">- " + adoc[2] + "</span><br />";
				}
			}
		}
	}
	$("#docLinksList").html(szdoclinksinfo);
}
/* function G_displaySpnDocLinkInfo() {//수정본
	var szdoclinksinfo = "";
	var szdoclinks =  $("#hidDocLinks").val();
	szdoclinks = szdoclinks.replace("undefined^", "");
	szdoclinks = szdoclinks.replace("undefined", "");
	var bEdit = false; 
	var bDisplayOnly = true;
	if (document.location.href.indexOf("Info.") > -1 || document.location.href.indexOf("InfoViewPopup.") > -1) {
		bEdit = false;
	} else {
		bEdit = true;bDisplayOnly=false;
	}
	if (bEdit) {
		szdoclinksinfo += "<a onclick='openDocLinkTF()' class='btnTypeDefault'>"+"<spring:message code='Cache.lbl_apv_linkdoc' />"+"</a>";
		szdoclinksinfo += "&nbsp;<a onclick='deleteDocLinkTF()' class='btnTypeDefault'>"+"<spring:message code='Cache.lbl_apv_link_delete' />"+"</a><br />";
	}
	if (szdoclinks != "") {
		var adoclinks = szdoclinks.split("^^^");
		for (var i = 0; i < adoclinks.length; i++) {
			
			var adoc = adoclinks[i].split("@@@");
			var FormUrl = document.location.protocol + "//" + document.location.host + "/approval/approval_Form.do";
			var iWidth = 790;
			var iHeight = window.screen.height - 82;
			if (bEdit) {
					szdoclinksinfo += "<input type='checkbox' name='_" + adoc[0] + "' value='" + adoc[0] + "' class='td_check' style='float:none;'>";
					szdoclinksinfo += "<span class='td_txt' onmouseover='this.style.color=\"#2f71ba\";' onmouseout='this.style.color=\"#111111\";'  style='cursor:pointer;float:none;'  onclick=\"CFN_OpenWindow('";
					szdoclinksinfo += FormUrl + "?mode=COMPLETE" + "&processID=" + adoc[0] + "&forminstanceID=" + (typeof adoc[3] != "undefined" ? adoc[3] : "&archived=true") + "&bstored=" + (typeof adoc[4] != "undefined" ? adoc[4] : "false");
					szdoclinksinfo += "',''," + iWidth + ", " + iHeight + ", 'scroll') \">" + adoc[2] + "</span><br />";
			} else {
				if (bDisplayOnly) {
					szdoclinksinfo += adoc[2];
				} else {
					szdoclinksinfo += "<span class='txt_gn11_blur' onmouseover='this.style.color=\"#2f71ba\";' onmouseout='this.style.color=\"#111111\";'  style='cursor:pointer;'  onclick=\"CFN_OpenWindow('";
					szdoclinksinfo += FormUrl + "?mode=COMPLETE" + "&processID=" + adoc[0] + "&forminstanceID=" + (typeof adoc[3] != "undefined" ? adoc[3] : "&archived=true") + "&bstored=" + (typeof adoc[4] != "undefined" ? adoc[4] : "false");
					szdoclinksinfo += "',''," + iWidth + ", " + iHeight + ", 'scroll') \">- " + adoc[2] + "</span><br />";
				}
			}
		}
	}
	$("#docLinksList").html(szdoclinksinfo);
} */
/*연결문서 끝*/
 
/*연결협업*/
function inputCollaborationLinkList(obj){
	if(obj != undefined && obj.length > 0){
		obj.forEach(function(item){
			var objFlag = true;
			_collaboList.forEach(function(c){
				if(c.CU_ID == item.CU_ID){
					objFlag = false;
				}
			});
			if(objFlag){
				_collaboList.push({"CU_ID":item.CU_ID,"CommunityName" : item.CommunityName});
			}
		});
	}
	//협업리스트 표기
	gridCollaboList();
}

function gridCollaboList(){
	var cHtml = "<a onclick='openDocLinkTF(\"project\")'  class='btnTypeDefault'><spring:message code='Cache.lbl_biztask_linkCollaboration' /></a>";
	_collaboList.forEach(function (item){
		//cHtml += "<input type='checkbox' name='_" + item.CU_ID + "' value='" + item.CU_ID +"' class='td_check' style='float:none;'>";
		cHtml += "<ul style='display:flex'><li>";
		cHtml += "<span class='td_txt' onmouseover='this.style.color=\"#2f71ba\";' onmouseout='this.style.color=\"#111111\";'  style='cursor:pointer;float:left;' >";
		cHtml += item.CommunityName;
		cHtml += "</span>"
		cHtml += "<span class='btnListRemove' onclick='removeLinkData(this);' style='float: left;margin: 3px 0px 0px 7px;position: relative;cursor: pointer;' data-linktype='project' data-cuid='"+item.CU_ID+"'></span>"
		cHtml += "</li></ul>";
	});
	
	$("#CollaboLinksList").html(cHtml);
}

function removeLinkData(obj){
	var linkType = $(obj).data("linktype");
	var cuId = $(obj).data("cuid");
	
	var _tempList = new Array();
	_collaboList.forEach(function (item){
		if(item.CU_ID != cuId ){
			_tempList.push(item);
		}
	});
	_collaboList = _tempList;
	
	gridCollaboList();
}

//팀룸 등록 완료시 팀원 대상자 메일 발송
function approvalJoinTf(cuId,projectNm,toList){
	var userNm = CFN_GetDicInfo(Common.getSession("UR_MultiName"));
	var userMail = Common.getSession("UR_Mail");	// 발신인 메일
	var arrTo = []; // 받는 사람
	toList.forEach(function(userObj){
		var receiver = new Object();
		receiver['UserName'] = userObj.UserName;
		receiver['MailAddress'] = userObj.MailAddress;
		arrTo.push(receiver);
	});
	
	var specs  = "left=10,top=10,width=1050,height=900";
			specs += ",toolbar=no,menubar=no,status=no,scrollbars=no,resizable=no";
	var contentLink  = "<a href='/groupware/layout/userCommunity/communityMain.do?C="+cuId+"' ";
		contentLink += "onclick='window.open(this.href,\"community\",\""+specs+"\"); return false;'>";
		contentLink += projectNm;
		contentLink += "</a>";
	var content = String.format(Common.getDic("msg_TFCreateMail_Content"),userNm,projectNm,contentLink);
	var text = content.replace(/\\n/gi,'</br>');
	
	var params = {
		"subject" : String.format("<spring:message code='Cache.msg_TFCreateMail_Subject'/>",projectNm)	//제목
		,"to" : arrTo // 받는 사람
		,"content" : text
		,"contentText" : content 
		,"sentSaveYn" : 'Y' // 보낸메일함 저장 여부(Y: 저장 N: 저장안함)
		,"from" : userMail // 보낸 사람
		,"userMail" : userMail // 발신인 메일 주소
		,"userName" : userNm // 발신인 이름
	}
	
	$.ajax({
		type : "POST",
		data: JSON.stringify(params),
		contentType: "application/json",
		dataType: "json",
		url : "/mail/userMail/simpleMailSent.do",
		success:function (data) {
			if(data.resultTy == "S"){
				Common.Inform("<spring:message code='Cache.msg_tf_mail_send_ok'/>");	//참여신청 되었습니다.
			}
		},
		error:function(response, status, error) {
			CFN_ErrorAjax("/mail/userMail/simpleMailSent.do", response, status, error);
		}
		
	});
}
</script>