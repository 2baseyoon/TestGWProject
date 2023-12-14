<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<form id="formData" method="post" enctype="multipart/form-data">

	<div data-role="page" id="board_write_page">
	
		<header id="board_write_header">
			<div class="sub_header">
				<div class="l_header">
					<a href="javascript: mobile_comm_back();" class="topH_close"><span class="Hicon">닫기</span></a>
					<div class="menu_link"><a id="board_write_mode" href="#" class="pg_tit"><spring:message code='Cache.btnWrite' /></a></div><!-- 작성 -->
				</div>
				<div class="utill">
					<a id="board_write_tempsave" href="javascript: mobile_board_tempsave();" class="topH_draft"><span class="Hicon">임시저장</span></a>
					<a id="board_write_save" href="javascript: mobile_board_save('C');" class="topH_save"><span class="Hicon">등록</span></a>
				</div>
			</div>
		</header>
	
		<div data-role="" class="cont_wrap" id="board_write_content">
			<div class="write_wrap">
				<!-- 게시판/카테고리 선택 -->
				<select id="board_write_folder" name="" class="full sel_type" onchange="javascript: mobile_board_changefolder('Y');">
					<option value=""><spring:message code='Cache.lbl_board_selectBoardFolder' /></option><!-- 게시판 선택 -->
				</select>
				<select id="board_write_category" name="" class="full sel_type" style="display: none;">
					<option value=""><spring:message code='Cache.lbl_JvCate' /></option><!-- TODO: 카테고리 목록 추가 --><!-- 카테고리 -->
				</select>
				<!-- 글 제목 -->
				<div class="title_wrap">
					<input type="text" id="board_write_title" voiceInputType="change" voiceStyle="" voiceCallBack=""  class="full mobileViceInputCtrl" placeholder="<spring:message code='Cache.lbl_subject' />"><!-- 제목 -->
					<div class="setting_tit">
						<a href="#" id="board_write_istop" onclick="mobile_board_clickUiSetting(this, 'on');" class="ico_notice_btn"></a>
						<a href="#" id="board_write_ispopup" onclick="mobile_board_clickUiSetting(this, 'on');" class="ico_popup_btn"></a>
						<a href="javascript: mobile_board_titlebold();" class="ico_bold" style="display: none;"></a>
						<a href="javascript: mobile_board_titlecolor();" class="ico_font_color" style="display: none;"><span id="board_write_titlecolor" class="font_color black"></span></a>
					</div>
					<div class="font_color_layer">
						<ul class="font_color_layer_list">
							<li><a href="javascript: mobile_board_titlecolor2('black');" class="black selected"></a></li>
							<li><a href="javascript: mobile_board_titlecolor2('red');" class="red"></a></li>
							<li><a href="javascript: mobile_board_titlecolor2('orange');" class="orange"></a></li>
							<li><a href="javascript: mobile_board_titlecolor2('yellow');" class="yellow"></a></li>
							<li><a href="javascript: mobile_board_titlecolor2('green');" class="green"></a></li>
						</ul>
						<ul class="font_color_layer_list">
							<li><a href="javascript: mobile_board_titlecolor2('blue');" class="blue"></a></li>
							<li><a href="javascript: mobile_board_titlecolor2('navy');" class="navy"></a></li>
							<li><a href="javascript: mobile_board_titlecolor2('skyblue');" class="skyblue"></a></li>
							<li><a href="javascript: mobile_board_titlecolor2('darkgray');" class="darkgray"></a></li>
						</ul>
					</div>
				</div>
				
				<!-- 사용자 정의 필드 -->
				<a href="javascript: mobile_board_opencloseuserdef();" class="acc_link"><spring:message code='Cache.lbl_board_UserField' /></a> <!-- 사용자 정의 필드 -->
				<div id="board_write_userdef" class="post_ex_area acc_cont"></div>
				
				<!-- 링크사이트 필드 -->
				<div id="board_write_linksite" class="links_wrap">
					<input type="text" id="board_write_linksite_input" voiceInputType="change" voiceStyle="margin-right:-8px;margin-top:-16px;" voiceCallBack=""  title="<spring:message code='Cache.lbl_URL' />" name="linksite" class="inputbox links_n mobileViceInputCtrl" value="http://">
				</div>
				
				<!--본문양식 -->
				<div id="board_BodyForm" class="post_ex_area" style="display:block;padding:0 15px;position:relative">
					<div style="padding:10px 0;color:#666;" class="post_ex">
						<span style="width:80px"><spring:message code='Cache.lbl_BodyForm'/></span>
						<span>
							<select id="board_BodyFormID" onchange="javascript: mobile_board_bodyformdata($(this).val(), 'Y');" style="width:80px"></select>
						</<span>
					</div>
				</div>
				
				<!-- 내용 -->
				<div id="editor_wrap" class="editor_wrap">
					<textarea id="board_write_body" name="name"  voiceInputType="append" voiceStyle="" voiceCallBack=""  class="full mobileViceInputCtrl" placeholder="<spring:message code='Cache.lbl_Contents' />"></textarea><!-- 내용 -->
				</div>
				
				<!-- 첨부 정보 -->
				<div covi-mo-attachupload system="Board"></div>
				
				<!-- 태그 -->
				<div id="board_write_tags" class="tags_wrap active">
				  <div class="tags_a" id="board_write_tagarea" style="display:;" >
					  <div id="board_write_tagarea_wrap" class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset">
					  	<input type="text" id="board_write_taginput" title="태그입력"  voiceInputType="change" voiceStyle="margin-right:30px;" voiceCallBack=""  name="tagnames" class="inputbox tags_n mobileViceInputCtrl" placeholder="<spring:message code='Cache.lbl_board_enterTag' />">
					  </div>
				  </div>
				  <a href="javascript: mobile_board_addtag();" class="btn_add_n ui-link">추가</a>
				</div>
				
				<!-- 링크 -->			
				<div id="board_write_links" class="links_wrap">
					<div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset text_in_wrap">
						<input type="text" id="board_write_linkname" voiceInputType="change" voiceStyle="margin-right:-8px;margin-top:-16px;" voiceCallBack=""  title="<spring:message code='Cache.lbl_LinkNm' />" name="linknames" class="inputbox links_n fname mobileViceInputCtrl" placeholder="<spring:message code='Cache.lbl_LinkNm' />">
					</div>
					<div class="ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset">
						<input type="text" id="board_write_linkurl" title="<spring:message code='Cache.msg_EnterLinkURL' />" name="linknames" class="inputbox links_n" placeholder="<spring:message code='Cache.msg_EnterLinkURL' />">
					</div>
					<a href="javascript: mobile_board_addlink();" class="btn_add_n ui-link"><spring:message code='Cache.btn_Add' /></a>
				</div>
				<div id="board_write_linkarea_wrap" style="display: none;" class="links_wrapD">
					<div class="links_a" id="board_write_linkarea"></div>
				</div>
				
				<!-- 상세설정 -->
				<a href="javascript: mobile_board_openclosedetail();" id="mobile_write_detail" class="acc_link_n acc_close ui-link"><spring:message code='Cache.lbl_doc_detailSetting' /></a> <!-- 상세설정 -->
				
				<div class="detail_config_area acc_cont">
				
					<!-- 비밀글/스크랩 -->
					<div class="detail_config_info">
						<dl class="dl_half">
							<dt><spring:message code='Cache.lbl_chkSecurity' /></dt><!-- 비밀글 -->
							<dd>
								<div id="board_write_security" onclick="" class="opt_setting"><!-- TODO: 기본값 셋팅 -->
									<span class="ctrl"></span>
								</div>
							</dd>
						</dl>
						<dl class="dl_half">
							<dt><spring:message code='Cache.btn_Scrap' /></dt><!-- 스크랩 -->
							<dd>
								<div id="board_write_scrap" onclick="" class="opt_setting"><!-- TODO: 기본값 셋팅 -->
									<span class="ctrl"></span>
								</div>
							</dd>
						</dl>
					</div>
					
					<!-- 답글알림/댓글알림 -->
					<div class="detail_config_info" style="display: none;">
						<dl class="dl_half">
							<dt><spring:message code='Cache.lbl_chkReply' /></dt><!-- 답글알림 -->
							<dd>
								<div id="board_write_replynoti" onclick=";" class="opt_setting"><!-- TODO: 기본값 셋팅 -->
									<span class="ctrl"></span>
								</div>
							</dd>
						</dl>
						<dl class="dl_half">
							<dt><spring:message code='Cache.lbl_commentNotify' /></dt><!-- 댓글알림 -->
							<dd>
								<div id="board_write_commnoti" onclick="" class="opt_setting"><!-- TODO: 기본값 셋팅 -->
									<span class="ctrl"></span>
								</div>
							</dd>
						</dl>
					</div>
					
					<!-- 작성자 -->
					<div class="detail_config_info">
						<dl>
							<dt><spring:message code='Cache.lbl_writer' /></dt><!-- 작성자 -->
							<dd>
								<div class="detail_config_chk writerinfo"><!-- writerinfo 클래스는 jquery용 임시 클래스 -->
									<input type="text" id="board_write_anonymname"  style="width: 130px; margin-right: 10px; background-color: #d9d9d9;" disabled>
									<input type="checkbox" id="board_write_anonym" onclick="mobile_board_ctrlAnonymWrite('user');" value="user">
									<label for="board_write_anonym"><spring:message code='Cache.lbl_Anonymity' /></label><!-- 익명 -->
									<input type="checkbox" id="board_write_dept" onclick="mobile_board_ctrlAnonymWrite('dept');" value="dept">
									<label for="board_write_dept"><spring:message code='Cache.lbl_DeptName' /></label><!-- 부서명 -->
								</div>
							</dd>
						</dl>
					</div>
				
					<!-- 보안등급 -->
					<div class="detail_config_info">
						<dl>
							<dt><spring:message code='Cache.lbl_SecurityLevel' /></dt><!-- 보안등급 -->
							<dd>
								<select id="board_write_seclevel" class="sec_level_sel">
									<option value=""><spring:message code='Cache.lbl_noexists' /></option><!-- 없음 -->
								</select>
							</dd>
						</dl>
					</div>
					
					<!-- 열람권한 -->
					<div class="detail_config_info">
						<dl>
							<dt><spring:message code='Cache.lbl_MessageReadAuth' /></dt><!-- 열람권한 -->
							<dd>
								<a href="javascript: mobile_board_openOrg('ReadAuth');" class="g_btn01"><i class="add"></i><spring:message code='Cache.btn_Add' /></a><!-- 추가 -->
							</dd>
							<dd id="board_write_readauth" class="name_list_wrap" style="display: none;">
							</dd>
						</dl>
					</div>
					
					<!-- 상세권한 -->
					<div class="detail_config_info">
						 <dl>
						 <dt><spring:message code='Cache.lbl_MessageDetailAuth' /></dt> <!-- 상세권한 -->
							 <dd>
							 <a onclick="mobile_board_openOrg('Auth')" class="g_btn01"><i class="add"></i><spring:message code='Cache.btn_Add' /></a> <!-- 추가 -->
							</dd>
							<dd class="name_list_detail_wrap">
								<div class="name_wrap" id="board_write_auth" style="display:none;">
								</div>
								<div id="board_write_switchList" class="detail_wrap" style="display: none;">
									<dl>
										<dt><spring:message code='Cache.btn_Security' /></dt> <!-- 보안 -->
										<dd>
											<div class="opt_setting" id="board_write_btnSecurity" onclick="mobile_board_setSwitchACLList(this, 0);">
												<span class="ctrl"></span>
											</div>
										</dd>
									</dl>
									<dl>
										<dt><spring:message code='Cache.lbl_Creation' /></dt> <!-- 생성 -->
										<dd>
											<div class="opt_setting" id="board_write_btnCreate" onclick="mobile_board_setSwitchACLList(this, 1);">
												<span class="ctrl"></span>
											</div>
										</dd>
									</dl>
									<dl>
										<dt><spring:message code='Cache.btn_delete' /></dt> <!-- 삭제 -->
										<dd>
											<div class="opt_setting" id="board_write_btnDelete" onclick="mobile_board_setSwitchACLList(this, 2);">
												<span class="ctrl"></span>
											</div>
										</dd>
									</dl>									
									<dl>
										<dt><spring:message code='Cache.btn_Modify' /></dt> <!-- 수정 -->
										<dd>
											<div class="opt_setting" id="board_write_btnModify" onclick="mobile_board_setSwitchACLList(this, 3);">
												<span class="ctrl"></span>
											</div>
										</dd>
									</dl>
									<dl>
										<dt><spring:message code='Cache.lbl_ACL_Execute' /></dt> <!-- 실행 -->
										<dd>
											<div class="opt_setting" id="board_write_btnExecute" onclick="mobile_board_setSwitchACLList(this, 4);">
												<span class="ctrl"></span>
											</div>
										</dd>
									</dl>
									<dl>
										<dt><spring:message code='Cache.lbl_ACL_Read' /></dt> <!-- 읽기 -->
										<dd>
											<div class="opt_setting" id="board_write_btnRead" onclick="mobile_board_setSwitchACLList(this, 5);">
												<span class="ctrl"></span>
											</div>
										</dd>
									</dl>
									<dl id="IsSubInclude_SwitchArea" style="display: none;">
										<dt><spring:message code='Cache.lbl_SubInclude' /></dt> <!-- 하위포함 -->
										<dd>
											<div class="opt_setting" id="board_write_btnIsSubInclude" onclick="mobile_board_setSwitchACLList(this);">
												<span class="ctrl"></span>
											</div>
										</dd>
									</dl>
								</div>
							</dd>
						</dl>
					</div>
					
					<!-- 알림설정 -->
					<div id="board_write_notification" class="detail_config_info">
						<dl>
							<dt><spring:message code='Cache.lbl_Alram' /></dt><!-- 알림 -->
							<dd>
								<div class="detail_config_info_sub">
									<dl class="dl_half">
										<dt><spring:message code='Cache.btn_Mail' /></dt><!-- 메일 -->
										<dd>
											<div id="board_write_notiMail"  value="MAIL" onclick="" class="opt_setting"><!-- TODO: 기본값 셋팅 -->
												<span class="ctrl"></span>
											</div>
										</dd>
									</dl>
									<dl class="dl_half">
										<dt>To-Do</dt><!-- TODO: 다국어처리 -->
										<dd>
											<div id="board_write_notiTODOLIST"   value="TODOLIST" onclick="" class="opt_setting"><!-- TODO: 기본값 셋팅 -->
												<span class="ctrl"></span>
											</div>
										</dd>
									</dl>
								</div>
							</dd>
						</dl>
					</div>
					
					<!-- 상단공지/등록예약 -->
					<div class="detail_config_info">
						<dl>
							<dt><spring:message code='Cache.lbl_board_settingPeriod' /></dt><!-- 기간설정 -->
							<dd class="detail_config_date_wrap">
								<dl>
									<dt>
										<input type="checkbox" value="" id="board_expired" >
										<label for="board_expired"><spring:message code='Cache.lbl_ExpireDate' /></label><!-- 만료일 -->
									</dt>
									<dd>
										<input type="text" id="board_expired_date" class="input_date date_time txt_center full">
									</dd>
								</dl>
								<dl>
									<dt>
										<input type="checkbox" value="" id="board_top" onclick="mobile_board_ctrlNotice();">
										<label for="board_top"><spring:message code='Cache.lbl_NoticeTop' /></label><!-- 상단공지 -->
									</dt>
									<dd>
										<input type="text" id="board_top_start" class="input_date to_for" style='width:108px;'><span class="tx_for">~</span><input type="text" id="board_top_end" class="input_date to_for" style='width:108px;'>
									</dd>
								</dl>
								<dl>
									<dt>
										<input type="checkbox" value="" id="board_popup" onclick="mobile_board_ctrlNotice();">
										<label for="board_popup"><spring:message code='Cache.lbl_NoticePopup' /></label><!-- 팝업공지 -->
									</dt>
									<dd>
										<input type="text" id="board_popup_start" class="input_date to_for" style='width:108px;'><span class="tx_for">~</span><input type="text" id="board_popup_end" class="input_date to_for" style='width:108px;'>
									</dd>
								</dl>
								<dl>
									<dt>
										<input type="checkbox" id="board_reservation">
										<label for="board_reservation"><spring:message code='Cache.lbl_RegBooking' /></label><!-- 등록예약 -->
									</dt>
									<dd>
										<input type="text" id="board_reservation_date" class="input_date date_time">
										<select id="board_reservation_time" class="input_time date_time">
											<option value="">00:00</option>
										</select>
									</dd>
								</dl>
							</dd>
						</dl>
					</div>
				</div>
			</div>
		</div>
		
	</div>

</form>