<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>
<% 
	String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path");
%>
<script type="text/javascript" src="/groupware/resources/script/admin/scheduleAdmin.js<%=resourceVersion%>" ></script>
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/collaboration/resources/css/collaboration.css<%=resourceVersion%>">
<style>
.palette-color-picker-button {
	z-index: 99
}

#con_acl .authPermissions table tr td:nth-child(9) {
	border-right: 1px dashed #ddd;
}

.authPermissions {
	height: 180px;
	overflow: auto;
	border-bottom: 1px solid #d7d7d7;
}

.authPermissions .userlist table tr td {
	padding: 5px !important;
}
</style>
<body>
	<div class="AXTabs" style="margin-bottom: 10px">
		<div class="AXTabsTray" style="height:30px">
			<a id="basicTab" class="AXTab on" onclick="clickTab(this);" value ="basic"><spring:message code="Cache.lbl_chkBasicConfigYN"/></a>
			<a id="authSettingTab" class="AXTab" onclick="clickTab(this);" value="authSetting"><spring:message code="Cache.btn_AuthSet"/></a>
		</div>
	</div>
	<div class="TabBox" style="margin-bottom: 20px">
		<div id="searchTab_Basic">
			<table class="AXFormTable">
				<colgroup>
					<col width="20%">
					<col width="30%">
					<col width="20%">
					<col width="30%">
				</colgroup>
				<tr>
					<th><spring:message code='Cache.lbl_Organization_Name' /></th> <!-- 표시이름 -->
					<td>
						<input type="text" class="AXInput HtmlCheckXSS ScriptCheckXSS" id="DisplayName" style="width: 55%" onchange="changeDisplayName();">
						<input type="hidden" id="hidMultiName" value="">
						<input type="button" class="AXButton" id="btnMultiLangDataSetting" value="<spring:message code='Cache.lbl_MultiLang2'/>" onclick="setMultiLangData();"><!-- 다국어 -->
					</td>
					<th><spring:message code='Cache.lbl_Sort' /></th> <!-- 정렬 -->
					<td>
						<input type="text" class="AXInput" id="SortKey" style="width: 93%" disabled="disabled" mode="number">
					</td>					
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_DefaultColor' /></th> <!-- 기본 컬러 -->
					<td>
						<span id="pDefaultColor" style="float: left; display: inline; width: 56%; height: 25px; margin-right: 5px;">
							<input type="hidden" id="DefaultColor" >
						</span>						
						<input type="button" class="AXButton" id="btnColorSetting" value="<spring:message code='Cache.btn_Setting' />" onclick="setFolderColor();"/><!-- 설정 -->
					</td>
					<th><spring:message code='Cache.lbl_Operator' /></th> <!-- 운영자 -->
					<td>
						<input type="text" class="AXInput HtmlCheckXSS ScriptCheckXSS" id="OwnerName" style="width: 72%" readonly="readonly">
						<input type="hidden" id="OwnerCode" >
						<a id="aOwnerCode" onclick="folderPopup.openOrgMapPopup('T')">
	                        <img width="21" height="18" style="vertical-align: middle; cursor: pointer; " src="/HtmlSite/smarts4j_n/covicore/resources/images/covision/btn_org.gif" >
	                    </a>
					</td>					
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_ScheduleType' /></th> <!-- 일정유형 -->
					<td>
						<select name="" class="AXSelect" id="FolderType">
						</select>
					</td>
					<th><spring:message code='Cache.lbl_shareyn' /></th> <!-- 공유 여부 -->
					<td>
						<input type="radio" name="IsShared" id="IsShared_Y"  value="Y"/><spring:message code='Cache.lbl_sharedY' /><!-- 공유함 -->&nbsp;
						<input type="radio" name="IsShared" id="IsShared_N" value="N"/><spring:message code='Cache.lbl_sharedN' /><!-- 공유안함 -->
					</td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_LinkSchedule' /></th> <!-- 연결 일정 -->
					<td colspan="3">
						<select name="" class="AXSelect" id="LinkFolderID">
						</select>
						&nbsp;
						<span id="PersonLinkFolder" style="display: none">
							<input type="text" class="AXInput HtmlCheckXSS ScriptCheckXSS" id="PersonLinkName" readonly="readonly" />
							<input type="hidden" id="PersonLinkCode" />
							<a id="aPersonLinkCode" onclick="folderPopup.openOrgMapPopup('P')">
		                        <img width="21" height="18" style="vertical-align: middle; cursor: pointer; " src="/HtmlSite/smarts4j_n/covicore/resources/images/covision/btn_org.gif" >
		                    </a>
						</span>
					</td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_SecurityLevel' /></th><!-- 보안등급 -->
					<td colspan="3">
						<select name="" class="AXSelect" id="SecurityLevel">
						</select>
					</td>
				</td>
				<tr style="height: 39px;">
					<th><spring:message code='Cache.lbl_IsUse' /></th><!-- 사용여부 -->
					<td>
						<input type="radio" name="IsUse" id="IsUse_Y" value="Y"/><spring:message code='Cache.lbl_USE_Y' /><!-- 사용함 -->&nbsp;
						<input type="radio" name="IsUse" id="IsUse_N" value="N" /><spring:message code='Cache.lbl_noUse' /><!-- 사용안함 -->
					</td>
					<th><spring:message code='Cache.lbl_DisplayYN' /></th><!-- 표시유무 -->
					<td>
						<input type="radio" name="IsDisplay" id="IsDisplay_Y" value="Y"/><spring:message code='Cache.lbl_Display2' /><!-- 표시함 -->&nbsp;
						<input type="radio" name="IsDisplay" id="IsDisplay_N" value="N" /><spring:message code='Cache.lbl_noDisplay' /><!-- 표시안함 -->
					</td>
				</tr>
				<tr style="height: 39px;">
					<th><spring:message code='Cache.lbl_IsURL' /></th><!-- URL 사용 -->
					<td>
						<input type="radio" name="IsURL" id="IsURL_Y" value="Y"/><spring:message code='Cache.lbl_USE_Y' /><!-- 사용함 -->&nbsp;
						<input type="radio" name="IsURL" id="IsURL_N" value="N" /><spring:message code='Cache.lbl_noUse' /><!-- 사용안함 -->
					</td>
					<th><spring:message code='Cache.lbl_AdminSubMenu' /></th>
					<td>
						<input type="radio" name="IsAdminSubMenu" id="IsAdminSubMenu_Y" value="Y"/><spring:message code='Cache.lbl_Display2' />&nbsp;
						<input type="radio" name="IsAdminSubMenu" id="IsAdminSubMenu_N" value="N"/><spring:message code='Cache.lbl_noDisplay' />
					</td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_URL' /></th><!-- URL -->
					<td colspan="3">
						<input type="text" class="AXInput HtmlCheckXSS ScriptCheckXSS" id="URL"  style="width: 93%">
					</td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_explanation' /></th><!-- 설명 -->
					<td colspan="3">
						<textarea id="Description" class="HtmlCheckXSS ScriptCheckXSS" rows="3" style="width:95%; resize:none"></textarea>
					</td>
				</tr>
			</table>
		</div>
		<div id="searchTab_AuthSetting" style="display: none; margin-top: 10px;">
			<div id="con_acl" style="margin-top: 10px;"></div>
		</div>
	</div>
	<br>
	<div align="center">
		<input type="button" class="AXButton red" id="btnSave" value="<spring:message code='Cache.btn_register' />" /><!-- 등록 -->
		<input type="button" class="AXButton" value="<spring:message code='Cache.btn_Close' />" onclick="Common.Close();"/><!-- 닫기 -->
	</div>
