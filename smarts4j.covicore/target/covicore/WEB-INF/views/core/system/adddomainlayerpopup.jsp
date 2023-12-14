<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>

<style>
	.AXgridPageBody { display: none !important; }
</style>

<div class="moduleLCpop">
	<form id="addDomain" name="addDomain">
		<div class="AXTabsLarge" style="margin-bottom: 10px">
			<div class="AXTabsTray">
				<a onclick="clickTab(this);" class="AXTab on" value="divDomainBasicInfo"><spring:message code='Cache.lbl_apv_baseInfo'/></a><!--기본정보-->
				<a onclick="clickTab(this);" class="AXTab" value="divDomainLicenseInfo"><spring:message code='Cache.lbl_licenseInfo'/></a><!--라이선스 정보-->
			</div>
			<!-- 기본정보 시작-->
			<div id="divDomainBasicInfo" class="mlc_domain">
				<table class="AXFormTable">
					<colgroup>
						<col width="15%"/>
						<col width="35%"/>
						<col width="15%"/>
						<col width="35%"/>
					</colgroup>
					<tbody>
						<tr>
							<th><spring:message code="Cache.lbl_Domain"/>(<spring:message code="Cache.lbl_service"/>)<font color="red">*</font></th>
							<td>
								<input type="text" id="domainURL" name="<spring:message code="Cache.lbl_Domain"/>" style="width: 96%;" class="AXInput HtmlCheckXSS ScriptCheckXSS"  onkeyup="return keyUpAlphabatNum(this)"/>
							</td>
							<th><spring:message code="Cache.lbl_DN_Code"/><font color="red">*</font></th>
							<td>
								<input type="text" id="domainCode"  name="<spring:message code="Cache.lbl_DN_Code"/>" style="width: 96%;" class="AXInput HtmlCheckXSS ScriptCheckXSS" onkeyup="return keyUpAlphabatNum(this)"/>
							</td>
						</tr>
						<tr>
							<th><spring:message code="Cache.lbl_Domain"/>(Mail)<font color="red">*</font></th>
							<td>
								<input type="text" id="mailDomain" style="width: 98%;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
							</td>
							<th><spring:message code="Cache.lbl_IsMail"/><font color="red">*</font></th>
							<td>
								<input type='text' kind='switch' on_value='Y' off_value='N' id='isCPMail' style='width:50px;height:21px;border:0px none;' value='Y' />
							</td>
						</tr>
						<tr>
							<th><spring:message code="Cache.lbl_EntireMailID"/><font color="red">*</font></th>
							<td>
								<input type="text" id="EntireMailID" style="width: 98%;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
							</td>
							<th></th>
							<td></td>
						</tr>
						<tr>
							<th><spring:message code="Cache.lbl_SubDomain"/></th> <!-- 서브 도메인 -->
							<td>
								<input type="text" id="subDomain" style="width: 98%;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
							</td>
							<th><spring:message code="Cache.lbl_OrgSyncType"/><font color="red">*</font></th>
							<td>
								<select id="selOrgSyncType" class="AXSelect">
									<option value="" selected><spring:message code="Cache.lbl_Select" /></option>
									<option value="AUTO"><spring:message code="Cache.lbl_HRSync" /></option>
									<option value="MANUAL"><spring:message code="Cache.lbl_NoHRSync" /></option>
								</select>
							</td>
						</tr>
						<tr>
							<th><spring:message code="Cache.lbl_ServicePeriod"/><font color="red">*</font></th>
							<td>
								<input type="text" id="serviceStart" style="width: 85px;" class="AXInput" /> ~ 
								<input type="text" kind="twindate" date_startTargetID="serviceStart" id="serviceEnd" name="<spring:message code="Cache.lbl_ServicePeriod"/>" style="width: 100px;" class="AXInput av-required"/>
							</td>
							<th></th>
							<td></td>
						</tr>
						<tr>
							<th><spring:message code="Cache.lbl_DomainType"/><font color="red">*</font></th> <!-- 도메인 유형 -->
							<td>
								<select id="selDomainType" class="AXSelect">
								</select>
							</td>
							<th><spring:message code="Cache.lbl_CompanyName"/><font color="red">*</font></th> <!-- 회사명 -->
							<td>
								<input type="text" id="domainName" name="<spring:message code='Cache.lbl_CompanyName'/>" style="width: 70%;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"> <!-- 회사명 -->
								<input type="button" value="<spring:message code='Cache.lbl__DicModify'/>" onclick="dictionaryLayerPopup('true', 'domainName');" class="AXButton"> <!-- 다국어 -->
							</td>
						</tr>
						<tr>
							<th><spring:message code="Cache.lbl_RepName"/><font class="isSaas_required_point" color="red">*</font></th>
							<td>
								<input type="text" id="repName" name="<spring:message code="Cache.lbl_RepName"/>" style="width: 96%;" class="AXInput HtmlCheckXSS ScriptCheckXSS"/>
							</td>
							<th><spring:message code="Cache.lbl_ComAddress"/><font class="isSaas_required_point" color="red">*</font></th>
							<td>
								<input type="text" id="comAddress" style="width: 98%;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
							</td>
						</tr>
						<tr>
							<th><spring:message code="Cache.lbl_CorpNumber"/><font class="isSaas_required_point" color="red">*</font></th> <!-- 법인번호 -->
							<td>
								<input type="text" id="corpNumber" style="width: 96%;" class="AXInput HtmlCheckXSS ScriptCheckXSS"/>
							</td>
							<th><spring:message code="Cache.lbl_RepNumber"/><font class="isSaas_required_point" color="red">*</font></th>
							<td>
								<input type="text" id="repNumber" name="<spring:message code="Cache.lbl_RepNumber"/>" style="width: 96%;" class="AXInput HtmlCheckXSS ScriptCheckXSS"/>
							</td>
						</tr>
						<tr>
							<th><spring:message code="Cache.lbl_apv_AdminName"/><font class="isSaas_required_point" color="red">*</font></th>
							<td>
								<input type="text" id="adminName" name="<spring:message code="Cache.lbl_apv_AdminName"/>" style="width: 96%;" class="AXInput HtmlCheckXSS ScriptCheckXSS"/>
							</td>
							<th><spring:message code="Cache.lbl_ChargePersonContact"/><font class="isSaas_required_point" color="red">*</font></th>
							<td>
								<input type="text" id="adminContact" name="<spring:message code="Cache.lbl_ChargePersonContact"/>" style="width: 96%;" class="AXInput HtmlCheckXSS ScriptCheckXSS"/>
							</td>
						</tr>
						<tr>
							<th><spring:message code="Cache.lbl_apv_AdminID"/><font color="red">*</font></th>
							<td>
								<input type="text" id="adminID" name="<spring:message code="Cache.lbl_apv_AdminID"/>" style="width: 96%;" class="AXInput HtmlCheckXSS ScriptCheckXSS"/>
							</td>
							<th><spring:message code="Cache.lbl_AdminEmail"/><font color="red">*</font></th>
							<td>
								<input type="text" id="adminEmail" name="<spring:message code="Cache.lbl_AdminEmail"/>" style="width: 96%;" class="AXInput HtmlCheckXSS ScriptCheckXSS"/>
							</td>
						</tr>
						<tr>
							<th><spring:message code="Cache.lbl_AttachLogo"/></th>
							<td>
								<div>
									<span><spring:message code="Cache.lbl_PCLogo"/></span><br/>
									<input type="text" value="" id="pcLogoFileText" placeholder="<spring:message code='Cache.lbl_vacationMsg30'/>" style="width: 70%;" readonly> <!-- 선택된 파일 없음 -->
									<a href="#" class="AXButton btn_file" onclick="$('#pcLogoFile').click();"><spring:message code="Cache.lbl_SelectFile"/></a> &nbsp;&nbsp; <!-- 파일선택 -->
									<div style="width:0px; height:0px; overflow:hidden;">
										<input type="file" id="pcLogoFile" onchange="fileUpload('PC', this);">
									</div>
								</div>
								<div>
									<span><spring:message code="Cache.lbl_MobileLogo"/></span><br/>
									<input type="text" value="" id="mobileLogoFileText" placeholder="<spring:message code='Cache.lbl_vacationMsg30'/>" style="width: 70%;" readonly> <!-- 선택된 파일 없음 -->
									<a href="#" class="AXButton btn_file" onclick="$('#mobileLogoFile').click();"><spring:message code="Cache.lbl_SelectFile"/></a> &nbsp;&nbsp; <!-- 파일선택 -->
									<div style="width:0px; height:0px; overflow:hidden;">
										<input type="file" id="mobileLogoFile" onchange="fileUpload('Mobile', this);">
									</div>
									<p class="explain"><span class="star">*</span> 1MB 이하, png 확장자</p>
								</div>
							</td>
							<th><spring:message code="Cache.lbl_PortalBanner"/></th>
							<td>
								<div>
									<input type="text" value="" id="portalBannerFileText" placeholder="<spring:message code='Cache.lbl_vacationMsg30'/>" style="width: 70%;" readonly> <!-- 선택된 파일 없음 -->
									<a href="#" class="AXButton btn_file" onclick="$('#portalBannerFile').click();"><spring:message code="Cache.lbl_SelectFile"/></a> &nbsp;&nbsp; <!-- 파일선택 -->
									<div style="width:0px; height:0px; overflow:hidden;">
										<input type="file" id="portalBannerFile" name="portalBannerFile" onchange="fileUpload('PortalBanner', this);" multiple>
									</div>
									<p class="explain"><span class="star">*</span> 1MB 이하, jpg 확장자</p><br/>
									<p class="explain"><span class="star">*</span> 3개까지 등록가능</p>
								</div>
							</td>
						</tr>
						<tr>
							<th><spring:message code="Cache.lbl_GoogleClientID"/></th>
							<td colspan="3">
								<input type="text" id="googleClientID" name="<spring:message code="Cache.lbl_GoogleClientID"/>" style="width: 96%;" class="AXInput HtmlCheckXSS ScriptCheckXSS"/>
							</td>
						</tr>
						<tr>
							<th><spring:message code="Cache.lbl_GoogleClientKey"/></th>
							<td>
								<input type="text" id="googleClientKey" name="<spring:message code="Cache.lbl_GoogleClientKey"/>" style="width: 96%;" class="AXInput HtmlCheckXSS ScriptCheckXSS"/>
							</td>
							<th><spring:message code="Cache.lbl_GoogleRedirectURL"/></th>
							<td>
								<input type="text" id="googleRedirectURL" name="<spring:message code="Cache.lbl_GoogleRedirectURL"/>" style="width: 96%;" class="AXInput HtmlCheckXSS ScriptCheckXSS"/>
							</td>
						</tr>
					</tbody>
				</table>
				
				<div id="divBasicLicense" class="mlc_basicLC" style="padding-top:10px">
					<h3 class="cycleTitle">
						<spring:message code="Cache.lbl_baseLicense"/> <!-- 기본 라이선스 -->
						<input type="button" id="btnBasicLicAdd" class="AXButton BtnAdd" value="<spring:message code="Cache.lbl_Add"/>"/> <!-- 추가 -->
						<input type="button" id="btnBasicLicDel" class="AXButton BtnDelete" value="<spring:message code='Cache.btn_delete'/>"   /> 	<!-- 삭제 -->
					</h3>
					<div id="divBasicLicGrid"></div>
				</div>
				<div id="divOptLicense" class="mlc_additionLC" style="padding-top:10px">
					<h3 class="cycleTitle">
						<spring:message code="Cache.lbl_additionalLicense"/> <!-- 부가 라이선스 -->
						<input type="button" id="btnOptLicAdd" class="AXButton BtnAdd" value="<spring:message code="Cache.lbl_Add"/>"/> <!-- 추가 -->
						<input type="button" id="btnOptLicDel" class="AXButton BtnDelete" value="<spring:message code='Cache.btn_delete'/>" /> 	<!-- 삭제 -->
					</h3>
					<div id="optLicGrid"></div>
				</div>
			</div>
			<!-- 기본정보 끝 -->
			
			<!-- 라이선스 정보 시작  -->
			<div id="divDomainLicenseInfo" class="mlc_license" style="display:none;">
				<table class="AXFormTable">
					<colgroup>
						<col width="15%"/>
						<col width="85%"/>
					</colgroup>
					<tbody>
						<tr>
							<th>lic.domain</th>
							<td>
								<input type="text" id="licDomain" style="width: 96%;" class="AXInput HtmlCheckXSS ScriptCheckXSS" />
							</td>
						</tr>
						<tr>
							<th>lic.date</th>
							<td>
								<input type="text" id="licExpireDate" style="width: 96%;" class="AXInput HtmlCheckXSS ScriptCheckXSS" />
						
							</td>
						</tr>
						<tr id="trProjectMsg" style="display:none;">
							<td colspan="2">
								<span class="caution"><spring:message code="Cache.msg_caution_licenseManage"/></p> <!-- SaaS 프로젝트 아닌 경우에는 최상위 도메인에서 라이선스 관리 바랍니다. -->
							</td>
						</tr>
					</tbody>
				</table>
				<div class="mlc_licenseDetail" style="padding-top:10px">
					<div id="licInfoGrid"></div>
				</div>
			</div>
			<!-- 라이선스 정보 끝  -->
		</div>
		<div align="center">
			<input type="button" id="btnAdd" value="<spring:message code="Cache.btn_Add"/>" onclick="addSubmit();" style="display: none" class="AXButton red"/>
			<input type="button" id="btnModify" value="<spring:message code="Cache.btn_Edit"/>" onclick="modifySubmit();" style="display: none" class="AXButton red"/>
			<%-- <input type="button" id="btnChkLogin" value="<spring:message code="Cache.btn_LoginConfirm"/>" onclick="chkLogin();" style="display: none" class="AXButton"/> --%>
			<input type="button" id="btnSendMail" value="<spring:message code="Cache.btn_SendMail"/>" onclick="sendMail();" style="display: none;" class="AXButton"/>
			<input type="button" value="<spring:message code="Cache.btn_Close"/>" onclick="closeLayer();" class="AXButton"/>
			<input type="button" id="btnRemoveLicenseCache" class="AXButton BtnDelete" value="<spring:message code="Cache.lbl_RemoveLicenseCache"/>" style="display: none;" onclick="removeLicenseCache();"/> <!-- 라이선스 인증 캐쉬 제거 -->
		</div>
		<input type="hidden" id="hidDomainCode" value="" />
		<input type="hidden" id="hidDomainName" value="" />
	</form>
