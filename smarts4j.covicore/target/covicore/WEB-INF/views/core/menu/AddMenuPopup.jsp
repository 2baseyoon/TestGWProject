<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil,egovframework.coviframework.util.RedisDataUtil,egovframework.baseframework.util.SessionHelper"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>
<% 
	String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path");
%>

<link rel="stylesheet" type="text/css" href="<%=cssPath%>/collaboration/resources/css/collaboration.css<%=resourceVersion%>">
<style type="text/css">
#con_AccessAuthDiv .authPermissions table tr td:nth-child(11) {
	border-right: 1px dashed #ddd;
}

#con_AccessAuthDiv .authPermissions .userlist table tr td {
	padding: 5px !important;
}

.authPermissions {
	height: 200px;
	overflow: auto;
	border-bottom: 1px solid #d7d7d7;
}
</style>
<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code="Cache.CN_4" /> - <spring:message code='Cache.tte_UserMenuModifyOrCreate'/></span>
	<!-- 사용자 메뉴 관리 -->
</h3>
<form>
	<div class="AXTabs" style="margin-bottom: 10px">
		<div class="AXTabsTray" style="height: 30px">
			<a href="javascript:;" onclick="clickTab(this);" class="AXTab on" value="Basic"><spring:message code="Cache.lbl_SettingDefault" /></a> <!-- 기본설정 -->
			<a href="javascript:;" onclick="clickTab(this);" class="AXTab" value="Auth"><spring:message code="Cache.lbl_SettingPermission" /></a> <!-- 권한설정 -->
		</div>
	</div>
	<div class="TabBox">
		<div id="searchTab_Basic">
			<div>
				<table class="AXFormTable" style="margin-top: 10px;width: 99%;">
					<colgroup>
						<col width="20%" />
						<col width="30%" />
						<col width="20%" />
						<col width="30%" />
					</colgroup>
					<tr>
						<th><spring:message code='Cache.lbl_MenuName' /><!-- 메뉴이름 --></th>
						<td colspan="3">
							<input type="text" id="txtMenuName" class="HtmlCheckXSS ScriptCheckXSS" style="width: 75%" />
							<input type="button" value="<spring:message code='Cache.lbl_MultiLang3'/>" class="AXButton" onclick="dictionaryLayerPopup('txtMenuName');" />
						</td>
					</tr>
					<tr>
						<th><spring:message code='Cache.lbl_menuType' /><!-- 메뉴유형 --></th>
						<td>
							<select id="cboMenuType" class="AXSelect" ></select>
						</td>
 						<th><span class="domain"><spring:message code='Cache.lbl_Enterprise_By'/>(<spring:message code='Cache.lbl_apv_formcreate_LCODE13'/>)</span></th>
					    <td>
					    	<span class="domain">
		                    	<select id="cboIsCopy"  class="AXSelect">
		                    		<option value="Y"><spring:message code='Cache.lbl_apv_formcreate_LCODE13'/></option>
									<option value="N"><spring:message code='Cache.lbl_apv_formcreate_LCODE14'/></option>
		                    	</select>
		                    </span>
						</td>
					</tr>
					<tr>
						<th><spring:message code='Cache.lbl_Sort' /><!-- 정렬 --></th>
						<td>
							<input type="text" id="txtMenuSort" style="width: 100%" readonly/>
						</td>
						<th><spring:message code='Cache.IsUse_Y' /><!-- 사용 --></th>
						<td>
							<select id="cboUse" class="AXSelect" ></select>
						</td>
					</tr>			
					<tr>
						<th><spring:message code='Cache.lbl_BizSection' /><!-- 업무구분 --></th>
						<td><div id="cboBizSection"></div></td>
						<th><spring:message code='Cache.lbl_MenuLocation' /><!-- 메뉴 위치 --></th>
						<td>
							<select id="cboSiteMapPosition" class="AXSelect" ></select>
						</td>
					</tr>
					<tr>
						<th><spring:message code='Cache.lbl_LinkURL' /><!-- 연결 URL --></th>
						<td colspan="3">
							<input type="text" id="txtMenuUrl" class="HtmlCheckXSS ScriptCheckXSS" style="width: 100%" />
						</td>
					</tr>
					<tr>
						<th><spring:message code='Cache.lbl_LandingURL' /><!-- 랜딩 URL --></th>
						<td colspan="3">
							<input type="text" id="txtReserved5" class="HtmlCheckXSS ScriptCheckXSS" style="width: 100%" />
						</td>
					</tr>
					<tr>
						<th>Mobile URL</th>
						<td colspan="3">
							<input type="text" id="txtMenuMobileUrl" class="HtmlCheckXSS ScriptCheckXSS" style="width: 100%" />
						</td>
					</tr>
					<tr>
						<th>Target</th>
						<td>
							<select id="cboTarget" class="AXSelect" ></select>
						</td>
						<th>Mobile Target</th>
						<td>
							<select id="cboMobileTarget" class="AXSelect" ></select>
						</td>
					</tr>
					<tr>
						<th><spring:message code='Cache.lbl_Reserved' />1</th> <!-- 예비1 -->
						<td>
							<input type="text" id="txtReserved1" class="HtmlCheckXSS ScriptCheckXSS" style="width: 100%" />
						</td>
						<th><spring:message code='Cache.lbl_Reserved' />2</th> <!-- 예비2 -->
						<td>
							<input type="text" id="txtReserved2" class="HtmlCheckXSS ScriptCheckXSS" style="width: 100%" />
						</td>
					</tr>
					<tr>
					<th><spring:message code='Cache.lbl_SeviceDevice' /><!-- 서비스 장치 --></th>
						<td>
							<select id="cboDevice" class="AXSelect" ></select>
						</td> 
						<th>Icon 클래스명</th>
						<td colspan="3">
							<input type="text" id="txtMenuIcon" class="AXInput HtmlCheckXSS ScriptCheckXSS" style="width: 100%" />
						</td>
					</tr>					
					<tr style="height: 50px">
						<th><spring:message code='Cache.lbl_Description' /><!-- 설명 --></th>
						<td colspan="3">
							<textarea id="txtDescription" rows="3" style="width: 98%" class="AXTextarea HtmlCheckXSS ScriptCheckXSS"></textarea>
						</td>
					</tr>
				</table>
			</div>
			<br/>
		</div>
		<div id="searchTab_Auth" style="display: none">
			<div id="con_AccessAuthDiv"></div>
		</div>
	</div>
	<div align="center"	style="margin-top: 20px;">
		<input type="button" value="<spring:message code='Cache.btn_save'/>" class="AXButton Red" onclick="saveMenuInfo();" /><!-- 저장 -->
		<input type="button" value="<spring:message code="Cache.btn_Close"/>" class="AXButton" onclick="Common.Close();" />
	</div>
	<input type="hidden" id="hidMenuName" value="" />
	<input type="hidden" id="hidMemberOf" value="" />
	<input type="hidden" id="OrgMapHidden" value="" />
	<input type="hidden" id="txtPGID" value="" />
	<input type="hidden" id="txtMNID" value="" />
	<input type="hidden" id="txtPeople" value="" />
	<input type="hidden" id="txtDept" value="" />
	<input type="hidden" id="txtAclListID" value="" />
	<input type="hidden" id="txtAclID" value="" />
	<input type="hidden" id="txtDicID" value="" />
	<input type="hidden" id="txtACLInfo" value="" />
