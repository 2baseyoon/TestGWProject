<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv='cache-control' content='no-cache'>
<meta http-equiv='expires' content='0'>
<meta http-equiv='pragma' content='no-cache'>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>

<style>
.txt_red {
    color: #e75c00;
}
</style>
</head>
<body>
	<%-- 상단 탭 --%>
	<div class="AXTabs">
		<div id="divTabTrayPop" class="AXTabsTray" style="height: 30px">
			<a id="tabTitle01" onclick="clickTab(this);" class="AXTab on" value="divTab01Content">module</a>			<!-- module -->
			<a id="tabTitle02" onclick="clickTab(this);" class="AXTab" value="divTab02Content">program</a> 				<!-- program -->
			<a id="tabTitle03" onclick="clickTab(this);" class="AXTab" value="divTab03Content">program_map</a>		<!-- program_map -->
			<a id="tabTitle04" onclick="clickTab(this);" class="AXTab" value="divTab04Content">program_menu</a> 	<!-- program_menu -->
		</div>
	
	<form>
		<!--  1st tab content -->
		<div id="divTab01Content" class="tabContent">
			<table id="tbl01tab01" class="AXFormTable">
				<colgroup>
					<col style="width: 25%"/>
					<col style="width: 25%"/>
					<col style="width: 25%"/>
					<col style="width: 25%"/>
				</colgroup>
				<tr>
					<th>BizSection <span class="txt_red">*</span></th>
					<td colspan="3"><input type="text" id="inptT1BizSection" style="width: 98%;" maxlength="40" /></td>
				</tr>
				<tr>
					<th>URL <span class="txt_red">*</span></th>
					<td colspan="3">
						<input type="text" id="inptT1Url" class="AXInput HtmlCheckXSS ScriptCheckXSS" style="width: 98%;" maxlength="90" onkeydown="fnOnlyEng(this)"/>
					</td>
				</tr>
			</table>
			<br/>
			
			<table id="tbl02tab01" class="AXFormTable">
				<colgroup>
					<col style="width: 25%"/>
					<col style="width: 25%"/>
					<col style="width: 25%"/>
					<col style="width: 25%"/>
				</colgroup>
				<tr id="trRecModuleId">
					<th>추천 ModuleID</th>
					<td colspan="3"><input type="text" id="inptRecModuleId" class="AXInput HtmlCheckXSS ScriptCheckXSS" style="width: 98%;" disabled/></td>
				</tr>
				<tr>
					<th>ModuleID <span class="txt_red">*</span></th>
					<td colspan="3">
						<input type="text" id="inptT1ModuleId" class="AXInput HtmlCheckXSS ScriptCheckXSS" style="width: 98%;" maxlength="90" onkeydown="" onkeyup="fnOnlyEng(this);fnCopyModuleID(this)"/>
					</td>
				</tr>
				<tr>
					<th>ModuleName</th>
					<td colspan="3"><input type="text" id="inptT1ModuleNm" class="AXInput HtmlCheckXSS ScriptCheckXSS" style="width: 98%;" maxlength="490"/></td>
				</tr>
				<tr>
					<th>AuditMethod</th>
					<td colspan="3"><input type="text" id="inptT1AuditMethod" maxlength="490" style="width: 98%;" /></td>
				</tr>
				<tr>
					<th>AuditClass</th>
					<td colspan="3"><input type="text" id="inptT1AuditClass" class="AXInput HtmlCheckXSS ScriptCheckXSS" style="width: 98%;" maxlength="490"></td>
				</tr>
				<tr>
					<th>IsUse</th>
					<td colspan="3">
						<label for="rdoIsUseY">
							<input type="radio" name="rdoIsUse" value="Y" id="rdoIsUseY" checked ">
							<spring:message code="Cache.lbl_USE_Y" />	<!-- 사용함 -->
						</label> &nbsp;&nbsp;
						<label for="rdoIsUseN">
							<input type="radio" name="rdoIsUse" value="N" id="rdoIsUseN" >
							<spring:message code="Cache.lbl_USE_N" /> 	<!-- 사용 안 함 -->
						</label> 
					</td>
				</tr>
				<tr>
					<th>IsAdmin</th>
					<td colspan="3">
						<label for="rdoIsAdminY">
							<input type="radio" name="rdoIsAdmin" value="Y" id="rdoIsAdminY" >
							<spring:message code="Cache.lbl_USE_Y" />	<!-- 사용함 -->
						</label> &nbsp;&nbsp;
						<label for="rdoIsAdminN">
							<input type="radio" name="rdoIsAdmin" value="N" id="rdoIsAdminN" checked>
							<spring:message code="Cache.lbl_USE_N" /> 	<!-- 사용 안 함 -->
						</label> 
					</td>
				</tr>
				<tr>
					<th>IsAudit</th>
					<td colspan="3">
						<label for="rdoIsAuditY">
							<input type="radio" name="rdoIsAudit" value="Y" id="rdoIsAuditY" >
							<spring:message code="Cache.lbl_USE_Y" />	<!-- 사용함 -->
						</label> &nbsp;&nbsp;
						<label for="rdoIsAuditN">
							<input type="radio" name="rdoIsAudit" value="N" id="rdoIsAuditN" >
							<spring:message code="Cache.lbl_USE_N" /> 	<!-- 사용 안 함 -->
						</label> 
					</td>
				</tr>
				<tr>
					<th>Description</th>
					<td colspan="3">
						<textarea id="txtDesc" class="HtmlCheckXSS ScriptCheckXSS" rows="3" style="width: 98%;" maxlength="490"></textarea>
					</td>
				</tr>
			</table>
			<table id="tbl03tab01" class="AXFormTable">
				<tr>
					<th>수정일</th>
					<td id="txtT1ModDate"></td>
					<th>수정계정</th>
					<td id="txtT1ModCode" style="text-overflow: ellipsis; overflow: hidden;"></td>
					<th>등록일</th>
					<td id="txtT1RegDate"></td>
					<th>등록계정</th>
					<td id="txtT1RegCode" style="text-overflow: ellipsis; overflow: hidden;"></td>
				</tr>
			</table>
			<br/>
			
			<table id="tbl04tab01" class="AXFormTable"></table>
			
			<input type="button" id="btnSlide" onclick="fnSlideDiv()" value="program_map 입력" />
		</div>
		
		<!-- 2nd tab content (program) -->
		<div style="display: none;" id="divTab02Content" class="tabContent">
			<table id="tbl01tab02" class="AXFormTable">
				<colgroup>
					<col style="width: 12.5%"/>
					<col style="width: 12.5%"/>
					<col style="width: 12.5%"/>
					<col style="width: 12.5%"/>
					<col style="width: 12.5%"/>
					<col style="width: 12.5%"/>
					<col style="width: 12.5%"/>
					<col style="width: 12.5%"/>
				</colgroup>
				<tr>
					<th colspan="2">PrgmID <span class="txt_red">*</span></th>
					<td colspan="2"><input type="text" id="inptT2PrgmId" class="AXInput HtmlCheckXSS ScriptCheckXSS" onkeydown="fnOnlyEng(this)" style="width: 98%;" maxlength="40"/></td>
					<th colspan="2">PrgmName</th>
					<td colspan="2"><input type="text" id="inptT2PrgmName" class="AXInput HtmlCheckXSS ScriptCheckXSS" style="width: 98%;" maxlength="390"/></td>
				</tr>
				<tr id="tr01tbl01tab02">
					<th>수정일</th>
					<td id="txtT2ModDate"></td>
					<th>수정계정</th>
					<td id="txtT2ModCode" style="text-overflow: ellipsis; overflow: hidden;"></td>
					<th>등록일</th>
					<td id="txtT2RegDate"></td>
					<th>등록계정</th>
					<td id="txtT2RegCode" style="text-overflow: ellipsis; overflow: hidden;"></td>
				</tr>
			</table>
		</div>
		
		<!-- 3rd tab content (program_map) -->
		<div style="display: none;" id="divTab03Content" class="tabContent">
			<table id="tbl01tab03" class="AXFormTable">
				<colgroup>
					<col style="width: 10%"/>
					<col style="width: 40%"/>
					<col style="width: 10%"/>
					<col style="width: 40%"/>
				</colgroup>
				<tr>
					<th>PrgmID <span class="txt_red">*</span></th>
					<td>
						<input type="text" id="inptT3PrgmId" class="AXInput HtmlCheckXSS ScriptCheckXSS" style="width: 70%;" disabled />
						<input type="button" id="btnT3PrgmIdCancel" class="AXButton BtnDelete" onclick="fnCancelT3PrgmId();" />
					</td>
					<th>ModuleID <span class="txt_red">*</span></th>
					<td>
						<input type="text" id="inptT3ModuleId" class="AXInput HtmlCheckXSS ScriptCheckXSS" style="width: 70%;" disabled />
						<input type="button" id="btnT3ModuleIdCancel" class="AXButton BtnDelete" onclick="fnCancelT3ModuleId();" />
					</td>
				</tr>
			</table>
		</div>
		
		<!-- 4th tab content (program_menu) -->
		<div style="display: none;" id="divTab04Content" class="tabContent">
			<table id="tbl01tab04" class="AXFormTable">
				<colgroup>
					<col style="width: 10%"/>
					<col style="width: 40%"/>
					<col style="width: 10%"/>
					<col style="width: 40%"/>
				</colgroup>
				<tr>
					<th>MenuID <span class="txt_red">*</span></th>
					<td>
						<input type="text" id="inptT4MenuId" class="AXInput HtmlCheckXSS ScriptCheckXSS" style="width: 70%;" value="" disabled />
						<input type="button" id="btnT4MenuIdCancel" class="AXButton BtnDelete" onclick="fnCancelT4MenuId();" />
					</td>
					<th>PrgmID <span class="txt_red">*</span></th>
					<td>
						<input type="text" id="inptT4PrgmId" class="AXInput HtmlCheckXSS ScriptCheckXSS" style="width: 70%;" value="" disabled />
						<input type="button" id="btnT4PrgmIdCancel" class="AXButton BtnDelete" onclick="fnCancelT4PrgmId();" />
					</td>
				</tr>
			</table>
			<table id="tbl02tab04" class="AXFormTable">
				<tr>
					<th>수정일</th>
					<td id="txtT4ModDate"></td>
					<th>수정계정</th>
					<td id="txtT4ModCode" style="text-overflow: ellipsis; overflow: hidden;"></td>
					<th>등록일</th>
					<td id="txtT4RegDate"></td>
					<th>등록계정</th>
					<td id="txtT4RegCode" style="text-overflow: ellipsis; overflow: hidden;"></td>
				</tr>
			</table>
		</div>
		
		<br/>
		<select id="searchTypePop" class="AXSelect W100" style="display: none;"></select>
		<input type="text" id="searchTextPop" class="AXInput" style="display: none;" onkeypress="if (event.keyCode==13){ getPopupGridData(this); return false;}" />&nbsp;
		<!-- 검색 버튼 -->
		<input type="button" id="searchBtnPop" value="<spring:message code='Cache.btn_search'/>" onclick="javascript:getPopupGridData(this);" class="AXButton" style="display: none;" />
		<br/>
		<!-- 검색결과 표시 -->
		<div id="searchResultPop" class="AXFormTable" style="display:none"></div>
		
		<!-- 저장 버튼 -->
		<div style="width: 97%; text-align: center; margin-top: 20px;">
			<input type="button" id="btnSaveData" value="<spring:message code='Cache.btn_save' />" onclick="saveData();" class="AXButton red"> <!-- 저장 -->
			<input type="button" id="btnEditData" value="<spring:message code='Cache.btn_Edit' />" onclick="editData();" class="AXButton red"> <!-- 수정 -->
			<input type="button" id="btnClose" value="<spring:message code='Cache.btn_Close' />" onclick="closePopup();" class="AXButton"> <!-- 닫기 -->
		</div>
	</form>
	</div>
