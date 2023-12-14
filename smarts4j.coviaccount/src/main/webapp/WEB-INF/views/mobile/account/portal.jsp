<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.baseframework.util.SessionHelper"%>
<%@ page import="egovframework.coviframework.util.ClientInfoHelper"%>
<% 
	boolean isMobile = ClientInfoHelper.isMobile(request);
	String useTeamsAddIn = "N";
	String userAgent = request.getHeader("User-Agent");
	String pIsTeamsAddIn = request.getParameter("teamsaddin");
    if ((userAgent != null && userAgent.toLowerCase().indexOf("teams") > -1) || (pIsTeamsAddIn != null && pIsTeamsAddIn.toUpperCase().equals("Y"))) {
    	useTeamsAddIn = "Y";
    }
%>
<div data-role="page" id="account_portal_page" class="mob_rw">
	<script>
		var AccountMenu = ${Menu};	//좌측 메뉴
	</script>
	<header class="header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript:mobile_comm_TopMenuClick('account_portal_topmenu');" class="topH_menu"><span></span></a>
				<div class="menu_link gnb">
					<span id="account_portal_title" class="topH_tit"><spring:message code='Cache.ACC_lbl_eAccounting'/></span>
					<div class="cover_leftmenu" style="display:none;">
						<div class="LsubHeader">
							<span class="LsubTitle approval" onclick="mobile_account_PortalLinkClick('Portal');"><spring:message code='Cache.ACC_lbl_eAccounting'/></span>
							<span class="LsubTitle_btn">
								<button type="button" onclick="mobile_comm_TopMenuClick('account_portal_topmenu',true);return false;" class="btn_close ui-btn ui-shadow ui-corner-all"><i>닫기</i></button>
							</span>
						</div>
						<div class="tree_default" id="account_portal_topmenu"></div>
					</div>
					<div class="left_bg_dim" onclick="mobile_comm_TopMenuClick('account_portal_topmenu',true);return false;" style="display: none;"></div>
				</div>
			</div>
		</div>
	</header>
	<div id="account_portal_content" data-role="content" class="cont_wrap">
		<div class="nea_portal_wrap">
			<p id="account_portal_deadline" class="nea_portal_tx"></p>
			<div class="nea_portal_top">
				<p class="nea_portal_top_tit"><spring:message code='Cache.lbl_apv_notice'/></p>
				<ul id="ul_account_portal_Notice" class="nea_portal_top_list">
					<li><span class="nea_portal_top_link"></span></li>
				</ul>
			</div>
			<div class="nea_portal_middle">
				<ul class="nea_portal_middle_list">
					<% if (!"Y".equals(useTeamsAddIn)) { %>
						<li id="li_account_portal_AppExpence" style="display: none;">
							<a onclick="mobile_account_PortalLinkClick('AppExpence');" class="nea_portal_middle_link01">
								<span class="nea_ico"></span>
								<span class="nea_txt"><spring:message code='Cache.lbl_expenceApplication'/></span>
							</a>
						</li>
					<% } %>
					<li id="li_account_portal_ApprovalList_Approval">
						<a onclick="mobile_account_PortalLinkClick('ApprovalList_Approval');" class="nea_portal_middle_link03">
							<span class="nea_ico"></span>
							<span class="nea_txt"><spring:message code='Cache.ACC_lbl_doc_approve'/></span>
							<span class="nea_cnt" style="display: none;"></span>
						</a>
					</li>
					<li id="li_account_portal_ExpenceMgr">
						<a onclick="mobile_account_PortalLinkClick('ExpenceMgr');" class="nea_portal_middle_link02">
							<span class="nea_ico"></span>
							<span class="nea_txt"><spring:message code='Cache.ACC_lbl_expenceApplicationViewRequest'/></span>
						</a>
					</li>
					<%-- 추후 개발 완료 시 오픈 --%>
					<%-- <li id="li_account_portal_WriteBizTripForm">
						<a onclick="mobile_account_writeBizTripForm();" class="nea_portal_middle_link04">
							<span class="nea_ico"></span>
							<span class="nea_txt"><spring:message code='Cache.lbl_BizTripDraft'/></span>
						</a>
					</li> --%>
					<%-- <li>
						<a href="#" class="nea_portal_middle_link05">
							<span class="nea_ico"></span>
							<span class="nea_txt"><spring:message code='Cache.lbl_UsageReport'/></span>
						</a>
					</li> --%>
				</ul>
			</div>
			<% if ("Y".equals(useTeamsAddIn) && !isMobile) { %>
				<div id="divPopBtnArea" class="FloatingBtn">
					<ul class="popBtn">
						<li class="btnNewPopup"><a href="javascript:void(0);" onclick="XFN_TeamsOpenGroupware('EACCOUNTING');">새창</a><span class="toolTip2">새창</span></li>
					</ul>
				</div>
			<% } else { %>
				<div class="nea_btn_wrap">
					<a id="account_portal_receipt_up" class="nea_btn" onclick="javascript:mobile_account_clickbtn(this);"></a>
				</div>
			<% } %>
			
		</div>
	</div>
	
	<div class="mobile_popup_wrap" id="account_upload_content" style="display: none;">
		<img id="account_upload_image" style="width: 100%;"/>
		<input type="file" id="account_upload_attach_input" onchange="javascript:mobile_account_changeupload(this);" accept="image/*" capture="camera" style="display: none;"/>
	</div>
	
	<div class="mobile_popup_wrap" id="account_upload_popup" style="display: none;">
    	<div class="nea_card_list_popup" style="top: 44%;">
			<div class="nea_post_ex_area">   
				<div class="post_ex">
					<p class="nea_bill_wrap">
						<input type="text" id="account_upload_totalAmount" style="text-align: right; margin-bottom: 3px; width: 80%;" onkeypress="return mobile_account_inputNumChk(event, this);" onkeyup="mobile_account_setNumberComma(this);" />
						<spring:message code='Cache.ACC_lbl_won'/>
					</p>
				</div>
				<div class="post_ex">
					<select class="nea_bill_sel" id="account_upload_expType"></select>
				</div>
				<!-- <div class="post_ex">
					<select class="nea_bill_sel" id="account_upload_rcpType"></select>
				</div> -->
				<div class="post_ex">
					<textarea id="account_upload_storeName" class="post_ex_textarea HtmlCheckXSS ScriptCheckXSS" placeholder="<spring:message code='Cache.ACC_msg_inputFranchiseCorpName'/>"></textarea>
				</div>
				<div class="post_ex">
					<textarea id="account_upload_usageText" class="post_ex_textarea HtmlCheckXSS ScriptCheckXSS" placeholder="<spring:message code='Cache.ACC_msg_inputComment'/>"></textarea>
				</div>
				<div class="post_ex">
					<span class="th"><spring:message code='Cache.ACC_lbl_approveDate'/></span>
					<span class="tx">
						<input type="text" id="account_upload_useDate" class="input_date HtmlCheckXSS ScriptCheckXSS" readonly="readonly" />
					</span>
				</div>
					<div class="post_ex">
						<span class="th"><spring:message code='Cache.lbl_useTime'/></span>
						<span class="tx">
							<select id="account_upload_useTimeHour"></select>
							&nbsp;:&nbsp;
							<select id="account_upload_useTimeMinute"></select>
							<input type="hidden" id="account_upload_useTime" />
						</span>
					</div>
				<div class="post_ex">
					<span class="th"><spring:message code='Cache.ACC_lbl_photoDate'/></span>
					<span class="tx" id="account_upload_photoDate"></span>
				</div> 
			</div>
			
			<div class="mobile_popup_btn">
				<a id="account_upload_popup_ok" onclick="javascript:mobile_account_clickbtn(this);" class="g_btn03"><spring:message code='Cache.btn_Confirm'/></a>
				<a id="account_upload_popup_cancel" onclick="javascript:mobile_account_clickbtn(this);" class="g_btn04"><spring:message code='Cache.lbl_Cancel'/></a>
			</div>
		</div>
		<!-- HIDDEN FIELD -->
		<input type="hidden" id="account_upload_storeAddress">	<!-- 주소 -->
    </div>
</div>
