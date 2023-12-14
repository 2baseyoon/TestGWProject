<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<form id="formData" method="post" enctype="multipart/form-data">

	<div data-role="page" id="doc_write_page">
	
		<header id="doc_write_header">
			<div class="sub_header">
				<div class="l_header">
					<a href="javascript: mobile_comm_back();" class="topH_close"><span class="Hicon">닫기</span></a>
					<div class="menu_link"><a id="doc_write_mode" href="#" class="pg_tit"><spring:message code='Cache.btnWrite'/></a></div>
				</div>
				<div class="utill">
					<a id="doc_write_save" href="javascript: mobile_doc_save();" class="topH_save"><span class="Hicon">등록</span></a>
					<!--<a id="doc_write_tempsave" href="javascript: mobile_doc_tempsave();" class="btn_txt">임시저장</a>-->
					<a id="doc_write_confirm" href="javascript: mobile_doc_confirm();" class="topH_save" style="display: none;"><span class="Hicon">확인</span></a>
					<a id="doc_write_saveRevision" href="javascript: mobile_doc_saveRevision();" class="btn_txt" style="display: none;"><spring:message code='Cache.btn_Revision'/></a><!-- 개정 -->
				</div>
			</div>
		</header>
	
		<div data-role="content" class="cont_wrap" id="doc_write_content">
			<div class="write_wrap">
			
				<!-- 게시판/카테고리 선택 -->
				<select id="doc_write_folder" name="" class="full sel_type" onchange="javascript: mobile_board_changefolder();">
					<option value=""><spring:message code='Cache.lbl_DocCate'/></option><!-- 문서분류 -->
				</select>
				
				<!-- 글 제목 -->
				<div class="title">
					<input type="text" id="doc_write_title" voiceInputType="change" voiceStyle="" voiceCallBack=""  class="full mobileViceInputCtrl" placeholder="<spring:message code='Cache.lbl_Title'/>"><!-- 제목 -->
					<div class="setting_tit">
						<a href="javascript: mobile_board_titlebold();" class="ico_bold" style="display: none;"></a>
						<a href="javascript: mobile_board_titlecolor();" class="ico_font_color" style="display: none;"><span id="doc_write_titlecolor" class="font_color black"></span></a>
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
				
				<div class="docu_num">
		          <input type="text" id="doc_write_docNumber" value="" placeholder="<spring:message code='Cache.lbl_DocNo'/>" class="full"> <!-- 문서번호 -->
		        </div>
				<div class="editor_wrap">
					<!-- 내용 -->
					<textarea id="doc_write_body" name="name" class="full mobileViceInputCtrl" voiceInputType="append" voiceStyle="" voiceCallBack=""  placeholder="<spring:message code='Cache.lbl_EnterContents'/>"></textarea><!-- 내용을 입력하세요. -->
					<!-- 내용(editor contents) -->
					<div id="doc_write_bodyContents" style="display: none;"></div>
				</div>
				<!-- 첨부 정보 -->
				<div covi-mo-attachupload system="Doc"></div>
				
				<!-- 상세설정 -->
				<a href="javascript: mobile_board_openclosedetail();" id="mobile_write_detail" class="acc_link_n acc_close ui-link"><spring:message code='Cache.lbl_doc_detailSetting' /></a> <!-- 상세설정 -->
				<div class="detail_config_area acc_cont">
					<div class="detail_config_info">
		            <dl>
		              <dt><spring:message code='Cache.lbl_Register'/></dt> <!-- 등록자 -->
		              <dd id="doc_write_creatorName"></dd>
		            </dl>
		            <dl>
		              <dt><spring:message code='Cache.lbl_RegistDept'/></dt> <!-- 등록부서 -->
		              <dd>
		                <select id="doc_write_registDept"></select>
		              </dd>
		            </dl>
