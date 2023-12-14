<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<form id="formData" method="post" enctype="multipart/form-data">
<input type="hidden" id="_ParentID" value= ""/>
<input type="hidden" id="uDnID" value= ""/>
<input type="hidden" id="oldCommunity" value= ""/>
<input type="hidden" id="oldCommunityCount" value= "0"/>
<input type="hidden" id ="hiddenCategory" value = ""/>
<input type="hidden" id ="DIC_Code_ko" value = ""/>
<input type="hidden" id ="DIC_Code_en" value = ""/>
<input type="hidden" id ="DIC_Code_ja" value = ""/>
<input type="hidden" id ="DIC_Code_zh" value = ""/>
<input type="hidden" id ="keyNum" value = "0"/>
<input type="hidden" id ="editChagneANum" value = "N"/>
<input type="hidden" id ="editChagneBNum" value = "N"/>

<div class="cRConTop ">
	<div class="cRTopButtons">
		<a href="#" class="btnTypeDefault btnTypeChk" onclick="goAdd();"><spring:message code='Cache.btn_register'/></a><a href="#" class="btnTypeDefault" onclick="movePage();"><spring:message code='Cache.btn_Cancel'/></a>
	</div>
	<!-- <div class="surveySetting">							
		<a href="#" class="surveryWinPop">팝업</a>
	</div> -->
</div>
<div class="cRContBottom mScrollVH ">
	<div class="communityContent commMiddle">
		<div class="commInputBoxDefault">
			<div class="inputBoxSytel01 type02">
				<div><span><spring:message code='Cache.lbl_CommunityID'/></span><a id="moveTarget" style="display: none;"></a></div>
				<div>
					<input type="text" id="cId" value="" readonly="" class="inpReadOnly"> <span class="blueStart ml15"><spring:message code='Cache.lbl_CommunityIdHelp'/></span>
				</div>
			</div>
			<div class="inputBoxSytel01 type02 commName">
				<div><span class="star"><spring:message code='Cache.lbl_communityName'/></span></div>
				<div>
					<input type="text" class="txtInp HtmlCheckXSS ScriptCheckXSS" id="txtCommunityName">
				</div>
				<div>
					<a href="#" onclick="CheckCommunityName();" class="btnTypeDefault btnThemeLine ml5"><spring:message code='Cache.lbl_apv_DuplicateCheck'/></a>
					<%--<a href="#" onclick="btnDictionaryInfoOnClick()" class="btnTypeDefault ml5"><spring:message code='Cache.lbl_MultiLangSet'/></a> --%>
				</div>
			</div>