</body>
<script type="text/javascript">
//다국어 특수문자 처리 위한 정규표현식.
var regExp = /\&nbsp\;|\&quot\;|\&apos\;|\;|\"|\'|\&/g;
var coviACL = null;
var g_isRoot = false;
var g_isInherited = false;	// 권한 상속 여부
var g_hasChild = false;		// 자식 객체 존재 여부
var sessionObj = Common.getSession(); //전체호출
var lang = sessionObj["lang"];

$(document).ready(function(){
	folderPopup.initContent();
});

var folderPopup = {			
	lang : sessionObj["lang"],
	g_aclList : "",		//권한 설정 ACL List, 추후 팝업호출시 해당 폴더의 권한 정보 조회
	mode : CFN_GetQueryString("mode"),
	FolderID : CFN_GetQueryString("FolderID") == "undefined" ? "" : CFN_GetQueryString("FolderID"),
	ScheduleType : CFN_GetQueryString("ScheduleType"),
	DomainID : CFN_GetQueryString("DomainID"),
	LinkFolderID : "",
	dataPalette : new Array(),		
	initContent : function(){
		//저장
		$("#btnSave").on('click', function(){
			folderPopup.saveData(this)
		});
		
		// SelectBox 세팅라디오 박스 디폴트 값 세팅
		this.setIninBox();
		
		//개별호출-일괄호출
		Common.getBaseConfigList(["FolderDefaultColor", "DefaultSecurityLevel","SchedulePersonFolderID","ScheduleTotalFolderID"]);
		
		// colorPicker 세팅
		var colorList = Common.getBaseCode("ScheduleColor");
		var defaultColor = coviCmn.configMap["FolderDefaultColor"];
		
		$(colorList.CacheData).each(function(){
			var obj = {};
			$$(obj).append(this.Code, "#"+this.Code);
			folderPopup.dataPalette.push(obj);
		});
		
		$("#DefaultColor").val(defaultColor);
		
		if(folderPopup.mode == "U"){
			$("#btnSave").text("<spring:message code='Cache.btn_save'/>");
			folderPopup.selectFolderData();
		}else{
			$("#SecurityLevel").bindSelectSetValue(coviCmn.configMap["DefaultSecurityLevel"]);
			folderPopup.dataPalette.unshift({"default" : defaultColor});
			coviCtrl.renderColorPicker("colorPicker", folderPopup.dataPalette);
		}
	},
	
	openOrgMapPopup:function (strType){
		_CallBackMethod2 = this.setOwnerData;
		if (strType== "P"){	//내일정
			_CallBackMethod2 = this.setPersonLinkData;
		}	
		var option = {
			callBackFunc : "_CallBackMethod2",
		};

		coviCmn.openOrgChartPopup("<spring:message code='Cache.lbl_DeptOrgMap'/>", "A1", option);
	},
	
	setOwnerData : function(data){
		var dataObj = $.parseJSON(data);
		
		var userCode = $$(dataObj).find("item").concat().eq(0).attr("AN");
		var userName = CFN_GetDicInfo($$(dataObj).find("item").concat().eq(0).attr("DN"));

		$("#OwnerCode").val(userCode);
		$("#OwnerName").val(userName);
	},
	
	setPersonLinkData : function(data){
		var dataObj = $.parseJSON(data);
		
		var userCode = $$(dataObj).find("item").concat().eq(0).attr("AN");
		var userName = CFN_GetDicInfo($$(dataObj).find("item").concat().eq(0).attr("DN"));
		
		$("#PersonLinkCode").val(userCode);
		$("#PersonLinkName").val(userName);
	},
	
	setIninBox:function(){
		$("#IsShared_N").attr("checked", true);						//공유 여부
		$("#IsUse_Y").attr("checked", true);						//사용여부
		$("#IsDisplay_Y").attr("checked", true);					//표시유무
		$("#IsURL_N").attr("checked", true);						//URL 사용
		$("#IsAdminSubMenu_Y").attr("checked", true);
		
		var option = {
			lang : lang, 
			allowedACL : '_CDMEVR',
			initialACL : '_CDMEVR',
			hasButton : false,
			orgMapCallback : 'orgCallback',
			aclCallback : 'aclCallback',
			systemType : "Schedule",
			useInherited : false
		};
		
		coviACL = new CoviACL(option);
		coviACL.render('con_acl');
			
		// 일정유형 SELECT BOX
		$("#FolderType").bindSelect({
			reserveKeys: {
				options: "list",
				optionValue: "optionValue",
				optionText: "optionText"
			},
			ajaxUrl: "/groupware/schedule/getFolderTypeData.do",
			ajaxPars: {"ScheduleType": this.ScheduleType},
			ajaxAsync:false,
			onChange: function(){
				folderPopup.onChangeFolderTypeSelectBox(this.optionValue);
        	}
		});
		
		// 연결일정 SELECT BOX
		$("#LinkFolderID").bindSelect({
			reserveKeys: {
				options: "list",
				optionValue: "optionValue",
				optionText: "optionText",
				optionData: "optionData"
			},
			ajaxUrl: "/groupware/schedule/getLinkFolderListData.do",
			ajaxPars: {
				manageCompany: this.DomainID
			},
			ajaxAsync:false,
			onload:function(){
        		$("#LinkFolderID").bindSelectSetValue(folderPopup.LinkFolderID );
				if(folderPopup.LinkFolderID == coviCmn.configMap["SchedulePersonFolderID"])	{		//내일정 폴더 ID
		        	$("#PersonLinkFolder").show();
				}
			},
			onChange: function(){
				if(this.optionData == "Schedule.Person"){
					$("#PersonLinkFolder").show();
				}else{
					$("#PersonLinkFolder").hide();
				}
			}
		});

		// 보안등급 SELECT BOX
		coviCtrl.renderAXSelect("SecurityLevel","SecurityLevel",this.lang,	"",		"",	"");
	},
	
	selectFolderData:function(){
		$.ajax({
		    url: "/groupware/schedule/getAdminFolderData.do",
		    type: "POST",
		    data: {
				"FolderID":folderPopup.FolderID,
				"ObjectID" : folderPopup.FolderID,
				"ObjectType" : "FD"
			},
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
			    	// 폴더 정보 데이터 세팅
		            $(res.data).each(function(){
		            	var folderData = res.data;
		            	
		            	folderPopup.LinkFolderID = folderData.LinkFolderID == "" || folderData.LinkFolderID == undefined ? "none" : folderData.LinkFolderID;
		            	
		            	if(folderData.LinkFolderID == coviCmn.configMap["SchedulePersonFolderID"]) {
		            		$("#PersonLinkFolder").show();	//내일정 폴더 ID
		            	}
		            			
		            	$("#FolderType").bindSelectSetValue(folderData.FolderType);
		        		$("#SecurityLevel").bindSelectSetValue(folderData.SecurityLevel);
		        		$("#LinkFolderID").bindSelectSetValue(folderPopup.LinkFolderID );
		            	$("#DisplayName").val(folderData.DisplayName);
		        		$("#hidMultiName").val(folderData.MultiDisplayName);
		        		$("#SortKey").val(folderData.SortKey);
		        		$("#OwnerCode").val(folderData.OwnerCode);
		        		$("#OwnerName").val(folderData.OwnerName);
		        		$("#PersonLinkCode").val(folderData.PersonLinkCode);
		        		$("#PersonLinkName").val(folderData.PersonLinkName);
		        		$("#URL").val(folderData.URL);
		        		$("#Description").val(folderData.Description);
		        		
		        		$("[name=IsShared][value='"+folderData.IsShared+"']").prop("checked", true);
		        		$("[name=IsUse][value='"+folderData.IsUse+"']").prop("checked", true);
		        		$("[name=IsDisplay][value='"+folderData.IsDisplay+"']").prop("checked", true);
		        		$("[name=IsURL][value='"+folderData.IsURL+"']").prop("checked", true);
		        		$("[name=IsAdminSubMenu][value='"+folderData.IsAdminSubMenu+"']").prop("checked", true);
		        		
		        		$("#hidMemberOf").val(folderData.MemberOf);
		        		
		        		// 색상 세팅
		        		$("#DefaultColor").val(folderData.DefaultColor);
		        		
		        		if(folderData.DefaultColor == "" || folderData.DefaultColor == "#") {
		        			$("#pDefaultColor").css("background-color", "");
		        		} else {
		        			$("#pDefaultColor").css("background-color", folderData.DefaultColor);
		        		}
		        		
						folderPopup.dataPalette.unshift({"default" : folderData.DefaultColor});
						coviCtrl.renderColorPicker("colorPicker", folderPopup.dataPalette);
		            });
		         
		            if($(res.data).length > 0){
		            	folderPopup.mode = "U";
		            	$("#btnSave").text("<spring:message code='Cache.btn_save'/>");
		            }else{
		            	folderPopup.mode = "I";
		            	$("#btnSave").text("<spring:message code='Cache.btn_register'/>");
		            }
		            
		         	// 권한 데이터 세팅
			    	if($(res.aclData).length > 0){
			    		coviACL.set(res.aclData);
			    	}
		    	} else {
					Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
				}
	        },
	        error:function(response, status, error){
				CFN_ErrorAjax("/groupware/schedule/getAdminFolderData.do", response, status, error);
			}
		});
	},
	
	saveData:function(){//저장
		var folderDataObj = {};		
		var DisplayName = $("#DisplayName").val();		
		var MultiDisplayName = $("#hidMultiName").val();
		var FolderType = $("#FolderType").val();
		
		if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

		// Validation Check
		if(DisplayName == "" || DisplayName == undefined || DisplayName == null){
			Common.Warning("<spring:message code='Cache.msg_SetScheduleName'/>");		//일정명(표시이름)을 작성해 주세요
			return false;
		}
		
		if(FolderType == "none" || FolderType == undefined || FolderType == null){
			Common.Warning("<spring:message code='Cache.msg_SetFolderType'/>");				//일정유형을 선택해 주세요
			return false;
		}
		
		if (!symbolCheck(DisplayName)) { 	// 다국어 특수문자 validityCheck.
			return false;
		}
		
		//폴더일 경우 기본컬러 색깔 X
		if(FolderType == "Folder"){
			$("#DefaultColor").val("");
		}
		
		var sDictionaryInfo = $("#hidMultiName").val();
		
	    if (sDictionaryInfo == "") {
	        switch (Common.getSession("lang").toUpperCase()) {
	            case "KO": sDictionaryInfo = document.getElementById("DisplayName").value + ";;;;;;;;;"; break;
	            case "EN": sDictionaryInfo = ";" + document.getElementById("DisplayName").value + ";;;;;;;;"; break;
	            case "JA": sDictionaryInfo = ";;" + document.getElementById("DisplayName").value + ";;;;;;;"; break;
	            case "ZH": sDictionaryInfo = ";;;" + document.getElementById("DisplayName").value + ";;;;;;"; break;
	            case "E1": sDictionaryInfo = ";;;;" + document.getElementById("DisplayName").value + ";;;;;"; break;
	            case "E2": sDictionaryInfo = ";;;;;" + document.getElementById("DisplayName").value + ";;;;"; break;
	            case "E3": sDictionaryInfo = ";;;;;;" + document.getElementById("DisplayName").value + ";;;"; break;
	            case "E4": sDictionaryInfo = ";;;;;;;" + document.getElementById("DisplayName").value + ";;"; break;
	            case "E5": sDictionaryInfo = ";;;;;;;;" + document.getElementById("DisplayName").value + ";"; break;
	            case "E6": sDictionaryInfo = ";;;;;;;;;" + document.getElementById("DisplayName").value; break;
	        }
	        
	        $("#hidMultiName").val(sDictionaryInfo);
	    }	

		$$(folderDataObj).append("FolderID", this.FolderID);
		$$(folderDataObj).append("ScheduleType", this.ScheduleType);
		$$(folderDataObj).append("DomainID", this.DomainID);
		$$(folderDataObj).append("DisplayName", DisplayName);
		$$(folderDataObj).append("FolderType", FolderType);
		$$(folderDataObj).append("MemberOf", this.mode == "I" ? this.FolderID : $("#hidMemberOf").val());
		$$(folderDataObj).append("MultiDisplayName", $("#hidMultiName").val());
		$$(folderDataObj).append("DefaultColor", $("#DefaultColor").val());
		$$(folderDataObj).append("SortKey", $("#SortKey").val());
		$$(folderDataObj).append("SecurityLevel", $("#SecurityLevel").val());
		$$(folderDataObj).append("IsShared", $("[name=IsShared]:checked").val());
		$$(folderDataObj).append("ManageCompany", this.DomainID);
		$$(folderDataObj).append("OwnerCode", $("#OwnerCode").val());
		$$(folderDataObj).append("LinkFolderID", $("#LinkFolderID").val() == "none" ? "" : $("#LinkFolderID").val());
		$$(folderDataObj).append("PersonLinkCode", $("#PersonLinkCode").val());
		$$(folderDataObj).append("IsInherited", "N");
		$$(folderDataObj).append("IsUse", $("[name=IsUse]:checked").val());
		$$(folderDataObj).append("IsDisplay", $("[name=IsDisplay]:checked").val());
		$$(folderDataObj).append("IsURL", $("[name=IsURL]:checked").val());
		$$(folderDataObj).append("IsAdminSubMenu", $("[name=IsAdminSubMenu]:checked").val());
		$$(folderDataObj).append("URL", $("#URL").val());
		$$(folderDataObj).append("Description", $("#Description").val());
		$$(folderDataObj).append("RegisterCode", sessionObj["USERID"]);
		$$(folderDataObj).append("ModifierCode", sessionObj["USERID"]);
		
		var aclInfo = coviACL_getACLData('con_acl');
		var aclIsChange = aclInfo.aclIsChange;
		var aclData = aclInfo.aclData;
		var aclActionData = coviACL_getACLActionData("con_acl");
		
		if(aclData == '[]'){
			Common.Warning("<spring:message code='Cache.msg_Common_01'/>");	// 사용권한을 설정해 주십시오.
			return;
		}
		
		$.ajax({
			url: "/groupware/schedule/saveAdminFolderData.do",
		    type: "POST",
		    data: {
		    	"mode":this.mode,
				"folderData":JSON.stringify(folderDataObj),
				"aclData":aclData,
				"aclActionData":aclActionData
			},
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
		            Common.Inform("<spring:message code='Cache.msg_117'/>", "Information", function(){		            	
		            	parent.searchListData();
		            	Common.Close();
		            });
		    	}else{
		    		Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
		    	}
	        },
	        error:function(response, status, error){
				CFN_ErrorAjax("/groupware/schedule/saveAdminFolderData.do", response, status, error);
			}
		});
	},
	
	checkIsInherit:function(pObj){//상위권한 상속일때
		$("#con_acl_hTbdPermissions").html("");
		g_aclList = "";
		//권한 표시항목 및 aclList변수 초기화
		//selectScheduleACLData($(pObj).prop("checked"));
		
		if($(pObj).prop("checked")){
			$("#con_acl").find("input").prop("disabled",true);
		} else {	
			$("#con_acl").find("input").prop("disabled",false);
		}
	},
	
	//일정유형별 Input 제한
	onChangeFolderTypeSelectBox:function(type){
		if(type == "Folder"){
			$("#pDefaultColor").hide();
			$("#btnColorSetting").hide();
			$("#IsShared_N").prop("checked", true);
			$("[name=IsShared]").attr("disabled", "disabled");
			
			$("#OwnerCode").val("");
			$("#OwnerName").val("");
			$("#OwnerName").attr("disabled", "disabled");
			$("#aOwnerCode").hide();
			
			$("#LinkFolderID").bindSelectSetValue("none");
			$("#LinkFolderID").bindSelectDisabled(true);
			
			$("[name=IsAdminSubMenu]").removeAttr("disabled");
		}else{
			$("#pDefaultColor").show();
			$("#btnColorSetting").show();
			
			$("#OwnerCode").val("");
			$("#OwnerName").val("");
			$("#OwnerName").removeAttr("disabled");
			$("#aOwnerCode").show();
			
			if(type == "Schedule" || type == "SchedulePerson"){
				$("[name=IsShared]").removeAttr("disabled");
				$("#LinkFolderID").bindSelectSetValue("none");
				$("#LinkFolderID").bindSelectDisabled(true);
			}else if(type == "ScheduleShare"){
				$("#IsShared_N").prop("checked", true);
				$("[name=IsShared]").attr("disabled", "disabled");
				$("#LinkFolderID").bindSelectDisabled(false);
			}
			$("#IsAdminSubMenu_Y").prop("checked", true);
			$("[name=IsAdminSubMenu]").attr("disabled", "disabled");
		}
	}
}

