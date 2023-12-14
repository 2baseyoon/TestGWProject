<%@page import="egovframework.baseframework.util.PropertiesUtil,egovframework.coviframework.util.DicHelper"%>
<%@page import="egovframework.coviframework.util.StringUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
	String boardType = StringUtil.replaceNull(request.getParameter("boardType"), "");
	String menuTitle = DicHelper.getDic("lbl_"+request.getParameter("boardType")+"List");
%>

<script type="text/javascript" src="/groupware/resources/script/admin/boardAdmin.js<%=resourceVersion%>"></script>
<div class="cRConTop titType AtnTop">
	<h2 class="title"><span class="con_tit"><%=menuTitle%></span></h2>
</div>
<div class="cRContBottom mScrollVH">
<form id="form1">
	<div id="topitembar03" class="inPerView type02 sa04 active">
		<div>
			<spring:message code='Cache.lbl_Section'/>&nbsp;
			<select id="searchType" class="selectType02">
				<option value=""><spring:message code="Cache.lbl_selection"/></option>
				<option value="Subject"><spring:message code="Cache.lbl_subject"/></option>
				<option value="CreatorName"><spring:message code="Cache.lbl_Register"/></option>
				<option value="BodyText"><spring:message code="Cache.lbl_Contents"/></option>
			</select>
			<spring:message code='Cache.lbl_SearchCondition'/>&nbsp;
			<input type="text" id="searchText" />&nbsp;
			<spring:message code='Cache.lblSearchScope'/>&nbsp;<input type="text" id="startDate" style="width:102px"/> ~ 
			<input type="text" kind="twindate" date_startTargetID="startDate" id="endDate" style="width:102px"/>
			<input type="button" id="searchBtn" value="<spring:message code='Cache.btn_search'/>" class="AXButton" />
		</div>
	</div>		
	<div class="sadminContent">
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<div class="pagingType02 buttonStyleBoxLeft" id="messageManage">
					<%if (boardType.equals("Report") || boardType.equals("RequestModify") || boardType.equals("Lock")){ %>
					<a data-role="operation" data-operation="delete" class="btnTypeDefault BtnDelete"><spring:message code="Cache.lbl_delete"/></a>	<!-- 삭제 -->
					<%} %>
					<%if (boardType.equals("Report") || boardType.equals("RequestModify")){ %>
					<a data-role="operation" data-operation="lock" class="btnTypeDefault"><spring:message code="Cache.lbl_Lock"/></a> 	<!-- 잠금 -->
					<%} %>
					<%if (boardType.equals("Lock")) { %>
					<a data-role="operation" data-operation="unlock" class="btnTypeDefault"><spring:message code="Cache.lbl_UnLock"/></a>
					<%} %>
					<%if (boardType.equals("DeleteNExpire")) { %>
					<a data-role="operation" data-operation="restore" class="btnTypeDefault"><spring:message code="Cache.lbl_Restore"/></a> 	<!-- 복원 -->
					<%} %>
					<a id="btnReadedUsers" class="btnTypeDefault"><spring:message code="Cache.lbl_SearchorList"/></a> 	<!-- 조회자목록 -->
					<a id="btnHistory" class="btnTypeDefault"><spring:message code="Cache.lbl_ProcessingHistory"/></a> 		<!-- 처리이력 -->
					<%if (boardType.equals("RequestModify")) { %>
						<a id="btnExcel" class="btnTypeDefault BtnExcel"><spring:message code="Cache.lbl_SaveToExcel"/></a>
					<%} %>
				</div>
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
		<div class="sadminMTopCont">
			<div id="lowerMessageGrid" class="tblList tblCont"></div>
		</div>
	</div>
	<input type="hidden" id="hiddenComment" value="" />
</form>
</div>
<script type="text/javascript">
// #/manage/board/MessageManageByType.jsp

