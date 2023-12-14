<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="egovframework.baseframework.util.LicenseBizHelper" %>	
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>
<div class="moduleLCpop">
	<table class="AXFormTable mlc_table">
		<colgroup>
			<col style="width:150px;">
			<col>
			<col style="width:150px;">
			<col>
		</colgroup>
		<tbody>
			<tr>
				<th><spring:message code='Cache.lbl_licenseName'/><font color="red">*</font></th> <!-- 라이선스명 -->
				<td colspan="3">
					<input type="text" id="licName" placeholder="이름 입력 후 중복확인 필수(최대20자)" class="AXInput HtmlCheckXSS ScriptCheckXSS" style="width:83%" /> <!-- 이름 입력 후 중복확인 필수(최대20자) -->
					<input type="button" id="chkLicNameBtn" value="<spring:message code='Cache.btn_CheckDouble'/>" class="AXButton" onclick="" /> <!-- 중복확인 -->
					<input type="hidden" id="licDupName" value="" />
					<input type="hidden" id="isDupChk" value="N" />
				</td>
			</tr>
			<tr>
				<th><spring:message code='Cache.lbl_licenseKey'/><font color="red">*</font></th> <!-- 라이선스명 -->
				<td colspan="3">
					<input type="text" id="licModule" style="width:83%" /> <!-- 이름 입력 후 중복확인 필수(최대20자) -->
					<input type="button" id="chkLicModuleBtn" value="<spring:message code="Cache.btn_Confirm"/>" class="AXButton"/>
				</td>
			</tr>
			<tr>
				<th><spring:message code='Cache.lbl_includedModule'/><font color="red">*</font></th> <!-- 포함모듈 -->
				<td colspan="3">
					<div id="moduleDiv" class="option_setChk"></div>
				</td>
			</tr>
			<tr>
				<th><spring:message code='Cache.lbl_addtionStatus'/></th> <!-- 부가여부 -->
				<td colspan="3">
					<input type="text" kind="switch" id="IsOpt" on_value="Y" off_value="N" style="width:50px; height:21px; border:0px none;" />
				</td>
			</tr>
			<tr>
				<th>PC <spring:message code='Cache.lbl_portal'/></th> <!-- PC 포탈 -->
				<td colspan="3">
					<select id="portalSelect" class="AXSelect W100" data-axbind="select"></select>
				</td>
			</tr>
			<tr>
				<th>Mobile <spring:message code='Cache.lbl_portal'/></th> 	<!-- Mobile 포탈 -->
				<td colspan="3">
					<input type="text" kind="switch" id="IsMbPortal" on_value="Y" off_value="N" style="width:50px; height:21px; border:0px none;" />
				</td>
			</tr>
			<tr>
				<th><spring:message code='Cache.lbl_licenseDescription'/></th> <!-- 라이선스 설명 -->
				<td colspan="3">
					<input type="text" id="licDescription" class="AXInput HtmlCheckXSS ScriptCheckXSS" style="width:100%">
				</td>
			</tr>
		</tbody>
	</table>
	<div align="center" style="padding-top: 10px">
		<input type="button" id="saveBtn" class="AXButton red" value="<spring:message code='Cache.btn_save'/>"/> <!-- 저장 -->
		<input type="button" id="closeBtn" class="AXButton" value="<spring:message code='Cache.lbl_close'/>"/> <!-- 닫기 -->
	</div>
</div>

