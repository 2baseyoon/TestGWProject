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
var bizSection = "Board";
var confBoard = {
	folderGrid: new coviTree(),		//폴더 Grid
	msgHeaderData: boardAdmin.getGridHeader("Normal"),
	domainID: confMenu.domainId,
	initContent: function(){
		
		this.folderGrid.setConfig({
			targetID: "folderGrid",				// HTML element target ID
			theme: "AXTree_none",
			colGroup: [
				{
					key: "FolderName",			// 컬럼에 매치될 item 의 키
					indent: true,				// 들여쓰기 여부
					label: '<spring:message code="Cache.lbl_BoardNm"/>',
					width: "170",
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
					formatter:function(){
						var html = '<a href="#" onclick="editBoardPopup(\'' + this.item.FolderID + '\')">' + this.item.FolderName + '</a>';
						return html;
					}
				},
				{key:'FolderID', label:'ID', width:'50', align:'center'},
				{key:'MenuID', label:'MenuID', width:'50', align:'center'},
				{key:'MenuName', label:'<spring:message code="Cache.lbl_menuName"/>', width:'50', align:'center'},		// 메뉴명
				{key:'FolderTypeName', label:'<spring:message code="Cache.lbl_FolderType"/>', width:'80', align:'center'}, // 폴더 유형
				{key:'DeleteDate', label:'<spring:message code="Cache.lbl_DeleteDate"/>(<spring:message code="Cache.lbl_Restore"/>)', width:'80', align:'center',
					formatter:function(){
						return boardAdmin.formatFolderDeleteDate(this);
					}
				},
				{key:'RegisterName', label:'<spring:message code="Cache.lbl_Register"/>', width:'100', align:'center'}, // 등록자
				{key:'IsDisplay', label:'<spring:message code="Cache.lbl_Display"/>', width:'50', align:'center', // 표시여부
					formatter:function(){ return boardAdmin.formatUpdateFlag(this); }
				},
				{key:'IsUse', label:'<spring:message code="Cache.lbl_selUse"/>', width:'50', align:'center', // 사용여부
					formatter:function(){ return boardAdmin.formatUpdateFlag(this); }
				},
				{key:'RegistDate', label:'<spring:message code="Cache.lbl_RegistrationDate"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'100', align:'center', // 등록일자
					formatter:function(){ return CFN_TransLocalTime(this.item.RegistDate); }
				},
				{key:'', label:"<spring:message code='Cache.lbl_action'/>", width:'300', align:'left', display:true, sort:false,
					formatter:function(){
						var html = '<div class="btnActionWrap">';
						
						html += '<a href="javascript:;" class="btnTypeDefault btnMoveUp" onclick="moveFolder(\'up\', this);"><spring:message code="Cache.lbl_apv_up"/></a>';
						html += '<a href="javascript:;" class="btnTypeDefault btnMoveDown" onclick="moveFolder(\'down\', this);"><spring:message code="Cache.lbl_apv_down"/></a>';
						html += '<a href="javascript:;" class="btnTypeDefault btnMove" onclick="moveFolderPopup(this);"><spring:message code="Cache.lbl_Move"/></a>';
						html += '<a href="javascript:;" class="btnTypeDefault btnSaRemove" onclick="deleteBoard(this);"><spring:message code="Cache.lbl_delete"/></a>';
						if (["Root", "Folder"].includes(this.item.itemType)) {
							html += '<a href="javascript:;" class="btnTypeDefault btnPlusAdd" onclick="createBoardPopup(\'' + this.item.FolderID + '\', \'' + this.item.MenuID + '\');"><spring:message code="Cache.btn_apv_Person"/></a>';
						}
						html += '</div>';
						return html;
					}
				}
			],							// tree 헤드 정의 값
			showConnectionLine: true,	// 점선 여부
			relation: {
				parentKey: "MemberOf",	// 부모 아이디 키
				childKey: "FolderID"	// 자식 아이디 키
			},
			persistExpanded: false,		// 쿠키를 이용해서 트리의 확장된 상태를 유지 여부
			persistSelected: false,		// 쿠키를 이용해서 트리의 선택된 상태를 유지 여부
			colHead: {
				display: true
			},
			fitToWidth: true			// 너비에 자동 맞춤
		});
		
		confBoard.setFolderTreeData();
		confBoard.setEvent();
	},
	setEvent: function(){
		// 폴더 새로고침
		$("#folderRefresh, #chk_IsAll").click(function(){
			confBoard.setFolderTreeData();
		});
		
		// 전체열기
		$("#folderOpen").click(function(){
			confBoard.folderGrid.expandAll();
		});
		
		// 전체닫기
		$("#folderClose").click(function(){
			confBoard.folderGrid.collapseAll();
		});
		
		// 폴더 추가
		$("#folderAdd").click(function(){
			createBoardPopup();
		});
		
		// 검색
		$("#searchText").on('keydown', function(){
			if(event.keyCode == "13"){
				$('#icoSearch').trigger('click');
			}
		});
		
		// 상단바 검색 버튼
		$("#icoSearch").on('click', function(){
			var keyword = $("#searchText").val();
			if (keyword == "") return;
			
			/* 엔터나 클릭을 이용해 검색조건에 맞는 폴더나 게시판을 조회 */ 
			var curIdx = Number(confBoard.folderGrid.selectedRow)+1;
			confBoard.folderGrid.findKeywordData("FolderName", keyword, true, true, curIdx);
		});
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
				confBoard.folderGrid.setList(data.list);
				confBoard.folderGrid.expandAll(1);
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/board/manage/selectFolderTreeData.do", response, status, error);
			}
		});
	},
	changeMessageGridList: function(pFolderID, pFolderPath){
		//폴더 변경시 검색항목 초기화
		if($("#hiddenFolderID").val() != pFolderID){
			$("#hiddenFolderID").val(pFolderID);
			$("#searchType").bindSelectSetValue("");
			$("#searchText").val("");
			$("#startDate, #endDate").val("");
		}
		
		//검색영역 및 검색조건 체크
		if($("#searchType").val() == "" && $("#searchText").val()!=""){
			Common.Warning("<spring:message code='Cache.msg_SelSearchGubun'/>"); // 검색구분을 선택하세요
			return;
		}
		$("#boardPath").text(pFolderPath.substr(0, pFolderPath.length-1).replace(/>/gi, ' > '));
		this.setMessageGridConfig();
	}
}

