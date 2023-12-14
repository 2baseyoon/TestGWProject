<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@taglib uri="/WEB-INF/tlds/covi.tld" prefix="covi" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<%
	String DNID = request.getParameter("DN_ID");
	String mode = request.getParameter("mode");
%>
<form>
	<div class="sadmin_pop" >
	    <table class="sadmin_table" >       
	    	<colgroup>
				<col style="width: 130px ;"></col>
				<col style="width: 210px ;"></col>
				<col style="width: 110px ;"></col>
				<col></col>
	    	</colgroup>       
	        <tbody>
	        	<tr>
	                <th><spring:message code="Cache.lbl_CommunityType"/><!-- 커뮤니티 유형 --> <font color="red">*</font></th>
	                <td>
	                	<select id="communityStatusSelBox" name="communityStatusSelBox" class="selectType02">
						</select> 	  
	                </td>
	                <th><spring:message code="Cache.lbl_FolderType"/><!-- 폴더유형 --> <font color="red">*</font></th>
	                <td>
	                	<select id="folderTypeSelBox" name="folderTypeSelBox" class="selectType02">
						</select> 	  
	                </td>
	           	</tr>
	           	<tr>
	             	<th><spring:message code="Cache.lbl_selUse"/><!-- 사용유무 --> <font color="red">*</font></th>
	                <td colspan=3>
	                	<select id="boardSettingUseSelBox" name="boardSettingUseSelBox" class="selectType02">
							<option value="Y"><spring:message code='Cache.lbl_USE_Y'/></option>
							<option value="N"><spring:message code='Cache.lbl_noUse'/></option>
						</select> 	                 
	                </td>
<%-- 	                <th><spring:message code="Cache.lbl_SortOrder"/><!-- 정렬순서 --></th> --%>
<!-- 	                <td > -->
<!-- 	                	<input type="text" class="HtmlCheckXSS ScriptCheckXSS" id="txtSortKey" style="width: 82%;"/>                    -->
<!-- 	                </td> -->
	           	</tr>
	           	<tr>
	                <th><spring:message code="Cache.lbl_BoardNm"/><!-- 게시판명 --> <font color="red">*</font></th>
	                <td colspan=3>
	                	<input type="text" id="txtBoardName" kind="dictionary" dic_src="hidBoardName" dic_callback="multiLang_callback" class="HtmlCheckXSS ScriptCheckXSS" style="width: 56%;"/>                   
                		<a href="#" kind="dictionaryBtn" src_elem="txtBoardName" class="AXButton" ><spring:message code='Cache.lbl_MultilanguageSettings'/></a>
	                </td>
	           	</tr>
	           	<tr>
	                <th><spring:message code="Cache.lbl_Description"/><!-- 설명 --></th>
	                <td colspan="3">
	                	<textarea id="txtDescription" rows="4" id="layoutHTML" class="HtmlCheckXSS ScriptCheckXSS w100"></textarea>                         
	                </td>
	            </tr>
	        </tbody>
	    </table>      
		<div class="bottomBtnWrap">
			<a onclick="editBoardSetting();" class="btnTypeDefault btnTypeBg" >
				<% if("E".equals(mode)){ %><spring:message code='Cache.btn_Edit'/><% } %>
				<% if("C".equals(mode)){ %><spring:message code='Cache.btn_apv_save'/><% } %>
			</a>
	     	<a onclick="Common.Close();"  class="btnTypeDefault" ><spring:message code='Cache.btn_apv_close'/></a>                    
	    </div>           
	</div>
	
	<input type="hidden" id ="mode" value = "${mode}"/>
	<input type="hidden" id ="menuID" value = "${MenuID}"/>
	<input type="hidden" id="hidBoardName" value="" />
	
</form>
<script  type="text/javascript">
var dnID = "<%=DNID%>";

//정규표현식(다국어 특수문자 처리).
var regExp = /\;|\"|'|\&quot|\&apos/g;

$(document).ready(function(){	
	eventInit();
	dataSetting();
});

