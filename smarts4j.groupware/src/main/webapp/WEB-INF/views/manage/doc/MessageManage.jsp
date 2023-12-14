<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld"%>
<%
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="/groupware/resources/script/admin/boardAdmin.js<%=resourceVersion%>"></script>

<script type="text/javascript">
// grid용 다국어
Common.getDicList(["lbl_no2", "lbl_BoardCate2", "lbl_subject", "lbl_State2", "lbl_Register", "lbl_attach", "lbl_RegistDate", "lbl_ExpireDate",
	"lbl_Registor", "lbl_Approval", "lbl_Rejected", "lbl_Lock", "lbl_RegistReq", "lbl_TempSave", "lbl_expiration", "lbl_delete"]);

var bizSection = "Doc";
var boardType = "Normal";
var sessionObj = Common.getSession();

var confDoc = {
	lowerMsgGrid: new coviGrid(),	// 게시글 Grid 
	folderGrid: new coviTree(),		// 폴더 Grid
	msgHeaderData: [ 
		         	{key:'chk', label:'chk', width:'1', align:'center', formatter: 'checkbox'},
		        	{key:'Version',  label:'Ver', width:'3', align:'center', 
		        		formatter:function(){
		        			return boardAdmin.formatVersion(this);
		        		}
		        	},
		        	{key:'Subject',  label:coviDic.dicMap["lbl_subject"], width:'15', align:'left',
		        		formatter:function(){ 
		        			return boardAdmin.formatSubjectName(this);
		        		}
		        	},
		        	{key:'Number',  label:"<spring:message code='Cache.lbl_apv_DocNo'/>", width:'7', align:'center'}, // 문서번호
		        	{key:'IsCheckOut',  label:"<spring:message code='Cache.lbl_CheckOut'/>", width:'2', align:'center',
		        		formatter:function(){ //체크아웃
		        			return boardAdmin.formatCheckOut(this);
		        		}
		        	},
		        	{key:'MsgStateDetail',  label:coviDic.dicMap["lbl_State2"], width:'5', align:'center',
		        		formatter:function(){ 
		        			return boardAdmin.formatMessageState(this); 
		        		}
		        	},
		        	{key:'RegistDept', label:"<spring:message code='Cache.lbl_RegistDept'/>",width:'7', align:'center',
		        		formatter: function(){ return this.item.RegistDeptName;
		        	}}, //등록부서
		        	{key:'OwnerName',  label:"<spring:message code='Cache.lbl_Owner'/>", width:'5', align:'center' }, //소유자
		        	{key:'RevisionDate', label:"<spring:message code='Cache.lbl_RevisionDate'/>" + Common.getSession("UR_TimeZoneDisplay"), width:'7', align:'center', sort:'desc', formatter: function(){
						return CFN_TransLocalTime(this.item.RevisionDate);
					}}, //개정일
		        ],
	domainID: confMenu.domainId,
	initContent: function(){
		$("#chk_IsAll").click(function(){
			confDoc.setFolderTreeData();
		});
		// 새로고침
		$("#btnRefresh").on('click', function(){
			if (confDoc.folderGrid.selectedRow[0]) {
				var selItem = confDoc.folderGrid.list[confDoc.folderGrid.selectedRow[0]];
				
				confDoc.setMessageGridList(selItem.FolderID, selItem.FolderName);
			}
		});
		
		$("#selectPageSize").on('change', function(){
			if (confDoc.folderGrid.selectedRow[0]) {
				var selItem = confDoc.folderGrid.list[confDoc.folderGrid.selectedRow[0]];
				
				confDoc.setMessageGridList(selItem.FolderID, selItem.FolderName);
			}
		});
		
		//검색
		$("#treeSearchText").on('keydown', function(event){
			if(event.keyCode === 13){
				event.preventDefault();
				$('#treeSearchBtn').trigger('click');
			}
		});
		
		$("#treeSearchBtn").on('click', function(){
			var keyword = $("#treeSearchText").val();
			if (keyword == ""){
				confDoc.setFolderTreeData();
				return;
			}
			/* 엔터나 클릭을 이용해 검색조건에 맞는 폴더나 문서함을 탐색하면서 해당 폴더, 문서함에 대한 문서들을 조회 */ 
			var curIdx = Number(confDoc.folderGrid.selectedRow)+1;
			confDoc.folderGrid.findKeywordData("FolderName", keyword, true, false, curIdx);
		});
		
		$("#searchText, #searchDetailText").on('keydown', function(){
			if(event.keyCode == "13"){
				confDoc.setMessageGridList($('#hiddenFolderID').val(), $('#hiddenFolderName').val());
			}
		});
		
		$("#icoSearch, #btnSearch").on('click', function(){
			confDoc.setMessageGridList($('#hiddenFolderID').val(), $('#hiddenFolderName').val());
		});
		
		//상세 검색
		$('.btnDetails').off('click').on('click', function(){
			var mParent = $('.inPerView');
			if(mParent.hasClass('active')){
				mParent.removeClass('active');
				$(this).removeClass('active');
			}else {
				mParent.addClass('active');
				$(this).addClass('active');
			}
			coviInput.setDate();
		});
		
		this.setMessageGridConfig();
		
		this.folderGrid.setConfig({
			targetID: "folderGrid",			// HTML element target ID
			theme: "AXTree_none",
			colGroup: [{
				key: "FolderName",			// 컬럼에 매치될 item 의 키
				indent: true,				// 들여쓰기 여부
				label: '<spring:message code="Cache.lbl_BoardNm"/>',
				width: "280",
				align: "left",
				getIconClass: function(){	// indent 속성 정의된 대상에 아이콘을 지정 가능
					var sRetIcon;
   					if (this.item.FolderType=="Root" || this.item.FolderType=="Folder")
   						sRetIcon = "ic_folder ";
   					else {
   						sRetIcon = "ic_file ";
   						if (this.item.IsContents == "Y") sRetIcon += "icon20";
   					}	
					 if (this.item.IsUse == "N" || this.item.IsDisplay == "N") sRetIcon += "icon02";
   					return sRetIcon;
   				},
				formatter: function(){
					var html = "<a class='alink'";
					
					if (this.item.FolderType != "Folder" && this.item.FolderType != "Root") {
						html += " href='#'";
					}
					
					html += ">" + this.item.FolderName + "</a>";
					html += "<a href='#' class='newWindowPop' onclick='confDoc.editBoardPopup(\"" + this.item.FolderID + "\");'></a>";
					
					return html;
				}
			}],							// tree 헤드 정의 값
			relation: {
				parentKey: "MemberOf",	// 부모 아이디 키
				childKey: "FolderID"	// 자식 아이디 키
			},
			persistExpanded: false,		// 쿠키를 이용해서 트리의 확장된 상태를 유지 여부
			persistSelected: false,		// 쿠키를 이용해서 트리의 선택된 상태를 유지 여부
			colHead: {
				display: false
			},
			showConnectionLine: true,	// 점선 여부
			body:{
		        onclick:function(idx, item){ //[Function] 바디 클릭 이벤트 콜백함수
		        	if (item.FolderType!="Root" && item.FolderType!="Folder") {
		        		confDoc.setMessageGridList(item.FolderID,item.FolderName);
		        	}
		        }}
		});
		
		confDoc.setFolderTreeData();
	},
	setFolderTreeData: function(){
		$.ajax({
			url: "/groupware/board/manage/selectFolderTreeData.do",
			type: "POST",
			data: {
				"domainID": confMenu.domainId,
				"bizSection": bizSection,
				"isAll":$("#chk_IsAll").prop("checked")?"Y":"N"
			},
			async: false,
			success: function(data){
				var List = data.list;
				confDoc.folderGrid.setList(List);
				confDoc.folderGrid.expandAll(1);
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/board/manage/selectFolderTreeData.do", response, status, error);
			}
		});
	},
	setMessageGridConfig: function(){
		this.lowerMsgGrid.setGridHeader(this.msgHeaderData);
		
		var messageConfigObj = {
			targetID: "lowerMessageGrid",
			listCountMSG: "<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
			height: "auto",
			page: {
				pageNo: 1,
				pageSize: $("#selectPageSize").val()
			},
			paging: true,
		};
		
		this.lowerMsgGrid.setGridConfig(messageConfigObj);
		this.lowerMsgGrid.config.fitToWidthRightMargin = 0;
	},
	setMessageGridList: function(pFolderID, pFolderName){
		//폴더 변경시 검색항목 초기화
		if($("#hiddenFolderID").val() != pFolderID){
			$("#hiddenFolderID").val(pFolderID);
			$("#searchType").bindSelectSetValue("");
			$("#searchText").val("");
			$("#searchDetailText").val("");
			$("#startDate, #endDate").val("");
		}
		
		var searchText = $("#searchDetailText").val() ? $("#searchDetailText").val() : $("#searchText").val();
		
		$("#boardPath").text("- " + pFolderName);
		$('#hiddenFolderName').val(pFolderName)
		
		this.setMessageGridConfig();
		this.lowerMsgGrid.bindGrid({
			ajaxUrl: "/groupware/message/manage/selectMessageGridList.do",
			ajaxPars: {
				"bizSection": bizSection,
				"boardType": boardType,
				"folderID": pFolderID,
				"folderIDs": $("#hiddenFolderIDs").val(),
				"categoryID": $("#selectCate").val(),
				"msgState": $("#msgState").val(),
				"domainID": confDoc.domainID,
				"startDate": $("#startDate").val(),
				"endDate": $("#endDate").val(),
				"searchType": $("#searchType").val(),
				"searchText": searchText
			}
		});
	},
	editBoardPopup: function(folderID){
		var title = "<spring:message code='Cache.lbl_BoardConfigSet'/>|||<spring:message code='Cache.lbl_FolderModify'/>";
		var url =  "/groupware/board/manage/goFolderManagePopup.do";
			url += "?folderID=" + folderID;
			url += "&mode=edit";
			url += "&bizSection=" + bizSection;
			url += "&domainID=" + confDoc.domainID;
		
		Common.open("", "setBoard", title, url, "700px", "600px", "iframe", true, null, null, true);
	}
}

