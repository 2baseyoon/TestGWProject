<%-- <%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>


<script type="text/javascript">
/**
 * Require Files for AXISJ UI Component...
 * Based		: jQuery
 * Javascript 	: AXJ.js, AXTree.js, AXInput.js, AXSelect.js
 * CSS			: AXJ.css, AXTree.css, AXInput.css, AXSelect.css
 */	
var pageID = "setList";
var myTree = new AXTree();

var fnTreeObj = {
	pageStart: function(){

		fnTreeObj.tree1();
		
		var List = [
			{no:1, nodeName:"LEVEL 1-1", writer:"tom", type:"0", pno:0},
			{no:2, nodeName:"LEVEL 2-1", writer:"tom", type:"0", pno:0},
			{no:3, nodeName:"LEVEL 3-1", writer:"tom", type:"0", pno:0},
			{no:11, nodeName:"LEVEL 1-1-1", writer:"tom", type:"0", pno:1},
			{no:21, nodeName:"LEVEL 2-1-1", writer:"tom", type:"0", pno:2},
			{no:24, nodeName:"LEVEL 2-1-4", writer:"tom", type:"0", pno:2},
			{no:241, nodeName:"LEVEL 2-1-4-1", writer:"tom", type:"0", pno:24},
			{no:2411, nodeName:"LEVEL 2-1-4-1-1", writer:"tom", type:"0", pno:241},
			{no:2412, nodeName:"LEVEL 2-1-4-1-1", writer:"tom", type:"0", pno:241},
			{no:25, nodeName:"LEVEL 2-1-2", writer:"tom", type:"0", pno:2},
		];
		myTree.setList(List);
	},
	tree1: function(){

		myTree.setConfig({
			targetID : "AXTreeTarget",
			theme: "AXTree_none",
            xscroll:true,
			relation:{
				parentKey:"pno",
				childKey:"no"
			},
			colGroup: [
				{
					key:"nodeName",
					label:"제목",
					width:"220", align:"left",
					indent:true,
					getIconClass: function(){
						var iconNames = "folder, AXfolder, movie, img, zip, file, fileTxt, fileTag".split(/, /g);
						var iconName = "";
						if(this.item.type) iconName = iconNames[this.item.type];
						return iconName;
					},
					formatter:function(){
						return "<b>"+this.item.no.setDigit(2) + "</b> : " + this.item.nodeName + " (" + this.item.writer + ")";
					}
				}
			],
			body: {
				onclick:function(idx, item){
					toast.push(Object.toJSON(item));
				}
			}
		});
	}
};

$(window).load(function(){fnTreeObj.pageStart();});
	
</script>

<div id="AXTreeTarget" style="height:400px;"></div>

<!-- 
<table style="width: 100%; height: 100%; border: 1px solid black;">
	<tr>
		<td style="width: 150px; float: left; margin-top: 10px; margin-left: 10px">공지사항</td>
	</tr>
	<tr>
		<td style="width: 150px; float: left; margin-top: 10px; margin-left: 10px">경조사</td>
	</tr>
	<tr>
		<td style="width: 150px; float: left; margin-top: 10px; margin-left: 10px">자유게시판</td>
	</tr>
</table>
--> --%>

<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<nav class="lnb">
	<h2 class="gnb_left_tit"><span class="gnb_tit" onclick="leftmenu_goToPageMain(); return false">전자결재</span></h2>
	<ul class="lnb_list">
	</ul>
</nav>

<script type="text/javascript">
	var leftdata = ${userapprovalleft};
	
	function leftmenu_goToPageMain(){
		location.href = "#";
	}
	
	$(document).ready(function (){
		drawadminleftmenu(leftdata);
		
	});
</script>
