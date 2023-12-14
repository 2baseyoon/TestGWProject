<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<html>
<head>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script type="text/javascript">
    var wObjRuleList = ${ruleList.list};     // 구분
    var wObjRuleItemInfo; // 아이템정보
    <c:if test="${not empty ruleList.info}">
    wObjRuleItemInfo = ${ruleList.info};
    </c:if>
    $(document).ready(function() {
    	var sHTML = "";

        // 타입 selectbox//lbl_apv_initiator
        var aApvTypeList = new Array("initiator","approve","assist","assist-parallel","consult","consult-parallel","receive","ccinfo","ccinfo-before");
        sHTML = "";
        for(var i = 0; i < aApvTypeList.length; i++) {
        	sHTML += "<option value='" + aApvTypeList[i] + "'>" + Common.getDic("ApvType_" + aApvTypeList[i]) + " (" + aApvTypeList[i] + ")</option>";
        }
        $("#apvType").append(sHTML);
        
    	// 유형
        sHTML = "<option value=''><spring:message code='Cache.lbl_Select'/></option>"; // 선택
        var oAPRVLine_RuleClass = Common.getBaseCode("APRVLine_RuleClass").CacheData;
        if ($(oAPRVLine_RuleClass).length > 0) {
        	$(oAPRVLine_RuleClass).each(function() {
        		if ($(this)[0].CodeGroup == $(this)[0].Code) {
        			return true;
        		}
        		sHTML += "<option value='" + $(this)[0].Reserved1 + "'>" + $(this)[0].CodeName + "</option>";
        	});
        }
        else{
        	sHTML = "<option value='MASTER'>전결규정 마스터 사용</option>";
        }
        $("#apvClass").append(sHTML);

        // 구분
        sHTML = "<option value=''><spring:message code='Cache.lbl_Select'/></option>"; // 선택
        $(wObjRuleList).each(function() {
        	sHTML += "<option value='" + $(this)[0].RuleID + "'" + " RuleType='" + $(this)[0].RuleType + "'>" + $(this)[0].RuleName + "</option>";
        });
   	 	$("#ruleId").append(sHTML);

        // 넘어온 데이터 처리, 버튼
        var sMode = CFN_GetQueryString("mode");
        if (sMode == "add") {
            $("#updBtn").css("display", "none");
            $("#delBtn").css("display", "none");
        }
        else if (sMode == "upd") {
            $("#apvName").val(wObjRuleItemInfo.list[0].ApvName);
        	if (wObjRuleItemInfo.list[0].RuleID != "0") {
        		$("#ruleId").val(wObjRuleItemInfo.list[0].RuleID);
        	}
        	$("#apvType").val(wObjRuleItemInfo.list[0].ApvType);
            $("#apvDesc").val(wObjRuleItemInfo.list[0].ApvDesc);
            $("#sort").val(wObjRuleItemInfo.list[0].Sort);
        	$("#apvClass").val(wObjRuleItemInfo.list[0].ApvClass);
        	$("#apvClassAtt01").val(wObjRuleItemInfo.list[0].ApvClassAtt01);

            $("#addBtn").css("display", "none");
        }
        
        // 화면 UI 처리
        /*
        if ($("#apvType").val() == "initiator") {
        	$("#apvClass").val("").attr("disabled", true);
        	$("#ruleId").val("").attr("disabled", true);
        }
        else {
	        if ($("#apvClass").val() == "") {
	        	$("#apvClass").val("MASTER");
	        }
	        
	        if ($("#apvClass").val() != "MASTER") {
		        if ($("#apvClass").val() == "DFIELD") {
		        	$("#spanApvClassAtt01").show();
		        }
	        	$("#ruleId").val("").attr("disabled", true);
	        }
	    }
        */
        void_apvType_onchange();
		
    });

    // 추가/수정/삭제 버튼 클릭시 실행
    function clickBtn(type) {
    	var sApvID = CFN_GetQueryString("apvid");
        if (type == "del") {
            parent.gridItem("del", sApvID);
        }
        else {
        	// 명칭
            if ($("#apvName").val() == '') {
                parent.Common.Warning("<spring:message code='Cache.msg_apv_016'/>", "", function() { // 명칭을 입력하여 주십시오.
                	$("#apvName").focus();
                });
                return;
            }

            if ($("#apvName").val().indexOf(",") >= 0) {
                parent.Common.Warning("명칭에 콤마(,)는 사용할 수 없습니다.", "", function() { // 명칭에 콤마(,)는 사용할 수 없습니다.
                	$("#apvName").val($("#apvName").val().replace(/,/gi, ""));
                	$("#apvName").focus();
                });
                return;
            }
            
        	// 유형
            if ($("#apvClass").val() == 'DFIELD') {
                if ($("#apvClassAtt01").val() == '') {
                    parent.Common.Warning("사용할 dField의 ID를 입력하여 주십시오.", "", function() { // 사용할 dField의 ID를 입력하여 주십시오.
                    	$("#apvClassAtt01").focus();
                    });
                    return;
                }

                if (/\W/.test($("#apvClassAtt01").val())) {
                    parent.Common.Warning("dField의 ID는 영문(대/소문자), 숫자, '_' 만 허용됩니다.", "", function() { // dField의 ID는 영문(대/소문자), 숫자, '_' 만 허용됩니다.
                    	$("#apvClassAtt01").focus();
                    });
                    return;
                }
            }
        	
        	// 구분
            if ($("#apvType").val() == "initiator") {
                if ($("#ruleId").val() != '') {
                    parent.Common.Warning("<spring:message code='Cache.msg_apv_setRuleIdErrorMsg'/>", "", function() { // 타입이 initiator일때 구분은 선택할 수 없습니다.
                    	$("#ruleId").focus();
                    });
                    return;
                }
            }
            if($("#sort").val() == "") $("#sort").val("0");
            
            var sApvClass = "";
            var sApvClassAtt01 = "";
            if (($("#apvClass").val() != "") &&
           		($("#apvClass").val() != "MASTER")) {
            	sApvClass = $("#apvClass").val();
    	        if ($("#apvClass").val() == "DFIELD") {
    	        	sApvClassAtt01 = $("#apvClassAtt01").val();
    	        }
            }
            var sRuleId = "0";
            if ($("#ruleId").val() != "") {
            	sRuleId = $("#ruleId").val();
            }
            var sSort = "0";
            if ($("#sort").val() != "") {
            	sSort = $("#sort").val();
            }
            var oParams = new Object();
            oParams.apvName = $("#apvName").val();
            oParams.itemId = CFN_GetQueryString("itemid");
            oParams.itemCode = Base64.b64_to_utf8(CFN_GetQueryString("itemcode"));
            oParams.ruleId = sRuleId;
            oParams.apvType = $("#apvType").val();
            oParams.sort = sSort;
            oParams.apvDesc = $("#apvDesc").val();
            oParams.apvId = sApvID;
            oParams.apvClass = sApvClass;
            oParams.apvClassAtt01 = sApvClassAtt01;

            var sMessage = "";
            var sUrl = "";
            if (type == "add") {
            	sMessage = "<spring:message code='Cache.msg_RURegist'/>";
            	sUrl = "insertRuleManagement.do";
            }
            else {
            	sMessage = "<spring:message code='Cache.msg_apv_294'/>";
            	sUrl = "updateRuleManagement.do";
            }
            
            parent.Common.Confirm(sMessage, "", function (confirmResult) {
                if (confirmResult) {
                     $.ajax({
                        type : "POST",
                        data : oParams,
                        url : sUrl,
                        success:function (data) {
                        	if (data.status == "FAIL") {
                        		parent.Common.Error(data.message);
                        		return;
                        	}
                            var obj = parent.tree.getSelectedList();
                            if (data.result == "ok" && !parent.axf.isEmpty(obj.item)) {
                           		Common.Close();
                                parent.setGrid();			// 그리드 세팅
                                parent.search(obj.item.no);	// 검색
                            }
                            else {
                        		parent.Common.Error(JSON.stringify(data));
                        		return;
                        	}
                        },
                        error:function(response, status, error){
                            CFN_ErrorAjax(url, response, status, error);
                        }
                    });
                } else {
                    return false;
                }
            });
        }
    }

    // 팝업 닫기
    function closeLayer() {
        Common.Close();
    }

    // 타입 변경시 호출
    // initiator 인 경우, 유형/구분 입력 못하도록 함.
    function void_apvType_onchange() {
    	switch ($("#apvType").val()) {
	    	case "initiator": // 기안자
	        	//initiator 선택의 경우, 유형/구분 입력 못하도록 함.
	        	$("#apvClass").val("").attr("disabled", true);
	        	$("#ruleId").val("").attr("disabled", true);
	    		break;
	    	case "receive": // 수신자
	    	case "ccinfo": // 사후참조
	    	case "ccinfo-before": // 사전참조
	        	$("#apvClass").val("MASTER").attr("disabled", true);
	    		break;
    		default:
	        	$("#apvClass").removeAttr("disabled");
	        	if ($("#apvClass").val() == "") {
	        		// 유형 선택이 안된 경우, 전결규정 마스터 사용으로 강제 설정
		        	$("#apvClass").val("MASTER");
	        	}
   				break;
    	}
    	
    	ValidJFData();
    	void_apvClass_onchange();
    }
    
    // 마스터(구분) 중 담당업무 제어
    function ValidJFData(){
    	var sApvType = $("#apvType").val();
    	if(sApvType == "receive"){ // 수신자일때 모두표시
    		$("#ruleId option").show(); 
    	}else{ // 나머지는 담당업무 제거
    		$("#ruleId option[RuleType='6']").hide(); 
    		if($("#ruleId option:selected").attr("RuleType") == "6") $("#ruleId").val("")
    	}
    }

    // 유형 변경시 호출
    function void_apvClass_onchange() {
        if ($("#apvClass").val() == "DFIELD") {
        	$("#spanApvClassAtt01").show();
        }
        else{
        	$("#spanApvClassAtt01").hide();
        }
        
    	if ($("#apvClass").val() != "MASTER") {
	    	$("#ruleId").val("");
	    	$("#ruleId").attr("disabled", true);
		}
		else {
	    	$("#ruleId").removeAttr("disabled");
		}
    }
