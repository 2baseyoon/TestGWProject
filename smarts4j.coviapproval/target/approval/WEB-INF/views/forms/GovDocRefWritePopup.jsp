<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>    
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script type="text/javascript" src="/approval/resources/script/forms/WebEditor_Approval_HWP.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Hwp/HwpToolbars.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Hwp/HwpCtrl.js<%=resourceVersion%>"></script>

<head>
<title></title>
</head>
<body>
	<div class="layer_divpop ui-draggable schPopLayer" style="width:500px;">
		<div class="divpop_contents" style="padding: 10px;">
			<div class="pop_header" name="default_info">
				<h4 class="divpop_header ui-draggable-handle"><span class="divpop_header_ico"><spring:message code='Cache.lbl_BasicInfo'/></span></h4>
			</div>
			<table class="table_3 tableStyle linePlus mt10" cellpadding="0" cellspacing="0" name="default_info">
				<colgroup>
					<col style="width: 20%">
					<col style="width: 80%">
				</colgroup>
				<tr>
					<th><spring:message code='Cache.lbl_Title'/></th>
					<td><input type="text" class="input-required w100" style="width: 98%;" id="TITLE" name="returnDataField" ></td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_DocNo'/></th>
					<td><input type="text" class="w100" style="width: 98%;" id="DOC_NO" disabled="disabled"></td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_Address'/></th>
					<td><select id="ADDRESS" class="w100" name="returnDataField" cdgrp="GovAddress"></select></td>
				</tr>
			</table>
			
			<br>
			
			<div class="pop_header">
				<h4 class="divpop_header ui-draggable-handle"><span class="divpop_header_ico"><spring:message code='Cache.lbl_recordInfo'/></span></h4>
			</div>
			<table class="table_3 tableStyle linePlus mt10" cellpadding="0" cellspacing="0">
				<colgroup>
					<col style="width: 20%">
					<col style="width: 80%">
				</colgroup>
				<tr>
					<th><spring:message code='Cache.lbl_recordFile'/></th>
					<td>
						<input type="text" class="input-required" id="RECORD_SUBJECT" name="returnDataField" style="width: 84.2%;" disabled="disabled">
						<input type="hidden" id="RECORD_CLASS_NUM" name="returnDataField">
						<input type="button" class="AXButton" id="btSelectRecord" onclick="openSelectRecordPopup();" value="<spring:message code='Cache.lbl_selection'/>" style="display: none;" />
					</td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_recordRegistType'/></th>
					<td><select id="REGIST_CHECK" class="input-required mw150p" name="returnDataField" cdgrp="RegistCheck"></select></td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_specialRecord'/></th>
					<td><select id="SPECIAL_RECORD" class="input-required mw150p" name="returnDataField" cdgrp="SpecialRecord"></select></td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_preservationPeriod'/></th>
					<td><select id="KEEP_PERIOD" class="input-required mw150p" name="returnDataField" cdgrp="KeepPeriod"></select></td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_apv_Publication'/></th>
					<td>
						<select id="RELEASE_CHECK" class="input-required mw150p" name="returnDataField" cdgrp="ReleaseCheck" onchange="toggleCheckDiv();"></select>
						<div id="RELEASE_CHECK_DIV" style="display: none;"></div>
					</td>
				</tr>
				<tr id="trReleaseRestriction" style="display: none;">
					<th><spring:message code='Cache.lbl_publicationPartDisplay'/></th>
					<td><input type="text" id="RELEASE_RESTRICTION" class="input-required mw150p" name="returnDataField" style="width: 98%;"></select></td>
				</tr>
				<tr>
					<th><spring:message code='Cache.lbl_viewRange'/><br>(<spring:message code='Cache.lbl_SecurityLevel'/>)</th>
					<td><select id="SECURE_LEVEL" class="input-required mw150p" name="returnDataField" cdgrp="SecureLevel"></select></td>
				</tr>
			</table>
			
			<div class="bottom">
				<a class="btnTypeDefault" href="javascript:doSave();"><spring:message code='Cache.btn_save'/></a>
				<a class="btnTypeDefault" href="javascript:Common.Close();"><spring:message code='Cache.btn_apv_close'/></a>
			</div>
		</div>	
	</div>
