<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@page import="egovframework.coviframework.util.StringUtil"%>
<%@page import="egovframework.baseframework.util.SessionHelper"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<script type="text/javascript" src="/approval/resources/script/user/ApprovalListCommon.js"></script>
		
<div class="cRConTop titType">
	<h2 class="title" id="govDocsTit"></h2>
	<div class="searchBox02">
		<span>
			<input type="text" class="sm" id="searchInput">
			<button type="button" id="simpleSearchBtn" class="btnSearchType01"><spring:message code="Cache.btn_search"/></button>
		</span>
		<a id="detailSchBtn" class="btnDetails"><spring:message code="Cache.lbl_apv_detail"/></a><!-- 상세 -->
	</div>
</div>
<div class="cRContBottom mScrollVH ">
	<div class="inPerView type02 appSearch" id="DetailSearch">
		<div>
			<div class="selectCalView">
				<span><spring:message code="Cache.lbl_Contents"/></span><!-- 내용 -->
				<div class="selBox" style="width: 110px;" id="selectSearchType">
					<span class="selTit">
						<c:choose>
							<c:when test="${GovDocs eq 'senderMaster'}">
								<a value="displayName" class="up"><spring:message code="Cache.lbl_DisplayName" /><!--표시이름--></a></span>
								<div class="selList" style="width: 83px;display: none;">
									<a class="listTxt" value="displayName"><spring:message code="Cache.lbl_DisplayName" /><!--표시이름--></a>
									<a class="listTxt" value="comDeptName"><spring:message code="Cache.lbl_apv_companyDeptName" /><!--회사/부서명--></a>
									<a class="listTxt" value="ouName"><spring:message code="Cache.lbl_apv_orgName" /><!--기관명--></a>
									<a class="listTxt" value="name"><spring:message code="Cache.lbl_apv_wardenName" /><!--기관장명--></a>
								</div>
							</c:when>
							<c:otherwise>
								<a value="title" class="up"><spring:message code="Cache.lbl_subject"/><!--  제목--></a></span>
								<div class="selList" style="width:83px;display: none;">
									<a class="listTxt" value="title"><spring:message code="Cache.lbl_subject"/><!--제목--></a>
									<c:if test="${GovDocs eq 'sendWait'}"><a class="listTxt" value="writedept"><spring:message code="Cache.lbl_apv_writedept"/><!--기안부서--></a></c:if>
									<c:if test="${GovDocs eq 'receiveWait'}"><a class="listTxt" value="senddept"><spring:message code="Cache.lbl_apv_SendDept"/><!--발신처--></a></c:if>
									<c:if test="${fn:contains('sendWait,receiveWait,receiveProcess',GovDocs)}"><a class="listTxt" value="docnumber"><spring:message code="Cache.lbl_docNumber"/><!--문서번호--></a></c:if>		
								</div>
							</c:otherwise>
						</c:choose>
				</div>
				<input type="text" id="titleNm" style="width: 215px;">
			</div>
		</div>
		<div>
			<div class="selectCalView">
				<span><spring:message code="Cache.lbl_scope"/></span><!-- 기간 -->
				<div id="divCalendar" class="dateSel type02">
					<input class="adDate" type="text" id="DeputyFromDate" date_separator="-" readonly=""> - <input id="DeputyToDate" date_separator="-" kind="twindate" date_starttargetid="DeputyFromDate" class="adDate" type="text" readonly="" data-axbind="twinDate">
				</div>
			</div>
			<a id="detailSearchBtn" class="btnTypeDefault btnSearchBlue nonHover"><spring:message code="Cache.lbl_search"/><!--검색--></a>
		</div>
	</div>
	<div class="apprvalContent">
		<div class="boradTopCont apprvalTopCont" style="height:45px">
			<div class="pagingType02 buttonStyleBoxLeft">
				<div class="selBox" style="width: 130px;display: none;"" id="selectSearchUser" >
					<span class="selTit"></span>
					<div class="selList" style="width:130px; display: none;"></div>
				</div>
				<select id="govDocSecurity" class="selectType02 listCount" style="width: 130px; height: 33px; display:none">
				<option value=""><spring:message code="Cache.lbl_all"/></option> <!-- 전체 -->
				</select>
				<!-- KIC 수정 OFFLINE 버튼 제거 -->
