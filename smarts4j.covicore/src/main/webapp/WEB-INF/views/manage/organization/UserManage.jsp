<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<style>
	.underline{text-decoration:underline}
	.tblList .AXGrid .AXgridScrollBody{overflow:hidden !important;}
</style>

<div class="cRConTop titType"> 
	<h2 class="title"><spring:message code="Cache.lbl_UserManage"/></h2>	<!-- 사용자관리 -->
	<div class="searchBox02">
		<span>
			<input type="text" class="sm" id="searchInput" onkeypress="if (event.keyCode==13){ $('#simpleSearchBtn').click(); return false;}">
			<button id="simpleSearchBtn" type="button" onclick="pageObj.searchUserListKeyword(this);"class="btnSearchType01"><spring:message code='Cache.btn_search' /></button>
		</span>
		<a id="detailSchBtn" onclick="DetailDisplay(this);" class="btnDetails"><spring:message code='Cache.lbl_detail'/></a> <!-- 상세 -->
	</div> 
</div>	
<div class="cRContBottom mScrollVH"> 
	<div id="DetailSearch" class="inPerView type02">
		<div> 
			<div class="selectCalView">
				<select id="selDetailSearchType" class="selectType02">
					<option value="USER_NAME"><spring:message code="Cache.lbl_USER_NAME_01"/></option>
					<option value="USER_CODE"><spring:message code="Cache.lbl_apv_user_code"/></option>
					<option value="JOBPOSITION_NAME"><spring:message code="Cache.lbl_JobPositionName"/></option>
					<option value="JOBTITLE_NAME"><spring:message code="Cache.lbl_JobTitleName"/></option>
					<option value="JOBLEVEL_NAME"><spring:message code="Cache.lbl_JobLevelName"/></option>
				</select>
				<input type="text" id="txtDetailSearchText" style="width: 215px;" onkeypress="if (event.keyCode==13){ pageObj.searchUserListKeyword(this); return false;}" >
			</div>
			<a href="#" class="btnTypeDefault btnSearchBlue nonHover" onclick="pageObj.searchUserListKeyword(this);" ><spring:message code="Cache.btn_search"/></a>
		</div>
	</div>
	<form>
		<div class="sadminTreeContent">
			<div class="AXTreeWrap">
				<div class="searchBox02">
					<span>
						<input type="text" id="treeSearchText" onkeypress="if (event.keyCode==13){ pageObj.searchDeptTreeKeyword(); return false;}">
						<button type="button" class="btnSearchType01" id="treeSearchBtn"onclick="pageObj.searchDeptTreeKeyword();"><spring:message code='Cache.btn_search' /></button> <!-- 검색 -->
					</span>
				</div>
				<div id="orgDeptTree" class="tblList tblCont" style="width:300px;"></div>
			</div>
			<div>
				<div class="sadminContent">	
					<div class="sadminMTopCont">
						<div class="pagingType02 buttonStyleBoxLeft"> 
							<a class="btnTypeDefault btnPlusAdd" 	id="btnAdd"		onclick="pageObj.addOrgUser();"><spring:message code="Cache.btn_Add"/></a><!-- 추가 -->
							<a class="btnTypeDefault btnSaRemove" 	id="btnDel"		onclick="pageObj.deleteOrgUser();"><spring:message code="Cache.btn_Retire"/></a><!-- 퇴사 -->
							<a class="btnTypeDefault" 								onclick="pageObj.moveDeptOrgUser();"><spring:message code="Cache.btn_MovUser"/></a><!-- 사용자 이동 -->
							<a class="btnTypeDefault btnExcel" 						onclick="pageObj.excelDownload(false);"><spring:message code="Cache.btn_SaveToExcel"/></a><!-- 엑셀저장 -->
							<a class="btnTypeDefault btnExcel" 						onclick="pageObj.excelDownload(true);"><spring:message code="Cache.btn_SaveToExcelWithSub"/></a><!-- 하위부서 포함 엑셀저장 -->
							<a class="btnTypeDefault" 								onclick="syncSelectDomain();"><spring:message code="Cache.btn_CacheApply"/></a><!-- 캐시적용 -->
						
						</div>
						<div class="buttonStyleBoxRight">
							<select id="selectPageSize" class="selectType02 listCount" onchange="pageObj.changePageSize(this);">
								<option value="10">10</option>
								<option value="20">20</option>
								<option value="30">30</option>
							</select>
							<button id="folderRefresh" class="btnRefresh" type="button" onclick="pageObj.searchList()"></button>
						</div>
					</div>
					<div id="orgUserGrid" class="tblList tblCont"></div>
				</div>
			</div>
		</div>
	</form>
