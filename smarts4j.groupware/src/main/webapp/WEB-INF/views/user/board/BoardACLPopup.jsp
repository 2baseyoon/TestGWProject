<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil,egovframework.coviframework.util.RedisDataUtil,egovframework.baseframework.util.SessionHelper"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<style type="text/css">	
table {
    table-layout: auto;
}
#con_acl .authPermissions table tr td:nth-child(9) { 
	border-right: 1px dashed #ddd;
}

#con_acl .authPermissions table tr td:nth-child(10) { 
	border-right: 1px dashed #ddd;
}
</style>
<div>
	<form id="frmBoardConfig" method="post" enctype="multipart/form-data">
		<div class="sadmin_pop">
			<div id="searchTab_AuthSetting">
				<div class="contentsAppPop">
					<div id="con_acl"></div>
				</div>
			</div>
			<div class="bottomBtnWrap">
				<a href="#" class="btnTypeDefault btnTypeBg" onclick="javascript:confirmACLSetting();"><spring:message code="Cache.btn_Confirm"/></a>
				<a href="#" class="btnTypeDefault" onclick="javascript:btnClose_Click();"><spring:message code="Cache.btn_Cancel"/></a>
			</div>
		</div>
	</form>
</div>
<script type="text/javascript">
var selectedACL = null;
var UseMessageAuth = null;
var messageAuth = null;
var IsInherited = null;
var lang = Common.getSession("lang");

var g_aclList = ""; 		// 권한 설정 ACL List, 추후 팝업호출시 해당 폴더의 권한 정보 조회
var g_isRoot = false;
var g_isInherited = false;	// 권한 상속 여부

$(document).ready(function (){
	if(parent != null && parent.$("#UseMessageAuth").val() != "undefined" && parent.$("#messageAuth").val() != "undefined" && parent.$("#IsInherited").val() != "undefined"){
		UseMessageAuth = parent.$("#UseMessageAuth");
		messageAuth = parent.$("#messageAuth");
		IsInherited = parent.$("#IsInherited");
	} else {
		UseMessageAuth = opener.$("#UseMessageAuth");
		messageAuth = opener.$("#messageAuth");
		IsInherited = opener.$("#IsInherited");
	}
	
	g_isInherited = IsInherited.val() == "Y" ? true : false;
	renderACL();
	setMessageACL();
});

// 권한 설정 탭 내부 UI 표시
var renderACL = function(){
	var option = {
		lang : lang, 
		hasButton : 'false', 
		hasItem : 'false', 
		allowedACL : 'SCDME_R',
		orgMapCallback : 'orgCallback',
		aclCallback : 'aclCallback',
		orgGroupType : "Basic|Board",
		inheritedTooltip : 'N',
		useInherited : false,
		inheritedFunc : "selectInheritedACL",
		systemType : "Message"
		
		/*
		objectID : parent.messageID,
		objectType : "MSG"
		*/
	};
	
	coviACL = new CoviACL(option);
	coviACL.render('con_acl');

	$("#con_acl_divControls [type=button]").hide();	 // 사용하지 않는 버튼 숨김처리
}

// 화면에 설정된 ACL 데이터 출력
var aclCallback = function(data){
	g_aclList = data;
}

// 메시지 권한 세팅
var setMessageACL = function(){
	$("#con_acl_hTbdPermissions").html("");
	
	if(messageAuth.val() != ""){
		var acl = $.parseJSON(messageAuth.val());
		
		$(acl).each(function(idx, item){		
			item.AclList = getConvertMessageACL(item.AclList);
			item.Security = item.AclList.charAt(0);
			item.Create = item.AclList.charAt(1);
			item.Delete = item.AclList.charAt(2);
			item.Modify = item.AclList.charAt(3);
			item.Execute = item.AclList.charAt(4);
			item.View = item.AclList.charAt(5);
			item.Read = item.AclList.charAt(6);
			item.SubjectType = item.TargetType;
			item.SubjectCode = item.TargetCode;
			item.SubjectName = item.DisplayName;
		});
		
		coviACL.set(acl);
	}
}

