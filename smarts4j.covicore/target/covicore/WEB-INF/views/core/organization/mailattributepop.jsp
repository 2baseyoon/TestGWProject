<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>

	<style>
		/* div padding */
		.divpop_body {
			padding: 20px !important;
		}
		
		label {
			font-size: 13px;
		}
	</style>
	
</head>
<body style="overflow: hidden;">
	<form>
	<div style="width:100%;" id="divMailAttribute" class="mt15">
		<table class="AXFormTable">
			<colgroup>	
				<col style="width:45%" />
				<col />
			</colgroup>
			<tbody>
               <tr>
					<th><spring:message code='Cache.lbl_extensionAttribute1'/></th>
					<td>
						<input type="text" class="AXInput" id="txtAttribute1">
					</td>
				</tr>
				 <tr>
					<th><spring:message code='Cache.lbl_extensionAttribute2'/></th>
					<td>
						<input type="text" class="AXInput" id="txtAttribute2">
					</td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_extensionAttribute3'/></th>
					<td>
						<input type="text" class="AXInput" id="txtAttribute3">
					</td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_extensionAttribute4'/></th>
					<td>
						<input type="text" class="AXInput" id="txtAttribute4">
					</td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_extensionAttribute5'/></th>
					<td>
						<input type="text" class="AXInput" id="txtAttribute5">
					</td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_extensionAttribute6'/></th>
					<td>
						<input type="text" class="AXInput" id="txtAttribute6">
					</td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_extensionAttribute7'/></th>
					<td>
						<input type="text" class="AXInput" id="txtAttribute7">
					</td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_extensionAttribute8'/></th>
					<td>
					<input type="text" class="AXInput" id="txtAttribute8">
					</td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_extensionAttribute9'/></th>
					<td>
						<input type="text" class="AXInput" id="txtAttribute9">
					</td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_extensionAttribute10'/></th>
					<td>
						<input type="text" class="AXInput" id="txtAttribute10">
					</td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_extensionAttribute11'/></th>
					<td>
						<input type="text" class="AXInput" id="txtAttribute11">
					</td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_extensionAttribute12'/></th>
					<td>
						<input type="text" class="AXInput" id="txtAttribute12">
					</td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_extensionAttribute13'/></th>
					<td>
						 <input type="text" class="AXInput" id="txtAttribute13">
					 </td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_extensionAttribute14'/></th>
					<td>
						<input type="text" class="AXInput" id="txtAttribute14">
					</td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_extensionAttribute15'/></td>
					<td>
						<input type="text" class="AXInput" id="txtAttribute15">
					</td>
				</tr>
           </tbody>
		</table>
	</div>
         
	<div style="width: 100%; text-align: center; margin-top: 10px;">
		<input type="button" id="btnConfirm" value="<spring:message code='Cache.lbl_Confirm' />" onclick="btnConfirm_OnClick();" class="AXButton red" > <!-- 확인 -->
		<input type="button" id="btnCancel" value="<spring:message code='Cache.btn_Cancel' />" onclick="btnCancel_OnClick();" class="AXButton" > <!-- 취소 -->
	</div>
	       
     <div style="display: none;">
		<input type="hidden" id="hidAttributesInfo" />
		<input type="hidden" id="hidIframeName" />
		<input type="hidden" id="hidOpenName"/>
		<input type="hidden" id="hidCallBackMethod"/>
      </div>
	</form>
</body>

