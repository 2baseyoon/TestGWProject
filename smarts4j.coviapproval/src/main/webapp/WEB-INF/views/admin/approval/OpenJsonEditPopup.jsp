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
<div id="jsoneditor" style="height:95%"></div>
<div class="popBtn" style="background-color: white; bottom: 0px; position: fixed; text-align:center;">
	<a onclick="retryLegacy();" class="btnTypeDefault btnTypeBg mr5"><spring:message code="Cache.btn_apv_process"/></a> 
	<a onclick="closeLayer();" class="btnTypeDefault"><spring:message code="Cache.btn_Close"/></a>
</div>

<script>
	var searchMode = "${param.searchMode}";
	var searchIndex = "${param.index}";
	var searchState = "${param.searchState}";
	var pLegacyID = "${param.pLegacyID}";
	var arrParsekey = [];
	var container = document.getElementById('jsoneditor')
	var options = {
		mode: 'code'
		,mainMenuBar : false
		,enableTransform : false
		,enableSort : false
		,indentation : 4
	};
	// https://jsoneditoronline.org/docs/index.html
	// config : https://github.com/josdejong/jsoneditor/blob/master/docs/api.md#configuration-options
	var origonJsonEncoded = parent.myGrid.list[searchIndex].Parameters;
	var jsonStr = decodeLegacyParameters(searchMode, origonJsonEncoded);
	var json = JSON.parse(jsonStr);
	var editor;

	//"start" 이력은 Parameter JSON 형태가 다르므로 재처리기능 미제공(불가)
	if(searchState == "start"){
		$(".btnTypeBg").css("display", "none");
	}
	
	$(document).ready(function(){		
		// 기본 javascript bind함수가 변경되서 다시 원복 - /mail/resources/script/cmmn/cmmn.func.js
		if (Function.prototype._original_bind && Function.prototype.bind) {
			Function.prototype.bind = Function.prototype._original_bind;
		}
		
		editor = new JSONEditor(container, options, json);
	});
	
	//닫기 버튼 클릭
	function closeLayer(){
		Common.Close();
	}
	
	function retryLegacy(){
		if(searchState == "complete"){
			var randomStr = new String(Math.round(coviCmn.random() * 100000));
			var msg1 = '<spring:message code="Cache.msg_apv_warnLegacyComplete"/>'; // 연동처리 완료된 데이터입니다!!
			var msg2 = '<spring:message code="Cache.msg_apv_warnLegacyRetry"/>'; // 재처리요청시 괄호안 코드를 입력해주세요.
			var msg3 = '<spring:message code="Cache.msg_apv_legacyRetryCode"/>'; // 재처리 요청코드
			Common.Prompt("<font color='red'>"+msg1+"</font>\n"+msg2, null, msg3+" ("+randomStr+")", function(inputStr){
				if(inputStr != null){
					if(randomStr == inputStr){
						__retryLegacy();	
					}else{
						alert('<spring:message code="Cache.msg_apv_checkRetryCode" />'); // 재처리 요청코드를 정확히 입력해주세요.
						retryLegacy();
					}
				}
			});
		}else{
			var msg = String.format(Common.getDic("msg_SureWantTo"), Common.getDic("btn_apv_process")); // ~ 하시겠습니까?
			if(JSON.stringify(editor.get())  !== jsonStr){
				msg = '<br/><spring:message code="Cache.msg_apv_legacyChangeData"/><br/>' + msg; // 변경된 데이터가 있습니다. 
			}
			Common.Confirm(msg, "Confirm", function(result) {
				if(result){
					__retryLegacy();
				}
			});
		}
	}
	
	function __retryLegacy(){
		var getJsonVal;
		try{ 
			getJsonVal = editor.get();
		}catch (e){
			Common.Warning("json parsing Error!!");
			return false;
		}
		
		var dataInfo = encodeLegacyParameters(searchMode, JSON.stringify(getJsonVal));
		if(searchMode == 'MESSAGE'){
			$.ajax({
	    		url:"/approval/legacy/setmessage.do",
	    		data: {
	    			"MessageInfo" : dataInfo,
	    			"LegacyID" : pLegacyID 
	    		},
	    		type:"post",
	    		dataType : "json",
	    		success:function (res) {
	    			if(res.status == 'SUCCESS'){
	    				Common.Inform("<spring:message code='Cache.msg_apv_alert_006' />", "Information", function(){ //성공적으로 처리 되었습니다.
	    					parent.searchConfig();
	    					closeLayer();
						});
	    			} else {
	    				if(res.message) {
		    				Common.Error(res.message);
		    			}
	    				else {
		    				Common.Error(res);
		    			}
	    			}			
	    		},
	    		error:function(response, status, error){
					CFN_ErrorAjax("/approval/legacy/setmessage.do", response, status, error);
				}
	    	});
		} else if(searchMode == 'LEGACY'){
			$.ajax({
				type:"POST",
				url : "/approval/legacy/executeLegacy.do",
				data : {
					"LegacyInfo": Base64.utf8_to_b64(dataInfo),
	    			"LegacyID" : pLegacyID 
				},
				dataType: "json", // 데이터타입을 JSON형식으로 지정
				success:function(res){
					if(res == 'OK'){
						Common.Inform("<spring:message code='Cache.msg_apv_alert_006' />", "Information", function(){ //성공적으로 처리 되었습니다.
							parent.searchConfig();
							closeLayer();
						});
	    			} else {
	    				if(res.message) {
		    				Common.Error(res.message);
		    			}
	    				else {
		    				Common.Error(res);
		    			}
	    			}	
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/approval/legacy/executeLegacy.do", response, status, error);
				}
			});
		}else if(searchMode == 'DISTRIBUTION'){
			$.ajax({
				type:"POST",
				url : "/approval/legacy/startDistribution.do",
				data : {
					"DistributionInfo": dataInfo,
	    			"LegacyID" : pLegacyID 
				},
				dataType: "json", // 데이터타입을 JSON형식으로 지정
				success:function(res){
					if(res.status == 'SUCCESS'){
						Common.Inform("<spring:message code='Cache.msg_apv_alert_006' />", "Information", function(){ //성공적으로 처리 되었습니다.
							parent.searchConfig();
							closeLayer();
						});
	    			} else {
	    				if(res.message) {
		    				Common.Error(res.message);
		    			}
	    				else {
		    				Common.Error(res);
		    			}
	    			}	
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/approval/legacy/startDistribution.do", response, status, error);
				}
			});
		}
	}
	
	function encodeLegacyParameters(searchMode, data){
		var ret;
		var json = JSON.parse(data);
		
		if(searchMode == 'LEGACY'){
			if($.isArray(json)){
				ret = [];
				$.each(json, function(i, item) {
					var jsonO = {};
					for (var key in item){
						if(arrParsekey.includes(key)){
							jsonO[key] = Base64.utf8_to_b64(JSON.stringify(item[key]));
						}else{
							jsonO[key] = Base64.utf8_to_b64(item[key]);
						}
					}
					ret.push(jsonO);
				});
			} else {
				ret = {};
				for (var key in json){
					if(arrParsekey.includes(key)){
						ret[key] = Base64.utf8_to_b64(JSON.stringify(json[key]));
					}else{
						ret[key] = Base64.utf8_to_b64(json[key]);
					}
				}
			}
		}else{
			ret = json;
		}
		
		return JSON.stringify(ret);
	}

	function decodeLegacyParameters(searchMode, data){
		var ret;
		var json = typeof data === "string" ? JSON.parse(data) : data;
		
		if(searchMode == 'LEGACY'){
			if($.isArray(json)){
				ret = [];
				$.each(json, function(i, item) {
					var jsonO = {};
					for (var key in item){
						jsonO[key] = JsonParseTry(key, Base64.b64_to_utf8(item[key]));
					}
					ret.push(jsonO);
				});
			} else {
				ret = {};
				for (var key in json){
					ret[key] = JsonParseTry(key, Base64.b64_to_utf8(json[key]));
				}
			}
		}else{
			ret = json;
		}
		
		return JSON.stringify(ret);
	}
	
	function JsonParseTry(key, data){
		var returnVal;
		try {
			returnVal = JSON.parse(data);
			arrParsekey.push(key);
		} catch (e) {
			returnVal = data;
		}
		return returnVal;
	}
</script>