// 게시판 수정 팝업 콜백 이벤트 처리
function refresh(){
	confDoc.setFolderTreeData();
	$("#btnRefresh").trigger("click");
}

//엑셀 다운로드
function ExcelDownload(){
		if ($("#hiddenFolderID").val() == ""){
			Common.Warning("<spring:message code='Cache.apv_msg_com_select_1'/>".replace("{0}","<spring:message code='Cache.FolderType_Doc'/>")); // 문서물이 선택되지 않았습다.
			return;
		}
		Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage'/>", "Confirm", function(result){
		if (result) {
			var sortKey = confDoc.lowerMsgGrid.getSortParam("one").split("=")[1].split(" ")[0];
			var sortWay = confDoc.lowerMsgGrid.getSortParam("one").split("=")[1].split(" ")[1];
			var searchText = $("#searchDetailText").val() ? $("#searchDetailText").val() : $("#searchText").val();
			var url = String.format("/groupware/message/manage/messageManageListExcelDownload.do?boardType={0}&domainID={1}&folderID={2}&startDate={3}&endDate={4}&sortKey={5}&sortWay={6}&searchText={7}&searchType={8}&bizSection={9}&msgState={10}&folderName={11}",
				boardType,
				confDoc.domainID,
				$("#hiddenFolderID").val(),
				$("#startDate").val(),
				$("#endDate").val(),
				sortKey,
				sortWay,
				searchText,
				$("#searchType").val(),
				bizSection,
				$("#msgState").val(),
				$("#hiddenFolderName").val()
			);
			
			location.href = url;
		}

	});
}

