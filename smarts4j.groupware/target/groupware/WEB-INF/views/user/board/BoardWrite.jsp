<%@page import="egovframework.baseframework.util.SessionHelper,egovframework.covision.groupware.util.BoardUtils,egovframework.covision.groupware.auth.BoardAuth,egovframework.baseframework.data.CoviMap,egovframework.coviframework.util.DicHelper,egovframework.coviframework.util.XSSUtils"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%
	String isPopup = request.getParameter("isPopup");
	pageContext.setAttribute("isPopup", isPopup);
%>

<c:if test="${isPopup eq 'Y'}">
	<head>
		<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
	</head>
</c:if>

<style>
.h_Line, .h_Half {
	height: 30px !important;
}

.h_2Line {
	height: 40px !important;
}

.h_3Line {
	height: 60px !important;
}

.h_4Line {
	height: 80px !important;
}

.h_5Line {
	height: 100px !important;
}

.helppopup {
	position: absolute;
	top: 32px;
	left: 0;
	min-width: 100px;
	min-height: 52px;
	background: #d9d9d9;
	/* border: 1px solid #c8c8c8; */
	border-radius: 10px;
	color: #fff;
	padding: 15px;
	font-size: 13px;
	font-weight: 400;
	line-height: 22px;
	font-size: 13px;
	z-index: 99;
	display: none;
}

.help_ico:after {
	content: "";
	position: absolute;
	bottom: 0;
	left: 50%;
	margin: 0 0 -8px 0;
	border-width: 5px;
	border-style: solid;
	border-color: transparent transparent #d9d9d9 transparent;
	transform: translate(-50%, 0);
	display: none;
}

.help_ico.active:after {
	display: inline-block;
}

.option_setChk {
	position: relative;
	padding: 20px 15px;
	margin: 0;
	margin-bottom: 20px;
	background: #f9f9f9;
	border: 0;
}

.approval_h {
	overflow: auto;
	overflow-y: hidden;
}

.approval_h ol {
	display: table;
	margin: 0;
	padding: 0;
}

.approval_h li {
	display: table-cell;
	white-space: nowrap;
	box-sizing: border-box;
	text-align: center;
	position: relative;
}

.approval_h li.person {
	width: 100px;
	height: 110px;
	padding: 7px 8px;
	border: 1px solid #c8c8c8;
	background: #fff;
	border-radius: 5px;
}

.approval_h li.arr span {
	display: inline-block;
	width: 15px;
	height: 100px;
	background: url('/HtmlSite/smarts4j_n/mobile/resources/images/ico_appr02.png') no-repeat 50% 50%;
	background-size: 8px;
	vertical-align: top;
}

.approval_h .image {
	display: inline-block;
	position: relative;
	margin-top: 10px;
}

.approval_h .appphoto {
	display: inline-block;
	width: 40px;
	height: 40px;
	background-size: 40px;
	border: 1px solid #dbdbdb;
	border-radius: 20px;
	overflow: hidden;
}

.approval_h .appname {
	margin-top: 3px;
	font-size: 12px;
	position: relative;
	display: block;
	color: black;
	min-width: 82px;
}

.emptyspace {
	width: 200px;
}

#divApprovalInfo {
	width: 155px;
}

#divTopNotice {
	margin-bottom : 10px;
}
</style>
<div class="cRConTop">
	<div class="cRTopButtons">
		<a href="#" name="btnCreate" class="btnTypeDefault btnTypeChk" onclick="javascript:setMessage('C');"><spring:message code='Cache.btn_register'/></a>	<!-- 등록 -->
		<a href="#" name="btnTempCreate" style="display:none;" class="btnTypeDefault btnTypeChk" onclick="javascript:setTempMessage();"><spring:message code='Cache.btn_register'/></a>	<!-- 등록 -->
		<a href="#" name="btnUpdate" class="btnTypeDefault btnTypeChk" onclick="javascript:setMessage();"><spring:message code='Cache.btn_Confirm'/></a>	<!-- 확인 -->
		<a href="#" name="btnRevision" class="btnTypeDefault" onclick="javascript:setMessageRevision();"><spring:message code='Cache.btn_Revision'/></a>	<!-- 개정 -->
		<a href="#" name="btnTemp" class="btnTypeDefault" onclick="javascript:setMessage('T');"><spring:message code='Cache.btn_tempsave'/></a>				<!-- 임시저장 -->
		<a href="#" name="btnCancel" class="btnTypeDefault" onclick="javascript:cancelMessage();"><spring:message code='Cache.btn_Cancel'/></a>				<!-- 취소 -->
		<a href="#" name="btnNoticePreView" class="btnTypeDefault" onclick="javascript:board.goPreView();"><spring:message code='Cache.btn_preview'/></a>	<!-- 미리보기 -->
	</div>
	<div class="surveySetting">
		<a href="#" class="surveryContSetting btnMakeCont active">설정</a>
		<!-- <a href="#" class="surveryWinPop">팝업</a> -->
	</div>
</div>
<form id="formData" method="post" enctype="multipart/form-data">
	<div class="cRContBottom mScrollVH ">
		<div class="boardAllCont">
			<div class="boradTopCont allMakeSettingView active">
				<div class="allMakeView">
					<div class="inpStyle01 allMakeTitle">
						<input type="text" id="Subject" name="subject" class="inpStyle01 ScriptCheckXSS" maxlength="128" placeholder="<spring:message code='Cache.msg_EnterSubject'/>">
					</div>
				</div>
				<!-- 우측의 버튼에 따라 만료일 설정 및 상단 공지 설정하는 datepicker 표시/숨김처리 버튼 배치-->
				<div id="divBoardSchedule" >
					<div class="inStyleSetting">
						<ul>
							<!-- 상단공지 ON/OFF 버튼처리 -->
