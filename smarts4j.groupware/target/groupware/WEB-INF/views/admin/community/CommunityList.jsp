<%@ page import="java.util.Objects"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code="Cache.lblComm"/></span>	
</h3>
<input type="hidden" id ="hiddenCategory" value = ""/>
<input type="hidden" id ="DIC_Code_ko" value = ""/>
<input type="hidden" id ="DIC_Code_en" value = ""/>
<input type="hidden" id ="DIC_Code_ja" value = ""/>
<input type="hidden" id ="DIC_Code_zh" value = ""/>
<input type="hidden" id ="_hiddenMemberOf" value = ""/>	
   <div style="width:100%;min-height: 500px">
   	<div id="topitembar01" class="topbar_grid">
		<input id="refresh" type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="gridRefresh();"/>
		<input id="property" type="button" class="AXButton"  value="<spring:message code="Cache.lbl_Property"/>" onclick="mainProperty();"/>
		<input id="add" type="button" class="AXButton BtnAdd"  value="<spring:message code="Cache.btn_Add"/>" onclick="addSubProperty();"/>
		<input id="dcooremove" type="button" class="AXButton BtnDelete"  value="<spring:message code="Cache.btn_dcooremove"/>" onclick="delProperty();"/>
		<input id="move" type="button" class="AXButton"  value="<spring:message code="Cache.btn_Move"/>" onclick="moveProperty();"/>
		<input id="makecommunitu" type="button" class="AXButton"  value="<spring:message code="Cache.lbl_MakeCommunity"/>" onclick="addCommunity();"/>
	</div>
	<div id="classificationDiv" style="margin: 10px 0; font-size: initial;">
		<spring:message code="Cache.lbl_Res_Div"/> : <span id="Classification"></span>
	</div>	
	<div id="gridDiv"></div>
	<div id="topitembar02" class="topbar_grid">
		<input id="refresh" type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="gridSubRefresh();"/>
		<input type="button" class="AXButton"  value="<spring:message code="Cache.btn_ForcedClosure"/>" onclick="communityClose();"/>
		<input type="button" class="AXButton"  value="<spring:message code="Cache.lbl_Restore"/>" onclick="communityRestore();"/>
		<div class="w_top" id="divNoticeMedia" style="display:none; float: right; padding-right: 10px; width: 300px;">
               <dl style="float: right;">
                   <dd class="w_top_line" style="display: inline;">
                   	<input id="chkNoticeMail" type="checkbox" value="Mail" checked="" class="input_check2">
                   	Mail
                   </dd>
                   <dd class="w_top_line" style="display: inline;">
                   	<input id="chkNoticeTODOLIST" type="checkbox" value="TODOLIST" checked="" class="input_check2">
                   	Todo
                   </dd>
             		<input type="button" class="AXButton"  value="<spring:message code="Cache.msg_contactOperator"/>" onclick="javascript:sendMessage();"/>	
               </dl>
      		 </div>
	</div>
	<div id="topitembar02" class="topbar_grid">
		<spring:message code="Cache.lbl_apv_state"/>
		<select id="communityCdSelBox" class="AXSelect W100"></select>
		<spring:message code="Cache.lbl_type"/>
		<select id="communityTySelBox" class="AXSelect W100"></select>
		<spring:message code="Cache.lbl_JoiningMethod"/>
		<select id="communityJoSeltBox" class="AXSelect W100"></select>
		<spring:message code="Cache.lbl_search"/>
		<select id="communitySeSelBox" class="AXSelect W100">
			<option value="0"><spring:message code="Cache.btn_Select"/></option>
			<option value="1"><spring:message code="Cache.lbl_selCommunityName"/></option>
			<option value="2"><spring:message code="Cache.lbl_Operator"/></option>
		</select>
		<input name="search" type="text" id="searchValue" class="AXInput" />
		<input type="button" value="<spring:message code='Cache.btn_search'/>" id="searchBtn" class="AXButton" />
	</div>	
	<div id="subGridDiv"></div>
