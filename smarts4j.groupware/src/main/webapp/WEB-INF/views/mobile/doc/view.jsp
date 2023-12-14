<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="doc_view_page" adata='view'>

	<header id="doc_view_header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript: mobile_comm_back();" class="topH_close"><span class="Hicon">닫기</span></a>
				<div class="menu_link"><a href="#" class="pg_tit"><spring:message code='Cache.lbl_DetailView'/></a></div><!-- 상세보기-->
			</div>
			<div class="utill" style="display: none;">
				<div class="dropMenu">
            		<a class="topH_exmenu ui-link" onclick="javascript: mobile_doc_showORhide(this);"><span class="Hicon">확장메뉴</span></a>
					<div class="exmenu_layer">
						<!-- <strong class="blind">본문 폰트 크기 조정</strong>
						<div class="font_box font_box_s">
							<a href="#" class="small dis"><span class="sim">본문 폰트 크기 작게 보기</span></a>
							<a href="#" class="big"><span class="sim">본문 폰트 크기 크게 보기</span></a>
							<span class="font_box_size font_zoom1">가</span>
						</div> -->
						<ul class="exmenu_list">
							<li id="doc_view_modify" style="display: none;"><a href="#" class="btn"><spring:message code='Cache.lbl_Modify'/></a></li> <!-- 수정 -->
							<li id="doc_view_delete" style="display: none;"><a href="#" class="btn"><spring:message code='Cache.lbl_delete'/></a></li> <!-- 삭제 -->
							<li id="doc_view_copy" style="display: none;"><a href="#" class="btn"><spring:message code='Cache.lbl_Copy'/></a></li> <!-- 복사 -->
							<li id="doc_view_move" style="display: none;"><a href="#" class="btn"><spring:message code='Cache.lbl_Move'/></a></li> <!-- 이동 -->
							<li id="doc_viewer_list" style="display: none;"><a href="#" class="btn"><spring:message code='Cache.btn_Viewer'/> <spring:message code='Cache.btn_List'/></a></li> <!-- 조회자 목록 -->
							<li id="doc_view_distribution" style="display: none;"><a href="#" class="btn"><spring:message code='Cache.btn_Doc_Distribution'/></a></li> <!-- 문서 배포 -->
							<li id="doc_view_requestAuth" style="display: none;"><a href="#" class="btn"><spring:message code='Cache.lbl_doc_requestAuth2'/></a></li> <!-- 권한 요청 -->
							<li id="doc_view_approvalAuth" style="display: none;"><a href="#" class="btn"><spring:message code='Cache.lbl_doc_manageAuth'/></a></li> <!-- 권한 관리 -->
							<li id="doc_view_checkout" style="display: none;"><a href="#" class="btn"><spring:message code='Cache.lbl_CheckOut'/></a></li> <!-- 체크아웃 -->
							<li id="doc_view_checkoutCancel" style="display: none;"><a href="#" class="btn"><spring:message code='Cache.lbl_CheckOut'/> <spring:message code='Cache.lbl_Cancel'/></a></li> <!-- 체크아웃 취소 -->
							<li id="doc_view_checkin" style="display: none;"><a href="#" class="btn"><spring:message code='Cache.lbl_CheckIn'/></a></li> <!-- 체크인 -->
						</ul>
					</div>
				</div>
			</div>
		</div>
	</header>

	<div data-role="content" class="cont_wrap" id="doc_view_content">
		<div id="board_folder" style="text-align:right; border-bottom:1px solid grey; display:none;">
			<select id="board_folder_list" name="" class="full sel_type"></select>
			<a href="javascript:mobile_board_message_change();" id="board_view_change" class="g_btn01" style="margin-top:10px; margin-right:10px; margin-bottom:10px;"></a>
		</div>
		<!-- 글 정보 -->
		<div class="post_title">
			<p id="doc_view_folder" class="post_location"></p>
			<h2 id="doc_view_subject" class="tit"></h2>
			<ul id="doc_view_folderpath" class="docu_location"></ul>
			<a href="#" class="thumb" style="background-image: url(../../resources/images/user_01.jpg);"></a><!-- TODO: 사진처리 -->
			<p class="info">
				<a id="doc_view_writer" href="#" class="name"></a>
			</p>
			<p class="info">
				<span id="doc_view_writedate" class="date"></span>
				<span id="doc_view_readcnt" class="ico_hits"></span>
			</p>
		</div>
		<div class="revision_area">
			<ul>
				<li id="doc_view_docNumber"><span class="label"><spring:message code='Cache.lbl_DocNo'/>: </span></li> <!-- 문서번호 -->
				<li id="doc_view_revisionName"><span class="label"><spring:message code='Cache.lbl_RevisionWriter'/>: </span></li> <!-- 개정자 -->
				<li id="doc_view_ownerName"><span class="label"><spring:message code='Cache.lbl_Owner'/>: </span></li> <!-- 소유자 -->
			</ul>
			<ul>
				<li id="doc_view_revisionDate"><span class="label"><spring:message code='Cache.lbl_RevisionDate'/>: </span></li> <!-- 개정일 -->
				<li id="doc_view_keepYear"><span class="label"><spring:message code='Cache.lbl_KeepYear'/>: </span></li> <!-- 보존년한 -->
				<li id="doc_view_expiredDate"><span class="label"><spring:message code='Cache.lbl_ExpireDate'/>: </span></li> <!-- 만료일 -->
			</ul>
		</div>

		<!-- 첨부 정보 -->
		<div id="doc_view_attach"></div>

		<!-- 본문 -->
		<div id="doc_view_body" class="post_cont"  style="padding-top:10px;min-height:100px;"></div>

		<!-- 태그 -->
		<div id="doc_view_tag" class="tag_area"></div>

		<!-- 바인더 -->
		<div id="doc_view_linkedDoc" class="link_area">
			<span class="tit"><spring:message code='Cache.lbl_Binder' /></span> <!-- 바인더 -->
			<!-- <a href="#" class=""><span class="">코비젼블로그</span></a>
	      	<a href="#" class=""><span class="">코비젼홈페이지</span></a> -->
		</div>

		<!-- 상세권한 -->
		<div id="doc_view_detailAuth" class="category_area">
			<span class="tx auth_tx">
				<strong><spring:message code='Cache.lbl_MessageDetailAuth'/> :</strong>  <!-- 상세권한 -->
			</span>
		</div>

		<!-- 댓글 -->
		<div covi-mo-comment></div>

		<!-- 개정정보 -->
		<div id="doc_view_revisionInfo" class="revision_info"></div>

		<!-- 이전글/다음글 -->
		<div id="doc_view_prevnext" class="section_nav"></div>

		<div class="fixed_btm_wrap">
			<div class="approval_comment" id="doc_view_commentarea">
				<a class="btn_toggle" onclick="mobile_doc_clickbtn(this, 'toggle');"></a>
				<div class="comment_inner">
					<div class="txt_area">
						<textarea name="name" id="doc_view_inputcomment" placeholder="<spring:message code='Cache.msg_doc_inputProcessReason'/>"></textarea> <!-- 처리사유를 입력해주세요 -->
						<a onclick="mobile_doc_doBtnClick('Y');" class="g_btn_sm" style="margin-right: 55px;"><spring:message code='Cache.btn_Confirm'/></a> <!-- 확인 -->
						<a onclick="mobile_doc_doBtnClick('N');" class="g_btn_sm"><spring:message code='Cache.btn_Cancel'/></a> <!-- 취소 -->
					</div>
				</div>
			</div>
			<div id="doc_view_btn_approval" class="btn_wrap" style="display: none;">
				<a id="doc_view_allow" onclick="javascript: mobile_doc_clickbtn(this, 'accept');" class="btn_approval"><i class="ico"></i><spring:message code='Cache.lbl_Approval'/></a> <!-- 승인 -->
				<a id="doc_view_deny" onclick="javascript: mobile_doc_clickbtn(this, 'reject');" class="btn_return"><i class="ico"></i><spring:message code='Cache.lbl_Deny'/></a> <!-- 거부 -->
			</div>
		</div>
	</div>
</div>
