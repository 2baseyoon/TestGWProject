<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<style>
</style>
<div class="cRConTop">
	<div class="cRTopButtons">
		<a href="#" name="btnCreate" class="btnTypeDefault btnTypeChk" onclick="javascript:setMessage('C');"><spring:message code='Cache.btn_register'/></a>	<!-- 등록 -->
		<a href="#" name="btnUpdate" class="btnTypeDefault btnTypeChk" onclick="javascript:setMessage();"><spring:message code='Cache.btn_Confirm'/></a>	<!-- 확인 -->
		<a href="#" name="btnRevision" class="btnTypeDefault" onclick="javascript:setMessageRevision();"><spring:message code='Cache.btn_Revision'/></a>	<!-- 개정 -->
		<a href="#" name="btnTemp" class="btnTypeDefault" onclick="javascript:setMessage('T');"><spring:message code='Cache.btn_tempsave'/></a>				<!-- 임시저장 -->
		<a href="#" name="btnCancel" class="btnTypeDefault" onclick="javascript:cancelMessage();"><spring:message code='Cache.btn_Cancel'/></a>				<!-- 취소 -->
	</div>
	<div class="surveySetting">
		<a href="#" class="surveryContSetting btnMakeCont">설정</a>
		<!-- <a href="#" class="surveryWinPop">팝업</a> -->
	</div>
</div>
<form id="formData" method="post" enctype="multipart/form-data">
	<div class="cRContBottom mScrollVH ">
		<div class="docAllCont">
			<div class="docTopCont allMakeSettingView active">
				<div class="allMakeView">
					<div class="inpStyle01 allMakeTitle">
						<input type="text" id="Subject" name="subject" class="inpStyle01 HtmlCheckXSS ScriptCheckXSS" maxlength="128" placeholder="<spring:message code='Cache.msg_EnterSubject'/>">
					</div>
				</div>
				<div class=" ">
					<div class="inStyleSetting ">
						<div class="inputBoxContent">
							<div class="inputBoxSytel01 type02">
								<div><span><spring:message code='Cache.lbl_DocCate'/></span></div>	<!-- 문서분류 -->
								<div class="pathArea">
									<div class="path">
									</div>
									<div class="btnArea">
										<a href="#" id="btnFolder" class="btnTypeDefault btnIco btnTypeBlue btnTypeSelect"><spring:message code='Cache.lbl_Select'/></a>	<!-- 선택 -->										
										<a href="#" id="btnMultiFolder" class="btnTypeDefault btnIco btnTypeBlue btnTypeSelect" style="display: none;"><spring:message code='Cache.lbl_selectMultiCategory'/></a>	<!-- 다중분류 선택 -->										
									</div>
								</div>
								<div class="inputBoxSytel01 subDepth type02">
									<div><span><spring:message code='Cache.lbl_DocNo'/></span></div>	<!-- 문서번호 -->
									<div>
										<input type="text" id="DocNumber" name="docNumber" class="HtmlCheckXSS ScriptCheckXSS">
									</div>
								</div>
							</div>
							<div id="divMultiFolderArea" class="inputBoxSytel01 type02" style="display: none;">
								<div><spring:message code='Cache.lbl_MultiClass'/></div> <!-- 다중분류 -->
								<div>
									<div id="divMultiFolderPath" class="autoComText clearFloat"></div>
								</div>
							</div>
							<div class="inputBoxSytel01 type02">
								<div><span><spring:message code='Cache.lbl_Register'/></span></div>	<!-- 등록자 -->
								<div>
									<input type="text" id="CreatorName" name="creatorname" readonly="" class="inpReadOnly HtmlCheckXSS ScriptCheckXSS">
								</div>
								<div class="inputBoxSytel01 subDepth type02">
									<div><span><spring:message code='Cache.lbl_RegistDept'/></span></div>	<!-- 등록부서 -->
									<div>
										<select id="selectRegistDept" name="registDept" class="selectType02 size153"></select>
										<span id="RegistDeptName"></span>
									</div>
								</div>
							</div>
	
							<div class="inputBoxSytel01 type02">
								<div><span><spring:message code='Cache.lbl_Owner'/></span></div>	<!-- 소유자 -->
								<div>
									<span id="spanOwnerName" style="display:none;"></span>
									<div id="divOwnerName" class="autoCompleteCustom">
										<input type="text" id="OwnerName" name="ownerName" class="wide HtmlCheckXSS ScriptCheckXSS">
