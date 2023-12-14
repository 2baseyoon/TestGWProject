<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="comment_list_page">

	<header id="comment_list_header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript: mobile_comm_back();" class="topH_close"><span class="Hicon">닫기</span></a>
				<div class="menu_link">
					<a href="#" class="pg_tit"><spring:message code='Cache.lbl_Comments'/></a> <!-- 댓글 -->
					<em id="comment_list_allcnt"></em>
				</div>
			</div>
		</div>
		
	</header>

	<div data-role="content" class="cont_wrap" id="comment_list_content">
	
		<!-- 상단 제목 영역 -->
		<div class="post_title comment">
			<p id="commnet_list_location" class="post_location"><!-- 공지사항 --></p>
			<h2 id="commnet_list_title" class="tit"><!-- <span class="ico_notice"></span>JAVA 그룹웨어 프로젝트 표준 Guide --></h2>
		</div>
	
		<div class="section_comment wt">
		
			<!-- 댓글 입력 영역-기본 -->
			<div id="comment_list_writeBtn" class="u_cbox_write open" onclick="mobile_comment_changeWriteArea('open');">
				<div class="u_cbox_write_inner">
					<div class="u_cbox_write_area">
						<div class="u_cbox_inbox">
							<textarea class="u_cbox_text" rows="1" cols="30"></textarea>
							<label for="content" class="u_cbox_guide" style="top: auto;"><spring:message code='Cache.msg_Mobile_enterComment'/></label> <!-- 댓글을 입력하세요. -->
							<button type="button" onclick="" class="u_cbox_btn_upload">
								<span class="u_cbox_ico_upload"></span>
								<span class="u_cbox_txt_upload"><spring:message code='Cache.lbl_Regist'/></span> <!-- 등록 -->
							</button>
						</div>
					</div>
				</div>
			</div>
			
			<!-- 댓글 입력 영역-상세 -->
			<div id="comment_list_write" class="u_cbox_write">
				<div class="u_cbox_write_inner">
					<div class="u_cbox_profile_area">
						<div class="u_cbox_profile">
							<div class="u_cbox_box_name">
								<span class="u_cbox_write_name"></span>
								<a href="javascript: mobile_comment_changeWriteArea('close');" class="u_cbox_write_btn_close"></a>
							</div>
						</div>
					</div>
					<div class="u_cbox_write_area" >
						<div class="u_cbox_inbox">
							<textarea id="comment_list_write_txt" class="u_cbox_text" rows="3" cols="30" style="height: 55px;" placeholder="댓글을 입력하세요."></textarea>
						</div>
						<div id="mobile_attach_uploded_file" class="file_area" style="display: none;">
						</div>
						<div id="mobile_attach_uploded_img" class="img_area" style="display: none;">
						</div>
					</div>
					<div class="u_cbox_upload">
						<div class="u_cbox_addition">
							<button type="button" class="u_cbox_btn_upload_photo" onclick="javascript: $('#mobile_attach_input_img').click();">
								<span class="u_cbox_ico_upload_photo"></span>
								<span class="u_cbox_txt_upload_photo">사진</span>
							</button>
							<button type="button" class="u_cbox_btn_upload_file" onclick="javascript: $('#mobile_attach_input_file').click();">
								<span class="u_cbox_ico_upload_file"></span>
								<span class="u_cbox_txt_upload_file">파일</span>
							</button>
							<button type="button" class="u_cbox_btn_upload_location" onclick="javascript: $('#mobile_attach_input').click();" style="display: none;">
								<span class="u_cbox_ico_upload_location"></span>
								<span class="u_cbox_txt_upload_location">장소</span>
							</button>
							<input type="file" id="mobile_attach_input_img" onchange="mobile_comment_changeupload(this, 'img');" multiple style="display: none;"/>
							<input type="file" id="mobile_attach_input_file" onchange="mobile_comment_changeupload(this, 'file');" multiple style="display: none;"/>
						</div>
					</div>
					<button type="button" id="btnSave" onclick="mobile_comment_clickAddComment('list');" class="u_cbox_btn_upload">
						<span class="u_cbox_ico_upload"></span>
						<span class="u_cbox_txt_upload"><spring:message code='Cache.lbl_Regist'/></span> <!-- 등록 -->
					</button>
				</div>
			</div>
			
			<!-- 댓글 목록 -->
			<div covi-mo-comment></div>
		
		</div>
		
		<!-- 본문보기 -->
		<div id="comment_list_viewContent" class="main_text_more" style="display: none;">
			<a href="javascript: mobile_comm_back();" class="main_text_more_btn"><span class="tx"><spring:message code='Cache.lbl_viewBody'/></span></a> <!-- 본문보기 -->
		</div>
		
		<!-- 전체 댓글 보기 -->
		<div id="comment_list_viewFullComment" class="main_text_more" style="display: none;">
			<a href="javascript: mobile_comm_getFullComment();" class="main_text_more_btn"><span class="tx"><spring:message code='Cache.lbl_viewAllComments'/></span></a> <!--  전체 댓글 보기 -->
		</div>
	
	</div>
</div>

