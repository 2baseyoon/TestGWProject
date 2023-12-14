<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil,egovframework.coviframework.util.RedisDataUtil"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<form id="formData" method="post" enctype="multipart/form-data">
<input type="hidden" id="oldCommunity" value= ""/>
<input type="hidden" id="savedCommunity" value= ""/>
<input type="hidden" id="oldCommunityCount" value= "0"/>
<input type="hidden" id ="hiddenCategory" value = ""/>
<input type="hidden" id ="DIC_Code_ko" value = ""/>
<input type="hidden" id ="DIC_Code_en" value = ""/>
<input type="hidden" id ="DIC_Code_ja" value = ""/>
<input type="hidden" id ="DIC_Code_zh" value = ""/>
<input type="hidden" id ="editChagneANum" value = "N"/>
<input type="hidden" id ="editChagneBNum" value = "N"/>
<input type="hidden" id="uDnID" value =""/>
<input type="hidden" id="operatorCode" value =""/>

	<div class="cRConTop">
		<h2 class="title"><spring:message code='Cache.lbl_communityInFoM'/></h2>						
	</div>
	<div class="commIndividualInfoAdmin">
		<div class="commInputBoxDefault">								
			<div class="inputBoxSytel01 type02 commName">
				<div>
					<span class="star"><spring:message code='Cache.lbl_communityName'/></span>
				</div>
				<div>
					<input type="text" class="txtInp HtmlCheckXSS ScriptCheckXSS" id="cName">
				</div>
				<div>
					<a onclick="CheckCommunityName();" class="btnTypeDefault btnThemeLine ml5"><spring:message code='Cache.lbl_DuplicateCheck'/></a>
					<%-- <a onclick="btnDictionaryInfoOnClick();" class="btnTypeDefault ml5"><spring:message code='Cache.lbl_MultilanguageSettings'/></a> --%>
				</div>
			</div>
			<div class="inputBoxSytel01 type02">
				<div>
					<span><spring:message code='Cache.lbl_Category_Folder'/></span>
				</div>
				<div>
					<p class="textBox"><spring:message code='Cache.lbl_MyHobby'/> > <span class="colorTheme"><spring:message code='Cache.CommunityDefaultBoardType_B'/></span></p>
				</div>
			</div>
			<div class="inputBoxSytel01 type02">
				<div>
					<span><spring:message code='Cache.lbl_Establishment_Day'/></span>
				</div>
				<div>
					<p class="textBox" id="crDate"></p>
				</div>
				<div class="inputBoxSytel01 subDepth type02">
					<div>
						<span><spring:message code='Cache.lbl_Establishment_Man'/></span>
					</div>
					<div>
						<p class="textBox" id="copName"></p>
					</div>
				</div>
			</div>
			<div class="inputBoxSytel01 type02">
				<div>
					<span><spring:message code='Cache.lbl_type'/></span>
				</div>
				<div>
					<p class="textBox" id="cType"></p>
				</div>
				<div class="inputBoxSytel01 subDepth type02">
					<div>
						<span><spring:message code='Cache.lbl_Operator'/></span>
					</div>
					<div>
						<input type="text" class="adminModifyInput" id="txtOperator" readonly="readonly">
						<a onclick='goManagerChange()' class='btnSysopChange ml5'><span><spring:message code='Cache.lbl_ChgOperator'/></span></a>
					</div>
				</div>
			</div>
			<div class="inputBoxSytel01 type02">
				<div>
					<span><spring:message code='Cache.lbl_User_Count'/></span>
				</div>
				<div>
					<p class="textBox">
						<span class="colorTheme" id="cMemberCnt"></span>
					</p>
				</div>
				<div class="inputBoxSytel01 subDepth type02">
					<div>
						<span><spring:message code='Cache.lbl_All_Count'/></span>
					</div>
					<div>
						<p class="textBox">
							<span class="colorTheme" id="cMsgCnt"></span>
						</p>
					</div>
				</div>
			</div>
			<div class="inputBoxSytel01 type02">
				<div>
					<span><spring:message code='Cache.lbl_AllocatedCapacity'/></span>
				</div>
				<div>
					<p class="textBox" id="cfdSize"></p>
				</div>
				<div class="inputBoxSytel01 subDepth type02">
					<div>
						<span><spring:message code='Cache.lbl_UseFileSize'/></span>
					</div>
					<div>
						<p class="textBox" id="cfuSize"></p>
					</div>
				</div>
			</div>
			
			<!-- 가입방식 변경 여부 -->
			<%if(RedisDataUtil.getBaseConfig("EnableChangeJoinOption").equals("Y")){ %>
			<div class="inputBoxSytel01 type02">
				<div>
					<span><spring:message code='Cache.lbl_JoiningMethod'/></span>
				</div>
				<div>
					<p>
						<span class="radioStyle04"><input type="radio" id="JoinOption_A" name="JoinOption"><label for="JoinOption_A"><span class="mr5"><span></span></span><spring:message code='Cache.msg_CommunityImmediatelyJoin'/></label></span>									
					</p>									
					<p class=" mt15">
						<span class="radioStyle04"><input type="radio" id="JoinOption_M" name="JoinOption"><label for="JoinOption_M"><span class="mr5"><span></span></span><spring:message code='Cache.msg_CommunityApprovalJoin'/></label></span>										
					</p>
				</div>
			</div>
			<%} %>
						
			<div class="inputBoxSytel01 type02">
				<div>
					<span><spring:message code='Cache.lbl_SingleLineIntroduction'/></span>
				</div>
				<div>
					<input type="text" class="txtInp HtmlCheckXSS ScriptCheckXSS" id="cOneTitle">
				</div>
			</div>							
			<div class="inputBoxEdit">
				<div class="inputBoxSytel01 type02">
					<div>
						<span><spring:message code='Cache.lbl_CommunityStipulation'/></span>
					</div>
					<input type="hidden" id="oldtxtStipulation"/>
					<div class="txtEdit"  id="editChangeA">
						<textarea id="txtStipulation"></textarea>
						<p class="editChange"><a href="#" onclick="editChange('A')"><spring:message code='Cache.lbl_editChange'/></a></p>
					</div>
				</div>
				<div class="inputBoxSytel01 type02">
					<div>
						<span><spring:message code='Cache.lbl_Community_Guide'/></span>
					</div>
					<input type="hidden" id="oldtxtIntroduction"/>
					<div class="txtEdit"  id="editChangeB">
						<textarea id="txtIntroduction"></textarea>
						<p class="editChange"><a href="#" onclick="editChange('B')"><spring:message code='Cache.lbl_editChange'/></a></p>
					</div>
				</div>
			</div>
		</div>						
		<div class="btm">
			<a onclick="goUpdate();" class="btnTypeDefault btnTypeBg"><spring:message code='Cache.btn_Edit'/></a><a onclick="goReset();" class="btnTypeDefault ml5"><spring:message code='Cache.btn_Cancel'/></a>
		</div>					
	</div>	
