<%@page import="egovframework.baseframework.util.SessionHelper,
				egovframework.covision.groupware.util.BoardUtils,
				egovframework.covision.groupware.auth.BoardAuth,
				egovframework.baseframework.data.CoviMap,
				egovframework.coviframework.util.DicHelper,
				egovframework.coviframework.util.XSSUtils,egovframework.coviframework.util.CoviLoggerHelper,
				java.text.SimpleDateFormat,
				java.util.Date"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil,egovframework.coviframework.util.ComUtils"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<style>
.fileSize {
    width: auto;
    max-width: 80px;
    margin-left: 4px;
    margin-top: 1px;
}

.woRd {
   height: 18px !important;
}

.word {
    padding-left: 26px;
    line-height: 17px;
    color: #000;
    background: url('/HtmlSite/smarts4j_n/covicore/resources/images/common/ic_word.png') no-repeat 0 center;
    text-indent: 0 !important;    
}
</style>
<%
String bizSection = request.getParameter("CLBIZ");
String boardType  = request.getParameter("boardType") == null ? "Normal" : request.getParameter("boardType");	//Normal외에 메뉴별 타입
boolean hasModifyAuth = false;

if (request.getParameter("communityId") != null && !request.getParameter("communityId").equals("")){
	bizSection = "Community";
}

CoviMap params = new CoviMap();
BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
params.put("bizSection", bizSection);

CoviMap configMap = new CoviMap();
CoviMap msgMap = new CoviMap();
CoviMap aclMap = new CoviMap();
CoviMap msgACLMap = new CoviMap();

if (request.getParameter("folderID")== null ){
	CoviLoggerHelper.authErrorLogger((String) request.getAttribute("javax.servlet.forward.request_uri"), "NOAUTH", "", "", "Auth unauthorized : No permission", "page");
	out.println("<script language='javascript'>window.location.href = '/covicore/coviException.do?CLSYS=portal&CLMD=user&CLBIZ=Portal&exceptionType=NoAuth';</script>");
	return;
} else {
	String folderID = request.getParameter("folderID");
	CoviMap returnMap = BoardUtils.getFolderConfig(params);
	
	configMap = (CoviMap)returnMap.get("configMap");
	msgMap = (CoviMap)returnMap.get("msgMap");
	aclMap = (CoviMap)returnMap.get("aclMap");
	msgACLMap = (CoviMap)returnMap.get("msgACLMap");
	
	if (!returnMap.getBoolean("isAuth").equals(true) || !returnMap.getBoolean("isRead").equals(true) || msgMap == null){
		CoviLoggerHelper.authErrorLogger((String) request.getAttribute("javax.servlet.forward.request_uri"), "NOAUTH", "", "", "Unauthorized : No Permission", "page");
		out.println("<script language='javascript'>window.location.href = '/covicore/coviException.do?CLSYS=portal&CLMD=user&CLBIZ=Portal&exceptionType=NoAuth';</script>");
		return;
	}
	
	hasModifyAuth = BoardAuth.getModifyAuth(params);
	out.println("<script language='javascript'>var hasModifyAuth = " + hasModifyAuth + ";</script>");	
	
	// Parameter 로 들어온 FolderID와 MessageID로 조회된 FolderID가 동일하지 않을 때
	// Parameter 로 들어온 FolderID와 MessageID로 조회된 MultiFolderIDs(다차원 분류 폴더 아이디) 에 속하지 않을때
	// 관리자 상관 없이 오류 페이지로 이동
	if(!folderID.equals(msgMap.getString("FolderID")) && msgMap.getString("MultiFolderIDs").indexOf(folderID) == -1){
		out.println("<script language='javascript'>window.location.href = '/covicore/coviException.do?CLSYS=portal&CLMD=user&CLBIZ=Portal&exceptionType=NotFound';</script>");	
		return;
	}
	
	// 관리자 또는 간편관리자, 게시글 작성자가 아닌 경우
	if(!"Y".equals(SessionHelper.getSession("isAdmin")) && !"Y".equals(SessionHelper.getSession("isEasyAdmin")) && !msgMap.getString("CreatorCode").equals(SessionHelper.getSession("USERID"))){
		SimpleDateFormat format = new SimpleDateFormat("yyyy.MM.dd");
		Date expireDate = format.parse(msgMap.getString("ExpiredDate"));
		Date nowDate = format.parse(ComUtils.GetLocalCurrentDate().replace("-", ".").substring(0, 10));
		
		int resultDate = nowDate.compareTo(expireDate);
		
		// 잠금 또는 만료된 게시물 접근	
		if(msgMap.getString("MsgState").equals("P") || resultDate >= 0){
			out.println("<script language='javascript'>window.location.href = '/covicore/coviException.do?CLSYS=portal&CLMD=user&CLBIZ=Portal&exceptionType=NotFound';</script>");	
			return;
		}	
	}
}

