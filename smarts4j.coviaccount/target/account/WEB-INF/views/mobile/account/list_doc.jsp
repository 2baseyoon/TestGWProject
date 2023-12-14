<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="approval_list_page" class="mob_rw">

	<script>
		var ApprovalMenu = ${Menu};	//좌측 메뉴
	</script>

	<header id="approval_list_header" class="header">
		<div class="sub_header" id="approval_list_header_normal">
			<div class="l_header">
				<a href="javascript:mobile_comm_TopMenuClick('approval_list_topmenu');" class="topH_menu"><span>전체메뉴</span></a>
				<div class="menu_link gnb">
					<span id="approval_list_title" href="javascript:void(0);" class="topH_tit"></span>
					<div class="cover_leftmenu" style="display: none;">
						<div class="LsubHeader">
							<span class="LsubTitle approval"><spring:message code='Cache.lbl_apv_approval'/></span>
							<span class="LsubTitle_btn">
								<button type="button" onclick="mobile_approval_settingApproval();" class="btn_setup"><i>환경설정</i></button>
								<button type="button" onclick="mobile_comm_TopMenuClick('approval_list_topmenu',true);return false;" class="btn_close"><i>닫기</i></button>
							</span>
						</div>
				 		<div class="tree_default" id="approval_list_topmenu"></div>
		    		</div>
					<div class="left_bg_dim" onclick="mobile_comm_TopMenuClick('approval_list_topmenu',true);return false;"  style="display: none;"></div>
				</div>
			</div>
			<div class="utill">
				<a id="approval_list_btn_search" href="javascript: mobile_approval_searchInput();" class="topH_search"><span class="Hicon"></span></a>
				<a id="approval_list_btn_reload" href="javascript: mobile_approval_reload();" class="topH_reload"><span class="Hicon">새로고침</span></a>									
			</div>
		</div>
		<div class="sub_header" id="approval_list_header_docSelect" style="display: none;">
			<div class="l_header">
				<a href="javascript: mobile_approval_closeDocLink();" class="topH_close"><span class="Hicon">닫기</span></a>
				<div class="menu_link gnb">
					<a href="#" class="pg_tit"><spring:message code='Cache.lbl_apv_doclink'/></a> <!-- 문서연결 -->
				</div>
			</div>
			<div class="utill">
				<a id="approval_list_btn_select" href="javascript: mobile_approval_selectLinkedDoc();" class="topH_save"><span class="Hicon">선택</span></a> <!-- 선택 -->
			</div>
		</div>
		<div class="ly_search" id="approval_div_search">
			<a href="javascript: mobile_approval_changeDisplay(); mobile_comm_closesearch();" class="topH_back"><span><!-- 닫기 --></span></a>
			<input type="text" id="approval_search_input" class="mobileViceInputCtrl" voiceInputType="callback" voiceStyle="margin-right:25px;" voiceCallBack="mobile_approval_search" name="" value="" placeholder="<spring:message code='Cache.msg_apv_searchBy'/>" onkeypress="mobile_approval_searchEnter(event)"> <!-- 제목, 기안부서, 기안자로 검색 -->
			<!-- <a onclick="mobile_comm_VoiceInput(this)" mobile_VoiceInputCallBack="mobile_approval_search" mobile_VoiceInputId="approval_search_input" mobile_VoiceInputType="callback" class="btn_vw used ui-link" style="display:;margin-right:25px;"><span>사용</span></a> -->
			<a href="javascript: mobile_approval_resetSearchInput();" class="topH_del"></a>
		</div>
	</header>

	<div data-role="content" class="cont_wrap" id="approval_list_content">
	
		<!-- 결재 분류 영역 -->
		<select id="approval_list_type" class="full sel_type" onchange="javascript: mobile_approval_changeListType(this);" style="display: none;">
			<option value="Complete" selected><spring:message code='Cache.lbl_apv_doc_person_complete'/></option> <!-- 개인완료함 -->
			<option value="TCInfo"><spring:message code='Cache.lbl_apv_doc_person2'/> - <spring:message code='Cache.lbl_apv_doc_circulation'/></option> <!-- 개인문서함 - 참조/회람함 -->
			<option value="DeptComplete"><spring:message code='Cache.lbl_apv_doc_dept2'/></option> <!-- 부서문서함 -->
			<option value="ReceiveComplete"><spring:message code='Cache.lbl_apv_doc_rec_completed'/></option> <!-- 부서수신처리함 -->
			<option value="DeptTCInfo"><spring:message code='Cache.lbl_apv_doc_dept2'/> - <spring:message code='Cache.lbl_apv_doc_circulation'/></option> <!-- 부서문서함 - 참조/회람함 -->
		</select>
	
		<div class="all_chk" id="approval_list_div_allchk" style="display: none;">
			<!-- 전체 선택 -->
	    	<p><input type="checkbox" name="" value="" id="approval_list_allchk" onchange="mobile_approval_checkAll(this);"><label for="approval_list_allchk"><spring:message code='Cache.lbl_apv_selectall'/> <strong class="point_cr" id="approval_list_chkcnt"></strong></label></p> <!-- 전체선택 -->
	    	
	    	<!-- 드롭 메뉴(PC 버튼 영역 - 일괄결재, 읽음확인, 삭제...) -->
	    	<div class="r_drop_menu dropMenu">
				<a href="#" class="btn_drop_menu" id="approval_list_dropmenu" onclick="mobile_approval_clickDropmenu(this)"></a>
				<ul class="menu_list" id="approval_list_dropmenuitems"></ul>
			</div>
		</div>
		
		<!-- 결재 목록 영역 -->
		<ul id="approval_list_list" class="approval_list"></ul>
		
		<!-- 검색된 결재 목록 영역 -->
		<ul id="approval_list_searchlist" class="approval_list" style="display: none;"></ul>
		
		<div id="approval_list_more" class="btn_list_more" style="display: none;">
			<a href="javascript: mobile_approval_nextlist();"><span><spring:message code='Cache.lbl_MoreView'/></span></a> <!-- 더보기 -->
		</div>
	</div>
	<div id="approval_list_btn_write" class="list_writeBTN" style="display:none;">
      <a href="javascript: mobile_approval_clickwrite();" class="ui-link"><span>작성</span></a>
    </div>
	<div class="bg_dim" style="display: none;"></div>

</div>