</script>
</head>
<body>
    <form autocomplete="off">
        <div class="sadmin_pop">
            <table class="sadmin_table sa_menuBasicSetting mb20">
                <tbody>
                    <tr>
                        <th style="width:150px;"><spring:message code='Cache.lbl_apv_Name'/></th><!-- 명칭 -->
                        <td><input id="apvName" name="apvName" class="" type="text" maxlength="64" style="width:200px;"/></td>
                    </tr>
                    <tr>
                        <th style="width:150px;"><spring:message code='Cache.lbl_apv_type'/></th><!-- 타입 -->
                        <td><select id="apvType" name="apvType" class="selectType02 w200p" onchange="void_apvType_onchange()"></select></td>
                    </tr>
                    <tr>
                        <th style="width:150px;"><spring:message code='Cache.lbl_type'/></th><!-- 유형 -->
                        <td>
                        	<select id="apvClass" name="apvClass" class="selectType02 w200p" onchange="void_apvClass_onchange();"></select>
                        	<span id="spanApvClassAtt01" style="display: none;">
	                        	<span>( ID :</span>
	                        	<input type="text" id="apvClassAtt01" name="apvClassAtt01" class="" style="width: 100px;" maxlength="20" />
	                        	<span>)</span>
                        	</span>
                        </td>
                    </tr>
                    <tr>
                        <th style="width:150px;"><spring:message code='Cache.lbl_apv_gubun'/></th><!-- 구분 -->
                        <td><select id="ruleId" name="ruleId" class="selectType02 w200p"></select></td>
                    </tr>
                    <tr>
                        <th style="width:150px;"><spring:message code='Cache.lbl_apv_desc'/></th><!-- 설명 -->
                        <td><textarea id="apvDesc" name="apvDesc" style="width:202px;height:50px;resize:none;"></textarea></td>
                    </tr>
                    <tr>
                        <th style="width:150px;"><spring:message code='Cache.lbl_apv_SortKey'/></th>
                        <td><input id="sort" name="sort" class="" type="number" maxlength="64" style="width:200px;" oninput="this.value = this.value.replace(/[^0-9.]/g, '').replace(/(\..*)\./g, '$1');"/></td>
                    </tr>
                </tbody>
            </table>
            <div class="bottomBtnWrap">
				<a id="addBtn" href="#" class="btnTypeDefault btnTypeBg" onclick="clickBtn('add');" ><spring:message code="Cache.btn_apv_add"/></a>
				<a id="updBtn" href="#" class="btnTypeDefault btnTypeBg" onclick="clickBtn('upd');" ><spring:message code="Cache.btn_apv_update"/></a>
				<a id="delBtn" href="#" class="btnTypeDefault" onclick="clickBtn('del');" style="display:none"><spring:message code="Cache.btn_apv_delete"/></a>
				<a href="#" class="btnTypeDefault" onclick="closeLayer();" ><spring:message code="Cache.btn_apv_close"/></a>
			</div>
        </div>
        
    </form>
</body>
</html>