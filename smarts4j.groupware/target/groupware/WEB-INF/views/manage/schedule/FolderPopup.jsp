<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib uri="/WEB-INF/tlds/covi.tld" prefix="covi" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<style>
.palette-color-picker-button{z-index:99}

#con_acl .authPermissions table tr td:nth-child(9) { 
	border-right: 1px dashed #ddd;
}
</style>
<body>
	<div class="sadmin_pop">
		<ul class="tabMenu clearFloat">
			<li id="basicTab" class="active" value="basic"><a href="javascript:;"><spring:message code="Cache.lbl_chkBasicConfigYN" /></a> <!-- 기본설정 --></li>
			<li id="authSettingTab" class=""  value="authSetting"> <a href="javascript:;"><spring:message code="Cache.btn_AuthSet" /></a> <!-- 권한설정 --></li>
		</ul>
		<div class="tabContent active"  id="searchTab_Basic">
			<table class="sadmin_table">
				<colgroup>
					<col width="20%">
					<col width="30%">
					<col width="20%">
					<col width="30%">
				</colgroup>
				<tr>
					<th><spring:message code='Cache.lbl_Organization_Name' /></th><!-- 표시이름 -->
					<td>
						<div class="sadmin_popup_displayname">
							<input type="text" id="DisplayName" kind="dictionary" dic_src="hidMultiName" dic_callback="dicCallback"/>
							<a href="#" kind="dictionaryBtn" src_elem="DisplayName" class="btnTypeDefault"><spring:message code='Cache.lbl_MultiLang2'/></a> 	<!-- 다국어 -->
							<input type="hidden" id="hidMultiName" value="">
						</div>
					</td>
					<th><spring:message code='Cache.lbl_Sort' /></th><!-- 정렬 -->
					<td>
						<input type="text" id="SortKey" style="width: 93%" disabled="disabled" mode="number">
					</td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_DefaultColor' /></th><!-- 기본 컬러 -->
					<td>
						<div id="colorPicker" style="float:left"></div>
						<input type="hidden" id="DefaultColor" >
						<!--  <span id="pDefaultColor" style="float: left;display: inline;width: 50px;height: 25px;">
							
						</span>
						&nbsp;<input type="button" class="AXButton" id="btnColorSetting" value="<spring:message code='Cache.btn_Setting' />" />-->
					</td>
					<th><spring:message code='Cache.lbl_Operator' /></th><!-- 운영자 -->
					<td>
						<input type="text" class="HtmlCheckXSS ScriptCheckXSS" id="OwnerName" readonly style="width: 72%">
						<input type="hidden" id="OwnerCode" >
						<a href="#" id="aOwnerCode" class="btnTypeDefault search"  onclick="folderPopup.openOrgMapPopup('T')"></a>
					</td>
					
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_ScheduleType' /></th><!-- 일정유형 -->
					<td>
						<select name="" id="FolderType" class="selectType02" >
						</select>
					</td>
					<th><spring:message code='Cache.lbl_shareyn' /></th><!-- 공유 여부 -->
					<td>
						<input type="radio" name="IsShared" id="IsShared_Y"  value="Y"/>&nbsp;<spring:message code='Cache.lbl_sharedY' /><!-- 공유함 -->&nbsp;
						<input type="radio" name="IsShared" id="IsShared_N" value="N"/>&nbsp;<spring:message code='Cache.lbl_sharedN' /><!-- 공유안함 -->
					</td>
				</tr>
				<covi:admin>
				<tr>
					<th><spring:message code='Cache.lbl_LinkSchedule' /></th><!-- 연결 일정 -->
					<td colspan="3">
						<select name="" id="LinkFolderID" class="selectType02" >
						</select>
						&nbsp;
						<span id="PersonLinkFolder" style="display: none">
							<input type="text" class="HtmlCheckXSS ScriptCheckXSS" id="PersonLinkName" readonly style="width:200px">
							<input type="hidden" id="PersonLinkCode" >
							<a href="#" id="aPersonLinkCode" class="btnTypeDefault search"  onclick="folderPopup.openOrgMapPopup('P')"></a>
						</span>
					</td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_SecurityLevel' /></th><!-- 보안등급 -->
					<td>
						<select name="" id="SecurityLevel" class="selectType02" ></select>
					</td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_IsUse' /></th><!-- 사용여부 -->
					<td>
						<input type="radio" name="IsUse" id="IsUse_Y" value="Y"/>&nbsp;<spring:message code='Cache.lbl_USE_Y' /><!-- 사용함 -->&nbsp;
						<input type="radio" name="IsUse" id="IsUse_N" value="N" />&nbsp;<spring:message code='Cache.lbl_noUse' /><!-- 사용안함 -->
					</td>
					<th><spring:message code='Cache.lbl_DisplayYN' /></th><!-- 표시유무 -->
					<td>
						<input type="radio" name="IsDisplay" id="IsDisplay_Y" value="Y"/>&nbsp;<spring:message code='Cache.lbl_Display2' /><!-- 표시함 -->&nbsp;
						<input type="radio" name="IsDisplay" id="IsDisplay_N" value="N" />&nbsp;<spring:message code='Cache.lbl_noDisplay' /><!-- 표시안함 -->
					</td>
				</tr>
		   <%-- <tr>
					<th><spring:message code='Cache.lbl_IsURL' /></th><!-- URL 사용 -->
					<td>
						<input type="radio" name="IsURL" id="IsURL_Y" value="Y"/>&nbsp;<spring:message code='Cache.lbl_USE_Y' /><!-- 사용함 -->&nbsp;
						<input type="radio" name="IsURL" id="IsURL_N" value="N" />&nbsp;<spring:message code='Cache.lbl_noUse' /><!-- 사용안함 -->
					</td>
					<th><spring:message code='Cache.lbl_AdminSubMenu' /></th>
					<td>
						<input type="radio" name="IsAdminSubMenu" id="IsAdminSubMenu_Y" value="Y"/>&nbsp;<spring:message code='Cache.lbl_Display2' />&nbsp;
						<input type="radio" name="IsAdminSubMenu" id="IsAdminSubMenu_N" value="N"/>&nbsp;<spring:message code='Cache.lbl_noDisplay' />
					</td>
				</tr> --%>
			<%-- <tr>
					<th><spring:message code='Cache.lbl_URL' /></th><!-- URL -->
					<td colspan="3">
						<input type="text" class="HtmlCheckXSS ScriptCheckXSS" id="URL"  >
					</td>
				</tr> --%>
				</covi:admin>
				<tr>
					<th><spring:message code='Cache.lbl_explanation' /></th><!-- 설명 -->
					<td colspan="3">
						<textarea id="Description" class="HtmlCheckXSS ScriptCheckXSS w100" rows="6" style="resize:none"></textarea>
					</td>
				</tr>
			</table>
		</div>
		<div id="searchTab_AuthSetting" style="display: none; margin-top: 10px;">
			<div id="con_acl" style="margin-top: 10px;"></div>
		</div>
		<div class="bottomBtnWrap">
			<a class="btnTypeDefault btnTypeBg" id="btnSave"><spring:message code='Cache.btn_register' /></a><!-- 등록 -->
	     	<a onclick="Common.Close();"  class="btnTypeDefault" ><spring:message code='Cache.btn_apv_close'/></a>                    
		</div>
	</div>
	<input type="hidden" id="hidMemberOf" value="" />
