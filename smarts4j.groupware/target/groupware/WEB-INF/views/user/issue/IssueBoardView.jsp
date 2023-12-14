<%@page import="egovframework.baseframework.util.SessionHelper"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<!-- 상단 버튼 컨트롤 -->
<div class="cRConTop">
	<!-- 버튼컨트롤 표시 부분 -->
	<div class="cRTopButtons ">							
		<div class="pagingType02 buttonStyleBoxLeft">
			<a href="#" name="btnList" class="btnTypeDefault btnTypeLArrr" onclick="javascript:goList();"><spring:message code='Cache.btn_List'/></a> <!-- 목록 -->
			<a href="#" name="btnUpdate" style="display:none;" class="btnTypeDefault right" onclick="javascript:goUpdate();"><spring:message code='Cache.btn_Edit'/></a>	<!-- 수정  -->
			<a href="#" name="btnDelete" style="display:none;" class="btnTypeDefault middle" onclick="javascript:chkDelete();"><spring:message code='Cache.btn_delete'/></a>
			<%-- <a href="#" name="btnMove" style="display:none;" class="btnTypeDefault left" onclick="javascript:board.moveFolderPopup('move');"><spring:message code='Cache.btn_Move'/></a> --%>
		</div>
		<div class="surveySetting">
			<!-- <a href="#" id="btnPopupView" class="surveryWinPop" title="게시글 팝업창으로 열기">팝업</a> -->
		</div>					
	</div>						