<!-- 			<div class="inputBoxSytel01 type02">
				<div><span class="star">커뮤니티 영역</span></div>
				<div>
					<span class="radioStyle04"><input type="radio" id="rrr01" name="rrrr"><label for="rrr01"><span class="mr5"><span></span></span>그룹</label></span>
					<span class="radioStyle04 ml15"><input type="radio" id="rrr02" name="rrrr"><label for="rrr02"><span class="mr5"><span></span></span>회사</label></span>
				</div>
			</div> -->
			<div class="inputBoxSytel01 type02">
				<div><span class="star"><spring:message code='Cache.lbl_Category_Folder'/></span></div>
				<div>
					<input type="text" class="midInput" disabled="disabled" id="txtCategoryName">
					<a href="#" class="btnTypeDefault" onclick="btnCategoryParenOnClick();"><spring:message code='Cache.lbl_Browse'/></a>
				</div>
			</div>
			<div class="inputBoxSytel01 type02 makeMoreParent">
				<div><span><spring:message code='Cache.lbl_keyword'/></span></div>
				<div>
					<input type="text" class="midInput HtmlCheckXSS ScriptCheckXSS" id="txtKeyWord" onkeypress="if (event.keyCode==13){ goAddKeyWord(); return false;}" >
					<a href="#" class="btnTypeDefault" onclick="goAddKeyWord();"><spring:message code='Cache.lbl_SchAddItem'/></a><a href="#" class="btnTypeDefault ml5" onclick="goAllDelKeyWord();"><spring:message code='Cache.lbl_AllDelete'/></a>									
				</div>
			</div>
			<div class="makeMoreInput active">
				<div class="inputBoxSytel01 type02">
					<div></div>
					<div>
						 <div class="autoComText clearFloat" id="moreBox" style="display: none;">
							<!-- <div>프로젝트 신청<a href="#" class="btnRemoveAuto">삭제</a></div>
							<div>크로스플랫폼<a href="#" class="btnRemoveAuto">삭제</a></div> -->
						</div>
		 			</div>
 				 </div>
			</div>
			<div class="inputBoxSytel01 type02">
				<div><span><spring:message code='Cache.lbl_SingleLineIntroduction'/></span></div>
				<div><input type="text" class="txtInp HtmlCheckXSS ScriptCheckXSS" id="textLineIntroduction"></div>
			</div>
			<div class="inputBoxSytel01 type02">
				<div><span class="star"><spring:message code='Cache.lbl_CommunityType'/></span></div>
				<div>
					<p>
						<span class="radioStyle04"><input type="radio" id="ttt01" name="tttt"><label for="ttt01"><span class="mr5"><span></span></span><spring:message code='Cache.lbl_Opening'/></label></span>
						<span class="radioStyle04 ml25"><input type="radio" id="ttt02" name="tttt"><label for="ttt02"><span class="mr5"><span></span></span><spring:message code='Cache.lbl_PrivateMould'/></label></span>
						<!-- <span class="radioStyle04 ml25"><input type="radio" id="ttt03" name="tttt"><label for="ttt03"><span class="mr5"><span></span></span>기밀형</label></span> -->
					</p>
					<p class=" mt10">
						<span class="blueStart" id="pCuTypeDiscription"><spring:message code='Cache.msg_CommunityOpeningTypeExplan'/></span>
					</p>
				</div>
			</div>
			<div class="inputBoxSytel01 type02">
				<div><span class="star"><spring:message code='Cache.lbl_JoiningMethod'/></span></div>
				<div>
					<p>
						<span class="radioStyle04"><input type="radio" id="sss01" name="ssss"><label for="sss01"><span class="mr5"><span></span></span><spring:message code='Cache.msg_CommunityImmediatelyJoin'/></label></span>									
					</p>									
					<p class=" mt15">
						<span class="radioStyle04"><input type="radio" id="sss02" name="ssss"><label for="sss02"><span class="mr5"><span></span></span><spring:message code='Cache.msg_CommunityApprovalJoin'/></label></span>										
					</p>
				</div>
			</div>
			<div class="inputBoxSytel01 type02">
				<div><span class="star"><spring:message code='Cache.lbl_DefaultMemberLevel'/></span></div>
				<div>
					<select class="selectType02 size102" id="ddlMemberLevel">
					</select>
				</div>
			</div>
			<div class="inputBoxSytel01 type02">
				<div><span class="star"><spring:message code='Cache.lbl_CommuntyBoardType'/></span></div>
				<div>
					 <select class="selectType02 size102" id="ddlDefaultBoardType">
					 </select>
				</div>
			</div>
			<div class="inputBoxEdit">
				<div class="inputBoxSytel01 type02">
					<div><span><spring:message code='Cache.lbl_CommunityStipulation'/></span></div>
					<input type="hidden" id="oldtxtStipulation"/>
					<div class="txtEdit" id="editChangeA">
						<textarea id="txtStipulation" class="HtmlCheckXSS ScriptCheckXSS" maxlength="300"></textarea>
						<p class="editChange"><a href="#" onclick="editChange('A')"><spring:message code='Cache.lbl_editChange'/></a></p>
					</div>
				</div>
				<div class="inputBoxSytel01 type02">
					<div><span><spring:message code='Cache.lbl_Community_Guide'/></span></div>
						<input type="hidden" id="oldtxtIntroduction"/>
						<div class="txtEdit" id="editChangeB">
							<textarea id="txtIntroduction" class="HtmlCheckXSS ScriptCheckXSS" maxlength="300"></textarea>
							<p class="editChange"><a href="#" onclick="editChange('B')"><spring:message code='Cache.lbl_editChange'/></a></p>
						</div>
					</div>
				</div>
			</div>
		</div>
		<div class="cRContEnd">
			<a href="#" class="btnTop"><spring:message code='Cache.lbl_topMove'/></a>
		</div>
</div>
</form>
<script type="text/javascript">
var timeout = "";

var g_editorKind = Common.getBaseConfig('EditorType');