$(document).ready(function(){
	//전체 체크
	$("#chk_IsAll").click(function(){
		if($("#chk_IsAll").prop("checked")){
			coviCmn.setCookie("IsAllCheck", "Y", 1);			
		}else{			
			coviCmn.setCookie("IsAllCheck", "N", 1);
		}
	});
	
	//쿠키
	var cookieAllCheck = coviCmn.getCookie("IsAllCheck");		
	if(cookieAllCheck!="" && cookieAllCheck != "undefined" && cookieAllCheck == 'Y'){
		$("#chk_IsAll").click();
	}
	
	confBoard.initContent();
});

var refresh = function(){
	confBoard.setFolderTreeData();
}

var createBoardPopup = function(folderID, menuID){
	var title = "<spring:message code='Cache.lbl_BoardConfigSet'/>|||<spring:message code='Cache.lbl_FolderAdd'/>";
	var url =  "/groupware/board/manage/goFolderManagePopup.do";
		url += "?folderID=" + (folderID ? folderID : "");
		url += "&menuID=" + (menuID ? menuID : "");
		url += "&mode=create";
		url += "&bizSection=" + bizSection;
		url += "&domainID=" + confMenu.domainId;
	
	Common.open("", "addBoard", title, url, "700px", "600px", "iframe", true, null, null, true);
}

var editBoardPopup = function(folderID){
	var title = "<spring:message code='Cache.lbl_BoardConfigSet'/>|||<spring:message code='Cache.lbl_FolderModify'/>";
	var url =  "/groupware/board/manage/goFolderManagePopup.do";
		url += "?folderID=" + folderID;
		url += "&mode=edit";
		url += "&bizSection=" + bizSection;
		url += "&domainID=" + confMenu.domainId;
	
	Common.open("", "setBoard", title, url, "700px", "600px", "iframe", true, null, null, true);
}

var moveFolderPopup=function(elem){
	var idx = $("#folderGrid .gridBodyTr").index($(elem).parents('tr:first'));
	var selectedItem = confBoard.folderGrid.list[idx];
	var url = "/groupware/board/manage/goMoveFolderPopup.do?folderID=" + selectedItem.FolderID + "&domainID=" + confMenu.domainId+"&bizSection="+bizSection ;
	parent.Common.open("","moveMenuCallBack","["+selectedItem.FolderName+"] <spring:message code='Cache.lbl_Move'/>", url,"550px","450px","iframe",true,null,null,true);

}

var moveFolder = function(pMode, elem){
	var idx = $("#folderGrid .gridBodyTr").index($(elem).parents('tr:first'));
	var selectedItem = confBoard.folderGrid.list[idx];
	
	$.ajax({
		type: "POST",
		url: "/groupware/board/manage/moveFolder.do",
		dataType: 'json',
		data: {
			"bizSection": bizSection,
			"domainID": confMenu.domainId,
			"menuID": selectedItem.MenuID,
			"folderPath": selectedItem.FolderPath,
			"folderType": selectedItem.FolderType,
			"folderID": selectedItem.FolderID,
			"sortKey": selectedItem.SortKey,
			"mode": pMode
		},
		success: function(data){
			if(data.status === 'SUCCESS'){
				if(data.message){
					Common.Inform(data.message); // 최상위, 최하위 항목의 경우에는 변경 불가 메시지 표시
				} else {
					Common.Inform("<spring:message code='Cache.msg_Changed'/>"); // 변경했습니다.
				}
				
				refresh();
			}else{
				Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생헸습니다.
			}
		},
		error: function(response, status, error){
			CFN_ErrorAjax("/groupware/board/manage/moveFolder.do", response, status, error);
		}
	});
}