</body>

<script type="text/javascript">

var popupMode = ""; 	// add(추가), dtlmodule(module상세)...

initialSet();

// 상세화면과 입력화면을 구분.
function initialSet() {

	if ( popupMode != undefined || popupMode != "" ) {
		popupMode = CFN_GetQueryString("popuptype");	
	}
	
	if ( popupMode === "add" ) {
		// 추가 화면일 때 세팅.
		$("#btnEditData").hide(); 	// 수정버튼
		$("#tbl03tab01").hide();	// 등록자, 수정자 hide.
		$("#tbl02tab04").hide();	// 등록자, 수정자 hide.
		$("#tbl04tab01").hide(); 	// 추가 내용 hide.
		$("#tr01tbl01tab02").hide();
		
		// 추가화면일 때, 어떠한 추가인지에 따라 팝업 화면 보여주는 부분을 제한함.
		var pTabVal = parent.$("#divTabTray").find(".AXTab.on").attr("value"); 
		
		if ( pTabVal != undefined && pTabVal === "tabMenu02") {	// module Tab에서 팝업창을 띄운 경우.
			clickTab($("#tabTitle01"));
			$("#tabTitle02").hide();
			$("#tabTitle03").hide();
			$("#tabTitle04").hide();
		} else if ( pTabVal != undefined && pTabVal === "tabMenu03") { 	// program tab에서 팝업창을 띄운 경우.
			clickTab($("#tabTitle02"));
			$("#tabTitle01").hide();
			$("#tabTitle03").hide();
			$("#tabTitle04").hide();
		} else if ( pTabVal != undefined && pTabVal === "tabMenu04") { 	// program_map tab에서 팝업창을 띄운 경우.
			clickTab($("#tabTitle03"));
			$("#tabTitle01").hide();
			$("#tabTitle02").hide();
			$("#tabTitle04").hide();
		} else if ( pTabVal != undefined && pTabVal === "tabMenu05") { 	// program_menu tab에서 팝업창을 띄운 경우.
			clickTab($("#tabTitle04"));
			$("#tabTitle01").hide();
			$("#tabTitle02").hide();
			$("#tabTitle03").hide();
		}
		
	} else if ( popupMode === "dtlmodule" ) {
		clickTab($("#tabTitle01"));
		
		$("#tabTitle02").hide();		// module 탭 제외하고 탭 감추기.
		$("#tabTitle03").hide();
		$("#tabTitle04").hide();
		$("#trRecModuleId").hide();		// 추천 ModuleID.
		$("#btnSaveData").hide();
		
		$("#inptT1ModuleId").prop("disabled", true);
		
		if ( CFN_GetQueryString("pid") != undefined || CFN_GetQueryString("pid") != "" ) {
			// 데이터 로딩.
			getModuleInfo( CFN_GetQueryString("pid") );	
		}
	} else if (popupMode === "dtlprgm") { 	// program 탭에서의 팝업일 때.
		clickTab($("#tabTitle02"));
	
		$("#tabTitle01").hide();
		$("#tabTitle03").hide();
		$("#tabTitle04").hide();
		$("#btnSaveData").hide();
		
		$("#inptT2PrgmId").prop("disabled", true);
		
		if ( CFN_GetQueryString("pid") != undefined || CFN_GetQueryString("pid") != "" ) {
			getPrmgInfo(CFN_GetQueryString("pid"));
		}
	} else if (popupMode === "dtlprgmmenu") { 		// program_menu 탭.
		clickTab($("#tabTitle04"));
		
		$("#tabTitle01").hide();
		$("#tabTitle02").hide();
		$("#tabTitle03").hide();
		$("#btnSaveData").hide();
		
		// 상세화면에서는 MenuId는 변경 못하게 select option과 지우기 버튼 처리.
		$("#searchTypePop option").remove();
		option = $('<option value="PrgmID">PrgmID</option><option value="PrgmName">PrgmName</option>');
		$("#searchTypePop").append(option);
		$("#btnT4MenuIdCancel").hide();
		
		if ( CFN_GetQueryString("pid") != undefined || CFN_GetQueryString("pid") != "" ) {
			getPrgmMenuInfo(CFN_GetQueryString("pid"));
		}
	}
}