<!-- 										<div id="OwnerName" class="ui-autocomplete-multiselect ui-state-default ui-widget"> -->
<!-- 											<div id="" class="ui-autocomplete-multiselect-item"><span class="ui-icon ui-icon-close"></span></div> -->
<!-- 										</div> -->
										<a href="#" id="btnOwner" class="btnTypeDefault btnTypeBlue"><spring:message code='Cache.btn_Add'/></a>	<!-- 추가 -->
									</div>
								</div>
								<div class="inputBoxSytel01 subDepth type02">
									<div><span><spring:message code='Cache.lbl_KeepYear'/></span></div>	<!-- 보존년한 -->
									<div>
										<select id="selectKeepyear" name="keepyear" class="selectType02 size153" onchange="javascript:changeKeepYear(this);">
										</select>
									</div>
								</div>
							</div>
							<div id="divUserDefFieldHeader" class="inputBoxSytel01 type01" >
								<div>
									<span><spring:message code='Cache.btn_ExtendedField'/></span><a href="#" class="btnMoreStyle01 btnSurMove active" data-index="0">필드추가 더보기</a>
								</div>
								<div></div>
							</div>
							<!-- 사용자 정의 필드 입력 항목 -->
							<div id="divUserDefField" class="makeMoreInput active" > </div>
						</div>
					</div>
				</div>
			</div>
			<div class="boradBottomCont">
				<!-- 에디터 항목 -->
				<div id="divWebEditor" class="writeEdit">
<!-- 					<textarea rows="10" style="width: 100%; height:311px;" id="BodyText" name="bodyText" class="AXTextarea"></textarea> -->
		<!-- 			<script type="text/javascript" src="/covicore/resources/script/Dext5/js/dext5editor.js"></script> -->
		<!-- 			<script src="/covicore/resources/script/Dext5/Dext5.js" type="text/javascript"></script>      -->
				</div>
			
			<!-- 파일 첨부 항목 -->
			<div class="inputBoxContent">
				<!-- 첨부 부분이 들어 올 곳 -->
				<div  id="fileDiv" class="inputBoxSytel01 type02"  style="display:none;">
					<div><span><spring:message code='Cache.lbl_apv_attachfile'/></span></div>	<!-- 파일 첨부 -->
<!-- 					<div><span class="sNoti">* 업로드 제한 용량 : <span id="limitFileSize">20</span>MB</span></div> -->
					<div id="con_file"></div>
				</div>
				<div class="inputBoxSytel01 type02">
					<div><span><spring:message code='Cache.lbl_SecurityGrade'/></span></div>	<!-- 보안등급 -->
					<div>
						<select id="selectSecurityLevel" name="securityLevel"/></select>
					</div>
				</div>
				<div class="inputBoxSytel01 type02">
					<div><spring:message code='Cache.lbl_authSetting'/></div>	<!-- 권한 설정 -->
					<div>
						<a href="#" class="btnTypeDefault btnIco btnTypeBlue btnAuthority" onclick="javascript:goMessageAuthPopup();"><spring:message code='Cache.lbl_MessageDetailAuth'/></a>	<!-- 상세권한 -->
					</div>
				</div>
				<div class="subUnputBoxStyle">
					<div id="divLinkedMessage" class="inputBoxSytel01 type02">
						<div><span id="spanLinkedHeader"><spring:message code='Cache.lbl_LinkDoc'/></span></div>	<!-- 연결 문서/바인더 -->
						<div>
