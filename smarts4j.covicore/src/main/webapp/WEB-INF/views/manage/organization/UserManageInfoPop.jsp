<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<% 
	String Editable = (String)request.getAttribute("Editable"); 
%>
<style>
	/* div padding */
	.width36 {
		width: 36% !important;
	} 
	.sadmin_pop table.sadmin_table .ipselect { width:calc(100% - 65px); margin-right:5px;}
</style>
<body> 
	<div class="sadmin_pop">
		<ul class="tabMenu clearFloat">
			<li class="active"><a id="userDefaultSetTab" onclick="clickTab(this);" value="divUserDefault"><spring:message code='Cache.lbl_SettingDefault' /></a><!-- 기본 설정 --></li>
			<li class=""><a id="userADSetTab" style="display:none" onclick="clickTab(this);"  value="divUserAD"><spring:message code='Cache.lbl_SetAD' /></a><!-- AD 설정 --></li>
			<li class=""><a id="userApprovalSetTab" style="display:none" onclick="clickTab(this);"  value="divUserApproval"><spring:message code='Cache.lbl_SetApproval' /></a><!-- 결재 설정 --></li>
			<li class=""><a id="userAddSetTab" style="display:none" onclick="clickTab(this);"  value="divUserAdd"><spring:message code='Cache.lbl_SettingOption' /></a>	<!-- 부가 설정 --></li>
		</ul>

		<!-- 기본 설정 탭 시작 -->
		<div class="tabContent active" id='divUserDefault'>
			<table class="sadmin_table sa_userBasicSetting">
				<colgroup>
					<col width="120px;">
					<col width="110px">
					<col width="*">
					<col width="110px;">
					<col width="*">
				</colgroup>
				<tbody>
					<tr>
						<td rowspan="6" class="userPhoto">
							<input type="file" name="addFile" size="15" style="display: none" onchange="changeUserImage(this);">
							<input type="text" id="txtImagePath" style="display: none;">
							<img id="userThumbnail">
							<a href="javascript:void(0);" value="" class="btnTypeDefault" id="btnUserImage" onclick="clickUserImage(this);"><spring:message code="Cache.lbl_ChangePhoto"/></a>
						</td>
						<th><span class="thstar">*</span><spring:message code="Cache.lbl_User_Id" /></th><!-- 사용자ID -->
						<td>
							<div style="padding-bottom:5px;display:none"><label id="txtPfx"></label></br></div>
							<input class="inputcheck" type="text" id="txtUserCode" onchange="fnAutoInputProperty(this, 'UserCode');"><a href="javascript:void(0);" class="btnTypeDefault" onclick="return checkDuplicate(this);" id="btnIsDuplicate_code"><spring:message code="Cache.lbl_DuplicateCheck2"/></a>
						</td>
						<th><span class="thstar">*</span><spring:message code="Cache.lblUserCode" /></th>
						<td>
							<input class="inputcheck" type="text"  id="txtUserEmpNo"><a href="javascript:void(0);" class="btnTypeDefault" onclick="return checkDuplicate(this);" id="btnIsDuplicate_empno"><spring:message code="Cache.lbl_DuplicateCheck2"/></a>
							<input type="hidden" id="hidtxtUserEmpNo" style="display: none;">
						</td>
					</tr>
					<tr name="trSaasN" style="display:none">
						<th><span class="thstar">*</span>LogonID</th>
						<td colspan="3">
							<input class="inputcheck" type="text" id="txtLogonID" onchange="fnAutoInputProperty(this, 'LogonID');"><a href="javascript:void(0);" class="btnTypeDefault" onclick="return checkDuplicate(this);" id="btnIsDuplicateLogonID"><spring:message code="Cache.lbl_DuplicateCheck2"/></a>
						</td>
					</tr>
					<tr name="trSaasY">
						<th><span class="thstar">*</span>LogonID</th>
						<td colspan="3">
							<input class="inputcheck width36" type="text" id="txtLogonIDSaaS"><label>@</label>
							<select	id="selMailDomainSaaS" name="selMailDomain" class='width36'>
								<option value="" selected><spring:message code="Cache.lbl_Select" /></option>
							</select>
							<a href="javascript:void(0);" class="btnTypeDefault" onclick="return checkDuplicate(this);" id="btnIsDuplicateLogonIDSaaS"><spring:message code="Cache.lbl_DuplicateCheck2"/></a>
						</td>
					</tr>
					
					<tr id="trName"  style="display:none">
						<th><span class="thstar">*</span><spring:message code="Cache.lbl_LastName" /></th>
						<td>
							<input type="text" id="txtLastName" onchange="javascript:fn_AutoNameInput();">
						</td>
						<th><span class="thstar">*</span><spring:message code="Cache.lbl_FirstName" /></th>
						<td>
							<input type="text" id="txtFirstName" onchange="javascript:fn_AutoNameInput();">
						</td>
					</tr>
					<tr>
						<th><span class="thstar">*</span><spring:message code="Cache.lbl_User_DisplayName" /></th>
						<td>
							<input class="userName" type="text" id="txtUserDisplayName"onclick="dictionaryLayerPopup('true', 'txtUserDisplayName');"><a href="javascript:void(0);" class="btnTypeDefault" onclick="dictionaryLayerPopup('true', 'txtUserDisplayName');"><spring:message code="Cache.lbl__DicModify"/></a>
						</td>
						<th><spring:message code="Cache.lbl_SmartDateofBirth" /></th>
						<td>
							<div class="radioStyle05">
								<input type="radio" name="rdoSolarLunar" value="S" id="rdoSolar"><label for="rdoSolar"><spring:message code="Cache.lbl_Solar" /></label>
							</div>
							<div class="radioStyle05">
								<input type="radio" name="rdoSolarLunar" value="L" id="rdoLunar"><label for="rdoLunar"><spring:message code="Cache.lbl_Lunar" /></label>
							</div>
							<div class="dateSel type02 birth">
								<input class="adDate" type="text" id="txtDateofBirth" date_separator="-" kind="date" data-axbind="date">
							</div>
						</td> 
					</tr>
					<tr>
						<th><span class="thstar">*</span><spring:message code="Cache.lbl_Password" /></th>
						<td><input type="password" id="txtPassword" autocomplete="new-password"></td>
						<th><span class="thstar">*</span><spring:message code="Cache.lbl_ConfirmPassword" /></th>
						<td><input type="password" id="txtConfirmPassword"></td>
					</tr>
					<tr>
						<th name="licArea"style="display:none"><span class="thstar">*</span><spring:message code="Cache.lbl_license" /></th>
						<td name="licArea"style="display:none">
							<select id="selLicSeq" class="selectType02" name="selLicSeq" onchange="fnLicSeq()">
							</select>
						</td>
						<th id="thIndiMailUse"><span class="thstar">*</span><spring:message code="Cache.lbl_IsMail" /></th>
						<td id="tdIndiMailUse">
							<select id="selIsCPMail" class="selectType02" name="selIsCPMail" onchange="fnCPMailUse()">
								<option value="Y" selected="selected"><spring:message code="Cache.lbl_Use" /></option>
								<option value="N"><spring:message code="Cache.lbl_noUse" /></option>
							</select>
							<input type="text" id="hidtxtUseMailConnect" style="display: none;">
						</td>
					</tr>
				</tbody>
			</table>

			<table class="sadmin_table sa_userMail">
				<colgroup>
					<col width="110px;">
					<col width="*">
				</colgroup>
				<tbody>
					<tr name="trMailAddress">
						<th><span class="thstar">*</span><spring:message code="Cache.lbl_MAIL"/></th>
						<td>
							<input class="inputcheck" type="text" id="txtMailID">
							<input type="text" id="hidtxtMailID" style="display: none;">
							@
							<select class="selectType02" id="selMailDomain" name="selMailDomain">
								<option value="" selected><spring:message code="Cache.lbl_Select" /></option>
							</select>
							<a href="javascript:void(0);" class="btnTypeDefault" onclick="checkDuplicateMail(_mode, 'User');" id="btnIsDuplicateMail"><spring:message code="Cache.lbl_DuplicateCheck2"/></a>
						</td>
					</tr>
					<tr>
						<th><spring:message code='Cache.lbl_extmail' />
							<div class="collabo_help02">
								<a href="javascript:void(0);" class="help_ico"></a>
								<div class="helppopup" style="width:300px;">
									<spring:message code="Cache.lbl_DescDxternalMail" /> 
								</div>
							</div>
						</th>
						<td>
							<input type="text" id="txtExtMail" class="HtmlCheckXSS ScriptCheckXSS">
							@
							<input type="text" id="txtExtMailDomain" class="HtmlCheckXSS ScriptCheckXSS">
						</td>
					</tr>
				</tbody>
			</table>

			<table class="sadmin_table sa_userBasicSetting2">
				<colgroup>
					<col width="110px;">
					<col width="*">
					<col width="110px">
					<col width="*">
					<col width="120px;">
					<col width="*">
				</colgroup>
				<tbody>
					<tr>
						<th><span class="thstar">*</span><spring:message code="Cache.lbl_CompanyName" /></th>
						<td>
							<input type="text" id="txtCompanyName"readonly="readonly"> 
							<input type="text" id="hidCompanyCode" style="display: none;">
							<input type="hidden" id= "hidOldCompanyCode" />
						</td>
						<th><span class="thstar">*</span><spring:message code="Cache.lbl_dept" /></th>
						<td>
							<input class="ipselect" type="text" id="txtDeptName" readonly="readonly"><a href="javascript:void(0);" class="btnTypeDefault" onclick="OrgMap_Open('dept', 'UserDept', 'hidDeptCode');"><spring:message code="Cache.btn_Select"/></a>
							<input type="text" id="hidDeptCode" style="display: none;"> 
							<input type="hidden" id= "hidOldGroupCode" />
						</td>
						<th><spring:message code="Cache.lbl_EnterDate" /></th>
						<td>
							<div class="dateSel type02">
								<input class="adDate" type="text" id="txtEnterDate" date_separator="-" kind="date" data-axbind="date" >
							</div>
						</td>
					</tr>
					<tr>
						<th><spring:message code="Cache.lbl_JobTitle" /></th>
						<td>
							<select class="selectType02" id="selJobTitle" name="selJobTitle">
								<option value="" selected><spring:message code="Cache.lbl_Select" /></option>
							</select>
							<input type="text" id="hidselJobTitle" style="display: none;">
						</td>
						<th><spring:message code="Cache.lbl_JobPosition" /></th>
						<td>
							<select class="selectType02"id="selJobPosition" name="selJobPosition">
								<option value="" selected><spring:message code="Cache.lbl_Select" /></option>
							</select>
							<input type="text" id="hidselJobPosition" style="display: none;">
						</td>
						<th><spring:message code="Cache.lbl_JobLevel" /></th>
						<td>
							<select class="selectType02"id="selJobLevel" name="selJobLevel">
								<option value="" selected><spring:message code="Cache.lbl_Select" /></option>
							</select>
							<input type="text" id="hidselJobLevel" style="display: none;">
						</td>
					</tr>
					<tr>
						<th><span class="thstar">*</span><spring:message code="Cache.lbl_IsUse" /></th>
						<td>
							<select class="selectType02" id="selIsUse" name="selIsUse">
								<option value="Y" selected="selected"><spring:message code="Cache.lbl_Use" /></option>
								<option value="N"><spring:message code="Cache.lbl_noUse" /></option>
							</select>
						</td>
						<th><span class="thstar">*</span><spring:message code="Cache.lbl_IsHR" /></th>
						<td>
							<select class="selectType02" id="selIsHR" name="selIsHR">
								<option value="Y"><spring:message code="Cache.lbl_Use" /></option>
								<option value="N" selected="selected"><spring:message code="Cache.lbl_noUse" /></option>
							</select>
						</td>
						<th><span class="thstar">*</span><spring:message code="Cache.lbl_SetDisplay" /></th>
						<td>
							<select class="selectType02" id="selIsDisplay" name="selIsDisplay">
								<option value="Y" selected="selected"><spring:message code="Cache.lbl_DisplayPermit" /></option>
								<option value="N"><spring:message code="Cache.lbl_DisplayInhibition" /></option>
							</select>
						</td>
					</tr>
					<tr>
						<th><span class="thstar">*</span><spring:message code="Cache.lbl_PriorityOrder" /></th>
						<td>
							<input type="text" id="txtPriorityOrder" onkeyup='writeNum(this);'>
						<th><spring:message code="Cache.lbl_MobilePhone" /></th>
						<td>
							<input type="text" id="txtMobilePhoneNum">
						</td>
						<th><spring:message code="Cache.lbl_MyInfo_13" /></th>
						<td>
							<input type="text" id="txtPhoneNumInter">
						</td>
					</tr>
					<tr>
						<th><spring:message code="Cache.lbl_RetireDate" /></th>
						<td>
							<div class="dateSel type02">
								<input class="adDate" type="text" id="txtRetireDate" date_separator="-" kind="date" data-axbind="date">
							</div>
						</td>
						<th><spring:message code="Cache.lblHomeCall" /></th>
						<td>
							<input type="text" id="txtHomePhoneNum">
						</td>
						<th><spring:message code="Cache.lbl_PhoneNum" /></th>
						<td>
							<input type="text" id="txtPhoneNum">
						</td>
					</tr>

					<tr>
						<th><spring:message code="Cache.lbl_Office_Fax" /></th>
						<td><input type="text" id="txtFaxNum"></td>
						<th><span class="thstar">*</span><spring:message code="Cache.lbl_SecurityLevel" /> </th>
						<td>
							<select class="selectType02" id="selSecurityLevel" name="selSecurityLevel">
								<option value="" selected><spring:message code="Cache.lbl_Select" /></option>
							</select></td>
						<th><spring:message code="Cache.lbl_PlaceOfBusiness" /></th>
						<td>
							<input class="ipselect" type="text" id="txtPlaceOfBusiness" readonly="readonly"><a href="javascript:void(0);" class="btnTypeDefault" onclick="PlaceOfBusiness_Open();"><spring:message code="Cache.lbl_Select" /></a>
							<input type="text" id="hidPlaceOfBusiness" style="display: none;"> 
						</td>
					</tr>
					<tr>
						<th id="thRole"><spring:message code='Cache.lbl_Role'/></th>
						<td id="tdRole" colspan="3"><input type="text" id="txtChargeBusiness"></td>
						<th id="thIsCRM" style="display:none"><span class="thstar">*</span><spring:message code='Cache.lbl_IsCRM'/></th> <!--CRM 사용여부-->
						<td id="tdIsCRM" style="display:none">
							<select class="selectType02" id="selIsCRM" name="selIsCRM">
								<option value="Y"><spring:message code="Cache.lbl_Use" /></option>
								<option value="N" selected="selected"><spring:message code="Cache.lbl_noUse" /></option>
							</select>
						</td>
						<th><span class="thstar">*</span><spring:message code='Cache.lbl_IsMSG' /></th>
						<td>
							<select class="selectType02" id="selIsEUM" name="selIsEUM">
								<option value="Y" selected="selected"><spring:message code="Cache.lbl_Use" /></option>
								<option value="N"><spring:message code="Cache.lbl_noUse" /></option>
							</select>
						</td>
					</tr>
					<tr id="trIPSetting">
						<th><spring:message code='Cache.lbl_IPAddress'/></th> <!--IP 주소 -->
						<td colspan="5">
							<span>
								&nbsp;<input type="checkbox" id="chkUserIPAddress" name="chkUserIPAddress" onchange="chkUserIPAddress_Changed(this); return false;">
								<label for="chkUserIPAddress" ><spring:message code='Cache.lbl_Use'/></label>
							</span>
							&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="text" id="txtStartIP" name="txtStartIP" class='width36' readonly="readonly">&nbsp;&nbsp;~&nbsp;&nbsp;<input type="text" id="txtEndIP" name="txtEndIP" class='width36'readonly="readonly">
						</td>
					</tr>
				</tbody>
			</table>
		</div>
		<!-- 기본 설정 탭 끝 -->

		<!-- 부가 설정 탭 시작 -->
		
		<div class="tabContent" id="divUserAD">
			<p style="font-size: 14px; color: #777676; margin: 15px 0px 5px;">
				<strong>ㆍ <spring:message code="Cache.lbl_selUse" /></strong>
			</p>
			<table class="sadmin_table sa_userBasicSetting2">
				<colgroup>
					<col style="width: 13%;"/>
					<col/>
					<col style="width: 13%;"/>
					<col/>
					<col style="width: 14%;"/>
					<col/>
				</colgroup>
				<tr>
					<th rowspan="3"><span class="thstar">*</span><spring:message code='Cache.lbl_IsUseAD' /></th>
					<td>
						<select class="selectType02" id="selIsAD" name="selIsAD" onchange="selIsAD_Changed();">
							<option value="Y"><spring:message code="Cache.lbl_Use" /></option>
							<option value="N" selected="selected"><spring:message code="Cache.lbl_noUse" /></option>
						</select>
					</td>
					<th rowspan="3"><span class="thstar">*</span><spring:message code='Cache.lbl_IsMail' /></th>
					<td>  
						<select id="selIsMail" name="selIsMail" class="selectType02" onchange="selIsMail_Changed();">
							<option value="Y"><spring:message code="Cache.lbl_Use" /></option>
							<option value="N" selected="selected"><spring:message code="Cache.lbl_noUse" /></option>
						</select>
					</td>
					<th style="display:none"rowspan="3"><span class="thstar">*</span><spring:message code='Cache.lbl_IsMSG' /></th>
					<td style="display:none"><select id="selIsMSG" name="selIsMSG" class="selectType02" onchange="selIsMSG_Changed();">
							<option value="Y"><spring:message code="Cache.lbl_Use" /></option>
							<option value="N" selected="selected"><spring:message code="Cache.lbl_noUse" /></option>
						</select>
					</td>
				</tr>
			</table>
			<br />
			<p name="ADAccountArea" style="font-size: 14px; color: #777676; margin: 15px 0px 5px;">
				<strong>ㆍ AD Account</strong>
			</p>
			<table name="ADAccountArea" class="sadmin_table">
				<colgroup>
					<col style="width: 13%;"/>
					<col/>
				</colgroup>
				<tr>
					<th rowspan="3"><span class="thstar">*</span>CN</th>
					<td>
						<input type="text" class="HtmlCheckXSS ScriptCheckXSS" id="txtAD_CN" style="width:100%;" />
					</td>
					<th rowspan="3"><span class="thstar">*</span>sAMAccountName</th>
					<td>
						<input type="text" class="HtmlCheckXSS ScriptCheckXSS" id="txtAD_SamAccountName" style="width:100%;" />
					</td>
					<th rowspan="3"><span class="thstar">*</span>UserPrincipalName</th>
					<td>
						<input type="text" class="HtmlCheckXSS ScriptCheckXSS" id="txtAD_UserPrincipalName" style="width:100%;" />
					</td>
					<th rowspan="3"><span class="thstar">*</span><spring:message code="Cache.lblAdminSetting" /></th>
					<td>
						<input type="text" id="txtAdminSettingName"readonly="readonly" class="ipselect"><a href="javascript:void(0);" class="btnTypeDefault" onclick="OrgMap_Open('user', 'AdminSetting', 'hidAdminSettingCode');"><spring:message code="Cache.lbl_Select" /></a>
						<input type="text" id="hidAdminSettingCode" style="display: none;">
					</td>
				</tr>
				<tr>
				</tr>
			</table>
			<br />
			<p name="MailArea" style="font-size: 14px; color: #777676; margin: 15px 0px 5px;">
				<strong>ㆍ <spring:message code="Cache.lbl_Mail" /></strong>
			</p>
			<table name="MailArea" class="sadmin_table">
				<colgroup>
					<col style="width: 13%;"/>
					<col/>
				</colgroup>
				<tr>
					<th rowspan="3"><span class="thstar">*</span><spring:message code='Cache.lbl_Mail_Address' /></th>
					<td>
						<div id="topitembar_2" class="">
							<label> 
								<input type="button" value="<spring:message code="Cache.btn_Add"/>" onclick="btnMailAdd_OnClick();" class="btnTypeDefault" /> <!-- 추가 -->
								<input type="button" value="<spring:message code="Cache.btn_delete"/>" onclick="btnMailDel_OnClick();" class="btnTypeDefault" /> <!-- 삭제 --> 
								<input type="button" value="▲ <spring:message code="Cache.btn_UP"/>" onclick="btnMailUp_OnClick();" class="btnTypeDefault" /> <!-- 위로 --> 
								<input type="button" value="▼ <spring:message code="Cache.btn_Down"/>" onclick="btnMailDown_OnClick();" class="btnTypeDefault" /> <!-- 아래로 --> 
								<input type="button" value="<spring:message code="Cache.lbl_User_Custom_Attribute"/>" onclick="btnMailAttributeAdd_OnClick();" class="btnTypeDefault" /> <!-- 사용자지정 특성추가 -->
								<input type="hidden" ID="hidAD_DisplayName" />
								<input type="hidden" ID="hidMailAttribute" />
								<input type="hidden" ID="hidMailAttribute1" />
								<input type="hidden" ID="hidMailAttribute2" />
								<input type="hidden" ID="hidMailAttribute3" />
								<input type="hidden" ID="hidMailAttribute4" />
								<input type="hidden" ID="hidMailAttribute5" />
								<input type="hidden" ID="hidMailAttribute6" />
								<input type="hidden" ID="hidMailAttribute7" />
								<input type="hidden" ID="hidMailAttribute8" />
								<input type="hidden" ID="hidMailAttribute9" />
								<input type="hidden" ID="hidMailAttribute10" />
								<input type="hidden" ID="hidMailAttribute11" />
								<input type="hidden" ID="hidMailAttribute12" />
								<input type="hidden" ID="hidMailAttribute13" />
								<input type="hidden" ID="hidMailAttribute14" />
								<input type="hidden" ID="hidMailAttribute15" />
							</label>
							<input type="hidden" ID="hidMailAddressInfo" />
						</div>
						<div id="divAttributeList" class="" style="height: 85px;overflow-y: scroll;"></div>
					</td>
				</tr>
				<tr>
				</tr>
				<tr>
				</tr>
				<tr>
					<th><span class="thstar">*</span><spring:message code='Cache.lbl_MailBoxServer' /></th>
					<td>
						<select id="selMailBoxServer" name="selMailBoxServer" class="selectType02" style="width: 95%;">
							<option value="" selected><spring:message code="Cache.lbl_Select" /></option>
						</select>
					</td>
				</tr>
			</table>
			<br />
			<p name="MessengerArea" style="font-size: 14px; color: #777676; margin: 15px 0px 5px;">
				<strong>ㆍ <spring:message code="Cache.lbl_Messenger" /></strong>
			</p>
			<table name="MessengerArea" class="sadmin_table">
				<colgroup>
					<col style="width: 13%;"/>
					<col/>
					<col style="width: 13%;"/>
					<col/>
				</colgroup>
				<tr>
					<th><span class="thstar">*</span><spring:message code='Cache.lbl_SIPAddress' /></th>
					<td colspan="3">
						<label> 
							<input type="text" id="txtSIPAddress" class="HtmlCheckXSS ScriptCheckXSS width36"> @ 
							<select id="selMailList" name="selMailList" class="selectType02 width36">
								<option value="" selected><spring:message code="Cache.lbl_Select" /></option>
							</select>
						</label>
					</td>
				</tr>
				<tr>
					<th><span class="thstar">*</span><spring:message code='Cache.lbl_TelephonyOptions' /></th>
					<td>
						<select id="selTelephonyOptions" name="selTelephonyOptions" class="selectType02" style="width: 90%;">
							<option value="" selected><spring:message code="Cache.lbl_Select" /></option>
						</select>
					</td>
					<th><span class="thstar">*</span><spring:message code='Cache.lbl_ServiceType' /></th>
					<td>
						<select id="selServiceType" name="selServiceType" class="selectType02" style="width: 90%;">
							<option value="" selected><spring:message code="Cache.lbl_Select" /></option>
						</select>
					</td>
				</tr>
			</table>
		</div>
		<div class="tabContent" id="divUserApproval">
			<table id="tblUserApproval " class="sadmin_table sa_userBasicSetting2" style="margin-top: 15px;">
				<colgroup>
					<col style="width: 15%;"/>
					<col/>
					<col style="width: 15%;"/>
					<col/>
				</colgroup>
				<tr>
					<th><spring:message code='Cache.lbl_ApprovalDept' /></th>
					<td>
						<input type="text" id="txtApprovalDeptName" class="ipselect" readonly="readonly"> 
						<input type="text" id="hidApprovalDeptCode" style="display: none;">
						<input type="button" class="btnTypeDefault"	value="<spring:message code="Cache.btn_Select"/>"	onclick="OrgMap_Open('dept', 'ApprovalDept', 'hidApprovalDeptCode');"	style="min-width: 20px;">
					</td>
					<th><spring:message code='Cache.lbl_ReceiptDept' /></th>
					<td>
						<input type="text" id="txtReceiptDeptName" class="ipselect" readonly="readonly"> 
						<input type="text" id="hidReceiptDeptCode" style="display: none;">
						<input type="button" class="btnTypeDefault"	value="<spring:message code="Cache.btn_Select"/>" onclick="OrgMap_Open('dept', 'ReceiptDept', 'hidReceiptDeptCode');" style="min-width: 20px;">
					</td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_IsDeputy' /></th>
					<td>
						<select id="selIsDeputy" name="selIsDeputy"	class="selectType02"onchange="selIsDeputy_Changed(this);"> 
							<option value="" selected><spring:message	code="Cache.lbl_Select" /></option>
							<option value="Y"><spring:message code="Cache.lbl_Use" /></option>
							<option value="N"><spring:message code="Cache.lbl_noUse" /></option>
						</select>
					</td>
					<th name="DeputyApprovalInfo"><spring:message code='Cache.lbl_DeputyApproval' /></th>
					<td name="DeputyApprovalInfo">
						<input type="text" id="txtDeputyApprovalName" class="ipselect" readonly="readonly"> 
						<input type="text" 	id="hidDeputyApprovalCode" style="display: none;">
						<input type="button"id="btnDeputyApprovalUser" class="btnTypeDefault" value="<spring:message code="Cache.btn_Select"/>" onclick="OrgMap_Open('user', 'DeputyApproval');"	style="min-width: 20px;">
					</td>
				</tr>
				<tr name="DeputyApprovalInfo">
					<th><spring:message code='Cache.lbl_Option' /></th>
					<td>
						<div class="radioStyle05">
							<input type="radio" name="rdoDeputyOption" value="Y" id="rdoDeputyOption_Y" onchange="optDeputyOption_Changed()"><label for="rdoDeputyOption_Y"><spring:message code="Cache.lbl_apv_DeputyOption_Y" /></label>
						</div>
						<div class="radioStyle05">
							<input type="radio" name="rdoDeputyOption" value="P" id="rdoDeputyOption_P" onchange="optDeputyOption_Changed()"><label for="rdoDeputyOption_P"><spring:message code="Cache.lbl_apv_DeputyOption_P" /></label>
						</div>
						
					</td>
				</tr>
				<tr name="DeputyApprovalInfo">
					<th><spring:message code='Cache.lbl_DeputyDate' /></th>
					<td>
						<input type="text" id="txtDeputyDateStart"	class="adDate ml5" date_separator="-" kind="date"data-axbind="date" vali_early="true" vali_date_id="txtDeputyDateEnd" style="width: 40%;"> ~ 
						<input type="text" id="txtDeputyDateEnd" class="adDate" date_separator="-" kind="date" data-axbind="date" vali_late="true" vali_date_id="txtDeputyDateStart" style="width: 40%;">
					</td>
					<th><spring:message code='Cache.lbl_PhoneApproval' /></th>
					<td>
						<select id="selPhoneApproval" name="selPhoneApproval" class="selectType02">
							<option value="" selected><spring:message code="Cache.lbl_Select" /></option>
							<option value="Y"><spring:message code="Cache.lbl_Use" /></option>
							<option value="N"><spring:message code="Cache.lbl_noUse" /></option>
						</select>
					</td>
				</tr>
				<tr style="display:none;">
					<th><spring:message code='Cache.lbl_Complete_YN' /></th>
					<td>
						<select id="selCompleteYN" name="selCompleteYN" class="selectType02">
							<option value="" selected><spring:message code="Cache.lbl_Select" /></option>
							<option value="Y"><spring:message code="Cache.lbl_Use" /></option>
							<option value="N"><spring:message code="Cache.lbl_noUse" /></option>
						</select>
					</td>
					<th><spring:message code='Cache.lbl_ComplateApproveType' /></th>
					<td>
						<label for="chkCompleteApprovalMail" style="font-size: 13px;"> <input type="checkbox"	id="chkCompleteApprovalMail" name="chkCompleteApprovalType" value="MAIL"> <spring:message code="Cache.lbl_Mail" />	</label>
						<label for="chkCompleteApprovalSMS" style="font-size: 13px;"> <input type="checkbox" id="chkCompleteApprovalSMS" name="chkCompleteApprovalType" value="SMS"> <spring:message code="Cache.lbl_SMS" />	</label> 
						<label for="chkCompleteApprovalMessage" style="font-size: 13px;"><input type="checkbox" id="chkCompleteApprovalMessage" name="chkCompleteApprovalType" value="MESSENGER"> <spring:message code="Cache.lbl_UserProfileSendMessage" /></label>
					</td>
				</tr>
			</table>
		</div>
		<div class="tabContent" id="divUserAdd">
			<table id="tblUserAdd" class="sadmin_table sa_userBasicSetting2" style="margin-top: 15px;">
				<colgroup>
					<col style="width: 12%;">
					<col/>
					<col style="width: 12%;">
					<col/>
					<col style="width: 12%;">
					<col/>
				</colgroup>
				<tr>
					<th><spring:message code='Cache.lbl_Initials' /></th>
					<td><input type="text" id="txtInitials" class="HtmlCheckXSS ScriptCheckXSS">
					</td>
					<th><spring:message code='Cache.lbl_WebPage' /></th>
					<td><input type="text" id="txtWebPage" class="HtmlCheckXSS ScriptCheckXSS">
					</td>
				</tr>
				<tr name='ADArea' style='display:none'>
					<th><spring:message code='Cache.lbl_Country' /><span class="txt_red">*</span></th>
					<td>
						<select id="selCountry" name="selCountry" class="selectType02" style="width: 100%;">
							<option value="" selected><spring:message code="Cache.lbl_Select" /></option>
						</select>
					</td>
					<th><spring:message code='Cache.lbl_CityState_01' /></th>
					<td><input type="text" id="txtCityState_01" class="HtmlCheckXSS ScriptCheckXSS"></td>
					<th><spring:message code='Cache.lbl_CityState_02' /></th>
					<td><input type="text" id="txtCityState_02" class="HtmlCheckXSS ScriptCheckXSS"></td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_ZipCode' /></th>
					<td colspan="5"><input type="text" id="txtZipCode" class="HtmlCheckXSS ScriptCheckXSS"></td>
				</tr>
				<tr name='ADArea'  style='display:none'>
					<th><spring:message code='Cache.lbl_MailBox' /></th>
					<td colspan="5"><input type="text" id="txtMailBox" class="AXInpu HtmlCheckXSS ScriptCheckXSSt"></td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_Address' /></th>
					<td colspan="5"><input type="text" id="txtAddress"  class="HtmlCheckXSS ScriptCheckXSS" style="width: 98%;"></td>
				</tr>
				<tr name='ADArea' style='display:none'>
					<th><spring:message code='Cache.lbl_OfficeAddress' /></th>
					<td colspan="5"><input type="text" id="txtOfficeAddress" class="AXInpu HtmlCheckXSS ScriptCheckXSSt" style="width: 98%;"></td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_Role' /></th>
					<td colspan="5"><textarea id="txtRole" class="HtmlCheckXSS ScriptCheckXSS" rows="3" style="width: 98%;"></textarea></td>
				</tr>
				<!--  
				<tr>
					<th><spring:message code='Cache.lbl_Organization_Description' /></th>
					<td colspan="5"><textarea id="txtDescription" rows="3"style="width: 98%;"></textarea></td>
				</tr>
				-->
			</table>
		</div>
		<% 
		if(Editable!=null && Editable.equals("Y")){
		%>
		<div class="bottomBtnWrap">
			<a href="javascript:void(0);" id="btnSave" 		onclick="return CheckValidation();"class="btnTypeDefault btnTypeBg"><spring:message code='Cache.btn_save' /></a>
			<a href="javascript:void(0);" id="btnResetPwd" 	onclick="resetPassword();"class="btnTypeDefault" style="display:none"><spring:message code='Cache.lbl_PwdInit' /></a>
			<a href="javascript:void(0);"id="btnClose" 		onclick="closePopup();"class="btnTypeDefault"><spring:message code='Cache.btn_Close' /></a>
		</div>
		<% }%>

		<!-- 기본 설정 탭 끝 -->
	</div>
	
	<input type="text" id="UserDisplayNameHidden" value="" style="display: none;" />
	<input type="text" id="hidUserID" value="" style="display: none;" />
	<input type="hidden" id="hidReserved1" />
	<input type="hidden" id="hidReserved2" />
	<input type="hidden" id="hidReserved3" />
	<input type="hidden" id="hidReserved4" />
	<input type="hidden" id="hidReserved5" />
	<input type="hidden" id="hidAlertConfig" />	
	<input type="hidden" id="hidOldIsCPMail" />	
	
	<!--Exchange 설정 값-->
	<input type="hidden" id="hidPrimary"  />
	<input type="hidden" id="hidSecondary"  />
	<input type="hidden" id="hidEX_StorageStore"  />
	<input type="hidden" id="hidEX_StorageServer"  />
	<!--Messenger 설정 값-->
	<input type="hidden" id="hidMSN_MeetingPolicyDN"  />
	<input type="hidden" id="hidMSN_PoolServerDN"  />
	<input type="hidden" id="hidMSN_PoolServerName"  />
	<input type="hidden" id="hidMSN_Anonmy"  />
	<input type="hidden" id="hidMSN_PBX"  />
	<input type="hidden" id="hidMSN_LinePolicyName"  />
	<input type="hidden" id="hidMSN_LinePolicyDN"  />
	<input type="hidden" id="hidMSN_LineURI"  />
	<input type="hidden" id="hidMSN_LineServerURI"  />
	<input type="hidden" id="hidMSN_Federation"  />
	<input type="hidden" id="hidMSN_RemoteAccess"  />
	<input type="hidden" id="hidMSN_PublicIMConnectivity"  />
	<input type="hidden" id="hidMSN_InternalIMConversation"  />
	<input type="hidden" id="hidMSN_FederatedIMConversation"  />
	<!--AD 설정 값-->
	<input type="hidden" id="hidAD_UserAccountControl"  /><!-- Value="66048" Active Directory 계정옵션코드-->
	<input type="hidden" id="hidAD_AccountExpires" value="0" /><!--Active Directory 계정만료일-->
	<input type="hidden" id="hidAD_Pager" />
	<input type="hidden" id="hidAD_Info" />
