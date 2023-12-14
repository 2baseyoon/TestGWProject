<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<h3 class="con_tit_box">
	<span class="con_tit"></span><%-- API 호출로그관리 --%>
</h3>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="/covicore/resources/ExControls/Chart.js-master/Chart.js<%=resourceVersion%>"></script>
<form id="form1">
	<div style="width:100%;min-height: 500px">
		<div id="topitembar01" class="topbar_grid">
			<input type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"/>
		</div>
		<div id="topitembar02" class="topbar_grid">
			<!--소유회사-->
			<spring:message code="Cache.lbl_Company"/>:
			<select id="companySelectBox" class="AXSelect W100" onchange="searchReqStatGrid();"></select>
			&nbsp;
			Search Type:
			<select id="searchType" class="AXSelect" onchange="searchReqStatGrid();"></select>
			&nbsp;
			<select id="searchDateType" class="AXSelect" onchange="setDate();"></select>
			<input type="text" id="startdate" style="width: 85px" class="AXInput" /> ~ 
			<input type="text" kind="twindate" date_startTargetID="startdate" id="enddate" maxDate="" minDate="" style="width: 85px" class="AXInput" />
			
			<select id="searchTarget" class="AXSelect"></select>
<!-- 			<input type="text" id="searchKeyword" class="AXInput" onkeypress="if (event.keyCode==13){ searchReqStatGrid(); return false;}" /> -->
			<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchReqStatGrid();" class="AXButton"/><!--검색 -->
		</div>	
		<canvas id="requestLogGraph" style="width:100%;height:400px;"></canvas>
		<div id="requestStatGrid" style="margin-top:15px;"></div>
	</div>
</form>

