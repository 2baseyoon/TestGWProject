<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>

<script type="text/javascript" src="/groupware/resources/script/admin/boardAdmin.js<%=resourceVersion%>"></script>

<script type="text/javascript">
var confBoard = {
		lowerMsgGrid : new coviGrid(),		//게시글 Grid 
		folderGrid :new coviTree(),		//폴더 Grid
		msgHeaderData : boardAdmin.getGridHeader("Normal"),
		domainID :confMenu.domainId,
		initContent:function (){
			$("#boardFolder").click(function () {//폴더 새로고침
				confBoard.setFolderTreeData();
			});
			$("#folderOpen").click(function () {//전체열기
				confBoard.folderGrid.expandAll();
			});
			$("#folderClose").click(function () {//전체닫기
				confBoard.folderGrid.collapseAll();
			});
			//검색
			$("#searchText").on( 'keydown',function(){
				if(event.keyCode=="13"){
					$('#icoSearch').trigger('click');

				}
			});	
			$("#icoSearch").on( 'click',function(){
				var keyword = $("#searchText").val();
				if (keyword =="") return;
				confBoard.folderGrid.findKeyword("FolderName", keyword);
			});
			
			this.setMessageGridConfig();
			var height=parseInt($("#folderGrid").css("height"))-20;
			this.folderGrid.setConfig({
				targetID : "folderGrid",					// HTML element target ID
				theme: "AXTree_none",
				colGroup:[ {key: "FolderName",			// 컬럼에 매치될 item 의 키
				 			indent: true,					// 들여쓰기 여부
				 			label:'<spring:message code="Cache.lbl_BoardNm"/>',
				 			width: "170",
							align: "left",		
				 			getIconClass: function(){		// indent 속성 정의된 대상에 아이콘을 지정 가능
				 				return "ic_folder";
				 			},
				 			formatter:function(){
				           		var  html = "<a href='#' id='editBoard' data-folderid='"+this.item.FolderID+"' data-memberof='"+this.item.MemberOf+"'  onclick='confBoard.editBoardPopup()'>" + this.item.FolderName + "</a>";
								return html;
				 			}},
				    	{key:'FolderID',  label:'ID', width:'50', align:'center'},						//FolderID							
				    	{key:'FolderTypeName', label:coviDic.dicMap["lbl_FolderType"], width:'80', align:'left'},		//폴더 타입
				    	{key:'DeleteDate', label:coviDic.dicMap["lbl_DeleteDate"]+"(" + coviDic.dicMap["lbl_Restore"]+")", width:'80', align:'center',  		formatter:function () {
				    			return boardAdmin.formatFolderDeleteDate(this); 		}	},
				    	{key:'RegisterName',  label:coviDic.dicMap["lbl_Register"], width:'100', align:'center'},		//생성 유저
				    	{key:'IsDisplay', label:coviDic.dicMap["lbl_Display"], width:'80', align:'center',			//표시여부
				    		formatter:function () { 			return boardAdmin.formatUpdateFlag(this); 		}
				    	},      
				    	{key:'IsUse', label:coviDic.dicMap["lbl_selUse"], width:'80', align:'center',					//사용여부
				    		formatter:function () {			return boardAdmin.formatUpdateFlag(this);   		}
				     	},      
				    	{key:'RegistDate', label:coviDic.dicMap["lbl_RegistrationDate"]  + Common.getSession("UR_TimeZoneDisplay"), width:'100', align:'center', formatter: function(){
							return CFN_TransLocalTime(this.item.RegistDate);
						}},	//등록일자     
						  {key:'',  label:"<spring:message code='Cache.lbl_action'/>",width:'300',align:'center', display:true, sort:false, formatter:function () {
			 		  			var	html = '<a href="javascript:;" class="btnTypeDefault btnMoveUp" onclick=""><spring:message code="Cache.lbl_apv_up"/></a>';
			 		  			html += '<a href="javascript:;" class="btnTypeDefault btnMoveDown" onclick=""><spring:message code="Cache.lbl_apv_down"/></a>';
			 		  			html += '<a href="javascript:;" class="btnTypeDefault btnPlusAdd" onclick=""><spring:message code="Cache.btn_apv_Person"/></a>';
			 		  			html += '<a href="javascript:;" class="btnTypeDefault btnSaRemove" onclick=""><spring:message code="Cache.lbl_delete"/></a>';
			 		  			return html;
		   		        	}}
						],						// tree 헤드 정의 값
				showConnectionLine:true,		// 점선 여부
				relation:{
					parentKey: "MemberOf",		// 부모 아이디 키
					childKey: "FolderID"			// 자식 아이디 키
				},
				persistExpanded: false,		// 쿠키를 이용해서 트리의 확장된 상태를 유지 여부
				persistSelected: false,			// 쿠키를 이용해서 트리의 선택된 상태를 유지 여부
				colHead: {
					display:true
				},
				height:parseInt($("#folderGrid").css("height"))-20,
				body:{onclick:function(idx, item){ //[Function] 바디 클릭 이벤트 콜백함수
			            if(item.FolderType != "Folder"){
			            	confBoard.changeMessageGridList(item.FolderID, item.FolderPath);
			            } }},
				fitToWidth:true // 너비에 자동 맞춤
			});
			$("#folderGrid .AXTreeBody").css("height",parseInt($("#folderGrid").css("height"))-20);
			confBoard.setFolderTreeData();
		},
		setFolderTreeData:function(){
			$.ajax({
				url:"/groupware/admin/selectFolderTreeData.do",
				type:"POST",
				data:{
					"domainID" :confMenu.domainId,
					"bizSection": "Board"
				},
				async:false,
				success:function (data) {
					var List = data.list;
					confBoard.folderGrid.setList(List);
					confBoard.folderGrid.expandAll(1);	
				},
				error:function(response, status, error){
		   	     CFN_ErrorAjax("/groupware/resource/getFolderResourceTreeList.do", response, status, error);
				}
		   	});
		},
		setMessageGridConfig:function(){
			this.lowerMsgGrid.setGridHeader(this.msgHeaderData);
			
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
			
			this.lowerMsgGrid.setGridConfig(messageConfigObj);
			this.lowerMsgGrid.config.fitToWidthRightMargin = 0;
		},
		changeMessageGridList:function (pFolderID, pFolderPath){
			//폴더 변경시 검색항목 초기화
			if($("#hiddenFolderID").val() != pFolderID){
				$("#hiddenFolderID").val(pFolderID);
				$("#searchType").bindSelectSetValue("");
				$("#searchText").val("");
				$("#startDate, #endDate").val("");
			}
			
			//검색영역 및 검색조건 체크
			if($("#searchType").val() == "" && $("#searchText").val()!=""){
				Common.Warning("<spring:message code='Cache.msg_SelSearchGubun'/>", "Warning Dialog", function () { });          // 검색구분을 선택하세요
				return;		
			}
			$("#boardPath").text(pFolderPath.substr(0, pFolderPath.length-1).replace(/>/gi, ' > '));
			this.setMessageGridConfig();
			this.lowerMsgGrid.bindGrid({
				ajaxUrl:"/groupware/admin/selectMessageGridList.do",
				ajaxPars: {
					"bizSection": bizSection,
					"boardType": boardType,
					"folderID": pFolderID,
					"folderIDs": $("#hiddenFolderIDs").val(),
					"categoryID": $("#selectCate").val(),
					"domainID":$("#domainIDSelectBox").val(),
					"startDate":$("#startDate").val(),
					"endDate":$("#endDate").val(),
					"searchType":$("#searchType").val(),
					"searchText":$("#searchText").val()
				},
			});
		},
		editBoardPopup:function(pFolderID){
			var pFolderID=$(this).data("folderid");
			parent.Common.open("","setBoard","<spring:message code='Cache.lbl_BoardConfigSet'/>|||<spring:message code='Cache.lbl_FolderModify'/>","/groupware/admin/goBoardConfigPopup.do?folderID="+pFolderID+"&mode=edit&bizSection="+bizSection+"&domainID="+this.domainID,"750px","600px","iframe",false,null,null,true);
		}

}
$(document).ready(function(){
	confBoard.initContent();
});



