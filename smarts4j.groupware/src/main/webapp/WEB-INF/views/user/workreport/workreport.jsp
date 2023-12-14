<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div>
	<h3 class="con_tit_box">
		<span class="con_tit">업무보고</span>
	</h3>
	
	<!-- 상단 필터 및 메뉴 -->
	<div style="width:100%; height:40px; margin-bottom: 10px;">
		<div style="display:inline-block;">
			<button type="button" id="btnRefresh" class="AXButton" onclick="refresh()"><spring:message code="Cache.btn_Refresh"></spring:message></button>
			<span style="margin-left:10px;">
				<select id="selDivision" class='selectSearchField' style='width:150px;'></select>
				<select id="selJob" class='selectSearchField' style='width:200px;'></select>
				<select id="selType" class='selectSearchField' style='width:150px;'></select>
			</span>
			<span style="margin-left: 10px;">
				검색기간
				<input type="text" id="startDate" class="AXInput W100" style="padding:0px!important;"> ~ 
			    <input type="text" kind="twindate" date_starttargetid="startDate" date_align="right" date_valign="bottom" date_separator="-" id="endDate" class="AXInput W120" data-axbind="twinDate" style="padding:0px!important;">
			</span>
			
			<button type="button" id="btnSearch" class="AXButton" onclick="searchWorkReport()"><spring:message code="Cache.btn_search"></spring:message></button>
		</div>
	</div>
	
	<!-- Grid -->
	<div id="resultBoxWrap" style="margin-top : 15px;">
		<div id="workReportGrid"></div>
	</div>
</div>

<div id="divCommentBox" style="display:none;">
	<div style="width:300px; height:200px; padding : 10px;">
		<div id="divCommentContent" style="width:280px; height:140px; overflow-y : auto; border:1px solid #a0a0a0; box-sizing:border-box; padding:5px;"></div>
		<div style="margin-top : 10px; text-align:right;">
			<button type="button" class="AXButton" onclick="Common.Close('commentPop')">확인</button>
		</div>
	</div>
</div>

