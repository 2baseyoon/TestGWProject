<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>
<%
	String DNID = request.getParameter("DN_ID");
	String mode = request.getParameter("mode");
	String path = request.getParameter("CU_ID");
%>
<form>
	<div class="pop_body1" style="width:100%;min-height: 100%">
	    <table class="AXFormTable" >       
	    	<colgroup>
				<col style="width: 110px ;"></col>
				<col style="width: 220px ;"></col>
				<col style="width: 125px ;"></col>
				<col></col>
	    	</colgroup>       
	        <tbody>
	        	<tr>
	                <th><spring:message code='Cache.lbl_CuCategory'/> <font color="red">*</font></th>
	                <td colspan="3">
	                	<input type="text" class="AXInput" id="txtCategoryName"  style="width: 71%;"/>                   
                		<input type="button" value="<spring:message code='Cache.lbl_Browse'/>" onclick="btnCategoryParenOnClick();" class="AXButton" id="parentSearch"/>
	                </td>
	           	</tr>
	           	<tr>
	           		<th><spring:message code='Cache.lbl_communityName'/> <font color="red">*</font></th>
	                <td colspan="3">
	                	<input type="text" class="AXInput" id="txtCommunityName"  style="width: 54%;"/> 
	                	<input type="button" value="<spring:message code='Cache.lbl_apv_DuplicateCheck'/>" onclick="CheckCommunityName()" class="AXButton" />                  
	                	<input type="button" value="<spring:message code='Cache.lbl_MultilanguageSettings'/>" onclick="btnDictionaryInfoOnClick()" class="AXButton" />
	                </td>
	           	</tr>
	           	<tr>
	           		<th><spring:message code='Cache.lbl_CommunityID'/></th>
	                <td>
	                	<span id="txtCommunityAlias"></span>
	                </td>
	                <th><spring:message code='Cache.lbl_CommunityRegStatus'/></th>
	                <td>
	                	<span id="txtCommunityState"></span>
	                </td>
	           	</tr>
	           	<tr>
	           		<th><spring:message code='Cache.lbl_Operator'/> <font color="red">*</font> </th>
	                <td>
	                	<span id="txtOperator"></span>
	                </td>
	                <th><spring:message code='Cache.lbl_CommunityType'/> <font color="red">*</font></th>
	                <td>
	                	<select id="ddlType" name="ddlType" class="AXSelect W100">
						</select> 	  
	                </td>
	           	</tr>
	           	<tr>
	           		<th><spring:message code='Cache.lbl_JoiningMethod'/> <font color="red">*</font></th>
	                <td>
	                	<select id="ddlJoinMothod" name="ddlJoinMothod" class="AXSelect W100">
						</select> 	 
	                </td>
	                <th><spring:message code='Cache.lbl_CommuntyBoardType'/> <font color="red">*</font></th>
	                <td>
	                	<select id="ddlDefaultBoardType" name=ddlDefaultBoardType class="AXSelect W100">
						</select> 	  
	                </td>
	           	</tr>
	           	<tr>
	           		<th><spring:message code='Cache.lbl_RankTitle'/> <font color="red">*</font></th>
	                <td>
	                	<input type="text" class="AXInput" id="txtGrade"  style="width: 95%;"/> 
	                </td>
	                <th><spring:message code='Cache.lbl_AllocatedCapacity'/> <font color="red">*</font></th>
	                <td>
	                	<input type="text" class="AXInput" id="txtLimitFileSize"  style="width: 82%;"/> 
	                </td>
	           	</tr>
	           	<tr>
	           		<th><spring:message code='Cache.lbl_DefaultMemberLevel'/> <font color="red">*</font> </th>
	                <td colspan="3">
	                	<select id="ddlMemberLevel" name="ddlMemberLevel" class="AXSelect W100">
						</select> 	  
	                </td>
	           	</tr>
	           	<tr>
	           		<th><spring:message code='Cache.lbl_keyword'/></th>
	                <td colspan="3">
	                	<input type="text" class="AXInput" id="txtKeyword" style="width: 95%;" /> 
	                </td>
	           	</tr>
	           	<tr>
	           		<th><spring:message code='Cache.lbl_SingleLineIntroduction'/></th>
	                <td colspan="3">
	                	<input type="text" class="AXInput" id="textLineIntroduction" style="width: 95%;" /> 
	                </td>
	           	</tr>
	           	<tr>
	                <th><spring:message code='Cache.lbl_Introduction_Writing'/></th>
	                <td colspan="3">
	                	<textarea id="txtIntroduction" rows="4" style="width: 95%; margin: 0px;  resize:vertical; font-family: 'Nanum Gothic','맑은고딕'; " id="layoutHTML" class="AXTextarea"></textarea>                         
	                </td>
	            </tr>
	            <tr>
	                <th><spring:message code='Cache.lbl_Summary_View'/></th>
	                <td colspan="3">
	                	<textarea id="txtSummary" rows="2" style="width: 95%; margin: 0px;  resize:vertical; font-family: 'Nanum Gothic','맑은고딕'; " id="layoutHTML" class="AXTextarea"></textarea>                         
	                </td>
	            </tr>
	             <tr>
	                <th><spring:message code='Cache.lbl_Stipulation'/></th>
	                <td colspan="3">
	                	<textarea id="txtStipulation" rows="4" style="width: 95%; margin: 0px;  resize:vertical; font-family: 'Nanum Gothic','맑은고딕'; " id="layoutHTML" class="AXTextarea"></textarea>                         
	                </td>
	            </tr>
	        </tbody>
	    </table>      
	    <div class="pop_btn2" align="center">
	     	<input type="button" value="<spring:message code='Cache.btn_apv_save'/>" onclick="editCommunity();" class="AXButton red" />
	     	<input type="button" value="<spring:message code='Cache.btn_apv_close'/>" onclick="Common.Close();"  class="AXButton" />                    
	    </div>           
	</div>
	<input type="hidden" id ="mode" value = "${mode}"/>
	<input type="hidden" id="_ParentID" value= ""/>
	<input type="hidden" id="oldCommunity" value= ""/>
	<input type="hidden" id="oldCommunityCount" value= "1"/>
	<input type="hidden" id="oldAlias" value= ""/>
	<input type="hidden" id="oldAliasCount" value= "1"/>
	<input type="hidden" id="operatorCode" value= ""/>
	
	<input type="hidden" id ="hiddenCategory" value = ""/>
	<input type="hidden" id ="DIC_Code_ko" value = ""/>
	<input type="hidden" id ="DIC_Code_en" value = ""/>
	<input type="hidden" id ="DIC_Code_ja" value = ""/>
	<input type="hidden" id ="DIC_Code_zh" value = ""/>