var bizSection = CFN_GetQueryString("CLBIZ");
var boardType = CFN_GetQueryString("boardType") == 'undefined'? "Normal" : CFN_GetQueryString("boardType");
var lowerMsgGrid = new coviGrid();		//게시글 Grid 

var sessionObj = Common.getSession();

//개별호출-일괄호출
Common.getDicList(["lbl_PriorityOrder","lbl_BoardNm","lbl_FolderType","lbl_DeleteDate","lbl_Restore","lbl_Register","lbl_Display","lbl_selUse","lbl_RegistrationDate",
                   "lbl_no2", "lbl_BoardCate2", "lbl_subject", "lbl_State2", "lbl_Register", "lbl_attach", "lbl_RegistDate", "lbl_ExpireDate",
                   "lbl_FieldNm","lbl_FieldType","lbl_Limit2","lbl_FieldSize","lbl_DisplayList","lbl_ListSearchItem","lbl_surveyIsRequire",
                   "lbl_BoardCate2", "lbl_SingoUserNm", "lbl_ReportDate","lbl_TrialContent", "lbl_RegistDate","lbl_attach","lbl_LockDate",
                   "lbl_State2","lbl_Requester","lbl_RequestDate","lbl_RequestContent","lbl_ProcessContents","lbl_State",
                   "lbl_writer","lbl_PersonNo", "lbl_CreateDates","lbl_ReadCount","lbl_AnswerNo",
                   "lbl_Approval","lbl_Rejected","lbl_Lock","lbl_RegistReq","lbl_TempSave","lbl_delete","lbl_expiration"]);
//페이지 로드시 Normal 헤더로 설정
var msgHeaderData = boardAdmin.getGridHeader("Normal");
 
function selectFolderGridListByTree(pMenuID, pFolderID, pFolderType, pFolderPath){
	//신고 게시물에서 폴더/게시판 관리하는 트리메뉴로 돌아왔을때 Normal로 처리
	if(boardType != "Normal"){//트리에서 조회되는 게시판 타입: Normal
		boardType = "Normal";
	}
	$("#hiddenMenuID").val(pMenuID);
	lowerMsgGrid = new coviGrid();
	changeBoardUI(pFolderType);		//트리에서 선택하여 조회할때 화면 설정

	if(pFolderType=="Root" || pFolderType=="Folder"){ 
		selectFolderGridList( pMenuID, pFolderID );			
	} else {
		selectFolderPath(pFolderPath + pFolderID + ";");
		selectMessageGridList(pFolderID);
	}
}


//폴더 그리드 세팅
function setFolderGrid(){
	selectFolderGridList();				
}


//폴더 그리드 Config 설정
function setFolderGridConfig(){
	
}


 /************************************************/
/* 폴더 그리드의 게시판명을 선택하면 해당하는 게시글들을 조회 ******/