var boardMessageManageByType = function(pObjectName){
	// 간편관리자의 "CLBIZ" 값은 "Conf" 이지만, 조회 대상이 게시판이어서, 조회 조건 중 bizSection 을 "Board"로 합니다.
	var bizSection = "Board";
	var boardType = "";//CFN_GetQueryString("boardType") == 'undefined'? "Normal" : CFN_GetQueryString("boardType");
	var lowerMsgGrid = new coviGrid();		//게시글 Grid 
	
	var objectName = pObjectName;
	//페이지 로드시 Normal 헤더로 설정
	var msgHeaderData = boardAdmin.getGridHeader("Normal");

	this.initContent = function(linkUrl) {
		boardType = CFN_GetQueryString("boardType", linkUrl) == 'undefined'? "Normal" : CFN_GetQueryString("boardType", linkUrl);
		
		changeBoardUI(boardType);
		setMessageGridConfig();
		selectMessageGridList();
	}
	
	var changeBoardUI = function(pFolderType) {
		//boardType에 따라 화면의 타이틀, 버튼 컨트롤 표시/숨김처리
		switch(boardType){
			case "Report":
				msgHeaderData = boardAdmin.getGridHeader("Report");
				break;
			case "Lock":
				msgHeaderData = boardAdmin.getGridHeader("Lock");
				break;
			case "DeleteNExpire":
				msgHeaderData = boardAdmin.getGridHeader("DeleteNExpire");
				break;	
			case "RequestModify":
				msgHeaderData = boardAdmin.getGridHeader("RequestModify");
				break;
			default:
		}
	}
	
	//게시글 그리드 세팅
	var setMessageGridConfig = function (){
		lowerMsgGrid.setGridHeader(msgHeaderData);
		
		var messageConfigObj = {
			targetID : "lowerMessageGrid",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
			height:"auto",
			page : {
				pageNo: 1,
				pageSize: $("#selectPageSize").val()
			},
			paging : true,
			colHead:{},
			body:{},
		};
		lowerMsgGrid.setGridConfig(messageConfigObj);
		lowerMsgGrid.config.fitToWidthRightMargin = 0;
	}
	
	//게시글 Grid 조회 
	var selectMessageGridList = function() {
		//검색영역 및 검색조건 체크
		if($("#searchType").val() == "" && $("#searchText").val()!=""){
			Common.Warning("<spring:message code='Cache.msg_SelSearchGubun'/>", "Warning Dialog", function () { });          // 검색구분을 선택하세요
			return;		
		}
		
		// paging.
		lowerMsgGrid.page.pageSize = $("#selectPageSize").val();
		
		lowerMsgGrid.bindGrid({
			ajaxUrl: "/groupware/message/manage/selectMessageGridList.do",
			ajaxPars: {
				"bizSection": bizSection,
				"boardType": boardType,
				"domainID":confMenu.domainId,
				"startDate":$("#startDate").val(),
				"endDate":$("#endDate").val(),
				"searchType":$("#searchType").val(),
				"searchText":$("#searchText").val()
			},
		});
	}
	
	// 조회버튼 클릭 이벤트.
	$("#searchBtn").on("click", function() {
		selectMessageGridList();
	});
	
	// 검색어 엔터 이벤트
	$("#searchText").off("keypress").on("keypress", function() {
		if (event.keyCode === 13) {
			selectMessageGridList();
		}
	});
	
	// 처리이력 클릭 이벤트
	$("#btnHistory").on("click", function() {
		if (lowerMsgGrid.getCheckedList(0).length === 0) {
			Common.Warning("<spring:message code='Cache.msg_MsgIsntSel'/>", "Warning Dialog", function () { });          // 게시물이 선택되지 않았습니다
			return;
		} else if (lowerMsgGrid.getCheckedList(0).length > 1) {
			Common.Warning("<spring:message code='Cache.msg_SelectOne'/>", "Warning Dialog", function () { });          // 한개만 선택되어야 합니다.
			return;
		}
		parent.Common.open("","messageHistory","<spring:message code='Cache.lbl_ProcessingHistory'/>","/groupware/message/manage/goMessageHistoryListPopup.do?messageID="+lowerMsgGrid.getCheckedList(0)[0].MessageID ,"840px","525px","iframe",true,null,null,true);
	});
	
	// 조회자목록 클릭 이벤트
	$("#btnReadedUsers").on("click", function() {
		if(lowerMsgGrid.getCheckedList(0).length == 0){
			Common.Warning("<spring:message code='Cache.msg_MsgIsntSel'/>", "Warning Dialog", function () { });          // 게시물이 선택되지 않았습니다
			return;
		} else if(lowerMsgGrid.getCheckedList(0).length > 1){
			Common.Warning("<spring:message code='Cache.msg_SelectOne'/>", "Warning Dialog", function () { });          // 한개만 선택되어야 합니다
			return;
		}
		var sendUrl  = "/groupware/message/manage/goMessageViewerListPopup.do?"+
			"messageID="+lowerMsgGrid.getCheckedList(0)[0].MessageID+
			"&messageVer="+lowerMsgGrid.getCheckedList(0)[0].Version+
			"&folderID="+lowerMsgGrid.getCheckedList(0)[0].FolderID+
			"&CLBIZ="+bizSection; 	// CLBIZ 게시판 내용을 가져오는 것이라 조회 조건에는 'CLBIZ=board'로 조회.
		parent.Common.open("","messageViewer","<spring:message code='Cache.lbl_SearchorList'/>",sendUrl ,"700px","525px","iframe",true,null,null,true);
	});
	
    // 페이지 당 목록 갯수 변경.
    $("#selectPageSize").on('change', function(){
          selectMessageGridList();
    });	
	
	$("#"+objectName+" a[data-role=operation]").on("click", function(e) {
		var target = e.target;
		var operationType = $(target).attr("data-operation");
		var messageIDs = '';
		
		$.each(lowerMsgGrid.getCheckedList(0), function(i,obj){
			messageIDs += obj.MessageID + ';'
		});
		
		if(messageIDs == ''){
			Common.Warning("<spring:message code='Cache.msg_MsgIsntSel' />"); // 게시글이 선택되지 않았습니다.
			return;
		}

		_CallBackMethod = new Function(objectName + "." + operationType + "Message()");
		Common.open("", "commentPopup", "<spring:message code='Cache.lbl_ReasonForProcessing'/>", "/groupware/message/manage/goCommentPopup.do?mode=" + operationType, "300px", "220px", "iframe", true, null, null, true);
	});

	// 게시물 잠금 기능.
	this.lockMessage = function() {
		var messageIDs = '';
		
		$.each(lowerMsgGrid.getCheckedList(0), function(i, obj) {
            messageIDs += obj.MessageID + ';'
      	});
		
		if (messageIDs === '') {
            Common.Warning("<spring:message code='Cache.msg_MsgIsntSel' />"); 	// 게시글이 선택되지 않았습니다.
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
		                  // 재조회
		                  selectMessageGridList();
		                  $("#hiddenComment").val("");
		            }else{
		                  Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생헸습니다.
		            }
		      },
		      error: function(response, status, error){
		            CFN_ErrorAjax("/groupware/message/manage/lockMessage.do", response, status, error);
		      }
		});
	}
	
	// 잠금해제 기능
	this.unlockMessage = function() {
		var messageIDs = '';
		
		$.each(lowerMsgGrid.getCheckedList(0), function(i,obj){
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
					// 재조회
					selectMessageGridList();
					$("#hiddenComment").val("");
				}else{
					Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생헸습니다.
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/message/manage/unlockMessage.do", response, status, error);
			}
		});
	}
	
	// 삭제 기능
	this.deleteMessage = function() {
		var messageIDs = '';
		$.each(lowerMsgGrid.getCheckedList(0), function(i,obj){
        	messageIDs += obj.MessageID + ';'
      	});
		if (messageIDs === '') {
			Common.Warning("<spring:message code='Cache.msg_Common_03'/>", "Warning Dialog", function () { });          // 삭제할 항목을 선택하여 주십시오.
			return;
		}
		$.ajax({
			type:"POST"
			, url:"/groupware/message/manage/deleteMessage.do"
			, data:{
	            "messageID": messageIDs
	            ,"comment": $("#hiddenComment").val()
	      	}
			, success : function(data) {
				if (data.status === 'SUCCESS') {         //성공시 Grid재조회 및 필드 입력항목 초기화
					Common.Warning("<spring:message code='Cache.msg_50'/>"); // 삭제되었습니다.
					selectMessageGridList();
					$("#hiddenComment").val("");
				} else {
					Common.Warning("<spring:message code='Cache.msg_apv_030'/>");	//오류가 발생헸습니다.
				}
			}
			, error : function(response, status, error) {
		    	CFN_ErrorAjax("/groupware/message/manage/deleteMessage.do", response, status, error);
		    }
		});
	}

	// 복원 기능.
	this.restoreMessage = function() {
		var messageIDs = '';
		
		$.each(lowerMsgGrid.getCheckedList(0), function(i, obj){
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
                        selectMessageGridList();
                        $("#hiddenComment").val("");
                  }else{
                        Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생헸습니다.
                  }
            },
            error: function(response, status, error){
                  CFN_ErrorAjax("/groupware/message/manage/restoreMessage.do", response, status, error);
            }
      });
		
	}
	
//	initLoad();
		
}

var messageManage;

$(document).ready(function(){
	messageManage = new boardMessageManageByType('messageManage');
	messageManage.initContent();
});
	
/**
 * 수정요청사항게시물 관련은 소스에 미구현 사항이라고 적혀 있음.
 /smarts4j.groupware/src/main/webapp/WEB-INF/views/user/board/BoardViewPopup.jsp
 68 line.
 관련 테이블인 board_request_modify 테이블은 데이터가 비어있음.
 아래 함수는 구현하다 멈춘 내용으로 주석으로 기록.
 */

/*
//수정요청 게시물 상태 변경
function requestStatusPopup(pRequestID, pAnswer, pStatus){
	var url =  "/groupware/board/manage/goRequestStatusPopup.do";
		url += "?requestID=" + pRequestID;
		url += "&answer=" + encodeURIComponent(pAnswer);
		url += "&status=" + pStatus;
		url += "&domainID=" + confBoard.domainID;
	
	Common.open("", "requestStatusPopup", "<spring:message code='Cache.lbl_ModificationRequest'/>", url, "360px", "220px", "iframe", true, null, null, true);
}
*/

</script>
