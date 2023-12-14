<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<link rel="stylesheet" type="text/css" href="/approval/resources/script/jsonEditor/jsoneditor.css<%=resourceVersion%>">
<script type="text/javascript" src="/approval/resources/script/jsonEditor/jsoneditor.js<%=resourceVersion%>"></script>

<div class="sadmin_pop">		 		
	<h3 class="cycleTitle" style="margin-bottom:1px;"><spring:message code="Cache.lbl_apv_legacyInfo"/></h3> <!-- 연동정보 -->
	<div id="jsoneditor_Info" style="height:32%;border: 1px solid #ddd;"></div>
	<h3 class="cycleTitle" style="margin-top:10px;margin-bottom:1px;"><spring:message code="Cache.lbl_LegacyParam"/></h3> <!-- 파라미터 -->
	<div id="jsoneditor_Param" style="height:50%;border: 1px solid #ddd;"></div>
	
	<div class="bottomBtnWrap">
		<a onclick="retryLegacy();" class="btnTypeDefault btnTypeBg mr5"><spring:message code="Cache.btn_apv_process"/></a> <!-- 재처리요청 -->
		<a onclick="closeLayer();" class="btnTypeDefault"><spring:message code="Cache.btn_Close"/></a> <!-- 닫기 -->
	</div>
	
</div>

<script>
	const sID = "${param.ID}"; //  CFN_GetQueryString("ID")=="undefined"? "" : CFN_GetQueryString("ID");
	const sState = "${param.State}";
	const sIndex = "${param.Index}";
	var strLegacyInfo = parent.myGrid.list[sIndex].LegacyInfo;
	var strParameters = parent.myGrid.list[sIndex].Parameters;
	var jsonLegacyInfo = (typeof strLegacyInfo === "string" && strLegacyInfo.trim() != "") ? JSON.parse(strLegacyInfo) : strLegacyInfo;
	var jsonParameters = (typeof strParameters === "string" && strParameters.trim() != "") ? JSON.parse(strParameters) : strParameters;
		
	var container_Info = document.getElementById('jsoneditor_Info');
	var container_Param = document.getElementById('jsoneditor_Param');
	var options_Info = {
		mode: 'code'
		,mainMenuBar : false
		,enableTransform : false
		,enableSort : false
		,indentation : 4
	};
	var options_Param = {
		mode: 'code'
		,mainMenuBar : false
		,enableTransform : false
		,enableSort : false
		,indentation : 4
	};
	var editor_Info;
	var editor_Param;
	
	// https://jsoneditoronline.org/docs/index.html
	// config : https://github.com/josdejong/jsoneditor/blob/master/docs/api.md#configuration-options
	$(document).ready(function(){		
		// 기본 javascript bind함수가 변경되서 다시 원복 - /mail/resources/script/cmmn/cmmn.func.js
		if (Function.prototype._original_bind && Function.prototype.bind) {
			Function.prototype.bind = Function.prototype._original_bind;
		}
		
		editor_Info = new JSONEditor(container_Info, options_Info, jsonLegacyInfo);
		editor_Param = new JSONEditor(container_Param, options_Param, jsonParameters);
	});
	
	function retryLegacy(){
		var getLegacyInfo;
		var getParameters;
	
		try{ getLegacyInfo = editor_Info.get(); getLegacyInfo = JSON.stringify(getLegacyInfo); }catch (e){
			Common.Warning('<spring:message code="Cache.lbl_apv_legacyInfo"/>' + " json parsing Error!!"); // 연동정보
			return false;
		}
		try{ getParameters = editor_Param.get(); getParameters = JSON.stringify(getParameters); }catch (e){
			Common.Warning('<spring:message code="Cache.lbl_LegacyParam"/>' + " json parsing Error!!"); // 파라미터
			return false;
		}
		
		if(sState == "SUCCESS"){
			var randomStr = new String(Math.round(coviCmn.random() * 100000));
			var msg1 = '<spring:message code="Cache.msg_apv_warnLegacyComplete"/>'; // 연동처리 완료된 데이터입니다!!
			var msg2 = '<spring:message code="Cache.msg_apv_warnLegacyRetry"/>'; // 재처리요청시 괄호안 코드를 입력해주세요.
			var msg3 = '<spring:message code="Cache.msg_apv_legacyRetryCode"/>'; // 재처리 요청코드
			Common.Prompt("<font color='red'>"+msg1+"</font>\n"+msg2, null, msg3+" ("+randomStr+")", function(inputStr){
				if(inputStr != null){
					if(randomStr == inputStr){
						__retryLegacy(getLegacyInfo, getParameters);	
					}else{
						alert('<spring:message code="Cache.msg_apv_checkRetryCode" />'); // 재처리 요청코드를 정확히 입력해주세요.
						retryLegacy();
					}
				}
			});
		}else{
			var msg = String.format(Common.getDic("msg_SureWantTo"), Common.getDic("btn_apv_process")); // 재처리요청 하시겠습니까?
			if(getLegacyInfo !== JSON.stringify(jsonLegacyInfo) || getParameters !== JSON.stringify(jsonParameters)){
				msg = '<br/><spring:message code="Cache.msg_apv_legacyChangeData"/><br/>' + msg; // 변경된 데이터가 있습니다. 
			}
			Common.Confirm(msg, "Confirm", function(result) {
				if(result){
					__retryLegacy(getLegacyInfo, getParameters);
				}
			});
		}
	}
	
	function __retryLegacy(getLegacyInfo, getParameters){
		$.ajax({
			type:"POST",
			url : "/approval/legacy/reExecuteCommonLegacy.do",
			data : {
				"LegacyInfo": Base64.utf8_to_b64(getLegacyInfo),
				"Parameters": Base64.utf8_to_b64(getParameters),
    			"LegacyHistoryID" : sID 
			},
			dataType: "json", // 데이터타입을 JSON형식으로 지정
			success:function(res){
				if(res.status && res.status == 'SUCCESS'){
					Common.Inform("<spring:message code='Cache.msg_apv_alert_006' />", "Information", function(){ //성공적으로 처리 되었습니다.
						parent.searchConfig();
						closeLayer();
					});
    			} else {
    				if(res.message) {
	    				Common.Error(res.message, "Error", function(){
							parent.searchConfig();
							closeLayer();
						});
	    			}
    				else {
    					Common.Error(res, "Error", function(){
							parent.searchConfig();
							closeLayer();
						});
	    			}
    			}	
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/legacy/reExecuteCommonLegacy.do", response, status, error);
			}
		});
	}
	
	//닫기 버튼 클릭
	function closeLayer(){
		Common.Close();
	}
	
</script>