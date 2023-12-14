<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil,egovframework.coviframework.util.RedisDataUtil,egovframework.baseframework.util.SessionHelper"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
	
	String useEasyAdmin = "N";
	if (RedisDataUtil.getBaseConfig("BoardEasyAdmin").equals("Y") && SessionHelper.getSession("isEasyAdmin").equals("Y"))
		useEasyAdmin = "Y"; 
%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<% 
	String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path");
%>
<!-- 컨텐츠앱 추가 -->
<style type="text/css">	
table {
    table-layout: auto;
}

#con_acl .authPermissions table tr td:nth-child(11) { 
	border-right: 1px dashed #ddd;
}

.cateOperator  {
	margin-top: 5px;
}

.userDefFieldTop {
	margin-top: 5px;
}

.userDefFieldBtn {
	margin-left: 5px;
}
</style>
	
<script type="text/javascript" src="/groupware/resources/script/admin/boardAdmin.js<%=resourceVersion%>"></script>
<div>
	<form id="frmBoardConfig" method="post" enctype="multipart/form-data">
		<div class="sadmin_pop">
			<ul class="tabMenu clearFloat">
				<li id="basicTab" class="active" value="basic"><a href="#"><spring:message code="Cache.lbl_chkBasicConfigYN"/></a></li> <!-- 기본설정 -->
				<c:if test="${mode ne 'create'}">
					<li id="authSettingTab" value="authSetting" style="display:none"><a href="#"><spring:message code="Cache.btn_AuthSet"/></a></li> <!-- 권한설정 -->
					<c:if test="${bizSection ne 'Doc'}">
					<li id="basicOptionTab" value="basicOption" style="display:none" ><a href="#"><spring:message code="Cache.lbl_BasicOptSet"/></a></li> <!-- 기본옵션설정 -->
					</c:if>
					<c:if test="${bizSection ne 'Community'}">
					<%if (useEasyAdmin.equals("N")){ %><li id="extOptionTab" value="extOption"  style="display:none"><a href="#"><spring:message code="Cache.lbl_ExtOptSet"/></a></li><%} %>
					</c:if>
				</c:if>
			</ul>
			<div id="searchTab_Basic" class="tabContent active">
				<table class="sadmin_table sa_menuBasicSetting">
					<colgroup>
						<col width="130px;">
						<col width="*">
						<col width="130px;">
						<col width="*">
					</colgroup>
					<tbody>
						<tr>
							<th><spring:message code="Cache.lbl_Location"/></th> <!-- 폴더 위치-->
							<td colspan="3">/<span id="folerPathName">${fn:replace(folderPathName,';','/')}</span></td>
						</tr>
						<tr>
							<th><span class="thstar">*</span><spring:message code="Cache.lbl_FolderType"/></th> <!-- 폴더유형 -->
							<td>
								<select id="folderType" name="folderType" class="selectType02"></select>
							</td>
							<th><span class="thstar">*</span><spring:message code="Cache.lbl_MenuName"/></th> <!-- 메뉴명 -->
							<td>
								<select id="selectMenuID" name="menuID" class="selectType02"></select>
							</td>
						</tr>
						<tr>
							<th><span class="thstar">*</span><spring:message code="Cache.lbl_apv_folderName"/></th> <!-- 분류명 -->
							<td colspan="3">
								<input type="text" id="folderName" name="folderName" class="menuName av-required HtmlCheckXSS ScriptCheckXSS"/>
								<a href="#" id="folderNameDicBtn" class="btnTypeDefault" style="float: right;"><spring:message code='Cache.lbl_MultiLang2'/></a> <!-- 다국어 -->
								<input id="hidFolderNameDicInfo" name="multiDisplayName" type="hidden" />
							</td>
						</tr>
						<tr>
							<th><spring:message code="Cache.lbl_IsUse"/></th> <!-- 사용여부 -->
							<td>
								<select id="selectIsUse" name="isUse" class="selectType02"></select>
							</td>
							<th><span class="thstar">*</span><spring:message code="Cache.lbl_DisplayYN"/></th> <!-- 표시유무 -->
							<td>
								<select id="selectIsDisplay" name="isDisplay" class="selectType02"></select>
							</td>
						</tr>
						<tr>
							<th><spring:message code="Cache.lbl_RegNotify"/></th> <!-- 등록 알림 -->
							<td>
								<select id="selectIsAdminNotice" name="isAdminNotice" class="selectType02"></select>
							</td>
							<th><spring:message code="Cache.lbl_MobileSupport"/></th> <!-- 모바일지원 -->
							<td>
								<select id="selectIsMobileSupport" name="isMobileSupport" class="selectType02"></select>
							</td>
						</tr>
						<tr>
							<th><spring:message code="Cache.lbl_RegNotify_Receiver"/></th> <!-- 등록 알림 수신자 -->
							<td colspan="3">
								<input type="text" id="ReceiversName" style="width: 74%" class="selectType02" readonly="readonly"/>
								<input type="hidden" id="ReceiversCode" />
								<a href="#" id="orgReceiverBtn" class="btnTypeDefault" data-target-name="ReceiversName" data-target-code="ReceiversCode" ><spring:message code="Cache.btn_Select"/></a> <!-- 선택 -->
							</td>
						</tr>
						<tr>
							<th><spring:message code="Cache.lbl_RegNotify_Excepter"/></th> <!-- 등록 알림 제외자 -->
							<td colspan="3">
								<input type="text" id="ExceptersName" style="width: 74%" class="selectType02" readonly="readonly"/>
								<input type="hidden" id="ExceptersCode" />
								<a href="#" id="orgExcepterBtn" class="btnTypeDefault" data-target-name="ExceptersName" data-target-code="ExceptersCode" ><spring:message code="Cache.btn_Select"/></a> <!-- 선택 -->
							</td>
						</tr>
					<%if (useEasyAdmin.equals("N")){ %>
						<tr>
							<th><spring:message code="Cache.lbl_SecurityLevel"/></th> <!-- 보안등급 -->
							<td colspan="3">
								<select id="securityLevel" name="securityLevel" class="selectType02"></select>
							</td>
						</tr>
					<%} %>	
						<tr>
							<th><span class="thstar">*</span><spring:message code="Cache.lbl_Operator"/></th> <!-- 운영자 -->
							<td colspan="3">
								<input type="text" id="userName" class="menuName02 av-required" style="margin-right: 0;" disabled/>
								<input type="hidden" id="ownerCode" name="ownerCode"/>
								<a href="#" id="orgOwnerBtn" class="btnTypeDefault"><spring:message code="Cache.btn_Select"/></a> <!-- 선택 -->
								<a href="#" id="initOwnerBtn" class="btnTypeDefault ml5" style="float: right;"><spring:message code="Cache.btn_init"/></a> <!-- 초기화 -->
							</td>
						</tr>
						<tr>
							<th id="thRegistDate"><spring:message code="Cache.lbl_RegistDateHour"/></th> <!-- 등록일시 -->
							<td>
								<span id="registDate"></span>
							</td>
							<th><spring:message code="Cache.lbl_Register"/></th> <!-- 등록자 -->
							<td>
								<span id="registerName"></span>
							</td>
						</tr>
						<tr>
							<th id="thtxtDescription"><spring:message code="Cache.lbl_FolderBoardDescription"/></th> <!-- 폴더 섦명 -->
							<td colspan="3">
								<textarea id="txtDescription"></textarea>
							</td>
						</tr>
						
					</tbody>
				</table>
			</div>
			<div id="searchTab_AuthSetting" class="tabContent">
				<div class="contentsAppPop">
					<div id="con_acl"></div>
				</div>
			</div>
			<div id="searchTab_BasicOption" class="tabContent">
				<div class="option_setting">
					<div class="option_setBox">
						<h3 class="cycleTitle">
							<input id="chkUseBasicConfig" name="useBasicConfig" type="checkbox" />
							<label for="chkUseBasicConfig"><span></span>	<spring:message code="Cache.lbl_BasicOption"/></label>
							<div class="collabo_help02">
								<a href="#" class="help_ico" id="btn_base_tt"></a>
							</div>
						</h3> <!-- 기본옵션 -->
						<a href="#" class="mdeps3"></a>
						<div class="option_setChk">
							<c:if test="${bizSection ne 'Community'}">
							<div class="chkStyle01">
								<input type="checkbox" id="chkUsePopNotice" name="usePopNotice"><label for="chkUsePopNotice"><span></span><spring:message code="Cache.lbl_NoticePopup"/></label> <!-- 팝업공지 -->
							</div>
							</c:if>
							<div class="chkStyle01">
								<input type="checkbox" id="chkUseTopNotice" name="useTopNotice"><label for="chkUseTopNotice"><span></span><spring:message code="Cache.lbl_NoticeTop"/></label> <!-- 상단공지 -->
							</div>
							<div class="chkStyle01">
								<input type="checkbox" id="chkUseExpiredDate" name="useExpiredDate" onclick="javascript:confirmResetExpiredDate(this);"><label for="chkUseExpiredDate"><span></span><spring:message code="Cache.lbl_ExpireDate"/></label> <!-- 만료일 -->
							</div>
							<div class="chkStyle01">
								<input type="checkbox" id="chkUseAnony" name="useAnony"><label for="chkUseAnony"><span></span><spring:message code="Cache.lbl_Anonymity"/></label> <!-- 익명 -->
							</div>
							<c:if test="${bizSection ne 'Community'}">
							<div class="chkStyle01">
								<input type="checkbox" id="chkUseSecret" name="useSecret"><label for="chkUseSecret"><span></span><spring:message code="Cache.lbl_chkSecurity"/></label> <!-- 비밀글 -->
							</div>
							</c:if>
							<div class="chkStyle01">
								<input type="checkbox" id="chkUsePrint" name="usePrint"><label for="chkUsePrint"><span></span><spring:message code="Cache.lbl_Print"/></label> <!-- 인쇄 -->
							</div>
							<div class="chkStyle01">
								<input type="checkbox" id="chkUseFile" name="useFile"><label for="chkUseFile"><span></span><spring:message code="Cache.btn_attachfile"/></label> <!-- 파일첨부 -->
							</div>
							<div class="chkStyle01">
								<input type="checkbox" id="chkUseReply" name="useReply"><label for="chkUseReply"><span></span><spring:message code="Cache.lbl_Reply"/></label> <!-- 답글 -->
							</div>
							<div class="chkStyle01">
								<input type="checkbox" id="chkUseComment" name="useComment"><label for="chkUseComment"><span></span><spring:message code="Cache.lbl_Comment2"/></label> <!-- 덧글 -->
							</div>
							<div class="chkStyle01">
								<input type="checkbox" id="chkUseFavorite" name="useFavorite"><label for="chkUseFavorite"><span></span><spring:message code="Cache.lbl_Favorite"/></label> <!-- 즐겨찾기 -->
							</div>
							<%if (useEasyAdmin.equals("N")){ %>
								<div class="chkStyle01">
									<input type="checkbox" id="chkUseTag" name="useTag"><label for="chkUseTag"><span></span><spring:message code="Cache.lbl_Tag"/></label> <!-- 태그 -->
								</div>
								<div class="chkStyle01">
									<input type="checkbox" id="chkUseLink" name="useLink"><label for="chkUseLink"><span></span><spring:message code="Cache.lbl_Link"/></label> <!-- 링크 -->
								</div>
								<div class="chkStyle01">
									<input type="checkbox" id="chkUseMessageReadAuth" name="useMessageReadAuth"><label for="chkUseMessageReadAuth"><span></span><spring:message code="Cache.lbl_MessageReadAuth"/></label> <!-- 열람권한 -->
								</div>
							<%} %>
							<div class="chkStyle01">
								<input type="checkbox" id="chkUsePubDeptName" name="usePubDeptName"><label for="chkUsePubDeptName"><span></span><spring:message code="Cache.lbl_PubDeptName"/></label> <!-- 부서명 게시 -->
							</div>
							<div class="chkStyle01">
								<input type="checkbox" id="chkUseReadCnt" name="useReadCnt"><label for="chkUseReadCnt"><span></span><spring:message code="Cache.lbl_DisplayHit"/></label> <!-- 조회수 표시 -->
							</div>
							<div class="chkStyle01">
								<input type="checkbox" id="chkUseReaderView" name="useReaderView"><label for="chkUseReaderView"><span></span><spring:message code="Cache.lbl_DisplayViewer"/></label> <!-- 조회자 표시 -->
							</div>
							<%if (useEasyAdmin.equals("N")){ %>
							<table class="sadmin_table">
								<colgroup>
									<col width="30%"/>
									<col width="20%"/>
									<col width="30%"/>
									<col width="20%"/>
								</colgroup>
								<tr>
									<th><font color="red">* </font><spring:message code="Cache.lbl_AttachCntLimit2"/></th> <!-- 첨부수 제한 -->
									<td><input type="text" id="txtLimitFileCnt" name="limitFileCnt" mode="number" allow_minus="false" style="width: 50px;"/>
										<spring:message code="Cache.lbl_Count"/><!-- 개 -->
									</td>
									<th><font color="red">* </font><spring:message code="Cache.lbl_LimitFileSize"/><p class="maxFileSize" style="margin-left: 10px;"></p></th> <!-- 1건 첨부용량 제한 -->
									<td><input type="text" id="txtLimitFileSize" name="limitFileSize" mode="number" allow_minus="false" style="width: 50px;"/>
										MB
									</td>
								</tr>
								<tr>
									<th><font color="red">* </font><spring:message code="Cache.lbl_TotalFileSize"/><p class="maxFileSize" style="margin-left: 10px;"></p></th> <!-- 총 첨부용량 제한 -->
									<td><input type="text" id="txtTotalFileSize" name="totalFileSize" mode="number" allow_minus="false" style="width: 50px;"/>
										MB
									</td>
									<th><font color="red">* </font><spring:message code="Cache.lbl_LinkCntLimit"/></th> <!-- 링크 수 제한 -->
									<td><input type="text" id="txtLimitLinkCnt" name="limitLinkCnt" mode="number" style="width: 50px;"/>
										<spring:message code="Cache.lbl_Count"/><!-- 개 -->
									</td>
								</tr>
								<tr>
									<th><font color="red">* </font><spring:message code="Cache.lbl_RecentMsgStd"/></th> <!-- 최근글 기준 -->
									<td><input type="text" id="txtRecentlyDay" name="recentlyDay" mode="number" allow_minus="false" style="width: 50px;"/>
										<spring:message code="Cache.lbl_day"/> <!-- 일 -->
									</td>
									<th><font color="red">* </font><spring:message code="Cache.lbl_ExpireDayStd"/><a href="#" id="updateExpiredDayBtn" style="display: block; margin-left: 10px; text-decoration: underline;" ><spring:message code="Cache.btn_board_updateExpired"/></a></th> <!-- 만료일 기준 -->
									<td><input type="text" id="txtExpireDay" name="expireDay" mode="number" style="width: 50px;"/>
										<spring:message code="Cache.lbl_day"/><!-- 일 -->
									</td>
								</tr>								
								<tr>
									<th><spring:message code="Cache.lbl_BodyBasicContents"/></th> <!-- 본문 기본 내용 -->
									<td colspan="3">
										<textarea rows="10" style="width: 90%" id="txtDefaultContents" name="defaultContents" class="AXTextarea HtmlCheckXSS ScriptCheckXSS"></textarea>
									</td>
								</tr>
							</table>
							<%} %>
						</div>
					</div>
					
					<%if (useEasyAdmin.equals("N")){ %>
					<div class="option_setBox">
						<h3 class="cycleTitle">
							<input id="chkAllFileExtention" name="allFileExtention" type="checkbox" />
							<label for="chkAllFileExtention"><span></span><spring:message code="Cache.lbl_UploadableExt"/></label>
							<span style="color:#888888; float:right; font-weight:500;font-size:12px"><spring:message code="Cache.lbl_UploadableExtToolTip"/></span>
						</h3> <!-- 업로드 가능한 파일 -->
						<div id="enableFileExtention" class="option_setChk"></div>
					</div>
					<%} %>
					
					<div class="option_setBox">
						<h3 class="cycleTitle"><spring:message code="Cache.lbl_AdditionOption2"/>
							<div class="collabo_help02">
								<a href="#" class="help_ico" id="btn_add_tt"></a>
							</div>
						</h3> <!-- 부가옵션 -->
						<div class="option_setChk">
							<div class="chkStyle01">
								<input type="checkbox" id="chkUseScrap" name="useScrap"><label for="chkUseScrap"><span></span><spring:message code="Cache.lbl_Scrap"/></label> <!-- 스크랩 -->
							</div>
							<div class="chkStyle01">
								<input type="checkbox" id="chkUseCopy" name="useCopy"><label for="chkUseCopy"><span></span><spring:message code="Cache.lbl_CopyOrMove"/></label> <!-- 복사/이동 -->
							</div>
							<div class="chkStyle01">
								<input type="checkbox" id="chkUseSubscription" name="useSubscription"><label for="chkUseSubscription"><span></span><spring:message code="Cache.lbl_Subscription"/></label> <!-- 구독 -->
							</div>
							<div class="chkStyle01">
								<input type="checkbox" id="chkUseIncludeRecentReg" name="useIncludeRecentReg"><label for="chkUseIncludeRecentReg"><span></span><spring:message code="Cache.lbl_IncludeRecentReg"/></label> <!-- 최근 게시 -->
							</div>
							<div class="chkStyle01">
								<input type="checkbox" id="chkUseBody" name="useBody"><label for="chkUseBody"><span></span><spring:message code="Cache.lbl_Body"/></label> <!--본문사용 -->
							</div>
							<%if (useEasyAdmin.equals("N")){ %>
								<div class="chkStyle01">
									<input type="checkbox" id="chkUseMessageAuth" name="useMessageAuth"><label for="chkUseMessageAuth"><span></span><spring:message code="Cache.lbl_MessageAcl"/></label> <!-- 메세지 권한 -->
								</div>
								<c:if test="${bizSection ne 'Community'}">
								<div class="chkStyle01">
									<input type="checkbox" id="chkUseReport" name="useReport"><label for="chkUseReport"><span></span><spring:message code="Cache.lbl_SinGo"/></label> <!-- 신고 -->
								</div>
								</c:if>
								<div class="chkStyle01">
									<input type="checkbox" id="chkUseReservation" name="useReservation"><label for="chkUseReservation"><span></span><spring:message code="Cache.lbl_ReservationReg"/></label> <!-- 예약 게시 -->
								</div>
								<c:if test="${bizSection ne 'Community'}">
									<div class="chkStyle01">
										<input type="checkbox" id="chkUseLinkedMessage" name="useLinkedMessage"><label for="chkUseLinkedMessage"><span></span><spring:message code="Cache.lbl_LinkedMessage"/></label> <!-- 게시글 연결 -->
									</div>
									<c:if test="${isUseTransferFeed eq 'Y'}">
										<div class="chkStyle01">
											<input type="checkbox" id="chkUseTransferFeed" name="useTransferFeed"><label for="chkUseTransferFeed"><span></span><spring:message code="Cache.lbl_TransferFeed"/></label> <!-- 피드 등록 -->
										</div>
									</c:if>
								</c:if>
							<%} %>
						</div>
					</div>
				</div>
			</div>
			<!-- 부가옵션 탭 시작 -->
			<div id="searchTab_ExtOption" class="tabContent">
				<div class="option_setting">
					<h3 class="cycleTitle"><spring:message code="Cache.lbl_ExtOption"/>
						<div class="collabo_help02">
							<a href="#" class="help_ico" id="btn_ext_tt"></a>
						</div>
					</h3> <!-- 확장옵션 -->
					<div class="option_setBox" >
						<div class="option_setChk">
							<c:if test="${bizSection eq 'Board'}">
							<div class="chkStyle01">
								<input id="chkUseCategory" name="useCategory" type="checkbox"/>
								<label for="chkUseCategory"><span></span><spring:message code="Cache.lbl_UseCate"/></label> <!--카테고리 사용-->
							</div>		
							<div class="chkStyle01">
								<input id="chkUseBodyForm" name="useBodyForm" type="checkbox"/>
								<label for="chkUseBodyForm"><span></span><spring:message code="Cache.lbl_BodyForm"/></label><!--본문양식-->
							</div>		
							<div class="chkStyle01">
								<input id="chkUseUserForm" name="useUserForm" type="checkbox"/>
								<label for="chkUseUserForm"><span></span><spring:message code="Cache.lbl_UserDefField"/> </label><!--사용자정의필드-->
								<input type="hidden" name="useProgressState" value=""/>
							</div>
							</c:if>
							<c:if test="${bizSection eq 'Doc'}">
							<div class="chkStyle01" ><input id="chkUseAutoDocNumber" name="useAutoDocNumber" type="checkbox" />
								<label for="chkUseAutoDocNumber"><span></span><spring:message code="Cache.lbl_autoDocNumber"/></label>
							</div> <!--문서번호 자동발번-->
							</c:if>
							<div class="chkStyle01" style="width:200px">
								<input group="chkUseProcess" id="chkUseOwnerProcess" name="useOwnerProcess" onclick="boardAdmin.checkOneByUseProcessCheckBox(this);" type="checkbox"/>
								<label for="chkUseOwnerProcess"><span></span><spring:message code="Cache.lbl_Operator"/> <spring:message code="Cache.lbl_UseSelApprovalProc"/></label>
							</div>
							<div id="divUseReplyProcess" class="chkStyle01" style="display: none;">
								<input group="chkUseReplyProcess" id="chkUseReplyProcess" name="useReplyProcess" type="checkbox"/>
								<label for="chkUseReplyProcess"><span></span><spring:message code="Cache.lbl_UseReplyProcess"/></label>
							</div>
							<div class="chkStyle01">
								<input id="chkUseBoardDescription" name="useDescription" type="checkbox"/>
								<label for="chkUseBoardDescription"><span></span><spring:message code="Cache.lbl_UseBoardDescription"/></label> <!--게시판 설명 사용-->
							</div>
						</div>
					</div>
					<div id="additionalExtOptionProperties">
					<!-- 설정한 부가 옵션에 따라 HTML 생성되는 부분 -->
						<div id="divCategory" class="option_setChk">
							<span><strong><spring:message code="Cache.lbl_Category"/></strong></span> <!--카테고리-->
							<table class="sadmin_table">
								<colgroup>
									<col width="20%">
									<col width="30%">
									<col width="50%">
								</colgroup>
								<tbody>
									<tr>
										<th><spring:message code="Cache.lbl_LCate"/></th> <!--대분류-->
										<td>
											<select id="selectLargeCategory" name="LargeCategory" class="selectType02"></select>
										</td>
										<td>	
											<input type="button" value="<spring:message code="Cache.lbl_Add"/>" id="addCategoryBtn"	class="AXButton"/>
											<input type="button" value="<spring:message code="Cache.lbl_Edit"/>" id="editCategoryBtn" class="AXButton"/>
											<input type="button" value="<spring:message code="Cache.lbl_delete"/>" id="delCategoryBtn" class="AXButton"/>											
											<div id="largeCateOperator" class="cateOperator">
												<input type="hidden" id="hidLargeCateName" />
												<input type="text" class="w80" id="hidLargeCategoryManagerName" name="hidLargeCategoryManagerName" disabled="disabled" />
												<input type="hidden" id="hidLargeCategoryManagerCode" name="hidLargeCategoryManagerCode" />
												<input type="button" value="<spring:message code="Cache.btn_charge"/>" onclick="OrgMapLayerPopup_CategoryManager('SetLargeCateOperator');" class="AXButton"/>
											</div>
										</td>
									</tr>
									<tr>
										<th><spring:message code="Cache.lbl_SCate"/></th> <!--소분류-->
										<td>
											<select id="selectSmallCategory" name="SmallCategory" class="selectType02"></select>
										</td>
										<td>
											<input type="button" value="<spring:message code="Cache.lbl_Add"/>" id="addSCategoryBtn" class="AXButton"/>
											<input type="button" value="<spring:message code="Cache.lbl_Edit"/>" id="editSCategoryBtn" class="AXButton"/>
											<input type="button" value="<spring:message code="Cache.lbl_delete"/>" id="delSCategoryBtn" class="AXButton"/>
											<div id="smallCateOperator" class="cateOperator">
												<input type="hidden" id="hidSmallCateName" />
												<input type="text" class="w80" id="hidSmallCategoryManagerName" name="hidSmallCategoryManagerName" disabled="disabled" />
												<input type="hidden" id="hidSmallCategoryManagerCode" name="hidSmallCategoryManagerCode" />
												<input type="button" value="<spring:message code="Cache.btn_charge"/>" onclick="OrgMapLayerPopup_CategoryManager('SetSmallCateOperator');" class="AXButton"/>
											</div>
										</td>
									</tr>
								</tbody>
							</table>
						</div>
						<div id="divBodyForm" class="option_setChk">
							<span><strong><spring:message code="Cache.lbl_BodyForm" /></strong> (<spring:message code="Cache.msg_DisplayInitFormonChk" /> / <spring:message code='Cache.msg_uploadBodyFormFile' />)</span> <!--본문양식--> <!--체크시 초기 작성양식으로 보여집니다.-->
							<!-- 본문양식 Display 시작 -->
							<table class="sadmin_table" cellpadding="0" cellspacing="0">
								<tr>
									<td style="Padding-top:5px;">
										<div class="topbar_grid">
											<span id="spnBodyFormList"></span>
										</div>
									</td>
								</tr>
							</table>
							<!-- 본문양식 Display 종료 -->
							<table class="sadmin_table" cellpadding="0" cellspacing="0">
								<colgroup>
									<col width="11%">
									<col width="35%">
									<col width="8%">
								</colgroup>
								<tbody>
									<tr>
										<th><spring:message code="Cache.lbl_FormNm"/></td> <!--양식명-->
										<td colspan="2">
											<input id="txtBodyFormName" name="bodyFormName" type="text" class="HtmlCheckXSS ScriptCheckXSS w80">
											<input id="hidBodyFormDicInfo" type="hidden" />
											<input type="button" value="<spring:message code='Cache.lbl_MultiLang2'/>" class="AXButton" id="formDicBtn" /><!--다국어-->
										</td>
									</tr>
									<tr>
										<th><spring:message code="Cache.lbl_FormFile"/></td> <!--명시파일-->
										<td colspan="2" id="tdUpload">
											<input type="file" id="uploadFile" accept=".txt,.htm,.html" class="w80" onchange="bodyFormCheckFileName(this.value);"/>
											<input type="button" value="<spring:message code="Cache.lbl_Add"/>" id="addFormBtn" class="AXButton"/> <!--추가-->
										</td> <!--파일업로드-->
									</tr>
								</tbody>
							</table>
							<span style="padding-top:5px"><spring:message code="Cache.msg_BodyFormMsg01"/></span>
						</div>
						<div id="divUserDefField" class="option_setChk">
							<span><strong><spring:message code="Cache.lbl_UserDefField"/></strong></span>
							<!-- 상단 버튼과 간격 조절 -->
							<div>
								<div id="userDefFieldGrid"></div>
							</div>
							<div  style="float:left; padding: 5px 0 5px 0;">
								<input type="button" value="<spring:message code='Cache.btn_UP'/>" class="AXButton" id="btnUp" /><!--순서-->
								<input type="button" value="<spring:message code='Cache.btn_Down'/>" class="AXButton" id="btnDown" /><!--순서-->
								<input type="button" value="<spring:message code='Cache.btn_ dataRemake'/>" class="AXButton" id="btnDataRemake" /><!--데이터 재생성-->
							</div>
							<div style="float:right; padding: 5px 0 5px 0;">
								<input type="button" value="<spring:message code='Cache.btn_init'/>" class="AXButton"  id="btnResetField"/><!-- 초기화 -->
								<input type="button" id="btnAddField" value="<spring:message code='Cache.btn_AddField'/>" class="AXButton" /><!-- 추가 -->
								<input type="button" id="btnEditField" value="<spring:message code='Cache.btn_EditField'/>" class="AXButton" style="display:none;" /><!-- 수정 -->
								<input type="button" id="btnDelField" value="<spring:message code='Cache.lbl_DeleteField'/>" class="AXButton" /><!-- 삭제 -->
							</div>
							<table class="sadmin_table" cellpadding="0" cellspacing="0">
								<colgroup>
									<col width="15%">
									<col width="35%">
									<col width="15%">
									<col width="35%">
								</colgroup>
								<tbody>
									<tr>
										<th><spring:message code="Cache.lbl_FieldNm"/></th>	<!--필드명-->
										<td>
											<input id="fieldName" name="fieldName" type="text" class="HtmlCheckXSS ScriptCheckXSS W60">
											<input id="hidFieldNameDicInfo" type="hidden" />
											<input type="button" value="<spring:message code='Cache.lbl_MultiLang2'/>" class="AXButton" id="btnSetDicField" /> <!--다국어-->
										</td>
										<th><spring:message code="Cache.lbl_FieldType"/></th> <!--필드 유형-->
										<td>
											<select id="fieldType" class="selectType02 W70" >
												<option value="Input">Input</option>
												<option value="TextArea">TextArea</option>
												<option value="Radio">RadioButton</option>
												<option value="CheckBox">CheckBox</option>
												<option value="DropDown">DropDownList</option>
												<option value="Date">DateField</option>
											</select>
											<span id="spanFieldLimitCnt">
												<input id="fieldLimitCnt" type="text"  mode="number" allow_minus="false" style="width:30px;"/><spring:message code="Cache.lbl_Char"/>
											</span>
										</td>
										<!-- <td><a href="javascript:UploadFrontStorageByBodyForm();" id="aUploadFrontStorageByBodyForm"><em class="btn_bs_l"><span class="btn_bs_r"><strong class="txt_btn_bs"><spring:message code="Cache.lbl_FileUpload"/></strong></span></em></a></td> -->	<!--파일업로드-->
									</tr>
									<tr id="rowFieldOption" style="display:none;">
										<th><spring:message code="Cache.lbl_FieldOpt"/></th> <!-- 필드옵션 -->
										<td colspan="3">
											<div id="optionPlaceHolder"></div>
										</td>
									</tr>
									<tr>
										<th><spring:message code="Cache.lbl_surveyIsRequire"/></th> <!-- 필수여부 -->
										<td>
											<select id="isCheckVal" class="selectType02 W100" >
												<option value="N" selected><spring:message code="Cache.lbl_NoIsRequire"/></option>
												<option value="Y"><spring:message code="Cache.lbl_apv_require"/></option>
											</select> 
										</td>
										<th><spring:message code="Cache.lbl_ViewField"/></th><!-- 필드보기 -->
										<td>
											<select id="fieldSize"  class="selectType02 W100" >
												<option value="Line">Line</option>
												<option value="Half">Half</option>
												<option value="2Line">2Line</option>
												<option value="3Line">3Line</option>
												<option value="4Line">4Line</option>
												<option value="5Line">5Line</option>
											</select>
										</td>
									</tr>
									<tr>
										<th><spring:message code="Cache.lbl_DisplayList"/></th><!-- 목록표시 -->
										<td>
											<select id="isList"  class="selectType02 W100" >
												<option value="N" selected><spring:message code="Cache.lbl_NonDisplay"/></option>
												<option value="Y"><spring:message code="Cache.lbl_Display2"/></option>
											</select>
										</td>
										<th><spring:message code="Cache.lbl_ListSearchItem"/></th><!-- 검색항목 -->
										<td>
											<select id="isSearchItem" class="selectType02 W100">
												<option value="Y"><spring:message code="Cache.lbl_Display2"/></option>
												<option value="N" selected><spring:message code="Cache.lbl_NonDisplay"/></option>
											</select>
										</td>
									</tr>
								</tbody>
							</table>
						</div>
						<!-- 승인 프로세스 설정 -->
						<div id="divApprovalProcSet" class="option_setChk">
							<span><strong><spring:message code="Cache.lbl_ApprovalProcSet"/></strong></span>
							<p style="float:right;padding-bottom:5px;">
