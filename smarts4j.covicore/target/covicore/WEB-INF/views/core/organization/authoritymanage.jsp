<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code="Cache.CN_215"/></span>
	<!-- TODO 초기 페이지로 설정 향후 개발 (미구현 사항으로 숨김처리) -->
	<%-- <a href="#" class="set_box">
		<span class="set_initialpage"><p><spring:message code="Cache.btn_SettingFirstPage"/></p></span>
	</a> --%>
</h3>

<form>
	<div class="AXTabs" style="display:none;">
		<div id="divTabTray" class="AXTabsTray" style="height:30px">
			<a id="groupSetTab" onclick="clickTab(this);" class="AXTab on" value="divgroup"><spring:message code='Cache.lbl_group' /></a> <!-- 부서 -->
			<a id="userSetTab"  onclick="clickTab(this);" class="AXTab" value="divuser"><spring:message code='Cache.lbl_User'/></a> <!-- 사용자 -->
		</div>
	</div>
	<div id="divgroup" style="margin-top: 5px; padding-top: 5px;">
		<div style="width:100%;">
			<div id="topitembar_1" class="topbar_grid">
				<input type="button" id="btnGroupRefresh" value="<spring:message code="Cache.lbl_Refresh"/>"  onclick="Refresh();" class="AXButton BtnRefresh"/> <!-- 새로고침 -->
				<input type="button" id="btnGroupAttribute" value="<spring:message code="Cache.lbl_Property"/>"  onclick="editOrggroup();" class="AXButton" style="display:none;"/> <!-- 속성 -->
				<input type="button" id="btnGroupAdd" value="<spring:message code="Cache.btn_Add"/>"  onclick="addOrggroup(); return false;" class="AXButton BtnAdd" /> <!-- 추가 -->
				<input type="button" id="btnGroupDelete" value="<spring:message code="Cache.btn_delete"/>"  onclick="deleteOrggroup();" class="AXButton BtnDelete"/> <!-- 삭제 -->
				<input type="button" id="btnGroupExcel" value="<spring:message code="Cache.btn_ExcelDownload"/>"  onclick="excelDownload('group');" class="AXButton BtnExcel"/> <!-- 엑셀 다운로드 -->
				<!-- <input type="button" id="btnCacheReload" value="<spring:message code="Cache.btn_CacheApply"/>"  onclick="syncSelectDomain();" class="AXButton"/>  --> <!-- 캐시 초기화 -->
				<!-- 미구현 -->
				<!-- <input type="button" value="이동" onclick="moveMenu();"class="AXButton"/>
				<input type="button" value="<spring:message code="Cache.lbl_OpenAll"/>" onclick="openAllMenu();"class="AXButton"/>
				<input type="button" value="<spring:message code="Cache.lbl_CloseAll"/>" onclick="closeAllMenu();"class="AXButton"/>
				<input type="button" value="<spring:message code="Cache.btn_CacheApply"/>" onclick="applyCache();"class="AXButton"/> -->
			</div>
			<div>
				<!-- 그룹 그리드 -->
				<div id="orggroupgrid"></div>
			</div>
		</div>
	</div>

	<div id="divuser" style="margin-top: 5px; padding-top: 5px; display: none;">
		<div style="width:100%;">
			<div id="topitembar_2" class="topbar_grid">
				<input type="button"  id="btnUserAdd" value="<spring:message code="Cache.btn_Add"/>" onclick="addOrgUser(); return false;" class="AXButton BtnAdd" /> <!-- 추가 -->
				<input type="button"  id="btnUserDelete" value="<spring:message code="Cache.btn_delete"/>" onclick="deleteOrgUser();" class="AXButton BtnDelete"/> <!-- 삭제 -->
				<input type="button"  id="btnUserExcel" value="<spring:message code="Cache.btn_ExcelDownload"/>" onclick="excelDownload('user');" class="AXButton BtnExcel" style="display: none;"/> <!-- 엑셀 다운로드 -->
				<!-- 미구현 -->
				<!-- <input type="button" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"class="AXButton"/>
				<input type="button" value="<spring:message code="Cache.lbl_Property"/>" onclick="editOrggroup();" class="AXButton" /> 
				<input type="button" value="이동" onclick="moveMenu();"class="AXButton"/>
				<input type="button" value="<spring:message code="Cache.lbl_OpenAll"/>" onclick="openAllMenu();"class="AXButton"/>
				<input type="button" value="<spring:message code="Cache.lbl_CloseAll"/>" onclick="closeAllMenu();"class="AXButton"/>
				<input type="button" value="<spring:message code="Cache.btn_CacheApply"/>" onclick="applyCache();"class="AXButton"/> -->
				<!-- <input type="button" id="btnCacheReload" value="<spring:message code="Cache.btn_CacheApply"/>"  onclick="syncSelectDomain();" class="AXButton"/>  --> <!-- 캐시 초기화 -->
			</div>
			<div>
				<!-- 사용자 그리드 -->
				<div id="orgusergrid"></div>
			</div>
		</div>
	</div>
