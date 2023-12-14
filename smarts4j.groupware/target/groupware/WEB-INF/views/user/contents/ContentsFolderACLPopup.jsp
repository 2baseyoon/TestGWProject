<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil,egovframework.coviframework.util.RedisDataUtil,egovframework.baseframework.util.SessionHelper"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld"%>
<% 
	String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
	//간편관리자 사용 여부에 따라 설정하기
	String useEasyAdmin = "N";
	if (RedisDataUtil.getBaseConfig("BoardEasyAdmin").equals("Y") && SessionHelper.getSession("isEasyAdmin").equals("Y"))
		useEasyAdmin = "Y"; 
%>
<!doctype html>
<html lang="ko">

<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

	<!-- 컨텐츠앱 추가 -->
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/contentsApp/resources/css/contentsApp.css">
	
	<script type="text/javascript" src="/groupware/resources/script/admin/boardAdmin.js<%=resourceVersion%>"></script>
<body>	
	<div class="layer_divpop contentsAppPop" style="width:870px; left:0; top:0; z-index:104;">
		<div class="caContent">

<form id="frmBoardConfig" method="post" enctype="multipart/form-data">
			<div id="con_acl"></div>
		
			<div class="bottomBtnWrap">
				<a href="javascript:setBoardConfig();" class="btnTypeDefault btnTypeBg"><spring:message code='Cache.btn_save'/></a>
				<a href="javascript:closeLayer();" class="btnTypeDefault"><spring:message code='Cache.btn_Cancel'/></a>
			</div>
			
		<input type="hidden" id="hidContentsID" value="" />	<!-- boardDescription ID -->
		<input type="hidden" id="hidUserFormID" value="" /> <!-- UserFormID -->
		<input type="hidden" id="hidProcessID" value="" />
		<input type="hidden" id="hidMemberOf" value="" />
</form>

		</div>
	</div>
</body>
</html>
<script type="text/javascript">

var bizSection = "Board";
var mode = "${mode}";
var folderID = "${folderID}"; // Create모드: 상위 폴더의 ID, Edit모드: 현재 선택된 게시판의 FolderID
var menuID = "${menuID}";
var communityID = "${CommunityID}";
var domainID = Common.getSession("DN_ID");
var isContentsApp = "${isContentsApp}";

var userDefFieldGrid = new coviGrid();
var lang = Common.getSession("lang");

var g_aclList = ""; // 권한 설정 ACL List, 추후 팝업호출시 해당 폴더의 권한 정보 조회
var g_optionIndex = "";	// 사용자 정의 필드 옵션을 다국어 처리하기 위한 전역 변수
var g_isRoot = false;
var g_hasChild = false;		// 자식 객체 존재 여부
var g_isInherited = false;	// 권한 상속 여부

//팝업 게시판 설정
var setBoardConfig = function(){
		
	if(folderID){
		var url;
		var param;
		
		//폴더/게시판 정보 수정	
		url = "/groupware/contents/updateFolderACL.do";
		
		var bodyFormId = $("input[name=chkBodyForm]:checked")[0] != undefined? $("input[name=chkBodyForm]:checked")[0].value:"";
		
		//권한 설정정보 
//		var aclList = encodeURIComponent(coviACL_getACLData("con_acl"));
//		var aclActionList = encodeURIComponent(coviACL_getACLActionData("con_acl"));
		
		var aclInfo = coviACL_getACLData('con_acl');
		var aclIsChange = aclInfo.aclIsChange;
		var aclList = aclInfo.aclData;
		var aclActionList = coviACL_getACLActionData('con_acl');
		
		
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
		paramObject["aclIsChange"] = aclIsChange;				//권한 변경 여부
		paramObject["aclList"] = encodeURIComponent(aclList);	//권한 설정 정보
		paramObject["aclActionList"] = encodeURIComponent(aclActionList);		//권한 설정 정보
		paramObject["communityID"] = communityID;
		paramObject["ownerCode"] = $("#ownerCode").val();
		
		// tab별 체크되지 않은 체크박스 항목 별도 참조 
		$("#searchTab_BasicOption input[type=checkbox]:not(:checked)").each(function(){ paramObject[this.name]=null; });
		$("#searchTab_ExtOption input[type=checkbox]:not(:checked)").each(function(){ paramObject[this.name]=null; });
		param = paramObject;
		
		//param.MessageTarget = getMessageTarget();
		
		$.ajax({
			type: "POST",
			url: url,
			dataType: 'json',
			data: param,
			success: function(data){
				if(data.status=='SUCCESS'){
					Common.Inform("<spring:message code='Cache.msg_37'/>", "Information", function(){ // 저장되었습니다.
						Common.Close();
					});
				}else{
					Common.Warning("<spring:message code='Cache.msg_sns_03'/>"); // 저장 중 오류가 발생하였습니다.
				}
			}, 
			error: function(error){
				Common.Warning("<spring:message code='Cache.msg_sns_03'/>"); // 저장 중 오류가 발생하였습니다.
			}
		});
	}
}