<script>
	var checkUserId = "<%=request.getParameter("checkUserId")%>";
	var workReportGrid = new coviGrid();
	
	//Grid 관련 사항 추가 -
	//Grid 생성 관련
	function setGrid(){
		//myGrid.setGridHeader(headerData);
		workReportGrid.setGridHeader([
			                  {key:'Month',  label:'제목', width:'200', align:'center', formatter : function() {
			                	  var statusText = "";
			                	  switch(this.item.State) {
			                	  case "W" : statusText = "작성중"; break;
			                	  case "I" : statusText = "승인요청"; break;
			                	  case "A" : statusText = "완료"; break;
			                	  case "R" : statusText = "작성중"; break;
			                	  }
			                	  var wrid = this.item.wrid ? "" : this.item.wrid;
			                	  var tHTML = "<a href='javascript:workReportPopOpen(\"" + this.item.WorkReportID + "\", \"" + this.item.CalID + "\")'>";
			                	  tHTML += this.item.Month + " 월 " + this.item.WeekOfMonth + " 주차 " + statusText;
			                	  tHTML += "</a>";
			                	  
			                	  return tHTML;
			                  }},
			                  {key:'StartDate',  label:'시작일', width:'100', align:'center'},
			                  {key:'EndDate', label:'종료일', width:'70', align:'center'},
			                  {key:'ReportDate',  label:'보고일' + Common.getSession("UR_TimeZoneDisplay"), width:'70', align:'center', 
			                   formatter : function() {
			                	   var dateStr = this.item.ReportDate;
			                	   if(dateStr != ""){
				                	   return CFN_TransLocalTime(dateStr, "yyyy-MM-dd");
			                	   }else{
			                		   return "-";
			                	   }
			                   }},
			                  {key:'State', label:'승인여부', width:'70', align:'center', formatter : function() {
			                	  var statusText = "";
			                	  switch(this.item.State) {
			                	  case "W" : statusText = "미보고"; break;
			                	  case "I" : statusText = "승인요청"; break;
			                	  case "A" : statusText = "승인"; break;
			                	  case "R" : statusText = "거부"; break;
			                	  }
			                	  
			                	  var commentBox = "";
			                	  if(this.item.Comment) {
			                		  // icnView
			                		  commentBox = '<a href="javascript:showCommentBox(' + this.index + ')" title="의견보기" ';
			                		  commentBox += 'style="background: url(/HtmlSite/smarts4j_n/covicore/resources/images/theme/icn_png.png) no-repeat -173px -550px; padding-left: 21px;"></a>';
			                	  }
			                	  
			                	  return statusText + commentBox;
			                  }},
			                  {key:'ApprovalDate',  label:'승인일' + Common.getSession("UR_TimeZoneDisplay"), width:'70', align:'center', 
				                   formatter : function() {
				                	   var dateStr = this.item.ApprovalDate;
				                	   if(dateStr != ""){
					                	   return CFN_TransLocalTime(dateStr, "yyyy-MM-dd");
				                	   }else{
				                		   return "-";
				                	   }
				                   }},
			                  {key:'ApproverName',  label:'승인자', width:'70', align:'center'}
				      		]);
		setGridConfig();
		bindGridData();
	}


	function bindGridData() {	
		var division = $("#selDivision").val();
		var jobId = $("#selJob").val();
		var type = $("#selType").val();
		
		var startDate = $("#startDate").val();
		var endDate = $("#endDate").val();
		
		var hidCheckUserId;
		// console.log("사용자 확인 : '"+checkUserId+"'");
		if(checkUserId != null && checkUserId != 'null' && checkUserId != undefined){
			hidCheckUserId = checkUserId;
			// console.log("사용자 변경 : "+hidCheckUserId);
		}
		
		workReportGrid.bindGrid({
			ajaxUrl:"getWorkReportMylist.do",
			ajaxPars: {
				jobid : jobId,
				type : type,
				division : division,
				startDate : startDate,
				endDate : endDate,
				checkUserId : hidCheckUserId
			},
			onLoad:function () {
				workReportGrid.fnMakeNavi("workReportGrid");
			}
		});
	}

	//Grid 설정 관련
	function setGridConfig(){
		var configObj = {
			targetID : "workReportGrid",		// grid target 지정
			sort : true,		// 정렬
			colHeadTool : false,	// 컬럼 툴박스 사용여부
			fitToWidth : true,		// 자동 너비 조정 사용여부
			colHeadAlign : 'center',
			height:"auto",
			
			page : {
				pageNo:1,
				pageSize:10
			},
			paging : true
		};
		
		// Grid Config 적용
		workReportGrid.setGridConfig(configObj);
	}

	
	var workReportPopOpen = function(wrid, calid) {
		if(wrid && wrid > 0) {
			var strUrl = "viewWorkReport.do?wrid=" + wrid + "&calid=" + calid + "&uid=";
			if(checkUserId != null && checkUserId != 'null' && checkUserId != undefined){
				strUrl += "&checkUserId="+checkUserId;
			}
			Common.open("", "WorkReportPop", "업무보고", strUrl, "1000px", "580px", "iframe", true, null, null, true);
		} else {
			Common.open("", "WorkReportPop", "업무보고", "regWorkReport.do?mode=W&calid=" + calid, "1000px", "580px", "iframe", true, null, null, true);
		}
	};
	
	var refresh = function() {
		$("#selDivision").val("");
		$("#selJob").val("");
		$("#selType").val("");
		
		$("#startDate").val("");
		$("#endDate").val("");
		
		bindGridData();
	};
	
	var bindSelect = function() {
		var selDiv = $("#selDivision");
		var selJob = $("#selJob");
		var selType = $("#selType");
		
		selDiv.append("<option value=''>분류전체</option>");
		selJob.append("<option value=''>업무전체</option>");
		selType.append("<option value=''>구분전체</option>");
		
		
		$.getJSON("getWorkReportDiv.do", {}, function(d) {
			var list = d.list;
			list.forEach(function(obj) {
				selDiv.append("<option value='" + obj.code + "'>" + obj.name + "</option>");
			});
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("getWorkReportDiv.do", response, status, error);
		});
		
		$.getJSON("getworkjob.do", {division : ""}, function(d) {
			var list = d.list;
			list.forEach(function(obj) {
				selJob.append("<option value='" + obj.JobID + "'>" + obj.JobName + "</option>");
			});
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("getworkjob.do", response, status, error);
		});
		
		$.getJSON("getWorkReportType.do", {}, function(d) {
			var list = d.list;
			list.forEach(function(obj) {
				selType.append("<option value='" + obj.code + "'>" + obj.name + "</option>");
			});
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("getWorkReportType.do", response, status, error);
		});
	};
	
	var searchWorkReport = function() {
		bindGridData();
	};
	
	var showCommentBox = function(idx) {
		var strComment = workReportGrid.list[idx].Comment;
		strComment = strComment.replace(/(\r\n|\n)/igm, '<br/>').replace(/ /g, '&nbsp;');
		$("#divCommentContent").empty().html(strComment);
		Common.open("", "commentPop", "의견보기", "divCommentBox", "300px", "200px", "id", true, null, null, true);
	};
	
	
	$(function() {
		
		$(".selectSearchField").on("change", function() {
			bindGridData();
		});
		
		setGrid();
		bindSelect();
	});
</script>