<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="/covicore/resources/script/Controls/covision.album.js<%=resourceVersion%>"></script>

<div class="cRConTop titType">
	<h2 class="title">공지사항</h2>						
	<div class="searchBox02">
		<span>
			<input id="subjectSearchText" type="text">
			<button type="button" class="btnSearchType01" onclick="javascript:subjectSearch($('#subjectSearchText').val())"><spring:message code='Cache.btn_search'/></button>	<!-- 검색 -->
		</span>
		<a href="#" class="btnDetails"><spring:message code='Cache.lbl_detail'/></a>	<!-- 상세 -->
	</div>
</div>
<div class="cRContBottom mScrollVH ">
	<div class="inPerView type02">
		<div>
			<div class="selectCalView">
				<span><spring:message code='Cache.lbl_Contents'/></span>	<!-- 내용 -->
				<select id="searchType" class="selectType02">
					<option value="Subject"><spring:message code='Cache.lbl_Title'/></option>	<!-- 제목 -->
					<option value="BodyText"><spring:message code='Cache.lbl_Contents'/></option><!-- 내용 -->
					<option value="CreatorName"><spring:message code='Cache.lbl_writer'/></option><!-- 작성자 -->
					<option value="Total"><spring:message code='Cache.lbl_Title'/> + <spring:message code='Cache.lbl_Contents'/></option>
				</select>
				<div class="dateSel type02">
					<input id="searchText" type="text">
				</div>											
			</div>
			<div>
				<a href="#" id="btnSearch" class="btnTypeDefault btnSearchBlue nonHover"><spring:message code='Cache.btn_search'/></a> <!-- 검색 -->
			</div>
			<div class="chkGrade">									
				<div class="chkStyle01">
					<input type="checkbox" id="chkRead"><label for="chkRead"><span></span><spring:message code='Cache.lbl_Mail_Unread'/></label><!-- 읽지않음 -->
				</div>
			</div>
		</div>
		<div>
			<div class="selectCalView">
			<span><spring:message code='Cache.lbl_Period'/></span>	<!-- 기간 -->
				<select id="selectSearch" class="selectType02">
				</select>
				<div id="divCalendar" class="dateSel type02">
					<input class="adDate" type="text" id="startDate" date_separator="." readonly=""> - <input id="endDate" date_separator="." kind="twindate" date_startTargetID="startDate" class="adDate" type="text" readonly="">
				</div>											
			</div>
		</div>
	</div>
	<div id="switchAllCont">	<!-- class: boardCommCnt, docAllCont -->
		<!-- #tabList -->
		<ul id="tabList" class="tabType2 clearFloat" style="display:none;">
<!-- 			<li name="boxType"><a href="#">승인함</a></li> -->
<!-- 			<li name="boxType"><a href="#">요청함</a></li> -->	
		</ul>
		
		<div id="switchTopCnt" class="boradTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a href="#" id="btnWrite" style="display:none;" class="btnTypeDefault btnThemeBg" onclick="javascript:board.goWrite();"><spring:message code='Cache.lbl_Write'/></a>	<!-- 작성 -->
				<a href="#" id="btnCopyMsg" style="display:none;" class="btnTypeDefault right" onclick="javascript:board.moveFolderPopup('copy');"><spring:message code='Cache.lbl_Copy'/></a>	<!-- 복사 -->
				<a href="#" id="btnMoveMsg" style="display:none;" class="btnTypeDefault middle" onclick="javascript:board.moveFolderPopup('move');"><spring:message code='Cache.lbl_Move'/></a>	<!-- 이동 -->
				<a href="#" id="btnDelete" style="display:none;" class="btnTypeDefault left" onclick="javascript:chkDelete();"><spring:message code='Cache.lbl_delete'/></a>	<!-- 삭제 -->
				<a href="#" id="btnSubscription" style="display:none;" class="btnSubscription" onclick="javascript:coviCtrl.addSubscription(folderID);"><spring:message code='Cache.lbl_Subscription'/></a>	<!-- 구독 -->	
				<a href="#" id="btnFavoriteMenu" style="display:none;" class="btnAddFavorite" onclick="javascript:coviCtrl.addFavoriteMenu(menuID, folderID);"><spring:message code='Cache.lbl_Favorite'/></a>	<!-- 즐겨찾기 -->
				<a href="#" id="btnApproval" style="display:none;" class="btnTypeDefault btnThemeBg" ><spring:message code='Cache.lbl_Approval'/></a>	<!-- 승인 -->
				<a href="#" id="btnReject" style="display:none;" class="btnTypeDefault" ><spring:message code='Cache.lbl_Reject'/></a>	<!-- 거부 -->
				<a href="#" id="btnBinder" style="display:none;" class="btnTypeDefault" onclick="javascript:board.goCreateBinder();"><spring:message code='Cache.btn_CreateBinder'/></a>	<!-- 바인더 생성 -->
				<a href="#" id="btnExcelUpload" style="display:none;" class="btnTypeDefault btnExcel" onclick="ExcelUpload();"><spring:message code='Cache.btn_UploadToExcel'/></a>	<!-- 일괄 업로드 -->
				<!-- <a href="#" id="btnExcelTemplate" class="btnTypeDefault btnExcel" onclick="ExcelTemplate();"><spring:message code='Cache.btn_issueTemplateDownload'/></a>	<!-- 템플릿 다운로드 -->
				<a href="#" id="btnExcel" style="display:none;" class="btnTypeDefault btnExcel" onclick="ExcelDownload();"><spring:message code='Cache.btn_SaveToExcel'/></a>	<!-- 엑셀저장 -->
				<div class="addFuncBox">
					<a href="#" style="display:none;" class="btnAddFunc"></a><!-- 부가기능 -->
					<ul class="addFuncLilst">
						<li><a id="ctxBoardConfig" style="display:none;" href="#" class="icon-setting" onclick="javascript:editBoardPopup(folderID);return false;"><spring:message code='Cache.btn_Preference'/></a></li>	<!-- 환경설정 -->
					</ul>
				</div>
			</div>
			<div class="buttonStyleBoxRight">
				<select id="selectCategoryID" class="selectType02 selectGroup"></select>
				<select id="selectApprovalStatus" class="selectType02 selectGroup" style="display:none;">
					<option value=""><spring:message code='Cache.lbl_all'/></option>				<!-- 전체 -->
					<option value="P"><spring:message code='Cache.lbl_Progressing'/></option>		<!-- 진행중 -->
					<option value="R" selected="selected"><spring:message code='Cache.lbl_ApprovalReq'/></option>	<!-- 승인요청 -->
					<option value="A"><spring:message code='Cache.lbl_ApprovalComplete'/></option>	<!-- 승인완료 -->
					<option value="D"><spring:message code='Cache.lbl_ApprovalDeny'/></option>		<!-- 승인거부 -->
				</select>
				<select id="selectPageSize" class="selectType02 listCount">
					<option value="10">10</option>
					<option value="20">20</option>
					<option value="30">30</option>
				</select>
				<a href="#" id="listView" class="btnListView listViewType01 active">리스트보기1</a>
				<a href="#" id="albumView" class="btnListView listViewType02 " style="display:none;">리스트보기2</a>
				<button id="btnRefresh" class="btnRefresh" type="button"></button>
			</div>
		</div>
		<!-- 목록보기-->
		<div id="divListView" class="tblList tblCont">
			<div id="messageGrid"></div>
