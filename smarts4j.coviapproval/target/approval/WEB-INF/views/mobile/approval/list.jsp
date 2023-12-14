<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="egovframework.baseframework.util.SessionHelper"%>
<%@ page import="egovframework.coviframework.util.ClientInfoHelper"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<% 
	boolean isMobile = ClientInfoHelper.isMobile(request);
	String useTeamsAddIn = "N";
	String userAgent = request.getHeader("User-Agent");
	String pIsTeamsAddIn = request.getParameter("teamsaddin");
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
    if ((userAgent != null && userAgent.toLowerCase().indexOf("teams") > -1) || (pIsTeamsAddIn != null && pIsTeamsAddIn.toUpperCase().equals("Y"))) {
    	useTeamsAddIn = "Y";
    }
%>

<div data-role="page" id="approval_list_page" class="mob_rw">
	<script>
		var ApprovalMenu = ${Menu};	//좌측 메뉴
		var proaas = "${aesSalt}";
		var proaaI = "${aesIv}";
		var proaapp = "${aesPassPhrase}";
		var aesUtil = new AesUtil("${aesKeysize}", "${aesIterationCount}");
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
		<div class="ly_search ly_change" id="approval_div_search">
			<a href="javascript: mobile_approval_changeDisplay(); mobile_comm_closesearch();" class="topH_back"><span><!-- 닫기 --></span></a>
			<input type="text" id="approval_search_input" class="mobileViceInputCtrl" voiceInputType="callback" voiceStyle="margin-right:25px;" voiceCallBack="mobile_approval_search" name="" value="" placeholder="<spring:message code='Cache.msg_apv_searchBy'/>" onkeypress="mobile_approval_searchEnter(event)" onkeyup="mobile_comm_searchinputui('approval_search_input');" /> <!-- 제목, 기안부서, 기안자로 검색 -->
			<a id="approval_search_input_btn" href="javascript: mobile_approval_search()" class="topH_search" style="display: none;"></a>
			<a href="javascript: mobile_approval_resetSearchInput(); mobile_comm_searchinputui('approval_search_input');" class="topH_del"></a>
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
	
		<!-- 권한있는 담당업무함 -->
		<div class="sel_eaccounting_wrap" id="approval_list_div_Jobfunction" style="display: none;">
			<select id="approval_list_Jobfunction" onchange="mobile_approval_changeListJobBiz(this);">
				<!-- <option value="A"><spring:message code='Cache.lbl_Whole'/></option>  -->
			</select>
		</div>
		<!-- 권한있는 업무문서함 -->
		<div class="sel_eaccounting_wrap" id="approval_list_div_BizDoc" style="display: none;">
			<select id="approval_list_BizDoc" onchange="mobile_approval_changeListJobBiz(this);">
				<!-- <option value="A"><spring:message code='Cache.lbl_Whole'/></option>  -->
			</select>
		</div>
	
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
		
		<!-- 팀즈 결재양식 목록 영역 -->
		<ul id="approval_teams_list_formList" style="display: none;">
			<li>
                <!-- 결재 목록 영역 -->
                <div id="teams_approval_temp" class="teams_approval_temp">
                    <div class="bodyMenu">
                        <div class="btn_group mb10">
	                        <select id="selListTypeID" class="teams_select" onchange="clickSelectListBoxData(this);">
		                        <option value="tab" id="<spring:message code="Cache.btn_apv_class_by"/>" selected><spring:message code="Cache.btn_apv_class_by"/></option> 	<!-- 분류 -->
		                        <option value="list" id="<spring:message code="Cache.btn_apv_total"/>"><spring:message code="Cache.btn_apv_total"/></option> 		<!-- 전체 -->
	                        </select>
                            <button type="button" class="opBtn" onclick="boxShowHide(this,'giBox');"><spring:message code='Cache.lbl_approval_recentlyApv'/></button> 	<!-- 최근기안 -->
                            <button type="button" class="opBtn" onclick="boxShowHide(this,'faGi');"><spring:message code='Cache.lbl_approval_favoriteForm'/></button> 	<!-- 자주쓰는 기안 -->
                        </div>
                    </div>
                    <!-- 최근기안  시작-->
                    <div class="giBox" id="giBox" style="display:none;">
                        <div class="approval_resect_box">
                            <span class="giTit">최근기안</span> 
                            <ul class="approval_resect_list" id="giList"></ul>
                        </div>
                    </div>
                    <!-- 최근기안  끝-->
                    <!-- 자주쓰는 기안-->
                    <ul class="faGi" id="faGi" style="display:none"></ul>
                    <!-- 자주쓰는 기안 끝-->
                    <div class="tabLine" style="height: auto; display: block;">
                        <ul class="writeTab" id="writeTab"></ul>
                    </div>
                    <ul class="writeTapCont" id="writeTapCont"></ul>
                </div>
			</li>
		</ul>
		
		<div id="approval_list_more" class="btn_list_more" style="display: none;">
			<a href="javascript: mobile_approval_nextlist();"><span><spring:message code='Cache.lbl_MoreView'/></span></a> <!-- 더보기 -->
		</div>
	</div>
	
	<% if ("Y".equals(useTeamsAddIn) && !isMobile) { %>
        <div id="divPopBtnArea" class="FloatingBtn">
            <ul class="popBtn">
                <li class="btnMore active" onclick="XFN_FloatingBtnMore_OnClick(this);"><a href="javascript:void(0);">더보기</a><span class="toolTip2">더보기</span></li>
                <li class="btnClose" onclick="XFN_FloatingBtnClose_OnClick(this);"><a href="javascript:void(0);">닫기</a><span class="toolTip2">닫기</span></li>
            </ul>
            <ul class="popBtn2" style="display: none;">
            	<li class="btnWrite"><a href="javascript: mobile_approval_clickwrite();">작성</a><span class="toolTip2">작성</span></li>
                <li class="btnNewPopup"><a href="javascript:void(0);" onclick="XFN_TeamsOpenGroupware('APPROVAL');">새창</a><span class="toolTip2">새창</span></li>
            </ul>
        </div>
	<% } else { %>
	
	<div id="approval_list_btn_write" class="list_writeBTN" style="display:none;">
      <a href="javascript: mobile_approval_clickwrite();" class="ui-link"><span>작성</span></a>
    </div>
    
   	<% } %>
    
	<div class="bg_dim" style="display: none;"></div>

</div>
