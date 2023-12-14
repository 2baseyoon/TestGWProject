<%@page import="egovframework.baseframework.util.SessionHelper,
				egovframework.covision.groupware.util.BoardUtils,
				egovframework.covision.groupware.auth.BoardAuth,
				egovframework.baseframework.data.CoviMap,
				egovframework.coviframework.util.DicHelper,
				egovframework.coviframework.util.XSSUtils,egovframework.coviframework.util.CoviLoggerHelper,
				java.text.SimpleDateFormat,
				java.util.Date"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil,egovframework.coviframework.util.ComUtils"%>
<%@ page import="egovframework.coviframework.util.RedisDataUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%
String bizSection = request.getParameter("CLBIZ");
String boardType  = request.getParameter("boardType") == null ? "Normal" : request.getParameter("boardType");	//Normal외에 메뉴별 타입
String isUseTransferFeed = RedisDataUtil.getBaseConfig("isUseTransferFeed");
String isUseCollab = RedisDataUtil.getBaseConfig("isUseCollab");

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
	out.println("<script language='javascript'>CoviMenu_GetContent('/groupware/layout/board_BoardAuthError.do?CLSYS=board&CLMD=user&CLBIZ=Board&boardType=Total');</script>");
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
		out.println("<script language='javascript'>CoviMenu_GetContent('/groupware/layout/board_BoardAuthError.do?CLSYS=board&CLMD=user&CLBIZ=Board&boardType=Total');</script>");
		return;
	}
	
	hasModifyAuth = BoardAuth.getModifyAuth(params);
	out.println("<script language='javascript'>var hasModifyAuth = " + hasModifyAuth + ";</script>");	
	
	// Parameter 로 들어온 FolderID와 MessageID로 조회된 FolderID가 동일하지 않을 때
	// Parameter 로 들어온 FolderID와 MessageID로 조회된 MultiFolderIDs(다차원 분류 폴더 아이디) 에 속하지 않을때
	// 관리자 상관 없이 오류 페이지로 이동
	if(!folderID.equals(msgMap.getString("FolderID")) && msgMap.getString("MultiFolderIDs").indexOf(folderID) == -1){
		out.println("<script language='javascript'>CoviMenu_GetContent('/groupware/layout/board_MessageNotFound.do?CLSYS=board&CLMD=user&CLBIZ=Board&boardType=Total');</script>");	
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
			out.println("<script language='javascript'>CoviMenu_GetContent('/groupware/layout/board_MessageNotFound.do?CLSYS=board&CLMD=user&CLBIZ=Board&boardType=Total');</script>");	
			return;
		}	
	}
}

StringBuffer sbBtnHtml = new StringBuffer();
if(BoardUtils.getAuthMessageUpdate(bizSection, configMap, aclMap, msgMap, msgACLMap, boardType)){
	sbBtnHtml.append("<a href='#' name='btnUpdate' class='btnTypeDefault right' onclick=\"javascript:goUpdate();\">"+DicHelper.getDic("btn_Edit")+"</a>"); // 수정
}
if(BoardUtils.getAuthMessageDelete(bizSection, configMap, aclMap, msgMap, msgACLMap)){ 
	sbBtnHtml.append("<a href='#' name='btnDelete' class='btnTypeDefault left' onclick=\"javascript:chkDelete();\">"+DicHelper.getDic("btn_delete")+"</a>"); // 삭제
}
if(BoardUtils.getAuthMessageMove(bizSection, configMap, aclMap, msgMap, msgACLMap, boardType)){ 
	sbBtnHtml.append("<a href='#' name='btnMove' class='btnTypeDefault right' onclick=\"javascript:board.moveFolderPopup('move');\">"+DicHelper.getDic("btn_Move")+"</a>"); // 이동
	sbBtnHtml.append("<a href='#' name='btnCopy' class='btnTypeDefault left' onclick=\"javascript:board.moveFolderPopup('copy');\">"+DicHelper.getDic("btn_Copy")+"</a>"); // 이동
} 
if(boardType.equals("Approval") && request.getParameter("approvalStatus").equals("R")){ //승인요청(R) 상태
	sbBtnHtml.append("<a href='#' name='btnAccept' class='btnTypeDefault right' onclick=\"board.commentPopup('accept');\">"+DicHelper.getDic("lbl_Approval")+"</a>"); // 승인
	sbBtnHtml.append("<a href='#' name='btnReject' class='btnTypeDefault middle' onclick=\"board.commentPopup('reject');\">"+DicHelper.getDic("btn_Reject")+"</a>"); // 거부
}
%>
<!-- 상단 버튼 컨트롤 -->
<div class="cRConTop">
	<!-- 버튼컨트롤 표시 부분 -->
	<div class="cRTopButtons ">
		<div class="pagingType02 buttonStyleBoxLeft">
			<a href="#" name="btnList" class="btnTypeDefault btnTypeLArrr" onclick="javascript:goList();"><spring:message code='Cache.btn_List'/></a> <!-- 목록 -->
			<%=sbBtnHtml.toString()%>
		</div>
		<div class="surveySetting">
			<a href="#" id="btnPopupView" class="surveryWinPop" title="<spring:message code='Cache.lbl_openPopup'/>"><spring:message code='Cache.lbl_popup'/></a>
		</div>
	</div>