//탭 클릭 이벤트.
function clickTab(pObj){
	
	$("#divTabTrayPop .AXTab").attr("class","AXTab");
	$(pObj).addClass("AXTab on");

	var str = $(pObj).attr("value");
		
	$(".tabContent").hide();		// all tabContent hide.
	$("#" + str).show();			// target tabContent show.
	
	$("#btnSlide").hide(); 			// module tab 추가 입력 show/hide.
	$("#searchResultPop").hide(); 	// 탭 변경이 되면 검색결과 숨기기.
	$("#searchTypePop").hide(); 	// 탭 변경 시마다 숨기기.
	$("#searchTextPop").hide();
	$("#searchBtnPop").hide();
	
	if ( CFN_GetQueryString("popuptype") === "add" ) {
		// 추가 팝업 & moduleTab.
		if (str === "divTab01Content") {
			$("#btnSlide").show();
			$("#searchTypePop option").remove();
		    option = $('<option value="PrgmID">PrgmID</option><option value="PrgmName">PrgmName</option>');
		    $("#searchTypePop").append(option);
		} else if (str === "divTab03Content") {
			// 추가 팝업 & program_map Tab.
			$("#searchTypePop option").remove();
			option = $('<option value="PrgmID">PrgmID</option><option value="PrgmName">PrgmName</option><option value="ModuleID">ModuleID</option><option value="ModuleName">ModuleName</option>');
			$("#searchTypePop").append(option);
			$("#searchTypePop").show();
			$("#searchTextPop").show();
			$("#searchBtnPop").show();
		} else if (str === "divTab04Content") {
			// 추가 팝업 & program_menu Tab.
			$("#searchTypePop option").remove();
			option = $('<option value="MenuID">MenuID</option><option value="MenuName">MenuName</option><option value="PrgmID">PrgmID</option><option value="PrgmName">PrgmName</option>');
			$("#searchTypePop").append(option);
			$("#searchTypePop").show();
			$("#searchTextPop").show();
			$("#searchBtnPop").show();
		}
	} else if ( CFN_GetQueryString("popuptype") === "dtlprgmmenu" ) {
		// divTab04Content
		$("#searchTypePop option").remove();
		option = $('<option value="MenuID">MenuID</option><option value="MenuName">MenuName</option><option value="PrgmID">PrgmID</option><option value="PrgmName">PrgmName</option>');
		$("#searchTypePop").append(option);
		$("#searchTypePop").show();
		$("#searchTextPop").show();
		$("#searchBtnPop").show();
	}
}

