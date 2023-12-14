<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib uri="/WEB-INF/tlds/covi.tld" prefix="covi" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<style>
.schPopLayer .middle {
	border-bottom: 0px;
}

#con_acl .authPermissions table tr td:nth-child(9) {
	border-right: 1px dashed #ddd;
}
</style>
<body>	
	<div class="layer_divpop ui-draggable schPopLayer" id="testpopup_p" style="width:100%;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
				<div id="popMain" style="visibility: hidden;">
					<div class="top">
						<ul class="tabMenu clearFloat">
							<li class="active" onclick="clickTap(this); setPopup(this);" data-type="schedule"><a><spring:message code='Cache.lbl_schedule_theme' /></a></li><!-- 테마일정 -->
							<li onclick="clickTap(this); setPopup(this);" data-type="auth"><a><spring:message code='Cache.lbl_Authority' /></a></li><!-- 권한 -->
						</ul>
					</div>
					<div class="middle">
						<div class="tabContent active themeSch">
							<div id="colorPicker" style="float:left"></div>
							<!-- <input type="text" id="colorPicker" name="colorPicker" data-palette='' style="display: none;"> -->
							<input type="text" id="themeName" class="HtmlCheckXSS ScriptCheckXSS" onchange="changeDisplayName();" style="width: 580px;" placeholder="<spring:message code='Cache.msg_mustWriteThemeName' />" /><!-- 테마 일정명을 입력해주세요. -->
							<input type="hidden" id="MultiDisplayName"/>
						</div>
						<div id="aclTab" class="tabContent">
							<div id="con_acl"></div>
						</div>
					</div>
					<div class="bottom">
						<a id="btnSave" onclick="setTheme();" class="btnTypeDefault btnTypeChk"><spring:message code='Cache.btn_register' /></a><!-- 등록 -->
						<a id="btnLang" onclick="setMultiLangData();" class="btnTypeDefault"><spring:message code='Cache.btn_MultiLanguage' /></a><!-- 다국어 지정 -->
						<a onclick="closeThemePop();" class="btnTypeDefault"><spring:message code='Cache.btn_Close' /></a><!-- 닫기 -->
					</div>
				</div>
			</div>
		</div>	
	</div>
