<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="/covicore/resources/script/codemirror/5.39.0/codemirror.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/codemirror/5.39.0/mode/xml/xml.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/codemirror/5.39.0/mode/javascript/javascript.min.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/codemirror/5.39.0/mode/sql/sql.min.js<%=resourceVersion%>"></script>
<link rel="stylesheet" type="text/css" href="/covicore/resources/script/codemirror/5.39.0/codemirror.min.css<%=resourceVersion%>">

<script  type="text/javascript">
var legacyIfConfigManage;
$(document).ready(function(){		
	window.legacyIfConfigManage = new LegacyIfConfigManage();
	legacyIfConfigManage.init();
});

function LegacyIfConfigManage() {
	var apvModeTree;
	var configListGrid;
	var schemaID = '<c:out value="${param.SchemaID}" />';
	var domainID = '<c:out value="${param.DomainID}" />';
	
	this.getSchemaID = function () {
		return schemaID == "undefined" ? "" : schemaID;
	};
	
	// 레이어 팝업 닫기
	var closeLayer = function() {
		Common.Close();	
	};
	this.init = function () {
		apvModeTree = new coviTree();
		initApvModeList();
		
		initConfigListGrid();
		// sql poolName list
		$.ajax({
			url : "/covicore/dbsync/getDatasourceSelectData.do",
			type:"POST",
			data:{},
			success:function (data) {
				if(data && data.list) {
					var len = data.list.length;
					for(var idx = 0; idx < len; idx++) {
						var info = data.list[idx];
						$("#PoolName").append("<option value='"+ info.optionValue +"'>" + info.optionText + "</option>");
					}
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("getDatasourceSelectData.do", response, status, error);
			}
		});
	};
	
	var initApvModeList = function() {
	    var treeBody = {
	            onclick:function(){
	                 var obj = apvModeTree.getSelectedList();
	                 onclickLegacyApvMode(obj.item.ApvMode);
	            }
		};
		
		var treeColGroup = [{
		    key: "Name",
		    width: "190",
		    align: "left",
		    indent: true,
		    getIconClass: function(){
		        return "ic_file";
		    },
		    formatter:function(){
		        return CFN_GetDicInfo(this.item.Name);
		    }
		}];
		
		apvModeTree.setTreeConfig("apvModeTreeWrapper", "pno", "no", false, false, treeColGroup, treeBody);
		var apvModeList = [];
		apvModeList.push({Name:"<spring:message code='Cachel.lbl_apv_setschema_94' />", ApvMode:"DRAFT"});
		apvModeList.push({Name:"<spring:message code='Cachel.lbl_apv_setschema_95' />", ApvMode:"COMPLETE"});
		apvModeList.push({Name:"<spring:message code='Cachel.lbl_apv_setschema_141' />", ApvMode:"DISTCOMPLETE"});
		apvModeList.push({Name:"<spring:message code='Cachel.lbl_apv_setschema_96' />", ApvMode:"REJECT"});
		apvModeList.push({Name:"<spring:message code='Cachel.lbl_apv_setschema_97' />", ApvMode:"CHARGEDEPT"});
		apvModeList.push({Name:"<spring:message code='Cachel.lbl_apv_setschema_121' />", ApvMode:"OTHERSYSTEM"});
		apvModeList.push({Name:"<spring:message code='Cachel.lbl_apv_setschema_132' />", ApvMode:"WITHDRAW"});
		apvModeTree.setList(apvModeList);
	};
	
	var initConfigListGrid = function(){
		configListGrid = new coviGrid();
		configListGrid.config.fitToWidthRightMargin = 0;
		
		// 헤더 설정
		var headerData =[
		                  {key:'Seq', label:'<spring:message code="Cache.lbl_apv_no"/>', width:'50', align:'center', sort:false, colHeadTool : false},
		                  {key:'ProgramName', label:'<spring:message code="Cache.lbl_SettingName"/>', width:'110', align:'center', sort:false, colHeadTool : false},
		                  {key:'IfType', label:'<spring:message code="Cache.lbl_apv_type"/>',   width:'80', align:'center' , sort:false, colHeadTool : false},
		                  {key:'IsUse', label:'<spring:message code="Cache.IsUse_Y"/>',   width:'50', align:'center', sort:false, colHeadTool : false}
			      		];
		
		configListGrid.setGridHeader(headerData);
		setGridConfig();
		
		// 그리드 Config 설정
		function setGridConfig(){
			var configObj = {
				targetID : "ConfigListGrid", 
				height:"auto",
				body: {
					onclick:function(idx, item){
						legacyIfConfigManage.loadConfigDetail(item.LegacyConfigID);
					}
				}
			};
			configListGrid.setGridConfig(configObj);
			
			$("#apvModeTreeWrapper_AX_treeBody").find(".gridBodyTr_0").find(".bodyNode").click();
		}
	};
	
	var onclickLegacyApvMode = function(apvMode) {
		// public method
		legacyIfConfigManage.loadConfigList(apvMode);
		$("#ConfigDetail").hide();
	};
	
	this.loadConfigList = function (v_apvMode) {
		$("input[id=ApvMode]").val(v_apvMode);
		
		var bindUrl = "/approval/manage/getLegacyConfigList.do";
		$("#ConfigAddBtn").show();
		configListGrid.setList({
			ajaxUrl:bindUrl,
 			ajaxPars:{
				"SchemaID" : legacyIfConfigManage.getSchemaID()				
				,"ApvMode" : v_apvMode				
 			}
		});
		configListGrid.reloadList();
	};
	
	this.loadConfigDetail = function (v_LegacyConfigID){
		$("#ConfigDetail").show();
		if(!v_LegacyConfigID || v_LegacyConfigID == "") {
			$("#useDeleteBtnArea").hide();
			$("input[id=LegacyConfigID]").val("");
			resetForm();
			legacyIfConfigManage.onChangeIfType();
		}else{
			$("#useDeleteBtnArea").show();
			resetForm();
			$("input[id=LegacyConfigID]").val(v_LegacyConfigID);
			setModifyData(v_LegacyConfigID);
		}
	};
	
	/**
	* 기존설정내용 셋팅
	*/
	var setModifyData = function(LegacyConfigID) {
		if(!LegacyConfigID || LegacyConfigID == "") return;
		$.ajax({
			type:"POST",
			data:{
				"LegacyConfigID" : LegacyConfigID
			},
			url:"/approval/manage/getLegacyConfigList.do",
			success:function (data) {
				if(data.status == "SUCCESS" && data.list.length == 1){
					var info = data.list[0];
					var ifType = info.IfType;
					var extInfo = info.ExtInfo;
					if(ifType == "SOAP") {
						ifType = ifType + "_" + extInfo["SoapType"];
					}
					$("#IfType").val(ifType).trigger("change");
					
					for(var key in info){
						if(key != "ExtInfo") {
							if($("#"+key+".MainInfo", ".Section_"+ifType).length == 1) {
								if(ifType == "HTTP" && key == "HttpParams") {
									// Multirow 셋팅 (HttpParams)
									var httpParams = info[key];
									var idx = 0;
									for(var key in httpParams) {
										var val = httpParams[key];
										// add row
										if(idx > 0) {
											legacyIfConfigManage.addParamsRow();
										}  
										// set value
										var $lastRow = $("table#HttpParams").find("tr:last");
										$lastRow.find("input[name=httpParamKey]").val(key);
										$lastRow.find("input[name=httpParamValue]").val(val);
										
										idx ++;
									}
								}else{
									var settingValue = info[key];
									if(typeof info[key] == "object" && info[key] != null) {
										try {
											if(key == "WSRequestObjectInfo") {
												settingValue = JSON.stringify(info[key],null,4);
											}else{
												settingValue = JSON.stringify(info[key]);
											}
										}catch(e) { coviCmn.traceLog(e); }
									}
									var $item = $("#"+key+".MainInfo", ".Section_"+ifType);
									if($item.prop("type") == "checkbox"){
										$item.prop("checked", settingValue == "Y" ? true : false);
									}else{
										$item.val(settingValue || "");
									}
									if($item.hasClass("code_editor")){
										// codemirror editor 셋팅.
										legacyIfConfigManage.codeEditors[key].getDoc().setValue(settingValue);
									}
								}
							}
						}
						if(key == "IsUse"){
							var isUse = info[key]; // Y,N
							$("input#IsUse").val(isUse);
							if(isUse == "Y") $("a#IsUse").addClass("on");
							else $("a#IsUse").removeClass("on");
						}
					}
					for(var key in extInfo) {
						if($("#"+key+".ExtInfo", ".Section_"+ifType).length == 1) {
							var settingValue = extInfo[key];
							if(typeof extInfo[key] == "object") {
								try {
									settingValue = JSON.stringify(extInfo[key]);
								}catch(e) { coviCmn.traceLog(e); }
							}
							$("#"+key+".ExtInfo", ".Section_"+ifType).val(settingValue);
							if($("#"+key+".ExtInfo", ".Section_"+ifType).hasClass("code_editor")){
								// codemirror editor 셋팅.
								legacyIfConfigManage.codeEditors[key].getDoc().setValue(settingValue);
							}
						}
					}
					
				}else{
					CFN_ErrorAjax("getLegacyConfigList.do");	
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("getLegacyConfigList.do", response, status, error);
			}
		});
	}

	var resetForm = function () {
		document.forms[0].reset();
		$("#FormID,#FormPrefix").val("");
		
		//editor 
		var editors = legacyIfConfigManage.codeEditors;
		for(var key in editors) {
			editors[key].getDoc().setValue("");
		}
		
		// multirow reset
		$("#ConfigDetail").find("tr.clonedTR").remove();
	};
	
	this.onChangeIfType = function () {
		var selectedIfType = $("select#IfType").val();
		$("#ConfigDetail").find(".Section").hide();
		$("#ConfigDetail").find(".Section_"+selectedIfType).show();
		
		if(selectedIfType == "SP") {
			$("select#SqlType").prop("disabled", true);
		}else{
			$("select#SqlType").prop("disabled", false);
		}
		
		var $visibleEditor = $(".code_editor", ".Section_"+selectedIfType);
		if($visibleEditor.length > 0) {
			legacyIfConfigManage.loadCodeEditor($visibleEditor);
		}
	};
	
	var formValidate = function (){
		var rtn = new Object();
		var bCheck = true;
		var selectedIfType = $("select#IfType").val();
		$("input[type=text].required,textarea.required,select.required", ".Section_"+selectedIfType).each(function(){
			if(this.tagName.toLowerCase() == "textarea" && $(this).hasClass("code_editor")) {
				if(legacyIfConfigManage.codeEditors[this.id]){
					legacyIfConfigManage.codeEditors[this.id].save(); // editor to textarea
				} 
			}
			if($(this).val() == "") {
				var _title = $(this).prev("label").attr("title");
				if(!_title || _title == "") {
					_title = $(this).prev("label").text();
				}
				rtn.msg = Common.getDic("msg_EnterTheRequiredValue").replace("{0}", _title);
				rtn.obj = this;
				bCheck = false;
				return false;
			}
		});
		
		
		if(bCheck == false) return rtn;
		rtn.msg = "OK";
		return rtn;
	}
	
	this.saveConfig = function () {
		var rtn = formValidate();
		if(rtn.msg != "OK") {
			Common.Warning(rtn.msg, "Warning", function() {
				if(rtn.obj) rtn.obj.focus();
			});
			return;
		}
		Common.Confirm('<spring:message code="Cache.msg_RUSave"/>', 'Confirm', function (result) {
			if(result){
				var configData = legacyIfConfigManage.makeJSONData();
				$.ajax({
					type:"POST",
					data: {"ConfigData" : JSON.stringify(configData)},
					url:"/approval/manage/saveLegacyConfig.do",
					success:function (data) {
						if(data.status == "SUCCESS") {
							var v_apvMode = $("input[id=ApvMode]").val();
							legacyIfConfigManage.loadConfigList(v_apvMode);
						}else{
							CFN_ErrorAjax("saveLegacyConfig.do");	
						}
					},
					error:function(response, status, error){
						CFN_ErrorAjax("saveLegacyConfig.do", response, status, error);
					}
				});
			}// end if
		});
	};
	
	this.makeJSONData = function () {
		if("" == $("#ApvMode").val()) {
			throw "apvmode is null";
		}
		
		var data = {};
		var extInfo = {};
		var IfType = $("#IfType").val();
		$(".Section_" + IfType).find("input,select,textarea").each(function (idx){
			if(this.id){ // 불필요 dom 제거 - <textarea autocorrect="off" autocapitalize="off" spellcheck="false"...
				var isExtInfo = $(this).hasClass("ExtInfo");
				var isMainInfo = $(this).hasClass("MainInfo");
				/*if(this.tagName.toLowerCase() == "textarea" && $(this).hasClass("code_editor")) {
					if(legacyIfConfigManage.codeEditors[this.id]){
						legacyIfConfigManage.codeEditors[this.id].save(); // editor to textarea
					} 
				}*/
				if(isExtInfo){
					extInfo[this.id] = this.value;
				}else{
					if(this.type == "checkbox"){
						data[this.id] = this.checked ? this.value : "";
					}else{
						data[this.id] = this.value;
					}
				}
			}
		});
		data["ExtInfo"] = extInfo;
		
		
		// Manual Settings Values.
		data["SchemaID"] = legacyIfConfigManage.getSchemaID();
		data["IfType"] = IfType.indexOf("_") > -1 ? IfType.split("_")[0] : IfType;
		data["ApvMode"] = $("#ApvMode").val();
		// FIXME
		// find Max Sequence
		var __configList = configListGrid.getList();
		var __maxSeq = 0;
		for(var j = 0; j < __configList.length; j++) {
			__maxSeq = Math.max(__maxSeq, Number(__configList[j].Seq));
		}
		data["Seq"] = __maxSeq + 1;
		data["LegacyConfigID"] = $("#LegacyConfigID").val();
		
		// Multirow Table data ( Http Parameters )
		var httpParams = {};
		$("table#HttpParams").find("tr").each(function (idx) {
			if($(this).find("input").length > 0){
				var key = $(this).find("[name=httpParamKey]").val();
				var val = $(this).find("[name=httpParamValue]").val();
				
				httpParams[key] = val;
			}
		});
		data["HttpParams"] = httpParams;
		
		return data;
	};
	
	this.codeEditors = {};
	this.loadCodeEditor = function ($visibleEditors) {
		// Initialize Code Editor
		$visibleEditors.each(function (idx) {
			if(legacyIfConfigManage.codeEditors[this.id]) {
				return;
			}
			
			var mode = "xml";
			if (this.id == "HttpBody") {
				var bodyType = $("#BodyType").val(); // XML/JSON
				mode = bodyType == "XML" ? "application/xml" : "application/json";
			}else if(this.id == "SqlClause") {
				mode = "text/x-sql";
			}else if(this.id == "WSRequestXML") {
				mode = "application/xml";
			}else{
				mode = "application/json";
			}
			legacyIfConfigManage.codeEditors[this.id] = CodeMirror.fromTextArea(this, {
			  	mode : mode
			  	,theme : "default"
				,lineNumbers: true
			 	,lineWrapping: true
			});
			legacyIfConfigManage.codeEditors[this.id].setSize("100%", "200px");
		});
	};
	
	this.onChangeHttpBodyType = function (){
		var editorName = "HttpBody";
		if(legacyIfConfigManage.codeEditors[editorName]) {
			var bodyType = $("#BodyType").val(); // XML/JSON
			var mode = bodyType == "XML" ? "application/xml" : "application/json";
			legacyIfConfigManage.codeEditors[editorName].setOption("mode", mode);
		}
	};
	
	this.addParamsRow = function() {
		var $tbl = $("table#HttpParams");
		var srcRow = $("table#HttpParams").find("#fRow");
		var cloneHtml = srcRow.html();
		$tbl.find("tbody").append("<tr class='clonedTR'>" + cloneHtml + "</tr>");
		$tbl.find("tbody").find("tr:last").find("input").val("");
	};
	
	this.removeParamsRow = function() {
		var $tbl = $("table#HttpParams");
		var checks = $tbl.find("input.check[type=checkbox]:checked");
		if(checks && checks.length > 0) {
			for(var i = checks.length - 1; i  >= 0; i--) {
				var row = $(checks[i]).closest("tr");
				if("fRow" != row.prop("id")) {// First Row
					$(checks[i]).closest("tr").remove();
				}
			}
		}
	};
	
	/**
	* Get Templates envelope XML from WSDL URL
	*/
	this.getSoapEnvelopeTemplates = function() {
		var wsdlUrl = $("#WSDLUrl", ".Section_SOAP_XML").val();
		var operationName = $("#OperationName", ".Section_SOAP_XML").val();
		if(wsdlUrl == "") {
			Common.Warning("WSDL URL 을 입력해 주세요.", "Warning", function(){
				$("#WSDLUrl", ".Section_SOAP_XML").focus();
			});
			return;
		}
		if(operationName == "") {
			Common.Warning("OperationName 을 입력해 주세요.", "Warning", function(){
				$("#OperationName", ".Section_SOAP_XML").focus();
			});
			return;
		}
		$.ajax({
			type:"POST",
			data:{
				"WSDLUrl" : wsdlUrl
				,"OperationName" : operationName
			},
			url:"/approval/manage/getEnvelopeTemplates.do",
			success:function (data) {
				if(data.status == "SUCCESS"){
					//$wrapper.append("<a class='btnTypeDefault' onclick='legacyIfConfigManage.loadConfigDetail(\"\")'>+</div>");
					var xml = data.TemplateXML;
					legacyIfConfigManage.codeEditors["WSRequestXML"].getDoc().setValue(xml);
				}else{
					CFN_ErrorAjax("getEnvelopeTemplates.do", data.status);	
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("getEnvelopeTemplates.do", response, status, error);
			}
		});
	};
	
	/**
	* Get Request Info(JSON using ObjectMapper.java) from WSDL URL
	*/
	this.getRequestObjectFromWSDL = function() {
		var wsdlUrl = $("#WSDLUrl", ".Section_SOAP_WSDL").val();
		var operationName = $("#OperationName", ".Section_SOAP_WSDL").val();
		if(wsdlUrl == "") {
			Common.Warning("WSDL URL 을 입력해 주세요.", "Warning", function (){
				$("#WSDLUrl", ".Section_SOAP_WSDL").focus();
			});
			return;
		}
		if(operationName == "") {
			Common.Warning("OperationName 을 입력해 주세요.", "Warning", function() {
				$("#OperationName", ".Section_SOAP_WSDL").focus();
			});
			return;
		}
		$.ajax({
			type:"POST",
			data:{
				"WSDLUrl" : wsdlUrl
				,"OperationName" : operationName
			},
			url:"/approval/manage/getRequestObjectFromWSDL.do",
			success:function (data) {
				if(data.status == "SUCCESS"){
					//$wrapper.append("<a class='btnTypeDefault' onclick='legacyIfConfigManage.loadConfigDetail(\"\")'>+</div>");
					var argumentsInfoArray = data.SerializedTemplate;
					var prettyJson = JSON.stringify(argumentsInfoArray,null,4);
					legacyIfConfigManage.codeEditors["WSRequestObjectInfo"].getDoc().setValue(prettyJson);
				}else{
					CFN_ErrorAjax("getRequestObjectFromWSDL.do", data.status);	
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("getRequestObjectFromWSDL.do", response, status, error);
			}
		});
	};
	
	/**
	* 삭제
	*/
	this.deleteConfig = function () {
		Common.Confirm('<spring:message code="Cache.msg_RUDelete"/>', 'Confirm', function (result) {
			if(result){
				$.ajax({
					type:"POST",
					data: {"LegacyConfigID" : $("#LegacyConfigID").val()},
					url:"/approval/manage/deleteLegacyConfig.do",
					success:function (data) {
						if(data.status == "SUCCESS") {
							// Reload ConfigList
							var v_apvMode = $("input[id=ApvMode]").val();
							legacyIfConfigManage.loadConfigList(v_apvMode);
						}else{
							CFN_ErrorAjax("deleteLegacyConfig.do", data.status);	
						}
					},
					error:function(response, status, error){
						CFN_ErrorAjax("deleteLegacyConfig.do", response, status, error);
					}
				});
			}// end if
		});
	};
	
	this.changeIsUse = function() {
		var IsUseVal = $("input#IsUse").val() == "Y" ? "N" : "Y";
		$.ajax({
			type:"POST",
			data: {
				"IsUse" : IsUseVal,
				"LegacyConfigID" : $("#LegacyConfigID").val()
			},
			url:"/approval/manage/updateLegacyConfigUse.do",
			success:function (data) {
				if(data.status == "SUCCESS") {
					var $IsUse = $("a#IsUse");
					if(IsUseVal == "Y"){
						$IsUse.addClass('on');
					} else {
						$IsUse.removeClass('on');
					}
					$("input#IsUse").val(IsUseVal);
					
					// Reload ConfigList
					var v_apvMode = $("input[id=ApvMode]").val();
					legacyIfConfigManage.loadConfigList(v_apvMode);
				}else{
					CFN_ErrorAjax("updateLegacyConfigUse.do", data.status);	
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("updateLegacyConfigUse.do", response, status, error);
			}
		});
	};
	
	//public 항목조회 (공통/양식) 팝업 (참고)
	this.fieldSelectPopup  = function() {
		if($("#FormID").val() == "") {
			var url = "/approval/manage/goLegacyInterfaceConfigFormSelectPopup.do";
			// 양식선택 팝업
			Common.open("", "FormSelectPop","<spring:message code='Cache.lbl_apv_formchoice'/>", url, "600px", "420px", "iframe", true, null, null, true);
			return;
		}
		
		// 양식기준 항목리스트 및 공통항목 리스트 참고화면 Popup
		CFN_OpenWindow("/approval/manage/goLegacyInterfaceConfigFieldPopup.do?FormID=" + $("#FormID").val(), "LegacyInterfaceFormFieldPop", "860px", "580px");
	};
	
	this.fieldSelectReset = function(){
		$("#FormID").val("");
		$("#FormPrefix").val("");
		$("#FormName").val("");
	};
	
	this.getDomainID = function () {
		return domainID;
	};
	this.getRefFormID = function () {
		return $("#FormID").val();
	};
	
	this.setFormSelected = function (formId, formPrefix, formName) {
		if(formId != "") {
			$("#FormID").val(formId);
			$("#FormPrefix").val(formPrefix);
			$("#FormName").val(CFN_GetDicInfo(formName));
			
			setTimeout(function() {
				legacyIfConfigManage.fieldSelectPopup();
				
				Common.close("FormSelectPop");
			}, 50);
		}
	};
	
	//연동테스트
	this.checkExecuteLegacy  = function() {
		var rtn = formValidate();
		if(rtn.msg != "OK") {
			Common.Warning(rtn.msg, "Warning", function() {
				if(rtn.obj) rtn.obj.focus();
			});
			return;
		}
		
		var url = "/approval/manage/goLegacyInterfaceCheckPopup.do";
		Common.open("", "CallTest","Call Test", url, "1024px", "700px", "iframe", true, null, null, true);
	};
	
};

</script>
<div class="sadmin_pop"><div style="position:absolute;left:30px;right:30px;;top:30px;bottom:30px;">
	<input type="hidden" id="ApvMode" />
	<input type="hidden" id="LegacyConfigID" />
	<table class="sadmin_table" style="height:100%;width:100%;">
		<colgroup>
			<col width="220px">
			<col width="320px">
			<col id="">
		</colgroup>
		<tbody>
			<tr>
				<!-- 트리영역 -->
				<td id="ApvModeList" class="treeBtn" valign="top">
					<div class="saTreeWrap" style="width:200px;">
							<!-- 트리 아이콘 icon01 ~ icon26 -->
							<div id="apvModeTreeWrapper" class="tblList tblCont"></div>
						</div>
					</div>
				</td>
				
				
				<!-- ApvMode 별 설정목록 -->
				<td id="ConfigList" class="sadminContent" valign="top" style="text-align:right;">
					<a id="ConfigAddBtn" class='btnPlusAdd' onclick='legacyIfConfigManage.loadConfigDetail("")' style="display:none;"><spring:message code="Cache.btn_Add" /></a>
					<div id="ConfigListGrid" class="tblList" style="margin-top:5px;"></div>
				</td>
				
				
				<!-- 세부설정 -->
				<td valign="top" style="position:relative;padding:0px;">
					<div id="ConfigDetail" style="display:none; position:absolute;width:100%;height:100%;overflow:auto;padding:10px;">
					<form id="ConfigDetail_Form">
						<div style="text-align:left; border-bottom:1px solid #aaa; padding-bottom:5px; margin-bottom:5px;" >
							<spring:message code="Cache.lbl_apv_legacyType"/><!-- 연동방식 선택 -->
							<select id="IfType" class="MainInfo selectType02" onchange="legacyIfConfigManage.onChangeIfType()">
								<option value="HTTP">HTTP</option>
								<option value="SQL">SQL</option>
								<option value="SP">SP</option>
								<option value="SOAP_XML">SOAP/XML</option>
								<option value="SOAP_WSDL">SOAP/WSDL</option>
								<option value="JAVA">JAVA</option>
							</select>
							<a class="btnTypeDefault  btnTypeBg" onclick="legacyIfConfigManage.saveConfig()"><spring:message code="Cache.btn_save"/></a>
							<a class="btnTypeDefault" onclick="legacyIfConfigManage.checkExecuteLegacy()" style="margin-left:3px;"><spring:message code="Cache.btn_apv_test"/></a>
							
							<div style="float:right;">
								<spring:message code="Cache.lbl_apv_refForm" /><!-- 양식항목참고 -->
								<input type="text" id="FormName" class="w140p" readonly="readonly" />
								<input type="hidden" id="FormID" />
								<input type="hidden" id="FormPrefix" />
								<a class="btnTypeDefault btnRefresh" style="height:30px;min-width:32px;" title="<spring:message code="Cache.lbl_apv_resetRefForm"/>" onclick="legacyIfConfigManage.fieldSelectReset()"></a>
								<a class="btnTypeDefault btnDocView" style="display:inline-block;height:30px;min-width:32px;" title='<spring:message code="Cache.lbl_apv_viewFormField"/>' onclick="legacyIfConfigManage.fieldSelectPopup()">보기</a>
								<div id="useDeleteBtnArea" style="display:none; display:inline-block; margin-left:10px;">
									<input type="hidden" id="IsUse" /><!-- 사용여부 -->
									<div class="alarm type01" style="padding:0px;">
										<span>사용여부</span>
										<a href="#" id="IsUse" class="onOffBtn" onclick="legacyIfConfigManage.changeIsUse()"><span></span></a>
									</div>
									<a class="btnTypeDefault btnSaRemove" onclick="legacyIfConfigManage.deleteConfig()"><spring:message code="Cache.btn_delete"/></a>
								</div>
							</div>
						</div>
						<div class="Section Section_SP Section_SQL Section_SOAP_XML Section_SOAP_WSDL Section_HTTP Section_JAVA" style="display:none;">
							<label><spring:message code="Cache.Cache.lbl_SettingName"/></label><!-- 설정명 -->
							<input type="text" id="ProgramName" class="MainInfo required" />
						</div>
						<div class="Section Section_JAVA" style="display:none;">
							<label><spring:message code="Cache.lbl_apv_javainvokation"/></label>
							<input type="text" class="ExtInfo required" id="InvokeJavaClassName" placeholder="egovframework.covision.coviflow.legacy.invokebean.impl.WF_FORM_DRAFT"/>
						</div>
						<div class="Section Section_HTTP" style="position:relative;display:none;">
							<label><spring:message code="Cache.lbl_apv_httpUrl"/></label>
							<input type="text" class="ExtInfo required" id="HttpUrl" />
							<label>Method</label>
							<select id="Method" class="ExtInfo required selectType02" >
								<option value="POST">POST</option>
								<option value="GET">GET</option>
							</select>
							<label><spring:message code="Cache.lbl_apv_charset"/></label>
							<select id="Encoding" class="ExtInfo selectType02 required" >
								<option value="UTF-8">UTF-8</option>
								<option value="MS949">MS949</option>
								<option value="EUC-KR">EUC-KR</option>
								<option value="ISO-8859-1">ISO-8859-1</option>
							</select>
							<label>Body Type</label>
							<select id="BodyType" class="ExtInfo selectType02 required" onchange="legacyIfConfigManage.onChangeHttpBodyType()">
								<option value="JSON">JSON</option>
								<option value="XML">XML</option>
							</select>
							<label><spring:message code="Cache.lbl_apv_httpBody"/></label>
							<textarea id="HttpBody" class="MainInfo code_editor required" rows="10"></textarea>
							<label><spring:message code="Cache.lbl_apv_httpParams"/></label>
							<a href="#" onclick="legacyIfConfigManage.addParamsRow()" class="btnPlusAdd"><spring:message code="Cache.btn_Add" /></a>
							<a href="#" onclick="legacyIfConfigManage.removeParamsRow()" class="btnMinusAdd"><spring:message code="Cache.btn_Delete" /></a>
							<table style="border:none;width:100%; margin-top:10px;" id="HttpParams" class="MainInfo MultiRow">
								<colgroup>
									<col width="30px"/>
									<col width="200px"/>
									<col width=""/>
								</colgroup>
								<tr>
									<th></th>
									<th>Key</th>
									<th>Value</th>
								</tr>
								<tr id="fRow">
									<td>
										<input type="checkbox" class="check"/>
									</td>
									<td>
										<input type="text" name="httpParamKey" placeholder="ParamName"/>
									</td>
									<td>
										<input type="text" name="httpParamValue" placeholder="\${Initiator}"/>
									</td>
								</tr>
							</table>
						</div>
						<!-- ************************************************* SQL/SP ************************************************* -->
						<div class="Section Section_SQL Section_SP" style="display:none;">
							<label><spring:message code="Cache.lbl_apv_datasource"/></label>
							<select class="ExtInfo selectType02 required" id="PoolName" >
							</select>
							<label><spring:message code="Cache.lbl_apv_sqltype"/></label>
							<select class="ExtInfo selectType02 required" id="SqlType" >
								<option value="UPDATE">UPDATE</option>
								<option value="INSERT">INSERT</option>
								<option value="DELETE">DELETE</option>
								<option value="SELECT">SELECT</option>
							</select>
							<label>SQL</label>
<!-- 							<a onclick="legacyIfConfigManage.checkSqlSyntax()" class="btnTypeDefault">Check SQL Syntax</a> -->
							<textarea id="SqlClause" class="MainInfo code_editor required" rows="10"></textarea>
						</div>
						<!-- ************************************************* SOAP(by Envelope) ************************************************* -->
						<div class="Section Section_SOAP_XML" style="display:none;">
							<input type="hidden" id="SoapType" class="ExtInfo" value="XML" />
							<label><spring:message code="Cache.lbl_apv_wsdl"/></label>
							<input type="text" id="WSDLUrl" class="ExtInfo required" />
							<label><spring:message code="Cache.lbl_apv_wsendpoint"/></label>
							<input type="text" id="EndpointUrl" class="ExtInfo required" />
							<label><spring:message code="Cache.lbl_apv_wsoperation"/></label>
							<input type="text" id="OperationName" class="ExtInfo required" />
							<label><spring:message code="Cache.lbl_apv_envelopexml"/></label>
							<a onclick="legacyIfConfigManage.getSoapEnvelopeTemplates()" class="btnTypeDefault"><spring:message code="Cache.lbl_apv_loadEnvelope"/></a>
							<textarea id="WSRequestXML" class="MainInfo code_editor required" rows="10"></textarea>
						</div>
						<!-- ************************************************* SOAP(by WSDL) ************************************************* -->
						<div class="Section Section_SOAP_WSDL" style="display:none;">
							<input type="hidden" id="SoapType" class="ExtInfo" value="WSDL" />
							<label><spring:message code="Cache.lbl_apv_wsdl"/></label>
							<input type="text" id="WSDLUrl" class="ExtInfo required" />
							<label><spring:message code="Cache.lbl_apv_wsoperation"/></label>
							<input type="text" id="OperationName" class="ExtInfo required" />
							<label>Payloads</label>
							<a onclick="legacyIfConfigManage.getRequestObjectFromWSDL()" class="btnTypeDefault"><spring:message code="Cache.lbl_apv_getWsArguments"/></a>
							<textarea id="WSRequestObjectInfo" class="MainInfo code_editor required" rows="10"></textarea>
						</div>
						<!-- ************************************************* Result ************************************************* -->
						
						<div class="Section Section_SP Section_SQL Section_SOAP_XML Section_SOAP_WSDL Section_HTTP Section_JAVA" style="display:none;">
							<label><spring:message code="Cache.lbl_apv_errorOnFail"/></label>
							<input type="checkbox" id="ErrorOnFail" class="MainInfo" value="Y" />
						</div>
						<div class="Section Section_SOAP_XML" style="display:none;">
							<label><spring:message code="Cache.lbl_apv_codeXpath"/></label>
							<input type="text" id="ResponseCodeXpath" class="ExtInfo required" placeholder="//*[local-name()='changeState5Response']/return/code"/>
							<label><spring:message code="Cache.lbl_apv_msgXpath"/></label>
							<input type="text" id="ResponseMsgXpath" class="ExtInfo required" placeholder="//*[local-name()='changeState5Response']/return/msg"/>
						</div>
						<div class="Section Section_SOAP_WSDL" style="display:none;">
							<label><spring:message code="Cache.lbl_apv_codeMethod"/></label>
							<input type="text" id="ResponseCodeMethod" class="ExtInfo" placeholder="getStatus"/>
							<label><spring:message code="Cache.lbl_apv_msgMethod"/></label>
							<input type="text" id="ResponseMsgMethod" class="ExtInfo" placeHolder="getMessage"/>
							<label><spring:message code="Cache.lbl_apv_codeIndex"/></label>
							<input type="text" id="ResponseCodeIndex" class="ExtInfo" placeHolder="0"/>
							<label><spring:message code="Cache.lbl_apv_msgIndex"/></label>
							<input type="text" id="ResponseMsgIndex" class="ExtInfo" placeHolder="1"/>
						</div>
						<div class="Section Section_HTTP" style="display:none;">
							<label><spring:message code="Cache.lbl_apv_httpResType"/></label>
							<select id="ResponseBodyType" class="ExtInfo selectType02 required">
								<option value="JSON">JSON</option>
								<option value="XML">XML</option>
							</select>
						</div>
						<div class="Section Section_SP Section_HTTP" style="display:none;">
							<label><spring:message code="Cache.lbl_apv_resCodeKey"/></label>
							<input type="text" id="OutStatusKey" class="ExtInfo" />
							<label><spring:message code="Cache.lbl_apv_resMsgKey"/></label>
							<input type="text" id="OutMsgKey" class="ExtInfo" />
						</div>
						<div class="Section Section_SP Section_HTTP Section Section_SOAP_XML Section Section_SOAP_WSDL" style="display:none;">
							<label><spring:message code="Cache.lbl_apv_successCondition"/></label>
							<select class="ExtInfo selectType02" id="OutCompareType" >
								<option value="E"><spring:message code="Cache.lbl_apv_condEquals"/></option><!-- 같으면 -->
								<option value="NE"><spring:message code="Cache.lbl_apv_condNotEquals"/></option><!-- 같지않으면 -->
							</select>
							<label><spring:message code="Cache.lbl_apv_codeCompareVal"/></label>
							<input type="text" id="OutCompareValue" class="ExtInfo" placeholder="SUCCESS" />
						</div>
					</form>
					</div>
				</td>
			</tr>
		</tbody>
	</table>
</div></div>
