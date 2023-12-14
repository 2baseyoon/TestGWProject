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
		<a id="detailSchBtn" class="btnDetails"><spring:message code="Cache.lbl_apv_detail"/></a> <!-- 상세 -->
	</div>
</div>
<div class="cRContBottom mScrollVH ">	
	<div class="inPerView type02 appSearch" id="DetailSearch">
		<div>
			<div class="selectCalView">
				<span><spring:message code="Cache.lbl_Contents"/></span>	<!-- 내용 -->
				<div class="selBox" style="width: 110px;" id="selectSearchType">
					<span class="selTit">
						<a value="title" class="up"><spring:message code="Cache.lbl_subject"/><!--  제목--></a></span>
						<div class="selList" style="width:83px;display: none;">
							<a class="listTxt" value="title"><spring:message code="Cache.lbl_subject"/><!--제목--></a>
							<a class="listTxt" value="docnumber"><spring:message code="Cache.lbl_DocNo"/><!--문서번호--></a>
						</div>
				</div>
				<input type="text" id="titleNm" style="width: 215px;">
			</div>
		</div>
		<div>
			<div class="selectCalView">
				<span><spring:message code="Cache.lbl_scope"/></span>	<!-- 기간 -->
				<div id="divCalendar" class="dateSel type02">
					<input class="adDate" type="text" id="DeputyFromDate" date_separator="-"> - <input id="DeputyToDate" date_separator="-" kind="twindate" date_starttargetid="DeputyFromDate" class="adDate" type="text" data-axbind="twinDate">						
				</div>
			</div>
			<a id="detailSearchBtn" class="btnTypeDefault btnSearchBlue nonHover"><spring:message code="Cache.lbl_search"/><!--  검색--></a>
		</div>							
	</div>	
	<div class="apprvalContent">
		<div class="boradTopCont apprvalTopCont" style="height:45px">
			<div class="pagingType02 buttonStyleBoxLeft">							
				<div class="selBox" style="width: 130px;display: none;"" id="selectSearchUser" >
					<span class="selTit"></span>						
					<div class="selList" style="width:130px; display: none;"></div>
				</div>
				<a id="excelBtn" class="btnTypeDefault btnExcel" style="display:none"><spring:message code='Cache.btn_SaveToExcel' /></a><!-- 엑셀저장 -->
				<a id="reprocessingBtn" class="btnTypeDefault" style="display:none">재처리</a>
			</div>
			<div class="buttonStyleBoxRight">
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
		
	var govDocFunction = function(page){
		
		var ListGrid = new coviGrid();
		var pageAttr = page.length > 0 ? page : "master";
		var selectParams;
		
		var template = {
			subject 			:	function(){ return $("<a>", { "id" : "subject", "text" : this.value }).get(0).outerHTML }
			,initiatorDeptName 	: 	function(){ return CFN_GetDicInfo(this.value); }		
			,initiatorName 		: 	function(){ return CFN_GetDicInfo(this.value); }		
			,stringDateToString : 	function(attr){
				return function(){
					return getStringDateToString("yyyy.MM.dd HH:mm:ss",this.item[attr]);
				}
			}			
			,status 	: 	function(){ 
				var value = "";
				this.item.STATE === "READY" 		&& 	(value = "준비");// Master 만 입력된 상태
				this.item.STATE === "CONVERROR" 	&& 	(value = "<font id='state' color='red' style='cursor:pointer;'>변환오류</font>");
				this.item.STATE === "CONVCOMPLETE" 	&& 	(value = "변환완료"); // 발송대상
				this.item.STATE === "SENDCOMPLETE"	&& 	(value = "발송완료");
				this.item.STATE === "UPDATE"		&& 	(value = "문서수정");
				this.item.STATE === "CONVPROGRESS"	&& 	(value = "문서변환처리중");
				return value;
				//return $("<a>", { "id" : "statusPointer", "text" : value }).get(0).outerHTML 
			}
			,type : function(){
				var _type = "";
				this.value === "NEW" && (_type = "신규");
				this.value === "UPT" && (_type = "수정");
				return _type;
			}
			,isFile : function(){
				var returnHtml= "";
				this.item.ISFILE === "1" && (returnHtml = "<div class=\"fClip\" style=\"float: none;\"><a class=\"mClip\" id=\"file\"><spring:message code='Cache.lbl_attach'/></a></div>"); //첨부
				return returnHtml;
			}
		};	
		
		var title = ({
			master 		: "<spring:message code='Cache.lbl_apv_govdoc_opendocMaster' />" // 원문공개 마스터
		})[pageAttr];
		
					
		var header = ({			
			master : [
				{key:'CHK'  		,label:'<spring:message code="Cache.lbl_apv_RecvDept" />'			,width:'15'		,align:'center', formatter: "checkbox", sort:false, disabled : function(){
					return (this.item.STATE !== "CONVERROR" && this.item.STATE !== "UPDATE");
				}}
				,{key:'DOCNUMBER'  		,label:'<spring:message code="Cache.lbl_DocNo" />'			,width:'50'		,align:'center'}	//문서번호
				,{key:'SUBJECT' 		,label:'<spring:message code="Cache.lbl_subject" />'		,width:'100'	,align:'left'	,formatter: template.subject }	//제목
				,{key:'DEPTNAME'		,label:'<spring:message code="Cache.lbl_DraftDept" />'		,width:'40'		,align:'center'	,formatter: template.initiatorDeptName}		//작성부서			
				,{key:'USERNAME'		,label:'<spring:message code="Cache.lbl_writer" />'			,width:'30'		,align:'center'	,formatter: template.initiatorName}		//작성자
				,{key:'REGISTDATE'  	,label:'<spring:message code="Cache.lbl_RegistDateHour" />'	,width:'50'		,align:'center'	,formatter: template.stringDateToString('REGISTDATE')}	//생성일자
				,{key:'ISFILE'  		,label:'<spring:message code="Cache.lbl_File" />'			,width:'15'		,align:'center'	,formatter: template.isFile}	//파일
				,{key:'NEW_UPDT_SE_CD'  ,label:'<spring:message code="Cache.lbl_apv_gubun" />'		,width:'25'		,align:'center'	,formatter: template.type}	//신규,수정 여부
				,{key:'STATE'  			,label:'<spring:message code="Cache.lbl_apv_doc_status" />'	,width:'30'		,align:'center'	,formatter: template.status}	//문서상태
			]
		})[pageAttr];
							
		var gridFunctions = ({
				master : function(id){ /* 마스터 */
					id === "subject" && openApvDoc(this.item.PROCESSID);
					id === "file" && openfileList(this.item.DOCID);
					if(id == "state" && this.item.STATE == "CONVERROR"){
						Common.open("","errorlog", " Detail Error Message", docFunc.makeScrollMsg(this.item.RESULTMSG), "700px", "500px", "html", true, null, null, true);
					}
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
		
		this.searchChangeUser = function(obj) {
			ListGrid.listData.ajaxPars.userId = $(obj).attr("value");
			$("#simpleSearchBtn").click();	
		}
		
		/* 사용함수 */
		this.pageInit = function(){
			/* Title */
			$("#govDocsTit").text( title );
					
			$("#refresh").on('click',function(){ ListGrid.reloadList(); });
			$("#simpleSearchBtn").on('click',function(){
				selectParams = $.extend(selectParams, { searchType : "title", searchWord : $("#searchInput").val() });
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
				target.offsetParent.id === 'selectSearchUser' && this.searchChangeUser(target);
				$(".selList",this).toggle();
			});

			$('#detailSearchBtn').on('click',function(){
				var obj 		=	{
					startDate	:	$("#DeputyFromDate").val()
					,endDate		:	$("#DeputyToDate").val()
					,searchType 	: 	$("#selectSearchType .selTit a").attr('value')
					,searchWord 	: 	$("#titleNm").val().replace(/\s/gi,'').length > 0 ? $("#titleNm").val() : ""
				}

				if((obj.startDate != "" && obj.endDate == "") || (obj.startDate == "" && obj.endDate != "")){
					Common.Warning("<spring:message code='Cache.msg_apv_periodSearchAllInputDT' />");	// 기간 검색 시 시작일과 종료일을 모두 입력해주십시오.
					return false;
				}
				
				selectParams = $.extend(selectParams, obj);
				setGrid();
			});			
			$('#titleNm').on( 'keypress', function(){  event.keyCode === 13 && $("#detailSearchBtn").trigger('click'); });

			$("#reprocessingBtn").show().on('click', reprocessing);
		}
		
		
		this.refresh = function(){ $("#detailSearchBtn").trigger('click'); }
				
		this.gridInit = function(){			
			ListGrid.setGridHeader(header);
			ListGrid.setGridConfig({
				targetID : "approvalListGrid",
				height:"auto",
				paging : true,
				page : {
					pageNo:1,
					pageSize:$("#selectPageSize").val()
				},
				notFixedWidth : 4,
				overflowCell : [6],
				body: {
			        onclick  : function(){
			        	var id = $( event.target ).attr('id');			        	
						if( !id ) return;
			        	gridFunctions.call(this,id);
			        }
			    }
			});	
			
			ListGrid.bindGrid({ 
				ajaxUrl : "/approval/user/opendoc/getOpenDocApvList.do",
				ajaxPars: $.extend(selectParams, { govDocs : pageAttr })
			});
		}

		var reprocessing = function(){
			var checkApprovalList = ListGrid.getCheckedList(0);
			if (checkApprovalList.length == 0) {
				Common.Warning("<spring:message code='Cache.lbl_Mail_NoSelectItem' />");
			} else if (checkApprovalList.length > 0) {
				var execute = function(){
					var item = checkApprovalList.splice(0,1)[0];
					var param = {
							FormInstID 	: item.DOCID
					}
					ajax("/approval/user/opendoc/reConvertDoc.do", param, false )
			    	.done(function(res){
			    		if (res.status == "SUCCESS" || (res.status == "FAIL" && res.message.indexOf("NOTASK")>-1)) {
			    			if(res.status == "FAIL"){
								res.message = Common.getDic("msg_apv_notask").replace(/(<([^>]+)>)/gi, "");
							}
			    			if( checkApprovalList.length > 0 ){
			    				execute();
							}else{
								//완료														
								Common.Inform("재처리 요청이 완료되었습니다", "Information Dialog", function () {
					                window.location.reload();
					                
					                if(ListGrid){
					                	ListGrid.reloadList();
					                }
					            });
							}									    												    			
			    		}else{
							Common.Warning(res.message);			//오류가 발생했습니다.
							checkApprovalList.unshift(item);
						}
			    	}).fail( function(response, status, error){ CFN_ErrorAjax("/approval/user/opendoc/reConvertDoc.do", response, status, error); });
				}; 
				execute();
			}			
		};
		
		this.makeScrollMsg = function(msg){
			function StringBuffer(){
				var str = "";
				this.append = function (msg){
					str = str + msg;
				};
				this.clear = function(){
					str = "";
				};
				this.toString = function(){return str;};
			}
			
			msg = msg.replace(/\</g, "&lt;");
			msg = msg.replace(/\>/g, "&gt;");
			msg = msg.replace(/\t/g, "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
			msg = msg.replace(/\r\n/g, "<br/>");
			msg = msg.replace(/\r/g, "<br/>");
			msg = msg.replace(/\n/g, "<br/>");
			
			var buf = new StringBuffer();
			buf.append("<div style='height:100%;padding:10px;overflow-y:auto;font-family:Georgia;font-size:16px;line-height:130%;white-space:nowrap;'>");
			buf.append(msg);
			buf.append("</div>");
			
			return buf.toString();
		}

		var openApvDoc = function(processID){
			CFN_OpenWindow("/approval/approval_Form.do?mode=COMPLETE&processID="+processID, "", 790, (window.screen.height - 100), "resize");
		} 

		var openfileList = function(docID){
			var target = event.target;
			if(!axf.isEmpty($(target).parent().eq(0).find('.file_box').html())){
				$(target).parent().find('.file_box').remove();
				return false;
			}
			$('.file_box').remove();
			var Params = { docID : docID };
			$.ajax({
				url:"/approval/user/opendoc/getOpenDocApvList.do",
				type:"GET",
				data:Params,
				async:false,
				success:function (data) {
					if(data.list.length > 0){
						var _ul = $("<ul>", {"class" : "file_box"});
						$(_ul).append($("<li>", {"class" : "boxPoint"}))
						$(data.list).each(function(idx, item){
							$(_ul).append($("<li>").append($("<a>").on("click", function(){ attachFileDownLoadCall.call(item); }).text("[" + item.Gubun + "] " + item.FileName)));
						});
						$(target).parent().append(_ul);
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/approval/getCommFileListData.do", response, status, error);
				}
			});
		}

		var attachFileDownLoadCall = function() {
	    	Common.fileDownLoad(this.FileID, this.FileName, this.FileToken);
	    }
	}

	//일괄 호출 처리
	var docFunc = new govDocFunction("${GovDocs}");	
	
	initApprovalListComm(initDocList, setGrid);
	
	function initDocList() {
		docFunc.pageInit();
		docFunc.gridInit();
	}
	
	function setGrid() {
		docFunc.gridInit();
	}

</script>