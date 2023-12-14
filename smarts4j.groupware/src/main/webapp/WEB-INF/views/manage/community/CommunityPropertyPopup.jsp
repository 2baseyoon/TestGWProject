<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@taglib uri="/WEB-INF/tlds/covi.tld" prefix="covi" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<form>
	<div class="sadmin_pop" >
	    <table class="sadmin_table " >       
	    	<colgroup>
				<col style="width: 110px ;"></col>
				<col></col>
	    	</colgroup>       
	        <tbody>
	        	<tr>
	                <th><spring:message code='Cache.lbl_selUse'/> <font color="red">*</font></th>
	                <td>   
	                	<select id="communityUseYnSelBox" name="communityUseYnSelBox" class="selectType02">
							<option value=""><spring:message code='Cache.lbl_Choice'/></option>
							<option value="Y"><spring:message code='Cache.lbl_USE_Y'/></option>
							<option value="N"><spring:message code='Cache.lbl_noUse'/></option>
						</select> 	                  
	                </td>
	            </tr>
	        	<tr>
	                <th><spring:message code='Cache.lbl_CateName'/> <font color="red">*</font></th>
	                <td colspan="3">   
	                	<input type="text" id="txtCategoryName" kind="dictionary" dic_src="hidCategoryName" dic_callback="addDicCallback" style="width: calc(100% - 185px);" />
	                	<a href="#" kind="dictionaryBtn" src_elem="txtCategoryName" class="btnTypeDefault" style="float: right;"><spring:message code='Cache.lbl_MultilanguageSettings'/></a>
	                </td>
	            </tr>
	        	<tr>
	                <th><spring:message code='Cache.lbl_highDiv'/> <font color="red">*</font></th>
	                <td colspan="3">   
	                	<input type="text" class="HtmlCheckXSS ScriptCheckXSS" id="txtParentName" style="width: 65%;"/>
                		<a  onclick="parentNameSearch();" class="btnTypeDefault" id="parentSearch"><spring:message code='Cache.lbl_Browse'/></a>
	                </td>
	            </tr>
	            <tr>
	                <th><spring:message code='Cache.lbl_PriorityOrder'/> <font color="red">*</font></th>
	                <td>
	                	<input type="text" class="HtmlCheckXSS ScriptCheckXSS" id="txtSortKey" style="width: 90%;"/>
	                </td>
	                <th><spring:message code='Cache.lbl_Alias'/></th>
	                <td>
	                	<input type="text" class="HtmlCheckXSS ScriptCheckXSS" id="txtAlias" style="width: 90%;"/>
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
	    <div class="bottomBtnWrap" align="center">
	     	<a type="button" value="" onclick="editProperty();" class="btnTypeDefault btnTypeBg" ><spring:message code='Cache.btn_apv_save'/></a>
	     	<a type="button" value="" onclick="Common.Close();"  class="btnTypeDefault"><spring:message code='Cache.btn_apv_close'/></a>                    
	    </div>           
	</div>
	<input type="hidden" id ="mode" value = "${mode}"/>
	<input type="hidden" id ="selCategoryID" value = ""/>
	<input type="hidden" id="_ParentID" value= ""/>
	<input type="hidden" id ="hidCategoryName" value = ""/>
</form>
<%
	String DNID = request.getParameter("DN_ID");
	String mode = request.getParameter("mode");
	String pType = request.getParameter("pType");
	String CategoryName = request.getParameter("CategoryName");
	String CategoryID = request.getParameter("CategoryID");
%>

<script  type="text/javascript">
var dnID = "<%=DNID%>";
var CategoryName = "<%=CategoryName%>";
var pType = '<%=pType%>';
var CategoryID = "<%=CategoryID%>";

//정규표현식(다국어 특수문자 처리).
var regExp = /\;|\"|'|\&quot|\&apos/g;

$(document).ready(function(){
	eventInit();
});

function eventInit(){
	if($("#mode").val() == "E"){
		selectProperty();
	}else{
		if (pType == "Root"){
			$("#parentSearch").closest("tr").find("font").hide();
			$("#txtParentName").val('');
		} else {
			$("#_ParentID").val(CategoryID);
			$("#txtParentName").val(CategoryName);
		}
		
		eventSetting();
	}
}