<!-- 			<div class="goPage"> -->
<!-- 				<input type="text"> <span> / 총 </span><span>1</span><span>페이지</span><a href="#" class="btnGo">go</a> -->
<!-- 			</div>							 -->
		</div>
		<div id="divAlbumView" class="tblList abList boradBottomCont" style="display:none;">
			<div id="albumContent" class="albumContent">
			</div>					
		</div>
	</div>												
</div>

<input type="hidden" id="hiddenMenuID" value=""/>
<input type="hidden" id="hiddenFolderID" value=""/>
<input type="hidden" id="hiddenMessageID" value=""/>
<input type="hidden" id="hiddenComment" value="" />

<script type="text/javascript">
var bizSection = CFN_GetQueryString("CLBIZ");		//Board, Doc
var boardType = (CFN_GetQueryString("boardType") == 'undefined'? "Normal" : CFN_GetQueryString("boardType"));	//Normal, Total, MyOwnWrite, OnWriting, RequestModify, MyBooking, Scrap
var viewType = (CFN_GetQueryString("viewType") == 'undefined'? "List" : CFN_GetQueryString("viewType"));		//List, Album
var boxType = (CFN_GetQueryString("boxType") == 'undefined'? "Receive" : CFN_GetQueryString("boxType"));		//Request, Receive
var folderID = CFN_GetQueryString("folderID");
var communityID = (CFN_GetQueryString("communityId") == 'undefined'? "" : CFN_GetQueryString("communityId"));
var menuID = "";

if(communityID != ""){
	menuID = communityID;
} else {
	menuID = (CFN_GetQueryString("menuID") =='undefined'?Common.getBaseConfig(menuCode):CFN_GetQueryString("menuID"));
}

//List 조회, 페이징처리용 Parameter
var sortBy = decodeURIComponent(CFN_GetQueryString("sortBy"));
var page = CFN_GetQueryString("page")== 'undefined'?1:CFN_GetQueryString("page");
var pageSize = CFN_GetQueryString("pageSize")== 'undefined'?10:CFN_GetQueryString("pageSize");
$('#selectPageSize').val(pageSize);

var searchText = CFN_GetQueryString("searchText")== 'undefined'?"":decodeURIComponent(CFN_GetQueryString("searchText"));
var searchType = CFN_GetQueryString("searchType")== 'undefined'?"Subject":decodeURIComponent(CFN_GetQueryString("searchType"));
$('#searchText').val(searchText);
$('#searchType').val(searchType);

var startDate = CFN_GetQueryString("startDate")== 'undefined'?"":decodeURI(CFN_GetQueryString("startDate"));
var endDate = CFN_GetQueryString("endDate")== 'undefined'?"":decodeURI(CFN_GetQueryString("endDate"));
$('#startDate').val(startDate);
$('#endDate').val(endDate);

var messageGrid = new coviGrid();		//게시글 Grid 
var gridOverflowCell = [];			
messageGrid.config.fitToWidthRightMargin=0;
//페이지 로드시 Normal 헤더로 설정

function subjectSearch( pSearchText ){
	$("#searchType").val("Subject");
	$("#searchText").val(pSearchText);

	//검색기능 사용시 페이지 초기화
	coviAlbum.page.pageNo = 1;
	messageGrid.page.pageNo = 1;
	if(viewType != "List"){
		selectMessageAlbumList(menuID, folderID);
	} else {
		selectMessageGridList(menuID, folderID);
	}
	
	// 검색어 저장
	coviCtrl.insertSearchData(pSearchText, 'Board');
}

//폴더 그리드 세팅
function setMessageGrid(){
	messageGrid.setGridHeader(msgHeaderData);
	setMessageGridConfig();
	selectMessageGridList(menuID, folderID);				
}

function setAlbumList(){
	selectMessageAlbumList(menuID, folderID);
}

//폴더 그리드 Config 설정
function setMessageGridConfig(){
	var configObj = {
		targetID : "messageGrid",
		listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
		height:"auto",
		page : {
			pageNo: (page != undefined && page != '')?page:1,
			pageSize: (pageSize != undefined && pageSize != '')?pageSize:10,
		},
		paging : true,
		colHead:{},
		body:{},
		overflowCell: gridOverflowCell
	};
	messageGrid.setGridConfig(configObj);
}

//게시글 상위 경로 조회
//JS로 이동 예정
function selectFolderPath(pFolderPath){
	$.ajax({
		type:"POST",
		data:{
			"folderPath" : pFolderPath,
		},
		url:"admin/selectFolderPath.do",
		success:function (data) {
			$("#boardPath").text(data.folderPath);
		},
		error:function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("admin/selectFolderPath.do", response, status, error);
		}
	});
}