<!--  								<input type="button" value="&lt; <spring:message code='Cache.lbl_Order'/>" class="AXButton" id="btnMoveLeftApv" />
								<input type="button" value="<spring:message code='Cache.lbl_Order'/> &gt;" class="AXButton" id="btnMoveRightApv"/>-->
								<input type="button" value="<spring:message code='Cache.lbl_Add'/>" class="AXButton" id="btnAddApv"/><!--추가-->
							</p>
							<table style="border:1px solid #d4d4d4;width:100%;" cellpadding="0" cellspacing="0" class="sadmin_table">
								<tr>
									<td>
										<div>
											<span id="spnApprovalLine" class="approval_h"><ol></ol></span>
										</div>
									</td>
								</tr>
							</table>
						</div>
						<!-- 진행상태 -->
						<div id="divProgressState" class="option_setChk">
							<span><strong><spring:message code="Cache.lbl_ProgressState"/></strong></span> <!--카테고리-->
							<table class="sadmin_table">
								<colgroup>
									<col width="20%">
									<col width="80%">
								</colgroup>
								<tbody>
									<tr>
										<td><spring:message code="Cache.lbl_ProgressState"/></td>	<!--진행상태-->
										<td>
											<select id="selectProgressState" name="ProgressState" class="AXSelect W100" ></select>
											<input type="button" value="<spring:message code="Cache.lbl_Add"/>" id="btnAddProgress"	class="AXButton"/>
											<input type="button" value="<spring:message code="Cache.lbl_Edit"/>" id="btnEditProgress"	class="AXButton"/>
											<input type="button" value="<spring:message code="Cache.lbl_delete"/>" id=btnDelProgress"	class="AXButton"/>
											<input type="hidden" id="hidProgressStateName" />
										</td>
									</tr>
								</tbody>
							</table>
						</div>
						<div id="divDescription" class="option_setChk">
							<span><strong><spring:message code="Cache.lbl_BoardDescription"/></strong></span>
							<div id="divWebEditor" class="writeEdit">
							</div>
						</div>
					</div>
				</div>
			</div>	
			<div class="bottomBtnWrap">
				<a href="#" id="btn_add" class="btnTypeDefault btnTypeBg" style="display: none;"><spring:message code="Cache.btn_Add"/></a> <!-- 추가 -->
				<a href="#" id="btn_modify" class="btnTypeDefault btnTypeBg" style="display: none;"><spring:message code="Cache.btn_Edit"/></a> <!-- 수정 -->
				<a href="#" id="btn_close" class="btnTypeDefault"><spring:message code="Cache.btn_Close"/></a> <!-- 취소 -->
			</div>
		</div>
		<input type="hidden" id="hidContentsID" value="" />	<!-- boardDescription ID -->
		<input type="hidden" id="hidUserFormID" value="" /> <!-- UserFormID -->
		<input type="hidden" id="hidProcessID" value="" />
		<input type="hidden" id="hidMemberOf" value="" />
	</form>
