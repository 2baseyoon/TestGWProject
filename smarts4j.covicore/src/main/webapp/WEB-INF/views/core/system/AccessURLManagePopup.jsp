<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>

<form id="accessURLForm" name="accessURLForm">
	<div>
		<table class="AXFormTable">
			<tr>
				<th style="width: 110px;"><font color="red">* </font>URL</th>
				<td>
					<input type="text" id="url" name="url" style="width:90%;height:25px;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
				</td>
			</tr>
			<tr>
				<th style="width: 110px;"><font color="red">* </font><spring:message code="Cache.lbl_selUse"/></th><!-- 사용유무  -->
				<td>
					 <select id="selectIsUse">
						<option value="Y" selected="selected">Y</option>
						<option value="N">N</option>
					</select>
				</td>
			</tr>
			<tr>
				<th style="width: 110px;"><font color="red">* </font><spring:message code="Cache.lbl_Anonymity"/></th><!-- 익명  -->
				<td>
					 <select id="selectIsAdmin">
						<option value="Y" selected="selected">Y</option>
						<option value="N">N</option>
					</select>
				</td>
			</tr>
			<tr style="height: 100px">
				<th><spring:message code="Cache.lbl_Description"/></th> <!-- 설명 -->
				<td>
					<textarea rows="5" style="width: 90%" id="description" name="<spring:message code="Cache.lbl_Description"/>" class="AXTextarea av-required HtmlCheckXSS ScriptCheckXSS"></textarea>
				</td>
			</tr>
		</table>
		<div align="center" style="padding-top: 10px">
			<input type="button" id="btn_create" value="<spring:message code="Cache.btn_Add"/>" onclick="addAccessURL();" class="AXButton red" />
			<input type="button" id="btn_modify" value="<spring:message code="Cache.btn_Edit"/>" onclick="modifyAccessURL();" style="display: none"  class="AXButton red" />
			<input type="button" value="<spring:message code="Cache.btn_Close"/>" onclick="closeLayer();"  class="AXButton" />
		</div>
	</div>
	<input type="hidden" id="SeqHiddenValue" value="" />
</form>
<script>

var mode = coviCmn.isNull(CFN_GetQueryString("mode"), "add");
var accessURLID = coviCmn.isNull(CFN_GetQueryString("accessURLID"), "0");

init();

function init(){		
	if(mode == "modify"){
		$("#btn_create").hide();
		$("#btn_modify").show();
		setAccessURLData();
	}else{
		$("#btn_create").show();
		$("#btn_modify").hide();
	}
}

//정보 조회
function setAccessURLData(){
	$.ajax({
		type:"POST",
		data:{
			"accessURLID" : accessURLID
		},
		url:"/covicore/accessurl/getInfo.do",
		success:function (data) {
			if(data.status =='SUCCESS'){
				$("#url").val(data.info.URL);
				$("#selectIsUse").val(data.info.IsUse);
				$("#selectIsAdmin").val(data.info.IsAdmin);
				$("#description").val(data.info.Description);
    			
    		}else{
    			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
    		}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/covicore/accessurl/getInfo.do", response, status, error);
		}
	});
	
}

//추가
function addAccessURL(){
	if(validationChk()){
		$.ajax({
			type:"POST",
			data:{
				"url" : $("#url").val(),
				"isUse" :  $("#selectIsUse").val(),
				"isAdmin" :  $("#selectIsAdmin").val(),
				"description" : $("#description").val()
			},
			url:"/covicore/accessurl/add.do",
			success:function (data) {
				if(data.status=='SUCCESS'){
		    		parent.Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){ /*저장되었습니다.*/
						parent.accessURLGrid.reloadList();	    			
		    			Common.Close();
		    		});
	    		}else{
	    			parent.Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
	    		}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/accessurl/add.do", response, status, error);
			}
		});
	}
}

//수정
function modifyAccessURL(){
	if(validationChk()){
		$.ajax({
			type:"POST",
			data:{
				"accessURLID" : accessURLID,
				"url" : $("#url").val(),
				"isUse" :  $("#selectIsUse").val(),
				"isAdmin" :  $("#selectIsAdmin").val(),
				"description" : $("#description").val()
			},
			url:"/covicore/accessurl/modify.do",
			success:function (data) {
				if(data.status=='SUCCESS'){
		    		parent.Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){ /*저장되었습니다.*/
						parent.accessURLGrid.reloadList();			
		    			Common.Close();
		    		});
	    		}else{
	    			parent.Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
	    		}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/accessurl/modify.do", response, status, error);
			}
		});
	}
	
}

//입력값 검증
function validationChk(){
	if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

	if($("#url").val() == ""){
		 parent.Common.Warning("<spring:message code='Cache.msg_enterURL'/>", "Warning Dialog", function () {     // URL을 입력하세요.
			 $("#url").focus();
        });
		 return false; 
	}
	
	return true;
}

//레이어 팝업 닫기
function closeLayer(){
	Common.Close();
}


</script>
