<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>
<%
	String mode = request.getParameter("mode");
%>
<form>
	<div class="pop_body1" style="width:100%;min-height: 100%">
	    <table class="AXFormTable" >       
	    	<colgroup>
				<col style="width: 110px ;"></col>
				<col style="width: 250px ;"></col>
				<col style="width: 110px ;"></col>
				<col></col>
	    	</colgroup>       
	        <tbody>
	        	<tr>
	                <th><spring:message code="Cache.lbl_Domain"/><!-- 도메인 --> <font color="red">*</font></th>
	                <td>
	                	<select id="communityDoPSelBox" name=communityDoPSelBox class="AXSelect W100">
						</select> 	  
	                </td>
	                <th><spring:message code="Cache.lbl_CommunityType"/><!-- 커뮤니티 유형 --> <font color="red">*</font></th>
	                <td>
	                	<select id="communityStatusSelBox" name="communityStatusSelBox" class="AXSelect W100">
						</select> 	  
	                </td>
	           	</tr>
	           	<tr>
	                <th><spring:message code="Cache.lbl_FolderType"/><!-- 폴더유형 --> <font color="red">*</font></th>
	                <td>
	                	<select id="folderTypeSelBox" name="folderTypeSelBox" class="AXSelect W100">
						</select> 	  
	                </td>
	             	<th><spring:message code="Cache.lbl_selUse"/><!-- 사용유무 --> <font color="red">*</font></th>
	                <td>
	                	<select id="boardSettingUseSelBox" name="boardSettingUseSelBox" class="AXSelect W100">
							<option value="Y"><spring:message code='Cache.lbl_USE_Y'/></option>
							<option value="N"><spring:message code='Cache.lbl_noUse'/></option>
						</select> 	                 
	                </td>
	           	</tr>
	           	<tr>
	                <th><spring:message code="Cache.lbl_BoardNm"/><!-- 게시판명 --> <font color="red">*</font></th>
	                <td colspan="3">
	                	<input type="text" class="AXInput HtmlCheckXSS ScriptCheckXSS" id="txtBoardName" style="width: 56%;"/>                   
                		<input type="button" value="<spring:message code='Cache.lbl_MultilanguageSettings'/>" onclick="btnDictionaryInfoOnClick()" class="AXButton" />
	                </td>
<%-- 	                <th><spring:message code="Cache.lbl_SortOrder"/><!-- 정렬순서 --></th> --%>
<!-- 	                <td > -->
<!-- 	                	<input type="text" class="AXInput HtmlCheckXSS ScriptCheckXSS" id="txtSortKey" style="width: 82%;"/>                    -->
<!-- 	                </td> -->
	           	</tr>
	           	<tr>
	                <th><spring:message code="Cache.lbl_Description"/><!-- 설명 --></th>
	                <td colspan="3">
	                	<textarea id="txtDescription" rows="4" style="width: 96%; margin: 0px;  resize:vertical; font-family: 'Nanum Gothic','맑은고딕'; " id="layoutHTML" class="AXTextarea HtmlCheckXSS ScriptCheckXSS"></textarea>                         
	                </td>
	            </tr>
	        </tbody>
	    </table>      
	    <div class="pop_btn2" align="center">
	    	<% if("E".equals(mode)){ %>
				<input type="button" value="<spring:message code='Cache.btn_Edit'/>" onclick="editBoardSetting();" class="AXButton red" />
			<% } %>
			<% if("C".equals(mode)){ %>
		     	<input type="button" value="<spring:message code='Cache.btn_apv_save'/>" onclick="editBoardSetting();" class="AXButton red" />
			<% } %>
	     	<input type="button" value="<spring:message code='Cache.btn_apv_close'/>" onclick="Common.Close();"  class="AXButton" />                    
	    </div>           
	</div>
	
	<input type="hidden" id ="mode" value = "${mode}"/>
	<input type="hidden" id ="menuID" value = "${MenuID}"/>
	<input type="hidden" id ="hiddenCategory" value = ""/>
	<input type="hidden" id ="DIC_Code_ko" value = ""/>
	<input type="hidden" id ="DIC_Code_en" value = ""/>
	<input type="hidden" id ="DIC_Code_ja" value = ""/>
	<input type="hidden" id ="DIC_Code_zh" value = ""/>