$(function(){
	$('.btnTop').on('click', function(){
		$('.mScrollVH').animate({scrollTop:0}, '500');
	});

	$("#txtCommunityName").validation("limitChar",50);
	$("#txtKeyWord").validation("limitChar",20);
	$("#textLineIntroduction").validation("limitChar",100);
	
	setValue();
	setEvent();
});

function setValue(){
	var recResourceHTML = "";
	$.ajax({
		url:"/groupware/layout/communitySelectCreateId.do",
		type:"POST",
		async:false,
		data:{
			
		},
		success:function (data) {
			$("#cId").val(data.id);
			$("#uDnID").val(data.DN_ID);
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/communitySelectCreateId.do", response, status, error); 
		}
	}); 
	
}

function setEvent(){
	$("#ttt01").prop("checked", true);
	$("#sss01").prop("checked", true);
	
	var lang = Common.getSession("lang");
	Common.getBaseCode("CuMemberLevel").CacheData.forEach(function(item){
		if (item.CodeGroup !== item.Code && item.Code !== "9") {
			var $option = $("<option/>", {"text": CFN_GetDicInfo(item.MultiCodeName, lang), "value": item.Code});
			$("#ddlMemberLevel").append($option);
		}
	});
	
	$("#ddlDefaultBoardType").coviCtrl("setSelectOption", 
			"/groupware/layout/selectCommunityBaseCode.do", 
			{"CodeGroup": "CommunityDefaultBoardType"},
			"",
			""
	);
	
	$("input[name='tttt']").on("click",function(){
		if($('input:radio[id="ttt01"]').is(':checked')){
			$("#pCuTypeDiscription").html("<spring:message code='Cache.msg_CommunityOpeningTypeExplan'/>");	
		}else{
			$("#pCuTypeDiscription").html("<spring:message code='Cache.msg_CommunityPrivateMouldTypeExplan'/>");	
		}
		
	});
	
}

function btnCategoryParenOnClick(){
	var url = "";
	url += "/groupware/layout/selectParentSearch.do?"+"DN_ID="+$("#uDnID").val()+"&CategoryID=&target=C";
		
	Common.open("", "ParentSearchPopup", "<spring:message code='Cache.lbl_highDiv'/>", url, "300px", "400px", "iframe", true, null, null, true);
}
function TreeData(id, name, target){
	if(target == "C"){
		$("#txtCategoryName").val(name);
		$("#_ParentID").val(id);
	}
}