<!-- 							<li> -->
<!-- 								<a href="#" class="btnNoti" onclick="javascript:toggleTopNotice(this);">TOP</a> -->
<%-- 									<a class="btnNoti" title="<spring:message code='Cache.lbl_apv_notice'/>"></a> --%>
<!-- 							</li> -->
							<!-- 강조기능 숨김 -->
							<!-- <li>
								<a href="#" class="btnBold">B</a>
							</li> -->
							
							<li>
								<a href="#" class="btnInqPer" title="<spring:message code='Cache.lbl_AdditionOption'/>"></a>
							</li>
						</ul>
						<div class="inPerView">
							<div>
								<div id="divExpiredDate" class="selectCalView oneDate">
									<span><spring:message code='Cache.lbl_ExpireDate'/></span>
									<div class="dateSel type02">
										<input class="adDate" type="text" id="ExpiredDate" date_separator="." kind="date" type="text" data-axbind="date" >
									</div>
								</div>
								<div class="ml25">
									<div id="divTopNotice" class="chkStyle01" >
										<span>
											<input type="checkbox" id="chkIsTop" >
											<label for="chkIsTop"><span></span><spring:message code='Cache.lbl_chkTop'/></label>
										</span>
										<select id="selectTopNotice" class="selectType01"></select>
										<div class="dateSel type02">
											<input class="adDate" type="text" id="TopStartDate" date_separator="."> - <input class="adDate" type="text" date_separator="." kind="twindate" date_startTargetID="TopStartDate" id="TopEndDate">
										</div>
									</div>
									<div id="divPopupNotice" class="chkStyle01">									
										<span>
											<input type="checkbox" id="chkIsPopup" >
											<label for="chkIsPopup"><span></span><spring:message code='Cache.lbl_NoticePopup'/></label>
										</span>
										<select id="selectPopupNotice" class="selectType01"></select>
										<div class="dateSel type02">
											<input class="adDate" type="text" id="PopupStartDate" date_separator="."> - <input class="adDate" type="text" date_separator="." kind="twindate" date_startTargetID="PopupStartDate" id="PopupEndDate">
										</div>
									</div>
								</div>
								<div id="divReservation" class="selectCalView oneTime ml25">
									<span><spring:message code='Cache.lbl_RegBooking'/></span>
									<select id="selectReservation" class="selectType01">
									</select>
									<div class="dateSel type02">
										<input class="adDate" type="text" id="ReservationDate" date_separator="." kind="date" type="text" data-axbind="date"> 
										- <select id="reservationTime" class="selectType04"></select>
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>
				<div class="inputBoxContent">
					<div class="inputBoxSytel01 type02">
						<div><span><spring:message code='Cache.lbl_Board_folderName'/></span></div>
						<!-- 게시판선택 -->
						<select id="selectFolderID" name="folderID" class="selectType02 size102" onchange="board.bindOptionControl($(this).val(), 'Y'); coviInput.init();"> </select>
						
						<!-- 카테고리 -->
						<select id="selectCategoryID" name="categoryID" class="selectType02 size102" >
							<option value="0"><spring:message code='Cache.lbl_JvCateSel'/></option>
						</select>
						
						<!-- 승인 게시판일 경우 승인프로세스 표시 -->
						<div id="divApprovalDiv" class="emptyspace"></div>
						<div id="divApprovalInfo" class="inputBoxSytel01 subDepth type02">
							<div><span><spring:message code='Cache.lbl_ApprovalProcess'/></span>
								<div class="collabo_help02">
									<a href="#" class="help_ico" id="btn_add_tt"></a>
									<div class="helppopup">
										<div class="help_p">
											<span id="spnApprovalLine" class="approval_h"></span>
										</div>
									</div>
								</div>
							</div>
						</div>
						
						<!-- 익명, 부서명 게시 체크박스 -->
						<div class="inputBoxSytel01 subDepth type02">
							<div><span><spring:message code='Cache.lbl_Register'/></span></div>
							<div>
								<input type="text" id="CreatorName" class="HtmlCheckXSS ScriptCheckXSS" name="creatorName" style="width: 100px;" class="inpReadOnly" disabled/>
								<div class="chkStyle01">
									<input type="checkbox" id="chkUseAnonym" name="useAnonym"><label for="chkUseAnonym"><span></span><spring:message code='Cache.lbl_Anonymity'/></label>
								</div>
								<div class="chkStyle01">
									<input type="checkbox" id="chkUsePubDeptName" name="usePubDeptName"><label for="chkUsePubDeptName"><span></span><spring:message code='Cache.lbl_DeptName'/></label>
								</div>
							</div>
						</div>
					</div>
					<!-- 사용자 정의 필드: name으로 표시/숨김 처리-->
					<div id="divUserDefFieldHeader" class="inputBoxSytel01 type01" >
						<div>
							<span><spring:message code='Cache.btn_ExtendedField'/></span><a href="#" class="btnMoreStyle01 btnSurMove active" data-index="0">필드추가 더보기</a>
						</div>
						<div></div>
					</div>
					<!-- 사용자 정의 필드 입력 항목 -->
					<div id="divUserDefField" class="makeMoreInput active" > </div>
					<div id="divEventBoard">	<!-- 경조사 게시판: 임직원 소식 웹파트에 표시되는 게시판 -->
						<div class="inputBoxSytel01 type02">
							<div>
								<span class="star">일자</span>
							</div>
							<div class="h_Half">
								<input id="EventDate" ischeck="Y" date_separator="." kind="date" type="text" data-axbind="date" id="AXInput-3">
							</div>
							<div class="inputBoxSytel01 subDepth type02">
								<div>
									<span class="star">종류</span>
								</div>
								<!-- 경조사 선택 -->
								<div class="h_Half" id="EventType"></div>
							</div>
						</div>
						<div class="inputBoxSytel01 type02">
							<div><span class="star"><spring:message code="Cache.lbl_empNm"/></span></div>	<!-- 사원명 -->
							<div>
								<div class="autoCompleteCustom">
									<input id="EventOwner" type="text" class="ui-autocomplete-input" style="width:calc(100% - 60px)" autocomplete="off">
									<a class="btnTypeDefault" onclick="javascript:OrgMapLayerPopup_eventOwner();return false;"><spring:message code='Cache.lbl_DeptOrgMap'/></a>	<!-- 조직도 -->
								</div>
							</div>
						</div>
					</div>
					<div id="divLinkSiteBoard" class="inputBoxSytel01 type02">
						<div><span><spring:message code='Cache.lbl_URL'/></span></div>
						<!-- LinkURL -->
						<input type="text" id="LinkURL" name="LinkURL" value="http://"  style="width:calc(100% - 60px)" >
						
					</div>
					<!-- 본문양식 -->
					<div id="divBodyForm" class="inputBoxSytel01 type02" >
						<div><span><spring:message code='Cache.lbl_BodyForm'/></span></div>
						<div>
							<select id="selectBodyFormID" class="selectType02 size233" onchange="board.selectBodyFormData($(this).val(), 'Y');"> </select>
						</div>
					</div>
				</div>
			</div>
			
			<div class="boradBottomCont">
				<!-- 에디터 항목 -->
				<div id="divWebEditor" class="writeEdit">
				</div>
			
			<!-- 파일 첨부 항목 -->
			<div class="inputBoxContent">
				<!-- 첨부 부분이 들어 올 곳 -->
				<div id="fileDiv" class="inputBoxSytel01 type02" style="display:none;">
					<div><span><spring:message code='Cache.lbl_apv_attachfile'/></span></div>	<!-- 파일 첨부 -->