//게시글 그리드 세팅
function setMessageGridConfig(){
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


//게시글 상위 경로 조회
//JS로 이동 예정
function selectFolderPath(pFolderPath){
	$.ajax({
		type:"POST",
		data:{
			"folderPath" : pFolderPath,
		},
		url:"/groupware/board/selectFolderPath.do",
		success:function (data) {
			$("#boardPath").text(data.folderPath.substr(0, data.folderPath.length-1).replace(/>/gi, ' > '));
		},
		error:function(response, status, error){
		     CFN_ErrorAjax("board/selectFolderPath.do", response, status, error);
		}
	});
}

//게시글 Grid 조회 
function selectMessageGridList(pFolderID){
	//폴더 변경시 검색항목 초기화
	if($("#hiddenFolderID").val() != pFolderID){
		$("#hiddenFolderID").val(pFolderID);
		$("#searchType").bindSelectSetValue("");
		$("#searchText").val("");
		$("#startDate, #endDate").val("");
	}
	
	//검색영역 및 검색조건 체크
	if($("#searchType").val() == "" && $("#searchText").val()!=""){
		Common.Warning("<spring:message code='Cache.msg_SelSearchGubun'/>", "Warning Dialog", function () { });          // 검색구분을 선택하세요
		return;		
	}
	
	setMessageGridConfig();
	lowerMsgGrid.bindGrid({
		ajaxUrl:"/groupware/admin/selectMessageGridList.do",
		ajaxPars: {
			"bizSection": bizSection,
			"boardType": boardType,
			"folderID": pFolderID,
			"folderIDs": $("#hiddenFolderIDs").val(),
			"categoryID": $("#selectCate").val(),
			"domainID":$("#domainIDSelectBox").val(),
			"startDate":$("#startDate").val(),
			"endDate":$("#endDate").val(),
			"searchType":$("#searchType").val(),
			"searchText":$("#searchText").val()
		},
	});
}


//문서번호 Grid 조회 
function selectDocNumberGridList(){
	setMessageGridConfig();
	
	lowerMsgGrid.bindGrid({
		ajaxUrl:"/groupware/admin/selectDocNumberGridList.do",
		ajaxPars: {
			"domainID":$("#domainIDSelectBox").val(),
			"boardType": boardType
		},
		onLoad: function(){
			$('#exAutoDocNumber1').text("");
			$('#exAutoDocNumber2').text("");		// onLoad 전 초기화.
			getFieldInfos();
		}
	});
}

//boardType에 따라 화면의 타이틀, 버튼 컨트롤 표시/숨김처리
function changeBoardUI(pFolderType){
	//게시판 Title 변경
	var boardTitle = "<spring:message code='Cache.lblBoardManage'/>";

	switch(boardType){
		case "Normal":
			if(bizSection == "Board"){
				boardTitle = "<spring:message code='Cache.lblBoardManage'/>";	//게시판관리
			} else {
				boardTitle = "<spring:message code='Cache.BizSection_Doc'/>";	//문서관리
			}
			
			if(pFolderType=="Root" || pFolderType=="Folder"){
				if(pFolderType=="Folder"){
					$("#btnAdd").show();
				} else {
					$("#btnAdd").hide();
				}
				
				$("#boardPath, #divMessageView").hide();				//게시판 경로 및 게시글 Grid항목 숨김
				$("#topitembar01, #folderGrid").show();					//폴더 정보 표시하는 Grid 및 버튼 컨트롤 표시
			} else {
				$("#btnAdd").hide();
				$("#boardPath, #divMessageView").show();				//게시판 경로 및 게시글 Grid항목 표시
				$("#topitembar01, #folderGrid").hide();					//폴더 정보를 표시하는 Grid 및 버튼 컨트롤 숨김
			}
			msgHeaderData = boardAdmin.getGridHeader("Normal");
			$("#btnDelMsg, #btnLockMsg, #btnUnlockMsg, #btnRestoreMsg").show();
			$("input[name=btnDocInfo], input[name=btnDocNumber], #btnExcel, #SearchStats").hide();
			break;
		case "Report":
			boardTitle = "<spring:message code='Cache.lbl_SingoList'/>";	//신고게시물 관리
			msgHeaderData = boardAdmin.getGridHeader("Report");

			//엑셀, 복원, 잠금해제 버튼 숨김
			$("input[name=btnDocInfo], input[name=btnDocNumber], #btnExcel, #SearchStats, #btnRestoreMsg, #btnUnlockMsg").hide();			
			break;
		case "Lock":
			boardTitle = "<spring:message code='Cache.lbl_LockList'/>";		//잠금게시물 관리
			msgHeaderData = boardAdmin.getGridHeader("Lock");
			$("input[name=btnDocInfo], input[name=btnDocNumber], #btnExcel, #SearchStats, #btnLockMsg, #btnRestoreMsg").hide();
			break;
		case "DeleteNExpire":
			boardTitle = "<spring:message code='Cache.lbl_DelExpireList'/>";//삭제/만료게시물 관리
			msgHeaderData = boardAdmin.getGridHeader("DeleteNExpire");
			$("input[name=btnDocInfo], input[name=btnDocNumber], #btnExcel, #SearchStats, #btnDelMsg, #btnLockMsg, #btnUnlockMsg").hide();
			break;	
		case "RequestModify":
			boardTitle = "<spring:message code='Cache.lbl_RequestModifyList'/>";//수정요청 게시물 관리
			msgHeaderData = boardAdmin.getGridHeader("RequestModify");
			$("input[name=btnDocInfo], input[name=btnDocNumber], #SearchStats, #btnRestoreMsg, #btnUnlockMsg").hide();
			break;
		case "Stats":
			boardTitle = "<spring:message code='Cache.CN_233'/>";			//게시 통계
			msgHeaderData = boardAdmin.getGridHeader("Stats");
			$("input[name=btnDocInfo], input[name=btnDocNumber], #btnRestoreMsg, #btnDelMsg, #btnLockMsg, #btnUnlockMsg").hide();
			break;
		case "OwnerManage":
			boardTitle = "소유권 관리";
			msgHeaderData = boardAdmin.getGridHeader("OwnerManage");
			$("input[name=btnDocNumber], #btnRestoreMsg, #btnDelMsg, #btnLockMsg, #btnUnlockMsg").hide();
			$("input[name=btnDocInfo]").show();
			break;
		case "DocNumberManage":
			boardTitle = "문서번호 발번 관리";
			msgHeaderData = boardAdmin.getGridHeader("DocNumberManage");
			$("#topitembar02").find("input[type=button]").hide();
			$("#topitembar03").hide();
			$("#topitembar04").show();
			$("input[name=btnDocNumber]").show();
			break;
		case "DocNumberStats":
			boardTitle = "문서번호 발번 현황";
			msgHeaderData = boardAdmin.getGridHeader("DocNumberStats");
			$("#topitembar02").hide();
			$("#topitembar03").hide();
			break;
		default:
	}
	
	$("span.con_tit").text(boardTitle);		//최상단 타이틀 변경
	
	//신고,잠금,삭제/만료, 수정요청,게시통계가 아닐경우 폴더 Grid표시
	if (boardType!="Normal"){
		if(boardType == "DocNumberManage" || boardType =="DocNumberStats"){
			selectDocNumberGridList();
			

			
		} else {
			selectMessageGridList();
		}
    	$("#topitembar01").hide();	//폴더 Grid관련 버튼컨트롤 숨김
        $("#folderGrid").hide()		//폴더 Grid 숨김
        $("#boardPath").hide();		//게시판 경로 네비게이터 숨김
    }

}

//사용자 정의 필드 위치 변경
function moveFolderGrid(pMode){
	if(folderGrid.getCheckedList(0).length == 0){
		Common.Warning("<spring:message code='Cache.msg_MsgIsntSel'/>", "Warning Dialog", function () { });          // 이동할 필드가 선택되지 않았습니다
		return;
	} else if(folderGrid.getCheckedList(0).length > 1){
		Common.Warning("<spring:message code='Cache.msg_SelectOne'/>", "Warning Dialog", function () { });          // 이동할 필드는 한개만 선택되어야 합니다
		return;
	}

	var param = folderGrid.getCheckedList(0)[0];	//체크된 Grid 데이터로 이동
	
	$.ajax({
    	type:"POST",
    	url: "/groupware/admin/moveFolder.do",
    	dataType : 'json',
    	data: {
        	"bizSection": bizSection,
        	"domainID": param.DomainID,
        	"menuID": param.MenuID,
        	"folderPath": param.FolderPath,
        	"folderType": param.FolderType,
        	"folderID": param.FolderID,
        	"sortKey": param.SortKey,
        	"mode": pMode
    	},
    	success:function(data){
    		if(data.status=='SUCCESS'){
        		if(data.message != undefined && data.message != ""){	//최상위, 최하위 항목의 경우에는 변경 불가 메시지 표시
        			Common.Warning(data.message); //변경했습니다.
            	} else {
            		Common.Warning("<spring:message code='Cache.msg_Changed'/>"); //변경했습니다.
                }
        		setTreeData();
				//myFolderTree.expandAll(2);
      			folderGrid.reloadList();
      		}else{
      			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");		//오류가 발생헸습니다.
      		}
    	}, 
    	error:function(response, status, error){
    	     CFN_ErrorAjax("/groupware/admin/moveFolder.do", response, status, error);
    	}
    });
}

//최상위폴더, 폴더에서 표시되는 추가버튼 선택시 호출
function createBoardPopup(){
	parent.Common.open("","setBoard","<spring:message code='Cache.lbl_BoardConfigSet'/>|||<spring:message code='Cache.lbl_FolderAdd'/>","/groupware/admin/goBoardConfigPopup.do?folderID="+$("#hiddenFolderID").val()+"&menuID="+$("#hiddenMenuID").val()+"&mode=create&bizSection="+bizSection+"&domainID="+$("#domainIDSelectBox").val(),"750px","600px","iframe",false,null,null,true);
}

//폴더/게시판 수정 팝업
function editBoardPopup(pFolderID){
	parent.Common.open("","setBoard","<spring:message code='Cache.lbl_BoardConfigSet'/>|||<spring:message code='Cache.lbl_FolderModify'/>","/groupware/admin/goBoardConfigPopup.do?folderID="+pFolderID+"&mode=edit&bizSection="+bizSection+"&domainID="+$("#domainIDSelectBox").val(),"750px","600px","iframe",false,null,null,true);
}

function createDocNumberPopup(){
	parent.Common.open("","createDocNumber","문서번호 등록","/groupware/admin/goDocNumberManagePopup.do?mode=create","550px","250px","iframe",false,null,null,true);
}

function editDocNumberPopup(pDomainID, pManagerID){
	parent.Common.open("","editDocNumber","문서번호 수정","/groupware/admin/goDocNumberManagePopup.do?mode=update&managerID="+pManagerID+"&domainID="+pDomainID,"550px","250px","iframe",false,null,null,true);
}

//게시판 삭제
function deleteBoard(){
	var folderIDs = '';
	
	$.each(folderGrid.getCheckedList(0), function(i,obj){
		folderIDs += obj.FolderID + ';'
	});
	
	if(folderIDs == ''){
		 Common.Warning("<spring:message code='Cache.msg_Common_03'/>", "Warning Dialog", function () { });          // 삭제할 항목을 선택하여 주십시오.
       return;
	}
	
	 Common.Confirm("<spring:message code='Cache.msg_Common_08'/>", 'Confirmation Dialog', function (result) {       // 선택한 항목을 삭제하시겠습니까?
       if (result) {
          $.ajax({
          	type:"POST",
          	url:"/groupware/admin/deleteBoard.do",
          	data:{
          		"folderID": folderIDs
          	},
          	success:function(data){
          		if(data.status=='SUCCESS'){		//성공시 Grid재조회 및 필드 입력항목 초기화
          			Common.Warning("<spring:message code='Cache.msg_50'/>"); // 삭제되었습니다.
          			folderGrid.reloadList();
          		}else{
          			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
          		}
          	},
          	error:function(response, status, error){
          	     //TODO 추가 오류 처리
          	     CFN_ErrorAjax("/groupware/admin/deleteBoard.do", response, status, error);
          	}
          });
       }
   });
}

//IsUse, IsDisplay 변경
function updateFlag( pFolderID, pFlagValue, pFlagKey){
	if(pFolderID != undefined && pFolderID != ""){
       $.ajax({
       	type:"POST",
       	url:"/groupware/admin/updateBoardFlag.do",
       	data:{
       		"folderID": pFolderID,
       		"flagKey" : pFlagKey,					//IsUse, IsDisplay의 이름으로 DB스크립트 컬럼 지정
       		"flagValue":(pFlagValue=="Y"?"N":"Y")	//현재 화면에서 조회된 값이 Y면 N으로 설정
       	},
       	success:function(data){
       		if(data.status=='SUCCESS'){
       			Common.Warning("<spring:message code='Cache.msg_ProcessOk'/>");
       			//page reload
       			folderGrid.reloadList();
       		}else{
       			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
       		}
       	},
       	error:function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("/groupware/admin/boardManage.do", response, status, error);
		}
       });
	}
}