<script>
	(function(params){
		var setComponent = function(){
			// 포함모듈 세팅
			var $fragment = $(document.createDocumentFragment());
			<%String[] licModule = LicenseBizHelper.getLicenseBizSection(); 
			for (int i=0; i < licModule.length;i++){%>
				var Code = "<%=licModule[i]%>";
				var CodeName=Common.getBaseCodeDic("BizSection",Code);
				var $div = $("<div/>", {"style" : "float:left;width:110px"});
				$div.append($("<input/>", {"type": "checkbox", "id": "chk" + Code, "value": Code, "disabled":"false"}));
				$div.append($("<label/>", {"for": "chk" + Code, "text": CodeName}).prepend($("<span/>")));
				
				$fragment.append($div);
			<%}%>
			$("#moduleDiv").append($fragment);
			
			// 포탈 셀렉트 세팅
			setPortal();
			
			coviInput.setSwitch();
		}
		
		var setEvent = function(){
			// 라이선스 명 중복 체크
			$("#chkLicNameBtn").on("click", function(){
				if ($("#licName").val() !== $("#licDupName").val()) {
					chkDupLicenseName();
				} else {
					Common.Inform("<spring:message code='Cache.msg_sameExistLicenseName'/>"); // 기존의 라이선스 명과 동일합니다.
				}
			});
			
			$("#chkLicModuleBtn").on("click", function(){
				if($("#licModule").val() == ""){
					Common.Warning("<spring:message code='Cache.msg_RequiredCheck'/>");
					$("#licModule").focus();
				}else{//복호화 처리
					$("#moduleDiv input[type=checkbox]").prop("checked", false);
					$.ajax({
						type:"POST",
						data:{
							"licKey" : $("#licModule").val()
						},
						url:"/covicore/license/decryptLicenseKey.do",
						success:function (data) {
							if(data.status == "SUCCESS"){
								console.log(data.decryptVal)
								var moduleList = data.decryptVal ? data.decryptVal.split("|") : "";
								if (moduleList) {
									moduleList.forEach(function(item){
										$("#chk" + item).prop("checked", true);
									});
								}
							}
						},
						error:function(response, status, error){
							CFN_ErrorAjax("/covicore/baseconfig/encrypt.do", response, status, error);
						}
					});
				}
			});
			
			$("#licName").on("change", function(){
				$("#isDupChk").val("N");
			});
			
			<%-- // 부가여부 변경 이벤트(부가여부 N일 때, PC포탈 NULL, IsMbPortal=N) --%>
			$("#IsOpt").on("change", function() {
				if ( $("#IsOpt").val() == 'Y' ) {
					$("#portalSelect").prop("disabled", true); 	// PC포탈 값 설정 못하게 함.
					$("#portalSelect").val(""); 	// PC포탈 값 빈값처리.
					$("#IsMbPortal").closest("td").find(".AXanchorSwitchBox").removeClass("on"); // 스위치 off 처리.
					$("#IsMbPortal").val("N"); 		// Mobile 포탈 'N'
				} else {
					console.log("disable")
					$("#portalSelect").prop("disabled", false);
				}
			});
			
			// Mobile 포탈 변경 이벤트.
			$("#IsMbPortal").on("change", function() {
				if ($("#IsMbPortal").val() === 'Y') {
					if ($("#IsOpt").val() === 'N') {
						$("#IsMbPortal").closest("td").find(".AXanchorSwitchBox").removeClass("on");
						$("#IsMbPortal").val("N");
					}
				}
			});
			
			// 저장
			$("#saveBtn").on("click", function(){
				saveLicenseInfo();
			});
			
			// 닫기
			$("#closeBtn").on("click", function(){
				Common.Close();
			});
		}
		
		var setPortal = function(){
			$.ajax({
				type: "POST",
				url: "/covicore/license/getLicensePortal.do",
				data: {},
				success: function(data){
					if (data.status === "SUCCESS") {
						var $fragment = $(document.createDocumentFragment());
						var $option = $("<option/>", {"value": "", "text": "<spring:message code='Cache.lbl_selection'/>"}); // 선택
						
						$fragment.append($option);
						
						if (data.list && data.list.length > 0) {
							$(data.list).each(function(idx, item){
								var $option = $("<option/>", {"value": item.PortalID, "text": item.DisplayName});
								
								$fragment.append($option);
							});
						}
						
						$("#portalSelect").append($fragment);
					} else {
						Common.Warning("<spring:message code='Cache.msg_ErrorOccurred'/>"); // 오류가 발생하였습니다.
					}
				},
				error: function(response, status, error){
					CFN_ErrorAjax("/covicore/license/getLicensePortal.do", response, status, error);
				}
			});
		}
		
		var setLicenseInfo = function(){
			$.ajax({
				type: "POST",
				url: "/covicore/license/getLicenseManageInfo.do",
				data: {
					licSeq: params.licSeq
				},
				success: function(data){
					if (data.status === "SUCCESS") {
						
						$("#licName").val(data.LicName);
						$("#licModule").val(data.LicModule);
						$("#licDupName").val(data.LicName);
						$("#IsOpt").val(data.IsOpt);
						$("#licDescription").val(data.Description);
						$("#portalSelect").val(data.PortalID);
						$("#isDupChk").val("Y");
						$("#IsMbPortal").val(data.IsMbPortal);
						
						var moduleList = data.Module ? data.Module.split("|") : "";
						if (moduleList) {
							moduleList.forEach(function(item){
								$("#chk" + item).prop("checked", true);
							});
						}
					} else {
						Common.Warning("<spring:message code='Cache.msg_ErrorOccurred'/>"); // 오류가 발생하였습니다.
					}
				},
				error: function(response, status, error){
					CFN_ErrorAjax("/covicore/license/getLicenseManageInfo.do", response, status, error);
				}
			});
		}
		
		var chkDupLicenseName = function(){
			$.ajax({
				type: "POST",
				url: "/covicore/license/chkDupLicenseName.do",
				data: {
					licName: $("#licName").val()
				},
				success: function(data){
					if (data.status === "SUCCESS") {
						$("#isDupChk").val("Y");
						
						if (data.dupCnt > 0) {
							Common.Inform("<spring:message code='Cache.msg_alreadyExistLicName'/>", "Information", function(result){ // 이미 존재하는 라이선스 명입니다.
								if (result) {
									$("#licName").val("");
									$("#licName").focus();
								}
							})
						} else {
							Common.Inform("<spring:message code='Cache.msg_availableLicName'/>"); // 사용할 수 있는 라이선스 명입니다.
						}
					} else {
						Common.Warning("<spring:message code='Cache.msg_ErrorOccurred'/>"); // 오류가 발생하였습니다.
					}
				},
				error: function(response, status, error){
					CFN_ErrorAjax("/covicore/license/chkDupLicenseName.do", response, status, error);
				}
			});
		}
		
		var saveLicenseInfo = function(){
			if (!XFN_ValidationCheckOnlyXSS(false)) return;
			if (!chkValidation()) return;
			
			var url = "/covicore/license/addLicenseInfo.do";
			
			var chkModule = $("#moduleDiv input[type=checkbox]:checked").map(function(){
				return $(this).val();
			}).get().join(";");
			
			var param = {
				  licName: $("#licName").val()
				, licModule: $("#licModule").val()
				, module: chkModule
				, isOpt: $("#IsOpt").val()
				, portalID: $("#portalSelect").val()==""?"0":$("#portalSelect").val()
				, description: $("#licDescription").val()
				, isMbPortal : $("#IsMbPortal").val()
			};

			if (params.mode === "edit") {
				url = "/covicore/license/editLicenseInfo.do";
				param["licSeq"] = params.licSeq;
			}
			
			$.ajax({
				type: "POST",
				url: url,
				data: param,
				success: function(data){
					if (data.status === "SUCCESS") {
						Common.Inform("<spring:message code='Cache.msg_37'/>", "Information", function(result){ // 저장되었습니다.
							if (result) {
								parent.searchGrid();
								Common.Close();
							}
						});
					} else {
						Common.Warning("<spring:message code='Cache.msg_ErrorOccurred'/>"); // 오류가 발생하였습니다.
					}
				},
				error: function(response, status, error){
					CFN_ErrorAjax(url, response, status, error);
				}
			});
		}
		
		var chkValidation = function(){
			if (!$("#licName").val()) {
				Common.Warning("<spring:message code='Cache.msg_enterLicName'/>"); // 라이선스 명을 입력해주세요.
				return false;
			} else if ($("#isDupChk").val() === "N") {
				Common.Warning("<spring:message code='Cache.msg_dbChkLicName'/>"); // 라이선스 명 중복체크를 하십시오.
				return false;
			} else if ($("#moduleDiv input[type=checkbox]:checked").length === 0) {
				Common.Warning("<spring:message code='Cache.msg_selectIncludedModule'/>"); // 포함 모듈을 선택해주세요.
				return false;
			}
			
			return true;
		}
		
		var init = function(){
			setComponent();
			setEvent();
			
			// 부가여부 확인.
			if ( $("#IsOpt").val() === 'Y' ) {
				$("#portalSelect").prop("disabled", true);
				$("#portalSelect").val("");
			}
			
			if (params.mode === "edit") {
				setLicenseInfo();
			}
		}
		
		init();
	})({
		  licSeq: "${licSeq}"
		, mode: "${mode}"
	});
</script>