</div>
<div class="cRContBottom mScrollVH ">
	<div class="boardAllCont" style="display:none;">
		<div class="boradTopCont">
			<div class=" cRContBtmTitle">
				<div>
					<div id="FolderName" class="boxDivTit"></div>	<!-- 게시판명 -->
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
					<div class="addFuncBox type02">
						<a href="#" class="btnAddFunc type02  ">부가기능</a>
						<ul class="addFuncLilst ">
							<li style="display:none"><a href="#" id="ctxReport" name= "Report" class="icon-report board_func" onclick="javascript:board.commentPopup('report');"><spring:message code='Cache.btn_Singo'/></a></li>												
							<li style="display:none"><a href="#" id="ctxReply" name= "Reply" class="icon-reply board_func" onclick="javascript:board.goReply(boardObj);"><spring:message code='Cache.btn_Reply'/></a></li>
							<li style="display:none"><a href="#" id="ctxScrap" name= "Scrap" class="icon-scrap board_func" onclick="javascript:board.scrapMessage();"><spring:message code='Cache.btn_Scrap'/></a></li>
							<li style="display:none"><a href="#" id="ctxPrint" name= "Print" class="icon-output board_func" onclick="javascript:board.printMessage();"><spring:message code='Cache.lbl_Print'/></a></li>
							<li style="display:none"><a href="#" id="ctxReaderView" name= "ReaderView" class="icon-inquiryList doc_func board_func" onclick="javascript:board.viewerPopup();"><spring:message code='Cache.btn_readerList'/></a></li>
							<li style="display:none"><a href="#" id="ctxMailSend" name= "MailSend" onclick="javascript:board.openMailPopup();" style="padding-left: 10px; background: none;"><span class="ico_applayer n08" style="margin-right: 16px; height: 15px;"></span><spring:message code='Cache.lbl_apv_ctxmenu_04'/></a></li>
							<li style="display:none"><a href="#" id="ctxHistoryView" name= "HistoryView" class="icon-recode doc_func" onclick="javascript:board.checkInHistoryPopup();"><spring:message code='Cache.btn_processingHistory'/></a></li>
							<li style="display:none"><a href="#" id="ctxDeployDoc" name= "DeployDoc" class="icon-distribute doc_func" onclick="board.distributeDocPopup(folderID,messageID,version)"><spring:message code='Cache.btn_Doc_Distribution'/></a></li>
							<li style="display:none"><a href="#" id="ctxRequestAuth" name= "RequestAuth" class="icon-request doc_func" onclick="board.requestAuthPopup(folderID, messageID, version)"><spring:message code='Cache.DocHistory_AuthRequest'/></a></li>
							<li style="display:none"><a href="#" id="ctxCheckOut" name= "CheckOut" class="icon-checkout doc_func" onclick="javascript:board.commentPopup('checkOut');"><spring:message code='Cache.lbl_CheckOut'/></a></li>
							<li style="display:none"><a href="#" id="ctxCancel" name= "Cancel" class="icon-checkout doc_func" onclick="javascript:board.commentPopup('cancel');"><spring:message code='Cache.lbl_UndoCheckOut'/></a></li>
							<li style="display:none"><a href="#" id="ctxCheckIn" name= "CheckIn" class="icon-checkout doc_func" onclick="javascript:board.commentPopup('checkIn');"><spring:message code='Cache.btn_CheckIn'/></a></li>
							<%-- 미구현사항
							<li style="display:none"><a href="#" id="ctxModificationRequest" class="icon-requestRectification  board_func" onclick="javascript:board.commentPopup('requestModify');"><spring:message code='Cache.lbl_ModificationRequest'/></a></li>
							<li style="display:none"><a href="#" id="ctxMigrationToDoc" class="icon-document  board_func" onclick="javascript:board.goMigrate(boardObj);"><spring:message code='Cache.btn_apv_transdoc'/></a></li> 
							--%>
						</ul>
					</div>
				</div>			
				
				<!-- 사용자 정의 필드 영역 -->												
				<div id="divUserDefField" class="boradDisplay type02">
					<div>
						<div class="tit">
							<span><spring:message code='Cache.lbl_issue_customerName'/></span>
						</div>
						<div class="txt h_Line">
							<span id="customerName" name="CustomerName"></span>
						</div>
					</div>
					<div>
						<div class="tit">
							<span><spring:message code='Cache.lbl_issue_projectName'/></span>
						</div>
						<div class="txt h_Line">
							<span id="projectName" name="ProjectName"></span>
						</div>
					</div>
					<div>
						<div class="tit">
							<span><spring:message code='Cache.lbl_issue_projectManager'/></span>
						</div>
						<div class="txt h_Line">
							<span id="projectManager" name="ProjectManager"></span>
						</div>
					</div>
					<div>
						<div class="tit">
							<span><spring:message code='Cache.lbl_issue_productType'/></span>
						</div>
						<div class="txt h_Line">
							<span class="radioStyle04 size">
							<!-- <span id="productType" name="ProductType"></span> -->
								<input type="radio" id="productType" name="productType" value="0">
								<label><span><span></span></span>CP</label>
							</span>
							<span class="radioStyle04 size">
							<input type="radio" id="productType" name="productType" value="1">
							<label><span><span></span></span>MP</label>
							</span>
						</div>
					</div>
					<div>
						<div class="tit">
							<span><spring:message code='Cache.lbl_issue_module'/></span>
						</div>
						<div class="txt h_Line">
							<span id="module" name="Module"></span>
						</div>
					</div>
					<div>
						<div class="tit">
							<span><spring:message code='Cache.lbl_issue_issueType'/></span>
						</div>
						<div class="txt h_Line">
							<span id="projectIssueType" name="ProjectIssueType"></span>
						</div>
					</div>
					<div>
						<div class="tit">
							<span><spring:message code='Cache.lbl_issue_issueContext'/></span>
						</div>
						<div class="txt h_Line">
							<pre id="projectIssueContext" name="ProjectIssueContext" style="line-height: 20px;"></pre>
						</div>
					</div>
					<div>
						<div class="tit">
							<span><spring:message code='Cache.lbl_issue_issueSolution'/></span>
						</div>
						<div class="txt h_Line">
							<pre id="projectIssueSolution" name="ProjectIssueSolution" style="line-height: 20px;"></pre>
						</div>
					</div>
					<div>
						<div class="tit">
							<span><spring:message code='Cache.lbl_issue_progress'/></span>
						</div>
						<div class="txt h_Line">
							<pre id="progress" name="Progress" style="line-height: 20px;"></pre>
						</div>
					</div>
					<div>
						<div class="tit">
							<span><spring:message code='Cache.lbl_issue_result'/></span>
						</div>
						<div class="txt h_Line">
							<pre id="result" name="Result" style="line-height: 20px;"></pre>
						</div>
					</div>
					<div>
						<div class="tit">
							<span>완료일자</span>
						</div>
						<div class="txt h_Line">
							<span id="complateDate" name="ComplateDate"></span>
						</div>
					</div>
					<div>
						<div class="tit">
							<span>완료여부</span>
						</div>
						<div class="txt h_Line">
							<select id="complateCheck" name="ComplateCheck" class="selectType02 size102" style="pointer-events: none;">
								<option value=""><spring:message code='Cache.msg_Select'/></option>
								<option value="0">진행중</option>
								<option value="1">완료</option>
							</select>
						</div>
					</div>
					<div>
						<div class="tit">
							<span>비고</span>
						</div>
						<div class="txt h_Line">
							<pre id="etc" name="Etc" style="line-height: 20px;"></pre>
						</div>
					</div>
				</div>
				
				<!-- 경조사 게시판 영역-->												
				<div id="divEventBoard" class="boradDisplay type02">
				</div>
				
				<!-- 연결글/바인더 영역-->
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
		<div class="cRTopButtons">
			<div class="cRTopButtons ">							
				<div class="pagingType02 buttonStyleBoxLeft">
					<a href="#" name="btnList" class="btnTypeDefault btnTypeLArrr" onclick="javascript:goList();"><spring:message code='Cache.btn_List'/></a> <!-- 목록 -->
					<a href="#" name="btnUpdate" style="display:none;" class="btnTypeDefault right" onclick="javascript:goUpdate();"><spring:message code='Cache.btn_Edit'/></a>	<!-- 수정  -->
					<a href="#" name="btnDelete" style="display:none;" class="btnTypeDefault middle" onclick="javascript:chkDelete();"><spring:message code='Cache.btn_delete'/></a>
					<%-- <a href="#" name="btnMove" style="display:none;" class="btnTypeDefault left" onclick="javascript:board.moveFolderPopup('move');"><spring:message code='Cache.btn_Move'/></a> --%>
				</div>									
			</div>	
			<a href="#" class="btnTop">탑으로 이동</a>
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
var bizSection = "<%=request.getParameter("CLBIZ")%>";
var boardType = "<%= (request.getParameter("boardType") == null) ? "Normal" : request.getParameter("boardType")%>";	//Normal외에 메뉴별 타입
var viewType = "<%= (request.getParameter("viewType") == null) ? "List" : request.getParameter("viewType")%>";		//List, Album
var version = <%=request.getParameter("version")%>;
var folderID = <%=request.getParameter("folderID")%>;
var messageID = <%=request.getParameter("messageID")%>;
var menuID = <%=request.getParameter("menuID")%>;
var communityID = "<%=(request.getParameter("communityId") == null) ? "" : request.getParameter("communityId")%>";
var categoryID = <%=request.getParameter("categoryID")%>;

