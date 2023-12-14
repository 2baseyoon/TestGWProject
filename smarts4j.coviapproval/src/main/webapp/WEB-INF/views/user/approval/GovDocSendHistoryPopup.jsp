<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp" />

<div class="layer_divpop ui-draggable docPopLayer w100" id="testpopup_p" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents" id="baseCodeViewSearchArea">	
		<div class="popContent" style="position:relative;">
			<c:if test="${govDocs eq 'sendWait'}">
				<div class="boradTopCont apprvalTopCont">
					<div class="pagingType02 buttonStyleBoxLeft">
						<div class="selBox" style="width:100%; max-width:350px;" id="selectSearch">
							<span class="selTit">
								<a value="all" class="up"><spring:message code='Cache.lbl_all' /></a>
							</span>						
							<div class="selList" style="width:100%;display: none;">
									<a class="listTxt"><spring:message code='Cache.lbl_all' /></a>
								<c:forEach items="${receiveList}" var="list">
									<a class="listTxt" value="${list.SEND_ID}" >${list.ORG_NM}</a>
								</c:forEach>
							</div>
						</div>
					</div>			
				</div>
			</c:if>
			<div class="apprvalBottomCont">
				<div class="searchBox" style='display: none' id="groupLiestDiv">
					<div class="searchInner">
						<ul class="usaBox" id='groupLiestArea' ></ul>
					</div>
				</div>
				<div class="appRelBox">
					<div class="contbox"> <!-- 상단 영역 확장시 값 변경 (기본 125px;) -->
						<div class="conin_list" style="width:100%; height: 300px">
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
			exceptionView 		: 	function(){  return  this.item.ERROR_YN === 'Y' ? $("<a>", { "id" : "exceptionView", "text" : "보기" }).get(0).outerHTML : ""; }
			,sendNm	:	function(){				
				var label
				this.item.STATUS === "send" 		&& ( label = "<spring:message code='Cache.lbl_send'/>" );	//발송
				this.item.STATUS === "arrive" 		&& ( label = "<spring:message code='Cache.lbl_arrival'/>" );	//도달
				this.item.STATUS === "receive" 		&& ( label = "<spring:message code='Cache.lbl_apv_receive'/>" );	//수신
				this.item.STATUS === "accept" 		&& ( label = "<spring:message code='Cache.lbl_apv_receipt'/>" );	//접수
				this.item.STATUS === "req-resend" 	&& ( label = "<spring:message code='Cache.lbl_apv_govdocs_resend'/> <spring:message code='Cache.lbl_Request'/>"  );	//재발송 요청
				this.item.STATUS === "resend" 		&& ( label = "<spring:message code='Cache.lbl_apv_govdocs_resend'/>" );	//재발송
				this.item.STATUS === "fail" 		&& ( label = "<spring:message code='Cache.lbl_Fail'/>" );	//발송실패
				return label;
			}
			,sendAction	:	function(){ 
				var label
				//this.item.RESEND_FLAG=== "Y"
				( label = $("<a>",{ "class" : "btnTypeDefault", "text" : "<spring:message code='Cache.lbl_apv_govdocs_resend' />", "id" : "reSendBtn" }).get(0).outerHTML  );
				return label;
			}
			,popupLog	:	function(){ 
				var label = $("<a>",{ "class" : "btnTypeDefault", "text" : "<spring:message code='Cache.lbl_apv_history_send' />", "id" : "sendStatusVw" }).get(0).outerHTML  ;
				return label;
			}
			,stringDateToString : 	function(attr){
				return function(){
					return this.item[attr].replace(/[-\s:]/gi,'').replace(/([0-9]{4})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})/,'$1.$2.$3 $4:$5')
				}
			}
		};		
		var header  = [
					{key:'ORG_NM'				,label:'<spring:message code="Cache.lbl_apv_RecvDept" />'			,width:'5'		,align:'left'}	//수신처
					,{key:'FIRST_SEND_DT'		,label:'<spring:message code="Cache.lbl_SendDateTime" />'			,width:'5'		,align:'center',formatter: template.stringDateToString('FIRST_SEND_DT')}	//발송일시
					,{key:'RESEND_REQ_CNT'		,label:'<spring:message code="Cache.lbl_RequestCnt" />'				,width:'3'		,align:'center'}		//요청수
					,{key:'RESEND_PROC_CNT'		,label:'<spring:message code="Cache.lbl_ProcessCnt" />'				,width:'3'		,align:'center'}		//처리수
					,{key:'STATUS'				,label:'<spring:message code="Cache.lbl_LastState" />'				,width:'5'		,align:'center',formatter: template.sendNm}	//최종상태
					,{key:'LAST_SEND_DT'		,label:'<spring:message code="Cache.lbl_LastProcDate" />'			,width:'5'		,align:'center',formatter: template.stringDateToString('LAST_SEND_DT')}	//최종처리일시
					,{key:''					,label:'<spring:message code="Cache.lbl_apv_govdocs_resend" />'		,width:'4'		,align:'center',formatter: template.sendAction}	//재발송 
					,{key:''					,label:'<spring:message code="Cache.lbl_apv_history_send" />'		,width:'4'		,align:'center',formatter:template.popupLog}	//이력
				];
		 
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
							,uniqueID       :   uId
						}

						Common.Confirm("<spring:message code='Cache.msg_DoyouResend' />", "Confirmation Dialog", function (result) {	//재발송 하시겠습니까?
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
					case "sendStatusVw":
						parent.Common.open("", "History", "<spring:message code='Cache.lbl_apv_history_send' />" ,"/approval/user/GovDocHistoryPopup.do?uniqueId="+this.item.UNIQUE_ID+"&govDocs=sendWait&sendID="+this.item.SEND_ID, '950px', '400px', "iframe", true, null, null, true);	
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
					ListGrid.listData.ajaxPars.sendID = $(".up",this).attr('value');
					ListGrid.reloadList();
					setAXGridBodyHeight();
				}	
			}
		}(pageAttr);
		
		this.pageInit = function(){						
			/* 상세 */
			$("#selectSearch").on('click',function(){
				var target		= event.target;				 				
				target.className === 'listTxt' && $(".up",this).text( target.innerText ).attr('value', target.getAttribute( 'value' ) ) && doSearch.call(this);			
				$(".selList",this).toggle();
			});			
		}
		
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
			        onclick  : gridFunctions
			    },
			    colHead:{
			    	rows:[
			    		[{colSeq:0,rowspan:2}
			    			, {colSeq:1,rowspan:2}
			    			, {colSeq:null,colspan:2, label:"<spring:message code='Cache.lbl_apv_govdocs_resend' />"}
			    			, {colSeq:4, rowspan:2}
			    			, {colSeq:5, rowspan:2}
			    			, {colSeq:6, rowspan:2}
			    			, {colSeq:7, rowspan:2}
			    		],
			    		[{colSeq:2},{colSeq:3}]
			    	]
			    }
			});
			ListGrid.page.pageSize = 5;
			ListGrid.page.pageNo = 1;
			ListGrid.bindGrid({ ajaxUrl : "/approval/user/selectSendHistoryData.do",ajaxPars: { docId : parmDocId, govDocs : pageAttr, uniqueId : uId } });
			setAXGridBodyHeight();
		}
	}

	// 헤더가 2라인인 경우 css 때문에 paging 부분 겹쳐지는 현상 제거
	let g_SetAXGridBodyHeightIntervalCnt = 0;
	let g_SetAXGridBodyHeightInterval = null;
	function setAXGridBodyHeight() {
		if (g_SetAXGridBodyHeightInterval != null) {
			g_SetAXGridBodyHeightIntervalCnt = 0;
			clearInterval(g_SetAXGridBodyHeightInterval);
		}
		
		g_SetAXGridBodyHeightInterval = setInterval(function() {
			console.log(g_SetAXGridBodyHeightIntervalCnt);
			if ($("#approvalListGrid").find("tbody[id*='_tbody'] > tr.noListTr").length == 0) {
				g_SetAXGridBodyHeightIntervalCnt = 0;
				clearInterval(g_SetAXGridBodyHeightInterval);
				
				$("#approvalListGrid").find("div.AXGridBody").css('height', '');
				$("#approvalListGrid").find("div.AXGridBody").attr('style', function(i,s) { return (s || '') + 'height: calc(100% - 82px) !important;' });
			} else if (g_SetAXGridBodyHeightIntervalCnt++ >= 10) {
				g_SetAXGridBodyHeightIntervalCnt = 0;
				clearInterval(g_SetAXGridBodyHeightInterval);
			}
		}, 500);
	}
	
	var init = new inital();	
	init.pageInit();
	init.gridInit();
</script>