// 저장 버튼 클릭 이벤트.
function saveData() { 	// moduleTab 저장 이벤트.
	
	var pType = $(".AXTab.on")[0].getAttribute("value"); 	// 활성화 탭 확인.
	var params = {};
	
	// 각 탭에 따른 변경사항.
	if (pType === "divTab01Content") {			// 1st tab active mode(module tab).
		// 필수사항 체크(URL, ModuleID, BizSection).
		if ( $("#inptT1Url").val().trim().length == 0 || $("#inptT1ModuleId").val().trim().length == 0 
				|| $("#inptT1BizSection").val().trim().length == 0) {
			Common.Inform("<spring:message code='Cache.lbl_hr_require'/> <spring:message code='Cache.lbl_EnterContents'/>"); 	<!-- 필수 사항 내용을 입력하세요. -->
			return;
		}
		
		params = {
				"url" : $("#inptT1Url").val()
				, "moduleId": $("#inptT1ModuleId").val()
				, "moduleName" : $("#inptT1ModuleNm").val()
				, "auditClass" : $("#inptT1AuditClass").val()
				, "bizSection" : $("#inptT1BizSection").val()
				, "auditMethod" : $("#inptT1AuditMethod").val()
				, "isUse" : $("input[name='rdoIsUse']:checked").val()
				, "isAdmin" : $("input[name='rdoIsAdmin']:checked").val()
				, "isAudit" : $("input[name='rdoIsAudit']:checked").val()
				, "description" : $("#txtDesc").val()
				, "type" : "module"
				};
		
		// 추가로 prgm_map 테이블 입력이 있었다면,
		var targetObj = document.getElementById("divTab03Content");
		if (targetObj.style.display === "none") {
		} else {
			// prgm_map 테이블 입력 내용 추가 입력 확인.
			if ( $("#inptT3PrgmId").val() === undefined || $("#inptT3PrgmId").val() === ""
				|| $("#inptT3ModuleId").val() === undefined || $("#inptT3ModuleId").val() === "" ) {
				Common.Inform("<spring:message code='Cache.lbl_hr_require'/> <spring:message code='Cache.lbl_EnterContents'/>"); 	<!-- 필수 사항 내용을 입력하세요. -->
				return;
			}
			// prgm_map 데이터 추가.
			params.prgmId = $("#inptT3PrgmId").val();
			params.moduleId = $("#inptT3ModuleId").val();
			// type 변경.
			params.type = "modulePrgmMap"
		}
		
		fnSendAjax(params);
		
	} else if (pType === "divTab02Content") { 	// 2nd tab active mode(program tab).
		// on 상태에서의 필수값 확인.
		if ( $("#inptT2PrgmId").val() === undefined || $("#inptT2PrgmId").val() === "" ) {
			Common.Inform("<spring:message code='Cache.lbl_hr_require'/> <spring:message code='Cache.lbl_EnterContents'/>"); 	<!-- 필수 사항 내용을 입력하세요. -->
			return;
		}
		params = {
				"prgmId" : $("#inptT2PrgmId").val()
				, "prgmName" : $("#inptT2PrgmName").val()
				, "type" : "prgm"
		};
		
		fnSendAjax(params);
		
	} else if (pType === "divTab03Content") { 	// 3rd tab. (program_map)
		// 3rd tab(program_map)일 때 필수값 확인.
		if ( $("#inptT3PrgmId").val() === undefined || $("#inptT3PrgmId").val() === ""
				|| $("#inptT3ModuleId").val() === undefined || $("#inptT3ModuleId").val() === "" ) {
			Common.Inform("<spring:message code='Cache.lbl_hr_require'/> <spring:message code='Cache.lbl_EnterContents'/>"); 	<!-- 필수 사항 내용을 입력하세요. -->
			return;
		}
		params = {
				"prgmId" : $("#inptT3PrgmId").val()
				, "moduleId" : $("#inptT3ModuleId").val()
				, "type" : "prgmMap"
		};
		fnSendAjax(params);
	
	} else if (pType === "divTab04Content") { 	// 4th tab(program_menu) active mode.
		// 4th tab(program_menu)일 때 필수값 확인.
		if ( $("#inptT4MenuId").val() === undefined || $("#inptT4MenuId").val() === ""
				|| $("#inptT4PrgmId").val() === undefined || $("#inptT4PrgmId").val() === "" ) {
			Common.Inform("<spring:message code='Cache.lbl_hr_require'/> <spring:message code='Cache.lbl_EnterContents'/>"); 	<!-- 필수 사항 내용을 입력하세요. -->
			return;
		}
		params = {
				"menuId" : $("#inptT4MenuId").val()
				, "prgmId" : $("#inptT4PrgmId").val()
				, "type" : "prgmMenu"
		};
		fnSendAjax(params);
	} else {
		return;
	}
	
}