function selectProperty(){
	$.ajax({
		type:"POST",
		data:{
			"DN_ID" : dnID,
			"CategoryID" : CategoryID,
			"pType" : pType,
		},
		async : false,
		url:"/groupware/manage/community/selectProperty.do",
		success:function (data) {
			
			if(data.list.length > 0){
				$(data.list).each(function(i,v){
					$("#communityUseYnSelBox").val(v.IsUse);
					$("#txtCategoryName").val(CFN_GetDicInfo(v.MultiDisplayName));
					$("#txtSortKey").val(v.SortKey);
					$("#txtAlias").val(v.FolderAlias);
					$("#txtDescription").val(v.Description);
					
					$("#communityDomainSelBox").attr("disabled",true);

					$("#txtParentName").attr("disabled",true);
					
					if(pType != "Folder"){
						$("#txtParentName").val('');
						$("#parentSearch").hide();
					}else{
						$("#txtParentName").val(v.parentDisplayName);
						$("#_ParentID").val(v.MemberOf);
						$("#parentSearch").show();
					}
					
					$("#selCategoryID").val(v.CategoryID);
					$("#hidCategoryName").val(v.MultiDisplayName);
    			});
			}
		},
		error:function (error){
			  CFN_ErrorAjax("/groupware/manage/community/selectProperty.do", response, status, error);
		}
	});
}

function editProperty(){
	if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

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
				DN_ID : dnID,
				FolderType : ($("#_ParentID").val() == '') ? 'Root' : 'Folder',
				txtMultiDisplayName : $("#hidCategoryName").val(),
				DIC_Code : $("#txtCategoryName").val()
			},
			async : false,
			url:"/groupware/manage/community/updateCommunityProperty.do",
			success:function (data) {
				if(data.status == "SUCCESS"){
					Common.Inform("<spring:message code='Cache.msg_136'/>");
					if(opener){
						opener.confCommunity.setCommunityGrid();
					}else{
						parent.confCommunity.setCommunityGrid();
					}
					Common.Close();
				}else{ 
					if(data.errorType == "Root"){
						Common.Warning("<spring:message code='Cache.msg_notRootPriority'/>"); //최상위 분류는 하나만 존재할 수 있습니다.
					}else if(data.errorType == "Sort"){
						Common.Warning("<spring:message code='Cache.msg_notSamePriority'/>"); //동일한 우선순위 값을 가질 수 없습니다.
					}else if(data.errorType == "NotUpdateCommunityProperty"){
						Common.Warning("<spring:message code='Cache.msg_NotUpdateCommunityProperty'/>"); //분류 속성이 변경되지 않았습니다.
					}else if(data.errorType == "NotUpdateCommunitySortProperty"){
						Common.Warning("<spring:message code='Cache.msg_NotUpdateCommunitySortProperty'/>"); //분류의 우선순위가 변경되지 않았습니다.
					}else if(data.errorType == "NotUpdateCommunitySubProperty"){
						Common.Warning("<spring:message code='Cache.msg_NotUpdateCommunitySubProperty'/>"); //하위분류의 우선순위가 변경되지 않았습니다.
					}else if(data.errorType == "NotUpdateCommunityDictionary"){
						Common.Warning("<spring:message code='Cache.msg_NotUpdateCommunityDictionary'/>"); //분류의 다국어정보가 변경되지 않았습니다.
					}else if(data.errorType == "NotUpdateCommunityIsUse"){
						Common.Warning("<spring:message code='Cache.msg_NotUpdateCommunityIsUse'/>"); //상위분류가 미사용중입니다. 사용으로 설정할수 없습니다.
					}else if(data.errorType == "NotCreateCommunityProperty"){
						Common.Warning("<spring:message code='Cache.msg_NotCreateCommunityProperty'/>"); //분류 속성이 저장되지 않았습니다.
					}else if(data.errorType == "NotCreateCommunityDictionary"){
						Common.Warning("<spring:message code='Cache.msg_NotCreateCommunityDictionary'/>"); //분류의 다국어정보가 저장되지 않았습니다.
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
	
	// 특수기호 체크.
	if (!symbolCheck($("#txtCategoryName").val())) {
		return check;
	}
	
	check = true;
	return check;
}

//다국어의 특수기호 체크
function symbolCheck(param) {
	if ( regExp.test(param) ) { 	// 정규표현식으로 특수문자 검색.
		var sMessage = String.format("<spring:message code='Cache.msg_DictionaryInfo_01' />", "&apos; &quot; ;") ; // 특수문자 [' " ;]는 사용할 수 없습니다.
		Common.Warning(sMessage, 'Warning Dialog', function () {});
		return false;	
	} else {
		return true;
	}
}

//특수기호 변경처리.
function symbolChange(strParam) {
	strParam = strParam.replaceAll(regExp,"");
	return strParam
}

function parentNameSearch(){
	var url = "";
	url += "/groupware/manage/community/selectParentSearch.do?DN_ID="+dnID+"&CategoryID="+CategoryID;
	CFN_OpenWindow(url,"<spring:message code='Cache.lbl_MultiLangSet'/>",300,410,"fix");
}

function eventSetting(){
	$("#txtParentName").attr("disabled",true);
	$("#communityDomainSelBox").val(dnID).attr("disabled",true);
}

// 다국어 콜백함수.
function addDicCallback(data){
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

	$("#hidCategoryName").val(multiLangName);
	$("#txtCategoryName").val(symbolChange(data.KoFull));
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