</div>

<script type="text/javascript">

var bizSection = "${bizSection}";
var mode = "${mode}";
var folderID = "${folderID}"; // Create모드: 상위 폴더의 ID, Edit모드: 현재 선택된 게시판의 FolderID
var menuID = "${menuID}";
var communityID = "${CommunityID}";
var domainID = "${domainID}";
var isContentsApp = "${isContentsApp}";
var allBoardConfig = ${allBoardConfig};

var userDefFieldGrid = new coviGrid();
var lang = Common.getSession("lang");

var g_aclList = ""; 		// 권한 설정 ACL List, 추후 팝업호출시 해당 폴더의 권한 정보 조회
var g_optionIndex = "";		// 사용자 정의 필드 옵션을 다국어 처리하기 위한 전역 변수
var g_isRoot = false;
var g_isInherited = false;	// 권한 상속 여부
var g_hasChild = false;		// 자식 객체 존재 여부

var setSelect = function(){
	// 기본설정탭 - 메뉴
	if(communityID){
		$("#selectMenuID").coviCtrl(
			"setSelectOption",
			"/groupware/board/manage/selectManageMenuList.do",
			{communityID: communityID, bizSection: bizSection},
			"<spring:message code='Cache.lbl_selectMenu'/>", // 메뉴 선택
			""
		).val(communityID);
	}else{
		$("#selectMenuID").coviCtrl(
			"setSelectOption",
			"/groupware/board/manage/selectManageMenuList.do",
			{"domainID": domainID, "bizSection": bizSection},
			"<spring:message code='Cache.lbl_selectMenu'/>", // 메뉴 선택
			""
		).val(menuID);
	}
	// 기본설정탭 - 폴더타입
	var folderTypeList = ${folderTypeList};
	var $fragment = $(document.createDocumentFragment());
	
	folderTypeList.forEach(function(item){
		$fragment.append($("<option/>", {"value": item.optionValue, "text": item.optionText}));
	});
	
	$("#folderType").append($fragment);
	
	// 기본설정탭 - 메시지보안, 표시/사용/등록알림/공유/모바일지원/연결URL/상속여부
	$fragment = $(document.createDocumentFragment());
	
	$fragment.append($("<option/>", {"value": "Y", "text": "<spring:message code='Cache.lbl_Use'/>"}))
			 .append($("<option/>", {"value": "N", "text": "<spring:message code='Cache.lbl_NotUse'/>"}));
	
	$("select[id^=selectIs]").append($fragment);
	
	// 기본설정탭 - 보안등급
	$("#securityLevel").coviCtrl("setSelectOption", "/groupware/board/selectSecurityLevelList.do");
}

var setEvent = function(){
	// 폴더명
	$("#folderName, #folderNameDicBtn").on("click", function(){
		dictionaryLayerPopup('', $('#folderName'), $('#hidFolderNameDicInfo'));
	});
	
	//등록알림수신, 제외자 
	$("#orgReceiverBtn, #orgExcepterBtn").on("click", function(){
		OrgMapLayerPopup(this, 'addTarget_Callback', 'D9')
	});
	
	// 운영자
	$("#orgOwnerBtn").on("click", function(){
		OrgMapLayerPopup_Owner();
	});
	
	$("#initOwnerBtn").on("click", function(){
		initOwnerCode();
	});
	
	// 연결 URL
	$("#selectIsURL").on("change", function(){
		boardAdmin.changeIsUrl(this);
	});
	
	$("#chkUseBasicConfig").on("click", function(){
		selectDefaultConfig();
	})
	
	// 대분류 카테고리
	$("#selectLargeCategory").on("change", function(){
		var largeCategoryManagerCode = $("#selectLargeCategory").val() ? $("#selectLargeCategory").val().split("|")[2] : "";
		selectCategoryManagerName(largeCategoryManagerCode, "hidLargeCategoryManagerName");
		$("#hidLargeCategoryManagerCode").val(largeCategoryManagerCode);
		selectSmallCategoryList();
	});
	
	// 소분류 카테고리
	$("#selectSmallCategory").on("change", function(){
		var smallCategoryManagerCode = $("#selectSmallCategory").val() ? $("#selectSmallCategory").val().split("|")[2] : "";
		selectCategoryManagerName(smallCategoryManagerCode, "hidSmallCategoryManagerName");
		$("#hidSmallCategoryManagerCode").val(smallCategoryManagerCode);
	});
	
	$("#addCategoryBtn").on("click", function(){
		dictionaryLayerPopup('create', $('#selectLargeCategory'), $('#hidLargeCateName'));
	});
	
	$("#editCategoryBtn").on("click", function(){
		editLargeCategory();
	});
	
	$("#delCategoryBtn").on("click", function(){
		deleteCategory($('#selectLargeCategory'));
	});
	
	$("#addSCategoryBtn").on("click", function(){
		createSmallCategory();
	});
	
	$("#editSCategoryBtn").on("click", function(){
		editSmallCategory();
	});
	
	$("#delSCategoryBtn").on("click", function(){
		deleteCategory($('#selectSmallCategory'));
	});
	
	// 본문 양식
	$("#formDicBtn").on("click", function(){
		dictionaryLayerPopup('', $('#txtBodyFormName'), $('#hidBodyFormDicInfo'));
	});
	
	$(document).on('click','#addFormBtn',function(){
		createBodyForm();
	});
	
	// 사용자 정의 필드
	$("#btnUp").on("click", function(){
		moveUserDefField('up');
	});
	
	$("#btnDown").on("click", function(){
		moveUserDefField('down');
	});
	
	$("#btnDataRemake").on("click", function(){
		Common.Confirm(Common.getDic("msg_remakeUserDefField"), 'Confirmation Dialog', function(result){ // 목록에 표시되는 필드 데이터를 재조합합니다.데이터 재생성하시겠습니까?
			if (result) {
				$.ajax({
					type: "POST",
					url: "/groupware/admin/dataRemakeUserDefField.do",
					dataType: 'json',
					data: {
						"folderID": folderID
					},
					success: function(data){
						if(data.status=='SUCCESS'){
							Common.Inform(Common.getDic("msg_createSuccess")); //생성되었습니다.
						}else{
							Common.Warning(Common.getDic("msg_apv_030")); // 오류가 발생헸습니다.
						}
					},
					error: function(response, status, error){
						CFN_ErrorAjax("/groupware/board/admin/dataRemakeUserDefField.do", response, status, error);
					}
				});
			}
		});
	});
	
	$("#btnResetField").on("click", function(){
		resetUserDefField();
	});
	
	$("#btnAddField").on("click", function(){
		setUserDefField('create');
	});
	
	$("#btnEditField").on("click", function(){
		setUserDefField('edit');
	});
	
	$("#btnDelField").on("click", function(){
		deleteUserDefField();
	});
	
	$("#btnSetDicField").on("click", function(){
		dictionaryLayerPopup('', $('#fieldName'), $('#hidFieldNameDicInfo'));
	});
	
	$("#fieldType").on("change", function(){
		boardAdmin.changeFieldType(this);
	});
	
	// 승인 프로세스
	$("#btnMoveLeftApv").on("click", function(){
		moveLeftApprover();
	});
	
	$("#btnMoveRightApv").on("click", function(){
		moveRightApprover();
	});
	
	$("#btnAddApv").on("click", function(){
		OrgMapLayerPopup_approvalLine();
	});
	
	// 진행상태
	$("#btnAddProgress").on("click", function(){
		dictionaryLayerPopup('create', $('#selectProgressState'), $('#hidProgressStateName'));
	});
	
	$("#btnEditProgress").on("click", function(){
		dictionaryLayerPopup('edit', $('#selectProgressState'), $('#hidProgressStateName'));
	});
	
	$("#btnDelProgress").on("click", function(){
		deleteProgressState($('#selectProgressState'));
	});
	
	// 탭 클릭 이벤트 설정
	$(".tabMenu li").on("click", function(){
		$(".tabMenu li").removeClass("active");
		$(this).addClass("active");
		
		var str = $(this).attr("value");
		
		if(str == "basic") {
			$("#searchTab_Basic").show();	
			$("#searchTab_AuthSetting").hide();
			$("#searchTab_BasicOption").hide();
			$("#searchTab_ExtOption").hide();
			$("#btn_preview").hide();
		}else if(str == "authSetting") {
			$("#searchTab_Basic").hide();	
			$("#searchTab_AuthSetting").show();
			$("#searchTab_BasicOption").hide();
			$("#searchTab_ExtOption").hide();
			$("#btn_preview").hide();
		}else if(str == "basicOption") {
			$("#searchTab_Basic").hide();	
			$("#searchTab_AuthSetting").hide();
			$("#searchTab_BasicOption").show();
			$("#searchTab_ExtOption").hide();
			$("#btn_preview").hide();
		}else if(str == "extOption") {
			$("#searchTab_Basic").hide();
			$("#searchTab_AuthSetting").hide();
			$("#searchTab_BasicOption").hide();
			$("#searchTab_ExtOption").show();
			
			if($("#chkUseBoardDescription").prop("checked")){
				if(coviEditor.getBodyText(g_editorKind, 'tbContentElement') == "" && escape(coviEditor.getImages(g_editorKind, 'tbContentElement')) == ""){
					setEditor();	
					selectBoardDescription();
				}
			}

			if($("#chkUseUserForm").prop("checked")){
				userDefFieldGrid.init();
			}
			$("#btn_preview").show();
		}
	});
	
	// 만료일 체크박스 선택시 0,90 기본값 설정
	$("#chkUseExpiredDate").on("click", function(){
		//boardAdmin.clickUseExpireDate();
	});	

	// 만료일자 일괄 수정 (만료되지 않은 게시글)
	$("#updateExpiredDayBtn").on("click", function(){	/*만료되지 않은 게시물들의 만료일이 일괄 변경됩니다. 변경하시겠습니까?*/
		var sExpireDay = $("#txtExpireDay").val();
		if(sExpireDay == 0){
			sExpireDay = Common.getDic("lbl_permanence");
		}
		Common.Confirm(Common.getDic("msg_board_updateExpiredConfirm").replace("{0}", sExpireDay), "Confirmation Dialog", function(result){
			if(result){
				$.ajax({
			    	type:"POST",
			    	url: "/groupware/admin/updateExpiredDay.do",
			    	dataType : 'json',
			    	data: {
			    		"expireDay" : $("#txtExpireDay").val(),
			    		"folderID": folderID
			    		},
			    	success:function(data){
			    		if(data.status=='SUCCESS'){
			    			Common.Inform("<spring:message code='Cache.msg_Changed'/>");
			    		}else{
			    			Common.Warning("<spring:message code='Cache.msg_ErrorOccurred'/>");
			    		}
			    	}, 
			  		error:function(error){
			  			Common.Warning("<spring:message code='Cache.msg_ErrorOccurred'/>");
			  		}
			    	
			    });
			}
		});
	});
	
	// 만족도 체크박스 이벤트 선택시 원본글,답글 체크박스 표시/숨김처리
	$("#chkUseSatisfaction").on("click", function(){
		boardAdmin.enDisableSatisfactionField(this);
	});
	
	// 만족도 - 원본글, 답글 만족도 체크박스 이벤트 
	$("[group=chkUseSatisfaction]").on("click", function(){
		boardAdmin.checkOneByUseSatisfactionBox(this);
	});
	
 	$("#searchTab_ExtOption [id^=chk]").on("click", function(e){
 		boardAdmin.enDisableExtOptionField(e.target);
 	});
	
	$("#folderName").on("change", function(){
		var sDictionaryInfo = '';
		
		switch (lang.toUpperCase()) {
			case "KO": sDictionaryInfo = this.value + ";;;;;;;;;"; break;
			case "EN": sDictionaryInfo = ";" + this.value + ";;;;;;;;"; break;
			case "JA": sDictionaryInfo = ";;" + this.value + ";;;;;;;"; break;
			case "ZH": sDictionaryInfo = ";;;" + this.value + ";;;;;;"; break;
			case "E1": sDictionaryInfo = ";;;;" + this.value + ";;;;;"; break;
			case "E2": sDictionaryInfo = ";;;;;" + this.value + ";;;;"; break;
			case "E3": sDictionaryInfo = ";;;;;;" + this.value + ";;;"; break;
			case "E4": sDictionaryInfo = ";;;;;;;" + this.value + ";;"; break;
			case "E5": sDictionaryInfo = ";;;;;;;;" + this.value + ";"; break;
			case "E6": sDictionaryInfo = ";;;;;;;;;" + this.value; break;
		}
		
		document.getElementById("hidFolderNameDicInfo").value = sDictionaryInfo;
	});
	
	$("#btn_add, #btn_modify").on("click", function(){
		setBoardConfig();
	});
	
	$("#btn_close").on("click", function(){
		Common.Close();
	});
		
	// 업로드 가능 확장자 전체 체크/해제
	$("#chkAllFileExtention").on("change", function(){
		var chkAllFileExtention = $(this).is(':checked');
		
		if(chkAllFileExtention) {
			$("#enableFileExtention input[type=checkbox]").prop('checked', true);			
		} else {
			$("#enableFileExtention input[type=checkbox]").each(function () {
				if(!$(this).prop("disabled")) {
					$(this).prop('checked', false);		
				}
			});
		}
	});
	
	$(document).on("click", "#enableFileExtention input[type=checkbox]", function(){	    
		if($("#enableFileExtention input[type=checkbox]:not(:checked)").length == 0) {
			$("#chkAllFileExtention").prop('checked', true);
		} else {
			$("#chkAllFileExtention").prop('checked', false);
		}
	});
}

var initCreate = function(){
	if (folderID != ""){
		$("#folderType").val("Folder").prop("selected", true);
		boardAdmin.changeFolderTypeSetDefault();
		
		$("#folderType option[value='Root']").remove();
		$("#folderType option[value='DocRoot']").remove();
	} else {
		$.each($("#folderType").find("option"), function(idx, item) {
			var $opt = $(item);
			var optValue = $opt.val();
			
			if(!optValue.endsWith("Root")) {
				$opt.remove();
			}
		});
		
		if(Common.getBaseConfig('useDocMultiCategory', domainID) != "Y") {
			$("#folderType option[value='DocRoot']").remove();	
		}
	}
	
	var default_security = Common.getBaseConfig('DefaultSecurityLevel', domainID);
	$("#securityLevel").val(default_security);
	$("#selectIsAdminNotice, #selectIsMobileSupport").val("N");
	
	$("#btn_add").show();
	$("#btn_modify").hide();
	
	$("#userName").val(Common.getSession("USERNAME"));
	$("#ownerCode").val(Common.getSession("USERID") + ";");
}
	
