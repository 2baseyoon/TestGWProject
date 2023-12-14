<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="egovframework.baseframework.util.PropertiesUtil
	,egovframework.covision.groupware.util.BoardUtils
	,egovframework.baseframework.data.CoviMap
	,egovframework.coviframework.util.StringUtil
	,egovframework.baseframework.util.SessionHelper
	,egovframework.coviframework.logging.LoggerHelper"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%
String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();

String bizSection = StringUtil.replaceNull(request.getParameter("CLBIZ"),"");
String boardType = StringUtil.replaceNull(request.getParameter("boardType"),"");
String grCode = StringUtil.replaceNull(request.getParameter("grCode"),"");
String requestUrl = request.getParameter("grCode");
	
if (request.getParameter("communityId") != null && !request.getParameter("communityId").equals("")){
	bizSection = "Community";
}

CoviMap configMap = new CoviMap();
CoviMap aclMap = new CoviMap();
if (request.getParameter("folderID")== null ){	
} 
else {
	String folderID = request.getParameter("folderID");			//폴더 ID
	CoviMap returnMap = BoardUtils.getFolderConfig(bizSection, folderID);
	
	configMap = (CoviMap)returnMap.get("configMap");
	aclMap = (CoviMap)returnMap.get("aclMap");
	
	if (!returnMap.getBoolean("isAuth").equals(true)){
		LoggerHelper.authErrorLogger((String) request.getAttribute("javax.servlet.forward.request_uri"), "NOAUTH", "", "", "Auth unauthorized : No permission", "page");
		out.println("<script language='javascript'>CoviMenu_GetContent('/groupware/layout/board_BoardAuthError.do?CLSYS=board&CLMD=user&CLBIZ=Board&boardType=Total');</script>");
		return;
	}
}
%>	

<script type="text/javascript" src="/covicore/resources/script/Controls/covision.album.js<%=resourceVersion%>"></script>

<style>
.cRConTop.titType > div:first-child .search-condition {
    font-weight: 400;
    vertical-align: middle;
    color: #666;
    border-left: 1px solid #ddd;
    margin: 0 0 0 8px;
    padding: 0 8px;
    border-radius: 0;
    display: inline;
    font-size: 13px;
    letter-spacing: -0.5px;
}

.cRConTop.titType > div:first-child .search-condition div {
	margin: 1px 5px 0 0;
    padding: 0 9px 0 6px;
    display: inline-block;
    height: 24px;
    line-height: 22px;
    font-size: 13px;
    background: #fff;
    border: 1px solid #e6e6e6;
}

.cRConTop.titType > div:first-child .search-condition div .btnRemoveAuto {
    margin-left: 6px;
    display: inline-block;
    width: 8px;
    height: 100%;
    background: url(/HtmlSite/smarts4j_n/covicore/resources/images/common/ic_bt_remove.png) no-repeat center center;
    text-indent: -9999px;
    vertical-align: top;
}
</style>