//IsUse, IsDisplay 변경
function updateDocNumberFlag( pManagerID, pFlagValue){
	if(pManagerID != undefined && pManagerID != ""){
       $.ajax({
       	type:"POST",
       	url:"/groupware/admin/updateDocNumberFlag.do",
       	data:{
       		"managerID": pManagerID,
       		"flagValue":(pFlagValue=="Y"?"N":"Y")	//현재 화면에서 조회된 값이 Y면 N으로 설정
       	},
       	success:function(data){
       		if(data.status=='SUCCESS'){
       			Common.Warning("<spring:message code='Cache.msg_ProcessOk'/>");
       			//page reload
       			lowerMsgGrid.reloadList();
       		}else{
       			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
       		}
       	},
       	error:function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("/groupware/admin/updateDocNumberFlag.do", response, status, error);
		}
       });
	}
}


//폴더 복원
function restoreFolder(pFolderID){
	if(pFolderID != undefined && pFolderID != ""){
		
		Common.Confirm("<spring:message code='Cache.msg_itemEnabledQ'/>", 'Confirmation Dialog', function (result) {       // 해당 항목을 다시 사용할 수 있도록 처리하시겠습니까?
            if (result) {
		       $.ajax({
		       	type:"POST",
		       	url:"/groupware/admin/restoreFolder.do",
		       	data:{
		       		"folderID": pFolderID,
		       	},
		       	success:function(data){
		       		if(data.status=='SUCCESS'){
		       			Common.Warning("<spring:message code='Cache.msg_ProcessOk'/>"); //작업이 완료됐습니다.
		       			//page reload
		       			setTreeData();
						//myFolderTree.expandAll(2);
		      			folderGrid.reloadList();
		       		}else{
		       			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
		       		}
		       	},
		       	error:function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("/groupware/admin/boardManage.do", response, status, error);
				}
		       });
            }
        });
	}
}


//***************************************************************************************************************************/
//엑셀 다운로드
function ExcelDownload(){
	Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage'/>", "Confirmation Dialog", function(result){
   		if(result){
   			var headerName = getHeaderNameForExcel();
   			
   			var	sortKey = lowerMsgGrid.getSortParam("one").split("=")[1].split(" ")[0]; 
   			var	sortWay = lowerMsgGrid.getSortParam("one").split("=")[1].split(" ")[1]; 				  	
   			
   			location.href = "/groupware/admin/messageListExcelDownload.do?boardType="+boardType+"&domainID="+$("#domainIDSelectBox").val()+"&folderID="+$("#hiddenFolderID").val()+ "&startDate="+$("#startDate").val()+"&endDate="+$("#endDate").val()+"&sortKey="+sortKey+"&sortWay="+sortWay+"&headerName="+encodeURI(headerName)+"&searchText="+$("#searchText").val()+"&searchType="+$("#searchType").val()+"&bizSection="+bizSection;
   		}
	});
}

//엑셀용 Grid 헤더정보 설정
function getHeaderNameForExcel(){
	var returnStr = "";
	
   	for(var i=0;i<msgHeaderData.length; i++){
   	   	if(msgHeaderData[i].display != false && msgHeaderData[i].label != 'chk' && msgHeaderData[i].label != 'MessageID' && msgHeaderData[i].label != 'FolderID'){
			returnStr += msgHeaderData[i].label + "|";
   	   	}
	}
	
	return returnStr;
}
//***************************************************************************************************************************/


//조회자 목록 조회 팝업 - messageViewerListPopup.jsp
function showReadedUsers(){
	if(lowerMsgGrid.getCheckedList(0).length == 0){
		Common.Warning("<spring:message code='Cache.msg_MsgIsntSel'/>", "Warning Dialog", function () { });          // 게시물이 선택되지 않았습다.
		return;
	} else if(lowerMsgGrid.getCheckedList(0).length > 1){
		Common.Warning("<spring:message code='Cache.msg_SelectOne'/>", "Warning Dialog", function () { });          // 한개만 선택되어야 합니다.
		return;
	}
	
	var sendUrl  = "/groupware/admin/goMessageViewerListPopup.do?"+
		"messageID="+lowerMsgGrid.getCheckedList(0)[0].MessageID+
		"&messageVer="+lowerMsgGrid.getCheckedList(0)[0].Version+
		"&folderID="+lowerMsgGrid.getCheckedList(0)[0].FolderID+
		"&CLBIZ="+CFN_GetQueryString("CLBIZ");
	parent.Common.open("","messageViewer","<spring:message code='Cache.lbl_SearchorList'/>",sendUrl ,"700px","525px","iframe",false,null,null,true);
}

//처리 이력 조회 팝업 - messageHistoryListPopup.jsp
function showHistory(){
	if(lowerMsgGrid.getCheckedList(0).length == 0){
		Common.Warning("<spring:message code='Cache.msg_MsgIsntSel'/>", "Warning Dialog", function () { });          // 게시물이 선택되지 않았습다.
		return;
	} else if(lowerMsgGrid.getCheckedList(0).length > 1){
		Common.Warning("<spring:message code='Cache.msg_SelectOne'/>", "Warning Dialog", function () { });          // 한개만 선택되어야 합니다.
		return;
	}
	
	parent.Common.open("","messageHistory","<spring:message code='Cache.lbl_ProcessingHistory'/>","/groupware/admin/goMessageHistoryListPopup.do?messageID="+lowerMsgGrid.getCheckedList(0)[0].MessageID ,"840px","525px","iframe",false,null,null,true);
}
	
