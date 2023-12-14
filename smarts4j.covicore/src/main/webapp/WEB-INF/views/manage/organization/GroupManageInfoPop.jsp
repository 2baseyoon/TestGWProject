<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%> 
<script type="text/javascript" src="/covicore/resources/script/menu/manageorganization.js<%=resourceVersion%>"></script>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
  
	<style>
		/* div padding */
		.divpop_body {
			padding: 20px !important;
		}
		
		label {
			font-size: 13px;
		}
		
		.txt_red {
    		color: #e75c00;
		}
	</style>
	
</head>
<body>
	<div class="sadmin_pop">
		<ul class="tabMenu clearFloat" id="divTabTray" >
			<li class="active"><a href="#" id="GroupDefaultSetTab" onclick="pageObj.clickTab(this);" value="divGroupDefault"><spring:message code='Cache.lbl_SettingDefault' /></a> <!-- 기본 설정 --></a></li>
			<li class=""><a href="#" id="GroupAddSetTab" onclick="pageObj.clickTab(this);"  value="divGroupAdd"><spring:message code='Cache.lbl_SettingAdditional' /></a> <!-- 추가 설정 --></a></li>
		</ul>
		<form>
			<div class="tabContent active" id="divGroupDefault">
				<table class="sadmin_table sa_posiadd">
					<colgroup>
						<col width="130px;">
						<col width="*">
						<col width="130px;">
						<col width="*">
					</colgroup>
					<tr>
						<th><spring:message code="Cache.lbl_JobTitleCode"/></th>
						<td colspan="3">
							<label id="txtPfx"></label>
							<input type="text" class="HtmlCheckXSS ScriptCheckXSS" id="txtGroupCode">
							<label id="txtSfx"></label>
							<a class="btnTypeDefault" onclick="pageObj.checkDuplicate();" id="btnIsDuplicate"><spring:message code="Cache.lbl_DuplicateCheck"/></a>
						</td>
					</tr>
					<tr>
						<th><spring:message code="Cache.lbl_JobTitleName"/></th>
						<td colspan="3">
							<input type="text" class="HtmlCheckXSS ScriptCheckXSS" id="txtGroupName" onchange="pageObj.resetDicData(this);">
							<a class="btnTypeDefault" onclick="pageObj.dictionaryLayerPopup('true', 'txtGroupName');"><spring:message code="Cache.lbl_MultiLangSet"/></a>
						</td>
					</tr>
					<tr>
						<th><span class="txt_red">*</span><spring:message code="Cache.lbl_Organization_ShortName"/></th>
						<td colspan="3">
							<input type="text" class="HtmlCheckXSS ScriptCheckXSS" id="txtGroupShortName" onchange="pageObj.resetDicData(this);">
							<a class="btnTypeDefault" onclick="pageObj.dictionaryLayerPopup('true', 'txtGroupShortName');"><spring:message code="Cache.lbl_MultiLangSet"/></a>
						</td>
					</tr>
					<tr>
						<th><spring:message code="Cache.lbl_CompanyName"/></th>
						<td colspan="3">
							<input type="text" class="" id="txtCompanyName" readonly="readonly">
							<input type="text" id="hidCompanyCode" style="display: none;">
						</td>
					</tr>
					<tr>
						<th><spring:message code="Cache.lbl_ParentGroupName"/></th>
						<td colspan="3">
							<input type="text" class="" id="txtParentGroupName" readonly="readonly">
							<input type="text" id="hidParentGroupCode" style="display: none;">
						</td>
					</tr>
					<tr>
						<th><span class="thstar">*</span><spring:message code="Cache.lbl_IsUse"/></th>
						<td>
							<select id="selIsUse" name="selIsUse" class="selectType02">
								<option value="Y" selected><spring:message code="Cache.lbl_UseY"/></option>
								<option value="N"><spring:message code="Cache.lbl_noUse"/></option>
							</select>
						</td>
						<th><span class="thstar">*</span><spring:message code="Cache.lbl_IsHR"/></th>
						<td>
							<select id="selIsHR" name="selIsHR" class="selectType02">
								<option value="Y"><spring:message code="Cache.lbl_UseY"/></option>
								<option value="N" selected><spring:message code="Cache.lbl_noUse"/></option>
							</select>
						</td>
					</tr>
					<tr>
						<th><span class="thstar">*</span><spring:message code="Cache.lbl_PriorityOrder"/></th>
						<td>
							<input type="text" class="" id="txtPriorityOrder" style="width: 98%;" onkeyup='_writeNum(this);'>
						</td>
						<th><span class="thstar">*</span><spring:message code="Cache.lbl_IsMail"/></th>
						<td>
							<select id="selIsMail" name="selIsMail" class="selectType02" onchange="pageObj.fnMailUse()">
								<option value="Y"><spring:message code="Cache.lbl_UseY"/></option>
								<option value="N"><spring:message code="Cache.lbl_noUse"/></option>
							</select>
							<input type="text" id="hidtxtUseMailConnect" style="display: none;">
						</td>
					</tr>
					<tr id="trIndiMail">
						<th><span class="thstar">*</span><spring:message code="Cache.lbl_Mail"/></th><!-- 메일(인디) -->
						<td colspan='3'>
							<input type="text" class="HtmlCheckXSS ScriptCheckXSS" id="txtMailID" style="width: 35%;"/> <label>@</label>
							<select id="selMailDomain" name="selMailDomain" class="selectType02">
								<option value="" selected><spring:message code="Cache.lbl_Select" /></option>
							</select>
							<input type="text" id="hidtxtMailID" style="display: none;">
							<a class="btnTypeDefault" onclick="pageObj.checkDuplicateMail();" id="btnIsDuplicateMail"><spring:message code="Cache.lbl_DuplicateCheck"/></a>				
						</td>
					</tr>
					<tr>
						<th><spring:message code="Cache.lbl_Description"/></th>
						<td colspan="3">
							<textarea id="txtDescription" class="AXTextarea HtmlCheckXSS ScriptCheckXSS" rows="8" style="width: 98%;"></textarea>
						</td>
					</tr>
				</table>
			</div>
			<div style="width:100%;display: none;" id="divGroupAdd" class="mt15">
				<table class="AXFormTable">
					<colgroup>
						<col style="width: 20%;">
						<col style="width: 80%;">
					</colgroup>
					<tr>
						<th rowspan="3"><spring:message code='Cache.lbl_Mail_Address' /></th>
						<td>
							<div id="topitembar_2" class="">
								<label>
									<input type="button" value="<spring:message code="Cache.btn_Add"/>" onclick="pageObj.btnMailAdd_OnClick();" class="usa" /> <!-- 추가 -->
									<input type="button" value="<spring:message code="Cache.btn_delete"/>" onclick="pageObj.btnMailDel_OnClick();"class="usa"/> <!-- 삭제 -->
									<input type="button" value="▲ <spring:message code="Cache.btn_UP"/>" onclick="pageObj.btnMailUp_OnClick();"class="usa"/> <!-- 위로 -->
									<input type="button" value="▼ <spring:message code="Cache.btn_Down"/>" onclick="pageObj.btnMailDown_OnClick();"class="usa"/> <!-- 아래로 -->
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
				</table>
			</div>
			
			<div class="bottomBtnWrap">
				<a id="btnSave" onclick="return pageObj.CheckValidation()" class="btnTypeDefault btnTypeBg"><spring:message code='Cache.btn_save' /></a>
				<a id="btnClose"onclick="_closePopup();" class="btnTypeDefault"><spring:message code='Cache.btn_Close' /></a>
			</div>
		</form>
	</div>
<input type="text" id="GroupNameHidden" value="" style="display:none;"/>
<input type="text" id="GroupShortNameHidden" value="" style="display:none;"/>
<input type="hidden" id="hidPrimary"  />
<input type="hidden" id="hidSecondary"  />
<input type="hidden" id="hidGroupType"  />
</body>

<script type="text/javascript">

	// 개별호출 일괄처리
	window.onload = initContent();
	
	function initContent(){
		pageObj = Object.create(groupManage);
		pageObj.pageObjName	 = 'pageObj'
		pageObj.sessionObj	=	Common.getSession()
		pageObj.isSyncMail	=	Common.getBaseConfig('IsSyncMail')
		pageObj.isSyncIndi	=	Common.getBaseConfig('IsSyncIndi')
		pageObj.gr_code = "${GR_Code}";
		pageObj.memberOf = "${MemberOf}";
		pageObj.domainId = "${DomainId}";
		pageObj.mode = "${mode}";
		pageObj.grouptype = "${GroupType}";
		pageObj.check_dupMail = "N";
		pageObj.containPrimaryMail = false;
		pageObj.isArbitraryGroup = false;
		pageObj.initContent()
	}
	
	
</script>