//조회자 목록 조회 팝업 - messageViewerListPopup.jsp
function showReadedUsers(){
	if (confDoc.lowerMsgGrid.getCheckedList(0).length == 0) {
		Common.Warning("<spring:message code='Cache.apv_msg_com_select_1'/>".replace("{0}","<spring:message code='Cache.ACC_lbl_doc'/>")); // 문서물이 선택되지 않았습다.
		return;
	} else if(confDoc.lowerMsgGrid.getCheckedList(0).length > 1) {
		Common.Warning("<spring:message code='Cache.msg_SelectOne'/>"); // 한개만 선택되어야 합니다.
		return;
	}
	
	var url =  "/groupware/message/manage/goMessageViewerListPopup.do";
		url += "?messageID=" + confDoc.lowerMsgGrid.getCheckedList(0)[0].MessageID;
		url += "&messageVer=" + confDoc.lowerMsgGrid.getCheckedList(0)[0].Version;
		url += "&folderID=" + confDoc.lowerMsgGrid.getCheckedList(0)[0].FolderID;
		url += "&CLBIZ=" + CFN_GetQueryString("CLBIZ");
	
	Common.open("", "messageViewer", "<spring:message code='Cache.lbl_SearchorList'/>", url, "700px", "525px", "iframe", true, null, null, true);
}

