<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<style>
/*.title_calendar { display: inline-block; font-size: 24px; font-weight: 700; font-family: sans-serif, 'Nanum Gothic','맑은 고딕', 'Malgun Gothic'; vertical-align: middle; width:128px !important; padding:0; text-indent:0; border:0px !important; }
.AXanchorDateHandle { right: -118px !important; top: -0px !important; height:32px !important; border:1px solid #d6d6d6; min-width:40px; border-radius: 2px; }
.pagingType02 { margin-left:2px; }*/
</style>
<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code='Cache.CN_362'/></span>
</h3>
<div>
	<div id="topitembar01" class="topbar_grid">
		<span class=domain>
			<spring:message code="Cache.lbl_Domain"/>&nbsp;
			<select name="" class="AXSelect" id="selectDomain"></select>
		</span>
		<input class="AXInput" type="text" id="StartDate" date_separator="." readonly> <span class="adLine">~</span>  
		<input id="EndDate" date_separator="." date_startTargetID="StartDate" class="AXInput" type="text" readonly>
		<spring:message code="Cache.lbl_ProcessStatus"/>
		<select id="messagingState" class="AXSelect">
			<option value=""><spring:message code='Cache.lbl_Whole'/></option><!--  -->
			<option value="1"><spring:message code='Cache.lbl_Ready'/></option><!-- 전송대기 -->
			<option value="2"><spring:message code='Cache.lbl_result'/></option><!-- 결과대기 -->
			<option value="3"><spring:message code='Cache.lbl_apv_completed'/></option><!-- 완료-->
			<option value="4"><spring:message code='Cache.btn_Cancel'/></option><!-- 취소-->
			<option value="5">Error</option><!-- error -->
		</select>
		<spring:message code="Cache.lbl_SearchCondition"/>&nbsp;
		<select id="searchType" class="AXSelect">
			<option value="MsgTypeName"><spring:message code='Cache.lbl_MessageType'/></option><!-- 메세지 유형 -->
			<option value="Subject"><spring:message code='Cache.lbl_Title'/></option>	<!-- 제목 -->
		</select>
		<input type="text" id="searchInput"  class="AXInput" onkeypress="if (event.keyCode==13){ msgListObj.grid.searchData(); return false;}"/>&nbsp;
		<input type="button" onclick="msgListObj.grid.searchData();" class="AXButton" value="<spring:message code="Cache.btn_search"/>" />
	</div>
	<div id="topitembar01" class="topbar_grid">
		<input type="button" id="btnRefresh" value="<spring:message code="Cache.btn_Refresh"/>"  class="AXButton BtnRefresh"/>
		<input type="button" id="btnInit" class="AXButton BtnRefresh" value="<spring:message code="Cache.btn_init"/>" style="display:none;"/>
		<input type="button" id="btnResend" class="AXButton BtnRefresh" value="<spring:message code="Cache.btn_resend"/>" />
		<input type="button" id="btnDelete" class="AXButton BtnDelete" value="<spring:message code="Cache.btn_delete"/>" />
		<input type="button" id="btnSendMessage" class="AXButton BtnRefresh" value="메세지 즉시 발송" style="display:none;"/>
		<%
		if("true".equals(PropertiesUtil.getGlobalProperties().getProperty("messaging.realtime.use"))) {
		%>
		[
		<span id="ThreadMonitorSpan"><jsp:include page="/covicore/admin/messaging/goMessagingHealthInfo.do"></jsp:include></span>
		<input type="button" id="btnThreadRefresh" class="AXButton BtnRefresh" value="" />
		]
		<%
		}
		%>
	</div>	
	<div class="tblList tblCont">
		<div id="gridDiv">
		</div>
	</div>
</div>

