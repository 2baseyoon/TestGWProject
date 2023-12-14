<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil,egovframework.coviframework.util.RedisDataUtil,egovframework.baseframework.util.SessionHelper"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<jsp:include page="/WEB-INF/views/cmmn/BoardConfigInclude.jsp"></jsp:include>
<% 
	String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path");
%>
<!-- 컨텐츠앱 추가 -->
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/contentsApp/resources/css/contentsApp.css">
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/covicore/resources/css/covision/Controls.css">
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/collaboration/resources/css/collaboration.css<%=resourceVersion%>">	
<link rel="stylesheet" id="cCss" type="text/css" /> 
<link rel="stylesheet" id="cthemeCss" type="text/css" /> 

<style type="text/css">
	table {
	    border-collapse: collapse;
	}
	
	#con_acl .authPermissions table tr td:nth-child(11) { 
		border-right: 1px dashed #ddd;
	}

	.div_wrap {
		border:1px solid #d9d9d9; 
		margin:10px 0px 15px 0px; 
		padding:9px;
	}
	.btn_x {
		background:url(/HtmlSite/smarts4j_n/covicore/resources/images/covision/ico_x.gif) no-repeat center 5px;
		padding-right: 10px;
	}
	
	.right_arrow{
		background: url(/HtmlSite/smarts4j_n/covicore/resources/images/covision/tlink_tit.gif) no-repeat center 5px;
    	padding-right: 10px;
	}
	
	#userDefFieldGrid td {
	    font-size: 12px;
	}
	
	.AXFormTable {
		width:100%;
		table-layout:fixed;
		border-collapse:collapse;
		border-top:1px solid #222222;
		border-bottom:0 none;
		font-size:12px;
		box-shadow: 0px 0px 0px #eee;
	}
	
	.cateOperator {
		margin-top: 5px;
	}
</style>

<script type="text/javascript" src="/groupware/resources/script/admin/boardAdmin.js<%=resourceVersion%>"></script>
<script  type="text/javascript">
// 기본설정 - 다국어 레이어팝업
var folderTypeList = ${folderTypeList};
var securityLevelList = ${securityLevelList};
var bizSection = "${bizSection}";
var mode = "${mode}";
var folderID = "${folderID}"; // Create모드: 상위 폴더의 ID, Edit모드: 현재 선택된 게시판의 FolderID
var menuID = "${menuID}";
var communityID = "${CommunityID}";
var domainID = "${domainID}";

var userDefFieldGrid = new coviGrid();
var lang = Common.getSession("lang");

//에디터 설정 변수
var g_editorTollBar = '0';	// 0, 1, 2 
var gx_id = 'xfe';
var g_id = 'tagfe';
var g_heigth = '400px';
var g_aclList = ""; 		// 권한 설정 ACL List, 추후 팝업호출시 해당 폴더의 권한 정보 조회
var g_optionIndex = "";		// 사용자 정의 필드 옵션을 다국어 처리하기 위한 전역 변수
var g_isRoot = false;
var g_isInherited = false;	// 권한 상속 여부
var g_hasChild = false;		// 자식 객체 존재 여부
 
$(document).ready(function (){
	//개별호출-일괄호출
	Common.getDicList(["lbl_PriorityOrder","lbl_BoardNm","lbl_FolderType","lbl_DeleteDate","lbl_Restore","lbl_Register","lbl_Display","lbl_selUse","lbl_RegistrationDate",
	                   "lbl_no2", "lbl_BoardCate2", "lbl_subject", "lbl_State2", "lbl_Register", "lbl_attach", "lbl_RegistDate", "lbl_ExpireDate",
	                   "lbl_FieldNm","lbl_FieldType","lbl_Limit2","lbl_FieldSize","lbl_DisplayList","lbl_ListSearchItem","lbl_surveyIsRequire",
	                   "lbl_BoardCate2", "lbl_SingoUserNm", "lbl_ReportDate","lbl_TrialContent", "lbl_RegistDate","lbl_attach","lbl_LockDate",
	                   "lbl_State2","lbl_Requester","lbl_RequestDate","lbl_RequestContent","lbl_ProcessContents","lbl_State",
	                   "lbl_writer","lbl_PersonNo", "lbl_CreateDates","lbl_ReadCount","lbl_AnswerNo",
	                   "lbl_Approval","lbl_Rejected","lbl_Lock","lbl_RegistReq","lbl_TempSave","lbl_delete"]);
	
	setSelect();			//폴더 타입, 카테고리 조회
	
	if(mode == "create"){
		initCreateMode();	//새로만들기/추가의 경우 화면 설정
	} else {			
		initEditMode();		//속성/수정의 경우 화면설정
	}
	
	//form 내부에 element를 element의 name으로 자동 맵핑
	//탭 클릭 이벤트 설정
	$(".AXTabsTray a").on("click", function(){ 
		boardAdmin.clickTab(this); 
	});
	
	//만료일 체크박스 선택시 0,90 기본값 설정
	$("#chkUseExpiredDate").on("click", function(){ 
		//boardAdmin.clickUseExpireDate(); 
	});
	
	// 만료일자 일괄 수정 (만료되지 않은 게시글)
	$("#updateExpiredDayBtn").on("click", function(){	/*만료되지 않은 게시물들의 만료일이 일괄 변경됩니다. 변경하시겠습니까?*/
		var sExpireDay = $("#txtExpireDay").val();
		if(sExpireDay == 0){
			sExpireDay = Common.getDic("lbl_permanence");
		}
		Common.Confirm(Common.getDic("msg_board_updateExpiredConfirm").replace("{0}", sExpireDay), "Confirmation Dialog", function(result){
			if(result){
				$.ajax({
			    	type:"POST",
			    	url: "/groupware/admin/updateExpiredDay.do",
			    	dataType : 'json',
			    	data: {
			    		"expireDay" : $("#txtExpireDay").val(),
			    		"folderID": folderID
			    	},
			    	success:function(data){
			    		if(data.status=='SUCCESS'){
			    			Common.Inform("<spring:message code='Cache.msg_Changed'/>");
			    		}else{
			    			Common.Warning("<spring:message code='Cache.msg_ErrorOccurred'/>");
			    		}
			    	}, 
			  		error:function(error){
			  			CFN_ErrorAjax("/groupware/admin/updateExpiredDay.do", response, status, error);
			  		}			    	
			    });
			}
		});
	});

	//만족도 체크박스 이벤트 선택시 원본글,답글 체크박스 표시/숨김처리
	$("#chkUseSatisfaction").on("click", function(){ 
		boardAdmin.enDisableSatisfactionField(this) 
	});
	
	//만족도 - 원본글, 답글 만족도 체크박스 이벤트 
	$("[group=chkUseSatisfaction]").on("click", function(){ 
		boardAdmin.checkOneByUseSatisfactionBox(this) 
	});

	$("#searchTab_ExtOption [id^=chk]").on("click", function(){
		boardAdmin.enDisableExtOptionField();
	});
	
	$("#folderName").on("change", function(){
		var sDictionaryInfo = '';
		switch (Common.getSession("lang").toUpperCase()) {
	        case "KO": sDictionaryInfo = this.value + ";;;;;;;;;"; break;
	        case "EN": sDictionaryInfo = ";" + this.value + ";;;;;;;;"; break;
	        case "JA": sDictionaryInfo = ";;" + this.value + ";;;;;;;"; break;
	        case "ZH": sDictionaryInfo = ";;;" + this.value + ";;;;;;"; break;
	        case "E1": sDictionaryInfo = ";;;;" + this.value + ";;;;;"; break;
	        case "E2": sDictionaryInfo = ";;;;;" + this.value + ";;;;"; break;
	        case "E3": sDictionaryInfo = ";;;;;;" + this.value + ";;;"; break;
	        case "E4": sDictionaryInfo = ";;;;;;;" + this.value + ";;"; break;
	        case "E5": sDictionaryInfo = ";;;;;;;;" + this.value + ";"; break;
	        case "E6": sDictionaryInfo = ";;;;;;;;;" + this.value; break;
	    }
	    document.getElementById("hidFolderNameDicInfo").value = sDictionaryInfo
	});
	
	if (parent && parent.communityID != '' && parent.communityCssPath != '' && parent.communityTheme != ''){
		$("#cCss").attr("href",parent.communityCssPath + "/community/resources/css/community.css");
		$("#cthemeCss").attr("href",parent.communityCssPath + "/covicore/resources/css/theme/community/"+parent.communityTheme+".css");
	} else {
		$("#cCss, #cthemeCss").remove();
	}
	
	// 업로드 가능 확장자 전체 체크/해제
	$("#chkAllFileExtention").on("change", function(){
		var chkAllFileExtention = $(this).is(':checked');
		
		if(chkAllFileExtention) {
			$("#enableFileExtention input[type=checkbox]").prop('checked', true);			
		} else {
			$("#enableFileExtention input[type=checkbox]").prop('checked', false);
		}
	});
	
	// 소분류 카테고리
	$("#selectSmallCategory").on("change", function(){
		var smallCategoryManagerCode = $("#selectSmallCategory").val() ? $("#selectSmallCategory").val().split("|")[2] : "";
		selectCategoryManagerName(smallCategoryManagerCode, "hidSmallCategoryManagerName");
		$("#hidSmallCategoryManagerCode").val(smallCategoryManagerCode);
	});
});

function setSelect(){
	//기본설정탭 - 메뉴
	if(communityID != null && communityID != ''){
		$("#selectMenuID").coviCtrl(
			"setSelectOption", 
			"/groupware/admin/selectMenuList.do", 
			{communityID: communityID, bizSection: bizSection}, 
			"<spring:message code='Cache.lbl_selectMenu'/>", // 메뉴 선택
			""
		).val(communityID);
	}else{
		$("#selectMenuID").coviCtrl(
			"setSelectOption", 
			"/groupware/admin/selectMenuList.do", 
			{"domainID": domainID, "bizSection": bizSection}, 
			"<spring:message code='Cache.lbl_selectMenu'/>", // 메뉴 선택
			""
		).val(menuID);
	}	

	//기본설정탭 - 폴더타입
	$("#folderType").bindSelect({
		reserveKeys: {
			optionValue: "optionValue",
			optionText: "optionText"
		},
		options:folderTypeList
	});
	
	//기본설정탭 - 메시지보안, 표시/사용/등록알림/공유/모바일지원/연결URL/상속여부
	$("select[id^=selectIs]").bindSelect({
		reserveKeys: {
			optionValue: "optionValue",
			optionText: "optionText"
		},
		options:[
			{"optionText":"<spring:message code='Cache.lbl_Use'/>", "optionValue":"Y"}, 
			{"optionText":"<spring:message code='Cache.lbl_NotUse'/>", "optionValue":"N"}
		]
	});

	//기본설정탭 - 보안등급
	$("#securityLevel").bindSelect({
		reserveKeys: {
            options: "list",
            optionValue: "optionValue",
            optionText: "optionText"
        },
        options: securityLevelList
	});
}

//새로만들기, 추가 버튼으로 팝업 호출시
function initCreateMode(){
	if (folderID != ""){
		$("#folderType").val("Folder");
	}
	
	var default_security = Common.getBaseConfig('DefaultSecurityLevel',domainID);
	$("#securityLevel").bindSelectSetValue(default_security);
	$("#selectIsMsgSecurity, #selectIsShared, #selectIsURL, #selectIsAdminNotice, #selectIsMobileSupport").bindSelectSetValue("N");

	//$("#authSettingTab, #basicOptionTab, #extOptionTab").hide();	//기본설정 외의 다른 탭 숨김
	
	$("#btn_add").show();
	$("#btn_modify").hide();
	
	// 폴더 타입 변경 이벤트 바인딩
	$("#folderType").on("change", function(){
		boardAdmin.changeFolderType(this);
		boardAdmin.changeFolderTypeSetDefault();
	});
	
	$("#userName").val(Common.getSession("USERNAME"));
	$("#ownerCode").val(Common.getSession("USERID") + ";");

	$("#btn_add").show();
	$("#btn_modify").hide();
}

//속성, 폴더 Grid에서 게시판명 선택으로 팝업 호출시
function initEditMode(){	
	/*
	if(bizSection == "Board"){
		$("#basicOptionTab").show();	//기본옵션 탭 표시
		$("#searchTab_ExtOption").find("[type=Doc]").hide();
		$("#searchTab_ExtOption").find("[type=Board]").show();
	} else {
		$("#basicOptionTab").hide();	//기본옵션 탭 숨김
		$("#searchTab_ExtOption").find("[type=Board]").hide();
		$("#searchTab_ExtOption").find("[type=Doc]").show();
	}
	*/
	
	$("#authSettingTab").show();
	$("#extOptionTab").show();		//확장 옵션 탭 표시
	
	$("#btn_add").hide();
	$("#btn_modify").show();
	
	selectBoardConfig();				// 폴더 옵션 조회	
	renderACL($("#folderType").val()); 	// 권한 설정 탭 내부 오브젝트 표시
	checkIsInherit();					// 권한 아이템 조회
	
	if($("#folderType").val() != "QuickComment"){
		$("#con_acl .authPermissions table tr td:nth-child(4)").css("border-right", "");
		$("#con_acl .authPermissions table tr td:nth-child(5)").css("border-right", "");
		$("#con_acl .authPermissions table tr td:nth-child(11)").css("border-right", "1px dashed #ddd");
	} else {
		$("#con_acl .authPermissions table tr td:nth-child(4)").css("border-right", "1px dashed #ddd");
		$("#con_acl .authPermissions table tr td:nth-child(5)").css("border-right", "1px dashed #ddd");
		$("#con_acl .authPermissions table tr td:nth-child(11)").css("border-right", "");
	}
	
	boardAdmin.enDisableExtOptionField();
	boardAdmin.disabledBoardOptByFolderType($("#folderType"));
	
	//폴더 타입 변경 이벤트 바인딩
	$("#folderType").on("change", function(){
		boardAdmin.changeFolderType(this);
		boardAdmin.changeFolderTypeSetDefault();		
		setEnableFileExtention($(this).val());
		
		if(mode === "edit" && $(this).val() === "Doc"){
			$('#basicOptionTab').attr('disabled', false).show();
		}
		
		// 폴더 타입에 따른 권한 설정 값 변경 (한줄 게시판일 경우 조회권한만 설정할 수 있도록 한다)
		renderACL($(this).val());
		checkIsInherit();
		
		if($(this).val() != "QuickComment"){
			$("#con_acl .authPermissions table tr td:nth-child(4)").css("border-right", "");
			$("#con_acl .authPermissions table tr td:nth-child(5)").css("border-right", "");
			$("#con_acl .authPermissions table tr td:nth-child(11)").css("border-right", "1px dashed #ddd");
		} else {
			$("#con_acl .authPermissions table tr td:nth-child(4)").css("border-right", "1px dashed #ddd");
			$("#con_acl .authPermissions table tr td:nth-child(5)").css("border-right", "1px dashed #ddd");
			$("#con_acl .authPermissions table tr td:nth-child(11)").css("border-right", "");
		}
	});
	
	// 하위 폴더의 권한에 해당 폴더의 권한이 일괄적 적용
	$("#checkIsSubfolderInherited").off("change").on("change", function(){
        if($("#checkIsSubfolderInherited").is(":checked")){
        	Common.Inform("<spring:message code='Cache.msg_useAuthInherited'/>"); // 권한 상속 사용 시 하위 폴더의 권한에 해당 폴더의 권한이 일괄적으로 저장됩니다.
        }
    });
	
	//최상위 폴더를 수정하는 팝업일경우 변경 불가능하게 Disabled 처리 
	if($("#folderType").val() == "Root"){
		$("#folderType").bindSelectDisabled(true);
		$("#basicOptionTab").hide();
		$("#extOptionTab").hide();
	} else if($("#folderType").val() == "Folder"){
		$("#basicOptionTab").hide();
		$("#extOptionTab").hide();
	}else{
		$("#extOptionTab").show(); // 확장 옵션 탭 표시
	}
	
	// 최상위 폴더 또는 폴더일 경우 등록알림, 등록알림 수신자, 등록알림 제외자 숨김
	/*
	if($("#folderType").val() == "Root" || $("#folderType").val() == "DocRoot" || $("#folderType").val() == "Folder"){
		$("#regNotifyTr").hide();
		$("#receiverTr").hide();
		$("#excepterTr").hide();
	} else {
		$("#regNotifyTr").show();
		$("#receiverTr").show();
		$("#excepterTr").show();
		$("#selectIsAdminNotice").css("visibility", "visible");
	}
	*/
}