<!-- 					<div><span class="sNoti">* 업로드 제한 용량 : <span id="limitFileSize">20</span>MB</span></div> -->
					<div id="con_file"></div>
				</div>
				<div class="subUnputBoxStyle">
					<!-- 설정정보 옵션 체크박스 표시  -->
					<div id="divConfigGroup" class="inputBoxSytel01 type02">
						<div><span><spring:message code='Cache.lbl_Board_optionInfo'/></span></div>	<!-- 설정 정보 -->
						<div>
							<span id="spanScrap" class="chkStyle01">
								<input type="checkbox" id="chkUseScrap" name="useScrap"><label for="chkUseScrap"><span></span><spring:message code='Cache.lbl_AllowScrap'/></label>	<!-- 스크랩 허용 -->
							</span>
							<!-- 게시판 옵션으로 답글/댓글 알림이 켜져있을 경우 게시글의 옵션도 자동적으로 사용처리 되도록 숨김 -->
							<div style="display:none;">
							<%-- 
								<span id="spanReplyNotice" class="chkStyle01">
									<input type="checkbox" id="chkUseReplyNotice" name="useReplyNotice" checked="checked"><label for="chkUseReplyNotice"><span></span><spring:message code='Cache.lbl_chkReply'/></label>	<!-- 답글알림 -->
								</span>
								<span id="spanUseCommNotice" class="chkStyle01">
									<input type="checkbox" id="chkUseCommNotice" name="useCommNotice"  checked="checked"><label for="chkUseCommNotice"><span></span><spring:message code='Cache.lbl_chkComment'/></label>	<!-- 댓글알림 -->
								</span>
							--%>
							
							<input type="checkbox" id="chkUseReplyNotice" name="useReplyNotice">
							<input type="checkbox" id="chkUseCommNotice" name="useCommNotice">
							
							</div>
							<span id="spanSecurity" class="chkStyle01">
								<input type="checkbox" id="chkUseSecurity" name="useSecurity"><label for="chkUseSecurity"><span></span><spring:message code='Cache.lbl_chkSecurity'/></label>	<!-- 비밀글 -->
							</span>
						</div>
					</div>
					
					<div class="inputBoxSytel01 type02">
						<div><span><spring:message code='Cache.lbl_SecurityGrade'/></span></div>	<!-- 보안등급 -->
						<div>
							<select id="selectSecurityLevel" name="securityLevel"/></select>
							<a href="javascript:goReadAuthPopup();" id="btnUseMessageReadAuth" class="btnTypeDefault ml5"><spring:message code='Cache.lbl_MessageReadAuth'/></a>	<!-- 열람 권한 -->
							<a href="javascript:goMessageAuthPopup();" id="btnUseMessageAuth" class="btnTypeDefault ml5"><spring:message code='Cache.lbl_MessageDetailAuth'/></a>	<!-- 상세 권한 -->
						</div>
					</div>
					
					<div id="divLinkedMessage" class="inputBoxSytel01 type02">
						<div><span><spring:message code='Cache.lbl_LinkedMessage' /></span><a href="#" class="btnMoreStyle01 btnSurMove">연결글 더보기</a></div>
						<div>
							<a href="#" class="btnTypeDefault" onclick="javascript:board.searchMessagePopup('Link', 'Board')" ><spring:message code='Cache.btn_Add'/></a>	<!-- 추가 -->
							<a href="#" class="btnTypeDefault ml5" onclick="javacript:board.deleteLinkedMessageAll();"><spring:message code='Cache.btn_DelAll'/></a>		<!-- 전체삭제 -->
						</div>
					</div>
					<div class="makeMoreInput">
						<input type="hidden" id="hiddenLinkedMessage" name="linkedMessage" value=""/>
						<div class="inputBoxSytel01 type02">
							<div></div>
							<div>
								<div id="divLinkedList" class="autoComText clearFloat">
								</div>
							</div>
						</div>
					</div>
					
					<!-- 태그 설정 영역  -->
					<div id="divTagHeader" class="inputBoxSytel01 type02">
						<div>
							<span><spring:message code='Cache.lbl_Tag'/></span>	<!-- 태그 -->
							<span id="tagCount" class="pCount">(0<spring:message code='Cache.lbl_Count'/>)</span> <!-- 개 -->
							<a href="#" class="btnMoreStyle01 btnSurMove">태그 더보기</a></div>
						<div>
							<input type="text" id="tag" class="midInput HtmlCheckXSS ScriptCheckXSS">
							<a href="#" class="btnTypeDefault" onclick="javascript:board.addTag();"><spring:message code='Cache.btn_Add'/></a>	<!-- 추가 -->
							<span class="sNoti">* <spring:message code='Cache.lbl_Board_AllowTagCount'/></span>		<!-- 최대 10개 등록 가능 -->
						</div>
					</div>
					<div class="makeMoreInput">
						<div class="inputBoxSytel01 type02">
							<div></div>
							<div>
								<div id="divTagList" class="autoComText clearFloat">
								</div>
							</div>
						</div>
					</div>
					
					<!-- 링크 설정 영역 -->
					<div id="divLinkHeader" class="inputBoxSytel01 type02">
						<div>
							<span><spring:message code='Cache.lbl_Link'/></span>	<!-- 링크 -->
							<span id="linkCount" class="pCount">(0<spring:message code='Cache.lbl_Count'/>)</span>	<!-- 개 -->
						<a href="#" class="btnMoreStyle01 btnSurMove">링크 더보기</a></div>
						<div>
							<input type="text" id="title" class="midInput HtmlCheckXSS ScriptCheckXSS" placeholder="<spring:message code='Cache.lbl_LinkNm'/>">
							<input type="text" id="link" class="midInput HtmlCheckXSS ScriptCheckXSS" placeholder="URL (ex.https://<spring:message code='Cache.lbl_Domain'/>/)">
							<a href="#" class="btnTypeDefault " onclick="javascript:board.addLink();"><spring:message code='Cache.btn_Add'/></a>	<!-- 추가 -->
							<span class="sNoti">* 
								<spring:message code='Cache.lbl_Mail_Maximum'/> <!-- 최대 -->
								<label id="limitLinkCount">0
								</label><spring:message code='Cache.lbl_Board_AllowCount'/> 		<!-- 개 등록 가능 -->
							</span>
						</div>
					</div>
					<div class="makeMoreInput">
						<div class="inputBoxSytel01 type02">
							<div></div>
							<div>
								<div id="divLinkList" class="autoComText clearFloat">
								</div>
							</div>
						</div>
					</div>
					<!-- 알림여부의 경우 개인 설정/통합메시지 설정 메뉴에서 설정한 알림 정보를 따라가도록  처리됨 -->
					<div id="divNoticeMedia" class="inputBoxSytel01 type02" style="display:none;">
						<div>
							<div id="NotificationMedia" class="alarm type01">
								<span><spring:message code='Cache.lbl_Alram'/></span>	<!-- 알림 -->
								<a href="#" class="onOffBtn"><span></span></a>
							</div>
						</div>
						<div id="divMediaList" class="alarmCont">
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
	<div class="cRContEnd">
		<a href="#" class="btnTop">탑으로 이동</a>
	</div>
