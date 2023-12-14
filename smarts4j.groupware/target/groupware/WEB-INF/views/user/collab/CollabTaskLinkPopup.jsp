<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"  import="egovframework.baseframework.util.SessionHelper,egovframework.baseframework.util.PropertiesUtil"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!doctype html>
<html lang="ko">
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<body>	

	<div class="collabo_popup_wrap">
	
		<div class="selectCalView">
			<!-- 섹션 select -->
			<select class="selectType02" id="seColumn" style="width:130px;">
				<c:if test="${pType eq 'M'}">
					<option value="W" ><spring:message code='Cache.lbl_Standby' /></option>
					<option value="P" ><spring:message code='Cache.lbl_Progress' /></option>
					<option value="H" ><spring:message code='Cache.lbl_Hold' /></option>
					<option value="C" ><spring:message code='Cache.lbl_Completed' /></option>
				</c:if>
				<c:if test="${pType ne 'M'}">
					<c:forEach items="${sectionList}" var="list" varStatus="status">
						<option value="${list.SectionSeq}" >${list.SectionName}</option>
					</c:forEach>
				</c:if>
				
			</select>
			<!-- 업무검색 input -->
			<div class="dateSel type02">
				<input type="text" id="seValue">
			</div>
			<!-- 검색btn -->
			<a href="#" class="btnTypeDefault btnSearchBlue nonHover" id="btnSearch"><spring:message code='Cache.btn_search'/></a>	
		</div>
		
		<div class="c_titBox">
			<h3 class="cycleTitle2"><spring:message code='Cache.lbl_task_task'/></h3>	<!-- lbl_task_task : 업무 -->
		</div>
		<div class="tblList tblCont boradBottomCont StateTb">
			<div id="collabGridDiv"></div>
		</div>
		
		<div class="popBtnWrap">
			<a href="#" class="btnTypeDefault btnTypeBg" id="btnSelect"><spring:message code='Cache.btn_Select'/></a> 	<!-- btn_Select : 선택 -->
			<a href="#" class="btnTypeDefault" id="btnClose"><spring:message code='Cache.btn_Close'/></a>	 	<!-- btn_Close : 닫기 -->
		</div>
	</div>
</body>
<script type="text/javascript">

var collabTaskLink = {
		callbackFunc:CFN_GetQueryString("callBackFunc")
		, grid:''
		, objectInit : function(){	
			this.makeGrid();		// grid initial Setting
			this.addEvent();
			collabTaskLink.searchData(1);
		},
		// grid initial setting.
		makeGrid :function(){
			var configObj = {	
					targetID : "collabGridDiv",
					height : "auto",
					page : {
						pageNo: 1, 
						pageSize: 5
						},
					paging : true
			};
			var headerData =  [ 
				       {key:'radio', label:"<spring:message code='Cache.btn_Select'/>", width:'46', align:'center', editor : {type : 'radio'} } 	// btn_Select : 선택
				       , {key:'TaskName',  label:"<spring:message code='Cache.lbl_TaskName'/>",width:'180',align:'left'}	// lbl_TaskName : 업무명
				       , {key:'TaskSeq',  label:'TaskSeq', display:false}
				];
			
			collabTaskLink.grid = new coviGrid();
			collabTaskLink.grid.setGridHeader(headerData);
			collabTaskLink.grid.setGridConfig(configObj);
		},
		addEvent : function(){	
			// 검색 버튼 클릭 이벤트.
			$("#btnSearch").on('click', function(){
				collabTaskLink.searchData(1);
			});
			
			$("#seValue").on('keydown', function(key){
				if (key.keyCode == 13) {
					collabTaskLink.searchData(1);
				}
			});
			
			// 팝업 닫기 버튼
			$("#btnClose").on('click', function(){
				// 1. >> 2. postMessage 사용
				
				
				
				
				
				if(opener) {
					window.opener.postMessage(
							{ 	functionName : collabTaskLink.callbackFunc
								, params : { "Type" : "close"}
							}, '*'
					);
					
					window.close();
				} else if(parent) {
					window.parent.postMessage(
							{ 	functionName : collabTaskLink.callbackFunc
								, params : { "Type" : "close"}
							}, '*'
					);
					
					Common.Close();
				}
				
			});
			
			// 선택 버튼 클릭 이벤트
			$("#btnSelect").on('click', function() {
				if ( collabTaskLink.grid.getSelectedItem().error != "noselected" ) {
					// 1. 선택버튼 하드 코딩. > postMessage로 변경.
					// 2. postMessage 사용
					
					if(opener) {
						window.opener.postMessage(
								{ 	functionName : collabTaskLink.callbackFunc
									, params : { 	"TaskSeq" : collabTaskLink.grid.getSelectedItem().item.TaskSeq
												, "TaskName" : collabTaskLink.grid.getSelectedItem().item.TaskName
												, "Type" : "selected"
											}
								}, '*'
						);
						
						window.close();
					} else if(parent) {
						window.parent.postMessage(
								{ 	functionName : collabTaskLink.callbackFunc
									, params : { 	"TaskSeq" : collabTaskLink.grid.getSelectedItem().item.TaskSeq
												, "TaskName" : collabTaskLink.grid.getSelectedItem().item.TaskName
												, "Type" : "selected"
											}
								}, '*'
						);
						
						Common.Close();	
					}
				} else {
					Common.Inform(Common.getDic("lbl_Mail_NoSelectItem")); 	// lbl_Mail_NoSelectItem : 선택된 항목이 없습니다.
				}
			});
		},
		searchData : function(pageNo){ 	// 검색.
			
			if (pageNo !="-1"){
				collabTaskLink.grid.page.pageNo =pageNo;
				collabTaskLink.grid.page.pageSize = 5;
			}	
			
			var params = {
					"sectionSeq": $("#seColumn").val() 	// 섹션값
					, "searchText": $("#seValue").val() // input 검색어
					, "prjSeq" : "${pSeq}" 				// prjSeq
					, "prjType" : "${pType}"			// prjType
					, "pageNo" : pageNo
					, "pageSize" : collabTaskLink.grid.page.pageSize
					, "excludeTaskSeq" : "${pTaskSeq}" 	// 자신업무 조회 제외.
			};
		
			// 내업무일 경우 날짜 정보 같이 전송
			if ("${pType}" === "M") {
				params.taskStatus = $("#seColumn").val();
			}
			
			// bind
			collabTaskLink.grid.bindGrid({
				ajaxPars : params
				, ajaxUrl:"/groupware/collabTask/getTaskLink.do"
				, onLoad : function() {
				}
			});

		},
}

$(document).ready(function(){
	collabTaskLink.objectInit();
});

</script>