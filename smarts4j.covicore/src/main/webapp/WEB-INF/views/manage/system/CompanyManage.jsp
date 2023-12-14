<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="egovframework.baseframework.util.PropertiesUtil,egovframework.baseframework.util.SessionHelper"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>

<div class="cRConTop titType AtnTop">
	<h2 class="title"><spring:message code="Cache.lbl_CompanyInfoManage"/></h2>	
</div>		
<style>
.l_img1{width:100%;height:100%}
</style>
<div class="cRContBottom mScrollVH">
<form id="form1">
	<div style="width:0px; height:0px; overflow:hidden;">
	</div>

	<div class="sadminContent">
		<ul class="tabMenu clearFloat">
			<li class="active"><a href="#"><spring:message code="Cache.lbl_BasicInfoManage"/></a></li><!-- 기본정보관리 -->
			<li class=""><a href="#"><spring:message code="Cache.lbl_DesignManage"/></a></li> <!-- 디자인 관리 -->
			<li class=""><a href="#"><spring:message code="Cache.lbl_apv_vacation_rule"/></a></li> <!-- 휴가 규정 -->
  			<li class=""><a href="#"><spring:message code="Cache.lbl_licenseInfo" /></a></li> <!--  라이선스 정보 -->
		</ul>
		<div id="info" class="tabContent active">
			<table class="sadmin_table company_info">
				<colgroup>
					<col width="200px;">
					<col width="*">
					<col width="200px;">
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
					</tr>
				</tbody>
			</table>
			<table class="sadmin_table">
				<colgroup>
					<col width="200px;">
					<col width="*">
					<col width="200px;">
					<col width="*">
				</colgroup>
				<tbody>
					<tr>
						<th><span class="thstar">*</span> <spring:message code="Cache.lbl_CompanyName"/></th> <!-- 회사명 -->
						<td>
							<input type="text" id="input_companyName" kind="dictionary" dic_src="hid_multiName" dic_callback="callbackMultiLangPopup" class="cInput HtmlCheckXSS ScriptCheckXSS" style="width: 70%;" />
							<a href="#" kind="dictionaryBtn" src_elem="input_companyName" class="btnTypeDefault" style="float: right;"><spring:message code='Cache.lbl_MultilanguageSettings'/></a>
						</td>
						<th><span class="thstar isSaas_required_point">*</span> <spring:message code="Cache.lbl_RepName"/></th> <!-- 대표자명 -->
						<td>
							<input type="text" id="input_repName" class="cInput HtmlCheckXSS ScriptCheckXSS"/>
						</td>
					</tr>
					<tr>
						<th><span class="thstar isSaas_required_point">*</span> <spring:message code="Cache.lbl_RepNumber"/></th> <!-- 대표번호 -->
						<td>
							<input type="text" id="input_repNumber" class="cInput HtmlCheckXSS ScriptCheckXSS"/>
						</td>
						<th><span class="thstar isSaas_required_point">*</span> <spring:message code="Cache.lbl_CorpNumber"/></th> <!-- 법인번호 -->
						<td>
							<input type="text" id="input_corpNumber" class="cInput HtmlCheckXSS ScriptCheckXSS"/>
						</td>
					</tr>
					<tr>
						<th><span class="thstar isSaas_required_point">*</span> <spring:message code="Cache.lbl_ComAddress"/></th> <!-- 회사주소 -->
						<td colspan="3">
							<input type="text" id="input_comAddress" class="cInput HtmlCheckXSS ScriptCheckXSS"/>
						</td>
					</tr>
					<tr>
						<th><span class="thstar isSaas_required_point">*</span> <spring:message code="Cache.lbl_apv_AdminName"/></th>
						<td>
							<input type="text" id="input_adminName" class="cInput HtmlCheckXSS ScriptCheckXSS"/>
						</td>
						<th><span class="thstar isSaas_required_point">*</span> <spring:message code="Cache.lbl_ChargePersonContact"/></th>
						<td>
							<input type="text" id="input_adminContact" class="cInput HtmlCheckXSS ScriptCheckXSS"/>
						</td>
					</tr>
					<tr>
						<th>
							<spring:message code="Cache.lbl_usageGoogleSchedule"/>
							<div class="collabo_help02">
								<a href="#" class="help_ico" id="btn_info"></a>
							</div>
						</th> <!-- 구글일정 사용여부 -->
						<td>
							<select id="select_useGoogleSchedule" >
								<option value="" selected><spring:message code="Cache.lbl_Select" /></option>
								<option value="Y"><spring:message code="Cache.lbl_Use" /></option>
								<option value="N"><spring:message code="Cache.lbl_noUse" /></option>
							</select>
						</td>
						<th><spring:message code="Cache.lbl_GoogleClientID"/> 	<!-- 구글 Client ID -->
							<div class="collabo_help02">
								<a href="#" class="help_ico" id="btn_google_id"></a>
							</div>
						</th> 
						<td>
							<input type="text" id="input_googleClientID" class="cInput googleInput HtmlCheckXSS ScriptCheckXSS"/>
						</td>
					</tr>
					<tr>
						<th><spring:message code="Cache.lbl_GoogleClientKey"/> 	<!-- 구글 Client Key -->
							<div class="collabo_help02">
								<a href="#" class="help_ico" id="btn_google_key"></a>
							</div>
						</th> 
						<td>
							<input type="text" id="input_googleClientKey" class="cInput googleInput HtmlCheckXSS ScriptCheckXSS"/>
						</td>
						<th><spring:message code="Cache.lbl_GoogleRedirectURL"/> 	<!-- 구글 Redirect URL -->
							<div class="collabo_help02">
								<a href="#" class="help_ico" id="btn_google_url"></a>
							</div>
						</th> 
						<td>
							<input type="text" id="input_googleRedirectURL" class="cInput googleInput HtmlCheckXSS ScriptCheckXSS"/>
						</td>
					</tr>
				</tbody>
			</table>
			<div align="center" class="bottomBtnWrap">
				<a onclick="confCompany.saveCompanyInfo();" class="btnTypeDefault btnTypeBg"> <spring:message code='Cache.btn_save'/></a><!-- 저장 -->
				<a onclick="confCompany.setData();" class="btnTypeDefault"><spring:message code='Cache.lbl_Cancel'/></a> <!-- 취소 -->
			</div>
		</div>
		<div id="design" class="tabContent" > 	<!-- 디자인 관리 탭 -->
			<h3>Logo</h3>
			<table class="sadmin_table sa_design">
				<colgroup>
					<col width="200">
					<col width="*">
					<col width="200">
					<col width="*">
				</colgroup>
				<tbody>
					<tr>
						<th><spring:message code="Cache.lbl_PCLogo"/> 		<!-- PC 로고 -->
							<div class="collabo_help02">
								<a href="#" class="help_ico" id="helpLogo"></a>
							</div>
							<p class="explain02">
								<spring:message code="Cache.lbl_Size"/> : 180 * 25 
								<br> 1MB <spring:message code="Cache.lbl_below"/>/
								<spring:message code="Cache.lbl_AllowExtension"/> :  png 
							</p>
						</th>
						<td>
							<div class="imgSelect" id="pcLogo1" style="width:50%;"> 
								<div class="designImgAdd" style="width:250x; height:80px;">
									<a href="#" class="fileSelect" ><spring:message code="Cache.msg_FileSelect"/></a>
									<img class="l_img1" onerror="coviCtrl.imgError(this);" style="display:none;">
									<a class="btn_del" href="#" style="display:none"></a>
								</div>
								<input type="file" name="input_pcLogo" style="display:none" accept=".png">
								<input type="hidden" class="inputPath" name="hid_pcLogoPath" value="" />
							</div>
						</td>
						<th><spring:message code="Cache.lbl_MobileLogo"/> 	<!-- Mobile 로고 -->
							<div class="collabo_help02">
								<a href="#" class="help_ico" id="helpMobileLogo"></a>
							</div>
							<p class="explain02">
								<spring:message code="Cache.lbl_Size"/> : 400 * 52 
								<br> 1MB <spring:message code="Cache.lbl_below"/>/
								<spring:message code="Cache.lbl_AllowExtension"/> :  png 
							</p>
						</th>
						<td>
							<div class="imgSelect" id="mobileLogo1" style="width:50%;"> 
								<div class="designImgAdd" style="width:250x; height:80px;">
									<a href="#" class="fileSelect" ><spring:message code="Cache.msg_FileSelect"/></a>
									<img class="l_img1" onerror="coviCtrl.imgError(this);" style="display:none;">
									<a class="btn_del" href="#" style="display:none"></a>
								</div>
								<input type="file" name="input_mobileLogo" style="display:none" accept=".png">
								<input type="hidden" class="inputPath"  name="hid_mobileLogoPath" value="" />
							</div>
						</td>
					</tr>
					<tr id="whiteLogoTable" style="display:none">
						<th>PC 화이트 로고 		<!-- PC 화이트 로고 -->
							<div class="collabo_help02">
								<a href="#" class="help_ico" id="helpLogo2"></a>
							</div>
							<p class="explain02">
								<spring:message code="Cache.lbl_Size"/> : 206 * 60 
								<br> 1MB <spring:message code="Cache.lbl_below"/>/
								<spring:message code="Cache.lbl_AllowExtension"/> :  png 
							</p>
						</th>
						<td>
							<div class="imgSelect" id="pcLogo2" style="width:50%;"> 
								<div class="designImgAdd logo_white" style="width:250x; height:80px;">
									<a href="#" class="fileSelect" ><spring:message code="Cache.msg_FileSelect"/></a>
									<img class="l_img1" onerror="coviCtrl.imgError(this);" style="display:none;">
									<a class="btn_del" href="#" style="display:none"></a>
								</div>
								<input type="file" name="input_pcLogo" style="display:none" accept=".png">
								<input type="hidden" class="inputPath" name="hid_pcLogoPath" value="" />
							</div>	
						</td>
						<th>Mobile 화이트 로고 	<!-- Mobile 화이트 로고 -->
							<div class="collabo_help02">
								<a href="#" class="help_ico" id="helpMobileLogo2"></a>
							</div>
							<p class="explain02">
								<spring:message code="Cache.lbl_Size"/> : 330 * 96 
								<br> 1MB <spring:message code="Cache.lbl_below"/>/
								<spring:message code="Cache.lbl_AllowExtension"/> :  png 
							</p>
						</th>
						<td>
							<div class="imgSelect" id="mobileLogo2" style="width:50%;"> 
								<div class="designImgAdd logo_white" style="width:250x; height:80px;">
									<a href="#" class="fileSelect" ><spring:message code="Cache.msg_FileSelect"/></a>
									<img class="l_img1" onerror="coviCtrl.imgError(this);" style="display:none;">
									<a class="btn_del" href="#" style="display:none"></a>
								</div>
								<input type="file" name="input_mobileLogo"  style="display:none" accept=".png">
								<input type="hidden" class="inputPath"  name="hid_mobileLogoPath" value="" />
							</div>	
						</td>
					</tr>
				</tbody>
			</table>
			<h3><spring:message code="Cache.lbl_PortalBanner"/></h3>
			<table id="tbl_potalBanner"  class="sadmin_table sa_design">	
				<colgroup>
					<col width="200">
					<col width="*">
				</colgroup>				
				<tbody>
					<tr>
						<th rowspan=4><spring:message code="Cache.lbl_PortalBanner"/>
							<div class="collabo_help02">
								<a href="#" class="help_ico" id="pcBanner"></a>
							</div>
							<p class="explain02">
								<spring:message code="Cache.lbl_Size"/> : 778 * 170 
								<br> 1MB <spring:message code="Cache.lbl_below"/>/
								<spring:message code="Cache.lbl_AllowExtension"/> :  jpg 
							</p>
						</th>
						<td>	
							<a href="#" class="btnPlusAdd" id="btnPlusAdd"><spring:message code="Cache.btn_Add"/></a> <!-- 추가 -->
							<a href="#" class="btnSaRemove" id="btnSaRemove"><spring:message code="Cache.lbl_AllDelete"/></a>  &nbsp;&nbsp; <!-- 삭제 -->
							<p class="explain"><span class="thstar">*</span><spring:message code="Cache.msg_canRegisterPortalBanners" /></p> 	<!--  포탈 배너는 3개까지 등록 가능합니다. -->
						</td>
					</tr>
					<tr >
						<td>
							<div class="imgSelect" id="bannerLogo"> 
								<div class="designImgAdd" style="width:778px; height:170px;">
									<a href="#" class="fileSelect" ><spring:message code="Cache.msg_FileSelect"/></a>
									<img  class="l_img1">
									<a class="btn_del" href="#" style="display:none"></a>
								</div>
								<p>
									<spring:message code="Cache.lbl_LinkURL" /> 	<!-- 연결URL -->
									<input type="text" id="input_portalBanner_link" class="input_portalBanner_link" value="" placeholder="연결할 URL을 입력하세요." >
								</p>  
								<input type="file" id="input_banner"  class="file_portal_banner" style="display:none"  accept=".jpg, .jpeg, .png, .gif" >
								<input type="hidden" id="hid_portalBannerPath" class="inputPath"  value="" />
							</div>	
						</td>
					</tr>
				</tbody>
			</table>
			
			<table id="tbl_ContentsBanner"  class="sadmin_table sa_design" style="display:none;">	
				<colgroup>
					<col width="200">
					<col width="*">
				</colgroup>
				<tbody>
					<tr>
						<th rowspan=4>콘텐츠 배너
							<div class="collabo_help02">
								<a href="#" class="help_ico" id="ctnBanner"></a>
							</div>
							<p class="explain02">
								<spring:message code="Cache.lbl_Size"/> : 706 * 260 
								<br> 1MB <spring:message code="Cache.lbl_below"/>/
								<spring:message code="Cache.lbl_AllowExtension"/> :  jpg 
							</p>
						</th>
						<td>	
							<a href="#" class="btnPlusAdd" id="btnCtnBnrPlusAdd"><spring:message code="Cache.btn_Add"/></a> <!-- 추가 -->
							<a href="#" class="btnSaRemove" id="btnCtnBnrRemove"><spring:message code="Cache.lbl_AllDelete"/></a>  &nbsp;&nbsp; <!-- 삭제 -->
							<p class="explain"><span class="thstar">*</span>콘텐츠 배너는 3개까지 등록 가능합니다.</p> 	<!-- 콘텐츠 배너는 3개까지 등록 가능합니다. -->
						</td>
					</tr>
					<tr >
						<td>
							<div class="imgSelect" id="ctnBannerLogo"> 
								<div class="designImgAdd" style="width:706px; height:260px;">
									<a href="#" class="fileSelect"><spring:message code="Cache.msg_FileSelect"/></a>
									<img  class="l_img1"/>
									<a class="btn_del" href="#" style="display:none"></a>
								</div>
								<p>
									<spring:message code="Cache.lbl_LinkURL" /> 	<!-- 연결URL -->
									<input type="text" id="input_ContentsBanner_link" class="input_ContentsBanner_link" value="" placeholder="연결할 URL을 입력하세요." >
								</p>  
								<input type="file" id="input_banner1"  class="file_portal_banner" style="display:none"  accept=".jpg, .jpeg, .png, .gif" >
								<input type="hidden" id="hid_ContentsBannerPath" class="inputPath"  value="" />
							</div>	
						</td>
					</tr>
				</tbody>
			</table>
			
			<h3><spring:message code="Cache.lbl_login"/></h3> 	<!-- 로그인 -->
			<table class="sadmin_table sa_design">
				<colgroup>
					<col width="200">
					<col width="*">
				</colgroup>
				<tbody>
					<tr>
						<th><spring:message code="Cache.ThemeType_BgImage" /></th> 	<!-- 배경이미지 -->
						<td>
							<div class="imgSelect" id="pcLogin"> 
								<div class="designImgAdd" style="width:450px; height:250px;">
									<a href="#" class="fileSelect" ><spring:message code="Cache.msg_FileSelect"/></a>
									<img class="l_img1" onerror="coviCtrl.imgError(this);" style="display:none;">
									<a class="btn_del" href="#" style="display:none"></a>
								</div>
								<input type="file" id="input_pcLogin"  style="display:none">
								<input type="hidden" id="hid_pcLoginPath" class="inputPath"  value="" />
							</div>	
						</td>
					</tr>
					<tr>
						<th><spring:message code="Cache.lbl_apv_thema" /></th> 	<!-- 테마설정 -->
						<td>
							<ul class="login_theme">
								<li>
									<input type="radio" name="theme" id="scheck1" class="theme_check" data-theme="purple">
									<img onerror="coviCtrl.imgError(this);" src="<%=cssPath%>/simpleAdmin/resources/images/login_bg_purple.jpg">
									<label for="scheck1" id="scheck1Lb"></label>
								</li>
								<li>
									<input type="radio" name="theme" id="scheck2" class="theme_check" data-theme="white">
									<img onerror="coviCtrl.imgError(this);" src="<%=cssPath%>/simpleAdmin/resources/images/login_bg_white.jpg">
									<label for="scheck2" id="scheck1Lb"></label>
								</li>
								<li>
									<input type="radio" name="theme" id="scheck3" class="theme_check" data-theme="gray">
									<img onerror="coviCtrl.imgError(this);" src="<%=cssPath%>/simpleAdmin/resources/images/login_bg_gray.jpg">
									<label for="scheck3" id="scheck1Lb"></label>
								</li>
							</ul>
						</td>
					</tr>
				</tbody>
			</table>
			<div align="center" class="bottomBtnWrap">
				<a onclick="confCompany.saveCompanyDesign();" class="btnTypeDefault btnTypeBg"><spring:message code='Cache.btn_save'/></a> <!-- 저장 -->
				<a onclick="confCompany.setData();" class="btnTypeDefault"><spring:message code='Cache.lbl_Cancel'/></a> <!-- 취소 -->
			</div>
		</div>
		<div id="vacationInfo" class="tabContent active" >
			<div id="divWebEditor" class="writeEdit">
			</div>
			<div align="center" class="bottomBtnWrap">
				<a onclick="confCompany.loadTemplate();" class="btnTypeDefault"><spring:message code='Cache.lbl_temploadRead'/></a> <!-- 저장 -->
				<a onclick="confCompany.saveCompanyVac();" class="btnTypeDefault btnTypeBg"><spring:message code='Cache.btn_save'/></a> <!-- 저장 -->
				<a onclick="confCompany.setData();" class="btnTypeDefault"><spring:message code='Cache.lbl_Cancel'/></a> <!-- 취소 -->
			</div>
		</div>						
		<div class="tabContent">
  			<h3><spring:message code='Cache.lbl_licenseInfo' /></h3> 	
			<table class="sadmin_table license_detail" id="license_detail">
				<colgroup>
					<col width="150">
					<col width="200">
					<col width="*">
					<col width="100">
					<col width="*">
					<col width="*">
					<col width="*">
				</colgroup>
				<thead>
					<tr>
						<th rowspan=2><spring:message code="Cache.lbl_licenseInfo"/></th>
						<th class="align_center" colspan=2><spring:message code="Cache.lbl_apv_normal"/></th>
						<th class="align_center" colspan=2><spring:message code="Cache.lbl_apv_Temporary"/></th> 	<!-- 서비스 -->
						<th class="align_center" rowspan=2><spring:message code="Cache.lbl_License_ActiveUserCnt"/></th> 		<!-- 실제수량 -->
  						<th class="align_center" rowspan=2><spring:message code="Cache.lbl_n_att_remain"/><spring:message code="Cache.ACC_lbl_quantity"/></th> 		<!-- 잔여수량 -->
					</tr>
					<tr>	
						<th class="align_center"><spring:message code="Cache.lbl_ServicePeriod"/></th>
						<th class="align_center"><spring:message code="Cache.lbl_License_UserCnt"/></th> 	<!-- 서비스 -->
						<th class="align_center"><spring:message code="Cache.lbl_ExpireDate" /></th>
						<th class="align_center"><spring:message code="Cache.lbl_License_UserCnt"/></th> 	<!-- 서비스 -->
					</tr>
				</thead>
				<tbody>
				</tbody>
			</table>
			
  			<h3><spring:message code='Cache.lbl_OptionInfo' /> </h3> 	
			<table class="sadmin_table license_detail" id="license_opt_detail">
				<colgroup>
					<col width="150">
					<col width="200">
					<col width="*">
					<col width="100">
					<col width="*">
					<col width="*">
					<col width="*">
				</colgroup>
				<thead>
					<tr>
						<th rowspan=2><spring:message code="Cache.lbl_licenseInfo"/></th>
						<th class="align_center" colspan=2><spring:message code="Cache.lbl_apv_normal"/></th>
						<th class="align_center" colspan=2><spring:message code="Cache.lbl_apv_Temporary"/></th> 	<!-- 서비스 -->
						<th class="align_center" rowspan=2><spring:message code="Cache.lbl_License_ActiveUserCnt"/></th> 		<!-- 실제수량 -->
  						<th class="align_center" rowspan=2><spring:message code="Cache.lbl_n_att_remain"/><spring:message code="Cache.ACC_lbl_quantity"/></th> 		<!-- 잔여수량 -->
					</tr>
					<tr>	
						<th class="align_center"><spring:message code="Cache.lbl_ServicePeriod"/></th>
						<th class="align_center"><spring:message code="Cache.lbl_License_UserCnt"/></th> 	<!-- 서비스 -->
						<th class="align_center"><spring:message code="Cache.lbl_ExpireDate" /></th>
						<th class="align_center"><spring:message code="Cache.lbl_License_UserCnt"/></th> 	<!-- 서비스 -->
					</tr>
				</thead>
				<tbody>
				</tbody>
			</table>
			<%if (SessionHelper.getSession("DN_ID").equals("0")) {%>
			<div align="center" class="bottomBtnWrap">
				<covi:admin><a id="btnRemoveLicense" class="btnTypeDefault"><spring:message code='Cache.lbl_RemoveLicenseCache'/></a><covi:admin>
			</div>
			<%} %>
		</div>
		
		<input type="hidden" id="hid_domainID" value="" />
		<input type="hidden" id="hid_multiName" value="" /> 	<!-- 다국어 팝업 공통 -->
	</div>
