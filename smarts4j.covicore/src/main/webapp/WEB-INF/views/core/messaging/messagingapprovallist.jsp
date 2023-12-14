<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code="Cache.CN_719"/></span>
	<!-- TODO 초기 페이지로 설정 향후 개발 (미구현 사항으로 숨김처리) -->
	<%-- <a href="#" class="set_box">
		<span class="set_initialpage"><p><spring:message code="Cache.btn_SettingFirstPage"/></p></span>
	</a> --%>
</h3>
<form id="form1">
	<div style="width:100%;min-height: 500px">
		<div id="topitembar01" class="topbar_grid">
			<label>
				<input type="button" value="<spring:message code="Cache.btn_Refresh"/>" onclick="Refresh();" class="AXButton BtnRefresh"/>
				<input type="button" value="<spring:message code="Cache.lbl_Approval"/>" onclick="Approve();" class="AXButton"/>
				<input type="button" value="<spring:message code="Cache.lbl_Reject"/>" onclick="Reject();" class="AXButton"/>
			</label>
		</div>
		<div id="topitembar02"  class="topbar_grid">
			<label>
				<spring:message code="Cache.lbl_Section"/>&nbsp;<!-- 영역 -->
				<select id="selSection" class="AXSelect" onchange="searchMsgList();"></select>
			</label>
			<label>
				<spring:message code="Cache.lbl_type"/>&nbsp;<!-- 유형 -->
				<select id="selType" class="AXSelect" onchange="searchMsgList();"></select>
			</label>
			<label>
				<spring:message code="Cache.lbl_SearchCondition"/>&nbsp;<!-- 검색조건 -->
				<select id="selSearchCondition" class="AXSelect" ></select>
				<input type="text" id="SearchText" style="width:120px" class="AXInput" onkeypress="if (event.keyCode==13) { searchMsgList(); return false; }"/>
				<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchMsgList();" class="AXButton"/>
			</label>
		</div>
		<div id="msgGrid"></div>
	</div>