<%-- 					<c:if test="${fn:contains('sendComplete,receiveProcess',GovDocs)}"> --%>
<!-- 						<a class="btnTypeDefault" id="btOffline" style="display: none;"> -->
<%-- 							<spring:message code='Cache.btn_govdocs_offline'/> <!-- offline문서 --> --%>
<!-- 						</a> -->
<%-- 					</c:if> --%>
				<a id="excelBtn" class="btnTypeDefault btnExcel" style="display:none"><spring:message code='Cache.btn_SaveToExcel' /></a><!--엑셀저장-->
				<a id="addBtn" class="btnTypeDefault" onclick="openAddPopup('I');" style="display:none"><spring:message code='Cache.btn_Add' /></a><!-- 추가 -->
				<a id="deleteBtn" class="btnTypeDefault" onclick="docFunc.deleteSenderMaster();" style="display:none"><spring:message code='Cache.btn_delete' /></a><!-- 삭제 -->
				<a id="receiveTEST" class="btnTypeDefault" style="display:none">수신받기</a>
			</div>
			<div class="buttonStyleBoxRight">
				<select id="govDocStatus" class="selectType02 listCount" style="width: 130px; height: 33px; display:none">
					<option value=""><spring:message code="Cache.lbl_all"/></option> <!-- 전체 -->
				</select>
				<select id="receiveStatus" class="selectType02 listCount" style="height: 33px; display:none">
					<option value=""><spring:message code="Cache.lbl_all"/></option> <!-- 전체 -->
					<c:choose>
						<c:when test="${fn:contains('history',GovDocs)}">
							<option value="send"><spring:message code="Cache.lbl_apv_receive"/></option> <!-- 수신 -->
							<option value='fail'><spring:message code="Cache.lbl_Fail"/></option><!--  수신실패 -->
						</c:when>
						<c:when test="${fn:contains('receiveProcess',GovDocs)}">
							<option value="distribute"><spring:message code="Cache.lbl_apv_govdoc_recv"/></option> <!-- 배부 -->
							<option value="return"><spring:message code="Cache.lbl_RejectOut"/></option> <!-- 반송 -->
						</c:when>
						<c:otherwise>
							<option value="send"><spring:message code="Cache.lbl_apv_receive"/></option> <!-- 수신 -->
							<option value="accept"><spring:message code="Cache.lbl_apv_receipt"/></option> <!-- 접수 -->
						</c:otherwise>
					</c:choose>
				</select>
				<select id="selectPageSize" class="selectType02 listCount">
					<option value="10">10</option>
					<option value="20">20</option>
					<option value="30">30</option>
				</select>
				<button class="btnRefresh" id="refresh"></button><!-- 새로고침 -->
			</div>
		</div>
		<!-- grid -->
		<div class="apprvalBottomCont">
			<div class="searchBox" style='display: none' id="groupLiestDiv">
				<div class="searchInner">
					<ul class="usaBox" id='groupLiestArea' ></ul>
				</div>
			</div>
			<div class="appRelBox">
				<div class="contbox"> <!-- 상단 영역 확장시 값 변경 (기본 125px;) -->
					<div class="conin_list" style="width:100%;">
						<div id="approvalListGrid"></div>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>