//상위 권한 상속
var selectInheritedACL = function(){	
	$.ajax({
		url: "/groupware/schedule/selectBoardACLData.do",
		type: "POST",
		async: false,
		data: {
			  "objectID": $("#hidMemberOf").val()
			, "objectType": "FD"
			, "ScheduleType" : folderPopup.ScheduleType
		},
		success: function(res){
			if (res.status === "SUCCESS") {
				var aclList = [];
				var exAclList = JSON.parse(coviACL_getACLData("con_acl"));
				
				$(res.data).each(function(idx, item){
					var exist = exAclList.map(function(exAcl){
						return exAcl.SubjectCode === item.SubjectCode;
					});
					
					// 있는 경우 상속 받은 권한으로 덮어쓴다
					if (exist.includes(true)) {
						// con_acl
						$(".aclSubject").each(function(i, tr) {							
							if($(tr).attr("objectcode") == item.SubjectCode) {
								coviACL_setDelInfo($(tr));
								$(tr).remove();
							}
						});
						
						coviACL_deleteACLBySubject("con_acl", item.SubjectCode);
					} 
					
					var acl = {
						  "AN": item.SubjectCode
						, "DN_Code": item.CompanyCode
						, "AclList": item.AclList
						, "Security": item.Security
						, "Create": item.Create
						, "Delete": item.Delete
						, "Modify": item.Modify
						, "Execute": item.Execute
						, "View": item.View
						, "Read": item.Read
						, "IsSubInclude" : item.IsSubInclude
					};
					
					if (item.SubjectType === "UR") {
						acl["itemType"] = "User";
						acl["DN"] = item.MultiSubjectName;
					} else {
						acl["itemType"] = "Group";
						acl["GroupName"] = item.MultiSubjectName;
						acl["GroupType"] = item.GroupType;
					}
					
					aclList.push(acl);					
				});
				
				var jsonData = {"item": aclList, "isInHerited": true, "inheritedObjectID": res.inheritedObjectID};
				
				// 모든 하이라이트 해제
				$('.aclSubject').css("background-color", "inherit");
				$('.aclSubject').removeAttr("data-clicked");
				
				coviACL.addSubjectRow(JSON.stringify(jsonData));
				setAuthSetting(jsonData.item);
			}
		},
		error: function(error){
			CFN_ErrorAjax("/groupware/schedule/selectBoardACLData.do", response, status, error);
		}
	});
}

