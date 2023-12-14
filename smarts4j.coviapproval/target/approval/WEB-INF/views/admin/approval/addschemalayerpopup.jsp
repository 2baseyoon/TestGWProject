<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/AdminInclude.jsp"></jsp:include>
<style>
	.AXFormTable tr { height: 43px; }
	input[type="checkbox"] { margin-right: 3px; }
	.AXFormTable { margin-top: 10px; }
	.mt10 { margin-top: 10px; }
	.mt20 { margin-top: 20px; }
</style>
<script>
	var mode = CFN_GetQueryString("mode");
	var SCHEMA_ID = CFN_GetQueryString("id");
	var processtype = "";
	$(document).ready(function() {
		
		// init Domain Select
		$("#domainID").coviCtrl("setSelectOption", "/approval/common/getEntInfoListAssignIdData.do");
		
		clickTab($(".on"));
		
		// 공공데모는 타시스템 연동 탭 가리기
		if(location.href.indexOf("gov.covismart.com") > -1)
			$("a[value='optionTab_link']").css("display", "none");
		
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
		$(".AXTab").attr("class", "AXTab");
		$(pObj).addClass("AXTab on");

		$("#divSchemaInfo div").hide();
		$("#" + strObjName).css({"margin-top":"10px", "min-height": "450px", "max-height": "490px"});
		$("#" + strObjName).show();
		coviInput.setDate();
		setSelect();
	}

	// 레이어 팝업 닫기
	function closeLayer() {
		Common.Close();
	}
	
	function setOption(type){
		if(type == "Draft"){
			$("[data-processtype=Draft]").show();
			$("[data-processtype=Request]").hide();	
			processtype = "Draft";
		}
		else{
			$("[data-processtype=Draft]").hide()
			$("[data-processtype=Request]").show();
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
			url : "/approval/admin/getschemainfo.do",
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
				CFN_ErrorAjax("/approval/admin/getschemainfo.do", response, status, error);
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
						/* if(context[d].value.scCmtReply == "Y"){
							$("input[name=scCmtReply]").prop("checked",true);
						} */
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
	    if ($("input[name=scDRec]").is(":checked")) {
	        if ( $("input[name=scChgrOUEnt]").is(":checked")
	            || $("input[name=scChgrOUReg]").is(":checked")
	            || $("input[name=scChgr]").is(":checked")
	            || $("input[name=scChgrEnt]").is(":checked")
	            || $("input[name=scChgrReg]").is(":checked")
	            || $("input[name=scChgrPerson]").is(":checked")
	            || $("input[name=scChgrOU]").is(":checked") 
	            || $("input[name=scChgrOUEnt]").is(":checked")
		        || $("input[name=scChgrOUReg]").is(":checked") ){
	            Common.Warning("<spring:message code='Cache.msg_apv_017' />"); return false;		//수신처를 선택한 경우 담당자사용, 담당부서사용을 선택할 수 없습니다.
	        }
	    }
        if($("input[name=scPRec]").is(":checked")
       		&&($("input[name=scDRec]").is(":checked")
 			|| $("input[name=scChgr]").is(":checked")
 			|| $("input[name=scChgrEnt]").is(":checked")
 			|| $("input[name=scChgrReg]").is(":checked")
 			|| $("input[name=scChgrOU]").is(":checked") 
         	|| $("input[name=scChgrOUEnt]").is(":checked")
      		|| $("input[name=scChgrOUReg]").is(":checked"))	) {
   	    	Common.Warning("<spring:message code='Cache.msg_apv_514' />"); return false;		//수신자를 선택한경우 수신부서와 담당업무, 담당부서 사용은 함께 선택할수 없습니다.
        }
        if($("input[name=scPRecA]").is(":checked")
        	&& !($("input[name=scPRec]").is(":checked")
        	|| $("input[name=scDRec]").is(":checked")) ){
        	Common.Warning("<spring:message code='Cache.msg_apv_515' />"); return false;		//수신결재자 사용시 수신자나 수신부서를 함께 선택해주세요. 
        }
	    if (($("input[name=scChgrOU]").is(":checked")
	        || $("input[name=scChgrOUEnt]").is(":checked")
	        || $("input[name=scChgrOUReg]").is(":checked"))
	        && ($("input[name=scChgr]").is(":checked")
	        || $("input[name=scChgrEnt]").is(":checked")
	        || $("input[name=scChgrReg]").is(":checked"))) {
	        Common.Warning("<spring:message code='Cache.msg_apv_018' />"); return false;		//담당자사용와 담당부서사용은 함께 선택할 수 없습니다
	    }
	    
	    if($("input[name=scComment]").is(":checked")
	       		&&($("input[name=scPrcCmtAdd]").is(":checked")
	 			|| $("input[name=scCmtAdd]").is(":checked")
	 			|| $("input[name=scCCpersonCmtAdd]").is(":checked"))) {
	   	    	Common.Warning("<spring:message code='Cache.msg_useCommentType' />"); return false;		
	    }
	    
	    if ($("input[name=scChgrOU]").is(":checked")
	        || $("input[name=scChgrOUEnt]").is(":checked")
	        || $("input[name=scChgrOUReg]").is(":checked")) {
	        var chkCnt = 0;
	        chkCnt += ($("input[name=scChgrOU]").is(":checked") ? 1 : 0);
	        chkCnt += ($("input[name=scChgrOUEnt]").is(":checked") ? 1 : 0);
	        chkCnt += ($("input[name=scChgrOUReg]").is(":checked") ? 1 : 0);
	        if (chkCnt > 1) {
	        	Common.Warning("<spring:message code='Cache.msg_apv_adminReceiptDept' />"); return false;
	        }
	    }
	    if ($("input[name=scChgr]").is(":checked")
	        || $("input[name=scChgrEnt]").is(":checked")
	        || $("input[name=scChgrReg]").is(":checked")) {
	        var chkCnt = 0;
	        chkCnt += ($("input[name=scChgr]").is(":checked") ? 1 : 0);
	        chkCnt += ($("input[name=scChgrEnt]").is(":checked") ? 1 : 0);
	        chkCnt += ($("input[name=scChgrReg]").is(":checked") ? 1 : 0);
	        if (chkCnt > 1) {
	        	Common.Warning("<spring:message code='Cache.msg_adminReceiptPerson' />"); return false;
	        }
	    }
	    if ($("input[name=scChgr]").is(":checked") && $("input[name=scChgr]").attr("value") == "") {
	        Common.Warning("<spring:message code='Cache.msg_apv_019' />"); return false;		//담당자사용의 결재업무담당자를 선택하십시요
	    }
	    if ($("input[name=scChgrOU]").is(":checked") && $("input[name=scChgrOU]").attr("value") == "") {
	        Common.Warning("<spring:message code='Cache.msg_apv_020' />"); return false;		//담당부서사용의 결재업무담당부서를 선택하십시요
	    }
	    if ($("input[name=scChgrOUEnt]").is(":checked") && $("input[name=scChgrOUEnt]").attr("value") == "") {
	        Common.Warning("<spring:message code='Cache.msg_apv_020' />"); return false;		//담당부서사용의 결재업무담당부서를 선택하십시요
	    }
	    if ($("input[name=scChgrOUReg]").is(":checked") && $("input[scChgrOUReg=scChgrOU]").attr("value") == "") {
	        Common.Warning("<spring:message code='Cache.msg_apv_020' />"); return false;		//담당부서사용의 결재업무담당부서를 선택하십시요
	    }
	    if ($("input[name=scDNum]").is(":checked") && $("#selscDNum option:selected").val() != "99"){
	    	$("input[name=scDNumExt]").prop("checked",false);
	    }
	    
	    if ($("input[name=scDNum]").is(":checked") && $("#selscDNum option:selected").val() == "99"){
			$("input[name=scDNumExt]").prop("checked",true);	
	    	if ($("input[name=scDNumExt]").attr("value") == "" ){
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

		data["mode"] = mode;
		data["SCHEMA_ID"] = (mode == "modify") ? SCHEMA_ID : Common.getUUID();
		data["SCHEMA_NAME"] = $("input[name=name]").val();
		data["SCHEMA_DESC"] = $("input[name=desc]").val();
		data["SCHEMA_CONTEXT"] = JSON.stringify(makeJSON());
		data["DOMAIN_ID"] = $("select#domainID").val();
		
		$.ajax({
			url : "/approval/admin/setschemainfo.do",
			type : "post",
			data : data,
			async : false,
			success : function(res) {
				if (res.data == 1) {
					Common.Inform("<spring:message code='Cache.msg_37' />", "Inform", function() {		//저장되었습니다.
						parent.Refresh();
						Common.Close();
					});
				} else {
					Common.Error(res.message, "Error");
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/admin/setschemainfo.do", response, status, error);
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
			url : "/approval/admin/deleteschemainfo.do",
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
				CFN_ErrorAjax("/approval/admin/deleteschemainfo.do", response, status, error);
			}
		});
	}
	// 함수(수정필요)
	function editList(sCallType, szObject) {
	    if ($("input[name=" + szObject + "]").is(":checked")) {	
	        if ($("input[name=" + szObject + "]").val().length > 0) {
	        	ParamszObject = szObject;
	        	parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>","/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod2&szObject="+szObject+"&type="+sCallType+"&setParamData=_setParamdata","1060px","580px","iframe",true,null,null,true); 	            
	        } else {
	        	parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>","/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod2&szObject="+szObject+"&type="+sCallType+"&setParamData=_setParamdata","1060px","580px","iframe",true,null,null,true); 
	        }
	    } else {
	        switch (szObject) {
	            case "scPAdt": Common.Warning("<spring:message code='Cache.msg_apv_232' />"); break;
	            case "scDAdt": Common.Warning("<spring:message code='Cache.msg_apv_234' />"); break;
	            case "scPAdt1": Common.Warning("<spring:message code='Cache.msg_apv_280' />"); break;
	            case "scDAdt1": Common.Warning("<spring:message code='Cache.msg_apv_281' />"); break;
	            case "scChgrOU": Common.Warning("<spring:message code='Cache.msg_apv_021' />"); break;			//담당부서를 선택하셔야 합니다
	            case "scReviewFix": Common.Warning("<spring:message code='Cache.msg_apv_293' />"); break;		//공람자를 선택하셔야 합니다.
	            case "scCAt1": Common.Warning("<spring:message code='Cache.msg_apv_284' />"); break;				//사용자정의1을 선택하셔야 합니다.
	            case "scIPub": Common.Warning("<spring:message code='Cache.lbl_selectuse_distribution' />"); break;			//사용자정의1을 선택하셔야 합니다.
	            case "scChgrPerson": Common.Warning("<spring:message code='Cache.msg_apv_347' />"); break;
	            case "scPRec": Common.Warning("<spring:message code='Cache.msg_apv_353' />"); break;
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
		
		$("input[name=" + textName + "]").empty();
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
		        $("input[name=" + textName + "]").val(strOURec + ";" + strPersonRec + ";" + "||" + strOURecList + "@" + strPersonRecList + "@");
			}
			else if(textName == "scChgrOU") {
				var scChgrOUValue = $("input[name=" + textName + "][type='text']").val();
			
				$("input[name=" + textName + "][type='text']").val(scChgrOUValue + (scChgrOUValue != "" ? "^" : "") + dataObj.item[i].AN+"@"+dataObj.item[i].DN);
				setszObj[textName] = peopleValue;
			}
			else if(textName == "scDAdt" || textName == "scDAdt1") {
				$("input[name=" + textName + "]").val(dataObj.item[0].AN+"@@"+dataObj.item[0].DN+"@@"+peopleValue);			
				$("input[name=" + textName + "]").attr('value',dataObj.item[0].AN+"@@"+dataObj.item[0].DN+"@@"+peopleValue);
				setszObj[textName] = peopleValue;
			}
			else if(textName == "scPRec" ){
				if(dataObj.item[i].itemType == "user"){
				var PRpeopleValue = '{"item":['+JSON.stringify(dataObj.item[i])+'],"userParams":""}'
				if(i == 0){
				$("input[name=" + textName + "]").val(dataObj.item[i].AN+"@@"+dataObj.item[i].DN+"@@"+PRpeopleValue);
				}else{
				$("input[name=" + textName + "]").val($("input[name=" + textName + "]").val()+"||"+dataObj.item[i].AN+"@@"+dataObj.item[i].DN+"@@"+PRpeopleValue);
				}
				$("input[name=" + textName + "]").attr('value',$("input[name=" + textName + "]").val());
				setszObj[textName] = peopleValue;
				}else if(dataObj.item[i].itemType == "group"){
				//$("input[name=" + textName + "]").attr('value',peopleValue);
				$("input[name=" + textName + "]").val(dataObj.item[0].AN+"@"+dataObj.item[0].DN);
				$("input[name=" + textName + "]").attr('value',dataObj.item[0].AN+"@"+dataObj.item[0].DN);
				setszObj[textName] = peopleValue;
				}
				}
			else{
				if(dataObj.item[i].itemType == "user"){	
					$("input[name=" + textName + "]").val(dataObj.item[0].AN+"@@"+dataObj.item[0].DN+"@@"+peopleValue);			
					$("input[name=" + textName + "]").attr('value',dataObj.item[0].AN+"@@"+dataObj.item[0].DN+"@@"+peopleValue);
					setszObj[textName] = peopleValue;
				}else if(dataObj.item[i].itemType == "group"){
					//$("input[name=" + textName + "]").attr('value',peopleValue);				
					$("input[name=" + textName + "]").val(dataObj.item[0].AN+"@"+dataObj.item[0].DN);
					$("input[name=" + textName + "]").attr('value',dataObj.item[0].AN+"@"+dataObj.item[0].DN);
					setszObj[textName] = peopleValue;
				}	
			}
		});
		/* if(dataObj.item.length > 1){
			$("input[name=" + textName + "]").val(peopleValue);			
			$("input[name=" + textName + "]").attr(peopleValue);
			setszObj[textName] = peopleValue;
		}else{
			if(dataObj.item[0].itemType == "user"){	
				$("input[name=" + textName + "]").val(dataObj.item[0].AN+"@@"+dataObj.item[0].DN);			
				$("input[name=" + textName + "]").attr('value',dataObj.item[0].AN+"@@"+dataObj.item[0].DN);
				setszObj[textName] = peopleValue;
			}else if(dataObj.item[0].itemType == "group"){	
				$("input[name=" + textName + "]").val(dataObj.item[0].AN+"@"+dataObj.item[0].DN);
				$("input[name=" + textName + "]").attr('value',dataObj.item[0].AN+"@"+dataObj.item[0].DN);
				setszObj[textName] = peopleValue;
			}
		} */
	}
	
	// [2015-03-09 add] 수신결재자 멀티선택(수정필요)
	function setscPRecA(sCallType) {
		var isChk = $("input[name=" + sCallType + "]").is(":checked");

		if (!isChk) {
			switch (sCallType) {
				case "scPRecA":
					Common.Warning("<spring:message code='Cache.msg_apv_354' />"); break;
			}
			return;
		}
		else {
			parent.Common.open("", "FormAutoRecApvSet",
					"<spring:message code='Cache.lbl_receiver_apv'/>",		//수신결재자 셋팅
					"/approval/admin/goFormAutoRecApvSet.do?type="+sCallType+"&openID=" + CFN_GetQueryString("CFN_OpenLayerName") + "&OpenFrom=FormAutoRecApvSet", "500px", "400px",
					"iframe", true, null, null, true);
		}
	}
	
	//조직도선택후처리관련
	parent._setNomalValue = setNomalValue;
	function setNomalValue(pObj,pdata){
		$("input[name=" + pObj + "]").val(pdata);
	}
	
	function onclick_scCC() {
 	    //참조 선택
 	    if ($("input[name=scCC]").is(":checked")) {
	        var szscCC = "";
	        if ($("input[name=scCCPerson]").is(":checked")) {
	            szscCC = "Y";
	        } else {
	            szscCC = "N";
	        }
	        if ($("input[name=scCCOu]").is(":checked")) {
	            szscCC += "Y";
	        } else {
	            szscCC += "N";
	        }
	        $("input[name=scCC]").attr('value',szscCC);
	    } else {
			if (!$("input[name=scCCPerson]").is(":checked") && !$("input[name=scCCOu]").is(":checked")) {
			} else {
				$("input[name=scCCPerson],input[name=scCCOu]").prop("checked", false);
				if($(event.target).prop("name") != "scCC"){
				    Common.Warning("<spring:message code='Cache.msg_apv_252' />");  //"참조사용을 선택한 후 설정을 하십시오."
				}
			}
			$("input[name=scCC]").attr('value','NN');
	    }  
	}
	
	function onclick_scDistribution() {
 	    //참조 선택
 	    if ($("input[name=scIPub]").is(":checked") && $("input[name=scDistribution]").is(":checked")) {
 	        	$("input[name=scDistribution]").prop("checked", false);
 	        	Common.Warning("<spring:message code='Cache.msg_scDistributution1' />");  //[배포사용]과[문서유통사용]은 동시에 사용할 수 없습니다.
	    }   
 	    
 	    if ($("input[name=scDistribution]").is(":checked") && !$("input[name=scOPub]").is(":checked")) {//대외수신처 및 대외공문변환 체크여부 확인
	        	$("input[name=scOPub]").prop("checked", true);
	        	Common.Warning("<spring:message code='Cache.msg_scDistributution2' />");  //[배포사용]과[문서유통사용]은 동시에 사용할 수 없습니다.
        }   
 	    
 	    if (!$("input[name=scDistribution]").is(":checked") && $("input[name=scOPub]").is(":checked")) {//대외수신처 및 대외공문변환 체크여부 확인
        	$("input[name=scOPub]").prop("checked", false);
        	Common.Warning("<spring:message code='Cache.msg_scDistributution3' />");  //[배포사용]과[문서유통사용]은 동시에 사용할 수 없습니다.
        }
	}
	
	//담당부서, 담당업무 유형별 팝업
	function setChgrType(sCallType, kind) {
		parent.Common.open("", "FormAutoApvSet",
				"<spring:message code='Cache.lbl_apv_responsibilities_kindset' />",			//담당업무 유형별 세팅
				"/approval/admin/goFormAutoApvSet.do?type="+sCallType+"&kind="+kind+"&openID=div_setwfschema&OpenFrom=FormAutoSet", "500px", "400px",
				"iframe", true, null, null, true);
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
	    		Common.Warning("<spring:message code='Cache.msg_apv_282' />");
	    	}else if(szObject=="scJFBox"){
	    		Common.Warning("<spring:message code='Cache.msg_adminSCJFBox' />");
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

		$("th input[type=checkbox]")	.each(function() {
			var type;
			var data;
			var hasData = false;
			var test ="";
								
			if($(this).parent().parent().find("td input[type=checkbox]").length > 0){
				hasData ="checkbox";							
			}else if($(this).parent().parent().find("td input[type=text]").length > 0){
				hasData ="text";								
			}else if($(this).parent().parent().find("td").find("select").length > 0){
				hasData ="select";
			}
			
			if (hasData=="checkbox") {
				type = typeof ($(this).parent().parent().find("td").find("input[type=text],select").val());								
				data = $(this).parent().parent().find("th").find("input[type=checkbox],select").val();								
			} else if(hasData=="text") {
				type = typeof ($(this).parent().parent().find("td").find("input[type=text],select").val());								
				data = $(this).parent().parent().find("td").find("input[type=text],select").val();								
			} else if(hasData=="select") {
				type = typeof ($(this).parent().parent().find("td").find("select ,select").val());								
				data = $(this).parent().parent().find("td").find("select ,select").val();		
			} else {
				type = "";
				data = "";
			}
			
			obj[$(this).attr("name")] = {};
			obj[$(this).attr("name")]["isUse"] = $(this).is(":checked") ? "Y" : "N"; //$(this).is(":checked");
			obj[$(this).attr("name")]["type"] = type;
			if($(this).attr("name")=="scLegacy"){								
				if(data!="on"){
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
			
			if($(this).attr("name")=="scComment"){								
				if(data!="on"){
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
				if($(this).parent().parent().attr("data-processtype")=="Request"){
					obj[$(this).attr("name")]["isUse"] = "N";
					obj[$(this).attr("name")]["value"] = "";
				}
			}else if(processtype=="Request"){
				if($(this).parent().parent().attr("data-processtype")=="Draft"){
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
				"/approval/admin/processdefinitionsearch_popup.do?PDEF_ID="+ $("input[name=pdef]").val(), "600px", "510px",
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
	
</script>
<form name="form1">
	<div id="divSchema" style="height: 540px">
		<div class="AXTabs" style="width: 100%; margin-bottom: 10px">
			<div class="AXTabsTray" style="height: 30px">
				<a onclick="clickTab(this);" class="AXTab on" value="optionTab_basic"><spring:message code='Cache.lbl_apv_setschema_tab01' /></a>
				<a onclick="clickTab(this);" class="AXTab" value="optionTab_approvalType"><spring:message code='Cache.lbl_apv_setschema_tab02' /></a>
				<a onclick="clickTab(this);" class="AXTab" value="optionTab_approvalLine"><spring:message code='Cache.lbl_apv_setschema_tab03' /></a> 
				<a onclick="clickTab(this);" class="AXTab" value="optionTab_approval"><spring:message code='Cache.lbl_apv_setschema_tab04' /></a>
				<a onclick="clickTab(this);" class="AXTab" value="optionTab_edms"><spring:message code='Cache.lbl_apv_setschema_tab05' /></a> 
				<a onclick="clickTab(this);" class="AXTab" value="optionTab_docNumber"><spring:message code='Cache.lbl_apv_setschema_tab06' /></a> 
				<a onclick="clickTab(this);" class="AXTab" value="optionTab_dept"><spring:message code='Cache.lbl_apv_setschema_tab07' /></a>
				<a onclick="clickTab(this);" class="AXTab" value="optionTab_link"><spring:message code='Cache.lbl_apv_setschema_tab08' /></a>
				<a onclick="clickTab(this);" class="AXTab" value="optionTab_etc"><spring:message code='Cache.lbl_apv_setschema_tab09' /></a>
			</div>
			<div id="divSchemaInfo" class="TabBox">
				<div id="optionTab_basic" style="display: none">
					<spring:message code='Cache.lbl_apv_setschema_tab01_desc' />
					<br /> <br />
					<table class="AXFormTable">
						<colgroup>
							<col style="width: 200px">
							<col style="width: 100%">
						</colgroup>
						<tr>
							<th><spring:message code='Cache.lbl_apv_setschema_01' /></th>
							<td>
								<input type="text" name="id" class="AXInput"readonly="readonly" style="width: 300px" />
							</td>
						</tr>
						<tr>
							<th><spring:message code='Cache.lbl_apv_setschema_02' /></th>
							<td>
								<input type="text" name="name" id="scnm" class="AXInput" style="width: 300px" />
							</td>
						</tr>
						<tr>
							<th><spring:message code='Cache.lbl_apv_setschema_03' /></th>
							<td class="center">
								<input type="text" name="desc" class="AXInput" style="width: 99.5%;" />
							</td>
						</tr>
						<!-- Schema Domain(Company) Setting. -->
						<tr>
							<th><spring:message code='Cache.lbl_Domain' /></th>
							<td>
								<select name="domainID" class="AXSelect" id="domainID"></select>
							</td>
						</tr>
					</table>
					<br />
					<spring:message code='Cache.lbl_apv_setschema_desc01' />
					<br />
					<table class="AXFormTable">
						<colgroup>
							<col style="width: 200px">
							<col style="width: 100%">
						</colgroup>
						<!-- PROCESS Definition ID -->
						<tr>
							<th><spring:message code='Cache.lbl_apv_setschema_04' /></th>
							<td>
								<input type="text" name="pdef" class="AXInput" readonly="readonly" />
								<input type="text" name="pdefname" class="AXInput" readonly="readonly" />
								<input type="button" class="AXButton" value="검색" onclick="showProcessDefinitionPopup(); return false;" />
								<label style="width: 100px"></label>
								<spring:message code='Cache.lbl_apv_setschema_desc02' />
								</td>
						</tr>
						<!--사용자 메뉴바-->
						<tr style="display: none">
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scCMB" /><spring:message code='Cache.lbl_apv_setschema_scCMB' />
							</th>
							<td>
								<input type="text" name="scCMB" class="AXInput" />
							</td>
						</tr>
					</table>
				</div>
				<div id="optionTab_approvalType" style="display: none; overflow: auto;">
					<spring:message code='Cache.lbl_apv_setschema_tab02_desc' />
					<br />
					<!-- 감사 -->
					<h4 data-processtype="Draft" class="mt20">
						<spring:message code='Cache.lbl_apv_setschema_Audit'/>
					</h4>
					<table class="AXFormTable" class="mt10">
						<colgroup>
							<col style="width: 170px;" />
							<col style="width: 170px;" />
							<col style="width: 560px;" />
						</colgroup>
						<!--개인감사사용-->
						<tr data-processtype="Draft">
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scPAdt" /><spring:message code='Cache.lbl_apv_setschema_scPAdt' />
							</th>
							<td class="sp_n2_wrap center" style="width: 180px">
								<input type="text" name="scPAdt" class="AXInput" />
								<input type="button" class="AXButton" value="검색" onclick="editList('B9', 'scPAdt'); return false;" />
							</td>
							<td>
								<span id="scPAdtSEQDESC"><spring:message code='Cache.lbl_apv_setschema_scPAdt_desc' /></span>
							</td>
						</tr>
						<!--부서감사사용-->
						<tr data-processtype="Draft">
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scDAdt" /><spring:message code='Cache.lbl_apv_setschema_scDAdt' />
							<td class="sp_n2_wrap center" style="width: 180px">
								<input type="text" name="scDAdt" class="AXInput" />
								<input type="button" class="AXButton" value="검색" onclick="editList('C1', 'scDAdt'); return false;" />
							</td>
							<td>
								<span id="scPAdtSEQDESC"><spring:message code='Cache.lbl_apv_setschema_scDAdt_desc' /></span>
							</td>
						</tr>
						<!--개인준법사용<br />(품의사용)-->
						<tr data-processtype="Draft">
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scPAdt1" /><spring:message code='Cache.lbl_apv_setschema_scPAdt1' />
							</th>
							<td class="sp_n2_wrap center" style="width: 180px">
								<input type="text" name="scPAdt1" class="AXInput" />
								<input type="button" class="AXButton" value="검색" onclick="editList('B1', 'scPAdt1'); return false;" />
							</td>
							<td>
								<span id="scPAdt1SEQDESC"><spring:message code='Cache.lbl_apv_setschema_scPAdt1_desc' /></span>
							</td>
						</tr>
						<!--부서준법사용<br />(품의사용)-->
						<tr data-processtype="Draft">
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scDAdt1" /><spring:message code='Cache.lbl_apv_setschema_scDAdt1' />
							</th>
							<td class="sp_n2_wrap center" style="width: 180px">
								<input type="text" name="scDAdt1" class="AXInput" />
								<input type="button" class="AXButton" value="검색" onclick="editList('C1', 'scDAdt1'); return false;" />
							</td>
							<td>
								<span id="scDAdt1SEQDESC"><spring:message code='Cache.lbl_apv_setschema_scDAdt1_desc' /></span>
							</td>
						</tr>
					</table>
					<!-- 합의/협조 -->
					<h4 class="mt20">
						<spring:message code='Cache.lbl_apv_setschema_Agree' />
					</h4>
					<table class="AXFormTable">
						<colgroup>
							<col style="width: 170px;" />
							<col style="width: 170px;" />
							<col style="width: 560px;" />
						</colgroup>
						<tr><!-- 감사부분은 Request 일 때 보여지면 안됨 -->
							<!-- 개인합의(병렬)사용 -->
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scPAgr" /><spring:message code='Cache.lbl_apv_setschema_31' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scPAgrDESC"><spring:message code='Cache.lbl_apv_setschema_desc07' /></span>
							</td>
						</tr>
						<tr>
							<!-- 개인합의(순차)사용 -->
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scPAgrSEQ" /><spring:message code='Cache.lbl_apv_setschema_32' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scPAgrSEQDESC"><spring:message code='Cache.lbl_apv_setschema_desc08' /></span>
							</td>
						</tr>
						<tr>
							<!-- 부서합의(병렬)사용 -->
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scDAgr" /><spring:message code='Cache.lbl_apv_setschema_33' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scDAgrDESC"><spring:message code='Cache.lbl_apv_setschema_desc09' /></span>
							</td>
						</tr>
						<tr>
							<!-- 부서합의(순차)사용 -->
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scDAgrSEQ" /><spring:message code='Cache.lbl_apv_setschema_109' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scDAgrSEQDESC"><spring:message code='Cache.lbl_apv_setschema_desc10' /></span>
							</td>
						</tr>
						<!--(수신부서)부서합의(순차)사용<br />반려권한없음-->
						<tr style="display: none;">
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scDAgrSEQR" /><spring:message code='Cache.lbl_apv_setschema_scDAgrSEQR' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scDAgrRDESC"><spring:message code='Cache.lbl_apv_setschema_scDAgrSEQR_desc' /></span>
							</td>
						</tr>
						<!--합의자 수 제한-->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scACLimit" /><spring:message code='Cache.lbl_apv_setschema_scACLimit' />
							</th>
							<td class="center" style="width: 100px">
								<input type="text" mode="numberint" num_min="1" num_max="30" name="scACLimit" class="AXInput" maxlength="2" style="width: 173px;" />
							</td>
							<td>
								<span id="scACLimitSEQRDESC"><spring:message code='Cache.lbl_apv_setschema_scACLimit_desc' /></span>
							</td>
						</tr>
						<!--개인협조(병렬)사용<br />반려권한있음-->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scPCooPL" /><spring:message code='Cache.lbl_apv_setschema_scPCooPL' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scPCooPLDESC"><spring:message code='Cache.lbl_apv_setschema_scPCooPL_desc' /></span>
							</td>
						</tr>
						<!--개인협조(순차)사용<br />반려권한있음-->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scPCoo" /><spring:message code='Cache.lbl_apv_setschema_scPCoo' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scPCooDESC"><spring:message code='Cache.lbl_apv_setschema_scPCoo_desc' /></span>
							</td>
						</tr>
						<!--부서협조사용<br />(품의사용)-->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scDCooPL" /><spring:message code='Cache.lbl_apv_setschema_scDCooPL' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scDCooPLDESC"><spring:message code='Cache.lbl_apv_setschema_scDCooPL_desc' /></span>
							</td>
						</tr>
						<!--부서협조사용<br />(품의사용)-->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scDCoo" /><spring:message code='Cache.lbl_apv_setschema_scDCoo' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scDCooDESC"><spring:message code='Cache.lbl_apv_setschema_scDCoo_desc' /></span>
							</td>
						</tr>
						<!--합의부서삭제--><!-- Draft -->
						<tr style="display: none;"><!-- data-processtype="Draft"   -->
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scDCooRemove" /><spring:message code='Cache.lbl_apv_setschema_scDCooRemove' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scDCooRemoveDESC"><spring:message code='Cache.lbl_apv_setschema_scDCooRemove_desc' /></span>
							</td>
						</tr>
						<!--강제합의--><!-- Draft -->
						<tr style="display: none;"><!-- data-processtype="Draft"   -->
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scForcedConsent" /><spring:message code='Cache.lbl_apv_setschema_scForcedConsent' />
							</th>
							<td class="center" style="width: 100px">
								<input type="text" name="scForcedConsent" class="AXInput" />
							</td>
							<td>
								<span id="scForcedConsentDESC"><spring:message code='Cache.lbl_apv_setschema_scForcedConsent_desc' /></span>
							</td>
						</tr>
						<!--합의단계확인-->
						<!--기능 확인필-->
						<tr  style="display: none;">
							<th class="sp_n1_wrap"><input type="checkbox" name="scConsultOK" />
							<spring:message code='Cache.lbl_apv_setschema_scConsultOK' /></th>
							<td style="width: 100px"></td>
							<td><span id="scConsultOKDESC"><spring:message
										code='Cache.lbl_apv_setschema_scConsultOK_desc' /></span></td>
						</tr>
						<!--합의부서 내 반려-->
						<!--기능 확인필-->
						<tr  style="display: none;">
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scDCooReturn" /><spring:message code='Cache.lbl_apv_setschema_scDCooReturn' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scDCooReturnDESC"><spring:message code='Cache.lbl_apv_setschema_scDCooReturn_desc' /></span>
							</td>
						</tr>
						<!--다중합의-->
						<!--기능 확인필-->
						<tr  style="display: none;">
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scMltStep" /><spring:message code='Cache.lbl_apv_setschema_scMltStep' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scMltStepDESC"><spring:message code='Cache.lbl_apv_setschema_scMltStep' /></span>
							</td>
						</tr>
					</table>
					<!-- 품의프로세스 배포 지정 방식 --><!-- Draft -->
					<h4 data-processtype="Draft" class="mt20">
						<spring:message code='Cache.lbl_apv_setschema_DraftProcess'/>
					</h4>
					<table class="AXFormTable" data-processtype="Draft">
						<colgroup>
							<col style="width: 170px;" />
							<col style="width: 170px;" />
							<col style="width: 560px;" />
						</colgroup>
						<!--배포사용<br />(품의/협조사용)-->
						<tr data-processtype="Draft">
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scIPub" /><spring:message code='Cache.lbl_apv_setschema_scIPub' />
							</th>
							<td  class="sp_n2_wrap center" style="width: 180px">
								<input type="text" name="scIPub" class="AXInput" />
								<input type="button" class="AXButton"value="검색" onclick="editList('D9', 'scIPub'); return false;" />
							</td>
							<td>
								<span id="scIPubDESC"><spring:message code='Cache.lbl_apv_setschema_scIPub_desc' /></span>
							</td>
						</tr>
						<!--배포그룹사용<br />(품의/협조사용)-->
						<tr data-processtype="Draft">
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scGRec" /><spring:message code='Cache.lbl_apv_setschema_scGRec' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scGRecDESC"><spring:message code='Cache.lbl_apv_setschema_scGRec_desc' /></span>
							</td>
						</tr>
						<!--일괄배포사용<br />(품의/협조사용)-->
						<tr data-processtype="Draft">
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scBatchPub" /><spring:message code='Cache.lbl_apv_setschema_scBatchPub' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scBatchPubDESC"><spring:message code='Cache.lbl_apv_setschema_scBatchPub_desc' /></span>
							</td>
						</tr>
						<!--문서유통 사용<br />(문서유통 사용)-->
						<tr data-processtype="Draft">
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scDistribution" onclick="onclick_scDistribution();"/><spring:message code='Cache.lbl_apv_setschema_scDistribution' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scDistributionDESC"><spring:message code='Cache.lbl_apv_setschema_scDistribution_desc' /></span>
							</td>
						</tr>						
						<!--회신옵션(미구현)-->
						<tr style="display: none;"><!-- data-processtype="Draft"  -->
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scReply" /><spring:message code='Cache.lbl_apv_setschema_scReply' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scReplyDESC"><spring:message code='Cache.lbl_apv_setschema_scReply_desc' /></span>
							</td>
						</tr>
					</table>
				<!-- 신청프로세스 수신처 지정 방식 관련 시작 --><!-- Request -->
					<h4 data-processtype="Request" class="mt20">
						<spring:message code='Cache.lbl_apv_setschema_RequestProcess' />
					</h4>
 					<table class="AXFormTable" data-processtype="Request">
						<colgroup>
							<col style="width: 170px;" />
							<col style="width: 170px;" />
							<col style="width: 560px;" />
						</colgroup>
                        <!--수신자사용<br />(신청사용)-->
                        <tr data-processtype="Request">
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scPRec" /><spring:message code='Cache.lbl_apv_setschema_scPRec' />
							</th>
							<td class="sp_n2_wrap center" style="width: 180px">
								<input type="text" name="scPRec" class="AXInput" />
								<input type="button" class="AXButton" value="검색" onclick="editList('B1', 'scPRec'); return false;" />
							</td>
							<td>
								<span id="scPRecDESC"><spring:message code='Cache.lbl_apv_setschema_scPRec_desc' /></span>
							</td>
						</tr>
                        <!--수신결재자사용<br />(신청사용)-->
                        <tr data-processtype="Request">
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scPRecA" /><spring:message code='Cache.lbl_apv_setschema_scPRecA' />
							</th>
							<td class="sp_n2_wrap center" style="width: 180px">
								<input type="text" name="scPRecA" class="AXInput" json-value="true" />
								<input type="button" class="AXButton" value="검색" onclick="setscPRecA('scPRecA');" />
							</td>
							<td>
								<span id="scPRecADESC"><spring:message code='Cache.lbl_apv_setschema_scPRecA_desc' /></span>
							</td>
						</tr>
                        <!--수신부서사용<br />(신청사용)-->
						<tr data-processtype="Request">
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scDRec" /><spring:message code='Cache.lbl_apv_setschema_scDRec' />
							</th>
							<td style="width: 180px"></td>
							<td>
								<span id="scDRecDESC"><spring:message code='Cache.lbl_apv_setschema_scDRec_desc' /></span>
							</td>
						</tr>
                        <!--담당업무사용<br />(신청사용)-->
                        <tr data-processtype="Request">
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scChgr" /><spring:message code='Cache.lbl_apv_setschema_scChgr' />
							</th>
							<td class="sp_n2_wrap center"  style="width: 180px">
								<input type="text" name="scChgr" class="AXInput" />
								<input type="button" class="AXButton" value="검색" onclick="JFList('scChgr');" />
							</td>
							<td>
								<span id="scChgrDESC"><spring:message code='Cache.lbl_apv_setschema_scChgr_desc' /></span>
							</td>
						</tr>
                        <!--담당업무함 계열사별 지정<br />(신청사용)-->
                        <tr data-processtype="Request">
                        	<th class="sp_n1_wrap">
                        		<input type="checkbox" name="scChgrEnt" /><spring:message code='Cache.lbl_apv_setschema_scChgrEnt' />
                        	</th>
							<td class="sp_n2_wrap center" style="width: 180px">
								<input type="text" name="scChgrEnt" class="AXInput" json-value="true" />
								<input type="button" class="AXButton" value="검색" onclick="setChgrType('E', 'Chgr');" />
							</td>
							<td>
								<span id="scChgrEntDESC"><spring:message code='Cache.lbl_apv_setschema_scChgr_desc' /></span>
							</td>
						</tr>
                        <!--담당업무함 사업장별 지정<br />(신청사용)-->
                        <tr data-processtype="Request">
                        	<th class="sp_n1_wrap">
                        		<input type="checkbox" name="scChgrReg" /><spring:message code='Cache.lbl_apv_setschema_scChgrReg' />
                        	</th>
							<td class="sp_n2_wrap center" style="width: 180px">
								<input type="text" name="scChgrReg" class="AXInput" json-value="true" />
								<input type="button" class="AXButton" value="검색" onclick="setChgrType('R', 'Chgr');" />
							</td>
							<td>
								<span id="scChgrRegDESC"><spring:message code='Cache.lbl_apv_setschema_scChgr_desc' /></span>
							</td>
						</tr>
                        <!--담당부서사용<br />(신청사용)-->
                        <tr data-processtype="Request">
                        	<th class="sp_n1_wrap">
                        		<input type="checkbox" name="scChgrOU" /><spring:message code='Cache.lbl_apv_setschema_scChgrOU' />
                        	</th>
							<td class="sp_n2_wrap center" style="width: 180px">
								<input type="text" name="scChgrOU" class="AXInput" />
								<input type="button" class="AXButton" value="검색" onclick="editList('C9', 'scChgrOU');" />
							</td>
							<td>
								<span id="scChgrOUDESC"><spring:message code='Cache.lbl_apv_setschema_scChgrOU_desc' /></span>
							</td>
						</tr>
                        <!--담당부서 계열사별 지정<br />(신청사용)-->
                        <tr data-processtype="Request">
                        	<th class="sp_n1_wrap">
                        		<input type="checkbox" name="scChgrOUEnt" /><spring:message code='Cache.lbl_apv_setschema_scChgrOUEnt' />
                        	</th>
							<td class="sp_n2_wrap center" style="width: 180px">
								<input type="text" name="scChgrOUEnt" class="AXInput" json-value="true" />
								<input type="button" class="AXButton" value="검색" onclick="setChgrType('E', 'ChgrOU');" />
							</td>
							<td>
								<span id="scChgrOUEntDESC"><spring:message code='Cache.lbl_apv_setschema_scChgrOU_desc' /></span>
							</td>
						</tr>
                        <!--담당부서 사업장별 지정<br />(신청사용)-->
                        <tr data-processtype="Request">
                        	<th class="sp_n1_wrap">
                        		<input type="checkbox" name="scChgrOUReg" /><spring:message code='Cache.lbl_apv_setschema_scChgrOUReg' />
                        	</th>
							<td class="sp_n2_wrap center" style="width: 180px">
								<input type="text" name="scChgrOUReg" class="AXInput" json-value="true" />
								<input type="button" class="AXButton" value="검색" onclick="setChgrType('R', 'ChgrOU');" />
							</td>
							<td>
								<span id="scChgrOURegDESC"><spring:message code='Cache.lbl_apv_setschema_scChgrOU_desc' /></span>
							</td>
						</tr>
                        <!--담당수신자사용<br />(신청사용)-->
                        <tr style="display: none;"><!-- data-processtype="Request"   -->
	                     	<th class="sp_n1_wrap">
	                     		<input type="checkbox" name="scChgrPerson" /><spring:message code='Cache.lbl_apv_setschema_scChgrPerson' />
	                     	</th>
							<td class="sp_n2_wrap center" style="width: 180px">
								<input type="text" name="scChgrPerson" class="AXInput" />
								<input type="button" class="AXButton" value="검색" onclick="editList('B9', 'scChgrPerson');" />
							</td>
							<td>
								<span id="scChgrPersonDESC"><spring:message code='Cache.lbl_apv_setschema_scChgrPerson_desc' /></span>
							</td>
						</tr>
                    </tbody>
                </table>
                <!-- 신청프로세스 수신처 지정 방식 관련 종료 -->
				<!-- 동시결재 -->
				<h4 class="mt20">
					<spring:message code='Cache.lbl_apv_setschema_MultiQueue' />
				</h4>
				<table class="AXFormTable">
					<colgroup>
						<col style="width: 170px;" />
						<col style="width: 170px;" />
						<col style="width: 560px;" />
					</colgroup>
					<!--동시결재<br />(발신부서만 지원함)-->
					<tr>
						<th class="sp_n1_wrap">
							<input type="checkbox" name="scPApprover" /><spring:message code='Cache.lbl_apv_setschema_scPApprover' />
						</th>
						<td style="width: 100px"></td>
						<td>
							<span id="scPApproverDESC"><spring:message code='Cache.lbl_apv_setschema_scPApprover_desc' /></span>
						</td>
					</tr>
				</table>
					<!-- 참조유형 -->
					<br />
					<h4>
						<spring:message code='Cache.lbl_apv_setschema_Reference' />
					</h4>
					<table class="AXFormTable">
						<colgroup>
							<col style="width: 170px;" />
							<col style="width: 170px;" />
							<col style="width: 560px;" />
							<!-- 참조유형 관련 시작 -->
						</colgroup>
						<!--수신공람-->
						<!--기능 확인필-->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scDocBoxRE" />
								<spring:message code='Cache.lbl_apv_setschema_scDocBoxRE' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scDocBoxREDESC"><spring:message code='Cache.lbl_apv_setschema_scDocBoxRE_desc' /></span>
							</td>
						</tr>
						<!--개인공람-->
						<tr data-processtype="Draft">
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scReview" />
								<spring:message code='Cache.lbl_apv_setschema_scReview' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scReviewDESC"><spring:message code='Cache.lbl_apv_setschema_scReview_desc' /></span>
							</td>
						</tr>						
						<!--확인결재-->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scPConfirm" /><spring:message code='Cache.lbl_apv_setschema_scPConfirm' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scPConfirmDESC"><spring:message code='Cache.lbl_apv_setschema_scPConfirm_desc' /></span>
							</td>
						</tr>
						<!--참조결재-->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scPShare" /><spring:message code='Cache.lbl_apv_setschema_scPShare' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scPShareDESC"><spring:message code='Cache.lbl_apv_setschema_scPShare_desc' /></span>
							</td>
						</tr>
						<!--참조사용(기본기능)-->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scCC" onclick="onclick_scCC();" /><spring:message code='Cache.lbl_apv_setschema_scCC' />
							</th>
							<td class="center" style="width: 100px">
								<span style="margin-right: 10px;">
									<input type="checkbox" name="scCCPerson" value="1" onclick="onclick_scCC();" />
									<spring:message code='Cache.lbl_apv_Pcc' />
								</span>
								<span>
									<input type="checkbox" name="scCCOu" value="1" onclick="onclick_scCC();" />
									<spring:message code='Cache.lbl_apv_Ucc' />
								</span>
							</td>
							<td>
								<span id="scPShareDESC"><spring:message code='Cache.lbl_apv_setschema_scCC_desc' /></span>
							</td>
						</tr>
						<!--사전참조 사용-->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scBeforCcinfo" /><spring:message code='Cache.lbl_apv_setschema_scBeforCcinfo' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scBeforCcinfoDESC"><spring:message code='Cache.lbl_apv_setschema_scBeforCcinfo_desc' /></span>
							</td>
						</tr>
						<!--수신참조 기본으로 설정--><!-- Request -->
						<tr><!-- data-processtype="Request"  -->
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scReceiptRef" /><spring:message code='Cache.lbl_apv_setschema_scReceiptRef' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scReceiptRefDESC"><spring:message code='Cache.lbl_apv_setschema_scReceiptRef_desc' /></span>
							</td>
						</tr>
						<!-- 참조유형 관련 종료 -->
					</table>
				</div>

				<div id="optionTab_approvalLine" style="display: none">
					<spring:message code='Cache.lbl_apv_setschema_tab03_desc' />
					<br /> <br />
					<table class="AXFormTable">
						<colgroup>
							<col style="width: 200px">
							<col style="width: 160px">
							<col style="width: 100%">
						</colgroup>
						<!-- 결재문서 결재선 출력형태 -->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scApvLineType" checked="checked" /><spring:message code='Cache.lbl_apv_setschema_91' />
							</th>
							<td style="width: 100px">
								<select id="selscApvLineType" name="scApvLineType"></select>
							</td>
							<td>
								<span id="scApvLineTypeDESC"><spring:message code='Cache.lbl_apv_setschema_desc30' /></span>
							</td>
						</tr>
						<!-- 결재선중복체크 -->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scChkDuplicateApv" /><spring:message code='Cache.lbl_apv_setschema_108' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scChkDuplicateApvDESC"><spring:message code='Cache.lbl_apv_setschema_desc31' /></span>
							</td>
						</tr>
						<!--결재자 수 제한-->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scCHLimit" /><spring:message code='Cache.lbl_apv_setschema_scCHLimit' />
							</th>
							<td class="center" style="width: 100px">
								<input type="text" mode="numberint" num_min="1" num_max="30" name="scCHLimit" class="AXInput" maxlength="2" />
							</td>
							<td>
								<span id="scCHLimitDESC"><spring:message code='Cache.lbl_apv_setschema_scCHLimit_desc' /></span>
							</td>
						</tr>
						<!--부서장결재단계사용-->
						<!--기능 확인필-->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scStep" /><spring:message code='Cache.lbl_apv_setschema_scStep' />
							</th>
							<td class="center" style="width: 100px">
								<input type="text" mode="numberint" num_min="1" num_max="30" name="scStep" class="AXInput" maxlength="2" />
							</td>
							<td>
								<span id="scStepDESC"><spring:message code='Cache.lbl_apv_setschema_scStep_desc' /></span>
							</td>
						</tr>
					</table>
					<table class="AXFormTable">
						<colgroup>
							<col style="width: auto">
						</colgroup>
						<tr style="width: 300px">
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_desc36' /></span>
							</td>
						</tr>
					</table>
				</div>
				<div id="optionTab_approval" style="display: none; overflow: auto;">
					<spring:message code='Cache.lbl_apv_setschema_tab04_desc' />
					<br /> <br />
					<table class="AXFormTable">
						<colgroup>
							<col style="width: 200px">
							<col style="width: 100px">
							<col style="width: 100%">
						</colgroup>
						<!-- 결재자 내용변경 -->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scCHBis" /><spring:message code='Cache.lbl_apv_setschema_55' /></th>
							<td style="width: 100px"></td>
							<td>
								<span id="scCHBisDESC"><spring:message code='Cache.lbl_apv_setschema_desc37' /></span>
							</td>
						</tr>
						<!-- 수신부서 내용변경 -->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scRCHBis" /><spring:message code='Cache.lbl_apv_setschema_56' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scRCHBisDESC"><spring:message code='Cache.lbl_apv_setschema_desc38' /></span>
							</td>
						</tr>
						<!-- 승인자 편집 시 저장버튼 활성화 -->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scCHBSaveBtn" /><spring:message code='Cache.lbl_apv_setschema_scCHBSaveBtn' /></th>
							<td style="width: 100px"></td>
							<td>
								<span id="scCHBSaveBtnDESC"><spring:message code='Cache.lbl_apv_setschema_scCHBSaveBtn_desc' /></span>
							</td>
						</tr>
						<!-- 관리자 내용변경 -->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scADMCHBis" /><spring:message code='Cache.lbl_apv_setschema_140' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scADMCHBisDESC"><spring:message code='Cache.lbl_apv_setschema_desc93' /></span>
							</td>
						</tr>
						<!-- 관리자 문서출력 사용여부 -->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scADMDocPnt" /><spring:message code='Cache.lbl_apv_setschema_scDocPnt' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scADMDocPntDESC"><spring:message code='Cache.lbl_apv_setschema_scDocPnt_desc' /></span>
							</td>
						</tr>
						<!-- 지정반려 -->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scRJTO" /><spring:message code='Cache.lbl_apv_setschema_57' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scRJTODESC"><spring:message code='Cache.lbl_apv_setschema_desc39' /></span>
							</td>
						</tr>
						<!-- 부서내반송 -->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scRJTODept" /><spring:message code='Cache.lbl_apv_setschema_118' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scRJTODeptDESC"><spring:message code='Cache.lbl_apv_setschema_desc80' /></span>
							</td>
						</tr>
						<!--담당자버튼사용-->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scRecBtn" /><spring:message code='Cache.lbl_apv_setschema_scRecBtn' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scRecBtnDESC"><spring:message code='Cache.lbl_apv_setschema_scRecBtn_desc' /></span>
							</td>
						</tr>
						<!--1인결재-->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scChrDraft" /><spring:message code='Cache.lbl_apv_setschema_scChrDraft' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scChrDraftDESC"><spring:message code='Cache.lbl_apv_setschema_scChrDraft_desc' /></span>
							</td>
						</tr>
						<!--수신부서 1인결재-->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scChrRedraft" /><spring:message code='Cache.lbl_apv_setschema_scChrRedraft' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scChrRedraftDESC"><spring:message code='Cache.lbl_apv_setschema_scChrRedraft_desc' /></span>
							</td>
						</tr>
						<!--협조자 최종결재 사용-->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scLastAssistDraft" /><spring:message code='Cache.lbl_apv_setschema_scLastAssistDraft' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scLastAssistDraftDESC"><spring:message code='Cache.lbl_apv_setschema_scLastAssistDraft_desc' /></span>
							</td>
						</tr>
						<!--전달사용-->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scTransfer" /><spring:message code='Cache.lbl_apv_setschema_scTransfer' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scTransferDESC"><spring:message code='Cache.lbl_apv_setschema_scTransfer_desc' /></span>
							</td>
						</tr>
						<!--결재암호사용-->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scWFPwd" /><spring:message code='Cache.lbl_apv_setschema_scWFPwd' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scWFPwdDESC"><spring:message code='Cache.lbl_apv_setschema_scWFPwd_desc' /></span>
							</td>
						</tr>
						<!--수신처 개별버튼사용-->
						<tr data-processtype="Draft">
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scDeployBtn" /><spring:message code='Cache.lbl_apv_setschema_scDeployBtn' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scDeployBtnDESC"><spring:message code='Cache.lbl_apv_setschema_scDeployBtn_desc' /></span>
							</td>
						</tr>
						<!--접수-->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scRec" /><spring:message code='Cache.lbl_apv_setschema_scRec' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scRecDESC"><spring:message code='Cache.lbl_apv_setschema_scRec_desc' /></span>
							</td>
						</tr>
						<!--부서합의 접수/반려 버튼 사용-->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scRecAssist" /><spring:message code='Cache.lbl_apv_setschema_scRecAssist' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scRecAssistDESC"><spring:message code='Cache.lbl_apv_setschema_scRecAssist_desc' /></span>
							</td>
						</tr>
						<!--결재승인시Validation check-->
						<tr style="display: none;">
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scCheckApproval" /><spring:message code='Cache.lbl_apv_setschema_scCheckApproval' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scCheckApprovalDESC"><spring:message code='Cache.lbl_apv_setschema_scCheckApproval_desc' /></span>
							</td>
						</tr>
						<!-- 예약기안/예약배포 사용여부 2020.07.21 -->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scReserveDraft" /><spring:message code='Cache.lbl_apv_setschema_scReserveDraft' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scReserveDraftDESC"><spring:message code='Cache.lbl_apv_setschema_scReserved_desc' /></span>
							</td>
						</tr> 
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scReserveDist" /><spring:message code='Cache.lbl_apv_setschema_scReserveDist' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scReserveDistDESC"><spring:message code='Cache.lbl_apv_setschema_scDistribute_desc' /></span>
							</td>
						</tr> 
						<!-- 결재자 결재선 편집 비활성화 여부 -->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scNCHAis" /><spring:message code='Cache.lbl_apv_setschema_scNCHAis' /></th>
							<td style="width: 100px"></td>
							<td>
								<span id="scNCHAisDESC"><spring:message code='Cache.lbl_apv_setschema_scNCHAis_desc' /></span>
							</td>
						</tr>
						<!--검토 사용-->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scConsultation" /><spring:message code='Cache.lbl_apv_setschema_scConsultation' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scConsultationDESC"><spring:message code='Cache.lbl_apv_setschema_scConsultation_desc' /></span>
							</td>
						</tr>
					</table>
				</div>
				<div id="optionTab_edms" style="display: none">
					<spring:message code='Cache.lbl_apv_setschema_tab05_desc' />
					<br /> <br />
					<table class="AXFormTable">
						<colgroup>
							<col style="width: 200px">
							<col style="width: 100px">
							<col style="width: 100%">
						</colgroup>
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scEdmsLegacy" /><spring:message code='Cache.lbl_apv_setschema_09' />
							</th>
							<td style="width: 100px"><input type="text" style="width: 90px" name="scEdmsLegacy" /></td>
							<td>
								<span id="scEdmsLegacyDESC"><spring:message code='Cache.lbl_apv_setschema_10' /></span>
							</td>
						</tr>
						<tr>
							<td colspan=3>
								<spring:message code='Cache.lbl_apv_setschema_desc50' />
							</td>
						</tr>
					</table>
				</div>
				<div id="optionTab_docNumber" style="display: none">
					<spring:message code='Cache.lbl_apv_setschema_tab06_desc' />
					<br /> <br />
					<table class="AXFormTable">
						<colgroup>
							<col style="width: 200px">
							<col style="width: 250px">
							<col style="width: 100%">
						</colgroup>
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scDNum" /><spring:message code='Cache.lbl_apv_setschema_11' />
							</th>
							<td style="width: 250px">
								<select id="selscDNum" name="scDNum"></select>
							</td>
							<td>
								<span id="scDNumDESC"><spring:message code='Cache.lbl_apv_setschema_12' /></span>
							</td>
						</tr>
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scDNumExt" disable="true" /><spring:message code='Cache.lbl_apv_setschema_scDNumExt' />
							</th>
							<td style="width: 250px">
								<input type="text" style="width: 240px" name="scDNumExt" />
							</td>
							<td>
								<span id="scDNumExtDESC"><spring:message code='Cache.lbl_apv_setschema_scDNumExt_desc' />
								<!-- 정규식 설정 기준코드;기준기간@포맷형태
								 ex) ent;YYYYMM@entnm-YYYY-seq(4) (회사 년월로 발번  문서번호 형태 : 회사명-2019-0001)
								( 회사코드 : ent,  회사명 : entnm ,  부서코드 : dept, 부서코드명 : deptnm 
								   년도4자리 : YYYY, 년월6자리 : YYYYMM, 년월일8자리 : YYYYMMDD, 년월4자리 : YYMM
								  fmpf : 양식코드, fmnm : 양식명 ) -->
								</span>
							</td>
						</tr>						
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scPreDocNum" /><spring:message code='Cache.lbl_apv_setschema_15' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scPreDocNumDESC"><spring:message code='Cache.lbl_apv_setschema_scPreDocNum_desc' /></span>
							</td>
						</tr>			
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scDistDocNum" /><spring:message code='Cache.lbl_apv_setschema_142' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scDistDocNumDESC"><spring:message code='Cache.lbl_apv_setschema_scDistDocNum_desc' /></span>
							</td>
						</tr>
						<tr>
							<td colspan=3>
								<spring:message code='Cache.lbl_apv_setschema_desc52' />
							</td>
						</tr>
					</table>
				</div>
				<div id="optionTab_dept" style="display: none">
					<spring:message code='Cache.lbl_apv_setschema_tab07_desc' />
					<br /> <br />
					<table class="AXFormTable">
						<colgroup>
							<col style="width: 200px">
							<col style="width: 170px">
							<col style="width: 100%">
						</colgroup>
						<!-- 품의함 저장 -->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scABox" /><spring:message code='Cache.lbl_apv_setschema_16' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scABoxDESC"><spring:message code='Cache.lbl_apv_setschema_desc53' /></span>
							</td>
						</tr>
						<!-- 발신함 저장 -->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scSBox" /><spring:message code='Cache.lbl_apv_setschema_17' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scSBoxDESC"><spring:message code='Cache.lbl_apv_setschema_desc54' /></span>
							</td>
						</tr>
						<!--개인합의 부서함저장-->
						<tr style="display: none;">
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scASSBox" /><spring:message code='Cache.lbl_apv_setschema_scASSBox' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scASSBoxDESC"><spring:message code='Cache.lbl_apv_setschema_scASSBox_desc' /></span>
							</td>
						</tr>
						<!--수신처리함저장<br />(신청사용)-->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scRPBox" /><spring:message code='Cache.lbl_apv_setschema_scRPBox' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scASSBoxDESC"><spring:message code='Cache.lbl_apv_setschema_scRPBox_desc' /></span>
							</td>
						</tr>
					</table>
					<table class="AXFormTable">
						<colgroup>
							<col style="width: auto">
						</colgroup>
						<tr style="width: 300px">
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_desc56' /></span>
							</td>
						</tr>
					</table>
					<table class="AXFormTable" style="display: none;">
						<colgroup>
							<col style="width: 200px">
							<col style="width: 170px">
							<col style="width: 100%">
						</colgroup>
						<!-- 특정권한함 -->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scJFBox" /><spring:message code='Cache.lbl_apv_setschema_scJFBox' />
							</th>
							<td style="width: 100px">
								<input type="text" name="scJFBox" class="AXInput" style="width:100px;"/>
								<input type="button" class="AXButton" value="검색" onclick="JFList('scJFBox');" />							
							</td>
							<td>
								<span id="scJFBoxDESC"><spring:message code='Cache.lbl_apv_setschema_scJFBox_desc' /></span>
							</td>
						</tr>
					</table>
				</div>
				<div id="optionTab_link" style="display: none">
					<spring:message code='Cache.lbl_apv_setschema_tab08_desc' />
					<br /> <br />
					<table class="AXFormTable">
						<colgroup>
							<col style="width: 200px">
							<col style="width: 150px">
							<col style="width: 100%">
						</colgroup>
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scLegacy"/><spring:message code='Cache.lbl_apv_setschema_59' />
							</th>
							<td style="width: 150px" class="sp_n1_wrap">
								<input type="checkbox" name="scLegacyDraft" onclick="onclick_scLegacy(this);"/><spring:message code='Cache.lbl_apv_setschema_94' />
								<br />
								<input type="checkbox" name="scLegacyComplete" onclick="onclick_scLegacy(this);"/><spring:message code='Cache.lbl_apv_setschema_95' />
								<br />
								<input type="checkbox" name="scLegacyDistComplete" onclick="onclick_scLegacy(this);"/><spring:message code='Cache.lbl_apv_setschema_141' />
								<br />
								<input type="checkbox" name="scLegacyReject" onclick="onclick_scLegacy(this);"/><spring:message code='Cache.lbl_apv_setschema_96' />
								<br />
								<input type="checkbox" name="scLegacyChargeDept" onclick="onclick_scLegacy(this);"/><spring:message code='Cache.lbl_apv_setschema_97' />
								<br />
								<input type="checkbox" name="scLegacyOtherSystem" onclick="onclick_scLegacy(this);"/><spring:message code='Cache.lbl_apv_setschema_121' />
								<br />
								<input type="checkbox" name="scLegacyWithdraw" onclick="onclick_scLegacy(this);"/><spring:message code='Cache.lbl_apv_setschema_132' />
								<br />
								<span style="display:none;">
									<input type="checkbox" name="scLegacyDelete" onclick="onclick_scLegacy(this);"/><spring:message code='Cache.lbl_apv_setschema_133' />
									<br />
								</span>
							</td>
							<td>
								<span id="scLegacyDESC"><spring:message code='Cache.lbl_apv_setschema_desc57' /></span>
							</td>
						</tr>
						<!--레포트생성<br />(완료 후 자동생성)-->
						<tr style="display: none;">
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scMRPT" /><spring:message code='Cache.lbl_apv_setschema_scMRPT' />
							</th>
							<td class="sp_n2_wrap" style="width: 180px">
								<input type="text" name="scMRPT" class="AXInput" />
							</td>
							<td>
								<span id="scPAdtSEQDESC"><spring:message code='Cache.lbl_apv_setschema_scMRPT_desc' /></span>
							</td>
						</tr>
					</table>
					<table class="AXFormTable">
						<colgroup>
							<col style="width: auto">
						</colgroup>
						<tr style="width: 300px">
							<td>
								<span><spring:message code='Cache.lbl_apv_setschema_desc59' /></span>
							</td>
						</tr>
					</table>
				</div>
				<div id="optionTab_etc" style="display:none; overflow:auto;">
					<spring:message code='Cache.lbl_apv_setschema_tab09_desc' />
					<br /> <br />
					<table class="AXFormTable">
						<colgroup>
							<col style="width: 180px">
							<col style="width: 160px">
							<col style="width: 100%">
						</colgroup>
						<!-- 기밀문서 -->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scSecrecy" /><spring:message code='Cache.lbl_apv_setschema_60' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="chkscSecrecyDESC"><spring:message code='Cache.lbl_apv_setschema_desc60' /></span>
							</td>
						</tr>
						<!-- 진행문서 의견추가	 -->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scPrcCmtAdd" /><spring:message code='Cache.lbl_apv_setschema_scPrcCmtAdd' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="chkscPrcCmtAddDESC"><spring:message code='Cache.lbl_apv_setschema_chkscPrcCmtAdd_desc' /></span>
							</td>
						</tr>
						<!-- 완료문서 의견추가	 -->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scCmtAdd" /><spring:message code='Cache.lbl_apv_setschema_104' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="chkscCmtAddDESC"><spring:message code='Cache.lbl_apv_setschema_desc61' /></span>
							</td>
						</tr>
						<!-- 참조자 의견추가	 -->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scCCpersonCmtAdd" /><spring:message code='Cache.lbl_apv_setschema_scCCpersonCmtAdd' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="chkscCCpersonCmtAddDESC"><spring:message code='Cache.lbl_apv_setschema_scCCpersonCmtAdd_desc' /></span>
							</td>
						</tr>
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scComment" onclick="onclick_useScComment(); onclick_scComment(this);"/><spring:message code='Cache.lbl_apv_setschema_scCommentReply' />
							</th>
							<td class="sp_n1_wrap" style="width: 100px">
									<%-- <input type= "radio" style="vertical-align: text-bottom;" name="rdoscCmtType" id="rdoscCmt_Default" onclick="onclick_rdoscCmtType(); onclick_scComment(this);"/><spring:message code='Cache.lbl_apv_rdoscCmtDefault' />
									<span>/</span>
									<input type= "radio" style="vertical-align: text-bottom;" name="rdoscCmtType" id="rdoscCmt_Board" onclick="onclick_rdoscCmtType(); onclick_scComment(this);"/><spring:message code='Cache.lbl_apv_rdoscCmtBoard' />
									<br/> --%>
										<input type= "radio" style="vertical-align: text-bottom; margin-left: 40px; display: none;" id="rdoscCmt_Approver" name="rdoscCmt_WriterType" onclick="onclick_rdoscCmt_WriterType(); onclick_scComment(this);"/><!-- 결재자만 작성 -->
										<!-- <br/> -->
										<input type= "radio" style="vertical-align: text-bottom; margin-left: 40px; display: none;" id="rdoscCmt_Everyone" name="rdoscCmt_WriterType" onclick="onclick_rdoscCmt_WriterType(); onclick_scComment(this);"/><!-- 누구나 작성 -->
										<!-- <br/> -->
										<input type= "checkbox" style="vertical-align: text-bottom; margin-left: 20px;" name="scCmtModify" onclick="onclick_scComment(this);" id="chkscCmt_Modify"/><spring:message code='Cache.lbl_apv_chkModify' />
										<br/>
										<input type= "checkbox" style="vertical-align: text-bottom; margin-left: 20px;" name="scCmtDelete" onclick="onclick_scComment(this);" id="chkscCmt_Delete"/><spring:message code='Cache.lbl_apv_chkDelete' />
										<br/>
										<%-- <input type= "checkbox" style="vertical-align: text-bottom; margin-left: 20px;" name="scCmtReply" id="chkscCmt_Reply" onclick="onclick_chkscCmt_Reply(this); onclick_scComment(this);"/><spring:message code='Cache.lbl_apv_chkCmtReply' />
										<br/> --%>
											<input type= "checkbox" style="vertical-align: text-bottom; margin-left: 20px;" onclick="onclick_scComment(this);" name="scCmtReplyTo" id="chkscCmt_ReplyTo" /><spring:message code='Cache.lbl_apv_chkCmtReplyTo' />
											<br/>
										<input type= "checkbox" style="vertical-align: text-bottom; margin-left: 20px;" name="scCmtReplyAdd" onclick="onclick_scComment(this);" id="chkscCmtAdd" class="input_check" /><spring:message code='Cache.lbl_apv_chkCmtAdd' />
										<br/>
										<input type= "checkbox" style="vertical-align: text-bottom; margin-left: 20px;" name="scCmtEdit" onclick="onclick_scComment(this);" id="chkscCmtEdit" class="input_check" /><spring:message code='Cache.lbl_apv_chkCmtEdit' />
										<br/>
									<input type= "checkbox" style="vertical-align: text-bottom; display: none;" name="scCmtAttach" onclick="onclick_scComment(this);" id="chkscCmt_Attach" class="input_check" /><!-- 첨부 사용 -->
									<!-- <br/> -->
									<input type= "checkbox" style="vertical-align: text-bottom;" name="scCmtShowType" onclick="onclick_scComment(this);" id="chkscCmt_ShowType" class="input_check" /><spring:message code='Cache.lbl_apv_chkCmtEdit' /> <!-- 발신/수신 의견 공유 -->
									<!-- <br/> -->
							</td>
							<td>
								<span id="chkscSecrecyDESC"><spring:message code='Cache.lbl_apv_setschema_desc100' /></span>
								<br>
								<span id="chkscSecrecyDESC"><spring:message code='Cache.lbl_apv_setschema_desc102' /></span>
								<br>
								<span id="chkscModifyDESC"><spring:message code='Cache.lbl_apv_setschema_desc104' /></span>
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
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scDraftCancel" /><spring:message code='Cache.lbl_apv_setschema_99' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="chkscDraftCancelDESC"><spring:message code='Cache.lbl_apv_setschema_desc62' /></span>
							</td>
						</tr>
						<!-- 승인취소 -->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scApproveCancel" /><spring:message code='Cache.lbl_apv_setschema_100' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="chkscApproveCancelDESC"><spring:message code='Cache.lbl_apv_setschema_desc63' /></span>
							</td>
						</tr>
						<!-- 현결재자 후결변경 -->
						<tr style="display: none">
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scChangeReview" /><spring:message code='Cache.lbl_apv_setschema_scChangeReview' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scChangeReviewDESC"><spring:message code='Cache.lbl_apv_setschema_scChangeReview_desc' /></span>
							</td>
						</tr>
						<!--자동후결 사용-->
						<!--기능 확인필-->
						<tr style="display: none">
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scAutoReview" /><spring:message code='Cache.lbl_apv_setschema_scAutoReview' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scChangeReviewDESC"><spring:message code='Cache.lbl_apv_setschema_scAutoReview_desc' /></span>
							</td>
						</tr>
						<!--기록물철 사용-->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scRecordDocOpen"/><spring:message code='Cache.lbl_apv_setschema_scRecDoc' />
							</th>
							<td style="width: 100px"></td>
							<td>
								<span id="scRecDocDESC"><spring:message code='Cache.lbl_apv_setschema_scRecDoc_desc' /></span>
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
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scCAt2" /><spring:message code='Cache.lbl_apv_setschema_scCAt2' />
							</th>
							<td class="center" style="width: 100px">
								<input type="text" name="scCAt2" class="AXInput" />
							</td>
							<td>
								<span id="scCAt2DESC"><spring:message code='Cache.lbl_apv_setschema_scCAt2_desc' /></span>
							</td>
						</tr>
						<!--사용자정의3-->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scCAt3" /><spring:message code='Cache.lbl_apv_setschema_scCAt3' />
							</th>
							<td class="center" style="width: 100px">
								<input type="text" name="scCAt3" class="AXInput" />
							</td>
							<td>
								<span id="scCAt3DESC"><spring:message code='Cache.lbl_apv_setschema_scCAt3_desc' /></span>
							</td>
						</tr>
						<!--사용자정의4-->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scCAt4" /><spring:message code='Cache.lbl_apv_setschema_scCAt4' />
							</th>
							<td class="center" style="width: 100px">
								<input type="text" name="scCAt4" class="AXInput" />
							</td>
							<td>
								<span id="scCAt4DESC"><spring:message code='Cache.lbl_apv_setschema_scCAt4_desc' /></span>
							</td>
						</tr>
						<!--사용자정의5-->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scCAt5" /><spring:message code='Cache.lbl_apv_setschema_scCAt5' />
							</th>
							<td class="center" style="width: 100px">
								<input type="text" name="scCAt5" class="AXInput" />
							</td>
							<td>
								<span id="scCAt5DESC"><spring:message code='Cache.lbl_apv_setschema_scCAt5_desc' /></span>
							</td>
						</tr>
						<!--대외공문변환-->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scOPub" /><spring:message code='Cache.lbl_apv_setschema_scOPub' />
							</th>
							<td class="center" style="width: 100px">
								<input type="text" name="scOPub" class="AXInput" />
							</td>
							<td>
								<span id="scCAt5DESC"><spring:message code='Cache.lbl_apv_setschema_scOPub_desc' /></span>
							</td>
						</tr>
						<!--원문공개(공공)-->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scPubOpenDoc" /><spring:message code='Cache.lbl_apv_setschema_scPubOpenDoc' />
							</th>
							<td class="center" style="width: 100px">
							</td>
							<td>
								<span id="scPubOpenDocDESC"><spring:message code='Cache.lbl_apv_setschema_scPubOpenDoc_desc' /></span>
							</td>
						</tr>
						<!--기록물철 사용-->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scRecordDocOpen" /><spring:message code='Cache.lbl_apv_setschema_scRecDoc' />
							</th>
							<td class="center" style="width: 100px">
							</td>
							<td>
								<span id="scPubOpenDocDESC"><spring:message code='Cache.lbl_apv_setschema_scRecDoc_desc' /></span>
							</td>
						</tr>
						<!--문서내 결재선 사용-->
						<tr>
							<th class="sp_n1_wrap">
								<input type="checkbox" name="scFormAddInApvLine" onclick="onclick_scFormAddInApvLine(this);" /><spring:message code='Cache.lbl_apv_setschema_scFormAddInApvLine' />
							</th>
							<td class="center" style="width: 100px">
								<label><input type="checkbox" name="scFormAddInApvLineUseOrg" onclick="onclick_scFormAddInApvLine(this);" style="vertical-align: text-bottom;"/><spring:message code='Cache.lbl_apv_setschema_scFormAddInApvLineUseOrg' /></label>
							</td>
							<td>
								<span id="scFormAddInApvLineDESC"><spring:message code='Cache.lbl_apv_setschema_scFormAddInApvLine_desc' /></span>
							</td>
						</tr>
						</table>
						<table class="AXFormTable">
						<colgroup>
							<col style="width: 180px">
							<col style="width: 160px">
							<col style="width: 100%">
						</colgroup>
						</table>
						<table class="AXFormTable">
						<colgroup>
							<col style="width: auto">
						</colgroup>
						<tr style="width: 300px">
							<td><span><spring:message code='Cache.lbl_apv_setschema_desc70' /></span></td>
						</tr>
					</table>			
				</div>
			</div>
		</div>
	</div>
	<div class="popBtn">
		<input type="button" id="btnSave" class="AXButton red" value="<spring:message code="Cache.btn_apv_save"/>" onclick="btnSave_Click();" />
		<input type="button" id="btnSaveAs" style="display: none" class="AXButton" value="<spring:message code="Cache.lbl_SaveAs"/>" onclick="btnSaveAs_Click();" />
		<input type="button" id="btnDelete" style="display: none" class="AXButton" value="<spring:message code="Cache.btn_apv_delete"/>" onclick="btnDelete_Click();" />
		<input type="button" id="btnClose" class="AXButton" value="<spring:message code="Cache.btn_apv_close"/>" onclick="closeLayer();" />
	</div>
</form>