</body>
<script>
	//개별호출-일괄호출
	var sessionObj = Common.getSession(); //전체호출
	
	var folderID = CFN_GetQueryString("folderID") == "undefined" ? "" : CFN_GetQueryString("folderID");
	var lang = sessionObj["lang"];
	var mode = "I";
	var g_aclList;
	var g_isRoot = false;
	var g_isInherited = false;
	var scheduleThemeFolderID = Common.getBaseConfig("ScheduleThemeFolderID") == "" ? "0" : Common.getBaseConfig("ScheduleThemeFolderID");
	
	initContent();
	
	function initContent(){
		// colorPicker 세팅
		var colorList = Common.getBaseCode("ScheduleColor");
		var dataPalette = new Array();
		var defaultColor = Common.getBaseConfig("FolderDefaultColor");
		
		dataPalette.push({"default" : defaultColor});
		$(colorList.CacheData).each(function(){
			var obj = {};
			$$(obj).append(this.Code, "#"+this.Code);
			
			dataPalette.push(obj);
		});
		
		coviCtrl.renderColorPicker("colorPicker", dataPalette);
		renderACL(); // 권한 화면 세팅
		
		if(folderID != ""){
			getThemeOne();
			mode = "U";
			$("#btnSave").text("<spring:message code='Cache.btn_Confirm'/>");		//확인
		}else{
			$("#popMain").css("visibility", "unset");
			
			var addedACL = [{
        		SubjectCode : sessionObj["UR_Code"],
        		SubjectName : CFN_GetDicInfo(sessionObj["UR_MultiName"], g_aclVariables.lang),
        		SubjectType : "UR",
        		AclList : "SCDMEVR",
        		InheritedObjectID : 0,
        		IsSubInclude : "Y"
         	}];
			
			coviACL.set(addedACL);
		}
	}
	
	function closeThemePop(){
		Common.Close();
	}
	
	// 기존 테마일정 데이터 조회
	function getThemeOne(){
		$.ajax({
			url: "/groupware/schedule/getThemeOne.do",
			type: "POST",
			data: {
				"FolderID" : folderID
			},
			success: function(res){
				if(res.status == "SUCCESS"){
					// 권한 정보 데이터 세팅
					if($(res.aclData).length > 0){
						coviACL.set(res.aclData);
					}
					
					// 폴더 정보 데이터 세팅
					if($(res.data).length > 0){
						if (res.data.OwnerCode === sessionObj["UR_Code"]) {
							coviCtrl.setSelectColor(res.data.Color.replace("#", ""));
							$("#themeName").val(res.data.DisplayName);
							$("#MultiDisplayName").val(res.data.MultiDisplayName);
						} else {
							$(".top").html($("<div/>", {"text": "<spring:message code='Cache.lbl_ShareTarget'/>", "style": "font-size: 20px; font-weight: 700; margin-bottom: 15px;"})); // 공유 대상자
							
							$("#con_acl_btnCallOrgMap").parent("div").hide();
							$("#con_acl_hTblAcl").hide();
							$("#con_acl_hTbdPermissions input[type=button]").hide()
							
							$(".tabContent").removeClass("active");
							$("#aclTab").addClass("active");
							$("#btnSave").hide();
							$("#btnLang").hide();
						}
						
						$("#popMain").css("visibility", "unset");
					}
				} else {
					Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/schedule/getThemeOne.do", response, status, error);
			}
		});
	}
	
	//권한 설정 탭 내부 UI 표시
	function renderACL(){
		var option = {
			lang : lang,
			allowedACL : '_CDMEVR',
			initialACL : '_CDMEVR',
			hasButton : false,
			orgMapCallback : 'orgCallback',
			aclCallback : 'aclCallback',
			systemType : "Schedule",
			objectID : folderID,
			objectType : "FD"
		};
		
		if (!g_isRoot) {
			option["useInherited"] = true;
			option["inheritedFunc"] = "selectInheritedACL";
		}
		
		coviACL = new CoviACL(option);
		coviACL.render('con_acl');
	}
	
	//상위 권한 상속
	var selectInheritedACL = function(){	
		$.ajax({
			url: "/groupware/manage/schedule/selectBoardACLData.do",
			type: "POST",
			async: false,
			data: {
				  "objectID": scheduleThemeFolderID
				, "objectType": "FD"
				, "ScheduleType" : "Theme"
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
					
					var jsonData = {"item": aclList, "isInHerited": true, "inheritedObjectID": scheduleThemeFolderID};
					
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
		aclList = data;
	}
	
	//다국어 설정 팝업
	function setMultiLangData(){
		var option = {
				lang : lang,
				hasTransBtn : 'true',
				allowedLang : 'ko,en,ja,zh',
				useShort : 'false',
				dicCallback : 'dicCallback',
				openerID : CFN_GetQueryString("CFN_OpenLayerName"),
				popupTargetID : 'setMultiLangData',
				init : 'dicInit'
		};
		
		var url = "";
		url += "/covicore/control/calldic.do?lang=" + option.lang;
		url += "&hasTransBtn=" + option.hasTransBtn;
		url += "&useShort=" + option.useShort;
		url += "&dicCallback=" + option.dicCallback;
		url += "&allowedLang=" + option.allowedLang;
		url += "&openerID=" + option.openerID;
		url += "&popupTargetID=" + option.popupTargetID;
		url += "&init=" + option.init;
		
		parent.Common.open("","setMultiLangData","<spring:message code='Cache.lbl_MultiLangSet' />",url,"450px","200px","iframe",true,null,null,true);		//다국어 설정
	}
	
	//다국어 세팅 함수
	function dicInit(){
		var value;
		
		if(document.getElementById("MultiDisplayName").value == ''){
			value = document.getElementById('themeName').value;
		}else{
			value = document.getElementById("MultiDisplayName").value;
		}
		
		return value;
	}
	
	//다국어 콜백 함수
	function dicCallback(data){
		var dicObj = JSON.parse(data);
		
		$("#MultiDisplayName").val(coviDic.convertDic(dicObj));
		document.getElementById('themeName').value = CFN_GetDicInfo(coviDic.convertDic(dicObj),lang);
		
		Common.Close("setMultiLangData");
	}
	
	//표시이름 변경시 다국어값 초기화
	function changeDisplayName(){
		$("#MultiDisplayName").val($("#themeName").val());
	}
	
	// 테마일정 저장
	function setTheme(){
		if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
		
		if($("#MultiDisplayName").val() == ""){
			$("#MultiDisplayName").val($("#themeName").val());
		}

		var userCode = sessionObj["USERID"];
		var folderData = {
				"DisplayName" : $("#themeName").val(),
				"MultiDisplayName" : $("#MultiDisplayName").val(),
				"DefaultColor" : coviCtrl.getSelectColorVal(),
				"ManageCompany" : sessionObj["DN_ID"],
				"OwnerCode" : userCode,
				"IsInherited" : $("#con_acl_isInherited").is(":checked") ? "Y" : "N",
				"RegisterCode" : userCode,
				"ModifierCode" : userCode
		};
		
		if(folderData.DisplayName == "" || folderData.DisplayName == undefined){
			Common.Warning("<spring:message code='Cache.msg_mustWriteThemeName'/>");		//테마 일정명을 입력해주세요.
			return false;
		}
		if(folderData.DefaultColor == "#" || folderData.DefaultColor == "" || folderData.DefaultColor == undefined){
			Common.Warning("<spring:message code='Cache.msg_mustSetThemeColor'/>");		//테마 일정 색깔을 지정해주세요.
			return false;
		}
		
		if(mode == "U") folderData.FolderID = folderID;
		
		var aclInfo = coviACL_getACLData('con_acl');
		var aclIsChange = aclInfo.aclIsChange;
		var aclData = aclInfo.aclData;
		aclData = aclData == undefined ? "[]" : aclData;
		var aclActionData = coviACL_getACLActionData('con_acl');
		aclActionData = aclActionData == undefined ? "[]" : aclActionData;
				
		$.ajax({
		    url: "setTheme.do",
		    type: "POST",
		    data: {
		    	"mode" : mode,
		    	"folderData" : JSON.stringify(folderData),
		    	"aclIsChange" : aclIsChange,
		    	"aclData" : aclData,
		    	"aclActionData" : aclActionData
			},
		    success: function (res) {
				if(res.status == "SUCCESS"){
			    	Common.Inform("<spring:message code='Cache.msg_117'/>", "", function(){		//성공적으로 저장하였습니다.
			    		parent.schAclArray = {};
			    		parent._CallBackMethod2();
			    		Common.Close();
			    		parent.setLeftMenu();
			    	});
		    	} else {
					Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("setTheme.do", response, status, error);
			}
		});
	}
	
	function setPopup(target){
		$("#btnLang").css("display", ($(target).attr("data-type") == 'auth') ? "none" : "inline-block");
		parent.Common.toResize('themeOne_Popup', parent.$("#themeOne_Popup_p").width() - 6, $("#testpopup_p").height())
	}
</script>