<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>
<form id="form_TokenInfoPop" name="form_TokenInfoPop">
	<div>
		<input type="hidden" id="TokenID" name="TokenID" />
		<table class="AXFormTable">
			<tr>
				<th style="width: 130px;">Token</th>
				<td colspan="3">
					<input type="hidden" id="Token" name="Token" readonly style="width:95%;height:25px;" class=""/>
					<div id="TokenValue" style="word-wrap: break-word;"></div>
				</td>
			</tr>
			<tr>
				<th><font color="red"></font><spring:message code="Cache.lbl_IsUse"/></th>
				<td colspan="3">
					<select type="text" id="IsActive" name="IsActive" class="selectType04">
						<option value="Y"><spring:message code="Cache.lbl_UseY" /></option>
						<option value="N"><spring:message code="Cache.lbl_UseN" /></option>
					</select>
				</td>
			</tr>
			<tr style="height: 100px">
				<th><spring:message code="Cache.lbl_Description"/></th> <!-- 설명 -->
				<td colspan="3">
					<textarea rows="5" style="width: 95%;resize:none;" id="Descriptions" name="Descriptions" class="AXTextarea HtmlCheckXSS ScriptCheckXSS"></textarea>
				</td>
			</tr>
		</table>
		<div align="center" style="padding-top: 10px">
<%-- 			<input type="button" id="btn_create" value="<spring:message code="Cache.btn_Add"/>" onclick="addDatasource();" class="AXButton red" /> --%>
			<input type="button" id="btn_modify" value="<spring:message code="Cache.btn_Edit"/>" onclick="modifyToken();" style="display: none"  class="AXButton red" />
			<input type="button" value="<spring:message code="Cache.btn_Close"/>" onclick="closeLayer();"  class="AXButton" />
		</div>
	</div>
</form>
<script>

var TokenID = coviCmn.isNull(CFN_GetQueryString("TokenID"), "-1");

init();

function init(){
	$("#btn_create").hide();
	$("#btn_modify").show();
	setTokenData();
}

//정보 조회
function setTokenData(){
	var Token = "", Description = "", IsActive = "";
	var gridData = parent.tokenGrid.list;
	for(var i = 0; i < gridData.length; i++){
		if(gridData[i].TokenID == TokenID){
			Description = gridData[i].Descriptions;
			IsActive = gridData[i].IsActive;
			Token = gridData[i].Token;
			break;
		}
	}
	$("#TokenID").val(TokenID);
	$("#Token").val(Token);
	$("#TokenValue").html(Token);
	$("#Descriptions").val(Description);
	$("#IsActive").val(IsActive);
	
	
}

//수정
function modifyToken(){
	if(validationChk()){
		$.ajax({
			type:"POST",
			data:$("#form_TokenInfoPop").serialize(),
			url:"/covicore/api/config/updateToken.do",
			success:function (data) {
				if(data.status=='SUCCESS'){
		    		parent.Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){ /*저장되었습니다.*/
						parent.tokenGrid.reloadList();			
		    			Common.Close();
		    		});
	    		}else{
	    			parent.Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
	    		}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/api/config/updateToken.do", response, status, error);
			}
		});
	}
	
}

//입력값 검증
function validationChk(){
	if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

	var requiredInputs = $(".av-required");
	for(var i = 0; i < requiredInputs.length; i++){
		if(requiredInputs[i].value == ""){
			var txt = $(requiredInputs[i]).closest("td").prev("th").text();
			parent.Common.Warning("Field [" + txt + "] is required.", "Warning Dialog", function(){
				requiredInputs[i].focus();
			});
			return false; 
		}
	}
	return true;
}

//레이어 팝업 닫기
function closeLayer(){
	Common.Close();
}
</script>