</div>
	
	<input type="hidden" id="FolderType" name="folderType" value="" />
	<input type="hidden" id="UseMessageReadAuth" name="useMessageReadAuth" value="" />	<!-- 열람권한 사용여부 -->
	<input type="hidden" id="messageReadAuth" name="messageReadAuth" value="" />		<!-- 열람권한 설정정보 -->
	<input type="hidden" id="UseMessageAuth" name="useMessageAuth" value="" />			<!-- 상세권한 사용 여부 -->
	<input type="hidden" id="messageAuth" name="messageAuth" value="" />				<!-- 상세권한 설정정보 -->
	<input type="hidden" id="IsInherited" name="isInherited" value="N" />				<!-- 폴더 권한 상속 여부 -->
	<input type="hidden" id="GroupName" value="" />	<!-- 현재 접속자의 부서 -->
	<input type="hidden" id="UserName" value="" />	<!-- 현재 접속자의 이름 -->
	<input type="hidden" id="OwnerCode" value="" />
	
	<input type="hidden" name="imageCnt" value="0" />			<!-- imageCnt를 별도로 관리할 필요가 있는지 확인 필요 -->
	
	<input type="hidden" id="Version" name="version" value="0" />
	<input type="hidden" id="Seq" name="seq" value="0" />		<!-- 답글일경우 원본글의 MessageID를 설정 -->
	<input type="hidden" id="Step" name="step" value="0" />		<!-- 답글 표시 순서 -->
	<input type="hidden" id="Depth" name="depth" value="0" />	<!-- 답글 표시 깊이, 답글의 답글, 등을 표시 할때  -->
	<!--<input type="hidden" id="IsPopup" name="isPopup" value="N" />-->	<!-- 팝업공지 사용여부, 현재는 N -->
	<!-- <input type="hidden" id="IsTop" name="isTop" value="N" /> -->		<!-- 상단공지 사용 여부 -->
	<input type="hidden" id="IsApproval" name="isApproval" value="N" /> <!-- 승인프로세스 사용여부 -->
	<input type="hidden" id="IsReplyApproval" name="isReplyApproval" value="N" /> <!-- 승인프로세스 사용여부 -->
	<input type="hidden" id="IsUserForm" name="isUserForm" value="N" />	<!-- 사용자 정의 필드 사용 여부 -->
	<input type="hidden" id="UseRSS" name="useRSS" value="N" />
	<input type="hidden" id="hiddenComment" value=" "/> <!-- 간편 게시 작성의 상세 등록시 취소 버튼을 눌렀을 때 처리 사유 필드 -->
	
	<input type="hidden" id="UseCategory" name="useCategory" value=""/> <!-- 카테고리 사용 여부 -->
</form>