function fnSendAjax(pData) {
	
	$.ajax({
		type : "POST"
		, url : "/covicore/devhelper/saveModuleManage.do"
		, contentType : "application/json"
		, data : JSON.stringify(pData)
		, success : function(data){
			if(data.status == "SUCCESS"){
				Common.Inform("<spring:message code='Cache.msg_37'/>","", function() { 		//저장되었습니다.
					// todos : 후처리. pData.type === "module", "prgm" 등으로 분기 처리는 논의.
					parent.getGridData();	// 본 화면 재조회.
					closePopup();
				});
			} else if (data.status != "SUCCESS" && data.result > 0) {
				Common.Warning("<spring:message code='Cache.msg_AlreadyRegisted'/>"); 	// 이미 등록되어있습니다
			} else {
				Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); 	//오류가 발생헸습니다.
			}
		}
		, error : function(response, status, error){
            Common.Warning("<spring:message code='Cache.msg_apv_030'/>");     //오류가 발생헸습니다.
      	}
	});
}


function closePopup() { 	// 팝업창 닫기.
	
	var object_id = "";
	
	if ( popupMode === "add" ) {
		object_id = "divModuleAttr";
	} else if ( popupMode === "dtlmodule" ) {
		object_id = "divViewDetail";
	} else if ( popupMode === "dtlprgm") {
		object_id = "divViewDetail";
	} else if ( popupMode === "dtlprgmmenu") {
		object_id = "divViewDetail";
	}
	
	parent.Common.close(object_id);
}

var popupGrid;
//searchOption의 type()
// 1. program_map 탭의 PrgmID 검색,
// 2. program_map 탭의 ModuleID 검색,
// 3. program_menu 탭의 MenuID 검색.(PrgmID는 위의 1번 사용)
var searchOption = ""; 
function getPopupGridData(pObj) {	// 검색. 활성화된 탭과 searchType 필요.
	popupGrid = new coviGrid();
	
	var popTabActive = $("#divTabTrayPop").closest(".AXTabs").find(".AXTab.on").attr('value'); 	// 활성화탭.
	var divAddPrgmMap = document.getElementById("divTab03Content");
	
	if ( (popTabActive === "divTab03Content") && ($("#searchTypePop").val() === "PrgmID" || $("#searchTypePop").val() === "PrgmName") ) {
		searchOption = "prgm"; 		// 3rd Tab(program_map).
	} else if ( (popTabActive === "divTab03Content") && ($("#searchTypePop").val() === "ModuleID" || $("#searchTypePop").val() === "ModuleName") ) {
		searchOption = "module";
	} else if ( (popTabActive === "divTab04Content") && ($("#searchTypePop").val() === "MenuID" || $("#searchTypePop").val() === "MenuName") ) {
		searchOption = "menu";
	} else if ( (popTabActive === "divTab04Content") && ($("#searchTypePop").val() === "PrgmID" || $("#searchTypePop").val() === "PrgmName") ) {
		searchOption = "prgm";
	} else if ( (popTabActive === "divTab01Content") && (divAddPrgmMap.style.display != "none") && ($("#searchTypePop").val() === "PrgmID" || $("#searchTypePop").val() === "PrgmName") ) {
		searchOption = "prgm";
	} else if ( (popTabActive === "divTab01Content") && (divAddPrgmMap.style.display != "none") && ($("#searchTypePop").val() === "ModuleID" || $("#searchTypePop").val() === "ModuleName") ) {
		searchOption = "module";
	} else {
		return;		// 값이 없는 상태면 종료.
	}
	
	setPopGrid(searchOption);
	bindPopGrid(searchOption);
	
	$("#searchResultPop").show();
}