//게시글 Grid 조회 
function selectMessageGridList(pMenuID, pFolderID){
	//폴더 변경시 검색항목 초기화
	var searchParam = {
		"bizSection": bizSection,
		"boardType": boardType,
		"viewType": viewType,
		"boxType": boxType,
		"menuID": pMenuID,
		"folderID": (pFolderID == "undefined" ? "": pFolderID),
		"folderType": g_boardConfig.FolderType,
		"categoryID": $("#selectCategoryID").val(),			//카테고리 선택 조회
		//"startDate":$("#startDate").val(),
		//"endDate":$("#endDate").val(),
		"searchType":$("#searchType").val(),
		"searchText":$("#searchText").val(),
		"useTopNotice": (g_boardConfig.UseTopNotice == undefined || g_boardConfig.UseTopNotice == "N")?"":"Y",
		"useUserForm": (g_boardConfig.UseUserForm == undefined || g_boardConfig.UseUserForm == "N")?"":"Y",
		"approvalStatus": $("#selectApprovalStatus").val(),	//승인 상태 선택 조회
		"readSearchType": $("#chkRead").prop("checked")?'unread':'',
		"communityID": communityID
	}

	if($('.btnDetails').hasClass('active')){
		searchParam['startDate'] = $("#startDate").val();
		searchParam['endDate'] = $("#endDate").val();
	} else {
		searchParam['startDate'] = "";
		searchParam['endDate'] = "";
	}

	if(sortBy != "undefined" && sortBy != ""){
		var sortColumn = sortBy.split(" ")[0];
		var sortDirection = sortBy.split(" ")[1];
		var colIndex = '';
		$.each(messageGrid.config.colGroup, function(i, item){ 
			if(item.key == sortColumn){
				colIndex = i; 
				return false; 
			};
		});
		messageGrid.config.colGroup[colIndex].sort = sortDirection;
		searchParam['sortBy'] = sortBy;
		
		messageGrid.bindGrid({
			ajaxUrl:"/groupware/issue/selectMessageGridList.do",
			ajaxPars: searchParam,
		});
		messageGrid.redrawGrid();
	} else {
		//TODO: sortBy가 없을경우...
		messageGrid.bindGrid({
			ajaxUrl:"/groupware/issue/selectMessageGridList.do",
			ajaxPars: searchParam,
		});
	}
}

//게시글 앨범보기 조회
function selectMessageAlbumList(pMenuID, pFolderID){
	var searchParam = {
		"bizSection": bizSection,
		"boardType": boardType,
		"viewType": viewType,
		"boxType": boxType,
		"menuID": pMenuID,
		"folderID": pFolderID,
		"folderType": g_boardConfig.FolderType,
		"categoryID": $("#selectCategoryID").val(),
		//"startDate":$("#startDate").val(),
		//"endDate":$("#endDate").val(),
		"searchType":$("#searchType").val(),
		"searchText":$("#searchText").val(),
		"useTopNotice": (g_boardConfig.UseTopNotice == undefined || g_boardConfig.UseTopNotice == "N")?"":"Y",
		"approvalStatus": $("#selectApprovalStatus").val(),	//승인 상태 선택 조회
		"readSearchType": $("#chkRead").prop("checked")?'unread':'',
		"communityID": communityID
	}

	if($('.btnDetails').hasClass('active')){
		searchParam['startDate'] = $("#startDate").val();
		searchParam['endDate'] = $("#endDate").val();
	} else {
		searchParam['startDate'] = "";
		searchParam['endDate'] = "";
	}

	if(page != undefined && page != ''){
		coviAlbum.page.pageNo = page;
	}

	if(pageSize != undefined && pageSize != ''){
		coviAlbum.page.pageSize = pageSize;
	}

	if(sortBy != "undefined" && sortBy != ""){
		coviAlbum.page.sortBy = sortBy;	
	}
	
	coviAlbum.target = 'albumContent';
	coviAlbum.url = "/groupware/board/selectMessageGridList.do";
	coviAlbum.setList(searchParam, g_boardConfig);
}


