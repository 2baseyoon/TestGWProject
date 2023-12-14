<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="approval_setting_page">

	<script>
//		var ApprovalMenu = ${Menu};	//좌측 메뉴
	</script>

	<header data-role="header" id="approval_setting_header" class="header">
		<div class="sub_header">
			<div class="l_header">
				<a class="topH_close ui-link" href="javascript:mobile_comm_back();"
					name="mail_mailList_prevEditBtn"><span>이전페이지로 이동</span></a>
				<div class="menu_link">
					<a class="pg_tit ui-link"><spring:message code="Cache.lbl_config"/><!-- 환경설정 --></a>
				</div>
			</div>
		</div>
	</header>

	<div data-role="content" class="cont_wrap" id="approval_setting_content" role="main">
		<div class="mail_config">
			<ul>
				<li onclick="mobile_approval_regSignature();" class="mail_config_list02">
					<a class="ui-link"> <span><spring:message code="Cache.lbl_apv_Regisign"/><!-- 서명등록 --></span>
				</a>
				</li>
			</ul>
		</div>

	</div>
	<div id="approval_list_btn_write" class="list_writeBTN" style="display:none;">
      <a href="javascript: mobile_approval_clickwrite();" class="ui-link"><span>작성</span></a>
    </div>
	<div class="bg_dim" style="display: none;"></div>

</div>