//조직도 Callback
function orgCallback(data){
	var orgJson = $.parseJSON(data);
	var bCheck = false;
	var sObjectType = "";
	var sObjectType_A = "";
	var sObjectTypeText = "";
	var sCode = "";
	var sDNCode = "";
	var sDisplayName = "";
	
	// 모든 하이라이트 해제
	$('.aclSubject').css("background-color", "inherit");
	$('.aclSubject').removeAttr("data-clicked");
	
	$.each(orgJson.item, function(i, item){
		sObjectType = item.itemType;
		
		if(sObjectType.toUpperCase() == "USER"){ //사용자
			sObjectTypeText = "사용자";
			sObjectType_A = "UR";
			sCode = item.AN;		//UR_Code
			sDNCode = item.ETID; 	//DN_Code
			sDisplayName = CFN_GetDicInfo(item.DN, lang);			
		}else{ //그룹
			switch(item.GroupType.toUpperCase()){
	  			case "AUTHORITY":
	                sObjectTypeText = "권한";
	                sObjectType_A = "GR";
	                break;
	  			case "COMMUNITY":
	                sObjectTypeText = "커뮤니티";
	                sObjectType_A = "GR";
	                break;
	  			case "COMPANY":
	                 sObjectTypeText = "회사";
	                 sObjectType_A = "CM";
	                 break;
	             case "JOBLEVEL":
	                 sObjectTypeText = "직급";
	                 sObjectType_A = "GR";
	                 break;
	             case "JOBPOSITION":
	                 sObjectTypeText = "직위";
	                 sObjectType_A = "GR";
	                 break;
	             case "JOBTITLE":
	                 sObjectTypeText = "직책";
	                 sObjectType_A = "GR";
	                 break;
	             case "MANAGE":
	                 sObjectTypeText = "관리";
	                 sObjectType_A = "GR";
	                 break;
	             case "OFFICER":
	                 sObjectTypeText = "임원";
	                 sObjectType_A = "GR";
	                 break;
	             case "DEPT":
	                 sObjectTypeText = "부서";
	                 sObjectType_A = "GR";
	                 break;
	             default:
	                 sObjectTypeText = "그룹";
	                 sObjectType_A = "GR";
	                 break;
	     	}
			
			sCode = item.AN;
			sDisplayName = CFN_GetDicInfo(item.GroupName);
			sDNCode = item.DN_Code;
		}
		
		bCheck = false;
		
		$('#con_acl_hTbdPermissions').find('tr').each(function(){
			if (($(this).attr("objecttype_a").toUpperCase() == sObjectType_A.toUpperCase()) && ($(this).attr("objectcode") == sCode)) {
				bCheck = true;
			}
		});
		
		if(!bCheck){
			var jsonData = JSON.stringify({"item": item});
			coviACL.addSubjectRow(jsonData);
			
			// 신규 추가 권한들의 최상위 데이터로 하단 라디오버튼 설정
			if(i == 0) {   				
		   	 	coviACL_setACLRdo(item.hasOwnProperty("AclList") ? item.AclList : coviACL.config.initialACL, 0, 'S', coviACL.config.target);
		        coviACL_setACLRdo(item.hasOwnProperty("AclList") ? item.AclList : coviACL.config.initialACL, 1, 'C', coviACL.config.target);
		        coviACL_setACLRdo(item.hasOwnProperty("AclList") ? item.AclList : coviACL.config.initialACL, 2, 'D', coviACL.config.target);
		        coviACL_setACLRdo(item.hasOwnProperty("AclList") ? item.AclList : coviACL.config.initialACL, 3, 'M', coviACL.config.target);
		        coviACL_setACLRdo(item.hasOwnProperty("AclList") ? item.AclList : coviACL.config.initialACL, 4, 'E', coviACL.config.target);
		        coviACL_setACLRdo(item.hasOwnProperty("AclList") ? item.AclList : coviACL.config.initialACL, 5, 'V', coviACL.config.target);
		        coviACL_setACLRdo(item.hasOwnProperty("AclList") ? item.AclList : coviACL.config.initialACL, 6, 'R', coviACL.config.target);	
		        coviACL_setSubIncludeRdo(item.hasOwnProperty("IsSubInclude") ? item.IsSubInclude : coviACL.config.initSubInclude, sObjectType_A, "SubInclude", coviACL.config.target);
		    }
		}else{
			Common.Error("<spring:message code='Cache.ACC_msg_existItem'/>"); // 이미 추가된 항목입니다.
		}
	});
	
	setAuthSetting(orgJson.item);
}

