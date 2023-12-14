<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String GroupType =  request.getParameter("GroupType");
%>
<style> 
.underline{text-decoration:underline}
label.help_label{font-size: 14px;}
</style>
<div class="cRConTop titType">
	<h2 class="title"><spring:message code="Cache.CN_189"/></h2>	
	<div class="searchBox02">
		<span>
			<input type="text" class="sm" id="searchInput" onkeypress="if (event.keyCode==13){ $('#simpleSearchBtn').click(); return false;}">
			<button id="simpleSearchBtn" type="button" onclick="pageObj.searchListKeyword(this);"class="btnSearchType01"><spring:message code='Cache.btn_search' /></button>
		</span>
		<a id="detailSchBtn" onclick="DetailDisplay(this);" class="btnDetails"><spring:message code='Cache.lbl_detail'/></a> <!-- 상세 -->
	</div>
</div>	
<div class="cRContBottom mScrollVH"> 
	<div id="DetailSearch" class="inPerView type02 sa01 ">
		<div>
			<div class="selectCalView">
				<span><spring:message code="Cache.lbl_IsUse"/></span>
				<select id="selDetailSearchIsUse" class="selectType02">
					<option value=""><spring:message code="Cache.lbl_all"/></option>
					<option value="Y"><spring:message code="Cache.lbl_Use"/></option>
					<option value="N"><spring:message code="Cache.lbl_noUse"/></option>
				</select>
			</div>
			<div class="selectCalView">
				<span><spring:message code="Cache.lbl_SearchWord"/></span>
				<select id="selDetailSearchType" class="selectType02">
					<option value="NAME"><spring:message code="Cache.lbl_GroupName"/>	</option>
					<option value="CODE"><spring:message code="Cache.lbl_GroupCode"/>	</option>
				</select>
			</div>
			<div class="selectCalView">
				<input type="text" id="txtDetailSearchText" style="width: 215px;" onkeypress="if (event.keyCode==13){ pageObj.searchListKeyword(this); return false;}" >
			</div>
			<a href="#" class="btnTypeDefault btnSearchBlue nonHover" onclick="pageObj.searchListKeyword(this);" ><spring:message code="Cache.btn_search"/></a>
		</div>
	</div>
	<!-- 컨텐츠 시작 -->
	<div class="sadminContent">
		<!-- 상단 버튼 시작 -->
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a class="btnTypeDefault btnPlusAdd" 	id="btnAdd"		onclick="pageObj.addOrgGroup();"><spring:message code="Cache.btn_Add"/></a><!-- 추가 -->
				<a class="btnTypeDefault btnSaRemove" 	id="btnDel"		onclick="pageObj.deleteOrgGroup();"><spring:message code="Cache.btn_NotUse"/></a><!-- 사용안함 -->
				<a class="btnTypeDefault btnExcel" 						onclick="pageObj.excelDownload();"><spring:message code="Cache.btn_SaveToExcel"/></a><!-- 엑셀저장 -->
				<!-- <input type="button" class="btnTypeDefault btnExcel" 					value = "<spring:message code="Cache.btn_SaveToExcelWithSub"/>"	onclick="excelDownload_hasChildGroup('group');"/>--><!-- 하위부서 포함 엑셀저장 -->
				<!-- <input type="button" class="btnTypeDefault" 							value = "<spring:message code="Cache.lbl_Property"/>"			onclick="editOrgGroup();"/> --><!-- 속성 -->
				<a class="btnTypeDefault" 								onclick="syncSelectDomain();"><spring:message code="Cache.btn_CacheApply"/></a><!-- 캐시적용 -->
				<label class='help_label'>*<spring:message code="Cache.msg_validCheckHasObject"/></label><!--소속된 객체가 있을 경우 체크박스 선택 불가능합니다.-->
			
			</div>
			<div class="buttonStyleBoxRight">
				<div class="searchBox02">
					<button id="folderRefresh" class="btnRefresh" type="button" onclick="pageObj.searchListKeyword()"></button>
				</div>
			</div>
		</div>
		<!-- 상단 버튼 끝 -->
		<div class="tblList tblCont">
			<div id="orggroupGrid"></div>
		</div>
	</div> 
