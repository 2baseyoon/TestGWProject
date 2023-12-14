<%@ page language="java" contentType="text/html; charset=UTF-8"  pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/include.jsp"></jsp:include>
	<style>
		/* div padding */
		.divpop_body {
			padding: 20px !important;
		}
		
		th, td{
			font-size: 13px;
		}
		
	</style>
</head>

<form id="form1">
	<div style="width:100%;">
		<table class="tableStyle linePlus">
			<colgroup>	
					<col style="width: 30%">
					<col style="width: 70%">
				</colgroup>
			<tbody>
				<tr id="TrRequestor">
					<th id="thTitle"><spring:message code="Cache.lbl_Requester"/></th><!-- 요청자 -->
					<td id="TdRequestor"></td>
				</tr>
				<tr id="TrServiceType">
					<th id="thTitle"><spring:message code="Cache.lbl_Section"/></th><!-- 영역 -->
					<td id="TdServiceType"></td>
				</tr>
				<tr id="TrMsgType">
					<th id="thTitle"><spring:message code="Cache.lbl_MessageType"/></th><!-- 메세지 유형 -->
					<td id="TdMsgType"></td>
				</tr>
				<tr id="TrTitle">
					<th id="thTitle"><spring:message code="Cache.lbl_Title"/></th><!-- 제목 -->
					<td id="TdTitle"></td>
				</tr>	
				<tr id="TrContent">
					<th id="thTitle"><spring:message code="Cache.lbl_Contents"/></th><!-- 내용 -->
					<td id="TdContent"></td>
				</tr>
				<tr id="TrMediaType">
					<th id="thTitle"><spring:message code="Cache.lbl_NoOfShipping"/></th><!-- 발송건수 -->
					<td id="TdMediaType"></td>
				</tr>
				<tr id="TrRegistDate">
					<th id="thTitle"><spring:message code="Cache.lbl_ApproveDate"/></th><!-- 요청일자 -->
					<td id="TdRegistDate"></td>
				</tr>
			</tbody>
		</table>
		<div style="width: 100%; text-align: center; margin-top: 10px;">
			<input type="button"  value="<spring:message code='Cache.lbl_Approval' />" onclick="return ApproveMessaging();" class="AXButton" > <!-- 승인 -->
			<input type="button"  value="<spring:message code='Cache.lbl_Reject' />" onclick="return RejectMessaging();" class="AXButton" > <!-- 거부 -->
			<input type="button" id="btnClose" value="<spring:message code='Cache.btn_Close' />" onclick="closePopup();" class="AXButton" > <!-- 닫기 -->
		</div>
	</div>