<script type="text/javascript">
var mode = CFN_GetQueryString("mode");			//'create', 'reply', 'update', 'revision', 'migrate'+
var bizSection = CFN_GetQueryString("CLBIZ");	//CHECK: 팝업 혹은 문서이관시 문서 타입 변경용으로 요청시 parameter로 설정된 bizSection을 사용한다.
var version = CFN_GetQueryString("version");
var communityID = CFN_GetQueryString("communityId") == 'undefined'? "" : CFN_GetQueryString("communityId");
var folderID = CFN_GetQueryString("folderID") == 'undefined'? "" : CFN_GetQueryString("folderID");	//게시판 선택후 작성버튼을 눌렀을 경우의 folderID
var menuID = communityID!=""?communityID:CFN_GetQueryString("menuID");
var messageID = CFN_GetQueryString("messageID");
var writeMode = CFN_GetQueryString("writeMode");	//간편게시 작성에서 상세등록을 눌렀을 시 simpleMake 값이 넘어옴
var isPopup = CFN_GetQueryString("isPopup") == 'undefined'? "N" : CFN_GetQueryString("isPopup");

var g_aclList = "";		//권한 설정 ACL List, 추후 팝업호출시 해당 폴더의 권한 정보 조회

//임직원 소식 게시판 전용 AutoComplete 공통 컨트롤 사용
function setOwnerInput(){
	// 사용자 값 조회
	coviCtrl.setCustomAjaxAutoTags(
		'EventOwner', //타겟
		'/covicore/control/getAllUserAutoTagList.do', //url 
		{
			labelKey : 'UserName',
			valueKey : 'UserCode',
			minLength : 2,
			useEnter : false,
			multiselect : true,
// 			select : function(event, ui) {
// 				var orgMapDivEl = $("<div/>", {'class' : 'ui-autocomplete-multiselect-item', attr : {label : '', value : ''}})
// 				.append($("<span/>", {'class' : 'ui-icon ui-icon-close'}));
// 	    		var id = $(document.activeElement).attr('id');
// 	    		var item = ui.item;
// 	    		var cloned = orgMapDivEl.clone();
// 				cloned.attr({'label': item.label,'value': item.value});
// 				cloned.text(item.label);
				
// 				$('#' + id).before(cloned).attr("data-value", item.value);
// 		    	ui.item.value = ''; // 선택 후 input에 value값이 들어가는 문제가 있어 빈값 처리
// 	    	}
		}
	);

	$("#EventOwner").on("keypress keydown keyup focusout", function(e){
		if($("#EventOwner").parent().children('.ui-autocomplete-multiselect-item').length > 0){
			$("#EventOwner").val("");
			return false;
		}
	});
	
	var initInfos = [
   		{
	   		target : 'EventType',				
	   		codeGroup : 'eventType',					
	   		hasGroupCode : "N",							
	   		defaultVal : 'eventDefault',					
	   		width : '102'								
   		}
   	];
	coviCtrl.renderAjaxSelect(initInfos, "", Common.getSession("lang"));
	
};

function OrgMapLayerPopup_eventOwner(){
		Common.open("","orgmap_pop","<spring:message code='Cache.lbl_DeptOrgMap'/>","/covicore/control/goOrgChart.do?callBackFunc=eventOwner_CallBack&type=B9","1000px","580px","iframe",true,null,null,true);
}

//소유자 지정
function eventOwner_CallBack(orgData){
	var userJSON =  $.parseJSON(orgData);
	var sCode, sDisplayName, sDNCode, sMail;
	
	$(userJSON.item).each(function (i, item) {
  		var sObjectType = item.itemType;
  		if(sObjectType.toUpperCase() == "USER"){ //사용자
  			sCode = item.AN;			//UR_Code
  			sDisplayName = CFN_GetDicInfo(item.DN);
  			sDNCode = item.ETID; //DN_Code
  			sMail = item.EM; // E-mail
  		}
  		
		bCheck = false;	
		$('#EventOwner .ui-autocomplete-multiselect-item').each( function(i, item){ 
			  if ($(this).attr("data-value") == sCode) {
                 bCheck = true;
             }
		});

		if (!bCheck && $("#EventOwner").parent().children('.ui-autocomplete-multiselect-item').length == 0) {
			var orgMapItem = $('<div class="ui-autocomplete-multiselect-item" />')
			.attr({'data-value': sCode})
			.text(sDisplayName)
			.append($("<span></span>")
            .addClass("ui-icon ui-icon-close")
            .click(function(){
                        var item = $(this).parent();
                        // delete self.selectedItems[item.text()]; 자동완성을 이용하여 추가한게 아니므로 삭제 하지 않아도 됨.
                        item.remove();
                    }));
			$('#EventOwner').before(orgMapItem);
		}
 	});
}

function cancelMessage(){
	if(writeMode == "simpleMake"){
		board.deleteMessage(writeMode); // 간편 게시작성 상세등록 취소 시에는 해당 임시 저장 게시물 삭제
		location.href = sessionStorage.getItem("urlHistory");
	}else if(isPopup == "Y"){ // 게시 작성 팝업에서 취소할 경우 이전 페이지로 이동됨
		location.href = sessionStorage.getItem("urlHistory");
	}else{
		//뒤로가기 사용시 대메뉴를 통해 접근한 페이지의 이전 페이지로 이동됨
		board.goFolderContents(g_urlHistory);	//마지막 페이지로 이동하도록
	}
}