</form>

<script>

	var isMailDisplay = true;
	var setBtnDisplayGroup = ""; 
	var setBtnDisplayUser = "";
	
	var myGroupGrid;
	var myUserGrid;
	
	var selectedGroupCode = "";
	
	// 개별호출 일괄처리	
	var lang = Common.getSession("lang");
	Common.getBaseConfigList(["IsSyncMail"]);
	
	
	$(document).ready(function () {

		myGroupGrid = new coviGrid();
		myUserGrid = new coviGrid();

		//기초설정에 따른 메일 표기 여부
		if(coviCmn.configMap["IsSyncMail"] == null ||  coviCmn.configMap["IsSyncMail"] == 'N'){
			$("#IsMailType").closest('span').css("display","none");
			isMailDisplay = false;
		}

		setGroupGrid();
        bindGrid('group','');
	});
	
	
	function gotoSelectedCategory(groupCode) {
		var href = $(location).attr('href');
		href = href.replace($.urlParam("gr_code"), groupCode)
		$(location).attr('href', href);
	}

	function setGroupGrid(){
		myGroupGrid.setGridHeader(
				 [
						{key:'chk', label:'chk', width:'20', align:'center', formatter: 'checkbox'},
	  					{key:'GroupCode', label:"<spring:message code='Cache.lbl_authorityCode'/>" , width:'50', align:'center', formatter : function(){
		  					return "<a href='#' onclick='editOrggroup(\"" + this.item.GroupCode +"\", \""+ "Authority" +"\"); return false;'>"+ "<span name='code'>" + this.item.GroupCode + "</span>"+"</a>";
	  					}},
 					{key:'GroupName',  label:"<spring:message code='Cache.lbl_authorityCodeNm'/>" , width:'70', align:'center'}, //표시이름
 					{key:'SortKey',  label:"<spring:message code='Cache.lbl_PriorityOrder'/>" , width:'40', align:'center'}, //우선순의
 					{key:'IsUse', label:"<spring:message code='Cache.lbl_IsUse'/>" , width:'50', align:'center', formatter : function() { //사용여부
 						return "<input type='text' kind='switch' on_value='Y' off_value='N' id='IsUse"+this.item.GroupCode+"' style='width:50px;height:20px;border:0px none;' value='"+this.item.IsUse+"' onchange='updateIsUse(\""+this.item.GroupCode+"\", \"group\", \""+this.item.GroupType+"\");' />";        	    
 					}},
 					{key:'Description',  label:"<spring:message code='Cache.lbl_Description'/>" , width:'90', align:'center'}, //설명
 					{key:'SetUser',  label:"<spring:message code='Cache.lbl_GroupMember'/>" , width:'50', align:'center', formatter : function() {
 							return "<a href='#' onclick='setUser(\"" + this.item.GroupCode +"\"); return false;'>"+ "<span name='code'>Member</span>"+"</a>";
 					}} //설명
					]
		);
		setGroupGridConfig();
	}
	
	function setUserGrid(){
		myUserGrid.setGridHeader(
				[{key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox'},
	                  {key:'Type',  label:'<spring:message code="Cache.lbl_Gubun"/>', width:'90', align:'center', 
	                	  formatter:function () {
		      					if(this.item.Type.toUpperCase() == "USER") 
		      						return "<a href='#' onclick='editOrgUser(\""+ this.item.Code +"\"); return false;'>"+this.item.Type+"</a>";
	      						else
		      						return "<a href='#' onclick='editOrggroup(\""+ this.item.Code +"\", \"" + 'Dept' + "\"); return false;'>"+this.item.Type+"</a>";
		      				}},
    				  {key:'Code', label:'<spring:message code="Cache.lbl_Code"/>', width:'90', align:'center',
		      				formatter:function () {
		      					if(this.item.Type.toUpperCase() == "USER") 
		      						return "<a href='#' onclick='editOrgUser(\""+ this.item.Code +"\"); return false;'>"+this.item.Code+"</a>";
	      						else
		      						return "<a href='#' onclick='editOrggroup(\""+ this.item.Code +"\", \"" + 'Dept' + "\"); return false;'>"+this.item.Code+"</a>";
		      				}},
	                  {key:'CodeName',  label:'<spring:message code="Cache.lbl_username"/>', width:'70', align:'center',
	                	  formatter:function () {
		      					if(this.item.Type.toUpperCase() == "USER") 
		      						return "<a href='#' onclick='editOrgUser(\""+ this.item.Code +"\"); return false;'>"+CFN_GetDicInfo(this.item.CodeName, lang)+"</a>";
	      						else
		      						return "<a href='#' onclick='editOrggroup(\""+ this.item.Code +"\", \"" + 'Dept' + "\"); return false;'>"+CFN_GetDicInfo(this.item.CodeName, lang)+"</a>";
		      				}},
		      		  {key:'MailAddress', label:'<spring:message code="Cache.lbl_Mail"/>', width:'80', align:'center',
			                	  formatter:function () {
				      					if(this.item.Type.toUpperCase() == "USER") 
				      						return "<a href='#' onclick='editOrgUser(\""+ this.item.Code +"\"); return false;'>"+this.item.MailAddress+"</a>";
			      						else
				      						return "<a href='#' onclick='editOrggroup(\""+ this.item.Code +"\", \"" + 'Dept' + "\"); return false;'>"+this.item.MailAddress+"</a>";
		      						}
		      		  }]
		);
		setMemberGridConfig();
	}
	
	function setGroupGridConfig(){
		var configObjg = {
				targetID : "orggroupgrid",
				height:"auto",
				xscroll:true,
				page : {
					pageNo:1,
					pageSize:5
				},
				paging : true,
				sort:false,
				body:{}
			};
		
		myGroupGrid.setGridConfig(configObjg);
	}
	
	function setMemberGridConfig(){
		var configObjm = {
				targetID : "orgusergrid",
				height:"auto",
				xscroll:true,
				page : {
					pageNo:1,
					pageSize:10
				},
				paging : true,
				sort:false,
				body:{}
			};
		
		myUserGrid.setGridConfig(configObjm);
	}
	
	function bindGrid(type, pStrGR_Code) {
		var url;
		var gr_code;
		var grouptype;
		var domainCode;
		var sortBy;
		var params;
		
		if(type == null || type == undefined) {
			type = "group";
		}
		
		switch(type) {
		case "group":
			url = "/covicore/admin/orgmanage/getAuthoritylist.do";
			gr_code = $.urlParam('gr_code') != null ? $.urlParam('gr_code') : "";
			sortBy = myGroupGrid.getSortParam();
			params = {
					"domain" : $("#domainCodeSelectBox :selected").val(),
					"grouptype" : "Authority",
					"IsUse" : "",
					"IsHR" : "",
					"IsMail" : "",
					"searchText" : "",
					"searchType" : "",
					"sortBy" : sortBy
			};
			myGroupGrid.bindGrid({
	 			ajaxUrl:url,
	 			ajaxPars: params
			});
			break;
		case "user":
			url = "/covicore/admin/orgmanage/getgroupmemberlist.do";
			sortBy = myUserGrid.getSortParam();
			params = {
					"gr_code":pStrGR_Code,
					"domainCode":$("#domainCodeSelectBox :selected").val(),
					"sortBy":sortBy
			};
			myUserGrid.bindGrid({
	 			ajaxUrl:url,
	 			ajaxPars: params
			});
			break;
		}
	}
	
	// 사용여부 스위치 버튼에 대한 값 변경
	function updateIsUse(pCode, pType,pGroupType){
		var now = new Date();
		var isUseValue = $("#IsUse"+pCode).val();
		var sGroupType = "";
		now = XFN_getDateTimeString("yyyy-MM-dd HH:mm:ss",now);
		
		var sURL = "";
		
		if(pType == "group") {
			sURL = "/covicore/admin/organization/updateisusegroup.do";
			sGroupType = pGroupType;
		} else {
			sURL = "/covicore/admin/organization/updateisuseuser.do";
		}
		
		$.ajax({
			type:"POST",
			data:{
				"Code" : pCode,
				"Type"     : sGroupType,
				"IsUse" : isUseValue,
				"ModID" : "",				// 세션 값
				"ModDate" : now
			},
			url:sURL,
			success:function (data) {
				if(data.result == "ok")
					Common.Inform("<spring:message code='Cache.msg_137'/>", "Information Dialog", function(result) {
						if(result) {
							myGroupGrid.reloadList();
							myUserGrid.reloadList();
						}
					});
			},
			error:function(response, status, error){
				CFN_ErrorAjax(sURL, response, status, error);
			}
		});
	}
	
	// 인사연동여부 스위치 버튼에 대한 값 변경
	function updateIsHR(pCode, pType){
		var now = new Date();
		var isHRValue = $("#IsHR"+pCode).val();
		now = XFN_getDateTimeString("yyyy-MM-dd HH:mm:ss",now);
		
		var sURL = "";
		
		sURL = "/covicore/admin/organization/updateishruser.do";
		
		$.ajax({
			type:"POST",
			data:{
				"Code" : pCode,
				"IsHR" : isHRValue,
				"ModID" : "",				// 세션 값
				"ModDate" : now
			},
			url:sURL,
			success:function (data) {
				if(data.result == "ok")
					Common.Inform("<spring:message code='Cache.msg_137'/>", "Information Dialog", function(result) {
						if(result) {
							myGroupGrid.reloadList();
							myUserGrid.reloadList();
						}
					});
			},
			error:function(response, status, error){
				CFN_ErrorAjax(sURL, response, status, error);
			}
		});
	}
	
	// 메일사용여부 스위치 버튼에 대한 값 변경
	function updateIsMail(pCode, pType){
		var now = new Date();
		var isMailValue = $("#IsMail"+pCode).val();
		now = XFN_getDateTimeString("yyyy-MM-dd HH:mm:ss",now);
		
		var sURL = "";
		
		if(pType == "group") {
			sURL = "/covicore/admin/organization/updateismailgroup.do";
		} else {
			sURL = "/covicore/admin/organization/updateismailuser.do";
		}
		
		$.ajax({
			type:"POST",
			data:{
				"Code" : pCode,
				"IsMail" : isMailValue,
				"ModID" : "",				// 세션 값
				"ModDate" : now
			},
			url:sURL,
			success:function (data) {
				if(data.result == "ok")
					Common.Inform("<spring:message code='Cache.msg_137'/>", "Information Dialog", function(result) {
						if(result) {
							myGroupGrid.reloadList();
							myUserGrid.reloadList();
						}
					});
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/admin/organization/updateismailgroup.do", response, status, error);
			}
		});
	}

	function Refresh() {
		myGroupGrid.reloadList();
		myUserGrid.reloadList();
	}
	
	function addOrggroup(){
		var sOpenName = "divgroupInfo";
		var sGR_Code = "";
		var sDN_Code = $("#domainCodeSelectBox :selected").val();

		var sURL = "/covicore/authoritymanageinfopop.do";
		sURL += "?domainCode=" + sDN_Code;
		sURL += "&mode=add";
		sURL += "&OpenName=" + sOpenName;
		
		var sTitle = "";
		sTitle = "<spring:message code='Cache.lbl_AuthorityAdd'/>"  + " ||| " + "<spring:message code='Cache.msg_AuthorityAdd'/>" ;

		var sWidth = "530px";
		var sHeight = "450px";
		Common.open("", sOpenName, sTitle, sURL, sWidth, sHeight, "iframe", false, null, null, true);
	}
	
	function deleteOrggroup(){
		var deleteObject = myGroupGrid.getCheckedList(0);
		if(deleteObject.length == 0 || deleteObject == null){
			Common.Inform("<spring:message code='Cache.msg_selectTargetDelete'/>"); 
			return false;
		}else{
			Common.Confirm("<spring:message code='Cache.msg_152'/>", "Confirmation Dialog", function (result) {
				if(result) {
					var deleteSeq = "";
					
					for(var i=0; i < deleteObject.length; i++){
						if(i==0){
							deleteSeq = deleteObject[i].GroupCode;
						}else{
							deleteSeq = deleteSeq + "," + deleteObject[i].GroupCode;
						}
					}
					
					$.ajax({
						type:"POST",
						data:{
							"deleteData" : deleteSeq
						},
						url:"/covicore/admin/organization/deletegroup.do",
						success:function (data) {
							if(data.status == "FAIL") {
								if(data.message.indexOf("|")) Common.Warning(Common.getDic(data.message.split("|")[0]).replace("{0}",data.message.split("|")[1]));
								else Common.Warning(data.message);
							} else {
								Common.Inform("<spring:message code='Cache.msg_138'/>", "Information Dialog", function(result) {
									if(result) {
										setGroupGrid();
								        bindGrid('group','');
									}
								});
							}
						},
						error:function(response, status, error){
							CFN_ErrorAjax("/covicore/admin/organization/deletegroup.do", response, status, error);
						}
					});
				}
			});
		}
	}
	
	function editOrggroup(pStrGR_Code, pStrGroupType){
		var sOpenName = "divgroupInfo";
		var sGR_Code = pStrGR_Code == undefined ? $.urlParam("gr_code") : pStrGR_Code;
		var sDN_Code = $("#domainCodeSelectBox :selected").val();
		var sGroupType = pStrGroupType == undefined ? $.urlParam("group_type") : pStrGroupType;

		var sURL = "/covicore/authoritymanageinfopop.do";
		sURL += "?gr_code=" + sGR_Code;
		sURL += "&domainCode=" + sDN_Code;
		sURL += "&GroupType=" + sGroupType;
		sURL += "&mode=modify";
		sURL += "&OpenName=" + sOpenName;

		var sTitle = "";
		sTitle = "<spring:message code='Cache.lbl_authorityInfo'/>"  + " ||| " + "<spring:message code='Cache.msg_authorityInfo'/>" ;

		var sWidth = "530px";
		var sHeight = "450px";
		Common.open("", sOpenName, sTitle, sURL, sWidth, sHeight, "iframe", false, null, null, true);
	}
	
	function setUser(pStrGR_Code) {
		selectedGroupCode = pStrGR_Code;
		if(pStrGR_Code != null && pStrGR_Code != undefined) {
			$("#divuser").show();
			setUserGrid();
			bindGrid('user', pStrGR_Code);
		}
	}
	
	function addOrgUser(){
		//type=B9 > user만 선택 가능
		Common.open("","orgmap_pop","<spring:message code='Cache.lbl_DeptOrgMap'/>","/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod2&type=B9","1060px","580px","iframe",true,null,null,true);
	}
	
	var _CallBackMethod2 = function(data) { //조직도 콜백함수 구현

		var urCodeList = ""; 
        var grCodeList = "";   
        
		var jsonData = JSON.parse(data);
		
		jsonData.item.forEach(function(obj){
			// 선택된 UR 코드를 꺼낸다.
			 var sObjectType = $(obj).attr("itemType");
			 if (sObjectType.toUpperCase() == "USER") {
	                urCodeList += $(obj).attr("UserCode") + ";";
	          }
		});
		
		jsonData.item.forEach(function(obj){
			// 선택된 GR 코드를 꺼낸다.
			 var sObjectType = $(obj).attr("itemType");
			 if (sObjectType.toUpperCase() == "GROUP") {
				 grCodeList += $(obj).attr("GroupCode") + ";";
	         }
		});			 
	     
		$.ajax({
			type:"POST",
			data:{
				"GroupCode" : selectedGroupCode, //$.urlParam('gr_code'),
				"URList" : urCodeList,
				"GRList" : grCodeList
			},
			url:"/covicore/admin/organization/addgroupmember.do",
			success:function (data) {
				if(data.status == "FAIL") {
					Common.Warning(data.message);
				} else {
					Common.Inform("<spring:message code='Cache.msg_37'/>", "Information Dialog", function(result) {
						if(result) {
							myUserGrid.reloadList();
						}
					});
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/admin/organization/addgroupmember.do", response, status, error);
			}
		});
	}
	
	function deleteOrgUser(){
		
		var checkCheckList 		= myUserGrid.getCheckedList(0);// 체크된 리스트 객체
		var TargetUserTemp 		= []; //체크된 항목 저장용 배열
		var TargetUser 				= ""; //체크된 항목을 문장으로 나열 (A;B; . . ;)
		var TargetGroupTemp 		= []; //체크된 항목 저장용 배열
		var TargetGroup 				= ""; //체크된 항목을 문장으로 나열 (A;B; . . ;)

		if(checkCheckList.length == 0){
			Common.Inform("<spring:message code='Cache.msg_apv_003'/>"); 
			return false;
		}else if(checkCheckList.length > 0){

			for(var i = 0; i < checkCheckList.length; i++){
				if(checkCheckList[i].Type.toUpperCase() == "USER"){
					TargetUserTemp.push(checkCheckList[i].MemberID);
				} else {
					TargetGroupTemp.push(checkCheckList[i].MemberID);
				}
			}
			
			TargetUser = TargetUserTemp.join(",");
			TargetGroup = TargetGroupTemp.join(",");
			
			Common.Confirm("<spring:message code='Cache.msg_apv_093'/>" , "Inform", function (result) { //삭제하시겠습니까?
				if (result) {
					$.ajax({
						url: "/covicore/admin/orgmanage/deletegroupmember.do",
						type:"post",
						data:{
			 				"TargetUser": TargetUser,
			 				"TargetGroup": TargetGroup
						},
						async:false,
						success:function (res) {
							myUserGrid.reloadList();
						},
						error:function(response, status, error){
							CFN_ErrorAjax("/covicore/admin/orgmanage/deletegroupmember.do", response, status, error);
						}
					});
				}
			}); 
		}else{
			Common.Inform("<spring:message code='Cache.msg_ScriptApprovalError'/>"); 
			return false;
		}
	}
	
	function editOrgUser(pStrUR_Code){
		var sOpenName = "divUserInfo";
		var sUR_Code = pStrUR_Code;
		var sDN_Code = $("#domainCodeSelectBox :selected").val();
		
		var sURL = "/covicore/UserManageInfoPop.do";
		sURL += "?userCode=" + sUR_Code
		sURL += "&domainCode=" + sDN_Code;
		sURL += "&mode=modify";
		sURL += "&OpenName=" + sOpenName;
		
		
										
		var sTitle = "";
		sTitle = "<spring:message code='Cache.lbl_OrganizationUserEdit'/>"  + " ||| " + "<spring:message code='Cache.msg_OrganizationUserEdit'/>" ;

		var sWidth = "1000px";
		var sHeight = "600px";
		Common.open("", sOpenName, sTitle, sURL, sWidth, sHeight, "iframe", false, null, null, true);
	}
	
	/*
	<잔여사항>
	1. 위로, 아래로 - SortKey 값 업데이트로 대체
	2. 이동 - 필요 시 MemberOf 값 업데이트로 대체 가능
	3. 전체 열기, 닫기 
	4. 다국어 처리
	*/
	// 위로 버튼 클릭시 실행되며, 해당 항목을 위로 이동합니다.
    function moveUp(type) {
		
		var checkCheckList = "";
		var gridObj = myGrid;
		/* if(type == "group") {
			gridObj = groupGrid;
		} else if(type == "user") {
			gridObj = userGrid;
		} */
		checkCheckList = gridObj.getCheckedList(0);// 체크된 리스트 객체
		if(checkCheckList.length == 0){
			Common.Inform("<spring:message code='Cache.msg_apv_003'/>"); 
			return false;
		}else if(checkCheckList.length > 0){

	        var sCode_A = 0;
	        var sCode_B = 0;
	
	        var oPrevTR = null;
	        var oNowTR = null;
	
	        var oResult = null;
	        var bSucces = true;
	        var sResult = "";
	        var sErrorMessage = "";
	
	        var nLength = gridObj.list.length;
	        for (var i = 0; i < nLength; i++) {
	        	if (!gridObj.list[i].___checked[0]) {
	                continue;
	            }
	
	            // 현재 행: 위에서부터 선택 되어 있는 행 찾기
	            oNowTR = gridObj.list[i];
	
	            // 이전 행 찾기: 현재 행 기준 위에서 선택 안되어 있는 행 찾기
	            oPrevTR = null;
	            for (var j = i - 1; j >= 0; j--) {
	                if (gridObj.list[j].GroupCode == undefined && gridObj.list[j].UserCode == undefined) {
	                    break;
	                }
	                if (gridObj.list[j].___checked[0]) {
	                    continue;
	                }
	                oPrevTR = gridObj.list[j];
	                break;
	            }
	            if (oPrevTR == null) {
	                continue;
	            }
				
	            if(type == "group") {
		            sCode_A = oNowTR.GroupCode;
		            sCode_B = oPrevTR.GroupCode;
	            } else if(type == "user") {
	            	sCode_A = oNowTR.UserCode;
		            sCode_B = oPrevTR.UserCode;
	            }
	
	            $.ajax({
					url: "/covicore/admin/orgmanage/movesortkey_groupuser.do",
					type:"post",
					data:{
		 				"pStrCode_A":sCode_A,
		 				"pStrCode_B":sCode_B,
		 				"pStrType":type
						},
					async:false,
					success:function (res) {
						gridObj.reloadList();
						//window.location.reload();
					},
					error:function(response, status, error){
						CFN_ErrorAjax("/covicore/admin/orgmanage/movesortkey_groupuser.do", response, status, error);
					}
				});
			}
	    }
	}
	
	// 아래로 버튼 클릭시 실행되며, 해당 항목을 아래로 이동합니다.
    function moveDown(type) {
		
    	var checkCheckList = "";
		var gridObj = myGrid;
		/* if(type == "group") {
			gridObj = groupGrid;
		} else if(type == "user") {
			gridObj = userGrid;
		} */
		var checkCheckList 		= gridObj.getCheckedList(0);// 체크된 리스트 객체
		if(checkCheckList.length == 0){
			Common.Inform("<spring:message code='Cache.msg_apv_003'/>"); 
			return false;
		}else if(checkCheckList.length > 0){

	        var sCode_A = 0;
	        var sCode_B = 0;
	
	        var oNextTR = null;
	        var oNowTR = null;
	
	        var oResult = null;
	        var bSucces = true;
	        var sResult = "";
	        var sTemp = "";
	        var sErrorMessage = "";
	
	        var nLength = gridObj.list.length;
	        for (var i = nLength-1; i >= 0; i--) {
	        	if (!gridObj.list[i].___checked[0]) {
	                continue;
	            }
	
	         // 현재 행: 아래에서부터 선택되어 있는 행 찾기
	            oNowTR = gridObj.list[i];
	
	         // 다음 행 찾기: 현재 행 기준 아래에서 선택 안되어 있는 행 찾기
	            oNextTR = null;
	            for (var j = i + 1; j < nLength; j++) {
	                if (gridObj.list[j].GroupCode == undefined && gridObj.list[j].UserCode == undefined) {
	                    break;
	                }
	                if (gridObj.list[j].___checked[0]) {
	                    continue;
	                }
	                oNextTR = gridObj.list[j];
	                break;
	            }
	            if (oNextTR == null) {
	                continue;
	            }
	
	            if(type == "group") {
		            sCode_A = oNowTR.GroupCode;
		            sCode_B = oNextTR.GroupCode;
	            } else if(type == "user") {
	            	sCode_A = oNowTR.UserCode;
		            sCode_B = oNextTR.UserCode;
	            }
	
	            $.ajax({
					url: "/covicore/admin/orgmanage/movesortkey_groupuser.do",
					type:"post",
					data:{
		 				"pStrCode_A" : sCode_A,
		 				"pStrCode_B" : sCode_B,
		 				"pStrType":type
						},
					async:false,
					success:function (res) {
						gridObj.reloadList();
						//window.location.reload();
					},
					error:function(response, status, error){
						CFN_ErrorAjax("/covicore/admin/orgmanage/movesortkey_groupuser.do", response, status, error);
					}
				});
			}
	    }
	}
	
  	//엑셀 다운로드
	function excelDownload(){	

		var checkCheckList 		= myGroupGrid.getCheckedList(0);// 체크된 리스트 객체
		if(checkCheckList.length == 0) {
			Common.Inform("<spring:message code='Cache.msg_SelectGroup2'/>", "Information Dialog");
			return;
		}
		var GroupCodeList = '';
		
		for(var i = 0; i < checkCheckList.length; i++){
	   	   	GroupCodeList += checkCheckList[i].GroupCode;
			if(i<checkCheckList.length-1)
				GroupCodeList +=";";
		}
		
		
		
		Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage'/>", "Confirmation Dialog", function(result){
       		if(result){
    			var type = "groupmember";
       			var headerName = getHeaderInfoForExcel();
    			var	sortKey = "SortKey";
    			var	sortWay = "ASC";		
    			
    			location.href = "/covicore/admin/orgmanage/orglistexceldownload.do?sortColumn=" + sortKey + "&sortDirection=" + sortWay + "&type=" + type + "&groupCode=" + GroupCodeList +"&groupType=Authority&companyCode=" + $("#domainCodeSelectBox :selected").val() + "&headerName=" + encodeURI(encodeURIComponent(headerName));
       		}
		});
	}

	
	function getHeaderInfoForExcel(){
		var msgHeaderData = getGridHeader();
		var returnLabelStr = "";
		
	   	for(var i=0;i<msgHeaderData.length; i++){
	   	   	returnLabelStr += msgHeaderData[i].label;
			if(i<msgHeaderData.length-1)
				returnLabelStr +=";";
		}
		
		return returnLabelStr;
	}
	
	//Grid Header 항목 시작
	function getGridHeader(){
		var headerData= [
							{key:'GroupCode', label:"<spring:message code='Cache.lbl_authorityCode'/>" },
							{key:'GroupName',  label:"<spring:message code='Cache.lbl_authorityCodeNm'/>"},
							{key:'SortKey',  label:"<spring:message code='Cache.lbl_PriorityOrder'/>"}, 
							{key:'IsUse', label:"<spring:message code='Cache.lbl_IsUse'/>"},
							{key:'Description',  label:"<spring:message code='Cache.lbl_Description'/>"}, 
							
							
							{key:'Type',  label:'<spring:message code="Cache.lbl_Gubun"/>'},
							{key:'MemberCode',  label:'<spring:message code="Cache.lbl_User_Id"/>'},
							{key:'MemberName', label:'<spring:message code="Cache.lbl_User"/>'},
							{key:'MemberMailAddress', label:'<spring:message code="Cache.lbl_Mail"/>'}
  
						];
	
		return headerData;
	}
	
	function syncSelectDomain() {
		var selDomainCode = $("#domainCodeSelectBox").val();
		Common.Progress("<spring:message code='Cache.msg_Processing'/>");
		$.post("/covicore/aclhelper/refreshSyncKeyAllByCode.do", {"DomainCode" : selDomainCode}, function(data) {
			Common.AlertClose();
		});
	}
</script>