//처리 이력 조회 팝업 - messageHistoryListPopup.jsp
function showHistory(){
	var selItem = confDoc.lowerMsgGrid.getCheckedList(0);
	
	if (selItem.length == 0) {
		Common.Warning("<spring:message code='Cache.apv_msg_com_select_1'/>".replace("{0}","<spring:message code='Cache.ACC_lbl_doc'/>")); // 문서물이 선택되지 않았습다.
		return;
	} else if(selItem.length > 1) {
		Common.Warning("<spring:message code='Cache.msg_SelectOne'/>"); // 한개만 선택되어야 합니다.
		return;
	}
	
	Common.open("", "messageHistory", "<spring:message code='Cache.lbl_ProcessingHistory'/>", "/groupware/message/manage/goMessageHistoryListPopup.do?messageID=" + selItem[0].MessageID, "1100px", "525px", "iframe", true, null, null, true);
}

//삭제, 복원, 잠금, 잠금해제 등을 할때 처리 사유 입력 팝업
function commentPopup(pMode){ // mode: delete, lock, unlock, restore
	if(confDoc.lowerMsgGrid.getCheckedList(0).length == 0){
		Common.Warning("<spring:message code='Cache.apv_msg_com_select_1'/>".replace("{0}","<spring:message code='Cache.ACC_lbl_doc'/>")); // 문서물이 선택되지 않았습다.
		return;
	}
	

	_CallBackMethod = new Function(pMode + "Message()");
	
	Common.open("", "commentPopup", "<spring:message code='Cache.lbl_ReasonForProcessing'/>", "/groupware/message/manage/goCommentPopup.do?mode=" + pMode, "300px", "220px", "iframe", true, null, null, true);
}

//수정요청 게시물 상태 변경
function requestStatusPopup(pRequestID, pAnswer, pStatus){
	var url =  "/groupware/board/manage/goRequestStatusPopup.do";
		url += "?requestID=" + pRequestID;
		url += "&answer=" + encodeURIComponent(pAnswer);
		url += "&status=" + pStatus;
		url += "&domainID=" + confDoc.domainID;
	
	Common.open("", "requestStatusPopup", "<spring:message code='Cache.lbl_ModificationRequest'/>", url, "360px", "220px", "iframe", true, null, null, true);
}

