<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@taglib uri="/WEB-INF/tlds/covi.tld" prefix="covi" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<%
	String CU_ID = request.getParameter("CU_ID");
%>
<form>
	<div class="sadmin_pop" >
	    <table class="sadmin_table" >       
	    	<colgroup>
				<col width="120px"></col>
				<col width="*"></col>
				<col width="130px"></col>
				<col></col>
	    	</colgroup>       
	        <tbody>
	        	<tr>
	                <th><spring:message code='Cache.lbl_CuCategory'/> <font color="red">*</font></th>
	                <td colspan="3">
	                	<input type="text" id="txtCategoryName"  style="width: 71%;"/>                   
                		<a  onclick="btnCategoryParenOnClick();" class="btnTypeDefault" id="parentSearch"><spring:message code='Cache.lbl_Browse'/></a>
	                </td>
	           	</tr>
	           	<tr>
	           		<th><spring:message code='Cache.lbl_communityName'/> <font color="red">*</font></th> 	<!-- 커뮤니티 명 -->
	                <td colspan="3">
	                	<%-- 버튼(중복체크: 75px, 다국어설정: 90px 로 계산) --%>
	                	<input type="text" id="txtCommunityName" kind="dictionary" dic_src="hidCommuMultiName" dic_callback="multiLang_callback" style="width: calc(100% - 185px);" />
	                	&nbsp;
	                	<a onclick="CheckCommunityName()" class="btnTypeDefault" ><spring:message code='Cache.lbl_apv_DuplicateCheck'/></a> 	<!-- 중복체크 -->            
	                	&nbsp;
	                	<a href="#" kind="dictionaryBtn" src_elem="txtCommunityName" class="btnTypeDefault" style="float: right;"><spring:message code='Cache.lbl_MultilanguageSettings'/></a>
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
	                	<select id="ddlType" name="ddlType" class="selectType02">
						</select> 	  
	                </td>
	           	</tr>
	           	<tr>
	           		<th><spring:message code='Cache.lbl_JoiningMethod'/> <font color="red">*</font></th>
	                <td>
	                	<select id="ddlJoinMothod" name="ddlJoinMothod" class="selectType02">
						</select> 	 
	                </td>
	                <th><spring:message code='Cache.lbl_CommuntyBoardType'/> <font color="red">*</font></th>
	                <td>
	                	<select id="ddlDefaultBoardType" name=ddlDefaultBoardType class="selectType02">
						</select> 	  
	                </td>
	           	</tr>
	           	<tr>
	           		<th><spring:message code='Cache.lbl_RankTitle'/> <font color="red">*</font></th>
	                <td>
	                	<input type="text" id="txtGrade" class="right"/> 
	                </td>
	                <th><spring:message code='Cache.lbl_AllocatedCapacity'/> <font color="red">*</font></th>
	                <td>
	                	<input type="text" id="txtLimitFileSize" class="right"/> 
	                </td>
	           	</tr>
	           	<tr>
	           		<th><spring:message code='Cache.lbl_DefaultMemberLevel'/> <font color="red">*</font> </th>
	                <td colspan="3">
	                	<select id="ddlMemberLevel" name="ddlMemberLevel" class="selectType02">
						</select> 	  
	                </td>
	           	</tr>
	           	<tr>
	           		<th><spring:message code='Cache.lbl_keyword'/></th>
	                <td colspan="3">
	                	<input type="text" id="txtKeyword" /> 
	                </td>
	           	</tr>
	           	<tr>
	           		<th><spring:message code='Cache.lbl_SingleLineIntroduction'/></th>
	                <td colspan="3">
	                	<input type="text" id="textLineIntroduction" /> 
	                </td>
	           	</tr>
	             <tr>
	                <th><spring:message code='Cache.lbl_Stipulation'/></th>
	                <td colspan="3">
	                	<textarea id="txtStipulation" rows="4" class="W100"  id="layoutHTML"></textarea>                         
	                </td>
	            </tr>
	           	<tr>
	                <th><spring:message code='Cache.lbl_DetailIntroduction'/></th>
	                <td colspan="3">
	                	<textarea id="txtIntroduction" rows="4" class="W100" id="layoutHTML"></textarea>                         
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
	<input type="hidden" id="oldCommunityCount" value= "1"/>
	<input type="hidden" id="oldAlias" value= ""/>
	<input type="hidden" id="oldAliasCount" value= "1"/>
	<input type="hidden" id="operatorCode" value= ""/>
	<input type="hidden" id="hidCommuMultiName" value="" />
