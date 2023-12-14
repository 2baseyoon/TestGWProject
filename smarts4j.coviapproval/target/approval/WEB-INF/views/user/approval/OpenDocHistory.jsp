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
					<input class="adDate" type="text" id="FromDate" date_separator="-"> - <input id="ToDate" date_separator="-" kind="twindate" date_starttargetid="FromDate" class="adDate" type="text" data-axbind="twinDate">						
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
				<a id="delBtn" class="btnTypeDefault" style="display:none"><spring:message code='Cache.btn_Delete' /></a><!-- 삭제 -->
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
		var pageAttr = page.length > 0 ? page : "history";
		var selectParams;
		
		var template = {
			subject 			:	function(){ return this.value; }
			,initiatorDeptName 	: 	function(){ return CFN_GetDicInfo(this.value); }		
			,initiatorName 		: 	function(){ return CFN_GetDicInfo(this.value); }		
			,stringDateToString : 	function(attr){
				return function(){
					return getStringDateToString("yyyy.MM.dd HH:mm:ss",this.item[attr]);
				}
			}			
			,sendtype 	: 	function(){
				var value = "";
				this.value === "NEW" 		&& 	(value = "신규");
				this.value === "UPT" 		&& 	(value = "수정");
				return value;
				//return $("<a>", { "id" : "statusPointer", "text" : value }).get(0).outerHTML 
			}
		};	
		
		var title = ({
			history 		: "<spring:message code='Cache.lbl_apv_govdoc_opendocHistory' />" // 원문공개 연계이력
		})[pageAttr];
		
					
		var header = ({			
			history : [
				{key:'CHK'  		,label:'-'			,width:'15'		,align:'center', formatter: "checkbox", sort:false }
				,{key:'DOCNUMBER'  	,label:'<spring:message code="Cache.lbl_DocNo" />'						,width:'50'		,align:'center'}	//문서번호
				,{key:'SUBJECT' 	,label:'<spring:message code="Cache.lbl_subject" />'					,width:'100'	,align:'left'	,formatter: template.subject }	//제목
				,{key:'DEPTNAME'	,label:'<spring:message code="Cache.lbl_DraftDept" />'					,width:'40'		,align:'center'	,formatter: template.initiatorDeptName}		//작성부서			
				,{key:'USERNAME'	,label:'<spring:message code="Cache.lbl_writer" />'						,width:'30'		,align:'center'	,formatter: template.initiatorName}		//작성자
				,{key:'SENDDATE'  	,label:'<spring:message code="Cache.lbl_apv_govdoc_opendocSendDate" />'	,width:'50'		,align:'center'	,formatter: template.stringDateToString('SENDDATE')}	//생성일자
				,{key:'SENDTYPE'  	,label:'<spring:message code="Cache.lbl_apv_govdoc_opendocSendType" />'	,width:'50'		,align:'center'	,formatter: template.sendtype}	//전송유형
			]
		})[pageAttr];

		var gridFunctions = ({
			history : function(id){ /* 마스터 */
					id !== "statusPointer" && CFN_OpenWindow(this.item.LINKURL,'', 850,(window.screen.height - 100),"resize");
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
				target.offsetParent.id === 'selectSearchUser' && docFunc.searchChangeUser(target);
				$(".selList",this).toggle();
			});

			$('#detailSearchBtn').on('click',function(){
				var obj 		=	{
					startDate	:	$("#FromDate").val()
					,endDate		:	$("#ToDate").val()
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
// 			$("#excelBtn").show().on ( 'click', function(){  
// 				// Excel 다운로드.
// 			});
			$("#delBtn").show().on ( 'click', function(){  
				// 선택삭제.
				var checkApprovalList = ListGrid.getCheckedList(0);
				if (checkApprovalList.length == 0) {
					Common.Warning("<spring:message code='Cache.lbl_Mail_NoSelectItem' />");
				}else if (checkApprovalList.length > 0) {
					
					Common.Confirm("삭제하시겠습니까?", "Information Dialog", function (result) {
						if(!result){
							return;
						}
						var chkedList = [];
						for(var idx = 0; idx < checkApprovalList.length; idx++){
							chkedList.push(checkApprovalList[idx].HISTORY_ID);
						}
						var param = {
							chkHistoryId : chkedList.join(",")					
						};
						
						var bAsync = false;
						ajax("/approval/user/opendoc/delHistory.do", param, bAsync).done(function(res) {
							if (res.status == "SUCCESS") {
				                if(ListGrid){
				                	ListGrid.reloadList();
				                }
							}else{
								Common.Inform("오류가 발생했습니다.", "Information Dialog");
							}
						}).fail( function(response, status, error){ CFN_ErrorAjax("/approval/user/opendoc/reConvertDoc.do", response, status, error); });
					});
				}
			});
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
				ajaxUrl : "/approval/user/opendoc/getHistoryList.do",
				ajaxPars: $.extend(selectParams, { govDocs : pageAttr })
			});
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