function setPopGrid(pOpt) {
	
	if (pOpt === "prgm") {
		popupGrid.setGridHeader([
			{key:'PrgmID', label:'PrgmID', align:'center', width:'400'}
			, {key:'PrgmName', label:'PrgmName', align:'center', width:'330'}
			, {key:'chk', label:'선택', align:'center', width:'100', formatter:function() {
				return "<input type='button' value='선택' onclick='putSearchVal(\""+ this.item.PrgmID +"\", \""+this.item.PrgmName+"\");' class='AXButton BtnAdd' ";
			}}
		]);
	} else if (pOpt === "module") {
		popupGrid.setGridHeader([
			{key:'ModuleID', label:'ModuleID', align:'center', width:'400'}
			, {key:'ModuleName', label:'ModuleName', align:'center', width:'330'}
			, {key:'chk', label:'선택', align:'center', width:'100', formatter:function() {
				return "<input type='button' value='선택' onclick='putSearchVal(\""+ this.item.ModuleID +"\", \""+this.item.ModuleName+"\");' class='AXButton BtnAdd' ";
			}}
		]);
	} else if (pOpt === "menu") {
		popupGrid.setGridHeader([
			{key:'MenuName', label:'MenuName', align:'center', width:'140'}
			, {key:'MenuID', label:'MenuID', align:'center', width:'80'}
			, {key:'BizSection', label:'BizSection', align:'center', width:'100'}
			, {key:'URL', label:'URL', align:'center', width:'440'}
			, {key:'chk', label:'선택', align:'center', width:'80', formatter:function() {
				return "<input type='button' value='선택' onclick='putSearchVal(\""+ this.item.MenuID +"\", \""+this.item.MenuName+"\");' class='AXButton BtnAdd' ";
			}}
		]);
	}
	
	var configObj = {
			targetID : "searchResultPop",
			height:"auto",
			fitToWidth: false, 		// 해당 grid의 간격이 자동으로 계산되는데 동작 이상을 보여, fitToWidth를 false로 세팅하고 setGridHeader에서 width로 설정함.  
			xscroll:true,
			page : {
				pageNo:1,
				pageSize:10
			},
			paging : true,
			sort: false
		};
	
	popupGrid.setGridConfig(configObj);
}

function bindPopGrid(pOpt) {
	var popUrl = "";
	if (pOpt === "prgm") {
		popUrl = "/covicore/devhelper/getPrgmDataList.do";
	} else if (pOpt === "module") {
		popUrl = "/covicore/devhelper/getModuleDataList.do";
	} else if (pOpt === "menu") {
		popUrl = "/covicore/devhelper/getMenuDataList.do";
	}
	var popParams = {
			"searchType" : $('#searchTypePop').val()
			, "searchText" : $('#searchTextPop').val()
	};
	popupGrid.bindGrid({
		ajaxUrl : popUrl
		, ajaxPars : popParams
	});
}

function putSearchVal(pID, pName) {

	if (searchOption === "prgm") {
		var popTabActive = $("#divTabTrayPop").closest(".AXTabs").find(".AXTab.on").attr('value');
		
		if ( popTabActive === "divTab01Content") { 	// module tab 활성화 && prgm_map 추가 입력
			$("#inptT3PrgmId").val(pID);
		} else if ( popTabActive === "divTab03Content" ) { 		// 활성화된 탭 확인.
			$("#inptT3PrgmId").val(pID);
		} else if (popTabActive === "divTab04Content") {
			$("#inptT4PrgmId").val(pID);
		}
	} else if (searchOption === "module") {
		$("#inptT3ModuleId").val(pID);
	} else if (searchOption === "menu") {
		$("#inptT4MenuId").val(pID);
	}
	
	$("#searchResultPop").hide();
}

function fnCancelT3PrgmId() {
	$("#inptT3PrgmId").val("");
}

function fnCancelT3ModuleId() {
	$("#inptT3ModuleId").val("");
}

function fnCancelT4MenuId() {
	$("#inptT4MenuId").val("");
}

function fnCancelT4PrgmId() {
	$("#inptT4PrgmId").val("");
}

// 추천 ModuleID
$("#inptT1Url").keyup(function() {
	
	var strUrlInput = $(this).val();
	var splitStrUrl = strUrlInput.replace(".do",""); 
	splitStrUrl = splitStrUrl.split("/");
	
	var strBizSection = $("#inptT1BizSection").val();
	var rtnVal = "";
	
	if (strBizSection === "account") {
		rtnVal = "acc";
	} else if (strBizSection === "approval") {
		rtnVal = "apv";
	} else if (strBizSection === "mobile") {
		rtnVal = "m";
	} else {
		rtnVal = strBizSection;
	}
		
	for (var i=2;splitStrUrl.length>i; i++) {
		if (strBizSection != splitStrUrl[i]) {
			
			if ( (strBizSection === "community") && ( ( splitStrUrl[i] === "layout") || ( splitStrUrl[i] === "userCommunity")) ) {
			} else if ( (strBizSection === "covicore") && ( splitStrUrl[i] === "aclhelper" ) ) {
			} else if ( (strBizSection === "mail") && ( splitStrUrl[i] === "companyPr" ) || ( splitStrUrl[i] === "downloadLargeFiles")
					|| ( splitStrUrl[i] === "exportToPc") || ( splitStrUrl[i] === "groupMail") || (splitStrUrl[i] === "transferRestriction") || (splitStrUrl[i] === "signatureForm") ) {
			} else if ( (strBizSection === "tf") && ( splitStrUrl[i] === "layout" ) ) {
			} else if ( (strBizSection === "webhard") && ( splitStrUrl[i] === "layout" ) ) {
			} else {
				rtnVal += "_" + splitStrUrl[i];	
			}
		}
	}
	$("#inptRecModuleId").val(rtnVal);
});