// 폴더 권한 상속
var selectInheritedACL = function(){
	$.ajax({
		url: "/groupware/board/manage/selectBoardACLData.do",
		type: "POST",
		async: false,
		data: {
			  "objectID": parent.$("#selectFolderID").val()
			, "objectType": "FD"
		},
		success: function(res){
			if (res.status === "SUCCESS") {
				var aclList = [];
				var exAclList = JSON.parse(coviACL_getACLData("con_acl").aclData);
				
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
						, "View": "_"
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
				
				var jsonData = {"item": aclList, "isInHerited": true, "inheritedObjectID": parent.$("#selectFolderID").val()};
				
				// 모든 하이라이트 해제
				$('.aclSubject').css("background-color", "inherit");
				$('.aclSubject').removeAttr("data-clicked");
				
				coviACL.addSubjectRow(JSON.stringify(jsonData));
				setAuthSetting(jsonData.item);
			}
		},
		error: function(error){
			CFN_ErrorAjax("/groupware/board/manage/selectBoardACLData.do", response, status, error);
		}
	});
}

// 권한 데이터 가져오기
function getACLData(){
	var aclArray = [];
	var aclData = $.parseJSON(coviACL_getACLData("con_acl").aclData);
	
	$(aclData).each(function(i, item) {		
		var aclShard = "";
		aclShard += item.AclList.charAt(0);
		aclShard += item.AclList.charAt(1);
		aclShard += item.AclList.charAt(2);
		aclShard += item.AclList.charAt(3);
		aclShard += item.AclList.charAt(4);
		aclShard += item.AclList.charAt(6);
		
		var ACL = new Object();
		ACL.AclList = aclShard;
		ACL.TargetType = item.hasOwnProperty("TargetType") ? item.TargetType : item.SubjectType;
		ACL.TargetCode = item.hasOwnProperty("TargetCode") ? item.TargetCode : item.SubjectCode;
		ACL.DisplayName = item.hasOwnProperty("DisplayName") ? item.DisplayName : getDisplayName(ACL.TargetCode);
		ACL.IsSubInclude = item.IsSubInclude;
		ACL.InheritedObjectID = item.hasOwnProperty("InheritedObjectID") ? (item.InheritedObjectID == "" ? 0 : item.InheritedObjectID) : 0;
		aclArray.push(ACL);
	});
	
	return JSON.stringify(aclArray);
}

// 메시지 권한 폴더권한 형식으로 변경
function getConvertMessageACL(AclList){
	var aclShard = "";
	
	aclShard += AclList.charAt(0);
	aclShard += AclList.charAt(1);
	aclShard += AclList.charAt(2);
	aclShard += AclList.charAt(3);
	aclShard += AclList.charAt(4);
	aclShard += "_";
	aclShard += AclList.charAt(5);
	
	return aclShard;
}

function getDisplayName(pTargetCode){
	var displayName = "";
	
	$('#con_acl_hTbdPermissions').find('tr').each(function(){
		if ($(this).attr("objectcode") == pTargetCode) {
			displayName = $(this).attr("displayname");
		}
	});
	
	return displayName;
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
			sCode = item.AN;//UR_Code
			sDisplayName = CFN_GetDicInfo(item.DN, lang);
			sDNCode = item.ETID; //DN_Code
		}else{ //그룹
			switch(item.GroupType.toUpperCase()){
				case "COMPANY":
					sObjectTypeText = "회사";
					sObjectType_A = "CM";
					break;
				case "JOBLEVEL":
					sObjectTypeText = "직급";
					sObjectType_A = "JL";
					break;
				case "JOBPOSITION":
					sObjectTypeText = "직위";
					sObjectType_A = "JP";
					break;
				case "JOBTITLE":
					sObjectTypeText = "직책";
					sObjectType_A = "JT";
					break;
				case "MANAGE":
					sObjectTypeText = "관리";
					sObjectType_A = "MN";
					break;
				case "OFFICER":
					sObjectTypeText = "임원";
					sObjectType_A = "OF";
					break;
				case "DEPT":
					sObjectTypeText = "부서"; // 그룹
					sObjectType_A = "GR";
					break;
			}
			
			sCode = item.AN
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

// 확인
function confirmACLSetting(){
	var aclList = getACLData();
	
	if($.parseJSON(aclList).length > 0){
		UseMessageAuth.val("Y");
		messageAuth.val(aclList);
	} else {
		UseMessageAuth.val("N");
		messageAuth.val("");
	}
	
	IsInherited.val($("#con_acl_isInherited").is(":checked") ? "Y" : "N");	
	Common.Close();
}

// 닫기
function btnClose_Click(){
	Common.Close();
}
</script>