</form>
<script  type="text/javascript">

$(document).ready(function(){	
	eventInit();
	dataSetting();
});

function eventInit(){
	$.ajax({
		type:"POST",
		data:{
			
		},
		async : false,
		url:"/groupware/layout/community/selectCommunityD.do",
		success:function (data) {
			var recResourceHTML = "";
			$("#communityDoPSelBox").html("");
			if(data.list.length > 0){
				$(data.list).each(function(i,v){
					recResourceHTML += '<option value="'+v.DomainID+'"  >'+v.DisplayName+'</option>';
    			});
			}
			
			$("#communityDoPSelBox").append(recResourceHTML);
			
		},
		error:function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("/groupware/layout/community/selectCommunityD.do", response, status, error);
		}
	});
 	
    $("#folderTypeSelBox").coviCtrl("setSelectOption", 
			"/groupware/layout/community/selectCommunityFolderType.do", 
			{"BizSection": "Community"},
			"",
			""
	);
    
    selBoxBind();
    
    $("#communityDoPSelBox").on("change", selBoxBind);
}

function selBoxBind(){
	$("#communityStatusSelBox").coviCtrl("setSelectOption", 
 			"/groupware/layout/community/selectCommunityBaseCode.do", 
			{"CodeGroup": "CommunityDefaultBoardType", "DomainID": $("#communityDoPSelBox").val()},
			"",
			""
	);
}

function dataSetting(){
	if($("#mode").val() == "E"){
		$.ajax({
			type:"POST",
			data:{
					MenuID : $("#menuID").val()
			},
			url:"/groupware/layout/community/communityBoardSettingInfo.do",
			success:function (data) {
				if(data.list.length > 0){
					$(data.list).each(function(i,v){
						$("#communityDoPSelBox").val(v.DN_ID);
						$("#communityStatusSelBox").val(v.CommunityType);
						$("#folderTypeSelBox").val(v.FolderType);
						$("#boardSettingUseSelBox").val(v.IsUse);
						$("#txtBoardName").val(v.BoardName);
						$("#txtSortKey").val(v.SortKey);
						$("#txtDescription").val(v.Description);
						
						if(opener){
							document.getElementById("DIC_Code_ko").value = "";
							document.getElementById("DIC_Code_en").value = "";
							document.getElementById("DIC_Code_ja").value = "";
							document.getElementById("DIC_Code_zh").value = "";
							
							if(v.KoFullWord == null || v.KoFullWord == ""){
								document.getElementById("hiddenCategory").value = v.BoardName+";"+v.EnFullWord+";"+v.JaFullWord+";"+v.ZhFullWord+";;;;;;;";
							}else{
								document.getElementById("hiddenCategory").value = v.KoFullWord+";"+v.EnFullWord+";"+v.JaFullWord+";"+v.ZhFullWord+";;;;;;;";
							}
							
						}else{
							parent.document.getElementById("DIC_Code_ko").value = "";
							parent.document.getElementById("DIC_Code_en").value = "";
							parent.document.getElementById("DIC_Code_ja").value = "";
							parent.document.getElementById("DIC_Code_zh").value = "";
							
							if(v.KoFullWord == null || v.KoFullWord == ""){
								parent.document.getElementById("hiddenCategory").value = v.BoardName+";"+v.EnFullWord+";"+v.JaFullWord+";"+v.ZhFullWord+";;;;;;;";
							}else{
								parent.document.getElementById("hiddenCategory").value = v.KoFullWord+";"+v.EnFullWord+";"+v.JaFullWord+";"+v.ZhFullWord+";;;;;;;";
							}
							
						}
						
					});
				}
			},
			error:function(response, status, error){
			     //TODO 추가 오류 처리
			  	 CFN_ErrorAjax("/groupware/layout/community/communityBoardSettingInfo.do", response, status, error);
			}
		}); 
	}else{
		
		if(opener){
			document.getElementById("DIC_Code_ko").value = "";
			document.getElementById("DIC_Code_en").value = "";
			document.getElementById("DIC_Code_ja").value = "";
			document.getElementById("DIC_Code_zh").value = "";
			document.getElementById("hiddenCategory").value = "";
		}else{
			parent.document.getElementById("DIC_Code_ko").value = "";
			parent.document.getElementById("DIC_Code_en").value = "";
			parent.document.getElementById("DIC_Code_ja").value = "";
			parent.document.getElementById("DIC_Code_zh").value = "";
			parent.document.getElementById("hiddenCategory").value = "";
		}
		
	}
}