//화면에 설정된 ACL 데이터 출력
function aclCallback(data){
	g_aclList = data;
}

//다국어 설정 팝업
function setMultiLangData(){
	var option = {
			lang : lang,
			hasTransBtn : 'true',
			allowedLang : 'ko,en,ja,zh,lang1,lang2',
			useShort : 'false',
			dicCallback : 'dicCallback',
			popupTargetID : 'setMultiLangData',
			init : 'dicInit'
	};
	
	var url = "";
	url += "/covicore/control/calldic.do?lang=" + option.lang;
	url += "&hasTransBtn=" + option.hasTransBtn;
	url += "&useShort=" + option.useShort;
	url += "&dicCallback=" + option.dicCallback;
	url += "&allowedLang=" + option.allowedLang;
	url += "&popupTargetID=" + option.popupTargetID;
	url += "&init=" + option.init;
	
	Common.open("","setMultiLangData","<spring:message code='Cache.lbl_MultiLangSet' />",url,"400px","280px","iframe",true,null,null,true);
}

//다국어 세팅 함수
function dicInit(){
	return $("#hidMultiName").val();
}

//다국어 콜백 함수
function dicCallback(data){
	if (!symbolCheck(data.KoFull)) {}
	
	var multiLangName = '';
	multiLangName += symbolChange(data.KoFull) + ';';
	multiLangName += symbolChange(data.EnFull) + ';';
	multiLangName += symbolChange(data.JaFull) + ';';
	multiLangName += symbolChange(data.ZhFull) + ';';
	multiLangName += symbolChange(data.Lang1Full) + ';';
	multiLangName += symbolChange(data.Lang2Full) + ';';
	multiLangName += symbolChange(data.Lang3Full) + ';';
	multiLangName += symbolChange(data.Lang4Full) + ';';
	multiLangName += symbolChange(data.Lang5Full) + ';';
	multiLangName += symbolChange(data.Lang6Full) + ';';
				
	$("#hidMultiName").val(multiLangName);
	$("#DisplayName").val(symbolChange(data.KoFull));
	
	Common.Close("setMultiLangData");
}

