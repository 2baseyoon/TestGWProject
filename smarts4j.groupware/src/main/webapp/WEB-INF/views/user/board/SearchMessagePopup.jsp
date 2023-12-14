<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="layer_divpop ui-draggable boradPopLayer " id="testpopup_p" style="width:830px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">
		<div class="popContent layerType02 boardReadingList">
			<div>				
				<div class="top">			
					<div class="searchBox02">
						<span>
							<input type="text" id="searchText" placeholder="게시글 검색">
							<button type="button" id="btnSearch" class="btnSearchType01" onclick="javascript:selectMessageGridList();coviCtrl.insertSearchData($('#searchText').val(), 'Board');"><spring:message code='Cache.btn_search'/></button>	<!-- 검색 -->
						</span>
					</div>
				</div>
				<div class="middle" style="margin-top:11px;">
					<div class="tblList tblCont">					
						<div id="messageGrid"></div>			
					</div>
				</div>
				<div class="bottom">
					<div class="popBottom">
						<a href="#" class="btnTypeDefault btnTypeBg" onclick="saveLinkedMessage();"><spring:message code='Cache.btn_Link'/></a>	<!-- 연결 -->
						<a href="#" class="btnTypeDefault" onclick="closeLayer();"><spring:message code='Cache.btn_Close'/></a>	<!-- 닫기 -->
					</div>
				</div>
			</div>
		</div>
	</div>	
</div>
<script>
var bizSection = CFN_GetQueryString("bizSection");	//Board, Doc ...Community?
var menuID = CFN_GetQueryString("menuID");
var mode = CFN_GetQueryString("mode");		//Link: 연결글, Bind: 바인더, Approval: EDMS 문서 첨부
var messageGrid = new coviGrid();			//게시글 Grid
var modeType = CFN_GetQueryString("modeType");	// [결재 EDMS 문서 첨부, 문서 연결 구분] Attach : 첨부 , Link : 연결
var communityID = CFN_GetQueryString("communityID") == "undefined" ? "" : CFN_GetQueryString("communityID");
messageGrid.config.fitToWidthRightMargin=0;

var messageArray = [];

//게시글 제목 포멧: 삭제된 게시글 취소선 처리, 답글표시
function formatSubjectName( pObj ){
	var returnStr = pObj.item.Subject;
	
	if(pObj.item.CommentCnt > 0 ){
		returnStr += " (" + pObj.item.CommentCnt + ")";
	}
	//삭제된 게시글의 경우 취소선 표시
	if(pObj.item.DeleteDate!="" && pObj.item.DeleteDate!=undefined){
		returnStr = String.format("<strike>{0}</strike>",returnStr);
	}
	
	returnStr = String.format("<a href='#' onclick='javascript:goViewPopup(\"{1}\", {2}, {3}, {4}, {5});' >{0}</a>", 
		returnStr,
		bizSection,
		menuID,
		pObj.item.Version,
		pObj.item.FolderID,
		pObj.item.MessageID
	);
	
	if(pObj.item.Depth!="0" && pObj.item.Depth!=undefined){
		returnStr = String.format("<div class='tblLink re'>{0}</div>",returnStr);
		//답글 게시글 화살표 표시
	} else {
		returnStr = String.format("<div class='tblLink'>{0}</div>",returnStr);
	}
	//댓글 개수 표시가 필요하다.
	return returnStr
}

