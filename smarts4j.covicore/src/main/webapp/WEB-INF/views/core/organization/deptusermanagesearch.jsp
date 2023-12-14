<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<h3 class="con_tit_box">
   <span class="con_tit"><spring:message code='Cache.lbl_search'/></span>
	<!-- TODO 초기 페이지로 설정 향후 개발 (미구현 사항으로 숨김처리) -->
	<%-- <a href="#" class="set_box">
		<span class="set_initialpage"><p><spring:message code="Cache.btn_SettingFirstPage"/></p></span>
	</a> --%>
</h3>

<div class="topbar_grid">
	<spring:message code="Cache.lbl_DepUser"/>&nbsp;
	<select id="selDeptUser" onchange="changeSearchType(this);" class="AXSelect">
		<option value="User" selected><spring:message code="Cache.lbl_User"/></option>
		<option value="Dept" ><spring:message code="Cache.lbl_dept"/></option>
	</select>&nbsp;
	<spring:message code="Cache.lbl_IsUse"/>&nbsp;
	<select id="selIsUse" class="AXSelect">
		<option value=""><spring:message code="Cache.lbl_all"/></option>
		<option value="Y"><spring:message code="Cache.lbl_Use"/></option>
		<option value="N"><spring:message code="Cache.lbl_noUse"/></option>
	</select>&nbsp;
	<spring:message code="Cache.lbl_apv_searchcomment"/>&nbsp;
	<select id="selSearchType" class="AXSelect"></select>&nbsp;
	<input type="text" class="AXInput" id="txtSearchText" onKeypress="if(event.keyCode==13) {clickSearchButton(); return false;}">
	<input type="button" id="btnSearch" value="<spring:message code='Cache.btn_search' />" onclick="clickSearchButton();" class="AXButton" > <!-- 검색 -->
</div>
<form>
	<div style="width:100%;">
		<div>
			<!-- 부서 그리드 -->
			<p id="pNavigation"></p>
			<div id="orgdeptgrid"></div>
		</div>
	</div>
</form>

<form>
	<div style="width:100%;">
		<div>
			<!-- 사용자 그리드 -->
			<p id="pPagingNum"></p>
			<div id="orgusergrid"></div>
		</div>
	</div>
</form>

