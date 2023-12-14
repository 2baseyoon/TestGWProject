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
<body>
	<form>
		<div style="width:100%;" id="divDeptDefault" class="mt15">
			<table class="AXFormTable">
				<colgroup>	
					<col style="width:20%" />
					<col />
				</colgroup>
				<tr>
					<th><spring:message code="Cache.lbl_Mail"/></th>
					<td>
						<input type="text" class="AXInput" id="txtMailID">
						&nbsp;@
						<select id="selMail" name="selMail" class="AXSelect" ></select>
						<input type="hidden" id="hidIsDuplicateCheck">
					</td>
				</tr>
			</table>
		</div>

		<div style="width: 100%; text-align: center; margin-top: 10px;">
			<input type="button" id="btnDuplicateCheck" value="<spring:message code='Cache.lbl_DuplicateCheck' />" onclick="btnDuplicateCheck_OnClick();" class="AXButton red" > <!-- 중복체크 -->
			<input type="button" id="btnConfirm" value="<spring:message code='Cache.lbl_Confirm' />" onclick="btnConfirm_OnClick();" class="AXButton red" > <!-- 확인 -->
			<input type="button" id="btnCancel" value="<spring:message code='Cache.btn_Cancel' />" onclick="btnCancel_OnClick();" class="AXButton" > <!-- 취소 -->
		</div>
		<input type="hidden" id="hidMode" />
		<input type="hidden" id="hidIndex"  />
		<input type="hidden" id="hidAttributeID"/>
		<input type="hidden" id="hidMailID"  />
		<input type="hidden" id="hidIframeName" />
		<input type="hidden" id="hidOpenName"/>
		<input type="hidden" id="hidCallBackMethod"/>
	</form>
</body>