//게시 작성, 임시저장, 수정 
function setMessage( pMessageState ){	//C: 등록 (Default), T: 임시저장, 그외의 코드값은 해당페이지에서 관리 하지 않음
	Common.Progress();
	if(board.checkMessageValidation()){
		//Multipart 업로드를 위한 formdata객체 사용 
		var formData = new FormData();
		formData.append("mode", mode);
		formData.append("folderID", $("#selectFolderID").val());
		formData.append("menuID", menuID);
		formData.append("bizSection", bizSection);
		formData.append("boardType", CFN_GetQueryString("boardType"))
		
		//커뮤니티 
		if(communityID != "" ){	//Community용 Parameter추가
			formData.append("communityId", communityID);
			formData.append("CSMU", CFN_GetQueryString("CSMU"));
		}else{
			formData.append("CSMU", "X");
		}
		
		if(typeof(menuCode) != "undefined" && menuCode && menuCode != '') {
			formData.append("menuCode", menuCode);
		}
		
		var menuName = "";
		if(window.hasOwnProperty('headerdata')) {
			$.each(headerdata, function(idx, el){
				if (el.MenuID == menuID){
					menuName = CFN_GetDicInfo(el.MultiDisplayName);
					formData.append("ReservedStr1", menuName);
				}
			});
		}
		
	    board.setDataByBizSection(bizSection, formData);	//통합게시, 문서관리별 작성,수정시 설정한 데이터 formData에 추가
		
		if(mode == "update" && g_messageConfig.MsgState !== "D"){	//mode: 'create', 'reply', 'update', 'revision'
			url = "/groupware/board/updateMessage.do";
			
			formData.append("messageID", messageID);
			formData.append("chkTemp",false); //임시저장>수정인지 그냥 수정인지 판단
		} else {	//추가, 답글
			url = "/groupware/board/createMessage.do";
			if($("#OwnerCode").val()==""){
				$("#OwnerCode").val(sessionObj["USERID"]);
			}
			
			// 본글 승인 프로세스 사용 또는 답글 승인프로세스 사용 일때
			if(((mode != "reply" && $("#IsApproval").val() == "Y") || (mode == "reply" && $("#IsApproval").val() == "Y" && $("#IsReplyApproval").val() == "Y")) && pMessageState != "T") {	
				// 사용자 지정 승인 프로세스 추가시 
				// formData.append("processActivityList", encodeURIComponent(board.setUserDefFieldData()));
			
				// 답글알림 설정 위치
				pMessageState = "R";	//승인 요청 상태 
			}
			
			formData.append("ownerCode", $("#OwnerCode").val());
		    formData.append("msgState", pMessageState);
		    
		    // 게시판 설정의 등록알림 수신자/제외자 전달. 작성자는 제외함.
		    try {
		    	var msgTarget = g_boardConfig.MessageTarget;
			    formData.append("Receivers", msgTarget.Receivers.code);
			    formData.append("Excepters", msgTarget.Excepters.code != "" ? msgTarget.Excepters.code + ';' + Common.getSession('UR_Code') + ';' : Common.getSession('UR_Code') + ';');
		    }
		    catch (ex){
		    	coviCmn.traceLog(ex);
		    }
		}
	    
	    var targetBtnSelector ='';
	    var targetBtnEvent = '';
	    
	    if(pMessageState == "C" || pMessageState == "T"){
	    	targetBtnSelector = "[name=btnCreate], [name=btnTemp]";
	    }
	    targetBtnEvent = $(targetBtnSelector).attr("onclick");
	    
		$.ajax({
	    	type:"POST",
	    	url: url,
	    	data: formData,
	    	dataType: 'json',
	        processData: false,
	        contentType: false,
	        beforeSend: function() {
	        	$(targetBtnSelector).attr("onclick", "");
	        },
	    	success: function(data){
	    		if(data.status == 'SUCCESS'){
	    		
		    		Common.Inform("<spring:message code='Cache.msg_37'/>", "Information", function(){		// 저장되었습니다.
			    		//컨텐츠 타입 폴더의 경우 등록후 상세보기로 이동
			    		if(g_boardConfig.FolderType == "Contents"){
			    			board.goView("Board", g_boardConfig.MenuID, 1, $("#selectFolderID").val(), data.messageID, "", "", "", "", "", "Normal", "");
				    	} else {
				    		if(writeMode == "simpleMake"){
				    			board.goFolderContents(bizSection, menuID, folderID, g_boardConfig.FolderType, "", "Y");
				    		}else if(isPopup == "Y"){
				    			if (sessionStorage.getItem("urlHistory") == null)
					    			Common.Close();
				    			else {
				    				if (opener) opener.location.reload();
				    				Common.Close();
				    			}	
				    		}else if(g_urlHistory != undefined && g_urlHistory != ""){
				    			board.goFolderContents(g_urlHistory);
				    		}else{
				    			CoviMenu_GetContent('/groupware/layout/board_BoardHome.do?CLSYS=board&CLMD=user&CLBIZ=Board&menuID='+menuID);
				    		}
						}
		    		});
	    		}else{
	    			if(data.detailMsg == 'MAX'){
	    				$(targetBtnSelector).attr("onclick", targetBtnEvent);
		    			Common.Warning("커뮤니티 용량을 초과하였습니다."); // 커뮤니티 용량을 초과하였습니다.
	    			}else{
	    				$(targetBtnSelector).attr("onclick", targetBtnEvent);
		    			Common.Warning(data.message);	// 저장 중 오류가 발생하였습니다.
	    			}
	    			
	    		}
	    	}, 
	  		error: function(error){
	  			$(targetBtnSelector).attr("onclick", targetBtnEvent);
	  			Common.Warning("<spring:message code='Cache.msg_sns_03'/>");	// 저장 중 오류가 발생하였습니다.
	  		}
	    });
	}
}