//메뉴별 상단 버튼 표시/숨김처리
//작성, 복사, 이동, 삭제, 구독, 즐겨찾기, 승인, 거부, 바인더 생성, 엑셀저장 , 부가기능
//프로젝트 이슈관리에서는 일괄 업로드 버튼이 추가로 있음
function renderButtonControl(){
	//작성버튼
	//조건: 커뮤니티에서만 표시 (커뮤니티는 좌측 상단에 게시물 작성 버튼이 없음)
	if(communityID != ""){
		$("#btnWrite").show();
	}else{
		$("#btnWrite").hide();
	}
	
	//즐겨찾기 버튼
	//조건: 즐겨찾기 설정이 켜저 있고 전체보기 아닐 경우 표시
	if(g_boardConfig.UseFavorite == "Y" && boardType != "Total" && boardType != "DocTotal"){
		$('#btnFavoriteMenu').show();
		g_boardConfig.IsFavorite == "Y"?$('#btnFavoriteMenu').addClass("active"):$('#btnFavoriteMenu').removeClass("active");
	}else{
		$('#btnFavoriteMenu').hide();
	}
		
	//구독 버튼
	//조건: 구독 설정이 켜저 있을 경우 표시
	if(g_boardConfig.UseSubscription == "Y"){
		$('#btnSubscription').show();
		g_boardConfig.IsSubscribe == "Y"?$('#btnSubscription').addClass("active"):$('#btnSubscription').removeClass("active");
	}else{
		$('#btnSubscription').hide()
	}
	
	
	var aclObj; 
	if(folderID != 'undefined'){
		aclObj = board.getMessageAclList(bizSection, '', '', folderID).aclObj;
	}
	
	//개별호출-일괄호출
	var sessionObj = Common.getSession(); //전체호출
	var ownerCode = g_boardConfig.OwnerCode;
	
	//복사/이동 버튼
	/* 조건 
	1. 전체보기 게시판이 아닌 경우
	2. 게시판 복사/이동 설정(UseCopy)이 'Y' 
	3. 게시판 보기 타입이 'Album'이 아닌 경우 
	4. bizSection 값이 'Doc'이 아닌 경우
	5. 승인요청 게시판이 아닌 경우
	6. 아래 2가지 중 하나라도 만족
		6-1. 시스템 관리자 또는 게시판 운영자일 경우 
		6-2. 메세지 권한 설정(UseMessageAuth)이 'N'이면서  [이동만 해당] 해당 게시판에 삭제 권한이 있을 경우 
	*/
	if(folderID != 'undefined' && g_boardConfig.UseCopy == "Y" && viewType != "Album" && bizSection != "Doc" && boardType != "Approval"){
		if( sessionObj["isAdmin"] == "Y" ||	(ownerCode !== undefined && (ownerCode.indexOf(sessionObj["USERID"]+";") != -1) )){
			$("#btnMoveMsg, #btnCopyMsg").show();
		}else if(g_boardConfig.UseMessageAuth == "N"){
			$("#btnCopyMsg").show();
			
			aclObj.Delete == "D" ? $("#btnMoveMsg").show() : $("#btnMoveMsg").hide() 
		}else{
			$("#btnMoveMsg, #btnCopyMsg").hide();
		}
	}else{
		$("#btnMoveMsg, #btnCopyMsg").hide();
	}
	
	//삭제 버튼
	/* 조건 
	1. 게시판 보기 타입이 'Album'이 아닌 경우 
	2. 게시판 전체보기, 문서관리 전체보기, 승인요청, 문서권한, 문서배포 게시판이 아닌경우
	3. 아래 3가지 중 하나라도 만족
		3-1. 내가 작성한 게시, 작성중인 게시, 예약게시, 스크랩, 소유문서인 경우
		3-2. 시스템 관리자 또는 게시판 운영자일 경우 
		3-3. 메세지 권한 설정(UseMessageAuth)이 'N'이면서 해당 게시판에 삭제 권한이 있을 경우 
	*/
	if(viewType != "Album" && ["Total", "DocTotal", "Approval", "DocAuth", "DistributeDoc"].indexOf(boardType) < 0){
		if(["MyOwnWrite", "OnWriting", "MyBooking", "Scrap", "DocOwner"].indexOf(boardType) > -1){
			$("#btnDelete").show();
		}else if( sessionObj["isAdmin"] == "Y" ||	(ownerCode !== undefined && (ownerCode.indexOf(sessionObj["USERID"]+";") != -1) )){
			$("#btnDelete").show();
		}else if(g_boardConfig.UseMessageAuth == "N" && aclObj.Delete == "D"){
			$("#btnDelete").show();
		}else{
			$("#btnDelete").hide();
		}
	}else{
		$("#btnDelete").hide();
	}
	
	//승인/거부 버튼
	//조건: 승인요청 또는 문서권한 게시판일 때 표시 (탭 선택에 따른 버튼 표시 여부 함수는 별도로 존재)
	if(boardType == "Approval" || boardType == "DocAuth"){
		$('#btnApproval, #btnReject').show();
	}else{
		$('#btnApproval, #btnReject').hide();
	}
	
	
	//바인더 생성 버튼
	/* 조건 
	1. bizSection 값이 'Doc'
	2. boardType이 Normal인 경우 (boardType이 'Normal'일때는 boardType은 'Doc'으로 변경됨 (Grid 사용이 게시와 다르기 때문))
	3. 시스템 관리자 또는 게시판 운영자이거나 해당 폴더 생성 권한이 있는 경우
	*/
	if(folderID != 'undefined' && bizSection == "Doc" && boardType == "Doc" ){
		if( sessionObj["isAdmin"] == "Y" ||	(ownerCode !== undefined && (ownerCode.indexOf(sessionObj["USERID"]+";") != -1) )){
			$("#btnBinder").show();
		}else if(aclObj.Create == "C"){
			$("#btnBinder").show();
		}else{
			$("#btnBinder").hide();
		}
	}else{
		$("#btnBinder").hide();
	}
	
	//엑셀저장 버튼
	//조건: X (늘 표시됨)
	$("#btnExcel").show();

	//일괄 업로드 버튼 (프로젝트 이슈관리 내에만 있는 버튼)
	//조건: 프로젝트 이슈관리일 경우 표시
	$("#btnExcelUpload").show();
	
	//부가기능 버튼
	//조건: 시스템 관리자 또는 게시판 운영자이면서 게시판 타입이 'Normal'일 때 표시
	if( boardType == "Normal" && 
		( sessionObj["isAdmin"] == "Y" || (ownerCode !== undefined && (ownerCode.indexOf(sessionObj["USERID"]+";") != -1) ) ) ){
		$('.btnAddFunc, #ctxBoardConfig').show();
	}else{
		$('.btnAddFunc, #ctxBoardConfig').hide();
	}
	
	//버튼 디자인 조정
	if($("#btnCopyMsg").css("display") == "none" && $("#btnMoveMsg").css("display") == "none"){
		$("#btnDelete").removeClass("left");
	} else if( $("#btnCopyMsg").css("display") != "none" && $("#btnMoveMsg").css("display") != "none" &&  $("#btnDelete").css("display") == "none"){
		$("#btnMoveMsg").removeClass("middle").addClass("left");
	}
}

//전체 버튼, 게시판 옵션, FolderType, BizSection별 표시 숨김
function renderUI(){
	if(boardType == "Approval"){	//승인함의 탭구조는 문서 관리쪽 Class를 사용해야하므로 분기처리
		switchContClass("Doc");		//Tab구조의 화면은 Class가 문서관리 기준으로 설정됨
	} else {
		switchContClass(bizSection);
	} 
	
	if(g_boardConfig.UseCategory == "Y"){
		$("#selectCategoryID").coviCtrl("setSelectOption", "/groupware/board/selectCategoryList.do", {"folderID": folderID}, "분류 선택", "");
	} else {
		$("#selectCategoryID").hide();
	}
	
	if(bizSection != "Doc"){
		//boardType값에 따라 tab 표시 숨김 및 Div Class 분기처리
		if(g_boardConfig.FolderType == "Album"){	//viewType 변경
			viewType = "Album";		
			// Album 게시에서만 요약보기 지원
// 			$("#albumView").show();
		} else {
			// Album 게시에서만 요약보기 지원
// 			$("#albumView").hide();
		}
	} else {
		if(g_boardConfig.FolderType == "Doc" && boardType == "Normal"){	//문서관리의 경우 boardType이 Normal이지만 별도 Grid를 사용하므로 GridHeader 참조부분 별도 처리
			boardType = "Doc";
		} 
	}
	
	msgHeaderData = getGridHeader(boardType, boxType, folderID);
	gridOverflowCell = board.getGridOverflowCell(boardType);
	//목록형, 앨범형 보기 화면 분기처리
	if(viewType != "List"){
		setAlbumList();
		changeAlbumView();	//앨범 리스트 표시
	} else {
		setMessageGrid();
		changeBoardView();	//Grid 리스트 표시
	}
}


