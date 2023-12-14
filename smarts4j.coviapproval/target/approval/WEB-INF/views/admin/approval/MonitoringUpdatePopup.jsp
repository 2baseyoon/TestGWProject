<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/AdminInclude.jsp"></jsp:include>
<%@ page import="egovframework.baseframework.util.PropertiesUtil" %>
<% String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); %>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<link rel="stylesheet" type="text/css" href="<%=cssPath%>/approval/resources/css/approval/monitoring.css<%=resourceVersion%>" />
<script>
	function encodeData(target){
		var val = $('#' + target).val();
		var encodedVal = Base64.utf8_to_b64(val);
		$('#' + target).val(encodedVal);
	}
	
	function updateData(table, col, colKey, txtKey, datatype, txtVal){
		Common.Confirm("<spring:message code='Cache.msg_apv_ConfirmUpdate' />", "Confirmation Dialog", function(result){		//update 하시겠습니까?
			if(!result){
				return false;
			}else{
				var selectedTable = $('#' + table + ' option:selected').val();
				var selectedCol = $('#' + col + ' option:selected').val();
				var selectedColKey = $('#' + colKey + ' option:selected').val();
				var selectedColKeyVal = $('#' + txtKey).val();
				var selectedVal = $('#' + txtVal).val();
				var selectedDataType = $('#' + datatype + ' option:selected').val();
				
				if((selectedCol == null || selectedCol == '')
						||(selectedColKey == null || selectedColKey == '')
						||(selectedColKeyVal == null || selectedColKeyVal == '')
						||(selectedVal == null || selectedVal == '')
						||(selectedDataType == null || selectedDataType == '')){
					return;
				}
				
				$.ajax({
				    url: "update.do",
				    type: "POST",
				    data: {
						"table" : selectedTable,
						"keyName" : selectedColKey,
						"keyValue" : selectedColKeyVal,
						"dataType" : selectedDataType,
						"colName" : selectedCol,
						"colValue" : selectedVal
					},
					dataType: "json",
				    success: function (res) {
				    	if(res.status == 'SUCCESS'){
				    		Common.Inform("<spring:message code='Cache.msg_apv_alert_006' />"); //성공하였습니다.	
				    		Refresh();
				    	}
		            },
		            error:function(response, status, error){
						CFN_ErrorAjax("update.do", response, status, error);
					}
				});
			}
		});
		
	}
</script>
<body>
<div style="padding:10px;">
	<h3 class="con_tit_box">
		<span class="con_tit">Update 호출</span>	
	</h3>
    	<br/>
    	<div id="divUpdate">
	    	<select id="sel_table">
	    		<option value="0">테이블을 선택하세요.</option>
			    <option value="FormInstance">jwf_forminstance</option>
			    <option value="Process">jwf_process</option>
			    <option value="ProcessDesc">jwf_processdescription</option>
			    <option value="DomainData">jwf_domaindata</option>
			    <option value="WorkItem">jwf_workitem</option>
			    <option value="Performer">jwf_performer</option>
			    <!-- <option value="CirculationBox">jwf_circulationbox</option>
			    <option value="CirculationBoxDesc">jwf_circulationboxdescription</option> -->
			</select>
			<select id="sel_column">
			    <option value="0">테이블을 선택하세요.</option>
			</select>
			<select id="sel_datatype">
				<option value="string">문자형</option>
			    <option value="int">숫자형</option>
			</select>
			<textarea id="txt_target" rows="5" style="width:90%;padding:3px;"></textarea><br/>
			where 절 key : 
			<select id="sel_column_key">
			    <option value="0">테이블을 선택하세요.</option>
			</select>
			<input type="text" id="txt_key" style="width:100px;padding:3px;"><br/>
			<input type="button" class="AXButton" onclick="encodeData('txt_target')" value="BASE64 ENCODE">
	   		<input type="button" class="AXButton Red" onclick="updateData('sel_table', 'sel_column', 'sel_column_key', 'txt_key', 'sel_datatype', 'txt_target')" value="UPDATE">
	    	<br/><br/><b>※ 완료된 건에 대하여는 activiti 정보 조회 및 재처리가 불가함</b>
    	</div>
    </div>
</div>
</body>
</html>