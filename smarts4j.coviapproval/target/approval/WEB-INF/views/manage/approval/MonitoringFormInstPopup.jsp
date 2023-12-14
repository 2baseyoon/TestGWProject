<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/AdminInclude.jsp"></jsp:include>
<script>
	$(document).ready(function (){
		getFormInstance();
		
		if(CFN_GetQueryString("archived") == "false"){
			$("#tblFormInstance").find("td").find("input[type=text],textarea").each(function(){
				$(this).attr("ondblclick", "changeEditMode(this)");
			});
		}else{
			$("#btnSaveFormInst").hide();
			$("#warningText").hide();
		}
	});
	
	//get forminstance
	function getFormInstance(){
		$.ajax({
		    url: "getforminstance.do",
		    type: "POST",
		    data: {
				"fiid" : CFN_GetQueryString("FormInstID")
			},
		    success: function (res) {
	            //$('#divProcInfo').append(JSON.stringify(res.list));
		    	getFormInstanceSuccessCallback(res.list[0]);
	        },
	        error:function(response, status, error){
				CFN_ErrorAjax("getforminstance.do", response, status, error);
			}
		});
	}
	
	function getFormInstanceSuccessCallback(data){
		for (var key in data){
			var $target = $('#txt_' + key);
			var val;
			if(key == 'BodyContext' || key == 'AttachFileInfo'){
				val = Base64.b64_to_utf8(data[key]);
			} else {
				val = data[key];
			}
			
			$target.val(val);
		}
	}
	
	function changeEditMode(obj){
		if($(obj).attr("readonly") == "readonly"){
			$(obj).removeAttr("readonly");
			$(obj).css("border", "");
			
			var hidden = document.createElement("input");
			hidden.setAttribute("type", "hidden");
			hidden.setAttribute("id", "hid"+$(obj).attr("id").replace("txt_", ""));
			hidden.setAttribute("value", $(obj).val());
			document.getElementById("divFormInstance").appendChild(hidden);
		}else{
			$(obj).attr("readonly", "readonly");
			$(obj).css("border", "0");
			
			$(obj).val($("#hid" + $(obj).attr("id").replace("txt_", "")).val());
			$("#hid" + $(obj).attr("id").replace("txt_", "")).remove();
		}
	}
	
	function saveFormInst(obj){
		var dataJson = {};
		$$(dataJson).append();
		
		$("#tblFormInstance").find("td").find("input[type=text],textarea").each(function(){
			if($(this).attr("readonly") != "readonly"){
				var tmpId = $(this).attr("id");
				if(tmpId == 'txt_BodyContext' || tmpId == 'txt_AttachFileInfo'){
					$$(dataJson).append(tmpId.replace("txt_", ""), Base64.utf8_to_b64($(this).val()));
				}else{
					$$(dataJson).append(tmpId.replace("txt_", ""), $(this).val());
				}
			}
		});
		
		if(Object.keys(dataJson).length > 0){
			$.ajax({
			    url: "setforminstance.do",
			    type: "POST",
			    data: {
			    	"fiid" : CFN_GetQueryString("FormInstID"),
			    	"formInstData" : JSON.stringify(dataJson)
			    },
			    dataType: "json",
			    success: function (res) {
			    	if(res.status == "SUCCESS")
			    		parent.Common.Inform("<spring:message code='Cache.msg_apv_alert_006' />", "Information", function(){
			    			location.reload();
			    		});
		        },
		        error:function(response, status, error){
					CFN_ErrorAjax("setforminstance.do", response, status, error);
				}
			});
		}else{
			Common.Warning("수정할 항목이 없습니다.\n수정을 원하는 항목을 더블클릭하여 수정하신 후 저장해주시길 바랍니다.");
		}
	}
	
	function closePopup(){
		Common.Close();
	}
