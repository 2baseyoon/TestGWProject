<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>
<style>
	.requiredTh::before{
		content: '* ';
		color:red;				
	}
</style>
<form id="form_StorageInfoManage" name="form_StorageInfoManage">
	<div>
		<table class="AXFormTable">
			<tr>
				<th class="requiredTh" style="width:150px;"><spring:message code="Cache.lbl_Domain"/></th><!-- 도메인 -->
				<td colspan="3">
					<select id="DomainID" name="domainID" style="height: 28px;"></select>
				</td>
			</tr>
			<tr>
				<th class="requiredTh"><spring:message code="Cache.lbl_ServiceType"/></th><!-- 서비스유형 -->
				<td colspan="3">
					<input type="text" id="ServiceType" name="serviceType" style="width:99%;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS" required="required"/>
				</td>
			</tr>
			<tr>
				<th class="requiredTh"><spring:message code="Cache.lbl_File"/> Path</th><!-- 파일 Path -->
				<td colspan="3">
					<input type="text" id="FilePath" name="filePath" style="width:99%;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS" required="required"/>
				</td>
			</tr>
			<tr>
				<th><spring:message code="Cache.lbl_Inline"/> Path</th><!-- 인라인 Path -->
				<td colspan="3">
					<input type="text" id="InlinePath" name="inlinePath" style="width:99%;" class="AXInput HtmlCheckXSS ScriptCheckXSS" />
				</td>
			</tr>
			<tr>
				<th><spring:message code="Cache.lbl_FileCreateSeq"/></th><!-- 파일생성 순번 -->
				<td colspan="3">
					<input type="number" id="LastSeq" name="lastSeq" size="10" min="0" value=0 class="AXInput HtmlCheckXSS ScriptCheckXSS"/>
				</td>
			</tr>
			<tr>
				<th class="requiredTh"><spring:message code="Cache.lbl_isActive"/></th><!-- 활성화 여부 -->
				<td colspan="3">
					<select id="IsActive" name="isActive" class="AXSelect">
						<option value="Y" selected>Y</option>
						<option value="N">N</option>
					</select>
				</td>
			</tr>
			<tr style="height: 100px">
				<th><spring:message code="Cache.lbl_Description"/></th> <!-- 설명 -->
				<td colspan="3">
					<textarea rows="5" style="width: 97%; resize:none;" id="Description" name="description" class="AXTextarea HtmlCheckXSS ScriptCheckXSS"></textarea>
				</td>
			</tr>
		</table>
		<div style="padding-top: 10px" class="center">
			<input type="button" id="btn_create" value="<spring:message code="Cache.btn_Add"/>" class="AXButton red" />
			<input type="button" id="btn_modify" value="<spring:message code="Cache.btn_Edit"/>" class="AXButton red" />
			<input type="button" value="<spring:message code="Cache.btn_Close"/>" onclick="closeLayer();"  class="AXButton" />
		</div>
	</div>
</form>
<script>

var params = (function(){
	var mode = "${mode}";
	var storageId = "${storageID}";
	var url = "/covicore/storage-info/get/${storageID}.do"
	// Domain List
	var lang = Common.getSession("lang");
	coviCtrl.renderDomainAXSelect('DomainID', lang, null, null);
	$("#IsActive").bindSelect();
	
	if(mode === "modify"){
		$("#btn_modify").on("click", modify);
		setData(url);
	} else {
		$("#btn_modify").remove();
	}
	
	$("#btn_create").on("click", add);
	$("#LastSeq").on("keydown", function(e){
		if(e.key.match(/\D/)){
			e.preventDefault();
		}
	})
	
	//정보 조회
	function setData(){
		$.ajax({
			type:"GET",
			url:url,
	        dataType: 'json',
	        contentType: 'application/json; charset=utf-8',
			success:function (data) {
				for(key in data.info){
					var $obj = $("#" + key);
					if($obj.length == 0) continue;					
					if($obj[0].tagName.toLowerCase() == "span"){
						$obj.html(data.info[key]);
					}else if($obj[0].tagName.toLowerCase() == "textarea"){
						$obj.val(data.info[key]);
					}else if($obj[0].tagName.toLowerCase() == "select"){
						$obj.bindSelectSetValue(data.info[key]);
					}else{
						if("checkbox" == $obj.attr("type")){
							if($obj.val() == data.info[key]){
								$obj.attr("checked", true);
							}else{
								$obj.attr("checked", false);
							}
						} else {
							$obj.val(data.info[key]);
						}
					}
	    		}
			},
			error:function(response){
				if(response.status === 400 && response.responseJSON){
					Common.Error(response.responseJSON);
				} else {
					CFN_ErrorAjax(url, response, response.status, response.statusText);
				}
			}
		});
	}
	
	//추가
	function add(){
		if(validationChk()){
			$.ajax({
				type:"POST",
				data:JSON.stringify($("#form_StorageInfoManage").serializeObject()),
			    contentType: 'application/json; charset=utf-8',
				url:"/covicore/storage-info/add.do",
				success:function (data) {
		    		parent.Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){ /*저장되었습니다.*/
						parent.grid.reloadList();	    			
		    			Common.Close();
		    		});
				},
				error:function(response){
					if(response.status === 400 && response.responseJSON){
						Common.Error(response.responseJSON);
					} else {
						CFN_ErrorAjax("/covicore/storage-info/add.do", response, response.status, response.statusText);
					}
				}
			});
		}
	}

	//수정
	function modify(){
		if(validationChk()){
			$.ajax({
				type:"PUT",
				data:JSON.stringify($("#form_StorageInfoManage").serializeObject()),
			    contentType: 'application/json; charset=utf-8',
				url:"/covicore/storage-info/modify/${storageID}.do",
				success:function (data) {
		    		parent.Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){ /*저장되었습니다.*/
						parent.grid.reloadList();			
		    			Common.Close();
		    		});
				},
				error:function(response){
					if(response.status === 400 && response.responseJSON){
						Common.Error(response.responseJSON);
					} else {
						CFN_ErrorAjax(url, response, response.status, response.statusText);
					}
				}
			});
		}		
	}
})();


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