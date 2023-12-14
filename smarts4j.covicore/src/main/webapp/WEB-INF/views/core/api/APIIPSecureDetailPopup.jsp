<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>
<form id="form_APIIPSecureInfoPop" name="form_APIIPSecureInfoPop">
	<div>
		<input type="hidden" id="SecID" name="SecID" />
		<input type="hidden" id="DomainID" name="DomainID" />
		<table class="AXFormTable">
			<tr style="height:36px;">
				<th style="width: 130px;">SecID</th>
				<td colspan="3">
					<div id="SecIDValue" style="word-wrap: break-word;"></div>
				</td>
			</tr>
			<tr>
				<th style="width: 130px;">IP<font color="red"> *</font></th>
				<td colspan="3">
					<input type="text" id="IP" name="IP" style="width:95%;height:25px;" />
				</td>
			</tr>
			<tr>
				<th><spring:message code="Cache.lbl_api_ipallowyn"/><font color="red"> *</font></th>
				<td colspan="3">
					<select type="text" id="ControlType" name="ControlType" class="selectType04 av-required">
						<option value="ACCEPT"><spring:message code="Cache.lbl_api_ipallowyn_y" /></option>
						<option value="REJECT"><spring:message code="Cache.lbl_api_ipallowyn_n" /></option>
					</select>
				</td>
			</tr>
			<tr>
				<th><spring:message code="Cache.lbl_IsUse"/><font color="red"> *</font></th>
				<td colspan="3">
					<select type="text" id="IsUse" name="IsUse" class="selectType04 av-required">
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
			<input type="button" value="<spring:message code="Cache.btn_save"/>" onclick="saveAPIIPSecure();" class="AXButton red" />
			<input type="button" value="<spring:message code="Cache.btn_Close"/>" onclick="closeLayer();"  class="AXButton" />
		</div>
	</div>
</form>
<script>

var DomainID = coviCmn.isNull(CFN_GetQueryString("DomainID"), "");
var SecID = coviCmn.isNull(CFN_GetQueryString("SecID"), "");
var mode = coviCmn.isNull(CFN_GetQueryString("mode"), "add");
var lang = Common.getSession("lang");

init();

function init(){
	if(mode == "modify") {
		$("input#Path").hide();
		//$("input#Path").removeClass("av-required");
		$("#PathValue").show();
	}else{
		$("#DomainID").val(DomainID);
		$("input#Path").show();
		//$("input#Path").addClass("av-required");
		$("#PathValue").hide();		
	}
	
	if(mode == "modify") {
		setIPSecureData();
	}
}

//정보 조회
function setIPSecureData(){
	$.ajax({
		type:"POST",
		url : "/covicore/api/config/getIPSecureDetail.do",
		data : { SecID : SecID },
		success : function(data){
			if(data.status=='SUCCESS'){
				var info = data.data;
				$("#SecID").val(SecID);
				$("#SecIDValue").html(SecID);
				$("#IP").val(info.IP);
				$("#ControlType").val(info.ControlType);
				$("#Descriptions").val(info.Descriptions);
				$("#IsUse").val(info.IsUse);
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/covicore/api/config/getIPSecureDetail.do", response, status, error);
		}
	});
}

//수정
function saveAPIIPSecure(){
	if(validationChk()){
		var _url = "/covicore/api/config/addIPSecure.do";
		if(mode == "modify") {
			_url = "/covicore/api/config/editIPSecure.do"
		}
		
		$.ajax({
			type:"POST",
			data:$("#form_APIIPSecureInfoPop").serialize(),
			url: _url,
			success:function (data) {
				if(data.status=='SUCCESS'){
		    		parent.Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){ /*저장되었습니다.*/
						parent.ipconfigGrid.reloadList();			
		    			Common.Close();
		    		});
	    		}else{
	    			parent.Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
	    		}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/api/config/editConfig.do", response, status, error);
			}
		});
	}
	
}

//입력값 검증
function validationChk(){
	if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
	var dic = Common.getDic("msg_EnterTheRequiredValue");
	var msg = dic;
	
	var requiredInputs = $(".av-required");
	for(var i = 0; i < requiredInputs.length; i++){
		if(requiredInputs[i].value == undefined || requiredInputs[i].value == ""){
			var txt = $(requiredInputs[i]).closest("td").prev("th").text();
			msg = dic.replace("{0}", txt);
			parent.Common.Warning(msg, "Warning Dialog", function(){
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