</body>

<script>

var idx = "${idx}";
var formInstID = "${formInstID}";
var processID = "${processID}";
var deptCode = "${deptCode}";

$(window).load(function () {
	setSelectBox();
	if(idx != "dist") {
			// 기안부서와 다른 부서의 사용자인 경우 기록물철 편집 불가능하도록 함
			if(opener.getInfo("Request.mode") == "DRAFT" || opener.getInfo("Request.mode") == "TEMPSAVE" || opener.getInfo("FormInstanceInfo.InitiatorUnitID") == opener.getInfo("AppInfo.dpid")) {
				$("#btSelectRecord").show();
			}
			
			$(".pop_header").eq(1).css("margin-top", "15px");
			
		setSavedInfo();
	} else {
			$("#btSelectRecord").show();
		$("[name=default_info]").hide();
		setSavedInfoDist();
	}
		
		toggleCheckDiv();
});

function setSelectBox() {
	var codeList = [];
	$("select").each(function(i, obj) {
		codeList.push($(obj).attr("cdgrp"));
	});
	
	Common.getBaseCodeList(codeList);
	
	for(var i = 0; i < codeList.length; i++) {
		var codeGroup = codeList[i];
		var codeMap = coviCmn.codeMap[codeGroup];
		
		var optHtml = "";
		if(codeMap[0].Code != "") { // 코드그룹 내 첫번째 코드가 빈값인 경우는 선택 option 필요 X
				optHtml += "<option value=''>" + Common.getDic("lbl_selection") + "</option>";
		}
		
		for(var j = 0; j < codeMap.length; j++) {
			optHtml += "<option value='"+codeMap[j].Code+"'>"+CFN_GetDicInfo(codeMap[j].MultiCodeName)+"</option>";
		}
		$("select[cdgrp="+codeGroup+"]").append(optHtml);
	}
	
	var checkHtml = "";
	for(var i = 1; i <= 8; i++) {
		checkHtml += "<input type='checkbox' name='ReleaseCheckField' id='RELEASE_CHECK_HO"+i+"'><label for='RELEASE_CHECK_HO"+i+"'> "+i+"호</label>&nbsp;&nbsp;";
		if(i == 4) {
			checkHtml += "<br/>";
		}
	}
	$("#RELEASE_CHECK_DIV").html(checkHtml);
}

function setSavedInfo() {
	$("[name=returnDataField]").each(function(i, obj){
		var id = $(obj).attr("id");
			var savedVal = "";
		
		if(id == "RELEASE_CHECK") {
				savedVal = opener.document.getElementsByName("MULTI_"+id)[idx].value;

			var hoArr = savedVal.substring(1).split('');
			for(var h = 1; h <= 8; h++) {
				if(hoArr[h-1] == "Y") {
					$("#RELEASE_CHECK_HO"+h).prop("checked", "checked");
				} else {
					$("#RELEASE_CHECK_HO"+h).prop("checked", false);
				}
			}
			
			toggleCheckDiv();
				
				$(obj).val(savedVal.charAt(0));
			} else if(id == "TITLE" && opener.isUseHWPEditor()) {
	    		var oMultiCtrl = opener.getMultiCtrlEditor();
	    		
	    		savedVal = oMultiCtrl.GetFieldText("SUBJECT");
	    		
				$(obj).val(savedVal);
		} else {
				savedVal = opener.document.getElementsByName("MULTI_"+id)[idx].value;
				
			$(obj).val(savedVal);
		}
	});	
	
	$("#DOC_NO").val(opener.document.getElementById("DocNo").value);
}