StringBuffer sbBtnHtml = new StringBuffer();
if(BoardUtils.getAuthMessageUpdate(bizSection, configMap, aclMap, msgMap, msgACLMap, boardType)){
	sbBtnHtml.append("<a href='#' name='btnUpdate' class='btnTypeDefault right' onclick=\"javascript:goUpdate();\">"+DicHelper.getDic("btn_Edit")+"</a>"); // 수정
}
if(BoardUtils.getAuthMessageDelete(bizSection, configMap, aclMap, msgMap, msgACLMap)){ 
	sbBtnHtml.append("<a href='#' name='btnDelete' class='btnTypeDefault middle' onclick=\"javascript:chkDelete();\">"+DicHelper.getDic("btn_delete")+"</a>"); // 삭제
}
if(BoardUtils.getAuthMessageMove(bizSection, configMap, aclMap, msgMap, msgACLMap, boardType)){ 
	sbBtnHtml.append("<a href='#' name='btnMove' class='btnTypeDefault left' onclick=\"javascript:board.moveFolderPopup('move');\">"+DicHelper.getDic("btn_Move")+"</a>"); // 이동
} 
if(boardType.equals("Approval") && request.getParameter("approvalStatus").equals("R")){ //승인요청(R) 상태
	sbBtnHtml.append("<a href='#' name='btnAccept' class='btnTypeDefault right' onclick=\"board.commentPopup('accept');\">"+DicHelper.getDic("lbl_Approval")+"</a>"); // 승인
	sbBtnHtml.append("<a href='#' name='btnReject' class='btnTypeDefault middle' onclick=\"board.commentPopup('reject');\">"+DicHelper.getDic("btn_Reject")+"</a>"); // 거부
}
%>
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
					<select id="selectCategoryID" name="categoryID" class="selectType02 size102" disabled style="background:#E4E4E4">
						<option value="0"><spring:message code='Cache.lbl_JvCateSel'/></option>
					</select>
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
					<div class="shareListBox">
						<!-- <a href="#" class="btnContentShare  btnTopOptionMenu" onclick="javascript:goShare();">공유</a>	 -->
						<ul class="shareListCont topOptionListCont">
							<li><a href="#" class="btnXClose btnShareListBoxClose btnTopOptionContClose"></a></li>
							<li class="clearFloat shareIconList">
								<a href="#" class="shareBorad">게시판</a>
								<a href="#" class="shareSocial">Social</a>
								<a href="#" class="shareSchedule">일정</a>
								<a href="#" class="shareMail">메일</a>
								<a href="#" class="shareCommunity">커뮤니티</a>
								<a href="#" class="shareTodo">Todo</a>
							</li>						
							<li><input type="text"><a href="#" class="btnTypeDefault">URL복사</a></li>												
						</ul>
					</div>
					<%if ( bizSection.equals("Doc") || 
							(!bizSection.equals("Doc") && !bizSection.equals("Community") && (boardType.equals("Normal") || boardType.equals("Total"))) || 
							(bizSection.equals("Community") && aclMap.getString("Create").equals("C")) ){ %>
					<div class="addFuncBox type02">
						<a href="#" class="btnAddFunc type02">부가기능</a>
						<ul class="addFuncLilst ">
							<%if (!bizSection.equals("Doc") && configMap.getString("UseReport").equals("Y")){ %>
								<li><a href="#" id="ctxReport" name= "Report" class="icon-report board_func" onclick="javascript:board.commentPopup('report');"><spring:message code='Cache.btn_Singo'/></a></li>
							<%} %>
							<%if ((!bizSection.equals("Doc") && configMap.getString("UseReply").equals("Y"))
									&&  (BoardUtils.isManage(bizSection, configMap, msgMap) || aclMap.getString("Security").equals("S") || (msgACLMap != null && msgACLMap.getString("Security").equals("S")))){ %>
								<li><a href="#" id="ctxReply" name= "Reply" class="icon-reply board_func" onclick="javascript:board.goReply(boardObj);"><spring:message code='Cache.btn_Reply'/></a></li>
							<%} %>
							<%if (!bizSection.equals("Doc") && configMap.getString("UseScrap").equals("Y") && msgMap.getString("UseScrap").equals("Y")){ %>
								<li><a href="#" id="ctxScrap" name= "Scrap" class="icon-scrap board_func" onclick="javascript:board.scrapMessage();"><spring:message code='Cache.btn_Scrap'/></a></li>
							<%} %>
							<%if (!bizSection.equals("Doc") && configMap.getString("UsePrint").equals("Y")){ %>
								<li><a href="#" id="ctxPrint" name= "Print" class="icon-output board_func" onclick="javascript:board.printMessage();"><spring:message code='Cache.lbl_Print'/></a></li>
							<%} %>
							<%if ((bizSection.equals("Doc") || (!bizSection.equals("Doc")  && !configMap.getString("FolderType").equals("Anonymous") && configMap.getString("UseReaderView").equals("Y"))) 
									&&  (BoardUtils.isManage(bizSection, configMap, msgMap) || aclMap.getString("Security").equals("S") || (msgACLMap != null && msgACLMap.getString("Security").equals("S")))){ %>
								<li><a href="#" id="ctxReaderView" name= "ReaderView" class="icon-inquiryList doc_func board_func" onclick="javascript:board.viewerPopup();"><spring:message code='Cache.btn_readerList'/></a></li>
							<%} %>
							<%if (!bizSection.equals("Doc") && ComUtils.getAssignedBizSection("Mail")) { %>
 								<li><a href="#" id="ctxMailSend" name= "MailSend" onclick="javascript:board.openMailPopup();" style="padding-left: 10px; background: none;"><span class="ico_applayer n08" style="margin-right: 16px; height: 15px;"></span><spring:message code='Cache.lbl_apv_ctxmenu_04'/></a></li>
							<%} %>
							<%if ((bizSection.equals("Doc") || (!bizSection.equals("Doc") && configMap.getString("UseHistoryView").equals("Y"))) && (aclMap.getString("Security").equals("S") || (msgACLMap != null && msgACLMap.getString("Security").equals("S")))){ %>
								<li><a href="#" id="ctxHistoryView" name= "HistoryView" class="icon-recode doc_func" onclick="javascript:board.checkInHistoryPopup();"><spring:message code='Cache.btn_processingHistory'/></a></li>
							<%} %>
							<%if (!bizSection.equals("Doc") && BoardUtils.isManage(bizSection, configMap, msgMap)){ %>
								<li><a href="#" id="ctxLock" name= "Lock" class="icon-checkout doc_func" onclick="javascript:board.commentPopup('lock');"><spring:message code='Cache.lbl_Lock'/></a></li>
							<%} %>		
												
							<%if (bizSection.equals("Doc")){%>
								<%if ( msgMap.getString("OwnerCode").equals(SessionHelper.getSession("USERID"))){%>
									<li><a href="#" id="ctxDeployDoc" name= "DeployDoc" class="icon-distribute doc_func" onclick="board.distributeDocPopup(folderID,messageID,version)"><spring:message code='Cache.btn_Doc_Distribution'/></a></li>
								<%} %>							
								<%if ( !msgMap.getString("OwnerCode").equals(SessionHelper.getSession("USERID"))){%>
									<li><a href="#" id="ctxRequestAuth" name= "RequestAuth" class="icon-request doc_func" onclick="board.requestAuthPopup(folderID, messageID, version)"><spring:message code='Cache.DocHistory_AuthRequest'/></a></li>
								<%} %>							
								<%if (msgMap.getString("IsCheckOut").equals("N") &&  BoardUtils.isManage(bizSection, configMap, msgMap)){  %>
									<li><a href="#" id="ctxCheckOut" name= "CheckOut" class="icon-checkout doc_func" onclick="javascript:board.commentPopup('checkOut');"><spring:message code='Cache.lbl_CheckOut'/></a></li>
								<%} %>							
								<%if (msgMap.getString("IsCheckOut").equals("Y") && (msgMap.getString("CheckOuterCode").equals(SessionHelper.getSession("USERID")) || BoardUtils.isManage(bizSection, configMap, msgMap))){  %>
									<li><a href="#" id="ctxCancel" name= "Cancel" class="icon-checkout doc_func" onclick="javascript:board.commentPopup('cancel');"><spring:message code='Cache.lbl_UndoCheckOut'/></a></li>
								<%} %>							
								<%if (msgMap.getString("IsCheckOut").equals("Y") && msgMap.getString("CheckOuterCode").equals(SessionHelper.getSession("USERID"))  && BoardUtils.isManage(bizSection, configMap, msgMap)){  %>
									<li><a href="#" id="ctxCheckIn" name= "CheckIn" class="icon-checkout doc_func" onclick="javascript:board.commentPopup('checkIn');"><spring:message code='Cache.btn_CheckIn'/></a></li>
								<%} %>							
							<%} %>
							<%if (bizSection.equals("Board")){%>
								<!-- 체크아웃 취소 (체크아웃자, 관리자) -->
								<%if (msgMap.getString("IsCheckOut").equals("Y") && (msgMap.getString("CheckOuterCode").equals(SessionHelper.getSession("USERID")) || BoardUtils.isManage(bizSection, configMap, msgMap))){  %>
									<li><a href="#" id="ctxCancel" name= "Cancel" class="icon-checkout doc_func" onclick="javascript:board.commentPopup('cancel');"><spring:message code='Cache.lbl_UndoCheckOut'/></a></li>
								<%} %>
								<!-- 체크아웃 (일반사용자) -->
								<%if (configMap.getString("UseCheckOut").equals("Y") && msgMap.getString("IsCheckOut").equals("N") && hasModifyAuth){  %>
									<li><a href="#" id="ctxCheckOut" name= "CheckOut" class="icon-checkout doc_func" onclick="javascript:board.commentPopup('checkOut');"><spring:message code='Cache.lbl_CheckOut'/></a></li>
								<%} %>
							<%} %>								
							<%-- 미구현사항
							<li style="display:none"><a href="#" id="ctxModificationRequest" class="icon-requestRectification  board_func" onclick="javascript:board.commentPopup('requestModify');"><spring:message code='Cache.lbl_ModificationRequest'/></a></li>
							<li style="display:none"><a href="#" id="ctxMigrationToDoc" class="icon-document  board_func" onclick="javascript:board.goMigrate(boardObj);"><spring:message code='Cache.btn_apv_transdoc'/></a></li> 
							--%>
						</ul>
					</div>
					<%} %>
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
				
				<!-- 피드 등록글 영역-->
				<div id="divLinkedFeed" class="boradDisplay type02" style="display: none;">
					<div>
						<div class="tit"></div>
						<div class="borNemoListBox"></div>
					</div>
				</div>
				
				<div class="boardDisplayContent">
					<div id="BodyText" class="boardDetaileVeiw" style="line-height: 20px;"><!-- 본문 영역 -->
