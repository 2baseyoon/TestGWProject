<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"  %> 
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<div class="cRConTop titType"> 
	<h2 class="title"><spring:message code="Cache.CN_216"/></h2> <!-- 엑셀동기화 -->
</div>
<style>  
.underline{text-decoration:underline};
</style>
<div class="cRContBottom mScrollVH">
	<!-- 컨텐츠 시작 -->
	<div class="sadminContent">
		<!-- 상단 버튼 시작 -->
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a class="btnTypeDefault btnExcel" href="#"onclick="deptObj.excelDownload();" ><spring:message code="Cache.btn_ExcelDownloadDept"/></a>
				<a class="btnTypeDefault btnExcel" href="#"onclick="userObj.excelDownload();" ><spring:message code="Cache.btn_ExcelDownloadUser"/></a>
				<a class="btnTypeDefault" href="#" onclick="checkSyncCompany('','DELETE');"><spring:message code="Cache.btn_TempRefresh"/></a>
				<a class="btnTypeDefault" href="#" onclick="checkSyncCompany('','SYNC');"><spring:message code="Cache.lbl_OrgSync"/></a>
			</div>
			<div class="buttonStyleBoxRight">
				<button class="btnRefresh" type="button" href="#" onclick="refresh();"></button>
			</div>
		</div>
		<!-- 상단 버튼 끝 -->
		<!-- 상단 검색영역 시작 -->
		<div class="sadmin_searchBox">
			<div class="sadmin_search01">
				<strong class="sadmin_tit"><spring:message code="Cache.lbl_dept"/></strong>
				<a class="btnTypeDefault" href="#" onclick="deptObj.selectFile();"><spring:message code="Cache.lbl_SelectFile"/></a>
				<input id="txtDeptFileName"class="upload-name" value="" placeholder="<spring:message code='Cache.lbl_NotExistFile'/>" style="width:540px;" readonly="readonly">
				<a id="btnImportDept" 	class="btnTypeDefault" href="#" onclick="checkSyncCompany('Dept','DATA');"><spring:message code="Cache.btn_fileOpen"/></a>
				<a class="btnTypeDefault" href="#" onclick="checkSyncCompany('Dept','RESET');"><spring:message code="Cache.btn_AllRefresh"/></a>
				
				<input type="file" id="importedFileDept" accept=".xlsx, .xls" onchange="deptObj.changeAttachFile('dept')" style="display:none"><!-- accept=".csv, .xls, .xlsx, .txt"  -->
			</div>
			<div class="sadmin_search02">
				<div class="sadmin_sbox">
					<span class="sadmin_tit"><spring:message code="Cache.lbl_OrgSyncType"/></span>
					<select class="selectType02 w70p" id="selDeptSyncType" name="selDeptSyncType" onchange="deptObj.bindGrid();">
						<option value="" selected><spring:message code="Cache.lbl_Whole" /></option>
						<option value="INSERT"><spring:message code="Cache.lbl_Add" /></option>
						<option value="UPDATE"><spring:message code="Cache.lbl_Modify" /></option>
						<option value="DELETE"><spring:message code="Cache.lbl_delete" /></option>
					</select>
				</div>
				<div class="sadmin_sbox">
					<span class="sadmin_tit"><spring:message code="Cache.lbl_SearchCondition"/></span>
					<select class="selectType02" id="selSearchTypeDept" name="selSearchTypeDept">
						<option value="GroupCode" selected><spring:message code="Cache.lbl_DeptCode"/></option>
						<option value="DisplayName"><spring:message code="Cache.lbl_DeptName"/></option>
					</select>
					<input type="text" value="" placeholder="" id="txtSearchTextDept" onKeypress="if(event.keyCode==13) {deptObj.bindGrid(); return false;}">
					<a class="btnTypeDefault" href="#" onclick="deptObj.bindGrid();"><spring:message code="Cache.btn_search"/></a>
					<a class="btnTypeDefault ml10" href="#" onclick="deptObj.deleteGridData();"><spring:message code="Cache.btn_deleteDept"/></a>
				</div>
			</div>
		</div>
		<!-- 상단 검색영역 끝 -->
		<!-- 리스트:그리드 컨트롤 사용 영역입니다. 참고만 하세요 시작 -->
		<div class="tblList tblCont">
			<div id="orgDeptexcelgrid"></div>
		</div>
		<!-- 상단 검색영역 시작 -->
		<div class="sadmin_searchBox mt30">
			<div class="sadmin_search01">
				<strong class="sadmin_tit"><spring:message code="Cache.lbl_User"/></strong>
				<a class="btnTypeDefault" href="#" onclick="userObj.selectFile();"><spring:message code="Cache.lbl_SelectFile"/></a>
				<input id="txtUserFileName"class="upload-name" value="" placeholder="<spring:message code='Cache.lbl_NotExistFile'/>" style="width:540px;" readonly="readonly">
				<a class="btnTypeDefault" href="#" onclick="checkSyncCompany('User','DATA');"><spring:message code="Cache.btn_fileOpen"/></a>
				<a class="btnTypeDefault" href="#" onclick="checkSyncCompany('User','RESET');"><spring:message code="Cache.btn_AllRefresh"/></a>

				<input type="file" id="importedFileUser" accept=".xlsx, .xls" onchange="userObj.changeAttachFile('user')" style="display:none"><!-- accept=".csv, .xls, .xlsx, .txt"  -->
			</div>
			<div class="sadmin_search02">
				<div class="sadmin_sbox">
					<span class="sadmin_tit"><spring:message code="Cache.lbl_OrgSyncType"/></span>
					<select class="selectType02 w70p" id="selUserSyncType" name="selUserSyncType" onchange="userObj.bindGrid();">
						<option value="" selected><spring:message code="Cache.lbl_Whole" /></option>
						<option value="INSERT"><spring:message code="Cache.lbl_Add" /></option>
						<option value="UPDATE"><spring:message code="Cache.lbl_Modify" /></option>
						<option value="DELETE"><spring:message code="Cache.lbl_delete" /></option>
					</select>
				</div>
				<div class="sadmin_sbox">
					<span class="sadmin_tit"><spring:message code="Cache.lbl_SearchCondition"/></span>
					<select class="selectType02" id="selSearchTypeUser" name="selSearchTypeUser">
						<option value="UserCode" selected><spring:message code="Cache.lbl_UserID"/></option>
						<option value="DisplayName"><spring:message code="Cache.lbl_USER_NAME_01"/></option>
					</select>
					<input type="text" value="" placeholder="" id="txtSearchTextUser" onKeypress="if(event.keyCode==13) {userObj.bindGrid(); return false;}">
					<a class="btnTypeDefault" href="#" onclick="userObj.bindGrid();"><spring:message code="Cache.btn_search"/></a>
					<a class="btnTypeDefault ml10" href="#" onclick="userObj.deleteGridData();"><spring:message code="Cache.btn_deleteUser"/></a>
				</div>
			</div>
		</div>
		<!-- 상단 검색영역 끝 -->
		<!-- 리스트:그리드 컨트롤 사용 영역입니다. 참고만 하세요 시작 -->
		<div class="tblList tblCont">
			<div id="orgUserexcelgrid"></div>
		</div>
	<!-- 컨텐츠 끝 -->
	</div>
