<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="bizcard_zipcode_page">

	<header data-role="header" id="bizcard_zipcode_header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript: mobile_comm_back();" class="btn_back"><span><!-- 이전페이지로 이동 --></span></a>
				<div class="menu_link gnb">
					<a href="#" class="pg_tit"><spring:message code='Cache.btn_SearchZipCode' /></a> <!-- 우편번호 검색 -->
				</div>
			</div>
			<div class="utill">
				<a href="javascript: mobile_comm_opensearch();" class="btn_search"><span><spring:message code='Cache.btn_search' /></span></a> <!-- 검색 -->
	        </div>
		</div>
		<div class="ly_search">
			<a href="javascript: mobile_bizcard_clickrefresh(); mobile_comm_closesearch();" class="btn_back"><span><spring:message code='Cache.btn_Close' /></span></a> <!-- 닫기 -->
			<input type="text" id="mobile_search_input" name="" value="" placeholder="<spring:message code='Cache.msg_bizcard_searchByZip' />" onkeypress="if (event.keyCode==13){ mobile_zipcode_clicksearch(); return false;}"> <!-- 지번, 도로명으로 검색 -->
			<a href="javascript: mobile_comm_cleansearch();" class="del ui-link"></a>
		</div>
	</header>

	<div data-role="content" class="cont_wrap" id="bizcard_zipcode_content">
		 
		<div id="con_addr">				
		</div>

		<div class="zipcode">
			<ul id="bizcard_zipcode_list" class="address_list">
			</ul>
			<div id="bizcard_zipcode_btnnextlist" class="btn_list_more" style="display: none;">
				<a href="javascript: mobile_zipcode_nextlist();"><span><spring:message code='Cache.lbl_MoreView' /></span></a>
			</div>
		</div>

	</div>