<script type="text/javascript">
	$(document).ready(function(){
		initcontrol();
	});
	
	function initcontrol(){
		var strIframeName = "${iframename}";
		var strOpenName = "${openname}";
		var strMailAddress = "${mailaddress}";
		var strMail = "${mail}";
		var strIndex = "${index}";
		var strMode = "${mode}";
		var strCallBackMethod = "${callbackmethod}";
		var strGroupType = "${grouptype}";
		var strMailID = "";
		var arrMail = strMail.split("@");
		
		var objMailDomain = Common.getBaseCode("MailDomain");
		$(objMailDomain.CacheData).each(function(idx, obj) {
			if (obj.Code == 'MailDomain')
				return true;
			$('#selMail').append($('<option>', {
				value : obj.Code,
				text : obj.CodeName
			}));
		});
		
		$('#selMailDomain').append($('<option>', { 
	        value: "",
	        text : "<spring:message code='Cache.lbl_selection'/>"
	 	}));
		
		if(arrMail.length > 1){
			$('#selMail').find("option").each(function (i){
				if($(this).text() == arrMail[1]){
					$('#selMail').val($(this).val());
				}
			});
		}
		
		$("#txtMailID").val(arrMail[0]);
        $("#hidMode").val(strMode);
        $("#hidIndex").val(strIndex);
        $("#hidMailID").val(strMailID);
        $("#hidIframeName").val(strIframeName);
        $("#hidOpenName").val(strOpenName);
        $("#hidCallBackMethod").val(strCallBackMethod);
		
	}

	 // 중복 체크 클릭 시, 메일 주소의 중복 여부를 확인하며 이상이 없을 시 추가가 가능하도록 셋팅을 변경한다.
    function btnDuplicateCheck_OnClick() {
        var sMailID = $("#txtMailID").val();
        if (sMailID == "") {
        	
            parent.Common.Warning("메일 주소를 입력하여 주십시오.", "Warning Dialog", function () {
                $("#txtMailID").focus();
            });
        	
            return;
        }

        var sMailDomain = $("#selMail option:selected").text();
        if (sMailDomain == "선택") {
        	
            parent.Common.Warning("메일 도메인을 선택하여 주십시오.", "Warning Dialog", function () {
                $("#selMail").focus();
            });
        	
            return;
        }

        var aStrSpecialChar = new Array(";", "'", "^", "!", "@", "#", "$", "%", "&", "*");
        var nLength = aStrSpecialChar.length;
        for (var i = 0; i < nLength; i++) {
            if ($("#txtMailID").val().indexOf(aStrSpecialChar[i]) >= 0) {
                var sMessage = "<spring:message code='Cache.msg_DictionaryInfo_01'/>";  // 특수문자 [{0}]는 사용할 수 없습니다.
                sMessage = sMessage.replace(/\{0\}/gi, aStrSpecialChar[i]);
                
                parent.Common.Warning(sMessage, 'Warning Dialog', function () {
                    $("#txtMailID").select();
                });
                
                return;
            }
        }

        $("#hidAttributeID").val(sMailID);
        var sAttributeID = $("#hidAttributeID").val();
        var sMailDomain = $("#selMail option:selected").text();
        var sMailAddress = sAttributeID + "@" + sMailDomain;
		$.ajax({
			type : "POST",
			data : {
				"MailAddress" : sMailAddress,
				"Code" : $("#hidIsDuplicateCheck").val() == "" ? '' : sAttributeID
			},
			url : "/covicore/admin/orgmanage/getisduplicatemail.do",
			success : function(data) {
				if (data.status != "FAIL") {
					if (data.list[0].isDuplicate > 0) {
						Common.Warning("이미 존재하는 메일입니다.");
						$('#txtMailID').focus();
						$("#hidIsDuplicateCheck").val("");
					} else {
						Common.Inform("사용가능한 메일 주소 입니다.");
						$("#hidIsDuplicateCheck").val(sMailAddress);
					}
				} else {
					Common.Warning(data.message);
					$("#hidIsDuplicateCheck").val("");
				}
			},
			error : function(response, status, error) {
				CFN_ErrorAjax("/covicore/admin/orgmanage/getisduplicatemail.do", response, status, error);
			}
		});
    }

    // 확인 버튼 클릭시 실행되며, 선택한 정보를 XML로 생성하여 CallBack 함수를 호출한 후, 화면을 종료합니다.
    function btnConfirm_OnClick() {
        if ($("#hidIsDuplicateCheck").val() != ""){ //중복 체크 통과 시.
            var sMailID = $("#txtMailID").val();
            if (sMailID == "") {
                parent.Common.Warning("메일 주소를 입력하여 주십시오.", "Warning Dialog", function () {
                    $("#txtMailID").focus();
                });
                return;
            }

            var sMailDomain = $("#selMail option:selected").text();
            if (sMailDomain == "선택") {
                parent.Common.Warning("메일 도메인을 선택하여 주십시오.", "Warning Dialog", function () {
                    $("#selMail").focus();
                });
                return;
            }

            var aStrSpecialChar = new Array(";", "'", "^", "!", "@", "#", "$", "%", "&", "*");
            var nLength = aStrSpecialChar.length;
            for (var i = 0; i < nLength; i++) {
                if ($("#txtMailID").val().indexOf(aStrSpecialChar[i]) >= 0) {
                    var sMessage = "<spring:message code='Cache.msg_DictionaryInfo_01'/>";  // 특수문자 [{0}]는 사용할 수 없습니다.
                    sMessage = sMessage.replace(/\{0\}/gi, aStrSpecialChar[i]);
                    parent.Common.Warning(sMessage, 'Warning Dialog', function () {
                        $("#txtMailID").select();
                    });
                    return;
                }
            }
            $("#hidAttributeID").val(sMailID);

            var sAttributeID = $("#hidAttributeID").val();
            var sMailDomain = $("#selMail option:selected").text();
            var sXML = "<Attribute>";
            sXML += "<AttributeID><![CDATA[" + sMailID + "]]></AttributeID>";
            sXML += "<Mail><![CDATA[" + sMailID + "@" + sMailDomain + "]]></Mail>";
            sXML += "<Index><![CDATA[" + $("#hidIndex").val() + "]]></Index>";
            sXML += "<Mode><![CDATA[" + $("#hidMode").val() + "]]></Mode>";
            sXML += "</Attribute>";
            var sCallBackMethod = $("#hidCallBackMethod").val();
            var sIframe = $("#hidIframeName").val();

            // CallBack 함수 호출
            XFN_CallBackMethod_Call(sIframe, sCallBackMethod, sXML);

            parent.Common.Close($("#hidOpenName").val());
        }else {
            parent.Common.Warning("<spring:message code='Cache.msg_DuplicateCheck'/>", "Warning Dialog", function () { $("#txtMailID").focus(); });
        }
    }

    // 닫기 버튼 클릭시 실행되며, 화면을 종료합니다.
    function btnCancel_OnClick() {
        parent.Common.Close($("#hidOpenName").val());
    }

    // 화면 로드시 실행되며, 선택된 지역 정보를 화면에 표시합니다.
    $(window).load(function () {
        var sTextItemID = $("#hidMailID").val();
        var sIframe = $("#hidIframeName").val();
        var sAttributeInfo = "";
        if (sIframe == "") {
            sAttributeInfo = new Function("return $(\"#" + sTextItemID + "\", parent.document).val();").apply();
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
            sAttributeInfo = new Function("return "+sCallBack + "$(\"#" + sTextItemID + "\").val();").apply();
        }

        if ((sAttributeInfo != null) && (sAttributeInfo != "")) {
            var oNode = $($.parseXML(sAttributeInfo)).find("Attribute").filter(":first");
            $("#hidAttributeID").val(oNode.find("AttributeID").text());
        }

        $("#txtMailID").focus();
    });
	
</script>