<script>
	var headerData;
	var govDocFunction = function(page){
		var ListGrid = new coviGrid();
		var pageAttr = page.length > 0 ? page : "sendComplete";
		var selectParams;
		
		var template = {
			subject 			:	function(){ return $("<a>", { "id" : "subject", "text" : this.value }).get(0).outerHTML }
			,historyVw 			: 	function(){ return $("<a>", { "id" : "historyVw", "text" : "보기" }).get(0).outerHTML }
			,initiatorName 		: 	function(){ return (this.item.INITIATORID ? setUserFlowerName(this.item.INITIATORID, CFN_GetDicInfo(this.value), 'AXGrid') : CFN_GetDicInfo(this.value)); }
			,initiatorUnitName	: 	function(){ return this.value; }
			,docVw 				: 	function(){ return $("<a>", { "id" : "docVw", "text" : this.value }).get(0).outerHTML }
			,stringDateToString : 	function(attr){
				return function(){
					return this.item[attr].replace(/[-\s:]/gi,'').replace(/([0-9]{4})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})/,'$1.$2.$3 $4:$5')
				}
			}
			,statusPointer 	:	function(){ return $("<a>", { "id" : "statusPointer", "text" : this.value }).get(0).outerHTML }
			,sendStatusVw	:	function(){ return $("<a>", { "id" : "sendStatusVw", "text" : this.value }).get(0).outerHTML }
			,receiveStatusVw	:	function(){
				var value = "<spring:message code='Cache.lbl_apv_receive'/>";	//수신
				this.item.DOCTYPE === "send" 	&&	(value = "<spring:message code='Cache.lbl_apv_receive'/>");			//수신	
				this.item.DOCTYPE === "accept" 	&&	(value = "<spring:message code='Cache.lbl_apv_receipt'/>");			//접수	
				this.item.STATUS  === "fail" 	&& 	(value = "<spring:message code='Cache.lbl_Fail'/>");				//실패	
				return $("<a>", { "id" : "receiveStatusVw", "text" : value }).get(0).outerHTML
			}
			,historyStatusVw	:	function(){
				var value = "<spring:message code='Cache.lbl_apv_receive'/>";	//수신
				this.item.STATUS === "send" 	&&	(value = "<spring:message code='Cache.lbl_apv_receive'/>");			//수신
				this.item.STATUS  === "fail" 	&& 	(value = "<spring:message code='Cache.lbl_Fail'/>");				//실패	
				return $("<a>", { "id" : "historyStatusVw", "text" : value }).get(0).outerHTML
			}
			,sendType	:	function(){
				var value = "<spring:message code='Cache._lbl_Corporation'/>";
				this.item.SENDTYPE === "3" 	&&	(value = "<spring:message code='Cache.lbl_apv_person'/>");
				return value;
			}
			,senderMasterType	:	function(){
				this.item.SENDER_TYPE === "C" 		&& 	(value = "<spring:message code='Cache.lbl_apv_ent' />");	//회사
				this.item.SENDER_TYPE === "D" 		&& 	(value = "<spring:message code='Cache.lbl_apv_dept' />");	//부서
				return $("<a>", { "id" : "receiveStatusVw", "text" : value }).get(0).outerHTML
			}
		};
		
		var title = ({
			sendWait 		: "<spring:message code='Cache.lbl_apv_govdoc_sendBox' />"
			,sendComplete 	: "<spring:message code='Cache.lbl_apv_govdoc_sendCmpl' />"
			,sendError 		: "<spring:message code='Cache.lbl_apv_govdoc_sendError' />"
			,receiveWait	: "<spring:message code='Cache.lbl_apv_govdoc_recvWait' />"
			,receiveComplete: "<spring:message code='Cache.lbl_apv_govdoc_recvCmpl' />"
			,receiveReturn	: "<spring:message code='Cache.lbl_apv_govdoc_recvRtn' />"
			,receiveProcess	: "<spring:message code='Cache.lbl_apv_govdoc_recvProc' />"
			,receiveReject	: "<spring:message code='Cache.lbl_apv_govdoc_recvRjct' />"
			,history		: "<spring:message code='Cache.lbl_apv_govdoc_history' />"
			,receiveGov24Wait: "<spring:message code='Cache.lbl_apv_govdoc_recvGov24Wait' />"
			,senderMaster    : "<spring:message code='Cache.lbl_apv_govdoc_senderMng' />"
		})[pageAttr];
		
		headerData = ({
			sendWait : [ //발송함
				{key:'RECEIVERNAME'  		,label:'<spring:message code="Cache.lbl_apv_RecvDept" />'			,width:'50'		,align:'left'}	//수신처
				,{key:'DOCNUMBER'  			,label:'<spring:message code="Cache.lbl_apv_setschema_tab06" />'	,width:'50'		,align:'left'}	//문서번호
				,{key:'PROCESSSUBJECT' 		,label:'<spring:message code="Cache.lbl_subject" />'				,width:'100'	,align:'left'	,formatter: template.subject }	//제목			
				,{key:'INITIATORNAME'		,label:'<spring:message code="Cache.lbl_writer" />'					,width:'50'		,align:'center'	,formatter: template.initiatorName}		//작성자
				,{key:'INITIATORUNITNAME'	,label:'<spring:message code="Cache.lbl_apv_writedept" />'			,width:'50'		,align:'center'	,formatter: template.initiatorUnitName}		//기안부서
				,{key:'LAST_SEND_DT'  		,label:'<spring:message code="Cache.lbl_apv_govdoc_sendDate" />'	,width:'50'		,align:'center'	,formatter: template.stringDateToString('LAST_SEND_DT') }	//발신일시
				,{key:'SENDDATE'  			,label:'<spring:message code="Cache.lbl_sch_CompleteDate" />'		,width:'50'		,align:'center'	,formatter: template.stringDateToString('SENDDATE') }	//완료일시
				,{key:'GOVDOC_STATUS'  		,label:'<spring:message code="Cache.lbl_apv_doc_status" />'			,width:'50'		,align:'center'	,formatter: template.sendStatusVw}	//문서상태
			]
			,receiveWait : [ //수신함
			 	{key:'SECURITYTEXT'  	,label:'<spring:message code="Cache.lbl_apv_Publication" />'		,width:'30'			,align:'center'}	//공개 여부
				,{key:'RECEIVERNAME'  		,label:'<spring:message code="Cache.lbl_apv_SendDept" />'			,width:'50'		,align:'left'}	//발신처
				,{key:'DOCNUMBER'  			,label:'<spring:message code="Cache.lbl_apv_setschema_tab06" />'	,width:'50'		,align:'left'}	//문서번호
				,{key:'PROCESSSUBJECT' 		,label:'<spring:message code="Cache.lbl_subject" />'				,width:'100'	,align:'left'	,formatter: template.subject }	//제목		
				,{key:'INITIATORNAME'		,label:'<spring:message code="Cache.lbl_apv_history_mail_sender" />',width:'50'		,align:'center'	,formatter: template.initiatorName}		//발송자		
				,{key:'INSERTED'  			,label:'<spring:message code="Cache.lbl_ReceiveDate" />'			,width:'50'		,align:'center'	,formatter: template.stringDateToString('INSERTED') }	//수신일시
				,{key:'GOVDOC_STATUS'  		,label:'<spring:message code="Cache.lbl_apv_doc_status" />'			,width:'50'		,align:'center'	,formatter: template.statusPointer}			//문서상태	
			]
			,receiveProcess	: [
				 {key:'RECEIVERNAME'  		,label:'<spring:message code="Cache.lbl_apv_SendDept" />'			,width:'50'		,align:'left'}	 //발신처
				,{key:'DOCNUMBER'  			,label:'<spring:message code="Cache.lbl_apv_setschema_tab06" />'	,width:'50'		,align:'left'}	 //문서번호	
				,{key:'PROCESSSUBJECT' 		,label:'<spring:message code="Cache.lbl_subject" />'				,width:'100'	,align:'left'	,formatter: template.subject }	//제목		
				,{key:'INITIATORNAME'		,label:'<spring:message code="Cache.lbl_writer" />'					,width:'50'		,align:'center'	,formatter: template.initiatorName}		//작성자		
				,{key:'DISTRIBDATE'  		,label:'<spring:message code="Cache.lbl_apv_DistributeDate" />'		,width:'50'		,align:'center'	,formatter: template.stringDateToString('DISTRIBDATE') }	//완료일시
				,{key:'DISTRIBDEPTNAME'  	,label:'<spring:message code="Cache.lbl_apv_govdoc_recvProcDept" />',width:'50'		,align:'center'}	//배부처			
				,{key:'DOCTYPE'  			,label:'<spring:message code="Cache.lbl_apv_doc_status" />'			,width:'50'		,align:'center'	,formatter: template.receiveStatusVw}				//문서상태
			]
			,history	: [ 
				{key:'PROCESSSUBJECT'		,label:'<spring:message code="Cache.lbl_subject" />'				,width:'20'		,align:'left' 	,formatter : template.docVw}			//제목			
				,{key:'FILE_NAME'			,label:'<spring:message code="Cache.lbl_apv_FileName" />'			,width:'15'		,align:'center'}	//파일명
				,{key:'PROCESS_DT'			,label:'<spring:message code="Cache.lbl_ProcessingDays" />'			,width:'10'		,align:'center'	,formatter: template.stringDateToString('INSERT_DT') }	//일시				
				,{key:'STATUS'				,label:'<spring:message code="Cache.lbl_att_sch_sts" />'			,width:'5'		,align:'center' ,formatter: template.historyStatusVw}	//상태
			]
			,receiveGov24Wait : [
			    {key:'SECURITYTEXT'  		,label:'<spring:message code="Cache.lbl_apv_Publication" />'		,width:'30'			,align:'center'}	//공개 여부
				,{key:'RECEIVERNAME'  		,label:'<spring:message code="Cache.lbl_apv_SendDept" />'			,width:'50'		,align:'left'}	//발신처
				,{key:'DOCNUMBER'  			,label:'<spring:message code="Cache.lbl_apv_setschema_tab06" />'	,width:'50'		,align:'left'}	//문서번호
				,{key:'PROCESSSUBJECT' 		,label:'<spring:message code="Cache.lbl_subject" />'				,width:'100'	,align:'left'	,formatter: template.subject }	//제목		
				,{key:'INITIATORNAME'		,label:'<spring:message code="Cache.lbl_apv_history_mail_sender" />',width:'50'		,align:'center'	,formatter: template.initiatorName}		//발송자		
				,{key:'INSERTED'  			,label:'<spring:message code="Cache.lbl_ReceiveDate" />'			,width:'50'		,align:'center'	,formatter: template.stringDateToString('INSERTED') }	//수신일시
				,{key:'GOVDOC_STATUS'  		,label:'<spring:message code="Cache.lbl_apv_doc_status" />'			,width:'50'		,align:'center'	,formatter: template.statusPointer}			//문서상태
				,{key:'SENDTYPE' 			,label:'<spring:message code="Cache._lbl_sendType" />'				,width:'50'		,align:'center', formatter: template.sendType }			//발송유형				
			]
			,senderMaster : [
				{key:'chk'					,label:'chk'														,width:'10'		,align:'center' ,formatter:'checkbox', sort:false }
				,{key:'SENDER_TYPE'  		,label:'<spring:message code="Cache.lbl_apv_gubun" />'				,width:'15'		,align:'center'	,formatter: template.senderMasterType } 							//구분
				,{key:'DEPT_NAME'  			,label:'<spring:message code="Cache.lbl_apv_companyDeptName" />'	,width:'30'		,align:'center'	,formatter: function(){return this.item.DEPT_NAME;} }				//회사/부서명
				,{key:'DISPLAY_NAME'  		,label:'<spring:message code="Cache.lbl_DisplayName" />'			,width:'30'		,align:'center'	,formatter: function(){return this.item.DISPLAY_NAME;} } 			//표시이름
				,{key:'USAGE_STATE'  		,label:'<spring:message code="Cache.lbl_apv_IsUse" />'				,width:'20'		,align:'center' ,formatter: function(){return this.item.USAGE_STATE;} }				//사용여부
				,{key:'OUNAME' 				,label:'<spring:message code="Cache.lbl_apv_orgName" />'			,width:'30'		,align:'center'	,formatter: function(){return this.item.OUNAME;} }					//기관명		
				,{key:'NAME'				,label:'<spring:message code="Cache.lbl_apv_wardenName" />'			,width:'40'		,align:'center'	,formatter: function(){return this.item.NAME;} }					//기관장명
				,{key:'CAMPAIGN_T'  		,label:'<spring:message code="Cache.lbl_apv_campaignT" />'			,width:'50'		,align:'center'	,formatter: function(){return this.item.CAMPAIGN_T;} }				//캠페인(상)
				,{key:'CAMPAIGN_F'  		,label:'<spring:message code="Cache.lbl_apv_campaignF" />'			,width:'50'		,align:'center'	,formatter: function(){return this.item.CAMPAIGN_F;} }				//캠페인(하)
				,{key:'ADDRESS' 			,label:'<spring:message code="Cache.lbl_Address" />'				,width:'40'		,align:'center' ,formatter: function(){return this.item.ADDRESS;} }					//주소	
				,{key:'TEL' 				,label:'<spring:message code="Cache.lbl_PhoneNum" />'				,width:'30'		,align:'center' ,formatter: function(){return this.item.TEL;} }						//전화번호		
				,{key:'FAX' 				,label:'<spring:message code="Cache.lbl_FaxNum" />'					,width:'30'		,align:'center' ,formatter: function(){return this.item.FAX;} }						//FAX		
			]
		})[pageAttr];
							
		var gridFunctions = ({
			sendWait : function(id){ /* 발송함 */
				id === "sendStatusVw" && Common.open("", "addUser", "<spring:message code='Cache.lbl_apv_send_list' />" ,"/approval/user/GovDocSendHistoryPopup.do?uniqueId="+this.item.UNIQUEID+"&govDocs="+pageAttr, '950px', '400px', "iframe", true, null, null, true);
				id === "subject" && CFN_OpenWindow(this.item.LINKURL+"&docType="+this.item.DOCTYPE+"&GovState=SENDWAIT",'', 850,(window.screen.height - 100),"resize");
			}
			,receiveWait : function(id){ /* 수신함 */
				id === "statusPointer" && Common.open("", "addUser", "<spring:message code='Cache.lbl_apv_govdoc_history' />"//수신 이력" 
						,"/approval/user/GovDocHistoryPopup.do?callType=receive&uniqueId="+this.item.UNIQUEID+"&govDocs=history", '950px', '650px', "iframe", true, null, null, true);
				id === "subject" && CFN_OpenWindow(this.item.LINKURL+"&GovState=RECEIVEWAIT&statusCd="+this.item.DOCTYPE,'', 850,(window.screen.height - 100),"resize");
			}
			,receiveProcess	: function(id){ /* 배부완료 */
				id !== "receiveStatusVw" && CFN_OpenWindow(this.item.LINKURL+"&GovState=RECEIVEPROCESS&statusCd="+this.item.DOCTYPE,'', 850,(window.screen.height - 100),"resize");
			}
			,history : function(id){ /* 수신이력 */
				id === "historyStatusVw" && Common.open("", "addUser", "<spring:message code='Cache.lbl_apv_govdoc_history' />"//수신 이력
						,"/approval/user/GovDocHistoryPopup.do?uniqueId="+this.item.UNIQUE_ID+"&govDocs="+pageAttr, '950px', '400px', "iframe", true, null, null, true); 
				id !== "historyStatusVw" && this.item.LINKURL != "" && CFN_OpenWindow(this.item.LINKURL+"&GovState=RECEIVEWAIT",'', 850,(window.screen.height - 100),"resize");		
			}				
			,receiveGov24Wait : function(id){ /* 문서24접수대기 */
				id === "statusPointer" && Common.open("", "addUser", "<spring:message code='Cache.lbl_apv_govdoc_history' />"//수신 이력" 
						,"/approval/user/GovDocHistoryPopup.do?uniqueId="+this.item.UNIQUEID+"&govDocs=history", '950px', '400px', "iframe", true, null, null, true);
				id !== "statusPointer" && CFN_OpenWindow(this.item.LINKURL+"&GovState=RECEIVEWAIT&statusCd="+this.item.DOCTYPE,'', 850,(window.screen.height - 100),"resize");
			}
			,senderMaster : function(id){ /* 발신처 관리 */
				openAddPopup("M", this.item.SEND_ID);
			}
		})[pageAttr];
			
		var ajax = function(pUrl, param, bAsync){
			var deferred = $.Deferred();
			$.ajax({
				url: pUrl,
				type:"POST",
				data: param,
				async: bAsync === false ? false : true,
				success:function (data) { deferred.resolve(data);},
				error:function(response, status, error){ deferred.reject(status); }
			});
		 	return deferred.promise();
		}
		
		var selectGovDocMng = function(){
			ajax("/approval/user/selectGovDocMng.do", {}, false)
				.done(function( data ){
					if( data.adminYN === "Y") {
						var list = data.mngList;
						$("#selectSearchUser .selTit").append( $("<a>",{ "class" : "up", "value" : list[0].AUTHORITYID, "text" : (list[0].ADMINYN == "Y" ? list[0].AUTHORITYNAME + "(관리자)" : list[0].AUTHORITYNAME)}) );
						$("#selectSearchUser .selList").append( 
						  	list.map(function( item,idx ){ 
							  return $("<a>",{ "class" : "listTxt", "value" : item.AUTHORITYID, "text" : (item.ADMINYN == "Y" ? item.AUTHORITYNAME + "(관리자)" : item.AUTHORITYNAME) }); 
							})
						);
					}
					else {
						$("#selectSearchUser .selTit").append( $("<a>",{ "class" : "up", "value" : sessionObj.USERID, "text" : sessionObj.USERNAME }) );
					}
				})
				.fail(  function( e ){  console.log(e) });
		}
		
		var openOfflineDoc = function() {
			var sDocListType = pageAttr.toUpperCase();

			var fmpf = "";
			var pDocList = "";
			switch (sDocListType) {
				case "SENDCOMPLETE": // 발송완료
					fmpf = "OFFICIAL_DOCUMENT_GOV";
					pDocList = 3;
					break;
				case "RECEIVEPROCESS": // 배부완료
					fmpf = "OFFICIAL_DOCUMENT_GOV_REC";
					pDocList = 20;
					break;
				default:
					break;
			}
			
			var width = "850px";
			var height = (window.screen.height - 100) + "px";
			CFN_OpenWindow("/approval/approval_Form.do?mode=DRAFT&menukind=notelist&formPrefix=" + fmpf + "&doclisttype=" + pDocList, "", width, (window.screen.height - 100), "resize");
		}
		
		this.searchChangeUser = function(obj) {
			ListGrid.listData.ajaxPars.userId = $(obj).attr("value");
			$("#simpleSearchBtn").click();	
		}
		
		/* 사용함수 */
		this.pageInit = function(){
			/* Title */
			$("#govDocsTit").text( title );
			
			// 관리자인 경우, 담당자 select box 표시
			//selectGovDocMng();
			
			// 문서상태 select box
			var govDocStatus = Common.getBaseCode("GovDocStatus").CacheData;
			govDocStatus.forEach(function(item) {
				if ($.trim(item.Reserved1).indexOf(pageAttr.toUpperCase()) > -1) {
					$('#govDocStatus').append('<option value="' + item.Code + '">' + CFN_GetDicInfo(item.MultiCodeName) + '</option>');
				}
			});
			// 공개여부 select box
			var DocSecurity = Common.getBaseCode("GovDocSecurity").CacheData;
			DocSecurity.forEach(function(item) {
					$('#govDocSecurity').append('<option value="' + item.Reserved1 + '">' + CFN_GetDicInfo(item.MultiCodeName) + '</option>');
			});
			
			$("#govDocStatus, #receiveProcessStatus, #receiveStatus, #govDocSecurity").on('change',function(){
				var obj 		=	{
					fromDate	:	$("#DeputyFromDate").val()
					,toDate		:	$("#DeputyToDate").val()
					,fieldName 	: 	$("#selectSearchType .selTit a").attr('value')
					,keyword 	: 	$("#titleNm").val().replace(/\s/gi,'').length > 0 ? $("#titleNm").val() : ""
					,govDocStatus	: 	$("#govDocStatus").val()
					,govDocSecurity	: 	$("#govDocSecurity").val()
				}
				
				selectParams = $.extend(selectParams, obj);
				if (pageAttr.toUpperCase() == "HISTORY") selectParams = $.extend(selectParams, { receiveStatus: $("#receiveStatus").val() });
				setGrid();
			});
			$("#refresh").on('click',function(){ CoviMenu_GetContent(location.href.replace(location.origin, ""), false); });
			$("#simpleSearchBtn").on('click',function(){
				var fileNameVal = $("#selectSearchType .selTit a").attr('value') == undefined ? "title" : $("#selectSearchType .selTit a").attr('value');
				selectParams = $.extend(selectParams, { fieldName : fileNameVal, keyword : $("#searchInput").val() });
				setGrid();
			});
			$("#searchInput").on( 'keypress', function(){  event.keyCode === 13 && $("#simpleSearchBtn").trigger('click'); });
			$("#detailSchBtn").on('click',function(){
				$(this).toggleClass( 'active' );
				$("#DetailSearch").toggleClass( 'active' );
				setGrid();
			});
			
			/* 상세 */
			$("#selectSearchType,#selectSearchUser").on('click',function(){
				var target		= event.target;				
				target.className === 'listTxt' && $(".up",this).text( target.innerText ).attr('value', target.getAttribute( 'value' ) );
				target.offsetParent.id === 'selectSearchUser' && docFunc.searchChangeUser(target);
				$(".selList",this).toggle();
			});
			
			$('#excelBtn').on('click',function(){
				if (!selectParams) {
					var obj = {
						govDocs : pageAttr
						,userId : $("#selectSearchUser .selTit a").attr('value')
						,govDocStatus : $("#govDocStatus").val()
						,receiveProcessStatus : $("#receiveProcessStatus").val()
					};
					selectParams = $.extend(selectParams, obj);
					if (pageAttr.toUpperCase() == "HISTORY") selectParams = $.extend(selectParams, { receiveStatus: $("#receiveStatus").val() });
				}
				selectParams = $.extend(selectParams, { sortBy : sort() });
				
				var queryID= "";
				var title="";
				var header = getHeaderDataForExcel();
				Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage'/>", "<spring:message code='Cache.ACC_btn_save' />", function(result){
		       		if(result){
		       			if (pageAttr == 'sendWait' || pageAttr == 'receiveWait' || pageAttr == 'receiveProcess' || pageAttr == 'receiveGov24Wait') {
		       				location.href = "/approval/user/govDocListExcelDownload.do?"
								+"selectParams="+encodeURIComponent(encodeURIComponent(JSON.stringify(selectParams)))
								+"&title="+encodeURIComponent(encodeURIComponent($("#govDocsTit").text()))			// 한글 깨짐 문제 때문에 두번 encode
								+"&headerkey="+encodeURIComponent(header[0])
								+"&headername="+encodeURIComponent(encodeURIComponent(header[1]))			// 한글 깨짐 문제 때문에 두번 encode
		       			} else {
							location.href = "/approval/user/downloadGovDocExcel.do?"
								+"selectParams="+encodeURIComponent(encodeURIComponent(JSON.stringify(selectParams)))
								+"&queryID="+queryID
								+"&title="+encodeURIComponent(encodeURIComponent($("#govDocsTit").text()));			// 한글 깨짐 문제 때문에 두번 encode
		       			}
					}
				});
			});
			
			$('#detailSearchBtn').on('click',function(){
				var obj 		=	{
					fromDate	:	$("#DeputyFromDate").val()
					,toDate		:	$("#DeputyToDate").val()
					,fieldName 	: 	$("#selectSearchType .selTit a").attr('value')
					,keyword 	: 	$("#titleNm").val().replace(/\s/gi,'').length > 0 ? $("#titleNm").val() : ""
				}
				
				selectParams = $.extend(selectParams, obj);
				if (pageAttr.toUpperCase() == "HISTORY") selectParams = $.extend(selectParams, { receiveStatus: $("#receiveStatus").val() });
				setGrid();
			});
			$('#titleNm').on( 'keypress', function(){  event.keyCode === 13 && $("#detailSearchBtn").trigger('click'); });
			
			// Offline 등록			
			switch( pageAttr.toUpperCase() ) {
				case "SENDWAIT"://발송함
					$("#govDocStatus").show();
					$("#excelBtn").show();
					break;
				case "RECEIVEWAIT"://수신함
					$("#govDocStatus").show();
					$("#govDocSecurity").show();
					$("#excelBtn").show();
					break;
				case "SENDCOMPLETE": // 발송완료
					$("#btOffline").css("display", "");
					$("#btOffline").on('click',function(){ openOfflineDoc(); });
					//$("#receiveStatus").show();
					$("#excelBtn").show();
					break;
				case "RECEIVEPROCESS": // 배부완료
					$("#btOffline").css("display", "");
					$("#btOffline").on('click',function(){ openOfflineDoc(); });
					//$("#receiveStatus").show();
					$("#excelBtn").show();
					break;
				case "HISTORY"://수신이력
					$("#receiveStatus").show();
					break;
				case "RECEIVEGOV24WAIT"://접수대기함	
					//$("#receiveStatus").show();
					$("#govDocStatus").show();
					$("#govDocSecurity").show();
					$("#excelBtn").show();
					break;
				case "SENDERMASTER"://발신처관리
					$("#addBtn").show();
					$("#deleteBtn").show();
					break;
				default:
					break;
			}
		}
		
		this.refresh = function(){ $("#detailSearchBtn").trigger('click'); }
		
		var sort = function() {
			var rtn;
			if (ListGrid.nowSortHeadObj) {
				rtn = ListGrid.nowSortHeadObj.key + " " + ListGrid.nowSortHeadObj.sort;
			} else {
				switch (pageAttr.toUpperCase()) {
					case "SENDWAIT": //발송함
						rtn = "SENDDATE DESC";
						break;
					case "RECEIVEWAIT": //수신함
						rtn = "INSERTED DESC";
						break;
					case "HISTORY": //수신이력
						rtn = "HIS.UNIQUE_ID DESC";
						break;
					case "RECEIVEPROCESS": // 배부완료
						rtn = "DISTRIBDATE DESC";
						break;
					default:
						rtn = "UNIQUEID DESC";
						break;
				}
			}
			return rtn;
		}
		
		this.gridInit = function(){
			ListGrid.setGridHeader(headerData);
			ListGrid.setGridConfig({
				targetID : "approvalListGrid",
				height:"auto",
				paging : true,
				page : {
					pageNo:1,
					pageSize:$("#selectPageSize").val()
				},
				notFixedWidth : 4,
				overflowCell : [],
				body: {
			        onclick  : function(){
			        	var id = $( event.target ).attr('id');
						if( !id ) return;
			        	gridFunctions.call(this,id);
			        }
			    }
			});
			
			ListGrid.bindGrid({
				ajaxUrl : "/approval/user/getGovApvList.do",
				ajaxPars: $.extend(selectParams, { govDocs : pageAttr,
							sortBy: sort(),
							userId : $("#selectSearchUser .selTit a").attr('value'),
							govDocStatus: $("#govDocStatus").val(),
							receiveProcessStatus: $("#receiveProcessStatus").val(),
							receiveStatus: $("#receiveStatus").val(),
							govDocSecurity : $("#govDocSecurity").val()
						  })
			});
		}
		
		// 발신처관리 삭제
		this.deleteSenderMaster = function(){
			var checkList = ListGrid.getCheckedList(0);
			var senderID = checkList[0].SEND_ID;
			
			if(checkList != null && checkList != ""){
				if(checkList.length > 1){
					Common.Inform("<spring:message code='Cache.msg_SelectOne' />"); // 한개만 선택되어야 합니다
				}else if(checkList.length == 0){
					Common.Inform("<spring:message code='Cache.lbl_apv_alert_selectRow' />"); // 선택한 행이 없습니다.
				}else{
					Common.Confirm("<spring:message code='Cache.msg_apv_093' />", "Confirmation Dialog", function(result){ //삭제하시겠습니까?	
						if(result){
							$.ajax({
								url: "/approval/user/deleteSenderMasterData.do",
								type: "POST",
								data: {
									"senderID": senderID
								},
								success: function(data){
									if(data.status == "SUCCESS"){
										Common.Inform(data.message, "Information", function(result){
											if(result){
												Common.Close();
												parent.Refresh();
											}
										});
									}else{
										Common.Error("<spring:message code='Cache.msg_apv_030' />");  // 오류가 발생했습니다.
									}
								},
								error: function(error){
									Common.Error("<spring:message code='Cache.msg_apv_030' />");  // 오류가 발생했습니다.
								}
							});
						}
					});
				}
			}else{
				Common.Inform('선택한 행이 없습니다.'); // 선택한 행이 없습니다.
			}
		}
	}
	var GOVDOCS = CFN_GetQueryString("GovDocs");
	//일괄 호출 처리
	var docFunc = new govDocFunction(GOVDOCS);
	
	initApprovalListComm(initDocList, setGrid);
	
	function initDocList() {
		docFunc.pageInit();
		docFunc.gridInit();
	}
	
	function setGrid() {
		docFunc.gridInit();
	}
	
	// 발신처관리 팝업
	function openAddPopup(mode, senderID){
		var url = "/approval/user/SenderMasterAddPopup.do?mode="+mode+"&senderID="+senderID;
		var popupName = "발신처 추가";
		
		var heights = "650px";
		if(mode == "M"){
			popupName = "발신처 수정";
			heights = "650px";
		}else if(mode == "R"){
			popupName = "발신처 조회";
		}
		
		Common.open("", "addSenderMaster", popupName, url, "600px", heights, "iframe", true, null, null, true);
	}

</script>