</form>
<script type="text/javascript">
$(function(){					
	$("#cName").validation("limitChar",50);
	$("#cOneTitle").validation("limitChar",100);
	
	setCommunityInfo("N");
});

var g_editorKind = Common.getBaseConfig('EditorType');

function setCommunityInfo(v){
	var str = "";
	$.ajax({
		url:"/groupware/layout/userCommunity/selectCommunityInfo.do",
		type:"POST",
		async:false,
		data:{
			CU_ID : cID
		},
		success:function (e) {
			if(e.list.length > 0){
				$(e.list).each(function(i,v){
					
					$("#cName").val(v.CommunityName);
					$("#crDate").html(CFN_TransLocalTime(v.RegProcessDate,_ServerDateSimpleFormat));
					$("#cType").html( v.CommunityType);
					$("#cMemberCnt").html( v.MemberCount);
					$("#cMsgCnt").html(v.MsgCount);
					$("#cfdSize").html( v.LimitFileSize);
					$("#cfuSize").html( v.FileSize);
					$("#cOneTitle").val( v.SearchTitle); 
					$("#uDnID").val(v.DN_ID);
					
					$("#oldCommunity").val(v.CommunityName);
					$("#savedCommunity").val(v.CommunityName);
					$("#oldCommunityCount").val("1");
					
    				$("#DIC_Code_ko").val(v.KoFullWord);
    				$("#DIC_Code_en").val(v.EnFullWord);
    				$("#DIC_Code_ja").val(v.JaFullWord); 
    				$("#DIC_Code_zh").val(v.ZhFullWord); 
    				
    				$("#operatorCode").val(v.OperatorCode);
    				
    				$("#hiddenCategory").val(v.KoFullWord+";"+v.EnFullWord+";"+v.JaFullWord+";"+v.ZhFullWord+";;;;;;;"); 
    				 
					if(v.opDeptName != "" && v.opDeptName != null && v.opJobPositionName != "" && v.opJobPositionName != null){
						if(v.crName != null && v.crName != ''){
							$("#copName").html(v.crName+"("+v.crDeptName+"/"+v.crJobPositionName+")");
						}
					}else{
						$("#copName").html(v.crName);
					}
					
					if(v.crDeptName != "" && v.crDeptName != null && v.crJobPositionName != "" && v.crJobPositionName != null){
						$("#txtOperator").val(v.opName+"("+v.opDeptName+"/"+v.opJobPositionName+")");
						//$("#ccrName").html("<a onclick='goManagerChange()' class='btnSysopChange ml15'><span>운영자 변경</span></a>");
					}else{
						$("#txtOperator").val(v.opName);
						//$("#ccrName").html("<a onclick='goManagerChange()' class='btnSysopChange ml15'><span>운영자 변경</span></a>");
					}
					
					if( v.ProvisionOption == "Y" ){
						$("#txtStipulation").val(v.ProvisionEditor);
						
						if( $("#editChagneANum").val() == "N"){
							setTime1 = setTimeout(function() {
								editChange('A');
								clearTimeout(setTime1);
							 }, 700);
						}else{
							coviEditor.setBody(g_editorKind, 'editA', v.ProvisionEditor);
						}
					}else{
						$("#txtStipulation").val(v.Provision);
					}
					
					if( v.DescriptionOption == "Y"){
						$("#txtIntroduction").val(v.DescriptionEditor);
						
						if( $("#editChagneBNum").val() == "N"){
							setTime = setTimeout(function() {
								editChange('B');
								clearTimeout(setTime);
							 }, 1050);
						}else{
							coviEditor.setBody(g_editorKind, 'editB', v.DescriptionEditor);
						}
						
					}else{
						$("#txtIntroduction").val(v.Description)
					}
					
					setCurrentLocation(v.CategoryID);
					
					if($('input:radio[name="JoinOption"]').length > 0) {
						if(v.JoinOption == "A") {
							$('input:radio[id="JoinOption_A"]').prop("checked", true);
						} else {
							$('input:radio[id="JoinOption_M"]').prop("checked", true);
						}	
					}
				});
			}
			
			if(v == "Y"){
				Common.Inform("변경 이전 상태로 복구 하였습니다.", "Inform", function() {
				});
				
			}
			
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/userCommunity/selectCommunityInfo.do", response, status, error); 
		}
	}); 
}

