<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div data-role="page" id="account_list_receipt_page">		
	<header class="header" id="account_list_receipt_header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript:mobile_comm_TopMenuClick('account_list_receipt_topmenu');" class="topH_menu"><span>전체메뉴</span></a>
				<div class="menu_link gnb">
					<span id="account_list_receipt_title" class="topH_tit">영수증 등록내역</span>
					<div class="cover_leftmenu" style="display:none;">
						<div class="LsubHeader">
							<span class="LsubTitle approval">영수증 등록내역</span>
							<span class="LsubTitle_btn">
								<button type="button" onclick="mobile_comm_TopMenuClick('account_list_receipt_topmenu',true);return false;" class="btn_close ui-btn ui-shadow ui-corner-all"><i>닫기</i></button>
							</span>
						</div>
						<div class="tree_default" id="account_list_receipt_topmenu"></div>
					</div>
					<div class="left_bg_dim" onclick="mobile_comm_TopMenuClick('account_list_receipt_topmenu',true);return false;" style="display: none;"></div>
				</div>
			</div>                	
			<div class="utill">			  
			  <a href="javascript: mobile_account_clickrefresh('R');" class="topH_reload"><span class="Hicon">새로고침</span></a>			  
			</div>
		</div>
	</header>

	<div data-role="content" class="cont_wrap" id="account_list_receipt_content">
		<div class="btn_eaccounting_wrap">
			<!-- 영수증 -->
			<a id="account_list_receipt_receipt" class="btn_receipt" onclick="javascript:mobile_account_clickbtn(this);"><span><spring:message code='Cache.btn_CostApplication'/></span></a> <!-- 비용신청 -->
			<a id="account_list_receipt_receipt_up" class="btn_receipt_upload" onclick="javascript:mobile_account_clickbtn(this);"><span><spring:message code='Cache.btn_uploadReceipt'/></span></a> <!-- 영수증 업로드 -->
			<a id="account_list_receipt_receipt_del" class="btn_receipt_del" onclick="javascript:mobile_account_clickbtn(this);"><span><spring:message code='Cache.ACC_lbl_delete'/></span></a> <!-- 삭제 -->
		</div>
 		<div class="receipt_list">
			<!-- 영수증 등록 내역 목록 영역 -->
			<ul id="account_list_receipt_list"></ul>
			
			<div id="account_list_receipt_more" class="btn_list_more" style="display: none;">
				<a onclick="javascript: mobile_account_nextlist('receipt');"><span><spring:message code='Cache.lbl_MoreView'/></span></a><!-- 더보기 -->
			</div>
		</div>
	</div>
	
	<div class="mobile_popup_wrap" id="account_list_receipt_popup" style="display:none;">
    	<div class="receipt_upload_popup">
			<div class="receipt_upload_img" id="account_list_receipt_image"></div>
			<div class="mobile_popup_btn">
				<a onclick="javascript:mobile_account_clickbtn(this);" class="g_btn03" id="account_list_receipt_popup_ok"><spring:message code='Cache.btn_Confirm'/></a>
			</div>
		</div>
    </div>

	<div id="account_upload_content" style="display: none;">
		<img id="account_upload_image" style="width: 100%;"/>
		<input type="file" id="account_upload_attach_input" onchange="javascript:mobile_account_changeupload(this);" accept="image/*" capture="camera" style="display: none;"/>
	</div>
	
	<div class="mobile_popup_wrap" id="account_upload_popup" style="display: none;">
    	<div class="card_list_popup">
			<div class="post_ex_area">   
				<div class="post_ex">
					<span class="th mt"><spring:message code='Cache.ACC_expType'/></span>
					<span class="tx"><select class="" id="account_upload_expType"></select></span>
				</div>
				<div class="post_ex">
					<span class="th"><spring:message code='Cache.ACC_lbl_receiptType'/></span>
					<span class="tx"><select class="" id="account_upload_rcpType"></select></span>
				</div>      	  
				<div class="post_ex">
					<span class="th"><spring:message code='Cache.ACC_useHistory'/></span>
					<span class="tx"><textarea id="account_upload_usageText" class="post_ex_textarea HtmlCheckXSS ScriptCheckXSS" placeholder="<spring:message code='Cache.ACC_msg_usePurpose'/>"></textarea></span>
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
    </div>

	<div class="bg_dim" style="display: none;"></div>

</div>