//사용자 정의 필드 이전의 컬럼헤더
var headerDataDoc = [ 
	{key:'chk',			label:'chk', width:'1', align:'center', formatter: 'checkbox', disabled : function(){
 		return mode == "Approval" && modeType == "Attach" && this.item.FileCnt == 0 ? "disabled" : "";
	}},
	{key:'MessageID',	label:"<spring:message code='Cache.lbl_no2'/>", width:'4', align:'center', sort:'desc' },		//번호
	{key:'FolderID',	label:'FolderID', align:'center', display:false, hideFilter : 'Y'},
	{key:'Seq',			label:'Seq', align:'center', display:false, hideFilter : 'Y'},
	{key:'Step',		label:'Step', align:'center', display:false, hideFilter : 'Y'},
	{key:'Files',		label:'Files', align:'center', display:false, hideFilter : 'Y'},
	{key:'FileCnt',		label:' ', width:'2', align:'center',
		formatter:function(){
			return board.formatFileAttach(this);
		}
	},
	{key:'Depth',		label:'Depth', align:'center', display:false, hideFilter : 'Y'},
	{key:'FolderName',  label:"<spring:message code='Cache.lbl_BoardCate2'/>", width:'7', align:'left'},
	{key:'Subject',  	label:"<spring:message code='Cache.lbl_subject'/>", width:'12', align:'left',		//제목
		formatter:function(){ 
			return formatSubjectName(this, 'N', 0); //최근게시 사용여부, 최근 게시 기준일
		}
	},
	{key:'Number', 		label: "<spring:message code='Cache.lbl_DocNo'/>", width:'8', align:'center'},	// 문서번호
	{key:'MsgState', 	align:'center', display:false, hideFilter : 'Y'},
	{key:'DeleteDate', 	align:'center', display:false, hideFilter : 'Y'},
	{key:'CreatorCode', align:'center', display:false, hideFilter : 'Y'},
	{key:'CreatorName',  label:"<spring:message code='Cache.lbl_Register'/>", width:'5', align:'center',
		formatter: function(){ 
			return CFN_GetDicInfo(this.item.CreatorName)
		}
	},
	{key:'RegistDate',	label:"<spring:message code='Cache.lbl_RegistDate'/>"  + Common.getSession("UR_TimeZoneDisplay"), width:'8', align:'center', formatter: function(){
		return CFN_TransLocalTime(this.item.RegistDate);
	}}
	//{key:'ReadCnt',		label:"<spring:message code='Cache.lbl_ReadCount'/>", width:'3', align:'center'}
];

var headerData = [ 
	{key:'chk',			label:'chk', width:'1', align:'center', formatter: 'checkbox', disabled : function(){
 		return mode == "Approval" && modeType == "Attach" && this.item.FileCnt == 0 ? "disabled" : "";
	}},
	{key:'MessageID',	label:"<spring:message code='Cache.lbl_no2'/>", width:'4', align:'center', sort:'desc' },		//번호
	{key:'FolderID',	label:'FolderID', align:'center', display:false, hideFilter : 'Y'},
	{key:'Seq',			label:'Seq', align:'center', display:false, hideFilter : 'Y'},
	{key:'Step',		label:'Step', align:'center', display:false, hideFilter : 'Y'},
	{key:'Files',		label:'Files', align:'center', display:false, hideFilter : 'Y'},
	{key:'FileCnt',		label:' ', width:'2', align:'center',
		formatter:function(){
			return board.formatFileAttach(this);
		}
	},
	{key:'Depth',		label:'Depth', align:'center', display:false, hideFilter : 'Y'},
	{key:'FolderName',  label:"<spring:message code='Cache.lbl_BoardCate2'/>", width:'7', align:'left'},
	{key:'Subject',  	label:"<spring:message code='Cache.lbl_subject'/>", width:'12', align:'left',		//제목
		formatter:function(){ 
			return formatSubjectName(this, 'N', 0); //최근게시 사용여부, 최근 게시 기준일
		}
	},
	{key:'MsgState', 	align:'center', display:false, hideFilter : 'Y'},
	{key:'DeleteDate', 	align:'center', display:false, hideFilter : 'Y'},
	{key:'CreatorCode', align:'center', display:false, hideFilter : 'Y'},
	{key:'CreatorName',  label:"<spring:message code='Cache.lbl_Register'/>", width:'5', align:'center',
		formatter: function(){ 
			return CFN_GetDicInfo(this.item.CreatorName)
		}
	},
	{key:'RegistDate',	label:"<spring:message code='Cache.lbl_RegistDate'/>"  + Common.getSession("UR_TimeZoneDisplay"), width:'8', align:'center', formatter: function(){
		return CFN_TransLocalTime(this.item.RegistDate);
	}}
	//{key:'ReadCnt',		label:"<spring:message code='Cache.lbl_ReadCount'/>", width:'3', align:'center'}
];

//폴더 그리드 세팅
function setMessageGrid(){
	if(bizSection == "Doc") {
		messageGrid.setGridHeader(headerDataDoc);	
	} else {
		messageGrid.setGridHeader(headerData);
	}	
	
	setMessageGridConfig();
	selectMessageGridList();				
}

function goViewPopup(pBizSection, pMenuID, pVersion, pFolderID, pMessageID){
	var url = String.format("/groupware/board/goBoardViewPopup.do?CLBIZ={0}&menuID={1}&version={2}&folderID={3}&messageID={4}&viewType=Popup", pBizSection, pMenuID, pVersion, pFolderID, pMessageID);
	parent.Common.open("", "boardViewPop", "<spring:message code='Cache.lbl_DetailView'/>", url, "1080px", "600px", "iframe", true, null, null, true);
}