</div>
<script type="text/javascript">
	var dnID = CFN_GetQueryString("DNID");
	var CategoryID = CFN_GetQueryString("folder") == 'undefined' ? "" :  CFN_GetQueryString("folder");
	var MemberOf = CFN_GetQueryString("path") == 'undefined' ? "" :  CFN_GetQueryString("path").replace(/@/gi, ';');
	var pType = CFN_GetQueryString("pType");
	
	var msgHeaderData = "";
	var msgSubHeaderData = "";
	
	var communityGrid = new coviGrid();
	var communitySubGrid = new coviGrid();
	
	communityGrid.config.fitToWidthRightMargin=0;
	communitySubGrid.config.fitToWidthRightMargin=0;
	
	var lang = Common.getSession("lang");
	
	var queryStr;
	
	$(function(){
		queryStr = initQueryStr();
		
		if (queryStr.folderID && queryStr.DNID && queryStr.folderType) {
			selectCommunityTreeListByTree(queryStr.folderID, queryStr.folderType, queryStr.path, queryStr.folderName, queryStr.folderIdx);
		}
		else {
			initLoad();
		}
	})
	
	function initQueryStr(){
		return JSON.parse('{"' + decodeURI(location.search.substring(1)).replace(/"/g, '\\"').replace(/&/g, '","').replace(/=/g,'":"') + '"}');
	}
	
	// window.onload = initLoad();
	
	function initLoad(){
		setCommunityGrid();
		
		if(CategoryID == "" && MemberOf == ""){
			$("#classificationDiv, #topitembar02, #subGridDiv").hide()
		}else{
			$("#classificationDiv, #topitembar02, #subGridDiv").show()
			setCommunitySubGrid();
			setCurrentLocation();
		}
		
		//분류 FolderType이 Folder인 경우 하위 폴더 생성 불가
		if(MemberOf != "" && MemberOf != 0 && MemberOf != undefined){
			$("#add").hide();
		}
		
		event();
	}
	
	function GridHeader(){
		var communityGridHeader = [
			      		         	{key:'CategoryID', label:'', width:'1', align:'center', formatter: 'checkbox', hideFilter : 'Y'},
			      		  			{key:'DisplayName', label:"<spring:message code='Cache.lbl_CategoryNm'/>",width:'2', align:'center', display:true ,formatter:function () {
				      		  			var html = "";
				      		        	html = String.format("<a href='#' onclick='javascript:subProperty({1},{2});' style='text-decoration:none'>{0}</a>", this.item.DisplayName, this.item.CategoryID, this.item.MemberOf);
			      		        		return html;
			      		        	}},   
			      		      		{key:'Description', label:"<spring:message code='Cache.lbl_Description'/>",width:'3', align:'center', display:true},
										{key:'FolderAlias',  label:"<spring:message code='Cache.lbl_Alias'/>",width:'2',display:true},  
										{key:'SortKey',  label:"<spring:message code='Cache.lbl_PriorityOrder'/>",width:'2',display:true ,sort:'asc'},  
				      		 		{key:'IsUse',  label:"<spring:message code='Cache.lbl_selUse'/>", width:'2',  formatter:function () {
			      		        		var str = "";
					      				str = "<input type='text' kind='switch' on_value='Y' off_value='N' id='AXInputSwitch"+this.item.CategoryID+"' style='width:50px;height:21px;border:0px none;' value='"+this.item.IsUse+"' onchange='updateIsCheck(\""+this.item.CategoryID+"\");' />";
					      				return str;
			      		        	}},   
				      		 	 	{key:'RegDisplayName',  label:"<spring:message code='Cache.lbl_Register'/>",width:'3',display:true},  
				      		 		{key:'RegistDate',  label:"<spring:message code='Cache.lbl_RegistrationDate'/>"+Common.getSession("UR_TimeZoneDisplay"),width:'3',display:true,
											formatter:function(){
												return CFN_TransLocalTime(this.item.RegistDate,_StandardServerDateFormat);
											}				      		 	 		
				      		 		},
				      		 		{key:'MemberOf',  label:'',display:false, hideFilter : 'Y'}
			      		        ]; 
		
		msgHeaderData = communityGridHeader;
		return communityGridHeader;
	}
	
	function SubGridHeader(){
		var communitySubGridHeader = [
										{key:'CU_ID', label:'', width:'1', align:'center', formatter: 'checkbox', hideFilter : 'Y'},
										{key:'CategoryName', label:"<spring:message code='Cache.lbl_CuCategory'/>",width:'2', align:'center', display:true,  sort:'asc'},  
										{key:'CU_Code', label:'Alias',width:'2', align:'center', display:true},
										{key:'CommunityName',  label:"<spring:message code='Cache.lbl_selCommunityName'/>",width:'2',display:true,formatter:function () {
					      		  			var html = "";
					      		        	html = String.format("<a href='#' onclick='javascript:subCommunity({1});' style='text-decoration:none'>{0}</a>", this.item.CommunityName, this.item.CU_ID);
				      		        		return html;
				      		        	}}, 
										{key:'CuAppDetail',  label:"<spring:message code='Cache.lbl_State'/>",width:'1.5',display:true},  
										{key:'CommunityType',  label:"<spring:message code='Cache.lbl_type'/>",width:'1.5',display:true},  
										{key:'CommunityJoin',  label:"<spring:message code='Cache.lbl_JoiningMethod'/>",width:'1.5',display:true},  
										{key:'Point',  label:'Point',width:'1',display:true},  
										{key:'MembersCount',  label:"<spring:message code='Cache.lbl_User_Count'/>",width:'1',display:true},  
										{key:'Grade',  label:"<spring:message code='Cache.lbl_RankTitle'/>",width:'1',display:true},  
										{key:'MsgCount',  label:"<spring:message code='Cache.lbl_noticeCount'/>",width:'1',display:true},  
										{key:'DisplayName',  label:"<spring:message code='Cache.lbl_Establishment_Man'/>",width:'1.5',display:true},  
										{key:'RegProcessDate',  label:"<spring:message code='Cache.lbl_Establishment_Day'/>" +Common.getSession("UR_TimeZoneDisplay"),width:'2',display:true,
											formatter:function(){
												return CFN_TransLocalTime(this.item.RegProcessDate,_StandardServerDateFormat);
											}	
										},
										{key:'CategoryID',  label:'',display:false, hideFilter : 'Y'},
										{key:'CommunityView', label:"<spring:message code='Cache.lbl_view'/>", width:'1',align:'center',display:true,formatter:function() {
											var html = "";
											if (this.item.AppStatus == "RA" || this.item.AppStatus == "RD" || this.item.AppStatus == "UV") {
												html = "";
											} else {
												html = String.format("<input type='button' class='AXButton' onclick='javascript:goCommunitySite({1});' value='{0}'></a>", "<spring:message code='Cache.lbl_view'/>", this.item.CU_ID);
											}
											
											return html;
										}}
			      		        ]; 
		
		msgSubHeaderData = communitySubGridHeader;
		return communitySubGridHeader;
	}
	
	//폴더 그리드 세팅
	function setCommunityGrid(){
		communityGrid.setGridHeader(GridHeader());
		selectCommunityList();				
	}
	
	function setCommunitySubGrid(){
		communitySubGrid.setGridHeader(SubGridHeader());
		selectSubCommunityList();		
	}
	
	function selectCommunityList(){
		//폴더 변경시 검색항목 초기화
		setCommunityGridConfig();
		communityGrid.bindGrid({
			ajaxUrl:"/groupware/layout/community/selectCommunityGridList.do",
			ajaxPars: {
				"DN_ID" : dnID,
				"MemberOf" : MemberOf,
				"CategoryID" : CategoryID
			},
		}); 
	}
	
	function selectSubCommunityList(){
		//폴더 변경시 검색항목 초기화
		setCommunitySubGridConfig();
		communitySubGrid.bindGrid({
			ajaxUrl:"/groupware/layout/community/selectCommunitySubGridList.do",
			ajaxPars: {
				"DN_ID" : dnID,
				"CategoryID" : CategoryID,
				"MemberOf" : MemberOf,
				"pType" : pType,
				"searchValue" : $("#searchValue").val(),
				"searchOption" : $("#communitySeSelBox").val(),
				"communityJoin" : $("#communityJoSeltBox").val(),
				"communityType" : $("#communityTySelBox").val(),
				"communityDetail" : $("#communityCdSelBox").val()
			},
		}); 
	}
	
	function setCommunityGridConfig(){
		var configObj = {
			targetID : "gridDiv",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
			height:"auto",
			page : {
				pageNo: 1,
				pageSize:5
			},
			paging : true,
			colHead:{},
			body:{}
		};
		
		communityGrid.setGridConfig(configObj);
	}
	
	function setCommunitySubGridConfig(){
		var configSubObj = {
			targetID : "subGridDiv",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
			height:"auto",
			page : {
				pageNo: 1,
				pageSize:5
			},
			paging : true,
			colHead:{},
			body:{}
		};
		
		communitySubGrid.setGridConfig(configSubObj);
	}
	
	function updateIsCheck(CategoryID){
		var isUseValue = $("#AXInputSwitch"+CategoryID).val();
		
		$.ajax({
			type:"POST",
			data:{
				"CategoryID" : CategoryID,
				"IsUse" : isUseValue
			},
			url:"/groupware/layout/community/categoryUseChange.do",
			success:function (data) {
				if(data.status == "SUCCESS")
					alert("<spring:message code='Cache.msg_ChangeAlert'/>");
				
				selectCommunityList();
			},
			error:function (error){
				alert(error.message);
			}
		});
		
	}
	
	function gridRefresh(){
		selectCommunityList();
	}
	
	function gridSubRefresh(){
		selectSubCommunityList();
	}
	
	function setCurrentLocation(){
		var locationText= "";
		$.ajax({
			type:"POST",
			data:{
				"DN_ID" : dnID,
				"CategoryID" : CategoryID,
				"pType" : pType
			},
			async : false,
			url:"/groupware/layout/community/setCurrentLocation.do",
			success:function (data) {
				if(data.list != null) {
					if(data.list.length > 0){
						$(data.list).each(function(i,v){
							if(v.num == data.list.length-1){
								locationText += v.DisplayName;
							}else{
								if(data.list.length == 1){
									locationText += v.DisplayName;
								}else{
									locationText += v.DisplayName+" > ";
								}
							}
		    			});
					}
				}
				$("#Classification").text(locationText);
				
			},
			error:function (error){
				  CFN_ErrorAjax("/groupware/layout/community/setCurrentLocation.do", response, status, error);
			}
		});
	}
	
	function event(){
		$("#communityCdSelBox").coviCtrl("setSelectOption", 
				"/groupware/layout/community/selectCommunityBaseCode.do", 
				{"CodeGroup": "CuAppDetail", "DomainID": dnID},
				"<spring:message code='Cache.lbl_selection'/>",
				""
		);
		
		$("#communityTySelBox").coviCtrl("setSelectOption", 
				"/groupware/layout/community/selectCommunityBaseCode.do", 
				{"CodeGroup": "CommunityType", "DomainID": dnID},
				"<spring:message code='Cache.lbl_selection'/>",
				""
		);
		
		$("#communityJoSeltBox").coviCtrl("setSelectOption", 
				"/groupware/layout/community/selectCommunityBaseCode.do", 
				{"CodeGroup": "CommunityJoin", "DomainID": dnID},
				"<spring:message code='Cache.lbl_selection'/>",
				""
		);
		
		$("#searchBtn").on("click",function(){
			selectSubCommunityList();
		});
	}
	function mainProperty(){
		Common.open("","communityProperty","<spring:message code='Cache.lbl_ClassificationAttribute'/>","/groupware/community/communityProperty.do?DN_ID="+dnID+"&CategoryID="+CategoryID+"&MemberOf="+MemberOf+"&pType="+pType+"&mode=E","550px","300px","iframe","false",null,null,true);
	}
	
	function subProperty(_categoryID, _memberOf){
		Common.open("","communityProperty","<spring:message code='Cache.lbl_ClassificationAttribute'/>","/groupware/community/communityProperty.do?DN_ID="+dnID+"&CategoryID="+_categoryID+"&MemberOf="+_memberOf+"&pType=Folder"+"&mode=E","550px","300px","iframe","false",null,null,true);
	}
	
	function addDicCallback(data){
		
		document.getElementById("DIC_Code_ko").value = data.KoFull;
		document.getElementById("DIC_Code_en").value = data.EnFull;
		document.getElementById("DIC_Code_ja").value = data.JaFull;
		document.getElementById("DIC_Code_zh").value = data.ZhFull;
		document.getElementById("hiddenCategory").value = coviDic.convertDic(data);
		
		$("iframe[id^='communityProperty']").contents().find("#txtCategoryName").val(data.KoFull);
		
		Common.Close('DictionaryPopup');
	}
	
	function initDicPopup(){
		
		if($("#hiddenCategory").val() ==  null || $("#hiddenCategory").val() ==  ''){
			$("#hiddenCategory").val($("iframe[id^='communityProperty']").contents().find("#txtCategoryName").val());
		}
			
		return $("#hiddenCategory").val(); 
	}
	
	function TreeData(id, name, target){
		if(target == "P"){
			$("iframe[id^='communityProperty']").contents().find("#txtParentName").val(name);
			$("iframe[id^='communityProperty']").contents().find("#_ParentID").val(id);
		}else if(target == "C"){
			$("iframe[id^='createCommunity']").contents().find("#txtCategoryName").val(name);
			$("iframe[id^='createCommunity']").contents().find("#_ParentID").val(id);
		}
	}
	
	function delProperty(){
		var checkCommunityList = communityGrid.getCheckedList(0);
		if (checkCommunityList.length == 0) {
			Common.Warning("<spring:message code='Cache.lbl_Mail_NoSelectItem' />");
		} else if (checkCommunityList.length > 0) {
			Common.Confirm("<spring:message code='Cache.msg_152' />", "Confirmation Dialog", function (confirmResult) {
				if (confirmResult) {
			    	var paramArr = new Array();
					
			    	paramArr = returnArr(checkCommunityList);
					
					if (paramArr.length > 0) {
						$.ajax({
							url:"/groupware/layout/community/deleteCategory.do",
							type:"post",
							data:{
								"paramArr" : paramArr.toString()
							},
							success:function (data) {
								if(data.status == "SUCCESS"){
									alert("<spring:message code='Cache.msg_50' />");
									gridRefresh();
									setTreeData();
								}else{ 
									alert("<spring:message code='Cache.msg_51' />");
									gridRefresh();
								}
							},
							error:function(response, status, error){
								CFN_ErrorAjax("/groupware/layout/community/deleteCategory.do", response, status, error); 
							}
						}); 
					} else {
						Common.Warning("<spring:message code='Cache.msg_ReadProcessingError' />");
					} 
				} else {
					return false;
				}
				
			});
				
		}else {
			Common.Error("<spring:message code='Cache.msg_ScriptApprovalError' />", "Error");
		}
		
	}
	function returnArr(checkCommunityList){
		var paramArr = new Array();
		$(checkCommunityList).each(function(i, v) {
				var str = v.CategoryID;
				paramArr.push(str);
		});
		
		return paramArr;
	}
	
	function moveProperty(){
	
		var checkCommunityList = communityGrid.getCheckedList(0);
		if (checkCommunityList.length == 0) {
			Common.Warning("<spring:message code='Cache.lbl_Mail_NoSelectItem' />");
		} else if (checkCommunityList.length > 0) {
			    var paramArr = new Array();
					
			    paramArr = returnArr(checkCommunityList);
					
				if (paramArr.length > 0) {
					
					var url = "";
					url += "/groupware/community/CommunityCategoryMove.do?paramArr="+paramArr+"&DN_ID="+dnID;
					
					Common.open("", "ParentCommunityMovePopup", "<spring:message code='Cache.lbl_highDiv'/>", url, "300px", "290px", "iframe", true, null, null, true);
				
				}
		}
	
	}
	
	function addSubProperty(){
		Common.open("","communityProperty","<spring:message code='Cache.lbl_ClassificationAttribute'/>","/groupware/community/communityProperty.do?DN_ID="+dnID+"&pType=Folder"+"&mode=C","550px","300px","iframe","false",null,null,true);
	}
	
	function returnSubArr(checkCommunityList){
		var paramArr = new Array();
		$(checkCommunityList).each(function(i, v) {
				var str = v.CU_ID;
				paramArr.push(str);
		});
		
		return paramArr;
	}
	
	function communityClose(){
		var checkCommunityList = communitySubGrid.getCheckedList(0);
		if (checkCommunityList.length == 0) {
			Common.Warning("<spring:message code='Cache.lbl_Mail_NoSelectItem' />");
		} else if (checkCommunityList.length > 0) {
			var isClose = true;
			$(checkCommunityList).each(function (i, item) {
				if(item.AppStatus == "UF") {
					isClose = false;
					return false;
				}
			});
			
			if(isClose) {
				Common.Confirm("<spring:message code='Cache.msg_SelectedCommunityClosureQ'/>", "Confirmation Dialog", function (confirmResult) {
					if (confirmResult) {
						var paramArr = new Array();
						
						paramArr = returnSubArr(checkCommunityList);
						
						if (paramArr.length > 0) {
							$.ajax({
								url:"/groupware/layout/community/closeCommunity.do",
								type:"post",
								data:{
									"paramArr" : paramArr.toString()
								},
								success:function (data) {
									if(data.status == "SUCCESS"){
										alert("<spring:message code='Cache.msg_Changed'/>");
										setTreeData()
										gridSubRefresh();
									}else{ 
										alert("<spring:message code='Cache.msg_FailProcess'/>");
										setTreeData()
										gridSubRefresh();
									}
								},
								error:function(response, status, error){
									CFN_ErrorAjax("/groupware/layout/community/closeCommunity.do", response, status, error); 
								}
							}); 		
							
						}
					}
				});
			} else {
				Common.Warning("<spring:message code='Cache.msg_ImpossibleCloseCommunity' />");
			}
		}
	}
	
	function communityRestore(){
		var checkCommunityList = communitySubGrid.getCheckedList(0);
		if (checkCommunityList.length == 0) {
			Common.Warning("<spring:message code='Cache.lbl_Mail_NoSelectItem' />");
		} else if (checkCommunityList.length > 0) {			
			var isRestore = true;
			$(checkCommunityList).each(function (i, item) {
				if(item.AppStatus == "RS" || item.AppStatus == "RV" || item.AppStatus == "RA") {
					isRestore = false;
					return false;
				}
			});
			
			if(isRestore) {
				Common.Confirm("<spring:message code='Cache.msg_AreYouRestoreSelectedItemQ'/>", "Confirmation Dialog", function (confirmResult) {
					if (confirmResult) {
						var paramArr = new Array();
						
						paramArr = returnSubArr(checkCommunityList);
						
						if (paramArr.length > 0) {
							$.ajax({
								url:"/groupware/layout/community/restoreCommunity.do",
								type:"post",
								data:{
									"paramArr" : paramArr.toString()
								},
								success:function (data) {
									if(data.status == "SUCCESS"){
										alert("<spring:message code='Cache.msg_Changed'/>");
										gridSubRefresh();
									}else{ 
										alert("<spring:message code='Cache.msg_FailProcess'/>");
										gridSubRefresh();
									}
								},
								error:function(response, status, error){
									CFN_ErrorAjax("/groupware/layout/community/restoreCommunity.do", response, status, error); 
								}
							}); 		
							
						}
					}
				});
			} else {
				Common.Warning("<spring:message code='Cache.msg_ImpossibleResCommunity' />");
			}
		}
	}
	
	function addCommunity(){
		Common.open("","createCommunity","<spring:message code='Cache.lbl_MakeCommunity'/>","/groupware/community/createCommunity.do?DN_ID="+dnID+"&mode=C","620px","550px","iframe","false",null,null,true);
	}
	
	
	function addSubDicCallback(data){
		
		document.getElementById("DIC_Code_ko").value = data.KoFull;
		document.getElementById("DIC_Code_en").value = data.EnFull;
		document.getElementById("DIC_Code_ja").value = data.JaFull;
		document.getElementById("DIC_Code_zh").value = data.ZhFull;
		document.getElementById("hiddenCategory").value = coviDic.convertDic(data);
		
		$("iframe[id^='createCommunity']").contents().find("#txtCommunityName").val(data.KoFull);
		
		Common.Close('DictionaryPopup');
	}
	
	function goDepUser(){
		Common.open("","orgmap_pop","<spring:message code='Cache.lbl_DeptOrgMap'/>","/covicore/control/goOrgChart.do?callBackFunc=depUser_CallBack&type=A1","540px","580px","iframe",true,null,null,true);	
	}
	var aStrDictionary = Common.getDicAll(["lbl_ACL_Allow","lbl_ACL_Denial","lbl_User","lbl_company","lbl_group"]);
	
	function depUser_CallBack(orgData){
		var readAuthJSON =  $.parseJSON(orgData);
		var sCode = "";
		var sDisplayName = "";
		var sObjectType_A = "";
		var sHTML = "";
		var step = $("[name=readAuth]").length;
		var sObjectType = "";
		$(readAuthJSON.item).each(function (i, item) {
			sObjectType = item.itemType
	  		if(sObjectType.toUpperCase() == "USER"){ //사용자
	  			sObjectTypeText = aStrDictionary["lbl_User"]; // 사용자
	  			sObjectType_A = "UR";
	  			sCode = item.AN;//UR_Code
	  			sDisplayName  = CFN_GetDicInfo(item.DN, lang);
	  			sDNCode = item.ETID;; //DN_Code
	  		}else{ //그룹
		  			switch(item.GroupType.toUpperCase()){
		 			 case "COMPANY":
		                sObjectTypeText = aStrDictionary["lbl_company"]; // 회사
		                sObjectType_A = "CM";
		                break;
		            case "JOBLEVEL":
		                //sObjectTypeText = "직급";
		                //sObjectType_A = "JL";
		                //break;
		            case "JOBPOSITION":
		                //sObjectTypeText = "직위";
		                //sObjectType_A = "JP";
		                //break;
		            case "JOBTITLE":
		                //sObjectTypeText = "직책";
		                //sObjectType_A = "JT";
		                //break;
		            case "MANAGE":
		                //sObjectTypeText = "관리";
		                //sObjectType_A = "MN";
		                //break;
		            case "OFFICER":
		                //sObjectTypeText = "임원";
		                //sObjectType_A = "OF";
		                //break;
		            case "DEPT":
		                sObjectTypeText = aStrDictionary["lbl_group"]; // 그룹
		                //sObjectTypeText = "부서";
		                sObjectType_A = "GR";
		                break;
		    	}
		
		  		sCode = item.AN;
				sDisplayName = CFN_GetDicInfo(item.DN, lang);
				sDNCode = item.ETID;
		  		
	  		}
		});
		$("iframe[id^='createCommunity']").contents().find("#txtOperator").val(sDisplayName);
		$("iframe[id^='createCommunity']").contents().find("#operatorCode").val(sCode);
		
	}
	
	function subCommunity(id){
		Common.open("","createCommunity","<spring:message code='Cache.lbl_communityInFoM'/>","/groupware/community/modifyCommunity.do?DN_ID="+dnID+"&mode=E"+"&CU_ID="+id,"640px","550px","iframe","false",null,null,true);
	}
	
	function sendMessage(){
		var notiMail = "";
		var todoList = "";
		
		if($('input:checkbox[id="chkNoticeMail"]').is(":checked") == true){
			notiMail = 'Y';
		}else{
			notiMail = 'N';
		}
		
		if($('input:checkbox[id="chkNoticeTODOLIST"]').is(":checked") == true){
			todoList = 'Y';
		}else{
			todoList = 'N';
		}
		
		var checkCommunityList = communitySubGrid.getCheckedList(0);
		if (checkCommunityList.length == 0) {
			Common.Warning("<spring:message code='Cache.lbl_Mail_NoSelectItem' />");
		} else if (checkCommunityList.length > 0) {
			 var paramArr = new Array();
			 paramArr = returnArr(checkCommunityList);
			 
			 Common.open("","todoOperator","<spring:message code='Cache.lbl_MessageInputDialog'/>","/groupware/community/todoOperator.do?DN_ID="+dnID+"&paramArr="+paramArr+"&notiMail="+notiMail+"&todoList="+todoList,"260px","140px","iframe","false",null,null,true);
		}
	}
	
	function goCommunitySite(community){
		 var specs = "left=10,top=10,width=1050,height=900";
		 specs += ",toolbar=no,menubar=no,status=no,scrollbars=no,resizable=no";
		 window.open("/groupware/layout/userCommunity/communityMain.do?C="+community, "community", specs);
	}

</script>