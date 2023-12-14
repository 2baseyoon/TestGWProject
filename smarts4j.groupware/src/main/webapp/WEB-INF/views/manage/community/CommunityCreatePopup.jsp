<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@taglib uri="/WEB-INF/tlds/covi.tld" prefix="covi" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<%
	String DNID = request.getParameter("DN_ID");
%>
<form>
	<div class="sadmin_pop" >
	    <table class="sadmin_table" >       
	    	<colgroup>
				<col width="120px"></col>
				<col width="180"></col>
				<col width="130px"></col>
				<col></col>
	    	</colgroup>       
	        <tbody>
	        	<tr>
	                <th><spring:message code="Cache.lbl_CommunityClass"/> <font color="red">*</font></th>
	                <td colspan="3">
	                	<input type="text"  id="txtCategoryName"  style="width: 71%;"/>                   
                		<a  onclick="btnCategoryParenOnClick();" class="btnTypeDefault" id="parentSearch"><spring:message code='Cache.lbl_Browse'/></a> 	<!-- 찾아보기 -->
	                </td>
	           	</tr>
	           	<tr>
	           		<th><spring:message code="Cache.lbl_communityName"/> <font color="red">*</font></th>
	                <td colspan="3">
						
						<input type="text" id="txtCommunityName" kind="dictionary" dic_src="hidCommuMultiName" dic_callback="addSubDicCallback" style="width: calc(100% - 185px);" />
						<a onclick="CheckCommunityName()" class="btnTypeDefault" ><spring:message code='Cache.lbl_apv_DuplicateCheck'/></a> 	<!-- 중복체크 -->
						<a href="#" kind="dictionaryBtn" src_elem="txtCommunityName" class="btnTypeDefault" style="float: right;"><spring:message code='Cache.lbl_MultilanguageSettings'/></a> <!-- 다국어 설정 -->
	                </td>
	           	</tr>
	           	<tr>
	           		<th><spring:message code="Cache.lbl_CommunityID"/> <font color="red">*</font></th>
	                <td>
	                	<span id="Alias"></span>
	                </td>
	                <th><spring:message code="Cache.lbl_DefaultMemberLevel"/> <font color="red">*</font> </th>
	                <td>
	                	<select id="ddlMemberLevel" name="ddlMemberLevel" class="selectType02">
						</select> 	  
	                </td>
	           	</tr>
	           	<tr>
	           		<th><spring:message code="Cache.lbl_Operator"/> <font color="red">*</font> </th>
	                <td>
	                	<input type="text"  id="txtOperator"  style="width: 59%;"/> 
	                	<a onclick="selectOperator()" class="btnTypeDefault" ><spring:message code="Cache.btn_Select"/></a>
	                </td>
	                <th><spring:message code="Cache.lbl_CommunityType"/> <font color="red">*</font></th>
	                <td>
	                	<select id="ddlType" name="ddlType" class="selectType02">
						</select> 	  
	                </td>
	           	</tr>
	           	<tr>
	           		<th><spring:message code="Cache.lbl_JoiningMethod"/> <font color="red">*</font></th>
	                <td>
	                	<select id="ddlJoinMothod" name="ddlJoinMothod" class="selectType02">
						</select> 	 
	                </td>
	                <th><spring:message code="Cache.lbl_CommuntyBoardType"/> <font color="red">*</font></th>
	                <td>
	                	<select id="ddlDefaultBoardType" name=ddlDefaultBoardType class="selectType02">
						</select> 	  
	                </td>
	           	</tr>
	           	<tr>
	           		<th><spring:message code='Cache.lbl_keyword'/></th>
	                <td colspan="3">
	                	<input type="text"  id="txtKeyword"  /> 
	                </td>
	           	</tr>
	           	<tr>
	           		<th><spring:message code="Cache.lbl_SingleLineIntroduction"/></th>
	                <td colspan="3">
	                	<input type="text"  id="textLineIntroduction" /> 
	                </td>
	           	</tr>
	             <tr>
	                <th><spring:message code="Cache.lbl_Stipulation"/></th>
	                <td colspan="3">
	                	<textarea id="txtStipulation" rows="4" class="W100" id="layoutHTML"></textarea>                         
	                </td>
	            </tr>
	           	<tr>
	                <th><spring:message code="Cache.lbl_DetailIntroduction"/></th>
	                <td colspan="3">
	                	<textarea id="txtIntroduction" rows="4" class="W100"  id="layoutHTML"></textarea>                         
	                </td>
	            </tr>
	        </tbody>
	    </table>      
		<div class="bottomBtnWrap">
	   		<a onclick="editCommunity();" class="btnTypeDefault btnTypeBg"><spring:message code='Cache.btn_apv_save'/></a>
	     	<a onclick="Common.Close();"  class="btnTypeDefault" ><spring:message code='Cache.btn_apv_close'/></a>                    
	    </div>           
	</div>
	<input type="hidden" id="_ParentID" value= ""/>
	<input type="hidden" id="oldCommunity" value= ""/>
	<input type="hidden" id="oldCommunityCount" value= "0"/>
	<input type="hidden" id="oldAlias" value= ""/>
	<input type="hidden" id="oldAliasCount" value= "0"/>
	<input type="hidden" id="operatorCode" value= ""/>
	
	<input type="hidden" id ="hidCommuMultiName" value = ""/>
	