//게시판 삭제
var deleteBoard = function(elem){
	var idx = $("#folderGrid .gridBodyTr").index($(elem).parents('tr:first'));
	var selectedItem = confBoard.folderGrid.list[idx];
	
	Common.Confirm("<spring:message code='Cache.msg_Common_08'/>", 'Confirmation Dialog', function(result){ // 선택한 항목을 삭제하시겠습니까?
		if (result) {
			$.ajax({
				type: "POST",
				url: "/groupware/board/manage/deleteBoard.do",
				data: {
					"folderID": selectedItem.FolderID
				},
				success: function(data){
					if(data.status === 'SUCCESS'){
						Common.Inform("<spring:message code='Cache.msg_50'/>"); // 삭제되었습니다.
						refresh();
					}else{
						Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생헸습니다.
					}
				},
				error: function(response, status, error){
					CFN_ErrorAjax("/groupware/board/manage/deleteBoard.do", response, status, error);
				}
			});
		}
	});
}

//게시판 복원
function restoreFolder(folderID, folderType, memberOf, menuID){	
	Common.Confirm("<spring:message code='Cache.msg_itemEnabledQ'/>", 'Confirmation Dialog', function(result){ // 해당 항목을 다시 사용할 수 있도록 처리하시겠습니까?
		if (result) {
			$.ajax({
				type: "POST",
				url: "/groupware/board/manage/restoreFolder.do",
				data: {
				    "folderID": folderID,
				    "folderType": folderType,
				    "memberOf": memberOf,
				    "menuID": menuID
				},
				success: function(data){
					if(data.status === 'SUCCESS'){
						Common.Inform("<spring:message code='Cache.msg_ProcessOk'/>"); //작업이 완료됐습니다.
						refresh();
					}else{
						Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
					}
				},
				error: function(response, status, error){
					CFN_ErrorAjax("/groupware/board/manage/restoreFolder.do", response, status, error);
				}
			});
		}
	});
}

// IsUse, IsDisplay 변경
var updateFlag = function(pParam, pFlagValue, pTarget){
	let param = JSON.parse(pParam);
	let folderID = param.folderID;
	let flagKey = param.columnName;

 	if(folderID){
		$.ajax({
			type: "POST",
			url: "/groupware/board/manage/updateBoardFlag.do",
			data: {
				"folderID": folderID,
				"flagKey": flagKey, // IsUse, IsDisplay의 이름으로 DB스크립트 컬럼 지정
				"flagValue": pFlagValue
			},
			success: function(data){
				if(data.status === 'SUCCESS'){
					Common.Indicator(Common.getDic("msg_37"), null, 1000);			// 저장되었습니다.
				}else{
					Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생헸습니다.
					
					if (pFlagValue == 'Y') {
						$("#switch_"+folderID+"_"+flagKey).val($("#switch_"+folderID+"_"+flagKey).attr("off_value"));
						$(pTarget).removeClass("on");
					} else {
						$("#switch_"+folderID+"_"+flagKey).val($("#switch_"+folderID+"_"+flagKey).attr("on_value"));
						$(pTarget).addClass("on");
					}
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/board/manage/updateBoardFlag.do", response, status, error);
			}
		});
	}
}

</script>

<div class="cRConTop titType AtnTop">
	<h2 class="title"><spring:message code='Cache.lblBoardManage'/></h2>
	<div class="searchBox02">
		<span><input type="text" id="searchText"><button type="button" class="btnSearchType01" id="icoSearch"><spring:message code='Cache.btn_search' /></button></span> <!-- 검색 -->
	</div>
</div>
<form id="form1">
	<div class="cRContBottom mScrollVH">
		<div class="sadminContent">
			<div class="sadminMTopCont">
				<div class="pagingType02 buttonStyleBoxLeft">
					<a class="btnTypeDefault btnPlusAdd" id="folderAdd"><spring:message code="Cache.btn_Add"/></a> <!-- 추가 -->
					<a class="btnTypeDefault" id="folderOpen"><spring:message code="Cache.lbl_OpenAll"/></a>
					<a class="btnTypeDefault" id="folderClose"><spring:message code="Cache.lbl_CloseAll"/></a>
				</div>
				<div class="buttonStyleBoxRight">
					<div class="chkStyle10"><input type="checkbox" class="check_class" id="chk_IsAll" value="Y" ><label for="chk_IsAll"><span class="s_check"></span><spring:message code='Cache.btn_All' /></label> </div>
					<button id="folderRefresh" class="btnRefresh" type="button" href="#"></button>
				</div>
			</div>
			<!-- 폴더 Grid 리스트 -->
			<div id="folderGrid" class="tblList tblCont"></div>
		</div>
		<input type="hidden" id="hiddenMenuID" value=""/>
		<input type="hidden" id="hiddenFolderID" value=""/>
		<input type="hidden" id="hiddenMessageID" value=""/>
		<input type="hidden" id="hiddenComment" value="" />
	</div>
</form>