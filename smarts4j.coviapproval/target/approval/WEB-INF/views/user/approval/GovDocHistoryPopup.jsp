<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp" />

<div class="layer_divpop ui-draggable docPopLayer w100" id="testpopup_p" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents" id="baseCodeViewSearchArea">	
		<div class="popContent" style="position:relative;">
			<div class="apprvalBottomCont">
				<div class="searchBox" style='display: none' id="groupLiestDiv">
					<div class="searchInner">
						<ul class="usaBox" id='groupLiestArea' ></ul>
					</div>
				</div>
				<div class="appRelBox">
					<div class="contbox"> <!-- 상단 영역 확장시 값 변경 (기본 125px;) -->
						<c:if test="${callType eq 'receive'}">
						<div class="sadmin_pop">
							<div id="searchTab_Basic" class="tabContent active">
								<table class="sadmin_table sa_menuBasicSetting">
									<colgroup>
										<col width="130px;">
										<col width="*">
										<col width="130px;">
										<col width="*">
									</colgroup>
									<tbody>
										<tr>
											<td colspan="4">
												<span><b><spring:message code='Cache.lbl_apv_govdoc_sendInfo'/></b></span><!-- 발송정보 -->
											</td>
										</tr>
										<tr>
											<th><spring:message code='Cache.lbl_apv_govdoc_receive_sendDate'/></th> <!-- 수신처발송일 -->
											<td>
												<span  id="insertedDate" name="insertedDate"></span>
											</td>
											<th><spring:message code='Cache.lbl_apv_govdoc_acceptDate'/></th> <!-- 공문접수일 -->
											<td>
												<span  id="acceptDate" name="acceptDate"></span>
											</td>
										</tr>
										<tr>
											<th><spring:message code='Cache.lbl_apv_govdoc_acceptorName'/></th> <!-- 접수자 -->
											<td>
												<span  id="acceptorName" name="acceptorName"></span>
											</td>
											<th><spring:message code='Cache.lbl_apv_govdoc_receiveNo'/></th> <!-- 공문접수번호 -->
											<td>
												<span  id="acceptID" name="acceptID"></span>
											</td>
										</tr>
										<tr>
											<th><spring:message code='Cache.lbl_apv_govdoc_sendTo'/></th> <!-- 발송처 -->
											<td>
												<span  id="displaySendName" name="displaySendName"></span>
											</td>
											<th><spring:message code='Cache.lbl_apv_govdoc_docNum'/></th> <!-- 발송처문서번호 -->
											<td>
												<span  id="sendID" name="sendID"></span>
											</td>
										</tr>
										<tr>
											<th><spring:message code='Cache.lbl_apv_govdoc_receiptDate'/></th> <!-- 공문수신일 -->
											<td>
												<span  id="insertedDate2" name="insertedDate"></span>
											</td>
											<th><spring:message code='Cache.lbl_apv_govdoc_publication'/></th> <!-- 공개여부 -->
											<td>
												<span  id="publication" name="menuID"></span>
											</td>
										</tr>
										<tr>
											<th><spring:message code='Cache.lbl_apv_govdoc_title'/></th> <!-- 제목 -->
											<td colspan="3">
												<span  id="processSubject" name="processSubject"></span>
											</td>
										</tr>
									</tbody>
								</table>
							</div>
						</div>
						</c:if>
						<div class="conin_list" style="width:100%; height:300px;">
							<div id="approvalListGrid"></div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>	
</div>

