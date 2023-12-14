<%@page import="egovframework.baseframework.util.SessionHelper,egovframework.covision.groupware.util.BoardUtils,egovframework.covision.groupware.auth.BoardAuth,egovframework.baseframework.data.CoviMap,egovframework.baseframework.util.DicHelper,egovframework.coviframework.util.XSSUtils"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil,egovframework.coviframework.util.ComUtils"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<!-- 상단 버튼 컨트롤 -->
<div class="cRContBottom mScrollVH " style="top:0px;">
	<div class="boardAllCont" style="display:none;">
		<div class="boradTopCont">
			<div class=" cRContBtmTitle">
				<div>
					<div id="FolderName" class="boxDivTit"></div>	<!-- 게시판명 -->
					<div class="collabo_help02" style="float:right"> <!-- 게시 정보 toolTip -->
						<a href="javascript:void(0);" class="help_ico" id="boardIcon" style="margin-top:3px;"></a>
						<div class="boardData helppopup"></div>
					</div>
					<div id="ExpiredDate"></div> 					<!-- 게시만료일 -->
					<!-- 카테고리 -->
				</div>
				<div class="boardTitle">
					<h2 id="Subject" ><!-- 게시글 제목 --></h2>		
					<div class="boardTitData">
						<span id="RegistDate" class="date"></span>	<!-- 등록일자 -->
						<span id="ReadCnt" class="hit">0</span>		<!-- 조회수 -->
					</div>
				</div>
			</div>
		</div>
		<div class="boradBottomCont">
			<div class="boardViewCont">
				<div class="bvcTitle">
					<div class="personBox">
						<div class="perPhoto">
							<img id="CreatorPhoto" src="/covicore/resources/images/common/noImg.png" onerror='coviCmn.imgError(this);' alt="프로필사진">
						</div>
						<p class="name">
							<strong id="CreatorName"></strong>	<!-- 작성자 이름 및 직급 -->
							<span id="CreatorDept"></span>		<!-- 작성자 부서 -->
						</p>	
					</div>
					<div class="attFileListBox">
					</div>
				</div>	
						
				<!-- 사용자 정의 필드 영역 -->												
				<div id="divUserDefField" class="boradDisplay type02">
				</div>
				<!-- 링크 게시판 영역-->												
				<div id="divLinkSiteBoard" class="boradDisplay type02">
				</div>
				<!-- 연결 게시글 표시 영역 -->
				<div id="divLinkedMessage" class="boradDisplay type02">
					<div>
						<div class="tit"></div>
						<div class="borNemoListBox"></div>
					</div>
				</div>
				
				<div class="boardDisplayContent">
					<div id="BodyText" class="boardDetaileVeiw" style="line-height: 20px;"><!-- 본문 영역 -->
					</div>
					<div class="tagView">
						<span class="sNoti">
							<!-- 분류일 -->
							<span class="line">|</span>
							<!-- 만료일 -->
						</span>
					</div>
				</div>
				<div id="divComment" class="commentView">								
				</div>				
			</div>
		</div>				
	</div>	
</div>


<span id="messageDetail"></span>
<div id="con_file"></div>

<input type="hidden" id="hiddenFolderID" value=""/>
<input type="hidden" id="hiddenMessageID" value=""/>
<input type="hidden" id="hiddenComment" value=""/>
<input type="hidden" id="hiddenCheckOuterCode" value="" />
<input type="hidden" id="messageAuth" name="messageAuth" value="" />
<script type="text/javascript">

var bizSection = (CFN_GetQueryString("communityId") !== "undefined" && CFN_GetQueryString("communityId") !== "") ? "Community" : CFN_GetQueryString("CLBIZ");
var boardType = CFN_GetQueryString("boardType") == "undefined" ? "Normal" : CFN_GetQueryString("boardType");	//Normal외에 메뉴별 타입
var viewType = CFN_GetQueryString("viewType") == "undefined" ? "List" : CFN_GetQueryString("viewType");		//List, Album, Popup
var version = CFN_GetQueryString("version");
var folderID = CFN_GetQueryString("folderID");
var messageID = CFN_GetQueryString("messageID");
var categoryID = CFN_GetQueryString("categoryID");
var communityID = CFN_GetQueryString("communityId") == "" ? "" : CFN_GetQueryString("communityId");
var menuID = CFN_GetQueryString("menuID") == "undefined" ? "" : CFN_GetQueryString("menuID");
var hasModifyAuth = true; //조회권한 강제 설정

//이전글, 다음글 표시용 parameter
var startDate = CFN_GetQueryString("startDate");
var endDate = CFN_GetQueryString("endDate");
var searchType = CFN_GetQueryString("searchType");
var searchText = CFN_GetQueryString("searchText");
var sortBy = CFN_GetQueryString("sortBy");

//추후 변경 가능성 있음
var boardObj = {
	"bizSection": bizSection,        // Board, Doc, Community
	"boardType": boardType,
	"version": version,
	"folderID": folderID,
	"messageID": messageID,
	"startDate": startDate,
	"endDate": endDate,
	"searchType": searchType,
	"searchText": searchText,
	"sortBy": decodeURIComponent(sortBy),
	"menuID": menuID
};

board.downloadAll = function(){
	// TODO 다국어 메세지 처리 미리보기에서는 실행 할 수 없습니다.
}
coviComment.addLikeCount = function(){
	// TODO 다국어 메세지 처리 미리보기에서는 실행 할 수 없습니다.
}
coviComment.save = function(){
	// TODO 다국어 메세지 처리 미리보기에서는 실행 할 수 없습니다.
}
board.checkExecuteAuth = function(){
	return true;
}
Common.fileDownLoad = function(){
	// TODO 다국어 메세지 처리 미리보기에서는 실행 할 수 없습니다.
}
coviComment.callImgUpload = function(){
	// TODO 다국어 메세지 처리 미리보기에서는 실행 할 수 없습니다.
}
coviComment.callFileUpload = function(){
	// TODO 다국어 메세지 처리 미리보기에서는 실행 할 수 없습니다.
}
Common.filePreview = function(){
	// TODO 다국어 메세지 처리 미리보기에서는 실행 할 수 없습니다.
}

initContent();

function initContent(){
	
	var preViewData = parent.board.getPreViewData();
	
	board.getBoardConfig(folderID);	//게시판별 옵션 조회 (board_config)
	
	//게시글 상세보기에 표시할 정보 조회: selectMessageDetail() -> renderMessageInfoView()
	board.renderMessageInfoView(bizSection, preViewData);
	$(".boardAllCont").show();
	
	//Tag, Link, 확장필드, 본문양식 등 옵션별 표시
	board.renderpreViewMessageOptionView(bizSection, folderID, preViewData)
	
	//컨텐츠 게시 목록버튼 및 이전글, 다음글 숨김
	$("#btnList, .prvNextList").hide();
	
	$('.btnTop').on('click', function(){
		$('.mScrollVH').animate({scrollTop:0}, '500');
	});
	
	$('.btnAddFunc').on('click', function(){
		if($(this).hasClass('active')){
			$(this).removeClass('active');
			$('.addFuncLilst').removeClass('active');
		} else {
			$(this).addClass('active');
			$('.addFuncLilst').addClass('active');
		}
	});
	
}


</script>
