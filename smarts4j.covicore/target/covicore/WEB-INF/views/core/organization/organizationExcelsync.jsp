<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code="Cache.CN_214"/></span>
</h3>

<form>	
	<div style="width:100%;min-height: 500px">
		<div id="topitembar_1" class="topbar_grid">
			<input type="button" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"class="AXButton BtnRefresh"/> <!-- 새로고침 -->
			<input type="button" value="<spring:message code="Cache.btn_ExcelDownloadDept"/>" onclick="excelDownload('exdept');" class="AXButton BtnExcel" /> <!-- 부서 엑셀 다운로드 -->
			<input type="button" value="<spring:message code="Cache.btn_ExcelDownloadUser"/>" onclick="excelDownload('exuser');" class="AXButton BtnExcel" /> <!-- 사용자 엑셀 다운로드 -->
			<input type="button" value="<spring:message code="Cache.btn_TempRefresh"/>" onclick="checkSyncCompany(companyCode,'','DELETE');"class="AXButton BtnDelete"/> <!-- 대상 데이터 초기화 -->
			<input type="button" value="<spring:message code="Cache.btn_AllRefresh"/>" onclick="checkSyncCompany(companyCode,'','RESET');"class="AXButton BtnDelete"/> <!-- 모두 초기화 -->
			<input type="button" value="<spring:message code="Cache.lbl_OrgSync"/>" onclick="checkSyncCompany(companyCode,'','SYNC');" class="AXButton"/> <!-- 조직도 동기화 -->
		</div>
		<!-- Dept -->
		<div id="topitembar_2" class="topbar_grid" >
			<label style="color: red; font-weight: bold; margin-right: 10px;">부서</label>
			<input type="file" id="importedFiledept" style="width: 50%;" accept=".csv, .txt" onchange="changeAttachFile('dept')"><!-- accept=".csv, .xls, .xlsx, .txt"  -->
			<input type="button" id="btnImportdept" value="<spring:message code='Cache.btn_fileOpen' />" onclick="checkSyncCompany(companyCode,'dept','DATA');" class="AXButton"/>
		</div>
		<div id="topitembar_3" class="topbar_grid" >
			<label><spring:message code="Cache.lbl_OrgSyncType"/></label>&nbsp;
			<select id="selDeptSyncType" name="selDeptSyncType" class="AXSelect" onchange="setdeptGrid();"> <!-- 동기화 타입 -->
				<option value="" selected><spring:message code="Cache.lbl_Whole" /></option>
				<option value="INSERT"><spring:message code="Cache.lbl_Add" /></option>
				<option value="UPDATE"><spring:message code="Cache.lbl_Modify" /></option>
				<option value="DELETE"><spring:message code="Cache.lbl_delete" /></option>
			</select>
			<label style="margin-left: 10px;">검색조건</label>&nbsp;
			<select id="selSearchTypeDept" name="selSearchTypeDept" class="AXSelect"> <!-- 검색조건 -->
				<option value="GroupCode" selected>부서코드</option>
				<option value="DisplayName">부서명</option>
			</select>
			<input type="text" class="AXInput" id="txtSearchTextDept" onKeypress="if(event.keyCode==13) {setdeptGrid(); return false;}">
			<input type="button" id="btnSearchDept" value="<spring:message code='Cache.btn_search' />" onclick="setdeptGrid();" class="AXButton" > <!-- 검색 -->
			<input type="button" value="<spring:message code="Cache.btn_deleteDept"/>" onclick="deleteOrgDept();"class="AXButton BtnDelete" style="margin-left: 10px;"/> <!-- 부서 선택 삭제 -->
		</div>
		<div id="resultBoxWrap">
			<div id="orgdeptexcelgrid"></div>
			<div id="orgtempdeptexcelgrid" style="display:none;" ></div>
		</div>
		
		<!-- User -->
		<div id="topitembar_4" class="topbar_grid"">
			<label style="color: red; font-weight: bold; margin-right: 10px;">사용자</label>
			<input type="file" id="importedFileuser" style="width: 50%;" accept=".csv, .txt" onchange="changeAttachFile('user')"><!-- accept=".csv, .xls, .xlsx, .txt"  -->
			<input type="button" id="btnImportuser" value="<spring:message code='Cache.btn_fileOpen' />" onclick="checkSyncCompany(companyCode,'user','DATA');" class="AXButton"/>
		</div>
		<div id="topitembar_5" class="topbar_grid">
			<label style="margin-left: 10px;"><spring:message code="Cache.lbl_OrgSyncType"/></label>&nbsp;
			<select id="selUserSyncType" name="selUserSyncType" class="AXSelect" onchange="setuserGrid();"> <!-- 동기화 타입 -->
				<option value="" selected><spring:message code="Cache.lbl_Whole" /></option>
				<option value="INSERT"><spring:message code="Cache.lbl_Add" /></option>
				<option value="UPDATE"><spring:message code="Cache.lbl_Modify" /></option>
				<option value="DELETE"><spring:message code="Cache.lbl_delete" /></option>
			</select>
			<label style="margin-left: 10px;">검색조건</label>&nbsp;
			<select id="selSearchTypeUser" name="selSearchTypeUser" class="AXSelect"> <!-- 검색조건 -->
				<option value="UserCode" selected>사용자 ID</option>
				<option value="DisplayName">사용자명</option>
			</select>
			<input type="text" class="AXInput" id="txtSearchTextUser" onKeypress="if(event.keyCode==13) {setuserGrid(); return false;}">
			<input type="button" id="btnSearchUser" value="<spring:message code='Cache.btn_search' />" onclick="setuserGrid();" class="AXButton" > <!-- 검색 -->
			<input type="button" value="<spring:message code="Cache.btn_deleteUser"/>" onclick="deleteOrgUser();"class="AXButton BtnDelete" style="margin-left: 10px;"/> <!-- 사용자 선택 삭제 -->
		</div>
		<div id="resultBoxWrap">
			<div id="orguserexcelgrid"></div>
			<div id="orgtempuserexcelgrid" style="display:none;" ></div>
		</div>
		
	</div>
