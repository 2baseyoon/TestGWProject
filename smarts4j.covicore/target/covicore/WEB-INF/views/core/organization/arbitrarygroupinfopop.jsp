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
			<a id="groupDefaultSetTab" onclick="clickTab(this);" class="AXTab on" value="divGroupDefault"><spring:message code='Cache.lbl_SettingDefault' /></a> <!-- 기본 설정 -->
			<a id="groupAddSetTab" onclick="clickTab(this);" class="AXTab" value="divGroupAdd"><spring:message code='Cache.lbl_SettingAdditional' /></a> <!-- 추가 설정 -->
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
					<th id="thTitle"><spring:message code="Cache.lbl_JobTitleCode"/></th><!-- 직책/직위/직급코드 -->
					<td colspan="3">
						<label id="txtPfx"></label>
						<input type="text" class="AXInput HtmlCheckXSS ScriptCheckXSS" id="txtGroupCode">
						<label id="txtSfx"></label>
						<input type="button" class="AXButton" value="<spring:message code="Cache.lbl_DuplicateCheck"/>" onclick="checkDuplicate();" id="btnIsDuplicate">
					</td>
				</tr>
				<tr>
					<th id="thName"><spring:message code="Cache.lbl_JobTitleName"/></th><!-- 직책/직위/직급명 -->
					<td colspan="3">
						<input type="text" class="AXInput HtmlCheckXSS ScriptCheckXSS" id="txtGroupName" onchange="resetDicData(this);">
						<input type="button" class="AXButton" value="<spring:message code="Cache.lbl_MultiLangSet"/>" onclick="dictionaryLayerPopup('true', 'txtGroupName');">
					</td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_CompanyName"/></th><!-- 회사명 -->
					<td colspan="3">
						<input type="text" class="AXInput" id="txtCompanyName" readonly="readonly">
						<input id="hidCompanyID" type="hidden" />
					</td>
				</tr>
				<tr>
					<th ><spring:message code="Cache.lbl_IsUse"/><span class="txt_red">*</span></th><!-- 사용여부 -->
					<td>
						<select id="selIsUse" name="selIsUse" class="AXSelect">
							<option value="Y" selected><spring:message code="Cache.lbl_UseY"/></option>
							<option value="N"><spring:message code="Cache.lbl_noUse"/></option>
						</select>
					</td>
					<th><spring:message code="Cache.lbl_IsHR"/><span class="txt_red">*</span></th><!-- 인사연동여부 -->
					<td>
						<select id="selIsHR" name="selIsHR" class="AXSelect">
							<option value="Y" selected><spring:message code="Cache.lbl_UseY"/></option>
							<option value="N"><spring:message code="Cache.lbl_noUse"/></option>
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
							<option value="Y" selected><spring:message code="Cache.lbl_UseY"/></option>
							<option value="N"><spring:message code="Cache.lbl_noUse"/></option>
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
				<input type="button" id="btnSave" value="<spring:message code='Cache.btn_save' />" onclick="return saveArbitraryGroup();" class="AXButton red" > <!-- 저장 -->
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
						<div id="topitembar_2" class="">
							<label>
								<input type="button" value="<spring:message code="Cache.btn_Add"/>" onclick="btnMailAdd_OnClick();" class="usa" /> <!-- 추가 -->
								<input type="button" value="<spring:message code="Cache.btn_delete"/>" onclick="btnMailDel_OnClick();"class="usa"/> <!-- 삭제 -->
								<input type="button" value="▲ <spring:message code="Cache.btn_UP"/>" onclick="btnMailUp_OnClick();"class="usa"/> <!-- 위로 -->
								<input type="button" value="▼ <spring:message code="Cache.btn_Down"/>" onclick="btnMailDown_OnClick();"class="usa"/> <!-- 아래로 -->
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
			</table>
		</div>
	</form>
	<input type="hidden" id="GroupNameHidden" value="" />
	<input type="hidden" id="hidPrimary"  />
	<input type="hidden" id="hidSecondary"  />
	<script type="text/javascript">
		var check_dupMail = "N";
		var gr_code = "${code}";
		var mode = "${mode}";
		var domainCode = "${dncode}";
		var type = "${type}";
		var typeName = "";
		
		//개별호출 일괄처리
		var lang = Common.getSession("lang");
		Common.getBaseConfigList(["IsSyncMail","IsSyncIndi"]);
		Common.getBaseCodeList(["MailDomain"]);
		
		var isSyncMail = coviCmn.configMap["IsSyncMail"];
		var isSyncIndi = coviCmn.configMap["IsSyncIndi"];
		
		window.onload = initContent();
		
		function initContent(){	
			if(type == "T"){
				typeName = "JobTitle";
			}
			else if(type == "P"){
				typeName = "JobPosition";
			}
			else{
				typeName = "JobLevel";
			}
			
			$('#thTitle').text(Common.getDic("lbl_" + typeName + "_Code"));
			$('#thTitle').append("<span class=\"txt_red\">*</span>");
			$('#thName').text(Common.getDic("lbl_" + typeName + "Name"));
			$('#thName').append("<span class=\"txt_red\">*</span>");
			
			if (mode == "add"){
				setGroupPopDefaultInfo(domainCode, typeName);
				
				if(Common.getGlobalProperties("isSaaS") == "Y") {
					$("#txtMailID").attr("readonly", "readonly");
		    		$("#selMailDomain").attr("disabled","disabled");
				} else {
					$("#selIsMail").on("change", function() {
						fnMailUse(this);
					});
				}
			} else if(mode == "modify"){
				getGroupInfoData(gr_code);
				$("#btnIsDuplicate").css("display", "none");
				$("#txtGroupCode").attr("readonly", "readonly");
			}
			
			//기초설정에 따른 메일 표기 여부
			if(isSyncIndi == "Y"){
				$("#groupAddSetTab").css("display","none");
			}else if(isSyncMail == "Y"){
				$("#trIndiMail").css("display", "none");
			}else {
				$("#groupAddSetTab").css("display","none");
				var trMail = $('#selIsMail').closest('tr');
				trMail.children('td:first').attr('colspan', '3');
				trMail.children('th:nth-of-type(2)').css("display","none");
				trMail.children('td:nth-of-type(2)').css("display","none");
			}
			
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
		
		//임의그룹 정보 바인딩(수정시)
		function getGroupInfoData(gr_code) {
			$.ajax({
				type:"POST",
				data:{
					"gr_code" : gr_code
				},
				url:"/covicore/admin/orgmanage/getarbitrarygroupinfo.do",
				success:function (data) {
					$("#txtGroupCode").val(data.list[0].GroupCode);
					$("#txtGroupName").val(CFN_GetDicInfo(data.list[0].MultiGroupName, lang));
					$("#GroupNameHidden").val(data.list[0].MultiGroupName);
					$("#txtCompanyName").val(CFN_GetDicInfo(data.list[0].MultiCompanyName, lang));
					$("#hidCompanyID").val(data.list[0].CompanyID);
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
					
					if(data.list[0].PrimaryMail != ""){
						$("#hidMailAddressInfo").val(data.list[0].PrimaryMail);	
					}
					if(data.list[0].SecondaryMail != "" && data.list[0].SecondaryMail != undefined){
						$("#hidMailAddressInfo").val($("#hidMailAddressInfo").val() + "," + data.list[0].SecondaryMail);
					}
					
	                if ($("#hidMailAddressInfo").val() != "" && coviCmn.configMap["IsSyncMail"] == "Y") {
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
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/covicore/admin/orgmanage/getarbitrarygroupinfo.do", response, status, error);
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
					Common.Warning(Common.getDic("msg_" + typeName + "_01"));/* 직급/직위/직책 코드를 입력하십시오 */
				} else{
					if(Common.getGlobalProperties('isSaaS') == 'Y') gr_code = gr_code + $("#txtSfx").text();
					if(Common.getGlobalProperties('disablePrefix') == 'N') gr_code = $("#txtPfx").text() + gr_code;
					
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
									
									if(Common.getGlobalProperties("isSaaS") == "Y") {
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
		
		
		//유효성 검사
		function CheckValidation() {
			if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

			if($("#txtGroupCode").val() == "") {
				Common.Warning(Common.getDic("msg_" + typeName + "_01"), 'Warning Dialog', function() { /* 직급/직위/직책 코드를 입력하십시오 */
					$("#txtGroupCode").focus();
				});
				return false;
			} else if("${mode}" == "add" && check_dup == "N" ) {
				Common.Warning("<spring:message code='Cache.msg_BaseCode_04' />"); //코드 중복을 확인하여 주십시오.
				return false;
			} else if($("#txtGroupName").val() == "") {
				Common.Warning(Common.getDic("msg_" + typeName + "_02"), 'Warning Dialog', function() { /* 직급/직위/직책명을 입력하세요. */
					$("#txtGroupName").focus();
				});
				return false;
			} else if($("#GroupNameHidden").val() == "") {
				Common.Warning("<spring:message code='Cache.msg_GRNAME_04'/>", 'Warning Dialog', function() { //그룹명의 다국어 처리를 변경하십시오.
					$("#txtGroupName").focus();
				});
				return false;
			} else if($("#txtPriorityOrder").val() == "") {
				Common.Warning("<spring:message code='Cache.msg_EnterPriorityNumber' />", 'Warning Dialog', function() {  //우선순위를 입력하세요.
					$("#txtPriorityOrder").focus();
				});
				return false;
			} else{
				//추가속성 :: Primary, Secondary값 HiddenField에 저장합니다.
				var aObjectTR = $("#divAttributeList > TABLE > TBODY > TR");
				var nLength = aObjectTR.length;
				for (var i = 1; i < nLength; i++) {
					if (i == nLength - 1) {
						$("#hidSecondary").val($("#hidSecondary").val() +aObjectTR.filter(":eq(" + i.toString() + ")").text());
					} else {
						$("#hidSecondary").val($("#hidSecondary").val() + aObjectTR.filter(":eq(" + i.toString() + ")").text() + "|");
					}
				}
				$("#hidPrimary").val(aObjectTR.filter(":eq(0)").text());
				if (coviCmn.configMap["IsSyncMail"] == "Y") { //[2012-09-14 Modi] 기초 설정 메일 연동 여부에 따른 필수값 패스
					if ($("#selIsMail").val() == "Y") {
						if (aObjectTR.filter(":eq(0)").text() == "") {
							parent.Common.Warning("<spring:message code='Cache.msg_37'/>", "Warning Dialog", function () {                       // 메일주소를 입력하여 주십시오.
								clickTab($("#deptAddSetTab"));
							});
							return false;
						}
					}
				}
			}
			
			if(isSyncMail == 'Y') {
				//Exch 메일 사용
			} else if(isSyncIndi == "Y" && $("#selIsMail option:selected").val() == "Y"){
				if($("#txtMailID").val() == "" && $("#selMailDomain option:selected").val() == "") {
					Common.Warning("<spring:message code='Cache.msg_insert_MailAddress'/>", 'Warning Dialog', function() { // 메일 도메인을 선택해 주십시오.
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
			} else {
				if($("#txtMailID").val() != "" && $("#selMailDomain option:selected").val() == "") {
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
					}
				}
			}
			return true;
		}
		
		//임의 그룹 추가
		function saveArbitraryGroup(){
			
		    if(!CheckValidation()) return false;
			
			var txtGroupCode = $("#txtGroupCode").val();
			var txtGroupName = $("#txtGroupName").val();
			var txtMultiGroupName = $("#GroupNameHidden").val() != "" ? $("#GroupNameHidden").val() : $("#txtGroupName").val() + ";;;;;;;;;";
			var txtCompanyCode = domainCode;
			var txtIsUse = $("#selIsUse").val();
			var txtIsHR = $("#selIsHR").val();
			var txtIsMail = isSyncMail == "N" && isSyncIndi == "N" ? "N" : $("#selIsMail").val();
			var txtPriorityOrder = $("#txtPriorityOrder").val();
			var txtDescription = $("#txtDescription").val();
			var mailAddress= "";
			if($('#txtMailID').val() != "" && $('#selMailDomain').val() != "") {
				mailAddress = $('#txtMailID').val() + '@' + $('#selMailDomain').val();
			}
			var primary= $("#hidPrimary").val();
			var secondary= $("#hidSecondary").val();
			
			if("${mode}" == "add") {
				if($("#txtSfx").text() != "")txtGroupCode = txtGroupCode+$("#txtSfx").text() ;
				if($("#txtPfx").text() != "")txtGroupCode = $("#txtPfx").text() + txtGroupCode;
			}			
			
			Common.Progress(Common.getDic('msg_apv_008'));
			
			$.ajax({
				url : "/covicore/admin/orgmanage/registarbitarygroup.do",
				type : "POST",
				data : {
					"Mode": mode,
					"Type" : typeName,
					"TypeCode" : $("#hidCompanyID").val() + "_" + typeName,
					"GroupCode" : txtGroupCode,
					"GroupName" : txtGroupName,
					"MultiGroupName" : txtMultiGroupName,
					"CompanyCode" :  txtCompanyCode,
					"IsUse" :  txtIsUse,
					"IsHR" :  txtIsHR,
					"IsMail" :  txtIsMail,
					"PriorityOrder" :  txtPriorityOrder,
					"Description" : txtDescription,
					"MailAddress" : mailAddress,
					"PrimaryMail" : mailAddress,
					"OUName" : txtGroupName ,
					"EX_PrimaryMail" : primary,
					"SecondaryMail" : secondary
				},
				success : function(d) {
					try {
						if(d.result == "OK") {
							Common.Inform("<spring:message code='Cache.msg_Common_10'/>" , 'Information Dialog', function (result) { //저장 되었습니다
								parent.orgGrid.reloadList();
								closePopup();
					        }); 
						} else {
							Common.Warning("<spring:message code='Cache.msg_ErrorOccurred'/>" ); //오류가 발생하였습니다.
						}
					} catch(e) {
						
					}
				},
				error:function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("/covicore/admin/orgmanage/registarbitarygroup.do", response, status, error);
				}
			});
		}
		
		function addMailAddress(pType, pCode, pMode){//메일 속성
			parent.Common.open("", "MailAddress_Attribute", "<spring:message code='Cache.lbl_Mail_Attributes'/>" , "/covicore/mailaddress_attribute.do?type=" + encodeURIComponent(pType) + "&mail=" + encodeURIComponent(pCode) + "&mode=" + encodeURIComponent(pMode) + "&CallBackMethod=addMailAddress_after", "500px", "120px", "iframe", true, null, null, true);
			return;
		}
		
		function addMailAddress_after(){
			return;
		}
		
		// 추가속성 추가버튼 클릭시 호출되며, 추가속성 추가를 위한 팝업을 화면에 표시합니다.
		function btnMailAdd_OnClick() {
			var sMailID = $("#txtGroupCode").val();
	  	  	$("#hidMailAddressInfo").val("");
	        ShowMailAttributeSetting(sMailID, "0", "Add");
		}

		// 추가 속성을 입력하는 화면을 표시합니다.
		function ShowMailAttributeSetting(sMail, nIndex, sMode) {
			var sOpenName = "divAttribute";
			var sURL = "/covicore/mailaddressattributepop.do";
			sURL += "?iframename=ViewArbitraryGroup";
	        sURL += "&openname=" + sOpenName;
	        sURL += "&mailaddress=hidMailAddressInfo";
	        sURL += "&mail=" + sMail;
	        sURL += "&index=" + nIndex;
	        sURL += "&mode=" + sMode;
	        sURL += "&callbackmethod=btnAttributeAdd_OnClick_After";
			
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
								Common.Warning("<spring:message code='Cache.lbl_EmailAddresSame.'/>" , "Warning Dialog");
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
						sHTML += "<a href=\"javascript:ShowMailAttributeSetting('" + sMail + "', '" + nIndex + "', 'Edit');\" style=\"font-weight:bold\">";
						sHTML += sMail;
						sHTML += "</a>";
						sHTML += "</td>";
					}
					else {
						sHTML += "<tr Mail=\"Secondary\">";
						sHTML += "<td class=\"t_back01_line\" width=\"10\" Index='" + nIndex + "'>";
						sHTML += "<input id=\"chkAttribute_" + nIndex + "\" type=\"checkbox\" style=\"cursor: pointer;\" class=\"input_check\" />";
						sHTML += "<a href=\"javascript:ShowMailAttributeSetting('" + sMail + "', '" + nIndex + "', 'Edit');\" style=\"font-weight:\">";
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
				Common.Warning("<spring:message code='Cache.msg_Common_03' />", "Warning Dialog", function () { });      // 이동할 항목을 선택하여 주십시오.
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
		        sURL += "?iframename=divDeptInfo";
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
		
		function fnMailUse(pObj) {
	    	if($("#selIsMail option:selected").val() == "N") {
	    		if(isSyncIndi == "Y") {
		    		$("#txtMailID").attr("readonly", "readonly");
		    		$("#selMailDomain").attr("disabled","disabled");
	    		} else if (isSyncMail == "Y") {
	    			$("#groupAddSetTab").css("display","none");
	    		}
	    	}else {
	    		if(isSyncIndi == "Y") {
		    		$("#txtMailID").removeAttr("readonly");
		    		$("#selMailDomain").removeAttr("disabled");
	    		} else if(isSyncMail == "Y") {
	    			$("#groupAddSetTab").css("display","");
	    		}
	    	}
	    }
		
	</script>
</body>