//게시글 삭제
function deleteMessage(){
	var messageIDs = '';
	
	$.each(confDoc.lowerMsgGrid.getCheckedList(0), function(i, obj){
		messageIDs += obj.MessageID + ';';
	});
	
	if(messageIDs == ''){
		Common.Warning("<spring:message code='Cache.msg_Common_03'/>"); // 삭제할 항목을 선택하여 주십시오.
		return;
	}
	
	$.ajax({
		type: "POST",
		url: "/groupware/message/manage/deleteMessage.do",
		data: {
			  "messageID": messageIDs
			, "comment": $("#hiddenComment").val()
		},
		success: function(data){
			if(data.status=='SUCCESS'){
				Common.Inform("<spring:message code='Cache.msg_50'/>"); // 삭제되었습니다.
				confDoc.setMessageGridList($("#hiddenFolderID").val(), $("#hiddenFolderName").val());
				$("#hiddenComment").val("");
			}else{
				Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생헸습니다.
			}
		},
		error: function(response, status, error){
			CFN_ErrorAjax("/groupware/board/manage/deleteMessage.do", response, status, error);
		}
	});
}

//게시글 잠금
function lockMessage(){
	var messageIDs = '';
	
	$.each(confDoc.lowerMsgGrid.getCheckedList(0), function(i, obj){
		messageIDs += obj.MessageID + ';';
	});
	
	if(messageIDs == ''){
		Common.Warning("<spring:message code='Cache.msg_MsgIsntSel' />"); // 게시글이 선택되지 않았습니다.
		return;
	}
	
	$.ajax({
		type: "POST",
		url: "/groupware/message/manage/lockMessage.do",
		data: {
			  "messageID": messageIDs
			, "comment": $("#hiddenComment").val()
		},
		success: function(data){
			if(data.status=='SUCCESS'){
				Common.Inform("<spring:message code='Cache.msg_ProcessOk'/>"); // 요청하신 작업이 정상적으로 처리되었습니다.
				confDoc.setMessageGridList($("#hiddenFolderID").val(), $("#hiddenFolderName").val());
				$("#hiddenComment").val("");
			}else{
				Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생헸습니다.
			}
		},
		error: function(response, status, error){
			CFN_ErrorAjax("/groupware/board/manage/lockMessage.do", response, status, error);
		}
	});
}

function unlockMessage(){
	var messageIDs = '';
	
	$.each(confDoc.lowerMsgGrid.getCheckedList(0), function(i,obj){
		messageIDs += obj.MessageID + ';';
	});
	
	if(messageIDs == ''){
		Common.Warning("<spring:message code='Cache.msg_MsgIsntSel' />"); // 게시글이 선택되지 않았습니다.
		return;
	}
	
	$.ajax({
		type: "POST",
		url: "/groupware/message/manage/unlockMessage.do",
		data: {
			  "messageID": messageIDs
			, "comment": $("#hiddenComment").val()
		},
		success: function(data){
			if(data.status=='SUCCESS'){
				Common.Inform("<spring:message code='Cache.msg_ProcessOk'/>"); // 요청하신 작업이 정상적으로 처리되었습니다.
				confDoc.setMessageGridList($("#hiddenFolderID").val(), $("#hiddenFolderName").val());
				$("#hiddenComment").val("");
			}else{
				Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생헸습니다.
			}
		},
		error: function(response, status, error){
			CFN_ErrorAjax("/groupware/board/manage/unlockMessage.do", response, status, error);
		}
	});
}

function restoreMessage(){
	var messageIDs = '';
	
	$.each(confDoc.lowerMsgGrid.getCheckedList(0), function(i, obj){
		messageIDs += obj.MessageID + ';';
	});
	
	if(messageIDs == ''){
		Common.Warning("<spring:message code='Cache.msg_gw_SelectResotre'/>");
		return;
	}
	
	$.ajax({
		type: "POST",
		url: "/groupware/message/manage/restoreMessage.do",
		data: {
			  "messageID": messageIDs
			, "comment": $("#hiddenComment").val()
		},
		success: function(data){
			if(data.status=='SUCCESS'){
				Common.Inform("<spring:message code='Cache.msg_ProcessOk'/>"); // 요청하신 작업이 정상적으로 처리되었습니다.
				confDoc.setMessageGridList($("#hiddenFolderID").val(), $("#hiddenFolderName").val());
				$("#hiddenComment").val("");
			}else{
				Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생헸습니다.
			}
		},
		error: function(response, status, error){
			CFN_ErrorAjax("/groupware/board/manage/restoreMessage.do", response, status, error);
		}
	});
}

