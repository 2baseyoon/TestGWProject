<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title></title>
</head>
<body>
    <div class="popBox">
        <div id="surveyContents" style="margin-bottom: 20px;">
        </div>
    </div>
    
<script type="text/javascript" src="/covicore/resources/ExControls/Chart.js-master/Chart.js<%=resourceVersion%>"></script>  
<script>
	var surveyInfo = $.extend(true, {}, ${result.list});	// 설문 정보
	
	initContent();

	// 설문차트보기
	function initContent(){
		init();	// 초기화
	}
	
	// 초기화
    function init() {
    	setSurveyHtml();	// 설문 html
    	
    	setSurveyQuestionHtml();	// 설문 문항 html
    }
	
 	// 설문 html
    function setSurveyHtml() {
		$("#surveyContents").empty();
		
    	var html = "<table class='tableStyle linePlus'>";
    	html += "<colgroup>";
    	html += "<col style='width:10%'>";
    	html += "<col style='width:40%'>";
    	html += "<col style='width:10%'>";
    	html += "<col style='width:40%'>";
    	html += "</colgroup>";
    	html += "<tbody>";
    	html += "<tr>";
    	html += "<th>";
    	html += "<spring:message code='Cache.lbl_polltitle2' />";
    	html += "</th>";
    	html += "<td colspan='3'>";
    	html += surveyInfo.subject;
    	html += "</td>";
    	html += "</tr>";
    	html += "<tr>";
    	html += "<td colspan='4'>";
    	html += surveyInfo.description;
    	html += "</td>";
    	html += "</tr>";
    	html += "<tr>";
    	html += "<td colspan='4'>";
    	html += "<span><spring:message code='Cache.lbl_Survey_period' /> : </span>";
    	html += CFN_TransLocalTime(surveyInfo.surveyStartDate,'yyyy.MM.dd') + "~" + CFN_TransLocalTime(surveyInfo.surveyEndDate,'yyyy.MM.dd');
    	html += "</td>";
    	html += "<tr>";
    	html += "<td colspan='4'>";
		html += "<a class='btnTypeDefault ' onclick='goTarget()'><spring:message code='Cache.lbl_polltargetview' /></a>   ";
		html += "<a class='btnTypeDefault ' onclick='goResultTarget()'><spring:message code='Cache.lbl_title_surveyResult_01' /></a>";
    	html += "</td>";
    	html += "</tr>";
    	html += "<tr>";
    	html += "<td colspan='4'>";
    	html += "<div id='questionContents'>";
    	html += "</div>";
    	html += "</td>";
    	html += "</tr>";
    	html += "</tbody>";
    	html += "</table>";
    	
    	$("#surveyContents").append(html);
 	}
 	
 	// 설문 문항 html
    function setSurveyQuestionHtml() {
    	$("#questionContents").empty();
    	
    	var html =""
    	
    	html += "<table class='tableStyle linePlus'>";
    	html += "<colgroup>";
    	html += "<col style='width:100%'>";
    	html += "</colgroup>";
    	html += "<tbody>";
    	html += "<tr>";
    	html += "<td>";
    	
    	$.each(surveyInfo.questions, function(i, v) {
	    	html += "<table class='tableStyle linePlus questionTable'>";
	    	html += "	<colgroup>";
	    	html += "		<col style='width:10%'>";
	    	html += "		<col style='width:40%'>";
	    	html += "		<col style='width:10%'>";
	    	html += "		<col style='width:40%'>";
	    	html += "	</colgroup>";
	    	html += "	<tbody>";
        	html += "	<tr>";
        	html += "		<td colspan='4'>";
        	html += "			<input type='hidden' value=" + v.questionID + ">";
        	html += "			<input type='hidden' value='" + v.questionType + "'>";
        	html += "			<input type='hidden' value='" + v.isEtc + "'>";
    		html += 			v.questionNO + "&nbsp;&nbsp;" + v.question;
    		//if (v.questionType == "N")
    			
        	//	html += 			"&nbsp;&nbsp;[" + v.items+"위]";
        	html += "		</td>";
        	html += "	</tr>";
        	
        	if (typeof(v.paragraph) != "undefined" && v.paragraph != ''){
	        	html += "<tr>";
	        	html += "	<td colspan='4'><b><spring:message code='Cache.lbl_surveyDirection'/>:&nbsp;</b>" + v.paragraph + '</tr>';
    	    	html += "</tr>";
        	}
        	if (typeof(v.description) != "undefined" && v.description != ''){
	        	html += "<tr>";
	        	html += "	<td colspan='4'><b><spring:message code='Cache.lbl_Description'/>:&nbsp;</b>" + v.description + '</tr>';
	        	html += "</tr>";
        	}
        	
        	html += "	<tr>";
        	html += "		<td colspan='4' class='answerTD'>";
        	if(v.questionType == "D"){ //주관식일떄
        		$(surveyInfo.userAnswersChart).each(function(idx, obj){
        			if(obj.questionId == v.questionID){
        				$.each(obj.labels,function(idx, obj){
    	        			html += "<div style='margin-left:5px; margin-bottom:5px;'><b><spring:message code='Cache.CuPoint_Reply'/>" + (idx+1) + ".</b> " + obj + "</div>" 
    	        		});
        				
        				return false;
        			}
        		});
        		
        		
        	}else if (v.questionType == "N"){
        		$(v.items).each(function(idx, obj){
    	        	html += "			<div class='canvasDiv'>"+obj.itemNO+"위 ";
    	        	html += "				<canvas id='" + v.questionType + "_" + v.questionID + "_" + obj.itemNO + "'></canvas>";
    	        	html += "			</div>";
        		});
        	}else{
	        	html += "			<div class='canvasDiv'>";
	        	html += "				<canvas id='" + v.questionType + "_" + v.questionID + "_0" + "'></canvas>";
	        	html += "			</div>";
        	}

        	html += "		</td>";
        	html += "	</tr>";
	    	html += "	</tbody>";
	    	html += "</table>";
   		});
    	
    	html += "</td>";
    	html += "</tr>";
    	html += "</tbody>";
    	html += "</table>";
    	
    	$("#questionContents").append(html);
    	
    	setChart();	// 차트 생성
    	
    	setEmpty();
 	}
 
	// 설문 대상 보기
    function goTarget() {
    	parent.Common.open("","target_pop","<spring:message code='Cache.lbl_polltargetview' />","/groupware/survey/goTargetRespondentList.do?surveyId="+surveyInfo.surveyID,"500px","665px","iframe",true,null,null,true);
    }
	
	// 결과공개 대상 보기
    function goResultTarget() {
    	parent.Common.open("","result_pop","<spring:message code='Cache.lbl_title_surveyResult_01' />","/groupware/survey/goTargetResultviewList.do?surveyId="+surveyInfo.surveyID,"500px","665px","iframe",true,null,null,true);
    }
 	
 	// 차트
    function setChart() {
 		
		$("#questionContents").find(".canvasDiv").each(function (i, v) {
			var canvasId = $(this).children("canvas").attr("id");
			var qType = canvasId.split('_')[0];
			var qId = canvasId.split('_')[1];
			var qWt = canvasId.split('_')[2];

			var isBind = false;
	    	$.each(surveyInfo.userAnswersChart, function(i, v) {
	    		if (qId == v.questionId && qWt == v.weighting) {
	    			var chartType = '';
	    			
	    			if (qType == 'S') {
	    				chartType = 'pie';
	    				
	    				new Chart($("#" + canvasId).get(0).getContext('2d'), {
	    					  type: chartType,
	    					  data: {
	    						labels: v.labels,
	    						datasets: [{
	    							backgroundColor: v.colors,
	    							data: v.datas
	    						}]
	    					  }
	    				});
	    			} else {
	    				chartType = (qType == 'D') ? 'bar' : 'horizontalBar';
	    				
	    				new Chart($("#" + canvasId).get(0).getContext('2d'), {
							type: chartType,
							data: {
							labels: v.labels,
								datasets: [{
									backgroundColor: v.colors,
									data: v.datas
								}]
							},
							options: {
								legend: {
									display: false
								},
								scales: {
				                    xAxes: [{
			                            display: true,
			                            scaleLabel: {
			                                display: true
			                            },
			                            ticks: {
			                                beginAtZero: true,
			                                min: 0,
			                                stepSize: 1
			                            }			                            
			                        }],									
				                    yAxes: [{
			                            display: true,
			                            ticks: {
			                                beginAtZero: true,
			                                min: 0,
			                                stepSize: 1
			                            }
				                    }]
				                }
							}
	    				});
	    			}
	    			
	    			isBind = true;
		    		return false;
	    		}
	   		});
	    	
	    	if(isBind == false){
	    		$(this).remove();
	    	}
		});
 	} 	
 	
 	function setEmpty(){
 		$("td.answerTD").each(function(idx, obj){
 			if($(obj).html().replace(/^\s+|\s+$/g,"") ==""){
 				$(obj).html('<div style="text-align: center; height: 50px; line-height: 50px;"><spring:message code="Cache.msg_apv_215"/></div>');
 			}
 			
 		});
 	}
 	
</script>    
</body>
</html>
