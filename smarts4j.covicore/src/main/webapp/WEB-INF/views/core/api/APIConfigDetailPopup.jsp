<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>
<form id="form_APIConfigInfoPop" name="form_APIConfigInfoPop">
	<div>
		<input type="hidden" id="ConfigID" name="ConfigID" />
		<input type="hidden" id="DomainID" name="DomainID" />
		<table class="AXFormTable">
			<tr style="height:36px;">
				<th style="width: 130px;">ConfigID</th>
				<td colspan="3">
					<div id="ConfigIDValue" style="word-wrap: break-word;"></div>
				</td>
			</tr>
			<tr style="height:36px;">
				<th style="width: 130px;">Path<font color="red"> *</font></th>
				<td colspan="3">
					<input type="text" id="Path" name="Path" class="av-required" style="display:none;width:95%;height:25px;" />
					<div id="PathValue" style="display:none; word-wrap: break-word;"></div>
				</td>
			</tr>
			<tr>
				<th style="width: 130px;">Service URL</th>
				<td colspan="3">
					<input type="text" id="ServiceURL" name="ServiceURL" style="width:95%;height:25px;" />
				</td>
			</tr>
			<tr>
				<th style="width: 130px;"><spring:message code="Cache.lbl_api_limit"/><font color="red"> *</font></th>
				<td colspan="3">
					<input type="text" id="ReqLimitPerDay" name="ReqLimitPerDay" class="av-required" style="width:110px;height:25px;" />
				</td>
			</tr>
			<tr>
				<th><spring:message code="Cache.lbl_SettingName"/><font color="red"> *</font></th>
				<td colspan="3">
					<input type="text" id="DisplayName" name="<spring:message code="Cache.lbl_SettingKey"/>" style="width:70%;height:25px;" class="AXInput av-required HtmlCheckXSS ScriptCheckXSS"/>
					<input id="MultiDisplayName" name="MultiDisplayName" type="hidden" />
		  			<input type="button" value="<spring:message code='Cache.lbl_MultiLang2'/>" class="AXButton" onclick="dictionaryLayerPopup();" /> <!-- 다국어 -->
				</td>
			</tr>
			<tr>
				<th><spring:message code="Cache.lbl_IsUse"/><font color="red"> *</font></th>
				<td colspan="3">
					<select type="text" id="IsUse" name="IsUse" class="selectType04 av-required">
						<option value="Y"><spring:message code="Cache.lbl_UseY" /></option>
						<option value="N"><spring:message code="Cache.lbl_UseN" /></option>
					</select>
				</td>
			</tr>
			<tr>
				<th><spring:message code="Cache.lbl_IsAnnoymous"/><font color="red"> *</font></th>
				<td colspan="3">
					<label>
						<input type="checkbox" id="IsAnnoymous" name="IsAnnoymous" class="" value="true"/>
						<spring:message code="Cache.lbl_IsAnnoymous" />
					</label>
				</td>
			</tr>
			<tr style="height: 100px">
				<th><spring:message code="Cache.lbl_Description"/></th> <!-- 설명 -->
				<td colspan="3">
					<textarea rows="5" style="width: 95%;resize:none;" id="Descriptions" name="Descriptions" class="AXTextarea HtmlCheckXSS ScriptCheckXSS"></textarea>
				</td>
			</tr>
		</table>
		<div align="center" style="padding-top: 10px">
			<input type="button" value="<spring:message code="Cache.btn_save"/>" onclick="saveAPIConfig();" class="AXButton red" />
			<input type="button" value="<spring:message code="Cache.btn_Close"/>" onclick="closeLayer();"  class="AXButton" />
		</div>
	</div>
</form>
<script>

var DomainID = coviCmn.isNull(CFN_GetQueryString("DomainID"), "");
var ConfigID = coviCmn.isNull(CFN_GetQueryString("ConfigID"), "");
var mode = coviCmn.isNull(CFN_GetQueryString("mode"), "add");
var lang = Common.getSession("lang");

init();

function init(){
	if(mode == "modify") {
		$("input#Path").hide();
		//$("input#Path").removeClass("av-required");
		$("#PathValue").show();
	}else{
		$("#DomainID").val(DomainID);
		$("input#Path").show();
		//$("input#Path").addClass("av-required");
		$("#PathValue").hide();		
	}
	
	if(mode == "modify") {
		setConfigData();
	}
}