//삭제, 복원, 잠금, 잠금해제 등을 할때 처리 사유 입력 팝업
function commentPopup(pMode) {
	//mode: delete, lock, unlock, restore
	parent._CallBackMethod = window[pMode + "Message"];//global function
	
	//CHECK: 처리 이력 팝업 제목 다국어처리 필요
	parent.Common.open("", "commentPopup", "<spring:message code='Cache.lbl_ReasonForProcessing'/>", "/groupware/admin/goCommentPopup.do?mode=" + pMode, "300px", "190px", "iframe", true, null, null, true);
}

//소유자, 등록부서 변경 조직도 팝업 호출
function changeDocInfo(pMode){
	if(lowerMsgGrid.getCheckedList(0).length == 0){
		Common.Warning("<spring:message code='Cache.msg_MsgIsntSel'/>", "Warning Dialog", function () { });          // 게시물이 선택되지 않았습다.
		return;
	} 
	if(pMode=="dept"){
		Common.open("","orgmap_pop","<spring:message code='Cache.lbl_DeptOrgMap'/>","/covicore/control/goOrgChart.do?callBackFunc="+pMode+"ChangeDocInfo_CallBack&type=C1","1040px","600px","iframe",true,null,null,true);
	} else if(pMode=="owner") {
		Common.open("","orgmap_pop","<spring:message code='Cache.lbl_DeptOrgMap'/>","/covicore/control/goOrgChart.do?callBackFunc="+pMode+"ChangeDocInfo_CallBack&type=D1","1040px","600px","iframe",true,null,null,true);
	} else if(pMode=="total") {
		Common.open("","orgmap_pop","<spring:message code='Cache.lbl_DeptOrgMap'/>","/covicore/control/goOrgChart.do?callBackFunc="+pMode+"ChangeDocInfo_CallBack&type=D9","1040px","600px","iframe",true,null,null,true);
	}
	// 	CFN_OpenWindow("/covicore/cmmn/orgmap.do?functionName=" + pMode + "ChangeDocInfo_CallBack","<spring:message code='Cache.lbl_DeptOrgMap'/>",1000,580,"");
}

//소유자 변경
function ownerChangeDocInfo_CallBack(orgData){
	var ownerJSON =  $.parseJSON(orgData);
	var docInfo = new Object();
	var ownerCode = "";
	
	if(ownerJSON.length > 1){
		Common.Warning("단일 소유자만 설정할 수 있습니다.", "Warning Dialog", function () { });
 	 	return;
	}
	
	$(ownerJSON.item).each(function (i, item) {
  		sObjectType = item.itemType;
  		if(sObjectType.toUpperCase() == "USER"){ //사용자
  			ownerCode = item.UserCode;
  		}
 	});

 	if(ownerCode == ""){
 		Common.Warning("소유자를 선택해주세요.", "Warning Dialog", function () { });
 	 	return;
 	}
 	docInfo.ownerCode = ownerCode;
	ajaxCallChangeDocInfo(docInfo);		
}

//등록부서 변경
function deptChangeDocInfo_CallBack(orgData){
	var ownerJSON =  $.parseJSON(orgData);
	var docInfo = new Object();
	var registDept = "";
	
	if(ownerJSON.length > 1){
		Common.Warning("단일 부서만 설정할 수 있습니다.", "Warning Dialog", function () { });
 	 	return;
	}
	
	$(ownerJSON.item).each(function (i, item) {
  		if(item.itemType.toUpperCase() == "GROUP"){
  	  		registDept = item.GroupCode;
  	  	} else if(item.itemType.toUpperCase() == "USER"){
  	  		registDept = item.GroupCode;
  	  	}
 	});
	if(registDept == ""){
 		Common.Warning("담당부서를 선택해주세요.", "Warning Dialog", function () { });
 	 	return;
 	}
 	
	docInfo.registDept = registDept;
	ajaxCallChangeDocInfo(docInfo);	
}

//일괄 변경
function totalChangeDocInfo_CallBack(orgData){
	var ownerJSON =  $.parseJSON(orgData);
	var ownerCode = "";
	var registDept = "";
	var docInfo = new Object();
	
	if(ownerJSON.length > 1){
		Common.Warning("단일 소유자만 설정할 수 있습니다.", "Warning Dialog", function () { });
 	 	return;
	}
	
	$(ownerJSON.item).each(function (i, item) {
  		sObjectType = item.itemType;
  		if(item.itemType.toUpperCase() == "GROUP"){
  	  		registDept = item.GroupCode;
  	  	} else if(item.itemType.toUpperCase() == "USER"){
  	  		ownerCode = item.UserCode;
  	  	}
 	});

	if(ownerCode == ""){
 		Common.Warning("소유자를 선택해주세요.", "Warning Dialog", function () { });
 	 	return;
 	}
	
	docInfo.ownerCode = ownerCode;
	docInfo.registDept = registDept;
	ajaxCallChangeDocInfo(docInfo);
}

function ajaxCallChangeDocInfo(pObj){
	var messageIDs = '';
	
	$.each(lowerMsgGrid.getCheckedList(0), function(i,obj){
		messageIDs += obj.MessageID + ';'
	});
	
	$.ajax({
    	type:"POST",
    	url:"/groupware/admin/changeDocInfo.do",
    	data:{
    		"messageID": messageIDs
    		,"ownerCode": pObj.ownerCode
    		,"registDept": pObj.registDept
    	},
    	success:function(data){
    		if(data.status=='SUCCESS'){		//성공시 Grid재조회 및 필드 입력항목 초기화
    			Common.Warning("<spring:message code='Cache.msg_ProcessOk'/>"); //요청하신 작업이 정상적으로 처리되었습니다.
    			selectMessageGridList($("#hiddenFolderID").val());
    			$("#hiddenComment").val("");
    		}else{
    			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
    		}
    	},
    	error:function(response, status, error){
    	     //TODO 추가 오류 처리
    	     CFN_ErrorAjax("/groupware/admin/deleteUserDefField.do", response, status, error);
    	}
    });
}

//수정요청 게시물 상태 변경
function requestStatusPopup( pRequestID, pAnswer, pStatus){
	parent.Common.open("", "requestStatusPopup", "<spring:message code='Cache.lbl_ModificationRequest'/>", "/groupware/admin/goRequestStatusPopup.do?requestID="+pRequestID+"&answer="+encodeURIComponent(pAnswer)+"&status="+pStatus+"&domainID="+$("#domainIDSelectBox").val(), "360px", "220px", "iframe", true, null, null, true);
}

function selectBoardTreePopup() {
	//CHECK: 게시판 트리메뉴 팝업 조회
	parent.Common.open("", "boardTreePopup", "<spring:message code='Cache.lbl_SelectBoard'/>", "/groupware/admin/goBoardTreePopup.do?bizSection="+bizSection, "400px", "300px", "iframe", true, null, null, true);
}