</body>


<script type="text/javascript">

	var _userCode = "${UserCode}"; 
	var _groupCode = "${GroupCode}";
	var _domainId = "${DomainId}";
	var _mode = "${Mode}";
	var _domainCode = "${DomainCode}";
	var _userInfo = "";
	var _licSection = "Y";//Common.getSecurityProperties("license.bizsection");
	_licSection = (_licSection==="Y")?"Y":"N";
	//개별호출 일괄처리
	var lang = Common.getSession("lang");
	Common.getBaseCodeList(["MailDomain", "SecurityLevel"]);
	Common.getBaseConfigList(["IsSyncAD","IsSyncMail","IsSyncMessenger","IsSyncIndi","OrgManageUsePWPolicy","AD_CN_Mapping","AD_sAMAccountName_Mapping","AD_UserPrincipalName_Mapping","IsUseApprovalSet","IsUseCRM"]);

	var _isSyncAD = coviCmn.configMap["IsSyncAD"];
	var _isSyncMail = coviCmn.configMap["IsSyncMail"];
	var _isSyncMessenger = coviCmn.configMap["IsSyncMessenger"];
	var _isSyncIndi = coviCmn.configMap["IsSyncIndi"];
	var _OrgManageUsePWPolicy = coviCmn.configMap["OrgManageUsePWPolicy"];
	var _IsUseApprovalSet = coviCmn.configMap["IsUseApprovalSet"];
	var _IsUseCRM = coviCmn.configMap["IsUseCRM"];

	$('.collabo_help02 .help_ico').on('click', function(){
		if($(this).hasClass('active')){
			$(this).removeClass('active');
		}else {
			$(this).addClass('active')
		}
	});
	$(document).ready(function() {

		$("#hidCompanyCode").val(_domainCode);
		$("#selIsAD").val(_isSyncAD);
		$("#selIsMail").val(_isSyncMail);
		$("#selIsMSG").val(_isSyncMessenger);
		setLicenseInfo();
		setSelectBox();
		getJobInfo();
		if(_licSection=='Y'){
			$("[name=licArea]").show();
		}
		if (_mode == "add") {
			setAddDefaultInfo();
			$("#selSecurityLevel").val('90');
			$("#selIsUse").val('Y');
			$("#selIsHR").val('N');
			$("#selIsDisplay").val('Y');
			$("#txtPriorityOrder").val('0');
			fnCPMailUse();
		} else if (_mode == "modify") {
			selectUserInfo(_userCode);
			//비밀번호 초기화버튼 표시
			$("#btnResetPwd").css("display","");
			//사용자ID
			$("#btnIsDuplicate_code").css("display", "none");
			$("#txtUserCode").attr("readonly", "readonly");
			$("#txtUserCode").removeClass("inputcheck");
			
			//비밀번호
			$("#txtPassword").closest("tr").css("display","none");
			
			
			//사번 수정불가
			$("#txtUserEmpNo").attr("readonly", "readonly");
			$("#txtUserEmpNo").removeClass("inputcheck");
			$("#btnIsDuplicate_empno").css("display", "none");
			
			$("#trLogonIDSaaS").attr("readonly", "readonly");
			$("#txtLogonIDSaaS").attr("readonly", "readonly");
			$("#selMailDomainSaaS").attr("disabled","disabled");
			$("#btnIsDuplicateLogonIDSaaS").hide();  
		}
		if(Common.getGlobalProperties("isSaaS") == "Y") {
			$("[name=trSaasN]").hide();
			$("#trLogonIDSaaS").css("display","");
			$("#txtMailID").attr("readonly", "readonly");
			$("#selMailDomain").attr("disabled","disabled");
			
			
			$("#txtLogonIDSaaS").on("propertychange change keyup paset input", function() {
				$("#txtMailID").val($("#txtLogonIDSaaS").val());
			});
			
			$("#selMailDomainSaaS").on("change", function() {
				$("#selMailDomain").val($("#selMailDomainSaaS option:selected").val());
			});
			$("#trIPSetting").css("display","none");
		}
		else
		{
			$("[name=trSaasN]").show();
			$("[name=trSaasY]").hide();
		}
	
		//기초설정에 따른 메일 표기 여부
		if(_isSyncAD != "Y"){
			var trMail = $('#selIsMail').closest('tr');
			//trMail.children('td:first').attr('colspan', '3');
			trMail.children('th:nth-of-type(2)').css("display","none");
			trMail.children('td:nth-of-type(2)').css("display","none");
	
			var trAD = $('#selIsAD').closest('tr');
			trAD.children('th:nth-of-type(2)').css("display","none");
			trAD.children('td:nth-of-type(2)').css("display","none");
			
			$("#trName").css("display", "none");
			
			$("#thExt").css("display", "");
			$("#tdExt").css("display", "");
			//$("#userAddSetTab").css("display", "none");
			
		}else{
			$("#userADSetTab").show()
			$("#trName").css("display", "");
			
			$("#thExt").css("display", "none");
			$("#tdExt").css("display", "none");
			$("#txtAD_CN").attr("class","mapping_"+coviCmn.configMap["AD_CN_Mapping"]);
			$("#txtAD_SamAccountName").attr("class","mapping_"+coviCmn.configMap["AD_sAMAccountName_Mapping"]);
			$("#txtAD_UserPrincipalName").attr("class","mapping_"+coviCmn.configMap["AD_UserPrincipalName_Mapping"]);
			
			$("[name=ADArea]").css("display", "");
			$("#txtUserDisplayName").attr("readonly", "readonly");
		}		
		
		if(_isSyncMail == "Y"){
			// Exch 메일
			$("#thIndiMailUse").css("display", "none");
			$("#tdIndiMailUse").css("display", "none");
			$("#thIndiMail").css("display", "none");
			$("#tdIndiMail").css("display", "none");
		}
		
		if(_IsUseApprovalSet == "Y") {
			$("#userApprovalSetTab").show()
		}

		if(_IsUseCRM == "Y"){
			$("#tdRole").attr("colspan", "");
			$("#thIsCRM").css("display", "");
			$("#tdIsCRM").css("display", "");
		}
		else{
			$("#tdRole").attr("colspan", "3");
			$("#thIsCRM").css("display", "none");
			$("#tdIsCRM").css("display", "none");
		}
		
		<% 
		if(Editable==null || !Editable.equals("Y"))
		{
		%>
			$("input").attr('disabled','disabled');
			$("select").attr('disabled','disabled');
			$("a[class=btnTypeDefault]").remove()
		<% }%>
	});

	
	//TODO
	function clickUserImage(obj) {
		$("input[name=addFile]").trigger('click');
	}
	
	var added_file;
	//TODO
	function changeUserImage(obj) {
		var file = $('input[name=addFile]')[0].files[0];
		var extension = file.name.replace(/^.*\./, '').toLowerCase();
		
		if (file.size > 1048576) {
			parent.Common.Warning("<spring:message code='Cache.msg_ImageUploadMessage' />");
			return;
		}
		
		if (extension != 'jpg') {
			parent.Common.Warning("<spring:message code='Cache.msg_onlyJpg' />");
			return;
		}
		$("#txtImagePath").val($("input[name=addFile]").val());
		added_file = $("input[name=addFile]")[0].files;
		getThumbnail($("input[name=addFile]"), $('#userThumbnail'));
	}

	//TODO
	function getThumbnail(html, target) {
		if (html[0].files && html[0].files[0]) {
			var reader = new FileReader();
			reader.onload = function(e) {
				//$("#btnUserImage").css('display','none');
				$(target).attr('src', e.target.result);
			}
			reader.readAsDataURL(html[0].files[0]);
			$(html).next('div').find('input[type=text]').val(html[0].value);
		}
	}

 
	function setAddDefaultInfo() {			
		$.ajax({
			type: "POST",
			data: {
				"gr_code": _groupCode
			},
			url: "/covicore/manage/conf/getGroupInfo.do",
			success: function (data) {
				$("#txtCompanyName").val(CFN_GetDicInfo(data.list[0].CompanyName, lang));
				$("#txtDeptName").val(data.list[0].DisplayName);
				$("#hidDeptCode").val(_groupCode);
				if(Common.getGlobalProperties("isSaaS") == "Y") {
					$("#txtPfx").text(_domainCode + "_");
					$("#txtPfx").parent().show()
					$("#selMailDomain").val(data.list[0].MailDomain);
					$("#selMailDomainSaaS").val(data.list[0].MailDomain);
				}
				
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/covicore/manage/conf/getGroupInfo.do", response, status, error);
			}
		});
		$("#rdoSolar").prop("checked", true);
		$("#rdoDeputyOption_Y").prop("checked", true);
	}

	function getJobInfo() {
		$.ajax({
			type:"POST",
			async: false,
			data:{
				"companyCode" : _domainCode
			},
			url:"/covicore/manage/conf/selectArbitraryGroupDropdownlist.do",
			success:function (data) {
				$('#selJobTitle option[value!=""]').remove()
				$('#selJobPosition option[value!=""]').remove()
				$('#selJobLevel option[value!=""]').remove()
				$.each(data.list, function (i, d) {
					if(d.GROUPTYPE == 'JobTitle'){
						 $('#selJobTitle').append($('<option>', { 
							value: d.GROUPCODE,
							text : d.GROUPNAME
						}));
					} else if(d.GROUPTYPE == 'JobPosition'){
						$('#selJobPosition').append($('<option>', { 
							value: d.GROUPCODE,
							text : d.GROUPNAME
						}));
					} else{
						 $('#selJobLevel').append($('<option>', { 
							value: d.GROUPCODE,
							text : d.GROUPNAME
						}));
					}
				});
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/manage/conf/getarbitrarygroupdropdownlist.do", response, status, error);
			}
		});
		
		
	}
	function setLicenseInfo() {
		$('#selLicSeq option').remove()
		$.ajax({
			type:"POST",
			async: false,
			data:{
				"domainCode" : _domainCode
			},
			url:"/covicore/manage/conf/selectLicenseInfoByCode.do",
			success:function (data) {
				if(data.status=="SUCCESS"){
					if(data.list.length==0){
						parent.Common.Warning("<spring:message code='Cache.msg_NotExistLicense' />"); //라이선스 정보가 없습니다.
						closePopup();
					}
					$.each(data.list, function (i, d) {
						$('#selLicSeq').append($('<option>', { 
							value: d.LicSeq,
							text : d.LicName,
							mail : d.LicMail
						}));
					});
					fnLicSeq();
				}
				else
					Common.Warning(data.message);
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/manage/conf/selectLicenseInfo.do", response, status, error);
			}
		});
		
		
	}
	//TODO
	function setSelectBox() {
		$(coviCmn.codeMap["MailDomain"]).each(function(idx, obj) {
			if (obj.Code == 'MailDomain')
				return true;
			$('#selMailDomain').append($('<option>', {
				value : obj.CodeName,
				text : obj.CodeName
			}));
			if(Common.getGlobalProperties("isSaaS") == "Y") {
				$('#selMailDomainSaaS').append($('<option>', {
					value : obj.CodeName,
					text : obj.CodeName
				}));
			}
		});
		
		$(coviCmn.codeMap["SecurityLevel"]).each(function(idx, obj) {
			if (obj.Code == 'SecurityLevel')
				return true;
			$('#selSecurityLevel').append($('<option>', {
				value : obj.Code,
				text : obj.CodeName
			}));
		});		
		$.ajax({
			type : "POST",
			async : false,
			data : {
				"codeGroups" : "MSNDomain,MSN_PhoneCommunication,CountryGroup,SecurityLevel"
			},
			url : "/covicore/basecode/get.do",
			success : function(data) {
				if (data.result == "ok") {
					var MSNDomainOption = makesadmin_tableData(data.list, "MSNDomain", lang);
					$("#selMailList").bindSelect({
						reserveKeys : {
							optionValue : "optionValue",
							optionText : "optionText"
						},
						options : MSNDomainOption
					});
					$("#selMailList").bindSelectRemoveOptions([ { optionValue : 'MSNDomain', optionText : 'MSNDomain' } ]);
					$('#selMailList').bindSelectAddOptions([{optionValue:'', optionText:'<spring:message code='Cache.lbl_Select' />'}]);
					$('#selMailList').val('');
					$("#selMailList").css("visibility", "")
					$("#AXselect_AX_selMailList").remove();

					var PhoneCommunicationOption = makesadmin_tableData(data.list, "MSN_PhoneCommunication", lang);
					$("#selTelephonyOptions").bindSelect({
						reserveKeys : {
							optionValue : "Reserved1",
							optionText : "optionText"
							
						},
						options : PhoneCommunicationOption
					});
					$("#selTelephonyOptions").bindSelectRemoveOptions([ { optionValue : 'MSN_PhoneCommunication', optionText : '전화통신옵션' } ]);
					$('#selTelephonyOptions').bindSelectAddOptions([{optionValue:'', optionText:'<spring:message code='Cache.lbl_Select' />'}]);
					$('#selTelephonyOptions').val('');
					$("#selTelephonyOptions").css("visibility", "")
					$("#AXselect_AX_selTelephonyOptions").remove();

					var CountryGroupOption = makesadmin_tableData(data.list, "CountryGroup", lang);
					$("#selCountry").bindSelect({
						reserveKeys : {
							optionValue : "Custom",
							optionText : "optionText"
						},
						options : CountryGroupOption
					});
					$("#selCountry").bindSelectRemoveOptions([ { optionValue : 'CountryGroup', optionText : 'CountryGroup' } ]);
					$("#selCountry").val('410/KR');
					$("#selCountry").css("visibility", "")
					$("#AXselect_AX_selCountry").remove();

					var SecurityLevelOption = makesadmin_tableData(data.list,"SecurityLevel", lang);
					$("#selSecurityLevel").bindSelect({
						reserveKeys : {
							optionValue : "optionValue",
							optionText : "optionText"
						},
						options : SecurityLevelOption
					});
					//$("#selSecurityLevel").bindSelectRemoveOptions([ { optionValue : 'SecurityLevel', optionText : '보안등급' } ]);
					//$("#selSecurityLevel").val('90');
					$("#selSecurityLevel").css("visibility", "");
					$("#AXselect_AX_selSecurityLevel").remove();
				}
			},
			error : function(error) {
				Common.Error(error.message)
			}
		});
		
		if("Y" == _isSyncMail){
			$.ajax({
				type : "POST",
				data : {
				},
				async : false,
				url : "/covicore/manage/conf/selectMailboxList.do",
				success : function(data) {
					if (data.result == "ok") {
						var MailBoxServerOption = data.list;
						$("#selMailBoxServer").bindSelect({
							reserveKeys : {
								optionValue : "code",
								optionText : "name"
							},
							options : MailBoxServerOption
						});
						
						$("#selMailBoxServer").css("visibility", "")
						$("#AXselect_AX_selMailBoxServer").remove();

					}
				},
				error : function(error) {
					Common.Error(error.message)
				}
			});
		}
		
		$('#selMailBoxServer').bindSelectAddOptions([{optionValue:'', optionText:'<spring:message code='Cache.lbl_Select' />'}]);
		$('#selMailBoxServer').val('');
		
 		$("#selServiceType").bindSelect({
			reserveKeys : {
				options : "list",
				optionValue : "optionValue",
				optionText : "optionText"
			},
			ajaxUrl : "/covicore/manage/conf/selectServiceTypeList.do",
			ajaxAsync : false,
			onchange : function() {
			}
		});
		$("#selServiceType").css("visibility", "")
		$("#AXselect_AX_selServiceType").remove();
	}

	//TODO
	function dictionaryLayerPopup(hasTransBtn, dicCallback) {
		var option = {
			lang : 'ko',
			hasTransBtn : hasTransBtn,
			allowedLang : 'ko,en,ja,zh',
			useShort : 'false',
			dicCallback : dicCallback,
			popupTargetID : 'DictionaryPopup',
			init : 'initDicPopup'
		};

		var url = "";
		url += "/covicore/control/calldic.do?lang=" + option.lang;
		url += "&hasTransBtn=" + option.hasTransBtn;
		url += "&useShort=" + option.useShort;
		url += "&dicCallback=" + option.dicCallback;
		url += "&allowedLang=" + option.allowedLang;
		url += "&popupTargetID=" + option.popupTargetID;
		url += "&init=" + option.init;
		url += "&styleType=" + "U";

		//CFN_OpenWindow(url,"다국어 지정",500,300,"");
		Common.open("", "DictionaryPopup", "<spring:message code='Cache.lbl__DicModify'/>", url, "400px", "300px", "iframe", true, null, null, true);
	}
	//TODO
	function initDicPopup() {
		if ($("#txtUserDisplayName").val() == '') {
			return "";
		}
		return $("#UserDisplayNameHidden").val() == '' ? $("#txtUserDisplayName").val() : $("#UserDisplayNameHidden").val();
	}
	//TODO
	function txtUserDisplayName(data) {
		$('#txtUserDisplayName').val(data.KoFull);
		$('#UserDisplayNameHidden').val(coviDic.convertDic(data))
	}

	// 다국어 값 바인드 및 처리
	parent._CallBackMethod = setDictionaryData;
	//TODO
	function setDictionaryData(nameValue) {
		$("#UserDisplayNameHidden").val(nameValue);
	}

	// 해당 값이 바뀌었을 경우 이전 다국어 데이터를 지움
	//TODO
	function resetDicData(thisObj) {
		if ($(thisObj)[0].id == "txtDeptName") {
			$("#DeptNameHidden").val("");
		} else if ($(thisObj)[0].id == "txtDeptShortName") {
			$("#DeptShortNameHidden").val("");
		}
	}

	//TODO
	function clickTab(pObj) {
		$('.tabMenu>li').removeClass('active');
		$(pObj).parent().addClass('active')
		

		var str = $(pObj).attr("value");

		$("#divUserDefault").hide();
		$("#divUserAD").hide();
		$("#divUserApproval").hide();
		$("#divUserAdd").hide();

		$("#" + str).show();
		
		coviInput.setDate();
	}

	//TODO
	function resetPassword() {
		var now = new Date();
		now = XFN_getDateTimeString("yyyy-MM-dd HH:mm:ss",now);
		var sURL = "/covicore/manage/conf/resetUserPassword.do";
		var tempMail = "";
		if($('#txtMailID').val() != "" && $('#selMailDomain').val() != "") tempMail = $('#txtMailID').val() + '@' + $('#selMailDomain').val();
		else tempMail = "";
				
		Common.Confirm("<spring:message code='Cache.msg_166'/>", "Confirmation Dialog", function (result) { 
			if(result) {
				$.ajax({
					type:"POST",
					data:{
						"UserCode" : $("#txtUserCode").val(),
						"ModDate" : now
					},
					url:sURL,
					success:function (data) {
						if(data.status == "SUCCESS")
							Common.Inform("<spring:message code='Cache.msg_ResetPassword'/>".replace(/\{0\}/gi, data.message), "Information Dialog", function(result) {
								if(result) {
									closePopup();
								}
							});
						else {
							Common.Warning(data.message);
						}
					},
					error:function(response, status, error){
						CFN_ErrorAjax(sURL, response, status, error);
					}
				});
			}
		});
	}

	//TODO
	function closePopup() {
		Common.Close();
	}

	
	function selectUserInfo(userCode) {
		$.ajax({
			type : "POST",
			data : {
				"UserCode" : userCode
			},
			async : false, 
			url : "/covicore/manage/conf/selectUserInfo.do",
			success : function(data) {
				_userInfo = data.list[0];
				$("#hidUserID").val(data.list[0].UserID);
				$("#txtUserCode").val(data.list[0].UserCode);
				$("#txtUserEmpNo").val(data.list[0].EmpNo);
				$("#hidtxtUserEmpNo").val(data.list[0].EmpNo);
				$("#txtLogonID").val(data.list[0].LogonID);
				$("#txtUserDisplayName").val(CFN_GetDicInfo(data.list[0].MultiDisplayName, lang));
				$("#UserDisplayNameHidden").val(data.list[0].MultiDisplayName);
				$("#txtInitials").val(data.list[0].NickName);
				$("#txtZipCode").val(CFN_GetDicInfo(data.list[0].MultiAddress, lang).split(")")[0].replace("(우. ", ""));
				$("#txtAddress").val(CFN_GetDicInfo(data.list[0].MultiAddress, lang).replace(CFN_GetDicInfo(data.list[0].MultiAddress, lang).split(")")[0],"").replace(") ", ""));
				$("#txtWebPage").val(data.list[0].HomePage);
				$("#txtPhoneNum").val(data.list[0].PhoneNumber);
				$("#txtMobilePhoneNum").val(data.list[0].Mobile);
				$("#txtFaxNum").val(data.list[0].FAX);
				$("#txtPhoneNumInter").val(data.list[0].PhoneNumberInter);
				$("#txtHomePhoneNum").val(data.list[0].IPPhone);
				$("#selIsEUM").val(data.list[0].UseMessengerConnect);
				$("#selIsCPMail").val(data.list[0].UseMailConnect);
				$("#selLicSeq").val(data.list[0].LicSeq);
				$("#selIsCRM").val(data.list[0].IsCRM);

				$("#hidOldIsCPMail").val(data.list[0].UseMailConnect);
				$("#hidtxtUseMailConnect").val(data.list[0].UseMailConnect);
				$("#txtPriorityOrder").val(data.list[0].SortKey);
				$("#selSecurityLevel").val(data.list[0].SecurityLevel);
				$("#txtRole").val(data.list[0].Description);
				$("#selIsUse").val(data.list[0].IsUse);
				$("#selIsHR").val(data.list[0].IsHR);
				$("#selIsDisplay").val(data.list[0].IsDisplay);
				$("#txtEnterDate").val(data.list[0].EnterDate);
				$("#txtRetireDate").val(data.list[0].RetireDate); 
				$("#txtDateofBirth").val(data.list[0].BirthDate);
				$("#txtMailID").val(data.list[0].MailAddress.split("@")[0]);
				$("#hidtxtMailID").val(data.list[0].MailAddress);
				$("#selMailDomain").val(data.list[0].MailAddress.split("@")[1]);
				
				$("#txtExtMail").val(data.list[0].ExternalMailAddress.split("@")[0]);
				if(data.list[0].ExternalMailAddress.split("@").length==2)
					$("#txtExtMailDomain").val(data.list[0].ExternalMailAddress.split("@")[1]);
				
				$("#txtChargeBusiness").val(data.list[0].ChargeBusiness);
				$("#hidReserved1").val(data.list[0].Reserved1);
				$("#hidReserved2").val(data.list[0].Reserved2);
				$("#hidReserved3").val(data.list[0].Reserved3);
				$("#hidReserved4").val(data.list[0].Reserved4);
				$("#hidReserved5").val(data.list[0].Reserved5);
				$("#hidCompanyCode").val(data.list[0].CompanyCode);
				$("#hidOldCompanyCode").val(data.list[0].CompanyCode);
				$("#txtCompanyName").val(CFN_GetDicInfo(data.list[0].MultiCompanyName, lang));
				$("#hidDeptCode").val(data.list[0].DeptCode);
				$("#txtDeptName").val(CFN_GetDicInfo(data.list[0].MultiDeptName, lang));
				$("#hidOldGroupCode").val(data.list[0].DeptCode);
				$("#hidPlaceOfBusiness").val(data.list[0].RegionCode);
				$("#txtPlaceOfBusiness").val(CFN_GetDicInfo(data.list[0].MultiRegionName, lang));
				$("#selJobPosition").val(data.list[0].JobPositionCode);
				$("#hidselJobPosition").val(data.list[0].JobPositionCode);
				$("#selJobTitle").val(data.list[0].JobTitleCode);
				$("#hidselJobTitle").val(data.list[0].JobTitleCode);
				$("#selJobLevel").val(data.list[0].JobLevelCode);
				$("#hidselJobLevel").val(data.list[0].JobLevelCode);
				$("#selIsDeputy").val(data.list[0].UseDeputy);
				$("#selDeputyOption").val(data.list[0].DeputyOption);
				$("#hidDeputyApprovalCode").val(data.list[0].DeputyCode);
				$("#txtDeputyApprovalName").val(CFN_GetDicInfo(data.list[0].DeputyName, lang));
				$("#txtDeputyDateStart").val(data.list[0].DeputyFromDate);
				$("#txtDeputyDateEnd").val(data.list[0].DeputyToDate);
				$("#hidApprovalDeptCode").val(data.list[0].ApprovalUnitCode);
				$("#txtApprovalDeptName").val(CFN_GetDicInfo(data.list[0].ApprovalUnitName, lang));
				$("#hidReceiptDeptCode").val(data.list[0].ReceiptUnitCode);
				$("#txtReceiptDeptName").val(CFN_GetDicInfo(data.list[0].ReceiptUnitName, lang));
				$("#selPhoneApproval").val(data.list[0].UseMobile);
				
				fnCPMailUse();
				fnLicSeq();
				if (data.list[0].PhotoPath != "" && data.list[0].PhotoPath != undefined) {
					$("#userThumbnail").eq(0).attr('src', (coviCmn.loadImage(data.list[0].PhotoPath)));
				}
				if (data.list[0].BirthDiv == "S") {
					$("#rdoSolar").prop("checked", true);
				} else if (data.list[0].BirthDiv == "L") {
					$("#rdoLunar").prop("checked", true);
				}
				if (data.list[0].DeputyOption == "Y") {
					$("#rdoDeputyOption_Y").prop("checked", true);
				} else if (data.list[0].DeputyOption == "P") {
					$("#rdoDeputyOption_P").prop("checked", true);
				}
				if(Common.getGlobalProperties("isSaaS") == "Y") {
					$("#txtLogonIDSaaS").val(data.list[0].LogonID.split("@")[0]);
					$("#selMailDomainSaaS").val(data.list[0].LogonID.split("@")[1]);
				}
				if (data.list[0].CheckUserIP == "Y") {
					$("#chkUserIPAddress").prop("checked", true);
					$("#txtStartIP").removeAttr("readonly").val(data.list[0].StartIP);
					$("#txtEndIP").removeAttr("readonly").val(data.list[0].EndIP);
				}
				if(data.list[0].AlertConfig.mailconfig != undefined){
					var alertConfig = data.list[0].AlertConfig.mailconfig.COMPLETE;
					$("#hidAlertConfig").val(JSON.stringify(data.list[0].AlertConfig.mailconfig));
					for (var i = 0; i < alertConfig.split(";").length; i++) {
						if(i == 0)
							$("#selCompleteYN").val(alertConfig.split(";")[i]);
						else {
							if (alertConfig.split(";")[i] == "MAIL") {
								$("#chkCompleteApprovalMail").prop("checked", true);
							} else if (alertConfig.split(";")[i] == "SMS") {
								$("#chkCompleteApprovalSMS").prop("checked", true);
							} else if (alertConfig.split(";")[i] == "MESSENGER") {
								$("#chkCompleteApprovalMessage").prop("checked", true);
							}
						}
					}
				}
				/*********추가 AD **********/
				$("#selIsAD").val(data.list[0].AD_ISUSE);
				if("Y" == _isSyncAD)
				{
					$("#hidAdminSettingCode").val(data.list[0].AD_MANAGERCODE);
					$("#txtAdminSettingName").val(CFN_GetDicInfo(data.list[0].ManagerName, lang));
					$("#hidAD_DisplayName").val(data.list[0].AD_DISPLAYNAME);
					$("#txtFirstName").val(data.list[0].AD_FIRSTNAME);
					$("#txtLastName").val(data.list[0].AD_LASTNAME);
					$("#txtInitials").val(data.list[0].AD_INITIALS);
					$("#txtOfficeAddress").val(data.list[0].AD_OFFICE);
					$("#txtWebPage").val(data.list[0].AD_HOMEPAGE);
					$("#selCountry").val(data.list[0].AD_COUNTRYID + "/" + data.list[0].AD_COUNTRYCODE );
					$("#txtCityState_01").val(data.list[0].AD_STATE);
					$("#txtCityState_02").val(data.list[0].AD_CITY);
					$("#txtAddress").val(data.list[0].AD_STREETADDRESS);
					$("#txtMailBox").val(data.list[0].AD_POSTOFFICEBOX);
					$("#txtZipCode").val(data.list[0].AD_POSTALCODE);
					$("#hidAD_UserAccountControl").val(data.list[0].AD_USERACCOUNTCONTROL);
					$("#hidAD_AccountExpires").val(data.list[0].AD_ACCOUNTEXPIRES);
					$("#txtPhoneNum").val(data.list[0].AD_PHONENUMBER);
					$("#txtHomePhoneNum").val(data.list[0].AD_HOMEPHONE);
					$("#hidAD_Pager").val(data.list[0].AD_PAGER);
					$("#hidAD_Info").val(data.list[0].AD_INFO);					
					$("#txtAD_CN").val(data.list[0].AD_CN);
					$("#txtAD_SamAccountName").val(data.list[0].AD_SamAccountName);
					$("#txtAD_UserPrincipalName").val(data.list[0].AD_UserPrincipalName);					
				}
				/*********추가 Exchange **********/
				$("#selIsMail").val(data.list[0].EX_ISUSE);
				if("Y" == _isSyncMail){
					$("#hidPrimary").val(data.list[0].EX_PRIMARYMAIL);
					$("#hidSecondary").val(data.list[0].EX_SECONDARYMAIL);
					$("#EX_CustomAttribute01").val(data.list[0].EX_CUSTOMATTRIBUTE01);
					$("#EX_CustomAttribute02").val(data.list[0].EX_CUSTOMATTRIBUTE02);
					$("#EX_CustomAttribute03").val(data.list[0].EX_CUSTOMATTRIBUTE03);
					$("#EX_CustomAttribute04").val(data.list[0].EX_CUSTOMATTRIBUTE04);
					$("#EX_CustomAttribute05").val(data.list[0].EX_CUSTOMATTRIBUTE05);
					$("#EX_CustomAttribute06").val(data.list[0].EX_CUSTOMATTRIBUTE06);
					$("#EX_CustomAttribute07").val(data.list[0].EX_CUSTOMATTRIBUTE07);
					$("#EX_CustomAttribute08").val(data.list[0].EX_CUSTOMATTRIBUTE08);
					$("#EX_CustomAttribute09").val(data.list[0].EX_CUSTOMATTRIBUTE09);
					$("#EX_CustomAttribute10").val(data.list[0].EX_CUSTOMATTRIBUTE10);
					$("#EX_CustomAttribute11").val(data.list[0].EX_CUSTOMATTRIBUTE11);
					$("#EX_CustomAttribute12").val(data.list[0].EX_CUSTOMATTRIBUTE12);
					$("#EX_CustomAttribute13").val(data.list[0].EX_CUSTOMATTRIBUTE13);
					$("#EX_CustomAttribute14").val(data.list[0].EX_CUSTOMATTRIBUTE14);
					$("#EX_CustomAttribute15").val(data.list[0].EX_CUSTOMATTRIBUTE15);
					$("#selMailBoxServer").val(data.list[0].EX_STORAGESERVER +"/"+ data.list[0].EX_STORAGEGROUP);
					if(data.list[0].EX_PRIMARYMAIL != ""){
						$("#hidMailAddressInfo").val(data.list[0].EX_PRIMARYMAIL);	
					}
					if(data.list[0].EX_SECONDARYMAIL != ""){
						$("#hidMailAddressInfo").val($("#hidMailAddressInfo").val() + "," + data.list[0].EX_SECONDARYMAIL);
					}
					
	                if ($("#hidMailAddressInfo").val() != "" && _isSyncMail == "Y") {
	                    var sMailAttributeInfo = $("#hidMailAddressInfo").val();
	                    if (sMailAttributeInfo.indexOf(';') != -1) {
	                        sMailAttributeInfo = sMailAttributeInfo.replace(';', ',');
	                    }
	                    var sAttributeID = "";
	                    var sMailID = "";
	                    var sXML = "<Attribute>";
	                    if (sMailAttributeInfo.indexOf(',') != -1) {
	                        var aMailAttributeInfo = sMailAttributeInfo.split(',');
	                        for (var i = 0; i < aMailAttributeInfo.length; i++) {
	                            if (aMailAttributeInfo[i].indexOf('|') != -1) {
	                                var aMailAttributeInfo_Secondary = aMailAttributeInfo[i].split('|');
	                                for (var j = 0; j < aMailAttributeInfo_Secondary.length; j++) {
	                                    sXML += "<Mail><![CDATA[" + aMailAttributeInfo_Secondary[j] + "]]></Mail>";
	                                    sXML += "<AttributeID><![CDATA[" + aMailAttributeInfo_Secondary[j] + "]]></AttributeID>";
	                                }
	                            } else {
	                                sXML += "<Mail><![CDATA[" + aMailAttributeInfo[i] + "]]></Mail>";
	                                sXML += "<AttributeID><![CDATA[" + sAttributeID + "]]></AttributeID>";
	                            }
	                        }

	                    } else {
	                        sXML += "<Mail><![CDATA[" + sMailAttributeInfo + "]]></Mail>";
	                        sXML += "<AttributeID><![CDATA[" + sAttributeID + "]]></AttributeID>";
	                    }
	                    sXML += "</Attribute>";
	                    btnAttributeAdd_OnClick_After(sXML);
	                }
				}
			
				/*********추가 Messenger **********/
				$("#selIsMSG").val(data.list[0].MSN_ISUSE);
				if("Y" == _isSyncMessenger){
					$("#hidMSN_PoolServerName").val(data.list[0].MSN_POOLSERVERNAME);
					$("#hidMSN_PoolServerDN").val(data.list[0].MSN_POOLSERVERDN);

					if(data.list[0].MSN_SIPADDRESS != "" && data.list[0].MSN_SIPADDRESS != undefined && data.list[0].MSN_SIPADDRESS != "undefined"){
						if(data.list[0].MSN_SIPADDRESS.indexOf("@") > -1){
							$("#txtSIPAddress").val(data.list[0].MSN_SIPADDRESS.split("@")[0]);
							$("#selMailList").val(data.list[0].MSN_SIPADDRESS.split("@")[1]);
						}
					}
					$("#hidMSN_Anonmy").val(data.list[0].MSN_ANONMY);
					$("#selServiceType").val(data.list[0].MSN_MEETINGPOLICYNAME);
					$("#hidMSN_MeetingPolicyDN").val(data.list[0].MSN_MEETINGPOLICYDN);
					$("#selTelephonyOptions").val(data.list[0].MSN_PHONECOMMUNICATION);
					$("#hidMSN_PBX").val(data.list[0].MSN_PBX);		
					$("#hidMSN_LinePolicyName").val(data.list[0].MSN_LINEPOLICYNAME);
					$("#hidMSN_LinePolicyDN").val(data.list[0].MSN_LINEPOLICYDN);
					$("#hidMSN_LineURI").val(data.list[0].MSN_LINEURI);
					$("#hidMSN_LineServerURI").val(data.list[0].MSN_LINESERVERURI);
					$("#hidMSN_Federation").val(data.list[0].MSN_FEDERATION);
					$("#hidMSN_RemoteAccess").val(data.list[0].MSN_REMOTEACCESS);
					$("#hidMSN_PublicIMConnectivity").val(data.list[0].MSN_PUBLICIMCONNECTIVITY);
					$("#hidMSN_InternalIMConversation").val(data.list[0].MSN_INTERNALIMCONVERSATION);
					$("#hidMSN_FederatedIMConversation").val(data.list[0].MSN_FEDERATEDIMCONVERSATION);
				}

				if(data.list[0].EX_ISUSE){
					$("#selMailBoxServer").attr("disabled","disabled");
				}
				if($("#selMailBoxServer").val() != ""){
					$("#selMailBoxServer").attr("disabled","disabled");
				}
			},
			error : function(response, status, error) {
				CFN_ErrorAjax("/covicore/manage/conf/selectUserInfo.do", response, status, error);
			}
		});
	}

	var check_dup_usercode = "N";
	var check_dup_empno = "N";
	var check_dup_logonid = "N";

	
	function checkDuplicate(obj) {
		if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
		
		var stringRegx = /[\s\{\}\[\]?,;:|\)*~`!^\-+┼<>@\#$%&\\(\=\'\"]/;
		var stringRegx2 = /[ㄱ-ㅎ|ㅏ-ㅣ|가-힣]/;
		
		var sUrl = "";

		var id = $(obj).closest("td").find("input[type=text]").attr("id");
		if(_mode != "add")
			return;
		var code = $("#" + id).val();

		sUrl = "/covicore/manage/conf/selectIsDuplicateUserInfo.do";
		if (id == "txtUserCode") {
			if (code == "") {
				Common.Warning("<spring:message code='Cache.msg_ObjectUR_01'/>");
				return;
			} else if (code.length > 20) {
				Common.Warning("<spring:message code='Cache.msg_ObjectUR_23'/>");
				return;
			} else if(stringRegx.test($("#txtUserCode").val())) {
				Common.Warning("<spring:message code='Cache.msg_specialNotAllowed'/>", 'Warning Dialog', function() {
					$("#txtUserCode").focus();
				});
				return false;
			} else if(stringRegx2.test($("#txtUserCode").val())) {
				Common.Warning("<spring:message code='Cache.msg_KoreanNotAllowed'/>", 'Warning Dialog', function() {
					$("#txtUserCode").focus();
				});
				return false;
			} 
		} else if (id == "txtLogonIDSaaS"){
			code = code + "@" + $("#selMailDomainSaaS option:selected").val();
			
			if (code == "") {
				Common.Warning("<spring:message code='Cache.msg_ObjectUR_27'/>");
				return;
			} else if(stringRegx.test($("#txtLogonIDSaaS").val())) {
				Common.Warning("<spring:message code='Cache.msg_specialNotAllowed'/>", 'Warning Dialog', function() {
					$("#txtLogonIDSaaS").focus();
				});
				return false;
			} else if(stringRegx2.test($("#txtLogonIDSaaS").val())) {
				Common.Warning("<spring:message code='Cache.msg_KoreanNotAllowed'/>", 'Warning Dialog', function() {
					$("#txtLogonIDSaaS").focus();
				});
				return false;
			} 
		} else {//사번, txtLogonID
			if (code == "") {
				Common.Warning("<spring:message code='Cache.msg_ObjectUR_02'/>");
				return;
			} else if (code.length > 50) {
				Common.Warning("<spring:message code='Cache.msg_apv_chk_emp_no_len'/>");
				return;
			} else if(stringRegx.test($("#txtUserEmpNo").val())) {
				Common.Warning("<spring:message code='Cache.msg_specialNotAllowed'/>", 'Warning Dialog', function() {
					$("#txtUserEmpNo").focus();
				});
				return false;
			} else if(stringRegx2.test($("#txtUserEmpNo").val())) {
				Common.Warning("<spring:message code='Cache.msg_KoreanNotAllowed'/>", 'Warning Dialog', function() {
					$("#txtUserEmpNo").focus();
				});
				return false;
			} 
			if(Common.getGlobalProperties("isSaaS") == "Y") {
				sUrl = "/covicore/manage/conf/selectIsDuplicateEmpno.do";
			}
		}

		if($("#txtPfx").text() != "" && id == "txtUserCode") {
			code = $("#txtPfx").text() + code;
		}
		
		$.ajax({
			type : "POST",
			data : {
				"Code" : code,
				"Type" : id.replace("txt", "").replace("SaaS","") ,
				"CompanyCode" : _domainCode 
			},
			url : sUrl,
			success : function(data) {
				if (data.status != "FAIL") {
					if (data.list[0].isDuplicate > 0) 
					{
						if (id == "txtUserCode") {
							Common.Warning("<spring:message code='Cache.msg_EXIST_URCODE'/>");
							check_dup_usercode = "N";
						} else if (id == "txtLogonID") {
							Common.Warning("<spring:message code='Cache.msg_EXIST_LogonID'/>");
							check_dup_logonid = "N";
						} else if (id == "txtLogonIDSaaS" && code.indexOf('@') > 0) {
							Common.Warning("<spring:message code='Cache.msg_EXIST_LogonID'/>");
							check_dup_logonid = "N";
						} else {
							Common.Warning("<spring:message code='Cache.msg_EXIST_EMPNO'/>");
							check_dup_empno = "N";
						}
						$("#" + id).focus();
					} 
					else 
					{
						if (id == "txtUserCode") {
							Common.Inform("<spring:message code='Cache.msg_possible_id'/>");
							check_dup_usercode = "Y";
						} else if (id == "txtLogonID") {
							Common.Inform("<spring:message code='Cache.msg_possible_LogonID'/>");
							check_dup_logonid = "Y";
						} else if (id == "txtLogonIDSaaS" && code.indexOf('@') > 0) {
							Common.Inform("<spring:message code='Cache.msg_possible_LogonID'/>");
							check_dup_logonid = "Y";
						} else {
							Common.Inform("<spring:message code='Cache.msg_possible_empno'/>");
							check_dup_empno = "Y";
						}
					}
				} else {
					Common.Warning(data.message);
					check_dup_usercode = "N";
					check_dup_empno = "N";
					check_dup_logonid = "N";
				}
			},
			error : function(response, status, error) {
				CFN_ErrorAjax("/covicore/manage/conf/selectIsDuplicateUserInfo.do", response, status, error);
			}
		});
	}

	//중복 확인-메일
	var check_dupMail = "N";

	var temp_target = "";

	function OrgMap_Open(type, target) {
		temp_target = target;
		var defaultVal = '';
		if (temp_target == "UserDept") {
			defaultVal = $("#hidDeptCode").val();
		} else if (temp_target == "ApprovalDept") {
			defaultVal = $("#hidApprovalDeptCode").val();
		} else if (temp_target == "ReceiptDept") {
			defaultVal = $("#hidReceiptDeptCode").val();
		}
		
		if (type == "user") { 
			parent.Common.open("","orgchart_pop","<spring:message code='Cache.lbl_DeptOrgMap'/>","/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod3&openerID=divUserInfo&type=B1&companyCode="+_domainCode+"&defaultValue="+defaultVal,"1040px", "580px", "iframe", true, null, null,true);
		} else if (type == "dept") {
			parent.Common.open("", "orgchart_pop", "<spring:message code='Cache.lbl_DeptOrgMap'/>", "/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod2&openerID=divUserInfo&type=C1&companyCode="+_domainCode+"&defaultValue="+defaultVal, "1040px", "580px", "iframe", true, null, null, true);
		}
	}

	function _CallBackMethod2(data) { //조직도 콜백함수 구현 : 부서(parent에 정의)
		var jsonData = JSON.parse(data);

		if(jsonData.item.length < 1){
			return ;
		}
			
		if (temp_target == "UserDept") {
			$("#txtDeptName").val(CFN_GetDicInfo(jsonData.item[0].DN));
			$("#hidDeptCode").val(jsonData.item[0].AN);
			$("#hidCompanyCode").val(jsonData.item[0].CompanyCode);
			$("#txtCompanyName").val(CFN_GetDicInfo(jsonData.item[0].CompanyName));
			_domainCode = jsonData.item[0].CompanyCode
		} else if (temp_target == "ApprovalDept") {
			$("#txtApprovalDeptName").val(CFN_GetDicInfo(jsonData.item[0].DN));
			$("#hidApprovalDeptCode").val(jsonData.item[0].AN);
		} else if (temp_target == "ReceiptDept") {
			$("#txtReceiptDeptName").val(CFN_GetDicInfo(jsonData.item[0].DN));
			$("#hidReceiptDeptCode").val(jsonData.item[0].AN);
		}
		
		if($("#hidOldCompanyCode").val() != $("#hidCompanyCode").val()){
			$("#txtPlaceOfBusiness").val("");
			$("#hidPlaceOfBusiness").val("");
			
			getJobInfo();
			setLicenseInfo();
		}
	}

	function _CallBackMethod3(data) { //조직도 콜백함수 구현 : 사용자(parent에 정의)
		var jsonData = JSON.parse(data);

		if (temp_target == "DeputyApproval") {
			$("#txtDeputyApprovalName").val(CFN_GetDicInfo(jsonData.item[0].DN));
			$("#hidDeputyApprovalCode").val(jsonData.item[0].AN);
		} else if (temp_target == "AdminSetting") {
			$("#txtAdminSettingName").val(CFN_GetDicInfo(jsonData.item[0].DN));
			$("#hidAdminSettingCode").val(jsonData.item[0].AN);
		}
	}
	
	function PlaceOfBusiness_Open() { 
		var companyCode = $("#hidCompanyCode").val();
		parent.Common.open("", "region_pop", "<spring:message code='Cache.lbl_ResourceManage_03'/>" + " ||| " +"<spring:message code='Cache.msg_PlaceOfBusinessSettings'/>", "/covicore/regionlistpop.do?functionName=_CallBackMethod4&lang=" + lang + "&domainCode=" + _domainCode, "550px", "300px", "iframe", true, null, null, true);
	}
	
	parent._CallBackMethod4 = setRegionData;
	function setRegionData(regionCode, multiRegionName) {
		$("#txtPlaceOfBusiness").val(CFN_GetDicInfo(multiRegionName, lang));
		$("#hidPlaceOfBusiness").val(regionCode);
	}

	//암호 복잡성 사용시 체크 시작
	function result_chkPWDComplexity() {
		var strChangePWD = $("#txtPassword").val();
		var chkSum = 0;
		var chkResult;
		chkSum = checkedPWD(strChangePWD);
		//복잡성 체크
		if (chkSum >= 3 && strChangePWD.replace(/ /g, "").length >= 8) {
			chkResult = 0;
		} else if (chkSum >= 2 && strChangePWD.replace(/ /g, "").length >= 10) {
			chkResult = 0;
		} else {
			chkResult = 1;
		}
		//개인정보 체크
		if (chkResult == 0) {
			var strMobile = $("#txtMobilePhoneNum").val();
			var arrMobile = strMobile.split('-');
			var strUrCode = $("#txtUserCode").val();
			if (strChangePWD.toUpperCase().indexOf(strUrCode.toUpperCase()) > -1) {
				chkResult = 2;
			} else if (arrMobile[1] != undefined) {
				if (strChangePWD.indexOf(arrMobile[1].toString()) > -1) {
					chkResult = 2;
				}
			} else if (arrMobile[2] != undefined) {
				if (strChangePWD.indexOf(arrMobile[2].toString()) > -1) {
					chkResult = 2;
				}
			}
		}
		//일련된 문자, 숫자 체크
		if (chkResult == 0) {

			var SamePass_0 = 0; //동일문자 카운트
			var SamePass_1 = 0; //연속성(+) 카운드
			var SamePass_2 = 0; //연속성(-) 카운드

			var chr_pass_0;
			var chr_pass_1;
			var chr_pass_2;

			for (var i = 0; i < strChangePWD.length; i++) {
				chr_pass_0 = strChangePWD.charAt(i);
				chr_pass_1 = strChangePWD.charAt(i + 1);

				//동일문자 카운트
				if (chr_pass_0 == chr_pass_1) {
					SamePass_0 = SamePass_0 + 1
				}
				chr_pass_2 = strChangePWD.charAt(i + 2);

				//연속성(+) 카운드
				if (chr_pass_0.charCodeAt(0) - chr_pass_1.charCodeAt(0) == 1 && chr_pass_1.charCodeAt(0) - chr_pass_2.charCodeAt(0) == 1) {
					SamePass_1 = SamePass_1 + 1
				}

				//연속성(-) 카운드
				if (chr_pass_0.charCodeAt(0) - chr_pass_1.charCodeAt(0) == -1 && chr_pass_1.charCodeAt(0) - chr_pass_2.charCodeAt(0) == -1) {
					SamePass_2 = SamePass_2 + 1
				}
			}
			if (SamePass_0 > 1) {
				chkResult = 3;
			}
			if (SamePass_1 > 1 || SamePass_2 > 1) {
				chkResult = 4;
			}
		}
		return chkResult;
	}

	function checkedPWD(chgPassword) {
		var chkArr = new Array();

		var chkNum1 = 0;
		var chkNum2 = 0;
		var chkNum3 = 0;
		var chkNum4 = 0;

		var chkSum = 0;

		// 정규식 패턴 //
		var regExp1 = /^[a-z]/;
		var regExp2 = /^[A-Z]/;
		var regExp3 = /^[0-9]/;
		var regExp4 = /[^0-9a-zA-Zㄱ-ㅎㅏ-ㅣ가-힣]/;
		// 정규식 패턴 //

		for (var i = 0; i < chgPassword.replace(/ /g, "").length; i++) {
			chkArr[i] = chgPassword.charAt(i);
			if (regExp1.test(chkArr[i])) {
				chkNum1 = 1;
				continue;
			} else if (regExp2.test(chkArr[i])) {
				chkNum2 = 1;
				continue;
			} else if (regExp3.test(chkArr[i])) {
				chkNum3 = 1;
				continue;
			} else if (regExp4.test(chkArr[i])) {
				chkNum4 = 1;
				continue;
			}
		}
		chkSum = chkNum1 + chkNum2 + chkNum3 + chkNum4;
		return chkSum;
	}
	
	var cryptoType = "";
	var privacy_level = "";
	var privacy_len = "";
	// 비밀번호 정책 사용
	function usePWPolicyCheck() {
		var NewPW = $("#txtPassword").val();
		
		$.ajax({
			type : "POST",
			data : {
				"DomainCode" : _domainCode,
				"NewPW" : NewPW
			},
			url : "/covicore/manage/conf/usePWPolicyCheck.do",
			success : function(data) {
				if (data.status != "FAIL") {					
					cryptoType = data.cryptoType;
					privacy_level = data.list[0].IsUseComplexity;
					privacy_len = data.list[0].MinimumLength;
					
				} else {
					Common.Warning(data.message);
				}
			},
			error : function(response, status, error) {
				CFN_ErrorAjax("/covicore/manage/conf/usePWPolicyCheck.do", response, status, error);
			}
		});
	}
	
	function validation() {
		var len = "";
		if(privacy_len == null || privacy_len == ""){
			len = 10;
		}else{
			len = parseInt(privacy_len);
		}
		
		if(!pwPolicy.isPwLevel("txtPassword", privacy_level, len)){
			return false;
		}
		
		if(!pwPolicy.isPwLevel("txtPassword", "0", len)){
			return false;
		}
		
		if(!pwPolicy.isPwContinuous("txtPassword")){
			return false;
		}
		return true;
	}
	//암호 복잡성 사용시 체크 끝

	function CheckValidation() {
		if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
		var now;
		var ApprovalArrivalMedium;
		var url;
		var message;

		// ================================= 기본 설정 =================================

		$("#txtUserCode").val($("#txtUserCode").val().replace(/ /gi, ''));

		if ($("#txtUserCode").val() == "") {
			Common.Warning("<spring:message code='Cache.msg_ObjectUR_01' />", 'Warning Dialog', function() { //사용자 ID를 입력하세요.
				$("#txtUserCode").focus();
			});
			return false;
		} else if (_mode == "add" && check_dup_usercode == "N") {
			Common.Warning("<spring:message code='Cache.msg_LogonID_DuplicateCheck' />", 'Warning Dialog', function() { //사용자 아이디 중복체크를 하십시오.
				$("#txtUserCode").focus();
			});
			return false;
		} else if ($("#txtUserCode").val().length > 20) {
			Common.Warning("<spring:message code='Cache.msg_ObjectUR_23' />", 'Warning Dialog', function() { //사용자 ID를 20자 이하로 설정하십시오.
				$("#txtUserCode").focus();
			});
			return false;
		}

		if ($("#txtUserEmpNo").val() == "") {
			Common.Warning("<spring:message code='Cache.msg_ObjectUR_02' />", 'Warning Dialog', function() { //사원번호를 입력하여 주십시오.
				$("#txtUserEmpNo").focus();
			});
			return false;
		} else if (_mode == "add" && check_dup_empno == "N") {
			Common.Warning("<spring:message code='Cache.msg_EmpNoDuplicateCheck' />", 'Warning Dialog', function() { //사원번호 중복 체크를 하십시오.
				$("#txtUserEmpNo").focus();
			});
			return false;
		} else if (_mode == "modify" && check_dup_empno == "N" && $("#txtUserEmpNo").val() != $("#hidtxtUserEmpNo").val()) {
			Common.Warning("<spring:message code='Cache.msg_EmpNoDuplicateCheck' />", 'Warning Dialog', function() { //사원번호 중복 체크를 하십시오.
				$("#txtUserEmpNo").focus();
			});
			return false;
		}
		var chkTarget; ;
		if(Common.getGlobalProperties("isSaaS") == "Y") 
			chkTarget = $('#txtLogonIDSaaS');
		else 
			chkTarget = $('#txtLogonID');
		if (chkTarget.val() == "") {
			Common.Warning("<spring:message code='Cache.msg_ObjectUR_25' />", 'Warning Dialog', function() { //LogonID를 입력하여 주십시오.
				chkTarget.focus();
			});
			return false;
		} else if(_mode == "add" && check_dup_logonid == "N") {
			Common.Warning("<spring:message code='Cache.msg_LogonIDDuplicateCheck' />", 'Warning Dialog', function() { //LogonID 중복 체크를 하십시오.
				chkTarget.focus();
			});
			return false;
		}
		
		if (_mode == "add") {
			if ($("#txtPassword").val() == "") {
				Common.Warning("<spring:message code='Cache.msg_ObjectUR_03' />", 'Warning Dialog', function() { //비밀번호를 입력하여 주십시오.
					$("#txtPassword").focus();
				});
				return false;
			} else if ($("#txtConfirmPassword").val() == "") {
				Common.Warning("<spring:message code='Cache.msg_ObjectUR_04' />", 'Warning Dialog', function() { //비밀번호를 다시한번 입력하여 주십시오.
					$("#txtConfirmPassword").focus();
				});
				return false;
			} else if ($("#txtPassword").val() != $("#txtConfirmPassword").val()) {
				Common.Warning("<spring:message code='Cache.msg_ObjectUR_05' />", 'Warning Dialog', function() { //비밀번호가 다릅니다.<br /> 다시 확인하여 입력하여 주십시오.
					$("#txtConfirmPassword").focus();
				});
				return false;
			}
			
			//복잡성체크 X
			//암호 정책(암호 길이, 재로그인 유무, 복잡성 사용 유무, 최대암호 사용기간, 암호관리 Type, 암호 연장 일수) 확인
			//암호 복잡성 사용시 체크 시작 : 암호화 정책
			//if (_OrgManageUsePWPolicy == "Y") {
			//	usePWPolicyCheck();
			//	
			//	if(!validation()){
			//		return;
			//	}
			//	
			//}
			//else {
			//	var strMessage1 = "<spring:message code='Cache.msg_passwordComplexityDscr' />"; // "영대문자, 영소문자, 숫자, 특수문자등 2종류 이상으로 구성하여\n 최소 10자리 이상 또는 영대문자, 영소문자, 숫자, 특수문자등\n 3종류 이상으로 구성하여 최소 8자리 이상으로 구성되어야 합니다.";
			//	var strMessage2 = "<spring:message code='Cache.msg_cannotBeUsedPersonalInfo' />"; //"개인정보를 비밀번호에 사용할 수 없습니다.";
			//	var strMessage3 = "<spring:message code='Cache.msg_cannotUseSameWord' />"; //"동일문자를 3번 이상 사용할 수 없습니다.";
			//	var strMessage4 = "<spring:message code='Cache.msg_cannotConsecutiveWord' />" //"연속된 숫자나 키보드 자판의 일련된 문자는 사용할 수 없습니다.";
			//	if (result_chkPWDComplexity() == 1) {
			//		Common.Warning(strMessage1, 'Warning Dialog', function() {
			//			$("#txtPassword").focus();
			//		});
			//		return false;
			//	} else if (result_chkPWDComplexity() == 2) {
			//		Common.Warning(strMessage2, 'Warning Dialog', function() {
			//			$("#txtPassword").focus();
			//		});
			//		return false;
			//	} else if (result_chkPWDComplexity() == 3) {
			//		Common.Warning(strMessage3, 'Warning Dialog', function() {
			//			$("#txtPassword").focus();
			//		});
			//		return false;
			//	} else if (result_chkPWDComplexity() == 4) {
			//		Common.Warning(strMessage4, 'Warning Dialog', function() {
			//			$("#txtPassword").focus();
			//		});
			//		return false;
			//	}
			//}
			////암호 복잡성 사용시 체크 끝
		}

		if ($("#txtUserDisplayName").val() == "") {
			Common.Warning("<spring:message code='Cache.msg_ObjectUR_08' />", 'Warning Dialog', function() {
				$("#txtUserDisplayName").focus();
			});
			return false;
		} else if ($("#UserDisplayNameHidden").val() == "") {
			Common.Warning("<spring:message code='Cache.msg_ObjectUR_24' />", 'Warning Dialog', function() {
				$("#txtUserDisplayName").focus();
			});
			return false;
		} else if ($("#txtCompanyName").val() == "") {
			Common.Warning("<spring:message code='Cache.msg_ObjectUR_09' />", 'Warning Dialog', function() {
				$("#txtCompanyName").focus();
			});
			return false;
		} else if ($("#txtDeptName").val() == "") {
			Common.Warning("<spring:message code='Cache.msg_ObjectUR_10' />", 'Warning Dialog', function() {
				$("#txtDeptName").focus();
			});
			return false;
		} 

		// Exch
		if(_isSyncMail == "Y"){
		
		}
		else if(_isSyncIndi == "Y" && $("#selIsCPMail option:selected").val() == "Y"){
			// CP
			if($("#txtMailID").val() == "" && $("#selMailDomain option:selected").val() == "") {
				Common.Warning("<spring:message code='Cache.msg_insert_MailAddress'/>", 'Warning Dialog', function() { // 메일주소를 입력해 주십시오.
					$("#txtMailID").focus();
				});
				return false;
			} else if($("#txtMailID").val() != "" && $("#selMailDomain option:selected").val() == "") {
				Common.Warning("<spring:message code='Cache.msg_select_MailDomain'/>", 'Warning Dialog', function() { // 메일 도메인을 선택해 주십시오.
					$("#selMailDomain").focus();
				});
				return false;
			}else if ($("#txtMailID").val() == "" && $("#selMailDomain option:selected").val() != "") {
				Common.Warning("<spring:message code='Cache.msg_insert_MailAddress'/>", 'Warning Dialog', function() { // 메일주소를 입력해 주십시오.
					$("#txtMailID").focus();
				});
				return false;
			}else if ($("#txtMailID").val() != "" && $("#selMailDomain option:selected").val() != "") {
				if(_mode == "add" && check_dupMail == "N") {
					Common.Warning("<spring:message code='Cache.msg_Check_Duplicate_Mail'/>", 'Warning Dialog', function() { // 메일 중복을 확인하여 주십시오.
						$("#txtMailID").focus();
					});
					return false;
				}else if(_mode == "modify" && $("#hidtxtMailID").val() != $("#txtMailID").val() + "@" + $("#selMailDomain option:selected").val() && check_dupMail == "N") {
					Common.Warning("<spring:message code='Cache.msg_Check_Duplicate_Mail'/>", 'Warning Dialog', function() { // 메일 중복을 확인하여 주십시오.
						$("#txtMailID").focus();
					});
					return false;
				}else if(_mode == "modify" && $("#hidtxtUseMailConnect").val() != $("#selIsCPMail option:selected").val() && check_dupMail == "N") {
					Common.Warning("<spring:message code='Cache.msg_Check_Duplicate_Mail'/>", 'Warning Dialog', function() { // 메일 중복을 확인하여 주십시오.
						$("#txtMailID").focus();
					});
					return false;
				}
			}
		} 
		//왜있는건지?
		//else {
		//	if($("#txtMailID").val() != "" && $("#selMailDomain option:selected").val() == "") {
		//		Common.Warning("<spring:message code='Cache.msg_select_MailDomain'/>", 'Warning Dialog', function() { // 메일 도메인을 선택해 주십시오.
		//			$("#selMailDomain").focus();
		//		});
		//		return false;
		//	}else if ($("#txtMailID").val() == "" && $("#selMailDomain option:selected").val() != "") {
		//		Common.Warning("<spring:message code='Cache.msg_insert_MailAddress'/>", 'Warning Dialog', function() { // 메일주소를 입력해 주십시오.
		//			$("#txtMailID").focus();
		//		});
		//		return false;
		//	}else if ($("#txtMailID").val() != "" && $("#selMailDomain option:selected").val() != "") {
		//		if(_mode == "add" && check_dupMail == "N") {
		//			Common.Warning("<spring:message code='Cache.msg_Check_Duplicate_Mail'/>", 'Warning Dialog', function() { // 메일 중복을 확인하여 주십시오.
		//				$("#txtMailID").focus();
		//			});
		//			return false;
		//		}else if(_mode == "modify" && $("#hidtxtMailID").val() != $("#txtMailID").val() + "@" + $("#selMailDomain option:selected").val() && check_dupMail == "N") {
		//			Common.Warning("<spring:message code='Cache.msg_Check_Duplicate_Mail'/>", 'Warning Dialog', function() { // 메일 중복을 확인하여 주십시오.
		//				$("#txtMailID").focus();
		//			});
		//			return false;
		//		}
		//	}
		//}


		if ($("#txtPriorityOrder").val() == "") {
			Common.Warning("<spring:message code='Cache.msg_ObjectUR_16' />", 'Warning Dialog', function() {
				$("#txtPriorityOrder").focus();
			});
			return false;
		}

		if ($("#txtDateofBirth").val() != "") {
			var date1 = new Date($("#txtDateofBirth").val().replace(/-/g, "-"));
			var date2 = new Date();
			if (date1 > date2) {
				Common.Warning("<spring:message code='Cache.msg_bad_birthdate' />", 'Warning Dialog', function() {
					$("#txtDateofBirth").focus();
				});
				return false;
			}
		}
		
		if($("#chkUserIPAddress").prop("checked")){ //사용자 IP 주소 체크 여부 확인
			if($("#txtStartIP").val() == ""){
				Common.Warning("<spring:message code='Cache.msg_EnterValueInField' />", 'Warning Dialog', function() { /*필드에 값을 입력하여 주세요. */
					$("#txtStartIP").focus();
				});
				return false;
			}
			
			if(!checkIPAddress($("#txtStartIP").val())){
				Common.Warning("<spring:message code='Cache.msg_ValidationCheck' />", 'Warning Dialog', function() {	/*유효성 체크가 필요합니다 */
					$("#txtStartIP").focus();
				});
				return false;
			}
			
			if($("#txtEndIP").val() == ""){
				Common.Warning("<spring:message code='Cache.msg_EnterValueInField' />", 'Warning Dialog', function() {  /*필드에 값을 입력하여 주세요. */
					$("#txtEndIP").focus();
				});
				return false;
			}

			if(!checkIPAddress($("#txtEndIP").val())){
				Common.Warning("<spring:message code='Cache.msg_ValidationCheck' />", 'Warning Dialog', function() {	/*유효성 체크가 필요합니다 */
					$("#txtEndIP").focus();
				});
				return false;
			}
		}
		
		/* 사용자 계정 생성 시 입사일이 주로 현재보다 뒤인데 체크해서 불편 => 주석처리
	 	if ($("#txtEnterDate").val() != "") {
			var date1 = new Date($("#txtEnterDate").val().replace(/-/g, "-"));
			var date2 = new Date();
			if (date1 > date2) {
				Common.Warning("<spring:message code='Cache.msg_bad_enterdate' />", 'Warning Dialog', function() {
					$("#txtEnterDate").focus();
				});
				return false;
			}
		} */
		
		/* 휴대폰번호 유효성 검사 */
		if($("#txtMobilePhoneNum").val() != ""){
			var regExp = /^01([0|1|6|7|8|9])-?([0-9]{3,4})-?([0-9]{4})$/;
			if(!regExp.test($("#txtMobilePhoneNum").val())){
				Common.Warning("<spring:message code='Cache.msg_hr_phone_num' />", 'Warning Dialog', function() {
					$("#txtMobilePhoneNum").focus();
				});
				return false;
			}
		}
		
		/* 내선번호 유효성 검사 >> 숫자/하이픈(-)만 허용 */
		if($("#txtPhoneNumInter").val() != ""){
			var regExp = /^[0-9-]+$/;
			if(!regExp.test($("#txtPhoneNumInter").val())){
				Common.Warning("<spring:message code='Cache.msg_hr_number_chk' />", 'Warning Dialog', function() {
					$("#txtPhoneNumInter").focus();
				});
				return false;
			}
		}
		
		/* 일반 전화번호 유효성 검사 시작 */
		if($("#txtHomePhoneNum").val() != ""){
			var obj = $("#txtHomePhoneNum").val();
			if(fn_telNoCheck(obj) == false){
				Common.Warning("<spring:message code='Cache.msg_apv_chk_tel_num' />", 'Warning Dialog', function() {
					$("#txtHomePhoneNum").focus();
				});
				return false;
			}
		}
		
		if($("#txtPhoneNum").val() != ""){
			var obj = $("#txtPhoneNum").val();
			if(fn_telNoCheck(obj) == false){
				Common.Warning("<spring:message code='Cache.msg_apv_chk_tel_num' />", 'Warning Dialog', function() {
					$("#txtPhoneNum").focus();
				});
				return false;
			}
		}
		
		if($("#txtFaxNum").val() != ""){
			var obj = $("#txtFaxNum").val();
			if(fn_telNoCheck(obj) == false){
				Common.Warning("<spring:message code='Cache.msg_apv_chk_tel_num' />", 'Warning Dialog', function() {
					$("#txtFaxNum").focus();
				});
				return false;
			}
		}
		
		function fn_telNoCheck(obj){
			var regExp = /^(070|02|0[3-9]{1}[0-9]{1})-?([0-9]{3,4})-?([0-9]{4})$/;
			return regExp.test(obj);
		}
		/* 일반 전화번호 유효성 검사 끝 */
		
		// ================================= AD 설정 ================================= 
		
		if(_isSyncAD == "Y"){
			if ($("#txtLastName").val() == "") {
				Common.Warning("<spring:message code='Cache.msg_ObjectUR_06' />", 'Warning Dialog', function() {
					$("#txtLastName").focus();
				});
				return false;
			} else if ($("#txtFirstName").val() == "") {
				Common.Warning("<spring:message code='Cache.msg_ObjectUR_07' />", 'Warning Dialog', function() {
					$("#txtFirstName").focus();
				});
				return false;
			} else if (($("#selIsAD option:selected").val() == "N") && ($("#selIsMail option:selected").val() == "Y")) {
				Common.Warning("<spring:message code='Cache.msg_ADNotUseMailUseError' />", "Warning Dialog", function(result) {
					$("#selIsMail").focus();
				});
				return false;
			} else if (($("#selIsAD option:selected").val() == "N")
					&& ($("#selIsMSG option:selected").val() == "Y")) {
				Common.Warning("<spring:message code='Cache.msg_ADNotUseMsnUseError' />", "Warning Dialog", function(result) {
					$("#selIsMSG").focus();
				});
				return false;
			}	
		}

		if ( ("Y" == _isSyncMail) && ($("#selIsMail option:selected").val() == "Y") && _mode == "add"){
			if ($("#selMailBoxServer option:selected").val() == "") {
	        	Common.Warning("<spring:message code='Cache.msg_ObjectUR_18' />", "Warning Dialog", function (result) {                 
	            	$("#selMailBoxServer").focus();
	        	});
	        	return false;
	    	}
		}

		if (("Y" == _isSyncMessenger) && _mode == "add") {
			if ($("#txtSIPAddress").val() == "") {
				Common.Warning("<spring:message code='Cache.msg_ObjectUR_19' />", "Warning Dialog", function(result) {
					$("#txtSIPAddress").focus();
				});
				return false;
			}

			if (null != $("#txtSIPAddress")) {
				if ($("#txtSIPAddress").val() != "") {
					var aStrSpecialChar = new Array(";", "'", "^", "%", "!", "&");
					var nLength = aStrSpecialChar.length;
					for (var i = 0; i < nLength; i++) {
						if ($("#txtSIPAddress").val().indexOf(aStrSpecialChar[i]) >= 0) {
							var sMessage = "<spring:message code='Cache.msg_DictionaryInfo_01' />"; // 특수문자 [{0}]는 사용할 수 없습니다.
							sMessage = sMessage.replace(/\{0\}/gi, aStrSpecialChar[i]);
							Common.Warning(sMessage, 'Warning Dialog', function() {
								$("#txtSIPAddress").focus();
							});
							return false;
						}
					}
				}
			}
			if ($("#selTelephonyOptions option:selected").val() == "") {
				Common.Warning("<spring:message code='Cache.msg_ObjectUR_20' />", "Warning Dialog", function(result) { // 전화통신옵션을 선택하여 주십시오.
					$("#selTelephonyOptions").focus();
				});
				return false;
			}
 			if ($("#selServiceType option:selected").val() == "") {
				Common.Warning("<spring:message code='Cache.msg_ObjectUR_21' />", "Warning Dialog", function(result) { // 서비스유형을 선택하여 주십시오.
					$("#selServiceType").focus();
				});
				return false;
			} 
			
			if ($("#selCountry option:selected").val() == "") {
				Common.Warning("<spring:message code='Cache.msg_ObjectUR_22' />", "Warning Dialog", function(result) { // 국가를 선택하여 주십시오.
					$("#selCountry").focus();
				});
				return false;
			}
		}

		// ================================= 결재 설정 =================================

		if ($("#selIsDeputy option:selected").val() == "Y") {
			if ($("#txtDeputyApprovalName").val() == ""&&$("[name=rdoDeputyOption]:checked").val()=="Y") {//대리자사용
				Common.Warning("<spring:message code='Cache.msg_apv_344' />", "Warning Dialog", function(result) { //대결자를 입력하십시오.                 
					$("#txtDeputyApprovalName").focus();
				});
				return false;
			} else if ($("#txtDeputyDateStart").val() == "") {
				Common.Warning("<spring:message code='Cache.msg_EnterStartDate' />", "Warning Dialog", function(result) { //시작일자를 입력하십시오.                 
					$("#txtDeputyDateStart").focus();
				});
				return false;
			} else if ($("#txtDeputyDateEnd").val() == "") {
				Common.Warning("<spring:message code='Cache.msg_EnterEndDate' />", "Warning Dialog", function(result) { //종료일자를 입력하세요             
					$("#txtDeputyDateEnd").focus();
				});
				return false;
			} else {
				var sdate = new Date($("#txtDeputyDateStart").val().replace(/-/g, "-"));
				var edate = new Date($("#txtDeputyDateEnd").val().replace(/-/g, "-"));

				if (sdate > edate) {
					Common.Warning("<spring:message code='Cache.msg_bad_period' />", "Warning Dialog", function(result) { //시작일이 종료일보다 클 수 없습니다.             
						$("#txtDeputyDateEnd").focus();
					});
					return false;
				}
			}
		}

		// ================================= 부가 설정 =================================
           //추가속성 :: Primary, Secondary값 HiddenField에 저장합니다.
           var aObjectTR = $("#divAttributeList > TABLE > TBODY > TR");

           if ("Y" == _isSyncMail) {
               $("#hidSecondary").val("");
               var nLength = aObjectTR.length;

               for (var i = 1; i < nLength; i++) {
                   if (i == nLength - 1) {
                	   $("#hidSecondary").val($("#hidSecondary").val()+aObjectTR.filter(":eq(" + i.toString() + ")").text());
                   } else {
                	   $("#hidSecondary").val($("#hidSecondary").val()+aObjectTR.filter(":eq(" + i.toString() + ")").text() + "|");
                   }
               }

               $("#hidPrimary").val(aObjectTR.filter(":eq(0)").text());

               if ($("#selIsMail").val() == "Y") {
                   if (aObjectTR.filter(":eq(0)").text() == "") {
                       parent.Common.Warning("<spring:message code='Cache.msg_Common_37' />", "Warning Dialog", function () {                       // 메일주소를 입력하여 주십시오.
                           clickTab($("#userADSetTab"));
                       });
                       return false;
                   }
               }
           }

		if ($("#selSecurityLevel option:selected").val() == "" || $("#selSecurityLevel option:selected").val() == undefined) {
			Common.Warning("<spring:message code='Cache.msg_ObjectUR_26' />", "Warning Dialog", function(result) { // 보안등급을 선택하여 주십시오.
				$("#selSecurityLevel").focus();
			});
			return false;
		} 
		// validation check 끝, 저장 시작

		now = new Date();
		now = XFN_getDateTimeString("yyyy-MM-dd HH:mm:ss", now);

		url = "/covicore/manage/conf/insertUpdateUserInfo.do";
		message = "<spring:message code='Cache.msg_117'/>";
		if (_mode == "modify") {
			message = "<spring:message code='Cache.msg_137'/>"
		}
		
		if(_mode == "add"){
			if(Common.getGlobalProperties("isSaaS") == "Y") {
				if($("#txtPfx").text() != "") {
					var sUserCode = $("#txtPfx").text() + $("#txtUserCode").val();
					$("#txtUserCode").val(sUserCode);	
				}
				
				$("#txtLogonID").val($("#txtLogonIDSaaS").val() + "@" + $("#selMailDomainSaaS").val());
			}
		}
		
		var CompleteApprovalType = '"COMPLETE":';
		
		if($("#selCompleteYN option:selected").val() == "Y") {
			CompleteApprovalType += '"Y;';
			$("input[type=checkbox][name=chkCompleteApprovalType]:checked").each(function() {
				CompleteApprovalType += $(this).val() + ';';
			});
			CompleteApprovalType += '"';
		} else {
			CompleteApprovalType += '"N;"';
		}
		ApprovalArrivalMedium = '{"mailconfig":{"APPROVAL":"N;",' + CompleteApprovalType + ',"REJECT":"N;","CCINFO":"N;","CIRCULATION":"N;","HOLD":"N;","WITHDRAW":"N;","ABORT":"N;","APPROVECANCEL":"N;","REDRAFT":"N;","CHARGEJOB":"N;"}}';
		var AlertConfig =$("#hidAlertConfig").val();
		if(AlertConfig != ""){
			 var oAlertConfig = JSON.parse(AlertConfig);
			 oAlertConfig.COMPLETE = CompleteApprovalType;
			 ApprovalArrivalMedium = JSON.stringify(oAlertConfig);			
		}
		if(added_file == undefined) added_file = "";

		//기존 임직원 메일사서함 신규 생성시
		//실제 메일박스 있는지 체크X, 메일사용여부로 체크
		if ("Y" == _isSyncIndi 
			&& $("#selIsCPMail option:selected").val() == "Y"
			&& $("#hidOldIsCPMail").val() != "Y"
			&& _mode == "modify"
			)
		{
			Common.Confirm("<spring:message code='Cache.msg_haveToChangePw'/>", "Confirmation Dialog", function (result) { 
				if(result)
					CheckValidationSub(true);
			});
		}
		else{
			CheckValidationSub(false);
		}

		//TODO
		function CheckValidationSub(bInitPW){
			var formData;
	
			formData = new FormData();
			//formData.append("domainId", _domainId);
			formData.append("InitPW", bInitPW?"Y":"N");
			formData.append("mode", _mode);
			formData.append("FileInfo", added_file.length > 0 ? added_file[0] : "");
			formData.append("RegionName", $("#txtPlaceOfBusiness").val());
			formData.append("SecurityLevel", $("#selSecurityLevel option:selected").val());
			formData.append("UseMailConnect", $("#selIsCPMail option:selected").val());
			formData.append("LicSeq", $("#selLicSeq option:selected").val());
			formData.append("MailAddress", $('#txtMailID').val() != "" ? $('#txtMailID').val() + '@' + $('#selMailDomain').val() : "");
			formData.append("MailBoxServer", $("#selMailBoxServer option:selected").val());
			formData.append("MailDomainList", $("#selMailList option:selected").val());
			formData.append("UseMessengerConnect", $("#selIsEUM option:selected").val());
			formData.append("ServiceType", $("#selServiceType option:selected").val());
			formData.append("ApprovalDeptCode", $("#hidApprovalDeptCode").val());
			formData.append("ReceiptDeptCode", $("#hidReceiptDeptCode").val());
			formData.append("IsPhoneApproval", $("#selPhoneApproval option:selected").val());
			formData.append("SIPAddress", $("#txtSIPAddress").val());
			formData.append("RegistDate", now);
			/*********추가 DB 기본 정보**********/
			formData.append("UserCode", $("#txtUserCode").val());
			//DN_ID
			formData.append("CompanyCode", $("#hidCompanyCode").val());
			formData.append("DeptCode", $("#hidDeptCode").val());
			formData.append("oldDeptCode", $("#hidOldGroupCode").val());
			formData.append("oldCompanyCode", $("#hidOldCompanyCode").val());
			formData.append("LogonID", $("#txtLogonID").val());		
			formData.append("Password", $("#txtPassword").val());
			formData.append("EmpNo", $("#txtUserEmpNo").val());
			formData.append("DisplayName", $("#txtUserDisplayName").val());
			formData.append("MultiDisplayName", $("#UserDisplayNameHidden").val());
			//ExGroupName
			formData.append("RegionCode", $("#hidPlaceOfBusiness").val());
			//ExRregionName
			formData.append("JobPositionCode", $("#selJobPosition option:selected").val());
			formData.append("JobPositionName", $("#selJobPosition option:selected").text() != "선택" ?  $("#selJobPosition option:selected").text() : "");
			formData.append("JobTitleCode", $("#selJobTitle option:selected").val());
			formData.append("JobTitleName", $("#selJobTitle option:selected").text() != "선택" ?  $("#selJobTitle option:selected").text() : "");
			formData.append("JobLevelCode", $("#selJobLevel option:selected").val());
			formData.append("JobLevelName", $("#selJobLevel option:selected").text() != "선택" ?  $("#selJobLevel option:selected").text() : "");
			formData.append("SortKey", $("#txtPriorityOrder").val());
			//Description
			formData.append("IsUse", $("#selIsUse option:selected").val());
			formData.append("IsHR", $("#selIsHR option:selected").val());
			formData.append("EnterDate", $("#txtEnterDate").val());
			formData.append("RetireDate", $("#txtRetireDate").val());
			formData.append("PhotoPath", $("#txtImagePath").val());
			formData.append("IsDisplay", $("#selIsDisplay option:selected").val());
			formData.append("BirthDiv", $("input[type=radio][name=rdoSolarLunar]:checked").length > 0 ? $("input[type=radio][name=rdoSolarLunar]:checked").val() : "");
			formData.append("BirthDate", $("#txtDateofBirth").val());
			formData.append("ExtMail", $('#txtExtMail').val() != "" ? $('#txtExtMail').val() + '@' + $('#txtExtMailDomain').val() : "");
			formData.append("ChargeBusiness", $("#txtChargeBusiness").val());
			formData.append("Role", $("#txtRole").val());
			formData.append("PhoneNumberInter", $("#txtPhoneNumInter").val());
			formData.append("CheckUserIP", $("#chkUserIPAddress").prop("checked") ? "Y":"N");
			formData.append("StartIP", $("#txtStartIP").val());
			formData.append("EndIP", $("#txtEndIP").val());
			formData.append("IsCRM", $("#selIsCRM").val());
			
			//LanguageCode
			formData.append("MobileThemeCode", "MobileTheme_Base");
			formData.append("TimeZoneCode", "TIMEZO0048");
			formData.append("InitPortal", "-1");
			
			formData.append("Reserved1", $("#hidReserved1").val());
			formData.append("Reserved2", $("#hidReserved2").val());
			formData.append("Reserved3", $("#hidReserved3").val());
			formData.append("Reserved4", $("#hidReserved4").val());
			formData.append("Reserved5", $("#hidReserved5").val());
			
			/*********추가 AD **********/
			if($("#selIsAD option:selected").val() != "" && $("#selIsAD option:selected").val() != undefined && $("#selIsAD option:selected").val() != "undefined"){
				formData.append("IsAD", $("#selIsAD option:selected").val());
			} else {
				formData.append("IsAD", "N");
			}
			
			formData.append("AD_CN", $("#txtAD_CN").val());
			formData.append("AD_SamAccountName", $("#txtAD_SamAccountName").val());
			formData.append("AD_UserPrincipalName", $("#txtAD_UserPrincipalName").val());
			formData.append("AD_DisplayName", $("#hidAD_DisplayName").val());
			formData.append("FirstName", $("#txtFirstName").val());
			formData.append("LastName", $("#txtLastName").val());
			formData.append("Initials", $("#txtInitials").val());
			formData.append("OfficeAddress", $("#txtOfficeAddress").val());
			formData.append("WebPage", $("#txtWebPage").val());
			formData.append("Country", $("#selCountry option:selected").text());
			if($("#selCountry option:selected").val() != "" && $("#selCountry option:selected").val() != undefined && $("#selCountry option:selected").val() != "undefined"){
	            var CountryID_Code = $("#selCountry option:selected").val();
	            var sAD_CountryID = "";
	            var sAD_CountryCode = "";
	            
	            if (CountryID_Code.indexOf("/") != -1)
	            {
	                sAD_CountryID = CountryID_Code.split('/')[0];
	                sAD_CountryCode = CountryID_Code.split('/')[1];
	            }
				formData.append("AD_CountryID", sAD_CountryID);
				formData.append("AD_CountryCode", sAD_CountryCode);
			}else{
				formData.append("AD_CountryID", "");
				formData.append("AD_CountryCode", "");
			}
			formData.append("CityState_01", $("#txtCityState_01").val());
			formData.append("CityState_02", $("#txtCityState_02").val());
			formData.append("Address", $("#txtAddress").val());
			formData.append("MailBox", $("#txtMailBox").val());
			formData.append("ZipCode", $("#txtZipCode").val());
			formData.append("AD_UserAccountControl", $("#hidAD_UserAccountControl").val());
			formData.append("AD_AccountExpires", $("#hidAD_AccountExpires").val());
			formData.append("PhoneNumber", $("#txtPhoneNum").val());
			formData.append("HomePhone", $("#txtHomePhoneNum").val());
			formData.append("AD_Pager", $("#hidAD_Pager").val());
			formData.append("Mobile", $("#txtMobilePhoneNum").val());
			formData.append("Fax", $("#txtFaxNum").val());
			formData.append("AD_Info", $("#hidAD_Info").val());
			formData.append("AD_Title", $("#selJobPosition option:selected").text());
			formData.append("DeptName", $("#txtDeptName").val());
			formData.append("CompanyName", $("#txtCompanyName").val());
			formData.append("ManagerCode", $("#hidAdminSettingCode").val());
			
			/*********추가 Exchange **********/
			if($("#selIsMail option:selected").val() != "" && $("#selIsMail option:selected").val() != undefined && $("#selIsMail option:selected").val() != "undefined"){
				formData.append("EX_IsUse", $("#selIsMail option:selected").val());
			} else {
				formData.append("EX_IsUse", "N");
			}
			
			formData.append("EX_PrimaryMail", $("#hidPrimary").val());
			formData.append("EX_SecondaryMail", $("#hidSecondary").val());
			
			if($("#selMailBoxServer option:selected").val() != "" && $("#selMailBoxServer option:selected").val() != undefined && $("#selMailBoxServer option:selected").val() != "undefined"){
				var sExStorage =$("#selMailBoxServer option:selected").val();
				var sExStorage_Server = "";
	            var sExStorage_Group = "";
				if (sExStorage.indexOf("/") != -1)
				{
					sExStorage_Server = sExStorage.split('/')[0];
					sExStorage_Group = sExStorage.split('/')[1];
				}
				formData.append("EX_StorageServer", sExStorage_Server);
				formData.append("EX_StorageGroup", sExStorage_Group);
			}else{
				formData.append("EX_StorageServer", "");
				formData.append("EX_StorageGroup", "");
			}
			formData.append("hidEX_StorageStore", "");
			formData.append("EX_CustomAttribute01", $("#hidMailAttribute1").val());
			formData.append("EX_CustomAttribute02", $("#hidMailAttribute2").val());
			formData.append("EX_CustomAttribute03", $("#hidMailAttribute3").val());
			formData.append("EX_CustomAttribute04", $("#hidMailAttribute4").val());
			formData.append("EX_CustomAttribute05", $("#hidMailAttribute5").val());
			formData.append("EX_CustomAttribute06", $("#hidMailAttribute6").val());
			formData.append("EX_CustomAttribute07", $("#hidMailAttribute7").val());
			formData.append("EX_CustomAttribute08", $("#hidMailAttribute8").val());
			formData.append("EX_CustomAttribute09", $("#hidMailAttribute9").val());
			formData.append("EX_CustomAttribute10", $("#hidMailAttribute10").val());
			formData.append("EX_CustomAttribute11", $("#hidMailAttribute11").val());
			formData.append("EX_CustomAttribute12", $("#hidMailAttribute12").val());
			formData.append("EX_CustomAttribute13", $("#hidMailAttribute13").val());
			formData.append("EX_CustomAttribute14", $("#hidMailAttribute14").val());
			formData.append("EX_CustomAttribute15", $("#hidMailAttribute15").val());
			
			/*********추가 Messenger **********/
			if($("#selIsMSG option:selected").val() != "" && $("#selIsMSG option:selected").val() != undefined && $("#selIsMSG option:selected").val() != "undefined"){
				formData.append("IsMSG", $("#selIsMSG option:selected").val());
			} else {
				formData.append("IsMSG", "N");
			}
			
			formData.append("MSN_PoolServerName", $("#hidMSN_PoolServerName").val());
			formData.append("MSN_PoolServerDN", $("#hidMSN_PoolServerDN").val());
			formData.append("MSN_SIPAddress", $("#txtSIPAddress").val()+"@"+$("#selMailList option:selected").val());
			formData.append("MSN_Anonmy", $("#hidMSN_Anonmy").val());
			formData.append("MSN_MeetingPolicyName", $("#selServiceType option:selected").val());
			formData.append("MSN_MeetingPolicyDN", $("#hidMSN_MeetingPolicyDN").val());
			formData.append("TelephonyOptions", $("#selTelephonyOptions option:selected").val());
			formData.append("MSN_PBX", $("#hidMSN_PBX").val());		
			formData.append("MSN_LinePolicyName", $("#hidMSN_LinePolicyName").val());
			formData.append("MSN_LinePolicyDN", $("#hidMSN_LinePolicyDN").val());
			formData.append("MSN_LineURI", $("#hidMSN_LineURI").val());
			
			formData.append("MSN_LineServerURI", $("#hidMSN_LineServerURI").val());
			formData.append("MSN_Federation", $("#hidMSN_Federation").val());
			formData.append("MSN_RemoteAccess", $("#hidMSN_RemoteAccess").val());
			formData.append("MSN_PublicIMConnectivity", $("#hidMSN_PublicIMConnectivity").val());
			formData.append("MSN_InternalIMConversation", $("#hidMSN_InternalIMConversation").val());
			formData.append("MSN_FederatedIMConversation", $("#hidMSN_FederatedIMConversation").val());
	
			/*********추가 Approval **********/
			formData.append("IsDeputy", $("#selIsDeputy option:selected").val());
			formData.append("DeputyApprovalCode", $("#hidDeputyApprovalCode").val());
			formData.append("DeputyApprovalName", $("#txtDeputyApprovalName").val());
			formData.append("DeputyDateStart", $("#txtDeputyDateStart").val());
			formData.append("DeputyDateEnd", $("#txtDeputyDateEnd").val());
			formData.append("ApprovalArrival_YN", $("#selCompleteYN option:selected").val());
			formData.append("CompleteApprovalType", ApprovalArrivalMedium);
			formData.append("DeputyOption", $("input[type=radio][name=rdoDeputyOption]:checked").length > 0 ? $("input[type=radio][name=rdoDeputyOption]:checked").val() : "");
			//ApprovalComplete_YN
			//ApprovalCompleteMedium
			//ApprovalUnitCode
			//ReceiptUnitCode
			//ApprovalCode
			//ApprovalFullCode
			//ApprovalFullName
			//ApprovalPassword
			//AbsentReason
			//ApprovalTempListView
			//ApprovalMessageBoxView
			//ApprovalMobileUse_YN
			if($("#selCountry option:selected").val() != "" && $("#selCountry option:selected").val() != undefined && $("#selCountry option:selected").val() != "undefined"){
	            var CountryID_Code = $("#selCountry option:selected").val();
	            var sAD_CountryID = "";
	            var sAD_CountryCode = "";
	            
	            if (CountryID_Code.indexOf("/") != -1)
	            {
	                sAD_CountryID = CountryID_Code.split('/')[0];
	                sAD_CountryCode = CountryID_Code.split('/')[1];
	            }
	            
			}
			formData.append("CityState_01", $("#txtCityState_01").val());
			formData.append("CityState_02", $("#txtCityState_02").val());
			formData.append("MailBox", $("#txtMailBox").val());
			formData.append("ZipCode", $("#txtZipCode").val());
			formData.append("Address", $("#txtAddress").val());
			formData.append("OfficeAddress", $("#txtOfficeAddress").val());
			formData.append("Role", $("#txtRole").val());
			formData.append("RegistDate", now);
			
			Common.Progress(Common.getDic('msg_apv_008'));
			
			$.ajax({
				type : "POST",
				data : formData,
				dataType : 'json',
				processData : false,
				contentType : false,
				url : url,
				success : function(data) {
					if(data.ReturnMsg!=''&&data.ReturnMsg.indexOf('FAIL')>-1)
					{
						message = data.ReturnMsg.replaceAll('|','');
						Common.Inform(message, "Information Dialog"); 
					}
					else if (data.result == "OK" && data.status == "SUCCESS")
						Common.Inform(message, "Information Dialog", function(result) {
							if (result) {
								//parent.window.location.reload();
								parent.pageObj.bindGridUser();
								closePopup();
							}
						});
					else if (data.status=="FAIL") 
						Common.Error(data.message);
				}, 
				error : function(response, status, error) {
					CFN_ErrorAjax(url, response, status, error);
				}
			});
		}
	}

	var writeNum = function(obj) {
		// Validation Chk
		var inputKey = event.key;
		var inputBox = $(obj);
		var value = inputBox.val();

		if (_ie) {
			if (inputKey == "Decimal")
				inputKey = ".";
		}

		// 숫자 및 소수점이 아닌 문자 치환
		value = value.replace(/[^0-9.]/g, '');

		value = value == "" ? "0" : value;

		// 숫자형식으로 변경
		// 숫자형식이거나 event에 바인딩되어 넘어오지 않은경우
		if (inputKey != ".") {
			//반올림 첫번째자리까지			
			value = parseFloat(value);

			inputBox.val(value);

		} else if (inputKey == ".") {
			inputBox.val(value);
		}
		return false;
	};
	

    //성, 이름 입력하면 자동으로 성명에 입력하기
	function fn_AutoNameInput() {
        $("#txtUserDisplayName").val($("#txtLastName").val() + $("#txtFirstName").val());

        if ("Y" == _isSyncAD) {
            $("#hidAD_DisplayName").val($("#txtLastName").val() + $("#txtFirstName").val());
        }
    }
    
 	// 추가속성 추가버튼 클릭시 호출되며, 추가속성 추가를 위한 팝업을 화면에 표시합니다.
	function btnMailAdd_OnClick() {
    	  var sMailID = $("#txtUserCode").val();
    	  $("#hidMailAddressInfo").val("");
          ShowMailAttributeSetting(sMailID, "0", "Add");
    }
		
	function ShowMailAttributeSetting(sMail, nIndex, sMode) {		
		var sOpenName = "divAttribute";
		var sURL = "/covicore/mailaddressattributepop.do";
		sURL += "?iframename=divUserInfo";
        sURL += "&openname=" + sOpenName;
        sURL += "&mailaddress=hidMailAddressInfo";
        sURL += "&mail=" + sMail;
        sURL += "&index=" + nIndex;
        sURL += "&mode=" + sMode;
        sURL += "&callbackmethod=btnAttributeAdd_OnClick_After&grouptype=User";
		/*
		 sURL += "?IframeName=divUserInfo";
         sURL += "&OpenName=" + sOpenName;
         sURL += "&MailAddress=hidMailAddressInfo";
         sURL += "&Mail=" + sMail;
         sURL += "&Index=" + nIndex;
         sURL += "&Mode=" + sMode;
         sURL += "&CallBackMethod=btnAttributeAdd_OnClick_After&GroupType=User";
*/
         var aStrDictionary = null;
         var sTitle = "";
         if ($("#hidMailAddressInfo").val() == "") {
             sTitle = "<spring:message code='Cache.lbl_ResourceManage_06'/>" + " ||| " + "<spring:message code='Cache.msg_ResourceManage_06'/>";
         }
         else {
             sTitle = "<spring:message code='Cache.lbl_ResourceManage_07'/>" + " ||| " + "<spring:message code='Cache.msg_ResourceManage_07'/>";
         }

		parent.Common.open("", "divAttribute", sTitle, sURL, "500px", "150px", "iframe", true, null, null, true);
	}
    
    // 추가 속성을 입력받은 후 호출되는 함수로, 선택된 추가 속성 정보를 화면에 표시합니다.
	function btnAttributeAdd_OnClick_After(pStrAttributeInfo) {
        var sHTML = "";

        if ((pStrAttributeInfo != null) && (pStrAttributeInfo != "")) {

            $($.parseXML(pStrAttributeInfo)).find("Attribute").find("Mail").each(function () {
                sHTML = "";

                var sMail = $(this).text();
                var sAttributeID = $(this).parent().find("AttributeID").text();
                var sIndex = $(this).parent().find("Index").text();
                var sMode = $(this).parent().find("Mode").text();

                var nIndex = $("#divAttributeList").children("TABLE").children("TBODY").children("TR").length;
                var oTR = $("#divAttributeList").children("TABLE").children("TBODY").children("TR");
                var oTD = $("#divAttributeList").children("TABLE").children("TBODY").children("TR").children("TD");

                if (sMode == "Add") {
                    for (var i = 0; i < oTR.length; i++) {
                        if ($(oTD[i]).children("A").text() == sMail) {
                            Common.Warning("<spring:message code='Cache.lbl_EmailAddresSame'/>", "Warning Dialog");  //메일주소가 같습니다 다시 작성하여 주십시오.
                            return;
                        }
                    }
                }
                else if (sMode == "Edit") {
                    for (var i = 0; i < oTR.length; i++) {
                        if ($(oTD[i]).children("A").text() == sMail) {
                            if (sIndex != "0") {
                                $(oTD[i]).children("A")[0].href = "javascript:ShowMailAttributeSetting('" + sMail + "', '" + i + "', 'Edit');"
                                $(oTD[i]).children("A").text(sMail);
                                $("TD[Index=" + sIndex + "]").remove();
                                return;
                            }
                        }
                    }
                    if (sIndex != "") {
                        $(oTD[sIndex]).children("A")[0].href = "javascript:ShowMailAttributeSetting('" + sMail + "', '" + sIndex + "', 'Edit');"
                        $(oTD[sIndex]).children("A").text(sMail);
                        return;
                    }
                }

                if ($("#divAttributeList").children().length == 0) {
                    sHTML += "<tr Mail=\"Primary\">";
                    sHTML += "<td class=\"t_back01_line\" width=\"10\" Index='" + nIndex + "'>";
                    sHTML += "<input id=\"chkAttribute_" + nIndex + "\" type=\"checkbox\" style=\"cursor: pointer;\" class=\"input_check\" />";
                    sHTML += "<a href=\"javascript:ShowMailAttributeSetting('" + sMail + "', '" + nIndex + "', 'Edit');\" style=\"font-size:10pt;font-weight:bold\">";
                    sHTML += sMail;
                    sHTML += "</a>";
                    sHTML += "</td>";
                }
                else {
                    sHTML += "<tr Mail=\"Secondary\">";
                    sHTML += "<td class=\"t_back01_line\" width=\"10\" Index='" + nIndex + "'>";
                    sHTML += "<input id=\"chkAttribute_" + nIndex + "\" type=\"checkbox\" style=\"cursor: pointer;\" class=\"input_check\" />";
                    sHTML += "<a href=\"javascript:ShowMailAttributeSetting('" + sMail + "', '" + nIndex + "', 'Edit');\" style=\"font-size:10pt;\">";
                    sHTML += sMail;
                    sHTML += "</a>";
                    sHTML += "</td>";
                }
                sHTML += "</tr>";

                if ($("#divAttributeList").children().length <= 0) {
                    sHTML = "<table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\">" + sHTML + "</table>";
                    $("#divAttributeList").append(sHTML);
                }
                else {
                    $("#divAttributeList").children("TABLE").children("TBODY").append(sHTML);
                }
            });
        }
    }
    // 추가속성 삭제버튼 클릭시 호출되며, 선택된 추가속성을 삭제합니다.
	function btnMailDel_OnClick() {
        if ($("input[id^='chkAttribute_']:checked").length > 0) {
            Common.Confirm("<spring:message code='Cache.msg_Common_08' />", 'Confirmation Dialog', function (result) {       // 선택한 항목을 삭제하시겠습니까?
                if (result) {
                    $("input[id^='chkAttribute_']:checked").each(function () {
                        $(this).parent().parent().remove();
                    });
                }
                if ($("#divAttributeList > TABLE > TBODY >TR").length == 0) {
                    $("#divAttributeList").html("");
                }
            });
        }
        else {
            Common.Warning("<spring:message code='Cache.msg_Common_03' />", "Warning Dialog", function () { });          // 삭제할 항목을 선택하여 주십시오.
            return;
        }
    }
    // 추가속성 위로버튼 클릭시 호출되며, 선택된 추가속성의 우선순위를 한단계 올립니다.
	function btnMailUp_OnClick() {
        var bSelected = false;
        $("input[id^='chkAttribute_']:checked").each(function () {
            bSelected = true;
        });

        if (!bSelected) {
            Common.Warning("<spring:message code='Cache.msg_Common_09' />", "Warning Dialog", function () { });      // 이동할 항목을 선택하여 주십시오.
            return;
        }

        var oPrevTR = null;
        var oNowTR = null;

        var oResult = null;
        var bSucces = true;
        var sResult = "";
        var sErrorMessage = "";

        var aObjectTR = $("#divAttributeList > TABLE > TBODY > TR");
        var nLength = aObjectTR.length;
        for (var i = 0; i < nLength; i++) {
            if (!aObjectTR.filter(":eq(" + i.toString() + ")").children("TD").children("INPUT").is(":checked")) {
                continue;
            }

            // 현재 행: 위에서부터 선택 되어 있는 행 찾기
            oNowTR = aObjectTR.filter(":eq(" + i.toString() + ")");

            // 이전 행 찾기: 현재 행 기준 위에서 선택 안되어 있는 행 찾기
            oPrevTR = null;
            for (var j = i - 1; j >= 0; j--) {
                if (aObjectTR.filter(":eq(" + j.toString() + ")").children("TD").children("INPUT").is(":checked")) {
                    continue;
                }
                oPrevTR = aObjectTR.filter(":eq(" + j.toString() + ")");
                break;
            }
            if (oPrevTR == null) {
                continue;
            }

            oPrevTR.insertAfter(oNowTR);

            if (oPrevTR.attr("Mail") == "Primary") {
                oPrevTR.removeAttr("Mail");
                oPrevTR.attr("Mail", "Secondary");
                oNowTR.removeAttr("Mail");
                oNowTR.attr("Mail", "Primary");

                $(oNowTR).children("TD").children("a").css({ "font-weight": "bold" });
                $(oPrevTR).children("TD").children("a").css({ "font-weight": "" });
            }
        }
        if (sErrorMessage != "") {
            Common.Error(sErrorMessage, "Error Dialog", function () { });
        }
    }
    // 추가속성 아래로버튼 클릭시 호출되며, 선택된 추가속성의 우선순위를 한단계 내립니다.
	function btnMailDown_OnClick() {
        var bSelected = false;
        $("input[id^='chkAttribute_']:checked").each(function () {
            bSelected = true;
        });

        if (!bSelected) {
            Common.Warning("<spring:message code='Cache.msg_Common_09' />", "Warning Dialog", function () { });      // 이동할 항목을 선택하여 주십시오.
            return;
        }

        var oNextTR = null;
        var oNowTR = null;

        var oResult = null;
        var bSucces = true;
        var sResult = "";
        var sTemp = "";
        var sErrorMessage = "";

        var aObjectTR = $("#divAttributeList > TABLE > TBODY > TR");
        var nLength = aObjectTR.length;
        for (var i = nLength; i >= 0; i--) {
            if (!aObjectTR.filter(":eq(" + i.toString() + ")").children("TD").children("INPUT").is(":checked")) {
                continue;
            }

            // 현재 행: 아래에서부터 선택되어 있는 행 찾기
            oNowTR = aObjectTR.filter(":eq(" + i.toString() + ")");

            // 다음 행 찾기: 현재 행 기준 아래에서 선택 안되어 있는 행 찾기
            oNextTR = null;
            for (var j = i + 1; j < nLength; j++) {
                if (aObjectTR.filter(":eq(" + j.toString() + ")").children("TD").children("INPUT").is(":checked")) {
                    continue;
                }
                oNextTR = aObjectTR.filter(":eq(" + j.toString() + ")");
                break;
            }
            if (oNextTR == null) {
                continue;
            }

            oNowTR.insertAfter(oNextTR);

            if (oNowTR.attr("Mail") == "Primary") {
                oNowTR.removeAttr("Mail");
                oNowTR.attr("Mail", "Secondary");
                oNextTR.removeAttr("Mail");
                oNextTR.attr("Mail", "Primary");

                $(oNextTR).children("TD").children("a").css({ "font-weight": "bold" });
                $(oNowTR).children("TD").children("a").css({ "font-weight": "" });
            }
        }
        if (sErrorMessage != "") {
            Common.Error(sErrorMessage, "Error Dialog", function () { });
        }
    }
    //추가속성 메일속성 값
	function btnMailAttributeAdd_OnClick() {
        var sOpenName = "divMailAttribute";
        var sURL = "/covicore/mailattributepop.do";
        sURL += "?iframename=divUserInfo";
        sURL += "&openname=" + sOpenName;
        sURL += "&attributes=hidMailAttribute";
        sURL += "&callbackmethod=btnMailAttributeAdd_OnClick_After";

        var aStrDictionary = null;
        var sTitle = "";
        if ($("#hidMailAddressInfo").val() == "") {
            sTitle = "<spring:message code='Cache.lbl_ResourceManage_06'/>" + " ||| " + "<spring:message code='Cache.msg_ResourceManage_06'/>";
        }
        else {
            sTitle = "<spring:message code='Cache.lbl_ResourceManage_07'/>" + " ||| " + "<spring:message code='Cache.msg_ResourceManage_07'/>";
        }
        parent.Common.open("", "divMailAttribute", sTitle, sURL, "380px", "550px", "iframe", true, null, null, true);
    }
    // 추가 속성 메일속성 값을 히든필드에 입력
	function btnMailAttributeAdd_OnClick_After(pStrAttributeInfo) {
        var sHTML = "";

        if ((pStrAttributeInfo != null) && (pStrAttributeInfo != "")) {
        	$("#hidMailAttribute").val(pStrAttributeInfo);
        	$("#hidMailAttribute1").val($($.parseXML(pStrAttributeInfo)).find("Attribute").find("Attribute_1").text());
        	$("#hidMailAttribute2").val($($.parseXML(pStrAttributeInfo)).find("Attribute").find("Attribute_2").text());
        	$("#hidMailAttribute3").val($($.parseXML(pStrAttributeInfo)).find("Attribute").find("Attribute_3").text());
        	$("#hidMailAttribute4").val($($.parseXML(pStrAttributeInfo)).find("Attribute").find("Attribute_4").text());
        	$("#hidMailAttribute5").val($($.parseXML(pStrAttributeInfo)).find("Attribute").find("Attribute_5").text());
        	$("#hidMailAttribute6").val($($.parseXML(pStrAttributeInfo)).find("Attribute").find("Attribute_6").text());
        	$("#hidMailAttribute7").val($($.parseXML(pStrAttributeInfo)).find("Attribute").find("Attribute_7").text());
        	$("#hidMailAttribute8").val($($.parseXML(pStrAttributeInfo)).find("Attribute").find("Attribute_8").text());
        	$("#hidMailAttribute9").val($($.parseXML(pStrAttributeInfo)).find("Attribute").find("Attribute_9").text());
        	$("#hidMailAttribute10").val($($.parseXML(pStrAttributeInfo)).find("Attribute").find("Attribute_10").text());
        	$("#hidMailAttribute11").val($($.parseXML(pStrAttributeInfo)).find("Attribute").find("Attribute_11").text());
        	$("#hidMailAttribute12").val($($.parseXML(pStrAttributeInfo)).find("Attribute").find("Attribute_12").text());
        	$("#hidMailAttribute13").val($($.parseXML(pStrAttributeInfo)).find("Attribute").find("Attribute_13").text());
        	$("#hidMailAttribute14").val($($.parseXML(pStrAttributeInfo)).find("Attribute").find("Attribute_14").text());
        	$("#hidMailAttribute15").val($($.parseXML(pStrAttributeInfo)).find("Attribute").find("Attribute_15").text());
        }
    }
    
    // 사용자 AD 사용 안 함 처리 시, UserAccountControl 값 변경
	function selIsAD_Changed() {
        if ($("#selIsAD option:selected").val() == "N") {
            $("#hidAD_UserAccountControl").val("66050");
            $("[name='ADAccountArea']").hide();
        }
        if ($("#selIsAD option:selected").val() == "Y") {
            $("#hidAD_UserAccountControl").val("66048");
            $("[name='ADAccountArea']").show();
        }
    }

    // 메일사용여부를 사용안함으로 변경시 추가설정에 메일영역이 Display None/Block 처리됨
	function selIsMail_Changed() {
        if ($("#selIsMail option:selected").val() == "N") {
            //$("#divMail").css({ "display": "none" });
            $("[name='MailArea']").hide();
        }
        if ($("#selIsMail option:selected").val() == "Y") {
            //$("#divMail").css({ "display": "" });
        	$("[name='MailArea']").show();
        }
    }
    // 메신저사용여부를 사용안함으로 변경시 추가설정에 메일영역이 Display None/Block 처리됨
	function selIsMSG_Changed() {
        if ($("#selIsMSG option:selected").val() == "N") {
            //$("#divMessenger").css({ "display": "none" });
        	$("[name='MessengerArea']").hide();
        }
        if ($("#selIsMSG option:selected").val() == "Y") {
            //$("#divMessenger").css({ "display": "" });
            $("[name='MessengerArea']").show();
        }
    }
	function selIsDeputy_Changed() { 
        if ($("#selIsDeputy option:selected").val() == "Y") {
			$("[name=DeputyApprovalInfo]").show();
        }
		else{
			$("[name=DeputyApprovalInfo]").find("input[type=text]").val('');
			$("[id=rdoDeputyOption_Y]").prop('checked',true);
			$("[name=DeputyApprovalInfo]").find("select").val('');
			$("[name=DeputyApprovalInfo]").hide();
		}
		coviInput.setDate();
    }
	function optDeputyOption_Changed() {
		var rdoDeputyOption = $("[name=rdoDeputyOption]:checked").val()
		if (rdoDeputyOption == 'P') {//부재중
			$("#txtDeputyApprovalName").val('')
			$("#hidDeputyApprovalCode").val('')
			$("#btnDeputyApprovalUser").attr("disabled", "disabled");
		}         
		else
			$("#btnDeputyApprovalUser").removeAttr('disabled');
    }
    
	function makesadmin_tableData (dataList, codeGroup, locale){
	    for(var i = 0; i < dataList.length; i++) {
		    var obj = dataList[i];
		    if(obj.hasOwnProperty(codeGroup)){
		    	var codeArray = obj[codeGroup];
		    	
		    	/*
		    	 * { optionValue: 'A.SettingKey', optionText:'설정키'}
		    	 * */
		    	var optionArray = new Array();
		    	for(var j = 0; j < codeArray.length; j++) {
		    		var optionObj = new Object();
		    		var codeObj = codeArray[j];
		    		optionObj.optionValue = codeObj.Code;
		    		optionObj.Reserved1 = codeObj.Reserved1;
		    		optionObj.Reserved2 = codeObj.Reserved2;
		    		optionObj.Custom = codeObj.Reserved1 + "/" + codeObj.Reserved2;
			    	if(locale == null || locale == '' || locale == 'ko'){
			    		optionObj.optionText = codeObj.CodeName;	
			    	} else {
			    		//MultiCodeName으로 다국어 처리 할 것
			    		optionObj.optionText = CFN_GetDicInfo(codeObj.MultiCodeName);
			    	}
			    	optionArray.push(optionObj);
		    	}
		    }
		}

		return optionArray;
    }
    
	function fnAutoInputProperty(pObj, pThisID) {
	    if (_isSyncAD == "Y" &&_mode == "add") {
	    	$(".mapping_" + pThisID).val($(pObj).val());
	    }
    }
    
	function fnCPMailUse() {
		var IsCPMail = $("#selIsCPMail").val(); 
		if(IsCPMail == "N") {
			$("[name=trMailAddress]").css('display','none')
			//$("#txtMailID").attr("readonly","readonly");
			//$("#selMailDomain").attr("disabled","disabled");
		}
		else
		{	
			$("[name=trMailAddress]").css('display','')
			//$("#txtMailID").removeAttr("readonly");
			//$("#selMailDomain").removeAttr("disabled");
		}
		coviInput.setDate();
    }
	function fnLicSeq() {
		var mail =$("#selLicSeq option:selected").attr('mail');
		if(mail == "Y")
			$("#selIsCPMail").removeAttr('disabled')
		else
		{
			$("#selIsCPMail").val('N')
			$("#selIsCPMail").change();
			$("#selIsCPMail").attr('disabled','disabled')
		}
    }
    

	function checkIPAddress(strIP) {
        var expUrl = /^(1|2)?\d?\d([.](1|2)?\d?\d){3}$/;
        return expUrl.test(strIP);
    }

	function chkUserIPAddress_Changed(chkObj){
    	if($(chkObj).prop("checked")){
    		$("#txtStartIP").removeAttr("readonly");
    		$("#txtEndIP").removeAttr("readonly");
    	}else{
    		$("#txtStartIP").val("").attr("readonly", "readonly");
    		$("#txtEndIP").val("").attr("readonly", "readonly");
    	}
    }
    $(window).load(function () {
    	if(_isSyncAD == "Y"){
    		selIsAD_Changed();
        	selIsMail_Changed();
        	selIsMSG_Changed();
    	}
		if(_IsUseApprovalSet=='Y')
		{
			selIsDeputy_Changed();
			optDeputyOption_Changed();
		}
    });
    
</script>