</div>
<script type="text/javascript">
	//엑셀동기화 대상 계열사 확인
	var _check_syncCompany = false;
	var _domainId =confMenu.domainId;
	var _companyCode = confMenu.domainCode;
	var deptObj;
	var userObj;
	var _commObj = {
		type				:	''//Dept / User
	,	grid				:	''
	,	gridHeader			:	''
	,	excelHeader			:	''
	,	init				:	function(type){
									var me = this;
									me.type = type;
									me.grid = new coviGrid();
									me.setHeaderData();
									me.setGrid();
								}
	,	selectFile			:	function(){
									var me = this;
									$("#importedFile"+me.type).val('');
									$("#txt"+me.type+"FileName").val('');
									$("#importedFile"+me.type).click();
								}
	,	changeAttachFile	:	function (ptype) {
									var me = this;
									if($("#importedFile"+me.type).val() != "") 
										me.chkExtension();
								}
	,	chkExtension 		:	function () {
									var me = this;
									var itemID = "#importedFile"+me.type;
									var ext = $(itemID).val().slice($(itemID).val().indexOf(".") + 1).toLowerCase();
									if (ext != "xlsx" &&ext != "xls" ) {
										Common.Warning("<spring:message code='Cache.msg_cannotLoadExtensionFile'/>"); //불러올 수 없는 확장자 파일입니다.
										if (_ie) { // ie
											$(itemID).replaceWith($(itemID).clone(true));
										} else { // 타브라우저
											$(itemID).val("");
										}
									}
									if($(itemID)[0].files.length>0)
										$("#txt"+me.type+"FileName").val($(itemID)[0].files[0].name);
									else
										$("#txt"+me.type+"FileName").val('');
									
								}
	,	setHeaderData		:	function(){
									var me = this;
									if(me.type=='Dept')
									{
										me.gridHeader	=	[																	
																{key:'deptchk'                   ,	label:'chk', width:'50', align:'center', formatter:'checkbox'}	
															,	{key:'deptSyncType'              ,	label:'<spring:message code="Cache.lbl_OrgSyncType"/>'                	, width:'100', align:'center'}
																																													 
															,	{key:'deptGroupCode'             ,	label:'<spring:message code="Cache.lbl_DeptCode"/>'                     , width:'100', align:'center'}
															,	{key:'deptCompanyCode'           ,	label:'<spring:message code="Cache.lbl_apv_entcode"/>'                  , width:'100', align:'center'}
															,	{key:'deptMemberOf'              ,	label:'<spring:message code="Cache.lbl_apv_UpperDeptCode"/>'            , width:'100', align:'center'}
															,	{key:'deptDisplayName'           ,	label:'<spring:message code="Cache.lbl_DeptName"/>'                     , width:'100', align:'center'}
															,	{key:'deptMultiDisplayName'      ,	label:'<spring:message code="Cache.lbl_MultiLang"/>'                    , width:'100', align:'center'}
															,	{key:'deptSortKey'               ,	label:'<spring:message code="Cache.lbl_PriorityOrder"/>'                , width:'100', align:'center'}
															,	{key:'deptIsUse'                 ,	label:'<spring:message code="Cache.lbl_IsUse"/>'                        , width:'100', align:'center'}
															,	{key:'deptIsHR'                  ,	label:'<spring:message code="Cache.lbl_IsHR"/>'							, width:'100', align:'center'}
															,	{key:'deptIsDisplay'             ,	label:'<spring:message code="Cache.lbl_IsDisplay"/>'					, width:'100', align:'center'}
															,	{key:'deptIsMail'                ,	label:'<spring:message code="Cache.lbl_IsMail"/>'						, width:'100', align:'center'}
															,	{key:'deptPrimaryMail'           ,	label:'<spring:message code="Cache.lbl_Mail"/>'                         , width:'100', align:'center'}
															,	{key:'deptManagerCode'           ,	label:'<spring:message code="Cache.lbl_admin"/>'                        , width:'100', align:'center'}


															];
										me.excelHeader	=	[
																{key:'GroupCode'        ,label:'<spring:message code="Cache.lbl_DeptCode"/>'}      
															,	{key:'CompanyCode'      ,label:'<spring:message code="Cache.lbl_apv_entcode"/>'}      
															,	{key:'MemberOf'         ,label:'<spring:message code="Cache.lbl_apv_UpperDeptCode"/>'}      
															,	{key:'DisplayName'      ,label:'<spring:message code="Cache.lbl_DeptName"/>'}      
															,	{key:'MultiDisplayName' ,label:'<spring:message code="Cache.lbl_MultiLang"/>'}      
															,	{key:'SortKey'          ,label:'<spring:message code="Cache.lbl_PriorityOrder"/>'}      
															,	{key:'IsUse'            ,label:'<spring:message code="Cache.lbl_IsUse"/>'}      
															,	{key:'IsHR'             ,label:'<spring:message code="Cache.lbl_IsHR"/>'}      
															,	{key:'IsDisplay'        ,label:'<spring:message code="Cache.lbl_IsDisplay"/>'}      
															,	{key:'IsMail'           ,label:'<spring:message code="Cache.lbl_IsMail"/>'}      
															,	{key:'PrimaryMail'      ,label:'<spring:message code="Cache.lbl_Mail"/>'}      
															,	{key:'ManagerCode'      ,label:'<spring:message code="Cache.lbl_admin"/>'}   


															]
									}
									else if(me.type=='User')
									{ 
										me.gridHeader	=	[	
																{key:'userchk'					,label:'chk', width:'50', align:'center', formatter:'checkbox'}
															,	{key:'userSyncType'				,label:'<spring:message code="Cache.lbl_OrgSyncType"/>'			, width:'100', align:'center'}
															,	{key:'userLicSeq'				,label:'<spring:message code="Cache.lbl_license"/>'             , width:'100', align:'center'}
															,	{key:'userUserCode'             ,label:'<spring:message code="Cache.lbl_User_Id"/>'             , width:'100', align:'center'}
															,	{key:'userCompanyCode'          ,label:'<spring:message code="Cache.lbl_apv_entcode"/>'         , width:'100', align:'center'}
															,	{key:'userDeptCode'             ,label:'<spring:message code="Cache.lbl_dept"/>'                , width:'100', align:'center'}
															,	{key:'userLogonID'              ,label:'<spring:message code="Cache.LogonID"/>'                 , width:'100', align:'center'}
															,	{key:'userLogonPW'              ,label:'<spring:message code="Cache.lbl_Password"/>'            , width:'100', align:'center'}
															,	{key:'userEmpNo'                ,label:'<spring:message code="Cache.lblUserCode"/>'             , width:'100', align:'center'}
															,	{key:'userDisplayName'          ,label:'<spring:message code="Cache.lbl_User"/>'                , width:'100', align:'center'}
															,	{key:'userMultiDisplayName'     ,label:'<spring:message code="Cache.lbl_MultiLang"/>'           , width:'100', align:'center'}
															,	{key:'userJobPositionCode'      ,label:'<spring:message code="Cache.lbl_JobPosition"/>'         , width:'100', align:'center'}
															,	{key:'userJobTitleCode'         ,label:'<spring:message code="Cache.lbl_JobTitle"/>'            , width:'100', align:'center'}
															,	{key:'userJobLevelCode'         ,label:'<spring:message code="Cache.lbl_JobLevel"/>'            , width:'100', align:'center'}
															,	{key:'userSortKey'              ,label:'<spring:message code="Cache.lbl_PriorityOrder"/>'       , width:'100', align:'center'}
															,	{key:'userIsUse'                ,label:'<spring:message code="Cache.lbl_IsUse"/>'               , width:'100', align:'center'}
															,	{key:'userIsHR'                 ,label:'<spring:message code="Cache.lbl_IsHR"/>'                , width:'100', align:'center'}
															,	{key:'userIsDisplay'            ,label:'<spring:message code="Cache.lbl_SetDisplay"/>'          , width:'100', align:'center'}
															,	{key:'userUseMailConnect'       ,label:'<spring:message code="Cache.lbl_IsMail"/>'              , width:'100', align:'center'}
															,	{key:'userEnterDate'            ,label:'<spring:message code="Cache.lbl_EnterDate"/>'           , width:'100', align:'center'}
															,	{key:'userRetireDate'           ,label:'<spring:message code="Cache.lbl_RetireDate"/>'          , width:'100', align:'center'}
															,	{key:'userBirthDiv'             ,label:'<spring:message code="Cache.lbl_SolarLunar2"/>'         , width:'100', align:'center'}
															,	{key:'userBirthDate'            ,label:'<spring:message code="Cache.lbl_SmartDateofBirth"/>'    , width:'100', align:'center'}
															,	{key:'userPhotoPath'            ,label:'<spring:message code="Cache.lbl_UserProfile"/>'         , width:'100', align:'center'}
															,	{key:'userMailAddress'          ,label:'<spring:message code="Cache.lbl_Mail"/>'                , width:'100', align:'center'}
															,	{key:'userExternalMailAddress'  ,label:'<spring:message code="Cache.lbl_extmail"/>'             , width:'100', align:'center'}
															,	{key:'userChargeBusiness'       ,label:'<spring:message code="Cache.lbl_Role"/>'                , width:'100', align:'center'}
															,	{key:'userPhoneNumberInter'     ,label:'<spring:message code="Cache.lbl_MyInfo_13"/>'           , width:'100', align:'center'}
															,	{key:'userPhoneNumber'          ,label:'<spring:message code="Cache.lbl_PhoneNum"/>'            , width:'100', align:'center'}
															,	{key:'userMobile'               ,label:'<spring:message code="Cache.lbl_MobilePhone"/>'         , width:'100', align:'center'}
															,	{key:'userFax'                  ,label:'<spring:message code="Cache.lbl_Office_Fax"/>'          , width:'100', align:'center'}
															,	{key:'useMessengerConnect'  	,label:'<spring:message code="Cache.lbl_IsMSG"/>'               , width:'100', align:'center'}
															];
										me.excelHeader	=	[
																{key:'LicSeq'				,label:'<spring:message code="Cache.lbl_license"/>'}
															,	{key:'UserCode'             ,label:'<spring:message code="Cache.lbl_User_Id"/>'}
															,	{key:'CompanyCode'          ,label:'<spring:message code="Cache.lbl_apv_entcode"/>'}
															,	{key:'DeptCode'             ,label:'<spring:message code="Cache.lbl_dept"/>'}
															,	{key:'LogonID'              ,label:'<spring:message code="Cache.LogonID"/>'}
															,	{key:'LogonPW'              ,label:'<spring:message code="Cache.lbl_Password"/>'}
															,	{key:'EmpNo'                ,label:'<spring:message code="Cache.lblUserCode"/>'}
															,	{key:'DisplayName'          ,label:'<spring:message code="Cache.lbl_User"/>'}
															,	{key:'MultiDisplayName'     ,label:'<spring:message code="Cache.lbl_MultiLang"/>'}
															,	{key:'JobPositionCode'      ,label:'<spring:message code="Cache.lbl_JobPosition"/>'}
															,	{key:'JobTitleCode'         ,label:'<spring:message code="Cache.lbl_JobTitle"/>'}
															,	{key:'JobLevelCode'         ,label:'<spring:message code="Cache.lbl_JobLevel"/>'}
															,	{key:'SortKey'              ,label:'<spring:message code="Cache.lbl_PriorityOrder"/>'}
															,	{key:'IsUse'                ,label:'<spring:message code="Cache.lbl_IsUse"/>'}
															,	{key:'IsHR'                 ,label:'<spring:message code="Cache.lbl_IsHR"/>'}
															,	{key:'IsDisplay'            ,label:'<spring:message code="Cache.lbl_SetDisplay"/>'}
															,	{key:'UseMailConnect'       ,label:'<spring:message code="Cache.lbl_IsMail"/>'}
															,	{key:'EnterDate'            ,label:'<spring:message code="Cache.lbl_EnterDate"/>'}
															,	{key:'RetireDate'           ,label:'<spring:message code="Cache.lbl_RetireDate"/>'}
															,	{key:'BirthDiv'             ,label:'<spring:message code="Cache.lbl_SolarLunar2"/>'}
															,	{key:'BirthDate'            ,label:'<spring:message code="Cache.lbl_SmartDateofBirth"/>'}
															,	{key:'PhotoPath'            ,label:'<spring:message code="Cache.lbl_UserProfile"/>'}
															,	{key:'MailAddress'          ,label:'<spring:message code="Cache.lbl_Mail"/>'}
															,	{key:'ExternalMailAddress'  ,label:'<spring:message code="Cache.lbl_extmail"/>'}
															,	{key:'ChargeBusiness'       ,label:'<spring:message code="Cache.lbl_Role"/>'}
															,	{key:'PhoneNumberInter'     ,label:'<spring:message code="Cache.lbl_MyInfo_13"/>'}
															,	{key:'PhoneNumber'          ,label:'<spring:message code="Cache.lbl_PhoneNum"/>'}
															,	{key:'Mobile'               ,label:'<spring:message code="Cache.lbl_MobilePhone"/>'}
															,	{key:'Fax'                  ,label:'<spring:message code="Cache.lbl_Office_Fax"/>'}
															,	{key:'UseMessengerConnect'  ,label:'<spring:message code="Cache.lbl_IsMSG"/>'}
												
															];
									}
								}
	,	setGrid				:	function () {
									var me = this;
									me.grid.setGridHeader(me.gridHeader);
									me.setGridConfig();
									me.bindGrid();
								}
	,	setGridConfig		:	function () {
									var me = this;
									me.grid.setGridConfig({
										targetID: "org"+me.type+"excelgrid",
										height: "auto",
										page: { pageNo: 1, pageSize: 5 },
										paging: true,
										colHead: {},
										body: {},
										fitToWidth:false,
										xscroll:true,
									});
								}
	,	bindGrid			:	function () {
									var me = this;
									var url= "/covicore/manage/conf/getExcelTempDeptList.do";
									var sortBy= me.grid.getSortParam();
									var params = {
													"companyCode": _companyCode,
													"sortBy": sortBy,
													"syncType": $("#selDeptSyncType").val(),
													"searchType": $("#selSearchTypeDept").val(),
													"searchText": $("#txtSearchTextDept").val()
												};
									if(me.type=='User'){
										url = "/covicore/manage/conf/getExcelTempUserList.do";
										params = {
													"companyCode": _companyCode,
													"sortBy": sortBy,
													"syncType": $("#selUserSyncType").val(),
													"searchType": $("#selSearchTypeUser").val(),
													"searchText": $("#txtSearchTextUser").val()
												};
									}
									me.grid.bindGrid({
										ajaxUrl: url,
										ajaxPars: params
									});
								}
	,	setGridTempData		:	function (object) {
									var me = this;
									me.insertTempData(object);
								}
	,	deleteGridData		:	function () {
									var me = this;
									var deleteObject = me.grid.getCheckedList(0);
									var uniqueKey = 'deptGroupCode';
									var ajaxUrl = "/covicore/manage/conf/deleteSelectDept.do";
									if(me.type=='User')
									{
										uniqueKey = 'userUserCode';
										ajaxUrl = "/covicore/manage/conf/deleteSelectUser.do";
									}
									if(deleteObject.length == 0 || deleteObject == null){
										Common.Inform("<spring:message code='Cache.msg_CheckDeleteObject'/>");
										return;
									}
									
									Common.Confirm("<spring:message code='Cache.msg_152'/>", "Confirmation Dialog", function (result) {
										if(result) {
											var deleteSeq = "";
											
											for(var i=0; i < deleteObject.length; i++){
												if(i==0){
													deleteSeq = deleteObject[i][uniqueKey];
												}else{
													deleteSeq = deleteSeq + "," + deleteObject[i][uniqueKey];
												}
											}
											
											$.ajax({
												type: "POST",
												data: {
													"deleteData": deleteSeq
												},
												url: ajaxUrl,
												success: function (data) {
													if(data.status == "FAIL") {
														Common.Warning(data.message);
													}
													else {
														Common.Inform("<spring:message code='Cache.msg_138'/>", "Information Dialog", function(result) {
															if(result) {
																me.grid.reloadList();
															}
														});
													}
												},
												error: function(response, status, error){
													CFN_ErrorAjax(ajaxUrl, response, status, error);
												}
											});
										}
									});
									
								}
	,	insertTempData		:	function (object) {
									var me = this;
									var surl = "/covicore/manage/conf/selectImportedOrgDeptList.do";
									if(me.type=='User'){
										surl = "/covicore/manage/conf/selectImportedOrgUserList.do";
									}

									Common.Loading()
									$.ajax({
										url: surl,
										data: {
											objectData: object,
											DomainID: _domainId
										},
										type: "POST",
										success: function(data) {
											if(data.status == "FAIL") {
												if(data.message.indexOf("|")>-1) Common.Warning(data.message.split("|")[0] + " " + Common.getDic(data.message.split("|")[1]));
												else Common.Warning(Common.getDic(data.message));
											} else {
												me.setGrid();
											}
											Common.AlertClose();
										},
										error: function(response, status, error){
											CFN_ErrorAjax(surl, response, status, error);
											Common.AlertClose();
										}
									});
								}

	,	excelDownload		:	function () {
									var me = this;
									Common.Confirm('<spring:message code="Cache.msg_ExcelDownMessage"/>', 'Confirmation Dialog', function (result) {  
										if (result) {
											var headerName = me.getHeaderNameForExcel();
											var	sortKey = "SortKey";
											var	sortWay = "ASC";				  	
											
											location.href = "/covicore/manage/conf/groupExcelDownload.do?sortColumn=" + sortKey 
											+ "&sortDirection=" + sortWay 
											+ "&groupType=" + 'ex'+me.type
											+ "&domainId=" + _domainId 
											+ "&headerName=" + encodeURI(encodeURIComponent(headerName.returnDicStr)) 
											+ "&headerKey=" + encodeURI(encodeURIComponent(headerName.returnKeyStr)) 
										}
									});
								}

	,	getHeaderNameForExcel:	function(){
									var me = this;
									var returnKeyStr = "";
									var returnDicStr = "";
		
									for(var i=0;i<me.excelHeader.length; i++){
										returnKeyStr += me.excelHeader[i].key + ",";
										returnDicStr += me.excelHeader[i].label + ";";
									}
									
									return {returnKeyStr,returnDicStr};
								}
	
	}
	  
	
	$(document).ready(function () {
		checkSyncCompany();
		deptObj = Object.create(_commObj)
		userObj = Object.create(_commObj)
		deptObj.init('Dept')
		userObj.init('User');
	});
	
	function refresh() {
		deptObj.grid.reloadList();
		userObj.grid.reloadList();
	}
	 
	//TODO
	function deleteTemp() {
		if(_check_syncCompany){
			Common.Confirm("<spring:message code='Cache.msg_DoyouInit'/>", "Confirmation Dialog", function (result) { // 동기화 대상을 삭제하시겠습니까?
				if(result) {
					$.ajax({
						type: "POST",
						url: "/covicore/manage/conf/deleteTemp.do",
						success: function (data) {
							if(data.status == "FAIL") {
								Common.Warning(data.message);
							}
							else {
								Common.Inform("<spring:message code='Cache.msg_138'/>", "Information Dialog", function(result) {
									if(result) {
										deptObj.grid.reloadList();
										userObj.grid.reloadList();
									}
								});
							}
						},
						error: function(response, status, error){
							CFN_ErrorAjax("/covicore/manage/conf/deleteTemp.do", response, status, error);
						}
					});
				}
	
			});
		}
	}
	
	//TODO
	function deleteAll(ptype) {
		if(_check_syncCompany) {
			Common.Confirm("<spring:message code='Cache.msg_DoyouInit'/>", "Confirmation Dialog", function (result) { // 초기화하시겠습니까?
				if(result) {
					$.ajax({
						type: "POST",
						data: {
							"DomainID" 	: _domainId
						,	"Type"		: ptype
						},
						url: "/covicore/manage/conf/deleteAll.do",
						success: function (data) {
							if(data.status == "FAIL") {
								Common.Warning(data.message);
							}
							else {
								Common.Inform("<spring:message code='Cache.msg_138'/>", "Information Dialog", function(result) {
									if(result) {
										if(ptype=='Dept')
											deptObj.grid.reloadList();
										else
											userObj.grid.reloadList();
									}
								});
							}
						},
						error: function(response, status, error){
							CFN_ErrorAjax("/covicore/manage/conf/deleteAll.do", response, status, error);
						}
					});
				}
			});
		}
	}
	
	
	function checkSyncCompany(ptype, stype) { // 부서가져오기, 사용자가져오기, 동기화 대상 삭제, 모두 초기화, 조직도 동기화
		$.ajax({
			type: "POST",
			data: {
				DomainID: _domainId
			},
			url: "/covicore/manage/conf/checkSyncCompany.do",
			async: false,
			success: function(data) {
				if (data.status != "FAIL") {
					if (data.list[0].OrgSyncType.toUpperCase() == "AUTO") {
						_check_syncCompany = false;
						Common.Warning("<spring:message code='Cache.msg_Is_ExcelSyncCompany'/>"); //엑셀 동기화를 지원하는 계열사가 아닙니다.
					}
					else if (data.list[0].OrgSyncType.toUpperCase() == "MANUAL") {
						_check_syncCompany = true;
						
						if (stype == "DATA") { // 데이터 가져오기
							showListImportedExcel(ptype);
						}
						else if (stype == "DELETE") { // 동기화 대상 삭제
							deleteTemp();
						}
						else if (stype == "RESET") { // 모두 초기화
							deleteAll(ptype);
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
				CFN_ErrorAjax("/covicore/manage/conf/checkSyncCompany.do", response, status, error);
			}
		});
	}
	
  	
	 
	function showListImportedExcel(ptype) {
		var obj = userObj;
		var _url = '/covicore/manage/conf/uploadUserExcelSyncData.do';
		var idFileInput = '#importedFileUser';
		if(ptype == "Dept")
		{
			obj = deptObj
			idFileInput = '#importedFileDept';
			_url = '/covicore/manage/conf/uploadDeptExcelSyncData.do';
		}
		if(_check_syncCompany) 
		{
			if(ptype == "Dept") {
				if ($(idFileInput).val() == "" || $(idFileInput).val() == null) {
					Common.Warning("<spring:message code='Cache.msg_FileNotAdded'/>", ""); //파일이 추가되지 않았습니다.
					return false;
				}				
			}
			else {
				if ($(idFileInput).val() == "" || $(idFileInput).val() == null) {
					Common.Warning("<spring:message code='Cache.msg_FileNotAdded'/>", ""); //파일이 추가되지 않았습니다.
					return false;
				}
				else if($('#importedFileDept').val() == "" || $('#importedFileDept').val() == null) {
					Common.Warning("<spring:message code='Cache.msg_DeptFileFirst'/>", ""); //부서 먼저 등록해주십시오.
					return false;
				}
			}
			var file = $(idFileInput);
			var ext = file.val().split(".").pop().toLowerCase();
			if (ext != "xlsx"&&ext != "xls") 
			{
				Common.Warning("<spring:message code='Cache.msg_uploadOnlyxlsx'/>", "");
				return;
			}
			var formData = new FormData();
			formData.append("uploadfile",file[0].files[0]);
			formData.append("DomainID",_domainId);
			formData.append("CompanyCode",_companyCode);
			Common.Loading()
			$.ajax({
				url: _url,
				processData: false,
				contentType: false,
				data: formData,
				type: 'POST',
				success: function(result) { 
					Common.AlertClose();
					if(result.status== "FAIL") {
						Common.Warning(result.message);
					} 
					else if(result.status== "SUCCESS") {
						obj.setGrid();
						
					}
				},error:function(error){
					Common.AlertClose();
					Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
				}
			});
			
			//var file = "";
			//if(ptype == "Dept") file = $(idFileInput);
			//else file = $(idFileInput);
			//
			//var fileObj = file[0].files[0];
			//var ext = file.val().split(".").pop().toLowerCase();
			//var thtd = "";
			//
			//if (fileObj != undefined) {
			//	var reader = new FileReader();
			//	if (ext == "csv") {
			//		reader.onload = function(e) {
			//			var csvResult = e.target.result.split(/\r?\n|\r/);
			//			var arrIndex = new Array();
			//			var tempStr = "";
			//			for (var i = 0; i < csvResult.length; i++) {
			//				var strResult = csvResult[i].replaceAll("\"", "").replaceAll("\t", "").replaceAll(", ", ",").replaceAll(" ,", ",");
			//				if (i == 0) {
			//					arrIndex = setIndex(strResult);
			//				}
			//				var tempResult = strResult.split(',');
			//				for (var j = 0; j < tempResult.length; j++) {
			//					for (var k = 0; k < arrIndex.length; k++) {
			//						if (arrIndex[k] == j) {
			//							tempStr += tempResult[j] + "†";
			//						}
			//					}
			//				}
			//				tempStr = tempStr.slice(0, -1);
			//				tempStr += "§";
			//			}
			//			obj.setGridTempData(tempStr);
			//		}
			//		reader.readAsText(fileObj, "EUC-KR");
			//		
			//	}
			//}
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
				case "LicSeq":
					keyValueArr.push({'LicSeq' : i});
					returnArr.push(i);
					break;
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
	 
	
	//엑셀동기화
	function syncExcelData() {
		if(_check_syncCompany) { 
			Common.Confirm("<spring:message code='Cache.msg_154'/>", "Confirmation Dialog", function (result) { 
				if(result) {
					$.ajax({
						url:"/covicore/admin/orgmanage/synchronizeByweb.do",
						data: {
							"IsSyncDB": "Y",
							"IsSyncIndi": "Y",
							"sChkBoxConfig": "chkDeptAdd;chkDeptMod;chkDeptDel;chkUserAdd;chkUserMod;chkUserDel;" // 동기화 페이지 체크박스 값
						},
						type: "POST",
						success: function(d) {
							Common.Inform(d.status);
							refresh();
						},
						error: function(response, status, error){
							CFN_ErrorAjax("/covicore/admin/orgmanage/synchronizeByweb.do", response, status, error);
						}
					});
				}
			});
		}
	}
</script>