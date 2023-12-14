<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<style>
	.cRConTop h2.title {
		width: 450px;
		overflow: hidden;
		text-overflow: ellipsis;
		white-space: nowrap;
	}
	
	#selectFolderID {
		width: 170px !important;
	}
</style>

<div class="individualAdminInfoBox">
	<div class="personBox individualPersonBox" style="height: 60px;">
		<div class="perPhoto" id="cuPhoto"></div>
		<p class="name">
			<span class="sysop" id="sop"></span>
			<span class="nicName mt10"><strong id="CNicnm"></strong></span>
			<span class="sysPosition mt5" id="CPosition"></span>								
		</p>	
	</div>
	<div class="individualAdminInfoMenu" id="subInfoMenu">
		<a class="btnIndividualAdminInfoMenu"></a>
		<ul class="individualAdminInfoMenuList" id="individualAdminInfoMenuList">
			<li class="individualAdminInfoMenuList01"><a onclick="goCommunityInfo()"><spring:message code='Cache.lbl_CommunityInfo'/></a></li>
			<li class="individualAdminInfoMenuList02"><a onclick="goInviteCommunity()"><spring:message code='Cache.lbl_CommunityIsInvited'/></a></li>
		</ul>
	</div>
	<p>
		<select class="selectType02 mt15" id="selectJoinCommunity">
		</select>
	</p>
</div>
<div class="individualMemberInfo" id="memberIndividual">
	<a class="btnType01 " id="memberList"  onclick="goCommunityUserInfo()"><spring:message code='Cache.lbl_User_Info'/></a>
	<a class="btnType01 " style="display: none;" id="memberJoin" onclick="goMoveJoin()"><spring:message code='Cache.lbl_User_Join'/></a>
	<a class="btnType01 " style="display: none;" id="tfinfo" onclick="goTFInfo()"><spring:message code='Cache.lbl_TFInfo'/></a>
	<!-- 프로젝트 참여 버튼 -->
	<a class="btnType01 " style="display: none; margin-top: 2px;" id="joinProject" onclick="approvalJoinTf()"><spring:message code='Cache.lbl_tf_app_for_participation'/></a>
</div>
<div class="individualLnbMenuBox" id="CM8" style="display:none;">
	<h3><spring:message code='Cache.lbl_activitymng'/></h3>
	<ul class="indLnbMyMenuList">
		<li><a onclick="goCommunityLMenu('Activity')"><spring:message code='Cache.lbl_all_Activity'/></a></li>
		<li style="display:none;"><a onclick="goCommunityLMenu('Task')"><spring:message code='Cache.lbl_Activity'/></a></li>
		<li><a onclick="goCommunityLMenu('MyTask')"><spring:message code='Cache.lbl_myActivity'/></a></li>
		<li style="display:none;"><a onclick="goCommunityLMenu('Progress')"><spring:message code='Cache.lbl_ProgressReport'/></a></li>
		<li><a onclick="goCommunityLMenu('Gantt')"><spring:message code='Cache.lbl_ProgressReport'/></a></li>
	</ul>
</div>
<div class="individualLnbMenuBox mt10" id="CM9" style="display: none">
	<h3><spring:message code='Cache.lbl_Additional_Menus'/></h3>
	<ul class="indLnbMyMenuList">
		<li><a onclick="goCommunityLMenu('ManagerView')"><spring:message code='Cache.lbl_collaboration_mng'/></a></li>
		<li><a onclick="goCommunityLMenu('PrintMain')"><spring:message code='Cache.lbl_collaboration_info_print'/></a></li>
		<li><a onclick="goCommunityLMenu('TFClose')"><spring:message code='Cache.lbl_closeCollabRoom'/></a><input type="hidden" id="closeComment" /></li>
	</ul>
</div>
<c:if test="${memberLevel > '0' or (memberLevel eq '0' and communityType eq 'P')}">
	<div class="individualLnbMenuBox" id="CM1" >
		<h3><spring:message code='Cache.lbl_Boards'/></h3>
		<div class="treeList radio radioType04 " id='coviTree_FolderMenu' style='height:210px;border-top: 1px solid #e0e0e0;overflow: auto;'>
		</div>
	</div>
</c:if>

