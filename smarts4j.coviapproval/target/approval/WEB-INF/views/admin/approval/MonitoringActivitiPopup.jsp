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
	function sendData(target){
		//data 추출
		var data = {};
		var taskid;
		var selectedMode, comment, signImage, isModified, isFile, apvline;
		
		taskid = $('#txt_rest_taskid').val();
		selectedMode = $('#sel_rest_mode option:selected').val();
		comment = $('#txt_rest_comment').val();
		signImage = $('#txt_rest_signimage').val();
		isModified = $('#txt_rest_ismodified').val();
		isFile = $('#txt_rest_isfile').val();
		apvline = $('#txt_rest_apvline').val();
		
		data['g_action_' + taskid] = selectedMode;
		data['g_actioncomment_' + taskid] = Base64.utf8_to_b64(comment);
		data['g_actioncomment_attach_' + taskid] = [];
		data['g_signimage_' + taskid] = signImage;
		data['g_isMobile_' + taskid] = "N";
		data['g_isBatch_' + taskid] = "N";
		
		if(isModified != null && isModified != ''){
			data['g_isModified'] = isModified;	
		}
		
		if(isFile != null && isFile != ''){
			data['g_isFile'] = isFile;	
		}
		
		if(apvline != null && apvline != ''){
			data['g_appvLine'] = apvline;	
		}
		
		Common.Confirm("<spring:message code='Cache.msg_apv_ConfirmSend' />", "Confirmation Dialog", function(result){		//"전송 하시겠습니까?"
			if(!result){
				return false;
			}else{
				//call ajax
				callRestAPI(taskid, data);
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
   					<td width="150px">task id</td>
   					<td><input type="text" id="txt_rest_taskid" style="width:100px;padding:3px;"></td>
   				</tr>
   				<tr>
   					<td width="150px">action mode</td>
   					<td>
   						<select id="sel_rest_mode">
						    <option value="APPROVAL">승인</option>
						    <option value="REJECT">반려</option>
						    <option value="HOLD">보류</option>
						    <option value="REDRAFT">재기안</option>
						    <option value="ABORT">기안취소, 회수</option>
						    <option value="APPROVECANCEL">승인취소</option>
						    <option value="AGREE">동의</option>
						    <option value="DISAGREE">거부</option>
						    <option value="FORWARD">전달</option>
						    <option value="REJECTTO">지정반려</option>
						</select>
					</td>
   				</tr>
   				<tr>
   					<td width="150px">comment</td>
   					<td><input type="text" id="txt_rest_comment" style="width:90%;padding:3px;"></td>
   				</tr>
   				<tr>
   					<td width="150px">sign image</td>
   					<td><input type="text" id="txt_rest_signimage" style="width:100px;padding:3px;"></td>
   				</tr>
   				<tr>
   					<td width="150px">isModified</td>
   					<td><input type="text" id="txt_rest_ismodified" style="width:100px;padding:3px;"></td>
   				</tr>
   				<tr>
   					<td width="150px">isFile</td>
   					<td><input type="text" id="txt_rest_isfile" style="width:100px;padding:3px;"></td>
   				</tr>
   				<tr>
   					<td width="150px">approval line</td>
   					<td><textarea id="txt_rest_apvline" rows="5" style="width:90%;padding:3px;"></textarea></td>
   				</tr>
   			</tbody>
   		</table>
   		
    	<div style="padding:5px;">
    		<input type="button" class="AXButton Red" onclick="sendData('tblRest')" value="SEND">
   		</div>
   	</div>
</div>
</body>
</html>