<!-- 											<img src="./coviSmart_상세보기_files/img02.png"> -->
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
<!-- 		<div class="cRContEnd"> -->
<!-- 			<div class="cRTopButtons"> -->
<!-- 				<div class="cRTopButtons ">							 -->
<!-- 					<div class="pagingType02 buttonStyleBoxLeft"> -->
<!-- 						<a href="#" class="btnTypeDefault right" onclick="javascript:goUpdate();">수정</a> -->
<!-- 						<a href="#" class="btnTypeDefault middle" onclick="javascript:board.commentPopup('delete');">삭제</a> -->
<!-- 						<a href="#" class="btnTypeDefault left" onclick="javascript:board.moveFolderPopup('move');">이동</a> -->
<!-- 						<a href="#" class="btnTypeDefault">구독</a> -->
<!-- 					</div>									 -->
<!-- 				</div>	 -->
<!-- 				<a href="#" class="btnTop">탑으로 이동</a> -->
<!-- 			</div> -->
<!-- 		</div>						 -->
</div>


<span id="messageDetail"></span>
<div id="con_file"></div>
<!-- 공지 여부 표시 -->
<!-- 제목 -->			<!-- 게시글타입 --> <!-- 게시일자 --> <!-- 조회수 -->
<!-- 작성자이름 --> <!-- 직급 --> <!-- (부서) -->				<!-- 첨부파일(선택시 레이어팝업 혹은 tooltip) --> <!-- 내보내기 -->
<!-- 본문 -->
<!-- 태그 -->												<!-- 분류 --> <!-- 만료일 -->
<!-- 댓글 -->
<!-- 이전글/다음글 -->
<input type="hidden" id="hiddenFolderID" value=""/>
<input type="hidden" id="hiddenMessageID" value=""/>
<input type="hidden" id="hiddenComment" value=""/>
<input type="hidden" id="hiddenCheckOuterCode" value="" />
<input type="hidden" id="messageAuth" name="messageAuth" value="" />
<script type="text/javascript">
var bizSection = (CFN_GetQueryString("communityId") == "undefined" || CFN_GetQueryString("communityId") == "") ? CFN_GetQueryString("CLBIZ") : "Community";
var boardType = CFN_GetQueryString("boardType") == "undefined" ? "Normal" : CFN_GetQueryString("boardType");	//Normal외에 메뉴별 타입
var viewType = CFN_GetQueryString("viewType") == "undefined" ? "List" : CFN_GetQueryString("viewType");		//List, Album, Popup
var version = CFN_GetQueryString("version");
var folderID = CFN_GetQueryString("folderID");
var messageID = CFN_GetQueryString("messageID");
var categoryID = CFN_GetQueryString("categoryID");
var communityID = CFN_GetQueryString("communityId") == "" ? "" : CFN_GetQueryString("communityId");
var menuID = CFN_GetQueryString("menuID") == "undefined" ? "" : CFN_GetQueryString("menuID");