<script type="text/javascript">
	$(document).ready(function(){
		initcontrol();
	});
	
	function initcontrol(){
		var strIframeName = "${iframename}";
		var strOpenName = "${openname}";
		var strCallBackMethod = "${callbackmethod}";
		var strAttributes = "${attributes}";
		
		$("#hidAttributesInfo").val(strAttributes);
        $("#hidIframeName").val(strIframeName);
        $("#hidOpenName").val(strOpenName);
        $("#hidCallBackMethod").val(strCallBackMethod);
		
	}
	// 확인 버튼 클릭시 실행되며, 선택한 정보를 XML로 생성하여 CallBack 함수를 호출한 후, 화면을 종료합니다.
	function btnConfirm_OnClick() {
		debugger;
		var aStrSpecialChar = new Array(";", "'", "^", "%", "!", "&");
		var nLength = aStrSpecialChar.length;
		for (var i = 0; i < nLength; i++) {
			if ($("#txtAttribute1").val().indexOf(aStrSpecialChar[i]) >= 0) {
				var sMessage = "<spring:message code='Cache.msg_DictionaryInfo_01' />";  // 특수문자 [{0}]는 사용할 수 없습니다.
				sMessage = sMessage.replace(/\{0\}/gi, aStrSpecialChar[i]);
				parent.Common.Warning(sMessage, 'Warning Dialog', function () {
					$("#txtAttribute1").focus();
				});
				return;
			}
			if ($("#txtAttribute2").val().indexOf(aStrSpecialChar[i]) >= 0) {
				var sMessage = "<spring:message code='Cache.msg_DictionaryInfo_01' />";  // 특수문자 [{0}]는 사용할 수 없습니다.
				sMessage = sMessage.replace(/\{0\}/gi, aStrSpecialChar[i]);
				parent.Common.Warning(sMessage, 'Warning Dialog', function () {
					$("#txtAttribute2").focus();
				});
				return;
			}
			if ($("#txtAttribute3").val().indexOf(aStrSpecialChar[i]) >= 0) {
				var sMessage = "<spring:message code='Cache.msg_DictionaryInfo_01' />";  // 특수문자 [{0}]는 사용할 수 없습니다.
				sMessage = sMessage.replace(/\{0\}/gi, aStrSpecialChar[i]);
				parent.Common.Warning(sMessage, 'Warning Dialog', function () {
					$("#txtAttribute3").focus();
				});
				return;
			}
			if ($("#txtAttribute4").val().indexOf(aStrSpecialChar[i]) >= 0) {
				var sMessage = "<spring:message code='Cache.msg_DictionaryInfo_01' />";  // 특수문자 [{0}]는 사용할 수 없습니다.
				sMessage = sMessage.replace(/\{0\}/gi, aStrSpecialChar[i]);
				parent.Common.Warning(sMessage, 'Warning Dialog', function () {
					$("#txtAttribute4").focus();
				});
				return;
			}
			if ($("#txtAttribute5").val().indexOf(aStrSpecialChar[i]) >= 0) {
				var sMessage = "<spring:message code='Cache.msg_DictionaryInfo_01' />";  // 특수문자 [{0}]는 사용할 수 없습니다.
				sMessage = sMessage.replace(/\{0\}/gi, aStrSpecialChar[i]);
				parent.Common.Warning(sMessage, 'Warning Dialog', function () {
					$("#txtAttribute5").focus();
				});
				return;
			}
			if ($("#txtAttribute6").val().indexOf(aStrSpecialChar[i]) >= 0) {
				var sMessage = "<spring:message code='Cache.msg_DictionaryInfo_01' />";  // 특수문자 [{0}]는 사용할 수 없습니다.
				sMessage = sMessage.replace(/\{0\}/gi, aStrSpecialChar[i]);
				parent.Common.Warning(sMessage, 'Warning Dialog', function () {
					$("#txtAttribute6").focus();
				});
				return;
			}
			if ($("#txtAttribute7").val().indexOf(aStrSpecialChar[i]) >= 0) {
				var sMessage = "<spring:message code='Cache.msg_DictionaryInfo_01' />";  // 특수문자 [{0}]는 사용할 수 없습니다.
				sMessage = sMessage.replace(/\{0\}/gi, aStrSpecialChar[i]);
				parent.Common.Warning(sMessage, 'Warning Dialog', function () {
					$("#txtAttribute7").focus();
				});
				return;
			}
			if ($("#txtAttribute8").val().indexOf(aStrSpecialChar[i]) >= 0) {
				var sMessage = "<spring:message code='Cache.msg_DictionaryInfo_01' />";  // 특수문자 [{0}]는 사용할 수 없습니다.
				sMessage = sMessage.replace(/\{0\}/gi, aStrSpecialChar[i]);
				parent.Common.Warning(sMessage, 'Warning Dialog', function () {
					$("#txtAttribute8").focus();
				});
				return;
			}
			if ($("#txtAttribute9").val().indexOf(aStrSpecialChar[i]) >= 0) {
				var sMessage = "<spring:message code='Cache.msg_DictionaryInfo_01' />";  // 특수문자 [{0}]는 사용할 수 없습니다.
				sMessage = sMessage.replace(/\{0\}/gi, aStrSpecialChar[i]);
				parent.Common.Warning(sMessage, 'Warning Dialog', function () {
					$("#txtAttribute9").focus();
				});
				return;
			}
			if ($("#txtAttribute10").val().indexOf(aStrSpecialChar[i]) >= 0) {
				var sMessage = "<spring:message code='Cache.msg_DictionaryInfo_01' />";  // 특수문자 [{0}]는 사용할 수 없습니다.
				sMessage = sMessage.replace(/\{0\}/gi, aStrSpecialChar[i]);
				parent.Common.Warning(sMessage, 'Warning Dialog', function () {
					$("#txtAttribute10").focus();
				});
				return;
			}
			if ($("#txtAttribute11").val().indexOf(aStrSpecialChar[i]) >= 0) {
				var sMessage = "<spring:message code='Cache.msg_DictionaryInfo_01' />";  // 특수문자 [{0}]는 사용할 수 없습니다.
				sMessage = sMessage.replace(/\{0\}/gi, aStrSpecialChar[i]);
				parent.Common.Warning(sMessage, 'Warning Dialog', function () {
					$("#txtAttribute11").focus();
				});
				return;
			}
			if ($("#txtAttribute12").val().indexOf(aStrSpecialChar[i]) >= 0) {
				var sMessage = "<spring:message code='Cache.msg_DictionaryInfo_01' />";  // 특수문자 [{0}]는 사용할 수 없습니다.
				sMessage = sMessage.replace(/\{0\}/gi, aStrSpecialChar[i]);
				parent.Common.Warning(sMessage, 'Warning Dialog', function () {
					$("#txtAttribute12").focus();
				});
				return;
			}
			if ($("#txtAttribute13").val().indexOf(aStrSpecialChar[i]) >= 0) {
				var sMessage = "<spring:message code='Cache.msg_DictionaryInfo_01' />";  // 특수문자 [{0}]는 사용할 수 없습니다.
				sMessage = sMessage.replace(/\{0\}/gi, aStrSpecialChar[i]);
				parent.Common.Warning(sMessage, 'Warning Dialog', function () {
					$("#txtAttribute13").focus();
				});
				return;
			}
			if ($("#txtAttribute14").val().indexOf(aStrSpecialChar[i]) >= 0) {
				var sMessage = "<spring:message code='Cache.msg_DictionaryInfo_01' />";  // 특수문자 [{0}]는 사용할 수 없습니다.
				sMessage = sMessage.replace(/\{0\}/gi, aStrSpecialChar[i]);
				parent.Common.Warning(sMessage, 'Warning Dialog', function () {
					$("#txtAttribute14").focus();
				});
				return;
			}
			if ($("#txtAttribute15").val().indexOf(aStrSpecialChar[i]) >= 0) {
				var sMessage = "<spring:message code='Cache.msg_DictionaryInfo_01' />";  // 특수문자 [{0}]는 사용할 수 없습니다.
				sMessage = sMessage.replace(/\{0\}/gi, aStrSpecialChar[i]);
				parent.Common.Warning(sMessage, 'Warning Dialog', function () {
					$("#txtAttribute15").focus();
				});
				return;
			}
		}
		
		var sXML = "<Attribute>";
			sXML += "<Attribute_1><![CDATA[" + $("#txtAttribute1").val() + "]]></Attribute_1>";
			sXML += "<Attribute_2><![CDATA[" + $("#txtAttribute2").val() + "]]></Attribute_2>";
			sXML += "<Attribute_3><![CDATA[" + $("#txtAttribute3").val() + "]]></Attribute_3>";
			sXML += "<Attribute_4><![CDATA[" + $("#txtAttribute4").val() + "]]></Attribute_4>";
			sXML += "<Attribute_5><![CDATA[" + $("#txtAttribute5").val() + "]]></Attribute_5>";
			sXML += "<Attribute_6><![CDATA[" + $("#txtAttribute6").val() + "]]></Attribute_6>";
			sXML += "<Attribute_7><![CDATA[" + $("#txtAttribute7").val() + "]]></Attribute_7>";
			sXML += "<Attribute_8><![CDATA[" + $("#txtAttribute8").val() + "]]></Attribute_8>";
			sXML += "<Attribute_9><![CDATA[" + $("#txtAttribute9").val() + "]]></Attribute_9>";
			sXML += "<Attribute_10><![CDATA[" + $("#txtAttribute10").val() + "]]></Attribute_10>";
			sXML += "<Attribute_11><![CDATA[" + $("#txtAttribute11").val() + "]]></Attribute_11>";
			sXML += "<Attribute_12><![CDATA[" + $("#txtAttribute12").val() + "]]></Attribute_12>";
			sXML += "<Attribute_13><![CDATA[" + $("#txtAttribute13").val() + "]]></Attribute_13>";
			sXML += "<Attribute_14><![CDATA[" + $("#txtAttribute14").val() + "]]></Attribute_14>";
			sXML += "<Attribute_15><![CDATA[" + $("#txtAttribute15").val() + "]]></Attribute_15>";
			sXML += "</Attribute>";

		var sCallBackMethod = $("#hidCallBackMethod").val();
		var sIframe = $("#hidIframeName").val();

		// CallBack 함수 호출
		XFN_CallBackMethod_Call(sIframe, sCallBackMethod, sXML);

		parent.Common.Close($("#hidOpenName").val());
	}

	// 닫기 버튼 클릭시 실행되며, 화면을 종료합니다.
	function btnCancel_OnClick() {
		parent.Common.Close($("#hidOpenName").val());
	}

	// 화면 로드시 실행되며, 선택된 지역 정보를 화면에 표시합니다.
	$(window).load(function () {
		var sAttributes = $("#hidAttributesInfo").val();
		var sIframe = $("#hidIframeName").val();
		var sAttributeInfo = "";
		
		if (sIframe == "") {
			sAttributeInfo = new Function("return $(\"#" + sAttributes + "\", parent.document).val();").apply();
		}
		else {
			var sCallBack = "";
			var sTemp = "";
			for (var i = 0; i < sIframe.split(";").length; i++) {
				sTemp = sIframe.split(";")[i];
				if (sTemp == "") {
					break;
				}

				if (i == 0) {
					sCallBack = "$(\"#" + sTemp + "_if\", parent.document)[0].contentWindow";
				}
				else {
					sCallBack += "$(\"#" + sTemp + "_if\")[0].contentWindow";
				}
				sCallBack += ".";
			}
			sAttributeInfo = new Function("return "+sCallBack + "$(\"#" + sAttributes + "\").val()");").apply();
		}
		
		if ((sAttributeInfo != null) && (sAttributeInfo != "")) {
			$("#txtAttribute1").val($($.parseXML(sAttributeInfo)).find("Attribute_1").text());
			$("#txtAttribute2").val($($.parseXML(sAttributeInfo)).find("Attribute_2").text());
			$("#txtAttribute3").val($($.parseXML(sAttributeInfo)).find("Attribute_3").text());
			$("#txtAttribute4").val($($.parseXML(sAttributeInfo)).find("Attribute_4").text());
			$("#txtAttribute5").val($($.parseXML(sAttributeInfo)).find("Attribute_5").text());
			$("#txtAttribute6").val($($.parseXML(sAttributeInfo)).find("Attribute_6").text());
			$("#txtAttribute7").val($($.parseXML(sAttributeInfo)).find("Attribute_7").text());
			$("#txtAttribute8").val($($.parseXML(sAttributeInfo)).find("Attribute_8").text());
			$("#txtAttribute9").val($($.parseXML(sAttributeInfo)).find("Attribute_9").text());
			$("#txtAttribute10").val($($.parseXML(sAttributeInfo)).find("Attribute_10").text());
			$("#txtAttribute11").val($($.parseXML(sAttributeInfo)).find("Attribute_11").text());
			$("#txtAttribute12").val($($.parseXML(sAttributeInfo)).find("Attribute_12").text());
			$("#txtAttribute13").val($($.parseXML(sAttributeInfo)).find("Attribute_13").text());
			$("#txtAttribute14").val($($.parseXML(sAttributeInfo)).find("Attribute_14").text());
			$("#txtAttribute15").val($($.parseXML(sAttributeInfo)).find("Attribute_15").text());
		}
	});
</script>