//상위권한 상속일때는 
var checkIsInherit = function(){
	$("#con_acl_hTbdPermissions").html("");
	g_aclList = "";
	
	//권한 표시항목 및 aclList변수 초기화
	selectBoardACLData();
}

/********************************************************************************************************/

//권한 설정 탭 내부 UI 표시
function renderACL(folderType){
	var option = {
		lang : lang, 
		hasItem : 'false', 
		allowedACL : (folderType == "QuickComment") ? "_____V_" : "",
		initialACL : (folderType == "QuickComment") ? "_____V_" : "",
		orgMapCallback : 'orgCallback',
		aclCallback : 'aclCallback',
		communityId : communityID,
		orgGroupType : "Basic|Board",
		useBoardInherited : Common.getBaseConfig("useBoardInherited"),
		systemType : "Board"
	};
	
	if (!g_isRoot) {
		option["useInherited"] = true;
		option["inheritedFunc"] = "selectInheritedACL";
	}
	
	coviACL = new CoviACL(option);
	coviACL.render('con_acl');
	
	$("#con_acl_divControls [type=button]").hide();		//사용하지 않는 버튼 숨김처리
}

//조직도 Callback
var orgCallback = function(data){
	var orgJson = $.parseJSON(data);
	var bCheck = false;
	var sObjectType = "";
	var sObjectType_A = "";
	var sObjectTypeText = "";
	var sCode = "";
	var sDNCode = "";
	var sDisplayName = "";
	
	// 모든 하이라이트 해제
	$('.aclSubject').css("background-color", "inherit");
	$('.aclSubject').removeAttr("data-clicked");
	
	$.each(orgJson.item, function(i, item){
		sObjectType = item.itemType;
		
		if(sObjectType.toUpperCase() == "USER"){ //사용자
			sObjectTypeText = "사용자";
			sObjectType_A = "UR";
			sCode = item.AN;		//UR_Code
			sDNCode = item.ETID; 	//DN_Code
			sDisplayName = CFN_GetDicInfo(item.DN, lang);
		}else{ //그룹
			switch(item.GroupType.toUpperCase()){
	  			case "AUTHORITY":
	                sObjectTypeText = "권한";
	                sObjectType_A = "GR";
	                break;
	  			case "COMMUNITY":
	                sObjectTypeText = "커뮤니티";
	                sObjectType_A = "GR";
	                break;
	  			case "COMPANY":
	                 sObjectTypeText = "회사";
	                 sObjectType_A = "CM";
	                 break;
	             case "JOBLEVEL":
	                 sObjectTypeText = "직급";
	                 sObjectType_A = "GR";
	                 break;
	             case "JOBPOSITION":
	                 sObjectTypeText = "직위";
	                 sObjectType_A = "GR";
	                 break;
	             case "JOBTITLE":
	                 sObjectTypeText = "직책";
	                 sObjectType_A = "GR";
	                 break;
	             case "MANAGE":
	                 sObjectTypeText = "관리";
	                 sObjectType_A = "GR";
	                 break;
	             case "OFFICER":
	                 sObjectTypeText = "임원";
	                 sObjectType_A = "GR";
	                 break;
	             case "DEPT":
	                 sObjectTypeText = "부서";
	                 sObjectType_A = "GR";
	                 break;
	             default:
	                 sObjectTypeText = "그룹";
	                 sObjectType_A = "GR";
	                 break;
	     	}
			
			sCode = item.AN;
			sDisplayName = CFN_GetDicInfo(item.GroupName);
			sDNCode = item.DN_Code;
		}
		
		bCheck = false;
		
		$('#con_acl_hTbdPermissions').find('tr').each(function(){
			if (($(this).attr("objecttype_a").toUpperCase() == sObjectType_A.toUpperCase()) && ($(this).attr("objectcode") == sCode)) {
				bCheck = true;
			}
		});
		
		if(!bCheck){
			var jsonData = JSON.stringify({"item": item});
			coviACL.addSubjectRow(jsonData);
		}else{
			Common.Error("<spring:message code='Cache.ACC_msg_existItem'/>"); // 이미 추가된 항목입니다.
		}
	});
	
	setAuthSetting(orgJson.item);
}

//화면에 설정된 ACL 데이터 출력
var aclCallback = function(data){
	g_aclList = data;
}

function selectInheritedACL(){
	$.ajax({
		url: "/groupware/admin/selectBoardACLData.do",
		type: "POST",
		async: false,
		data: {
			  "objectID": $("#hidMemberOf").val()
			, "objectType": "FD"
		},
		success: function(res){
			if (res.status === "SUCCESS") {
				var aclList = [];
				var exAclList = JSON.parse(coviACL_getACLData("con_acl"));
				
				$(res.data).each(function(idx, item){
					var exist = exAclList.map(function(exAcl){
						return exAcl.SubjectCode === item.SubjectCode;
					});
					
					// 있는 경우 상속 받은 권한으로 덮어쓴다
					if (exist.includes(true)) {
						// con_acl
						$(".aclSubject").each(function(i, tr) {							
							if($(tr).attr("objectcode") == item.SubjectCode) {
								coviACL_setDelInfo($(tr));
								$(tr).remove();
							}
						});
						
						coviACL_deleteACLBySubject("con_acl", item.SubjectCode);
					} 
					
					var acl = {
						  "AN": item.SubjectCode
						, "DN_Code": item.CompanyCode
						, "AclList": item.AclList
						, "Security": item.Security
						, "Create": item.Create
						, "Delete": item.Delete
						, "Modify": item.Modify
						, "Execute": item.Execute
						, "View": item.View
						, "Read": item.Read
						, "IsSubInclude" : item.IsSubInclude
					};
					
					if (item.SubjectType === "UR") {
						acl["itemType"] = "User";
						acl["DN"] = item.MultiSubjectName;
					} else {
						acl["itemType"] = "Group";
						acl["GroupName"] = item.MultiSubjectName;
						acl["GroupType"] = item.GroupType;
					}
					
					aclList.push(acl);
				});
				
				var jsonData = {"item": aclList, "isInHerited": true, "inheritedObjectID": $("#hidMemberOf").val()};
				
				// 모든 하이라이트 해제
				$('.aclSubject').css("background-color", "inherit");
				$('.aclSubject').removeAttr("data-clicked");
				
				coviACL.addSubjectRow(JSON.stringify(jsonData));
				setAuthSetting(jsonData.item);
			}
		},
		error: function(error){
			CFN_ErrorAjax("/groupware/admin/selectBoardACLData.do", response, status, error);
		}
	});
}
 
/*****************************************/

//기본옵션 사용 체크 관련
function UnCheckDefaultOption() { $('#chkUseBasicConfig').prop('checked', false); }

//폴더 타입별 board_config_default 테이블 데이터를 참조하여 조회
function selectDefaultConfig(){
	if ($('#chkUseBasicConfig').prop('checked')) {
		$.ajax({
	    	type:"POST",
	    	url: "/groupware/admin/selectDefaultConfig.do",
	    	dataType : 'json',
	    	data: {
				"folderType": $("#folderType").val()
		    },
	    	success:function(data){
	    		var config = data.config;
				for (var key in config) {
					if (/^Use/.test(key)) {
						config[key] == "Y" ? $("#chk"+key).prop('checked',true) : $("#chk"+key).prop('checked',false);
					} else if (/FileSize$/.test(key)) {
						$("#txt" + key).val(convertToMegaBytes(config[key]));					
					} else {
						$("#txt" + key).val(config[key]);
					}
				}
				
				// 기본값은 업로드 가능 확장자 전체 사용
				var chkAllFileExtention = $("#chkAllFileExtention").is(':checked');
				if(!chkAllFileExtention) {
					$("#chkAllFileExtention").trigger("click");			
				}
				
	    		//기본옵션 설정 탭에 존재하는 체크박스와 입력항목에만 클릭이벤트 할당
	    		$("#searchTab_BasicOption").find("input[id^=chkUse], input[id^=txt]").not("#chkUseBasicConfig").on("click", function() {
	    			UnCheckDefaultOption()
	    		});
	    	}, 
	  		error:function(error){
	  			CFN_ErrorAjax("/groupware/admin/selectDefaultConfig.do", response, status, error); 
	  		}
	    });
	}
}

//sys_object_folder, board_config 테이블 데이터를 참조하여 조회
function selectBoardConfig(){
	$.ajax({
    	type:"POST",
    	url: "/groupware/admin/selectBoardConfig.do",
    	dataType : 'json',
    	async: false,
    	data: {
			"folderID": folderID,
			"domainID": domainID
	    },
    	success:function(data){
	    	var config = data.config;
	    	
	    	g_isRoot = (config.FolderType === "Root");
			g_isInherited = config.IsInherited == "Y" ? true : false;
			g_hasChild = config.hasChild == "Y" ? true : false;
			
	    	$("#hidMemberOf").val(config.MemberOf);	    	
	    	$("#folderType").bindSelectSetValue(config.FolderType);
	    	
	    	// 폴더 타입에 따라 탭 표시여부 변경
	    	boardAdmin.changeFolderType($("#folderType"));
	    	
	    	//조회된 정보로 화면에 이벤트 셋팅
			for(var key in config) {
				//Use로 시작되는 항목은 전부 체크박스 처리
				if (/^Use/.test(key)) {
					config[key] == "Y" ? $("#chk" + key).prop('checked', true) : $("#chk" + key).prop('checked', false);
					$("#chk"+key).attr("data-value", config[key]);
				} else if (/^Is/.test(key)) {
					//is로 시작되는 항목은 전부 selectbox처리
					$("#select" + key).bindSelectSetValue(config[key] + "");
				} else if (/FileSize$/.test(key)) {
					//FileSize로 끝나는 항목 용량 변환 처리
					$("#txt" + key).val(config[key] != 0 ? convertToMegaBytes(config[key]) : convertToMegaBytes(config["FileSize"]));
				} else if (key == "EnableFileExtention"){
					// 업로드 가능한 파일 체크박스 표시
					setEnableFileExtention(config.FolderType);
					
					// 업로드 가능한 파일 체크박스 처리
					var enableFileExtentionArr = config[key] == "" ? Common.getBaseConfig('EnableFileExtention').split(",") : config[key].split(",");
					
					if(config.FolderType == "Album"){
						enableFileExtentionArr = config[key] == "" ? Common.getBaseConfig('EnableFileImageExtention').split(",") : config[key].split(",");
					}
					
					for(var i = 0; i < enableFileExtentionArr.length; i++) {
						$("#chk_" + enableFileExtentionArr[i]).prop('checked', true)
					}
					
					if($("#enableFileExtention input[type=checkbox]:not(:checked)").length == 0) {
						$("#chkAllFileExtention").prop('checked', true);
					}
				} else {
					$("#txt" + key).val(config[key]);
				}
			}
	    	
			$("#selectMenuID").val(config.MenuID).prop("disabled",true);
			
			// 최대 설정 가능한 용량 표시
			$(".maxFileSize").text(Common.getDic("lbl_MaxFileSize").replace("{0}", coviFile.convertFileSize(config["FileSize"])));
			
	    	//다국어 표시명이 없을 경우 분기 처리
    		var displayName = CFN_GetDicInfo(config.MultiDisplayName);	
    		if(displayName != "" && displayName != "undefined"){
        		$("#hidFolderNameDicInfo").val(config.MultiDisplayName);
        		$("#folderName").val(displayName);
        	} else {
        		$("#folderName").val(config.DisplayName);
            }    		
    		
    		$("#thRegistDate").text($("#thRegistDate").text() + Common.getSession("UR_TimeZoneDisplay"));    		
    		$("#ownerCode").val(config.OwnerCode);							//담당자ID
    		$("#registDate").text(CFN_TransLocalTime(config.CreateDate));
    		$("#registerName").text(CFN_GetDicInfo(config.RegisterName));	//등록자 이름
    		$("#description").val(config.Description);						//폴더설명
    		$("#securityLevel").bindSelectSetValue(config.SecurityLevel);	//보안등급
    		
    		if(config.OwnerCode != ""){ //담당자가 설정됐을 경우 담당자 이름 검색하여 표시
				selectBoardOwnerName(config.OwnerCode);
			}
    		
    		if(config.IsURL == "Y")	{ //연결URL 사용시 URL값 설정
				$("#linkURL").val(config.URL);
    		}
    		
			var msgTarget = config.MessageTarget;
    		try {
    			var receivers = msgTarget.Receivers;
        		$("#ReceiversName").val(receivers.name);
        		$("#ReceiversCode").val(receivers.code);
        		var excepters = msgTarget.Excepters;
        		$("#ExceptersName").val(excepters.name);
        		$("#ExceptersCode").val(excepters.code);
    		}
    		catch (ex){
    			coviCmn.traceLog(ex);
    		}    		
    		
    		/*
    		if(config.UseCategory == "Y"){		//확장옵션설정 탭: 카테고리 사용시 카테고리 Selectbox 조회
    			selectLargeCategoryList();
    			if($("#selectLargeCategory option").size()>0)
    			selectSmallCategoryList();
        	}

        	if(config.UseUserForm == "Y"){	//확장옵션설정 탭: 사용자정의필드 사용시 Grid 데이터 조회
        		setUserDefFieldGrid();
            }
        	*/
        	
        	if(config.IsMobileSupport != "Y") { //모바일지원 null 일경우 비사용 표시
        		$("#selectIsMobileSupport").bindSelectSetValue("N");	
        	}
        	
        	$("#folerPathName").text(config.FolderPathName.replaceAll(";","/"));
    	}, 
  		error:function(error){
  			CFN_ErrorAjax("/groupware/admin/selectBoardConfig.do", response, status, error); 
  		}
    });
}

//권한 조회
function selectBoardACLData(){
	$.ajax({
    	type:"POST",
    	url: "/groupware/admin/selectBoardACLData.do",
    	dataType: 'json',
    	async: false,
    	data: {
			  "objectID": folderID
			, "objectType": "FD"
	    },
    	success: function(res){
        	$("#con_acl_hTbdPermissions").html("");
    		coviACL.set(res.data);
    	}, 
  		error: function(error){
  			CFN_ErrorAjax("/groupware/admin/selectBoardACLData.do", response, status, error); 
  		}
    });
}

//담당자 이름 조회
function selectBoardOwnerName(pOwnerCode){
	$.ajax({
    	type:"POST",
    	url: "/groupware/admin/selectBoardOwnerName.do",
    	dataType : 'json',
    	async: false,
    	data: {
			"ownerCode": pOwnerCode
	    },
    	success:function(data){
	    	var ownerName = "";
	    	if(data.list != undefined){
	    		$(data.list).each(function (i, item) {
	    	  		ownerName += CFN_GetDicInfo(item.MultiDisplayName)+", ";
	    	 	});
	    		ownerName = ownerName.substring(0,ownerName.length-2);
	    	 	$("#userName").val(ownerName);
		    }
    	}, 
  		error:function(error){
  			CFN_ErrorAjax("/groupware/admin/selectBoardOwnerName.do", response, status, error); 
  		}
    });
}

//분류별 담당자 이름 조회
var selectCategoryManagerName = function(pOwnerCode, pCateOperator){	
	if(pOwnerCode == "") {
		$("#"+pCateOperator).val("");
	} else {
		$.ajax({
			type: "POST",
			url: "/groupware/admin/selectBoardOwnerName.do",
			dataType: 'json',
			async: false,
			data: {
				"ownerCode": pOwnerCode
			},
			success: function(data){
				if(data.status === "SUCCESS" && data.list){
					var ownerName = "";
					
					$(data.list).each(function(i, item){
						ownerName += CFN_GetDicInfo(item.MultiDisplayName) + ", ";
					});
					
					ownerName = ownerName.substring(0, ownerName.length-2);
					$("#"+pCateOperator).val(ownerName);
				}
			}, 
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/admin/selectBoardOwnerName.do", response, status, error);
			}
		});
	}
}