</form>
<script  type="text/javascript">
var dnID = <%=DNID%>;

//정규표현식(다국어 특수문자 처리).
var regExp = /\;|\"|'|\&quot|\&apos/g;

$(document).ready(function(){	
	eventInit();
});

var lang = Common.getSession("lang");

function eventInit(){
	selBoxBind();
	$("#txtCategoryName,#txtOperator").attr("disabled",true);
	setAlias();
}

function selBoxBind(){
	var lang = Common.getSession("lang");
	coviCtrl.renderAXSelect('CuMemberLevel', 'ddlMemberLevel', lang, '', '','','',true);
	coviCtrl.renderAXSelect('CommunityType', 'ddlType', lang, '', '','','',true);
	coviCtrl.renderAXSelect('CommunityJoin', 'ddlJoinMothod', lang, '', '','','',true);
	coviCtrl.renderAXSelect('CommunityDefaultBoardType', 'ddlDefaultBoardType', lang, '', '','','',true);
}

function btnCategoryParenOnClick(){
	var url = "";
	url += "/groupware/manage/community/selectParentSearch.do?DN_ID="+dnID+"&target=C";
	
	CFN_OpenWindow(url,"<spring:message code='Cache.lbl_highDiv'/>",300,410,"");
}

// 다국어 콜백함수.
function addSubDicCallback(data){
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
	
	$("#hidCommuMultiName").val(multiLangName);
	$("#txtCommunityName").val(symbolChange(data.KoFull));
}

// 중복체크.
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
	
	// 다국어 특수기호 체크.
	if (!symbolCheck($("#txtCommunityName").val())) {
		return false;
	}
	
	$.ajax({
		type:"POST",
		data:{
			DN_ID : dnID,
			DisplayName : communityName
		},
		async : false,
		url:"/groupware/manage/community/checkCommunityName.do",
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
		     CFN_ErrorAjax("/groupware/manage/community/checkCommunityName.do", response, status, error);
		}
	});
	
}

function selectOperator(){
	var option = {
			callBackFunc : 'depUser_CallBack',
	};
	coviCmn.openOrgChartPopup("<spring:message code='Cache.lbl_DeptOrgMap'/>", "A1", option);
}

function editCommunity(){
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

	if($("#oldCommunity").val() != $("#txtCommunityName").val()){
		Common.Warning("<spring:message code='Cache.msg_DuplicateCheckCuName'/>");
		return ;
	}

	if($("#operatorCode").val() == ""){
		Common.Warning("<spring:message code='Cache.msg_checkOperator'/>");
		return ;
	}
	
	// 커뮤니티 이름의 특수기호 체크.
	if (!symbolCheck($("#txtCommunityName").val())) {
		return;
	}
	
	parent.Common.Progress(Common.getDic('msg_Processing'));
	
	$.ajax({
		type:"POST",
		data:{
			DN_ID : dnID,
			mode : "C",
			txtCategoryName : $("#txtCategoryName").val(),
			txtCommunityName : $("#txtCommunityName").val(),
			ddlMemberLevel : $("#ddlMemberLevel").val(),
			txtOperator : $("#operatorCode").val(),
			ddlType : $("#ddlType").val(),
			ddlJoinMothod : $("#ddlJoinMothod").val(),
			ddlDefaultBoardType : $("#ddlDefaultBoardType").val(),
			txtKeyword : $("#txtKeyword").val(),
			textLineIntroduction : $("#textLineIntroduction").val(),
			txtIntroduction : $("#txtIntroduction").val(),
			txtStipulation : $("#txtStipulation").val(),
			DIC_Code : $("#txtCategoryName").val(),
			_ParentID : $("#_ParentID").val(),
			txtMultiDisplayName : $("#hidCommuMultiName").val()
		},
		async : false,
		url:"/groupware/manage/community/editCommunityInfomation.do",
		success:function (data) {
			if(data.status == "SUCCESS"){
				Common.Inform("<spring:message code='Cache.msg_37'/>", "Information", function(){
					parent.confCommunity.selectCommunityList();
					Common.Close();
				});
			}else{ 
				Common.Warning("<spring:message code='Cache.msg_FailProcess'/>");
			} 
		},
		error:function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("/groupware/manage/community/editCommunityInfomation.do", response, status, error);
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
		url:"/groupware/manage/community/selectCommunityAlias.do",
		success:function (data) {
			$("#Alias").html(data.alias);
		},
		error:function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("/groupware/manage/community/selectCommunityAlias.do", response, status, error);
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


// 다국어 특수기호 체크
function symbolCheck(param) {
	if ( regExp.test(param) ) { 	// 정규표현식으로 특수문자 검색.
		var sMessage = String.format("<spring:message code='Cache.msg_DictionaryInfo_01' />", "&apos; &quot; ;") ; // 특수문자 [' " ;]는 사용할 수 없습니다.
		Common.Warning(sMessage, 'Warning Dialog', function () {});
		return false;	
	} else {
		return true;
	}
}

// 특수기호 변경처리.
function symbolChange(strParam) {
	strParam = strParam.replaceAll(regExp,"");
	return strParam
}


</script>