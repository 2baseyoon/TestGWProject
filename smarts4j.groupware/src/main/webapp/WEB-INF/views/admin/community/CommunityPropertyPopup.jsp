<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>
<%
	String DNID = request.getParameter("DN_ID");
	String path = request.getParameter("CategoryID");
	String folder = request.getParameter("MemberOf");
	String pType = request.getParameter("pType");
	String mode = request.getParameter("mode");
%>
		
<form>
	<div class="pop_body1" style="width:100%;min-height: 100%">
	    <table class="AXFormTable" >       
	    	<colgroup>
				<col style="width: 110px ;"></col>
				<col></col>
	    	</colgroup>       
	        <tbody>
	        	<tr>
	                <th><spring:message code='Cache.lbl_OwnedCompany'/> <font color="red">*</font></th>
	                <td>   
	                	<select id="communityDomainSelBox" name="communityDomainSelBox" class="AXSelect W100">
						</select>        	           
	                </td>
	                <th><spring:message code='Cache.lbl_selUse'/> <font color="red">*</font></th>
	                <td>   
	                	<select id="communityUseYnSelBox" name="communityUseYnSelBox" class="AXSelect W100">
							<option value=""><spring:message code='Cache.lbl_Choice'/></option>
							<option value="Y"><spring:message code='Cache.lbl_USE_Y'/></option>
							<option value="N"><spring:message code='Cache.lbl_noUse'/></option>
						</select> 	                  
	                </td>
	            </tr>
	        	<tr>
	                <th><spring:message code='Cache.lbl_CateName'/> <font color="red">*</font></th>
	                <td colspan="3">   
	                	<input type="text" class="AXInput HtmlCheckXSS ScriptCheckXSS" id="txtCategoryName" style="width: 65%;"/>
	                	<input type="button" value="<spring:message code='Cache.lbl_MultilanguageSettings'/>" onclick="dictionaryLayerPopup()" class="AXButton" />
	                </td>
	            </tr>
	        	<tr>
	                <th><spring:message code='Cache.lbl_highDiv'/> <font color="red">*</font></th>
	                <td colspan="3">   
	                	<input type="text" class="AXInput HtmlCheckXSS ScriptCheckXSS" id="txtParentName" style="width: 65%;"/>
                		<input type="button" value="<spring:message code='Cache.lbl_Browse'/>" onclick="parentNameSearch();" class="AXButton" id="parentSearch"/>
	                </td>
	            </tr>
	            <tr>
	                <th><spring:message code='Cache.lbl_PriorityOrder'/> <font color="red">*</font></th>
	                <td>
	                	<input type="text" class="AXInput HtmlCheckXSS ScriptCheckXSS" id="txtSortKey" style="width: 90%;"/>
	                </td>
	                <th><spring:message code='Cache.lbl_Alias'/></th>
	                <td>
	                	<input type="text" class="AXInput HtmlCheckXSS ScriptCheckXSS" id="txtAlias" style="width: 90%;"/>
	                </td>
	            </tr>
	            <tr>
	                <th><spring:message code='Cache.lbl_explanation'/></th>
	                <td colspan="3">
	                	<textarea id="txtDescription" rows="5" style="width: 95%; margin: 0px; resize:vertical; font-family: 'Nanum Gothic','맑은고딕'; " id="layoutHTML" class="AXTextarea HtmlCheckXSS ScriptCheckXSS"></textarea>                         
	                </td>
	            </tr>
	        </tbody>
	    </table>        
	    <div class="pop_btn2" align="center">
	     	<input type="button" value="<spring:message code='Cache.btn_apv_save'/>" onclick="editProperty();" class="AXButton red" />
	     	<input type="button" value="<spring:message code='Cache.btn_apv_close'/>" onclick="Common.Close();"  class="AXButton" />                    
	    </div>           
	</div>
	<input type="hidden" id ="mode" value = "${mode}"/>
	<input type="hidden" id ="selCategoryID" value = ""/>
	<input type="hidden" id="_ParentID" value= ""/>
	
	<input type="hidden" id ="hiddenCategory" value = ""/>
	<input type="hidden" id ="DIC_Code_ko" value = ""/>
	<input type="hidden" id ="DIC_Code_en" value = ""/>
	<input type="hidden" id ="DIC_Code_ja" value = ""/>
	<input type="hidden" id ="DIC_Code_zh" value = ""/>
</form>
<script  type="text/javascript">
var dnID = <%=DNID%>;
var CategoryID = "";
var MemberOf ="";
var pType = '<%=pType%>';

<% if("Folder".equals(pType) && "E".equals(mode)){ %>
		CategoryID = <%=path%>;
<% }else if(!"".equals(folder) && folder != null && !"C".equals(mode)){ %>
		<%-- CategoryID = <%=folder%>; --%>
		CategoryID = <%=path%>;
<% } %>

<% if("Folder".equals(pType) && "E".equals(mode)){ %>
		MemberOf = <%=folder%>;
<% }else if(!"".equals(path) && path != null && !"C".equals(mode)){ %>
		MemberOf = <%=path%>;
<% } %>

