<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="collabo_popup_wrap" id="collabStatisPopup">
	<div class="c_titBox">
		<h3 class="cycleTitle">${groupName}
		<c:if test ="${ not empty searchKeyword }">	
		(
			<c:choose>
				<c:when test = "${searchOption eq 1}">
					<spring:message code='Cache.lbl_subject'/> <!-- 제목 -->
				</c:when>
				<c:when test = "${searchOption eq 2}">
					<spring:message code='Cache.lbl_Contents' /></option> <!-- 내용 -->
				</c:when>
				<c:when test = "${searchOption eq 3}">
					<spring:message code='Cache.lbl_Tag' /></option> <!-- 태그 -->
				</c:when>
				<c:otherwise>
					<spring:message code='Cache.lbl_subject' /> + <spring:message code='Cache.lbl_Contents' /> + <spring:message code='Cache.lbl_Tag' /></option> <!-- 제목 + 내용 + 태그 -->
				</c:otherwise>
			</c:choose>
			:
			${searchKeyword}
		)
		</c:if> 
		<div id="divDate" >
			<input class="adDate title_calendar" type="text" id="StartDate" date_separator="." readonly value="${startDate}"> <span class="adLine">~</span> 
			<input id="EndDate" date_separator="." date_startTargetID="StartDate" class="adDate title_calendar" type="text" readonly value="${endDate}">
		</div>								
		</h3>
	</div>
	<div class="selectBox" id="selectBoxDiv">
		<span>
			<c:forEach var="item" items="${modeList}"  varStatus="status">
				<div class="chkStyle10">
					<input type="checkbox" class="check_class" id="chk_${status.index}" ${mode==item[0]?"checked":""} value="${item[0]}" >
					<label for="chk_${status.index}"><span class="s_check"></span><spring:message code='Cache.${item[1]}'/></label>
				</div>	
			</c:forEach>
		</span>	
		<select class="selectType01" id="selectSize">
			<option>10</option>
			<option>20</option>
			<option>30</option>
		</select>
		<button href="#" class="btnRefresh" type="button"></button>							
	</div>
	<div class="tblList tblCont">
		<form id="form1">
			<div id="collabStatisPopupDiv">
			</div>
		</form>
		<input type="hidden" id="initStartDate" value="${startDate}" />
		<input type="hidden" id="initEndDate" value="${endDate}" />
		<input type="hidden" id="searchKeyword" value="${searchKeyword}" />
		<input type="hidden" id="searchOption" value="${searchOption}" />
	</div>
</div>
<script type="text/javascript">
var collabStatisPopup = {
		grid:'',
		objectInit : function(){		
			this.makeGrid();
			this.addEvent();
			this.searchData(1);
			$("#EndDate").bindTwinDate({
				startTargetID : "StartDate",
				separator : ".",
				onChange:function(){
					collabStatisPopup.searchData(1);
				},
				onBeforeShowDay : function(date){
					var fnStr = $("#"+this.config.targetID.split("_")[2]).attr("onBeforeShowDay");
					if(fnStr != null && fnStr != ""){
						return coviCmn.callFnBasedNamespace(fnStr, [date]);
					}
				}
			})
		},
		makeGrid :function(){
			var configObj = {	
					targetID : "collabStatisPopupDiv",height : "auto",
					page : {pageNo: 1,pageSize: 10,},
					paging : true};
			var headerData = [
					{key:'PrjName', label:"<spring:message code='Cache.lbl_project_name'/>",width:'2', align:'left', display:true,formatter:function(){
						return this.item.PrjName == null?"My":this.item.PrjName					
					}},
					{key:"TaskName",  label:"<spring:message code='Cache.lbl_prj_workName'/>",width:'2',align:'left',formatter:function(){
						return "<a id=taskInfo data-taskseq='"+this.item.TaskSeq+"'>"+collabUtil.getTaskStatus(this.item)+"</a>"
					}}, 
					{key:"TmUserCount",  label:"<spring:message code='Cache.lbl_TFTotalCount'/>",width:'1',align:'center',display:true}, 
					{key:'Scope',  label:"<spring:message code='Cache.lbl_scope'/>",width:'2',align:'center',display:true,formatter:function(){
						return coviCmn.getDateFormat(this.item.StartDate) + "~" +coviCmn.getDateFormat(this.item.EndDate)
					}}, 
					{key:'ProgRate',  label:"<spring:message code='Cache.lbl_ProgressRate'/>",width:'1',align:'center',display:true} 
     		];
			this.grid = new coviGrid();
			this.grid.setGridHeader(headerData);
			this.grid.setGridConfig(configObj);
		},
		addEvent : function(){
			$('#collabStatisPopup #seValue').on('keypress', function(e){
				if(event.keyCode==13) {collabStatisPopup.searchData(1); return false;}
			});
			$('#collabStatisPopup #selectSize').on('change', function(e){
				collabStatisPopup.searchData(1);
			});
			
			$('#collabStatisPopup .btnRefresh').on('click', function(e){
				$('#collabStatisPopup #StartDate').val($('#collabStatisPopup #initStartDate').val());
				$('#collabStatisPopup #EndDate').val($('#collabStatisPopup #initEndDate').val());
				collabStatisPopup.searchData(1);
			});
			
			$(".check_class").click(function() {
				 $('.check_class').not(this).prop("checked", false);
				 collabStatisPopup.searchData(1);
			});
			
			$(document).on('click','#taskInfo',function() {
					collabUtil.openTaskPopup("", "", $(this).data("taskseq"), $(this).data("taskseq"));
			});
		},
		searchData:function(pageNo){
			var trgArr = new Array();//, "groupBy":$('.check_class:checked').val()

			var params = {"groupKey":"${groupKey}","groupCode":"${groupCode}","prjType":"${prjType}","prjSeq":"${prjSeq}","mode":$('.check_class:checked').val()
					,"startDate":$("#StartDate").val()
					,"endDate":$("#EndDate").val(), "searchKeyword":$("#searchKeyword").val(), "searchOption":$("#searchOption").val()};
			if (pageNo !="-1"){
				this.grid.page.pageNo =pageNo;
				this.grid.page.pageSize = $('#collabStatisPopup #selectSize').val();
			}	
			// bind
			this.grid.bindGrid({
				ajaxPars : params,
				ajaxUrl:"/groupware/collabStatis/getStatisStatusCurst.do"
			});

		}
	}
$(document).ready(function(){
	collabStatisPopup.objectInit();
});
</script>