function eventInit(){
	
	$("#communityStatusSelBox").coviCtrl("setSelectOption", 
 			"/groupware/layout/community/selectCommunityBaseCode.do", 
			{"CodeGroup": "CommunityDefaultBoardType"},
			Common.getDic('lbl_Select'),
			""
	);
	
    $("#folderTypeSelBox").coviCtrl("setSelectOption", 
			"/groupware/layout/community/selectCommunityFolderType.do", 
			{"BizSection": "Community"},
			Common.getDic('lbl_Select'),
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
			url:"/groupware/manage/community/communityBoardSettingInfo.do",
			success:function (data) {
				if(data.list.length > 0){
					$(data.list).each(function(i,v){
						$("#communityStatusSelBox").val(v.CommunityType);
						$("#folderTypeSelBox").val(v.FolderType);
						$("#boardSettingUseSelBox").val(v.IsUse);
						$("#txtBoardName").val(v.BoardName);
						$("#txtSortKey").val(v.SortKey);
						$("#txtDescription").val(v.Description);
						$("#hidBoardName").val(v.MultiDisplayName);
					});
				}
			},
			error:function(response, status, error){
			     //TODO 추가 오류 처리
			  	 CFN_ErrorAjax("/groupware/layout/community/communityBoardSettingInfo.do", response, status, error);
			}
		}); 
	} else {
		// mode = 'C'
		$("#txtBoardName").val("");
	}
}

function editBoardSetting(){
	if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
	
	if($("#communityStatusSelBox").val() == ""){
		Common.Warning("<spring:message code='Cache.msg_select_communityType'/>"); // 커뮤니티 유형을 선택하세요
		return;
	}
	
	if($("#folderTypeSelBox").val() == ""){
		Common.Warning("<spring:message code='Cache.msg_select_folderType'/>"); // 폴더 유형을 선택하세요
		return;
	}
	
	if($("#txtBoardName").val() == ""){
		Common.Warning("<spring:message code='Cache.msg_apv_016'/>"); //명칭을 입력하여 주십시오.
		return;
	}

	// 특수기호 체크.
	if (!symbolCheck($("#txtBoardName").val())) {
		return;
	}
	
	if($("#mode").val() == "E"){
		confirm = "<spring:message code='Cache.msg_RUEdit'/>"; //수정하시겠습니까?
	}else{
		confirm = "<spring:message code='Cache.msg_RURegist'/>"; //등록하시겠습니까?
	}
	
	Common.Confirm(confirm, "Confirmation Dialog", function (confirmResult) {
		 if (confirmResult) {
			var messageCode = ($("#mode").val() == 'E') ? "<spring:message code='Cache.msg_ChangeAlert'/>" : "<spring:message code='Cache.msg_insert'/>"
			$.ajax({
				type:"POST",
				data:{
						MenuID :$("#menuID").val(),
						mode : $("#mode").val(),
						DN_ID: dnID,
						CommunityType : $("#communityStatusSelBox").val(),
						FolderType : $("#folderTypeSelBox").val(),
						IsUse : $("#boardSettingUseSelBox").val(),
						DisplayName : $("#txtBoardName").val(),
						Description : $("#txtDescription").val(),
						exDisplayName : $("#hidBoardName").val()
				},
				url:"/groupware/manage/community/updateBoardSetting.do",
				success:function (data) {
					if(data.status == "SUCCESS"){
						Common.Inform(messageCode, "Information", function(){
							parent.confCommuBoard.selectCommunityList();
							Common.Close();
						});
					}else{ 
						Common.Error("<spring:message code='Cache.msg_Fail'/>");
					}				
				},
				error:function(response, status, error){
				     CFN_ErrorAjax("/groupware/manage/community/updateBoardSetting.do", response, status, error);
				}
			}); 
		 }
	});
}

// 커뮤니티 명칭의 특수기호 체크
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

//다국어 콜백 재정의 함수. 
function multiLang_callback(data) {
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
				
	$("#hidBoardName").val(multiLangName);
	$("#txtBoardName").val(symbolChange(data.KoFull));
}

</script>