</form>
<script>
	var domainId = CFN_GetQueryString("domainId") == 'undefined'? '' : CFN_GetQueryString("domainId");
	var isAdmin = CFN_GetQueryString("isAdmin") == 'undefined'? '' : CFN_GetQueryString("isAdmin");
	var ttId = CFN_GetQueryString("ttId") == 'undefined'? '' : CFN_GetQueryString("ttId");
	var menuId = CFN_GetQueryString("menuId") == 'undefined'? '' : CFN_GetQueryString("menuId");
	var mode = CFN_GetQueryString("mode") == 'undefined'? '' : CFN_GetQueryString("mode");
	var popupTagetID = CFN_GetQueryString("popupTargetID") == 'undefined'? '' : CFN_GetQueryString("popupTargetID");
	var bizSection = CFN_GetQueryString("bizSection") == 'undefined'? '' : CFN_GetQueryString("bizSection");
	var g_isInherited = false;	// 권한 상속 여부
	var g_hasChild = false;		// 자식 객체 존재 여부
	
	window.onload = initContent();
	
	function initContent(){ 
		setSelectBox();
		renderingACL();
		
		if ((mode === "add" && ttId) || (mode !== "add" && ttId.split("-").length > 1)) {
			coviCtrl.setSelected('cboBizSection', bizSection);
		}
	};

	function selectRenderComplete(){
		if (mode == "modify") {
			getMenuData(menuId);
			getACL(menuId);
		} else {
			getACL(menuId);
		}
	}
	
	var coviACL;
	function renderingACL(){
		var option = {
			lang : 'ko', 
			hasButton : 'false', 
			allowedACL : '',
			initialACL : '',
			orgMapCallback : 'orgCallback',
			aclCallback : 'aclCallback',
			systemType : "Menu"
		};
		
		if ((mode === "add" && ttId) || (mode !== "add" && ttId.split("-").length > 1)) {
			option["useInherited"] = true;
			option["inheritedFunc"] = "getInheritedACL";
		}
		
		coviACL = new CoviACL(option);
		coviACL.render('con_AccessAuthDiv');
	}
	
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
				sDisplayName = CFN_GetDicInfo(item.DN, coviACL.config.lang);				
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
			
			$('#con_AccessAuthDiv_hTbdPermissions').find('tr').each(function(){
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
	
	function aclCallback(data){
		coviCmn.traceLog(data);
	}
	
	function getACL(menuId){
		$.ajax({
			type:"POST",
			data:{
				"ObjectID" : menuId,
				"ObjectType" : "MN"
			},
			url:"/covicore/menu/getacl.do",
			success : function (res) {
				if(res.result == "ok"){
					if ((res.data).length > 0) coviACL.set(res.data);
				} else {
					parent.Common.Error("<spring:message code='Cache.ACC_msg_error'/>");	//오류가 발생하였습니다. 관리자에게 문의 바랍니다.
				}
			},
			error : function(response, status, error){
				CFN_ErrorAjax("/covicore/menu/getacl.do", response, status, error);
			}
		});
	}
	
	function getInheritedACL(){
		var inheritedObjectID = $("#hidMemberOf").val() ? $("#hidMemberOf").val() : menuId;
		
		$.ajax({
			type: "POST",
			data: {
				"ObjectID": inheritedObjectID,
				"ObjectType": "MN"
			},
			url: "/covicore/menu/getacl.do",
			success: function(res){
				if (res.status === "SUCCESS") {
					var aclList = [];
					var exAclList = JSON.parse(coviACL_getACLData("con_AccessAuthDiv"));
					
					$(res.data).each(function(idx, item){
						var exist = exAclList.map(function(exAcl){
							return exAcl.SubjectCode === item.SubjectCode;
						});
						
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
							
							coviACL_deleteACLBySubject("con_AccessAuthDiv", item.SubjectCode);
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
					
					var jsonData = {"item": aclList, "isInHerited": true, "inheritedObjectID": inheritedObjectID};
					
					// 모든 하이라이트 해제
					$('.aclSubject').css("background-color", "inherit");
					$('.aclSubject').removeAttr("data-clicked");
					
					coviACL.addSubjectRow(JSON.stringify(jsonData));
					setAuthSetting(jsonData.item);
				} else {
					parent.Common.Error("<spring:message code='Cache.ACC_msg_error'/>");	//오류가 발생하였습니다. 관리자에게 문의 바랍니다.
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/covicore/menu/getacl.do", response, status, error);
			}
		});
	}
	
	function getMenuData(menuId){
		$.ajax({
			type:"POST",
			data:{
				"menuID" : menuId
			},
			url:"/covicore/menu/get.do",
			success : function (res) {
				if(res.result == "ok"){
					bindMenuData(res.list[0]);
					$("#hidMemberOf").val(res.list[0].MemberOf);
				} else {
					parent.Common.Error("<spring:message code='Cache.ACC_msg_error'/>");	//오류가 발생하였습니다. 관리자에게 문의 바랍니다.
				}
			},
			error : function(response, status, error){
				CFN_ErrorAjax("/covicore/menu/get.do", response, status, error);
			}
		});
	}
	
	function bindMenuData(data) {
		$("#txtMenuName").val(data.DisplayName); //메뉴이름, txtMenuName
		$("#txtMenuIcon").val(data.IconClass); //메뉴이름, txtMenuName
		$("#cboMenuType").bindSelectSetValue(data.MenuType); //메뉴유형, cboMenuType, [Top, TopSub, Left, Hidden]
		$("#cboIsCopy").val(data.IsCopy); //계열사사ㅓ여부, cboMenuType, [Top, TopSub, Left, Hidden]
		$("#cboTarget").bindSelectSetValue(data.Target); //Target, cboTarget
		$("#cboMobileTarget").bindSelectSetValue(data.MobileTarget); //Target, cboTarget
		$("#txtMenuSort").val(data.SortKey); //정렬, txtMenuSort 
		$("#cboUse").bindSelectSetValue(data.IsUse); //사용유무, cboUse
		$("#cboIsCopy").bindSelectSetValue(data.IsCopy); //사용유무, cboUse
		$("#cboSecurity").bindSelectSetValue(data.SecurityLevel); //보안등급, cboSecurity		
		$("#txtMenuUrl").val(data.URL); //연결URL, txtMenuUrl
		$("#txtMenuMobileUrl").val(data.MobileURL); //연결URL, txtMenuUrl
		$("#cboDevice").bindSelectSetValue(data.ServiceDevice); //서비스장치, cboDevice
		$("#txtDescription").val(data.Description); //설명, txtDescription
		$("#txtReserved1").val(data.Reserved1); //예비1, txtReserved1
		$("#txtReserved2").val(data.Reserved2); //예비2, txtReserved2
		$("#cboSiteMapPosition").bindSelectSetValue(data.SiteMapPosition); //sitemap 위치		
		//다국어
		$("#hidMenuName").val(data.MultiDisplayName);
		$("#cboSiteMapPosition").bindSelectSetValue(data.SiteMapPosition); //사용유무, cboUse
		$("#txtReserved5").val(data.Reserved5); //최종 url

		if (data.DomainID != "0" && data.OriginMenuID != ""){//상속 받은 메뉴임
			$("#txtMenuUrl").attr("disabled", true);
			$("#txtMenuMobileUrl").attr("disabled", true);
			$("#txtReserved5").attr("disabled", true);
		}
		else{
			$("#txtMenuUrl").attr("disabled", false);
			$("#txtMenuMobileUrl").attr("disabled", false);
			$("#txtReserved5").attr("disabled", false);
		}	
		
		coviCtrl.setSelected('cboBizSection', data.BizSection);
	}
	
	function saveMenuInfo() {
		if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

		if ($('#txtMenuName').val() == '') {
			parent.Common.Warning("<spring:message code='Cache.msg_FillMenuName'/>"); //메뉴이름을 작성하여 주십시오.
			$('#txtMenuName').focus();
			return;
		}
		
		if ($('#cboMenuType option:selected').val() == 'MenuType') {
			parent.Common.Warning("<spring:message code='Cache.msg_SelectMenuType'/>"); //메뉴유형을 선택하여 주십시오.
			return;
		}		

		if ($('#txtMenuName').val().indexOf(';') > -1 ||
				$('#txtMenuName').val().indexOf('\'') > -1 ||
				$('#txtMenuName').val().indexOf('&apos;') > -1 ||
				$('#txtMenuName').val().indexOf('\"') > -1 ||
				$('#txtMenuName').val().indexOf('&quot;') > -1 ) {
			var sMessage = String.format("<spring:message code='Cache.msg_DictionaryInfo_01' />", '\' \" ;') ; // 특수문자 [' " ;]는 사용할 수 없습니다.
			sMessage += "(<spring:message code='Cache.lbl_MenuName'/>)"; // 특수문자 [' " ;]는 사용할 수 없습니다. (메뉴이름)
			parent.Common.Warning(sMessage, 'Warning Dialog', function () {
				$('#txtMenuName').focus();
			});
			return;
		}

		// 다국어 입력 체크
		var multiDisplayName = $("#hidMenuName").val();
		if(	multiDisplayName != null && multiDisplayName != '' && multiDisplayName.indexOf(';') > -1) {
		var arrTarget = multiDisplayName.split(';');
			if( arrTarget.length > 11 || ( multiDisplayName.indexOf('\'') > -1 ||
					multiDisplayName.indexOf('&apos;') > -1 ||
					multiDisplayName.indexOf('\"') > -1 ||
					multiDisplayName.indexOf('&quot;') > -1 ) ) {
						var sMessage = String.format("<spring:message code='Cache.msg_DictionaryInfo_01' />", '\' \" ;') ; // 특수문자 [' " ;]는 사용할 수 없습니다.
						sMessage += "(<spring:message code='Cache.lbl_MultiLang'/> <spring:message code='Cache.lbl_MenuName'/>)"; // 특수문자 [' " ;]는 사용할 수 없습니다. (다국어 메뉴이름))
						parent.Common.Warning(sMessage, 'Warning Dialog', function () {
							$('#txtMenuName').focus();
						});
				return;
			}
		}
		
		var aclData = coviACL_getACLData('con_AccessAuthDiv');
		var aclActionData = coviACL_getACLActionData('con_AccessAuthDiv');
		
		if(mode == "add") {
		    var parentObjectId;
		    var parentObjectType;
		    var sortKey;
		    var sortPath;
		    var memberOf;
		    var $row;
		    var $childRow;
		    var menuPath;
		   
		    if(ttId == ''){
		    	if(parent.$('tr[data-memberof=0]').length > 0){
		    		sortKey = Number(parent.$('tr[data-memberof=0]').last().attr('data-sortkey')) + 1;
				} else {
					sortKey = 0;
				}
		    	
		    	sortPath = parent.coviCtrl.pad(sortKey, 15) + ';';
			    parentObjectId = domainId;
			    parentObjectType = 'DN';
			    memberOf = '0';
		    } else {
		    	$row = parent.$("tr[data-tt-id=" + ttId + "]");
		    	$childRow = parent.$("tr[data-tt-parent-id=" + ttId + "]");
		    	
		    	if($childRow.length > 0){
		    		sortKey = Number($childRow.last().attr('data-sortkey')) + 1;
		    	} else {
		    		sortKey = 0;
		    	}
		    	
		    	sortPath = $row.attr('data-sortpath') + parent.coviCtrl.pad(sortKey, 15) + ';';
		    	parentObjectId = menuId;
			    parentObjectType = 'MN';
			    memberOf = menuId;
		    }
		    
			var pData = {
				"domainID" : domainId, // 도메인 아이디
				"isAdmin" : isAdmin,
				"parentObjectID" : parentObjectId, // 부모 object id
				"parentObjectType" : parentObjectType, // 부모 object type
				"displayName" : $("#txtMenuName").val(), // 메뉴 이름
				"multiDisplayName" : $("#hidMenuName").val(), // 다국어 
				"iconClass" : $("#txtMenuIcon").val(),
				"menuType" : $("#cboMenuType option:selected").val(), //메뉴유형
				"bizSection" :  $("#cboBizSection option:selected").val(),  //업무구분
				"target" : $("#cboTarget option:selected").val(), //Target
				"mobileTarget" : $("#cboMobileTarget option:selected").val(), //Target
				"sortKey" : sortKey, //정렬
				"sortPath" : sortPath, //정렬 경로
				"isUse" : $("#cboUse option:selected").val(), //사용유무
				"isCopy" : $("#cboIsCopy option:selected").val(), //사용유무
				"securityLevel" : $("#cboSecurity option:selected").val(), //보안등급
				"url" : $("#txtMenuUrl").val(), //연결URL
				"mobileUrl" : $("#txtMenuMobileUrl").val(), //연결URL
				"serviceDevice" : $("#cboDevice option:selected").val(), //서비스장치
				"description" : $("#txtDescription").val(), //설명
				"aclInfo" :  encodeURIComponent(aclData), // AclInfo
				"aclActionInfo" :  encodeURIComponent(aclActionData), // AclActionInfo
				"memberOf" : memberOf, // 상위 메뉴
				"reserved1" : $("#txtReserved1").val(), //예비1
				"reserved2" : $("#txtReserved2").val(), //예비2					
				"reserved5" : $("#txtReserved5").val(), //최종 url
				"siteMapPosition" : $("#cboSiteMapPosition option:selected").val(), //사이트맵 위치
				"isInherited" : $("#con_AccessAuthDiv_isInherited").is(":checked") ? "Y" : "N" // 권한 상속 여부
			};
			
			$.ajax({
				type : "POST",
				data : pData,
				url : "/covicore/menu/add.do",
				success : function(data) {
					if(data.result == 'ok'){
						var html = parent.coviCtrl.makeRowForTreeTable(data.list[0]);
						if(ttId == ''){
							parent.coviCtrl.treeTableLoadBranch(null, html);
						} else{
							parent.coviCtrl.treeTableLoadBranch(ttId, html);	
						}
						parent.coviCtrl.makeDraggable();
						parent.Common.Inform("<spring:message code='Cache.msg_37'/>")	//저장되었습니다.
						parent.Common.close(popupTagetID);
					} else{
						parent.Common.Error("<spring:message code='Cache.ACC_msg_error'/>");	//오류가 발생하였습니다. 관리자에게 문의 바랍니다.
					}
				},
				error : function(response, status, error){
					CFN_ErrorAjax("/covicore/menu/add.do", response, status, error);
				}
			});
		} else if(mode == "modify") {			
			var pData = {
				"domainID" : domainId, // 도메인 아이디
				"menuID" : menuId, // 메뉴 이름
				"displayName" : $("#txtMenuName").val(), // 메뉴 이름
				"multiDisplayName" : $("#hidMenuName").val(), // 다국어
				"iconClass" : $("#txtMenuIcon").val(),
				"menuType" : $("#cboMenuType option:selected").val(), //메뉴유형
				"bizSection" : $("#cboBizSection option:selected").val(),  //업무구분
				"target" : $("#cboTarget option:selected").val(), //Target
				"mobileTarget" : $("#cboMobileTarget option:selected").val(), //Target
				"isUse" : $("#cboUse option:selected").val(), //사용유무
				"isCopy" : $("#cboIsCopy option:selected").val(), //계열사사용유무
				"securityLevel" : $("#cboSecurity option:selected").val(), //보안등급
				"url" : $("#txtMenuUrl").val(), //연결URL
				"mobileUrl" : $("#txtMenuMobileUrl").val(), //연결URL
				"serviceDevice" : $("#cboDevice option:selected").val(), //서비스장치
				"description" : $("#txtDescription").val(), //설명
				"aclInfo" :  encodeURIComponent(aclData), // AclInfo
				"aclActionInfo" :  encodeURIComponent(aclActionData), // AclActionInfo
				"memberOf" : $("#hidMemberOf").val(), // 상위 메뉴
				"reserved1" :  $("#txtReserved1").val(), // 예비1
				"reserved2" : $("#txtReserved2").val(),  //예비2
				"reserved5" : $("#txtReserved5").val(), //최종 url
				"siteMapPosition" : $("#cboSiteMapPosition option:selected").val(), //사이트맵 위치				
				"isInherited" : $("#con_AccessAuthDiv_isInherited").is(":checked") ? "Y" : "N" // 권한 상속 여부
			};
			
 			$.ajax({
				type : "POST",
				data : pData,
				url : "/covicore/menu/modify.do",
				success : function(data) {
					if(data.result == 'ok'){
						parent.$("tr[data-menuid=" + pData["menuID"] + "] td").each(function(){
							$(this).find('span').each(function(){
								var name = $(this).attr("name");
								if(data.list[0][name] != undefined){
									$(this).text(data.list[0][name]);
								}
							});
						});
						
						parent.Common.Inform("<spring:message code='Cache.msg_37'/>", "Information", function(result){ // 저장되었습니다.
							if (result) {
								parent.Common.close(popupTagetID);
							}
						});
					} else {
						parent.Common.Error("<spring:message code='Cache.ACC_msg_error'/>");	//오류가 발생하였습니다. 관리자에게 문의 바랍니다.
					}
				},
				error : function(response, status, error){
					CFN_ErrorAjax("/covicore/menu/modify.do", response, status, error);
				}
			});
		}
	}
	
	// 기본설정 - 다국어 레이어팝업
	function dictionaryLayerPopup() {
		var option = {
				lang : 'ko',
				hasTransBtn : 'true',
				allowedLang : 'ko,en,ja,zh',
				useShort : 'false',
				dicCallback : 'addMenuDicCallback',
				popupTargetID : 'DictionaryPopup',
				init : 'initDicPopup'
		};
		
		var url = "";
		url += "/covicore/control/calldic.do?lang=" + option.lang;
		url += "&hasTransBtn=" + option.hasTransBtn;
		url += "&useShort=" + option.useShort;
		url += "&dicCallback=" + option.dicCallback;
		url += "&allowedLang=" + option.allowedLang;
		url += "&popupTargetID=" + option.popupTargetID;
		url += "&init=" + option.init;
		
		//CFN_OpenWindow(url,"다국어 지정",500,300,"");
		Common.open("", "DictionaryPopup", "<spring:message code='Cache.lbl_MultiLangSet'/>", url, "500px", "250px", "iframe", true, null, null, true);
	}
	
	function initDicPopup(){
		return $('#hidMenuName').val();
	}
	
	function addMenuDicCallback(data){
		$('#txtMenuName').val(data.KoFull);
		$('#hidMenuName').val(coviDic.convertDic(data))
		Common.close("DictionaryPopup");
	}
	
	function clickTab(pObj) {
		$(".AXTab").attr("class", "AXTab");
		$(pObj).addClass("AXTab on");

		var str = $(pObj).attr("value");

		$("#searchTab_Basic").hide();
		$("#searchTab_Auth").hide();

		if (str == "Basic") {
			$("#searchTab_Basic").show();
		} else if (str == "Auth") {
			$("#searchTab_Auth").show();
		}
	}
	
	function setSelectBox() {
		var initInfos = [{
		         			target : 'cboBizSection',
		         			codeGroup : 'BizSection',
		         			defaultVal : '',
		         			width : '100',
		         			onchange : ''
		         		}];
		         		
		coviCtrl.renderAjaxSelect(initInfos, '', 'ko');		
		coviCtrl.renderAXSelect(
			"MenuType,SecurityLevel,ServiceDevice",
			"cboMenuType,cboSecurity,cboDevice",
			"ko",
			null,
			"selectRenderComplete"
		);

		$("#cboTarget").bindSelect({
			reserveKeys : {
				optionValue : "value",
				optionText : "name"
			},
			options : [ {
				"name" : "<spring:message code='Cache.lbl_winSel1'/>",
				"value" : "Current"
			}, {
				"name" : "<spring:message code='Cache.lbl_winSel2'/>",
				"value" : "New"
			} ]
		});
		
		$("#cboMobileTarget").bindSelect({
			reserveKeys : {
				optionValue : "value",
				optionText : "name"
			},
			options : [ {
				"name" : "<spring:message code='Cache.lbl_winSel1'/>",
				"value" : "Current"
			}, {
				"name" : "<spring:message code='Cache.lbl_winSel2'/>",
				"value" : "New"
			} ]
		});

		$("#cboUse").bindSelect({
			reserveKeys : {
				optionValue : "value",
				optionText : "name"
			},
			options : [ {
				"name" : "<spring:message code='Cache.lbl_Use'/>",
				"value" : "Y"
			}, {
				"name" : "<spring:message code='Cache.lbl_NotUse'/>",
				"value" : "N"
			} ]
		});
		
		$("#cboSiteMapPosition").bindSelect({
			reserveKeys : {
				optionValue : "value",
				optionText : "name"
			},
			options : [ {
				"name" : "First Zone",
				"value" : "0"
			}, {
				"name" : "Second Zone",
				"value" : "1"
			}, {
				"name" : "Third Zone",
				"value" : "2"
			}, {
				"name" : "Fourth Zone",
				"value" : "3"
			} ]
		});
	}
	
	//# sourceURL=AddMenuPopup.jsp
</script>