</body>
<script type="text/javascript">
//다국어 특수문자 처리 위한 정규표현식.
var regExp = /\&nbsp\;|\&quot\;|\&apos\;|\;|\"|\'|\&/g;
var coviACL = null;
var g_isRoot = false;
var g_isInherited = false;	// 권한 상속 여부
var g_hasChild = false;		// 자식 객체 존재 여부

var folderPopup = {			
	lang : Common.getSession()["lang"],
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

		//탭메뉴 클릭
		$(".tabMenu li").on( 'click',function(){
			$(".tabMenu li").toggleClass("active");
			var str = $(this).attr("value");
			if(str == "basic") {
				$("#searchTab_Basic").show();	
				$("#searchTab_AuthSetting").hide();
			}else if(str == "authSetting") {
				$("#searchTab_Basic").hide();	
				$("#searchTab_AuthSetting").show();
			}
			
			$(window).resize();
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
		<covi:admin>
		$("#IsUse_Y").attr("checked", true);						//사용여부
		$("#IsDisplay_Y").attr("checked", true);					//표시유무
		$("#IsURL_N").attr("checked", true);						//URL 사용
		$("#IsAdminSubMenu_Y").attr("checked", true);
		</covi:admin>
		
		var option = {
			lang : lang, 
			allowedACL : '_CDMEVR',
			initialACL : '_CDMEVR',
			hasButton : false,
			orgMapCallback : 'orgCallback',
			aclCallback : 'aclCallback',
			systemType : "Schedule",
			useInherited : false,
			objectID : folderPopup.FolderID,
			objectType : "FD"
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
			ajaxUrl: "/groupware/manage/schedule/getFolderTypeData.do",
			ajaxPars: {"ScheduleType" : this.ScheduleType, "MemberOf" : this.FolderID},
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
			ajaxUrl: "/groupware/manage/schedule/getLinkFolderListData.do",
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
		    url: "/groupware/manage/schedule/getAdminFolderData.do",
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
		            	$("#DisplayName").val(CFN_GetDicInfo(folderData.MultiDisplayName));
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
				CFN_ErrorAjax("/groupware/manage/schedule/getAdminFolderData.do", response, status, error);
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

		var selectedColor = coviCtrl.getSelectColor();
		$("#DefaultColor").val(selectedColor.split(":")[1]);
		$$(folderDataObj).append("FolderID", this.FolderID);
		$$(folderDataObj).append("ScheduleType", this.ScheduleType);
		$$(folderDataObj).append("DomainID", this.DomainID);
		$$(folderDataObj).append("DisplayName", DisplayName);
		$$(folderDataObj).append("FolderType", FolderType);
		$$(folderDataObj).append("MemberOf", this.mode == "I" ? this.FolderID : $("#hidMemberOf").val());
		$$(folderDataObj).append("MultiDisplayName", MultiDisplayName);
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
		var aclActionData = coviACL_getACLActionData('con_acl');
		
		if(aclData == '[]'){
			Common.Warning("<spring:message code='Cache.msg_Common_01'/>");	// 사용권한을 설정해 주십시오.
			return;
		}
		
		$.ajax({
		    url: "/groupware/manage/schedule/saveAdminFolderData.do",
		    type: "POST",
		    data: {
		    	"mode":this.mode,
				"folderData":JSON.stringify(folderDataObj),
				"aclIsChange" : aclIsChange,
				"aclData":aclData,
				"aclActionData":aclActionData
			},
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
		            Common.Inform("<spring:message code='Cache.msg_117'/>", "Information", function(){		            	
		            	parent.confSchedule.setFolderData();	
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
		// 연결일정 SELECT BOX
		$("#LinkFolderID").bindSelect({
			reserveKeys: {
				options: "list",
				optionValue: "optionValue",
				optionText: "optionText",
				optionData: "optionData"
			},
			ajaxUrl: "/groupware/manage/schedule/getLinkFolderListData.do",
			ajaxPars: {
				manageCompany: this.DomainID,
				folderType : (type == "ScheduleShare" ? type : "")
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
		
		if(type == "Folder"){
			$("#pDefaultColor").hide();
			$("#btnColorSetting").hide();
			$("#IsShared_N").prop("checked", true);
			$("[name=IsShared]").parent("td").css("opacity", "0.3");
			$("[name=IsShared]").attr("disabled", "disabled");
			
			$("#OwnerCode").val("");
			$("#OwnerName").val("");
			$("#OwnerName").attr("disabled", "disabled");
			$("#aOwnerCode").hide();
			
			$("#LinkFolderID").bindSelectSetValue("none");
			$("#LinkFolderID").bindSelectDisabled(true);
			
			$("[name=IsAdminSubMenu]").parent("td").css("opacity", "1");
			$("[name=IsAdminSubMenu]").removeAttr("disabled");
		}else{
			$("#pDefaultColor").show();
			$("#btnColorSetting").show();
			
			$("#OwnerCode").val("");
			$("#OwnerName").val("");
			$("#OwnerName").removeAttr("disabled");
			$("#aOwnerCode").show();
			
			if(type == "Schedule" || type == "SchedulePerson"){
				$("[name=IsShared]").parent("td").css("opacity", "1");
				$("[name=IsShared]").removeAttr("disabled");
				
				$("#LinkFolderID").bindSelectSetValue("none");
				$("#LinkFolderID").bindSelectDisabled(true);
			}else if(type == "ScheduleShare"){
				$("[name=IsShared]").parent("td").css("opacity", "0.3");
				$("[name=IsShared]").attr("disabled", "disabled");
				
				$("#IsShared_N").prop("checked", true);
				$("#LinkFolderID").bindSelectDisabled(false);
			}
			
			$("#IsAdminSubMenu_Y").prop("checked", true);
			
			$("[name=IsAdminSubMenu]").parent("td").css("opacity", "0.3");
			$("[name=IsAdminSubMenu]").attr("disabled", "disabled");
		}
	}
}

$(document).ready(function(){
	folderPopup.initContent();
});

//상위 권한 상속
var selectInheritedACL = function(){	
	$.ajax({
		url: "/groupware/manage/schedule/selectBoardACLData.do",
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
				var exAclList = JSON.parse(coviACL_getACLData("con_acl").aclData);
				
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
			CFN_ErrorAjax("/groupware/manage/schedule/selectBoardACLData.do", response, status, error);
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
</script>