//이전글, 다음글 표시용 parameter
var startDate = "<%=request.getParameter("startDate")%>";
var endDate = "<%=request.getParameter("endDate")%>";
var searchType = "<%=request.getParameter("searchType")%>";
var searchText = decodeURI(decodeURIComponent("<%=request.getParameter("searchText")%>"));
var sortBy = "<%=request.getParameter("sortBy")%>";
var page = "<%=(request.getParameter("page") == null) ? 1 : request.getParameter("page")%>";
var pageSize = "<%=(request.getParameter("pageSize") == null) ? 10 : request.getParameter("pageSize")%>";

var boardObj = {
	"bizSection": bizSection,	//Board, Doc
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
	"pageSize": pageSize
}

//목록으로 돌아가는거 임시 메thㅗ드
function goList(){
	//게시글, 게시판 정보 URL parameter로 추가
	var context_param = String.format("&CLBIZ={0}&menuID={1}&folderID={2}",bizSection, menuID, folderID);
	
	var url = "/groupware/layout/issue_IssueBoardList.do?CLSYS="+ bizSection +"&CLMD=user&boardType=Normal" + context_param;
	
	if(viewType != undefined && viewType != ""){
		url += "&viewType="+viewType;
	}

	if(sortBy != undefined && sortBy != ""){
		url += "&sortBy="+decodeURIComponent(sortBy);
	}
	
	if(page != undefined && page != ""){
		url += "&page="+page;
	}
	
	if(page != undefined && pageSize != ""){
		url += "&pageSize="+pageSize;
	}
	
	if(searchType != undefined && searchType != ""){
		url += "&searchType="+searchType;
	}
	
	if(searchText != undefined && searchText != ""){
		url += "&searchText="+searchText;
	}
	
	if(startDate != undefined && startDate != ""){
		url += "&startDate="+startDate;
	}
	
	if(endDate != undefined && endDate != ""){
		url += "&endDate="+endDate;
	}
	
	if(CFN_GetQueryString("C") != "undefined"){	//Community용 Parameter추가
		url += "&communityId="+CFN_GetQueryString("C") + "&CSMU=C";
	} else if (CFN_GetQueryString("communityId") != "undefined"){
		url += "&communityId="+CFN_GetQueryString("communityId") + "&CSMU=C";
	}

	if(CFN_GetQueryString("activeKey") != "undefined" ){
		url += "&activeKey="+CFN_GetQueryString("activeKey");
	}
	//페이지 URL정보 세션, 전역변수에 저장
	
	sessionStorage.setItem("urlHistory", url);
	g_urlHistory = url;
	
	CoviMenu_GetContent(url);
}


