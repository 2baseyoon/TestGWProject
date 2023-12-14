<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<jsp:include page="/WEB-INF/views/cmmn/include_chart.jsp"></jsp:include>
</head>
<body>
	<div style='width:100%; text-align:right; padding-top:10px; border-bottom:1px solid #c9c9c9; margin-bottom:10px; padding-bottom:10px;'>
		<span style='display:inline-block; margin-right:10px;'>
			<button class="AXButton" type="button" onclick='chartDownload();'>차트 이미지 저장</button>
		</span>
	</div>
	
	<div id="textNodeTestBox" style="display:none;"></div>
	<div id="drawBox" style="width : 500px; height : 400px;">
	
	</div>
	
	

	<div id="hidDownloadImageBox" style="display:none;">
		<canvas id="canvas"></canvas>	
	</div>
<script>
	var grCode = "${grCode}";
	var startDate = "${startDate}";
	var endDate = "${endDate}";
	
	var typecodes = "";
	var typenames = "";
	var cnt=0;
	
	var svg;
	var canvas;
	var popupWidth = 500;
	
	var drawData = [];
	
	$.ajaxSetup({
		async : false
	});
	
	$(function() {
		canvas = $('#canvas');
		
		$.getJSON("getJobTypeList.do",{gr_code : grCode, startdate : startDate, enddate : endDate}, function(d){
			
			var typeCodelist = d.list;
			
			typeCodelist.forEach(function(obj) {
				$.each(obj,function(key, value){
					if(key == "TypeCode"){
						typecodes +=  value + ";" ;
					}else if(key == "DisplayName"){
						typenames += value + ";";
					}		
				});
			});

			typecodes = typecodes.substring(0,typecodes.length-1);
			typenames = typenames.substring(0,typenames.length-1);

			$("#tbodyResult").html('');
					
			if(typecodes != "") {

				$.getJSON("getSumHourList.do", {gr_code : grCode, startdate : startDate, enddate : endDate , typecodes : typecodes}, function(list){
					var tblBody = "";
					var tblHeader = "";
					var list = list.list;
					var userName = "";
					var stypecodes = typecodes.split(";");
					var displaynames = typenames.split(";");
					var totalData = null;
					
					list.forEach(function(obj) {
						if(obj.UR_Code == 'Total') {
							totalData = obj
							return false;
						}
					});
					
					for(var typeCodeName in totalData) {						
						typeCodelist.forEach(function(obj) {
							if(obj.TypeCode == typeCodeName) {
								var appendObj = {};
								appendObj.DisplayName = obj.DisplayName;
								appendObj.TypeCode = obj.TypeCode;
								appendObj.ManHour = totalData[typeCodeName];
								
								if(appendObj.ManHour > 0)
									drawData.push(appendObj);
									
								return false;
							}
						});
					}
										
				}).error(function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("getSumHourList.do", response, status, error);
				});
			}			
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("getJobTypeList.do", response, status, error);
		});
		
		drawData.sort(function(a,b) {
			return b.ManHour - a.ManHour;
		});
		
		
		if(drawData.length > 0) {
			var listData = drawData;
			var height = (listData.length * 25) + 70;
			
			// d3 svg conf
			svg = d3.select("#drawBox")
					.append("svg")
					.attr("width", popupWidth)
					.attr("height", height)
					.style("background-color", "#fff")
					.attr("id", "chartSVG");
			
			canvas.attr("width", popupWidth)
				  .attr("height", height);
			
			// Title 그리기
			var strTitleText = "팀원 M/H";
			
			svg.append("rect")
			   .attr("x", 0)
			   .attr("y", 0)
			   .attr("width", popupWidth)
			   .attr("height", height)
			   .style("fill", "#fff");
			
			
			svg.append("text")
			   .attr("x", popupWidth / 2 - 30)
			   .attr("y", "23")
			   .text(strTitleText)
			   .style("fill", "black")
			   .style("font-weight", "bold")
			   .style("font-size", "18px");
			
			
			// 치역 환산
			var xScale = d3.scaleLinear()
						   .domain([0, listData[0].ManHour])
						   .range([0, (popupWidth - 20)-200]);
			
			var xAxis = d3.axisBottom().scale(xScale).ticks(5).tickSizeOuter(0).tickPadding(3);
			
			svg.append("g")
			   .attr("class", "x axis")
			   .attr("style", "font-size:12px;")
			   .attr("transform", "translate(200, " + ( height - 20 ) + ")")
			   .call(xAxis);
			
			
			svg.selectAll(".chartBar")
			    .data(listData)
			    .enter()
			    .append("rect")
			    .attr("x", 200)
			    .attr("y", function(d, i) {return i * (20 + 5) + 50 })
			    .attr("width", function(d) {return xScale(d.ManHour)})
			    .attr("height", 20)
			    .attr("fill", "steelblue");
			
			var xLabel = svg.selectAll(".labelX")
							.data(listData)
							.enter()
							.append("text")
							.attr("x", function(d, i) {
								var xPos = xScale(d.ManHour) + 195;
								
								// 화면에 표시되지 못할정도로 작은 비율일때
								if(xPos < 230) {
									xPos = xScale(d.ManHour) + 10 + 200;
								}
								return xPos;
							})
							.attr("y", function(d, i) {return i * (20 + 5) + 15 + 50;})
							.attr("text-anchor", function(d, i) {
								var anchor = "end";
								
								var xPos = xScale(d.ManHour) + 195;
								
								// 화면에 표시되지 못할정도로 작은 비율일때
								if(xPos < 230) {
									anchor = "start";
								}
								
								return anchor;
							})
							.text(function(d) { return parseFloat(d.ManHour).toFixed(0);})
							.style("fill", function(d, i) {
								var color = "#fff";
								
								var xPos = xScale(d.ManHour) + 195;
								
								// 화면에 표시되지 못할정도로 작은 비율일때
								if(xPos < 230) {
									color = "#000";
								}
								
								return color;
							})
							.style("font-size", "12px")
							
			var yLabel = svg.selectAll(".labelY")
							.data(listData)
							.enter()
							.append("text")
							.attr("x", "10")
							.attr("y", function(d, i) {return i * (20 + 5) + 16 + 50;})
							.text(function(d) {
								var fullText = d.DisplayName;
								var changeText = d.DisplayName;
								var sizeChkBox = $("#textNodeTestBox");
								sizeChkBox.text(fullText);
								
								var chkSize = sizeChkBox.width();
								var truncateSize = 2;
								
								var isTruncate = (chkSize > 190);
								
								while(chkSize > 190) {
									changeText = fullText.substr(0, fullText.length = truncateSize);
									sizeChkBox.text(changeText);
									chkSize = sizeChkBox.width();
									
									truncateSize += 2;
								}
								
								if(isTruncate)
									changeText = "...";
								
								return changeText;
							})
							.style("fill", "black")
							.style("font-size", "12px");
		}
		
		$.ajaxSetup({
			async : true
		});
	});
	
	
	var chartDownload = function() {
		
		if(_ie) {
			Common.Inform('IE에서는 사용할 수 없습니다.<br/>우클릭 > 다른이름으로 저장을 통해 저장해 주세요.', '알림');
			return false;
		}
		
		var canvas = document.getElementById('canvas');
		var ctx = canvas.getContext('2d');
		var toImgSVG = document.getElementById('chartSVG');
		var data = (new XMLSerializer()).serializeToString(toImgSVG);
		var DOMURL = window.URL || window.webkitURL || window;
		
		var img = new Image();
		var svgBlob = new Blob([data], {type: 'image/svg+xml;charset=utf-8'});
		var url = DOMURL.createObjectURL(svgBlob);
		
		img.onload = function () {
		  ctx.drawImage(img, 0, 0);
		  DOMURL.revokeObjectURL(url);
		
		  var imgURI = canvas
		      .toDataURL('image/png')
		      .replace('image/png', 'image/octet-stream');
		
		  triggerDownload(imgURI);
		};
		
		img.src = url;
	};
	
	var triggerDownload = function(imgURI) {
		var evt = new MouseEvent('click', {
			view: window,
			bubbles: false,
			cancelable : true
		});
		
		var a = $("<a></a>");
		a.attr('download', 'chart_tmh_' + startDate + '_' + endDate + '.png')
		 .attr('href', imgURI)
		 .attr('target', '_blank');
		
		a[0].dispatchEvent(evt);
	};
</script>

</body>
</html>