</form>
<script  type="text/javascript">

(function() {
	var dnID = "";
	var CU_ID = '<%=CU_ID%>';
	
	// 정규표현식(다국어 특수문자 처리).
	var regExp = /\;|\"|'|\&quot|\&apos/g;
	
	var eventInit = function() {
		selBoxBind();
		$("#txtCategoryName,#txtOperator").attr("disabled",true);
	}
	
	var selBoxBind = function() {
		var lang = Common.getSession("lang");
		coviCtrl.renderAXSelect('CuMemberLevel', 'ddlMemberLevel', lang, '', '','','',true);
		coviCtrl.renderAXSelect('CommunityType', 'ddlType', lang, '', '','','',true);
		coviCtrl.renderAXSelect('CommunityJoin', 'ddlJoinMothod', lang, '', '','','',true);
		coviCtrl.renderAXSelect('CommunityDefaultBoardType', 'ddlDefaultBoardType', lang, '', '','','',true);
	}
	
	var dataSetting = function() {
		$.ajax({
			type:"POST",
			data:{
				CU_ID : CU_ID
			},
			async : false,
			url:"/groupware/manage/community/selectCommunityInfomation.do",
			success:function (data) {
				
			
				if(data.list.length > 0){
					$(data.list).each(function(i,v){
						dnID =  v.DN_ID
						$("#txtCategoryName").val(v.CategoryName);
						$("#txtCommunityName").val(v.CommunityName);
						$("#txtCommunityAlias").text(v.CU_Code);
						$("#txtCommunityState").text(v.CuAppDetail);
						$("#txtOperator").text(v.DisplayName);
						$("#operatorCode").val(v.OperatorCode);
						$("#ddlType").bindSelectSetValue(v.CommunityType);
						$("#ddlJoinMothod").bindSelectSetValue(v.CommunityJoin);
						$("#ddlDefaultBoardType").bindSelectSetValue(v.DefaultBoardType);
						$("#txtGrade").val(v.Grade);
						$("#txtLimitFileSize").val(v.LimitFileSize);
						$("#ddlMemberLevel").bindSelectSetValue(v.DefaultMemberLevel);
						$("#txtKeyword").val(v.Keyword);
						$("#textLineIntroduction").val(v.SearchTitle);
						$("#txtIntroduction").val(v.Description);
						$("#txtStipulation").val(v.Provision);
						$("#_ParentID").val(v.CategoryID);
						$("#oldCommunity").val(v.CommunityName);
						$("#hidCommuMultiName").val(v.MultiDisplayName);
	    			});
				}
			},
			error:function(response, status, error){
			     CFN_ErrorAjax("/groupware/manage/community/selectCommunityInfomation.do", response, status, error);
			}
		});
		
	}
	
	// 커뮤니티 명칭의 특수기호 체크
	var symbolCheck = function(param) {
		if ( regExp.test(param) ) { 	// 정규표현식으로 특수문자 검색.
			var sMessage = String.format("<spring:message code='Cache.msg_DictionaryInfo_01' />", "&apos; &quot; ;") ; // 특수문자 [' " ;]는 사용할 수 없습니다.
			Common.Warning(sMessage, 'Warning Dialog', function () {});
			return false;	
		} else {
			return true;
		}
	}
	
	// 특수기호 변경처리.
	var symbolChange = function(strParam) {
		strParam = strParam.replaceAll(regExp,"");
		return strParam
	}
	// 다국어 콜백함수. 
	this.multiLang_callback = function(data) {
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
	
	// 찾아보기 버튼
	this.btnCategoryParenOnClick = function() {
		var url = "";
		url += "/groupware/manage/community/selectParentSearch.do?DN_ID="+dnID+"&target=C";
		CFN_OpenWindow(url,"<spring:message code='Cache.lbl_highDiv'/>",300,410,"");
	}
	
	// 찾아보기 팝업의 트리정보 저장.
	this.TreeData = function(id, name, target) {
		if(target == "P"){
			$("#txtParentName").val(name);
			$("#_ParentID").val(id);
		}else if(target == "C"){
			$("#txtCategoryName").val(name);
			$("#_ParentID").val(id);
		}
	}
	
	// 중복체크
	this.CheckCommunityName = function() {
		var communityName = $("#txtCommunityName").val();
		
		if (communityName == null || communityName == "") {
			Common.Warning("<spring:message code='Cache.msg_blankValue'/>", "warning", function(answer){ // 빈값을 입력할 수 없습니다.
				if(answer){
					$("#txtCommunityName").focus();
				}
			});
			
			return false;
		}
		
		// 특수기호 체크.
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
					Common.Inform("<spring:message code='Cache.msg_canusedCuName'/>"); 	// 사용 가능한 커뮤니티 이름입니다.
					$("#oldCommunity").val(communityName);
					$("#oldCommunityCount").val("1");
				}else{ 
					Common.Warning("<spring:message code='Cache.msg_duplyCommunityName'/>"); 	// 커뮤니티 이름이 중복되어 사용할 수 없습니다.
					$("#oldCommunity").val("");
					$("#oldCommunityCount").val("0");
				}			
			},
			error:function(response, status, error){
			     CFN_ErrorAjax("/groupware/manage/community/checkCommunityName.do", response, status, error);
			}
		});
	}

	// 저장
	this.editCommunity = function() {
		if($("#txtCategoryName").val().replace(/(\s*)/g, "") == ""){
			Common.Warning("<spring:message code='Cache.msg_communityClassification'/>"); 	// 커뮤니티 분류를 입력하세요.
			return ;
		}
		
		if($("#txtCommunityName").val() == ""){
			Common.Warning("<spring:message code='Cache.msg_inputCommunityName'/>"); 	// 커뮤니티 이름을 입력하세요.s
			return ;
		}
		
		if($("#oldCommunityCount").val() == "0"){
			Common.Warning("<spring:message code='Cache.msg_DuplicateCheckCuName'/>"); 	// 커뮤니티 이름 중복체크를 하십시오.
			return ;
		}
		
		if($("#oldCommunity").val() != $("#txtCommunityName").val()){
			Common.Warning("<spring:message code='Cache.msg_DuplicateCheckCuName'/>"); 	// 커뮤니티 이름 중복체크를 하십시오.
			return ;
		}
		
		if (!symbolCheck($("#txtCommunityName").val())) {
			return;
		}
		
		parent.Common.Progress(Common.getDic('msg_Processing'));
		
		$.ajax({
			type:"POST",
			data:{
				DN_ID : dnID,
				CU_ID : CU_ID,
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
				txtStipulation : $("#txtStipulation").val(),
				txtMultiDisplayName : $("#hidCommuMultiName").val(),
				DIC_Code : $("#txtCategoryName").val(),
				_ParentID : $("#_ParentID").val(),
				operatorCode : $("#operatorCode").val()
			},
			async : false,
			url:"/groupware/manage/community/editCommunityInfomation.do",
			success:function (data) {
				if(data.status == "SUCCESS"){
					parent.gridRefresh();
					Common.Warning("<spring:message code='Cache.msg_Changed'/>"); 	// 변경되었습니다
					Common.Close();
				}else{ 
					Common.Warning("<spring:message code='Cache.msg_FailProcess'/>"); 	// 처리에 실패했습니다
				} 
			},
			error:function(response, status, error){
			     CFN_ErrorAjax("/groupware/manage/community/editCommunityInfomation.do", response, status, error);
			}
		});
	}
	
	$(document).ready(function(){	
		eventInit();
		dataSetting();
	});
	
})();

</script>