//임시저장 게시 등록
function setTempMessage(){
	if(board.checkMessageValidation()){
		//Multipart 업로드를 위한 formdata객체 사용 
		var formData = new FormData();
		formData.append("mode", mode);
		formData.append("folderID", $("#selectFolderID").val());
		formData.append("menuID", menuID);
		formData.append("bizSection", bizSection);
		formData.append("boardType", CFN_GetQueryString("boardType"));
		
		//커뮤니티 
		if(communityID != "" ){	//Community용 Parameter추가
			formData.append("communityId", communityID);
			formData.append("CSMU", CFN_GetQueryString("CSMU"));
		}else{
			formData.append("CSMU", "X");
		}
	  	
	    board.setDataByBizSection(bizSection, formData);	//통합게시, 문서관리별 작성,수정시 설정한 데이터 formData에 추가
	    
	    var menuName = "";
		if(window.hasOwnProperty('headerdata')) {
			$.each(headerdata, function(idx, el){
				if (el.MenuID == menuID){
					menuName = CFN_GetDicInfo(el.MultiDisplayName);
					formData.append("ReservedStr1", menuName);
				}
			});
		}
		
		url = "/groupware/board/tempSaveMessage.do";
		
		if($("#OwnerCode").val()==""){
			$("#OwnerCode").val(sessionObj["USERID"]);
		}
		
		formData.append("ownerCode", $("#OwnerCode").val());
		formData.append("messageID", messageID);

		if($("#IsApproval").val()=="Y"){
			formData.append("msgState", "R");
		}else{
			formData.append("msgState", "C");
		}
		
		// 게시판 설정의 등록알림 수신자/제외자 전달. 작성자는 제외함.
	    try {
	    	var msgTarget = g_boardConfig.MessageTarget;
		    formData.append("Receivers", msgTarget.Receivers.code);
		    formData.append("Excepters", msgTarget.Excepters.code != "" ? msgTarget.Excepters.code + ';' + Common.getSession('UR_Code') + ';' : Common.getSession('UR_Code') + ';');
	    }
	    catch (ex){
	    	coviCmn.traceLog(ex);
	    }

		$.ajax({
	    	type:"POST",
	    	url: url,
	    	data: formData,
	    	dataType : 'json',
	        processData : false,
	        contentType : false,
	    	success:function(data){
	    		if(data.status=='SUCCESS'){
	    			/*저장되었습니다.*/
		    		Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){
			    		//컨텐츠 타입 폴더의 경우 등록후 상세보기로 이동
			    		if(g_boardConfig.FolderType == "Contents"){
			    			board.goView("Board", g_boardConfig.MenuID, 1, $("#selectFolderID").val(), data.messageID, "", "", "", "", "", "Normal", "");
				    	} else {
				    		if(writeMode == "simpleMake"){
				    			board.goFolderContents(bizSection, menuID, folderID, g_boardConfig.FolderType, "", "Y");
				    		}else if(isPopup == "Y"){
				    			location.href = sessionStorage.getItem("urlHistory");
				    		}else if(g_urlHistory != undefined && g_urlHistory != ""){
				    			board.goFolderContents(g_urlHistory);
				    		}else{
				    			CoviMenu_GetContent('/groupware/layout/board_BoardHome.do?CLSYS=board&CLMD=user&CLBIZ=Board&menuID='+menuID);
				    		}
					    }
		    			
		    		});
	    		}else{
	    			Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
	    		}
	    	}, 
	  		error:function(error){
	  			Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
	  		}
	    });
	}
}

//CHECK: 개정용 메소드 분리
function setMessageRevision(){
	if(board.checkMessageValidation()){
		//Multipart 업로드를 위한 formdata객체 사용 
		var formData = new FormData();
		formData.append("mode", "revision");	//Revision은 별도 함수로 분리해놓고 진행
		formData.append("folderID", $("#selectFolderID").val());
		formData.append("bizSection", bizSection);
		formData.append("messageID", messageID);
		
		//커뮤니티 
		if(communityID != "" ){	//Community용 Parameter추가
			formData.append("communityId", communityID);
			formData.append("CSMU", CFN_GetQueryString("CSMU"));
		}else{
			formData.append("CSMU", "X");
		}
	  	
	    board.setDataByBizSection(bizSection, formData);	//통합게시, 문서관리별 작성,수정시 설정한 데이터 formData에 추가
		
		formData.append("ownerCode", $("#OwnerCode").val());
	    
	    var messageState = "C";	//등록 상태
	    if($("#IsApproval").val() == "Y"){
			//사용자 지정 승인 프로세스 추가시 
			//formData.append("processActivityList", encodeURIComponent(board.setUserDefFieldData()));
			messageState = "R";	//승인 요청 상태 
		}
		formData.append("msgState", messageState);
		
		url = "/groupware/board/createMessage.do";

		$.ajax({
	    	type:"POST",
	    	url: url,
	    	data: formData,
	    	dataType : 'json',
	        processData : false,
	        contentType : false,
	    	success:function(data){
	    		if(data.status=='SUCCESS'){
	    			/*저장되었습니다.*/
		    		Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){
		    			board.goFolderContents(g_urlHistory);
		    		});
	    		}else if(data.status == 'MAX'){
	    			Common.Warning(data.message); // 커뮤니티 용량을 초과하였습니다.
	    		}else{
	    			Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
	    		}
	    	}, 
	  		error:function(error){
	  			Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
	  		}
	    });
	}
}

//열람 권한 설정 팝업
function goReadAuthPopup(){
	//열람권한 설정
	Common.open("","readAuth","<spring:message code='Cache.lbl_MessageReadAuthSet' />","/groupware/board/goReadAuthPopup.do?frangment=contents" ,"360px","380px","iframe",false,null,null,true);
}

//상세 권한 설정 팝업
function goMessageAuthPopup(){
	//상세권한 설정
	Common.open("","messageAuth","<spring:message code='Cache.lbl_MessageDetailAuthSet' />","/groupware/board/goMessageAuthPopup.do?frangment=contents" ,"650px","525px","iframe",false,null,null,true);
}

//화면 이벤트와 연동되는 데이터 처리용
function toggleTopNotice(pObj){
	$(pObj).parent().hasClass('active') == true ? $(pObj).parent().removeClass('active') :$(pObj).parent().addClass('active') ;
}

//문서관리 내부 보존 기간 설정이 만료일로 자동 적용
function changeKeepYear( pObj ){
	var year = $(pObj).val()
	
	var date = new Date(CFN_GetLocalCurrentDate(_StandardServerDateFormat));
    date.setFullYear(date.getFullYear()+parseInt(year));
    date.setMonth(date.getMonth());
    date.setDate(date.getDate());
    $("#ExpiredDate").val(board.dateString(date).substring(0, 10));
}

initContent();

