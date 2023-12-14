<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<script type="text/javascript">
	$(document).ready(function(){
		//검색기간 제한
		/* var searchDate = new Date();
		$("#enddate").attr("maxDate", XFN_getDateString(searchDate, 'yyyy-MM-dd'));
		searchDate.setFullYear(searchDate.getFullYear() - 2)
		$("#enddate").attr("minDate", XFN_getDateString(searchDate, 'yyyy-MM-dd')); */
		
	    setGrid();
	    setDateTypeSelect();
		setTimeout(function(){setDate();}, 10);
	});

	var headerData = [{key:'Items',  label:'<spring:message code="Cache.lbl_item"/>', width:'100', align:'center'},
	                  {key:'Cnt',  label:'<spring:message code="Cache.lbl_CountValue"/>', width:'100', align:'center', formatter:function(){
	                	  return this.value.number();
	                  }},
	                  {key:'CoCnt',  label:'<spring:message code="Cache.lbl_Percent"/>(%)', width:'100', align:'center'}]; 
	var myPieChart;
	
	function setChart(list){
		var data_piedou = new Array();
		
		for(var i=0; i<list.length; i++){
			data_piedou.push({label:list[i].Items, value:list[i].Cnt});
		}
		
		var ctx_pie = document.getElementById("canvas_pie").getContext("2d");
		
		if(myPieChart == null | myPieChart == undefined){
	   		myPieChart = new Chart(ctx_pie).Pie(data_piedou);
		}
		else{
			myPieChart.resetData(data_piedou);
		}
	}
	
	var myGrid = new coviGrid();
	
	function setGrid(){
		myGrid.setGridHeader(headerData);
		setGridConfig();
	}
	
	function setGridConfig(){
		var configObj = {
			targetID : "usersystemgrid",
 			//listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
			height : "auto",
			page : {
				pageNo:1,
				pageSize:11
			},
			paging : true
		};
		
		myGrid.setGridConfig(configObj);
	}
	
	function setMode(mode_str){
		document.getElementById("hidden_mode_val").value = mode_str;
		searchChart();
	}
	
	function setDate(){
		var date_str = $("#searchDateType option:selected").val();
		
		var thisyear = new Date();
		var startdate = "";
		var enddate = "";
		
		if(date_str == "Today"){
			startdate = XFN_getCurrDate("-", "dash");
		} else if(date_str == "Yesterday"){
			startdate = XFN_addMinusDateByCurrDate(-1, "-", "dash");
		} else if(date_str == "BeforeYesterday"){
			startdate = XFN_addMinusDateByCurrDate(-2, "-", "dash");
		} else if(date_str == "AWeek"){
			startdate = XFN_addMinusDateByCurrDate(-6, "-", "dash");
		} else if(date_str == "AMonth"){
			startdate = XFN_addMinusDateByCurrDate(-30, "-", "dash");
		} else if(date_str == "TwoMonth") {
			startdate = XFN_addMinusDateByCurrDate(-61, "-", "dash");
		} else if(date_str == "ThisYear"){
			thisyear.setMonth(0);	
			thisyear.setDate(1);
			startdate = thisyear.getFullYear() + "-" + (thisyear.getMonth()+1 < 10 ? "0"+(thisyear.getMonth()+1) : thisyear.getMonth()+1) + "-" +(thisyear.getDate() < 10 ? "0"+thisyear.getDate() : thisyear.getDate());					// XFN_TransDateLocalFormat(< % = _strThisYear % > + ".01.01");
		}
		
		if(enddate == ""){
			enddate = XFN_getCurrDate("-", "dash");
		}
		
		document.getElementById("startdate").value = startdate;
		document.getElementById("enddate").value = enddate;
		
		searchChart();
	}
	
	function searchChart(){
		//var minDate = $("#enddate").attr("minDate");
		
		// 검색기간 2년 이하로 제한
		var dateVali = true;
		var strdate = $("#startdate").val();
		var enddate = $("#enddate").val();
		var mode = $("#hidden_mode_val").val();
		
		if((enddate.split("-")[0] - strdate.split("-")[0]) > 2){
			dateVali = false;
		}else if((enddate.split("-")[0] - strdate.split("-")[0]) == 2){
			if(enddate.split("-")[1] > strdate.split("-")[1]){
				dateVali = false;
			}else if(enddate.split("-")[1] == strdate.split("-")[1] && enddate.split("-")[2] > strdate.split("-")[2]){
				dateVali = false;
			}
		}
		
		if(!dateVali){
			Common.Inform("<spring:message code='Cache.msg_CanSelectTwoYearAgo'/>", "Information Dialog", function(result) {
				$("#startdate").val(XFN_getCurrDate("-", "dash"));
				$("#enddate").val(XFN_getCurrDate("-", "dash"));
				
				strdate = $("#startdate").val();
				enddate = $("#enddate").val();
			});

			return false;
		}
		
		$.ajax({
 			url:"static/getstaticusersystemlist.do",
 			method:"POST",
 			data:{
 				"startdate":strdate,
 				"enddate":enddate,
 				"modevalue":mode,
 				"pageNo":"1",
				"pageSize":"11"
 			},
 			success:function (res) {
 				setChart(res.list);
 				
 				myGrid.page.pageNo = 1;
 				
 				myGrid.bindGrid({
					list: res.list,
					page:{
				  	  	pageNo : res.page.pageNo,
				  	  	pageSize : res.page.pageNo,
				  	  	pageCount : res.page.pageNo,
				  	  	listCount : res.page.pageNo
			  	  }
 				});
 			}
 		});
	}
	
	function setDateTypeSelect(){
		$("#searchDateType").bindSelect({
            reserveKeys: {
                optionValue: "value",
                optionText: "name"
            },
            options : [{"name":"<spring:message code='Cache.btn_Today'/>", "value":"Today"},
                       {"name":"<spring:message code='Cache.btn_Yesterday'/>", "value":"Yesterday"},
                       {"name":"<spring:message code='Cache.btn_BeforeYesterday'/>", "value":"BeforeYesterday"},
                       {"name":"<spring:message code='Cache.btn_AWeek'/>", "value":"AWeek"},
                       {"name":"<spring:message code='Cache.btn_AMonth'/>", "value":"AMonth"},
                       {"name":"<spring:message code='Cache.btn_TwoMonth'/>", "value":"TwoMonth"},
                       {"name":"<spring:message code='Cache.btn_AYear'/>", "value":"ThisYear"}]
        });
	}
