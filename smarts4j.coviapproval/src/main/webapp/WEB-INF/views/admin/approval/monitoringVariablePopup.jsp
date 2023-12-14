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
	// 변수 가져오기
	function getVariable(){
		var taskid = $("#txt_rest_taskid").val();
		var name = $("#txt_var_name").val();
		
		if(!taskid || !name){
			Common.Warning(Common.getDic("msg_apv_actIdName")); // taskID, name 을 입력해주세요.
			return false;
		}
		
		$.ajax({
		    url: "getactvariable.do",
		    type: "POST",
		    data: {
				"taskid" : taskid,
				"name" : name
			},
		    success: function (res) {
                if(res.status == "FAIL"){ 
                	var msg = res.message;
					if(msg == "FileNotFound"){ // taskid , name 으로 정보가 없는경우 엔진에서 FileNotFound 로 리턴됨 (An exception occurred: java.io.FileNotFoundException)
						msg = Common.getDic("msg_apv_notExistVariable");
					}
                	Common.Warning(msg);
                }else{ // SUCCESS
                	if(!res.list){
                		Common.Warning(Common.getDic("msg_apv_030")); // 오류가 발생했습니다.
                	}else{
                		var value = res.list.value;
                		if(typeof res.list.value == "object") value = JSON.stringify(res.list.value);
                		if(value == "NULL") value = "NULL - " + Common.getDic("msg_apv_actValNull"); // 현재 변수 값이 null입니다. 빈값(\"\")으로 put 하더라도 값이 변경되므로 주의하세요.
							
						$("#txt_var_value").val(value);
						displayPut('show');
						
						switch(name){
							case "g_appvLine":
							case "g_context":
							case "g_isLegacy":
							case "g_config":
								$("#txt_var_type").val("json"); break;
							default:
								$("#txt_var_type").val("string"); break;
						}
                	}
                }
            },
            error:function(response, status, error){
				CFN_ErrorAjax("getactvariable.do", response, status, error);
			}
		});
	}
	
	//결재선 변경 Update
	function putVariable(){
		var taskid = $("#txt_rest_taskid").val();
		var name = $("#txt_var_name").val();
		var value = $("#txt_var_value").val();
		var type = $("#txt_var_type").val(); // string , json
		
		if(value == "") type = "string";
		if(type == "json" && !isJson(value)){
			Common.Warning(Common.getDic("msg_apv_jsonFormat")); // 값이 json형식이 아닙니다.
			return false;
		}
		
		if(!taskid || !name){
			Common.Warning(Common.getDic("msg_apv_actIdName")); // taskID, name 을 입력해주세요.
			return false;
		}
		
		$.ajax({
			url:"setActivitiVariable.do",
			type:"post",
			data: {
				"taskid": taskid,
				"name": name,
				"value" : value,
				"type" : type
			},
			async:false,
			success:function (res) {
				if(res.status == "FAIL"){ 
                	Common.Warning(res.message);
                }else{ // SUCCESS
					Common.Inform(Common.getDic("msg_apv_alert_006"), "Information", function(){ // 성공적으로 처리 되었습니다.
						displayPut("hide");
					});
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("setActivitiVariable.do", response, status, error);
			}
		});
	}
	
	function displayPut(pType){
		if(pType == "hide") {
			$("#btnPut").hide();
			$("#txt_var_value").val("");
		}
		else{ 
			$("#btnPut").show();
		}
	}

	function isJson(pVal){
		try{
			var json = JSON.parse(pVal);
			return (typeof json == "object");
		}catch(e){
			return false;
		}
	}
	
</script>
<body>
<div style="margin: 10px">
	<h3 class="con_tit_box">
		<span class="con_tit"><spring:message code='Cache.lbl_apv_callActivitiApi' /></span> <!-- Activiti Rest API 호출 -->
	</h3>
	<div>
    	<table id="tblRest" class="table1_12" width="100%">
   			<tbody>
   				<tr>
   					<td width="100px">taskID</td>
   					<td><input type="text" id="txt_rest_taskid" style="width:100px;padding:3px;" onkeyup="displayPut('hide')"></td>
   				</tr>
   				<tr>
   					<td>name</td>
   					<td><input type="text" id="txt_var_name" style="width:100px;padding:3px;" onkeyup="displayPut('hide')"></td>
   				</tr>
   				<tr>
   					<td>value type</td>
   					<td>
   						<select id="txt_var_type">
   							<option value="string">string</option>
   							<option value="json">json</option>
   						</select>
   					</td>
   				</tr>
   				<tr>
   					<td>value</td>
   					<td><textarea id="txt_var_value" rows="5" json-value='true' style="width:98%;padding:3px;"></textarea></td>
   				</tr>
   			</tbody>
   		</table>
   		
    	<div style="padding:5px;">
    		<div style="color:red;font-weight:bold;margin-bottom:10px;margin-top:5px;">* <spring:message code='Cache.msg_apv_chkValForPut' /></div> <!-- 반드시 GET으로 변수가 있는지 값 확인 후 PUT 하시기 바랍니다. -->
    		<input type="button" class="AXButton Red" onclick="getVariable()" value="GET">
    		<input type="button" class="AXButton Red" onclick="putVariable()" id="btnPut" value="PUT" style="display:none;">
   		</div>
   	</div>
</div>
</body>
</html>