<div class="cRConTop titType">
	<div>
		<h2 class="title" id="toptitle">공지사항</h2>
		<button type="button" class="help" aria-pressed="true" onclick="boardDescription(this)"><span><spring:message code='Cache.lbl_Description'/></span></button>
		<span id="location"></span>
		<div id="searchCondition" class="search-condition" style="display:none;"></div>
	</div>			
	<div class="searchBox02">
		<span>
			<input id="subjectSearchText" type="text" class="HtmlCheckXSS ScriptCheckXSS">
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
					<option value="Tag"><spring:message code='Cache.lbl_Tag'/></option>	<!-- 태그 -->
				</select>
				<div class="dateSel type02">
					<input id="searchText" type="text" class="HtmlCheckXSS ScriptCheckXSS">
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
		<div id="divSearchFolderArea" style="margin-top: 10px; display: none;">
			<div class="selectCalView">
				<span><spring:message code='Cache.lbl_apv_DocboxFolder'/></span>	<!-- 문서분류 -->
				<a href="#" id="btnFolder" class="btnTypeDefault btnIco btnTypeBlue btnTypeSelect" style="background-color: white;"><spring:message code='Cache.lbl_Select'/></a>
				<div id="divFolderArea" class="inputBoxSytel01 type02" style="display: none;">
					<div id="divSelFolderPath" class="autoComText clearFloat"></div>
				</div>
			</div>
		</div>
	</div>
	<div id="switchAllCont" class="boardAllCont">	<!-- class: boardCommCnt, docAllCont -->
		<!-- #tabList -->
		<%if(boardType.equals("Approval") || boardType.equals("DocAuth") || boardType.equals("DistributeDoc")){%>
		<ul id="tabList" class="tabType2 clearFloat">
			<%if(boardType.equals("Approval") || boardType.equals("DocAuth")){%>
				<li type="Receive"><a href="#" ><spring:message code='Cache.lbl_doc_approvalBox'/></a>	</li><!--승인함-->
				<li type="Request"><a href="#" ><spring:message code='Cache.lbl_doc_requestBox'/></a>	</li><!--요청함-->
			<%}else{%>
				<li type="Receive"><a href="#" ><spring:message code='Cache.lbl_apv_doc_receive'/></a>	</li><!--수신함-->
				<li type="Distribute"><a href="#" ><spring:message code='Cache.lbl_apv_Distribute2'/></a>	</li><!--배포함-->
			<%}%>
		</ul>
		<%} %>
		<%if(!boardType.equals("Total")){ %>
		<div id="boardDescriptiondiv" class="boardSummary">
			<div class="summaryHead">
				<h3 class="title"><spring:message code='Cache.lbl_BoardDescription'/></h3>
 				<button type="button" class="close" aria-pressed="false" onclick="boardDescription(this)"><span><spring:message code='Cache.lbl_close'/></span></button>
			</div>
			<div class="summaryContent"></div>
		</div>
		<%} %>
		<div id="switchTopCnt"  class="boradTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<%if(boardType.equals("Approval")){%>
					<div id="selectTypeDiv" class="selBox">
						<span class="selTit">
							<a id="selectType" class="up" value="all" onclick="clickSelectBox(this);"><spring:message code='Cache.lbl_Whole'/></a>
						</span>
						<div class="selList" style="display: none;">
							<a id="type_all" class="listTxt" value="all" onclick="clickSelectBoxList(this);"><spring:message code='Cache.lbl_Whole'/></a>
							<a id="type_category" class="listTxt" value="category" onclick="clickSelectBoxList(this);"><spring:message code='Cache.lbl_board_category_by'/></a>
							<a id="type_date" class="listTxt" value="date" onclick="clickSelectBoxList(this);"><spring:message code='Cache.lbl_apv_date_by'/></a>
						</div>
					</div>	
				<%}%>
				<% if (bizSection.equals("Community") && aclMap.getString("Create").equals("C")){//커뮤니티만 %>
					<a href="#" id="btnWrite" class="btnTypeDefault btnTypeChk" onclick="javascript:board.goWrite();"><spring:message code='Cache.lbl_Write'/></a>	<!-- 작성 -->
				<%}%>
				<%String isAdmin = "N";
				if( "Y".equals(SessionHelper.getSession("isAdmin")) || (!configMap.isEmpty() && configMap.getString("OwnerCode").indexOf(SessionHelper.getSession("USERID")) != -1)){
					isAdmin = "Y";
				}
				
				// 복사/이동 권한 Y이면
	 			if (boardType.equals("Normal") && !configMap.isEmpty() && configMap.getString("UseCopy").equals("Y")) { 
		 			//관리자, 운영자, 메세지 권한 N, 읽기 권한 일때 복사 버튼 (문서관리는 복사기능 없음)
			 		if (!bizSection.equals("Doc") && (isAdmin.equals("Y") || (!configMap.isEmpty() && configMap.getString("UseMessageAuth").equals("N")) && aclMap.getString("Read").equals("R"))){ %>
						<a href="#" id="btnCopyMsg" class="btnTypeDefault right" onclick="javascript:board.moveFolderPopup('copy');"><spring:message code='Cache.lbl_Copy'/></a>	<!-- 복사 -->
					<%}	//관리자, 운영자, 메세지 권한 N, 삭제 권한 일때 이동 버튼
			 		if (isAdmin.equals("Y") || (!configMap.isEmpty() && configMap.getString("UseMessageAuth").equals("N")) && aclMap.getString("Delete").equals("D")){ %>
						<a href="#" id="btnMoveMsg" class="btnTypeDefault middle" onclick="javascript:board.moveFolderPopup('move');"><spring:message code='Cache.lbl_Move'/></a>	<!-- 이동 -->
					<%}
				}
				if ( (boardType.equals("MyOwnWrite") || boardType.equals("OnWriting") || boardType.equals("MyBooking")|| boardType.equals("Scrap")|| boardType.equals("DocOwner"))
						|| (!configMap.isEmpty() && (isAdmin.equals("Y") || configMap.getString("UseMessageAuth").equals("N") && aclMap.getString("Delete").equals("D")))){%>	
					<a href="#" id="btnDelete" class="btnTypeDefault left" onclick="javascript:chkDelete();"><spring:message code='Cache.lbl_delete'/></a>	<!-- 삭제 -->
				<%}
				
				
				if (!bizSection.equals("Doc") && boardType.equals("Normal")){ 
					if(configMap.getString("UseSubscription").equals("Y")) {//구독%>
						<a href="#" id="btnSubscription" class="btnSubscription <%=(configMap.getString("IsSubscribe").equals("Y")?"active":"")%>" onclick="javascript:coviCtrl.addSubscription(folderID);"><spring:message code='Cache.lbl_Subscription'/></a>	<!-- 구독 -->	
					<%}%>
					<%if(configMap.getString("UseFavorite").equals("Y")) { //즐겨찾기%>
						<a href="#" id="btnFavoriteMenu"  class="btnAddFavorite" onclick="javascript:coviCtrl.addFavoriteMenu(menuID, folderID);"><spring:message code='Cache.lbl_Favorite'/></a>	<!-- 즐겨찾기 -->
					<%}
				}	
				
				if(boardType.equals("Approval") || boardType.equals("DocAuth")){%>
					<a href="#" id="btnApproval" class="btnTypeDefault btnTypeChk" ><spring:message code='Cache.lbl_Approval'/></a>	<!-- 승인 -->
					<a href="#" id="btnReject" class="btnTypeDefault btnTypeX" ><spring:message code='Cache.lbl_Reject'/></a>	<!-- 거부 -->
				<%} %>
				
				<%if (bizSection.equals("Doc")  && !configMap.isEmpty() && 
					 (isAdmin.equals("Y") || aclMap.getString("Create").equals("C"))){%>
					<a href="#" id="btnBinder" class="btnTypeDefault" onclick="javascript:board.goCreateBinder();"><spring:message code='Cache.btn_CreateBinder'/></a>	<!-- 바인더 생성 -->
				<%}%>
				
				<a href="#" id="btnExcel" class="btnTypeDefault btnExcel" onclick="ExcelDownload();"><spring:message code='Cache.btn_SaveToExcel'/></a>	<!-- 엑셀저장 -->
				<%if( !bizSection.equals("Doc") && boardType.equals("Normal") && grCode.equals("") && isAdmin.equals("Y") ){%>
				<div class="addFuncBox">
					<a href="#" class="btnAddFunc"></a><!-- 부가기능 -->
					<ul class="addFuncLilst">
						<li><a id="ctxBoardConfig" href="#" class="icon-setting" onclick="javascript:editBoardPopup(folderID);return false;"><spring:message code='Cache.btn_Preference'/></a></li>	<!-- 환경설정 -->
					</ul>
				</div>
				<%}%>
			</div>
			<div class="buttonStyleBoxRight">
				<select id="selectCategoryID" class="selectType02 selectGroup"></select>
				<span id="multiCategoryArea"></span>
				<select id="selectApprovalStatus" class="selectType02 selectGroup" style="display:none;">
					<option value=""><spring:message code='Cache.lbl_all'/></option>				<!-- 전체 -->
					<option value="P"><spring:message code='Cache.lbl_Progressing'/></option>		<!-- 진행중 -->
					<option value="R" selected="selected"><spring:message code='Cache.lbl_ApprovalReq'/></option>	<!-- 승인요청 -->
					<option value="A"><spring:message code='Cache.lbl_ApprovalComplete'/></option>	<!-- 승인완료 -->
					<option value="D"><spring:message code='Cache.lbl_ApprovalDeny'/></option>		<!-- 승인거부 -->
				</select>
				<select id="selectPageSize" class="selectType02 listCount">
					<option value="10">10</option>
					<option value="15">15</option>
					<option value="20">20</option>
					<option value="30">30</option>
					<option value="50">50</option>
				</select>
				<a href="#" id="listView" class="btnListView listViewType01 active" style="display:none;">리스트보기1</a>
				<a href="#" id="albumView" class="btnListView listViewType02" style="display:none;">리스트보기2</a>
				<button id="btnRefresh" class="btnRefresh" type="button"></button>
			</div>
			<%if(boardType.equals("Approval")){%>
				<div id="groupLiestDiv" class="searchBox" style="display: none;">
					<div class="searchInner"><ul id="selTypeList" class="usaBox"></ul></div>
				</div>
			<%} %>	
		</div>
		<!-- 목록보기-->
		<div id="divListView" class="tblList tblCont <%=(bizSection.equals("Doc")?"tblDocList" :"boradBottomCont")%>">
			<div id="messageGrid"></div>
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
<input type="hidden" id="hiddenSearchFolderIDs" value=""/>