//소유자, 등록부서 변경 조직도 팝업 호출
function changeDocInfo(pMode){
	if(confDoc.lowerMsgGrid.getCheckedList(0).length == 0){
		Common.Warning("<spring:message code='Cache.apv_msg_com_select_1'/>".replace("{0}","<spring:message code='Cache.ACC_lbl_doc'/>")); // 문서물이 선택되지 않았습다.
		return;
	}
	
	var type = "";
	
	switch(pMode){
		case "dept":
			type = "C1";
			break;
		case "owner":
			type = "A1";
			break;
		case "total":
			type = "D9";
			break;
	}
	
	var option = {
			callBackFunc : pMode + "ChangeDocInfo_CallBack",
	};
	
	coviCmn.openOrgChartPopup("<spring:message code='Cache.lbl_DeptOrgMap'/>", type, option)
//		var url =  "/covicore/control/goOrgChart.do";
//		url += "?callBackFunc=" + pMode + "ChangeDocInfo_CallBack";
//		url += "&type=" + type;
		
//	Common.open("", "orgmap_pop", "<spring:message code='Cache.lbl_DeptOrgMap'/>", url, "1040px", "600px", "iframe", true, null, null, true);
}

//소유자 변경
function ownerChangeDocInfo_CallBack(orgData){
	var ownerJSON = $.parseJSON(orgData);
	var docInfo = new Object();
	var ownerCode = "";
	
	if(ownerJSON.length > 1){
		Common.Warning("<spring:message code='Cache.msg_selectOnlySingleOwner'/>"); // 단일 소유자만 설정할 수 있습니다.
 	 	return;
	}
	
	$(ownerJSON.item).each(function(i, item){
  		sObjectType = item.itemType;
  		if(sObjectType.toUpperCase() == "USER"){ //사용자
  			ownerCode = item.UserCode;
  		}
 	});
	
 	if(ownerCode == ""){
 		Common.Warning("<spring:message code='Cache.ACC_msg_ckOwnerUser'/>"); // 소유자를 선택해주세요.
 	 	return;
 	}
 	
 	docInfo.ownerCode = ownerCode;
	ajaxCallChangeDocInfo(docInfo);		
}

//등록부서 변경
function deptChangeDocInfo_CallBack(orgData){
	var ownerJSON = $.parseJSON(orgData);
	var docInfo = new Object();
	var registDept = "";
	
	if(ownerJSON.length > 1){
		Common.Warning("<spring:message code='Cache.msg_selectOnlySingleDept'/>"); // 단일 부서만 설정할 수 있습니다.
 	 	return;
	}
	
	$(ownerJSON.item).each(function(i, item){
  		if(item.itemType.toUpperCase() == "GROUP"){
  	  		registDept = item.GroupCode;
  	  	}else if(item.itemType.toUpperCase() == "USER"){
  	  		registDept = item.GroupCode;
  	  	}
 	});
	
	if(registDept == ""){
 		Common.Warning("<spring:message code='Cache.msg_apv_021'/>"); // 담당부서를 선택하셔야 합니다.
 	 	return;
 	}
 	
	docInfo.registDept = registDept;
	ajaxCallChangeDocInfo(docInfo);
}

