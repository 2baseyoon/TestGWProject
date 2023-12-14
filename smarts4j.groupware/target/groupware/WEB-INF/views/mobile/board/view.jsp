<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<% pageContext.setAttribute("isViewPanel", request.getParameter("isViewPanel")); %>

<div data-role="dialog" id="board_view_page" adata='view'>
	<header id="board_view_header">
		<div class="sub_header">
			<div class="l_header">
				<c:if test="${isViewPanel != 'Y'}">
					<a href="javascript: mobile_comm_back();" class="topH_close"><span class="Hicon">닫기</span></a>
				</c:if>
				<div class="menu_link"><a href="#" class="pg_tit"><spring:message code='Cache.lbl_DetailView' /></a></div><!-- 상세보기 -->
			</div>
			<div class="utill" style="display: none;">
          		<div class="dropMenu">
            		<a href="#" class="topH_exmenu" onclick="javascript: mobile_doc_showORhide(this);"><span class="Hicon">확장메뉴</span></a>
					<div class="exmenu_layer" >
						<ul class="exmenu_list">
							<li><a id="board_view_modify" href="#" class="btn"><spring:message code='Cache.btn_Edit' /></a></li> <!-- 수정 -->
							<li><a id="board_view_delete" href="#" class="btn"><spring:message code='Cache.btn_delete' /></a></li> <!-- 삭제 -->
							<li><a id="board_view_copy" href="#" class="btn"><spring:message code='Cache.btn_Copy' /></a></li> <!-- 복사 -->
							<li><a id="board_view_move" href="#" class="btn"><spring:message code='Cache.btn_Move' /></a></li> <!-- 이동 -->
							<li><a id="board_view_scrap" href="#" class="btn"><spring:message code='Cache.btn_Scrap' /></a></li> <!-- 스크랩 -->
							<li><a id="board_view_report" href="#" class="btn"><spring:message code='Cache.btn_Singo' /></a></li> <!-- 신고 -->
							<li><a id="board_view_viewerlist" href="#" class="btn"><spring:message code='Cache.btn_Viewer' /> <spring:message code='Cache.btn_List' /></a></li> <!-- 조회자 목록 -->
						</ul>
					</div>
        		</div>
			</div>
		</div>
	</header>

	<div data-role="content" class="cont_wrap" id="board_view_content">
		<div id="board_folder" style="text-align:right; border-bottom:1px solid grey; display:none;">
			<select id="board_folder_list" name="" class="full sel_type"></select>
			<a href="javascript:mobile_board_message_change();" id="board_view_change" class="g_btn01" style="margin-top:10px; margin-right:10px; margin-bottom:10px;"></a>
		</div>
		<!-- 글 정보 -->
		<div class="post_title">
			<p id="board_view_folder" class="post_location"><!-- 공지사항 --></p>
			<h2 id="board_view_subject" class="tit"></h2>
			<a href="#" class="thumb" style="background-image: url(/covicore/resources/images/common/noImg.png);"></a>
			<p class="info">
				<a id="board_view_writer" href="#" class="name"><!-- 홍길동 --></a>
			</p>
			<p class="info">
				<span id="board_view_writedate" class="date"><!-- 2017.10.12. 08:44 --></span>
				<span id="board_view_readcnt" class="ico_hits"><!-- 120 --></span>
			</p>
		</div>
		
		<!-- 첨부 정보 -->
		<div id="board_view_attach"></div>
		
		<div id="board_view_watermarkbody" class="watermarked" data-watermark="${WaterMark}">
			<!-- 사용자 정의필드 영역 -->
			<div id="board_view_userdef" class="post_ex_area" style="display:none;"></div>
			
			<!-- 링크 게시판 영역-->				
			<div id="board_view_linksite" class="post_ex_area" style="display:none;"></div>
			
			<!-- 본문 -->
			<div id="board_view_body" class="post_cont" style="padding-top:10px;min-height:100px;"></div>
			
			<!-- 좋아요 -->
			<div id="board_view_like" class="end_like_area"></div>
		</div>
		
		<!-- 카테고리/만료일 -->
		<div id="board_view_category" class="category_area"></div>
		
		<!-- 태그 -->
		<div id="board_view_tag" class="tag_area"></div>
		
		<!-- 링크 -->
		<div id="board_view_link" class="link_area"></div>	
		
		<!-- 댓글 -->
		<div covi-mo-comment></div>
		
		<!-- 이전글/다음글 -->
		<div id="board_view_prevnext" class="section_nav"></div>
		
		<!-- 승인/거부 -->
		<div class="fixed_btm_wrap">
			<div class="approval_comment" id="board_view_commentarea">
				<a class="btn_toggle" onclick="mobile_board_clickbtn(this, 'toggle');"></a>
				<div class="comment_inner">
					<div class="txt_area">
						<textarea name="name" id="board_view_inputcomment" placeholder="<spring:message code='Cache.msg_doc_inputProcessReason'/>"></textarea> <!-- 처리사유를 입력해주세요 -->
						<a onclick="mobile_board_doBtnClick('Y');" class="g_btn_sm" style="margin-right: 55px;"><spring:message code='Cache.btn_Confirm'/></a> <!-- 확인 -->
						<a onclick="mobile_board_doBtnClick('N');" class="g_btn_sm"><spring:message code='Cache.btn_Cancel'/></a> <!-- 취소 -->
					</div>
				</div>
			</div>
			<div id="board_view_btn_approval" class="btn_wrap" style="display: none;">
				<a id="board_view_allow" onclick="javascript: mobile_board_clickbtn(this, 'accept');" class="btn_approval"><i class="ico"></i><spring:message code='Cache.lbl_Approval'/></a> <!-- 승인 -->
				<a id="board_view_deny" onclick="javascript: mobile_board_clickbtn(this, 'reject');" class="btn_return"><i class="ico"></i><spring:message code='Cache.lbl_Deny'/></a> <!-- 거부 -->
			</div>			
		</div>
	</div>
</div>