<script type="text/javascript">
var bizSection = (CFN_GetQueryString("communityId") == 'undefined' ? CFN_GetQueryString("CLBIZ") : "Community");//Board, Doc, Community
var boardType = (CFN_GetQueryString("boardType") == 'undefined' ? "Normal" : CFN_GetQueryString("boardType"));	//Normal, Total, MyOwnWrite, OnWriting, RequestModify, MyBooking, Scrap
var viewType = (CFN_GetQueryString("viewType") == 'undefined' ? "List" : CFN_GetQueryString("viewType"));		//List, Album
var boxType = (CFN_GetQueryString("boxType") == 'undefined' ? "Receive" : CFN_GetQueryString("boxType"));		//Request, Receive
var folderID = CFN_GetQueryString("folderID") == 'undefined' ? '' : CFN_GetQueryString("folderID");
var communityID = (CFN_GetQueryString("communityId") == 'undefined' ? "" : CFN_GetQueryString("communityId"));
var grCode = (CFN_GetQueryString("grCode") == 'undefined' ? "" : CFN_GetQueryString("grCode"));
var multiCategory = "";
var menuID = "";

if(communityID != ""){
	menuID = communityID;
} else {
	menuID = (CFN_GetQueryString("menuID") =='undefined'?Common.getBaseConfig(menuCode):CFN_GetQueryString("menuID"));
}

//List 조회, 페이징처리용 Parameter
var sortBy = decodeURIComponent(CFN_GetQueryString("sortBy"));
var page = CFN_GetQueryString("page") == 'undefined'?1:CFN_GetQueryString("page");
var pageSize = CFN_GetQueryString("pageSize") == 'undefined'?10:CFN_GetQueryString("pageSize");
$('#selectPageSize').val(pageSize);

if(CFN_GetCookie("pageSize")){
	pageSize=CFN_GetCookie("pageSize");
}

var searchText = CFN_GetQueryString("searchText") == 'undefined'?"":decodeURIComponent(CFN_GetQueryString("searchText"));
var searchType = CFN_GetQueryString("searchType") == 'undefined'?"Subject":decodeURIComponent(CFN_GetQueryString("searchType"));
$('#searchText').val(searchText);
$('#searchType').val(searchType);

var startDate = CFN_GetQueryString("startDate") == 'undefined'?"":decodeURI(CFN_GetQueryString("startDate"));
var endDate = CFN_GetQueryString("endDate") == 'undefined'?"":decodeURI(CFN_GetQueryString("endDate"));
$('#startDate').val(startDate);
$('#endDate').val(endDate);

var selectSearch = CFN_GetQueryString("selectSearch") == 'undefined'?"":decodeURI(CFN_GetQueryString("selectSearch"));
var readSearchType = CFN_GetQueryString("readSearchType") == 'undefined'?"":decodeURI(CFN_GetQueryString("readSearchType"));

if(readSearchType == "unread") {
	$("#chkRead").prop("checked", true);
}

let isSearch = false;
let limitSearchPeriod = 0;

var messageGrid = new coviGrid();		//게시글 Grid 
var gridOverflowCell = [];			
messageGrid.config.fitToWidthRightMargin=0;
//페이지 로드시 Normal 헤더로 설정

function search(isNotPageReset){
	isSearch = true;
	
	if(!isNotPageReset){
		//검색기능 사용시 페이지 초기화
		coviAlbum.page.pageNo = 1;
		messageGrid.page.pageNo = 1;
	}
	
	//목록형, 앨범형 보기 화면 분기처리
	if(viewType != "List"){
		selectMessageAlbumList(menuID, folderID);
	} else {
		selectMessageGridList(menuID, folderID);
	}
	
	if (boardType === "Approval" && $("#selectType").attr("value") !== "all") {
		setGroupType();
	}
	setBoardSearchContition();
}

function subjectSearch( pSearchText ){
	if (!XFN_ValidationCheckOnlyXSS()) { return; }
	
	$("#searchType").val("Subject");
	$("#searchText").val(pSearchText);

	search();
	
	// 검색어 저장
	coviCtrl.insertSearchData(pSearchText, 'Board');
}

//폴더 그리드 세팅
function setMessageGrid(){
	messageGrid.setGridHeader(msgHeaderData);
	setMessageGridConfig();
	selectMessageGridList(menuID, folderID);	
	
	var pageSize = $("select[id='selectPageSize']");
	
	if(pageSize.length > 0){
		if(CFN_GetCookie("pageSize")){
			pageSize.val(CFN_GetCookie("pageSize"));
		}
	}
}

function setAlbumList(){
	selectMessageAlbumList(menuID, folderID);
}