// 해당하는 id의 value 에 영어와 숫자, 특수기호만 받음. 한글은 빈값("")으로 replace.
function fnOnlyEng(pObj) {
	var strInput = $("#"+pObj.getAttribute("id")).val();
	$("#"+pObj.getAttribute("id")).val( strInput.replace(/[^\\!-z]/gi,"") );
}

// module tab에서 ModuleID가 입력되면, 추가 입력란의 ModuleID도 입력된다.
function fnCopyModuleID(pObj) {
	$("#inptT3ModuleId").val( $("#inptT1ModuleId").val() );
}

// 상세보기(Module 상세정보)
function getModuleInfo(pId) {

	var params = {"searchType" : "detail", "moduleId" : pId, "pageNo": "", "pageSize": "", "searchText": ""};
	
	$.ajax({
		type : "POST"
		, url : "/covicore/devhelper/getModuleDataList.do"
		, data : params
		, success : function(data){
			if(data.status == "SUCCESS"){
				if (data.list.length > 0) {
					$("#inptT1BizSection").val(data.list[0].BizSection);
					$("#inptT1AuditMethod").val(data.list[0].AuditMethod);
					$("#inptT1Url").val(data.list[0].URL);
					$("#inptT1ModuleId").val(data.list[0].ModuleID);
					$("#inptT1ModuleNm").val(data.list[0].ModuleName);
					$("#inptT1AuditClass").val(data.list[0].AuditClass);
					if (data.list[0].IsUse === "Y") { $("#rdoIsUseY").prop('checked', true); } else { $("#rdoIsUseN").prop('checked', true);}
					if (data.list[0].IsAdmin === "Y") { $("#rdoIsAdminY").prop('checked', true); } else { $("#rdoIsAdminN").prop('checked', true);}
					if (data.list[0].IsAudit === "Y") { $("#rdoIsAuditY").prop('checked', true); } else { $("#rdoIsAuditN").prop('checked', true);}
					$("#txtDesc").val(data.list[0].Description);
					$("#txtT1ModDate").text(data.list[0].ModifyDate);
					$("#txtT1ModCode").text(data.list[0].ModifierCode);
					$("#txtT1RegDate").text(data.list[0].RegistDate);
					$("#txtT1RegCode").text(data.list[0].RegisterCode);
					
					// module 정보의 추가 정보(메뉴이름, 연결 PrgmId, PrgmName)
					var strHtml = "<colgroup><col style='width: 4%'/><col style='width: 24%'/><col style='width: 24%'/><col style='width: 24%'/><col style='width: 24%'/></colgroup>";
					strHtml += "<tr><th colspan='2'>메뉴이름</th><td colspan='3'>" + data.list[0].AuditMenuNm + "</td></tr>";
					$("#tbl04tab01").append(strHtml);
					if (data.listPrgm != undefined && data.listPrgm.length > 0) {
						data.listPrgm.forEach(function(item, idx) {
							strHtml = "<tr><th>"+ (idx+1) +"</th>";
							strHtml += "<th>PrgmID</th><td>"+item.PrgmID+"</td>";
							strHtml += "<th>PrgmName</th><td>"+item.PrgmName+"</td></tr>";
							$("#tbl04tab01").append(strHtml);
						})
					}
				}
				
			} else if (data.status != "SUCCESS" && data.result > 0) {
				Common.Warning("<spring:message code='Cache.msg_AlreadyRegisted'/>"); 	// 이미 등록되어있습니다
			} else {
				Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); 	//오류가 발생헸습니다.
			}
		}
		, error : function(response, status, error){
            Common.Warning("<spring:message code='Cache.msg_apv_030'/>");     //오류가 발생헸습니다.
      	}
	});
}

// 수정버튼 이벤트.
function editData() {
	var pType = $(".AXTab.on")[0].getAttribute("value");  // 활성화 탭 확인.
	var params = {};
	
	if (pType === "divTab01Content") { 		// module tab 에서 수정버튼 클릭을 확인.
		params = {
			"bizSection" : $("#inptT1BizSection").val()
			, "url" : $("#inptT1Url").val()
			, "moduleId" : $("#inptT1ModuleId").val()
			, "moduleName" : $("#inptT1ModuleNm").val()
			, "auditMethod" : $("#inptT1AuditMethod").val()
			, "auditClass" : $("#inptT1AuditClass").val()
			, "isUse" : $("input[name='rdoIsUse']:checked").val()
			, "isAdmin" : $("input[name='rdoIsAdmin']:checked").val()
			, "isAudit" : $("input[name='rdoIsAudit']:checked").val()
			, "description" : $("#txtDesc").val()
			, "type" : "modModule"
		};		
	} else if ( pType === "divTab02Content") { 		// program tab 수정.
		params = {
			"prgmId" : $("#inptT2PrgmId").val()
			, "prgmName" :  $("#inptT2PrgmName").val()
			, "type" : "modPrgm"
		};
	} else if ( pType === "divTab04Content" ) { 	// program_menu 수정.
		params = {
			"menuId" : $("#inptT4MenuId").val()
			, "prgmId" : $("#inptT4PrgmId").val()
			, "type" : "modPrgmMenu"
		};
	}
	
	fnModSendAjax(params);
}