//게시글 삭제
function deleteMessage(){
	var messageIDs = '';
	
	$.each(lowerMsgGrid.getCheckedList(0), function(i,obj){
		messageIDs += obj.MessageID + ';'
	});
	
	if(messageIDs == ''){
		 Common.Warning("<spring:message code='Cache.msg_Common_03'/>", "Warning Dialog", function () { });          // 삭제할 항목을 선택하여 주십시오.
       return;
	}
	
    $.ajax({
    	type:"POST",
    	url:"/groupware/admin/deleteMessage.do",
    	data:{
    		"messageID": messageIDs
    		,"comment": $("#hiddenComment").val()
    	},
    	success:function(data){
    		if(data.status=='SUCCESS'){		//성공시 Grid재조회 및 필드 입력항목 초기화
    			Common.Warning("<spring:message code='Cache.msg_50'/>"); // 삭제되었습니다.
    			selectMessageGridList($("#hiddenFolderID").val());
    			$("#hiddenComment").val("");
    		}else{
    			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
    		}
    	},
    	error:function(response, status, error){
    	     //TODO 추가 오류 처리
    	     CFN_ErrorAjax("/groupware/admin/deleteMessage.do", response, status, error);
    	}
    });
}

//게시글 잠금
function lockMessage(){
	var messageIDs = '';
	
	$.each(lowerMsgGrid.getCheckedList(0), function(i,obj){
		messageIDs += obj.MessageID + ';'
	});
	
	if(messageIDs == ''){
		 Common.Warning("<spring:message code='Cache.msg_MsgIsntSel' />", "Warning Dialog", function () { });	// 게시글이 선택되지 않았습니다.
       return;
	}
	
    $.ajax({
    	type:"POST",
    	url:"/groupware/admin/lockMessage.do",
    	data:{
    		"messageID": messageIDs
    		,"comment": $("#hiddenComment").val()
    	},
    	success:function(data){
    		if(data.status=='SUCCESS'){		//성공시 Grid재조회 및 필드 입력항목 초기화
    			Common.Warning("<spring:message code='Cache.msg_ProcessOk'/>"); //요청하신 작업이 정상적으로 처리되었습니다.
    			selectMessageGridList($("#hiddenFolderID").val());
    			$("#hiddenComment").val("");
    		}else{
    			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
    		}
    	},
    	error:function(response, status, error){
    	     //TODO 추가 오류 처리
    	     CFN_ErrorAjax("/groupware/admin/lockMessage.do", response, status, error);
    	}
    });
}

function unlockMessage(){
	var messageIDs = '';
	
	$.each(lowerMsgGrid.getCheckedList(0), function(i,obj){
		messageIDs += obj.MessageID + ';'
	});
	
	if(messageIDs == ''){
		 Common.Warning("<spring:message code='Cache.msg_MsgIsntSel' />", "Warning Dialog", function () { });	// 게시글이 선택되지 않았습니다.
       return;
	}
	
    $.ajax({
    	type:"POST",
    	url:"/groupware/admin/unlockMessage.do",
    	data:{
    		"messageID": messageIDs
    		,"comment": $("#hiddenComment").val()
    	},
    	success:function(data){
    		if(data.status=='SUCCESS'){		//성공시 Grid재조회 및 필드 입력항목 초기화
    			Common.Warning("<spring:message code='Cache.msg_ProcessOk'/>"); //요청하신 작업이 정상적으로 처리되었습니다. 
    			selectMessageGridList($("#hiddenFolderID").val());
    			$("#hiddenComment").val("");
    		}else{
    			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
    		}
    	},
    	error:function(response, status, error){
    	     //TODO 추가 오류 처리
    	     CFN_ErrorAjax("/groupware/admin/deleteUserDefField.do", response, status, error);
    	}
    });
}

function restoreMessage(){
	var messageIDs = '';
	
	$.each(lowerMsgGrid.getCheckedList(0), function(i,obj){
		messageIDs += obj.MessageID + ';'
	});
	
	if(messageIDs == ''){
		 Common.Warning("<spring:message code='Cache.msg_gw_SelectResotre'/>", "Warning Dialog", function () { });
       return;
	}
	
    $.ajax({
    	type:"POST",
    	url:"/groupware/admin/restoreMessage.do",
    	data:{
    		"messageID": messageIDs
    		,"comment": $("#hiddenComment").val()
    	},
    	success:function(data){
    		if(data.status=='SUCCESS'){		//성공시 Grid재조회 및 필드 입력항목 초기화
    			Common.Warning("<spring:message code='Cache.msg_ProcessOk'/>"); // 요청하신 작업이 정상적으로 처리되었습니다.
    			selectMessageGridList($("#hiddenFolderID").val());
    			$("#hiddenComment").val("");
    		}else{
    			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
    		}
    	},
    	error:function(response, status, error){
    	     //TODO 추가 오류 처리
    	     CFN_ErrorAjax("/groupware/admin/deleteUserDefField.do", response, status, error);
    	}
    });
}

function deleteDocNumber(){
	var managerIDs = '';
	$.each(lowerMsgGrid.getCheckedList(0), function(i,obj){
		managerIDs += obj.ManagerID + ';'
	});
	
	if(managerIDs == ''){
		 Common.Warning("<spring:message code='Cache.msg_Common_03'/>", "Warning Dialog", function () { });          // 삭제할 항목을 선택하여 주십시오.
       return;
	}
	Common.Confirm("<spring:message code='Cache.msg_Common_08'/>", 'Confirmation Dialog', function (result) {       // 선택한 항목을 삭제하시겠습니까?
		if (result) {
		    $.ajax({
		    	type:"POST",
		    	url:"/groupware/admin/deleteDocNumber.do",
		    	data:{
		    		"managerIDs": managerIDs
		    	},
		    	success:function(data){
		    		if(data.status=='SUCCESS'){
		    			Common.Warning("<spring:message code='Cache.msg_50'/>"); // 삭제되었습니다.
		    			selectDocNumberGridList();
		    		}else{
		    			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
		    		}
		    	},
		    	error:function(response, status, error){
		    	     //TODO 추가 오류 처리
		    	     CFN_ErrorAjax("/groupware/admin/deleteMessage.do", response, status, error);
		    	}
		    });
		}
	});
}

