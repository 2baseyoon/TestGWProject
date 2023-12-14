<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="org_list_page" data-close-btn="none"><!-- data-close-btn="none" > dialog로 띄울시 close 보여서 추가 -->

	<header data-role="header" id="org_list_header" class="header" role="banner">
		<div class="sub_header">
		
				
			<!-- 편집화면 헤더 -->
			<div class="l_header" name="org_orgList_divOrgListCheck" style="display:none;">
				<a class="topH_back" adata="LIST" onclick="mobile_org_orgList_listViewChang(this);" name="org_orgList_viewChangBtn"><span class="Hicon">이전화면으로복귀</span></a>
				<!-- <a href="javascript: mobile_comm_back();" id="org_list_back" class="topH_close"><span class="Hicon">닫기</span></a> -->
				<div class="menu_link gnb">
					<%-- <a href="#" class="pg_tit"><spring:message code='Cache.lbl_DeptOrgMap' /></a><!-- 조직도 --> --%>
					<a name = "orgListEdit_pg_tit" class="pg_tit ui-link"></a>
				</div>
			</div>
			
			
			<!-- 목록화면 헤더 -->
			<div class="l_header" name="org_orgList_divOrgList">
				<!--  a href="javascript:mobile_comm_TopMenuClick('org_list_topmenu');" class="topH_menu"><span>좌측메뉴</span></a> -->	
				<a href="javascript: $('#collab_menu_list').attr('IsLoad', 'N'); mobile_comm_back();" id="org_list_back"><span class="Hicon"></span></a><!-- 닫기 -->
				<div class="menu_link">
					<a href="#" class="pg_tit"><spring:message code='Cache.lbl_DeptOrgMap' /></a><!-- 조직도 -->
				</div>
			</div>
			
			<!-- 목록화면 utill -->
			<div class="utill" name="org_orgList_divOrgList">
				<a id="orgSearch" href="javascript: mobile_org_searchInput();" class="topH_search"><span class="Hicon">검색</span></a>
				<a href="javascript: $('#collab_menu_list').attr('IsLoad', 'N'); mobile_org_setconfirm();" id="btn_SetOrgConfirm" class="topH_save" style="display:none;"><span class="Hicon">등록</span></a>
				<div class="dropMenu" id="divOrgListMoreMenu">
					<a href="#" onclick="mobile_org_showORhide(this);" class="topH_exmenu ui-link"><span class="Hicon">확장메뉴</span></a>
					<div class="exmenu_layer">
						<ul class="exmenu_list">
							<li><a class="btn ui-link" adata="CHECK" onclick="mobile_org_orgList_editViewChang(this);" name="org_orgList_viewChangBtn" id="org_orgList_viewChangBtn"><spring:message code='Cache.lbl_SyncContact' /></a></li><!-- 연락처 동기화  -->
							<!-- <li><a class="btn ui-link" onclick="mobile_comm_callappvoicerecognition(this);" name="org_orgList_testBtn" id="org_orgList_testBtn">음성인식 테스트</a></li>
							<li><a class="btn ui-link" onclick="$(this).text('음성인식 테스트 결과는');" id="mobile_voiceresult">음성인식 테스트 결과는?</a></li>
							<input type="hidden" id="mobile_voiceresult"/> -->
						</ul>
					</div>
				</div>					
			</div>
			
			<!-- 편집화면 utill -->
			<div class="utill" name="org_orgList_divOrgListCheck" style="display:none;">
				<!-- <a id="orgSearch" href="javascript: mobile_org_searchInput();" class="topH_search"><span class="Hicon">검색</span></a> -->
				<!-- <div class="dropMenu" id="divMailListMoreMenu">
						<a href="#" onclick="mobile_org_showORhide(this);" class="topH_exmenu ui-link"><span class="Hicon">확장메뉴</span></a>
						<div class="exmenu_layer">
							<ul class="exmenu_list">
								<li><a class="btn ui-link" adata="BOXCLEAN" onclick="mobile_org_ChangeMultiMode();" name="org_sync">연락처 동기화</a></li>
							</ul>
						</div>
					</div> -->
				<a onclick="mobile_org_allCheck(this);" id="btn_SetOrgAllCheck" class="topH_check" style="display: block;"><span class="Hicon">전체선택</span></a><!-- 전체선택 -->
				<a onclick="mobile_org_syncContact(this);" id="btn_SetOrgConfirm" class="topH_save" style="display: block;"><span class="Hicon">등록</span></a><!-- 선택 -->
			</div>
		</div>
				
		<div class="ly_search ly_change" id="org_div_search">
			<a href="javascript: mobile_org_changeDisplay(); mobile_comm_closesearch();" class="topH_back"><span>이전페이지로 이동</span></a>
			<input type="text" id="org_search_input"  class="mobileViceInputCtrl" voiceInputType="callback" voiceStyle="margin-right:25px;" voiceCallBack="mobile_org_search" name="" value="" placeholder="<spring:message code='Cache.lbl_SearchEmployees' />" onkeypress="mobile_org_searchEnter(event)" onkeyup="mobile_comm_searchinputui('org_search_input');" /><!-- 임직원 검색 -->
			<a id="org_search_input_btn" href="javascript: mobile_org_search();" class="topH_search" style="display: none;"></a>
			<a href="javascript: mobile_org_resetSearchInput(); mobile_comm_searchinputui('org_search_input');" class="topH_del"></a>
		</div>
		
	</header>

	<div data-role="content" class="cont_wrap" id="org_orgList_content">
		
		<!-- 선택목록 영역 -->
		<div id="org_list_selected" style="display: block;" class="org_select_wrap">
			<ul>
			</ul>
		</div>
		<input type="hidden" id="org_list_selecteditems" />
		
		<!-- 부서 step 영역 -->
		<div class="org_tree_wrap" id="org_list_div_step">
			<a href="javascript: mobile_org_goTop();" class="top"></a>
			<div class="scr_h" style="min-height : 22px;">
				<ol id="org_list_step" ></ol>
			</div>
		</div>
		
		<!-- 하위부서/부서원 영역 -->
		<ul id="org_list_sublist" class="org_list"></ul>
		
		<!-- 검색된 부서/부서원 영역 -->
		<ul id="org_list_searchlist" class="org_list"></ul>
		
	</div>
	<!-- 음성인식 시작 --> 
	<div class="PVoiceBtn used" id="divOrgVoiceListener" style="display:none;">
      <a onclick="mobile_orgVoiceCall()"><span></span></a>
    </div>
   	<!-- 음성가이드 팝업 시작 -->
	<div class="mobile_popup_wrap" id="divOrgReadVoiceGuidePop" style="display:none;">
    	<div class="voice_search_wrap" style="height:340px;">
			<a onclick="$('#divOrgReadVoiceGuidePop').hide()" class="btn_voice_cancel"><span>닫기</span></a>
			<p class="voice_pop_title">음성지원 명령</p>
			<div class="voice_pop_cont">
				<ul class="voice_pop_cont_list">
					<li>전화 연결 (첫번째 사람)</li>
					<li>OOO 연결</li>
					<li>OOO 검색</li>
					<li>포탈로 이동</li>
				</ul>
			</div>
			<div class="write_info_wrap"><p class="write_info">음성인식 버튼을 길게 눌러  기능을  활성 또는 비활성화 할 수 있습니다. </p></div>
		</div>
    </div>
	<!-- 음성가이드 팝업 끝 -->

</div>