//CHECK: board.js로 이동 예정
//Tab 항목 생성 및 내부 항목별 type코드 설정(boxType)
function renderTabUI(){
	switch(boardType){
		case "Approval":	//승인요청
		case "DocAuth":		//문서권한
			$("#tabList").html($('<li type="Receive"/>').append($('<a href="#" />').text("승인함")));
			$("#tabList").append($('<li type="Request"/>').append($('<a href="#" />').text("요청함")));
			break;
		case "DistributeDoc"://문서배포
			$("#tabList").html($('<li type="Receive"/>').append($('<a href="#" />').text("수신함")));
			$("#tabList").append($('<li type="Distribute"/>').append($('<a href="#" />').text("배포함")));
			break;
	}

	//Tab 선택시 재조회 이벤트
	$("#tabList li").on("click",function(){
		$(this).addClass("active");
		$("#tabList li").not($(this)).removeClass("active");

		if(boardType == "Approval" || boardType == "DocAuth" || boardType == "DistributeDoc")
			changeApprovalTabUI();

		msgHeaderData = getGridHeader(boardType, boxType, folderID);
		if(viewType != "List"){
			setAlbumList();
		} else {
			setMessageGrid();
		}
	});
	
	$("#tabList").show();
	
	if(boxType == "Receive"){	//페이지 로드 이후 boxType의 값에 따라 승인함, 요청함 활성화
		$("#tabList li:eq(0)").addClass("active");
		$("#tabList li:eq(1)").removeClass("active");
	} else {
		$("#tabList li:eq(0)").removeClass("active");
		$("#tabList li:eq(1)").addClass("active");
	}
}

//boardType별 분기처리, 버튼 표시,숨김 , Class 분기처리
function switchingBoardType(){
	//게시판 Title 변경, 탭, 버튼 표시숨김처리
	switch(boardType){
		case "Total":
			boardTitle = "<spring:message code='Cache.lbl_Board_totalView'/>";	//전체 글 보기
			break;
		case "Normal":
			//게시판 의 FolderID로 게시판 옵션 조회 시작
			boardTitle = CFN_GetDicInfo(g_boardConfig.MultiDisplayName);
			break;
		case "MyOwnWrite":	//내가 작성한 게시
			boardTitle = "<spring:message code='Cache.lbl_MyWriteMsg'/>";
			break;
		case "MyInterest":	//나의 관심 게시(전 즐겨찾기)
			boardTitle = "<spring:message code='Cache.lbl_MyInterestBoard'/>";
			break;
		case "Scrap":	//스크랩
			boardTitle = "<spring:message code='Cache.lbl_ScrapBoard'/>";
			break;	
		case "OnWriting":	//작성중 게시 
			boardTitle = "<spring:message code='Cache.lbl_OnWritingBoard'/>";
			break;
		case "Approval":	//승인 요청 게시
			boardTitle = "<spring:message code='Cache.lbl_ApprovalReq'/>";
			
			$('#btnApproval').on('click', function(){
				board.commentPopup('accept');
			});
			
			$('#btnReject').on('click', function(){
				board.commentPopup('reject');
			});
			
			renderTabUI();
			changeApprovalTabUI();
			break;
		case "RequestModify":	//수정 요청 게시
			boardTitle = "<spring:message code='Cache.lbl_RequestModifyList'/>";
			break;
		case "MyBooking":	//예약 게시
			boardTitle = "<spring:message code='Cache.lbl_MyBookingList'/>";
			break;

		/* 문서 관리 ***************************************************************************/	
		case "DocTotal":	//전체 문서 보기
			boardTitle = "<spring:message code='Cache.lbl_Doc_totalView'/>";
			break;
		case "Doc":			//문서관리 boardType: Normal
			boardTitle = CFN_GetDicInfo(g_boardConfig.MultiDisplayName);
			break;
		case "CheckIn":			//문서관리 boardType: CheckIn
			boardTitle = "<spring:message code='Cache.lbl_CheckIn'/>";
			break;
		case "CheckOut":		//문서관리 boardType: CheckOut
			boardTitle = "<spring:message code='Cache.lbl_CheckOut'/>";
			break;
		case "DocOwner":		//문서관리 boardType: MyOwner
			boardTitle = "<spring:message code='Cache.lbl_Doc_myDoc'/>";
			break;
		case "DocFavorite":		//문서관리 boardType: 관심문서
			boardTitle = "관심문서";
			break;
		case "DocAuth":		//문서 권한
			boardTitle = "<spring:message code='Cache.lbl_Doc_docAuth'/>";
			$("#tabList").show();
			
			$('#btnApproval').on('click', function(){
				board.commentPopup('allow');
			}).show();
			
			$('#btnReject').on('click', function(){
				board.commentPopup('denie');
			}).show();

			renderTabUI();
			changeApprovalTabUI();
			break;
		case "DistributeDoc":
			boardTitle = "<spring:message code='Cache.lbl_Doc_docDistribution'/>";

			renderTabUI();
			break;
		default:
			
		var boardTitle = "<spring:message code='Cache.lblBoardManage'/>";	//게시관리
	}
	$(".title").text(boardTitle);		//최상단 타이틀 변경
	renderButtonControl();
}

//승인함, 요청함 탭에 따라 표시/숨김 및 select parameter 변경
function changeApprovalTabUI(){
	boxType = $("#tabList li.active").attr("type");	//boxTyper 값 변경
	if(boardType!="DistributeDoc" && boxType == "Receive"){	//승인함, 수신함
		$("#selectApprovalStatus").show().val("R");
		$("#btnApproval, #btnReject").show();
	} else if(boxType == "Request"){	//요청함
		$("#selectApprovalStatus").hide().val("");
		$("#btnApproval, #btnReject").hide();
	}
}


//CHECK: board.js로 이동 예정
function changeBoardView(){
	$("#divAlbumView").hide();
	$("#divListView").show();
	$("#albumView").removeClass("active");
	$("#listView").addClass("active");
	page = coviAlbum.page.pageNo;
	sortBy = coviAlbum.page.sortBy;
	viewType = "List";
	switchingBoardType();	//게시판 옵션별 제목 및 버튼 표시 숨김처리
	bindControlEvent();
}

//CHECK: board.js로 이동 예정
function changeAlbumView(){
	$("#divListView").hide();
	$("#divAlbumView").show();
	$("#listView").removeClass("active");
	$("#albumView").addClass("active");
	page = messageGrid.page.pageNo;
	sortBy = messageGrid.getSortParam("one").split("=").pop();
	viewType = "Album";
	switchingBoardType();	//게시판 옵션별 제목 및 버튼 표시 숨김처리
	bindControlEvent();
}