<c:if test="${memberLevel > '0'}">
	<div class="individualLnbMenuBox mt10" id="CM2">
		<h3><spring:message code='Cache.lbl_MyMenu'/></h3>
		<ul class="indLnbMyMenuList" id="myBoardMenu">
			<li><a onclick="myBoardList('MW')"><spring:message code='Cache.lbl_MyWriteMsg'/></a></li>
			<li><a onclick="myBoardList('OW')"><spring:message code='Cache.lbl_OnWritingBoard'/></a></li>
			<li><a onclick="myBoardList('MB')"><spring:message code='Cache.lbl_MyBookingList'/></a></li>
			<li><a onclick="myBoardList('MS')"><spring:message code='Cache.lbl_Scrap'/></a></li> 
		</ul>
	</div>
			
	<div class="individualLnbMenuBox mt10" id="CM3">
		<h3><spring:message code='Cache.btn_extmenu'/></h3>
		<ul class="indLnbMyMenuList">
			<li><a onclick="goCommunityLMenu('SW')"><spring:message code='Cache.MN_110'/></a></li>
			<li><a onclick="goCommunityLMenu('SLC')"><spring:message code='Cache.MN_113'/></a></li>
			<li><a onclick="goCommunityLMenu('SLT')"><spring:message code='Cache.lbl_title_surveyName_01'/></a></li>
		</ul>	
	</div>
</c:if>		
				
<c:if test="${memberLevel eq '9' || (hasAdminAuth eq 'Y' && callByAdmin eq 'Y')}">
	<div class="individualLnbMenuBox mt10" id="CM4">
		<h3><spring:message code='Cache.lbl_OperatingMenu'/></h3>
		<ul class="indLnbMyMenuList">
			<li><a onclick="goCommunityLMenu('CMM')"><spring:message code='Cache.lbl_User_Manager'/></a></li>
			<li><a onclick="goCommunityLMenu('CHM')"><spring:message code='Cache.lbl_Home_Settings'/></a></li>
			<li><a onclick="goCommunityLMenu('CIM')"><spring:message code='Cache.lbl_cafeInfoManage'/></a></li>
			<li><a onclick="goCommunityLMenu('CAM')"><spring:message code='Cache.lbl_PartiMgr'/></a></li>
			<li><a onclick="goCommunityLMenu('CCA')"><spring:message code='Cache.lbl_ClosureApplication'/></a></li>
		</ul>
	</div>
</c:if>
<c:if test="${memberLevel > '0'}">
	<div class="individualLnbMenuBox mt10 alliance" id="CM5">
		<h3><spring:message code='Cache.lbl_AffiliateCommunity'/></h3>
		<div>
			<div class="personBox individualPersonBox " id="allianceCommunityList">
			</div>
		</div>
	</div>
	<div class="individualLnbMenuBox mt10 latestVisitorCont" id="CM6">
		<h3><spring:message code='Cache.lbl_Latest_User'/></h3>
		<ul class="latestVisitorList" id="visitList"></ul>
	</div>
</c:if>	
<c:if test="${memberLevel > '0' and memberLevel ne '9'}">
	<div class="individualLnbMenuBox mt10 leaveMemberBox" id="CM7">
		<a class="btnLeaveMember" onclick="MemberLeave()"><span><spring:message code='Cache.TodoMsgType_Withdrawal'/></span></a>
	</div>
</c:if>


<script type="text/javascript">
var memberLevel = '${memberLevel}';
var myCommunityFolderTree = new coviTree();

var aStrDictionary = Common.getDicAll(["lbl_ACL_Allow","lbl_ACL_Denial","lbl_User","lbl_company","lbl_group"]);
var sessionObj = Common.getSession(); //전체호출
var lang = sessionObj["lang"];
var boxType = (CFN_GetQueryString("boxType") == "undefined"? "Receive" : CFN_GetQueryString("boxType")); //Request, Receive

var left_orgMenuID = "";
var left_orgFolderID = "";

var body = { 
	onclick:function(idx, item){ //[Function] 바디 클릭 이벤트 콜백함수
		
		if(item.itemType != "Root"  && item.itemType != "Folder" ){
			goFolderContents("Board", item.MenuID, item.FolderID, item.FolderType, "1");
		}
		
	}
};


$(function(){	
	setLeft();
	
	XFN_removeWindow("community");
	XFN_addWindowOpenList(location.pathname + location.search, "community");
});	