<script>
	var isMailDisplay = true;
	var mode = $.urlParam('mode');
	
	$.urlParam = function(name){
		var results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href);
		if(results != null) {
			return results[1] || 0;
		} else {
			return null;
		}
	}

	// 개별호출 일괄처리	
	var lang = Common.getSession("lang");
	Common.getBaseConfigList(["IsSyncMail"]);
	var _deptHeaderData ;
	var _userHeaderData ;
	var deptGrid = new coviGrid();
	var userGrid = new coviGrid();
	$(document).ready(function () {
		//기초설정에 따른 메일 표기 여부
		if(coviCmn.configMap["IsSyncMail"] == null |  coviCmn.configMap["IsSyncMail"] == 'N'){
			$("#IsMailType").closest('span').css("display","none");
			isMailDisplay = false;
		}

		if(mode == "Dept") {
			$("#selDeptUser").val("Dept");
			$("#selSearchType").append("<option value='DeptName'><spring:message code="Cache.lbl_DeptName"/></option>");
			$("#selSearchType").append("<option value='DeptCode'><spring:message code="Cache.lbl_DeptCode"/></option>");
		} else if(mode == "User") {
			$("#selDeptUser").val("User");
			$("#selSearchType").append("<option value='UserName'><spring:message code="Cache.lbl_USER_NAME_01"/></option>");
			$("#selSearchType").append("<option value='UserCode'><spring:message code="Cache.lbl_apv_user_code"/></option>");
			$("#selSearchType").append("<option value='DeptName'><spring:message code="Cache.lbl_DeptName"/></option>");
			$("#selSearchType").append("<option value='JobPositionName'><spring:message code="Cache.lbl_JobPositionName"/></option>");
			$("#selSearchType").append("<option value='JobTitleName'><spring:message code="Cache.lbl_JobTitleName"/></option>");
			$("#selSearchType").append("<option value='JobLevelName'><spring:message code="Cache.lbl_JobLevelName"/></option>");
		}	
		_deptHeaderData =[{key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox'},
						  {key:'CompanyName',  label:'<spring:message code="Cache.lbl_CompanyName"/>', width:'100', align:'center',
							  formatter:function () {
									return "<a href='#' onclick='editOrgDept(\""+ this.item.GroupCode +"\", \"" + this.item.GroupType + "\"); return false;'>"+CFN_GetDicInfo(this.item.MultiDomainName, lang)+"</a>";
								}},   
						  {key:'GroupCode',  label:'<spring:message code="Cache.lbl_DeptCode"/>', width:'100', align:'center',
							  formatter:function () {
									return "<a href='#' onclick='editOrgDept(\""+ this.item.GroupCode +"\", \"" + this.item.GroupType + "\"); return false;'>"+this.item.GroupCode+"</a>";
								}},
						  {key:'MultiDisplayName', label:'<spring:message code="Cache.lbl_DeptName"/>', width:'100', align:'center',
							  formatter:function () {
									return "<a href='#' onclick='editOrgDept(\""+ this.item.GroupCode +"\", \"" + this.item.GroupType + "\"); return false;'>"+CFN_GetDicInfo(this.item.MultiDisplayName, lang)+"</a>";
								}},
						  {key:'IsUse', label:'<spring:message code="Cache.lbl_IsUse"/>', width:'80', align:'center',
							  formatter:function () {
									return "<input type='text' kind='switch' on_value='Y' off_value='N' id='IsUse"+this.item.GroupCode+"' style='width:50px;height:20px;border:0px none;' value='"+this.item.IsUse+"' onchange='updateIsUse(\""+this.item.GroupCode+"\", \"Dept\");' />";
								}}];
		
		_userHeaderData =[{key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox'},
							  {key:'UserCode',  label:'<spring:message code="Cache.lbl_User_Id"/>', width:'90', align:'center', 
								  formatter:function () {
										return "<a href='#' onclick='editOrgUser(\""+ this.item.UserCode +"\"); return false;'>"+this.item.UserCode+"</a>";
									}},
							  {key:'MultiDisplayName', label:'<spring:message code="Cache.lbl_User"/>', width:'90', align:'center',
								  formatter:function () {
										return "<a href='#' onclick='editOrgUser(\""+ this.item.UserCode +"\"); return false;'>"+CFN_GetDicInfo(this.item.MultiDisplayName, lang)+"</a>";
									}},
							  {key:'JobTitle',  label:'<spring:message code="Cache.lbl_JobTitle"/>', width:'70', align:'center',
								  formatter:function () {
										return "<a href='#' onclick='editOrgUser(\""+ this.item.UserCode +"\"); return false;'>"+ CFN_GetDicInfo(this.item.JobTitle.split("|")[1] == undefined ? "" :this.item.JobTitle.split("|")[1], lang) +"</a>";
									}},
							  {key:'JobPosition',  label:'<spring:message code="Cache.lbl_JobPosition"/>', width:'70', align:'center',
								  formatter:function () {
										return "<a href='#' onclick='editOrgUser(\""+ this.item.UserCode +"\"); return false;'>"+ CFN_GetDicInfo(this.item.JobPosition.split("|")[1] == undefined ? "" : this.item.JobPosition.split("|")[1], lang) +"</a>";
									}},
							  {key:'JobLevel',  label:'<spring:message code="Cache.lbl_JobLevel"/>', width:'70', align:'center',
								  formatter:function () {
										return "<a href='#' onclick='editOrgUser(\""+ this.item.UserCode +"\"); return false;'>"+ CFN_GetDicInfo(this.item.JobLevel.split("|")[1] ==  undefined ? "" : this.item.JobLevel.split("|")[1],lang) +"</a>";
									}},
							  {key:'IsUse', label:'<spring:message code="Cache.lbl_IsUse"/>', width:'80', align:'center',
								  formatter:function () {
										return "<input type='text' kind='switch' on_value='Y' off_value='N' id='IsUse"+this.item.UserCode.replaceAll(".", "") + "_" + this.item.UserID + "' style='width:50px;height:20px;border:0px none;' value='"+this.item.IsUse+"' onchange='updateIsUse(\""+this.item.UserCode + "_" + this.item.UserID +"\", \"User\");' />";
							  }}];
		
		setGrid(); 
	});
	
	function clickSearchButton() {
		if($("#txtSearchText").val() == "") { //검색어를 입력하십시오.
			Common.Warning('<spring:message code="Cache.msg_apv_001"/>'); 
			return;
		}
		
		bindGrid();
	}
	
	function changeSearchType(obj) {		
		//다른 도메인 선택 후 부서 검색 시 좌측 메뉴 초기화되는 현상 수정
		CoviMenu_GetContent($(location).attr('pathname')+"?CLSYS=core&CLBIZ=Organization&domainCode=" + $("#domainCodeSelectBox").val() + "&mode="+$(obj).val());
	}
	
	
	function setGrid(){
		if(mode == "Dept") {
			setDeptGridConfig();
			$("#orgusergrid").css("display", "none");
		} else if(mode == "User") {
			setUserGridConfig();
			$("#orgdeptgrid").css("display", "none");
		}
	}
	
	function setDeptGridConfig(){
		deptGrid.setGridHeader(_deptHeaderData);
		
		var configObj = {
			targetID : "orgdeptgrid",
			height:"auto",
			page : {
				pageNo:1,
				pageSize:10
			},
			paging : true,
			sort:false
		};
		
		deptGrid.setGridConfig(configObj);
	}
	
	function setUserGridConfig(){
		userGrid.setGridHeader(_userHeaderData);
		
		var configObj = {
			targetID : "orgusergrid",
			height:"auto",
			page : {
				pageNo:1,
				pageSize:10
			},
			paging : true,
			sort:false
		};
		
		userGrid.setGridConfig(configObj);
	}
	
	function bindGrid(){
		if(mode == "Dept") {
			bindDeptGrid();
		} else if(mode == "User") {
			bindUserGrid();
		}
	}
	
	function bindDeptGrid() {
		deptGrid.bindGrid({
			ajaxUrl:"/covicore/admin/orgmanage/getsubdeptlist.do",
			ajaxPars: {
				"gr_code" : $.urlParam('gr_code'),
				"domainCode" : $.urlParam('domainCode'),
				"grouptype" : $.urlParam('group_type'),
				"IsUse" : $("#selIsUse").val(),
				"searchType" : $("#selSearchType").val(),
				"searchText" : $("#txtSearchText").val(),
				"sortBy" : deptGrid.getSortParam(),
				"type" : 'search'
			},
			onLoad:function(){
				coviInput.setSwitch();
				deptGrid.fnMakeNavi("deptGrid");
			}
		});
	}
	
	function bindUserGrid() {		
		userGrid.bindGrid({
			ajaxUrl:"/covicore/admin/orgmanage/getuserlist.do",
			ajaxPars: {
				"gr_code" : $.urlParam('gr_code'),
				"domainCode" : $.urlParam('domainCode'),
				"IsUse" : $("#selIsUse").val(),
				"searchType" : $("#selSearchType").val(),
				"searchText" : $("#txtSearchText").val(),
				"sortBy" : userGrid.getSortParam(),
				"type" : 'search'
			},
			onLoad:function(){
				coviInput.setSwitch();
				userGrid.fnMakeNavi("userGrid");
			}
		});
	}
	// 사용여부 스위치 버튼에 대한 값 변경
	function updateIsUse(pCode, pType){
		var now = new Date();
		var isUseValue = $("#IsUse"+pCode.replaceAll(".", "")).val();
		now = XFN_getDateTimeString("yyyy-MM-dd HH:mm:ss",now);
		
		var sURL = "";
		
		if(pType == "Dept") {
			sURL = "/covicore/admin/organization/updateisusedept.do";
		} else {
			sURL = "/covicore/admin/organization/updateisuseuser.do";
			pCode = pCode.substr(0, pCode.indexOf("_"));
		}
		
		$.ajax({
			type:"POST",
			data:{
				"Code" : pCode,
				"IsUse" : isUseValue,
				"ModID" : "",				// 세션 값
				"ModDate" : now
			},
			url:sURL,
			success:function (data) {
				if(data.result == "ok")
					Common.Inform("<spring:message code='Cache.msg_137'/>", "Information Dialog", function(result) {
						if(result) {
							window.location.reload();
						}
					});
			},
			error:function(response, status, error){
				CFN_ErrorAjax(sURL, response, status, error);
			}
		});
	}
	
	/* function getOrgDeptListData(gr_code, group_type) {
		if(gr_code != "" && group_type != "") {
			if($(location).attr('href').indexOf("?") < 0) {
				$(location).attr('href',$(location).attr('pathname')+"?domainCode="+Common.getSession("DN_Code")+"&gr_code="+gr_code+"&group_type="+group_type);
			} else {
				var domainCode = $(location).attr('href').split("?")[1].split("&")[0].split("=")[1];
				$(location).attr('href',$(location).attr('pathname')+"?domainCode="+domainCode+"&gr_code="+gr_code+"&group_type="+group_type);
			}
		}
	} */
	
	function editOrgDept(pStrGR_Code, pStrGroupType){
		var sOpenName = "divDeptInfo";
		var sGR_Code = pStrGR_Code == undefined ? $.urlParam("gr_code") : pStrGR_Code;
		var sDN_Code = $.urlParam("domainCode");
		var sMemberOf = "";
		var sGroupType = pStrGroupType == undefined ? $.urlParam("group_type") : pStrGroupType;

		var sURL = "/covicore/deptmanageinfopop.do";
		sURL += "?gr_code=" + sGR_Code;
		sURL += "&domainCode=" + sDN_Code
		sURL += "&memberOf=" + sMemberOf;
		sURL += "&GroupType=" + sGroupType;
		sURL += "&mode=modify";
		sURL += "&OpenName=" + sOpenName;
		
		var sTitle = "";
		sTitle = "<spring:message code='Cache.lbl_OrganizationDeptInfo'/>"  + " ||| " + "<spring:message code='Cache.msg_OrganizationDeptInfo'/>" ;

		var sWidth = "530px";
		var sHeight = "680px";
		Common.open("", sOpenName, sTitle, sURL, sWidth, sHeight, "iframe", false, null, null, true);
	}
	
	function editOrgUser(pStrUR_Code){
		var sOpenName = "divUserInfo";
		var sUR_Code = pStrUR_Code;
		var sDN_Code = $.urlParam("domainCode");
		
		var sURL = "/covicore/usermanageinfopop.do";
		sURL += "?ur_code=" + sUR_Code
		sURL += "&domainCode=" + sDN_Code;
		sURL += "&mode=modify";
		sURL += "&OpenName=" + sOpenName;
		
		var sTitle = "";
		sTitle = "<spring:message code='Cache.lbl_OrganizationUserEdit'/>"  + " ||| " + "<spring:message code='Cache.msg_OrganizationUserEdit'/>" ;

		var sWidth = "830px";
		var sHeight = "600px";
		
		Common.open("", sOpenName, sTitle, sURL, sWidth, sHeight, "iframe", false, null, null, true);
	}
	
</script>