//CHECK: board.js로 이동 예정
//표시 항목별 Div 클래스 변경
function switchContClass( pBizSection ){
	if(pBizSection != "Doc"){
		$("#switchAllCont").addClass("boardAllCont");
		$("#switchTopCont").addClass("boradTopCont");
		$("#divListView").addClass("boradBottomCont");
	} else {
		$("#switchAllCont").addClass("docAllCont");
		$("#switchTopCont").addClass("docTopCont");
		$("#divListView").addClass("tblDocList");
	}
}

//***************************************************************************************************************************/
//엑셀 다운로드
function ExcelDownload(){
	Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage'/>", "Confirmation Dialog", function(result){
   		if(result){
   			var headerName = getHeaderNameForExcel();
   			var headerKey = getHeaderKeyForExcel();
   			var sortInfo = messageGrid.getSortParam("one").split("=");
   			var	sortKey = sortInfo.length>1? sortInfo[1].split(" ")[0]:"";
   			var	sortWay = sortInfo.length>1? sortInfo[1].split(" ")[1]:"";				  	
   			var useUserForm = (g_boardConfig.UseUserForm == undefined || g_boardConfig.UseUserForm == "N")?"":"Y";
   			var approvalStatus = $("#selectApprovalStatus").val();	//승인 상태 선택 조회
   			var url = String.format("/groupware/issue/messageListExcelDownload.do?boardType={0}&bizSection={1}&menuID={2}&folderID={3}&startDate={4}&endDate={5}&sortKey={6}&sortWay={7}&headerName={8}&headerKey={9}&searchText={10}&searchType={11}&folderType={12}&boxType={13}&useUserForm={14}&approvalStatus={15}", 
   					boardType, 
   					bizSection, 
   					menuID, 
   					folderID, 
   					$("#startDate").val(), 
   					$("#endDate").val(), 
   					sortKey, 
   					sortWay, 
   					encodeURI(headerName),
   					headerKey, 
   					$("#searchText").val(), 
   					$("#searchType").val(),
   					g_boardConfig.FolderType,
   					boxType,
   					useUserForm,
   					approvalStatus);
   			location.href = url;
   		}
	});
}

function ExcelUpload(){
	parent.Common.open("", "IssueUploadPopup", Common.getDic('lbl_ExcelUploadPopup'), "/groupware/board/goIssueUploadPopup.do", "400px", "300px", "iframe", true, null, null, true);
}

function ExcelTemplate(){
	Common.Confirm("<spring:message code='Cache.msg_bizcard_downloadTemplateFiles'/>", "Confirm Dialog", function(result){
 		if (result) { 			
 			location.href = '/groupware/issue/excelTemplateDownload.do';
		}
	});
}

//엑셀용 Grid 헤더정보 설정
function getHeaderNameForExcel(){
	var returnStr = "";
	
   	for(var i=0;i<msgHeaderData.length; i++){
   	   	if(msgHeaderData[i].display != false &&
   	   			msgHeaderData[i].label != '' && 
   	   			msgHeaderData[i].key != 'FileCnt' &&
   	    	   	msgHeaderData[i].key != 'chk' && 
   	    	 	msgHeaderData[i].key != 'CreatorCode' && 
   	    	 	msgHeaderData[i].key != 'Depth' && 
   	    		msgHeaderData[i].key != 'Step' &&
   	    		msgHeaderData[i].key != 'Seq' &&  
   	    	   	msgHeaderData[i].key != 'FolderID'){
			returnStr += msgHeaderData[i].label + "|";
   	   	}
	}
   	returnStr = returnStr.substring(0, returnStr.length-1);
	return returnStr;
}

function getHeaderKeyForExcel(){
	var returnStr = "";
	
   	for(var i=0;i<msgHeaderData.length; i++){
   	   	if(msgHeaderData[i].display != false && 
   	   			msgHeaderData[i].label != '' && 
   	   			msgHeaderData[i].key != 'FileCnt' &&
   	    	   	msgHeaderData[i].key != 'chk' && 
   	    	 	msgHeaderData[i].key != 'CreatorCode' && 
   	    	 	msgHeaderData[i].key != 'Depth' && 
   	    		msgHeaderData[i].key != 'Step' &&
   	    		msgHeaderData[i].key != 'Seq' &&  
   	    	   	msgHeaderData[i].key != 'FolderID'){
			returnStr += msgHeaderData[i].key + ",";
   	   	}
	}
   	returnStr = returnStr.substring(0, returnStr.length-1);
	return returnStr;
}
//***************************************************************************************************************************/

function goImageSlidePopup (pMessageID, pFolderID) {
	//CHECK: 처리 이력 팝업 제목 다국어처리 필요
	var contextParam = String.format("&messageID={0}&serviceType={1}&objectID={2}&objectType={3}", pMessageID, bizSection, (pFolderID == undefined ? folderID : pFolderID), 'FD');
// 	parent.Common.open("", "imageSlidePopup", "이미지 슬라이드 쇼", "/covicore/control/goImageSlidePopup.do?" + contextParam, "797px", "778px", "iframe", true, null, null, true);
	CFN_OpenWindow("/covicore/control/goImageSlidePopup.do?" + contextParam,"Image Slide",800,780,"");	//이미지 슬라이드 쇼
}

//게시판 환경설정 팝업
function editBoardPopup(pFolderID){
	var disp_popup_name = "<spring:message code='Cache.lbl_BoardConfigSet'/>|||<spring:message code='Cache.lbl_FolderModify'/>";
	var context_url = "/groupware/board/manage/goFolderManagePopup.do?";
	var param_url = "domainID="+sessionObj["DN_ID"]+"&menuID="+menuID+"&folderID="+pFolderID+"&bizSection=Board"+"&mode=edit";
	parent.Common.open("", "editBoard", disp_popup_name, context_url+param_url,"600px","680px","iframe",true,null,null,true);
}

