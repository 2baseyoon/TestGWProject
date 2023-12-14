<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<style type="text/css">
#renderAclDiv .authPermissions table tr td:nth-child(9) { 
	border-right: 1px dashed #ddd;
}
</style>
<form name="form1">
	<div class="sadmin_pop">
		<ul class="tabMenu clearFloat">
			<li id="divBasicInfoTab" class="active" value="Basic"><a href="javascript:;"><spring:message code="Cache.lbl_SettingDefault" /></a> <!-- 기본설정 --></li>
			<covi:admin><li id="divAdditionalInfoTab" value="AdditionInfo"><a href="javascript:;"><spring:message code='Cache.lbl_SettingAdditional' /></a></li></covi:admin>
			<c:if test="${mode ne 'create'}">
				<li id="divPermissionInfoTab" class=""  value="AuthSetting"> <a href="javascript:;"><spring:message code="Cache.lbl_SettingPermission" /></a> <!-- 권한설정 --></li>
			</c:if>
		</ul>
		<!--기본설정 탭 시작 -->
		<div class="tabContent active"  id="searchTab_Basic">
			<table class="sadmin_table" style="margin-bottom: 10px;">
				<colgroup>
					<col style="width: 130px;" />
					<col />
					<col style="width: 100px;" />
					<col />
				</colgroup>
				<tbody>
					<tr>
						<th>
							<font color="red">*</font>
							<spring:message	code="Cache.lbl_SchDivision" /> <!-- 구분 -->
						</th>
						<td colspan="3">	
							<span id="rootSpan">
								<input type="radio" id="rootRadio" name="folderType" value="Root" />
								<label for="rootRadio">
									<spring:message	code='Cache.lbl_Category_insertRoot' />&nbsp;&nbsp;
								</label>								
							</span>						
							<span id="folderSpan">								
								<input type="radio" id="folderRadio" name="folderType" value="Folder" />
								<label for="folderRadio">
									<spring:message	code='Cache.lbl_Category_Folder' />&nbsp;&nbsp;
								</label>
								<input type="radio" id="resourceRadio" name="folderType" value="Resource" checked="checked" />
								<label for="resourceRadio">
									<spring:message code='Cache.lbl_Category_Resource' />&nbsp;&nbsp;
								</label>
								<input type="radio" id="resourceLinkRadio" name="folderType" value="ResourceLink" />
								<label for="resourceLinkRadio">
									<spring:message	code='Cache.lbl_Category_Link' />&nbsp;&nbsp;
								</label>
							</span>
							<span id="spanResourceShare">
								<input type="checkbox" id="isSharedChk" />
								<label for="isSharedChk">
									<spring:message code='Cache.lbl_SetSharedResource' />&nbsp;&nbsp;
								</label>
							</span>
						</td>
					</tr>
					<tr id="spanResourceLink" style="display: none;">
						<th><font color="red">*&nbsp;</font><spring:message code="Cache.lbl_ResourceManage_01" /></th>
						<td colspan="3">
							<input type="text" id="resourceLinkName" readonly="readonly" style="width: 80%;"/>
							<input type="hidden" id="hidResourceLinkID" />
							<input type="button" id="resourceLinkFindBtn" style="float: right;" class="AXButton" value="<spring:message code='Cache.btn_Find'/>" />
						</td>
					</tr>
					<tr>
						<th>
							<font color="red">*</font>
							<span id="tdNameLabel"><spring:message code="Cache.lbl_Res_Name" /></span> <!-- 자원명 -->
						</th>
						<td colspan="3">
							<input type="text" id="resourceName" kind="dictionary" dic_src="hidResourceName" class="HtmlCheckXSS ScriptCheckXSS" style="width: 80%;" />
							<a href="#" kind="dictionaryBtn" src_elem="resourceName" class="btnTypeDefault" style="float: right;"><spring:message code='Cache.lbl_MultiLang2'/></a>
						</td>
					</tr>
					<tr id="trIsUseSelectBox">
						<th><spring:message code="Cache.lbl_selUse" /></th> <!-- 사용유무  -->
						<td>
							<select id="isUseSelectBox" name="isUseSelectBox""></select>
						</td>
						<covi:admin>
						<th><spring:message code="Cache.lbl_apv_kind" /></th> <!-- 종류 -->
						<td>
							<select id="resourceTypeSelect" type="selectbox" ></select>
						</td>
						</covi:admin>
					</tr>
					<covi:admin>
					<tr>
						<th>
							<spring:message code="Cache.lbl_SecurityLevel" />
						</th>
						<!-- 보안등급 -->
						<td>
							<select id="securityLevelSelect" class="AXSelect" style="width: 90%;"></select>
						</td>
						<th>
							<spring:message code="Cache.lbl_PriorityOrder" />
							<!-- <font color="red">*</font> -->
						</th>
						<!-- 우선순위 -->
						<td>
							<input type="text" id="sortKey" style="width: 57%;" disabled="disabled" />
						</td>
					</tr>
					</covi:admin>
					<tr id="trParentFolderName">
						<th>
							<font color="red">*</font>
							<spring:message code="Cache.lbl_Res_Div" />
						</th>
						<td colspan="3">
							<input type="text" id="parentFolderName" readonly="readonly" style="width:80%;" value="${folderName}"/>
							<input type="hidden" id="hidParentFolderID" value="${parentFolderID}"/>
							<span id="spanParentButton" style="float: right;">
								<input id="findParentFolderBtn" type="button" class="AXButton" value="<spring:message code='Cache.btn_Find'/>" onclick="findParentFolder()">
							</span>
						</td>
					</tr>
					<covi:admin>
					<tr>
						<th>
							<spring:message code="Cache.lbl_PlaceOfBusiness" />
						</th>
						<!-- 사업장 -->
						<td colspan="3">
							<input type="text" id="placeOfBusinessName" readonly="readonly" style="width: 80%;">
							<input type="hidden" id="hidPlaceOfBusinessCode" value=""/>
							<input type="button" class="AXButton" style="float: right;" value="<spring:message code='Cache.btn_Find'/>" id="findPlaceOfBusinessBtn">
						</td>
					</tr>
					</covi:admin>
					<tr>
						<th><spring:message code='Cache.lbl_Description' /></th> <!-- 설명 -->
						<td colspan="3">
							<textarea id="description" rows="4" class="w100 HtmlCheckXSS ScriptCheckXSS"></textarea>
						</td>
					</tr>
					<tr>
						<th><spring:message code="Cache.lbl_resourceImage" /></th> <!-- 자원 이미지 -->
						<td colspan="3">
							<img id="resourceImage" style="width: 100px; height:80px" onerror="coviCmn.imgError(this);"/>
							<input type="hidden" id="hidResourceImagePath" value="" />
							<input type="button" id="uploadImgBtn" class="AXButton" value="<spring:message code='Cache.btn_Upload'/>" /> <!-- 업로드 -->
						</td>
					</tr>
				</tbody>
			</table>
			
			<!--상위 분류 설정을 상속-->
			<table id="divIsInheritance" class="sadmin_table">
				<colgroup>
					<col style="width: 130px;" />
					<col />
				</colgroup>
				<tbody>
					<tr>
						<th colspan="2">
							<input id="isInheritance" type='checkbox'  />
							<h4 style="margin-top: 25px; display: inline;" id="inheritanceLabel">
								<label for="isInheritance">
									<spring:message code='Cache.lbl_SetParentCategory' />
								</label>
							</h4>
						</th>
					</tr>
				</tbody>		
			</table>
			
			<table id="folderOptionTable" class="sadmin_table" style="border-top: 0px;">
				<colgroup>
					<col style="width: 130px;" />
					<col />
				</colgroup>
				<tbody>
					<tr>
						<th><spring:message code="Cache.lbl_NoticeMedia" /></th>	<!-- 알림매체 -->
						<td id="noticeMedia"></td>
					</tr>
					<tr>
						<th>
							<spring:message code="Cache.lbl_ReservationProc" />
							<font color="red">*</font>
						</th>
						<!--예약절차 -->
						<td>
							<input type="radio" id="chargeBookingRdo"name="bookingType" value="ChargeApproval" />
							<label for="chargeBookingRdo">
								<spring:message code='Cache.BookingType_ChargeApproval' />&nbsp;&nbsp;
							</label>
							<!--담당승인-->
							<input type="radio" id="directBookingRdo" name="bookingType" value="DirectApproval"  checked="checked"/>
							<label for="directBookingRdo">
								<spring:message code='Cache.BookingType_DirectApproval' />&nbsp;&nbsp;
							</label>
							<!--바로승인-->
							<input type="radio" id="noneBookingRdo" name="bookingType" value="ApprovalProhibit"  />
							<label for="noneBookingRdo">
								<spring:message code='Cache.BookingType_ApprovalProhibit' />&nbsp;&nbsp;
							</label>
							<!--예약불가-->
						</td>
					</tr>
					<tr>
						<th>
							<spring:message code="Cache.lbl_ReturnProc" />
							<font color="red">*</font>
						</th>
						<!--반납절차 -->
						<td >
							<input type="radio" id="chargeReturnRdo" name="returnType" value="ChargeConfirm" />
							<label for="chargeReturnRdo">
								<spring:message code='Cache.ReturnType_ChargeConfirm' />&nbsp;&nbsp;
							</label>
							<!--담당승인-->
							<input type="radio" id="directReturnRdo" name="returnType" value="AutoReturn" checked="checked" />
							<label for="directReturnRdo">
								<spring:message code='Cache.ReturnType_AutoReturn' />&nbsp;&nbsp;
							</label>
							<!--바로승인-->
						</td>
					</tr>
					<tr id="trLeastTimeRentalSelect">
						<th>
							<spring:message code="Cache.lbl_MinimumRental" />
						</th>
						<!-- 최소대여시간 -->
						<td >
							<select id="leastTimeRentalSelect"></select>
						</td>
					</tr>
					<tr>
						<th>
							<spring:message code="Cache.lbl_DescriptionURL" />
						</th>
						<!-- 부가설명 URL -->
						<td>
							<input id="descriptionURL" type="text" class="HtmlCheckXSS ScriptCheckXSS" style="width: 97%;" />
						</td>
					</tr>
				</tbody>
			</table>
		</div>
		<!--기본설정 탭 종료 -->
		<!--추가설정 탭 시작-->
		<covi:admin>
		<div class="tabContent" id="searchTab_AdditionInfo" style="display: none;">
			<table id="divAdditionInfo" class="sadmin_table">
				<colgroup>
					<col width="90px" />
					<col />
				</colgroup>
				<tr>
					<th>
						<spring:message code='Cache.lbl_Equipment' />
					</th>
					<td>
						<div style="width: 97%; padding: 3px; border: 1px solid #ececec; background-color: #f9f9f9; border-radius: 5px;"align="right">
							<input id="addEquipmentBtn" type="button" value="<spring:message code="Cache.btn_Add"/>" class="AXButtonSmall" />
							<input id="delEquipmentBtn" type="button" value="<spring:message code="Cache.btn_delete"/>"	class="AXButtonSmall" />
						</div>
						<div id="divEquipmentList"	style="width: 98%; height: 110px; overflow: scroll; overflow-x: hidden;"></div>
					</td>
				</tr>
				<tr>
					<th>
						<spring:message code='Cache.lbl_AddProperty' /> 	<!-- 추가속성 -->
					</th>
					<td>
						<div style="width: 97%; padding: 3px; border: 1px solid #ececec; background-color: #f9f9f9; border-radius: 5px;"align="right">
							<input id="addAttributeBtn" type="button" value="<spring:message code="Cache.btn_Add"/>" class="AXButtonSmall" />
							<input id="delAttributeBtn" type="button"value="<spring:message code="Cache.btn_delete"/>"	class="AXButtonSmall" />
							<input id="upAttributeBtn" type="button" value="<spring:message code="Cache.btn_UP"/>"	class="AXButtonSmall" onclick="upAttribute()">
							<input id="downAttributeBtn" type="button" value="<spring:message code="Cache.btn_Down"/>" class="AXButtonSmall" onclick="downAttribute()">
						</div>
						<div id="divAttributeList" style="width: 98%; height: 110px; overflow: scroll; overflow-x: hidden;"></div>
					</td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_Res_Admin' /></th>
					<td>
						<div style="width: 97%; padding: 3px; border: 1px solid #ececec; background-color: #f9f9f9; border-radius: 5px;" align="right">
							<input id="addManagementBtn" type="button" value="<spring:message code="Cache.btn_Add"/>" class="AXButtonSmall" /> <!-- 추가 -->
							<input id="delManagementBtn" type="button" value="<spring:message code="Cache.btn_delete"/>" class="AXButtonSmall" /> <!-- 삭제 -->
						</div>
						<div id="divManagementList" style="width: 98%; height: 110px; overflow: scroll; overflow-x: hidden;"></div>
					</td>
				</tr>
			</table>
		</div>
		</covi:admin>
		<!--추가 정보 탭 종료 -->
		<!-- 권한 설정 탭 시작 -->
		<div class="tabContent" id="searchTab_AuthSetting" style="display: none;">
			<div id="renderAclDiv" style="clear:both;"></div>
		</div>
		<!-- 권한 설정 탭 종료 -->
		<div class="bottomBtnWrap">
			<a class="btnTypeDefault btnTypeBg" id="btnSave"><spring:message code='Cache.btn_apv_save' /></a><!-- 등록 -->
	     	<a id="btnClose"  class="btnTypeDefault" ><spring:message code='Cache.btn_apv_close'/></a>                    
		</div>
	</div>
	<input type="hidden" id="resourceImgInfo" value="[]" />
	<input type="hidden" id="hidResourceName" value="" />	
