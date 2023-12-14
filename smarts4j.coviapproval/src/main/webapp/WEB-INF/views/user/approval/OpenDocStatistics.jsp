<%@page import="java.util.Calendar"%>
<%@page import="egovframework.coviframework.util.ComUtils"%>
<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@page import="egovframework.coviframework.util.StringUtil"%>
<%@page import="egovframework.baseframework.util.SessionHelper"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<script type="text/javascript" src="/approval/resources/script/user/ApprovalListCommon.js"></script>
<%
String fromDateStr = ComUtils.GetLocalCurrentDate("yyyy-MM-dd", -10);
String toDateStr = ComUtils.GetLocalCurrentDate("yyyy-MM-dd");
%>		
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
		<div style="display:none;">
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
					<input class="adDate" type="text" id="FromDate" date_separator="-" value="<%=fromDateStr%>"> - <input id="ToDate" date_separator="-" kind="twindate" date_starttargetid="FromDate" class="adDate" type="text" data-axbind="twinDate" value="<%=toDateStr%>">						
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
		var pageAttr = page.length > 0 ? page : "statistics";
		var selectParams;
		
		var template = {
			count 			:	function(){ return this.value == '' ? '-' : this.value; }		
			,stringDateToString : 	function(){
				return getStringDateToString("yyyy.MM.dd HH:mm:ss",this.value);
			}			
			,result 	: 	function(){ 
				var value = "";
				
				var resendBtn = "<a id='manualSend' class='btnType02 btnNormal'>수동연계</a>";
				switch(this.value){
				case "" :
					value = "미전송 " + resendBtn;
					break;
				case "SUCCESS" :
					value = "성공";
					break;
				case "FAIL" :
					value = "<font color='red'>실패 </font>" + resendBtn;
					break;
				case "PROGRESS" :
					value = "전송요청";
					break;
				}
				return value;
			},
			
			date : function(){
				var value = "";
				return this.value;
			}
		};	
		
		var title = ({
			statistics 		: "<spring:message code='Cache.lbl_apv_govdoc_opendocStatistics' />" // 원문공개 연계이력
		})[pageAttr];
		
					
		var header = ({			
			statistics : [
				{key:'DAY_RANGE'  	,label:'<spring:message code="Cache.lbl_apv_govdoc_opendocTargetdate" />'				,width:'50'		,align:'center'}	//대상일자
				,{key:'TOTCNT'		,label:'<spring:message code="Cache.lbl_apv_govdoc_opendocTotCnt" />'					,width:'40'		,align:'center'	,formatter: template.count}		//총건수
				,{key:'NEWCNT'		,label:'<spring:message code="Cache.lbl_apv_govdoc_opendocNewCnt" />'					,width:'40'		,align:'center'	,formatter: template.count}		//신규건수
				,{key:'UPDCNT'		,label:'<spring:message code="Cache.lbl_apv_govdoc_opendocUpdCnt" />'					,width:'40'		,align:'center'	,formatter: template.count}		//수정건수
				,{key:'RST'  		,label:'<spring:message code="Cache.lbl_apv_govdoc_opendocSendRst" />'					,width:'120'	,align:'center'	,formatter: template.result}	//전송결과
				,{key:'SENDDATE'  	,label:'<spring:message code="Cache.lbl_apv_govdoc_opendocSendDate" />'					,width:'40'		,align:'center'	,formatter: template.stringDateToString}		//전송일시
			]
		})[pageAttr];
							
		var gridFunctions = ({
			statistics : function(id){ /* 마스터 */
					id === "manualSend" && docFunc.manualSend(this.item.DAY_RANGE);
				}
			})[pageAttr];			
			
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
				docFunc.search();
			});			
			$('#titleNm').on( 'keypress', function(){  event.keyCode === 13 && $("#detailSearchBtn").trigger('click'); });
			$("#excelBtn").on ( 'click', function(){  
				// Excel 다운로드.
				docFunc.excelDown();
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
				ajaxUrl : "/approval/user/opendoc/getStatisticsList.do",
				// 기간조건 무조건 있도록 함.
				ajaxPars: $.extend(selectParams, {
					govDocs : pageAttr 
					,startDate	:	$("#FromDate").val()
					,endDate		:	$("#ToDate").val()					
				})
			});
		};
		
		this.search = function(){
			if("" == $("#FromDate").val() || "" == $("#ToDate").val()){
				Common.Warning("<spring:message code='Cache.msg_apv_periodSearchAllInputDT' />");	// 기간 검색 시 시작일과 종료일을 모두 입력해주십시오.
				return false;
			}
			var obj 		=	{
				startDate	:	$("#FromDate").val()
				,endDate		:	$("#ToDate").val()
				,searchType 	: 	$("#selectSearchType .selTit a").attr('value')
				,searchWord 	: 	$("#titleNm").val().replace(/\s/gi,'').length > 0 ? $("#titleNm").val() : ""
			}
			
			selectParams = $.extend(selectParams, obj);
			setGrid();
		};
		
		this.manualSend = function(targetDateStr){ // yyyyMMdd
			// 수동연계
			Common.Confirm("<spring:message code='Cache.msg_DoyouResend' />", "Confirmation Dialog", function (result) {
				if(result){
					
					var param = {
							targetDate : targetDateStr
					};
					$.ajax({
						url: "/approval/user/opendoc/resend.do",
						type:"POST",
						data: param,
						success:function (data) { 
							data.status === "SUCCESS" && Common.Inform("<spring:message code='Cache.msg_Mail_SentMail' />","",function(){ ListGrid.reloadList(); });
						},
						error:function(response, status, error){
		                    Common.Inform("<spring:message code='Cache.msg_FailedToSend' />", 'Information', null);
		                    ListGrid.reloadList();
			            }
					});								
				}		
			});	
		};
		
		this.excelDown = function(){
			;;
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