</script>
<body>
	<div id="divFormInstance" style="padding:10px;">
		<h3 class="con_tit_box">
			<span class="con_tit">FormInstance 정보</span>	
		</h3>
    	<div id="warningText" style="color:red;font-size:9pt"><b>NULL 에 대한 수정은 쿼리로 직접 해주시길 바라며, ID에 대한 수정은 다른 테이블들의 관계와 영향을 미칠 수 있습니다.</b></div>
    	<br>
    	<table id="tblFormInstance" class="AXFormTable" width="100%">
    		<colgroup>
    			<col style="width: 15%">
    			<col style="width: 35%">
    			<col style="width: 15%">
    			<col style="width: 35%">
    		</colgroup>
    		<tbody>
    			<tr>
					<th>FormInstID</th>
					<td colspan="3"><input type="text" id="txt_FormInstID" style="width:95%;padding:3px;border: 0" readonly></td>
				</tr>
	   			<tr>
	   				<th>ProcessID</th>
					<td><input type="text" id="txt_ProcessID" style="width:95%;padding:3px;border: 0" readonly></td>
					<th>FormID</th>
					<td><input type="text" id="txt_FormID" style="width:95%;padding:3px;border: 0" readonly></td>
				</tr>
				<tr>
					<th>SchemaID</th>
					<td><input type="text" id="txt_SchemaID" style="width:95%;padding:3px;border: 0" readonly></td>
					<th>Subject</th>
					<td><input type="text" id="txt_Subject" style="width:95%;padding:3px;border: 0" readonly></td>
				</tr>
				<tr>
					<th>InitiatorID</th>
					<td><input type="text" id="txt_InitiatorID" style="width:95%;padding:3px;border: 0" readonly></td>
					<th>InitiatorName</th>
					<td><input type="text" id="txt_InitiatorName" style="width:95%;padding:3px;border: 0" readonly></td>
				</tr>
				<tr>
					<th>InitiatorUnitID</th>
					<td><input type="text" id="txt_InitiatorUnitID" style="width:95%;padding:3px;border: 0" readonly></td>
					<th>InitiatorUnitName</th>
					<td><input type="text" id="txt_InitiatorUnitName" style="width:95%;padding:3px;border: 0" readonly></td>
				</tr>
				<tr>
					<th>InitiatedDate</th>
					<td><input type="text" id="txt_InitiatedDate" style="width:95%;padding:3px;border: 0" readonly></td>
					<th>CompletedDate</th>
					<td><input type="text" id="txt_CompletedDate" style="width:95%;padding:3px;border: 0" readonly></td>
				</tr>
				<tr>
					<th>DeletedDate</th>
					<td><input type="text" id="txt_DeletedDate" style="width:95%;padding:3px;border: 0" readonly></td>
					<th>EntCode</th>
					<td><input type="text" id="txt_EntCode" style="width:95%;padding:3px;border: 0" readonly></td>
				</tr>
				<tr>
					<th>EntName</th>
					<td><input type="text" id="txt_EntName" style="width:95%;padding:3px;border: 0" readonly></td>
					<th>DocNo</th>
					<td><input type="text" id="txt_DocNo" style="width:95%;padding:3px;border: 0" readonly></td>
				</tr>
				<tr>
					<th>DocLevel</th>
					<td><input type="text" id="txt_DocLevel" style="width:95%;padding:3px;border: 0" readonly></td>
					<th>DocClassID</th>
					<td><input type="text" id="txt_DocClassID" style="width:95%;padding:3px;border: 0" readonly></td>
				</tr>
				<tr>
					<th>DocClassName</th>
					<td><input type="text" id="txt_DocClassName" style="width:95%;padding:3px;border: 0" readonly></td>
					<th>IsPublic</th>
					<td><input type="text" id="txt_IsPublic" style="width:95%;padding:3px;border: 0" readonly></td>
				</tr>
				<tr>
					<th>AttachFileInfo</th>
					<td colspan="3"><textarea id="txt_AttachFileInfo" rows="2"  style="width:95%;padding:3px;resize:none;border: 0" readonly json-value='true'></textarea></td>				
				</tr>
				<tr>
					<th>SaveTerm</th>
					<td><input type="text" id="txt_SaveTerm" style="width:95%;padding:3px;border: 0" readonly></td>
					<th>AppliedDate</th>
					<td><input type="text" id="txt_AppliedDate" style="width:95%;padding:3px;border: 0" readonly></td>
				</tr>
				<tr>
					<th>AppliedTerm</th>
					<td><input type="text" id="txt_AppliedTerm" style="width:95%;padding:3px;border: 0" readonly></td>
					<th>ReceiveNo</th>
					<td><input type="text" id="txt_ReceiveNo" style="width:95%;padding:3px;border: 0" readonly></td>
				</tr>
				<tr>
					<th>ReceiveNames</th>
					<td><input type="text" id="txt_ReceiveNames" style="width:95%;padding:3px;border: 0" readonly></td>
					<th>ReceiptList</th>
					<td><input type="text" id="txt_ReceiptList" style="width:95%;padding:3px;border: 0" readonly></td>
				</tr>
				<tr>
					<th>BodyType</th>
					<td><input type="text" id="txt_BodyType" style="width:95%;padding:3px;border: 0" readonly></td>
					<th>DocLinks</th>
					<td><input type="text" id="txt_DocLinks" style="width:95%;padding:3px;border: 0" readonly></td>
				</tr>
				<tr>
					<th>BodyContext</th>
					<td colspan="3"><textarea id="txt_BodyContext" rows="2" style="width:95%;padding:3px;resize:none;border:0" readonly json-value='true'></textarea></td>
				</tr>
    		</tbody>
    	</table>
    	<br/>
    	<div align="center">
    		<input type="button" id="btnSaveFormInst" class="AXButton Red" value="저장" onclick="saveFormInst(this);">
    		<input type="button" id="btnCloseFormInst" class="AXButton" value="닫기" onclick="closePopup();">
    	</div>
    </div>
</body>
</html>