//이전글, 다음글 표시용 parameter
var startDate = CFN_GetQueryString("startDate");
var endDate = CFN_GetQueryString("endDate");
var searchType = CFN_GetQueryString("searchType");
var searchText = CFN_GetQueryString("searchText");
var sortBy = CFN_GetQueryString("sortBy");

// 댓글 삭제 권한
var commentDelAuth = "<%=BoardUtils.isCommentDelAuth(configMap)%>";

//추후 변경 가능성 있음
var boardObj = {
	"bizSection": bizSection,	// Board, Doc, Community
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
}

//CHECK: 꼭 board.js로 이동할 필요는 없는거 같아 !!
function goUpdate(){
	if((bizSection == "Doc" || g_boardConfig.UseCheckOut == "Y") 
			&& g_messageConfig.IsCheckOut == "Y"
			&& g_messageConfig.CheckOuterCode != Common.getSession("USERID")){
		Common.Warning("<spring:message code='Cache.msg_Doc_alreadyCheckOut'/>"); 
		//체크아웃 여부 체크 이후 수정페이지 이동
	} else {
		board.goUpdate(boardObj);
	}
}

initContent();

function initContent(){
	board.getBoardConfig(folderID);	//게시판별 옵션 조회 (board_config)
	
	//게시글 상세보기에 표시할 정보 조회: selectMessageDetail() -> renderMessageInfoView()
	board.selectMessageDetail("View", bizSection, version, messageID, folderID);

	$(".boardAllCont").show();
	//Tag, Link, 확장필드, 본문양식 등 옵션별 표시
	board.renderMessageOptionView(bizSection, version, messageID, folderID);

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

// 	$('.btnAttFile').on('click', function(){
// 		$('.attFileListCont').toggleClass('active');
// 	});

	//댓글 컨트롤 추가
// 	coviComment.load('divComment', 'Board', messageID+"_"+version);
}

function goShare(){
	alert("서비스 준비중입니다.");
}

</script>
