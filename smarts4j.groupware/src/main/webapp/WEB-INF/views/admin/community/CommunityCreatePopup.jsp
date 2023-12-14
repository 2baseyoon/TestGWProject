<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>
<%
	String DNID = request.getParameter("DN_ID");
	String mode = request.getParameter("mode");
	String path = request.getParameter("CategoryID");
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
	                <th><spring:message code="Cache.lbl_CommunityClass"/> <font color="red">*</font></th>
	                <td colspan="3">
	                	<input type="text" class="AXInput" id="txtCategoryName"  style="width: 71%;"/>                   
                		<input type="button" value="<spring:message code="Cache.lbl_Browse"/>" onclick="btnCategoryParenOnClick();" class="AXButton" id="parentSearch"/>
	                </td>
	           	</tr>
	           	<tr>
	           		<th><spring:message code="Cache.lbl_communityName"/> <font color="red">*</font></th>
	                <td colspan="3">
	                	<input type="text" class="AXInput" id="txtCommunityName"  style="width: 54%;"/> 
	                	<input type="button" value="<spring:message code="Cache.lbl_apv_DuplicateCheck"/>" onclick="CheckCommunityName()" class="AXButton" />                  
	                	<input type="button" value="<spring:message code="Cache.lbl_MultilanguageSettings"/>" onclick="btnDictionaryInfoOnClick()" class="AXButton" />
	                </td>
	           	</tr>
	           	<tr>
	           		<th><spring:message code="Cache.lbl_CommunityID"/> <font color="red">*</font></th>
	                <td>
	                	<span id="Alias"></span>
	                	<!-- <input type="text" class="AXInput" id="txtCommunityAlias"  style="width: 59%;"/>  -->
	                	<%-- <input type="button" value="<spring:message code="Cache.lbl_apv_DuplicateCheck"/>" onclick="CheckCommunityCode()" class="AXButton" />       --%>            
	                </td>
	                <th><spring:message code="Cache.lbl_DefaultMemberLevel"/> <font color="red">*</font> </th>
	                <td>
	                	<select id="ddlMemberLevel" name="ddlMemberLevel" class="AXSelect W100">
						</select> 	  
	                </td>
	           	</tr>
	           	<tr>
	           		<th><spring:message code="Cache.lbl_Operator"/> <font color="red">*</font> </th>
	                <td>
	                	<input type="text" class="AXInput" id="txtOperator"  style="width: 59%;"/> 
	                	<input type="button" value="<spring:message code="Cache.btn_Select"/>" onclick="selectOperator()" class="AXButton" />                  
	                </td>
	                <th><spring:message code="Cache.lbl_CommunityType"/> <font color="red">*</font></th>
	                <td>
	                	<select id="ddlType" name="ddlType" class="AXSelect W100">
						</select> 	  
	                </td>
	           	</tr>
	           	<tr>
	           		<th><spring:message code="Cache.lbl_JoiningMethod"/> <font color="red">*</font></th>
	                <td>
	                	<select id="ddlJoinMothod" name="ddlJoinMothod" class="AXSelect W100">
						</select> 	 
	                </td>
	                <th><spring:message code="Cache.lbl_CommuntyBoardType"/> <font color="red">*</font></th>
	                <td>
	                	<select id="ddlDefaultBoardType" name=ddlDefaultBoardType class="AXSelect W100">
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
	           		<th><spring:message code="Cache.lbl_SingleLineIntroduction"/></th>
	                <td colspan="3">
	                	<input type="text" class="AXInput" id="textLineIntroduction" style="width: 95%;" /> 
	                </td>
	           	</tr>
	           	<tr>
	                <th><spring:message code="Cache.lbl_Introduction_Writing"/></th>
	                <td colspan="3">
	                	<textarea id="txtIntroduction" rows="4" style="width: 95%; margin: 0px;  resize:vertical; font-family: 'Nanum Gothic','맑은고딕'; " id="layoutHTML" class="AXTextarea"></textarea>                         
	                </td>
	            </tr>
	            <tr>
	                <th><spring:message code="Cache.lbl_Summary_View"/></th>
	                <td colspan="3">
	                	<textarea id="txtSummary" rows="2" style="width: 95%; margin: 0px;  resize:vertical; font-family: 'Nanum Gothic','맑은고딕'; " id="layoutHTML" class="AXTextarea"></textarea>                         
	                </td>
	            </tr>
	             <tr>
	                <th><spring:message code="Cache.lbl_Stipulation"/></th>
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
	<input type="hidden" id="oldCommunityCount" value= "0"/>
	<input type="hidden" id="oldAlias" value= ""/>
	<input type="hidden" id="oldAliasCount" value= "0"/>
	<input type="hidden" id="operatorCode" value= ""/>
	
	<input type="hidden" id ="hiddenCategory" value = ""/>
	<input type="hidden" id ="DIC_Code_ko" value = ""/>
	<input type="hidden" id ="DIC_Code_en" value = ""/>
	<input type="hidden" id ="DIC_Code_ja" value = ""/>
	<input type="hidden" id ="DIC_Code_zh" value = ""/>
	
</form>
<script  type="text/javascript">
var dnID = <%=DNID%>;

var CategoryID ="";
CategoryID = '<%=path%>';
$(document).ready(function(){	
	eventInit();
});