//폴더 그리드 Config 설정
function setMessageGridConfig(){
	if (CFN_GetQueryString("page") != 'undefined') page = CFN_GetQueryString("page");
	
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

// 파라미터 세팅
function setParameter(pMenuID, pFolderID) {
	if(boardType == "DocTotal"){
		if(pMenuID == ""){
			pMenuID = Common.getBaseConfig("DocMain");
		}
	}
	
	// 전체글보기 기간제약 설정이 있고, 검색 상태가 아닌 경우 검색 기간 제한
	if (limitSearchPeriod > 0 && !isSearch && boardType == 'Total'){
		var eDate = new Date(CFN_GetLocalCurrentDate(_StandardServerDateFormat));
		var sDate = new Date(eDate.getFullYear(), eDate.getMonth(), eDate.getDate()-limitSearchPeriod);
		$("#startDate").val(sDate.format('yyyy.MM.dd'));
		$("#endDate").val(eDate.format('yyyy.MM.dd'));
	}
	
	var searchParam = {
		"bizSection": bizSection,
		"boardType": boardType,
		"viewType": viewType,
		"boxType": boxType,
		"menuID": pMenuID,
		"menuCode": typeof(communityID) != 'undefined' && communityID != '' ? communityID : menuCode,
		"folderID": (pFolderID == "undefined" ? "": pFolderID),
		"folderType": (g_boardConfig.FolderType ? g_boardConfig.FolderType : ""),
		"categoryID": $("#selectCategoryID").val(), //카테고리 선택 조회
		"searchType":$("#searchType").val(),
		"searchText":$("#searchText").val(),
		"startDate":($("#startDate").val() == undefined?"":$("#startDate").val()),
		"endDate":($("#endDate").val() == undefined?"":$("#endDate").val()),
		"useTopNotice": (g_boardConfig.UseTopNotice == undefined || g_boardConfig.UseTopNotice == "N")?"":"Y",
		"useUserForm": (g_boardConfig.UseUserForm == undefined || g_boardConfig.UseUserForm == "N")?"":"Y",
		"approvalStatus": $("#selectApprovalStatus").val(),	//승인 상태 선택 조회
		"readSearchType": $("#chkRead").prop("checked")?'unread':'',
		"communityID": communityID,
		"searchFolderIDs": $("#hiddenSearchFolderIDs").val().replaceAll(";", ",").substring(0, $("#hiddenSearchFolderIDs").val().length - 1),
		"grCode": grCode
	}
	
	if(searchParam.searchType == "UserForm"){
		searchParam['ufColumn'] = $("#searchType option:selected").attr("ufcolumn");
	}
	
	if(multiCategory){
		searchParam['multiCategory'] = multiCategory;
	}
	
	if(searchText != "" || startDate != "" || endDate != "" || selectSearch != "" || readSearchType != ""){
		if(boardType != 'Total' || bizSection != 'Board') {
			$('.btnDetails, .inPerView').addClass('active');
		}
	}
	
	if(messageGrid.config.colGroup && sortBy != "undefined" && sortBy != ""){
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
	}
	
	return searchParam;
}

//게시글 Grid 조회 
function selectMessageGridList(pMenuID, pFolderID){
	var searchParam = setParameter(pMenuID, pFolderID);
	
	messageGrid.bindGrid({
		ajaxUrl:"/groupware/board/selectMessageGridList.do",
		ajaxPars: searchParam
	});
}

//게시글 앨범보기 조회
function selectMessageAlbumList(pMenuID, pFolderID){
	var searchParam = setParameter(pMenuID, pFolderID);
	
	if (CFN_GetQueryString("page") != 'undefined') page = CFN_GetQueryString("page");
	
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
function renderButtonControl(){
	if(viewType != "Album"){
		$("#btnMoveMsg, #btnCopyMsg, #btnDelete").show();
	}else{
		$("#btnMoveMsg, #btnCopyMsg, #btnDelete").hide();
	}
	
	// 즐겨찾기 버튼 - 즐겨찾기 설정이 켜저 있고 전체보기 아닐 경우 표시
	if(g_boardConfig.UseFavorite == "Y" && boardType != "Total" && boardType != "DocTotal"){
	 	$('#btnFavoriteMenu').show();
	 	g_boardConfig.IsFavorite == "Y"?$('#btnFavoriteMenu').addClass("active"):$('#btnFavoriteMenu').removeClass("active");
	 }else{
	 	$('#btnFavoriteMenu').hide();
	 }	 

	 // 구독 버튼 - 구독 설정이 켜저 있을 경우 표시
	 if(g_boardConfig.UseSubscription == "Y"){
		$('#btnSubscription').show();
	 	g_boardConfig.IsSubscribe == "Y"?$('#btnSubscription').addClass("active"):$('#btnSubscription').removeClass("active");
	 }else{
	 	$('#btnSubscription').hide()
	 }
}		

//버튼 안정화후 함수 제거 22.07.06 kimhy2
function renderButtonControl_back(){
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
		changeApprovalTabUI();
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

	
	//부가기능 버튼
	//조건: 시스템 관리자 또는 게시판 운영자이면서 게시판 타입이 'Normal'일 때 표시, 부서 문서함 일때는 표시X
	if( boardType == "Normal" && !grCode &&
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
	} else if( $("#btnCopyMsg").css("display") != "none" && $("#btnMoveMsg").css("display") != "none" &&  $("#btnDelete").css("display") != "none"){
		$("#btnDelete").addClass("left");
	}
}

//전체 버튼, 게시판 옵션, FolderType, BizSection별 표시 숨김
function renderUI(){
/*	if(boardType == "Approval"){	//승인함의 탭구조는 문서 관리쪽 Class를 사용해야하므로 분기처리
		switchContClass("Doc");		//Tab구조의 화면은 Class가 문서관리 기준으로 설정됨
		setApprovalSelect();
	} else {
		switchContClass(bizSection);
	} 
*/	
	if(g_boardConfig.UseCategory == "Y"){
		$("#selectCategoryID").coviCtrl("setSelectOption", "/groupware/board/selectCategoryList.do", {"folderID": folderID}, "<spring:message code='Cache.msg_Select'/>", "");
		
		var selectCategoryID = CFN_GetQueryString("selectCategoryID") || "";
		selectCategoryID = selectCategoryID == "undefined" ? "" : selectCategoryID;
		if("" != selectCategoryID){
			$('#selectCategoryID').val(selectCategoryID);
		}
	} else {
		$("#selectCategoryID").hide();
	}
	
	// 다중 카테고리
	if(Common.getBaseConfig("use" + bizSection + "MultiCategory") == "Y"){
		var multiCategoryCode = Common.getBaseConfig(bizSection + "MultiCategoryCode");
		
		if(multiCategoryCode){
			var multiCategoryCodeArr = multiCategoryCode.split(",");
			var $fragment = $(document.createDocumentFragment());
			var lang = Common.getSession("lang");
			
			$.each(multiCategoryCodeArr, function(idx, mCode){
				var $select = $(String.format("<select class='selectType02' ufid='{0}'></select>", idx));
				
				$(Common.getBaseCode(mCode).CacheData).each(function(){
					if(this.Code){
						$select.append(String.format("<option value='{0}'>{1}</option>", (this.Code === mCode ? "" : this.Code), CFN_GetDicInfo(this.MultiCodeName, lang)));
					}
				});
				
				$fragment.append($select);
			});
			
			$("#multiCategoryArea").append($fragment);
			
			$("#multiCategoryArea select").on("change", function(){
				var selValList = [];
				
				$("#multiCategoryArea select").each(function(idx, item){
					var selVal = $(item).val();
					var ufid = Number($(item).attr("ufid")) + 1;
					
					if(selVal) selValList.push(ufid + "-" + selVal);
				});
				
				multiCategory = selValList.join(";");
				search();
			});
		}
	}
	
	if(bizSection != "Doc"){
		//boardType값에 따라 tab 표시 숨김 및 Div Class 분기처리
		if(g_boardConfig.FolderType == "Album" && CFN_GetQueryString("viewType") == 'undefined'){	//viewType 변경
			// 앨범 유형 게시판의 경우, 쿼리 스트링의 viewType이 있으면 보기유형 유지. 없으면 album 유형으로 설정.
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
		}else if(grCode){
			boardType = "Doc";
		}
		
		// 문서관리에서 문서번호 검색 옵션 추가
		$("#searchType").append($("<option>").val("Number").text("<spring:message code='Cache.lbl_DocNo'/>")); // 믄서번호
		
		if (searchType === "Number") {
			$("#searchType").val(searchType);
		}
		
		// 전체 문서 보기에서 문서 분류 검색 영역 추가
		$("#hiddenSearchFolderIDs").val("");
		
		if(boardType && boardType === "DocTotal"){
			$("#divSearchFolderArea").show();
			
			$("#btnFolder").on("click",function(e){
				var selId = $(e.target).attr("id");
				parent._CallBackMethod = addSearchFolder;
				
				parent.Common.open("", "boardTreePopup",
					"<spring:message code='Cache.lbl_apv_DocboxFolder'/>",
					"/groupware/board/goSearchBoardTreePopup.do?bizSection="+bizSection,
					"340px", "500px", "iframe", true, null, null, true);
			});
		}else{
			$("#divSearchFolderArea").hide();
		}
	}
	
	if(boardType == "Normal" && coviCmn.isNull(folderID, '') != ''){
		getUserDefFieldList(folderID);
	}
	
	msgHeaderData = board.getGridHeader(boardType, boxType, folderID);
	gridOverflowCell = board.getGridOverflowCell(boardType);
	//목록형, 앨범형 보기 화면 분기처리
	if(viewType != "List"){
		changeAlbumView();	//앨범 리스트 표시
		setAlbumList();
	} else {
		changeBoardView();	//Grid 리스트 표시
		setMessageGrid();
	}
}


//CHECK: board.js로 이동 예정
//Tab 항목 생성 및 내부 항목별 type코드 설정(boxType)
function renderTabUI(){
/*	switch(boardType){
		case "Approval":	//승인요청
		case "DocAuth":		//문서권한
			$("#tabList").html($('<li type="Receive"/>').append($('<a href="#" />').text("<spring:message code='Cache.lbl_doc_approvalBox'/>"))); // 승인함
			$("#tabList").append($('<li type="Request"/>').append($('<a href="#" />').text("<spring:message code='Cache.lbl_doc_requestBox'/>"))); // 요청함
			break;
		case "DistributeDoc"://문서배포
			$("#tabList").html($('<li type="Receive"/>').append($('<a href="#" />').text("<spring:message code='Cache.lbl_apv_doc_receive'/>"))); // 수신함
			$("#tabList").append($('<li type="Distribute"/>').append($('<a href="#" />').text("<spring:message code='Cache.lbl_apv_Distribute2'/>"))); // 배포함
			break;
	}
	*/
	//Tab 선택시 재조회 이벤트
	$("#tabList li").on("click",function(){
		$(this).addClass("active");
		$("#tabList li").not($(this)).removeClass("active");
		
		if(boardType == "Approval" || boardType == "DocAuth" || boardType == "DistributeDoc")
			changeApprovalTabUI();
		
		msgHeaderData = board.getGridHeader(boardType, boxType, folderID);
		if(viewType != "List"){
			setAlbumList();
		} else {
			setMessageGrid();
		}
		
		if (boardType === "Approval" && $("#selectType").attr("value") !== "all") {
			setGroupType();
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
			
			var location = g_boardConfig.FolderPathName.replaceAll(";", " > ").slice(0, -3);
			$("#location").text(location);
			$("#location").attr('class','location');
			$("#location").attr('title',location);
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
			if(grCode) boardTitle = getGroupName(grCode);
			else boardTitle = CFN_GetDicInfo(g_boardConfig.MultiDisplayName);
			break;
		case "CheckIn":			//문서관리 boardType: CheckIn
			boardTitle = "<spring:message code='Cache.lbl_CheckIn'/>";
			break;
		case "CheckOut":		//문서관리 boardType: CheckOut
			boardTitle = "<spring:message code='Cache.lbl_CheckOut'/>";
			break;
		case "DocOwner":		//문서관리 boardType: MyOwner
			boardTitle = "<spring:message code='Cache.lbl_Doc_myDoc'/>";
			$("#btnMoveMsg").removeClass("middle").addClass("right");
			break;
		case "DocFavorite":		//문서관리 boardType: 관심문서
			boardTitle = "관심문서";
			$("#btnMoveMsg").removeClass("middle").addClass("right");
			break;
		case "DocAuth":		//문서 권한
			boardTitle = "<spring:message code='Cache.lbl_Doc_docAuth'/>";
			$("#tabList").show();
			
			$('#btnApproval').on('click', function(){
				board.commentPopup('allow');
			});
			
			$('#btnReject').on('click', function(){
				board.commentPopup('denie');
			});

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
	$("#toptitle").text(boardTitle);		//최상단 타이틀 변경
	renderButtonControl();
}

//승인함, 요청함 탭에 따라 표시/숨김 및 select parameter 변경
function changeApprovalTabUI(){
	boxType = $("#tabList li.active").attr("type");	//boxTyper 값 변경
	if(boardType!="DistributeDoc" && boxType == "Receive"){	//승인함, 수신함
		$("#selectApprovalStatus").show().val(
			(CFN_GetQueryString("approvalStatus") != "undefined" ) ? CFN_GetQueryString("approvalStatus") : "R"
		);
		$("#btnApproval, #btnReject").show();
	} else if(boxType == "Request"){	//요청함
		$("#selectApprovalStatus").hide().val("");
		$("#btnApproval, #btnReject").hide();
	}
}

function getUserDefFieldList(folderID){
	$.ajax({
		url: "/groupware/board/selectUserDefFieldList.do",
		type: "post",
		async: false,
		data: {
			"folderID": folderID
			, "onlyData": "Y"
		},
		success: function(res){
			if(res.status == "SUCCESS"){
				var list = res.list;
				
				if(list.length != 0){
					$.each(list, function(idx, item){
						if(item.IsSearchItem == "Y"){
							$("#searchType").append($("<option>").val("UserForm").attr("ufcolumn", "UF_Value"+idx).text(item.FieldName));
						}
					});
					
					// 검색 조건 바인딩
					if (searchType === "UserForm" && CFN_GetQueryString("ufColumn") !== 'undefined') {
						$('#searchType option[ufColumn=' + CFN_GetQueryString("ufColumn") + ']').prop("selected", true);
					}
				}
			}
		},
		error: function(response, status, error){
			CFN_ErrorAjax(url, response, status, error);
		}
	});
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
   			var headerType = getHeaderTypeForExcel();

   			var sortInfo = messageGrid.getSortParam("one").split("=");
   			var	sortKey = sortInfo.length>1? sortInfo[1].split(" ")[0]:"";
   			var	sortWay = sortInfo.length>1? sortInfo[1].split(" ")[1]:"";				  	
   			var useUserForm = (g_boardConfig.UseUserForm == undefined || g_boardConfig.UseUserForm == "N")?"":"Y";
   			var approvalStatus = $("#selectApprovalStatus").val();	//승인 상태 선택 조회
   			var readSearchType = $("#chkRead").prop("checked")?'unread':'';
   			var url = String.format("/groupware/board/messageListExcelDownload.do?boardType={0}&bizSection={1}&menuID={2}&folderID={3}&startDate={4}&endDate={5}&sortKey={6}&sortWay={7}&searchText={8}&searchType={9}&folderType={10}&boxType={11}&useUserForm={12}&approvalStatus={13}&headerType={14}&readSearchType={15}&domainID={16}&searchFolderIDs={17}&grCode={18}&excelTitle={19}&useCategory={20}&useReadCnt={21}&menuCode={22}", 
   					boardType, 
   					bizSection, 
   					menuID, 
   					(folderID == "undefined" ? "": folderID), 
   					$("#startDate").val(), 
   					$("#endDate").val(), 
   					sortKey, 
   					sortWay, 
   					$("#searchText").val(), 
   					$("#searchType").val(),
   					g_boardConfig.FolderType,
   					boxType,
   					useUserForm,
   					approvalStatus,
   					encodeURI(headerType),
   					readSearchType,
   					Common.getSession("DN_ID"),
   					$("#hiddenSearchFolderIDs").val().replaceAll(";", ",").substring(0, $("#hiddenSearchFolderIDs").val().length - 1),
   					grCode,
   					encodeURI($(".title").text()),
   					g_boardConfig.UseCategory,
   					g_boardConfig.UseReadCnt,
   					window.menuCode);
   			
   			if($("#searchType").val() == "UserForm"){
   				var ufColumn = $("#searchType option:selected").attr("ufcolumn");
   				url += "&ufColumn=" + ufColumn;
   			}

   			if(communityID) url += "&communityID=" + communityID;
   			
   			if(multiCategory) url += "&multiCategory=" + multiCategory;
   			
   			location.href = url;
   		}
	});
}

//엑셀용 Grid 헤더정보 설정
function getHeaderNameForExcel(){
	var returnStr = "";
	
   	for(var i=0;i<msgHeaderData.length; i++){
   	   	if(msgHeaderData[i].display != false &&
   	   			msgHeaderData[i].label != '' && 
   	   			msgHeaderData[i].key != '' && 
   	   			msgHeaderData[i].key != 'FileCnt' &&
   	    	   	msgHeaderData[i].key != 'chk' && 
   	    	 	msgHeaderData[i].key != 'CreatorCode' && 
   	    	 	msgHeaderData[i].key != 'Depth' && 
   	    		msgHeaderData[i].key != 'Step' &&
   	    		msgHeaderData[i].key != 'Seq' &&  
  	    	   	msgHeaderData[i].key != 'AclList' &&
   	    	   	msgHeaderData[i].key != 'FolderID' ){
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
   	   			msgHeaderData[i].key != '' && 
   	   			msgHeaderData[i].key != 'FileCnt' &&
   	    	   	msgHeaderData[i].key != 'chk' && 
   	    	 	msgHeaderData[i].key != 'CreatorCode' && 
   	    	 	msgHeaderData[i].key != 'Depth' && 
   	    		msgHeaderData[i].key != 'Step' &&
   	    		msgHeaderData[i].key != 'Seq' &&  
  	    	   	msgHeaderData[i].key != 'AclList' &&
   	    	   	msgHeaderData[i].key != 'FolderID'){
			returnStr += msgHeaderData[i].key + ",";
   	   	}
	}
   	returnStr = returnStr.substring(0, returnStr.length-1);
	return returnStr;
}

function getHeaderTypeForExcel(){
	var returnStr = "";

   	for(var i=0;i<msgHeaderData.length; i++){
   		if(msgHeaderData[i].display != false &&
   	   			msgHeaderData[i].label != '' && 
   	   			msgHeaderData[i].key != '' && 
   	   			msgHeaderData[i].key != 'FileCnt' &&
   	    	   	msgHeaderData[i].key != 'chk' && 
   	    	 	msgHeaderData[i].key != 'CreatorCode' && 
   	    	 	msgHeaderData[i].key != 'Depth' && 
   	    		msgHeaderData[i].key != 'Step' &&
   	    		msgHeaderData[i].key != 'Seq' &&  
  	    	   	msgHeaderData[i].key != 'AclList' &&
   	    	   	msgHeaderData[i].key != 'FolderID'){
			returnStr += (msgHeaderData[i].dataType != undefined ? msgHeaderData[i].dataType:"Text") + "|";
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
	CFN_OpenWindow("/covicore/control/goImageSlidePopup.do?" + contextParam,"Image Slide",820,780,"scroll");	//이미지 슬라이드 쇼
}

//게시판 환경설정 팝업
function editBoardPopup(pFolderID){
	var disp_popup_name = "<spring:message code='Cache.lbl_BoardConfigSet'/>|||<spring:message code='Cache.lbl_FolderModify'/>";
	var context_url = "/groupware/board/manage/goFolderManagePopup.do?";
	var param_url = "domainID="+sessionObj["DN_ID"]+"&menuID="+menuID+"&folderID="+pFolderID+"&bizSection="+bizSection+"&mode=edit&CommunityID="+communityID;
	parent.Common.open("", "setBoard", disp_popup_name, context_url+param_url,"700px","680px","iframe",true,null,null,true);
}

function bindControlEvent(){
	//페이지 개수 변경
	$("#selectPageSize").off('change').on("change", function(){
		pageSize = $(this).val();
		
		CFN_SetCookieDay("pageSize", $(this).find("option:selected").val(), 31536000000);
		
		messageGrid.page.pageSize = $(this).val();
		coviAlbum.page.pageSize = $(this).val();
		
		search();
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
		
		if (!XFN_ValidationCheckOnlyXSS()) { return; }
		if($("#startDate").val() > $("#endDate").val()){
			Common.Warning(Common.getDic("msg_StartDateCannotAfterEndDate"));		//시작일은 종료일 보다 이후일 수 없습니다.
			return;
		}
		
		search();
		
		// 검색어 저장
		coviCtrl.insertSearchData($("#searchText").val(), 'Board');
	});
	
	//상세검색 엔터 키
	$("#searchText").on('keypress', function(e){
		if (e.which == 13) {
	        if (!XFN_ValidationCheckOnlyXSS()) { return; }
			if($("#startDate").val() > $("#endDate").val()){
				Common.Warning(Common.getDic("msg_StartDateCannotAfterEndDate"));		//시작일은 종료일 보다 이후일 수 없습니다.
				return;
			}

			search();
			
			// 검색어 저장
			coviCtrl.insertSearchData($("#searchText").val(), 'Board');
		}
	});

	//갱신
	$("#btnRefresh").off('click').on('click', function(){
		search(true);
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
			if (boardType == 'Total' && bizSection == 'Board') $("#searchCondition").show();
		}else {
			mParent.addClass('active');
			$(this).addClass('active');
			if (boardType == 'Total' && bizSection == 'Board') $("#searchCondition").hide();
		}
		coviInput.setDate();			
	});

	//카테고리 변경시 자동 조회
	$("#selectCategoryID, #selectApprovalStatus").off('change').on("change",function(){
		search();
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

function getGroupName(pGrCode){
	var resultStr = "";
	
	$.ajax({
		type: "POST",
		url: "/groupware/board/selectBoardGroupName.do",
		async: false,
		data: {
       		"grCode": pGrCode
       	},
       	success: function(data){
       		resultStr = data.GroupName;
       	},
       	error: function(response, status, error){
	     CFN_ErrorAjax("/groupware/board/selectBoardGroupName.do", response, status, error);
   		}
	});
	
	return resultStr;
}

function addSearchFolder(pFolderObj){
	var multiFolderID = $("#hiddenSearchFolderIDs").val();
	var selFolderID = pFolderObj.FolderID;
	
	if(multiFolderID.indexOf(selFolderID) > -1){
		Common.Warning("<spring:message code='Cache.msg_alreadyAddClass'/>"); // 이미 추가된 분류입니다.
		return false;
	}
	
	board.getBoardConfig(selFolderID);
	
	var folderPath = $("<div tag='"+selFolderID+"'></div>")
		.append(board.renderFolderPath())
		.append($("<a class='btnRemoveAuto'></a>")
			.click(function(){
				var fdid = $(this).closest("div").attr("tag");
				var hidMultiFdid = $("#hiddenSearchFolderIDs").val();
				
				$("#hiddenSearchFolderIDs").val(hidMultiFdid.replace(fdid + ";", ""));
				$(this).closest("div").remove();
				
				if($("#divSelFolderPath div").length == 0) $("#divFolderArea").hide();
		}));
	
	$("#divSelFolderPath").append(folderPath);
	$("#hiddenSearchFolderIDs").val(selFolderID + ";" + multiFolderID);
	if($("#divSelFolderPath div").length > 0) $("#divFolderArea").show();
}

function setApprovalSelect(){
	var $select = $("<div/>", {"id": "selectTypeDiv", "class": "selBox", "style": "width: 95px;"})
					.append($("<span/>", {"class": "selTit"})
						.append($("<a/>", {"id": "selectType", "class": "up", "value": "all", "text": "<spring:message code='Cache.lbl_Whole'/>", "onclick": "clickSelectBox(this);"}))) // 전체
					.append($("<div/>", {"class": "selList", "style": "width: 95px; display: none;"})
						.append($("<a/>", {"id": "type_all", "class": "listTxt", "value": "all", "text": "<spring:message code='Cache.lbl_Whole'/>", "onclick": "clickSelectBoxList(this);"})) // 전체
						.append($("<a/>", {"id": "type_category", "class": "listTxt", "value": "category", "text": "<spring:message code='Cache.lbl_board_category_by'/>", "onclick": "clickSelectBoxList(this);"})) // 게시분류별
						.append($("<a/>", {"id": "type_date", "class": "listTxt", "value": "date", "text": "<spring:message code='Cache.lbl_apv_date_by'/>", "onclick": "clickSelectBoxList(this);"})) // 날짜별
					);
	
	var $searchBox = $("<div/>", {"id": "groupLiestDiv", "class": "searchBox", "style": "display: none;"})
						.append($("<div/>", {"class": "searchInner"})
							.append($("<ul/>", {"id": "selTypeList", "class": "usaBox"})));
	
	$(".pagingType02").prepend($select);
	$("#switchTopCnt").append($searchBox);
}

function clickSelectBoxList(pObj){
	clickSelectBox(pObj);
	
	//messageGrid.bindGrid({page: {pageNo: 1, pageSize: 10, pageCount: 1}, list: []});
	if(viewType == "List"){
		messageGrid.bindGrid({page: {pageNo: 1, pageSize: 10, pageCount: 1}, list: []});
	}
	
	setGroupType();
}

function setGroupType(){
	var selType = $("#selectType").attr("value");
	$("#selTypeList").empty();
	
	if(selType !== "all"){
		var lang = Common.getSession("lang");
		var searchParam = setParameter(menuID, folderID);
		searchParam["searchGroupType"] = selType;
		
		$("#groupLiestDiv").show();
		
		$.ajax({
			url: "/groupware/board/selectTypeList.do",
			type: "POST",
			data: searchParam,
			success: function(res){
				if(res.status === "SUCCESS"){
					if(res.list.length == 0){
						$("#groupLiestDiv").css({"height": "42px", "line-height": "20px"});
						$("#selTypeList").css("text-align", "center").append("<spring:message code='Cache.msg_NoDataList'/>"); // 조회할 목록이 없습니다
						messageGrid.bindGrid({page: {pageNo: 1, pageSize: 10, pageCount: 1}, list: []});
					}else{
						var $fragment = $(document.createDocumentFragment());
						
						$(res.list).each(function(){
							var $li = $("<li/>").append($("<a/>", {"id": "fieldName_" + this.fieldID, "text": this.fieldName + " (" + this.fieldCnt + ")", "onclick": "setSearchGroupWord('" + selType + "', '" + this.fieldID + "');"}));
							$fragment.append($li);
						});
						
						$("#groupLiestDiv").css({"height": "unset", "line-height": "unset"});
						$("#selTypeList").append($fragment);
						$("#selTypeList").show();
					}
				}else{
					Common.Error("<spring:message code='Cache.msg_ErrorOccurred'/>"); // 오류가 발생하였습니다.
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/board/selectTypeList.do", response, status, error);
			}
		});
	}else{
		$("#groupLiestDiv").hide();
		search(true);
	}
}

function setSearchGroupWord(type, fieldID) {
	var searchParam = setParameter(menuID, folderID);
	
	switch(type) {
		case "category":
			searchParam["folderID"] = fieldID;
			break;
		case "date":
			searchParam["startDate"] = fieldID;
			searchParam["endDate"] = fieldID;
			break;
	}
	
	//목록형, 앨범형 보기 화면 분기처리
	if(viewType != "List"){
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
		
		changeAlbumView();	//앨범 리스트 표시
	} else {
		messageGrid.bindGrid({
			ajaxUrl:"/groupware/board/selectMessageGridList.do",
			ajaxPars: searchParam
		});
		
		changeBoardView();	//Grid 리스트 표시
	}
}

function setBoardSearchContition(){
	if (boardType == 'Total') {
		$("#searchCondition").html('');
		var hasSearhCondition = false;
		if ($("#searchText").val() != ''){
			$("#searchCondition").append(
				'<div>' + 
					$("#searchType option[value="+$("#searchType").val()+"]").text() + ": " + $("#searchText").val() + 
					'<a href="#" class="btnRemoveAuto" data-target="searchText" onclick="javascript:removeBoardSearchContition(this);"></a>' +
				'</div>'
			);
			hasSearhCondition = true;
		}
		if ($("#chkRead").prop("checked")){
			$("#searchCondition").append(
				'<div>' + 
					$("label[for=chkRead]").text() + 
					'<a href="#" class="btnRemoveAuto" data-target="chkRead" data-target-type="checkbox" onclick="javascript:removeBoardSearchContition(this);"></a>' +
				'</div>'
			);
			hasSearhCondition = true;
		}
		if ($("#startDate").val() != '' && $("#endDate").val() != '') {
			$("#searchCondition").append(
				'<div>' + 
					Common.getDic('lblSearchScope') + ": " + $("#startDate").val() + " ~ " + $("#endDate").val() + 
					'<a href="#" class="btnRemoveAuto" data-target="Date" data-target-type="date" onclick="javascript:removeBoardSearchContition(this);"></a>' + 
				'</div>'
			);
			hasSearhCondition = true;
		}
		if (!$(".btnDetails").hasClass("active") && hasSearhCondition){
			$("#searchCondition").show();
		}
	} else {
		$("#searchCondition").hide();
	}
}

function removeBoardSearchContition(pTarget){
	var targetID = $(pTarget).attr('data-target');
	var targetType = $(pTarget).attr("data-target-type");
	
	if (targetType == 'checkbox') { $("#"+targetID).prop("checked", false); }
	else if (targetType == 'date') { $("#selectSearch").val('').change(); }
	else { $("#"+targetID).val(''); }
	
	$(pTarget).parent().remove();
}

initContent();

function initContent(){
	$('#selectSearch').coviCtrl("setDateInterval", $('#startDate'), $('#endDate'), "", {"changeTarget": "start"});
	$('#selectSearch').val(selectSearch);
	
	sessionStorage.setItem("urlHistory", $(location).attr('pathname') + $(location).attr('search'));
	g_urlHistory = $(location).attr('pathname') + $(location).attr('search');
	
	board.getBoardConfig(folderID);	//게시판별 옵션 조회 (board_config)
	
	if(localStorage.getItem("ContentsID") !== null){
		for(i=0;i<JSON.parse(localStorage.getItem("ContentsID")).length;i++){
			if(g_boardConfig.ContentsID == JSON.parse(localStorage.getItem("ContentsID"))[i]){
				$('.boardSummary').attr('aria-expanded', 'false');
				$('.cRConTop .help').attr('aria-pressed', 'false');
			}	
		}	
	}
	
	if(g_boardConfig.Body != undefined){
		$(".summaryContent").html(board.XSSBoard(unescape(g_boardConfig.Body)));	
	} else {
		$('.boardSummary').attr('aria-expanded', 'false');
	}

	if (bizSection != 'Community'){
		if (Common.getBaseConfig('limitTotalSearch') != 'nouse') {
			var configLimitTotalSearch = Common.getBaseConfig('limitTotalSearch');
			if (configLimitTotalSearch.indexOf(menuCode) > -1) {
				var configArr = configLimitTotalSearch.split(';');
				$.each(configArr, function(idx, el){
					if (el.split('@@')[0] == menuCode) {
						limitSearchPeriod = el.split('@@')[1];
						return false;
					}
				});
			}
		}
	}
	
	if (bizSection == 'Doc'){
		$("#listView, #albumView").hide();
	} else {
		$("#listView, #albumView").show();
	}
	
	renderUI();						//게시판 타입별 UI변경
	
	setBoardSearchContition();
}
</script>