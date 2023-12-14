<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="/covicore/resources/script/menu/adminorganization.js<%=resourceVersion%>"></script>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>
	<style>
		/* div padding */
		.divpop_body {
			padding: 20px !important;
		}
		.txt_red {
    	color: #e75c00;
		}
	</style>
</head>
<body>
	<div class="AXTabs">
		<div id="divTabTray" class="AXTabsTray" style="height:30px">
			<a id="regionDefaultSetTab" onclick="clickTab(this);" class="AXTab on" value="divGroupDefault"><spring:message code='Cache.lbl_SettingDefault' /></a> <!-- 기본 설정 -->
			<a id="regionAddSetTab" onclick="clickTab(this);" class="AXTab" value="divGroupAdd"><spring:message code='Cache.lbl_SettingAdditional' /></a> <!-- 추가 설정 -->
		</div>
	</div>
	<form>
		<div style="width:100%;" id="divGroupDefault" class="mt15">
			<table class="AXFormTable">
				<colgroup>	
					<col style="width: 20%">
					<col style="width: 30%">
					<col style="width: 20%">
					<col style="width: 30%">
				</colgroup>
				<tr>
					<th id="thTitle"><spring:message code="Cache.lbl_CompanyName"/></th><!-- 회사명 -->
					<td colspan="3">
						<select id="selCompanyCode" name="selCompanyCode" class="AXSelect"></select>
					</td>
				</tr>
				<tr>
					<th id="thName"><spring:message code="Cache.lbl_RegionCode"/><span class="txt_red">*</span></th><!-- 지역코드 -->
					<td colspan="3">
					<label id="txtPfx"></label>
						<input type="text" class="AXInput HtmlCheckXSS ScriptCheckXSS" id="txtGroupCode">
						<input type="button" class="AXButton" value="<spring:message code="Cache.lbl_DuplicateCheck"/>" onclick="checkDuplicate();" id="btnIsDuplicate">
					</td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_RegionName"/><span class="txt_red">*</span></th><!-- 지역이름 -->
					<td colspan="3">
						<input type="text" class="AXInput HtmlCheckXSS ScriptCheckXSS" id="txtGroupName">
						<input type="button" class="AXButton" value="<spring:message code="Cache.lbl_MultiLangSet"/>" onclick="dictionaryLayerPopup('true', 'txtGroupName');">
					</td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_IsUse"/><span class="txt_red">*</span></th><!-- 사용여부 -->
					<td>
						<select id="selIsUse" name="selIsUse" class="AXSelect">
							<option value="Y" selected><spring:message code="Cache.lbl_UseY"/></option>
							<option value="N"><spring:message code="Cache.lbl_noUse"/></option>
						</select>
					</td>
					<th><spring:message code="Cache.lbl_IsHR"/><span class="txt_red">*</span></th><!-- 인사연동여부 -->
					<td>
						<select id="selIsHR" name="selIsHR" class="AXSelect">
							<option value="Y"><spring:message code="Cache.lbl_UseY"/></option>
							<option value="N" selected><spring:message code="Cache.lbl_noUse"/></option>
						</select>
					</td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_PriorityOrder"/><span class="txt_red">*</span></th><!-- 우선순위 -->
					<td>
						<input type="text" class="AXInput" id="txtPriorityOrder" style="width: 98%;" onkeyup='writeNum(this);'>
					</td>
					<th><spring:message code="Cache.lbl_IsMail"/><span class="txt_red">*</span></th><!-- 메일사용여부 -->
					<td>
						<select id="selIsMail" name="selIsMail" class="AXSelect">
							<option value="Y"><spring:message code="Cache.lbl_UseY"/></option>
							<option value="N" selected><spring:message code="Cache.lbl_noUse"/></option>
						</select>
						<input type="text" id="hidtxtUseMailConnect" style="display: none;">
					</td>
				</tr>
				<tr id="trIndiMail">
					<th><spring:message code="Cache.lbl_Mail"/></th><!-- 메일(인디) -->
					<td colspan='3'>
						<input type="text" class="AXInput HtmlCheckXSS ScriptCheckXSS" id="txtMailID" /> <label>@</label>
						<select id="selMailDomain" name="selMailDomain" class="AXSelect">
							<option value="" selected><spring:message code="Cache.lbl_Select" /></option>
						</select>
						<input type="text" id="hidtxtMailID" style="display: none;">
						<input type="button" class="AXButton" value="<spring:message code="Cache.lbl_DuplicateCheck"/>" onclick="checkDuplicateMail(mode, 'Group');" id="btnIsDuplicateMail">						
					</td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_Description"/></th><!-- 설명 -->
					<td colspan="3">
						<textarea id="txtDescription" class="AXTextarea HtmlCheckXSS ScriptCheckXSS" rows="8" style="width: 98%;"></textarea>
					</td>
				</tr>
			</table>
			
			<div style="width: 100%; text-align: center; margin-top: 10px;">
				<input type="button" id="btnSave" value="<spring:message code='Cache.btn_save' />" onclick="return saveRegion();" class="AXButton red" > <!-- 저장 -->
				<input type="button" id="btnClose" value="<spring:message code='Cache.btn_Close' />" onclick="closePopup();" class="AXButton" > <!-- 닫기 -->
			</div>
		</div>
		<div style="width:100%; display: none;" id="divGroupAdd" class="mt15">
			<table class="AXFormTable">
				<colgroup>	
					<col style="width: 20%">
					<col style="width: 80%">
				</colgroup>
				<tr>
					<th rowspan="3"><spring:message code='Cache.lbl_Mail_Address' /></th>
					<td>
						<div id="topitembar_2" class="topbar_grid" style="margin:auto 0;">
							<label>
								<input type="button" value="<spring:message code="Cache.btn_Add"/>" onclick="addMailAddress();" class="usa" /> <!-- 추가 -->
								<input type="button" value="<spring:message code="Cache.btn_delete"/>" onclick="deleteMailAddress();"class="usa"/> <!-- 삭제 -->
								<input type="button" value="▲ <spring:message code="Cache.btn_UP"/>" onclick="moveUpMailAddress();"class="usa"/> <!-- 위로 -->
								<input type="button" value="▼ <spring:message code="Cache.btn_Down"/>" onclick="moveDownMailAddress();"class="usa"/> <!-- 아래로 -->
							</label>
						</div>
					</td>
				</tr>
				<!-- <tr>
					<td>
						<input type="chl"
					</td>
				</tr> -->
			</table>
		</div>
	</form>
	<input type="hidden" id="GroupNameHidden" value="" />
	<script type="text/javascript">

		var gr_code = "${code}";
		var mode = "${mode}";
		var company = "${company}";

		//개별호출 일괄처리
		var lang = Common.getSession("lang");
		Common.getBaseConfigList(["IsSyncMail","IsSyncIndi"]);
		Common.getBaseCodeList(["MailDomain"]);
		
		var isSyncMail = coviCmn.configMap["IsSyncMail"];
		var isSyncIndi = coviCmn.configMap["IsSyncIndi"];
		
		window.onload = initContent();
			
		function initContent(){
			bindDropDownList();
			
			$("#selCompanyCode").val(company);
			$("#selCompanyCode").attr("disabled", "true");
			
			if (mode == "add"){
				setGroupPopDefaultInfo('', 'Region');
				
				if(Common.getGlobalProperties("isSaaS") != "Y") {
					$("#selIsMail").on("change", function() {
						fnMailUse(this);
					});
				}
				else{
					$("#txtPfx").text($("#selCompanyCode option:selected").attr("value") + "_");
				}
			} else if(mode == "modify"){
				getGroupInfoData(gr_code);
				$("#btnIsDuplicate").css("display", "none");
				$("#txtGroupCode").attr("readonly", "readonly") ;
				$("#selCompanyCode").attr("disabled", "true") ;
			}
			
			//기초설정에 따른 메일 표기 여부
			if(isSyncIndi == "Y"){
				$("#regionAddSetTab").css("display","none");
			}else if(isSyncMail == "Y"){
				$("#trIndiMail").css("display", "none");
			}else {
				$("#regionAddSetTab").css("display","none");
				var trMail = $('#selIsMail').closest('tr');
				trMail.children('td:first').attr('colspan', '3');
				trMail.children('th:nth-of-type(2)').css("display","none");
				trMail.children('td:nth-of-type(2)').css("display","none");
				check_dupMail = "Y";
			}
			
			//메일 도메인 바인딩
			var objMailDomain = coviCmn.codeMap["MailDomain"];
			$(objMailDomain).each(function(idx, obj) {
				if (obj.Code == 'MailDomain')
					return true;
				$('#selMailDomain').append($('<option>', { 
				        value: obj.CodeName,
				        text : obj.CodeName
				 }));
			});
		}
		
		//지역 회사 코드 바인딩
		function bindDropDownList(){
			$.ajax({
				type:"POST",
				async: false,
				url:"/covicore/admin/orgmanage/getavailablecompanylist.do",
				success:function (data) {
					$.each(data.list, function (i, d) {
						/* $('#selCompanyCode').append($('<option>', { 
					        value: d.CompanyCode,
					        text : d.CompanyName
						 })); */
						$('#selCompanyCode')
				         .append($("<option></option>")
				                    .attr("value",d.CompanyCode)
				                    .attr("id",d.CompanyID)
				                    .text(CFN_GetDicInfo(d.CompanyName), lang)); 

					});
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/covicore/admin/orgmanage/getavailablecompanylist.do", response, status, error);
				}
			});
		}
		

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
			
			//CFN_OpenWindow(url,"다국어 지정",500,300,"");
			Common.open("", "DictionaryPopup", "<spring:message code='Cache.lbl_MultiLangSet'/>", url, "400px", "200px", "iframe", true, null, null, true);
		}
		function initDicPopup(){
			var sFieldName = "txtGroupName"
			var sHiddenName = "GroupNameHidden";
			if(sFieldName==''){
				return "";
			}
			return $("#"+sHiddenName).val()==''? $("#"+sFieldName).val() : $("#"+sHiddenName).val();
		}
		function txtGroupName(data){
			$('#txtGroupName').val(data.KoFull);
			$('#GroupNameHidden').val(coviDic.convertDic(data))
		}

		// 다국어 값 바인드 및 처리
		parent._CallBackMethod = setDictionaryData;
		function setDictionaryData(nameValue){
			// nameValue : ko;en;ja;zh;reserved1;reserved2;;;;;
			var koData = nameValue.split(';')[0];
			$("#GroupNameHidden").val(nameValue);
		}
		
		// 해당 값이 바뀌었을 경우 이전 다국어 데이터를 지움
		function resetDicData(thisObj){
			$("#GroupNameHidden").val("");
		}
		
		function clickTab(pObj){
			$("#divTabTray .AXTab").attr("class","AXTab");
			$(pObj).addClass("AXTab on");
			
			var str = $(pObj).attr("value");
			
			$("#divGroupDefault").hide();
			$("#divGroupAdd").hide();
			
			$("#" + str).show();
		}
		
		//지역 정보 바인딩(수정시)
		function getGroupInfoData(gr_code) {
			$.ajax({
				type:"POST",
				data:{
					"gr_code" : gr_code
				},
				url:"/covicore/admin/orgmanage/getregioninfo.do",
				success:function (data) {
					$("#txtGroupCode").val(data.list[0].GroupCode);
					$("#txtGroupName").val(CFN_GetDicInfo(data.list[0].MultiGroupName, lang));
					$("#GroupNameHidden").val(data.list[0].MultiGroupName);
					$("#selCompanyCode option[id='" + data.list[0].CompanyID + "']").prop("selected", true);
					$("#selIsUse").val(data.list[0].IsUse == "" ? "N" : data.list[0].IsUse);
					$("#selIsHR").val(data.list[0].IsHR == "" ? "N" : data.list[0].IsHR);
					$("#selIsMail").val(data.list[0].IsMail == "" ? "N" : data.list[0].IsMail);
					$("#hidtxtUseMailConnect").val(data.list[0].IsMail == "" ? "N" : data.list[0].IsMail);
					
					var txtPrimaryMail = data.list[0].PrimaryMail;
					if(txtPrimaryMail != ""){
						$("#txtMailID").val(txtPrimaryMail.split("@")[0]);
						$("#selMailDomain").val(txtPrimaryMail.split("@")[1]);
						$("#hidtxtMailID").val(txtPrimaryMail);
						
						$("#txtMailID").attr("readonly", "readonly");
						$("#selMailDomain").attr("disabled","disabled");
					}
					
					$("#txtPriorityOrder").val(data.list[0].SortKey);
					$("#txtDescription").val(data.list[0].Description); 
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/covicore/admin/orgmanage/getregioninfo.do", response, status, error);
				}
			});
		}
		
		//중복 확인
		var check_dup = "N";
		function checkDuplicate() {
			if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
			
			var stringRegx = /[\{\}\[\]?.,;:|\)*~`!^\-+┼<>@\#$%&\\(\=\'\"]/;
			var stringRegx2 = /[ㄱ-ㅎ|ㅏ-ㅣ|가-힣]/;
			var blank_pattern = /[\s]/g;

			if("${mode}" == "add") {
				var gr_code = $('#txtGroupCode').val();
				if(gr_code == "") {
					Common.Warning("<spring:message code='Cache.msg_Region_01'/>");/* 지역코드를 입력하여 주십시오. */
				} else{
					if(stringRegx.test($("#txtGroupCode").val())) {
						Common.Warning("<spring:message code='Cache.msg_specialNotAllowed'/>", 'Warning Dialog', function() {
							$("#txtGroupCode").focus();
						});
						return false;
					} else if(stringRegx2.test($("#txtGroupCode").val())) {
						Common.Warning("<spring:message code='Cache.msg_KoreanNotAllowed'/>", 'Warning Dialog', function() {
							$("#txtGroupCode").focus();
						});
						return false;
					} else if(blank_pattern.test($("#txtGroupCode").val()) == true ){
						Common.Warning(Common.getDic("msg_apv_146"), 'Warning Dialog', function() {
							$("#txtGroupCode").focus();
						});
						return false;
					}
					
					$.ajax({
						type:"POST",
						data:{
							"GroupCode" : gr_code
						},
						url:"/covicore/admin/orgmanage/getisduplicategroupcode.do",
						success:function (data) {
							if(data.status != "FAIL") {
								if(data.list[0].isDuplicate > 0) {
									Common.Warning("<spring:message code='Cache.msg_EXIST_GRCODE'/>");/* 이미 존재하는 코드입니다. */
									$('#txtGroupCode').focus();
									check_dup = "N";
								} else {
									Common.Inform("<spring:message code='Cache.msg_Not_Duplicate'/>");/* 사용 가능한 코드입니다. */
									check_dup = "Y";
									
									if(Common.getGlobalProperties("isSaaS") == "Y" && $("#selIsMail option:selected").val() == "Y") {
										$("#txtMailID").val(gr_code);
									}
								}
							} else {
								Common.Warning(data.message);
								check_dup = "N";
							}
						},
						error:function(response, status, error){
							CFN_ErrorAjax("/covicore/admin/orgmanage/getisduplicategroupcode.do", response, status, error);
						}
					});
				}
			}
		}
		
		//중복 확인-메일
		var check_dupMail = "N";
		
		//유효성 검사
		function CheckValidation() {
			if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

			if($("#txtGroupCode").val() == "") {
				Common.Warning("<spring:message code='Cache.msg_Region_01'/>");/* 지역코드를 입력하여 주십시오. */
				return false;
			} else if("${mode}" == "add" && check_dup == "N" ) {
				Common.Warning("<spring:message code='Cache.msg_BaseCode_04' />"); //코드 중복을 확인하여 주십시오.
				return false;
			} else if($("#txtGroupName").val() == "") {
				Common.Warning("<spring:message code='Cache.msg_Region_02'/>");/* 지역명 입력하여 주십시오.*/
				return false;
			} else if($("#txtPriorityOrder").val() == "") {
				Common.Warning("<spring:message code='Cache.msg_EnterPriorityNumber' />"); //우선순위를 입력하세요.
				return false;
			} else if($("#GroupNameHidden").val() == "") {
				Common.Warning("<spring:message code='Cache.msg_MultilingualSettings' />"); //다국어를 설정해주세요.
				return false;
			}
			
			if(isSyncMail == 'Y') {
				//Exch 메일 사용
			} else if(isSyncIndi == "Y" && $("#selIsMail option:selected").val() == "Y") {
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
					if("${mode}" == "add" && check_dupMail == "N") {
						Common.Warning("<spring:message code='Cache.msg_Check_Duplicate_Mail'/>", 'Warning Dialog', function() { // 메일 중복을 확인하여 주십시오.
							$("#txtMailID").focus();
						});
						return false;
					}else if("${mode}" == "modify" && $("#hidtxtMailID").val() != $("#txtMailID").val() + "@" + $("#selMailDomain option:selected").val() && check_dupMail == "N") {
						Common.Warning("<spring:message code='Cache.msg_Check_Duplicate_Mail'/>", 'Warning Dialog', function() { // 메일 중복을 확인하여 주십시오.
							$("#txtMailID").focus();
						});
						return false;
					}else if("${mode}" == "modify" && $("#hidtxtUseMailConnect").val() != $("#selIsMail option:selected").val() && check_dupMail == "N") {
						Common.Warning("<spring:message code='Cache.msg_Check_Duplicate_Mail'/>", 'Warning Dialog', function() { // 메일 중복을 확인하여 주십시오.
							$("#txtMailID").focus();
						});
						return false;
					}
				}
			}
			return true;
		}
		
		//임의 그룹 추가
		function saveRegion(){
			
		    if(!CheckValidation()) return false;
		    
		    var txtGroupCode;
			if("${mode}" == "add"){
		    	txtGroupCode = $("#selCompanyCode option:selected").attr("value") + "_" + $("#txtGroupCode").val();				
			}else if("${mode}" == "modify"){
				txtGroupCode = $("#txtGroupCode").val();
			}
			
			var txtGroupName = $("#txtGroupName").val();
			var txtMultiGroupName = $("#GroupNameHidden").val();
			var txtCompanyCode = $("#selCompanyCode").val();
			var txtIsUse = $("#selIsUse").val();
			var txtIsHR = $("#selIsHR").val();
			var txtIsMail = $("#selIsMail").val();
			var txtPriorityOrder = $("#txtPriorityOrder").val();
			var txtDescription = $("#txtDescription").val();
			var mailAddress = "";
			if($('#txtMailID').val() != "" && $('#selMailDomain').val() != "") {
				mailAddress = $('#txtMailID').val() + '@' + $('#selMailDomain').val();
			}			
						
			$.ajax({
				url : "/covicore/admin/orgmanage/registregion.do",
				type : "POST",
				data : {
					"Type" : "Region",
					"TypeCode" : $("#selCompanyCode option:selected").attr('id') + "_Region",
					"Mode" : mode,
					"GroupCode" : txtGroupCode,
					"GroupName" : txtGroupName,
					"MultiGroupName" : txtMultiGroupName,
					"CompanyCode" : txtCompanyCode,
					"IsUse" :  txtIsUse,
					"IsHR" :  txtIsHR,
					"IsMail" :  txtIsMail,
					"PriorityOrder" :  txtPriorityOrder,
					"Description" : txtDescription,
					"MailAddress" : mailAddress
				},
				success : function(d) {
					try {
						if(d.result == "OK") {
							Common.Inform("<spring:message code='Cache.msg_Common_10'/>", 'Information Dialog', function (result) { 
								parent.orgGrid.reloadList();
								closePopup();
					        }); 
						} else {
							Common.Warning("<spring:message code='Cache.msg_ErrorOccurred'/>"); //오류가 발생하였습니다.
						}
					} catch(e) {
						
					}
				},
				error:function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("/covicore/admin/orgmanage/registregion.do", response, status, error);
				}
			});
		}
		
		function addMailAddress(pType, pCode, pMode){
			parent.Common.open("", "MailAddress_Attribute", "<spring:message code='Cache.lbl_Mail_Attributes'/>", "/covicore/mailaddress_attribute.do?type=" + encodeURIComponent(pType) + "&mail=" + encodeURIComponent(pCode) + "&mode=" + encodeURIComponent(pMode) + "&CallBackMethod=addMailAddress_after", "500px", "120px", "iframe", true, null, null, true);
			return;
		}
		
		function addMailAddress_after(){
			return;
		}
		
		function fnMailUse(pObj) {
	    	if($("#selIsMail option:selected").val() == "N") {
	    		if(isSyncIndi == "Y") {
		    		$("#txtMailID").attr("readonly", "readonly");
		    		$("#selMailDomain").attr("disabled","disabled");
	    		} else if (isSyncMail == "Y") {
	    			$("#regionAddSetTab").css("display","none");
	    		}
	    	}else {
	    		if(isSyncIndi == "Y") {
		    		$("#txtMailID").removeAttr("readonly");
		    		$("#selMailDomain").removeAttr("disabled");
	    		} else if(isSyncMail == "Y") {
	    			$("#regionAddSetTab").css("display","");
	    		}
	    	}
	    }

	</script>
</body>