/* JS로 분리 예정  *************************************************************************************************/

//다국어 입력 팝업
function dictionaryLayerPopup(pMode, pOriginObj, pDicObj) { //pMode: create, edit
	var option = {
		lang : 'ko',
		hasTransBtn : 'true',
		allowedLang : 'ko,en,ja,zh',
		useShort : 'false',
		dicCallback : pMode + $(pOriginObj).attr("name") + "Dic_CallBack",
		popupTargetID : 'DictionaryPopup',
		init : pMode + $(pOriginObj).attr("name") + "DicInit"
	};

	var url = "";
	url += "/covicore/control/calldic.do?lang=" + option.lang;
	url += "&hasTransBtn=" + option.hasTransBtn;
	url += "&useShort=" + option.useShort;
	url += "&dicCallback=" + option.dicCallback;
	url += "&allowedLang=" + option.allowedLang;
	url += "&popupTargetID=" + option.popupTargetID;
	url += "&init=" + option.init;

	Common.open("", "DictionaryPopup", "<spring:message code='Cache.lbl_MultiLangSet'/>", url, "500px", "250px", "iframe", true, null, null, true);
}

function folderNameDicInit(){
	var value;
	
	if($('#hidFolderNameDicInfo').val() == ''){
		value = $('#folderName').val();
	}else{
		value = $('#hidFolderNameDicInfo').val();
	}
	
	return value;
}

function folderNameDic_CallBack(data) {
	$('#folderName').val(data.KoFull);
	$('#hidFolderNameDicInfo').val(coviDic.convertDic(data));
	Common.close("DictionaryPopup");
}

function fieldNameDic_CallBack(data) {
	if($("#fieldName").val() == ''){
		$("#fieldName").val(data.KoFull);
	}
	$("#hidFieldNameDicInfo").val(coviDic.convertDic(data));
}

function fieldNameDicInit(){
	return ($('#hidFieldNameDicInfo').val() != '') ?
			$('#hidFieldNameDicInfo').val() :
			$('#fieldName').val();
}

function bodyFormNameDic_CallBack(data) {
	if($("#txtBodyFormName").val() == ''){
		$("#txtBodyFormName").val(data.KoFull);
	}
	$("#hidBodyFormDicInfo").val(coviDic.convertDic(data));
}

function bodyFormNameDicInit(){
	var value;
	
	if($('#hidBodyFormDicInfo').val() == ''){
		value = $('#txtBodyFormName').val();
	}else{
		value = $('#hidBodyFormDicInfo').val();
	}
	
	return value;
}

function userDefFieldOptionDic_CallBack(data){
	if($("#fieldOption_" + g_optionIndex).val() == ''){
		$("#fieldOption_" + g_optionIndex).val(data.KoFull);
	}
	$("#hidFieldOption_" + g_optionIndex + "_DicInfo").val(coviDic.convertDic(data));
}

function userDefFieldOptionDicInit(){
	return ($('#hidFieldOption_'+ g_optionIndex+'_DicInfo').val() != '') ? 
			$('#hidFieldOption_'+ g_optionIndex+'_DicInfo').val() :
			$("#fieldOption_"+ g_optionIndex).val()	;
}

//사용자 정의 필드 전용 다국어 입력 팝업
function userDefFieldnDicLayerPopup(pIndex, pOriginObj, pDicObj) { //pMode: create, edit
	var value="";
	//IE 8 이하에서는 Object.keys 동작하지 않음
	if($(pDicObj).val() == ""){
		if($(pOriginObj).val() != ""){
			value = encodeURIComponent($(pOriginObj).val());
		}
	}else{
		value = encodeURIComponent($(pDicObj).val());
	}

	var option = {
		lang : 'ko',
		hasTransBtn : 'true',
		allowedLang : 'ko,en,ja,zh',
		useShort : 'false',
		dicCallback : "userDefFieldOptionDic_CallBack",
		popupTargetID : 'DictionaryPopup',
		init : "userDefFieldOptionDicInit"
	};

	var url = "";
	url += "/covicore/control/calldic.do?lang=" + option.lang;
	url += "&hasTransBtn=" + option.hasTransBtn;
	url += "&useShort=" + option.useShort;
	url += "&dicCallback=" + option.dicCallback;
	url += "&allowedLang=" + option.allowedLang;
	url += "&popupTargetID=" + option.popupTargetID;
	url += "&init=" + option.init;
	
	g_optionIndex = pIndex;
	
	Common.open("", "DictionaryPopup", "<spring:message code='Cache.lbl_MultiLangSet'/>", url, "500px", "250px", "iframe", true, null, null, true);
}


/********************************************************************************************************/


//대분류, 소분류 selectbox 조회
//Selectbox에 value 값에   'CategoryID|DisplayName|CategoryPath' 형태로 설정됨
function selectLargeCategoryList(){
	$.ajax({
		type:"POST",
		async:false,
		data: {
			  "folderID": folderID
			, "communityID": communityID
		},
		url:"/groupware/admin/selectCategoryList.do",
		success:function(data){
			$("#selectLargeCategory").bindSelect({ //대분류
				reserveKeys: {
					optionValue: "optionValue",
					optionText: "optionText"
				},
				options:data.categoryList
			});
		},
		error:function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("/groupware/admin/selectCategory.do", response, status, error);
		}
	});
}

//소분류 조회 
function selectSmallCategoryList(){
	var largeCategoryManagerCode = $("#selectLargeCategory").val() ? $("#selectLargeCategory").val().split("|")[2] : "";
	selectCategoryManagerName(largeCategoryManagerCode, "hidLargeCategoryManagerName");
	$("#hidLargeCategoryManagerCode").val(largeCategoryManagerCode);
	
	$.ajax({
		type:"POST",
        async: false,
		data: {
			"folderID": folderID,
			"memberOf": $("#selectLargeCategory").val() ? $("#selectLargeCategory").val().split("|")[0] : "",
			"communityID": communityID
		},
		url:"/groupware/admin/selectCategoryList.do",
		success:function(data){
			$("#selectSmallCategory").bindSelect({ //대분류
				reserveKeys: {
					optionValue: "optionValue",
					optionText: "optionText"
				},
				options:data.categoryList
			});
			
			var smallCategoryManagerCode = $("#selectSmallCategory").val() ? $("#selectSmallCategory").val().split("|")[2] : "";
			selectCategoryManagerName(smallCategoryManagerCode, "hidSmallCategoryManagerName");
			$("#hidSmallCategoryManagerCode").val(smallCategoryManagerCode);
		},
		error:function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("/groupware/admin/selectCategory.do", response, status, error);
		}
	});
}