function goUpdate(){

	var pObj = boardObj;
	
	if((bizSection == "Doc" || g_boardConfig.UseCheckOut == "Y") 
			&& g_messageConfig.IsCheckOut == "Y"
			&& g_messageConfig.CheckOuterCode != Common.getSession("USERID")){
		Common.Warning("<spring:message code='Cache.msg_Doc_alreadyCheckOut'/>"); 
		//체크아웃 여부 체크 이후 수정페이지 이동
	} else {
		if(bizSection=="Doc" && g_messageConfig.IsCheckOut == "N"){
			board.commentPopup('updateCheckOut');
		} else {
			var prefix_url = "";
			if(pObj.bizSection != "Doc"){
				prefix_url = "/groupware/layout/issue_IssueBoardWrite.do?CLSYS=board&CLMD=user";
			} else {
				prefix_url = "/groupware/layout/board_DocWrite.do?CLSYS=doc&CLMD=user";
			}
			
			var url = String.format("{0}&CLBIZ={1}&boardType={2}&version={3}&menuID={4}&folderID={5}&messageID={6}&mode=update",
				prefix_url,
				pObj.bizSection, 
				pObj.boardType, 
				pObj.version, 
				pObj.menuID,
				pObj.folderID, 
				pObj.messageID );
			
			if(CFN_GetQueryString("communityId") != "undefined" ){	//Community용 Parameter추가
				url += "&communityId="+CFN_GetQueryString("communityId") + "&CSMU=C";
			}
			
			if(CFN_GetQueryString("activeKey") != "undefined" ){	//Community용 Parameter추가
				url += "&activeKey="+CFN_GetQueryString("activeKey");
			}
			
			CoviMenu_GetContent(url);
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
			|| (bizSection == "Doc" && g_messageConfig.OwnerCode == sessionObj["USERID"]))){
		Common.Warning("<spring:message code='Cache.msg_noDeleteACL'/>"); // 삭제 권한이 없습니다.
		return false;
	}
	
	board.commentPopup('delete');
}

initContent();