<!-- 							<a href="#" class="btnTypeDefault" onclick="javascript:board.searchMessagePopup('Link', 'Doc')" >추가</a> -->
							<a href="#" id="btnAddMessage" class="btnTypeDefault"><spring:message code='Cache.btn_Add'/></a>	<!-- 추가 -->
							<a href="#" class="btnTypeDefault ml5" onclick="javacript:board.deleteLinkedMessageAll();"><spring:message code='Cache.btn_DelAll'/></a>	<!-- 전체삭제 -->
						</div>
					</div>
					<input type="hidden" id="hiddenLinkedMessage" name="linkedMessage" value=""/>
					<div>
						<div class="inputBoxSytel01 type02">
							<div></div>
							<div>
								<div id="divLinkedList" class="autoComText clearFloat">
<!-- 									<div>구글 음성 인식 기능을 활용한 타이핑<a href="#" class="btnRemoveAuto">삭제</a></div> -->
<!-- 									<div>9월 출장신청서<a href="#" class="btnRemoveAuto">삭제</a></div> -->
								</div>
							</div>
						</div>
					</div>						
															
					<!-- 태그 설정 영역  -->
					<div id="divTagHeader" class="inputBoxSytel01 type02">
						<div>
							<span><spring:message code='Cache.lbl_Tag'/></span><span id="tagCount" class="pCount">(0<spring:message code='Cache.lbl_Count'/>)</span> <!-- 개 -->
							<a href="#" class="btnMoreStyle01 btnSurMove active">태그 더보기</a></div>
						<div>
							<input type="text" id="tag" class="midInput HtmlCheckXSS ScriptCheckXSS">
							<a href="#" class="btnTypeDefault" onclick="javascript:board.addTag();">추가</a>
							<span class="sNoti">* <spring:message code='Cache.lbl_Board_AllowTagCount'/></span>		<!-- 최대 10개 등록 가능 -->
						</div>
					</div>
					<div class="makeMoreInput active">
						<div class="inputBoxSytel01 type02">
							<div></div>
							<div>
								<div id="divTagList" class="autoComText clearFloat">
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
	<div class="cRContEnd">
		<a href="#" class="btnTop">탑으로 이동</a>
	</div>
</div>
	<input type="hidden" id="hiddenFolderID" value=""/>
	<input type="hidden" id="hiddenMultiFolderID" value=""/> <!-- 다중분류 -->
	<input type="hidden" id="hiddenFolderPath" value=""/>

	<input type="hidden" id="ExpiredDate" />
	<input type="hidden" id="FolderType" name="folderType" value="" />
	<input type="hidden" id="UseSecurity" name="useSecurity" value="">					<!-- 비밀글 여부 -->
	<input type="hidden" id="UseAutoDocNumber" />										<!-- 자동발번 사용여부 -->
	<input type="hidden" id="UseMessageReadAuth" name="useMessageReadAuth" value="" />	<!-- 열람권한 사용여부 -->
	<input type="hidden" id="messageReadAuth" name="messageReadAuth" value="" />		<!-- 열람권한 설정정보 -->
	<input type="hidden" id="UseMessageAuth" name="useMessageAuth" value="" />			<!-- 상세권한 사용 여부 -->
	<input type="hidden" id="messageAuth" name="messageAuth" value="" />				<!-- 상세권한 설정정보 -->
	<input type="hidden" id="IsInherited" name="isInherited" value="N" />				<!-- 폴더 권한 상속 여부 -->
	<input type="hidden" id="GroupName" value="" />	<!-- 현재 접속자의 부서 -->
	<input type="hidden" id="UserName" value="" />	<!-- 현재 접속자의 이름 -->
	<input type="hidden" id="OwnerCode" name="ownerCode" value="" />
	
	<input type="hidden" name="imageCnt" value="0" />			<!-- imageCnt를 별도로 관리할 필요가 있는지 확인 필요 -->
	
	<input type="hidden" id="Version" name="version" value="0" />
	<input type="hidden" id="Seq" name="seq" value="0" />		<!-- 답글일경우 원본글의 MessageID를 설정 -->
	<input type="hidden" id="Step" name="step" value="0" />		<!-- 답글 표시 순서 -->
	<input type="hidden" id="Depth" name="depth" value="0" />	<!-- 답글 표시 깊이, 답글의 답글, 등을 표시 할때  -->
	<input type="hidden" id="IsPopup" name="isPopup" value="N" />	<!-- 팝업공지 사용여부, 현재는 N -->
	<input type="hidden" id="IsTop" name="isTop" value="N" />		<!-- 상단공지 사용 여부 -->
	<input type="hidden" id="IsApproval" name="isApproval" value="N" /> <!-- 승인프로세스 사용여부 -->
	<input type="hidden" id="IsUserForm" name="isUserForm" value="N" />	<!-- 사용자 정의 필드 사용 여부 -->
	<input type="hidden" id="UseRSS" name="useRSS" value="N" />
