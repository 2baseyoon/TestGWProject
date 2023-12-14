<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<style>
	.AXInput{width: 50%; height: 25px;}
	.AXFormTable tbody td table td{
		border-right: 1px solid #ddd !important;
	    border-left: 1px solid #ddd !important;
        border-bottom: 1px solid #ddd !important;
	}
</style>

<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code="Cache.lbl_CompanyInfoManage"/></span> <!-- 회사 정보 관리 -->
	<!-- TODO 초기 페이지로 설정 향후 개발 (미구현 사항으로 숨김처리) -->
	<%-- <a href="#" class="set_box">
		<span class="set_initialpage"><p><spring:message code="Cache.btn_SettingFirstPage"/></p></span>
	</a> --%>
</h3>
<form id="form1">
	<div class="AXTabs">
		<div class="AXTabsTray" style="height:30px">
			<a id="infoTab" href="#" onclick="clickTab(this);" class="AXTab on" value="info"><spring:message code="Cache.lbl_BasicInfoManage"/></a> <!-- 기본 정보 관리 -->
			<a id="designTab" href="#" onclick="clickTab(this);" class="AXTab" value="design"><spring:message code="Cache.lbl_DesignManage"/></a> <!-- 디자인 관리 -->
		</div>
		<div id="info" class="tab-content on">
			<table class="AXFormTable AXFormTable_h">
				<colgroup>
					<col width="150px;">
					<col width="*">
				</colgroup>
				<tbody>
					<tr>
						<th><spring:message code="Cache.lbl_Domain"/></th> <!-- 도메인 -->
						<td id="txt_domain"></td>
						<th><spring:message code="Cache.lbl_apv_entcode"/></th> <!-- 회사코드 -->
						<td id="txt_domainCode"></td>
					</tr>
					<tr>
						<th><spring:message code="Cache.lbl_ServicePeriod"/></th> <!-- 서비스 기간 -->
						<td id="txt_servicePeriod"></td>
						<th><spring:message code="Cache.lbl_UserCount"/> / <spring:message code="Cache.lbl_License_UserCnt"/></th> <!-- 사용자 수 / 라이선스 사용자 수 -->
						<td id="txt_userCount"></td>
					</tr>
				</tbody>
			</table>
			<table class="AXFormTable AXFormTable_h mt12">
				<colgroup>
					<col width="150px;">
					<col width="*">
				</colgroup>
				<tbody>
					<tr>
						<th><span class="star">*</span> <spring:message code="Cache.lbl_CompanyName"/></th> <!-- 회사명 -->
						<td>
							<input type="text" id="input_companyName" class="cInput HtmlCheckXSS ScriptCheckXSS" style="width: 70%;"/>
							<input type="button" value="<spring:message code='Cache.lbl__DicModify'/>" onclick="dictionaryLayerPopup('true', 'domainName');" class="AXButton"> <!-- 다국어 -->
							<input type="hidden" id="hid_domainName" value="" />
						</td>
						<th><span class="star">*</span> <spring:message code="Cache.lbl_RepName"/></th> <!-- 대표자명 -->
						<td>
							<input type="text" id="input_repName" class="cInput HtmlCheckXSS ScriptCheckXSS"/>
						</td>
					</tr>
					<tr>
						<th><span class="star">*</span> <spring:message code="Cache.lbl_RepNumber"/></th> <!-- 대표번호 -->
						<td>
							<input type="text" id="input_repNumber" class="cInput HtmlCheckXSS ScriptCheckXSS"/>
						</td>
						<th><span class="star">*</span> <spring:message code="Cache.lbl_CorpNumber"/></th> <!-- 법인번호 -->
						<td>
							<input type="text" id="input_corpNumber" class="cInput HtmlCheckXSS ScriptCheckXSS"/>
						</td>
					</tr>
					<tr>
						<th><span class="star">*</span> <spring:message code="Cache.lbl_ComAddress"/></th> <!-- 회사주소 -->
						<td colspan="3">
							<input type="text" id="input_comAddress" class="cInput HtmlCheckXSS ScriptCheckXSS"/>
						</td>
					</tr>
					<tr>
						<th><span class="star">*</span> <spring:message code="Cache.lbl_apv_AdminName"/></th>
						<td>
							<input type="text" id="input_adminName" class="cInput HtmlCheckXSS ScriptCheckXSS"/>
						</td>
						<th><span class="star">*</span> <spring:message code="Cache.lbl_ChargePersonContact"/></th> <!-- 담당자 연락처 -->
						<td>
							<input type="text" id="input_adminContact" class="cInput HtmlCheckXSS ScriptCheckXSS"/>
						</td>
					</tr>
					<tr>
						<th><span class="star">*</span> <spring:message code="Cache.lbl_usageGoogleSchedule"/></th> <!-- 구글일정 사용여부 -->
						<td>
							<select id="select_useGoogleSchedule" class="AXSelect">
								<option value="" selected><spring:message code="Cache.lbl_Select" /></option>
								<option value="Y"><spring:message code="Cache.lbl_Use" /></option>
								<option value="N"><spring:message code="Cache.lbl_noUse" /></option>
							</select>
						</td>
						<th><span class="star">*</span> <spring:message code="Cache.lbl_GoogleClientID"/></th> <!-- 구글 Client ID -->
						<td>
							<input type="text" id="input_googleClientID" class="cInput googleInput HtmlCheckXSS ScriptCheckXSS"/>
						</td>
					</tr>
					<tr>
						<th><span class="star">*</span> <spring:message code="Cache.lbl_GoogleClientKey"/></th> <!-- 구글 Client Key -->
						<td>
							<input type="text" id="input_googleClientKey" class="cInput googleInput HtmlCheckXSS ScriptCheckXSS"/>
						</td>
						<th><span class="star">*</span> <spring:message code="Cache.lbl_GoogleRedirectURL"/></th> <!-- 구글 Redirect URL -->
						<td>
							<input type="text" id="input_googleRedirectURL" class="cInput googleInput HtmlCheckXSS ScriptCheckXSS"/>
						</td>
					</tr>
				</tbody>
			</table>
		</div>
		<div id="design" class="tab-content on" style="display: none;">
			<table id="tbl_potalBanner" class="AXFormTable AXFormTable_h">
				<colgroup>
					<col width="150">
					<col width="34">
					<col width="*">
				</colgroup>
				<tbody>
					<tr>
						<th rowspan="2"><spring:message code="Cache.lbl_PCLogo"/></th> <!-- PC 로고 -->
						<td colspan="2">
							<input type="text" value="" id="input_pcFileText" class="cInput3" placeholder="<spring:message code='Cache.lbl_vacationMsg30'/>" readonly> <!-- 선택된 파일 없음 -->
							<a href="#" class="AXButton btn_file" onclick="$('#input_pcLogo').click();"><spring:message code="Cache.lbl_SelectFile"/></a> <!-- 파일선택 -->
							<a id="delBtn_pcLogo" class="AXButton" href="#" style="display: none;" onclick="deleteLogo('PC');"><spring:message code="Cache.btn_delete"/></a> &nbsp;&nbsp; <!-- 삭제 -->
							<p class="explain"><span class="star">*</span> W : 180px, H : 25px 이하 사이즈 / 1MB 이하, png 확장자</p>
							<div style="width:0px; height:0px; overflow:hidden;">
								<input type="file" id="input_pcLogo" onchange="fileUpload('PC', this);">
								<input type="hidden" id="hid_pcLogoPath" value="" />
							</div>
						</td>
					</tr>
					<tr>
						<td colspan="2">
							<span id="span_pcLogo" class="caution" style="display: none;"><spring:message code="Cache.msg_noRegisteredLogo"/></span> <!-- 등록된 로고가 없습니다. -->
							<p id="p_pcLogo" class="l_img1" style="display: none;"><img id="img_pcLogo" onerror="coviCtrl.imgError(this);"></p>
						</td>
					</tr>
					<tr>
						<th rowspan="2"><spring:message code="Cache.lbl_MobileLogo"/></th> <!-- Mobile 로고 -->
						<td colspan="2">
							<input type="text" value="" id="input_mobileFileText" class="cInput3" placeholder="<spring:message code='Cache.lbl_vacationMsg30'/>" readonly> <!-- 선택된 파일 없음 -->
							<a href="#" class="AXButton btn_file" onclick="$('#input_mobileLogo').click();"><spring:message code="Cache.lbl_SelectFile"/></a> <!-- 파일선택 -->
							<a id="delBtn_mobileLogo" class="AXButton" href="#" style="display: none;" onclick="deleteLogo('Mobile');"><spring:message code="Cache.btn_delete"/></a> &nbsp;&nbsp; <!-- 삭제 -->
							<p class="explain"><span class="star">*</span> W : 400px, H : 52px 이하 사이즈 / 1MB 이하, png 확장자</p>
							<div style="width:0px; height:0px; overflow:hidden;">
								<input type="file" id="input_mobileLogo" onchange="fileUpload('Mobile', this);">
								<input type="hidden" id="hid_mobileLogoPath" value="" />
							</div>
						</td>
					</tr>
					<tr>
						<td colspan="2">
							<span id="span_mobileLogo" class="caution" style="display: none;"><spring:message code="Cache.msg_noRegisteredLogo"/></span> <!-- 등록된 로고가 없습니다. -->
							<p id="p_mobileLogo" class="l_img2" style="display: none;"><img id="img_mobileLogo" onerror="coviCtrl.imgError(this);" alt=""></p>
						</td>
					</tr>
					<tr>
						<th rowspan="7"><spring:message code="Cache.lbl_PortalBanner"/></th> <!-- 포탈 배너 -->
						<td class="center">
							<span class="chkStyle01">
								<input type="checkbox" id="chk_all" class="chk_portalBanner"><label for="chk_all"><span></span></label>
							</span>
						</td>
						<td>
							<a href="#" class="AXButton btn_plus" onclick="addRow();"><spring:message code="Cache.btn_Add"/></a> <!-- 추가 -->
							<a href="#" class="AXButton btn_minus" onclick="delRow();"><spring:message code="Cache.btn_delete"/></a>  &nbsp;&nbsp; <!-- 삭제 -->
							<p class="explain"><span class="star">*</span> 3개까지 등록가능</p>
						</td>
					</tr>
					<tr class="tr_portalBanner_hidden" style="display: none;">
						<td rowspan="2" class="center">
							<span class="chkStyle01">
								<input type="checkbox" id="ccc03" class="chk_portalBanner"><label for="ccc03"><span></span></label>
							</span>
						</td>
						<td>
							<input type="text" value="" id="input_portalBanner_hidden" class="cInput2" placeholder="<spring:message code='Cache.lbl_vacationMsg30'/>" readonly> <!-- 선택된 파일 없음 -->
							<a href="#" class="AXButton btn_file" onclick="$('#input_file_portalBanner_hidden').click();"><spring:message code="Cache.lbl_SelectFile"/></a> &nbsp;&nbsp; <!-- 파일선택 -->
							<p class="explain"><span class="star">*</span> W : 778px, H : 170px 이하 사이즈 / 1MB 이하, jpg 확장자</p>
							<div style="width:0px; height:0px; overflow:hidden;">
								<input type="file" id="input_file_portalBanner_hidden" onchange="fileUpload('hidden', this);">
								<input type="hidden" id="hid_portalBanner_hidden" value="" />
							</div>
						</td>
					</tr>
					<tr class="tr_portalBanner_hidden" style="display: none;">
						<td>
							<span id="span_portalBanner_hidden" class="caution"><spring:message code="Cache.msg_noRegisteredPortalBanners"/></span> <!-- 등록된 포탈 배너가 없습니다. -->
							<input type="text" value="" id="input_portalBanner_link" class="cInput2" placeholder="<spring:message code='Cache.msg_EnterLinkURL'/>" >
							<p id="p_portalBanner_hidden" class="l_img3" style="display: none;"><img id="img_portalBanner_hidden" src="" onerror="coviCtrl.imgError(this);" alt=""></p>
						</td>
					</tr>
					<tr class="tr_potalBanner tr_portalBanner_1">
						<td rowspan="2" class="center">
							<span class="chkStyle01">
								<input type="checkbox" id="ccc03" class="chk_portalBanner"><label for="ccc03"><span></span></label>
							</span>
						</td>
						<td>
							<input type="text" value="" id="input_portalBanner_1" class="cInput2" placeholder="<spring:message code='Cache.lbl_vacationMsg30'/>" readonly> <!-- 선택된 파일 없음 -->
							<a href="#" class="AXButton btn_file" onclick="$('#input_file_portalBanner_1').click();"><spring:message code="Cache.lbl_SelectFile"/></a> &nbsp;&nbsp; <!-- 파일선택 -->
							<p class="explain"><span class="star">*</span> W : 778px, H : 170px 이하 사이즈 / 1MB 이하, jpg 확장자</p>
							<div style="width:0px; height:0px; overflow:hidden;">
								<input type="file" id="input_file_portalBanner_1" class="file_portal_banner" onchange="fileUpload('portalBanner_1', this);">
								<input type="hidden" id="hid_portalBanner_1" class="hid_portalBannerPath" value="" />
							</div>
						</td>
					</tr>
					<tr class="tr_portalBanner_1">
						<td>
							<span id="span_portalBanner_1" class="caution"><spring:message code="Cache.msg_noRegisteredPortalBanners"/></span> <!-- 등록된 포탈 배너가 없습니다. -->
							<input type="text" value="" id="input_portalBanner_link_1" class="cInput2" placeholder="<spring:message code='Cache.msg_EnterLinkURL'/>" >
							<p id="p_portalBanner_1" class="l_img3" style="display: none;"><img id="img_portalBanner_1" onerror="coviCtrl.imgError(this);"></p>
						</td>
					</tr>
				</tbody>
			</table>
		</div>
		<div align="center" class="pt10">
			<input type="button" value="<spring:message code='Cache.btn_save'/>" onclick="saveCompanyInfo();" class="AXButton"> <!-- 저장 -->
		</div>
		<input type="hidden" id="hid_domainID" value="" />
	</div>
