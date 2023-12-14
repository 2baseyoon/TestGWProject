<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
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
<div data-role="page" id="account_list_page" class="mob_rw">	
	<script>
		var ApprovalMenu = ${Menu};	//좌측 메뉴
		var proaas = "${aesSalt}";
		var proaaI = "${aesIv}";
		var proaapp = "${aesPassPhrase}";
		var aesUtil = new AesUtil("${aesKeysize}", "${aesIterationCount}");
	</script>
	<header class="header" id="account_list_header">
		<div class="sub_header">
			<div class="l_header">
				<a href="javascript:mobile_comm_TopMenuClick('account_list_topmenu');" class="topH_menu"><span></span></a>
				<div class="menu_link gnb">
					<span id="account_portal_title" class="topH_tit"></span>
					<div class="cover_leftmenu" style="display:none;">
						<div class="LsubHeader">
							<span class="LsubTitle approval" onclick="mobile_account_PortalLinkClick('Portal');"><spring:message code='Cache.ACC_lbl_eAccounting'/></span>
							<span class="LsubTitle_btn">
								<button type="button" onclick="mobile_comm_TopMenuClick('account_list_topmenu',true);return false;" class="btn_close ui-btn ui-shadow ui-corner-all"><i>닫기</i></button>
							</span>
						</div>
						<div class="tree_default" id="account_list_topmenu"></div>
					</div>
					<div class="left_bg_dim" onclick="mobile_comm_TopMenuClick('account_list_topmenu',true);return false;" style="display: none;"></div>
				</div>
			</div>                	
			<div class="utill">			  
			  <a href="javascript: mobile_account_reload();" class="topH_reload"><span class="Hicon"><spring:message code='Cache.btn_apv_refresh'/></span></a>			  
			</div>
		</div>
	</header>

	<div data-role="content" class="cont_wrap" id="account_list_content">
		<!-- 권한있는 담당업무함 -->
		<div class="sel_eaccounting_wrap" id="account_list_div_Jobfunction" style="display: none;">
			<select id="account_list_Jobfunction" onchange="mobile_approval_changeListJobBiz(this);">
				<!-- <option value="A"><spring:message code='Cache.lbl_Whole'/></option>  -->
			</select>
		</div>
		<!-- 권한있는 업무문서함 -->
		<div class="sel_eaccounting_wrap" id="account_list_div_BizDoc" style="display: none;">
			<select id="account_list_BizDoc" onchange="mobile_approval_changeListJobBiz(this);">
				<!-- <option value="A"><spring:message code='Cache.lbl_Whole'/></option>  -->
			</select>
		</div>
		
		<div class="nea_list_top_wrap" id="account_list_div_allchk_AppExpence" style="display: none;">
			<input type="checkbox" id="account_list_allchk_AppExpense" name="account_list_allchk" onchange="mobile_account_checkAll(this);"><label for="account_list_allchk_AppExpense"><spring:message code='Cache.lbl_apv_selectall'/></label>
			<div class="nea_list_top_tx_r">
				<p class="nea_list_top_tx">
					<span class="nea_list_top_tx_p" id="account_list_chkcnt"></span><spring:message code='Cache.lbl_DocCount'/> /
					<span class="nea_list_top_tx_p" id="account_list_chkamount"></span><spring:message code='Cache.lbl_krw'/>
				</p>
				<a id="account_list_application" onclick="javascript:mobile_account_clickbtn(this);" class="nea_list_btn"><spring:message code='Cache.ACC_btn_application'/></a>
			</div>
		</div>
		<div class="all_chk" id="account_list_div_allchk" style="display: none;">
	    	<p><input type="checkbox" id="account_list_allchk" name="account_list_allchk"  onchange="mobile_account_checkAll(this);"><label for="account_list_allchk"><spring:message code='Cache.lbl_apv_selectall'/> <strong class="point_cr" id="approval_list_chkcnt"></strong></label></p> <!-- 전체선택 -->
	    	<div class="r_drop_menu dropMenu">
				<a href="#" class="btn_drop_menu" id="account_list_dropmenu" onclick="mobile_account_clickDropmenu(this)"></a>
				<ul class="menu_list" id="account_list_dropmenuitems"></ul>
			</div>
		</div>
		<div class="sel_eaccounting_wrap" id="account_list_cond" style="display: none">
			<select id="account_list_expensetype" onchange="mobile_account_changeExpenseType(this);">
				<option value="A"><spring:message code='Cache.lbl_Whole'/></option>
				<option value="C"><spring:message code='Cache.ACC_lbl_corpCard'/></option>
				<option value="M"><spring:message code='Cache.ACC_lbl_mobileReceipt'/></option>
			</select>
			<select id="account_list_expenceAppMngUserListType" style="display: none;">
			</select>
		</div>
 		<div class="card_list">
			<ul id="account_list_list"></ul>
			<div id="account_list_more" class="btn_list_more" style="display: none;">
				<a onclick="javascript: mobile_account_nextlist();"><span><spring:message code='Cache.lbl_MoreView'/></span></a><!-- 더보기 -->
			</div>
		</div>
		<% if ("Y".equals(useTeamsAddIn) && !isMobile) { %>
				<div id="divPopBtnArea" class="FloatingBtn">
                	<ul class="popBtn">
                    	<li class="btnNewPopup"><a href="javascript:void(0);" onclick="XFN_TeamsOpenGroupware('EACCOUNTING');">새창</a><span class="toolTip2">작성</span></li>
                	</ul>
        		</div>
		<% } else { %>
				<div class="nea_btn_wrap">
					<a id="account_list_receipt_up" class="nea_btn" onclick="javascript:mobile_account_clickbtn(this);"></a>
				</div>
		<% } %>
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
	
	<div class="mobile_popup_wrap" id="account_list_cardpopup" style="display:none;">
    	<div class="card_list_popup">
			<div class="card_list_popup_cont">
				<p class="card_list_title"><spring:message code='Cache.ACC_msg_selectExpenceType'/></p>
				<div class="card_list_radio_wrap" id="account_list_card_radio_div" style="height: 160px; overflow-y: scroll; margin-bottom: 13px;">
				</div>
			</div>
			<div class="mobile_popup_btn">
				<a onclick="javascript:mobile_account_clickbtn(this);" class="g_btn03" id="account_list_card_popup_ok"><spring:message code='Cache.btn_Confirm'/></a>
				<a onclick="javascript:mobile_account_clickbtn(this);" class="g_btn04" id="account_list_card_popup_cancel"><spring:message code='Cache.lbl_Cancel'/></a>
			</div>
		</div>
    </div>
    
    <div class="mobile_popup_wrap" id="account_list_card_proof" style="display: none;">
    	<div class="card_list_bill_popup">
			<div class="eaccounting_bill">
				<p class="card_number">
					<span id="account_list_card_proof_CardNo"></span>
				</p>
				<div class="card_info01_wrap">
					<dl class="card_info">
						<dt><spring:message code='Cache.ACC_lbl_confirmNum'/></dt>
						<dd id="account_list_card_proof_ApproveNo"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.ACC_lbl_TransactionDate'/></dt>
						<dd id="account_list_card_proof_UseDate"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.ACC_lbl_payMethod'/></dt>
						<dd id="account_list_card_proof_PayMethod"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.ACC_lbl_franchiseCorpName'/></dt>
						<dd id="account_list_card_proof_StoreName"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.ACC_lbl_franchiseCorpNo'/></dt>
						<dd id="account_list_card_proof_StoreNo"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.lbl_RepresentativeName'/></dt>
						<dd id="account_list_card_proof_StoreRepresentative"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.ACC_lbl_bizRegNo'/></dt>
						<dd id="account_list_card_proof_StoreRegNo"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.lbl_PhoneNum'/></dt>
						<dd id="account_list_card_proof_StoreTel"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.lbl_Address'/></dt>
						<dd id="account_list_card_proof_StoreAddress"></dd>
					</dl>
				</div>
				<div class="card_info02_wrap">
					<dl class="card_info">
						<dt><spring:message code='Cache.ACC_lbl_amt'/></dt>
						<dd id="account_list_card_proof_RepAmount"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.ACC_lbl_taxType'/></dt>
						<dd id="account_list_card_proof_TaxAmount"></dd>
					</dl>
					<dl class="card_info">
						<dt><spring:message code='Cache.ACC_lbl_serviceAmt'/></dt>
						<dd id="account_list_card_proof_ServiceAmount"></dd>
					</dl>
				</div>
				<div class="card_info03_wrap">
					<dl class="card_info">
						<dt><spring:message code='Cache.lblSum'/></dt>
						<dd id="account_list_card_proof_AmountWon_InfoIndex"></dd>
					</dl>
				</div>
			</div>
			<div class="mobile_popup_btn">
				<a id="account_list_card_proof_ok" onclick="javascript: mobile_account_clickbtn(this)" class="g_btn03"><spring:message code='Cache.btn_Confirm'/></a>
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

	<div class="bg_dim" style="display: none;"></div>

</div>