function setCurrentLocation(categoryID){
	var locationText= "";
	$.ajax({
		type:"POST",
		data:{
			"CategoryID" : categoryID
		},
		async : false,
		url:"/groupware/layout/userCommunity/setCurrentLocation.do",
		success:function (data) {
			
			if(data.list.length > 0){
				$(data.list).each(function(i,v){
					
					if(v.num == '1'){
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
			$("#cCategoryNm").html(locationText);
			
		},
		error:function (error){
			  CFN_ErrorAjax("/groupware/layout/userCommunity/setCurrentLocation.do", response, status, error);
		}
	});
}

function CheckCommunityName(){
	
	if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
	
	var communityName = $("#cName").val();
	
	if(communityName == null || communityName == ""){
		Common.Warning("<spring:message code='Cache.msg_blankValue'/>", "warning", function(answer){ // 빈값을 입력할 수 없습니다.
			if(answer){
				$("#cName").focus();
			}
		});
	}else if($("#cName").val() == $("#oldCommunity").val() || $("#savedCommunity").val() == $("#cName").val()){
		Common.Inform("<spring:message code='Cache.msg_canusedCuName'/>"); //사용 가능한 커뮤니티 이름입니다.
		$("#oldCommunity").val(communityName);
		$("#oldCommunityCount").val("1");
	}else{
		$.ajax({
			type:"POST",
			data:{
				DisplayName : communityName
			},
			async : false,
			url:"/groupware/layout/checkCommunityName.do",
			success:function (data) {
				if(data.status == "SUCCESS"){
					Common.Inform("<spring:message code='Cache.msg_canusedCuName'/>"); //사용 가능한 커뮤니티 이름입니다.
					$("#oldCommunity").val(communityName);
					$("#oldCommunityCount").val("1");
				}else{ 
					Common.Warning("<spring:message code='Cache.msg_duplyCommunityName'/>"); //커뮤니티 이름이 중복되어 사용할 수 없습니다.
					$("#oldCommunity").val("");
					$("#oldCommunityCount").val("0");
				}			
			},
			error:function(response, status, error){
			     //TODO 추가 오류 처리
			     CFN_ErrorAjax("/groupware/layout/checkCommunityName.do", response, status, error);
			}
		});
	}
	
}

function btnDictionaryInfoOnClick(){
	var option = {
			lang : 'ko',
			hasTransBtn : 'true',
			allowedLang : 'ko,en,ja,zh',
			useShort : 'false',
			dicCallback : 'addSubDicCallback',
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
	
	parent.Common.open("", "DictionaryPopup", "<spring:message code='Cache.lbl_MultiLangSet'/>", url, "500px", "200px", "iframe", true, null, null, true);
}

function addSubDicCallback(data){
	
	document.getElementById("DIC_Code_ko").value = data.KoFull;
	document.getElementById("DIC_Code_en").value = data.EnFull;
	document.getElementById("DIC_Code_ja").value = data.JaFull;
	document.getElementById("DIC_Code_zh").value = data.ZhFull;
	document.getElementById("hiddenCategory").value = coviDic.convertDic(data);
	
	$("#cName").val(data.KoFull);
	
	Common.Close('DictionaryPopup');
}

function initDicPopup(){
	
	if($("#hiddenCategory").val() ==  null || $("#hiddenCategory").val() ==  '' || $("#hiddenCategory").val() == ';;;;;;;;;;'){
		$("#hiddenCategory").val($("#cName").val());
	}
		
	return $("#hiddenCategory").val(); 
}

function editChange(type){
	if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

	if(type == "A"){
		$("#oldtxtStipulation").val($("#txtStipulation").val());
		if( $("#editChagneANum").val() == "N"){
			 $("#editChagneANum").val("Y");	
			 coviEditor.loadEditor(
						'editChangeA',
						{
							editorType : g_editorKind,
							containerID : 'editA',
							frameHeight : '311',
							focusObjID : ''
						}
			);
			 timeout1 = setTimeout(function() {
				 coviEditor.setBody(g_editorKind, 'editA', $("#oldtxtStipulation").val());
				 clearTimeout(timeout1);
			 }, 500);
			 
		}else{
			coviEditor.setBody(g_editorKind, 'editA', $("#oldtxtStipulation").val());
		}
		
		 
	}else{
		$("#oldtxtIntroduction").val($("#txtIntroduction").val());
		if( $("#editChagneBNum").val() == "N"){
			 $("#editChagneBNum").val("Y");	
			 coviEditor.loadEditor(
						'editChangeB',
						{
							editorType : g_editorKind,
							containerID : 'editB',
							frameHeight : '311',
							focusObjID : ''
						}
			);
		 
			 timeout2 = setTimeout(function() {
				 coviEditor.setBody(g_editorKind, 'editB', $("#oldtxtIntroduction").val());
				 clearTimeout(timeout2);
			 }, 850);
		}else{
			 coviEditor.setBody(g_editorKind, 'editB', $("#oldtxtIntroduction").val());
		}
		
	}
}

var aStrDictionary = Common.getDicAll(["lbl_ACL_Allow","lbl_ACL_Denial","lbl_User","lbl_company","lbl_group"]);
var lang = Common.getSession("lang");

function goManagerChange(){
	var url = "";
	url += "/groupware/layout/userCommunity/ManagerChange.do?callBackFunc=managerChange_CallBack&CU_ID="+cID;
	Common.open("", "manager_pop", "<spring:message code='Cache.lbl_ChgOperator'/>", url, "550px", "500px", "iframe", true, null, null, true);	
}

function managerChange_CallBack(UR_Code, opName, opDeptName, opJobPositionName){
	if(opDeptName != "" && opDeptName != null && opJobPositionName != "" && opJobPositionName != null){
		$("#txtOperator").val(opName + "("+opDeptName+"/"+opJobPositionName+")");
	}else{
		$("#txtOperator").val(opName);
	}
	
	$("#operatorCode").val(UR_Code);
}

function goReset(){
	Common.Confirm(Common.getDic("msg_restoreCommunityInfo"), "Confirmation Dialog", function (confirmResult) {
		if (confirmResult) {
			setCommunityInfo("Y");
		}
	});
}

function goUpdate(){
	if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
	
	if($("#cName").val().replace(/(\s*)/g, "") == ""){
		Common.Warning("<spring:message code='Cache.msg_inputCommunityName'/>"); //커뮤니티 이름을 입력하세요.
		return ;
	}
	
	if($("#oldCommunityCount").val() == "0"){
		Common.Warning("<spring:message code='Cache.msg_DuplicateCheckCuName'/>"); //커뮤니티 이름 중복체크를 하십시오.
		return ;
	}
	
	if($("#oldCommunity").val() != $("#cName").val()){
		Common.Warning("<spring:message code='Cache.msg_DuplicateCheckCuName'/>"); //커뮤니티 이름 중복체크를 하십시오.
		return ;
	}
	
	if($("#txtOperator").val() == ""){
		Common.Warning("<spring:message code='Cache.msg_RegiAdmin'/>");
		return;
	}
	
	if($("#operatorCode").val() == ""){
		Common.Warning("<spring:message code='Cache.msg_RegiAdmin'/>");
		return;
	}
	
	var txtStipulation = "";
	var txtStipulationEditer = "";
	var txtStipulationInlineImage = "";
	
	if($("#editChagneANum").val() == "N"){
		txtStipulation = $("#txtStipulation").val();
		txtStipulationEditer = $("#txtStipulation").val();
		txtStipulationInlineImage = "";
	}else{
		txtStipulationEditer = coviEditor.getBody(g_editorKind, 'editA');
		txtStipulation = coviEditor.getBodyText(g_editorKind, 'editA');
		txtStipulationInlineImage = coviEditor.getImages(g_editorKind, 'editA');
	}
	
	var txtIntroduction = "";
	var txtIntroductionEditer = "";
	var txtIntroductionInlineImage = "";
	
	if($("#editChagneBNum").val() == "N"){
		txtIntroduction = $("#txtIntroduction").val();
		txtIntroductionEditer = $("#txtIntroduction").val();
		txtIntroductionInlineImage =  "";
	}else{
		txtIntroductionEditer = coviEditor.getBody(g_editorKind, 'editB');
		txtIntroduction = coviEditor.getBodyText(g_editorKind, 'editB');
		txtIntroductionInlineImage =  coviEditor.getImages(g_editorKind, 'editB');
	}
	
	var JoinOption = "";	
	if($('input:radio[name="JoinOption"]').length > 0) {
		if($('input:radio[id="JoinOption_A"]').is(':checked')) {
			JoinOption = "A";
		} else if($('input:radio[id="JoinOption_M"]').is(':checked')) {
			JoinOption = "M";
		}	
	}
	
	Common.Confirm("<spring:message code='Cache.msg_EditCommunityConfirm'/>", "Confirmation Dialog", function (confirmResult) {
		if (confirmResult) {
			$.ajax({
				url:"/groupware/layout/userCommunity/CommunityUpdateInfo.do",
				type:"post",
				data:{
					DIC_Code_ko : parent.document.getElementById("DIC_Code_ko").value,
					DIC_Code_en : parent.document.getElementById("DIC_Code_en").value,
					DIC_Code_ja : parent.document.getElementById("DIC_Code_ja").value,
					DIC_Code_zh : parent.document.getElementById("DIC_Code_zh").value,
					DIC_Code : $("#hiddenCategory").val(),
					txtCommunityName : $("#cName").val(),
					operatorCode : $("#operatorCode").val(),
					textLineIntroduction : $("#cOneTitle").val(),
					txtStipulation : txtStipulation,
					txtStipulationEditer : txtStipulationEditer,
					txtStipulationInlineImage : txtStipulationInlineImage,
					txtIntroduction : txtIntroduction,
					txtIntroductionEditer : txtIntroductionEditer,
					txtIntroductionInlineImage : txtIntroductionInlineImage,
					DescriptionOption : $("#editChagneBNum").val(),
					ProvisionOption :	$("#editChagneANum").val(),
					CU_ID : cID,
					JoinOption : JoinOption
				},
				success:function (data) {
					if(data.status == "SUCCESS"){
						Common.Inform("<spring:message code='Cache.msg_Edited'/>"); //수정되었습니다
						setCommunityInfo("N");
						opener.localCache.removeAll();
						opener.scheduleUser.setAclEventFolderData();
					}else{ 
						Common.Error("<spring:message code='Cache.msg_changeFail'/>"); //변경에 실패하였습니다.
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/groupware/layout/userCommunity/CommunityUpdateInfo.do", response, status, error); 
				}
			}); 
		}
	});
}
</script>