$(document).ready(function(){
	// 값 초기화
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
	
	eventInit();
});

function eventInit(){
	selBoxBind();
	if($("#mode").val() == "E"){
		selectProperty();
	}else{
		eventSetting();
	}
}

function selBoxBind(){
	$.ajax({
		type:"POST",
		data:{
			
		},
		async : false,
		url:"/groupware/layout/community/selectCommunityD.do",
		success:function (data) {
			var recResourceHTML = "";
			$("#selectDomain").html("");
			if(data.list.length > 0){
				$(data.list).each(function(i,v){
					recResourceHTML += '<option value="'+v.DomainID+'"  >'+v.DisplayName+'</option>';
    			});
			}
			
			$("#communityDomainSelBox").append(recResourceHTML);
			
		},
		error:function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("/groupware/layout/community/selectCommunityD.do", response, status, error);
		}
	});
}

function selectProperty(){
	$.ajax({
		type:"POST",
		data:{
			"DN_ID" : dnID,
			"CategoryID" : CategoryID,
			"pType" : pType,
			"MemberOf" : MemberOf
		},
		async : false,
		url:"/groupware/community/selectProperty.do",
		success:function (data) {
			
			if(data.list.length > 0){
				$(data.list).each(function(i,v){
					$("#communityDomainSelBox").val(v.DN_ID);
					$("#communityUseYnSelBox").val(v.IsUse);
					$("#txtCategoryName").val(v.DisplayName);
					$("#txtSortKey").val(v.SortKey);
					$("#txtAlias").val(v.FolderAlias);
					$("#txtDescription").val(v.Description);
					
					$("#communityDomainSelBox").attr("disabled",true);
					
					if(pType != "Folder"){
						$("#txtParentName").val('').attr("disabled",true);
						$("#parentSearch").attr("disabled",true);
					}else{
						$("#txtParentName").val(v.parentDisplayName).attr("disabled",true);
						$("#_ParentID").val(v.MemberOf);
					}
					
					$("#selCategoryID").val(v.CategoryID);
					
					
					if(opener){
						document.getElementById("DIC_Code_ko").value = v.KoFullWord;
						document.getElementById("DIC_Code_en").value = v.EnFullWord;
						document.getElementById("DIC_Code_ja").value = v.JaFullWord;
						document.getElementById("DIC_Code_zh").value = v.ZhFullWord;
						
						document.getElementById("hiddenCategory").value = v.KoFullWord+";"+v.EnFullWord+";"+v.JaFullWord+";"+v.ZhFullWord+";;;;;;;";
					}else{
						parent.document.getElementById("DIC_Code_ko").value = v.KoFullWord;
						parent.document.getElementById("DIC_Code_en").value = v.EnFullWord;
						parent.document.getElementById("DIC_Code_ja").value = v.JaFullWord;
						parent.document.getElementById("DIC_Code_zh").value = v.ZhFullWord;
						
						parent.document.getElementById("hiddenCategory").value = v.KoFullWord+";"+v.EnFullWord+";"+v.JaFullWord+";"+v.ZhFullWord+";;;;;;;";
					}
					
					
    			});
			}
			
		},
		error:function (error){
			  CFN_ErrorAjax("/groupware/community/selectProperty.do", response, status, error);
		}
	});
}

function editProperty(){
	var DIC_Code_ko = "";
	var DIC_Code_en = "";
	var DIC_Code_ja = "";
	var DIC_Code_zh = "";

	if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

	if(opener){
		DIC_Code_ko = document.getElementById("DIC_Code_ko").value;
		DIC_Code_en = document.getElementById("DIC_Code_en").value;
		DIC_Code_ja = document.getElementById("DIC_Code_ja").value;
		DIC_Code_zh = document.getElementById("DIC_Code_zh").value;
		
	}else{
		DIC_Code_ko = parent.document.getElementById("DIC_Code_ko").value;
		DIC_Code_en = parent.document.getElementById("DIC_Code_en").value;
		DIC_Code_ja = parent.document.getElementById("DIC_Code_ja").value;
		DIC_Code_zh = parent.document.getElementById("DIC_Code_zh").value;
		
	}
	
	if(DIC_Code_ko == null || DIC_Code_ko == ""){
		DIC_Code_ko =  $("#txtCategoryName").val();
	}
	
	if(checkValue()){
		$.ajax({
			type:"POST",
			data:{
				mode : $("#mode").val(),
				CategoryID : $("#selCategoryID").val(),
				Description : $("#txtDescription").val(),
				MemberOf : $("#_ParentID").val(),
				DisplayName : $("#txtCategoryName").val(),
				
				SortKey : $("#txtSortKey").val(),
				FolderAlias : $("#txtAlias").val(),
				IsUse : $("#communityUseYnSelBox").val(),
				DN_ID : $("#communityDomainSelBox").val(),
				
				FolderType : pType,
				
				DIC_Code_ko : DIC_Code_ko,
				DIC_Code_en : DIC_Code_en,
				DIC_Code_ja : DIC_Code_ja,
				DIC_Code_zh : DIC_Code_zh,
				DIC_Code : $("#txtCategoryName").val()
			},
			async : false,
			url:"/groupware/community/updateCommunityProperty.do",
			success:function (data) {
				if(data.status == "SUCCESS"){
					if(opener){
						opener.setTreeData();
						opener.gridRefresh();
					}else{
						parent.setTreeData();
						parent.gridRefresh();
					}
					Common.Close();
					
				}else{ 
					if(data.errorType == "Sort"){
						Common.Warning("<spring:message code='Cache.msg_notSamePriority'/>"); //동일한 우선순위 값을 가질 수 없습니다.
					}else{
						Common.Error("<spring:message code='Cache.msg_FailProcess' />");
						if(opener){
							opener.gridRefresh();
						}else{
							parent.gridRefresh();
						}
						Common.Close();
					}
					
				}
			},
			error:function (error){
				  CFN_ErrorAjax("/groupware/community/updateCommunityProperty.do", response, status, error);
			}
		});
	}
}