<!-- 보안등급 -->
					<dl>
						<dt><spring:message code='Cache.lbl_SecurityLevel' /></dt><!-- 보안등급 -->
						<dd>
							<select id="doc_write_seclevel" class="sec_level_sel">
								<option value=""><spring:message code='Cache.lbl_noexists' /></option><!-- 없음 -->
							</select>
						</dd>
					</dl>
					<dl>
		              <dt><spring:message code='Cache.lbl_Owner'/></dt> <!-- 소유자 -->
		              <dd>
		                <a onclick="mobile_doc_openOrg('Owner')" class="g_btn01"><i class="add"></i><spring:message code='Cache.lbl_Add'/></a> <!-- 추가 -->
		              </dd>
		              <dd id="doc_write_owner" class="name_list_wrap" style="display: none;">
					  </dd>
		            </dl>
		            <dl>
		              <dt><spring:message code='Cache.lbl_KeepYear'/></dt> <!-- 보존년한 -->
		              <dd>
		                <select id="doc_write_selectKeepyear" onchange="mobile_doc_changeKeepYear(this)">
		               		<option value="1">1<spring:message code='Cache.lbl_year'/></option>
							<option value="3" selected>3<spring:message code='Cache.lbl_year'/></option>
							<option value="5">5<spring:message code='Cache.lbl_year'/></option>
							<option value="7">7<spring:message code='Cache.lbl_year'/></option>
							<option value="10">10<spring:message code='Cache.lbl_year'/></option>
							<option value="99"><spring:message code='Cache.lbl_permanence'/></option> <!-- 영구 -->		                
		                </select>
		              </dd>
		            </dl>
		          </div>
		          <div class="detail_config_info">
		            <dl>
		              <dt><spring:message code='Cache.lbl_MessageDetailAuth'/></dt> <!-- 상세권한 -->
		              <dd>
		                <a onclick="mobile_doc_openOrg('Auth')" class="g_btn01"><i class="add"></i><spring:message code='Cache.lbl_Add'/></a> <!-- 추가 -->
		              </dd>
		              <dd class="name_list_detail_wrap">
		                <div class="name_wrap" id="doc_write_auth" style="display:none;">
		                  <!-- <a href="#" class="btn_add_person selected">김연아</a> -->
						</div>
		                <div id="doc_write_switchList" class="detail_wrap" style="display: none;">
		                  <dl>
		                    <dt><spring:message code='Cache.btn_Security'/></dt> <!-- 보안 -->
		                    <dd>
		                      <div class="opt_setting" id="doc_write_btnSecurity" onclick="mobile_doc_setSwitchACLList(this, 0);">
		                        <span class="ctrl"></span>
		                      </div>
		                    </dd>
		                  </dl>
		                  <dl>
		                    <dt><spring:message code='Cache.lbl_Creation'/></dt> <!-- 생성 -->
		                    <dd>
		                      <div class="opt_setting" id="doc_write_btnCreate" onclick="mobile_doc_setSwitchACLList(this, 1);">
		                        <span class="ctrl"></span>
		                      </div>
		                    </dd>
		                  </dl>
		                  <dl>
		                    <dt><spring:message code='Cache.lbl_delete'/></dt> <!-- 삭제 -->
		                    <dd>
		                      <div class="opt_setting" id="doc_write_btnDelete" onclick="mobile_doc_setSwitchACLList(this, 2);">
		                        <span class="ctrl"></span>
		                      </div>
		                    </dd>
		                  </dl>
		                  <dl>
		                    <dt><spring:message code='Cache.lbl_Modify'/></dt> <!-- 수정 -->
		                    <dd>
		                      <div class="opt_setting" id="doc_write_btnModify" onclick="mobile_doc_setSwitchACLList(this, 3);">
		                        <span class="ctrl"></span>
		                      </div>
		                    </dd>
		                  </dl>
		                  <dl>
							<dt><spring:message code='Cache.lbl_ACL_Execute' /></dt> <!-- 실행 -->
							<dd>
								<div class="opt_setting" id="doc_write_btnExecute" onclick="mobile_doc_setSwitchACLList(this, 4);">
									<span class="ctrl"></span>
								</div>
							</dd>
							</dl>
		                  <dl>
		                    <dt><spring:message code='Cache.lbl_Read'/></dt> <!-- 읽기 -->
		                    <dd>
		                      <div class="opt_setting" id="doc_write_btnRead" onclick="mobile_doc_setSwitchACLList(this, 5);">
		                        <span class="ctrl"></span>
		                      </div>
		                    </dd>
		                  </dl>		                  
		                  <dl id="IsSubInclude_SwitchArea" style="display: none;">
							<dt><spring:message code='Cache.lbl_SubInclude' /></dt> <!-- 하위포함 -->
							<dd>
								<div class="opt_setting" id="doc_write_btnIsSubInclude" onclick="mobile_doc_setSwitchACLList(this);">
									<span class="ctrl"></span>
								</div>
							</dd>
						  </dl>
						</div>
		              </dd>
		            </dl>
		          </div>
		          <div class="detail_config_info">
		              <input type="hidden" id="doc_write_hiddenLinkedDocList" />
		            <dl>
		              <dt><spring:message code='Cache.lbl_LinkDoc'/></dt> <!-- 연결문서 -->
		              <dd><a onclick="mobile_doc_addLinkedDoc();" class="btn_add_file"><spring:message code='Cache.lbl_Add'/></a></dd> <!-- 추가 -->
		              <dd id="doc_write_linkedDocList" class="name_list_wrap" style="display:none;">
		              </dd>
		            </dl>
		          </div>
		          <input type="hidden" id="doc_write_IsApproval" />			<!-- 승인 프로세스 여부 -->
		          <input type="hidden" id="doc_write_expiredDate" />		<!-- 만료일 -->
		          <input type="hidden" id="doc_write_hidAuth" />			<!-- 상세권한 설정정보 -->
				</div>
			</div>
		</div>
	</div>
</form>