function initContent(){
	
	board.getBoardConfig(folderID);	//게시판별 옵션 조회 (board_config)
	
	//게시글 상세보기에 표시할 정보 조회: selectMessageDetail() -> renderMessageInfoView()
	selectMessageDetail("View", bizSection, version, messageID, folderID);

	$(".boardAllCont").show();	//.boardAllCont를 숨겨놨다가 읽기 권한 체크 이후 표시
	//Tag, Link, 확장필드, 본문양식 등 옵션별 표시
	renderMessageOptionView(bizSection, version, messageID, folderID);
	
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
		var url = String.format("/groupware/board/goBoardViewPopup.do?CLBIZ={0}&menuID={1}&version={2}&folderID={3}&messageID={4}&viewType=Popup", 'Board', menuID, version, folderID, messageID);
		CFN_OpenWindow(url, "상세보기 팝업",920, 780,"resize");
	});
	
	//$("#divUserDefField").show();
}

//상세보기 게시글 옵션 항목 표시/숨김
function renderMessageOptionView(pBizSection, pVersion, pMessageID, pFolderID){
	
	//tag정보 조회
	if(g_boardConfig.UseTag == "Y"){
		board.renderTag(pMessageID, pVersion)
	}
	
	//link정보 조회
	if(g_boardConfig.UseLink == "Y"){
		board.renderLink(pMessageID);
	}
	
	//경조사 게시판 상세보기 화면 표시 처리
	if(Common.getBaseConfig("eventBoardID") == pFolderID){
		//개별호출
		Common.getDicList(["lbl_empNm","lbl_kind","lbl_Schedule"]);
		
		var divEventOwner = $('<div />');
		divEventOwner.append( $('<div class="tit"><span class="star">' + coviDic.dicMap["lbl_empNm"] + '<span/></div>'));
		divEventOwner.append( $('<div class="txt h_Line"><span id="EventOwnerName">' + g_messageConfig.EventOwnerName + '</span></div>'));
		
		var divDateAndType = $('<div />');
		var eventDate = $('<div class="disTblStyle"><span id="eventDate">' + g_messageConfig.EventDate +'</span></div>');
		var eventType = $('<div class="tit"> <span>' +  coviDic.dicMap["lbl_kind"] + '</span></div><div class="txt h_Half"> <span id="eventType">' + Common.getDic("lbl_" + g_messageConfig.EventType) + '</span></div></div>');
		divDateAndType.append($('<div class="tit"><span>' + coviDic.dicMap["lbl_Schedule"] + '</span></div>'));
		divDateAndType.append($('<div class="txt h_Half">').append(eventDate).append($('<div class="disTblStyle"/>').append(eventType)));
		
		$("#divEventBoard").append(divEventOwner);
		$("#divEventBoard").append(divDateAndType);
		$("#divEventBoard").show();
	} else {
		$("#divEventBoard").hide();
	}
	
	if(g_boardConfig.UseUserForm == "Y"){
		//게시판 설정 및 게시글의 사용자 정의 폼 사용시 설정값 조회
		$("#divUserDefField").show();
		//board.getUserDefField("View", pFolderID);
		//board.getUserDefFieldValue("View", pVersion, pMessageID);
	} else {
		$("#divUserDefField").hide();
	}
	
	if(g_boardConfig.UseProgressState == "Y"){
		$("#divUserDefField").show();
		board.getProcessState(pFolderID);
	}
	
	if(g_boardConfig.UseLinkedMessage = "Y" || pBizSection == "Doc"){
		$("#divLinkedMessage").show();
		board.getLinkedMessage("View", pBizSection, pMessageID, pVersion);
	} else {
		$("#divLinkedMessage").hide();
	}
}

