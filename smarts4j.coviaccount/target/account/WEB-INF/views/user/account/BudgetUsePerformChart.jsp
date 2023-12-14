<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
	<script type="text/javascript" src="/covicore/resources/ExControls/Chart.js-master/Chart.js<%=resourceVersion%>"></script>  
</head>

<style>
	.pad10 { padding:10px;}
	.inPerView .inPerTitbox input {    border: 0px;background-color1:gray}
</style>

<body>
<form id=f>
<input type=hidden name="companyCode" readonly value="${companyCode}">
	<div class="layer_divpop ui-draggable docPopLayer" style="width:98%;padding:20px" source="iframe" modallayer="false" layertype="iframe" pproperty="">
			<div class="bodysearch_Type01">
				<div class="inPerView  type08">
					<div class="inPerTitbox">
						<span class="bodysearch_tit">
							<spring:message code='Cache.ACC_lbl_budget' /><spring:message code='Cache.lbl_apv_vacation_year' />	<!-- 예산년도 -->
						</span>
						<input type=text name="fiscalYear" readonly value="${fiscalYear}" style="width:90px">
					</div>
					<div class="inPerTitbox">
						<span class="bodysearch_tit" style="width:100px">
							<spring:message code='Cache.ACC_lbl_DeptUser' />	<!-- 부서/사용자 -->
						</span>
						<input type=text name="costCenterName" readonly value="${costCenterName}">					
					</div>
					<div class="inPerTitbox">
						<span class="bodysearch_tit">
							<spring:message code='Cache.ACC_lbl_accountCode' />	<!-- 예산계정 -->
						</span>
						<input type=hidden name="searchType" readonly value="${searchType}">	
						<input type=text name="searchStr" readonly value="${searchStr}">	
					</div>
					<div class="inPerTitbox">
						<input type="radio" id="a1" name="groupbyCol" value="Cost" <c:if test="${groupbyCol eq 'Cost'}">checked</c:if> onclick="$('#f').submit()" >
						<label for="a1"><spring:message code="Cache.ACC_lbl_DeptUser"/></label>	<!--부서/사용자명  -->
						<input type="radio" id="a2" name="groupbyCol" value="Account" <c:if test="${groupbyCol eq 'Account'}">checked</c:if> onclick="$('#f').submit()">
						<label for="a2"><spring:message code='Cache.ACC_lbl_budget' /><spring:message code='Cache.ACC_lbl_accountCode' /></label> 
						<input type="hidden" name="authMode" value="A"/>
					</div>
					
				</div>	
			</div>
			
			<div class='canvasDiv' style="width:900px;height:350px;text-align:center">
	        	<canvas id="myChart"></canvas>
        	</div>
	</div>
</form>
</body>

<script>

	if (!window.BudgetUsePerformChart) {
		window.BudgetUsePerformChart = {};
	}
	
	(function(window) {
		var BudgetUsePerformChart = {
				pageInit : function(){
					var me = this;
					me.setChart();
				},
				
				setChart: function() {

					var ctx = document.getElementById("myChart");

					var  labels = [];
					var  aBudgetAmount  = [];
					var  aUsedAmount  = [];
					
					<c:forEach items="${resultList}" var="item" varStatus="status">
						labels.push("${item.GroupbyName}");
						aBudgetAmount.push(parseInt("${item.BudgetAmount}"));
						aUsedAmount.push(parseInt("${item.UsedAmount}"));
					</c:forEach>
				
					var myChart = new Chart(ctx, {
					    type : "bar",
					    data : {
					          labels: labels
					        , datasets : [{
					              label: "#예산금액"
					            , data: aBudgetAmount			
					        },
					        {
					              label: "#사용금액"
					            , data: aUsedAmount
					            , backgroundColor:"#EDD3ED"
					        }]
					    }
					    , options : {
					        scales : {
					            xAxes : [{
					            	stacked: true
					            }]
					            ,yAxes : [{
					                ticks : { beginAtZero : true 
		 					            	,userCallback:function(value, index, values){
		 					            		if(value > 0 && value < 1) value = value.toFixed(1);
		 					            		return value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");}
					            			}
					            }]
					        }
					    }
					});
				},
				
				closeLayer : function() {
					var isWindowed	= CFN_GetQueryString("CFN_OpenedWindow");
					var popupID		= CFN_GetQueryString("popupID");
					
					if(isWindowed.toLowerCase() == "true") {
						window.close();
					} else {
						parent.Common.close(popupID);
					}
				}
		}
		window.BudgetUsePerformChart = BudgetUsePerformChart;
	})(window);
	
	BudgetUsePerformChart.pageInit();
	
</script>