</form>

<script type="text/javascript">
var mode = CFN_GetQueryString("mode");			//'create', 'reply', 'update', 'revision', 'migrate'+
var bizSection = CFN_GetQueryString("CLBIZ");	//CHECK: 팝업 혹은 문서이관시 문서 타입 변경용으로 요청시 parameter로 설정된 bizSection을 사용한다.
var version = CFN_GetQueryString("version");
var folderID = CFN_GetQueryString("folderID") == 'undefined'? "" : CFN_GetQueryString("folderID");	//게시판 선택후 작성버튼을 눌렀을 경우의 folderID
var menuID = menuCode!=""?Common.getBaseConfig(menuCode):CFN_GetQueryString("menuID");
var messageID = CFN_GetQueryString("messageID");
var communityID = CFN_GetQueryString("communityId") == 'undefined'? "" : CFN_GetQueryString("communityId");
multiFolderType = CFN_GetQueryString("multiFolderType") == 'undefined'? "" : CFN_GetQueryString("multiFolderType"); // 다중분류 여부 - ORIGIN: 원본 문서, SUB: 다중분류 문서

var g_aclList = "";		//권한 설정 ACL List, 추후 팝업호출시 해당 폴더의 권한 정보 조회

function cancelMessage(){
	//뒤로가기 사용시 대메뉴를 통해 접근한 페이지의 이전 페이지로 이동됨
	multiFolderType = '';
	board.goFolderContents(g_urlHistory);	//마지막 페이지로 이동하도록
}

function OrgMapLayerPopup_Owner(){
	//CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=ownerAdd_CallBack&type=A1","<spring:message code='Cache.lbl_DeptOrgMap'/>",520,580,"");
	Common.open("","orgmap_pop","<spring:message code='Cache.lbl_DeptOrgMap'/>","/covicore/control/goOrgChart.do?callBackFunc=ownerAdd_CallBack&type=A1","520px","580px","iframe",true,null,null,true);
}

//소유자 지정
function ownerAdd_CallBack(orgData){
	var ownerJSON =  $.parseJSON(orgData);
	var ownerCode = "";
	var ownerName = "";
	
	$(ownerJSON.item).each(function (i, item) {
  		sObjectType = item.itemType;
  		if(sObjectType.toUpperCase() == "USER"){ //사용자
  			ownerCode = item.UserCode;
  			ownerName = CFN_GetDicInfo(item.DN);
  			if(ownerCode != ""){
  				var ownerHTML = $(String.format('<div class="ui-autocomplete-multiselect-item" data-json="{&quot;label&quot;:&quot;{0}&quot;,&quot;value&quot;:&quot;{0}&quot;}" data-value="{0}"/>', ownerName));
  	  			if($("#OwnerName").parent().children('.ui-autocomplete-multiselect-item').length > 0){
	  	  			$("#OwnerName").val("");
  	  				Common.Warning("<spring:message code='Cache.msg_OrgMap05'/>");/* 선택목록의 임직원(사용자) / 부서(그룹) 항목은 1개만 추가 할 수 있습니다. */
	  				return false;
  	  			}else{
	  	  			ownerHTML.append(ownerName, $('<span class="ui-icon ui-icon-close" />').click(function(){
	  	  		        var item = $(this).parent();
	  	  		        item.remove();
	  	  		    }));
  	  				$('#OwnerName').before(ownerHTML);
  	  				$("#OwnerCode").val(ownerCode);
  	  			}
  			}else{
  				$("#OwnerName").val("");
  			}
  		}
 	});
}