</form>
<script type="text/javascript">
	var bannerRowCnt = 1; // 포탈 배너 테이블 열 수

	$(document).ready(function(){
		initContent();
	});
	
	function initContent(){
		setData();
		
		clickTab($("#infoTab"));
		
		$("#input_pcLogo").on("change", function(){
			var file = $(this)[0].files[0];
			
			if(file.name != ""){
				var pathPoint = file.name.lastIndexOf('.');
				var filePoint = file.name.substring(pathPoint + 1, file.name.length);
				var fileType = filePoint.toLowerCase();
				
				if(file.size > 1000000){
					Common.Warning("<spring:message code='Cache.msg_only1MB'/>"); // 1MB 이하만 가능합니다
					$(this).val("");
					$("#input_pcFileText").val("");
					$("#img_pcLogo").attr("src", "");
				}else if(fileType != "png"){
					Common.Warning("<spring:message code='Cache.msg_onlyPng'/>"); // png만 가능합니다.
					$(this).val("");
					$("#input_pcFileText").val("");
					$("#img_pcLogo").attr("src", "");
				}else{
					$("#delBtn_pcLogo").show();
					$("#p_pcLogo").show();
					$("#span_pcLogo").hide();
					
					if(typeof(file) == "undefined") $("#input_pcFileText").val("");
					else $("#input_pcFileText").val(file.name);
				    readURL("PC", this);
				}
			}
		});
		
		$("#input_mobileLogo").on("change", function(){
			var file = $(this)[0].files[0];
			
			if(file.name != ""){
				var pathPoint = file.name.lastIndexOf('.');
				var filePoint = file.name.substring(pathPoint + 1, file.name.length);
				var fileType = filePoint.toLowerCase();
				
				if(file.size > 1000000){
					Common.Warning("<spring:message code='Cache.msg_only1MB'/>"); // 1MB 이하만 가능합니다
					$(this).val("");
					$("#input_mobileFileText").val("");
					$("#img_mobileLogo").attr("src", "");
				}else if(fileType != "png"){
					Common.Warning("<spring:message code='Cache.msg_onlyPng'/>"); // png만 가능합니다.
					$(this).val("");
					$("#input_mobileFileText").val("");
					$("#img_mobileLogo").attr("src", "");
				}else{
					$("#delBtn_mobileLogo").show();
					$("#p_mobileLogo").show();
					$("#span_mobileLogo").hide();
					
					if(typeof(file) == "undefined") $("#input_mobileFileText").val("");
					else $("#input_mobileFileText").val(file.name);
				    readURL("Mobile", this);
				}
			}
		});
		
		$("#input_file_portalBanner_1").on("change", function(){
			var file = $(this)[0].files[0];
			
			if(file.name != ""){
				var pathPoint = file.name.lastIndexOf('.');
				var filePoint = file.name.substring(pathPoint + 1, file.name.length);
				var fileType = filePoint.toLowerCase();
				
				if(file.size > 1000000){
					Common.Warning("<spring:message code='Cache.msg_only1MB'/>"); // 1MB 이하만 가능합니다
					$(this).val("");
					$("#input_portalBanner_1").val("");
					$("#img_portalBanner_1").attr("src", "");
				}else if(fileType != "jpg" && fileType != "jpeg"){
					Common.Warning("<spring:message code='Cache.msg_onlyJpg'/>"); // jpg만 가능합니다.
					$(this).val("");
					$("#input_portalBanner_1").val("");
					$("#img_portalBanner_1").attr("src", "");
				}else{
					$("#hid_portalBanner_1").val("");
					$("#p_portalBanner_1").show();
					$("#span_portalBanner_1").hide();
					
					if(typeof(file) == "undefined") $("#input_portalBanner_1").val("");
					else $("#input_portalBanner_1").val(file.name);
				    readURL("portalBanner_1", this);
				}
			}
		});
		
		$("#chk_all").on("click", function(){
			$(".chk_portalBanner").prop("checked", $(this).is(":checked"));
		});
		
		$("#select_useGoogleSchedule").on("change", function(){
			var selVal = $(this).find("option:selected").val();
			
			if(selVal == "Y"){
				$(".googleInput").prop("disabled", false);
			}else{
				$(".googleInput").prop("disabled", true);
			}
		});
	}

	function dictionaryLayerPopup(hasTransBtn, dicCallback) {
		var option = {
			lang : 'ko',
			hasTransBtn : hasTransBtn,
			allowedLang : 'ko,en,ja,zh,lang1,lang2',
			useShort : 'false',
			dicCallback : dicCallback,
			popupTargetID : 'DictionaryPopup',
			init : 'initDicPopup',
			openerID : ''
		};
		
		var url = "";
		url += "/covicore/control/calldic.do?lang=" + option.lang;
		url += "&hasTransBtn=" + option.hasTransBtn;
		url += "&useShort=" + option.useShort;
		url += "&dicCallback=" + option.dicCallback;
		url += "&allowedLang=" + option.allowedLang;
		url += "&popupTargetID=" + option.popupTargetID;
		url += "&init=" + option.init;
		url += "&openerID=" + option.openerID;
		
		parent.Common.open("", "DictionaryPopup", "<spring:message code='Cache.lbl_MultiLangSet'/>", url, "400px", "280px", "iframe", true, null, null, true);
	}
	
	function initDicPopup(){
		return $("#hid_domainName").val() == "" ? $("#input_companyName").val() : $("#hid_domainName").val();
	}
	
	function domainName(data){
		$("#hid_domainName").val(coviDic.convertDic(data));
		if(document.getElementById("input_companyName").value == ""){
			document.getElementById("input_companyName").value = CFN_GetDicInfo($("#hid_domainName").val());
		}
		
		Common.Close("DictionaryPopup");
	}
	
	function setFullDisplayName(){
		var langCode = Common.getSession("lang");
		
		if ($("#hid_domainName").val() == "") {
			switch (langCode.toUpperCase()) {
				case "KO": sDictionaryInfo = $("#input_companyName").val() + ";;;;;;;;;"; break;
				case "EN": sDictionaryInfo = ";" + $("#input_companyName").val() + ";;;;;;;;"; break;
				case "JA": sDictionaryInfo = ";;" + $("#input_companyName").val() + ";;;;;;;"; break;
				case "ZH": sDictionaryInfo = ";;;" + $("#input_companyName").val() + ";;;;;;"; break;
				case "E1": sDictionaryInfo = ";;;;" + $("#input_companyName").val() + ";;;;;"; break;
				case "E2": sDictionaryInfo = ";;;;;" + $("#input_companyName").val() + ";;;;"; break;
				case "E3": sDictionaryInfo = ";;;;;;" + $("#input_companyName").val() + ";;;"; break;
				case "E4": sDictionaryInfo = ";;;;;;;" + $("#input_companyName").val() + ";;"; break;
				case "E5": sDictionaryInfo = ";;;;;;;;" + $("#input_companyName").val() + ";"; break;
				case "E6": sDictionaryInfo = ";;;;;;;;;" + $("#input_companyName").val(); break;
			}
			document.getElementById("hid_domainName").value = sDictionaryInfo
		}
	}
	
	function setData(){
		$.ajax({
			type: "POST",
			data: {
				"DomainID" : Common.getSession("DN_ID")
			},
			async: false,
			url: "/covicore/domain/get.do",
			success: function (data){
				//var backStorage = Common.getBaseConfig("BackStorage").replace("{0}", data.list[0].DomainCode);
				var serviceStartDate = data.list[0].ServiceStart.split(" ")[0];
				var serviceEndDate = data.list[0].ServiceEnd.split(" ")[0];
				var pcLogoImagePath = "";
				var mobileLogoImagePath = "";
				var portalBannerPaths = data.list[0].DomainBannerPath.split(";");
				var portalBannerLinks = data.list[0].DomainBannerLink.split(";");
				
				if(data.list[0].DomainImagePath != ""){
					pcLogoImagePath = data.list[0].DomainImagePath.split(";")[0];
					mobileLogoImagePath = data.list[0].DomainImagePath.split(";")[1];
				}
				
				$("#hid_domainID").val(data.list[0].DomainID)
				$("#txt_domainCode").text(data.list[0].DomainCode);
				$("#txt_domain").text(data.list[0].DomainURL);
				$("#txt_servicePeriod").text(serviceStartDate + " ~ " + serviceEndDate);
				if(Number(data.list[0].ActiveUser) >= Number(data.list[0].ServiceUser)){
					$("#txt_userCount").html("<font color='red'>" + data.list[0].ActiveUser + "</font> / " + data.list[0].ServiceUser);
				}else{
					$("#txt_userCount").text(data.list[0].ActiveUser + " / " + data.list[0].ServiceUser);
				}
				$("#input_companyName").val(CFN_GetDicInfo(data.list[0].MultiDisplayName), Common.getSession("lang"));
				$("#hid_domainName").val(data.list[0].MultiDisplayName);
				$("#input_repName").val(data.list[0].DomainRepName);
				$("#input_repNumber").val(data.list[0].DomainRepTel);
				$("#input_corpNumber").val(data.list[0].DomainCorpTel);
				$("#input_comAddress").val(data.list[0].DomainAddress);
				$("#input_adminName").val(data.list[0].ChargerName);
				$("#input_adminContact").val(data.list[0].ChargerTel);
				$("#select_useGoogleSchedule").val(data.list[0].IsUseGoogleSchedule);
				$("#input_googleClientID").val(data.list[0].GoogleClientID);
				$("#input_googleClientKey").val(data.list[0].GoogleClientKey);
				$("#input_googleRedirectURL").val(data.list[0].GoogleRedirectURL);
				
				if(data.list[0].IsUseGoogleSchedule == "Y"){
					$(".googleInput").prop("disabled", false);
				}else{
					$(".googleInput").prop("disabled", true);
				}
				
				if(pcLogoImagePath != null && pcLogoImagePath != ""){
					$("#img_pcLogo").attr("src", "/covicore/common/logo/"+pcLogoImagePath+".do");
					$("#hid_pcLogoPath").val(pcLogoImagePath);
					$("#p_pcLogo").show();
					$("#delBtn_pcLogo").show();
				}else{
					$("#span_pcLogo").show();
				}
				
				if(mobileLogoImagePath != null && mobileLogoImagePath != ""){
					$("#img_mobileLogo").attr("src", "/covicore/common/logo/"+mobileLogoImagePath+".do");
					$("#hid_mobileLogoPath").val(mobileLogoImagePath);
					$("#p_mobileLogo").show();
					$("#delBtn_mobileLogo").show();
				}else{
					$("#span_mobileLogo").show();
				}
				
				if(portalBannerPaths != "" && portalBannerPaths.length > 0){
					$(portalBannerPaths).each(function(idx, path){
						if(path){
							if(idx == 0){
								$("#img_portalBanner_1").attr("src", "/covicore/common/banner/"+path+".do");
								$("#hid_portalBanner_1").val(path);
								$("#p_portalBanner_1").show();
								$("#span_portalBanner_1").hide();
								$("#input_portalBanner_link_1").val(portalBannerLinks[idx]);
							}else{
								addRow();
								$("#img_portalBanner_" + bannerRowCnt).attr("src", "/covicore/common/banner/"+path+".do");
								$("#hid_portalBanner_" + bannerRowCnt).val(path);
								$("#p_portalBanner_" + bannerRowCnt).show();
								$("#span_portalBanner_" + bannerRowCnt).hide();
								if (portalBannerLinks.length>idx && portalBannerLinks[idx] != "") $("#input_portalBanner_link_"+bannerRowCnt).val(portalBannerLinks[idx]);
							}
						}
					});
				}
			},
			error: function(response, status, error){
			     CFN_ErrorAjax("/covicore/domain/get.do", response, status, error);
			}
		});
	}
	
	function saveCompanyInfo(){
		if(!chkValidation()){
			return false;
		}
		
		var formData = new FormData();
		var portalBannerPathList = new Array($(".tr_potalBanner").length);
		
		$(".file_portal_banner").each(function(idx, item){
			var file = item.files[0];
			
			if(file != null){
				formData.append("PortalBannerFile", file);
			}
		});
		
		$(".hid_portalBannerPath").each(function(idx, item){
			var path = $(item).val();
			var bIdx = Number($(item).attr("id").replace(/[^\-\.0-9]/g, ""));
			
			bIdx = (bIdx % 3) == 0 ? 2 : (bIdx % 3) - 1;
			portalBannerPathList[bIdx] = path;
		});
		
		setFullDisplayName();
		
		formData.append("DomainID", $("#hid_domainID").val());
		formData.append("DomainCode", $("#txt_domainCode").text());
		formData.append("DisplayName", $("#input_companyName").val());
		formData.append("MultiDisplayName", $("#hid_domainName").val());
		formData.append("DomainRepName", $("#input_repName").val());
		formData.append("DomainRepTel", $("#input_repNumber").val());
		formData.append("DomainCorpTel", $("#input_corpNumber").val());
		formData.append("DomainAddress", $("#input_comAddress").val());
		formData.append("ChargerName", $("#input_adminName").val());
		formData.append("ChargerTel", $("#input_adminContact").val());
		formData.append("PCLogoFile", $("#input_pcLogo")[0].files[0]);
		formData.append("MobileLogoFile", $("#input_mobileLogo")[0].files[0]);
		formData.append("PCLogoPath", $("#hid_pcLogoPath").val());
		formData.append("MobileLogoPath", $("#hid_mobileLogoPath").val());
		formData.append("PortalBannerPaths", portalBannerPathList.join(";"));
		formData.append("IsUseGoogleSchedule", $("#select_useGoogleSchedule").val());
		formData.append("GoogleClientID", $("#input_googleClientID").val());
		formData.append("GoogleClientKey", $("#input_googleClientKey").val());
		formData.append("GoogleRedirectURL", $("#input_googleRedirectURL").val());
		formData.append("DomainBannerLink", ($("#input_portalBanner_link_1").length>0?$("#input_portalBanner_link_1").val():"")
				+";"+($("#input_portalBanner_link_2").length>0?$("#input_portalBanner_link_2").val():"")
				+";"+($("#input_portalBanner_link_3").length>0?$("#input_portalBanner_link_3").val():""));

		$.ajax({
			type: "POST",
			data: formData,
			processData: false,
			contentType: false,
			url: "/covicore/domain/addInfo.do",
			success: function(data){
				if(data.status == "SUCCESS"){
					Common.Inform("<spring:message code='Cache.msg_apv_331'/>", "Information", function(result){ // 저장되었습니다.
						if(result){
							location.reload();
						}
					});
				}else{
					Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생했습니다.
				}
			},
			error: function(response, status, error){
			     CFN_ErrorAjax("/covicore/domain/addInfo.do", response, status, error);
			}
		});
	}
	
	function chkValidation(){
		if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
		if($("#input_companyName").val() == undefined || $("#input_companyName").val() == ""){
			Common.Warning("<spring:message code='Cache.msg_EnterCompName'/>", "Warning", function(){ $("#input_companyName").focus(); }); // 회사명을 입력하세요.
			return false;
		}else if($("#input_repName").val() == undefined || $("#input_repName").val() == ""){
			Common.Warning("<spring:message code='Cache.msg_EnterRepName'/>", "Warning", function(){ $("#input_repName").focus(); }); // 대표자명을 입력하세요.
			return false;
		}else if($("#input_repNumber").val() == undefined || $("#input_repNumber").val() == ""){
			Common.Warning("<spring:message code='Cache.msg_EnterRepNumber'/>", "Warning", function(){ $("#input_repNumber").focus(); }); // 대표번호를 입력하세요.
			return false;
		}else if($("#input_corpNumber").val() == undefined || $("#input_corpNumber").val() == ""){
			Common.Warning("<spring:message code='Cache.msg_EnterCorpNumber'/>", "Warning", function(){ $("#input_corpNumber").focus(); }); // 법인번호를 입력하세요.
			return false;
		}else if($("#input_comAddress").val() == undefined || $("#input_comAddress").val() == ""){
			Common.Warning("<spring:message code='Cache.msg_EnterComAddress'/>", "Warning", function(){ $("#input_comAddress").focus(); }); // 회사주소를 입력하세요.
			return false;
		}else if($("#input_adminName").val() == undefined || $("#input_adminName").val() == ""){
			Common.Warning("<spring:message code='Cache.msg_EnterChargeName'/>", "Warning", function(){ $("#input_adminName").focus(); });
			return false;
		}else if($("#input_adminContact").val() == undefined || $("#input_adminContact").val() == ""){
			Common.Warning("<spring:message code='Cache.msg_EnterChargeContact'/>", "Warning", function(){ $("#input_adminContact").focus(); });
			return false;
		}else if($("#select_useGoogleSchedule").val() == "Y"){
			if($("#input_googleClientID").val() == undefined || $("#input_googleClientID").val() == ""){
				Common.Warning("<spring:message code='Cache.msg_EnterGoogleClientID'/>", "Warning", function(){ $("#input_googleClientID").focus();	}); // 구글 Client ID를 입력하세요.
				return false;
			}else if($("#input_googleClientKey").val() == undefined || $("#input_googleClientKey").val() == ""){
				Common.Warning("<spring:message code='Cache.msg_EnterGoogleClientKey'/>", "Warning", function(){ $("#input_googleClientKey").focus(); }); // 구글 Client Key를 입력하세요.
				return false;
			}else if($("#input_googleRedirectURL").val() == undefined || $("#input_googleRedirectURL").val() == ""){
				Common.Warning("<spring:message code='Cache.msg_GoogleRedirectURL'/>", "Warning", function(){ $("#input_googleRedirectURL").focus(); }); // 구글 Redirect URL을 입력하세요.
				return false;
			}else{
				return true;
			}
		}else{
			return true;
		}
	}
	
	function clickTab(pObj){
		$(".AXTab").attr("class", "AXTab");
		$(pObj).addClass("AXTab on");

		var str = $(pObj).attr("value");
		
		$("#info").hide();
		$("#design").hide();
		
		$("#" + str).show();
	}
	
	function addRow(){
		var bannerRowLen = $("#tbl_potalBanner .tr_potalBanner").length;
		
		if(bannerRowLen == 3){
			Common.Inform("<spring:message code='Cache.msg_canRegisterPortalBanners'/>"); // 포탈 배너는 3개까지 등록 가능합니다.
		}else{
			bannerRowCnt += 1;
			
			var cloneTr = $(".tr_portalBanner_hidden").clone();
			var portalBanner = "portalBanner_" + bannerRowCnt;
			
			cloneTr.prop("class", "tr_" + portalBanner);
			cloneTr.eq(0).prop("class", "tr_potalBanner tr_" + portalBanner);
			cloneTr.find("#input_portalBanner_hidden").prop("id", "input_" + portalBanner);
			cloneTr.find("#input_portalBanner_link").prop("id", "input_portalBanner_link_" + bannerRowCnt);
			cloneTr.find("input[type=file]").prop("id", "input_file_" + portalBanner).addClass("file_portal_banner");
			cloneTr.find("input[type=hidden]").prop("id", "hid_" + portalBanner).addClass("hid_portalBannerPath");
			cloneTr.find(".caution").prop("id", "span_" + portalBanner);
			cloneTr.find(".l_img3").prop("id", "p_" + portalBanner);
			cloneTr.find("img").prop("id", "img_"+portalBanner);
			
			cloneTr.find("input[type=file]").attr("onchange", "fileUpload('" + portalBanner + "', this);");
			cloneTr.find(".btn_file").attr("onclick", "$('#input_file_" + portalBanner + "').click();");
			cloneTr.find("#input_" + portalBanner).val("");
			cloneTr.find("#input_file_" + portalBanner).val("");
			cloneTr.find("img").attr("src", "");
			
			cloneTr.appendTo("#tbl_potalBanner tbody");
			
			$(".tr_" + portalBanner).show();
			
			$("#input_file_" + portalBanner).on("change", function(){
				var file = $(this)[0].files[0];
				
				if(file.name != ""){
					var pathPoint = file.name.lastIndexOf('.');
					var filePoint = file.name.substring(pathPoint + 1, file.name.length);
					var fileType = filePoint.toLowerCase();
					
					if(file.size > 1000000){
						Common.Warning("<spring:message code='Cache.msg_only1MB'/>"); // 1MB 이하만 가능합니다
						$(this).val("");
						$("#input_" + portalBanner).val("");
						$("#img_" + portalBanner).attr("src", "");
					}else if(fileType != "jpg" && fileType != "jpeg"){
						Common.Warning("<spring:message code='Cache.msg_onlyJpg'/>"); // jpg만 가능합니다.
						$(this).val("");
						$("#input_" + portalBanner).val("");
						$("#img_" + portalBanner).attr("src", "");
					}else{
						$("#hid_" + portalBanner).val("");
						$("#p_" + portalBanner).show();
						$("#span_" + portalBanner).hide();
						
						if(typeof(file) == "undefined") $("#input_" + portalBanner).val("");
						else $("#input_" + portalBanner).val(file.name);
					    readURL(portalBanner, this);
					}
				}
			});
		}
	}
	
	function delRow(){
		var bannerRowLen = $("#tbl_potalBanner .tr_potalBanner").length;
		
		if(bannerRowLen == 0){
			return false;
		}else{
			var checkedList = $("#tbl_potalBanner .chk_portalBanner:checked");
			
			$(checkedList).each(function(idx, item){
				var itemClass = $(item).closest("tr").prop("class");
				
				if($(item).prop("id") != "chk_all"
					&& itemClass != "tr_portalBanner_hidden"){
					$("." + itemClass.split(" ")[1]).remove();
				}
			});
		}
	}

	function readURL(mode, input) {
		var imgObj = null;
		
		if(mode == "PC") {
			imgObj = $("#img_pcLogo");
		}else if(mode == "Mobile"){
			imgObj = $("#img_mobileLogo");
		}else{
			imgObj = $("#img_" + mode);
		}
		
		if (input.files && input.files[0]) {
			var reader = new FileReader(); //파일을 읽기 위한 FileReader객체 생성
			reader.onload = function (e) {
				//파일 읽어들이기를 성공했을때 호출되는 이벤트 핸들러
		        imgObj.attr("src", e.target.result);
		        //이미지 Tag의 SRC속성에 읽어들인 File내용을 지정
		        //(아래 코드에서 읽어들인 dataURL형식)
		    }                   
		    reader.readAsDataURL(input.files[0]);
		    //File내용을 읽어 dataURL형식의 문자열로 저장
		}
	}
	
	function fileUpload(mode, obj) {
		var fileObj = null;
		var files = $(obj)[0].files;
		var fileName = files[0].name;
		var fileSize = files[0].size;
		var imgObj = null;
		
		if(mode == "PC") {
			imgObj = $("#img_pcLogo");
		}else if(mode == "Mobile"){
			imgObj = $("#img_mobileLogo");
		}else{
			imgObj = $("#img_" + mode);
		}
		
		// 선택파일의 경로를 분리하여 확장자를 구합니다.
		if(fileName != ""){
			var pathPoint = fileName.lastIndexOf('.');
			var filePoint = fileName.substring(pathPoint + 1, fileName.length);
			var fileType = filePoint.toLowerCase();
			
			if(fileSize > 1000000){
				return false;
			}else if((mode == "PC" || mode == "Mobile") && fileType == "png"){
				return true;
			}else if(mode != "PC" && mode != "Mobile" && (fileType == "jpg" || fileType == "jpeg")){
				return true;
			}else{
				return false;
			}
		}else{
			return false;
		}
	}
	
	function deleteLogo(mode) {
		if (mode === "PC") {
			$("#img_pcLogo").attr("src", "");
			$("#input_pcLogo").val("");
			$("#input_pcFileText").val("");
			$("#hid_pcLogoPath").val("");
			$("#p_pcLogo").hide();
			$("#span_pcLogo").show();
			$("#delBtn_pcLogo").hide();
		} else if (mode === "Mobile") {
			$("#img_mobileLogo").attr("src", "");
			$("#input_mobileLogo").val("");
			$("#input_mobileFileText").val("");
			$("#hid_mobileLogoPath").val("");
			$("#p_mobileLogo").hide();
			$("#span_mobileLogo").show();
			$("#delBtn_mobileLogo").hide();
		}
	}
</script>