</form>
<script>	
	var isMailDisplay = true;
	var companyCode = $("#domainCodeSelectBox").val();
	
	var exceldeptGrid = new coviGrid();
	var exceluserGrid = new coviGrid();
	
	$(document).ready(function () {
		setdeptGrid();
		setuserGrid();
	});
	
	function setdeptGrid() {
		exceldeptGrid.setGridHeader(GridHeaderDept());
		setdeptGridConfig();
		bindGrid('dept');
	}
	
	function setuserGrid() {
		exceluserGrid.setGridHeader(GridHeaderUser());
		setuserGridConfig();
		bindGrid('user');
	}
	
	function setGrid(object, ptype) {
		if(ptype == "dept") {
			insertTempDeptData(object);
			setdeptGrid();
		}
		else {
			insertTempUserData(object);
			setuserGrid();
		}
	}
	
	function GridHeaderDept() {
		return [
			{key:'deptchk', label:'chk', width:'20', align:'center', formatter:'checkbox'},
			{key:'deptSyncType',  label:'<spring:message code="Cache.lbl_OrgSyncType"/>', width:'30', align:'center'},
			{key:'deptGroupCode',  label:'<spring:message code="Cache.lbl_DeptCode"/>', width:'30', align:'center'},
			{key:'deptCompanyCode',  label:'<spring:message code="Cache.lbl_apv_entcode"/>', width:'30', align:'center'},
			{key:'deptMemberOf',  label:'<spring:message code="Cache.lbl_apv_UpperDeptCode"/>', width:'30', align:'center'},
			{key:'deptDisplayName',  label:'<spring:message code="Cache.lbl_DeptName"/>', width:'30', align:'center'},
			{key:'deptSortKey',  label:'<spring:message code="Cache.lbl_PriorityOrder"/>', width:'30', align:'center'},
			{key:'deptIsUse', label:'<spring:message code="Cache.lbl_IsUse"/>', width:'30', align:'center'},
			{key:'deptIsHR', label:'<spring:message code="Cache.lbl_IsHR"/>',  width:'30', align:'center'},
			{key:'deptIsDisplay', label:'<spring:message code="Cache.lbl_IsDisplay"/>',   width:'30', align:'center'},
			{key:'deptIsMail', label:'<spring:message code="Cache.lbl_IsMail"/>',   width:'30', align:'center'},
			{key:'deptPrimaryMail', label:'<spring:message code="Cache.lbl_Mail"/>', width:'30', align:'center'},
			{key:'deptManagerCode', label:'<spring:message code="Cache.lbl_admin"/>', width:'30', align:'center'}
		];
	}
	
	function GridHeaderUser() {
		return [
			{key:'userchk', label:'chk', width:'20', align:'center', formatter:'checkbox'},
			{key:'userSyncType',  label:'<spring:message code="Cache.lbl_OrgSyncType"/>', width:'30', align:'center'},
			{key:'userUserCode',  label:'<spring:message code="Cache.lbl_User_Id"/>', width:'30', align:'center'},
			{key:'userCompanyCode',  label:'<spring:message code="Cache.lbl_apv_entcode"/>', width:'30', align:'center'},
			{key:'userSortKey',  label:'<spring:message code="Cache.lbl_PriorityOrder"/>', width:'30', align:'center'},
			{key:'userDisplayName', label:'<spring:message code="Cache.lbl_User"/>', width:'30', align:'center'},
			{key:'userJobTitleCode',  label:'<spring:message code="Cache.lbl_JobTitle"/>', width:'30', align:'center'},
			{key:'userJobPositionCode',  label:'<spring:message code="Cache.lbl_JobPosition"/>', width:'30', align:'center'},
			{key:'userJobLevelCode',  label:'<spring:message code="Cache.lbl_JobLevel"/>', width:'30', align:'center'},
			{key:'userIsUse', label:'<spring:message code="Cache.lbl_IsUse"/>', width:'30', align:'center'},
			{key:'userIsHR', label:'<spring:message code="Cache.lbl_IsHR"/>',  width:'30', align:'center'},
			{key:'userUseMailConnect', label:'<spring:message code="Cache.lbl_IsMail"/>',  width:'30', align:'center'},
			{key:'userMailAddress', label:'<spring:message code="Cache.lbl_Mail"/>', width:'30', align:'center'},
			{key:'useMessengerConnect', label:'<spring:message code="Cache.lbl_IsMSG"/>', width:'30', align:'center'}
		];
	}
	
	function setdeptGridConfig(){
		exceldeptGrid.setGridConfig({
			targetID: "orgdeptexcelgrid",
			height: "auto",
			page: { pageNo: 1, pageSize: 5 },
			paging: true,
			colHead: {},
			body: {}
		});
	}
	
	function setuserGridConfig(){
		exceluserGrid.setGridConfig({
			targetID: "orguserexcelgrid",
			height: "auto",
			page: { pageNo: 1, pageSize: 5 },
			paging: true,
			colHead: {},
			body: {}
		});
	}
	
	function bindGrid(type) {
		var url;
		var gr_code;
		var grouptype;
		var domainCode;
		var sortBy;
		var params;
		
		if(type == null || type == undefined) {
			type = "dept";
		}
		
		switch(type) {
			case "dept":
				url = "/covicore/admin/orgmanage/getExcelTempDeptList.do";
				sortBy = exceldeptGrid.getSortParam();
				params = {
					"companyCode": companyCode,
					"sortBy": sortBy,
					"syncType": $("#selDeptSyncType").val(),
					"searchType": $("#selSearchTypeDept").val(),
					"searchText": $("#txtSearchTextDept").val()
				};
				exceldeptGrid.bindGrid({
		 			ajaxUrl: url,
		 			ajaxPars: params
				});
				break;
			case "user":
				url = "/covicore/admin/orgmanage/getExcelTempUserList.do";
				sortBy = exceluserGrid.getSortParam();
				params = {
					"companyCode": companyCode,
					"sortBy": sortBy,
					"syncType": $("#selUserSyncType").val(),
					"searchType": $("#selSearchTypeUser").val(),
					"searchText": $("#txtSearchTextUser").val()
				};
				exceluserGrid.bindGrid({
		 			ajaxUrl: url,
		 			ajaxPars: params
				});
				break;
		}
	}

	function Refresh() {
		var url = location.href;
		location.href = url;
	}
	
	function deleteOrgDept(){
		var deleteObject = exceldeptGrid.getCheckedList(0);
		
		if(deleteObject.length == 0 || deleteObject == null){
			Common.Inform("<spring:message code='Cache.msg_CheckDeleteObject'/>"); 
			return false;
		}
		else{
			Common.Confirm("<spring:message code='Cache.msg_152'/>", "Confirmation Dialog", function (result) {
				if(result) {
					var deleteSeq = "";
					
					for(var i=0; i < deleteObject.length; i++){
						if(i==0){
							deleteSeq = deleteObject[i].deptGroupCode;
						}else{
							deleteSeq = deleteSeq + "," + deleteObject[i].deptGroupCode;
						}
					}
					
					$.ajax({
						type: "POST",
						data: {
							"deleteData": deleteSeq
						},
						url: "/covicore/admin/orgmanage/deleteSelectDept.do",
						success: function (data) {
							if(data.status == "FAIL") {
								Common.Warning(data.message);
							}
							else {
								Common.Inform("<spring:message code='Cache.msg_138'/>", "Information Dialog", function(result) {
									if(result) {
										exceldeptGrid.reloadList();
									}
								});
							}
						},
						error: function(response, status, error){
							CFN_ErrorAjax("/covicore/admin/orgmanage/deleteSelectDept.do", response, status, error);
						}
					});
				}
			});
		}
	}
	
	function deleteOrgUser(){
		var deleteObject = exceluserGrid.getCheckedList(0);
		
		if(deleteObject.length == 0 || deleteObject == null){
			Common.Inform("<spring:message code='Cache.msg_CheckDeleteObject'/>"); 
			return false;
		}
		else{			
			Common.Confirm("<spring:message code='Cache.msg_152'/>", "Confirmation Dialog", function (result) {
				if(result) {
					var deleteSeq = "";
					
					for(var i=0; i < deleteObject.length; i++){
						if(i==0) {
							deleteSeq = deleteObject[i].userUserCode;
						}
						else {
							deleteSeq = deleteSeq + "," + deleteObject[i].userUserCode;
						}
					}
					
					$.ajax({
						type: "POST",
						data: {
							"deleteData" : deleteSeq
						},
						url: "/covicore/admin/orgmanage/deleteSelectUser.do",
						success: function (data) {
							if(data.status == "FAIL") {
								Common.Warning(data.message);
							}
							else {
								Common.Inform("<spring:message code='Cache.msg_138'/>", "Information Dialog", function(result) {
									if(result) {
										exceluserGrid.reloadList();
									}
								});
							}
						},
						error: function(response, status, error){
							CFN_ErrorAjax("/covicore/admin/organization/deleteuser.do", response, status, error);
						}
					});
				}
			});
		}
	}
	
	function deleteTemp() {
		if(check_syncCompany){
			Common.Confirm("<spring:message code='Cache.msg_DoyouInit'/>", "Confirmation Dialog", function (result) { // 동기화 대상을 삭제하시겠습니까?
				if(result) {
					$.ajax({
						type: "POST",
						url: "/covicore/admin/orgmanage/deleteTemp.do",
						success: function (data) {
							if(data.status == "FAIL") {
								Common.Warning(data.message);
							}
							else {
								Common.Inform("<spring:message code='Cache.msg_138'/>", "Information Dialog", function(result) {
									if(result) {
										exceldeptGrid.reloadList();
										exceluserGrid.reloadList();
									}
								});
							}
						},
						error: function(response, status, error){
							CFN_ErrorAjax("/covicore/admin/organization/deleteTemp.do", response, status, error);
						}
					});
				}
	
			});
		}
	}
	
	function deleteAll() {
		if(check_syncCompany) {
			Common.Confirm("<spring:message code='Cache.msg_DoyouInit'/>", "Confirmation Dialog", function (result) { // 초기화하시겠습니까?
				if(result) {
					$.ajax({
						type: "POST",
						data: {
							"syncCompanyCode" : companyCode
						},
						url: "/covicore/admin/orgmanage/deleteAll.do",
						success: function (data) {
							if(data.status == "FAIL") {
								Common.Warning(data.message);
							}
							else {
								Common.Inform("<spring:message code='Cache.msg_138'/>", "Information Dialog", function(result) {
									if(result) {
										exceldeptGrid.reloadList();
										exceluserGrid.reloadList();
									}
								});
							}
						},
						error: function(response, status, error){
							CFN_ErrorAjax("/covicore/admin/organization/deleteAll.do", response, status, error);
						}
					});
				}
			});
		}
	}
	
	//엑셀동기화 대상 계열사 확인
	var check_syncCompany = false;
	
	function checkSyncCompany(pStrCompanyCode, ptype, stype) { // 부서가져오기, 사용자가져오기, 동기화 대상 삭제, 모두 초기화, 조직도 동기화
		$.ajax({
			type: "POST",
			data: {
				CompanyCode: pStrCompanyCode
			},
			url: "/covicore/admin/orgmanage/checkSyncCompany.do",
			async: false,
			success: function(data) {
				if (data.status != "FAIL") {
					if (data.list[0].OrgSyncType.toUpperCase() == "AUTO") {
						check_syncCompany = false;
						Common.Warning("<spring:message code='Cache.msg_Is_ExcelSyncCompany'/>"); //엑셀 동기화를 지원하는 계열사가 아닙니다.
					}
					else if (data.list[0].OrgSyncType.toUpperCase() == "MANUAL") {
						check_syncCompany = true;
						
						if (stype == "DATA") { // 데이터 가져오기
							showListImportedExcel(check_syncCompany,ptype);
						}
						else if (stype == "DELETE") { // 동기화 대상 삭제
							deleteTemp();
						}
						else if (stype == "RESET") { // 모두 초기화
							deleteAll();
						}
						else if (stype == "SYNC") { // 조직도 동기화
							syncExcelData();
						}
					}
				}
				else {
					Common.Warning(data.message);
				}
			},
			error: function(response, status, error) {
				CFN_ErrorAjax("/covicore/admin/orgmanage/checkSyncCompany.do", response, status, error);
			}
		});
	}
	
  	//엑셀 다운로드
	function excelDownload(type){	
		Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage'/>", "Confirmation Dialog", function(result){
       		if(result){
       			var headerName = getHeaderNameForExcel(type);
    			var sortKey = "";
    			if(type == "exdept") sortKey = "SortPath, GroupCode";
    			else if(type == "exuser") sortKey = "UserCode";
    			var	sortWay = "ASC";				  	
    			
    			location.href = "/covicore/admin/orgmanage/orglistexceldownload.do?sortKey=" + sortKey + "&sortDirection=" + sortWay + "&type=" + type + "&groupCode=" + $.urlParam("gr_code") + "&companyCode=" + companyCode + "&headerName=" + encodeURI(encodeURIComponent(headerName));
       		}
		});
	}

	//엑셀용 Grid 헤더정보 설정
	function getHeaderNameForExcel(type){
		var msgHeaderData;
		if(type == "exdept") {
			msgHeaderData = [
				{key:'deptGroupCode',  label:'GroupCode', width:'30', align:'center'},
				{key:'deptCompanyCode',  label:'CompanyCode', width:'30', align:'center'},
				{key:'deptMemberOf',  label:'MemberOf', width:'30', align:'center'},
				{key:'deptDisplayName',  label:'DisplayName', width:'30', align:'center'},
				{key:'deptMultiDisplayName',  label:'MultiDisplayName', width:'30', align:'center'},
				{key:'deptSortKey',  label:'SortKey', width:'30', align:'center'},
				{key:'deptIsUse', label:'IsUse', width:'30', align:'center'},
				{key:'deptIsHR', label:'IsHR',  width:'30', align:'center'},
				{key:'deptIsDisplay', label:'IsDisplay',   width:'30', align:'center'},
				{key:'deptIsMail', label:'IsMail',   width:'30', align:'center'},
				{key:'deptPrimaryMail', label:'PrimaryMail', width:'30', align:'center'},
				{key:'deptManagerCode', label:'ManagerCode', width:'30', align:'center'}
			];
		}
		else {
			msgHeaderData = [
				{key:'userUserCode',  label:'UserCode', width:'30', align:'center'},
				{key:'userCompanyCode',  label:'CompanyCode', width:'30', align:'center'},
				{key:'userDeptCode',  label:'DeptCode', width:'30', align:'center'},
				{key:'userLogonID',  label:'LogonID', width:'30', align:'center'},
				{key:'userLogonPW',  label:'LogonPW', width:'30', align:'center'},
				{key:'userEmpNo',  label:'EmpNo', width:'30', align:'center'},
				{key:'userDisplayName', label:'DisplayName', width:'30', align:'center'},
				{key:'userMultiDisplayName',  label:'MultiDisplayName', width:'30', align:'center'},
				{key:'userJobPositionCode',  label:'JobPositionCode', width:'30', align:'center'},
				{key:'userJobTitleCode',  label:'JobTitleCode', width:'30', align:'center'},
				{key:'userJobLevelCode',  label:'JobLevelCode', width:'30', align:'center'},
				{key:'userSortKey',  label:'SortKey', width:'30', align:'center'},
				{key:'userIsUse', label:'IsUse', width:'30', align:'center'},
				{key:'userIsHR', label:'IsHR',  width:'30', align:'center'},
				{key:'userIsDisplay', label:'IsDisplay',  width:'30', align:'center'},
				{key:'userUseMailConnect', label:'UseMailConnect',  width:'30', align:'center'},
				{key:'userEnterDate', label:'EnterDate',  width:'30', align:'center'},
				{key:'userRetireDate', label:'RetireDate',  width:'30', align:'center'},
				{key:'userBirthDiv', label:'BirthDiv',  width:'30', align:'center'},
				{key:'userBirthDate', label:'BirthDate',  width:'30', align:'center'},
				{key:'userPhotoPath', label:'PhotoPath',  width:'30', align:'center'},
				{key:'userMailAddress', label:'MailAddress', width:'30', align:'center'},
				{key:'userExternalMailAddress', label:'ExternalMailAddress',  width:'30', align:'center'},
				{key:'userChargeBusiness', label:'ChargeBusiness',  width:'30', align:'center'},
				{key:'userPhoneNumberInter', label:'PhoneNumberInter',  width:'30', align:'center'},
				{key:'userPhoneNumber', label:'PhoneNumber',  width:'30', align:'center'},
				{key:'userMobile', label:'Mobile',  width:'30', align:'center'},
				{key:'userFax', label:'Fax',  width:'30', align:'center'},
				{key:'userUseMessengerConnect', label:'UseMessengerConnect',  width:'30', align:'center'}
			];
		}
		var returnStr = "";
		
	   	for(var i=0;i<msgHeaderData.length; i++){
	   	   	if(msgHeaderData[i].label != 'chk'){
				returnStr += msgHeaderData[i].label + ";";
	   	   	}
		}
		
		return returnStr;
	}
	
	function syncSelectDomain() {
		var selDomainCode = $("#domainCodeSelectBox").val();
		Common.Progress("<spring:message code='Cache.msg_Processing'/>");
		$.post("/covicore/aclhelper/refreshSyncKeyAllByCode.do", { DomainCode: selDomainCode }, function(data) {
			Common.AlertClose();
		});
	}
	
	var changeAttachFile = function (ptype) {
		if(ptype == "dept") {
			if($("#importedFiledept").val() != "") {
				chkExtension(ptype);
			}
		} else {
			if($("#importedFileuser").val() != "") {
				chkExtension(ptype);
			}
		}
	}
	
	function chkExtension(ptype) {
		if(ptype == "dept") {
			var ext = $("#importedFiledept").val().slice($("#importedFiledept").val().indexOf(".") + 1).toLowerCase();
			if (ext != "csv" && ext != "xls" && ext != "xlsx" && ext != "txt") {
				Common.Warning("<spring:message code='Cache.msg_cannotLoadExtensionFile'/>"); //불러올 수 없는 확장자 파일입니다.
				if (_ie) { // ie
					$("#importedFiledept").replaceWith($("#importedFiledept").clone(true));
				} else { // 타브라우저
					$("#importedFiledept").val("");
				}
			}
		} else {
			var ext = $("#importedFileuser").val().slice($("#importedFileuser").val().indexOf(".") + 1).toLowerCase();
			if (ext != "csv" && ext != "xls" && ext != "xlsx" && ext != "txt") {
				Common.Warning("<spring:message code='Cache.msg_cannotLoadExtensionFile'/>"); //불러올 수 없는 확장자 파일입니다.
				if (_ie) { // ie
					$("#importedFileuser").replaceWith($("#importedFileuser").clone(true));
				} else { // 타브라우저
					$("#importedFileuser").val("");
				}
			}
		}
	}
	
	function showListImportedExcel(check_syncCompany, ptype) {
		if(check_syncCompany) {
			if(ptype == "dept") {
				if ($('#importedFiledept').val() == "" || $('#importedFiledept').val() == null) {
					Common.Warning("<spring:message code='Cache.msg_FileNotAdded'/>", ""); //파일이 추가되지 않았습니다.
					return false;
				}				
			}
			else {
				if ($('#importedFileuser').val() == "" || $('#importedFileuser').val() == null) {
					Common.Warning("<spring:message code='Cache.msg_FileNotAdded'/>", ""); //파일이 추가되지 않았습니다.
					return false;
				}
				else if($('#importedFileuser').val() != "" && $('#importedFileuser').val() != null && ($('#importedFiledept').val() == "" || $('#importedFiledept').val() == null)) {
					Common.Warning("<spring:message code='Cache.msg_DeptFileFirst'/>", ""); //부서 먼저 등록해주십시오.
					return false;
				}
			}
	
			var file = "";
			if(ptype == "dept") file = $('#importedFiledept');
			else file = $('#importedFileuser');
			
			var fileObj = file[0].files[0];
			var ext = file.val().split(".").pop().toLowerCase();
			var thtd = "";
			
			if (fileObj != undefined) {
				var reader = new FileReader();
				if (ext == "csv") {
					reader.onload = function(e) {
						var csvResult = e.target.result.split(/\r?\n|\r/);
						var arrIndex = new Array();
						var tempStr = "";
						for (var i = 0; i < csvResult.length; i++) {
							var strResult = csvResult[i].replaceAll("\"", "").replaceAll("\t", "").replaceAll(", ", ",").replaceAll(" ,", ",");
							if (i == 0) {
								arrIndex = setIndex(strResult);
							}
							var tempResult = strResult.split(',');
							for (var j = 0; j < tempResult.length; j++) {
								for (var k = 0; k < arrIndex.length; k++) {
									if (arrIndex[k] == j) {
										tempStr += tempResult[j] + "†";
									}
								}
							}
							tempStr = tempStr.slice(0, -1);
							tempStr += "§";
						}
						setGrid(tempStr,ptype);
					}
					reader.readAsText(fileObj, "EUC-KR");
					
				} else {
					var i = 1;
					j = 1;
					var Excel;
					var obj;
					var tempStr = "";
					Excel = new ActiveXObject("Excel.Application");
					Excel.Visible = false;
					do {
						do {
							if(ptype=="dept") obj = Excel.Workbooks.Open($('#importedFiledept').val()).ActiveSheet.Cells(i, j).Value;
							else obj = Excel.Workbooks.Open($('#importedFileuser').val()).ActiveSheet.Cells(i, j).Value;
							if (obj != undefined) {
								tempStr += obj + "†";
							}
							j++;
						} while (obj != null);
						i++;
						j = 1;
						tempStr = tempStr.slice(0, -1);
						tempStr += "§";
						if(ptype=="dept") obj = Excel.Workbooks.Open($('#importedFiledept').val()).ActiveSheet.Cells(i, j).Value;
						else obj = Excel.Workbooks.Open($('#importedFileuser').val()).ActiveSheet.Cells(i, j).Value;
					} while (obj != null);
					setGrid(tempStr, ptype);
				}
			}
		}
	}
	
	var keyValueArr = new Array();
	
	function setIndex(str) {
		//모든 따옴표 제거
		if (str[0] == '"')
			str = str.substring(1, str.length - 1);

		//마지막 문자가 따옴표이면 삭제
		if (str[str.length - 1] == '"')
			str = str.substring(0, str.length - 1);

		//","을 콤마로 변경
		//str = str.replaceAll('\",\"', ',').replaceAll(',\"', ',').replaceAll('\",', ',').replaceAll('\t', '').replaceAll(', ', '');
		var arrTemp = str.split(',');
		var _nIndexCnt = arrTemp.length;
		var returnArr = new Array();

		if (arrTemp[0].trim() == "GroupCode") {
			type = "CSV_dept";
		} else {
			type = "CSV_user";
		}

		for (var i = 0; i < arrTemp.length; i++) {
			if (type == "CSV_dept") {
				switch (arrTemp[i].trim()) {
				case "GroupCode":
					keyValueArr.push({'GroupCode' : i});
					returnArr.push(i);
					break;
				case "CompanyCode":
					keyValueArr.push({'CompanyCode' : i});
					returnArr.push(i);
					break;
				case "MemberOf":
					keyValueArr.push({'MemberOf' : i});
					returnArr.push(i);
					break;
				case "DisplayName":
					keyValueArr.push({'DisplayName' : i});
					returnArr.push(i);
					break;
				case "MultiDisplayName":
					keyValueArr.push({'MultiDisplayName' : i});
					returnArr.push(i);
					break;
				case "SortKey":
					keyValueArr.push({'SortKey' : i});
					returnArr.push(i);
					break;
				case "IsUse":
					keyValueArr.push({'IsUse' : i});
					returnArr.push(i);
					break;
				case "IsHR":
					keyValueArr.push({'IsHR' : i});
					returnArr.push(i);
					break;
				case "IsDisplay":
					keyValueArr.push({'IsDisplay' : i});
					returnArr.push(i);
					break;
				case "IsMail":
					keyValueArr.push({'IsMail' : i});
					returnArr.push(i);
					break;
				case "PrimaryMail":
					keyValueArr.push({'PrimaryMail' : i});
					returnArr.push(i);
					break;
				case "ManagerCode":
					keyValueArr.push({'ManagerCode' : i});
					returnArr.push(i);
					break;
				}
			}
			else {
				switch (arrTemp[i].trim()) {
				case "UserCode":
					keyValueArr.push({'UserCode' : i});
					returnArr.push(i);
					break;
				case "CompanyCode":
					keyValueArr.push({'CompanyCode' : i});
					returnArr.push(i);
					break;
				case "DeptCode":
					keyValueArr.push({'DeptCode' : i});
					returnArr.push(i);
					break;
				case "LogonID":
					keyValueArr.push({'LogonID' : i});
					returnArr.push(i);
					break;
				case "LogonPW":
					keyValueArr.push({'LogonPW' : i});
					returnArr.push(i);
					break;
				case "EmpNo":
					keyValueArr.push({'EmpNo' : i});
					returnArr.push(i);
					break;
				case "DisplayName":
					keyValueArr.push({'DisplayName' : i});
					returnArr.push(i);
					break;
				case "MultiDisplayName":
					keyValueArr.push({'MultiDisplayName' : i});
					returnArr.push(i);
					break;
				case "JobPositionCode":
					keyValueArr.push({'JobPositionCode' : i});
					returnArr.push(i);
					break;
				case "JobTitleCode":
					keyValueArr.push({'JobTitleCode' : i});
					returnArr.push(i);
					break;
				case "JobLevelCode":
					keyValueArr.push({'JobLevelCode' : i});
					returnArr.push(i);
					break;
				case "SortKey":
					keyValueArr.push({'SortKey' : i});
					returnArr.push(i);
					break;
				case "IsUse":
					keyValueArr.push({'IsUse' : i});
					returnArr.push(i);
					break;
				case "IsHR":
					keyValueArr.push({'IsHR' : i});
					returnArr.push(i);
					break;
				case "IsDisplay":
					keyValueArr.push({'IsDisplay' : i});
					returnArr.push(i);
					break;
				case "UseMailConnect":
					keyValueArr.push({'UseMailConnect' : i});
					returnArr.push(i);
					break;
				case "EnterDate":
					keyValueArr.push({'EnterDate' : i});
					returnArr.push(i);
					break;
				case "RetireDate":
					keyValueArr.push({'RetireDate' : i});
					returnArr.push(i);
					break;
				case "BirthDiv":
					keyValueArr.push({'BirthDiv' : i});
					returnArr.push(i);
					break;
				case "BirthDate":
					keyValueArr.push({'BirthDate' : i});
					returnArr.push(i);
					break;
				case "PhotoPath":
					keyValueArr.push({'PhotoPath' : i});
					returnArr.push(i);
					break;
				case "MailAddress":
					keyValueArr.push({'MailAddress' : i});
					returnArr.push(i);
					break;
				case "ExternalMailAddress":
					keyValueArr.push({'ExternalMailAddress' : i});
					returnArr.push(i);
					break;
				case "ChargeBusiness":
					keyValueArr.push({'ChargeBusiness' : i});
					returnArr.push(i);
					break;
				case "PhoneNumberInter":
					keyValueArr.push({'PhoneNumberInter' : i});
					returnArr.push(i);
					break;
				case "PhoneNumber":
					keyValueArr.push({'PhoneNumber' : i});
					returnArr.push(i);
					break;
				case "Mobile":
					keyValueArr.push({'Mobile' : i});
					returnArr.push(i);
					break;
				case "Fax":
					keyValueArr.push({'Fax' : i});
					returnArr.push(i);
					break;
				case "UseMessengerConnect":
					keyValueArr.push({'UseMessengerConnect' : i});
					returnArr.push(i);
					break;
				}
			}
		}

		return returnArr;
	}
	
	// insert to excel table
	function insertTempDeptData(object) {
		var surl = "/covicore/admin/orgmanage/getImportedOrgDeptList.do";
		if(Common.getGlobalProperties("isSaaS") == "Y") surl = "/covicore/admin/orgmanage/getImportedOrgDeptListSaaS.do";
			
		$.ajax({
			url: surl,
			data: {
				objectData: object,
				companyCode: companyCode
			},
			type: "POST",
			success: function(data) {
				if(data.status == "FAIL") {
					if(data.message.indexOf("|")) Common.Warning(data.message.split("|")[0] + " " + Common.getDic(data.message.split("|")[1]));
					else Common.Warning(Common.getDic(data.message));
				} else {
					setdeptGrid();
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax(surl, response, status, error);
			}
		});
	}
	
	function insertTempUserData(object) {
		var surl = "/covicore/admin/orgmanage/getImportedOrgUserList.do";
		if(Common.getGlobalProperties("isSaaS") == "Y") surl = "/covicore/admin/orgmanage/getImportedOrgUserListSaaS.do";
		
		$.ajax({
			url: surl,
			data: {
				objectData: object,
				companyCode: companyCode
			},
			type: "POST",
			success: function(data) {
				if(data.status == "FAIL") {
					if(data.message.indexOf("|")) Common.Warning(data.message.split("|")[0] + " " + Common.getDic(data.message.split("|")[1]));
					else Common.Warning(Common.getDic(data.message));
				}
				else {
					setuserGrid();
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax(surl, response, status, error);
			}
		});
	}
	
	//엑셀동기화
	function syncExcelData() {
		if(check_syncCompany) {
			Common.Confirm("<spring:message code='Cache.msg_154'/>", "Confirmation Dialog", function (result) { 
				if(result) {
					if(    ($('#importedFiledept').val() == "" || $('#importedFiledept').val() == null)
						|| ($('#importedFileuser').val() == "" || $('#importedFileuser').val() == null)) {
					
						Common.Warning("<spring:message code='Cache.msg_AddFileAll'/>", ""); //부서, 사용자 모두 파일을 추가해주세요.
						return false;
					} 
					else {
						$.ajax({
							url: "/covicore/admin/orgmanage/synchronizeByweb.do",
							data: {
								"IsSyncDB": "Y",
								"IsSyncIndi": "Y",
								"sChkBoxConfig": "chkDeptAdd;chkDeptMod;chkDeptDel;chkUserAdd;chkUserMod;chkUserDel;" // 동기화 페이지 체크박스 값
							},
							type: "POST",
							success: function(d) {
								Common.Inform(d.status, "Information Dialog", function(result) {
									Refresh();	
								});
							},
							error: function(response, status, error){
								CFN_ErrorAjax("/covicore/admin/orgmanage/synchronizeByweb.do", response, status, error);
							}
						});
					}
					
				}
			});
		}
	}
</script>