var initEdit = function(){
	$("#authSettingTab").show();
	$("#basicOptionTab").show();	//기본옵션 탭 표시
	
	//컨텐츠 앱 화면에서 접근시 권한설정 탭 숨김
	if(isContentsApp == "Y") $("#authSettingTab").hide();
	
	$("#btn_add").hide();
	$("#btn_modify").show();
	
	selectBoardConfig(); 				// 폴더 옵션 조회
	renderACL($("#folderType").val()); 	// 권한 설정 탭 내부 오브젝트 표시
	checkIsInherit(); 					// 권한 아이템 조회
	
	if($("#folderType").val() != "QuickComment"){
		$("#con_acl .authPermissions table tr td:nth-child(4)").css("border-right", "");
		$("#con_acl .authPermissions table tr td:nth-child(5)").css("border-right", "");
		$("#con_acl .authPermissions table tr td:nth-child(11)").css("border-right", "1px dashed #ddd");
	} else {
		$("#con_acl .authPermissions table tr td:nth-child(4)").css("border-right", "1px dashed #ddd");
		$("#con_acl .authPermissions table tr td:nth-child(5)").css("border-right", "1px dashed #ddd");
		$("#con_acl .authPermissions table tr td:nth-child(11)").css("border-right", "");
	}
	
	boardAdmin.enDisableExtOptionField();
	//boardAdmin.disabledBoardOptByFolderType($("#folderType"));
	$("#selectMenuID").prop("disabled", true);
	
	//폴더 타입 변경 이벤트 바인딩
	$("#folderType").on("change", function(){
		boardAdmin.changeFolderType(this);
		boardAdmin.changeFolderTypeSetDefault();
		setEnableFileExtention($(this).val());

		if(mode === "edit" && $(this).val() === "Doc"){
			$('#basicOptionTab').attr('disabled', false).show();
		}
		
		// 폴더 타입에 따른 권한 설정 값 변경 (한줄 게시판일 경우 조회권한만 설정할 수 있도록 한다)
		renderACL($(this).val());
		checkIsInherit();
		
		if($(this).val() != "QuickComment"){
			$("#con_acl .authPermissions table tr td:nth-child(4)").css("border-right", "");
			$("#con_acl .authPermissions table tr td:nth-child(5)").css("border-right", "");
			$("#con_acl .authPermissions table tr td:nth-child(11)").css("border-right", "1px dashed #ddd");
		} else {
			$("#con_acl .authPermissions table tr td:nth-child(4)").css("border-right", "1px dashed #ddd");
			$("#con_acl .authPermissions table tr td:nth-child(5)").css("border-right", "1px dashed #ddd");
			$("#con_acl .authPermissions table tr td:nth-child(11)").css("border-right", "");
		}
	});
	
	// 하위 폴더의 권한에 해당 폴더의 권한이 일괄적 적용
	$("#checkIsSubfolderInherited").off("change").on("change", function(){
        if($("#checkIsSubfolderInherited").is(":checked")){
        	Common.Inform("<spring:message code='Cache.msg_useAuthInherited'/>"); // 권한 상속 사용 시 하위 폴더의 권한에 해당 폴더의 권한이 일괄적으로 저장됩니다.
        }
    });
	
	//최상위 폴더를 수정하는 팝업일경우 변경 불가능하게 Disabled 처리 
	if($("#folderType").val() == "Root" || $("#folderType").val() == "DocRoot"){
		$("#folderType").bindSelectDisabled(true);
		$("#basicOptionTab").hide();
		$("#extOptionTab").hide();
	} else if($("#folderType").val() == "Folder"){
		$("#basicOptionTab").hide();
		$("#extOptionTab").hide();
	}else{
		$("#extOptionTab").show(); // 확장 옵션 탭 표시
	}
	
	if ($("#folderType").val() == "Root" || $("#folderType").val() == "DocRoot"){
		$("#folderType option[value='Doc']").remove();
		$("#folderType option[value='Folder']").remove();
		
		if(Common.getBaseConfig('useDocMultiCategory', domainID) != "Y") {
			$("#folderType option[value='DocRoot']").remove();	
		}
	} else {
		$("#folderType option[value='Root']").remove();
		$("#folderType option[value='DocRoot']").remove();
	}
}

//권한 설정 탭 내부 UI 표시
var renderACL = function(folderType){	
	var option = {
		lang : lang, 
		hasItem : 'false', 
		allowedACL : (folderType == "QuickComment") ? "_____V_" : "",
		initialACL : (folderType == "QuickComment") ? "_____V_" : "",
		orgMapCallback : 'orgCallback',
		aclCallback : 'aclCallback',
		communityId : communityID,
		orgGroupType : "Basic|Board",
		useUpdateChildren : Common.getBaseConfig("useBoardInherited"),
		systemType : "Board",
		objectID : folderID,
		objectType : "FD"
	};
	
	option["useInherited"] = true;
	option["inheritedFunc"] = "selectInheritedACL";
	coviACL = new CoviACL(option);
	coviACL.render('con_acl');

	$("#con_acl_divControls [type=button]").hide();	 // 사용하지 않는 버튼 숨김처리
}

//화면에 설정된 ACL 데이터 출력
var aclCallback = function(data){
	g_aclList = data;
}

//상위 권한 상속
var selectInheritedACL = function(){
	$.ajax({
		url: "/groupware/board/manage/selectBoardACLData.do",
		type: "POST",
		async: false,
		data: {
			  "objectID": $("#hidMemberOf").val()
			, "objectType": "FD"
			, "folderType" : $("#folderType").val()
			, "menuID": $("#selectMenuID").val()
		},
		success: function(res){
			if (res.status === "SUCCESS") {
				var aclList = [];
				var exAclList = JSON.parse(coviACL_getACLData("con_acl").aclData);
				
				$(res.data).each(function(idx, item){
					var exist = exAclList.map(function(exAcl){
						return exAcl.SubjectCode === item.SubjectCode;
					});
					
					// 있는 경우 상속 받은 권한으로 덮어쓴다
					if (exist.includes(true)) {
						// con_acl
						$(".aclSubject").each(function(i, tr) {							
							if($(tr).attr("objectcode") == item.SubjectCode) {
								coviACL_setDelInfo($(tr));
								$(tr).remove();
							}
						});
						
						coviACL_deleteACLBySubject("con_acl", item.SubjectCode);
					} 
					
					var acl = {
						  "AN": item.SubjectCode
						, "DN_Code": item.CompanyCode
						, "AclList": item.AclList
						, "Security": item.Security
						, "Create": item.Create
						, "Delete": item.Delete
						, "Modify": item.Modify
						, "Execute": item.Execute
						, "View": item.View
						, "Read": item.Read
						, "IsSubInclude" : item.IsSubInclude
					};
					
					if (item.SubjectType === "UR") {
						acl["itemType"] = "User";
						acl["DN"] = item.MultiSubjectName;
					} else {
						acl["itemType"] = "Group";
						acl["GroupName"] = item.MultiSubjectName;
						acl["GroupType"] = item.GroupType;
					}
					
					aclList.push(acl);					
				});
				
				var jsonData = {"item": aclList, "isInHerited": true, "inheritedObjectID": $("#hidMemberOf").val()};
				
				// 모든 하이라이트 해제
				$('.aclSubject').css("background-color", "inherit");
				$('.aclSubject').removeAttr("data-clicked");
				
				coviACL.addSubjectRow(JSON.stringify(jsonData));
				setAuthSetting(jsonData.item);
			}
		},
		error: function(error){
			CFN_ErrorAjax("/groupware/board/manage/selectBoardACLData.do", response, status, error);
		}
	});
}

var checkIsInherit = function(){
	$("#con_acl_hTbdPermissions").html("");
	g_aclList = "";
	
	//권한 표시항목 및 aclList변수 초기화
	selectBoardACLData();
}

// 조직도 Callback
var orgCallback = function(data){
	var orgJson = $.parseJSON(data);
	var bCheck = false;
	var sObjectType = "";
	var sObjectType_A = "";
	var sObjectTypeText = "";
	var sCode = "";
	var sDNCode = "";
	var sDisplayName = "";
	
	// 모든 하이라이트 해제
	$('.aclSubject').css("background-color", "inherit");
	$('.aclSubject').removeAttr("data-clicked");
	
	$.each(orgJson.item, function(i, item){
		sObjectType = item.itemType;
		
		if(sObjectType.toUpperCase() == "USER"){ //사용자
			sObjectTypeText = "사용자";
			sObjectType_A = "UR";
			sCode = item.AN;		//UR_Code
			sDNCode = item.ETID; 	//DN_Code
			sDisplayName = CFN_GetDicInfo(item.DN, lang);
		}else{ //그룹
			switch(item.GroupType.toUpperCase()){
	  			case "AUTHORITY":
	                sObjectTypeText = "권한";
	                sObjectType_A = "GR";
	                break;
	  			case "COMMUNITY":
	                sObjectTypeText = "커뮤니티";
	                sObjectType_A = "GR";
	                break;
	  			case "COMPANY":
	                 sObjectTypeText = "회사";
	                 sObjectType_A = "CM";
	                 break;
	             case "JOBLEVEL":
	                 sObjectTypeText = "직급";
	                 sObjectType_A = "GR";
	                 break;
	             case "JOBPOSITION":
	                 sObjectTypeText = "직위";
	                 sObjectType_A = "GR";
	                 break;
	             case "JOBTITLE":
	                 sObjectTypeText = "직책";
	                 sObjectType_A = "GR";
	                 break;
	             case "MANAGE":
	                 sObjectTypeText = "관리";
	                 sObjectType_A = "GR";
	                 break;
	             case "OFFICER":
	                 sObjectTypeText = "임원";
	                 sObjectType_A = "GR";
	                 break;
	             case "DEPT":
	                 sObjectTypeText = "부서";
	                 sObjectType_A = "GR";
	                 break;
	             default:
	                 sObjectTypeText = "그룹";
	                 sObjectType_A = "GR";
	                 break;
	     	}
			
			sCode = item.AN;
			sDisplayName = CFN_GetDicInfo(item.GroupName);
			sDNCode = item.DN_Code;
		}
		
		bCheck = false;
		
		$('#con_acl_hTbdPermissions').find('tr').each(function(){
			if (($(this).attr("objecttype_a").toUpperCase() == sObjectType_A.toUpperCase()) && ($(this).attr("objectcode") == sCode)) {
				bCheck = true;
			}
		});
		
		if(!bCheck){
			var jsonData = JSON.stringify({"item": item});
			coviACL.addSubjectRow(jsonData);
		}else{
			Common.Error("<spring:message code='Cache.ACC_msg_existItem'/>"); // 이미 추가된 항목입니다.
		}
	});
	
	setAuthSetting(orgJson.item);
}

// 담당자 지정
var ownerAdd_CallBack = function(orgData){
	var ownerJSON =	$.parseJSON(orgData);
	var ownerName = "";
	var ownerCode = "";
	
	$(ownerJSON.item).each(function(i, item){
		sObjectType = item.itemType;
		if(sObjectType.toUpperCase() == "USER"){ //사용자
			ownerName += CFN_GetDicInfo(item.DN) + ", ";
			ownerCode += item.UserCode + ";";
		}
	});
	
	if(ownerCode.length > 0){
		ownerName = ownerName.substring(0, ownerName.length - 2);
	}
	
	$("#userName").val(ownerName);
	$("#ownerCode").val(ownerCode);
}

// 대분류 담당자 변경
var largeCategoryManagerAdd_CallBack = function(orgData){
	var ownerJSON =	$.parseJSON(orgData);
	var ownerName = "";
	var ownerCode = "";
	
	$(ownerJSON.item).each(function(i, item){
		sObjectType = item.itemType;
		if(sObjectType.toUpperCase() == "USER"){ //사용자
			ownerName += CFN_GetDicInfo(item.DN) + ", ";
			ownerCode += item.UserCode + ";";
		}
	});
	
	if(ownerCode.length > 0){
		ownerName = ownerName.substring(0, ownerName.length - 2);
	}
	
	var idx = $("#selectLargeCategory option").index($("#selectLargeCategory option:selected"));
	var categoryID = $("#selectLargeCategory").val() ? $("#selectLargeCategory").val().split("|")[0] : "";
	var categoryManagerCode = ownerCode;
	
	$.ajax({
		type: "POST",
		url: "/groupware/board/manage/updateCategoryManager.do",
		dataType: 'json',
		async: false,
		data: {
			  "categoryID": categoryID
			, "categoryManagerCode": categoryManagerCode
		},
		success: function(res){
			selectLargeCategoryList();
			$('#selectLargeCategory option:eq('+idx+')').prop('selected', true);			
			$("#hidLargeCategoryManagerName").val(ownerName);
			$("#hidLargeCategoryManagerCode").val(ownerCode);
		}, 
		error: function(response, status, error){
			CFN_ErrorAjax("/groupware/board/manage/selectBoardACLData.do", response, status, error);
		}
	});
}

// 소분류 담당자 변경
var smallCategoryManagerAdd_CallBack = function(orgData){
	var ownerJSON =	$.parseJSON(orgData);
	var ownerName = "";
	var ownerCode = "";
	
	$(ownerJSON.item).each(function(i, item){
		sObjectType = item.itemType;
		if(sObjectType.toUpperCase() == "USER"){ //사용자
			ownerName += CFN_GetDicInfo(item.DN) + ", ";
			ownerCode += item.UserCode + ";";
		}
	});
	
	if(ownerCode.length > 0){
		ownerName = ownerName.substring(0, ownerName.length - 2);
	}
	
	var idx = $("#selectSmallCategory option").index($("#selectSmallCategory option:selected"));
	var categoryID = $("#selectSmallCategory").val() ? $("#selectSmallCategory").val().split("|")[0] : "";
	var categoryManagerCode = ownerCode;
	
	$.ajax({
		type: "POST",
		url: "/groupware/board/manage/updateCategoryManager.do",
		dataType: 'json',
		async: false,
		data: {
			  "categoryID": categoryID
			, "categoryManagerCode": categoryManagerCode
		},
		success: function(res){
			selectSmallCategoryList();
			$('#selectSmallCategory option:eq('+idx+')').prop('selected', true);			
			$("#hidSmallCategoryManagerName").val(ownerName);
			$("#hidSmallCategoryManagerCode").val(ownerCode);
		}, 
		error: function(response, status, error){
			CFN_ErrorAjax("/groupware/board/manage/selectBoardACLData.do", response, status, error);
		}
	});
}

// 권한 조회
var selectBoardACLData = function(){
	$.ajax({
		type: "POST",
		url: "/groupware/board/manage/selectBoardACLData.do",
		dataType: 'json',
		async: false,
		data: {
			  "objectID": folderID
			, "objectType": "FD"
		},
		success: function(res){
			$("#con_acl_hTbdPermissions").html("");
			coviACL.set(res.data);
		}, 
		error: function(response, status, error){
			CFN_ErrorAjax("/groupware/board/manage/selectBoardACLData.do", response, status, error);
		}
	});
}

// 담당자 이름 조회
var selectBoardOwnerName = function(pOwnerCode){
	$.ajax({
		type: "POST",
		url: "/groupware/board/manage/selectBoardOwnerName.do",
		dataType: 'json',
		async: false,
		data: {
			"ownerCode": pOwnerCode
		},
		success: function(data){
			if(data.status === "SUCCESS" && data.list){
				var ownerName = "";
				
				$(data.list).each(function(i, item){
					ownerName += CFN_GetDicInfo(item.MultiDisplayName) + ", ";
				});
				
				ownerName = ownerName.substring(0, ownerName.length-2);
				$("#userName").val(ownerName);
			}
		}, 
		error: function(response, status, error){
			CFN_ErrorAjax("/groupware/board/manage/selectBoardOwnerName.do", response, status, error);
		}
	});
}

//분류별 담당자 이름 조회
var selectCategoryManagerName = function(pOwnerCode, pCateOperator){	
	if(pOwnerCode == "") {
		$("#"+pCateOperator).val("");
	} else {
		$.ajax({
			type: "POST",
			url: "/groupware/board/manage/selectBoardOwnerName.do",
			dataType: 'json',
			async: false,
			data: {
				"ownerCode": pOwnerCode
			},
			success: function(data){
				if(data.status === "SUCCESS" && data.list){
					var ownerName = "";
					
					$(data.list).each(function(i, item){
						ownerName += CFN_GetDicInfo(item.MultiDisplayName) + ", ";
					});
					
					ownerName = ownerName.substring(0, ownerName.length-2);
					$("#"+pCateOperator).val(ownerName);
				}
			}, 
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/board/manage/selectBoardOwnerName.do", response, status, error);
			}
		});
	}
}