function getFieldInfos() {
	// 각 언어설정에 따른 다국어로 가져온다.(회사명, 회사약어, 부서명, 부서약어, 분류명)
	var compNmLang = lowerMsgGrid.list.filter(function(obj, idx, pList) { return obj.FieldType === "CompanyName" });
	if (compNmLang.length > 0) { $('#compNmLang').val(compNmLang[0].LanguageCode); }
	var compSnmLang = lowerMsgGrid.list.filter(function(obj, idx, pList) { return obj.FieldType === "CompanyShortName" });
	if (compSnmLang.length > 0) { $('#compSnmLang').val(compSnmLang[0].LanguageCode); }
	var deptNmLang = lowerMsgGrid.list.filter(function(obj, idx, pList) { return obj.FieldType === "DeptName" });
	if (deptNmLang.length > 0) { $('#deptNmLang').val(deptNmLang[0].LanguageCode); }
	var deptSnmLang = lowerMsgGrid.list.filter(function(obj, idx, pList) { return obj.FieldType === "DeptShortName" });
	if (deptSnmLang.length > 0) { $('#deptSnmLang').val(deptSnmLang[0].LanguageCode); }
	var cateNmLang = lowerMsgGrid.list.filter(function(obj, idx, pList) { return obj.FieldType === "CateName" });
	if (cateNmLang.length > 0) { $('#cateNmLang').val(cateNmLang[0].LanguageCode); }
	
	// 파라미터 확인.
	if ( sessionObj.USERID != "" && sessionObj.USERID != undefined
		&& sessionObj.DN_ID != "" && sessionObj.DN_ID != undefined
		&& sessionObj.DN_Code != "" && sessionObj.DN_Code != undefined
		&& sessionObj.DEPTID != "" && sessionObj.DEPTID != undefined ) {
		
		$.ajax({
			type :"POST"
			, data : {
				"USERID" : sessionObj.USERID			, "DN_ID" : sessionObj.DN_ID
				, "DN_Code" : sessionObj.DN_Code		, "DEPTID" : sessionObj.DEPTID
				, "compLang" : $('#compNmLang').val()	, "compSnmLang" : $('#compSnmLang').val()
				, "deptNmLang" : $('#deptNmLang').val()	, "deptSnmLang" : $('#deptSnmLang').val()
				, "cateNmLang" : $('#cateNmLang').val()
			},
			url : "/groupware/admin/selectFieldLangInfos.do",
			success : function(data) {
				if (data.list != undefined || data.list != "" ) {
					if (data.list[0].compNm != "" && data.list[0].compNm != undefined) {	// 회사명.
						$('#compNm').val(data.list[0].compNm);
					}
					if (data.list[0].compSnm != "" && data.list[0].compSnm != undefined) {	// 회사명약어.
						$('#compSnm').val(data.list[0].compSnm);
					}
					if (data.list[0].deptNm != "" && data.list[0].deptNm != undefined) { 	// 부서명.
						$('#deptNm').val(data.list[0].deptNm);	
					}
					if (data.list[0].deptSnm != "" && data.list[0].deptSnm != undefined) { 	// 부서명약어.
						$('#deptSnm').val(data.list[0].deptSnm);	
					}
					if (data.list[0].folderNm != "" && data.list[0].folderNm != undefined) { // 분류명(문서함마다 달라지므로 ROOT값으로).
						$('#cateNm').val(""+data.list[0].folderNm);
					}					
				}
				setExmplDocNum(lowerMsgGrid.list);	// 언어별 정보 조회 후, 예시를 보여줌.
			},
			error : function(response, status, error){
				CFN_ErrorAjax("selectFieldLangInfos.do", response, status, error);
			}
		});
	}
}

// 문서번호를 지정할 때, 일련번호를 최상위 혹은 일련번호만 남겨두면 안되어 관리자에게 알림창으로 알려줌.
function alertFirstSerialNumber(pUseFields) {
	if (pUseFields[0].FieldType === "SerialNumber") {
		Common.Inform("일련번호를 첫번째로 사용하실 수 없습니다. 수정하십시오.","Information",function(){ // 일련번호를 첫번째로 사용하실 수 없습니다.
			Common.Close();
    	});
		return false;
	} else {
		return true;
	}
}

// 문서번호 예시를 보여줌.
function setExmplDocNum(pList) {
	if ( pList.length === 0 ) {		// 문서번호 발번 내역이 없다면 return.
		return;
	}
	var useFields = pList.filter(function (obj, idx, pList) {	// 사용 중인 것들만 filtering.
		return obj.IsUse === "Y"
	});
	
	useFields.sort(function(a, b) {		// sorting. 1차 Seq, 2차 ManagerID.
		if (a.Seq > b.Seq) { return 1; }
		if (a.Seq < b.Seq) { return -1; }
		if ( (a.Seq === b.Seq) && (a.ManagerID > b.ManagerID) ) { return 1; }
		if ( (a.Seq === b.Seq) && (a.ManagerID < b.ManagerID) ) { return -1; }
		return 0;
	});
	
	alertFirstSerialNumber(useFields);	// 일련번호가 최상위일 때 오류 내용 관리자에게 알림.
	
	var exDocNum = "";
	
	// FieldName(FieldLength) 형식으로 문서번호 예시 보여주기.
	for (var item of useFields) {
		exDocNum = exDocNum + item.FieldType + "(" + item.FieldLength + ")" + item.Separator
	}
	$('#exAutoDocNumber1').text( exDocNum );	// 문서 번호 예시 값.
	
	exDocNum = "";
	for (var item of useFields) {
		exDocNum = exDocNum + fieldCombine(item);
	}
	
	$('#exAutoDocNumber2').text( exDocNum );	// 문서 번호 예시 값.
}

function fieldCombine(field) {
	if (typeof(field) === "undefined") {
		return;
	}
	var retVal = "";
	var dateToday = new Date();
	
	if (field.FieldType === 'CompanyName') {	// 회사명
		retVal = $('#compNm').val().substr(0, field.FieldLength);
		retVal = retVal + field.Separator;
	} else if (field.FieldType === "CompanyShortName") {	// 회사명 약어
		if ( $('#compSnm').val() != "" ) {
			retVal = $('#compSnm').val().substr(0, field.FieldLength);
		} else { 	// 회사명 약어가 조회할 수 없다면, '{회사명 약어(FieldLength)}'로 보여주기
			retVal = "{<spring:message code='Cache.lbl_CorpAliasName'/>("+ field.FieldLength +")}";		// ex : {회사명 약어(4)}
		}
		retVal = retVal + field.Separator;
	} else if ( field.FieldType === "DeptName" ) {		// 부서명
		if ( $('#deptNm').val() != undefined || $('#deptNm').val() != "" ) {
			retVal = $('#deptNm').val().substr(0, field.FieldLength);
		} else {	// 부서명 조회를 못했을 경우, "{부서명(4)}" 형식으로 표기.
			retVal = "{<spring:message code='Cache.lbl_DeptName'/>("+ field.FieldLength +")}";		// ex : {부서명(4)}
		}
		retVal = retVal + field.Separator;
	} else if (field.FieldType === "DeptShortName") {
		if ( $('#deptSnm').val() != "" ) {
			retVal = $('#deptSnm').val().substr(0, field.FieldLength);
		} else {	// 부서명 약어가 빈값이면, '{부서명약어(FieldLength)}'
			retVal = "{<spring:message code='lbl_DeptShortName' />(" + field.FieldLength + ")}";
		}
		retVal = retVal + field.Separator;
	} else if ( field.FieldType === "CateName") {	// 분류명(선택한 문서함)
		retVal = $('#cateNm').val().substr(0, field.FieldLength);
		retVal = retVal + field.Separator;
	} else if ( field.FieldType === "Year") { 	// 년도.
		retVal = ""+dateToday.getFullYear();
		retVal = retVal.substr(retVal.length - field.FieldLength, field.FieldLength);
		retVal = retVal + field.Separator;
	} else if (field.FieldType === "Month") {	// 월.
		retVal = dateToday.getMonth() + 1;
		retVal = ""+retVal;
		if (retVal.length < 2) { retVal = "0"+ retVal; }
		retVal = retVal.substr(retVal.length - field.FieldLength, field.FieldLength);
		retVal = retVal + field.Separator;
	} else if (field.FieldType === "Day") {
		retVal = dateToday.getDate();
		retVal = ""+retVal;
		if (retVal.length < 2) { retVal = "0"+ retVal; }
		retVal = retVal.substr(retVal.length - field.FieldLength, field.FieldLength);
		retVal = retVal + field.Separator;
	} else if (field.FieldType === "SerialNumber") {	// 일련번호는 예시이므로 1로 보여준다.
		retVal = "1";
		retVal = retVal + field.Separator;
	}

	return retVal;
}