var selectBoardConfig = function(){
	$.ajax({
		type: "POST",
		url: "/groupware/board/manage/selectBoardConfig.do",
		dataType: 'json',
		async: false,
		data: {
			"folderID": folderID,
			"domainID": domainID
		},
		success: function(data){
			var config = data.config;
			
			g_isRoot = (config.FolderType === "Root");
			$("#hidMemberOf").val(config.MemberOf);
			$("#folderType").val(config.FolderType);
			
			//조회된 정보로 화면에 이벤트 셋팅
			for(var key in config) {
				//Use로 시작되는 항목은 전부 체크박스 처리
				if (/^Use/.test(key)) {
					config[key] == "Y" ? $("#chk" + key).prop('checked', true) : $("#chk" + key).prop('checked', false);
				} else if (/^Is/.test(key)) {
					//is로 시작되는 항목은 전부 selectbox처리
					$("#select" + key).val(config[key] + "");
				} else {
					$("#txt" + key).val(config[key]);
				}
			}
			
			$("#selectMenuID").val(config.MenuID).prop("disabled", true);
			
			//다국어 표시명이 없을 경우 분기 처리
			var displayName = CFN_GetDicInfo(config.MultiDisplayName);	
			if(displayName && displayName != "undefined"){
				$("#hidFolderNameDicInfo").val(config.MultiDisplayName);
				$("#folderName").val(displayName);
			} else {
				$("#folderName").val(config.DisplayName);
			}
			
			$("#thRegistDate").text($("#thRegistDate").text() + Common.getSession("UR_TimeZoneDisplay"));
			$("#ownerCode").val(config.OwnerCode);
			$("#registDate").text(CFN_TransLocalTime(config.CreateDate));
			$("#registerName").text(CFN_GetDicInfo(config.RegisterName));
			$("#description").val(config.Description);
			$("#securityLevel").val(config.SecurityLevel);
			
			if(config.OwnerCode != ""){ // 담당자가 설정됐을 경우 담당자 이름 검색하여 표시
				selectBoardOwnerName(config.OwnerCode);
			}
			
			if(config.IsURL == "Y"){ // 연결URL 사용시 URL값 설정
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
    		
			if (config.IsContents == "Y"){
				$("#chkUseUserForm").attr("disabled",true);
				$("#divUserDefField").show();
	        	$("#divUserDefField div").hide();
	        	$("#divUserDefField table").hide();
	        	$("#divUserDefField strong").html("<a href='/groupware/contents/ContentsUserForm.do?folderID="+folderID+"' target='_blank' style='color:red;display:inline-block;padding-bottom:10px'>contents app 에서 확인</a>");
		        
			}else{	
	    		if(config.UseUserForm == "Y"){ // 확장옵션설정 탭: 사용자정의필드 사용시 Grid 데이터 조회
					setUserDefFieldGrid();
				}	
			}
			
			if(config.IsMobileSupport != "Y"){ // 모바일지원 null 일경우 비사용 표시
				$("#selectIsMobileSupport").val("N");
			}
			
			$("#folerPathName").text(config.FolderPathName.replaceAll(";","/"));
		}, 
		error: function(response, status, error){
			CFN_ErrorAjax("/groupware/board/manage/selectBoardConfig.do", response, status, error);
		}
	});
}

//권한 설정 탭 내부 UI 표시
var renderACL = function(){
	var option = {
		lang : lang, 
		hasItem : 'false', 
		allowedACL :  '',
		orgMapCallback : 'orgCallback',
		aclCallback : 'aclCallback',
		communityId : communityID,
		orgGroupType : "Basic|Board"
	};
	
	if (!g_isRoot) {
		option["useInherited"] = true;
		option["inheritedFunc"] = "selectInheritedACL";
	}
	
	coviACL = new CoviACL(option);
	coviACL.render('con_acl');
	
	<%if (useEasyAdmin.equals("Y")){ %>	//간편관리여부
		$("#con_acl_hTblAcl").hide();
		$("#con_acl_divControls").hide();
	<%}%>
	$("#con_acl_divControls [type=button]").hide();	 // 사용하지 않는 버튼 숨김처리
}

//조직도 Callback
function orgCallback(data){
	var orgJson = $.parseJSON(data);
	var bCheck = false;
	var sObjectType = "";
	var sObjectType_A = "";
	var sObjectTypeText = "";
	var sCode = "";
	var sDNCode = "";
	var sDisplayName = "";
	var lang = Common.getSession("lang");
	
	$.each(orgJson.item, function(i, item){
		sObjectType = item.itemType;
		
		if(sObjectType.toUpperCase() == "USER"){ //사용자
			sObjectTypeText = "사용자";
			sObjectType_A = "UR";
			sCode = item.AN;//UR_Code
			sDisplayName  = CFN_GetDicInfo(item.DN, lang);
			sDNCode = item.ETID;; //DN_Code
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
}

//화면에 설정된 ACL 데이터 출력
var aclCallback = function(data){
	g_aclList = data;
}

//상위 권한 상속
var selectInheritedACL = function(){
	$.ajax({
		url: "/groupware/board/manage/selectBoardACLData.do",
		type: "POST",
		async: false,
		data: {
			  "objectID": $("#hidMemberOf").val()
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
					
					if (!exist.includes(true)) {
						var acl = {
							  "AN": item.SubjectCode
							, "DN_Code": item.CompanyCode
							, "AclList": item.AclList
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
					}
				});
				
				var jsonData = {"item": aclList, "isInHerited": true, "inheritedObjectID": $("#hidMemberOf").val()};
				
				coviACL.addSubjectRow(JSON.stringify(jsonData));
			}
		},
		error: function(error){
			CFN_ErrorAjax("/groupware/board/manage/selectBoardACLData.do", response, status, error);
		}
	});
}

var checkIsInherit = function(){
	$("#con_acl_hTbdPermissions").html("");
	g_aclList = "";
	
	//권한 표시항목 및 aclList변수 초기화
	selectBoardACLData();
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
    	success:function(res){
        	$("#con_acl_hTbdPermissions").html("");
    		coviACL.set(res.data);
    	}, 
  		error:function(error){
  			CFN_ErrorAjax("admin/boardManage.do", response, status, error);	//CHECK 확인 필요 
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
  			CFN_ErrorAjax("admin/boardManage.do", response, status, error);	//CHECK 확인 필요 
  		}
    });
}

//등록알림 수신자, 제외자에 대한 데이터 처리
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

$(document).ready(function(){
	selectBoardConfig(); // 폴더 옵션 조회
	renderACL(); // 권한 설정 탭 내부 오브젝트 표시
	checkIsInherit(); // 권한 아이템 조회
});

</script>