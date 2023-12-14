<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib uri="/WEB-INF/tlds/covi.tld" prefix="covi" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<style type="text/css">
#con_AccessAuthDiv .authPermissions table tr td:nth-child(11) { 
	border-right: 1px dashed #ddd;
}

#con_AccessAuthDiv .authPermissions .userlist table tr td { padding: 5px !important;}
</style>
<form>	
	<div class="sadmin_pop" id="sadmin_p">
		<ul class="tabMenu clearFloat">
			<li class="active"><a href="javascript:;" onclick="clickTab(this); setPopup(this);" value="Basic"><spring:message code="Cache.lbl_SettingDefault" /></a> <!-- 기본설정 --></li>			
			<c:if test="${(empty ttId and mode eq 'add') or mode eq 'modify'}">
				<li class=""><a href="javascript:;" onclick="clickTab(this); setPopup(this);" value="Auth"><spring:message code="Cache.lbl_SettingPermission" /></a> <!-- 권한설정 --></li>
			</c:if>
		</ul>
		<div class="tabContent active"  id="searchTab_Basic">
			<table class="sadmin_table sa_menuBasicSetting">
				<colgroup>
					<col width="20%" />
					<col width="30%" />
					<col width="20%" />
					<col width="30%" />
				</colgroup>
				<tbody>
					<tr>
						<th><spring:message code='Cache.lbl_MenuName' /><!-- 메뉴이름 --></th>
						<td colspan="3">
							<input type="text" id="txtMenuName" kind="dictionary" dic_src="hidMenuName" class="HtmlCheckXSS ScriptCheckXSS" style="width: 75%" />
							<a href="#"  kind="dictionaryBtn" src_elem="txtMenuName" class="btnTypeDefault" style="float: right;"><spring:message code='Cache.lbl_MultiLang2'/></a> 
						</td>
					</tr>
					<covi:admin>
					<tr>
						<th><spring:message code='Cache.lbl_menuType' /><!-- 메뉴유형 --></th>
						<td>
							<select id="cboMenuType" class="selectType02" ></select>
						</td>
						<th><span class="domain"><spring:message code='Cache.lbl_Enterprise_By'/>(<spring:message code='Cache.lbl_apv_formcreate_LCODE13'/>)</span></th>
					    <td>
					    	<span class="domain">
			                    <select id="cboIsCopy"  class="selectType02">
			                    	<option value="Y"><spring:message code='Cache.lbl_apv_formcreate_LCODE13'/></option>
									<option value="N"><spring:message code='Cache.lbl_apv_formcreate_LCODE14'/></option>
			                    </select>
		                    </span>
						</td>
					</tr>
					<tr>
						<th><spring:message code='Cache.lbl_Sort' /><!-- 정렬 --></th>
						<td>
							<input type="text" id="txtMenuSort" readonly/>
						</td>
						<th><spring:message code='Cache.IsUse_Y' /><!-- 사용 --></th>
						<td>
							<select id="cboUse" class="selectType02" ></select>
						</td>
					</tr>
					<tr>
						<th><spring:message code='Cache.lbl_BizSection' /><!-- 업무구분 --></th>
						<td>
							<select id="cboBizSection" class="selectType02" ></select>
						</td>
						<th><spring:message code='Cache.lbl_MenuLocation' /><!-- 메뉴 위치 --></th>
						<td>
							<select id="cboSiteMapPosition" class="selectType02" ></select>
						</td>
					</tr>
					<tr>
						<th><spring:message code='Cache.lbl_LinkURL' /><!-- 연결 URL --></th>
						<td colspan="3">
							<input type="text" id="txtMenuUrl" class="HtmlCheckXSS ScriptCheckXSS"/>
						</td>
					</tr>
					<tr>
						<th><spring:message code='Cache.lbl_LandingURL' /><!-- 랜딩 URL --></th>
						<td colspan="3">
							<input type="text" id="txtReserved5" class="HtmlCheckXSS ScriptCheckXSS"/>
						</td>
					</tr>
					<tr>
						<th>Mobile URL</th>
						<td colspan="3">
							<input type="text" id="txtMenuMobileUrl" class="HtmlCheckXSS ScriptCheckXSS"/>
						</td>
					</tr>
					<tr>
						<th>Target</th>
						<td>
							<select id="cboTarget" class="selectType02" ></select>
						</td>
						<th>Mobile Target</th>
						<td>
							<select id="cboMobileTarget" class="selectType02" ></select>
						</td>
					</tr>
					<tr>
						<th><spring:message code='Cache.lbl_Reserved' />1</th> <!-- 예비1 -->
						<td>
							<input type="text" id="txtReserved1" class="HtmlCheckXSS ScriptCheckXSS" />
						</td>
						<th><spring:message code='Cache.lbl_Reserved' />2</th> <!-- 예비2 -->
						<td>
							<input type="text" id="txtReserved2" class="HtmlCheckXSS ScriptCheckXSS"/>
						</td>
					</tr>
					<tr>
						<th><spring:message code='Cache.lbl_SeviceDevice' /><!-- 서비스 장치 --></th>
						<td>
							<select id="cboDevice" class="selectType02" ></select>
						</td> 
						<th>Icon <spring:message code='Cache.ACC_lbl_className'/></th> <!-- ICON 클래스명 -->
						<td>
							<input type="text" id="txtMenuIcon" class="HtmlCheckXSS ScriptCheckXSS"/>
						</td>
					</tr>
					<tr>
						<th>별칭</th>
						<td colspan="3">
							<input type="text" id="txtMenuAlias" class="HtmlCheckXSS ScriptCheckXSS"/>
						</td>
					</tr>					
					<tr style="height: 50px">
						<th><spring:message code='Cache.lbl_Description' /><!-- 설명 --></th>
						<td colspan="3">
							<textarea id="txtDescription" rows="3" class="HtmlCheckXSS ScriptCheckXSS"></textarea>
						</td>
					</tr>
					</covi:admin>
				</tbody>	
			</table>
		</div>
		<div class="tabContent" id="searchTab_Auth" style="display: none">
			<div id="con_AccessAuthDiv"></div>
		</div>	
		<div align="center"	class="bottomBtnWrap">
			<a class="btnTypeDefault btnTypeBg"  onclick="saveMenuInfo();"><spring:message code='Cache.btn_save'/></a><!-- 저장 -->
			<a class="btnTypeDefault"  onclick="Common.Close();"><spring:message code='Cache.Cache.btn_Close'/></a>
		</div>
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
	var bizSectionObj = {};
	
	window.onload = initContent();

	$("input[kind='dictionary']").each(function(){
		$(this).click(function(){
			var pInitData = $(this).val();
			var dicCallback = "CFN_setDic" ;// $(this).attr("id")+"Dic_CallBack";
			
			if($(this).attr("dic_src") != undefined){
				if ($("#"+$(this).attr("dic_src")).val() != '') pInitData= $("#"+$(this).attr("dic_src")).val();
			} 
			
			if($(this).attr("dic_callback") != undefined){
				dicCallback=$(this).attr("dic_callback");
			}	
			
			var option = {
				lang : Common.getSession("lang"),
				hasTransBtn : 'true',
				allowedLang : 'ko,en,ja,zh',
				useShort : 'false',
				dicCallback : dicCallback,
				popupTargetID : 'DictionaryPopup',
				init : 'initDicPopup',
				dicID : $(this).attr("id")
			};
				
			coviCmn.openDicLayerPopup(option,"");
		})
	});
	
	$("a[kind='dictionaryBtn']").each(function(){
		$(this).click(function(){
			$('#'+$(this).attr("src_elem")).trigger('click');
		})
	});
	
	function initContent(){ 
		setSelectBox();
		renderingACL();
		
		if ((mode === "add" && bizSection)) {
			$("#cboBizSection").bindSelectSetValue(bizSection); //서비스장치, cboDevice
		}		
		
		$.each(Common.getBaseCode('BizSection').CacheData, function(idx, el){
			bizSectionObj[el.Code] = el;
		});
	}

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
		g_hasChild = (CFN_GetQueryString('hasChild') == 'Y');
		
		var option = {
			lang : 'ko', 
			hasButton : 'false', 
			allowedACL : '',
			initialACL : '',
			orgMapCallback : 'orgCallback',
			aclCallback : 'aclCallback',
			useUpdateChildren : Common.getBaseConfig("useMenuInherited"),
			systemType : "Menu",
			objectID : menuId,
			objectType : "MN"
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
			url:"/covicore/manage/menu/getacl.do",
			success : function (res) {
				if(res.result == "ok"){
					if ((res.data).length > 0) coviACL.set(res.data);
				} else {
					parent.Common.Error("<spring:message code='Cache.ACC_msg_error'/>");	//오류가 발생하였습니다. 관리자에게 문의 바랍니다.
				}
			},
			error : function(response, status, error){
				CFN_ErrorAjax("/covicore/manage/menu/getacl.do", response, status, error);
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
			url: "/covicore/manage/menu/getacl.do",
			success: function(res){
				if (res.status === "SUCCESS") {
					var aclList = [];
					var exAclList = JSON.parse(coviACL_getACLData("con_AccessAuthDiv").aclData);
					
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
				CFN_ErrorAjax("/covicore/manage/menu/getacl.do", response, status, error);
			}
		});
	}
	
	function getMenuData(menuId){
		console.log('getMenuData', menuId);
		$.ajax({
			type:"POST",
			async: false,
			data:{
				"menuID" : menuId
			},
			url:"/covicore/manage/menu/get.do",
			success : function (res) {
				if(res.result == "ok"){
					bindMenuData(res.list[0]);
					$("#hidMemberOf").val(res.list[0].MemberOf);
				} else {
					parent.Common.Error("<spring:message code='Cache.ACC_msg_error'/>");	//오류가 발생하였습니다. 관리자에게 문의 바랍니다.
				}
			},
			error : function(response, status, error){
				CFN_ErrorAjax("/covicore/manage/menu/get.do", response, status, error);
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
		
		$("#txtMenuAlias").val(data.MenuAlias); //예비3, 칼럼추가필요 txtMenuAlias
		
		$("#cboSiteMapPosition").bindSelectSetValue(data.SiteMapPosition); //sitemap 위치		
		//다국어
		$("#hidMenuName").val(data.MultiDisplayName);
		$("#cboBizSection").bindSelectSetValue(data.BizSection);

		$("#cboSiteMapPosition").bindSelectSetValue(data.SiteMapPosition); //사용유무, cboUse
		$("#txtReserved5").val(data.Reserved5); //최종 url

		if (data.DomainID != "0" && data.OriginMenuID != ""){//상속 받은 메뉴임
			$("#txtMenuUrl").attr("disabled", true);
			$("#txtMenuMobileUrl").attr("disabled", true);
			$("#txtReserved5").attr("disabled", true);
		} else{
			$("#txtMenuUrl").attr("disabled", false);
			$("#txtMenuMobileUrl").attr("disabled", false);
			$("#txtReserved5").attr("disabled", false);
		}
		
		// 권한 상속 여부
		g_isInherited = data.IsInherited == "Y" ? true : false;
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
		
		var selectedBizSection = $("#cboBizSection option:selected").val();
		if (typeof bizSectionObj[selectedBizSection] != 'undefined' && bizSectionObj[selectedBizSection].Reserved3 == 'Y') {
			if ($("#txtMenuAlias").val() == '' && ['Top', 'TopSub'].indexOf($("#cboMenuType option:selected").val()) > -1){
				parent.Common.Warning(Common.getDic('msg_required_menuAlias')); // 별칭을 입력해 주십시오.
				return;
			}
		}
		
		var aclInfo = coviACL_getACLData('con_AccessAuthDiv');
		var aclIsChange = aclInfo.aclIsChange;
		var aclData = aclInfo.aclData;
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
				"isInherited" : $("#con_AccessAuthDiv_isInherited").is(":checked") ? "Y" : "N", // 권한 상속 여부
				"menuAlias" : $("#txtMenuAlias").val()
			};
			
			$.ajax({
				type : "POST",
				data : pData,
				url : "/covicore/manage/menu/add.do",
				success : function(data) {
					if(data.result == 'ok'){
						parent.Common.Inform("<spring:message code='Cache.msg_37'/>", "Information", function(result){ // 저장되었습니다.
							if (result) {
								parent.$("#folderRefresh").trigger("click");
								parent.Common.close(popupTagetID);
								
								window.parent.postMessage({
									  "functionName": "selectAddOrModifyMenu"
									, "params": data.list[0].MenuPath
								}, '*');
							}
						});
					} else if (data.result == 'MENU_ALIAS_DUPLICATION'){
						parent.Common.Error(data.message);
					} else{
						parent.Common.Error("<spring:message code='Cache.ACC_msg_error'/>");	//오류가 발생하였습니다. 관리자에게 문의 바랍니다.
					}
				},
				error : function(response, status, error){
					CFN_ErrorAjax("/covicore/manage/menu/add.do", response, status, error);
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
				"aclIsChange" : aclIsChange, // 권한 변경 여부
				"aclInfo" :  encodeURIComponent(aclData), // AclInfo
				"aclActionInfo" :  encodeURIComponent(aclActionData), // AclActionInfo
				"memberOf" : $("#hidMemberOf").val(), // 상위 메뉴
				"reserved1" :  $("#txtReserved1").val(), // 예비1
				"reserved2" : $("#txtReserved2").val(),  //예비2
				"reserved5" : $("#txtReserved5").val(), //최종 url
				"siteMapPosition" : $("#cboSiteMapPosition option:selected").val(), //사이트맵 위치				
				"isInherited" : $("#con_AccessAuthDiv_isInherited").is(":checked") ? "Y" : "N", // 권한 상속 여부
				"isUpdateChildren" : $("#checkIsSubfolderInherited").is(":checked") ? "Y" : "N",	// 하위폴더 일괄 업데이트
				"menuAlias" : $("#txtMenuAlias").val()
			};
			
 			$.ajax({
				type : "POST",
				data : pData,
				url : "/covicore/manage/menu/modify.do",
				success : function(data) {
					if(data.result == 'ok'){						
						parent.Common.Inform("<spring:message code='Cache.msg_37'/>", "Information", function(result){ // 저장되었습니다.
							if (result) {
								parent.$("#folderRefresh").trigger("click");
								parent.Common.close(popupTagetID);
								
								window.parent.postMessage({
									  "functionName": "selectAddOrModifyMenu"
									, "params": data.list[0].MenuPath
								}, '*');
							}
						});
					} else if (data.result == 'MENU_ALIAS_DUPLICATION'){
						parent.Common.Error(data.message);
					} else {
						parent.Common.Error("<spring:message code='Cache.ACC_msg_error'/>");	//오류가 발생하였습니다. 관리자에게 문의 바랍니다.
					}
				},
				error : function(response, status, error){
					CFN_ErrorAjax("/covicore/manage/menu/modify.do", response, status, error);
				}
			});
		}	    
	}
	
	function clickTab(pObj) {
		$(".tabMenu li").toggleClass("active");

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
		
		coviCtrl.renderAXSelect(
			"MenuType,SecurityLevel,ServiceDevice,BizSection",
			"cboMenuType,cboSecurity,cboDevice,cboBizSection",
			"ko",
			null,
			"selectRenderComplete"
		);
	}
	
	// covision.dic.js에서 호출되는 함수 (다국어 입력값 표시용) 
	function initDicPopup(){
		return $('#hidMenuName').val();
	}
	
	function setPopup(target){
		parent.Common.toResize('addMenuPopup', parent.$("#addMenuPopup_p").width() - 6, $("#sadmin_p").outerHeight())
	}
</script>