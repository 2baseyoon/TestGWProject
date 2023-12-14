<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="bizcard_write_page" data-close-btn="none">
	
	<header data-role="header" id="bizcard_write_header">
		<div class="sub_header">
	        <div class="l_header">
				<a href="javascript:mobile_comm_back();" class="topH_close"><span><!-- 닫기 --></span></a>
				<div class="menu_link gnb">
					<a id="bizcard_write_title"  href="#" class="pg_tit"><spring:message code='Cache.btnWrite' /></a><!-- 작성 -->
				</div>
			</div>
			<div class="utill">
				<a id="bizcard_write_save" href="javascript: mobile_bizcard_save();" class="topH_save"><span class="Hicon">등록</span></a>
				<a id="bizcard_write_modify" href="javascript: mobile_bizcard_modify();" class="topH_save" style="display: none;"><span class="Hicon">수정</span></a><!-- 수정 -->
			</div>
		</div>
	</header>

	<div data-role="content" class="cont_wrap" id="bizcard_write_content">
		<div class="write_wrap" id="bizcard_write_divperson">
			<div class="bizcard_top">
				<div class="add_img">
					<a name="bizcard_write_img" href="javascript: $('#bizcard_write_divperson input[name=addFile]').click();" class="attach_file">
						<input type="file" name="addFile" size="15" style="display:none;" onchange="javascript: mobile_bizcard_changeimage(this);" accept=".jpg, .jpeg, .png, .gif" >
						<span class="btn_add"></span>
					</a>
				</div>
				<div class="bizcard_add_info">
					<div class="add_info_tab" id="bizcard_write_persontype">
						<a onclick="mobile_bizcard_changepersontype(this);" value="P" class=""><spring:message code='Cache.lbl_ShareType_Personal' /></a>
						<a onclick="mobile_bizcard_changepersontype(this);" value="D" class=""><spring:message code='Cache.lbl_ShareType_Dept' /></a>
						<a onclick="mobile_bizcard_changepersontype(this);" value="U" class=""><spring:message code='Cache.lbl_Company' /></a>
					</div>
					<div class="add_info_name text_in_wrap" style='width:197px;'>
						<input id="bizcard_write_personname" voiceInputType="change" voiceStyle="right:0px;" voiceCallBack=""  class="mobileViceInputCtrl HtmlCheckXSS ScriptCheckXSS" type="text" placeholder="<spring:message code='Cache.msg_EnterName' />"> <!-- 이름을 입력하세요. -->
					</div>
				</div>
			</div>
			<div class="bizcard_wrap gruop">
				<select  class="bizcard_select" id="bizcard_write_persongroup" onchange="mobile_bizcard_changegroup(this);" >
					<option value="none" selected><spring:message code='Cache.lbl_bizcard_noGroup' /></option> <!-- 그룹없음 -->
					<option value="new"><spring:message code='Cache.lbl_newGroup' /></option> <!-- 새 그룹 -->
				</select>
				<p class="bizcard_tx">
					<input id="bizcard_write_persongroupname" disabled type="text" voiceInputType="change" voiceStyle="margin-right:15px" voiceCallBack="" class="bizcard_tx_input mobileViceInputCtrl HtmlCheckXSS ScriptCheckXSS" placeholder="<spring:message code='Cache.lbl_bizcard_enterNewGroupName' />"> <!-- 새 그룹명 입력 -->
				</p>
			</div>
			
			<div class="bizcard_wrap phone">
				<select id="selPhoneType" class="bizcard_select" name="bizcard_write_phonetype" >
					<option value="C"><spring:message code='Cache.lbl_MobilePhone' /></option> 			<!-- 핸드폰 -->					
					<option value="T"><spring:message code='Cache.lbl_Office_Line' /></option> 			<!-- 사무실전화 -->
					<option value="F"><spring:message code='Cache.lbl_Office_Fax' /></option> 			<!-- 팩스 -->
					<option value="E"><spring:message code='Cache.lbl_EtcPhone' /></option> 			<!-- 기타 -->
					<option value="H"><spring:message code='Cache.lbl_HomePhone' /></option> 			<!-- 자택 -->
					<option value="D"><spring:message code='Cache.lbl_DirectPhone' /></option> 			<!-- 직접입력 -->
				</select>
				<p class="bizcard_tx" id="phonetxt_1">
					<input name="bizcard_write_phonetxt"  class="bizcard_tx_input HtmlCheckXSS ScriptCheckXSS" type="text" placeholder="<spring:message code='Cache.btn_bizcard_EnterNum' />">
				</p>
				<a name="bizcard_write_btnaddphone" onclick="javascript: mobile_bizcard_clickaddphone(this);" class="btn_add_n"><spring:message code='Cache.btn_Add' /></a> <!-- 추가 -->
			</div>
			
		    <div class="bizcard_wrap phone bizcard_direct" style="display: none;">
				<p class="bizcard_tx" id="phonetxt_2"></p>
			</div>
			
			<div name="bizcard_write_phonelist" class="bizcard_add_list" style="display:none; background: none !important;"></div>
			<div class="bizcard_wrap mail">
				<select class="bizcard_select" name="bizcard_write_mailtype">
					<option value="C"><spring:message code='Cache.lbl_Mail' /></option> <!-- 메일 -->
				</select>
				<p class="bizcard_tx">
					<input name="bizcard_write_emailtxt" class="bizcard_tx_input HtmlCheckXSS ScriptCheckXSS" type="text" placeholder="<spring:message code='Cache.lbl_personalEmailAddress' />"> <!-- 개인 이메일 주소 -->
				</p>
				<a name="bizcard_write_btnaddemail"  onclick="javascript: mobile_bizcard_clickaddemail(this);" class="btn_add_n"><spring:message code='Cache.btn_Add' /></a> <!-- 추가 -->
			</div>
			<div name="bizcard_write_emaillist"  class="bizcard_add_list" style="display:none; background: none !important;"></div>
			<div class="editor_wrap" style="height:120px;">
				<textarea  id="bizcard_write_personmemo"  name="name" rows="8" cols="80" class="txareas full mobileViceInputCtrl HtmlCheckXSS ScriptCheckXSS" voiceInputType="append" voiceStyle="margin-right:15px" voiceCallBack="" placeholder="<spring:message code='Cache.msg_bizcard_enterMemo' />"></textarea> <!-- 메모를 입력하세요. -->
			</div>
			<div class="msgs_wrap">
				<input type="text" title="<spring:message code='Cache.BizSection_Messenger' />" name="msgnames"  id="bizcard_write_personmessenger" class="inputbox msgs_n HtmlCheckXSS ScriptCheckXSS" placeholder="<spring:message code='Cache.BizSection_Messenger' />">
			</div>
			<div class="companys_wrap">
				<input type="text" id="bizcard_write_personcompany" voiceInputType="change" voiceStyle="margin-right:15px" voiceCallBack="" title="<spring:message code='Cache.lbl_CompanyName' />" name="companynames" class="inputbox companys_n mobileViceInputCtrl HtmlCheckXSS ScriptCheckXSS"  comID="" placeholder="<spring:message code='Cache.lbl_CompanyName' />">
			</div>
			<div class="depts_wrap">
				<input type="text" id="bizcard_write_persondept" voiceInputType="change" voiceStyle="margin-right:15px" voiceCallBack="" title="<spring:message code='Cache.lbl_dept' />" name="deptnames" 	class="inputbox depts_n mobileViceInputCtrl HtmlCheckXSS ScriptCheckXSS" placeholder="<spring:message code='Cache.lbl_dept' />">
			</div>
			<div class="levels_wrap">
				<input type="text" id="bizcard_write_personjobtitle" voiceInputType="change" voiceStyle="margin-right:15px" voiceCallBack="" title="<spring:message code='Cache.lbl_JobTitle' />" name="levelnames" class="inputbox levels_n mobileViceInputCtrl HtmlCheckXSS ScriptCheckXSS" placeholder="<spring:message code='Cache.lbl_JobTitle' />">
			</div>
		</div>
		<!-- 이전 회사등록  사용하지 않음.-->
		<div class="bizcard_write" style="display:none;">
			<div class="tab_wrap">
				<ul id="bizcard_write_tabtype" class="g_tab sm_tab" style="display:none;">
					<li value="person"><a href="#bizcard1" onclick="mobile_bizcard_clickTabWrap(this);"><spring:message code='Cache.lbl_BizCard' /></a></li> <!-- 명함 -->
					<li value="company"><a href="#bizcard2" onclick="mobile_bizcard_clickTabWrap(this);"><spring:message code='Cache.lbl_Company2' /></a></li> <!-- 업체 -->
				</ul>
				<div class="tab_cont_wrap">
					<div id="bizcard_write_divcompany" class="tab_cont">
						<div class="add_img company">
							<a name="bizcard_write_img" href="javascript: $('#bizcard_write_divcompany input[name=addFile]').click();" class="attach_file">
								<input type="file" name="addFile" size="15" style="display:none;" onchange="javascript: mobile_bizcard_changeimage(this);" accept=".jpg, .jpeg, .png, .gif" >
								<span class="btn_add"></span>
							</a>
						</div>
						<div class="input_info">
							<ul>
								<li><input id="bizcard_write_companyname" type="text" name="" placeholder="<spring:message code='Cache.lbl_BusinessName' />" class="full"></li> <!-- 업체명 -->
								<li><input id="bizcard_write_companyrep" type="text" name="" placeholder="<spring:message code='Cache.lbl_RepName' />" class="full"></li> <!-- 대표자명 -->
								<li>
									<select  id="bizcard_write_companygroup" onchange="mobile_bizcard_changegroup(this);" class="" name="">
										<option value="none"><spring:message code='Cache.lbl_bizcard_noGroup' /></option> <!-- 그룹없음 -->
										<option value="new"><spring:message code='Cache.lbl_newGroup' /></option> <!-- 새 그룹 -->
									</select>
									<input id="bizcard_write_companygroupname" disabled type="text" placeholder="<spring:message code='Cache.lbl_bizcard_enterNewGroupName' />"> <!-- 새 그룹명 입력 -->
								</li>
								<li class="phone">
									<select  name="bizcard_write_phonetype" class="" name="">
										<option value="T"><spring:message code='Cache.lbl_Office' /></option> <!-- 사무실 -->
										<option value="F">FAX</option> 
									</select>
									<input name="bizcard_write_phonetxt"  type="text" placeholder="<spring:message code='Cache.btn_bizcard_EnterNum' />"> <!-- 번호입력 -->
									<a  name="bizcard_write_btnaddphone" onclick="javascript: mobile_bizcard_clickaddphone(this);" class="btn_add_file"><spring:message code='Cache.btn_Add' /></a> <!-- 추가 -->
								</li>
								<li name="bizcard_write_phonelist" class="add_list">
								</li>
								<li class="email">
									<input name="bizcard_write_emailtxt"  type="text" placeholder="<spring:message code='Cache.lbl_companyEmailAddress' />"> <!-- 회사 이메일 주소 -->
									<a name="bizcard_write_btnaddemail"  onclick="javascript: mobile_bizcard_clickaddemail(this);" class="btn_add_file"><spring:message code='Cache.btn_Add' /></a> <!-- 추가 -->
								</li>
								<li name="bizcard_write_emaillist"  class="add_list">
								</li>
								<li class="msg">
									<textarea  id="bizcard_write_companymemo"  name="name" rows="8" cols="80" class="full" placeholder="<spring:message code='Cache.msg_bizcard_enterMemo' />"></textarea> <!-- 메모를 입력하세요. -->
								</li>
							</ul>
							<a href="#" onclick="mobile_bizcard_clickAccLink(this);" class="acc_link show"><spring:message code='Cache.lbl_bizcard_addInfo' /></a> <!-- 추가정보 -->
							<div class="acc_cont">
								<dl>
									<dt><spring:message code='Cache.lbl_AnniversarySchedule' /></dt> <!-- 기념일 -->
									<dd><input id="bizcard_write_companyanniversary" type="text" class="input_date"></dd>
								</dl>
								<dl>
									<dt><spring:message code='Cache.lbl_homepage' /></dt> <!-- 홈페이지 -->
									<dd><input id="bizcard_write_companywebsite" type="text" class="full" placeholder="<spring:message code='Cache.msg_bizcard_enterURL' />"></dd> <!-- URL을 입력하세요. -->
								</dl>
								<dl>
									<dt><spring:message code='Cache.lbl_Address' /></dt> <!-- 주소 -->
									<dd><input id="bizcard_write_companyzipcode" type="text" placeholder="<spring:message code='Cache.lbl_ZipCode' />" class="full"> <!-- 우편번호 -->
									<dd><input id="bizcard_write_companyaddress" type="text" placeholder="<spring:message code='Cache.lbl_Address' />" class="full"></dd> <!-- 주소 -->
									<dd><input id="bizcard_write_companyaddressfull" type="text" placeholder="<spring:message code='Cache.lbl_bizcard_detailAddress' />" class="full"></dd> <!-- 상세주소 -->
								</dl>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
		
	</div>
	
</div>