//소유자 AutoComplete 공통 컨트롤 사용
function setOwnerInput(){
	// 사용자 값 조회
	coviCtrl.setCustomAjaxAutoTags(
		'OwnerName', //타겟
		'/covicore/control/getAllUserAutoTagList.do', //url 
		{
			labelKey : 'UserName',
			valueKey : 'UserCode',
			minLength : 1,
			useEnter : true,
			multiselect : true,
			select : function(event, ui) {
				var orgMapDivEl = $("<div/>", {'class' : 'ui-autocomplete-multiselect-item', attr : {label : '', value : ''}})
				.append($("<span/>", {'class' : 'ui-icon ui-icon-close'}));
	    		var id = $(document.activeElement).attr('id');
	    		var item = ui.item;
	    		var cloned = orgMapDivEl.clone();
				cloned.attr({'label': item.label,'value': item.label});
				cloned.find('.ui-icon-close').before(item.label);

				$('#' + id).before(cloned);
		    	ui.item.value = ''; // 선택 후 input에 value값이 들어가는 문제가 있어 빈값 처리
		    	$('#OwnerCode').val(item.UserCode);
	    	}
		}
	);

	//소유자 한명이상 설정 불가능 하도록 이벤트 추가
	$("#OwnerName").on("keypress keydown keyup focusout", function(e){
		if($("#OwnerName").parent().children('.ui-autocomplete-multiselect-item').length > 0){
			$("#OwnerName").val("");
			return false;
		}
	});
};

function setKeepYearSelect(){
	var targetObj = $("#selectKeepyear");
	var keepYears = Common.getBaseCode("SAVE_TERM");
	
	targetObj.empty();
	targetObj.html(coviCtrl.makeSelectData(Common.getBaseCode("SAVE_TERM")["CacheData"], {hasAll:false,id:"selectKeepyear"}, Common.getSession('lang')));
	targetObj.find("option[data-reserved1=selected]").attr("selected", true);
}

//게시 작성, 임시저장, 수정 
function setMessage( pMessageState ){	//C: 등록 (Default), T: 임시저장, 그외의 코드값은 해당페이지에서 관리 하지 않음
	if(board.checkMessageValidation()){
		//Multipart 업로드를 위한 formdata객체 사용 
		var formData = new FormData();
		formData.append("mode", mode);
		formData.append("bizSection", bizSection);
	  	
	    board.setDataByBizSection(bizSection, formData);	//통합게시, 문서관리별 작성,수정시 설정한 데이터 formData에 추가
		
		if(mode == "update" && g_messageConfig.MsgState !== "D"){	//mode: 'create', 'reply', 'update'
			url = "/groupware/board/updateMessage.do";

			formData.append("messageID", messageID);
		} else {	//추가, 답글
			url = "/groupware/board/createMessage.do";

			if(mode != "reply" && $("#IsApproval").val() == "Y" && pMessageState != "T"){	//답글은 승인 프로세스를 사용하지 않음
				//사용자 지정 승인 프로세스 추가시 
// 				formData.append("processActivityList", encodeURIComponent(board.setUserDefFieldData()));
				pMessageState = "R";	//승인 요청 상태 
			} 
			formData.append("isAutoDocNumber", $("#UseAutoDocNumber").val());
		    formData.append("msgState", pMessageState);
		}
	    
		formData.append("multiFolderID", $("#hiddenMultiFolderID").val()); // 다중분류
	    
		$.ajax({
	    	type:"POST",
	    	url: url,
	    	data: formData,
	    	dataType : 'json',
	        processData : false,
	        contentType : false,
	    	success:function(data){
	    		if(data.status=='SUCCESS'){
	    			/*저장되었습니다.*/
		    		Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){
		    			board.goFolderContents(g_urlHistory);
		    		});
	    		}else{
	    			Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
	    		}
	    	}, 
	  		error:function(error){
	  			Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
	  		}
	    });
	}
}