function CheckCommunityName(){
	if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
	var communityName = $("#txtCommunityName").val();
	
	if(communityName == null || communityName == ""){
		Common.Warning("<spring:message code='Cache.msg_blankValue'/>", "warning", function(answer){ // 빈값을 입력할 수 없습니다.
			if(answer){
				$("#txtCommunityName").focus();
			}
		});
		
		return false;
	}
	
	$.ajax({
		type:"POST",
		data:{
			DisplayName : communityName
		},
		async : false,
		url:"/groupware/layout/checkCommunityName.do",
		success:function (data) {
			if(data.status == "SUCCESS"){
				Common.Inform("<spring:message code='Cache.msg_canusedCuName'/>"); // 사용 가능한 커뮤니티 이름입니다.
				$("#oldCommunity").val(communityName);
				$("#oldCommunityCount").val("1");
			}else{ 
				Common.Warning("<spring:message code='Cache.msg_duplyCommunityName'/>"); // 커뮤니티 이름이 중복되어 사용할 수 없습니다.
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
	
	Common.open("", "DictionaryPopup", "<spring:message code='Cache.lbl_MultiLangSet'/>", url, "500px", "200px", "iframe", true, null, null, true);
}

function addSubDicCallback(data){
	
	document.getElementById("DIC_Code_ko").value = data.KoFull;
	document.getElementById("DIC_Code_en").value = data.EnFull;
	document.getElementById("DIC_Code_ja").value = data.JaFull;
	document.getElementById("DIC_Code_zh").value = data.ZhFull;
	document.getElementById("hiddenCategory").value = coviDic.convertDic(data);
	
	$("#txtCommunityName").val(data.KoFull);
	
	Common.Close('DictionaryPopup');
}

function initDicPopup(){
	
	if($("#hiddenCategory").val() ==  null || $("#hiddenCategory").val() ==  ''){
		$("#hiddenCategory").val($("#txtCommunityName").val());
	}
		
	return $("#hiddenCategory").val(); 
}

function goAddKeyWord(){
	var special_pattern = /[`~!@#$%^&*,|\\\'\";:\/?]/gi;

	if( special_pattern.test($("#txtKeyWord").val()) == true ){
		Common.Warning("<spring:message code='Cache.msg_specialNotAllowed'/>"); //특수문자는 사용할 수 없습니다.
	    return;
	}else if($("#txtKeyWord").val().replace(/ /gi, "") == ''){
		Common.Warning("<spring:message code='Cache.msg_blankValue'/>"); //빈값을 입력할 수 없습니다.
	}else{
		var keyWordArry = ReKeyWord();
		keyWordArry = keyWordArry + $("#txtKeyWord").val();
		
		if(keyWordArry.length > 199){
			Common.Warning("<spring:message code='Cache.msg_exceededKeyword'/>"); //키워드를 등록 할 수 있는 길이를 초과하였습니다.
			return;
		}
		
		$("#moreBox").show();
		$("#moreBox").append("<div name='keyWord' id='divKeyWord_"+$("#keyNum").val()+"' value='"+$("#txtKeyWord").val()+"'>"+$("#txtKeyWord").val()+"<a href='#' onclick='goDelKeyWord(\""+$("#keyNum").val()+"\");')' class='btnRemoveAuto'>삭제</a></div>");
		$("#txtKeyWord").val("");
		$("#keyNum").val(parseInt($("#keyNum").val())+1);
	}
}

function goDelKeyWord(keyNum){
	$("#divKeyWord_"+keyNum).remove();
	if($("div[id^='divKeyWord_']").size() < 1){
		$("#moreBox").hide();
	}
}

function goAllDelKeyWord(){
	$("div[id^='divKeyWord_']").remove();
	$("#moreBox").hide();
}

function editChange(type){
	if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

	if(type == "A"){
		 $("#editChagneANum").val("Y");
		 $("#oldtxtStipulation").val($("#txtStipulation").val());
		 coviEditor.loadEditor(
					'editChangeA',
					{
						editorType : g_editorKind,
						containerID : 'editA',
						frameHeight : '311',
						focusObjID : '', 
						onLoad: function() {
							 coviEditor.setBody(g_editorKind, 'editA', $("#oldtxtStipulation").val());
						 }
					}
		);
		 
		/*  timeout = setTimeout(function() {
			 coviEditor.setBody(g_editorKind, 'editA', $("#oldtxtStipulation").val());
			 clearTimeout(timeout);
		 }, 500); */
		 
	}else{
		 $("#editChagneBNum").val("Y");
		 $("#oldtxtIntroduction").val($("#txtIntroduction").val());
		 coviEditor.loadEditor(
					'editChangeB',
					{
						editorType : g_editorKind,
						containerID : 'editB',
						frameHeight : '311',
						focusObjID : '',
						onLoad: function(){
							 coviEditor.setBody(g_editorKind, 'editB', $("#oldtxtIntroduction").val());
						} 
							
					}
		);
		 
		/*  timeout = setTimeout(function() {
			 coviEditor.setBody(g_editorKind, 'editB', $("#oldtxtIntroduction").val());
			 clearTimeout(timeout);
		 }, 500);
		  */
	}
}

function goReset(){
	setEvent();
	$("#oldCommunity").val("");
	$("#oldCommunityCount").val("0");
	$("#_ParentID").val("");
	$("#hiddenCategory").val("");
	$("#DIC_Code_ko").val("");
	$("#DIC_Code_en").val("");
	$("#DIC_Code_ja").val("");
	$("#DIC_Code_zh").val("");
	$("#txtCommunityName").val("");
	$("#txtCategoryName").val("");
	$("#txtKeyWord").val("");
	$("#textLineIntroduction").val("");
	
	if($("#editChagneANum").val() == "N"){
		$("#txtStipulation").val("");
	}else{
		coviEditor.setBody(g_editorKind, 'editA', "");
	}
	if($("#editChagneBNum").val() == "N"){
		$("#txtIntroduction").val("");
	}else{
		coviEditor.setBody(g_editorKind, 'editB', "");
	}
	goAllDelKeyWord();
	setValue();
}

function goAdd(){
	if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

	if($("#txtCategoryName").val() == ""){
		Common.Warning("<spring:message code='Cache.msg_communityClassification'/>"); //커뮤니티 분류를 입력하세요.
		return ;
	}
	if($("#txtCommunityName").val().replace(/(\s*)/g, "") == ""){
		Common.Warning("<spring:message code='Cache.msg_inputCommunityName'/>"); //커뮤니티 이름을 입력하세요.
		return ;
	}
	
	if($("#oldCommunityCount").val() == "0"){
		Common.Warning("<spring:message code='Cache.msg_DuplicateCheckCuName'/>"); //커뮤니티 이름 중복체크를 하십시오.
		return ;
	}
	
	if($("#oldCommunity").val() != $("#txtCommunityName").val()){
		Common.Warning("<spring:message code='Cache.msg_DuplicateCheckCuName'/>"); //커뮤니티 이름 중복체크를 하십시오.
		return ;
	}
	
	var ddlType = "";
	
	if($('input:radio[id="ttt01"]').is(':checked')){
		ddlType = "P";
	}else{
		ddlType = "C";
	}
	
	var ddlJoinMothod = "";
	
	if($('input:radio[id="sss01"]').is(':checked')){
		ddlJoinMothod = "A";
	}else{
		ddlJoinMothod = "M";
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
		txtIntroductionInlineImage = "";
	}else{
		txtIntroductionEditer = coviEditor.getBody(g_editorKind, 'editB');
		txtIntroduction = coviEditor.getBodyText(g_editorKind, 'editB');
		txtIntroductionInlineImage =  coviEditor.getImages(g_editorKind, 'editB');
	}
	
	var keyWordArry = "";
	
	keyWordArry = ReKeyWord();
	
	Common.Confirm("<spring:message code='Cache.msg_createCommunityConfirm'/>", "Confirmation Dialog", function (confirmResult) {
		if (confirmResult) {
			$.ajax({
				url:"/groupware/layout/CommunityCreateSite.do",
				type:"post",
				data:{
					DIC_Code_ko : parent.document.getElementById("DIC_Code_ko").value,
					DIC_Code_en : parent.document.getElementById("DIC_Code_en").value,
					DIC_Code_ja : parent.document.getElementById("DIC_Code_ja").value,
					DIC_Code_zh : parent.document.getElementById("DIC_Code_zh").value,
					DIC_Code : $("#txtCategoryName").val(),
					txtCommunityName : $("#txtCommunityName").val(),
					_ParentID : $("#_ParentID").val(),
					textLineIntroduction : $("#textLineIntroduction").val(),
					ddlType : ddlType,
					ddlJoinMothod : ddlJoinMothod,
					ddlMemberLevel : $("#ddlMemberLevel").val(),
					ddlDefaultBoardType : $("#ddlDefaultBoardType").val(),
					keyWordArry : keyWordArry,
					txtStipulation : txtStipulation,
					txtStipulationEditer : txtStipulationEditer,
					txtStipulationInlineImage : txtStipulationInlineImage,
					txtIntroduction : txtIntroduction,
					txtIntroductionEditer : txtIntroductionEditer,
					txtIntroductionInlineImage : txtIntroductionInlineImage,
					DescriptionOption : $("#editChagneBNum").val(),
					ProvisionOption :	$("#editChagneANum").val()
					
				},
				success:function (data) {
					if(data.status == "SUCCESS"){
						Common.Inform("<spring:message code='Cache.msg_SuccessRegist'/>"); //정상적으로 등록되었습니다.
						//CoviMenu_GetContent('/groupware/layout/community_CommunityUserList.do?CLSYS=community&CLMD=user&CLBIZ=Community&searchWord='+$("#txtCommunityName").val()+"&searchType=C&CategoryID=''");
						CoviMenu_GetContent('/groupware/layout/community_CommunityUserList.do?CLSYS=community&CLMD=user&CLBIZ=Community');
					}else{ 
						Common.Error("<spring:message code='Cache.msg_38'/>"); //오류로 인해 저장 하지 못 하였습니다.
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/groupware/layout/CommunityCreateSite.do", response, status, error); 
				}
			}); 
		}
	});
}

function ReKeyWord(){
	var str = "";
	
	$("div[id^='divKeyWord_']").each(function(){
		if($(this).attr("value") != null && $(this).attr("value") != ""){
			str = str + $(this).attr("value")+",";
		}
	});
	
	return str;
}

function movePage() {
	CoviMenu_GetContent(g_lastURL);
}
</script>