var selectBoardConfig = function(){
	$.ajax({
		type: "POST",
		url: "/groupware/board/manage/selectBoardConfig.do",
		dataType: 'json',
		async: false,
		data: {
			"folderID": folderID,
			"domainID": domainID
		},
		success: function(data){
			var config = data.config;
			
			g_isRoot = (config.FolderType === "Root" || config.FolderType === "DocRoot");
			g_isInherited = config.IsInherited == "Y" ? true : false;
			g_hasChild = config.hasChild == "Y" ? true : false;
			
			$("#hidMemberOf").val(config.MemberOf);
			$("#folderType").val(config.FolderType);
			$("#selectMenuID").val(config.MenuID);
			
			if(config.FolderType == "Root" || config.FolderType == "DocRoot") {
				$("#folderType").prop("disabled", true);
			}
			
			// 폴더 타입에 따라 탭 표시여부 변경
	    	boardAdmin.changeFolderType($("#folderType"), config);
			
			
			//게시판 기본 설정을 사용하지 않는 경우 체크 처리
			if(Common.getBaseConfig('UseBoardDefaultSetting') != 'Y'){
				//조회된 정보로 화면에 이벤트 셋팅
				for(var key in config) {
					//Use로 시작되는 항목은 전부 체크박스 처리
					if (/^Use/.test(key)) {
						config[key] == "Y" ? $("#chk" + key).prop('checked', true) : $("#chk" + key).prop('checked', false);
						$("#chk"+key).attr("data-value", config[key]);
					} else if (/^Is/.test(key)) {
						//is로 시작되는 항목은 전부 selectbox처리
						$("#select" + key).val(config[key] + "");
					} else if (/FileSize$/.test(key)) {
						//FileSize로 끝나는 항목 용량 변환 처리
						$("#txt" + key).val(config[key] != 0 ? convertToMegaBytes(config[key]) : convertToMegaBytes(config["FileSize"]));
					} else if (key == "EnableFileExtention"){
						// 업로드 가능한 파일 체크박스 표시
						setEnableFileExtention(config.FolderType);
						
						// 업로드 가능한 파일 체크박스 처리
						var enableFileExtentionArr = config[key] == "" ? Common.getBaseConfig('EnableFileExtention').split(",") : config[key].split(",");
						
						if(config.FolderType == "Album"){
							enableFileExtentionArr = config[key] == "" ? Common.getBaseConfig('EnableFileImageExtention').split(",") : config[key].split(",");
						}
						
						for(var i = 0; i < enableFileExtentionArr.length; i++) {
							$("#chk_" + enableFileExtentionArr[i]).prop('checked', true);
						}
						
						if($("#enableFileExtention input[type=checkbox]:not(:checked)").length == 0) {
							$("#chkAllFileExtention").prop('checked', true);
						} else {
							$("#chkAllFileExtention").prop('checked', false);
						}
					} else {
						$("#txt" + key).val(config[key]);
					}
				}
			}
			
			// 최대 설정 가능한 용량 표시
			$(".maxFileSize").text(Common.getDic("lbl_MaxFileSize").replace("{0}", coviFile.convertFileSize(config["FileSize"])));
			
			//다국어 표시명이 없을 경우 분기 처리
			var displayName = CFN_GetDicInfo(config.MultiDisplayName);	
			if(displayName && displayName != "undefined"){
				$("#hidFolderNameDicInfo").val(config.MultiDisplayName);
				$("#folderName").val(displayName);
			} else {
				$("#folderName").val(config.DisplayName);
			}
			
			$("#thRegistDate").text($("#thRegistDate").text() + Common.getSession("UR_TimeZoneDisplay"));
			$("#ownerCode").val(config.OwnerCode);
			$("#registDate").text(CFN_TransLocalTime(config.CreateDate));
			$("#registerName").text(CFN_GetDicInfo(config.RegisterName));
			$("#description").val(config.Description);
			$("#securityLevel").val(config.SecurityLevel);
			
			if(config.OwnerCode != ""){ // 담당자가 설정됐을 경우 담당자 이름 검색하여 표시
				selectBoardOwnerName(config.OwnerCode);
			}
			
			if(config.IsURL == "Y"){ // 연결URL 사용시 URL값 설정
				$("#linkURL").val(config.URL);
			}
			
			var msgTarget = config.MessageTarget;
			try {
    			var receivers = msgTarget.Receivers;
        		$("#ReceiversName").val(receivers.name);
        		$("#ReceiversCode").val(receivers.code);
        		var excepters = msgTarget.Excepters;
        		$("#ExceptersName").val(excepters.name);
        		$("#ExceptersCode").val(excepters.code);
    		}
    		catch (ex){
    			coviCmn.traceLog(ex);
    		}
    		
    		/*			
			if(config.UseCategory == "Y"){ // 확장옵션설정 탭: 카테고리 사용시 카테고리 Selectbox 조회
				selectLargeCategoryList();
				if($("#selectLargeCategory option").size() > 0) selectSmallCategoryList();
			}
			if(config.UseUserForm == "Y"){ // 확장옵션설정 탭: 사용자정의필드 사용시 Grid 데이터 조회
				if (config.IsContents == "Y"){
					$("#chkUseUserForm").attr("disabled",true);
				}else{
					setUserDefFieldGrid();
				}	
			}
			*/

			if (config.IsContents == "Y"){
				$("#chkUseUserForm").attr("disabled",true);
				$("#divUserDefField").show();
	        	$("#divUserDefField div").hide();
	        	$("#divUserDefField table").hide();
	        	$("#divUserDefField strong").html("<a href='/groupware/contents/ContentsUserForm.do?folderID="+folderID+"' target='_blank' style='color:red;display:inline-block;padding-bottom:10px'>contents app 에서 확인</a>");
		        
			}else{	
	    		if(config.UseUserForm == "Y"){ // 확장옵션설정 탭: 사용자정의필드 사용시 Grid 데이터 조회
					setUserDefFieldGrid();
				}	
			}

			if(config.IsMobileSupport != "Y"){ // 모바일지원 null 일경우 비사용 표시
				$("#selectIsMobileSupport").val("N");
			}
			
			$("#folerPathName").text(config.FolderPathName.replaceAll(";","/"));
		}, 
		error: function(response, status, error){
			CFN_ErrorAjax("/groupware/board/manage/selectBoardConfig.do", response, status, error);
		}
	});
}

// 팝업 게시판 설정
var setBoardConfig = function(){
	if(boardAdmin.checkBoardConfigValidation()){
		var sDictionaryInfo = document.getElementById("hidFolderNameDicInfo").value;
		if (sDictionaryInfo == "") {
			switch (lang.toUpperCase()) {
				case "KO": sDictionaryInfo = document.getElementById("folderName").value + ";;;;;;;;;"; break;
				case "EN": sDictionaryInfo = ";" + document.getElementById("folderName").value + ";;;;;;;;"; break;
				case "JA": sDictionaryInfo = ";;" + document.getElementById("folderName").value + ";;;;;;;"; break;
				case "ZH": sDictionaryInfo = ";;;" + document.getElementById("folderName").value + ";;;;;;"; break;
				case "E1": sDictionaryInfo = ";;;;" + document.getElementById("folderName").value + ";;;;;"; break;
				case "E2": sDictionaryInfo = ";;;;;" + document.getElementById("folderName").value + ";;;;"; break;
				case "E3": sDictionaryInfo = ";;;;;;" + document.getElementById("folderName").value + ";;;"; break;
				case "E4": sDictionaryInfo = ";;;;;;;" + document.getElementById("folderName").value + ";;"; break;
				case "E5": sDictionaryInfo = ";;;;;;;;" + document.getElementById("folderName").value + ";"; break;
				case "E6": sDictionaryInfo = ";;;;;;;;;" + document.getElementById("folderName").value; break;
			}
			document.getElementById("hidFolderNameDicInfo").value = sDictionaryInfo
		}
		
		var url;
		var param;
		if(folderID && mode != "create"){
			//폴더/게시판 정보 수정	
			url = "/groupware/board/manage/updateBoard.do";
			
			var bodyFormId = $("input[name=chkBodyForm]:checked")[0] != undefined? $("input[name=chkBodyForm]:checked")[0].value:"";
			
			//권한 설정정보 
			var aclInfo = coviACL_getACLData('con_acl');
			var aclIsChange = aclInfo.aclIsChange;
			var aclList = aclInfo.aclData;
			var aclActionList = coviACL_getACLActionData('con_acl');
			
			$('input[type=checkbox]').attr('disabled', false);	//disable상태인 체크박스데이터 parameter로 추가
			
			var paramObject = new Object();
			paramObject = $("#frmBoardConfig").serializeObject();
			paramObject["mode"] = mode;
			paramObject["bizSection"]= bizSection;
			paramObject["folderID"] = folderID;
			paramObject["domainID"] = domainID;
			paramObject["menuID"] = $("#selectMenuID").val();
			paramObject["folderType"] = $("#folderType").val();
			paramObject["displayName"] = $("#folderName").val();
			paramObject["multiDisplayName"] = $("#hidFolderNameDicInfo").val();		//다국어 입력항목
			paramObject["contentsID"] = $("#hidContentsID").val();
			paramObject["processActivityList"] = boardAdmin.setProcessData();
			paramObject["processID"] = $("#hidProcessID").val();
			paramObject["description"] = $("#txtDescription").val();
			paramObject["bodyFormID"] = bodyFormId;					//초기양식으로 설정된 본문양식ID
			paramObject["aclIsChange"] = aclIsChange;				//권한 변경 여부
			paramObject["aclList"] = encodeURIComponent(aclList);	//권한 설정 정보
			paramObject["aclActionList"] = encodeURIComponent(aclActionList);		//권한 설정 정보
			paramObject["communityID"] = communityID;
			paramObject["ownerCode"] = $("#ownerCode").val();
			paramObject["limitFileSize"] = convertToBytes(paramObject["limitFileSize"]);	// 1회 업로드 제한
			paramObject["totalFileSize"] = convertToBytes(paramObject["totalFileSize"]);	// 총 업로드 제한
			paramObject["isUpdateChildren"] = $("#checkIsSubfolderInherited").is(":checked") ? "Y" : "N";
			paramObject["isInherited"] = $("#con_acl_isInherited").is(":checked") ? "Y" : $("#checkIsSubfolderInherited").is(":checked") ? "Y" : "N";
			
			if($("#chkUseBoardDescription").is(":checked")){
				paramObject["DescriptionBody"] = escape(coviEditor.getBody(g_editorKind, 'tbContentElement'));
				paramObject["DescriptionBodyText"] = coviEditor.getBodyText(g_editorKind, 'tbContentElement');
				paramObject["DescriptionInlineImage"] = escape(coviEditor.getImages(g_editorKind, 'tbContentElement'));
				paramObject["DescriptionBackgroundImage"] = escape(coviEditor.getBackgroundImage(g_editorKind, 'tbContentElement'));
				paramObject["frontStorageURL"] = escape(Common.getGlobalProperties("smart4j.path")+ Common.getBaseConfig("FrontStorage"));
			}
			
			// 업로드 가능한 확장자
			var enableFileExtentionArr = new Array();
			$("#enableFileExtention input[type=checkbox]:checked").each(function() {				
				enableFileExtentionArr.push(this.name);
				delete paramObject[this.name];
			});
			
			paramObject["enableFileExtention"] = enableFileExtentionArr.join(",");
			
			// tab별 체크되지 않은 체크박스 항목 별도 참조 
			$("#searchTab_BasicOption input[type=checkbox]:not(:checked)").each(function(){ paramObject[this.name]=null; });
			$("#searchTab_ExtOption input[type=checkbox]:not(:checked)").each(function(){ paramObject[this.name]=null; });
			param = paramObject;
		}else{
			url = "/groupware/board/manage/createBoard.do";
			param = {
				"domainID": domainID,
				"bizSection": bizSection,
				"menuID": $("#selectMenuID").val(),
				"mode": mode, // 'copy' or ''
				"memberOf": $("#folderType").val() != 'Root' ? folderID : "",
				"displayName": $("#folderName").val(),
				"multiDisplayName": $("#hidFolderNameDicInfo").val(),		//다국어 입력항목
				"folderType": $("#folderType").val(),
				"isUse": $("#selectIsUse").val(),
				"isDisplay": $("#selectIsDisplay").val(),
				"isAdminNotice": $("#selectIsAdminNotice").val(),
				"isShared": "N",
				"isMobileSupport": $("#selectIsMobileSupport").val(),
				"isURL": "N",
				"url": $("#linkURL").val(),
				"securityLevel": $("#securityLevel").val(),
				"ownerCode": $("#ownerCode").val(),
				"description": $("#txtDescription").val(),
				"communityID": communityID
			}
		}
		
		param.MessageTarget = getMessageTarget();
		
		$.ajax({
			type: "POST",
			url: url,
			dataType: 'json',
			data: param,
			success: function(data){
				if(data.status=='SUCCESS'){
					Common.Inform("<spring:message code='Cache.msg_37'/>", "Information", function(){ // 저장되었습니다.
						if(communityID){
							if(opener){
								opener.inCommMenu();
								opener.communityBoardLeft();
							}else{
								parent.inCommMenu();
								parent.communityBoardLeft();
							} 
						}else{
							if(opener){
								if(opener.folderGrid){
									opener.folderGrid.reloadList();
									opener.setTreeData();
									opener.myFolderTree.expandAll(2);
								}	
							}else{
								if(parent.folderGrid != undefined){
									parent.refresh();	
								}
							}
						}
						Common.Close();
					});
				}else{
					Common.Warning("<spring:message code='Cache.msg_sns_03'/>"); // 저장 중 오류가 발생하였습니다.
				}
			}, 
			error: function(error){
				Common.Warning("<spring:message code='Cache.msg_sns_03'/>"); // 저장 중 오류가 발생하였습니다.
			}
		});
	}
}

//게시판 설명 항목 조회
var selectBoardDescription = function(){
	$.ajax({
		type: "POST",
		url: "/groupware/board/manage/selectBoardDescription.do",
		dataType: 'json',
		data: {
			"folderID": folderID,
		},
		success: function(data){
			if(data.status=='SUCCESS'){
				if(data.boardDescription.Body){
					setTimeout(function(){
						coviEditor.setBody(g_editorKind, 'tbContentElement', board.XSSBoard(unescape(data.boardDescription.Body)));
					}, 1000);
				}
				
				$("#hidContentsID").val(data.boardDescription.ContentsID);
			}else{
				Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생헸습니다.
			}
		}, 
		error: function(response, status, error){
			 CFN_ErrorAjax("/groupware/board/manage/boardDescription.do", response, status, error);
		}
	});
}

var initOwnerCode = function(){
	$("#userName, #ownerCode").val('');
}

//다국어 입력 팝업
var dictionaryLayerPopup = function(pMode, pOriginObj, pDicObj){ // pMode: create, edit
	var option = {
		lang : lang,
		hasTransBtn : 'true',
		allowedLang : 'ko,en,ja,zh',
		useShort : 'false',
		dicCallback : pMode + $(pOriginObj).attr("name") + "Dic_CallBack",
		popupTargetID : 'DictionaryPopup',
		init : pMode + $(pOriginObj).attr("name") + "DicInit"
	};
	
	coviCmn.openDicLayerPopup(option,"");
}

//select name + Dic_CallBack(); 형태로 콜백 메소드 생성
var folderNameDicInit = function(){
	var value;
	
	if($('#hidFolderNameDicInfo').val() == ''){
		value = $('#folderName').val();
	}else{
		value = $('#hidFolderNameDicInfo').val();
	}
	
	return value;
}

var folderNameDic_CallBack = function(data){
	
	if($("#folderName").val() == ''){
		$("#folderName").val(data.KoFull);
	}
	$("#hidFolderNameDicInfo").val(coviDic.convertDic(data));
	
	Common.close("DictionaryPopup");
}

var fieldNameDic_CallBack = function(data){
	if($("#fieldName").val() == ''){
		$("#fieldName").val(data.KoFull);
	}
	$("#hidFieldNameDicInfo").val(coviDic.convertDic(data));
}

var fieldNameDicInit = function(){
	var value;
	
	if($('#hidFieldNameDicInfo').val() == ''){
		value = $('#fieldName').val();
	}else{
		value = $('#hidFieldNameDicInfo').val();
	}
	
	return value;
}

var bodyFormNameDic_CallBack = function(data){
	if($("#txtBodyFormName").val() == ''){
		$("#txtBodyFormName").val(data.KoFull);
	}
	
	$("#hidBodyFormDicInfo").val(coviDic.convertDic(data));
}

var bodyFormNameDicInit = function(){
	var value;
	
	if($('#hidBodyFormDicInfo').val() == ''){
		value = $('#txtBodyFormName').val();
	}else{
		value = $('#hidBodyFormDicInfo').val();
	}
	
	return value;
}

function OrgMapLayerPopup(caller, callbackName, type) {
	var orgChartUrl = "/covicore/control/goOrgChart.do?callBackFunc="+callbackName+"&type="+type;
	
	var target = { 
		name: (caller.getAttribute('data-target-name')) ? caller.getAttribute('data-target-name') : '',
		code: (caller.getAttribute('data-target-code')) ? caller.getAttribute('data-target-code') : '',
		selected : $("#" + caller.getAttribute('data-target-code')).val()
	}
	
	orgChartUrl += '&userParams=' + encodeURIComponent(JSON.stringify(target));
	CFN_OpenWindow(orgChartUrl, "<spring:message code='Cache.lbl_DeptOrgMap'/>",1000,580,"");
}

//조직도에서 전달받은 사용자/그룹코드를 등록알림 지정한 위치에 추가
function addTarget_Callback(orgData){
	var _orgData = JSON.parse(orgData);				// JSON 문자열을 객체로 변환
	var _target = JSON.parse(decodeURIComponent(_orgData.userParams));	// userParams에 담아온 JON 문자열를 디코드하여 객체로 변환

	var _names = '';
	var _codes = '';
	$.each(_orgData.item, function(idx, el){
		_names += ((idx > 0) ? ', ' : '') + CFN_GetDicInfo(el.DN);
		_codes += ((el.itemType == 'group') ? el.GroupCode : el.UserCode) + ';';
	});
	
	var nameEl = document.getElementById(_target.name);
	nameEl.value = _names;
	var codeEl = document.getElementById(_target.code);
	codeEl.value = _codes;
}

// 등록알림 수신자, 제외자에 대한 데이터 처리
function getMessageTarget(){
	return JSON.stringify({ 
		Receivers: {
			code: $("#ReceiversCode").val(),
			name: $("#ReceiversName").val()
		},
		Excepters: {
			code: $("#ExceptersCode").val(),
			name: $("#ExceptersName").val()
		}
	});
}