//정보 조회
function setConfigData(){
	$.ajax({
		type:"POST",
		url : "/covicore/api/config/getConfigDetail.do",
		data : { ConfigID : ConfigID },
		success : function(data){
			if(data.status=='SUCCESS'){
				var info = data.data;
				$("#ConfigID").val(ConfigID);
				$("#ConfigIDValue").html(ConfigID);
				$("#Path").val(info.Path);
				$("#PathValue").html(info.Path);
				$("#ServiceURL").val(info.ServiceURL);
				$("#ReqLimitPerDay").val(info.ReqLimitPerDay);
				if(info.IsAnnoymous == "true") {
					$("#IsAnnoymous").prop("checked", true);
				}else{
					$("#IsAnnoymous").prop("checked", false);
				}
				var Name = CFN_GetDicInfo(info.MultiDisplayName, lang);
				$("#DisplayName").val(Name);
				$("#MultiDisplayName").val(info.MultiDisplayName);
				$("#Descriptions").val(info.Descriptions);
				$("#IsUse").val(info.IsUse);
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/covicore/api/config/getConfigDetail.do", response, status, error);
		}
	});
}

//수정
function saveAPIConfig(){
	if(validationChk()){
		var _url = "/covicore/api/config/addConfig.do";
		if(mode == "modify") {
			_url = "/covicore/api/config/editConfig.do"
		}
		
		var multiDisplayName = $('#MultiDisplayName').val();
		if(multiDisplayName == '') {
			$('#MultiDisplayName').val($('#DisplayName').val());
		}
		$.ajax({
			type:"POST",
			data:$("#form_APIConfigInfoPop").serialize(),
			url: _url,
			success:function (data) {
				if(data.status=='SUCCESS'){
		    		parent.Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){ /*저장되었습니다.*/
						parent.configGrid.reloadList();			
		    			Common.Close();
		    		});
	    		}else{
	    			parent.Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
	    		}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/api/config/editConfig.do", response, status, error);
			}
		});
	}
	
}

//입력값 검증
function validationChk(){
	if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
	var dic = Common.getDic("msg_EnterTheRequiredValue");
	var msg = dic;
	
	var requiredInputs = $(".av-required");
	for(var i = 0; i < requiredInputs.length; i++){
		if(requiredInputs[i].value == undefined || requiredInputs[i].value == ""){
			var txt = $(requiredInputs[i]).closest("td").prev("th").text();
			msg = dic.replace("{0}", txt);
			parent.Common.Warning(msg, "Warning Dialog", function(){
				requiredInputs[i].focus();
			});
			return false; 
		}
	}
	return true;
}

//레이어 팝업 닫기
function closeLayer(){
	Common.Close();
}

//다국어 설정 팝업
function dictionaryLayerPopup(){
	var option = {
			lang : lang,
			hasTransBtn : 'true',
			allowedLang : 'ko,en,ja,zh,lang1,lang2',
			useShort : 'false',
			dicCallback : 'dicCallback',
			openerID : CFN_GetQueryString("CFN_OpenLayerName"),
			popupTargetID : 'setMultiLangData',
			init : 'dicInit'
	};
	
	var url = "";
	url += "/covicore/control/calldic.do?lang=" + option.lang;
	url += "&hasTransBtn=" + option.hasTransBtn;
	url += "&useShort=" + option.useShort;
	url += "&dicCallback=" + option.dicCallback;
	url += "&allowedLang=" + option.allowedLang;
	url += "&openerID=" + option.openerID;
	url += "&popupTargetID=" + option.popupTargetID;
	url += "&init=" + option.init;
	
	parent.Common.open("","setMultiLangData","<spring:message code='Cache.lbl_MultiLangSet' />",url,"400px","280px","iframe",true,null,null,true);
}

//다국어 세팅 함수
function dicInit(){
	if(document.getElementById("MultiDisplayName").value == ''){
		value = document.getElementById('DisplayName').value;
	}else{
		value = document.getElementById("MultiDisplayName").value;
	}
	
	return value;
}

//다국어 콜백 함수
function dicCallback(data){
	var jsonData = JSON.parse(data);
	
	$("#MultiDisplayName").val(coviDic.convertDic(jsonData));
	if(document.getElementById('DisplayName').value == ''){
		document.getElementById('DisplayName').value = CFN_GetDicInfo(coviDic.convertDic(jsonData), lang);
	}
	
	Common.Close("setMultiLangData");
}

function setMultiCodeName(){
	var sDictionaryInfo = document.getElementById("MultiDisplayName").value;
	if (sDictionaryInfo == "") {
	      switch (lang.toUpperCase()) {
	          case "KO": sDictionaryInfo = document.getElementById("DisplayName").value + ";;;;;;;;;"; break;
	          case "EN": sDictionaryInfo = ";" + document.getElementById("DisplayName").value + ";;;;;;;;"; break;
	          case "JA": sDictionaryInfo = ";;" + document.getElementById("DisplayName").value + ";;;;;;;"; break;
	          case "ZH": sDictionaryInfo = ";;;" + document.getElementById("DisplayName").value + ";;;;;;"; break;
	          case "E1": sDictionaryInfo = ";;;;" + document.getElementById("DisplayName").value + ";;;;;"; break;
	          case "E2": sDictionaryInfo = ";;;;;" + document.getElementById("DisplayName").value + ";;;;"; break;
	          case "E3": sDictionaryInfo = ";;;;;;" + document.getElementById("DisplayName").value + ";;;"; break;
	          case "E4": sDictionaryInfo = ";;;;;;;" + document.getElementById("DisplayName").value + ";;"; break;
	          case "E5": sDictionaryInfo = ";;;;;;;;" + document.getElementById("DisplayName").value + ";"; break;
	          case "E6": sDictionaryInfo = ";;;;;;;;;" + document.getElementById("DisplayName").value; break;
	       }
	       document.getElementById("MultiDisplayName").value = sDictionaryInfo;
	}
}
</script>