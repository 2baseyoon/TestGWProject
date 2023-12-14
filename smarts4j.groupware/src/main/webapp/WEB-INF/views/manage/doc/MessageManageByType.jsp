<%@page import="egovframework.baseframework.util.PropertiesUtil,egovframework.coviframework.util.DicHelper"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>

<script type="text/javascript" src="/groupware/resources/script/admin/boardAdmin.js<%=resourceVersion%>"></script>
<div class="cRConTop titType AtnTop">
	<h2 class="title"><spring:message code='Cache.lbl_DeleteDisposal'/></h2> <!-- 폐기함 -->
</div>
<div class="cRContBottom mScrollVH">
<form id="form1">
	<div id="topitembar03" class="inPerView type02 sa04 active">
		<div>
			<div class="selectCalView">
				<span><spring:message code='Cache.lbl_Section'/></span>
				<select id="searchType" class="selectType02">
					<option value=""><spring:message code="Cache.lbl_selection"/></option>
					<option value="Subject"><spring:message code="Cache.lbl_subject"/></option>
					<option value="CreatorName"><spring:message code="Cache.lbl_Register"/></option>
					<option value="BodyText"><spring:message code="Cache.lbl_Contents"/></option>
				</select>
			</div>
			<div class="selectCalView">
				<span><spring:message code='Cache.lbl_SearchCondition'/></span>
				<input type="text" id="searchText" />
			</div>
			<div class="selectCalView">
				<span><spring:message code='Cache.lblSearchScope'/></span>
				<div id="divCalendar" class="dateSel type02">
					<input type="text" id="startDate" class="adDate"/> ~ 
					<input type="text" kind="twindate" date_startTargetID="startDate" id="endDate" class="adDate"/>
				</div>
			</div>
			<input id="searchBtn" type="button" value="<spring:message code='Cache.btn_search'/>" class="btnTypeDefault btnSearchBlue nonHover" />
		</div>
	</div>		
	<div class="sadminContent">
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<div class="pagingType02 buttonStyleBoxLeft">
					<a onclick="commentPopup('restore')" class="btnTypeDefault" ><spring:message code="Cache.lbl_Restore"/> </a>
					<a id="btnReadedUsers" class="btnTypeDefault"><spring:message code="Cache.lbl_SearchorList"/></a>
					<a id="btnHistory" class="btnTypeDefault"><spring:message code="Cache.lbl_ProcessingHistory"/></a>
				</div>
			</div>
			<div class="buttonStyleBoxRight">
				<select id="selectPageSize" class="selectType02 listCount">
					<option value="10">10</option>
					<option value="20">20</option>
					<option value="30">30</option>
				</select>
				<button id="btnRefresh" class="btnRefresh" type="button" href="#" > </button>
			</div>
		</div>	
		<div class="sadminMTopCont">
			<div id="lowerMessageGrid" class="tblList tblCont"></div>
		</div>
	</div>
	<input type="hidden" id="hiddenMenuID" value=""/>
	<input type="hidden" id="hiddenFolderID" value=""/>
	<input type="hidden" id="hiddenMessageID" value=""/>
	<input type="hidden" id="hiddenComment" value="" />
</form>
</div>
<script type="text/javascript">
// # /manage/doc/MessageManageByType.jsp (폐기함관리)

(function() {
	var bizSection = "Doc";
	var boardType = "DeleteNExpire";
	var lowerMsgGrid = new coviGrid();		//게시글 Grid
	
	var msgHeaderData = boardAdmin.getGridHeader("DeleteNExpire");
	
	var initLoad = function() {
		setMessageGridConfig();
		selectMessageGridList();
	}
	
	// 새로고침
	$("#btnRefresh").on('click', function(){
		selectMessageGridList();
	});
	
	// 페이지 당 목록 갯수 변경.
	$("#selectPageSize").on('change', function(){
		selectMessageGridList();
	});
	
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
    
	// 조회자목록 클릭 이벤트
	$("#btnReadedUsers").on("click", function() {
		if (lowerMsgGrid.getCheckedList(0).length === 0) {
			Common.Warning("<spring:message code='Cache.msg_MsgIsntSel'/>", "Warning Dialog", function () { });	// 게시물이 선택되지 않았습니다
			return;
		} else if (lowerMsgGrid.getCheckedList(0).length > 1) {
			Common.Warning("<spring:message code='Cache.msg_SelectOne'/>", "Warning Dialog", function () { });	// 한개만 선택되어야 합니다
            return;
		}
		var sendUrl  = "/groupware/message/manage/goMessageViewerListPopup.do?"+
        "messageID="+lowerMsgGrid.getCheckedList(0)[0].MessageID+
        "&messageVer="+lowerMsgGrid.getCheckedList(0)[0].Version+
        "&folderID="+lowerMsgGrid.getCheckedList(0)[0].FolderID+
        "&CLBIZ="+bizSection;   // CLBIZ 게시판 내용을 가져오는 것이라 조회 조건에는 'CLBIZ=Doc'로 조회.
  		parent.Common.open("","messageViewer","<spring:message code='Cache.lbl_SearchorList'/>",sendUrl ,"700px","525px","iframe",true,null,null,true);
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
	
	//게시글 그리드 세팅
	var setMessageGridConfig = function() {
		lowerMsgGrid.setGridHeader(msgHeaderData);
		
		var messageConfigObj = {
			targetID : "lowerMessageGrid",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
			height:"auto",
			page : {
				pageNo:1,
				pageSize:10
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
				"categoryID": $("#selectCate").val(),
				"domainID":confMenu.domainId,
				"startDate":$("#startDate").val(),
				"endDate":$("#endDate").val(),
				"searchType":$("#searchType").val(),
				"searchText":$("#searchText").val()
			},
		});
	}
	
	// 복원 팝업. 사유 입력.
	this.commentPopup = function (pMode) {	// mode: restore
		_CallBackMethod = new Function(pMode + "Message()");
		Common.open("", "commentPopup", "<spring:message code='Cache.lbl_ReasonForProcessing'/>", "/groupware/message/manage/goCommentPopup.do?mode=" + pMode, "300px", "220px", "iframe", true, null, null, true);
	}
	
	// 복원 기능.
	this.restoreMessage = function () {
		var messageIDs = '';
		
		$.each(lowerMsgGrid.getCheckedList(0), function(i,obj){
			messageIDs += obj.MessageID + ';'
		});
		
		if(messageIDs == ''){
			 Common.Warning("<spring:message code='Cache.msg_gw_SelectResotre'/>", "Warning Dialog", function () { }); 	// 복원처리할 항목을 선택해주세요.
	       return;
		}
		
	    $.ajax({
	    	type : "POST",
	    	url : "/groupware/message/manage/restoreMessage.do",
	    	data : {
	    		"messageID": messageIDs
	    		,"comment": $("#hiddenComment").val()
	    	},
	    	success : function(data) {
	    		if (data.status=='SUCCESS') {		//성공시 Grid재조회 및 필드 입력항목 초기화
	    			Common.Warning("<spring:message code='Cache.msg_ProcessOk'/>"); // 요청하신 작업이 정상적으로 처리되었습니다.
	    			selectMessageGridList();
	    			$("#hiddenComment").val("");
	    		} else {
	    			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
	    		}
	    	},
	    	error:function(response, status, error){
	    	     CFN_ErrorAjax("/groupware/message/manage/restoreMessage.do", response, status, error);
	    	}
	    });
	}
	
	
	initLoad();
})();

</script>