function createLargeCategoryDic_CallBack(dicInfo) {
	$('#hidLargeCateName').val(coviDic.convertDic(dicInfo));

	$.ajax({
    	type:"POST",
    	url: "/groupware/admin/createCategory.do",
    	dataType : 'json',
    	data: {
        	"folderID": folderID,
        	"displayName": $("#hidLargeCateName").val(),
        	"memberOf": "",
        	"sortKey": $("#selectLargeCategory option").size()
    	},
    	success:function(data){
    		if(data.status=='SUCCESS'){
    			/*저장되었습니다.*/
	    		Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){
	    			selectLargeCategoryList();
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

function createSmallCategory(){
	if($("#selectLargeCategory option").size() > 0){
		dictionaryLayerPopup('create', $('#selectSmallCategory'),$('#hidSmallCateName'));
	} else {
		Common.Warning("<spring:message code='Cache.msg_category_insert'/>");		//추가하실 대분류를 선택해주세요
	}
}

function createSmallCategoryDic_CallBack(data) {
	$('#hidSmallCateName').val(coviDic.convertDic(data));

	$.ajax({
    	type:"POST",
    	url: "/groupware/admin/createCategory.do",
    	dataType : 'json',
    	data: {
        	"folderID": folderID,
        	"memberOf": $("#selectLargeCategory").val().split("|")[0],
        	"displayName": $("#hidSmallCateName").val(),
        	"sortKey": $("#selectSmallCategory option").size(),
        	"sortPath": $("#selectLargeCategory").val().split("|")[3]
        	
    	},
    	success:function(data){
    		if(data.status=='SUCCESS'){
    			/*저장되었습니다.*/
	    		Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){
	    			selectSmallCategoryList();//소분류 selectbox 재조회
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

function editLargeCategory(){
	if($("#selectLargeCategory option").size() > 0){
		dictionaryLayerPopup('edit', $('#selectLargeCategory'),$('#hidLargeCateName'));
	} else {
		Common.Warning("<spring:message code='Cache.msg_SelectTarget'/>");		//대상을 선택해주세요.
	}
}

function editLargeCategoryDic_CallBack(data) {
	$('#hidLargeCateName').val(coviDic.convertDic(data));
	//이후에 대분류 카테고리 추가

	$.ajax({
    	type:"POST",
    	url: "/groupware/admin/updateCategory.do",
    	dataType : 'json',
    	data: {
    		"categoryID": $("#selectLargeCategory").val().split("|")[0],	// CategoryID | DisplayName | 
        	"displayName": $("#hidLargeCateName").val(),
    	},
    	success:function(data){
    		if(data.status=='SUCCESS'){
    			/*저장되었습니다.*/
	    		Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){
	    			selectLargeCategoryList();
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

function editLargeCategoryDicInit(){
	var value = "";
	
	if($('#selectLargeCategory').find("option").length > 0){
		value = $('#selectLargeCategory').val().split("|")[1];
	}	
	
	return value;
}

function editSmallCategory(){
	if($("#selectSmallCategory option").size() > 0){
		dictionaryLayerPopup('edit', $('#selectSmallCategory'),$('#hidSmallCateName'));
	} else {
		Common.Warning("<spring:message code='Cache.msg_SelectTarget'/>");		//대상을 선택해주세요.
	}
}

function editSmallCategoryDic_CallBack(data) {
	$('#hidSmallCateName').val(coviDic.convertDic(data));

	$.ajax({
    	type:"POST",
    	url: "/groupware/admin/updateCategory.do",
    	dataType : 'json',
    	data: {
        	"categoryID": $("#selectSmallCategory").val().split("|")[0],
        	"displayName": $("#hidSmallCateName").val()
    	},
    	success:function(data){
    		if(data.status=='SUCCESS'){
    			/*저장되었습니다.*/
	    		Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){
	    			selectSmallCategoryList();
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

function editSmallCategoryDicInit(){
	var value = "";
	if($('#selectSmallCategory').find("option").length > 0){
		value = $('#selectSmallCategory').val().split("|")[1];
	}	
	
	return value;
}

function deleteCategory(pObj){	
	if($(pObj).val() == null || $(pObj).val() == undefined){
		Common.Warning("<spring:message code='Cache.msg_SelectTarget'/>");		//대상을 선택해주세요.
		return;
	}
	
	var categoryID = $(pObj).val().split("|")[0];	//카테고리ID | 표시명 | 관리자코드 | sortpath
	
	Common.Confirm("<spring:message code='Cache.msg_Common_08'/>", 'Confirmation Dialog', function (result) {       // 선택한 항목을 삭제하시겠습니까?
		if (result) {
			$.ajax({
				type:"POST",
	           	url:"/groupware/admin/deleteCategory.do",
	           	data:{
	               	"categoryID": categoryID,
	           	},
	           	success:function(data){
	           		if(data.status=='SUCCESS'){
	           			Common.Inform("<spring:message code='Cache.msg_50'/>"); // 삭제되었습니다.   
	           			
	           			if($(pObj).attr("id") == "selectLargeCategory"){		//삭제 처리 이후 selectbox 재조회
	               			selectLargeCategoryList();
	               		} 
	           			selectSmallCategoryList(); //대뷴류 삭제 시 소분류도 삭제됨
	           			
	           		}else{
	           			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
	           		}
	           	},
	           	error:function(error){
	           		Common.Warning("<spring:message code='Cache.msg_apv_030'/>");// 오류가 발생헸습니다. 
	           	}
			});
		}
	});
}

/********************************************************************************************************/

//Selectbox에 value 값에   'StateID|DisplayName' 형태로 설정됨
function selectProgressStateList(){
	$.ajax({
		type:"POST",
		data: {
			"folderID": folderID,
		},
		url:"/groupware/admin/selectProgressStateList.do",
		success:function(data){
			$("#selectProgressState").bindSelect({ //대분류
				reserveKeys: {
					optionValue: "optionValue",
					optionText: "optionText"
				},
				options:data.stateList
			});
		},
		error:function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("/groupware/admin/selectProgressStateList.do", response, status, error);
		}
	});
}

function createProgressStateDic_CallBack(dicInfo) {
	document.getElementById("hidProgressStateName").value = dicInfo;

	$.ajax({
    	type:"POST",
    	url: "/groupware/admin/createProgressState.do",
    	dataType : 'json',
    	data: {
        	"folderID": folderID,
        	"displayName": $("#hidProgressStateName").val(),
        	"sortKey": $("#selectProgressState option").size()
    	},
    	success:function(data){
    		if(data.status=='SUCCESS'){
    			/*저장되었습니다.*/
	    		Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){
	    			selectProgressStateList();//소분류 selectbox 재조회
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


function editProgressStateDic_CallBack(dicInfo) {
	document.getElementById("hidProgressStateName").value = dicInfo;

	$.ajax({
    	type:"POST",
    	url: "/groupware/admin/updateProgressState.do",
    	dataType : 'json',
    	data: {
    		"stateID": $("#selectProgressState").val().split("|")[0],
        	"displayName": $("#hidProgressStateName").val(),
    	},
    	success:function(data){
    		if(data.status=='SUCCESS'){
    			
	    		Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){	/*저장되었습니다.*/
	    			selectProgressStateList();
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

function deleteProgressState(pObj){
	var stateID = $(pObj).val().split("|")[0];	//진행상태ID | 표시명
	
	Common.Confirm("<spring:message code='Cache.msg_Common_08'/>", 'Confirmation Dialog', function (result) {       // 선택한 항목을 삭제하시겠습니까?
        if (result) {
           $.ajax({
           	type:"POST",
           	url:"/groupware/admin/deleteProgressState.do",
           	data:{
               	"stateID": stateID,
               	"folderID": folderID
           	},
           	success:function(data){
           		if(data.status=='SUCCESS'){
           			Common.Inform("<spring:message code='Cache.msg_50'/>"); // 삭제되었습니다.   
           			selectProgressStateList();	
           		}else{
           			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
           		}
           	},
           	error:function(error){
           		Common.Warning("<spring:message code='Cache.msg_apv_030'/>");// 오류가 발생헸습니다. 
           	}
           	
           });
        }
    });
}

/********************************************************************************************************/
//조직도 호출 팝업
function OrgMapLayerPopup_Owner(){
	var paramsCommunity = communityID == "" ? "" : ("&communityId=" + communityID);
	var target = {
		selected : $("#ownerCode").val()
	}
	var userParam = '&userParams=' + encodeURIComponent(JSON.stringify(target));
	CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=ownerAdd_CallBack&type=B9" + userParam + paramsCommunity,"<spring:message code='Cache.lbl_DeptOrgMap'/>",1000,580,"");
}

function OrgMapLayerPopup_approvalLine(){
	CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=approvalLineAdd_CallBack&type=B9","<spring:message code='Cache.lbl_DeptOrgMap'/>",1000,580,"");
}

//분류별 담당자 지정 조직도 팝업
var OrgMapLayerPopup_CategoryManager = function(cateOperator){
	var categoryID = cateOperator == "SetLargeCateOperator" ? ($("#selectLargeCategory").val() ? $("#selectLargeCategory").val().split("|")[0] : "") : ($("#selectSmallCategory").val() ? $("#selectSmallCategory").val().split("|")[0] : "");
	
	if(categoryID == "") {
		Common.Warning(String.format(Common.getDic("msg_ChooseCategory"), Common.getDic(cateOperator == "SetLargeCateOperator" ? "lbl_LCate" : "lbl_SCate")));
		return;
	}
	
	var paramsCommunity = communityID ? ("&communityId=" + communityID) : "";
	var callBackFunc = cateOperator == "SetLargeCateOperator" ? "largeCategoryManagerAdd_CallBack" : "smallCategoryManagerAdd_CallBack";
	var target = { selected : cateOperator == "SetLargeCateOperator" ? $("#hidLargeCategoryManagerCode").val() : $("#hidSmallCategoryManagerCode").val() };	
	var userParam = '&userParams=' + encodeURIComponent(JSON.stringify(target));
	
	CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=" + callBackFunc + "&type=B9" + userParam + paramsCommunity,"<spring:message code='Cache.lbl_DeptOrgMap'/>",1000,580,"");
}

function OrgMapLayerPopup(caller, callbackName, type) {
	var orgChartUrl = "/covicore/control/goOrgChart.do?callBackFunc="+callbackName+"&type="+type;
	var target = {
		name: (caller.getAttribute('data-target-name')) ? caller.getAttribute('data-target-name') : '',
		code: (caller.getAttribute('data-target-code')) ? caller.getAttribute('data-target-code') : '',
		selected: (caller.getAttribute('data-target-code')) ? document.getElementById(caller.getAttribute('data-target-code')).value : ''
	}
	
	orgChartUrl += '&userParams=' + encodeURIComponent(JSON.stringify(target));
	CFN_OpenWindow(orgChartUrl, "<spring:message code='Cache.lbl_DeptOrgMap'/>",1000,580,"");
}

//담당자 지정
function ownerAdd_CallBack(orgData){
	var ownerJSON =	$.parseJSON(orgData);
	var ownerName = "";
	var ownerCode = "";
	
	$(ownerJSON.item).each(function(i, item){
		sObjectType = item.itemType;
		if(sObjectType.toUpperCase() == "USER"){ //사용자
			ownerName += CFN_GetDicInfo(item.DN) + ", ";
			ownerCode += item.UserCode + ";";
		}
	});
	
	if(ownerCode.length > 0){
		ownerName = ownerName.substring(0, ownerName.length - 2);
	}
	
	$("#userName").val(ownerName);
	$("#ownerCode").val(ownerCode);
}

//대분류 담당자 변경
var largeCategoryManagerAdd_CallBack = function(orgData){
	var ownerJSON =	$.parseJSON(orgData);
	var ownerName = "";
	var ownerCode = "";
	
	$(ownerJSON.item).each(function(i, item){
		sObjectType = item.itemType;
		if(sObjectType.toUpperCase() == "USER"){ //사용자
			ownerName += CFN_GetDicInfo(item.DN) + ", ";
			ownerCode += item.UserCode + ";";
		}
	});
	
	if(ownerCode.length > 0){
		ownerName = ownerName.substring(0, ownerName.length - 2);
	}
	
	var idx = $("#selectLargeCategory option").index($("#selectLargeCategory option:selected"));
	var categoryID = $("#selectLargeCategory").val() ? $("#selectLargeCategory").val().split("|")[0] : "";
	var categoryManagerCode = ownerCode;
	
	$.ajax({
		type: "POST",
		url: "/groupware/admin/updateCategoryManager.do",
		dataType: 'json',
		async: false,
		data: {
			  "categoryID": categoryID
			, "categoryManagerCode": categoryManagerCode
		},
		success: function(res){
			selectLargeCategoryList();
			$('#selectLargeCategory option:eq('+idx+')').prop('selected', true);			
			$("#hidLargeCategoryManagerName").val(ownerName);
			$("#hidLargeCategoryManagerCode").val(ownerCode);
		}, 
		error: function(response, status, error){
			CFN_ErrorAjax("/groupware/admin/updateCategoryManager.do", response, status, error);
		}
	});
}

// 소분류 담당자 변경
var smallCategoryManagerAdd_CallBack = function(orgData){
	var ownerJSON =	$.parseJSON(orgData);
	var ownerName = "";
	var ownerCode = "";
	
	$(ownerJSON.item).each(function(i, item){
		sObjectType = item.itemType;
		if(sObjectType.toUpperCase() == "USER"){ //사용자
			ownerName += CFN_GetDicInfo(item.DN) + ", ";
			ownerCode += item.UserCode + ";";
		}
	});
	
	if(ownerCode.length > 0){
		ownerName = ownerName.substring(0, ownerName.length - 2);
	}
	
	var idx = $("#selectSmallCategory option").index($("#selectSmallCategory option:selected"));
	var categoryID = $("#selectSmallCategory").val() ? $("#selectSmallCategory").val().split("|")[0] : "";
	var categoryManagerCode = ownerCode;
	
	$.ajax({
		type: "POST",
		url: "/groupware/admin/updateCategoryManager.do",
		dataType: 'json',
		async: false,
		data: {
			  "categoryID": categoryID
			, "categoryManagerCode": categoryManagerCode
		},
		success: function(res){
			selectSmallCategoryList();
			$('#selectSmallCategory option:eq('+idx+')').prop('selected', true);			
			$("#hidSmallCategoryManagerName").val(ownerName);
			$("#hidSmallCategoryManagerCode").val(ownerCode);
		}, 
		error: function(response, status, error){
			CFN_ErrorAjax("/groupware/admin/updateCategoryManager.do", response, status, error);
		}
	});
}

//승인자 체크박스 클릭
function checkClickApprover(pChk) {
    //한개만 선택되게..
    if (pChk.checked) {
        $("[name=chkApprover]").each(function (i) {
            $(this).attr('checked', false);
        });
        pChk.checked = true;
    }
}

//승인자 왼쪽으로 이동
function moveLeftApprover(){
	var org_approver = $("[name=chkApprover]:checked").parent().html();
	var dest_approver = $("[name=chkApprover]:checked").parent().prev().prev().html();
	var startYN = "";
    var isChecked = false;
		
	$("[name=chkApprover]").each(function (i) {
		if ($(this).prop("checked")) {
			isChecked = true;
			l_Seq = $(this).attr('value');
			if (i == 0)
				startYN = "Y";
		}
	});
	
	if (!isChecked) {
		Common.Warning("<spring:message code='Cache.msg_NoSelMovingApprover'/>");  //이동할 승인자가 선택되지 않았습니다
		return;
	}
	
	if (startYN != "Y") {			
		$("[name=chkApprover]:checked").parent().prev().prev().html(org_approver);
		$("[name=chkApprover]:checked").parent().html(dest_approver);
	}
}

//승인자 오른쪽으로 이동
function moveRightApprover(){
	var org_approver = $("[name=chkApprover]:checked").parent().html();
	var dest_approver = $("[name=chkApprover]:checked").parent().next().next().html();
	var endYN = "";
    var isChecked = false;
		
	$("[name=chkApprover]").each(function (i) {
		if ($(this).prop("checked")) {
			isChecked = true;
			l_Seq = $(this).attr('value');
			if (i == ($("[name=chkApprover]").length-1))
				endYN = "Y";
		}
	});
	
	if (!isChecked) {
		Common.Warning("<spring:message code='Cache.msg_NoSelMovingApprover'/>");  //이동할 승인자가 선택되지 않았습니다
		return;
	}
	
	if (endYN != "Y") {			
		$("[name=chkApprover]:checked").parent().next().next().html(org_approver);
		$("[name=chkApprover]:checked").parent().html(dest_approver);
	}
}

//승인자 중복체크 
function dupCheckApprover( pOrgData ) {
    var approvalJSON = $.parseJSON(pOrgData);
    var isExist = false;
    var l_UserCode = "";
    var l_UserName = "";
    var l_ApproverCnt = $("[name=chkApprover]").length;

    $(approvalJSON.item).each(function (i, item) {
  		sObjectType = item.itemType;
  		
  		if(sObjectType.toUpperCase() == "USER"){ //사용자
	        l_UserCode = item.UserCode;
	        l_UserName = CFN_GetDicInfo(item.DN);
	        
	        $("[name=spnApprover]").each(function (i) {
	            if (l_UserCode == $(this).attr('userCode')) {
	                isExist = true;
	                Common.Warning(l_UserName + " " + "<spring:message code='Cache.msg_AlreadyAdd'/>");  //(은)는 이미 추가되어있습니다
	            }
	        });
  		}
    });
    return isExist;
}

//승인 프로세스 지정용 - 추가 수정 필요
//CHECK
function approvalLineAdd_CallBack(orgData){
	if (dupCheckApprover(orgData))
        return;
	
	var approvalJSON =  $.parseJSON(orgData);
	var approvalUser = "";
	var approvalUserName = "";
	var approvalDept = "";
	var approvalIDs = "";
	var htmlApprovalLine = "";
	var step = $("[name=chkApprover]").length;
	
	$(approvalJSON.item).each(function (i, item) {
  		sObjectType = item.itemType;
  		
  		if(sObjectType.toUpperCase() == "USER"){ //사용자
  			approvalUser = item.UserCode;
  			approvalUserName = CFN_GetDicInfo(item.DN);
			approvalDept = CFN_GetDicInfo(item.SGNM);

			if(step > 0 && i == 0 ){
				htmlApprovalLine += String.format("<span class='right_arrow' id='imgApproverArrow_{0}'/>", step);
  	  		}
			htmlApprovalLine += "<div class='topbar_grid' style='display:inline-block;'>";
			htmlApprovalLine += String.format("<input name='chkApprover' id='chkApprover_{0}' onclick='checkClickApprover(this);' type='checkbox' class='input_check' value='{0}'>", step);
			htmlApprovalLine += String.format("<input type='button' class='AXButtonSmall' value='{0}' onclick='javascript:boardAdmin.changeActivityType({1}, this)'/>", "<spring:message code='Cache.lbl_Serial'/>", step);
			htmlApprovalLine += String.format("<span name='spnApprover' id='spnApprover_{0}' ActivityID='' ActorRole='Approver' ActivityType='Serial' userCode='{3}'> {1} ({2})&nbsp; </span>", step, approvalUserName, approvalDept, approvalUser);
			htmlApprovalLine += String.format("<span class='btn_x' onclick='javascript:deleteApprover(this)'/>");
			htmlApprovalLine += String.format("</div>");
			if(i != approvalJSON.item.length-1){
				htmlApprovalLine += String.format("<span class='right_arrow' id='imgApproverArrow_{0}' />", step);
			}
			step++;
  	  	}
 	});

	$('#spnApprovalLine').append(htmlApprovalLine);
}

//승인자 삭제 
function deleteApprover( pObj ){
	//이전 단계의 승인자가 없을 경우 우측에 있는 화살표 삭제
	if($(pObj).parent().prev().length > 0){
		$(pObj).parent().prev().remove();
	} else {
		$(pObj).parent().next().remove();
	}
	$(pObj).parent().remove();
}

/********************************************************************************************************/

//하단의 닫기 버튼 함수
function closeLayer(){
	Common.Close();
}

//팝업 게시판 설정
function setBoardConfig(){
	if(boardAdmin.checkBoardConfigValidation()){
		var sDictionaryInfo = document.getElementById("hidFolderNameDicInfo").value;
	    if (sDictionaryInfo == "") {
	        switch (Common.getSession("lang").toUpperCase()) {
	            case "KO": sDictionaryInfo = document.getElementById("folderName").value + ";;;;;;;;;"; break;
	            case "EN": sDictionaryInfo = ";" + document.getElementById("folderName").value + ";;;;;;;;"; break;
	            case "JA": sDictionaryInfo = ";;" + document.getElementById("folderName").value + ";;;;;;;"; break;
	            case "ZH": sDictionaryInfo = ";;;" + document.getElementById("folderName").value + ";;;;;;"; break;
	            case "E1": sDictionaryInfo = ";;;;" + document.getElementById("folderName").value + ";;;;;"; break;
	            case "E2": sDictionaryInfo = ";;;;;" + document.getElementById("folderName").value + ";;;;"; break;
	            case "E3": sDictionaryInfo = ";;;;;;" + document.getElementById("folderName").value + ";;;"; break;
	            case "E4": sDictionaryInfo = ";;;;;;;" + document.getElementById("folderName").value + ";;"; break;
	            case "E5": sDictionaryInfo = ";;;;;;;;" + document.getElementById("folderName").value + ";"; break;
	            case "E6": sDictionaryInfo = ";;;;;;;;;" + document.getElementById("folderName").value; break;
	        }
	        document.getElementById("hidFolderNameDicInfo").value = sDictionaryInfo
	    }

	    var url;
	    var param;
		if(folderID !="" && mode!="create"){
			//폴더/게시판 정보 수정	
			url = "/groupware/admin/updateBoard.do";
			
			var bodyFormId = $("input[name=chkBodyForm]:checked")[0] != undefined? $("input[name=chkBodyForm]:checked")[0].value:"";
			
			//권한 설정정보 
			var aclList = encodeURIComponent(coviACL_getACLData("con_acl"));
			var aclActionList = encodeURIComponent(coviACL_getACLActionData("con_acl"));
			
			$('input[type=checkbox]').attr('disabled', false);	//disable상태인 체크박스데이터 parameter로 추가
			
			var paramObject = new Object();
			paramObject = $("#frmBoardConfig").serializeObject();
			paramObject["mode"] = mode;
			paramObject["bizSection"]= bizSection;
			paramObject["folderID"] = folderID;
			paramObject["domainID"] = domainID;
			paramObject["folderType"] = $("#folderType").val();
			paramObject["displayName"] = $("#folderName").val();
			paramObject["multiDisplayName"] = $("#hidFolderNameDicInfo").val();		//다국어 입력항목
			paramObject["contentsID"] = $("#hidContentsID").val();
			paramObject["processActivityList"] = boardAdmin.setProcessData();
			paramObject["processID"] = $("#hidProcessID").val();
			paramObject["boardDescription"] = "";
			paramObject["bodyFormID"] = bodyFormId;					//초기양식으로 설정된 본문양식ID
			paramObject["aclList"] = aclList;						//권한 설정 정보
			paramObject["aclActionList"] = aclActionList;			//권한 설정 정보
			paramObject["communityID"] = communityID;
			paramObject["ownerCode"] = $("#ownerCode").val();
			paramObject["limitFileSize"] = convertToBytes(paramObject["limitFileSize"]);	// 1회 업로드 제한
			paramObject["totalFileSize"] = convertToBytes(paramObject["totalFileSize"]);	// 총 업로드 제한
			paramObject["isUpdateChildren"] = $("#checkIsSubfolderInherited").is(":checked") ? "Y" : "N";
			paramObject["isInherited"] = $("#con_acl_isInherited").is(":checked") ? "Y" : $("#checkIsSubfolderInherited").is(":checked") ? "Y" : "N";
		
			// 업로드 가능한 확장자
			var enableFileExtentionArr = new Array();
			$("#enableFileExtention input[type=checkbox]:checked").each(function() {				
				enableFileExtentionArr.push(this.name);
				delete paramObject[this.name];
			});
			
			paramObject["enableFileExtention"] = enableFileExtentionArr.join(",");
			
			// tab별 체크되지 않은 체크박스 항목 별도 참조 
			$("#searchTab_BasicOption input[type=checkbox]:not(:checked)").each(function(){ paramObject[this.name]=null; });
			$("#searchTab_ExtOption input[type=checkbox]:not(:checked)").each(function(){ paramObject[this.name]=null; });
			param = paramObject;
		}else{			
			url = "/groupware/admin/createBoard.do";
			param = {
	    		"domainID": domainID,
	    		"bizSection": bizSection,
	    		"menuID": $("#selectMenuID").val(),
	    		"mode": mode, // 'copy' or ''
	    		"memberOf": $("#folderType").val()!='Root'?folderID:"",
	    		"displayName": $("#folderName").val(),
	    		"multiDisplayName": $("#hidFolderNameDicInfo").val(),
	    		"folderType": $("#folderType").val(),
	    		"isUse": $("#selectIsUse").val(),
	    		"isDisplay": $("#selectIsDisplay").val(),
	    		"isAdminNotice": $("#selectIsAdminNotice").val(),
	    		"isMsgSecurity": $("#selectIsMsgSecurity").val(),
	    		"isShared": "N",
	    		"isMobileSupport": $("#selectIsMobileSupport").val(),
	    		"isURL": "N",
	    		"url": $("#linkURL").val(),
	    		"securityLevel": $("#securityLevel").val(),
	    		"ownerCode": $("#ownerCode").val(),
	    		"description": $("#description").val(),
	    		"communityID": communityID
	    	}
		}
		
		param.MessageTarget = getMessageTarget();

		$.ajax({
	    	type: "POST",
	    	url: url,
	    	dataType: 'json',
	    	data: param,
	    	success:function(data){
	    		if(data.status=='SUCCESS'){
	    			/*저장되었습니다.*/
		    		Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){
		    			if(communityID != null && communityID != ''){
		    				if(opener){
		    					opener.inCommMenu();
		    					opener.communityBoardLeft();
		    				}else{
		    					parent.inCommMenu();
			    				parent.communityBoardLeft();						
		    				} 
		    			}else{
		    				if(opener){
		    					if(opener.folderGrid != undefined){
		    						opener.folderGrid.reloadList();
		    						opener.setTreeData();
		    						opener.myFolderTree.expandAll(2);
								}	
		    				}else{
		    					if(parent.folderGrid != undefined){
									parent.folderGrid.reloadList();
									parent.setTreeData();
									parent.myFolderTree.expandAll(2);
								}							
		    				} 
		    			}
		    			Common.Close();
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

//옵션 삭제
function deleteOption(pObj, pOptionID){
	//이미 저장된 필드 항목의 옵션을 삭제할경우 row데이터를 추가로 삭제처리
	if(pOptionID != undefined && pOptionID != ''){
		Common.Confirm("<spring:message code='Cache.msg_Common_08'/>", 'Confirmation Dialog', function (result) {       // 선택한 항목을 삭제하시겠습니까?
          if (result) {
             $.ajax({
             	type:"POST",
             	url:"/groupware/admin/deleteUserDefOption.do",
             	data:{
                 	"optionID": pOptionID
             	},
             	success:function(data){
             		if(data.status=='SUCCESS'){
             			Common.Inform("<spring:message code='Cache.msg_50'/>"); // 삭제되었습니다.
             			selectUserDefFieldList();	//OptionCnt의 개수가 변했으므로 List재조회
             			//필드옵션 항목에서 표시하는 방법 변경
             			$(pObj).parent().parent().remove();
             			if($("#btnAddOption").size()==0){	//옵션 추가 버튼이 모두 사라졌을경우 재생성
             				$("#optionPlaceHolder>ul>li>input:last").after('<input type="button" id="btnAddOption" value=" + " class="AXButton" onclick="javascript:addOption()">');
             			}
             		}else{
             			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
             		}
             	},
             	error:function(error){
             		Common.Warning("<spring:message code='Cache.msg_apv_030'/>");// 오류가 발생헸습니다. 
             	}
             	
             });
          }
      });
	} else {
		$(pObj).parent().parent().remove();
		if($("#btnAddOption").size()==0){	//
			$("#optionPlaceHolder>ul>li>input:last").after('<input type="button" id="btnAddOption" value=" + " class="AXButton" onclick="javascript:boardAdmin.addOption()">');
		}
	}
}

//사용자 정의 필드 초기화버튼 클릭
function resetUserDefField() {
	$("#fieldType").val("Input");
	
	//컨트롤 초기화
	$("#fieldName").val("");
	$("#hidUserFormID").val("");
	$("#hidFieldNameDicInfo").val("");
	$("#fieldLimitCnt").val("");
	$("#isCheckVal").val("Y");		//필수
	$("#isList").val("N");			//목록표시
	$("#fieldSize").val("Line");
	
	//필드옵션항목 초기화
	$("#optionPlaceHolder").html("");
	$('#rowFieldOption').css({ "display": "none" });
	$('#spanFieldLimitCnt').css({ "display": "inline" });
	
	$("#btnEditField").hide();
	$("#btnAddField").show();
}

//사용자 정의 필드 validation 체크
function checkUserDefParam( pMode ){
var flag = true;
	
	if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
	
	if(pMode == "create" && userDefFieldGrid.getList().length >= 10){
		parent.Common.Warning("<spring:message code='Cache.msg_gw_ValidationUserDefField'/>"); // 필드명 입력
		flag = false;
	}
	
	if ($("#fieldName").val() == "") {
		parent.Common.Warning("<spring:message code='Cache.msg_EnterFieldNm'/>", "Warning Dialog", function(){ // 필드명 입력
			document.getElementById("fieldName").focus();
		});
		flag = false;
	}
	
	// 옵션체크
	if ($("#fieldType").val() == "DropDown" || $("#fieldType").val() == "CheckBox" || $("#fieldType").val() == "Radio") {
		$("input[id^=fieldOption_]").each(function (i) {
			if ($(this).attr('value') == "") {
				Common.Warning(CFN_GetDicInfo('msg_EnterFieldNm'));	//필드명을 입력하세요
				$(this).focus();
				flag = false;
				return flag;
			}
		});
	}
	
	return flag;
}

function setUserDefField( pMode ){
	if(checkUserDefParam(pMode)){
	 	var optionStr = "";
		for(var i = 0; i < $("input[id^=fieldOption]").length; i++){
			var optionName = ($("input[id^=hidFieldOption]")[i].value != '') ? $("input[id^=hidFieldOption]")[i].value : $("input[id^=fieldOption]")[i].value;
			optionStr += String.format('{0}|', optionName);
		}

		var sDictionaryInfo = document.getElementById("hidFieldNameDicInfo").value;
	    if (sDictionaryInfo == "") {
	        switch (Common.getSession("lang").toUpperCase()) {
	            case "KO": sDictionaryInfo = document.getElementById("fieldName").value + ";;;;;;;;;"; break;
	            case "EN": sDictionaryInfo = ";" + document.getElementById("fieldName").value + ";;;;;;;;"; break;
	            case "JA": sDictionaryInfo = ";;" + document.getElementById("fieldName").value + ";;;;;;;"; break;
	            case "ZH": sDictionaryInfo = ";;;" + document.getElementById("fieldName").value + ";;;;;;"; break;
	            case "E1": sDictionaryInfo = ";;;;" + document.getElementById("fieldName").value + ";;;;;"; break;
	            case "E2": sDictionaryInfo = ";;;;;" + document.getElementById("fieldName").value + ";;;;"; break;
	            case "E3": sDictionaryInfo = ";;;;;;" + document.getElementById("fieldName").value + ";;;"; break;
	            case "E4": sDictionaryInfo = ";;;;;;;" + document.getElementById("fieldName").value + ";;"; break;
	            case "E5": sDictionaryInfo = ";;;;;;;;" + document.getElementById("fieldName").value + ";"; break;
	            case "E6": sDictionaryInfo = ";;;;;;;;;" + document.getElementById("fieldName").value; break;
	        }
	        document.getElementById("hidFieldNameDicInfo").value = sDictionaryInfo
	    }
		
		var param = {
			"userFormID": $("#hidUserFormID").val(),
			"folderID": folderID,
	       	"fieldName": $("#hidFieldNameDicInfo").val(),
	       	"fieldType": $("#fieldType").val(),
	       	"fieldSize": $("#fieldSize").val(),
	       	"fieldLimitCnt": $("#fieldLimitCnt").val(),
	       	"isList": $("#isList").val(),
	       	"isOption": $("input[id^=fieldOption]").size()>0?"Y":"N",		//필드 옵션 입력항목이 있다면 Y
			"isCheckVal": $("#isCheckVal").val(),
			"isSearchItem": $("#isSearchItem").val(),
			"optionStr": optionStr
		}
		
		var url = "";
		if(pMode != "create"){
			url = "/groupware/admin/updateUserDefField.do";
		} else {
			url = "/groupware/admin/createUserDefField.do";
		}
		
		$.ajax({
	    	type: "POST",
	    	url: url,
	    	dataType: 'json',
	    	data: param,
	    	success: function(data){
	    		if(data.status=='SUCCESS'){
		    		Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){
		    			selectUserDefFieldList();	//사용자 정의 필드 데이터 추가  이후 조회
		    			resetUserDefField();		//저장, 조회 이후 입력항목 초기화
		    		});
	    		}else{
	    			Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
	    		}
	    	}, 
	  		error: function(error){
	  			Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
	  		}
	    });
	}
}

//사용자 정의 필드 삭제
function deleteUserDefField(){
	var userFormIDs = '';
	
	$.each(userDefFieldGrid.getCheckedList(0), function(i,obj){
		userFormIDs += obj.UserFormID + ';'
	});
	
	if(userFormIDs == ''){
		 Common.Warning("<spring:message code='Cache.msg_Common_03'/>"); // 삭제할 항목을 선택하여 주십시오.
		 return;
	}
	
	Common.Confirm("<spring:message code='Cache.msg_Common_08'/>", 'Confirmation Dialog', function (result) {       // 선택한 항목을 삭제하시겠습니까?
		if (result) {
			$.ajax({
          		type: "POST",
          		url: "/groupware/admin/deleteUserDefField.do",
          		data: {
          			"userFormIDs":userFormIDs,
          			"folderID": folderID
          		},
          		success: function(data){
          			if(data.status=='SUCCESS'){		//성공시 Grid재조회 및 필드 입력항목 초기화
          				Common.Inform("<spring:message code='Cache.msg_50'/>"); // 삭제되었습니다.
          				userDefFieldGrid.reloadList();
          				resetUserDefField();
          			}else{
          				Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
          			}
          		},
          		error: function(response, status, error){
					CFN_ErrorAjax("/groupware/admin/deleteUserDefField.do", response, status, error);
          		}
          	});
       	}
   });
}

//사용자 정의 필드 Grid 세팅
function setUserDefFieldGrid(){
	userDefFieldGrid.setGridHeader(boardAdmin.getGridHeader("UserDefField"));
	setUserDefFieldGridConfig();
	selectUserDefFieldList();				
}

//사용자 정의 필드 Grid Config 설정
function setUserDefFieldGridConfig(){
	var configObj = {
		targetID: "userDefFieldGrid",
		listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
		height: "auto",
		page: {
	        display: false,
	        paging: false,
	        pageNo: 1,
	        pageSize: 10,
		},
		paging : true,
		colHead: {},
		body: {
			onclick: function(){
				if(this.item.IsOption == "Y"){
					selectUserDefFieldOptionList(this.item.FolderID, this.item.UserFormID);
				} else {
					$("#rowFieldOption").hide();
					$("#optionPlaceHolder").html("");
				}
				$("#hidUserFormID").val(this.item.UserFormID);
				$("#hidFieldNameDicInfo").val(this.item.FieldName);
				$("#fieldName").val(CFN_GetDicInfo(this.item.FieldName));
				$("#fieldType").val(this.item.FieldType);
				$("#fieldLimitCnt").val(this.item.FieldLimitCnt);
				$("#isList").val(this.item.IsList);
				$("#isCheckVal").val(this.item.IsCheckVal);
				$("#isSearchItem").val(this.item.IsSearchItem);
				$("#fieldSize").val(this.item.FieldSize);		
				$("#btnAddField").hide();
				$("#btnEditField").show();
		    }				
		}
	};
	userDefFieldGrid.setGridConfig(configObj);
	userDefFieldGrid.config.fitToWidthRightMargin = 0;
}

//사용자 정의 Field 조회/페이징
function selectUserDefFieldList( pMenuID, pFolderID ){
	userDefFieldGrid.bindGrid({
		ajaxUrl: "/groupware/admin/selectUserDefFieldGridList.do",
		ajaxPars: {
			"folderID": folderID,
		}
	});
}

//Grid에서 선택한 사용자 정의 필드에 필드 옵션에 존재할 경우 필드옵션 리스트 조회
function selectUserDefFieldOptionList(pFolderID, pUserFormID){
	$.ajax({
    	type: "POST",
    	url: "/groupware/admin/selectUserDefFieldOptionList.do",
    	dataType: 'json',
    	data: {
        	"folderID": pFolderID,
        	"userFormID": pUserFormID
    	},
    	success: function(data){
    		$("#optionPlaceHolder").html("");
    		$("#rowFieldOption").show();
    		var optionList = data.optionList;
    		for(var i = 0 ; i < optionList.length ;i++){
    			var option = String.format('<ul><li><input type="text" id="fieldOption_{0}" name="fieldOption_{0}" optionID="{1}" class="AXInput" value="{1}"/>', i, optionList[i].OptionName, optionList[i].OptionID);
    			option += String.format('<input type="hidden" id="hidFieldOption_{0}_DicInfo"/>', i);
    			option += String.format('<input type="button" value="{1}" class="AXButton" onclick="javascript:userDefFieldnDicLayerPopup({0},$(\'#fieldOption_{0}\'),$(\'#hidFieldOption_{0}_DicInfo\'));">',i, "<spring:message code='Cache.lbl_MultiLang2'/>");
    			option += String.format('<input type="button" id="btnDeleteOption" value=" - " class="AXButton" onclick="javascript:deleteOption(this, {0})" /></li></ul>', optionList[i].OptionID);	 
    			$("#optionPlaceHolder").append(option);
    		}

    		//입력항목 추가후 옵션 추가 버튼을 마지막 항목에 추가 
    		$("#optionPlaceHolder>ul>li>input:last").after('<input type="button" id="btnAddOption" value=" + " class="AXButton" onclick="javascript:boardAdmin.addOption()">');
    	}, 
  		error:function(error){
  			Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
  		}
    });
}

//사용자 정의 필드 위치 변경
function moveUserDefField(pMode){
	if(userDefFieldGrid.getCheckedList(0).length == 0){
		Common.Warning("<spring:message code='Cache.msg_NoSelMovingField'/>"); // 이동할 필드가 선택되지 않았습니다
		return;
	}else if(userDefFieldGrid.getCheckedList(0).length > 1){
		Common.Warning("<spring:message code='Cache.msg_OnlyOneSelMovingField'/>"); // 이동할 필드는 한개만 선택되어야 합니다
		return;
	}
	
	var param = userDefFieldGrid.getCheckedList(0)[0];
	
	$.ajax({
		type: "POST",
		url: "/groupware/admin/moveUserDefField.do",
		dataType: 'json',
		data: {
			"folderID": param.FolderID,
			"userFormID": param.UserFormID,
			"sortKey": param.SortKey,
			"mode": pMode
		},
		success: function(data){
			if(data.status=='SUCCESS'){
				if(data.message){ // 최상위, 최하위 항목의 경우에는 변경 불가 메시지 표시
					Common.Warning(data.message);
				} else {
					Common.Warning("<spring:message code='Cache.msg_Changed'/>"); // 삭제되었습니다.
				}
				userDefFieldGrid.reloadList();
				resetUserDefField();
			}else{
				Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생헸습니다.
			}
		},
		error: function(response, status, error){
			CFN_ErrorAjax("/groupware/admin/moveUserDefField.do", response, status, error);
		}
	});
}

//게시판 설명 항목 조회
function selectBoardDescription(){
	$.ajax({
    	type:"POST",
    	url: "/groupware/admin/selectBoardDescription.do",
    	dataType : 'json',
    	data: {
        	"folderID": folderID,
    	},
    	success: function(data){
			if(data.status=='SUCCESS'){
				if(data.boardDescription.Body){
					setTimeout(function(){
						DEXT5.setBodyValueEx(data.boardDescription.Body, 'xfe');
					}, 500);
				}
				
				$("#hidContentsID").val(data.boardDescription.ContentsID);
			}else{
				Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생헸습니다.
			}
		}, 
		error: function(response, status, error){
			 CFN_ErrorAjax("/groupware/admin/selectBoardDescription.do", response, status, error);
		}
    });
}

//본문양식 체크박스 컨트롤
//본문양식명 앞에있는 체크박스 체크시
function CheckClickBodyForm(oChk) {
    var l_Seq = 0;
    //하나만 선택되게
    if (oChk.checked) {
        $("[name=chkBodyForm]").each(function (i) {
            //체크해제
            $(this).attr('checked', false);
            //"IsInit"속성값 "N"으로 변경
            l_Seq = $(this).attr('value');
            $("#spnBodyForm_" + l_Seq).attr('IsInit', 'N');
        });

        oChk.checked = true;
    }

    //체크여부에따른 "IsInit"속성값 재변경
    l_Seq = oChk.value;
    if (oChk.checked) {
        $("#spnBodyForm_" + l_Seq).attr('IsInit', 'Y');
    } else {
        $("#spnBodyForm_" + l_Seq).attr('IsInit', 'N');
    }
}

//양식파일 validation check
function fileuploadBeforeCheck() {
    var file = document.getElementById("uploadFile");

	if(file.files.length != 1){
		Common.Warning("<spring:message code='Cache.msg_SelFormFile'/>");
		return false;
	}
    
    if(file.files.length<=0){	//CHECK: 추가로직이 아닌 수정일경우 파일 업로드 하지 않아도 되는 부분에서 사용하는 것 같다. 추가 분석 필요 
    	return true;
	}else if (file.files.item(0).name.length > 20) {
        Common.Warning("<spring:message code='Cache.lbl_apv_warning_filename'/>");
        return false;
    }else if (file.files.item(0).size > 512000) {
    	Common.Warning("<spring:message code='Cache.lbl_apv_warning_filesize'/>");
        return false;
    } else {
        return true;
    }
}

//본문양식 등록
function createBodyForm(){
	if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

	if($("#txtBodyFormName").val() == ""){
		Common.Warning("<spring:message code='Cache.msg_EnterFormNm'/>", "Warning Dialog", function () {
			$("#txtBodyFormName").focus();
		});          // 이동할 필드가 선택되지 않았습니다
		return;
	} else if(!fileuploadBeforeCheck()){
    	return; 
    }
	
	var formData = new FormData();
	formData.append("formName", $("#txtBodyFormName").val());
	formData.append('uploadFile', $('#uploadFile')[0].files[0]);
	formData.append('folderID', folderID);
	
	$.ajax({
        type : 'post',
        url : "/groupware/admin/createBodyForm.do",
        data : formData,
        dataType : 'json',
        processData : false,
        contentType : false,	  
        success : function(data){	
        	if(data.status=='SUCCESS'){
            	Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){ //저장되었습니다.
            		$("#tdUpload").html("<input type=\"file\" id=\"uploadFile\" accept=\".txt,.htm,.html\" style=\"width: 80%;\"onchange=\"bodyFormCheckFileName(this.value);\"/><input type=\"button\" value=\""+Common.getDic("lbl_Add")+"\" style=\"margin-left: 6px;\" onclick=\"javascript:createBodyForm();\" class=\"AXButton\" />");           	
            		$("#txtBodyFormName").val("");
            		selectBodyForm();
            	});
        	}else{
        		Common.Warning("<spring:message code='Cache.msg_apv_030'/>");
        	}
        },
        error:function(response, status, error){
            //TODO 추가 오류 처리
            CFN_ErrorAjax("/groupware/admin/createBodyForm.do", response, status, error);
        }
    });
}

//본문양식 조회
function selectBodyForm(){
	$.ajax({
        type : 'POST',
        url : "/groupware/admin/selectBodyForm.do",
        data: {
			"folderID": folderID
		},
        dataType : 'json',
        success : function(data){
        	var formList = data.formList;
        	var bodyFormHtml = "";
        	for (var i = 0; i < formList.length ; i++) {
        		bodyFormHtml += "<span name='spnBodyForm' id='spnBodyForm_" + formList[i].BodyFormID + "' FormPath='" + formList[i].FormPath + "' FormName='" + CFN_GetDicInfo(formList[i].FormName) + "' IsInit='" + formList[i].IsInit + "'>";
                if (formList[i].IsInit == "Y")
                	bodyFormHtml += "<input name='chkBodyForm' id='chkBodyForm_" + formList[i].BodyFormID + "' onclick='CheckClickBodyForm(this);' type='checkbox' checked value='" + formList[i].BodyFormID + "'>";
                else
                	bodyFormHtml += "<input name='chkBodyForm' id='chkBodyForm_" + formList[i].BodyFormID + "' onclick='CheckClickBodyForm(this);' type='checkbox' value='" + formList[i].BodyFormID + "'>";
                	bodyFormHtml += formList[i].FormName + "&nbsp;";
                	bodyFormHtml += "<input type='button' class='AXButtonSmall' value='X' onclick='javascript:deleteBodyForm("+ formList[i].BodyFormID +")'/>";
                	bodyFormHtml += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>";
            }

            $('#spnBodyFormList').html("");
            $('#spnBodyFormList').append(bodyFormHtml);
        },
        error:function(response, status, error){
            CFN_ErrorAjax("/groupware/admin/selectBodyForm.do", response, status, error);
        }
    });
}

//본문양식 삭제
function deleteBodyForm(pBodyFormID){
	Common.Confirm("<spring:message code='Cache.msg_Common_08'/>", 'Confirmation Dialog', function (result) {       // 선택한 항목을 삭제하시겠습니까?
		if (result) {
			$.ajax({
		        type : 'POST',
		        url : "/groupware/admin/deleteBodyForm.do",
		        data : {
					"bodyFormID": pBodyFormID
				},
		        dataType : 'json',
		        success : function(data){	
		        	if(data.status=='SUCCESS'){
		            	Common.Inform("<spring:message code='Cache.msg_50'/>","Information",function(){ //저장되었습니다.
		            		selectBodyForm()
		            	});
		        	}else{
		        		Common.Warning("<spring:message code='Cache.msg_apv_030'/>");
		        	}
		        },
		        error:function(response, status, error){
		            //TODO 추가 오류 처리
		            CFN_ErrorAjax("/groupware/admin/deleteBodyForm.do", response, status, error);
		        }
		    });
		}
	});
}

function bodyFormCheckFileName(str) {
    var fileName = str.split('\\').pop().toLowerCase();
    var ext =  str.split('.').pop().toLowerCase();
    
    if($.inArray(ext, ['txt', 'htm', 'html']) == -1) {
    	Common.Warning("<spring:message code='Cache.msg_uploadBodyFormFile'/>");  // txt, htm, html 파일만 업로드 할 수 있습니다.
    	$("#uploadFile").val("");
        return;
    }
}

//게시판 승인프로세스 조회 
function selectProcessActivityList(){
	$.ajax({
    	type:"POST",
    	url: "/groupware/admin/selectProcessActivityList.do",
    	dataType : 'json',
    	data: {
        	"folderID": folderID,
    	},
    	success:function(data){
    		if(data.status=='SUCCESS'){
    			$('#spnApprovalLine').html("");
    			var step = 0;
    			var htmlApprovalLine = "";
    			$("#hidProcessID").val(data.processID);
				
    			$(data.list).each(function (i, item) {
   					if(step > 0 && i == 0 ){
   						htmlApprovalLine += String.format("<span class='right_arrow' id='imgApproverArrow_{0}'/>", step);
   		  	  		}
   					htmlApprovalLine += "<div class='topbar_grid' style='display:inline-block;'>";
					htmlApprovalLine += String.format("<input name='chkApprover' id='chkApprover_{0}' onclick='checkClickApprover(this);' type='checkbox' class='input_check' value='{0}'>", step);
					htmlApprovalLine += String.format("<input type='button' class='AXButtonSmall' value='{0}' onclick='javascript:boardAdmin.changeActivityType({1}, this)'/>", Common.getDic("lbl_"+item.ActivityType), step);
					htmlApprovalLine += String.format("<span name='spnApprover' id='spnApprover_{0}' ActivityID='' ActorRole='Approver' ActivityType='{3}' userCode='{4}'> {1} ({2})&nbsp; </span>", step, item.DisplayName, item.DeptName, item.ActivityType, item.ActorCode);
					htmlApprovalLine += String.format("<span class='btn_x' onclick='javascript:deleteApprover(this)'/>");
					htmlApprovalLine += String.format("</div>");
   					if(i != data.list.length-1){
   						htmlApprovalLine += String.format("<span class='right_arrow' id='imgApproverArrow_{0}' />", step);
   					}
   					step++;
    		 	});

    			$('#spnApprovalLine').append(htmlApprovalLine);
      		}else{
      			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
      		}
    	}, 
    	error:function(response, status, error){
     	     CFN_ErrorAjax("/groupware/admin/selectProcessActivityList.do", response, status, error);
     	}
    });
}

function initOwnerCode() {
	$("#userName, #ownerCode").val('');
}

// 조직도에서 전달받은 사용자/그룹코드를 등록알림 지정한 위치에 추가
function addTarget_Callback(orgData){
	var _orgData = JSON.parse(orgData);				// JSON 문자열을 객체로 변환
	var _target = JSON.parse(decodeURIComponent(_orgData.userParams));	// userParams에 담아온 JON 문자열를 디코드하여 객체로 변환

	var _names = '';
	var _codes = '';
	$.each(_orgData.item, function(idx, el){
		_names += ((idx > 0) ? ', ' : '') + CFN_GetDicInfo(el.DN);
		_codes += ((el.itemType == 'group') ? el.GroupCode : el.UserCode) + ';';
	});
	
	var nameEl = document.getElementById(_target.name);
	nameEl.value = _names;
	var codeEl = document.getElementById(_target.code);
	codeEl.value = _codes;
}

// 등록알림 수신자, 제외자에 대한 데이터 처리
function getMessageTarget(){
	return JSON.stringify({ 
		Receivers: {
			code: $("#ReceiversCode").val(),
			name: $("#ReceiversName").val()
		},
		Excepters: {
			code: $("#ExceptersCode").val(),
			name: $("#ExceptersName").val()
		}
	});
}

function setEnableFileExtention(folderType) {
	var enableFileExtentionArr = Common.getBaseConfig('EnableFileExtention').split(",");
	
	if(folderType == "Album") {
		enableFileExtentionArr = Common.getBaseConfig('EnableFileImageExtention').split(",");
	}
	
	var html = "<tr>";
	
	var idx = 0;
	for(var i = 0; i < enableFileExtentionArr.length; i++) {
		html += "<td><input type='checkbox' id='chk_" + enableFileExtentionArr[i] + "' name='" + enableFileExtentionArr[i] + "' />" + enableFileExtentionArr[i] + "</td>";
		idx++;
		
		if(idx % 5 == 0 && idx != enableFileExtentionArr.length) {
			html += "</tr><tr>";
		} else if(idx == enableFileExtentionArr.length) {
			html += "</tr>";
		}
	}	
	
	$("#enableFileExtention").append(html);  
}

//Megabytes -> Bytes
function convertToBytes(pSize) {
	var bytes = 1024;
	return parseInt(pSize) * parseInt(bytes) * parseInt(bytes);
}

// Bytes -> MegaBytes
function convertToMegaBytes(pSize) {
	var bytes = 1024;
	return (parseInt(pSize) / parseInt(bytes) / parseInt(bytes)).toFixed(0);
}
</script>
<div>
<form id="frmBoardConfig" method="post" enctype="multipart/form-data">
	<div class="AXTabs" style="margin-bottom: 10px">
		<div class="AXTabsTray" style="height:30px">
			<a id="basicTab" class="AXTab on" value ="basic"><spring:message code="Cache.lbl_chkBasicConfigYN"/></a>
			<c:if test="${mode ne 'create'}">
				<a id="authSettingTab" class="AXTab" value="authSetting"><spring:message code="Cache.btn_AuthSet"/></a>
				<a id="basicOptionTab" class="AXTab" value="basicOption" style="display: none;"><spring:message code="Cache.lbl_BasicOptSet"/></a>
				<a id="extOptionTab" class="AXTab" value="extOption"><spring:message code="Cache.lbl_ExtOptSet"/></a>
			</c:if>
		</div>
	</div>		
	<div class="TabBox" style="margin-bottom: 20px">
		<div id="searchTab_Basic">
			<table class="AXFormTable">
				<colgroup>
					<col width="20%"/>
					<col width="30%"/>
					<col width="20%"/>
					<col width="30%"/>
				</colgroup>
				<tr style="height: 39px;">
					<th><spring:message code="Cache.lbl_Location"/></th> <!-- 폴더 위치-->
					<td colspan="3">/<span id="folerPathName">${fn:replace(folderPathName,';','/')}</span></td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_FolderType"/><font color="red"> *</font></th> <!-- 폴더 유형 -->
					<td>
						<select id="folderType" name="folderType" class="AXSelect W150" >
						</select>
					</td>
					<th>메뉴명<font color="red"> *</font></th> <!-- 메뉴명 -->
					<td> 
						<select id="selectMenuID" name="menuID" class="AXSelect W150" >
						</select>
					</td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_classNm"/><font color="red"> *</font></th> <!-- 분류명 -->
					<td colspan="3">
						<input type="text" id="folderName" name="folderName" style="width: 75%;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS" onclick="javascript:dictionaryLayerPopup('',$('#folderName'),$('#hidFolderNameDicInfo'));"/>
						<input id="hidFolderNameDicInfo" name="multiDisplayName" type="hidden" />
						<input type="button" value="<spring:message code='Cache.lbl_MultiLang2'/>" class="AXButton" onclick="javascript:dictionaryLayerPopup('',$('#folderName'),$('#hidFolderNameDicInfo'));" />
					</td>
				</tr>
				<tr>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_IsUse"/></th> <!-- 사용 여부 -->
					<td>
						<select id="selectIsUse" name="isUse" class="AXSelect">
						</select>
					</td>
					<th><spring:message code="Cache.lbl_DisplayYN"/></th> <!-- 표시 여부 -->
					<td>
						<select id="selectIsDisplay" name="isDisplay" class="AXSelect">
						</select>
					</td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_RegNotify"/></th> <!-- 등록 알림 -->
					<td>
						<select id="selectIsAdminNotice" name="isAdminNotice" class="AXSelect">
						</select>
					</td>
					<th><spring:message code="Cache.lbl_MobileSupport"/></th> <!-- 모바일 지원 -->
					<td>
						<select id="selectIsMobileSupport" name="isMobileSupport" class="AXSelect">
						</select>
					</td>
				</tr>				
				<tr>
					<th><spring:message code="Cache.lbl_RegNotify_Receiver"/></th> <!-- 등록 알림 수신자 -->
					<td colspan="3">
						<input type="text" id="ReceiversName" style="width: 74%" class="AXInput" readonly="readonly"/>
						<input type="hidden" id="ReceiversCode" />
						<input type="button" class="AXButton" value="<spring:message code="Cache.btn_Select"/>" data-target-name="ReceiversName" data-target-code="ReceiversCode" onclick="OrgMapLayerPopup(this, 'addTarget_Callback', 'D9');"/>
					</td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_RegNotify_Excepter"/></th> <!-- 등록 알림 제외자 -->
					<td colspan="3">
						<input type="text" id="ExceptersName" style="width: 74%" class="AXInput" readonly="readonly"/>
						<input type="hidden" id="ExceptersCode" />
						<input type="button" class="AXButton" value="<spring:message code="Cache.btn_Select"/>" data-target-name="ExceptersName" data-target-code="ExceptersCode"  onclick="OrgMapLayerPopup(this, 'addTarget_Callback', 'D9');"/>
					</td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_SecurityLevel"/></th> <!-- 보안등급 -->
					<td colspan="3">
						<select id="securityLevel" name="securityLevel" class="AXSelect">
						</select>
					</td>
				</tr>
				<tr>
					<th><font color="red">* </font><spring:message code="Cache.lbl_Operator"/></th> <!-- 운영자 -->
					<td colspan="3">
						<!-- 조직도 연동부분 -->
						<input type="text" id="userName" style="width: 74%" name="<spring:message code="Cache.lbl_User"/>" class="AXInput av-required" readonly="readonly"/>
						<input type="hidden" id="ownerCode" name="ownerCode" />
						<input type="button" class="AXButton" id="btnOrgMap" value="<spring:message code="Cache.btn_Select"/>" onclick="OrgMapLayerPopup_Owner();"/>
						<input type="button" class="AXButton" id="btnIntOwner" value="<spring:message code="Cache.btn_init"/>" onclick="initOwnerCode();">
					</td>
				</tr>					
				<tr style="height: 39px;">
					<th id="thRegistDate"><spring:message code="Cache.lbl_RegistDateHour"/></th> <!-- 등록일시 -->
					<td>
						<span id="registDate"></span>
					</td>
					<th><spring:message code="Cache.lbl_Register"/></th> <!-- 등록자 -->
					<td>
						<span id="registerName"></span>
					</td>
				</tr>
			</table>
		</div>
		<div id="searchTab_AuthSetting" style="margin-top:10px; display: none">
			<div class="contentsAppPop">
				<div id="con_acl">
				</div>
			</div>
		</div>
		<div id="searchTab_BasicOption" style="display: none; margin-top: 10px;">
			<span>
				<input id="chkUseBasicConfig" name="useBasicConfig" type="checkbox" onclick="javascript:selectDefaultConfig();"  />
				<spring:message code="Cache.lbl_BasicOption"/>	<!-- 기본옵션 -->
			</span>
			<table class="AXFormTable" style="margin-top: 3px; margin-bottom: 10px;">
				<colgroup>
					<col width="20%"/>
					<col width="20%"/>
					<col width="20%"/>
					<col width="20%"/>
				</colgroup>
				<tr>
	              	<td><input id="chkUsePopNotice" name="usePopNotice" type="checkbox" /><spring:message code="Cache.lbl_NoticePopup"/></td>  <!--팝업공지-->
	              	<td><input id="chkUseTopNotice" name="useTopNotice" type="checkbox" /><spring:message code="Cache.lbl_NoticeTop"/></td>  <!--상단공지-->
		          	<td><input id="chkUseExpiredDate" name="useExpiredDate" type="checkbox" /><spring:message code="Cache.lbl_ExpireDate"/></td>  <!--만료일-->
		          	<td><input id="chkUseAnony" name="useAnony" type="checkbox"  /><spring:message code="Cache.lbl_Anonymity"/></td>  <!--익명-->
		          	<td><input id="chkUseSecret" name="useSecret" type="checkbox"  /><spring:message code="Cache.lbl_chkSecurity"/></td>  <!--비밀글-->	
                   </tr>
                <tr>
                	<td><input id="chkUsePrint" name="usePrint" type="checkbox"  /><spring:message code="Cache.lbl_Print"/></td>  <!--인쇄-->
                	<td><input id="chkUseFile" name="useFile" type="checkbox" /><spring:message code="Cache.btn_attachfile"/></td>  <!--파일첨부-->
		          	<td><input id="chkUseReply" name="useReply" type="checkbox"  /><spring:message code="Cache.lbl_Reply"/></td>  	<!--답글-->
		          	<td><input id="chkUseComment" name="useComment" type="checkbox"  /><spring:message code="Cache.lbl_Comment2"/></td>  <!--덧글-->
		          	<td><input id="chkUseFavorite" name="useFavorite" type="checkbox"  /><spring:message code="Cache.lbl_Favorite"/></td>  <!--즐겨찾기-->
                   </tr>
            	<tr>
            		<td><input id="chkUseTag" name="useTag" type="checkbox"  /><spring:message code="Cache.lbl_Tag"/></td>  <!--태그-->
            		<td><input id="chkUseLink" name="useLink" type="checkbox"  /><spring:message code="Cache.lbl_Link"/></td>  <!--링크-->
            		<td><input id="chkUseMessageReadAuth" name="useMessageReadAuth" type="checkbox"  /><spring:message code="Cache.lbl_MessageReadAuth"/></td>  <!--메세지 열람 권한-->
            		<td><input id="chkUsePubDeptName" name="usePubDeptName" type="checkbox"  /><spring:message code="Cache.lbl_PubDeptName"/></td>  <!--부서명게시-->
            		<td><input id="chkUseReadCnt" name="useReadCnt" type="checkbox" /><spring:message code="Cache.lbl_DisplayHit"/></td>  <!--조회수 표시-->
				</tr>
				<tr>
				  	<td><input id="chkUseReaderView" name="useReaderView" type="checkbox" /><spring:message code="Cache.lbl_DisplayViewer"/></td>  <!--조회자 표시-->
				  	<td style="display:none;"><input id="chkUseVideo" name="useVideo" type="checkbox"  /><spring:message code="Cache.lbl_attachvideo"/></td>  <!--동영상-->
		          	<td style="display:none;"><input id="chkUseImage" name="useImage" type="checkbox" /><spring:message code="Cache.lbl_AttachImage"/></td>  <!--이미지 첨부-->
		          	<td style="display:none;"><input id="chkUseInterest" name="useInterest" type="checkbox"  /><spring:message code="Cache.lbl_IntrestBoard"/></td>  <!--관심게시-->
		          	<td style="display:none;"><input id="chkUseRecommend" name="useRecommend" type="checkbox"  /><spring:message code="Cache.lbl_Recommend"/></td>  <!--추천-->
				</tr>
			</table>
			
			<table class="AXFormTable" style="margin-bottom: 10px;">
				<colgroup>
					<col width="20%"/>
					<col width="30%"/>
					<col width="20%"/>
					<col width="30%"/>
				</colgroup>
				<%-- <tr>
						<th><font color="red">* </font><spring:message code="Cache.lbl_UploadLimit3"/></th> <!-- 업로드 용량 제한 -->
						<td><input type="text" id="txtLimitFileSize" name="limitFileSize" mode="number" allow_minus="false" style="width: 50px;" class="AXInput" />
							MB
						</td>
				</tr> --%>
				<tr>
					<th><font color="red">* </font><spring:message code="Cache.lbl_AttachCntLimit2"/></th> <!-- 첨부수 제한 -->
					<td><input type="text" id="txtLimitFileCnt" name="limitFileCnt" mode="number" allow_minus="false" style="width: 50px;" class="AXInput" />
						<spring:message code="Cache.lbl_Count"/><!-- 개 -->
					</td>
					<th><font color="red">* </font><spring:message code="Cache.lbl_LimitFileSize"/><br/><p class="maxFileSize" style="margin-left: 10px;"></p></th> <!-- 1건 첨부용량 제한 -->
					<td><input type="text" id="txtLimitFileSize" name="limitFileSize" mode="number" allow_minus="false" style="width: 50px;"/>
						MB
					</td>
				</tr>
				<tr>
					<th><font color="red">* </font><spring:message code="Cache.lbl_TotalFileSize"/><br/><p class="maxFileSize" style="margin-left: 10px;"></p></th> <!-- 총 첨부용량 제한 -->
					<td><input type="text" id="txtTotalFileSize" name="totalFileSize" mode="number" allow_minus="false" style="width: 50px;"/>
						MB
					</td>
					<th><font color="red">* </font><spring:message code="Cache.lbl_LinkCntLimit"/></th> <!-- 링크 수 제한 -->
					<td><input type="text" id="txtLimitLinkCnt" name="limitLinkCnt" mode="number" style="width: 50px;"/>
						<spring:message code="Cache.lbl_Count"/><!-- 개 -->
					</td>
				</tr>
				<tr>
					<th><font color="red">* </font><spring:message code="Cache.lbl_RecentMsgStd"/></th> <!-- 최근글 기준 -->
					<td><input type="text" id="txtRecentlyDay" name="recentlyDay" mode="number" allow_minus="false" style="width: 50px;" class="AXInput" />
						<spring:message code="Cache.lbl_day"/> <!-- 일 -->
					</td>
					<th><font color="red">* </font><spring:message code="Cache.lbl_ExpireDayStd"/><a href="#" id="updateExpiredDayBtn" style="display: block; margin-left: 10px; text-decoration: underline;" ><spring:message code="Cache.btn_board_updateExpired"/></a></th> <!-- 만료일 기준 -->
					<td><input type="text" id="txtExpireDay" name="expireDay" mode="number" style="width: 50px;" class="AXInput"/>
						<spring:message code="Cache.lbl_day"/><!-- 일 -->
					</td>
				</tr>
				<!-- TODO 사용용량 구현 (미구현 사항으로 숨김처리) -->
				<tr style="display:none;">
					<th style="display:none;"><font color="red">* </font><spring:message code="Cache.lbl_UseFileSize"/></th> <!-- 사용중인 총 용량 -->
					<td style="display:none;"><input type="text" id="txtCurrentTotalFileSize" name="currentTotalFileSize" mode="number" allow_minus="false" style="width: 50px;" class="AXInput" readonly="readonly"/>
						MB
					</td>
					<th style="display:none;"><font color="red">* </font><spring:message code="Cache.lbl_SetBoardLimitUpLoad"/></th> <!-- 게시업로드 제한용량 설정 -->
					<td style="display:none;" colspan = "3"><input type="text" id="txtBoardTotalLimitFileSize" name="boardTotalLimitFileSize" mode="number" style="width: 50px;" class="AXInput" />
						MB
					</td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_BodyBasicContents"/></th> <!-- 본문 기본 내용 -->
					<td colspan="3">
						<textarea rows="10" style="width: 90%" id="txtDefaultContents" name="defaultContents" class="AXTextarea HtmlCheckXSS ScriptCheckXSS"></textarea>
					</td>
				</tr>
			</table>
			
			<!-- 업로드 가능 확장자 -->
			<span>
				<input type="checkbox" id="chkAllFileExtention" name="allFileExtention" />
				<span><strong><spring:message code="Cache.lbl_UploadableExt"/></strong></span>
				<span style="color : #888888; float : right"><spring:message code="Cache.lbl_UploadableExtToolTip"/></span>
			</span>
			
			<table id="enableFileExtention" class="AXFormTable" style="margin-top: 3px; margin-bottom: 10px;"></table>
			
			<!-- 부가옵션 -->
			<span><strong><spring:message code="Cache.lbl_AdditionOption2"/></strong></span>
			<table class="AXFormTable" style="margin-top: 3px; margin-bottom: 3px;">
				<tr>
	              <td><input id="chkUseScrap" name="useScrap" type="checkbox"  /><spring:message code="Cache.lbl_Scrap"/></td>  <!--스크랩-->
		          <td><input id="chkUseCopy" name="useCopy" type="checkbox"  /><spring:message code="Cache.lbl_CopyOrMove"/></td>  <!--복사/이동-->
                     <td><input id="chkUseMessageAuth" name="useMessageAuth" type="checkbox"  /><spring:message code="Cache.lbl_MessageAcl"/></td>  <!--메세지 권한-->
                     <td><input id="chkUseReport" name="useReport" type="checkbox"  /><spring:message code="Cache.lbl_SinGo"/></td>  <!--신고-->
                     <td><input id="chkUseReservation" name="useReservation" type="checkbox"  /><spring:message code="Cache.lbl_ReservationReg"/></td>  <!--예약 게시-->
                     <!-- <td><input id="chkUseEvalPoint" name="useEvalPoint" type="checkbox"  /><spring:message code="Cache.lbl_EvaluPoint"/></td> -->  <!--평점-->
                     <input type="hidden" name="useEvalPoint" value="" />
				</tr>
                <tr>		          
                     <input type="hidden" name="useCommentRecommend" value="" />
                     <input type="hidden" name="useRecommendDisp" value="" />
                     <input type="hidden" name="useLogWrite" value="" />
                     <input type="hidden" name="useDefaultSecret" value="" />
				</tr>
                <tr>
                  <td><input id="chkUseSubscription" name="useSubscription" type="checkbox"   /><spring:message code="Cache.lbl_Subscription"/></td>  <!--구독-->
                     <!-- <td><input id="chkUseIncludeMaximumRead" name="useIncludeMaximumRead" type="checkbox"  /><spring:message code="Cache.lbl_IncludeMaxiumRead"/></td> -->  <!--최다 게시-->
                      <input type="hidden" name="useIncludeMaximumRead" value="" />
                     <td><input id="chkUseIncludeRecentReg" name="useIncludeRecentReg" type="checkbox"  /><spring:message code="Cache.lbl_IncludeRecentReg"/></td>  <!--최근 게시-->
                     <td><input id="chkUseLinkedMessage" name="useLinkedMessage" type="checkbox"  /><spring:message code="Cache.lbl_LinkedMessage"/></td>	<!--게시글 연결-->
                     <!-- TODO 수정요청 구현 (미구현 사항으로 숨김처리) -->
                     <td style="display:none;"><input id="chkUseModificationRequest" name="useModificationRequest" type="checkbox"  /><spring:message code="Cache.lbl_ModificationRequest"/></td><!--수정 요청-->
                     <!-- <td><input id="chkUseIncludeOverallSearch" name="useIncludeOverallSearch" type="checkbox"  /><spring:message code="Cache.lbl_IncludeOverallSearch"/></td> -->  <!--통합검색포함-->
                   	<input type="hidden" name="useModificationRequest" value="" />
                   	<input type="hidden" name="useIncludeOverallSearch" value="" />
                   </tr>
                   <tr>
                       <!-- <td><input id="chkUseCheckOut" name="useCheckOut" type="checkbox"  />CHECKOUT</td> -->  <!--체크아웃-->
                       
		            <!-- <td><input id="chkUseSendMailInBody" name="useSendMailInBody" type="checkbox"   /><spring:message code="Cache.lbl_useSendMailInBody"/></td> -->  <!--본문메일사용-->
                       <!-- <td><input id="chkUseMessageSecurityLevel" name="useMessageSecurityLevel" type="checkbox"   /><spring:message code="Cache.lbl_SecurityLevel"/></td> -->  <!--메세지 보안등급-->
                       <!-- <td><input id="chkUseMigrationToDoc" name="useMigrationToDoc" type="checkbox"/><spring:message code="Cache.lbl_usemigrationtodoc"/></td>-->  <!--문서이관사용-->
                   	<input type="hidden" name="useSendMailInBody" value="" />
                   	<input type="hidden" name="useMessageSecurityLevel" value="" />
                   	<input type="hidden" name="useCheckOut" value="" />
                   	<input type="hidden" name="useMigrationToDoc" value="" />
                   </tr>
                   <tr>
                   	<input type="hidden" name="useSatisfaction" value="" />
                   	<input type="hidden" name="useSatisfactionOrigin" value="" />
                   	<input type="hidden" name="useSatisfactionReply" value="" />
			</table>
		</div>
		<!-- 부가옵션 탭 시작 -->
		<div id="searchTab_ExtOption" style="display: none; margin-top: 10px;">
			<span><strong><spring:message code="Cache.lbl_ExtOption" /></strong></span>
			<table class="AXFormTable" style="margin-top: 3px;">
				<colgroup>
			        <col width="33%">
			        <col width="33%">
			        <col width="33%">
	          	</colgroup>
				<tbody>
					<tr type="Board">
		              	<td><input id="chkUseCategory" name="useCategory" type="checkbox"   /><spring:message code="Cache.lbl_UseCate"/></td>  <!--카테고리 사용-->
			          	<td><input id="chkUseBodyForm" name="useBodyForm" type="checkbox"   /><spring:message code="Cache.lbl_BodyForm"/></td>  <!--본문양식-->
			          	<td><input id="chkUseUserForm" name="useUserForm" type="checkbox"   /><spring:message code="Cache.lbl_UserDefField"/></td>  <!--사용자정의필드-->
						<input type="hidden" name="useProgressState" value=""/>
                    </tr>
                    <tr>
                    	<td>
                    		<input group="chkUseProcess" id="chkUseOwnerProcess" name="useOwnerProcess" onclick="boardAdmin.checkOneByUseProcessCheckBox(this);" type="checkbox"   /><spring:message code="Cache.lbl_Operator"/> 
                    		<spring:message code="Cache.lbl_UseSelApprovalProc"/>
                    	</td>
                    	<td id="divUseReplyProcess" style="display: none;">
                    		<input group="chkUseReplyProcess" id="chkUseReplyProcess" name="useReplyProcess" type="checkbox" /> 
                    		<spring:message code="Cache.lbl_UseReplyProcess"/>
                    	</td>
                    	<c:if test="${bizSection eq 'Doc'}">
							<!--문서번호 자동발번-->
	                    	<td type="Doc">
	                    		<input id="chkUseAutoDocNumber" name="useAutoDocNumber" type="checkbox" />
	                    		<spring:message code="Cache.lbl_autoDocNumber"/>
	                    	</td>
						</c:if>
                    </tr>
				</tbody>
	        </table>
	        <div id="additionalExtOptionProperties">
	        	<!-- 설정한 부가 옵션에 따라 HTML 생성되는 부분 -->
	        	<div id="divCategory" class="div_wrap" style="padding-top:15px;">
					<span><strong><spring:message code="Cache.lbl_Category"/></strong></span> <!--카테고리-->
					<table class="AXFormTable">
						<colgroup>
			            	<col width="20%">
			            	<col width="80%">
		              	</colgroup>
		              	<tbody>
		                	<tr>
			                  	<td><spring:message code="Cache.lbl_LCate"/></td>  <!--대분류-->
								<td>
									<table style="width: 100%">
										<tr>
											<td>
	                                      		<select id="selectLargeCategory" name="LargeCategory" class="AXSelect" onchange="javascript:selectSmallCategoryList();"></select>
	                                      		<input type="button" value="<spring:message code="Cache.lbl_Add"/>" onclick="javascript:dictionaryLayerPopup('create', $('#selectLargeCategory'),$('#hidLargeCateName'));"  class="AXButton"/>
	                                      		<input type="button" value="<spring:message code="Cache.lbl_Edit"/>" onclick="javascript:editLargeCategory();"  class="AXButton"/>
	                                      		<input type="button" value="<spring:message code="Cache.lbl_delete"/>" onclick="javascript:deleteCategory($('#selectLargeCategory'));"  class="AXButton"/>
												<input type="hidden" id="hidLargeCateName" />
											
												<div id="largeCateOperator" class="cateOperator">
													<input type="text" style="width: 85%;" id="hidLargeCategoryManagerName" name="hidLargeCategoryManagerName" disabled="disabled" />
													<input type="hidden" id="hidLargeCategoryManagerCode" name="hidLargeCategoryManagerCode" />
													<input type="button" value="<spring:message code="Cache.btn_charge"/>" onclick="OrgMapLayerPopup_CategoryManager('SetLargeCateOperator');" class="AXButton"/>
												</div>
	                                      	</td>
	                                  	</tr>
	                              	</table>
	                            </td>
	                        </tr>
	                        <tr>
				              	<td><spring:message code="Cache.lbl_SCate"/></td>  <!--소분류-->
				              	<td>
				              		<table style="width: 100%">
	                                 	<tr>
	                                     	<td>
	                                     		<select id="selectSmallCategory" name="SmallCategory" class="AXSelect"></select>
	                                   			<input type="button" value="<spring:message code="Cache.lbl_Add"/>" onclick="javascript:createSmallCategory();"  class="AXButton"/>
	                                     		<input type="button" value="<spring:message code="Cache.lbl_Edit"/>" onclick="javascript:editSmallCategory();"  class="AXButton"/>
	                                     		<input type="button" value="<spring:message code="Cache.lbl_delete"/>" onclick="javascript:deleteCategory($('#selectSmallCategory'));"  class="AXButton"/>
	                                     		<input type="hidden" id="hidSmallCateName" />
	                                     	
	                                     		<div id="smallCateOperator" class="cateOperator">
													<input type="text" style="width: 85%;" id="hidSmallCategoryManagerName" name="hidSmallCategoryManagerName" disabled="disabled" />
													<input type="hidden" id="hidSmallCategoryManagerCode" name="hidSmallCategoryManagerCode" />
													<input type="button" value="<spring:message code="Cache.btn_charge"/>" onclick="OrgMapLayerPopup_CategoryManager('SetSmallCateOperator');" class="AXButton"/>
												</div>
	                                    	 </td>
	                                  	</tr>
	                            	</table>
	                         	</td>
			                </tr>
						</tbody>
		            </table>
	        	</div>
	        	<div id="divBodyForm" class="div_wrap" style="padding-top:15px;">
	        		<span><strong><spring:message code="Cache.lbl_BodyForm" /></strong> (<spring:message code="Cache.msg_DisplayInitFormonChk" /> / <spring:message code='Cache.msg_uploadBodyFormFile' />)</span> <!--본문양식--> <!--체크시 초기 작성양식으로 보여집니다.-->
                    <!-- 본문양식 Display 시작 -->
                    <div>
                        <table class="pop_option_t" cellpadding="0" cellspacing="0">
                            <tr>
			                    <td style="Padding-top:5px;">
			                    	<div class="topbar_grid">
                                    	<span id="spnBodyFormList"></span>
                                    </div>
                                </td>
                            </tr>
                        </table>
		            </div>
                    <!-- 본문양식 Display 종료 -->
		            <table class="AXFormTable" cellpadding="0" cellspacing="0">
						<colgroup>
							<col width="11%">
			            	<col width="35%">
			            	<col width="8%">
		              	</colgroup>
		              	<tbody>
		                	<tr>
			                  	<th><spring:message code="Cache.lbl_FormNm"/></td>  <!--양식명-->
				              	<td colspan="2">
				              		<input id="txtBodyFormName" name="bodyFormName" type="text" class="AXInput HtmlCheckXSS ScriptCheckXSS" style="width: 80%;">
				              		<input id="hidBodyFormDicInfo" type="hidden" />
				              		<input type="button" value="<spring:message code='Cache.lbl_MultiLang2'/>" class="AXButton" onclick="javascript:dictionaryLayerPopup('', $('#txtBodyFormName'), $('#hidBodyFormDicInfo'));" /><!--다국어-->
				              	</td>  
			              	</tr>
			               	<tr>
				              	<th><spring:message code="Cache.lbl_FormFile"/></td>  <!--명시파일-->
				              	<td colspan="2" id="tdUpload">
									<input type="file" id="uploadFile" accept=".txt,.htm,.html" style="width: 80%;" onchange="bodyFormCheckFileName(this.value);"/>
									<input type="button" value="<spring:message code="Cache.lbl_Add"/>" onclick="javascript:createBodyForm();" class="AXButton"/>
								</td>
			                </tr>
	                  	</tbody>
		            </table>
		            <span style="padding-top:5px; display:block"><spring:message code="Cache.msg_BodyFormMsg01"/></span>
				</div>
	        	<div id="divUserDefField" class="div_wrap" style="padding-top:15px;">
	        		<span><strong><spring:message code="Cache.lbl_UserDefField"/></strong></span>
	            	<!-- 상단 버튼과 간격 조절 -->
	            	<div >
		            	<div id="userDefFieldGrid" class="ztable_list"></div>
		            </div>
		            <div style="float:left; padding: 5px 0 5px 0;">
	        			<input type="button" value="<spring:message code='Cache.btn_UP'/>" class="AXButton" onclick="javascript:moveUserDefField('up');" /><!--순서-->
	            		<input type="button" value="<spring:message code='Cache.btn_Down'/>" class="AXButton" onclick="javascript:moveUserDefField('down');" /><!--순서-->
	            	</div>
		            <div style="float:right; padding: 5px 0 5px 0;">
	                   	<input type="button" value="<spring:message code='Cache.btn_init'/>" class="AXButton" onclick="javascript:resetUserDefField();" /><!-- 초기화 -->
	                   	<input type="button" id="btnAddField" value="<spring:message code='Cache.btn_AddField'/>" class="AXButton" onclick="javascript:setUserDefField('create');" /><!-- 추가 -->
	                   	<input type="button" id="btnEditField" value="<spring:message code='Cache.btn_EditField'/>" class="AXButton" style="display:none;" onclick="javascript:setUserDefField('edit');" /><!-- 수정 -->
	                   	<!-- <input type="button" value="<spring:message code='Cache.btn_AddOpt'/>" class="AXButton" onclick="javascript:addOption();" /> --><!-- 옵션 추가 -->
	                   	<input type="button" value="<spring:message code='Cache.lbl_DeleteField'/>" class="AXButton" onclick="javascript:deleteUserDefField();" /><!-- 삭제 -->
		            </div>
	                <table class="AXFormTable" cellpadding="0" cellspacing="0">
		              <colgroup>
			            <col width="15%">
			            <col width="35%">
			            <col width="15%">
			            <col width="35%">
		              </colgroup>
		              <tbody>
		                <tr>
		                  <th><spring:message code="Cache.lbl_FieldNm"/></th>  <!--필드명-->
			              <td>
			              	<input id="fieldName" name="fieldName" type="text" class="AXInput HtmlCheckXSS ScriptCheckXSS" >
			              	<input id="hidFieldNameDicInfo" type="hidden" />
			              	<input type="button" value="<spring:message code='Cache.lbl_MultiLang2'/>" class="AXButton" onclick="javascript:dictionaryLayerPopup('',$('#fieldName'),$('#hidFieldNameDicInfo'));" />
			              </td>  <!--다국어-->
			              <th><spring:message code="Cache.lbl_FieldType"/></th>  <!--필드 유형-->
			              <td>
			              	<select id="fieldType" class="AXSelect" onchange="boardAdmin.changeFieldType(this)">
			              		<option value="Input">Input</option>
			              		<option value="TextArea">TextArea</option>
			              		<option value="Radio">RadioButton</option>
			              		<option value="CheckBox">CheckBox</option>
			              		<option value="DropDown">DropDownList</option>
			              		<option value="Date">DateField</option>
			              	</select>
							<span id="spanFieldLimitCnt">
								<input id="fieldLimitCnt" type="text" class="AXInput" mode="number" allow_minus="false" style="width:30px;"/><spring:message code="Cache.lbl_Char"/>
							</span>
						   </td>
			              <!-- <td><a href="javascript:UploadFrontStorageByBodyForm();" id="aUploadFrontStorageByBodyForm"><em class="btn_bs_l"><span class="btn_bs_r"><strong class="txt_btn_bs"><spring:message code="Cache.lbl_FileUpload"/></strong></span></em></a></td> -->  <!--파일업로드-->
		                </tr>
		                <tr id="rowFieldOption" style="display:none;">
		                	<th><spring:message code="Cache.lbl_FieldOpt"/></th><!-- 필드옵션 -->
		                	<td colspan="3">
	                			<div id="optionPlaceHolder">
	                			</div>
		                	</td>
		                </tr>
		                <tr>
		                	<th><spring:message code="Cache.lbl_surveyIsRequire"/></th><!-- 필수여부 -->
		                	<td><select id="isCheckVal" class="AXSelect">
		                			<option value="N" selected><spring:message code="Cache.lbl_NoIsRequire"/></option>
		                			<option value="Y"><spring:message code="Cache.lbl_apv_require"/></option>
		                		</select> 
		                	</td>
		                	<th><spring:message code="Cache.lbl_ViewField"/></th><!-- 필드보기 -->
		                	<td><select id="fieldSize" class="AXSelect">
		                			<option value="Line">Line</option>
		                			<option value="Half">Half</option>
		                			<option value="2Line">2Line</option>
		                			<option value="3Line">3Line</option>
		                			<option value="4Line">4Line</option>
		                			<option value="5Line">5Line</option>
		                		</select> 
		                	</td>
		                </tr>
		                <tr>
		                	<th><spring:message code="Cache.lbl_DisplayList"/></th><!-- 목록표시 -->
		                	<td><select id="isList" class="AXSelect">
		                			<option value="N" selected><spring:message code="Cache.lbl_NonDisplay"/></option>
		                			<option value="Y"><spring:message code="Cache.lbl_Display2"/></option>
		                		</select> 
		                	</td>
		                	<th>검색항목</th><!-- 검색항목 -->
		                	<td><select id="isSearchItem" class="AXSelect">
		                			<option value="Y"><spring:message code="Cache.lbl_Display2"/></option>
		                			<option value="N" selected><spring:message code="Cache.lbl_NonDisplay"/></option>
		                		</select> 
		                	</td>
		                </tr>
	                  </tbody>
		            </table>
	        	</div>
	        	<!-- 승인 프로세스 설정 -->
	        	<div id="divApprovalProcSet" class="div_wrap" style="padding-top:15px;">
	        		<span><strong><spring:message code="Cache.lbl_ApprovalProcSet"/></strong></span>
	                <p style="float:right;padding-bottom:5px;">
	                   	<input type="button" value="&lt; <spring:message code='Cache.lbl_Order'/>" class="AXButton" onclick="javascript:moveLeftApprover();" /><!--순서-->
	                   	<input type="button" value="<spring:message code='Cache.lbl_Order'/> &gt;" class="AXButton" onclick="javascript:moveRightApprover();" /><!--순서-->
	                   	<input type="button" value="<spring:message code='Cache.lbl_Add'/>" class="AXButton" onclick="OrgMapLayerPopup_approvalLine();" /><!--추가-->
	                </p>
	                <table style="border:1px solid #d4d4d4;width:100%;" cellpadding="0" cellspacing="0">
	                    <tr>
				            <td>
				            	<div>
	                            	<span id="spnApprovalLine"></span>
	                            </div>
	                        </td>
	                    </tr>
	                </table>
	            </div>
	            <!-- 진행상태 -->
	        	<div id="divProgressState" class="div_wrap" style="padding-top:15px;">
	        		<span><strong><spring:message code="Cache.lbl_ProgressState"/></strong></span> <!--카테고리-->
		            <table class="AXFormTable">
		              <colgroup>
			            <col width="20%">
			            <col width="80%">
		              </colgroup>
		              <tbody>
		                <tr>
		                  <td><spring:message code="Cache.lbl_ProgressState"/></td>  <!--진행상태-->
			              <td>
                              <table>
                                  <tr>
                                      <td>
                                      	<select id="selectProgressState" name="ProgressState" class="AXSelect W100" ></select>
                                      	<input type="button" value="<spring:message code="Cache.lbl_Add"/>" onclick="javascript:dictionaryLayerPopup('create', $('#selectProgressState'),$('#hidProgressStateName'));"  class="AXButton"/>
                                      	<input type="button" value="<spring:message code="Cache.lbl_Edit"/>" onclick="javascript:dictionaryLayerPopup('edit', $('#selectProgressState'),$('#hidProgressStateName'));"  class="AXButton"/>
                                      	<input type="button" value="<spring:message code="Cache.lbl_delete"/>" onclick="javascript:deleteProgressState($('#selectProgressState'));"  class="AXButton"/>
                                      </td>
                                  </tr>
                              </table>
                              <input type="hidden" id="hidProgressStateName" />
                            </td>
                        </tr>
                        </tbody>
                       </table>
	        	</div>
	        </div>
		</div>
		<!-- 부가옵션 탭 종료 -->
	</div>
	<div align="center" style="padding-top: 20px">
		<!-- <input type="button" id="btn_preview" value="<spring:message code="Cache.lbl_PreviewUserDefField"/>" onclick="peviewUserDefField();" class="AXButton" style="display:none;"/> -->
		<input type="button" id="btn_add" value="<spring:message code="Cache.btn_Add"/>" onclick="setBoardConfig();" class="AXButton red"/>
		<input type="button" id="btn_modify" value="<spring:message code="Cache.btn_Edit"/>" onclick="setBoardConfig();" class="AXButton red"/>
		<input type="button" value="<spring:message code="Cache.btn_Close"/>" onclick="closeLayer();"  class="AXButton"/>
	</div>
	<input type="hidden" id="hidContentsID" value="" />	<!-- boardDescription ID -->
	<input type="hidden" id="hidUserFormID" value="" /> <!-- UserFormID -->
	<input type="hidden" id="hidProcessID" value="" />
	<input type="hidden" id="hidMemberOf" value="" />
</form>	
</div>