//일괄 변경
function totalChangeDocInfo_CallBack(orgData){
	var ownerJSON = $.parseJSON(orgData);
	var ownerCode = "";
	var registDept = "";
	var docInfo = new Object();
	
	if(ownerJSON.length > 1){
		Common.Warning("<spring:message code='Cache.msg_selectOnlySingleOwner'/>"); // 단일 소유자만 설정할 수 있습니다.
 	 	return;
	}
	
	$(ownerJSON.item).each(function(i, item){
  		sObjectType = item.itemType;
  		if(item.itemType.toUpperCase() == "GROUP"){
  	  		registDept = item.GroupCode;
  	  	}else if(item.itemType.toUpperCase() == "USER"){
  	  		ownerCode = item.UserCode;
  	  	}
 	});

	if(ownerCode == ""){
 		Common.Warning("<spring:message code='Cache.ACC_msg_ckOwnerUser'/>"); // 소유자를 선택해주세요.
 	 	return;
 	}
	
	docInfo.ownerCode = ownerCode;
	docInfo.registDept = registDept;
	ajaxCallChangeDocInfo(docInfo);
}

function ajaxCallChangeDocInfo(pObj){
	var messageIDs = '';
	
	$.each(confDoc.lowerMsgGrid.getCheckedList(0), function(i, obj){
		messageIDs += obj.MessageID + ';';
	});
	
	$.ajax({
		type: "POST",
		url: "/groupware/board/manage/changeDocInfo.do",
		data: {
			  "messageID": messageIDs
			, "ownerCode": pObj.ownerCode
			, "registDept": pObj.registDept
		},
		success: function(data){
			if(data.status=='SUCCESS'){
				Common.Inform("<spring:message code='Cache.msg_ProcessOk'/>"); // 요청하신 작업이 정상적으로 처리되었습니다.
				confDoc.setMessageGridList($("#hiddenFolderID").val(), $("#hiddenFolderName").val());
			}else{
				Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생헸습니다.
			}
		},
		error: function(response, status, error){
			CFN_ErrorAjax("/groupware/board/manage/changeDocInfo.do", response, status, error);
		}
	});
}

$(document).ready(function(){
	confDoc.initContent();
});

</script>

<div class="cRConTop titType AtnTop">
	<h2 class="title">
		<span><spring:message code="Cache.BizSection_Doc"/></span> <!-- 문서관리 -->
		<span id="boardPath"></span>
	</h2>
	<div class="searchBox02">
		<span>
			<input type="text" id="searchText">
			<button type="button" class="btnSearchType01" id="icoSearch"><spring:message code='Cache.btn_search' /></button> <!-- 검색 -->
		</span>
		<a href="#" class="btnDetails"><spring:message code='Cache.lbl_detail'/></a> <!-- 상세 -->
	</div>
