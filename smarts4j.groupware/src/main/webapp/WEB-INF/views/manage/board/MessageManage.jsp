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

var bizSection = "Board";
var boardType = "Normal";
var sessionObj = Common.getSession();

var confBoard = {
	lowerMsgGrid: new coviGrid(),	// 게시글 Grid 
	folderGrid: new coviTree(),		// 폴더 Grid
	msgHeaderData: [ 
		         	{key:'chk', label:'chk', width:'2', align:'center', formatter: 'checkbox'},
		        	{key:'MessageID',  label:coviDic.dicMap["lbl_no2"], width:'5', align:'center'},
		        	{key:'Subject',  label:coviDic.dicMap["lbl_subject"], width:'20', align:'left',
		        		formatter:function(){
		        			return boardAdmin.formatSubjectName(this); 
		        		}
		        	},
	        		{key:'BodyText',  label:'<spring:message code="Cache.lbl_SummaryInfo"/>', width:'30', align:'left'},
		        	{key:'MsgStateDetail',  label:coviDic.dicMap["lbl_State2"], width:'5', align:'center',
		        		formatter:function(){ 
		        			return boardAdmin.formatMessageState(this); 
		        		}
		        	},
		        	{key:'CreatorName',  label:coviDic.dicMap["lbl_Register"], width:'8', align:'center',
		        		formatter: function(){ return CFN_GetDicInfo(this.item.CreatorName)
		        	}},
		        	{key:'FileCnt',  label:coviDic.dicMap["lbl_attach"], width:'4', align:'center'},
		        	{key:'RegistDate',  label:coviDic.dicMap["lbl_RegistDate"] + Common.getSession("UR_TimeZoneDisplay"), width:'10', align:'center', sort:'desc', formatter: function(){
						return CFN_TransLocalTime(this.item.RegistDate);
					}},
		        	{key:'ExpiredDate',  label:coviDic.dicMap["lbl_ExpireDate"], width:'10', align:'center'}
		        ],
	domainID: confMenu.domainId,
	initContent: function(){
		
		$("#chk_IsAll").click(function(){
			confBoard.setFolderTreeData();
		});

		
		// 새로고침
		$("#btnRefresh").on('click', function(){
			if (confBoard.folderGrid.selectedRow[0]) {
				var selItem = confBoard.folderGrid.list[confBoard.folderGrid.selectedRow[0]];
				
				confBoard.setMessageGridList(selItem.FolderID, selItem.FolderName);
			}
		});
		
		$("#selectPageSize").on('change', function(){
			if (confBoard.folderGrid.selectedRow[0]) {
				var selItem = confBoard.folderGrid.list[confBoard.folderGrid.selectedRow[0]];
				
				confBoard.setMessageGridList(selItem.FolderID, selItem.FolderName);
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
				confBoard.setFolderTreeData();
				return;
			}
			/* 엔터나 클릭을 이용해 검색조건에 맞는 폴더나 게시판을 탐색하면서 해당 폴더, 게시판에 대한 게시물을 조회 */ 
			var curIdx = Number(confBoard.folderGrid.selectedRow)+1;
			confBoard.folderGrid.findKeywordData("FolderName", keyword, true, false, curIdx);
		});
		
		$("#searchText, #searchDetailText").on('keydown', function(){
			if(event.keyCode == "13"){
				confBoard.setMessageGridList($('#hiddenFolderID').val(), $('#hiddenFolderName').val());
			}
		});
		
		$("#icoSearch, #btnSearch").on('click', function(){
			confBoard.setMessageGridList($('#hiddenFolderID').val(), $('#hiddenFolderName').val());
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
					html += "<a href='#' class='newWindowPop' onclick='confBoard.editBoardPopup(\"" + this.item.FolderID + "\");'></a>";
					
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
		        		confBoard.setMessageGridList(item.FolderID,item.FolderName);
		        	}
		        }}
		});
		
		confBoard.setFolderTreeData();
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
				confBoard.folderGrid.setList(List);
				confBoard.folderGrid.expandAll(1);
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
				"domainID": confBoard.domainID,
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
			url += "&domainID=" + confMenu.domainId;
		
		Common.open("", "setBoard", title, url, "700px", "600px", "iframe", true, null, null, true);
	}
}

// 게시판 수정 팝업 콜백 이벤트 처리
function refresh(){
	confBoard.setFolderTreeData();
	$("#btnRefresh").trigger("click");
}