</div>
<div class="cRContBottom mScrollVH ">
	<div class="boardAllCont" style="display:none;">
		<div class="boradTopCont">
			<div class=" cRContBtmTitle">
				<div>
					<div id="FolderName" class="boxDivTit"></div>	<!-- 게시판명 -->
					<div class="collabo_help02" style="float:right"> <!-- 게시 정보 toolTip -->
						<a href="javascript:void(0);" class="help_ico" id="boardIcon" style="margin-top:3px;"></a>
						<div class="boardData helppopup"></div>
					</div>
					<div id="ExpiredDate"></div> <!-- 게시만료일 -->
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
						<!-- <a href="#" class="btnContentShare  btnTopOptionMenu" onclick="javascript:goShare();">공유</a> -->
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
							(bizSection.equals("Community") && !boardType.equals("Scrap") && aclMap.getString("Create").equals("C")) ){ %>
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
							<%if (!bizSection.equals("Doc") && ((configMap.getString("UseTransferFeed").equals("Y") && "Y".equals(isUseTransferFeed)) || "A".equals(isUseTransferFeed))) { %>
 								<li><a href="#" id="ctxMailSend" name= "MailSend" onclick="javascript:board.openFeedPopup(bizSection,menuID,folderID,messageID,version);" style="padding-left: 10px; background: none;"><span class="ico_applayer n10" style="margin-right: 16px; height: 15px;"></span><spring:message code='Cache.lbl_TransferFeed'/></a></li>
							<%} %>
							<%if (!bizSection.equals("Doc") && "Y".equals(isUseCollab)) { %>
 								<li><a href="#" id="ctxCollab" name= "Collab" onclick="javascript:board.openProjectAllocPopup();" style="padding-left: 10px; background: none;"><span class="ico_applayer n10" style="margin-right: 16px; height: 15px;"></span><spring:message code='Cache.btn_apv_AddTask'/></a></li>
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
				
				<!-- 경조사 게시판 영역-->
				<div id="divEventBoard" class="boradDisplay type02">
				</div>
				
				<!-- 링크 게시판 영역-->
				<div id="divLinkSiteBoard" class="boradDisplay type02">
				</div>
				
				<!-- 연결글/바인더 영역-->
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
				<ul class="prvNextList">
					<li>
						<div><spring:message code='Cache.lbl_PrevMsg2'/><span class="line">|</span></div>
						<div id="prevMessage"><span><spring:message code='Cache.lbl_noPrevMsg'/></span></div>
					</li>
					<li>
						<div><spring:message code='Cache.lbl_NextMsg2'/><span class="line">|</span></div>
						<div id="nextMessage"><span><spring:message code='Cache.lbl_noNextMsg' /></span></div>
					</li>
				</ul>
			</div>
		</div>
	</div>
	<div class="cRContEnd">
		<a href="#" class="btnTop">탑으로 이동</a>
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
var bizSection = "<%= bizSection%>";
var boardType = "<%= (request.getParameter("boardType") == null) ? "Normal" : request.getParameter("boardType")%>";	//Normal외에 메뉴별 타입
var viewType = "<%= (request.getParameter("viewType") == null) ? "List" : request.getParameter("viewType")%>";		//List, Album
var version = <%=request.getParameter("version")%>;
var folderID = <%=request.getParameter("folderID")%>;
var messageID = <%=request.getParameter("messageID")%>;
var menuID = <%=request.getParameter("menuID")%>;
var communityID = "<%=(request.getParameter("communityId") == null) ? "" : request.getParameter("communityId")%>";
var categoryID = "<%=(request.getParameter("selectCategoryID") == null) ? "" : request.getParameter("selectCategoryID")%>";
multiFolderType = "<%= (request.getParameter("multiFolderType") == null || request.getParameter("multiFolderType").equals("undefined")) ? "ORIGIN" : request.getParameter("multiFolderType")%>";
var grCode = "<%= (request.getParameter("grCode") == null || request.getParameter("grCode").equals("undefined")) ? "" : request.getParameter("grCode")%>";

//이전글, 다음글 표시용 parameter
var startDate = "<%=request.getParameter("startDate")%>";
var endDate = "<%=request.getParameter("endDate")%>";
var searchType = "<%=request.getParameter("searchType")%>";
var searchText = decodeURI(decodeURIComponent("<%=request.getParameter("searchText")%>"));
var sortBy = "<%=request.getParameter("sortBy")%>";
var page = "<%=(request.getParameter("page") == null) ? 1 : request.getParameter("page")%>";
var pageSize = "<%=(request.getParameter("pageSize") == null) ? 10 : request.getParameter("pageSize")%>";
var rNum = "<%=(request.getParameter("rNum") == null) ? 1 : request.getParameter("rNum")%>";
var boxType = "<%=(request.getParameter("boxType") == null) ? "Receive" : request.getParameter("boxType")%>"; //Request, Receive
var approvalStatus = "<%=(request.getParameter("approvalStatus") == null) ? 1 : request.getParameter("approvalStatus")%>";
var ufColumn = "<%=(request.getParameter("ufColumn") == null) ? "" : request.getParameter("ufColumn")%>";
var selectSearch = "<%=(request.getParameter("selectSearch") == null) ? "" : request.getParameter("selectSearch")%>";
var readSearchType = "<%=(request.getParameter("readSearchType") == null) ? "" : request.getParameter("readSearchType")%>";

//댓글 삭제 권한
var commentDelAuth = "<%=BoardUtils.isCommentDelAuth(configMap)%>";

var msgType = "<%=msgMap.getString("MsgType")%>";

var boardObj = {
	"bizSection": bizSection,	// Board, Doc, Community
	"boardType": boardType,
	"version": version,
	"menuID": menuID,
	"folderID": folderID,
	"messageID": messageID,
	"startDate": startDate,
	"endDate": endDate,
	"searchType": searchType,
	"searchText": decodeURIComponent(searchText),
	"sortBy": decodeURIComponent(sortBy),
	"page": page,
	"pageSize": pageSize,
	"rNum": rNum,
	"boxType": boxType,
	"approvalStatus": approvalStatus,
	"categoryID": categoryID,
	"multiFolderType": multiFolderType,
	"ufColumn": ufColumn,
	"useUserForm": (searchType === "UserForm" && ufColumn) ? "Y" : "N",
	"msgType" : msgType,
	"readSearchType" : readSearchType
}

//목록으로 돌아가는거 임시 메소드
function goList(){
	multiFolderType = '';
	board.goList(bizSection, menuID, folderID, boardType, g_boardConfig.FolderType);
}

//태그
function goTagList(searchText){
	
	boardObj.searchType = "Tag";
	boardObj.searchText = searchText;
	
	board.goTagList(boardObj);
}

function goUpdate(){
	var aclObj = board.getMessageAclList(bizSection, version, messageID, folderID).aclObj;
	var folderOwnerCode = ";" + g_messageConfig.FolderOwnerCode;
	// 수정 권한 체크
	if(sessionObj["isAdmin"] != "Y" 
		&& !(folderOwnerCode.indexOf(";" + sessionObj["USERID"] + ";") > -1)
		&& aclObj.Modify != "M"
		&& !((bizSection == "Board" && g_messageConfig.CreatorCode == sessionObj["USERID"])
				|| (bizSection == "Doc" && g_messageConfig.OwnerCode == sessionObj["USERID"])
				|| (bizSection == "Community" && g_messageConfig.CreatorCode == sessionObj["USERID"]))) {
		Common.Warning("<spring:message code='Cache.msg_noModifyACL'/>"); // 수정 권한이 없습니다.
		return false;
	}
	
	if((bizSection == "Doc" || g_boardConfig.UseCheckOut == "Y") 
			&& g_messageConfig.IsCheckOut == "Y"
			&& g_messageConfig.CheckOuterCode != Common.getSession("USERID")){
		var checkOuter = Common.GetObjectInfo('UR', g_messageConfig.CheckOuterCode, '');
		var checkOuterDisplay = CFN_GetDicInfo(checkOuter.MultiDisplayName) + " ("+CFN_GetDicInfo(checkOuter.MultiDeptName) +")";
		Common.Warning("<spring:message code='Cache.msg_Doc_alreadyCheckOut'/> - "+ checkOuterDisplay +"");
		//체크아웃 여부 체크 이후 수정페이지 이동
	} else {
		if((bizSection=="Doc"|| g_boardConfig.UseCheckOut == "Y") && g_messageConfig.IsCheckOut == "N" && g_messageConfig.MsgState !== "D"){
			board.commentPopup('updateCheckOut');
		} else {
			board.goUpdate(boardObj);
		}
	}
}

function chkDelete(){
	var aclObj = board.getMessageAclList(bizSection, version, messageID, folderID).aclObj;
	var folderOwnerCode = ";" + g_messageConfig.FolderOwnerCode;
	if(sessionObj["isAdmin"] != "Y" 
		&& !(folderOwnerCode.indexOf(";" + sessionObj["USERID"] + ";") > -1)
		&& aclObj.Delete != "D"
		&& !((bizSection == "Board" && g_messageConfig.CreatorCode == sessionObj["USERID"])
				|| (bizSection == "Doc" && g_messageConfig.OwnerCode == sessionObj["USERID"])
				|| (bizSection == "Community" && g_messageConfig.CreatorCode == sessionObj["USERID"]))) {
		Common.Warning("<spring:message code='Cache.msg_noDeleteACL'/>"); // 삭제 권한이 없습니다.
		return false;
	}
	
	board.commentPopup('delete');
}

initContent();

function initContent(){
	board.getBoardConfig(folderID);	//게시판별 옵션 조회 (board_config)
	
	//게시글 상세보기에 표시할 정보 조회: selectMessageDetail() -> renderMessageInfoView()
	board.selectMessageDetail("View", bizSection, version, messageID, folderID);

	$(".boardAllCont").show();	//.boardAllCont를 숨겨놨다가 읽기 권한 체크 이후 표시
	//Tag, Link, 확장필드, 본문양식 등 옵션별 표시
	board.renderMessageOptionView(bizSection, version, messageID, folderID);
	
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

	$('#btnPopupView').on('click', function(){
		var url = String.format("/groupware/board/goBoardViewPopup.do?CLBIZ={0}&menuID={1}&version={2}&folderID={3}&messageID={4}&viewType=Popup", bizSection, menuID, version, folderID, messageID);
		CFN_OpenWindow(url, "상세보기 팝업",920, 780,"resize");
	});
	
	if($(".accountTab").length > 0 && $(".accountTab").is(':visible')) {
		// 탭 구조일 경우 버튼 및 이전/다음글 숨김 처리 
		$(".cRConTop").hide();
		$(".cRContEnd").hide();
		$(".prvNextList").hide();
		$(".cRContBottom").css("top", "0px");
	}
	
	if(coviComment){
		coviComment.commentVariables.commentDelAuth = commentDelAuth;
	}
}

function goShare(){
	alert("서비스 준비중입니다.");
}

</script>
