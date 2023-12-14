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
	<div id="jsoneditor_Info" style="height:40%;border: 1px solid #ddd;"></div>
	<h3 class="cycleTitle" style="margin-top:10px;margin-bottom:1px;"><spring:message code="Cache.lbl_LegacyParam"/></h3> <!-- 파라미터 -->
	<div id="jsoneditor_Param" style="height:40%;border: 1px solid #ddd;"></div>
	
	<div class="bottomBtnWrap">
		<a onclick="legacyCheckManager.retryLegacy();" class="btnTypeDefault btnTypeBg mr5">Call</a>
		<a onclick="legacyCheckManager.closeLayer();" class="btnTypeDefault"><spring:message code="Cache.btn_Close"/></a> <!-- 닫기 -->
	</div>
	
</div>

<script>
	var legacyCheckManager;
	$(document).ready(function(){		
		legacyCheckManager = new LegacyCheckManager();
		legacyCheckManager.init();
	});
	
	function LegacyCheckManager () {
		var editor_Info;
		var editor_Param;
			
		//Const
		this.init = function () {
			setDataControl();
		};
		
		var setDataControl = function () {
			var jsonLegacyInfo = parent.legacyIfConfigManage.makeJSONData();
			var jsonParameters = {};

			jsonParameters.apvMode = jsonLegacyInfo.ApvMode;
			
			$.each(Object.keys(jsonLegacyInfo.ExtInfo), function(i,key){
			    jsonLegacyInfo[key] = jsonLegacyInfo.ExtInfo[key];
			});
			// 불필요 정보 삭제 (재처리시 혼돈우려)
			delete jsonLegacyInfo.ExtInfo;
			delete jsonLegacyInfo.SchemaID;
			delete jsonLegacyInfo.ApvMode;
			delete jsonLegacyInfo.Seq;
			delete jsonLegacyInfo.ErrorOnFail; // 테스트일땐 throw 없이 결과 보여주도록

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
			
			// https://jsoneditoronline.org/docs/index.html
			// config : https://github.com/josdejong/jsoneditor/blob/master/docs/api.md#configuration-options
			// 기본 javascript bind함수가 변경되서 다시 원복 - /mail/resources/script/cmmn/cmmn.func.js
			if (Function.prototype._original_bind && Function.prototype.bind) {
				Function.prototype.bind = Function.prototype._original_bind;
			}
			editor_Info = new JSONEditor(container_Info, options_Info, jsonLegacyInfo);
			editor_Param = new JSONEditor(container_Param, options_Param, jsonParameters);
		};

	    
		this.retryLegacy = function () {
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
			
			$.ajax({
				type:"POST",
				url : "/approval/legacy/checkExecuteCommonLegacy.do",
				data : {
					"LegacyInfo": Base64.utf8_to_b64(getLegacyInfo),
					"Parameters": Base64.utf8_to_b64(getParameters)
				},
				dataType: "json", // 데이터타입을 JSON형식으로 지정
				success:function(res){
					if(res.legacyCheckStatus && res.legacyCheckStatus == 'SUCCESS'){
						var txtRes = "State : " + res.State;
						if(res.ResultCode) txtRes += "\r\n\r\nResultCode : " + res.ResultCode;
						if(res.ResultMessage) txtRes += "\r\n\r\nResultMessage : " + res.ResultMessage;
						if(res.RawResponse) txtRes += "\r\n\r\nRawResponse : " + res.RawResponse;
						if(res.ErrorStackTrace) txtRes += "\r\n\r\nErrorStackTrace : " + res.ErrorStackTrace;
						
						Common.open("","CallResult", "Call Result", "<textarea style='font-family:Consolas;resize:none;width:100%;height:100%;line-height:130%;padding:20px; text-align:left' readonly>"+txtRes+"</textarea>", "900px","530px","html", true, null, null, true);
	    			} else {
	    				if(res.legacyCheckMessage) {
		    				Common.Error(res.legacyCheckMessage);
		    			}
	    				else {
		    				Common.Error(res);
		    			}
	    			}	
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/approval/legacy/checkExecuteCommonLegacy.do", response, status, error);
				}
			});
			
		};
		
		
		this.closeLayer = function() {
			Common.Close();
		};
		
	}
	
</script>