//엑셀 다운로드
function ExcelDownload(){
		if ($("#hiddenFolderID").val() == ""){
			Common.Warning("<spring:message code='Cache.msg_SelectBoard'/>");
			return;
		}
		Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage'/>", "Confirm", function(result){
		if (result) {
			var sortKey = confBoard.lowerMsgGrid.getSortParam("one").split("=")[1].split(" ")[0];
			var sortWay = confBoard.lowerMsgGrid.getSortParam("one").split("=")[1].split(" ")[1];
			var searchText = $("#searchDetailText").val() ? $("#searchDetailText").val() : $("#searchText").val();
			var url = String.format("/groupware/message/manage/messageManageListExcelDownload.do?boardType={0}&domainID={1}&folderID={2}&startDate={3}&endDate={4}&sortKey={5}&sortWay={6}&searchText={7}&searchType={8}&bizSection={9}&msgState={10}&folderName={11}",
				boardType,
				confBoard.domainID,
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
	if(confBoard.lowerMsgGrid.getCheckedList(0).length == 0){
		Common.Warning("<spring:message code='Cache.msg_MsgIsntSel'/>"); // 게시물이 선택되지 않았습다.
		return;
	} else if(confBoard.lowerMsgGrid.getCheckedList(0).length > 1){
		Common.Warning("<spring:message code='Cache.msg_SelectOne'/>"); // 한개만 선택되어야 합니다.
		return;
	}
	
	var url =  "/groupware/message/manage/goMessageViewerListPopup.do";
		url += "?messageID=" + confBoard.lowerMsgGrid.getCheckedList(0)[0].MessageID;
		url += "&messageVer=" + confBoard.lowerMsgGrid.getCheckedList(0)[0].Version;
		url += "&folderID=" + confBoard.lowerMsgGrid.getCheckedList(0)[0].FolderID;
		url += "&CLBIZ=" + CFN_GetQueryString("CLBIZ");
	
	Common.open("", "messageViewer", "<spring:message code='Cache.lbl_SearchorList'/>", url, "700px", "525px", "iframe", true, null, null, true);
}

//처리 이력 조회 팝업 - messageHistoryListPopup.jsp
function showHistory(){
	var selItem = confBoard.lowerMsgGrid.getCheckedList(0);
	
	if(selItem.length == 0){
		Common.Warning("<spring:message code='Cache.msg_MsgIsntSel'/>"); // 게시물이 선택되지 않았습다.
		return;
	} else if(selItem.length > 1){
		Common.Warning("<spring:message code='Cache.msg_SelectOne'/>"); // 한개만 선택되어야 합니다.
		return;
	}
	
	Common.open("", "messageHistory", "<spring:message code='Cache.lbl_ProcessingHistory'/>", "/groupware/message/manage/goMessageHistoryListPopup.do?messageID=" + selItem[0].MessageID, "840px", "525px", "iframe", true, null, null, true);
}

//삭제, 복원, 잠금, 잠금해제 등을 할때 처리 사유 입력 팝업
function commentPopup(pMode){ // mode: delete, lock, unlock, restore
	if(confBoard.lowerMsgGrid.getCheckedList(0).length == 0){
		Common.Warning("<spring:message code='Cache.msg_MsgIsntSel' />"); // 게시글이 선택되지 않았습니다.
		return;
	}
	
	_CallBackMethod = new Function(pMode + "Message()");
	
	Common.open("", "commentPopup", "<spring:message code='Cache.lbl_ReasonForProcessing'/>", "/groupware/message/manage/goCommentPopup.do?mode=" + pMode, "300px", "220px", "iframe", true, null, null, true);
}



//게시글 삭제
function deleteMessage(){
	var messageIDs = '';
	
	$.each(confBoard.lowerMsgGrid.getCheckedList(0), function(i, obj){
		messageIDs += obj.MessageID + ';'
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
				confBoard.setMessageGridList($("#hiddenFolderID").val(), $("#hiddenFolderName").val());
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
	
	$.each(confBoard.lowerMsgGrid.getCheckedList(0), function(i, obj){
		messageIDs += obj.MessageID + ';'
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
				confBoard.setMessageGridList($("#hiddenFolderID").val(), $("#hiddenFolderName").val());
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

//잠금해제
function unlockMessage(){
	var messageIDs = '';
	
	$.each(confBoard.lowerMsgGrid.getCheckedList(0), function(i,obj){
		messageIDs += obj.MessageID + ';'
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
				confBoard.setMessageGridList($("#hiddenFolderID").val(), $("#hiddenFolderName").val());
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

//복원
function restoreMessage(){
	var messageIDs = '';
	
	$.each(confBoard.lowerMsgGrid.getCheckedList(0), function(i, obj){
		messageIDs += obj.MessageID + ';'
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
				confBoard.setMessageGridList($("#hiddenFolderID").val(), $("#hiddenFolderName").val());
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

$(document).ready(function(){
	confBoard.initContent();
});

</script>

<div class="cRConTop titType AtnTop">
	<h2 class="title">
		<span><spring:message code="Cache.lbl_msgManage"/></span> <!-- 게시물관리 -->
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
				<select id="msgState" class="selectType04"> 										<!-- 상세검색 select -->
					<option value=""><spring:message code="Cache.lbl_all"/></option> 				<!-- 전체 -->
					<%-- 엑셀다운로드는 GET방식으로 넘기는데, GET방식에서는 특수문자 + 처리 못함. --%>
					<option value="C_A" selected><spring:message code="Cache.lbl_Registor"/>+<spring:message code="Cache.lbl_Approval"/></option> 	<!-- 등록+승인 -->
					<option value="P"><spring:message code="Cache.lbl_Lock"/></option> 				<!-- 잠금 -->
					<option value="E"><spring:message code="Cache.lbl_expiration"/></option> 		<!-- 만료 -->
					<option value="D"><spring:message code="Cache.lbl_delete"/></option> 			<!-- 삭제 -->
				</select>
			</div>
			<div class="selectCalView"> 
				<spring:message code='Cache.lbl_SearchCondition'/>&nbsp; 							<!-- 검색조건 -->
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
			<a href="#" id="btnSearch" class="btnTypeDefault btnSearchBlue nonHover"><spring:message code="Cache.btn_search"/></a> 	<!-- 검색(상세검색) -->
		</div>
	</div>
	<form id="form1">
		<div class="sadminTreeContent">
			<div class="AXTreeWrap">
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
							<a id="btnRestoreMsg" onclick="commentPopup('restore');" class="btnTypeDefault"><spring:message code="Cache.lbl_Restore"/></a>
							<a id="btnLockMsg" onclick="commentPopup('lock');" class="btnTypeDefault"><spring:message code="Cache.lbl_Lock"/></a>
							<a id="btnUnlockMsg" onclick="commentPopup('unlock');" class="btnTypeDefault"><spring:message code="Cache.lbl_UnLock"/></a>
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