<script>
function searchData(){
	
}
	var msgListObj = {
		pageStart: function () {
			var g_curDate = CFN_GetLocalCurrentDate("yyyy.MM.dd");

			var lang = Common.getSession("lang");
			coviCtrl.renderDomainAXSelect('selectDomain', lang, 'msgListObj.grid.searchData', '', '', true);
			$("#EndDate").bindTwinDate({
				startTargetID : "StartDate",
				separator : ".",
				onChange:function(){
					msgListObj.grid.searchData(1);
				},
				onBeforeShowDay : function(date){
					var fnStr = $("#"+this.config.targetID.split("_")[2]).attr("onBeforeShowDay");
					if(fnStr != null && fnStr != ""){
						return coviCmn.callFnBasedNamespace(fnStr, [date]);
					}
				}
			})
		
					//오늘 클릭시
			$(".calendartoday").click(function(){
				$("#StartDate").val(g_curDate);
				$("#EndDate").val(g_curDate);
				msgListObj.grid.searchData(1);		
				
			});

			if ($("#StartDate").val()==""){
				var gDate =  $("#StartDate").val();
				$("#StartDate").val(g_curDate);
				$("#EndDate").val(g_curDate);
				$("#dateTitle").text($("#StartDate").val() + "~" + $("#EndDate").val());
			}

			$(".cal").bind("click", function(){
				//$("#inputBasic_AX_EndDate_AX_expandBox").show();
				$(".AXanchorDateHandle").trigger("click");
			});
			
			$(document).off('click','#msgSubject').on('click','#msgSubject',function(){
				msgListObj.event.openSubMessaging();
		    });
			
			//처리상태변경시
			$("#messagingState").change(function(){
				msgListObj.grid.searchData(1);
			});
			
			//초기화
			$("#btnInit").click(function(){
				msgListObj.event.initMessage();
			});
			//재발송
			$("#btnResend").click(function(){
				msgListObj.event.resendMessage();
			});
			//삭제
			$("#btnDelete").click(function(){
				msgListObj.event.deleteMessage();
			});
			//발송 테스트
			$("#btnSendMessage").click(function(){
				msgListObj.event.sendMessage();
			});
			
			//검색
			$("#btnRefresh").click(function(){
				msgListObj.grid.searchData(1);		
			});
			
			//Thread 정보 새로고침
			<%
			if("true".equals(PropertiesUtil.getGlobalProperties().getProperty("messaging.realtime.use"))) {
			%>
			$("#btnThreadRefresh").click(function(){
				msgListObj.event.refreshThreadInfo();
			});
			$("#btnThreadRefresh").click();
			<%
			}
			%>
			msgListObj.util.searchType();
		},	
		util:{
			mediaType : '',
			searchType:function(){
				$.ajax({
					type:"POST",
					data:{"codeGroups" : "NotificationMedia"},
					url:"/covicore/basecode/get.do",
					success:function (data) {
						if(data.result == "ok"){
							msgListObj.util.mediaType=data.list[0]["NotificationMedia"];
							msgListObj.grid.bind();
						}
					},
					error:function (error){
						Common.Error(error.message);
					}
				});
			},
			inArray:function(findStr, arrayList, col){
				for (var i=0; i < arrayList.length; i++){
					if (col != "")
						if (arrayList[i][col] == findStr)	return true;
					else
						if (arrayList[i] == findStr)	return true;
				}
				return false;
			},
			getMedia:function(data, filterType){
				var mediaList = data.MediaType.split(";");//사용가능한 매체
				return msgListObj.util.inArray(filterType, mediaList)?"√":"";
			},
			findMedia:function(filterType){
				return msgListObj.util.inArray(filterType, msgListObj.util.mediaType, "Code");
			}			
		},
		event:{
			openSubMessaging:function(){
				var obj = msgListObj.grid.myGrid;
				var gridData =obj.getSelectedItem()["item"];
				var sOpenName = "divSubMessaging";
	
				var sURL = "/covicore/admin/messaging/MessagingSubPopup.do";
				sURL += "?msgID=" + gridData.MessagingID;
				sURL += "&OpenName=" + sOpenName;
				
				var sTitle = "";
				sTitle = "<spring:message code='Cache.CN_362'/>" ;
	
				var sWidth = "1280px";
				var sHeight = "540px";
				Common.open("", sOpenName, sTitle, sURL, sWidth, sHeight, "iframe", false, null, null, true);
			}	
			,sendMessage:function() {
				$.ajax({
					type:"POST",
					data:{},
					url:"/covicore/admin/messaging/sendmessaging.do",
					success:function (data) {
						if(data.status == "FAIL") {
							Common.Warning(data.message);
						} else {
							//<response><result MediaType='MAIL'><OK><![CDATA[MAIL(2) OK:0, Fail:2]]></OK></result><result MediaType='MDM'><OK><![CDATA[MDM(1) OK:0, Fail:1]]></OK></result></response>
							Common.Inform("<spring:message code='Cache.msg_ProcessOk'/>["+data.message+"]");
							msgListObj.grid.searchData(1);		
							/* Common.Inform("<spring:message code='Cache.msg_ProcessOk'/>", "Information Dialog", function(result) {
								if(result) {
									window.location.reload();
								}
							}); */
						}
					},
					error:function(response, status, error){
						CFN_ErrorAjax("/covicore/admin/messaging/setmessagingdata.do", response, status, error);
					}
				});
			}	
			,initMessage:function(){
				var initObject = msgListObj.grid.myGrid.getCheckedList(0);
				if(initObject.length == 0 || initObject == null){
					Common.Inform("<spring:message code='Cache.msg_InitLastSeqNotFound'/>"); //초기화할 항목을 선택하여 주십시오.
					return false;
				}else{
					Common.Confirm("<spring:message code='Cache.msg_DoyouInit'/>", "Confirmation Dialog", function (result) {/* 초기화하시겠습니까? */
						if(result) {
							var initSeq = "";
							for(var i=0; i < initObject.length; i++){
								initSeq += (i>0?";":"") + initObject[i].MessagingID;
							}
							
							$.ajax({
								type:"POST",
								data:{"Mode" : 0,"MessagingID" : initSeq},
								url:"/covicore/admin/messaging/initmessagingdata.do",
								success:function (data) {
									if(data.status == "FAIL") {
										Common.Warning(data.message);
									} else {
										Common.Inform("<spring:message code='Cache.msg_ProcessOk'/>", "Information Dialog", function(result) {
											if(result) {
												msgListObj.grid.searchData(1);		
											}
										});
									}
								},
								error:function(response, status, error){
									CFN_ErrorAjax("/covicore/admin/messaging/initmessagingdata.do", response, status, error);
								}
							});
						}
					});
				}
			}
			,resendMessage:function(){
				var resendObject =  msgListObj.grid.myGrid.getCheckedList(0);
				if(resendObject.length == 0 || resendObject == null){
					Common.Inform("<spring:message code='Cache.msg_ResendLastSeqNotFound'/>"); //재발송할 항목을 선택하여 주십시오.
					return false;
				}else{
					Common.Confirm("<spring:message code='Cache.msg_DoyouResend'/>", "Confirmation Dialog", function (result) {/* 재발송하시겠습니까? */
						if(result) {
							var resendSeq = "";
							for(var i=0; i < resendObject.length; i++){
								resendSeq += (i>0?";":"") + resendObject[i].MessagingID;
							}
							
							$.ajax({
								type:"POST",
								data:{"Mode" : 1,"MessagingID" : resendSeq},
								url:"/covicore/admin/messaging/initmessagingdata.do",
								success:function (data) {
									if(data.status == "FAIL") {
										Common.Warning(data.message);
									} else {
										Common.Inform("<spring:message code='Cache.msg_ProcessOk'/>", "Information Dialog", function(result) {
											if(result) {
												msgListObj.grid.searchData(1);		
											}
										});
									}
								},
								error:function(response, status, error){
									CFN_ErrorAjax("/covicore/admin/messaging/initmessagingdata.do", response, status, error);
								}
							});
						}
					});
				}
			}
			,deleteMessage:function(){
				var deleteObject = msgListObj.grid.myGrid.getCheckedList(0);
				if(deleteObject.length == 0 || deleteObject == null){
					Common.Inform("<spring:message code='Cache.msg_selectTargetDelete'/>"); //삭제할 대상을 선택하세요.
					return false;
				}else{
					Common.Confirm("<spring:message code='Cache.msg_152'/>", "Confirmation Dialog", function (result) {
						if(result) {
							var deleteSeq = "";
							for(var i=0; i < deleteObject.length; i++){
								deleteSeq  += (i>0?";":"") +  deleteObject[i].MessagingID;
							}
							
							$.ajax({
								type:"POST",
								data:{"MessagingID" : deleteSeq,"SubID" : 0	},
								url:"/covicore/admin/messaging/deletemessagingdata.do",
								success:function (data) {
									if(data.status == "FAIL") {
										Common.Warning(data.message);
									} else {
										Common.Inform("<spring:message code='Cache.msg_ProcessOk'/>", "Information Dialog", function(result) {
											if(result) {
												msgListObj.grid.searchData(1);		
											}
										});
									}
								},
								error:function(response, status, error){
									CFN_ErrorAjax("/covicore/admin/messaging/deletemessagingdata.do", response, status, error);
								}
							});
						}
					});
				}
			}
			,refreshThreadInfo : function (){
				var url = "/covicore/admin/messaging/goMessagingHealthInfo.do";
				$.get(url, function(data){
					$("#ThreadMonitorSpan").html(data);
				});
			}
		},
		grid:{
			myGrid:new coviGrid(),
			bind: function () {
				msgListObj.grid.myGrid.setGridConfig({
						targetID: "gridDiv",
						height:"auto",			
						page : {pageNo: 1,pageSize: 10},
						colGroup: [
							 {key:'chk', label:'chk', width:'20', align:'center', formatter: 'checkbox'},      
				             {key:'MsgTypeName',  label:'<spring:message code="Cache.lbl_MessageType"/>', width:'100', align:'left'},
				             {key:'MessagingSubject',  label:'<spring:message code="Cache.lbl_subject"/>', width:'210', align:'left', formatter:function () {
				      				return "<a href='#' id=msgSubject>"+this.item.MessagingSubject+"</a>";}},
		            		 {key:'MessagingState',  label:'<spring:message code="Cache.lbl_ProcessStatus"/>', width:'100', align:'center',formatter:function(){
		            			 	switch(this.item.MessagingState){
			            			 	case "1":return "<spring:message code='Cache.lbl_Ready'/>";break;
			            			 	case "2":return "<spring:message code='Cache.lbl_result'/>";break;
			            			 	case "3":return "<spring:message code='Cache.lbl_apv_completed'/>";break;
			            			 	case "4":return "<spring:message code='Cache.btn_Cancel'/>";break;
			            			 	case "5":return "Error";break;
		            			 	}
		            		 	}
				             },
		            		 {key:'SenderName',  label:'<spring:message code="Cache.lbl_apv_history_mail_sender"/>', width:'100', align:'left'},
		            		 {key:'ReservedDate',  label:'<spring:message code="Cache.lbl_SendDateTime"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'120', align:'left',
		            			 formatter:function(){
		            				 return CFN_TransLocalTime(this.item.ReservedDate);
		            			 }
		            		 },
		            		 {key:'',  label:'MAIL ', width:'50', align:'center',  display:msgListObj.util.findMedia('MAIL'), sort:false, formatter:function () {
				      				return msgListObj.util.getMedia(this.item, "MAIL")}
		            		 },	
		            		 {key:'',  label:'TODO ', width:'50', align:'center',  display:msgListObj.util.findMedia('TODOLIST'), sort:false, formatter:function () {
				      				return msgListObj.util.getMedia(this.item, "TODOLIST")}
		            		 },	
		            		 {key:'',  label:'PUSH ', width:'50', align:'center',  display:msgListObj.util.findMedia('MDM'), sort:false, formatter:function () {
				      				return msgListObj.util.getMedia(this.item, "MDM")}
		            		 },	
		            		 {key:'',  label:'EUM', width:'50', align:'center',  display:msgListObj.util.findMedia('MESSENGER'), sort:false, formatter:function () {
				      				return msgListObj.util.getMedia(this.item, "MESSENGER")}
		            		 },	
		            		 {key:'TargetCnt',  label:'<spring:message code="Cache.lbl_TargetPerson"/>', sort:false, width:'70', align:'center'},
		            		 {key:'SubTotalCount',  label:'<spring:message code="Cache.lbl_apv_cases"/>', sort:false, width:'70', align:'center'},
		            		 {key:'SendCount',  label:'<spring:message code="Cache.lbl_Success"/>', sort:false, width:'70', align:'center'},
		            		 {key:'FailCnt',  label:'<spring:message code="Cache.lbl_Fail"/>', sort:false, width:'70', align:'center'},
		            		 {key:'ThreadType',  label:'<spring:message code="Cache.lbl_Msg_ThreadType"/>', sort:false, width:'90', align:'center', formatter:function(){
		            			 	switch(this.item.ThreadType){
		            			 	case "RT":return '<spring:message code="Cache.lbl_Msg_Realtime"/>'; break;
		            			 	default : return '<spring:message code="Cache.lbl_Msg_Scheduler"/>'; break;
	            			 	}
	            		 	}
			             }
						]
					}
				);
				msgListObj.grid.searchData();
			},
			searchData: function () {
				msgListObj.grid.myGrid.page.pageNo = 1;
				msgListObj.grid.myGrid.page.pageSize= 10;
				
				msgListObj.grid.myGrid.bindGrid({
					ajaxUrl:"/covicore/admin/messaging/selectMessagingList.do",
		 			ajaxPars: {"startDate":$("#StartDate").val(),"endDate":$("#EndDate").val()
		 					,"domainId":$("#selectDomain").val()
		 					,"messagingState":$("#messagingState").val()
		 					,"searchType":$("#searchType").val()
		 					,"searchInput":$("#searchInput").val()
		 					}
				});
				
				<%
				if("true".equals(PropertiesUtil.getGlobalProperties().getProperty("messaging.realtime.use"))) {
				%>
				setTimeout(function(){
					msgListObj.event.refreshThreadInfo();
				}, 0);
				<%
				}
				%>
			},
		}
	};
	
jQuery(document.body).ready(function () {
	msgListObj.pageStart();
});
</script>