function setSavedInfoDist() {
		var docInfo = opener.getReceiveGovDocInfo();
				
		if(docInfo) {
				if(JSON.stringify(docInfo) != "{}") {				
					$("[name=returnDataField]").each(function(i, obj){
						var id = $(obj).attr("id");
						var savedVal = docInfo["MULTI_"+id];
						
						if(id == "RELEASE_CHECK") {
							$(obj).val(savedVal.charAt(0));
	
							var hoArr = savedVal.substring(1).split('');
							for(var h = 1; h <= 8; h++) {
								if(hoArr[h-1] == "Y") {
									$("#RELEASE_CHECK_HO"+h).prop("checked", "checked");
								} else {
									$("#RELEASE_CHECK_HO"+h).prop("checked", false);
								}
							}
							
							toggleCheckDiv();
						} else {
							$(obj).val(savedVal);
						}
					});	
				}
		}
}

function openSelectRecordPopup() {
	var sUrl = "goRecordSelectPopup.do";
	var iHeight = 670; 
	var iWidth = 1050;
	
	CFN_OpenWindow(sUrl, Common.getDic("lbl_selectRecordFile"), iWidth, iHeight, "scroll");
}

function setRecord(returnObj) {
	$("#RECORD_CLASS_NUM").val(returnObj.RecordClassNum);
	$("#RECORD_SUBJECT").val(returnObj.RecordSubject);
}

function validationCheck() {
		if(idx == "dist") {
			if(!$("#RECORD_CLASS_NUM").val()) {
				Common.Warning(Common.getDic("msg_selectRecordClass"));
				return false;
			}
			
			if(!$("#REGIST_CHECK").val()) {
				Common.Warning(Common.getDic("msg_selectRegistCheck"));
				return false;
			}
			
			if(!$("#SPECIAL_RECORD").val()) {
				Common.Warning(Common.getDic("msg_selectSpecialRecord"));
				return false;
			}
			
			if(!$("#KEEP_PERIOD").val()) {
				Common.Warning(Common.getDic("msg_selectKeepPeriod"));
				return false;
			}
			
			if(!$("#RELEASE_CHECK").val()) {
				Common.Warning(Common.getDic("msg_selectReleaseCheck"));
				return false;
			}
			
			if(!$("#SECURE_LEVEL").val()) {
				Common.Warning(Common.getDic("msg_selectSecureLevel"));
				return false;
			}
		}
	
	return true;
}

function doSave() {
	if(!validationCheck()) return;
	
	var returnData = {};
	
	var ho = "";
	$("[name=ReleaseCheckField]").each(function(i, obj){
		ho += ($(obj)[0].checked ? "Y" : "N");
	});
	
	$("[name=returnDataField]").each(function(i, obj){
		var id = $(obj).attr("id");
		
		returnData[id] = $(obj).val();
		
		if(id == "RELEASE_CHECK" && $(obj).val() != "") {
			if($(obj).val() == "1") {
				returnData[id] += "NNNNNNNN";
			} else {
				returnData[id] += ho;
			}
		}
	});
	
	if(idx != "dist") {
		opener.setGovDocInfo(returnData);
		
		Common.Close();
	} else {
		$.ajax({
			url	: "/approval/user/saveDocTempInfo.do",
			type: "POST",
			data: {
				"DocInfoParam" : JSON.stringify(returnData),
				"FormInstID" : formInstID,
				"ProcessID" : processID,
				"DeptCode" : deptCode
			},
			success:function (data) {
				if(data.status == "SUCCESS"){
						opener.G_displaySpnRecordInfoMulti(idx, returnData);
						
					Common.Inform(data.message); 
					Common.Close();
				}else{
						Common.Error(Common.getDic("msg_apv_030"));
				}
			},
			error:function (error){
					Common.Error(Common.getDic("msg_apv_030"));
			}
		});
	}
}

function toggleCheckDiv() {
	if($("#RELEASE_CHECK").val() == "" || $("#RELEASE_CHECK").val() == "1") {
		$("#RELEASE_CHECK_DIV").hide();
	} else {
		$("#RELEASE_CHECK_DIV").show();
	}
}
</script>