</form>

<script type="text/javascript">
	var lang = Common.getSession("lang");
	var coviACL = null;
	var g_isRoot = (CFN_GetQueryString("folderType") == 'Root' || CFN_GetQueryString("parentFolderID") == 'undefined' || CFN_GetQueryString("parentFolderID") == "0") ? true : false;
	var g_isInherited = false;	// 권한 상속 여부
	var g_hasChild = false;		// 자식 객체 존재 여부
	var removeManagement = new Array();
	//다국어 특수문자 처리 위한 정규표현식.
	var regExp = /\&nbsp\;|\&quot\;|\&apos\;|\;|\"|\'|\&/g;
	
	(function(params){
		var setEvent = function(){
			// 탭 전환
			$(".tabMenu li").off("click").on("click", function(){
				clickTab(this);
			});
			
			// 분류 선택
			$("input[name=folderType]").off("click").on("click", function(){
				clickFolderType();
			});
			
			// 자원 연결
			$("#resourceLinkFindBtn").off("click").on("click", function(){
				findSharedResource();
			});
			
			// 자원 이미지 업로드
			$("#uploadImgBtn").off("click").on("click", function(){
				uploadResourceImage();
			});
			
			//지원장비 추가
			$("#addEquipmentBtn").off("click").on("click", function(){
				addEquipment();
			});
			//지원장비삭제
			$("#delEquipmentBtn").off("click").on("click", function(){
				delAdditionOpt('Equipment')
			});
			
			//추가속성 추가
			$("#addAttributeBtn").off("click").on("click", function(){
				addAttribute();
			});
			
			//추가속성 삭제
			$("#delAttributeBtn").off("click").on("click", function(){
				delAdditionOpt("Attribute");
			});
			
			//추가속성 위로
			$("#upAttributeBtn").off("click").on("click", function(){
				upAttribute();
			});
			
			//추가속성 아래로
			$("#downAttributeBtn").off("click").on("click", function(){
				downAttribute();
			});

			// 담당자 추가
			$("#addManagementBtn").off("click").on("click", function(){
				addManager();
			});
			
			// 담당자 삭제
			$("#delManagementBtn").off("click").on("click", function(){
				delAdditionOpt('Management');
			});
			
			// 상위권한상속
			$("#chkAuthInherit").off("click").on("click", function(){
				checkIsInherit(this);
			});
			
			// 저장
			$("#btnSave").off("click").on("click", function(){
				saveFolder();
			});
			
			// 닫기
			$("#btnClose").off("click").on("click", function(){
				Common.Close();
			});
			
			//자원분류찾기
			$("#findParentFolderBtn").off("click").on("click", function(){
				findParentFolder();
			});
			
			//사업장
			$("#findPlaceOfBusinessBtn").off("click").on("click", function(){
				findPlaceOfBusiness();
			});
			
			//상속
			$("#isInheritance").off("click").on("click", function(){
				clickIsInheritance();
			});
		};
		
		var setControl = function(){
			//알림 종류 바인딩
			var sHTML = '';
			var mediaObj = Common.getBaseCode("NotificationMedia");
			
			$(mediaObj.CacheData).each(function(idx, obj){
				if (obj.Code == 'NotificationMedia') return true;
				
				sHTML += '<input type="checkbox" id="noticeMedia_'+obj.Code+'" name="noticeMedia" value="'+obj.Code+'" /><label for="noticeMedia_'+obj.Code+'" >&nbsp;' + CFN_GetDicInfo(obj.MultiCodeName, lang) + '&nbsp;&nbsp;</label>';
			});
			
			$("#noticeMedia").html(sHTML);
			
			// SelectBox 바인딩
			$("#isUseSelectBox").bindSelect({
				options : [
					  {"optionText": "<spring:message code='Cache.lbl_USE_Y'/>", "optionValue": "Y"}
					, {"optionText": "<spring:message code='Cache.lbl_USE_N'/>", "optionValue": "N"}
				]
			});
			
			coviCtrl.renderAXSelect(
				"SecurityLevel,ResourceType,LeastTimeRentalType",
				"securityLevelSelect,resourceTypeSelect,leastTimeRentalSelect",
				lang,
				"",
				"",
				"90,60,10"
			);
			
			renderingACL();
			
			$(":radio[value='" + params.folderType + "']").prop("checked", true);
		};
		
		var renderingACL = function(){
			var option = {
				lang: lang,
				hasButton: false,
				allowedACL : '_CDMEVR',
				initialACL : '_CDMEVR',
				orgMapCallback: 'orgCallback',
				aclCallback: 'aclCallback',
				systemType : "Resource",
				objectID : params.folderID,
				objectType : "FD"
			};
			
			if (!g_isRoot) {
				option["useInherited"] = true;
				option["inheritedFunc"] = "selectInheritedACL";
			}
			
			coviACL = new CoviACL(option);
			coviACL.render('renderAclDiv');
		};
		
		var clickFolderType = function(){
			var folderType = $(':radio[name="folderType"]:checked').val();
			
			switch (folderType.toUpperCase()) {
				case 'ROOT':
					$("#isInheritance").prop("checked", false);					
					$("#spanResourceShare").hide();
					$("#trParentFolderName").hide();
					$("#divIsInheritance").hide();
					break;
				case "FOLDER": // 분류					
					$("#spanResourceLink").hide();
					$("#spanResourceShare").hide();
					$("#trParentFolderName").show();
					$("#divIsInheritance").show();
					$("#tdNameLabel").html("<spring:message code='Cache.lbl_classNm'/>"); // 분류명
					$("#isInheritance").attr("disabled", false)
					$("#inheritanceLabel").text("<spring:message code='Cache.lbl_SetParentCategory'/>"); // 상위 분류 설정을 상속
					
					if ($("#isInheritedPermission").val() == "Y") {
						$("#hidPermission_Target").val($("#hidPermission_Parent").val());
					}
					break;
				case "RESOURCE": // 자원					
					$("#spanResourceLink").hide();
					
					if (typeof(parent.confMenu.domainId) != "undefined" && parent.confMenu.domainId === "0") { 	// domainID 0 일 경우에만 공유 자원 설정이 가능.
						$("#spanResourceShare").show();
					} else {
						$("#spanResourceShare").hide();
					}
					
					$("#trParentFolderName").show();
					$("#divIsInheritance").show();
					$("#tdNameLabel").html("<spring:message code='Cache.lbl_Res_Name'/>"); // 자원명
					$("#isInheritance").attr("disabled", false)
					$("#inheritanceLabel").text("<spring:message code='Cache.lbl_SetParentCategory'/>"); // 상위 분류 설정을 상속
					
					if ($("#isInheritance").prop("checked")) {
						$("#hidFDInfo_Target").val($("#hidFDInfo_Parent").val());
						$("#hidManagement_Target").val($("#hidManagement_Parent").val());
					}
					break;
				case "RESOURCELINK":					
					$("#spanResourceLink").show();
					$("#spanResourceShare").hide();
					$("#trParentFolderName").show();
					$("#divIsInheritance").show();
					$("#tdNameLabel").html("<spring:message code='Cache.lbl_Res_Name'/>"); // 자원명
					$("#isInheritance").attr("disabled", true)
					$("#isInheritance").prop("checked", true);
					$("#inheritanceLabel").text("<spring:message code='Cache.lbl_SetConnectionResource'/>"); // 연결 자원 설정을 상속
					
					if (!$("#hidResourceLinkID").val()) {
						if ($("#isInheritance").prop("checked")) {
							$("#hidFDInfo_Target").val($("#hidFDInfo_LinkFD").val());
							$("#hidManagement_Target").val($("#hidManagement_LinkFD").val());
						}
						if ($("#isInheritance").prop("checked")) {
							$("#hidPermission_Target").val($("#hidPermission_Parent").val());
						}
					}
					
					break;
			}
			
			relocationSelectbox();
		};
		
		var setData = function(){
			$.ajax({
				url: "/groupware/resource/manage/getFolderData.do",
				type: "POST",
				data: {
					"folderID": params.folderID
				},
				success: function(data) {
					if (data.status === 'SUCCESS') {
						setAddOption(data.folderData);
						setDataInfo(data.folderData.folderData);
					} else {
						Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); //오류가 발생했습니다.
					}
				},
				error: function(response, status, error) {
					CFN_ErrorAjax("/groupware/resource/manage/getFolderData.do",response, status, error);
				}
			});
		};
		
		var setDataInfo = function(dataObj){
			
			var folderType = dataObj.FolderType.split('.')[0];
			var resourceType = dataObj.FolderType.split('.')[1];
			
			switch (folderType.toUpperCase()) {
				case 'ROOT':
					$(":radio[value='Root']").prop("checked", true);		
					
					$("#spanResourceShare").hide();
					$("#isInheritance").prop("checked", false);
					$("#divIsInheritance").hide();
					$("#trParentFolderName").hide();
					break;
				case 'RESOURCE':
					$(":radio[value='Resource']").prop("checked", true)					
					
					if (typeof(parent.confMenu.domainId) != "undefined" && parent.confMenu.domainId === "0") {	<%-- domainID 0 인 경우에만 공유자원 설정 가능 --%>
						$("#spanResourceShare").show();
					} else {
						$("#spanResourceShare").hide();	
					}
					
					if(dataObj.LinkFolderID){
						$(":radio[value='ResourceLink']").prop("checked", true)
						$("#hidResourceLinkID").val(dataObj.LinkFolderID);
						$("#resourceLinkName").val(CFN_GetDicInfo(dataObj.LinkFolderName));
					}else{
						$(":radio[value='Resource']").prop("checked", true)
						$("#isSharedChk").prop("checked", dataObj.IsShared === "Y");
					}
					
					break;
				case 'RESOURCELINK':
					if(dataObj.LinkFolderID){
						$(":radio[value='ResourceLink']").prop("checked", true)
						$("#hidResourceLinkID").val(dataObj.LinkFolderID);
						$("#resourceLinkName").val(CFN_GetDicInfo(dataObj.LinkFolderName));
					}else{
						$(":radio[value='Resource']").prop("checked", true)
						$("#isSharedChk").prop("checked", dataObj.IsShared === "Y");
					}
					break;
				case 'FOLDER':
					$(":radio[value='Folder']").prop("checked", true);
					break;
			}
						
			clickFolderType();
			
			$("#hidParentFolderID").val(dataObj.MemberOf);
			$("#parentFolderName").val(CFN_GetDicInfo(dataObj.ParentFolderName));
			$("#isUseSelectBox").bindSelectSetValue(dataObj.IsUse)
			$("#resourceTypeSelect").bindSelectSetValue(resourceType);
			$("#hidPlaceOfBusinessCode").val(dataObj.Reserved1);
			$("#placeOfBusinessName").val(dataObj.PlaceOfBusiness);
			$("#securityLevelSelect").bindSelectSetValue(dataObj.SecurityLevel);
			$("#resourceName").val(CFN_GetDicInfo(dataObj.MultiDisplayName));
			$("#hidResourceName").val(dataObj.MultiDisplayName);
			$("#sortKey").val(dataObj.SortKey);
			$("#description").val(dataObj.Description);
			
			if(!dataObj.Reserved3){
				$("#resourceImage").attr("src", "");
			}else{
				$("#resourceImage").attr("src", "/covicore/common/view/Resource/"+dataObj.Reserved3+".do");
			}
			
			if(dataObj.Reserved2=="Y"){
				$("#isInheritance").prop("checked",true);
				$("#folderOptionTable *").prop("disabled",true);
				$("#divAdditionInfo *").prop("disabled",true);
				$("#leastTimeRentalSelect").bindSelectDisabled(true);
				
			}else{
				$("#isInheritance").prop("checked",false);
			}

			if(dataObj.NotificationKind != undefined){
				$.each(dataObj.NotificationKind.split(";"), function(idx, obj){
					if(obj == '') return true;
					$(":checkbox[id='noticeMedia_" + obj + "']").prop("checked", true);
				});
			}
			
			$(":radio[name='bookingType'][value='"+dataObj.BookingTypeCode+"']").prop("checked",true);
			$(":radio[name='returnType'][value='"+dataObj.ReturnTypeCode+"']").prop("checked",true);
			$("#leastTimeRentalSelect").bindSelectSetValue(dataObj.LeastRentalTime);
			$("#descriptionURL").val(dataObj.DescriptionURL);
			$("#hidDisplayIconCode").val(dataObj.IconCode);
			
			relocationSelectbox();
		}
		
		var setAddOption = function(option){
			// 권한 상속 여부
			g_isInherited = option.folderData.IsInherited == "Y" ? true : false;
			
			var managerData = new Array();
			
			if($(option.aclData).length > 0){
				coviACL.set(option.aclData);
			}
			
			$.each(option.attributeData,function(idx,obj){
				callbackAddAttribute(JSON.stringify(obj));
			})
			
			callbackAddEquipment(JSON.stringify(option.equipmentData));
			
			$.each(option.managementData, function(idx, obj){
				var orgObj = {};
				
				switch(obj.SubjectType){
					case 'UR':
						orgObj['itemType'] = 'user';
						break;
					case 'CM':
						orgObj['itemType'] = 'group';
						orgObj['GroupType'] = 'Company';
						break;
					case 'GR':
						orgObj['itemType'] = 'group';
						orgObj['GroupType'] = 'Dept';
						break;
				}
				
				orgObj['AN'] = obj.SubjectCode;
				orgObj['DN'] = obj.MultiSubjectName;
				orgObj['ETID'] = '';
				
				//기타
				orgObj['ETNM'] = '';
				orgObj['so'] = '';
				orgObj['UserID'] = '';
				orgObj['LV'] = '';
				orgObj['TL'] = '';
				orgObj['PO'] = '';
				orgObj['MT'] = '';
				orgObj['Mobile'] = '';
				orgObj['FAX'] = '';
				orgObj['EM'] = '';
				orgObj['OT'] = '';
				orgObj['USEC'] = '';
				orgObj['RG'] = '';
				orgObj['SG'] = '';
				orgObj['RGNM'] = '';
				orgObj['SGNM'] = '';
				orgObj['JobType'] = '';
				orgObj['UserCode'] = '';
				orgObj['ExGroupName'] = '';
				orgObj['PhoneNumberInter'] = '';
				orgObj['ChargeBusiness'] = '';
				orgObj['PhotoPath'] = '';
				orgObj['AbsenseUseYN'] = '';
				orgObj['po'] = '';
				orgObj['lv'] = '';
				orgObj['tl'] = '';
				
				managerData.push(orgObj);
			});
			
			callbackAddManager(JSON.stringify($$({}).append("item", managerData).json()));
		}
		
		var clickTab = function(pObj){
			$(".tabMenu li").removeClass("active");
			$(pObj).addClass("active");
			$(".tabContent").hide();
			var str = $(pObj).attr("value");
			$("#searchTab_"+str).show();	
			if (str =="Basic"){
				AXSelect.alignAllAnchor();
			}	
			$(window).resize();
		};
		
		var saveFolder = function(){
			var mode = !params.folderID ? "I" : "U";
			var maxFolderDepth = (Common.getBaseConfig('maxFolderDepth')) ? Number(Common.getBaseConfig('maxFolderDepth')) : 3;
			
			if (!chkValidation()) return;

			if (params.folderDepth > maxFolderDepth) {
				Common.Warning(Common.getDic("msg_resource_checkDepth").replace("{0}", (maxFolderDepth - 1)));
				return;
			}
			
			var folderData = {
				"folderID" : params.folderID,
				"menuID" : params.menuID,
				"domainID" : params.domainID,
				"folderType" : $(':radio[name="folderType"]:checked').val(),
				"resourceType" : $("#resourceTypeSelect").val(),
				"linkFolderID" : $("#hidResourceLinkID").val(),
				"displayName" : $("#resourceName").val(),
				"multiDisplayName" : $("#hidResourceName").val(),
				"memberOf" : $(':radio[name="folderType"]:checked').val() == "Root" ? "0" : $("#hidParentFolderID").val(),
				"sortKey" : $("#sortKey").val(),
				"isInherited" : ($("#renderAclDiv_isInherited").prop("checked") == true ? "Y": "N"),
				"isShared" : ($("#isSharedChk").prop("checked") == true ? "Y" : "N"),
				"isUse" : $("#isUseSelectBox").val(),
				"isDisplay" : "Y",
				"isURL" : "N",
				"url" : "",
				"description" : $("#description").val(),
				"placeOfBusiness" :$("#hidPlaceOfBusinessCode").val(),
				"isInheritedSetting" : ($("#isInheritance").prop("checked") == true ? "Y": "N"),
				"securityLevel" : $("#securityLevelSelect").val(),				
				"iconCode" : '',
				"iconPath" : '',
				"bookingType" : $(':radio[name="bookingType"]:checked').val(),
				"returnType" : $(':radio[name="returnType"]:checked').val(),
				"notificationState" : 'Approval;',
				"notificationKind" : getNotificationKind(),
				"leastRentalTime" : $("#leastTimeRentalSelect").val(),
				"leastPartRentalTime" : "10",
				"descriptionURL" : $("#descriptionURL").val(),
				"resorceImagePath" : $("#resourceImgInfo").val()
			}
			
			var aclInfo = coviACL_getACLData('renderAclDiv');
			var aclIsChange = aclInfo.aclIsChange;
			var aclData = aclInfo.aclData;
			var aclActionData = coviACL_getACLActionData('renderAclDiv');
			
			$.ajax({
				type: "POST",
				url: "/groupware/resource/manage/saveFolderData.do",
				data: {
					"mode": mode,
					"folderData": JSON.stringify(folderData),
					"aclIsChange" : aclIsChange,
					"aclData": aclData,
					"aclActionData": aclActionData,
					"managementData": getManagementData(),
					"equipmentData": getEquipmentData(),
					"attributeData": getAttributeData(),
				},
				success: function(res) {
					if(res.status === 'SUCCESS'){
						Common.Inform("<spring:message code='Cache.msg_37'/>", "Information", function(result){ // 저장되었습니다.
							if (result) {
								parent.refresh();
								Common.Close();
							}
						});
					}else{
						Common.Warning("<spring:message code='Cache.msg_sns_03'/>"); // 저장 중 오류가 발생하였습니다.
					}
				},
				error: function(response, status, error) {
					CFN_ErrorAjax("/covicore/resource/manage/saveFolderData.do", response, status, error);
				}
			});
		};
		
		var getNotificationKind=function(){
			var retVal = '';
			
			$.each($(":checkbox[name='noticeMedia']:checked"), function(idx, obj){
				retVal += obj.value + ";";
			});
			
			return retVal;
		};
		
		var getAttributeData=function(){
			var attributeData = new Array();
			
			$("#divAttributeList tbody tr").each(function(idx, obj){
				var att = {
					"attributeName": $(obj).attr("stitle"),
					"multiAttributeName": $(obj).attr("extitle"),
					"attributeValue": $(obj).attr("svalue"),
					"multiAttributeValue": $(obj).attr("exvalue")
				}
				
				attributeData.push(att);
			});
			
			return JSON.stringify(attributeData);
		};
		
		var chkValidation = function(){
			var folderType = $(':radio[name="folderType"]:checked').val();
			var message = "";
			
			if (!XFN_ValidationCheckOnlyXSS(false)) return;
			
			switch (folderType.toUpperCase()) {
				case "FOLDER": // 분류
					message ="<spring:message code='Cache.msg_ResourceManage_24'/>"; // 분류명을 입력하여 주십시오.
					break;
				case "RESOURCE": // 자원
					message = "<spring:message code='Cache.msg_ResourceManage_22'/>"; // 자원명을 입력하여 주십시오.
					break;
				case "RESOURCELINK": // 공유자원연결
					if (!$("#hidResourceLinkID").val()) {
						parent.Common.Warning("<spring:message code='Cache.msg_ResourceManage_23'/>", 'Warning Dialog', function(){ // 연결할 자원을 선택하여 주십시오.
							clickTab($("#divBasicInfoTab"));
							findSharedResource();
						});
						
						return false;
					}
					
					message = "<spring:message code='Cache.msg_ResourceManage_22'/>"; // 자원명을 입력하여 주십시오.
					break;
			}
			
			if (!$("#resourceName").val()) {
				parent.Common.Warning(message, 'Warning Dialog', function () {
					clickTab($("#divBasicInfoTab"));
					$("#resourceName").focus();
				});
				
				return false;
			}
			
			if(folderType != "Root") {
				if($("#parentFolderName").val() == ""){
					parent.Common.Warning( "<spring:message code='Cache.msg_checkResourceClassification'/>", "Warning Dialog", function () { 
			        });
					return false;
				}
			}
			
			// 자원명 특수기호 처리.
			if (!symbolCheck($("#resourceName").val())) {
				return false;
			}
			
			// 담당승인 및 담당확인이 체크 되어 있는 경우, 담당자 지정여부 확인
			if($(':radio[name="bookingType"]:checked').val() == 'ChargeApproval' || $(':radio[name="returnType"]:checked').val() == 'ChargeConfirm') {
				if($("#divManagementList").children().length == 0) {
					parent.Common.Warning("<spring:message code='Cache.lbl_apv_charge_select'/>", "Warning Dialog", function () { 
			        });
					return false;
				}
			}
			
			return true;
		};
		
		var getManagementData = function(){
			var managementData = new Array();
			
			$("#divManagementList tbody tr").each(function(idx, obj) {
				var att = {
					"subjectCode": $(obj).attr("objectcode"),
					"subjectType": $(obj).attr("objecttype_a")
				}
				
				managementData.push(att);
			});
			
			return JSON.stringify(managementData.concat(removeManagement));
		};
		
		var uploadResourceImage = function(){
			var url =  "";
				url += "/covicore/control/callFileUpload.do"
				url += "?lang=" + lang;
				url += "&listStyle=div";
				url += "&callback=callImgUploadCallBack";
				url += "&actionButton=" + encodeURIComponent("add,upload");
				url += "&multiple=false";
				url += "&servicePath=" + coviCmn.commonVariables.frontPath + Common.getSession("DN_Code") + "/";
				url += "&elemID=resourceImage";
			
			Common.open("", "CoviImgUp", "파일", url, "500px", "250px", "iframe", true, null, null, true);
		};
		
		var addManager = function(){
			var option = {
					callBackFunc : 'callbackAddManager',
			};
				
			coviCmn.openOrgChartPopup("<spring:message code='Cache.btn_OrgManage'/>", "", option);
			
			var url =  "/covicore/control/goOrgChart.do";
			url += "?callBackFunc=callbackAddManager";
			url += "&openerID=divResourceInfo";			
			// parent.Common.open("", "orgmap_pop", "<spring:message code='Cache.btn_OrgManage'/>", url, "1060px",	"580px", "iframe", true, null, null, true);
		};
		
		var delAdditionOpt = function(type){
			if ($("input[id^='chk" + type + "_']:checked").length > 0){
				Common.Confirm("<spring:message code='Cache.msg_Common_08'/>", 'Confirmation Dialog', function(result){ // 선택한 항목을 삭제하시겠습니까?
					if (result){
						$("input[id^='chk" + type + "_']:checked").each(function(){
							if(type == "Management"){
								var obj = $(this).parent().parent();
								var att = {
										"subjectCode": obj.attr("objectcode"),
										"subjectType": obj.attr("objecttype_a"),
										"isRemove": "Y"
								}
								removeManagement.push(att);
							}

							$(this).parent().parent().remove();
						});
					}
					
					if ($("#div" + type+ "List > TABLE > TBODY >TR").length == 0){
						$("#div" + type + "List").html("");
					}
				});
			} else {
				Common.Warning("<spring:message code='Cache.msg_Common_03'/>"); // 삭제할 항목을 선택하여 주십시오.
				return;
			}
		};
		
		var findSharedResource = function(){
			var title = "<spring:message code='Cache.lbl_ResourceManage_01'/>|||<spring:message code='Cache.msg_ResourceManage_01'/>";
			parent.Common.open("","findSharedResource", title, "/groupware/resource/manage/goShareResourceListSetPopup.do?callback=callbackfindSharedResource", "650px", "350px", "iframe", true, null, null, true);
		};
		
		var init = function(){
			// 사업장 사용 여부
			if((Common.getBaseConfig("IsUsePlaceOfBusinessSel") === "N")){
				$("#placeOfBusinessName").parent().parent().hide();
			}else{
				$("#placeOfBusinessName").parent().parent().show();
			}
			
			setEvent();
			setControl();
			
			if (g_isRoot){
				$(":radio[value='Root']").prop("checked", true);
				$("#folderSpan").remove();
				
				$("#isInheritance").prop("checked", false);					
				$("#spanResourceShare").hide();
				$("#trParentFolderName").hide();
				$("#divIsInheritance").hide();
			} else {
				$("#rootSpan").remove();
			}
			
			if (params.folderID) {
				setData();
			}
			
			// 공유 자원 설정은 도메인 0번일 때만, 그리고 Root인 경우는 설정 못함.
			if (params.domainID != "0") {
				$("#spanResourceShare").hide();
			}
			
			if (g_isRoot) {
				$("#spanResourceShare").hide();
			}
			
		};
		
		var clickIsInheritance = function(){
			if($("#isInheritance").prop("checked")){
				Common.Confirm("<spring:message code='Cache.msg_ResourceManage_12'/>", "Confirmation Dialog", function(result){
					if (result){
						$("#folderOptionTable *").prop("disabled", true);
						$("#divAdditionInfo *").prop("disabled", true);
						$("#leastTimeRentalSelect").bindSelectDisabled(true);
						setParentData($("#hidParentFolderID").val());
					}else{
						$("#isInheritance").prop("checked", false);
					}
				});
			}else{
				$("#folderOptionTable *").prop("disabled", false);
				$("#leastTimeRentalSelect").bindSelectDisabled(false);
				$("#divAdditionInfo *").prop("disabled", false);
			}
		};
		
		var setParentData = function(folderID){
			
			$("#divEquipmentList").empty();
			$("#divAttributeList").empty();
			$("#divManagementList").empty();
			
			getFolderData(folderID, function(data){
				setParentAddOption(data.folderData);
				setParentDataInfo(data.folderData.folderData);
			});
		};
		
		var getFolderData = function(folderID, callback, async){
			$.ajax({
				type: "POST",
				url: "/groupware/resource/manage/getFolderData.do",
				data: {
					"folderID": folderID
				},
				async: (typeof async !== 'undefined') ? async : true,
				success: function(data){
					if (data.status == 'SUCCESS'){
						if(typeof callback === "function"){
							callback.call(this, data);
						}
					} else {
						Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생했습니다.
					}
				},
				error: function(response, status, error){
					CFN_ErrorAjax("/groupware/resource/getFolderData.do", response, status, error);
				}
			});
		}
		
		var setParentAddOption = function(option){
			// 권한 상속 여부
			g_isInherited = option.folderData.IsInherited == "Y" ? true : false;
			
			// 이전 권한 삭제
			$(".aclSubject").each(function () {
				coviACL_deleteACLBySubject(coviACL.config.target, $(this).attr("objectcode"));
			}).remove();
			
			// 상위 권한 상속
			selectInheritedACL();
			$("#" + coviACL.config.target + "_isInherited").prop("checked", true);
			
			// 담당자
			var managerData = new Array();
			
			$.each(option.attributeData,function(idx,obj){
				callbackAddAttribute(JSON.stringify(obj));
			});
			
			callbackAddEquipment(JSON.stringify(option.equipmentData));
			
			$.each(option.managementData, function(idx, obj){
				var orgObj = {};
				
				switch(obj.SubjectType){
					case 'UR':
						orgObj['itemType'] = 'user';
						break;
					case 'CM':
						orgObj['itemType'] = 'group';
						orgObj['GroupType'] = 'Company';
						break;
					case 'GR':
						orgObj['itemType'] = 'group';
						orgObj['GroupType'] = 'Dept';
						break;
				}
				
				orgObj['AN'] = obj.SubjectCode;
				orgObj['DN'] = obj.MultiSubjectName;
				orgObj['ETID'] = '';
				
				//기타
				orgObj['ETNM'] = '';
				orgObj['so'] = '';
				orgObj['UserID'] = '';
				orgObj['LV'] = '';
				orgObj['TL'] = '';
				orgObj['PO'] = '';
				orgObj['MT'] = '';
				orgObj['Mobile'] = '';
				orgObj['FAX'] = '';
				orgObj['EM'] = '';
				orgObj['OT'] = '';
				orgObj['USEC'] = '';
				orgObj['RG'] = '';
				orgObj['SG'] = '';
				orgObj['RGNM'] = '';
				orgObj['SGNM'] = '';
				orgObj['JobType'] = '';
				orgObj['UserCode'] = '';
				orgObj['ExGroupName'] = '';
				orgObj['PhoneNumberInter'] = '';
				orgObj['ChargeBusiness'] = '';
				orgObj['PhotoPath'] = '';
				orgObj['AbsenseUseYN'] = '';
				orgObj['po'] = '';
				orgObj['lv'] = '';
				orgObj['tl'] = '';
				
				managerData.push(orgObj);
			});
			
			callbackAddManager(JSON.stringify($$({}).append("item", managerData).json()));
		}
		
		var setParentDataInfo = function(dataObj){
			$("#isInheritance").prop("checked", true);
			
			if(dataObj.NotificationKind != undefined){
				$(":checkbox[id='noticeMedia_MAIL']").prop("checked", false);
				$(":checkbox[id='noticeMedia_MESSENGER']").prop("checked", false);
				$(":checkbox[id='noticeMedia_TODOLIST']").prop("checked", false);
				$(":checkbox[id='noticeMedia_MDM']").prop("checked", false);
				
				$.each(dataObj.NotificationKind.split(";"), function(idx, obj){
					if(obj=='') return true;
					$(":checkbox[id='noticeMedia_"+obj+"']").prop("checked", true);
				});
			}
			$(":radio[name='bookingType'][value='"+dataObj.BookingTypeCode+"']").prop("checked", true);
			$(":radio[name='returnType'][value='"+dataObj.ReturnTypeCode+"']").prop("checked", true);
			$("#leastTimeRentalSelect").bindSelectSetValue(dataObj.LeastRentalTime);
			$("#minPartRentalSelect").bindSelectSetValue(dataObj.LeastPartRentalTime);
			$("#descriptionURL").val(dataObj.DescriptionURL);
			$("#hidDisplayIconCode").val(dataObj.IconCode);
		}
		
		var findParentFolder = function(value){
			var folderID = "";
			
			if ($("#hidParentFolderID").val()){
				folderID = $("#hidParentFolderID").val();
			}
			
			parent.Common.open("", "findParentFolder", "<spring:message code='Cache.lbl_ResourceManage_02'/>|||<spring:message code='Cache.msg_ResourceManage_02'/>", "/groupware/resource/manage/goFindParentFolder.do?domainID="+ params.domainID + "&folderID=" + folderID + "&callback=callbackFindParentFolder", "300px", "345px", "iframe", true, null, null, true);
		};
		
		var findPlaceOfBusiness=function(){
			var placeOfBusinessCodes = "";
			if ($("#hidPlaceOfBusinessCode").val() != undefined && $("#hidParentFolderID").val() != ""){
				placeOfBusinessCodes = $("#hidPlaceOfBusinessCode").val();
			}
			
			parent.Common.open("", "findPlaceOfBusiness", "<spring:message code='Cache.lbl_ResourceManage_03'/>|||<spring:message code='Cache.msg_ResourceManage_03'/>", "/groupware/resource/manage/goPlaceOfBusinessSetPopup.do?placeOfBusinessCode=" + placeOfBusinessCodes + "&callback=callbackFindPlaceOfBusiness&domainID=" + params.domainID, "650px", "350px", "iframe", true, null, null, true);
		};
		
		var addEquipment=function(){
			var equipmentIDs = "";
			
			$("#divEquipmentList tbody tr").each(function(idx, obj){
				equipmentIDs += ($(obj).attr("equipmentid") + "@");
			});
			
			parent.Common.open("", "addEquipment", "<spring:message code='Cache.lbl_ResourceManage_05'/>|||<spring:message code='Cache.msg_ResourceManage_05'/>", "/groupware/resource/manage/goResourceEquipmentSetPopup.do?equipmentID=" + equipmentIDs + "&callback=callbackAddEquipment&domainID=" + params.domainID, "650px", "350px", "iframe", true, null, null, true);
		};
		
		var getEquipmentData=function (){
			var equipmentIDs = "";
			
			$("#divEquipmentList tbody tr").each(function(idx, obj){
				equipmentIDs += ($(obj).attr("equipmentid") + ";");
			});
			
			return equipmentIDs;
		};

		var addAttribute=function(){
			parent.Common.open("", "addAttribute", "<spring:message code='Cache.lbl_ResourceManage_06'/>|||<spring:message code='Cache.msg_ResourceManage_06'/>", "/groupware/resource/manage/goResourceAttributeSetPopup.do?callback=callbackAddAttribute", "400px", "200px", "iframe", true, null, null, true);
		};
		
		var upAttribute=function(){
			var bSelected = false;
			$("input[id^='chkAttribute_']:checked").each(function(){
				bSelected = true;
			});
			
			if (!bSelected){
				Common.Warning("<spring:message code='Cache.msg_Common_09'/>"); // 이동할 항목을 선택하여 주십시오.
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
			for (var i = 0; i < nLength; i++){
				if (!aObjectTR.filter(":eq(" + i.toString() + ")").children("TD").children("INPUT").is(":checked")){
					continue;
				}
				
				// 현재 행: 위에서부터 선택 되어 있는 행 찾기
				oNowTR = aObjectTR.filter(":eq(" + i.toString() + ")");
				
				// 이전 행 찾기: 현재 행 기준 위에서 선택 안되어 있는 행 찾기
				oPrevTR = null;
				for (var j = i - 1; j >= 0; j--){
					if (aObjectTR.filter(":eq(" + j.toString() + ")").children("TD").children("INPUT").is(":checked")){
						continue;
					}
					oPrevTR = aObjectTR.filter(":eq(" + j.toString() + ")");
					break;
				}
				
				if (oPrevTR == null){
					continue;
				}
				
				oPrevTR.insertAfter(oNowTR);
			}
			
			if (sErrorMessage != ""){
				Common.Error(sErrorMessage);
			}
		};
		
		// 추가속성 아래로버튼 클릭시 호출되며, 선택된 추가속성의 우선순위를 한단계 내립니다.
		var downAttribute=function(){
			var bSelected = false;
			$("input[id^='chkAttribute_']:checked").each(function(){
				bSelected = true;
			});
			
			if (!bSelected){
				Common.Warning("<spring:message code='Cache.msg_Common_09'/>"); // 이동할 항목을 선택하여 주십시오.
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
			
			for (var i = nLength; i >= 0; i--){
				if (!aObjectTR.filter(":eq(" + i.toString() + ")").children("TD").children("INPUT").is(":checked")){
					continue;
				}
				
				// 현재 행: 아래에서부터 선택되어 있는 행 찾기
				oNowTR = aObjectTR.filter(":eq(" + i.toString() + ")");
				
				// 다음 행 찾기: 현재 행 기준 아래에서 선택 안되어 있는 행 찾기
				oNextTR = null;
				for (var j = i + 1; j < nLength; j++){
					if (aObjectTR.filter(":eq(" + j.toString() + ")").children("TD").children("INPUT").is(":checked")){
						continue;
					}
					oNextTR = aObjectTR.filter(":eq(" + j.toString() + ")");
					break;
				}
				
				if (oNextTR == null){
					continue;
				}
				
				oNowTR.insertAfter(oNextTR);
			}
			if (sErrorMessage != ""){
				Common.Error(sErrorMessage);
			}
		};
		
		// 다국어의 특수기호 체크
		var symbolCheck = function(param) {
			if ( regExp.test(param) ) { 	// 정규표현식으로 특수문자 검색.
				var sMessage = String.format("<spring:message code='Cache.msg_DictionaryInfo_01' />", "&apos; &quot; ;") ; // 특수문자 [' " ;]는 사용할 수 없습니다.
				Common.Warning(sMessage, 'Warning Dialog', function () {});
				return false;	
			} else {
				return true;
			}
		};
		
		// 특수기호 변경처리.
		var symbolChange = function(strParam) {
			strParam = strParam.replaceAll(regExp,"");
			return strParam
		};
		
		init();
	})({
		  menuID: "${menuID}"
		, folderID: "${folderID}"
		, domainID: "${domainID}"
		, folderType: "${folderType}"
		, folderDepth: "${folderDepth}"
	});
	
	// call back method
	var orgCallback = function(data){
		var orgJson = $.parseJSON(data);
		var bCheck = false;
		var sObjectType = "";
		var sObjectType_A = "";
		var sObjectTypeText = "";
		var sCode = "";
		var sDNCode = "";
		var sDisplayName = "";
		
		// 모든 하이라이트 해제
		$('.aclSubject').css("background-color", "inherit");
		$('.aclSubject').removeAttr("data-clicked");
		
		$.each(orgJson.item, function(i, item){
			sObjectType = item.itemType;
			
			if(sObjectType.toUpperCase() == "USER"){ //사용자
				sObjectTypeText = "사용자";
				sObjectType_A = "UR";
				sCode = item.AN;		//UR_Code
				sDNCode = item.ETID; 	//DN_Code
				sDisplayName = CFN_GetDicInfo(item.DN, lang);				
			}else{ //그룹
				switch(item.GroupType.toUpperCase()){
		  			case "AUTHORITY":
		                sObjectTypeText = "권한";
		                sObjectType_A = "GR";
		                break;
		  			case "COMMUNITY":
		                sObjectTypeText = "커뮤니티";
		                sObjectType_A = "GR";
		                break;
		  			case "COMPANY":
		                 sObjectTypeText = "회사";
		                 sObjectType_A = "CM";
		                 break;
		             case "JOBLEVEL":
		                 sObjectTypeText = "직급";
		                 sObjectType_A = "GR";
		                 break;
		             case "JOBPOSITION":
		                 sObjectTypeText = "직위";
		                 sObjectType_A = "GR";
		                 break;
		             case "JOBTITLE":
		                 sObjectTypeText = "직책";
		                 sObjectType_A = "GR";
		                 break;
		             case "MANAGE":
		                 sObjectTypeText = "관리";
		                 sObjectType_A = "GR";
		                 break;
		             case "OFFICER":
		                 sObjectTypeText = "임원";
		                 sObjectType_A = "GR";
		                 break;
		             case "DEPT":
		                 sObjectTypeText = "부서";
		                 sObjectType_A = "GR";
		                 break;
		             default:
		                 sObjectTypeText = "그룹";
		                 sObjectType_A = "GR";
		                 break;
		     	}
				
				sCode = item.AN;
				sDisplayName = CFN_GetDicInfo(item.GroupName);
				sDNCode = item.DN_Code;
			}
			
			bCheck = false;
			
			$('#renderAclDiv_hTbdPermissions').find('tr').each(function(){
				if (($(this).attr("objecttype_a").toUpperCase() == sObjectType_A.toUpperCase()) && ($(this).attr("objectcode") == sCode)) {
					bCheck = true;
				}
			});
			
			if(!bCheck){
				var jsonData = JSON.stringify({"item": item});
				coviACL.addSubjectRow(jsonData);
				
				// 신규 추가 권한들의 최상위 데이터로 하단 라디오버튼 설정
				if(i == 0) {   				
			   	 	coviACL_setACLRdo(item.hasOwnProperty("AclList") ? item.AclList : coviACL.config.initialACL, 0, 'S', coviACL.config.target);
			        coviACL_setACLRdo(item.hasOwnProperty("AclList") ? item.AclList : coviACL.config.initialACL, 1, 'C', coviACL.config.target);
			        coviACL_setACLRdo(item.hasOwnProperty("AclList") ? item.AclList : coviACL.config.initialACL, 2, 'D', coviACL.config.target);
			        coviACL_setACLRdo(item.hasOwnProperty("AclList") ? item.AclList : coviACL.config.initialACL, 3, 'M', coviACL.config.target);
			        coviACL_setACLRdo(item.hasOwnProperty("AclList") ? item.AclList : coviACL.config.initialACL, 4, 'E', coviACL.config.target);
			        coviACL_setACLRdo(item.hasOwnProperty("AclList") ? item.AclList : coviACL.config.initialACL, 5, 'V', coviACL.config.target);
			        coviACL_setACLRdo(item.hasOwnProperty("AclList") ? item.AclList : coviACL.config.initialACL, 6, 'R', coviACL.config.target);	
			        coviACL_setSubIncludeRdo(item.hasOwnProperty("IsSubInclude") ? item.IsSubInclude : coviACL.config.initSubInclude, sObjectType_A, "SubInclude", coviACL.config.target);
			    }
			}else{
				Common.Error("<spring:message code='Cache.ACC_msg_existItem'/>"); // 이미 추가된 항목입니다.
			}
		});
		
		setAuthSetting(orgJson.item);
	};
	
	var callImgUploadCallBack = function(data, num){
		var json = new Array();
		
		$.each(data, function(i, v){
			var src = coviCmn.commonVariables.frontPath + Common.getSession("DN_Code") + "/" + v.FrontAddPath + "/" ;
			var thumbSrc = src+v.SavedName.split('.')[0] + '_thumb.jpg';
			$("#resourceImage").attr('src', thumbSrc);
			json.push(v);
		});
		
		$("#resourceImgInfo").val(JSON.stringify(json));
		
		Common.close("CoviImgUp");
	};
	
	var callbackAddManager = function(orgData){
		var bCheck = false;
		
		// 담당자 선택 후 호출되는 함수로, 선택된 담당자를 화면에 표시합니다.
		if (orgData) {
			var sHTML = "";
			var sType = "";
			var sObjectTypeText = "";
			var sObjectType_A = "";
			var sCode = "";
			var sDisplayName = "";
			
			var sDNCode = "";
			
			$(JSON.parse(orgData).item).each(function(idx, obj) {
				sType = obj.itemType;
				if (!sType) {
					return true;
				}
				
				if (sType.toUpperCase() == "USER") {
					sObjectTypeText = "<spring:message code='Cache.lbl_User'/>"; //사용자
					sObjectType_A = "UR";
					sCode = obj.AN
					sDisplayName = CFN_GetDicInfo(obj.DN, lang);
					sDNCode = obj.ETID;
				} else {
					switch (obj.GroupType.toUpperCase()) {
					case "COMPANY":
						sObjectTypeText = "<spring:message code='Cache.lbl_company'/>"; // 회사
						sObjectType_A = "CM";
						break;
					case "JOBLEVEL":
					case "JOBPOSITION":
					case "JOBTITLE":
					case "MANAGE":
					case "OFFICER":
					case "DEPT":
						sObjectTypeText = "<spring:message code='Cache.lbl_group'/>"; //그룹
						sObjectType_A = "GR";
						break;
					}
					
					sCode = obj.AN;
					sDisplayName = CFN_GetDicInfo(obj.DN, lang);
					sDNCode = obj.ETID;
				}
				
				// 중복 체크
				bCheck = false;
				$('#divManagementList tr').each(function(){
					if (($(this).attr("objecttype_a").toUpperCase() == sObjectType_A.toUpperCase())
						&& ($(this).attr("objectcode") == sCode)) {
						bCheck = true;
					}
				});
				 
				if (bCheck) {
					 Common.Error("<spring:message code='Cache.msg_DuplicateSelectedUser'/>"); // 선택된 사용자 중에 이미 추가된 사용자가 있습니다.
					 return;
				}
				
				if ($("#isInheritance").prop("checked")) {
					sHTML += "<tr objectcode=\"" + sCode + "\" objecttype=\"" + sType + "\" objecttype_a=\"" + sObjectType_A + "\" dncode=\"" + sDNCode + "\" displayname=\"" + sDisplayName + "\" objecttypetext=\"" + sObjectTypeText + "\" >";
					sHTML += "<td style=\"border-bottom: 1px solid #d7d7d7 !important; height: 20px; padding-top: 5px;  padding-bottom: 5px;  padding-left: 10px;\">";
					sHTML += "<input id=\"chkManagement_" + sCode + "\" type=\"checkbox\" disabled=\"true\"  />";
					sHTML += "</td>";
					sHTML += "<td style=\"border-bottom: 1px solid #d7d7d7 !important; height: 20px; padding-top: 5px;  padding-bottom: 5px;  padding-left: 10px;\">";
					
					if (sType.toUpperCase() == "USER") {
						sHTML += "<img src=\"/HtmlSite/smarts4j_n/covicore/resources/images/covision/ico_ad02.gif\" style=\"width:16px; height:16px;\" />";
						sHTML += " " + sDisplayName;
					} else {
						sHTML += "<img src=\"/HtmlSite/smarts4j_n/covicore/resources/images/covision/ico_ad01.gif\"  style=\"width:16px; height:16px;\"/>";
						sHTML += " " + sDisplayName;
					}
					sHTML += "</td >";
					sHTML += "<td style=\"border-bottom: 1px solid #d7d7d7 !important; height: 20px; padding-top: 5px;  padding-bottom: 5px;  padding-left: 10px;\">";
					sHTML += sObjectTypeText;
					sHTML += "</td>";
					sHTML += "</tr>";
				} else {
					sHTML += "<tr objectcode=\"" + sCode + "\" objecttype=\"" + sType + "\" objecttype_a=\"" + sObjectType_A + "\" dncode=\"" + sDNCode + "\" displayname=\"" + sDisplayName + "\" objecttypetext=\"" + sObjectTypeText + "\" >";
					sHTML += "<td style=\"border-bottom: 1px solid #d7d7d7 !important; height: 20px; padding-top: 5px;  padding-bottom: 5px;  padding-left: 10px;\">";
					sHTML += "<input id=\"chkManagement_" + sCode + "\" type=\"checkbox\"  style=\"cursor: pointer;\" />";
					sHTML += "</td>";
					sHTML += "<td style=\"border-bottom: 1px solid #d7d7d7 !important; height: 20px; padding-top: 5px;  padding-bottom: 5px;  padding-left: 10px;\">";
					
					if (sType.toUpperCase() == "USER") {
						sHTML += "<label for=\"chkManagement_" + sCode + "\" style=\"cursor: pointer;\">";
						sHTML += "<img src=\"/HtmlSite/smarts4j_n/covicore/resources/images/covision/ico_ad02.gif\" style=\"width:16px; height:16px;\"/>";
						sHTML += " " + sDisplayName;
						sHTML += "</label>";
					} else {
						sHTML += "<label for=\"chkManagement_" + sCode + "\" style=\"cursor: pointer;\">";
						sHTML += "<img src=\"/HtmlSite/smarts4j_n/covicore/resources/images/covision/ico_ad01.gif\" style=\"width:16px; height:16px;\"/>";
						sHTML += " " + sDisplayName;
						sHTML += "</label>";
					}
					sHTML += "</td>";
					sHTML += "<td style=\"border-bottom: 1px solid #d7d7d7 !important; height: 20px; padding-top: 5px;  padding-bottom: 5px;  padding-left: 10px;\">";
					sHTML += "<label for=\"chkManagement_" + sCode + "\" style=\"cursor: pointer;\">";
					sHTML += sObjectTypeText;
					sHTML += "</label>";
					sHTML += "</td>";
					sHTML += "</tr>";
				}
			});
			
			if ($("#divManagementList tbody").length > 0) {
				$("#divManagementList tbody").append(sHTML);
			} else {
				var sTemp = "<table cellpadding=\"0\" cellspacing=\"0\" style=\"width:100%; font-size: 13px;\">";
				sTemp += "<colgroup>";
				sTemp += "<col width=\"33\" >";
				sTemp += "<col width=\"150\" />";
				sTemp += "<col />";
				sTemp += "</colgroup>";
				sTemp += "<tbody>";
				sTemp += sHTML;
				sTemp += "</tbody>";
				sHTML += "</table>";
				$("#divManagementList").html(sTemp);
			}
		}
	};
	
	var callbackfindSharedResource = function(value){
		if (value) {
			$("#hidResourceLinkID").val(value.split("|")[0]);
			$("#resourceLinkName").val(value.split("|")[1]);
		}
	};
	
	var callbackFindParentFolder =function(value){
		if (value != ""){
			$("#hidParentFolderID").val(value.split("|")[0]);
			$("#parentFolderName").val(CFN_GetDicInfo(value.split("|")[1]));
		}
	}
	
	callbackFindPlaceOfBusiness=function(value){
		if (value != ""){
			$("#hidPlaceOfBusinessCode").val(value.split("|")[0]);
			$("#placeOfBusinessName").val(value.split("|")[1]);
		}
	}

	callbackAddAttribute=function(pStrAttributeInfo){
		var sHTML = "";
		var oAttributeInfo = JSON.parse(pStrAttributeInfo);
		
		if ((pStrAttributeInfo != null) && (pStrAttributeInfo != "")){
			sHTML = "";
			var sTitle = oAttributeInfo.Title;
			var sExTitle = oAttributeInfo.ExTitle;
			var sValue = oAttributeInfo.Value;
			var sExValue = oAttributeInfo.ExValue;
			
			if ((sTitle == "") || (sExTitle == "") || (sValue == "") || (sExValue == "")){
				return true;
			}
			
			var sAttributeID = $("#divAttributeList").children().length + 1;
			
			if ($("#isInheritance").prop("checked")){
				sHTML += "<tr attributeid=\"" + sAttributeID + "\"stitle=\"" + sTitle + "\" extitle=\"" + sExTitle + "\" svalue=\"" + sValue + "\" exvalue=\"" + sExValue + "\">";
				sHTML += "<td style='padding: 8px; border-bottom: 1px solid #d7d7d7 !important;'>";
				sHTML += "<input id=\"chkAttribute_" + sAttributeID + "\" type=\"checkbox\" disabled=\"true;\" style=\"margin-right: 10px; vertical-align: middle;\"/>";
				sHTML += sTitle + ": " + sValue;
				sHTML += "</td>";
				sHTML += "</tr>";
			} else {
				sHTML += "<tr attributeid=\"" + sAttributeID + "\"stitle=\"" + sTitle + "\" extitle=\"" + sExTitle + "\" svalue=\"" + sValue + "\" exvalue=\"" + sExValue + "\">";
				sHTML += "<td style='padding: 8px; border-bottom: 1px solid #d7d7d7 !important;'>";
				sHTML += "<input id=\"chkAttribute_" + sAttributeID + "\" type=\"checkbox\" style=\"margin-right: 10px;cursor: pointer;vertical-align: middle;\"/>";
				sHTML += sTitle + ": " + sValue;
				sHTML += "</td>";
				sHTML += "</tr>";
			}
			
			if ($("#divAttributeList").children().length <= 0){
				sHTML = "<table class=\"approach_t3\" cellpadding=\"0\" cellspacing=\"0\" style=\"width: 100%; font-size: 13px;\">" + sHTML + "</table>";
				$("#divAttributeList").append(sHTML);
			} else {
				$("#divAttributeList").children("TABLE").children("TBODY").append(sHTML);
			}
		}
	}
	
	callbackAddEquipment=function(sEquipmentInfo){
		$("hidEquipmentInfo").val(sEquipmentInfo);
		var oEquipmentInfo = JSON.parse(sEquipmentInfo);
		var sHTML = "";
		
		if ((oEquipmentInfo != null) && (oEquipmentInfo != "")){
			var sEquipmentID = "";
			var sName = "";
			var sURL = "";
			var i = 0;
			
			$(oEquipmentInfo).each(function(idx, obj){
				sEquipmentID = obj.EquipmentID;
				sName = CFN_GetDicInfo(obj.MultiEquipmentName,lang);
				sURL = coviCmn.loadImage(Common.getBaseConfig("BackStorage").replace("{0}", obj.CompanyCode) + obj.IconPath);
				
				if ((sEquipmentID == "") || (sName == "")){
					return true;
				}
				
				if ($("#isInheritance").prop("checked")){
					sHTML += "<tr equipmentID=\"" + sEquipmentID + "\" name=\"" + sName + "\" url=\"" + sURL + "\">";
					sHTML += "<td style='padding: 8px; border-bottom: 1px solid #d7d7d7 important;''>";
					sHTML += "<input id=\"chkEquipment_" + i + "\" type=\"checkbox\" disabled=\"true\" style=\"margin-right: 10px;cursor: pointer;vertical-align: middle;\" class=\"input_check\" />";
					sHTML += "<label for=\"chkEquipment_" + i + "\">";
					sHTML += "<img src=\"" + sURL + "\" alt=\"" + sName + "\" title=\"" + sName + "\" width=\"16px\" height=\"16px\" onerror=\"coviCmn.imgError(this, false);\" this.onerror=null;\" />";
					sHTML += "&nbsp;" + sName + "</label>";
					sHTML += "</td>";
					sHTML += "</tr>";
				} else {
					sHTML += "<tr equipmentID=\"" + sEquipmentID + "\" name=\"" + sName + "\" url=\"" + sURL + "\">";
					sHTML += "<td style='padding: 8px; border-bottom: 1px solid #d7d7d7 !important;'>";
					sHTML += "<input id=\"chkEquipment_" + i + "\" type=\"checkbox\" style=\"margin-right: 10px;cursor: pointer;vertical-align: middle;\" />";
					sHTML += "<label for=\"chkEquipment_" + i + "\" style=\"cursor: pointer;\">";
					sHTML += "<img src=\"" + sURL + "\" alt=\"" + sName + "\" title=\"" + sName + "\" width=\"16px\" height=\"16px\" onerror=\"coviCmn.imgError(this, false);\" this.onerror=null;\"/>";
					sHTML += "&nbsp;" + sName + "</label>";
					sHTML += "</td>";
					sHTML += "</tr>";
				}
				
				i++;
			});
			
			if (sHTML != ""){
				sHTML = '<table cellpadding="0" cellspacing="0" style="width: 100%; font-size: 13px;">' + sHTML + "</table>";
			}
		}
		$("#divEquipmentList").html(sHTML);
	}
	
	//상위 권한 상속
	var selectInheritedACL = function(){
		$.ajax({
			url: "/groupware/board/manage/selectBoardACLData.do",
			type: "POST",
			async: false,
			data: {
				  "objectID": $("#hidParentFolderID").val()
				, "objectType": "FD"
			},
			success: function(res){
				if (res.status === "SUCCESS") {
					if(res.data.length > 0){
						var aclList = [];
						var exAclList = JSON.parse(coviACL_getACLData("renderAclDiv").aclData);
						
						$(res.data).each(function(idx, item){
							var exist = exAclList.map(function(exAcl){
								return exAcl.SubjectCode === item.SubjectCode;
							});
							
							if (exist.includes(true)) {
								// renderAclDiv
								$(".aclSubject").each(function(i, tr) {							
									if($(tr).attr("objectcode") == item.SubjectCode) {
										coviACL_setDelInfo($(tr));
										$(tr).remove();
									}
								});
								
								coviACL_deleteACLBySubject("renderAclDiv", item.SubjectCode);
							} 
							
							var acl = {
								  "AN": item.SubjectCode
								, "DN_Code": item.CompanyCode
								, "AclList": item.AclList
								, "Security": item.Security
								, "Create": item.Create
								, "Delete": item.Delete
								, "Modify": item.Modify
								, "Execute": item.Execute
								, "View": item.View
								, "Read": item.Read
								, "IsSubInclude" : item.IsSubInclude
							};
							
							if (item.SubjectType === "UR") {
								acl["itemType"] = "User";
								acl["DN"] = item.MultiSubjectName;
							} else {
								acl["itemType"] = "Group";
								acl["GroupName"] = item.MultiSubjectName;
								acl["GroupType"] = item.GroupType;
							}
							
							aclList.push(acl);				
						});
						
						var jsonData = {"item": aclList, "isInHerited": true, "inheritedObjectID": $("#hidParentFolderID").val()};
						
						// 모든 하이라이트 해제
						$('.aclSubject').css("background-color", "inherit");
						$('.aclSubject').removeAttr("data-clicked");
						
						coviACL.addSubjectRow(JSON.stringify(jsonData));
						setAuthSetting(jsonData.item);
					}
				}
			},
			error: function(error){
				CFN_ErrorAjax("/groupware/board/manage/selectBoardACLData.do", response, status, error);
			}
		});
	}
	
	function relocationSelectbox() {
		$("#AXselect_AX_isUseSelectBox").css("top", ($("#trIsUseSelectBox").offset().top + 6) + "px");
		$("#AXselect_AX_resourceTypeSelect").css("top", ($("#trIsUseSelectBox").offset().top + 6) + "px");
		$("#AXselect_AX_securityLevelSelect").css("top", ($("#trIsUseSelectBox").offset().top + 48) + "px");		
		$("#AXselect_AX_leastTimeRentalSelect").css("top", ($("#trLeastTimeRentalSelect").offset().top + 6) + "px");
	}
</script>