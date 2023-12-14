<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<% 
	String IsPopup = request.getParameter("IsPopup");
	if ("Y".equals(IsPopup)) {
		String menu = (String)pageContext.getAttribute("Menu");
		if (menu == null) pageContext.setAttribute("Menu", "''");
	}
%>

<!-- TODO : 다국어 처리 -->
<div data-role="page" id="doc_list_page" class="mob_rw">

	<script>
		var BoardMenu = ${Menu};	//좌측 메뉴
	</script>
	<header class="header" id="board_list_header">
		<div class="sub_header" id="board_list_header_normal">
			<div class="l_header">
				<a href="javascript:mobile_comm_TopMenuClick('board_list_topmenu');" class="topH_menu"><span>전체메뉴</span></a>
				<div class="menu_link gnb">
					<span id="board_list_title" href="javascript:void(0);" class="topH_tit"></span>
					<div class="cover_leftmenu" style="display:none;">
						<div class="LsubHeader">
							<span class="LsubTitle board"><spring:message code='Cache.BizSection_Doc' /></span>
							<span class="LsubTitle_btn">
								<button type="button" onclick="mobile_comm_TopMenuClick('board_list_topmenu',true);return false;" class="btn_close ui-btn ui-shadow ui-corner-all"><i>닫기</i></button>
							</span>
						</div>
				 		<div class="tree_default" id="board_list_topmenu"></div>
		    		</div>
					<div class="left_bg_dim" onclick="mobile_comm_TopMenuClick('board_list_topmenu',true);return false;" style="display: none;"></div>
          		</div>
        	</div>                	
	        <div class="utill">
	          <a href="javascript:voic(0);" onclick="$('#board_div_search').css('display', 'block');" class="topH_search"><span class="Hicon">검색</span></a>	
	          <a href="javascript: mobile_board_clickrefresh();" class="topH_reload"><span class="Hicon">새로고침</span></a>	          
	        </div>
      	</div>
      	
      	<div class="sub_header" id="board_list_header_docSelect" style="display:none;">
			<div class="l_header">				
				<a href="javascript: mobile_doc_closeLinkedDoc();" class="topH_back"><span><!-- 이전페이지로 이동 --></span></a>
				<div class="menu_link gnb">
					<span href="javascript:void(0);" class="topH_tit"><spring:message code='Cache.lbl_apv_doclink'/></span>
          		</div>
        	</div>                	
	        <div class="utill">
				<a href="javascript:voic(0);" onclick="$('#board_div_search').css('display', 'block');" class="topH_search"><span class="Hicon">검색</span></a>	          
				<a id="doc_linked_btn_select" href="javascript: mobile_doc_saveSelectLinkedDoc();" class="topH_save"><span class="Hicon">등록</span></a>				
	        </div>
      	</div>
      	
	  	<div class="ly_search ly_change" tabindex="0" id="board_div_search">
			<a href="javascript: mobile_comm_closesearch(); mobile_board_closesearch();" class="topH_back"><span><span><spring:message code='Cache.btn_Close' /></span></a> <!-- 닫기 -->
			<input type="text" id="mobile_search_input" class="mobileViceInputCtrl" voiceInputType="callback" voiceStyle="margin-right:25px;" voiceCallBack="mobile_board_clicksearch" name="" value="" placeholder="<spring:message code='Cache.msg_doc_searchBy' />" onkeypress="if (event.keyCode==13){ mobile_board_clicksearch(); return false;}" onkeyup="mobile_comm_searchinputui('mobile_search_input');" />
			<a id="mobile_search_input_btn" href="javascript: mobile_board_clicksearch();" class="topH_search" style="display: none;"></a>
			<a href="javascript: $('#mobile_search_input').val(''); mobile_comm_searchinputui('mobile_search_input');" class="topH_del"></a>
		</div>
    </header>
     
	<div data-role="content" class="cont_wrap" id="board_list_content">
		<!-- 게시글 분류 영역 -->
		<select id="board_list_category" class="full sel_type" onchange="javascript: mobile_board_clickcategory();"></select>
		
		<!-- 게시글 목록 영역 -->
		<ul id="board_list_list" class="g_list"></ul>
		
		<div id="board_list_more" class="btn_list_more" style="display: none;">
			<a href="javascript: mobile_board_nextlist();"><span><spring:message code='Cache.lbl_MoreView'/></span></a> <!-- 더보기 -->
		</div>
	</div>
	
	<div class="list_writeBTN">
      <a href="javascript: mobile_board_clickwrite();" class="ui-link"><span>작성</span></a>
    </div>
    
	<div class="bg_dim" style="display: none;"></div>

</div>