<script>


	var inital = function(){ 
		var ListGrid = new coviGrid();
		var pageAttr 	= 	"${govDocs}".length > 0 ? "${govDocs}" : "sendComplete";
		var parmDocId 	= 	"${docId}";
		var uId			=	"${uniqueId}";
		var template = {
			exceptionView 		: 	function(){  return  this.item.LOG_YN === 'Y' ? $("<a>", { "id" : "exceptionView", "text" : "보기" }).get(0).outerHTML : ""; }
			,sendNm	:	function(){
				var label;
				this.item.STATUS === "send" 		&& ( label = "<spring:message code='Cache.lbl_send'/>" );	//발송
				this.item.STATUS === "arrive" 		&& ( label = "<spring:message code='Cache.lbl_arrival'/>" );	//도달
				this.item.STATUS === "receive" 		&& ( label = "<spring:message code='Cache.lbl_apv_receive'/>" );	//수신
				this.item.STATUS === "accept" 		&& ( label = "<spring:message code='Cache.lbl_apv_receipt'/>" );	//접수
				this.item.STATUS === "req-resend" 	&& ( label = "<spring:message code='Cache.lbl_apv_govdocs_resend'/> <spring:message code='Cache.lbl_Request'/>"  );	//재발송 요청
				this.item.STATUS === "resend" 		&& ( label = "<spring:message code='Cache.lbl_apv_govdocs_resend'/>" );	//재발송
				this.item.STATUS === "fail" 		&& ( label = "<spring:message code='Cache.lbl_Fail'/>" );	//발송실패
				this.item.STATUS === "return" 		&& ( label = "<spring:message code='Cache.lbl_RejectOut'/>" );	//반송
				return label;
			}
		};		
		var header  = ({			
				sendComplete : [				 	 
					{key:'SEQ'  			,label:'No.'		,width:'70'		,align:'center'}
					,{key:''  				,label:'<spring:message code="Cache.lbl_apv_RecvDept" />'		,width:'70'		,align:'center'}	//수신처
					,{key:''  				,label:'<spring:message code="Cache.lbl_apv_charge_person" />'	,width:'70'		,align:'center'}	//담당자
					,{key:'STATUS_NAME'  	,label:'<spring:message code="Cache.lbl_att_sch_sts" />'		,width:'70'		,align:'center'}	//상태
					,{key:'RECEIVE_DATE'  	,label:'<spring:message code="Cache.lbl_ReceiveDate" />'		,width:'70'		,align:'center'}	//수신일시
					,{key:'LIST_UNIT_NM'  	,label:'<spring:message code="Cache.lbl_att_reason" />'			,width:'70'		,align:'center'}	//사유
				]
				,receiveProcess : [
					{key:'ROW_NUM'  		,label:'No.'		,width:'70'		,align:'center'}
					,{key:'AUTHORITY_USER'  ,label:'<spring:message code="Cache.lbl_apv_history_mail_sender" />'		,width:'70'		,align:'center'}	//발송자
					,{key:'IN_USER'  		,label:'<spring:message code="Cache.lbl_apv_charge_person" />(<spring:message code="Cache.lbl_ReadCheck" />)'		,width:'70'		,align:'center'}	//담당자-읽음확인
					,{key:'STATUS_NM'  		,label:'<spring:message code="Cache.lbl_att_sch_sts" />'		,width:'70'		,align:'center'}	//상태
					,{key:'INSERTED'  		,label:'<spring:message code="Cache.lbl_RegistDate" />'			,width:'70'		,align:'center'}		//일시
				]
				,history : [
					{key:'PROCESS_DT' ,label:'<spring:message code="Cache.lbl_RegistDate" />'		,width:'5'		,align:'center',
						formatter:function () {
							  if(this.item.STATUS == "resend"){
								  return this.item.RESEND_DT;
							  }else{
								  return this.item.PROCESS_DT;
							  }
						  }
					}	//일시
					/* ,{key:'RECEIVE_USER'	,label:'<spring:message code="Cache.lbl_apv_history_mail_sender" />'				,width:'5'		,align:'center'}	//발송자
					,{key:'ORG_NM'			,label:'<spring:message code="Cache.lbl_apv_SendDept" />'				,width:'5'		,align:'center'}	//발송처		 */		
					,{key:'STATUS'			,label:'<spring:message code="Cache.lbl_att_sch_sts" />'	,width:'5'		,align:'center' ,formatter: template.sendNm }	//상태
					,{key:''				,label:'<spring:message code="Cache.lbl_govLoglist" />'				,width:'5'		,align:'center' ,formatter: template.exceptionView }//로그목록
				]		
				,sendWait : [
					{key:'PROCESS_DT' ,label:'<spring:message code="Cache.lbl_RegistDate" />'		,width:'5'		,align:'center',
						formatter:function () {
	                		  if(this.item.STATUS == "resend"){
	                			  if(this.item.RESEND_DT != null && this.item.RESEND_DT != undefined && this.item.RESEND_DT != ''){
		                			  return this.item.RESEND_DT;
	                			  }else{
	                				  return this.item.PROCESS_DT
	                			  }
	                		  }else{
	                			  return this.item.PROCESS_DT;
	                		  }
	                	  }
					}	//일시
					,{key:'SEND_USER'		,label:'<spring:message code="Cache.lbl_apv_history_mail_sender" />'		,align:'center'		,width:'5'		}	//발송자
					/* ,{key:'RECEIVE_USER'	,label:'수신자'				,width:'5'		,align:'center'} */
					,{key:'ORG_NM'			,label:'<spring:message code="Cache.lbl_apv_RecvDept" />'	,width:'5'		,align:'center'}	//수신처
					,{key:'STATUS'			,label:'<spring:message code="Cache.lbl_att_sch_sts" />'	,width:'5'		,align:'center' ,formatter: template.sendNm }	//상태
					,{key:''				,label:'<spring:message code="Cache.lbl_govLoglist" />'				,width:'5'		,align:'center' ,formatter: template.exceptionView }	//로그목록
				]
		})[pageAttr];		
		var gridFunctions = ({
			history : function(){
				var id = $( event.target ).attr('id');
				if( !id ) return;				
				switch( id ){
				case "exceptionView" :						
						parent.Common.open("", "ExceptionPopup", "<spring:message code='Cache.lbl_govLoglist' />" 
								,"/approval/user/GovDocExceptionPopup.do?historySeq="+this.item.HISTORY_SEQ, '950px', '650px', "iframe", true, null, null, true);	
						break;	
				}
			}
			,sendWait : function(){
				var id = $( event.target ).attr('id');
				if( !id ) return;		
				switch( id ){
					case "reSendBtn" :
						var param = {
							processId 		:	this.item.PROCESS_ID
							,formInstId 	: 	this.item.FORM_INST_ID	
							,type 			:	"resend"	
							,receiver 		:	this.item.SEND_ID
						}
						Common.Confirm("<spring:message code='Cache.msg_DoyouResend' />", "Confirmation Dialog", function (result) {
							if(result){								
								$.ajax({
									url: "/approval/govDocs/callPacker.do",
									type:"POST",
									data: param,				
									success:function (data) { 
										data.status === "OK" && Common.Inform("<spring:message code='Cache.msg_Mail_SentMail' />","",function(){ ListGrid.reloadList(); });
									},  
									error:function(response, status, error){ 
					                    Common.Inform("<spring:message code='Cache.msg_FailedToSend' />", 'Information', null);
					                    ListGrid.reloadList();
						            }
								});								
							}		
						});						
						break;
					case "exceptionView" :						
						parent.Common.open("", "ExceptionPopup", "<spring:message code='Cache.lbl_govLoglist' />" 
								,"/approval/user/GovDocExceptionPopup.do?historySeq="+this.item.HISTORY_SEQ, '950px', '650px', "iframe", true, null, null, true);	
						break;	
				}				
			}
		})[pageAttr];
		
		var doSearch = function(page){			
			if( page === 'sendWait' ){
				return function(){
					ListGrid.page.pageNo = 1;
					ListGrid.listData.ajaxPars.sendID = "${sendID}";
					ListGrid.reloadList();
				}	
			}
		}(pageAttr);
		
		this.gridInit = function(){	
			ListGrid.setGridHeader(header);			
			ListGrid.setGridConfig({
				targetID : "approvalListGrid",
				height:"auto",
				paging : true,
				//notFixedWidth : 4,
				sort        : false,
				overflowCell : [],
				body: {
			        onclick : gridFunctions
			    }
			});
			ListGrid.page.pageSize = 5;
			ListGrid.page.pageNo = 1;
			ListGrid.bindGrid({ ajaxUrl : "/approval/user/selectHistoryData.do",ajaxPars: { docId : parmDocId, govDocs : pageAttr, uniqueId : uId, sendID:"${sendID}" } });
		}	
		
		//발송정보 데이터 매핑
		this.tableInit = function(){
			if (CFN_GetQueryString('callType') == 'receive') {
				$.ajax({
				        type : "post",
				      	url : "/approval/user/selectHistorySendData.do", 
					    data: { uniqueId : uId },
						async:false,
						success : function(data) {    
							if (data.list.length > 0) {		
								document.getElementById("insertedDate").innerHTML = data.list[0].INSERTED == null ? "" : data.list[0].INSERTED; //수신처발송일
								document.getElementById("acceptDate").innerHTML = data.list[0].ACCEPTDATE == null ? "" : data.list[0].ACCEPTDATE; //공문접수일
								document.getElementById("acceptorName").innerHTML = data.list[0].ACCEPTORNAME == null ? "" : data.list[0].ACCEPTORNAME; //접수자
								document.getElementById("acceptID").innerHTML = data.list[0].ACCEPTNUMBER == null ? "" : data.list[0].ACCEPTNUMBER; //공문접수번호
								document.getElementById("displaySendName").innerHTML = data.list[0].DISPLAYSENDNAME == null ? "" : data.list[0].DISPLAYSENDNAME; //발송처
								document.getElementById("sendID").innerHTML = data.list[0].DOCNUMBER == null ? "" : data.list[0].DOCNUMBER; //발송처문서번호 
								document.getElementById("insertedDate2").innerHTML = data.list[0].INSERTED == null ? "" : data.list[0].INSERTED; //공문수신일
								document.getElementById("publication").innerHTML = data.list[0].PUBLICATION == null ? "" : data.list[0].PUBLICATION; //공개여부
								document.getElementById("processSubject").innerHTML = data.list[0].PROCESSSUBJECT == null ? "" : data.list[0].PROCESSSUBJECT; //제목
							}
						},
						error:function(response, status, error){
							CFN_ErrorAjax("/approval/user/selectHistorySendData.do", response, status, error);
						}
	
						        
				});
			}
		}
		
	}
	
	var init = new inital();	
	init.gridInit();
	init.tableInit();


</script>