//다국어의 특수기호 체크
function symbolCheck(param) {
	if ( regExp.test(param) ) { 	// 정규표현식으로 특수문자 검색.
		var sMessage = String.format("<spring:message code='Cache.msg_DictionaryInfo_01' />", "&apos; &quot; ; &") ; // 특수문자 [' " ;]는 사용할 수 없습니다.
		Common.Warning(sMessage, 'Warning Dialog', function () {});
		return false;	
	} else {
		return true;
	}
}

// 특수기호 변경처리.
function symbolChange(strParam) {
	strParam = strParam.replaceAll(regExp,"");
	return strParam
}

//탭
function clickTab(pObj){
	$(".AXTab").attr("class","AXTab");
	$(pObj).addClass("AXTab on");
	
	var str = $(pObj).attr("value");
	
	if(str == "basic") {
		$("#searchTab_Basic").show();	
		$("#searchTab_AuthSetting").hide();
	}else if(str == "authSetting") {
		$("#searchTab_Basic").hide();	
		$("#searchTab_AuthSetting").show();
	}
	$(window).resize();
}

function setFolderColor(){
	var defaultColor = $("#DefaultColor").val().replace("#", "");
	Common.open("","setColor","일정 색깔 지정","/groupware/schedule/goScheduleFolderColor.do?defaultColor="+defaultColor,"400px","250px","iframe",true,null,null,true);
}

//표시이름 변경시 다국어값 초기화
function changeDisplayName(){
	$("#hidMultiName").val($("#DisplayName").val());
}
</script>