var lang = Common.getSession("lang");

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
	
	setAlias();
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
	url += "/groupware/community/selectParentSearch.do?"+"DN_ID="+dnID+"&CategoryID="+CategoryID+"&target=C";
	
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
				Common.Inform("<spring:message code='Cache.msg_canusedCuId'/>");
				$("#oldAlias").val($("#txtCommunityAlias").val());
				$("#oldAliasCount").val("1");
			}else{ 
				Common.Warning("<spring:message code='Cache.msg_duplyCommunityID'/>");
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

function selectOperator(){
	if(opener){
		CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=depUser_CallBack&type=A1","<spring:message code='Cache.lbl_DeptOrgMap'/>","540px","580px","");
	}else{
		parent.goDepUser();
	}
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
		Common.Warning("<spring:message code='Cache.msg_communityClassification'/>");
		return ;
	}
	
	if($("#txtCommunityName").val() == ""){
		Common.Warning("<spring:message code='Cache.msg_inputCommunityName'/>");
		return ;
	}
	
	if($("#oldCommunityCount").val() == "0"){
		Common.Warning("<spring:message code='Cache.msg_DuplicateCheckCuName'/>");
		return ;
	}
	
/* 	if($("#oldAliasCount").val() == "0"){
		alert("<spring:message code='Cache.msg_DuplicateCheckCuId'/>");
		return ;
	}
	 */
	if($("#oldCommunity").val() != $("#txtCommunityName").val()){
		Common.Warning("<spring:message code='Cache.msg_DuplicateCheckCuName'/>");
		return ;
	}
	/* if($("#oldAlias").val() != $("#txtCommunityAlias").val()){
		alert("<spring:message code='Cache.msg_DuplicateCheckCuId'/>");
		return ;
	} */
	
	if($("#operatorCode").val() == ""){
		Common.Warning("<spring:message code='Cache.msg_checkOperator'/>");
		return ;
	}
	
	if(DIC_Code_ko == null || DIC_Code_ko == ""){
		DIC_Code_ko = $("#txtCommunityName").val();
	}
	
	$.ajax({
		type:"POST",
		data:{
			DN_ID : dnID,
			mode : $("#mode").val(),
			txtCategoryName : $("#txtCategoryName").val(),
			txtCommunityName : $("#txtCommunityName").val(),
		/* 	txtCommunityAlias : $("#txtCommunityAlias").val(), */
			ddlMemberLevel : $("#ddlMemberLevel").val(),
			txtOperator : $("#operatorCode").val(),
			ddlType : $("#ddlType").val(),
			ddlJoinMothod : $("#ddlJoinMothod").val(),
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
			_ParentID : $("#_ParentID").val()
		},
		async : false,
		url:"/groupware/layout/community/editCommunityInfomation.do",
		success:function (data) {
			if(data.status == "SUCCESS"){
				Common.Inform("<spring:message code='Cache.msg_37'/>", "Information", function(){
					if(opener){
						opener.gridSubRefresh();
					}else{
						parent.gridSubRefresh();
					}
					
					Common.Close();
				});
			}else{ 
				Common.Warning("<spring:message code='Cache.msg_FailProcess'/>");
			} 
		},
		error:function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("/groupware/layout/community/editCommunityInfomation.do", response, status, error);
		}
	});
}

function setAlias(){
	$.ajax({
		type:"POST",
		data:{
			DN_ID : dnID
		},
		async : false,
		url:"/groupware/layout/community/selectCommunityAlias.do",
		success:function (data) {
			$("#Alias").html(data.alias);
		},
		error:function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("/groupware/layout/community/checkCommunityAlias.do", response, status, error);
		}
	});
}

var aStrDictionary = Common.getDicAll(["lbl_ACL_Allow","lbl_ACL_Denial","lbl_User","lbl_company","lbl_group"]);
 
function depUser_CallBack(orgData){
	var readAuthJSON =  $.parseJSON(orgData);
	var sCode = "";
	var sDisplayName = "";
	var sObjectType_A = "";
	var sHTML = "";
	var step = $("[name=readAuth]").length;
	var sObjectType = "";
	$(readAuthJSON.item).each(function (i, item) {
		sObjectType = item.itemType
  		if(sObjectType.toUpperCase() == "USER"){ //사용자
  			sObjectTypeText = aStrDictionary["lbl_User"]; // 사용자
  			sObjectType_A = "UR";
  			sCode = item.AN;//UR_Code
  			sDisplayName  = CFN_GetDicInfo(item.DN, lang);
  			sDNCode = item.ETID;; //DN_Code
  		}else{ //그룹
	  			switch(item.GroupType.toUpperCase()){
	 			 case "COMPANY":
	                sObjectTypeText = aStrDictionary["lbl_company"]; // 회사
	                sObjectType_A = "CM";
	                break;
	            case "JOBLEVEL":
	                //sObjectTypeText = "직급";
	                //sObjectType_A = "JL";
	                //break;
	            case "JOBPOSITION":
	                //sObjectTypeText = "직위";
	                //sObjectType_A = "JP";
	                //break;
	            case "JOBTITLE":
	                //sObjectTypeText = "직책";
	                //sObjectType_A = "JT";
	                //break;
	            case "MANAGE":
	                //sObjectTypeText = "관리";
	                //sObjectType_A = "MN";
	                //break;
	            case "OFFICER":
	                //sObjectTypeText = "임원";
	                //sObjectType_A = "OF";
	                //break;
	            case "DEPT":
	                sObjectTypeText = aStrDictionary["lbl_group"]; // 그룹
	                //sObjectTypeText = "부서";
	                sObjectType_A = "GR";
	                break;
	    	}
	
	  		sCode = item.AN;
			sDisplayName = CFN_GetDicInfo(item.DN, lang);
			sDNCode = item.ETID;
	  		
  		}
	});
	$("#txtOperator").val(sDisplayName);
	$("#operatorCode").val(sCode);
	
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