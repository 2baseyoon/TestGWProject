<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% String as = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.salt")); %>
<% String aI = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.iv")); %>
<% String ak = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.keysize")); %>
<% int ac = Integer.parseInt(PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.iterationCount"))); %>
<% int app = Integer.parseInt(PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.login.passPhrase"))); %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script type="text/javascript" src="/covicore/resources/script/security/AesUtil.js"></script>
<script type="text/javascript" src="/covicore/resources/script/security/aes.js"></script>
<script type="text/javascript" src="/covicore/resources/script/security/pbkdf2.js"></script>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="resources/script/forms/FormAttach.js<%=resourceVersion%>"></script>
<script>
	var m_oInfoSrc;
	var openID = CFN_GetQueryString("CFN_OpenLayerName");
	var m_oFormMenu;
	var m_oApvList;
	var actionID;
	var sTaskID;
	var bAdd = false;
	var flgUsePWDCheck = false; //결재비밀번호유무
	var useFIDO = "${useFIDO}"; //파이도 사용여부 
	var authFIDO = false; 
	var usePWD = "${usePWD}";
	var _g_authKey,_g_password;
	var proaas = "<%=as%>";
	var proaaI = "<%=aI%>";
	var proaapp = "<%=app%>";
	var aesUtil = new AesUtil("<%=ak%>", "<%=ac%>");
	
	// 팝업 호출 위치 구분
	var param = location.search.substring(1).split('&');
	var reqType = param[0].split('=')[0] == "reqType" ? "person" : "other";
	var bSerial = param[0].split('=')[0] == "bSerial" ? true : false;
	
	$(window).load(function () {
		if (openID != "" && openID != "undefined") {//Layer popup 실행
		    /* if ($("#" + openID + "_if", parent.document).length > 0) {
		        m_oInfoSrc = $("#" + openID + "_if", parent.document)[0].contentWindow;
		    } else { //바닥 popup */
		        m_oInfoSrc = parent;
		    //}
		} else {
			document.getElementById("testpopup_ph").style.display = "";
	        
		    m_oInfoSrc = opener;
		    if(bSerial) {
		    	m_oInfoSrc = opener.document.IframeSerialApprovalFrm;
		    }
		}
		
		m_oFormMenu = m_oInfoSrc;
		m_oApvList = m_oFormMenu.document.getElementById("APVLIST") != undefined ? $.parseJSON(m_oFormMenu.document.getElementById("APVLIST").value) : "";
		actionID = m_oFormMenu.commentPopupButtonID;
		
		//참조자 의견추가
		var strCCpersonAdd = "N";
		if(getInfo("Request.loct") == "COMPLETE" && getInfo("Request.mode") == "COMPLETE" && getInfo("SchemaContext.scCCpersonCmtAdd.isUse") == "Y" && $$($.parseJSON(getInfo("ApprovalLine"))).find("ccinfo>ou>person[code='"+Common.getSession("UR_Code")+"']").length > 0){
			$("#span_comment").text("<spring:message code='Cache.msg_apv_ccComment' />"); // 참조 의견
			strCCpersonAdd = "Y";
		}else if (reqType == "person") {
			$("#span_comment").text("<spring:message code='Cache.lbl_apv_additionalComments' />"); // 추가 의견
		} else {
			$("#span_comment").text(m_oFormMenu.commentPopupTitle + ' ' + "<spring:message code='Cache.lbl_apv_comment' />"); // 의견
		}

		if(m_oInfoSrc.getInfo("FormInfo.FormPrefix") == "WF_FORM_OVERTIME_WORK" || m_oInfoSrc.getInfo("FormInfo.FormPrefix") == "WF_FORM_HOLIDAY_WORK") {
			 if(actionID == "btReject" && m_oFormMenu.document.getElementById("RESULT_COMMENT") != undefined) {
			 	$("#txtComment").val(m_oFormMenu.document.getElementById("RESULT_COMMENT").value);
			 } 
		 }
		
		//지정반려일 경우
		if(actionID == "btRejectedto"){
			//지정반려시 원문서와 결재선이 다를 경우 원 문서의 결재선으로 세팅되도록 변경		
			if(m_oFormMenu.document.getElementById("APVLIST").value != m_oFormMenu.getInfo("ApprovalLine"))
				m_oApvList = $.parseJSON(m_oFormMenu.getInfo("ApprovalLine"));
			doRejectToAction();
		}

		var g_UsePWDCheck = "N"; //결재암호 사용, 스키마 설정값 사용으로 변경 2012-01-02
		try{
			if(m_oInfoSrc.getInfo != undefined){
				g_UsePWDCheck = m_oInfoSrc.getInfo("SchemaContext.scWFPwd.isUse");
				if(m_oInfoSrc.getInfo("Request.subkind") === "T023" || actionID === "btConsultReq" || actionID === "btConsultReqCancel" || actionID === "btReConsultReq") g_UsePWDCheck = "N";
			}
		} catch(e){}
		if(usePWD != "") {
			g_UsePWDCheck = usePWD;
		}
		
		if(useFIDO =="Y"){
			$("#btnFIDO").show();
		}
		
		// 아래 조건에 해당하지 않을 경우만 의견 첨부 표시
		// 기안, 보류, 회수, 취소
		// 반려 시 의견 첨부 N && 반려, 지정반려, 부서내반송, 선반려
		var useRejectCommentAttach = Common.getBaseConfig("useRejectCommentAttach");
		if(!(actionID == "btDraft" || actionID == "btHold" || actionID == "btAbort" || actionID == "btWithdraw" || actionID == "btConsultReq" || actionID == "btConsultReqCancel" || actionID == "btReConsultReq"  
				|| (useRejectCommentAttach == "N" && (actionID == "btReject" || actionID == "btRejectedto" || actionID == "btRejectedtoDept" || actionID == "btRejectLast")))) {
			$("#attachDiv").show();
		}
		
		if (g_UsePWDCheck == "Y" && chkUsePasswordYN()){
			flgUsePWDCheck = true;			
	        $("#tr_passwork").show();
	        document.getElementById("iptPassword").focus();

            //[2014-12-03 modi] E -> e
	        $("#iptPassword").keypress(function (e) { //결재암호에서 enterkey 누름시 확인 click이벤트 실행	        	
	            var code = e.keyCode || e.which;	        	
	            if (code == 13) {
	               // fn_approval_CoviInkComment();
	               //e.stopPropagation();
	               //window.focus();
	               //window.blur();
	               //doOK();
	               document.getElementById("commentOK").click();
	            }
	        });
	    }else{
	    	flgUsePWDCheck = false;
            //document.getElementById("tr_passwork").style.display="none";            
		    //document.getElementById("txtComment").style.height = "80px";
	    	$("#tr_passwork").hide();
	     }
		
		 setCommentSize(); // 의견창 높이조절
		 
		 $("#commentOK").prop('disabled', false).on('click',function(){
				var g_UsePWDCheck = "N";
				try{
					if(m_oInfoSrc.getInfo){
						g_UsePWDCheck = m_oInfoSrc.getInfo("SchemaContext.scWFPwd.isUse");
						if(m_oInfoSrc.getInfo("Request.subkind") === "T023" || actionID === "btConsultReq" || actionID === "btConsultReqCancel" || actionID === "btReConsultReq") g_UsePWDCheck = "N";
					}
				} catch(e){}
				var flgUsePWDCheck = chkUsePasswordYN() && g_UsePWDCheck === "Y"; 
				
				if (reqType != "person") {
					if ( flgUsePWDCheck && !authFIDO ){
						if( !$("#iptPassword").val() ){
							Common.Warning("<spring:message code='Cache.msg_Mail_PleaseEnterPassword'/>","");
							//m_oFormMenu.commentPopupReturnValue = false;
							return false;
						}
						if(!chkCommentWrite($("#iptPassword").val())){
							Common.Warning("<spring:message code='Cache.msg_PasswordChange_02'/>","");
							//m_oFormMenu.commentPopupReturnValue = false;
							return false;
						}
					}
				}
				
				if( m_oFormMenu ){
					_g_password  = aesUtil.encrypt(proaas, proaaI, proaapp, $("#iptPassword").prop("disabled") ? "" : $("#iptPassword").val());
					m_oFormMenu._g_authKey 	 = _g_authKey;
					m_oFormMenu._g_password  = _g_password;
				}
				
				if (reqType === "person" || actionID === "btRejectedtoDept") { 		// 추가 의견 등록
					var formData = new FormData();
					for (var i = 0; i < l_aObjFileList.length; i++) {
						typeof l_aObjFileList[i] === 'object' && formData.append("fileData_comment[]", l_aObjFileList[i]);
		            }
				
					if(l_aObjFileList.length > 0 && $("textarea#txtComment").val() == "") { // 첨부 추가시에는 의견이 무조건 있어야 함.
						$("textarea#txtComment").val("<spring:message code='Cache.msg_apv_189' />");
					}			
					if($.trim( $("textarea#txtComment").val() ).length === 0 ){ // 의견필수체크(의견추가 , 부서내반송)
						Common.Inform("<spring:message code='Cache.msg_apv_064' />");
						return false;
					}
					var params = {
						"formInstId" 	: m_oFormMenu.getInfo("FormInstanceInfo.FormInstID"),
						"processId" 	: m_oFormMenu.getInfo("ProcessInfo.ProcessID"),
						"mode" 			: "Y",
						"kind" 			: "lastapprove",
						"comment" 		: $("#txtComment").val(),
						"g_authKey" 	:  _g_authKey ,
						"g_password" 	:  _g_password ,
						"taskId" 		:  m_oFormMenu.getInfo("ProcessInfo.TaskID")
					};

					params.formInstId = params.formInstId || m_oFormMenu.getInfo("FormInstID");
					params.processId = params.processId || m_oFormMenu.getInfo("ProcessID");
					params.taskId = params.taskId || m_oFormMenu.getInfo("taskID");
					
					actionID === "btRejectedtoDept" && ( params.kind = "rejectedtodept" ); 			
					
					if (actionID === "btRejectedtoDept" && m_oFormMenu.getInfo("ProcessInfo.SubKind") == "T006" && m_oFormMenu.getInfo("Request.loct") == "PROCESS" && m_oFormMenu.getInfo("Request.mode") == "RECAPPROVAL") {
						var elmList = $$(m_oApvList).find("steps>division[divisiontype='receive']").has("taskinfo[status='pending']").find(">step>ou>person").has("taskinfo[kind='charge']");

						if (elmList.length > 0) {
							if ($$(elmList).attr("code") == m_oFormMenu.getInfo("AppInfo.usid")) {
								params.kind = "redraftwithdraw";
							}
						}
					}
					
					var type = "";
					var receivers = [];
					var oReceivers = null;
					if(params.kind == "lastapprove") {
						if($$(m_oApvList).find("steps>division[divisiontype='receive'][processID='" + params.processId + "']").concat().length > 0) {
							var receiptList = m_oFormMenu.document.getElementById("ReceiptList").value;
							
							if(receiptList.split("@").length > 2 && (receiptList.split("@")[0].trim() != "" || receiptList.split("@")[1].trim() != "")) {
								oReceivers = $$(m_oApvList).find("division[divisiontype='receive']>step>ou[taskid!='" + params.taskId + "']>person").has("taskinfo[status='completed']");
							} else {
								oReceivers = $$(m_oApvList).find("division>step>ou[taskid!='" + params.taskId + "']>person").has("taskinfo[status='completed']");
							}
						} else {
							type = "ALL";
						}
					} else {
						oReceivers = $$(m_oApvList).find("steps>division[divisiontype='receive']").has("taskinfo[status='pending']").find(">step>ou[taskid!='" + params.taskId + "']>person").has("taskinfo[status='completed'],taskinfo[status='pending']");
					}
					
					if(oReceivers != null) {
						oReceivers.concat().each(function(i, elm){
							var receiver = {
									"UserId" : elm.attr("code"), 
									"Subject" : m_oFormMenu.getInfo("FormInstanceInfo.Subject"), 
									"Initiator" : m_oFormMenu.getInfo("FormInstanceInfo.InitiatorID"), 
									"ProcessId" : elm.closest("division").attr("processID"), 
									"WorkitemId" : elm.parent().attr("wiid"), 
									"FormInstId" : m_oFormMenu.getInfo("FormInstanceInfo.FormInstID"), 
									"FormName" : m_oFormMenu.getInfo("FormInfo.FormName")
								}
							receivers.push(receiver);
						});
					}
					
					params.type = type;
					params.receivers = receivers;
					
					if(strCCpersonAdd == "Y"){ params.kind = "lastCCcmtAdd"; }
					formData.append("formObj", Base64.utf8_to_b64(JSON.stringify(params)));

					var setComment = function(){
						$.ajax({
							type : "POST",
							data : formData,
							url : "form/setComment.do",
		            		async : false,
							dataType : 'json',
		            		processData : false,
		            		contentType : false,
							success:function (data) {
								if(data.status === 'SUCCESS'){
									if(actionID == "btRejectedtoDept") {
										m_oFormMenu.document.getElementById("ACTIONCOMMENT").value = Base64.utf8_to_b64($("textarea#txtComment").val());
										l_aObjFileList.length > 0 && (m_oFormMenu.document.getElementById("ACTIONCOMMENT_ATTACH").value = JSON.stringify(data.attachFileResult))
										//m_oFormMenu.commentPopupReturnValue = true;
										typeof m_oFormMenu.commonWritePopupOnload === "function" && m_oFormMenu.commonWritePopupOnload.call({ g_authKey : _g_authKey, g_password : _g_password })
										window.close();	
									} else {
										Common.Inform("<spring:message code='Cache.msg_apv_170'/>", "Inform", function(){
											window.close();
										});
									}
								} else {
									Common.Error("<spring:message code='Cache.msg_apv_030'/>");
								}
							},
							error:function(response, status, error){
								CFN_ErrorAjax(url, response, status, error);
							}
						});
					}
					
					if(actionID != "btRejectedtoDept") {
			 			Common.Confirm("<spring:message code='Cache.msg_RURegist'/>", "Confirmation Dialog", function (confirmResult) {
			 				if(confirmResult){
			 					setComment();
			 				} else {
								return false;
							}
						});
					} else {
						setComment();
					}
				} else { // 그외 의견 팝업
					if( ["btAbort","btReject","btRejectLast","btHold","btRejectedto","btRejectedtoDept","btCDisagree"].indexOf( actionID ) > -1 && $.trim( $("textarea#txtComment").val() ).length === 0 ){
						Common.Inform("<spring:message code='Cache.msg_apv_064' />");
					}else if(actionID == "btHold" && !checkRereserve()){
					}else {
						if(actionID === "btRejectedto" && !setRJTApvList()) {
							return false;
						}

						$("#commentOK").prop("disabled", true);
						
						if(l_aObjFileList.length > 0) {
							var formData = new FormData();
							for (var i = 0; i < l_aObjFileList.length; i++) {
								typeof l_aObjFileList[i] === 'object' && formData.append("fileData_comment[]", l_aObjFileList[i]);
				            }
					
						// 첨부 업로드
						$.ajax({
							type : "POST",
							data : formData,
							url : "/approval/commentFileUpload.do",
							dataType : 'json',
					            		processData : false,
					            		contentType : false,
					            		async: false,
						success:function (data) {
							if(data.status === "FAIL") {
								Common.Error(data.message);								
								$("#commentOK").prop('disabled', false)
							}
							else {
								// 첨부 추가시에는 의견이 무조건 있어야 함.
								$.trim( $("textarea#txtComment").val() ).length === 0 && $("textarea#txtComment").val("<spring:message code='Cache.msg_apv_189' />"); 
								m_oFormMenu.document.getElementById("ACTIONCOMMENT").value = Base64.utf8_to_b64($("textarea#txtComment").val());
								m_oFormMenu.document.getElementById("ACTIONCOMMENT_ATTACH").value = JSON.stringify(data.result);
								//m_oFormMenu.commentPopupReturnValue = true;
								typeof m_oFormMenu.commonWritePopupOnload === "function" && m_oFormMenu.commonWritePopupOnload.call({ g_authKey : _g_authKey, g_password : _g_password })
								
								window.close();	
							}
						},
						error:function(response, status, error){
							CFN_ErrorAjax(url, response, status, error);
						}
					});
					}else {
						m_oFormMenu.document.getElementById("ACTIONCOMMENT").value = Base64.utf8_to_b64($("textarea#txtComment").val());
						//m_oFormMenu.commentPopupReturnValue = true;
						typeof m_oFormMenu.commonWritePopupOnload === "function" && m_oFormMenu.commonWritePopupOnload.call({ g_authKey : _g_authKey, g_password : _g_password })
						window.close();	
					}
				}
			} 
		 });
		 //commentOK
	});
	
	// 의견창 높이조절
	function setCommentSize(){
		var divHeight = $("#div_comment").outerHeight();
		var otherHeight = 14; // 기본 padding
		var commentHeight = 100;
		
		$("#div_comment").find("tr").not("#tr_comment").each(function(idx,item){
			if($(item).is(":visible")) otherHeight += $(item).outerHeight();
		});
		commentHeight = divHeight - otherHeight;
		if(commentHeight < 100) commentHeight = 100;
		
		$("#txtComment").height(commentHeight);
	}  
	
	//사용자 전자결재 비밀번호 확인
	function chkCommentWrite(pPassword){
		var returnval = false;
		
		$.ajax({
			url:"chkCommentWrite.do",
			type:"post",
			data: {
				"ur_code" : Common.getSession("USERID"),
				"password" : aesUtil.encrypt(proaas, proaaI, proaapp, pPassword), 
			},
			async:false,
			success:function (res) {				
				if(res){					
					returnval = true;					
				} else {					
					returnval = false;
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("chkCommentWrite.do", response, status, error);
			}
		});
		return returnval;
	}
	
	//사용자 전자결재 비밀번호 사용유무 조회
	function chkUsePasswordYN(){
		var returnval = false;
		
		$.ajax({
			url:"chkUsePasswordYN.do",
			type:"post",
			data: {
				"ur_code" : Common.getSession("USERID"),
			},
			async:false,
			success:function (res) {				
				if(res){					
					returnval = true;					
				} else {					
					returnval = false;
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("chkUsePasswordYN.do", response, status, error);
			}
		});
		return returnval;
	}
	
	// 지정반려 radio 클릭할 때마다 호출
	function chkAction(oRdo) {
        var aApprove = oRdo.value.split("@");
        sTaskID = aApprove[0];
        sApvName = aApprove[1];
    }
	
	// 지정반려 결재선 세팅 함수
	function doRejectToAction(){
		$("#tr_rejectto").show();
		$("#tr_rejectto_table").show();
		
		var oApprovedSteps;
        if (m_oFormMenu.getInfo("Request.mode") == "RECAPPROVAL") {
            oApprovedSteps = $$(m_oApvList).find("division").has(">taskinfo[status='pending']").find(">step[routetype='approve']>ou>person").has("taskinfo[kind!='charge'][kind!='review'][kind!='bypass'][kind!='skip'][kind!='reference'][status='completed']").has("taskinfo[rejectee!='y'][rejectee!='n']").find(">taskinfo");
        } else if (m_oFormMenu.getInfo("Request.mode") == "SUBAPPROVAL") { 
            oApprovedSteps = $$(m_oApvList).find("division").has(">taskinfo[status='pending']").find(">step[routetype='consult']>ou, >step[routetype='assist']>ou").has("taskinfo[status='pending'][piid='" + m_oFormMenu.getInfo("ProcessInfo.ProcessID").toUpperCase() + "']").find(">person").has("taskinfo[kind!='review'][kind!='bypass'][kind!='skip'][kind!='conveyance'][status='completed']").has("taskinfo[rejectee!='y'][rejectee!='n']").find(">taskinfo");
        } else {
            oApprovedSteps = $$(m_oApvList).find("division").has(">taskinfo[status='pending']").find(">step[routetype='approve']>ou>person").has("taskinfo[kind!='charge'][kind!='review'][kind!='bypass'][kind!='skip'][kind!='reference'][status='completed']").has("taskinfo[rejectee!='y'][rejectee!='n']").find(">taskinfo");
        }

        if (m_oFormMenu.getInfo("SchemaContext.scRJTO.isUse") == "Y" && m_oFormMenu.getInfo("SchemaContext.scRJTO.value") != "") {
            var iRJCnt = 0;
            var oRJSteps;
            if (m_oFormMenu.getInfo("Request.mode") == "RECAPPROVAL") {
                oRJSteps = $$(m_oApvList).find("steps>division").has(">taskinfo[status='pending']").find(">step[routetype='approve']>ou>person>taskinfo[rejectee='y']");
            } else if (m_oFormMenu.getInfo("Request.mode") == "SUBAPPROVAL") {
                oRJSteps = $$(m_oApvList).find("steps>division").has(">taskinfo[status='pending']").find(">step[routetype='consult']>ou, >step[routetype='assist']>ou").has("taskinfo[status='pending'][piid='" + m_oFormMenu.getInfo("ProcessInfo.ProcessID").toUpperCase() + "']").find(">person>taskinfo[rejectee='y'], >role>taskinfo[rejectee='y']");
            } else {
                oRJSteps = $$(m_oApvList).find("steps>division").has(">taskinfo[status='pending']").find(">step[routetype='approve']>ou").find(">person>taskinfo[rejectee='y'], >role>taskinfo[rejectee='y']");
            }

            iRJCnt = oRJSteps.length;
            if (iRJCnt >= parseInt(m_oFormMenu.getInfo("SchemaContext.scRJTO.value"))) {
                Common.Inform("<spring:message code='Cache.msg_apv_110' />");
                return false;
            }
        }
        if (oApprovedSteps.length == 0) {
            Common.Inform("<spring:message code='Cache.msg_apv_110' />");
            return false;
        } else {
            var iApvCNT = 0;
            var szCode = "";
            var szName = "";
            $$(oApprovedSteps).concat().each(function (i, oTaskInfo){
                var oStep = $$(oTaskInfo).parent().parent().parent();
                if ($$(oStep).attr("allottype") != "parallel") {
                    if (m_oFormMenu.getInfo("Request.mode") == "RECAPPROVAL") {
                        oTaskInfo= $$(oStep).find("ou>person>taskinfo[kind!='conveyance'], ou>role>taskinfo[kind!='conveyance']");
                    } else if (m_oFormMenu.getInfo("Request.mode") == "SUBAPPROVAL") {
                        oTaskInfo= $$(oStep).find("taskinfo");
                    } else {
                        oTaskInfo= $$(oStep).find("ou>person>taskinfo[kind!='conveyance'], ou>role>taskinfo[kind!='conveyance']");
                    }
                    if ($(oTaskInfo).attr("rejectee") != 'y') {
                        iApvCNT++;
                        szCode =$$(oTaskInfo).parent().attr("wiid");
                        szName = $$(oTaskInfo).parent().attr("name");
                    }
                }
            });
            if (iApvCNT > 0) {
                //지정반려 작업
                var szTemp = "";
                var trCnt = 1;
                
                if (m_oFormMenu.getInfo("Request.mode") == "RECAPPROVAL") {
	                	oApprovedSteps = $$(m_oApvList).find("division").has(">taskinfo[status='pending']").find(">step[routetype='approve']").has("taskinfo[kind!='charge'][kind!='review'][kind!='skip'][kind!='bypass'][kind!='reference'][kind!='conveyance'][status='completed']").has("taskinfo[rejectee!='y'][rejectee!='n']");
	                    var nCount = oApprovedSteps.length-1;
	                    //var sClassName = "appointment_td";
	                    $$(oApprovedSteps).concat().each(function (i,oStep){
	                        //if(nCount==i) sClassName= "appointment_td_last";
	                        if ($$(oStep).attr("allottype") != "parallel") {
	    	                    oPerson = $$(oStep).find("ou>person").has("taskinfo[kind!='conveyance']").concat().eq(0);
	    	                    oTaskInfo = $$(oPerson).find("taskinfo");
	    	                    if ($$(oTaskInfo).attr("rejectee") != 'y') {
	    	                    	szTemp += "<tr align='center'>";
	    	                    	szTemp += "<td>";
	    	                    	szTemp += "<input type='radio' name='rejectToRadio' onclick='chkAction(this);' value='"+$$(oPerson).parent().attr("taskid")+"@"+$$(oPerson).attr("name")+"' onclick=''>&nbsp;"+CFN_GetDicInfo($$(oPerson).attr("name"));
	    	                    	szTemp += "</td>";
	    	                    	szTemp += "<td>"+CFN_GetDicInfo($$(oPerson).attr("ouname"))+"</td>";
	    	                    	szTemp += "<td>"+((typeof $$(oPerson).attr("level") != "string") ? "" : CFN_GetDicInfo($$(oPerson).attr("level").split(";")[1]))+"</td>";
	    	                    	szTemp += "</tr>";
	    	                    	
	    	                    	++trCnt;
	    	                    }
	    	                }
	                    });
        	        } else if (m_oFormMenu.getInfo("Request.mode") == "SUBAPPROVAL") {
                        oApprovedSteps = $$(m_oApvList).find("division").has(">taskinfo[status='pending']").find(">step").has("taskinfo[status='pending']").find(">ou").has("taskinfo[status='pending']").has("taskinfo[piid='" + m_oFormMenu.getInfo("ProcessInfo.ProcessID").toUpperCase() + "']").find(">person").has("taskinfo[kind!='review'][kind!='bypass'][kind!='skip'][kind!='conveyance'][status='completed']").has("taskinfo[rejectee!='y'][rejectee!='n']");
        	            $$(oApprovedSteps).concat().each(function (i,oPerson){
        	                oTaskInfo = $$(oPerson).find("taskinfo");
        	                if ($$(oTaskInfo).attr("rejectee") != 'y') {
        	                	szTemp += "<tr align='center'>";
    	                    	szTemp += "<td>";
    	                    	szTemp += "<input type='radio' name='rejectToRadio' onclick='chkAction(this);' value='"+$$(oPerson).attr("taskid")+"@"+$$(oPerson).attr("name")+"' onclick=''>&nbsp;"+CFN_GetDicInfo($$(oPerson).attr("name"));
    	                    	szTemp += "</td>";
    	                    	szTemp += "<td>"+CFN_GetDicInfo($$(oPerson).attr("ouname"))+"</td>";
    	                    	szTemp += "<td>"+((typeof $$(oPerson).attr("level") != "string") ? "" : CFN_GetDicInfo($$(oPerson).attr("level").split(";")[1]))+"</td>";
    	                    	szTemp += "</tr>";
    	                    	
    	                    	++trCnt;
        	                }
        	            });
        	        } else {
                        oApprovedSteps = $$(m_oApvList).find("division").has(">taskinfo[status='pending']").find(">step[routetype='approve']").has("taskinfo[kind!='charge'][kind!='review'][kind!='skip'][kind!='bypass'][kind!='reference'][kind!='conveyance'][status='completed']").has("taskinfo[rejectee!='y'][rejectee!='n']");
                        var nCount = oApprovedSteps.length-1;
                        //var sClassName = "appointment_td";
                        $$(oApprovedSteps).concat().each(function (i,oStep){
                            //if(nCount==i) sClassName= "appointment_td_last";
                            if ($$(oStep).attr("allottype") != "parallel") {
        	                    oPerson = $$(oStep).find("ou>person").has("taskinfo[kind!='conveyance']").concat().eq(0);
        	                    oTaskInfo = $$(oPerson).find("taskinfo");
        	                    if ($$(oTaskInfo).attr("rejectee") != 'y') {
        	                    	szTemp += "<tr align='center' style='font-size: 14px;'>";
        	                    	szTemp += "<td>";
        	                    	szTemp += "<input type='radio' name='rejectToRadio' onclick='chkAction(this);' value='"+$$(oPerson).parent().attr("taskid")+"@"+$$(oPerson).attr("name")+"' onclick=''>&nbsp;"+CFN_GetDicInfo($$(oPerson).attr("name"));
        	                    	szTemp += "</td>";
        	                    	szTemp += "<td>"+CFN_GetDicInfo($$(oPerson).attr("ouname"))+"</td>";
        	                    	szTemp += "<td>"+((typeof $$(oPerson).attr("level") != "string") ? "" : CFN_GetDicInfo($$(oPerson).attr("level").split(";")[1]))+"</td>";
        	                    	szTemp += "</tr>";
        	                    	
        	                    	++trCnt;
        	                    }
        	                }
                        });
        	        }
                	$("#th_rejecttoTitle").attr("rowspan", trCnt);
        	        $("#tr_rejectto").after(szTemp);
            } else {
                Common.Inform("<spring:message code='Cache.msg_apv_110' />");
                return false;
            }
        }
	}
	
	// 지정반려 선택한 결재선 세팅
	function setRJTApvList() {
        var oLastStep;
	    var oSteps;
	    
	    if($("input[type='radio'][name='rejectToRadio']:checked").length == 0) {
	    	Common.Warning(Common.getDic("msg_apv_291"));
	    	return false;
	    }
	    
	    if ( m_oFormMenu.getInfo("Request.mode") == "RECAPPROVAL"){
	    	oLastStep = $$(m_oApvList).find("division").has(">taskinfo[status='pending']").find(">step").has("taskinfo[kind!='charge'][kind!='review'][kind!='skip'][kind!='bypass'][status='inactive']"); 
            oSteps = $$(m_oApvList).find("division").has(">taskinfo[status='pending']").has("step[routetype='approve'],[routetype='assist'],[routetype='consult']").find(">step").has("taskinfo[kind!='review'][kind!='bypass'][kind!='skip']").has("taskinfo[status='completed'],[status='pending'],[status='reserved']").has("taskinfo[rejectee!='y'][rejectee!='n']");
	    }else if ( m_oFormMenu.getInfo("Request.mode") == "SUBAPPROVAL"){
            oLastStep = $$(m_oApvList).find("division").has(">taskinfo[status='pending']").find(">step").has("taskinfo[status='pending']").find(">ou").has("taskinfo[status='pending'][piid='"+m_oFormMenu.getInfo("ProcessInfo.ProcessID").toUpperCase()+"']").find(">person").has("taskinfo[status='inactive']");
            oSteps = $$(m_oApvList).find("division").has(">taskinfo[status='pending']").find(">step").has("taskinfo[status='pending']").find(">ou").has("taskinfo[status='pending'][piid='"+m_oFormMenu.getInfo("ProcessInfo.ProcessID").toUpperCase()+"']").find(">person").has("taskinfo[kind!='bypass'][kind!='skip'][kind!='conveyance']").has("taskinfo[status='completed'],[status='pending'],[status='reserved']").has("taskinfo[rejectee!='y'][rejectee!='n']");
	    }else{
            oLastStep = $$(m_oApvList).find("division").has(">taskinfo[status='pending']").find(">step").has("taskinfo[kind!='charge'][kind!='review'][kind!='skip'][kind!='bypass'][status='inactive']"); 
            //oSteps = $$(m_oApvList).find("division").has(">taskinfo[status='pending']").has("step[routetype='approve'],[routetype='assist']").find(">step").has("taskinfo[kind!='charge'][kind!='review'][kind!='bypass'][kind!='skip']").has("taskinfo[status='completed'],[status='pending'],[status='reserved']").has("taskinfo[rejectee!='y'][rejectee!='n']");
            oSteps = $$(m_oApvList).find("division").has(">taskinfo[status='pending']").has("step[routetype='approve'],[routetype='assist'],[routetype='consult']").find(">step").has("taskinfo[kind!='charge'][kind!='review'][kind!='skip'][kind!='bypass'][status='completed'],taskinfo[kind!='charge'][kind!='review'][kind!='skip'][kind!='bypass'][status='pending'],taskinfo[kind!='charge'][kind!='review'][kind!='skip'][kind!='bypass'][status='reserved'],taskinfo[kind='bypass'][status='inactive']").has("taskinfo[rejectee!='y'][rejectee!='n']");
	    }
	    
		// 지정반려 타입
		// 1: 순서변경 없이 부서합의/협조 이전으로 지정반려
		// 2(기본): 중간에 합의/협조가 있는 경우 일반결재자만 다시 결재할 수 있도록 순서변경
	    var RejectedtoType = Common.getBaseConfig("RejectedtoType"); // 1 or 2

	    var oStep, oPerson, oTaskInfo, oTaskID;
	    var cnt=0;
        $$(oSteps).concat().each(function (x,oStep){
		    if (m_oFormMenu.getInfo("Request.mode") == "SUBAPPROVAL"){
			    oPerson = oStep;
			    oTaskID = oPerson.attr("taskid");
		    }else{
		    	oPerson = $$(oStep).find("ou").find("person, role:has(taskinfo[kind!='conveyance'])");
		    	oTaskID = oPerson.parent().attr("taskid");
		    }
		    oTaskInfo = oPerson.find("taskinfo");
		    
		    if ($$(oTaskInfo).attr("status") == "pending" || $$(oTaskInfo).attr("status") == "reserved") { //지정반송자	                
            	// 지정반려 의견 추가
                $$(oTaskInfo).attr("comment", {"#text" : Base64.utf8_to_b64($("textarea#txtComment").val()) });
		    
		    	// 의견 팝업에서 지정반려 시간도 추가함.
		    	$$(oTaskInfo).attr("daterejectedto", m_oFormMenu.getInfo("AppInfo.svdt_TimeZone"));
            }
		    
		    //넘어온 코드와 같다면 결재선에 추가
		    if ( oTaskID == sTaskID || bAdd == true){
			    var oCStep = $.parseJSON(JSON.stringify($$(oStep).json()));		//$$(oStep).clone();
			    var oCTaskInfo;
			    if ( m_oFormMenu.getInfo("Request.mode") == "SUBAPPROVAL"){
				    oCTaskInfo = $$(oCStep).find("taskinfo");
			    }else{
				     var oCOU = $$(oCStep).find("ou");
				     var oCUnitType = $$(oCStep).attr("unittype");
				     var oCRouteType = $$(oCStep).attr("routetype");
                    //전달자들은 삭제 2006.03. by sunny
                    /*var oRmvPerson;
                    oRmvPerson = $$(oCOU).find("person:has(taskinfo[kind='conveyance']), role:has(taskinfo[kind='conveyance'])");
                    for(var i=0; i<$$(oRmvPerson).concat().length; i++){
                    	$$(oRmvPerson).concat().eq(i).remove();
                    }*/
                    $$(oCOU).find("person, role").has("taskinfo[kind='conveyance']").remove();

                    //대결자 삭제
                    /*oRmvPerson = $$(oCOU).find("person:has(taskinfo[kind='substitute']), role:has(taskinfo[kind='substitute'])");
                    for(var i=0; i<$$(oRmvPerson).concat().length; i++){
                    	$$(oRmvPerson).concat().eq(i).remove();
                    }*/
                    $$(oCOU).find("person, role").has("taskinfo[kind='substitute']").remove();
                    
                    if(oCUnitType != "ou" && oCRouteType != "assist" && oCRouteType != "consult") {
                    	oCTaskInfo = $$(oCStep).find("ou").find("person,role").find(">taskinfo[kind!='conveyance']");
                    }
                    else if(RejectedtoType == "1" && oCUnitType == "person" && (oCRouteType == "assist" || oCRouteType == "consult")) {
                    	oCTaskInfo = $$(oCStep).find("taskinfo[kind!='conveyance']");
                    	$$(oCTaskInfo).attr("status", "inactive");
			            $$(oCTaskInfo).attr("result", "inactive");
                    	
                    	$$($$(oCStep).find("ou").find("person,role")).each(function (i, obj) {
                    		oCTaskInfo = $$(obj).find(">taskinfo[kind!='conveyance']");
                        	
                        	if(oCTaskInfo != null) {
    						    $$(oCTaskInfo).attr("status", "inactive");
    				            $$(oCTaskInfo).attr("result", "inactive");
    				            
    				            // 재기안자한테 반려하는 경우는 charge 유지하도록 수정함. 
    			                //if($$(oCTaskInfo).attr("kind")=="bypass" || $$(oCTaskInfo).attr("kind")=="charge") $$(oCTaskInfo).attr("kind", "normal");
    			                if($$(oCTaskInfo).attr("kind")=="bypass") $$(oCTaskInfo).attr("kind", "normal");
    			                $$(oCTaskInfo).remove("datereceived");
    			                $$(oCTaskInfo).remove("datecompleted");
    			                $$(oCTaskInfo).remove("customattribute1");
    			                $$(oCTaskInfo).remove("wiid");
    			                $$(oCTaskInfo).remove("visible");
    			                $$(oCTaskInfo).remove("rejectee");
    			                $$(oCTaskInfo).parent().parent().remove("widescid");
    			                $$(oCTaskInfo).parent().parent().remove("pfid");
    			                $$(oCTaskInfo).parent().parent().remove("taskid");
    			                $$(oCTaskInfo).parent().parent().remove("wiid");
    					    }
                    	});
                    }
                    else if(RejectedtoType == "1" && oCUnitType == "ou" && (oCRouteType == "assist" || oCRouteType == "consult")) { // 부서합의/협조는 기존 결재완료 상태 유지
                    	// step > taskinfo 속성 지우기
                    	oCTaskInfo = $$(oCStep).find("taskinfo[kind!='conveyance']");
                    	$$(oCTaskInfo).attr("status", "inactive");
			            $$(oCTaskInfo).attr("result", "inactive");
			            $$(oCTaskInfo).remove("datereceived");
			            $$(oCTaskInfo).remove("datecompleted");
			            
			            var oRmvOU = $$(oCStep).find("ou");
			            $$(oRmvOU).each(function(i, obj){
			            	// ou 속성 지우기
                        	$$(obj).concat().remove("pfid");
                        	$$(obj).concat().remove("wiid");
                        	$$(obj).concat().remove("widescid");
                        	$$(obj).concat().remove("taskid");
                        	
                        	// person, role 지우기
                        	$$(obj).concat().find("person,role").remove();
                        	
                        	// ou > taskinfo 속성 지우기
                        	var oCTaskInfo2 = $$(obj).concat().find("taskinfo[kind!='conveyance']");
                        	if(oCTaskInfo2 != null) {
    						    $$(oCTaskInfo2).attr("status", "inactive");
    				            $$(oCTaskInfo2).attr("result", "inactive");
    				            
    				         	// 재기안자한테 반려하는 경우는 charge 유지하도록 수정함.
    			                //if($$(oCTaskInfo2).attr("kind")=="bypass" || $$(oCTaskInfo2).attr("kind")=="charge") $$(oCTaskInfo2).attr("kind", "normal");
    			                if($$(oCTaskInfo2).attr("kind")=="bypass") $$(oCTaskInfo2).attr("kind", "normal");
    			                $$(oCTaskInfo2).remove("datereceived");
    			                $$(oCTaskInfo2).remove("datecompleted");
    			                $$(oCTaskInfo2).remove("customattribute1");
    			                $$(oCTaskInfo2).remove("wiid");
    			                $$(oCTaskInfo2).remove("piid");
    			                $$(oCTaskInfo2).remove("execid");
    			                $$(oCTaskInfo2).remove("pdescid");
    			                $$(oCTaskInfo2).remove("visible");
    			                $$(oCTaskInfo2).remove("rejectee");
    					    }
                        });
			            
			            oCTaskInfo = null;
                    }
                    else {
                    	return 1;
                    }
			    }
			    
			    if(oCTaskInfo != null) {
				    $$(oCTaskInfo).attr("status", "inactive");
		            $$(oCTaskInfo).attr("result", "inactive");
		            
		         	// 재기안자한테 반려하는 경우는 charge 유지하도록 수정함. 
	                //if($$(oCTaskInfo).attr("kind")=="bypass" || $$(oCTaskInfo).attr("kind")=="charge") $$(oCTaskInfo).attr("kind", "normal");
	                if($$(oCTaskInfo).attr("kind")=="bypass") $$(oCTaskInfo).attr("kind", "normal");
	                $$(oCTaskInfo).remove("datereceived");
	                $$(oCTaskInfo).remove("datecompleted");
	                $$(oCTaskInfo).remove("customattribute1");
	                $$(oCTaskInfo).remove("wiid");
	                $$(oCTaskInfo).remove("visible");
	                $$(oCTaskInfo).remove("rejectee");
	                $$(oCTaskInfo).parent().parent().remove("widescid");
	                $$(oCTaskInfo).parent().parent().remove("pfid");
	                $$(oCTaskInfo).parent().parent().remove("taskid");
	                $$(oCTaskInfo).parent().parent().remove("wiid");
	                
	                if ($$(oTaskInfo).attr("status") != "pending" && $$(oTaskInfo).attr("status") != "reserved") {
		             	$$(oCTaskInfo).find("comment").remove();
		             	$$(oCTaskInfo).find("comment_fileinfo").remove();
	                }
			    }
			    
                bAdd = true;
                
                $$(oStep).find("ou > taskinfo").attr("visible", "n"); // 부서합의 표시를 위해 ou > taskinfo > visible n으로 설정
                $$(oTaskInfo).attr("visible", "n");
                
                $$(oTaskInfo).attr("rejectee", "y");
                if ($$(oTaskInfo).attr("status") == "pending" || $$(oTaskInfo).attr("status") == "reserved") { //지정반송자
                    $$(oTaskInfo).attr("daterejectedto", m_oFormMenu.getInfo("AppInfo.svdt_TimeZone"));
                }
                
                if (m_oFormMenu.getInfo("Request.mode") == "SUBAPPROVAL") {
                	var pendingOU = $$(m_oApvList).find("division").has(">taskinfo[status='pending']").find(">step").has("taskinfo[status='pending']").find(">ou").has("taskinfo[status='pending'][piid='"+ m_oFormMenu.getInfo("ProcessInfo.ProcessID").toUpperCase()+"']");
                	
                	if(oLastStep.length>0){
                		$$(pendingOU).find(">person").json().splice(parseInt($$(oLastStep).concat().eq(0).index())+cnt, 0, $$(oCStep).concat().eq(0).json());
                		cnt++;
                	} else { // 마지막 결재자, inactive인 사용자 없을 때
                		$$(pendingOU).append("person", $$(oCStep).json());
                	}
                } else {
                    if(oLastStep.length>0){
                    	var pendingDivision = $$(m_oApvList).find("steps>division").has(">taskinfo[status='pending']");
                    	$$(pendingDivision).find(">step").json().splice(parseInt($$(oLastStep).concat().eq(0).index())+cnt, 0, $$(oCStep).concat().eq(0).json());
                    	
                    	cnt++;
                    }else{
                        $$(m_oApvList).find("steps>division").has(">taskinfo[status='pending'],[status='reserved']").append("step", $$(oCStep).json());
                    }
                }
		    }
	    });
        m_oFormMenu.document.getElementById("APVLIST").value = JSON.stringify(m_oApvList);
		
        return true;
    }
	
	// 보류에 대한 처리
	function checkRereserve() {
		var _oApvList = m_oApvList;
		if(m_oFormMenu.getInfo != undefined){
			_oApvList = $.parseJSON(m_oFormMenu.getInfo("ApprovalLine"));
		}
        var oApprovedSteps = $$(_oApvList).find("steps>division>step[routetype!='review']>ou").find(">person:has(taskinfo[status='reserved']), >ou>role:has(taskinfo[status='reserved'])");
	    if(((m_oFormMenu.getInfo != undefined ? m_oFormMenu.getInfo("Request.gloct") : m_oFormMenu.CFN_GetQueryString("gloct")) == "JOBFUNCTION") && oApprovedSteps.length == 0){
            oApprovedSteps = $$(_oApvList).find("division>step[routetype='receive']>ou> role").has("taskinfo[status='reserved']");
	    }
	    if (oApprovedSteps.length > 0){
		    Common.Inform("<spring:message code='Cache.msg_apv_065' />");//"결재 보류는 단 1회만 가능합니다."
		    return false;
	    }else{
		    return true;
	    }
    }
	
	function doCancel(){
		m_oFormMenu.commentPopupReturnValue = false;
		if (openID != "" && openID != "undefined") {
			parent.Common.close(openID);
		} else {
			window.close();
		}
	}
	
	function checkFido(){
		window.open("/covicore/control/checkFido.do?logonID="+Common.getSession("LogonID")+"&authType=Approval", "checkFido", "toolbar=no,location=no,statusbar=no,menubar=no,scrollbars=yes,resizable=no,width=410,height=510" );
	}
	
	//fido callback 함수 
	function fidoCallBack(){
		$("#iptPassword").attr("type","text").attr("disabled", "disabled").val("<spring:message code='Cache.msg_CertificationSuccess'/>");
		$("#btnFIDO").attr("class", "btnTypeDefault btnTypeChk").attr("onclick", "return false;").text("<spring:message code='Cache.lbl_authStatus_succ'/>");
		authFIDO = true;
	}
</script>
<body>
	<div class="layer_divpop ui-draggable" id="testpopup_p" style="min-width:540px; width:100%; z-index: 51;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="pop_header" id="testpopup_ph" style="display:none;">
				<h4 class="divpop_header ui-draggable-handle" id="testpopup_Title">
					<span class="divpop_header_ico"><spring:message code='Cache.lbl_apv_comment_write'/></span><!-- 의견 작성 -->
				</h4>
		    </div>
		    <div id="div_comment" style="overflow-x: hidden; overflow-y: auto; height: 220px; margin: 20px 30px 0px 30px;">
				<table class="tableStyle">
					<colgroup>
						<col style="width:100px;">
						<col style="width:*">
					</colgroup>
					<thead>
						<tr id="tr_passwork" style="display: none">
							<th><spring:message code='Cache.lbl_apv_approvalpwd'/></th><!-- 결재비밀번호 -->
							<td colspan="3">
								<input type="password" class="W200" id="iptPassword">
								<a id="btnFIDO" class="btnTypeDefault btnTypeChkLine" style="display:none; height:31px;" onclick="checkFido(); return false;">FIDO 인증&nbsp;</a>
							</td>
						</tr>
						<tr id="tr_rejectto" style="display: none">
							<th id="th_rejecttoTitle" rowspan="2"><spring:message code='Cache.lbl_apv_setschema_57'/></th><!-- 지정반려 -->
							<th><spring:message code='Cache.lbl_ApprovalUser'/></th><!-- 결재자 -->
							<th><spring:message code='Cache.lbl_dept'/></th><!-- 부서 -->
							<th><spring:message code='Cache.lbl_JobLevel'/></th><!-- 직급 -->
						</tr>
						<tr id="tr_comment">
							<th><span id="span_comment"></span></th>
							<td colspan="3">
								<textarea id="txtComment" name="txtComment" style="width:100%;resize:none" ></textarea>
							</td>
						</tr>
					</thead>
				</table>
			</div>
			
			<!-- 첨부파일 시작 작성페이지의 경우 첨부파일Uload UX 조회페이지 다운로드UX표시 -->
			<div id="attachDiv" style="display: none; margin: 20px 30px 0px 30px;">
				<table class="tableStyle linePlus">
				  <colgroup>
				  <col style="width:100%">
				  </colgroup>
				  <tbody>
				    <tr>
				      <td style="padding: 5px 10px 10px;">
				      		<!-- 첨부파일 컨트롤 시작 -->
				            <!-- 파일 컨트롤 타입 설정 : 0.None, 1.DEXTUploadX, 2.CoviFileTrans, 3.CoviSilverlightTrans, 4.CoviUploadNSlvTrans, 5.HTML 5 -->
				            <div id="divFileControlContainer"></div>
				            <div style="width:0px; height:0px; float:right; overflow-x:hidden;">
				            	<input type="file" multiple name="FileSelect" id="FileSelect" onchange="javascript:FileSelect_onchange();" style="opacity:0;"/>
				            	<input type="submit" id="btnsubmit" style="display:none;"/>
				            	<input type="hidden" id="hidsaveFileName" />
				            	<input type="hidden" id="hidDeletFiles" />
				            </div>
				            </form>
				            <div class="addDataBtn">
				            	<input type="button" class="smButton" onclick="AddFile();" value="<spring:message code='Cache.btn_addfile'/>">
				            	<input type="button" class="smButton" onclick="DeleteFile();clearDeleteFront();" value="<spring:message code='Cache.lbl_apv_file_delete'/>">
				            	<input id="webhardAttach" type="button" class="smButton" onclick="AddWebhardFile();" style="display:none;" value="<spring:message code='Cache.lbl_webhard'/>">
				            </div>
				            <div ondragenter="onDragEnter(event)" ondragover="onDragOver(event)" ondrop="onDrop(event)" style="min-height:125px;">
				             <div class="file_controls"  class="addData">
				             	<table id="tblFileList" class="fileHover">
				              	<colgroup>
				              		<col style="width:25px">
				              		<col style="width:25px">
				              		<col style="width:*">
				              		<col style="width:120px">
				              	</colgroup>
				               <tbody id = "fileInfo" style="background-color:white;">
				                	<tr id="trFileInfoBox" style="height:99%">
				                		<td colspan="4">
				                			<div class="dragFileBox"><span class="dragFile">icn</span><spring:message code="Cache.lbl_DragFile"/></div>
				                		</td>
				                	</tr>
				               </tbody>
				              </table>
				             </div>
				            </div>
				        </td>
				    </tr>
				    </tbody>
				</table>
				
				<input type="hidden" ID="hidFrontPath"/>
				<input type="hidden" ID="hidFileSize"/>
				<input type="hidden" ID="hidOldFile"/>
				<input type="hidden" ID="hidDeleteFront"/>
				<input type="hidden" ID="hidImageFile"/>
				<input type="hidden" ID="hidDeleteFile"/>
				<input type="hidden" ID="hidUseVideo" Value="N" />
				<input type="hidden" ID="hidFileSeq"/>
			</div>
			<!-- 첨부파일 컨트롤 끝 -->
			<div class="form_footer"></div>
						
			
			<!-- 하단버튼 시작 -->
			<div class="popBtn borderNon">
				<input id="commentOK" type="button" class="ooBtn ooBtnChk"  value="<spring:message code='Cache.btn_apv_confirm'/>" disabled="true" /><!-- 확인 -->
				<input id="commentCancel" type="button" class="owBtn mr30"  value="<spring:message code='Cache.btn_apv_close'/>"  onclick="doCancel();"/><!-- 닫기 -->
			</div>
			<!-- 하단버튼 끝 -->
		</div>
	</div>
</body>