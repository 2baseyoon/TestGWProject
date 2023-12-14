<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/AdminInclude.jsp"></jsp:include>
<%@ page import="egovframework.baseframework.util.PropertiesUtil" %>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<% String approvalAppPath = PropertiesUtil.getGlobalProperties().getProperty("approval.app.path"); %>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/approval/resources/css/approval/monitoring.css<%=resourceVersion%>" />
<script type="text/javascript" src="<%=approvalAppPath%>/resources/script/admin/Monitoring.js<%=resourceVersion%>"></script>
<script>
	//결재선 변경 Update
	function goBatchApvLine(){
		var g_ProcessID = $("#txt_rest_processid").val();
		var g_FormInstID = $("#txt_rest_forminstid").val();
		var taskID = $("#txt_rest_taskid").val();
		var apvLine = $("#txt_rest_apvline").val();
		
		$.ajax({
			url:"setDomainListData.do",
			type:"post",
			data: {
				"ProcessID": g_ProcessID,
				"FormInstID": g_FormInstID,
				"taskID" : taskID,
				"DomainDataContext" : apvLine
			},
			async:false,
			success:function (data) {
				if(data.status == "SUCCESS"){
					parent.Common.Inform(Common.getDic("msg_apv_alert_006"), "Information", function(){
						location.reload();
					});
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("setDomainListData.do", response, status, error);
			}
		});
	}
	
	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}

</script>
<body>
<div style="margin: 10px">
	<h3 class="con_tit_box">
		<span class="con_tit">Activiti Rest API 호출</span>	
	</h3>
	<div>
    	<table id="tblRest" class="table1_12" width="100%">
   			<thead>
    			<th width="150px">명칭</th>
    			<th>Value</th>
   			</thead>
   			<tbody>
   				<tr>
   					<td width="150px">ProcessID</td>
   					<td><input type="text" id="txt_rest_processid" style="width:100px;padding:3px;"></td>
   				</tr>
   				<tr>
   					<td width="150px">FormInstID</td>
   					<td><input type="text" id="txt_rest_forminstid" style="width:100px;padding:3px;"></td>
   				</tr>
   				<tr>
   					<td width="150px">taskID</td>
   					<td><input type="text" id="txt_rest_taskid" style="width:100px;padding:3px;"></td>
   				</tr>
   				<tr>
   					<td width="150px">DomainDataContext</td>
   					<td><textarea id="txt_rest_apvline" rows="5" json-value='true' style="width:90%;padding:3px;"></textarea></td>
   				</tr>
   			</tbody>
   		</table>
   		
    	<div style="padding:5px;">
    		<input type="button" class="AXButton Red" onclick="goBatchApvLine()" value="PUT">
   		</div>
   	</div>
</div>
</body>
</html>