<script type="text/javascript">
	var requestStatGrid;
	var headerData;
	var lang = Common.getSession("lang");
	
	initContent();
	
	function initContent(){ 
		requestStatGrid = new coviGrid();
		// 헤더 설정
		
		headerData =[
		             {key:'ReqDay', label:'<spring:message code="Cache.lbl_reqDay"/>', width:'90', align:'center'},
		             {key:'ReqCnt', label:'<spring:message code="Cache.lbl_api_reqCnt"/>', width:'90', align:'center'},
		             {key:'SuccessCnt', label:'<spring:message code="Cache.lbl_api_successCnt"/>', width:'90', align:'center'},
		             {key:'TotalFailCnt', label:'<spring:message code="Cache.lbl_api_failCnt"/>', width:'90', align:'center'},
		             {key:'ErrorCnt', label:'<spring:message code="Cache.lbl_api_errorCnt"/>', width:'90', align:'center'},
		             {key:'LimitCnt', label:'<spring:message code="Cache.lbl_api_limitCnt"/>', width:'90', align:'center'},
		             {key:'AuthErrorCnt', label:'<spring:message code="Cache.lbl_api_authErrorCnt"/>', width:'90', align:'center'},
		             {key:'AvgTotalTime', label:'<spring:message code="Cache.lbl_elapsedTime_Total"/>', width:'90', align:'center', display:false, formatter : function(){
		            	 return this.item.AvgTotalTime + " ms";
		             }},
		             {key:'AvgApplicationTime', label:'<spring:message code="Cache.lbl_elapsedTime_App"/>', width:'90', align:'center', display:false, formatter : function(){
		            	 return this.item.AvgApplicationTime + " ms";
		             }}
			      	];
		setStatGrid();			// 그리드 세팅
		
		setDateTypeSelect();
		setSearchTargetSelect();
		
		setTimeout(function(){$("#searchDateType").setValueSelect("AMonth");}, 10);
	}
	
	//그리드 세팅
	function setStatGrid(){
		var hasAll = true;
		coviCtrl.renderDomainAXSelect("companySelectBox", lang, null, null, '', hasAll); // 전체표시
		
		requestStatGrid.setGridHeader(headerData);
		requestStatGrid.setGridConfig({
			targetID : "requestStatGrid",
			height:"auto"
		});
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
			enddate = thisyear.getFullYear() + "-12-31"; 
		}
		
		if(enddate == ""){
			enddate = XFN_getCurrDate("-", "dash");
		}
		
		document.getElementById("startdate").value = startdate;
		document.getElementById("enddate").value = enddate;
		
		searchReqStatGrid();
	}
	
	function searchReqStatGrid(){
		
		// 검색기간 2년 이하로 제한
		var dateVali = true;
		var strdate = $("#startdate").val();
		var enddate = $("#enddate").val();
		var text = $("#searchKeyword").val();
		var searchType = $("#searchType").val();
		
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
			url : "/covicore/api/config/getRequestStatList.do",
			type : "POST",
 			data : {
 				"DomainID" : $("#companySelectBox").val(),
 				"SearchTarget" : $("#searchTarget").val(),
 				"StartDate":strdate,
 				"EndDate":enddate,
 				"SearchKeyword" : text,
 				"SearchType" : searchType
 			},
			success: function(data){
				if(data.status === "SUCCESS"){
					var list_ = data.data;
					for(var i = 0; i < headerData.length; i++) {
						if(searchType == "COUNT") {
							if(headerData[i].key == "AvgTotalTime" || headerData[i].key == "AvgApplicationTime"){
								headerData[i].display = false;
							}else{
								headerData[i].display = true;
							}
						}else{
							if(headerData[i].key == "AvgTotalTime" || headerData[i].key == "AvgApplicationTime"){
								headerData[i].display = true;
							}else{
								headerData[i].display = false;
							}							
						}
						
						if(headerData[i].key == "ReqDay") {
							headerData[i].display = true;
						}
					}
					requestStatGrid.setGridHeader(headerData);
					requestStatGrid.setData({
						  list: list_
						, page: {
							listCount: list_.length
						}
					});
					requestStatGrid.redrawGrid();
					
					
					// Draw Line chart
					requestLogGraphObj.drawChart(list_);
				}else{
					Common.Warning(data.message);
				}
			},
			error: function(response, status, error){
			     CFN_ErrorAjax("/covicore/api/config/getRequestStatList.do", response, status, error);
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
		$("#searchType").bindSelect({
            reserveKeys: {
                optionValue: "value",
                optionText: "name"
            },
            options : [{"name":"건수", "value":"COUNT"},
                       {"name":"응답시간", "value":"ELAPSED_TIME"}]
        });
	}
	
	function setSearchTargetSelect () {
		var paramDomainID = $("#companySelectBox").val(); 
		$.ajax({
			url : "/covicore/api/config/getConfigListAll.do",
			type : "post",
			data : {"DomainID" : paramDomainID == "" || paramDomainID == undefined ? "ALL" : paramDomainID},
			async:false,
			success:function (data) {
				var dup = [];
				var list = [];
				list.push({"Path": "", "PathText" : "전체"});
				for(var i = 0; i < data.data.length; i++) {
					if(dup.indexOf(data.data[i].Path) == -1) {
						list.push({"Path" : data.data[i].Path, "PathText" : data.data[i].Path});
					}
				}
				$('#searchTarget').bindSelect({
					reserveKeys: {
						optionValue: "Path",
						optionText: "PathText"
					},
					options: list,
					// setValue : paramJobID,
					onchange: function(){
						searchReqStatGrid();
					}
					
				});	
			},
			error: function(response, status, error){
			     CFN_ErrorAjax("/covicore/api/config/getConfigListAll.do", response, status, error);
			}
		});
	}
	
	// 새로고침
	function Refresh(){
		searchReqStatGrid();
	}
	
	/**
	* Chart Handler.
	*/
	var requestLogGraphObj = {
			chart:null,
			chartConfig : {data : {},
					options: {
						responsive : false,
						maintainAspectRatio: false,
						tooltips : { enabled: true },
						legend : { display: true },
						height : "400px",
					    plugins: {
					        legend: {
					          position: 'top',
					        }
					    }
					}
			},	

			initChart:function(data){
				this.chartConfig.type = 'line';
				this.chart = new Chart(  $("#requestLogGraph"), this.chartConfig ); 
			},
			
			drawChart:function(data){
				if(!this.chart) {
					this.initChart();
				}
				var chartData = this.makeDatasets(data);
				this.chart.data = chartData;
				this.chart.update();
			},
			
			makeDatasets : function(data) {
				var datasets = [];
				var labels = [];// days
				var pivots = {};
				var dayinfo = data[0];
				for(var key in dayinfo) {
					pivots[key] = [];
				}
				
				for(var i = 0; i < data.length; i++){
					var dayinfo = data[i];
					var ReqDay = dayinfo.ReqDay;
					labels.push(ReqDay);
					
					var dataset = {};
					for(var key in dayinfo) {
						var value = dayinfo[key];
						
						pivots[key].push(value);
					}
				}
				
				for(var key in pivots) {
					if(key == "CompanyName" || key == "ReqDay"){
						continue;
					}
					
					var _color = "rgb(75, 192, 192)";
					var _hidden = false;
					var _label = key;
					switch(key) {
						case "ReqCnt" :
							_color = "#49e39b";
							_label = "<spring:message code='Cache.lbl_api_reqCnt'/>";
							break;
						case "SuccessCnt" :
							_color = "#2093e6";
							_label = "<spring:message code='Cache.lbl_api_successCnt'/>";
							break;
						case "TotalFailCnt" :
							_color = "red";
							_label = "<spring:message code='Cache.lbl_api_failCnt'/>";
							break;
						case "ErrorCnt" :
							_color = "#b32534";
							_label = "<spring:message code='Cache.lbl_api_errorCnt'/>";
							_hidden = true; // default hidden.
							break;
						case "AuthErrorCnt" :
							_color = "#d4851e";
							_label = "<spring:message code='Cache.lbl_api_authErrorCnt'/>";
							_hidden = true;
							break;
						case "LimitCnt" :
							_color = "#d14c0f";
							_label = "<spring:message code='Cache.lbl_api_limitCnt'/>";
							_hidden = true;
							break;
						case "AvgTotalTime" :
							_color = "#745fe2";
							_label = "<spring:message code='Cache.lbl_elapsedTime_Total'/>";
							break;
						case "AvgApplicationTime" :
							_color = "#ad5bd4";
							_label = "<spring:message code='Cache.lbl_elapsedTime_App'/>";
							break;
						default :
							break;
					}
					var dataset = {
						label : _label,
						data : pivots[key],
					    fill: false,
					    borderColor: _color,
					    backgroundColor: "#FFF",
					    tension: 0.0,
					    hidden : _hidden
					}
					datasets.push(dataset);
				}
				
				var chartData = {
						  labels: labels,
						  datasets: datasets
						};
				
				return chartData;
			}
		}
</script>