//CHECK: 개정용 메소드 분리
function setMessageRevision(){
	if(board.checkMessageValidation()){
		//Multipart 업로드를 위한 formdata객체 사용 
		var formData = new FormData();
		formData.append("mode", "revision");	//Revision은 별도 함수로 분리해놓고 진행
		formData.append("bizSection", bizSection);
		formData.append("messageID", messageID);

	    board.setDataByBizSection(bizSection, formData);		//통합게시, 문서관리별 작성,수정시 설정한 데이터 formData에 추가

	    var messageState = "C";	//등록 상태
	    if($("#IsApproval").val() == "Y"){
			//사용자 지정 승인 프로세스 추가시 
			//formData.append("processActivityList", encodeURIComponent(board.setUserDefFieldData()));
			messageState = "R";	//승인 요청 상태 
		}
		formData.append("msgState", messageState);
		formData.append("multiFolderID", $("#hiddenMultiFolderID").val()); // 다중분류
	
		url = "/groupware/board/createMessage.do";
		
		$.ajax({
	    	type:"POST",
	    	url: url,
	    	data: formData,
	    	dataType : 'json',
	        processData : false,
	        contentType : false,
	    	success:function(data){
	    		if(data.status=='SUCCESS'){
	    			/*저장되었습니다.*/
		    		Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){
		    			board.goFolderContents(g_urlHistory);
		    		});
	    		}else{
	    			Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
	    		}
	    	}, 
	  		error:function(error){
	  			Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
	  		}
	    });
	}
}

//상세 권한 설정 팝업
function goMessageAuthPopup(){
	//상세권한 설정
	Common.open("","messageAuth","<spring:message code='Cache.lbl_MessageDetailAuthSet' />","/groupware/board/goMessageAuthPopup.do?frangment=contents" ,"650px","525px","iframe",false,null,null,true);
}

//문서관리 내부 보존 기간 설정이 만료일로 자동 적용
function changeKeepYear( pObj ){
	var year = $(pObj).val()
	
	var date = new Date();
	if(year == "99"){
		date.setFullYear("9999");	
		date.setMonth("11");
		date.setDate("31");
	}else{
	    date.setFullYear(date.getFullYear()+parseInt(year));
	    date.setMonth(date.getMonth());
	    date.setDate(date.getDate());
	}
    $("#ExpiredDate").val(board.dateString(date).substring(0, 10));
}

function changeFolder(pFolderObj){
	$("#hiddenFolderID").val(pFolderObj.FolderID);
	
	if(mode == "update") {
		board.bindOptionControl(pFolderObj.FolderID, 'Y', 'Y');	
	} else {
		board.bindOptionControl(pFolderObj.FolderID, 'Y');
	}
	
	$("#UseAutoDocNumber").val(g_boardConfig.UseAutoDocNumber);
	$(".path").html(board.renderFolderPath());
}