function fieldSeqChange(pManagerID, pSeq, pDomainID, pFieldType, pStatus) {	// 우선순위 -1
	$.ajax({
		type : "POST"
		, data : { 
			"ManagerID" : pManagerID
			, "Seq" : pSeq
			, "DomainID" : pDomainID
			, "FieldType" : pFieldType
			, "Status" : pStatus
		}
		, url : "/groupware/admin/updateFieldSeq.do"
		, success : function (data) {
			Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){ //저장되었습니다.
				Common.Close();
				selectDocNumberGridList();	// 변경 후, reload.
        	});
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/admin/updateFieldSeq.do", response, status, error);
		}
	});
}

$(document).ready(function (){

});

</script>
<div class="cRConTop titType AtnTop">
	<h2 class="title">게시관리</span></h2>
    <div class="searchBox02">
        <span><input type="text" id="searchText"><button type="button" class="btnSearchType01"  id="icoSearch"><spring:message code='Cache.btn_search' /></button></span> <!-- 검색 -->
    </div>
</div>
<form id="form1">
    <div class="sadminContent">
    	<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a class="btnTypeDefault btnPlusAdd" onclick="javascript:createBoardPopup();"><spring:message code="Cache.btn_Add"/></a><!-- 추가 -->	
				<a class="btnTypeDefault" id="folderOpen"><spring:message code="Cache.lbl_OpenAll"/></a>
				<a class="btnTypeDefault"  id="folderClose"><spring:message code="Cache.lbl_CloseAll"/></a>
			</div>
			<div class="buttonStyleBoxRight">
				<button class="btnRefresh" type="button" href="#" id="boardFolder"></button>
			</div>
		</div>	
		<!-- 폴더 Grid 리스트 -->
		<div id="folderGrid" class="tblList tblCont" style="height:250px"></div>
	</div>
		
		<!-- 게시글 네비게이터 : 통합게시(최상위) > 공지(폴더) > 공지사항 게시글(게시판) -->
<div class="cRConTop titType AtnTop">
	<h2 class="title" id=boardPath></h2>
</div>
	<div class="sadminContent">	
		<!-- 게시글 조회항목  -->
		<div class="sadminMTopCont" id="divMessageView">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a id="btnDelMsg" onclick="commentPopup('delete');" class="btnTypeDefault BtnDelete" ><spring:message code="Cache.lbl_delete"/></a>
				<a id="btnLockMsg" onclick="commentPopup('lock');" class="btnTypeDefault" ><spring:message code="Cache.lbl_Lock"/></a>
				<a id="btnUnlockMsg" onclick="commentPopup('unlock');" class="btnTypeDefault" ><spring:message code="Cache.lbl_UnLock"/></a>
				<a id="btnRestoreMsg" onclick="commentPopup('restore');" class="btnTypeDefault" ><spring:message code="Cache.lbl_Restore"/></a>
				<a id="btnReadedUsers" onclick="showReadedUsers();" class="btnTypeDefault" ><spring:message code="Cache.lbl_SearchorList"/></a>
				<a id="btnHistory" onclick="showHistory();" class="btnTypeDefault" ><spring:message code="Cache.lbl_ProcessingHistory"/></a>
				<a name="btnDocInfo" onclick="changeDocInfo('owner');" class="btnTypeDefault" >소유자 변경</a>
				<a name="btnDocInfo" onclick="changeDocInfo('dept');" class="btnTypeDefault" >등록부서 변경</a>
				<a name="btnDocInfo" onclick="changeDocInfo('total');" class="btnTypeDefault" >일괄 변경</a>
				<a name="btnDocNumber" class="btnTypeDefault BtnAdd" onclick="javascript:createDocNumberPopup();">추가</a>
				<a name="btnDocNumber" class="btnTypeDefault BtnDelete" onclick="javascript:deleteDocNumber();">삭제</a>
				<a id="btnExcel" onclick="ExcelDownload();" class="btnTypeDefault BtnExcel" ><spring:message code="Cache.lbl_SaveToExcel"/></a>
			</div>
			<div class="buttonStyleBoxRight">
				<button class="btnRefresh" type="button" href="#" id="boardMessage"></button>
			</div>
		</div>	
		<div id="topitembar03" class="topbar_grid">
			<span id="SearchStats"> <!-- 게시통계용 조회 조건 -->
				<spring:message code="Cache.lbl_Notice_Select"/>&nbsp;
				<input type="text" id="searchFolder" class="AXInput" readonly/>
				<input type="hidden" id="hiddenFolderIDs" class="AXInput" readonly/>
				<!-- 게시판 선택 조회 -->
				<input type="button" id="btnFolderSearch" class="AXButton" value="<spring:message code='Cache.btn_Select'/>" onclick="javascript:selectBoardTreePopup();"/>
			</span>
			<spring:message code='Cache.lbl_Section'/>&nbsp;
			<select id="searchType" class="AXSelect W100">
				<option value=""><spring:message code="Cache.lbl_selection"/></option>
				<option value="Subject"><spring:message code="Cache.lbl_subject"/></option>
				<option value="CreatorName"><spring:message code="Cache.lbl_Register"/></option>
				<option value="BodyText"><spring:message code="Cache.lbl_Contents"/></option>
			</select>
			<spring:message code='Cache.lbl_SearchCondition'/>&nbsp;
			<input type="text" id="searchText" class="AXInput" onkeypress="if (event.keyCode==13){ selectMessageGridList($('#hiddenFolderID').val()); return false;}" />&nbsp;
			<spring:message code='Cache.lblSearchScope'/>&nbsp;<input type="text" id="startDate" style="width: 85px" class="AXInput" /> ~ 
			<input type="text" kind="twindate" date_startTargetID="startDate" id="endDate" style="width: 85px" class="AXInput"  />
			<input type="button" value="<spring:message code='Cache.btn_search'/>" onclick="javascript:selectMessageGridList($('#hiddenFolderID').val());" class="AXButton" />
			<!-- <label>
				<spring:message code='Cache.lbl_Period'/>&nbsp;
				<select id="selectCate" class="AXSelect">
				</select>
			</label>  -->
		</div>
		<div id= "topitembar04" class="topbar_grid" style="display: none;">
			<span>문서번호 예시 : </span>	<%-- 문서번호 예시 : --%>
			<text id="exAutoDocNumber2"></text><br/>
			<span>문서번호 구성 : </span>
			<text id="exAutoDocNumber1"></text>
			<input type="hidden" id="compNmLang" />
			<input type="hidden" id="compNm" />
			<input type="hidden" id="compSnmLang" />
			<input type="hidden" id="compSnm" />
			<input type="hidden" id="deptNmLang" />
			<input type="hidden" id="deptNm" />
			<input type="hidden" id="deptSnmLang" />
			<input type="hidden" id="deptSnm" />
			<input type="hidden" id="cateNmLang" />
			<input type="hidden" id="cateNm" />
		</div>
			
		<div id="lowerMessageGrid" class="tblList tblCont"></div>
	</div>

	<input type="hidden" id="hiddenMenuID" value=""/>
	<input type="hidden" id="hiddenFolderID" value=""/>
	<input type="hidden" id="hiddenMessageID" value=""/>
	<input type="hidden" id="hiddenComment" value="" />
</form>