</form>
<script type="text/javascript">

	var msgID = "${msgID}";
	var sRejectOpinion = "";
	
	//개별호출 일괄처리
	var sessionObj = Common.getSession();
	Common.getBaseCodeList(["TodoMsgType"]);
	
	window.onload = initContent();
	
	function initContent(){
		setTimeout(function(){getMsgInfo();}, 10);
	};
	
	function getMsgInfo(){		
		
		$.ajax({
			type:"POST",
			data:{
				"MessagingID": msgID,
 				"ServiceType": "",
 				"MsgType": "",
 				"SearchColumn": "",
 				"SearchText": ""
			},
			url:"/covicore/admin/messaging/getmessagingapprovallist.do",
			success:function (data) {
				  var sReturn = "";
				  var oMType =  (data.list[0].MediaType).split('@');
				  for(var i = 0; i<oMType.length; i++){
					  sReturn += " <input type=\"checkbox\" checked style='margin-top:-1px;margin-right:2px;' ";
					  sReturn += "mediatype='" + oMType[i].split(';')[0] + "'> " ;
					  sReturn += Common.getDic("NotificationMedia_" + oMType[i].split(';')[0]) + " : " + oMType[i].split(';')[1];
					  sReturn += "&nbsp;&nbsp;";
				  }
				$("#TdRequestor").text(data.list[0].SenderCode);
				$("#TdServiceType").text(Common.getDic('TodoCategory_' + data.list[0].ServiceType));
				$("#TdMsgType").text(Common.getDic('TodoMsgType_' + data.list[0].MsgType));
				$("#TdTitle").text(data.list[0].MessagingSubject);
				$("#TdContent").text(data.list[0].ReceiverText);
				$("#TdMediaType").html(sReturn);
				$("#TdRegistDate").text(data.list[0].RegistDate);
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/admin/orgmanage/getgroupinfo.do", response, status, error);
			}
		});
	}
		
	function closePopup() {
		Common.Close();
	}
	
	function ApproveMessaging(){ //체크가 된 항목만 승인처리하고 체크가 되지 않은 항목은 거부처리함.

		var strAlert = "<spring:message code='Cache.msg_RUApprove'/>"; //승인하시겠습니까?
		strAlert += "<spring:message code='Cache.msg_MessagingApprovalRest'/>"; //<br />※ 체크된 항목만 {0} 처리되며, 나머지는 자동 {1} 처리됩니다.
		strAlert = strAlert.replace("{0}", "승인").replace("{1}", "거부");
		
		Common.Confirm(strAlert, "Confirmation Dialog", function (result) {
			if(result) {
				var strNoChk = "";
				var chks = $('input:checkbox:not(:checked)');
		        $.each(chks, function (i, chk) {
		        	strNoChk += $(this).attr('mediatype') + ";";
		        });
		        
		      //1. 체크가 되지 않은 항목은 string으로 만들어서 comonService에 있는 함수를 호출
		        $.ajax({
					type:"POST",
					data:{
						"Delimiter" : ";", 
						"RejectMediaType" : strNoChk, 
						"MessagingID" : msgID
					},
					url:"/covicore/admin/messaging/editmessagingpartialapproval.do",
					success:function (data) {
						if(data.status == "FAIL") {
							Common.Warning(data.message);
						} else {
							//2. 요청자가 요청한 알림을 승인하며 발송되도록 설정
							$.ajax({
								type:"POST",
								data:{
									"MessagingState" : 2, // 플래그 값을 취소로 바꿔줌
									"ApprovalState" : "A", //플래그 값을 승인으로 : ApprovalState를 A(pproval)로 바꿔줘야 함
									"MessagingID" : msgID,
								},
								url:"/covicore/admin/messaging/editmessagingdata.do",
								success:function (data) {
									if(data.status == "FAIL") {
										Common.Warning(data.message);
									} else {
										//알림 발송
										noticeResult("Approve", $("#TdRequestor").text());
									}
								},
								error:function(response, status, error){
									CFN_ErrorAjax("/covicore/admin/messaging/editmessagingdata.do", response, status, error);
								}
							});
						}
					}
				});
			}//if - result
		});//common - confirm
	}
	
	function RejectMessaging(){
		Common.Confirm("<spring:message code='Cache.msg_RUReject'/><spring:message code='Cache.msg_ALLReject'/>", "Confirmation Dialog", function (result) {// 거부하시겠습니까?  체크여부에 상관없이 모두 거부됩니다. 
			if(result) {
				//의견 받기
				Common.PromptArea("<spring:message code='Cache.msg_161'/>", "", "<spring:message code='Cache.lbl_Confirm'/>", function (result2) { 
                    if (result2 != null) {
                    	sRejectOpinion = result2;
                    	
						$.ajax({
							type:"POST",
							data:{
								"MessagingID" : msgID,
								"ApprovalState" : "C", // 플래그 값을 발송취소로 : ApprovalState를 C(ancel)로 바꿔줘야 함
								"MessagingState" : 4 // 플래그 값을 취소로 바꿔줌
							},
							url:"/covicore/admin/messaging/editmessagingdata.do",
							success:function (data) {
								if(data.status == "FAIL") {
									Common.Warning(data.message);
								} else {
									//알림 발송
    								noticeResult("Reject", $("#TdRequestor").text());
								}
							},
							error:function(response, status, error){
								CFN_ErrorAjax("/covicore/admin/messaging/editmessagingdata.do", response, status, error);
							}
						});
                    }//if - result2
                });//common - prompt
			}//if - result
		});//common - confirm
	}
	
	function noticeResult(mode, receiverCode){
		
		var SenderCode = sessionObj["UR_Code"];
        var RegistererCode = sessionObj["UR_Code"];
        var ApprovalState = "P";
        var ApproverCode = "";
        var ReceiversCode = receiverCode;
        var MessagingSubject = "";
        var MessageContext = "";
        var ReceiverText = "";
        $(coviCmn.codeMap["TodoMsgType"]).each(function(idx, obj) {
			if (obj.Code == 'MessagingApproval'){
				MediaType = obj.Reserved1; 
				ServiceType = obj.BizSection; 
				MsgType = obj.Code; 
			}
		});
        
      //요청자에게 승인/거부되었음을 알려주는 알림 생성
		if(mode == "Approve"){ /* 승인 */
			MessagingSubject = "<spring:message code='Cache.lbl_ApproveSendingRequest'/>"; //발송 요청 승인
			MessageContext = "<spring:message code='Cache.msg_ApproveSendingRequest'/>"; //발송 요청을 승인하였습니다.
			ReceiverText = "<spring:message code='Cache.msg_ApproveSendingRequest'/>"; //발송 요청을 승인하였습니다.
			 
			//체크 항목 가져오기
			var chks = $('input:checkbox:not(:checked)');
	        $.each(chks, function (i, chk) {
	        	ReceiverText += Common.getDic("NotificationMedia_" + $(this).attr('mediatype')) + ", ";
	        });
	        if(ReceiverText.slice(-2) == ", "){
	        	ReceiverText = ReceiverText.slice(0, -2);
	        }
	        ReceiverText += "<spring:message code='Cache.msg_ItisRejected'/>"; /* 는 거부되었습니다. */
		} else { /* 거부 */
			MessagingSubject = "<spring:message code='Cache.lbl_RejectSendingRequest'/>"; //발송 요청 거부
			MessageContext = sRejectOpinion;
			ReceiverText = sRejectOpinion;
		}
      
		$.ajax({
			type:"POST",
			data:{
				"SenderCode" : SenderCode,
		        "RegistererCode" : RegistererCode,
		        "ApprovalState" : ApprovalState,
		        "ApproverCode" : ApproverCode,
		        "ReceiversCode" : ReceiversCode,
		        "MessagingSubject" : MessagingSubject,
		        "MessageContext" : MessageContext,
		        "ReceiverText" : ReceiverText,
		        "MediaType" : MediaType,
		        "ServiceType" : ServiceType,
		        "MsgType" : MsgType
			},
			url:"/covicore/admin/messaging/setmessagingdata.do",
			success:function (data) {
				if(data.status == "FAIL") {
					Common.Warning(data.message);
				} else {
					Common.Inform("<spring:message code='Cache.msg_ProcessOk'/>", "Information Dialog", function(result) {
						if(result) {
							parent.myGrid.reloadList();
							closePopup();
						}
					});
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/admin/messaging/setmessagingdata.do", response, status, error);
			}
		});
	}	
</script>