function bindControlEvent(){
	//페이지 개수 변경
	$("#selectPageSize").off('change').on("change", function(){
		pageSize = $(this).val();
		
		messageGrid.page.pageNo = 1;
		messageGrid.page.pageSize = $(this).val();
		selectMessageGridList(menuID, folderID);

		coviAlbum.page.pageNo = 1;
		coviAlbum.page.pageSize = $(this).val();
		selectMessageAlbumList(menuID, folderID);
	});
	
	//리스트보기
	$("#listView").off('click').on('click', function(){
		changeBoardView();
		setMessageGrid();
	});

	//앨범보기
	$("#albumView").off('click').on('click', function(){
		changeAlbumView();
		setAlbumList();
	});

	//조회
	$("#btnSearch").off('click').on('click', function(){
		//검색기능 사용시 페이지 초기화
		coviAlbum.page.pageNo = 1;
		messageGrid.page.pageNo = 1;
		
		//목록형, 앨범형 보기 화면 분기처리
		if(viewType != "List"){
			selectMessageAlbumList(menuID, folderID);
		} else {
			selectMessageGridList(menuID, folderID);
		}
		
		// 검색어 저장
		coviCtrl.insertSearchData($("#searchText").val(), 'Board');
	});

	//갱신
	$("#btnRefresh").off('click').on('click', function(){
		//목록형, 앨범형 보기 화면 분기처리	
		if(viewType != "List"){
			selectMessageAlbumList(menuID, folderID);
		} else {
			selectMessageGridList(menuID, folderID);
		}
	});

	//contextMenu
	$('.btnAddFunc').off('click').on('click', function(){
		if($(this).hasClass('active')){
			$(this).removeClass('active');
			$('.addFuncLilst').removeClass('active');
		}else {
			$(this).addClass('active');
			$('.addFuncLilst').addClass('active');
		}
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

	//카테고리 변경시 자동 조회
	$("#selectCategoryID, #selectApprovalStatus").off('change').on("change",function(){
		messageGrid.page.pageNo = 1;	//분류 변경시 페이징 초기화
		coviAlbum.page.pageNo = 1;
		selectMessageGridList(menuID, folderID);
	});

	$('#subjectSearchText').off('keypress').on('keypress', function(e){ 
		if (e.which == 13) {
	        e.preventDefault();
	        if($('#subjectSearchText').val() != ""){
	        	subjectSearch($('#subjectSearchText').val());
		    }
	    }
	});
}

function chkDelete(){
	if(messageGrid.getCheckedList(0).length > 0){
		var chkDel = true;
		
		$.each(messageGrid.getCheckedList(0), function(idx, item){
			var aclObj = board.getMessageAclList(bizSection, item.Version, item.MessageID, item.FolderID).aclObj;
			var folderOwnerCode = ";" + item.FolderOwnerCode;
            if(sessionObj["isAdmin"] != "Y" 
        		&& !(folderOwnerCode.indexOf(";" + sessionObj["USERID"] + ";") > -1)
				&& aclObj.Delete != "D"
				&& !((bizSection == "Board" && item.CreatorCode == sessionObj["USERID"])
					|| (bizSection == "Doc" && item.OwnerCode == sessionObj["USERID"]))){
				chkDel = false;
				return false;
			}
		});
		
		if(chkDel){
			board.commentPopup('delete');
		}else{
			Common.Warning("<spring:message code='Cache.msg_noDeleteACL'/>"); // 삭제 권한이 없습니다.
		}
	}else{
		Common.Warning("<spring:message code='Cache.msg_apv_003'/>"); // 선택된 항목이 없습니다.
	}
}

initContent();

function initContent(){
	//임시 page history
	//$('#selectSearch').coviCtrl("setDateInterval", $('#startDate'), $('#endDate'));
	$('#selectSearch').coviCtrl("setDateInterval", $('#startDate'), $('#endDate'), "", {"changeTarget": "start"});
	sessionStorage.setItem("urlHistory", $(location).attr('pathname') + $(location).attr('search'));
	g_urlHistory = $(location).attr('pathname') + $(location).attr('search');
	
	board.getBoardConfig(folderID);	//게시판별 옵션 조회 (board_config)
	renderUI();				//게시판 타입별 UI변경
	switchingBoardType();	//게시판 옵션별 제목 및 버튼 표시 숨김처리
}

function getGridHeader(){
	var headerData = null;		//Grid Header
	
	var categoryFlag = g_boardConfig.UseCategory == "Y"?true:false;				//카테고리
	var userDefFieldFlag = g_boardConfig.UseUserForm == "Y"?true:false;			//사용자 정의 필드
	
	//개별호출-일괄호출
	Common.getDicList(["lbl_no2","lbl_BoardCate2","lbl_subject","lbl_Register","lbl_RegistDate", "lbl_CreateDates", "lbl_ReadCount",
					   "lbl_ReadAcl","lbl_ModifyAcl","lbl_DeleteAcl","lbl_issue_projectName","lbl_issue_projectManager","lbl_issue_productType","lbl_issue_module"]);
	
	viewIcon = $('<span class="icoDocList icoView"><span class="toolTip">' + coviDic.dicMap["lbl_ReadAcl"] + '</span></span>');	//조회권한
	modifyIcon = $('<span class="icoDocList icoWrite"><span class="toolTip">' + coviDic.dicMap["lbl_ModifyAcl"] + '</span></span>');//수정권한
	deleteIcon = $('<span class="icoDocList icoDel"><span class="toolTip">' + coviDic.dicMap["lbl_DeleteAcl"] + '</span></span>');	//삭제권한
	
	var beforeUserDefField = [ 
	          	         	{key:'chk',			label:'chk', width:'1', align:'center', formatter: 'checkbox'},
	          	        	{key:'MessageID',	label:coviDic.dicMap["lbl_no2"], width:'5', align:'center',
	          	         		formatter:function(){
	          	         			return board.formatTopNotice(this, g_boardConfig.UseTopNotice);	//상단공지 사용 여부 
	          	         		}
	          	        	},		//번호
	          	        	{key:'FolderID',	label:'FolderID', align:'center', display:false, hideFilter : 'Y'},
	          	        	{key:'Seq',			label:'Seq', align:'center', display:false, hideFilter : 'Y'},
	          	        	{key:'Step',		label:'Step', align:'center', display:false, hideFilter : 'Y'},
	          	        	{key:'FileCnt',		label:' ', width:'1', align:'left', hideFilter : 'Y',
	          	        		formatter:function(){
	          	        			return board.formatFileAttach(this);
	          	        		}
	          	        	},
	          	        	{key:'Depth',		label:'Depth', align:'center', display:false, hideFilter : 'Y'},
	          	        	{key:'CategoryName',label:coviDic.dicMap["lbl_BoardCate2"], display: categoryFlag, width:'4', align:'center'},
	          	        	{key:'Subject',  	label:coviDic.dicMap["lbl_subject"], width:'12', align:'left',		//제목
	          	        		formatter:function(){ 
	          	        			return formatSubjectName(this, g_boardConfig.UseIncludeRecentReg, g_boardConfig.RecentlyDay); //최근게시 사용여부, 최근 게시 기준일
	          	        		}
	          	        	},
	          	        	{key:'ProjectName',label:coviDic.dicMap["lbl_issue_projectName"], width:'10', align:'center'},
	          	        	{key:'ProjectManager',label:coviDic.dicMap["lbl_issue_projectManager"], width:'4', align:'center'},
	          	        	{key:'ProductType',label:coviDic.dicMap["lbl_issue_productType"], width:'4', align:'center'},
	          	        	{key:'Module',label:coviDic.dicMap["lbl_issue_module"], width:'4', align:'center'},
	          	        	{key:'MsgState', 	align:'center', display:false, hideFilter : 'Y'},
	          	        	{key:'DeleteDate', 	align:'center', display:false, hideFilter : 'Y'},
	          	        	{key:'CreatorCode', align:'center', display:false, hideFilter : 'Y'}
	          	        ];
	          			
	 //사용자 정의 필드 이후의 컬럼 헤더
	 var afterUserDefField = [
	          				{key:'CreatorName',  label:coviDic.dicMap["lbl_Register"], width:'5', align:'center',
	          					formatter: function(){
	          						if(this.item.UseAnonym == "Y"){
	          							return this.item.CreatorName;							
	          						}else{
	          							return coviCtrl.formatUserContext("List", this.item.CreatorName, this.item.CreatorCode, this.item.MailAddress);
	          						}
	          					}
	          				},
	          				{key:'RegistDate',	label:coviDic.dicMap["lbl_RegistDate"]  + Common.getSession("UR_TimeZoneDisplay"), width:'8', align:'center', formatter: function(){
	        					return CFN_TransLocalTime(this.item.RegistDate);
	        				}},
	          				{key:'ReadCnt',		label:coviDic.dicMap["lbl_ReadCount"], width:'3', align:'center'}
	          			];
	          			
	          			
	headerData = beforeUserDefField;
	//사용자 정의 필드 추가 구간
	if(folderID != undefined && folderID != null && folderID != ""){
		//FolderID가 있을경우 board_config 옵션에 따라서 확장필드 검색 및 카테고리 표기하도록 처리
		if(userDefFieldFlag){
			//g_boardConfig참조
			headerData = headerData.concat(board.getUserDefFieldHeader(folderID));
		}
	}
	          			
	headerData = headerData.concat(afterUserDefField);
	
	return headerData;
	
}

function formatSubjectName( pObj, pRecentlyFlag, pRecentlyDay){
	var	sortBy = messageGrid.getSortParam("one").split("=")[1] != undefined?messageGrid.getSortParam("one").split("=")[1]:"";
	var page = messageGrid.page.pageNo;
	var pageSize = $("#selectPageSize").val();
	var clickBox = $("<div class='tblClickBox' />");	//제목 우측에 새글 표시 및 댓글 카운트 표시
	var recentlyBadge = $("<span />").addClass("cycleNew new").text("N");	//새글 표시 뱃지
	var replyFlag = false;		//답글 flag
	var recentFlag = false;		//최신글 flag
	
	//Subject항목 내부 <, >가 존재할경우 문자열로 치환(HTML DOM Element To String)
	var returnStr = pObj.item.Subject.toString().replaceAll("<", "&lt;").replaceAll(">", "&gt;");
	//댓글이 있을 경우 clickbox 추가
	if(pObj.item.CommentCnt > 0 && g_boardConfig.UseComment == "Y"){
		//답글 팝업
		clickBox.append("<span  style='color:black;cursor:pointer;' onclick='javascript:board.replyPopup("+pObj.item.MessageID+","+pObj.item.Version+",\""+bizSection+"\");'>(" + pObj.item.CommentCnt + ")</span>");
		replyFlag = true;
	}
	
	//g_boardConfig.UseIncludeReg, g_boardConfig.RecentlyDay
	if(pRecentlyFlag == "Y" && pRecentlyDay > 0){
		var today = new Date();
		var registDate = new Date(pObj.item.CreateDate);
		if(today < registDate.setDate(registDate.getDate()+ pRecentlyDay)){
			recentFlag = true;
		}
	}
	
	//문서관리 바인더일 경우 표시
	if(bizSection == "Doc" && pObj.item.MsgType == "B"){
		returnStr = "<span class='btnType02'>" + coviDic.dicMap["lbl_Binder"] + "</span>" + returnStr;
	}
	
	
	var subject = String.format("<a onclick='javascript:board.goView(\"{1}\", {2}, {3}, {4}, {5}, \"{6}\", \"{7}\", \"{8}\", \"{9}\", \"{10}\", \"{11}\", \"{12}\", {13}, {14});' >{0}</a>", 
		returnStr,
		bizSection,
		pObj.item.MenuID,
		pObj.item.Version,
		pObj.item.FolderID,
		pObj.item.MessageID,
		$("#startDate").val(),
		$("#endDate").val(),
		sortBy,
		$("#searchText").val(),
		$("#searchType").val(),
		viewType,
		boardType,
		page,
		pageSize);
	
	returnStr = subject;
	
	if(recentFlag){
		returnStr += clickBox.append( recentlyBadge ).prop('outerHTML');
	} else if(replyFlag && !recentFlag){
		returnStr += clickBox.prop('outerHTML');
	}
	//삭제된 게시글의 경우 취소선 표시
	if(pObj.item.DeleteDate != "" && pObj.item.DeleteDate != undefined){
		returnStr = $("<strike/>").append(returnStr);
	}
	
	if(pObj.item.Depth!="0" && pObj.item.Depth!=undefined){
		returnStr = $("<div class='tblLink re'>").append(returnStr);
		//답글 게시글 화살표 표시
	} else {
		returnStr = $("<div class='tblLink'>").append(returnStr);
	}
	
	returnStr.attr('title', returnStr.text());	// tooltip 추가
	
	//읽지않은 게시글 굵게
	if(pObj.item.IsRead != "Y"){
		returnStr = $("<strong />").append(returnStr);
	}

	
	return returnStr.prop('outerHTML');
}
//# sourceURL=IssueBoardList.jsp
</script>