</form>
<script  type="text/javascript">
var dnID = <%=DNID%>;
var CU_ID ="";
CU_ID = '<%=path%>';
$(document).ready(function(){	
	eventInit();
	dataSetting();
});

function eventInit(){
	selBoxBind();
	$("#txtCategoryName,#txtOperator").attr("disabled",true);
	
	if(opener){
		document.getElementById("DIC_Code_ko").value = "";
		document.getElementById("DIC_Code_en").value = "";
		document.getElementById("DIC_Code_ja").value = "";
		document.getElementById("DIC_Code_zh").value = "";
		document.getElementById("hiddenCategory").value = ";;;;;;;;;;";
	}else{
		parent.document.getElementById("DIC_Code_ko").value = "";
		parent.document.getElementById("DIC_Code_en").value = "";
		parent.document.getElementById("DIC_Code_ja").value = "";
		parent.document.getElementById("DIC_Code_zh").value = "";
		parent.document.getElementById("hiddenCategory").value = ";;;;;;;;;;";
	}

}

function selBoxBind(){
	var lang = Common.getSession("lang");
	Common.getBaseCode("CuMemberLevel").CacheData.forEach(function(item){
		if (item.CodeGroup !== item.Code && item.Code !== "9") {
			var $option = $("<option/>", {"text": CFN_GetDicInfo(item.MultiCodeName, lang), "value": item.Code});
			$("#ddlMemberLevel").append($option);
		}
	});
	
	$("#ddlType").coviCtrl("setSelectOption", 
			"/groupware/layout/community/selectCommunityBaseCode.do", 
			{"CodeGroup": "CommunityType", "DomainID": dnID},
			"",
			""
	);
	
	$("#ddlJoinMothod").coviCtrl("setSelectOption", 
			"/groupware/layout/community/selectCommunityBaseCode.do", 
			{"CodeGroup": "CommunityJoin", "DomainID": dnID},
			"",
			""
	);
	
	$("#ddlDefaultBoardType").coviCtrl("setSelectOption", 
			"/groupware/layout/community/selectCommunityBaseCode.do", 
			{"CodeGroup": "CommunityDefaultBoardType", "DomainID": dnID},
			"",
			""
	);
	
}

