<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	import="egovframework.baseframework.util.SessionHelper,egovframework.baseframework.util.PropertiesUtil, egovframework.baseframework.util.SessionHelper,egovframework.coviframework.util.RedisDataUtil"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<% 
	String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<!-- 컨텐츠앱 추가 -->
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/contentsApp/resources/css/contentsApp.css">
	<script type="text/javascript" src="<%=cssPath%>/contentsApp/resources/js/contentsApp.js"></script>
	<script type="text/javascript" src="/covicore/resources/ExControls/Chart.js-master/Chart.js<%=resourceVersion%>"></script>  
<div class='caContent'>
	<h3 class="cycleTitle">${chartList[0].ChartName}</h3>
	<div class="inPerView type02 active">
		<div>
			<div id="divCalendar" class="dateSel type02">
				<input class="adDate" type="text" id="startDate" date_separator="." readonly=""> - <input id="endDate" date_separator="." kind="twindate" date_startTargetID="startDate" class="adDate" type="text" readonly="">
			</div>											
			<div class="selectCalView">
				<select id="searchType" class="selectType02">
					<option value="Subject"><spring:message code='Cache.lbl_Title'/></option>	<!-- 제목 -->
					<option value="BodyText"><spring:message code='Cache.lbl_Contents'/></option><!-- 내용 -->
					<option value="CreatorName"><spring:message code='Cache.lbl_writer'/></option><!-- 작성자 -->
					<option value="Total"><spring:message code='Cache.lbl_Title'/> + <spring:message code='Cache.lbl_Contents'/></option>
					<option value="Tag"><spring:message code='Cache.lbl_Tag'/></option>	<!-- 태그 -->
					<c:forEach items="${searchItem}" var="list" varStatus="status">
						<option value="UserForm" ufcolumn="${list.UserFormID}">${list.FieldName}</option>
					</c:forEach>
				</select>
				<input id="searchText" type="text" class="HtmlCheckXSS ScriptCheckXSS">
			</div>											
			<div>
				<a href="#" id="btnSearch" class="btnTypeDefault btnSearchBlue nonHover"><spring:message code='Cache.btn_search'/></a> <!-- 검색 -->
			</div>
		</div>	
	</div>	
	<div>
		<canvas id="chart_${chartList[0].ChartID}" width='300' height='200'></canvas>
	</div>
</div>	
<script>
(function(param){
	var chart;
	var chartColorList = [ "rgb(255,177,193)","rgb(255,207,155)","rgb(255,230,170)","rgb(165,223,223)","rgb(228,229,231)","rgb(154,208,245)","rgb(204,178,255)"  ];			
	var chartType = "${chartList[0].ChartType}".toLowerCase();
	
	var setInit = function(){
		//차트 그리기
		var labels = [];
		var datas = [];
		var colors = []
		var i=0
		<c:forEach items="${chartList[0].ChartData}" var="item" varStatus="status">
			//if ("${list.ChartType}"=="Pie" && parseInt("${item.GroupVal}",10) == 0 ) continue;
			i++;
			labels.push("${item.GroupName==null?'No Answer':item.GroupName}");
			datas.push(parseInt("${item.GroupVal}",10));
			colors.push(chartColorList[i%chartColorList.length]);
			
		</c:forEach>
		var chartObj = {type: chartType,
						data: {labels: labels,
							datasets: [{
									backgroundColor: colors,
									borderColor: colors,
									fill: false,
									data: datas
								}]
						}};
		
		if (chartType != "pie" && chartType != "doughnut"){
			chartObj["options"] ={
				legend: {display: false	},
				responsive: true,
				scales: {
					xAxes: [{
	                    display: true,
	                    scaleLabel: {display: true},
	                    ticks: {beginAtZero: true,min: 0}}],									
	                yAxes: [{
	                    display: true,
	                    ticks: {beginAtZero: true,min: 0}}]
	            }
			};
		}	
				
		chart = new Chart($("#chart_${chartList[0].ChartID}").get(0).getContext('2d'), chartObj);
		
		//검색
		$('#searchText').on('keydown', function(){
			if(event.keyCode=="13"){
				search();
			}	
	    });
	    
		$('#btnSearch').on('click', function(){
			search();
	    });
		
	};

	var search = function(){
		var searchParam = {
				"folderID": "${folderID}",
				"chartID": "${chartID}",
				"startDate": $("#startDate").val(),
				"endDate":$("#endDate").val(),
				"searchType":$("#searchType").val(),
				"searchText":$("#searchText").val(),
				"ufColumn": $("#searchType").val()=="UserForm"?$("#searchType option:selected").attr("ufcolumn"):""};
		
		$.ajax({
			url: "/groupware/contents/getFolderChartData.do",
			type: "POST",
			data: searchParam,
			success: function(res){
				if(res.status === "SUCCESS"){
					var labels = [];
					var datas = [];
					var colors = []
					var i=0
					res.chartData.map(function(item,idx){
						i++;
						labels.push(item.GroupName==null?'No Answer':item.GroupName);
						datas.push(parseInt(item.GroupVal,10));
						colors.push(chartColorList[i%chartColorList.length]);
					});
					chart.data = {"labels": labels,
									"datasets": [{
										backgroundColor: colors,
										borderColor: colors,
										fill: false,
										data: datas
									}]};
					chart.update();
				}else{
					Common.Error("<spring:message code='Cache.msg_ErrorOccurred'/>"); // 오류가 발생하였습니다.
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/board/selectTypeList.do", response, status, error);
			}
		});
	};
	
	var init = function(){
		setInit();
	};
	
	init();
})({
	folderID: "${folderID}"
});
	
	</script>