//폴더 그리드 Config 설정
function setMessageGridConfig(){
	var configObj = {
		targetID : "messageGrid",
		listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
		height:"auto",
		page : {
			pageNo: 1,
			pageSize:10
		},
		paging : true,
		colHead:{},
		body:{}
	};
	
	messageGrid.setGridConfig(configObj);
}

//게시글 Grid 조회 
function selectMessageGridList(){
	//폴더 변경시 검색항목 초기화
	var searchParam = {
		"bizSection": bizSection,
		"boardType": "Total",
		"menuID": menuID,
		"viewType": "List",
		"searchType":"Total",
		"searchText":$("#searchText").val(),
		"mode": mode,
		"communityID": communityID
	}
	messageGrid.bindGrid({
		ajaxUrl:"/groupware/board/selectSearchMessageGridList.do",
		ajaxPars: searchParam,
	});
}

var hiddenLinkedMessage = null;

$(document).ready(function (){
	setMessageGrid();
	
	//팝업 모드 별 parent, opener Element참조용...개선이 필요함 구림
	if(parent != null && parent.$("#hiddenLinkedMessage").val() != undefined ){
		hiddenLinkedMessage = parent.$("#hiddenLinkedMessage");
	} else {
		hiddenLinkedMessage = opener.$("#hiddenLinkedMessage");
	}

	if(hiddenLinkedMessage.length > 0 && hiddenLinkedMessage.val() != ""){
		messageArray = $.parseJSON(hiddenLinkedMessage.val());
	}
	
	$('#searchText').off('keypress').on('keypress', function(e){ 
		if (e.which == 13) {
	        e.preventDefault();
	        if($('#searchText').val() != ""){
	        	selectMessageGridList();
	        	coviCtrl.insertSearchData($('#searchText').val(), 'Board');
		    }
	    }
	});
});

//하단의 닫기 버튼 함수
function closeLayer(){
	Common.Close();
}

function saveLinkedMessage(){
	if(mode == "Approval"){
		if(modeType == "Attach"){
			// 파일 첨부
			var fileArr = [];
			//security.
			var attachFilePath = bizSection + "/";
			
			$.each(messageGrid.getCheckedList(0), function(i, obj){
				$.each(obj.Files, function(i, item) {
					item.fullPath = attachFilePath + item.FilePath + item.SavedName;
					fileArr.push( item );
				});
			});
			
			// 첨부파일 정보 전달
			var _scope = opener || parent;
			if(_scope._CallBackMethod){
				_scope._CallBackMethod.call(_scope, fileArr);
			}
		} else {
			var linkDocArr = [];
			// 문서 연결
			$.each(messageGrid.getCheckedList(0), function(i,obj){
				var linkMessage = new Object();
				linkMessage.BizSection = bizSection;
				linkMessage.MenuID = menuID;
				linkMessage.MessageID = obj.MessageID;
				linkMessage.FolderID = obj.FolderID;
				linkMessage.Version = obj.Version;
				linkMessage.DisplayName = obj.Subject;
				linkMessage.Number = obj.Number;
				linkMessage.CreatorName = obj.CreatorName;
				linkMessage.CreateDate = obj.CreateDate;
				
				linkDocArr.push( linkMessage );
			});	

			// 첨부파일 정보 전달
			var _scope = opener || parent;
			if(_scope._CallBackMethod){
				_scope._CallBackMethod.call(_scope, linkDocArr);
			}
		}
	}else{
		$.each(messageGrid.getCheckedList(0), function(i,obj){
			var linkMessage = new Object();
			linkMessage.MessageID = obj.MessageID;
			linkMessage.FolderID = obj.FolderID;
			linkMessage.Version = obj.Version;
			linkMessage.DisplayName = obj.Subject;
			linkMessage.Number = obj.Number;
			linkMessage.CreatorName = obj.CreatorName;
			linkMessage.CreateDate = obj.CreateDate;
			
			bCheck = false;
			//중복 체크 이후 sHTML로 TR 데이터 그려줌
			$.each(messageArray, function (i, item) {
				if (obj.MessageID == item.MessageID) {
					bCheck = true;
				}
			});
			
			if(!bCheck){
				messageArray.push(linkMessage);
			}	
		});
		
		hiddenLinkedMessage.val((JSON.stringify(messageArray)));
		board.renderLinkedMessage(hiddenLinkedMessage);
	}

	closeLayer();
}
</script>