</script>
<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code="Cache.tte_UserSystemStatic"/></span>
	<!-- TODO 초기 페이지로 설정 향후 개발 (미구현 사항으로 숨김처리) -->
	<%-- <a href="#" class="set_box">
		<span class="set_initialpage"><p><spring:message code="Cache.btn_SettingFirstPage"/></p></span>
	</a> --%>
</h3>
<form id="form1">
	<div style="width:100%;min-height: 500px">
		<div id="topitembar_1" class="topbar_grid">
			<label>
				<input type="button" id="per_browser" value="<spring:message code="Cache.btn_EachBrowser"/>" onclick="setMode('Browser');"class="AXButton"/>
				<input type="button" id="per_os" value="<spring:message code="Cache.btn_EachOS"/>" onclick="setMode('OS');" class="AXButton"/>
				<input type="button" id="per_revolution" value="<spring:message code="Cache.btn_EachResolution"/>" onclick="setMode('Resolution');" class="AXButton"/>
				<input type="button" id="per_region" value="<spring:message code="Cache.btn_EachRegion"/>" onclick="setMode('Region');" class="AXButton"/>
			</label>
		</div>
		<div id="topitembar_2" class="topbar_grid">
			<%-- <label>
				<input type="button" id="conn_today" value="<spring:message code="Cache.btn_Today"/>" onclick="setDate('Today');" class="AXButton"/>
				<input type="button" id="conn_yester" value="<spring:message code="Cache.btn_Yesterday"/>" onclick="setDate('Yesterday');" class="AXButton"/>
				<input type="button" id="conn_beforeyester" value="<spring:message code="Cache.btn_BeforeYesterday"/>" onclick="setDate('BeforeYesterday');" class="AXButton"/>
				<input type="button" id="conn_week" value="<spring:message code="Cache.btn_AWeek"/>" onclick="setDate('AWeek');" class="AXButton"/>
				<input type="button" id="conn_month" value="<spring:message code="Cache.btn_AMonth"/>" onclick="setDate('AMonth');" class="AXButton"/>
				<input type="button" id="conn_twomonth" value="<spring:message code="Cache.btn_TwoMonth"/>" onclick="setDate('TwoMonth');" class="AXButton"/>
				<input type="button" id="conn_year" value="<spring:message code="Cache.btn_AYear"/>" onclick="setDate('ThisYear');" class="AXButton"/>
			</label> --%>
			<label>
				<select id="searchDateType" class="AXSelect" onchange="setDate();"></select>
			</label>
			<label>
				<input type="text" id="startdate" style="width: 85px" class="AXInput" /> ~ 
				<input type="text" kind="twindate" date_startTargetID="startdate" id="enddate" style="width: 85px" class="AXInput" />
				<input type="button" value="<spring:message code="Cache.btn_search"/>"  onclick="searchChart();"class="AXButton"/>
			</label>
		</div>
		<div style="text-align: center; widows: 100%; margin: 20px">
			<canvas id="canvas_pie" height="300" width="470"></canvas>
		</div>
		<div id="usersystemgrid"></div>
	</div>
	<input type="hidden" id="hidden_mode_val" value="Browser"/>
</form>