// 조직도 호출 팝업
var OrgMapLayerPopup_Owner = function(){
	var paramsCommunity = communityID ? ("&communityId=" + communityID) : "";	
	var target = { selected : $("#ownerCode").val() };
	var userParam = '&userParams=' + encodeURIComponent(JSON.stringify(target));
	
	CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=ownerAdd_CallBack&type=B9" + userParam + paramsCommunity,"<spring:message code='Cache.lbl_DeptOrgMap'/>",1000,580,"");
}

var OrgMapLayerPopup_approvalLine = function(){
	CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=approvalLineAdd_CallBack&type=B9","<spring:message code='Cache.lbl_DeptOrgMap'/>", 1000, 580, "");
}

// 분류별 담당자 지정 조직도 팝업
var OrgMapLayerPopup_CategoryManager = function(cateOperator){
	var categoryID = cateOperator == "SetLargeCateOperator" ? ($("#selectLargeCategory").val() ? $("#selectLargeCategory").val().split("|")[0] : "") : ($("#selectSmallCategory").val() ? $("#selectSmallCategory").val().split("|")[0] : "");
	
	if(categoryID == "") {
		Common.Warning(String.format(Common.getDic("msg_ChooseCategory"), Common.getDic(cateOperator == "SetLargeCateOperator" ? "lbl_LCate" : "lbl_SCate")));
		return;
	}
	
	var paramsCommunity = communityID ? ("&communityId=" + communityID) : "";
	var callBackFunc = cateOperator == "SetLargeCateOperator" ? "largeCategoryManagerAdd_CallBack" : "smallCategoryManagerAdd_CallBack";
	var target = { selected : cateOperator == "SetLargeCateOperator" ? $("#hidLargeCategoryManagerCode").val() : $("#hidSmallCategoryManagerCode").val() };	
	var userParam = '&userParams=' + encodeURIComponent(JSON.stringify(target));
	
	CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=" + callBackFunc + "&type=B9" + userParam + paramsCommunity,"<spring:message code='Cache.lbl_DeptOrgMap'/>",1000,580,"");
}

// 폴더 타입별 board_config_default 테이블 데이터를 참조하여 조회
var selectDefaultConfig = function(){
	if ($('#chkUseBasicConfig').prop('checked')) {
		$.ajax({
			type: "POST",
			url: "/groupware/board/manage/selectDefaultConfig.do",
			dataType: 'json',
			data: {
				"folderType": $("#folderType").val()
			},
			success: function(data){
				var config = data.config;
				for (var key in config) {
					if (/^Use/.test(key)) {
						config[key] == "Y" ? $("#chk"+key).prop('checked',true) : $("#chk"+key).prop('checked',false);
					} else if (/FileSize$/.test(key)) {
						$("#txt" + key).val(convertToMegaBytes(config[key]));					
					} else {
						$("#txt" + key).val(config[key]);
					}
				}
				
				// 기본값은 업로드 가능 확장자 전체 사용
				var chkAllFileExtention = $("#chkAllFileExtention").is(':checked');
				if(!chkAllFileExtention) {
					$("#chkAllFileExtention").trigger("click");			
				}
				
				// 기본옵션 설정 탭에 존재하는 체크박스와 입력항목에만 클릭이벤트 할당
				$("#searchTab_BasicOption").find("input[id^=chkUse], input[id^=txt]").not("#chkUseBasicConfig").on("click", function(){
					// 기본옵션 사용 체크 관련
					$('#chkUseBasicConfig').prop('checked', false);
				});
			}, 
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/board/manage/selectDefaultConfig.do", response, status, error);
			}
		});
	}
}

// Megabytes -> Bytes
function convertToBytes(pSize) {
	if(pSize != null) {
		var bytes = 1024;
		return parseInt(pSize) * parseInt(bytes) * parseInt(bytes);	
	} else {
		return "";	
	}
}

// Bytes -> MegaBytes
function convertToMegaBytes(pSize) {
	var bytes = 1024;
	return (parseInt(pSize) / parseInt(bytes) / parseInt(bytes)).toFixed(0);
}

/*********** 카테고리 시작 ***********/
var selectSmallCategoryList = function(){
	$.ajax({
		type: "POST",
		async: false,
		data: {
			"folderID": folderID,
			"memberOf": $("#selectLargeCategory").val() ? $("#selectLargeCategory").val().split("|")[0] : ""
		},
		url: "/groupware/admin/selectCategoryList.do",
		success: function(data){
			$("#selectSmallCategory").empty();
			data.categoryList.forEach(function(item){
				$("#selectSmallCategory").append($("<option/>", {"value": item.optionValue, "text": item.optionText}));
			});
			
			var smallCategoryManagerCode = $("#selectSmallCategory").val() ? $("#selectSmallCategory").val().split("|")[2] : "";
			selectCategoryManagerName(smallCategoryManagerCode, "hidSmallCategoryManagerName");
			$("#hidSmallCategoryManagerCode").val(smallCategoryManagerCode);
		},
		error: function(response, status, error){
			CFN_ErrorAjax("/groupware/admin/selectCategoryList.do", response, status, error);
		}
	});
};

var selectLargeCategoryList = function(){
	$.ajax({
		type: "POST",
		async: false,
		data: {
			"folderID": folderID
		},
		url: "/groupware/admin/selectCategoryList.do",
		success: function(data){
			$("#selectLargeCategory").empty();
			data.categoryList.forEach(function(item){
				$("#selectLargeCategory").append($("<option/>", {"value": item.optionValue, "text": item.optionText}));
			});
			
			var largeCategoryManagerCode = $("#selectLargeCategory").val() ? $("#selectLargeCategory").val().split("|")[2] : "";
			selectCategoryManagerName(largeCategoryManagerCode, "hidLargeCategoryManagerName");
			$("#hidLargeCategoryManagerCode").val(largeCategoryManagerCode);
		},
		error: function(response, status, error){
			 CFN_ErrorAjax("/groupware/admin/selectCategoryList.do", response, status, error);
		}
	});
};

var createSmallCategory = function(){ // 대분류의 데이터가 있을 경우에만 작업을 수행하므로 메소드 추가 하여 호출
	if($("#selectLargeCategory option").size() > 0){
		dictionaryLayerPopup('create', $('#selectSmallCategory'), $('#hidSmallCateName'));
	} else {
		Common.Warning("<spring:message code='Cache.msg_category_insert'/>");		//추가하실 대분류를 선택해주세요
	}
}

var editLargeCategory = function(){
	if($("#selectLargeCategory option").size() > 0){
		dictionaryLayerPopup('edit', $('#selectLargeCategory'), $('#hidLargeCateName'));
	} else {
		Common.Warning("<spring:message code='Cache.msg_SelectTarget'/>"); // 대상을 선택해주세요.
	}
}

var editSmallCategory = function(){
	if($("#selectSmallCategory option").size() > 0){
		dictionaryLayerPopup('edit', $('#selectSmallCategory'), $('#hidSmallCateName'));
	} else {
		Common.Warning("<spring:message code='Cache.msg_SelectTarget'/>"); // 대상을 선택해주세요.
	}
}

var deleteCategory = function(pObj){
	if($(pObj).val() == null || $(pObj).val() == undefined){
		Common.Warning("<spring:message code='Cache.msg_SelectTarget'/>"); // 대상을 선택해주세요.
		return;
	}
	
	var categoryID = $(pObj).val().split("|")[0];	//카테고리ID | 표시명 | 관리자코드 | sortpath
	
	Common.Confirm("<spring:message code='Cache.msg_Common_08'/>", 'Confirmation Dialog', function(result){ // 선택한 항목을 삭제하시겠습니까?
		if (result) {
			$.ajax({
				type: "POST",
				url: "/groupware/admin/deleteCategory.do",
				data: {
					"folderID": folderID,
					"categoryID": categoryID
				},
				success: function(data){
					if(data.status=='SUCCESS'){
						Common.Inform("<spring:message code='Cache.msg_50'/>"); // 삭제되었습니다.	 
						
						if($(pObj).attr("id") == "selectLargeCategory"){ // 삭제 처리 이후 selectbox 재조회
							selectLargeCategoryList();
						} 
						
						selectSmallCategoryList(); // 대뷴류 삭제 시 소분류도 삭제됨
					}else{
						Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생헸습니다.
					}
				},
				error: function(error){
					Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생헸습니다. 
				}
			});
		}
	});
}

var createLargeCategoryDic_CallBack = function(dicInfo){
	$('#hidLargeCateName').val(coviDic.convertDic(dicInfo));
	
	$.ajax({
		type: "POST",
		url: "/groupware/admin/createCategory.do",
		dataType : 'json',
		data: {
			"folderID": folderID,
			"displayName": $("#hidLargeCateName").val(),
			"memberOf": "",
			"sortKey": $("#selectLargeCategory option").size()
		},
		success: function(data){
			if(data.status == 'SUCCESS'){
				Common.Inform("<spring:message code='Cache.msg_37'/>", "Information", function(){ // 저장되었습니다.
					selectLargeCategoryList();
				});
			}else{
				Common.Warning("<spring:message code='Cache.msg_sns_03'/>"); // 저장 중 오류가 발생하였습니다.
			}
		}, 
		error:function(error){
			Common.Warning("<spring:message code='Cache.msg_sns_03'/>"); // 저장 중 오류가 발생하였습니다.
		}
	});
}

var createSmallCategoryDic_CallBack = function(data){
	$('#hidSmallCateName').val(coviDic.convertDic(data));
	
	$.ajax({
		type: "POST",
		url: "/groupware/admin/createCategory.do",
		dataType: 'json',
		data: {
			"folderID": folderID,
			"memberOf": $("#selectLargeCategory").val().split("|")[0],
			"displayName": $("#hidSmallCateName").val(),
			"sortKey": $("#selectSmallCategory option").size(),
			"sortPath": $("#selectLargeCategory").val().split("|")[3]
			
		},
		success: function(data){
			if(data.status == 'SUCCESS'){
				Common.Inform("<spring:message code='Cache.msg_37'/>", "Information", function(){ // 저장되었습니다.
					selectSmallCategoryList(); // 소분류 selectbox 재조회
				});
			}else{
				Common.Warning("<spring:message code='Cache.msg_sns_03'/>"); // 저장 중 오류가 발생하였습니다.
			}
		}, 
		error: function(error){
			Common.Warning("<spring:message code='Cache.msg_sns_03'/>"); // 저장 중 오류가 발생하였습니다.
		}
	});
}

var editLargeCategoryDic_CallBack = function(data){
	$('#hidLargeCateName').val(coviDic.convertDic(data));
	
	$.ajax({
		type: "POST",
		url: "/groupware/admin/updateCategory.do",
		dataType: 'json',
		data: {
			"categoryID": $("#selectLargeCategory").val().split("|")[0], // CategoryID | DisplayName | 
			"displayName": $("#hidLargeCateName").val(),
		},
		success: function(data){
			if(data.status=='SUCCESS'){
				Common.Inform("<spring:message code='Cache.msg_37'/>", "Information", function(){ // 저장되었습니다.
					selectLargeCategoryList();
				});
			}else{
				Common.Warning("<spring:message code='Cache.msg_sns_03'/>"); // 저장 중 오류가 발생하였습니다.
			}
		},
		error: function(error){
			Common.Warning("<spring:message code='Cache.msg_sns_03'/>"); // 저장 중 오류가 발생하였습니다.
		}
	});
}

var editLargeCategoryDicInit = function(){
	var value = "";
	
	if($('#selectLargeCategory').find("option").length > 0){
		value = $('#selectLargeCategory').val().split("|")[1];
	}
	
	return value;
}

var editSmallCategoryDic_CallBack = function(data){
	$('#hidSmallCateName').val(coviDic.convertDic(data));
	
	$.ajax({
		type: "POST",
		url: "/groupware/admin/updateCategory.do",
		dataType: 'json',
		data: {
			"categoryID": $("#selectSmallCategory").val().split("|")[0],
			"displayName": $("#hidSmallCateName").val()
		},
		success: function(data){
			if(data.status=='SUCCESS'){
				Common.Inform("<spring:message code='Cache.msg_37'/>", "Information", function(){ // 저장되었습니다.
					selectSmallCategoryList();
				});
			}else{
				Common.Warning("<spring:message code='Cache.msg_sns_03'/>"); // 저장 중 오류가 발생하였습니다.
			}
		},
		error: function(error){
			Common.Warning("<spring:message code='Cache.msg_sns_03'/>"); // 저장 중 오류가 발생하였습니다.
		}
	});
}

var editSmallCategoryDicInit = function(){
	var value = "";
	
	if($('#selectSmallCategory').find("option").length > 0){
		value = $('#selectSmallCategory').val().split("|")[1];
	}
	
	return value;
}
/*********** 카테고리 끝 ***********/
 

/*********** 진행상태 시작 ***********/
var selectProgressStateList = function(){
	$.ajax({
		type: "POST",
		data: {
			"folderID": folderID
		},
		url: "/groupware/admin/selectProgressStateList.do",
		success: function(data){
			$("#selectProgressState").bindSelect({
				reserveKeys: {
					optionValue: "optionValue", // Selectbox에 value 값에 'StateID|DisplayName' 형태로 설정됨
					optionText: "optionText"
				},
				options:data.stateList
			});
		},
		error: function(response, status, error){
			CFN_ErrorAjax("/groupware/admin/selectProgressStateList.do", response, status, error);
		}
	});
}

var deleteProgressState = function(pObj){
	var stateID = $(pObj).val().split("|")[0];	//진행상태ID | 표시명
	
	Common.Confirm("<spring:message code='Cache.msg_Common_08'/>", 'Confirmation Dialog', function(result){ // 선택한 항목을 삭제하시겠습니까?
		if (result) {
			$.ajax({
				type: "POST",
				url: "/groupware/admin/deleteProgressState.do",
				data: {
					"stateID": stateID,
					"folderID": folderID
				},
				success: function(data){
					if(data.status=='SUCCESS'){
						Common.Inform("<spring:message code='Cache.msg_50'/>"); // 삭제되었습니다.	 
						selectProgressStateList();	
					}else{
						Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생헸습니다.
					}
				},
				error: function(error){
					Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생헸습니다. 
				}
			});
		}
	});
}

var createProgressStateDic_CallBack = function(dicInfo){
	document.getElementById("hidProgressStateName").value = dicInfo;
	
	$.ajax({
		type: "POST",
		url: "/groupware/admin/createProgressState.do",
		dataType: 'json',
		data: {
			"folderID": folderID,
			"displayName": $("#hidProgressStateName").val(),
			"sortKey": $("#selectProgressState option").size()
		},
		success: function(data){
			if(data.status=='SUCCESS'){
				Common.Inform("<spring:message code='Cache.msg_37'/>", "Information", function(){ // 저장되었습니다.
					selectProgressStateList();
				});
			}else{
				Common.Warning("<spring:message code='Cache.msg_sns_03'/>"); // 저장 중 오류가 발생하였습니다.
			}
		},
		error: function(error){
			Common.Warning("<spring:message code='Cache.msg_sns_03'/>"); // 저장 중 오류가 발생하였습니다.
		}
	});
}

var editProgressStateDic_CallBack = function(dicInfo){
	document.getElementById("hidProgressStateName").value = dicInfo;
	
	$.ajax({
		type: "POST",
		url: "/groupware/admin/updateProgressState.do",
		dataType: 'json',
		data: {
			"stateID": $("#selectProgressState").val().split("|")[0],
			"displayName": $("#hidProgressStateName").val(),
		},
		success: function(data){
			if(data.status=='SUCCESS'){
				Common.Inform("<spring:message code='Cache.msg_37'/>", "Information", function(){	// 저장되었습니다.
					selectProgressStateList();
				});
			}else{
				Common.Warning("<spring:message code='Cache.msg_sns_03'/>"); // 저장 중 오류가 발생하였습니다.
			}
		},
		error: function(error){
			Common.Warning("<spring:message code='Cache.msg_sns_03'/>"); // 저장 중 오류가 발생하였습니다.
		}
	});
}

/*********** 진행상태 끝 ***********/
 
/*********** 승인프로세스 시작 ***********/
var changeActivityType= function( pObj){
	$(pObj).closest("li").find("[name=spnApprover]").attr("activitytype", $(pObj).val());
};

// 게시판 승인프로세스 조회 
var selectProcessActivityList = function(){
	$.ajax({
		type: "POST",
		url: "/groupware/board/manage/selectProcessActivityList.do",
		dataType: 'json',
		data: {
			"folderID": folderID
		},
		success: function(data){
			if(data.status=='SUCCESS'){
				$('#spnApprovalLine ol').html("");
				var htmlApprovalLine = "";
				$("#hidProcessID").val(data.processID);
				
				$(data.list).each(function(i, item){
					if(i > 0){
						htmlApprovalLine += "<li class='arr'><span></span></li>";
					}
					htmlApprovalLine += drawAppovalList(item.ActivityType, item.ActorCode, item.DisplayName);
				});
				
				$('#spnApprovalLine ol').append(htmlApprovalLine);
			}else{
				Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생헸습니다.
			}
		},
		error: function(response, status, error){
			CFN_ErrorAjax("/groupware/board/manage/selectProcessActivityList.do", response, status, error);
		}
	});
};

