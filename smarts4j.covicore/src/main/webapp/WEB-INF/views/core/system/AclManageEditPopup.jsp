<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="EUC-KR"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>

<style>
	.acl_switch {
		width: 50px;
		height: 21px !important;
		border: 0px none;
	}
</style>

<body>
	<div>
		<div style="padding: 15px;">
			<table class="AXFormTable">
				<colgroup>
					<col width="80px;">
					<col>
				</colgroup>
				<tr>
					<th><spring:message code="Cache.lbl_ACL_Security"/></th> <!-- 보안 -->
					<td>
						<input type="text" kind="switch" id="AXInputSwitch_Security" class="acl_switch" on_value="Y" off_value="N"/>
					</td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_ACL_Generation"/></th> <!-- 생성 -->
					<td>
						<input type="text" kind="switch" id="AXInputSwitch_Create" class="acl_switch" on_value="Y" off_value="N"/>
					</td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_ACL_Delete"/></th> <!-- 삭제 -->
					<td>
						<input type="text" kind="switch" id="AXInputSwitch_Delete" class="acl_switch" on_value="Y" off_value="N"/>
					</td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_Modify"/></th> <!-- 수정 -->
					<td>
						<input type="text" kind="switch" id="AXInputSwitch_Modify" class="acl_switch" on_value="Y" off_value="N"/>
					</td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_Execute"/></th> <!-- 실행 -->
					<td>
						<input type="text" kind="switch" id="AXInputSwitch_Execute" class="acl_switch" on_value="Y" off_value="N"/>
					</td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_ACL_Views"/></th> <!-- 조회 -->
					<td>
						<input type="text" kind="switch" id="AXInputSwitch_View" class="acl_switch" on_value="Y" off_value="N"/>
					</td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_ACL_Read"/></th> <!-- 읽기 -->
					<td>
						<input type="text" kind="switch" id="AXInputSwitch_Read" class="acl_switch" on_value="Y" off_value="N"/>
					</td>
				</tr>
			</table>
		</div>
		<div align="center">
			<input type="button" id="applyBtn" class="AXButton red" value="<spring:message code="Cache.btn_Apply"/>"/> <!-- 적용 -->
			<input type="button" id="closeBtn" class="AXButton" value="<spring:message code="Cache.btn_Close"/>"/> <!-- 닫기 -->
		</div>
	</div>
</body>

<script>
	(function(param){
		var aclType = ["Security", "Create", "Delete", "Modify", "Execute", "View", "Read"];
		
		var setEvent = function(){
			// 적용
			$("#applyBtn").off("click").on("click", function(){
				setACLInfo();
			});
			
			// 닫기
			$("#closeBtn").off("click").on("click", function(){
				Common.Close();
			});
		}
		
		var getACLInfo = function(){
			$.ajax({
				url: "/covicore/aclManage/getACLInfo.do",
				type: "POST",
				data: {
					aclID: param.aclID
				},
				success: function(data){
					if(data.status === "SUCCESS"){
						if(data.list.length > 0){
							var info = data.list[0];
							
							aclType.forEach(function(item){
								$("#AXInputSwitch_" + item).val(info[item] === "_" ? "N" : "Y");
							});
							
							if (typeof coviInput === "object") coviInput.setSwitch();
						}
					}else{
						Common.Warning("<spring:message code='Cache.msg_apv_030'/>");
					}
				},
				error: function(response, status, error){
					CFN_ErrorAjax("/covicore/aclManage/getACLInfo.do", response, status, error);
				}
			});
		}
		
		var setACLInfo = function(){
			var params = new Object();
			var aclList = "";
			
			aclType.forEach(function(item){
				aclList += params[item] = $("#AXInputSwitch_" + item).val() === "Y" ? item[0] : "_";
			});
			
			params["AclList"] = aclList;
			params["aclID"] = param.aclID;
			params["objectType"] = param.objType;
			params["domain"] = param.domain;
			
			$.ajax({
				url: "/covicore/aclManage/setACLInfo.do",
				type: "POST",
				data: params,
				success: function(data){
					if(data.status === "SUCCESS"){
						parent.Common.Inform("<spring:message code='Cache.msg_successSave'/>", "Information", function(){ // 저장에 성공했습니다.
							parent.aclManage.searchAclDetail(parent.aclManage.gridAcl.getSelectedItem().item, parent.aclManage.gridAclDetail.page.pageNo);
							Common.Close();
						});
					}else{
						Common.Warning("<spring:message code='Cache.msg_apv_030'/>");
					}
				},
				error: function(response, status, error){
					CFN_ErrorAjax("/covicore/aclManage/setACLInfo.do", response, status, error);
				}
			});
		}
		
		var init = function(){
			setEvent();
			getACLInfo();
		}
		
		init();
	})({
		  aclID: "${aclID}"
		, objType: "${objType}"
		, domain: "${domain}"
	})
</script>