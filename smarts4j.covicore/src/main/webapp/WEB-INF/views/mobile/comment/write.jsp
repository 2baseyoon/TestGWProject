<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="comment_write_page">

	<header data-role="header" id="comment_write_header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript: mobile_comm_back();" class="btn_close"><span><!-- 닫기 --></span></a>
				<div class="menu_link">
					<a href="#" class="pg_tit"><spring:message code='Cache.btn_Reply'/></a> <!-- 답글 -->
				</div>
			</div>
		</div>
		
	</header>

	<div data-role="content" class="cont_wrap" id="comment_write_content">
		
		<div class="section_comment re_write">
		
			<!-- 답글할 댓글 영역 -->
			<ul id="comment_write_info" class="comment_list"></ul>
			
			<!-- 댓글 입력 영역 -->
			<div id="comment_write_write" class="u_cbox_write open re">
				<div class="u_cbox_write_inner">
					<div class="u_cbox_profile_area">
						<div class="u_cbox_profile">
							<div class="u_cbox_box_name">
								<span class="u_cbox_write_name">홍길동 사원</span>
								<a href="javascript: mobile_comment_clearWrite();" class="u_cbox_write_btn_close"></a>
							</div>
						</div>
					</div>
					<div class="u_cbox_write_area">
						<div class="u_cbox_inbox">
							<textarea id="comment_write_write_txt" class="u_cbox_text" rows="3" cols="30" style="height: 55px;" placeholder=<spring:message code='Cache.msg_Mobile_enterComment'/>></textarea>
						</div>
						<div id="comment_write_write_add" class="img_area">
							<span class="img_area_btn">
								<a href="#" class="img_link"><span class="thum"><img src="../../resources/images/@ex_list_thum.jpg" alt=""></span></a>
								<a href="#" class="img_link_del"></a>
							</span>
							<span class="img_area_btn">
								<a href="#" class="img_link"><span class="thum video"><img src="../../resources/images/@ex_list_thum02.jpg" alt=""></span></a>
								<a href="#" class="img_link_del"></a>
							</span>
							<span class="img_area_btn">
								<a href="#" class="img_link"><span class="thum"><img src="../../resources/images/@ex_list_thum.jpg" alt=""></span></a>
								<a href="#" class="img_link_del"></a>
							</span>
						</div>
					</div>
					<div class="u_cbox_upload">
						<div class="u_cbox_addition">
							<button type="button" class="u_cbox_btn_upload_photo">
								<span class="u_cbox_ico_upload_photo"></span>
								<span class="u_cbox_txt_upload_photo">사진</span>
							</button>
							<button type="button" class="u_cbox_btn_upload_file">
								<span class="u_cbox_ico_upload_file"></span>
								<span class="u_cbox_txt_upload_file">파일</span>
							</button>
							<button type="button" class="u_cbox_btn_upload_location">
								<span class="u_cbox_ico_upload_location"></span>
								<span class="u_cbox_txt_upload_location">장소</span>
							</button>
						</div>
					</div>
					<button type="button" onclick="mobile_comment_clickAddComment('write');" class="u_cbox_btn_upload">
						<span class="u_cbox_ico_upload"></span>
						<span class="u_cbox_txt_upload"><spring:message code='Cache.lbl_Regist'/></span> <!-- 등록 -->
					</button>
				</div>
			</div>
			
          
          
          
		</div>
		
		
		
	
	</div>


</div>