//승인자 왼쪽으로 이동
var moveLeftApprover=function(pObj){
	var org_approver = $(pObj).closest("li");
	var arr =  org_approver.prev();//화살표 
	var dest_approver = arr.prev();
	dest_approver.before(org_approver);
	dest_approver.before(arr);
};	

//승인자 오른쪽으로 이동
var moveRightApprover=function(pObj){
	var org_approver = $(pObj).closest("li");
	var arr =  org_approver.next();//화살표 
	var dest_approver =  arr.next();//화살표 제외
	dest_approver.after(org_approver);
	dest_approver.after(arr);
};


//승인자 중복체크 
var dupCheckApprover = function(pOrgData){
	var approvalJSON = $.parseJSON(pOrgData);
	var isExist = false;
	var l_UserCode = "";
	var l_UserName = "";
	
	$(approvalJSON.item).each(function (i, item) {
		sObjectType = item.itemType;
		
		if(sObjectType.toUpperCase() == "USER"){ //사용자
			l_UserCode = item.UserCode;
			l_UserName = CFN_GetDicInfo(item.DN);
			
			$("[name=spnApprover]").each(function(i){
				if (l_UserCode == $(this).attr('userCode')) {
					isExist = true;
					Common.Warning(l_UserName + " " + "<spring:message code='Cache.msg_AlreadyAdd'/>");	// (은)는 이미 추가되어있습니다
				}
			});
		}
	});
	return isExist;
}

//승인자 삭제 
var deleteApprover = function(pObj){
	//이전 단계의 승인자가 없을 경우 우측에 있는 화살표 삭제
	if($(pObj).parent().prev().length > 0){
		$(pObj).parent().prev().remove();
	} else {
		$(pObj).parent().next().remove();
	}
	$(pObj).parent().remove();
}

//승인 프로세스 지정용 - 추가 수정 필요
var approvalLineAdd_CallBack = function(orgData){
	if (dupCheckApprover(orgData)) return;
	
	var approvalJSON =	$.parseJSON(orgData);
	var approvalUser = "";
	var approvalUserName = "";
	var approvalDept = "";
	var approvalIDs = "";
	var htmlApprovalLine = "";
	var step = $(".person").length;
	
	$(approvalJSON.item).each(function(i, item){
		sObjectType = item.itemType;
		
		if(sObjectType.toUpperCase() == "USER"){ //사용자
			approvalUser = item.UserCode;
			approvalUserName = CFN_GetDicInfo(item.DN);
			approvalDept = CFN_GetDicInfo(item.SGNM);
			if(step > 0){
				htmlApprovalLine += "<li class='arr'><span></span></li>";
			}
			
			htmlApprovalLine += drawAppovalList("Serial", approvalUser, approvalUserName);
			step++;
		}
	});
	
	$('#spnApprovalLine ol').append(htmlApprovalLine);
}

var drawAppovalList=function(ActivityType, ActorCode, DisplayName){
	return '<li class="person">'+
			'<span name="spnApprover" ActorRole="Approver" ActivityType="'+ActivityType+'" userCode="'+ActorCode+'"></span>'+ //' {1} ({2})&nbsp; </span>", step, approvalUserName, approvalDept, approvalUser);
			'<select onchange="changeActivityType(this)">'+
			'<option value="Parall" '+(ActivityType=="Parall"?"selected":"")+'>'+Common.getDic("lbl_Parall")+'</option>'+
			'<option value="Serial" '+(ActivityType=="Serial"?"selected":"")+'>'+Common.getDic("lbl_Serial")+'</option>'+
			'</select>'+
			'<a href="#">'+
		    '<div class="image2">'+
		    '    <span class="appphoto" style="background-image:url(\'/covicore/resources/images/no_profile.png\')"></span>'+
		    '</div>'+
		    '<p class="appname">'+DisplayName+'</p>'+
		    '</a>'+
		    ' <div class="btn_area">'+
		    '  <a class="prev" onclick="moveLeftApprover(this)"></a>'+
		    '  <a class="next" onclick="moveRightApprover(this)"></a>'+
		    '</div>'+
			'<span class="btn_x" onclick="javascript:deleteApprover(this)"/>'+
		'</li>';
}
/*********** 승인프로세스 끝 ***********/


/*********** 사용자 정의 필드 시작 ***********/
// 사용자 정의 필드 Grid 세팅
var setUserDefFieldGrid = function(){
	Common.getDicList(["lbl_FieldNm","lbl_FieldType","lbl_Limit2","lbl_FieldSize","lbl_OptionCnt","lbl_DisplayList","lbl_ListSearchItem","lbl_surveyIsRequire"]);
	
	userDefFieldGrid.setGridHeader(boardAdmin.getGridHeader("UserDefField"));
	setUserDefFieldGridConfig();
	selectUserDefFieldList();
}

// 사용자 정의 필드 초기화버튼 클릭
var resetUserDefField = function(){
	$("#fieldType").val("Input");
	
	//컨트롤 초기화
	$("#fieldName").val("");
	$("#hidUserFormID").val("");
	$("#hidFieldNameDicInfo").val("");
	$("#fieldLimitCnt").val("");
	$("#isCheckVal").val("Y");		//필수
	$("#isList").val("N");			//목록표시
	$("#fieldSize").val("Line");
	
	//필드옵션항목 초기화
	$("#optionPlaceHolder").html("");
	$('#rowFieldOption').css({ "display": "none" });
	$('#spanFieldLimitCnt').css({ "display": "inline" });
	
	$("#btnEditField").hide();
	$("#btnAddField").show();
}

// 사용자 정의 필드 validation 체크
var checkUserDefParam = function(pMode){
	var flag = true;
	
	if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
	
	if(pMode == "create" && userDefFieldGrid.getList().length >= 10){
		parent.Common.Warning("<spring:message code='Cache.msg_gw_ValidationUserDefField'/>"); // 필드명 입력
		flag = false;
	}
	
	if ($("#fieldName").val() == "") {
		parent.Common.Warning("<spring:message code='Cache.msg_EnterFieldNm'/>", "Warning Dialog", function(){ // 필드명 입력
			document.getElementById("fieldName").focus();
		});
		flag = false;
	}
	
	// 옵션체크
	if ($("#fieldType").val() == "DropDown" || $("#fieldType").val() == "CheckBox" || $("#fieldType").val() == "Radio") {
		$("input[id^=fieldOption_]").each(function (i) {
			if ($(this).val() == "" && $(this).attr('value') == "") {
				Common.Warning(CFN_GetDicInfo('msg_EnterFieldNm'));	//필드명을 입력하세요
				$(this).focus();
				flag = false;
				return flag;
			}
		});
	}
	
	return flag;
}

var setUserDefField = function(pMode){
	if(checkUserDefParam(pMode)){
		var optionStr = "";
		var optionArr = [];
		$.each( $("input[id^=fieldOption]"), function(idx, el){
			var optionIdx = $(el).attr("idx");
			
			var optionName = ($("input[id=hidFieldOption_"+optionIdx+"_DicInfo]").val() != '') ? $("input[id=hidFieldOption_"+optionIdx+"_DicInfo]").val() : el.value;
			var optionObj = { 'optionName': optionName }
			if ($("input[type=radio][id=optionCheck_"+optionIdx+"]").length > 0) optionObj.optionCheck = ($("input[type=radio][id=optionCheck_"+optionIdx+"]").prop("checked")) ? 'Y' : 'N';
			optionArr.push(optionObj);
		});
		optionStr = JSON.stringify(optionArr);
		
		var sDictionaryInfo = document.getElementById("hidFieldNameDicInfo").value;
		if (sDictionaryInfo == "") {
			switch (Common.getSession("lang").toUpperCase()) {
				case "KO": sDictionaryInfo = document.getElementById("fieldName").value + ";;;;;;;;;"; break;
				case "EN": sDictionaryInfo = ";" + document.getElementById("fieldName").value + ";;;;;;;;"; break;
				case "JA": sDictionaryInfo = ";;" + document.getElementById("fieldName").value + ";;;;;;;"; break;
				case "ZH": sDictionaryInfo = ";;;" + document.getElementById("fieldName").value + ";;;;;;"; break;
				case "E1": sDictionaryInfo = ";;;;" + document.getElementById("fieldName").value + ";;;;;"; break;
				case "E2": sDictionaryInfo = ";;;;;" + document.getElementById("fieldName").value + ";;;;"; break;
				case "E3": sDictionaryInfo = ";;;;;;" + document.getElementById("fieldName").value + ";;;"; break;
				case "E4": sDictionaryInfo = ";;;;;;;" + document.getElementById("fieldName").value + ";;"; break;
				case "E5": sDictionaryInfo = ";;;;;;;;" + document.getElementById("fieldName").value + ";"; break;
				case "E6": sDictionaryInfo = ";;;;;;;;;" + document.getElementById("fieldName").value; break;
			}
			document.getElementById("hidFieldNameDicInfo").value = sDictionaryInfo
		}
		
		var param = {
			"userFormID": $("#hidUserFormID").val(),
			"folderID": folderID,
			"fieldName": $("#hidFieldNameDicInfo").val(),
			"fieldType": $("#fieldType").val(),
			"fieldSize": $("#fieldSize").val(),
			"fieldLimitCnt": ($("#fieldType").val() == "Input" || $("#fieldType").val() == "TextArea") ? $("#fieldLimitCnt").val() : "",
			"isList": $("#isList").val(),
			"isOption": ($("#fieldType").val() == "Input" || $("#fieldType").val() == "TextArea") ? "N" : $("input[id^=fieldOption]").size() > 0 ? "Y" : "N",
			"isCheckVal": $("#isCheckVal").val(),
			"isSearchItem": $("#isSearchItem").val(),
			"optionStr": optionStr
		}
		
		var url = (pMode != "create") ? "/groupware/admin/updateUserDefField.do" : "/groupware/admin/createUserDefField.do";
		
		$.ajax({
			type: "POST",
			url: url,
			dataType: 'json',
			data: param,
			success: function(data){
				if(data.status=='SUCCESS'){
					Common.Inform("<spring:message code='Cache.msg_37'/>", "Information", function(){ // 저장되었습니다.
						selectUserDefFieldList(); // 사용자 정의 필드 데이터 추가 이후 조회
						resetUserDefField(); // 저장, 조회 이후 입력항목 초기화
					});
				}else{
					Common.Warning("<spring:message code='Cache.msg_sns_03'/>"); // 저장 중 오류가 발생하였습니다.
				}
			}, 
			error: function(error){
				Common.Warning("<spring:message code='Cache.msg_sns_03'/>"); // 저장 중 오류가 발생하였습니다.
			}
		});
	}
}

// 사용자 정의 필드 삭제
var deleteUserDefField = function(){
	var userFormIDs = '';
	
	$.each(userDefFieldGrid.getCheckedList(0), function(i,obj){
		userFormIDs += obj.UserFormID + ';'
	});
	
	if(userFormIDs == ''){
		 Common.Warning("<spring:message code='Cache.msg_Common_03'/>"); // 삭제할 항목을 선택하여 주십시오.
		 return;
	}
	
	Common.Confirm("<spring:message code='Cache.msg_Common_08'/>", 'Confirmation Dialog', function(result){ // 선택한 항목을 삭제하시겠습니까?
		if (result) {
			$.ajax({
				type: "POST",
				url: "/groupware/admin/deleteUserDefField.do",
				data: {
					"userFormIDs": userFormIDs,
					"folderID": folderID
				},
				success: function(data){
					if(data.status=='SUCCESS'){
						Common.Inform("<spring:message code='Cache.msg_50'/>"); // 삭제되었습니다.
						userDefFieldGrid.reloadList();
						resetUserDefField();
					}else{
						Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생헸습니다.
					}
				},
				error: function(response, status, error){
					CFN_ErrorAjax("/groupware/admin/deleteUserDefField.do", response, status, error);
				}
			});
		}
	});
}

// 사용자 정의 필드 Grid Config 설정
var setUserDefFieldGridConfig = function(){
	var configObj = {
		targetID: "userDefFieldGrid",
		listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
		height: "auto",
		page: {
			display: false,
			paging: false,
			pageNo: 1,
			pageSize: 10
		},
		paging: true,
		colHead: {},
		body: {
			onclick: function(){
				if(this.item.FieldType == "Radio" || this.item.FieldType == "CheckBox" || this.item.FieldType == "DropDown" || this.item.FieldType == "Date") {
					$("#spanFieldLimitCnt").hide();	//제한 입력 항목 숨김
				} else if(this.item.FieldType == "Input" || this.item.FieldType == "TextArea") {
					$("#spanFieldLimitCnt").show();
				}
				
				if(this.item.IsOption == "Y"){
					selectUserDefFieldOptionList(this.item.FolderID, this.item.UserFormID, this.item.FieldType);
				} else {
					$("#rowFieldOption").hide();
					$("#optionPlaceHolder").html("");
				}
				
				$("#hidUserFormID").val(this.item.UserFormID);
				$("#hidFieldNameDicInfo").val(this.item.FieldName);
				$("#fieldName").val(CFN_GetDicInfo(this.item.FieldName));
				$("#fieldType").val(this.item.FieldType);
				$("#fieldLimitCnt").val(this.item.FieldLimitCnt);
				$("#isList").val(this.item.IsList);
				$("#isCheckVal").val(this.item.IsCheckVal);
				$("#isSearchItem").val(this.item.IsSearchItem);
				$("#fieldSize").val(this.item.FieldSize);
				$("#btnAddField").hide();
				$("#btnEditField").show();
			}
		}
	};
	
	userDefFieldGrid.setGridConfig(configObj);
	userDefFieldGrid.config.fitToWidthRightMargin = 0;
}

// 사용자 정의 Field 조회/페이징
var selectUserDefFieldList = function(pMenuID, pFolderID){
	userDefFieldGrid.bindGrid({
		ajaxUrl: "/groupware/admin/selectUserDefFieldGridList.do",
		ajaxPars: {
			"folderID": folderID
		}
	});
}

// Grid에서 선택한 사용자 정의 필드에 필드 옵션에 존재할 경우 필드옵션 리스트 조회
var selectUserDefFieldOptionList = function(pFolderID, pUserFormID, pFieldType){
	$.ajax({
		type: "POST",
		url: "/groupware/admin/selectUserDefFieldOptionList.do",
		dataType: 'json',
		data: {
			"folderID": pFolderID,
			"userFormID": pUserFormID
		},
		success: function(data){
			$("#optionPlaceHolder").html("");
			$("#rowFieldOption").show();
			var optionList = data.optionList;
			
			if(optionList.length > 0) {
				for(var i = 0 ; i < optionList.length ;i++){
					var option = String.format('<ul {0}><li>', (i != 0 ? "class='userDefFieldTop'" : ""));
					if(['DropDown','Radio','CheckBox'].indexOf(pFieldType) > -1){
						option += String.format('<input type="radio" id="optionCheck_{0}" name="optionCheck" {1} style="margin-right:5px;"/>', i, (optionList[i].OptionCheck == 'Y') ? 'checked' : '');
					}
					option += String.format('<input type="text" id="fieldOption_{0}" name="fieldOption_{0}" idx={0} optionID="{1}" class="w60" value="{1}" onclick="javascript:userDefFieldnDicLayerPopup({0},$(\'#fieldOption_{0}\'),$(\'#fieldOption_{0}\'));"/>', i, optionList[i].OptionName);
					option += String.format('<input type="hidden" id="hidFieldOption_{0}_DicInfo" value="{1}"/>', i, optionList[i].MultiDisplayName);
					option += String.format('<input type="button" value="{1}" class="AXButton userDefFieldBtn" onclick="javascript:userDefFieldnDicLayerPopup({0},$(\'#fieldOption_{0}\'),$(\'#hidFieldOption_{0}_DicInfo\'));">',i, "<spring:message code='Cache.lbl_MultiLang2'/>");
					option += String.format('<input type="button" id="btnDeleteOption" value=" - " class="AXButton userDefFieldBtn" onclick="javascript:deleteOption(this, {0})" /></li></ul>', optionList[i].OptionID);	 
					$("#optionPlaceHolder").append(option);
				}
				
				//입력항목 추가후 옵션 추가 버튼을 마지막 항목에 추가 
				$("#optionPlaceHolder>ul>li>input:last").after('<input type="button" id="btnAddOption" value=" + " class="AXButton userDefFieldBtn" onclick="javascript:boardAdmin.addOption(this)">');
			} else {
				var option = String.format('<ul><li>');
				option += String.format('<input type="radio" id="optionCheck_{0}" name="optionCheck" style="margin-right:5px;"/>', 0);
				option += String.format('<input type="text" id="fieldOption_{0}" name="fieldOption_{0}" class="w60" value="{0}" onclick="javascript:userDefFieldnDicLayerPopup({0},$(\'#fieldOption_{0}\'),$(\'#fieldOption_{0}\'));"/>', 0);
				option += String.format('<input type="hidden" id="hidFieldOption_{0}_DicInfo"/>', 0);
				option += String.format('<input type="button" value="{1}" class="AXButton userDefFieldBtn" onclick="javascript:userDefFieldnDicLayerPopup({0},$(\'#fieldOption_{0}\'),$(\'#hidFieldOption_{0}_DicInfo\'));">',0, Common.getDic("lbl_MultiLang2"));
				option += String.format('<input type="button" id="btnAddOption" value="+" class="AXButton userDefFieldBtn" onclick="javascript:boardAdmin.addOption(this)" /></li></ul>');	 
				$("#optionPlaceHolder").html(option);
			}
		},
		error: function(error){
			Common.Warning("<spring:message code='Cache.msg_sns_03'/>"); // 저장 중 오류가 발생하였습니다.
		}
	});
}