</div>
<script type="text/javascript"> 
	var pageObj;
	var _group_type = "Dept";
	var _domainId =confMenu.domainId;
	var _domainCode = confMenu.domainCode;
	var _deptSearchKeyword = '';
	
	var confManage = {
			isMailDisplay 		:	true
		,	gridDept			:	''
		,	gridUser			:	''
		,	gr_code				:	''
		,	group_type 			: 	''
		,	domainId 			:	''
		,	domainCode			:	''
		,	deptHeaderData		:	''
		,	userHeaderData		:	''
		,	pageObjName			:	''
		,	userSearchObj		:	{
										searchType 	: ''
									,	searchText 	: ''
									,	groupCode 	: ''
									}
		,	userSearchObjClear	:	function(){
										var me = this;
										me.userSearchObj = {
																searchType 	: ''
															,	searchText 	: ''
															,	groupCode 	: ''
																
															}
									}
		,	init				:	function(domainId,domainCode,group_type,pageObjName){
										var me = this;
										me.domainId = domainId
										me.domainCode = domainCode
										me.group_type = group_type;
										me.pageObjName = pageObjName;
										me.gridDept = new coviTree();
										me.gridUser = new coviGrid();
										if(coviCmn.configMap["IsSyncMail"] == null ||  coviCmn.configMap["IsSyncMail"] == 'N'){
											me.isMailDisplay = false;
										} 
										me.getHeaderData();
										me.getGridConfigDept();
										me.getGridConfigUser();
										me.bindgridDept();
									}
		,	getHeaderData		:	function(){
										var me = this;
										me.deptHeaderData=	[{	key:'LANG_DISPLAYNAME',  label:"<spring:message code='Cache.lbl_DeptName'/>", width:'100', align:'left'
																,indent: true
																,getIconClass: function(){
																	return "ic_folder";
																}
															}];
															
										me.userHeaderData=	[	{key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox'}
										
																//사용자ID
															//,	{key:'USERCODE',  label:"<spring:message code='Cache.lbl_User_Id'/>", width:'100', align:'center',containExcel : true
															//		,formatter:function () {
															//			return "<a class='underline' href='#' onclick='"+me.pageObjName+".editOrgUser(\""+ this.item.USERCODE+"\"); return false;'>"+this.item.USERCODE+"</a>";
															//		}
															//	}
															,	{key:'LANG_DEPTNAME',  label:"<spring:message code='Cache.lbl_DeptName'/>", width:'100', display:false,containExcel : true}
																//성명
															,	{key:'LANG_DISPLAYNAME',  label:"<spring:message code='Cache.lbl_USER_NAME_01'/>", width:'*', align:'center',containExcel : true
																	,formatter:function () { 
																		return "<a class='underline' href='#' onclick='"+me.pageObjName+".editOrgUser(\""+ this.item.USERCODE+"\"); return false;'>"+this.item.LANG_DISPLAYNAME+"</a>";
																	}
																}
																//우선순위
															,	{key:'SORTKEY',  label:"<spring:message code='Cache.lbl_PriorityOrder'/>", width:'100', align:'center',containExcel : true}
															
																//직책
															,	{key:'LANG_JOBTITLENAME',  label:"<spring:message code='Cache.lbl_JobTitle'/>", width:'100', align:'center',containExcel : true}
																//직위
															,	{key:'LANG_JOBPOSITIONNAME',  label:"<spring:message code='Cache.lbl_JobPosition'/>", width:'100', align:'center',containExcel : true}
																//직급
															,	{key:'LANG_JOBLEVELNAME',  label:"<spring:message code='Cache.lbl_JobLevel'/>", width:'100', align:'center',containExcel : true}
																//사용여부
															,	{key:'IsUse', label:"<spring:message code='Cache.lbl_IsUse'/>", width:'90', align:'center'
																	,formatter: function() { return window[me.pageObjName].formatUpdateFlag(this); }
																	,containExcel : true
																}
															,	{key:'IsHR', label:"<spring:message code='Cache.lbl_IsHR'/>", width:'90', align:'center'
																	,formatter: function() { return window[me.pageObjName].formatUpdateFlag(this); }
																	,containExcel : true
																}
															,	{key:'IsDisplay', label:"<spring:message code='Cache.lbl_SetDisplay'/>", width:'90', align:'center'
																	,formatter: function() { return window[me.pageObjName].formatUpdateFlag(this); }
																	,containExcel : true
																}
																//메일 
															,	{key:'MAILADDRESS',  label:"<spring:message code='Cache.lbl_Mail'/>", width:'150', align:'center',containExcel : true}
																//기능
															,	{key:'UPDOWN',  label:"<spring:message code='Cache.lbl_action'/>", width:'150', align:'center'
																	, formatter:function () {
																		var item = '';
																			item = '<div class="btnActionWrap">'
																					+	'<a class="btnTypeDefault btnMoveUp" href="#" onclick="'+me.pageObjName+'.moveUser(\'user\',\''+this.index+'\',\'UP\');"><spring:message code="Cache.lbl_apv_up"/></a>'
																					+	'<a class="btnTypeDefault btnMoveDown" href="#" onclick="'+me.pageObjName+'.moveUser(\'user\',\''+this.index+'\',\'DOWN\');"><spring:message code="Cache.lbl_apv_down"/></a>'
																					+'</div>'
																			return item;
																	}
																}
															];
									}
		,	getGridConfigDept	:	function(){
										var me = this;
										var configObj = {
											targetID : "orgDeptTree",					// HTML element target ID
											colGroup:me.deptHeaderData,						// tree 헤드 정의 값
											relation:{
												parentKey: "MemberOf",		// 부모 아이디 키
												childKey: "GroupCode"			// 자식 아이디 키
											},
											persistExpanded: false,		// 쿠키를 이용해서 트리의 확장된 상태를 유지 여부
											persistSelected: false,		// 쿠키를 이용해서 트리의 선택된 상태를 유지 여부
											colHead: {
												display:false
											},
											theme: "AXTree_none",
											fitToWidth:false, // 너비에 자동 맞춤
											xscroll:true,
											width:"auto",
											body: {
												onclick:function(idx, item,ds,s){ //[Function] 바디 클릭 이벤트 콜백함수
													me.gr_code = item.GroupCode;
													$("#btnAdd").show()
													$("#btnDel").show()
													if(me.gr_code.indexOf('_RetireDept')>-1){
														$("#btnAdd").hide()
														$("#btnDel").hide()
													}
													me.setUserGridList();
												}
											}
											
										};
										me.gridDept.setConfig(configObj);
									}
		,	getGridConfigUser	:	function(){
										var me = this;
										var configObj = {
											targetID : "orgUserGrid",
											colGroup:me.userHeaderData,	
											height:"auto",
											xscroll:true,
											page : {
												pageNo:1,
												pageSize: $("#selectPageSize").val()
											},
											paging : true,
											sort:false,
											fitToWidth:false, // 너비에 자동 맞춤
										};
										me.gridUser.setGridConfig(configObj);
									}
		,	bindgridDept 		:	function(searchType,searchText,searchIsUse) {
										var me = this;
										if($.isEmptyObject(_domainId)||_domainId=='')
											return;
										me.gridDept.setList({
											ajaxUrl:"/covicore/manage/conf/selectAllDeptList.do",
											ajaxPars: "domainId="+_domainId,
											onLoad:function(){
												if(me.gr_code==''&&me.gridDept.selectedRow.length==0&&me.gridDept.list.length>0)
													me.gridDept.click(0)
												me.gridDept.expandAll(1);
											}
										});
									}
		,	setUserGridList		:	function(){
										var me = this;
										me.userSearchObjClear();
										me.userSearchObj.groupCode=me.gr_code;
										me.bindGridUser();
									}
		,	bindGridUser 		:	function() {
										var me = this;
										if($.isEmptyObject(me.domainId)||me.domainId=='')
											return;
										
										me.gridUser.bindGrid({
											ajaxUrl:"/covicore/manage/conf/selectUserList.do",
											ajaxPars: {
												domainId : me.domainId,
												groupCode : me.userSearchObj.groupCode,
												searchText : me.userSearchObj.searchText,
												searchType : me.userSearchObj.searchType,
												sortBy: me.gridUser.getSortParam('one')
											}
										});
									}
		,	searchList			:	function searchList() {
										var me = this;
										me.setUserGridList();
									}
		,	searchUserListKeyword:	function(obj) {
										var me = this;
										var searchType = $("#selDetailSearchType").val();
										var searchText = $("#txtDetailSearchText").val();
										if(!($.isEmptyObject(obj)||obj=='') && obj.id=='simpleSearchBtn')
										{
											searchType = "USER_NAME";
											searchText = $("#searchInput").val();
											searchIsUse = "";
											if(searchText=='')
											{
												pageObj.searchList()
												return;
											}
										}
										me.userSearchObjClear();
										me.userSearchObj.searchType=searchType;
										me.userSearchObj.searchText=searchText;
										this.bindGridUser()
									}
		,	changePageSize		:	function(obj){
										var me = this;
										me.gridUser.page.pageSize=$(obj).val();
										me.bindGridUser()
									}
		,	searchDeptTreeKeyword:	function(obj) {
										var me= this;
										var searchText = $("#treeSearchText").val().toLowerCase();
										var curIdx =Number(me.gridDept.selectedRow)+1;
										if(_deptSearchKeyword!=searchText)
										{	
											curIdx = 0;
											_deptSearchKeyword = searchText;
										}
										me.gridDept.findKeywordData("DisplayName",searchText,false,false,curIdx)
									}
		,	updateIsUseUser		:	function(pUserCode, pIsUseValue, pTarget){
										var me = this;
										var now = new Date(); 
										now = XFN_getDateTimeString("yyyy-MM-dd HH:mm:ss",now);
										
										var sURL = "/covicore/manage/conf/updateIsUseUser.do";
										
										$.ajax({
											type:"POST",
											data:{
												"UserCode" : pUserCode,
												"IsUse" : pIsUseValue,
												"ModDate" : now
											},
											url:sURL,
											success:function (data) {
												if(data.status == "SUCCESS") {
													Common.Indicator(Common.getDic("msg_37"), null, 1000);			// 저장되었습니다.
												} else {
													if(!$.isEmptyObject(data.returnMsg)&&data.returnMsg.indexOf('|')>-1) {
														message = data.returnMsg.replaceAll('|','');
														Common.Inform(message, "Information Dialog");
													} else {
														Common.Error(data.returnMsg);
													}
													
													if(pIsUseValue == 'Y') {
														$(pTarget).removeClass("on");
														$("#switch_"+pUserCode+"IsUse").val($("#switch_"+pUserCode+"IsUse").attr("off_value"));
													} else {
														$(pTarget).addClass("on");
														$("#switch_"+pUserCode+"IsUse").val($("#switch_"+pUserCode+"IsUse").attr("on_value"));
													}
												}
											},
											error:function(response, status, error){
												CFN_ErrorAjax(sURL, response, status, error);
											}
										});
									}
		
		,	updateIsHRUser		:	function(pUserCode, pIsHRValue){
										var me = this;
										var now = new Date(); 
										now = XFN_getDateTimeString("yyyy-MM-dd HH:mm:ss",now);
										
										var sURL = "/covicore/manage/conf/updateIsHRUser.do";
										
										$.ajax({
											type:"POST",
											data:{
												"UserCode" : pUserCode,
												"IsHR" : pIsHRValue,
												"ModDate" : now
											},
											url:sURL,
											success:function (data) {
												if(data.result == "ok") {
													Common.Indicator(Common.getDic("msg_37"), null, 1000);			// 저장되었습니다.
												}else{
													Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생헸습니다.
													
													if(pIsHRValue == 'Y') {
														$(pTarget).removeClass("on");
														$("#switch_"+pUserCode+"IsHR").val($("#switch_"+pUserCode+"IsHR").attr("off_value"));
													} else {
														$(pTarget).addClass("on");
														$("#switch_"+pUserCode+"IsHR").val($("#switch_"+pUserCode+"IsHR").attr("on_value"));
													}
												}
											},
											error:function(response, status, error){
												CFN_ErrorAjax(sURL, response, status, error);
											}
										});
									}
		
		,	updateIsDisplayUser	:	function(pUserCode, pIsDisplayValue){
										var me = this;
										var now = new Date(); 
										now = XFN_getDateTimeString("yyyy-MM-dd HH:mm:ss",now);
										
										var sURL = "/covicore/manage/conf/updateIsDisplayUser.do";

										$.ajax({
											type:"POST",
											data:{
												"UserCode" : pUserCode,
												"IsDisplay" : pIsDisplayValue,
												"ModDate" : now
											},
											url:sURL,
											success:function (data) {
												if(data.result == "ok") {
													Common.Indicator(Common.getDic("msg_37"), null, 1000);			// 저장되었습니다.
												}else{
													Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생헸습니다.
													
													if(pIsDisplayValue == 'Y') {
														$(pTarget).removeClass("on");
														$("#switch_"+pUserCode+"IsDisplay").val($("#switch_"+pUserCode+"IsDisplay").attr("off_value"));
													} else {
														$(pTarget).addClass("on");
														$("#switch_"+pUserCode+"IsDisplay").val($("#switch_"+pUserCode+"IsDisplay").attr("on_value"));
													}
												}
											},
											error:function(response, status, error){
												CFN_ErrorAjax(sURL, response, status, error);
											}
										});
									}
		
		,	addOrgUser			:	function(){
										var me = this;
										if(me.gr_code=='')
										{
											Common.Inform("<spring:message code='Cache.msg_apv_238'/>", "Information Dialog");//부서를 선택하세요.
											return;
										}
										var sOpenName = "divUserInfo";
										var sURL = "/covicore/UserManageInfoPop.do";
										sURL += "?groupCode=" + me.gr_code;
										sURL += "&domainId=" + me.domainId
										sURL += "&domainCode=" + me.domainCode
										sURL += "&mode=add";
										sURL += "&OpenName=" + sOpenName;
										
										var sTitle = "";
										sTitle = "<spring:message code='Cache.lbl_OrganizationUserAdd'/>"  + " ||| " + "<spring:message code='Cache.msg_OrganizationUserAdd'/>" ;

										var sWidth = "1000px";
										var sHeight = "600px";
										Common.open("", sOpenName, sTitle, sURL, sWidth, sHeight, "iframe", true, null, null, true);
									}
		
		
		,	deleteOrgUser		:	function(){
										var me = this;
										var groupCodes='';
										var deleteObject = me.gridUser.getCheckedList(0);
										if(deleteObject.length == 0 || deleteObject == null){
											Common.Inform("<spring:message code='Cache.msg_CheckDeleteObject'/>"); //msg_CheckDeleteObject
										}else{			
											Common.Confirm("<spring:message code='Cache.msg_156'/>", "Confirmation Dialog", function (result) {	//해당 사용자를 퇴사 처리하시겠습니까? (확인 시, 퇴직부서로 이동됩니다.)
												if(result) {
													var deleteSeq = "";
													
													for(var i=0; i < deleteObject.length; i++){
														if(i==0){
															deleteSeq = deleteObject[i].USERCODE;
														}else{
															deleteSeq = deleteSeq + "," + deleteObject[i].USERCODE;
														}
													}
													
													$.ajax({
														type:"POST",
														data:{
															"deleteData" : deleteSeq
														},
														url:"/covicore/manage/conf/deleteUser.do",
														success:function (data) {
															if(data.status == "SUCCESS")
															{
																Common.Inform("<spring:message code='Cache.msg_139'/>", "Information Dialog", function(result) { //퇴사 처리 되었습니다.
																	if(result) {
																		me.setUserGridList()
																	}
																});
															}
															else
															{
																if(!$.isEmptyObject(data.returnMsg)&&data.returnMsg.indexOf('|')>-1)
																{
																	message = data.returnMsg.replaceAll('|','');
																	Common.Inform(message, "Information Dialog");
																}
																else
																	Common.Error(data.returnMsg);
															}
														},
														error:function(response, status, error){
															CFN_ErrorAjax("/covicore/manage/conf/deleteUser.do", response, status, error);
														}
													});
												}

											});
										}
									}
		
		,	moveUser			:	function(Type,Idx,UPDOWN){
										var me = this;
										var sCode_A = 0;
										var sCode_B = 0;

										var oChangeTR = null;
										var oCurrentTR = me.gridUser.list[Idx];
										sCode_A = oCurrentTR.USERCODE;

										var i = Number(Idx);
										i = i+(UPDOWN=='UP'?-1:+1);
										
										
										// 상위OR하위Row
										oChangeTR = me.gridUser.list[i];
										if($.isEmptyObject(oChangeTR))
										{
											Common.Inform("<spring:message code='Cache.msg_gw_UnableChangeSortKey'/>", "Information Dialog");//순서를 변경할 수 없습니다
											return;
										}
										if(oChangeTR.SORTKEY==oCurrentTR.SORTKEY)
										{
											Common.Inform("<spring:message code='Cache.msg_gw_UnableChangeSortKeySameSort'/>", "Information Dialog");//동일한 우선순위는 이동 불가능합니다.
											return;
										}
										sCode_B = oChangeTR.USERCODE;
										$.ajax({
											url: "/covicore/manage/conf/moveSortKey_GroupUser.do",
											type:"post",
											data:{
												"pStrCode_A":sCode_A,
												"pStrCode_B":sCode_B,
												"pStrType":Type
												},
											async:false,
											success:function (res) {
												if(res.result == "OK")
													Common.Inform("<spring:message code='Cache.msg_apv_move'/>", "Information Dialog", function() {
														me.setUserGridList()
													});
													
											},
											error:function(response, status, error){
												CFN_ErrorAjax("/covicore/manage/conf/moveSortKey_GroupUser.do", response, status, error);
											}
										});
									}
		,	moveDeptOrgUser:	function(){
										Common.open("","orgchart_pop","<spring:message code='Cache.lbl_DeptOrgMap'/>"
										,"/covicore/control/goOrgChart.do?callBackFunc=callbackOrgUser&allCompany=N&type=C1&companyCode="+_domainCode
										,"1040px", "580px", "iframe", true, null, null,true);
								}
								
		,	callbackOrgUser:	function(data){
									var me = this;
									var jsonData = JSON.parse(data);
									if(jsonData.item.length ==0){
										return ;
									}
									var GroupCode = jsonData.item[0].GroupCode;
									
									var moveUserObject = me.gridUser.getCheckedList(0);
									if(moveUserObject.length == 0 || moveUserObject == null){
										Common.Inform("<spring:message code='Cache.CPMail_mail_moveSel'/>"); // 이동할 항목을 선택해주세요.
									}else{			
										Common.Confirm("<spring:message code='Cache.msg_RUMove'/>", "Confirmation Dialog", function (result) {	//이동 하시겠습니까?
											if(result) {
												var UserList = "";
												
												for(var i=0; i < moveUserObject.length; i++){
													if(i==0){
														UserList = moveUserObject[i].USERCODE;
													}else{
														UserList = UserList + "," + moveUserObject[i].USERCODE;
													}
												}
									 
												$.ajax({
													type:"POST",
													data:{
														"GroupCode" : GroupCode,
														"UserCodeList" : UserList
													},
													url:"/covicore/manage/conf/moveDeptOrgUser.do",
													success:function (data) {
														Common.AlertClose();
														var returnMsg =data.returnMsg;
														if (data.status == "SUCCESS") {
															Common.Inform("<spring:message code='Cache.msg_apv_509'/>" , 'Warning Dialog', function () { //성공적으로 이동하였습니다.
																me.searchList();
															});
														}
														else 
															Common.Error(data.message);
		
													},
													error:function(response, status, error){
														CFN_ErrorAjax(sURL, response, status, error);
													}
												});
											}
										});
									}
								}

		,	editOrgUser		:	function(userCode){
										var me = this;
										if($.isEmptyObject(userCode)||userCode=='')
											return;
										var sOpenName = "divUserInfo";
										var sURL = "/covicore/UserManageInfoPop.do";
										sURL += "?userCode=" + userCode;
										sURL += "&domainId=" + me.domainId
										sURL += "&domainCode=" + me.domainCode
										sURL += "&mode=modify";
										sURL += "&OpenName=" + sOpenName;
										sURL += "&gr_code=" + '';
										
										var sTitle = "";
										sTitle = "<spring:message code='Cache.lbl_OrganizationUserEdit'/>"  + " ||| " + "<spring:message code='Cache.msg_OrganizationUserEdit'/>" ;
										
										var sWidth = "1000px";
										var sHeight = "530px";
										Common.open("", sOpenName, sTitle, sURL, sWidth, sHeight, "iframe", true, null, null, true);
									}
		
		,	excelDownload		:	function(pContainChild){
										var me = this;
										Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage'/>", 'Confirmation Dialog', function (result) {  
											if (result) {
												var headerName = me.getHeaderNameForExcel();
												var	sortKey = "SortKey";
												var	sortWay = "ASC";				  	
												if(pContainChild)
												{
													location.href = "/covicore/manage/conf/groupExcelDownload.do?sortColumn=" + sortKey 
													+ "&sortDirection=" + sortWay 
													+ "&groupType=" + 'user' 
													+ "&groupCode=" + me.gr_code
													+ "&domainId=" + me.domainId 
													+ "&hasChildGroup=" + (pContainChild===true?"Y":"N")
													+ "&headerName=" + encodeURI(encodeURIComponent(headerName)) 
												}
												else{
													location.href = "/covicore/manage/conf/groupExcelDownload.do?sortColumn=" + sortKey 
													+ "&sortDirection=" + sortWay 
													+ "&groupType=" + 'user' 
													+ "&groupCode=" + me.userSearchObj.groupCode
													+ "&searchText=" + me.userSearchObj.searchText
													+ "&searchType=" + me.userSearchObj.searchType
													+ "&domainId=" + me.domainId 
													+ "&hasChildGroup=" + (pContainChild===true?"Y":"N")
													+ "&headerName=" + encodeURI(encodeURIComponent(headerName)) 
												}
											}
										});
									}
		
		,	getHeaderNameForExcel:	function(){
										var me = this;
										var returnStr = "";
			
										for(var i=0;i<me.userHeaderData.length; i++){
											if(me.userHeaderData[i].containExcel){
												returnStr += me.userHeaderData[i].label + ";";
											}
										}
										
										return returnStr;
									}
		 
		
		,	formatUpdateFlag: 		function(pObj){
										var param = pObj.item;
										param.on = 'Y'; param.off = 'N';
										param.defVal = param[pObj.key.toUpperCase()];
										param.retVal = param.USERCODE;
										
										return coviCmn.getCoviSwitch('switch_'+param.USERCODE+'_'+pObj.key, param, 'confManage.update'+pObj.key+'User');
									}
	};
	
	$(document).ready(function () {
		pageObj = Object.create(confManage)
		pageObj.init(_domainId,_domainCode,_group_type,'pageObj')
	});
	
	// 상세검색 열고닫기
	function DetailDisplay(pObj){
		if($("#DetailSearch").hasClass("active")){
			$(pObj).removeClass("active");
			$('#DetailSearch').removeClass("active");
		}else{
			$(pObj).addClass("active");
			$('#DetailSearch').addClass("active");
		}
		
	}
	// 내부 함수로 연결.
	function callbackOrgUser(data) {
		pageObj.callbackOrgUser(data);
	}

	function syncSelectDomain() {
		Common.Progress("<spring:message code='Cache.msg_Processing'/>");
		$.post("/covicore/aclhelper/refreshSyncKeyAll.do", {"DomainID" : _domainId}, function(data) {
			Common.AlertClose();
		});
	}

</script>