// 수정 ajax
function fnModSendAjax(pData) {
	if (pData.type === "modModule") { 	// module tab 수정 일 때.
		// 필수사항 체크(BizSection, URL, ModuleID ).
		if ( $("#inptT1Url").val().trim().length == 0 || $("#inptT1ModuleId").val().trim().length == 0 
				|| $("#inptT1BizSection").val().trim().length == 0 ) {
			Common.Inform("<spring:message code='Cache.lbl_hr_require'/> <spring:message code='Cache.lbl_EnterContents'/>"); 	<!-- 필수 사항 내용을 입력하세요. -->
			return;
		}	
	} else if (pData.type === "modPrgm") {
		// 필수사항 체크(prgmId, prgmName)
		if (pData.prgmId.trim().length == 0) {
			Common.Inform("<spring:message code='Cache.lbl_hr_require'/> <spring:message code='Cache.lbl_EnterContents'/>"); 	<!-- 필수 사항 내용을 입력하세요. -->
			return;
		}
	} else if (pData.type === "modPrgmMenu") {
		// 필수사항 체크(menuId, prgmId)
		if (pData.menuId.trim().length == 0 || pData.prgmId.trim().length == 0) {
			Common.Inform("<spring:message code='Cache.lbl_hr_require'/> <spring:message code='Cache.lbl_EnterContents'/>"); 	<!-- 필수 사항 내용을 입력하세요. -->
			return;			
		}
	}
	
	$.ajax({
		type : "POST"
		, url : "/covicore/devhelper/modifyModuleData.do"
		, contentType : "application/json"
		, data : JSON.stringify(pData)
		, success : function(data){
			if(data.status == "SUCCESS"){
				Common.Inform("<spring:message code='Cache.msg_37'/>","", function() { 		//저장되었습니다.
					parent.getGridData();	// 본 화면 재조회.
					closePopup();
				});
			}
		}
		, error : function(response, status, error){
            Common.Warning("<spring:message code='Cache.msg_apv_030'/>");     //오류가 발생헸습니다.
      	}
	});
}

// 상세보기, program
function getPrmgInfo(pId) {
	var params = {"searchType" : "detail", "prgmId" : pId, "pageNo": "", "pageSize": "", "searchText": ""};
	$.ajax({
		type : "POST"
		, url : "/covicore/devhelper/getPrgmDataList.do"
		, data : params
		, success : function(data){
			if(data.status == "SUCCESS") {
				if (data.list.length > 0) {
					$("#inptT2PrgmId").val(data.list[0].PrgmID);
					$("#inptT2PrgmName").val(data.list[0].PrgmName);
					$("#txtT2ModDate").text(data.list[0].ModifyDate);
					$("#txtT2ModCode").text(data.list[0].ModifierCode);
					$("#txtT2RegDate").text(data.list[0].RegistDate);
					$("#txtT2RegCode").text(data.list[0].RegisterCode);
				}
			} else {
				Common.Warning("<spring:message code='Cache.msg_apv_030'/>");     //오류가 발생헸습니다.
			}
		}
		, error : function(response, status, error) {
        	Common.Warning("<spring:message code='Cache.msg_apv_030'/>");     //오류가 발생헸습니다.
        }
	});
}

function getPrgmMenuInfo(pId) {
	var params = {"searchType" : "detail", "menuId" : pId, "pageNo": "", "pageSize": "", "searchText": ""};
	$.ajax({
		type : "POST"
		, url : "/covicore/devhelper/getPrgmMenuDataList.do"
		, data : params
		, success : function(data){
			if(data.status == "SUCCESS") {
				if (data.list.length > 0) {
					$("#inptT4MenuId").val(data.list[0].MenuID);
					$("#inptT4PrgmId").val(data.list[0].PrgmID);
					$("#txtT4ModDate").text(data.list[0].ModifyDate);
					$("#txtT4ModCode").text(data.list[0].ModifierCode);
					$("#txtT4RegDate").text(data.list[0].RegistDate);
					$("#txtT4RegCode").text(data.list[0].RegisterCode);
				}
			} else {
				Common.Warning("<spring:message code='Cache.msg_apv_030'/>");     //오류가 발생헸습니다.
			}
		}
		, error : function(response, status, error) {
        	Common.Warning("<spring:message code='Cache.msg_apv_030'/>");     //오류가 발생헸습니다.
        }
	});
}

function fnSlideDiv() {
	var targetObj = document.getElementById("divTab03Content");
	if (targetObj.style.display === "none") {
		$("#divTab03Content").slideDown(500, function () {
			$("#searchTypePop").show();
		    $("#searchTextPop").show();
		    $("#searchBtnPop").show();
		});
	} else {
		$("#divTab03Content").slideUp(500, function () {
		    $("#searchTypePop").hide();
		    $("#searchTextPop").hide();
		    $("#searchBtnPop").hide();
		});
	}
}

</script>