function checkValue(){
	var check = false;
	
	if($("#communityDomainSelBox").val() == ''){
		Common.Warning("<spring:message code='Cache.msg_Common_38'/>");
		return check;
	}
	
	if($("#communityUseYnSelBox").val() == ''){
		Common.Warning("<spring:message code='Cache.msg_Common_04'/>");
		return check;
	}
	
	if($("#txtCategoryName").val() == '' || $("#txtCategoryName").val() == null){
		Common.Warning("<spring:message code='Cache.msg_Common_39'/>");
		return check;
	}
	
	if($("#txtSortKey").val() == ''){
		Common.Warning("<spring:message code='Cache.msg_Common_02'/>");
		return check;
	}
	
	check = true;
	return check;
}


function dictionaryLayerPopup() {
	var option = {
			lang : 'ko',
			hasTransBtn : 'true',
			allowedLang : 'ko,en,ja,zh',
			useShort : 'false',
			dicCallback : 'addDicCallback',
			openerID : CFN_GetQueryString("CFN_OpenLayerName"),
			popupTargetID : 'DictionaryPopup',
			init : 'initDicPopup'
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
	
	if(opener){
		CFN_OpenWindow(url,"<spring:message code='Cache.lbl_MultiLangSet'/>",500,200,"");
	}else{
		parent.Common.open("", "DictionaryPopup", "<spring:message code='Cache.lbl_MultiLangSet'/>", url, "500px", "200px", "iframe", true, null, null, true);
	}
	
}

function parentNameSearch(){
	var url = "";
	url += "/groupware/community/selectParentSearch.do?"+"DN_ID="+dnID+"&CategoryID="+CategoryID;
	
	if(opener){
		CFN_OpenWindow(url,"<spring:message code='Cache.lbl_MultiLangSet'/>",300,300,"");
	}else{
		parent.Common.open("", "ParentSearchPopup", "<spring:message code='Cache.lbl_highDiv'/>", url, "300px", "300px", "iframe", true, null, null, true);
	}
	
}

function eventSetting(){
	$("#txtParentName").attr("disabled",true);
	$("#communityDomainSelBox").val(dnID).attr("disabled",true);
}

function initDicPopup(){
	var value = opener ? document.getElementById("hiddenCategory").value : parent.document.getElementById("hiddenCategory").value;
	
	if(!value || value === ";;;;;;;;;;"){
		value = document.getElementById('txtCategoryName').value;
	}
	
	return value;
}

function addDicCallback(data){
	var jsonData = JSON.parse(data);
	
	if(opener){
		document.getElementById("DIC_Code_ko").value = jsonData.KoFull;
		document.getElementById("DIC_Code_en").value = jsonData.EnFull;
		document.getElementById("DIC_Code_ja").value = jsonData.JaFull;
		document.getElementById("DIC_Code_zh").value = jsonData.ZhFull;
		document.getElementById("hiddenCategory").value = coviDic.convertDic(jsonData);
	}else{
		parent.document.getElementById("DIC_Code_ko").value = jsonData.KoFull;
		parent.document.getElementById("DIC_Code_en").value = jsonData.EnFull;
		parent.document.getElementById("DIC_Code_ja").value = jsonData.JaFull;
		parent.document.getElementById("DIC_Code_zh").value = jsonData.ZhFull;
		parent.document.getElementById("hiddenCategory").value = coviDic.convertDic(jsonData);
	}
	
	$("#txtCategoryName").val(jsonData.KoFull);
	
	Common.Close("DictionaryPopup");
}

function TreeData(id, name, target){
	if(target == "P"){
		$("#txtParentName").val(name);
		$("#_ParentID").val(id);
	}else if(target == "C"){
	    $("#txtCategoryName").val(name);
		$("#_ParentID").val(id);
	}
}


</script>