</div>
<script>
	var mode = CFN_GetQueryString("mode");
	var domainID = CFN_GetQueryString("domainID");
	var langCode = Common.getSession("lang");
	var isSaaS = Common.getGlobalProperties("isSaaS");
	
	var basicLicGrid = new coviGrid();
	var optLicGrid = new coviGrid();
	var licInfoGrid = new coviGrid();
	
	//ready
	initContent();
	
	function initContent(){ 
		setControls();
		setLicGrid();
		
		if(mode=="add"){
			$("#btnAdd").show();
		}else if(mode=="modify"){
			$("#btnModify").show();
			$("#btnChkLogin").show();
			$("#btnSendMail").show();
			$("#domainCode").attr("readonly", true);
			$("#mailDomain").attr("readonly", true);
			$("#EntireMailID").attr("readonly", true);
			setSelectData();
			
			if(isSaaS != "Y"){
				$(".isSaas_required_point").css("display","none");
			}
		}
		
		$("#pcLogoFile").on("change", function(){
			var file = $(this)[0].files[0];
			
			if(file.name != ""){
				var pathPoint = file.name.lastIndexOf('.');
				var filePoint = file.name.substring(pathPoint + 1, file.name.length);
				var fileType = filePoint.toLowerCase();
				
				if(file.size > 1000000){
					Common.Warning("<spring:message code='Cache.msg_only1MB'/>"); // 1MB 이하만 가능합니다
					$(this).val("");
					$("#pcLogoFileText").val("");
				}else if(fileType != "png"){
					Common.Warning("<spring:message code='Cache.msg_onlyPng'/>"); // png만 가능합니다.
					$(this).val("");
					$("#pcLogoFileText").val("");
				}else{
					if(typeof(file) == "undefined") $("#pcLogoFileText").val("");
					else $("#pcLogoFileText").val(file.name);
				}
			}
		});
		
		$("#mobileLogoFile").on("change", function(){
			var file = $(this)[0].files[0];
			
			if(file.name != ""){
				var pathPoint = file.name.lastIndexOf('.');
				var filePoint = file.name.substring(pathPoint + 1, file.name.length);
				var fileType = filePoint.toLowerCase();
				
				if(file.size > 1000000){
					Common.Warning("<spring:message code='Cache.msg_only1MB'/>"); // 1MB 이하만 가능합니다
					$(this).val("");
					$("#mobileLogoFileText").val("");
				}else if(fileType != "png"){
					Common.Warning("<spring:message code='Cache.msg_onlyPng'/>"); // png만 가능합니다.
					$(this).val("");
					$("#mobileLogoFileText").val("");
				}else{
					if(typeof(file) == "undefined") $("#mobileLogoFileText").val("");
					else $("#mobileLogoFileText").val(file.name);
				}
			}
		});
		
		$("#portalBannerFile").on("change", function(){
			var files = $(this)[0].files;
			var fileName = "";

			$(files).each(function(idx, file){
				if(file.name != ""){
					var pathPoint = file.name.lastIndexOf('.');
					var filePoint = file.name.substring(pathPoint + 1, file.name.length);
					var fileType = filePoint.toLowerCase();
					
					if(file.size > 1000000){
						Common.Warning("<spring:message code='Cache.msg_only1MB'/>"); // 1MB 이하만 가능합니다
						$("#portalBannerFile").val("");
						$("#portalBannerFileText").val("");
						return false;
					}else if(fileType != "jpg" && fileType != "jpeg"){
						Common.Warning("<spring:message code='Cache.msg_onlyJpg'/>"); // jpg만 가능합니다.
						$("#portalBannerFile").val("");
						$("#portalBannerFileText").val("");
						return false;
					}else{
						fileName += file.name + ", ";
					}
				}
			});
			
			if(files.length == 0) $("#portalBannerFileText").val("");
			else if($(this).val() != "" && fileName != "") $("#portalBannerFileText").val(fileName.substring(0, fileName.length-2));
		});
	};
	
	function setControls(){
		var initInfos = [
			         		{
			         		target : 'selDomainType',
			         		codeGroup : 'DomainType',
			         		defaultVal : '',
			         		width : '100',
			         		onchange : ''
			         		}];
		         		
		coviCtrl.renderAjaxSelect(initInfos, '', 'ko');
		if(isSaaS != "Y" && domainID != 0){
			$("#trProjectMsg").show();
			$("#licDomain").prop("readonly", true)
			$("#licUserCount").prop("readonly", true)
			$("#licExpireDate").prop("readonly", true)
			$("#lieExUserCount").prop("readonly", true)
			$("#licEx1Date").prop("readonly", true)
		}
	}
	
	// 도메인 데이터 추가
	function addSubmit(){
		if(!chkValidation()){
			return false;
		}
		
		setFullDisplayName();
		
		var formData = new FormData();
		var now = new Date();
		
		formData.append("DomainCode", $("#domainCode").val());
		formData.append("DomainURL", $("#domainURL").val());
		formData.append("DomainName", $("#domainName").val());
		formData.append("DomainType", $("#selDomainType option:selected").val());
		formData.append("MailDomain", $("#mailDomain").val());
		formData.append("IsCPMail", $("#isCPMail").val());
		formData.append("EntireMailID", $("#EntireMailID").val());
		formData.append("MulitiDomainName", $("#hidDomainName").val());
		formData.append("ServiceUser", "0");
		formData.append("ServiceStart", $("#serviceStart").val());
		formData.append("ServiceEnd", $("#serviceEnd").val());
		formData.append("SubDomain", $("#subDomain").val());
		formData.append("OrgSyncType", $("#selOrgSyncType option:selected").val());
		formData.append("DomainCorpTel", $("#corpNumber").val());
		formData.append("CorpNumber", $("#corpNumber").val());
		formData.append("DomainRepName", $("#repName").val());
		formData.append("DomainRepTel", $("#repNumber").val());
		formData.append("DomainAddress", $("#comAddress").val());
		formData.append("ChargerName", $("#adminName").val());
		formData.append("ChargerTel", $("#adminContact").val());
		formData.append("ChargerID", $("#adminID").val());
		formData.append("ChargerEmail", $("#adminEmail").val());
		formData.append("PCLogoFile", $("#pcLogoFile")[0].files[0]);
		formData.append("MobileLogoFile", $("#mobileLogoFile")[0].files[0]);
		formData.append("GoogleClientID", $("#googleClientID").val());
		formData.append("GoogleClientKey", $("#googleClientKey").val());
		formData.append("GoogleRedirectURL", $("#googleRedirectURL").val());
		formData.append("LicDomain", $("#licDomain").val());
		formData.append("LicExpireDate", $("#licExpireDate").val());
		/* formData.append("LicUserCount", $("#licUserCount").val());
		formData.append("LieExUserCount", $("#lieExUserCount").val());
		formData.append("LicEx1Date", $("#licEx1Date").val()); */
		formData.append("LicInfoList", setLicParams());
		formData.append("RegistDate", XFN_getDateTimeString("yyyy-MM-dd HH:mm:ss", now));
		
		var fileList = $("#portalBannerFile")[0].files;
		
		for(var i = 0; i < fileList.length; i++){
			formData.append("PortalBannerFile", fileList[i]);
		}
		
		
		$.ajax({
			type: "POST",
			data: formData,
			processData: false,
			contentType: false,
			url: "/covicore/domain/add.do",
			success: function(data){
				if(data.status == "SUCCESS"){
					if(data.result > 0){
						Common.Inform("<spring:message code='Cache.msg_Added'/>", "Information", function(){ // 추가 되었습니다
							closeLayer();
							parent.refreshGrid();;
						});
					}else if(data.result == -1){
						Common.Warning("이미 존재하는 도메인 코드입니다.", "Warning", function(){
							$("#domainCode").focus();	
							$("#domainCode").select();	
						})
					}
				}else{
					Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생했습니다.
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/covicore/domain/add.do", response, status, error);
			}
		});
	}
	
	// 도메인 데이터 수정
	function modifySubmit(){
		if(!chkValidation()){
			return false;
		}

		setFullDisplayName();

		var formData = new FormData();
		
		formData.append("DomainID", domainID);
		formData.append("DomainCode", $("#domainCode").val());
		formData.append("DomainURL", $("#domainURL").val());
		formData.append("DomainName", $("#domainName").val());
		formData.append("DomainType", $("#selDomainType option:selected").val());
		formData.append("MulitiDomainName", $("#hidDomainName").val());
		formData.append("ServiceStart", $("#serviceStart").val());
		formData.append("ServiceEnd", $("#serviceEnd").val());
		formData.append("SubDomain", $("#subDomain").val());
		formData.append("OrgSyncType", $("#selOrgSyncType option:selected").val());
		formData.append("DomainCorpTel", $("#corpNumber").val());
		formData.append("DomainRepName", $("#repName").val());
		formData.append("DomainRepTel", $("#repNumber").val());
		formData.append("DomainAddress", $("#comAddress").val());
		formData.append("ChargerName", $("#adminName").val());
		formData.append("ChargerTel", $("#adminContact").val());
		formData.append("ChargerID", $("#adminID").val());
		formData.append("ChargerEmail", $("#adminEmail").val());
		formData.append("PCLogoFile", $("#pcLogoFile")[0].files[0]);
		formData.append("MobileLogoFile", $("#mobileLogoFile")[0].files[0]);
		formData.append("GoogleClientID", $("#googleClientID").val());
		formData.append("GoogleClientKey", $("#googleClientKey").val());
		formData.append("GoogleRedirectURL", $("#googleRedirectURL").val());
		formData.append("LicDomain", $("#licDomain").val());
		formData.append("LicExpireDate", $("#licExpireDate").val());
		/* formData.append("LicUserCount", $("#licUserCount").val());
		formData.append("LieExUserCount", $("#lieExUserCount").val());
		formData.append("LicEx1Date", $("#licEx1Date").val()); */
		formData.append("LicInfoList", setLicParams());
		
		var fileList = $("#portalBannerFile")[0].files;
		
		for(var i = 0; i < fileList.length; i++){
			formData.append("PortalBannerFile", fileList[i]);
		}
		
		$.ajax({
			type: "POST",
			data: formData,
			processData: false,
			contentType: false,
			url: "/covicore/domain/modify.do",
			success: function(data){
				if(data.status == "SUCCESS"){
					Common.Inform("<spring:message code='Cache.msg_Edited'/>", "Information", function(){ // 수정되었습니다.
						closeLayer();
						parent.refreshGrid();
					});
				}else{
					Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생했습니다.
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/covicore/domain/modify.do", response, status, error);
			}
		});
	}
	
	// 수정 레이어팝업에서 보일 데이터 바인드
	function setSelectData(){
		$.ajax({
			type: "POST",
			data: {
				"DomainID" : domainID
			},
			async: false,
			url: "/covicore/domain/get.do",
			success: function(data){
				var serviceStartDate = data.list[0].ServiceStart.split(' ')[0];
				var serviceEndDate = data.list[0].ServiceEnd.split(' ')[0];
				
				$("#hidDomainCode").val(data.list[0].DomainCode);
				$("#domainURL").val(data.list[0].DomainURL);
				$("#mailDomain").val(data.list[0].MailDomain);
				$("#isCPMail").val(data.list[0].IsCPMail);
				$("#EntireMailID").val(data.list[0].EntireMailID);
				if(!data.list[0].EntireMailID)
					$("#EntireMailID").val(data.list[0].DomainCode);
				$("#domainCode").val(data.list[0].DomainCode);
				$("#domainName").val(data.list[0].DisplayName);
				$("#selDomainType").val(data.list[0].DomainType);
				$("#hidDomainName").val(data.list[0].MultiDisplayName);
				$("#serviceStart").val(serviceStartDate);
				$("#serviceEnd").val(serviceEndDate);
				$("#description").val(data.list[0].Description);
				$("#subDomain").val(data.list[0].SubDomain);
				$("#selOrgSyncType").val(data.list[0].OrgSyncType);
				$("#corpNumber").val(data.list[0].DomainCorpTel);
				$("#repName").val(data.list[0].DomainRepName);
				$("#repNumber").val(data.list[0].DomainRepTel);
				$("#comAddress").val(data.list[0].DomainAddress);
				$("#adminName").val(data.list[0].ChargerName);
				$("#adminContact").val(data.list[0].ChargerTel);
				$("#adminID").val(data.list[0].ChargerID);
				$("#adminEmail").val(data.list[0].ChargerEmail);
				$("#googleClientID").val(data.list[0].GoogleClientID);
				$("#googleClientKey").val(data.list[0].GoogleClientKey);
				$("#googleRedirectURL").val(data.list[0].GoogleRedirectURL);
				
				if(isSaaS == "Y" || domainID == 0){
					$("#licDomain").val(data.list[0].LicDomain);
					$("#licUserCount").val(data.list[0].LicUserCount);
					$("#licExpireDate").val(data.list[0].LicExpireDate);
					$("#lieExUserCount").val(data.list[0].LieExUserCount);
					$("#licEx1Date").val(data.list[0].LicEx1Date);
				}
				
				$("#adminID").prop("readonly", true);
				$("#adminEmail").prop("readonly", true);
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/covicore/domain/get.do", response, status, error);
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
				openerID : 'setDomain'
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
		return $("#hidDomainName").val() == "" ? $("#domainName").val() : $("#hidDomainName").val();
	}
	
	function domainName(data){
		$("#hidDomainName").val(coviDic.convertDic($.parseJSON(data)));
		
		if(document.getElementById("domainName").value == ""){
			document.getElementById("domainName").value = CFN_GetDicInfo($("#hidDomainName").val());
		}
		
		Common.Close("DictionaryPopup");
	}
	
	function setFullDisplayName(){
		  if ($("#hidDomainName").val() == "") {
		        switch (langCode.toUpperCase()) {
		            case "KO": sDictionaryInfo = $("#domainName").val() + ";;;;;;;;;"; break;
		            case "EN": sDictionaryInfo = ";" + $("#domainName").val() + ";;;;;;;;"; break;
		            case "JA": sDictionaryInfo = ";;" + $("#domainName").val() + ";;;;;;;"; break;
		            case "ZH": sDictionaryInfo = ";;;" + $("#domainName").val() + ";;;;;;"; break;
		            case "E1": sDictionaryInfo = ";;;;" + $("#domainName").val() + ";;;;;"; break;
		            case "E2": sDictionaryInfo = ";;;;;" + $("#domainName").val() + ";;;;"; break;
		            case "E3": sDictionaryInfo = ";;;;;;" + $("#domainName").val() + ";;;"; break;
		            case "E4": sDictionaryInfo = ";;;;;;;" + $("#domainName").val() + ";;"; break;
		            case "E5": sDictionaryInfo = ";;;;;;;;" + $("#domainName").val() + ";"; break;
		            case "E6": sDictionaryInfo = ";;;;;;;;;" + $("#domainName").val(); break;
		        }
		        
		        document.getElementById("hidDomainName").value = sDictionaryInfo
		    }
	}

	function chkValidation(){
		if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
		
		// 라이선스별 정식수량 입력값 확인.
		var serviceUserCheck = false;
		var serviceUserObj = $(".AXInput.HtmlCheckXSS.ScriptCheckXSS.inputServiceUser");
		for (var i=0; i < serviceUserObj.length; i++) {
			if (serviceUserObj.eq(i).val() == undefined || serviceUserObj.eq(i).val() == "") {
				Common.Warning("정식 신청수량을 입력하십시오.", "Warning",function(){});
				return false;
			} 
		}
	
		if($("#domainURL").val() == undefined || $("#domainURL").val() == ""){
			Common.Warning("도메인(Service)을 입력하십시오.", "Warning",function(){	$("#domainURL").focus();	});
			return false;
		}else if($("#mailDomain").val() == undefined || $("#mailDomain").val() == ""){
			Common.Warning("도메인(Mail)을 입력하십시오.", "Warning",function(){	$("#mailDomain").focus();	});
			return false;
		}else if($("#EntireMailID").val() == undefined || $("#EntireMailID").val() == ""){
			Common.Warning("전사메일 ID를 입력하십시오.", "Warning",function(){	$("#EntireMailID").focus();	});
			return false;
		}else if($("#domainCode").val() == undefined || $("#domainCode").val() == ""){
			Common.Warning("도메인 코드를 입력하십시오.", "Warning",function(){ 	$("#domainCode").focus();		});
			return false;
		}else if($("#selOrgSyncType").val() == undefined || $("#selOrgSyncType").val() == "") {
			Common.Warning("동기화 타입을 선택하여 주십시오.", "Warning",function(){	$("#selOrgSyncType").focus();	});
			return false;
		}else if($("#serviceStart").val() == undefined || $("#serviceStart").val() == ""){
			Common.Warning("시작일을 입력하십시오.", "Warning",function(){	$("#serviceStart").focus();	});
			return false;
		}else if($("#serviceEnd").val() == undefined || $("#serviceEnd").val() == ""){
			Common.Warning("종료일을 입력하십시오.", "Warning",function(){	$("#serviceEnd").focus();		});
			return false;
		}else if($("#domainName").val() == undefined || $("#domainName").val() == ""){
			Common.Warning("회사명을 입력하십시오.", "Warning",function(){	$("#domainName").focus();	});
			return false;
		}else if(isSaaS != "N" && mode != "add"){
			if($("#repName").val() == undefined || $("#repName").val() == ""){
				Common.Warning("대표자명을 입력하십시오.", "Warning", function(){ $("#repName").focus(); });
				return false;
			}else if($("#comAddress").val() == undefined || $("#comAddress").val() == ""){
				Common.Warning("회사주소를 입력하십시오.", "Warning", function(){ $("#comAddress").focus(); });
				return false;
			}else if(isSaaS != "N" && ($("#corpNumber").val() == undefined || $("#corpNumber").val() == "")){
				Common.Warning("법인번호를 입력하십시오.", "Warning", function(){ $("#corpNumber").focus(); });
				return false;
			}else if($("#repNumber").val() == undefined || $("#repNumber").val() == ""){
				Common.Warning("대표번호를 입력하세요.", "Warning", function(){ $("#repNumber").focus(); });
				return false;
			}else if($("#adminName").val() == undefined || $("#adminName").val() == ""){
				Common.Warning("담당자명을 입력하십시오.", "Warning", function(){ $("#adminName").focus(); });
				return false;
			}else if($("#adminContact").val() == undefined || $("#adminContact").val() == ""){
				Common.Warning("담당자 연락처를 입력하십시오.", "Warning", function(){ $("#adminContact").focus(); });
				return false;
			}else{
				return true;
			}			
		}else if($("#adminID").val() == undefined || $("#adminID").val() == ""){
			Common.Warning("담당자 ID를 입력하십시오.", "Warning", function(){ $("#adminID").focus();	});
			return false;
		}else if($("#adminEmail").val() == undefined || $("#adminEmail").val() == ""){
			Common.Warning("담당자 이메일을 입력하십시오.", "Warning", function(){ $("#adminEmail").focus(); });
			return false;
		}else if(!licValidCheck()){
			return false;
		}else{
			return true;
		}
	}
	
	// 레이어팝업 - 창닫기
	function closeLayer(){
		Common.Close();
	}
	
	//알파벳과 숫자만 입력하도록(아이디 등을 만들때 사용)
	function keyUpAlphabatNum(pObj) {
	    var strValue = pObj.value;
	    var strChangeValue = strValue;
	    var strAllow = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_.-"
	    for (var i = 0; i < pObj.value.length; i++) {
	        if (strAllow.indexOf(pObj.value.substring(i, i + 1)) < 0) {
	            strValue = strValue.replace(pObj.value.substring(i, i + 1), "");
	        }
	    }
	    if (strChangeValue != strValue) $(pObj).val(strValue);
	}
	
	function fileUpload(mode, obj) {
		var fileObj = null;
		var files = $(obj)[0].files;
		var fileName = files[0].name;
		
		if(mode == "PC") {
			fileObj = $("#pcLogoFile");
		}else if(mode == "Mobile"){
			fileObj = $("#mobileLogoFile");
		}else{
			fileObj = $("#portalBannerFile");
		}
		
		if(mode == "PortalBanner" && files.length > 1){
			if(files.length > 3){
				Common.Inform("<spring:message code='Cache.msg_canRegisterPortalBanners'/>"); // 포탈 배너는 3개까지 등록 가능합니다.
				$(fileObj).val("");
				return false;
			}else{
				$(files).each(function(idx, item){
					var pathPoint = item.name.lastIndexOf('.');
					var filePoint = item.name.substring(pathPoint + 1, item.name.length);
					var fileType = filePoint.toLowerCase();
					var fileSize = item.size;
					
					if(fileSize > 1000000){
						return false;
					}else if((mode == "PC" || mode == "Mobile") && fileType == "png"){
						return true;
					}else if(mode != "PC" && mode != "Mobile" && (fileType == "jpg" || fileType == "jpeg")){
						return true;
					}else{
						return false;
					}
				});
			}
		}else{
			if(fileName != ""){
				var pathPoint = fileName.lastIndexOf('.');
				var filePoint = fileName.substring(pathPoint + 1, fileName.length);
				var fileType = filePoint.toLowerCase();
				var fileSize = files[0].size;
				
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
	}
	
	function sendMail(){
		var chargerEmail = $("#adminEmail").val();
		var chargerID = $("#adminID").val();
		var domainName = $("#domainName").val();
		
		if(chargerID == undefined || chargerID == ""){
			Common.Warning("담당자 ID를 입력하십시오.", "Warning", function(){$("#adminID").focus();});
			return false;
		}else if(chargerEmail == undefined || chargerEmail == ""){
			Common.Warning("담당자 이메일을 입력하십시오.", "Warning", function(){$("#adminEmail").focus();});
			return false;
		}else if($("#domainName").val() == undefined || $("#domainName").val() == ""){
			Common.Warning("회사명을 입력하십시오.", "Warning", function(){$("#domainName").focus();});
			return false;
		}
		
		$.ajax({
			type: "POST",
			data: {
				"ChargerID": chargerID,
				"ChargerEmail": chargerEmail,
				"DomainName": domainName
			},
			url: "/covicore/domain/sendMail.do",
			success: function(data){
				if(data.status == "SUCCESS"){
					Common.Inform("<spring:message code='Cache.CPMail_MailHasBeenSent'/>"); // 메일이 발송되었습니다.
				}else{
					Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생했습니다.
				}
			},
			error: function(response, status, error){
			     CFN_ErrorAjax("/covicore/domain/get.do", response, status, error);
			}
		});
	}
	
	// 탭 클릭 이벤트
	function clickTab(pObj){
		var strObjName = $(pObj).attr("value");
		$(".AXTab").attr("class","AXTab");
		$(pObj).addClass("AXTab on");
	
		$("#divDomainBasicInfo").hide();
		$("#divDomainLicenseInfo").hide();
		
		$("#" + strObjName).show();
		
		if(strObjName == "divDomainLicenseInfo" 
			&& (isSaaS == "Y" || domainID == 0)){
			$("#btnRemoveLicenseCache").show();
		}else{
			$("#btnRemoveLicenseCache").hide();
		}
		
		if (strObjName == "divDomainLicenseInfo") {
			setLicInfoGridConfig();
		}
		
		coviInput.init();
	}
	
	function removeLicenseCache(){
		Common.Confirm("<spring:message code='Cache.msg_RemoveLicenseCache'/>" /* 사용자 별 라이선스 인증 캐쉬를 제거합니다.<br>금일 관리자 알림 메일도 재전송하려면 [확인] 아니면 [취소]를 눌러주세요. */
				, "<spring:message code='Cache.lbl_RemoveLicenseCache'/>", function(result){ /* 라이선스 인증 캐쉬 제거 */
			var removeMailCache;
			
			if(result){
				removeMailCache = "Y";
			}else{
				removeMailCache = "N";
			}
			
			$.ajax({
				type: "post"
				, url: "/covicore/license/removeLicenseCache.do"
				, data: {
					"domainID": domainID,
					"removeMailCache":removeMailCache
				}, 
				success: function(data){
					if(data.status == "SUCCESS"){
						Common.Inform("<spring:message code='Cache.msg_50'/>");			//삭제되었습니다.
					}else{
						Common.Warning("<spring:message code='Cache.msg_apv_030'/>");	//오류가 발생헸습니다.
					}
				},
	        	error:function(response, status, error){
	       	     CFN_ErrorAjax("/covicore/license/removeLicenseCache.do", response, status, error);
	       		}	
			});

		});
	}
	
	function chkLogin(){
		// 로그인 창을 띄워도 이미 로그인한 상태라 자동으로 포탈로 이동되기 때문에 구현 불가. 추후 작업 예정
	}

	function setLicGrid(){
		$("#btnBasicLicAdd").on("click", function(){
			openDomainLicPopup("N");
		});
		
		$("#btnOptLicAdd").on("click", function(){
			openDomainLicPopup("Y");
		});
		
		// 삭제버튼 이벤트(기본 라이선스)
		$("#btnBasicLicDel").on("click", function() {
			delLicense("1");
		});
		
		// 삭제버튼 이벤트(부가 라이선스)
		$("#btnOptLicDel").on("click", function() {
			delLicense("2");
		});
		
		setBasicLicGridConfig();
		setOptLicGridConfig();
	}
	
	function delLicense(pLic) {
		let warnMsg = "";
		let pLicSeq = "";
		let checkListGrid;

		if (pLic === "1") { 	// 기본 라이선스 시도.
			checkListGrid = basicLicGrid.getCheckedList(0);
			// 기본 라이선스는 필수로 1개는 이상 존재해야 함.
			if ((basicLicGrid.list.length === checkListGrid.length) || (basicLicGrid.list.length === 1)) {
				Common.Warning("<spring:message code='Cache.msg_haveOneBaseLicense'/>"); 	// 1개 이상의 기본 라이선스가 있어야 합니다.
				return;
			}
		} else if (pLic === "2") { 	// 부가 라이선스
			checkListGrid = optLicGrid.getCheckedList(0);
		}
		
		if (checkListGrid.length > 0) {
			checkListGrid.forEach(function(element) {
				pLicSeq += element.LicSeq+";";
			});
			
			warnMsg = "<spring:message code='Cache.msg_152'/>"; 	// 해당 항목들을 삭제하시겠습니까?
			Common.Confirm(warnMsg, "<spring:message code='Cache.lbl_Confirm'/>", function(result) {
				if (result) {
					$.ajax({
						url : "/covicore/domain/deleteDomainLic.do"
						, type : "POST"
						, data : {"LicSeq" : pLicSeq, "domainID" : domainID}
						, async : false
						, success : function(response) {
							if (response.status === "SUCCESS") {
								if (pLic === "1") {
									setBasicLicGrid(); 	// 기본 라이선스 재조회.
								} else if (pLic === "2") {
									setOptLicGrid();	// 부가 라이선스 재조회.
								}
								Common.Inform("<spring:message code='Cache.msg_50'/>");  	// 삭제되었습니다.
							}
						}
						, error:function(response, status, error) {
				    	     //TODO 추가 오류 처리
				    	     CFN_ErrorAjax("/covicore/domain/deleteDomainLic.do", response, status, error);
				    	}
					});
				}
			});
		} else {
			warnMsg = "<spring:message code='Cache.msg_270'/>"; 	// 삭제할 대상이 없습니다.
			Common.Warning(warnMsg);
		}
	}
	
	function setBasicLicGridConfig(){
		var basicHeader=[
			{key: 'chk', label: 'chk', width: '10', align: 'center', formatter: 'checkbox', sort: false},
			{key:'LicName', label:'<spring:message code="Cache.lbl_license"/>', width:'15', align:'left', sort: false, formatter: function(){ // 라이선스
				var returnObj = $("<div/>")
								.append($("<span/>", {"text": this.item.LicName}))
								.append($("<a/>", {"class": "btn_del", "style": "cursor: pointer;", "onclick": "deleteLicense('" + this.item.IsOpt + "', '" + this.item.LicSeq + "');"}));
				
				return returnObj[0].outerHTML;
			}},
			{key:'Description', label:'<spring:message code="Cache.lbl_licenseDescription"/>', width:'30', align:'left', sort: false}, // 라이선스 설명
			{key:'ServiceUser', label:'<spring:message code="Cache.lbl_formApplyCnt"/>', width:'10', align:'center', sort: false}, // 정식 신청수량
			{key:'ExtraExpiredate', label:'<spring:message code="Cache.lbl_tempDeadline"/>', width:'10', align:'center', sort: false}, // 임시기한
			{key:'ExtraServiceUser', label:'<spring:message code="Cache.lbl_tempCnt"/>', width:'10', align:'center', sort: false} // 임시 신청수량
		];
		
		basicLicGrid.setConfig({
			targetID: "divBasicLicGrid",
			height: "auto",
			listCountMSG: " ",
			paging: false,
			page: {
				paging: false,
				pageSize: 10
			},
			fitToWidth:true,
			colGroup:basicHeader
		});
//		basicLicGrid.setConfig(configObj);
		basicLicGrid._targetID = "divBasicLicGrid";
		setBasicLicGrid();
	}
	
	function setBasicLicGrid(){
		if (mode === "modify") {
			basicLicGrid.bindGrid({
				ajaxUrl: "/covicore/domain/getDomainLicenseList.do",
				ajaxPars: {
					"domainID": domainID,
					"isOpt": "N"
				}
			});
		}
	}
	
	function setOptLicGridConfig(){
		var optHeader=[
			{key: 'chk', label: 'chk', width: '10', align: 'center', formatter: 'checkbox', sort: false},
			{key:'LicName', label:'<spring:message code="Cache.lbl_license"/>', width:'20', align:'left', sort: false, formatter: function(){ // 라이선스
				var returnObj = $("<div/>")
								.append($("<span/>", {"text": this.item.LicName}))
								.append($("<a/>", {"class": "btn_del", "style": "cursor: pointer;", "onclick": "deleteLicense('" + this.item.IsOpt + "', '" + this.item.LicSeq + "');"}));
				
				return returnObj[0].outerHTML;
			}},
			{key:'Description', label:'<spring:message code="Cache.lbl_licenseDescription"/>', width:'30', align:'left', sort: false}, // 라이선스 설명
			{key:'ServiceUser', label:'<spring:message code="Cache.lbl_formApplyCnt"/>', width:'10', align:'center', sort: false}, // 정식 신청수량
			{key:'ExtraExpiredate', label:'<spring:message code="Cache.lbl_tempDeadline"/>', width:'10', align:'center', sort: false}, // 임시기한
			{key:'ExtraServiceUser', label:'<spring:message code="Cache.lbl_tempCnt"/>', width:'10', align:'center', sort: false} // 임시 신청수량
		];
		
		optLicGrid.setConfig({
			targetID: "optLicGrid",
			height: "auto",
			listCountMSG: " ",
			paging: false,
			page: {
				paging: false,
				pageSize: 10
			},
			fitToWidth:true,
			colGroup:optHeader
		});
		
		optLicGrid._targetID = "optLicGrid";
		setOptLicGrid();
	}
	
	function setOptLicGrid(){
		if (mode === "modify") {
			optLicGrid.bindGrid({
				ajaxUrl: "/covicore/domain/getDomainLicenseList.do",
				ajaxPars: {
					"domainID": domainID,
					"isOpt": "Y"
				}
			});
		}
	}
	
	function setLicInfoGridConfig(){
		var licHeader = [
			{key:'LicName', label:'<spring:message code="Cache.lbl_license"/>', width:'50', align:'left', sort: false}, // 라이선스
			{key:'Description', label:'<spring:message code="Cache.lbl_licenseDescription"/>', width:'0', align:'left', sort: false}, // 라이선스 설명
			{key:'ServiceUser', label:'<spring:message code="Cache.lbl_formApplyCnt"/>', width:'30', align:'center', sort: false, formatter: function(){ // 정식 부여 key
				var returnObj = $("<input/>", {"type": "text", "value": this.item.ServiceUser, "class": "AXInput HtmlCheckXSS ScriptCheckXSS inputServiceUser", "style": "width: 88%;"});
				
				return returnObj[0].outerHTML;
			}}, // 정식 신청수량
			{key:'LicUserCount', label:'<spring:message code="Cache.lbl_formalGrantKey"/>', width:'150', align:'center', sort: false, formatter: function(){ // 정식 부여 key
				var returnObj = $("<input/>", {"type": "text", "value": this.item.LicUserCount, "class": "AXInput HtmlCheckXSS ScriptCheckXSS inputLicUser", "style": "width: 88%;"});
				
				return returnObj[0].outerHTML;
			}},
			{key:'ExtraExpiredate', label:'<spring:message code="Cache.lbl_tempDeadline"/>', width:'50', align:'center', sort: false, formatter: function(){ // 정식 부여 key
				var returnObj = $("<input/>", {"type": "text", "value": this.item.ExtraExpiredate, "class": "AXInput HtmlCheckXSS ScriptCheckXSS inputExtraExpiredate", "style": "width: 88%;"});
				
				return returnObj[0].outerHTML;
			}}, // 임시기한
			{key:'LicEx1Date', label:'<spring:message code="Cache.lbl_tempTimeGrantKey"/>', width:'150', align:'center', sort: false, formatter: function(){ // 임시기한 부여 key
				var returnObj = $("<input/>", {"type": "text", "value": this.item.LicEx1Date, "class": "AXInput HtmlCheckXSS ScriptCheckXSS inputLicExDate", "style": "width: 88%;"});
				
				return returnObj[0].outerHTML;
			}},
			{key:'ExtraServiceUser', label:'<spring:message code="Cache.lbl_tempCnt"/>', width:'30', align:'center', sort: false, formatter: function(){ // 정식 부여 key
				var returnObj = $("<input/>", {"type": "text", "value": this.item.ExtraServiceUser, "class": "AXInput HtmlCheckXSS ScriptCheckXSS inputExtraServiceUser", "style": "width: 88%;"});
				
				return returnObj[0].outerHTML;
			}}, // 임시수량
			{key:'LicExUserCount', label:'<spring:message code="Cache.lbl_tempCntGrantKey"/>', width:'150', align:'center', sort: false, formatter: function(){ // 임시수량 부여 key
				var returnObj = $("<input/>", {"type": "text", "value": this.item.LicExUserCount, "class": "AXInput HtmlCheckXSS ScriptCheckXSS inputLicExUser", "style": "width: 88%;"});
				
				return returnObj[0].outerHTML;
			}},
			{key:'LicUsingCnt', label:'<spring:message code="Cache.lbl_UsedAmount"/>', width:'30', align:'center', sort: false} // 사용수량
		];
		
		licInfoGrid.setConfig({
			targetID: "licInfoGrid",
			height: "auto",
			listCountMSG: " ",
			paging: false,
			page: {
				paging: false,
				pageSize: 10
			},
			fitToWidth:true,
			colGroup:licHeader
		});
		licInfoGrid._targetID = "licInfoGrid";
		setLicInfoGrid();
	}
	
	function setLicInfoGrid(){
		var pushArr = [];
		// 리스트 데이터 추가
		if (basicLicGrid.list.length > 0) {
			basicLicGrid.list.forEach(function(item){
				pushArr.push(item);
			});
		}
		
		if (optLicGrid.list.length > 0) {
			optLicGrid.list.forEach(function(item){
				pushArr.push(item);
			});
		}
		
		// 리스트 초기화
		if (licInfoGrid.list.length > 0) {
			var removeArr = [];
			
			licInfoGrid.list.forEach(function(item, idx){
				removeArr.push({index: idx});
			});
			
			licInfoGrid.removeListIndex(removeArr);
		}
		licInfoGrid.pushList(pushArr);
	}
	
	function openDomainLicPopup(isOpt){
		var title = "<spring:message code='Cache.lbl_licenseRegist'/>"; // 라이선스 등록
		var seqList = ";";
		
		if (isOpt === "Y") {
			seqList += $(optLicGrid.list).map(function(idx, item){
				return item.LicSeq;
			}).get().join(";") + ";";
		} else {
			seqList += $(basicLicGrid.list).map(function(idx, item){
				return item.LicSeq;
			}).get().join(";") + ";";
		}
		
		var url =  "/covicore/domain/goDomainLicPopup.do";
			url += "?domainID=" + domainID;
			url += "&isOpt=" + isOpt;
			url += "&seqList=" + seqList;
		
		parent.Common.open("", "DomainLicPopup", title, url, "1000px", "260px", "iframe", false, null, null, true);
	}
	
	function addRow(isOpt, licList){
		if (isOpt === "Y") {
			licList.forEach(function(item){
				optLicGrid.pushList(item);
				if ($("#licInfoGrid .AXGridBody").length > 0) licInfoGrid.pushList(item);
			});
		} else {
			licList.forEach(function(item){
				basicLicGrid.pushList(item);
				if ($("#licInfoGrid .AXGridBody").length > 0) licInfoGrid.pushList(item);
			});
		}
		
		
//		setLicInfoGrid();
	}
	
	function deleteLicense(isOpt, licSeq){
		if (isOpt === "Y") {
			var removeList = [{"LicSeq": licSeq}];
			
			optLicGrid.removeList(removeList);
		} else {
			var removeList = [{"LicSeq": licSeq}];
			
			basicLicGrid.removeList(removeList);
		}
	}
	
	function licValidCheck(){
		var licList = [];
		var bool = true;
		
		/*if (licInfoGrid.list.length == 0) {
			Common.Warning("<spring:message code='Cache.msg_haveOneBaseLicense'/>"); // 1개 이상의 기본 라이선스가 있어야 합니다.
			return false;
		}*/
		
		<%-- // 서비스 기간 종료일과 lic.date(라이선스 암호값) 비교. isSaaS = "N" 이면, domainID = 0 을 보고, isSaaS가 "Y" 면 본인의 domainID 를 확인. --%>
		if (isSaaS != "Y" && domainID == 0) {
			licList.push({
				text : $("#serviceEnd").val().replaceAll("-", "")
				, item : "LIUP"
				, encrypt : $("#licExpireDate").val()
			});
		} else if (isSaaS == "Y" && domainID != 0) {
			licList.push({
				text : $("#serviceEnd").val().replaceAll("-", "")
				, item : "LIUP"
				, encrypt : $("#licExpireDate").val()
			});
		}
		
		licInfoGrid.list.forEach(function(item, idx){
			var $selGrid = $("#licInfoGrid .AXGridBody .gridBodyTr").eq(idx);
			
			// 정식수량
			if ($selGrid.find(".inputServiceUser").val()  && $selGrid.find(".inputLicUser").val()) {
				licList.push({
					  text:  $selGrid.find(".inputServiceUser").val() 
					, item : "LIUC"
					, encrypt: $selGrid.find(".inputLicUser").val()
				});
			} 
			
			// 임시기한
			if ($selGrid.find(".inputExtraExpiredate").val() && $selGrid.find(".inputLicExDate").val()) {
				licList.push({
					  text:  $selGrid.find(".inputExtraExpiredate").val()
					, item : "LIEx1UP"
					, encrypt: $selGrid.find(".inputLicExDate").val()
				});
			}
			
			// 임시수량
			if ($selGrid.find(".inputExtraServiceUser").val() && $selGrid.find(".inputLicExUser").val()) {
				licList.push({
					  text: $selGrid.find(".inputExtraServiceUser").val()
					, item : "LIExUC"
					, encrypt: $selGrid.find(".inputLicExUser").val()
				});
			}
		});
		
		if (!bool) {
			Common.Warning("<spring:message code='Cache.msg_enterFormalAssginKey'/>"); // 정식부여 key를 입력해주세요.
			return false;
		}
		
		$.ajax({
			url: "/covicore/domain/decryptLic.do",
			type: "POST",
			data: {
				"algorithm": "PBE",
				"siteUrl":$("#domainURL").val(),
				"list": JSON.stringify(licList)
			},
			async: false,
			success: function(res){
				if(res.status === 'SUCCESS'){
					var message = "";
					
					if (res.result.length > 0) {
						res.result.forEach(function(item){
							if (!item.ret) {
								<%-- // 암호화된 값이 decrypt는 가능하나 해당 값이 일치하지 않을 때.
									item.text 의 8자리가 숫자일 경우, 날짜로 판명하고, 년월일 구분.
								--%>
								if ( (item.text.length === 8) && (!isNaN(item.text)) ) {
									var strDate = item.text.substring(0, 4) +"-" +item.text.substring(4, 6) + "-" + item.text.substring(6,8);
									message += String.format("{0} : {1}<br>", strDate, item.encrypt);
								} else {
									message += String.format("{0} : {1}<br>", item.text, item.encrypt);	
								}
							}
						});
					}
					
					if (message) {
						var warnMsg = "<spring:message code='Cache.msg_notMatchGivenKey'/>" + message; // 지정된 값과 부여된 key가 일치하지 않습니다.<br>일치하지 않는 항목은 아래를 참고하시길 바랍니다.<br>
						
						Common.Warning(warnMsg);
						bool = false;
					}
				} else {
					<%-- 암호화된 값이 허위값이라 decrypt조차 될수없을 때 exception 으로 status='FAIL' 발생. message값 생성 못함. --%>
					var warnMsg = "<spring:message code='Cache.msg_notMatchGivenKey'/>";	// 지정된 값과 부여된 key가 일치하지 않습니다.<br>일치하지 않는 항목은 아래를 참고하시길 바랍니다.<br>
					Common.Warning(warnMsg.split("<br>")[0]); 	// 지정된 값과 부여된 key가 일치하지 않습니다.
					bool = false;
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/covicore/domain/decryptLic.do", response, status, error);
			}
		});
		
		return bool;
	}
	
	function setLicParams(){
		if ($("#licInfoGrid .AXGridBody").length == 0) {
			setLicInfoGridConfig();
		}
		
		var licList = [];
		
		licInfoGrid.list.forEach(function(item, idx){
			var $selGrid = $("#licInfoGrid .AXGridBody .gridBodyTr").eq(idx);
			var licObj = {
				 LicSeq: item.LicSeq
				, ServiceUser: ($selGrid.find(".inputServiceUser").val() === "" ? 0 : $selGrid.find(".inputServiceUser").val())  
				, ExtraExpiredate: $selGrid.find(".inputExtraExpiredate").val()  
				, ExtraServiceUser: ($selGrid.find(".inputExtraServiceUser").val() === "" ? 0 : $selGrid.find(".inputExtraServiceUser").val()) 
				, LicEx1Date: $selGrid.find(".inputLicExDate").val()
				, LicExUserCount: $selGrid.find(".inputLicExUser").val()
				, LicUserCount: $selGrid.find(".inputLicUser").val()
			};
			
			licList.push(licObj);
		});
		
		return JSON.stringify(licList);
	}
</script>