//다중분류 선택
function addMultiFolder(pFolderObj){
	var multiFolderID = $("#hiddenMultiFolderID").val();
	var selFolderID = typeof pFolderObj != "object" ? pFolderObj : pFolderObj.FolderID;
	
	if(multiFolderID.indexOf(selFolderID) > -1
		|| Number($("#hiddenFolderID").val()) === Number(selFolderID)){
		Common.Warning("<spring:message code='Cache.msg_alreadyAddClass'/>"); // 이미 추가된 분류입니다.
		return false;
	}
	
	board.getBoardConfig(selFolderID);
	
	var folderPath = $("<div tag='"+selFolderID+"'></div>")
		.append(board.renderFolderPath())
		.append($("<a class='btnRemoveAuto'></a>")
		.click(function(){
			var fdid = $(this).closest("div").attr("tag");
			var hidMultiFdid = $("#hiddenMultiFolderID").val();
			
			$("#hiddenMultiFolderID").val(hidMultiFdid.replace(fdid + ";", ""));
			$(this).closest("div").remove();
			
			if($("#divMultiFolderPath div").length == 0) $("#divMultiFolderArea").hide();
	}));
	
	$("#divMultiFolderPath").append(folderPath);
	$("#hiddenMultiFolderID").val(selFolderID + ";" + multiFolderID);
	if($("#divMultiFolderPath div").length > 0) $("#divMultiFolderArea").show();
}

initContent();

