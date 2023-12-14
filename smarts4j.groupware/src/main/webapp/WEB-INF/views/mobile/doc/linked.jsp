<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<!-- TODO : 다국어 처리 -->
<div data-role="page" id="doc_linked_page">

	<header data-role="header" id="doc_linked_header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript: mobile_doc_closeSelectLinkedDoc();" class="btn_back"><span><!-- 이전페이지로 이동 --></span></a>
				<div class="menu_link gnb">
					<a href="#" class="pg_tit"><spring:message code='Cache.lbl_apv_doclink'/></a> <!-- 문서연결 -->
				</div>
			</div>
			<div class="utill">
				<!-- <a onclick="$('#doc_linked_div_search').css('display', 'block');" class="btn_search"><span>검색</span></a> -->
				<a id="doc_linked_btn_select" href="javascript: mobile_doc_saveSelectLinkedDoc();" class="btn_txt"><spring:message code='Cache.btn_Select'/></a> <!-- 선택 -->
			</div>
		</div>
		<div class="ly_search ly_change" tabindex="0" id="doc_linked_div_search">
			<a href="javascript: mobile_comm_closesearch(); mobile_board_closesearch();" class="btn_back"><span><spring:message code='Cache.btn_Close'/></span></a> <!-- 닫기 -->
			<input type="text" id="doc_linked_search_input" name="" value="" placeholder="<spring:message code='Cache.msg_doc_searchBy'/>" onkeypress="if (event.keyCode==13){ mobile_doc_linked_clicksearch(); return false;}" onkeyup="mobile_comm_searchinputui('doc_linked_search_input');" /> <!-- 제목, 내용으로 검색 -->
			<a id="doc_linked_search_input_btn" href="javascript: mobile_doc_linked_clicksearch();" class="topH_search" style="display: none;"></a>
			<a onclick="$('#doc_linked_search_input').val(''); mobile_comm_searchinputui('doc_linked_search_input');" class="del ui-link"></a>
		</div>
	</header>

	<div data-role="content" class="cont_wrap" id="doc_linked_content">
		
		<!-- 게시글 목록 영역 -->
		<ul id="doc_linked_list" class="g_list"></ul>
		
		<div id="doc_linked_more" class="btn_list_more" style="display: none;">
			<a href="javascript: mobile_doc_linked_nextlist();"><span><spring:message code='Cache.lbl_MoreView'/></span></a> <!-- 더보기 -->
		</div>
	</div>

	<div class="bg_dim" style="display: none;"></div>

</div>

