<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="doc_auth_page">

	<header data-role="header" id="doc_auth_header">
		<div class="sub_header">
			<div class="l_header">
				<a class="topH_close" id="doc_auth_backBtn"><span>닫기</span></a>
				<div class="menu_link"><a href="#" class="pg_tit"><spring:message code='Cache.lbl_Authority'/> <spring:message code='Cache.lbl_Request'/></a></div><!-- 권한 요청 -->
			</div>
		</div>
	</header>

	<div data-role="content" class="cont_wrap" id="doc_auth_content">
		<!-- 글 정보 -->
		<div class="post_title">
			<h2 id="doc_auth_subject" class="tit"></h2>
			<ul id="doc_auth_folderpath" class="docu_location"></ul>
			<a href="#" id="doc_auth_thumb" class="thumb" style="background-image: url(../../resources/images/user_01.jpg);"></a><!-- TODO: 사진처리 -->
			<p class="info">
				<a id="doc_auth_requester" href="#" class="name"></a>
			</p>
			<p class="info">
				<span id="doc_auth_requestdate" class="date"></span>
			</p>
		</div>
		<div class="ask_auth">
			<div id="doc_auth_div_current" style="display:none;">
				<p class="list_tit"><spring:message code='Cache.lbl_doc_currentAuth'/></p> <!-- 현재권한 -->
				<ul>
					<li>
						<span class="label"><spring:message code='Cache.lbl_doc_securityAuth'/></span> <!-- 보안권한 -->
						<div id="doc_auth_secretAuth_C" class="opt_setting disable"><span class="ctrl"></span></div>
					</li>
					<li>
						<span class="label"><spring:message code='Cache.lbl_doc_modifyAuth'/></span> <!-- 수정권한 -->
						<div id="doc_auth_modifyAuth_C" class="opt_setting disable"><span class="ctrl"></span></div>
					</li>
					<li>
						<span class="label"><spring:message code='Cache.lbl_doc_executeAuth'/></span> <!-- 실행권한 -->
						<div id="doc_auth_executeAuth_C" class="opt_setting disable"><span class="ctrl"></span></div>
					</li>
					<li>
						<span class="label"><spring:message code='Cache.lbl_doc_readAuth'/></span> <!-- 읽기권한 -->
						<div id="doc_auth_readAuth_C" class="opt_setting disable"><span class="ctrl"></span></div>
					</li>
					<li>
						<span class="label"><spring:message code='Cache.lbl_doc_deleteAuth'/></span> <!-- 삭제권한 -->
						<div id="doc_auth_deleteAuth_C" class="opt_setting disable"><span class="ctrl"></span></div>
					</li>
				</ul>
			</div>
			<div id="doc_auth_div_request" style="display:none;">
				<p class="list_tit"><spring:message code='Cache.lbl_doc_requestAuth'/></p> <!-- 요청권한 -->
				<ul>
					<li>
						<span class="label"><spring:message code='Cache.lbl_doc_securityAuth'/></span> <!-- 보안권한 -->
						<div id="doc_auth_secretAuth_R" class="opt_setting"><span class="ctrl"></span></div>
					</li>
					<li>
						<span class="label"><spring:message code='Cache.lbl_doc_modifyAuth'/></span> <!-- 수정권한 -->
						<div id="doc_auth_modifyAuth_R" class="opt_setting"><span class="ctrl"></span></div>
					</li>
					<li>
						<span class="label"><spring:message code='Cache.lbl_doc_executeAuth'/></span> <!-- 실행권한 -->
						<div id="doc_auth_executeAuth_R" class="opt_setting"><span class="ctrl"></span></div>
					</li>
					<li>
						<span class="label"><spring:message code='Cache.lbl_doc_readAuth'/></span> <!-- 읽기권한 -->
						<div id="doc_auth_readAuth_R" class="opt_setting"><span class="ctrl"></span></div>
					</li>
					<li>
						<span class="label"><spring:message code='Cache.lbl_doc_deleteAuth'/></span> <!-- 삭제권한 -->
						<div id="doc_auth_deleteAuth_R" class="opt_setting"><span class="ctrl"></span></div>
					</li>
				</ul>
			</div>
			<p class="list_tit"><spring:message code='Cache.lbl_Reason'/></p> <!-- 사유 -->
			<textarea id="doc_auth_inputreason" placeholder="<spring:message code='Cache.msg_doc_inputRequestReason'/>" style="display: none;"></textarea> <!-- 요청 사유를 입력해주세요 -->
			<p id="doc_auth_txtreason" class="reason_desc" style="display: none;"></p>
		</div>
		
		<div class="fixed_btm_wrap">
			<div class="approval_comment" id="doc_auth_commentarea">
				<a class="btn_toggle" onclick="mobile_doc_clickbtn(this, 'toggle');"></a>
				<div class="comment_inner">
					<div class="txt_area">
						<textarea name="name" id="doc_auth_inputcomment" placeholder="<spring:message code='Cache.msg_doc_inputProcessReason'/>"></textarea> <!-- 처리 사유를 입력해주세요 -->
						<a onclick="mobile_doc_doBtnClick('Y');" class="g_btn_sm"><spring:message code='Cache.lbl_Confirm'/></a> <!-- 확인 -->
					</div>
				</div>
			</div>
			<div id="doc_auth_btn_request" class="btn_wrap" style="display: none;">
				<!--  버튼 1개 일 경우 a 태그에 full 클래스 추가 -->
				<a id="doc_auth_allow" onclick="javascript: mobile_doc_clickbtn(this, 'request');" class="btn_approval full"><i class="ico"></i><spring:message code='Cache.lbl_ApprovalRequest'/></a> <!-- 승인요청 -->
			</div>
			<div id="doc_auth_btn_approval" class="btn_wrap" style="display: none;">
				<a id="doc_auth_allow" onclick="javascript: mobile_doc_clickbtn(this, 'allow');" class="btn_approval"><i class="ico"></i><spring:message code='Cache.lbl_Approval'/></a> <!-- 승인 -->
				<a id="doc_auth_deny" onclick="javascript: mobile_doc_clickbtn(this, 'deny');" class="btn_return"><i class="ico"></i><spring:message code='Cache.lbl_Reject'/></a> <!-- 거부 -->
			</div>
		</div>
		
		<input type="hidden" id="doc_auth_hidOwnerCode">
	</div>
</div>