function initContent(){
	//1. 작성자이름, 부서 정보 설정 및 에디터 불러오기
	g_editorBody = '';
	
	$("#UserName").val(sessionObj["UR_Name"]);
	$("#GroupName").val(sessionObj["GR_Name"]);
	$("#RegistDeptName").hide();

	board.setEditor();			//에디터
	setOwnerInput();			//소유자 autoComplete 바인드
	setKeepYearSelect();		//보존년한 selectbox 바인드
	
	//2. UI및 이벤트 설정
	board.bindEventByBizSection(bizSection);	//게시판, 문서관리별 이벤트 바인딩
	board.bindOptionControl(folderID, 'N');			//선택한 Folder의 환경설정 검색 
	$(".path").html(board.renderFolderPath());
	
	// 자동발번 사용 여부
	if(folderID && g_boardConfig.UseAutoDocNumber){
		$("#UseAutoDocNumber").val(g_boardConfig.UseAutoDocNumber);
	}
	
	//3. mode에 따른 옵션값 설정 추후 board.js에 추가 
	//'create', 'reply', 'update', 'revision'
	if(mode == 'create'){		
		//작성자 명, 부서명을 세션에서 가져온 사용자명으로 우선 설정
		$("#CreatorName").val($("#UserName").val());
		$("[name=btnUpdate], [name=btnRevision]").hide();	//수정, 개정 버튼 숨김

		//연결문서용 게시글 조회 팝업 이벤트 바인드
		$("#btnAddMessage").on('click', function(){
			board.searchMessagePopup('Link', 'Doc');
		});

		if(bizSection == "Doc"){	//문서관리의 경우 임시저장 버튼 숨김
			$("[name=btnTemp]").hide();
		}

	} else if(mode =='binder'){
		//작성자 명, 부서명을 세션에서 가져온 사용자명으로 우선 설정
		$("#CreatorName").val($("#UserName").val());
		$("[name=btnUpdate], [name=btnRevision]").hide();	//수정, 개정 버튼 숨김
		
		$("#spanLinkedHeader").text("<spring:message code='Cache.lbl_Binder'/>");	//바인더

		$("#btnAddMessage").on('click', function(){
			board.searchMessagePopup('Binder', 'Doc');
		});
	} else if(mode =='migrate'){
		$("#CreatorName").val($("#UserName").val());				//작성자 명, 부서명을 세션에서 가져온 사용자명으로 우선 설정
		$("[name=btnUpdate], [name=btnRevision], [name=btnTemp]").hide();				//임시저장, 수정, 개정 버튼 숨김
		
		board.selectMessageDetail("Write", bizSection, version, messageID, folderID);	//board_message 테이블기준 설정항목 조회

		$("#DocNumber").prop("disabled",false);
		changeKeepYear($("#selectKeepyear"));

	} else {	//mode: update
		if(!board.checkModifyAuth(bizSection, folderID, messageID, version)){
			Common.Warning("<spring:message code='Cache.msg_noModifyACL'/>", "Warning", function(answer){ // 수정 권한이 없습니다.
				if(answer){
					cancelMessage();
				}
			});
		}
		
		$("#hiddenFolderID").val(folderID);
		//$("#btnFolder").hide();															//수정시 게시판 변경 불가능
		board.selectMessageDetail("Write", bizSection, version, messageID, folderID);	//board_message 테이블기준 설정항목 조회
		
		// 다차원 분류에 속한 문서 수정 시
		if(g_messageConfig.MultiFolderIDs != null && g_messageConfig.MultiFolderIDs != ""){
			var multiFolderIDs = g_messageConfig.MultiFolderIDs.split(";");
			
			if(multiFolderType == "SUB"){
				folderID = g_messageConfig.FolderID;
				$("#hiddenFolderID").val(g_messageConfig.FolderID);
				$("#UseAutoDocNumber").val(g_boardConfig.UseAutoDocNumber);
				board.bindOptionControl(folderID, "Y");
				$(".path").html(board.renderFolderPath());
			}
			
			if(multiFolderIDs.length > 0){
				$.each(multiFolderIDs, function(idx, item){
					addMultiFolder(item);
				});
			}
		}
		
		board.renderMessageOptionWrite(bizSection, version, messageID, folderID);		//옵션별 설정, 표시항목 조회 (태그, 링크, 열람권한, 상세권한, 사용자정의 폼 조회 )
		
		if(g_messageConfig.IsCheckOut == "Y"){			//개정버튼
			$("[name=btnRevision]").show();
		}

		$("#btnAddMessage").on('click', function(){
			board.searchMessagePopup('Link', 'Doc');	//연결문서
		});
		
		//등록, 임시저장 버튼 숨김
		$("[name=btnCreate], [name=btnTemp]").hide();
		
		// 반려된 게시 재등록 시 버튼 처리
		if (g_messageConfig.MsgState === "D") {
			$("[name=btnUpdate]").hide();
			$("[name=btnRevision]").hide();
			$("[name=btnCreate]").show();
		}
	}

	//분류 선택 게시판 트리메뉴 팝업 호출 
	$("#btnFolder, #btnMultiFolder").on("click",function(e){
		var selId = $(e.target).attr("id");
		
		if(selId == "btnMultiFolder"){
			parent._CallBackMethod = addMultiFolder;
		}else{
			parent._CallBackMethod = changeFolder;
		}
		
		var popupTitle = ""
		if (bizSection == "Doc") {
			popupTitle = "<spring:message code='Cache.lbl_apv_DocboxFolder'/>";
		} else {
			popupTitle= "<spring:message code='Cache.lbl_SelectBoard'/>";
		}
		
		if(mode == "update" && selId == "btnFolder") {
			parent.Common.open("", "boardTreePopup", popupTitle, "/groupware/board/goSearchBoardTreePopup.do?bizSection="+bizSection, "340px", "500px", "iframe", true, null, null, true);
		} else { 
			// 다중분류 문서함 트리 호출
			if(bizSection == "Doc" && selId == "btnMultiFolder" && Common.getBaseConfig("useDocMultiCategory") == "Y") {
				parent.Common.open("", "boardTreePopup", popupTitle, "/groupware/board/goSearchBoardTreePopup.do?bizSection="+bizSection+"&docMultiFolder=Y", "340px", "500px", "iframe", true, null, null, true);	
			} else {
				parent.Common.open("", "boardTreePopup", popupTitle, "/groupware/board/goSearchBoardTreePopup.do?bizSection="+bizSection, "340px", "500px", "iframe", true, null, null, true);	
			}
		}
	});
	
	if(Common.getBaseConfig("useDocMultiCategoryBtn") == "N") {
		$("#btnMultiFolder").hide();
	} else {
		$("#btnMultiFolder").show();
	}
}

</script>