function btnCategoryParenOnClick(){
	var url = "";
	url += "/groupware/community/selectParentSearch.do?"+"DN_ID="+dnID+"&target=C";
	
	if(opener){
		CFN_OpenWindow(url,"<spring:message code='Cache.lbl_highDiv'/>",300,280,"");
	}else{
		parent.Common.open("", "ParentSearchPopup", "<spring:message code='Cache.lbl_highDiv'/>", url, "300px", "280px", "iframe", true, null, null, true);
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
	
	Common.Close();
}

function CheckCommunityName(){
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
			DN_ID : dnID,
			DisplayName : communityName
		},
		async : false,
		url:"/groupware/layout/community/checkCommunityName.do",
		success:function (data) {
			if(data.status == "SUCCESS"){
				Common.Inform("<spring:message code='Cache.msg_canusedCuName'/>");
				$("#oldCommunity").val(communityName);
				$("#oldCommunityCount").val("1");
			}else{ 
				Common.Warning("<spring:message code='Cache.msg_duplyCommunityName'/>");
				$("#oldCommunity").val("");
				$("#oldCommunityCount").val("0");
			}			
		},
		error:function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("/groupware/layout/community/checkCommunityName.do", response, status, error);
		}
	});
	
}

function CheckCommunityCode(){
	$.ajax({
		type:"POST",
		data:{
			DN_ID : dnID,
			DisplayCode : $("#txtCommunityAlias").val()
		},
		async : false,
		url:"/groupware/layout/community/checkCommunityAlias.do",
		success:function (data) {
			if(data.status == "SUCCESS"){
				alert("<spring:message code='Cache.msg_canusedCuId'/>");
				$("#oldAlias").val($("#txtCommunityAlias").val());
				$("#oldAliasCount").val("1");
			}else{ 
				alert("<spring:message code='Cache.msg_duplyCommunityID'/>");
				$("#oldAlias").val("");
				$("#oldAliasCount").val("0");
			} 
		},
		error:function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("/groupware/layout/community/checkCommunityAlias.do", response, status, error);
		}
	});
}