function editBoardSetting(){
	if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

	if($("#txtBoardName").val() == ""){
		Common.Warning("<spring:message code='Cache.msg_apv_016'/>"); //명칭을 입력하여 주십시오.
		return ;
	}
	
	if($("#mode").val() == "E"){
		confirm = "<spring:message code='Cache.msg_RUEdit'/>"; //수정하시겠습니까?
	}else{
		confirm = "<spring:message code='Cache.msg_RURegist'/>"; //등록하시겠습니까?
	}
	
	var hiddenCategory = "";
	
	if(hiddenCategory == null || hiddenCategory == ""){
		switch (Common.getSession("lang").toUpperCase()) {
	        case "KO": hiddenCategory = $("#txtBoardName").val() + ";;;;;;;;;"; break;
	        case "EN": hiddenCategory = ";" + $("#txtBoardName").val() + ";;;;;;;;"; break;
	        case "JA": hiddenCategory = ";;" + $("#txtBoardName").val() + ";;;;;;;"; break;
	        case "ZH": hiddenCategory = ";;;" + $("#txtBoardName").val() + ";;;;;;"; break;
	        case "E1": hiddenCategory = ";;;;" + $("#txtBoardName").val() + ";;;;;"; break;
	        case "E2": hiddenCategory = ";;;;;" + $("#txtBoardName").val() + ";;;;"; break;
	        case "E3": hiddenCategory = ";;;;;;" + $("#txtBoardName").val() + ";;;"; break;
	        case "E4": hiddenCategory = ";;;;;;;" + $("#txtBoardName").val() + ";;"; break;
	        case "E5": hiddenCategory = ";;;;;;;;" + $("#txtBoardName").val() + ";"; break;
	        case "E6": hiddenCategory = ";;;;;;;;;" + $("#txtBoardName").val(); break;
		    default : hiddenCategory = $("#txtBoardName").val()+ ";;;;;;;;;"; break;
    	}	
		
		if(opener){
			document.getElementById("hiddenCategory").value = hiddenCategory;
		}else{
			parent.document.getElementById("hiddenCategory").value = hiddenCategory;
		}
	}
	
// 	if( $("#txtSortKey").val() == "" ||  $("#txtSortKey").val() == null){
// 		 $("#txtSortKey").val("0"); 
// 	}
	
	Common.Confirm(confirm, "Confirmation Dialog", function (confirmResult) {
		if (confirmResult) {
			var messageCode = ($("#mode").val() == 'E') ? "<spring:message code='Cache.msg_ChangeAlert'/>" : "<spring:message code='Cache.msg_insert'/>"
			$.ajax({
				type:"POST",
				data:{
						MenuID :$("#menuID").val(),
						mode : $("#mode").val(),
						DN_ID: $("#communityDoPSelBox").val(),
						CommunityType : $("#communityStatusSelBox").val(),
						FolderType : $("#folderTypeSelBox").val(),
						IsUse : $("#boardSettingUseSelBox").val(),
						DisplayName : $("#txtBoardName").val(),
// 						SortKey : $("#txtSortKey").val(),
						Description : $("#txtDescription").val(),
						exDisplayName : hiddenCategory
					
				},
				url:"/groupware/layout/community/updateBoardSetting.do",
				success:function (data) {
					if(data.status == "SUCCESS")
						Common.Inform(messageCode, "Information", function(){
							if(opener){
								opener.selectCommunityList();
							}else{
								parent.selectCommunityList();
							}
							
							Common.Close();
						});
				},
				error:function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("/groupware/layout/community/updateBoardSetting.do", response, status, error);
				}
			}); 
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
	
	if(opener){
		CFN_OpenWindow(url,"<spring:message code='Cache.lbl_MultiLangSet'/>",500,200,"");
	}else{
		parent.Common.open("", "DictionaryPopup", "<spring:message code='Cache.lbl_MultiLangSet'/>", url, "500px", "200px", "iframe", true, null, null, true);
	}
	
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


</script>