</div>
<div class="cRContBottom mScrollVH">
	<div id="topitembar03" class="inPerView type02 sa04">
		<div>
			<div class="selectCalView">
				<spring:message code='Cache.lbl_State2'/>&nbsp;
				<select id="msgState" class="selectType04">
					<option value=""><spring:message code="Cache.lbl_all"/></option>
					<option value="C" selected><spring:message code="Cache.lbl_Registor"/></option>
					<option value="A"><spring:message code="Cache.lbl_Approval"/></option>
					<option value="P"><spring:message code="Cache.lbl_Lock"/></option>
					<option value="E"><spring:message code="Cache.lbl_expiration"/></option>
					<option value="D"><spring:message code="Cache.lbl_delete"/></option>
				</select>
			</div>		
			<div class="selectCalView"> 
				<spring:message code='Cache.lbl_SearchCondition'/>&nbsp;
				<select id="searchType" class="selectType04">
					<option value="Subject"><spring:message code="Cache.lbl_subject"/></option>
					<option value="CreatorName"><spring:message code="Cache.lbl_Register"/></option>
					<option value="BodyText"><spring:message code="Cache.lbl_Contents"/></option>
				</select>
				<input type="text" id="searchDetailText" style="width:100px"/>&nbsp;
			</div>
			<div class="selectCalView"> 
				<spring:message code='Cache.lblSearchScope'/>&nbsp;<input type="text" id="startDate" style="width: 95px"/> ~ 
				<input type="text" kind="twindate" date_startTargetID="startDate" id="endDate" style="width: 95px"/>
			</div>
			<a href="#" id="btnSearch" class="btnTypeDefault btnSearchBlue nonHover"><spring:message code="Cache.btn_search"/></a>
		</div>
	</div>
	<form id="form1">
		<div class="sadminTreeContent">
			<div  class="AXTreeWrap">
				<div class="searchBox02" style="margin: 10px 0px -20px 30px;">
					<span>
						<div class="chkStyle10"><input type="checkbox" class="check_class" id="chk_IsAll" value="Y" ><label for="chk_IsAll"><span class="s_check"></span><spring:message code='Cache.btn_All' /></label> </div>
						<input type="text" id="treeSearchText" class="w80">
						<button type="button" class="btnSearchType01" id="treeSearchBtn"><spring:message code='Cache.btn_search' /></button> <!-- 검색 -->
					</span>
				</div>
				<div id="folderGrid" class="tblList tblCont" style="width:300px;"></div>
			</div>
			<div>
				<div class="sadminContent">
					<!-- 게시글 조회항목 -->
					<div class="sadminMTopCont">
						<div class="pagingType02 buttonStyleBoxLeft">
							<a id="btnDelMsg" onclick="commentPopup('delete');" class="btnTypeDefault BtnDelete"><spring:message code="Cache.lbl_delete"/></a>
							<%-- <a id="btnLockMsg" onclick="commentPopup('lock');" class="btnTypeDefault"><spring:message code="Cache.lbl_Lock"/></a>
							<a id="btnUnlockMsg" onclick="commentPopup('unlock');" class="btnTypeDefault"><spring:message code="Cache.lbl_UnLock"/></a>
							<a id="btnRestoreMsg" onclick="commentPopup('restore');" class="btnTypeDefault"><spring:message code="Cache.lbl_Restore"/></a> --%> 

							<a name="btnDocInfo" onclick="changeDocInfo('owner');" class="btnTypeDefault"><spring:message code="Cache.lbl_changeOwner"/></a> <!-- 소유자 변경 -->
							<a name="btnDocInfo" onclick="changeDocInfo('dept');" class="btnTypeDefault"><spring:message code="Cache.lbl_changeRegDept"/></a> <!-- 등록부서 변경 -->
							<a name="btnDocInfo" onclick="changeDocInfo('total');" class="btnTypeDefault"><spring:message code="Cache.lbl_changeBulk"/></a> <!-- 일괄 변경 -->

							<a id="btnReadedUsers" onclick="showReadedUsers();" class="btnTypeDefault"><spring:message code="Cache.lbl_SearchorList"/></a>
							<a id="btnHistory" onclick="showHistory();" class="btnTypeDefault"><spring:message code="Cache.lbl_ProcessingHistory"/></a>
							<a id="btnExcel" onclick="ExcelDownload();" class="btnTypeDefault BtnExcel"><spring:message code="Cache.lbl_SaveToExcel"/></a>
						</div>
						<div class="buttonStyleBoxRight">
							<select id="selectPageSize" class="selectType02 listCount">
								<option value="10">10</option>
								<option value="20">20</option>
								<option value="30">30</option>
							</select>
							<button id="btnRefresh" class="btnRefresh" type="button" href="#"></button>
						</div>
					</div>
					<div id="lowerMessageGrid" class="tblList tblCont"></div>
				</div>
			</div>
		</div>
		<input type="hidden" id="hiddenMenuID" value=""/>
		<input type="hidden" id="hiddenFolderID" value=""/>
		<input type="hidden" id="hiddenFolderName" value=""/>
		<input type="hidden" id="hiddenMessageID" value=""/>
		<input type="hidden" id="hiddenComment" value=""/>
	</form>
</div>