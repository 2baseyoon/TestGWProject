<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<style>
	.h_Line, .h_Half {
		height:30px !important;
	}
	
	.h_2Line {
		height:40px !important;
	}
	
	.h_3Line {
		height:60px !important;
	}
	
	.h_4Line {
		height:80px !important;
	}
	
	.h_5Line {
		height:100px !important;
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
	</div>
	<div class="surveySetting">
		<a href="#" class="surveryContSetting btnMakeCont">설정</a>
		<!-- <a href="#" class="surveryWinPop">팝업</a> -->
	</div>
</div>
<form id="formData" method="post" enctype="multipart/form-data">
	<div class="cRContBottom mScrollVH ">
		<div class="boardAllCont">
			<div class="boradTopCont allMakeSettingView active">
				<div class="allMakeView">
					<div class="inpStyle01 allMakeTitle">
						<input type="text" id="Subject" name="subject" class="inpStyle01 HtmlCheckXSS ScriptCheckXSS" placeholder="<spring:message code='Cache.msg_EnterSubject'/>">
					</div>
				</div>
				<!-- 우측의 버튼에 따라 만료일 설정 및 상단 공지 설정하는 datepicker 표시/숨김처리 버튼 배치-->
				<div id="divBoardSchedule" >
					<div class="inStyleSetting">
						<ul>
							<!-- 상단공지 ON/OFF 버튼처리 -->
							<li>
<!-- 								<a href="#" class="btnNoti" onclick="javascript:toggleTopNotice(this);">TOP</a> -->
									<a class="btnNoti">TOP</a>
							</li>
							<!-- 강조기능 숨김 -->
							<!-- <li>
								<a href="#" class="btnBold">B</a>
							</li> -->
							
							<li>
								<a href="#" class="btnInqPer">조회기간 설정</a>
							</li>
						</ul>
						<div class="inPerView">
							<div>
								<div class="selectCalView oneDate">
									<span><spring:message code='Cache.lbl_ExpireDate'/></span>
									<div class="dateSel type02">
										<input class="adDate" type="text" id="ExpiredDate" date_separator="." kind="date" type="text" data-axbind="date" >
									</div>											
								</div>
								<div id="divTopNotice" class="selectCalView ml25" >
									<span><spring:message code='Cache.lbl_chkTop'/></span>
									<select id="selectNotice" class="selectType01">
									</select>
									<div class="dateSel type02">
										<input class="adDate" type="text" id="TopStartDate" date_separator="."> - <input class="adDate" type="text" date_separator="." kind="twindate" date_startTargetID="TopStartDate" id="TopEndDate">
									</div>
								</div>
								<div id="divPopupNotice" class="chkStyle01">
									<input type="checkbox" id="chkIsPopup" ><label for="chkIsPopup"><span></span><spring:message code='Cache.lbl_NoticePopup'/></label>
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
						<!-- 게시판이름 label -->
						<div><span><spring:message code='Cache.lbl_Board_folderName'/></span></div>
						<!-- 게시판선택 -->  
						<select id="selectFolderID" name="folderID" class="selectType02 size102" onchange="board.bindOptionControl($(this).val(), 'Y');"> </select>
						
						<!-- 카테고리 --> 
						<select id="selectCategoryID" name="categoryID" class="selectType02 size102" >
							<option value="0"><spring:message code='Cache.lbl_JvCateSel'/></option>
						</select>
						
						<!-- 익명, 부서명 게시 체크박스 -->
						<div class="inputBoxSytel01 subDepth type02">
							<div><span><spring:message code='Cache.lbl_Register'/></span></div>
							<div>
								<input type="text" id="CreatorName" name="creatorName" style="width: 100px;" class="inpReadOnly" disabled/>
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
					<div id="divUserDefField" class="makeMoreInput active" >
						<!-- 이슈공유리스크게시판 custom -->
						<div class="inputBoxSytel01 type02">
							<div><span class="star"><spring:message code='Cache.lbl_issue_customerName'/></span></div>
							<div><input type="text" id="CustomerName" name="customerName" class="HtmlCheckXSS ScriptCheckXSS" style="width: 100%;" ischeck="Y" required="required"/></div>
						</div>
						<div class="inputBoxSytel01 type02">
							<div><span class="star"><spring:message code='Cache.lbl_issue_projectName'/></span></div>
							<div><input type="text" id="ProjectName" name="projectName" class="HtmlCheckXSS ScriptCheckXSS" style="width: 100%;" ischeck="Y"/></div>
						</div>
						<div class="inputBoxSytel01 type02">
							<div><span class="star"><spring:message code='Cache.lbl_issue_projectManager'/></span></div>
							<div><input type="text" id="ProjectManager" name="projectManager" class="HtmlCheckXSS ScriptCheckXSS" ischeck="Y"/></div>
						</div>
						<div class="inputBoxSytel01 type02">
							<div><span class="star"><spring:message code='Cache.lbl_issue_productType'/></span></div>
							<div>
								<input type="radio" id="ProductType" name="productType" value="0" ischeck="Y">
								<label><span>CP</span></label>
								<input type="radio" id="ProductType" name="productType" value="1" ischeck="Y">
								<label><span>MP</span></label>
							</div>
						</div>
						<div class="inputBoxSytel01 type02">
							<div><span class="star"><spring:message code='Cache.lbl_issue_module'/></span></div>
							<div><input type="text" id="Module" name="module" class="HtmlCheckXSS ScriptCheckXSS" style="width: 100%;" ischeck="Y"/></div>
						</div>
						<div class="inputBoxSytel01 type02">
							<div><span class="star"><spring:message code='Cache.lbl_issue_issueType'/></span></div>
							<div><input type="text" id="ProjectIssueType" name="projectIssueType" class="HtmlCheckXSS ScriptCheckXSS" style="width: 100%;" ischeck="Y"/></div>
						</div>
						<div class="inputBoxSytel01 type02">
							<div><span class="star"><spring:message code='Cache.lbl_issue_issueContext'/></span></div>
							<div>
								<textarea id="ProjectIssueContext" name="projectIssueContext" class="HtmlCheckXSS ScriptCheckXSS" style="width:100%; height:100px; resize:none;" ischeck="Y"></textarea>
							</div>
						</div>
						<div class="inputBoxSytel01 type02">
							<div><span><spring:message code='Cache.lbl_issue_issueSolution'/></span></div>
							<div>
								<textarea id="ProjectIssueSolution" name="projectIssueSolution" class="HtmlCheckXSS ScriptCheckXSS" style="width:100%; height:100px; resize:none;"></textarea>
							</div>
						</div>
						<div class="inputBoxSytel01 type02">
							<div><span><spring:message code='Cache.lbl_issue_progress'/></span></div>
							<div>
								<textarea id="Progress" name="progress" class="HtmlCheckXSS ScriptCheckXSS" style="width:100%; height:100px; resize:none;"></textarea>
							</div>
						</div>
						<div class="inputBoxSytel01 type02">
							<div><span><spring:message code='Cache.lbl_issue_result'/></span></div>
							<div>
								<textarea id="Result" name="result" class="HtmlCheckXSS ScriptCheckXSS" style="width:100%; height:100px; resize:none;"></textarea>
							</div>
						</div>
						<div class="inputBoxSytel01 type02">
							<div>
								<span>완료일자</span>
							</div>
							<div class="h_Line">
								<input name="complateDate" ischeck="N" date_separator="." kind="date" type="text" data-axbind="date" id="ComplateDate">
								<div id="inputBasic_AX_ComplateDate" class="AXanchor" style="left: 140px; top: 171px; width: 171px; height: 0px; display: block;">
									<a href="javascript:;" id="inputBasic_AX_ComplateDate_AX_dateHandle" class="AXanchorDateHandle" style="right: 0px; top: 0px; width: 30px; height: 30px;">&nbsp;</a>
								</div>
							</div>
						</div>
						<div class="inputBoxSytel01 type02">
							<div>
								<span>완료여부</span>
							</div>
							<div class="h_Line">
								<select  id="ComplateCheck" name="complateCheck" class="selectType02 size102">
									<option value=""><spring:message code='Cache.msg_Select'/></option>
									<option value="0">진행중</option>
									<option value="1">완료</option>
								</select>
							</div>
						</div>
						<div class="inputBoxSytel01 type02">
							<div><span>비고</span></div>
							<div>
								<textarea id="Etc" name="etc" class="HtmlCheckXSS ScriptCheckXSS" style="width:100%; height:100px; resize:none;"></textarea>
							</div>
						</div>
					</div>
					<div id="divEventBoard">	<!-- 경조사 게시판: 임직원 소식 웹파트에 표시되는 게시판 -->
						<div class="inputBoxSytel01 type02">
							<div>
								<span class="star">일자</span>
							</div>
							<div class="h_Half">
								<input id="EventDate" date_separator="." kind="date" type="text" data-axbind="date" id="AXInput-3">
							</div>
							<div class="inputBoxSytel01 subDepth type02">
								<div>
									<span class="star">종류</span>
								</div>
								<div class="h_Half">
									<select id="EventType" class="selectType02 size102">
										<option value="">선택하세요</option>
										<option value="Marry">결혼</option>
										<option value="Promotion">진급</option>
										<option value="Event">돌잔치</option>
									</select>
								</div>
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
					<!-- 본문양식 -->
					<div id="divBodyForm" class="inputBoxSytel01 type02" >
						<div><span><spring:message code='Cache.lbl_BodyForm'/></span></div>
						<div>
							<select id="selectBodyFormID" class="selectType02 size233" onchange="board.selectBodyFormData($(this).val(),'Y');"> </select>
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
							<input type="text" id="title" class="midInput HtmlCheckXSS ScriptCheckXSS" placeholder="링크명">
							<input type="text" id="link" class="midInput HtmlCheckXSS ScriptCheckXSS" placeholder="URL">
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
		<div class="cRTopButtons">
			<a href="#" name="btnCreate" class="btnTypeDefault btnTypeChk" onclick="javascript:setMessage('C');"><spring:message code='Cache.btn_register'/></a>	<!-- 등록 -->
			<a href="#" name="btnTempCreate" style="display:none;" class="btnTypeDefault btnTypeChk" onclick="javascript:setTempMessage();"><spring:message code='Cache.btn_register'/></a>	<!-- 등록 -->
			<a href="#" name="btnUpdate" class="btnTypeDefault btnTypeChk" onclick="javascript:setMessage();"><spring:message code='Cache.btn_Confirm'/></a>	<!-- 확인 -->
			<a href="#" name="btnRevision" class="btnTypeDefault" onclick="javascript:setMessageRevision();"><spring:message code='Cache.btn_Revision'/></a>	<!-- 개정 -->
			<a href="#" name="btnTemp" class="btnTypeDefault" onclick="javascript:setMessage('T');"><spring:message code='Cache.btn_tempsave'/></a>				<!-- 임시저장 -->
			<a href="#" name="btnCancel" class="btnTypeDefault" onclick="javascript:cancelMessage();"><spring:message code='Cache.btn_Cancel'/></a>				<!-- 취소 -->
			<a href="#" class="btnTop">탑으로 이동</a>
		</div>
	</div>
</div>
	
	<input type="hidden" id="FolderType" name="folderType" value="" />
	<input type="hidden" id="UseMessageReadAuth" name="useMessageReadAuth" value="" />	<!-- 열람권한 사용여부 -->
	<input type="hidden" id="messageReadAuth" name="messageReadAuth" value="" />		<!-- 열람권한 설정정보 -->
	<input type="hidden" id="UseMessageAuth" name="useMessageAuth" value="" />			<!-- 상세권한 사용 여부 -->
	<input type="hidden" id="messageAuth" name="messageAuth" value="" />				<!-- 상세권한 설정정보 -->
	<input type="hidden" id="IsInherited" name="isInherited" value="Y" />				<!-- 폴더 권한 상속 여부 -->
	<input type="hidden" id="GroupName" value="" />	<!-- 현재 접속자의 부서 -->
	<input type="hidden" id="UserName" value="" />	<!-- 현재 접속자의 이름 -->
	<input type="hidden" id="OwnerCode" value="" />
	
	<input type="hidden" name="imageCnt" value="0" />			<!-- imageCnt를 별도로 관리할 필요가 있는지 확인 필요 -->
	
	<input type="hidden" id="Version" name="version" value="0" />
	<input type="hidden" id="Seq" name="seq" value="0" />		<!-- 답글일경우 원본글의 MessageID를 설정 -->
	<input type="hidden" id="Step" name="step" value="0" />		<!-- 답글 표시 순서 -->
	<input type="hidden" id="Depth" name="depth" value="0" />	<!-- 답글 표시 깊이, 답글의 답글, 등을 표시 할때  -->
	<!--<input type="hidden" id="IsPopup" name="isPopup" value="N" />-->	<!-- 팝업공지 사용여부, 현재는 N -->
	<input type="hidden" id="IsTop" name="isTop" value="N" />		<!-- 상단공지 사용 여부 -->
	<input type="hidden" id="IsApproval" name="isApproval" value="N" /> <!-- 승인프로세스 사용여부 -->
	<input type="hidden" id="IsUserForm" name="isUserForm" value="N" />	<!-- 사용자 정의 필드 사용 여부 -->
	<input type="hidden" id="UseRSS" name="useRSS" value="N" />
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
	//뒤로가기 사용시 대메뉴를 통해 접근한 페이지의 이전 페이지로 이동됨
	board.goFolderContents(g_urlHistory);	//마지막 페이지로 이동하도록
}