</div>
<script type="text/javascript">
	var pageObj;
	var _group_type = "<%=GroupType%>";
	var _domainId =confMenu.domainId;
	
	var confManage = {
			isMailDisplay 		:	true
		,	grid				:	''
		,	gr_code				:	''
		,	group_type 			: 	''
		,	domainId 			:	''
		,	headerData			:	''
		,	pageObjName			:	''
		,	searchObj			:	{
										groupType	: ''
									,	searchType 	: ''
									,	searchText 	: ''
									,	searchIsUse	: ''
									}
		,	searchObjClear		:	function(){
										var me = this;
										me.searchObj.searchType='';
										me.searchObj.searchText='';
										me.searchObj.searchIsUse='';
									}
		,	init				:	function(domainId,group_type,pageObjName){
										var me = this;
										me.domainId = domainId
										me.group_type = group_type;
										me.pageObjName = pageObjName;
										me.grid = new coviGrid();
										me.gr_code =me.domainId+"_"+me.group_type
										if(coviCmn.configMap["IsSyncMail"] == null ||  coviCmn.configMap["IsSyncMail"] == 'N'){
											me.isMailDisplay = false;
										} 
										me.searchObj.groupType = group_type;
										
										me.getHeaderData();
										me.setGridConfigGroup();
										me.bindGrid();
										
										
										$("#selDetailSearchType option[value=NAME]").text(Common.getDic("lbl_"+me.group_type+"Name"))
										$("#selDetailSearchType option[value=CODE]").text(Common.getDic("lbl_"+me.group_type+"_Code"))
									}
		,	getHeaderData		:	function(){
										var me = this;
										if(me.group_type=='JobPosition')
											me.headerData	=	[		{key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox'},
																		//직위명
																		{key:'LANG_DISPLAYNAME', label:"<spring:message code='Cache.lbl_JobPositionName'/>", width:'80',  align:'center',containExcel : true
																			,formatter:function () {
																				return "<a class='underline' href='#' onclick='pageObj.editOrgGroup(\""+ this.item.GroupCode +"\"); return false;'>"+this.item.LANG_DISPLAYNAME+"</a>";
																			}
																		},
																		//우선순위
																		{key:'SortKey',  label:"<spring:message code='Cache.lbl_PriorityOrder'/>", width:'50', align:'center',containExcel : true},
																		//그룹사
																		//{key:'', label:"<spring:message code='Cache.lbl_GroupCode'/>", width:'80', display:false, align:'center'},
																		//직위코드
																		{key:'GroupCode', label:"<spring:message code='Cache.lbl_JobPosition_Code'/>", width:'80', align:'center',containExcel : true, display:false
																			,formatter:function () {
																				return "<a class='underline' href='#' onclick='pageObj.editOrgGroup(\""+ this.item.GroupCode +"\"); return false;'>"+this.item.GroupCode+"</a>";
																			}
																		},
																		//메일
																		{key:'PrimaryMail', label:"<spring:message code='Cache.lbl_Mail'/>", width:'150', align:'center',containExcel : true},
																		//사용여부
																		{key:'IsUse', label:"<spring:message code='Cache.lbl_IsUse'/>", width:'40', align:'center'
																			,formatter: function() { return formatSwitch(this); }
																			,containExcel : true
																		},
																		//기능
																		{key:'UPDOWN',  label:"<spring:message code='Cache.lbl_action'/>", width:'100', align:'center', formatter:function () {
																				var item = '';
																				item = '<div class="btnActionWrap">'
																						+	'<a class="btnTypeDefault btnMoveUp" href="#" onclick="pageObj.move(\'group\',\''+this.index+'\',\'UP\');"><spring:message code="Cache.lbl_apv_up"/></a>'
																						+	'<a class="btnTypeDefault btnMoveDown" href="#" onclick="pageObj.move(\'group\',\''+this.index+'\',\'DOWN\');"><spring:message code="Cache.lbl_apv_down"/></a>'
																						+'</div>'
																				return item;
																			}
																		},
																		
																	];
										else if(me.group_type=='JobLevel')
											me.headerData	=	[		{key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox'},
																		//직급명
																		{key:'LANG_DISPLAYNAME', label:"<spring:message code='Cache.lbl_JobLevelName'/>", width:'80',  align:'center',containExcel : true
																			,formatter:function () {
																				return "<a class='underline' href='#' onclick='pageObj.editOrgGroup(\""+ this.item.GroupCode +"\"); return false;'>"+this.item.LANG_DISPLAYNAME+"</a>";
																			}
																		},
																		//우선순위
																		{key:'SortKey',  label:"<spring:message code='Cache.lbl_PriorityOrder'/>", width:'50', align:'center',containExcel : true},
																		//그룹사
																		//{key:'', label:"<spring:message code='Cache.lbl_GroupCode'/>", width:'80', display:false, align:'center'},
																		//직급코드
																		{key:'GroupCode', label:"<spring:message code='Cache.lbl_JobLevel_Code'/>", width:'80', align:'center',containExcel : true, display:false
																			,formatter:function () {
																				return "<a class='underline' href='#' onclick='pageObj.editOrgGroup(\""+ this.item.GroupCode +"\"); return false;'>"+this.item.GroupCode+"</a>";
																			}
																		},
																		//메일
																		{key:'PrimaryMail', label:"<spring:message code='Cache.lbl_Mail'/>", width:'150', align:'center',containExcel : true},
																		//사용여부
																		{key:'IsUse', label:"<spring:message code='Cache.lbl_IsUse'/>", width:'40', align:'center'
																			,formatter: function() { return formatSwitch(this); }
																			,containExcel : true
																		},
																		//기능
																		{key:'UPDOWN',  label:"<spring:message code='Cache.lbl_action'/>", width:'100', align:'center', formatter:function () {
																				var item = '';
																				item = '<div class="btnActionWrap">'
																						+	'<a class="btnTypeDefault btnMoveUp" href="#" onclick="pageObj.move(\'group\',\''+this.index+'\',\'UP\');"><spring:message code="Cache.lbl_apv_up"/></a>'
																						+	'<a class="btnTypeDefault btnMoveDown" href="#" onclick="pageObj.move(\'group\',\''+this.index+'\',\'DOWN\');"><spring:message code="Cache.lbl_apv_down"/></a>'
																						+'</div>'
																				return item;
																			}
																		},
																	
																	];
										else if(me.group_type=='JobTitle')
											me.headerData	=	[		{key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox'},
																		//직책명
																		{key:'LANG_DISPLAYNAME', label:"<spring:message code='Cache.lbl_JobTitleName'/>", width:'80',  align:'center',containExcel : true
																			,formatter:function () {
																				return "<a class='underline' href='#' onclick='pageObj.editOrgGroup(\""+ this.item.GroupCode +"\"); return false;'>"+this.item.LANG_DISPLAYNAME+"</a>";
																			}
																		},
																		//우선순위
																		{key:'SortKey',  label:"<spring:message code='Cache.lbl_PriorityOrder'/>", width:'50', align:'center',containExcel : true},
																		//그룹사
																		//{key:'', label:"<spring:message code='Cache.lbl_GroupCode'/>", width:'80', display:false, align:'center'},
																		//직책코드
																		{key:'GroupCode', label:"<spring:message code='Cache.lbl_JobTitle_Code'/>", width:'80', align:'center',containExcel : true, display:false
																			,formatter:function () {
																				return "<a class='underline' href='#' onclick='pageObj.editOrgGroup(\""+ this.item.GroupCode +"\"); return false;'>"+this.item.GroupCode+"</a>";
																			}
																		},
																		//메일
																		{key:'PrimaryMail', label:"<spring:message code='Cache.lbl_Mail'/>", width:'150', align:'center',containExcel : true},
																		//사용여부
																		{key:'IsUse', label:"<spring:message code='Cache.lbl_IsUse'/>", width:'40', align:'center'
																			,formatter: function() { return formatSwitch(this); }
																			,containExcel : true
																		},
																		//기능
																		{key:'UPDOWN',  label:"<spring:message code='Cache.lbl_action'/>", width:'100', align:'center', formatter:function () {
																				var item = '';
																				item = '<div class="btnActionWrap">'
																						+	'<a class="btnTypeDefault btnMoveUp" href="#" onclick="pageObj.move(\'group\',\''+this.index+'\',\'UP\');"><spring:message code="Cache.lbl_apv_up"/></a>'
																						+	'<a class="btnTypeDefault btnMoveDown" href="#" onclick="pageObj.move(\'group\',\''+this.index+'\',\'DOWN\');"><spring:message code="Cache.lbl_apv_down"/></a>'
																						+'</div>'
																				return item;
																			}
																		},
																		
																	];
										else if(me.group_type=='Region')
											me.headerData	=	[		{key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox'},
																		//지역명
																		{key:'LANG_DISPLAYNAME', label:"<spring:message code='Cache.lbl_RegionName'/>", width:'80',  align:'center',containExcel : true
																			,formatter:function () {
																				return "<a class='underline' href='#' onclick='pageObj.editOrgGroup(\""+ this.item.GroupCode +"\"); return false;'>"+this.item.LANG_DISPLAYNAME+"</a>";
																			}
																		},
																		//우선순위
																		{key:'SortKey',  label:"<spring:message code='Cache.lbl_PriorityOrder'/>", width:'50', align:'center',containExcel : true},
																		//그룹사
																		//{key:'', label:"<spring:message code='Cache.lbl_GroupCode'/>", width:'80', display:false, align:'center'},
																		//직책코드
																		{key:'GroupCode', label:"<spring:message code='Cache.lbl_Region_Code'/>", width:'80', align:'center',containExcel : true, display:false
																			,formatter:function () {
																				return "<a class='underline' href='#' onclick='pageObj.editOrgGroup(\""+ this.item.GroupCode +"\"); return false;'>"+this.item.GroupCode+"</a>";
																			}
																		},
																		//메일
																		{key:'PrimaryMail', label:"<spring:message code='Cache.lbl_Mail'/>", width:'150', align:'center',containExcel : true},
																		//사용여부
																		{key:'IsUse', label:"<spring:message code='Cache.lbl_IsUse'/>", width:'40', align:'center'
																			,formatter: function() { return formatSwitch(this); }
																			,containExcel : true
																		},
																		//기능
																		{key:'UPDOWN',  label:"<spring:message code='Cache.lbl_action'/>", width:'100', align:'center', formatter:function () {
																				var item = '';
																				item = '<div class="btnActionWrap">'
																						+	'<a class="btnTypeDefault btnMoveUp" href="#" onclick="pageObj.move(\'group\',\''+this.index+'\',\'UP\');"><spring:message code="Cache.lbl_apv_up"/></a>'
																						+	'<a class="btnTypeDefault btnMoveDown" href="#" onclick="pageObj.move(\'group\',\''+this.index+'\',\'DOWN\');"><spring:message code="Cache.lbl_apv_down"/></a>'
																						+'</div>'
																				return item;
																			}
																		},
																		
																	];
									}
		,	setGridConfigGroup	:	function(){
										var me = this;
										me.grid.setGridConfig({
											targetID : "orggroupGrid",
											colGroup:me.headerData,	
											height:"auto",
											xscroll:true,
											page : {
												pageNo:1,
												pageSize:10
											},
											paging : true,
											sort:false
										});
									}
		,	bindGrid 			:	function() {
										var me = this;
										
										this.grid.bindGrid({
											ajaxUrl:"/covicore/manage/conf/selectGroupListByGroupType.do",
											ajaxPars: {
												domainId : this.domainId,
												groupType : me.searchObj.groupType,
												searchIsUse : me.searchObj.searchIsUse,
												searchText : me.searchObj.searchText,
												searchType : me.searchObj.searchType,
												sortBy: this.grid.getSortParam('one')
											}
										});
									}
		,	searchListKeyword	:	function(obj) {
										var me = this;
										
										var searchType = $("#selDetailSearchType").val();
										var searchText = $("#txtDetailSearchText").val();
										var searchIsUse = $("#selDetailSearchIsUse").val();
										if(!($.isEmptyObject(obj)||obj=='') && obj.id=='simpleSearchBtn')
										{
											searchType = "NAME";
											searchText = $("#searchInput").val();
											searchIsUse = "";
										}
										me.searchObjClear();
										me.searchObj.searchType = searchType;
										me.searchObj.searchText = searchText;
										me.searchObj.searchIsUse = searchIsUse;
										
										this.grid.page.pageNo=1;
										this.bindGrid()
									}
		,	updateIsUse			:	function(pCode, pIsUseValue){
										var me = this;
										var now = new Date();
										now = XFN_getDateTimeString("yyyy-MM-dd HH:mm:ss",now);
										
										var sURL = "/covicore/manage/conf/updateIsUseGroup.do";
										
										$.ajax({
											type:"POST",
											data:{
												"Code" : pCode,
												"IsUse" : pIsUseValue,
												"ModID" : "",				// 세션 값
												"ModDate" : now
											},
											url:sURL,
											success:function (data) {
												if(data.result == "ok"){
													Common.Indicator(Common.getDic("msg_37"), null, 1000);			// 저장되었습니다.
												}
												else {
													if(data.message.indexOf("|")>-1) Common.Warning(Common.getDic(data.message.split("|")[0]).replace("{0}",data.message.split("|")[1]));
													else Common.Warning(data.message);
													me.grid.reloadList();
												}
											},
											error:function(response, status, error){
												CFN_ErrorAjax(sURL, response, status, error);
											}
										});
									}
		
		
		,	addOrgGroup			:	function(){
										var me = this;
										var sOpenName = "divgroupInfo";
										var sGR_Code = "";
										var sURL = "/covicore/ArbitraryGroupManageInfoPop.do";
										sURL += "?gr_code=" + '';
										sURL += "&domainId=" + me.domainId
										sURL += "&memberOf=" + me.gr_code;
										sURL += "&GroupType=" + me.group_type;
										sURL += "&mode=add";
										sURL += "&OpenName=" + sOpenName;
										 
										var sTitle = 
										_group_type=='JobTitle'?"<spring:message code='Cache.lbl_OrganizationJobTitleInfo'/>"+ " ||| " + "<spring:message code='Cache.msg_OrganizationJobTitleAdd'/>"
										:_group_type=='JobLevel'?"<spring:message code='Cache.lbl_OrganizationJobLevelInfo'/>"+ " ||| " + "<spring:message code='Cache.msg_OrganizationJobLevelAdd'/>"
										:"<spring:message code='Cache.lbl_OrganizationJobPositionInfo'/>"+ " ||| " + "<spring:message code='Cache.msg_OrganizationJobPositionAdd'/>"
									
										var sWidth = "710px";
										var sHeight = "640px";
										Common.open("", sOpenName, sTitle, sURL, sWidth, sHeight, "iframe", true, null, null, true);
									}
		
		
		,	deleteOrgGroup		:	function(){
										var me = this;
										var groupCodes='';
										var deleteObject = me.grid.getCheckedList(0);
										if(deleteObject.length == 0 || deleteObject == null){
											Common.Inform("<spring:message code='Cache.msg_CheckNotUseObject'/>"); 
											return;
										}
										$.each(deleteObject, function(i,obj){
											groupCodes += obj.GroupCode + ','
										});
										groupCodes=groupCodes.slice(0,-1)
										Common.Confirm("<spring:message code='Cache.msg_AreYouNotUse'/>", 'Confirmation Dialog', function (result) {       //apv_msg_rule02 하위 노드가 존재하면 같이 삭제 됩니다. 선택한 항목을 삭제 하시겠습니까?
											 if (result) {
												$.ajax({
													type:"POST",
													url:"/covicore/manage/conf/deleteGroup.do",
													data:{
														"GroupCodes":groupCodes
													},
													success:function(data){
														if(data.status == "FAIL") {
															if($.isEmptyObject(data.message)){
																Common.Warning("<spring:message code='Cache.msg_changeFail'/>");
															}
															else{
																if(data.message.indexOf("|")>-1) Common.Warning(Common.getDic(data.message.split("|")[0]).replace("{0}",data.message.split("|")[1]));
																else Common.Warning(data.message);
															}
														} else {
															Common.Inform("<spring:message code='Cache.msg_processSuccess'/>", "Information Dialog", function(result) {
																if(result) {
																	me.searchListKeyword()
																}
															});
														}
													},
													error:function(response, status, error){
														 CFN_ErrorAjax("/covicore/manage/conf/deleteDept.do", response, status, error);
													}
												});
											}
										});
									}
		
		,	move				:	function(Type,Idx,UPDOWN){
										var me = this;
										var sCode_A = 0;
										var sCode_B = 0;

										var oChangeTR = null;
										var oCurrentTR = me.grid.list[Idx];
										sCode_A = oCurrentTR.GroupCode;

										var i = Number(Idx);
										i = i+(UPDOWN=='UP'?-1:+1);
										
										
										// 상위OR하위Row
										oChangeTR = me.grid.list[i];
										if($.isEmptyObject(oChangeTR))
										{
											Common.Inform("<spring:message code='Cache.msg_gw_UnableChangeSortKey'/>", "Information Dialog");//순서를 변경할 수 없습니다
											return;
										}
										if(oChangeTR.SortKey==oCurrentTR.SortKey)
										{
											Common.Inform("<spring:message code='Cache.msg_gw_UnableChangeSortKeySameSort'/>", "Information Dialog");//동일한 우선순위는 이동 불가능합니다.
											return;
										}
										sCode_B = oChangeTR.GroupCode;
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
														me.searchListKeyword() 
													});
													
											},
											error:function(response, status, error){
												CFN_ErrorAjax("/covicore/manage/conf/moveSortKey_GroupUser.do", response, status, error);
											}
										});
									}
		
		,	editOrgGroup		:	function(gr_code){
										var me = this;
										if($.isEmptyObject(gr_code)||gr_code=='')
											return;
										
										var sOpenName = "divgroupInfo";

										var sURL = "/covicore/ArbitraryGroupManageInfoPop.do";
										sURL += "?gr_code=" + gr_code
										sURL += "&domainId=" + me.domainId
										sURL += "&memberOf=" + ''
										sURL += "&GroupType=" + me.group_type
										sURL += "&mode=modify"
										sURL += "&OpenName=" + sOpenName;
										

										var sTitle = 
										_group_type=='JobTitle'?"<spring:message code='Cache.lbl_OrganizationJobTitleInfo'/>"+ " ||| " + "<spring:message code='Cache.msg_OrganizationJobTitleInfo'/>"
										:_group_type=='JobLevel'?"<spring:message code='Cache.lbl_OrganizationJobLevelInfo'/>"+ " ||| " + "<spring:message code='Cache.msg_OrganizationJobLevelInfo'/>"
										:"<spring:message code='Cache.lbl_OrganizationJobPositionInfo'/>"+ " ||| " + "<spring:message code='Cache.msg_OrganizationJobPositionInfo'/>"
									

										var sWidth = "710px";
										var sHeight = "640px";
										Common.open("", sOpenName, sTitle, sURL, sWidth, sHeight, "iframe", true, null, null, true);
									}
		
		,	excelDownload		:	function(){
										var me = this;
										Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage'/>", 'Confirmation Dialog', function (result) {  
											if (result) {
												var headerName = me.getHeaderNameForExcel();
												var	sortKey = "SortKey";
												var	sortWay = "ASC";	
												location.href = "/covicore/manage/conf/groupExcelDownload.do?sortColumn=" + sortKey 
												+ "&sortDirection=" + sortWay 
												+ "&groupType=" + me.searchObj.groupType  
												+ "&searchType=" + me.searchObj.searchType  
												+ "&searchText=" + me.searchObj.searchText  
												+ "&searchIsUse=" + me.searchObj.searchIsUse  
												+ "&domainId=" + me.domainId 
												+ "&headerName=" + encodeURI(encodeURIComponent(headerName)) 
											}
										});
									}
		
		,	getHeaderNameForExcel:	function(){
										var me = this;
										var returnStr = "";
			
										for(var i=0;i<me.headerData.length; i++){
											if(me.headerData[i].containExcel){
												returnStr += me.headerData[i].label + ";";
											}
										}
										
										return returnStr;
									}
		 
		
		
	};
	
	$(document).ready(function () {
		var title = _group_type=='JobTitle'?"<spring:message code='Cache.CN_188'/>"
		:_group_type=='JobLevel'?"<spring:message code='Cache.CN_190'/>"
		:_group_type=='JoPosition'?"<spring:message code='Cache.CN_189'/>"
		:"<spring:message code='Cache.CN_192'/>"
		$("[class=title]").html(title)
		pageObj = Object.create(confManage)
		pageObj.init(_domainId,_group_type,'pageObj')
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
		

	function syncSelectDomain() {
		Common.Progress("<spring:message code='Cache.msg_Processing'/>");
		$.post("/covicore/aclhelper/refreshSyncKeyAll.do", {"DomainID" : _domainId}, function(data) {
			Common.AlertClose();
		});
	}

	function pageRefresh(){
		pageObj.searchListKeyword()
	}
	
	function formatSwitch(pObj){
		var param = pObj.item;
		param.on = 'Y'; param.off = 'N';
		param.defVal = param[pObj.key];
		param.retVal = param.GroupCode;
		return coviCmn.getCoviSwitch('switch_'+param.GroupCode, param, 'pageObj.updateIsUse');
	}
</script>