<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<style>
/* 	input[type="checkbox"] { margin-right: 3px; } */
	.mt10 { margin-top: 10px; }
	.mt20 { margin-top: 20px; }
	
	.schemaOptionBottom {
		position:absolute;
		bottom:0px;
		text-align:center;
	}
	#divSchemaInfo {
		height:440px;
		position:relative;
		overflow:auto;
	}
	.legacyOptions .chkStyle01 {
		margin-top:2px;
		margin-bottom:2px;
	}
</style>
<script>
	var mode = CFN_GetQueryString("mode");
	var SCHEMA_ID = CFN_GetQueryString("id");
	var processtype = "";
	$(document).ready(function() {
		
		// init Domain Select
		$("#domainID").coviCtrl("setSelectOption", "/approval/common/getEntInfoListAssignIdData.do");
		
		coviInput.setDate();
		setSelect();
		
		// 공공데모는 타시스템 연동 탭 가리기
		/* 2023.02.09 공공데모 최신패치 관련, hgsong
		if(location.href.indexOf("gov.covismart.com") > -1)
			$("a[value='optionTab_link']").css("display", "none");
		*/

		//select 기본값 지정
		$("#selscApvLineType option:eq(1)").attr("selected", "selected");
		$("#selscDNum option:eq(10)").attr("selected", "selected");

		if (mode == "modify") {
			$("#btnSaveAs").show();
			$("#btnDelete").show();

			setData();
			if($("input[name=pdef]").val().toLowerCase().match("draft")){
				setOption("Draft");
			}else if($("input[name=pdef]").val().toLowerCase().match("request")){
				setOption("Request");
			}
		}else{
			//$("input[name=scRecDoc]").prop("checked",true);
			setOption("Draft");
		}
		
		$("#selscDNum").change(function() {
		     $("#selscDNum option:selected").each(function() {
		    	 if($(this).val() == "99"){
		    		 $("input[name=scDNumExt]").prop("checked",true);	
		    	 }else{
		    		 $("input[name=scDNumExt]").prop("checked",false);	
		    	 }
		     });
		});		
	});	

	// 탭 클릭 이벤트
	function clickTab(pObj) {
		var strObjName = $(pObj).attr("value");
		$(".tabMenu > li").removeClass("active");
		$(pObj).parent("li").addClass("active");

		$("#divSchemaInfo > div").removeClass("active");
		//$("#" + strObjName).css({"margin-top":"10px", "min-height": "450px", "max-height": "490px"});
		//$("#" + strObjName).show();
		$("#" + strObjName).addClass("active");
		
		coviInput.setDate();
		setSelect();
	}

	// 레이어 팝업 닫기
	function closeLayer() {
		Common.Close();
	}
	
	function setOption(type){
		if(type == "Draft"){
			$("[data-processtype=Draft]:not([visibleFixed])").show();
			$("[data-processtype=Request]:not([visibleFixed])").hide();	
			processtype = "Draft";
		}
		else{
			$("[data-processtype=Draft]:not([visibleFixed])").hide()
			$("[data-processtype=Request]:not([visibleFixed])").show();
			processtype = "Request";
		}	
	}

	// select setting
	function setSelect() {
		$("#selscApvLineType").bindSelect({
			reserveKeys : {
				optionValue : "value",
				optionText : "name"
			},
			options : [ {
				"name" : "Section Type",
				"value" : "1"
			}, {
				"name" : "Table Type",
				"value" : "2"
			} ]
		});
		//임시로 값 지정
		/*$("#selpdef").bindSelect({
			reserveKeys : {
				optionValue : "value",
				optionText : "name"
			},
			options : [ {
				"name" : "Draft",
				"value" : "Draft"
			}, {
				"name" : "Request",
				"value" : "Request"
			} ],
			onchange:function (item) {
				setOption(item.value);		
			}
		});
		*/

		$("#selscDNum").bindSelect({
			reserveKeys : {
				optionValue : "value",
				optionText : "name"
			},
			options : [ {
				"name" : "기본(부서명-YYYY-일련번호(4))",
				"value" : "0"
			}, {
				"name" : "1-부서약어:분류번호-일련번호(4)",
				"value" : "1"
			}, {
				"name" : "2-부서약어-일련번호(4)",
				"value" : "2"
			}, {
				"name" : "3-부서약어YYYY-일련번호(4)",
				"value" : "3"
			}, {
				"name" : "4-부서약어 분류번호-일련번호(4)",
				"value" : "4"
			}, {
				"name" : "5-부서약어-YYMM-일련번호(4)",
				"value" : "5"
			}, {
				"name" : "6-부서약어-YYYY-일련번호(4)",
				"value" : "6"
			}, {
				"name" : "7-부서약어 YYYY - 일련번호(4)",
				"value" : "7"
			}, {
				"name" : "8-회사명-일련번호(4)(회사별발번)",
				"value" : "8"
			}, {
				"name" : "9-부서약어 제 YY - 일련번호(4)호",
				"value" : "9"
			}, {
				"name" : "10-부서코드 YY-일련번호(5)",
				"value" : "10"
			}, {
				"name" : "11-회사명-YYYY-일련번호(4)",
				"value" : "11"
			}, {
				"name" : "12-문서분류-YYYY-일련번호(4)",
				"value" : "12"
			}, {
				"name" : "99-정규식지정",
				"value" : "99"
			} ]
		});
		
		$("#domainID").bindSelect({});
	}

	// 수정모드일 시 data setting
	function setData() {

		var JSONObj;
		
		$.ajax({
			url : "/approval/manage/getschemainfo.do",
			type : "post",
			data : {
				SCHEMA_ID : SCHEMA_ID
			},
			async : false,
			success : function(res) {
				if (res.data != null && res.data != undefined) {
					JSONObj = res.data;
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/manage/getschemainfo.do", response, status, error);
			}
		});

		if (JSONObj != null && JSONObj != undefined) {
			var context = JSONObj.map[0].SCHEMA_CONTEXT;

			if(typeof JSONObj.map[0]["DOMAIN_ID"] != "undefined"){
				$("#domainID").bindSelectSetValue(JSONObj.map[0]["DOMAIN_ID"]);				
			}

			for ( var d in context) {
				//if (context[d].isUse == "Y" && ($("input[name=" + d + "]").length > 0)) {
				if (($("input[name=" + d + "]").length > 0)) {
					if(d=="scCC"){
						if(context[d].value == "YY"){
							$("input[name=scCCPerson]").prop("checked",true);							
							$("input[name=scCCOu]").prop("checked",true);
						}else if(context[d].value == "YN"){
							$("input[name=scCCPerson]").prop("checked",true);							
							$("input[name=scCCOu]").prop("checked",false);
						}else if(context[d].value == "NN"){
							$("input[name=scCCPerson]").prop("checked",false);							
							$("input[name=scCCOu]").prop("checked",false);
						}else if(context[d].value == "NY"){
							$("input[name=scCCPerson]").prop("checked",false);							
							$("input[name=scCCOu]").prop("checked",true);
						}else{
							// default
							context[d].value = "YY";
							$("input[name=scCCPerson]").prop("checked",true);							
							$("input[name=scCCOu]").prop("checked",true);							
						}
						$("input[name=" + d + "]").val(context[d].value);
					}
					if(d=="scLegacy"){
						if(context[d].value.scLegacyDraft == "Y"){
							$("input[name=scLegacyDraft]").prop("checked",true);
						}
						if(context[d].value.scLegacyComplete == "Y"){
							$("input[name=scLegacyComplete]").prop("checked",true);
						}
						if(context[d].value.scLegacyDistComplete == "Y"){
							$("input[name=scLegacyDistComplete]").prop("checked",true);
						}
						if(context[d].value.scLegacyReject == "Y"){
							$("input[name=scLegacyReject]").prop("checked",true);
						}
						if(context[d].value.scLegacyChargeDept == "Y"){
							$("input[name=scLegacyChargeDept]").prop("checked",true);
						}
						if(context[d].value.scLegacyOtherSystem == "Y"){
							$("input[name=scLegacyOtherSystem]").prop("checked",true);
						}
						if(context[d].value.scLegacyInBound == "Y"){
							$("input[name=scLegacyInBound]").prop("checked",true);
						}
						if(context[d].value.scLegacyOutBound == "Y"){
							$("input[name=scLegacyOutBound]").prop("checked",true);
						}
						if(context[d].value.scLegacyWithdraw == "Y"){
							$("input[name=scLegacyWithdraw]").prop("checked",true);
						}
						if(context[d].value.scLegacyDelete == "Y"){
							$("input[name=scLegacyDelete]").prop("checked",true);
						}
						$("[name=" + d + "]").val(JSON.stringify(context[d].value));
					}
					if (d=="scFormAddInApvLine") {
						$("input[name=scFormAddInApvLineUseOrg]").prop("checked", (context[d].value == "Y" ? true : false));
					}
					
					if(d=="scComment"){
						if(context[d].value.rdoscCmt_Approver == "Y"){
							$("#rdoscCmt_Approver").prop("checked",true);
						}
						if(context[d].value.rdoscCmt_Everyone == "Y"){
							$("#rdoscCmt_Everyone").prop("checked",true);
						}
						if(context[d].value.scCmtModify == "Y"){
							$("input[name=scCmtModify]").prop("checked",true);
						}
						if(context[d].value.scCmtDelete == "Y"){
							$("input[name=scCmtDelete]").prop("checked",true);
						}
						if(context[d].value.scCmtReplyTo == "Y"){
							$("input[name=scCmtReplyTo]").prop("checked",true);
						}
						if(context[d].value.scCmtReplyAdd == "Y"){
							$("input[name=scCmtReplyAdd]").prop("checked",true);
						}
						if(context[d].value.scCmtEdit == "Y"){
							$("input[name=scCmtEdit]").prop("checked",true);
						}
						if(context[d].value.scCmtAttach == "Y"){
							$("input[name=scCmtAttach]").prop("checked",true);
						}
						if(context[d].value.scCmtShowType == "Y"){
							$("input[name=scCmtShowType]").prop("checked",true);
						}

						$("[name=" + d + "]").val(JSON.stringify(context[d].value));
					}
					
					$("[name=" + d + "]").each(function() {
						if ($(this).attr("type") == "checkbox") {
							if (context[d].isUse == "Y"){
								$(this).attr("checked", "checked")
							}
							// default checked 항목을 고려하여 isUse N 인경우도 처리한다.
							else {
								$(this).removeAttr("checked");	
							}
						} else {
							if($(this).attr("type") == "text" && (typeof context[d].value == "object")){
								$(this).val(JSON.stringify(context[d].value));
							}else{
								$(this).val(context[d].value);
							}
						}
					});
				}
			}
		}
	}
	
	
	function evaluateSchema() {
		if (!$("#scnm").val()) {
	        Common.Warning("<spring:message code='Cache.msg_setshemaname' />"); return false; // 서식스키마 명칭을 입력하세요
	    }
	    if(!$("input[name='pdef']").val()){
	        Common.Warning("<spring:message code='Cache.msg_setSchemaProcessDef' />"); return false; // Process Definition을 설정해주세요.
		}
	    
	    if(
	    	$("input[type=checkbox][name=scPRec]").is(":checked") || $("input[type=checkbox][name=scPRecEnt]").is(":checked") || $("input[type=checkbox][name=scPRecReg]").is(":checked")
	    	|| $("input[type=checkbox][name=scPRecA]").is(":checked") || $("input[type=checkbox][name=scPRecAEnt]").is(":checked") || $("input[type=checkbox][name=scPRecAReg]").is(":checked")
	    	|| $("input[type=checkbox][name=scDRec]").is(":checked") || $("input[type=checkbox][name=scDRecEnt]").is(":checked") || $("input[type=checkbox][name=scDRecReg]").is(":checked")
	    	|| $("input[type=checkbox][name=scChgr]").is(":checked") || $("input[type=checkbox][name=scChgrEnt]").is(":checked") || $("input[type=checkbox][name=scChgrReg]").is(":checked")
	    	|| $("input[type=checkbox][name=scChgrOU]").is(":checked") || $("input[type=checkbox][name=scChgrOUEnt]").is(":checked") || $("input[type=checkbox][name=scChgrOUReg]").is(":checked")
	    ){
	    	var chkCntPRec = 0; // 수신자
	        chkCntPRec += ($("input[type=checkbox][name=scPRec]").is(":checked") ? 1 : 0);
	        chkCntPRec += ($("input[type=checkbox][name=scPRecEnt]").is(":checked") ? 1 : 0);
	        chkCntPRec += ($("input[type=checkbox][name=scPRecReg]").is(":checked") ? 1 : 0);
	        var chkCntPRecA = 0; // 수신결재자
	        chkCntPRecA += ($("input[type=checkbox][name=scPRecA]").is(":checked") ? 1 : 0);
	        chkCntPRecA += ($("input[type=checkbox][name=scPRecAEnt]").is(":checked") ? 1 : 0);
	        chkCntPRecA += ($("input[type=checkbox][name=scPRecAReg]").is(":checked") ? 1 : 0);
	        var chkCntDRec = 0; // 수신부서
	        chkCntDRec += ($("input[type=checkbox][name=scDRec]").is(":checked") ? 1 : 0);
	        chkCntDRec += ($("input[type=checkbox][name=scDRecEnt]").is(":checked") ? 1 : 0);
	        chkCntDRec += ($("input[type=checkbox][name=scDRecReg]").is(":checked") ? 1 : 0);
	        var chkCntChgr = 0; // 담당업무
	        chkCntChgr += ($("input[type=checkbox][name=scChgr]").is(":checked") ? 1 : 0);
	        chkCntChgr += ($("input[type=checkbox][name=scChgrEnt]").is(":checked") ? 1 : 0);
	        chkCntChgr += ($("input[type=checkbox][name=scChgrReg]").is(":checked") ? 1 : 0);
	        var chkCntChgrOU = 0; // 담당부서
	        chkCntChgrOU += ($("input[type=checkbox][name=scChgrOU]").is(":checked") ? 1 : 0);
	        chkCntChgrOU += ($("input[type=checkbox][name=scChgrOUEnt]").is(":checked") ? 1 : 0);
	        chkCntChgrOU += ($("input[type=checkbox][name=scChgrOUReg]").is(":checked") ? 1 : 0);
	        
	        var chkAll = chkCntPRec + chkCntDRec + chkCntChgr + chkCntChgrOU; // 수신결재자 제외 전체
	        if(chkAll > 1){
	        	if(chkAll == 2 && chkCntPRec == 1 && chkCntDRec == 1){}
	        	else{
	        		Common.Warning("<spring:message code='Cache.msg_adminReceiptDup' />"); return false; // 수신처 지정 방식(수신자/수신부서, 담당업무, 담당부서) 중 하나만 선택해주세요. (단, 수신자/수신부서는 각각 1개 유형씩 동시 선택이 가능 합니다.)
	        	}
	        }
	        if(chkCntPRecA > 1){
	        	Common.Warning("<spring:message code='Cache.msg_adminReceiptApproverDup' />"); return false; // 수신결재자사용 유형중 하나만 선택해주세요.
	        }else if(chkCntPRecA > 0 && chkAll == 0){
	        	Common.Warning("<spring:message code='Cache.msg_adminReceiptApprover' />"); return false;		// 수신결재자 사용시 수신처 지정 방식(수신자, 수신부서, 담당업무, 담당부서) 중 하나를 함께 선택해주세요. 
	        }
	    }
	    
	    if ($("input[type=checkbox][name=scChgr]").is(":checked") && $("input[type=text][name=scChgr]").val() == ""
	    	|| $("input[type=checkbox][name=scChgrEnt]").is(":checked") && $("input[type=text][name=scChgrEnt]").val() == ""
	    	|| $("input[type=checkbox][name=scChgrReg]").is(":checked") && $("input[type=text][name=scChgrReg]").val() == "") {
	        Common.Warning("<spring:message code='Cache.msg_apv_019' />"); return false;		//담당자사용의 결재업무담당자를 선택하십시요
	    }
	    if ($("input[type=checkbox][name=scChgrOU]").is(":checked") && $("input[type=text][name=scChgrOU]").val() == ""
	    	|| $("input[type=checkbox][name=scChgrOUEnt]").is(":checked") && $("input[type=text][name=scChgrOUEnt]").val() == ""
	    	|| $("input[type=checkbox][name=scChgrOUReg]").is(":checked") && $("input[type=text][name=scChgrOUReg]").val() == "") {
	        Common.Warning("<spring:message code='Cache.msg_apv_020' />"); return false;		//담당부서사용의 결재업무담당부서를 선택하십시요
	    }
	    if ($("input[type=checkbox][name=scPRecA]").is(":checked") && $("input[type=text][name=scPRecA]").val() == ""
	    	|| $("input[type=checkbox][name=scPRecAEnt]").is(":checked") && $("input[type=text][name=scPRecAEnt]").val() == ""
	    	|| $("input[type=checkbox][name=scPRecAReg]").is(":checked") && $("input[type=text][name=scPRecAReg]").val() == "") {
	        Common.Warning("<spring:message code='Cache.msg_apv_530' />"); return false;		//수신결재자사용의 결재자를 선택해주세요.
	    }
	    
	    if ($("input[type=checkbox][name=scDNum]").is(":checked") && $("select#selscDNum option:selected").val() != "99"){
	    	$("input[type=checkbox][name=scDNumExt]").prop("checked",false);
	    }
	    
	    if ($("input[name=scDNum]").is(":checked") && $("#selscDNum option:selected").val() == "99"){
			$("input[name=scDNumExt]").prop("checked",true);	
	    	if ($("input[id=scDNumExtVal]").val() == "" ){
		        	Common.Warning("<spring:message code='Cache.msg_apv_scDNumExt' />"); return false;		//문서번호 정규식을 입력하세요
	    	}
	    }
	    
	    return true;
	}

	// 저장버튼 클릭
	function btnSave_Click() {
		if(!evaluateSchema()){
			return;
		}
		
		var data = {};

		data["mode"] = (SCHEMA_ID == "") ? "add" : mode;
		data["SCHEMA_ID"] = (mode == "modify") ? SCHEMA_ID : Common.getUUID();
		data["SCHEMA_NAME"] = $("input[name=name]").val();
		data["SCHEMA_DESC"] = $("input[name=desc]").val();
		data["SCHEMA_CONTEXT"] = JSON.stringify(makeJSON());
		data["DOMAIN_ID"] = $("select#domainID").val();
		
		$.ajax({
			url : "/approval/manage/setschemainfo.do",
			type : "post",
			data : data,
			async : false,
			success : function(res) {
				if (res.data == 1) {
					Common.Inform("<spring:message code='Cache.msg_37' />", "Inform", function() {		//저장되었습니다.
						parent.cmdSearch(); //parent.Refresh();
						Common.Close();
					});
				} else {
					Common.Error(res.message, "Error");
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/manage/setschemainfo.do", response, status, error);
			}
		});
	}

	// 다른 이름으로 저장 버튼 클릭
	function btnSaveAs_Click() {
		mode = "add";
		btnSave_Click();
	}

	// 삭제 버튼 클릭
	function btnDelete_Click() {
		var data = {};

		data["SchemaID"] = SCHEMA_ID;

		$.ajax({
			url : "/approval/manage/deleteschemainfo.do",
			type : "post",
			data : data,
			async : false,
			success : function(res) {
				if (res.status == "SUCCESS") {
					Common.Inform(res.message, "Inform", function() {			//삭제되었습니다.
						parent.Refresh();
						Common.Close();
					});
				} else if (res.status == "NODATA"){
					Common.Warning(res.message);
				} else {
					Common.Error(res.message, "Error");
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/manage/deleteschemainfo.do", response, status, error);
			}
		});
	}
	// 함수(수정필요)
	function editList(sCallType, szObject) {
	    if ($("input[type=checkbox][name=" + szObject + "]").is(":checked")) {	
        	ParamszObject = szObject;
        	parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>","/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod2&szObject="+szObject+"&type="+sCallType+"&setParamData=_setParamdata","1060px","580px","iframe",true,null,null,true); 	            
	    } else {
	        switch (szObject) {
	            case "scPAdt": Common.Warning("<spring:message code='Cache.msg_apv_232' />"); break; // 개인감사사용을 선택하셔야 합니다.
	            case "scDAdt": Common.Warning("<spring:message code='Cache.msg_apv_234' />"); break; // 부서감사사용을 선택하셔야 합니다.
	            case "scPAdt1": Common.Warning("<spring:message code='Cache.msg_apv_280' />"); break; // 개인준법사용을 선택하셔야 합니다.
	            case "scDAdt1": Common.Warning("<spring:message code='Cache.msg_apv_281' />"); break; // 부서준법사용을 선택하셔야 합니다.
	            case "scChgrOU": Common.Warning("<spring:message code='Cache.msg_apv_021' />"); break;			//담당부서를 선택하셔야 합니다
	            case "scReviewFix": Common.Warning("<spring:message code='Cache.msg_apv_293' />"); break;		//공람자를 선택하셔야 합니다.
	            case "scCAt1": Common.Warning("<spring:message code='Cache.msg_apv_284' />"); break;				//사용자정의1을 선택하셔야 합니다.
	            case "scIPub": Common.Warning("<spring:message code='Cache.lbl_selectuse_distribution' />"); break;			//사용자정의1을 선택하셔야 합니다.
	            case "scChgrPerson": Common.Warning("<spring:message code='Cache.msg_apv_347' />"); break; // 담당수신자를 선택 하셔야 합니다.
	            case "scPRec": Common.Warning("<spring:message code='Cache.msg_apv_353' />"); break; // 수신자사용을 선택 하셔야 합니다.
	            case "scDRec": Common.Warning("<spring:message code='Cache.msg_apv_531' />"); break; // 수신부서사용을 선택 하셔야 합니다.
	        }
	    }
	}
	parent._setParamdata = setParamdata;
	function setParamdata(paramszObject){
		return setszObj[paramszObject];
	}
	
	var ParamszObject = "";
	var setszObj = new Object();
	//조직도선택후처리관련
	parent._CallBackMethod2 = setMGRDEPTLIST;
	function setMGRDEPTLIST(peopleValue){
		var dataObj = $.parseJSON(peopleValue);	
		var UR_Data;
		var textName;
		textName = ParamszObject;

		var strOURec = ""; //fix 수신처 리스트
		var strPersonRec = ""; //fix 수신자 리스트

		var strOURecList = ""; //fix 수신처 리스트
		var strPersonRecList = ""; //fix 수신자 리스트
		
		$("input[type=text][name=" + textName + "]").empty();
		$(dataObj.item).each(function(i){
			// [19-01-24] kimhs, 배포처의 경우 저장되는 포맷이 상이하여 별도로 분기처리함.
			if(textName == "scIPub") {
				if (dataObj.item[i].itemType == "user") {
					strPersonRec += ";" + "1:" + dataObj.item[i].AN + ":" + dataObj.item[i].DN.replace(/;/gi, "^") + ":X" + ":" + dataObj.item[i].RG;
	                strPersonRecList += ";" + dataObj.item[i].AN + "|X";
				} else if(dataObj.item[i].itemType == "group"){
	                strOURec += ";" + "0:" + dataObj.item[i].AN + ":" + dataObj.item[i].DN.replace(/;/gi, "^") + ":N";
	                strOURecList += ";" + dataObj.item[i].AN + "|N";
	            }
				
				if (strOURec.indexOf(";") == 0) strOURec = strOURec.substring(1, strOURec.length);
		        if (strPersonRec.indexOf(";") == 0) strPersonRec = strPersonRec.substring(1, strPersonRec.length);
		        if (strOURecList.indexOf(";") == 0) strOURecList = strOURecList.substring(1, strOURecList.length);
		        if (strPersonRecList.indexOf(";") == 0) strPersonRecList = strPersonRecList.substring(1, strPersonRecList.length);
		        $("input[type=text][name=" + textName + "]").val(strOURec + ";" + strPersonRec + ";" + "||" + strOURecList + "@" + strPersonRecList + "@");
			}
			else if(textName == "scChgrOU") {
				var scChgrOUValue = $("input[type=text][name=" + textName + "][type='text']").val();
			
				$("input[type=text][name=" + textName + "][type='text']").val(scChgrOUValue + (scChgrOUValue != "" ? "^" : "") + dataObj.item[i].AN+"@"+dataObj.item[i].DN);
				setszObj[textName] = peopleValue;
			}
			else if(textName == "scDAdt" || textName == "scDAdt1") {
				$("input[type=text][name=" + textName + "]").val(dataObj.item[0].AN+"@@"+dataObj.item[0].DN+"@@"+peopleValue);			
				$("input[type=text][name=" + textName + "]").attr('value',dataObj.item[0].AN+"@@"+dataObj.item[0].DN+"@@"+peopleValue);
				setszObj[textName] = peopleValue;
			}
			else if(textName == "scPRec" || textName == "scDRec"){
				if(dataObj.item[i].itemType == "user"){
					var PRpeopleValue = '{"item":['+JSON.stringify(dataObj.item[i])+'],"userParams":""}'
					if(i == 0){
						$("input[type=text][name=" + textName + "]").val(dataObj.item[i].AN+"@@"+dataObj.item[i].DN+"@@"+PRpeopleValue);
					}else{
						$("input[type=text][name=" + textName + "]").val($("input[type=text][name=" + textName + "]").val()+"||"+dataObj.item[i].AN+"@@"+dataObj.item[i].DN+"@@"+PRpeopleValue);
					}
					// ???
					$("input[type=text][name=" + textName + "]").attr('value',$("input[type=text][name=" + textName + "]").val());
					setszObj[textName] = peopleValue;
				}else if(dataObj.item[i].itemType == "group"){
					var PRpeopleValue = '{"item":['+JSON.stringify(dataObj.item[i])+'],"userParams":""}'
					if(i == 0){
						$("input[type=text][name=" + textName + "]").val(dataObj.item[i].AN+"@@"+dataObj.item[i].DN);
					}else{
						$("input[type=text][name=" + textName + "]").val($("input[type=text][name=" + textName + "]").val()+"||"+dataObj.item[i].AN+"@@"+dataObj.item[i].DN);
					}
					// ???
					$("input[type=text][name=" + textName + "]").attr('value',$("input[type=text][name=" + textName + "]").val());
					setszObj[textName] = peopleValue;
				}
			}
			else{
				if(dataObj.item[i].itemType == "user"){	
					$("input[type=text][name=" + textName + "]").val(dataObj.item[0].AN+"@@"+dataObj.item[0].DN+"@@"+peopleValue);			
					$("input[type=text][name=" + textName + "]").attr('value',dataObj.item[0].AN+"@@"+dataObj.item[0].DN+"@@"+peopleValue);
					setszObj[textName] = peopleValue;
				}else if(dataObj.item[i].itemType == "group"){
					//$("input[name=" + textName + "]").attr('value',peopleValue);				
					$("input[type=text][name=" + textName + "]").val(dataObj.item[0].AN+"@"+dataObj.item[0].DN);
					$("input[type=text][name=" + textName + "]").attr('value',dataObj.item[0].AN+"@"+dataObj.item[0].DN);
					setszObj[textName] = peopleValue;
				}	
			}
		});
	}
	
	// [2015-03-09 add] 수신결재자 멀티선택(수정필요)
	function setscPRecA(sTarget) {
		var sTitle = "<spring:message code='Cache.lbl_receiver_apv' />"; // 수신결재자 셋팅
		
		if ($("input[type=checkbox][name=" + sTarget + "]").is(":checked")) {	
			parent.Common.open("", "FormAutoRecApvSet",
					sTitle,
					"/approval/manage/goFormAutoRecApvSet.do?type=&kind=PRecA&targetID=" + sTarget +"&openID="+ CFN_GetQueryString("CFN_OpenLayerName") + "&OpenFrom=FormAutoRecApvSet", "500px", "400px",
					"iframe", true, null, null, true);
	    } else {
	        Common.Warning("<spring:message code='Cache.msg_apv_354' />"); // 수신결재자사용을 선택 하셔야 합니다.
	    }
		
	}
	
	//조직도선택후처리관련
	parent._setNomalValue = setNomalValue;
	function setNomalValue(pObj,pdata){
		$("input[name=" + pObj + "]").val(pdata);
	}
	
	function onclick_scCC() {
 	    //참조 선택
 	    if ($("input[type=checkbox][name=scCC]").is(":checked")) {
	        var szscCC = "";
	        if ($("input[type=checkbox][name=scCCPerson]").is(":checked")) {
	            szscCC = "Y";
	        } else {
	            szscCC = "N";
	        }
	        if ($("input[type=checkbox][name=scCCOu]").is(":checked")) {
	            szscCC += "Y";
	        } else {
	            szscCC += "N";
	        }
	        $("input[name=scCC]").attr('value',szscCC);
	    } else {
			if (!$("input[type=checkbox][name=scCCPerson]").is(":checked") && !$("input[type=checkbox][name=scCCOu]").is(":checked")) {
			} else {
				$("input[type=checkbox][name=scCCPerson],input[type=checkbox][name=scCCOu]").prop("checked", false);
				if($(event.target).prop("name") != "scCC"){
				    Common.Warning("<spring:message code='Cache.msg_apv_252' />");  //"참조사용을 선택한 후 설정을 하십시오."
				}
			}
			$("input[type=text][name=scCC]").val('NN');
	    }  
	}
	
	//담당부서, 담당업무 유형별 팝업
	function setChgrType(sCallType, kind) {
		var sTitle = "";
		var sTarget = "sc" + kind;
		
		if(sCallType == "E") sTarget += "Ent";
		else if(sCallType == "R") sTarget += "Reg";
		
		if ($("input[type=checkbox][name=" + sTarget + "]").is(":checked")) {	
        	if(kind == "PRec") sTitle = "<spring:message code='Cache.lbl_apv_responsibilities_person_kindset' />"; // 수신자 유형별 셋팅
			else if(kind == "Chgr") sTitle = "<spring:message code='Cache.lbl_apv_responsibilities_kindset' />"; // 담당업무 유형별 세팅
			else if(kind == "ChgrOU") sTitle = "<spring:message code='Cache.lbl_apv_responsibilities_dept_kindset' />"; // 담당부서 유형별 세팅
			else if(kind == "PRecA") sTitle = "<spring:message code='Cache.lbl_apv_responsibilities_personA_kindset' />"; // 수신결재자 유형별 셋팅
			else if(kind == "DRec") sTitle = "<spring:message code='Cache.lbl_apv_responsibilities_rDept_kindset' />"; // 수신부서 유형별 셋팅
        		
			parent.Common.open("", "FormAutoApvSet",
				sTitle,
				"/approval/manage/goFormAutoApvSet.do?type="+sCallType+"&kind="+kind+"&targetID="+sTarget+"&openID=div_setwfschema&OpenFrom=FormAutoSet", "500px", "400px",
				"iframe", true, null, null, true);
	    } else {
	        switch (kind) {
	            case "PRec": Common.Warning("<spring:message code='Cache.msg_apv_353' />"); break; // 수신자사용을 선택 하셔야 합니다.
	            case "Chgr": Common.Warning("<spring:message code='Cache.msg_apv_282' />"); break; // 담당업무사용을 선택하셔야 합니다.
	            case "ChgrOU": Common.Warning("<spring:message code='Cache.msg_apv_021' />"); break;			//담당부서를 선택하셔야 합니다
	            case "PRecA": Common.Warning("<spring:message code='Cache.msg_apv_354' />"); break;			//수신결재자사용을 선택 하셔야 합니다.
	            case "PRecA": Common.Warning("<spring:message code='Cache.msg_apv_354' />"); break;			//수신결재자사용을 선택 하셔야 합니다.
	            case "DRec": Common.Warning("<spring:message code='Cache.msg_apv_531' />"); break; // 수신부서사용을 선택 하셔야 합니다.
	        }
	    }
		
	}
	
	//수정필요
	var objTxtSelect = null;
	function JFList(szObject) {
	    //결재 업무 담당자 목록 보기
	    if (szObject != null) {
	        objTxtSelect = $("[type=text][name="+szObject+"]");
	    }	    
	    
	    if ( $("input[name="+szObject+"]").is(":checked")) {
	    	var sTitle = "<spring:message code='Cache.lbl_SelChargeTask'/>";		// 담당업무 선택
	    	if(szObject=="scJFBox"){
	    		sTitle = "<spring:message code='Cache.lbl_SelSCJFBox'/>";			// 특정권한함 선택
	    	}
	    	
	    	Common.open("", "JFListSelect", sTitle, "goJFListSelect.do?functionName=JFlistSchema&domainID="+$("#domainID").val(), "500px", "350px", "iframe", true, null, null, true);
	    	
	    } else {
	    	if(szObject=="scChgr"){
	    		Common.Warning("<spring:message code='Cache.msg_apv_282' />"); // 담당업무사용을 선택하셔야 합니다.
	    	}else if(szObject=="scJFBox"){
	    		Common.Warning("<spring:message code='Cache.msg_adminSCJFBox' />"); // 특정권한함를 선택하셔야 합니다.
	    	}
	    }
	}

	//담당업무 리턴
	var JFlistSchema = setobjTxtSelect;
 	function setobjTxtSelect(data){ 
 		objTxtSelect.val(data);
 	}	
	
	// json data 생성
	function makeJSON() {
		var obj = {};
		$("input[name=id],input[name=name],input[name=desc],input[name=pdef],input[name=pdefname]").each(function() {
			obj[$(this).attr("name")] = {};
			obj[$(this).attr("name")]["isUse"] = "Y"; //true;
			obj[$(this).attr("name")]["type"] = "string";
			obj[$(this).attr("name")]["value"] = $(this).val();
			obj[$(this).attr("name")]["desc"] = "";

			if ($(this).attr("name") == "id" && mode == "add")
				obj[$(this).attr("name")]["value"] = Common.getUUID();
		});

		$("th input[type=checkbox]").each(function() {
			var type;
			var data;
			var hasData = false;
			var test ="";
								
			if($(this).closest("tr").find("td").find("input[type=checkbox]").length > 0){
				hasData ="checkbox";							
			}else if($(this).closest("tr").find("td").find("input[type=text]").length > 0){
				hasData ="text";								
			}else if($(this).closest("tr").find("td").find("select").length > 0){
				hasData ="select";
			}
			
			if (hasData=="checkbox") {
				type = typeof ($(this).closest("tr").find("td").find("input[type=text],select").val());								
				data = $(this).closest("tr").find("th").find("input[type=checkbox],select").val();								
			} else if(hasData=="text") {
				type = typeof ($(this).closest("tr").find("td").find("input[type=text],select").val());								
				data = $(this).closest("tr").find("td").find("input[type=text],select").val();								
			} else if(hasData=="select") {
				type = typeof ($(this).closest("tr").find("td").find("select ,select").val());								
				data = $(this).closest("tr").find("td").find("select ,select").val();		
			} else {
				type = "";
				data = "";
			}
			
			obj[$(this).attr("name")] = {};
			obj[$(this).attr("name")]["isUse"] = $(this).is(":checked") ? "Y" : "N"; //$(this).is(":checked");
			obj[$(this).attr("name")]["type"] = type;
			if($(this).attr("name")=="scLegacy"){								
				if(data!="on" && data!=""){
					obj[$(this).attr("name")]["value"] = JSON.parse(data);
				}else{
					obj[$(this).attr("name")]["value"] = "";
				}
			}else{
				if(typeof data == "object"){
					obj[$(this).attr("name")]["value"] = JSON.parse(data);
				}else{
					obj[$(this).attr("name")]["value"] = data;	
				}
			}
			
			//추가요청사항
			if(processtype=="Draft"){
				if($(this).closest("tr").attr("data-processtype")=="Request"){
					obj[$(this).attr("name")]["isUse"] = "N";
					obj[$(this).attr("name")]["value"] = "";
				}
			}else if(processtype=="Request"){
				if($(this).closest("tr").attr("data-processtype")=="Draft"){
					obj[$(this).attr("name")]["isUse"] = "N";
					obj[$(this).attr("name")]["value"] = "";
				}
			}
			
			obj[$(this).attr("name")]["desc"] = (($("#"+ $(this).attr("name") + "DESC") == undefined) ? "" : $("#" + $(this).attr("name") + "DESC").text()).replaceAll("\n", "");
		});
		
		return obj;
	}

	//검색창에서 전달받은 데이터 적용
	function setPDEFID(pPDEFID, pPDEFName) {
		$("input[name=pdef]").val(pPDEFID);
		$("input[name=pdefname]").val(pPDEFName);
		if($("input[name=pdef]").val().toLowerCase().match("draft")){
			setOption("Draft");
		}else if($("input[name=pdef]").val().toLowerCase().match("request")){
			setOption("Request");
		}
	}

	parent._CallBackMethod = setPDEFID;

	// ProcessDefinition 검색 팝업
	function showProcessDefinitionPopup() {
		parent.Common.open("", "processDefinitionSearch",
				"<spring:message code='Cache.lbl_apv_search'/>",
				"/approval/manage/processdefinitionsearch_popup.do?PDEF_ID="+ $("input[name=pdef]").val(), "700px", "660px",
				"iframe", true, null, null, true);
	}
	
	function onclick_scLegacy(objThis) {
	    //연동 선/후 처리 옵션
		//input[name=scCCPerson]
	    if ($("input[name=scLegacy]").is(":checked")) {
	    	var szscLegacyObj = new Object();
	    	
	    	var szscLegacy = "";
	        if ($("input[name=scLegacyDraft]").is(":checked")) {
	            szscLegacy = "1";
	            szscLegacyObj.scLegacyDraft = "Y";
	        } else {
	            szscLegacy = "0";
	            szscLegacyObj.scLegacyDraft = "N";
	        }
	        if ($("input[name=scLegacyComplete]").is(":checked")) {
	            szscLegacy += "1";
	            szscLegacyObj.scLegacyComplete = "Y";
	        } else {
	            szscLegacy += "0";
	            szscLegacyObj.scLegacyComplete = "N";
	        }
	        if ($("input[name=scLegacyDistComplete]").is(":checked")) {
	            szscLegacy += "1";
	            szscLegacyObj.scLegacyDistComplete = "Y";
	        } else {
	            szscLegacy += "0";
	            szscLegacyObj.scLegacyDistComplete = "N";
	        }
	        if ($("input[name=scLegacyReject]").is(":checked")) {
	            szscLegacy += "1";
	            szscLegacyObj.scLegacyReject = "Y";
	        } else {
	            szscLegacy += "0";
	            szscLegacyObj.scLegacyReject = "N";
	        }
	        if ($("input[name=scLegacyChargeDept]").is(":checked")) {
	            szscLegacy += "1";
	            szscLegacyObj.scLegacyChargeDept = "Y";
	        } else {
	            szscLegacy += "0";
	            szscLegacyObj.scLegacyChargeDept = "N";
	        }
	        if ($("input[name=scLegacyOtherSystem]").is(":checked")) {
	            szscLegacy += "1";
	            szscLegacyObj.scLegacyOtherSystem = "Y";
	        } else {
	            szscLegacy += "0";
	            szscLegacyObj.scLegacyOtherSystem = "N";
	        }
	        if ($("input[name=scLegacyInBound]").is(":checked")) {
	            szscLegacy += "1";
	            szscLegacyObj.scLegacyInBound = "Y";
	        } else {
	            szscLegacy += "0";
	            szscLegacyObj.scLegacyInBound = "N";
	        }
	        if ($("input[name=scLegacyOutBound]").is(":checked")) {
	            szscLegacy += "1";
	            szscLegacyObj.scLegacyOutBound = "Y";
	        } else {
	            szscLegacy += "0";
	            szscLegacyObj.scLegacyOutBound = "N";
	        }
	        if ($("input[name=scLegacyWithdraw]").is(":checked")) {
	            szscLegacy += "1";
	            szscLegacyObj.scLegacyWithdraw = "Y";
	        } else {
	            szscLegacy += "0";
	            szscLegacyObj.scLegacyWithdraw = "N";
	        }
	        if ($("input[name=scLegacyDelete]").is(":checked")) {
	            szscLegacy += "1";
	            szscLegacyObj.scLegacyDelete = "Y";
	        } else {
	            szscLegacy += "0";
	            szscLegacyObj.scLegacyDelete = "N";
	        }
	        $("input[name=scLegacy]").val(JSON.stringify(szscLegacyObj));
	        
	    } else {
	        Common.Warning("<spring:message code='Cache.msg_apv_250' />"); //기간연동을 선택한 후 설정을 하십시오.
	        $(objThis).attr("checked",false);
	        $("scLegacy").val("");	        
	    }
	}
	
	function onclick_scFormAddInApvLine(objThis) {
		if (objThis.name == 'scFormAddInApvLine') {
			if (!objThis.checked) {
				$("input[name=scFormAddInApvLine]").val('N');
				$("input[name=scFormAddInApvLineUseOrg]").prop('checked', false);
			}
		} else {
			if (!$("input[name=scFormAddInApvLine]").checked) {
				$("input[name=scFormAddInApvLine]").prop('checked', true);
			}
			$("input[name=scFormAddInApvLine]").val(objThis.checked ? 'Y' : 'N');
		}
	}
	
	// 의견 유형 선택에 따른 UI 표시
	function onclick_rdoscCmtType() {
	    if ($("#rdoscCmt_Board").is(":checked")) {
	        // 게시형
	        $("#scCmtType").val("Board");

	        $("#rdoscCmt_Approver").attr("disabled", false);
	        $("#rdoscCmt_Everyone").attr("disabled", false);

	        // 권한처리 가능시 다음 1줄 주석
	        $("#rdoscCmt_Everyone").prop("checked", true);
	        // 권한처리 가능시 위 1줄 주석

	        onclick_rdoscCmt_WriterType();

	        $("#chkscCmt_Modify").attr("disabled", false);
	        $("#chkscCmt_Delete").attr("disabled", false);

	        $("#chkscCmt_Reply").attr("disabled", false);

	        $("#chkscCmtEdit").attr("disabled", false);
	    }
	    else {
	        // 기본형
	        $("#scCmtType").val("Default");

	        $("#rdoscCmt_Approver").attr("disabled", true).prop("checked", true);
	        $("#rdoscCmt_Everyone").attr("disabled", true)
	        onclick_rdoscCmt_WriterType();

	        $("#chkscCmt_Modify").attr("disabled", true).prop("checked", false);
	        $("#chkscCmt_Delete").attr("disabled", true).prop("checked", false);
	        $("#chkscCmt_Reply").attr("disabled", true).prop("checked", false);

	        $("#chkscCmtEdit").attr("disabled", true).prop("checked", false);
	    }

	    onclick_chkscCmt_Reply();
	}

	// 작성자 유형 선택에 따른 값 저장
	function onclick_rdoscCmt_WriterType() {
	    if ($("#rdoscCmt_Approver").is(":checked")) {
	        $("#scCmt_WriterType").val("Approver");
	    }
	    else {
	        $("#scCmt_WriterType").val("Everyone");
	    }
	}

	// 게시형 의견 선택에 따른 UI 표시
	function onclick_useScComment() {
	    if (!($("input[name=scComment]").is(":checked"))) {
	        $("#chkscCmt_Modify").attr("disabled", true);
	        $("#chkscCmt_Modify").prop("checked",false);
	        
	        $("#chkscCmt_Delete").attr("disabled", true);
	        $("#chkscCmt_Delete").prop("checked",false);
	        
	        $("#chkscCmt_ReplyTo").attr("disabled", true);
	        $("#chkscCmt_ReplyTo").prop("checked",false);
	        
	        $("#chkscCmtAdd").attr("disabled", true);
	        $("#chkscCmtAdd").prop("checked",false);
	        
	        $("#chkscCmtEdit").attr("disabled", true);
	        $("#chkscCmtEdit").prop("checked",false);
	    } else{
	    	$("#chkscCmt_Modify").attr("disabled", false);
	    	$("#chkscCmt_Delete").attr("disabled", false);
	    	$("#chkscCmt_ReplyTo").attr("disabled", false);
	        $("#chkscCmtAdd").attr("disabled", false);
	        $("#chkscCmtEdit").attr("disabled", false);
	    }
	}
	
	function onclick_scComment(objThis) {
	    if ($("input[name=scComment]").is(":checked")) {
	    	var szscCommentObj = new Object();
	    	var szscComment = "";
	    	
	        if ($("#rdoscCmt_Approver").is(":checked")) {
	        	szscComment += "1";
	        	szscCommentObj.rdoscCmt_Approver = "Y";
	        } else {
	        	szscComment += "0";
	            szscCommentObj.rdoscCmt_Approver = "N";
	        }
	        if ($("#rdoscCmt_Everyone").is(":checked")) {
	        	szscComment += "1";
	        	szscCommentObj.rdoscCmt_Everyone = "Y";
	        } else {
	        	szscComment += "0";
	            szscCommentObj.rdoscCmt_Everyone = "N";
	        }
	        if ($("input[name=scCmtModify").is(":checked")) {
	        	szscComment += "1";
	        	szscCommentObj.scCmtModify = "Y";
	        } else {
	        	szscComment += "0";
	            szscCommentObj.scCmtModify = "N";
	        }
	        if ($("input[name=scCmtDelete").is(":checked")) {
	        	szscComment += "1";
	        	szscCommentObj.scCmtDelete = "Y";
	        } else {
	        	szscComment += "0";
	            szscCommentObj.scCmtDelete = "N";
	        }
	        if ($("input[name=scCmtReplyTo").is(":checked")) {
	        	szscComment += "1";
	        	szscCommentObj.scCmtReplyTo = "Y";
	        } else {
	        	szscComment += "0";
	            szscCommentObj.scCmtReplyTo = "N";
	        }
	        if ($("input[name=scCmtReplyAdd").is(":checked")) {
	        	szscComment += "1";
	        	szscCommentObj.scCmtReplyAdd = "Y";
	        } else {
	        	szscComment += "0";
	            szscCommentObj.scCmtReplyAdd = "N";
	        }
	        if ($("input[name=scCmtEdit").is(":checked")) {
	        	szscComment += "1";
	        	szscCommentObj.scCmtEdit = "Y";
	        } else {
	        	szscComment += "0";
	            szscCommentObj.scCmtEdit = "N";
	        }
	        if ($("input[name=scCmtAttach").is(":checked")) {
	        	szscComment += "1";
	        	szscCommentObj.scCmtAttach = "Y";
	        } else {
	        	szscComment += "0";
	            szscCommentObj.scCmtAttach = "N";
	        }
	        if ($("input[name=scCmtShowType").is(":checked")) {
	        	szscComment += "1";
	        	szscCommentObj.scCmtShowType = "Y";
	        } else {
	        	szscComment += "0";
	            szscCommentObj.scCmtShowType = "N";
	        }
	        
	        $("input[name=scComment]").val(JSON.stringify(szscCommentObj));
	    } else{
	    	var szscCommentObj = new Object();
	    	
	            szscCommentObj.rdoscCmt_Approver = "N";
	            szscCommentObj.rdoscCmt_Everyone = "N";
	            szscCommentObj.scCmtModify = "N";
	            szscCommentObj.scCmtDelete = "N";
	            szscCommentObj.scCmtReplyTo = "N";
	            szscCommentObj.scCmtReplyAdd = "N";
	            szscCommentObj.scCmtEdit = "N";
	            szscCommentObj.scCmtAttach = "N";
	            szscCommentObj.scCmtShowType = "N";
	            
	     	   $("input[name=scComment]").val(JSON.stringify(szscCommentObj));
	    }
	}
	
	function onclick_scFormAddInApvLine(objThis) {
		if (objThis.name == 'scFormAddInApvLine') {
			if (!objThis.checked) {
				$("input[name=scFormAddInApvLine]").val('N');
				$("input[name=scFormAddInApvLineUseOrg]").prop('checked', false);
			}
		} else {
			if (!$("input[name=scFormAddInApvLine]").checked) {
				$("input[name=scFormAddInApvLine]").prop('checked', true);
			}
			$("input[name=scFormAddInApvLine]").val(objThis.checked ? 'Y' : 'N');
		}
	}
	
	/**
	* 후처리 연동 세부설정 팝업조회.
	*/
	function openLegacyInterfaceConfigPop() {
		var url = "/approval/manage/goLegacyInterfaceConfigPopup.do?SchemaID=" + SCHEMA_ID + "&DomainID=" + $("#domainID").val();
		var popupTit = "<spring:message code='Cache.lbl_apv_legacyDetail' />";
		var width = window.screen.width - 400;
		var height = window.screen.height - 300;
		//CFN_OpenWindow(url, popupTit, width, height, "");
		parent.Common.open("", "LegacyDetailConfigWin", popupTit, url, width+"px", height+"px", "iframe", true, null, null, true);
	}
</script>
<div id="divSchema">
	<div class="sadmin_pop">
		<div>
			<ul class="tabMenu clearFloat">
				<li class="active"><a onclick="clickTab(this);" class="AXTab active" value="optionTab_basic"><spring:message code='Cache.lbl_apv_setschema_tab01' /></a></li>
				<li><a onclick="clickTab(this);" class="AXTab" value="optionTab_approvalType"><spring:message code='Cache.lbl_apv_setschema_tab02' /></a></li>
				<li <covi:admin hiddenWhenEasyAdmin="true" />><a onclick="clickTab(this);" class="AXTab" value="optionTab_approvalLine"><spring:message code='Cache.lbl_apv_setschema_tab03' /></a> </li>
				<li><a onclick="clickTab(this);" class="AXTab" value="optionTab_approval"><spring:message code='Cache.lbl_apv_setschema_tab04' /></a></li>
				<li <covi:admin hiddenWhenEasyAdmin="true" />><a onclick="clickTab(this);" class="AXTab" value="optionTab_edms"><spring:message code='Cache.lbl_apv_setschema_tab05' /></a></li>
				<li><a onclick="clickTab(this);" class="AXTab" value="optionTab_docNumber"><spring:message code='Cache.lbl_apv_setschema_tab06' /></a></li>
				<li <covi:admin hiddenWhenEasyAdmin="true" />><a onclick="clickTab(this);" class="AXTab" value="optionTab_dept"><spring:message code='Cache.lbl_apv_setschema_tab07' /></a></li>
				<li <covi:admin hiddenWhenEasyAdmin="true" />><a onclick="clickTab(this);" class="AXTab" value="optionTab_link"><spring:message code='Cache.lbl_apv_setschema_tab08' /></a></li>
				<li <covi:admin hiddenWhenEasyAdmin="true" />><a onclick="clickTab(this);" class="AXTab" value="optionTab_etc"><spring:message code='Cache.lbl_apv_setschema_tab09' /></a></li>
			</ul>
			<div id="divSchemaInfo">
				<div id="optionTab_basic" class="tabContent active">
					<p class="sadmin_txt"><spring:message code='Cache.lbl_apv_setschema_tab01_desc' /></p>
					<table class="sadmin_table sa_menuBasicSetting mb20">
						<colgroup>
							<col style="width: 200px">
							<col style="width: 100%">
						</colgroup>
						<tr <covi:admin hiddenWhenEasyAdmin="true" />>
							<th><spring:message code='Cache.lbl_apv_setschema_01' /></th>
							<td>
								<input type="text" name="id" class="w100p" readonly="readonly" />
							</td>
						</tr>
						<tr>
							<th><spring:message code='Cache.lbl_apv_setschema_02' /></th>
							<td>
								<input type="text" name="name" id="scnm" class="w100"/>
							</td>
						</tr>
						<tr>
							<th><spring:message code='Cache.lbl_apv_setschema_03' /></th>
							<td class="center">
								<input type="text" name="desc" class="w100" />
							</td>
						</tr>
						<!-- Schema Domain(Company) Setting. -->
						<tr <covi:admin hiddenWhenEasyAdmin="true" />>
							<th><spring:message code='Cache.lbl_Domain' /></th>
							<td>
								<select name="domainID" class="selBox" id="domainID"></select>
							</td>
						</tr>
					</table>
					<p class="sadmin_txt"><spring:message code='Cache.lbl_apv_setschema_desc01' /></p>
					<table class="sadmin_table sa_menuBasicSetting mb20">
						<colgroup>
							<col style="width: 200px">
							<col style="width: 100%">
						</colgroup>
						<!-- PROCESS Definition ID -->
						<tr>
							<th><spring:message code='Cache.lbl_apv_setschema_04' /></th>
							<td>
								<div class="chkTxt01">
									<spring:message code='Cache.lbl_apv_setschema_desc02' />
								</div>							
								<div class="chkTxt02">
									<input type="text" name="pdef" class="w140p" readonly="readonly" />
									<input type="text" name="pdefname" class="w140p" readonly="readonly" />
									<a class="btnTypeDefault" onclick="showProcessDefinitionPopup(); return false;" ><spring:message code='Cache.lbl_apv_search'/></a>
								</div>
							</td>
						</tr>
						<!--사용자 메뉴바-->
						<tr style="display: none">
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scCMB" name="scCMB" />
							</th>
							<td>
								<input type="text" name="scCMB" class="cInput" />
							</td>
						</tr>
					</table>
				</div>
				<div id="optionTab_approvalType" class="tabContent">
					<p class="sadmin_txt"><spring:message code='Cache.lbl_apv_setschema_tab02_desc' /></p>
					<!-- 감사 -->
					<h3 data-processtype="Draft" class="cycleTitle" <covi:admin hiddenWhenEasyAdmin="true" />>
						<spring:message code='Cache.lbl_apv_setschema_Audit'/>
					</h3>
					<table class="sadmin_table sa_menuBasicSetting mb20" <covi:admin hiddenWhenEasyAdmin="true" />>
						<colgroup>
							<col width="200px" />
							<col width="200px" />
							<col width="*" />
						</colgroup>
						<!--개인감사사용-->
						<tr data-processtype="Draft">
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scPAdt" name="scPAdt"/>
							</th>
							<td>
								<input type="text" name="scPAdt" class="menuName"/><a 
									class="btnTypeDefault" onclick="editList('B9', 'scPAdt'); return false;" ><spring:message code='Cache.lbl_apv_search'/></a>
							</td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scPAdt_desc' /></span>
							</td>
						</tr>
						<!--부서감사사용-->
						<tr data-processtype="Draft">
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scDAdt" name="scDAdt"/>
							<td>
								<input type="text" name="scDAdt" class="menuName" /><a 
									class="btnTypeDefault" onclick="editList('C1', 'scDAdt'); return false;" ><spring:message code='Cache.lbl_apv_search'/></a>
							</td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scDAdt_desc' /></span>
							</td>
						</tr>
						<!--개인준법사용<br />(품의사용)-->
						<tr data-processtype="Draft">
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scPAdt1" name="scPAdt1"/>
							</th>
							<td>
								<input type="text" name="scPAdt1" class="menuName" /><a 
									class="btnTypeDefault" onclick="editList('B1', 'scPAdt1'); return false;" ><spring:message code='Cache.lbl_apv_search'/></a>
							</td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scPAdt1_desc' /></span>
							</td>
						</tr>
						<!--부서준법사용<br />(품의사용)-->
						<tr data-processtype="Draft">
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scDAdt1" name="scDAdt1"/>
							</th>
							<td>
								<input type="text" name="scDAdt1" class="menuName" /><a 
									class="btnTypeDefault" onclick="editList('C1', 'scDAdt1'); return false;" ><spring:message code='Cache.lbl_apv_search'/></a>
							</td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scDAdt1_desc' /></span>
							</td>
						</tr>
					</table>
					<!-- 합의/협조 -->
					<h3 class="cycleTitle">
						<spring:message code='Cache.lbl_apv_setschema_Agree' />
					</h3>
					<table class="sadmin_table sa_menuBasicSetting mb20">
						<colgroup>
							<col style="width: 200px;" />
							<col style="width: 200px;" />
							<col style="width: auto;" />
						</colgroup>
						<tr><!-- 감사부분은 Request 일 때 보여지면 안됨 -->
							<!-- 개인합의(병렬)사용 -->
							<th>
								<covi:checkbox name="scPAgr" msgCode="lbl_apv_setschema_31" />
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_desc07' /></span>
							</td>
						</tr>
						<tr>
							<!-- 개인합의(순차)사용 (default) -->
							<th>
								<covi:checkbox name="scPAgrSEQ" msgCode="lbl_apv_setschema_32" checked="true" />
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_desc08' /></span>
							</td>
						</tr>
						<tr>
							<!-- 부서합의(병렬)사용 -->
							<th>
								<covi:checkbox name="scDAgr" msgCode="lbl_apv_setschema_33" />
							</th>
							<td></td>
							<td>
								<span id="scDAgrDESC"><spring:message code='Cache.lbl_apv_setschema_desc09' /></span>
							</td>
						</tr>
						<tr>
							<!-- 부서합의(순차)사용 -->
							<th>
								<covi:checkbox name="scDAgrSEQ" msgCode="lbl_apv_setschema_109" />
							</th>
							<td></td>
							<td>
								<span id="scDAgrSEQDESC"><spring:message code='Cache.lbl_apv_setschema_desc10' /></span>
							</td>
						</tr>
						<!--(수신부서)부서합의(순차)사용<br />반려권한없음-->
						<tr style="display: none;">
							<th>
								<covi:checkbox name="scDAgrSEQR" msgCode="lbl_apv_setschema_scDAgrSEQR" />
							</th>
							<td></td>
							<td>
								<span id="scDAgrRDESC"><spring:message code='Cache.lbl_apv_setschema_scDAgrSEQR_desc' /></span>
							</td>
						</tr>
						<!--합의자 수 제한-->
						<tr>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scACLimit" name="scACLimit"/>
							</th>
							<td class="left">
								<input type="text" mode="numberint" num_min="1" num_max="30" name="scACLimit" class="cInput" maxlength="2" style="width: 50px;" />
							</td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scACLimit_desc' /></span>
							</td>
						</tr>
						<!--개인협조(병렬)사용<br />반려권한있음-->
						<tr>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scPCooPL" name="scPCooPL"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scPCooPL_desc' /></span>
							</td>
						</tr>
						<!--개인협조(순차)사용<br />반려권한있음-->
						<tr>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scPCoo" name="scPCoo"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scPCoo_desc' /></span>
							</td>
						</tr>
						<!--부서협조사용<br />(품의사용)-->
						<tr>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scDCooPL" name="scDCooPL"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scDCooPL_desc' /></span>
							</td>
						</tr>
						<!--부서협조사용<br />(품의사용)-->
						<tr>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scDCoo" name="scDCoo"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scDCoo_desc' /></span>
							</td>
						</tr>
						<!--합의부서삭제--><!-- Draft -->
						<tr style="display: none;"><!-- data-processtype="Draft"   -->
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scDCooRemove" name="scDCooRemove"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scDCooRemove_desc' /></span>
							</td>
						</tr>
						<!--강제합의--><!-- Draft -->
						<tr style="display: none;"><!-- data-processtype="Draft"   -->
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scForcedConsent" name="scForcedConsent"/>
							</th>
							<td class="center" style="width: 100px">
								<input type="text" name="scForcedConsent" class="cInput" />
							</td>
							<td>
								<span id="scForcedConsentDESC"><spring:message code='Cache.lbl_apv_setschema_scForcedConsent_desc' /></span>
							</td>
						</tr>
						<!--합의단계확인-->
						<!--기능 확인필-->
						<tr  style="display: none;">
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scConsultOK" name="scConsultOK"/>
							</th>
							<td></td>
							<td><span><spring:message
										code='Cache.lbl_apv_setschema_scConsultOK_desc' /></span></td>
						</tr>
						<!--합의부서 내 반려-->
						<!--기능 확인필-->
						<tr  style="display: none;">
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scDCooReturn" name="scDCooReturn"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scDCooReturn_desc' /></span>
							</td>
						</tr>
						<!--다중합의-->
						<!--기능 확인필-->
						<tr  style="display: none;">
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scMltStep" name="scMltStep"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scMltStep' /></span>
							</td>
						</tr>
					</table>
					<!-- 품의프로세스 배포 지정 방식 --><!-- Draft -->
					<h3 data-processtype="Draft" class="cycleTitle">
						<spring:message code='Cache.lbl_apv_setschema_DraftProcess'/>
					</h3>
					<table class="sadmin_table sa_menuBasicSetting mb20" data-processtype="Draft">
						<colgroup>
							<col style="width: 200px;" />
							<col style="width: 200px;" />
							<col style="width: auto;" />
						</colgroup>
						<!--배포사용<br />(품의/협조사용)-->
						<tr data-processtype="Draft">
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scIPub" name="scIPub"/>
							</th>
							<td>
								<input type="text" name="scIPub" class="menuName" /><a 
									class="btnTypeDefault" onclick="editList('D9', 'scIPub'); return false;" ><spring:message code='Cache.lbl_apv_search'/></a>
							</td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scIPub_desc' /></span>
							</td>
						</tr>
						<!--배포그룹사용<br />(품의/협조사용)-->
						<tr data-processtype="Draft" <covi:admin hiddenWhenEasyAdmin="true" />>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scGRec" name="scGRec"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scGRec_desc' /></span>
							</td>
						</tr>
						<!--일괄배포사용<br />(품의/협조사용)-->
						<tr data-processtype="Draft" <covi:admin hiddenWhenEasyAdmin="true" />>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scBatchPub" name="scBatchPub"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scBatchPub_desc' /></span>
							</td>
						</tr>
                        <!--문서유통 사용<br />(문서유통 사용)-->
                        <tr data-processtype="Draft" <covi:admin hiddenWhenEasyAdmin="true" />>
                            <th>
                                <covi:checkbox msgCode="lbl_apv_setschema_scDistribution" name="scDistribution"/>
                                <%-- <input type="checkbox" name="scDistribution" onclick="onclick_scDistribution();"/><spring:message code='Cache.lbl_apv_setschema_scDistribution' /> --%>
                            </th>
                            <td></td>
                            <td>
                                <span><spring:message code='Cache.lbl_apv_setschema_scDistribution_desc' /></span>
                                <%-- <span id="scDistributionDESC"><spring:message code='Cache.lbl_apv_setschema_scDistribution_desc' /></span> --%>
                            </td>
                        </tr>        
						<!--회신옵션(미구현)-->
						<tr style="display: none;"><!-- data-processtype="Draft"  -->
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scReply" name="scReply"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scReply_desc' /></span>
							</td>
						</tr>
					</table>
				<!-- 신청프로세스 수신처 지정 방식 관련 시작 --><!-- Request -->
					<h3 data-processtype="Request" class="cycleTitle">
						<spring:message code='Cache.lbl_apv_setschema_RequestProcess' />
					</h3>
 					<table class="sadmin_table sa_menuBasicSetting mb20" data-processtype="Request">
						<colgroup>
							<col style="width: 200px;" />
							<col style="width: 200px;" />
							<col style="width: auto;" />
						</colgroup>
                        <!--수신자사용<br />(신청사용)-->
                        <tr data-processtype="Request">
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scPRec" name="scPRec"/>
							</th>
							<td class="center">
								<input type="text" name="scPRec" class="menuName" /><a 
									class="btnTypeDefault" onclick="editList('B9', 'scPRec'); return false;" ><spring:message code='Cache.lbl_apv_search'/></a>
							</td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scPRec_desc' /></span>
							</td>
						</tr>
						<!--수신자 계열사별 지정<br />(신청사용)-->
                        <tr data-processtype="Request" <covi:admin hiddenWhenEasyAdmin="true" />>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scPRecEnt" name="scPRecEnt"/>
							</th>
							<td class="center">
								<input type="text" name="scPRecEnt" class="menuName" /><a 
									class="btnTypeDefault" onclick="setChgrType('E', 'PRec'); return false;" ><spring:message code='Cache.lbl_apv_search'/></a>
							</td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scPRec_desc' /> <spring:message code='Cache.lbl_apv_setschema_RecType_desc' /></span>
							</td>
						</tr>
						<!--수신자 사업장별 지정<br />(신청사용)-->
                        <tr data-processtype="Request" <covi:admin hiddenWhenEasyAdmin="true" />>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scPRecReg" name="scPRecReg"/>
							</th>
							<td class="center">
								<input type="text" name="scPRecReg" class="menuName" /><a 
									class="btnTypeDefault" onclick="setChgrType('R', 'PRec'); return false;" ><spring:message code='Cache.lbl_apv_search'/></a>
							</td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scPRec_desc' /> <spring:message code='Cache.lbl_apv_setschema_RecType_desc' /></span>
							</td>
						</tr>
                        <!--수신결재자사용<br />(신청사용)-->
                        <tr data-processtype="Request" <covi:admin hiddenWhenEasyAdmin="true" />>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scPRecA" name="scPRecA"/>
							</th>
							<td>
								<input type="text" name="scPRecA" class="menuName" json-value="true" /><a 
									class="btnTypeDefault" onclick="setscPRecA('scPRecA');" ><spring:message code='Cache.lbl_apv_search'/></a>
							</td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scPRecA_desc' /></span>
							</td>
						</tr>
						<!--수신결재자 계열사별 지정<br />(신청사용)-->
                        <tr data-processtype="Request" <covi:admin hiddenWhenEasyAdmin="true" />>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scPRecAEnt" name="scPRecAEnt"/>
							</th>
							<td>
								<input type="text" name="scPRecAEnt" class="menuName" json-value="true" /><a 
									class="btnTypeDefault" onclick="setChgrType('E', 'PRecA');" ><spring:message code='Cache.lbl_apv_search'/></a>
							</td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scPRecA_desc' /></span>
							</td>
						</tr>
						<!--수신결재자 사업장별 지정<br />(신청사용)-->
                        <tr data-processtype="Request" <covi:admin hiddenWhenEasyAdmin="true" />>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scPRecAReg" name="scPRecAReg"/>
							</th>
							<td>
								<input type="text" name="scPRecAReg" class="menuName" json-value="true" /><a 
									class="btnTypeDefault" onclick="setChgrType('R', 'PRecA');" ><spring:message code='Cache.lbl_apv_search'/></a>
							</td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scPRecA_desc' /></span>
							</td>
						</tr>
                        <!--수신부서사용<br />(신청사용)-->
						<tr data-processtype="Request">
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scDRec" name="scDRec"/>
							</th>
							<td>
								<input type="text" name="scDRec" class="menuName" json-value="true" /><a 
									class="btnTypeDefault" onclick="editList('C9', 'scDRec');" ><spring:message code='Cache.lbl_apv_search'/></a>
							</td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scDRec_desc' /></span>
							</td>
						</tr>
						<!--수신부서사용 계열사별 지정<br />(신청사용)-->
						<tr data-processtype="Request" <covi:admin hiddenWhenEasyAdmin="true" />>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scDRecEnt" name="scDRecEnt"/>
							</th>
							<td>
								<input type="text" name="scDRecEnt" class="menuName" json-value="true" /><a 
									class="btnTypeDefault" onclick="setChgrType('E', 'DRec');" ><spring:message code='Cache.lbl_apv_search'/></a>
							</td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scDRec_desc' /> <spring:message code='Cache.lbl_apv_setschema_RecType_desc' /></span>
							</td>
						</tr>
						<!--수신부서사용 사업장별 지정<br />(신청사용)-->
						<tr data-processtype="Request" <covi:admin hiddenWhenEasyAdmin="true" />>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scDRecReg" name="scDRecReg"/>
							</th>
							<td>
								<input type="text" name="scDRecReg" class="menuName" json-value="true" /><a 
									class="btnTypeDefault" onclick="setChgrType('R', 'DRec');" ><spring:message code='Cache.lbl_apv_search'/></a>
							</td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scDRec_desc' /> <spring:message code='Cache.lbl_apv_setschema_RecType_desc' /></span>
							</td>
						</tr>
                        <!--담당업무사용<br />(신청사용)-->
                        <tr data-processtype="Request">
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scChgr" name="scChgr"/>
							</th>
							<td>
								<input type="text" name="scChgr" class="menuName" /><a 
									class="btnTypeDefault" onclick="JFList('scChgr');" ><spring:message code='Cache.lbl_apv_search'/></a>
							</td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scChgr_desc' /></span>
							</td>
						</tr>
                        <!--담당업무함 계열사별 지정<br />(신청사용)-->
                        <tr data-processtype="Request" <covi:admin hiddenWhenEasyAdmin="true" />>
                        	<th>
                        		<covi:checkbox msgCode="lbl_apv_setschema_scChgrEnt" name="scChgrEnt"/>
                        	</th>
							<td>
								<input type="text" name="scChgrEnt" class="menuName" json-value="true" /><a 
									class="btnTypeDefault" onclick="setChgrType('E', 'Chgr');" ><spring:message code='Cache.lbl_apv_search' /></a>
							</td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scChgr_desc' /></span>
							</td>
						</tr>
                        <!--담당업무함 사업장별 지정<br />(신청사용)-->
                        <tr data-processtype="Request" <covi:admin hiddenWhenEasyAdmin="true" />>
                        	<th>
                        		<covi:checkbox msgCode="lbl_apv_setschema_scChgrReg" name="scChgrReg"/>
                        	</th>
							<td>
								<input type="text" name="scChgrReg" class="menuName" json-value="true" /><a 
									class="btnTypeDefault" onclick="setChgrType('R', 'Chgr');" ><spring:message code='Cache.lbl_apv_search'/></a>
							</td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scChgr_desc' /></span>
							</td>
						</tr>
                        <!--담당부서사용<br />(신청사용)-->
                        <tr data-processtype="Request">
                        	<th>
                        		<covi:checkbox msgCode="lbl_apv_setschema_scChgrOU" name="scChgrOU"/>
                        	</th>
							<td>
								<input type="text" name="scChgrOU" class="menuName" /><a 
									class="btnTypeDefault" onclick="editList('C9', 'scChgrOU');" ><spring:message code='Cache.lbl_apv_search'/></a>
							</td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scChgrOU_desc' /></span>
							</td>
						</tr>
                        <!--담당부서 계열사별 지정<br />(신청사용)-->
                        <tr data-processtype="Request" <covi:admin hiddenWhenEasyAdmin="true" />>
                        	<th>
                        		<covi:checkbox msgCode="lbl_apv_setschema_scChgrOUEnt" name="scChgrOUEnt"/>
                        	</th>
							<td>
								<input type="text" name="scChgrOUEnt" class="menuName" json-value="true" /><a 
									class="btnTypeDefault" onclick="setChgrType('E', 'ChgrOU');" ><spring:message code='Cache.lbl_apv_search'/></a>
							</td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scChgrOU_desc' /></span>
							</td>
						</tr>
                        <!--담당부서 사업장별 지정<br />(신청사용)-->
                        <tr data-processtype="Request" <covi:admin hiddenWhenEasyAdmin="true" />>
                        	<th>
                        		<covi:checkbox msgCode="lbl_apv_setschema_scChgrOUReg" name="scChgrOUReg"/>
                        	</th>
							<td>
								<input type="text" name="scChgrOUReg" class="menuName" json-value="true" /><a 
									class="btnTypeDefault" onclick="setChgrType('R', 'ChgrOU');" ><spring:message code='Cache.lbl_apv_search'/></a>
							</td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scChgrOU_desc' /></span>
							</td>
						</tr>
                        <!--담당수신자사용<br />(신청사용)-->
                        <tr style="display: none;"><!-- data-processtype="Request"   -->
	                     	<th>
	                     		<covi:checkbox msgCode="lbl_apv_setschema_scChgrPerson" name="scChgrPerson"/>
	                     	</th>
							<td>
								<input type="text" name="scChgrPerson" class="menuName" /><a 
									class="btnTypeDefault" onclick="editList('B9', 'scChgrPerson');" ><spring:message code='Cache.lbl_apv_search'/></a>
							</td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scChgrPerson_desc' /></span>
							</td>
						</tr>
                    </tbody>
                </table>
                <!-- 신청프로세스 수신처 지정 방식 관련 종료 -->
				<!-- 동시결재 -->
				<h3 class="cycleTitle" <covi:admin hiddenWhenEasyAdmin="true" />>
					<spring:message code='Cache.lbl_apv_setschema_MultiQueue' />
				</h3>
				<table class="sadmin_table sa_menuBasicSetting mb20" <covi:admin hiddenWhenEasyAdmin="true" />>
					<colgroup>
						<col style="width: 200px;" />
						<col style="width: 200px;" />
						<col style="width: auto;" />
					</colgroup>
					<!--동시결재<br />(발신부서만 지원함)-->
					<tr>
						<th>
							<covi:checkbox msgCode="lbl_apv_setschema_scPApprover" name="scPApprover"/>
						</th>
						<td></td>
						<td>
							<span><spring:message code='Cache.lbl_apv_setschema_scPApprover_desc' /></span>
						</td>
					</tr>
				</table>
				<!-- 참조유형 -->
				<br />
				<h3 class="cycleTitle">
					<spring:message code='Cache.lbl_apv_setschema_Reference' />
				</h3>
				<table class="sadmin_table sa_menuBasicSetting mb20">
					<colgroup>
						<col style="width: 200px;" />
						<col style="width: 200px;" />
						<col style="width: auto;" />
						<!-- 참조유형 관련 시작 -->
					</colgroup>
					<!--수신공람-->
					<!--기능 확인필-->
					<tr <covi:admin hiddenWhenEasyAdmin="true" />>
						<th>
							<covi:checkbox msgCode="lbl_apv_setschema_scDocBoxRE" name="scDocBoxRE"/>
						</th>
						<td></td>
						<td>
							<span><spring:message code='Cache.lbl_apv_setschema_scDocBoxRE_desc' /></span>
						</td>
					</tr>
					<!--개인공람-->
					<tr data-processtype="Draft" <covi:admin hiddenWhenEasyAdmin="true" />>
						<th>
							<covi:checkbox msgCode="lbl_apv_setschema_scReview" name="scReview"/>
						</th>
						<td></td>
						<td>
							<span><spring:message code='Cache.lbl_apv_setschema_scReview_desc' /></span>
						</td>
					</tr>						
					<!--확인결재-->
					<tr <covi:admin hiddenWhenEasyAdmin="true" />>
						<th>
							<covi:checkbox msgCode="lbl_apv_setschema_scPConfirm" name="scPConfirm"/>
						</th>
						<td></td>
						<td>
							<span><spring:message code='Cache.lbl_apv_setschema_scPConfirm_desc' /></span>
						</td>
					</tr>
					<!--참조결재-->
					<tr <covi:admin hiddenWhenEasyAdmin="true" />>
						<th>
							<covi:checkbox msgCode="lbl_apv_setschema_scPShare" name="scPShare" />
						</th>
						<td></td>
						<td>
							<span><spring:message code='Cache.lbl_apv_setschema_scPShare_desc' /></span>
						</td>
					</tr>
					<!--참조사용(기본기능) (default on) -->
					<tr>
						<th>
							<covi:checkbox msgCode="lbl_apv_setschema_scCC" name="scCC" checked="true" onclick="onclick_scCC();"/>
						</th>
						<td class="center">
							<span style="margin-right: 10px;">
								<covi:checkbox msgCode="lbl_apv_Pcc" name="scCCPerson" value="1" checked="true" onclick="onclick_scCC();"/>
							</span>
							<span>
								<covi:checkbox msgCode="lbl_apv_Ucc" name="scCCOu" value="1" checked="true" onclick="onclick_scCC();"/>
							</span>
						</td>
						<td>
							<span><spring:message code='Cache.lbl_apv_setschema_scCC_desc' /></span>
						</td>
					</tr>
					<!--사전참조 사용-->
					<tr>
						<th>
							<covi:checkbox msgCode="lbl_apv_setschema_scBeforCcinfo" name="scBeforCcinfo"/>
						</th>
						<td></td>
						<td>
							<span><spring:message code='Cache.lbl_apv_setschema_scBeforCcinfo_desc' /></span>
						</td>
					</tr>
					<!--수신참조 기본으로 설정--><!-- Request -->
					<tr <covi:admin hiddenWhenEasyAdmin="true" />><!-- data-processtype="Request"  -->
						<th>
							<covi:checkbox msgCode="lbl_apv_setschema_scReceiptRef" name="scReceiptRef"/>
						</th>
						<td></td>
						<td>
							<span><spring:message code='Cache.lbl_apv_setschema_scReceiptRef_desc' /></span>
						</td>
					</tr>
					<!-- 참조유형 관련 종료 -->
				</table>
				</div>

				<div id="optionTab_approvalLine" class="tabContent">
					<spring:message code='Cache.lbl_apv_setschema_tab03_desc' />
					<br /> <br />
					<table class="sadmin_table sa_menuBasicSetting mb20">
						<colgroup>
							<col style="width: 200px;">
							<col style="width: 200px;">
							<col style="width: auto;">
						</colgroup>
						<!-- 결재문서 결재선 출력형태 -->
						<tr>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_91" name="scApvLineType" checked="true"/>
							</th>
							<td>
								<select id="selscApvLineType" name="scApvLineType"></select>
							</td>
							<td>
								<span id="scApvLineTypeDESC"><spring:message code='Cache.lbl_apv_setschema_desc30' /></span>
							</td>
						</tr>
						<!-- 결재선중복체크 -->
						<tr>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_108" name="scChkDuplicateApv"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_desc31' /></span>
							</td>
						</tr>
						<!--결재자 수 제한-->
						<tr>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scCHLimit" name="scCHLimit"/>
							</th>
							<td>
								<input type="text" mode="numberint" num_min="1" num_max="30" name="scCHLimit" class="w50p" maxlength="2" />
							</td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scCHLimit_desc' /></span>
							</td>
						</tr>
						<!--부서장결재단계사용-->
						<!--기능 확인필-->
						<tr>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scStep" name="scStep"/>
							</th>
							<td>
								<input type="text" mode="numberint" num_min="1" num_max="30" name="scStep" class="w50p" maxlength="2" />
							</td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scStep_desc' /></span>
							</td>
						</tr>
					</table>
					<table class="sadmin_table sa_menuBasicSetting mb20">
						<colgroup>
							<col style="width: 100%;">
						</colgroup>
						<tr>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_desc36' /></span>
							</td>
						</tr>
					</table>
				</div>
				<div id="optionTab_approval" class="tabContent">
					<spring:message code='Cache.lbl_apv_setschema_tab04_desc' />
					<br /> <br />
					<table class="sadmin_table sa_menuBasicSetting mb20">
						<colgroup>
							<col style="width: 250px;">
							<col style="width: 0px;">
							<col style="width: auto;">
						</colgroup>
						<!-- 결재자 내용변경 -->
						<tr>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_55" name="scCHBis"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_desc37' /></span>
							</td>
						</tr>
						<!-- 수신부서 내용변경 -->
						<tr>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_56" name="scRCHBis"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_desc38' /></span>
							</td>
						</tr>
						<!-- 승인자 편집 시 저장버튼 활성화 -->
						<tr>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scCHBSaveBtn" name="scCHBSaveBtn"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scCHBSaveBtn_desc' /></span>
							</td>
						</tr>
						<!-- 관리자 내용변경 -->
						<tr <covi:admin hiddenWhenEasyAdmin="true" />>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_140" name="scADMCHBis"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_desc93' /></span>
							</td>
						</tr>
						<!-- 관리자 문서출력 사용여부 -->
						<tr <covi:admin hiddenWhenEasyAdmin="true" />>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scDocPnt" name="scADMDocPnt"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scDocPnt_desc' /></span>
							</td>
						</tr>
						<!-- 지정반려 -->
						<tr <covi:admin hiddenWhenEasyAdmin="true" />>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_57" name="scRJTO"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_desc39' /></span>
							</td>
						</tr>
						<!-- 부서내반송 -->
						<tr <covi:admin hiddenWhenEasyAdmin="true" />>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_118" name="scRJTODept"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_desc80' /></span>
							</td>
						</tr>
						<!--담당자버튼사용-->
						<tr <covi:admin hiddenWhenEasyAdmin="true" />>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scRecBtn" name="scRecBtn"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scRecBtn_desc' /></span>
							</td>
						</tr>
						<!--1인결재-->
						<tr>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scChrDraft" name="scChrDraft"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scChrDraft_desc' /></span>
							</td>
						</tr>
						<!--수신부서 1인결재-->
						<tr>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scChrRedraft" name="scChrRedraft"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scChrRedraft_desc' /></span>
							</td>
						</tr>
						<!--협조자 최종결재 사용-->
						<tr <covi:admin hiddenWhenEasyAdmin="true" />>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scLastAssistDraft" name="scLastAssistDraft"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scLastAssistDraft_desc' /></span>
							</td>
						</tr>
						<!--전달사용-->
						<tr <covi:admin hiddenWhenEasyAdmin="true" />>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scTransfer" name="scTransfer"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scTransfer_desc' /></span>
							</td>
						</tr>
						<!--결재암호사용-->
						<tr>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scWFPwd" name="scWFPwd"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scWFPwd_desc' /></span>
							</td>
						</tr>
						<!--수신처 개별버튼사용-->
						<tr data-processtype="Draft" <covi:admin hiddenWhenEasyAdmin="true" />>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scDeployBtn" name="scDeployBtn"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scDeployBtn_desc' /></span>
							</td>
						</tr>
						<!--접수-->
						<tr <covi:admin hiddenWhenEasyAdmin="true" />>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scRec" name="scRec"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scRec_desc' /></span>
							</td>
						</tr>
						<!--부서합의 접수/반려 버튼 사용-->
						<tr <covi:admin hiddenWhenEasyAdmin="true" />>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scRecAssist" name="scRecAssist"/>	
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scRecAssist_desc' /></span>
							</td>
						</tr>
						<!--결재승인시Validation check-->
						<tr style="display: none;">
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scCheckApproval" name="scCheckApproval"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scCheckApproval_desc' /></span>
							</td>
						</tr>
						<!-- 예약기안/예약배포 사용여부 2020.07.21 -->
						<tr <covi:admin hiddenWhenEasyAdmin="true" />>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scReserveDraft" name="scReserveDraft"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scReserved_desc' /></span>
							</td>
						</tr> 
						<tr <covi:admin hiddenWhenEasyAdmin="true" />>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scReserveDist" name="scReserveDist"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scDistribute_desc' /></span>
							</td>
						</tr> 
						<!-- 결재자 결재선 편집 비활성화 여부 -->
						<tr <covi:admin hiddenWhenEasyAdmin="true" />>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scNCHAis" name="scNCHAis"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scNCHAis_desc' /></span>
							</td>
						</tr>
						<!--검토 사용-->
						<tr <covi:admin hiddenWhenEasyAdmin="true" />>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scConsultation" name="scConsultation"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scConsultation_desc' /></span>
							</td>
						</tr>
					</table>
				</div>
				<div id="optionTab_edms" class="tabContent">
					<spring:message code='Cache.lbl_apv_setschema_tab05_desc' />
					<br /> <br />
					<table class="sadmin_table sa_menuBasicSetting mb20">
						<colgroup>
							<col style="width: 200px;">
							<col style="width: 120px;">
							<col style="width: auto;">
						</colgroup>
						<tr>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_09" name="scEdmsLegacy"/>
							</th>
							<td>
								<input type="text" class="w90p" name="scEdmsLegacy" />
							</td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_10' /></span>
							</td>
						</tr>
						<tr>
							<td colspan=3>
								<spring:message code='Cache.lbl_apv_setschema_desc50' />
							</td>
						</tr>
					</table>
				</div>
				<div id="optionTab_docNumber" class="tabContent">
					<spring:message code='Cache.lbl_apv_setschema_tab06_desc' />
					<br /> <br />
					<table class="sadmin_table sa_menuBasicSetting mb20">
						<colgroup>
							<col style="width: 200px">
							<col style="width: 250px">
							<col style="width: 100%">
						</colgroup>
						<tr>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_11" name="scDNum"/>
							</th>
							<td>
								<select id="selscDNum" name="scDNum" class="selBox"></select>
							</td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_12' /></span>
							</td>
						</tr>
						<tr>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scDNumExt" name="scDNumExt" />
							</th>
							<td>
								<input type="text" class="w100" name="scDNumExt" id="scDNumExtVal" />
							</td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scDNumExt_desc' />
								<!-- 정규식 설정 기준코드;기준기간@포맷형태
								 ex)ent;YYYYMM@entnm-YYYY-seq(4) (회사 년월로 발번  문서번호 형태 : 회사명-2019-0001)
								(회사코드: ent,  회사명:entnm ,  부서코드:dept, 부서코드명: deptnm , 년도4자리:YYYY, 년월6자리:YYYYMM, 년월일8자리:YYYYMMDD, fmpf:양식코드, fmnm : 양식명 .....) -->
								</span>
							</td>
						</tr>						
						<tr>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_15" name="scPreDocNum"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scPreDocNum_desc' /></span>
							</td>
						</tr>			
						<tr <covi:admin hiddenWhenEasyAdmin="true"/>>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_142" name="scDistDocNum"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scDistDocNum_desc' /></span>
							</td>
						</tr>
						<tr <covi:admin hiddenWhenEasyAdmin="true"/>>
							<td colspan=3>
								<spring:message code='Cache.lbl_apv_setschema_desc52' />
							</td>
						</tr>
					</table>
				</div>
				<div id="optionTab_dept" class="tabContent">
					<spring:message code='Cache.lbl_apv_setschema_tab07_desc' />
					<br /> <br />
					<table class="sadmin_table sa_menuBasicSetting mb20">
						<colgroup>
							<col style="width: 200px;">
							<col style="width: 0px;">
							<col style="width: auto;">
						</colgroup>
						<!-- 품의함 저장 -->
						<tr>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_16" name="scABox" checked="true"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_desc53' /></span>
							</td>
						</tr>
						<!-- 발신함 저장 -->
						<tr>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_17" name="scSBox" checked="true"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_desc54' /></span>
							</td>
						</tr>
						<!--개인합의 부서함저장-->
						<tr style="display: none;">
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scASSBox" name="scASSBox"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scASSBox_desc' /></span>
							</td>
						</tr>
						<!--수신처리함저장<br />(신청사용)-->
						<tr>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scRPBox" name="scRPBox" checked="true"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scRPBox_desc' /></span>
							</td>
						</tr>
					</table>
					<table class="sadmin_table sa_menuBasicSetting mb20">
						<colgroup>
							<col style="width: auto;">
						</colgroup>
						<tr style="width: 300px">
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_desc56' /></span>
							</td>
						</tr>
					</table>
					<table class="sadmin_table sa_menuBasicSetting mb20" style="display: none;">
						<colgroup>
							<col style="width: 200px;">
							<col style="width: 170px;">
							<col style="width: auto;">
						</colgroup>
						<!-- 특정권한함 -->
						<tr>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scJFBox" name="scJFBox"/>
							</th>
							<td style="width: 100px">
								<input type="text" name="scJFBox" class="cInput" style="width:100px;"/><a 
									class="btnTypeDefault" onclick="JFList('scJFBox');" ><spring:message code='Cache.lbl_apv_search'/></a>							
							</td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scJFBox_desc' /></span>
							</td>
						</tr>
					</table>
				</div>
				<div id="optionTab_link" class="tabContent">
					<spring:message code='Cache.lbl_apv_setschema_tab08_desc' />
					<br /> <br />
					<table class="sadmin_table sa_menuBasicSetting mb20">
						<colgroup>
							<col style="width: 200px;">
							<col style="width: 180px;">
							<col style="width: auto;">
						</colgroup>
						<tr>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_59" name="scLegacy"/>
							</th>
							<td class="legacyOptions">
								<covi:checkbox msgCode="lbl_apv_setschema_94" name="scLegacyDraft" onclick="onclick_scLegacy(this);" />
								<p style="line-height: 5px;">&nbsp;</p>
								<covi:checkbox msgCode="lbl_apv_setschema_95" name="scLegacyComplete" onclick="onclick_scLegacy(this);"/>
								<p style="line-height: 5px;">&nbsp;</p>
								<covi:checkbox msgCode="lbl_apv_setschema_141" name="scLegacyDistComplete" onclick="onclick_scLegacy(this);"/>
								<p style="line-height: 5px;">&nbsp;</p>
								<covi:checkbox msgCode="lbl_apv_setschema_96" name="scLegacyReject" onclick="onclick_scLegacy(this);"/>
								<p style="line-height: 5px;">&nbsp;</p>
								<covi:checkbox msgCode="lbl_apv_setschema_97" name="scLegacyChargeDept" onclick="onclick_scLegacy(this);"/>
								<p style="line-height: 5px;">&nbsp;</p>
								<covi:checkbox msgCode="lbl_apv_setschema_121" name="scLegacyOtherSystem" onclick="onclick_scLegacy(this);"/>
								<p style="line-height: 5px;">&nbsp;</p>
								<covi:checkbox msgCode="lbl_apv_setschema_132" name="scLegacyWithdraw" onclick="onclick_scLegacy(this);"/>
								<span style="display:none;">
									<p style="line-height: 5px;">&nbsp;</p>
									<covi:checkbox msgCode="lbl_apv_setschema_133" name="scLegacyDelete" onclick="onclick_scLegacy(this);"/>
								</span>
								<br/><br/>
								<a class="btnTypeDefault" onclick="openLegacyInterfaceConfigPop();" ><spring:message code='Cache.btn_apv_LegayDetail'/></a> 
							</td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_desc57' /></span>
							</td>
						</tr>
						<!--레포트생성<br />(완료 후 자동생성)-->
						<tr style="display: none;">
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scMRPT" name="scMRPT"/>
							</th>
							<td>
								<input type="text" name="scMRPT" class="w100" />
							</td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scMRPT_desc' /></span>
							</td>
						</tr>
					</table>
					<table class="sadmin_table sa_menuBasicSetting mb20">
						<colgroup>
							<col style="width: auto;">
						</colgroup>
						<tr>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_desc59' /></span>
							</td>
						</tr>
					</table>
				</div>
				<div id="optionTab_etc" class="tabContent">
					<spring:message code='Cache.lbl_apv_setschema_tab09_desc' />
					<br /> <br />
					<table class="sadmin_table sa_menuBasicSetting mb20">
						<colgroup>
							<col style="width: 200px">
							<col style="width: 160px">
							<col style="width: auto;">
						</colgroup>
						<!-- 기밀문서 -->
						<tr>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_60" name="scSecrecy" />
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_desc60' /></span>
							</td>
						</tr>
						<!-- 진행문서 의견추가	 -->
						<tr>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scPrcCmtAdd" name="scPrcCmtAdd"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_chkscPrcCmtAdd_desc' /></span>
							</td>
						</tr>
						<!-- 완료문서 의견추가	 -->
						<tr>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_104" name="scCmtAdd"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_desc61' /></span>
							</td>
						</tr>
						<!-- 참조자 의견추가	 -->
						<tr>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scCCpersonCmtAdd" name="scCCpersonCmtAdd"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scCCpersonCmtAdd_desc' /></span>
							</td>
						</tr>
						<!-- 게시형 의견 사용 -->
						<tr>
							<th >
								<covi:checkbox msgCode="lbl_apv_setschema_scCommentReply" name="scComment" onclick="onclick_useScComment(); onclick_scComment(this);"/>
							</th>
							<td>
									<!-- <input type= "radio" style="vertical-align: text-bottom; margin-left: 40px;" id="rdoscCmt_Approver" name="rdoscCmt_WriterType" onclick="onclick_rdoscCmt_WriterType(); onclick_scComment(this);"/> --><!-- 결재자만 작성 -->
									<!-- <br/> -->
									<!-- <input type= "radio" style="vertical-align: text-bottom; margin-left: 40px;" id="rdoscCmt_Everyone" name="rdoscCmt_WriterType" onclick="onclick_rdoscCmt_WriterType(); onclick_scComment(this);"/> --><!-- 누구나 작성 -->
									<!-- <br/> -->
								<covi:checkbox msgCode="lbl_apv_chkModify"  name="scCmtModify" onclick="onclick_scComment(this);" id="chkscCmt_Modify"/>
								<p style="line-height: 5px;">&nbsp;</p>
								<covi:checkbox msgCode="lbl_apv_chkDelete" name="scCmtDelete" onclick="onclick_scComment(this);" id="chkscCmt_Delete"/>
								<p style="line-height: 5px;">&nbsp;</p>
								<%-- <covi:checkbox msgCode="lbl_apv_chkCmtReply" name="scCmtReply" id="chkscCmt_Reply" onclick="onclick_chkscCmt_Reply(this); onclick_scComment(this);"/>
								<p style="line-height: 5px;">&nbsp;</p> --%>
								<covi:checkbox msgCode="lbl_apv_chkCmtReplyTo" onclick="onclick_scComment(this);" name="scCmtReplyTo" id="chkscCmt_ReplyTo" />
								<p style="line-height: 5px;">&nbsp;</p>
								<covi:checkbox msgCode="lbl_apv_chkCmtAdd" name="scCmtReplyAdd" onclick="onclick_scComment(this);" id="chkscCmtAdd" />
								<p style="line-height: 5px;">&nbsp;</p>
								<covi:checkbox msgCode="lbl_apv_chkCmtEdit" name="scCmtEdit" onclick="onclick_scComment(this);" id="chkscCmtEdit" />
								<p style="line-height: 5px;">&nbsp;</p>
								<span style="display: none;">
									<covi:checkbox msgCode=""  name="scCmtAttach" onclick="onclick_scComment(this);" id="chkscCmt_Attach"/><!-- 첨부 사용 -->
									<p style="line-height: 5px;">&nbsp;</p>
								</span>
								<covi:checkbox msgCode="lbl_apv_chkCmt_ShowType"  name="scCmtShowType" onclick="onclick_scComment(this);" id="chkscCmt_ShowType"/><!-- 발신/수신 의견 공유 -->
								<p style="line-height: 5px;">&nbsp;</p>
							</td>
							<td>
								<span id="chkscSecrecyDESC"><spring:message code='Cache.lbl_apv_setschema_desc100' /></span>
								<br>
								<span id="chkscSecrecyDESC"><spring:message code='Cache.lbl_apv_setschema_desc102' /></span>
								<br>
								<span id="scModifyDESC"><spring:message code='Cache.lbl_apv_setschema_desc104' /></span>
								<br>
								<span id="chkscDeleteDESC"><spring:message code='Cache.lbl_apv_setschema_desc105' /></span>
								<br>
								<span id="chkscReplyToDESC"><spring:message code='Cache.lbl_apv_setschema_desc107' /></span>
								<br>
								<span id="chkscReplyAddDESC"><spring:message code='Cache.lbl_apv_setschema_desc108' /></span>
								<br>
								<span id="chkscReplyModiDESC"><spring:message code='Cache.lbl_apv_setschema_desc109' /></span>
								<br>
								<span id="chkscReplyShowTypeDESC"><spring:message code='Cache.lbl_apv_setschema_desc110' /></span>
								<br>
							</td>
						</tr>
						<!-- 기안취소 -->
						<tr>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_99" name="scDraftCancel"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_desc62' /></span>
							</td>
						</tr>
						<!-- 승인취소 -->
						<tr>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_100" name="scApproveCancel"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_desc63' /></span>
							</td>
						</tr>
						<!-- 현결재자 후결변경 -->
						<tr style="display: none">
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scChangeReview" name="scChangeReview"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scChangeReview_desc' /></span>
							</td>
						</tr>
						<!--자동후결 사용-->
						<!--기능 확인필-->
						<tr style="display: none">
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scAutoReview" name="scAutoReview"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scAutoReview_desc' /></span>
							</td>
						</tr>
						<!--기록물철 사용-->
						<tr>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scRecDoc" name="scRecordDocOpen"/>
							</th>
							<td></td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scRecDoc_desc' /></span>
							</td>
						</tr>
						<%--                         <!--사용자정의1-->
                        <tr style="display: none;">
                            <td class="t_tit01">
                                <input type="checkbox" class="input_check" name="cField" id="chkscCAt1" /><span class="txt_on"><%= GetDic("lbl_apv_setschema_scCAt1") %></span></td>
                            <td class="t_back01_line">
                                <input type="text" style="float: left; padding-left: 5px; width: 140px;" maxlength="60" name="dField" id="scCAt1" readonly="readonly" />
                                <img id="btn_CAt1" onclick="editList('B1','scCAt1');" style="cursor: pointer; border: 0; text-align: center;" src="" />
                            </td>
                            <td class="t_back03_line"><%= GetDic("lbl_apv_setschema_scCAt1_desc") %>
                            </td>
                        </tr> --%>
						<!--사용자정의2-->
						<tr>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scCAt2" name="scCAt2"/>
							</th>
							<td class="center" style="width: 100px">
								<input type="text" name="scCAt2" class="cInput" />
							</td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scCAt2_desc' /></span>
							</td>
						</tr>
						<!--사용자정의3-->
						<tr>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scCAt3" name="scCAt3"/>
							</th>
							<td class="center" style="width: 100px">
								<input type="text" name="scCAt3" class="cInput" />
							</td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scCAt3_desc' /></span>
							</td>
						</tr>
						<!--사용자정의4-->
						<tr>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scCAt4" name="scCAt4"/>
							</th>
							<td class="center" style="width: 100px">
								<input type="text" name="scCAt4" class="cInput" />
							</td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scCAt4_desc' /></span>
							</td>
						</tr>
						<!--사용자정의5-->
						<tr>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scCAt5" name="scCAt5"/>
							</th>
							<td class="center" style="width: 100px">
								<input type="text" name="scCAt5" class="cInput" />
							</td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scCAt5_desc' /></span>
							</td>
						</tr>
						<!--대외공문변환-->
						<tr>
							<th>
								<covi:checkbox msgCode="lbl_apv_setschema_scOPub" name="scOPub"/>
							</th>
							<td class="center" style="width: 100px">
								<input type="text" name="scOPub" class="cInput" />
							</td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scOPub_desc' /></span>
							</td>
						</tr>
						<!--원문공개(공공)-->
						<tr>
							<th>
								<label>
									<covi:checkbox msgCode="lbl_apv_setschema_scPubOpenDoc" name="scPubOpenDoc"/>
								</label>
							</th>
							<td class="center" style="width: 100px">
							</td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scPubOpenDoc_desc' /></span>
							</td>
						</tr>
						<!--문서내 결재선 사용-->
						<tr>
							<th>
								<label>
									<covi:checkbox msgCode="lbl_apv_setschema_scFormAddInApvLine" name="scFormAddInApvLine" onclick="onclick_scFormAddInApvLine(this);" />
								</label>
							</th>
							<td class="center" style="width: 100px">
								<label>
									<covi:checkbox msgCode="lbl_apv_setschema_scFormAddInApvLineUseOrg" name="scFormAddInApvLineUseOrg" onclick="onclick_scFormAddInApvLine(this);"/>
								</label>
							</td>
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_scFormAddInApvLine_desc' /></span>
							</td>
						</tr>
						</table>
						<table class="sadmin_table sa_menuBasicSetting mb20">
						<colgroup>
							<col style="width: 100%;">
						</colgroup>
						<tr>
							<td><span><spring:message code='Cache.lbl_apv_setschema_desc70' /></span></td>
						</tr>
					</table>			
				</div>
			</div>
		</div>
	</div>
	<div class="popBtn schemaOptionBottom">
		<a id="btnSave" class="btnTypeDefault btnTypeBg" onclick="btnSave_Click();" ><spring:message code="Cache.btn_apv_save"/></a>
		<a id="btnSaveAs" style="display: none" class="btnTypeDefault" onclick="btnSaveAs_Click();" ><spring:message code="Cache.lbl_SaveAs"/></a>
		<a id="btnDelete" style="display: none" class="btnTypeDefault" onclick="btnDelete_Click();" ><spring:message code="Cache.btn_apv_delete"/></a>
		<a id="btnClose" class="btnTypeDefault" onclick="closeLayer();" ><spring:message code="Cache.btn_apv_close"/></a>
	</div>
</div>
