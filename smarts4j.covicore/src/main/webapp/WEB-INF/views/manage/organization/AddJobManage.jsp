<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<style> 
.underline{text-decoration:underline};
</style>
<div class="cRConTop titType">
	<h2 class="title"><spring:message code="Cache.CN_193"/></h2>	
	<div class="searchBox02">
		<span>
			<input type="text" class="sm" id="searchInput" onkeypress="if (event.keyCode==13){ $('#simpleSearchBtn').click(); return false;}">
			<button id="simpleSearchBtn" type="button" onclick="pageObj.searchListKeyword(this);"class="btnSearchType01"><spring:message code='Cache.btn_search'/></button><!-- 검색 -->
		</span>
		<a id="detailSchBtn" onclick="DetailDisplay(this);" class="btnDetails"><spring:message code='Cache.lbl_detail'/></a> <!-- 상세 -->
	</div>
</div>
<div class="cRContBottom mScrollVH"> 
	<div id="DetailSearch" class="inPerView type02 sa02 ">
		<div>
			<div class="selectCalView">
				<span><spring:message code="Cache.lbl_SearchWord"/></span>
				<select id="selDetailSearchType" class="selectType02">
					<option value="NAME"><spring:message code='Cache.lbl_name'/></option> <!-- 이름 -->
					<option value="Company"><spring:message code='Cache.lbl_AddJob_Company'/></option> <!-- 겸직회사 -->
					<option value="Dept"><spring:message code='Cache.lbl_AddJob_Dept'/></option> <!-- 겸직부서 -->
					<option value="JobTitle"><spring:message code='Cache.lbl_AddJob_JobTitle'/></option> <!-- 겸직직책 -->
					<option value="JobPosition"><spring:message code='Cache.lbl_AddJob_JobPosition'/></option> <!-- 겸직직위 -->
					<option value="JobLevel"><spring:message code='Cache.lbl_AddJob_JobLevel'/></option> <!-- 겸직직급 -->
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
				<a class="btnTypeDefault btnPlusAdd" 	id="btnAdd"		onclick="pageObj.addAddJob();"><spring:message code="Cache.btn_Add"/></a><!-- 추가 -->
				<a class="btnTypeDefault btnSaRemove" 	id="btnDel"		onclick="pageObj.deleteAddJob();"><spring:message code="Cache.btn_delete"/></a><!-- 삭제 -->
				<a class="btnTypeDefault btnExcel" 						onclick="pageObj.excelDownload();"><spring:message code="Cache.btn_SaveToExcel"/></a><!-- 엑셀저장 -->
				<!-- <input type="button" class="btnTypeDefault btnExcel" 					value = "<spring:message code="Cache.btn_SaveToExcelWithSub"/>"	onclick="excelDownload_hasChildGroup('group');"/>--><!-- 하위부서 포함 엑셀저장 -->
				<!-- <input type="button" class="btnTypeDefault" 							value = "<spring:message code="Cache.lbl_Property"/>"			onclick="editAddJob();"/> --><!-- 속성 -->
				<a class="btnTypeDefault" 								onclick="syncSelectDomain();"><spring:message code="Cache.btn_CacheApply"/></a><!-- 캐시적용 -->
			
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
	var _domainId =confMenu.domainId;
	var _domainCode = confMenu.domainCode;
	
	var confManage = {
			isMailDisplay 		:	true
		,	grid				:	''
		,	domainId 			:	''
		,	domainCode 			:	''
		,	headerData			:	''
		,	pageObjName			:	''
		,	searchObj			:	{
										searchType 	: ''
									,	searchText 	: ''
									}
		,	searchObjClear		:	function(){
										var me = this;
										me.searchObj.searchType='';
										me.searchObj.searchText='';
									}
		,	init				:	function(domainId,domainCode,pageObjName){
										var me = this;
										me.domainId = domainId
										me.domainCode = domainCode
										me.pageObjName = pageObjName;
										me.grid = new coviGrid();
										if(coviCmn.configMap["IsSyncMail"] == null ||  coviCmn.configMap["IsSyncMail"] == 'N'){
											me.isMailDisplay = false;
										} 
										me.getHeaderData();
										me.setGridConfigGroup();
										me.bindGrid();
									}
		,	getHeaderData		:	function(){
										var me = this;
										
										me.headerData	=	[	
																	{key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox'},
																	//그룹사
																	//{key:'', label:"<spring:message code='Cache.lbl_GroupCode'/>", width:'80', display:false, align:'center'},
																	
																	//이름
																	{key:'LANG_USERNAME', label:"<spring:message code='Cache.lbl_name'/>", width:'150', align:'center',containExcel : true
																		,formatter:function () {
																				return "<a class='underline' href='#' onclick='pageObj.editAddJob(\""+ this.item.NO +"\"); return false;'>"+this.item.LANG_USERNAME+"</a>";
																		}
																	},
																	//겸직회사
																	{key:'LANG_COMPANYNAME', label:"<spring:message code='Cache.lbl_AddJob_Company'/>", width:'150', align:'center',containExcel : true},
																	//겸직부서
																	{key:'LANG_DEPTNAME', label:"<spring:message code='Cache.lbl_AddJob_Dept'/>", width:'150', align:'center',containExcel : true},
																	//겸직직책
																	{key:'LANG_JOBTITLENAME', label:"<spring:message code='Cache.lbl_AddJob_JobTitle'/>", width:'150', align:'center',containExcel : true},
																	//겸직직위
																	{key:'LANG_JOBPOSITIONNAME', label:"<spring:message code='Cache.lbl_AddJob_JobPosition'/>", width:'150', align:'center',containExcel : true},
																	//겸직직급
																	{key:'LANG_JOBLEVELNAME', label:"<spring:message code='Cache.lbl_AddJob_JobLevel'/>", width:'150', align:'center',containExcel : true},
																		
																]
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
											ajaxUrl:"/covicore/manage/conf/selectAddJobList.do",
											ajaxPars: {
												domainId : this.domainId,
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
										if(!($.isEmptyObject(obj)||obj=='') && obj.id=='simpleSearchBtn')
										{
											searchType = "NAME";
											searchText = $("#searchInput").val();
										}
										
										if($.isEmptyObject(this.domainId)||this.domainId=='')
											return;
										me.searchObjClear();
										me.searchObj.searchType=searchType;
										me.searchObj.searchText=searchText;
										
										
										
										
										this.grid.page.pageNo=1;
										this.bindGrid()
									}
		,	addAddJob			:	function(){
										var me = this;
										var sOpenName = "divAddJobInfo";
										var sGR_Code = "";
										var sURL = "/covicore/AddJobManageInfoPop.do";
										sURL += "?NO=" + '';
										sURL += "&mode=add";
										sURL += "&domainId="+this.domainId;
										sURL += "&domainCode="+this.domainCode;
										sURL += "&OpenName=" + sOpenName;
										
										
										var sTitle = "";
										sTitle = "<spring:message code='Cache.lbl_AddJobAdd'/>";

										var sWidth = "710px";
										var sHeight = "450px";
										Common.open("", sOpenName, sTitle, sURL, sWidth, sHeight, "iframe", true, null, null, true);
									}
		
		
		,	deleteAddJob		:	function(){
										var me = this;
										var NO='';
										var deleteObject = me.grid.getCheckedList(0);
										if(deleteObject.length == 0 || deleteObject == null){
											Common.Inform("<spring:message code='Cache.msg_CheckDeleteObject'/>"); //msg_CheckDeleteObject
											return;
										}
										$.each(deleteObject, function(i,obj){
											NO += obj.NO + ','
										});
										NO=NO.slice(0,-1)
										Common.Confirm("<spring:message code='Cache.msg_AreYouDelete'/>", 'Confirmation Dialog', function (result) {       //apv_msg_rule02 하위 노드가 존재하면 같이 삭제 됩니다. 선택한 항목을 삭제 하시겠습니까?
											 if (result) {
												$.ajax({
													type:"POST",
													url:"/covicore/manage/conf/deleteAddJob.do",
													data:{
														"NO":NO
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
															Common.Inform("<spring:message code='Cache.msg_deletedOK'/>", "Information Dialog", function(result) {
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
		
		
		,	editAddJob		:	function(NO){
										var me = this;
										if($.isEmptyObject(NO)||NO=='')
											return;
										
										var sOpenName = "divAddJobInfo";

										var sURL = "/covicore/AddJobManageInfoPop.do";
										sURL += "?NO=" + NO
										sURL += "&mode=modify"
										sURL += "&domainId="+this.domainId;
										sURL += "&domainCode="+this.domainCode;
										sURL += "&OpenName=" + sOpenName;
										

										sTitle = "<spring:message code='Cache.lbl_OrganizationGroupInfo'/>"  + " ||| " + "<spring:message code='Cache.msg_OrganizationGroupInfo'/>" ;

										var sWidth = "710px";
										var sHeight = "450px";
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
												+ "&groupType=" + 'addJob'
												+ "&searchText=" + me.searchObj.searchText
												+ "&searchType=" + me.searchObj.searchType
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
		pageObj = Object.create(confManage)
		pageObj.init(_domainId,_domainCode,'pageObj')
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
</script>