function setLeft(){
	var lURL = "/groupware/layout/selectUserJoinCommunity.do";
	var lLabel = Common.getDic("lbl_MyCommunity");
	
	if(cType=="T"){
		lURL = "/groupware/layout/selectUserJoinTF.do";
		lLabel = Common.getDic("lbl_mytf");
	}
	
	$("#selectJoinCommunity").coviCtrl("setSelectOption", 
			lURL, 
			{},
			lLabel,
			""
	);
	
	$('.btnIndividualAdminInfoMenu').on('click', function(){
		var displaCont = $('.individualAdminInfoMenuList');
		if(displaCont.hasClass('active')){
			displaCont.removeClass('active');
		}else {
			displaCont.addClass('active');
		}
	});
	$("#selectJoinCommunity").change(function(){
		if($("#selectJoinCommunity").val() != "" ){
			location.href = "/groupware/layout/userCommunity/communityMain.do?C="+$("#selectJoinCommunity").val();
		}
	});
	
	communityUserInfo();
	communityBoardLeft();
	if(cType=="C"){ //2019.11 일반커뮤니티일때만 호출
		allianceList();
		visitList();
	}
	myBoardList();
}

function communityUserInfo(){
	var lURL = "/groupware/layout/userCommunity/communityLeftUserInfo.do";
	
	if(cType=="T"){
		lURL = "/groupware/layout/userTF/TFLeftUserInfo.do";
	}
	
	$.ajax({
		url:lURL,
		type:"POST",
		async:false,
		data:{
			communityID: cID
		},
		success:function (r) {
			if(r.list.length > 0){
				$(r.list).each(function(i,v){
					if(v.MemberLevel != null && v.MemberLevel != ''){
						var _memberLevel = v.MemberLevel;
						if ('${hasAdminAuth}' == 'Y' && '${callByAdmin}' == 'Y') {
							_memberLevel += '('+Common.getDic('lbl_admin')+')'
						}
						$("#sop").html(_memberLevel);
					}else{
						$("#subInfoMenu").hide();
						$("#sop").html(Common.getDic("CuMemberLevel_0") + (('${hasAdminAuth}' == 'Y' && '${callByAdmin}' == 'Y') ? '('+Common.getDic('lbl_admin')+')' : ''));
					}
					$("#CNicnm").html(v.DisplayName);
					$("#CPosition").html("");
					$("#cuPhoto").html("<img src='"+coviCmn.loadImage(sessionObj["PhotoPath"])+"' onerror='coviCmn.imgError(this);'  style='width:100%;height:100%;' alt='"+"<spring:message code='Cache.lbl_ProfilePhoto'/>"+"'>");
					
					if (v.GroupCode != "") {
						if (window.sessionStorage.getItem("communityGroupCode") == null) {
							window.sessionStorage.setItem("communityGroupCode", v.GroupCode);
						}
					}
					
				});
			}else{
				$("#subInfoMenu").hide();
				$("#sop").html(Common.getDic("CuMemberLevel_0") + (('${hasAdminAuth}' == 'Y' && '${callByAdmin}' == 'Y') ? '('+Common.getDic('lbl_admin')+')' : ''));
				$("#CNicnm").html(r.USERNAME);
				$("#CPosition").html("");
				$("#cuPhoto").html("<img src='"+coviCmn.loadImage(sessionObj["PhotoPath"])+"' onerror='coviCmn.imgError(this, true);' style='width:100%;height:100%;' alt='"+"<spring:message code='Cache.lbl_ProfilePhoto'/>"+"'>");
				
				//프로젝트 참여신청 메일 발송
				if(cType == "T"){
					$("#joinProject").show(); 
				}
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax(lURL, response, status, error); 
		}
	}); 
}

function communityBoardLeft(){
	var str = "";	
	var lURL = "/groupware/layout/userCommunity/communityBoardLeft.do";
	if(cType=="T"){
		lURL = "/groupware/layout/userTF/TFBoardLeft.do";
	}
	
	$.ajax({
		url:lURL,
		type:"POST",
		data:{
			CU_ID : cID
		},
		async:true,
		success:function (b) {
			if(b.flag){
				$("#CM1,#CM2,#CM3,#CM4,#CM5,#CM7").show();
				
				if(cType=="C"){
					$("#CM6").show();
				}
			}else{
				// 비회원인데 공개형 커뮤니티일 경우 게시판 트리를 보여줌				
				if(b.communityType == "P") {
					$("#CM2,#CM3,#CM4,#CM5,#CM6,#CM7").hide();	
				} else {
					$("#CM1,#CM2,#CM3,#CM4,#CM5,#CM6,#CM7").hide();
					$("#coviTree_FolderMenu").html("");	
				}
			}
						
			if(b.memberLevel == "9" || ('${hasAdminAuth}' == 'Y' && '${callByAdmin}' == 'Y')){
				$("#CM4,#memberList").show();
				$("#memberJoin").hide();
				$("#CM7").hide();
			}else if(b.memberLevel != null &&  b.memberLevel !="" &&  b.memberLevel !="0"){
				$("#CM1,#CM2,#CM3,#CM5,#CM6,#CM7,#memberList").show();
				$("#CM4,#memberJoin").hide();
			}else if(b.memberLevel == "0"){
				$("#CM4,#memberJoin,#memberList,#subInfoMenu").hide();
				$("#CPosition").html("("+Common.getDic("lbl_WaitingCommunity")+")");
			}else{
				$("#CM4,#memberList").hide();
				if(cType=="T"){
					$("#memberJoin").hide();
				}else{
					$("#memberJoin").show();
				}
			}	
			
			if(cType=="T"){
				$("#CM4,#CM5,#CM7").hide();
				$("#subInfoMenu,#memberList").hide();
				$("#tfinfo").show();
				$("#CM1").addClass("mt10");
				if(b.memberLevel == "9" || b.memberLevel == "8" ){
					$("#CM8,#CM9").show();
	    			$("#inTM").html("<a href='#' onclick='setTopMenu();' class='btnIndividualOption ml5'></a>");
				}else if(b.memberLevel != null &&  b.memberLevel !="" &&  b.memberLevel !="0"){
					$("#CM8").show();
				}
			}		
			
			var memberLevel = b.memberLevel;
			
			if(b.flag || (!b.flag && b.communityType == "P")){
				var List = b.list;
				myCommunityFolderTree.setTreeList("coviTree_FolderMenu", List, "nodeName", "170", "left", true, true, body);
				myCommunityFolderTree.expandAll(1);
				if(memberLevel == "9"){
					 myCommunityFolderTree.setConfig({contextMenu:{
						theme:"AXContextMenu", // 선택항목
			            width:"150", // 선택항목
			            menu:[
			                {
			                    userType:1, label:"<spring:message code='Cache.lbl_new'/>", className:"plus", onclick:function(){
									ctxCreateBoardPopup(this.sendObj.MenuID, this.sendObj.FolderID);
			                    }
			                },
			                {
			                    userType:2, label:"<spring:message code='Cache.lbl_delete'/>", className:"minus", onclick:function(){
			                    	ctxDeleteBoard(this.sendObj.MenuID, this.sendObj.FolderID);
			                    }
			                },
			                {
			                    userType:0, label:"<spring:message code='Cache.lbl_Property'/>", className:"edit", onclick:function(){
			                    	ctxEditBoardPopup(this.sendObj.MenuID, this.sendObj.FolderID);
			                    }
			                },
			                {
			                    userType:1, label:"<spring:message code='Cache.lbl_paste'/>", className:"paste", onclick:function(){
			                    	ctxPasteBoard(this.sendObj.MenuID, this.sendObj.FolderID, this.sendObj.FolderPath, this.sendObj.SortPath);
			                    }
			                },
			                {
			                    userType:2, label:"<spring:message code='Cache.lbl_Cut'/>", className:"cut", onclick:function(){
			                    	ctxCutBoard(this.sendObj.MenuID, this.sendObj.FolderID, this.sendObj.SortPath, this.sendObj.FolderPath);
			                    }
			                },
			                
			            ],
			            filter:function(id){
			            	if(this.sendObj.FolderType == 'Root'){
			                	return (this.menu.userType == 0 || this.menu.userType == 1);
			            	} else if (this.sendObj.FolderType =='Folder'){
			            		return true;
			                } else {
			                	return (this.menu.userType == 0 || this.menu.userType == 2);
			                } 
			            }
			        }}); 
				}
			}			
		},
		error:function (error){
			CFN_ErrorAjax(lURL, response, status, error);
		}
	}).done(function(data){
		setTimeout(function(){
			$.each(data.list,function(idx, el){
				if (el.IsUse == 'N') {
					$("#coviTree_FolderMenu #folder_item_"+el.no).css("text-decoration", "line-through")
				}
			})
		}, 200);
		
	});
	myCommunityFolderTree.displayIcon(true);
	myCommunityFolderTree.clearFocus(); 
	
}

function keyTrigger(){
	var E = $.Event("keydown");
	E.which = 27;
	E.keyCode = 27;
	$(document).trigger(E);
}

//추가 버튼에 대한 레이어 팝업
function ctxCreateBoardPopup(pMenuID, pFolderID){
	if (typeof(bizSection) == "undefined") {
		Common.open("","createBoard","<spring:message code='Cache.lbl_BoardConfigSet'/>|||<spring:message code='Cache.lbl_FolderAdd'/>","/groupware/board/manage/goFolderManagePopup.do?folderID="+pFolderID+"&menuID="+pMenuID+"&mode=create&CommunityID="+cID+"&domainID="+dnID+"&bizSection=Community","750px","675px","iframe",false,null,null,true, 'UA');
	} else {
		Common.open("","createBoard","<spring:message code='Cache.lbl_BoardConfigSet'/>|||<spring:message code='Cache.lbl_FolderAdd'/>","/groupware/board/manage/goFolderManagePopup.do?folderID="+pFolderID+"&menuID="+pMenuID+"&mode=create&CommunityID="+cID+"&domainID="+dnID+"&bizSection="+bizSection,"750px","675px","iframe",false,null,null,true, 'UA');
	}
	
}

function ctxEditBoardPopup(pMenuID, pFolderID){
	if (typeof(bizSection) == "undefined") {
		Common.open("","editBoard","<spring:message code='Cache.lbl_BoardConfigSet'/>|||<spring:message code='Cache.lbl_FolderModify'/>","/groupware/board/manage/goFolderManagePopup.do?folderID="+pFolderID+"&menuID="+pMenuID+"&mode=edit&CommunityID="+cID+"&domainID="+dnID+"&bizSection=Community","750px","675px","iframe",false,null,null,true, 'UA');
	} else {
		Common.open("","editBoard","<spring:message code='Cache.lbl_BoardConfigSet'/>|||<spring:message code='Cache.lbl_FolderModify'/>","/groupware/board/manage/goFolderManagePopup.do?folderID="+pFolderID+"&menuID="+pMenuID+"&mode=edit&CommunityID="+cID+"&domainID="+dnID+"&bizSection="+bizSection,"750px","675px","iframe",false,null,null,true, 'UA');	
	}
}

//context 삭제 - API는 동일하지만 Param처리 및 Page가 동일 하지 않으므로 분리 하여 구현
function ctxDeleteBoard(pMenuID, pFolderID){
	Common.Confirm("<spring:message code='Cache.msg_Common_08'/>", 'Confirmation Dialog', function (result) {       // 선택한 항목을 삭제하시겠습니까?
        if (result) {
           $.ajax({
           	type:"POST",
           	url:"/groupware/board/manage/deleteBoard.do",
           	data:{
               	"menuID": pMenuID,
           		"folderID":pFolderID
           	},
           	success:function(data){
           		if(data.status=='SUCCESS'){
           			Common.Warning("<spring:message code='Cache.msg_50'/>", "Warning Dialog", function () {// 삭제되었습니다.
							communityBoardLeft(); //page reload
    				});
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


function goCommunityInfo(){
	mActiveKey = "1";
	
	$("li[class^='inCommMenu0']").removeClass("active");
	$("li[class='inCommMenu01']").addClass("active");
	
	$("#individualAdminInfoMenuList").removeClass('active');
	
	var url = "/groupware/layout/userCommunity/communityMovePage.do?move=CommunityInfo&C="+cID;
	CoviMenu_GetContent(url);
	moveScroll();
}

function goCommunityLMenu(op){
	
	mActiveKey = "1";
	
	$("li[class^='inCommMenu0']").removeClass("active");
	$("li[class='inCommMenu01']").addClass("active");
	
	var url = "";
	if(op == "SW"){
		url="/groupware/layout/survey_SurveyWrite.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&reqType=create&surveyId=&CSMU=C&communityId="+cID;
	}else if(op == "SLC"){
		url="/groupware/layout/survey_SurveyList.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&reqType=complete&CSMU=C&communityId="+cID;
	}else if(op == "SLT"){
		url="/groupware/layout/survey_SurveyList.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&reqType=tempSave&CSMU=C&communityId="+cID;
	}else if(op == "CMM"){
		url="/groupware/layout/community_CommunityMemberManage.do?CLSYS=community&CLMD=user&CLBIZ=Community&CSMU=C&communityId="+cID;
	}else if(op == "CIM"){
		url="/groupware/layout/community_CommunityInfoManage.do?CLSYS=community&CLMD=user&CLBIZ=Community&CSMU=C&communityId="+cID;
	}else if(op == "CAM"){
		url="/groupware/layout/community_CommunityAllianceManage.do?CLSYS=community&CLMD=user&CLBIZ=Community&CSMU=C&communityId="+cID;
	}else if(op == "CCA"){
		url="/groupware/layout/community_CommunityClosingManage.do?CLSYS=community&CLMD=user&CLBIZ=Community&CSMU=C&communityId="+cID;
	}else if(op == "CHM"){
		url="/groupware/layout/community_CommunityHomeManage.do?CLSYS=community&CLMD=user&CLBIZ=Community&CSMU=CU&communityId="+cID+"&part=Y";	
	}else if(op == "Activity"){
		url="/groupware/layout/community_TFActivityList.do?CLSYS=community&CLMD=user&CLBIZ=CommunityF&CSMU=C&communityId="+cID;
	}else if(op == "Task"){
		url="/groupware/layout/community_TFTaskList.do?CLSYS=community&CLMD=user&CLBIZ=Community&CSMU=C&communityId="+cID;
	}else if(op == "MyTask"){
		url="/groupware/layout/community_TFMyTaskList.do?CLSYS=community&CLMD=user&CLBIZ=Community&CSMU=C&communityId="+cID;
	}else if(op == "Progress"){
		url="/groupware/layout/community_TFProgress.do?CLSYS=community&CLMD=user&CLBIZ=Community&CSMU=C&communityId="+cID;
	}else if(op == "ManagerView"){
		url="/groupware/layout/community_TFManagerView.do?CLSYS=community&CLMD=user&CLBIZ=Community&CSMU=C&communityId="+cID;
	}else if(op == "PrintMain"){
		url="/groupware/layout/community_TFPrintMain.do?CLSYS=community&CLMD=user&CLBIZ=Community&CSMU=C&communityId="+cID;
	}else if(op == "Gantt"){
		url="/groupware/layout/community_TFProgressGantt.do?CLSYS=community&CLMD=user&CLBIZ=Community&CSMU=C&communityId="+cID;
	}else if(op == "TFClose") {

	}
	
	if (op == 'TFClose') {
		//mode: delete
		parent._CallBackMethod = new Function("deleteTFRoom()");
		parent.Common.open("", "commentPopup", Common.getDic('lbl_ReasonForProcessing'), "/groupware/tf/goCommentPopup.do?mode=delete", "285px", "200px", "iframe", true, null, null, true);
	} else if(op != 'CHM') {
		CoviMenu_GetContent(url);
	}else{
		var contentUrl = url + "&fragments=content";
		var state = CoviMenu_makeState(url);
		var title = url; 
		history.pushState(state, title, url);
		CoviMenu_SetState(state)
		
		part = 'Y';
		
		//content
		$.ajax({
	        type : "GET",
	        beforeSend : function(req) {
	            req.setRequestHeader("Accept", "text/html;type=ajax");
	        },
	        url : contentUrl,
	        success : function(res) {
	        	
	        	$("#portContent").html(res);
	        },
	        error : function(response, status, error){
				CFN_ErrorAjax(contentUrl, response, status, error);
	        }
	    });	
	
	}
	moveScroll();
}

function visitList(){
	var str = "";	
	$("#CM6").show();
	
	$.ajax({
		type:"POST",
		url:"/groupware/layout/userCommunity/communityVisitList.do",
		async:true,
		data:{
			CU_ID : cID
		},
		success:function (c) {
			if(c.list.length > 0){
				$(c.list).each(function(i,v){
					str += "<li><a href='#' class='btnFlowerName' onclick='coviCtrl.setFlowerName(this)' style='position:relative;cursor:pointer' data-user-code='"+ v.UserCode +"' data-user-mail=''>"+v.DisplayName+"</a></li>";
				});
			}
			$("#visitList").html(str);
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/userCommunity/communityVisitList.do", response, status, error); 
		}
	}); 
}

function goMoveJoin(){
	var url = "/groupware/layout/userCommunity/communityMovePage.do?move=CommunityJoin&C="+cID;
	CoviMenu_GetContent(url);
	moveScroll();
}

function MemberLeave(){
	var url = "/groupware/layout/userCommunity/communityMovePage.do?move=CommunityMemberLeave&C="+cID;
	CoviMenu_GetContent(url);
	moveScroll();
}

function goCommunityUserInfo(){
	mActiveKey = "1";
	
	$("li[class^='inCommMenu0']").removeClass("active");
	$("li[class='inCommMenu01']").addClass("active");
	
	var url = "/groupware/layout/userCommunity/communityMovePage.do?move=CommunityMemberJoinInfo&C="+cID;
	CoviMenu_GetContent(url);
	moveScroll();
}

function goInviteCommunity(){
	$("#individualAdminInfoMenuList").removeClass('active');
	
	var url = "";
	url += "/groupware/layout/userCommunity/InviteCommunity.do?"+"CU_ID="+cID;
		
	Common.open("", "InvitePopup", "커뮤니티 초대", url, "470px", "340px", "iframe", true, null, null, true);
}

function allianceList(){
	var str = "";
	//var backStroage = String.format(Common.getBaseConfig("BackStorage"), Common.getSession("DN_Code"));
	
	$.ajax({
		type:"POST",
		url:"/groupware/layout/userCommunity/communityAllianceList.do",
		async:true,
		data:{
			communityID : cID
		},
		success:function (al) {
			if(al.list.length > 0){
				$(al.list).each(function(i,v){
					str += String.format('<p class="name" style="cursor: pointer;" onclick="goCommunityMove('+"'{0}'"+')">', v.communityID);
					str += "<span class='mt10'>"+v.CommunityName+"</span>";
					str += "</p>";
				});
			}
			
			$("#allianceCommunityList").html(str); 
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/userCommunity/communityAllianceList.do", response, status, error); 
		}
	}); 
}

function goCommunityMove(communityID){
	location.href = "/groupware/layout/userCommunity/communityMain.do?C="+communityID;
}

function myBoardList(type){
	var url = "";
	
	mActiveKey = "1";
	
	$("li[class^='inCommMenu0']").removeClass("active");
	$("li[class='inCommMenu01']").addClass("active");
	
	
	if(type == "MW"){
		url = "/groupware/layout/board_BoardList.do?CLSYS=board&CLMD=User&CLBIZ=Board&boardType=MyOwnWrite&CSMU=C&communityId="+cID
	}else if(type == "OW"){
		url = "/groupware/layout/board_BoardList.do?CLSYS=board&CLMD=User&CLBIZ=Board&boardType=OnWriting&CSMU=C&communityId="+cID
	}else if(type == "RM"){
		url = "/groupware/layout/board_BoardList.do?CLSYS=board&CLMD=User&CLBIZ=Board&boardType=RequestModify&CSMU=C&communityId="+cID
	}else if(type == "MB"){
		url = "/groupware/layout/board_BoardList.do?CLSYS=board&CLMD=User&CLBIZ=Board&boardType=MyBooking&CSMU=C&communityId="+cID
	}else if(type == "MS"){
		url = "/groupware/layout/board_BoardList.do?CLSYS=board&CLMD=User&CLBIZ=Board&boardType=Scrap&CSMU=C&communityId="+cID
	}	
	
	CoviMenu_GetContent(url);
	moveScroll();
}

//context 잘라내기 클릭
function ctxCutBoard(pMenuID, pFolderID) {
    left_orgMenuID = pMenuID; 
    left_orgFolderID = pFolderID;
    Common.Inform("<spring:message code='Cache.msg_TempSaveCuttingFolder'/>");   //잘라낼 폴더를 임시 저장했습니다
}

//context 붙여넣기 클릭
function ctxPasteBoard(pMenuID, pFolderID, pFolderPath, pSortPath){
	if (left_orgFolderID == "") {
        Common.Inform("<spring:message code='Cache.msg_NoCuttedFolder'/>");  //잘라낸 폴더가 없습니다
        return;
    }
	
	$.ajax({
		type:"POST",
		url:"/groupware/board/manage/pasteBoard.do",
		data:{
			"orgMenuID": left_orgMenuID,
			"orgFolderID": left_orgFolderID,
			"targetMenuID": pMenuID,
			"targetFolderID": pFolderID,
			"targetFolderPath": pFolderPath,
			"targetSortPath": pSortPath
		},
		success:function(data){
			Common.Warning("<spring:message code='Cache.msg_Processed'/>", "Warning Dialog", function () {
				inCommMenu();
				communityBoardLeft();
			}); 
		},
		error:function(error){
			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");
		}
	});
}

function goTFInfo(){
	mActiveKey = "1";
	
	$("li[class^='inCommMenu0']").removeClass("active");
	$("li[class='inCommMenu01']").addClass("active");
	$("#individualAdminInfoMenuList").removeClass('active');
	
	var url = "/groupware/layout/userCommunity/communityMovePage.do?move=TFInfo&C="+cID;
	CoviMenu_GetContent(url);
	moveScroll();
}

function approvalJoinTf(obj){
	Common.Confirm("<spring:message code='Cache.msg_tf_mail_send_confirm'/>","Confirm",function(result){ // 업무 참여신청 메일을 발송 하시겠습니까?
		if(result){
			$.ajax({
				url:"/groupware/layout/selectTFDetailInfo.do",
				type:"POST",
				async:false,
				data:{
					CU_ID : cID
				},
				success:function (data) {
					if(data.status == "SUCCESS"){
						var info = data.TFInfo[0];
						
						var projectNm = $(obj).data("projectnm");
						var userNm = CFN_GetDicInfo(Common.getSession("UR_MultiName"));
						var userMail = Common.getSession("UR_Mail");
						
						var arrTo = []; // 받는 사람
						var receiver = new Object();
						receiver['UserName']	= info.TF_PM.split("|")[1];
						receiver['MailAddress'] = info.TF_PM_MAIL;
						arrTo.push(receiver);
						
						var specs  = "left=10,top=10,width=1050,height=900";
							specs += ",toolbar=no,menubar=no,status=no,scrollbars=no,resizable=no";
						var contentLink  = "<a href='/groupware/layout/userCommunity/communityMain.do?C="+cID+"' ";
							contentLink += "onclick='window.open(this.href,\"community\",\""+specs+"\"); return false;'>";
							contentLink += projectNm;
							contentLink += "</a>";
						var content = String.format(Common.getDic("msg_TFJoinMail_Content"),userNm,projectNm,contentLink);
						var text = content.replace(/\\n/gi,'</br>');
						
						var params = {
							"subject" : String.format("<spring:message code='Cache.msg_TFJoinMail_Subject'/>",projectNm,userNm)	//제목
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
					        	if(data.msgType === "noAuth"){
					        		Common.Warning(Common.getDic("msg_notHaveAccess"), Common.getDic("CPMail_warning_msg"));  //접근 권한 없습니다
	                        	}else{								
									if(data.resultTy == "S"){
										Common.Inform("<spring:message code='Cache.msg_tf_mail_send_ok'/>");	//참여신청 되었습니다.
									}
	                        	}
							},
							error:function(response, status, error) {
								CFN_ErrorAjax("/mail/userMail/simpleMailSent.do", response, status, error);
							}
						});
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/groupware/layout/selectTFDetailInfo.do", response, status, error); 
				}
			});
		}
	});
}

function deleteTFRoom() {
	$.ajax({
		url: "/groupware/layout/userCommunity/setCommunityStatus.do",
		type: "post",
		data: {
			"CU_ID": cID,
			"RegStatus": "R",
			"AppStatus": "UV",
			"txtOperator": Common.getSession('UserCode'),
			"ClosingMsg":$("#closeComment").val()
		},
		success: function(data){
			if(data.status == "SUCCESS"){
				Common.Inform("<spring:message code='Cache.msg_ProcessOk'/>", "Inform", function(){ // 요청하신 작업이 정상적으로 처리되었습니다.
					window.close();
				});
			}else{
				Common.Inform("<spring:message code='Cache.msg_ErrorOccurred'/>"); // 오류가 발생하였습니다.
			}
		},
		error: function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/userCommunity/setCommunityStatus.do", response, status, error);
		}
	});
}
</script>