function editCommunity(){
	var DIC_Code_ko = "";
	var DIC_Code_en = "";
	var DIC_Code_ja = "";
	var DIC_Code_zh = "";
	
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
	
	
	if($("#txtCategoryName").val().replace(/(\s*)/g, "") == ""){
		alert("<spring:message code='Cache.msg_communityClassification'/>");
		return ;
	}
	
	if($("#txtCommunityName").val() == ""){
		alert("<spring:message code='Cache.msg_inputCommunityName'/>");
		return ;
	}
	
	if($("#oldCommunityCount").val() == "0"){
		alert("<spring:message code='Cache.msg_DuplicateCheckCuName'/>");
		return ;
	}
	
	if($("#oldCommunity").val() != $("#txtCommunityName").val()){
		alert("<spring:message code='Cache.msg_DuplicateCheckCuName'/>");
		return ;
	}
	
	if(DIC_Code_ko == null || DIC_Code_ko == ""){
		DIC_Code_ko = $("#txtCommunityName").val();
	}
	
	$.ajax({
		type:"POST",
		data:{
			DN_ID : dnID,
			CU_ID : CU_ID,
			mode : $("#mode").val(),
			txtCategoryName : $("#txtCategoryName").val(),
			txtCommunityName : $("#txtCommunityName").val(),
			ddlMemberLevel : $("#ddlMemberLevel").val(),
			ddlType : $("#ddlType").val(),
			ddlJoinMothod : $("#ddlJoinMothod").val(),
			txtGrade : $("#txtGrade").val(),
			txtLimitFileSize : $("#txtLimitFileSize").val(),
			ddlDefaultBoardType : $("#ddlDefaultBoardType").val(),
			txtKeyword : $("#txtKeyword").val(),
			textLineIntroduction : $("#textLineIntroduction").val(),
			txtIntroduction : $("#txtIntroduction").val(),
			txtSummary : $("#txtSummary").val(),
			txtStipulation : $("#txtStipulation").val(),
			DIC_Code_ko : DIC_Code_ko,
			DIC_Code_en : DIC_Code_en,
			DIC_Code_ja : DIC_Code_ja,
			DIC_Code_zh : DIC_Code_zh,
			DIC_Code : $("#txtCategoryName").val(),
			_ParentID : $("#_ParentID").val(),
			operatorCode : $("#operatorCode").val()
		},
		async : false,
		url:"/groupware/layout/community/editCommunityInfomation.do",
		success:function (data) {
			if(data.status == "SUCCESS"){
				alert("<spring:message code='Cache.msg_Changed'/>");
				if(opener){
					opener.gridSubRefresh();
				}else{
					parent.gridSubRefresh();
				}
				
				Common.Close();
			}else{ 
				alert("<spring:message code='Cache.msg_FailProcess'/>");
			} 
		},
		error:function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("/groupware/layout/community/editCommunityInfomation.do", response, status, error);
		}
	});
}



function dataSetting(){
	$.ajax({
		type:"POST",
		data:{
			DN_ID : dnID,
			mode : $("#mode").val(),
			CU_ID : CU_ID
		},
		async : false,
		url:"/groupware/layout/community/selectCommunityInfomation.do",
		success:function (data) {
			if(data.list.length > 0){
				$(data.list).each(function(i,v){
					$("#txtCategoryName").val(v.CategoryName);
					$("#txtCommunityName").val(v.CommunityName);
					$("#txtCommunityAlias").text(v.CU_Code);
					$("#txtCommunityState").text(v.CuAppDetail);
					$("#txtOperator").text(v.DisplayName);
					$("#operatorCode").val(v.OperatorCode);
					
					$("#ddlType").val(v.CommunityType);
					$("#ddlJoinMothod").val(v.CommunityJoin);
					$("#ddlDefaultBoardType").val(v.DefaultBoardType);
					$("#txtGrade").val(v.Grade);
					$("#txtLimitFileSize").val(v.LimitFileSize);
					$("#ddlMemberLevel").val(v.DefaultMemberLevel);
					$("#txtKeyword").val(v.Keyword);
					$("#textLineIntroduction").val(v.SearchTitle);
					$("#txtIntroduction").val(v.Description);
					$("#txtSummary").val(v.SearchSummary);
					$("#txtStipulation").val(v.Provision);
					$("#_ParentID").val(v.CategoryID);
					
					$("#oldCommunity").val(v.CommunityName);
					
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
		error:function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("/groupware/layout/community/selectCommunityInfomation.do", response, status, error);
		}
	});
	
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