//게시 작성, 임시저장, 수정 
function setMessage( pMessageState ){	//C: 등록 (Default), T: 임시저장, 그외의 코드값은 해당페이지에서 관리 하지 않음
	
	//개별호출-일괄호출
	Common.getDicList(["msg_EnterFieldValue"]);
	
	//필수값 체크
	var isUserForm = true;
	var userFormName = "";
	var userFormObj = null;
	var radioChk = false;
	var radioVal = "";
	var radioName = "";

	if(g_boardConfig.UseUserForm == "Y"){
		$(this.formData).find("input, select, textarea").each(function(i){
			userFormObj = $(this);
			if(userFormObj.attr("ischeck")=="Y"){
				if(userFormObj.attr("type")=="radio"){
					radioChk = true;
					radioName = $(this).parent().prev().text().split(" ").join("");
					if($(this).prop("checked")){
						radioVal = $(this).val();
					}
				}
				if($(this).val() == ""){
					userFormName = $(this).parent().prev().text().split(" ").join("");
					isUserForm = false;
				}
			}
		});
		if(radioChk){
			if(radioVal==""){
				userFormName = radioName;
				isUserForm = false;
			}
		}
		if(!isUserForm){
			parent.Common.Warning(userFormName + " " + coviDic.dicMap["msg_EnterFieldValue"], "Warning Dialog", function () {	//필드값을 설정해주세요.
				userFormObj.focus();
	        });
			return isUserForm;
		}
	}
	
	if(board.checkMessageValidation()){
		//Multipart 업로드를 위한 formdata객체 사용 
		var formData = new FormData();
		formData.append("mode", mode);
		formData.append("folderID", $("#selectFolderID").val());
		formData.append("menuID", menuID);
		formData.append("bizSection", bizSection);
		formData.append("boardType", CFN_GetQueryString("boardType"))
		
		//커뮤니티 
		if(CFN_GetQueryString("communityId") != "undefined" ){	//Community용 Parameter추가
			formData.append("communityId", CFN_GetQueryString("communityId"));
			formData.append("CSMU", CFN_GetQueryString("CSMU"));
		}else{
			formData.append("CSMU", "X");
		}
	  	
	    board.setDataByBizSection(bizSection, formData);	//통합게시, 문서관리별 작성,수정시 설정한 데이터 formData에 추가
		
		if(mode == "update"){	//mode: 'create', 'reply', 'update', 'revision'
			url = "/groupware/board/updateIssueMessage.do";
			
			formData.append("messageID", messageID);
		} else {	//추가, 답글
			url = "/groupware/board/createIssueMessage.do";
			if($("#OwnerCode").val()==""){
				$("#OwnerCode").val(sessionObj["USERID"]);
			}
			if(mode != "reply" && $("#IsApproval").val() == "Y" && pMessageState != "T"){	//답글은 승인 프로세스를 사용하지 않음
				//사용자 지정 승인 프로세스 추가시 
// 				formData.append("processActivityList", encodeURIComponent(board.setUserDefFieldData()));
				//답글알림 설정 위치
				pMessageState = "R";	//승인 요청 상태 
			}
			formData.append("ownerCode", $("#OwnerCode").val());
		    formData.append("msgState", pMessageState);
		}
	    
		$.ajax({
	    	type:"POST",
	    	url: url,
	    	data: formData,
	    	dataType : 'json',
	        processData : false,
	        contentType : false,
	    	success:function(data){
	    		if(data.status == 'SUCCESS'){
	    			/*저장되었습니다.*/
		    		Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){
			    		//컨텐츠 타입 폴더의 경우 등록후 상세보기로 이동
			    		if(g_boardConfig.FolderType == "Contents"){
			    			board.goView("Board", g_boardConfig.MenuID, 1, $("#selectFolderID").val(), data.messageID, "", "", "", "", "", "Normal", "");
				    	} else {
				    		board.goFolderContents(g_urlHistory);
						}
		    		});
	    		}else{
	    			if(data.detailMsg == 'MAX'){
		    			Common.Warning("커뮤니티 용량을 초과하였습니다."); // 커뮤니티 용량을 초과하였습니다.
	    			}else{
		    			Common.Warning(data.message);/* 저장 중 오류가 발생하였습니다. */
	    			}
	    			
	    		}
	    	}, 
	  		error:function(error){
	  			Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
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
		formData.append("bizSection", bizSection);
		formData.append("boardType", CFN_GetQueryString("boardType"));
	  	
	    board.setDataByBizSection(bizSection, formData);	//통합게시, 문서관리별 작성,수정시 설정한 데이터 formData에 추가
		
		url = "/groupware/board/updateMessage.do";
		
		formData.append("messageID", messageID);
		formData.append("msgState", "C");
		
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
				    		board.goFolderContents(g_urlHistory);
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
		if(CFN_GetQueryString("communityId") != "undefined" ){	//Community용 Parameter추가
			formData.append("communityId", CFN_GetQueryString("communityId"));
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
	Common.open("","messageAuth","<spring:message code='Cache.lbl_MessageDetailAuthSet' />","/groupware/board/goMessageAuthPopup.do?frangment=contents" ,"508px","525px","iframe",false,null,null,true);
}

//화면 이벤트와 연동되는 데이터 처리용
function toggleTopNotice(pObj){
	$(pObj).parent().hasClass('active') == true ? $(pObj).parent().removeClass('active') :$(pObj).parent().addClass('active') ;
	if($(pObj).parent().hasClass('active')){
		$("#IsTop").val("Y");
		$("#TopStartDate, #TopEndDate").prop("disabled", false);
	} else {
		$("#IsTop").val("N");
		$("#TopStartDate, #TopEndDate").prop("disabled", true).val("");
	}
}

//문서관리 내부 보존 기간 설정이 만료일로 자동 적용
function changeKeepYear( pObj ){
	var year = $(pObj).val()
	
	var date = new Date();
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
	$('#selectNotice').coviCtrl("setDateInterval", $('#TopStartDate'), $('#TopEndDate'));
	$('#selectReservation').coviCtrl("setDateInterval", $('#ReservationDate'));
	$('#reservationTime').coviCtrl('setTime', 30);	//시간:분 30분 간격으로 표시
	
	//2. UI및 이벤트 설정
	board.bindEventByBizSection(bizSection);	//게시판, 문서관리별 이벤트 바인딩
	bindOptionControl($("#selectFolderID").val(), 'N');					//선택한 Folder의 환경설정 검색 

	//3. mode에 따른 옵션값 설정 
	//TODO:추후 board.js에 추가 
	//'create', 'reply', 'update', 'revision'
	if(mode == 'create'){
		$("#selectFolderID").attr("style", "pointer-events: none;");
		//작성자 명, 부서명을 세션에서 가져온 사용자명으로 우선 설정
		$("#CreatorName").val($("#UserName").val());
		$("[name=btnUpdate], [name=btnRevision]").hide();	//수정, 개정 버튼 숨김
		
		//CHECK: 작성화면에서 에디터에 본문양식을 불러와야하므로 bindOption에서 설정하지 않음 
		g_editorBody = coviCmn.isNull(g_boardConfig.DefaultContents,'');
		if(g_boardConfig.UseBodyForm == "Y" && $("#selectBodyFormID").val() != ""){
			//setTimeout(function (){ 
				board.selectBodyFormData($("#selectBodyFormID").val(), 'N');
			//}, 700);
		}
		
		$("[name=btnTemp]").hide();
		
	} else if(mode =='reply'){
		$("#selectfolderid").attr("style", "pointer-events: none;");	//수정시 게시판 변경 불가능
		$("#CreatorName").val($("#UserName").val());		//작성자 명, 부서명을 세션에서 가져온 사용자명으로 우선 설정
		$("[name=btnUpdate], [name=btnRevision], [name=btnTemp]").hide();	//수정, 개정, 임시저장 버튼 숨김
		
		//답글일 경우 원본게시글과 동일한 게시판 정보를 조회 및 설정
		board.selectOriginMessageInfo(version, messageID, folderID);

		//작성화면에서 에디터에 본문양식을 불러와야하므로 bindOption에서 설정하지 않음 
		g_editorBody = coviCmn.isNull(g_boardConfig.DefaultContents,'');
		if(g_boardConfig.UseBodyForm == "Y" && $("#selectBodyFormID").val() != ""){
			board.selectBodyFormData($("#selectBodyFormID").val(), 'N');
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
		
		$("#selectfolderid").attr("style", "pointer-events: none;");					//수정시 게시판 변경 불가능
		selectMessageDetail("Write", bizSection, version, messageID, folderID);	//board_message 테이블기준 설정항목 조회
		board.renderMessageOptionWrite(bizSection, version, messageID, folderID);		//옵션별 설정, 표시항목 조회 (태그, 링크, 열람권한, 상세권한, 사용자정의 폼 조회 )

		if(g_messageConfig.MsgState == "T"){
			$("[name=btnTempCreate]").show();
		}
		//목차/이력형 게시판의 경우 개정버튼 표시
		if(g_boardConfig.FolderType == "TableHistory" && writeMode != 'simpleMake'){
			$("[name=btnRevision]").show();
		}
		//등록, 임시저장 버튼 숨김
		$("[name=btnCreate], [name=btnTemp]").hide();
	}
	
	
	board.setEditor();
	
	board.renderFileLimitInfo();
	
	$("#ComplateDate").change(function(){
		if($("#ComplateDate").val()==""){
			$("#ComplateCheck option[value=0]").prop("selected","selected");
		}else{
			$("#ComplateCheck option[value=1]").prop("selected","selected");
		}
	});
	
	$("#ComplateCheck").change(function(){
		if($("#ComplateCheck option:selected").val()=="0"){
			$("#ComplateDate").val("");
		}
	});
	
}

//게시판 옵션별 화면 표시 처리: 초기 화면에서는 모든 설정항목을 숨김표시하고 게시판 옵션에 따라 표시
//초기 바인딩 시 pIsChange "N" 게시판 변경 시 "Y" 
function bindOptionControl( pFolderID , pIsChange){
	board.getBoardConfig(pFolderID);
	var optionList = g_boardConfig;
	$("#messageAuth, #messageReadAuth").val("");	//권한 설정 초기화
	$("#divTagList, #divLinkList").html("");		//태그, 링크 초기화
	$("#tagCount, #linkCount").text("(0개)");		//UI 표시용 Count: DB에 기록 하지 않음
	
	//개별호출-일괄호출
	Common.getDicList(["msg_noWriteAuth","msg_contentAfterRegist","msg_contentAlreadyExist","lbl_CategorySelect"]);
	
	if(pFolderID != ""){
		if(!board.checkFolderWriteAuth(pFolderID)){
			Common.Warning(coviDic.dicMap["msg_noWriteAuth"], "Warning Dialog", function () {	//해당 분류에는 쓰기 권한이 없습니다.
				if(bizSection != "Doc"){
					$("#selectFolderID").val("");
					
					var	url = '/groupware/layout/board_BoardWrite.do?CLSYS=board&CLMD=user&CLBIZ=Board&mode=create&menuID='+menuID;
					CoviMenu_GetContent(url);
				} else {
					$(".path").html("");
					$("#hiddenFolderID").val("");
				}
			});
			return false;
		}
	}
	
	if(optionList.FolderType == "Contents" && mode == "create"){
		var contents = board.selectContentMessage(pFolderID);
		//선택한 컨텐츠 게시판에 게시물이 존재할 경우 상세보기 화면으로 이동 여부 확인 후 이동하지 않으면 게시판 선택 불가 처리
		if(!$.isEmptyObject(contents)){
			//해당 컨텐츠 게시판에 저장된 게시글이 존재합니다. 상세보기 화면으로 이동하시겠습니까?', '해당 컨텐츠 게시판에 저장된 게시글이 존재합니다. 상세보기 화면으로 이동하시겠습니까?
			Common.Confirm(coviDic.dicMap["msg_contentAfterRegist"], 'Confirmation Dialog', function (result) {
	            if (result) {
					//게시판 상세보기 조회 팝업
	            	board.goView("Board", menuID, contents.Version, contents.FolderID, contents.MessageID, "", "", "", "", "", "List", "Normal", "", "");
	            } else {
	            	//컨텐츠 게시판에는 한개의 게시글만 등록 가능합니다. 다른 게시판을 선택해주세요.', '컨텐츠 게시판에는 한개의 게시글만 등록 가능합니다. 다른 게시판을 선택해주세요.
	            	Common.Warning(coviDic.dicMap["msg_contentAlreadyExist"], "Warning Dialog", function () {
	            		$('#selectFolderID').val("");
			        });
	            }
	        });
			
		}
	}
	
	if(optionList.UseAutoDocNumber == "Y"){
		//문서 번호 자동 발번 옵션 사용
		$('#DocNumber').attr({placeholder:'AUTO', readonly:'readonly'}).addClass('inpReadOnly');
	}
	
	//익명게시 사용
	if(optionList.UseAnony != "Y"){
		$('#chkUseAnonym, [for=chkUseAnonym]').hide();
	} else {
		$('#chkUseAnonym, [for=chkUseAnonym]').show();
	}
	
	//부서명 게시 사용
	if(optionList.UsePubDeptName != "Y"){
		$('#chkUsePubDeptName, [for=chkUsePubDeptName]').hide();
	} else {
		$('#chkUsePubDeptName, [for=chkUsePubDeptName]').show();
	}
	
	//Limit 설정 영역
	$("#limitFileSize").text(optionList.LimitFileSize);	//업로드 파일 용량 제한
	$("#limitLinkCount").text(optionList.LimitLinkCnt);	//링크 설정 개수 제한, 태그의 경우 고정적으로 10개
	//카테고리 사용여부
	if(optionList.UseCategory == "Y"){
		$("#selectCategoryID").show();
		//분류 선택
		$("#selectCategoryID").coviCtrl("setSelectOption", "/groupware/board/selectCategoryList.do", 
			{folderID: pFolderID},
			coviDic.dicMap["lbl_CategorySelect"], "0"	
		);
	} else {
		$("#selectCategoryID").hide();
	}
	
	//본문기본내용
	var defaultContents = coviCmn.isNull(optionList.DefaultContents,'');
	if(pIsChange == "Y" && defaultContents != ''){
		g_editorBody = defaultContents;
		coviEditor.setBody(g_editorKind, 'tbContentElement', g_editorBody);
	}
	
	//본문양식 사용여부
	if(optionList.UseBodyForm == "Y"){
		//표시 및 조회
		$("#divBodyForm").show();
		$("#selectBodyFormID").coviCtrl("setSelectOption", "/groupware/board/selectBodyFormList.do", {folderID: pFolderID}).val();
		if(pIsChange == "Y"){
			$("#selectBodyFormID").change();
		} 
	} else {
		//숨김처리
		$("#divBodyForm").hide();
		$("#selectBodyFormID").html("");
	}
	
	//사용자정의 필드  초기화, 사용 여부 체크 후 조회
	//$("#divUserDefField").html("");
	if(optionList.UseUserForm == "Y" ){
		//게시판 환경설정에 따라 확장필드 조회 및 표시
		$("#divUserDefFieldHeader").show();
		$("#divUserDefFieldHeader").find(".btnSurMove").addClass("active");
		$("#divUserDefFieldHeader").next().addClass("active");
		board.getUserDefField("Write", pFolderID);
		$("#IsUserForm").val("Y");
	} else {
		//board_config의 UseUserForm이 N이면 게시글의 사용자정의폼도 N으로 설정
		$("#divUserDefFieldHeader").hide();
		$("#divUserDefFieldHeader").find(".btnSurMove").removeClass("active");
		$("#divUserDefFieldHeader").next().removeClass("active");
		$("#IsUserForm").val("N");
	}
	
	//경조사 게시판 이벤트 바인드
	if(Common.getBaseConfig("eventBoardID") == pFolderID){
		$("#divEventBoard").show();
			setOwnerInput();
	} else {
		$("#divEventBoard").hide();
	}
	
	//승인프로세스 사용여부
    if (status != "reply" && (optionList.UseOwnerProcess == "Y" || optionList.UseUserProcess == "Y")) {
        $("#IsApproval").val("Y");
	} else {
		$("#IsApproval").val("N");
	}
    
    //열람권한 설정 영역 표시 숨김, 값 설정은 api호출전 별도로 작업
    if(optionList.UseMessageReadAuth == "Y"){
    	$("#btnUseMessageReadAuth").show();
    } else {
    	$("#btnUseMessageReadAuth").hide();
    }
    
    //상세권한 설정 표시/숨김
    if(optionList.UseMessageAuth == "Y" || bizSection == "Doc"){
    	var folderACLList = board.getBoardAclList(pFolderID);	//폴더 권한 조회
        $("#messageAuth").val(JSON.stringify(folderACLList));	//폴더 선택,변경시 폴더권한 설정
    	$("#btnUseMessageAuth").show();
    } else {
    	$("#btnUseMessageAuth").hide();
    }
    
    //태그 
    if(optionList.UseTag == "Y"){
    	//태그 설정항목 표시
    	$("#divTagHeader").show();
//		$("#divTagHeader").find(".btnSurMove").addClass("active");
//		$("#divTagHeader").next().addClass("active");
    } else {
    	//태그  설정항목 숨김
    	$("#divTagHeader").hide();
		$("#divTagHeader").find(".btnSurMove").removeClass("active");
		$("#divTagHeader").next().removeClass("active");
    } 
    
    //링크
    if(optionList.UseLink == "Y"){
    	//링크 설정항목 표시 
    	$("#divLinkHeader").show();
//		$("#divLinkHeader").find(".btnSurMove").addClass("active");
//		$("#divLinkHeader").next().addClass("active");
    } else {
    	//링크 설정항목 숨김
    	$("#divLinkHeader").hide();
		$("#divLinkHeader").find(".btnSurMove").removeClass("active");
		$("#divLinkHeader").next().removeClass("active");
    }
    
    //팝업, 상단공지 표시/숨김처리
    if(optionList.FolderType == "Notice" && optionList.UseTopNotice == "Y"){
    	$(".btnNoti").parent().show();
    	$("#divTopNotice, #divPopupNotice").show();
    } else if(optionList.FolderType != "Notice" && optionList.UseTopNotice == "Y"){
    	$(".btnNoti").parent().show();
    	$("#divTopNotice").show();
    	$("#divPopupNotice").hide();
    } else {
    	$(".btnNoti").parent().hide();
    	$("#divTopNotice, #divPopupNotice").hide();
    }
    
    //예약 게시, 예약 일시 
    if(optionList.UseReservation == "Y"){
    	$('#divReservation').show();
    } else {
    	$('#divReservation').hide();
    	$('#ReservationDate').val("");
    	$('#reservationTime').val("00:00");
    }
    $('.inPerView').resize();	//달력컨트롤 탈출방지
    
    //일괄 체크하여 div영역 자체를 숨김
    $('#divConfigGroup input[type=checkbox]').prop('checked',false);
    
    //BaseConfig에서 Security Level 기본값 조회
	var default_security = Common.getBaseConfig('DefaultSecurityLevel',sessionObj["DN_ID"]);
	$("#selectSecurityLevel").val(default_security);
	
    if( optionList.UseSecurity != "Y"
    	&& optionList.UseReply != "Y"
    	&& optionList.UseComment != "Y"
    	&& optionList.UseScrap != "Y"){
    	$("#divConfigGroup").hide();
    } else {
    	$("#divConfigGroup").show();
    	//개별적으로 체크박스 숨김처리
    	//스크랩
        if(optionList.UseScrap == "Y") {
        	$("#spanScrap").show();
        } else {
        	$("#spanScrap").hide();
        }
    	
    	//비밀글 
    	if(optionList.UseSecret == "Y") {
        	$("#spanSecurity").show();
        } else {
        	$("#spanSecurity").hide();
        }
        //답글 사용시 답글 알림 사용여부 표시
    	if(optionList.UseReply == "Y") {
        	$("#chkUseReplyNotice").prop("checked", true);
        }
    	
    	//코멘트 사용시 코멘트 알림 사용여부 표시
    	if(optionList.UseComment == "Y") {
        	$("#chkUseCommNotice").prop("checked", true);
        }
    }
	
    //연결글, 문서관리에서는 무조건 표시
    if(optionList.UseLinkedMessage == "Y" || bizSection == "Doc"){
		$("#divLinkedMessage").show();
//		$("#divLinkedMessage").find(".btnSurMove").addClass("active");
//		$("#divLinkedMessage").next().addClass("active");
	} else {
		$("#divLinkedMessage").hide();
		$("#divLinkedMessage").find(".btnSurMove").removeClass("active");
		$("#divLinkedMessage").next().removeClass("active");
	}
    
    //만료일 사용 여부
	if (optionList.UseExpiredDate == "Y") {
        if (optionList.ExpireDay == 0) {		//0은 만료일을 사용 안함 상태
            $('#ExpiredDate').attr('disabled', true);
            //만료일 설정 disable처리 혹은 숨겨야됨
        } else {
            var date = new Date();
            date.setFullYear(date.getFullYear());
            date.setMonth(date.getMonth());
            date.setDate(date.getDate() + parseInt(optionList.ExpireDay, 10));
            $("#ExpiredDate").val(board.dateString(date).substring(0,10));
        }
    }
		
	//coviFile.fileInfos 초기화
	coviFile.fileInfos.length = 0;
			
	//File Upload 공통 컨트롤
	if ((bizSection == "Doc" && mode != 'binder') || (bizSection == "Board" && optionList.UseFile == "Y")) {					
		var imageFileOption = "false";
		
		if(bizSection == "Board" && optionList.FolderType == "Album"){
			imageFileOption = "true";
		}			
		
		$("#con_file").empty();
		
		if(mode == "migrage" || mode == "update"){
			var fileList = JSON.parse(JSON.stringify(g_messageConfig.fileList));
			coviFile.renderFileControl('con_file', {listStyle:'table', actionButton :'add', multiple : 'true', image : imageFileOption}, fileList);			
		}else{ //create, reply
			coviFile.renderFileControl('con_file', {listStyle:'table', actionButton :'add', multiple : 'true', image : imageFileOption});	
		}
		
		$("#fileDiv").show();
	} else {
		$("#fileDiv").hide();
	}
	
	$("#divNoticeMedia").hide();
	
	coviFile.option.limitFileCnt = optionList.LimitFileCnt;
	
	board.renderFileLimitInfo();
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
		 			//$("#productType").val(data.list.ProductType);
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
		 			
		 			if(data.list.ComplateCheck=="1" || data.list.ComplateCheck=="2"){
		 				$("#complateCheck").val(data.list.ComplateCheck);	
		 			}else{
		 				$("#complateCheck").val("");
		 			}
		 			
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
					if(g_messageConfig.UseMessageReadAuth == "Y"){
						//열람권한 테이블에서 조회된 데이터가 없을경우
						if(board.getMessageReadAuthCount(bizSection, messageID, folderID) > 0){
							readFlag = true;
						}
					}

					if(!readFlag){
						Common.Inform("조회 권한이 없습니다.", "Warning Dialog", function(){
							if(g_urlHistory == null){
 								g_urlHistory = "/groupware/layout/issue_IssueBoardList.do?CLSYS=board&CLMD=user&CLBIZ=Board&boardType=Total&menuID=" + Common.getBaseConfig("BoardMain");
 							}
 							CoviMenu_GetContent(g_urlHistory);
 						});
						return;
					} else {
						board.renderMessageInfoView(pBizSection, config);
						
					}
					
					//게시글 권한별 및 버튼 컨트롤 표시/숨김
					board.checkAclList();	
					
					
	 			} else if(pPageType == "Write"){
	 				if(data.list.ProductType != ""){
		 				$("[name=productType][value="+data.list.ProductType+"]").prop("checked",true);
	 				}
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

</script>