// 사용자 정의 필드 위치 변경
var moveUserDefField = function(pMode){
	if(userDefFieldGrid.getCheckedList(0).length == 0){
		Common.Warning("<spring:message code='Cache.msg_NoSelMovingField'/>"); // 이동할 필드가 선택되지 않았습니다
		return;
	}else if(userDefFieldGrid.getCheckedList(0).length > 1){
		Common.Warning("<spring:message code='Cache.msg_OnlyOneSelMovingField'/>"); // 이동할 필드는 한개만 선택되어야 합니다
		return;
	}
	
	var param = userDefFieldGrid.getCheckedList(0)[0];
	
	$.ajax({
		type: "POST",
		url: "/groupware/admin/moveUserDefField.do",
		dataType: 'json',
		data: {
			"folderID": param.FolderID,
			"userFormID": param.UserFormID,
			"sortKey": param.SortKey,
			"mode": pMode
		},
		success: function(data){
			if(data.status=='SUCCESS'){
				if(data.message){ // 최상위, 최하위 항목의 경우에는 변경 불가 메시지 표시
					Common.Warning(data.message);
				} else {
					Common.Warning("<spring:message code='Cache.msg_Changed'/>"); // 삭제되었습니다.
				}
				userDefFieldGrid.reloadList();
				resetUserDefField();
			}else{
				Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생헸습니다.
			}
		},
		error: function(response, status, error){
			CFN_ErrorAjax("/groupware/admin/moveUserDefField.do", response, status, error);
		}
	});
}

//옵션 삭제
var deleteOption = function(pObj, pOptionID){
	//이미 저장된 필드 항목의 옵션을 삭제할경우 row데이터를 추가로 삭제처리
	if(pOptionID){
		Common.Confirm("<spring:message code='Cache.msg_Common_08'/><br><spring:message code='Cache.msg_DeleteFieldOptionWarning'/>", 'Confirmation Dialog', function(result){ // 선택한 항목을 삭제하시겠습니까? 필드 옵션 삭제 시 데이터가 잘못 표기될 수 있습니다.
			if (result) {
			 $.ajax({
				type: "POST",
				url: "/groupware/admin/deleteUserDefOption.do",
				data: {
					"optionID": pOptionID
				},
				success: function(data){
					if(data.status=='SUCCESS'){
						Common.Inform("<spring:message code='Cache.msg_50'/>"); // 삭제되었습니다.
						selectUserDefFieldList();	//OptionCnt의 개수가 변했으므로 List재조회
						
						//필드옵션 항목에서 표시하는 방법 변경
						$(pObj).parent().parent().remove();
						
						if($("#optionPlaceHolder>ul").size() == 0) {
							var option = String.format('<ul><li>');
							option += String.format('<input type="radio" id="optionCheck_{0}" name="optionCheck" style="margin-right:5px;"/>', 0);
							option += String.format('<input type="text" id="fieldOption_{0}" name="fieldOption_{0}" class="w60" value="{0}" onclick="javascript:userDefFieldnDicLayerPopup({0},$(\'#fieldOption_{0}\'),$(\'#fieldOption_{0}\'));"/>', 0);
							option += String.format('<input type="hidden" id="hidFieldOption_{0}_DicInfo"/>', 0);
							option += String.format('<input type="button" value="{1}" class="AXButton userDefFieldBtn" onclick="javascript:userDefFieldnDicLayerPopup({0},$(\'#fieldOption_{0}\'),$(\'#hidFieldOption_{0}_DicInfo\'));">',0, Common.getDic("lbl_MultiLang2"));
							option += String.format('<input type="button" id="btnAddOption" value="+" class="AXButton userDefFieldBtn" onclick="javascript:boardAdmin.addOption(this)" /></li></ul>');	 
							$("#optionPlaceHolder").html(option);
						}
						
						if($("#btnAddOption").size() == 0){	//옵션 추가 버튼이 모두 사라졌을경우 재생성
							$("#optionPlaceHolder>ul>li>input:last").after('<input type="button" id="btnAddOption" value=" + " class="AXButton userDefFieldBtn" onclick="javascript:boardAdmin.addOption(this)">');
						}
					}else{
						Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
					}
				},
				error: function(error){
					Common.Warning("<spring:message code='Cache.msg_apv_030'/>");// 오류가 발생헸습니다. 
				}
			 });
			}
		});
	} else {
		$(pObj).parent().parent().remove();
		if($("#btnAddOption").size() == 0){
			$("#optionPlaceHolder>ul>li>input:last").after('<input type="button" id="btnAddOption" value=" + " class="AXButton userDefFieldBtn" onclick="javascript:boardAdmin.addOption(this)">');
		}
	}
}

//사용자 정의 필드 전용 다국어 입력 팝업
var userDefFieldnDicLayerPopup = function(pIndex, pOriginObj, pDicObj){ //pMode: create, edit
	var value="";
	//IE 8 이하에서는 Object.keys 동작하지 않음
	if($(pDicObj).val() == ""){
		if($(pOriginObj).val() != ""){
			value = encodeURIComponent($(pOriginObj).val());
		}
	}else{
		value = encodeURIComponent($(pDicObj).val());
	}
	
	var option = {
		lang : 'ko',
		hasTransBtn : 'true',
		allowedLang : 'ko,en,ja,zh',
		useShort : 'false',
		dicCallback : "userDefFieldOptionDic_CallBack",
		popupTargetID : 'DictionaryPopup',
		init : "userDefFieldOptionDicInit"
	};
	
	var url = "";
	url += "/covicore/control/calldic.do?lang=" + option.lang;
	url += "&hasTransBtn=" + option.hasTransBtn;
	url += "&useShort=" + option.useShort;
	url += "&dicCallback=" + option.dicCallback;
	url += "&allowedLang=" + option.allowedLang;
	url += "&popupTargetID=" + option.popupTargetID;
	url += "&init=" + option.init;
	
	g_optionIndex = pIndex;
	Common.open("", "DictionaryPopup", "<spring:message code='Cache.lbl_MultiLangSet'/>", url, "500px", "250px", "iframe", true, null, null, true);
}

var userDefFieldOptionDic_CallBack = function(data){
	$("#fieldOption_" + g_optionIndex).val(data.KoFull);
	$("#hidFieldOption_" + g_optionIndex + "_DicInfo").val(coviDic.convertDic(data));
}

function userDefFieldOptionDicInit(){
	return ($('#hidFieldOption_'+ g_optionIndex+'_DicInfo').val() != '') ? 
			$('#hidFieldOption_'+ g_optionIndex+'_DicInfo').val() :
			$("#fieldOption_"+ g_optionIndex).val()	;
}
/*********** 사용자 정의 필드 끝 ***********/

/*********** 본문양식 시작 ***********/
//본문양식 체크박스 컨트롤
var CheckClickBodyForm = function(oChk){
	var l_Seq = 0;
	//하나만 선택되게
	if (oChk.checked) {
		$("[name=chkBodyForm]").each(function (i) {
			//체크해제
			$(this).attr('checked', false);
			//"IsInit"속성값 "N"으로 변경
			l_Seq = $(this).attr('value');
			$("#spnBodyForm_" + l_Seq).attr('IsInit', 'N');
		});
		
		oChk.checked = true;
	}
	
	//체크여부에따른 "IsInit"속성값 재변경
	l_Seq = oChk.value;
	if (oChk.checked) {
		$("#spnBodyForm_" + l_Seq).attr('IsInit', 'Y');
	} else {
		$("#spnBodyForm_" + l_Seq).attr('IsInit', 'N');
	}
}

//양식파일 validation check
var fileuploadBeforeCheck = function(){
	var file = document.getElementById("uploadFile");
	
	if(file.files.length != 1){
		Common.Warning("<spring:message code='Cache.msg_SelFormFile'/>");
		return false;
	}
	
	if(file.files.length<=0){	//CHECK: 추가로직이 아닌 수정일경우 파일 업로드 하지 않아도 되는 부분에서 사용하는 것 같다. 추가 분석 필요 
		return true;
	}else if (file.files.item(0).name.length > 20){
		Common.Warning("<spring:message code='Cache.lbl_apv_warning_filename'/>");
		return false;
	}else if (file.files.item(0).size > 512000){
		Common.Warning("<spring:message code='Cache.lbl_apv_warning_filesize'/>");
		return false;
	}else{
		return true;
	}
}

//본문양식 등록
var createBodyForm = function(){
	if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
	
	if($("#txtBodyFormName").val() == ""){
		Common.Warning("<spring:message code='Cache.msg_EnterFormNm'/>", "Warning Dialog", function(){ // 이동할 필드가 선택되지 않았습니다
			$("#txtBodyFormName").focus();
		});
		return;
	}else if(!fileuploadBeforeCheck()){
		return; 
	}
	
	var formData = new FormData();
	formData.append("formName", $("#txtBodyFormName").val());
	formData.append('uploadFile', $('#uploadFile')[0].files[0]);
	formData.append('folderID', folderID);
	
	$.ajax({
		type: 'post',
		url: "/groupware/board/manage/createBodyForm.do",
		data: formData,
		dataType: 'json',
		processData: false,
		contentType: false,
		success: function(data){
			if(data.status=='SUCCESS'){
				Common.Inform("<spring:message code='Cache.msg_37'/>", "Information", function(){ // 저장되었습니다.
					$("#tdUpload").html("<input type=\"file\" id=\"uploadFile\" accept=\".txt,.htm,.html\" class=\"w80\" onchange=\"bodyFormCheckFileName(this.value);\"/><input type=\"button\" value=\""+Common.getDic("lbl_Add")+"\" id=\"addFormBtn\" class=\"AXButton\" style=\"margin-left: 5px;\"/>");
					$("#txtBodyFormName").val("");
					selectBodyForm();
				});
			}else{
				Common.Warning("<spring:message code='Cache.msg_apv_030'/>");
			}
		},
		error: function(response, status, error){
			CFN_ErrorAjax("/groupware/board/manage/createBodyForm.do", response, status, error);
		}
	});
}

//본문양식 조회
var selectBodyForm = function(){
	$.ajax({
		type: 'POST',
		url: "/groupware/board/manage/selectBodyForm.do",
		data: {
			"folderID": folderID
		},
		dataType: 'json',
		success: function(data){
			var formList = data.formList;
			var bodyFormHtml = "";
			for (var i = 0; i < formList.length ; i++) {
				bodyFormHtml += "<span name='spnBodyForm' id='spnBodyForm_" + formList[i].BodyFormID + "' FormPath='" + formList[i].FormPath + "' FormName='" + CFN_GetDicInfo(formList[i].FormName) + "' IsInit='" + formList[i].IsInit + "'>";
				if (formList[i].IsInit == "Y")
					bodyFormHtml += "<input name='chkBodyForm' id='chkBodyForm_" + formList[i].BodyFormID + "' onclick='CheckClickBodyForm(this);' type='checkbox' checked value='" + formList[i].BodyFormID + "'>";
				else
					bodyFormHtml += "<input name='chkBodyForm' id='chkBodyForm_" + formList[i].BodyFormID + "' onclick='CheckClickBodyForm(this);' type='checkbox' value='" + formList[i].BodyFormID + "'>";
					bodyFormHtml += formList[i].FormName + "&nbsp;";
					bodyFormHtml += "<input type='button' class='AXButtonSmall' value='X' onclick='javascript:deleteBodyForm("+ formList[i].BodyFormID +")'/>";					
					bodyFormHtml += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>";
			}
			
			$('#spnBodyFormList').html("");
			$('#spnBodyFormList').append(bodyFormHtml);
		},
		error: function(response, status, error){
			CFN_ErrorAjax("/groupware/board/manage/selectBodyForm.do", response, status, error);
		}
	});
}

//본문양식 삭제
var deleteBodyForm = function(pBodyFormID){
	Common.Confirm("<spring:message code='Cache.msg_Common_08'/>", 'Confirmation Dialog', function(result){ // 선택한 항목을 삭제하시겠습니까?
		if (result) {
			$.ajax({
				type: 'POST',
				url: "/groupware/board/manage/deleteBodyForm.do",
				data: {
					"bodyFormID": pBodyFormID
				},
				dataType: 'json',
				success: function(data){	
					if(data.status=='SUCCESS'){
						Common.Inform("<spring:message code='Cache.msg_50'/>", "Information", function(){ // 저장되었습니다.
							selectBodyForm()
						});
					}else{
						Common.Warning("<spring:message code='Cache.msg_apv_030'/>");
					}
				},
				error: function(response, status, error){
					CFN_ErrorAjax("/groupware/board/manage/deleteBodyForm.do", response, status, error);
				}
			});
		}
	});
}

var setEnableFileExtention = function (folderType) {
	var enableFileExtentionArr = folderType != "Album" ? Common.getBaseConfig('EnableFileExtention').split(",") : Common.getBaseConfig('EnableFileImageExtention').split(",");
	
	$("#enableFileExtention").empty();	
	if(enableFileExtentionArr.length > 0) {
		for(var i = 0; i < enableFileExtentionArr.length; i++) {
			$("#enableFileExtention").append("<div class='chkStyle01'><input type='checkbox' id='chk_" + enableFileExtentionArr[i] + "' name='" + enableFileExtentionArr[i] + "'><label for='chk_" + enableFileExtentionArr[i] + "'><span></span>" + enableFileExtentionArr[i] + "</label></div>");
		}	
	}
	
	// 동영상 게시판일 경우 기초설정값의 EnableFileVideoExtention 확장자를 가져와서 필수 업로드 확장자로 설정
	if(folderType == "Video") {
		var enableFileVideoExtentionArr = Common.getBaseConfig('EnableFileVideoExtention').split(",");
		if(enableFileVideoExtentionArr.length > 0) {
			for(var j = 0; j < enableFileVideoExtentionArr.length; j++) {
				$("#chk_" + enableFileVideoExtentionArr[j]).prop('checked', true).prop("disabled", true);
			}
		}
	} else {
		$("#enableFileExtention").find("input[type='checkbox']").prop("disabled", false);
	}
	
	$("#chkAllFileExtention").prop('checked', false);
}

var bodyFormCheckFileName = function(str) {
    var fileName = str.split('\\').pop().toLowerCase();
    var ext =  str.split('.').pop().toLowerCase();
    
    if($.inArray(ext, ['txt', 'htm', 'html']) == -1) {
    	Common.Warning("<spring:message code='Cache.msg_uploadBodyFormFile'/>");  // txt, htm, html 파일만 업로드 할 수 있습니다.
    	$("#uploadFile").val("");
        return;
    }
}

// 만료일 해제 시 만료일 기준값 초기화여부
function confirmResetExpiredDate(target){
	if (!target.checked && $("#txtExpireDay").val() != '0'){
		Common.Confirm(Common.getDic('msg_initExpireDate'), "", function(result){			//만료일 기준을 초기화 하시겠습니까?
			if(result) {
				$("#txtExpireDay").val(0);
			}
		});
	}
}

function setEditor(){
	coviEditor.loadEditor(
		'divWebEditor',
		{
			editorType : g_editorKind,
			containerID : 'tbContentElement',
			frameHeight : '300',
			focusObjID : '',
			onLoad:  function(){
	        	coviEditor.setBody(g_editorKind, 'tbContentElement', g_editorBody);
	        }
		}
	);
}
/*********** 본문양식 끝 ***********/

var init = function() {
	setSelect();
	setEvent();
	
	if (mode === "create") {
		initCreate();
	} else {
		initEdit();
	}
		
	Common.toolTip($("#btn_base_tt"), "TT_BoardBaseOpt", "width:400px"); 				// 기본옵션.
	Common.toolTip($("#btn_add_tt"), "TT_BoardAddOpt", "width:400px"); 					// 부가옵션.
	Common.toolTip($("#btn_ext_tt"), "TT_BoardExtOpt", "width:400px"); 					// 확장옵션.
}

init();
</script>