</form>
<script type="text/javascript">

	var myGrid;
	var headerData;
	var sRejectOpinion = "";
	
	//개별호출 일괄처리
	var sessionObj = Common.getSession();
	Common.getBaseCodeList(["TodoMsgType", "TodoCategory"]);
	
	window.onload = initContent();
	
	function initContent(){
		
		myGrid = new coviGrid();
		
		headerData = [{key:'chk', label:'chk', width:'20', align:'center', formatter: 'checkbox'},
		              {key:'MessagingID', label:'ID', width:'20', align:'center'},
	                  {key:'ServiceType',  label:'<spring:message code="Cache.lbl_Section"/>', width:'50', align:'center', formatter : function(){
						  return Common.getDic('TodoCategory_' + this.item.ServiceType);
					  }}, /* 영역 */
	                  {key:'MsgType',  label:'<spring:message code="Cache.lbl_MessageType"/>', width:'50', align:'center', formatter : function(){
						  return Common.getDic('TodoMsgType_' + this.item.MsgType);
					  }}, /* 메세지 유형 */
	                  {key:'MessagingSubject', label:'<spring:message code="Cache.lbl_Title"/>', width:'70', align:'center', formatter : function(){
						  return "<a href='#' onclick='ViewMessagingApvPopUp(\""+ this.item.MessagingID +"\"); return false;'>"+this.item.MessagingSubject+"</a>";
					  }}, /* 제목 */
					  {key:'ReceiverText', label:'<spring:message code="Cache.lbl_Contents"/>', width:'80', align:'center'}, /* 내용 */
					  {key:'MediaType', label:'<spring:message code="Cache.lbl_NoOfShipping"/>', width:'80', align:'center', formatter : function(){
						  var sReturn = "";
						  var oMType =  (this.item.MediaType).split('@');
						  for(var i = 0; i<oMType.length; i++){
							  sReturn += Common.getDic("NotificationMedia_" + oMType[i].split(';')[0]) + "(" + oMType[i].split(';')[1] + ")\t";
						  }
						  return sReturn;
					  }}, /* 발송건수 */
	                  {key:'SenderCode', label:'<spring:message code="Cache.lbl_Requester"/>', width:'50', align:'center'}, /* 요청자 */
	                  {key:'RegistDate', label:'<spring:message code="Cache.lbl_ApproveDate"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'70', align:'center', 
	                	formatter: function(){
	                		return CFN_TransLocalTime(this.item.RegistDate, "yyyy-MM-dd hh:mm");
	                	}
	                  } /* 요청일시 */
	                  ];
				
		setGrid();
		
		//select box 바인딩
		setSelSection();
		setSelType();
		setSelSearchCondition();
		
		setTimeout(function(){searchMsgList();}, 10);
	};

	function setGrid(){
		myGrid.setGridHeader(headerData);
		setGridConfig();
	}
	
	function setGridConfig(){
		var configObj = {
			targetID : "msgGrid",
			height: "auto", //"490px",
			page : {
				pageNo:1,
				pageSize:10
			},
			paging : true
		};
		
		myGrid.setGridConfig(configObj);
	}
	
	function searchMsgList(){		
		var serviceType = $("#selSection").val();
		var msgType = $("#selType").val();
		var searchColumn = $("#selSearchCondition").val();
		var text = $("#SearchText").val();
		
		myGrid.page.pageNo = 1;
		
		myGrid.bindGrid({
 			ajaxUrl:"/covicore/admin/messaging/getmessagingapprovallist.do",
 			ajaxPars: {
 				"MessagingID": '',
 				"ServiceType": serviceType,
 				"MsgType": msgType,
 				"SearchColumn": searchColumn,
 				"SearchText": text,
 				"sortBy": myGrid.getSortParam()
 			},
 			onLoad:function(){
 				//custom 페이징 추가
 				$('.AXgridPageBody').append('<div id="custom_navi" style="text-align:center;margin-top:2px;"></div>');
			    myGrid.fnMakeNavi("myGrid");
			    setSelType(); //유형 select 박스 바인딩
 			}
		});
	}
	
	function Refresh(){
		location.reload();
	}
	
	function Approve(){
		var approveObject = myGrid.getCheckedList(0);
		if(approveObject.length == 0 || approveObject == null){
			Common.Inform("<spring:message code='Cache.msg_approveLastSeqNotFound'/>"); //승인할 항목을 선택하여 주십시오.
		}else{
			Common.Confirm("<spring:message code='Cache.msg_RUApprove'/>", "Confirmation Dialog", function (result) {/* 승인하시겠습니까? */
				if(result) {
					var approveSeq = "";
					for(var i=0; i < approveObject.length; i++){
						if(i==0){
							approveSeq = approveObject[i].MessagingID;
						}else{
							approveSeq = approveSeq + ";" + approveObject[i].MessagingID;
						}
					}
					
					$.ajax({
						type:"POST",
						data:{
							"MessagingID" : approveSeq,
							"ApprovalState": "A",
							"MessagingState": "2",
						},
						url:"/covicore/admin/messaging/editmessagingdata.do",
						success:function (data) {
							if(data.status == "FAIL") {
								Common.Warning(data.message);
							} else {
								//알림 발송
								for(var i=0; i < approveObject.length; i++){
									noticeResult("Approve", approveObject[i].SenderCode);
								}
								Common.Inform("<spring:message code='Cache.msg_ProcessOk'/>", "Information Dialog");
							}
						},
						error:function(response, status, error){
							CFN_ErrorAjax("/covicore/admin/messaging/editmessagingdata.do", response, status, error);
						}
					});
				}
			});
		}
	}
	
	function Reject(){
		var rejectObject = myGrid.getCheckedList(0);
		if(rejectObject.length == 0 || rejectObject == null){
			Common.Inform("<spring:message code='Cache.msg_rejectLastSeqNotFound'/>"); //거절할 항목을 선택하여 주십시오.
		}else{
			Common.Confirm("<spring:message code='Cache.msg_RUReject'/>", "Confirmation Dialog", function (result) {/* 거부하시겠습니까? */
				if(result) {
					//의견 받기
					Common.PromptArea("<spring:message code='Cache.msg_161'/>", "", "<spring:message code='Cache.lbl_Confirm'/>", function (result2) { 
                        if (result2 != null) {
                        	sRejectOpinion = result2;
                        	
                        	var rejectSeq = "";
        					for(var i=0; i < rejectObject.length; i++){
        						if(i==0){
        							rejectSeq = rejectObject[i].MessagingID;
        						}else{
        							rejectSeq = rejectSeq + ";" + rejectObject[i].MessagingID;
        						}
        					}
        					
        					$.ajax({
        						type:"POST",
        						data:{
        							"MessagingID" : rejectSeq,
        							"ApprovalState" : "C", // 플래그 값을 발송취소로 : ApprovalState를 C(ancel)로 바꿔줘야 함
        							"MessagingState" : 4 // 플래그 값을 취소로 바꿔줌
        						},
        						url:"/covicore/admin/messaging/editmessagingdata.do",
        						success:function (data) {
        							if(data.status == "FAIL") {
        								Common.Warning(data.message);
        							} else {
        								//알림 발송
        								for(var i=0; i < rejectObject.length; i++){
        									noticeResult("Reject", rejectObject[i].SenderCode);
        								}
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
		}//else
	}
	
	function noticeResult(mode, receiverCode){
		Common.Inform(mode + "-" + receiverCode);
		
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
							window.location.reload();
						}
					});
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/admin/messaging/setmessagingdata.do", response, status, error);
			}
		});
	}	
	
	function setSelSection(){
		$('#selSection').append($('<option>', {
		        value: '',
		        text : "<spring:message code='Cache.lbl_all'/>" 
		 }));
		var objTodomsgType = coviCmn.codeMap['TodoCategory'];
		$(objTodomsgType).each(function(idx, obj) {
			if (obj.Code == 'TodoCategory')
				return true;
			$('#selSection').append($('<option>', { 
			        value: obj.Code,
			        text : obj.CodeName
			 }));
		});
	}
	
	function setSelType(){
		$('#selType').find('option').remove();
		$('#selType').append($('<option>', {
		        value: '',
		        text : "<spring:message code='Cache.lbl_all'/>"
		 }));
		var objTodomsgType = coviCmn.codeMap['TodoMsgType'];
		$(objTodomsgType).each(function(idx, obj) {
			if (obj.Code == 'TodoMsgType')
				return true;
			if($('#selSection').val() != '' && obj.BizSection != $('#selSection').val()) //bizsection이 일치하지 않으면
				return true;
			$('#selType').append($('<option>', { 
			        value: obj.Code,
			        text : obj.CodeName
			 }));
		});
	}
		
	function setSelSearchCondition(){
		$("#selSearchCondition").bindSelect({
            reserveKeys: {
                optionValue: "value",
                optionText: "name"
            },
            options : [{"name":"<spring:message code='Cache.lbl_Title'/>", "value":"Title"},
                       {"name":"<spring:message code='Cache.lbl_Contents'/>", "value":"Contents"},
                       {"name":"<spring:message code='Cache.lbl_Requester'/>", "value":"Requester"}]
        });
	}
	
	function ViewMessagingApvPopUp(pMsgID){
		var sOpenName = "divMessagingApv";

		var sURL = "/covicore/admin/messaging/messagingapprovalpopup.do";
		sURL += "?msgID=" + pMsgID;
		sURL += "&OpenName=" + sOpenName;
		
		var sTitle = "";
		sTitle = "<spring:message code='Cache.CN_719'/>" ;

		var sWidth = "680px";
		var sHeight = "340px";
		Common.open("", sOpenName, sTitle, sURL, sWidth, sHeight, "iframe", false, null, null, true);
	}
</script>