</form>
</div>
<script type="text/javascript">
	var bannerRowCnt = 1; // 포탈 배너 테이블 열 수
	// 정규표현식(다국어 특수문자 처리).
	var regExp = /\&nbsp\;|\&quot\;|\&apos\;|\;|\"|\'/g;
	
	// (PC, Mobile) personal 포탈 사용 여부
	var isUsePersonalPortal = Common.getBaseConfig("IsUsePersonalPortal");
	var isSaaS = Common.getGlobalProperties("isSaaS");

	if(isUsePersonalPortal == "Y") {
		$("#whiteLogoTable, #tbl_ContentsBanner").show();
		
		$("#helpLogo").closest("div").siblings(".explain02").html(
				Common.getDic("lbl_Size") + " : 206 * 60 <br/> 1MB " + Common.getDic("lbl_below") + "/" + Common.getDic("lbl_AllowExtension") + ": png"
		);
		$("#helpMobileLogo").closest("div").siblings(".explain02").html(
				Common.getDic("lbl_Size") + " : 330 * 96 <br/> 1MB " + Common.getDic("lbl_below") + "/" + Common.getDic("lbl_AllowExtension") + ": png"
		);
		$("#pcBanner").closest("div").siblings(".explain02").html(
				Common.getDic("lbl_Size") + " : 160 * 194 <br/> 1MB " + Common.getDic("lbl_below") + "/" + Common.getDic("lbl_AllowExtension") + ": jpg"
		);
		
		$("#bannerLogo").children("div").css("width", "160px");
		$("#bannerLogo").children("div").css("height", "194px");
	}
	
	var confCompany = {
		initContent:function (){
					
			$("#divWebEditor").css("visibility", "hidden");
			coviEditor.loadEditor('divWebEditor',
					{
						editorType : g_editorKind,
						containerID : 'tbContentElement',
						frameHeight : '510',
						focusObjID : '',
						onLoad:  function(){
							confCompany.setData();
				        	$("#vacationInfo").removeClass('active');
				        	$("#divWebEditor").css("visibility", "visible");
				        }
					}
				);
			// 탭메뉴
			$('.tabMenu>li').on('click', function(){
				$('.tabMenu>li').removeClass('active');
				$('.tabContent').removeClass('active');
				$(this).addClass('active');
				$('.tabContent').eq($(this).index()).addClass('active');
			});
			// 툴팁 - 기본 정보 관리
			Common.toolTip($("#btn_info"), "TT_CompanyGoogleYN", "width:400px"); 					// 구글일정 사용여부.
			Common.toolTip($("#btn_google_id"), "TT_GoogleClientID", "width:400px");				// 구글 Client ID
			Common.toolTip($("#btn_google_key"), "TT_GoogleClientSecureKey", "width:410px"); 	// 구글 Client Key
			Common.toolTip($("#btn_google_url"), "TT_GoogleRedirectURL", "width:400px"); 		// 구글 Redirect URL
			// 툴팁 - 디자인 관리
			Common.toolTip($("#helpLogo"), "TT_PcLogo", "width:400px");					// PC 로고
			Common.toolTip($("#helpMobileLogo"), "TT_MobileLogo", "width:400px");	 	// Mobile 로고
			Common.toolTip($("#pcBanner"), "TT_PortalBanner", "width:400px"); 			// 포탈 배너
			Common.toolTip($("#ctnBanner"), "TT_ContentsBanner" ,"width:400px");        // 퍼스널형 컨텐츠 배너

			Common.toolTip($("#helpLogo2"), "TT_PcLogo2", "width:400px");					// PC 로고
			Common.toolTip($("#helpMobileLogo2"), "TT_MobileLogo2", "width:400px");	 	// Mobile 로고

			//파일선택
			$(".fileSelect").on("click", function(){
				var srcId= $(this).closest(".imgSelect").attr("id");
				var idx;
				
				if (srcId =="bannerLogo"){
					idx = $("#tbl_potalBanner tbody tr").index($(this).parents("tr"));
					$("#tbl_potalBanner tbody tr:eq("+idx+") input[type='file']").click();
				} else if(srcId =="ctnBannerLogo") {
					idx = $("#tbl_ContentsBanner tbody tr").index($(this).parents("tr"));
					$("#tbl_ContentsBanner tbody tr:eq("+idx+") input[type='file']").click();
				} else{
					$("#"+srcId +" input[type='file']").click();
				}
			});
			
			$("input[type='file']").on("change",function(){
				var srcObj = $(this).closest(".imgSelect");
				
				//var mode= srcId.data("mode");
				var file = $(this)[0].files[0];
				var allowType = {};

				if ($(this).attr("accept") != undefined ) allowType = $(this).attr("accept").replaceAll(" ", "").split(",");
				if(file.name != ""){
					var pathPoint = file.name.lastIndexOf('.');
					var filePoint = file.name.substring(pathPoint + 1, file.name.length);
					var fileType = filePoint.toLowerCase();
					$(srcObj).find("img").attr("src", "");
					
					if(file.size > 1000000){
						Common.Warning("<spring:message code='Cache.msg_only1MB'/>"); // 1MB 이하만 가능합니다
						$(this).val("");
						return;
					}

					if(allowType.length>0 && $.inArray("."+fileType, allowType) == -1) {
						Common.Warning("<spring:message code='Cache.msg_ExistLimitedExtensionFile'/>");	
						return;
					}
					
/*					if(fileType != "png"){
						Common.Warning("<spring:message code='Cache.msg_onlyPng'/>"); // png만 가능합니다.
						$(this).val("");
						return;
					}
*/					

					$(srcObj).find("img").show();//미리보기
					$(srcObj).find(".btn_del").show();//미리보기
					$(srcObj).find(".fileSelect").hide();
					$(srcObj).find(".designImgAdd").addClass("imgY");

					confCompany.readURL($(srcObj).find("img"), this);
				}
				
			});
			//파일 삭제
			$(".btn_del").on("click",function(){
				var srcId = $(this).closest(".imgSelect").attr("id");
				var idx;
				
				if (srcId =="bannerLogo"){
					idx = $("#tbl_potalBanner tbody tr").index($(this).parents("tr"));
					srcId = "tbl_potalBanner tbody tr:eq("+idx+")" ;
				} else if(srcId == "ctnBannerLogo") {
					idx = $("#tbl_ContentsBanner tbody tr").index($(this).parents("tr"));
					srcId = "tbl_ContentsBanner tbody tr:eq("+idx+")" ;
				}
				
				$("#"+srcId +" .designImgAdd").removeClass("imgY");
				$("#"+srcId +" .fileSelect").show();
				$("#"+srcId +" img").hide();
				$("#"+srcId +" .btn_del").hide();
				$("#"+srcId +" img").removeAttr("onerror");
				$("#"+srcId +" img").attr("src", "");
				$("#"+srcId +" input[type='file']").val("");
				$("#"+srcId +" input[type='file']").val("");
				$("#"+srcId +" .inputPath").val("");
			});
			
			//추가
			$("#btnPlusAdd").on("click",function(){
				confCompany.addRow();
			});
			//삭제
			$("#btnSaRemove").on("click",function(){
				confCompany.removeAllRow();
			});
			$("#btnCtnBnrPlusAdd").on("click",function(){
				confCompany.addCtnBnrRow();
			});
			$("#btnCtnBnrRemove").on("click",function(){
				confCompany.removeAllCtnBnrRow();
			});

			$("#select_useGoogleSchedule").on("change", function(){
				var selVal = $(this).find("option:selected").val();
				
				if(selVal == "Y"){
					$(".googleInput").prop("disabled", false);
				}else{
					$(".googleInput").prop("disabled", true);
				}
			});
			
			$('#btnRemoveLicense').on('click', function(){	
				confCompany.removeLicenseCache()
			});

		}
		, setData:function (){
			$.ajax({
				type: "POST",
				data: {
					"DomainID" : confMenu.domainId
				},
				async: false,
				url: "/covicore/manage/domain/getCompanyInfo.do",
				success: function (data){
					//var backStorage = Common.getBaseConfig("BackStorage").replace("{0}", data.map.DomainCode);
					var pcLogoImagePath = [];
					var mobileLogoImagePath = [];
					
					var pcLoginImagePath = "";
					var domainBannerPath = data.map.DomainBannerPath.split("|");
					var domainBannerLink = data.map.DomainBannerLink.split("|");
					
					var portalBannerLinks = domainBannerLink[0].split(";");
					var contentsBannerLinks = domainBannerLink.length == 2 ? domainBannerLink[1].split(";") : "";
					
					var portalBannerPaths = domainBannerPath[0].split(";");
					var contentsBannerPaths = domainBannerPath.length == 2 ? domainBannerPath[1].split(";") : ""; 
					
					if(data.map.DomainImagePath != ""){
						//DomainImagePath 구성 : PCLogo1;MobileLogo1;PCLogin;PCLogo2;MobileLogo2;
						pcLogoImagePath.push(data.map.DomainImagePath.split(";")[0]); //PC 로고1
						
						mobileLogoImagePath.push(data.map.DomainImagePath.split(";")[1]); //모바일 로고1
						
						pcLoginImagePath= data.map.DomainImagePath.split(";")[2]; //PC 로그인 이미지
						
						pcLogoImagePath.push(data.map.DomainImagePath.split(";")[3]); //PC 로고2
						
						mobileLogoImagePath.push(data.map.DomainImagePath.split(";")[4]); //모바일 로고2
					}
					
					$("#hid_domainID").val(data.map.DomainID)
					$("#txt_domainCode").text(data.map.DomainCode);
					$("#txt_domain").text(data.map.DomainURL);
					$("#input_companyName").val(data.map.DisplayName);
					
					<%-- // 회사명은 '&'가 포함되는 경우가 있는 케이스가 있음. 공통 다국어처리 시 GET방식으로 호출되기 때문에 추가로 처리함. --%>
					$("#hid_multiName").val(encodeURIComponent(data.map.MultiDisplayName));
					
					$("#input_repName").val(data.map.DomainRepName);
					$("#input_repNumber").val(data.map.DomainRepTel);
					$("#input_corpNumber").val(data.map.DomainCorpTel);
					$("#input_comAddress").val(data.map.DomainAddress);
					$("#input_adminName").val(data.map.ChargerName);
					$("#input_adminContact").val(data.map.ChargerTel);
					$("#select_useGoogleSchedule").val(data.map.IsUseGoogleSchedule);
					$("#input_googleClientID").val(data.map.GoogleClientID);
					$("#input_googleClientKey").val(data.map.GoogleClientKey);
					$("#input_googleRedirectURL").val(data.map.GoogleRedirectURL);
					
					if (data.map.DomainThemeCode != "" && data.map.DomainThemeCode != "blue"){
						$('.login_theme input[data-theme="'+data.map.DomainThemeCode+'"]').attr("checked", true);
					}else{
						$('.login_theme input[data-theme="purple"]').attr("checked", true);
					}	
					if(data.map.IsUseGoogleSchedule == "Y"){
						$(".googleInput").prop("disabled", false);
					}else{
						$(".googleInput").prop("disabled", true);
					}
					
					if(isSaaS != "Y"){
						$(".isSaas_required_point").css("display","none");
					}
					
					$.each($("input[name=hid_pcLogoPath]"), function(idx, item) {
						if(pcLogoImagePath[idx] != null && pcLogoImagePath[idx] != "") {
							var srcID = "#pcLogo" + (idx+1).toString();
							
							$(item).val(pcLogoImagePath[idx]);
							
							var pcLogoPath = "/covicore/common/logo/"+pcLogoImagePath[idx]+".do";
							
							if ($("#txt_domainCode").text() != Common.getSession('DN_Code')) pcLogoPath += '?DomainCode='+$("#txt_domainCode").text();
							
							$(srcID + " img").show();
							$(srcID + " img").attr("src", pcLogoPath);
							$(srcID + " .fileSelect").hide();
							$(srcID + " .designImgAdd").addClass("imgY");
							$(srcID + " .btn_del").show();
						}
					});
					
					$.each($("input[name=hid_mobileLogoPath]"), function(idx, item) {
						if(mobileLogoImagePath[idx] != null && mobileLogoImagePath[idx] != "") {
							var srcID = "#mobileLogo" + (idx+1).toString();
							
							$(item).val(mobileLogoImagePath[idx]);
							
							var mobileLogoPath = "/covicore/common/logo/"+mobileLogoImagePath[idx]+".do";
							
							if ($("#txt_domainCode").text() != Common.getSession('DN_Code')) mobileLogoPath += '?DomainCode='+$("#txt_domainCode").text();
							
							$(srcID + " img").show();
							$(srcID + " img").attr("src", mobileLogoPath);
							$(srcID + " .fileSelect").hide();
							$(srcID + " .designImgAdd").addClass("imgY");
							$(srcID + " .btn_del").show();
						}
					});
					
					$("#hid_pcLoginPath").val(pcLoginImagePath);
					
					if(pcLoginImagePath != null && pcLoginImagePath != ""){
						var pcLoginPath = "/covicore/common/logo/"+pcLoginImagePath+".do";
						if ($("#txt_domainCode").text() != Common.getSession('DN_Code')) pcLoginPath += '?DomainCode='+$("#txt_domainCode").text();
						
						$("#pcLogin img").show();
						$("#pcLogin img").attr("src", pcLoginPath);
						$("#pcLogin .fileSelect").hide();
						$("#pcLogin .designImgAdd").addClass("imgY");
						$("#pcLogin .btn_del").show();
					}else{
						$("#pcLogin .fileSelect").show();
					}

					confCompany.removeAllRow();
					if(portalBannerPaths != "" && portalBannerPaths.length > 0){
						$(portalBannerPaths).each(function(idx, path){
							if(path){
								if (idx>0) confCompany.addRow();
								
								var bannerPath = "/covicore/common/banner/"+path+".do";
								if ($("#txt_domainCode").text() != Common.getSession('DN_Code')) bannerPath += '?DomainCode='+$("#txt_domainCode").text();
								$('#tbl_potalBanner tbody tr:last').find("#input_portalBanner_link").val(portalBannerLinks[idx]);
								$('#tbl_potalBanner tbody tr:last').find("img").attr("src", bannerPath);
								$('#tbl_potalBanner tbody tr:last').find("img").attr("onerror", "coviCtrl.imgError(this);");
								$('#tbl_potalBanner tbody tr:last').find("img").show();
								$('#tbl_potalBanner tbody tr:last').find(".fileSelect").hide();//미리보기
								$('#tbl_potalBanner tbody tr:last').find(".designImgAdd").addClass("imgY");
								$('#tbl_potalBanner tbody tr:last').find(".btn_del").show();
								$('#tbl_potalBanner tbody tr:last').find("#hid_portalBannerPath").val(path);

							}
						});
					}
					
					confCompany.removeAllCtnBnrRow();
					if(contentsBannerPaths != "" && contentsBannerPaths.length > 0){
						$(contentsBannerPaths).each(function(idx, path){
							if(path){
								if (idx>0) confCompany.addCtnBnrRow();
								
								var bannerPath = "/covicore/common/banner/"+path+".do";
								if ($("#txt_domainCode").text() != Common.getSession('DN_Code')) bannerPath += '?DomainCode='+$("#txt_domainCode").text();
								$('#tbl_ContentsBanner tbody tr:last').find("#input_ContentsBanner_link").val(contentsBannerLinks[idx]);
								$('#tbl_ContentsBanner tbody tr:last').find("img").attr("src", bannerPath);
								$('#tbl_ContentsBanner tbody tr:last').find("img").attr("onerror", "coviCtrl.imgError(this);");
								$('#tbl_ContentsBanner tbody tr:last').find("img").show();
								$('#tbl_ContentsBanner tbody tr:last').find(".fileSelect").hide();//미리보기
								$('#tbl_ContentsBanner tbody tr:last').find(".designImgAdd").addClass("imgY");
								$('#tbl_ContentsBanner tbody tr:last').find(".btn_del").show();
								$('#tbl_ContentsBanner tbody tr:last').find("#hid_ContentsBannerPath").val(path);

							}
						});
					}
					
					//ServiceUser
					$('#license_detail tbody').empty()
					$('#license_opt_detail tbody').empty()
					if (data.licenseList.length>0){
						data.licenseList.map(function(item, idx){
							var objId = "license_detail";
							if (item.IsOpt == "Y") objId="license_opt_detail";
							
							$('#'+objId+' tbody').append($("<tr>")
										.append($("<th>",{"class":"bodyTdText","text":item.LicName}))
										
										.append($("<td>",{"class":"bodyTdText","text":coviCmn.getDateFormat(item.ServiceStart,".") +" ~"+coviCmn.getDateFormat(item.LicExpireDate,".")}))
										.append($("<td>",{"class":"bodyTdText","text":item.LicUserCount}))
										.append($("<td>",{"class":"bodyTdText","text":coviCmn.getDateFormat(item.LicEx1Date,".")}))
										.append($("<td>",{"class":"bodyTdText","text":item.LicExUserCount}))
										.append($("<td>",{"class":"bodyTdText","text":item.LicUsingCnt}))
										.append($("<td>",{"class":"bodyTdText","text":item.RemainCnt}))

//										.append($("<td>",{"class":"bodyTdText","text":coviCmn.getDateFormat(item.ServiceStart,".") +" ~"+coviCmn.getDateFormat(item.ServiceEnd,".")}))
//										.append($("<td>",{"class":"bodyTdText","text":item.ServiceUser}))
//										.append($("<td>",{"class":"bodyTdText","text":coviCmn.getDateFormat(item.ExtraExpiredate,".")}))
//										.append($("<td>",{"class":"bodyTdText","text":item.ExtraServiceUser}))
										
									);
						});
					}
					
					if ($('#license_opt_detail tbody tr').length == 0) $('#license_opt_detail').hide();
					else $('#license_opt_detail').show();
					// 서비스 기간
					var serviceStartDate = data.map.ServiceStart.split(" ")[0];
					var serviceEndDate = data.map.ServiceEnd.split(" ")[0];
					$("#txt_servicePeriod").text(serviceStartDate + " ~ " + serviceEndDate);
					
					var g_editorBody = data.vacationPolicy;
					coviEditor.setBody(g_editorKind, 'tbContentElement', data.vacationPolicy);
				},
				error: function(response, status, error){
				     CFN_ErrorAjax("/covicore/domain/get.do", response, status, error);
				}
			});
		},
		saveCompanyInfo:function(){
			if(!confCompany.chkValidation()){
				return false;
			}
			
			data= {
					"DomainID" : $("#hid_domainID").val(),
					"DomainCode" : $("#txt_domainCode").text(),
					"DisplayName" : $("#input_companyName").val(),
					"MultiDisplayName" : decodeURIComponent($("#hid_multiName").val()),
					"DomainRepName" : $("#input_repName").val(),
					"DomainRepTel" : $("#input_repNumber").val(),
					"DomainCorpTel" : $("#input_corpNumber").val(),
					"DomainAddress" : $("#input_comAddress").val(),
					"ChargerName" : $("#input_adminName").val(),
					"ChargerTel" : $("#input_adminContact").val(),
					"IsUseGoogleSchedule" : $("#select_useGoogleSchedule").val(),
					"GoogleClientID" : $("#input_googleClientID").val(),
					"GoogleClientKey" : $("#input_googleClientKey").val(),
					"GoogleRedirectURL" : $("#input_googleRedirectURL").val()
				};
			
			$.ajax({
				type: "POST",
				data: data,
				url: "/covicore/manage/domain/saveCompanyInfo.do",
				success: function(data){
					if(data.status == "SUCCESS"){
						Common.Inform("<spring:message code='Cache.msg_apv_331'/>", "Information", function(result){ // 저장되었습니다.
							if(result){
								confCompany.setData();
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
		},
		saveCompanyDesign:function(){
			
			var formData = new FormData();
			var portalBannerPathList = "";
			var contentsBannerPathList = "";	

			$("#tbl_potalBanner tbody tr").each(function(idx, item){
				if (idx > 0){
					var file = $(item).find("input[type='file']")[0].files[0];
					if(file != null){
						formData.append("PortalBannerFile_"+(idx-1), file);
					}
					var path = $(item).find("#hid_portalBannerPath").val();
					if (idx > 1) portalBannerPathList += ";";
					portalBannerPathList += path;
				}	
			});
			
			$("#tbl_ContentsBanner tbody tr").each(function(idx, item){
				if (idx > 0){
					var ctnfile = $(item).find("input[type='file']")[0].files[0];
					if(ctnfile != null){
						formData.append("ContentsBannerFile_"+(idx-1), ctnfile);
					}
					var ctnPath = $(item).find("#hid_ContentsBannerPath").val();
					if (idx > 1) contentsBannerPathList += ";";
					contentsBannerPathList += ctnPath;
				}	
			});

			//PC 로고 저장
			formData.append("PCLogoFile1", $("input[name=input_pcLogo]").eq(0)[0].files[0]);
			formData.append("PCLogoFile2", $("input[name=input_pcLogo]").eq(1)[0].files[0]);
			
			//PC 로고 경로 저장
			formData.append("PCLogoPath1", $("input[name=hid_pcLogoPath]").eq(0).val() + ";");
			formData.append("PCLogoPath2", $("input[name=hid_pcLogoPath]").eq(1).val() + ";");
			
			//모바일 로고 저장
			formData.append("MobileLogoFile1", $("input[name=input_mobileLogo]").eq(0)[0].files[0]);
			formData.append("MobileLogoFile2", $("input[name=input_mobileLogo]").eq(1)[0].files[0]);
			
			//모바일 로고 경로 저장
			formData.append("MobileLogoPath1", $("input[name=hid_mobileLogoPath]").eq(0).val() + ";");
			formData.append("MobileLogoPath2", $("input[name=hid_mobileLogoPath]").eq(1).val() + ";");
			
			formData.append("DomainID", $("#hid_domainID").val());
			formData.append("DomainCode", $("#txt_domainCode").text());
			formData.append("PCLoginFile", $("#input_pcLogin")[0].files[0]);
			formData.append("PCLoginPath", $("#hid_pcLoginPath").val());
			formData.append("PortalBannerPaths", portalBannerPathList);
			formData.append("ContentsBannerPaths", contentsBannerPathList);
			formData.append("DomainThemeCode", $(".login_theme input[name=theme]:checked").data("theme"));
			formData.append("PortalBannerLink", $(".input_portalBanner_link").eq(0).val()
					+";"+($(".input_portalBanner_link").length>1?$(".input_portalBanner_link").eq(1).val():"")
					+";"+($(".input_portalBanner_link").length>2?$(".input_portalBanner_link").eq(2).val():""));
			formData.append("ContentsBannerLink", $(".input_ContentsBanner_link").eq(0).val()
					+";"+($(".input_ContentsBanner_link").length>1?$(".input_ContentsBanner_link").eq(1).val():"")
					+";"+($(".input_ContentsBanner_link").length>2?$(".input_ContentsBanner_link").eq(2).val():""));

			$.ajax({
				type: "POST",
				data: formData,
				processData: false,
				contentType: false,
				url: "/covicore/manage/domain/saveCompanyDesign.do",
				success: function(data){
					if(data.status == "SUCCESS"){
						Common.Inform("<spring:message code='Cache.msg_apv_331'/>", "Information");
					}else{
						Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생했습니다.
					}
				},
				error: function(response, status, error){
				     CFN_ErrorAjax("/covicore/domain/addInfo.do", response, status, error);
				}
			});
		},
		loadTemplate:function(){
			$.ajax({
				type: "POST",
				url: "/covicore/manage/domain/loadTemplate.do",
				success: function(data){
					if(data.status == "SUCCESS"){
						var g_editorBody = data.vacationPolicy;
						coviEditor.setBody(g_editorKind, 'tbContentElement', g_editorBody);
					}else{
						Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생했습니다.
					}
				},
				error: function(response, status, error){
				     CFN_ErrorAjax("/covicore/domain/addInfo.do", response, status, error);
				}
			});
		},
		saveCompanyVac:function(){
			var data= {
					"DomainID": $("#hid_domainID").val(),
					"DomainCode" : $("#txt_domainCode").text(),
					"VacationPolicy" : coviEditor.getBody(g_editorKind, 'tbContentElement'),
					"bodyInlineImage":    encodeURIComponent(coviEditor.getImages(g_editorKind, 'tbContentElement')),
					"bodyBackgroundImage":encodeURIComponent(coviEditor.getBackgroundImage(g_editorKind, 'tbContentElement')),
					"body":encodeURIComponent(coviEditor.getBody(g_editorKind, 'tbContentElement'))
				};
			
			$.ajax({
				type:"POST",
		    	data: 	data,
				url: "/covicore/manage/domain/saveCompanyVac.do",
				success: function(data){
					if(data.status == "SUCCESS"){
						Common.Inform("<spring:message code='Cache.msg_apv_331'/>", "Information", function(result){ // 저장되었습니다.
							if(result){
								confCompany.setData();
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
		},
		addRow:function(){
			var bannerRowLen = $("#tbl_potalBanner tbody tr").length;
			if(bannerRowLen == 4){
				Common.Inform("<spring:message code='Cache.msg_canRegisterPortalBanners'/>"); // 포탈 배너는 3개까지 등록 가능합니다.
			}else{
				$('#tbl_potalBanner tbody tr:last').after($('#tbl_potalBanner tbody tr:eq(1)').clone(true));
				$('#tbl_potalBanner tbody tr:last').find("input[type='file']").val("");
				$('#tbl_potalBanner tbody tr:last').find("#input_portalBanner_link").val("");
				$('#tbl_potalBanner tbody tr:last').find("img").attr("src", "");
				
				$('#tbl_potalBanner tbody tr:last').find(".designImgAdd").removeClass("imgY");
				$('#tbl_potalBanner tbody tr:last').find(".fileSelect").show();
				$('#tbl_potalBanner tbody tr:last').find("img").hide();
				$('#tbl_potalBanner tbody tr:last').find(".btn_del").hide();
				$('#tbl_potalBanner tbody tr:last').find("#hid_portalBannerPath").val("");
			}
		},
		addCtnBnrRow:function(){
			var bannerRowLen = $("#tbl_ContentsBanner tbody tr").length;
			if(bannerRowLen == 4){
				Common.Inform("컨텐츠 배너는 3개까지 등록 가능합니다."); // 포탈 배너는 3개까지 등록 가능합니다.
			}else{
				$('#tbl_ContentsBanner tbody tr:last').after($('#tbl_ContentsBanner tbody tr:eq(1)').clone(true));
				$('#tbl_ContentsBanner tbody tr:last').find("input[type='file']").val("");
				$('#tbl_ContentsBanner tbody tr:last').find("#input_ContentsBanner_link").val("");
				$('#tbl_ContentsBanner tbody tr:last').find("img").attr("src", "");
				
				$('#tbl_ContentsBanner tbody tr:last').find(".designImgAdd").removeClass("imgY");
				$('#tbl_ContentsBanner tbody tr:last').find(".fileSelect").show();
				$('#tbl_ContentsBanner tbody tr:last').find("img").hide();
				$('#tbl_ContentsBanner tbody tr:last').find(".btn_del").hide();
				$('#tbl_ContentsBanner tbody tr:last').find("#hid_ContentsBannerPath").val("");
			}
		},
		removeAllRow: function(){
			var bannerRowLen = $("#tbl_potalBanner tbody tr").length;
//			var bannerRowLen = $("#tbl_potalBanner .tr_potalBanner").length;
			for (var i=bannerRowLen; i>2; i--){
				$('#tbl_potalBanner tbody tr:last').remove();
			}

			$('#tbl_potalBanner tbody tr:last').find("input[type='file']").val("");
			$('#tbl_potalBanner tbody tr:last').find("#input_portalBanner_link").val("");
			$('#tbl_potalBanner tbody tr:last').find("img").removeAttr("onerror");
			$('#tbl_potalBanner tbody tr:last').find("img").attr("src", "");
			$('#tbl_potalBanner tbody tr:last').find("img").attr("style", "display:none");
			$('#tbl_potalBanner tbody tr:last').find("#hid_portalBannerPath").val("");
			
			$('#tbl_potalBanner tbody tr:last').find(".designImgAdd").removeClass("imgY");
			$('#tbl_potalBanner tbody tr:last').find(".fileSelect").show();
			$('#tbl_potalBanner tbody tr:last').find(".btn_del").hide();
			
		},
		removeAllCtnBnrRow: function(){
			var bannerRowLen = $("#tbl_ContentsBanner tbody tr").length;
//			var bannerRowLen = $("#tbl_potalBanner .tr_potalBanner").length;
			for (var i=bannerRowLen; i>2; i--){
				$('#tbl_ContentsBanner tbody tr:last').remove();
			}

			$('#tbl_ContentsBanner tbody tr:last').find("input[type='file']").val("");
			$('#tbl_ContentsBanner tbody tr:last').find("#input_ContentsBanner_link").val("");
			$('#tbl_ContentsBanner tbody tr:last').find("img").removeAttr("onerror");
			$('#tbl_ContentsBanner tbody tr:last').find("img").attr("src", "");
			$('#tbl_ContentsBanner tbody tr:last').find("img").attr("style", "display:none");
			$('#tbl_ContentsBanner tbody tr:last').find("#hid_ContentsBannerPath").val("");
			
			$('#tbl_ContentsBanner tbody tr:last').find(".designImgAdd").removeClass("imgY");
			$('#tbl_ContentsBanner tbody tr:last').find(".fileSelect").show();
			$('#tbl_ContentsBanner tbody tr:last').find(".btn_del").hide();
			
		},
		readURL:function(imgObj, input) {
			if (input.files && input.files[0]) {
				var reader = new FileReader(); //파일을 읽기 위한 FileReader객체 생성
				reader.onload = function (e) {
					//파일 읽어들이기를 성공했을때 호출되는 이벤트 핸들러
					imgObj.attr("onerror", "coviCtrl.imgError(this);")
			        imgObj.attr("src", e.target.result);
			        //이미지 Tag의 SRC속성에 읽어들인 File내용을 지정
			        //(아래 코드에서 읽어들인 dataURL형식)
			    }                   
			    reader.readAsDataURL(input.files[0]);
			    //File내용을 읽어 dataURL형식의 문자열로 저장
			}
		},
		chkValidation:function (){
			if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
			if($("#input_companyName").val() == undefined || $("#input_companyName").val() == ""){
				Common.Warning("<spring:message code='Cache.msg_EnterCompName'/>", "Warning", function(){ $("#input_companyName").focus(); }); // 회사명을 입력하세요.
				return false;
			// 회사명 특수기호 체크.
			}else if(!confCompany.symbolCheck($("#input_companyName").val())) {
				return false;
			}else if(isSaaS != "N") {
				if($("#input_repName").val() == undefined || $("#input_repName").val() == ""){
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
					Common.Warning("<spring:message code='Cache.msg_EnterChargeName'/>", "Warning", function(){ $("#input_adminName").focus(); }); //담당자명을 입력하세요.
					return false;
				}else if($("#input_adminContact").val() == undefined || $("#input_adminContact").val() == ""){
					Common.Warning("<spring:message code='Cache.msg_EnterChargeContact'/>", "Warning", function(){ $("#input_adminContact").focus(); }); //담당자 연락처를 입력하세요.
					return false;
				}else{
					return true;
				}
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
		
		, removeLicenseCache:function (){
			Common.Confirm("<spring:message code='Cache.msg_RemoveLicenseCache'/>", "<spring:message code='Cache.lbl_RemoveLicenseCache'/>", function(result){
				var removeMailCache;
				
				if(result){
					removeMailCache = "Y";
				}else{
					removeMailCache = "N";
				}
				
				$.ajax({
					type: "post"
					, url: "/groupware/control/removeLicenseCache.do"
					, data: {
						"domainID": confMenu.domainId,
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
		
		// 다국어 콜백함수.
		, callbackMultiLangPopup : function(data) {
			if (!confCompany.symbolCheck(data.KoFull)) {}
			
			var multiLangName = '';
			multiLangName += confCompany.symbolChange(data.KoFull) + ';';
			multiLangName += confCompany.symbolChange(data.EnFull) + ';';
			multiLangName += confCompany.symbolChange(data.JaFull) + ';';
			multiLangName += confCompany.symbolChange(data.ZhFull) + ';';
			multiLangName += confCompany.symbolChange(data.Lang1Full) + ';';
			multiLangName += confCompany.symbolChange(data.Lang2Full) + ';';
			multiLangName += confCompany.symbolChange(data.Lang3Full) + ';';
			multiLangName += confCompany.symbolChange(data.Lang4Full) + ';';
			multiLangName += confCompany.symbolChange(data.Lang5Full) + ';';
			multiLangName += confCompany.symbolChange(data.Lang6Full) + ';';
			
			$("#hid_multiName").val(encodeURIComponent(multiLangName));
			$("#input_companyName").val(confCompany.symbolChange(data.KoFull));
		}
		
		// 다국어의 특수기호 체크.
		, symbolCheck : function(param) {
			if ( regExp.test(param) ) { 	// 정규표현식으로 특수문자 검색.
				var sMessage = String.format("<spring:message code='Cache.msg_DictionaryInfo_01' />", "&apos; &quot; ;") ; // 특수문자 [' " ;]는 사용할 수 없습니다.
				Common.Warning(sMessage, 'Warning Dialog', function () {});
				return false;	
			} else {
				return true;
			}
		}
		
		// 특수기호 변경처리.
		, symbolChange : function(strParam) {
			strParam = strParam.replaceAll(regExp,"");
			return strParam;
		}
	}
	
	// 내부 함수로 연결.
	function callbackMultiLangPopup(data) {
		confCompany.callbackMultiLangPopup(data);
	}
	function symbolCheck(param) {
		confCompany.symbolCheck(param);
	}
	function symbolChange(strParam) {
		confCompany.symbolChange(strParam);
	}

	

	$(document).ready(function(){
		confCompany.initContent();
	});
	
</script>