//게시글 정보 조회: 게시 수정화면 및 상세보기에 사용
function selectMessageDetail(pPageType, pBizSection, pVersion, pMessageID, pFolderID){
	var readFlag = false;	//읽기 권한
	readFlag = board.checkReadAuth(pBizSection, pFolderID, pMessageID, pVersion);
	
 	$.ajax({
 		type:"POST",
 		data: {
 			"bizSection": pBizSection,
 			"version": pVersion,
 			"messageID": pMessageID,	
 			"folderID": pFolderID
 		},
 		url:"/groupware/board/selectIssueMessageDetail.do",
 		async: false,
 		success:function(data){
 			if(data.status == "SUCCESS"){
 				var config = data.list;
	 			g_messageConfig = data.list;
	 			g_messageConfig.fileList = data.fileList;
	 			
	 			
	 			
	 			//작성화면과 상세조회화면에서 표시 처리하기 위한 분기처리
	 			if(pPageType == "View"){
	 				
	 				$("#customerName").text(data.list.CustomerName);
		 			$("#projectName").text(data.list.ProjectName);
		 			$("#projectManager").text(data.list.ProjectManager);
		 			if(data.list.ProductType != ""){
			 			$("[name=productType][value="+data.list.ProductType+"]").prop("checked",true);
		 			}
		 			$("#module").text(data.list.Module);
		 			$("#projectIssueType").text(data.list.ProjectIssueType);
		 			$("#projectIssueContext").text(data.list.ProjectIssueContext);
		 			$("#projectIssueSolution").text(data.list.ProjectIssueSolution);
		 			$("#progress").text(data.list.Progress);
		 			$("#result").text(data.list.Result);
		 			$("#complateDate").text((data.list.ComplateDate).replaceAll("-","."));
		 			$("#complateCheck").val(data.list.ComplateCheck);
		 			$("#etc").text(data.list.Etc);
		 			
		 			
	 				var currentUser = sessionObj["USERID"];
	 				if(g_boardConfig.FolderType == "OneToOne") {
	 					// 1:1게시판의 경우 작성자이거나 게시판 담당자가 아닌경우 조회불가
	 					if(!(g_boardConfig.OwnerCode.indexOf(currentUser) > -1 || data.list.OwnerCode == currentUser)) {
	 						Common.Inform("조회 권한이 없습니다.", "Warning Dialog", function(){
	 							if(g_urlHistory == null){
	 								g_urlHistory = "/groupware/layout/issue_IssueBoardList.do?CLSYS=board&CLMD=user&CLBIZ=Board&boardType=Total&menuID=" + Common.getBaseConfig("BoardMain");
	 							}
	 							CoviMenu_GetContent(g_urlHistory);
	 						});
	 						return;
	 					}
	 				}
					
					//한줄 게시는 읽기권한 체크 안함
					if(g_boardConfig.FolderType == "QuickComment"){
						readFlag = true;
					}
					
					//열람 권한 확인
					/* if(g_messageConfig.UseMessageReadAuth == "Y"){
						//열람권한 테이블에서 조회된 데이터가 없을경우
						if(board.getMessageReadAuthCount(bizSection, messageID, folderID) > 0){
							readFlag = true;
						}
					} */

					if(!readFlag){
						Common.Inform("조회 권한이 없습니다.", "Warning Dialog", function(){
							if(CFN_GetQueryString("CFN_OpenLayerName") != 'undefined'){ //팝업일 경우 
								parent.Common.close(CFN_GetQueryString("CFN_OpenLayerName"));
							}else if(CFN_GetQueryString("CFN_OpenWindowName") != 'undefined'){ //윈도우 팝업일 경우 
								window.close();
							}else{
								if(g_urlHistory == null){
		 							g_urlHistory = "/groupware/layout/board_BoardList.do?CLSYS=board&CLMD=user&CLBIZ=Board&boardType=Total&menuID=" + Common.getBaseConfig("BoardMain");
		 						}
		 						CoviMenu_GetContent(g_urlHistory);
							}
 						});
						return;
					} else {
						board.renderMessageInfoView(pBizSection, config);
						
					}
					
					//게시글 권한별 및 버튼 컨트롤 표시/숨김
					board.checkAclList();	
					
					
	 			} else if(pPageType == "Write"){
	 				board.renderMessageInfoWrite(pBizSection, config);
	 			}
 			} else {
 				alert("정상적인 접근이 아닙니다.");
				CoviMenu_GetContent(g_urlHistory);
				return;
 			}
 		},
 		error:function(response, status, error){
 		     CFN_ErrorAjax("/groupware/board/selectIssueMessageDetail.do", response, status, error);
 		}
 	});
}


function goShare(){
	alert("서비스 준비중입니다.");
}

</script>
