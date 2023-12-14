<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp" />

<div class="layer_divpop ui-draggable docPopLayer" id="testpopup_p" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">	
		<div class="popContent">
			<div class="apprvalBottomCont">
				<div class="appRelBox">
					<dl class="daeLeft">
						<dt class="daeTop">
							<span><spring:message code='Cache.lbl_TaskClassSet' /></span> <!-- 업무구분 설정 -->
						</dt>
						<dd class="daeBot">
                      		<div class="t_padding">
		                      	<table>
			                        <colgroup>
				                          <col style="width:150px">
				                          <col style="width:*">
			                        </colgroup>
			                        <tbody>
	                        			<tr id="trTopClass" style="display: none">
			                          		<td><spring:message code='Cache.Approval_TopClassName' /></td> <!-- 상위 업무구분명 -->
				                          	<td>
				                          		<input type="text" class="adTArea" id="txtParentFunctionName" disabled="disabled">
				                          		<input type="hidden" class="adTArea" id="hidParentFunctionCode">
				                          	</td>
				                        </tr>
	                        			<tr>
			                          		<td><spring:message code='Cache.Approval_ClassName' /></td> <!-- 업무구분명 -->
				                          	<td>
				                          		<input type="text" class="adTArea" id="txtFunctionName">
				                          	</td>
				                        </tr>
	                        			<tr>
			                          		<td><spring:message code='Cache.Approval_ClassCode' /></td> <!-- 업무구분코드 -->
				                          	<td>
				                          		<input type="text" class="adTArea" id="txtFunctionCode">
				                          	</td>
				                        </tr>
	                        			<tr>
			                          		<td><spring:message code='Cache.lbl_apv_Sort' /></td> <!-- 정렬 -->
				                          	<td>
				                          		<input type="text" class="adTArea" id="txtSort" onkeyup="removeChar(this)" maxlength="4">
				                          	</td>
			                        	</tr>
		                      		</tbody>
	                      		</table>
                      		</div>
						</dd>
					</dl>
				</div>
			</div>
			<div class="bottom">
				<a class="btnTypeDefault btnTypeChk" onclick="save();"><spring:message code='Cache.btn_save' /></a> <!-- 저장 -->
				<a class="btnTypeDefault" onclick="Common.Close(); return false;"><spring:message code='Cache.btn_apv_close' /></a> <!-- 닫기 -->
			</div>
		</div>
	</div>
</div>

<script>
   	window.onload = initOnload;
   	function initOnload() {
   		// 하위 업무구분 생성시 선택한 상위 업무구분 바인딩
   		if (CFN_GetQueryString('parentCode') != '') {
	   		document.getElementById('trTopClass').style.display = '';
		   
			document.getElementById('txtParentFunctionName').value = decodeURIComponent(CFN_GetQueryString('parentName')) + ' / ' + CFN_GetQueryString('parentCode');
			document.getElementById('hidParentFunctionCode').value = CFN_GetQueryString('parentCode');
	   }
   	}
	
   	// 저장
   	function save() {
   		if (validation()) {
   			Common.Confirm('<spring:message code='Cache.msg_RUSave' />', 'Confirm Dialog', function(result) { // 저장하시겠습니까?
				if (result) {
	   				let url = '/approval/user/insertSeriesFunctionData.do';
	   		   		let params = {
	   		   				"ParentFunctionCode": document.getElementById('hidParentFunctionCode').value,
	   		   				"FunctionCode": document.getElementById('txtFunctionCode').value,
	   		   				"FunctionName": document.getElementById('txtFunctionName').value,
	   		   				"Sort": document.getElementById('txtSort').value
	   		   			};
	   		   		
	   		   		$.ajax({
	   					url: url,
	   					type: 'POST',
	   					data: params,
	   					success: function(data){
	   						if(data.status == 'SUCCESS'){
	   							Common.Inform(data.message, 'Inform Dialog', function(){
   									parent.refresh();
   									Common.Close();
	   							});
	   						} else if(data.status == "EXISTS"){
								Common.Warning(data.message);  // 이미 존재하는 업무구분코드입니다.
							} else{
	   							Common.Error('<spring:message code='Cache.msg_apv_030' />');  // 오류가 발생했습니다.
	   						}
	   					},
	   					error: function(error){
	   						Common.Error('<spring:message code='Cache.msg_apv_030' />');  // 오류가 발생했습니다.
	   					}
	   				});
				}
   			});
   		}
   	}
   	
   	// 저장 전 벨리데이션
   	function validation() {
   		let rtn = true;
   		
   		if ($.trim(document.getElementById('txtFunctionName').value) == '') {
   			Common.Warning('<spring:message code='Cache.Approval_EnterBusinessClassName' />', 'Warning Dialog', function() { // 업무구분명을 입력하세요.
   				document.getElementById('txtFunctionName').focus();
   			});
   			rtn = false;
   		} else if ($.trim(document.getElementById('txtFunctionCode').value) == '') {
   			Common.Warning('<spring:message code='Cache.Approval_EnterBusinessClassCode' />', 'Warning Dialog', function() { // 업무구분코드를 입력하세요.
   				document.getElementById('txtFunctionCode').focus();
   			});
   			rtn = false;
   		} else if (isNaN(document.getElementById('txtSort').value)) {
   			Common.Warning('<spring:message code='Cache.msg_apv_249' />', 'Warning Dialog', function() { // 숫자만 입력가능합니다.
   				document.getElementById('txtSort').focus();
   			});
   			rtn = false;
   		}
   		return rtn;
   	}
</script>