function initContent(){
	//1. 작성자이름, 부서 정보 설정 및 에디터 불러오기
	g_editorBody = '';
	
	$('#UserName').val(sessionObj["UR_Name"]);
	$('#GroupName').val(sessionObj["GR_Name"]);
	$('#selectTopNotice').coviCtrl("setDateInterval", $('#TopStartDate'), $('#TopEndDate'));
	$('#selectPopupNotice').coviCtrl("setDateInterval", $('#PopupStartDate'), $('#PopupEndDate'));
	$('#selectReservation').coviCtrl("setDateInterval", $('#ReservationDate'));
	$('#reservationTime').coviCtrl('setTime', 30);	//시간:분 30분 간격으로 표시
	
	//2. UI및 이벤트 설정
	board.bindEventByBizSection(bizSection);	//게시판, 문서관리별 이벤트 바인딩
	board.bindOptionControl($("#selectFolderID").val(), 'N');					//선택한 Folder의 환경설정 검색 
	
	//3. mode에 따른 옵션값 설정 
	//TODO:추후 board.js에 추가 
	//'create', 'reply', 'update', 'revision'
	if(mode == 'create'){
		//작성자 명, 부서명을 세션에서 가져온 사용자명으로 우선 설정
		if(g_boardConfig.FolderType != "Anonymous"){
			$("#CreatorName").val($("#UserName").val());
		}
		$("[name=btnUpdate], [name=btnRevision]").hide();	//수정, 개정 버튼 숨김

		//작성화면에서 에디터에 본문양식을 불러와야하므로 bindOption에서 설정하지 않음 
		g_editorBody = coviCmn.isNull(g_boardConfig.DefaultContents,'');
		if(g_boardConfig.UseBodyForm == "Y" && $("#selectBodyFormID").val() != ""){
			//setTimeout(function (){ 
				board.selectBodyFormData($("#selectBodyFormID").val(), 'N');
			//}, 700);
		}
	} else if(mode =='reply'){
		$("#selectFolderID").prop("disabled" ,true);		//수정시 게시판 변경 불가능
		$("#CreatorName").val($("#UserName").val());		//작성자 명, 부서명을 세션에서 가져온 사용자명으로 우선 설정
		$("[name=btnUpdate], [name=btnRevision], [name=btnTemp]").hide();	//수정, 개정, 임시저장 버튼 숨김
		
		//답글일 경우 원본게시글과 동일한 게시판 정보를 조회 및 설정
		board.selectOriginMessageInfo(bizSection, version, messageID, folderID);
		
		//작성화면에서 에디터에 본문양식을 불러와야하므로 bindOption에서 설정하지 않음 
		g_editorBody = coviCmn.isNull(g_boardConfig.DefaultContents,'');
		if(g_boardConfig.UseBodyForm == "Y" && $("#selectBodyFormID").val() != ""){
			//setTimeout(function (){ 
				board.selectBodyFormData($("#selectBodyFormID").val(), 'N');
			//}, 700);
		}		
	} else if(mode =='migrate'){
		$("#CreatorName").val($("#UserName").val());				//작성자 명, 부서명을 세션에서 가져온 사용자명으로 우선 설정
		$("[name=btnUpdate], [name=btnRevision], [name=btnTemp]").hide();				//임시저장, 수정, 개정 버튼 숨김
		
		board.selectMessageDetail("Write", bizSection, version, messageID, folderID);	//board_message 테이블기준 설정항목 조회
		
		$("#DocNumber").prop("disabled",false);
		changeKeepYear($("#selectKeepyear"));
		
	} else {
		if(!board.checkModifyAuth(bizSection, folderID, messageID, version)){
			Common.Warning("<spring:message code='Cache.msg_noModifyACL'/>", "Warning", function(answer){ // 수정 권한이 없습니다.
				if(answer){
					cancelMessage();
				}
			});
		}
		
		$("#selectFolderID").prop("disabled" ,true);										//수정시 게시판 변경 불가능
		board.selectMessageDetail("Write", bizSection, version, messageID, folderID);		//board_message 테이블기준 설정항목 조회
		board.renderMessageOptionWrite(bizSection, version, messageID, folderID);			//옵션별 설정, 표시항목 조회 (태그, 링크, 열람권한, 상세권한, 사용자정의 폼 조회 )
		
		if(g_messageConfig.MsgState == "T"){
			$("[name=btnTempCreate]").show();
		}
		
		if(writeMode == 'simpleMake'){ // 간편 게시 작성 상세 등록시 버튼 표시
			$("[name=btnUpdate]").removeClass("btnTypeChk");
			$("[name=btnUpdate]").text("<spring:message code='Cache.lbl_TempSave' />"); // 임시저장
		}
		
		//목차/이력형 게시판의 경우 개정버튼 표시
		if(g_boardConfig.FolderType == "TableHistory" && writeMode != 'simpleMake'){
			$("[name=btnRevision]").show();
			//if (g_boardConfig.OwnerCode != Common.getSession('UR_Code') && Common.getSession('isAdmin') != 'Y') {
			//	$("[name=btnUpdate]").hide();
			//}
		}
		
		//등록, 임시저장 버튼 숨김
		$("[name=btnCreate], [name=btnTemp]").hide();
		
		// 반려된 게시 재등록 시 버튼 처리
		if (g_messageConfig.MsgState === "D") {
			$("[name=btnUpdate]").hide();
			$("[name=btnCreate]").show();
		}
	}
	
	if (communityID != '') {
		$(".allMakeTitle").width($("#formData .boradTopCont").width());
		$(".inputBoxSytel01 > div:first-child").css("width", "120px");
		$(".inStyleSetting > ul").css("padding-left", "0");
	}
	
	$('.collabo_help02 .help_ico').on('click', function(){
		if($(this).hasClass('active')){
			$(this).removeClass('active');
		}else {
			$(this).addClass('active')
		}
	});
	
	board.setEditor();
	board.renderFileLimitInfo();
	
	//본문 사용여부 
	if (g_boardConfig.UseBody == "N"){
		$("#divWebEditor").hide();
	}
	
	//미리보기 사용여부
	if(Common.getBaseConfig("UseBoardPreViewPopup") == "N") {
		$('[name=btnNoticePreView]').remove();
	}
	
	$("#UseCategory").val(g_boardConfig.UseCategory);
}

</script>
